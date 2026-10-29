# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import os
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.Process import Process
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib import common_lib


builtin_obj = BuiltIn()
proc_obj = Process()
ssh_obj = ta_ssh_telnet()
os_obj = OperatingSystem()
comm_obj = common_lib()

CPL_DEFAULT_MSGS = [
    "0x2040-0x2079",
    "0x207e-0x207f",
    "0x2081",
    "0x2084-0x2098",
    "0x209b-0x20a7",
    "0x20a9-0x20ab",
    "0x20b1-0x20c4",
    "0x20c7-0x20dc",
    "0x20e3",
    "0x20e6-0x20ea",
    "0x20ed-0x2101",
    "0x2103-0x210a",
    "0x210d-0x212b",
    "0x2132-0x213b",
    "0x213e-0x2144",
    "0x2146-0x2147",
    "0x214a-0x217a",
    "0x217c-0x2188",
    "0x218c-0x2193",
    "0x2195-0x219e",
    "0x21a0-0x21bf",
    "0x21c2-0x237b",
    "0x237d-0x2660",
    "0x2678-0x2679",
    "0x270f-0x2800",
    "0x4200-0x42ff",
    "0x436d-0x436e",
    "0x4377-0x4378",
    "0x438d",
    "0x439d-0x43a0",
    "0x43b0-0x43b1",
    "0x43ca",
    "0x43c1-0x43c8",
    "0x45a8-0x45aa",
    "0x45b0-0x45b7",
    "0x45d2",
    "0x461c-0x461d",
    "0x461f-0x4620",
    "0x4ec0-0x4ecb",
    "0x4ecd-0x4ecf",
    "0x4f07-0x4f18",
    "0x4375-0x4376",
    "0x26e7-0x26e8",
    "0x7400-0x74ff",
    "0x750a",
    "0x259f-0x25a0",
    "0x44E9",
    "0x439b-0x439c"
]


class emil_base(object):
    def __init__(self, alias):
        self.emil_port = "15004"
        self.setup_emil_flag = False
        self.alias = alias
        self.remote_host = None
        self.pc_conn = ""
        self.emil_log_dir = ""
        self.cplane_nodes = []
        self.other_nodes = {}

    def __del__(self):
        if self.setup_emil_flag and self.pc_conn != "":
            ssh_obj.disconnect_from_host(self.pc_conn)

    def _setup_emil(self):
        if not self.setup_emil_flag:
            self.setup_emil_flag = True
            if self.alias == "enb1":
                self.rack_location = builtin_obj.get_variable_value("${RACK_POSITION}")
            elif self.alias == "enb2":
                self.rack_location = "right"
            else:
                raise Exception("Not support alias: %s" % self.alias)
            if self.remote_host is None:
                self.pc_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH",
                                                       timeout="10")
            else:
                self.pc_conn = ssh_obj.connect_to_host(self.remote_host, "22", "ute", "ute", conn_type="SSH",
                                                       timeout="10")
            # switch to test_repo virtual env
            try:
                if os.path.exists("/home/ute/test_repo/bin/activate"):
                    ssh_obj.execute_shell_command("source /home/ute/test_repo/bin/activate")
            except Exception as e:
                builtin_obj.log("enter test_repo failed: %s" % e)
            # get emil_tool path
            python_path = ssh_obj.execute_shell_command("which python")
            site_packages_path = ssh_obj.execute_shell_command("find %s -name site-packages"
                                                               % python_path.split("bin")[0])
            self.emil_tool = "%s/ta_ttitrace/resources/cli_aatrace_utility_debian" % site_packages_path
            ssh_obj.execute_shell_command("chmod +x %s" % self.emil_tool)
            self.emil_log_prefix = "CLIAATRACE"

            # Kill DCAP process
            cmd = 'DCAP_Basic_controller status'
            result = ssh_obj.execute_shell_command(cmd)
            if 'DCAP Basic health check passed' in result:
                ssh_obj.set_shell_timeout(110)
                cmd = 'DCAP_Basic_controller stop'
                ssh_obj.execute_shell_command(cmd)

    def _get_save_log_dir(self):
        if self.alias == "enb1":
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"),
                                       "emil_cli_aatrace_log")
        else:
            save_log_dir = "%s/%s/%s/" % (
              builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"), self.alias, "emil_cli_aatrace_log")
        os_obj.create_directory(save_log_dir)
        return save_log_dir

    def _kill_process_by_name(self, *keys):
        self._setup_emil()
        ps_cmd = "ps -ef | grep -v -w grep"
        for key in keys:
            ps_cmd += " | grep -i '%s'" % key
        ssh_obj.switch_host_connection(self.pc_conn)
        ssh_obj.execute_shell_command(ps_cmd)
        kill_cmd = ps_cmd + " | awk '{print $2}' | xargs kill -9"
        ssh_obj.execute_shell_command(kill_cmd)
        ssh_obj.execute_shell_command(ps_cmd)

    def _start_to_capture_emil_log(self, msgs_extend):
        self._setup_emil()
        #         if len(self.cplane_nodes) == 0:
        #             if self.alias == "enb1":
        #                 self.cplane_nodes = comm_obj.get_cplane_nodes()
        #             else:
        #                 self.cplane_nodes = comm_obj.get_cplane_nodes_enb2()
        #         if len(self.other_nodes) == 0:
        #             if self.alias == "enb1":
        #                 self.other_nodes = comm_obj.get_other_nodes()
        #             else:
        #                 self.other_nodes = comm_obj.get_other_nodes_enb2()
        if self.alias == "enb1":
            self.cplane_nodes = comm_obj.get_cplane_nodes()
        else:
            self.cplane_nodes = comm_obj.get_cplane_nodes_enb2()
        builtin_obj.log("zy: cplane nodes are %s" % self.cplane_nodes)
        if self.alias == "enb1":
            self.other_nodes = comm_obj.get_other_nodes()
        else:
            self.other_nodes = comm_obj.get_other_nodes_enb2()
        builtin_obj.log("zy: other nodes are %s" % self.other_nodes)
        self._kill_process_by_name(self.emil_tool.split("/")[-1], self.emil_port)
        msgs_extend = [msg.strip() for msg in msgs_extend if len(msg.strip()) != 0]
        self.emil_log_dir = self._get_save_log_dir()
        ssh_obj.switch_host_connection(self.pc_conn)
        ssh_obj.execute_shell_command("mkdir -p %s" % self.emil_log_dir)

        # command part 1
        hw_type = comm_obj.judge_hw_type()
        if hw_type == "R3":
            command = "%s -H r3 -c tcp_control_port=15007 -r 10000 -p %s -t 1 -u 61000 " \
                      "-a 127.0.0.1 -c printsuffix=aa_tracer" % (self.emil_tool, self.emil_port)
        else:
            command = "%s -H r4 -f 1 -s 1 -c tcp_control_port=15007 -r 10000 -p %s -t 1 -u 61000 " \
                      "-a 127.0.0.1 -c printsuffix=aa_tracer" % (self.emil_tool, self.emil_port)

        # command part 2.1: cplane messages
        other_nodes_msgs = []
        cpl_msgs = CPL_DEFAULT_MSGS
        for msg in msgs_extend:
            if msg.count("-n") == 0:
                cpl_msgs.append(msg)
            else:
                if msg.count("mac") or msg.count("phy"):
                    if len(self.other_nodes):
                        node_name = msg.split()[1]
                        for node_id in self.other_nodes[node_name.lower()]:
                            other_nodes_msgs.append("-n %s %s" % (node_id, msg.partition(node_name)[-1]))
                else:
                    other_nodes_msgs.append(msg)

        builtin_obj.log("zy: to capture cplane messages:%s" % cpl_msgs)
        builtin_obj.log("zy: to capture other node messages: %s" % other_nodes_msgs)

        for node in self.cplane_nodes:
            command = command + " -n %s" % node
            for msg in cpl_msgs:
                if len(msg.strip()) != 0:
                    command = command + " -e %s" % msg

        # command part 2.2: other messages
        command = command + " " + " ".join(other_nodes_msgs)

        # command part 3
        command = command + \
            " -l ERR -r 300 -b %s/%s.backtrace -o %s/%s.bin -i 2>%s/%s_output.log" % (
                self.emil_log_dir,
                self.emil_log_prefix,
                self.emil_log_dir,
                self.emil_log_prefix,
                self.emil_log_dir,
                self.emil_log_prefix)

        # update command according to  rack location
        if self.rack_location.lower().count("left"):
            command = command.replace("-n 2", "-n 1").replace("-n 0x2", "-n 1")
        elif self.rack_location.lower().count("right"):
            command = command.replace("-n 1", "-n 2").replace("-n 0x1", "-n 2")

        # start emil command
        ssh_obj.switch_host_connection(self.pc_conn)
        ssh_obj.execute_shell_command("nohup %s &" % command)

    def _stop_capture_emil_log(self):
        self._setup_emil()
        ssh_obj.switch_host_connection(self.pc_conn)
        self._kill_process_by_name(self.emil_tool.split("/")[-1], self.emil_port)
        if self.remote_host is not None:
            # local create self.emil_log_dir and download emil logs from other control pc
            os_obj.create_directory(self.emil_log_dir)
            local_pc_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")
            ssh_obj.execute_shell_command(
                "scp -r %s:%s/* %s" % (self.remote_host, self.emil_log_dir, self.emil_log_dir))
            ssh_obj.disconnect_from_host(local_pc_conn)


class emil_bts1(object):

    def __init__(self):
        alias = "enb1"
        self.emil_base_instance_1 = emil_base(alias)

    def start_to_capture_emil_log(self, msgs_extend=[]):
        """This keyword is to start to capture emil log by using cli_aatrace_utility_debian command
        | Input Parameters | Man. | Description |
        | msgs_extend  | No   | parameters list specified which msgs should be captured |

        format of msgs_extend
        | 1) | message_id | single message in nodes where cplane locates |
        | 2) | message_id_start-message_id_end |  continuous messages in nodes where cplane locates |
        | 3) | -n node -e message_id -e message_id_start-message_id_end ... | messages in specified nodes
               node could be node id or node name (mac, phy) |

        Example:
        | ${msgs_extend} | Create List | 0x45d2 | 0x2040-0x2079 |  -n 0x223D -e 0x43ca -e 0x4ecd-0x4ecf |
          -n mac -e 0x1234 -e 0x1345-0x135a |
        | start_to_capture_emil_log | ${msgs_extend} |

        Note:
        | if msgs_extend is empty, some default emil messages received /sent by cplane SC are captured. |
        | if msgs_extend is not empty, the specified messages in msgs_extend are also captured besides default
          emil messages. |
        """
        if builtin_obj.get_variable_value('${EMIL_FLAG}') is not True:
            return
        self.emil_base_instance_1._start_to_capture_emil_log(msgs_extend)

    def stop_capture_emil_log(self):
        if builtin_obj.get_variable_value('${EMIL_FLAG}') is not True:
            return
        self.emil_base_instance_1._stop_capture_emil_log()


class emil_bts2(object):

    def __init__(self):
        alias = "enb2"
        self.emil_base_instance_2 = emil_base(alias)

    def _setup_emil_bts2(self):
        self.emil_base_instance_2.bts_host = builtin_obj.get_variable_value('${ENB2_IP}')  # S1 IP
        self.emil_base_instance_2.remote_host = builtin_obj.get_variable_value('${ENB2_PC_IP}')

    def start_to_capture_emil_log_enb2(self, msgs_extend=[]):
        """This keyword is to start to capture emil log by using cli_aatrace_utility_debian command
        | Input Parameters | Man. | Description |
        | msgs_extend  | No   | parameters list specified which msgs should be captured |

        format of msgs_extend
        | 1) | message_id | single message in nodes where cplane locates |
        | 2) | message_id_start-message_id_end |  continuous messages in nodes where cplane locates |
        | 3) | -n node -e message_id -e message_id_start-message_id_end ... |
               messages in specified nodes. node could be node id or node name (mac, phy) |

        Example:
        | ${msgs_extend} | Create List | 0x45d2 | 0x2040-0x2079 |  -n 0x223D -e 0x43ca -e 0x4ecd-0x4ecf |
          -n mac -e 0x1234 -e 0x1345-0x135a |
        | start_to_capture_emil_log | ${msgs_extend} |

        Note:
        | if msgs_extend is empty, some default emil messages received /sent by cplane SC are captured. |
        | if msgs_extend is not empty, the specified messages in msgs_extend are also captured besides
          default emil messages. |
        """
        self._setup_emil_bts2()
        self.emil_base_instance_2._start_to_capture_emil_log(msgs_extend)

    def stop_capture_emil_log_enb2(self):
        self._setup_emil_bts2()
        self.emil_base_instance_2._stop_capture_emil_log()


class emil(emil_bts1, emil_bts2):
    def __init__(self):
        emil_bts1.__init__(self)
        emil_bts2.__init__(self)


if __name__ == "__main__":
    pass
