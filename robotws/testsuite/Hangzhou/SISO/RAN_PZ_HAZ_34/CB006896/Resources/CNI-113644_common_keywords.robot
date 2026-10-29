*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library     CNI-113644.py


Documentation    This is for CNI-113644 common keywords
...              Author: Renzhenzhen
...              Squard: HZ SG8

*** Keywords ***
CNI-113644_1_Fault_251_EFaultId_BackplaneSwitchUnreachableAI in single unit
    [Arguments]    ${asik_alias}=ASIK Master
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Connect to Common Unit Master  alias=${asik_alias}
    ${output}    csn.execute     pcotool -n REG_PWRSEQ_CTRL -m 0x04000000 0x04000000    connection=${asik_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    ${line_info}    check_special_line    content=${output}
    log to console    ${line_info}
    should be equal as strings    ${line_info}    bit26-bit26(0x04000000)pco_s3m_pcie_perst(R/W)0x1
    sleep    10min
    Wait For Expect Fault Present    faultId=251    timeout=300
    Check no other fault during test
    Verify all cells should be onair    cell_type=nr
    [Teardown]    Run keywords    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}   AND
    ...    Perform BTS power off and power on


Perform BTS power off and power on
    Perform Site Power Off
    sleep    2min
    Perform Site Power On
    sleep    5min
    wait until keyword succeeds    15min    180s    Verify all cells should be onair    cell_type=nr
    Wait For Expect Fault To Disappear    faultId=251    timeout=300


Check no other fault during test
    [Arguments]    ${fault_ID}=251
    log to console    check not exist unexpect active alarm and history alarm
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    ${fault_ID}    Convert To Integer    ${fault_ID}
    ${fault_dic}    Create Dictionary    faultId=${fault_ID}
    Append To List     ${ALLOWED_FAULT_TEMP}    ${fault_dic}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_FAULT_TEMP}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
