# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   AP    owner_changyli
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_2AEQE_CASE20_APLO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_CASE20_LO.xml
# ${WTS_NAME}       WTS_2AEQE_CASE20_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# 
# 
# *** Test Cases ***
# 5GC001729_Case20_A_5c_2CC_CA_blindaddtion_BufferActivation_deactivation
#     Enable RD syslog in AP Swconfig
#     Add counter timer in gnb Swconfig
#     Prepare gnb onair
# #	Online change to blind addition active
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Internal send DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Check throughput
# 	Stop data to trigger deactive
# 	Check Scell deactive
# 	resume data to trigger good threshold and scell resume
# 	Check Scell active
#     Stop data transfer
#     Detach UE
#     :For    ${id}    IN RANGE   1   101
#     \    Log To Console    id:${id}
#     \    Attach ue send data and detach ue
#     \    Wait '1s' for stabible
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Stop data to trigger deactive
#     Airphone SA Stop Data Traffic    ue_id=1    direction=dl    pdu_id=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check Scell no throughput
# 
# resume data to trigger good threshold and scell resume
#     Internal send DL data
# 
# Add counter timer in gnb Swconfig
#         Add GNB swconfig    0x340000:15
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# 
# Check Scell RLQ deactive
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb_1
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap_1
# 
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Override Scell CQI trigger bad threshold
#     Airphone Cqi Param
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell no throughput
# 
# Override Scell CQI trigger morebad threshold
#     Airphone Cqi Param
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell no throughput
# 
# Override Scell CQI trigger good threshold and scell resume
#     Airphone Cqi Param    nr_cqi=15
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell have throughput
# 
# Check PM counter scell no throughput
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     run keyword if    ${PM_counter_value}>0    Check PM counter scell no throughput again
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
#     Check throughput
# 
# Override Scell CQI trigger good threshold and scell not resume
#     Airphone Cqi Param    nr_cqi=15
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell no throughput
# 
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Internal send DL data
#     Internal send mutiple trf '15' for each '175M' DL data
# 
# Check throughput
#     wait '10s' for stable
#     Wait until keyword succeeds    60s    15s    Check throughput peak
# 
# Check PM counter scell no throughput again
#     Wait until keyword succeeds    120s    20s    Check pm counter M55310C01006 in cell 2 is expected == 0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
#     Airphone Cqi Param    nr_cqi=15
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Online change to blind addition active
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-2    sCellAdditionMethod    blind    online
#     Wait '2s' for stabible
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAddition    false    online
#     Wait '2s' for stabible
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAdditionNsa    false    online
#     Wait '5s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# 
# 
# Check throughput peak
#     ${pcell_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0   type=pdsch    tput_type=ave
#     Log To Console    pcell_tput:${pcell_throughput}
#     should_be_true    ${pcell_throughput}>700000
#     ${scell_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1   type=pdsch    tput_type=ave
#     Log To Console    scell_tput:${scell_throughput}
#     should_be_true    ${scell_throughput}>700000
#     ${total_tput}    evaluate    ${pcell_throughput}+${scell_throughput}
#     should_be_true    ${total_tput}>1500000
# 
# Check big throughput
#     [Arguments]    ${scell_id}=0    ${throughput}=600000
#     ${dl_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=ave
#     Log To Console    cell_tp:${dl_throughput}
#     should_be_true    ${dl_throughput}>${throughput}
# 
# Check throughput equal
#     [Arguments]    ${scell_id}=1    ${throughput}=0
#     ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=current
#     should_be_true    ${dl_throughput_scell}==${throughput}
# 
# Check Pcell throughput
#     Wait until keyword succeeds    60s    5s    Check big throughput
# 
# Check Scell no throughput
#     Wait until keyword succeeds    60s    5s    Check throughput equal    1
# 
# Send mutiple trf '${number}' for each '${dl_data}' DL data in '${ue_id}' ue
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    DL    ${dl_data}    pdu_id=${PDU_ID}    duration=6000s    trf_id=${num}
# 
# Attach ue send data and detach ue
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Internal send DL data
#     Wait '1s' for stabible
#     Check throughput
#     Detach UE
