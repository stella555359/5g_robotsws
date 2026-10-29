*** Settings ***
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.pdu    WITH NAME    pdu
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    String
Library    Collections
Library           DateTime
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/gnb_handler.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot

*** Variables ***
${TAF_ADDR}      ${tl.test_pc.default_ssh_connection_details.addr}
${TAF_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${TAF_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
#${pre_disk_msg}   //*[@id="frmTaskDetails:dtProgressInner:4:4:colMessage"]
${pre_disk_msg}   //*[@id="frmTaskDetails:pgpDtProgress"]
${precheck_xpath}    //*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[4]/td/label
${postcheck_xpath}   //*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[8]/td/label
${download_xpath}   //*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[3]/td/label
${networkoperationstatus_xpath}   //*[@id="TView:TTable:0:0:colTasksStatus"]
${Exp_Fault}    30

*** Keywords ***
Preventing_BTS_OAM_outage_in_BTS_SW_upgrade
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_OAM-325
    ...
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Backlog ID:** FCA_ST_OAM-325
    ...  *****************
    ...  The purpose of this TC is check if verifiy basic functionality of CB007944 on 5gClassicalBTS
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.03.2022 - First case draft created

    Step 1: Enable stb write permission
    Step 2: Log file removed while precheck request recieved
    Step 3: SW precheck and downlaod when no enough space in passive partition
    Step 4: SW download when enough space in passive partition
    Step 5: SW activation when no enough space in passive partition
    Step 6: SW activation when enough space in passive partition



Step 1: Enable stb write permission
    Log to console   To enable /ffs/stb write
    Check If Precheck or Postcheck Succeeded   input_status=OK

Step 2: Log file removed while precheck request recieved
    Log to console   Precheck reomve /ffs/stb/logs
    Fill Dummy Log File to BTS
    Check If Precheck or Postcheck Succeeded   input_status=OK
    ${if_log_removed}   Check if Log Existed
    should be equal   ${if_log_removed}   ${True}

Step 3: SW precheck and downlaod when no enough space in passive partition
    Log to console   Precheck and Download failed when no enough spacce in passive partition
    Fill Dummy File to BTS   fill_path=/ffs/stb   size=${60}   file_no=${1}
    Check If Precheck or Postcheck Succeeded   input_status=NOK
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger SW Download from NetAct    exp_status=Failed
    ...   ELSE    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    Wait Until Keyword Succeeds   5 min   10 s   Fault 30 Reported    ${Exp_Fault}

Step 4: SW download when enough space in passive partition
    Log to console   SW update can be proceeded when enough space;Download will remove /ffs/stb/logs
    Remove Dummy File
    Fill Dummy Log File to BTS
#    Check If Precheck or Postcheck Succeeded   input_status=OK
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger SW Download from NetAct    exp_status=Successful
    ...   ELSE    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    ${if_log_removed}   Check if Log Existed
    should be equal   ${if_log_removed}   ${True}

Step 5: SW activation when no enough space in passive partition
    Log to console   Activation failed while passive partition with no enough space
    Fill Dummy File to BTS   fill_path=/ffs/stb   size=${60}   file_no=${1}
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Activation   taget_version=${upgrade_version}
    Wait Until Keyword Succeeds   5 min   10 s   Fault 30 Reported    ${Exp_Fault}

Step 6: SW activation when enough space in passive partition
    Log to console   Activation succeeded after Dummy file removed
    Remove Dummy File
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Provision  taget_version=${upgrade_version}
    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   both   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}

Suite Setup Steps
    [Arguments]    ${webui_tool}=COAM    ${upgrade_tool}=netact
    Check running nms mode
    Get Available Space on Test PC
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    ${bts_id}   convert to string   ${MRBTS_ID}
    Remove Planned Space
    Set gNB SW version and Release
    Switch to source build
    set suite variable    ${bts_id}
    set suite variable   ${input_btsname}    MRBTS-${bts_id}
    Get Disk Space at Beginning

Suite Teardown Steps
    run keyword and ignore error   Remove logs on TAF


Test common setup
    [Arguments]     ${upgrade_tool}=netact   ${webui_tool}=COAM   ${action}=upgrade
    Switch to source build
    Check gNB memory
    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus


Test common teardown
    run keyword if test passed    run keyword and ignore error    Stop And Remove BTS LOG Collection On Gnb And Rus
    run keyword if test failed   Save btslog and snapshot if case failed
    run keyword and ignore error    Remove Dummy File


Save btslog and snapshot if case failed
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    run keyword and ignore error    Stop And Download And Remove BTS LOG Collection On Gnb And Rus    dir=${OUTPUT_DIR}/${TEST_NAME}
    run keyword and ignore error    Screenshot for COAM     dir=${OUTPUT_DIR}/${TEST_NAME}
    run keyword and ignore error    Get Alarm Sreenshot in COAM    dir=${OUTPUT_DIR}/${TEST_NAME}
    run keyword and ignore error    Save Snapshot logs    dir=${OUTPUT_DIR}/${TEST_NAME}

Save Snapshot to TAF
    log to console    Save Snapshot logs
    ${curr_data}    Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    set suite variable     ${snapshot_path}    ${OUTPUT_DIR}/${TEST_NAME}/snapshot_${curr_data}.zip
    run keyword    Debug Catch snapshot COAM    snapshot_path=${snapshot_path}    http=${LMP_ADDR}

Stop btslog
    [Arguments]  ${name}=btslog
    run keyword and ignore error   Collect_logs    names=${name}

Remove logs on TAF
    FOR   ${ru}   IN   @{rus}
       run keyword and ignore error   Stop btslog
       ${connection_taf}=  csn.connect_to    hostname=${ru['ctrl_addr']}    username=${ru['ctrl_username']}
    ...   password=${ru['ctrl_password']}    alias=taf
       run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/btslog_${ru['ctrl_addr']}.tar   connection=taf
       run keyword and ignore error   csn.Execute    command=ll /tmp/btslog2/;rm -rf /tmp/btslog2/*   connection=taf
       csn.disconnect    connection=taf
    END

Dwonload Btslog to TAF
    [Arguments]  ${taf_ip}   ${taf_user}   ${taf_pw}
    ${connection_taf}=  csn.connect_to    hostname=${taf_ip}    username=${taf_user}    password=${taf_pw}    alias=taf
    run keyword and ignore error   csn.Execute    command=cd /tmp/btslog2;tar -cvf btslog_${taf_ip}.tar SYSLOG*   connection=taf
    run keyword and ignore error   csn.Download File    remote_path=/tmp/btslog2/btslog_${taf_ip}.tar
    ...    local_path=${OUTPUT_DIR}/btslog_${taf_ip}.tar   connection=taf
    sleep   3s
    csn.disconnect    connection=taf

Check Site Status
     Log To Console  Coam Check Site Status
     gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     run keyword and continue on failure    Check ASIK Status Coam
     run keyword and continue on failure    Check ABIL Status Coam
     run keyword and continue on failure    Check RU Status Coam
     run keyword and continue on failure    common.Get Cell Status Coam
     [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Start BTS LOG Collection
    log to console    Start BTS LOG Collection On Gnb And Rus
    FOR   ${ru}   IN   @{rus}
       ${status}   run keyword and return status   Create Btslog log collection on remote machine for UUF
    ...   host=${ru['ctrl_addr']}    user=${ru['ctrl_username']}    password=${ru['ctrl_password']}
       run keyword if  not ${status}   Log   start btslog collection failed on ${ru['ctrl_addr']}   WARN
    END

Netact Trigger SWM Precheck or Postcheck
    [Documentation]  NetAct Precheck opereration.
    [Arguments]    ${taget_version}   ${operation}   ${input_btsname}=${input_btsname}
    ...   ${netact_url}=${netact_url}   ${netact_account}=${netact_account}   ${netact_pwd}=${netact_pwd}
    log to console    NetAct SWM Precheck or Postcheck
    ${is_common}   run keyword and return status   should contain   ${taget_version}   SBTS
    ${is_commontrunk}   run keyword and return status   should contain   ${taget_version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${taget_version}    _    1
    ${version_name}   run keyword if   ${is_commontrunk}   set variable   ${commonBuild_trunk}_${commontrunk_version}[1]
    ...   ELSE   set variable if   ${is_common}   ${taget_version}   AirScale-${taget_version}
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    sleep    10s
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    Select Operation in Newtask    operation=${operation}
    ${provisionradio_xpath}    netact_find_and_replace    xpath_ori=//*[@title="Version ID: ${version_name}"]   attr_text=id
    ...   replace_ori=swpackName    replace_dest=radioSelectSWPackage_:0
    selenium_netact.select_radio    radio_xpath=//*[@id="${provisionradio_xpath}"]
    netact_click_button    xpath=${provisionfinish_xpath}  #click finish button
    ${if_chen}    run keyword and return status    should contain any    ${netact_url}    gansu   qin   sui   han    chen
    ${topdisplay}    run keyword if    ${if_chen}    set variable    ${topdisplay_xpath_chen}
    ...    ELSE    set variable    ${topdisplay_xpath}
    netact_click_button    xpath=${topdisplay}
    selenium_netact.wait_for_visibility    elem_xpath=${networkoperationstatus_xpath}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Netact Check Precheck or Postcheck Status
    [Arguments]  ${operation_xpath}   ${exp_status}=OK
    log to console  Check Netact Precheck or Postcheck Status
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_network_operations
    sleep  10s
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
#    ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[4]/td/label
    ...   checkbox_xpath=${operation_xpath}
    netact_click_button   xpath=${task_apply_button}
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
    wait until keyword succeeds  2min   30s   WA for Filter MO
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${networkoperationstatus_xpath}
    sleep  5s
    ${disk_text}   wait until keyword succeeds   5 times   5s  selenium_netact.get_elem_text   elem_xpath=${pre_disk_msg}
    run keyword if    '${exp_status}'=='OK'    should contain   ${disk_text}   Enough disk space to perform SW upgrade
    ...   ELSE   should contain    ${disk_text}   Not enough disk space to perform SW upgrade
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Fill Dummy File to No Enough Space
    [Arguments]  ${upgrade_version}
    FOR  ${i}  IN RANGE  ${5}
        ${run_space}   ${stb_space}   Check Disk space
        run keyword if   ${${stb_space[:-1]}} > ${1}   run keywords   Check If Precheck or Postcheck Succeeded   input_status=NOK
        ...   AND   run keyword if  ${precheck_status}   exit for loop
        ...   AND   Fill Dummy File to BTS    fill_path=/ffs/stb   size=150   file_no=${i}
    END

Fill Dummy File to BTS
    [Arguments]  ${fill_path}    ${size}   ${file_no}
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute   command=dd if=/dev/zero of=${fill_path}/test${file_no} bs=100M count=${size}  timeout=150   connection=gnb
    csn.disconnect    connection=gnb

Fill Dummy Log File to BTS
#    ${if_logs_exist}   csn.execute   command=cd /ffs/stb;ls -l |grep logs
    ${log_not_exist}   Check if Log Existed
    run keyword if   ${log_not_exist}   run keywords   csn.Connect to   hostname=${asik_addr}   username=${asik_username}
    ...   password=${asik_password}   alias=gnb
    ...   AND   csn.execute   command=mkdir /ffs/stb/logs;dd if=/dev/zero of=/ffs/stb/logs/test bs=100M count=60  timeout=150   connection=gnb
    ...   AND   csn.disconnect    connection=gnb

Check if Log Existed
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${if_logs_exist}   csn.execute   command=cd /ffs/stb;ls -l |grep logs   connection=gnb
    ${log_not_exist}   run keyword and return status   should be empty   ${if_logs_exist}
    csn.disconnect    connection=gnb
    [Return]  ${log_not_exist}

Check If Precheck or Postcheck Succeeded
    [Arguments]  ${input_status}
    run keyword if    '${NMS_TYPE}'=='netact'    Netact Trigger SWM Precheck or Postcheck
    ...   operation=Precheck   taget_version=${upgrade_version}
    Sleep   45 s
    ${precheck_status}   run keyword and return status   Netact Check Precheck or Postcheck Status
    ...   operation_xpath=${precheck_xpath}  exp_status=${input_status}
 #   set test variable   ${precheck_status}
    should be true   ${precheck_status}

Remove Dummy File
    ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute   command=rm -rf /ffs/stb/test*    timeout=60   connection=gnb
    csn.disconnect    connection=gnb

Fault 30 Reported
    [Arguments]  ${exp_fault}
     gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault}
     ${fault_exist}   UUF_common.find_value_in_list   check_list=@{return_active_alarm}   check_key=faultId   check_value_list=${exp_fault}
     should be equal   ${fault_exist}   ${True}

Trigger SW Download from NetAct
    [Arguments]  ${exp_status}
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Download
    should contain any    ${operation_status}   ${exp_status}
