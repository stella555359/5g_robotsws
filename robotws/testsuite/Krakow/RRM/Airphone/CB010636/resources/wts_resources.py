"""
:author: Anna Bien, Maryna Lukaczyk
:maintainer: Anna Bien, Maryna Lukaczyk
:owner_email: anna.bien@nokia.com, maryna.lukaczyk@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
"""
import importlib.util
import re
import os
import shutil
from itertools import cycle
import time
from ta5g_ue_mobility import ta5g_ue_mobility
from ta_egate_cmd_parser import ta_egate_cmd_parser
from taf.config.wts import wts
from taf.config.wts.exceptions import WtsConfigError
from taf.rfrl.utilities.robot.general import get_builtin_value
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_info, logger_console_info
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import get_cells_info, get_gnb_band
from testsuite.Krakow.RRM.Airphone.resources.Python.common_wts import (
    attach_ue_and_establish_pdu_session, start_traffic_for_multiple_ues, stop_data_traffic_for_multiple_ues,
    check_ue_thput_stats, configure_ips_on_vm_interfaces, wait_for_environment_prepared_for_wts_ready_state,
    attach_ue_and_perform_sgnb_addition, setup_x2_link, get_next_suci, get_next_imsi, get_next_ipv4_address,
    run_egate_cmd, wait_for_information_block_reception, check_bearer_stats)
from testsuite.Krakow.RRM.Airphone.resources.Python.wts_config_modification import (
    configure_additional_qosflow, configure_nwslices_in_wts_cfg_file, configure_additional_bearer, modify_bearer_qci,
    modify_bearer_id, modify_ue_cell_alignment, modify_ue_gnb_alignment, add_additional_qosrules
)
from testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities import get_log_dir, get_test_prefix
from testsuite.Krakow.RRM.Airphone.CB010636.resources.ue_capabilities import UeCap
from testsuite.Krakow.RRM.Airphone.CB010636.resources.variables import (
    GNB_IP, GNB2_IP, FR2_SA_TCS, FR2_NSA_TCS, FR2_SA_TCS_SIB_CELL1
)
from testsuite.Krakow.RRM.Airphone.CB010636.resources.cell_parameters import CellParam


class WtsSetup:
    """
    This class is responsible for setting up the WTS environment for test execution.
    It prepares the WTS configuration file, sets up necessary links, configures IP addresses on VM etc.
    """

    configuration_dir = os.path.dirname(os.path.abspath(__file__))

    def __init__(self):
        self._x2_link_pass_regexp = 'X2AP Link with GNB-<GNB-ID> .* is up'
        self._default_cfg_path = '/opt/wts/latest/basic_setup.cfg'
        self._target_filename = 'wts_cfg.cfg'
        self._wts_instance = wts()
        self._ue_cap_instance = UeCap()
        self._cell_param_instance = CellParam()
        self.set_sa_ue_command = \
            'set_ue simulated id=<UE_ID> uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39' \
            'C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=<SUCI> mode=nr ' \
            'enb=<ENB_ID> cell=<CELL_ID>'
        self.set_nsa_ue_command = \
            'set_ue simulated id=<UE_ID> uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 ' \
            'sec_key=0102030405060708090A0B0C0D0EFF00 nia=zuc nea=zuc imsi=<IMSI>'

    def setup_wts_environment(self, allow_first_reboot=True):
        """
        Prepares the WTS environment for test execution.
        This includes preparing the VM IP addresses, setting up the simulator and the X2 link.
        FR2 NSA - SIB messages are received after X2 link is established
        FR2 SA - X2 link should not be established, SIB is received only for PCell

        :param allow_first_reboot: (bool, optional) Whether to allow the first reboot. Default is True.
        """

        test_prefix = get_test_prefix()
        self._prepare_vm_ip_addresses()
        sib_dict = self._get_sib_dict()
        wait_for_environment_prepared_for_wts_ready_state(
            wts_config_filename=self._prepare_wts_configuration_file(test_prefix),
            sib_reception_dict=sib_dict,
            info_block_type='MasterInformationBlock',
            allow_first_reboot=allow_first_reboot,
            secondary_gnb_ip=GNB2_IP
        )
        if test_prefix not in FR2_SA_TCS:
            self._setup_x2_link()
            if test_prefix not in FR2_NSA_TCS:
                wait_for_information_block_reception(
                    sib_reception_dict=sib_dict,
                    info_block_type='SystemInformationBlockType1'
                )
        else:
            if test_prefix in FR2_SA_TCS_SIB_CELL1:
                sib_dict = {2: [1]}
            else:
                sib_dict = {2: [2]}
            wait_for_information_block_reception(
                sib_reception_dict=sib_dict,
                info_block_type='SystemInformationBlockType1'
            )

    def _get_x2_link_pass_regexp(self, complementary_device):
        return self._x2_link_pass_regexp.replace('<GNB-ID>', str(complementary_device))

    def _setup_x2_link(self):
        setup_x2_link(pass_regexp=self._get_x2_link_pass_regexp(2))
        if GNB2_IP:
            setup_x2_link(complementary_device=3, pass_regexp=self._get_x2_link_pass_regexp(3))

    def _prepare_wts_configuration_file(self, test_prefix):
        """
        Prepare WTS configuration file for test execution
        """

        wts_cfg_path = os.path.join(get_log_dir(), self._target_filename)
        shutil.copyfile(src=self._default_cfg_path, dst=wts_cfg_path)
        self._wts_instance.load_wts_cfg(wts_cfg_path)
        self._add_ues(test_prefix)
        self._modify_ue_cap(test_prefix)
        self._modify_cell_param(test_prefix)
        self._change_log_level(test_prefix)
        self._fr2_sa_reconfigure_link_ctrl(test_prefix)
        self._wts_instance.modify(
            command=f'enb_endc_param id=1',
            modification=f'serving_cell_index_range_scg=1:16'
        )
        self._modify_bearer_id(test_prefix)
        self._modify_bearer_qci(test_prefix)
        self._add_additional_qosrules(test_prefix)
        self._add_qosflow(test_prefix)
        self._add_bearer(test_prefix)
        self._remove_ues(test_prefix)
        self._modify_ue_cell_alignment(test_prefix)
        self._modify_ue_gnb_alignment(test_prefix)
        self._wts_instance.save_wts_cfg(file_path=wts_cfg_path)
        return wts_cfg_path

    def _prepare_vm_ip_addresses(self):
        """
        Add to VM interfaces IP addresses from configuration file
        """

        configure_ips_on_vm_interfaces(
            cfg_filepath=self._default_cfg_path,
            sim_gnb=False
        )

    @staticmethod
    def _get_sib_dict():
        """
        Get SIBs dictionary for WTS environment preparation.
        If second gNB is available, it will be added to the dictionary
        """

        def get_cells_ids(host_ip):
            gnb_cells = get_cells_info(bts_host_ip=host_ip)
            return [cell['globalCellId'] for cell in gnb_cells]

        sib_dict = {2: get_cells_ids(GNB_IP)}
        if GNB2_IP:
            sib_dict.update({3: get_cells_ids(GNB2_IP)})
        return sib_dict

    def _add_sa_ue(self, ue_cfg, available_ues_ids):
        """
        Add SA UE to WTS configuration file:
            - If possible get UE1 as a pattern for SA UEs.
            - In other case create UE configuration from scratch
        # TODO: Not tested
        """

        if 1 in available_ues_ids:
            first_suci = self._wts_instance.get_parameter(
                command='set_ue simulated id=1',
                parameter='suci'
            )
            self._wts_instance.clone_and_modify(
                command='set_ue simulated id=1',
                modification=f'id={ue_cfg["ue_id"]} enb={ue_cfg["enb_id"]} cell={ue_cfg["cell_id"]} '
                             f'suci={get_next_suci(first_suci=first_suci, eu_id=ue_cfg["ue_id"])}'
            )
            self._wts_instance.clone_and_modify(
                command='ue_param id=1',
                modification=f'id={ue_cfg["ue_id"]}'
            )
            pdu_gateway_net_ip = self._wts_instance.get_parameter(
                command='set_pdu_gateway id=1',
                parameter='ue_nat_ip'
            )
            new_pdu_gateway_net_ip = get_next_ipv4_address(
                addr=pdu_gateway_net_ip,
                step=ue_cfg["ue_id"] - 1
            )
            self._wts_instance.clone_and_modify(
                command='set_pdu_gateway id=1',
                modification=f'id={ue_cfg["ue_id"]} ue_nat_ip={new_pdu_gateway_net_ip}'
            )
        else:
            first_suci = '0:311:489:0000:0:0:021645400'
            new_ue_cmd = self.set_sa_ue_command.replace('<UE_ID>', str(ue_cfg['ue_id'])) \
                .replace('<SUCI>', get_next_suci(first_suci=first_suci, eu_id=ue_cfg["ue_id"])) \
                .replace('<ENB_ID>', str(ue_cfg['enb_id'])).replace('<CELL_ID>', str(ue_cfg['cell_id']))
            self._wts_instance.insert(
                command=new_ue_cmd,
                location='before',
                reference='set_qosflow id=1'
            )
            self._wts_instance.insert(
                command=f'ue_param id={ue_cfg["ue_id"]} ue_nr_capabilities=None',
                location='after',
                reference=f'set_ue simulated id={ue_cfg["ue_id"]}'
            )
            self._wts_instance.insert(
                command=f'set_pdu_gateway id={ue_cfg["ue_id"]} ue_nat_ip=72.23.0.{ue_cfg["ue_id"]} '
                        f'dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP',
                location='after',
                reference=f'set_nwslice id=1'
            )

    def _add_nsa_ue(self, ue_cfg, available_ues_ids):
        """
        Add NSA UE to WTS configuration file:
            - If possible get UE11 as a pattern for NSA UEs.
            - In other case create UE configuration from scratch
        """

        if 11 in available_ues_ids:
            first_imsi = self._wts_instance.get_parameter(
                command='set_ue simulated id=11',
                parameter='imsi'
            )
            new_imsi = get_next_imsi(
                imsi=first_imsi,
                increment=ue_cfg["ue_id"] - 11
            )
            self._wts_instance.clone_and_modify(
                command='set_ue simulated id=11',
                modification=f'id={ue_cfg["ue_id"]} imsi={new_imsi}'
            )
            self._wts_instance.clone_and_modify(
                command='ue_param id=11',
                modification=f'id={ue_cfg["ue_id"]}'
            )
            pdu_gateway_net_ip = self._wts_instance.get_parameter(
                command='set_pdu_gateway id=11',
                parameter='ue_nat_ip'
            )
            new_pdu_gateway_net_ip = get_next_ipv4_address(
                addr=pdu_gateway_net_ip,
                step=ue_cfg["ue_id"] - 11
            )
            self._wts_instance.clone_and_modify(
                command='set_pdu_gateway id=11',
                modification=f'id={ue_cfg["ue_id"]} ue_nat_ip={new_pdu_gateway_net_ip}'
            )
            self._wts_instance.clone_and_modify(
                command='set_bearer ue=11',
                modification=f'ue={ue_cfg["ue_id"]} ip=4.7.254.{ue_cfg["ue_id"]}'
            )
        else:
            first_imsi = '311:489:21645500'
            new_imsi = get_next_imsi(
                imsi=first_imsi,
                increment=ue_cfg["ue_id"] - 11
            )
            new_ue_cmd = self.set_nsa_ue_command.replace('<UE_ID>', str(ue_cfg['ue_id'])) \
                .replace('<IMSI>', new_imsi)
            self._wts_instance.insert(
                command=new_ue_cmd,
                location='before',
                reference='set_qosflow id=1'
            )
            self._wts_instance.insert(
                command=f'ue_param id={ue_cfg["ue_id"]} ue_nr_capabilities=None dual_conn=eutra_nr '
                        f'ue_eutra_nr_capabilities=None',
                location='after',
                reference=f'set_ue simulated id={ue_cfg["ue_id"]}'
            )
            self._wts_instance.insert(
                command=f'set_pdu_gateway id={ue_cfg["ue_id"]} ue_nat_ip=72.23.0.{ue_cfg["ue_id"]} '
                        f'dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP',
                location='after',
                reference=f'set_nwslice id=1'
            )
            self._wts_instance.insert(
                command=f'set_bearer id=2 ue={ue_cfg["ue_id"]} qci=9 pdn=1 ip=4.7.254.{ue_cfg["ue_id"]} default=on '
                        f'ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal',
                location='before',
                reference='set_qosflow'
            )

    def _add_ues(self, test_prefix):
        """
        Add missing UEs based on variable from test_scenario_variables.py
        """

        def get_tuple_of_already_configured_ues():
            ue_id_regexp = re.compile(r'set_ue simulated id=(\d+)')
            ues_commands = self._wts_instance.find_all('set_ue simulated')
            ues_ids = []
            for command in ues_commands:
                ues_ids.append(int(ue_id_regexp.search(command).group(1)))
            return tuple(ues_ids)

        ues_conf = get_builtin_value(f'{test_prefix}_UE_CFG')
        if ues_conf is None:
            ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_1_UE_CFG')
        already_configured_ues = get_tuple_of_already_configured_ues()
        for ue_conf in ues_conf:
            if ue_conf['ue_id'] in already_configured_ues:
                continue
            getattr(self, f'_add_{ue_conf["net_arch"]}_ue')(ue_conf, already_configured_ues)

    def _modify_ue_cap(self, test_prefix):
        """
        Modify UE Capabilities for SA and NSA UEs
        """

        ue_cap_map = self._ue_cap_instance.get_ue_capabilities_by_test_name(test_prefix)
        for ue_id, ue_cap_cfg in ue_cap_map.items():
            for ue_cap_type, ue_cap in ue_cap_cfg.items():
                self._wts_instance.modify(
                    command=f'ue_param id={ue_id}',
                    modification=f'ue_{ue_cap_type}_capabilities={ue_cap}'
                )

    def _modify_cell_param(self, test_prefix):
        """
        Modify Cell parameters
        """

        cells_param_map = self._cell_param_instance.get_cell_parameters_by_test_name(test_prefix)
        for cell_id, cell_param_cfg in cells_param_map.items():
            gnb_value = cell_param_cfg.get('gnb', 2)
            command = f'set_cell id={cell_id} gnb={gnb_value}'
            if 'delete' in cell_param_cfg.keys():
                self._wts_instance.delete(command=command)
                ue_command = f'set_ue simulated id={cell_id}'
                self._wts_instance.delete(command=ue_command)
                ue_param_command = f'ue_param id={cell_id}'
                self._wts_instance.delete(command=ue_param_command)
                pdu_gw_command = f'set_pdu_gateway id={cell_id}'
                self._wts_instance.delete(command=pdu_gw_command)
            else:
                for param, value in cell_param_cfg.items():
                    modification = f'{param}={value}'
                    try:
                        self._wts_instance.modify(command=command, modification=modification)
                    except WtsConfigError:
                        self._wts_instance.clone_and_modify(command=f'set_cell id={cell_id - 1} gnb=2',
                                                            modification=f'id={cell_id}')
                        self._wts_instance.modify(command=command, modification=modification)

    def _remove_ues(self, test_prefix):
        ues_to_delete = get_builtin_value(f'{test_prefix}_UE_TO_DELETE_CFG')
        if ues_to_delete is not None:
            for ue_id in ues_to_delete:
                self._wts_instance.delete(
                    command=f'ue_param id={ue_id}'
                )
                self._wts_instance.delete(
                    command=f'set_ue simulated id={ue_id}'
                )
                self._wts_instance.delete(
                    command=f'set_pdu_gateway id={ue_id}'
                )
                self._wts_instance.delete(
                    command=f'set_bearer id=2 ue={ue_id}'
                )

    def _change_log_level(self, test_prefix):
        """
        Change debug_log level for selected TCs
        """

        if test_prefix in ['a_a1_04', 'a_b104_04', 'b_b301_01']:
            self._wts_instance.modify(
                command='debug_log',
                modification='level=6'
            )

    def _fr2_sa_reconfigure_link_ctrl(self, test_prefix):
        """
        Applicable to FR2 SA configuration only.
        """

        if test_prefix in FR2_SA_TCS:
            self._wts_instance.delete(
                command='link_ctrl_param'
            )
            self._wts_instance.insert(
                command='link_ctrl_param use_hb=off',
                location='after',
                reference='trace uec=1'
            )
            self._wts_instance.insert(
                command='sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled',
                location='after',
                reference='link_ctrl_param'
            )
            self._wts_instance.delete(
                command='trace enb=1 protocol=x2 on'
            )
            self._wts_instance.delete(
                command='trace uec=1 protocol=x2 on'
            )

    def _modify_bearer_qci(self, test_prefix):
        """
        Modify QCI value nof the existing bearer in the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_bearer_qci_configuration():
            """
            Retrieve the QCI bearer configuration for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_BEARER_QCI_CONFIGURATION"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(f"The QCI configuration for {variable_name} was not found in the module.")

        try:
            bearer_qci_configuration = _get_bearer_qci_configuration()
            qci_capability = self._wts_instance.get_parameter_as_list(
                command=f'enb_param id=1', parameter=f'endc_capable_qci'
            )
            formatted_qci_capability = ",".join(qci_capability)
            for config in bearer_qci_configuration:
                if str(config['new_qci']) not in qci_capability and 'all' not in qci_capability:
                    self._wts_instance.modify(
                        command=f'enb_param id=1',
                        modification=f'endc_capable_qci={formatted_qci_capability},{config["new_qci"]}'
                    )
                modify_bearer_qci(
                    self._wts_instance, config['id'], config['ue'], config['old_qci'], config['new_qci']
                )

        except AttributeError as error:
            logger_console_info(error)

    def _add_qosflow(self, test_prefix):
        """
        Add new qosflow to the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_qosflow_configuration():
            """
            Retrieve the QOS flow configuration for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_QOS_FLOW_CONFIGURATION"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(f"The configuration for {variable_name} was not found in the module.")

        try:
            qosflow_configuration = _get_qosflow_configuration()
            configure_additional_qosflow(self._wts_instance, qosflow_configuration)
            configure_nwslices_in_wts_cfg_file(self._wts_instance, [])

        except AttributeError as error:
            logger_console_info(error)

    def _add_additional_qosrules(self, test_prefix):
        """
        Add new qosrules to the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_qosrules_configuration():
            """
            Retrieve the QOS rules configuration for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f'{test_prefix}_QOS_RULES_CONFIGURATION'

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(f'The configuration for {variable_name} was not found in the module.')

        try:
            qosrules_configuration = _get_qosrules_configuration()
            add_additional_qosrules(self._wts_instance, qosrules_configuration)
            configure_nwslices_in_wts_cfg_file(self._wts_instance, [])
        except AttributeError as error:
            logger_console_info(error)

    def _modify_bearer_id(self, test_prefix):
        """
        Modify bearer ID value of the existing bearer in the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_bearer_id_configuration():
            """
            Retrieve the new bearer ID configuration for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_BEARER_MODIFICATION"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(f"The bearer configuration for {variable_name} was not found in the module.")

        try:
            bearer_id_configuration = _get_bearer_id_configuration()
            for config in bearer_id_configuration:
                modify_bearer_id(
                    self._wts_instance, config['ue'], config['old_bearer_id'], config['new_bearer_id']
                )

        except AttributeError as error:
            logger_console_info(error)

    def _add_bearer(self, test_prefix):
        """
        Add new bearer to the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_bearer_configuration():
            """
            Retrieve the bearer configuration for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_BEARER_CONFIGURATION"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(f"The configuration for {variable_name} was not found in the module.")

        try:
            bearer_configuration = _get_bearer_configuration()
            for config in bearer_configuration:
                configure_additional_bearer(
                    wts_instance=self._wts_instance,
                    bearers=[2, 3], first_nsa_ue=config['ue'], target_number_of_nsa_ues=1,
                    qci=config['qci'], pdn=config['pdn'], default=config['default'],
                )
            if 'D_B104_01' in test_prefix:
                commands_to_delete = (
                    'enb_param id=1',
                    'ue_enb_endc_param id=1 bearer=2-3',
                    'set_bearer id=3 ue=33 qci=9 pdn=1 default=on trf_type=internal',
                    'set_bearer id=3 ue=32 qci=9 pdn=1 default=on trf_type=internal',
                    'set_bearer id=3 ue=31 qci=8 pdn=1 default=on trf_type=internal'
                )
                for command in commands_to_delete:
                    self._wts_instance.delete(command=command)

                self._wts_instance.modify(
                    command='set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal',
                    modification='qci=8'
                )
                self._wts_instance.insert(
                    command='enb_param id=1 drb_id_begin=3 endc_capable_qci=all',
                    location='after',
                    reference='set_enb id=1'
                )
                self._wts_instance.insert(
                    command='ue_enb_endc_param id=1 bearer=2-3',
                    location='after',
                    reference='enb_param id=1'
                )
            if 'A_B202_01' in test_prefix:
                commands_to_delete = (
                    'set_bearer id=2 ue=151 qci=9',
                )
                for command in commands_to_delete:
                    self._wts_instance.delete(command=command)

        except AttributeError as error:
            logger_console_info(error)

    def _modify_ue_cell_alignment(self, test_prefix):
        """
        Modify cell alignment of the existing UEs in the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_ue_cell_alignment():
            """
            Retrieve the gNB UE cell alignment for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_UE_CELL_ALIGNMENT"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(
                    f'The {variable_name} configuration was not found in the module.'
                )

        try:
            ue_cell_alignment = _get_ue_cell_alignment()
            for config in ue_cell_alignment:
                modify_ue_cell_alignment(
                    self._wts_instance, config['id'], config['old_cell'], config['new_cell']
                )

        except AttributeError as error:
            logger_console_info(error)

    def _modify_ue_gnb_alignment(self, test_prefix):
        """
        Modify gNB alignment of the existing UEs in the existing WTS configuration file.
        """
        test_prefix = test_prefix.upper()

        def _get_ue_gnb_alignment():
            """
            Retrieve the gNB UE alignment for the given test prefix.
            """
            module_path = os.path.join(self.configuration_dir, "test_scenario_variables.py")
            spec = importlib.util.spec_from_file_location("test_scenario_variables", module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            variable_name = f"{test_prefix}_UE_GNB_ALIGNMENT"

            if hasattr(module, variable_name):
                return getattr(module, variable_name)
            else:
                raise AttributeError(
                    f'The {variable_name} configuration was not found in the module.'
                )

        try:
            ue_gnb_alignment = _get_ue_gnb_alignment()
            for config in ue_gnb_alignment:
                modify_ue_gnb_alignment(
                    self._wts_instance, config['id'], config['old_gnb'], config['new_gnb']
                )

        except AttributeError as error:
            logger_console_info(error)


class WtsResources:
    """
    This class provides methods that perform operations in the WTS simulator.
    """

    def __init__(self):
        self._pdu_regexp_pattern = f'UE-<UE-ID> PDU SESSION ID-<PDU-ID> setup/reestablishment complete'
        self._ue_deregister_regexp_pattern = f'UE<UE-ID>: detached'
        self._dl_tput_stats_pass_regexp = 'NR PDSCH'
        self._ul_tput_stats_pass_regexp = 'NR PUSCH'

    def _get_pdu_regexp(self, ue_id, pdu):
        return self._pdu_regexp_pattern.replace('<UE-ID>', str(ue_id)).replace('<PDU-ID>', str(pdu))

    @staticmethod
    def wait_for_traffic_running(duration=1, **kwargs):
        """
        :param duration: (int) Wait time in seconds
        """

        time.sleep(duration)

    def attach_sa_ue_and_establish_pdu_session(self, ue_id=1, cell_id=1, enb_id=1, pdu=1, nwslice=1):
        attach_ue_and_establish_pdu_session(
            ue_id=ue_id,
            cell_id=cell_id,
            enb_id=enb_id,
            pdu=pdu,
            nwslice=nwslice,
            pdu_regexp=self._get_pdu_regexp(ue_id, pdu),
        )

    def attach_multiple_sa_ues_and_establish_pdu_session(self, ues_conf):
        ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_UE_CFG')
        if ues_conf is None:
            ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_1_UE_CFG')
        for ue in ues_conf:
            if ue["net_arch"] == "sa":
                attach_ue_and_establish_pdu_session(
                    ue_id=ue['ue_id'],
                    cell_id=ue['cell_id'],
                    enb_id=ue['enb_id'],
                    pdu=ue['pdu'],
                    pdu_regexp=self._get_pdu_regexp(ue['ue_id'], ue['pdu']),
                )
                time.sleep(2)  # Better results with sleep between operations - avoidance of potential race conditions.

    @staticmethod
    def attach_nsa_ue_and_perform_sgnb_addition(ue_id=101, bearer=2, cell_id=1, enb_id=2, profile=None,
                                                timeout=5):
        attach_ue_and_perform_sgnb_addition(
            ue_id=ue_id,
            bearer=bearer,
            cell_id=cell_id,
            enb_id=enb_id,
            profile=profile,
            timeout=timeout
        )

    @staticmethod
    def add_bearer_for_nsa_ue(add_bearer_info):
        ue = add_bearer_info['ue']
        bearer_id = add_bearer_info['id']
        precedence_1 = add_bearer_info['precedence_1']
        cmd = f'bearer_add ue={ue} id={bearer_id} filter=2 precedence={precedence_1}'
        logger_console_info(f'Adding bearer for NSA UE with command: {cmd}')
        run_egate_cmd(cmd)

    @staticmethod
    def define_pdu_session_modification(pdu_modify_info):
        pdu_modify_info = pdu_modify_info if pdu_modify_info else get_builtin_value(f'{get_test_prefix()}_UE_CFG_EXTRA')
        for config in pdu_modify_info:
            ue = config['ue']
            pdu = config['pdu']
            by = config['by']
            cmd = 'ue_pdu_session_modify'
            cmd += f' pdu={pdu}'
            if 'qosflows_to_add' in config:
                qosflows_to_add = config['qosflows_to_add']
                cmd += f' qosflows_to_add={qosflows_to_add}'
            if 'qosflows_to_del' in config:
                qosflows_to_del = config['qosflows_to_del']
                cmd += f' qosflows_to_del={qosflows_to_del}'
            cmd += f' by={by} ue={ue}'
            logger_console_info(f'Modifying pdu session with command: {cmd}')
            run_egate_cmd(cmd)
            time.sleep(2)

    @staticmethod
    def define_pdu_session_modification_nsa(pdu_modify_info):
        ue = pdu_modify_info['ue']
        by = pdu_modify_info['by']
        bearer_to_add = pdu_modify_info['bearer_to_add']
        cmd = f'enb_ue_dc_modify ue={ue} bearer_to_add={bearer_to_add} type=split_scg by={by} cause=off'
        logger_console_info(f'Modifying pdu session with command: {cmd}')
        run_egate_cmd(cmd)

    def attach_sa_ue_and_run_traffic(self, ue_id=1, pdu=1, cell_id=1, enb_id=2, nwslice=1, trf_dir='bi', **kwargs):
        """
        Attach single SA UE and run traffic for it
        """

        attach_ue_and_establish_pdu_session(
            ue_id=ue_id,
            cell_id=cell_id,
            enb_id=enb_id,
            pdu=pdu,
            nwslice=nwslice,
            pdu_regexp=self._get_pdu_regexp(ue_id, pdu),
        )
        if 'burst' in kwargs:
            time.sleep(3)  # necessary for traffic counters to be more accurate
            kwargs.pop('net_arch', None)
            self.start_multiple_burst_traffic(
                ue_ids=[ue_id],
                net_arch='SA',
                traffic_direction=trf_dir,
                **kwargs
            )
        else:
            time.sleep(3)  # necessary for traffic counters to be more accurate
            start_traffic_for_multiple_ues(
                number_of_ues=1,
                first_ue_id=ue_id,
                traffic_direction=trf_dir,
                **kwargs
            )

    def attach_nsa_ue_and_run_traffic(self, ue_id=11, bearer=2, cell_id=1, enb_id=2, trf_dir='bi', **kwargs):
        """
        Attach single NSA UE and run traffic for it
        """

        attach_ue_and_perform_sgnb_addition(
            ue_id=ue_id,
            bearer=bearer,
            cell_id=cell_id,
            enb_id=enb_id
        )
        if 'burst' in kwargs:
            time.sleep(3)  # necessary for traffic counters to be more accurate
            kwargs.pop('net_arch', None)
            self.start_multiple_burst_traffic(
                ue_ids=[ue_id],
                traffic_direction=trf_dir,
                **kwargs
            )
        else:
            time.sleep(3)  # necessary for traffic counters to be more accurate
            start_traffic_for_multiple_ues(
                number_of_ues=1,
                first_ue_id=ue_id,
                traffic_direction=trf_dir,
                **kwargs
            )

    def register_multiple_ues_and_handle_traffic(self, ues_conf=None, trf_duration=5, deregister=False):
        """
        Handle registering UEs and traffic running based on configuration specified in 'ues_conf' parameter.

        :param ues_conf: (tuple) global value from test_scenario_variables.py
        :param trf_duration: (int) Time when traffic is running for single UE [s]
        :param deregister: (bool)
        """

        ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_UE_CFG')
        if ues_conf is None:
            ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_1_UE_CFG')
        for ue_conf in ues_conf:
            getattr(self, f'attach_{ue_conf["net_arch"]}_ue_and_run_traffic')(**ue_conf)
            if trf_duration:
                self.wait_for_traffic_running(trf_duration)
                self.get_ue_throughput_stats(**ue_conf)
                self.stop_traffic(number_of_ues=1, first_ue_id=ue_conf['ue_id'], net_arch=ue_conf['net_arch'])
            if deregister:
                if ue_conf["net_arch"] == 'sa':
                    self.deregister_ues(sa_ues=str(ue_conf['ue_id']))
                else:
                    self.deregister_ues(nsa_ues=str(ue_conf['ue_id']))

    def get_ue_throughput_stats(self, ue_id=1, trf_dir='bi', scell_range='0-15', bearer_id=2, **kwargs):
        """
        Get UE throughput statistics

        :param ue_id: (int)
        :param trf_dir: (str) Traffic direction 'dl', 'ul' or 'bi'
        :param scell_range: (str) Cells range for which statistics will be displayed
        :param bearer_id: (int) bearer ID for NSA UE
        """

        if 'c_b202_013' in get_test_prefix():
            nsa_tput = check_bearer_stats(bearer_id=bearer_id, ue_id=ue_id)
            return nsa_tput
        else:
            dl_stats, ul_stats = None, None
            if trf_dir in ['bi', 'dl']:
                dl_stats = check_ue_thput_stats(
                    ues_ids=ue_id,
                    scell=scell_range,
                    type='pdsch',
                    pass_regexp=self._dl_tput_stats_pass_regexp
                )
                logger_console_info(dl_stats)
            if trf_dir in ['bi', 'ul']:
                ul_stats = check_ue_thput_stats(
                    ues_ids=ue_id,
                    scell=scell_range,
                    type='pusch',
                    pass_regexp=self._ul_tput_stats_pass_regexp
                )
                logger_console_info(ul_stats)
            return dl_stats, ul_stats

    @staticmethod
    def _get_data_rates_on_scells(ue_id, scell_id, trf_dir):
        """
        Gets data rate for UE on given SCell
        :param ue_id: ID of the UE
        :param scell_id: ID of the checked SCell
        :param trf_dir: DL or UL transmission
        :return: Throughput value for UE on given SCell
        """
        ta_egate = ta_egate_cmd_parser()
        cmd = ta_egate.get_command('ue_stats_nr')
        if trf_dir.lower() == 'dl':
            trf_type = 'pdsch'
        if trf_dir.lower() == 'ul':
            trf_type = 'pusch'
        ue_stats_out = cmd(id=ue_id, scell=scell_id, type=trf_type).execute_and_parse()
        traffic_value = float(ue_stats_out["CellIndex-" + str(scell_id)]["Average"]["value"])
        traffic_unit = str(ue_stats_out["CellIndex-" + str(scell_id)]["Average"]["unit"])
        return traffic_value, traffic_unit

    def verify_traffic_on_scell_for_ue(self, ue_id, scell_id, trf_dir, expected_traffic_rate_mbps, error_margin=15):
        """
        Function to check the average ul/dl data traffic rate on PCell/SCell for single UE.

        :param ue_id: (int) UE id for which data traffic rate is checked
        :param scell_id: (int) SCell id for which data traffic rate is checked (0 is for PCell)
        :param trf_dir: (str) Traffic direction (ul or dl)
        :param expected_traffic_rate_mbps: (int) Expected data traffic rate in Mbps
        :param error_margin: (int) error margin in percent
        :return: None
        """
        tput = float(expected_traffic_rate_mbps)
        error_margin_percent = float(error_margin) / 100.0
        max_accepted_traffic_value = tput + (tput * error_margin_percent)
        min_accepted_traffic_value = tput - (tput * error_margin_percent)
        measured_traffic_value, measured_traffic_unit = self._get_data_rates_on_scells(ue_id, scell_id, trf_dir)
        if int(expected_traffic_rate_mbps) == 0:
            assert measured_traffic_value == 0, "Unexpected average data traffic rate - should be 0"
            return
        if measured_traffic_unit == "Mbps" and \
                min_accepted_traffic_value <= measured_traffic_value <= max_accepted_traffic_value:
            logger_console_info(f'Average data rate on SCell-{scell_id} for NR_UE{ue_id} '
                                f'has correct value of {measured_traffic_value} Mbps.')
            return
        raise AssertionError(f'Unexpected average data traffic rate. {measured_traffic_value}MBps is out of expected '
                             f'range {min_accepted_traffic_value}MBps - {max_accepted_traffic_value}Mbps.')

    @staticmethod
    def start_traffic(ue_id, direction, pdu=1, qfi=1, trf_id=1,
                      protocol="udp", timeout=30, net_arch='sa',
                      mbps=50, seconds=60, bearer=2, **kwargs):
        """
        Start data traffic in egate for single UE

        :param ue_id: (int) UE id for which data traffic is started
        :param direction: (str) Traffic direction (ul, dl or bi)
        :param pdu: (int) PDU id
        :param qfi: (int) QoS flow id
        :param trf_id: (int) Traffic id
        :param protocol: (str) Traffic protocol
        :param timeout: (int) Operation timeout
        :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
        :param mbps: (int) Traffic rate in megabits per second
        :param seconds: (int) Maximum number of seconds to generate traffic
        :param bearer: (int) Bearer id
        **kwargs: Additional parameters for egate command
        """

        command_args = ''
        dir_dict = {'dl': 'Downlink', 'ul': 'Uplink'}
        for key, value in kwargs.items():
            command_args += ' ' + str(key) + '=' + str(value)
        if net_arch == 'sa':
            cmd = f'trf_data_start ue={ue_id} pdu={pdu} qfi={qfi} trf_id={trf_id}' \
                  f' mbps={mbps} dir={direction} protocol={protocol} seconds={seconds}{command_args}'
            pass_regexp = f'Started {dir_dict[direction]} Internal traffic over {protocol.upper()} on Ue:{ue_id}'
        else:
            cmd = f'trf_data_start ue={ue_id} id={bearer} dir={direction}' \
                  f' trf_id={trf_id} mbps={mbps} protocol={protocol} seconds={seconds}{command_args}'
            pass_regexp = f'UE {ue_id}: {protocol.upper()} {direction.upper()} TRF'
        run_egate_cmd(cmd=cmd, pass_regexp=pass_regexp, timeout=timeout)
        logger_console_info(f'{direction.upper()} {protocol} data for UE {ue_id} is started')

    def start_traffic_multiple_ues(self, ues_conf):
        ues_conf = ues_conf if ues_conf else get_builtin_value(f'{get_test_prefix()}_UE_CFG_TRAFFIC')
        for ue in ues_conf:
            ue_id = ue['ue_id']
            direction = ue['direction']
            trf_id = ue['trf_id']
            net_arch = ue['net_arch']
            mbps = ue['throughput']
            seconds = ue['duration']
            protocol = ue['protocol']
            burst_data = ue.get('burst')
            if net_arch == 'sa':
                pdu = ue['pdu']
                qfi = ue['qfi']
                if burst_data is None:
                    self.start_traffic(ue_id, direction, pdu, qfi, trf_id, protocol, 30, net_arch, mbps, seconds)
                else:
                    self.start_burst_traffic(
                        ue_id, direction, burst_data['period_ms'], burst_data['burst'], burst_data['size'],
                        pdu, qfi, trf_id, protocol, "on", 30, net_arch
                    )
            else:
                bearer = ue['bearer']
                if burst_data is None:
                    self.start_traffic(ue_id, direction, 1, 1, trf_id, protocol, 30, net_arch, mbps, seconds, bearer)
                else:
                    self.start_burst_traffic(
                        ue_id, direction, burst_data['period_ms'], burst_data['burst'], burst_data['size'],
                        1, 1, trf_id, protocol, "on", 30, net_arch, bearer
                    )

    @staticmethod
    def start_burst_traffic(ue_id, direction, period_ms=10, burst=2, size=6000, pdu=1, qfi=1, trf_id=1,
                            protocol="udp", cl_trf_stats='on', timeout=30, net_arch='sa', bearer=2, **kwargs):
        """
        Start data traffic in egate for single UE

        :param ue_id: (int) UE id for which data traffic is started
        :param direction: (str) Traffic direction (ul, dl or bi)
        :param period_ms: (int) Period (4,6,8,...,20,30,40,...) between bursts
        :param burst: (int) Number of packets to be sent in burst
        :param size: (int) Layer 3 packet size range (size includes all headers beginning from IP)
                           {V}:{V}, where {V} is 42..9000
        :param pdu: (int) PDU id
        :param qfi: (int) QoS flow id
        :param trf_id: (int) Traffic id
        :param protocol: (str) Traffic protocol
        :param timeout: (int) Operation timeout
        :param cl_trf_stats: (str) Toggle for clear L3 statistics for the traffic instance (on, off)
        :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
        :param bearer: (int) Bearer id
        **kwargs: Additional parameters for egate command
        """

        command_args = ''
        dir_dict = {'dl': 'Downlink', 'ul': 'Uplink'}
        for key, value in kwargs.items():
            command_args += ' ' + str(key) + '=' + str(value)
        if net_arch == 'sa':
            cmd = f'trf_data_start ue={ue_id} dir={direction} period_ms={period_ms} burst={burst} size={size}' \
                  f' pdu={pdu} qfi={qfi} trf_id={trf_id} protocol={protocol} cl_trf_stats={cl_trf_stats}{command_args}'
            pass_regexp = f'Started {dir_dict[direction]} Internal traffic over {protocol.upper()} on Ue:{ue_id}'
        else:
            cmd = f'trf_data_start ue={ue_id} dir={direction} period_ms={period_ms} burst={burst} size={size}' \
                  f' id={bearer} trf_id={trf_id} protocol={protocol} cl_trf_stats={cl_trf_stats}{command_args}'
            pass_regexp = f'UE {ue_id}: {protocol.upper()} {direction.upper()} TRF'
        run_egate_cmd(cmd=cmd, pass_regexp=pass_regexp, timeout=timeout)
        logger_console_info(f'{direction.upper()} {protocol} data for UE {ue_id} is started')

    @staticmethod
    def merge_different_lengths_lists(l1, l2):
        """
        Merges two lists into a list of tuples, cycling through the shorter list to match
        the length of the longer one.
        """
        list_of_tuples = zip(cycle(l1), l2) if len(l1) < len(l2) else zip(l1, cycle(l2))
        return list_of_tuples

    def start_multiple_burst_traffic(self, ue_ids=None, burst=None, ues_conf=None, net_arch='SA',
                                     traffic_direction='dl', qfi=1, bearer=2, **kwargs):
        """
        Start multiple traffics on desired QFIs or bearers for multiple UEs.

        :param ue_ids: (list) List of UE IDs.
        :param burst: (dict) Dictionary that contains burst configuration
        e.g. {'period_ms': 10,'burst': 3,'size': 3000}
        :param ues_conf: (list) List of configuration dictionaries for UEs.
        :param net_arch: (str) Network architecture ('SA' or 'NSA').
        :param traffic_direction: (str) Direction of the traffic ('dl', 'ul', or 'bi').
        :param qfi: (int) QFIs on which to start traffic separated by ','. Order matters in case of multi-UE
        :param bearer: (int or str) Bearers on which to start traffic separated by ','.
        Order matters in case of multi-UE
        """

        if ues_conf:
            ue_ids = [ue['ue_id'] for ue in ues_conf]
            bursts = [ue['burst'] for ue in ues_conf]
            net_arch = ues_conf[0].get('net_arch', net_arch) if 'net_arch' in ues_conf[0] else net_arch
        else:
            bursts = [burst] * len(ue_ids) if ue_ids else []

        if not ue_ids:
            raise ValueError("ue_ids must be provided either directly or through ues_conf.")
        if not bursts:
            raise ValueError("burst configuration must be provided either directly or through ues_conf.")

        drb_param = 'qfi' if net_arch == 'SA' else 'bearer'
        drb_param_values = str(qfi) if net_arch == 'SA' else str(bearer)
        drb_param_values = [val.strip(' ') for val in drb_param_values.split(',')]

        for ue_id, burst_config in zip(ue_ids, bursts):
            for drb_num in drb_param_values:
                logger_console_info(f'Start {traffic_direction.upper()} {net_arch} traffic on UE{ue_id} '
                                    f'on {drb_param} {drb_num}')
                burst_arg = {drb_param: int(drb_num), **burst_config}
                if traffic_direction in ['bi', 'dl']:
                    self.start_burst_traffic(
                        ue_id=ue_id, direction='dl', trf_id=int(drb_num), net_arch=net_arch.lower(), **burst_arg
                    )
                if traffic_direction in ['bi', 'ul']:
                    self.start_burst_traffic(
                        ue_id=ue_id, direction='ul', trf_id=int(drb_num), net_arch=net_arch.lower(), **burst_arg
                    )

    @staticmethod
    def stop_traffic(number_of_ues, **kwargs):
        """
        Stops all traffic for certain UEs.
        """

        stop_data_traffic_for_multiple_ues(
            number_of_ues=number_of_ues,
            traffic_direction='bi',
            trf_id='1-32',
            **kwargs
        )

    def deregister_ues(self, sa_ues=None, nsa_ues=None):
        """
        Deregister multiple UEs.

        :param sa_ues: (str) SA UE IDs separated by comma  e.g. '1,4,5'
        :param nsa_ues: (str) NSA UE IDs separated by comma
        """

        if sa_ues:
            for sa_ue in sa_ues.split(','):
                ta5g_ue_mobility().deregister_ue(
                    ue_id=sa_ue,
                    pass_regexp=self._ue_deregister_regexp_pattern.replace('<UE-ID>', sa_ue)
                )
        if nsa_ues:
            for nsa_ue in nsa_ues.split(','):
                ta5g_ue_mobility().detach_ue(ue_id=nsa_ue)
