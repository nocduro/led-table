using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;
using Windows.Networking;
using Windows.Networking.Connectivity;
using Windows.Networking.Sockets;
using Windows.Storage.Streams;
using System.Text;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=391641

namespace TestApp
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {

        private StreamSocket clientSocket;
        private HostName serverHost;
        private string serverHostnameString;
        private int serverPort;
        private bool connected = false;
        private bool closing = false;


        public MainPage()
        {
            this.InitializeComponent();
            clientSocket = new StreamSocket();

            this.NavigationCacheMode = NavigationCacheMode.Required;
        }

        /// <summary>
        /// Invoked when this page is about to be displayed in a Frame.
        /// </summary>
        /// <param name="e">Event data that describes how this page was reached.
        /// This parameter is typically used to configure the page.</param>
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            // TODO: Prepare page for display here.

            // TODO: If your application contains multiple pages, ensure that you are
            // handling the hardware Back button by registering for the
            // Windows.Phone.UI.Input.HardwareButtons.BackPressed event.
            // If you are using the NavigationHelper provided by some templates,
            // this event is handled for you.

            ModeComboBox.Items.Add("Sound Reactive");
            ModeComboBox.Items.Add("Bouncing bubbles");
            

        }

        private byte ledBrightness = 0;
        

        private void TextBlock_SelectionChanged(object sender, RoutedEventArgs e)
        {

        }
        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }

        private void BrightnessSlider_ValueChanged(object sender, RangeBaseValueChangedEventArgs e)
        {
            ledBrightness = (byte)BrightnessSlider.Value;
            BrightnessTextBox.Text = String.Format("Brightness {0}%", ledBrightness);
            SendMessage("brightness ", ledBrightness);
        }

        private async void Send_Click(object sender, RoutedEventArgs e)
        {
            if (!connected)
            {
                StatusText.Text = "Must be connected to send!";
                return;
            }

            Int32 len = 0; // gets the UTF-8 string length;

            try
            {
                OutputView.Text = "";
                StatusText.Text = "Trying to send data ...";

                // add a new line to text and send
                string sendData = SendText.Text + Environment.NewLine;
                DataWriter writer = new DataWriter(clientSocket.OutputStream);
                len = (int)writer.MeasureString(sendData); // Gets the UTF-8 string length
                writer.WriteString(sendData);
                // call StoreAsync method to store the data to a backing stream
                await writer.StoreAsync();
                

                StatusText.Text = "Data was sent" + Environment.NewLine;
                await writer.FlushAsync();
                // detach the stream and close it
                writer.DetachStream();
                writer.Dispose();
                
            }
            catch (Exception exception)
            {
                // If this is an unknown status, 
                // it means that the error is fatal and retry will likely fail.
                if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                {
                    throw;
                }

                StatusText.Text = "Send data or receive failed with error: " + exception.Message;
                // Could retry the connection, but for this simple example
                // just close the socket.

                closing = true;
                clientSocket.Dispose();
                clientSocket = null;
                connected = false;
            }
            
            // Now try to receive data from the server
            try
            {
                OutputView.Text = "";
                StatusText.Text = "Trying to receive data ...";
                byte[] buffer = new byte[4];

                DataReader reader = new DataReader(clientSocket.InputStream);
                // Set inputstream options so that we don't have to know the data size
                reader.InputStreamOptions = InputStreamOptions.Partial;
                await reader.LoadAsync(1024);
                string receivedLengthString = reader.ReadString(4);
                uint lengthOfString = uint.Parse(receivedLengthString);

                string textReceived = reader.ReadString(lengthOfString);
                OutputView.Text = textReceived;
                reader.DetachBuffer();
                reader.DetachStream();
            }
            catch (Exception exception)
            {
                // If this is an unknown status, 
                // it means that the error is fatal and retry will likely fail.
                if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                {
                    throw;
                }

                StatusText.Text = "Receive failed with error: " + exception.Message;
                // Could retry, but for this simple example
                // just close the socket.

                closing = true;
                clientSocket.Dispose();
                clientSocket = null;
                connected = false;
            }
            


        }

        private async void ConnectButton_Click(object sender, RoutedEventArgs e)
        {
            if (connected)
            {
                StatusText.Text = "Already Connected";
                return;
            }

            try
            {
                OutputView.Text = "";
                StatusText.Text = "Trying to connect ...";

                serverHost = new HostName(ServerHostname.Text);
                // try to connect to the
                await clientSocket.ConnectAsync(serverHost, ServerPort.Text);
                connected = true;
                StatusText.Text = "Connection established" + Environment.NewLine;

                // receive data from server on state
                SendMessage("firstConnect");


            }
            catch (Exception exception)
            {
                // If this is an unknown status, 
                // it means that the error is fatal and retry will likely fail.
                if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                {
                    throw;
                }

                StatusText.Text = "Connect failed with error: " + exception.Message;
                // Could retry the connection, but for this simple example
                // just close the socket.

                closing = true;
                // the Close method is mapped to the C# Dispose
                clientSocket.Dispose();
                clientSocket = null;
            }




        }

        private async void SendMessage(string dataType, int dataValue)
        {
            if (!connected)
            {
                StatusText.Text = "Must be connected to send!";
                return;
            }

            Int32 len = 0; // gets the UTF-8 string length;

            try
            {
                OutputView.Text = "";
                StatusText.Text = "Trying to send data ...";

                // add a new line to text and send
                string sendData = dataType + dataValue + Environment.NewLine;
                DataWriter writer = new DataWriter(clientSocket.OutputStream);
                len = (int)writer.MeasureString(sendData); // Gets the UTF-8 string length
                writer.WriteString(sendData);
                // call StoreAsync method to store the data to a backing stream
                await writer.StoreAsync();


                StatusText.Text = "Data was sent" + Environment.NewLine;
                await writer.FlushAsync();
                // detach the stream and close it
                writer.DetachStream();
                writer.Dispose();

            }
            catch (Exception exception)
            {
                // If this is an unknown status, 
                // it means that the error is fatal and retry will likely fail.
                if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                {
                    throw;
                }

                StatusText.Text = "Send data or receive failed with error: " + exception.Message;
                // Could retry the connection, but for this simple example
                // just close the socket.

                closing = true;
                clientSocket.Dispose();
                clientSocket = null;
                connected = false;
            }

            // Now try to receive data from the server
            try
            {
                OutputView.Text = "";
                StatusText.Text = "Trying to receive data ...";
                byte[] buffer = new byte[4];

                DataReader reader = new DataReader(clientSocket.InputStream);
                // Set inputstream options so that we don't have to know the data size
                reader.InputStreamOptions = InputStreamOptions.Partial;
                await reader.LoadAsync(1024);
                string receivedLengthString = reader.ReadString(4);
                uint lengthOfString = uint.Parse(receivedLengthString);

                string textReceived = reader.ReadString(lengthOfString);
                OutputView.Text = textReceived;
                reader.DetachBuffer();
                reader.DetachStream();
            }
            catch (Exception exception)
            {
                // If this is an unknown status, 
                // it means that the error is fatal and retry will likely fail.
                if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                {
                    throw;
                }

                StatusText.Text = "Receive failed with error: " + exception.Message;
                // Could retry, but for this simple example
                // just close the socket.

                closing = true;
                clientSocket.Dispose();
                clientSocket = null;
                connected = false;
            }
        }

        private async void SendMessage(string message)
        {
            {
                if (!connected)
                {
                    StatusText.Text = "Must be connected to send!";
                    return;
                }

                Int32 len = 0; // gets the UTF-8 string length;

                try
                {
                    OutputView.Text = "";
                    StatusText.Text = "Trying to send data ...";

                    // add a new line to text and send
                    string sendData = message + Environment.NewLine;
                    DataWriter writer = new DataWriter(clientSocket.OutputStream);
                    len = (int)writer.MeasureString(sendData); // Gets the UTF-8 string length
                    writer.WriteString(sendData);
                    // call StoreAsync method to store the data to a backing stream
                    await writer.StoreAsync();


                    StatusText.Text = "Data was sent" + Environment.NewLine;
                    await writer.FlushAsync();
                    // detach the stream and close it
                    writer.DetachStream();
                    writer.Dispose();

                }
                catch (Exception exception)
                {
                    // If this is an unknown status, 
                    // it means that the error is fatal and retry will likely fail.
                    if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                    {
                        throw;
                    }

                    StatusText.Text = "Send data or receive failed with error: " + exception.Message;
                    // Could retry the connection, but for this simple example
                    // just close the socket.

                    closing = true;
                    clientSocket.Dispose();
                    clientSocket = null;
                    connected = false;
                }

                // Now try to receive data from the server
                try
                {
                    OutputView.Text = "";
                    StatusText.Text = "Trying to receive data ...";
                    byte[] buffer = new byte[4];

                    DataReader reader = new DataReader(clientSocket.InputStream);
                    // Set inputstream options so that we don't have to know the data size
                    reader.InputStreamOptions = InputStreamOptions.Partial;
                    await reader.LoadAsync(1024);
                    string receivedLengthString = reader.ReadString(4);
                    uint lengthOfString = uint.Parse(receivedLengthString);

                    string textReceived = reader.ReadString(lengthOfString);
                    OutputView.Text = textReceived;
                    reader.DetachBuffer();
                    reader.DetachStream();
                }
                catch (Exception exception)
                {
                    // If this is an unknown status, 
                    // it means that the error is fatal and retry will likely fail.
                    if (SocketError.GetStatus(exception.HResult) == SocketErrorStatus.Unknown)
                    {
                        throw;
                    }

                    StatusText.Text = "Receive failed with error: " + exception.Message;
                    // Could retry, but for this simple example
                    // just close the socket.

                    closing = true;
                    clientSocket.Dispose();
                    clientSocket = null;
                    connected = false;
                }
            }
        }

        
    }
}
