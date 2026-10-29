from robot.api import logger
from ta_egate_cmd_parser import ta_egate_cmd_parser
import platform
import sys
import time
from robot.libraries.BuiltIn import BuiltIn


class LTE5190_A_common_CUS(object):

    def __init__(self):
        super(LTE5190_A_common_CUS, self).__init__()
        self.ta_uexgate = BuiltIn().get_library_instance('ta_uexgate')

    def egate_parser_for_enb_disp(self):
        time.sleep(5)
        enbdisp = ta_egate_cmd_parser().get_command(command_name='enb_disp')
        enb_disp_output = enbdisp.without_id().execute_and_parse()
        return enb_disp_output

    def get_number_of_ues_in_sgnb(self, cmd, sgnb):
        return int((cmd[str(sgnb)])["Active UEs"])

    def verify_num_of_ue_per_gNB(self, gnb_id, num_of_expected_ues):
        time.sleep(2)
        enbdisp = self.egate_parser_for_enb_disp()
        num_of_configured_ues = self.get_number_of_ues_in_sgnb(cmd=enbdisp, sgnb=gnb_id)

        assert int(num_of_configured_ues) == int(num_of_expected_ues), \
            'wrong number of UEs for sgnb {}: expected {} configured {}'.format(gnb_id, num_of_expected_ues,
                                                                                num_of_configured_ues)

    def get_number_of_UE_in_ACTIVE_state_from_eNB(self):
        return len(self.ta_uexgate.run_uex_command('get_ue_summary')['active'])

    def configure_param_for_second_group_of_30UEs_to_delay_respose_for_RRC_during_SCG_split_addition(
            self, first_ue_id, last_ue_id):
        for ue in range(int(first_ue_id), int(last_ue_id)):
            self.ta_uexgate.ue_rrc_reconf_param(if_contains='', delay=6000, action='none', id=ue)
            time.sleep(0.2)
