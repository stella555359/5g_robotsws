from robot.libraries.BuiltIn import BuiltIn
from ta5g_tshark import ta5g_tshark
from ta5g_interface_tools import ta5g_interface_tools
from ta5g_egate import ta5g_egate
import feature_variables
from ute_fsmaccess import ute_fsmaccess
from contextlib import contextmanager
import re


class Keywords5GC001167(object):
    def __init__(self):
        self._ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
        self.tshark_instance = ta5g_tshark()
        self.egate_configurator_instance = EgateConfigurator()

    def perform_a3_inter_cell_handover_with_confirmation(self, ue_id, dst_phycell_id, scell_to_release, a3_meas_id=2,
                                                         a2_meas_id=1,
                                                         a2_rsrp=30, a3_rsrp=100):
        if scell_to_release > 0:
            packet_to_confirmation = self._scell_release_packet(scell_to_release=scell_to_release)
            self.tshark_instance.perform_action_and_wait_for_given_tshark_message_number(
                alias='default_tcpdump_alias',
                packet_filter=packet_to_confirmation,
                action='A3 Inter Cell Handover',
                packet_number=1,
                waiting_timeout=30,
                value='false',
                ue_id=ue_id,
                phycell_id=dst_phycell_id,
                a3_meas_id=a3_meas_id,
                a2_meas_id=a2_meas_id,
                a2_rsrp=a2_rsrp,
                a3_rsrp=a3_rsrp
            )
        else:
            self.a3_inter_cell_handover(ue_id=ue_id, phycell_id=dst_phycell_id, a2_meas_id=a2_meas_id,
                                        a3_meas_id=a3_meas_id, a2_rsrp=a2_rsrp, a3_rsrp=a3_rsrp)

    def a3_inter_cell_handover(self, ue_id, phycell_id, a2_meas_id, a3_meas_id, a2_rsrp, a3_rsrp):
        self._ute_wtssim_instance.execute_egate_command_and_wait_for_data(
            cmd='ue_measurement_send_nr id={ue_id} meas_id={a2_meas_id} ' /
                'srsrp_nr={a2_rsrp} event=A2'.format(ue_id,
                                                     a2_meas_id,
                                                     a2_rsrp),
            pass_regexp='message c1 : rrcReconfigurationComplete :'
        )
        self._ute_wtssim_instance.execute_egate_command_and_wait_for_data(
            cmd='ue_measurement_send_nr id={ue_id} meas_id={a3_meas_id} ' /
                'srsrp_nr={a3_rsrp} event=A3 phycell_id={phycell_id}}'.format(ue_id,
                                                                              a3_meas_id,
                                                                              a3_rsrp,
                                                                              phycell_id),
            pass_regexp='UE{}: Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed'.format(ue_id)
        )

    def _scell_release_packet(self, scell_to_release):
        if scell_to_release <= 0:
            return None
        else:
            f1_scells_to_be_removed = "f1ap.SCell_ToBeRemoved_List == {}".format(scell_to_release)
            f1_scells_to_release = "nr-rrc.sCellToReleaseList == {}".format(scell_to_release)
            return ' && '.join(
                [f1_scells_to_be_removed,
                 f1_scells_to_release])

    @contextmanager
    def gnb_fsm_access_manager(self, alias, teardown_session=True):
        fsm_access_instance = ute_fsmaccess()
        try:
            fsm_access_instance.setup_enb_fsm_access(alias=alias)
            yield fsm_access_instance
        finally:
            if teardown_session:
                fsm_access_instance.teardown_enb_fsm_access(alias=alias)
            else:
                pass

    def configure_wts_without_onair_check(self, lua_cfg, logs_dirpath=None, timeout=1200):
        self.egate_configurator_instance.reach_onair_without_sib_check(lua_cfg, logs_dirpath)


class EgateConfigurator(ta5g_egate):

    def reach_onair_without_sib_check(self, lua_cfg, logs_dirpath=None):
        """
        Start egate service using .lua config file
        :param lua_cfg: File path of .lua config file
        :return:
        """
        if not logs_dirpath:
            logs_dirpath = ta5g_interface_tools().get_robot_output_dir()
        self.start_wts_and_store_config_file_in_logs_dir(lua_cfg=lua_cfg, logs_dirpath=logs_dirpath)
        self._ute_wtssim_instance.execute_egate_command(cmd='start version_check=off', timeout=10)
