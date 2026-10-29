import os
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ute_fsmaccess import ute_fsmaccess
from cm import cm
from common_lib import common_lib
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

    def __del__(self):
        if self._setup_trs_traffic_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def _execute_cmd_on_gnb(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd)
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd)

    def _get_mac_address(self):
        self._setup_trs_traffic()
        mac_addr_param = "MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/ETHIF_R-1:macAddr"
        if self.alias == "gnb1":
            mac_addr = self.cm_obj.get_scf_parameter_value(mac_addr_param)
        else:
            mac_addr = self.cm_obj.get_scf_parameter_value_gnb2(mac_addr_param)
        return "0x{}".format(mac_addr.replace(":", ""))

    def _start_to_capture_trs_traffic_on_backhaul(self, cap_point, user_plane, output_type):
        self._setup_trs_traffic()
        builtin_obj.log("step: start trs traffic")
        self._execute_cmd_on_gnb("rm -rf /lte1460/*")
        mac_addr = self._get_mac_address()
        cmd = "/opt/trs/bin/vtc vtc_traffic_capturing_start_test {} {} {} 0 {} {}".format(
            cap_point,
            user_plane,
            output_type,
            mac_addr,
            self.alias)
        out = self._execute_cmd_on_gnb(cmd)
        try:
            builtin_obj.should_contain(out, "TC_START::Done")
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("Fail to start TRS traffic", level="WARN")
            builtin_obj.log(detail)

    def _stop_to_capture_trs_traffic_on_backhaul(self, tag):
        self._setup_trs_traffic()
        builtin_obj.log("step: stop trs traffic")
        cmd_stop = "/opt/trs/bin/vtc vtc_traffic_capturing_stop_test"
        out1 = self._execute_cmd_on_gnb(cmd_stop)
        try:
            builtin_obj.should_contain(out1, "TC_STOP::Done")
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("Fail to stop TRS traffic", level="WARN")
            builtin_obj.log(detail)

        builtin_obj.log("step: generate pcap file")
        cmd_pcap = "/opt/trs/bin/vtc vtc_traffic_capture_gen_pcap_test dummy"
        self._execute_cmd_on_gnb(cmd_pcap)
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        if 'startup' in tag:
            trs_log_dir = "{}/{}_logs/trs_backhaul_logs/".format(save_log_dir, tag)
        elif len(tag) == 0:
            trs_log_dir = "{}/trs_backhaul_logs/".format(save_log_dir)
        else:
            trs_log_dir = "{}/trs_backhaul_logs_{}/".format(save_log_dir, tag)
        interval = 10
        timeout = 120
        start_time = time.time()
        while True:
            ls_out = self._execute_cmd_on_gnb("ls -ltr /lte1460/")
            if ls_out.count("pcap.gz") == 0:
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    builtin_obj.log("Fail to generate pcap file of TRS traffic", level="WARN")
                    break
            else:
                self.fsm_obj.get_enb_file("/lte1460/*.pcap.gz", trs_log_dir, alias=self.alias)
                break


class trs_traffic_gnb1(object):

    def __init__(self):
        alias = "gnb1"
        self.trs_traffic_instance_1 = trs_traffic_base(alias)

    def start_to_capture_trs_traffic_on_backhaul(self, cap_point=1, user_plane=1, output_type=1):
        """
        This keyword is used to start to capture backhaul logs for trs issue.

        | Arguments   | Man. | Default | Description |
        | cap_point   | No   | 1       | 1: capture point B (after IPSEC); 2: capture point A (before IPSEC) |
        | user_plane  | No   | 1       | 0: Uplane capture disable; 1: Uplane capture enable |
        | output_type | No   | 1       | 1: Capturing; 2: Streaming |

        Examples:
         | start_to_capture_trs_traffic_on_backhaul |
         | start_to_capture_trs_traffic_on_backhaul | cap_point=2 | user_plane=0 |
        """
        self.trs_traffic_instance_1._start_to_capture_trs_traffic_on_backhaul(cap_point, user_plane, output_type)

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

    def start_to_capture_trs_traffic_on_backhaul_gnb2(self, cap_point=1, user_plane=1, output_type=1):
        """
        This keyword is used to start to capture backhaul logs for trs issue.

        | Arguments   | Man. | Default | Description |
        | cap_point   | No   | 1       | 1: capture point B (after IPSEC); 2: capture point A (before IPSEC) |
        | user_plane  | No   | 1       | 0: Uplane capture disable; 1: Uplane capture enable |
        | output_type | No   | 1       | 1: Capturing; 2: Streaming |

        Examples:
         | start_to_capture_trs_traffic_on_backhaul_gnb2 |
         | start_to_capture_trs_traffic_on_backhaul_gnb2 | cap_point=2 | user_plane=0 |
        """
        self._setup_trs_traffic_gnb2()
        self.trs_traffic_instance_2._start_to_capture_trs_traffic_on_backhaul(cap_point, user_plane, output_type)

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
