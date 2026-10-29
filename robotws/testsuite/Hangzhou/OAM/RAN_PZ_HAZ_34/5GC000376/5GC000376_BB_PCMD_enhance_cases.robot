# *** Settings ***
# Documentation
# ...  author : liangliang.heng@nokia-sbell.com
# ...  contact: liangliang.heng@nokia-sbell.com   liping.hong@nokia-sbell.com
# 
# Resource        Resource/common.robot
# 
# Force Tags   SG_07   CA_5G_OAM   CRT
# ...    PY36
# ...   RAN_5G   RAN_5G_TDD
# Suite Setup    Setup Sequence
# Suite Teardown    Teardown Sequence
# Test Setup   PCMD Common Case Setup
# Test Teardown   PCMD Common Case Teardown
# 
# *** Test Cases ***
# 5GC000376_BB_100_PCMD_ulTimeUeSched_SUlSchedulingTraceRecord_Counter_Enhancement
#     [Documentation]
#     ...     This script Check the counter of the report indicated in its name
#     ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
#     log to console     check elemnet  ulTimeUeSched_SUlSchedulingTraceRecord
#     Load Pcap File with Filter
#      ...                        pcap_file=${Log_directory}/${filename5}
#      ...                        record_type=Du
#      ...                        input_type=3
#      ...                        filter=tcp.dstport==49148
#     ${ulSchedulingRecord_endMark_list}=    wireshark.get_field_value_by_xpath
#     ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.endMarker
#     ${ulTimeUeSched_value_list}=    wireshark.get_field_value_by_xpath
#     ...   xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.timeOfUeSched
#     Run Keyword If    0 < @{ulTimeUeSched_value_list}[0] < 134273 or @{ulTimeUeSched_value_list}[0]==0
#     ...    Log To Console   first value is OK
#     ${ulTimeUeSched_length}=     Get Length   ${ulTimeUeSched_value_list}
#     : FOR   ${idx}    IN RANGE    1    ${ulTimeUeSched_length}
#         Run Keyword If    131073 < @{ulTimeUeSched_value_list}[${idx}] < 134273
#         ...   Should Be True   @{ulSchedulingRecord_endMark_list}[${idx-1}] ==1
#         ...   ELSE    Should Be True   0 < @{ulTimeUeSched_value_list}[${idx}] < 131073 or @{ulTimeUeSched_value_list}[${idx}]==0
#     END
#     Log To Console   check value is OK
# 
# #5GC000376_BB_101_PCMD_dlRlcPduTxBytes_DL_RLCTraceRecord_Counter_Enhancement
# #    [Documentation]
# #    ...     This script Check the counter of the report indicated in its name
# #    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
# #    log to console    check elemnet  dlRlcPduTxBytes_DL_RLCTraceRecord
# #    ${filtered_dlRbRlcMeasRecord_packets}    Load Pcap File with Filter
# #    ...                        input_file=${Log_directory}/${filename5}
# #    ...                        record_type=Du
# #    ...                        input_type=6
# #    ...                        filter=tcp.dstport==48151
# #    ${dlRbRlcMeasRecord_endMark_list}=    wireshark.get_field_value_by_xpath
# #    ...   pdml_list=${filtered_dlRbRlcMeasRecord_packets}
# #    ...   xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.endMarker
# #    ${dlRlcPduTxBytes_value_list}=    wireshark.get_field_value_by_xpath
# #    ...  pdml_list=${filtered_dlRbRlcMeasRecord_packets}
# #    ...  xpath=.//nsetapx.dlRbRlcMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.DlRadioBearerRlcMeasData_eleme
# ...nt/nsetapx.sumOfRlcPduTxBytes
# #    Run Keyword If    0 < @{dlRlcPduTxBytes_value_list}[0] < 2533693758 or @{dlRlcPduTxBytes_value_list}[0]==0
# #    ...    Log To Console   first value is OK
# #    ${dlRlcPduTxBytes_length}=     Get Length   ${dlRlcPduTxBytes_value_list}
# #    : FOR   ${idx}    IN RANGE    1    ${dlRlcPduTxBytes_length}
# #        Run Keyword If     2473310208 < @{dlRlcPduTxBytes_value_list}[${idx}] < 2533693758
# #        ...   Should Be True   @{dlRbRlcMeasRecord_endMark_list}[${idx-1}] ==1
# #        ...   ELSE    Should Be True   0 < @{dlRlcPduTxBytes_value_list}[${idx}] < 2473310208 or @{dlRlcPduTxBytes_value_list}[${idx}]==0
# #    END
# #    Log To Console   check value is OK
# 
# 
# *** Keywords ***
# Setup Sequence
#     robot_common_operations.Common Suite Setup
#     Wait Until Keyword Succeeds   3 times   2m   COAM Login
#     Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
# #    COAM WEBUI Save BTS Configuration
#     COAM Backup SCF
#     ${release}   Get gnb release   host=${WEBUI_ADDR}
#     Run Keyword If   '${release}' >= 'SBTS23R4'    COAM SCF Commission    filepath=/home/ute/lheng/5GC000376_BB_PCMD_enhance_cases_Trunk.xml
#     Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
#     log to console    BTS is on air
#     log to console   Start to Remove the NRCELL-1 and NRCELLGROUP-0 online
#     Remove the cell and cellgrp online    cell_id=1   cellgrp_id=0  connection=COAM
#     log to console   Start to add the NRCELL-1 and NRCELLGROUP-0 online
#     run keyword and ignore error   COAM WEBUI Logout
#     COAM Reset Site
#     log to console    reset Site
#     Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
#     log to console    Remove PCMD Object
# #    COAM Remove PCMD Object via API
#     Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
#     run keyword and ignore error   Remove PCMD Object
#     Add PCMD Object
#     log to console    Add PCMD Object
#     run keyword and ignore error   COAM WEBUI Logout
# #    COAM Add PCMD Object via API
#     Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
#     Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
#     Add the cell and cellgrp online   cell_id=1  cellgrp_id=0  connection=COAM
#     Validate and Activate Plan
# ##    log to console    Remove PCMD Object
# ##    run keyword and ignore error   Remove PCMD Object
# ##    log to console    Add PCMD Object
# ##    Add PCMD Object
#     Set Environment Variable              https_proxy                 ${empty}
# 	Run Keyword And Ignore Error   UE soft reboot   ue_index=${ue_index}   detach_request=${false}
#     asik_handler.connect                i_ipAddr=${ASIK_IP}
#     log to console    start tcpdump
#     ${SMOD_name}   Get SMOD Product Name
#     log to console   SMOD_name=${SMOD_name}
#     Run Keyword If     '${SMOD_name}'=='ASIB'
#     ...           asik_handler.general_tcpdump_ASIB   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#     ...   ELSE IF  '${SMOD_name}'=='ASIK'  asik_handler.general_tcpdump_ASIK   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#     ...   ELSE   asik_handler.general_tcpdump_ASOE   i_dir_path=${remote_dir_path}   i_filename=${filename5}
#     Run Keyword and Ignore Error   Wait Until Keyword Succeeds   3x   20s
#     ...   Call Setup and check tput   duration=180    tput=1000    tput_expect=100   4G_check=true
#     asik_handler.kill_tcpdump
#     Sleep   5s
#     Run keyword and Ignore error  asik_handler.close
#     Create Directory     ${Log_directory}
#     asik_handler.connect                i_ipAddr=${ASIK_IP}
#     asik_handler.download_file_from_Asik	i_filename=${remote_dir_path}/${filename5} 	i_local_path=${Log_directory}/${filename5}
#     Run Keyword and Ignore Error   Check Extra Reset From Blackbox
# 
# Teardown Sequence
#     run keyword and ignore error   asik_handler.close
#     run keyword and ignore error   COAM WEBUI Load SCF
#     run keyword and ignore error   Validate and Activate Plan
#     run keyword and ignore error   COAM WEBUI Logout
#     run keyword and ignore error   COAM Logout
#     robot_common_operations.Common Suite Teardown
# 
# PCMD Common Case Setup
#     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     run keyword and ignore error   Start Catch Relative Log   log_dir_name=${TEST NAME}
# 
# PCMD Common Case Teardown
#     Check Extra Reset From Blackbox
#     run keyword if test failed  Collect Relative Log
#     run keyword if test passed   Delete BTS log in VM
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Remove the cell and cellgrp online
#     [Arguments]  ${cell_id}  ${cellgrp_id}  ${connection}
#     ${cell_object}  Set Variable   {"distName": "${INSID}/NRCELL-${cell_id}", "operation": "delete", "parameters": []}
#     ${cellgrp_object}  Set Variable  {"distName": "${INSID}/NRCELLGRP-${cellgrp_id}", "operation": "delete", "parameters": []}
#     ${lcelnr_object}  Set Variable  {"distName": "${BTSID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}", "operation":
# ... "delete", "parameters": []}
#     ${parameterName}  Set Variable  {"parameterName": "refNrCellGroup","value": ["1"],"operation": "update"}
#     ${refNrCellGroup_2}   Set Variable  {"distName": "${INSID}/NRDU-1", "operation": "update", "parameters": [${parameterName}]}
#     ${delta_file}   Set Variable   [${cell_object},${cellgrp_object},${lcelnr_object},${refNrCellGroup_2}]
#     COAM Perform Delta Recommission
#     ...   delta_file=${delta_file}
#     ...   connection=${connection}
# 
# Add the cell and cellgrp online
#     [Arguments]  ${cell_id}  ${cellgrp_id}   ${connection}
#     Add NRCELL  cell_id=${cell_id}
#     Add NRCELLGROUP  cellgrp_id=${cellgrp_id}
#     Set lcrId For New NRCELL   cell_id=${cell_id}
#     Set physCellId For New NRCELL   cell_id=${cell_id}
#     Set nrCellList For New NRCELLGROUP   cellgrp_id=${cellgrp_id}   cell_id=${cell_id}
#     Unlock New RMOD   cell_id=${cell_id}
#     Add refNrCellGroup For NRCELLGROUP Under NRDU   cellgrp_id=${cellgrp_id}
#     ${cell_map_node_list}   selenium_coam.get_object_name_list   CELLMAPPING
#     Log To Console  cell_map_node_list: ${cell_map_node_list}
#     ${cell_map_node}   Set Variable   ${cell_map_node_list[0]}
#     ${channel_group_node_list}   selenium_coam.get_object_name_list
#     ...  object_name=${BTSID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-${cell_id}/CHANNELGROUP-
#     Log To Console  channel_group_node_list: ${channel_group_node_list}
#     ${channel_group_number}=   get length   ${channel_group_node_list}
#     Add LCELNR For New NRCELL    cell_id=${cell_id}
#     FOR  ${idx}    IN RANGE    1   ${channel_group_number+1}
#         Change resourceDN For Every Channel Every Channelgroup   channelgroup_id=${idx}  cell_map_node=${cell_map_node}  cell_id=${cell_id}
#     END
#     run keyword and continue on failure    selenium_coam.validate_plan
#     ${relation_errors}      selenium_coam.get_relation_errors
#     ${hardware_errors}      selenium_coam.get_hardware_errors
#     ${definition_errors}    selenium_coam.get_definition_errors
# 
# Change resourceDN For Every Channel Every Channelgroup
#     [Arguments]  ${channelgroup_id}  ${cell_map_node}  ${cell_id}
# #    COAM WEBUI Save BTS Configuration   SCF_path=${Log_directory}/channel_for_channelgroup.xml
#     COAM Backup SCF   local_dir=${Log_directory}   file_name=channel_for_channelgroup.xml
#     Sleep   3s
#     ${distName_1}  set variable  ${BTSID}/MNL-1/MNLENT-1/${cell_map_node}/LCELNR-2/CHANNELGROUP-${channelgroup_id}/CHANNEL
#     @{distname_list}  Create List
#     ${parsed_xml}   XML.Parse XML   ${Log_directory}/channel_for_channelgroup.xml
#     ${eles}   XML.Get Elements   ${parsed_xml}
#     ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL" and contains(@distName,"${distName_1}")]
#     FOR  ${ele}    IN    @{eles}
#         ${channel_distname}=   XML.Get Element Attribute  ${ele}   distName  xpath=.
#         ${cur_DN}   selenium_coam.get_parameter_value   dist_name=${channel_distname}
#          ...  filter_param=Distinguished Name of antenna line   abbr=antlDN
#         ${channel_distname}   String.Replace String Using Regexp   ${channel_distname}   LCELNR\-\\d+    LCELNR-${cell_id}
#          ${set_DN}   String.Replace String Using Regexp   ${cur_DN}   RMOD\-\\d+   RMOD-${cell_id}
#          selenium_coam.set_parameter_value    dist_name=${channel_distname}
#          ...  filter_param=Distinguished Name of antenna line  abbr=antlDN  new_value=${set_DN}
#     END
# 
# Add NRCELL
#     [Arguments]  ${cell_id}
#     selenium_coam.add_object    object_name=${INSID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${INSID}/NRCELL-2    include_subobject=true    id_value=${cell_id}
# 
# Add NRCELLGROUP
#     [Arguments]  ${cellgrp_id}
#     selenium_coam.add_object    object_name=${INSID}    object_class_name=NRCELLGRP
#     ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${INSID}/NRCELLGRP-1   include_subobject=true    id_value=${cellgrp_id}
# 
# Set lcrId For New NRCELL
#     [Arguments]  ${cell_id}
#     selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELL-${cell_id}
#     ...    filter_param=Local cell resource ID   new_value=${cell_id}
# 
# Set physCellId For New NRCELL
#     [Arguments]  ${cell_id}
#     ${physCellId_origin}   selenium_coam.get_parameter_value   dist_name=${INSID}/NRCELL-2  filter_param=Physical cell identifier
#     ${physCellId_new}=    Evaluate   ${physCellId_origin}-1
#     selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELL-${cell_id}
#     ...    filter_param=Physical cell identifier   new_value=${physCellId_new}
# 
# Set nrCellList For New NRCELLGROUP
#     [Arguments]  ${cell_id}  ${cellgrp_id}
#     selenium_coam.set_parameter_value    dist_name=${INSID}/NRCELLGRP-${cellgrp_id}
#     ...    filter_param=List of NR cells assigned to cell group  node_index=${0}  new_value=${cell_id}  abbr=nrCellList
# 
# Unlock New RMOD
#     [Arguments]  ${cell_id}
#     selenium_coam.set_parameter_value    dist_name=${BTSID}/EQM-1/APEQM-1/RMOD-${cell_id}
#     ...    filter_param=Administrative state   new_value=Unlocked  abbr=administrativeState
# 
# Add refNrCellGroup For NRCELLGROUP Under NRDU
#     [Arguments]  ${cellgrp_id}
#     selenium_coam.add element   dist_name=${INSID}/NRDU-1    filter_param=Reference to cell group   abbr=refNrCellGroup
#     selenium_coam.set_parameter_value    dist_name=${INSID}/NRDU-1
#     ...    filter_param=Reference to cell group   node_index=${1}    new_value=${cellgrp_id}   abbr=refNrCellGroup
# 
# Add LCELNR For New NRCELL
#     [Arguments]  ${cell_id}
#     selenium_coam.add_object    object_name=${BTSID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${BTSID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    include_subobject=true
#     ...    id_value=${cell_id}
