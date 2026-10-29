# *** Settings ***
# Library    OperatingSystem
# Library   Collections
# Library    taf.transport.ssh   WITH NAME   csn
# 
# Resource   ..${/}common${/}taf_coam.robot
# Resource  .${/}resources${/}case_steps.robot
# Library   libraries${/}ui_operation.py
# Variables    ..${/}libraries${/}global_vars.py
# Resource   ..${/}common${/}coam_resource.robot
# Library   libraries${/}snapshot_files.py
# Resource   resources${/}coam.robot
# Resource   resources${/}call.robot
# Resource   resources${/}FGCR_common.robot
# Suite Setup       cOAM Common Suite Setup
# Suite Teardown    cOAM Common Suite Teardown
# 
# 
# Documentation
# ...    author: fred.li
# ...    contact: fred.li@nokia-sbell.com
# ...    squad group: SG_08
# ...    Feature 5GC0001639-VA in 5G19A program
# 
# Force Tags    CA_5G_OAM      CRT
# ...    PY36
# 
# *** Variables ***
# ${Abil_ADDR}   192.168.253.22
# ${abil_path}   /etc/5g-layer-1/
# ${local_path}   ${OUTPUT_DIR}
# ${filename}   test_modes.conf
# ${L1iq_tgz}    BTS${tl.gnbs[0].global_bts_id}_125D_DL_IqSamples.bin.xz
# ${L1Log_dir}    L1Log
# ${duration}   90
# ${tput}   10
# ${tput_unit}   M
# ${debug_mode}   N
# ${abil_index}   1
# ${cell_id}   8224769
# ${cell_num}    2
# ${BBMOD}    BBMOD_R-1(ABIL)
# ${L3call_cell_index}    2
# 
# 
# *** Test Cases ***
# [1]5GC001681-5GC000794-S_004_snapshot_contains_IQ_Samples_due_to_L1_abnormal_event_ trigger
#      [Documentation]    *****************
#      ...    Basic information
#      ...    *****************
#      ...    this case is to verify IQ data can be collected when L1 abnormal event happened
#      ...    *******************
#      [Tags]    OWNER_fred.li@nokia-sbell.com
#      [Timeout]    30 min
#      [Setup]    Case Setup
#     #    COAM Login   alias=COAM
#     #    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
#     #    Reset Env Parameter
#      common.Set Output Log Path
#      Step1: Configure common configuration
#      Step2: modify L1 configuration files in gnb
#      Step3: Configure common configuration
#      Step4: raise L3 call
#      Step5: decode snapshot and check iq data file
#     #    Check IQ Sample in Snapshot List
#      Log to console   pass
#      [Teardown]    Case Teardown
# 
# *** Keywords ***
# Case Setup
#      COAM WEBUI LOGIN
#      COAM Login
#      ${physCellId}  Wait Until Keyword Succeeds   5m   20s
#      ...   COAM Get Parameter Value   dist_name=MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell_num}  parameter=physCellId
#      set suite variable    ${physCellId}
# 
# Case Teardown
#      COAM WEBUI Logout
#      COAM Logout
# 
# Step1: Configure common configuration
#      [Arguments]    ${subcell_id}=2
#      Wait Until Keyword Succeeds   5m   20s    COAM Try Connect gNB
# #    ${ul}=    Create List    [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${ul}=    Create List    BBMOD_R-1[ABIL] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${ul}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    [BBMOD_R-1(ABIL)] [PCI: 88][1]NRCELL-1: Subcell 0
#      ${ul}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell  ${subcell_id}
# #    ${dl}=    Create List    [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${dl}=    Create List    BBMOD_R-1[ABIL] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${dl}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    [BBMOD_R-1(ABIL)] [PCI: 88][1]NRCELL-1: Subcell 0
#      ${dl}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell  ${subcell_id}
#      selenium_coam.configure_iq_capture  ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
#      ...   enable_capture_on_event=${false}
# 
# 
# Step2: modify L1 configuration files in gnb
#      Wait Until Keyword Succeeds   5m   20s
#      ...    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
#      csn.Connect to    hostname=${Abil_ADDR}    username=${asik_username}    password=${asik_password}    proxy=asik    alias=abil
#      csn.execute    command=confmgmtbrowser write l1sw_trbl prach_preamble_detection_enabled 1   connection=abil
#      csn.execute    command=confmgmtbrowser write l1sw_trbl prach_peak_metric 1.0    connection=abil
#      csn.execute    command=confmgmtbrowser write l1sw_trbl trigger_delay 20    connection=abil
#      [Teardown]    csn.Disconnect     connection=asik
# 
# Step2: reset site
#     COAM Reset Site
# 
# Step3: Configure common configuration
#      [Arguments]    ${subcell_id}=2
#      Wait Until Keyword Succeeds   5m   20s    COAM Try Connect gNB
# #    ${ul}=    Create List    [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${ul}=    Create List    BBMOD_R-1[ABIL] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
#      ${ul}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell  ${subcell_id}
# #    ${dl}=    Create List    [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
# #    ${dl}=    Create List    BBMOD_R-1[ABIL] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell ${subcell_id}
#      ${dl}=    Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}][${L3call_cell_index}]NRCELL-${cell_num}: Subcell  ${subcell_id}
#      selenium_coam.configure_iq_capture  ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
#      ...   enable_capture_on_event=${true}
# 
# Step4: raise L3 call
#     [Arguments]   ${call_mode}=single
#     ${res}   Run Keyword and Ignore Error   Setup Call by mode  call_mode=single
# #    Should Be Equal   ${res[0]}   PASS
#     Run Keyword Unless  '${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
#     Set Suite Variable   ${call_alias}   ${res[1]}
#     sleep   30s
# 
# Step5: decode snapshot and check iq data file
#     COAM Login
#     Get_Coam_Snapshop
# #    ${L1iq_folder}    ${key_L1iq}  snapshot_files.get_file_from_snapshot_by_key   key_name=${L1iq_tgz}   snapshot_structure=${FILE_STRUCT}
# #    run    cd ${OUTPUT_DIR}/snapshot/;unzip -d ${L1Log_dir} ${L1iq_folder}
# #    ${result}   run    cd ${OUTPUT_DIR}/snapshot/${L1Log_dir};tar -xvf ${L1iq_tgz}
# #    should contain    container=${result}   item=bin
# #    ${row}    snapshot_files.decode_snapshot    ${OUTPUT_DIR}/snapshot    IqSamples
#     ${values}    Get Dictionary Values    ${FILE_STRUCT}
#     :FOR  ${list}   IN   @{values}
#          ${status}    run keyword and return status    Should Contain Match    ${list}    regexp=\\S+IqSamples\\S+
#          exit for loop if   ${status}
#     END
#     should be true    ${status}
# 
# #Check IQ Sample in Snapshot List
# #    COAM Login
# #    ${snapshot_filename}    Catch Snapshot COAM
# #    COAM Logout
# #    run   rm -rf ${OUTPUT_DIR}/snapshot
# #    ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
# #    run   ${command_unzip}
# #    ${row}    snapshot_files.decode_snapshot    ${OUTPUT_DIR}/snapshot    IqSamples
# 
# Get_Coam_Snapshop
#     ${snapshot_filename}    Catch Snapshot COAM
#     run   rm -rf ${OUTPUT_DIR}/snapshot
#     ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
#     run   ${command_unzip}
#     ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    ${OUTPUT_DIR}/snapshot
#     set suite variable   ${FILE_STRUCT}
