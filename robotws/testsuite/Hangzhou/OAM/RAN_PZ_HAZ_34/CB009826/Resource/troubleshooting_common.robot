*** Settings ***
Documentation     author: Xing Casbo
...               contact: casbo.xing@nokia-sbell.com
...               squad group: SG_07
...               Feature : CB009826 Troubleshooting CA

#Library           OperatingSystem
#Library           Collections
Resource   9826_fallback_common.robot
Library   taf.sbts.oam.coam.admin    WITH NAME    coam

*** Variables ***
${Ignore_History_Fault_list}   61524,61652,4334,4655,4654,4592,4459,61649,61074,6327, 7107,7300,7319,1936,4420,4293
${Power_Reset_times}   2
*** Keywords ***
#TRBL Suite Setup
#    ${SUITE_SETUP_START}   DateTime.Get Current Date   result_format=epoch
#    Log To Console   SUITE_SETUP_START: ${SUITE_SETUP_START}
#    Set Suite Variable   ${SUITE_SETUP_START}

Case Setup: TRBL Test Setup
#    ${CASE_RROCESS_START}   DateTime.Get Current Date   result_format=epoch
#    Log To Console   CASE_RROCESS_START: ${CASE_RROCESS_START}
#    Set Test Variable   ${CASE_RROCESS_START}
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Wait Until Keyword Succeeds    9m   3m   COAM WEBUI Login
    Check Truck Roll Process
    Wait Until Keyword Succeeds   5m   30s   COAM Check all cells should be onair
    Run Keyword and Ignore Error   Start Syslog Collection


TRBL Test Teardown
    Siso Common Save Logs
    Remove SW Package From VM
    run keyword and ignore error    COAM Logout
    run keyword and ignore error    COAM WEBUI Logout

WebEM BTS Power Reset
#    COAM WEBUI Login
#    run keyword and ignore error     selenium_coam.power_reset    with_snapshot_collection=${False}
    ${status}    run keyword and return status   coam.Power_Reset   reset_with_snapshot=${False}   wait_for_reconnection=${False}   connection=COAM
    Should Be Equal    ${status}    ${true}
    BuiltIn.sleep  10s
    Log to console   Site power reseting...
    Wait Until Keyword Succeeds   5m   30s   Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${False}
    Log to console    Waiting for BTS up from power reset
    Wait Until Keyword Succeeds   10m   1m   Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${True}
    Run Keyword and Ignore Error   COAM WEBUI Logout   connection=COAM
    Run Keyword and Ignore Error   COAM Logout   connection=COAM
#    [Teardown]  COAM WEBUI Logout

WebEM BTS Power Reset in Loops
    Log to console   WebEM Admin BTS Power Reset Loop Start ...
    FOR   ${index}    IN RANGE    ${Power_Reset_times}
       ${RESET_RROCESS_START}   DateTime.Get Current Date   result_format=epoch
       Log To Console   RESET_RROCESS_START: ${RESET_RROCESS_START}
       Set Test Variable   ${RESET_RROCESS_START}
       taf_coam.COAM Login
       Wait Until Keyword Succeeds   5m   30s   COAM Check all cells should be onair
#       Run Keyword and Ignore Error   taf_coam.COAM Logout
       WebEM BTS Power Reset
       Wait Until Keyword Succeeds   15m  1m   Check Points After BTS Power Reset
       Log To Console  WebEM Admin BTS Power Reset: ${index + 1} Finshed
    END
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    Log To Console   WebEM Admin BTS Power Reset Finished!!!

Check Points After BTS Power Reset
    COAM Login
    Log to console   Module status checking...
    Check BTS Module Status
    Log to console   Cell status checking...
    COAM Check all cells should be onair
    Log to console   Alarm status checking...
    Check Alarm Status
    Log to console   Blackbox Checking...
    Check Blackbox
    Log to console   Syslog checking...
    Check Syslog Status
    Run Keyword And Ignore Error    COAM Logout

Check Alarm Status
    gnb_para.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
#    ${Ignore_Fault_list}   Create List   ${61524}   ${61652}   ${4655}   ${4592}   ${4654}   ${61649}   ${61074}  ${4420}
#    ...   ${4293}   ${6327}   ${4459}
#    ${Ignore_History_Fault_list}   Create List   ${61524}   ${61652}   ${4655}   ${4592}   ${4654}   ${61649}   ${61074}  ${4420}
#    ...   ${4293}   ${6327}   ${4459}   ${7107}   ${7300}   ${7319}
    @{return_active_alarm}   gnb_para.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault_list}
    @{return_history_alarm}   gnb_para.get_history_alarms    connection=gnb   except_alarms=${Ignore_History_Fault_list}
    ${active_alarm}   create list
    ${history_alarm}   create list
    FOR  ${active}  IN  @{return_active_alarm}
        ${faultid}   Set Variable   ${active['faultId']}
        append to list   ${active_alarm}     ${faultid}
     END
    FOR  ${history}  IN  @{return_history_alarm}
        ${faultid}   Set Variable   ${history['faultId']}
        append to list   ${history_alarm}     ${faultid}
     END
    Should Be Empty   ${active_alarm}
    Should Be Empty   ${history_alarm}
    [Teardown]  run keyword and ignore error  gnb_para.logout   connection=gnb

Check Blackbox
    ${RESET_START_TIMESTAMP}   Get Variable Value   ${RESET_RROCESS_START}   ${SUITE_SETUP_START}
    ${active_sw_release}   ${passive_sw_release}    Get SBTS SW release
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}   alias=gnb
    ${blackbox}   run keyword if   '${active_sw_release}'>'SBTS25R1'
    ...   csn.Execute   command=cd /ffs/run/logs/lifetimedata;cat blackbox   timeout=${60}   connection=gnb
    ...   ELSE   csn.Execute   command=cd /ffs/run/config/lifedata;cat blackbox   timeout=${60}   connection=gnb
    @{blackbox_split}   Split String   ${blackbox}   \r\n
    @{blackbox_info_list}   Create List
    FOR   ${blackbox_line}   IN   @{blackbox_split}
        ${isoutctime}   Set Variable   ${blackbox_line[:24]}
        ${status}   Run Keyword And Return Status
        ...   Should Match Regexp   ${isoutctime}   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\.\\d+([+-][0-2]\\d:[0-5]\\d|Z)
        Continue For Loop If   not ${status}
        ${datetime}   DateTime.Convert Date   date=${isoutctime}+0000   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S.%fZ%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Run Keyword If   ${timestamp} > ${RESET_START_TIMESTAMP}   Append To List   ${blackbox_info_list}   ${blackbox_line}
    END
    @{Extra_Reset}   Create List
    ...   System module site reset : Recovery (Execute reset.)
    ...   probably SW crash
    ...   Recovery (Execute reset.)
    ...   Watchdog reset
    FOR   ${blackbox_info}   IN   @{blackbox_info_list}
        ${is_Extra_Reset}   Evaluate   any(s in "${blackbox_info}" for s in ${Extra_Reset})
        Run Keyword If   ${is_Extra_Reset}   Fail   msg=BlackBox Unexpected Reset Happen: ${blackbox_info}
    END
    [Teardown]  csn.Disconnect   connection=gnb

Check Syslog Status
    ${output}   RUN   command=ls -al /tmp/btslog2/SYSLOG*.LOG
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}
    Log To Console   Syslog File List:
    Log To Console   ${output}
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
    ${status1}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4329'
    ${status2}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4330'
    ${status3}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4329'
    ${status4}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4330'
    ${status5}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4329'
    ${status6}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4330'
    ${status7}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '4230 Radio memory consumption exceeds critical threshold'
    ${status8}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '\\-\\=\\-\\='
    ${status9}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'Please contact the owner'
    ...   | grep -v '/ffs/run/logs'
    ...   | grep -v 'is not defined in SysinfoQuota.xml'
    ${offline_output}   RUN   command=${command}
    ${status10}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'ERR'
    ...   | grep '/ffs/run/logs'
    ...   | grep 'is not defined in SysinfoQuota.xml'
    ...   | grep 'Please contact the owner'
    ${offline_output}   RUN   command=${command}
    ${status11}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed
    ${status_list}   Create List   ${status1}   ${status2}   ${status3}   ${status4}   ${status5}   ${status6}
    ...   ${status7}   ${status8}   ${status9}   ${status10}   ${status11}
    Run Keyword And Continue On Failure   List Should Not Contain Value   ${status_list}   ${False}
