import os
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ute_fsmaccess import ute_fsmaccess
from cm import cm
from common_lib import common_lib
from taf.sbts.oam.coam.admin import admin
import traceback

os_obj = OperatingSystem()
builtin_obj = BuiltIn()
comm_obj = common_lib()


class trs_traffic_base(object):
    def __init__(self, alias):
        self._setup_trs_traffic_flag = False
        self.alias = alias
        self.bts_host = "192.168.255.129"
        self.remote_host = None

    def _setup_trs_traffic(self):
        if not self._setup_trs_traffic_flag:
            self._setup_trs_traffic_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self.cm_obj = cm()
            self.admin_obj = admin()

        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def _execute_cmd_on_gnb(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd)
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd)

    def __del__(self):
        if self._setup_trs_traffic_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def _get_mac_address(self):
        self._setup_trs_traffic()
        mac_addr_param = "MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/ETHIF_R-1:macAddr"
        if self.alias == "gnb1":
            mac_addr = self.cm_obj.get_scf_parameter_value(mac_addr_param)
        else:
            mac_addr = self.cm_obj.get_scf_parameter_value_gnb2(mac_addr_param)
        return "0x{}".format(mac_addr.replace(":", ""))

    def _start_to_capture_trs_traffic_on_backhaul(self, cap_point, user_plane):
        self._setup_trs_traffic()
        # clean env
        try:
            self._execute_cmd_on_gnb("rm -rf /lte1460/*")
            builtin_obj.log("step: stop_ip_capture_file")
            self.admin_obj.stop_ip_capture_file(alias=self.alias)
        except Exception:
            pass

        try:
            builtin_obj.log("step: start_ip_capture_file")
            measurement_point = "Transport_Interface" if cap_point == "B" else "NE_Terminated"
            self.admin_obj.start_ip_capture_file(measurement_point=measurement_point,
                                                 uplane_capturing=user_plane,
                                                 alias=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to start ip capture file", level="WARN")
            builtin_obj.log(detail)

    def _verify_ip_capture_file_generated(self):
        interval = 10
        timeout = 600
        start_time = time.time()
        while True:
            ls_out = self._execute_cmd_on_gnb("ls -ltr /lte1460/")
            if ls_out.count("pcap.gz") == 0:
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("Fail to generate pcap file under /lte1460/")
            else:
                break

    def _stop_to_capture_trs_traffic_on_backhaul(self, tag):
        self._setup_trs_traffic()
        try:
            builtin_obj.log("step: stop_ip_capture_file")
            self.admin_obj.stop_ip_capture_file(alias=self.alias)
            builtin_obj.log("step: generate_ip_capture_file")
            self.admin_obj.generate_ip_capture_file(alias=self.alias)
            self._verify_ip_capture_file_generated()
            builtin_obj.log("step: download_ip_capture_file")
            save_log_dir = comm_obj._get_save_log_dir(self.alias)
            if 'startup' in tag:
                trs_log_dir = "{}/{}_logs/trs_backhaul_logs/".format(save_log_dir, tag)
            elif len(tag) == 0:
                trs_log_dir = "{}/trs_backhaul_logs/".format(save_log_dir)
            else:
                trs_log_dir = "{}/trs_backhaul_logs_{}/".format(save_log_dir, tag)
            # failed due to proceduralState: CapturingStopped
            # self.admin_obj.download_ip_capture_file(os.path.join(trs_log_dir, "ip_traffic.pcap.gz"))
            self.fsm_obj.get_enb_file("/lte1460/*.pcap.gz",
                                      os.path.join(trs_log_dir, "ip_traffic.pcap.gz"),
                                      alias=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to stop ip capture file", level="WARN")
            builtin_obj.log(detail)


class trs_traffic_gnb1(object):

    def __init__(self):
        alias = "gnb1"
        self.trs_traffic_instance_1 = trs_traffic_base(alias)

    def start_to_capture_trs_traffic_on_backhaul(self, cap_point="B", user_plane=True):
        """
        This keyword is used to start to capture backhaul logs for trs issue.

        | Arguments   | Man. | Default | Description |
        | cap_point   | No   | B       | A: before IPSec, B: after IPSec |
        | user_plane  | No   | True    | uplane capture enable or disable |

        Examples:
         | start_to_capture_trs_traffic_on_backhaul |
         | start_to_capture_trs_traffic_on_backhaul | cap_point=A | user_plane=False |
        """
        self.trs_traffic_instance_1._start_to_capture_trs_traffic_on_backhaul(cap_point, user_plane)

    def stop_to_capture_trs_traffic_on_backhaul(self, tag=""):
        """
        This keyword is used to stop backhaul logs and generate pcap file.
        Examples:
           | stop_to_capture_trs_traffic_on_backhaul |
          """
        self.trs_traffic_instance_1._stop_to_capture_trs_traffic_on_backhaul(tag)


class trs_traffic_gnb2(object):

    def __init__(self):
        alias = "gnb2"
        self.trs_traffic_instance_2 = trs_traffic_base(alias)

    def _setup_trs_traffic_gnb2(self):
        self.trs_traffic_instance_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.trs_traffic_instance_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def start_to_capture_trs_traffic_on_backhaul_gnb2(self, cap_point="B", user_plane=True):
        """
        This keyword is used to start to capture backhaul logs for trs issue.

        | Arguments   | Man. | Default | Description |
        | cap_point   | No   | B       | A: before IPSec, B: after IPSec |
        | user_plane  | No   | True    | uplane capture enable or disable |

        Examples:
         | start_to_capture_trs_traffic_on_backhaul_gnb2 |
         | start_to_capture_trs_traffic_on_backhaul_gnb2 | cap_point=A | user_plane=False |
        """
        self._setup_trs_traffic_gnb2()
        self.trs_traffic_instance_2._start_to_capture_trs_traffic_on_backhaul(cap_point, user_plane)

    def stop_to_capture_trs_traffic_on_backhaul_gnb2(self, tag=""):
        """
        This keyword is used to stop backhaul logs and generate pcap file.
        Examples:
           | stop_to_capture_trs_traffic_on_backhaul_gnb2 |
        """
        self._setup_trs_traffic_gnb2()
        self.trs_traffic_instance_2._stop_to_capture_trs_traffic_on_backhaul(tag)


class trs_traffic(trs_traffic_gnb1, trs_traffic_gnb2):
    def __init__(self):
        trs_traffic_gnb1.__init__(self)
        trs_traffic_gnb2.__init__(self)


if __name__ == "__main__":
    trs_traffic_obj = trs_traffic()
    help(trs_traffic_obj)
