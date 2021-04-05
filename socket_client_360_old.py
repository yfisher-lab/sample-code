#!/usr/bin/env python3
#cd 'C:\Users\ewest\PycharmProjects\pythonProject\venv\Lib\site-packages'
from Phidget22.Phidget import *
from Phidget22.Devices.VoltageOutput import *
import socket
import numpy as np
#cd 'C:\Code\FicTrac\scripts'
# *********** Set up socket info ***********

HOST = '127.0.0.1'  # Standard loopback interface address (localhost)
PORT = 65432  # Port to listen on (non-privileged ports are > 1023)

# The following is from the 'init' part of analogout.py (https://github.com/jennyl617/fly_experiments/blob/master/fictrac_2d/analogout.py)


# *********** Set up analog output channels ***********

# Setup analog output y
aout_y = VoltageOutput()
aout_y.setChannel(2)
aout_y.openWaitForAttachment(5000)
aout_y.setVoltage(0.0)

# Setup analog output yaw
aout_yaw = VoltageOutput()
aout_yaw.setChannel(0)
aout_yaw.openWaitForAttachment(5000)
aout_yaw.setVoltage(0.0)

# Setup analog output YAW_GAIN
aout_yaw_gain = VoltageOutput()
aout_yaw_gain.setChannel(3)
aout_yaw_gain.openWaitForAttachment(5000)
aout_yaw_gain.setVoltage(0.0)

# Setup analog output x
aout_x = VoltageOutput()
aout_x.setChannel(1)
aout_x.openWaitForAttachment(5000)
aout_x.setVoltage(0.0)

# Open the connection (FicTrac must be waiting for socket connection) and get data until FT closes....

# Below we create a socket object using socket.socket() and specify the socket type as socket.SOCK_STREAM.
# When you do that, the default protocol thatâ€™s used is the Transmission Control Protocol (TCP). This is a good
# default and probably what you want. # The object can be used w/in a with statement and there's no need to call s.close().

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.connect((HOST, PORT))
    data = ""

    # Keep receiving data until FicTrac closes

    # while True:
    while True:

        # Receive one data frame
        new_data = sock.recv(1024)
        if not new_data:
            break

        # Decode received data
        data += new_data.decode('UTF-8')

        # Find the first frame of data
        endline = data.find("\n")
        line = data[:endline]  # copy first frame
        data = data[endline + 1:]  # delete first frame

        # Tokenise
        toks = line.split(", ")

        # Fixme: sometimes we read more than one line at a time,
        # should handle that rather than just dropping extra data...
        if ((len(toks) < 24) | (toks[0] != "FT")):
            print('Bad read')
            continue

        # Extract FicTrac variables - see https://github.com/rjdmoore/fictrac/blob/master/doc/data_header.txt
        cnt = int(toks[1])
        heading = float(toks[17])
        #velx = float(toks[6])  # ball velocity about the x axis, i.e. L/R rotation velocity (units = rotation angle/axis in rads), see config image
        #vely = float(toks[7])  # ball velocity about the y axis, i.e. fwd/backwards rotation velocity
        #velheading = float(toks[8])  # ball velocity about the z axis, i.e. yaw/heading velocity
        intx = float(toks[20])  # displacement of the fly in the x direction CHANGED 10/25
        inty = float(toks[21])  # displacement of the fly in the y direction CHANGED 10/25

        # Send voltage signals
        # Set analog output voltage YAW
        output_voltage_yaw = (heading) * 10. / (2*np.pi)
        # output_voltage_yaw = clamp(output_voltage_yaw, aout_min_volt, aout_max_volt)
        aout_yaw.setVoltage(output_voltage_yaw)

        # Set analog output voltage X
        wrapped_intx = (intx % (2 * np.pi))  # transform into animal coordinates
        output_voltage_x = wrapped_intx * 10. / (2 * np.pi)
        # output_voltage_x = clamp(output_voltage_x, aout_min_volt,aout_max_volt)
        aout_x.setVoltage(output_voltage_x)

        # Set analog output voltage YAW_GAIN
        output_voltage_yaw_gain = (heading % (2*np.pi)) * (10.) / (2*np.pi)
        # output_voltage_yaw_gain = clamp(output_voltage_yaw_gain, aout_min_volt,aout_max_volt)
        aout_yaw_gain.setVoltage(output_voltage_yaw_gain)

        # Set analog output voltage Y
        wrapped_inty = (inty % (2 * np.pi))  # transform into animal coordinates
        output_voltage_y = wrapped_inty * 10. / (2 * np.pi)
        #output_voltage_x = clamp(output_voltage_x, 0, 10)
        aout_y.setVoltage(output_voltage_y)

        #print(heading)

def clamp(x, min_val, max_val):
    """
    Clamp value between min_val and max_val
    """
    return max(min(x, max_val), min_val)
