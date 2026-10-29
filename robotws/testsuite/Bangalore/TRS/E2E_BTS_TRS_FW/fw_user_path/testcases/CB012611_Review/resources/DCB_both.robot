*** Settings ***
Documentation
    ...     [Procedure]             "CB012611 Support for degraded Capacity board Test cases"
    ...     [Date]                  "01-10-24"

Library         SSHLibrary
Library         taf.selenium.sbts
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json
${profile}                  /home/ute/SBTS00

*** Keywords ***
Login Secondary Core and Execute POWER failure from FCT and verify status For LOKI A
        SSHLibrary.Open Connection  ${host}
        SSHLibrary.Login            ${username}  ${password}
        Setup Remote Access     remote_device=bts2    alias=default
        Execute Interactive Remote Command      command=${dut_login}      alias=default
        Execute Interactive Remote Command      command=${Soc_A}       alias=default
        Teardown Remote Access  alias=default
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Verify Loki_A's & Loki_B's NRcell status
        Verify Other Baseband Loki NRcell status
        ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
        ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
        ${pre_alarm_faultids}=  Create List
        ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
        site block and unblock
        Verify Loki_A's & Loki_B's NRcell status
        Verify Other Baseband Loki NRcell status
        ${post_reset_alarms}=   Verify Alarm    alarm_type=active
        ${post_reset_length}=   Get Length  ${post_reset_alarms}
        ${post_alarm_faultids}=  Create List
        ${post_alarm_faultids}=  Create fault id List    ${post_reset_alarms}
        ${alarms_post_reset}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20


Login Secondary Core and Execute POWER failure from FCT and verify status For LOKI B
        SSHLibrary.Open Connection  ${host}
        SSHLibrary.Login            ${username}  ${password}
        Setup Remote Access     remote_device=bts2    alias=default
        Execute Interactive Remote Command      command=${dut_login}      alias=default
        Execute Interactive Remote Command      command=${Soc_B}       alias=default
        Teardown Remote Access  alias=default
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Verify Loki_B's & Loki_A's NRcell status
        Verify Other Baseband Loki NRcell status
        ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
        ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
        ${pre_alarm_faultids}=  Create List
        ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
        Perform Software Download And Update        package=${profile}    activate_sw=True    update_timeout=1800
        ...      wait_for_bts_to_be_ready=600       alias=default
        BuiltIn.Sleep    300
        ${post_reset_alarms}=   Verify Alarm    alarm_type=active
        ${post_reset_length}=   Get Length  ${post_reset_alarms}
        ${post_alarm_faultids}=  Create List
        ${post_alarm_faultids}=  Create fault id List    ${post_reset_alarms}
        ${alarms_post_reset}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
        Verify Loki_B's & Loki_A's NRcell status
        Verify Other Baseband Loki NRcell status
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20

Login Secondary Core and Execute POWER failure from FCT and verify status For LOKI A&B
        SSHLibrary.Open Connection  ${host}
        SSHLibrary.Login            ${username}  ${password}
        Setup Remote Access     remote_device=bts2    alias=default
        Execute Interactive Remote Command      command=${dut_login}      alias=default
        Execute Interactive Remote Command      command=${Soc_A}       alias=default
        Execute Interactive Remote Command      command=${Soc_B}       alias=default
        Teardown Remote Access  alias=default
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Verify Alarm      faultid=252      occurrences=1       should_exist=${True}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20
        Verify Loki_A&B_NRcell status
        Verify Other Baseband Loki NRcell status
        ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
        ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
        ${pre_alarm_faultids}=  Create List
        ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
        Reset Bts     should_be_onair=${False}
        BuiltIn.Sleep    300
        Verify Loki_A&B_NRcell status
        Verify Other Baseband Loki NRcell status
        ${post_reset_alarms}=   Verify Alarm    alarm_type=active
        ${post_reset_length}=   Get Length  ${post_reset_alarms}
        ${post_alarm_faultids}=  Create List
        ${post_alarm_faultids}=  Create fault id List    ${post_reset_alarms}
        ${alarms_post_reset}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20

Verify Loki_A+B_NRcell status
        ${operationalState}=      Get Cells Statuses     param_path=${NRCELL}
        Should Be Equal     ${operationalState}     enabled
        ${operationalState}=      Get Cells Statuses     param_path=${Soc_B_NRCELL}
        Should Be Equal     ${operationalState}     enabled

Verify Loki_A's & Loki_B's NRcell status
        ${operationalState}=      Get Cells Statuses     param_path=${NRCELL}
        Should Be Equal     ${operationalState}     disabled
        ${operationalState}=      Get Cells Statuses     param_path=${Soc_B_NRCELL}
        Should Be Equal     ${operationalState}     enabled

Verify Loki_B's & Loki_A's NRcell status
        ${operationalState}=      Get Cells Statuses     param_path=${Soc_B_NRCELL}
        Should Be Equal     ${operationalState}     disabled
        ${operationalState}=      Get Cells Statuses     param_path=${NRCELL}
        Should Be Equal     ${operationalState}     enabled

Verify Loki_A&B_NRcell status
        ${operationalState}=      Get Cells Statuses     param_path=${NRCELL}
        Should Be Equal     ${operationalState}     disabled
        ${operationalState}=      Get Cells Statuses     param_path=${Soc_B_NRCELL}
        Should Be Equal     ${operationalState}     disabled

site block and unblock
        Block       operation=site     timeout=60
        Unblock     operation=site      timeout=300
        BuiltIn.Sleep    300

Login Secondary Core and Execute POWER failure restore from FCT
        Setup Remote Access     remote_device=bts2    alias=default
        Execute Interactive Remote Command      command=${dut_login}      alias=default
        Execute Interactive Remote Command      command=${Soc_restore}       alias=default
        Teardown Remote Access  alias=default
        BuiltIn.Sleep    20

Verify Other Baseband Loki NRcell status
        ${operationalState}=      Get Cells Statuses     param_path=${NRCELL_184}
        Should Be Equal     ${operationalState}     enabled

Verify pre-alarm list
        Verify Alarm      faultid=252      occurrences=1       should_exist=${True}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm    expected_alarms=${expected_alarms}      alarm_type=active
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20

Verify post-alarm list
        Verify Alarm      faultid=252      occurrences=1       should_exist=${True}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm    expected_alarms=${expected_alarms}      alarm_type=active
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
        BuiltIn.Sleep    20

verify LOKI status
        Verify Loki_A+B_NRcell status
        Verify Bts Status   should_be_onair=${True}      req_rat=5g
        Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
        BuiltIn.Sleep    20

verify LOKIB status
        Verify Loki_A+B_NRcell status
        Verify Bts Status   should_be_onair=${True}      req_rat=5g
        Verify Alarm    expected_alarms=${expected_alarms}     alarm_type=active
        BuiltIn.Sleep    20
        Verify Alarm      faultid=23      occurrences=1       should_exist=${True}      alarm_type=active
        BuiltIn.Sleep    20

verify precondition
        Verify Bts Status   should_be_onair=${True}      req_rat=5g
        Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
        Verify Alarm    unexpected_alarms=${unexpected_alarms}     alarm_type=active
        Verify Alarm    unexpected_alarms=${unexpected_alarms}     alarm_type=history

Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list1}    ${list[${i}]['faultId']}
    END
    [Return]    ${list1}

Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}
    ${list}=    Create List
    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END
    [Return]    ${list}
