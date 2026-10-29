*** Settings ***
Documentation    This is for android UE normal L3 call common keyword, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Andy Cheng
...              Contact: huimin.1.cheng@nokia-sbell.com
...              Squard: HZ SG3

Library           Telnet
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.pdu  WITH NAME   pdu
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/qualcomm_common_keywords.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource          taf/rfrl/common_resources/robot/stream_manager.robot
Library           ../python/ue.py
Library    DateTime
Library    String
Library    taf.ul.mobile.ui.android    WITH NAME    android_ui

*** Variables ***
${QPSTexe}    "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"


*** Keywords ***
Precondition for Android UE
    [Documentation]  This keyword is the precondition for android ue attach,
    ...  action contain QPST start to avoid UE crash and airplane mode turn on
    ...              and ue reboot to clear last time test remained.
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    Start the QPST progress    ${ue_index}
    Check UE device exist    ${ue_index}
    Reserve ue with index    ue_index=${ue_index}    cap_index=${cap_index}
    UE soft reboot    ${ue_index}

Prepare for Android UE
    [Documentation]  This keyword is the precondition for android ue attach,
    ...   action contain QPST start to avoid UE crash and airplane mode turn on
    ...   and ue reboot to clear last time test remained. also has the choose with control pc reset or ue pb reset to recover UE connect
    ...   :param reset_sol has four choose (none, pc_reset, pb_reset):
    ...    none with default choose mean with no action when ue connect is missing.
    ...    pc_reset mean if ue connection nok, will try to reset the control pc to recover.
    ...    pb_reset mean if ue connection nok, will try to reset the ue with ue PB power off and on.
    ...    ue_reboot mean force to let ue with adb reboot before attach.
    ...   :param detach_request is the choose with ue with detach status contain in prepare progress.
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}    ${reset_sol}=none    ${detach_request}=${true}
    ${ue_status}    run keyword and return status    Check UE device status with adb recover    ue_index=${ue_index}
    run keyword if     '${reset_sol}'=='none'    should be true  ${ue_status}  msg=with adb server kill still cannot recover ue connect
    run keyword if     ${ue_status}==${False} and '${reset_sol}'=='pc_reset'    Check ue device after pc reset    ue_index=${ue_index}
    run keyword if     ${ue_status}==${False} and '${reset_sol}'=='pb_reset'    Check ue device after pb reset    ue_index=${ue_index}
    Reserve ue with index    ue_index=${ue_index}    cap_index=${cap_index}
    ${app_status}    run keyword and return status    Start the uemanager App    ue_index=${ue_index}
    run keyword if    ${app_status}==${False} or '${reset_sol}'=='ue_reboot'    UE soft reboot
    ...               ue_index=${ue_index}    detach_request=${detach_request}
    run keyword if    ${app_status}==${True} and ${detach_request}==${true}   Ue detach with index    ue_index=${ue_index}

Check ue device after pc reset
    [Arguments]  ${ue_index}=${0}
    Reset UE Control PC    ue_index=${ue_index}
    BuiltIn.sleep    1min
    Connect to control pc enhanced    ue_index=${ue_index}
    Start the QPST progress    ue_index=${ue_index}
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    should be true    ${status}    msg=with control pc reset still cannot connect to ue device

Check ue device after pb reset
    [Arguments]  ${ue_index}=${0}
    ${ue_pdu_ip} =    set variable    ${tl.ues[${ue_index}].pdu_port.pdu.addr}
    ${ue_pdu_port} =    set variable    ${tl.ues[${ue_index}].pdu_port.port_no}
    Power off on ue    ue_index=${ue_index}    ue_pdu_ip=${ue_pdu_ip}    ue_pdu_port=${ue_pdu_port}
    BuiltIn.sleep    30s
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    should be true    ${status}    msg=with ue PB reset still cannot connect to ue device

Check UE device status with adb recover
    [Arguments]  ${ue_index}=${0}
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    run keyword if    ${status}==${False}    Restart adb server and wait until status ready    ue_index=${ue_index}

Android UE l3 call
    [Documentation]  This keyword start android ue L3 call and check the call status,
    ...  and also one time reattach as WA for not success with ute_ue lib connect issue.
    ...  :param 5Gstatus is the tag for the 5GRACH should be success or not, contain the abnormal scenario
    ...  :param ue_index is the list index from tl.ues[], it will use the index UE for reserve
    [Arguments]    ${5Gstatus}=PASS    ${ue_index}=${0}
    ${5Grach_ed}    ${5Grach_time_ed}    Get 5GRACH success times on gnb side
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword if     '${attach_status}'=='False'    Ue reattach with index    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10s    Check 5G Rach Status    before=${5Grach_ed}    before_time=${5Grach_time_ed}
    ...                                                                   5Gstatus=${5Gstatus}
    BuiltIn.sleep    3s

Android UE Attach
    [Documentation]  This keyword start android ue attach and check the attach result,
    ...  and also one time reattach as WA for not success with ute_ue lib connect issue.
    ...  :param 5Gstatus is the tag for the 5GRACH should be success or not, contain the abnormal scenario
    ...  :param ue_index is the list index from tl.ues[], it will use the index UE for reserve
    [Arguments]    ${5Gstatus}=PASS    ${ue_index}=${0}   ${operation}=${0}   ${4G_check}=${true}
    Log    ${operation}
    ${5Grach_ed}    Get 5GRACH success info on gnb side
#    Run Keyword Unless   ${operation}==${0}   Ue attach with index    ue_index=${ue_index}
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword if   ${4G_check}   wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    ...   ELSE   Run keywords   BuiltIn.Sleep   10s   AND   run keyword and ignore error   Verify 4G Attach by ADB Command    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10s    Verify 5G attached gnb   5Grach_ed=${5Grach_ed}   5Gstatus=${5Gstatus}

Verify 5G attached gnb
    [Arguments]   ${5Grach_ed}    ${5Gstatus}=PASS   ${abil_index}=${1}
    ${5Grach_ing}    Get 5GRACH success info on gnb side   abil_index=${abil_index}
    Verify 5G New Attach Available   before=${5Grach_ed}   after=${5Grach_ing}   expect=${5Gstatus}
    BuiltIn.sleep   3s

verify 5G rach success
    [Arguments]    ${before}    ${after}    ${before_time}    ${after_time}
    ${item_flag}    Run keyword and return status    Should be true    ${after}>${before}
    ${time_flag}    Run keyword and return status    '${before_time}'!='${after_time}'
    Run keyword if    '${item_flag}'=='False'    Run keyword if    '${time_flag}'=='False'
    ...               Fail    5G RACH still not success after retry
    Log to console    \nINFO:5G UE RACH successfully.

verify 5G rach not success
    [Arguments]    ${before}    ${after}    ${before_time}    ${after_time}
    ${item_flag}    Run keyword and return status    Should be true    ${after}==${before}
    ${time_flag}    Run keyword and return status    '${before_time}'=='${after_time}'
    Run keyword if    '${item_flag}'=='False'    Run keyword if    '${time_flag}'=='False'
    ...               Fail    5G RACH success but not as expected
    Log to console    \nINFO:5G UE RACH not successfully.

Android UE release
    [Documentation]  This keyword start android normal UE release,
    ...  and clear QPST progress.
    [Arguments]    ${ue_index}=${0}
    Check UE device exist    ${ue_index}
    Ue detach with index    ${ue_index}
    Stop the QPST progress    ${ue_index}

Get Mplane IP from gNB
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ${mplane_ip}   Set Variable   ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${host}   Set Variable If   '${mplane_ip}'=='None'
    ...      ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...      ${mplane_ip}
    [Return]   ${host}

Get 5GRACH success times on gnb side
    [Documentation]  This keyword help to check the 5G RACH status in gnb side
    ...  :param gnb_index is index for which gnb prepare to attach
    ...  :param du_index is index for which du prepare to attach
    ...  :param hwcheck_index is index for which HW try to check 5grach status, ex: 0->ASIK 1>ABIL1 2->ABIL2 3->ABIL3
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hwcheck_index}=${1}    ${log_type}=journallog
    ...    ${log_loca}=l2lo
    ${host}   Get Mplane IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${host}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK
    ${abil_alias}    run keyword if    '${log_type}'=='journallog'    Connect to ABIL by index
    ...              abil_index=${hwcheck_index}   asik_alias=ASIK    alias=fsp${hwcheck_index}a
    ${journal_cmd}=    catenate    journalctl -b|grep "flow control start"|grep -v grep
#    ${Aal2lo_cmd}=    catenate    cat /tmp/5Grach.txt | grep -a "flow control starts" | grep -av grep
    ${Aal2lo_cmd}=    catenate    grep -aE 'flow control starts|Start flow control successfull' /tmp/5Grach.txt
#    ${Aal2hidu_cmd}=    catenate    cat /tmp/5Grach.txt | grep -a "flow control started" | grep -av grep
    ${Aal2hidu_cmd}=    catenate    cat /tmp/5Grach.txt | grep -ai "flow control started" | grep -av grep
    ${output} =    run keyword if    '${log_type}'=='journallog'    csn.execute    command=${journal_cmd}    connection=${abil_alias}
    ...    ELSE IF    '${log_type}'=='Aasyslog' and '${log_loca}'=='l2lo'    csn.execute    command=${Aal2lo_cmd}    connection=ASIK
    ...    ELSE IF    '${log_type}'=='Aasyslog' and '${log_loca}'=='l2hidu'    csn.execute    command=${Aal2hidu_cmd}    connection=ASIK
    run keyword and ignore error    run keyword if  not ${hwcheck_index}==${0}   csn.disconnect    connection=${abil_alias}
    run keyword and ignore error    csn.disconnect    connection=ASIK
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    ${last_line}    Run keyword if    ${len}>0    Get From List    ${list}    -1
    ${rach_time}    Run keyword if    ${len}>0    Get Regexp Matches    ${last_line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
    [Return]    ${len}    ${rach_time}

Get 5GRACH success info on gnb side
    [Documentation]  This keyword help to check the 5G RACH status in gnb l2lo side
    [Arguments]   ${abil_index}=${1}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    ${abil_alias}    wait until keyword succeeds    1 min    10 sec    Connect to ABIL by index
    ...   ${abil_index}   ASIK    alias=fsp${abil_index}a
    ${output} =    csn.execute    command=journalctl -b | grep "flow control start" |grep -v grep    connection=${abil_alias}
    run keyword and ignore error    run keyword if  not ${abil_index}==${0}   csn.disconnect    connection=${abil_alias}
    run keyword and ignore error    csn.disconnect    connection=ASIK
    @{list}    split string    ${output}    \n
    [Return]    ${list}

Reserve ue with index
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...  It will read the testline tl.ues all parameter in ue_pool
    ...  It is strongly suggested to put this keyword into the suite setup.
    ...  If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...  Important: this keyword support multi ue , but need to config the tl.ues[xx].capability[] at least with one different value.
    ...  :param ue_index is the list index from tl.ues[], it will use the index UE for reserve
    ...  :param index for tl.ues.capabilities[] list, for multi ue, should use the different capability value's index here.
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}

Ue attach with index
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...  If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    [Arguments]  ${ue_index}=${0}
    ute_ue.attach_ue    UE_${ue_index}

UE Reboot with adb command
    [Arguments]  ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Restart adb server and wait until status ready    ue_index=${ue_index}   serial_number=${serial_number}
    ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    BuiltIn.sleep    30s

UE soft reboot
    [Documentation]  Actions for every UE reboot request needed.
    ...    2021-5-13 Ding Binmei: Change reboot ue to taf method, as original method will case ue manager app startup failure issue
    [Arguments]  ${ue_index}=${0}   ${detach_request}=${true}    ${reboot_timeout}=120
    Check UE device exist    ${ue_index}
    UE reboot via taf method    ue_index=${ue_index}   detach_request=${detach_request}    reboot_timeout=${reboot_timeout}

UE Forced Reboot
    [Arguments]  ${ue_index}=${0}   ${detach_request}=${true}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    UE Reboot with adb command   ue_index=${ue_index}   serial_number=${serial_number}
    Run Keyword If   ${detach_request}   wait until keyword succeeds    5min    10s    Ue detach with index    ${ue_index}

UE reboot via taf method
    [Documentation]  Author: Ding Binmei
    ...              Description: Reboot UE via taf method
    [Arguments]  ${ue_index}=${0}   ${detach_request}=${True}    ${reboot_timeout}=120
    ute_ue.reboot_ue    ue_alias=UE_${ue_index}    timeout=${reboot_timeout}
    Run Keyword If   ${detach_request}  run keywords    Ue attach with index    ue_index=${ue_index}    AND
    ...    sleep    3s    AND
    ...    Ue detach with index    ${ue_index}

Start the uemanager App
    [Documentation]  Modifier: Ding Binmei 2019-10-10
    ...              Description: Added check point for checking if ue manager app is started after sending out startup command
    ...              2020/07/16: Liu Zheng add sleep time before check uemanager app process, because on some testline, after
    ...              start uemanager, the process can not be greped immediately, but the process is really started.
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Check UE device exist    ${ue_index}
    Connect to control pc enhanced    ${ue_index}
    csn.execute
    ...    command=adb -s ${serial_number} shell monkey -p com.nokia.syve.uemanager.mobile -c android.intent.category.LAUNCHER 1
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    sleep   3s
    Run keyword and ignore error
    ...    wait until keyword succeeds   8s    1s    Verify if ue manager app is started    cpc_alias=cpc_${ue_index}    ue_index=${ue_index}
    [Teardown]  csn.disconnect      connection=cpc_${ue_index}

Ue reattach with index
    [Documentation]  This keyword's is a WA for ute_ue.ue attach sometimes not connect success and attach fail.
    [Arguments]  ${ue_index}=${0}
    UE soft reboot    ue_index=${ue_index}
    Ue attach with index    ue_index=${ue_index}

Ue detach with index
    [Documentation]  When with UE_CAPABILITIES is REAL_ANDORID_UE,
    ...  the keyword will send adb command to turn on the airplane mode.
    [Arguments]  ${ue_index}=${0}
    ute_ue.detach_ue    UE_${ue_index}

Get the UE Ip address
    [Documentation]  After UE attach success, can use this keyword to get the UE IP for data transfer.
    [Arguments]    ${ue_index}=${0}
    ${IP}    ute_ue.Get Ue Info    UE_${ue_index}    IP
    [return]  ${IP}

Get Android UE IP
    [Documentation]   Get Android UE IP by command adb -s SN_OF_UE shell ifconfig
    [Arguments]   ${ue_index}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced   ue_index=${ue_index}
    csn.Send Command   adb -s ${serial_number} shell ifconfig   connection=cpc_${ue_index}
    ${ip_info}   Wait Until Keyword Succeeds   3x   2s   UE PC SSH output Should Not Empty   ue_index=${ue_index}
    ${ip}   ue.get_ava_ue_ip   ue_ifconfig_output=${ip_info}
    [Return]   ${ip}
    [Teardown]   csn.Disconnect   connection=cpc_${ue_index}

Start the QPST progress
    [Documentation]  To start the Control PC qpst.exe progress to catch the ue crash dump ,
    ...  then make ue recover to normal start screen.
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=3s
    Connect to control pc enhanced    ${ue_index}
    csn.Send Command    command=tasklist | grep "QPSTServer.exe" | grep -v grep  connection=cpc_${ue_index}    timeout=5
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${status}    ${result}    run keyword and ignore error    csn.read_output    connection=cpc_${ue_index}
    ${status_output}    run keyword and return status    should contain    ${result}    QPSTServer.exe
    run keyword if    ${status_output}== ${False}    csn.Send Command    command=${QPSTexe}   connection=cpc_${ue_index}    timeout=5
    BuiltIn.sleep    3s
    [Teardown]    Run keyword and ignore error    csn.disconnect      connection=cpc_${ue_index}

Stop the QPST progress
    [Documentation]  To start the Control PC qpst.exe progress to catch the ue crash dump ,
    ...  then make ue recover to normal start screen.
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=taskkill /F /IM QPSTConfig.exe    connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

Connect to control pc enhanced
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${output}    RUN    netstat -natple | grep ssh
    ${cpc_status}    run keyword and return status
    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               reset cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}

reset cpc sshd services
    [Documentation]  Start the sshd server, with sometimes reset the control pc system,
    ...  the sshd server not work.
    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}
    Telnet.Open connection    ${cpc_ip}
    Telnet.set timeout    20 s
    Telnet.Login    ${cpc_usrname}    ${cpc_passwd}    login_timeout=10 s    password_prompt=password:
    Telnet.Write    sc stop cygsshd
    BuiltIn.sleep    5s
    Telnet.Write    sc config cygsshd start= Auto
    BuiltIn.sleep    5s
    Telnet.Write    sc start cygsshd
    BuiltIn.sleep    5s
    Telnet.close connection
    BuiltIn.sleep    5s

Reset UE Control PC
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect      connection=cpc_${ue_index}

ADB Reboot UE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}
    csn.disconnect   connection=cpc_${ue_index}
    sleep    10s

Verify 4G Attach by ADB Command
    [Documentation]   Verify 4G UE network type normal by ADB command.
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    Should contain  ${result}  LTE
    Log to console    \nINFO:4G UE ATTACH successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Check UE device exist
    [Documentation]   Check the UE device is connect to control pc normally.
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Get UE device status
    [Documentation]   UE Status Reading from "adb devices" interface
    [Arguments]  ${alias}    ${serial_number}    ${sleep_time}=10s
    Csn.send_command   command=adb devices    connection=${alias}    timeout=5
    BuiltIn.Sleep   ${sleep_time}
    ${result}    csn.read output    connection=${alias}
    Should contain   ${result}   ${serial_number}
    ${ue_status_info}   ${ue_status}   Should Match Regexp   ${result}   ${serial_number}\[\\s,\\t\]+(\\w+)
    [Return]   ${ue_status}

Connect ADB devices
    [Arguments]  ${alias}    ${serial_number}    ${sleep_time}=10s
    ${result}   Get UE device status   alias=${alias}   serial_number=${serial_number}   sleep_time=${sleep_time}
    should not contain  ${result}   connecting
    should not contain  ${result}   offline

Connect to ABIL by index
    [Documentation]  Author: He Jingmin
    ...              Description: this keyword can choose to connect to [ABIL1 ABIL2 ABIL3] with abil index input
    [Arguments]   ${abil_index}   ${asik_alias}   ${alias}
    Run Keyword If   ${abil_index}==${0}   Return From Keyword   ${asik_alias}
    ${abil_addr_end}   Evaluate   16+${abil_index}*4
    csn.Connect to   hostname=192.168.253.${abil_addr_end}    username=${asik_username}    password=${asik_passwd}
    ...   proxy=${asik_alias}   alias=${alias}
    [Return]   ${alias}

Verify if ue manager app is started
    [Documentation]    Author: Ding Binmei
    ...                Description: check if ue manager app is started
    ...                2021/09/23 Cui Lingxue: extend to compatible with NAA.
    [Arguments]    ${cpc_alias}    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${cmd_check_ue_manager_process}    Set variable
    ...    adb -s ${serial_number} shell ps -ef|grep -E "com.nokia.syve.uemanager.mobile|com.nokia.android.application"|grep -v "grep"
    csn.send_command    command=${cmd_check_ue_manager_process}    connection=${cpc_alias}    timeout=20
    sleep    1s
    ${output_check_ue_manager_process}    csn.read_output    connection=${cpc_alias}
    Should contain any    ${output_check_ue_manager_process}    uemanager    nokia.android.application

Start to capture adb log
    [Documentation]  Author: Ding Binmei
    ...              Description: 1. Clear adb log file
    ...                           2. Clear adb log on ue
    ...                           3. Capture adb log
    ...             Return adb log path on ue control pc
    [Arguments]     ${ue_index}=${0}    ${ue_adb_log_folder}=/tmp    ${cpc_alias}=cpc_${ue_index}    ${sleep_time_before_read_output}=${None}
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    ${cmd_delete_adb_log_files}    set variable  rm -f ${ue_adb_log_folder}/adb_log_ue_${ue_index}*.log
    csn.send_command     command=${cmd_delete_adb_log_files}    connection=${cpc_alias}
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    csn.read_output    connection=${cpc_alias}
    ${cmd_clear_adb_log}    set variable    adb -s ${serial_number} logcat -c -b main -b events -b radio -b system
    csn.send_command    command=${cmd_clear_adb_log}  connection=${cpc_alias}
    csn.read_output    connection=${cpc_alias}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${ue_adb_log_path}    Join path    ${ue_adb_log_folder}    adb_log_ue_${ue_index}_${timestamp}.log
    ${cmd_capture_adb_log}    Set variable    nohup adb -s ${serial_number} shell logcat -b all > ${ue_adb_log_path} 2>&1 &
    csn.send_command    command=${cmd_capture_adb_log}    connection=${cpc_alias}
    Log to console    INFO:Start to catch UE ADB log
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}
    [Return]    ${ue_adb_log_path}

Verify adb log capture process is started
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if adb log capturing process is started; if yes, keyword will pass, otherwise, fail
    ...              2020/3/16 Liu Zheng : add ue serial number
    [Arguments]     ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${cmd_is_adb_log_logcat_process_started}    Set variable    adb -s ${serial_number} shell ps -ef|grep logcat|grep -v 'grep'
    csn.send_command    command=${cmd_is_adb_log_logcat_process_started}    connection=${cpc_alias}
    ${output_is_adb_log_logcat_process_started}    csn.read_output    connection=${cpc_alias}
    Should contain    ${output_is_adb_log_logcat_process_started}    logcat -b all    msg=Logcat process is not found

Stop to capture adb log
    [Documentation]  Author: Ding Binmei
    ...              Description: Stop capture UE ADB log and save it.
    [Arguments]     ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Connect to control pc enhanced    ${ue_index}
    Verify adb log capture process is started    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    csn.send_command    command=adb kill-server logcat  connection=${cpc_alias}
    BuiltIn.sleep   1s
    csn.read_output    connection=${cpc_alias}
    ${is_process_started}    Run keyword and return status    Verify adb log capture process is started
    ...    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    Should not be true    ${is_process_started}    msg=Logcat process is not killed
    Log to console    INFO:Stop to catch UE ADB log
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Verify 5G attach passed from adb log
    [Documentation]  Author: Ding Binmei
    [Arguments]     ${adb_log_file_path}    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}    ${sleep_time_before_read_output}=${None}
    Connect to control pc enhanced    ${ue_index}
    csn.send_command    command=grep is5GConnected ${adb_log_file_path} |tail -1    connection=${cpc_alias}
    ${result}   Csn.read_output    connection=${cpc_alias}
    Should contain  ${result}  is5GConnected true
    should not contain  ${result}   is5GConnected false
    csn.send_command    command=grep ratType ${adb_log_file_path}    connection=${cpc_alias}
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result}   Csn.read_output    connection=${cpc_alias}
    Should contain  ${result}  ratType 5gnr
    Log to console    INFO:5G UE attach successfully
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Download uepc log on ue control pc
    [Documentation]    Author: Ding Binmei
    ...                Description: Collect ue pc log on ue control pc for debugging purpose
    [Arguments]     ${local_log_folder_on_ute}=${TS_CASE_LOG_PATH}    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Connect to control pc enhanced    ${ue_index}
    ${pyro_server_log_path}    Join path    ${tl.ues[${ue_index}].server_dir}    logs/ta_ue_uepc_local.log
    ${local_log_path}    Join path    ${local_log_folder_on_ute}    ta_ue_uepc_local.log
    csn.Download file    remote_path=${pyro_server_log_path}    local_path=${local_log_path}    connection=${cpc_alias}
    [Return]    ${local_log_path}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Download adb log to test pc
    [Documentation]    Author: Ding Binmei
    ...                Description: Download adb log to our test pc
    [Arguments]     ${adb_log_path_on_control_pc}    ${local_log_folder_on_ute}=${TS_CASE_LOG_PATH}
    ...             ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${adb_log_name}    Fetch from right    string=${adb_log_path_on_control_pc}    marker=/
    ${local_log_path}    Join path    ${local_log_folder_on_ute}    ${adb_log_name}
    Connect to control pc enhanced    ${ue_index}
    csn.Download file    remote_path=${adb_log_path_on_control_pc}    local_path=${local_log_path}    connection=${cpc_alias}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Power off on ue
    [Documentation]    Author: Ding Binmei
    ...                        Power off and on ue
    [Arguments]    ${ue_index}=${0}    ${ue_pdu_ip}=${UE0_PDU_IP}    ${ue_pdu_port}=${UE0_PDU_PORT}
    Log to console    Power off and on ue
    pdu.setup_pdu    model=facom   host=${ue_pdu_ip}    alias=ue_${ue_index}
    pdu.power_off    port=${ue_pdu_port}    pdu_device=ue_${ue_index}
    BuiltIn.Sleep    5s
    pdu.power_on    port=${ue_pdu_port}    pdu_device=ue_${ue_index}

Reboot ue via PB and start ue manager
    [Documentation]    Author: Ding Binmei
    ...                Description: reboot ue and start ue manager app
    [Arguments]    ${ue_index}=${0}    ${ue_pdu_ip}=${UE0_PDU_IP}    ${ue_pdu_port}=${UE0_PDU_PORT}
    Power off on ue    ue_index=${ue_index}    ue_pdu_ip=${ue_pdu_ip}    ue_pdu_port=${ue_pdu_port}
    BuiltIn.Sleep    30s
    wait until keyword succeeds    3min    5s    Start the uemanager App    ue_index=${ue_index}

Restart adb server and wait until status ready
    [Documentation]    Author: Ding Binmei
    ...                Description: Restart adb server in case adb command is abnormal
    [Arguments]     ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}    ${sleep_time_for_adb_devices}=3s
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}
    wait until keyword succeeds    3min    2s    Connect to control pc enhanced    ${ue_index}
    ${cmd_kill_server}    Set variable    adb -s ${serial_number} kill-server
    csn.send_command    command=${cmd_kill_server}    connection=${cpc_alias}
    ${kill_server_result}   csn.read_output    connection=${cpc_alias}
    Should be empty    ${kill_server_result}    msg=adb kill-server command executed with error
    BuiltIn.Sleep    1s
    ${cmd_start_server}    Set variable    adb -s ${serial_number} start-server
    csn.execute    command=${cmd_start_server}    connection=${cpc_alias}
    wait until keyword succeeds    3min    2s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    ...    sleep_time=${sleep_time_for_adb_devices}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Check 5G Rach Status
    [Documentation]    Author: Hao Xiaoxia
    [Arguments]    ${before}     ${before_time}    ${5Gstatus}=PASS    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${log_type}=journallog
    ...    ${log_loca}=l2lo
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                            hwcheck_index=${hwcheck_index}
    ...                                                                            log_type=${log_type}
    ...                                                                            log_loca=${log_loca}
    run keyword if     '${5Gstatus}'=='PASS'    verify 5G rach success    before=${before}     after=${5Grach_ing}
    ...                                         before_time=${before_time}    after_time=${5Grach_time_ing}
    run keyword if     '${5Gstatus}'=='FAIL'    verify 5G rach not success    before=${before}     after=${5Grach_ing}
    ...                                         before_time=${before_time}    after_time=${5Grach_time_ing}

UE attach and verify from adb log
    [Documentation]    Author: Ding Binmei
    ...                Description: ue attach and verify from adb log
    [Timeout]  5 min
    [Arguments]    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}    ${sleep_time_for_adb_devices}=3s
    ...    ${sleep_time_before_read_output}=${None}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${status}    Run keyword and return status    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    ...    sleep_time=${sleep_time_for_adb_devices}
    Run keyword if    ${status} == ${False}
    ...    Restart adb server and wait until status ready    ue_index=${ue_index}    sleep_time_for_adb_devices=${sleep_time_for_adb_devices}
    Ue detach with index    ue_index=${ue_index}
    ${adb_log_path}    Start to capture adb log    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    Ue attach with index    ue_index=${ue_index}
    Wait until keyword succeeds    1 min    1s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    ...    sleep_time_before_read_output=${sleep_time_before_read_output}
    Stop to capture adb log    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    Download adb log to test pc    adb_log_path_on_control_pc=${adb_log_path}    local_log_folder_on_ute=${local_log_folder}
    ...             ue_index=${ue_index}    cpc_alias=${cpc_alias}
    BuiltIn.sleep    1 sec
    Verify 5G attach passed from adb log     adb_log_file_path=${adb_log_path}    ue_index=${ue_index}
    ...    sleep_time_before_read_output=${sleep_time_before_read_output}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Retry ue attach if failed
    [Documentation]    Author: Ding Binmei
    ...                Description: try Attach ue with ${retry_time} times, if still failed will reboot ue then try attach again
    ...                ${is_pb_exist}: if ${True} and when ue attach failed will reboot ue via PB as WA
    ...                                if ${False}, then will restart adb server as WA when attach failed
    [Arguments]    ${ue_index}=${0}    ${retry_time}=5    ${is_pb_exist}=${True}    ${sleep_time_for_adb_devices}=3s
    ...    ${sleep_time_before_read_output}=${None}
    [Timeout]  20 min
    ${attach_status}    Run keyword and return status
    ...    wait until keyword succeeds    ${retry_time}x    1s    UE attach and verify from adb log    ue_index=${ue_index}
    ...    sleep_time_for_adb_devices=${sleep_time_for_adb_devices}    sleep_time_before_read_output=${sleep_time_before_read_output}
    Run keyword if    ${attach_status}==${False}
    ...    Log to console    First trial for attach failed, will reboot ue and retry for attach
    ...    ELSE    Return from keyword    ${attach_status}
    Run keyword if     ${is_pb_exist} == ${False}
    ...    Restart adb server and wait until status ready    ue_index=${ue_index}    sleep_time_for_adb_devices=${sleep_time_for_adb_devices}
    ...    ELSE    Reboot ue via PB and start ue manager    ue_index=${ue_index}
    UE attach and verify from adb log    ue_index=${ue_index}    sleep_time_for_adb_devices=${sleep_time_for_adb_devices}
    ...    sleep_time_before_read_output=${sleep_time_before_read_output}

Clear uepc log on ue control pc
    [Documentation]    Author: Wang Yixiang
    ...                Description: Clear ue pc log on ue control pc when log is too big, or else maybe cause UE lost connection
    ...                Jira ticket:https://jiradc.int.net.nokia.com/browse/TAUE-1186
    [Arguments]     ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Connect to control pc enhanced    ${ue_index}
    ${pyro_server_log_path}    Join path    ${tl.ues[${ue_index}].server_dir}    logs/ta_ue_uepc_local.log
    ${cmd_output}    ssh.execute    command=echo "" > ${pyro_server_log_path}    connection=${cpc_alias}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

UE PC SSH output Should Not Empty
    [Arguments]     ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Log    ${ue_index}_${cpc_alias}
    ${output}   csn.Read Output   connection=cpc_alias
    Should Not Be Empty   ${output}
    [Return]   ${output}

Kill QXDM process
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：kill QXDM.exe progress
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Kill QPST process
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：kill QPST.exe progress
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTConfig.exe    connection=cpc_${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Kill ClientMain process
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：kill clientMain.exe process
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM ClientMain.exe    connection=cpc_${ue_index}
    BuiltIn.sleep    1s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Get UE Airmode status
    [Documentation]  He Jingmin
    ...              Description: return the air mode status
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command   command=adb -s ${serial_number} shell settings get global airplane_mode_on   connection=cpc_${ue_index}
    ${mode_status}   csn.Read Output   connection=cpc_${ue_index}
    [Return]   ${mode_status.splitlines()[0]}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Is network mode as expected
    [Documentation]  Author: Ding Binmei
    ...    Validate if network mode is as expected; Retun values are True/False
    [Arguments]    ${exp_net_mode}    ${ue_index}=${0}    ${network_mode_switch_method}=${tl.ues[${ue_index}].network_mode_switch_method}
    ...    ${mobile_network_text}=Mobile network    ${setting_network_mode_text}=Preferred network type
    ${validate_status}    Run keyword and return status    ute_ue.validate_ue_info    UE_${ue_index}    PREFERRED_NET_MODE    ${exp_net_mode}
    ...    network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...    setting_network_mode_text=${setting_network_mode_text}
    [Return]    ${validate_status}

Change network mode on UE
    [Documentation]  Author: Ding Binmei
    ...    Supported network types: 'NR_only', 'NR_LTE', ..., (Should be align with UI display)
    ...    Return ${True} ${False} to indicate wheter network mode is updated
    ...    Based on ta_ue_android_plugin 1.37.0:
    ...    validate_net_mode_text, In Some UE version, ${net_mode} is different with ${validate_net_mode_text}, so added
    ...    validate_net_mode_text && setting_network_mode_text parameters: Newly added. These values should be the same with UI display.
    ...        Later will move to init file: https://jiradc.ext.net.nokia.com/browse/WROCAUTOCV-4352
    [Arguments]    ${net_mode}    ${validate_net_mode_text}    ${ue_index}=${0}
    ...    ${network_mode_switch_method}=${tl.ues[${ue_index}].network_mode_switch_method}
    ...    ${mobile_network_text}=${tl.ues[${ue_index}].mobile_network_text}
    ...    ${setting_network_mode_text}=${tl.ues[${ue_index}].setting_network_mode_text}
    ${is_network_mode_expected}    Is network mode as expected    exp_net_mode=${validate_net_mode_text}    ue_index=${ue_index}
    ...    network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...    setting_network_mode_text=${setting_network_mode_text}
    Run keyword if    ${is_network_mode_expected}==${False}    Run keywords    ute_ue.change_network_mode    UE_${ue_index}    ${net_mode}
    ...    network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...    setting_network_mode_text=${setting_network_mode_text}   AND
    ...    ute_ue.validate_ue_info    UE_${ue_index}    PREFERRED_NET_MODE    ${validate_net_mode_text}
    ...        network_mode_switch_method=${network_mode_switch_method}
    ...        mobile_network_text=${mobile_network_text}    setting_network_mode_text=${setting_network_mode_text}    AND
    ...    Log to console    Change network mode to ${net_mode} successfully
    ...    ELSE    Log to console    Network mode is as expected, no need to change
    ${is_network_mode_updated}    Set variable if    ${is_network_mode_expected}    ${False}    ${True}
    [Return]    ${is_network_mode_updated}

Switch prefer 5G NR mode
    [Documentation]  Author: Ding Binmei
    ...    This keyword is tested with QCOM UE, for other UE types, need to do additional adaption
    ...    ${5g_nr_mode}: specified the prefer 5g nr mode name e.g : 'NSA Mode', 'SA Mode', 'NSA + SA Mode'. Case sensitive
    ...    ${ui_version}: For QCOM it's ${EMPTY}, for other UE type like Huawei, need to fill with specific UI version
    [Arguments]    ${5g_nr_mode}    ${ue_index}=${0}   ${ui_version}=${EMPTY}    ${ue_alias}=UE_UI_${ue_index}
    android_ui.setup    ui_version=${ui_version}    host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    serial_number=${tl.ues[${ue_index}].serial_number}    alias=${ue_alias}
    android_ui.switch_network_mode    mode_name=${5g_nr_mode}    mobile=${ue_alias}
    [Teardown]    Run keyword and ignore error    android_ui.teardown    mobile=${ue_alias}
