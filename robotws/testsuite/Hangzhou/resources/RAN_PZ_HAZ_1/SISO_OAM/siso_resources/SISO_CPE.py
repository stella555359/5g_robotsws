from __future__ import print_function
from __future__ import division
import time
import socket
import urllib
import requests
import re
import traceback
import json
from robot.libraries.Telnet import Telnet
from utils.telnet_common import TelnetCommon
import subprocess
from utils.earfcn import get_band_with_earfcn
from taf.transport.ssh import ssh

"""This file is used to control CPE by send AT command
These keywords can be use in Robot framework.
"""


class CPEBase(object):
    HTTP_PROXY = {"https": "",
                  "http": "",
                  }

    def __init__(self, cpe_type, ip):
        self.cpe_type = cpe_type
        self.cookie_list = {}
        self.is_set_dmz = False
        self.session = None
        self.ip = ip

    def get_cpe_type(self):
        return self.cpe_type

    def release(self):
        pass

    def _get(self, url, data):
        ret_value = None
        try:
            data['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) ' \
                                 'Chrome/78.0.3904.108 Safari/537.36'
            if not self.session:
                self.session = requests.Session()
            resp = self.session.get(url, headers=data, proxies=CPEBase.HTTP_PROXY, timeout=120, verify=False)

            ret_value = resp.text
            ret_code = resp.status_code
        except Exception as e:
            ret_code = -100
            print(e)
        return ret_code, ret_value

    def _post(self, url, data, cookie=None):
        ret_value = None
        header = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                          'Chrome/78.0.3904.108 Safari/537.36'
        }
        try:
            if not self.session:
                self.session = requests.Session()
            resp = self.session.post(url,
                                     headers=header,
                                     data=data,
                                     proxies=CPEBase.HTTP_PROXY,
                                     timeout=120,
                                     verify=False)
            ret_value = resp.text
            ret_code = resp.status_code
            cookie = resp.cookies
        except Exception as e:
            ret_code = -100
            print(e)

        return ret_code, ret_value, cookie

    def ping(self, timeout):
        sb = None
        ret_code = False
        print("start to ping {}".format(self.ip))
        ping_result = re.compile(r'.*from\s+?%s:.*?time[<|=](\d[\.|\d]+)\s+?ms.*' % self.ip)
        # print '.*from\s+?%s:.*?time[<|=](\d[\.|\d]+)\s+?ms.*'%(self.ip)
        ping_ok_count = 0
        try:
            cmd = ["ping".encode(), self.ip.encode()]
            sb = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE)
            start_time = time.time()
            while True:
                output = sb.stdout.readline().decode()
                print(output)
                if ping_result.search(output):
                    ping_ok_count += 1
                    ret_code = True
                else:
                    ping_ok_count = 0
                    ret_code = False

                if ping_ok_count > 5:
                    break
                end_time = time.time()
                if 0 < timeout < (end_time - start_time):
                    break
        except Exception as e:
            print(e)
        finally:
            try:
                if sb:
                    sb.kill()
            except Exception as e:
                print(e)
        return ret_code

    def test_ping(self):
        try_time = 3
        ret_code = False
        while try_time > 0:
            ret_code = self.ping(60)
            if ret_code:
                break
            try_time -= 1
        return ret_code

    def set_dmz(self, ip):
        return 0

    def logout(self):
        try:
            if self.session:
                self.session.close()
        except Exception as ex:
            print(ex)
        finally:
            self.session = None


class ZMTEL(CPEBase):
    ATTACH_STATUS = re.compile(r"\+CGATT:(\d+)")
    IP = re.compile(r"CGPADDR.*\"(\d+\.\d+\.\d+\.\d+)\"")
    RSRP = re.compile(r"RSRP\s\(dBm\)\s:\s([\d|-]+)\s")
    SINR = re.compile(r"SINR\s\(dB\)\s:\s([\d|-]+)\s")
    START_FLAG = re.compile("Serving:")
    UL = re.compile(r"GTPUT:\sUL\s(\d+),(\d+),(\d+)")
    DL = re.compile(r"GTPUT:\sDL\s(\d+),(\d+),(\d+)")
    CEREG = re.compile(r"CEREG:\s+\d,\d,\"\d+\",\"([\d|\w]+)\",")
    PROCESS = re.compile(r"(\d+)\s+(\w+)\s+(\d+)\s+\w+\s+(\w[\w+\s]+\w+)")

    # +CEREG: 2,1,"0297","0009d001",7

    def __init__(self, ip, cpe_type="ZMTEL"):
        super(ZMTEL, self).__init__(cpe_type, ip)
        self.user = "root"
        self.password = "Si8a&2vV9"
        self.conn = None

    def connect_to_cpe(self):
        return self.connect()

    def _kill_related_process(self):
        self.conn.write("ps | grep lted")
        ret = self.conn.read_until_prompt().decode()
        print(ret)
        process_info_list = ret.split("\r\n")
        print(len(process_info_list))
        print(process_info_list)
        process_list = []
        process_name_list = ["lted_defender", "lted mtk", "gct_lted"]
        for process_info in process_info_list:
            result = ZMTEL.PROCESS.search(process_info)
            if result:
                process_id = result.group(1)
                process_name = result.group(4)
                # print process_name
                if process_name in process_name_list:
                    print(process_info)
                    process_list.append(process_id)
        for process_id in process_list:
            cmd = "kill -9 {}".format(process_id)
            self.conn.write(cmd)
            self.conn.read_until_prompt().decode()

    def connect(self):
        ret_code = False
        try:
            host = self.ip
            port = 23
            my_prompt = ["#", "DM>"]
            self.conn = TelnetCommon(host, port, my_prompt)
            self.conn.login(self.user, self.password, ["gdm7243 login:", "OpenWrt login:"],
                            ["password: ", r"Password:\s{0,1}", "Password for .*: ", "ENTER PASSWORD <"])

            self._kill_related_process()

            if self.cpe_type == "ZMTEL":
                self.conn.set_prompt(['gdm7243 login:'])
                self.conn.write("telnet 169.254.0.1")
                ret = self.conn.read_until_prompt()
                print(ret)
                self.conn.set_prompt(["Password:"])
                self.conn.write(self.user)
                self.conn.read_until_prompt()
                self.conn.write(self.password)
                self.conn.set_prompt(my_prompt)

                self.conn.read_until_prompt()

            self.conn.set_prompt(['lted_client_init_ex success'])
            self.conn.write('lted_cli')

            # self.conn.expect(['lted_client_init_ex success'])
            # self.conn.write('\n')

            ret = self.conn.read_until_prompt()
            print(ret)
            if ret.find("lted_client_init_ex success") == -1:
                raise Exception("login failed!!!")
            else:
                print("login ok!!!")
            self.conn.set_prompt(my_prompt)

            self.conn.write('arm1log 2')
            self.conn.write('')
            ret = self.conn.read_until_prompt()
            print("--------------------------------------------")
            print(ret)
            print("--------------------------------------------")
            ret_code = True

        except Exception as ex:
            print(ex)
        finally:
            if self.conn:
                self.conn.close_connection()
                self.conn = None
        return ret_code

    def release(self):
        if self.conn:
            self.conn.close_connection()
            self.conn = None

    def _send_cmd(self, cmd, prompt=None):
        if prompt:
            self.conn.set_prompt(prompt)
        if not self.conn:
            raise Exception("CPE is not at connection status!!!!")
        self.conn.write(cmd)
        return self.conn.read_until_prompt()

    def _send_cmd_without_reply(self, cmd, prompt=None):
        if prompt:
            self.conn.set_prompt(prompt)
        if not self.conn:
            raise Exception("CPE is not at connection status!!!!")
        self.conn.write(cmd)

    def attach(self):
        ret_code = self._send_cmd('at 1', ["INTERFACE READY INDICATION"])
        print("===================================")
        print(ret_code)
        print("===================================")

    def reboot_and_reconnect(self):
        self._send_cmd_without_reply("reboot", ["#"])

        self.test_ping()
        self.connect()
        return 0

    def set_dmz(self, ip, user="superadmin", password="admin"):
        print("login....")

        post_url = 'http://%s/action/login' % self.ip
        print(post_url)
        data = {'username': user, 'password': password, }

        cookie_info = None
        ret_code = -1
        for i in range(3):
            (ret_code, ret_value, cookie_info) = self._post(post_url, data)
            if ret_code == 200:
                break

        if ret_code != 200:
            print("Login fail")
            return -1

        self.cookie_list["cookie"] = cookie_info
        for item in cookie_info:
            self.cookie_list[item.name] = item.value
        print(self.cookie_list)

        (num, val) = ZMTEL.get_params(ip)
        data = {'value': val}
        try:
            post_url = "http://%s/_request.xml?cmd=OAM_MIDWARE_NODEM_SET&node=%s&%s" % (self.ip, num,
                                                                                        urllib.urlencode(data))
            print(post_url)
            self._get(post_url, {})
        except Exception as ex:
            print(ex)
        return 0

    def ps_detach(self):
        ret_code = 0
        try:
            ret_code = self._send_cmd("AT+CGATT=0", [r"PS\sDEACTIVATE\sINDICATION"])
        except Exception as ex:
            print(ex)
        print(ret_code)

    def ps_attach(self):

        cmd = "AT+CGATT?"
        self._send_cmd(cmd, [r"\+CGATT\:\d"])

        # ip = re.findall('\d+\.\d+\.\d+\.\d+', line)[0]

        # '''
        # cmd = 'AT+CFUN=1'
        # retCode = self._send_cmd(cmd,[r"CME\sERROR:"])
        # print "==================================="
        # print retCode
        # print "==================================="
        # '''
        try_count = 0
        attach_status = 0
        while try_count < 3:
            try:
                try_count += 1
                cmd = "AT+CGATT=1"
                ret_code = self._send_cmd(cmd, ["OK.*\n", "ERROR.*\n"])

                print("===================================")
                print(ret_code)
                print("===================================")

                cmd = "AT+CGATT?"
                ret_code = self._send_cmd(cmd, [r"\+CGATT\:\d"])
                result = ZMTEL.ATTACH_STATUS.search(ret_code)
                if result:
                    attach_status = int(result.group(1))
                    if attach_status != 1:
                        print("Check attach status failed for %d time!!!" % try_count)
                    else:
                        print("Attach ok!!!")
                        break
                time.sleep(15)
            except Exception as ex:
                print(ex)

        return attach_status

    def detach(self):
        cmd = "dt 1 0"
        ret_code = self._send_cmd(cmd, ["INTERFACE RELEASE INDICATION"])
        print("===================================")
        print(ret_code)
        print("===================================")

    def lock_cell_and_earfcn(self, band, earfcn, pci):
        cmd = 'AT%GSETSBD=1,{}'.format(band)
        self._send_cmd(cmd, ["RRC Band List SET"])

        cmd = 'AT%GLOCKCELL=1,{},{}'.format(earfcn, pci)
        ret_code = self._send_cmd(cmd, ["RRC Lock Celllist SET"])
        print("===================================")
        print(ret_code)
        print("===================================")

    def get_current_cell_info(self):

        cmd = "AT!GSTATUS"
        ret_code = self._send_cmd(cmd, [r"SINR\s\(dB\).*\n"])
        # '''
        # IP = re.compile("AT+CGPADDR.*\s(\d+\.\d+\.\d+\.\d+)")
        # RSRP = re.compile("RSRP\s\(dBm\)\s:\s([\d|-]+)\s")
        # SINR = re.compile("SINR\s\(dB\)\s:\s([\d|-]+)\s")
        # START_FLAG = re.compile("Serving:")
        # '''
        cell_id = "-1"
        bts_id = "-1"
        rsrp = 0
        sinr = 0

        result = ZMTEL.RSRP.search(ret_code)
        if result:
            rsrp = int(result.group(1))

        result = ZMTEL.SINR.search(ret_code)
        if result:
            sinr = int(result.group(1))

        '''
        lines = retCode.split("\n")
        for line in lines:
            print "-----------------------------"
            print line
            print "-----------------------------"
        '''

        cmd = "AT!LTEINFO"
        ret_code = self._send_cmd(cmd, [r"InterFreq:\sEARFCN"])
        lines = ret_code.split("\n")
        i = 0
        for line in lines:
            i += 1
            if ZMTEL.START_FLAG.search(line):
                if len(lines) > i:
                    cell_id = lines[i].split(" ")[5]
                break
        cmd = "at+cereg?"
        ret_code = self._send_cmd(cmd, [r"CEREG:.*\n"])
        # CEREG = re.compile("CEREG:\s+\d,\d,\"\d+\",\"([0-9|a-f|A-F]+)\",")
        result = ZMTEL.CEREG.search(ret_code)
        if result:
            print("----------------------------")
            print(result.group(1), result.group(0))
            print(ret_code)
            print("----------------------------")
            bts_id = str(int(result.group(1), 16) >> 8)
        print("bts_id= %s,cell_id= %s,RSRP= %d, SINR= %d" % (bts_id, cell_id, rsrp, sinr))
        return bts_id, cell_id, rsrp, sinr

    def get_ip(self):
        cmd = "AT+CGPADDR"
        ret_code = self._send_cmd(cmd, [r'CGPADDR\:.*\n'])
        ip = ""
        result = ZMTEL.IP.search(ret_code)
        if result:
            ip = result.group(1)

        print("IP:%s" % ip)
        return ip

    def get_dongle_ip_address(self):
        return self.get_ip()

    def get_current_tput(self):
        # UL = "GTPUT:\sUL\s\((\d+)\),\((\d+)\),\((\d+)\)"
        # DL = "GTPUT:\sDL\s\((\d+)\),\((\d+)\),\((\d+)\)"
        ul = -1
        dl = -1
        cmd = "at%GTPUT?"
        ret_code = self._send_cmd(cmd, [r'%GTPUT:\sDL.*\n'])
        print("===================================")
        print(ret_code)
        print("===================================")
        result = ZMTEL.UL.search(ret_code)
        if result:
            ul = result.group(1)
        result = ZMTEL.DL.search(ret_code)
        if result:
            dl = result.group(1)
        return ul, dl

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn):
        try:
            cell_id = cell_id[0]
            # self.lock_cell_and_earfcn(band, earfcn, "-1")
            self.lock_cell_and_earfcn(band, earfcn, cell_id)
            self.ps_detach()
            status = self.ps_attach()
            if status != 1:
                print("Attach failed!!!")
                return -1, "Attach failed!!!"
            (current_bts_id, current_cell_id, rsrp, sinr) = self.get_current_cell_info()
            '''
            if current_bts_id != bts_id:

                print ("Current bts is not target bts! %s:%s"%(current_bts_id,bts_id))
                print "Current bts is not target bts! %s:%s"%(current_bts_id,bts_id)
                return (-2,"Current bts is not target bts! %s:%s"%(current_bts_id,bts_id))
            '''
            if current_cell_id != cell_id:
                print("Current cell is not target cell! %s:%s" % (current_cell_id, cell_id))
                return -3, "Current cell is not target cell! %s:%s" % (current_cell_id, cell_id)
            if rsrp < -85:
                print("RSRP is too low!!!%d" % rsrp)
                return -4, "RSRP is too low!!!%d" % rsrp

            self.get_ip()
            # return (0, ip)
            return 0
        except Exception as ex:
            print(ex)
            traceback.print_exc()
            return 1

    @staticmethod
    def _encode_message(text_string):
        haut = 0
        result = ''
        if not text_string:
            return result
        for i in range(len(text_string)):
            b = ord(text_string[i])
            if haut != 0:
                if 0xDC00 <= b <= 0xDFFF:
                    result += hex(0x10000 + ((haut - 0xD800) << 10) + (b - 0xDC00))[2:].upper()
                    haut = 0
                    continue
                else:
                    haut = 0
            if 0xD800 <= b <= 0xDBFF:
                haut = b
            else:
                cp = hex(b)[2:].upper()
                while len(cp) < 4:
                    cp = '0' + cp
                result += cp

        return result

    @staticmethod
    def get_params(ip):
        num = 'N_3_59;N_3_60;N_3_61;'
        val = ZMTEL._encode_message('1') + ';'
        val += ZMTEL._encode_message('0') + ';'
        val += ZMTEL._encode_message(ip) + ';'
        print(val)
        # value = urllib.urlencode(val)
        '''
        data = {"cmd":"OAM_MIDWARE_NODEM_SET", 'value':val,'node':num}
        posturl = "http://%s/_request.xml?%s"%(self.ip,urllib.urlencode(data))
        print posturl
        '''
        return num, val


class ZMTELNew(ZMTEL):
    IP = re.compile(r"(\d+\.\d+\.\d+\.\d+)")

    def __init__(self, ip, cpe_type="ZMTEL"):
        super(ZMTELNew, self).__init__(ip, cpe_type)
        self.current_band = 0

    def connect(self):
        ret_code = False
        try:
            host = self.ip
            port = 23
            my_prompt = ["#", "DM>"]
            self.conn = TelnetCommon(host, port, my_prompt)
            self.conn.login(self.user, self.password, ["gdm7243 login:", "OpenWrt login:"],
                            ["password: ", r"Password:\s{0,1}", "Password for .*: ", "ENTER PASSWORD <"])
            self.conn.set_prompt(my_prompt)
            ret_code = True

        except Exception as ex:
            print(ex)
            if self.conn:
                self.conn.close_connection()
                self.conn = None
        return ret_code

    @staticmethod
    def _print_result(ret_code):
        print("===================================")
        print(ret_code)
        print("===================================")

    def ps_detach(self):
        cmd = "oam-midware set 8 104 off"
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        status = 0
        try_count = 0
        while try_count < 3:
            cmd = "oam-midware get 8 46"
            ret_code = self._send_cmd(cmd)
            ZMTELNew._print_result(ret_code)
            if ret_code.find("no_service") != -1:
                print("Detach ok!!!")
                status = 1
                break
            time.sleep(10)
            try_count += 1
        return status

    def ps_attach(self):
        cmd = "oam-midware get 8 46"
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)

        # ip = re.findall('\d+\.\d+\.\d+\.\d+', line)[0]
        #
        # '''
        # cmd = 'AT+CFUN=1'
        # retCode = self._send_cmd(cmd,["CME\sERROR:"])
        # print "==================================="
        # print retCode
        # print "==================================="
        # '''
        cmd = "oam-midware set 8 104 on"
        ret_code = self._send_cmd(cmd)
        print("===============================")
        print(ret_code)
        print("===============================")

        attach_status = 0
        try_count = 0
        while try_count < 50:
            try:
                try_count += 1
                attach_status = 0

                cmd = "oam-midware get 8 46"
                ret_code = self._send_cmd(cmd)
                ZMTELNew._print_result(ret_code)
                if ret_code.find("disconnected") != -1:
                    pass
                elif ret_code.find("connected") != -1:
                    attach_status = 1
                    print("Attach ok!!!")
                    break
                time.sleep(10)
            except Exception as ex:
                print(ex)

        return attach_status

    def lock_cell_and_earfcn(self, band, earfcn, pci):
        cmd = 'oam-midware set 8 36 "{};"'.format(band)
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)

        cmd = 'oam-midware set 8 76 "{},{};"'.format(earfcn, pci)
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        if ret_code.find("ERR_VALID") != -1:
            cmd = 'oam-midware set  8 37 "{};"'.format(earfcn)
            ret_code = self._send_cmd(cmd)
            ZMTELNew._print_result(ret_code)

    def get_current_cell_info(self):
        cmd = 'oam-midware get 8 35'
        ret_code = self._send_cmd(cmd)  # SINR
        ZMTELNew._print_result(ret_code)

        sinr = int(ret_code.split("\r\n")[1])

        cmd = 'oam-midware get 8 25'  # RSRP0
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        rsrp0 = int(ret_code.split("\r\n")[1])

        cmd = 'oam-midware get 8 26'  # RSRP1
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)

        rsrp1 = int(ret_code.split("\r\n")[1])

        cmd = 'oam-midware get 8 73'  # bts_id
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        bts_id = ret_code.split("\r\n")[1]

        cmd = 'oam-midware get 8 21'  # pci id
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        cell_id = ret_code.split("\r\n")[1]
        # '''
        # IP = re.compile("AT+CGPADDR.*\s(\d+\.\d+\.\d+\.\d+)")
        # RSRP = re.compile("RSRP\s\(dBm\)\s:\s([\d|-]+)\s")
        # SINR = re.compile("SINR\s\(dB\)\s:\s([\d|-]+)\s")
        # START_FLAG = re.compile("Serving:")
        # '''

        print("bts_id= %s,cell_id= %s,RSRP0= %d,RSRP1= %d, SINR= %d" % (bts_id, cell_id, rsrp0, rsrp1, sinr))

        return bts_id, cell_id, rsrp0, rsrp1, sinr

    def get_ip(self):
        cmd = "oam-midware get 3 45"
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        ip = ""
        result = ZMTELNew.IP.search(ret_code)
        if result:
            ip = result.group(1)

        print("IP:%s" % ip)
        return ip

    def check_attach_status(self):
        cmd = "oam-midware get 8 46"
        ret_code = self._send_cmd(cmd)
        ZMTELNew._print_result(ret_code)
        if ret_code.find("disconnected") != -1:
            return -2
        elif ret_code.find("connected") != -1:
            return 1
        elif ret_code.find("no_service") != -1:
            return 0
        else:
            return -1

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn):
        try:
            # self.reboot_and_reconnect()
            cell_id = cell_id[0]
            # self.lock_cell_and_earfcn(band, earfcn, "-1")
            self.lock_cell_and_earfcn(band, earfcn, cell_id)
            self.ps_detach()
            status = self.ps_attach()
            if status != 1:
                print("Attach failed!!!")
                return -1
            time.sleep(20)
            status = self.check_attach_status()
            if status != 1:
                print("UE is not at attach status!!!")
                return -1

            (current_bts_id, current_cell_id, RSRP0, RSRP1, SINR) = self.get_current_cell_info()

            if current_bts_id != bts_id:
                print("Current bts is not target bts! %s:%s" % (current_bts_id, bts_id))
                return -2

            if current_cell_id != cell_id:
                print("Current cell is not target cell! %s:%s" % (current_cell_id, cell_id))
                return -3
            if RSRP0 < -85 and RSRP1 < -85:
                print("RSRP is too low!!!%d:%d" % (RSRP0, RSRP1))
                return -4

            time.sleep(1)
            self.get_ip()
            return 0
        except Exception as ex:
            print(ex)
            traceback.print_exc()
            return 1


def resolve_unstable(fun):
    def wrap(*args, **kwargs):
        ret_code = fun(*args, **kwargs)
        if ret_code == 500:
            print("Try to recover. Then to attach again!!!")
            ret_code = fun(*args, **kwargs, reboot=True)
        return ret_code
    return wrap


def try_twice(fun):
    def wrap(*args, **kwargs):
        ret_code = fun(*args, **kwargs)
        if ret_code != 0:
            print("Sleep 10s. Try twice!!!")
            time.sleep(10)
            ret_code = fun(*args, **kwargs)
        return ret_code
    return wrap


class Gemtek(CPEBase):
    def __init__(self, ip, lte_core="Sequans"):
        super(Gemtek, self).__init__("Gemtek", ip)
        self.count = 0
        self.lte_core = lte_core
        self.URL = "http://{}/cgi-bin/sysconf.cgi".format(self.ip)

    def logout(self):
        print("logout....")
        post_url = '%s?page=ajax.asp&action=logout&userlevel=%s&timestamp=1450680666794' % \
                   (self.URL, self.cookie_list["userlevel"])
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {})
        super(Gemtek, self).logout()
        if ret_code != 200:
            print("Login out fail")
            return -1
        return 0

    def reboot(self):
        print("reboot...")
        post_url = \
            '%s?page=ajax_check.asp&action=reboot&reason=1&sid=%s&timestamp=1450680666794' % \
            (self.URL, self.cookie_list["sid"])
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {})
        if ret_code != 200:
            print("Reboot fail")
            return -1
        time.sleep(80)
        return 0

    @staticmethod
    def _sub_string(info):
        start_pos = info.find("\"")
        end_pos = info.find("\"", start_pos + 1)
        return info[start_pos + 1:end_pos]

    @resolve_unstable
    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn, reboot=False):
        if not self.count or reboot:
            ret_code = self.login("administrator", "administrator")
            self.count = 1
            if ret_code != 0:
                print("Login fail!!!:%d" % ret_code)
                return ret_code
            self.reboot()
            self.logout()
        self.count = (self.count+1) % 5

        ret_code = self.login("administrator", "administrator")
        if ret_code != 0:
            print("Login fail!!!:%d" % ret_code)
            return ret_code
        ret_code = self.lock_cell(earfcn, cell_id[0])
        if ret_code != 0:
            print("Lock cell fail!!!%d" % ret_code)
            self.logout()
            return 500
        if len(cell_id) == 1:
            ret_code = self.lock_earfcn(earfcn, band)
            if ret_code:
                print("Select cell fail!!!%d" % ret_code)
                self.logout()
                return 500

            ret_code = self.start_and_stop_lte()
            if ret_code:
                print("Reboot LTE fail!!!%d" % ret_code)
                self.logout()
                return 500

            print("Reboot LTE  Ok!!!")
        # else:
        #     ret_code = self.reboot()
        #     if ret_code:
        #         print("Reboot fail!!!%d" % ret_code)
        #         return ret_code
        #     ret_code = self.login("administrator", "administrator")
        #     if ret_code:
        #         print("Login fail!!!:%d" % ret_code)
        #         return ret_code
        ret_code = 1
        try_time = 12
        while try_time > 0:
            (attach_code, info) = self._get_attach_status()
            print(attach_code)
            if not attach_code:
                c_bts_id = info[0]
                c_cell_id = info[1]
                # c_u_rate = info[2]
                # c_d_rate = info[3]
                s_cell_id = info[4]
                print("-------------------------------")
                print(c_bts_id + ":" + bts_id)
                print(c_cell_id + ":" + cell_id[0])
                print("-----------------------------------")
                if c_bts_id == bts_id and c_cell_id == cell_id[0]:
                    if len(cell_id) >= 2 and s_cell_id not in cell_id[1:]:
                        pass
                    else:
                        ret_code = 0
                        break
            print("Wait for 10 sec,try to get status again!!!")
            time.sleep(10)
            try_time -= 1
        self.logout()
        return ret_code

    def get_tput(self, bts_id, cell_id, during=10):
        ret_code = self.login("administrator", "administrator")
        if ret_code:
            raise Exception("Login fail!!!:%d" % ret_code)

        start_time = time.time()
        uplink_rates = []
        downlink_rates = []
        while True:
            time.sleep(1)
            try:
                (retCode, info) = self._get_attach_status()
                if not retCode:
                    c_bts_id = info[0]
                    c_cell_id = info[1]
                    c_u_rate = info[2]
                    c_d_rate = info[3]
                    s_cell_id = info[4]
                    if c_bts_id != bts_id or c_cell_id != cell_id[0] or (len(cell_id) >= 2 and s_cell_id
                                                                         not in cell_id[1:]):
                        print("The UE is not attach to the correct cell {}:{}!!!".format(c_cell_id, cell_id[0]))
                        return -1, -1
                    uplink_rates.append(float(c_u_rate))
                    downlink_rates.append(float(c_d_rate))
            except Exception as ex:
                print(ex)
            current_time = time.time()
            if (current_time - start_time) > during * 2:
                break
        self.logout()
        if len(uplink_rates) < during / 2:
            print("The rate samples is not enough!!!!")
            return -1, -1
        return sum(uplink_rates) / len(uplink_rates), sum(downlink_rates) / len(downlink_rates)

    @try_twice
    def login(self, user, password):
        print("login....")

        post_url = '%s?page=login.asp&action=login' % self.URL
        print(post_url)
        data = {'user_name': user, 'user_passwd': password, }
        ret_code = -1
        cookie_info = None
        (ret_code, ret_value, cookie_info) = self._post(post_url, data)

        if ret_code != 200:
            print("Login fail")
            return -1

        self.cookie_list["cookie"] = cookie_info
        for item in cookie_info:
            self.cookie_list[item.name] = item.value
        print(self.cookie_list)

        return 0

    def _get_attach_status(self):
        print("get attach status...")
        post_url = '%s?page=ajax.asp&action=status_wanInfo&timestamp=1450680666794' % self.URL
        # cookie_list["cookie"].set_cookie(make_cookie("page", "llmobile_status.asp&,lte,0,undefined"))
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"),
                                         {"sid": self.cookie_list["sid"]})
        if ret_code != 200:
            print("Get response fail!!!!")
            return -10, None
        print(ret_info)
        second_cell_info = None
        info_list = ret_info.split(";")
        general = info_list[0].split("\t")
        want_info = info_list[1].split("\t")
        up_down_link = info_list[2].split("\t")
        print(general)
        if len(info_list) == 4:
            second_cell_info = info_list[3].split("\t")

        if general[0] != "Successfully":
            print("Get info unsuccessfully!!!")
            return -1, None
        elif general[1] != "5":
            print("CPE status is connectting...")
            return 1, None

        current_scan_mode = general[4]
        print("CPE status is connected")
        print("Network Operator:%s" % (general[2]))
        if general[3] != "LTE":
            print("The technology is not LTE:%s" % (general[3]))
            return 2, None

        elif want_info[0] == "not value":
            print("The lte status is invalid!!!")
            return 3, None
        elif current_scan_mode != "1":
            print("Scan mode is invalid!!!")
            return 4, None
        elif want_info[0] != "Sequans":
            print("The ue is from Sequans!!!")
            return 5, None
        elif want_info[1] != "5":
            print("The cpe is not in attach status!!!")
            return 6, None
        print("DL Frequency:%s kHz;UL Frequency:%skHz" % (want_info[3], want_info[2]))
        print("Bandwidth:%skHz;RSRP0:%sdBm" % (want_info[4], want_info[5]))
        print("RSRP1:%sdBm;RSRQ:%sdB" % (want_info[6], want_info[7]))
        print("CINR0:%sdB;CINR1:%sdB" % (want_info[8], want_info[9]))
        print("TX Power:%s;PCI:%s" % (want_info[10], want_info[11]))

        # print "TX Power:%sdBm;PCI:%s"%(wantInfo[13],wantInfo[14])
        print("Bts Id:%s" % (want_info[17]))
        print("Uplink Rate:%s kbps;Downlink Rate:%s kbps" % (up_down_link[0], up_down_link[3]))
        rsrp_0 = -127
        rsrp_1 = -127
        try:
            rsrp_0 = int(want_info[5])
        except Exception as ex:
            print(ex)
        try:
            rsrp_1 = int(want_info[6])
        except Exception as ex:
            print(ex)

        second_cell = None

        if len(info_list) >= 4:
            second_cell_info = info_list[3].split(",")
            if len(second_cell_info) >= 3:
                second_cell = second_cell_info[1]
                print("scell id:%s" % second_cell)

        if rsrp_0 < -85 and rsrp_1 < -85:
            return 8, None
        return 0, (want_info[17], want_info[11], up_down_link[0], up_down_link[3], second_cell)

    def lock_cell(self, earfcn, cell_id):
        print("lock cell....")
        post_url = '%s?page=lte_cell_lock.asp&action=request&sid=%s&user level=%s&timestamp=14533' \
                   % (self.URL, self.cookie_list["sid"], self.cookie_list["userlevel"])

        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {})
        if ret_code != 200:
            print("Get lte_cell_lock.asp fail!!!")
            return 1

        index = ret_info.find('name="confirm_code"')
        if index == -1:
            print("Can not find confirm code 1!!!")
            return 2

        temp_info = ret_info[index:index + 50]
        print(temp_info)
        index = temp_info.find("value=")
        if index == -1:
            print("Can not find confirm code2!!!")
            return 3

        print(temp_info[index:])
        confirm_code = Gemtek._sub_string(temp_info[index:])
        print("confirmCode : %s" % confirm_code)
        # tempInfo[index:index+50].find
        post_url = '%s?page=lte_cell_lock.asp&sid=%s' % (self.URL, self.cookie_list["sid"])
        data = {'confirm_code': confirm_code, 'LTE_RequiredCellList': "%s,%s" % (earfcn, cell_id),
                'lockDLearfcn_0': earfcn,
                "lockPCI_0": cell_id
                }

        (ret_code, ret_value, cookie) = self._post(post_url, data, self.cookie_list["cookie"])
        if ret_code != 200:
            print("lock cell fail!!!")
            return 4
        return 0

    def lock_earfcn(self, earfcn, band):
        print("select cell....")
        post_url = '%s?page=lte_cell_selection.asp&action=request&sid=%s&user level=%s&timestamp=1450680666794' \
                   % (self.URL, self.cookie_list["sid"], self.cookie_list["userlevel"])
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {})
        if ret_code != 200:
            print("Get lte_cell_lock.asp fail!!!")
            return 1

        index = ret_info.find('name="confirm_code"')
        if index == -1:
            print("Can not find confirm code 1!!!")
            return 2

        temp_info = ret_info[index:index + 50]
        print(temp_info)
        index = temp_info.find("value=")
        if index == -1:
            print("Can not find confirm code2!!!")
            return 3

        print(temp_info[index:])
        confirm_code = Gemtek._sub_string(temp_info[index:])
        print("confirmCode : %s" % confirm_code)

        post_url = '%s?page=lte_cell_selection.asp&sid=%s' % (self.URL, self.cookie_list["sid"])
        data = {'confirm_code': confirm_code, 'LTE_Band': "%s" % (str(band)), 'LTE_DL_Earfcn': earfcn,
                "lte_dl_freq_earfcn": "0", "lte_scan_mode": "0", "LTE_UL_Earfcn": earfcn, "rat_ant_selection": "1",
                "ui_mid": "WLTFSM-136ACN", "wifi_AutoChannelSkipList": "", "wifi_channel_check": ""}

        (ret_code, ret_value, cookie) = self._post(post_url, data, self.cookie_list["cookie"])
        if ret_code != 200:
            print("cell selection fail!!!")
            return 4
        return 0

    def set_dmz(self, ip):
        print("set dmz")
        if self.is_set_dmz:
            return 0
        self.login("administrator", "administrator")
        ret_code = self._set_dmz(ip)
        self.logout()
        if not ret_code:
            self.is_set_dmz = True
        return ret_code

    def _set_dmz(self, ip):
        post_url = '%s?page=network_firewall.asp&action=request&sid=%s&user level=%s&timestamp=1450680666794' % (
            self.URL, self.cookie_list["sid"], self.cookie_list["userlevel"])

        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {})
        if ret_code != 200:
            print("Get lte_cell_lock.asp fail!!!")
            return 1

        index = ret_info.find('name="confirm_code"')
        if index == -1:
            print("Can not find confirm code 1!!!")
            return 2

        temp_info = ret_info[index:index + 50]
        print(temp_info)
        index = temp_info.find("value=")
        if index == -1:
            print("Can not find confirm code2!!!")
            return 3

        print(temp_info[index:])
        confirm_code = Gemtek._sub_string(temp_info[index:])
        print("confirmCode : %s" % confirm_code)

        ip_data = ip.split(".")[-1]

        post_url = '%s?page=network_firewall.asp&sid=%s' % (self.URL, self.cookie_list["sid"])

        # FirewallEnable: disable
        # ui2_wan_ping: on
        # ui_wan_ping: enable
        # WebLoginEnable: disable
        # https_port: 8080
        # ui_https_port: 8080
        # ui_dmz_enable: on
        # dmz_enable: enable
        # dmz_ip: 2
        # dmz_ip_data: 2
        # ui_icmp_redirection: disable
        # igmp_multicast_filter: disable
        # UPnPEnable: disable
        data = {'confirm_code': confirm_code, 'FirewallEnable': "disable", 'ui2_wan_ping': "on",
                "ui_wan_ping": "enable", "WebLoginEnable": "disable", "https_port": "8080", "ui_https_port": "8080",
                "ui_dmz_enable": "on", "dmz_enable": "enable", "dmz_ip": ip_data, "dmz_ip_data": ip_data,
                "ui_icmp_redirection": "disable", "igmp_multicast_filter": "disable", "UPnPEnable": "disable"}

        (retCode, retValue, cookie) = self._post(post_url, data, self.cookie_list["cookie"])
        if retCode != 200:
            print("cell selection fail!!!")
            return 4

        return 0

    def start_and_stop_lte(self):
        post_url = '%s?page=ajax.asp&action=tag_stopSs_lte&timestamp=1450680666794' % (
            self.URL)
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {"sid": self.cookie_list["sid"]})
        self.logout()
        print(ret_info)
        if ret_code != 200:
            print("Stop LTE fail")
            return -1
        time.sleep(5)
        self.login("administrator", "administrator")
        post_url = '%s?page=ajax.asp&action=tag_startSs_lte&timestamp=1450680666794' % (
            self.URL)
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {"sid": self.cookie_list["sid"]})
        if ret_code != 200:
            print("Start LTE fail")
            return -1
        time.sleep(5)
        print("Reboot LTE ok!!!")
        return 0

    def get_dongle_ip_address(self):
        print("get ip...")
        post_url = '%s?page=ajax.asp&action=status_device&sid=%s&timestamp=1450680666794' % \
                   (self.URL, self.cookie_list["sid"])
        # cookie_list["cookie"].set_cookie(make_cookie("page", "lmobile_status.asp&,lte,0,undefined"))
        (ret_code, ret_info) = self._get(post_url.replace(" ", "%20"), {"sid": self.cookie_list["sid"]})
        print(ret_info)
        if ret_code != 200:
            print("Request fail!!!")
            return None
            # return (1,None)
        print(ret_info)
        ip_info_list = ret_info.split(",")
        if ip_info_list[0].lower() != "successfully":
            print("Get info unsuccessfully!!!")
            return None
        ip = ip_info_list[1]
        return ip

    @staticmethod
    def _print_as_hex(msg):
        b = []
        for s in msg:
            b.append(hex(ord(s)))
        print(b)

    def get_ue_status(self):
        cmd = "\x01\x05\x00\x0d\x90\x08\x01\x00\x40\x00\x1f\xa3\x00\x00\x00\x00\x72\x72\x63\x3a\x53" \
              "\x68\x6f\x77\x53\x74\x61\x74\x00"
        con = None
        rrc_info = None
        try:
            con = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            con.settimeout(10)
            con.connect((self.ip, 7772))
            ret = con.recv(1024).decode()
            while len(ret) < 4:
                ret += con.recv(1024).decode()
            header = "\x01\x05"
            index = ret.find(header)
            if index == -1:
                raise Exception("Find package header fail!!!")
            packet_len = len(ret)
            msg_len = ord(ret[index + 2]) * 256 + ord(ret[index + 3])
            print(msg_len)
            while (packet_len - 16) != msg_len:
                ret += con.recv(msg_len + 16 - packet_len).decode()
                packet_len = len(ret)
            print(ret)

            con.sendall(cmd)
            ret = con.recv(1024).decode()
            while len(ret) < 4:
                ret += con.recv(1024).decode()
            # self._print_as_hex(ret)
            # header = "\x01\x05"
            index = ret.find(header)
            if index == -1:
                raise Exception("Find package header fail!!!")
            packet_len = len(ret)
            msg_len = ord(ret[index + 2]) * 256 + ord(ret[index + 3])
            print(msg_len)
            while (packet_len - 16) != msg_len:
                ret += con.recv(msg_len + 16 - packet_len).decode()
                packet_len = len(ret)
            print(ret)
            # __print_as_hex(ret)
            rrc_info = ret[20:].split("\n")
            print(rrc_info)

        except Exception as e:
            print(e)
        finally:
            if con:
                con.close()
        random_access_count = -1
        if rrc_info:
            for i in range(len(rrc_info)):
                if rrc_info[i].find("RANDOM ACCESS") != -1 and rrc_info[i + 1].find("complete") != -1:
                    random_access = rrc_info[i + 1].split(":")
                    if len(random_access) == 2:
                        random_access_count = int(random_access[1].strip(" "))
        print("RANDOM ACCESS complete:%d" % random_access_count)
        return random_access_count


class Deming(CPEBase):
    def __init__(self, ip):
        super(Deming, self).__init__("Deming", ip)
        self.retry_time = 3
        self.timeout = 30
        self.pause_time = 2
        self.attach_count = 0
        self.con = None
        print("DeMing CPE started:", self.ip)

    def disconnect(self):
        try:
            if self.con:
                self.con.close()
                self.con = None
        except Exception as ex:
            print(ex)

    def release(self):
        self.disconnect()

    def connect_to_cpe(self):
        ret_code = False
        try:
            if self.con:
                return True
            self.con = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.con.settimeout(self.timeout)
            self.con.connect((self.ip, 9001))
            result = self._execute_at_command("ATBEGIN=1")
            print(result)
            if result == 0:
                print("socket connect succeed!")
                ret_code = True
            else:
                raise Exception("AT begin failed!!!!")
        except Exception as e:
            print("Error: ", e)
        finally:
            if not ret_code and self.con:
                self.con.close()
                self.con = None
        return ret_code

    def __send_cmd(self, cmd):
        s = ''
        self.retry_time = 3
        print("-------command: %s-----------" % cmd)
        while self.retry_time > 0:
            if not self.con:
                raise Exception("socket is not exists!")
            self.con.sendall(cmd.encode())
            print("command(%ss): %s" % ((4 - self.retry_time), cmd))
            #
            try:
                s = self.con.recv(1024).decode()
                while "ERROR" not in s and "OK" not in s:
                    s += self.con.recv(1024).decode()
            except Exception as e:
                print("*WARN* ", e)
                self.retry_time -= 1
                continue  # make sure if s is None continue next loop.
            print("response(%ss): %s" % ((4 - self.retry_time), s))
            if "ERROR" in s:
                self.retry_time -= 1
                s = ''
                time.sleep(self.pause_time)
            else:
                break
        return s

    def execute_at_command(self, at_cmd):
        ret = ''
        try:
            ret = self.__send_cmd(at_cmd)

        except Exception as e:
            print("*WARN* Exec AT cmd \"%s\" failed with error: %s" % (at_cmd, e))
        finally:
            return ret

    def _execute_at_command(self, at_cmd):
        try:
            ret = self.__send_cmd(at_cmd)
            if "OK" not in ret:
                return 1
            return 0
        except Exception as e:
            print("*WARN* Exec AT cmd \"%s\" failed with error: %s" % (at_cmd, e))
        finally:
            pass
        return -2

    def dongle_reboot(self, at_cmd="ATREBOOT"):
        ret = self.__send_cmd(at_cmd)
        if 'OK' in ret:
            pass
        else:
            return self.reboot()

        print("command(1s): %s" % at_cmd)
        # self.logger.info('Try to ping cpe!!!')
        time.sleep(5)
        # self.logger.info("command(1s): %s" % (at_cmd))
        ret_code = self.test_ping()

        if ret_code == 1:
            print('fail to reboot cpe!!!')
        else:
            time.sleep(5)
            # self.logger.info('fail to reboot cpe!!!')
        self.disconnect()
        return ret_code

    def dongle_attach(self, at_cmd="AT+CGATT=1"):
        try:
            self._execute_at_command('AT+CFUN=1')
            ret_code = self._execute_at_command(at_cmd)
            if not ret_code:
                print("cpe_attach succeed!")
        finally:
            pass
        return ret_code

    def set_dmz(self, ip):
        if self.is_set_dmz:
            return 0
        url = "http://%s/goform/DMZ" % self.ip
        print(url)
        data = {'DMZEnabled': '1',
                'DMZAddress': ip,
                'DMZTCPPort80': '0',
                'addDMZ': 'Apply'
                }
        (ret_code, ret_value, cookie) = Deming._authenticate(url, 'admin', 'admin', data)
        print(ret_code)
        print(ret_value)
        if ret_code != 200:
            return -1
        # print (retCode,retValue,cookie)
        self.is_set_dmz = True
        return 0

    @staticmethod
    def _authenticate(url, username, password, data):
        try:
            # cookie = cookielib.CookieJar()
            # password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
            # password_mgr.add_password(None, url, username, password)
            # handler = urllib2.HTTPBasicAuthHandler(password_mgr)
            # nullproxy_handler = urllib2.ProxyHandler({})
            # opener = urllib2.build_opener(handler,nullproxy_handler,urllib2.HTTPCookieProcessor(cookie))
            # data = urllib.urlencode(data)
            # opener.open(url)
            # # use the opener to fetch a URL
            # urllib2.install_opener(opener)
            # resp = urllib2.urlopen(url,data)
            resp = requests.post(url, data=data, auth=(username, password))
            ret_value = resp.text
            ret_code = resp.status_code
            cookie = resp.cookies
            return ret_code, ret_value, cookie
        finally:
            pass

    def dongle_detach(self, at_cmd="AT+CGATT=0"):
        ret_code = self._execute_at_command(at_cmd)
        if not ret_code:
            print("cpe_detach succeed!")
        elif ret_code == 1:
            print("*WARN* cpe_detach failed!")
        return ret_code

    def logout(self):
        pass

    def reboot(self):
        user = 'admin'
        password = 'admin'
        # myprompt = [ "#"]

        tel_conn = Telnet()
        try:
            tel_conn.open_connection(self.ip,
                                     port=23,
                                     timeout=20,
                                     prompt='#',
                                     prompt_is_regexp=True)
            tel_conn.login(user,
                           password,
                           password_prompt='ssword:')

            print('telnet %s ok, start to send reboot...' % self.ip)
            print(tel_conn.execute_command('reboot'))
        except Exception as ex:
            print(ex)
        finally:
            tel_conn.close_connection()
        time.sleep(5)
        ret_code = 1
        retry_time = 4
        while retry_time > 0:
            if self.ping(30):
                print('cpe_reboot succeed!')
                ret_code = 0
                break
            retry_time -= 1
            time.sleep(10)
        if ret_code == 1:
            print('fail to reboot cpe!!!')
        else:
            time.sleep(25)
            # self.logger.info('fail to reboot cpe!!!')
        self.disconnect()

        return ret_code

    def reboot_and_reconnect(self):
        ret_code = self.reboot()
        if not ret_code and not self.connect_to_cpe():
            ret_code = 9
        return ret_code

    @staticmethod
    def convert_41_to_38(band, earfcn, current_band):
        if band == 41 and current_band != str(band):
            map_earfcn = int(earfcn) - 2640
            # 37750 <= earfcn < 38250
            if map_earfcn < 37750 or map_earfcn >= 38250:
                return -1, earfcn
            else:
                return 38, str(map_earfcn)
        else:
            return band, earfcn

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn):
        cell_id = cell_id[0]
        current_band = self.get_dongle_bandwidth()

        if not current_band or self.attach_count == 0:
            ret_code = self.reboot_and_reconnect()
            if ret_code:
                return ret_code
            # if self.reboot() != 0 :
            #     print "Reboot cpe Fail!!!"
            #     return -9
            # if self.connect_to_cpe() != True:
            #     print "Connect CPE Fail!!!"
            #     return 5

            current_band = self.get_dongle_bandwidth()

            if not current_band:
                print("Can not get cpe band config!!!")
                return -10
        self.attach_count = (self.attach_count + 1) % 4

        (band, earfcn) = Deming.convert_41_to_38(band, earfcn, current_band)
        print("Convert band:%d,earfcn:%s:%s" % (band, earfcn, self.attach_count))
        if band == -1:
            print("Convert band 41 to 38 fail!!!!")
            return -11
        print(current_band)
        if current_band != str(band):
            # self.dongle_reboot()
            if self.set_dongle_bandwidth(band):
                return 1
            if self.reboot():
                print("Reboot cpe Fail!!!")
                return -9
            if not self.connect_to_cpe():
                print("Connect CPE Fail!!!")
                return 5
        else:
            print("when try to initialize, check bts cell id !!!!!")
            attach_info = self.get_attached_btscell_id()
            print(attach_info[0])
            attach_cell_id = attach_info[0]
            if attach_cell_id is None:
                return 10
            current_earfcn = attach_info[1]
            (bts, cell) = attach_cell_id.split('/')
            if current_earfcn is not None and earfcn != "" and earfcn != current_earfcn:
                pass
            elif attach_cell_id is None or cell == cell_id:
                pass
            elif band == 41:
                if self.reboot() != 0:
                    print("Reboot cpe Fail!!!")
                    return -9
                if not self.connect_to_cpe():
                    print("Connect CPE Fail!!!")
                    return 5
            else:
                set_band = band + 1
                if band > 38:
                    set_band = band - 1
                if self.set_dongle_bandwidth(set_band) != 0:
                    return 1
                if self.reboot() != 0:
                    print("Reboot cpe Fail!!!")
                    return -9
                if not self.connect_to_cpe():
                    print("Connect CPE Fail!!!")
                    return 5
                if self.set_dongle_bandwidth(band) != 0:
                    return 1
                if self.reboot() != 0:
                    print("Reboot cpe Fail!!!")
                    return -9
                if not self.connect_to_cpe():
                    print("Connect CPE Fail!!!")
                    return 5
                time.sleep(1)

        current_earfcn = self.get_dongle_earfcn()
        if current_earfcn and current_earfcn == earfcn:
            pass
        elif earfcn != '' and self.set_dongle_earfcn(earfcn) != 0:
            return 4

        ret_code = self.check_dongle_attach_status()
        print(ret_code)
        ip = self.get_dongle_ip_address()
        print(ip)

        if ret_code == 0:
            self.dongle_detach()
            time.sleep(2)
        retry_time = 3

        attach_done = False
        for i in range(0, retry_time):
            timeout = 10 + i * 5
            print("wait for %d seconds,and then try to attach..." % timeout)
            time.sleep(timeout)
            if self.dongle_attach() == 0:
                attach_done = True
                break

        if not attach_done:
            return 3

        print("attach and check bts cell id !!!!!")
        ip = self.get_dongle_ip_address()
        print(ip)
        attach_cell_id = self.get_attached_btscell_id()
        print(attach_cell_id)

        if not attach_cell_id:
            return 7
        (bts, cell) = attach_cell_id[0].split('/')
        if cell != cell_id:
            return 6
        (ret_code, rssi) = self.get_csq()
        if ret_code == 0 and rssi > 80:
            print("The signal rssi is too low!!!!")
            return 8
        return 0

    def get_csq(self):
        at_cmd = "AT%CSQ"
        real_rssi = 113
        ret = self.execute_at_command(at_cmd)
        print(ret)
        if 'OK' not in ret:
            return -1, real_rssi
        result = re.search(r'%CSQ:\s*(\d+)\s*,\s*\d*\s*,\s*(\d*)', ret)
        if not result:
            return -2, real_rssi
        try:
            rssi = int(result.group(1))
            rsrq = int(result.group(2))
            if rssi == 99:
                print("No signal!!!")
            else:
                real_rssi = 113 - (rssi * 2)
                print("Signal: -%d dbm,Signal RSRQ:%d" % (real_rssi, rsrq))
        except Exception as ex:
            print(ex)
            return -3, real_rssi
        return 0, real_rssi

    def get_dongle_earfcn(self):
        ret = self.execute_at_command("at%earfcn?")
        if not ret:
            return None
        earfcn = None
        res_result = re.search(r"EARFCN:(\d+)", ret)
        if res_result:
            earfcn = res_result.group(1)
        return earfcn

    def check_dongle_attach_status(self, at_cmd="AT+CGATT?"):
        """This keyword used for execute attach AT command to UE by Telnet.

        Example
        | Check Dongle Attach Status |
        """
        ret = self.execute_at_command(at_cmd)
        if re.search(".*CGATT: 1.*", ret):
            return 0
        else:
            return 1

    def get_dongle_ip_address(self, at_cmd="AT+CGPADDR"):
        """This keyword used for execute attach AT command to UE by Telnet.

        Example
        | Get Dongle IP address |
        """
        """
        '\n\n+CGPADDR: 1,"10.68.191.153"\n\n\n\nOK\n\n'
        """
        ip_addr = None
        try:
            # for i in range(self.retry_time):
            ret_code = self.execute_at_command(at_cmd)
            if not ret_code:
                print("None info retruned")
                return ip_addr
            if "+CGPADDR" not in ret_code:
                return ip_addr
            ip_pattern = r"((25[0-5]|2[0-4]\d|[01]?\d\d?)\." \
                         r"(25[0-5]|2[0-4]\d|[01]?\d\d?)" \
                         r"\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?))"

            res_search = re.search(ip_pattern, ret_code)
            if res_search:
                ip_addr = res_search.group(1)
                return ip_addr
        except Exception as e:
            print("Try to get CPE IP address failed")
            print(e)
        finally:
            return ip_addr

    def get_attached_btscell_id(self, at_cmd="AT%PCONI"):
        """
        'duplexing mode: TDD\n\nTransmission mode: Open loop MIMO\n\nBandwidth: 3\n\nEARFCN: 38000\n\n
        Global Cell ID: 00002E01\n\nPhysical Cell ID: 11\n\nOK\n\n'
        """
        bts_cell_id = None
        earfcn = None
        try:
            # for i in range(self.retry_time):
            ret = self.execute_at_command(at_cmd)
            if not ret:
                return bts_cell_id
            if "Global Cell ID" not in ret:
                return bts_cell_id

            result = re.search(r'Global Cell ID:\s(.*)\n', ret)
            if result:
                global_cell_id = int(result.group(1), 16)
                bts_id = global_cell_id / 256
            result = re.search(r'Physical Cell ID:\s(.*)\n', ret)
            if result:
                cell_id = int(result.group(1))
            bts_cell_id = "%d/%d" % (bts_id, cell_id)
            print("UE has found the BTS/CELL \"%s\"" % bts_cell_id)
            result = re.search(r'EARFCN:\s*(\d*)', ret)
            if result:
                earfcn = result.group(1)
        except Exception as e:
            print("Try to get attached bts and cell id failed")
            print(e)
        finally:
            return [bts_cell_id, earfcn]

    def get_dongle_bandwidth(self, at_cmd="AT%GETCFG=\"BAND\""):
        """
        '\n\nBands:  38\n\n\n\nOK\n\n'"""
        print("start to get bandwidth!!!")
        result = None
        try:
            # for i in range(self.retry_time):
            ret = self.execute_at_command(at_cmd)
            if not ret:
                return result
            res_result = re.search(r".*Bands:\s+(\d+).*", ret, re.I)
            if res_result:
                result = res_result.group(1)
        except Exception as e:
            print("Try to get dongle bandwidth failed")
            print(e)
        finally:
            return result

    def set_dongle_bandwidth(self, band=38):
        result = 1
        try:
            print(band)
            at_cmd = 'AT%SETCFG="BAND","' + str(band) + '"'
            print(at_cmd)
            # at_cmd = "AT\%SETCFG=\"BAND\",\"%d\""%(band)
            # for i in range(self.retry_time):
            result = self._execute_at_command(at_cmd)

        except Exception as e:
            print("Try to set dongle bandwidth failed")
            print(e)
        finally:
            return result

    def set_dongle_earfcn(self, earfcn):
        if earfcn == '':
            return 0
        result = 1
        try:
            self.execute_at_command("at+cfun=0")
            at_cmd = 'at%earfcn=' + earfcn
            print(at_cmd)
            # at_cmd = "AT\%SETCFG=\"BAND\",\"%d\""%(band)
            # for i in range(self.retry_time):
            result = self._execute_at_command(at_cmd)

        except Exception as e:
            print("Try to set dongle earfcn fail")
            print(e)
        finally:
            return result

    def set_cqi_ri(self, cqi, ri, pmi):
        # Override CQI command ""
        at_cmd = ""
        self.execute_at_command(at_cmd)
        return -1

    def catch_cpe_logs(self, path_saved=""):
        pass

    def reconnect(self):
        self.disconnect()
        return self.connect_to_cpe()


class Deming2(Deming):
    def __init__(self, ip):
        super(Deming2, self).__init__(ip)

    def set_dmz(self, ip):
        return 0

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn):
        cell_id = cell_id[0]
        current_band = self.get_dongle_bandwidth()

        # if current_band == None or self.attachCount == 0:
        if not current_band:
            if self.reboot() != 0:
                print("Reboot cpe Fail!!!")
                return -9
            if not self.connect_to_cpe():
                print("Connect CPE Fail!!!")
                return 5

            current_band = self.get_dongle_bandwidth()

            if not current_band:
                print("Can not get cpe band config!!!")
                return -10
        # self.attachCount = (self.attachCount + 1) % 4

        # (band,earfcn) = self.convert_41_to_38(band,earfcn,current_band)
        # print "Convert band:%d,earfcn:%s:%s"%(band,earfcn,self.attachCount)
        # if band == -1:
        #     print "Convert band 41 to 38 fail!!!!"
        #     return -11
        # print current_band
        if current_band != str(band) and self.set_dongle_bandwidth(band) != 0:
            return 1

        current_earfcn = self.get_dongle_earfcn()
        if current_earfcn and current_earfcn == earfcn:
            pass
        elif earfcn != '' and self.set_dongle_earfcn(earfcn) != 0:
            return 4

        # retcode = self.check_dongle_attach_status()
        # print retcode
        # ip = self.get_dongle_ip_address()
        # print ip
        #
        # if retcode == 0:
        #     self.dongle_detach()
        #     time.sleep(2)

        # attach_done = False
        # for i in range(0,3):
        #     timeout = 10 + i * 5
        #     print "wait for %d seconds,and then try to attach..."%(timeout)
        #     time.sleep(timeout)
        #     if self.dongle_attach() == 0:
        #         attach_done = True
        #         break
        # if attach_done == False:
        #     return 3
        self.dongle_attach()
        # time.sleep(10)
        # self.reconnect()
        print("attach and check bts cell id !!!!!")
        attach_cell_id = None
        for i in range(6):
            attach_cell_id = self.get_attached_btscell_id()
            if attach_cell_id[0]:
                break
            time.sleep(10)
        print(attach_cell_id)
        if not attach_cell_id:
            return 7
        if self.check_dongle_attach_status():
            print("not at attach status!!!!")
            return 9
        ip = self.get_dongle_ip_address()
        print(ip)

        (bts, cell) = attach_cell_id[0].split('/')
        if cell != cell_id:
            return 6
        (ret_code, rssi) = self.get_csq()
        if ret_code == 0 and rssi > 80:
            print("The signal rssi is too low!!!!")
            return 8
        return 0


class NokiaCPE31(CPEBase):
    ELEMENT_UE_IP = 'InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANIPConnection.1.ExternalIPAddress'
    ELEMENT_DEFAULT_GATEWAY = 'InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANIPConnection.1.DefaultGateway'
    ELEMENT_UE_APN = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.AccessPoint.1.APN'
    ELEMENT_UE_IFNAME = 'InternetGatewayDevice.WANDevice.2.WANConnectionDevice.1.WANIPConnection.1.X_ASB_COM_IfName'
    ELEMENT_CELL_TOWER_1 = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.Interface.1.X_ALU-COM_CellTower.1.'
    ELEMENT_CELL_TOWER_1_PCI = ELEMENT_CELL_TOWER_1 + 'PCI'
    ELEMENT_CELL_TOWER_1_RSRP = ELEMENT_CELL_TOWER_1 + 'RSRP'
    ELEMENT_CELL_TOWER_1_SNR = ELEMENT_CELL_TOWER_1 + 'SNR'
    ELEMENT_CELL_TOWER_2 = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.Interface.1.X_ALU-COM_CellTower.2.'
    ELEMENT_CELL_TOWER_2_PCI = ELEMENT_CELL_TOWER_2 + 'PCI'
    ELEMENT_CELL_TOWER_2_ENB = ELEMENT_CELL_TOWER_2 + 'eNB'
    ELEMENT_LTE_CELLS = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.Interface.1.X_ALU-COM_LteRanCells.'
    ELEMENT_LTE_CELL = ELEMENT_LTE_CELLS + 'LteRanCell.'
    ELEMENT_LTE_CELL_1 = ELEMENT_LTE_CELL + '1.'
    ELEMENT_LTE_CELL_PCI = ELEMENT_LTE_CELL_1 + 'PhysicalCellID'
    ELEMENT_LTE_CELL_DL_ARFCN = ELEMENT_LTE_CELL_1 + 'DownlinkEarfcn'
    ELEMENT_NR_CELLS = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.Interface.1.X_ALU-COM_5GRanCells.'
    ELEMENT_NR_CELL = ELEMENT_NR_CELLS + 'NR5GRanCell.'
    ELEMENT_NR_CELL_1 = ELEMENT_NR_CELL + '1.'
    ELEMENT_NR_CELL_PCI = ELEMENT_NR_CELL_1 + 'PhysicalCellID'
    ELEMENT_NR_CELL_DL_ARFCN = ELEMENT_NR_CELL_1 + 'Downlink-NR-ARFCN'
    ELEMENT_NR_CELL_BAND = ELEMENT_NR_CELL_1 + 'Band'
    ELEMENT_LTE_BAND = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.X_ALU-COM_Band.'
    ELEMENT_LTE_BAND_1 = ELEMENT_LTE_BAND + '1.'
    ELEMENT_LTE_BAND_1_BAND = ELEMENT_LTE_BAND_1 + 'Band'
    ELEMENT_LTE_BAND_1_ENABLE = ELEMENT_LTE_BAND_1 + 'Enable'
    ELEMENT_NR_BAND = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.X_ALU-COM_5GBand.'
    ELEMENT_NR_BAND_1 = ELEMENT_NR_BAND + '1.'
    ELEMENT_NR_BAND_1_BAND = ELEMENT_NR_BAND_1 + 'Band'
    ELEMENT_NR_BAND_1_ENABLE = ELEMENT_NR_BAND_1 + 'Enable'
    ELEMENT_RAT_BASE = 'InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.Interface.1.'
    ELEMENT_RAT_PAT = ELEMENT_RAT_BASE + 'PreferredAccessTechnology'
    ELEMENT_RAT_SAT = ELEMENT_RAT_BASE + 'SupportedAccessTechnologies'
    ELEMENT_RAT_CAT = ELEMENT_RAT_BASE + 'CurrentAccessTechnology'
    ELEMENT_RAT_SA = ELEMENT_RAT_BASE + 'X_ALU-COM_EnableSA'
    ELEMENT_RAT_NSA = ELEMENT_RAT_BASE + 'X_ALU-COM_EnableNSA'
    ELEMENT_MSG_LOGGING = 'InternetGatewayDevice.DeviceInfo.VendorLogFile.3.X_ALU-COM_Enable'

    ELEMENT_VALUE_AUTO = 'Auto'
    ELEMENT_VALUE_TRUE = 'true'
    ELEMENT_VALUE_FALSE = 'false'
    SUPPORT_ACCESS_TECHNOLOGIES = ['LTE', 'NR5GNSA', 'NR5GSA']
    SUPPORT_PREFERRED_ACCESS_TECHNOLOGIES = ['LTE', 'NR5GNSA', 'NR5GSA', ELEMENT_VALUE_AUTO]
    ATTACH = """/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 1}]}'"""
    DETACH = """/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 2}]}'"""

    def __init__(self, ip, root_password, user="hguser", password="bkIt0@Uq", cpe_type="nokia_cpe_31"):
        super(NokiaCPE31, self).__init__(cpe_type, ip)
        self.user = user
        self.password = password
        self.root_password = root_password
        self.sshconn = ssh()
        self.session = None
        self.prompt = ""

    def connect(self):
        if self.session:
            return True
        try:
            print("connect to nokia cpe...")
            connection = self.sshconn.connect_to(self.ip, self.user, self.password)
            self.session = connection.invoke_shell()
            self.session.timeout = 10
            time.sleep(1)
            self.prompt = "@OpenWrt:/$"
            self._read_until_prompt()
            self.prompt = "Password:"
            self._send_cmd("su root\r")
            self.prompt = "root@OpenWrt:/#"
            self._send_cmd(f"{self.root_password}\r")
            return True
        except Exception as e:
            print(e)
            return False

    def disconnect(self):
        print("disconnect...")
        if hasattr(self.session, "close") and callable(self.session.close):
            self.session.close()
        self.session = None
        if hasattr(self.sshconn, "disconnect") and callable(self.sshconn.disconnect):
            self.sshconn.disconnect()

    def reboot_and_reconnect(self):
        self._send_cmd("reboot")
        self.disconnect()
        time.sleep(30)
        self.test_ping()
        time.sleep(60)
        self.connect()
        return 0

    def _send_cmd(self, command):
        if not self.session:
            raise Exception("CPE is not at connection status!!!!")
        self.session.send(f"{command}\r")
        return self._read_until_prompt()

    def _read_until_prompt(self, wait_time=1):
        result = ""
        while True:
            try:
                time.sleep(wait_time)
                ret = self.session.recv(65535).decode("utf-8")
                result += ret
                if self.prompt in result:
                    print(result)
                    return result
            except Exception:
                raise Exception(f"{result} not contain {self.prompt}")

    def _set_prompt(self, prompt):
        self.prompt = prompt

    def _set_parameter_value(self, element, value):
        command = f"cfgcli -s {element} {value}"
        self._send_cmd(command)
        current_value = self._get_single_ue_info(element)
        assert str(current_value) == str(value), f"set {element} to {value} failed!"

    def _get_parameters_value(self, element):
        command = f"cfgcli -G {element}"
        return self._send_cmd(command)

    def _get_parameter_value(self, element):
        command = f"cfgcli -g {element}"
        return self._send_cmd(command)

    def _add_dynamic_node(self, element):
        """
        add dynamic node by element with cfgcli command.

        :param element: str, path of DataModule Element, e.g. "InternetGatewayDevice.DeviceInfo.SerialNumber"
        :return str: response of cfgcli command
        """
        command = f"cfgcli add {element}"
        return self._send_cmd(command)

    def _delete_dynamic_node(self, element):
        command = f"cfgcli del {element}"
        return self._send_cmd(command)

    def _get_single_ue_info(self, element):
        response = self._get_parameter_value(element=element)

        if response is None or "failed" in response:
            print('failed to get ue info: {}'.format(response))
            return None

        regex = r'=(.*?)\r\n'
        ue_info_value = re.search(regex, response)
        if not ue_info_value:
            print("Get ue info failure: '{}'".format(response))
            return None
        return ue_info_value.groups()[0]

    def _set_single_access_technology(self, technology):
        if technology == '4G':
            self._set_parameter_value(self.ELEMENT_RAT_PAT, value="LTEOnly")
        elif technology == 'SA':
            self._set_parameter_value(self.ELEMENT_RAT_PAT, value="NR5GSAOnly")
        elif technology == 'NSA':
            self._set_parameter_value(self.ELEMENT_RAT_PAT, value="NR5GNSA")
        else:
            raise Exception(f"{technology} not supported!")

    def set_dmz(self, ip):
        return 0

    def attach(self):
        attach_status = False
        try_times = 12
        while try_times > 0:
            try_times -= 1
            ip = self.get_dongle_ip_address()
            if ip:
                attach_status = True
                break
            else:
                try:
                    print("try actual attach...")
                    ret = self._send_cmd(self.ATTACH)
                    regexp = r"result.*(\d).*\n"
                    result_value = re.search(regexp, ret)
                    if not result_value:
                        print("attach failed!")
                        continue
                    if int(result_value.groups()[0]) == 0:
                        attach_status = True
                        break
                except Exception:
                    print("actual attach failed!")
            print("attach failed!")
            time.sleep(15)
        return attach_status

    def detach(self):
        ret_code = 0
        try:
            ret = self._send_cmd(self.DETACH)
            regexp = r"result.*(\d).*\n"
            result_value = re.search(regexp, ret)
            if not result_value or int(result_value.groups()[0]) != 0:
                print("detach failed!")
        except Exception as ex:
            print(ex)
        print(ret_code)

    def lock_lte_cell(self, pci, earfcn):
        response = self._get_parameters_value(self.ELEMENT_LTE_CELL_1)
        if response is None or "failed" in response:
            self._add_dynamic_node(self.ELEMENT_LTE_CELL)

        self._set_parameter_value(element=self.ELEMENT_LTE_CELL_PCI, value=pci)
        self._set_parameter_value(element=self.ELEMENT_LTE_CELL_DL_ARFCN, value=earfcn)

    def unlock_lte_cell(self):
        response = self._delete_dynamic_node(self.ELEMENT_LTE_CELL_1)
        if "success" not in response:
            raise Exception("unlock lte cell failed!")

    def lock_lte_band(self, band):
        band = "B" + band
        response = self._get_parameters_value(self.ELEMENT_LTE_BAND_1)
        if response is None or "failed" in response:
            self._add_dynamic_node(self.ELEMENT_LTE_BAND)
        self._set_parameter_value(element=self.ELEMENT_LTE_BAND_1_BAND, value=band)
        self._set_parameter_value(element=self.ELEMENT_LTE_BAND_1_ENABLE, value=self.ELEMENT_VALUE_TRUE)

    def unlock_lte_band(self):
        self._set_parameter_value(element=self.ELEMENT_LTE_BAND_1_ENABLE, value=self.ELEMENT_VALUE_FALSE)

    def lock_nr_band(self, band):
        band = "n" + band
        response = self._get_parameters_value(self.ELEMENT_NR_BAND_1)
        if response is None or "failed" in response:
            self._add_dynamic_node(self.ELEMENT_NR_BAND)
        self._set_parameter_value(element=self.ELEMENT_NR_BAND_1_BAND, value=band)
        self._set_parameter_value(element=self.ELEMENT_NR_BAND_1_ENABLE, value=self.ELEMENT_VALUE_TRUE)

    def unlock_nr_band(self):
        self._set_parameter_value(element=self.ELEMENT_NR_BAND_1_ENABLE, value=self.ELEMENT_VALUE_FALSE)

    def get_dongle_ip_address(self):
        ip = self._get_single_ue_info(self.ELEMENT_UE_IP)
        return ip

    def get_current_cell_info(self):
        cell_id = self._get_single_ue_info(self.ELEMENT_CELL_TOWER_1_PCI)
        rsrp = self._get_single_ue_info(self.ELEMENT_CELL_TOWER_1_RSRP)
        snr = self._get_single_ue_info(self.ELEMENT_CELL_TOWER_1_SNR)
        print("cell_id= %s,RSRP= %s, SNR= %s" % (cell_id, rsrp, snr))
        return cell_id, rsrp, snr

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn, network_type):
        if not self.session:
            self.connect()
        self._set_single_access_technology(network_type)
        if network_type == "4G":
            self.lock_lte_cell(cell_id[0], earfcn)
        else:
            self.lock_nr_band(band)

        count = 3
        while count > 0:
            count -= 1
            attach_status = self.attach()
            if attach_status:
                pci, rsrp, snr = self.get_current_cell_info()
                if pci and int(cell_id[0]) == int(pci) and int(rsrp) > -95:
                    return 0
            if count > 0:
                print(f"not attach {cell_id} successfully or rsrp <= -95, reboot cpe!")
                ret_code = self.reboot_and_reconnect()
                if ret_code:
                    print("reboot and reconnect failed!")
                    return -2
        return -1, "Attach failed!"


class NokiaCPE32(NokiaCPE31):
    """Ue access layer API"""
    ATTACH = """/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 1}]}'"""
    DETACH = """/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 2}]}'"""

    def __init__(self, ip, root_password, user="hguser", password="Hp@9wYs2d%t7", cpe_type="nokia_cpe_32"):
        super(NokiaCPE32, self).__init__(ip, root_password, user=user, password=password, cpe_type=cpe_type)

    def attach(self):
        attach_status = False
        try_times = 12
        while try_times > 0:
            try_times -= 1
            ret = self._send_cmd(self.ATTACH)
            regexp = r"result.*(\d).*\n"
            result_value = re.search(regexp, ret)
            if not result_value:
                print("attach failed!")
                continue
            if int(result_value.groups()[0]) == 0:
                attach_status = True
                break
            print("attach failed!")
            time.sleep(15)
        return attach_status

    def detach(self):
        ret_code = 0
        try:
            ret = self._send_cmd(self.DETACH)
            regexp = r"result.*(\d).*\n"
            result_value = re.search(regexp, ret)
            if not result_value or int(result_value.groups()[0]) != 0:
                print("detach failed!")
        except Exception as ex:
            print(ex)
        print(ret_code)

    def lock_nr_cell(self, pci, nrarfcn, band):
        response = self._get_parameters_value(self.ELEMENT_NR_CELL_1)
        if response is None or "failed" in response:
            self._add_dynamic_node(self.ELEMENT_NR_CELL)
        self._set_parameter_value(element=self.ELEMENT_NR_CELL_PCI, value=pci)
        self._set_parameter_value(element=self.ELEMENT_NR_CELL_DL_ARFCN, value=nrarfcn)
        band = 'n' + band
        self._set_parameter_value(element=self.ELEMENT_NR_CELL_BAND, value=band)

    def unlock_nr_cell(self):
        response = self._delete_dynamic_node(self.ELEMENT_NR_CELL_1)
        if "success" not in response:
            raise Exception("unlock lte cell failed!")

    def enhanced_dongle_attach(self, bts_id, cell_id, band, earfcn, network_type):
        cell_id = cell_id[0]
        if not self.session:
            self.connect()

        self._set_single_access_technology(network_type)
        if network_type == "4G":
            self.lock_lte_cell(cell_id, earfcn)
        else:
            self.lock_nr_cell(cell_id, earfcn, band)

        count = 3
        while count > 0:
            self.detach()
            time.sleep(5)
            attach_status = self.attach()
            if attach_status:
                wait_count = 6
                ip = ""
                while wait_count > 0:
                    ip = self.get_dongle_ip_address()
                    if ip:
                        break
                    time.sleep(10)
                    wait_count -= 1
                pci, rsrp, snr = self.get_current_cell_info()
                if ip and pci and rsrp and int(cell_id) == int(pci) and int(rsrp) > -90:
                    return 0

            print(f"not attach {cell_id} successfully, reboot cpe!")
            ret_code = self.reboot_and_reconnect()
            if ret_code:
                print("reboot and reconnect failed!")
                return -2
            count -= 1
        return -1, "Attach failed!"


def nokia_cpe_attach(bts_id, cell_id, band, earfcn, ip, lan_ip, root_password, network_type, cpe_type="nokiacpe31",
                     dmz='yes'):
    # band = get_band_with_earfcn(earfcn)
    cell_id = str(cell_id)

    if ip in CPEInstanceList.keys():
        cpe_instance = CPEInstanceList[ip]
        print("find cpe instance:%s" % ip)
    else:
        cpe_instance = None
        if cpe_type == "NokiaCPE31":
            cpe_instance = NokiaCPE31(ip, root_password=root_password, cpe_type=cpe_type)
            if not cpe_instance.connect():
                raise Exception("Connect to cpe fail!!!")
        elif cpe_type == "NokiaCPE32":
            cpe_instance = NokiaCPE32(ip, root_password=root_password, cpe_type=cpe_type)
            if not cpe_instance.connect():
                raise Exception("Connect to cpe fail!!!")

        if dmz == "yes" and cpe_instance.set_dmz(lan_ip) != 0:
            raise Exception("Set Dmz failed!!!")

        CPEInstanceList[ip] = cpe_instance
    cell_list = cell_id.split("_")
    try:
        ret_code = cpe_instance.enhanced_dongle_attach(bts_id, cell_list, band, earfcn, network_type)
        if ret_code:
            raise Exception("Attach cpe fail!!!")

        ip_try = 6
        while ip_try > 0:
            ip = cpe_instance.get_dongle_ip_address()
            if ip:
                break
            ip_try -= 1
            time.sleep(10)
    finally:
        if cpe_type == "NokiaCPE31" or cpe_type == "NokiaCPE32":
            cpe_instance.disconnect()
    if not ip:
        raise Exception("Get ip fail!!!")
    return ip


def get_band(searfcn):
    return get_band_with_earfcn(searfcn)


CPEInstanceList = {}


def cpe_attach(bts_id, cell_id, earfcn, ip, lan_ip, cpe_type="Deming", dmz='yes'):
    band = get_band_with_earfcn(earfcn)
    cell_id = str(cell_id)

    if ip in CPEInstanceList.keys():
        cpe_instance = CPEInstanceList[ip]
        print("find cpe instance:%s" % ip)
    else:
        cpe_instance = None
        if cpe_type == "Deming":
            cpe_instance = Deming(ip)
            if not cpe_instance.connect_to_cpe():
                raise Exception("Connect to cpe fail!!!")
        elif cpe_type == "Deming2":
            cpe_instance = Deming2(ip)
            if not cpe_instance.connect_to_cpe() and cpe_instance.reboot_and_reconnect() != 0:
                raise Exception("Connect to cpe fail!!!")

        elif cpe_type == "ZMTEL":
            cpe_instance = ZMTELNew(ip)
            if not cpe_instance.connect_to_cpe():
                raise Exception("Connect to cpe fail!!!")
        elif cpe_type == "ZMTEL_old":
            cpe_instance = ZMTEL(ip=ip, cpe_type=cpe_type)
            if not cpe_instance.connect():
                raise Exception("Connect to cpe fail!!!")
        elif cpe_type == "Gemtek":
            cpe_instance = Gemtek(ip)

        if dmz == "yes" and cpe_instance.set_dmz(lan_ip) != 0:
            raise Exception("Set Dmz failed!!!")

        CPEInstanceList[ip] = cpe_instance
    cell_list = cell_id.split("_")
    ret_code = cpe_instance.enhanced_dongle_attach(bts_id, cell_list, band, earfcn)
    if ret_code:
        raise Exception("Attach cpe fail!!!")

    ip = cpe_instance.get_dongle_ip_address()
    if cpe_type == "Deming" or cpe_type == "Deming2" or cpe_type == "Gemtek":
        cpe_instance.logout()
    if not ip:
        raise Exception("Get ip fail!!!")
    return ip


def get_tput_from_web_page(ip, bts_id, cell_id, during, cpe_type):
    if cpe_type != "Gemtek":
        raise Exception("Not support the CPE type:{}".format(cpe_type))

    if ip not in CPEInstanceList.keys():
        raise Exception("Can not find CPE instance: {}".format(ip))

    cpe_instance = CPEInstanceList[ip]
    cell_list = cell_id.split("_")
    return cpe_instance.get_tput(bts_id=bts_id, cell_id=cell_list, during=int(during))


def release_all_cpe():
    for key in CPEInstanceList:
        cpe = CPEInstanceList[key]
        cpe.release()
    CPEInstanceList.clear()


def get_udp_port(direction):
    host_name = socket.gethostname()
    print(host_name)
    reg_str = r"(CLOUD|UTE4G)(\d+)"
    import re
    result = re.search(reg_str, host_name)
    port = 0
    if result:
        port = int(result.group(2))
    else:
        raise Exception("The hostname is not correct")
    print(direction, port)
    print(direction == "UL")
    if direction == "UL":
        return 5000 + port * 2
    elif direction == "DL":
        return 5000 + port * 2 + 1
    else:
        raise Exception("That doesn't  support direction type:%s" % direction)


def get_timestamp(fmt="%Y%m%d%H%M%S"):
    import datetime
    return datetime.datetime.now().strftime(fmt)


def check_tput(ul, dl, standard_ul, standard_dl, cpe_type):
    check_ul = float(standard_ul)
    check_dl = float(standard_dl)
    if cpe_type == "Deming" or cpe_type == "Deming2":
        check_ul = check_ul * 1024 * (2 / 3 - 0.1)
        check_dl = check_dl * 1024 * (2 / 3 - 0.1)
    elif cpe_type == "Gemtek":
        check_ul = check_ul * 1024 * 0.7
        check_dl = check_dl * 1024 * 0.95
    elif cpe_type == "ZMTEL" or cpe_type == "ZMTEL_old":
        check_ul = check_ul * 1024 * 0.7
        check_dl = check_dl * 1024 * 0.9
    elif cpe_type == "NokiaCPE31" or cpe_type == "NokiaCPE32":
        check_ul = check_ul * 1024 * 0.9
        check_dl = check_dl * 1024 * 0.9
    else:
        raise Exception("Not support the CPE type")
    ret_code = True

    if float(ul) < check_ul:
        print("ul doesn't reach the standard rate,%f:%f" % (float(ul), check_ul))
        ret_code = False
    if float(dl) < check_dl:
        print("dl doesn't reach the standard rate,%f:%f" % (float(dl), check_dl))
        ret_code = False
    if not ret_code:
        raise Exception("Check tput failed!!!")


def check_ping_result(result_data):
    summary_result = result_data[0]
    delay_max_min_avg = result_data[1]
    if float(summary_result[2]) >= 40:
        raise Exception("Packet loss =%s" % (str(summary_result)))
    if delay_max_min_avg[0] >= 500:
        raise Exception("max delay time >=%s" % (str(delay_max_min_avg[0])))
    elif delay_max_min_avg[0] == -1:
        raise Exception("not enough data!!!")
    print("check ping data ok!!!")


def get_matched_ue(band, ue_list, network_type="4G", technology="", pa_ids=""):
    # band = str(get_band_with_earfcn(earfcn))
    print(ue_list)
    print(network_type)
    print(technology)
    for ue_info in ue_list:
        if "STATUS" in ue_info.keys() and \
                ue_info["STATUS"] != "Enabled":
            continue
        supported_band = ue_info["BAND"]
        supported_network = ue_info["NETWORK_TYPE"].split(",")
        if network_type not in supported_network:
            continue
        if "TECHNOLOGY" in ue_info.keys():
            supported_tech = ue_info["TECHNOLOGY"].split(",")
            if technology not in supported_tech:
                continue

        supported_band_list = supported_band.split(",")
        if isinstance(pa_ids, list) and pa_ids:
            ue_bind_pa_id = None
            if "PA_List" in ue_info.keys():
                ue_bind_pa_id = ue_info["PA_List"].split("/")
            elif "PA_LIST" in ue_info.keys():
                ue_bind_pa_id = ue_info["PA_LIST"].split("/")
            if ue_bind_pa_id:
                is_matched = True
                for pa_id in pa_ids:
                    if pa_id not in ue_bind_pa_id:
                        is_matched = False
                        break
                if not is_matched:
                    continue
                if band in supported_band_list:
                    return ue_info

    for ue_info in ue_list:
        supported_band = ue_info["BAND"]
        supported_network = ue_info["NETWORK_TYPE"].split(",")
        if network_type not in supported_network:
            continue
        if "TECHNOLOGY" in ue_info.keys():
            supported_tech = ue_info["TECHNOLOGY"].split(",")
            if technology not in supported_tech:
                continue
        supported_band_list = supported_band.split(",")
        if band in supported_band_list:
            return ue_info

    raise Exception("Can not find the matched UE!!!")


if __name__ == '__main__':
    print(get_udp_port("UL"))
