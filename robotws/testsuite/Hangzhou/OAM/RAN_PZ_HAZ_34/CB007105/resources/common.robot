*** Settings ***
Documentation
    ...    Author: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com
Resource   testsuite${/}Hangzhou${/}resources${/}RAN_PZ_HAZ_34${/}robot${/}android_common_keyword.robot
Resource   testsuite${/}Hangzhou${/}resources${/}RAN_PZ_HAZ_34${/}robot${/}coam_gnb_classical.robot

Library   OperatingSystem
Library   XML    True
Variables   ..${/}..${/}libraries${/}global_vars.py
Variables   ..${/}library${/}config_vars.py
Resource   ..${/}..${/}common${/}taf_env.robot
Resource   ..${/}..${/}common${/}L3_Call.robot
Resource   ..${/}..${/}common${/}gnb.robot
Library   taf.pdu   WITH NAME   pdu
Library   taf.selenium.sbts    WITH NAME    selenium_coam
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Library    taf.analyzer.pcap   WITH NAME    parser
Resource    testsuite${/}Hangzhou${/}resources${/}RAN_PZ_HAZ_34${/}robot${/}power_ue${/}power_ue.robot
Resource    testsuite${/}Hangzhou${/}resources${/}RAN_PZ_HAZ_34${/}robot${/}at_ue_common_keyword.robot
Resource   testsuite${/}Hangzhou${/}resources${/}RAN_PZ_HAZ_34${/}robot${/}CI_Operations${/}CI_interface.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

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
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_6502}    faultId=${6502}
&{fault_7523}    faultId=${7523}
&{fault_7100}    faultId=${7100}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4655}   &{fault_4654}   &{fault_61652}   &{fault_61524}   &{fault_6502}
...               &{fault_7523}   &{fault_7100}
${DEBUG}   false
${nrbts_id}=    NRBTS-${tl.gnbs[0].instance_id}
${BTS_ID}=    ${tl.gnbs[0].global_bts_id}
${plan_copy_from}=   CURRENT_BTS_CONF-1


*** Keywords ***
Suite Setup Steps
#    Create_Btslog_log_collection_on_testvm
#    Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs sudo kill -9
    COAM Login
    COAM Backup SCF
    Log to console   ready for btslog
    Set L3Call CELLID

Suite Teardown Steps
#    ${log_path}   Collect_logs   name=btslog
#    Run Keyword If All Tests Passed   Remove File   ${log_path}
#    ...   ELSE   Move File   source=${log_path}   destination=${OUTPUT_DIR}
    Check Extra Reset From Blackbox
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   2m   30s     Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    COAM SCF Commission   connection=GNB_OAM
    COAM Teardown gnb connections
    Log to console   close btslog
    run keyword and ignore error    COAM Logout

Case Setup
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}
    #run keyword and ignore error   Start BTS Log Collection
    #DO NOT CLOSE FIREFOX AFTER WEBUI LOGIN HERE

Case Teardown
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if test failed    run keyword and ignore error    Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   2m   30s     Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    CI_interface.Common Case Teardown

Case Teardown for ABIP
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    run keyword and ignore error   COAM Logout
    CI_interface.Common Case Teardown

Set L3Call CELLID
    ${L3CALL_cellid}   Set Variable If
    ...   '${tl.gnbs[0].global_bts_id}' in ${L3CALL_CELL}   ${L3CALL_CELL["${tl.gnbs[0].global_bts_id}"]}
    ...   '${tl.gnbs[0].global_bts_id}' not in ${L3CALL_CELL}   2
    Set Suite Variable   ${L3CALL_cellid}

Backup Gnb Swconfig
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=Backup
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    csn.Execute    command=${cmd}    connection=Backup
    [Teardown]   csn.Disconnect   Backup

Modify Gnb Swconfig
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=Modify
    csn.Execute    command=echo "0x4F030E=1">>/ffs/run/swconfig.txt    connection=Modify
    csn.Execute    command=crasign /ffs/run/swconfig.txt    connection=Modify
    [Teardown]   csn.Disconnect   Modify

Recover Gnb Swconfig
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${asik_password} ssh ${asik_username}@${asik_addr} '${cmd}'

Data Transfer Conducted
    [Arguments]   ${abil_index}=1   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90s
    ${iperf_port}   Run Keyword If   '${tl.gnbs[0].global_bts_id}'=='None' or '${tl.gnbs[0].global_bts_id}'=='92'   Set Variable   58092
    ...   ELSE   Set Variable   58${tl.gnbs[0].global_bts_id}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Call Setup and check tput   port=${iperf_port}   tput_expect=5
    [Teardown]   run keyword if   ${traffic_stop}    power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Import SCF and Wait to onair
    [Arguments]   ${ip_addr}   ${SCF_FILE}
    Import SCF On COAM   IP_WEBUI=${ip_addr}  SCF_FILE=${SCF_FILE}
    Wait Until Keyword Succeeds   10m   30s   Try Connect gNB    gnb_addr=${ip_addr}
    Wait until keyword succeeds  10min   1min   COAM Login
    Wait Until Keyword Succeeds   20min   1min   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

#Commission Reset
#    COAM WEBUI Login   url=https://${lmp_addr}   alias=uncommission
#    ${alias_dict}   Get COAM Alias Dict   coam=uncommission
#    selenium_coam.configuration_reset   &{alias_dict}
#    Run Keyword and Ignore Error   COAM WEBUI Logout   coam=uncommission
#    Wait Until Keyword Succeeds   10m   30s   gNB not Connected
#    Wait until keyword succeeds   15x   1m   COAM Login   alias=uncommission   bts_host=${lmp_addr}
#    ${bts_status}   COAM Get General Status   connection=uncommission
#    Should Be Equal   ${bts_status['proceduralState']}   NotCommissioned
#    [Teardown]   COAM Logout   connection=uncommission
#
#Commission Reset and Import SCF
#    [Arguments]   ${SCF_FILE}
#    Wait until keyword succeeds  3x   1min   Commission Reset
#    Wait until keyword succeeds  2x   1min   Import SCF and Wait to onair   ip_addr=${lmp_addr}   SCF_FILE=${SCF_FILE}
#    coam_client.Get active alarms   connection=COAM   timeout=30


Import SCF On COAM
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    ${admin_status}   Run Keyword and Return Status   Import SCF by Admin   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}
    Return From Keyword If   ${admin_status}
    ${admin_status}   Run Keyword and Return Status   Import SCF by Selenium   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}
    Return From Keyword If   ${admin_status}
    Import SCF by Coam CU   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}

Import SCF by Admin
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    Wait until keyword succeeds  30min   1min   coam.connect_to   bts_host=${IP_WEBUI}   name=cOAM
    Log to console   \nImport SCF File: ${SCF_FILE}
    ${version}   coam.get_sw_version   timeout=${60}   connection=cOAM
    log to console   \n${version}
    coam.perform_commissioning
    ...   scf_file=${SCF_FILE}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=cOAM
#    Wait Until Keyword Succeeds   7m   30s   gNB not Connected
    Wait Until Keyword Succeeds   7m   30s   Try Connect gNB
    [Teardown]  run keyword and ignore error  coam.teardown   connection=cOAM

Import SCF by Selenium
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    COAM WEBUI Login   url=https://${IP_WEBUI}   alias=LMP
    ${alias_dict}   Get COAM Alias Dict   coam=LMP
    selenium_coam.load_commissioning_file_and_check_load_status   file_path=${SCF_FILE}   timeout=${120}   &{alias_dict}
    selenium_coam.validate_plan   &{alias_dict}
    selenium_coam.activate_plan   &{alias_dict}
    Wait Until Keyword Succeeds   7m   30s   gNB not Connected
    Wait Until Keyword Succeeds   7m   30s   Try Connect gNB
    [Teardown]   run keyword and ignore error   COAM WEBUI Logout   coam=LMP

Import SCF by Coam CU
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    taf.gnb.oam.coam.cu.connect_to    host=${IP_WEBUI}    port=${EMPTY}    secure=${True}
    ...   username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    cu_version=cuoam_19b
    ${upload_info}    taf.gnb.oam.coam.cu.upload_plan_file    path_to_plan_file=${SCF_FILE}
    wait until keyword succeeds    10x   5s
    ...    CI_commssion.CU Plan Upload Success    plan_id=${upload_info["action_id"]}
    ${validate_info}  taf.gnb.oam.coam.cu.plan_validation    ${upload_info["plan_id"]}
    wait until keyword succeeds    10x   5s
    ...    CI_commssion.CU Plan Validate Success    plan_id=${upload_info["plan_id"]}    action_id=${validate_info["action_id"]}
    ${activation_info}    taf.gnb.oam.coam.cu.plan_activation      plan_id=${upload_info["plan_id"]}
    wait until keyword succeeds    20x   20s
    ...    CI_commssion.CU Plan Activate Success    plan_id=${upload_info["plan_id"]}    activate_id=${activation_info["id"]}
    Wait Until Keyword Succeeds   7m   30s   gNB not Connected
    [Teardown]    taf.gnb.oam.coam.cu.disconnect

Import SCF by Custom
    [Arguments]   ${local_path}
    log to console    import scf
    Import SCF and Wait to onair   ip_addr=${asik_addr}   SCF_FILE=${local_path}
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout    display=${${DEBUG}}

Check BTS Normal ${ru_num}
    ${bts_info}   coam.get_bts_info   timeout=${30}   connection=COAM
    ${cell_num}   Get length   ${bts_info['cells']['nr']}
    ${ru_num_int}       Convert To Integer       ${ru_num}
    should be equal     ${cell_num}     ${ru_num_int}
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       Wait until keyword succeeds  5min   10s   Verify cOAM Cell Setup    alias=COAM   cell_id=${cell_id+1}   timeout=30
    END
#    check alarm on COAM    opration=fail    connection=COAM

Check BTS reset or not
#    Check ASIK is UP
#    Check ABIL is UP
    ${led_ASIK}    run keyword and ignore error       common.Check Given ASIK Led State    asik=1
    should be equal   ${led_ASIK[1]}   Online
    ${led_ABIL}    run keyword and ignore error       common.Check Given ABIL Led State    abil=1
    should be equal   ${led_ABIL[1]}   Online

Check RU Resetted
    [Arguments]   ${index}   ${asik_alias}
    Connect to RU With Allocated IP   ru_alias=RU_${index}   asik_alias=${asik_alias}   connection=COAM
    ${not_reset}   run keyword and return status   csn.File Exists   remote_path=/tmp/test_restart   connection=RU_${index}
    Should Be True   ${not_reset}
    [Teardown]   csn.Disconnect   connection=RU_${index}

Check Given ASIK Led State
    [Arguments]    ${asik}
    ${ASIK_state}       selenium_coam.get_led_status_of_an_unit     unit=SMOD-${asik}
    Log to console      ASIK state: ${ASIK_state}
    [Return]            ${ASIK_state}

Check Given ABIL Led State
    [Arguments]    ${abil}
    ${ABIL_state}       selenium_coam.get_led_status_of_an_unit     unit=BBMOD-${abil}
    Log to console      ABIL state: ${ABIL_state}
    [Return]            ${ABIL_state}

Remove Cell ${index}
    ${index}       Convert To Integer       ${index}
    log to console    remove cell
    COAM WEBUI Login   display=${${DEBUG}}
    COAM Login
    selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${index}
    selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELLGRP-${index-1}
    selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}
    selenium_coam.remove_element    dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRDU-1
    ...     filter_param=Reference to cell group    node_index=${index-1}

    run keyword and ignore error   selenium_coam.validate_plan
    run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}
    ...   activate_plan_despite_errors=${True}    execute=${True}
    sleep  2m
    Wait Until Keyword Succeeds   5min   1min   COAM Check All Cells Onair
    COAM Logout
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout    display=${${DEBUG}}

Recovery Cell
    [Arguments]     ${index}
#    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
#    Check RU Resetted   index=${index}   asik_alias=ASIK
#    Check BTS reset or not
    log to console    recover cell
    COAM WEBUI Login   display=${${DEBUG}}
    COAM Login
    Add Cell   index=${index}
    Add Cell Group   index=${index}
    Activate Plan For 7105
    sleep  1m
    Wait Until Keyword Succeeds   5min   1min   COAM Check All Cells Onair
    COAM Logout
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout   display=${${DEBUG}}

Recovery Cell for multiBB
    [Arguments]     ${index}
#    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
#    Check RU Resetted   index=${index}   asik_alias=ASIK
#    Check BTS reset or not
    log to console    recover cell
    COAM WEBUI Login   display=${${DEBUG}}
    COAM Login
    Add Cell for multiBB   index=${index}
    Add Cell Group   index=${index}
    Activate Plan For 7105
    sleep  1m
    Wait Until Keyword Succeeds   5min   1min   COAM Check All Cells Onair
    COAM Logout
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout   display=${${DEBUG}}

Recovery Cell for ASOF TDD
    [Arguments]     ${index}
#    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
#    Check RU Resetted   index=${index}   asik_alias=ASIK
#    Check BTS reset or not
    log to console    recover cell
    COAM WEBUI Login   display=${${DEBUG}}
    COAM Login
    Add Cell for ASOF TDD   index=${index}
    Add Cell Group   index=${index}
    Activate Plan For 7105
    sleep  1m
    Wait Until Keyword Succeeds   5min   1min   COAM Check All Cells Onair
    COAM Logout
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Logout   display=${${DEBUG}}

Add Cell
    [Arguments]     ${index}
    log to console    add cell
    ${cell_technology}   Get Cells Technology
    ${index}   Convert To Integer   ${index}
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELL
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-1
     ...   id_value=${index}   include_subobject=${true}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Physical cell identifier
     ...   new_value=${index-1}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Local cell resource ID
     ...   new_value=${index}
#     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=List of RMOD distinguished names
#     ...   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}   node_index=${0}
     Run Keyword If   '${cell_technology}'=='FDD'
     ...   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=PRACH configuration index
     ...   new_value=${index+35}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
     ...   id_value=${index}   include_subobject=${true}
     Run Keyword If   '${cell_technology}'=='TDD'   Change TDD Cells Parameter   index=${index}
     ...   ELSE   Change FDD Cells Parameter   index=${index}
     selenium_coam.add_element   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1   filter_param=Reference to cell group
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
     ...   filter_param=Reference to cell group
     ...   new_value=${index-1}
     ...   node_index=${index-1}

Add Cell for multiBB
    [Arguments]     ${index}
    log to console    add cell
    ${cell_technology}   Get Cells Technology
    ${index}   Convert To Integer   ${index}
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELL
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-1
     ...   id_value=${index}   include_subobject=${true}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Physical cell identifier
     ...   new_value=${index-1}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Local cell resource ID
     ...   new_value=${index}
#     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=List of RMOD distinguished names
#     ...   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}   node_index=${0}
     Run Keyword If   '${cell_technology}'=='FDD'
     ...   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=PRACH configuration index
     ...   new_value=${index+35}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
     ...   id_value=${index}   include_subobject=${true}
     Run Keyword If   '${cell_technology}'=='TDD'   Change TDD Cells Parameter   index=${index}
     ...   ELSE   Change FDD Cells Parameter   index=${index}
     ${cell_numbers}    Get Cell Number
     ${cell_numbers}    Convert To Integer   ${cell_numbers}
     set test variable    ${cell_numbers}
     selenium_coam.add_element   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1   filter_param=Reference to cell group
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
     ...   filter_param=Reference to cell group
     ...   new_value=${index-1}
     ...   node_index=${cell_numbers}

Add Cell for ASOF TDD
    [Arguments]     ${index}
    log to console    add cell
    ${cell_technology}   Get Cells Technology
    ${index}   Convert To Integer   ${index}
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELL
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-1
     ...   id_value=${index}   include_subobject=${true}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Physical cell identifier
     ...   new_value=${index-1}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Local cell resource ID
     ...   new_value=${index}
#     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=List of RMOD distinguished names
#     ...   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}   node_index=${0}
     Run Keyword If   '${cell_technology}'=='FDD'
     ...   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=PRACH configuration index
     ...   new_value=${index+35}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
     ...   id_value=${index}   include_subobject=${true}
     Run Keyword If   '${cell_technology}'=='TDD'   Change Cellmapping for ASOF TDD   index=${index}
     ...   ELSE   Change Cellmapping for ASOF FDD   index=${index}
     ${cell_numbers}    Get Cell Number
     ${cell_numbers}    Convert To Integer   ${cell_numbers}
     set test variable    ${cell_numbers}
     selenium_coam.add_element   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1   filter_param=Reference to cell group
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
     ...   filter_param=Reference to cell group
     ...   new_value=${index-1}
     ...   node_index=${cell_numbers}

Get Cell Number
    ${cell_list}   COAM Get Cell List
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

Add Cell Group
    [Arguments]     ${index}
    log to console    add cellgroup
    ${index}   Convert To Integer   ${index}
    selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELLGRP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-0
     ...   id_value=${index-1}   include_subobject=${true}
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-${index-1}
     ...   filter_param=List of NR cells assigned to cell group
     ...   new_value=${index}
     ...   node_index=${0}

Activate Plan For 7105
     log to console    activate plan
     selenium_coam.validate_plan
     COAM WEBUI Whether Close Start Up View Window
     selenium_coam.activate_plan  download_plan_without_activation=${False}
     ...   activate_plan_despite_errors=${True}    execute=${True}

Get Cells Technology
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R
    Set Suite Variable   ${nrcell_r}   ${nrcell[0]['distName']}
    ${cell_specific_info}   COAM Get Cell Info   cell_id=${nrcell_r}
    ${cell_technology}   set variable   ${cell_specific_info['technology']}
    [Return]     ${cell_technology}

Change TDD Cells Parameter
    [Arguments]    ${index}
#    for mMimo
#    :FOR   ${int}    IN RANGE    8
#        run keyword and ignore error   selenium_coam.set_parameter_value
#        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
#        ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
#     END
#    for 8T8R
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-1
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-5
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-2
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-6
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-3
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-7
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-4
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-8
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4

Change Cellmapping for ASOF TDD
    [Arguments]    ${index}
#    for 4T4R
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-1
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-2
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-3
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-4
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-5
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-6
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-7
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4
     selenium_coam.set_parameter_value
     ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-8
     ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4

Change FDD Cells Parameter
    [Arguments]    ${index}
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+3}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+5}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+7}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4
    END

Change Cellmapping for ASOF FDD
    [Arguments]    ${index}
#    for 4T4R
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+3}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+5}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
     END
    FOR   ${int}    IN RANGE    2
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+7}
        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4
    END

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
       [Return]     ${scfname}

Data Transfer Conducted for 8325
     Set automatic rotation for 8325    ue_index=${0}
     Power UE Precondition for 8325   ue_type=huawei   ue_index=${0}
     Run keyword and ignore error   Power UE detach for 8325   ue_type=huawei   ue_index=${0}
     Start Capture Wireshark Logs on gNB for 8325   nglogname=asix.pcap
     Run keyword and ignore error   Power UE attach for 8325   ue_type=huawei   ue_index=${0}
     Run keyword and ignore error   Power UE detach for 8325   ue_type=huawei   ue_index=${0}
     Stop Capture Wireshark Logs on gNB for 8325   nglogname=asix.pcap
     Check IE wireshark log for attach for 8325   nglogname=asix.pcap

Set automatic rotation for 8325
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s
    csn.disconnect      connection=cygwin${ue_index}

Start Capture Wireshark Logs on gNB for 8325
    [Arguments]     ${nglogname}    ${interface}=any
    log to console    tcpdumplog_start
    Set Suite Variable    ${epc_log_path}    ${OUTPUT DIR}/Logs
    Create directory    ${epc_log_path}
    RUN KEYWORD AND IGNORE ERROR    gNB connections for 8325
    csn.send command    command=tcpdump -i ${interface} sctp -w /tmp/${nglogname}   connection=gnb
    sleep    3s
    Run Keyword And Ignore Error    csn.disconnect    connection=gnb

Stop Capture Wireshark Logs on gNB for 8325
    [Arguments]    ${nglogname}
    log to console    tcpdumplog_stop
    gNB connections for 8325
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb
    sleep    3
    run keyword and ignore error   csn.send command    command=rm ${epc_log_path}/${TESTNAME}/asix.*   connection=gnb
    Create directory   ${epc_log_path}/${TESTNAME}
    csn.download_file   remote_path=/tmp/${nglogname}   local_path=${epc_log_path}/${TESTNAME}/${nglogname}   connection=gnb
    sleep    3
    Run Keyword And Ignore Error    csn.disconnect    connection=gnb

Power UE Precondition for 8325
    [Arguments]    ${ue_type}=xiaomi    ${ue_index}=${8}
    power_ue. Prepare UE   ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
#    Run keyword if   '${ue_type}'=='xiaomi'   Get all xiaomi11 pointer variable

Power UE attach for 8325
    [Arguments]    ${ue_type}=xiaomi   ${4g_check}=False    ${gnb_index}=${0}   ${ue_index}=${8}
    log to console    ue_attach
    Run keyword if   '${ue_type}'=='xiaomi'   unlock the screen and close all task for 8325    ue_index=${ue_index}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
#    sleep    18s
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    gnb_index=${gnb_index}
#    ...                       4G_check=${4g_check}    5Gstatus=PASS
    Preparation and execution for Commercial UE Attach    ue_index=${ue_index}    UE_type=${ue_type}

Power UE detach for 8325
    [Arguments]    ${ue_type}=xiaomi   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    ue_detach
    Run keyword if   '${ue_type}'=='xiaomi'   unlock the screen and close all task for 8325    ue_index=${ue_index}
    power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

unlock the screen and close all task for 8325
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep    1s
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
    [Teardown]    csn.disconnect      connection=${connection}

gNB connections for 8325
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Check IE wireshark log for attach for 8325
    [Arguments]     ${nglogname}
    log to console    check tcpdumplog
    parser.load_pcap_file    pcap_file=${epc_log_path}/${TESTNAME}/${nglogname}   alias=Wireshark
    ${filter_expression}=     Catenate    ngap.procedureCode == 14 and ngap.fiveQI == 5
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//ngap.fiveQI
    Should Not Be Empty    ${result}
    ${filter_expression}=     Catenate    ngap.procedureCode == 29 and ngap.fiveQI == 7
    ${filtered_packets}=    parser.filter_packets_by_expression    pcap_parser=Wireshark    filter_expression=${filter_expression}
    ${result}=    parser.Get Field Value By Xpath    pcap_parser=Wireshark
    ...    xpath=.//ngap.fiveQI
    Should Not Be Empty    ${result}
