from robot.libraries.BuiltIn import BuiltIn
from .ue_config import parse_ue_config, logging
from taf.transport.ssh.connection import connect as taf_connect
from taf.transport.ssh import ssh
from taf.internal.aliasing import aliasing_scope
# from taf.transport.ftp.connection import Connection as ftp_connect
from .uebox_at_commands import AtCommands
from collections import namedtuple
import re
import time
import os


class device(object):

    def __init__(self):
        pass
        self.log = None

    def connect(self, hostname, username, password, port=22):
        self.hostname = hostname
        self.username = username
        self.password = password
        self.connection = ssh()

    def disconnect(self):
        self.connection.disconnect(connection=self.alias)

    def execute(self, command, timeout=120):
        logging.info(f"Executing command {command}")
        ret = self.connection.execute(command=command, timeout=timeout, connection=self.alias)
        logging.info(f"reponse {ret}")
        return ret

    def send_command(self, command, timeout=30):
        logging.info(f"Send command {command}")
        ret = self.connection.send_command(command=command, timeout=timeout, connection=self.alias)
        return ret

    def read(self):
        ret = self.connection.read_output(connection=self.alias)
        return ret

    def read_until(self, match):
        ret = self.connection.read_output_until(match=match, connection=self.alias)
        return ret


class iperf(device):
    def __init__(self):
        pass

    def connect(self, hostname, username, password, port=22):
        logging.info(f"Connecting to iperf server {hostname}")
        super().connect(hostname, username, password, port)
        self.connection.connect_to(hostname=hostname,
                                   username=username,
                                   password=password,
                                   port=port,
                                   alias=f"iperf_{hostname}")
        self.alias = f"iperf_{hostname}"


server_info = namedtuple("server_info", ["hostname", "username", "password", "path"])
uepc_prepare_done = {}


class uepc(device):
    server_info = server_info(hostname="10.56.198.140",
                              username="root",
                              password="uteadmin",
                              path="/shared/TA2021/sendcom.exe")
    default_sendcom_path = "~/../../bin/sendcom.exe"

    def __init__(self):
        pass

    def connect(self, hostname, username, password, port=22):
        super().connect(hostname, username, password, port)
        logging.info(f"Connecting to ue pc {hostname} {password}")
        self.connection.connect_to(hostname=hostname,
                                   username=username,
                                   password=password,
                                   timeout=120,
                                   port=port,
                                   alias=f"uepc_{hostname}")
        self.alias = f"uepc_{hostname}"

    def prepare(self):
        try:
            prepare_server = ssh()
            prepare_server.connect_to(self.server_info.hostname,
                                      self.server_info.username,
                                      self.server_info.password,
                                      alias=f"ssh_{self.server_info.hostname}")
            local_path = "/home/ute"
            filename = os.path.basename(self.server_info.path)
            prepare_server.download_file(local_path=local_path,
                                         remote_path=[self.server_info.path],
                                         connection=f"ssh_{self.server_info.hostname}")
            # os.system(f"sshpass -p {self.server_info.password} scp -r self.server_info.path
            #                     {self.server_info.username}@{self.server_info.hostname}:{local_path}")
            logging.info(f"sshpass -p {self.password} scp -r " +
                         f"{local_path}/{filename} {self.username}@{self.hostname}:{self.default_sendcom_path}")
            os.system(f"sshpass -p {self.password} scp -r " +
                      f"{local_path}/{filename} {self.username}@{self.hostname}:{self.default_sendcom_path}")
            prepare_server.execute(command="chmod 777 " + self.default_sendcom_path,
                                   connection=self.default_sendcom)
        except Exception as e:
            logging.info(e)
            logging.info("can't update the sendcom.exe")
        finally:
            prepare_server.disconnect(connection=f"ssh_{self.server_info.hostname}")

    def check_sendcom_exist(self, timeout=10):
        ret = self.execute(f"ssh -V")
        if "OpenSSH_for_Windows" in ret:
            # for Windows ssh will no to check the sendcom.exe
            return True
        logging.info(f'test -f {self.default_sendcom_path} && echo "File exists" || echo "File does not exist"')
        logging.info(self.send_command(f"chmod 777 {self.default_sendcom_path}"))
        logging.info(self.execute(f"ls -l {self.default_sendcom_path}"))
        starttime = time.time()
        while time.time() < starttime + timeout:
            ret = self.execute(
                f'test -f {self.default_sendcom_path} && echo "File exists" || echo "File does not exist"')
            logging.info(ret)
            if "File exists" in ret:
                break
        if "File exists" in ret:
            return True
        else:
            return False


def connect_decorator(func):
    def wrapper(self, *args, **kwargs):
        print("connect to...")
        if "traffic" in func.__name__:
            self._connect_iperf()
        else:
            self._connect_uepc()
        result = func(self, *args, **kwargs)
        if "traffic" in func.__name__:
            self._disconnect_iperf()
        else:
            self._disconnect_uepc()
        print("disconnect to.")
        return result
    return wrapper


class Ue:
    IP_STRING = r"((25[0-5]\.|2[0-4]\d\.|1\d{2}\.|[1-9]?\d\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d))"

    def __init__(self, ue_index=0):
        self.ue_config = parse_ue_config(index=ue_index)
        self.iperf = iperf()
        self.uepc = uepc()
        self.at_commands = AtCommands("Fibocom")
        if "quectel" in self.ue_config.capabilities or "Quectel" in self.ue_config.capabilities:
            self.at_commands = AtCommands("Quectel")

    def _connect_uepc(self):
        # retry 3 times to connect to ue pc
        for i in range(3):
            try:
                self.uepc.connect(
                    hostname=self.ue_config.cpc_ip,
                    username=self.ue_config.cpc_username,
                    password=self.ue_config.cpc_password)
                break
            except Exception as e:
                logging.info(f"connect to ue pc error {e}")
                time.sleep(5)
        if self.uepc.hostname not in uepc_prepare_done.keys():
            uepc_prepare_done[self.uepc.hostname] = False
        if uepc_prepare_done[self.uepc.hostname] is False:
            if self.uepc.check_sendcom_exist() is False:
                self.uepc.prepare()
            uepc_prepare_done[self.uepc.hostname] = self.uepc.check_sendcom_exist()
            if uepc_prepare_done[self.uepc.hostname] is False:
                raise "Can't find the sendcom.exe in ue pc path: cygwin64/bin/, please check the connection"

    def teardown(self):
        try:
            self._disconnect_iperf()
        except Exception as e:
            logging.info(f"disconnect iperf server error {e}")
        try:
            self._disconnect_uepc()
        except Exception as e:
            logging.info(f"disconnect ue pc error {e}")

    def _disconnect_uepc(self):
        self.uepc.disconnect()

    def _connect_iperf(self, ip=None, username=None, password=None, port="22"):
        if ip is not None and username is not None and password is not None:
            self.iperf_connection = self.iperf.connect(
                hostname=ip,
                username=username,
                password=password,
                port=port)
            self.iperf_hostname = ip
        else:
            self.iperf_connection = self.iperf.connect(
                hostname=self.ue_config.iperf_address,
                username=self.ue_config.iperf_user,
                password=self.ue_config.iperf_password,
                port=port)
            self.iperf_hostname = self.ue_config.iperf_address

    def _disconnect_iperf(self):
        self.iperf.disconnect()

    @connect_decorator
    def execute_and_check_result(self, atcmd):
        cmd = f"sendcom COM{self.ue_config.com_id} {atcmd}"
        # retry 3 times to execute cmd
        for i in range(4):
            ret = self.uepc.execute(cmd)
            if "OK" in ret:
                break
            time.sleep(5)
        if "OK" not in ret:
            raise Exception(f"Execute command failed {atcmd} {ret}")
        return ret

    @connect_decorator
    def execute_without_check_result(self, com_id, get_respon=False, extend=""):
        cmd = f"sendcom {com_id} {extend}"
        if get_respon:
            ret = self.uepc.execute(cmd)
            return ret
        else:
            self.uepc.send_command(cmd)

    def get_cell_id(self):
        atcmd = "AT+CGREG?"
        response = self.execute_and_check_result(atcmd=atcmd)
        match = re.search(r"\+CGREG: \d,\d,(\d+),(\d+)", response)
        if match:
            lac = match.group(1)
            cell_id = match.group(2)
            return {"lac": lac, "cell_id": cell_id}
        else:
            raise Exception("Failed to get Cell ID")

    def check_pci_and_cell_info(self, expected_pci=None, expected_cellid=None):
        atcmd = self.at_commands.net_service.SERVING_CELL
        response = self.execute_and_check_result(atcmd=atcmd)
        # +QENG: "servingcell","NOCONN","NR5G-SA","TDD",460,02,002C9B021,33,118,634080,77,6,-86,-11,25,1,-
        # 1,9,262,03,118,29F201F,9BCA0,1F,5077,40,107,68,68,65
        if expected_pci is not None:
            if f",{expected_pci}," in response:
                pass
            else:
                raise Exception(f"{response},pci is not expected as {expected_pci}")
        if expected_cellid is not None:
            if f",{hex(int(expected_cellid))[2:].upper()}," in response:
                pass
            else:
                raise Exception(f"{response},cell id is not expected as {expected_cellid}")

    # @connect_decorator
    def exec_at_command(self, atcmd):
        return self.execute_and_check_result(atcmd)

    # @connect_decorator
    def attach(self, expected_pci=None, expected_cellid=None, attach_stats_checked=False):
        if attach_stats_checked:
            atcmd = self.at_commands.CHECK_ATTACH_STATUS
            ret = self.execute_and_check_result(atcmd=atcmd)
            if re.search(r"COPS: 2", ret) is not None:
                atcmd = self.at_commands.set_UE_Func.enable_ue_most_func()
                ret = self.execute_and_check_result(atcmd=atcmd)
                atcmd = self.at_commands.CHECK_ATTACH_STATUS
                ret = self.execute_and_check_result(atcmd=atcmd)
                if re.search(r"COPS: \d+", ret) is None:
                    raise Exception("Attach Error")
            else:
                logging.warn("Already attach, no attach again")
        else:
            atcmd = self.at_commands.set_UE_Func.enable_ue_most_func()
            ret = self.execute_and_check_result(atcmd=atcmd)
        if expected_pci is None and expected_cellid is None:
            return ret
        else:
            self.check_pci_and_cell_info(expected_pci=expected_pci, expected_cellid=expected_cellid)
            return ret

    # @connect_decorator
    def detach(self):
        atcmd = self.at_commands.set_UE_Func.disable_ue_most_func()
        ret = self.execute_and_check_result(atcmd=atcmd)
        return ret

    # @connect_decorator
    def get_apn(self, pdp_type):
        atcmd = self.at_commands.CHECK_IMS
        # CGDCONT: ${c_id},\\"${pdp_type}\\"\\,\\"[0-9a-zA-Z.]+\\"
        ret = self.execute_and_check_result(atcmd=atcmd)
        for line in ret.split("CGDCONT: "):
            logging.info(line)
            logging.info(re.search(fr'\d+,"{pdp_type}","[0-9a-zA-Z\._-]+"', line))
            if re.search(fr'\d+,"{pdp_type}","[0-9a-zA-Z\._-]+"', line) and "ims" not in line:
                info = line.split(",")
                return info[0], info[2]
            # to do
        return False

    # @connect_decorator
    def set_apn(self, before_intf_name, after_intf_name):
        atcmd = self.at_commands.CHECK_IMS
        ret = self.execute_and_check_result(atcmd=atcmd)
        for line in ret.split("CGDCONT"):
            if before_intf_name in line:
                info = line.split(",")
                c_id = re.search(r"\d+", info[0]).group(0)
                pdp_type = info[1]
                apn = after_intf_name
                self.execute_and_check_result(atcmd=f'at+cgdcont={c_id},{pdp_type},"{apn}"')
                break
        atcmd = self.at_commands.CHECK_IMS
        ret = self.execute_and_check_result(atcmd=atcmd)
        if after_intf_name in ret:
            pass
        else:
            raise Exception(f"Can't set apn {after_intf_name} -> {before_intf_name}")
        return ret

    # @connect_decorator
    def get_ue_ip(self, intf_name=None):
        """
        +CGDCONT: 1,"IPV4V6","ststatic","172.250.82.27,0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,"",,,,0
        +CGDCONT: 2,"IPV4V6","ims","10.70.206.116,42.0.138.5.64.33.24.91.0.0.0.0.25.146.53.236",0,0,"",,,,0
        +CGDCONT: 3,"IPV4V6","CMNET","0.0.0.0,0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,"",,,,0
        +CGDCONT: 4,"IPV4V6","CMWAP","0.0.0.0,0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,"",,,,0
        +CGDCONT: 5,"IPV4V6","SOS","0.0.0.0,0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,1,,,,,,,,,"",,,,0

        +CGPADDR: 1,"0.0.0.0","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0"
        +CGPADDR: 2,"10.107.216.191","42.0.138.5.64.33.3.248.0.0.0.0.27.49.149.102"
        +CGPADDR: 3,"0.0.0.0","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0"
        +CGPADDR: 38,"0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0"
        +CGPADDR: 39,"0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0"
        +CGPADDR: 4,"0.0.0.0"
        +CGPADDR: 5,"10.107.220.140"
        """
        ip = None
        line = self.execute_and_check_result(atcmd=self.at_commands.CHECK_IMS)
        ip_line = self.execute_and_check_result(atcmd=self.at_commands.CHECK_IP)
        if intf_name is None:
            ims_index = None
            for per_line in line.split("CGDCONT: "):
                if "ims" in per_line:
                    ims_index = per_line.split(",")[0]
                    break
            logging.info(f"ims index: {ims_index}")
            for per_line in ip_line.split("CGPADDR: "):
                logging.info(f"per_line: {per_line}")
                if per_line.split(",")[0] != ims_index or ims_index is None:
                    ip = re.search('\"?'+self.IP_STRING+'\"?', per_line)
                    if ip is not None:
                        ip = ip.group(0).replace("\"", "")
                        if ip != "0.0.0.0":
                            break
                        else:
                            ip = None
        else:
            intf_index = None
            if intf_name in line:
                for per_line in line.split("CGDCONT: "):
                    if intf_name in per_line:
                        intf_index = per_line.split(",")[0]
                        break
                if intf_index is None:
                    raise Exception(f"Could not find interface {intf_name}")
                for per_line in ip_line.split("CGPADDR: "):
                    if per_line.split(",")[0] == intf_index:
                        ip = re.search('\"?'+self.IP_STRING+'\"?', per_line)
                        if ip is not None:
                            ip = ip.group(0).replace("\"", "")
                            if ip != "0.0.0.0":
                                break
                            else:
                                ip = None
            if ip is None:
                raise Exception(f"Could not find ip in interface {intf_name}")
        if ip is None:
            raise Exception(f"Could not find ip")
        return ip

    # @connect_decorator
    def start_call(self, number):
        atcmd = f"ATD+{number}" + r"\;"
        ret = self.execute_and_check_result(atcmd=atcmd)
        return ret

    # @connect_decorator
    def stop_call(self):
        atcmd = self.at_commands.VONR_CALL_END
        ret = self.execute_and_check_result(atcmd=atcmd)
        return ret

    # @connect_decorator
    def reboot(self, timeout=150):
        atcmd = self.at_commands.RESET
        self.execute_without_check_result(com_id=f"COM{self.ue_config.com_id}", extend=atcmd)
        starttime = time.time()
        while time.time() < timeout + starttime:
            ret = self.execute_without_check_result(com_id=f"COM{self.ue_config.com_id}", extend="AT")
            logging.info(f"rebooting... {ret}")
            if ret and "OK" in ret:
                break
            time.sleep(20)

    # @connect_decorator
    def reboot_abandon(self, timeout=120):
        at_ports_before_str = self.execute_without_check_result(com_id="ALL", extend="test", get_respon=True)
        at_ports_before = re.search(r"(\d+,)+\d+", at_ports_before_str).group(0).split(",")
        logging.info(f"reset before {at_ports_before}")
        atcmd = self.at_commands.RESET
        self.execute_without_check_result(com_id=f"COM{self.ue_config.com_id}", extend=atcmd)
        starttime = time.time()
        while time.time() < timeout + starttime:
            at_ports_after_str = self.execute_without_check_result(com_id="ALL", extend="test", get_respon=True)
            at_ports_after = re.search(r"(\d+,)+\d+", at_ports_after_str).group(0).split(",")
            if len(at_ports_before) - len(at_ports_after) > 0:
                break
            # some port disapper
        if len(at_ports_before) - len(at_ports_after) > 0:
            while time.time() < timeout + starttime:
                at_ports_after_str = self.execute_without_check_result(com_id="ALL", extend="test", get_respon=True)
                at_ports_after = re.search(r"(\d+,)+\d+", at_ports_after_str).group(0).split(",")
                time.sleep(5)
                if len(at_ports_before) == len(at_ports_after):
                    break
            if len(at_ports_before) != len(at_ports_after):
                raise Exception(f"reboot failed for {self.ue_config.com_id}, timeout")
            else:
                if self.ue_config.com_id not in at_ports_after:
                    common_com_id = list(set(at_ports_before) & set(at_ports_after))
                    newcom_id = [i for i in at_ports_after if i not in common_com_id][0]
                    logging.info(newcom_id)
                    if newcom_id != self.ue_config.com_id:
                        logging.warn(f"com id already change: {self.ue_config.com_id} -> {newcom_id}")
                    self.ue_config.set_com_id(newcom_id)
        else:
            raise Exception(f"reboot failed for {self.ue_config.com_id}, no power offf")
        return ret

    def _pppoe_call(self):
        atcmd = self.at_commands.PPPOE_CALL
        ret = self.execute_and_check_result(atcmd=atcmd)
        return ret

    def __check_tput(self, conn_server, ip):
        ret = getattr(self, f"{conn_server}").execute(f"ps -ef| grep '{ip}' |grep -v grep| awk '{{print $2}}'")
        logging.info(f"iperf command pid: {ret}")
        ret = getattr(self, f"{conn_server}").execute(f"cat iperf_{ip}.log")
        logging.info(f"output through {ret}")
        setattr(self, f"{conn_server}.log", f"cat iperf_{ip}.log")
        getattr(self, f"_disconnect_{conn_server}")()

    # @connect_decorator
    def start_traffic(self, direction="dl",
                      ip=None,
                      intf_name=None,
                      IperfOptions="-u -i 1 -t 300 -b 10M -p 5000",
                      remote_hostname=None,
                      remote_username=None,
                      remote_password=None,
                      remote_port="22",
                      protocol_type="udp"):
        if protocol_type == "tcp":
            tput_port_match = re.search(r"-p \d+", IperfOptions)
            if tput_port_match is None:
                raise Exception(f"Can't get the port of the tcp port {IperfOptions}")
            else:
                tput_port = int(tput_port_match.group(0).split(" ")[-1])
        if ip is None:
            ip = self.get_ue_ip(intf_name=intf_name)
        if ip is None:
            raise Exception("Can't get the ue ip")
        else:
            self.ip = ip

        if "dl" in direction:
            if protocol_type == "tcp":
                iperf_server_cmd = f"iperf -s -B {ip} -p {tput_port} -i 1"
                self._connect_uepc()
                self.uepc.send_command(iperf_server_cmd)
                # for tcp dl

            self._connect_iperf(remote_hostname,
                                remote_username,
                                remote_password,
                                remote_port)
            self.iperf.execute(f"rm -f iperf_{ip}.log")
            self.iperf.send_command(command=f"iperf {IperfOptions} -c {ip} > iperf_{ip}.log")
            # check tput
            time.sleep(2)
            self.__check_tput("iperf", ip)

        if "ul" in direction:
            self._connect_iperf(remote_hostname,
                                remote_username,
                                remote_password,
                                remote_port)
            if protocol_type == "tcp":
                iperf_server_cmd = f"iperf -s -p {tput_port} -i 1"
                self.iperf.send_command(iperf_server_cmd)
            self._connect_uepc()
            try:
                self._pppoe_call()
            except Exception as e:
                logging.warn(f"pppoe call failed: {e}")
            self.uepc.execute(f"rm -f iperf_{self.iperf_hostname}.log")
            if protocol_type == "tcp":
                cmd = f"iperf {IperfOptions} -c {self.iperf_hostname} -B {ip} > " + \
                      f"iperf_{self.iperf_hostname}.log"
                self.uepc.send_command(command=cmd)
            else:
                cmd = f"iperf {IperfOptions} -c {self.iperf_hostname} -B {ip} > " + \
                      f"iperf_{self.iperf_hostname}.log"
                self.uepc.send_command(command=cmd)
            time.sleep(2)
            self.__check_tput("uepc", self.iperf_hostname)

    # @connect_decorator
    def stop_traffic(self, direction="dl",
                     remote_hostname=None,
                     remote_username=None,
                     remote_password=None,
                     remote_port="22",
                     protocol_type="udp"):
        cmd = f"ps -ef | grep iperf | grep -v grep | grep {self.ip} | awk '{{print $2}}' |xargs kill -9"
        if "dl" in direction:
            self._connect_iperf(remote_hostname,
                                remote_username,
                                remote_password,
                                remote_port)
            # ps -ef|grep iperf|grep -v grep|grep %s | awk '{print $2}' |xargs kill -9" % (port)
            # ps -ef|grep iperf | awk '{print $2}' |xargs kill -9
            self.iperf.send_command(
                command=cmd)
            if protocol_type == "tcp":
                self._connect_uepc()
                self.uepc.send_command(
                    command="ps -ef|grep 'iperf -s'| awk '{print $2}' |xargs kill -9")
        if "ul" in direction:
            self._connect_uepc()
            self.uepc.send_command(
                command=cmd)
            if protocol_type == "tcp":
                self._connect_iperf(remote_hostname,
                                    remote_username,
                                    remote_password,
                                    remote_port)
                self.iperf.send_command(
                    command="ps -ef|grep 'iperf -s'| awk '{print $2}' |xargs kill -9")


class at_operation(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    lookup_handler, at_operation_modules = aliasing_scope(
        lookup_arg='alias', lookup_type=Ue)

    def __init__(self):
        pass

    def Setup(self, ue_index=0):
        try:
            self.at_operation_modules.get(f"at_operation_{ue_index}")
        except Exception as e:
            logging.info(f"create ue alias at_operation_{ue_index}")
            self.at_operation_handler = Ue(ue_index)
            self.at_operation_modules.add(self.at_operation_handler,
                                          f"at_operation_{ue_index}")

    @lookup_handler.implicit_lookup
    def attach(self, alias):
        return alias.attach()

    @lookup_handler.implicit_lookup
    def detach(self, alias):
        return alias.detach()

    @lookup_handler.implicit_lookup
    def reboot(self, alias, timeout=150):
        return alias.reboot(timeout=timeout)

    @lookup_handler.implicit_lookup
    def start_traffic(self, alias,
                      IperfOptions,
                      direction="dl",
                      ueip=None,
                      intf_name=None,
                      remote_hostname=None,
                      remote_username=None,
                      remote_password=None,
                      remote_port="22",
                      protocol_type="udp"):
        return alias.start_traffic(direction=direction,
                                   ip=ueip,
                                   intf_name=intf_name,
                                   IperfOptions=IperfOptions,
                                   remote_hostname=remote_hostname,
                                   remote_username=remote_username,
                                   remote_password=remote_password,
                                   remote_port=remote_port,
                                   protocol_type=protocol_type)

    @lookup_handler.implicit_lookup
    def stop_traffic(self, alias,
                     direction="dl",
                     remote_hostname=None,
                     remote_username=None,
                     remote_password=None,
                     remote_port="22",
                     protocol_type="udp"):
        return alias.stop_traffic(direction=direction,
                                  remote_hostname=remote_hostname,
                                  remote_username=remote_username,
                                  remote_password=remote_password,
                                  remote_port=remote_port,
                                  protocol_type=protocol_type)

    @lookup_handler.implicit_lookup
    def start_call(self, alias, number):
        return alias.start_call(number=number)

    @lookup_handler.implicit_lookup
    def stop_call(self, alias):
        return alias.stop_call()

    @lookup_handler.implicit_lookup
    def exec_at_command(self, alias, command):
        return alias.exec_at_command(atcmd=command)

    @lookup_handler.implicit_lookup
    def get(self, alias, intf_name=None, item="ueip", *args, **kwargs):
        logging.info(kwargs)
        logging.info(f'pdp_type {kwargs.get("pdp_type")}')
        if item == "ueip":
            return alias.get_ue_ip(intf_name=intf_name)
        elif item == "apn":
            return alias.get_apn(pdp_type=kwargs.get("pdp_type"))
        else:
            raise Exception(f"Can't support get the item {item}")

    @lookup_handler.implicit_lookup
    def set(self, alias, before_intf_name, after_intf_name, item="apn"):
        return alias.set_apn(before_intf_name=before_intf_name,
                             after_intf_name=after_intf_name)

    @lookup_handler.implicit_lookup
    def teardown(self, alias):
        return alias.teardown()
