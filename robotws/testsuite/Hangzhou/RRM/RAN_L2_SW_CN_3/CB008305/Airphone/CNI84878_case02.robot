# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   AP    owner_changyli
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# #Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_84878_case02.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_84878_case02.xml
# ${L1BYP_XML}      L1ByPTestModeConfiguration_case10.xml
# ${WTS_NAME}       wts_84878_case02.cfg
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${FILTER_1}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# @{titles_1}    DlData_PdschGrant.bestBeamPowerOffset
# 
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# 
# ${dlmimo}    8x4 Closed Loop Spatial Multiplexing
# @{Rdparameter}    0x580396:1    0x580264:0x03    0x580265:1  #0x580265=1 UE specific csi-rs
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# 
# *** Test Cases ***
# CNI84878_case02_A_B1_Beam_power_balancing_optimizations_for_CB008305_with_4X4MIMO_leagcy_with_varible_rank
#     Add GNB swconfig    @{Rdparameter}
#     Modify l1bypass
#     Active GNB L2 feature debug traces
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
# 
#     UE Attach and check bestbeampoweroffset
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# CNI84878_case02_A_B1_Beam_power_balancing_optimizations_for_CB008305_with_4X4MIMO_leagcy_with_varible_rank_8x4
#     ${SCFC_NAME}      set variable    SCFC_84878_case02_8x4.xml
#     set test variable    ${SCFC_NAME}
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     wait '30s' for stable
#     UE Attach and check bestbeampoweroffset
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# 
# UE Attach and check bestbeampoweroffset
#     UE SA Attach    ${UE_ID1}
#     UE SA Attach    ${UE_ID2}
#     run keyword and continue on failure    Check rrc log
#     Send DL data to UE and check throughput
# 
#     Collect '4_4' ttitrace
#     Collect and convert '4_4' BIP
#     Check throughput    140000    140000
# 
#     Fix ue rank    ${UE_ID1}    0
#     Fix ue rank    ${UE_ID2}    3   2
#     wait '10s' for stable
# 
#     Check throughput    30000    140000
#     Collect '1_4' ttitrace
#     Collect and convert '1_4' BIP
# 
#     Fix ue rank    ${UE_ID1}    1
#     Fix ue rank    ${UE_ID2}    3    2
#     wait '10s' for stable
# 
#     Check throughput    60000    140000
#     Collect '2_4' ttitrace
#     Collect and convert '2_4' BIP
# 
#     Fix ue rank    ${UE_ID1}    2
#     Fix ue rank    ${UE_ID2}    3    2
#     wait '10s' for stable
# 
#     Check throughput    90000    140000
#     Collect '3_4' ttitrace
#     Collect and convert '3_4' BIP
# 
# 
#      #add loss path
#     airphone_bler_testmode_nr    3    dl_bler=\200,100
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler action\=activate profile_id\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler action\=activate profile_id\=3
#     wait '10s' for stable
# 
# 
#     Collect '4_0' ttitrace
#     Collect and convert '4_0' BIP
# 
#     airphone_bler_testmode_nr    3    delete=\true
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler action\=deactivate profile_id\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler action\=deactivate profile_id\=3
# 
#     Detach SA UE    ${UE_ID1}
#     Detach SA UE    ${UE_ID2}
# 
# 
# UE SA Attach
#     [Arguments]    ${UE_ID}
#     airphone_cleanup_egate_console_log
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID}
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=1    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' for stable
# 
# 
# #Send DL data to UE and check throughput
# #    SA send mutiple trf dl data    ${UE_ID1}    6   175M
# #    SA send mutiple trf dl data    ${UE_ID2}    6    175M
# 
# Detach SA UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}
# 
# 
# Check mupair in ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_mu_case02.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_case10_mu.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>140000
#     should_be_true    ${dl_throughput_ue2}>140000
# 
# Send DL data to UE and check throughput
#     SA send mutiple trf dl data    ${UE_ID1}    6    175M
#     SA send mutiple trf dl data    ${UE_ID2}    6    175M
#     wait '20s' for stable
#     Check throughput    140000    140000
# 
# Check throughput
#     [Arguments]    ${ue1_tput}    ${ue2_tput}
#     Wait until keyword succeeds    60s    5s    Verify throughput-2'${ue1_tput}''${ue2_tput}'
# 
# Verify throughput-2'${ue1_tput}''${ue2_tput}'
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     Log To Console    ue1_tput:${dl_throughput_ue1}
#     Log To Console    ue2_tput:${dl_throughput_ue2}
#     should_be_true    ${dl_throughput_ue1}>${ue1_tput}
#     should_be_true    ${dl_throughput_ue2}>${ue2_tput}
# 
# Check su in ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_su_case10.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Collect '${rank}' ttitrace
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_${rank}'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_mu_case02_${rank}.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Collect and convert '${rank}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_${rank}'
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_${rank}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_${rank}/bip_${rank}.csv    ${FILTER_1}    ${titles_1}
# 
#     Check best beam power offset index in bip'${rank}'
# 
# 
# Check best beam power offset index in bip'${rank}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_bestBeamPowerOffsetIndex_case2.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_${rank}/
# 
# Fix ue rank
#     [Arguments]    ${UE_ID}=1    ${RANK_VALUE}=3    ${PROFILE_ID}=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${PROFILE_ID} cqi\=15 ri\=${RANK_VALUE}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${PROFILE_ID}
# 
# Online change dlmimomode
#     [Arguments]    ${dlMimoMode}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   dlMimoMode    ${dlMimoMode}    online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   periodicCsiAcquisition.csirsNumberWithinReportPeriod_Set1    1    online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   periodicCsiAcquisition.maxCsirsNumber    2    online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   periodicCsiAcquisition.csirsPower    0    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
# 
# 
