# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G   owner_l3gao
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    2TDD_CA
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# Documentation     beamform_beamset6 8mhz_80mhz refinebeam_false 4DL2UL dlmimo_4X4 SA frame_1/4 radio_2symbol
# ...     actPdschAtSsbSlots_P_enable_S_true prach_98
# ...     peak downlink_1.2g_1.2g  uplink 120mbps
# ...     uldata push stop due to [Precheck][CB007922[SBTS00][LOAPLO]When send ul data the rank will drop to rank1
# ...     tti check shutdown due to NACK
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     7922_CASE53_SCFC_LO_AP_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_4CELL_LO_AP_LO.xml
# ${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    #ap_snapshot    egatelog    sosreport
# ${EGATE_TAG_1}      RLQ_bundling_false
# ${EGATE_TAG_2}      RLQ_bundling_true
# @{LOG_NAME_LIST}    gnb_snapshot
# 
# *** Test Cases ***
# CB007922_case53_C_5b_intraL2RT_SA_CA_SSBBF_interwork_with_pCSI_multiplexing_on_pucch_4RX_actPerCsi_scell
#     Prepare gnb onair
#     online change pCSI multiplexing and check CA    Csi_multiplex_diable
#     online change pCSI multiplexing and check CA    Csi_multiplex_enable
#     online change pCSI multiplexing and check CA    Csi_multiplex_enable_and_beam4
# 
# *** Keywords ***
# online change pCSI multiplexing and check CA
#     [Arguments]    ${CSI_mutiplex_tag}
#     log to console   online change ${CSI_mutiplex_tag},check CA ,scell RLQ,scell release,scell A1 addition,scell deactive
#     Start capture gnb and ap syslog in '${CSI_mutiplex_tag}' file
#     Online recommissioning with delta json file
#     ...    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_7922_case53_APLO_${CSI_mutiplex_tag}.json
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     Wait '60s' for stable
#     airphone_cleanup_egate_console_log
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     Send ue '${UE_ID1}' A1 event
#     SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
#     Wait '15s' for stable
#     Collect AP egate log    ${CSI_mutiplex_tag}
#     Analyse scelladd and CSI bundling enable in rrclog   ${CSI_mutiplex_tag}
#     Check throughput    ${UE_ID1}
#     run keyword and continue on failure    tti trace ACK check    ${CSI_mutiplex_tag}
#     Override Scell CQI trigger bad threshold    ${UE_ID1}
#     Override Scell CQI trigger good threshold and scell resume    ${UE_ID1}
#     Override Scell CQI trigger bad threshold    ${UE_ID1}
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume   ${UE_ID1}
#     UE send A2 event    ${UE_ID1}
#     Check Scell release    ${CSI_mutiplex_tag}
#     Verify Pcell throughput    ${UE_ID1}
#     UE send A1 event again    ${UE_ID1}
#     Check throughput    ${UE_ID1}
#     Stop data transfer    ${UE_ID1}
#     Detach UE     ${UE_ID1}
#     Stop capture gnb and ap syslog in '${CSI_mutiplex_tag}' file
# 
# Attach SA UE
#     [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
#     Airphone Setup X2 Connection
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait '5s' for stable
# 
# Verify throughput
#     [Arguments]    ${UE_ID}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1150000   #1200000
#     should_be_true    ${dl_throughput_scell1}>1150000
# 
# 
# check 2 CA UE throughput dl and ul peak reach
#     [Arguments]    ${UE_ID1}    ${UE_ID2}    ${UE1_pcell_tp}    ${UE1_scell_tp}     ${UE2_pcell_tp}    ${UE2_scell_tp}    ${pcell_ul_tp}
#     ${UE1_dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=1    type=pdsch    tput_type=ave
#     ${UE1_ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${UE1_dl_throughput_pcell}>${UE1_pcell_tp}
#     Run Keyword If    ${UE1_scell_tp}==0     should be true   ${UE1_dl_throughput_scell1}==0
#     Run Keyword If    ${UE1_scell_tp}>0     should be true   ${UE1_dl_throughput_scell1}>${UE1_scell_tp}
# #    should_be_true    ${UE1_ul_throughput_pcell}>${pcell_ul_tp}
#     ${UE2_dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     ${UE2_dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=1    type=pdsch    tput_type=ave
#     ${UE2_ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${UE2_dl_throughput_pcell}>${UE2_pcell_tp}
#     Run Keyword If    ${UE2_scell_tp}==0     should be true   ${UE2_dl_throughput_scell1}==0
#     Run Keyword If    ${UE2_scell_tp}>0     should be true   ${UE2_dl_throughput_scell1}>${UE2_scell_tp}
# #    should_be_true    ${UE2_ul_throughput_pcell}>${pcell_ul_tp}
# 
# tti trace ACK check
#     [Arguments]     ${tti_tag}
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${tti_tag}'
#     Check ttitrace    ${tti_tag}
# 
# Override Scell CQI trigger bad threshold
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
# 
# Override Scell CQI trigger bad threshold 2UE
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait '2s' for stable
#     Wait until keyword succeeds    80s    5s      check 2 CA UE throughput dl and ul peak reach     ${UE_ID1}    ${UE_ID2}
#     ...    UE1_pcell_tp=700000    UE1_scell_tp=0      UE2_pcell_tp=300000      UE2_scell_tp=900000      pcell_ul_tp=55000
# 
# Override Scell CQI trigger good threshold and scell resume
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Check throughput    ${UE_ID}
# 
# Override Scell CQI trigger good threshold and scell resume 2UE
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait '10s' for stable
#     Wait until keyword succeeds    60s    6s       check 2 CA UE throughput dl and ul peak reach     ${UE_ID1}    ${UE_ID2}
#     ...    UE1_pcell_tp=600000    UE1_scell_tp=600000     UE2_pcell_tp=600000      UE2_scell_tp=600000    pcell_ul_tp=20
# 
# UE send A1 event again
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Check Scell deactive
# #    wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# UE send A2 event
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=${UE_ID} meas_id\=3 rs_type\=ssb scell\=1 scell_rsrp\=30
# 
# Override Scell CQI trigger good threshold and scell not resume
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
# 
# Override Scell CQI trigger good threshold and scell not resume 2UE
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    6s      check 2 CA UE throughput dl and ul peak reach     ${UE_ID1}    ${UE_ID2}
#     ...    UE1_pcell_tp=800000    UE1_scell_tp=0      UE2_pcell_tp=360000      UE2_scell_tp=950000      pcell_ul_tp=55000
# 
# Check throughput
#     [Arguments]    ${UE_ID}
#     Wait until keyword succeeds    60s    6s    Verify throughput    ${UE_ID}
# 
# Analyse scelladd in rrclog
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_LO_AP_LO_case53.ini    p
#     ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Analyse scelladd and CSI bundling enable in rrclog
#     [Arguments]    ${EGATE_TAG}
#     run keyword if   '${EGATE_TAG}'!='Csi_multiplex_diable'    check_log_with_au2anlysis
#     ...    ${CURDIR}/ini/RRC_scelladd_and_CSIbundling_LO_AP_LO_case53.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
#     run keyword if   '${EGATE_TAG}'=='Csi_multiplex_diable'    check_log_with_au2anlysis
#     ...    ${CURDIR}/ini/RRC_scelladd_LO_AP_LO_case53.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# 
# Verify Pcell throughput
#     [Arguments]    ${UE_ID}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1150000   #1200000
# 
# Verify Pcell throughput 2UE
#     [Arguments]    ${UE_ID1}    ${UE_ID2}
#     ${dl_throughput_pcell_UE1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_pcell_UE2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell_UE1}>700000
#     should_be_true    ${dl_throughput_pcell_UE1}+${dl_throughput_pcell_UE2}>1000000
# 
# Verify Scell throughput=0
#     [Arguments]    ${UE_ID}
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check Scell release
#     [Arguments]    ${scell_release_egate_log}
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}_scellrelease/    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}_scellrelease
# 
# Check ttitrace
#     [Arguments]    ${tti_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# SA send dl and ul data
#     [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
#     SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
# #    SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}
# 
# Send ue '${ue_id}' A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Stop data transfer
#     [Arguments]    ${UE_ID}
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl
# 
# Detach UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30