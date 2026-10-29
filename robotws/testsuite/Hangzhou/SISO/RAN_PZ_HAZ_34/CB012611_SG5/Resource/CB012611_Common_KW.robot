*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Keywords ***
ABIO reset with single failed Loki
    [Arguments]    ${bbmod_index}=${1}
    [Documentation]   This User scenario objective is to describe BTS Behavior on ABIO reset with one Loki permanently
    ...  failed. Cells shared between Lokis are configured on BTS
    log to console    \ntrigger failure on BBMOD-${bbmod_index} as default
    Step 1 Execute command to destory 1 loki
    Step 2 Reset ABIO from WebEM
    Step 3 Restore the failed loki by command
    Step 4 Site Reset

Check ABIO is degraded
    [Arguments]   ${baseband_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    ${abio_info}      selenium_coam.get_abil_info   abil_index=${baseband_index}
    Should Be Equal As Strings   ${abio_info}[Status][Availability status]   degraded
#    ${hw_info}     selenium_coam.get_bts_start_up_view_info   cell='NR cells'
#    ${unit_info}     selenium_coam.get_units_to_be_reset
#    FOR    ${element}    IN    @{unit_info}
#        Run Keyword If    "BBMOD-${baseband_index}" in "${element}"    Set Test Variable    ${bbmod_1}    ${element}
#    END
#    @{bbmod_1}    string.split string    ${bbmod_1}    separator=(
#    ${bbmod_1}    Strip String    ${bbmod_1[0]}    right
#    ${abio_info}   selenium_coam.get_hw_info   hw_name=${bbmod_1}
#    ${ru_info}     selenium_coam.get_ru_info   ru_index=1
#    ${cell_info}   selenium_coam.get_cell_info     cell_idx=1


    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Step 1 Execute command to destory 1 loki
    log to console  \n Step 1 Execute command to destory 1 loki
    Connect to Common Unit Master
    ${output}   csn.execute    command=lxc-ls   connection=ASIK Master   timeout=30
    ${slot_id}    Get Slot ID from Container ID   hex_string=${output}

    #0x10- for lokiA, 0x11- for lokiB
    # csn.execute    command=bmutool -S ${slot_id} -r 0x10 0xA0    connection=ASIK Master   timeout=30
    csn.execute    command=bmutool -S ${slot_id} -r 0x11 0xA0    connection=ASIK Master   timeout=30
    sleep    60s
    #Check Alarm 252 is critical
    Wait Until Keyword Succeeds    8min    30s    Expect Fault Should Present In Active or History Alarms    faultId=${252}
    Check ABIO is degraded
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Step 2 Reset ABIO from WebEM
    [Arguments]   ${baseband_index}=${1}
    log to console  \n Step 2 Reset ABIO from WebEM
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable    ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.reset_baseband    baseband_index=${baseband_index}
    sleep    180s
    #Check Alarm 1868 is raised
#    Wait Until Keyword Succeeds    8min    30s    Expect Fault Should Present In Active or History Alarms    faultId=${1868}
#    #Check Alarm 252 is minor
#    Wait Until Keyword Succeeds    8min    30s    Expect Fault Should Present In Active or History Alarms    faultId=${252}  severity=Minor
    Check ABIO is degraded
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Step 3 Restore the failed loki by command
    [Arguments]
    log to console  \n Step 3 Restore the failed loki by command
    Connect to Common Unit Master
    csn.execute    command=bmutool -S ${slot_id} -r 0x1F 1    connection=ASIK Master   timeout=30
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Step 4 Site Reset
    [Arguments]
    log to console   \n Step 4 Site Reset
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version[0]}
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.reset_site
    sleep    180s
    Wait Until Keyword Succeeds    8min    30s    Verify all cells should be onair   cell_type=${cell_type}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Get Slot ID from Container ID
    [Arguments]    ${hex_string}
    ${number}      Set Variable    ${hex_string.split()[0]}
    ${hex_digits}  Evaluate        ${number}[2]
    Set Test Variable    ${slot_id}    1
    Run Keyword If    '${hex_digits}' == '1'    Set Test Variable    ${slot_id}    1
    ...    ELSE IF    '${hex_digits}' == '2'    Set Test Variable    ${slot_id}    5
    ...    ELSE    Log    The first hex number after 0x is neither 1 nor 2
    [Return]  ${slot_id}

Expect Fault Should Present In Active or History Alarms
    [Documentation]    Auther:  xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=10

    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present
    ...      faultId=${faultId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    ...      alarmId=${alarmId}
    ...      configObjectName=${configObjectName}
    ...      supplementary=${supplementary}
    ...      supplementary_not_contain=${supplementary_not_contain}
    return from keyword if    ${present_status}      log to console  Expect Fault:${faultId} Present In Active Alarms

    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present In History Alarms
    ...      faultId=${faultId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Present In History Alarms
    [Documentation]    Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=100
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_historic_alarms    connection=${connection}    timeout=${timeout}    load_history=${True}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.
