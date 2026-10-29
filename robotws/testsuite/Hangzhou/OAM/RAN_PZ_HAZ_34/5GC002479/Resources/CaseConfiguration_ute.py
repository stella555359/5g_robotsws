import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

CNF_5G_4 = {
    'KPI1a': {'KPI1a_AVG': '400', 'KPI1a_MAX': '468'},
    'KPI3': {'KPI3_AVG': '400', 'KPI3_MAX': '468'},
    'KPI5': '480',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '20',
    'KPI17b': '20',
    'KPI10': '750',
    'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '570', 'KPI2a_MAX': '684'},
    'KPI2b': {'KPI2b_AVG': '810', 'KPI2b_MAX': '972'},
    'KPI2c': {'KPI2c_AVG': '390', 'KPI2c_MAX': '468'},
    'KPI2d': {'KPI2d_AVG': '630', 'KPI2d_MAX': '756'},
    'KPI4': {'KPI4_AVG': '2610', 'KPI4_MAX': '3132'},
    'Customer': 'True',
}

CNF_5G_6 = {
    'KPI1a': {'KPI1a_AVG': '300', 'KPI1a_MAX': '360'},
    'KPI3': {'KPI3_AVG': '300', 'KPI3_MAX': '360'},
    'KPI5': '270',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI10': '860',
    'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '480', 'KPI2a_MAX': '576'},
    'KPI2b': {'KPI2b_AVG': '720', 'KPI2b_MAX': '864'},
    'KPI2c': {'KPI2c_AVG': '300', 'KPI2c_MAX': '360'},
    'KPI2d': {'KPI2d_AVG': '540', 'KPI2d_MAX': '648'},
    'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'Customer': 'False',
}

CNF_5G_9 = {
    'KPI1a': {'KPI1a_AVG': '420', 'KPI1a_MAX': '504'},
    'KPI3': {'KPI3_AVG': '420', 'KPI3_MAX': '504'},
    'KPI5': '270',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI10': '1050',
    'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '600', 'KPI2a_MAX': '720'},
    'KPI2b': {'KPI2b_AVG': '840', 'KPI2b_MAX': '1008'},
    'KPI2c': {'KPI2c_AVG': '420', 'KPI2c_MAX': '504'},
    'KPI2d': {'KPI2d_AVG': '660', 'KPI2d_MAX': '792'},
    'KPI4': {'KPI4_AVG': '2640', 'KPI4_MAX': '3168'},
    'Customer': 'False',
}

CNF_5G_10 = {
    'KPI1a': {'KPI1a_AVG': '420', 'KPI1a_MAX': '504'},
    'KPI3': {'KPI3_AVG': '420', 'KPI3_MAX': '504'},
    'KPI5': '270',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI10': '810',
    'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '600', 'KPI2a_MAX': '720'},
    'KPI2b': {'KPI2b_AVG': '840', 'KPI2b_MAX': '1008'},
    'KPI2c': {'KPI2c_AVG': '420', 'KPI2c_MAX': '504'},
    'KPI2d': {'KPI2d_AVG': '660', 'KPI2d_MAX': '792'},
    'KPI4': {'KPI4_AVG': '2640', 'KPI4_MAX': '3168'},
    'Customer': 'False',
}

CNF_5G_15 = {
    'KPI1a': {'KPI1a_AVG': '300', 'KPI1a_MAX': '360'},
    'KPI3': {'KPI3_AVG': '300', 'KPI3_MAX': '360'},
    'KPI5': '270',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI10': '450',
    'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '480', 'KPI2a_MAX': '576'},
    'KPI2b': {'KPI2b_AVG': '720', 'KPI2b_MAX': '864'},
    'KPI2c': {'KPI2c_AVG': '300', 'KPI2c_MAX': '360'},
    'KPI2d': {'KPI2d_AVG': '540', 'KPI2d_MAX': '648'},
    'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'Customer': 'False',
}


Configurations = {
    '1ASIK_3ABIL_TDD': CNF_5G_4,
    '1ASIB_3ABIL_TDD': CNF_5G_6,
    '2ASIK_6ABIL_TDD': CNF_5G_9,
    '2ASIB_2ABIO_4ABIL': CNF_5G_10,
    '1ASOE_TDD': CNF_5G_15,
}

RUs = {
    'AEQN': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '0'},
    'AEQV': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AEQY': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AEHC': {'AdjValues': '240', 'AdjValueResetBBMOD': '480', 'AdjValueCellBlockUnblock': '40',
             'AdjValueCellLockUnlock': '10'},
    'AZQO': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AZQU': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AZQL': {'AdjValues': '60', 'AdjValueResetBBMOD': '60', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AEQP': {'AdjValues': '240', 'AdjValueResetBBMOD': '240', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AZQG': {'AdjValues': '60', 'AdjValueResetBBMOD': '60', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
    'AZQH': {'AdjValues': '60', 'AdjValueResetBBMOD': '60', 'AdjValueCellBlockUnblock': '10',
             'AdjValueCellLockUnlock': '10'},
}

SFPCooledTransceiver = {
    'true': {'AdjValues': '90', 'AdjValueResetBBMOD': '90'},
}

gNBCuType = {
    'NSA': {'AdjValues': '90'},
    'SA+NSA': {'AdjValues': '90'},
}

AA_01 = {
    'Duration_SCFLoad': '20',
    'Duration_ValidationError': '270',
    'Duration_Validation': '140',
    'Duration_Activation': '600',
}
AA_02 = {
    'Duration_DeltaValidation_succ': '45',
    'Duration_DeltaValidation_error': '75',
    'Duration_Delta_Activation': '45',  # update a parameter in all cells
}
AA_03 = {'SCF_backup_duration': '30'}
AA_04 = {'Duration_DeltaActivation': '600'}
AA_05 = {'Delta_Plan_Provision_Durtion': '110'}
AA_06 = {'Full_Plan_Provision_Durtion': '660'}
AA_07 = {
    'Delta_Plan_PreProvision_Durtion': '60',
    'Delta_Plan_validation_err_Durtion': '70',
    'Delta_Plan_validation_suc_Durtion': '40',
    'Delta_Plan_download_Duration': '20',
}
AA_08 = {'Import_Delta_Plan_Durtion': '20'}
AA_09 = {'Delta_Plan_Provision_Durtion_Reboot': '660'}
AA_10 = {'CMUplod_Durtion': '30'}
AA_11 = {'Duration_ChangeNoti': '27'}
BA_01 = {'PM_File_Creation_Time': '60'}
BA_02 = {'Duration_PM_Kept': '180'}
BA_03 = {'PM_MAX_Size': '272.7'}
BA_04 = {'CPU_Jitter': '4 '}
CA_01 = {'alarm_report_time': '60'}
CA_02 = {'Alarm_Upload_Durtion': '120'}
DA_01 = {'snapshot_save_time': '420'}  # 7min=420 for avgerage size,16min=960 for big size
DA_02 = {'FilePresentTime': '420'}  # 7min for avgerage size,16min for big size
DA_03 = {'StartAndStopLtency': '5'}
FA_01 = {'MaxFileSize': '2147483648'}
FA_02 = {'MaxSession': '10'}
FA_03 = {'Duration_Loading_WebEM': '5'}
FA_04 = {'Login_duration_time': '25'}
FA_05 = {'StartupView_Login_duration_time': '30'}
FA_06 = {'RMToolSessionCount': '5'}
FA_07 = {'RMToolRequestLatency': '30'}
FA_08 = {'RMToolConnectionLatency': '32'}
FA_09 = {'RMToolRequestLatencyServerMode': '5'}
SWM_15 = {'DurationOfSwrollback': '540'}
SWM_16 = {'DurationOfSwConfigUpload': '15'}
SWM_12 = {'DurationOfSwPrecheck': '45'}
SWM_13 = {'DurationOfSwPostcheck': '30'}
SWM_17 = {'DurationOfSwCancel': '180'}
SWM_18 = {'DurationOfSwCopyManual': '360'}

CASE_RESULT_FLIE_PATH = '/home/ute/'

REQUIREMENT_ID = {
    '[1]CB008457_SR_A_01_CM_Delta_Plan_Download_Activation_Operations_No_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2776',
    '[1]CB008457_SR_A_02_CM_Duration_Of_Full_Plan_Download_Validation_Activation': ['OM_GEN_SFS_PERF_CAP.6758',
                                                                                    'OM_GEN_SFS_PERF_CAP.5326',
                                                                                    'OM_GEN_SFS_PERF_CAP.5325',
                                                                                    'OM_GEN_SFS_PERF_CAP.5327'],
    '[1]CB008457_SR_A_03_CM_Delta_Plan_Activation_Operations_Site_Level_Service_Outage': 'OM_GEN_SFS_PERF_CAP.6724',
    '[1]CB008457_SR_A_04_CM_Configuration_File_Backup': 'OM_GEN_SFS_PERF_CAP.6819',
    '[1]CB008457_SR_A_05_CM_Delta_Plan_Validation': ['OM_GEN_SFS_PERF_CAP.2768',
                                                     'OM_GEN_SFS_PERF_CAP.2772',
                                                     'OM_GEN_SFS_PERF_CAP.2774'],
    '[1]CB008457_SR_A_06_CM_Delta_Plan_Pre-Activate_Successful': 'OM_GEN_SFS_PERF_CAP.2770',
    '[1]CB008457_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2780',
    '[1]CB008457_SR_A_08_CM_Delta_Plan_Provision_Operation_Site_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2786',
    '[1]CB008457_SR_A_09_CM_Full_Config_Plan_Provision': 'OM_GEN_SFS_PERF_CAP.2787',
    '[1]CB008457_SR_A_10_CM_Upload_CM_Configuration': 'OM_GEN_SFS_PERF_CAP.2790',
    '[1]CB008457_SR_A_11_CM_Duration_of_CM_Change_Notification': 'OM_GEN_SFS_PERF_CAP.2792',

    '[1]CB008457_SR_A_28_Troubleshooting_duration_of_snapshot_collection_manually_trggered': 'OM_GEN_SFS_PERF_CAP.2836',
    '[1]CB008457_SR_A_29_Troubleshooting_duration_of_snapshot_collection_automatically_trggered': [
        'OM_GEN_SFS_PERF_CAP.8574'],
    '[1]CB008457_SR_A_31_Troubleshooting_Maximum_number_of_simultaneous_DCC_user_sessions_in_the_BTS': [
        'OM_GEN_SFS_PERF_CAP.4890'],
    '[1]CB008457_SR_A_32_Troubleshooting_Remote_Syslog_Session_Start_and_Stop_Latency': 'OM_GEN_SFS_PERF_CAP.6847',
    '[1]CB008457_SR_A_33_Troubleshooting_IP_connectivity_test': 'OM_GEN_SFS_PERF_CAP.6964',
    '[1]CB008457_SR_A_34_Troubleshooting_System_Module_Sanity_Checker': 'OM_GEN_SFS_PERF_CAP.10677',

    '[1]CB008457_SR_A_12_SWM_Duration_of_Fully_PreCheck': 'OM_GEN_SFS_PERF_CAP.4674',
    '[1]CB008457_SR_A_13_SWM_Duration_of_PostCheck': 'OM_GEN_SFS_PERF_CAP.12955',
    '[1]CB008457_SR_A_15_SWM_Duration_of_SW_Rollback': 'OM_GEN_SFS_PERF_CAP.2813',
    '[1]CB008457_SR_A_16_SWM_Duration_of_Upload_SW_Configuration': 'OM_GEN_SFS_PERF_CAP.2816',
    '[1]CB008457_SR_A_17_SWM_Duration_of_ Cancel_SW_Management': 'OM_GEN_SFS_PERF_CAP.2864',
    '[1]CB008457_SR_A_18_SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered': [
        'OM_GEN_SFS_PERF_CAP.18654'],

    '[1]CB008457_SR_A_41_Radio_Network_Integration_Duration_of_Configuration_Reset': 'OM_GEN_SFS_PERF_CAP.13130',

    '[1]5GC002479_AJ_03_CM_Configuration_File_Backup_Dual_Core': 'OM_GEN_SFS_PERF_CAP.6819',
    '[1]5GC002479_DJ_01_LOG_Manual_Trigger_Snapshot_Dual_Core': 'NA',
    '[1]5GC002479_DA_01_LOG_Manual_Trigger_Snapshot': 'NA',
    '[1]5GC002479_AA_04_CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage': 'NA',
    '[1]5GC002479_AA_03_CM_Configuration_File_Backup': 'NA',
    '[1]5GC002479_AA_01_CM_Full_Plan_Download_Validation_Activation_Operations': ['NA', 'NA', 'NA', 'NA'],
    '[1]5GC002479_AA_02_CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage': 'NA',

}
