*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Variables   ../Library/config_vars.py
Library   taf.gnb.oam.commissioning   WITH NAME   oam_commissioning
Library     taf.gnb.oam.coam.cu
Library   taf.transport.ssh   WITH NAME   csn

*** Variables ***
&{config_value}   2DL2UL=A   4DL2UL=C
${coam_alias}   COAM
&{channel_dl}

*** Keywords ***
COAM Client Reset Site
    [Arguments]   ${connection}=COAM
    coam_client.reset_site   connection=${connection}   wait_for_reconnection=${True}

COAM Client Delete Object
    [Arguments]   ${dist_name}   ${activate}=${true}   ${connection}=COAM
    @{empty_list}   Create List
    coam_client.perform_object_recommissioning   dist_name=${dist_name}   parameter=${empty_list}
    ...   operation=delete
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${activate}
    ...   timeout=300
    ...   connection=${connection}

Covert Config to Request
    [Arguments]   ${config_index}
    ${config_match}   Check Current Configuration Match   config_index=${config_index}
    run keyword if  not ${config_match}   Commission 1821 Configuration ${config_index}
    run keyword if  not ${config_match}   selenium_coam.validate_plan
    run keyword if  not ${config_match}   selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
    run keyword if  not ${config_match}   Sleep   10m
    [Teardown]   Run Keyword and Ignore Error   selenium_coam.Logout

Check Current Configuration Match
    [Arguments]   ${config_index}
    selenium_coam.enable_virtual_display
    selenium_coam.Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ${bts_id}   selenium_coam.get_bts_id
    ${nrbts_node}   Set Variable   MRBTS-${bts_id}/NRBTS-${bts_id}
    ${curr_config}   selenium_coam.get_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=NR Cell type
    ${is_match}   Run Keyword and Return Status   Should Be Equal   ${config_value['${curr_config}']}   ${config_index}
    [Return]   ${is_match}

Import SCF On COAM
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    ${admin_status}   Run Keyword and Return Status   Import SCF by Admin   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}
    Return From Keyword If   ${admin_status}
    ${admin_status}   Run Keyword and Return Status   Import SCF by Selenium   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}
    Return From Keyword If   ${admin_status}
    Import SCF by Coam CU   IP_WEBUI=${IP_WEBUI}   SCF_FILE=${SCF_FILE}

Import SCF by Admin
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    Wait until keyword succeeds  30min   1min   coam_client.connect_to   bts_host=${IP_WEBUI}   name=cOAM
    Log to console   \nImport SCF File: ${SCF_FILE}
    ${version}   coam_client.get_sw_version   timeout=${60}   connection=cOAM
    log to console   \n${version}
    coam_client.perform_commissioning
    ...   scf_file=${SCF_FILE}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=cOAM
#    Wait Until Keyword Succeeds   7m   30s   gNB not Connected
    Wait Until Keyword Succeeds   7m   30s   Try Connect gNB
    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=cOAM

Import SCF by Selenium
    [Arguments]   ${IP_WEBUI}   ${SCF_FILE}
    COAM WEBUI Login   url=https://${IP_WEBUI}   alias=LMP
    ${alias_dict}   Get COAM Alias Dict   coam=LMP
    selenium_coam.load_commissioning_file_and_check_load_status   file_path=${SCF_FILE}   timeout=${120}   &{alias_dict}
    selenium_coam.validate_plan   &{alias_dict}
    selenium_coam.activate_plan   &{alias_dict}
    Wait Until Keyword Succeeds   7m   30s   gNB not Connected
    Wait Until Keyword Succeeds   7m   30s   Try Connect gNB
    [Teardown]   Wait Until Keyword Succeeds   7m   30s   COAM WEBUI Logout   coam=LMP

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

Get Current SCF File On COAM
    [Arguments]   ${IP_WEBUI}
    coam_client.Connect to   bts_host=${IP_WEBUI}   name=cOAM
    ${SCF_FILE}   coam_client.Get current scf file   local_dir_path=${OUTPUT_DIR}   file_name=Configuration_scf.xml
    ...   timeout=30   connection=cOAM
    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=cOAM
    [Return]   ${SCF_FILE}

Save Snapshot logs On COAM
    [Documentation]   COAM session get snapshot
    [Arguments]   ${IP_WEBUI}
    coam_client.Connect to   bts_host=${IP_WEBUI}   name=COAM
    ${snapshot_path}   Catch Snapshot COAM
    [Teardown]  run keyword and ignore error  coam_client.teardown   connection=COAM
    [Return]   ${snapshot_path}

Screenshot for case fail
    [Documentation]   Catch screenshot when required
#    Wait Until Keyword Succeeds   3 min   1 min    COAM WEBUI Login
    Create Directory     ${OUTPUT_DIR}
    selenium_coam.get_cell_group_status
    Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
#    [Teardown]     WEBEM Logout

Change CellType by perform SCF
   [Arguments]    ${celltype}=4DL4UL
   wait until keyword succeeds     10x    30s    COAM Login    bts_host=${LMP_ADDR}
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
   ${gnb_release}    Run keyword if   '${gnb_release}'=='SBTS21B'     set variable   21B
   ...   ELSE IF    '${gnb_release}'=='5G21A'     set variable   21A
   ...   ELSE IF    '${gnb_release}'=='SBTS22R1'     set variable   22R1
   ...   ELSE IF    '${gnb_release}'=='TRUNK'     set variable   TRUNK
   wait until keyword succeeds     5x    5min
   ...   COAM SCF Commission    filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${gnb_release}_${celltype}.xml
   COAM Logout

Upgrade Swconfig File
    csn.Connect to   ${asik_addr}   ${asik_username}   ${asik_password}   alias=gnb
    ${output}   csn.Execute   cat /rom/swconfig.txt   connection=gnb
    run keyword if  ${output.count('No such file or directory')} > 0
    ...   _upload_swconfig_to_gnb
    [Teardown]    run keyword and ignore error  csn.Disconnect   connection=gnb


_upload_swconfig_to_gnb
    csn.Upload File   local_path=${CURDIR}/../Library/swconfig.txt   remote_path=/rom/swconfig.txt  connection=gnb
    csn.Execute   crasign /rom/swconfig.txt   connection=gnb
    csn.Execute   reboot   connection=gnb

Set SCF Path
    ${SCF}    RUN    ls ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
    ${gnb_release}   Get gnb release
    ${scf_load}    run keyword if  ${SCF.count('${gnb_release}')} > 0    set variable
    ...   ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${gnb_release}.xml
    ...   ELSE    Pick Earlist SCF    SCF=${SCF}
    [Return]    ${scf_load}

Pick Earlist SCF
    [Arguments]    ${SCF}
    ${SCF_list}    Get Regexp Matches    ${SCF}    SCF_SBTS2[2-9]R[1-4].xml
    ${earlist_scf}    run keyword if  len(${SCF_list}) > 0    _set_scf_dic    SCF_list=${SCF_list}
    ...   ELSE    set variable     ${earlist_scf}
    [Return]    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/${earlist_scf}

_set_scf_dic
    [Arguments]     ${SCF_list}
    &{scf_dic}    Create Dictionary
    FOR  ${scf}  IN   @{SCF_list}
        ${scf_num}    Get Regexp Matches    ${scf}    SCF_SBTS2[2-9]R(.).xml   1
        Set To Dictionary   ${scf_dic}   ${scf_num[0]}   ${scf}
    END
    ${sorted}    Get Dictionary Values    ${scf_dic}
    [Return]   ${sorted[0]}
