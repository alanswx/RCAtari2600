/* 
 * Project:    AtariFPGA Terminal
 *
 * Author:     Ed Henciak, based off code available from 
 *             Noah Coad, http://coad.net/noah
 * Created:    January 2007
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
using System.IO;
using System.IO.Ports;
using System.Windows.Forms;
using System.ComponentModel;
using System.Collections.Generic;

using AtariFPGATerminal.Properties;
#endregion



namespace AtariFPGATerminal
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
   
    // Pointer to the current ROM image we wish to send to the Atari FPGA
    private string rom_file_name = "";

    // Various colors for logging info
    private Color[] LogMsgTypeColor = { Color.Blue, Color.Green, Color.Black, Color.Orange, Color.Red };

    const byte SYSTEM_RESET        = 0xA0;
    const byte GAME_START_PRESSED  = 0xA1;
    const byte GAME_START_RELEASED = 0xA2;
    const byte GAME_SEL_PRESSED    = 0xA3;
    const byte GAME_SEL_RELEASED   = 0xA4;
    const byte UPLOAD_MODE         = 0xA5;
    const byte SET_LEFT_DIFF       = 0xA6;
    const byte CLEAR_LEFT_DIFF     = 0xA7;
    const byte SET_RIGHT_DIFF      = 0xA8;
    const byte CLEAR_RIGHT_DIFF    = 0xA9;
    const byte SET_COLOR           = 0xAA;
    const byte CLEAR_COLOR         = 0xAB;

    // Silly character buffer for transmitting single
    // instructions to the board...
    byte[] char_buffer = new byte[1];

    // Flag used to prevent the serial port event handler from reading the port...
    int block_serial = 0;

      int    curbyte;
      int    permission_to_use_serial = 0;
      string curbyte_str;
      int    tick;

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

      if (comport.IsOpen) btnOpenPort.Text = "&Close Port";
      else btnOpenPort.Text = "&Open Port";
    }

    private void SendCommand(byte command)
    {

          if (comport.IsOpen)
          {
              char_buffer[0] = command;
              comport.Write(char_buffer, 0, 1);
              while (comport.BytesToWrite > 0) { }
          }
          else
          {
              Log(LogMsgType.Error, "The COM Port is current CLOSED.  Please open it with the Open Port Button\n");
          }
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

    #endregion

    #region Local Properties

    #endregion

    #region Event Handlers

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

        SendCommand(SYSTEM_RESET);
      }

      // Change the state of the form's controls
      EnableControls();

    }
 
    private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
    {
        // This method will be called when there is data waiting in the port's buffer

        // Read all the data waiting in the buffer
        string data = comport.ReadExisting();

        // Display the text to the user in the terminal
        Log(LogMsgType.Incoming, data);
          
    }

    private void btnGame_Reset_MouseDown(object sender, MouseEventArgs e)
    {
         Log(LogMsgType.Normal, "Game Reset Depressed\n");
         SendCommand(GAME_START_PRESSED);
    }

      private void btnGame_Reset_MouseUp(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Reset Released\n");
         SendCommand(GAME_START_RELEASED);
      }

      private void btnGame_Select_MouseDown(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Select Depressed\n");
         SendCommand(GAME_SEL_PRESSED);
      }

      private void btnGame_Select_MouseUp(object sender, MouseEventArgs e)
      {
         Log(LogMsgType.Normal, "Game Select Released\n");
         SendCommand(GAME_SEL_RELEASED);
      }

      private void rdoLeft_Expert_Changed(object sender, EventArgs e)
      {
          if (ExpertLeft.Checked)
          {
              Log(LogMsgType.Normal, "Left Expert Enabled\n");
              SendCommand(SET_LEFT_DIFF);
          }
      }

      private void rdoLeft_Novice_Changed(object sender, EventArgs e)
      {
          if (NoviceLeft.Checked)
          {
              Log(LogMsgType.Normal, "Left Novice Enabled\n");
              SendCommand(CLEAR_LEFT_DIFF);
          }

      }

      private void rdoRight_Expert_Changed(object sender, EventArgs e)
      {
          if (ExpertRight.Checked)
          {
              Log(LogMsgType.Normal, "Right Expert Enabled\n");
              SendCommand(SET_RIGHT_DIFF);
          }
      }

      private void rdoRight_Novice_Changed(object sender, EventArgs e)
      {
          if (NoviceRight.Checked)
          {
              Log(LogMsgType.Normal, "Right Novice Enabled\n");
              SendCommand(CLEAR_RIGHT_DIFF);
          }
     }
    
      private void rdoColor_CheckedChanged(object sender, EventArgs e)
      {
          if (rdoColor.Checked)
          {
              Log(LogMsgType.Normal, "Color Enabled\n");
              SendCommand(SET_COLOR);
          }
      }

      private void rdoBW_CheckedChanged(object sender, EventArgs e)
      {
          if (rdoBW.Checked)
          {
              Log(LogMsgType.Normal, "Black & White Enabled\n");
              SendCommand(CLEAR_COLOR);
          }
      }
  
      private void btnSelROM_Click(object sender, EventArgs e)
      {
          if (this.openFileDialog1.ShowDialog() == DialogResult.OK)
          {
              MessageBox.Show("The file " + this.openFileDialog1.FileName +
                              " has been selected.\n");
              rom_file_name = this.openFileDialog1.FileName;
              richTextBox1.Clear();
              richTextBox1.AppendText("Current ROM Selected is : " + rom_file_name);

          }
          else
              MessageBox.Show("The Cancel button was clicked or Esc was pressed");
      }

      private void btnSendROM_Click(object sender, EventArgs e)
      {
          // Declare some local variables...
          int xfer_cnt = 0;
          int block_cnt = 0;
          byte send_byte = 0;

          // See if we can transfer the files...
          if (comport.IsOpen)
          {
              // So the user has decided to send a ROM To the FPGA...
              // Open the file...it is a binary file...
              FileStream fs = new FileStream(rom_file_name, FileMode.Open, FileAccess.Read);
              //BinaryReader r = new BinaryReader(fs);

              //Log(LogMsgType.Normal, "Sending the file " + rom_file_name + "\n");
              //Log(LogMsgType.Normal, "File is size " + fs.Length + " bytes.\n");

              SendCommand(UPLOAD_MODE);

              System.Threading.Thread.Sleep(1);
              
              UInt16 length_uint16 = (UInt16)fs.Length;
              byte[] bytLength   = new byte[2];
              bytLength = System.BitConverter.GetBytes(length_uint16);
              //Log(LogMsgType.Normal, "Length byte #1 = " + bytLength[0] + " \nLength Byte #2 = " + bytLength[1] + "\n");

              // Send the length to the chip...
              SendCommand(bytLength[0]);
              System.Threading.Thread.Sleep(1);
              SendCommand(bytLength[1]);
              System.Threading.Thread.Sleep(1);

              // Now that the length is sent, we can transfer the file.
              using (fs)
                  comport.Write((new BinaryReader(fs)).ReadBytes((int)fs.Length),0,(int)fs.Length);

              //for (xfer_cnt = 0; xfer_cnt < length_uint16 ; xfer_cnt++){
              //    
              //     send_byte = r.ReadByte();
              //     //Log(LogMsgType.Normal, "S:" + send_byte.ToString("X2") + "\n");
              //     SendCommand(send_byte);
              //     System.Threading.Thread.Sleep(1);
              //}
                        
              // We're done...let the user know this...
              Log(LogMsgType.Normal, "Sent " + xfer_cnt + " bytes to the FPGA.");
             
          }
          else
          {
              Log(LogMsgType.Error, "The COM Port is current CLOSED.  Please open it with the Open Port Button\n");
          }

      }
      #endregion
  }
}