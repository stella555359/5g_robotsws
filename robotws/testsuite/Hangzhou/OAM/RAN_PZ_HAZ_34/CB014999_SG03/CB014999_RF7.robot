*** Settings ***
Documentation
...    author: yuanyuan liu
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW3
...    feature : CB012119

Force Tags    CRT_TRUNK

Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    ./Resources/CB014999_common_keywords.robot
#Resource      ../../step_keywords/5G/basic/coam_check_status.robot




*** Variables ***
${TEST_LOG_DIRECTORY}    ${OUTPUTDIR}
@{carrier_center_freq_list}    2546010000   2640720000
@{carrier_bandwidth_list}   100000000   90000000
${carrier_num}    2
${antenna_count}   64
${ru_index}    7
${gNb_CuType}    SA

*** Test Cases ***
[1]CB014999-SR-D_RU_Black_Box_enhancements_RTWP_on_RF7.1_after_Radio_Reset_and_Power_Reset
    [Tags]    HAZ3_T03
    # CB014999 SA case Preparation
    Get Snapshot and find the needed BBOX5 file   ru_index=${ru_index}
    Get the rtwp lifetime for xCC before RU Reset
    Reset Rmod via admin cli   ru_index=${ru_index}
    Get Snapshot and find the needed BBOX5 file   ru_index=${ru_index}
    Get the rtwp lifetime for xCC after RU Reset
    Compare the increased rtwp counts   rtwp_list_after=${rtwp_list_2}   rtwp_list_before=${rtwp_list_1}
    # sleep   900s
    # Rmod Power off and power on directly
    # Get Snapshot and find the needed BBOX5 file   ru_index=${ru_index}
    # Get the rtwp lifetime for xCC after RU Power off and power on
    # Compare the increased rtwp counts be zero   rtwp_list_after=${rtwp_list_3}   rtwp_list_before=${rtwp_list_2}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown

*** Keywords ***
Get the rtwp lifetime for xCC before RU Reset
    ${rtwp_list_1}    Create List
    ${rtwp_list_1}=    Get the rtwp lifetime counter for selected RMOD
    set suite variable   ${rtwp_list_1}

Get the rtwp lifetime for xCC after RU Reset
    ${rtwp_list_2}    Create List
    ${rtwp_list_2}=    Get the rtwp lifetime counter for selected RMOD
    set suite variable   ${rtwp_list_2}

Get the rtwp lifetime for xCC after RU Power off and power on
    ${rtwp_list_3}    Create List
    ${rtwp_list_3}=    Get the rtwp lifetime counter for selected RMOD
    set suite variable   ${rtwp_list_3}

Compare the increased rtwp counts
    [Arguments]   ${rtwp_list_before}  ${rtwp_list_after}
    FOR    ${index}    IN RANGE    0   ${carrier_num}
       ${increased_counts_calculated}   evaluate    ${rtwp_list_after}[${index}]-${rtwp_list_before}[${index}]
    #   should be true   ${increased_counts_calculated}==${increased_counts}
        should be true   ${increased_counts_calculated}==1 or ${increased_counts_calculated}==2
    END
Rmod Power off for 15min and then power on
    [Arguments]  ${ru_index}=1
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}

    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Expect FID10 Present    configObjectName=RMOD-${ru_index}
    END
    log to console    \n***Power On RU after 15 MIN And Check***
    sleep   900s
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Expect FID10 Absent
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
Compare the increased rtwp counts be zero
    [Arguments]   ${rtwp_list_before}  ${rtwp_list_after}
    #${rtwp_list_before}    Create List
    #${rtwp_list_after}    Create List
    FOR    ${index}    IN RANGE    0   ${carrier_num}
       ${increased_counts_calculated}   evaluate    ${rtwp_list_after}[${index}]-${rtwp_list_before}[${index}]
        should be true   ${increased_counts_calculated}==0
    END
Rmod Power off and power on directly
    [Arguments]  ${ru_index}=1
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}

    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Expect FID10 Present    configObjectName=RMOD-${ru_index}
    END
    log to console    \n***Power On RU Directly And Check***

    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Expect FID10 Absent
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
