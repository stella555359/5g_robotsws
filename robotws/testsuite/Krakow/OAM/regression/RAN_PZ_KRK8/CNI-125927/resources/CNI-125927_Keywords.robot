*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Keywords for CDD feature CNI-125927


Library      taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Library      taf.rfrl.bts.commissioning
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library      testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource     testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot
Resource     ${L3_CALL_RESOURCE}
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${cdd_file_path}        ${cdd_project_path}/${CDD_directory}
${cdd_project_path}     /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CNI-125927
${CDD_directory}        CDD_backups_v5.80.0.127
${CDD_artifactory_URL}  https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/jdziedzi/CNI-125927
@{cdd_config_name}      TL094_CDD_configBackup_n5.zip
${CDD_url}              https://10.253.176.147/

${SMAWave_address_IP}   10.253.176.144

${sw_config_file_path}      commissionings/Krakow/swconfig/default_swconfig.txt
@{CUSTOM_ALLOWED_ALARMS}    Cell blocked    Unit temperature is high    GPS receiver alarm: firmware upgrade ongoing

${TOTAL_TIMEOUT}                 ${3600}
${EMAIL_NOTIFICATION_WHEN_FAIL}  ${False}
${OPERATIONS}                    ['site_reset', 'bts_power_on', 'reset_bbmod', 'reset_rmod', 'rat_reset',
...                               'cell_block_unblock', 'cell_lock_unlock']
${OPERATION_KWARGS}          {'site_reset': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False, 'timeout': 900},
...                           'bts_power_on': {'temp_allowed_alarms': [{'fault_id': '6327'}, {'fault_id': '2'}],
...                                            'collect_ru_logs': False, 'timeout': 900},
...                           'reset_bbmod': {'temp_allowed_alarms': [{'fault_id': '6327'}, {'fault_id': '7300'}, {'fault_id': '7319'},
...                                                                   {'fault_id': '2'}], 'collect_ru_logs': False, 'timeout': 900},
...                           'reset_rmod': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False, 'timeout': 900},
...                           'rat_reset': {'temp_allowed_alarms': [{'fault_id': '7107'}, {'fault_id': '2'}],
...                                         'collect_ru_logs': False, 'timeout': 900},
...                           'cell_block_unblock': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False},
...                           'cell_lock_unlock': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False}}
${RANDOM_SEED}                   ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${L3_CALL}                       ${False}
${L3_CALL_RESOURCE}              taf/rfrl/ue/robot/REAL_UE.robot
${L3_CALL_KEYWORDS}              ${None}
${SWCONFIG_PATH}                 ${None}

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_file_path}
    Download CDD configuration files    ${cdd_file_path}    ${CDD_artifactory_URL}    ${cdd_config_name}
    ...                                 ${cdd_project_path}    ${CDD_directory}
    Perform CDD and BTS Commissioning    file_name=${cdd_file_path}/${cdd_config_name}[0]    cdd_url=${cdd_url}
    ...                                  prefix_tag=CDD_CNI-125927
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup    enable_sleeping_cell_detection=${False}
    logger.log_info_to_console    --Test Suite Setup DONE--\n

Start DLUL Data Transfer And Verify Throughput
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}
    ...            ${max_deviation_dl}    ${max_deviation_ul}    ${protocol}=udp
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    Log    \n--Starting DLUL data transfer--\n    console=${True}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}    ${protocol}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}    ${protocol}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation_dl}    ${duration}
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation_ul}    0s
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer--\n    console=${True}

Test Setup with CDD config loading
    [Arguments]    ${file_name}
    Run Keywords
    ...        Cdd Connect And Load Config    file_name=${file_name}    cdd_url=${CDD_url}    AND
    ...        keywords.Test Setup
