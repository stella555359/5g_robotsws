*** Settings ***
Documentation
...  author: dalwang
...  contact: dali.wang@nokia-sbell.com
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.selenium.sbts    WITH NAME    selenium_coam
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot
Variables   ../../libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001545_AA/Resource/common_license.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB007040/Resource/7040_resource.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/collect_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Library     SSHLibrary
#Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ1/MP_OM/OM_MP_Resource.robot


*** Variables ***
&{fault_4459}    faultId=${4459}
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_6502}    faultId=${6502}
&{fault_7523}    faultId=${7523}
&{fault_7100}    faultId=${7100}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4655}   &{fault_4654}   &{fault_61652}   &{fault_61524}   &{fault_6502}
...               &{fault_7523}   &{fault_7100}
${TS_CASE_LOG_PATH}   ${OUTPUT_DIR}


*** Keyword ***
Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
    [Arguments]  ${swconfig_flag}=${False}
    log to console  \n***Common Suite Setup for COAM***
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    robot_common_operations.Common Suite Setup
    run keyword if   ${swconfig_flag}    upload swconfig and reboot gnb
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
#    Reboot UE For 7040
    ${gnb_release}     Get gnb release    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release}
    Run keyword if   '${gnb_release}'!='SBTS23R1'      Set Suite Variable    ${comma}   ,
    ...   ELSE    Set Suite Variable   ${comma}    ${EMPTY}

Common Suite Setup for COAM on UTE
#    COAM Create log directory    is_set_to_test_case_level=${False}
    [Arguments]  ${swconfig_flag}=${False}
    log to console  \n***CI_interface.Common Suite Setup for COAM on UTE***
    CI_interface.Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    robot_common_operations.Common Suite Setup
    run keyword if   ${swconfig_flag}    upload swconfig and reboot gnb
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
#    Reboot UE For 7040
    ${gnb_release}     Get gnb release    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release}
    Run keyword if   '${gnb_release}'!='SBTS23R1'      Set Suite Variable    ${comma}   ,
    ...   ELSE    Set Suite Variable   ${comma}    ${EMPTY}

7040 COAM Teardown gnb connections
    [Arguments]    ${connection}=COAM
    coam.teardown    connection=${connection}

Case Setup for 7040
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    set suite variable    ${gnb_release}
    ${action}    Create Dictionary  modal_name=Additional hardware detected   button=close
    ${action_list}    Create List  ${action}
#    ${version}   set variable if   '${gnb_release}'=='SBTS23R1'    23R1   ${None}
#    ${version}   set variable   ${gnb_release}
    ${gnb_release_for_7040}   Get gnb release for 7040    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release_for_7040}
    COAM WEBUI Login    version=${gnb_release_for_7040}    modal_action_configurations=${action_list}
    Run Keyword And Ignore Error   COAM WEBUI Whether Close Start Up View Window
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword And Ignore Error   Update Rad For BTSSyslog In AaShell Via SSHLibrary
    Wait Until Keyword Succeeds   3x   5s   Start BTS Log Collection
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}

Case Teardown for 7040
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    Siso Common Save Logs
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout

Case Teardown for 7040 steps
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    run keyword and ignore error    COAM Logout
    wait until keyword succeeds    10min   30s    COAM LOGIN    bts_host=${LMP_ADDR}
    wait until keyword succeeds    10min   30s    COAM SCF Commission
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error    Syslog Capture Stop and Collect
    run keyword if test failed    run keyword and ignore error    Save Snapshot logs On COAM    IP_WEBUI=${WEBUI_ADDR}
    run keyword if test failed    run keyword and ignore error    Screenshot for case fail
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
#    Save or Remove logs

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='SBTS22R2'     set variable   22R2
       ...   ELSE IF    '${gnb_release}'=='SBTS22R3'     set variable   22R3
       ...   ELSE IF    '${gnb_release}'=='SBTS22R4'     set variable   22R4
       ...   ELSE IF    '${gnb_release}'=='SBTS23R1'     set variable   23R1
       ...   ELSE IF    '${gnb_release}'=='SBTS23R2'     set variable   23R2
       ...   ELSE IF    '${gnb_release}'=='SBTS23R3'     set variable   23R3
       ...   ELSE IF    '${gnb_release}'=='SBTS23R4'     set variable   23R4
       ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE        set variable    22R2
       [Return]     ${scfname}

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}${/}qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}

Set GNB Oamtls Param
       ${return_oamtls}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...   filter_param=TLS usage towards the operation and maintenance system
    Run Keyword If   '${return_oamtls}'!='off'   selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=TLS usage towards the operation and maintenance system  new_value=off
    Validate and Activate Parameter
    CM Upload on NetAct Background

Check LSS Coam Account Exist
    csn.connect to   hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...   username=${tl.test_pc.default_ssh_connection_details.username}
    ...   password=${tl.test_pc.default_ssh_connection_details.password}   alias=lss
    ${coamaccount}   csn.execute   command=getent passwd coam    connection=lss
    ${coamexist}   run keyword and return status   should contain   ${coamaccount}   coam
    csn.execute   command=echo "coam:zO&n1W*ktp7" |sudo chpasswd    connection=lss
    set suite variable    ${coamexist}
    csn.disconnect   connection=lss
    [Return]     ${coamexist}

Create LSS Coam Account
    csn.connect to   hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...   username=${tl.test_pc.default_ssh_connection_details.username}
    ...   password=${tl.test_pc.default_ssh_connection_details.password}   alias=lss
    csn.execute   command=sudo useradd -m coam    connection=lss
    csn.execute   command=echo "coam:zO&n1W*ktp7" |sudo chpasswd    connection=lss
    csn.execute   command=sudo chmod a+w /home/coam    connection=lss
    csn.disconnect   connection=lss

Remove LSS Snapshot
    csn.connect to   hostname=${LSS_Server_ip}   username=${LSS_Server_Username}    password=${LSS_Server_Password}    alias=lss
    csn.execute   command=cd /home/coam/;rm -rf Snapshot_MRBTS-${MRBTS_ID}_*   connection=lss
    csn.disconnect   connection=lss

Remove Netact Snapshot
    csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
    ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;rm -rf Snapshot_MRBTS-${MRBTS_ID}_*   connection=Netact
    csn.disconnect    connection=Netact

Config LSS Server on WebEM
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Diagnostic Snapshot destination
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Local symptoms server configuration
    sleep    2s
    Validate and Activate Parameter
    wait until keyword succeeds   3x  15s    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Diagnostic Snapshot destination
    ...                                new_value=lss
    run keyword and ignore error     selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Local symptoms server configuration   timeout=${100}
    sleep    2s
    wait until keyword succeeds   3x  15s    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP address
    ...                                new_value=${LSS_Server_ip}
    wait until keyword succeeds   3x   15s    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP port number
    ...                                new_value=${LSS_Server_Port_Num}
    Validate and Activate Parameter
#    Check Fault 4459 Clear Status
    Remove LSS Snapshot

Config Netact Server on WebEM
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Diagnostic Snapshot destination
    ...                                new_value=netact
    Validate and Activate Parameter

Check Snapshot Upload to LSS Status
    [Arguments]   ${snapshot}=${true}
    csn.connect to    hostname=${LSS_Server_ip}   username=${LSS_Server_Username}   password=${LSS_Server_Password}    alias=lss
    ${Snapshot_Output}   csn.execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${MRBTS_ID}_*   connection=lss
    Run Keyword If   ${snapshot}   Should Not Be Empty   ${Snapshot_Output}
    ...   ELSE   Should Be Empty   ${Snapshot_Output}
    csn.disconnect    connection=lss


Validate and Activate Parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120

Check Snapshot Upload to Netact
    csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
    ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;ls -al | grep "Snapshot_MRBTS-${MRBTS_ID}_*"   connection=Netact
    Should Not Be Empty   ${Snapshot_Output}
    csn.disconnect    connection=Netact


Wait for Cell Onair
    [Arguments]   ${wait_timer}   ${cell_index}
    ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
    ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   selenium_coam.refresh_page
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if  not ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically

Syslog Capture Start
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_start
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Syslog Capture Stop and Collect
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_stop
    run keyword and ignore error    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}


__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    Run  rm -rf ${OUTPUTDIR}/5GC*

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME}/BTSlog ]; then mkdir ${LOG_PATH}/${TESTNAME}/BTSlog; else rm ${LOG_PATH}/${TESTNAME}/BTSlog/*; fi
    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG.LOG ${LOG_PATH}/${TESTNAME}/BTSlog/SYSLOG.LOG
    Run   rm -rf ${OUTPUTDIR}/5GC*

Print BTSlog
    [Arguments]    ${message_name}=BbPoolingRacAlgorithmCommon.cpp    ${bts_logs_path}=/tmp/btslog2
    log to console    check btslog
    ${message} =    OperatingSystem.Grep File    ${bts_logs_path}    ${message_name}
    log to console   ${message}
    [Return]      ${message}

Add SWRESETREQ-1
    [Arguments]    ${Reset_command}
    Run Keyword And Ignore Error    selenium_coam.remove_object   object_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1
    Run Keyword And Ignore Error    Validate and Activate Parameter
    selenium_coam.add_object
    ...     object_name=MRBTS-${MRBTS_ID}/MNL-1
    ...     object_class_name=CMD
    ...     id_value=1
    ...     is_load_default_values=true
#    selenium_coam.refresh
    selenium_coam.add_object
    ...     object_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1
    ...     object_class_name=SWRESETREQ
    ...     id_value=1
    ...     is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/SWRESETREQ-1
    ...  filter_param=Software reset command level    new_value=${Reset_command}
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Case Teardown Steps
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login   bts_host=192.168.255.129
    COAM SCF Commission
    Case Teardown

Check History File Content
    ${ret}    coam.Get Snapshot History    ${OUTPUT_DIR}/${TEST_NAME}/Snapshot_history.log    connection=COAM
	Should Be Equal As Strings    ${ret}    Success
    ${Snapshot_history}    Run    cat ${OUTPUT_DIR}/${TEST_NAME}/Snapshot_history.log
    ${date} 	Get Current Date
    ${date}    fetch from left    ${date}    ${SPACE}
#    ${checkstr1}    set variable
#    ...   "trigger_reason":"PowerReset","coverage_level":"Full","failed_reason":"PowerReset","snapshot_result":"cancel"
    ${checkstr2}    set variable    "trigger_reason":"PowerReset","coverage_level":"Full","snapshot_result":"success"
    ${checkstr3}    set variable   "snapshot_result":"fail"
#    check_info_in_file    filepath=${OUTPUT_DIR}/${TEST_NAME}/Snapshot_history.log   str=${checkstr1}    datestr=${date}
    check_info_in_file    filepath=${OUTPUT_DIR}/${TEST_NAME}/Snapshot_history.log   str=${checkstr2}    datestr=${date}
    #${status}   run keyword and return status     check_info_in_file
    #...    filepath=${OUTPUT_DIR}/${TEST_NAME}/Snapshot_history.log   str=${checkstr3}    datestr=${date}
    #should not be true   ${status}

Collect Snapshot COAM
    [Timeout]   30m
    [Arguments]   ${local_file_path}=None   ${connection}=COAM
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/snapshot_coam_${curr_data}.zip
    ...   ${true}   ${local_file_path}
    Run Keyword And Ignore Error   coam.collect_snapshot   target_file_name=${local_file_path}   timeout=${2100}   connection=${connection}
    [Return]   ${local_file_path}

cancel snapshot with power reset
    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${True}
    Should Be Equal    ${status}    ${true}
    selenium_coam.cancel_snapshot_with_power_reset    timeout=120

upload swconfig and reboot gnb
    log to console   ***begin upload swconfig and reboot gnb!***
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    Upload Swconfig File
    ...   swconfig_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline}/swconfig.txt
    COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
    log to console   ***upload swconfig and reboot gnb finished!***
    [Teardown]   COAM Logout

Reboot UE For 7040
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    ue_reboot
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Get gnb release for 7040
    [Documentation]   Get gnb release version from TargetBD file
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${gnb_release_for_7040}   Set Variable   ${info.split('_')[1]}
    [Return]    ${gnb_release_for_7040}
    [Teardown]   csn.Disconnect   connection=release_info

Validate IP Reachability from Test PC 7040
    [Arguments]  ${ip_addr}  ${exp_status}
    ${ipv6}  run keyword and return status   should contain   ${ip_addr}  :
    ${output}   run keyword if  '${ipv6}' == 'True'
    ...    RUN    sudo ping6 ${asik_addr} -c 3
    ...    ELSE   RUN    sudo ping ${ip_addr} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    ${status}  set variable if   '${output}'== '0'   ${True}   ${False}
    should be equal   ${exp_status}   ${status}

Update Rad for BTSSyslog in AaShell via SSHLibrary
    [Documentation]  Update Rad for BTS Syslog Collection via telnet
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    Log To Console   Update RaD for BTSSyslog in AaShell Starting ...
    SSHLibrary.open connection  ${host}
    SSHLibrary.Login  ${username}  ${password}
#   ${sm_ip}  Set Variable If  ${is_rfSharing}  192.168.255.5  192.168.255.1
    ${smod_local_ip}  Set Variable   127.0.0.1
    # Connect to AaShell
    SSHLibrary.Write  telnet ${smod_local_ip} 15007
    SSHLibrary.Read until  AaShell>
    # update AasyslogUdpport and AasyslogUdpAddress in Aashell
    SSHLibrary.Write  rad -w 0x10041 5
    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
    SSHLibrary.Write  rad -w 0x10042 0xC0A8FF7E
    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
    SSHLibrary.Write  rad -w 0x10043 0xC738
    ${output}    wait until keyword succeeds  2x  3s  SSHLibrary.Read until    AaShell>
    SSHLibrary.Write  quit
    SSHLibrary.read until  ~ >
    Log To Console    Update RaD for BTSSyslog in AaShell Done!
    [Teardown]  Run Keyword And Ignore Error    SSHLibrary.Close Connection

Common Case Setup for 7040
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    set suite variable    ${gnb_release}
    ${action}    Create Dictionary  modal_name=Additional hardware detected   button=close
    ${action_list}    Create List  ${action}
#    ${version}   set variable if   '${gnb_release}'=='SBTS23R1'    23R1   ${None}
#    ${version}   set variable   ${gnb_release}
    ${gnb_release_for_7040}   Get gnb release for 7040    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release_for_7040}
    COAM WEBUI Login    version=${gnb_release_for_7040}    modal_action_configurations=${action_list}
    Run Keyword And Ignore Error   COAM WEBUI Whether Close Start Up View Window
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword And Ignore Error   Update Rad For BTSSyslog In AaShell Via SSHLibrary
    Wait Until Keyword Succeeds   3x   5s   Start BTS Log Collection
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}

Common Case Teardown for 7040
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    Siso Common Save Logs
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

CB010547 Case Setup For 7040
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    set suite variable    ${gnb_release}
    ${action}    Create Dictionary  modal_name=Additional hardware detected   button=close
    ${action_list}    Create List  ${action}
#    ${version}   set variable if   '${gnb_release}'=='SBTS23R1'    23R1   ${None}
#    ${version}   set variable   ${gnb_release}
    ${gnb_release_for_7040}   Get gnb release for 7040    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release_for_7040}
    COAM WEBUI Login    version=${gnb_release_for_7040}    modal_action_configurations=${action_list}
    Run Keyword And Ignore Error   COAM WEBUI Whether Close Start Up View Window
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword And Ignore Error   Update Rad For BTSSyslog In AaShell Via SSHLibrary
    Wait Until Keyword Succeeds   3x   5s   Start BTS Log Collection
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}

CB010547 Case Teardown For 7040
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    Siso Common Save Logs
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    CI_interface.Common Case Teardown
