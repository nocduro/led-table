from flask import Flask, render_template, request
import socket
import sys

app = Flask(__name__)

# constants used for connecting to the matrix control sketch over a TCP socket
LED_MATRIX_IP = '127.0.0.1'
LED_MATRIX_PORT = 5204
LED_MATRIX_BUFFER_SIZE = 1024


def send_message(m):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect( (LED_MATRIX_IP, LED_MATRIX_PORT) )
        s.send(m.encode('utf-8'))
    except:
        print("ERROR: Couldn't connect to TCP server")
    finally:
        s.close()


def parse_message(key, val):
    key = key.strip().upper()
    val = val.strip().upper()

    print("Form key: ", key, " value: ", val)

    if key == 'CUSTOMCOMMAND':
        send_message(val)
        return
    if key == 'BRIGHTNESS':
        send_message('BRIGHTNESS ' + val)
        return
    if key == 'MODESELECTION':
        send_message('MODE ' + val)
        return
    if key == 'COLOURPICKER1':
        # strip the # from the colour
        val = val.replace("#", "")
        send_message('COLOUR PRIMARY ' + val)
        return
    if key == 'COLOURPICKER2':
        # strip the # from the colour
        val = val.replace("#", "")
        send_message('COLOUR SECONDARY ' + val)
        return



#send_message('hello')
#send_message('colour primary ff9900')

@app.route("/", methods=['GET', 'POST'])
def index():
    print("request.method = ", request.method)
    if request.method == 'GET':
        # send the webpage
        return render_template('index.html')
    elif request.method == 'POST':
        # from data was submitted
        for key in request.form:
            parse_message(key, request.form[key])
        return render_template('index.html')
    else:
        return "<h2>Invalid request</h2>"

@app.route("/settings")
def settings():
    return "Settings page"


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=False)
