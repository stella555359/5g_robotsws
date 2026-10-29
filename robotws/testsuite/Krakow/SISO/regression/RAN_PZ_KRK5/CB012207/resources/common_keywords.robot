*** Settings ***
Documentation
...   Keywords for regression testing of feature CB012207
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/bts/robot/common/gnb_log.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms    WITH NAME    alarm

*** Keywords ***
Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test on second bts
    [Arguments]    ${allowed_alarms}
    Run Keyword If  ${CUSTOM_ALLOWED_ALARMS}    Append To List  ${allowed_alarms}  @{CUSTOM_ALLOWED_ALARMS}
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms}    gnb_id=${1}
    gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm    gnb_id=${1}
    gnb_log.Start Collecting gNB Btslog    gnb_id=${1}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}    ${both_bts}=${True}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Run Keyword If    "${both_bts}"=="True"    Actions before test on second bts    allowed_alarms=@{allowed_alarms}
    common_setups_and_teardowns.Common Preconditions With Watching Alarms

Load default BTS configs
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=${None}
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=${None}

Actions after test on second bts
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_log.Collect Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Collect IM Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Collect IMS Log From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    gnb_log.Stop Collecting gNB Btslog    gnb_id=${1}    log_dir=${LOG_PATH}

Actions after test
    [Arguments]    ${both_bts}=${True}
    Remove custom allowed alarms if defined
    common_setups_and_teardowns.Common Postconditions With Watching Alarms
    Run Keyword If    '${both_bts}'=='True'    Actions after test on second bts
    [Teardown]    Run Keyword If Test Failed    Load default BTS configs
