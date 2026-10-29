*** Settings ***
Documentation
    ...    Contact: yin.4.chen@nokia-sbell.com
    ...             ruiyu.han@nokia-sbell.com

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
Library    taf.collectors.l1l2bip   WITH NAME  l1l2bip
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Variables ***
@{EMPTY_LIST}

*** Keywords ***
Start Syslog Collection
    [Documentation]  Start BTSlogs Collection and get logs
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/btslog2/SYSLOG*.LOG
    Run Keyword And Ignore Error   OperatingSystem.Run   command=rm -rf /tmp/BTSLogCommandsLocalServer
    Run Keyword And Ignore Error   OperatingSystem.Run   command=mkdir /tmp/btslog2
    run keyword and ignore Error   core.stop_collectors   names=btslog
    run keyword and ignore Error   core.Teardown Collectors      names=btslog
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    ...   start_timeout=${30}
    btslog.Set Global Alias   btslog
    ${status1}    Run Keyword And Return Status   core.setup_collectors   names=btslog
    ${status2}    Run Keyword And Return Status   core.start_collectors   names=btslog
    run keyword if   not ${status1} or not ${status2}    run keywords
    ...   run keyword and ignore Error   core.stop_collectors   names=btslog
    ...   AND   run keyword and ignore Error   core.Teardown Collectors      names=btslog

Stop and Save Syslog Collection
    [Documentation]  Stop BTSlogs Collection and get logs
    [Arguments]    ${logpath}=${OUTPUT_DIR}
    core.Teardown Collectors      names=btslog
    ${curr_date_str}   DateTime.Get Current Date
    ${curr_date}   DateTime.Convert Date   ${curr_date_str}   datetime
    ${date_str}   Set Variable   ${curr_date.year}${curr_date.month}${curr_date.day}_${curr_date.hour}${curr_date.minute}
    OperatingSystem.Run    command=cd /tmp/btslog2; ls -al; zip SYSLOG_archive_${date_str}.zip SYSLOG_*.LOG
    OperatingSystem.Run    command=cd /tmp/btslog2; cp SYSLOG_archive_${date_str}.zip ${logpath}
    OperatingSystem.Run    command=cd /tmp/btslog2; ls -al; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG
    OperatingSystem.Run    command=cd /tmp/btslog2; cp SYSLOG_combine_${date_str}.LOG ${logpath}
    OperatingSystem.Run    command=cd /tmp/btslog2; rm -rf SYSLOG_*
    Set Suite Variable   ${ALL_SYSLOG_PATH}   ${logpath}/SYSLOG_combine_${date_str}.LOG
    [Return]   ${ALL_SYSLOG_PATH}

Stop and Delete Syslog Collection
    [Documentation]  Delete BTSlogs in VM
    Run Keyword And Ignore Error   core.Teardown Collectors      names=btslog
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
     Wait Until Keyword Succeeds   1m   3x   COAM Login
     ${SW_release}   COAM Get SW Release
     wait until keyword succeeds   1min    3x
     ...   csn.Connect to   hostname=192.168.255.129   username=toor4nsn   password=oZPS0POrRieRtu   alias=ASIK
     ${blackbox}   run keyword if   '${SW_release}'>'SBTS25R1'
     ...   csn.execute    command=cd /ffs/run/logs/lifetimedata;cat blackbox_reset   timeout=300   connection=ASIK
     ...   ELSE   csn.execute    command=cd /ffs/run/config/lifedata;cat blackbox_reset   timeout=300   connection=ASIK
     @{blackbox_split} =   Split String   ${blackbox}     \r\n
     @{Extra_Reset}   Create List
    ...   System module site reset : Recovery (Execute reset.)
    ...   probably SW crash
    ...   Recovery (Execute reset.)
    ...   Watchdog reset
     FOR   ${reset}   IN   @{Extra_Reset}
        ${status}   run keyword and return status   Should Not Contain   ${blackbox_split[-2]}    ${reset}    msg=Extra Reboot Happen
#        @{black_result}   Split String   ${blackbox_split[-8]}   /ffs
        run keyword if  not ${status}   fail  msg=Unexpected gnb reset happen: ${blackbox_split[-2]}
     END
     [Teardown]   run keywords   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK
     ...   AND   Run Keyword And Ignore Error    COAM Logout

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
    ...         4681      Sanity Check Error

    [Arguments]   ${gnb_index}=${0}   ${hisory_faults_whitelist}=${EMPTY_LIST}   ${should_fail}=${True}
    @{ALLOWED_HISTORY_FAULTS}   Create List
    ...   61652   61649   61618   61524   61074
    ...   9000   7319   7317   7300
    ...   4681   4655   4654   4592   4527   4459   4334   4420
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

Start catch BIP logs
    [Documentation]     Collect L1L2 BIP Logs using gnbMirroring.sh script V61
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param interface: Interface tcpdump (default any)
    ...     -   :param options:   Addtional options for tcpdump e.g. set bip filter (default empty)
    ...     -   :param cellid:   Addtional nr_phy_cell_ids for tcpdump e.g. ${cellid}=328,428,318,418,338,438(default NONE)
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${interface}=any
    ...     ${options}=${EMPTY}
    ...     ${cellid}=${None}
    log to console   start to catch bip log, maybe use interface='${interface}', options='${options}'...
    ${webservice}=  Create Dictionary
    ...    host=${WEBUI_ADDR}
    ...    user=${WEBUI_USER}
    ...    password=${WEBUI_PASSWORD}
    ...    port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias}
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${cellid}
    ...  timeout=3600
    l1l2bip.Set suite alias  ${alias}
    ${status}    run keyword and return status    _setup_and_start_collectors   names=${alias}
    run keyword and return if  '${status}' == 'False'    run keywords    core.teardown_collectors  names=${alias}
    ...   AND    FAIL   [warn]start bip log failed! Will retry!
    Log to console  BIP logs collecting started

_setup_and_start_collectors
    [Arguments]    ${alias}=L1L2_BIP_Logs
    core.setup_collectors    names=${alias}
    core.start_collectors    names=${alias}

Stop and Save BIP logs
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/${TEST_NAME})
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}
    ...     ${delay}=0
    Sleep  ${delay}
    core.stop_collectors  names=${alias}
    core.collect_collectors  names=${alias}  target_dir=/tmp
    core.teardown_collectors  names=${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/BTS*.pcap -w /tmp/${alias}/bip.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/bip.pcap    ${dir_path}/${alias}/bip.pcap
    RUN   cd ${dir_path}/${alias};zip biplog.zip bip.pcap;rm -f bip.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished

Start Capture Wireshark at gNB
    [Arguments]     ${nglogname}    ${interface}=any
    log to console    tcpdumplog_start
    csn.Connect To    hostname=${asik_addr}
    ...     username=${asik_username}
    ...     password=${asik_password}
    ...    alias=gnb
    csn.send command    command=rm -f /tmp/${nglogname}   connection=gnb
    BuiltIn.sleep   3s
    csn.send command    command=ls -l /tmp/${nglogname}   connection=gnb
    BuiltIn.sleep   1s
    csn.send command    command=tcpdump -i ${interface} sctp -w /tmp/${nglogname}   connection=gnb
    BuiltIn.sleep   3s
    [Teardown]     csn.disconnect    connection=gnb

Stop and download Wireshark at gNB
    [Arguments]    ${nglogname}
    log to console    tcpdumplog_stop
    csn.Connect To    hostname=${asik_addr}
    ...     username=${asik_username}
    ...     password=${asik_password}
    ...     alias=gnb
#    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb
#    sleep    3
    run keyword and ignore error   csn.send command    command=rm ${tmp}/asix*   connection=gnb
    Create directory   ${OUTPUT_DIR}/${TESTNAME}
    csn.download_file   remote_path=/tmp/${nglogname}   local_path=${OUTPUT_DIR}/${TESTNAME}/${nglogname}   connection=gnb
#    sleep    3
    [Teardown]   csn.disconnect    connection=gnb

Stop Wireshark at gNB
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb
    csn.send command    command=killall tcpdump     connection=gnb
    [Teardown]   csn.disconnect    connection=gnb


Start Egen Log
    [Arguments]    ${egen_server}=10.57.232.154   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97
    Log To Console    Start Egen Log
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${command}   Catenate   SEPARATOR=
    ...   sudo egen --cores 0-6${SPACE}
    ...   --port 03:00.0 --port 03:00.1${SPACE}
    ...   --port 82:00.0 --port 82:00.1${SPACE}
    ...   --capture /tmp/AEHC.pcap${SPACE}
    ...   --save-n-and-quit 1000000${SPACE}
    ...   &> /dev/null &
    csn.send command   command=${command}   timeout=60   connection=egen
    [Teardown]    csn.Disconnect       connection=egen


Stop Egen Log
    [Arguments]    ${egen_server}=10.57.232.154   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97
    Log To Console    Stop Egen Log
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${output}   csn.Execute   command=ps -ef | grep "egen --cores"   timeout=60   connection=egen
    ${pid_list}   Get Regexp Matches   ${output}   root\\s+(\\d+)   1
    FOR    ${pid}    IN   @{pid_list}
        csn.send command   command=sudo kill -9 ${pid}   timeout=60   connection=egen
    END
    [Teardown]    csn.Disconnect       connection=egen


Stop Egen Log and Save to VM
    [Arguments]    ${egen_server}=10.57.232.154   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97    ${logpath}=${OUTPUT_DIR}
    Log To Console    Stop Egen Log And Save To VM
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${output}   csn.Execute   command=ps -ef | grep "egen --cores"   timeout=60   connection=egen
    ${pid_list}   Get Regexp Matches   ${output}   root\\s+(\\d+)   1
    FOR    ${pid}    IN   @{pid_list}
        csn.send command   command=sudo kill -9 ${pid}   timeout=60   connection=egen
    END
    csn.Download File   remote_path=/tmp/AEHC.pcap   local_path=${logpath}/AEHC.pcap   connection=egen
    [Teardown]    csn.Disconnect       connection=egen

