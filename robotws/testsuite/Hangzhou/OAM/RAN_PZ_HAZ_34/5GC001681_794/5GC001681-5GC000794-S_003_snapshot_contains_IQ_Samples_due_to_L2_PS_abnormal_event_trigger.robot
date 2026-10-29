# *** Settings ***
# Documentation
# ...   author:Fred Li
# ...   contact: fred.li@nokia-sbell.com
# Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
# Library   taf.transport.ssh   WITH NAME   csn
# Resource  .${/}resources${/}case_steps.robot
# Variables   .${/}..${/}libraries${/}global_vars.py
# Resource   .${/}resources${/}decode.robot
# Library   libraries${/}snapshot_files.py
# Library    OperatingSystem
# Library   Collections
# 
# Resource   ..${/}common${/}taf_coam.robot
# Library   libraries${/}ui_operation.py
# Resource   ..${/}common${/}coam_resource.robot
# Resource   resources${/}coam.robot
# Resource   resources${/}call.robot
# Resource   resources${/}FGCR_common.robot
# Force Tags   SG_08   CA_5G_OAM         CRT
# ...    PY36
# 
# *** Variables ***
# ${Snapshot_path}    ${OUTPUT_DIR}/snapshot
# ${ASIx_ADDR}   ${WEBUI_ADDR}
# ${MO_NAME}  ${tl.gnbs[0].global_bts_id}
# ${BBMOD}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
# ${L1iq_tgz}    BTS${tl.gnbs[0].global_bts_id}_1011_Node125D_IqSamples.tgz
# ${L1Log_dir}    L1Log
# 
# *** Test Cases ***
# [1]5GC001681-5GC000794-S_003_snapshot_contains_IQ_Samples_due_to_L2_PS_abnormal_event_trigger
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify IQ data and probe log can be collected when L2 abnormal event happened
#     ...    *******************
#     [Tags]    OWNER_fred.li@nokia-sbell.com
#     [Timeout]    30 min
#     [Setup]
# #    Case Setup
# #    Step1: modify swconfig file in gnb and reset
# #    Step2: configure trace capture
# #    Step3: check snapshot
# #    Check IQ Sample in Snapshot List
#      LOG    PASS EXECUTION
# #    Log to console   pass
#     [Teardown]   
# 
# *** Keywords ***
# Step1: modify swconfig file in gnb and reset
#     csn.Connect to    hostname=${ASIx_ADDR}    username=${asik_username}    password=${asik_password}    alias=asik
#     csn.Download File   remote_path=/rom/swconfig.txt
#     ...   local_path=${OUTPUT_DIR}/swconfig.txt     connection=asik
#     csn.execute    command=echo -e "0x58016c=10\n0x5800f7=1\n0x5800f8=3221225472" >> /rom/swconfig.txt
#     ...   connection=asik
#     csn.execute    command=crasign /rom/swconfig.txt  connection=asik
#     selenium_coam.reset_site
#     [Teardown]   csn.Disconnect     connection=asik
# 
# Step2: configure trace capture
# #    Wait Until Keyword Succeeds   15min    10s   Run Keyword   cOAM Common Test Setup
#     sleep  12min
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     ${ul}=    Create List    1
#     ${dl}=    Create List    0
#     ${release}   Get gnb release
#     run keyword if   '${release}'=='5G20B'
#     ...   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index=1   dl_subcell_index=0    enable_capture_on_event=${True}
#     ...   ELSE   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index_list=${ul}
#     ...   dl_subcell_index_list=${dl}    enable_capture_on_event=${True}
#     sleep  5min
# 
# Step3: check snapshot
#     Get_Coam_Snapshop
#     ${L1iq_folder}    ${key_L1iq}  snapshot_files.get_file_from_snapshot_by_key   key_name=${L1iq_tgz}   snapshot_structure=${FILE_STRUCT}
#     run    cd ${OUTPUT_DIR}/snapshot/;unzip -d ${L1Log_dir} ${L1iq_folder}
#     ${result}   run    cd ${Snapshot_path}/${L1Log_dir};tar -xvf ${L1iq_tgz}
#     should contain    container=${result}   item=bin
# 
# Get_Coam_Snapshop
#     COAM Login
#     ${snapshot_filename}    Catch Snapshot COAM
#     COAM Logout
#     run   rm -rf ${Snapshot_path}
#     ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${Snapshot_path}
#     run   ${command_unzip}
#     ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${Snapshot_path}
#     set suite variable   ${FILE_STRUCT}
# 
# Check IQ Sample in Snapshot List
#     COAM Login
#     ${snapshot_filename}    Catch Snapshot COAM
#     run   rm -rf ${Snapshot_path}
#     ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${Snapshot_path}
#     run   ${command_unzip}
#     ${row}    snapshot_files.decode_snapshot    ${Snapshot_path}    IqSamples
#     [Teardown]   COAM Logout
# 
# Case Setup
#     taf_coam.COAM WEBUI LOGIN
# 
# Case Teardown
#     taf_coam.COAM WEBUI LOGOUT
#     csn.Connect to    hostname=${ASIx_ADDR}    username=${asik_username}    password=${asik_password}    alias=asik1
# #    csn.Upload File   local_path=${OUTPUT_DIR}/swconfig.txt   remote_path=/rom/swconfig.txt   connection=asik1
# #    csn.execute    command=crasign /rom/swconfig.txt  connection=asik1
#     [Teardown]    csn.Disconnect     connection=asik1
# 
# 
# Decode Snapshot and Check iq data file
#     [Arguments]     ${snapshot_name}
#     run   rm -rf ${Snapshot_path}
#     ${command_unzip}    Set Variable    unzip ${snapshot_name} -d ${Snapshot_path}
#     run   ${command_unzip}
#     ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${Snapshot_path}
#     set suite variable   ${FILE_STRUCT}
#     ${L1iq_folder}    ${key_L1iq}  snapshot_files.get_file_from_snapshot_by_key      key_name=${L1iq_tgz}     snapshot_structure=${FILE_STRUCT}
#     run    cd ${Snapshot_path}/;unzip -d ${L1Log_dir} ${L1iq_folder}
#     ${result}   run    cd ${Snapshot_path}/${L1Log_dir};tar -xvf ${L1iq_tgz}
#     should contain    container=${result}   item=bin