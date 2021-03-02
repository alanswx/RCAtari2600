/* 
 * Project:    SerialPort Terminal
 * Company:    Coad .NET, http://coad.net
 * Author:     Noah Coad, http://coad.net/noah
 * Created:    March 2005
 * 
 * Notes:      This was created to demonstrate how to use the SerialPort control for
 *             communicating with your PC's Serial RS-232 COM Port
 * 
 *             It is for educational purposes only and not sanctified for industrial use. :)
 * 
 *             Search for "comport" to see how I'm using the SerialPort control.
 */

#region Namespace Inclusions
using System;
using System.Data;
using System.Text;
using System.Drawing;
using System.IO.Ports;
using System.Windows.Forms;
using System.ComponentModel;
using System.Collections.Generic;

using SerialPortTerminal.Properties;
#endregion

namespace SerialPortTerminal
{
  #region Public Enumerations
  public enum DataMode { Text, Hex }
  public enum LogMsgType { Incoming, Outgoing, Normal, Warning, Error };
  #endregion

  public partial class frmTerminal : Form
  {
    #region Local Variables

    // The main control for communicating through the RS-232 port
    private SerialPort comport = new SerialPort();

    // Various colors for logging info
    private Color[] LogMsgTypeColor = { Color.Blue, Color.Green, Color.Black, Color.Orange, Color.Red };

    // Temp holder for whether a key was pressed
    private bool KeyHandled = false;
    
    #endregion

    #region Constructor
    public frmTerminal()
    {
      // Build the form
      InitializeComponent();

      // Restore the users settings
      InitializeControlValues();

      // Enable/disable controls based on the current state
      EnableControls();

      // When data is recieved through the port, call this method
      comport.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);
    }
    #endregion

    #region Local Methods
    
    /// <summary> Save the user's settings. </summary>
    private void SaveSettings()
    {
      Settings.Default.BaudRate = int.Parse(cmbBaudRate.Text);
      Settings.Default.DataBits = int.Parse(cmbDataBits.Text);
      Settings.Default.Parity = (Parity)Enum.Parse(typeof(Parity), cmbParity.Text);
      Settings.Default.StopBits = (StopBits)Enum.Parse(typeof(StopBits), cmbStopBits.Text);
      Settings.Default.PortName = cmbPortName.Text;

      Settings.Default.Save();
    }

    /// <summary> Populate the form's controls with default settings. </summary>
    private void InitializeControlValues()
    {
      cmbParity.Items.Clear(); cmbParity.Items.AddRange(Enum.GetNames(typeof(Parity)));
      cmbStopBits.Items.Clear(); cmbStopBits.Items.AddRange(Enum.GetNames(typeof(StopBits)));

      cmbParity.Text = Settings.Default.Parity.ToString();
      cmbStopBits.Text = Settings.Default.StopBits.ToString();
      cmbDataBits.Text = Settings.Default.DataBits.ToString();
      cmbParity.Text = Settings.Default.Parity.ToString();
      cmbBaudRate.Text = Settings.Default.BaudRate.ToString();

      cmbPortName.Items.Clear();
      foreach (string s in SerialPort.GetPortNames())
        cmbPortName.Items.Add(s);

      if (cmbPortName.Items.Contains(Settings.Default.PortName)) cmbPortName.Text = Settings.Default.PortName;
      else if (cmbPortName.Items.Count > 0) cmbPortName.SelectedIndex = 0;
      else
      {
        MessageBox.Show(this, "There are no COM Ports detected on this computer.\nPlease install a COM Port and restart this app.", "No COM Ports Installed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        this.Close();
      }
    }

    /// <summary> Enable/disable controls based on the app's current state. </summary>
    private void EnableControls()
    {
      // Enable/disable controls based on whether the port is open or not
      gbPortSettings.Enabled = !comport.IsOpen;
      txtSendData.Enabled = btnSend.Enabled = comport.IsOpen;

      if (comport.IsOpen) btnOpenPort.Text = "&Close Port";
      else btnOpenPort.Text = "&Open Port";
    }

    /// <summary> Send the user's data currently entered in the 'send' box.</summary>
    private void SendData()
    {
      
      // Send the user's text straight out the port
      comport.Write(txtSendData.Text);

      // Show in the terminal window the user's text
      Log(LogMsgType.Outgoing, txtSendData.Text + "\n");
 
     
      txtSendData.SelectAll();
    }

    /// <summary> Log data to the terminal window. </summary>
    /// <param name="msgtype"> The type of message to be written. </param>
    /// <param name="msg"> The string containing the message to be shown. </param>
    private void Log(LogMsgType msgtype, string msg)
    {
      rtfTerminal.Invoke(new EventHandler(delegate
      {
        rtfTerminal.SelectedText = string.Empty;
        rtfTerminal.SelectionFont = new Font(rtfTerminal.SelectionFont, FontStyle.Bold);
        rtfTerminal.SelectionColor = LogMsgTypeColor[(int)msgtype];
        rtfTerminal.AppendText(msg);
        rtfTerminal.ScrollToCaret();
      }));
    }

    /// <summary> Convert a string of hex digits (ex: E4 CA B2) to a byte array. </summary>
    /// <param name="s"> The string containing the hex digits (with or without spaces). </param>
    /// <returns> Returns an array of bytes. </returns>
    private byte[] HexStringToByteArray(string s)
    {
      s = s.Replace(" ", "");
      byte[] buffer = new byte[s.Length / 2];
      for (int i = 0; i < s.Length; i += 2)
        buffer[i / 2] = (byte)Convert.ToByte(s.Substring(i, 2), 16);
      return buffer;
    }

    /// <summary> Converts an array of bytes into a formatted string of hex digits (ex: E4 CA B2)</summary>
    /// <param name="data"> The array of bytes to be translated into a string of hex digits. </param>
    /// <returns> Returns a well formatted string of hex digits with spacing. </returns>
    private string ByteArrayToHexString(byte[] data)
    {
      StringBuilder sb = new StringBuilder(data.Length * 3);
      foreach (byte b in data)
        sb.Append(Convert.ToString(b, 16).PadLeft(2, '0').PadRight(3, ' '));
      return sb.ToString().ToUpper();
    }
    #endregion

    #region Local Properties

    #endregion

    #region Event Handlers
    private void lnkAbout_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      // Show the user the about dialog
      (new frmAbout()).ShowDialog(this);
    }
    
    private void frmTerminal_Shown(object sender, EventArgs e)
    {
      Log(LogMsgType.Normal, String.Format("Application Started at {0}\n", DateTime.Now));
    }
    private void frmTerminal_FormClosing(object sender, FormClosingEventArgs e)
    {
      // The form is closing, save the user's preferences
      SaveSettings();
    }

    
    private void cmbBaudRate_Validating(object sender, CancelEventArgs e)
    { int x; e.Cancel = !int.TryParse(cmbBaudRate.Text, out x); }
    private void cmbDataBits_Validating(object sender, CancelEventArgs e)
    { int x; e.Cancel = !int.TryParse(cmbDataBits.Text, out x); }

    private void btnOpenPort_Click(object sender, EventArgs e)
    {
      // If the port is open, close it.
      if (comport.IsOpen) comport.Close();
      else
      {
        // Set the port's settings
        comport.BaudRate = int.Parse(cmbBaudRate.Text);
        comport.DataBits = int.Parse(cmbDataBits.Text);
        comport.StopBits = (StopBits)Enum.Parse(typeof(StopBits), cmbStopBits.Text);
        comport.Parity = (Parity)Enum.Parse(typeof(Parity), cmbParity.Text);
        comport.PortName = cmbPortName.Text;

        // Open the port
        comport.Open();
      }

      // Change the state of the form's controls
      EnableControls();

      // If the port is open, send focus to the send data box
      if (comport.IsOpen) txtSendData.Focus();
    }
    private void btnSend_Click(object sender, EventArgs e)
    { SendData(); }

    private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
    {
      // This method will be called when there is data waiting in the port's buffer


        // Read all the data waiting in the buffer
        string data = comport.ReadExisting();

        // Display the text to the user in the terminal
        Log(LogMsgType.Incoming, data);
      
    }

    private void txtSendData_KeyDown(object sender, KeyEventArgs e)
    { 
      // If the user presses [ENTER], send the data now
      if (KeyHandled = e.KeyCode == Keys.Enter) { e.Handled = true; SendData(); } 
    }
    private void txtSendData_KeyPress(object sender, KeyPressEventArgs e)
    { e.Handled = KeyHandled; }
    #endregion



      private void btnGame_Reset_MouseDown(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Reset Depressed\n");
      }

      private void btnGame_Reset_MouseUp(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Reset Released\n");
      }

      private void btnGame_Select_MouseDown(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Select Depressed\n");
      }

      private void btnGame_Select_MouseUp(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Select Released\n");
      }

      // If this event is handled, check the previous state of the window.
      private void rdoLeft_Expert_Changed(object sender, EventArgs e)
      {
         if (ExpertLeft.Checked) Log(LogMsgType.Normal, "Left Expert Enabled\n");
      }

      private void rdoLeft_Novice_Changed(object sender, EventArgs e)
      {
         if (NoviceLeft.Checked) Log(LogMsgType.Normal, "Left Novice Enabled\n");
      }

      private void rdoRight_Expert_Changed(object sender, EventArgs e)
      {
          if (ExpertRight.Checked) Log(LogMsgType.Normal, "Right Expert Enabled\n");
      }

      private void rdoRight_Novice_Changed(object sender, EventArgs e)
      {
          if (NoviceRight.Checked) Log(LogMsgType.Normal, "Right Novice Enabled\n");
      }
  }
}