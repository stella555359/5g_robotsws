# -*- coding: utf-8 -*-
"""
:author: Yonna Yao
:contact: yonna.yao@nokia-sbell.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
"""

import os
import re
import six
import time
import logging
import paramiko
import pkg_resources
from ta_ttitrace import ta_ttitrace
from tak_config import *
from taf.sbts.oam.coam.admin import admin
from ute_fsmaccess import ute_fsmaccess
from ute_common_store.store import Store
from tak_core import tak_core


DEFAULT_CMESSAGE = ["0x2040-0x2079", "0x207e-0x207f", "0x2081", "0x2084-0x2098", "0x209b-0x20a7", "0x20a9-0x20ab",
                    "0x20b1-0x20c4", "0x20c7-0x20dc", "0x20e3", "0x20e6-0x20ea", "0x20ed-0x2101", "0x2103-0x210a",
                    "0x210d-0x212b", "0x2132-0x213b", "0x213e-0x2144", "0x2146-0x2147", "0x214a-0x217a",
                    "0x217c-0x2188", "0x218c-0x2193", "0x2195-0x219e", "0x21a0-0x21bf", "0x21c2-0x237b",
                    "0x237d-0x2660", "0x2678-0x2679", "0x270f-0x2800", "0x4200-0x42ff", "0x436d-0x436e",
                    "0x4377-0x4378", "0x438d", "0x439d-0x43a0", "0x43b0-0x43b1", "0x43ca", "0x43c1-0x43c8",
                    "0x45a8-0x45aa", "0x45b0-0x45b7", "0x45d2", "0x461c-0x461d", "0x461f-0x4620", "0x4ec0-0x4ecb",
                    "0x4ecd-0x4ecf", "0x4f07-0x4f18", "0x4375-0x4376", "0x26e7-0x26e8", "0x7400-0x74ff", "0x750a",
                    "0x259f-0x25a0", "0x44E9", "0x439b-0x439c"]


class EmilLog(object):

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.store = Store()
        tool_name = 'cli_aatrace_utility_debian'
        self.tool_path = os.path.join(pkg_resources.resource_filename('ta_ttitrace', "resources"), tool_name)
        self.udp_port = 61000
        self.enb_port = 15004
        self.udp_addr = '127.0.0.1'
        self.log_prefix = "KISSCLIAATRACE"

    def start_emil_log(self, aashell_port=15007, remote_host="127.0.0.1", fsm_ip='192.168.255.129', extend_msg=[],
                       alias="enb1"):
        self.remote_host = remote_host
        self._stop_running_process(remote_host)
        self._ensure_ttitracers_are_executable(remote_host)
        save_path = self._create_save_log_path(alias, remote_host)
        command = self._generate_command(save_path, aashell_port, extend_msg, fsm_ip, remote_host)
        self._execute_command_by_ssh("nohup {} &".format(command), remote_host)
        self.store.add({'save_dir': save_path, 'remote_host': remote_host}, alias)

    def stop_emil_log(self, alias="enb1"):
        remote_host = self.store.get(alias)["remote_host"]
        save_path = self.store.get(alias)["save_dir"]
        self._stop_running_process(remote_host)
        self._copy_remote_emil_log_to_local(save_path, remote_host)
        return save_path

    def _copy_remote_emil_log_to_local(self, save_path, remote_host):
        if remote_host != "127.0.0.1":
            if not os.path.exists(save_path):
                os.system("mkdir -p {}".format(save_path))
            cp_cmd = "scp -r {user}@{host}:{dir}/* {dir}".format(user='ute', host=remote_host, dir=save_path)
            self._execute_command_by_ssh(cp_cmd)

    def _generate_command(self, save_path, aashell_port, extend_msg, fsm_ip, remote_host):
        hw = self._get_hw_type(remote_host, fsm_ip)
        base_command = self._base_command(hw)
        extend_command = self._add_extend_message_id_in_command(aashell_port, fsm_ip, extend_msg)
        save_path_command = self._add_save_directory_and_prefix(save_path)
        total_command = base_command + extend_command + save_path_command
        return self._adapt_smod_postion_in_command(total_command, fsm_ip, remote_host)

    def _base_command(self, hw):
        cmd_section_1 = '-H r3' if hw == 'r3' else '-H r4 -f 1 -s 1'
        command = "{tool} {cmd_add} -c tcp_control_port=15007 -r 10000 -p {tcp_port} -t 1 -u {udp_port} -a {udp_addr}" \
                  " -c printsuffix=aa_tracer".format(tool=self.tool_path, cmd_add=cmd_section_1, tcp_port=self.enb_port,
                                                     udp_port=self.udp_port, udp_addr=self.udp_addr)
        return command

    def _add_extend_message_id_in_command(self, aashell_port, fsm_ip, extend_msg):
        all_cmsg = DEFAULT_CMESSAGE
        extend_nodes_msgs = []
        command_add = ''
        self._log.debug("extend_msg:{}".format(extend_msg))
        cplane_nodes, mac_node, phy_node = self._connect_to_enb_and_get_nodes(fsm_ip, aashell_port)
        self._log.info("Cplane Node:{}, mac node:{}, phy_node:{}".format(cplane_nodes, mac_node, phy_node))
        if isinstance(extend_msg, six.string_types):
            extend_msg = [extend_msg]
        for msg in extend_msg:
            if "-n" not in msg:
                all_cmsg.append(msg)
            else:
                extend_nodes_msgs.append(msg)
        for node in cplane_nodes:
            command_add += " -n {}".format(node)
            for m in all_cmsg:
                if len(m.strip()) != 0:
                    command_add += " -e {}".format(m)
        command_add = command_add + " " + " ".join(extend_nodes_msgs)
        return self._adapt_mac_and_phy_node_in_command(command_add, mac_node, phy_node)

    def _adapt_mac_and_phy_node_in_command(self, msg, mac_node, phy_node):
        new_msg = ''
        for item in msg.split():
            new_msg = new_msg + " " + self._transfer_string_to_node(item, mac_node, phy_node)
        return new_msg

    def _transfer_string_to_node(self, str, mac_node, phy_node):
        if "mac-cell-" in str:
            if str.split("-")[2] not in mac_node.keys():
                raise Exception("cell id is not correct.")
            node = mac_node[str.split("-")[2]][str.split("-")[3]]
            self._log.debug("{} -> {}".format(str, node))
            return node
        if "phy-cell-" in str:
            if str.split("-")[2] not in phy_node.keys():
                raise Exception("cell id is not correct.")
            node = phy_node[str.split("-")[2]][str.split("-")[3]]
            self._log.debug("{} -> {}".format(str, node))
            return node
        return str

    def _add_save_directory_and_prefix(self, save_path):
        dir_command = " -l ERR -r 300 -b {save_dir}/{tag}.backtrace -o {save_dir}/{tag}.bin -i" \
                      " 1>{save_dir}/output.log 2>&1".format(save_dir=save_path, tag=self.log_prefix)
        return dir_command

    def _create_save_log_path(self, alias, remote_host):
        save_dir = os.path.join(test_log_directory(), alias)
        if not os.path.exists(save_dir):
            self._execute_command_by_ssh("mkdir -p {}".format(save_dir), remote_host)
        return save_dir

    def _get_hw_type(self, remote_host, fsm_ip):
        """Get eNB bbu type.
         """
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        enbfsm = ute_fsmaccess()
        enbfsm.setup_enb_fsm_access(host=fsm_ip, fallback_prompt='#', remote_host=remote_host, alias='unit')
        rru = enbfsm.execute_command_on_enb(cmd, False, alias='unit').rstrip('\x00')
        enbfsm.teardown_enb_fsm_access(alias='unit')
        return self._rru_map_to_hw_type(rru)

    def _rru_map_to_hw_type(self, rru):
        version3 = ['FSMF', 'FSIH']
        # version4 = ['ASIA', 'ASIB', 'FSIP', 'ABIA', 'ASIK', 'ABIL', 'ASOD', 'ASIL', 'ASOE',
        #            'ASOF','ABIN', 'ABIO', 'ASIM', 'ABIP', 'ASOG', 'ASOH']
        logging.info("HW is :{}".format(rru))
        return 'r3' if rru in version3 else 'r4'

    def _get_smod_postion(self, fsm_ip, remote_host):
        coam_admin = admin()
        coam_admin.setup_admin(bts_host=fsm_ip, name='get_postion', remote_host=remote_host)
        postion_index = coam_admin.get_smod_position(connection="get_postion")
        coam_admin.teardown_admin(connection="get_postion")
        self._log.info("smod_postion:{}".format(postion_index))
        return postion_index

    def _adapt_smod_postion_in_command(self, command, fsm_ip, remote_host):
        postion = self._get_smod_postion(fsm_ip, remote_host)
        if postion == 'left':
            command = command.replace("-n 2", "-n 1").replace("-n 0x2", "-n 1")
        elif postion == 'right':
            command = command.replace("-n 1", "-n 2").replace("-n 0x1", "-n 2")
        else:
            self._log.warning("Please check! Smod Postion is {}!".format(postion))
        return command

    def _stop_running_process(self, remote_host):
        self._log.info("Before start Emil log, kill running {} by port {}".format(self.tool_path, self.enb_port))
        cmd = "timeout 5 sudo kill -9 $(ps -ef|grep %s|grep %s|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1" % \
              (self.tool_path, self.enb_port)
        self._execute_command_by_ssh(cmd, remote_host)

    def _ensure_ttitracers_are_executable(self, remote_host):
        self._execute_command_by_ssh('sudo chmod u+x {}'.format(self.tool_path), remote_host)

    def _connect_to_enb_and_get_nodes(self, fsm_ip, port):
        try:
            conn = paramiko.SSHClient()
            conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            conn.connect(fsm_ip, username="toor4nsn", password="oZPS0POrRieRtu")
            # get cplane node
            cmd = "echo 'proc #0xFFFF' | nc 127.0.0.1 {}".format(port)
            self._log.info(cmd)
            stdin, stdout, stderr = conn.exec_command(cmd)
            self._log.info("[proc #0xFFFF]stderr:{}".format(stderr.read()))
            proc_info = stdout.read() if six.PY2 else stdout.read().decode()
            cplane_node, rrom_node = self._get_cplane_process_node(proc_info)
            # get mac and phy node
            cmd = "echo 'getCellMapping @RROMexe #{}' | nc 127.0.0.1 {}".format(rrom_node, port)
            self._log.info(cmd)
            stdin, stdout, stderr = conn.exec_command(cmd)
            self._log.info("[getCellMapping]stderr:{}".format(stderr.read()))
            cell_mapping = stdout.read() if six.PY2 else stdout.read().decode()
            mac_node, phy_node = self._get_mac_and_phy_node_from_cellmapping(cell_mapping)
            return cplane_node, mac_node, phy_node
        except Exception as e:
            self._log.info(e)
            raise Exception("Connect to enb and get nodes fail!You can change another port to try again.")
        finally:
            conn.close()

    def _get_cplane_process_node(self, info):
        cplane_node = []
        cplane_proc = ["RROM", "ENBC", "CELLC", "UEC", "TUPC"]
        for line in info.strip().splitlines():
            if "node" in line:
                node = re.findall(r"node: (.*) .*", line)[0]
                continue
            if "RROM" in line:
                rrom_node = node
            target_node = [node for c in cplane_proc if line.upper().startswith(c)]
            cplane_node += target_node
        return list(set(cplane_node)), rrom_node

    def _get_mac_and_phy_node_from_cellmapping(self, cellmapping):
        cell_mapping = re.search('(lcr lnCel.*\n[\\w\\s.-]+)\n', cellmapping, re.MULTILINE).group(1)
        self._log.debug(cellmapping)
        tables = cell_mapping.splitlines()[0].split()
        mac_node = {}
        phy_node = {}
        for index in range(0, len(tables)):
            if "MACULTTI" == tables[index]:
                mac_ul_index = index
            if "MACDLTTI" == tables[index]:
                mac_dl_index = index
            if "UL-PHY" == tables[index]:
                phy_ul_index = index
            if "DL-PHY" == tables[index]:
                phy_dl_index = index
        for line in cell_mapping.splitlines()[1:]:
            mac_node[line.split()[0]] = {'ul': line.split()[mac_ul_index][0:6], 'dl': line.split()[mac_dl_index][0:6]}
            phy_node[line.split()[0]] = {'ul': line.split()[phy_ul_index][0:6], 'dl': line.split()[phy_dl_index][0:6]}
        return mac_node, phy_node

    def _execute_command_by_ssh(self, command, remote_host):
        """
        """
        ssh_client = tak_core().execute(remote_host, 'ute', 'ute')
        try:
            ssh_client._setup()
            command = command.encode('utf-8') if six.PY3 else command
            ssh_client.execute(command)
        except Exception as e:
            raise Exception("{} execute fail!Detail is {}".format(command, str(e)))
        finally:
            ssh_client._teardown()
