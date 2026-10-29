# This script is used to drive the CV39/CV36 Hytem 8x8
# HISTORY
# 30/03/2020  R. Duthu           Initial version: start then stop the HO
# IntraDU script

import time
import telnetlib
import socket


class Hytem8x8:
    def __init__(self):
        # HYTEM 8x8 access parameters
        self.HOST = "10.14.57.189"
        self.PORT = "2000"
        self.HO_SCRIPT_DURATION = "70"
        self.TEARDOWN_SCRIPT_DURATION = "20"
        self.NO_SCRIPT = "None"
        self.HO_SCRIPT1 = "HO_60sec_935_000.sqc"
        self.HO_SCRIPT2 = "HO_60sec_000_935.sqc"
        self.TEARDOWN_SCRIPT1 = "HO_Teardown_935.sqc"
        self.TEARDOWN_SCRIPT2 = "HO_Teardown_000.sqc"
        self.script1_user = ["36", "37", "44", "45"]
        self.script2_user = ["38", "39", "46", "47"]

    def hytem_connection(self):
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Telnet Connection To Hytem8x8"
        )
        guess_idx, gessed_str, received_str = self.tn.expect(["\\n"], 1)
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ")
            + "Received String: "
            + str(received_str)
        )

    def load_script(self, value, script):
        cmd = "SEQ " + str(value) + " " + str(script)
        self.tn.write(cmd + "\n")
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Hytem Cmd: " + cmd
        )
        time.sleep(0.5)

    def load_all_scripts(self, script1, script2):
        for ATxx in self.script1_user:
            self.load_script(ATxx, script1)
        for ATxx in self.script2_user:
            self.load_script(ATxx, script2)

    def start_script(self, value):
        cmd = "START " + str(value)
        self.tn.write(cmd + "\n")
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Hytem Cmd: " + cmd
        )
        time.sleep(0.5)

    def start_all_scripts(self):
        for ATxx in self.script1_user:
            self.start_script(ATxx)
        for ATxx in self.script2_user:
            self.start_script(ATxx)

    def sleep_during_script(self, value):
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ")
            + " ...sleep "
            + str(value)
            + "sec... "
        )
        time.sleep(int(value))

    def stop_script(self, value):
        cmd = "STOP " + str(value)
        self.tn.write(cmd + "\n")
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Hytem Cmd: " + cmd
        )
        time.sleep(0.5)

    def stop_all_scripts(self):
        for ATxx in self.script1_user:
            self.stop_script(ATxx)
        for ATxx in self.script2_user:
            self.stop_script(ATxx)

    def clear_all_scripts(self):
        for ATxx in self.script1_user:
            self.load_script(ATxx, self.NO_SCRIPT)
        for ATxx in self.script2_user:
            self.load_script(ATxx, self.NO_SCRIPT)

    def hytem_deconnection(self):
        self.f_debug.write(time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Telnet Shutdown ")
        self.tn.get_socket().shutdown(socket.SHUT_WR)
        data = self.tn.read_all()
        self.tn.close()
        self.f_debug.write(
            time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "End of Scenario\n\n"
        )

    def ho_intra_du(self):
        # Hytem Connection
        self.f_debug = open("/home/ute/traces/Hytem/Hytem_mng.log", "a")
        self.f_debug.write(time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Start Scenario")
        self.tn = telnetlib.Telnet(self.HOST, self.PORT)
        self.hytem_connection()

        # Script Launch then Stop
        self.load_all_scripts(self.HO_SCRIPT1, self.HO_SCRIPT2)
        self.start_all_scripts()
        self.sleep_during_script(self.HO_SCRIPT_DURATION)
        self.stop_all_scripts()
        self.clear_all_scripts()

        # Hytem deconnection:
        self.hytem_deconnection()

    def ho_teardown(self):
        # Hytem Connection
        self.f_debug = open("/home/ute/traces/Hytem/Hytem_mng.log", "a")
        self.f_debug.write(time.strftime("\n%Y/%m/%d %H:%M:%S - ") + "Start Scenario")
        self.tn = telnetlib.Telnet(self.HOST, self.PORT)
        self.hytem_connection()

        # Script Launch then Stop
        self.load_all_scripts(self.TEARDOWN_SCRIPT1, self.TEARDOWN_SCRIPT2)
        self.start_all_scripts()
        self.sleep_during_script(self.TEARDOWN_SCRIPT_DURATION)
        self.stop_all_scripts()
        self.clear_all_scripts()

        # Hytem deconnection:
        self.hytem_deconnection()
