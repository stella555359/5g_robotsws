*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Keywords for CDD feature CNI-141366


Library      taf.rfrl.utilities.logger.custom_logger       WITH NAME    logger
Library      on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Library      taf.rfrl.bts.commissioning
Library      testsuite/Krakow/resources/random_oam_procedure_runner.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource     ${L3_CALL_RESOURCE}
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${cdd_file_path}        ${cdd_project_path}/${CDD_directory}
${cdd_project_path}     /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CNI-141366
${CDD_directory}        CDD_backups_v6.10.1.110
${CDD_artifactory_URL}  https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/jdziedzi/CDD_CNIs
@{cdd_configs_list}     CDD-config_B66_CNI-103193.zip    CDD-config_n41_CNI-103190.zip
...                     CDD-config_n77_CNI-115365.zip    CDD-config_n78_CNI-105082.zip
${CDD_url}              https://10.253.176.168/
@{scf_prefix_tags}      TSPY074_B66_CNI-103193    TSPY074_n41_CNI-103190
...                     TSPY074_n77_CNI-115365    TSPY074_n78_CNI-105082

${sw_config_file_path}  commissionings/Krakow/swconfig/default_swconfig.txt

${TOTAL_TIMEOUT}                 ${3600}
${EMAIL_NOTIFICATION_WHEN_FAIL}  ${False}
${OPERATIONS}                    ['site_reset', 'bts_power_on', 'reset_rmod',
...                               'rat_reset', 'cell_block_unblock', 'cell_lock_unlock']
${OPERATION_KWARGS}              {'site_reset': {'temp_allowed_alarms': [{'fault_id': '7316'}, {'fault_id': '2'}],
...                                              'collect_ru_logs': False, 'timeout': 900},
...                               'bts_power_on': {'temp_allowed_alarms': [{'fault_id': '7316'}, {'fault_id': '2'}],
...                                                'collect_ru_logs': False, 'timeout': 900},
...                               'reset_rmod': {'temp_allowed_alarms': [{'fault_id': '2'}],
...                                              'collect_ru_logs': False, 'timeout': 900},
...                               'power_reset_rmod': {'temp_allowed_alarms': [{'fault_id': '2'}],
...                                                    'collect_ru_logs': False, 'timeout': 900},
...                               'rat_reset': {'temp_allowed_alarms': [{'fault_id': '7316'}, {'fault_id': '2'}],
...                                             'collect_ru_logs': False, 'timeout': 900},
...                               'cell_block_unblock': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False},
...                               'cell_lock_unlock': {'temp_allowed_alarms': [{'fault_id': '2'}], 'collect_ru_logs': False}}
${RANDOM_SEED}                                  ${None}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${L3_CALL}                                      ${False}
${L3_CALL_RESOURCE}                             taf/rfrl/ue/robot/REAL_UE.robot
${L3_CALL_KEYWORDS}                             ${None}
${SWCONFIG_PATH}                                ${None}

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_file_path}
    Download CDD configuration files    ${cdd_file_path}    ${CDD_artifactory_URL}    ${cdd_configs_list}
    ...                                 ${cdd_project_path}    ${CDD_directory}
    Perform CDD and BTS Commissioning    file_name=${cdd_file_path}/${cdd_configs_list}[0]    cdd_url=${CDD_url}
    ...                                  prefix_tag=${scf_prefix_tags}[0]
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup
    logger.log_info_to_console    --Test Suite Setup DONE--\n
