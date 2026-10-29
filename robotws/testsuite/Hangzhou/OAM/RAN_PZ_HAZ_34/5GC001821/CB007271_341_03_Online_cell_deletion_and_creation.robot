# *** Settings ***
# Documentation    5GC000702_AAHF_AAHJ_General_SiSo_Cells_Sectors_number_change_scenario
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
# Variables   ./Library/config_vars.py
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# Force Tags   SG_08   CA_5G_Siso         CRT   AUTHOR_johnny.1.jiang@nokia-sbell.com
# ...    PY36
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# ${nrbts_id}=    NRBTS-${tl.gnbs[0].instance_id}
# ${BTS_ID}=    ${tl.gnbs[0].global_bts_id}
# ${plan_copy_from}=   CURRENT_BTS_CONF-1
# 
# 
# *** Test Cases ***
# [1]CB007271_341_03_Online_cell_deletion_and_creation
#     [Timeout]    5h
#     [Setup]   Run Keywords    Case Setup
#     ...   AND    COAM Backup SCF
#     ...   AND    COAM SCF Commission
#     ...   filepath=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL873_3S1CC_22R3.xml
# #    Set Common Test Tag   case_key=cell_number_change
#     COAM Login
#     Wait Until Keyword Succeeds   10min   1min   COAM Check All Cells Onair
#     Change cell scenario
#     [Teardown]    Run Keywords    COAM Login
#     ...   AND    COAM SCF Commission
#     ...   AND    Run Keyword and Ignore Error    Case Teardown
# 
# *** Keywords ***
# Load
# Change cell scenario
#     ${bts_info}   coam.get_bts_info   connection=COAM   timeout=${30}
#     ${cell_num_before}   Get length   ${bts_info['cells']['nr']}
#     ${cell_num_before}       Convert To Integer       ${cell_num_before}
#     ${cell_num_after}   set variable   ${cell_num_before-1}
# #    ${cell_type}    Read Cell Type
# #    :FOR   ${index}    IN RANGE    ${cell_num_before}
# #        Remove Cell ${index+1}
# #        Check BTS Normal ${cell_num_after}
# #        Recovery Cell   index=${index+1}   cell_type=${cell_type}
# #        Check BTS Normal ${cell_num_before}
# #     END
#     Remove Cell 1
#     Check BTS Normal ${cell_num_after}
#     Recovery Cell 1
#     Check BTS Normal ${cell_num_before}
#     Remove Cell 3
#     Check BTS Normal ${cell_num_after}
#     Recovery Cell 3
#     Check BTS Normal ${cell_num_before}
# 
# Remove Cell ${index}
#     ${index}       Convert To Integer       ${index}
#     log to console    remove cell ${index}
#     COAM WEBUI Login   display=${${DEBUG}}
#     COAM Login
#     selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${index}
#     selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELLGRP-${index-1}
#     selenium_coam.remove_object     object_name=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}
#     ${node_index}    set variable if    ${index}==1  0  1
#     selenium_coam.remove_element    dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRDU-1
#     ...     filter_param=Reference to cell group    node_index=${node_index}
#     run keyword and ignore error   selenium_coam.validate_plan
#     run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}
#     ...   activate_plan_despite_errors=${True}    execute=${True}
#     sleep  2m
#     Wait Until Keyword Succeeds   10min   1min   COAM Check All Cells Onair
#     COAM Logout
#     COAM WEBUI Whether Close Start Up View Window
#     COAM WEBUI Logout    display=${${DEBUG}}
# 
# Check BTS Normal ${ru_num}
#     COAM Login
#     ${bts_info}   coam.get_bts_info   connection=COAM   timeout=${30}
#     ${cell_num}   Get length   ${bts_info['cells']['nr']}
#     ${ru_num_int}       Convert To Integer       ${ru_num}
#     should be equal     ${cell_num}     ${ru_num_int}
#     Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#     COAM Logout
# 
# Recovery Cell ${index}      
#     ${index}       Convert To Integer       ${index}
#     log to console    recover cell ${index}
# #    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
# #    run keyword if   '${index}'!='${L3CALL_cellid}'
# #    ...   run keyword and continue on failure     Wait Until Keyword Succeeds   2x   1m
# #    ...   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#     COAM WEBUI Logout    display=${${DEBUG}}
#     COAM WEBUI Login   display=${true}
#     COAM Login
#     Add Cell   index=${index}  
#     Add Cell Group   index=${index}
#     COAM WEBUI Logout   display=${${DEBUG}}
#     COAM WEBUI Login   display=${${DEBUG}}
#     COAM Logout
#     run keyword and continue on failure     Wait Until Keyword Succeeds   2x   1m
#     ...   Data Transfer Conducted    cell_index=${L3CALL_cellid}    direction=DL
# 
# Add Cell
#     [Arguments]     ${index}   
#     ${copy_index}=   Set Variable If
#     ...   '${index}'=='1'   2   1
#     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELL
#      ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
#      ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${copy_index}
#      ...   id_value=${index}   include_subobject=${true}
#      selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Physical cell identifier
#      ...   new_value=${index-1}
#      selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=Local cell resource ID
#      ...   new_value=${index}
# #     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELL-${index}   filter_param=List of RMOD distinguished names
# #     ...   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}   node_index=${0}
#      selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
#      ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
#      ...   copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_index}
#      ...   id_value=${index}   include_subobject=${true}
#      4DL4UL   index=${index}
#      selenium_coam.add_element   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1   filter_param=Reference to cell group
#      ${index}   Convert To Integer   ${index}
#      selenium_coam.set_parameter_value
#      ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRDU-1
#      ...   filter_param=Reference to cell group
#      ...   new_value=${index-1}
#      ...   node_index=${2}
#      ...   abbr=refNrCellGroup
# 
# Add Cell Group
#     [Arguments]     ${index}
#     log to console    add cellgroup ${index}
#     ${index}   Convert To Integer   ${index}
#     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/${nrbts_id}   object_class_name=NRCELLGRP
#      ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
#      ...   copy_from=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-1
#      ...   id_value=${index-1}   include_subobject=${true}
#      selenium_coam.set_parameter_value
#      ...   dist_name=MRBTS-${BTS_ID}/${nrbts_id}/NRCELLGRP-${index-1}
#      ...   filter_param=List of NR cells assigned to cell group
#      ...   new_value=${index}
#      ...   node_index=${0}
#      ...   abbr=nrCellList
#      run keyword and ignore error   selenium_coam.validate_plan
#      run keyword and ignore error   selenium_coam.activate_plan  download_plan_without_activation=${False}
#      ...   activate_plan_despite_errors=${True}    execute=${True}
# 
# 2DL2UL
#     log to console   pass
# 
# 4DL2UL
#     [Arguments]     ${index}
#      :FOR   ${int}    IN RANGE    6
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
#         ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
#      END
# 
# 4DL4UL
#     [Arguments]     ${index}
# #     :FOR   ${int}    IN RANGE    8
# #        ${ANTLID}    Evaluate     int(2*int(${int/2})+1)
# #        run keyword and ignore error   selenium_coam.set_parameter_value
# #        ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
# #        ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-${ANTLID}
# #     END
#     :FOR   ${int}    IN RANGE    2
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
#         ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-1
#      END
#     :FOR   ${int}    IN RANGE    2
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+3}
#         ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-2
#      END
#     :FOR   ${int}    IN RANGE    2
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+5}
#         ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-3
#      END
#     :FOR   ${int}    IN RANGE    2
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+7}
#         ...   filter_param=Distinguished Name of antenna line   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/ANTL-4
#     END
# 
# 8DL4UL
#     [Arguments]     ${index}
#      :FOR   ${int}    IN RANGE    8
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-1/CHANNEL-${int+1}
#         ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
#      END
#      :FOR   ${int}    IN RANGE    4
#         run keyword and ignore error   selenium_coam.set_parameter_value
#         ...   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}/CHANNELGROUP-2/CHANNEL-${int+1}
#         ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${index}/PHYANT-1
#      END
