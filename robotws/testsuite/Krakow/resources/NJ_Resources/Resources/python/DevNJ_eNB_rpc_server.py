#!/usr/bin/env python

from __future__ import print_function

import signal
import threading

from robotremoteserver import RobotRemoteServer

from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_eNB_keywords import EnbRpcLibrary

ADDRESS = "0.0.0.0"
PORT = 8270

if __name__ == "__main__":
    server = RobotRemoteServer(EnbRpcLibrary(), host=ADDRESS, port=PORT, serve=False)
    server.serve()
