*** Settings ***
Documentation    This is common keywords for siso sync related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      taf.selenium.sbts    WITH NAME    selenium_coam
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/btsom_log.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot

*** Keywords ***
get sync info of GNB
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]
    ...    ${syncst_path}=${syncStatus_path}
    ...    ${lockst_path}=${lockState_path}
    ...    ${accpetclock_path}=${acceptedClock_path}
    ...    ${syncinput_path}=${syncInputType_RAU_path}
    Selenium Login And Disable Screen Lock
    ${syncstatus}    selenium_coam.get_parameter_value    dist_name=${syncst_path}    filter_param=Clock synchronization status
    ${lockstate}    selenium_coam.get_parameter_value    dist_name=${lockst_path}    filter_param=ToP slave lock state
    ${accpetclock}    selenium_coam.get_parameter_value    dist_name=${accpetclock_path}    filter_param=Accepted clock class list
    sort list    ${accpetclock}
    ${syncinput}    selenium_coam.get_parameter_value    dist_name=${syncinput_path}    filter_param=Sync input type
    ${sync_info}    create dictionary    syncstatus=${syncstatus}    lockstate=${lockstate}
    ...    acceptclock=${accpetclock}   syncinput=${syncinput}
    [Return]    ${sync_info}
    [Teardown]   Selenium Logout And Close Browser

set sync info of GNB
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]
    ...    ${accpetclock_path}=${acceptedClock_path}
    ...    ${syncinput_path}=${syncInputType_RAU_path}
    ...    ${syncinput}=${syncInputType_new}
    ...    ${acceptclock}=${accept_clock_value_modify}
    Selenium Login And Disable Screen Lock
    selenium_coam.set_parameter_value
    ...    abbr=syncInputType
    ...    dist_name=${syncinput_path}
    ...    filter_param=Sync input type
    ...    new_value=${syncinput}
    sleep    1s
    selenium_coam.set_parameter_value
    ...    abbr=acceptedClockClass
    ...    dist_name=${accpetclock_path}
    ...    filter_param=Accepted clock class list
    ...    new_value=${acceptclock}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    [Teardown]   Selenium Logout And Close Browser

check sync status change of GNB
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]
    ...    ${syncst_path}=${syncStatus_path}
    ...    ${lockst_path}=${lockState_path}
    Selenium Login And Disable Screen Lock
#    :FOR  ${i}    IN RANGE    10
#    \    ${syncstatus}    selenium_coam.get_parameter_value    dist_name=${syncst_path}    filter_param=Clock synchronization status
#    \    Run keyword if    '${syncstatus}'=='Holdover'    exit for loop
#    \    sleep    1s
#    Should be True    '${syncstatus}'=='Holdover'
    FOR  ${i}    IN RANGE    10
        ${syncstatus}    Wait Until Keyword Succeeds   3x   10s    selenium_coam.get_parameter_value    dist_name=${syncst_path}
        ...    filter_param=Clock synchronization status
        Run keyword if    '${syncstatus}'=='Freerun'    exit for loop
        sleep    1s
    END
    Should be True    '${syncstatus}'=='Freerun'
    ${lockstate}    Wait Until Keyword Succeeds   3x   10s    selenium_coam.get_parameter_value    dist_name=${lockst_path}
    ...    filter_param=ToP slave lock state
    Should be True    '${lockstate}'=='OutOfLock'
    [Teardown]   Selenium Logout And Close Browser

check sync info of RU
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]    ${status}
    Connect to Common Unit Master
    ${release}    Get program version based on gNB active version
    ${sub_dir}   Run Keyword If   "${release}"=="SBTS23R2" or "${release}"=="SBTS23R3"    set variable    *
    ...    ELSE    set variable    UnitOAM_SOAP_Startup_LBTS_*
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${log_path_ute}    Wait Until Keyword Succeeds   3x   10s    getsoapfile    subdir=${sub_dir}    connection=RU_${ru_index}
        ${syncstate}    get syncstate from soap log    local_soap_path=${log_path_ute}
        run keyword if    ${status}=='abnormal'    should be equal    ${syncstate[-1]}    FREERUN
         ...   ELSE    should be equal    ${syncstate}    ${syncstate_ru_ok}
        ${lockstate}    get lockstate from soap log    local_soap_path=${log_path_ute}
        run keyword if    ${status}=='abnormal'    should be equal    ${lockstate[-1]}    UNLOCKED
         ...   ELSE    should be equal    ${lockstate[-1]}    LOCKED
        ${acceptclock}    get acceptclock from soap log    local_soap_path=${log_path_ute}
        @{acceptclock_list}    split string    ${acceptclock[-1]}    ,
        ${accept_clock_value_modify}    convert to string    ${accept_clock_value_modify[0]}
        run keyword if    ${status}=='abnormal'    should be equal    ${acceptclock[-1]}    ${accept_clock_value_modify}
         ...   ELSE    should be equal    ${acceptclock_list}    ${sync_old['acceptclock']}
        csn.Disconnect    connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

Check eCPRI PTP State via Btsom Log
    [Documentation]  Author:jie-jessy.li@nokia-sbell.com
    [Arguments]    ${filter}=API_START_SYNCE_RESP_MSG    ${check_content}=EeCpriStatus_NoError    ${alias}=asik_conn
    ${output}    Check Btsom Log file on ASIK    filter=${filter}
    Should Contain    ${output}    Received ${filter} with status ${check_content}

Change NCPRI PM Interval
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    log to console   \nChange NCPRI PM Interval to ${interval}
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    ${filter_param}    Run keyword If  '${release_sbts}'=='SBTS23R3' or '${release_sbts}'=='SBTS23R4'
	...    set variable    SBTS NR eCPRI Master Statistics
    ...    ELSE    set variable    SBTS eCPRI Master Statistics
	${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=eCpriMasterStatisticsInterval    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${origin_value}


Check Sync Counter
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${change_interval}=5
    log to console  \n***Check Sync Counter***
    Wait Until Next Counter Update 561    counter_period=${change_interval}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    ${SyncMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C0
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    run keyword and ignore error    selenium_coam.refresh_page
    ${AnnMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C1
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayRespMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C2
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayReqMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C3
    Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    run keyword and ignore error    selenium_coam.refresh_page
    ${SsmMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C4
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302

Wait Until Next Counter Update 561
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${counter_period}=5    ${gnb_connection}=ASIK Master
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${gnb_connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Sync Startup is verified
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    log to console  \n***Sync Startup is verified***
    ${bts_sync_mode}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1    filter_param=BTS synchronization mode
    ${bts_sync_mode_1}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/CLOCK_R-1
    ...    filter_param=Active synchronization mode
    should be equal as strings    ${bts_sync_mode_1}    ${bts_sync_mode}
    ${eCPRI_Master_clock_state}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...    filter_param=eCPRI Master clock state
    should be equal as strings    ${eCPRI_Master_clock_state}    MASTER_CLOCK_OK
    Check eCPRI Basic configuration via SOAP message

Sync data is verified after startup
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${origin_interval}    ${change_interval}
    log to console  \n***Sync data is verified after startup***
    Wait for New Interval PM measurements Generate    ${origin_interval}
    sleep  ${change_interval}
    sleep  30
    ${interval_seconds}    Get Interval Seconds    ${change_interval}
    ${Sync_messages_counter}    Get PM Counter via Webem    counter_id=M40102C0    interval=${change_interval}    counter_type=Transport
    ${Sync_messages_counter}    convert to integer     ${Sync_messages_counter}
    ${message_rate}    evaluate    ${Sync_messages_counter}*1.0/${interval_seconds}
    ${message_rate}  Evaluate    int(round(${message_rate}))     math
    should be equal as strings     ${message_rate}    16
    ${announce_messages_counter}    Get PM Counter via Webem    counter_id=M40102C1    interval=${change_interval}    counter_type=Transport
    ${announce_messages_counter}    convert to integer     ${announce_messages_counter}
    ${message_rate}    evaluate    ${announce_messages_counter}*1.0/${interval_seconds}
    ${message_rate}  Evaluate    int(round(${message_rate}))     math
    should be equal as strings    ${message_rate}    8

Wait for New Interval PM measurements Generate
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    log to console  \nWait for New Interval PM measurements Generate
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    get time from gnb
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    run keyword and ignore error    selenium_coam.refresh_page
    ${orig_content}    Get PM Counter content via Webem    counter_id=ETHLK-2    counter_type=Transport
    ${orig_len}    get length  ${orig_content}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    sleep    ${wait_time}min
    sleep    30
    FOR  ${i}  IN RANGE  ${3}
        ${new_content}    Get PM Counter content via Webem    counter_id=ETHLK-2    counter_type=Transport
        ${new_len}    get length  ${new_content}
        exit for loop if   ${new_len}>${orig_len}
        sleep    ${interval}
        sleep    30
    END

Check eCPRI Basic configuration via SOAP message
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${alias}=ASIK Master
    ${output}    Check Btsom Log file on ASIK   filter=API    alias=ASIK Master
    Should Contain    ${output}    Sending API_INET_VLAN_SET_REQ_MSG
    Should Contain    ${output}    Sending API_START_PTP_REQ_MSG
    Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status EeCpriStatus_NoError

Sync status reported to O&M is verified
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    log to console  \n***Sync status reported to O&M is verified***
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ${currentUtcOffsetValid}   Get Parameter Via Webem    dist_name=${dist_name}
    ...    filter_param=eCPRI Master UTC offset validity flag
    should be equal as strings    ${currentUtcOffsetValid}    true
    ${frequencyTraceable}    Get Parameter Via Webem    dist_name=${dist_name}
    ...    filter_param=eCPRI Master clock frequency traceable to a PRC clock
    should be equal as strings    ${frequencyTraceable}    true
    ${timeTraceable}    Get Parameter Via Webem    dist_name=${dist_name}
    ...    filter_param=eCPRI Master time traceable to a PRTC clock
    should be equal as strings    ${timeTraceable}    true
    ${ClockClass}    Get Parameter Via Webem    dist_name=${dist_name}
    ...    filter_param=eCPRI Master clock class
    should be equal as strings    ${ClockClass}    6

Get PM Counter via Webem
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${counter_id}    ${interval}   ${dist_name}=${None}  ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${current_time}   get time from gnb
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
    ${value}    get_from_dictionary   ${content}    ${last_time}
    [Return]    ${value}

Set ptp only to true
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    log to console    \n Set ptp only to true
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate eCPRI RU PTP only synchronization
    ...    p_name=actEcpriRuPtpOnlySync    value=true
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate general connectivity bronze use case level
    ...    p_name=actGeneralConnectivityBronze    value=true
    append to list  ${modify_params}  ${item}
    ${origin_params}    generate origion parameters    modify_params=${modify_params}
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Return]    ${origin_params}

Modify Accepted clock class list
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${acceptedClockClass}
    log to console    \n Modify Accepted clock class list to ${acceptedClockClass}
    ${modify_params}    create list
	${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
	...    filter_param=Accepted clock class list  p_name=acceptedClockClass  value=${acceptedClockClass}
    append to list  ${modify_params}  ${item}
    ${value}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
	...    filter_param=Accepted clock class list
    Modify Parameters On Webem    modify_params=${modify_params}
    [Return]  ${value}

Check Sync State and Slave State
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${sync_state}=Locked    ${slave_state}=Locked
    ${value}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
	...    filter_param=Clock synchronization status
	should be equal as strings    ${value}    ${sync_state}
    ${value}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
	...    filter_param=ToP slave lock state
	should be equal as strings    ${value}    ${slave_state}
