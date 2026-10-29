*** Settings ***
Documentation    ...
#Library        ../5GC001817/csv_bit_to_qci.py
#Library        ../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library        ../CUDU_L2/scripts/python/get_csv_data.py
#Resource       ./keywords_CB008131_common_AP_BOO_LOO.robot
#Resource       ../CUDU_L2/common_setup_teardown.robot
#Resource       ../5GC001817/keywords_1817_common_AP.robot
#Resource       ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#
#Force Tags     CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    RAN_5G_TDD    FR1
#...            PRI-High    RAN_5G    SBTS00    CRT
#
#Suite Setup    Run Keywords
#...            Common Suite Setup
#...            Prepare Test TL
#
#*** Variables ***
#
#${WTS_CFG_FT_2CC_5M}                basic_sansa_F_T_cmwv_5MHz.cfg
#${WTS_CFG_FT_2CC_15M}               basic_sansa_F_T_cmwv_15MHz.cfg
#${WTS_CFG_FT_2CC_B007}              basic_sansa_F_T_cmwvB007.cfg
#${IPHY_FT_eCPRI_5M}                 iphy_FT_eCPRI_5M_LOO.xml
#${IPHY_FT_eCPRI_15M}                iphy_FT_eCPRI_15M_LOO.xml
#${SCF_FT_2CC_5M}                    SCF_CB008131_FT_2CC_5M.xml
#${SCF_FT_2CC_5M_UCIONLY}            SCF_CB008131_FT_2CC_5M_UCIOnly.xml
#${SCF_FT_2CC_10M}                   SCF_CB008131_FT_2CC_10M.xml
#${SCF_FT_2CC_15M_DRX}               SCF_CB008131_FT_2CC_15M_DRX.xml
#${SCF_FT_2CC_10MB010}               SCF_CB008131_FT_2CC_10M_B010.xml
#${SCF_FT_2CC_20MB007}               SCF_CB008131_FT_2CC_20M_B007.xml
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
##CB008131-ET-B001_F_T_CA_basic_ACSI_handling
##    [Tags]     Owner_xinwang    case_B001
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_5M}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_10M}
##    ...    iphy_name=${IPHY_FT_eCPRI_5M}    cfg_name=${WTS_CFG_FT_2CC_5M}    nsa_sa_flag=${TestLine_Type_SA}
##    [Timeout]    60min
##    L3 Call With SA With Iperf
##	Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_10M
##    Check_Betaoffset_MCShark_For_CA    B001
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B001
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    B001
##    Check csiPart1CrcCheck in PuschReceiveRespPs    B001
##    Check csiPart2CrcCheck in PuschReceiveRespPs    B001
##    Check dtxCsiPart1 in PuschReceiveRespPs    B001
##    Check dtxCsiPart2 in PuschReceiveRespPs    B001
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B001
##    Check CRCNOK Rate in PuschReceiveRespHarqU    B001
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    B001    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-B002_F_T_CA_Scell_addition_for_UE_reconfig_with_CA
##    [Tags]     Owner_lilidong    case_B002
##    [Documentation]    Note:For 5M FDD BWP configuration,there is limitation on APoABIO,so
##    ...    MRBTS-1/NRBTS-1/BWP_PROFILE-30/PDCCH-1/PDCCH_CONFIG_DEDICATED-1 3&4rd instances has been deleted in SCF file,see detail as below .
##    ...    Related content cited from https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1104199524 as below:
##    ...    for FDD 5MHz, coreset-0 and Dedicated-CoreSet are used (both supporting type3 & ue-specicic SearchSPaceTypes).
##    ...    Thus in the configuration recommended for FDD 5MHZ, only the 1st & 2nd instances are supported in PDCCH_Config_Recommendations_23R1.xlsx.
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_5M}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_5M}
##    ...    iphy_name=${IPHY_FT_eCPRI_5M}    cfg_name=${WTS_CFG_FT_2CC_5M}    nsa_sa_flag=${TestLine_Type_NSA}
##    [Timeout]    60min
##    L3 Call With NSA    ${COVBASEDA1}    ${NO_A2_REL_SCELL}    B002    2    100
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${FT_2CC_SCELL}
##    Verify TDD Scell Is Activation    9
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_NSA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_5M
##    Check_Betaoffset_MCShark_For_CA    B002
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B002
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    B002
##    Check csiPart1CrcCheck in PuschReceiveRespPs    B002
##    Check csiPart2CrcCheck in PuschReceiveRespPs    B002
##    Check dtxCsiPart1 in PuschReceiveRespPs    B002
##    Check dtxCsiPart2 in PuschReceiveRespPs    B002
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B002
##    Check CRCNOK Rate in PuschReceiveRespHarqU    B002
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    B002    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-B008_F_T_CA_Scell_addition_for_UE_reconfig_with_CA_UciOnly
##    [Tags]     Owner_Susie    case_B008
##    [Documentation]    Note:For 5M FDD BWP configuration,there is limitation on APoABIO,so
##    ...    MRBTS-1/NRBTS-1/BWP_PROFILE-30/PDCCH-1/PDCCH_CONFIG_DEDICATED-1 3&4rd instances has been deleted in SCF file,see detail as below .
##    ...    Related content cited from https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1104199524 as below:
##    ...    for FDD 5MHz, coreset-0 and Dedicated-CoreSet are used (both supporting type3 & ue-specicic SearchSPaceTypes).
##    ...    Thus in the configuration recommended for FDD 5MHZ, only the 1st & 2nd instances are supported in PDCCH_Config_Recommendations_23R1.xlsx.
##    [Setup]    Run keywords
##     ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_5M}
##     ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_5M_UCIONLY}
##     ...    iphy_name=${IPHY_FT_eCPRI_5M}    cfg_name=${WTS_CFG_FT_2CC_5M}    ucionly=${UciOnly_True}
##     ...    nsa_sa_flag=${TestLine_Type_NSA}
##    [Timeout]    60min
##    L3 Call With NSA FOR UCIOnly    ${COVBASEDA1}    ${NO_A2_REL_SCELL}    B008    2    30
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${FT_2CC_SCELL_B008}
##    Verify TDD Scell Is Activation    6
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_NSA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_5M
##    Check_Betaoffset_MCShark_For_CA    B008
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B008
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    B008
##    Check csiPart1CrcCheck in PuschReceiveRespPs    B008
##    Check csiPart2CrcCheck in PuschReceiveRespPs    B008
##    Check dtxCsiPart1 in PuschReceiveRespPs    B008
##    Check dtxCsiPart2 in PuschReceiveRespPs    B008
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B008
##    Check CRCNOK Rate in PuschReceiveRespHarqU    B008
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    B008    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-B004_F_T_CA_Scell_addition_for_UE_reconfig_with_CA_IWK_CDRX
##    [Tags]    Owner_susie    case_B004
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_15M}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_15M_DRX}
##    ...    iphy_name=${IPHY_FT_eCPRI_15M}    cfg_name=${WTS_CFG_FT_2CC_15M}    ucionly=${UciOnly_False}
##    ...    nsa_sa_flag=${TestLine_Type_NSA}    rdACsiEligibilityAgeThreshold=0x14
##    [Timeout]    60min
##    L3 Call With NSA For B004    B004
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_15M
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B004
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    B004
##    Check csiPart1CrcCheck in PuschReceiveRespPs    B004
##    Check csiPart2CrcCheck in PuschReceiveRespPs    B004
##    Check dtxCsiPart1 in PuschReceiveRespPs    B004
##    Check dtxCsiPart2 in PuschReceiveRespPs    B004
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B004
##    Check CRCNOK Rate in PuschReceiveRespHarqU    B004
##    ute_wtssim.Execute Egate Command    sim_log_set flush
##    Get And Check Scell Infos    ${FT_2CC_SCELL}
##    Verify TDD Scell Is Activation    9
##    Check ACSI Info From Egate Log For CA    ${CLOSELOOP_FLAG}    ${2CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_NSA}
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    B004    ${OUTPUT_DIR}
##    Check ACSI Periodicity On PCell    B004    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-B010_F_T_CA_Scell_addition_for_UE_reconfig_with_CA_with_2200_disabled
##    [Tags]     junying    case_B010
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_5M}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_10MB010}
##    ...    iphy_name=${IPHY_FT_eCPRI_5M}    cfg_name=${WTS_CFG_FT_2CC_5M}    nsa_sa_flag=${TestLine_Type_NSA}
##    [Timeout]    60min
##    L3 Call With NSA    ${COVBASEDA1}    ${NO_A2_REL_SCELL}    B010    2    100
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${FT_2CC_SCELL}
##    Verify TDD Scell Is Activation    9
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_NSA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_10M
##    Check_Betaoffset_MCShark_For_CA    B010
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B010
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    B010
##    Check csiPart1CrcCheck in PuschReceiveRespPs    B010
##    Check csiPart2CrcCheck in PuschReceiveRespPs    B010
##    Check dtxCsiPart1 in PuschReceiveRespPs    B010
##    Check dtxCsiPart2 in PuschReceiveRespPs    B010
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B010
##    Check CRCNOK Rate in PuschReceiveRespHarqU    B010
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    B010    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
#CB008131-ET-B007_F_T_CA_Scell_release_for_UE_reconfig_wo_CA_IWK_MG_MUE
#    [Tags]     junying    case_B007
#    [Setup]    Run keywords
#    ...    Set WTS Files Name For Each Cases    ${WTS_CFG_FT_2CC_B007}
#    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FT_2CC_20MB007}
#    ...    iphy_name=${IPHY_FT_eCPRI_5M}    cfg_name=${WTS_CFG_FT_2CC_B007}    nsa_sa_flag=${TestLine_Type_NSA}
#    [Timeout]    60min
#    L3 Call With SA For MGB007    ${2CC}    B007
#    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
#    Verify Scells Are Activation    ${2CC}
#	Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
#    Log To Console    start check bip log
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_FT_20M
#    Check_Betaoffset_MCShark_For_CA    B007
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    B007
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    B007
#    Check csiPart1CrcCheck in PuschReceiveRespPs    B007
#    Check csiPart2CrcCheck in PuschReceiveRespPs    B007
#    Check dtxCsiPart1 in PuschReceiveRespPs    B007
#    Check dtxCsiPart2 in PuschReceiveRespPs    B007
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    B007
#    Check CRCNOK Rate in PuschReceiveRespHarqU    B007
#    Log To Console    \nstart check ttitrace log for pcsi period
#    Check PCSI Periodicity On Each Cell    B007    ${OUTPUT_DIR}
#    #[Teardown]    Get Cfg Files And Recover TL For Each Case3
#    #[Teardown]    Common Test Teardown 2
#    [Teardown]    Common Test Teardown without snapshot
#
#*** Keywords ***
#L3 Call With NSA For B004
#    [Arguments]    ${tc_id}
#    Set Suite Variable    ${UE_ID}    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    11    2    2    2
#    NSA Verify If Attach Passed
#    Log To Console     start ttitrace...
#    Start Ttitrace With Streaming Mode
#    Sleep    5s     reason=wait for script start
#    Start GNB BIP By Admin Method    0    L1-L2    Local
#    Scell Addition Triggered By A1 Event    ue_id=${UE_ID}
#    Sleep    10s    reason=For scell activation
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}
#    Stop And Collect GNB BIP By Admin Method    ${SUITE_LOG_DIRECTORY}    L1-L2    Local    0
#
#
#L3 Call With SA For MGB007
#    [Arguments]    ${cell_nums}    ${tc_id}
#    Set Suite Variable    ${UE_ID}    1
#    Set Suite Variable    ${UE_ID2}    2
#    Setup X2 Connection
#	SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
#	SA Set Traffic Type To Internal    ${UE_ID2}     ${PDU_ID}
#	SA 5G Attach    ${UE_ID}
#	SA 5G Attach    ${UE_ID2}
#	SA 5G PDU Session Setup    ${UE_ID}
#	SA 5G PDU Session Setup    ${UE_ID2}
#    SA Start DL Traffic Internal    ${UE_ID}     ${PDU_ID}    175
#	SA Start DL Traffic Internal    ${UE_ID2}    ${PDU_ID}    175
#	SA Start UL Traffic Internal    ${UE_ID}     ${PDU_ID}     15
#	SA Start UL Traffic Internal    ${UE_ID2}    ${PDU_ID}     15
#    ${measIdA1UE}=    keywords_CB008131_common_AP_BOO_LOO.Get MeasID A1    ${UE_ID}
#	${measIdA1UE2}=    keywords_CB008131_common_AP_BOO_LOO.Get MeasID A1    ${UE_ID2}
#    Scell Addition Triggered By A1 Event    ${UE_ID}    ${measIdA1UE}    100
#	Scell Addition Triggered By A1 Event    ${UE_ID2}    ${measIdA1UE2}    100
#    Capture TTItrace And BIP Logs
#	Start Ttitrace With Streaming Mode    names=MGtti
#	${measIdA2mgUE}=     Get MeasID A2 MG     ${UE_ID}
#	${measIdA2mgUE2}=    Get MeasID A2 MG    ${UE_ID2}
#    Measurement Gap Triggered By A2 Event    ${UE_ID}     ${measIdA2mgUE}
#	Measurement Gap Triggered By A2 Event    ${UE_ID2}    ${measIdA2mgUE2}
#	${measIdA2releaseUE}=    Get MeasID A2 release    ${UE_ID}
#	${measIdA2releaseUE2}=    Get MeasID A2 release    ${UE_ID2}
#    Scell Released By A2 Event    ${UE_ID}    ${measIdA2releaseUE}    1
#	Scell Released By A2 Event    ${UE_ID2}    ${measIdA2releaseUE2}    1
#    Sleep    2s    reason=For the log
#	Stop Ttitrace    MGtti    ${OUTPUT_DIR}
#	SA Stop DL Traffic Egate Command    1
#	SA Stop UL Traffic Egate Command    1
