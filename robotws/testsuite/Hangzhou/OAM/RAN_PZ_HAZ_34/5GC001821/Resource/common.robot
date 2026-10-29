*** Settings ***
Documentation
    ...    Author: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library   OperatingSystem
Library   Collections
Library   XML    True
Variables   ../../libraries/global_vars.py
Variables   ../Library/config_vars.py
Resource   ../../common/taf_env.robot
Resource   ../../common/L3_Call.robot
Resource   ./coam.robot
Resource   ./CPRI.robot
Library   taf.pdu   WITH NAME   pdu
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Library    taf.analyzer.pcap     WITH NAME    cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot

*** Variables ***
#${ue_type}    huawei
${DL_THRESHOLD_100}   50833
${DL_THRESHOLD_80}   40147
${DL_THRESHOLD_UNIT}   K
${UL_THRESHOLD_100}   5978
${UL_THRESHOLD_80}   4836
${UL_THRESHOLD_UNIT}   K
${cell_e}   16388
${single_RMOD_index}   1
@{link_adapt_flag}   0x580011   0x580012   0x580013   0x580014
${link_adapt_open}   1
${link_adapt_close}   0
${TS_CASE_LOG_PATH}   ${OUTPUT_DIR}
${iperf_port}      ${tl.ues[0].iperf_details.port}
${lua_script_path}   /home/ute/luashark_script/generated_luashark/luashark.lua
&{fault_4459}    faultId=${4459}
&{fault_4654}    faultId=${4654}
&{fault_4655}    faultId=${4655}
&{fault_61524}    faultId=${61524}
&{fault_61652}    faultId=${61652}
&{fault_61649}    faultId=${61649}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4654}   &{fault_4655}   &{fault_61524}   &{fault_61652}   &{fault_61649}
&{siso_fault}   faultId=${4681}
&{siso_fault_T088}   faultId=${4656}
&{siso_fault_T289}   faultId=${4293}


*** Keywords ***
Suite Setup Steps
    robot_common_operations.Common Suite Setup
#    Create_Btslog_log_collection_on_testvm
#    Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs sudo kill -9
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Setup Steps For 2034A
    [Arguments]  ${swconfig_flag}=${True}
    CI_interface.Common Suite Setup
    run keyword if   ${swconfig_flag}    upload swconfig and reboot gnb
    robot_common_operations.Common Suite Setup
    Case Setup for 842
    Log to console   import scf for 2034A-8D4U SISO cases
    Import SCF by Custom for 842
    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_8DL4UL.xml
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Setup Steps For 2034B
    [Arguments]  ${swconfig_flag}=${True}
    CI_interface.Common Suite Setup
    run keyword if   ${swconfig_flag}    upload swconfig and reboot gnb
    robot_common_operations.Common Suite Setup
    Case Setup for 842
    Log to console   import scf for 2034B-4D4U SISO cases
    Import SCF by Custom for 842
    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_4DL4UL.xml
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Setup Steps For 2035D
    robot_common_operations.Common Suite Setup
    Log to console   import scf for 2035D-8D4U SISO cases
    Case Setup for 842
    Import SCF by Custom for 842
    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL842_2035D_${scfname}.xml
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Setup Steps For 2035G
    robot_common_operations.Common Suite Setup
    Log to console   import scf for 2035G-4D2U SISO cases
    Case Setup for 842
    Import SCF by Custom for 842
    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL842_2035G_${scfname}.xml
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Teardown Steps
#    ${log_path}   Collect_logs   name=btslog
#    Run Keyword If All Tests Passed   Remove File   ${log_path}
#    ...   ELSE   Move File   source=${log_path}   destination=${OUTPUT_DIR}
    Connect to gnb coam via ssl
    ${allowed_faults}   Create List   @{ALLOWED_FAULT}   ${siso_fault}   ${siso_fault_T088}   ${siso_fault_T289}
    Wait Until Keyword Succeeds   2m   30s   Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    COAM Teardown gnb connections
    Log to console   close btslog
    robot_common_operations.Common Suite Teardown

SISO Common Setup
    robot_common_operations.Common Case Setup
    COAM Login
    ${var_status}   ${ci_var_dict}   CI_commssion._Set Variables For Test   gnb_index=${0}, du_index=${0}, common_unit_index=${0}
    CI_commssion.All Hw Should Be Detected   testline=${var_dict}[testline]   build=${var_dict}[build]
    ...   stream=${var_dict}[stream]   ute_env=${var_dict}[ute_env]   connection=COAM
    COAM WEBUI Login
    ${errors}   Validate Plan and Return Error
    Should Be True   ${errors[0]}==0

SISO Common Teardown
    ${allowed_faults}   Create List   @{ALLOWED_FAULT}   ${siso_fault}   ${siso_fault_T088}   ${siso_fault_T289}
    Wait Until Keyword Succeeds   2m   30s   Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Run Keyword If Test Failed   Catch Snapshot COAM   local_file_path=${OUTPUT_DIR}
    COAM WEBUI Logout
    COAM Logout
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown

Set L3Call CELLID
    ${L3CALL_cellid}   Set Variable If
    ...   '${tl.gnbs[0].global_bts_id}' in ${L3CALL_CELL}   ${L3CALL_CELL["${tl.gnbs[0].global_bts_id}"]}
    ...   '${tl.gnbs[0].global_bts_id}' not in ${L3CALL_CELL}   2
    Set Suite Variable   ${L3CALL_cellid}

Check gNB restarted
    Wait Until Keyword Succeeds   15m   30s   gNB not Connected
    ${before}   DateTime.Get Current Date
    Wait until keyword succeeds  10min   1min   COAM Login
    ${after}   DateTime.Get Current Date
    ${interval}   DateTime.Subtract Date From Date   ${after}   ${before}
    Wait Until Keyword Succeeds   10m   60s   COAM Check All Cells Onair
    Should Be True   ${interval} > ${30}

Case Setup for 842
    robot_common_operations.Common Case Setup
    [Documentation]   Setup WEBUI login and start btslog collection
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}
    #run keyword and ignore error   Start BTS Log Collection
    #DO NOT CLOSE FIREFOX AFTER WEBUI LOGIN HERE

Case Teardown for 842
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    run keyword and ignore error    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if test failed    run keyword and ignore error    Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
    Run Keyword If Test Failed   Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout
    Connect to gnb coam via ssl
    ${allowed_faults}   Create List   @{ALLOWED_FAULT}   ${siso_fault}   ${siso_fault_T088}   ${siso_fault_T289}
    Wait Until Keyword Succeeds   2m   30s   Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    CI_interface.Common Case Teardown

Import SCF by Custom for 842
    [Arguments]   ${local_path}
    log to console    import scf
    Import SCF and Wait to onair   ip_addr=${asik_addr}   SCF_FILE=${local_path}
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout    display=${${DEBUG}}

Import SCF and Wait to onair
    [Arguments]   ${ip_addr}   ${SCF_FILE}
    coam.Import SCF On COAM   IP_WEBUI=${ip_addr}  SCF_FILE=${SCF_FILE}
    Wait Until Keyword Succeeds   10m   30s   Try Connect gNB    gnb_addr=${ip_addr}
    Wait until keyword succeeds  10min   1min   COAM Login
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
       [Return]     ${scfname}

Load SCF by Feature
    [Arguments]    ${feature}=2035-D
    Case Setup for 842
    Import SCF by Custom for 842
    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${feature}_${scfname}.xml
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout

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
