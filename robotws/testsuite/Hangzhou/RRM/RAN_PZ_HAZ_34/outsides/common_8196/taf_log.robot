*** Settings ***
Library   BuiltIn
Library   XML   True
Library   String
Library   DateTime
Library   Collections
Library   OperatingSystem

Library   taf.sbts.oam.coam.admin   WITH NAME   coam
Library   taf.transport.ssh   WITH NAME   csn
Library   taf.collectors.btslog   WITH NAME   btslog
Library   taf.collectors.core   WITH NAME   core
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py
Variables    ./libraries/global_vars.py
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

*** Variables ***
@{EMPTY_LIST}

*** Keywords ***
Start Syslog Collection
    [Documentation]  Start BTSlogs Collection and get logs
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/btslog2/SYSLOG_*.LOG
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/BTSLogCommandsLocalServer
    Run Keyword And Ignore Error   OperatingSystem.Run   command=mkdir /tmp/btslog2
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias   btslog
    core.setup_collectors   names=btslog
    core.start_collectors   names=btslog

Stop and Save Syslog Collection
    [Documentation]  Stop BTSlogs Collection and get logs
    core.stop_collectors   names=btslog
    ${curr_date_str}   DateTime.Get Current Date
    ${curr_date}   DateTime.Convert Date   ${curr_date_str}   datetime
    ${date_str}   Set Variable   ${curr_date.year}${curr_date.month}${curr_date.day}_${curr_date.hour}${curr_date.minute}
    OperatingSystem.Run    command=cd /tmp/btslog2; ls -al; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG
    OperatingSystem.Run    command=cd /tmp/btslog2; cp SYSLOG_combine_${date_str}.LOG ${OUTPUT_DIR}
    OperatingSystem.Run    command=cd /tmp/btslog2; rm -rf SYSLOG_*
    Set Suite Variable   ${ALL_SYSLOG_PATH}   ${OUTPUT_DIR}/SYSLOG_${date_str}.LOG
    [Return]   ${ALL_SYSLOG_PATH}

Stop and Delete Syslog Collection
    [Documentation]  Delete BTSlogs in VM
    Run Keyword And Ignore Error   core.stop_collectors      names=btslog
    OperatingSystem.Run   rm -rf /tmp/btslog2/SYSLOG_*

Check Offline And Online Interval Time
    [Arguments]  ${action}
    ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Online to Offline'
    @{offline_output}    split string   ${offline_output}   \n
    ${offline_time}   should match regexp    ${offline_output}[0]   \\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+
    ${online_output}    RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Offline to Online' |grep 'CellDriver'
    ${online_output}   Run Keyword And Ignore Error   run keyword if   '${online_output}'==''
    ...   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Degraded to Online' |grep 'CellDriver'
    ...   ELSE   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Offline to Online' |grep 'CellDriver'
    ${online_output}    split string   ${online_output}[-1]   \n
    ${online_time}   should match regexp    ${online_output}[-1]  \\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+
    ${downtime}   Subtract Date From Date    ${online_time}    ${offline_time}    compact
    Run Keyword And Ignore Error   Write gNB Status to Excel   title=Upgrade Downtime   content=${downtime}
    ${convert_downtime}    Convert Time    ${downtime}
    Run Keyword And Ignore Error  add json to file    downtime    ${convert_downtime}    ${OUTPUT_DIR}/execution_results.json    ${action}
    ${max_downtime}   Set Downtime by Config
    should be true  ${convert_downtime} < ${max_downtime}
    ...   msg=upgrade downtime ${convert_downtime} exceed performance criteria downtime ${max_downtime}

Check Extra Reset From Blackbox
     wait until keyword succeeds   10min    1min
     ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
     ${blackbox}   csn.execute    command=cd /ffs/run/config/lifedata;cat blackbox   timeout=300   connection=ASIK
     @{blackbox_split} =   Split String   ${blackbox}     \r\n
     FOR   ${reset}   IN   @{Extra_Reset}
        ${status}   run keyword and return status   Should Not Contain   ${blackbox_split[-8]}    ${reset}    msg=Extra Reboot Happen
        @{black_result}   Split String   ${blackbox_split[-8]}   /ffs
        run keyword if  not ${status}   fail  msg=Unexpected gnb reset happen: ${black_result[-1]}
     END
     [Teardown]   csn.disconnect    connection=ASIK

Check Error Log From Syslog
    [Arguments]   ${syslog_path}=${ALL_SYSLOG_PATH}
    Log To Console   Start To Check Syslog Error.
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    # Check Texts "-=-="" and "please contact".
    # Example:
    # 52 FCT-1011-3-HAS <2021-12-14T03:07:04.936382Z> 3382-BB_TRANSPORT ERR/HAS:(pid:12672) NEW -=-= Error Handler exception report =-=-
    # 53 FCT-1011-3-HAS <2021-12-14T03:07:04.936387Z> 3382-BB_TRANSPORT ERR/HAS:(pid:12672) Please contact the owner of 'BB_TRANSPORT'
    # 54 FCT-1011-3-HAS <2021-12-14T03:07:04.936392Z> 3382-BB_TRANSPORT ERR/HAS:(pid:12672) Core dump generation is disabled
    # (reason 'Core Dump R&D tag not set')
    # 55 FCT-1011-3-HAS <2021-12-14T03:07:04.936397Z> 3382-BB_TRANSPORT ERR/HAS:(pid:12672) fatality : 2 (EAaErrorFatality_System)
    ${output}   OperatingSystem.Run   cat ${syslog_path} | grep -i "\\-=\\-=" | grep -i "=\\-=\\-"
    ${status1}   Run Keyword And Return Status   Should Not Be Empty   ${output}
    ${output}   OperatingSystem.Run   cat ${syslog_path} | grep -i "please contact"
    ${status2}   Run Keyword And Return Status   Should Not Be Empty   ${output}
    Run Keyword If   ${status1} and ${status2}   Fail
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    Log To Console   Syslog Error Check Success.
    #-----------------------------------------------------------------------------------------------------------------------------------------------

Check Unexpected History Faults
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    ...   Description: Check Unexpected History Faults
    ...   :param gnb_index : GNB index, Default 0
    ...   :param hisory_faults_whitelist : A Faults list that user allowed to be ignored, Default EMPTY_LIST
    ...   :param should_fail : Keyword Should Be failed, Default True
    ...
    ...   The Default Allowed History Faults List is below:
    ...         61652     R&D Service Port enabled
    ...         61524     SSH enabled
    ...         61649     LMP access via port $port
    ...         9000      Temp Fault1
    ...         4592      BTS Reset Cause
    ...         4527      Radio Diagnostic Files collected
    ...         1932      No module fan detected
    ...         4334      Serial console activated
    ...         61074     CRL Update failure
    ...         61618     BTS and/or peer trust anchor expired or due to expire
    ...         7319      No X2 link available for a specific LTEENB
    ...         7300      No X2 link available
    ...         7317      NgSetupStopRetry
    ...         4420      GPS receiver alarm: firmware upgrade ongoing
    ...         4654      Ethernet port security is disabled
    ...         4655      Service account root access is enabled
    ...         4459      User Account has Default Password

    [Arguments]   ${gnb_index}=${0}   ${hisory_faults_whitelist}=${EMPTY_LIST}   ${should_fail}=${True}
    @{ALLOWED_HISTORY_FAULTS}   Create List
    ...   61652   61649   61618   61524   61074
    ...   9000   7319   7317   7300
    ...   4655   4654   4592   4527   4459   4334   4420
    ...   1932
    ${ALLOWED_HISTORY_FAULTS}   Combine Lists   ${ALLOWED_HISTORY_FAULTS}   ${hisory_faults_whitelist}

    ${WEBUI_ADDR}   Set Variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${WEBUI_USER}   Set Variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}   Set Variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

    Wait Until Keyword Succeeds   5m   1m   coam.connect_to
    ...   bts_host=${WEBUI_ADDR}
    ...   username=${WEBUI_USER}
    ...   password=${WEBUI_PASSWORD}
    ...   bts_port=${443}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${OUTPUT_DIR}
    ...   name=HISTORY_ALARM

    ${history_alarm_list}   coam.get_historic_alarms
    ...   load_history=${True}
    ...   connection=HISTORY_ALARM
    ...   timeout=${600}

    @{Unexpected_alarm_history}   Create List
    FOR   ${history_alarm}   IN   @{history_alarm_list}
        ${fault_id}   Set Variable   ${history_alarm['faultId']}
        Run Keyword If   '${fault_id}' not in ${ALLOWED_HISTORY_FAULTS}   Append To List   ${Unexpected_alarm_history}   ${history_alarm}
    END
    Run Keyword If   ${should_fail}   Should Be Empty   ${Unexpected_alarm_history}
    [Return]   ${Unexpected_alarm_history}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown   connection=HISTORY_ALARM
