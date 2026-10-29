import re
import os
import filecmp
import difflib
import paramiko
import random
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
import testsuite.Oulu.TrunkEng.Common.Python.Resources.virtual_node_applications as vn
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (PIDNotFound, ScriptIssue, SSHConnectionFailure,
                                                                        EnvironmentIssue, ComparisonFailure)
from taf.transport.ssh.exceptions import (CommandOutputTimeoutError, CommandExecutionError, ConnectFailedError,
                                          ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                                          CommandOutputCollectionTerminationError)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)

# Running in SMOD
critical_processes = ["bm", "BTSOMexe", "DCS", "DEM", "FRI", "HAS", "LTS", "MCI",
                      "MCtrl", "SWM", "SysAdapter", "BStat", "FaultServiceExe", "PMStat"]
# BStat is replaced with PMStat

# Running in CentralCPlane virtual node in SMOD
central_c_plane_virtual_processes = ["ENBC", "FaultServiceExe", "MCEC", "RROM", "TUPc"]

# Application running in virtual nodes in SMOD&BBMOD
# F.ex
# ASIA: D_CPNODE: "FaultServiceExe", "CellCExe", "UECexe"
# ASIL: D_CPNODE: "FaultServiceExe", "CellCExe", "UECexe"
# ABIA: FDDMACNODE: CCSEmDispatcherExe
# ABIN/O/P:
#    FDDMACNODE: CCSEmDispatcherExe
#    LTEL2NODE: CCSEmDispatcherExe
#    D_CPNODE: "FaultServiceExe", "CellCExe", "UECexe"
#    CRMNODE: CRMexe
other_virtual_processes = ["FaultServiceExe", "CellCExe", "UECexe", "CCSEmDispatcherExe", "CRMexe"]


class Applications(object):
    """
    Applications offers an interface for killing applications on BTS units.
    Critical applications (critical_processes) running in SMOD are causing spurious reset in eNodeB.
    Applications running in CentralCPlane virtual node in SMOD are causing RAT/Site autonomous reset in eNodeB.
    Application running in virtual nodes (DCPNODE, LTEL2NODE, FDDMACNODE, CRMNODE) (on SMOD/BBMOD)
    are causing Internal BTS process autonomous reset in SMOD/BBMOD.
    """

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.fsp_ips = BuiltIn().get_library_instance("FSP")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.logger = BuiltIn().get_library_instance("LOG")

        self.nodes_applications_pids = None
        self.node_id_sw_node = None

    def make_bts_ssh_connection(self):
        """
        Make bts ssh connection. If connection is successfully created to SMOD return,
        otherwise raise SSHConnectionFailure.
        """
        try_ctr = 0
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        e = None
        for try_ctr in range(1, 5):
            try:
                self.ssh.take_ssh_connection("192.168.255.129", "SMOD")
                return
            except (ConnectFailedError, SSHConnectionFailure, CommandOutputTimeoutError, CommandExecutionError,
                    ConnectFailedError, CommandOutputCollectionError, FileProtocolClientError, TimeoutError,
                    CommandOutputCollectionTerminationError, paramiko.ssh_exception.SSHException, EOFError) as e:
                BuiltIn().sleep("5s")
                info(f"Could not make SSH connection to SMOD ({e.__class__.__name__}:{e}). Remove known_hosts."
                     f"Trying again.")
                self.logger.debug(''.join(format_exception(type(e), e, e.__traceback__)))
                print(''.join(format_exception(type(e), e, e.__traceback__)))
                if try_ctr > 2:
                    self.ssh.delete_known_host_file(also_rsa=True)
                    self.ssh.close_all_ssh_connections()
                else:
                    self.ssh.delete_known_host_file()
                BuiltIn().sleep("1s")
        if try_ctr == 4:
            if e:
                error(f"{loop}Could not make SSH connection to SMOD. {e.__class__.__name__}:{e}")
                info(''.join(format_exception(type(e), e, e.__traceback__)))
            else:
                error(f"{loop}Could not make SSH connection to SMOD.")
        raise SSHConnectionFailure("Could not make SSH connection to SMOD.")

    def close_bts_ssh_connection(self):
        self.ssh.close_ssh_connection("SMOD")

    def get_virtual_sw_node(self, node, unit="", selected_node_id=""):
        """
        Get all SW_NODEs of virtual node and return the first one.

        :param str node: Virtual node. For example DistributedCPlane, CentralCPlane, UPlane, FHNET.
        :param str unit: (OPTIONAL) Unit where virtual node is. Can be as for example:
                         SMOD/SMOD1/SMOD2/ABIN1/ABIO2/ABIP3/ABIA2.1/ABIO2.3...
                         If empty string, unit is SMOD. If not fullrack, SMOD is for left and right side SMOD.
                         If fullrack environment SMOD and SMOD1 are left side and SMOD2 is right side.
                         In fullrack environments if unit is empty, left side SMOD is selected.
        :param str selected_node_id: (OPTIONAL) Node ID of virtual node. Can have for example values:
                                     0x101b, 0x1016, 0x1015...
        """
        vns_with_specific_vnu = vn.get_all_virtual_nodes_with_specific_vnu_variant(self, node)
        sw_nodes = []
        for virtual_node in vns_with_specific_vnu:
            # TODO if later we want to select special SW_NODE, we can check for example that it has cell resources here
            _, __, node_id, ___, sw_node = virtual_node
            node_id = str(hex(int(node_id)))
            if selected_node_id:
                if node_id == selected_node_id:
                    if sw_node not in sw_nodes:
                        sw_nodes.append(sw_node)
            else:
                bbmod_names = ['BBMOD', "ABIA", "ABIO", "ABIC", "ABIN", "ABIP", "ABIQ", "ABIL"]
                if any(b for b in bbmod_names if b in unit):
                    bci_object = self.bts.get_bbmod_object_from_user_given_values(unit)
                    expected_hexs = self._expected_hex_name(bci_object.name)
                else:
                    expected_hexs = self._expected_hex_name(unit)
                print(f"Search hexs: {expected_hexs}")
                if node_id[:4] in expected_hexs:
                    print(f"Node ID is {node_id} and it is on {unit}")
                    if sw_node not in sw_nodes:
                        sw_nodes.append(sw_node)
        if sw_nodes:
            sw_nodes.sort(key=lambda x: int(x.split("-")[1]) if x and "-" in x else 0)
            text = "SMOD" if not unit else unit
            info(f"All SW_NODEs of virtual node {node} on {text} are {sw_nodes}, returning  {sw_nodes[0]}.")
            return sw_nodes[0]
        else:
            error(f"No SW_NODE found for virtual node {node} on {unit}. Check specs if the HW should have {node}.")
            raise ScriptIssue(f"No SW_NODE found for virtual node {node} on {unit}.")

    def get_virtual_pids(self, node, unit="", selected_sw_node="", selected_soc="K2A", ipv6=False):
        """
        Choose unit from self.bts.bbmods if bbmod, then we can call get_ip_of_selected_fsp in FspIP.
        vnu_variant can be CentralCPlane, DistributedCPlane, UPlane and FHNET.

        :param str node: Virtual node.
        :param str unit: Unit where virtual node is, empty string if not given. Can be given as ABIN1/ABIO1/ABIP1...
                         or BBMOD1 (bottom unit of rack), BBMOD2 (middle unit of rack) or BBMOD3 (top unit of rack) or
                         SMOD1 or SMOD2 (fullrack).
        :param str selected_sw_node: SW node, for example SW_NODE_L-3. Selected randomly if not given.
        :param str selected_soc: SoC of unit, K2A if not given.
                                 Can be K2A, K2B, K2C, K2D, SNF, LOKI#A, LOKI#B, LFA, LFB, LUNUM, Thor, Marlin.
        :param bool ipv6: Give IP in IPv4 or IPv6. False/IPv4 if not given.

        :return list: virtual PIDs that match the requirements.
        """
        try:
            vns_with_specific_vnu = vn.get_all_virtual_nodes_with_specific_vnu_variant(self, node)
            node_ids = {}
            for virtual_node in vns_with_specific_vnu:
                _, __, node_id, ___, sw_node = virtual_node
                node_id = str(hex(int(node_id)))
                if sw_node == selected_sw_node or not selected_sw_node:
                    node_ids[node_id] = sw_node
            info("Found node IDs that match the requirements given by tester: {}".format(node_ids))
            self.node_id_sw_node = node_ids
            if unit and isinstance(unit, str) and (("BBMOD" in unit) or ("ABI" in unit)):
                unit = self.bts.get_bbmod_object_from_user_given_values(unit)
            elif unit and isinstance(unit, str) and (("SMOD" in unit) or ("ASI" in unit)):  # else unit is object
                unit = self.bts.get_smod_object(unit)
            if unit and selected_soc == "K2A" and hasattr(unit, "primary_soc"):
                self.logger.debug(f"selected_soc == K2A -> selected soc is not given. Select primary soc of {unit.name}"
                                  f" that is {unit.primary_soc}")
                selected_soc = unit.primary_soc
            self.nodes_applications_pids = vn.get_node_swpool_application_and_pid(self, unit, selected_soc, ipv6)
            info("All nodes, applications and PIDs for selected unit and SoC: {}".format(self.nodes_applications_pids))
            virtual_pids = vn.get_virtual_pids_from_nodes_applications_pids(self.nodes_applications_pids, node_ids)
            if not virtual_pids:
                if not unit:
                    self.logger.debug("No unit selected -> unit = SMOD")
                    unit = "SMOD"  # SMOD if not chosen
                info("Could not find any virtual nodes for chosen unit '{}'.".format(unit))
            info("Found virtual PIDs: {}".format(virtual_pids))
            return virtual_pids
        except (TypeError, KeyError, AttributeError) as e:
            error(f"Unable to get virtual pids. {e.__class__.__name__}:{e}")
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            raise ScriptIssue(f"{e.__class__.__name__}:{e}")

    def get_virtual_pid_of_application(self, application, virtual_pids):
        if application == "random":
            return self._choose_random_application(virtual_pids)
        else:
            return self._find_virtual_application_pid(application, virtual_pids)

    def kill_virtual_process(self, unit, application, pid):
        kill_method = "11" if ('ASI' in unit or 'FSIP' in unit) else "9"
        info("Kill virtual process {} with 'kill -{} {}'".format(application, kill_method, pid))
        alias = "SMOD" if not unit else "chosen_unit"
        self.ssh.send_command_to_ip_return_output("kill -{} {}".format(kill_method, pid), alias)

    def kill_application(self, pid, application, alias="SMOD"):
        """
        Kill application from real node.
        Checks after kill that the application is killed, and makes a re-attempt if not.

        :param str pid: Application PID.
        :param str application: Name of application being killed.
        :param str alias: Name of alias used for ssh connections.
        """
        info("Kill application {} with 'kill -9 {}'".format(application, pid))
        self.ssh.send_command_to_ip_return_output("kill -9 {}".format(pid), alias)

    def select_realtime_process(self, process_list):
        closest_to_root = ""
        return_pid = ""
        for p in process_list:
            pid, empy = p
            if not closest_to_root:
                closest_to_root = len(str(empy))
                return_pid = str(pid)
            if len(str(empy)) < len(str(closest_to_root)):
                self.logger.debug("{} is closer than {} ({}<{})".format(empy, closest_to_root, len(empy),
                                                                        len(closest_to_root)))
                return_pid = pid
        self.logger.debug("Pid {} is closest to root -> realtime application".format(return_pid))
        return return_pid

    def find_real_application_pid(self, application, alias="SMOD"):
        """
        Searches pid of realtime application.

        :param str application: Name of application that's pid is searched.
        :param str alias: Name of alias used for ssh connections.
        """
        self.ssh.send_command_to_ip_return_output("ps auxf -w -w", alias=alias)
        if not application:
            error("Application is NOT given to method find_real_application_pid.")
            raise ScriptIssue
        pid = self.ssh.send_command_to_ip_return_output("pgrep {}".format(application), alias=alias)
        if pid and "pgrep: no matching criteria specified" not in pid and len(pid.strip().split()) > 1:
            self.logger.debug("More than one PID found with command 'pgrep {}': {}.".format(application, pid))
            paux_pid = self.ssh.send_command_to_ip_return_output("ps auxf -w -w|grep {}".format(application),
                                                                 alias=alias)
            paux_pid_list = paux_pid.split('\n') if paux_pid else []
            pid_found, pid = self._search_pid(paux_pid_list, application)
            if not pid_found:
                self.logger.debug(
                    r"There may be problems with regex. Current regex is:\n "
                    r".*(root|btssw)\s+(?P<PID>\d+).*(?P<time>\d+:\d+)(?P<empty>\s+|(\s+\|\s+)+)"
                    r"(?P<application>/opt/{}/{}).* \nand output to which it is matched is:\n {}".format(
                        application.replace("exe", ""), application, paux_pid))
                pid = ""
        if not pid:
            paux_pid = self.ssh.send_command_to_ip_return_output("ps auxf -w -w|grep {}".format(application),
                                                                 alias=alias)
            paux_pid_list = paux_pid.split('\n') if paux_pid else []
            process_pattern = re.compile(r"\w+\s+(?P<process_id>\d+)\s+.*{}.*".format(application))
            if application == "CCSDaemonExe":  # is found multiple times with different ports
                process_pattern = re.compile(r".*root\s+(?P<process_id>\d+).*/opt/CCS/CCSDaemonExe.*-c.*15007")
            for ps in paux_pid_list:
                match = process_pattern.match(ps)
                if match and match.group("process_id"):
                    self.logger.debug("Regex matched to {}".format(ps))
                    pid = match.group("process_id")
                    break
        if not pid or "pgrep: no matching criteria specified" in pid:
            error("{} PID was not found.".format(application))
            raise PIDNotFound
        info("PID of {} is {}".format(application, pid))
        return pid.strip()

    def kill_ccsemdispatcherexe_from_bbmod(self, bci):
        """
        Kill CCSEmDispatcherExe from given BBMOD.
        Take ssh connection to smod, take ssh connection to BBMOD do lxc-attach to BBMOD and give commands.

        :param obj bci: BBMOD unit object (from BTS.py)
        """
        if not any(bbmod for bbmod in ["ABIP", "ABIN", "ABIO", "ABIQ"] if bbmod in bci.name):
            warning("Killing of CCSEmDispatcherExe -test is planned for primary SOC of ABIP/ABIN/ABIO/ABIQ. You are "
                    "running test with {} so functionality is not guaranteed.".format(bci.name))
        fsp_ip = self.fsp_ips.get_ip_of_selected_fsp(bci.name, bci.primary_soc)
        info("Check if FSP pings before trying to send commands.")
        self.bts.ping_ip_from_smod(fsp_ip)
        enb_ssh = self.ssh.ssh_connection_to_smod()
        fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
        lxc, _ = self._find_lxc_with_ccsemdispatcherexe_in_it(fsp_ssh, bbmod=True)
        attach_command = rf"lxc-attach -n {lxc}"
        info(f"Perform lxc-attach with '{attach_command}'")
        attach_success = False
        attach_attempt = 0
        while not attach_success and attach_attempt < 10:
            # more attempts required after site reset to get connection
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, attach_command, ssh_timeout=60)
            self.logger.debug(f"Output from attach command: {output}")
            if "Connection refused" in output:
                self.logger.debug(f"Could not perform lxc-attach, connection refused.")
                attach_attempt += 1
                BuiltIn().sleep("5s")
            else:
                attach_success = True
        if attach_success:
            kill_app_command = r"kill -SIGABRT $(echo $(ps -x | grep CCSEmDispatcherExe) | cut -d ' ' -f 1)"
            info(f"Kill application with '{kill_app_command}'")
            self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, kill_app_command, ssh_timeout=60)
        else:
            error("Could not perform lxc-attach to BBMOD, cannot perform application kill.")
            raise SSHConnectionFailure("Could not perform lxc-attach to BBMOD, cannot perform application kill.")
        self.ssh.disconnect_ssh_connection(fsp_ssh)

    def kill_faultserviceexe_from_abia(self, bci, soc=""):
        """
        Kills FaultServiceExe from given BBMOD.
        Takes SSH connection to BBMOD using SMOD connection as proxy, then finds and kills FaultServiceExe.
        :param obj bci: BBMOD unit object (from BTS.py)
        :param str soc: (Optional) BBMOD SoC. If not given, primary SoC is used.
        """
        pid = ""
        fsp_ssh = None
        if "ABIA" not in bci.name:
            warning(f"Trying to kill FaultServiceExe from unit {bci.name}. "
                    f"Success with {bci.name} is not guaranteed, because functionality is designed only for ABIA.")
        soc = soc if soc else bci.primary_soc
        fsp_ip = self.fsp_ips.get_ip_of_selected_fsp(bci.name, soc)
        info(f"FSP IP of {bci.name} - {soc}: {fsp_ip}")
        pid_search_command = "ps auxf -w -w"
        attempt_counter = 0
        while not pid and attempt_counter < 5:
            enb_ssh = self.ssh.ssh_connection_to_smod()
            fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
            self.logger.debug(f"Trying to find PID of FaultServiceExe (attempt {attempt_counter+1})")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, pid_search_command, ssh_timeout=360)
            pid = self._search_faultserviceexe_from_output(output, pid)
            attempt_counter += 1
            BuiltIn().sleep("1s")
            if not pid:
                self.ssh.disconnect_ssh_connection(fsp_ssh)

        if pid:
            info(f"Kill application with 'kill -9 {pid}'")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, f"kill -9 {pid}", ssh_timeout=60)
            if "No such process" in output:
                error(f"Could not kill application: {output}")
            else:
                info("Kill successful.")
        else:
            error(f"No PID found for FaultServiceExe from unit {bci.name}.")
            raise PIDNotFound(f"No PID found for FaultServiceExe from unit {bci.name}.")
        self.ssh.disconnect_ssh_connection(fsp_ssh)

    def kill_real_application_from_soc(self, bci, soc, application):
        """
        Kills application from real node.
        Takes SSH connection to SMOD, then SoC, then finds and kills the application.

        :param obj bci: BBMOD unit object (from BTS.py)
        :param str soc: SoC of BBMOD.
        :param str application: Application to be killed.
        """
        pid = ""
        fsp_ssh = None

        fsp_ip = self.fsp_ips.get_ip_of_selected_fsp(bci.name, soc)
        info(f"FSP IP of {bci.name} - {soc}: {fsp_ip}")
        pid_search_command = "ps auxf -w -w"
        attempt_counter = 0
        while not pid and attempt_counter < 5:
            enb_ssh = self.ssh.ssh_connection_to_smod()
            fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
            self.logger.debug(f"Trying to find PID of {application} (attempt {attempt_counter + 1})")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, pid_search_command, ssh_timeout=360)
            pid = self._search_real_application_pid_from_output(output, application)
            attempt_counter += 1
            BuiltIn().sleep("1s")
            if not pid:
                self.ssh.disconnect_ssh_connection(enb_ssh)
        if pid:
            info(f"Kill application ({application}) with 'kill -9 {pid}'")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, f"kill -9 {pid}", ssh_timeout=60)
            self.logger.debug(f"Output from kill command: {output}")
            if "No such process" in output:
                error(f"Could not kill application: {output}")
            else:
                info("Kill successful.")
        else:
            error(f"No PID found for {application} from unit {bci.name}.")
            raise PIDNotFound(f"No PID found for {application} from unit {bci.name}.")
        self.ssh.disconnect_ssh_connection(fsp_ssh)

    def kill_application_from_secondary_soc(self, bci, soc, application):
        """
        Kills application from secondary SoC of BBMOD.
        Takes SSH connection to BBMOD using SMOD connection as proxy, then finds and kills application.
        :param obj bci: BBMOD unit object (from BTS.py)
        :param str soc: Secondary SoC of BBMOD.
        :param str application: Application to be killed.
        """
        pid = ""
        fsp_ssh = None
        if not any(bbmod for bbmod in ["ABIP", "ABIN", "ABIO", "ABIQ"] if bbmod in bci.name):
            warning(f"Kill application from secondary SoC -test is planned for secondary SoC of ABIP/ABIN/ABIO/ABIQ. "
                    f"You are running test with {bci.name} ({soc}) so functionality is not guaranteed.")

        fsp_ip = self.fsp_ips.get_ip_of_selected_fsp(bci.name, soc)
        info(f"FSP IP of {bci.name} - {soc}: {fsp_ip}")
        pid_search_command = "ps auxf -w -w"
        attempt_counter = 0
        while not pid and attempt_counter < 20:
            enb_ssh = self.ssh.ssh_connection_to_smod()
            fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
            self.logger.debug(f"Trying to find PID of {application} (attempt {attempt_counter + 1})")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, pid_search_command, ssh_timeout=360)
            pid = self._search_secondary_soc_app_from_output(output, pid, application)
            attempt_counter += 1
            BuiltIn().sleep("1s")
            if not pid:
                self.ssh.disconnect_ssh_connection(enb_ssh)
        if pid:
            info(f"Kill application with 'kill -9 {pid}'")
            output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, f"kill -9 {pid}", ssh_timeout=60)
            if "No such process" in output:
                error(f"Could not kill application: {output}")
            else:
                info("Kill successful.")
        else:
            error(f"No PID found for {application} from unit {bci.name}.")
            raise PIDNotFound(f"No PID found for {application} from unit {bci.name}.")
        self.ssh.disconnect_ssh_connection(fsp_ssh)

    def kill_application_from_smod_controller_soc(self, application):
        pid = ""
        pid_search_command = "ps auxf -w -w"
        attempt_counter = 0
        enb_ssh = self.ssh.ssh_connection_to_smod()
        while not pid and attempt_counter < 5:
            self.logger.debug(f"Trying to find PID of {application} (attempt {attempt_counter + 1})")
            output = self.ssh.send_command_to_smod_by_ssh(
                pid_search_command, enb_ssh=enb_ssh, return_output=True, ssh_timeout=360,
                print_to_eventlog=False, disconnect_ssh=False)
            pid = self._search_real_application_pid_from_output(output, application)
            attempt_counter += 1
            BuiltIn().sleep("1s")

        if pid:
            info(f"Kill application with 'kill -9 {pid}'")
            output = self.ssh.send_command_to_smod_by_ssh(
                f"kill -9 {pid}", enb_ssh=enb_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False)
            if "No such process" in output:
                error(f"Could not kill application: {output}")
            else:
                info("Kill successful.")
        else:
            error(f"No PID found for {application}.")
            raise PIDNotFound(f"No PID found for {application}.")

    def kill_application_from_smod_interface_soc(self, application):
        pid = ""
        pid_search_command = "ps auxf -w -w"
        attempt_counter = 0
        enb_ssh = self.ssh.ssh_connection_to_smod()
        if application == "CCSEmDispatcherExe":
            lxc, node = self._find_lxc_with_ccsemdispatcherexe_in_it(enb_ssh)
            self.logger.debug(f"connecting to lxc {lxc} and node {node}")
            soc_ssh = self.ssh.connect_to_smod_interface_soc(enb_ssh, use_lxc_attach=True, node=node, lxc_hex=lxc)
            info(f"Kill application with 'kill -SIGABRT $(echo $(ps -x | grep CCSEmDispatcherExe) | cut -d ' ' -f 1)'")
            output = self.ssh.send_command_to_smod_by_ssh(
                "kill -SIGABRT $(echo $(ps -x | grep CCSEmDispatcherExe) | cut -d ' ' -f 1)",
                enb_ssh=soc_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False)
            if "No such process" in output:
                error(f"Could not kill application: {output}")
            else:
                info("Kill successful.")
        else:
            soc_ssh = self.ssh.connect_to_smod_interface_soc(enb_ssh, use_lxc_attach=False)
            while not pid and attempt_counter < 5:
                self.logger.debug(f"Trying to find PID of {application} (attempt {attempt_counter + 1})")
                output = self.ssh.send_command_to_smod_by_ssh(
                    pid_search_command, enb_ssh=soc_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False,
                    disconnect_ssh=False)
                pid = self._search_real_application_pid_from_output(output, application)
                attempt_counter += 1
                BuiltIn().sleep("1s")

            if pid:
                info(f"Kill application with 'kill -9 {pid}'")
                output = self.ssh.send_command_to_smod_by_ssh(
                    f"kill -9 {pid}", enb_ssh=soc_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False)
                if "No such process" in output:
                    error(f"Could not kill application: {output}")
                else:
                    info("Kill successful.")
            else:
                error(f"No PID found for {application}.")
                raise PIDNotFound(f"No PID found for {application}.")
        self.ssh.disconnect_ssh_connection(enb_ssh)

    def _find_lxc_with_ccsemdispatcherexe_in_it(self, enb_ssh, bbmod=False):
        # Used for SMOD or BBMOD
        info("Find all lxcs with lxc-ls and find one lxc with CCSEmDispatcherExe in it")
        soc_ssh = None
        if not bbmod:
            lxc_output = self.ssh.send_command_to_smod_by_ssh("lxc-ls", enb_ssh=enb_ssh, return_output=True,
                                                              ssh_timeout=60, print_to_eventlog=False,
                                                              disconnect_ssh=False)
        else:
            lxc_output = self.ssh.send_command_to_fsp_by_ssh(enb_ssh, "lxc-ls", ssh_timeout=60)
        lxc_output = lxc_output.split("\n") if lxc_output else []
        # Only use the line with the hexes in it
        for line in lxc_output:
            if "0x" in line:
                lxc_output = line.split() if line else []
                break

        for lxc in lxc_output:
            self.logger.debug(f"current lxc is: {lxc}")
            if not bbmod:
                soc_ssh = self.ssh.connect_to_smod_interface_soc(enb_ssh=enb_ssh, use_lxc_attach=True, lxc_hex=lxc)
                output = self.ssh.send_command_to_smod_by_ssh("ps auxf -w -w", enb_ssh=soc_ssh, return_output=True,
                                                              ssh_timeout=60, print_to_eventlog=False,
                                                              disconnect_ssh=False)
            else:
                self.ssh.send_command_to_fsp_by_ssh(enb_ssh, f"lxc-attach -n {lxc}", ssh_timeout=60)
                output = self.ssh.send_command_to_fsp_by_ssh(enb_ssh, "ps auxf -w -w", ssh_timeout=60)
            tries = 0
            while not output and tries < 5:
                BuiltIn().sleep("1s")
                if not bbmod:
                    output = self.ssh.send_command_to_smod_by_ssh("ps auxf -w -w", enb_ssh=soc_ssh, return_output=True,
                                                                  ssh_timeout=60, print_to_eventlog=False,
                                                                  disconnect_ssh=False)
                else:
                    output = self.ssh.send_command_to_fsp_by_ssh(enb_ssh, "ps auxf -w -w", ssh_timeout=60)
                tries += 1
                if output:
                    break
            self.logger.debug(f"output from ps auxf -w -w is: {output}")
            if bbmod:
                self.ssh.send_command_to_fsp_by_ssh(enb_ssh, "exit", ssh_timeout=60)
            if "CCSEmDispatcherExe" in output:
                match = re.search(r"root@(?P<node_name>.*)", string=output)
                if match:
                    node = match.group("node_name")
                    self.logger.debug(f"Found CCSEmDispatcherExe from node {node} and hex {lxc}")
                    return lxc, node
                else:
                    info("Could not find node from output.")
        return None, None

    def kill_application_from_smod_interface_soc_all_containers(self, application):
        pid_hex_node_tuples = self._pid_and_lxc_attach_for_all_containers()
        for pid, lxc_hex, node in pid_hex_node_tuples:
            enb_ssh = self.ssh.ssh_connection_to_smod()
            soc_ssh = self.ssh.connect_to_smod_interface_soc(enb_ssh, use_lxc_attach=True, node=node, lxc_hex=lxc_hex)
            info(f"pid: {pid}, lxc_hex: {lxc_hex}, node: {node}")
            if application == "CCSEmDispatcherExe":
                info(
                    f"Kill application with"
                    f" 'kill -SIGABRT $(echo $(ps -x | grep CCSEmDispatcherExe) | cut -d ' ' -f 1)'")
                output = self.ssh.send_command_to_smod_by_ssh(
                    "kill -SIGABRT $(echo $(ps -x | grep CCSEmDispatcherExe) | cut -d ' ' -f 1)",
                    enb_ssh=soc_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False)
                info(f"Received output is: {output}")
                if "No such process" in output:
                    error(f"Could not kill application: {output}")
                else:
                    info("Kill successful.")
            else:
                error(f"Only CCSEmDispatcherExe is supported")
                raise PIDNotFound
            self.ssh.disconnect_ssh_connection(enb_ssh)

    def _pid_and_lxc_attach_for_all_containers(self):
        enb_ssh = self.ssh.ssh_connection_to_smod()
        pid_search_command = "ps auxf -w -w | grep -E 'lxc-start|CCSEmDispatcherExe'"
        info(f"sending command: {pid_search_command}")
        tries = 0
        output = ""
        while tries < 5:
            output = self.ssh.send_command_to_smod_by_ssh(
                pid_search_command, enb_ssh=enb_ssh, return_output=True, ssh_timeout=60, print_to_eventlog=False)
            if pid_search_command not in output:
                tries += 1
            else:
                break
        self.ssh.disconnect_ssh_connection(enb_ssh)

        lines = output.strip().split('\n') if output else []
        pid_hex_node_tuples = []
        current_hex = ""
        current_node = ""
        for line in lines:
            if 'lxc-start' in line:
                node_pattern = re.compile(r'.*/ram/node_(?P<node_name>.*NODE\d\d).*')
                hex_pattern = re.compile(r'-n (?P<hex_name>\S+)')
                match_node = node_pattern.match(line)
                match_hex = hex_pattern.search(line)
                if match_node and match_hex:
                    current_node = match_node.group("node_name")
                    current_hex = match_hex.group("hex_name")
            elif ('CCSEmDispatcherExe' and '<Ll') in line and (
                    re.search(r'LTEL2NODE\d\d', current_node) or re.search(r'FDDMACNODE\d\d', current_node)):
                parts = line.split()
                if len(parts) > 1 and parts[1].isdigit():
                    pid = parts[1]
                    if current_node not in pid_hex_node_tuples:
                        pid_hex_node_tuples.append((pid, current_hex, current_node))
                        current_node = ""
                        current_hex = ""

        info(f"pid_hex_node_tuples: {pid_hex_node_tuples}")
        return pid_hex_node_tuples

    def _expected_hex_name(self, unit):
        bottom = ["0x12", "0x22"]
        middle = ["0x13", "0x23"]
        top = ["0x14", "0x24"]
        if self.bts.fullrack:
            if not unit or unit == "SMOD" or unit == "SMOD1":
                return ["0x10"]
            elif "SMOD2" == unit:
                return ["0x20"]
            elif unit[-1] == "1":
                return bottom[1] if "." in unit else bottom[0]
            elif unit[-1] == "2":
                return middle[1] if "." in unit else middle[0]
            elif unit[-1] == "3":
                return top[1] if "." in unit else top[0]
        else:
            if not unit or "SMOD" in unit:
                return ["0x10", "0x15", "0x20"]
            elif unit[-1] == "1":
                return bottom
            elif unit[-1] == "2":
                return middle
            elif unit[-1] == "3":
                return top
        error(f"Unkown unit: {unit}")
        return None

    @staticmethod
    def _search_faultserviceexe_from_output(output, pid):
        pid = ""
        pattern = re.compile(r"(root|btssw)\s+(?P<PID>\d+).*opt/FaultServiceExe/FaultServiceExe")
        for o in output.split("\n") if output else []:
            pid = pattern.match(o)
            if pid:
                pid = pid.group("PID")
                break
        return pid

    @staticmethod
    def _search_secondary_soc_app_from_output(output, pid, application):
        if application == "sfpd":
            pattern = re.compile(r"(root|btssw|sfp)\s+(?P<PID>\d+)\s+.*(/usr/bin/sfpd|sfpd)")
        elif application == "l1_application_nrt":
            pattern = re.compile(r"(root|btssw)\s+(?P<PID>\d+).*/usr/bin/l1_application_nrt")
        elif application == "l1_application_rt":
            pattern = re.compile(r"(root|btssw)\s+(?P<PID>\d+).*/usr/bin/l1_application_rt")
        else:
            error(f"Application {application} is not supported by kill_application_from_secondary_soc.")
            raise PIDNotFound(f"Application {application} is not supported by kill_application_from_secondary_soc.")
        for o in output.split("\n") if output else []:
            pid = pattern.match(o)
            if pid:
                pid = pid.group("PID")
                break
        return pid

    @staticmethod
    def _search_real_application_pid_from_output(output, application):
        pid = ""
        pattern = re.compile(fr".*(btssw|root)\s+(?P<PID>\d+).*(/opt/.*/|/usr/bin/){application}.*")
        for o in output.split("\n") if output else []:
            pid = pattern.match(o)
            if pid:
                pid = pid.group("PID")
                break
        return pid

    def _choose_random_application(self, pids):
        """
        Currently only for virtual nodes
        """
        pid = random.choice(pids)
        for nap in self.nodes_applications_pids:
            for ap in self.nodes_applications_pids[nap][1]:
                if pid in ap:
                    application = ap[1][ap[1].rfind("/")+1:]
                    if (any(i for i in central_c_plane_virtual_processes if application in i) or
                            any(i for i in critical_processes if application in i)):
                        return pid, application
                    self._choose_random_application(pids)
        return None, None

    def _find_virtual_application_pid(self, selected_application, selected_virtual_pids):
        for node in self.nodes_applications_pids:
            for apps_and_pids in self.nodes_applications_pids[node][1]:
                pid, app = apps_and_pids
                if pid in selected_virtual_pids:
                    if selected_application in app:
                        info("PID of {} is {}".format(selected_application, pid))
                        return pid
        error("Couldn't find pid for {} (from {})".format(
            selected_application, self.nodes_applications_pids))
        raise PIDNotFound

    def _search_pid(self, paux_pid_list, application):
        """
        Used by find_real_application_pid, might become obsolete in the future when all ssh application kills stop
        using the TAF versions.
        """
        application_pattern = re.compile(r".*(btssw|root)\s+(?P<PID>\d+).*(?P<aika>\d+:\d+)(?P<empty>\s+|\s+\\_\s+|"
                                         r"(\s+\|\s+)+|(\s+\|\s+)+\\_\s+)(?P<application>/opt/{}/{}).*".format(
                                          application.replace("exe", ""), application))
        pid_found = False
        process_list = []
        for ps in paux_pid_list:
            match = application_pattern.match(ps)
            if match and match.group("PID"):
                self.logger.debug("Matched")
                pid = match.group("PID")
                pid_found = True
                if application != "FaultServiceExe":
                    self.logger.debug("Not FaultServiceExe and PID is {}".format(pid))
                    return pid_found, pid
                else:
                    emptiness = match.group("empty")
                    process_list.append((pid, emptiness))
                    self.logger.debug("PIDs of processes with same name {}".format(process_list))
        pid = self.select_realtime_process(process_list)
        return pid_found, pid

    def list_all_applications(self, additional_filename=""):
        """
        Lists all found applications under /opt/ from SMOD (and all BBMODs (core-wise) if the environment has them)

        :param str additional_filename: Additional name to be given to the file created. File will be named
                                        applications_<additional_filename>.txt
        """
        list_applications = BuiltIn().get_variable_value("${LIST_APPLICATIONS}", default=False)
        if list_applications and isinstance(list_applications, str) and list_applications.lower() == "false":
            info(f"User has given value {list_applications} for LIST_APPLICATIONS variable -> Do not list all "
                 f"applications")
            list_applications = False
        elif list_applications:
            info("LIST_APPLICATIONS variable is set to True, list all applications.")
        else:
            self.logger.debug("No LIST_APPLICATIONS variable has been given")
        if list_applications:
            # (?:\s+\S+){x} is used for skipping unwanted fields
            app_pattern = re.compile(
                          r'\S+\s+(?P<pid>\d+)(?:\s+\S+){5}\s+(?P<status>\S+)(?:\s+\S+){2}\s+(?P<application>/opt/\S+)')
            node_pattern = re.compile(r'.*/ram/node_(?P<node_name>\S+\d\d)/lxc')
            lxc_pattern = re.compile(r'.*-n (?P<lxc_number>\S+)')
            core_pattern = re.compile(r'.*(?P<core>(fsp|asp)\d_\w+)')
            bbmod_pattern = re.compile(r'root@(?P<bbmod_name>\S+)')
            newline_with_spaces = '\n    '  # Python < 3.12 doesn't support \ inside {}
            virtual_nodes_and_applications = []
            bbmod_applications = []
            core_applications = []
            filtered_files = [".sh", ".xml", ".conf", ".json"]  # filter out unnecessary files
            # SMOD functionality
            enb_ssh = self.ssh.ssh_connection_to_smod()
            output = self.ssh.send_command_to_smod_by_ssh("ps auxf -w -w", enb_ssh=enb_ssh,
                                                          return_output=True, ssh_timeout=60,
                                                          print_to_eventlog=False,
                                                          disconnect_ssh=False)
            real_output, virtual_output = output.split("lxc-start", 1)  # split into real and virtual nodes
            real_output = real_output.split("\n")
            virtual_output = virtual_output.split("lxc-start")  # split into each node separately
            real_applications = self._match_real_apps_from_output(real_output, app_pattern, filtered_files)
            for node_output in virtual_output:
                splitted_node_output = node_output.split("\n")
                node, lxc, virtual_applications = self._match_virtual_apps_from_output(splitted_node_output,
                                                                                       app_pattern, node_pattern,
                                                                                       lxc_pattern, filtered_files)
                virtual_nodes_and_applications.append((node, lxc, virtual_applications))
            self.ssh.disconnect_ssh_connection(enb_ssh)

            # BBMOD functionality
            if self.bts.bbmods:
                bbmod_applications = []
                bbmod_virtual_nodes_and_applications = []
                bb_node_pattern = re.compile(r'.*/ram/node_(?P<node_name>\S+)/tmp')
                for bbmod in self.bts.bbmods:
                    enb_ssh = self.ssh.ssh_connection_to_smod()
                    fsp_ip = self.fsp_ips.get_ip_of_selected_fsp(bbmod.name, bbmod.primary_soc)
                    fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
                    output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, "ps auxf -w -w", ssh_timeout=60)
                    real_output, virtual_output = output.split("lxc-start", 1)
                    real_output = real_output.split("\n")
                    virtual_output = virtual_output.split("\n")  # BBMODs should have only one lxc-start per BBMOD.
                    bbmod_real_applications = self._match_real_apps_from_output(real_output, app_pattern,
                                                                                filtered_files)
                    node, lxc, bbmod_virtual_applications = self._match_virtual_apps_from_output(virtual_output,
                                                                                                 app_pattern,
                                                                                                 bb_node_pattern,
                                                                                                 lxc_pattern,
                                                                                                 filtered_files)
                    bbmod_virtual_nodes_and_applications.append((node, lxc, bbmod_virtual_applications))
                    bbmod_applications.append((bbmod.name, bbmod_real_applications,
                                               bbmod_virtual_nodes_and_applications))
                    # Logic for BBMOD cores
                    output = self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, "cat /etc/hosts", ssh_timeout=60)
                    matched_bbmod = bbmod_pattern.search(output)
                    bbmod_name = ""
                    if matched_bbmod:
                        bbmod_name = matched_bbmod.group("bbmod_name")
                        bbmod_name = bbmod_name.replace("-", "")[:-1]
                        if "asp" in bbmod_name:
                            bbmod_name = f"fsp{bbmod_name[-1]}"
                    cores = []
                    output = output.split("\n")
                    for line in output:
                        matched_core = core_pattern.match(line)
                        if matched_core:
                            core = matched_core.group("core")
                            if core not in cores:
                                if bbmod_name in core and "a" not in core:  # a indicates primary core
                                    cores.append(core)
                    if cores:
                        core_connections = []
                        for core in cores:
                            virtual_apps = False
                            core_virtual_nodes_and_applications = []
                            core_ssh = self.ssh.connect_to_fsp(fsp_ssh, core, "toor4nsn", known_hosts=False)
                            core_connections.append(core_ssh)
                            output = self.ssh.send_command_to_fsp_by_ssh(core_ssh, "ps auxf -w -w", ssh_timeout=60)
                            if "lxc-start" in output:
                                virtual_apps = True
                                real_output, virtual_output = output.split("lxc-start", 1)
                            else:
                                real_output = output
                            real_output = real_output.split("\n") if real_output else []
                            core_real_apps = self._match_real_apps_from_output(real_output, app_pattern, filtered_files)
                            if virtual_apps:
                                virtual_output = virtual_output.split("\n") if virtual_output else []
                                node, lxc, core_virtual_applications = self._match_virtual_apps_from_output(
                                    virtual_output, app_pattern, bb_node_pattern, lxc_pattern, filtered_files)
                                core_virtual_nodes_and_applications.append((node, lxc, core_virtual_applications))
                            core_applications.append(
                                (bbmod.name, core, core_real_apps, core_virtual_nodes_and_applications))
                        for core_connection in core_connections:
                            self.ssh.disconnect_ssh_connection(core_connection)
                    self.ssh.disconnect_ssh_connection(fsp_ssh)
                    self.ssh.disconnect_ssh_connection(enb_ssh)
            file_name = "applications" if not additional_filename else f"applications_{additional_filename}"
            with open(f"{self.logger.suite_folder}/{file_name}.txt", "w") as f:
                f.write("Process state code explanations:\n\n"
                        "\tD    uninterruptible sleep (usually I/O)\n"
                        "\tI    idle kernel thread\n"
                        "\tR    running or runnable (on run queue)\n"
                        "\tS    interruptible sleep (waiting for an event to complete)\n"
                        "\tT    stopped by job control signal\n"
                        "\tt    stopped by debugger during the tracing\n"
                        "\tX    dead (should never be seen)\n"
                        "\tZ    defunct (“zombie”) process, terminated but not reaped by its parent\n\n"
                        "\t<    high-priority (not nice to other users)\n"
                        "\tN    low-priority (nice to other users)\n"
                        "\tL    has pages locked into memory (for real-time and custom I/O)\n"
                        "\ts    is a session leader\n"
                        "\tl    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)\n"
                        "\t+    is in the foreground process group\n")
                f.write(f"\nApplications started on {self.bts.smods[0].name}:\n"
                        f"\nReal applications:\n    {newline_with_spaces.join(real_applications)}\n")

                f.write(f"\n{self.bts.smods[0].name} Virtual nodes and applications:")
                for node, lxc, apps in virtual_nodes_and_applications:
                    f.write(f"\n\n{node} {lxc}:\n    {newline_with_spaces.join(apps)}")

                f.write(f"\n{'-' * 40}\n")
                if self.bts.bbmods:
                    for bbmod_name, bbmod_real_apps, bbmod_virtual_apps in bbmod_applications:
                        f.write(f"\nApplications started on {bbmod_name} (PRIMARY CORE):\n"
                                f"\nReal applications:\n    {newline_with_spaces.join(bbmod_real_apps)}\n")

                        f.write("\nVirtual nodes and applications:\n")
                        for node, lxc, apps in bbmod_virtual_apps:
                            f.write(f"\n{bbmod_name} {node} {lxc}:\n    {newline_with_spaces.join(apps)}")

                        for core_bbmod_name, core, core_real_apps, core_virtual_applications in core_applications:
                            if core_bbmod_name == bbmod_name:
                                f.write(f"\n\nApplications started on {core_bbmod_name} core {core}:"
                                        f"\n    Real applications:\n    {newline_with_spaces.join(core_real_apps)}\n")
                                info(f"core_virtual_applications: {core_virtual_applications}")
                                if core_virtual_applications:
                                    f.write(f"\n    Virtual nodes and applications on core {core}:")
                                    for node, lxc, apps in core_virtual_applications:
                                        f.write(f"\n    {node} {lxc}:\n    {newline_with_spaces.join(apps)}")
                                else:
                                    f.write(f"\n    No virtual applications were found from core {core}.")
                else:
                    f.write("\nNo BBMODs found from the environment.")

    @staticmethod
    def _match_real_apps_from_output(output, application_pattern, filtered_files):
        applications = []
        for line in output:
            matched_application = application_pattern.match(line)
            if matched_application:
                app = matched_application.group("application")
                pid = matched_application.group("pid")
                status = matched_application.group("status")
                app_string = f"{pid.ljust(5)}  {status.ljust(4)}  {app}"
                if app not in applications and not any(app.endswith(extension) for extension in filtered_files):
                    applications.append(app_string)
        return applications

    @staticmethod
    def _match_virtual_apps_from_output(output, application_pattern, node_pattern, lxc_pattern, filtered_files):
        virtual_applications = []
        node = ""
        lxc = ""
        for line in output:
            matched_node = node_pattern.match(line)
            matched_lxc = lxc_pattern.match(line)
            if matched_node and matched_lxc:
                node = matched_node.group("node_name")
                lxc = matched_lxc.group("lxc_number")
            else:
                matched_application = application_pattern.match(line)
                if matched_application:
                    app = matched_application.group("application")
                    pid = matched_application.group("pid")
                    status = matched_application.group("status")
                    app_string = f"{pid}  {status}  {app}"
                    if app not in virtual_applications and not any(
                            app.endswith(extension) for extension in filtered_files):
                        virtual_applications.append(app_string)
        return node, lxc, virtual_applications

    def bbmod_checks_for_application_kills(self, unit):
        given_bbmod_obj = self.bts.get_bbmod_object_from_user_given_values(unit)
        result = True
        if len(self.bts.bbmods) < 2:
            error("This test is not supported on only one BBMOD. Please check the used environment configuration.")
            result = False
        else:
            for bbmod in self.bts.bbmods:
                if bbmod.name == given_bbmod_obj.name and "ABIA" in bbmod.name:
                    error(f"This test is not supported on ABIA. Please check the used environment configuration."
                          f"Given BBMOD is {given_bbmod_obj.name}.")
                    result = False
                    break
        if not result:
            raise EnvironmentIssue
        info("BBMOD checks for application kills --> OK")
        return result

    def ssbl_bootloader_procedure(self):
        """Does the required procedure according to FCA_TATSCRIPTS-183061"""
        file_path = "/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/MiscFiles/install_ssbl_fsbl.sh"
        enb_ssh = self.ssh.ssh_connection_to_smod()
        collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        info("Copy install_ssbl_fsbl.sh to SMOD")
        collect_logs.upload_file_or_folder_to_bts(file_path, "/ffs/run/logs")
        info("Give execution rights to install_ssbl_fsbl.sh, run it and reboot the SMOD")
        BuiltIn().sleep("10s")
        o1 = self.ssh.send_command_to_smod_by_ssh("ls -l /ffs/run/logs/", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        o2 = self.ssh.send_command_to_smod_by_ssh("sed -i 's/\\r//g' /ffs/run/logs/install_ssbl_fsbl.sh",
                                                  enb_ssh=enb_ssh, disconnect_ssh=False,
                                                  return_output=True)
        BuiltIn().sleep("10s")
        o3 = self.ssh.send_command_to_smod_by_ssh("chmod +x /ffs/run/logs/install_ssbl_fsbl.sh", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        o4 = self.ssh.send_command_to_smod_by_ssh("ls -l /ffs/run/logs/", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        output = self.ssh.send_command_to_smod_by_ssh("/ffs/run/logs/install_ssbl_fsbl.sh",
                                                      enb_ssh=enb_ssh, disconnect_ssh=False, ssh_timeout=300,
                                                      return_output=True)

        self.logger.debug(f"outputs are: \n\n{o1}\n\n{o2}\n\n{o3}\n\n{o4}\n\n{output}\n\n")
        info("Give uboot_env related commands before performing SWDL")
        for smod in self.bts.smods:
            if smod.master:
                if "ASIM" in smod.name:
                    self.ssh.send_command_to_smod_by_ssh("uboot_env set disable_bootsupervision=1",
                                                         enb_ssh=enb_ssh,
                                                         disconnect_ssh=False)
        self.ssh.send_command_to_smod_by_ssh("uboot_env set block_ssbl_counter=3", enb_ssh=enb_ssh,
                                             disconnect_ssh=False)
        self.ssh.send_command_to_smod_by_ssh("reboot", enb_ssh=enb_ssh, disconnect_ssh=True)
        self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", disconnection=True,
                                                             time_to_wait=1800)
        self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", time_to_wait=1800)
        self.bts.check_if_admin_connection_available(wait_for_connection=180, create_connection=False,
                                                     additional_wait=False)

    def fsbl_bootloader_procedure(self):
        """Does the required procedure according to FCA_TATSCRIPTS-183062"""
        file_path = "/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/MiscFiles/install_ssbl_fsbl.sh"
        enb_ssh = self.ssh.ssh_connection_to_smod()
        collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        info("Copy install_ssbl_fsbl.sh to SMOD")
        collect_logs.upload_file_or_folder_to_bts(file_path, "/ffs/run/logs")
        info("Give execution rights to install_ssbl_fsbl.sh, run it and reboot the SMOD")
        BuiltIn().sleep("10s")
        o1 = self.ssh.send_command_to_smod_by_ssh("ls -l /ffs/run/logs/", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        o2 = self.ssh.send_command_to_smod_by_ssh("sed -i 's/\\r//g' /ffs/run/logs/install_ssbl_fsbl.sh",
                                                  enb_ssh=enb_ssh, disconnect_ssh=False,
                                                  return_output=True)
        BuiltIn().sleep("10s")
        o3 = self.ssh.send_command_to_smod_by_ssh("chmod +x /ffs/run/logs/install_ssbl_fsbl.sh", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        o4 = self.ssh.send_command_to_smod_by_ssh("ls -l /ffs/run/logs/", enb_ssh=enb_ssh,
                                                  disconnect_ssh=False, return_output=True)
        BuiltIn().sleep("10s")
        output = self.ssh.send_command_to_smod_by_ssh("/ffs/run/logs/install_ssbl_fsbl.sh",
                                                      enb_ssh=enb_ssh, disconnect_ssh=False, ssh_timeout=300,
                                                      return_output=True)

        self.logger.debug(f"outputs are: \n\n{o1}\n\n{o2}\n\n{o3}\n\n{o4}\n\n{output}\n\n")
        self.ssh.send_command_to_smod_by_ssh("reboot", enb_ssh=enb_ssh, disconnect_ssh=True)
        self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", disconnection=True,
                                                             time_to_wait=1800)
        self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", time_to_wait=1800)
        enb_ssh_post_reset = self.ssh.ssh_connection_to_smod()
        info("Give uboot_env related commands before performing SWDL")
        for smod in self.bts.smods:
            if smod.master:
                if "ASIM" in smod.name:
                    self.ssh.send_command_to_smod_by_ssh("uboot_env set disable_bootsupervision=1",
                                                         enb_ssh=enb_ssh_post_reset,
                                                         disconnect_ssh=False)
        self.ssh.send_command_to_smod_by_ssh("uboot_env del netboot", enb_ssh=enb_ssh_post_reset, disconnect_ssh=False)
        self.ssh.send_command_to_smod_by_ssh("uboot_env set block_fsbl_counter=3", enb_ssh=enb_ssh_post_reset,
                                             disconnect_ssh=True)

    def test_cleanup_steps(self, flag_to_clear=None, service_to_clear=None, bootloader_case=False):
        """
        Do test cleanup steps based on given  parameters. Universally give ddal commmand as a cleaning step. These
        cleaning steps are required to make sure the test environment does not have any lingering values from
        previous tests if they are run in succession. This function also ensures that environments are not left in
        an ambiguous state where it is seen to be OnAir, but it still can cause an environment to not go OnAir after
        upgrading SW.

        :param dict flag_to_clear: Dictionary of (a) flag(s) to clear
        :param str service_to_clear: Name of service to be cleared
        :param bool bootloader_case: These steps are run on T1 packages for UC4 and UC5 if this parameter is True.
        """
        enb_ssh = self.ssh.ssh_connection_to_smod()
        if flag_to_clear:
            swconfig_pre_removal = self.ssh.send_command_to_smod_by_ssh("cat /ffs/run/swconfig.txt",
                                                                        enb_ssh=enb_ssh, disconnect_ssh=False,
                                                                        return_output=True)
            self.logger.debug(f"swconfig with active flags: {swconfig_pre_removal}")
            swconfig = BuiltIn().get_library_instance("SWCONFIG")
            swconfig.add_and_remove_flags_with_swconfig(flag_to_clear, add_flag=False)
        if service_to_clear:
            self.save_service_name_in_uboot_environment(service_to_clear, remove=True)
        if bootloader_case:
            self.ssh.send_command_to_smod_by_ssh("uboot_env del disable_bootsupervision", enb_ssh=enb_ssh,
                                                 disconnect_ssh=False)
            BuiltIn().sleep("5s")
            self.ssh.send_command_to_smod_by_ssh("uboot_env del block_fsbl_counter", enb_ssh=enb_ssh,
                                                 disconnect_ssh=False)
            BuiltIn().sleep("5s")
            self.ssh.send_command_to_smod_by_ssh("uboot_env del block_ssbl_counter", enb_ssh=enb_ssh,
                                                 disconnect_ssh=False)
            self.ssh.send_command_to_smod_by_ssh("ddal -s ddal_boot_set_reset_loop_count 0",
                                                 enb_ssh=enb_ssh, disconnect_ssh=False)
            BuiltIn().sleep("5s")
            for smod in self.bts.smods:
                # The tests are only run on the master SMOD in full-rack environments
                if smod.master:
                    if "ASIL" in smod.name:
                        self.ssh.send_command_to_smod_by_ssh("if [ \"$(cat /var/dt/module-identity/unit-id | "
                                                             "tr -d '\0')\" = \"ASIL\" ]; then update_bios.sh -F -D "
                                                             "/ffs/run/swpool/LFS/boot/FCT-SNFB1-MC-BW*.bin; "
                                                             "else echo \"Not ASIL skipping\"; fi", enb_ssh=enb_ssh,
                                                             disconnect_ssh=False)
                    elif "ASIM" in smod.name:
                        self.ssh.send_command_to_smod_by_ssh("if [ \"$(cat /var/dt/module-identity/unit-id | "
                                                             "tr -d '\0')\" = \"ASIM\" ]; then update_marvellfw.sh "
                                                             "-F -D -S upgrade_firmware "
                                                             "/ffs/run/swpool/LFS/boot/FCT-MC-BW*.bin; "
                                                             "else echo \"Not ASIM skipping\"; fi", enb_ssh=enb_ssh,
                                                             disconnect_ssh=False)
                    else:
                        warning(f"{smod.name} is not supported, not running cleanup commands")
            BuiltIn().sleep("5s")
            # Use reboot command only for UC4&5, site reset for other cases
            self.ssh.send_command_to_smod_by_ssh("reboot", enb_ssh=enb_ssh, disconnect_ssh=True)
            self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", disconnection=True,
                                                                 time_to_wait=900)
            self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", time_to_wait=420)
        else:
            BuiltIn().sleep("5s")
            self.admin.reset_site(detailed_output=True, wait_for_reconnection=False)
            self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", disconnection=True,
                                                                 time_to_wait=1800)
            self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129", time_to_wait=1800)
            swconfig_post_cleaning = self.ssh.send_command_to_smod_by_ssh("cat /ffs/run/swconfig.txt",
                                                                          disconnect_ssh=True,
                                                                          return_output=True)
            self.logger.debug(f"swconfig after cleaning steps: {swconfig_post_cleaning}")

    def systemd_startup_procedure(self):
        """Does the required procedure according to FCA_TATSCRIPTS-183063"""
        self.ssh.send_command_to_smod_by_ssh("echo stop > /dev/watchdog")

    def save_service_name_in_uboot_environment(self, service, remove=False):
        """
        Does the required procedure according to FCA_TATSCRIPTS-183064, FCA_TATSCRIPTS-183065 and
        FCA_TATSCRIPTS-183066
        """
        enb_ssh = self.ssh.ssh_connection_to_smod()
        set_or_del = "set" if not remove else "del"
        self.ssh.send_command_to_smod_by_ssh(f"uboot_env {set_or_del} bootargs_opt=\"{service}\"", enb_ssh=enb_ssh,
                                             disconnect_ssh=True)

    def kill_application_during_t1_swdl(self, application):
        """
        Kill application during t1 SWDL for UC3 (FCA_TATSCRIPTS-183060)

        :param str application: Name of application to be crashed f.ex. HWRPostSExe
        """
        pid = ""
        enb_ssh = self.ssh.ssh_connection_to_smod()
        output = self.ssh.send_command_to_smod_by_ssh(f"pgrep {application}", enb_ssh=enb_ssh, return_output=True,
                                                      disconnect_ssh=False)
        output = output.split("\n")
        pid_pattern = re.compile(r"(?P<pid_grp>\d+\b)")
        for line in output:
            match = pid_pattern.match(line)
            if match:
                pid = match.group("pid_grp")
                self.logger.debug(f"Match found, pid is: {pid}")
                break
        self.logger.debug(f"got pid: {pid}, sending kill -11 {pid} command next")
        self.ssh.send_command_to_smod_by_ssh(f"kill -11 {pid}", enb_ssh=enb_ssh, disconnect_ssh=True)

    def update_software_expect_fallback(self, build_to_dl):
        """
        Attempt SWDL, expect it to fail due to UC4 & UC5 scripts and modifications

        :param str build_to_dl: Build to download
        """
        try:
            response = self.admin.update_software(build_to_dl, timeout=18000, connection="log_admin")
            self.logger.debug(f"SWDL response (expecting fallback): {response}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException) as admin_error:
            info(f"Expecting some sort of admin errors during swdl {admin_error.__class__.__name__}:{admin_error}")
        info("SWDL attempt done")

    def check_processes_after_application_kill(self, application=None, allowed_to_change=True):
        """
        List processes after application kill by using list_all_applications and compare the previous applications.txt
        file with the new applications_errors.txt file. If differences are found between the files, check if they are
        allowed changes or not. The most common scenario is that given application should be alive with a different pid

        :param str application: (Optional) Name of the application. If not given, prints out all differences but does
                                not perform any comparison checks
        :param bool allowed_to_change: (Optional) If application should be running on a new PID after application kills,
                                       True by default, added possibility for it being False but realistically if the
                                       application is killed, it should always have a different pid.
        """
        if self.logger.errors_and_warnings:
            for item in self.logger.errors_and_warnings:
                if "ERROR:" in item:
                    self.list_all_applications(additional_filename="errors")
                    info(f"application is: {application}")
                    if application:
                        result = self._find_and_compare_application_files(
                            f"{self.logger.suite_folder}/applications_errors.txt", application,
                            allowed_to_change)
                        if result:
                            info("Application pid was changed as planned after application kills --> OK")
                            return
                    else:
                        self._compare_all_applications()
                        return

    def _compare_all_applications(self):
        """
        Compares applications.txt and applications_errors.txt files and looks for all differences. Prints them out
        nicely but does not raise any errors if unexpected behaviour is noticed.
        """
        if not os.path.exists(f"{self.logger.suite_folder}/applications.txt"):
            info("applications.txt file was not found, skipping comparison.")
            return
        result = filecmp.cmp(f"{self.logger.suite_folder}/applications.txt",
                             f"{self.logger.suite_folder}/applications_errors.txt", shallow=False)
        if result:
            info("Contents of the compared files were identical.")
            return
        # Specific application not given, only printing out differences between files
        app_changes = {}
        diffs = self._capture_differences_between_files(f"{self.logger.suite_folder}/applications.txt",
                                                        f"{self.logger.suite_folder}/applications_"
                                                        "errors.txt")
        app_pattern = re.compile(r"(?P<app>/opt/\S+)")
        for line in diffs:
            match = app_pattern.search(line)
            if match:
                app = match.group("app")
                if app not in app_changes:
                    app_changes[app] = {"removed": [], "added": []}
                if line.startswith("-") and app in line and line not in app_changes[app]["removed"]:
                    app_changes[app]["removed"].append(line)
                if line.startswith("+") and app in line and line not in app_changes[app]["added"]:
                    app_changes[app]["added"].append(line)
        self.logger.debug(f"App_changes: {app_changes}")
        for app, changes in app_changes.items():
            if changes["removed"] and changes["added"]:
                info(f"Application {app} restarted normally.")
                self.logger.debug(f"\n\t{changes['removed']}\n\t{changes['added']}")
            if changes["removed"] and not changes["added"]:
                info(f"Application {app} died but did not restart.")
                self.logger.debug(f"\n\t{changes['removed']}")
            if not changes["removed"] and changes["added"]:
                # Most likely should never happen
                info(f"Application {app} was not found from applications.txt but was later found from "
                     f"applications_errors.txt.")
                self.logger.debug(f"\n\t{changes['added']}")

    def _find_and_compare_application_files(self, file_path, application, allowed_to_change):
        """
        Compares applications.txt files and prints out differences, if there are any. If the files are identical,
        comparison is skipped and if the application for some reason is not allowed to change, returns True. If
        differences are found, checks if they are wanted and returns True or False depending on the allowed_to_change
        parameter and the situation.

        :param str file_path: Path to the original applications.txt file
        :param str application: Name of the application
        :param bool allowed_to_change: If the application should be running on a new PID after application kills
                                       (most likely should always be true but added the possibility for it to be False)

        """
        default_path = f"{self.logger.suite_folder}/applications.txt"
        if not os.path.exists(default_path):
            info("applications.txt file was not found, skipping comparison.")
            return None

        info("applications.txt file was found, using it for comparison")
        # shallow=False will compare file contents instead of os.stat() values
        result = filecmp.cmp(default_path, file_path, shallow=False)
        if result:
            info("Contents of the compared files were identical.")
            return True if not allowed_to_change else False
        else:
            info("Differences were found between the files.")
            diffs = self._capture_differences_between_files(default_path, file_path)
            diff_result = False
            app_crash = ""
            app_restart = ""
            for line in diffs:
                self.logger.debug(line)
                if application in line and line.startswith("-"):
                    app_crash = line[1:].split()
                if application in line and line.startswith("+"):
                    app_restart = line[1:].split()
            if app_crash and app_restart:
                info("Application was found from both files, meaning it has restarted and is running with a new PID "
                     "after application kills.")
                if allowed_to_change and (app_crash[0] != app_restart[0]):
                    info(f"Application PID is allowed to change --> OK. Old PID: {app_crash[0]}, "
                         f"new PID: {app_restart[0]}")
                    diff_result = True
                else:
                    error(f"Application PID is not allowed to change --> NOK. Old PID: {app_crash[0]}, "
                          f"new PID: {app_restart[0]}")
                    raise ComparisonFailure
            if app_crash and not app_restart:
                error("Application crashed but was not found from the applications_errors.txt file.")
                raise ComparisonFailure
            if not app_crash and app_restart:
                # Realistically this should never happen
                error("Application was not found from the initial applications.txt file but was later found from the "
                      "applications_errors.txt file.")
                raise ComparisonFailure
            return diff_result

    @staticmethod
    def _capture_differences_between_files(default_path, file_path):
        """
        Captures the differences between two files and returns them as a list

        :param str default_path: Original file path
        :param str file_path: Second file path
        :return list: List of found differences
        """
        found_diffs = []
        with open(default_path, "r") as f1, open(file_path, "r") as f2:
            f1_lines = f1.readlines()
            f2_lines = f2.readlines()
        differences = difflib.unified_diff(f1_lines, f2_lines, fromfile=default_path, tofiledate=file_path, lineterm="")
        for line in differences:
            if line.startswith("+") or line.startswith("-"):
                found_diffs.append(line.strip())
        return found_diffs
