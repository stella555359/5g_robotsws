# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BLLL_AP_LOO    owner_changyli   AP    CRT
# ...    SBTS00   RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_9198_case01-60M.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_ASIL_1CELL.xml
# ${WTS_NAME}    wts_9198_AEQE_case01.cfg
# ${UE_ID11}          11
# 
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# 
# ${UE_NUM_SA}         1
# ${UE_NUM_SA_VONR}         2
# ${UE_NUM_NSA}        1
# ${UE_NUM_NSA_ID}        11
# ${EGATE_TAG}      precoder
# ${TTI_TAG}      tti
# ${TTI_TAG_BLER}      tti_bler
# #&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# #...    NUMBER_OF_FILES=30
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='false'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BIP_TAG}    precoder_bip
# ${FILTER_1}    uldata_puschreceivereq
# @{titles_1}    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
# 
# ${PROFILE1}    ul_sinr_testmode_nr profile_id\=1 pathloss\=60
# ${PROFILE2}    ul_sinr_testmode_nr profile_id\=1 pathloss\=70
# ${PROFILE3}    ul_sinr_testmode_nr profile_id\=1 pathloss\=80
# ${PROFILE4}    ul_sinr_testmode_nr profile_id\=1 pathloss\=90
# ${PROFILE5}    ul_sinr_testmode_nr profile_id\=1 pathloss\=100
# ${PROFILE6}    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
# ${PROFILE7}    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
# 
# #SA
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE3}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE4}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE5}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE6}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# ${SET_PROFILE7}    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# 
# ${PROFILE_DEL}    ul_sinr_testmode_nr profile_id\=1 delete\=1
# 
# 
# *** Test Cases ***
# CB009198_A_B1_case01_DFT-S-FDM_feature_activation_in_SA_mode
#     Modify 9198 Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     UE attach and check tput
#     Online change actUlDftSOfdm enabled
# 
#     Case check '1' times
# 
#     #robustness 20 times
#     :FOR    ${num}    IN RANGE    2    20+2
#     \    Case check '${num}' times
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Modify 9198 Swconfig
# 	Add GNB swconfig    0x580376:5  #rdTransPrecodeHystThresh
# 	Add AP swconfig    0x10041:5
# 
# UE attach and check tput
#     Set traffic type to internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     wait '1s' for stable
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     wait '2s' for stable
#     SA send mutiple trf ul data    ${UE_ID}    1   90M   ${UE_ID}
#     SA send mutiple trf dl data    ${UE_ID}    3   150M   ${UE_ID}
#     wait '20s' for stable
#     run keyword and continue on failure    Check SA UE throughput
# 
#     Airphone SA Stop Data Traffic And Detach UE
# 
# Case check '${num}' times
#    # SA UE attach
#     log to console  UE attach ${num} times
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     wait '1s' for stable
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     wait '2s' for stable
#     SA send mutiple trf ul data    ${UE_ID}    1   90M   ${UE_ID}
#     SA send mutiple trf dl data    ${UE_ID}    3   150M   ${UE_ID}
#     wait '20s' for stable
#     run keyword and continue on failure    Check SA UE throughput
#     run keyword and continue on failure    Capture and check ttitrace no bler
# 
#     Set pathloss from low to high
#     wait '10s' for stable
# #    log to console  DFTS enabled Start collect bip log ${num}
# #    Collect and convert bip    bip_name=bip_${num}_enable    cp_flag=1
#     run keyword and continue on failure    Verify multi SA UEs throughput    0
# 
#     Set pathloss from hign to low
# #    log to console  DFTS disabled Start collect bip log ${num}
# #    Collect and convert bip    bip_name=bip_${num}_diabled    cp_flag=0
#     Collect AP egate log    ${EGATE_TAG}
#     Check transformPrecoder in rrc log
# 
#     Delete pathloss
#     Airphone SA Stop Data Traffic And Detach UE
# 
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_NUM_NSA_ID}    scell_id=8    type=pusch    tput_type=ave
#     log to console    ul tput =${ul_throughput_pcell}
# #    should_be_true    ${ul_throughput_pcell}>790000
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_NUM_NSA_ID}    scell_id=8    type=pdsch    tput_type=ave
#     log to console    dl tput =${dl_throughput_pcell}
# #    should_be_true    ${dl_throughput_pcell}>415000
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# #Verify multi SA UEs throughput
# #    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
# #    log to console    ul tput =${ul_throughput_pcell}
# ##    should_be_true    ${ul_throughput_pcell}>20000
# #    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# #     log to console    dl tput =${dl_throughput_pcell}
# ##     should_be_true    ${dl_throughput_pcell}>20000
# 
# Verify multi SA UEs throughput
#     [Arguments]    ${tput_peak}=1
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     log to console    ul tput =${ul_throughput_pcell}
#     Run Keyword If    ${tput_peak}==1    should_be_true    ${ul_throughput_pcell}>78000
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#      log to console    dl tput =${dl_throughput_pcell}
#      Run Keyword If    ${tput_peak}==1    should_be_true    ${dl_throughput_pcell}>410000
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     Airphone NSA Stop Data Traffic   ${UE_NUM_NSA_ID}    DL
#     Airphone NSA Stop Data Traffic   ${UE_NUM_NSA_ID}    UL
#     Airphone NSA Detach    ${UE_NUM_NSA_ID}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     Airphone SA Stop Data Traffic     ${UE_ID}     DL    ${UE_ID}
#     Airphone SA Stop Data Traffic     ${UE_ID}     UL    ${UE_ID}
#     Airphone SA Detach    ue_id=${UE_ID}
# 
# Check UE '${num}' rrc log aperidic
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
# 
# Collect and convert bip
#     [Arguments]    ${bip_name}=precoder    ${cp_flag}=0
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${bip_name}'
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_name}/tcpdump_L2L1_bip_filtering_1:0.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_name}/${bip_name}.csv    ${FILTER_1}    ${titles_1}
# 
#     run keyword if   ${cp_flag}==0    Check puschTransformPrecoderFlag Disabled in bip'${bip_name}'
#     ...    ELSE    Check puschTransformPrecoderFlag Enabled in bip'${bip_name}'
# 
# Check puschTransformPrecoderFlag Disabled in bip'${bip_name}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_TransformPrecoderFlagDisabled.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_name}/
# 
# Check puschTransformPrecoderFlag Enabled in bip'${bip_name}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_TransformPrecoderFlagEnable.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_name}/
# 
# Check ttitrace no bler
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case01.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case01.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Capture and check ttitrace no bler
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace no bler
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# 
# Set pathloss from low to high
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     wait '10s' for stable
# 
# 
# Set pathloss from hign to low
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     wait '10s' for stable
# 
# Online change actUlDftSOfdm enabled
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    actUlDftSOfdm    true    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stable
# 
# Check transformPrecoder in rrc log
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_TransformPrecoderFlag.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# 
# Delete pathloss
#     airphone_execute_egate_command    ${PROFILE_DEL}
# 
