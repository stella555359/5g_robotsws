import os
from moler.device import DeviceFactory
from taf.wts.runner import runner as wts_runner
from taf.transport.ssh import ssh
from taf.internal.sim.service.software_components import Egate, Edaemon
from taf.rfrl.utilities.tl_config import get_epc_object, get_epc_pc_credentials
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.transfer_files import upload_files


class epcsim_operations(object):
    TAF_EPCSIM_WS_ALIAS = 'TAF-EPCSIM{}'
    MOLER_EPCSIM_ALIAS = 'EPCSIM{}'
    MOLER_EPCSIM_WS_ALIAS = 'EPCSIM{}_WS'

    Egate.WITH_SUDO = True
    Edaemon.WITH_SUDO = True

    def __init__(self):
        self.ssh = ssh()
        self.wts_runner = wts_runner()
        self._s1_link_observer = []

    def start_epcsim(self, epc_id=0):
        """
        Start EpcSim(Edaemn and Egate) process on remote machine
        :param epc_id: ID related to TestLine config(tl.core)
        :return: None
        """
        epc_host_alias = self.TAF_EPCSIM_WS_ALIAS.format(epc_id)
        epc_pc_credentials = get_epc_pc_credentials(epc_id)
        epc_obj = get_epc_object(epc_id)
        self._connect_to_epcsim_remote_host(epc_id)

        self.wts_runner.configure_wtsemu_edaemon(edaemon_ssh_alias=epc_host_alias,
                                                 directory_path=epc_obj.dir_path, port=epc_obj.edaemon_port)
        self.wts_runner.configure_wtsemu_egate(egate_ssh_alias=epc_host_alias,
                                               directory_path=epc_obj.dir_path, port=epc_obj.egate_port)
        self.wts_runner.start_wtsemu(egate_console_ip=epc_pc_credentials[0], egate_port=epc_obj.egate_port)

    def stop_epcsim(self, epc_id=0):
        """
        Stop EpcSim(Edaemn and Egate) process on remote machine
        :param epc_id: ID related to TestLine config(tl.core)
        :return: None
        """
        epc_host_alias = self.TAF_EPCSIM_WS_ALIAS.format(epc_id)
        epc_obj = get_epc_object(epc_id)
        self._connect_to_epcsim_remote_host(epc_id)
        self.wts_runner.kill_wtsemu_edaemon(edaemon_port=epc_obj.edaemon_port, connection=epc_host_alias, sudo=True)
        self.wts_runner.kill_wtsemu_egate(egate_port=epc_obj.egate_port, connection=epc_host_alias, sudo=True)

    def _connect_to_epcsim_remote_host(self, epc_id=0):
        epc_host_alias = self.TAF_EPCSIM_WS_ALIAS.format(epc_id)
        epc_pc_credentials = get_epc_pc_credentials(epc_id)
        self.ssh.connect_to(hostname=epc_pc_credentials[0],
                            username=epc_pc_credentials[1],
                            password=epc_pc_credentials[2],
                            alias=epc_host_alias)

    @load_moler_configuration_from_tl()
    def scp_epcsim_configuration_file_to_remote_machine(self, local_cfg_file, epc_id=0):
        """
        SCP cfg configuration file to Remote Machine
        :param local_cfg_file: local path to configuration cfg file
        :param epc_id: ID related to TestLine config(tl.core)
        :return: None
        """
        epc_obj = get_epc_object(epc_id)
        repository_path = get_repository_path()
        cfg_file_path = os.path.join(repository_path, local_cfg_file)
        epc_ws_name = self.MOLER_EPCSIM_WS_ALIAS.format(epc_id)
        upload_files(local_dir=os.path.dirname(cfg_file_path),
                     local_file=os.path.basename(cfg_file_path),
                     device_name=epc_ws_name, remote_dir=os.path.dirname(epc_obj.cfg_filename))

    @load_moler_configuration_from_tl()
    def load_epcsim_configuration_file(self, epc_id=0, start_s1_link_observer=True):
        """
        Load configuration file and start simulation
        :param epc_id: ID related to TestLine config(tl.core)
        :param start_s1_link_observer: True/False
        :return: None
        """
        epc_obj = get_epc_object(epc_id)
        epc = DeviceFactory.get_device(name=self.MOLER_EPCSIM_ALIAS.format(epc_id))

        if start_s1_link_observer:
            s1_up = epc.get_event(event_name='s1_link_up', event_params={'till_occurs_times': 1})
            s1_up.start()
            self._s1_link_observer.append(s1_up)
        load_dcf_file = epc.get_cmd(cmd_name='sim_cfg', cmd_params={'options': 'file={}'.format(epc_obj.cfg_filename)})
        load_dcf_file(timeout=60)
        epc.get_cmd(cmd_name='start')(timeout=300)

    def wait_for_s1_up_on_all_epcsims(self):
        """
        Wait until S1 link is UP for all started EPCSIMs
        :return: None
        """
        for s1_observer in self._s1_link_observer:
            s1_observer.await_done(timeout=5 * 60)
