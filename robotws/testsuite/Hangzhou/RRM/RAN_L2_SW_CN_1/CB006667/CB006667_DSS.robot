*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    Owner_BZW
#...               SBTS00    SBTS23R4    CN1_SQ6    CB006667    RAN_5G    RAN_5G_fDD    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/resources/config
#${FULL_SCF_10M}                 SCFC_DSS_10M.xml
#${IPHY_FILE_10M}                ${CURDIR}/resources/wts/iphy_6667_DSS.xml
#${WTS_LOCAL}                    ${CURDIR}/resources/wts
#${WTS_CFG_10M}                  DSS_6667_10M.cfg
#${FULL_SCF_20M}                 SCFC_DSS_20M.xml
#${IPHY_FILE_20M}                ${CURDIR}/resources/wts/iphy_6667_DSS.xml
#${WTS_CFG_20M}                  DSS_6667_20M.cfg
#@{LOG_NAME_LIST}                snapshot    btsLog
#${ENBID}                        2
#${GNBID}                        1
#${CELL5_ID}                     5
#${ANTP_NUM}                     2
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE}     1111110110-0111011110-1111110110-1111011111-0111111110-0111011111-1111011110-0111011111
#${10M_DL_PRB_LIST_P1}          0:0,50+1:1,3|5,3+2:20,2+5:0,50+9:0,50+15:0,50+19:0,50+25:0,50+29:0,50+35:0,50+39:0,50+
#${10M_DL_PRB_LIST_P2}          45:0,50+49:0,50+55:0,50+59:0,50+65:0,50+69:0,50+75:0,50+79:0,50
#${10M_UL_PRB_LST}              0,5|5,25|30,10
#${20M_DL_PRB_LIST_P1}          0:0,100+1:1,3|5,3+2:20,2+5:0,100+9:0,100+15:0,100+19:0,100+25:0,100+29:0,100+35:0,100+39:0,
#${20M_DL_PRB_LIST_P2}          100+45:0,100+49:0,100+55:0,100+59:0,100+65:0,100+69:0,100+75:0,100+79:0,100
#${20M_UL_PRB_LST}              0,5|5,25|30,20
#${ATTACH_UE_NUM}               10
#${SWCONFIG_PARAM}              0x89003B=1
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB006667_E001_PDSCH_RS_Increasing_Per_Slot_SU_MIMO_2X2_10M_Pi_2_BPSK_SA_Without_PRB_Blanking
#    [Tags]    Owner_zbu   E01
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_10M}    iphy_file=${IPHY_FILE_10M}
#    ...           swconfig_param=${SWCONFIG_PARAM}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_10M}
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure_CELL_DSS    30    100    20    70    ${10M_DL_PRB_LIST_P1}    ${10M_DL_PRB_LIST_P2}    ${10M_UL_PRB_LST}
#    SANSA_Muilt_UE_Register_And_PDU_Session_Setup    max_ue_num=${ATTACH_UE_NUM}
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${test_log_directory}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_A2A${/}CB006667-E01.ini
#    ...    i    save_log_directory=${test_log_directory}/ttitrace_streaming/
##    [Teardown]    Test Teardown Recover Env    scf_file=${SCF_TEST_BAK_FILE}    iphy_file=${IPHY_TEST_BAK_FILE}
#    [Teardown]    Common Test Teardown
#
#CB006667_E004_PDSCH_And_PUSCH_RS_Increasing_Per_Slot_SU_MIMO_2X2_20M_QPSK_SA_High_PRB_Blanking
#    [Tags]    Owner_zbu   E04
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_20M}    iphy_file=${IPHY_FILE_20M}
#    ...           swconfig_param=${SWCONFIG_PARAM}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_20M}
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure_CELL_DSS    30    100    20    70        ${20M_DL_PRB_LIST_P1}    ${20M_DL_PRB_LIST_P2}    ${20M_UL_PRB_LST}
#    SANSA Muilt UE Register And PDU Session Setup    max_ue_num=${ATTACH_UE_NUM}
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${test_log_directory}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_A2A${/}CB006667-E04.ini
#    ...    i    save_log_directory=${test_log_directory}/ttitrace_streaming/
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Configure_CELL_DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#	...            ${DL_PRB_LIST_P1}     ${DL_PRB_LIST_P2}     ${UL_PRB_LST}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL5_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL5_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    ${DL_PRB_LIST}    catenate    SEPARATOR=    ${DL_PRB_LIST_P1}    ${DL_PRB_LIST_P2}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE}    ${UL_PRB_LST}    ${ENBID}    ${GNBID}    ${CELL5_ID}    ${DL_PRB_LIST}
#    common_setup_teardown.UE SIB Decoding Should Be Successful
#    Sleep    10s    reason=waiting for SIB for all cells
#
#SANSA_Muilt_UE_Register_And_PDU_Session_Setup
#    [Arguments]    ${max_ue_num}    ${dl_tput}=60      ${ul_tput}=15
#    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
#    \   SA 5G Attach        ${ue_id}
#    \    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
#    \    SANSA_5G_PDU_Session_Setup_multiue       ${ue_id}
#    \    Start_DL_Traffic        ${ue_id}   ${dl_tput}
#    \    Start_UL_Traffic        ${ue_id}   ${ul_tput}
#    \    Display_average_DL_and_UL_data        ${ue_id}
#
#Display_average_DL_and_UL_data
#    [Arguments]    ${ue_id}
#    ${out_dl}=    ute_wtssim.Execute Egate Command and wait for data
#    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
#    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out_dl}
#    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${current_date}=    Get Current Date
#    Log    ${current_date} : AVG DL : ${average_dl}    WARN
#    ${out_ul}=    ute_wtssim.Execute Egate Command and wait for data
#    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=ul
#    Create File       ${OUTPUT_DIR}/ul_data1.txt    ${out_ul}
#    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${current_date}=    Get Current Date
#    Log    ${current_date} : AVG UL : ${average_ul}    WARN
#    [Return]    ${average_dl}    ${average_ul}
#
#SANSA_5G_PDU_Session_Setup_multiue
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA 5G PDU Session Setup | 1 |
#    Log To Console    start 5G PDU Session Setup...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Start_DL_Traffic
#    [Arguments]    ${ue_id}     ${dl_tput}
#    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
#    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 mbps\=${dl_tput}
#    ...               pass_regexp=TRF:
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
#    Log to Console    ${output}
#Start_UL_Traffic
#    [Arguments]    ${ue_id}     ${ul_tput}
#    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
#    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 mbps\=${ul_tput}
#    ...               pass_regexp=TRF:
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
#    Log to Console    ${output}
