from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names


class Agent5G:

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def run_agent_5g(self, config_path, du_sw_version=None, cu_sw_version=None, label='CLOUD_5G_ASIKL_ABILB1_AEUD_ENB',
                     output_path='/home/ute/output', state='gnb_not_commissioned', agent_timeout=900,
                     result_path='/home/ute/testline_init_results/', bts_id=0, du_id=0):
        """
        Run agent_5g init command.

        :param config_path: path to TL config
        :param du_sw_version: du sw version
        :param cu_sw_version: cu sw version
        :param label: TL label e.g. 'CLOUD_5G_ASIKL_ABILB1_AEUD_ENB'
        :param output_path: agent_5g output path
        :param state: TL state e.g. 'gnb_not_commissioned'
        :param result_path: agent_5g result path
        :param bts_id: ID of BTS
        :param du_id: ID of DU
        :param agent_timeout: timeout for agent_5g execution, seconds
        :return: None
        """
        vm = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', bts_id, du_id),
                                      initial_state="PROXY_PC")
        vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": "source /opt/ute/agent_env/bin/activate"})()
        agent_5g = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "agent_5g init -l {} {} {} -o {} -s {} -R {} -p {}"
                              .format(label, "-b {}".format(du_sw_version) if du_sw_version else "--skip_du",
                                      '--cu_build {}'.format(cu_sw_version) if cu_sw_version else '', output_path,
                                      state,
                                      result_path, config_path)})
        MolerTest.info('cmd_agent: {}'.format(agent_5g))
        vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": "source /opt/ute/agent_env/bin/activate"})()
        agent_5g(timeout=agent_timeout)
        vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": "deactivate"})()
