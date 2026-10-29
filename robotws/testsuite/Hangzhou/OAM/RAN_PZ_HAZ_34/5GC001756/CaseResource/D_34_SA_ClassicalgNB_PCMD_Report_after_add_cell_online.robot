*** Settings ***
Documentation
...  author : yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
D_34_SA_ClassicalgNB_PCMD_Report_after_add_cell_online
    Make L3CALL And Get ALL PCMD MSG
    ${flag}   Set Variable   ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${flag}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        Exit For Loop If   ${flag}
    END
    run keyword if  not ${flag}   Fail   Message Not Found!

Case Setup: D_34
    Common Setup 1756
    # Run Keyword And Ignore Error   Start Catch Relative Log   log_dir_name=${TEST_NAME}
    COAM WEBUI Login
    # COAM WEBUI Save BTS Configuration
    Wait Until Keyword Succeeds   5m   1m   COAM Check All Cells Onair   connection=COAM

    Log To Console   Start to Remove the NRCELL-1 and NRCELLGROUP-0 online
    # Remove the cell and cellgrp online    cell_id=1   cellgrp_id=0   connection=COAM
    Remove The Cell And Cellgrp WEBMEM   cell_id=1   cellgrp_id=0
    Validate and Activate Plan

    Remove And Add PCMD Object

    Log To Console   Start to add the NRCELL-1 and NRCELLGROUP-0 online
    Add the cell and cellgrp online   cell_id=1   cellgrp_id=0
    Validate and Activate Plan

    Wait Until Keyword Succeeds   5m   1m   COAM Check All Cells Onair   connection=COAM

Case Teardown: D_34
    # Run Keyword If Test Failed   Collect Relative Log
    # Run Keyword If Test Passed   Delete BTS log in VM
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM SCF Commission
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Common Teardown 1756

Remove The Cell And Cellgrp WEBMEM
    [Arguments]   ${cell_id}   ${cellgrp_id}
    selenium_coam.remove_object   object_name=${INSID}/NRCELL-${cell_id}
    selenium_coam.remove_object   object_name=${INSID}/NRCELLGRP-${cellgrp_id}
    selenium_coam.remove_object   object_name=${MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    selenium_coam.remove_element
    ...   dist_name=${INSID}/NRDU-1
    ...   filter_param=Reference to cell group
    ...   node_index=${0}
    ...   abbr=refNrCellGroup

Add the cell and cellgrp online
    [Arguments]   ${cell_id}   ${cellgrp_id}
    Add NRCELL   cell_id=${cell_id}
    Add NRCELLGROUP   cellgrp_id=${cellgrp_id}
    Set lcrId For New NRCELL   cell_id=${cell_id}
    Set physCellId For New NRCELL   cell_id=${cell_id}
    Set nrCellList For New NRCELLGROUP   cellgrp_id=${cellgrp_id}   cell_id=${cell_id}
    Unlock New RMOD   cell_id=${cell_id}
    Add refNrCellGroup For NRCELLGROUP Under NRDU   cellgrp_id=${cellgrp_id}
    ${cell_map_node_list}   selenium_coam.get_object_name_list   CELLMAPPING
    Log To Console   cell_map_node_list: ${cell_map_node_list}
    ${cell_map_node}   Set Variable   ${cell_map_node_list[0]}
    ${channel_group_node_list}   selenium_coam.get_object_name_list
    ...  object_name=${MRBTS}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id}/CHANNELGROUP-
    Log To Console  channel_group_node_list: ${channel_group_node_list}
    ${channel_group_number}=   get length   ${channel_group_node_list}
    Add LCELNR For New NRCELL    cell_id=${cell_id}
    FOR  ${idx}    IN RANGE    1   ${channel_group_number+1}
        Change resourceDN For Every Channel Every Channelgroup   channelgroup_id=${idx}  cell_map_node=${cell_map_node}  cell_id=${cell_id}
    END
    Run Keyword And Ignore Error   selenium_coam.validate_plan
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    ${definition_errors}    selenium_coam.get_definition_errors

Change resourceDN For Every Channel Every Channelgroup
    [Arguments]   ${channelgroup_id}   ${cell_map_node}   ${cell_id}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/channel_for_channelgroup.xml
    Sleep   3s
    ${distName_1}  set variable  ${MRBTS}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-2/CHANNELGROUP-${channelgroup_id}/CHANNEL
    @{distname_list}  Create List
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/channel_for_channelgroup.xml
    ${eles}   XML.Get Elements   ${parsed_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL" and contains(@distName,"${distName_1}")]
    FOR  ${ele}    IN    @{eles}
        ${channel_distname}=   XML.Get Element Attribute  ${ele}   distName  xpath=.
        ${cur_DN}   selenium_coam.get_parameter_value   dist_name=${channel_distname}
        ...  filter_param=Distinguished Name of antenna line   abbr=antlDN
        ${channel_distname}   String.Replace String Using Regexp   ${channel_distname}   LCELNR\-\\d+    LCELNR-${cell_id}
        ${set_DN}   String.Replace String Using Regexp   ${cur_DN}   RMOD\-\\d+   RMOD-${cell_id}
        selenium_coam.set_parameter_value    dist_name=${channel_distname}
        ...  filter_param=Distinguished Name of antenna line  abbr=antlDN  new_value=${set_DN}
    END

Add NRCELL
    [Arguments]  ${cell_id}
    selenium_coam.add_object    object_name=${INSID}    object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${INSID}/NRCELL-2    include_subobject=true    id_value=${cell_id}

Add NRCELLGROUP
    [Arguments]  ${cellgrp_id}
    selenium_coam.add_object    object_name=${INSID}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${INSID}/NRCELLGRP-1   include_subobject=true    id_value=${cellgrp_id}

Set lcrId For New NRCELL
    [Arguments]  ${cell_id}
    selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID   new_value=${cell_id}

Set physCellId For New NRCELL
    [Arguments]  ${cell_id}
    ${physCellId_origin}   selenium_coam.get_parameter_value   dist_name=${INSID}/NRCELL-2  filter_param=Physical cell identifier
    ${physCellId_new}=    Evaluate   ${physCellId_origin}-1
    selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier   new_value=${physCellId_new}

Set nrCellList For New NRCELLGROUP
    [Arguments]  ${cell_id}  ${cellgrp_id}
    selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELLGRP-${cellgrp_id}
    ...    filter_param=List of NR cells assigned to cell group  node_index=${0}  new_value=${cell_id}  abbr=nrCellList

Unlock New RMOD
    [Arguments]  ${cell_id}
    selenium_coam.set_parameter_value    dist_name=${MRBTS}/EQM-1/APEQM-1/RMOD-${cell_id}
    ...    filter_param=Administrative state   new_value=Unlocked  abbr=administrativeState

Add refNrCellGroup For NRCELLGROUP Under NRDU
    [Arguments]  ${cellgrp_id}
    selenium_coam.add element   dist_name=${INSID}/NRDU-1    filter_param=Reference to cell group   abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=${INSID}/NRDU-1
    ...    filter_param=Reference to cell group   node_index=${1}    new_value=${cellgrp_id}   abbr=refNrCellGroup

Add LCELNR For New NRCELL
    [Arguments]  ${cell_id}
    selenium_coam.add_object    object_name=${MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    include_subobject=true
    ...    id_value=${cell_id}
