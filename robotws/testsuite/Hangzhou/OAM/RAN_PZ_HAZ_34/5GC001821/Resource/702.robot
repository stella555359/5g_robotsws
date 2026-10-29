*** Settings ***
Documentation
...  author: Jiang Johnny  He Jingmin
...  contact: johnny.1.jiang@nokia-sbell.com  jingmin.he@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource   ../../common/collect_log.robot
Resource   ../../common/Inseego.robot
Resource   coam.robot
Library   ../Library/CPRI.py
Variables   ../Library/config_vars.py
Library   OperatingSystem
Variables   ../Library/702_qc_id.py
Variables   ../Library/2035_qc_id.py
Variables   ../Library/2089_qc_id.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library   String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library   ../Library/ru.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/RU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${cell_index}   2
${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}
&{config_type}   2DL2UL=L   4DL2UL=M   8DL4UL=O    4DL4UL=P
${DEBUG}   false
${mrbts_id}   ${tl.gnbs[0].global_bts_id}
${nrbts_id}   ${tl.gnbs[0].instance_id}

*** Keywords ***
Commission Modify actFDMScheduling
    COAM WEBUI Whether Close Start Up View Window
    ${fdm_status}   selenium_coam.get_parameter_value
    ...   dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}   filter_param=Activate frequency domain scheduling
    ${fdm_new_status}   Set Variable If   $fdm_status=='true'   false   true
    selenium_coam.set_parameter_value  dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}
    ...   filter_param=Activate frequency domain scheduling   new_value=${fdm_new_status}
    selenium_coam.set_parameter_value  dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}
    ...   filter_param=Activate general connectivity bronze use case level   new_value=true
    selenium_coam.validate_plan    timeout=40
    run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}

Set Common Test Tag
    [Arguments]   ${case_key}
    ${ru_type}   Read Current RU Type
    ${config_type}   Read Current Configuration AAH
    ${release}   Get gnb release
    ${eCPRI_status}    Read eCPRI Configuation
    ${sector_type}    Read Cells Number
    ${cell_type}    Read Cell Type
    ${cab_type}    Get CABLINK Num
    ${bbmod}    Get BBMOD Product Name
    run keyword if  ${eCPRI_status.count('true')}>0
    ...   Set Tags   QC_${ecpri_qc_id['${case_key}']['${release}']['${bbmod}']['${ru_type}']['${sector_type}']['${cell_type}']['${cab_type}']}
    ...   ELSE   Set Tags   QC_${qc_ins_id['${case_key}']['${release}']['${ru_type}']['${config_type}']}
    Set Suite Variable   ${GNB_RELEASE}   ${release}

Set Common Test Tag New
    [Arguments]   ${case_key}
    ${ru_type}   Read Current RU Type
    ${config_type}   Read Current Configuration AAH
    ${release}   Get gnb release
    ${eCPRI_status}    Read eCPRI Configuation
    ${sector_type}    Read Cells Number
    ${cell_type}    Read Cell Type
    ${cab_type}    Get CABLINK Num
    ${bbmod}    Get BBMOD Product Name
    ${link_type}   Set Variable If   ${eCPRI_status.count('true')}>0   ECPRI   CPRI
    ${csv_file}   Set Variable   ${CURDIR}${/}..${/}Library${/}${bbmod}_${link_type}.csv
    ${search_key}   Set Variable   ${ru_type}-${sector_type}-${cell_type}-${cab_type}-${release}
    ${qc_id}   Get QC Ins ID   file_name=${csv_file}   search_key=${search_key}   case_key=${case_key}
    run keyword if  not '${qc_id}'=='NA'   Set Tags   QC_${qc_id}

Read Current Configuration AAH
    ${dist_name}   set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ${cell_type}  selenium_coam.get_parameter_value   dist_name=${dist_name}    filter_param=NR Cell type
    [Return]   ${config_type}[${cell_type}]

Read Current RU Type
    COAM Login   alias=ru_info
    ${bts_info}   coam.get_bts_info   connection=ru_info   timeout=${30}
    ${ru_type_info}   Create Dictionary
    FOR   ${rmod}   IN   @{bts_info['radioModules']['rmod']}
        ${rmod_index}   Set Variable   ${rmod['id']['configuration'].split("/")[-1].split("-")[-1]}
        Set To Dictionary   ${ru_type_info}   ${rmod_index}   ${rmod['productName']}
    END
    ${ru_list}   Get Dictionary Values   ${ru_type_info}
    ${ru_no_dup_list}   RU List To Str   ru_list=${ru_list}
    ${ru_type}   Evaluate   "+".join(${ru_no_dup_list})
    [Return]   ${ru_type}
    [Teardown]   COAM Logout   connection=ru_info

Read eCPRI Configuation
    ${dist_name}   set variable
    ...     MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SYNC-1
    ${eCPRI_status}  selenium_coam.get_parameter_value   dist_name=${dist_name}    filter_param=Activate eCPRI Master clock
    [Return]    ${eCPRI_status}

Read Cells Number
    ${cells_number}    selenium_coam.get_number_of_cells
    set suite variable    ${cells_number}
    [Return]    ${cells_number}S

Read Cell Type
    ${dist_name}   set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ${cell_type}  selenium_coam.get_parameter_value   dist_name=${dist_name}    filter_param=NR Cell type
    [Return]   ${cell_type}

Get CABLINK Num
    COAM Login   alias=cab_info
    ${bts_info}   coam.get_bts_info   connection=cab_info   timeout=${30}
    ${cabnum}     Get length   ${bts_info['cables']}
    [Return]  ${cabnum}cab
    [Teardown]     COAM Logout   connection=cab_info

Get gNB RU info
    COAM Login   alias=ru_info
    ${bts_info}   coam.get_bts_info   connection=ru_info   timeout=${30}
    #${rmod}   Set Variable   ${bts_info['radioModules']['rmod']}
    [Return]   ${bts_info['radioModules']['rmod'][0]['productName']}
    [Teardown]   COAM Logout   connection=ru_info

Get BBMOD Product Name
    COAM LOGIN   alias=bb_info
    ${bbmod_info_list}   Get BBMODs info   alias=bb_info
    ${smod_product_name}   Get SMOD Product Name   connection=bb_info
    ${bbmod_status}   Run Keyword And Return Status   Should Not Be Empty   ${bbmod_info_list}
    ${bbmod_productname}   Set Variable If
    ...   ${bbmod_status}   ${bbmod_info_list[0]['product_name']}
    ...   ${smod_product_name}
    [Return]    ${bbmod_productname}
    [Teardown]   COAM LOGOUT   connection=bb_info

Case Setup
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Read Cells Number
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    run keyword and ignore error   Upgrade Swconfig File
    wait until keyword succeeds    10min    1min    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword and Ignore Error    Set Sanity Check to False
    Run Keyword and Ignore Error   Start BTS Log Collection
    run keyword if  '${tl.gnbs[0].global_bts_id}' == '835' or '${tl.gnbs[0].global_bts_id}' == '833'
    ...   RU Log Operation Setup
    #DO NOT CLOSE FIREFOX AFTER WEBUI LOGIN HERE

Case Teardown
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error   Save or Remove logs
    run keyword if  '${tl.gnbs[0].global_bts_id}' == '835' or '${tl.gnbs[0].global_bts_id}' == '833'
    ...   RU Log Operation Teardown
    run keyword if test failed    run keyword and ignore error    Screenshot for case fail
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    Run Keyword and Ignore Error   COAM Logout
#    Save or Remove logs
    CI_interface.Common Case Teardown

Save or Remove logs
    [Documentation]   Collect snapshot and btslog when case failed
    #run keyword and ignore error    Stop and Save BTS Logs
    #Log to console   close btslog
    run keyword if test passed   Remove Directory   ${log_path}    recursive=True
#    ...   ELSE   Move File   source=${log_path}   destination=${OUTPUT_DIR}
    run keyword if test failed   702.Save Logs   log_path=${log_path}
    run keyword if test failed   run keyword and ignore error    Stop and Save BTS Log Collection
    run keyword if test passed   run keyword and ignore error    Stop and Delete BTS log in VM

Save Logs
    [Documentation]   Collect snapshot and btslog
    [Arguments]     ${log_path}
    run keyword and ignore error    Screenshot for case fail
#    run keyword and ignore error    Move File   log_path=${log_path}   destination=${OUTPUT_DIR}
    run keyword and ignore error    Save Snapshot logs On COAM    IP_WEBUI=${WEBUI_ADDR}

Data Transfer Conducted
    [Documentation]   Call setup and release for 702 testing
    [Arguments]   ${cell_index}=${cell_index}   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH
    ...   ${tput_expect_DL}=85   ${tput_expect_uL}=30    ${send_tp_DL}=100    ${send_tp_UL}=100
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_port}   Set Variable If
    ...   '${ue_type}'=='askey' or '${ue_type}'=='nokia_fastmile'    58092
    ...   ${tl.ues[${ue_index}].iperf_details.port}>${50000}   ${tl.ues[${ue_index}].iperf_details.port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    ${ul_iperf_port}   Set Variable If
    ...   '${ue_type}'=='askey' or '${ue_type}'=='nokia_fastmile'   57092
    ...   ${tl.ues[${ue_index}].iperf_details.port}>${50000}   ${tl.ues[${ue_index}].iperf_details.port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   57092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   570${tl.gnbs[0].global_bts_id}   57${tl.gnbs[0].global_bts_id}
    Run Keyword If   '${direction}'=='BOTH' or '${direction}'=='DL'
    ...   Call Setup and check tput   port=${iperf_port}   tput_expect=${tput_expect_DL}    tput=${send_tp_DL}
    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}
    Run Keyword If   '${direction}'=='BOTH' or '${direction}'=='UL'
    ...   Call Setup and check tput   port=${ul_iperf_port}   tput_expect=${tput_expect_uL}    tput=${send_tp_UL}
    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}   direction=UL
    [Teardown]   run keyword if   ${traffic_stop}    power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

RU Log Operation Setup
    run keyword and ignore error    Check and Upload RU btslog Flag in Swconfig File
    wait until keyword succeeds    10min   30s   COAM Check All Cells Onair
    run keyword and ignore error    Enable LMI RU at ControlPC
    run keyword and ignore error    Clear ALL RUs Serial Log
    run keyword and ignore error    Clear ALL RUs BTSLOG
    Run Keyword and Ignore Error    Start ALL RUs BTSLOG at RU PC

RU Log Operation Teardown
    run keyword and ignore error    Stop ALL RUs BTSLOG at RU PC
    run keyword if test failed    run keyword and ignore error    Save RU Serial Log
    run keyword if test failed    run keyword and ignore error    Save RU BTSLOG
    run keyword if test failed    run keyword and ignore error    Save ALL RUs Snapshot
#    run keyword and ignore error    Save ALL RUs Serial Log
#    run keyword and ignore error    Save ALL RUs BTSLOG
#    run keyword and ignore error    Save ALL RUs Snapshot

RU sync checking
    [Documentation]   Check if RU is shared with gNB and eNB, share mode RU shouldn't reset under gNB reset
    [Arguments]   ${ru_alias}
    ${res}   run keyword and return status   csn.File Exists   remote_path=/sbin/devmem   connection=${ru_alias}
    return from keyword if   not ${res}   ${EMPTY}
    ${res}   Run Keyword and Ignore Error   csn.Execute   /sbin/devmem 0xa1602308 32   connection=${ru_alias}   timeout=5
    Return From Keyword If   '${res[0]}'=='FAIL'   ${EMPTY}
    @{lines}   Split To Lines   ${res[1]}
    return from keyword if   '${lines[0][-3]}'=='1'   share
    [return]   ${EMPTY}

COAM Get GNB RU Number
    [Arguments]    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    log    ${hw_info}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${count_RUs}    convert to integer    ${count_RUs}
    [Return]    ${count_RUs}

Change All Cells Bandwith
    [Documentation]   chbw change in all cells webui
    [Arguments]   ${new_band}
    run keyword and ignore error    COAM WEBUI Login
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    ${cell_count}   selenium_coam.get_number_of_cells
    FOR   ${index}    IN RANGE    ${cell_count}
       _Change chbw by Cell Index   cell_index=${index+1}   new_band=${new_band}
    END
    selenium_coam.validate_plan
    Sleep   5s
    selenium_coam.refresh_page
    Sleep   5s
    wait until keyword succeeds   1m   10s   selenium_coam.activate_plan   activate_plan_despite_errors=${true}
    wait until keyword succeeds   10m   1m   Try Connect gNB
    wait until keyword succeeds   25m   1m   COAM Check All Cells Onair
    COAM WEBUI Whether Close Start Up View Window

Change Bandwith
    [Documentation]   chbw change in webui
    [Arguments]   ${cell_index}   ${new_band}   ${pair_cell_change}=${false}
    #COAM WEBUI Login
    COAM WEBUI Whether Close Start Up View Window
    _Change chbw by Cell Index   cell_index=${cell_index}   new_band=${new_band}
    Run Keyword If   ${pair_cell_change}   Change Pair Cell chbw by Index   ${cell_index}   ${new_band}
    selenium_coam.validate_plan
    Sleep   5s
    selenium_coam.refresh_page
    Sleep   5s
    wait until keyword succeeds   1m   10s   selenium_coam.activate_plan   activate_plan_despite_errors=${true}
    wait until keyword succeeds   10m   1m   Try Connect gNB
    wait until keyword succeeds   25m   1m   COAM Check All Cells Onair
    COAM WEBUI Whether Close Start Up View Window
    #[Teardown]   Run Keyword and Ignore Error   COAM WEBUI Logout

_Change chbw by Cell Index
    [Documentation]   chbw change in asked cell webui
    [Arguments]   ${cell_index}   ${new_band}
    ${dist_name}   Set Variable   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}
    ${curr_band}   selenium_coam.Get Parameter Value   dist_name=${dist_name}   filter_param=Channel bandwidth
    Return From Keyword If   '${new_band}MHz'=='${curr_band}'
    selenium_coam.set_parameter_value    dist_name=${dist_name}     filter_param=Channel bandwidth    new_value=${new_band}MHz

Change Pair Cell chbw by Index
    [Documentation]   calculate the pair cell index and change the chbw
    [Arguments]   ${cell_index}   ${new_band}
    ${mod_res}   Evaluate   ${cell_index} % 2
    ${pair_index}   Run Keyword If   ${mod_res}==${0}   Evaluate   ${cell_index}-1
    ...   ELSE   Evaluate    ${cell_index}+1
    _Change chbw by Cell Index   cell_index=${pair_index}   new_band=${new_band}
    [Return]   ${pair_index}

Set Sanity Check to False
    ${dist_name}   Set Variable   MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${value}   selenium_coam.Get Parameter Value   dist_name=${dist_name}   filter_param=Activate System Module Sanity Checker
    Run Keyword If   '${value}'=='true'
    ...   selenium_coam.set_parameter_value    dist_name=${dist_name}     filter_param=Activate System Module Sanity Checker
    ...  new_value=false
