import socket
import re
import time
from paramiko import SSHException
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import create_ssh, SSH_PORT

CONFIGURE_UE_CMD = 'set_pdu_param ue={ue_id} pdu={pdu_id} trf_type=internal'
REGISTER_UE_CMD = 'ue_register id={ue_id}'
PDU_SESSION_SETUP_UE_CMD = 'ue_pdu_session_setup pdu={pdu_id} ue={ue_id} nwslice={nwslice} gw={gw}'
TRF_DATA_START_CMD = 'trf_data_start ue={ue_id} pdu={pdu_id} qfi=1 dir={dir} trf_id={trf_id} mbps={tput}'
TRF_DATA_STOP_CMD = 'trf_data_stop ue={ue_id} pdu={pdu_id} dir={dir}'
TRF_DATA_GET_STATS_CMD = 'ue_stats_nr id={ue_id} scell={scell} type={type}'
UE_KILL_CMD = 'ue_kill id={ue_id}'
UE_CHANGE_CELL_CMD = 'ue_change_location cell={cell_id} ue={ue_id}'
EGATE_TELNET_CMD = 'telnet 0 20000'
EGATE_START_CMD = 'egate-start'
EGATE_PROMPT = 'EGATE>'
EGATE_RESET_CMD = 're'
EGATE_ACTIVATE_CONFIG_FILE_CMD = 'cfg file={filename}'
EGATE_CFG_SIM_FILE_CMD = 'cfg_sim file={filename}'
EGATE_START_SIM_CMD = 'start_sim version_check=off'
EGATE_LOAD_UE_CAPS_CMD = 'ue_param id={ue_id} ue_nr_capabilities={ue_caps_id} capability_file={filename}'
EGATE_RESET_EXPECTED_OUTPUT = 'CHANGE STATE: INIT'
EGATE_ACTIVATE_EXPECTED_OUTPUT = 'CHANGE STATE: ACTIVE'
EGATE_CONFIGURED_EXPECTED_OUTPUT = 'Script completed'
EGATE_STARTED_EXPECTED_OUTPUT = 'CHANGE STATE: STARTED'
EGATE_UE_CHANGE_CELL_EXPECTED_OUTPUT = 'location updated'
CMD_TIMEOUT = 10
SHELL_TIMEUOT = 20
SOCKET_TIMEOUT = 40
RCVD_BYTES = 4096
UE_REG_EXPECTED_OUTPUT = 'Received REGISTRATION COMPLETE from UE'
UE_PDU_EXPECTED_OUTPUT = 'rrcReconfigurationComplete'
UE_TRF_EXPECTED_OUTPUT = 'UE{ue_id}: Started {direction} Internal traffic'
UE_TRF_STOP_EXPECTED_OUTPUT = 'Stopped {direction} Internal traffic on Ue:{ue_id}'
UE_KILL_EXPECTED_OUTPUT = 'UE{ue_id}: silently killed'
TOTAL_AVG_TPUT_REGEX = r"cell.\s+([\d.]+)\s+Mbps\s+([\d.]+)\s+Mbps\s+([\d.]+)\s+Mbps\s+([\d.]+)\s+Mbps"


class AirphoneClient(object):
    def __init__(self, ip_address, username, password):
        self._wts_dir = "/home/ute/WTS"
        self._ssh_connection = create_ssh(host=ip_address, username=username, password=password)
        self._shell = None
        self._ip_address = ip_address
        self._username = username
        self._password = password

    def start_egate(self):
        self._connect_to_wts_vm()
        self._shell = self._ssh_connection.invoke_shell()
        return self._execute_egate_command_and_verify(EGATE_START_CMD, EGATE_PROMPT)

    def attach_ue(self, ue_id, pdu_id):
        self._connect_to_wts_vm()
        self._open_egate_console()
        Logger.info(f'AirPhone UE {ue_id}: Configuring UE')
        assert self._configure_ue(ue_id, pdu_id), 'Failure while configuring UE'
        Logger.info(f'AirPhone UE {ue_id}: Registering UE')
        assert self._register_ue(ue_id), 'Failure while UE register'
        Logger.info(f'AirPhone UE {ue_id}: Establishing PDU session {pdu_id}')
        assert self._setup_pdu_session(ue_id, pdu_id), 'Failure while establishing PDU session'

    def change_ue_cell(self, ue_id, cell_id):
        Logger.info(f'AirPhone UE {ue_id}: Changing cell to {cell_id}')
        return self._execute_egate_command_and_verify(
            UE_CHANGE_CELL_CMD.format(ue_id=ue_id, cell_id=cell_id), EGATE_UE_CHANGE_CELL_EXPECTED_OUTPUT)

    def start_traffic(self, ue_id, pdu_id, direction, tput, trf_id=1):
        direction_output = "Uplink" if "ul" in direction else "Downlink"
        Logger.info(f'AirPhone UE {ue_id}: Starting {direction_output} traffic of {tput} Mbps')
        command = TRF_DATA_START_CMD.format(ue_id=ue_id, pdu_id=pdu_id, dir=direction, tput=tput, trf_id=trf_id)
        return self._execute_egate_command_and_verify(
            command, UE_TRF_EXPECTED_OUTPUT.format(ue_id=ue_id, direction=direction_output))

    def stop_traffic(self, ue_id, pdu_id, direction):
        direction_output = "Uplink" if "ul" in direction else "Downlink"
        Logger.info(f'AirPhone UE {ue_id}: Stopping {direction_output} traffic')
        command = TRF_DATA_STOP_CMD.format(ue_id=ue_id, pdu_id=pdu_id, dir=direction)
        return self._execute_egate_command_and_verify(
            command, UE_TRF_STOP_EXPECTED_OUTPUT.format(ue_id=ue_id, direction=direction_output))

    def get_traffic_stats(self, ue_id, scell, type='pdsch'):
        command = TRF_DATA_GET_STATS_CMD.format(ue_id=ue_id, scell=scell, type=type)
        output = self._execute_egate_command_and_get_output(command)
        Logger.info(output)
        total_avg_out = re.search(TOTAL_AVG_TPUT_REGEX, output)
        return total_avg_out.group(4) if total_avg_out else None

    def get_full_traffic_stats(self, ue_id, scell, type='pdsch'):
        command = TRF_DATA_GET_STATS_CMD.format(ue_id=ue_id, scell=scell, type=type)
        return self._execute_egate_command_and_get_output(command)

    def kill_ue(self, ue_id):
        Logger.info(f'AirPhone UE {ue_id}: Destroying UE')
        command = UE_KILL_CMD.format(ue_id=ue_id)
        return self._execute_egate_command_and_verify(command, UE_KILL_EXPECTED_OUTPUT.format(ue_id=ue_id))

    def reset_egate(self):
        Logger.info(f'EGATE: Resetting')
        self._connect_to_wts_vm()
        self._open_egate_console()
        return self._execute_egate_command_and_verify(EGATE_RESET_CMD, EGATE_RESET_EXPECTED_OUTPUT)

    def activate_egate_config_file(self, filename='basic.cfg'):
        Logger.info(f'EGATE: Activating config {filename}')
        return self._execute_egate_command_and_verify(
            EGATE_ACTIVATE_CONFIG_FILE_CMD.format(filename=filename), EGATE_ACTIVATE_EXPECTED_OUTPUT)

    def configure_egate_config_file(self, filename='basic.cfg'):
        Logger.info(f'EGATE: Configuring with {filename}')
        return self._execute_egate_command_and_verify(
            EGATE_CFG_SIM_FILE_CMD.format(filename=filename), EGATE_CONFIGURED_EXPECTED_OUTPUT)

    def start_sim_egate(self):
        Logger.info(f'EGATE: Starting simulation')
        return self._execute_egate_command_and_verify(EGATE_START_SIM_CMD, EGATE_STARTED_EXPECTED_OUTPUT)

    def load_ue_capabilities_egate(self, ue_id, ue_caps_id, filename):
        Logger.info(f'EGATE: Loading capabilities for UE{ue_id} form file {filename}')
        return self._execute_egate_command_and_get_output(EGATE_LOAD_UE_CAPS_CMD.format(
            ue_id=ue_id, ue_caps_id=ue_caps_id, filename=filename))

    def _connect_to_wts_vm(self):
        try:
            self._ssh_connection.connect(
                self._ip_address, port=SSH_PORT, username=self._username, password=self._password,
                timeout=SOCKET_TIMEOUT)
        except (SSHException, socket.timeout):
            self._ssh_connection.close()
            raise

    def _disconnect_from_wts_vm(self):
        self._ssh_connection.close()

    def _open_egate_console(self):
        self._shell = self._ssh_connection.invoke_shell()
        return self._execute_egate_command_and_verify(EGATE_TELNET_CMD, EGATE_PROMPT)

    def _execute_egate_command_and_verify(self, command, expected_output, timeout=SHELL_TIMEUOT):
        self._shell.send(f'{command}\n'.encode('utf-8'))
        endtime = time.time() + timeout
        while time.time() < endtime:
            if self._shell.recv_ready():
                output = self._shell.recv(RCVD_BYTES).decode('utf-8')
                if expected_output in output:
                    return True
            time.sleep(0.01)
        return False

    def _execute_egate_command_and_get_output(self, command):
        self._shell.send(f'{command}\n'.encode('utf-8'))
        time.sleep(1)
        return self._shell.recv(RCVD_BYTES).decode('utf-8')

    def _configure_ue(self, ue_id, pdu_id):
        command = CONFIGURE_UE_CMD.format(ue_id=ue_id, pdu_id=pdu_id)
        return self._execute_egate_command_and_verify(command, '')

    def _register_ue(self, ue_id):
        command = REGISTER_UE_CMD.format(ue_id=ue_id)
        return self._execute_egate_command_and_verify(command, UE_REG_EXPECTED_OUTPUT)

    def _setup_pdu_session(self, ue_id, pdu_id, nwslice=1, gw=1):
        command = PDU_SESSION_SETUP_UE_CMD.format(ue_id=ue_id, pdu_id=pdu_id, nwslice=nwslice, gw=gw)
        return self._execute_egate_command_and_verify(command, UE_PDU_EXPECTED_OUTPUT)

    def clear_shell_buffer(self):
        self._shell.settimeout(0.1)
        try:
            while self._shell.recv_ready():
                _ = self._shell.recv(RCVD_BYTES)
            while self._shell.recv_stderr_ready():
                _ = self._shell.recv_stderr(RCVD_BYTES)
        except socket.timeout:
            pass
        except Exception as e:
            Logger.info(f"Error clearing shell buffer: {e}")
