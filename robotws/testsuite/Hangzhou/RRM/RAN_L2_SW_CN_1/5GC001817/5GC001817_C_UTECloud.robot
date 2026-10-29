*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords
#...               Common Suite Setup
#...               Set Config Path
#Suite Teardown    Common Suite Teardown
#
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    RAN_5G_FDD
#...                FR1    PRI-High    RAN_5G    SBTS00    SBTS23R1    CN1_SQ    CRT
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#Resource          ./keywords_1817_common_AP.robot
#Library           BuiltIn
#Library           String
#Library           taf.wts.runner    WITH NAME    wtsrunner
#Library           ./csv_bit_to_qci.py
#
#*** Variables ***
#${scf_path}    ${CURDIR}
#${L3_CALL_TYPE_for_various_case}    "SA_basic_L3CALL"
#${NSA_DL}        5
#${NSA_UL}        5
#${GSCN_10M_CA002}          1582
#${GSCN_10M_C019}          1582
#${GSCN_5M}           1596
#${GSCN_10M}          1582
#${GSCN_20M}          1582
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${DELTA_PATH_5M_C018}    Delta_conf_5GC001817_ET_5M_C018.json
#${DELTA_PATH_20M_C020}    Delta_conf_5GC001817_ET_20M_C020.json
#${DELTA_PATH_20M_CA003}    Delta_conf_5GC001817_ET_20M_CA003.json
#${DELTA_PATH_10M_CA002}    Delta_conf_5GC001817_ET_10M_CA002.json
#${DELTA_PATH_20M_CA001}    Delta_conf_5GC001817_ET_20M_CA001.json
#${DELTA_PATH_20M_C017}       Delta_conf_5GC001817_ET_20M_C017.json
#${DELTA_PATH_10M_C022}    Delta_conf_5GC001817_ET_10M_C022.json
#${DELTA_PATH_10M_C023}    Delta_conf_5GC001817_ET_10M_C023.json
#${DELTA_PATH_20M_C021}    Delta_conf_5GC001817_ET_20M_C021.json
#${DELTA_PATH_10M_C019}    Delta_conf_5GC001817_ET_10M_C019.json
#${DELTA_PATH_20M_C029}    Delta_conf_5GC001817_ET_20M_C029.json
#${DELTA_PATH_20M_CA004}    Delta_conf_5GC001817_ET_20M_CA004.json
#${WTS_CFG}          wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
#@{old_values_patts}    ue_nr_capabilities=[0-9a-zA-Z]+
#@{new_values_NSA}    ue_nr_capabilities=${ue_capacity_NSA}
#${ue_capacity_NSA}        E1201000014F5E0342C00201404820D9C4C3E140426C020FFCC31E50B03826010188A01014C200141F11B586368E9315047F2
#                   ...    CA49940220B64C1203063C63FF30C7942C0E070F0113804E0001083011B9343E01C8200000148200000548200000949280000
#                   ...    D300F81B795378195BA40141000009652404000065949010000296524040000E594941000049652424000154B29200BA07174
#                   ...    AA2E81C4D2A89A55115D88020F00340201000000100
#@{new_values_SA}    ue_nr_capabilities=${ue_capacity_SA}
#${ue_capacity_SA}         E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531800507C46D618DA3A4C5411FCB
#                   ...    29265048082D930480C18F18FFCC31E50B0381C3C04CEC3B0CEC3B004003000000000711800000001083011B9343E01C82000001
#                   ...    48200000548200000949280000D300B81B791B5BA40141000009652404000065949010000296524040000E594941000049652424
#                   ...    000154B292009A071748E2E8544D2A88AEC409007801A01008000000000020040084
#${TestLine_Type_NSA}    NSA
#${TestLine_Type_SA}    SA
#${OPENLOOP_FLAG}     OpenLoop
#${CLOSELOOP_FLAG}     CloseLoop
#${NO_UL_ZEROPADDING}    False
#${UL_ZEROPADDING}    True
#${UciOnly_False}    0
#${UciOnly_True}    1
#
#*** Test Cases ***
##5GC001817_C020_NSA_CL_MIMO4_2_20Mhz_UL_256QAM_SUE_fullmode_Optimisticenable
#    #[Documentation]    The purpose
#    #[Tags]    Owner_WangAbby   case_C020
#    #[setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M_C020}    ucionly=${UciOnly_False}
#    #...    EnableBetaOptimistic=1    gscn=${GSCN_20M}    nsa_sa_flag=${TestLine_Type_NSA}
#    #[Timeout]  40min
#    #Start L3 Call And BIP Log    ${TestLine_Type_NSA}    ${NO_UL_ZEROPADDING}    ${UciOnly_False}
#    #Check ACSI Info From Egate Log   ${CLOSELOOP_FLAG}
#    #Check BetaOffsets From Egate Log    ${TestLine_Type_NSA}
#    #Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
#    #Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    020
#    #Check l1_common_dtx_t.value in PuschReceiveRespPs    020
#    #Check csiPart1CrcCheck in PuschReceiveRespPs    020
#    #Check csiPart2CrcCheck in PuschReceiveRespPs    020
#    #Check dtxCsiPart1 in PuschReceiveRespPs    020
#    #Check dtxCsiPart2 in PuschReceiveRespPs    020
#    #Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    020
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    020
#    #Check_Betaoffset_MCShark    020
#    #[Teardown]    Recover TL For Each Case
#
#5GC001817_C023_SA_CL_MIMO4_2_10Mhz_ULzeropadding_64QAM_SUE_fullmode_Optimisticdisable
#    [Documentation]    The purpose
#    [Tags]    Owner_LiuHaiyan   case_C023
#    [setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_10M_C023}    ucionly=${UciOnly_False}    gscn=${GSCN_10M}
#    ...    nsa_sa_flag=${TestLine_Type_NSA}
#    [Timeout]  40min
#    Start L3 Call And BIP Log    ${TestLine_Type_NSA}    ${NO_UL_ZEROPADDING}    ${UciOnly_False}
#    Check ACSI Info From Egate Log   {CLOSELOOP_FLAG}
#    Check BetaOffsets From Egate Log    ${TestLine_Type_NSA}
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_10M
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    023
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    023
#    Check csiPart1CrcCheck in PuschReceiveRespPs    023
#    Check csiPart2CrcCheck in PuschReceiveRespPs    023
#    Check dtxCsiPart1 in PuschReceiveRespPs    023
#    Check dtxCsiPart2 in PuschReceiveRespPs    023
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    023
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    023
#    Check_Betaoffset_MCShark    023
#    [Teardown]    Recover TL For Each Case
#
##5GC001817_C026_NSA_CL_MIMO4_2_20Mhz_UL_256QAM_SUE_fullmode_Optimisticenable_Ucionly
#    #[Documentation]    The purpose
#    #[Tags]    Owner_WangAbby   case_C026
#    #[setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M_C020}    ucionly=${UciOnly_True}
#    #...    EnableBetaOptimistic=1    gscn=${GSCN_20M}    nsa_sa_flag=${TestLine_Type_NSA}
#    #[Timeout]  40min
#    #Sleep   180s
#    #Log To Console    start sos report ...
#    #Start L3 Call And BIP Log    ${TestLine_Type_NSA}    ${UL_ZEROPADDING}    ${UciOnly_True}
#    #Check ACSI Info From Egate Log   ${CLOSELOOP_FLAG}
#    #Check BetaOffsets From Egate Log    ${TestLine_Type_NSA}
#    #Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
#    #Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    026
#    #Check l1_common_dtx_t.value in PuschReceiveRespPs    026
#    #Check csiPart1CrcCheck in PuschReceiveRespPs    026
#    #Check csiPart2CrcCheck in PuschReceiveRespPs    026
#    #Check dtxCsiPart1 in PuschReceiveRespPs    026
#    #Check dtxCsiPart2 in PuschReceiveRespPs    026
#    #Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    026
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    026
#    #Check_Betaoffset_MCShark    026
#    #Check_Ucionly_MCShark    026
#    #[Teardown]    Recover TL For Each Case
#
##5GC001817_CA001_SA_CL_MIMO4_2_20Mhz_UL256QAM_DL256QAM_SUE_fullmode_Optimisticenable
#    #[Tags]    Owner_susie    case_CA001
#    #[setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M_CA001}    EnableBetaOptimistic=1
#    #...    ucionly=${UciOnly_False}    gscn=${GSCN_20M}    nsa_sa_flag=${TestLine_Type_SA}
#    #[Timeout]  40min
#    #Start L3 Call And BIP Log    ${TestLine_Type_SA}    ${NO_UL_ZEROPADDING}    ${UciOnly_False}
#    #Sleep    10s    reason=For the egate log
#    #Check ACSI Info From Egate Log    ${CLOSELOOP_FLAG}
#    #Check BetaOffsets From Egate Log    ${TestLine_Type_SA}
#    #Copy Preference For MCShark    ${CURDIR}/Resource/TC01/preferences
#    #Check BeataOffset And UL256 QAM In CSV File     01
#    #Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    01
#    #Check l1_common_dtx_t.value in PuschReceiveRespPs    01
#    #Check csiPart1CrcCheck in PuschReceiveRespPs    01
#    #Check csiPart2CrcCheck in PuschReceiveRespPs    01
#    #Check dtxCsiPart1 in PuschReceiveRespPs    01
#    #Check dtxCsiPart2 in PuschReceiveRespPs    01
#    #Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    01
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    01
#    #[Teardown]     Recover TL For Each Case
#
##5GC001817_CA002_NSA_CL_MIMO2_2_10Mhz_UL256QAM_DL256QAM_SUE_fullmode_Optimisticenable
#    #[Tags]    Owner_susie    case_CA002
#    #[setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_10M_CA002}    EnableBetaOptimistic=1
#    #...    ucionly=${UciOnly_False}    gscn=${GSCN_10M_CA002}    nsa_sa_flag=${TestLine_Type_NSA}
#    #[Timeout]  40min
#    #Start L3 Call And BIP Log    ${TestLine_Type_NSA}    ${NO_UL_ZEROPADDING}    ${UciOnly_False}
#    #Sleep    10s    reason=For the egate log
#    #Check ACSI Info From Egate Log    ${CLOSELOOP_FLAG}
#    #Check BetaOffsets From Egate Log    ${TestLine_Type_NSA}
#    #Copy Preference For MCShark    ${CURDIR}/Resource/TC002/preferences
#    #Check BeataOffset And UL256 QAM In CSV File     002
#    #Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    002
#    #Check l1_common_dtx_t.value in PuschReceiveRespPs    002
#    #Check csiPart1CrcCheck in PuschReceiveRespPs    002
#    #Check csiPart2CrcCheck in PuschReceiveRespPs    002
#    #Check dtxCsiPart1 in PuschReceiveRespPs    002
#    #Check dtxCsiPart2 in PuschReceiveRespPs    002
#    #Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    002
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    002
#    #[Teardown]       Recover TL For Each Case
#
#5GC001817_CA003_SA_CL_MIMO4_2_20Mhz_UL256QAM_DL256QAM_SUE_limitedmode_Ucionly
#    [Documentation]    The purpose
#    [Tags]    Owner_WangAbby   case_CA003
#    [setup]    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M_CA003}    EnableDynBetaOff=0x1    ucionly=${UciOnly_True}
#    ...    gscn=${GSCN_20M}    nsa_sa_flag=${TestLine_Type_SA}
#    [Timeout]  40min
#    Start L3 Call And BIP Log    ${TestLine_Type_SA}    ${UL_ZEROPADDING}    ${UciOnly_True}
#    Check ACSI Info From Egate Log   ${CLOSELOOP_FLAG}
#    Check BetaOffsets From Egate Log    ${TestLine_Type_SA}
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A003
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    A003
#    Check csiPart1CrcCheck in PuschReceiveRespPs    A003
#    Check csiPart2CrcCheck in PuschReceiveRespPs    A003
#    Check dtxCsiPart1 in PuschReceiveRespPs    A003
#    Check dtxCsiPart2 in PuschReceiveRespPs    A003
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    A003
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    A003
#    Check_Betaoffset_MCShark    A003
#    Check_Ucionly_MCShark    A003
#    [Teardown]    Recover TL For Each Case
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB
#    Set Suite Variable    @{ASP_BOARDS_TYPE}    ABIO
#    Set Suite Variable    @{AP_ASP_BOARDS_TYPE}    ABIL
#    Suite Setup Copy WTS Config Files From QT
#
#Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
#    [Arguments]    ${tc_id}
#    Log To Console    Check A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark For 5GC001817-A    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv
#
#Setup TL For Test Case
#    [Arguments]    ${delta_file}    ${EnableDynBetaOff}=2    ${EnableBetaOptimistic}=0    ${ACsiCheckDlLoad}=1
#    ...    ${ucionly}=1    ${ModeratePayloadSizeThr}=0x2    ${CqiJitterTimer}=0x28    ${AcsiHighJitterTimer}=0x28
#    ...    ${CqiDeltaThreshold}=0    ${gscn}=1    ${nsa_sa_flag}=NSA
#    Verify Coam Site Is Ready
#    Backup Gnb Sw Configuration
#    Modify Gnb Sw Configuration 1817-C    ${EnableDynBetaOff}    ${EnableBetaOptimistic}    ${ACsiCheckDlLoad}    ${ucionly}
#    ...    ${ModeratePayloadSizeThr}    ${CqiJitterTimer}    ${AcsiHighJitterTimer}    ${CqiDeltaThreshold}
#    Backup AP Config File
#    Configure Airphone    ${gscn}
#    Configure Gnb    ${delta_file}
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    Modify UE Capbility For 1817C    ${nsa_sa_flag}
#    Suite Setup Start WTS And Check OnAir
#
#Setup TL For Test Case WiReboot
#    [Arguments]    ${delta_file}    ${EnableDynBetaOff}=2    ${EnableBetaOptimistic}=0    ${ACsiCheckDlLoad}=1
#    ...    ${ucionly}=1    ${ModeratePayloadSizeThr}=0x2    ${CqiJitterTimer}=0x28    ${AcsiHighJitterTimer}=0x28
#    ...    ${CqiDeltaThreshold}=0    ${gscn}=1    ${nsa_sa_flag}=NSA
#    Verify Coam Site Is Ready
#	Backup Gnb Sw Configuration
#    Modify Gnb Sw Configuration 1817-C    ${EnableDynBetaOff}    ${EnableBetaOptimistic}    ${ACsiCheckDlLoad}    ${ucionly}
#    ...    ${ModeratePayloadSizeThr}    ${CqiJitterTimer}    ${AcsiHighJitterTimer}    ${CqiDeltaThreshold}
#    Backup AP Config File
#    Configure Airphone    ${gscn}
#    Configure Gnb    ${delta_file}
#    Reboot TL And Check Configured
#    Verify Coam Site Is Ready
#    Modify UE Capbility For 1817C    ${nsa_sa_flag}
#    Suite Setup Start WTS And Check OnAir
#
#Recover TL For Each Case
#    Recover Gnb Sw Configuration
#    Recover AP Config File
#    Recover Config
#    Clean Edaemon And Egate
#    Stop Edaemon Egate
#
#Start L3 Call And BIP Log
#    [Arguments]    ${sa_flag}    ${ul_zeropadding}    ${ucionly}
#    Run Keyword If    '${sa_flag}'=='SA'
#    ...    L3 Call With SA    ${ul_zeropadding}    ${ucionly}
#    Run Keyword If    '${sa_flag}'=='NSA'
#    ...    L3 Call With NSA    ${ul_zeropadding}    ${ucionly}
#    sleep    10s
#
#L3 Call With NSA
#    [Arguments]    ${ul_zeropadding}    ${ucionly}
#    ${UE_ID}=    Set Variable    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Run Keyword If    '${ucionly}'=='1'
#    ...    ute_wtssim.Execute Egate Command    enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Start Gnb BIP Log
#    Run Keyword If    '${ucionly}'=='1'
#    ...    Change CQI For UCIonly NSA
#    Sleep    10s    reason=Keep the traffic stable
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    NSA Stop Traffic    11    2    dl
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Stop Traffic    11    2    ul
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
#    NSA LTE Detach     ${UE_ID}
#
#Change CQI For UCIonly NSA
#    Log To Console    Change CQI ...
#    ${prepare_1}    Set Variable
#    ...    csi_override_testmode_nr profile_id=3 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
#    ${prepare_2}    Set Variable
#    ...    ue_testmode_set_nr id=11 testmode=csi_override profile_id=3 action=activate scell=5
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
#
#L3 Call With SA
#    [Arguments]    ${ul_zeropadding}    ${ucionly}
#    SA Traffic Type Setting    ${UE_ID}
#    #Start Gnb BIP Log
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Egate Command    1    20
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...       SA Start UL Traffic Egate Command    1    20
#    Start Gnb BIP Log
#    Run Keyword If    '${ucionly}'=='1'
#    ...    Change CQI For UCIonly SA
#    sleep    15s
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    SA Stop DL Traffic Egate Command    1
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    dl    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    SA Stop UL Traffic Egate Command    1
#
#Change CQI For UCIonly SA
#    Log To Console    Change CQI ...
#    ${prepare_1}    Set Variable
#    ...    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
#
#    ${prepare_2}    Set Variable
#    ...    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
#
#Convert BIP To CSV By MCShark FOR BetaOffsets And UL256
#    [Arguments]    ${case_id}
#    ${filter}=    Set Variable
#    ...    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
#    @{csv_title_list}=    Create List    3gpp.sfn    dci.dci01.CSIrequest
#    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits    UlData_puschReceiveReqGrant_t.mcsTable
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#        Convert BIP To CSV By MCShark    ${name}    ${OUTPUT_DIR}/csv_CA${case_id}_${index}.csv    ${filter}    ${csv_title_list}
#    END
#
#Check BeataOffset And UL256 QAM In CSV File
#    [Arguments]    ${case_id}
#    Convert BIP To CSV By MCShark FOR BetaOffsets And UL256    ${case_id}
#    ${bip_csv_names}    OperatingSystem.List Files In Directory    ${OUTPUT_DIR}    csv_CA${case_id}_*.csv    ${True}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${case_id}/ttitrace_CA${case_id}.ini    ${bip_csv_names}[0]
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
