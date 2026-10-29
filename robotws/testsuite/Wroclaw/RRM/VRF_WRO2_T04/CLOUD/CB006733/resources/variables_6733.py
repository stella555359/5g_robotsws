from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id

SSB_FREQS = ['428910', '431530', '663936', '509790', '527790']
RSRP_THRESHOLDS = [100, 101, 102, 103, 104]

CONFIG_IDS = '3,4,5,6' if str(mrbts_id) == '8681' else '3,4,5,6,7'
CONFIG_IDS_RECONFIG_1 = '5,6' if str(mrbts_id) == '8681' else '5,6,7'
CONFIG_IDS_RECONFIG_2 = '6,7,8' if str(mrbts_id) == '8681' else '5,7,8'

MEAS_IDS_NUM = 4 if str(mrbts_id) == '8681' else 5
MEAS_IDS_NUM_AFTER_RECONFIG = 2 if str(mrbts_id) == '8681' else 3
