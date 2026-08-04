using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace GuildrunFrenchInstallerV21
{
    internal sealed class InstallerForm : Form
    {
        private readonly TextBox gameRoot;
        private readonly TextBox log;
        private readonly Button installButton;
        private readonly Button restoreButton;

        public InstallerForm()
        {
            Text = "Guildrun Demo - Traduction francaise V2.1";
            ClientSize = new Size(720, 430);
            MinimumSize = new Size(650, 420);
            StartPosition = FormStartPosition.CenterScreen;
            Font = new Font("Segoe UI", 9F);

            var title = new Label { Left = 20, Top = 18, Width = 675, Height = 30, Text = "Guildrun Demo - Locale francais officiel", Font = new Font("Segoe UI Semibold", 16F) };
            var description = new Label {
                Left = 22, Top = 58, Width = 675, Height = 55,
                Text = "V2.1 cible exclusivement Guildrun 0.5.3 build 748. Elle sauvegarde French, Locales, catalog.bin et la preference Unity. Le bundle English n'est jamais ecrit."
            };
            var rootLabel = new Label { Left = 22, Top = 122, Width = 180, Height = 22, Text = "Dossier du jeu :" };
            gameRoot = new TextBox { Left = 22, Top = 145, Width = 570, Height = 25, Text = DetectGameRoot() };
            var browse = new Button { Left = 602, Top = 143, Width = 92, Height = 28, Text = "Parcourir..." };
            browse.Click += delegate { Browse(); };

            installButton = new Button { Left = 22, Top = 185, Width = 215, Height = 38, Text = "Installer la V2.1" };
            restoreButton = new Button { Left = 247, Top = 185, Width = 215, Height = 38, Text = "Restaurer la sauvegarde" };
            installButton.Click += delegate { Run(false); };
            restoreButton.Click += delegate { Run(true); };

            log = new TextBox {
                Left = 22, Top = 240, Width = 672, Height = 165, Multiline = true,
                ReadOnly = true, ScrollBars = ScrollBars.Vertical, BackColor = Color.White
            };
            Controls.AddRange(new Control[] { title, description, rootLabel, gameRoot, browse, installButton, restoreButton, log });
        }

        private static string DetectGameRoot()
        {
            string directory = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar);
            string[] candidates = {
                directory,
                Directory.GetParent(directory) == null ? directory : Directory.GetParent(directory).FullName,
                Directory.GetParent(directory) != null && Directory.GetParent(directory).Parent != null ? Directory.GetParent(directory).Parent.FullName : directory
            };
            foreach (string candidate in candidates)
                if (File.Exists(Path.Combine(candidate, "Guildrun.exe"))) return candidate;
            return directory;
        }

        private void Browse()
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Selectionnez le dossier contenant Guildrun.exe";
                dialog.SelectedPath = gameRoot.Text;
                if (dialog.ShowDialog(this) == DialogResult.OK) gameRoot.Text = dialog.SelectedPath;
            }
        }

        private void Run(bool restore)
        {
            string root = gameRoot.Text.Trim();
            if (!File.Exists(Path.Combine(root, "Guildrun.exe")))
            {
                MessageBox.Show(this, "Guildrun.exe est introuvable dans ce dossier.", "Dossier invalide", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            installButton.Enabled = restoreButton.Enabled = false;
            log.Clear();
            try
            {
                string output = ExecutePowerShell(root, restore);
                log.Text = output;
                MessageBox.Show(this, restore ? "Fichiers et preference Unity restaures et verifies." : "V2.1 installee et Locale fr selectionne.", "Operation terminee", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                log.Text += Environment.NewLine + ex.Message;
                MessageBox.Show(this, ex.Message, "Operation annulee", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                installButton.Enabled = restoreButton.Enabled = true;
            }
        }

        private static string ExecutePowerShell(string root, bool restore)
        {
            string temporaryRoot = Path.Combine(Path.GetTempPath(), "GuildrunFRV21-" + Guid.NewGuid().ToString("N"));
            string scripts = Path.Combine(temporaryRoot, "scripts");
            string payload = Path.Combine(temporaryRoot, "payload");
            Directory.CreateDirectory(scripts);
            Directory.CreateDirectory(payload);
            try
            {
                Extract("GuildrunFRV21.Common", Path.Combine(scripts, "GuildrunV21.Common.ps1"));
                Extract("GuildrunFRV21.Install", Path.Combine(scripts, "installer_traduction.ps1"));
                Extract("GuildrunFRV21.Restore", Path.Combine(scripts, "restaurer_sauvegarde.ps1"));
                Extract("GuildrunFRV21.French", Path.Combine(payload, "localization-string-tables-french(fr)_assets_all.bundle"));
                Extract("GuildrunFRV21.Locales", Path.Combine(payload, "localization-locales_assets_all.bundle"));
                Extract("GuildrunFRV21.Catalog", Path.Combine(payload, "catalog.bin"));

                string script = Path.Combine(scripts, restore ? "restaurer_sauvegarde.ps1" : "installer_traduction.ps1");
                var start = new ProcessStartInfo {
                    FileName = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell", "v1.0", "powershell.exe"),
                    Arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + script + "\" -GameRoot \"" + root.Replace("\"", "\"\"") + "\"",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    StandardOutputEncoding = Encoding.UTF8,
                    StandardErrorEncoding = Encoding.UTF8
                };
                using (Process process = Process.Start(start))
                {
                    string stdout = process.StandardOutput.ReadToEnd();
                    string stderr = process.StandardError.ReadToEnd();
                    process.WaitForExit();
                    if (process.ExitCode != 0) throw new InvalidOperationException((stderr + Environment.NewLine + stdout).Trim());
                    return stdout.Trim();
                }
            }
            finally
            {
                try { if (Directory.Exists(temporaryRoot)) Directory.Delete(temporaryRoot, true); } catch { }
            }
        }

        private static void Extract(string resourceName, string destination)
        {
            Assembly assembly = Assembly.GetExecutingAssembly();
            using (Stream input = assembly.GetManifestResourceStream(resourceName))
            {
                if (input == null) throw new InvalidOperationException("Ressource embarquee absente : " + resourceName);
                using (FileStream output = File.Create(destination)) input.CopyTo(output);
            }
        }
    }

    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new InstallerForm());
        }
    }
}
