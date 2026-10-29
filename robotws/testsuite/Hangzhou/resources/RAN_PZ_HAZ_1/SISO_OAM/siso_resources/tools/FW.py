from __future__ import absolute_import
from __future__ import print_function
import socket
import time
import datetime
import re


class GG(object):
    def __init__(
        self, ip, port=10034, timeout=20, userName="BTS637", password="Siso2abc123^"
    ):
        self.ip = ip
        self.port = port
        self.timeout = timeout
        self.con = None
        self.userName = userName
        self.password = password
        # self.userName = "SISO2"
        # self.password = "Siso@123"
        self.delay = 0.4

    def connect(self):
        if self.con:
            return
        try:
            self.con = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.con.settimeout(self.timeout)
            self.con.connect((self.ip, self.port))
            print("connect ...")
        except Exception as e:
            print(e)
            if self.con:
                self.con.close()
                self.con = None
            raise e

    def disconnect(self):
        try:
            if self.con is None:
                return
            print("disconnect-----")
            self.con.close()
            self.con = None
        except Exception as e:
            print(e)
        finally:
            self.con = None

    def __send(self, cmd, type=1):
        s = None
        try:
            self.con.sendall(cmd.encode())
            if type == 1:
                time.sleep(self.delay)
                s = self.con.recv(1024).decode()
                msgLen = len(s)
                # if ord(s[msgLen - 1]) != 13:
                #    s += self.con.recv(1024)
        except Exception as e:
            print(e)
            # print  "hello"
        return s

    def __print_as_hex(self, msg):
        if msg is None:
            return
        print(msg)
        b = []
        for word in msg:
            b.append(hex(ord(word)))
        print(b)

    def reset(self):
        cmdList = [
            "act-user::%s:1::%s;\n" % (self.userName, self.password),
            "dlt-crs-fiber::all:1;\n",
            "canc-user::%s:end;\n" % self.userName,
        ]
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print("ret::%s" % ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def breakLink(self, links):
        cmdList = []
        cmdList.append("act-user::%s:1::%s;\n" % (self.userName, self.password))
        for link in links:
            cmdList.append(
                "dlt-crs-fiber::%s:1;\n" % (self._formatLinString(link[0], "in"))
            )
            cmdList.append(
                "dlt-crs-fiber::%s:1;\n" % (self._formatLinString(link[1], "in"))
            )

        cmdList.append("canc-user::%s:end;\n" % (self.userName))
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print(ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def breakLink2(self, links):
        cmdList = []
        cmdList.append("act-user::%s:1::%s;\n" % (self.userName, self.password))
        for link in links:
            cmdList.append(
                "dlt-crs-fiber::%s:1;\n" % (self._formatLinString(link[0], "in"))
            )
            cmdList.append(
                "dlt-crs-fiber::%s:1;\n" % (self._formatLinString(link[0], "out"))
            )

        cmdList.append("canc-user::%s:end;\n" % (self.userName))
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print(ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def breakLinkWithCheckStatus(self, links):
        portLinkList = self.queryLinkListStatus(links)
        print("---------------------------------------------------------")
        print(portLinkList)
        print("---------------------------------------------------------")
        if not len(portLinkList):
            return 1
        cmdList = []
        cmdList.append("act-user::%s:1::%s;\n" % (self.userName, self.password))

        for link in portLinkList:
            if link[0] != -1 and link[1] != -1:
                cmdList.append("dlt-crs-fiber::%s:1;\n" % (link[0]))

        cmdList.append("canc-user::%s:end;\n" % (self.userName))
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print(ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def queryPortStatus(self):
        cmdList = []
        cmdList.append("act-user::%s:1::%s;\n" % (self.userName, self.password))
        cmdList.append("rtrv-cfg-fiber::10013&20037:1;\n")
        cmdList.append("rtrv-crs-fiber::10013&20037:1;\n")
        cmdList.append("canc-user::%s:end;\n" % (self.userName))
        for cmd in cmdList:
            now = datetime.datetime.now()
            # formatTime = now.strftime('%Y-%m-%d %H:%M:%S')
            print("Command executing:%s" % cmd)
            ret = self.__send(cmd)
            now = datetime.datetime.now()
            # formatTime = now.strftime('%Y-%m-%d %H:%M:%S:%f')

            print(ret)

            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def parseLink(self, linkString):
        links = []
        linkPairs = linkString.split(";")

        for pair in linkPairs:
            link = pair.split(":")
            checkLen = len(link)

            if checkLen == 1:
                links.append([int(link[0])])
            elif checkLen == 2:
                links.append([int(link[0]), int(link[1])])
            else:
                return None
        return links

    def _formatLinString(self, port, type):
        link = ""
        if type == "in":
            link = "1{:0>4}".format(port)
        elif type == "out":
            link = "2{:0>4}".format(port)
        else:
            raise Exception("The type: %s is not supported" % (type))
        return link

    def _getPortId(self, portId):
        port = str(portId)
        if port[-2] != 0:
            return int(port[-2:])
        else:
            return int(port[-1:])

    def _getLinkPair(self, port1, port2):
        retCode = ""
        retCode = self._formatLinString(port1, "in")
        retCode += ","
        retCode += self._formatLinString(port2, "out")
        return retCode

    # def _getBreakLink(s)

    def setLink(self, links):
        cmdList = []
        cmdList.append("act-user::%s:1::%s;\n" % (self.userName, self.password))
        for link in links:
            cmdList.append(
                "ent-crs-fiber::%s:1;\n" % (self._getLinkPair(link[0], link[1]))
            )
            cmdList.append(
                "ent-crs-fiber::%s:1;\n" % (self._getLinkPair(link[1], link[0]))
            )

        cmdList.append("canc-user::%s:end;\n" % (self.userName))
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print(ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def reboot(self):
        cmdList = [
            "act-user::%s:1::%s;\n" % (self.userName, self.password),
            "init-sys:::1::1;\n",
            "canc-user::%s:end;\n" % (self.userName),
        ]
        for cmd in cmdList:
            print(cmd)
            ret = self.__send(cmd)
            print("ret::%s" % ret)
            if ret is None or ret.find("COMPLD") == -1:
                return -1
        return 0

    def executeCMD(self, cmd):
        print(cmd)
        ret = self.__send(cmd)
        print("ret::%s" % ret)
        if ret is None or ret.find("COMPLD") == -1:
            return [-1, ret]
        return [0, ret]

    def queryLinkListStatus(self, portList):
        cmdList = []
        cmd = "act-user::%s:1::%s;\n" % (self.userName, self.password)
        retList = self.executeCMD(cmd)
        if retList[0] == -1:
            return None
        links = []
        pattern = r"OPORTID=(\d+),"
        outPattern = r"IPORTID=(\d+),"
        for portLink in portList:
            port = self._formatLinString(portLink, "in")
            cmd = "rtrv-crs-fiber::%s:1::;\n" % (port)
            retList = self.executeCMD(cmd)
            if retList[0] == -1:
                return None

            portInfo = retList[1]
            result = re.search(pattern, portInfo)
            if result is None:
                links.append([port, -1])
                continue
            outputPort = result.group(1)
            if outputPort == "0":
                links.append([port, -1])
                continue
            # outputPort = self._getPortId(outputPort)
            links.append([port, outputPort])
        """
        for portLink in portList:
            port = self._formatLinString(portLink[1],"in")
            cmd = "rtrv-crs-fiber::%s:1::;\n"%(port)
            retList = self.executeCMD(cmd)
            if retList[0] == -1:
                return None
            portInfo = retList[1]
            result = re.search(pattern,portInfo)
            if result == None:
                links.append([port,-1])
                continue
            outputPort = result.group(1)
            if outputPort == '0':
                links.append([port,-1])
                continue
            #outputPort = self._getPortId(outputPort)
            links.append([port,outputPort])
        """
        for portLink in portList:
            port = self._formatLinString(portLink, "out")
            cmd = "rtrv-crs-fiber::%s:1::;\n" % (port)
            retList = self.executeCMD(cmd)
            if retList[0] == -1:
                return None

            portInfo = retList[1]
            result = re.search(outPattern, portInfo)
            if result is None:
                links.append([-1, port])
                continue
            inputPort = result.group(1)
            if inputPort == "0":
                links.append([-1, port])
                continue
            # outputPort = self._getPortId(outputPort)
            links.append([inputPort, port])

        cmd = "canc-user::%s:end;\n" % self.userName
        retList = self.executeCMD(cmd)
        return links

    def queryLinkStatus(self, startPort, endPort):
        startpos = int(startPort)
        endPos = int(endPort) + 1

        cmdList = []
        cmd = "act-user::%s:1::%s;\n" % (self.userName, self.password)
        retList = self.executeCMD(cmd)
        if retList[0] == -1:
            return None
        links = []
        pattern = r"OPORTID=(\d+),"
        portList = []
        for i in range(startpos, endPos):
            if i in portList:
                continue

            cmd = "rtrv-crs-fiber::%s:1::;\n" % (self._formatLinString(i, "in"))
            retList = self.executeCMD(cmd)
            if retList[0] == -1:
                return None

            portInfo = retList[1]
            result = re.search(pattern, portInfo)
            if result is None:
                continue
            outputPort = int(result.group(1))
            if outputPort == 0:
                continue
            outputPort = self._getPortId(outputPort)
            links.append([i, outputPort])
            portList.append(outputPort)
        cmd = "canc-user::%s:end;\n" % self.userName
        self.executeCMD(cmd)
        print(links)
        return links


class CALIENT(object):
    def __init__(
        self, ip, port=3082, timeout=20, userName="BTS637", password="Siso2abc123^"
    ):
        self.ip = ip
        self.port = port
        self.timeout = timeout
        self.con = None
        self.userName = userName
        self.password = password
        # self.userName = "SISO2"
        # self.password = "Siso@123"
        self.delay = 0.4

    def connect(self):
        try:
            if self.con:
                return True
            self.con = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.con.settimeout(self.timeout)
            self.con.connect((self.ip, self.port))
            print("connect ...")
        except Exception as e:
            print(e)
            if self.con:
                self.con.close()
                self.con = None
            raise e
        return True

    def disconnect(self):
        try:
            if self.con is None:
                return True
            print("disconnect-----")
            self.con.close()
            self.con = None
        except Exception as e:
            print(e)
        finally:
            self.con = None

    def __send(self, cmd, type=1):
        s = None
        try:
            self.con.sendall(cmd.encode())
            if type == 1:
                # time.sleep(self.delay)
                s = self._receive_data()
                # msgLen = len(s)
                # if ord(s[msgLen - 1]) != 13:
                #    s += self.con.recv(1024)
        except Exception as e:
            print(e)
            # print  "hello"
        return s

    def _receive_data(self):
        s = ""
        while True:
            s += self.con.recv(1024).decode()
            if s.find(";") != -1:
                break
        return s

    def __print_as_hex(self, msg):
        if msg is None:
            return
        print(msg)
        b = []
        for word in msg:
            b.append(hex(ord(word)))
        print(b)

    def _executeCMD(self, cmd):
        print(cmd)
        ret = self.__send(cmd)
        print("ret::%s" % ret)
        if ret is None or ret.find("COMPLD") == -1:
            return [-1, ret]
        return [0, ret]

    def _login(self):
        cmd = "act-user::%s:::%s;" % (self.userName, self.password)
        (retCode, retValue) = self._executeCMD(cmd)
        if retCode != 0:
            raise Exception("authenticate failed!!!!")

    def _logout(self):
        cmd = "CANC-USER;"
        self._executeCMD(cmd)

    def reset(self):
        self._login()
        try:
            cmd = "dlt-crs-all;\n"
            (retCode, retValue) = self._executeCMD(cmd)
            if retCode != 0:
                raise Exception("reset failed!!!!")
        finally:
            self._logout()
        return 0

    def breakLink(self, links):
        self._login()
        cmdList = []
        for link in links:
            cmdList.append("DLT-CRS:::::%s-%s;\n" % (link[0], link[1]))
        try:
            for cmd in cmdList:
                print(cmd)
                ret = self.__send(cmd)
                print(ret)
                if not ret or ret.find("COMPLD") == -1:
                    raise Exception("break link failed!!!")
        finally:
            self._logout()
        return 0

    def breakLink2(self, links):
        return self.breakLinkWithCheckStatus(links)

    def breakLinkWithCheckStatus(self, links):
        portLinkList = self.queryLinkListStatus(links)
        print("---------------------------------------------------------")
        print(portLinkList)
        print("---------------------------------------------------------")
        self._login()
        cmdList = []

        for link in portLinkList:
            if link[2] == 0:
                cmdList.append("DLT-CRS:::::%s-%s;\n" % (link[0], link[1]))
            else:
                cmdList.append("DLT-CRS:::::%s>%s;\n" % (link[0], link[1]))
                # cmdList.append("DLT-CRS:::::%s>%s;\n"%(link[1],link[0]))

        try:
            for cmd in cmdList:
                print(cmd)
                ret = self.__send(cmd)
                print(ret)
                if not ret or ret.find("COMPLD") == -1:
                    raise Exception("break link failed!!!")
        finally:
            self._logout()
        return 0

    def parseLink(self, linkString):
        links = []
        linkPairs = linkString.split(";")

        for pair in linkPairs:
            link = pair.split(":")
            # checkLen = len(link)

            if len(link) == 1:
                links.append([link[0]])
            elif len(link) == 2:
                links.append([link[0], link[1]])
            else:
                raise Exception("link format is not correct!!!")
        return links

    def setLink(self, links):
        self._login()
        cmdList = []
        for link in links:
            cmdList.append("ent-crs-enh::%s,%s;\n" % (link[0], link[1]))
        try:
            for cmd in cmdList:
                print(cmd)
                ret = self.__send(cmd)
                print(ret)
                if not ret or ret.find("COMPLD") == -1:
                    raise Exception("set link failed!!!")
        finally:
            self._logout()
        return 0

    def reboot(self):
        self._login()
        try:
            cmd = "init-sys:::::1"
            (retCode, retValue) = self._executeCMD(cmd)
            if retCode != 0:
                raise Exception("init system failed!!!!")
        finally:
            self._logout()
        return 0

    def queryLinkListStatus(self, portList=None):
        self._login()
        linkPattern = (
            r"([\d|\.]*?)-([\d|\.]*?):SRCPORT=([\d|\.]*?),DSTPORT=([\d|\.]*?),"
        )
        linkPattern2 = (
            r"([\d|\.]*?)>([\d|\.]*?):SRCPORT=([\d|\.]*?),DSTPORT=([\d|\.]*?),"
        )
        portLinkList = {}
        links = []
        try:
            cmd = "RTRV-CRS;"
            retList = self._executeCMD(cmd)
            if retList[0] == -1:
                raise Exception("query link status failed!!!")
            portInfoList = retList[1].split("\r\n")
            for portInfo in portInfoList:
                print("------------------------")
                print(portInfo)
                print("------------------------")
                result = re.search(linkPattern, portInfo)
                if result:
                    srcPort = result.group(3)
                    print(srcPort)
                    dstPort = result.group(4)
                    portLinkList[srcPort] = [dstPort, 0]

                result = re.search(linkPattern2, portInfo)
                if result:
                    srcPort = result.group(3)
                    dstPort = result.group(4)
                    portLinkList[srcPort] = [dstPort, 1]
            if not portList:
                for port in portLinkList.keys():
                    dstPort = portLinkList[port][0]
                    linkType = portLinkList[port][1]
                    links.append([port, dstPort, linkType])
            else:
                # print(portLinkList)
                for port in portList:
                    if isinstance(port, list):
                        port = port[0]
                    for srcPort in portLinkList.keys():
                        dstPort = portLinkList[srcPort][0]
                        if (srcPort == port or dstPort == port) and len(
                            portLinkList[srcPort]
                        ) == 2:
                            links.append([srcPort, dstPort, portLinkList[srcPort][1]])
                            portLinkList[srcPort].append(True)
                            break
        finally:
            self._logout()
        return links

    def flashBreak(self, portList, lowperiod, highperiod):
        self._login()
        cmd = "opR-liNK-FLAP:::::lowperiod=%s,highperiod=%s,repEAT=2,poRTS=" % (
            lowperiod,
            highperiod,
        )
        for port in portList:
            cmd = cmd + port + "&"
        print(cmd)
        try:
            ret = self.__send(cmd + ";\n")
            print(ret)
            if not ret or ret.find("COMPLD") == -1:
                raise Exception("break link failed!!!")
        finally:
            self._logout()
        return 0


def _get_FW_instance(ip, user_name, password, FW_type):
    if FW_type == "GG":
        return GG(ip=ip, userName=user_name, password=password)
    elif FW_type == "CALIENT":
        return CALIENT(ip=ip, userName=user_name, password=password)
    else:
        raise Exception("Not support the FW type!!!")


def set_link(ip, user_name, password, link_list, FW_type="GG"):
    ret_code = -1
    gg = _get_FW_instance(
        ip=ip, user_name=user_name, password=password, FW_type=FW_type
    )
    try:
        gg.connect()
        ret_code = gg.reset()
        if ret_code == 0:
            link_list = gg.parseLink(link_list)
            ret_code = gg.setLink(link_list)
    except Exception as ex:
        print(ex)
        ret_code = -100
    finally:
        gg.disconnect()
    if ret_code != 0:
        raise Exception("set link Failed")


def reset_all_links(ip, user_name, password, ports="", FW_type="GG"):
    ret_code = -1
    gg = _get_FW_instance(
        ip=ip, user_name=user_name, password=password, FW_type=FW_type
    )
    try:
        gg.connect()
        if ports.strip(" ") != "":
            ret_code = gg.breakLinkWithCheckStatus(ports.split(":"))
        else:
            ret_code = gg.reset()
    except Exception as ex:
        print(ex)
        ret_code = -100
    finally:
        gg.disconnect()
    if ret_code != 0:
        raise Exception("reset link Failed")


def break_link(ip, user_name, password, link_list, link_type="pair", FW_type="GG"):
    ret_code = -1
    gg = _get_FW_instance(
        ip=ip, user_name=user_name, password=password, FW_type=FW_type
    )
    try:
        gg.connect()
        link_list = gg.parseLink(link_list)
        if link_type == "pair":
            ret_code = gg.breakLink(link_list)
        else:
            ret_code = gg.breakLink2(link_list)
    except Exception as ex:
        print(ex)
        ret_code = -100
    finally:
        gg.disconnect()
    if ret_code != 0:
        raise Exception("break link Failed")


def connect_link(ip, user_name, password, link_list, FW_type="GG"):
    ret_code = -1
    gg = _get_FW_instance(
        ip=ip, user_name=user_name, password=password, FW_type=FW_type
    )
    try:
        gg.connect()
        link_list = gg.parseLink(link_list)
        ret_code = gg.setLink(link_list)
    except Exception as ex:
        ret_code = -100
        print(ex)
    finally:
        gg.disconnect()
    if ret_code != 0:
        raise Exception("connect link Failed")


def flash_break(ip, user_name, password, portList, lowperiod, highperiod, FW_type="GG"):
    ret_code = -1
    gg = _get_FW_instance(
        ip=ip, user_name=user_name, password=password, FW_type=FW_type
    )
    try:
        gg.connect()
        ret_code = gg.flashBreak(portList, lowperiod, highperiod)
    except Exception as ex:
        print(ex)
        ret_code = -100
    finally:
        gg.disconnect()
    if ret_code != 0:
        raise Exception("break link Failed")


if __name__ == "__main__":
    pass
