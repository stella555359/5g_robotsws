# @Time    : 2023/5/22
# @Author  : xudong.1.li
# @Email   : xudong.1.li@nokia-sbell.com
# @File    : CB009493_keyword.robot

*** Settings ***
Documentation    This is common keywords about CB009493
Library     taf.selenium.sbts    WITH NAME    selenium_sbts
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Activate Parameter And PDL TriggerReset Verification Passed
    [Arguments]    ${reset_dist_name}    ${reset_pra}    ${reset_value}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result}    coam.perform_parameter_recommissioning    dist_name=${reset_dist_name}    parameter=${reset_pra}
    ...    operation=update    value=${reset_value}   connection=${connection}
    Should Be Equal As Strings
    ...    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    Should Be Equal As Strings    ${result['commissioningResult']['isGoingToTriggerReset']}    True
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    [Return]  ${result}

Activate Parameter On Webem And PDL Verification Passed
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...    dist_name = MRBTS-2003/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter = eCpriMasterStatisticsInterval
    ...    value = 15min
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result}    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${value}    skip_parameter_relation_errors=True    connection=${connection}
    Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    Should Be Equal As Strings
    ...    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    [Return]    ${result}

Lock Unlock ENB Cell via Coam
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${lncel_id}=1    ${enb_index}=0    ${value}=unlocked    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    connection=${connection}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-${lncel_id}
    ...    parameter=administrativeState    value=${value}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

MMW5 Detach Qualcomm Mobile
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin
    Sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    Sleep    2s
    #####Click Home_button#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cygwin
    Sleep    2s
    #####Airplane screen#####
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
    ...    connection=cygwin
    Sleep    2s
    #####Lock Airplane#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input tap 960 1400
    ...    connection=cygwin
    Sleep    2s
    csn.disconnect     connection=cygwin
