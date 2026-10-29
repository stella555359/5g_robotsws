import os

__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS@internal.nsn.com'

TestLineID = '7_5_UTE5G402T930'
prefix_of_release = '5G_'
CASE_INPUT_CB006443 = {
    'StreamPrefix': 'SBTS00_ENB_9999',
    'Stream_Version': 'SBTS22R3',
    'CB006443_IA': {
        'OriginalStream': {
              'SBTS00': 'SBTS22R3_ENB_0000',
              'SBTS22R3': 'SBTS22R2_ENB_0000',
              'SBTS22R2': 'SBTS22R1_ENB_0000',
        },
        'SecondaryUTEVMIP': '10.57.167.1921',
        'SecondaryTLName': 'xxxxx',
    },
    'CB006443_AA_01': {
        'Duration_SCFLoad': '10',
        'Duration_ValidationError': '270',
        'Duration_Validation': '140',
        'Duration_Activation': '600',
    },
    'CB006443_AA_02': {
        'Duration_DeltaValidation_succ': 25,
        'Duration_DeltaValidation_error': 60, },
    'CB006443_AA_03': {'SCF_backup_duration': 30, },
    'CB006443_AA_04': {'Duration_DeltaActivation': 600, },
    'CB006443_AA_05': {'Delta_Plan_Provision_Durtion': 110, },
    'CB006443_AA_06': {'Full_Plan_Provision_Durtion': 660, },
    'CB006443_AA_07': {'Delta_Plan_PreProvision_Durtion': 60, },
    'CB006443_AA_08': {'Import_Delta_Plan_Durtion': 20, },
    'CB006443_AA_09': {'Delta_Plan_Provision_Durtion_Reboot': 660, },
    'CB006443_AA_10': {'CMUplod_Durtion': 30, },
    'CB006443_AA_11': {'Duration_ChangeNoti': 30, },
    'CB006443_BA_01': {'PM_File_Creation_Time': 60, },
    'CB006443_BA_02': {'Duration_PM_Kept': 180, },
    'CB006443_BA_03': {'PM_MAX_Size': 698.3, },
    'CB006443_BA_04': {'CPU_Jitter': 4, },
    'CB006443_CA_01': {'alarm_report_time': 60, },
    'CB006443_CA_02': {'Alarm_Upload_Durtion': 120, },
    'CB006443_DA_01': {'snapshot_save_time': 900, },
    'CB006443_DA_02': {'FilePresentTime': 15, },
    'CB006443_DA_03': {'StartAndStopLtency': 5, },
    'CB006443_FA_01': {'MaxFileSize': 2147483648, },
    'CB006443_FA_02': {
        'MaxSession': 6,
        'webEMSessionLogoutTimer': 7200, },
    'CB006443_FA_03': {'Duration_Loading_WebEM': '5', },
    'CB006443_FA_04': {'Login_duration_time': '25', },
    'CB006443_FA_05': {'StartupView_Login_duration_time': '30', },
    'CB006443_FA_06': {'RMToolSessionCount': '5', },
    'CB006443_FA_07': {'RMToolRequestLatency': '30', },
    'CB006443_FA_08': {'RMToolConnectionLatency': '30', },
    'CB006443_FA_09': {'RMToolRequestLatencyServerMode': '5', },
    'CB006443_HA_07': {'CellLockUnLockDurtion': '40', },
    'CB006443_KPI54A': {
        'RU_INDEX': '1',
        'KPI54A_AVG': 390,
        'KPI54A_MAX': 468,
        'ru_reset_times': 50,
        'fail_loop_max': 2,
    },
    'CB006443_HA_KPI17': {
         'KPI17a': 10,
         'KPI17b': 10,
         'cell_index': 4,
         'cell_block_times': 50,
         'cell_block_times_CDRT': 30,
    },
    'CB006443_IA_01': {'SW_Download_MAX': 1920, },
    'CB006443_IA_KPI2a': {
        'KPI2a_AVG': '570',
        'KPI2a_MAX': '684',
    },
    'CB006443_IA_KPI2b': {
        'KPI2b_AVG': '810',
        'KPI2b_MAX': '972',
    },
    'CB006443_IA_KPI2c': {
        'KPI2c_AVG': '390',
        'KPI2c_MAX': '468',
    },
    'CB006443_IA_KPI2d': {
        'KPI2d_AVG': '960',
        'KPI2d_MAX': '1152',
    },
    'CB006443_IA_KPI4': {
        'KPI4_AVG': '630',
        'KPI4_MAX': '756',
    },
    'CB006443_IA_15': {'UpdateByYAFT': 'true', },
    'CB006443_HA_KPI1a': {
        'WebUI_reset_times': 50,
        'WebUI_reset_times_CDRT': 30,
        'KPI1a_AVG': 390,
        'KPI1a_MAX': 468,
    },
    'CB006443_HA_KPI3': {
        'Power_reset_times': 50,
        'Power_reset_times_CDRT': 30,
        'KPI3_AVG': '390',
        'KPI3_MAX': '468',
        'fail_loop_max': '3',
    },
    'CB006443_HA_KPI51': {
        'RF_reset_times': 50,
        'RF_reset_times_CDRT': 30,
        'KPI51_AVG': 240,
        'KPI51_MAX': 240,
    },
    'CB006443_HA_KPI5': {
        'BBMOD_reset_times': 50,
        'BBMOD_reset_times_CDRT': 30,
        'KPI5_AVG': 270,
        'KPI5_MAX': 270,
        'fail_loop_max': 2,
    },
}
