*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From QT
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
##CB009169-ET-BD029
#${DELTA_SCF_001}               Delta_CB009169_ULCA_029.json
#${WTS_CFG_001}                 basic_setup_CB009169_mutiue.cfg
##CB009169-ET-BD023
#${DELTA_SCF_002}               Delta_Conf_CB009169_DMRS_FDM.json
#${WTS_CFG_002}                 basic_setup_CB009169_BD.cfg
#${WTS_CFG_003}                 basic_setup_CB009169_Special_UE_Capability.cfg
##CB009169-ET-BD020
#${FULL_SCF_003}                           FULL_CB009169_TypeA_SCFC.xml
#${FILTER_TYPEA}                uldata_puschreceivereq
#@{COLUMN_NAME_TYPEA}           UlData_puschReceiveReqGrant_t.ulDmrsMappingType
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${SCF_PATH}                    ${CURDIR}/Config
#${SWCONFIG_PARAM}              0x580692=1
#@{SCELL_PHYSICALID_LIST}       50    52
#${2CC_UE_ID}                   1
#@{2CC_UE_ID_LIST}              1
#${2CC_DL_DATA}                 600
#${2CC_UL_DATA}                 100
#@{2CC_EXP_DL_TPUT_LIST_029}    400    50
#@{2CC_EXP_UL_TPUT_LIST_029}    30    20
#@{2CC_EXP_DL_TPUT_LIST_023}    450    70
#@{2CC_EXP_UL_TPUT_LIST_023}    30    15
#@{2CC_EXP_DL_TPUT_LIST_032}    400    60
#@{2CC_EXP_UL_TPUT_LIST_032}    15    0
##ACSI***TC015***TC016***
#${FULL_SCF_TDD_ACSI}           Full_CB009169_ACSI.xml
#${WTS_CFG_015}                 CB009169_BD_IWK7_ACSI.cfg
#@{2CC_UE_LIST_015}             20    21    22    23    24
#@{2CC_SCELL_PCI_1}             50
#@{2CC_SCELL_PCI_2}             50
#@{2CC_SCELL_PCI_3}             50
#@{2CC_SCELL_PCI_4}             50
#@{2CC_SCELL_PCI_5}             50
#@{2CC_SCELL_PCI_LIST_015}      ${2CC_SCELL_PCI_1}    ${2CC_SCELL_PCI_2}    ${2CC_SCELL_PCI_3}    ${2CC_SCELL_PCI_4}    ${2CC_SCELL_PCI_5}
#${2CC_DL_DATA_015}             20
#${2CC_UL_DATA_015}             10
#@{2CC_EXP_UL_TPUT_LIST_015}    1    0
#${RD_DEBUG_015}                0x58057a=0x4;0x58057c=0x1C00000;0x58057d=0x3000
#${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
#${FILTER}                      dci.dci01.CSIrequest == 1||uldata_puschreceivereq||uldata_puschreceiverespps
#@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#...                            UlData_puschReceiveReqGrant_t.uciOnly    UlData_UePuschReceiveRespPs_t.dtx
#...                            UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
#...                            UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
#${PREFERENCE_016}              preferences_T_F_CA
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009169_ET_BD029_UL_CA_Call_With_4Rx_IRC_For_TDD_FR1_Cell_On_ABIO
#    [Tags]    Owner_melwu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_001}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_001}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_001}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Check SA All Scell PhysicalID With UE ID    ${2CC_UE_ID}    ${SCELL_PHYSICALID_LIST}    2
#    SA Start DL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_DL_DATA}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_UL_DATA}    trf_id=1
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_029}    ${2CC_EXP_DL_TPUT_LIST_029}    2
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    Verify PUCCH Group And PUSCH Configured
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BD023_UL_CA_Call_With_PUSCH_Data_And_DMRS_FDM_Without_DFT_S_OFDM_On_ABIO
#    [Tags]    Owner_fanjin
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_002}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_002}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_002}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Trigger A1 Scell Addition    ${2CC_UE_ID}    srsrp_nr=95    phycell_id=52
#    Start SA UE Big DL Traffic Internal    ${2CC_UE_ID}    ${2CC_DL_DATA}
#    Start SA UE Big UL Traffic Internal    ${2CC_UE_ID}    ${2CC_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_023}    ${2CC_EXP_DL_TPUT_LIST_023}    2
#    Capture Convert Format Ttitrace With Streaming Mode    3s
#    Verify PUSCH And DMRS FDM
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BD015_ACSI_IWK_T_F_2CC_FR1_DlMimomode_70_BF
#    [Tags]    Owner_naliu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_TDD_ACSI}    swconfig_param=${RD_DEBUG_015}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_015}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_015}
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST_015}    ${2CC_SCELL_PCI_LIST_015}    2
#    Trigger CQI Jitter
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST_015}    ${2CC_DL_DATA_015}    ${2CC_UL_DATA_015}
#    Sleep    2s    reason=wait for data is stable
#    Check Multi UE ULCA Cell L1 Tput    ${2CC_UE_LIST_015}    ${2CC_EXP_UL_TPUT_LIST_015}    2
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Check ACSI
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BD016_ACSI_UCI_Only_IWK_T_F_2CC_FR1_DlMimomode_70_BF
#    [Tags]    Owner_naliu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_TDD_ACSI}    swconfig_param=${RD_DEBUG_015}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_015}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_015}
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST_015}    ${2CC_SCELL_PCI_LIST_015}    2
#    Trigger CQI Jitter
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=before ue DL traffic
#    SA Multi UE Start DL Traffic    ${2CC_UE_LIST_015}    ${2CC_DL_DATA_015}
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Covert BIP To Csv
#    Check UCI Only
##    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    GNB_swconfig_file=${GNB_SWCONFIG_TEST_BAK_FILE}
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BD020_UL_CA_Call_With_PUSCH_Mapping_TypeA_Just_Enable_On_Pcell_On_ABIO
#    [Tags]    Owner_zbu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_003}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_002}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_002}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Trigger A1 Scell Addition    ${2CC_UE_ID}    srsrp_nr=95    phycell_id=52
#    Start SA UE Big DL Traffic Internal    ${2CC_UE_ID}    ${2CC_DL_DATA}
#    Start SA UE Big UL Traffic Internal    ${2CC_UE_ID}    ${2CC_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
##    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_029}    ${2CC_EXP_DL_TPUT_LIST_029}    2
#    Capture And Covert BIP To Csv    ${FILTER_TYPEA}    ${COLUMN_NAME_TYPEA}
#    Verify PUSCH Mapping TypeA
##    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#    [Teardown]    Common Test Teardown
#
#
#CB009169_ET_BD032_UL_CA_Call_For_SA_With_UE_Capability_Support_1_UL_MIMO_Layer_And_2_SRS_Ports_Work_On_ABIO
#    [Tags]    Owner_xiaothan
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_003}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_003}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_003}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Trigger A1 Scell Addition    ${2CC_UE_ID}    srsrp_nr=95    phycell_id=52
#    Start SA UE Big DL Traffic Internal    ${2CC_UE_ID}    ${2CC_DL_DATA}
#    Start SA UE Big UL Traffic Internal    ${2CC_UE_ID}    ${2CC_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_032}    ${2CC_EXP_DL_TPUT_LIST_032}    2
#    Check UL Of Scell Not Be Triggered
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Verify PUCCH Group And PUSCH Configured
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD029_4Rx_IRC.ini    p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
#
#Verify PUSCH And DMRS FDM
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD023_DMRS_FDM.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#Trigger CQI Jitter
#    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id=4 cqi_mode=varying cqi=2,6,8,13,15
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=20,21,22,23,24 scell=primary testmode=csi_override profile_id=4 action=activate
#
#Check ACSI
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate1/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD015_ACSI.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD015_ACSI.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}/
#
#Check UCI Only
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate2/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD016_ACSI.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD016_UCIOnly.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD016_ACSI.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}/
#
#Covert BIP To Csv
#    Copy Preference For MCShark    ${CURDIR}/Resource/${PREFERENCE_016}
#    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/${BIP_CSV_NAME}    filter=${FILTER}    csv_title_list=${COLUMN_NAME}
#
#Verify PUSCH Mapping TypeA
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB009169_BD${/}CB009169-BD_PUSCH_Mapping_TypeA.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
#
#Capture And Covert BIP To Csv
#    [Arguments]    ${FILTER}    ${COLUMN_NAME}
#    Sleep    1s    reason=Wait For Transmission Stable
#    Start Gnb BIP Log
#    Sleep    1s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.csv    filter=${FILTER}
#    ...    csv_title_list=${COLUMN_NAME}
#
#Check UL Of Scell Not Be Triggered
#    ${output}    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id\=${2CC_UE_ID} type=pusch scell=primary,secondary    pass_regexp=CellIndex
#    Sleep    1s    reason=capture short egatelog
#    Should Not Match Regexp    ${output}    CellIndex-1
