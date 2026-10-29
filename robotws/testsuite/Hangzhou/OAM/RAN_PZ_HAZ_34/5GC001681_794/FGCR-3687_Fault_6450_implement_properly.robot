# *** Settings ***
# Documentation
# ...   author:Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# Resource  .${/}resources${/}FGCR_common.robot
# Force Tags   SG_08   CA_5G_OAM         CRT
# ...    PY36
# 
# *** Variables ***
# ${L1iq_tgz}    BTS${tl.gnbs[0].global_bts_id}_1011_Node125D_IqSamples.tgz
# ${L1Log_dir}    L1Log
# ${ASIx_ADDR}   ${WEBUI_ADDR}
# #${asik_username}   toor4nsn
# #${asik_password}   oZPS0POrRieRtu
# ${Abil_ADDR}   192.168.253.22
# ${abil_path}   /etc/5g-layer-1/
# ${local_path}   ${OUTPUT_DIR}
# ${filename}   test_modes.conf
# #${WEBUI_ADDR}   ${ASIx_ADDR}
# ${WEBUI_USER}   Nemuadmin
# ${WEBUI_PASSWORD}   nemuuser
# 
# *** Test Cases ***
# [1]FGCR-3687_Fault_6450_implement_properly
#     [Setup]
# #    Step1: modify L1 configuration files in gnb
# #    Step2: reset site
# #    ${snapshot_before_list}     Get Snapshot List
# #    ${status_before}    Check alarm id in list   exp_alarm_id=6450
# #    should be true    '${status_before}'=='False'
# #    ${ul}=    Create List    1
# #    ${dl}=    Create List    0
# #    ${release}   Get gnb release
# #    run keyword if   '${release}'=='5G20B'
# #    ...   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index=1   dl_subcell_index=0    enable_capture_on_event=${True}
# #    ...   ELSE   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index_list=${ul}
# #    ...   dl_subcell_index_list=${dl}    enable_capture_on_event=${True}
# #    L3 Call
# #    ${status_after}    Check alarm id in list   exp_alarm_id=6450
# #    should be true    '${status_after}'=='True'
# #    sleep  2m
# #    ${snapshot_after_list}     Get Snapshot List
# #    ${snapshot_name}    snapshot_files.filter_new_snapshot_file_by_btsid   old_file_list=${snapshot_before_list}
# #    ...   new_file_list=${snapshot_after_list}
# #    ...    bts_id=${MO_NAME}
# #    Download Snapshot to VM     snapshot_name=${snapshot_name}
# #    Decode Snapshot and Check iq data file for 6450      snapshot_name=${snapshot_name}
#     Log to console   pass
#     [Teardown]
# 
# *** Keywords ***
# Wait for Site Unavailability
#     ${output}    RUN    ping ${LMP_ADDR} -c 3
#     ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
#     ${output}    Fetch From Left    ${output[0]}    %
#     should be true    ${${output}}> ${90}
# 
# Decode Snapshot and Check iq data file for 6450
#     [Arguments]     ${snapshot_name}
#     run   rm -rf ${OUTPUT_DIR}/snapshot
#     ${command_unzip}    Set Variable    unzip ${snapshot_name} -d ${OUTPUT_DIR}/snapshot
#     run   ${command_unzip}
#     ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
#     set suite variable   ${FILE_STRUCT}
#     ${L1iq_folder}    ${key_L1iq}  snapshot_files.get_file_from_snapshot_by_key   key_name=${L1iq_tgz}   snapshot_structure=${FILE_STRUCT}
#     run    cd ${OUTPUT_DIR}/snapshot/;unzip -d ${L1Log_dir} ${L1iq_folder}
#     ${result}   run    cd ${OUTPUT_DIR}/snapshot/${L1Log_dir};tar -xvf ${L1iq_tgz}
#     should contain    container=${result}   item=bin
