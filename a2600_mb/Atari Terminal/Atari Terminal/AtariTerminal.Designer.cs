namespace AtariFPGATerminal
{
  partial class frmTerminal
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
      {
        components.Dispose();
      }
      base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmTerminal));
        this.rtfTerminal = new System.Windows.Forms.RichTextBox();
        this.cmbPortName = new System.Windows.Forms.ComboBox();
        this.cmbBaudRate = new System.Windows.Forms.ComboBox();
        this.lblComPort = new System.Windows.Forms.Label();
        this.lblBaudRate = new System.Windows.Forms.Label();
        this.label1 = new System.Windows.Forms.Label();
        this.cmbParity = new System.Windows.Forms.ComboBox();
        this.lblDataBits = new System.Windows.Forms.Label();
        this.cmbDataBits = new System.Windows.Forms.ComboBox();
        this.lblStopBits = new System.Windows.Forms.Label();
        this.cmbStopBits = new System.Windows.Forms.ComboBox();
        this.btnOpenPort = new System.Windows.Forms.Button();
        this.gbPortSettings = new System.Windows.Forms.GroupBox();
        this.btnGame_Reset = new System.Windows.Forms.Button();
        this.btnGame_Select = new System.Windows.Forms.Button();
        this.LeftDifficultyBox = new System.Windows.Forms.GroupBox();
        this.NoviceLeft = new System.Windows.Forms.RadioButton();
        this.ExpertLeft = new System.Windows.Forms.RadioButton();
        this.RightDifficultyBox = new System.Windows.Forms.GroupBox();
        this.NoviceRight = new System.Windows.Forms.RadioButton();
        this.ExpertRight = new System.Windows.Forms.RadioButton();
        this.grpColBW = new System.Windows.Forms.GroupBox();
        this.rdoBW = new System.Windows.Forms.RadioButton();
        this.rdoColor = new System.Windows.Forms.RadioButton();
        this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
        this.btnSelROM = new System.Windows.Forms.Button();
        this.richTextBox1 = new System.Windows.Forms.RichTextBox();
        this.btnSendROM = new System.Windows.Forms.Button();
        this.gbPortSettings.SuspendLayout();
        this.LeftDifficultyBox.SuspendLayout();
        this.RightDifficultyBox.SuspendLayout();
        this.grpColBW.SuspendLayout();
        this.SuspendLayout();
        // 
        // rtfTerminal
        // 
        this.rtfTerminal.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.rtfTerminal.Location = new System.Drawing.Point(12, 12);
        this.rtfTerminal.Name = "rtfTerminal";
        this.rtfTerminal.Size = new System.Drawing.Size(529, 292);
        this.rtfTerminal.TabIndex = 0;
        this.rtfTerminal.Text = "";
        // 
        // cmbPortName
        // 
        this.cmbPortName.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        this.cmbPortName.FormattingEnabled = true;
        this.cmbPortName.Items.AddRange(new object[] {
            "COM1",
            "COM2",
            "COM3",
            "COM4",
            "COM5",
            "COM6"});
        this.cmbPortName.Location = new System.Drawing.Point(13, 35);
        this.cmbPortName.Name = "cmbPortName";
        this.cmbPortName.Size = new System.Drawing.Size(67, 21);
        this.cmbPortName.TabIndex = 1;
        // 
        // cmbBaudRate
        // 
        this.cmbBaudRate.FormattingEnabled = true;
        this.cmbBaudRate.Items.AddRange(new object[] {
            "300",
            "600",
            "1200",
            "2400",
            "4800",
            "9600",
            "14400",
            "28800",
            "36000",
            "115000"});
        this.cmbBaudRate.Location = new System.Drawing.Point(86, 35);
        this.cmbBaudRate.Name = "cmbBaudRate";
        this.cmbBaudRate.Size = new System.Drawing.Size(69, 21);
        this.cmbBaudRate.TabIndex = 3;
        this.cmbBaudRate.Validating += new System.ComponentModel.CancelEventHandler(this.cmbBaudRate_Validating);
        // 
        // lblComPort
        // 
        this.lblComPort.AutoSize = true;
        this.lblComPort.Location = new System.Drawing.Point(12, 19);
        this.lblComPort.Name = "lblComPort";
        this.lblComPort.Size = new System.Drawing.Size(56, 13);
        this.lblComPort.TabIndex = 0;
        this.lblComPort.Text = "COM Port:";
        // 
        // lblBaudRate
        // 
        this.lblBaudRate.AutoSize = true;
        this.lblBaudRate.Location = new System.Drawing.Point(85, 19);
        this.lblBaudRate.Name = "lblBaudRate";
        this.lblBaudRate.Size = new System.Drawing.Size(61, 13);
        this.lblBaudRate.TabIndex = 2;
        this.lblBaudRate.Text = "Baud Rate:";
        // 
        // label1
        // 
        this.label1.AutoSize = true;
        this.label1.Location = new System.Drawing.Point(163, 19);
        this.label1.Name = "label1";
        this.label1.Size = new System.Drawing.Size(36, 13);
        this.label1.TabIndex = 4;
        this.label1.Text = "Parity:";
        // 
        // cmbParity
        // 
        this.cmbParity.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        this.cmbParity.FormattingEnabled = true;
        this.cmbParity.Items.AddRange(new object[] {
            "None",
            "Even",
            "Odd"});
        this.cmbParity.Location = new System.Drawing.Point(161, 35);
        this.cmbParity.Name = "cmbParity";
        this.cmbParity.Size = new System.Drawing.Size(60, 21);
        this.cmbParity.TabIndex = 5;
        // 
        // lblDataBits
        // 
        this.lblDataBits.AutoSize = true;
        this.lblDataBits.Location = new System.Drawing.Point(229, 19);
        this.lblDataBits.Name = "lblDataBits";
        this.lblDataBits.Size = new System.Drawing.Size(53, 13);
        this.lblDataBits.TabIndex = 6;
        this.lblDataBits.Text = "Data Bits:";
        // 
        // cmbDataBits
        // 
        this.cmbDataBits.FormattingEnabled = true;
        this.cmbDataBits.Items.AddRange(new object[] {
            "7",
            "8",
            "9"});
        this.cmbDataBits.Location = new System.Drawing.Point(227, 35);
        this.cmbDataBits.Name = "cmbDataBits";
        this.cmbDataBits.Size = new System.Drawing.Size(60, 21);
        this.cmbDataBits.TabIndex = 7;
        this.cmbDataBits.Validating += new System.ComponentModel.CancelEventHandler(this.cmbDataBits_Validating);
        // 
        // lblStopBits
        // 
        this.lblStopBits.AutoSize = true;
        this.lblStopBits.Location = new System.Drawing.Point(295, 19);
        this.lblStopBits.Name = "lblStopBits";
        this.lblStopBits.Size = new System.Drawing.Size(52, 13);
        this.lblStopBits.TabIndex = 8;
        this.lblStopBits.Text = "Stop Bits:";
        // 
        // cmbStopBits
        // 
        this.cmbStopBits.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        this.cmbStopBits.FormattingEnabled = true;
        this.cmbStopBits.Items.AddRange(new object[] {
            "1",
            "2",
            "3"});
        this.cmbStopBits.Location = new System.Drawing.Point(293, 35);
        this.cmbStopBits.Name = "cmbStopBits";
        this.cmbStopBits.Size = new System.Drawing.Size(65, 21);
        this.cmbStopBits.TabIndex = 9;
        // 
        // btnOpenPort
        // 
        this.btnOpenPort.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.btnOpenPort.Location = new System.Drawing.Point(388, 334);
        this.btnOpenPort.Name = "btnOpenPort";
        this.btnOpenPort.Size = new System.Drawing.Size(135, 60);
        this.btnOpenPort.TabIndex = 6;
        this.btnOpenPort.Text = "Open COM Port";
        this.btnOpenPort.Click += new System.EventHandler(this.btnOpenPort_Click);
        // 
        // gbPortSettings
        // 
        this.gbPortSettings.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
        this.gbPortSettings.Controls.Add(this.lblComPort);
        this.gbPortSettings.Controls.Add(this.cmbPortName);
        this.gbPortSettings.Controls.Add(this.lblStopBits);
        this.gbPortSettings.Controls.Add(this.cmbBaudRate);
        this.gbPortSettings.Controls.Add(this.cmbStopBits);
        this.gbPortSettings.Controls.Add(this.lblBaudRate);
        this.gbPortSettings.Controls.Add(this.lblDataBits);
        this.gbPortSettings.Controls.Add(this.cmbParity);
        this.gbPortSettings.Controls.Add(this.cmbDataBits);
        this.gbPortSettings.Controls.Add(this.label1);
        this.gbPortSettings.Location = new System.Drawing.Point(12, 330);
        this.gbPortSettings.Name = "gbPortSettings";
        this.gbPortSettings.Size = new System.Drawing.Size(370, 64);
        this.gbPortSettings.TabIndex = 4;
        this.gbPortSettings.TabStop = false;
        this.gbPortSettings.Text = "Serial Port &Settings";
        // 
        // btnGame_Reset
        // 
        this.btnGame_Reset.Anchor = System.Windows.Forms.AnchorStyles.Right;
        this.btnGame_Reset.Location = new System.Drawing.Point(572, 17);
        this.btnGame_Reset.Name = "btnGame_Reset";
        this.btnGame_Reset.Size = new System.Drawing.Size(109, 26);
        this.btnGame_Reset.TabIndex = 8;
        this.btnGame_Reset.Text = "Game Reset";
        this.btnGame_Reset.UseVisualStyleBackColor = true;
        this.btnGame_Reset.MouseDown += new System.Windows.Forms.MouseEventHandler(this.btnGame_Reset_MouseDown);
        this.btnGame_Reset.MouseUp += new System.Windows.Forms.MouseEventHandler(this.btnGame_Reset_MouseUp);
        // 
        // btnGame_Select
        // 
        this.btnGame_Select.Anchor = System.Windows.Forms.AnchorStyles.Right;
        this.btnGame_Select.Location = new System.Drawing.Point(572, 54);
        this.btnGame_Select.Name = "btnGame_Select";
        this.btnGame_Select.Size = new System.Drawing.Size(109, 27);
        this.btnGame_Select.TabIndex = 9;
        this.btnGame_Select.Text = "Game Select";
        this.btnGame_Select.UseVisualStyleBackColor = true;
        this.btnGame_Select.MouseDown += new System.Windows.Forms.MouseEventHandler(this.btnGame_Select_MouseDown);
        this.btnGame_Select.MouseUp += new System.Windows.Forms.MouseEventHandler(this.btnGame_Select_MouseUp);
        // 
        // LeftDifficultyBox
        // 
        this.LeftDifficultyBox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.LeftDifficultyBox.Controls.Add(this.NoviceLeft);
        this.LeftDifficultyBox.Controls.Add(this.ExpertLeft);
        this.LeftDifficultyBox.Location = new System.Drawing.Point(572, 90);
        this.LeftDifficultyBox.Name = "LeftDifficultyBox";
        this.LeftDifficultyBox.Size = new System.Drawing.Size(109, 71);
        this.LeftDifficultyBox.TabIndex = 10;
        this.LeftDifficultyBox.TabStop = false;
        this.LeftDifficultyBox.Text = "Left Difficulty";
        // 
        // NoviceLeft
        // 
        this.NoviceLeft.AutoSize = true;
        this.NoviceLeft.Location = new System.Drawing.Point(7, 44);
        this.NoviceLeft.Name = "NoviceLeft";
        this.NoviceLeft.Size = new System.Drawing.Size(75, 17);
        this.NoviceLeft.TabIndex = 1;
        this.NoviceLeft.Text = "Novice (B)";
        this.NoviceLeft.UseVisualStyleBackColor = true;
        this.NoviceLeft.CheckedChanged += new System.EventHandler(this.rdoLeft_Novice_Changed);
        // 
        // ExpertLeft
        // 
        this.ExpertLeft.AutoSize = true;
        this.ExpertLeft.Checked = true;
        this.ExpertLeft.Location = new System.Drawing.Point(7, 20);
        this.ExpertLeft.Name = "ExpertLeft";
        this.ExpertLeft.Size = new System.Drawing.Size(71, 17);
        this.ExpertLeft.TabIndex = 0;
        this.ExpertLeft.TabStop = true;
        this.ExpertLeft.Text = "Expert (A)";
        this.ExpertLeft.UseVisualStyleBackColor = true;
        this.ExpertLeft.CheckedChanged += new System.EventHandler(this.rdoLeft_Expert_Changed);
        // 
        // RightDifficultyBox
        // 
        this.RightDifficultyBox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.RightDifficultyBox.Controls.Add(this.NoviceRight);
        this.RightDifficultyBox.Controls.Add(this.ExpertRight);
        this.RightDifficultyBox.Location = new System.Drawing.Point(572, 165);
        this.RightDifficultyBox.Name = "RightDifficultyBox";
        this.RightDifficultyBox.Size = new System.Drawing.Size(109, 64);
        this.RightDifficultyBox.TabIndex = 11;
        this.RightDifficultyBox.TabStop = false;
        this.RightDifficultyBox.Text = "Right Difficulty";
        // 
        // NoviceRight
        // 
        this.NoviceRight.AutoSize = true;
        this.NoviceRight.Location = new System.Drawing.Point(7, 44);
        this.NoviceRight.Name = "NoviceRight";
        this.NoviceRight.Size = new System.Drawing.Size(75, 17);
        this.NoviceRight.TabIndex = 1;
        this.NoviceRight.Text = "Novice (B)";
        this.NoviceRight.UseVisualStyleBackColor = true;
        this.NoviceRight.CheckedChanged += new System.EventHandler(this.rdoRight_Novice_Changed);
        // 
        // ExpertRight
        // 
        this.ExpertRight.AutoSize = true;
        this.ExpertRight.Checked = true;
        this.ExpertRight.Location = new System.Drawing.Point(7, 20);
        this.ExpertRight.Name = "ExpertRight";
        this.ExpertRight.Size = new System.Drawing.Size(71, 17);
        this.ExpertRight.TabIndex = 0;
        this.ExpertRight.TabStop = true;
        this.ExpertRight.Text = "Expert (A)";
        this.ExpertRight.UseVisualStyleBackColor = true;
        this.ExpertRight.CheckedChanged += new System.EventHandler(this.rdoRight_Expert_Changed);
        // 
        // grpColBW
        // 
        this.grpColBW.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.grpColBW.Controls.Add(this.rdoBW);
        this.grpColBW.Controls.Add(this.rdoColor);
        this.grpColBW.Location = new System.Drawing.Point(572, 234);
        this.grpColBW.Name = "grpColBW";
        this.grpColBW.Size = new System.Drawing.Size(109, 68);
        this.grpColBW.TabIndex = 12;
        this.grpColBW.TabStop = false;
        this.grpColBW.Text = "Color BW Sel";
        // 
        // rdoBW
        // 
        this.rdoBW.AutoSize = true;
        this.rdoBW.Location = new System.Drawing.Point(7, 44);
        this.rdoBW.Name = "rdoBW";
        this.rdoBW.Size = new System.Drawing.Size(48, 17);
        this.rdoBW.TabIndex = 1;
        this.rdoBW.Text = "B/W";
        this.rdoBW.UseVisualStyleBackColor = true;
        this.rdoBW.CheckedChanged += new System.EventHandler(this.rdoBW_CheckedChanged);
        // 
        // rdoColor
        // 
        this.rdoColor.AutoSize = true;
        this.rdoColor.Checked = true;
        this.rdoColor.Location = new System.Drawing.Point(7, 20);
        this.rdoColor.Name = "rdoColor";
        this.rdoColor.Size = new System.Drawing.Size(49, 17);
        this.rdoColor.TabIndex = 0;
        this.rdoColor.TabStop = true;
        this.rdoColor.Text = "Color";
        this.rdoColor.UseVisualStyleBackColor = true;
        this.rdoColor.CheckedChanged += new System.EventHandler(this.rdoColor_CheckedChanged);
        // 
        // openFileDialog1
        // 
        this.openFileDialog1.ReadOnlyChecked = true;
        // 
        // btnSelROM
        // 
        this.btnSelROM.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
        this.btnSelROM.Location = new System.Drawing.Point(573, 326);
        this.btnSelROM.Name = "btnSelROM";
        this.btnSelROM.Size = new System.Drawing.Size(109, 30);
        this.btnSelROM.TabIndex = 13;
        this.btnSelROM.Text = "Select ROM";
        this.btnSelROM.UseVisualStyleBackColor = true;
        this.btnSelROM.Click += new System.EventHandler(this.btnSelROM_Click);
        // 
        // richTextBox1
        // 
        this.richTextBox1.Location = new System.Drawing.Point(12, 303);
        this.richTextBox1.Name = "richTextBox1";
        this.richTextBox1.ReadOnly = true;
        this.richTextBox1.Size = new System.Drawing.Size(529, 21);
        this.richTextBox1.TabIndex = 14;
        this.richTextBox1.Text = "No ROM image selected";
        // 
        // btnSendROM
        // 
        this.btnSendROM.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
        this.btnSendROM.Location = new System.Drawing.Point(573, 362);
        this.btnSendROM.Name = "btnSendROM";
        this.btnSendROM.Size = new System.Drawing.Size(109, 30);
        this.btnSendROM.TabIndex = 15;
        this.btnSendROM.Text = "Send ROM";
        this.btnSendROM.UseVisualStyleBackColor = true;
        this.btnSendROM.Click += new System.EventHandler(this.btnSendROM_Click);
        // 
        // frmTerminal
        // 
        this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.AutoSize = true;
        this.ClientSize = new System.Drawing.Size(759, 410);
        this.Controls.Add(this.btnSendROM);
        this.Controls.Add(this.richTextBox1);
        this.Controls.Add(this.btnSelROM);
        this.Controls.Add(this.grpColBW);
        this.Controls.Add(this.RightDifficultyBox);
        this.Controls.Add(this.LeftDifficultyBox);
        this.Controls.Add(this.btnGame_Select);
        this.Controls.Add(this.btnGame_Reset);
        this.Controls.Add(this.gbPortSettings);
        this.Controls.Add(this.btnOpenPort);
        this.Controls.Add(this.rtfTerminal);
        this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
        this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
        this.MinimumSize = new System.Drawing.Size(559, 288);
        this.Name = "frmTerminal";
        this.Text = "AtariFPGA Terminal";
        this.Shown += new System.EventHandler(this.frmTerminal_Shown);
        this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmTerminal_FormClosing);
        this.gbPortSettings.ResumeLayout(false);
        this.gbPortSettings.PerformLayout();
        this.LeftDifficultyBox.ResumeLayout(false);
        this.LeftDifficultyBox.PerformLayout();
        this.RightDifficultyBox.ResumeLayout(false);
        this.RightDifficultyBox.PerformLayout();
        this.grpColBW.ResumeLayout(false);
        this.grpColBW.PerformLayout();
        this.ResumeLayout(false);

    }

    #endregion

      private System.Windows.Forms.RichTextBox rtfTerminal;
    private System.Windows.Forms.ComboBox cmbPortName;
    private System.Windows.Forms.ComboBox cmbBaudRate;
    private System.Windows.Forms.Label lblComPort;
    private System.Windows.Forms.Label lblBaudRate;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.ComboBox cmbParity;
    private System.Windows.Forms.Label lblDataBits;
    private System.Windows.Forms.ComboBox cmbDataBits;
    private System.Windows.Forms.Label lblStopBits;
    private System.Windows.Forms.ComboBox cmbStopBits;
    private System.Windows.Forms.Button btnOpenPort;
    private System.Windows.Forms.GroupBox gbPortSettings;
    private System.Windows.Forms.Button btnGame_Reset;
    private System.Windows.Forms.Button btnGame_Select;
    private System.Windows.Forms.GroupBox LeftDifficultyBox;
      private System.Windows.Forms.RadioButton NoviceLeft;
      private System.Windows.Forms.RadioButton ExpertLeft;
      private System.Windows.Forms.GroupBox RightDifficultyBox;
      private System.Windows.Forms.RadioButton NoviceRight;
      private System.Windows.Forms.RadioButton ExpertRight;
      private System.Windows.Forms.GroupBox grpColBW;
      private System.Windows.Forms.RadioButton rdoBW;
      private System.Windows.Forms.RadioButton rdoColor;
      private System.Windows.Forms.OpenFileDialog openFileDialog1;
      private System.Windows.Forms.Button btnSelROM;
      private System.Windows.Forms.RichTextBox richTextBox1;
      private System.Windows.Forms.Button btnSendROM;
  }
}

