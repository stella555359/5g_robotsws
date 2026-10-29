import re
from subprocess import *
from threading import *
import time
import socket
import traceback


# ----------------
class Cockpit_Server:
    # ----------------
    def __init__(self, debug, config, serverStateLabel, actions):
        self._debug = debug
        self._config = config
        self._serverState = serverStateLabel
        self._actions = actions
        self._eventStop = False

        Thread(target=self.ThreadServer).start()

    def setEventStop(self):
        self._eventStop = True

    def getIpAddress(self):
        # print("getIpAddress")
        cmd = "ipconfig"
        p = Popen(cmd.split(), stdout=PIPE)
        result = p.communicate()[0].decode(
            "utf-8", "ignore")  # Richard: Python36
        p.stdout.close()

        # Richard 18-02-2016 : debut modif
        # ip_re=re.compile("IP.*\:\s(?P<ip>\d+\.\d+\.\d+.\d+)",re.IGNORECASE)
        ip_re = re.compile(
            "IP.*\\:\\s(?P<ip>135\\.\\d+\\.\\d+.\\d+)",
            re.IGNORECASE)
        # Richard 18-02-2016 : fin modif
        IpFound = ip_re.search(result)
        if IpFound:
            return IpFound.group('ip')
        else:
            self._debug.write(0, "RMCTRL Did not find IP address")
            return None

    def parse_line(self, buffer):
        pos = buffer.find('\n')
        if pos != -1:
            return 1, buffer[pos + 1:], buffer[:pos - 1]
        else:
            return 0, buffer, ""

    def ThreadServer(self):
        self._debug.write(2, "RMCTRL thread started")
        try:
            # host_ip = self.getIpAddress()
            host_ip = ''  # means all available interfaces
            if host_ip is None:
                self._debug.writeErr(0, "NO IP TO BIND SERVER TO")
                return
            else:
                self._debug.write(3, "RMCTRL binding to ip " + host_ip)

            mySocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

            try:
                # print(host_ip)
                mySocket.bind((host_ip, self._config.TcpPort))
            except socket.error:
                self._debug.HandleMsgColor('Socket creation failed', "red")
                sys.exit()

            while not self._eventStop:
                self._serverState.config(
                    text='Server state: Waiting connection on ' +
                    host_ip +
                    " : TCP Port " +
                    str(
                        self._config.TcpPort),
                    foreground="blue")
                mySocket.listen(5)
                mySocket.settimeout(2)
                try:
                    connexion, adresse = mySocket.accept()
                except Exception:
                    connexion = None

                # check if connection or timeout
                if connexion:
                    buffer = ""

                    # set socket to blocking
                    mySocket.settimeout(0.1)

                    self._serverState.config(
                        text='Server state: Connected', foreground="green")
                    self._debug.write(
                        0, "RMCTRL: Client connected, IP = %s, port = %s" %
                        (adresse[0], adresse[1]))
                    time.sleep(2)
                    connexion.send("\n")
                    self._debug.write(0, "RMCTRL =>INIT")
                    connexion.send("INIT")

                    rmctrl_error_message = "NO ERROR"

                    while not self._eventStop:
                        try:
                            # self._debug.write(0, "Waiting for message")
                            msgClient = connexion.recv(1024)
                            # self._debug.write(0, "Message received")
                            # print(msgClient)
                            if not msgClient:
                                self._debug.write(
                                    0, "RMCTRL Disconnected from client")
                                connexion.close()
                                break
                            status = 1
                        except Exception:
                            if self.eventStop:
                                self._debug.write(
                                    0, "RMCTRL Disconnection forced by ending")
                                connexion.close()
                                break
                            status = 0

                        if status > 0:
                            self._debug.write(3, "RMCTRL <= Received message")
                            buffer = buffer + msgClient.upper()
                            test, buffer, keyword = self.parse_line(buffer)
                            if test:
                                self._debug.write(0, "RMCTRL <=" + keyword)
                                send_msg = ""
                                if keyword == "STATUS":
                                    send_msg = "OK"

                                if keyword in ("GET TIME", "GET_TIME"):
                                    send_msg = time.strftime(
                                        "%Y/%m/%d-%H:%M:%S",
                                        time.localtime(
                                            time.time())) + "ACK"

                                if keyword[0:11] == "RUN_COMMAND":
                                    commandToRun = keyword[12:]
                                    # r, w = popen2.popen2(commandToRun)
                                    p = Popen(
                                        commandToRun, shell=True, stdin=PIPE, stdout=PIPE, close_fds=True)
                                    (r, w) = (p.stdin, p.stdout)
                                    send_msg = "ACK\n"

                                if keyword[0:7] == "PROCESS":
                                    proc_re = re.compile(
                                        "PROCESS\\s*(?P<ueId>\\d+)")
                                    proc_re_obj = proc_re.search(keyword)
                                    if proc_re_obj is not None:
                                        ueId = self.ueRemoteId[proc_re_obj.group(
                                            "ueId")]
                                        nbOfProc = self._config.getNumberOfThread(
                                            ueId)
                                    # print("nbOfProc" + str(nbOfProc))
                                    else:
                                        nbOfProc = self._config.getNumberOfThread()
                                    # #self.scen[ueId].stop()

                                    send_msg = str(nbOfProc) + "ACK"

                                if keyword[0:5] == "ERROR":
                                    send_msg = rmctrl_error_message

                                if keyword == "QUIT":
                                    self._debug.write(
                                        0, "RMCTRL: Disconnection requested by client")
                                    # send_msg="ACK"
                                    connexion.close()
                                    break

                                if send_msg != "":
                                    self._debug.write(
                                        0, "RMCTRL =>" + send_msg)
                                    connexion.send(send_msg)
                                # clear error if no problem

                                if (send_msg != "NOK") and (
                                        keyword != "STATUS"):
                                    rmctrl_error_message = "NO ERROR"

                            # End if test:
                        # End if (status>0):
                        time.sleep(0.3)

                    # End while (self._eventStop==False):
                # End if (connexion):
            # End while (self._eventStop==False):
        except Exception:
            self._debug.write(
                2,
                "RMCTRL thread exception" +
                traceback.format_exc(
                    limit=5))
        self._debug.write(2, "RMCTRL thread ended")

    # End def ThreadServer(self):
# End
