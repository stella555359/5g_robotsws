*** Settings ***
Documentation
...  author:  Sara Nowak
...  contact: sara.nowak@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     resources/SFP_keywords.robot
Resource     resources/suite_specific_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/allowed_alarms.py

Suite Setup       Run Keyword If    '${skip_commissioning}' != 'true'    Run Keywords
...                                  Upload Swconfig On Classical Gnb    bts_id=0
...                                  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt   AND
...                                  Perform Full Commissioning On Classical Gnb    AND
...                                  Wait Until Keyword Succeeds    15min    10s    Verify Setup Of All Cells    gnb_id=0    du_id=0

Test Setup        Common Preconditions     collect_syslog=${False}    verify_mandatory_scf_params=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}

*** Variables ***
&{AWKUC_KPI_51a_b_target}       kpi51a=${250}    kpi51b=${250}
&{KPI_1a_1b_1c_target}          kpi1a=${360}     kpi1b=${600}    kpi1c=${600}
${skip_commissioning}           ${NONE}
@{RU_CONFIG_AWKUC}              ${0}    ${1}
@{RU_CONFIGS_AC}                ${RU_CONFIG_AWKUC}

@{ADDITIONAL_ALARMS_FOR_TESTS}     BTS configuration error (not enough HW for LCR)    No connection to unit    Diagnostic Files collected

*** Test Cases ***
CB012667-SR-AC_01_RU_Reset_KPI_51a_with_and_without_CB012667_AWKUC
    Calculate RU Reset KPI With and Without CB012667    ru_id=0    ru_bts_id=1    kpi_target=&{AWKUC_KPI_51a_b_target}
    ...                                                 ru_name=AWKUC    iterations=20


CB012667-SR-AC_02_Site_Reset_KPI_1a_with_and_without_CB012667_AWKUC
    Calculate Site Reset KPI With and Without CB012667    ru_configs=${RU_CONFIGS_AC}    iterations=20    kpi_target=&{KPI_1a_1b_1c_target}


CB012667-SR-AC_08_General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}
    SFP Lock And Unlock
    [Teardown]    Run keywords
    ...    Actions after test
    ...    AND    Common Postconditions    collect_syslog=${False}
