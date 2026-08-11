using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

[assembly: AssemblyVersion("2.1.2.0")]
[assembly: AssemblyFileVersion("2.1.2.0")]

namespace GuildrunFrenchInstallerV21
{
    internal static class Theme
    {
        public static readonly Color WindowTop = Color.FromArgb(8, 17, 25);
        public static readonly Color WindowBottom = Color.FromArgb(12, 28, 40);
        public static readonly Color Header = Color.FromArgb(8, 16, 24);
        public static readonly Color Panel = Color.FromArgb(10, 28, 38);
        public static readonly Color PanelAlt = Color.FromArgb(13, 33, 45);
        public static readonly Color Border = Color.FromArgb(48, 76, 90);
        public static readonly Color BorderSoft = Color.FromArgb(33, 59, 72);
        public static readonly Color Text = Color.FromArgb(244, 247, 249);
        public static readonly Color Muted = Color.FromArgb(171, 184, 194);
        public static readonly Color Accent = Color.FromArgb(79, 205, 192);
        public static readonly Color AccentLight = Color.FromArgb(108, 226, 213);
        public static readonly Color AccentDark = Color.FromArgb(37, 143, 143);
        public static readonly Color Error = Color.FromArgb(239, 128, 128);

        public static GraphicsPath RoundedRectangle(Rectangle bounds, int radius)
        {
            int diameter = Math.Max(2, radius * 2);
            GraphicsPath path = new GraphicsPath();
            path.AddArc(bounds.Left, bounds.Top, diameter, diameter, 180, 90);
            path.AddArc(bounds.Right - diameter, bounds.Top, diameter, diameter, 270, 90);
            path.AddArc(bounds.Right - diameter, bounds.Bottom - diameter, diameter, diameter, 0, 90);
            path.AddArc(bounds.Left, bounds.Bottom - diameter, diameter, diameter, 90, 90);
            path.CloseFigure();
            return path;
        }
    }

    internal sealed class RoundedPanel : Panel
    {
        private Color fillColor;
        public Color FillColor
        {
            get { return fillColor; }
            set { fillColor = value; BackColor = value; Invalidate(); }
        }
        public Color BorderColor { get; set; }
        public int Radius { get; set; }

        public RoundedPanel()
        {
            FillColor = Theme.Panel;
            BorderColor = Theme.BorderSoft;
            Radius = 16;
            DoubleBuffered = true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            e.Graphics.Clear(Parent == null ? Theme.Panel : Parent.BackColor);
            Rectangle bounds = new Rectangle(0, 0, Width - 1, Height - 1);
            using (GraphicsPath path = Theme.RoundedRectangle(bounds, Radius))
            using (SolidBrush fill = new SolidBrush(FillColor))
            using (Pen border = new Pen(BorderColor))
            {
                e.Graphics.FillPath(fill, path);
                e.Graphics.DrawPath(border, path);
            }
            base.OnPaint(e);
        }
    }

    internal sealed class RoundedButton : Button
    {
        private bool hovered;
        private bool pressed;

        public Color FillColor { get; set; }
        public Color HoverColor { get; set; }
        public Color PressedColor { get; set; }
        public Color BorderColor { get; set; }
        public int Radius { get; set; }

        public RoundedButton()
        {
            FillColor = Theme.PanelAlt;
            HoverColor = Color.FromArgb(22, 46, 59);
            PressedColor = Color.FromArgb(16, 39, 51);
            BorderColor = Theme.Border;
            Radius = 12;
            FlatStyle = FlatStyle.Flat;
            FlatAppearance.BorderSize = 0;
            UseVisualStyleBackColor = false;
            BackColor = Color.Transparent;
            ForeColor = Theme.Text;
            Cursor = Cursors.Hand;
            TabStop = true;
        }

        protected override void OnMouseEnter(EventArgs e) { hovered = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { hovered = false; pressed = false; Invalidate(); base.OnMouseLeave(e); }
        protected override void OnMouseDown(MouseEventArgs e) { pressed = true; Invalidate(); base.OnMouseDown(e); }
        protected override void OnMouseUp(MouseEventArgs e) { pressed = false; Invalidate(); base.OnMouseUp(e); }
        protected override void OnEnabledChanged(EventArgs e) { Invalidate(); base.OnEnabledChanged(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            e.Graphics.Clear(Parent == null ? Theme.Panel : Parent.BackColor);
            Rectangle bounds = new Rectangle(0, pressed ? 1 : 0, Width - 1, Height - 2);
            Color fill = !Enabled ? Color.FromArgb(20, 42, 52) : pressed ? PressedColor : hovered ? HoverColor : FillColor;
            Color foreground = !Enabled ? Color.FromArgb(104, 124, 134) : ForeColor;

            using (GraphicsPath path = Theme.RoundedRectangle(bounds, Radius))
            using (SolidBrush brush = new SolidBrush(fill))
            using (Pen border = new Pen(Enabled ? BorderColor : Theme.BorderSoft))
            {
                e.Graphics.FillPath(brush, path);
                e.Graphics.DrawPath(border, path);
            }

            if (Focused && Enabled)
            {
                Rectangle focusBounds = Rectangle.Inflate(bounds, -3, -3);
                using (GraphicsPath focusPath = Theme.RoundedRectangle(focusBounds, Math.Max(4, Radius - 3)))
                using (Pen focusPen = new Pen(Color.FromArgb(150, Theme.AccentLight)) { DashStyle = DashStyle.Dot })
                    e.Graphics.DrawPath(focusPen, focusPath);
            }

            TextRenderer.DrawText(e.Graphics, Text, Font, bounds, foreground,
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
        }
    }

    internal sealed class AccentButton : Button
    {
        private bool hovered;
        private bool pressed;
        public int Radius { get; set; }

        public AccentButton()
        {
            Radius = 13;
            FlatStyle = FlatStyle.Flat;
            FlatAppearance.BorderSize = 0;
            UseVisualStyleBackColor = false;
            BackColor = Color.Transparent;
            ForeColor = Theme.Text;
            Cursor = Cursors.Hand;
        }

        protected override void OnMouseEnter(EventArgs e) { hovered = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { hovered = false; pressed = false; Invalidate(); base.OnMouseLeave(e); }
        protected override void OnMouseDown(MouseEventArgs e) { pressed = true; Invalidate(); base.OnMouseDown(e); }
        protected override void OnMouseUp(MouseEventArgs e) { pressed = false; Invalidate(); base.OnMouseUp(e); }
        protected override void OnEnabledChanged(EventArgs e) { Invalidate(); base.OnEnabledChanged(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            e.Graphics.Clear(Parent == null ? Theme.Panel : Parent.BackColor);
            Rectangle bounds = new Rectangle(0, pressed ? 1 : 0, Width - 1, Height - 2);
            Color left = !Enabled ? Color.FromArgb(42, 91, 94) : hovered ? Color.FromArgb(58, 180, 179) : Color.FromArgb(45, 155, 157);
            Color right = !Enabled ? Color.FromArgb(46, 98, 99) : hovered ? Theme.AccentLight : Color.FromArgb(77, 197, 187);

            using (GraphicsPath path = Theme.RoundedRectangle(bounds, Radius))
            using (LinearGradientBrush fill = new LinearGradientBrush(bounds, left, right, 0F))
            using (Pen border = new Pen(!Enabled ? Theme.BorderSoft : Color.FromArgb(125, 226, 216)))
            {
                e.Graphics.FillPath(fill, path);
                e.Graphics.DrawPath(border, path);
            }

            if (hovered && Enabled)
            {
                Rectangle glowBounds = Rectangle.Inflate(bounds, -2, -2);
                using (GraphicsPath glowPath = Theme.RoundedRectangle(glowBounds, Math.Max(4, Radius - 2)))
                using (Pen glow = new Pen(Color.FromArgb(70, 229, 220), 1F))
                    e.Graphics.DrawPath(glow, glowPath);
            }

            Color textColor = Enabled ? Theme.Text : Color.FromArgb(150, 177, 180);
            TextRenderer.DrawText(e.Graphics, Text, Font, bounds, textColor,
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
        }
    }

    internal enum FeatureIconKind { Globe, Shield, Restore, Check }

    internal sealed class StatusCheck : Control
    {
        public StatusCheck()
        {
            SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            BackColor = Color.Transparent;
            DoubleBuffered = true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            float diameter = Math.Max(4F, Math.Min(Width, Height) - 3F);
            float left = (Width - diameter) / 2F;
            float top = (Height - diameter) / 2F;
            RectangleF circle = new RectangleF(left, top, diameter, diameter);
            using (SolidBrush fill = new SolidBrush(Theme.Accent)) e.Graphics.FillEllipse(fill, circle);
            using (Pen check = new Pen(Color.FromArgb(8, 45, 48), Math.Max(1.8F, diameter * 0.075F)))
            {
                check.StartCap = LineCap.Round;
                check.EndCap = LineCap.Round;
                e.Graphics.DrawLines(check, new[] {
                    new PointF(left + diameter * 0.29F, top + diameter * 0.51F),
                    new PointF(left + diameter * 0.46F, top + diameter * 0.67F),
                    new PointF(left + diameter * 0.74F, top + diameter * 0.34F)
                });
            }
        }
    }

    internal sealed class FolderGlyph : Control
    {
        public FolderGlyph()
        {
            SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            BackColor = Color.Transparent;
            DoubleBuffered = true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            float cx = Width / 2F;
            float cy = Height / 2F;
            float scale = Math.Min(Width, Height) / 34F;
            using (GraphicsPath folder = new GraphicsPath())
            {
                folder.AddLines(new[] {
                    new PointF(cx - 12F * scale, cy - 8F * scale),
                    new PointF(cx - 5F * scale, cy - 8F * scale),
                    new PointF(cx - 2F * scale, cy - 5F * scale),
                    new PointF(cx + 12F * scale, cy - 5F * scale),
                    new PointF(cx + 12F * scale, cy + 9F * scale),
                    new PointF(cx - 12F * scale, cy + 9F * scale)
                });
                folder.CloseFigure();
                using (Pen pen = new Pen(Theme.Muted, Math.Max(1.5F, 1.8F * scale)) { LineJoin = LineJoin.Round })
                    e.Graphics.DrawPath(pen, folder);
            }
        }
    }

    internal sealed class IconTile : Control
    {
        public FeatureIconKind Kind { get; set; }

        public IconTile()
        {
            SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            Size = new Size(46, 46);
            BackColor = Color.Transparent;
            DoubleBuffered = true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            Rectangle card = new Rectangle(0, 0, Width - 1, Height - 1);
            using (GraphicsPath path = Theme.RoundedRectangle(card, 10))
            using (LinearGradientBrush fill = new LinearGradientBrush(card, Color.FromArgb(17, 45, 53), Color.FromArgb(10, 31, 41), 45F))
            using (Pen border = new Pen(Color.FromArgb(28, 62, 71)))
            {
                g.FillPath(fill, path);
                g.DrawPath(border, path);
            }

            float scale = Math.Min(Width, Height) / 46F;
            using (Pen pen = new Pen(Theme.Accent, Math.Max(1.6F, 2F * scale)))
            {
                pen.StartCap = LineCap.Round;
                pen.EndCap = LineCap.Round;
                if (Kind == FeatureIconKind.Globe) DrawGlobe(g, pen);
                else if (Kind == FeatureIconKind.Shield) DrawShield(g, pen, false);
                else if (Kind == FeatureIconKind.Restore) DrawRestore(g, pen);
                else DrawCheck(g, pen);
            }
        }

        private void DrawGlobe(Graphics g, Pen pen)
        {
            float scale = Math.Min(Width, Height) / 46F;
            float cx = Width / 2F;
            float cy = Height / 2F;
            RectangleF r = new RectangleF(cx - 11.5F * scale, cy - 12F * scale, 23F * scale, 24F * scale);
            g.DrawEllipse(pen, r);
            RectangleF meridian = new RectangleF(cx - 5.5F * scale, cy - 12F * scale, 11F * scale, 24F * scale);
            g.DrawArc(pen, meridian, 90, 180);
            g.DrawArc(pen, meridian, 270, 180);
            g.DrawLine(pen, cx - 11.5F * scale, cy, cx + 11.5F * scale, cy);
            g.DrawArc(pen, new RectangleF(cx - 11.5F * scale, cy - 6F * scale, 23F * scale, 12F * scale), 180, 180);
        }

        private void DrawShield(Graphics g, Pen pen, bool small)
        {
            float scale = Math.Min(Width, Height) / 46F;
            float cx = Width / 2F;
            float cy = Height / 2F;
            PointF[] points = {
                new PointF(cx, cy - 13.5F * scale), new PointF(cx + 11F * scale, cy - 8.5F * scale),
                new PointF(cx + 10F * scale, cy + 5.5F * scale), new PointF(cx, cy + 13.5F * scale),
                new PointF(cx - 10F * scale, cy + 5.5F * scale), new PointF(cx - 11F * scale, cy - 8.5F * scale)
            };
            g.DrawPolygon(pen, points);
            g.DrawLines(pen, new[] {
                new PointF(cx - 5F * scale, cy + 0.5F * scale),
                new PointF(cx - 1F * scale, cy + 4.5F * scale),
                new PointF(cx + 6F * scale, cy - 3.5F * scale)
            });
        }

        private void DrawRestore(Graphics g, Pen pen)
        {
            float scale = Math.Min(Width, Height) / 46F;
            float cx = Width / 2F;
            float cy = Height / 2F;
            g.DrawArc(pen, new RectangleF(cx - 12F * scale, cy - 12F * scale, 24F * scale, 24F * scale), -70, 285);
            g.DrawLines(pen, new[] {
                new PointF(cx - 12.5F * scale, cy - 8F * scale),
                new PointF(cx - 12.5F * scale, cy),
                new PointF(cx - 5.5F * scale, cy)
            });
        }

        private void DrawCheck(Graphics g, Pen pen)
        {
            float scale = Math.Min(Width, Height) / 46F;
            float cx = Width / 2F;
            float cy = Height / 2F;
            g.DrawEllipse(pen, new RectangleF(cx - 11F * scale, cy - 11F * scale, 22F * scale, 22F * scale));
            g.DrawLines(pen, new[] {
                new PointF(cx - 6F * scale, cy),
                new PointF(cx - 2F * scale, cy + 4F * scale),
                new PointF(cx + 6F * scale, cy - 5F * scale)
            });
        }
    }

    internal sealed class BrandMark : Control
    {
        public bool ShowCard { get; set; }

        public BrandMark()
        {
            SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            BackColor = Color.Transparent;
            DoubleBuffered = true;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            Rectangle canvas = ClientRectangle;

            if (ShowCard)
            {
                Rectangle card = new Rectangle(0, 0, Width - 1, Height - 1);
                using (GraphicsPath path = Theme.RoundedRectangle(card, 22))
                using (LinearGradientBrush fill = new LinearGradientBrush(card, Color.FromArgb(11, 34, 44), Color.FromArgb(8, 25, 34), 135F))
                using (Pen border = new Pen(Color.FromArgb(43, 83, 94)))
                {
                    g.FillPath(fill, path);
                    g.DrawPath(border, path);
                }
            }

            int size = ShowCard ? Math.Min(96, Width / 2) : Math.Min(28, Width - 6);
            int cx = Width / 2;
            int cy = Height / 2;
            Point[] diamond = {
                new Point(cx, cy - size / 2),
                new Point(cx + size / 2, cy),
                new Point(cx, cy + size / 2),
                new Point(cx - size / 2, cy)
            };

            Rectangle gradientBounds = new Rectangle(cx - size / 2, cy - size / 2, size, size);
            using (LinearGradientBrush gradient = new LinearGradientBrush(gradientBounds, Theme.AccentLight, Theme.AccentDark, 90F))
            using (Pen pen = new Pen(gradient, ShowCard ? 17F : 6F))
            {
                pen.LineJoin = LineJoin.Round;
                pen.StartCap = LineCap.Round;
                pen.EndCap = LineCap.Round;
                g.DrawPolygon(pen, diamond);
            }
        }
    }

    internal sealed class InstallerForm : Form
    {
        private const int WindowRadius = 21;
        private readonly TextBox gameRoot;
        private readonly TextBox log;
        private readonly AccentButton installButton;
        private readonly RoundedButton restoreButton;
        private readonly RoundedButton browseButton;
        private readonly RoundedPanel actionPanel;
        private readonly RoundedPanel pathPanel;
        private readonly RoundedPanel readyBadge;
        private readonly Label steamStatus;
        private readonly Label installerUpdateStatus;
        private readonly Label footerStatus;
        private readonly RoundedButton updateButton;
        private readonly Button detailsButton;
        private readonly Panel header;
        private readonly Panel footer;
        private InstallerReleaseInfo availableRelease;
        private bool updateCheckStarted;
        private bool installerUpdateInProgress;
        private bool patchOperationInProgress;

        public InstallerForm(string initialGameRoot)
        {
            Text = "Guildrun - Français V2.1.2";
            ClientSize = new Size(1080, 700);
            MinimumSize = new Size(980, 700);
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.None;
            BackColor = Theme.WindowTop;
            ForeColor = Theme.Text;
            Font = new Font("Segoe UI", 10F);
            AutoScaleDimensions = new SizeF(96F, 96F);
            AutoScaleMode = AutoScaleMode.Dpi;
            DoubleBuffered = true;
            KeyPreview = true;

            header = new Panel { Left = 1, Top = 1, Height = 78, BackColor = Theme.Header, Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right };
            header.Width = ClientSize.Width - 2;
            header.MouseDown += DragWindow;

            BrandMark smallMark = new BrandMark { Left = 30, Top = 21, Width = 34, Height = 34, ShowCard = false };
            Label brand = CreateLabel("Guildrun", 66, 25, 100, 28, Theme.Text, new Font("Segoe UI Semibold", 14F));
            Label language = CreateLabel("Français", 173, 27, 105, 25, Color.FromArgb(114, 165, 169), new Font("Segoe UI", 13F));

            installerUpdateStatus = CreateLabel("Vérification de l’installateur…", ClientSize.Width - 530, 24, 272, 30, Theme.Muted, new Font("Segoe UI", 9.5F));
            installerUpdateStatus.TextAlign = ContentAlignment.MiddleRight;
            installerUpdateStatus.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            updateButton = new RoundedButton {
                Left = ClientSize.Width - 243, Top = 21, Width = 122, Height = 36,
                Text = "Mettre à jour", Font = new Font("Segoe UI Semibold", 9.5F), Radius = 9,
                Anchor = AnchorStyles.Top | AnchorStyles.Right, Visible = false
            };
            updateButton.Click += delegate { BeginInstallerUpdate(); };

            Button minimize = CreateWindowButton("—", 62);
            minimize.Click += delegate { WindowState = FormWindowState.Minimized; };
            Button close = CreateWindowButton("×", 17);
            close.Font = new Font("Segoe UI Light", 21F);
            close.Click += delegate { Close(); };
            header.Controls.AddRange(new Control[] { smallMark, brand, language, installerUpdateStatus, updateButton, minimize, close });

            Panel headerLine = new Panel { Left = 1, Top = 78, Height = 1, BackColor = Theme.BorderSoft, Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right };
            headerLine.Width = ClientSize.Width - 2;

            BrandMark heroMark = new BrandMark { Left = 48, Top = 122, Width = 182, Height = 182, ShowCard = true };
            Label heroTitle = CreateLabel("Guildrun\nen français", 270, 136, 340, 105, Theme.Text, new Font("Segoe UI Semibold", 30F));
            heroTitle.AutoEllipsis = false;
            Label heroSubtitle = CreateLabel("Installation locale et restauration incluse.", 272, 254, 390, 28, Theme.Muted, new Font("Segoe UI", 12F));

            AddFeature(48, 370, FeatureIconKind.Globe, "100% local", "Aucun fichier envoyé. Tout reste sur votre PC.");
            AddFeature(48, 452, FeatureIconKind.Shield, "Sûr & vérifié", "3 919 textes contrôlés et validés.");
            AddFeature(48, 534, FeatureIconKind.Restore, "Réversible", "Retire la traduction et restaure l’état précédent.");

            actionPanel = new RoundedPanel {
                Left = 500, Top = 318, Width = 630, Height = 285,
                FillColor = Color.FromArgb(10, 29, 39), BorderColor = Theme.Border, Radius = 16,
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            Label rootLabel = CreateLabel("Emplacement du jeu", 28, 26, 220, 26, Theme.Text, new Font("Segoe UI Semibold", 11F));
            steamStatus = CreateLabel("Jeu détecté   ●", 433, 28, 165, 24, Theme.Accent, new Font("Segoe UI", 9.5F));
            steamStatus.TextAlign = ContentAlignment.MiddleRight;
            steamStatus.Anchor = AnchorStyles.Top | AnchorStyles.Right;

            pathPanel = new RoundedPanel {
                Left = 28, Top = 67, Width = 574, Height = 48,
                FillColor = Color.FromArgb(8, 23, 32), BorderColor = Theme.Border, Radius = 11,
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            FolderGlyph folderIcon = new FolderGlyph { Left = 14, Top = 6, Width = 34, Height = 34 };
            gameRoot = new TextBox {
                Left = 50, Top = 14, Width = 408, Height = 24,
                Text = String.IsNullOrWhiteSpace(initialGameRoot) ? DetectGameRoot() : initialGameRoot, BorderStyle = BorderStyle.None,
                BackColor = Color.FromArgb(8, 23, 32), ForeColor = Theme.Muted,
                Font = new Font("Segoe UI", 9.5F), Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            gameRoot.TextChanged += delegate { UpdateDetection(); };
            browseButton = new RoundedButton {
                Left = 463, Top = 4, Width = 106, Height = 40, Text = "Parcourir",
                Font = new Font("Segoe UI Semibold", 9.5F), Radius = 9,
                Anchor = AnchorStyles.Top | AnchorStyles.Right
            };
            browseButton.Click += delegate { Browse(); };
            pathPanel.Controls.AddRange(new Control[] { folderIcon, gameRoot, browseButton });

            installButton = new AccentButton {
                Left = 28, Top = 136, Width = 574, Height = 59,
                Text = "↓    Installer le français", Font = new Font("Segoe UI Semibold", 13F),
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            restoreButton = new RoundedButton {
                Left = 28, Top = 211, Width = 574, Height = 55,
                Text = "Restaurer", Font = new Font("Segoe UI", 12F), Radius = 12,
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            installButton.Click += delegate { Run(false); };
            restoreButton.Click += delegate { Run(true); };
            actionPanel.Controls.AddRange(new Control[] { rootLabel, steamStatus, pathPanel, installButton, restoreButton });

            footer = new Panel { Left = 1, Height = 86, BackColor = Theme.Header, Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Bottom };
            footer.Width = ClientSize.Width - 2;
            footer.Top = ClientSize.Height - footer.Height - 1;
            Panel footerLine = new Panel { Left = 0, Top = 0, Height = 1, BackColor = Theme.BorderSoft, Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right };
            footerLine.Width = footer.Width;
            IconTile footerShield = new IconTile { Left = 38, Top = 23, Width = 40, Height = 40, Kind = FeatureIconKind.Shield };
            footerStatus = CreateLabel("Version vérifiée   •   Installer français", 88, 29, 350, 28, Theme.Muted, new Font("Segoe UI", 10.5F));
            footerStatus.UseMnemonic = false;

            detailsButton = new Button {
                Left = 442, Top = 25, Width = 105, Height = 32, Text = "Voir le journal",
                FlatStyle = FlatStyle.Flat, BackColor = Color.Transparent, ForeColor = Theme.Accent,
                Font = new Font("Segoe UI", 9F), Cursor = Cursors.Hand, Visible = false
            };
            detailsButton.FlatAppearance.BorderSize = 0;
            detailsButton.FlatAppearance.MouseOverBackColor = Color.FromArgb(17, 38, 49);
            detailsButton.Click += delegate { ShowLog(); };

            readyBadge = new RoundedPanel {
                Width = 196, Height = 50, Top = 18,
                Left = footer.Width - 224, FillColor = Color.FromArgb(11, 27, 36),
                BorderColor = Theme.BorderSoft, Radius = 11, Anchor = AnchorStyles.Top | AnchorStyles.Right
            };
            StatusCheck readyIcon = new StatusCheck { Left = 15, Top = 10, Width = 29, Height = 29 };
            Label readyText = CreateLabel("3 919 textes prêts", 52, 12, 132, 26, Theme.Text, new Font("Segoe UI", 10F));
            readyBadge.Controls.AddRange(new Control[] { readyIcon, readyText });
            footer.Controls.AddRange(new Control[] { footerLine, footerShield, footerStatus, detailsButton, readyBadge });

            log = new TextBox {
                Visible = false, Multiline = true, ReadOnly = true, ScrollBars = ScrollBars.Vertical,
                BackColor = Theme.Panel, ForeColor = Theme.Text, Font = new Font("Consolas", 9F)
            };

            Controls.AddRange(new Control[] {
                header, headerLine, heroMark, heroTitle, heroSubtitle, actionPanel, footer, log
            });

            Resize += delegate { LayoutWindow(); UpdateWindowRegion(); };
            Shown += delegate { UpdateDetection(); BeginUpdateCheck(); };
            LayoutWindow();
            UpdateWindowRegion();
        }

        protected override CreateParams CreateParams
        {
            get
            {
                const int CsDropShadow = 0x00020000;
                CreateParams cp = base.CreateParams;
                cp.ClassStyle |= CsDropShadow;
                return cp;
            }
        }

        protected override void OnPaintBackground(PaintEventArgs e)
        {
            Rectangle bounds = ClientRectangle;
            using (LinearGradientBrush background = new LinearGradientBrush(bounds, Theme.WindowTop, Theme.WindowBottom, 105F))
                e.Graphics.FillRectangle(background, bounds);

            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            DrawGlow(e.Graphics, new Point(165, 260), 360, Color.FromArgb(23, 41, 135, 128));
            DrawGlow(e.Graphics, new Point(ClientSize.Width - 130, 430), 420, Color.FromArgb(19, 40, 91, 119));
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            Rectangle borderBounds = new Rectangle(0, 0, Width - 1, Height - 1);
            using (GraphicsPath path = Theme.RoundedRectangle(borderBounds, WindowRadius))
            using (Pen border = new Pen(Color.FromArgb(58, 82, 95)))
                e.Graphics.DrawPath(border, path);
        }

        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            if (keyData == Keys.Escape) { Close(); return true; }
            return base.ProcessCmdKey(ref msg, keyData);
        }

        private static Label CreateLabel(string text, int left, int top, int width, int height, Color color, Font font)
        {
            return new Label {
                Text = text, Left = left, Top = top, Width = width, Height = height,
                ForeColor = color, BackColor = Color.Transparent, Font = font,
                TextAlign = ContentAlignment.MiddleLeft
            };
        }

        private Button CreateWindowButton(string text, int right)
        {
            Button button = new Button {
                Text = text, Width = 42, Height = 42, Top = 18, Left = ClientSize.Width - right - 42,
                Anchor = AnchorStyles.Top | AnchorStyles.Right, FlatStyle = FlatStyle.Flat,
                BackColor = Color.Transparent, ForeColor = Theme.Muted,
                Font = new Font("Segoe UI", 15F), Cursor = Cursors.Hand, TabStop = false
            };
            button.FlatAppearance.BorderSize = 0;
            button.FlatAppearance.MouseOverBackColor = Color.FromArgb(24, 42, 52);
            button.FlatAppearance.MouseDownBackColor = Color.FromArgb(32, 51, 61);
            return button;
        }

        private void AddFeature(int left, int top, FeatureIconKind kind, string title, string description)
        {
            IconTile icon = new IconTile { Left = left, Top = top + 4, Kind = kind };
            Label titleLabel = CreateLabel(title, left + 66, top + 1, 285, 24, Theme.Text, new Font("Segoe UI Semibold", 10.5F));
            Label descriptionLabel = CreateLabel(description, left + 66, top + 28, 315, 25, Theme.Muted, new Font("Segoe UI", 9.5F));
            Controls.AddRange(new Control[] { icon, titleLabel, descriptionLabel });
        }

        private void LayoutWindow()
        {
            int actionLeft = Math.Max(435, ClientSize.Width / 2 - 90);
            actionPanel.Left = actionLeft;
            actionPanel.Width = ClientSize.Width - actionLeft - 50;
            footer.Top = ClientSize.Height - footer.Height - 1;
            footer.Width = ClientSize.Width - 2;
            readyBadge.Left = footer.Width - readyBadge.Width - 28;
        }

        private void UpdateWindowRegion()
        {
            using (GraphicsPath path = Theme.RoundedRectangle(new Rectangle(0, 0, Width, Height), WindowRadius))
                Region = new Region(path);
            Invalidate();
        }

        private static void DrawGlow(Graphics graphics, Point center, int diameter, Color color)
        {
            Rectangle area = new Rectangle(center.X - diameter / 2, center.Y - diameter / 2, diameter, diameter);
            using (GraphicsPath path = new GraphicsPath())
            {
                path.AddEllipse(area);
                using (PathGradientBrush glow = new PathGradientBrush(path))
                {
                    glow.CenterColor = color;
                    glow.SurroundColors = new[] { Color.FromArgb(0, color.R, color.G, color.B) };
                    graphics.FillEllipse(glow, area);
                }
            }
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

        private void UpdateDetection()
        {
            bool detected = File.Exists(Path.Combine(gameRoot.Text.Trim(), "Guildrun.exe"));
            steamStatus.Text = detected ? "Jeu détecté   ●" : "Dossier à vérifier   ●";
            steamStatus.ForeColor = detected ? Theme.Accent : Theme.Error;
        }

        private void Browse()
        {
            using (FolderBrowserDialog dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Sélectionnez le dossier contenant Guildrun.exe";
                dialog.SelectedPath = gameRoot.Text;
                if (dialog.ShowDialog(this) == DialogResult.OK) gameRoot.Text = dialog.SelectedPath;
            }
        }

        private void BeginUpdateCheck()
        {
            if (updateCheckStarted) return;
            updateCheckStarted = true;
            installerUpdateStatus.Text = "Vérification de l’installateur…";
            installerUpdateStatus.ForeColor = Theme.Muted;
            Version currentVersion = InstallerUpdateService.NormalizeVersion(Assembly.GetExecutingAssembly().GetName().Version);
            Task.Factory.StartNew(delegate { return InstallerUpdateService.CheckLatestRelease(currentVersion); })
                .ContinueWith(delegate(Task<InstallerUpdateCheckResult> task)
                {
                    if (IsDisposed || Disposing) return;
                    try
                    {
                        BeginInvoke((Action)delegate
                        {
                            if (task.IsFaulted)
                                ApplyUpdateCheck(new InstallerUpdateCheckResult { State = InstallerUpdateState.Unavailable, ErrorMessage = task.Exception.GetBaseException().Message });
                            else ApplyUpdateCheck(task.Result);
                        });
                    }
                    catch (InvalidOperationException) { }
                });
        }

        private void ApplyUpdateCheck(InstallerUpdateCheckResult result)
        {
            availableRelease = null;
            updateButton.Visible = false;
            if (result != null && result.State == InstallerUpdateState.Available && result.Release != null)
            {
                availableRelease = result.Release;
                installerUpdateStatus.Text = "Mise à jour disponible — " + result.Release.TagName;
                installerUpdateStatus.ForeColor = Theme.AccentLight;
                updateButton.Visible = true;
                updateButton.Enabled = !patchOperationInProgress && !installerUpdateInProgress;
            }
            else if (result != null && result.State == InstallerUpdateState.UpToDate)
            {
                installerUpdateStatus.Text = "Installateur à jour ✓";
                installerUpdateStatus.ForeColor = Theme.Accent;
            }
            else
            {
                installerUpdateStatus.Text = "Mise à jour non vérifiée";
                installerUpdateStatus.ForeColor = Theme.Muted;
            }
        }

        private void BeginInstallerUpdate()
        {
            if (availableRelease == null || installerUpdateInProgress || patchOperationInProgress) return;
            InstallerReleaseInfo release = availableRelease;
            installerUpdateInProgress = true;
            installButton.Enabled = restoreButton.Enabled = browseButton.Enabled = updateButton.Enabled = false;
            UseWaitCursor = true;
            installerUpdateStatus.Text = "Téléchargement de " + release.TagName + "…";
            installerUpdateStatus.ForeColor = Theme.Accent;

            Task.Factory.StartNew(delegate { return InstallerUpdateService.DownloadAndPrepareInstaller(release); })
                .ContinueWith(delegate(Task<string> task)
                {
                    if (IsDisposed || Disposing) return;
                    try
                    {
                        BeginInvoke((Action)delegate
                        {
                            try
                            {
                                if (task.IsFaulted) throw task.Exception.GetBaseException();
                                string encodedRoot = Convert.ToBase64String(Encoding.UTF8.GetBytes(gameRoot.Text.Trim()));
                                Process.Start(new ProcessStartInfo {
                                    FileName = task.Result,
                                    Arguments = "--game-root-base64 " + encodedRoot,
                                    UseShellExecute = true
                                });
                                Close();
                            }
                            catch (Exception ex)
                            {
                                installerUpdateInProgress = false;
                                UseWaitCursor = false;
                                installButton.Enabled = restoreButton.Enabled = browseButton.Enabled = true;
                                updateButton.Enabled = true;
                                installerUpdateStatus.Text = "Mise à jour disponible — " + release.TagName;
                                installerUpdateStatus.ForeColor = Theme.AccentLight;
                                MessageBox.Show(this, "La mise à jour de l’installateur n’a pas abouti.\n\n" + ex.Message + "\n\nL’installation du patch français reste disponible.", "Mise à jour non installée", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            }
                        });
                    }
                    catch (InvalidOperationException) { }
                });
        }

        private void Run(bool restore)
        {
            string root = gameRoot.Text.Trim();
            if (!File.Exists(Path.Combine(root, "Guildrun.exe")))
            {
                footerStatus.Text = "Dossier du jeu invalide";
                footerStatus.ForeColor = Theme.Error;
                MessageBox.Show(this, "Guildrun.exe est introuvable dans ce dossier.", "Dossier invalide", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            patchOperationInProgress = true;
            installButton.Enabled = restoreButton.Enabled = browseButton.Enabled = false;
            if (updateButton.Visible) updateButton.Enabled = false;
            UseWaitCursor = true;
            log.Clear();
            footerStatus.ForeColor = Theme.Accent;
            footerStatus.Text = restore ? "Restauration de l’état précédent…" : "Installation du français…";
            Refresh();

            try
            {
                string output = ExecutePowerShell(root, restore);
                log.Text = output;
                detailsButton.Visible = !String.IsNullOrWhiteSpace(output);
                footerStatus.Text = restore ? "État précédent restauré et vérifié" : "Français installé et vérifié";
                footerStatus.ForeColor = Theme.Accent;
                MessageBox.Show(this,
                    restore ? "L’état précédent du jeu a été restauré et les modifications de la traduction ont été retirées." : "Traduction française installée et langue sélectionnée.",
                    "Opération terminée", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                log.Text += Environment.NewLine + ex.Message;
                detailsButton.Visible = true;
                footerStatus.Text = "L’opération n’a pas abouti";
                footerStatus.ForeColor = Theme.Error;
                MessageBox.Show(this, ex.Message, "Opération annulée", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                UseWaitCursor = false;
                patchOperationInProgress = false;
                installButton.Enabled = restoreButton.Enabled = browseButton.Enabled = true;
                if (updateButton.Visible && !installerUpdateInProgress) updateButton.Enabled = true;
            }
        }

        private void ShowLog()
        {
            using (Form dialog = new Form())
            {
                dialog.Text = "Journal de l’opération";
                dialog.StartPosition = FormStartPosition.CenterParent;
                dialog.Size = new Size(760, 430);
                dialog.MinimumSize = new Size(620, 320);
                dialog.BackColor = Theme.WindowBottom;
                dialog.ForeColor = Theme.Text;
                TextBox output = new TextBox {
                    Dock = DockStyle.Fill, Multiline = true, ReadOnly = true,
                    ScrollBars = ScrollBars.Both, WordWrap = false,
                    Text = log.Text, BackColor = Color.FromArgb(8, 22, 30),
                    ForeColor = Theme.Text, BorderStyle = BorderStyle.FixedSingle,
                    Font = new Font("Consolas", 9.5F)
                };
                dialog.Padding = new Padding(14);
                dialog.Controls.Add(output);
                dialog.ShowDialog(this);
            }
        }

        private static string ExecutePowerShell(string root, bool restore)
        {
            string temporaryRoot = Path.Combine(Path.GetTempPath(), "GuildrunFRV212-" + Guid.NewGuid().ToString("N"));
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
                Extract("GuildrunFRV21.CatalogCurrent", Path.Combine(payload, "catalog.bin"));
                Extract("GuildrunFRV21.CatalogLegacy", Path.Combine(payload, "catalog-24551494.bin"));

                string script = Path.Combine(scripts, restore ? "restaurer_sauvegarde.ps1" : "installer_traduction.ps1");
                ProcessStartInfo start = new ProcessStartInfo {
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
                if (input == null) throw new InvalidOperationException("Ressource embarquée absente : " + resourceName);
                using (FileStream output = File.Create(destination)) input.CopyTo(output);
            }
        }

        [DllImport("user32.dll")]
        private static extern bool ReleaseCapture();

        [DllImport("user32.dll")]
        private static extern IntPtr SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);

        private void DragWindow(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left) return;
            ReleaseCapture();
            SendMessage(Handle, 0xA1, 0x2, 0);
        }
    }

    internal static class Program
    {
        [STAThread]
        private static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new InstallerForm(ReadInitialGameRoot(args)));
        }

        private static string ReadInitialGameRoot(string[] args)
        {
            if (args == null) return null;
            for (int index = 0; index + 1 < args.Length; index++)
            {
                if (!args[index].Equals("--game-root-base64", StringComparison.OrdinalIgnoreCase)) continue;
                try { return Encoding.UTF8.GetString(Convert.FromBase64String(args[index + 1])); }
                catch (FormatException) { return null; }
            }
            return null;
        }
    }
}
