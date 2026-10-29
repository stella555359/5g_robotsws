from taf.rfrl.utilities.robot.general import get_builtin_value

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import Misc

MY_UE_ALIAS_UE1 = 'QC_MTP_SDX75'
MY_UE_ALIAS_UE1_AT = f'{MY_UE_ALIAS_UE1}_AT'
MY_UE_ALIAS_UE2 = 'MTK_M80_Dujac'
UE_CAPS = {MY_UE_ALIAS_UE1: 'REAL_UE',
           MY_UE_ALIAS_UE2: 'MTK_UE'}
RUN_COMMON_STEPS = not Misc.to_bool(get_builtin_value("skip_common_steps"), False)
REBOOT_UE = Misc.to_bool(get_builtin_value("REBOOT_UE"), False)
NUM_BTS_DEVICES = 2
COLLECT_RU_CONSOLE_LOG = Misc.to_bool(get_builtin_value("COLLECT_RU_CONSOLE_LOG"), False)

T09SK030_RU_DATA = {'AZQO': {'start_attenuation': '0dB',
                             'nrCellId': 11,
                             'nrCellIdentity': '1311211531'},
                    'AEQP': {'start_attenuation': '10dB',
                             'nrCellId': 20,
                             'nrCellIdentity': '1311211540'},
                    'APHG': {'start_attenuation': '0dB',
                             'nrCellId': 21,
                             'nrCellIdentity': '1311211541'},
                    'AHPE': {'start_attenuation': '10dB',
                             'nrCellId': 30,
                             'nrCellIdentity': '1311211550'},
                    'AHEH': {'start_attenuation': '10dB',
                             'nrCellId': 40,
                             'nrCellIdentity': '1311211560'}}
