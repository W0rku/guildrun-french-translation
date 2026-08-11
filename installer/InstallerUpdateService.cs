using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;

namespace GuildrunFrenchInstallerV21
{
    public enum InstallerUpdateState
    {
        UpToDate,
        Available,
        Unavailable
    }

    public sealed class InstallerReleaseInfo
    {
        public Version Version { get; internal set; }
        public string TagName { get; internal set; }
        public string AssetName { get; internal set; }
        public string DownloadUrl { get; internal set; }
        public string ExpectedSha256 { get; internal set; }
        public string ReleaseUrl { get; internal set; }
    }

    public sealed class InstallerUpdateCheckResult
    {
        public InstallerUpdateState State { get; internal set; }
        public InstallerReleaseInfo Release { get; internal set; }
        public string ErrorMessage { get; internal set; }
    }

    public static class InstallerUpdateService
    {
        public const string LatestReleaseApiUrl = "https://api.github.com/repos/W0rku/guildrun-french-translation/releases/latest";
        private const string ReleaseDownloadPrefix = "/W0rku/guildrun-french-translation/releases/download/";
        private const string InstallerAssetPrefix = "Guildrun_Demo_FR_Installer_V";

        public static InstallerUpdateCheckResult CheckLatestRelease(Version currentVersion)
        {
            return CheckLatestRelease(currentVersion, DownloadReleaseJson);
        }

        public static InstallerUpdateCheckResult CheckLatestRelease(Version currentVersion, Func<string, string> fetchText)
        {
            try
            {
                if (currentVersion == null) throw new ArgumentNullException("currentVersion");
                if (fetchText == null) throw new ArgumentNullException("fetchText");
                InstallerReleaseInfo release = ParseLatestRelease(fetchText(LatestReleaseApiUrl));
                bool available = NormalizeVersion(release.Version).CompareTo(NormalizeVersion(currentVersion)) > 0;
                return new InstallerUpdateCheckResult {
                    State = available ? InstallerUpdateState.Available : InstallerUpdateState.UpToDate,
                    Release = release
                };
            }
            catch (Exception ex)
            {
                return new InstallerUpdateCheckResult {
                    State = InstallerUpdateState.Unavailable,
                    ErrorMessage = ex.Message
                };
            }
        }

        public static InstallerReleaseInfo ParseLatestRelease(string json)
        {
            if (String.IsNullOrWhiteSpace(json)) throw new InvalidDataException("Réponse GitHub vide.");
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Dictionary<string, object> root = serializer.DeserializeObject(json) as Dictionary<string, object>;
            if (root == null) throw new InvalidDataException("Réponse GitHub invalide.");

            string tagName = GetString(root, "tag_name");
            Version releaseVersion = ParseVersionTag(tagName);
            string releaseUrl = GetString(root, "html_url");
            string body = GetOptionalString(root, "body");
            string expectedAssetName = InstallerAssetPrefix + releaseVersion.ToString(3) + ".exe";

            Dictionary<string, object> selectedAsset = null;
            object assetsObject;
            IEnumerable assets = root.TryGetValue("assets", out assetsObject) ? assetsObject as IEnumerable : null;
            if (assets != null)
            {
                foreach (object value in assets)
                {
                    Dictionary<string, object> asset = value as Dictionary<string, object>;
                    if (asset == null) continue;
                    string name = GetOptionalString(asset, "name");
                    string state = GetOptionalString(asset, "state");
                    if (!String.IsNullOrEmpty(state) && !state.Equals("uploaded", StringComparison.OrdinalIgnoreCase)) continue;
                    if (name.Equals(expectedAssetName, StringComparison.OrdinalIgnoreCase)) { selectedAsset = asset; break; }
                    if (selectedAsset == null && name.StartsWith(InstallerAssetPrefix, StringComparison.OrdinalIgnoreCase) && name.EndsWith(".exe", StringComparison.OrdinalIgnoreCase)) selectedAsset = asset;
                }
            }
            if (selectedAsset == null) throw new InvalidDataException("Aucun installateur EXE compatible dans la dernière Release.");

            string assetName = GetString(selectedAsset, "name");
            if (!assetName.Equals(Path.GetFileName(assetName), StringComparison.Ordinal)) throw new InvalidDataException("Nom d’asset GitHub invalide.");
            string downloadUrl = GetString(selectedAsset, "browser_download_url");
            if (!IsTrustedDownloadUrl(downloadUrl)) throw new InvalidDataException("URL de téléchargement GitHub non autorisée.");

            string expectedSha256 = ParseDigest(GetOptionalString(selectedAsset, "digest"));
            if (expectedSha256 == null) expectedSha256 = ExtractSha256FromReleaseBody(body, assetName);

            return new InstallerReleaseInfo {
                Version = releaseVersion,
                TagName = tagName,
                AssetName = assetName,
                DownloadUrl = downloadUrl,
                ExpectedSha256 = expectedSha256,
                ReleaseUrl = releaseUrl
            };
        }

        public static bool IsTrustedDownloadUrl(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) &&
                uri.Scheme.Equals(Uri.UriSchemeHttps, StringComparison.OrdinalIgnoreCase) &&
                uri.Host.Equals("github.com", StringComparison.OrdinalIgnoreCase) &&
                uri.AbsolutePath.StartsWith(ReleaseDownloadPrefix, StringComparison.OrdinalIgnoreCase);
        }

        public static string ComputeSha256(string path)
        {
            using (FileStream stream = File.OpenRead(path))
            using (SHA256 sha = SHA256.Create())
                return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", String.Empty);
        }

        public static string VerifySha256(string path, string expectedSha256)
        {
            string actual = ComputeSha256(path);
            if (!String.IsNullOrWhiteSpace(expectedSha256) && !actual.Equals(expectedSha256.Trim(), StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Le SHA-256 de l’installateur téléchargé ne correspond pas à la Release.");
            return actual;
        }

        public static string ValidateDownloadedInstaller(string path, InstallerReleaseInfo release)
        {
            if (release == null) throw new ArgumentNullException("release");
            string actualHash = VerifySha256(path, release.ExpectedSha256);
            AssemblyName assemblyName = AssemblyName.GetAssemblyName(path);
            if (!NormalizeVersion(assemblyName.Version).Equals(NormalizeVersion(release.Version)))
                throw new InvalidDataException("La version interne de l’installateur téléchargé ne correspond pas à la Release.");
            if (!assemblyName.Name.Equals(Path.GetFileNameWithoutExtension(release.AssetName), StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("L’identité de l’installateur téléchargé est inattendue.");
            return actualHash;
        }

        public static string DownloadAndPrepareInstaller(InstallerReleaseInfo release)
        {
            if (release == null) throw new ArgumentNullException("release");
            if (!IsTrustedDownloadUrl(release.DownloadUrl)) throw new InvalidDataException("URL de téléchargement GitHub non autorisée.");
            string root = Path.Combine(Path.GetTempPath(), "GuildrunFrenchInstallerUpdates", NormalizeVersion(release.Version).ToString(3));
            Directory.CreateDirectory(root);
            string destination = Path.Combine(root, release.AssetName);
            string partial = destination + ".partial-" + Guid.NewGuid().ToString("N");
            try
            {
                using (TimeoutWebClient client = NewGitHubClient(60000)) client.DownloadFile(release.DownloadUrl, partial);
                if (!File.Exists(partial) || new FileInfo(partial).Length == 0) throw new InvalidDataException("Installateur téléchargé vide.");
                ValidateDownloadedInstaller(partial, release);

                if (File.Exists(destination)) File.Delete(destination);
                File.Move(partial, destination);
                return destination;
            }
            finally
            {
                if (File.Exists(partial)) File.Delete(partial);
            }
        }

        public static Version NormalizeVersion(Version value)
        {
            if (value == null) throw new ArgumentNullException("value");
            return new Version(value.Major, Math.Max(0, value.Minor), Math.Max(0, value.Build));
        }

        private static string DownloadReleaseJson(string url)
        {
            using (TimeoutWebClient client = NewGitHubClient(8000)) return client.DownloadString(url);
        }

        private static TimeoutWebClient NewGitHubClient(int timeoutMilliseconds)
        {
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            TimeoutWebClient client = new TimeoutWebClient(timeoutMilliseconds);
            client.Headers[HttpRequestHeader.UserAgent] = "Guildrun-French-Installer/2.1.2";
            client.Headers[HttpRequestHeader.Accept] = "application/vnd.github+json";
            client.Headers["X-GitHub-Api-Version"] = "2022-11-28";
            return client;
        }

        private static Version ParseVersionTag(string tagName)
        {
            string value = (tagName ?? String.Empty).Trim();
            if (value.StartsWith("v", StringComparison.OrdinalIgnoreCase)) value = value.Substring(1);
            int suffix = value.IndexOfAny(new[] { '-', '+' });
            if (suffix >= 0) value = value.Substring(0, suffix);
            Version version;
            if (!Version.TryParse(value, out version) || version.Major < 0 || version.Minor < 0)
                throw new InvalidDataException("Version de Release GitHub invalide.");
            return NormalizeVersion(version);
        }

        private static string ParseDigest(string digest)
        {
            if (String.IsNullOrWhiteSpace(digest)) return null;
            Match match = Regex.Match(digest.Trim(), "^sha256:([0-9a-fA-F]{64})$");
            if (!match.Success) throw new InvalidDataException("Digest SHA-256 GitHub invalide.");
            return match.Groups[1].Value.ToUpperInvariant();
        }

        private static string ExtractSha256FromReleaseBody(string body, string assetName)
        {
            if (String.IsNullOrWhiteSpace(body)) return null;
            foreach (string line in body.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
            {
                if (line.IndexOf(assetName, StringComparison.OrdinalIgnoreCase) < 0) continue;
                Match match = Regex.Match(line, "(?i)(?<![0-9a-f])[0-9a-f]{64}(?![0-9a-f])");
                if (match.Success) return match.Value.ToUpperInvariant();
            }
            return null;
        }

        private static string GetString(Dictionary<string, object> values, string key)
        {
            string value = GetOptionalString(values, key);
            if (String.IsNullOrWhiteSpace(value)) throw new InvalidDataException("Champ GitHub manquant : " + key + ".");
            return value;
        }

        private static string GetOptionalString(Dictionary<string, object> values, string key)
        {
            object value;
            return values.TryGetValue(key, out value) && value != null ? Convert.ToString(value) : null;
        }
    }

    internal sealed class TimeoutWebClient : WebClient
    {
        private readonly int timeoutMilliseconds;

        public TimeoutWebClient(int timeoutMilliseconds)
        {
            this.timeoutMilliseconds = timeoutMilliseconds;
        }

        protected override WebRequest GetWebRequest(Uri address)
        {
            WebRequest request = base.GetWebRequest(address);
            request.Timeout = timeoutMilliseconds;
            HttpWebRequest http = request as HttpWebRequest;
            if (http != null) http.ReadWriteTimeout = timeoutMilliseconds;
            return request;
        }
    }
}
