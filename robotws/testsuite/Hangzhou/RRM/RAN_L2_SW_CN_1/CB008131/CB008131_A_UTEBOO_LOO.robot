*** Settings ***
Documentation    ...
#Library        ../5GC001817/csv_bit_to_qci.py
#Library        ../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library        ../CUDU_L2/scripts/python/get_csv_data.py
#Resource       ./keywords_CB008131_common_AP_BOO_LOO.robot
#Resource       ../CUDU_L2/common_setup_teardown.robot
#Resource       ../5GC001817/keywords_1817_common_AP.robot
#Resource       ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    RAN_5G_FDD
#...               FR1    PRI-High    RAN_5G    SBTS00
#
#Suite Setup    Run Keywords
#...            Common Suite Setup
#...            Prepare Test TL
#
#*** Variables ***
#${SCF_FFF_3CC_20M_IntraBand}        SCF_CB008131_FFF_3CC_20M_IntraBand.xml
#${SCF_FFF_3CC_15M_InterBand}        SCF_CB008131_FFF_3CC_15M_InterBand.xml
#${SCF_FF_2CC_10M_IntraBand}         SCF_CB008131_FF_2CC_10M_IntraBand.xml
#${SCF_FFF_3CC_15M_InterBand_DRX}     SCF_CB008131_FFF_3CC_15M_InterBand_DRX.xml
#${SCF_FFF_3CC_5M_IntraBand}         SCF_CB008131_FFF_3CC_5M_IntraBand.xml
#${SCF_FF_2CC_5M_InterBandA001}      SCF_CB008131_FF_2CC_5M_InterBandA001.xml
#${SCF_FFF_3CC_10M_IntraBand}        SCF_CB008131_FF_3CC_10M_IntraBand.xml
#
#${3CC_INTER_IPHY}                   iphy_3CC-Inter-FF_LOO.xml
#${3CC_INTRA_IPHY}                   iphy_3CC-Intra-FF_LOO.xml
#${3CC_INTRA_IPHY_20M}               iphy_3CC_IntraBand_LOO.xml
#${3CC_INTRA_5M_IPHY}                iphy_3CC-Intra-5M-FF_LOO.xml
#${2CC_INTER_IPHYA001}               iphy_2CC_InterBandA001_LOO.xml
#
#${5M_2CC_CFG_A001}              basic_fs_sa_call_fdd_cmwv_2CC_InterBand_5MA001.cfg
#${10M_2CC_CFG}                  basic_fs_sa_call_fdd_cmwv_2CC_IntraBand_10M.cfg
#${15M_3CC_CFG}                  basic_fs_sa_call_fdd_cmwv_3CC_InterBand_15M.cfg
#${20M_3CC_CFG}                  basic_fs_sa_call_fdd_cmwv_3CC_IntraBand_20M.cfg
#${5M_3CC_Intra_CFG}             basic_fs_sa_call_fdd_cmwv_3CC_IntraBand_5M.cfg
#${10M_3CC_Intra_CFG}            basic_fs_sa_call_fdd_cmwv_3CC_IntraBand_10M.cfg
#${Basic_CFG_A010}               basic_fs_sa_call_fdd_cmwv_A010_dedicated.cfg
#
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
##CB008131-ET-A001_F_F_CA_basic_ACSI_handling
##    [Tags]     Owner_junying    case_A001    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${5M_2CC_CFG_A001}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FF_2CC_5M_InterBandA001}
##    ...    iphy_name=${2CC_INTER_IPHYA001}    cfg_name=${5M_2CC_CFG_A001}    nsa_sa_flag=${TestLine_Type_SA}
##    [Timeout]    60min
##    L3 Call With SA For A001    ${2CC}    A001
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${2CC_INTER_BAND_FF_SCELL}
##    Verify Scells Are Activation    ${2CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_5M
##    Verfiy Scells Are Activation From BIP       A001   ${2CC}
##    Verfiy Scells Are Deactivation From BIP     A001   ${2CC}
##    Check_Betaoffset_MCShark_For_CA    A001
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A001
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A001
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A001
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A001
##    Check dtxCsiPart1 in PuschReceiveRespPs    A001
##    Check dtxCsiPart2 in PuschReceiveRespPs    A001
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A001
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A001
##    Convert BIP To CSV And Check Pcsi On Scell    A001    ${2CC}
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    A001    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
#CB008131-ET-A002_F_F_CA_Scell_addition_for_UE_reconfig_with_CA
#    [Tags]    Owner_susie    case_A002    CIT    CDRT
#    [Setup]    Run keywords
#    ...    Set WTS Files Name For Each Cases    ${10M_2CC_CFG}
#    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FF_2CC_10M_IntraBand}
#    ...    iphy_name=${3CC_INTRA_IPHY}    cfg_name=${10M_2CC_CFG}    nsa_sa_flag=${TestLine_Type_SA}
#    [Timeout]    60min
#    L3 Call With SA    ${NO_UL_ZEROPADDING}    ${UciOnly_False}    ${COVBASEDA1}    ${A2_REL_SCELL}    ${2CC}    A002
#    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
#    Get And Check Scell Infos    ${2CC_INTRA_BAND_FF_SCELL}
#    Verify Scells Are Activation    ${2CC}
#    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
#    Log To Console    start check bip log
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_10M
#    Check_Betaoffset_MCShark_For_CA    A002
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A002
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    A002
#    Check csiPart1CrcCheck in PuschReceiveRespPs    A002
#    Check csiPart2CrcCheck in PuschReceiveRespPs    A002
#    Check dtxCsiPart1 in PuschReceiveRespPs    A002
#    Check dtxCsiPart2 in PuschReceiveRespPs    A002
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A002
#    Check CRCNOK Rate in PuschReceiveRespHarqU    A002
#    Convert BIP To CSV And Check Pcsi On Scell    A002    ${2CC}
#    Log To Console    start check ttitrace log
#    Check PCSI Periodicity On Each Cell    A002    ${OUTPUT_DIR}
#    #[Teardown]    Get Cfg Files And Recover TL For Each Case3
#    [Teardown]    Common Test Teardown without snapshot
#
##CB008131-ET-A004_F_F_CA_Scell_addition_for_UE_reconfig_with_CA_IWK_CDRX
##    [Tags]    Owner_Yuxin    case_A004    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${15M_3CC_CFG}
##    ...    AND    Setup TL For Test Case    ${3CC}    ${SCF_FFF_3CC_15M_InterBand_DRX}
##    ...    iphy_name=${3CC_INTER_IPHY}   cfg_name=${15M_3CC_CFG}    nsa_sa_flag=${TestLine_Type_SA}
##    ...    rdACsiEligibilityAgeThreshold=0x14
##    [Timeout]    60min
##    L3 Call With SA    ${UL_ZEROPADDING}    ${UciOnly_False}    ${COVBASEDA1}    ${NO_A2_REL_SCELL}    ${3CC}    A004
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${3CC_INTER_BAND_FFF_SCELLS}
##    Verify Scells Are Activation    ${3CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_15M
##    Check_Betaoffset_MCShark_For_CA    A004
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A004
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A004
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A004
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A004
##    Check dtxCsiPart1 in PuschReceiveRespPs    A004
##    Check dtxCsiPart2 in PuschReceiveRespPs    A004
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A004
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A004
##    Log To Console    start check ttitrace log
##    Check ACSI Periodicity On PCell    A004    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-A005_F_F_CA_Scell_release_for_UE_reconfig_wo_CA_IWK_MG
##    [Tags]    Owner_Abby    case_A005    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${20M_3CC_CFG}
##    ...    AND    Setup TL For Test Case    ${3CC}    ${SCF_FFF_3CC_20M_IntraBand}
##    ...    iphy_name=${3CC_INTRA_IPHY_20M}   cfg_name=${20M_3CC_CFG}    nsa_sa_flag=${TestLine_Type_SA}
##    ...    OpenLoopwocsipart2=${OpenLoop_WO_CsiPart2_True}
##    [Timeout]    60min
##    Start L3 Call And BIP Log For A005    ${3CC}    A005    ${Measurement_Gap_True}
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${3CC_INTRA_BAND_FFF_SCELLS}
##    Verify Scells Are Activation    ${3CC}
##    Verify Scells Are Released      ${3CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_20M
#    #Check_Betaoffset_MCShark_For_CA    A005
#    #Note:numOfUciCsiPart1Bits is 6 in 23R2,5 in 23R1
#    #Set numOfUciCsiPart1Bits In Ttitrace_1_a.csv
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A005
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A005
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A005
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A005
##    Check dtxCsiPart1 in PuschReceiveRespPs    A005
##    Check dtxCsiPart2 in PuschReceiveRespPs    A005
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A005
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A005
##    Convert BIP To CSV And Check Pcsi On Scell    A005    ${3CC}    3    4
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    A005    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-A006_F_F_CA_Scell_addition_for_UE_reconfig_with_CA_IWK_CDRX_MUE
##    [Tags]    Owner_susie    case_A006    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${10M_3CC_Intra_CFG}
##    ...    AND    Setup TL For Test Case    ${3CC}    ${SCF_FFF_3CC_10M_IntraBand}
##    ...    iphy_name=${3CC_INTRA_IPHY}    cfg_name=${10M_3CC_Intra_CFG}    ucionly=${UciOnly_False}
##    ...    nsa_sa_flag=${TestLine_Type_SA}    rdACsiEligibilityAgeThreshold=0x14
##    [Timeout]    60min
##    L3 Call With SA For A006    A006
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_10M
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A006
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A006
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A006
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A006
##    Check dtxCsiPart1 in PuschReceiveRespPs    A006
##    Check dtxCsiPart2 in PuschReceiveRespPs    A006
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A006
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A006
##    ute_wtssim.Execute Egate Command    sim_log_set flush
##    Get And Check Scell Infos    ${3CC_INTRA_BAND_FFF_SCELLS}
##    Verify Scells Are Activation    ${2CC}
##    Check ACSI Info From Egate Log For CA    ${CLOSELOOP_FLAG}    ${3CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    A006    ${OUTPUT_DIR}
##    Check ACSI Periodicity On PCell    A006    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-A008_F_F_CA_Scell_addition_for_UE_reconfig_with_CA_UciOnly
##    [Tags]    Owner_susie    case_A008    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${5M_3CC_Intra_CFG}
##    ...    AND    Setup TL For Test Case    ${3CC}    ${SCF_FFF_3CC_5M_IntraBand}
##    ...    iphy_name=${3CC_INTRA_5M_IPHY}    cfg_name=${5M_3CC_Intra_CFG}    ucionly=${UciOnly_True}
##    ...    nsa_sa_flag=${TestLine_Type_SA}
##    [Timeout]    60min
##    L3 Call With SA Ucionly For A008    ${3CC}
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Get And Check Scell Infos    ${3CC_INTRA_BAND_FFF_SCELLS}
##    Verify Scells Are Activation    ${3CC}
##    Check ACSI Info From Egate Log For CA    ${CLOSELOOP_FLAG}    ${3CC}
##    Check BetaOffsets From Local Egate Log    ${TestLine_Type_SA}
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_5M
##    Check_Betaoffset_MCShark_For_CA    A008
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A008
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A008
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A008
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A008
##    Check dtxCsiPart1 in PuschReceiveRespPs    A008
##    Check dtxCsiPart2 in PuschReceiveRespPs    A008
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A008
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A008
##    Check_Ucionly_MCShark_For_CA  A008
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    A008    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
##CB008131-ET-A010_F_F_CA_Limited_UECapability_for_maxNumberAllCC
##    [Tags]    Owner_lilidong    case_A010    CRT
##    [Setup]    Run keywords
##    ...    Set WTS Files Name For Each Cases    ${Basic_CFG_A010}
##    ...    AND    Setup TL For Test Case    ${2CC}    ${SCF_FF_2CC_10M_IntraBand}
##    ...    iphy_name=${3CC_INTRA_IPHY}    cfg_name=${Basic_CFG_A010}    nsa_sa_flag=${TestLine_Type_SA}
##    [Timeout]    60min
##    L3 Call With SA For A010    ${2CC}    A010
##    Run Keyword And Ignore Error    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
##    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
##    Sleep    10s    reason=For the egate log
##    Get And Check Scell Infos    ${2CC_INTRA_BAND_FF_SCELL}
##    Verify Scells Are Activation    ${2CC}
##    Check BetaOffsets From Local Egate Log A010 Dedicated
##    Check ACSI Released Info From Local Egate Log A010 Dedicated
##    Log To Console    start check bip log
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_10M
##    Check_Betaoffset_MCShark_For_CA    A010
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A010
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    A010
##    Check csiPart1CrcCheck in PuschReceiveRespPs    A010
##    Check csiPart2CrcCheck in PuschReceiveRespPs    A010
##    Check dtxCsiPart1 in PuschReceiveRespPs    A010
##    Check dtxCsiPart2 in PuschReceiveRespPs    A010
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A010
##    Check CRCNOK Rate in PuschReceiveRespHarqU    A010
##    Convert BIP To CSV And Check Acsi For A010    A010    2
##    Log To Console    start check ttitrace log
##    Check PCSI Periodicity On Each Cell    A010    ${OUTPUT_DIR}
##    [Teardown]    Get Cfg Files And Recover TL For Each Case3
#
#*** Keywords ***
#Check BetaOffsets From Local Egate Log A010 Dedicated
#    [Arguments]    ${log_path}=/opt/iphy/latest
#    Log To Console    \nStart check A010 dedicated betaOffset info from egate log.\n
#    ${betaoffset}    Set Variable    betaOffset
#    ${check_rst}    Run    cat ${log_path}/egate_console.log|grep "${betaoffset}"|wc -l
#    Should Be True    ${check_rst}==45
#
#Check ACSI Released Info From Local Egate Log A010 Dedicated
#    [Arguments]    ${log_path}=/opt/iphy/latest
#    ${csi-ReportConfigToReleaseList}=    Set Variable
#        ...    csi-ReportConfigToReleaseList[\\s\\S]+(?P<release_id>\\d)[\\s\\S]+reportTriggerSize
#    ${content}=    OperatingSystem.Get File    ${log_path}/egate_console.log
#    ${release_id_list}=    String.Get Regexp Matches    ${content}    ${csi-ReportConfigToReleaseList}    release_id
#    ${release_id}=    Set Variable    @{release_id_list}[0]
#    Should Be True    ${release_id}==1
#    ${output}=    Set Variable    csi-ReportConfigToReleaseList[\\s\\S]{1,150}aperiodicTriggerStateList release
#    ${output_list}    String.Get Regexp Matches    ${content}    ${output}
#    ${output_content}    Set Variable    @{output_list}[0]
#    Should Contain    ${output_content}    reportTriggerSize 0
#    Should Contain    ${output_content}    aperiodicTriggerStateList release
#
#Convert BIP To CSV And Check Acsi For A010
#    [Arguments]    ${tcid}    ${logid}
#    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest
#    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/${tcid}/${logid}/5GBipL2L1_filtering_off.pcap0
#    ...     ${OUTPUT_DIR}/csv_TC${tcid}_non_acsi.csv    ${filter}    ${csv_title_list}
#    ${rc}    ${output}=    Run And Return Rc And Output    wc ${OUTPUT_DIR}/csv_TC${tcid}_non_acsi.csv|awk '{print $6}'
#    Should Be Equal As Integers    ${rc}    0
#    Should Be True    "${output}"==""
#
#Set numOfUciCsiPart1Bits In Ttitrace_1_a.csv
#    Run Keyword If    "${SW_VERSION}"==""    Get Software Version
#    Run Keyword If    "${SW_VERSION}"=="SBTS23R1"    Modify File Parameter    ${CURDIR}/Resource/TCA005/ttitrace_1_a.csv    ,6    ,5
#
#L3 Call With SA For A010
#    [Arguments]    ${cell_nums}    ${tc_id}
#    Set Suite Variable    ${UE_ID}    1
#    SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    15
#    Capture BIP Log    10    ${SUITE_LOG_DIRECTORY}
#    Scell Addition Triggered By A1 Event
#    Capture TTItrace
#    Capture BIP LOG    10    ${SUITE_LOG_DIRECTORY}/${tc_id}/2
#    Get And Check Cells TP    dl    ${cell_nums}
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
#    SA Stop DL Traffic Egate Command    1
#    SA Stop UL Traffic Egate Command    1
#
#L3 Call With SA For A001
#    [Arguments]    ${cell_nums}    ${tc_id}
#    Set Suite Variable    ${UE_ID}    1
#    SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    Start GNB BIP By Admin Method    0    L1-L2    Local
#    Sleep    1s    reason=Wait for logs
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    100
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    15
#    Sleep    5s    reason=Wait for logs
#    Stop And Collect GNB BIP By Admin Method    ${SUITE_LOG_DIRECTORY}    L1-L2    Local    0
#    Sleep    30s    reason=Wait for the process handling.
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}
#    Get And Check Cells TP    dl    ${cell_nums}
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
#    Start GNB BIP By Admin Method    0    L1-L2    Local
#    Sleep    3s    reason=For the bip log
#    SA Start DL Traffic Egate Command    1    10
#    Sleep    3s    reason=For scell deactive
#    Stop And Collect GNB BIP By Admin Method    ${SUITE_LOG_DIRECTORY}/${tc_id}/2    L1-L2    Local    0
#    Sleep    30s    reason=Wait for the process handling.
#    SA Stop DL Traffic Egate Command    1
#    SA Stop UL Traffic Egate Command    1
#
#L3 Call With SA For A006
#    [Arguments]    ${tc_id}
#    FOR    ${id}    IN RANGE    1    3
#    SA UE Attach And PDU Session Setup    ${id}
#    END
#    Sleep    30s
#    Scell Addition Triggered By A1 Event
#    Scell Addition Triggered By A1 Event    ue_id=2
#    Capture TTItrace And BIP Logs
#
#L3 Call With SA Ucionly For A008
#    [Arguments]    ${cell_nums}
#    Sleep    10s    reason=Wait For all cell....
#    SA Set Traffic Type To Internal    1     ${PDU_ID}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    SA Start DL Traffic Internal    1    ${PDU_ID}    175
#    Scell Addition Triggered By A1 Event
#    Log To Console     \nstart gNBbiplog.....\n
#    Trigger CQI Change And Capture Logs for SA
#    Get And Check Cells TP    dl    ${cell_nums}
#    SA Stop DL Traffic Egate Command    1
#
#Trigger CQI Change And Capture Logs for SA
#    [Arguments]    ${interface}=L1-L2
# 	Log To Console     start bip...
#    Start GNB BIP By Admin Method    0    ${interface}    Local
#    Sleep    10s    reason=Wait for start BIP script
#	Change CQI For UCIonly SA
#	Sleep    10s    reason=Wait for logs
#	Stop And Collect GNB BIP By Admin Method    ${SUITE_LOG_DIRECTORY}    ${interface}    Local    0
#    Sleep    30s    reason=Wait for the process handling.
#    Log To Console     start ttitrace...
#    Sleep    5s    reason=Scell Addition done
#    Start Ttitrace With Streaming Mode
#    Sleep    5s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}
#
#Start L3 Call And BIP Log For A005
#   [Arguments]    ${cell_nums}    ${tc_id}    ${measurement_gap}=0    ${MBPS}=175
#    Set Suite Variable    ${UE_ID}    1
#    SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175    1
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175    2
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175    3
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175    4
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    15    1
#    Scell Addition Triggered By A1 Event    1    2    100
#    sleep    10s    reason=for A1 message is ok
#    Capture TTItrace And BIP Logs
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    dl    450
#    Measurement Gap Triggered By A2 Event
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
#    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}
#    SA Stop DL Traffic Egate Command    1
#    SA Stop UL Traffic Egate Command    1
