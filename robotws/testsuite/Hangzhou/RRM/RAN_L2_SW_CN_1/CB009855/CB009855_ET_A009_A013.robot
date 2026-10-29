*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    master_classicalbts_all    STATE_CONFIGURED
#...               RAN_5G    FR1    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource         ./Resources/CB009855_resource.robot
#*** Variables ***
##Common parameters#
#${SWCONFIG_PARAM}
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      basic_A009_A013.cfg
#${3T3F_IPHY}                    ${CURDIR}/Resources/wts/iphy_A009_3T3F.xml
#${UEC_REACTION_TIME}            100
##A009#
#${FULL_SCF_CB009855_ET_A009}    FULL_SCF_CB009855_A009_TDD_TDLTE_SEMI1-4_SEMI3-7.xml
#${UE1}                          1
#${UE6}                          6
#@{5CC_SCELL_PCI_1}              51    52    53    54
#@{4CC_SCELL_PCI_2}              51    52    53
#${DL_DATA_009}                  1100
#${UL_DATA_009}                  80
#${4CC_NUM}                      4
#${5CC_NUM}                      5
#@{2CC_EXP_UL_TPUT_LIST_009}     10    2
#@{5CC_EXP_DL_TPUT_LIST_009}     400    10    50    50    10
#@{4CC_EXP_DL_TPUT_LIST_009}     400    10    50    50
##A013#
#${FULL_SCF_CB009855_ET_A013}    FULL_SCF_CB009855_A013_TDD_TDLTE_SEMI3-7_SEMI3-7.xml
#@{UE_LIST_013}                  1    2    3    4
#@{5CC_SCELL_PCI}                51    52    53    54
#@{SCELL_PHYSICALID_LIST}        ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}
#${DL_DATA_013}                  560
#${UL_DATA_013}                  50
#@{2CC_EXP_UL_TPUT_LIST_013}     10    2
#@{5CC_EXP_DL_TPUT_LIST_013}     50    2    10    10    2
#@{LOG_NAME_LIST}                snapshot    btsLog    sosreport
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-ET-A009_Verify_3T2F_DL_CA_Deactivation_With_Different_FrameStruture_BF_DL_Trf
#    [Tags]    Owner_j8shen    CRT
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_ET_A009}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    Start Gnb BIP Log
#    5CC UE Attach And Start DL UL Big Traffic
#    ...    ${UE1}    ${5CC_SCELL_PCI_1}    ${5CC_NUM}    ${DL_DATA_009}    ${UL_DATA_009}
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    maxNumScellsDlFr1    3
#    5CC UE Attach And Start DL UL Big Traffic
#    ...    ${UE6}    ${4CC_SCELL_PCI_2}    ${4CC_NUM}    ${DL_DATA_009}    ${UL_DATA_009}
#    Wait Until Keyword Succeeds    60s    3sec    Check 5CC CA UE DL And UL Pcell Scell TP On Target
#    Wait Until Keyword Succeeds    60s    3sec    Check 4CC CA UE DL And UL Pcell Scell TP On Target
#    Run Keyword And Continue On Failure    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    Capture Convert Format Ttitrace With Streaming Mode    1s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    A2A Check Peak CSI Bundling Bits And Harq Bits
#    [Teardown]    Common Test Teardown
#
#CB009855-ET-A013_Verify_3T2F_DL_CA_Peak_UCIBits_With_PCSI_Bundling_MultiUE_AddionPUCCHDMRS
#    [Tags]    Owner_y7li    CRT
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_ET_A013}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA Multi UE Attach With Scell Blind Addition    ${UE_LIST_013}    ${SCELL_PHYSICALID_LIST}    ${5CC_NUM}
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST_013}    ${DL_DATA_013}    ${UL_DATA_013}
#    Override All UE RI For TDD Pcell 4Layer    ${UE_LIST_013}
#    Sleep    10s    reason=wait for all UEs traffic statble
#    Capture Convert Format Ttitrace With Streaming Mode    0.5s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Run Keyword And Ignore Error    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA Cell L1 Tput
#    ...    ${UE_LIST_013}    ${5CC_EXP_DL_TPUT_LIST_013}    ${5CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE ULCA Cell L1 Tput
#    ...    ${UE_LIST_013}    ${2CC_EXP_UL_TPUT_LIST_013}    ${5CC_NUM}
#    A2A Check Four UEs Can Achieve Peak CSI Bundling Bits And Harq Bits
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#5CC UE Attach And Start DL UL Big Traffic
#    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    ${ul_data}
#    SA 5G CA Attach    ${ue_id}
#    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}
#    Override Pcell RI To 4layer And Scells 2layer Per CC Num    ${ue_id}    ${cc_num}
#    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data}
#    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data}
#    Sleep    10s    reason=wait for traffic statble
#
#
#
#Check 5CC CA UE DL And UL Pcell Scell TP On Target
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE1}    ${5CC_EXP_DL_TPUT_LIST_009}    ${5CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE1}    ${2CC_EXP_UL_TPUT_LIST_009}    ${5CC_NUM}
#
#Check 4CC CA UE DL And UL Pcell Scell TP On Target
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE6}    ${4CC_EXP_DL_TPUT_LIST_009}    ${4CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE6}    ${2CC_EXP_UL_TPUT_LIST_009}    ${4CC_NUM}
#
#A2A Check Peak CSI Bundling Bits And Harq Bits
#    ${UE1_CRNTI}=    Get Crnti From Egate Log    ${UE1}
#    Set Suite Variable    ${UE1_CRNTI}
#    ${UE6_CRNTI}=    Get Crnti From Egate Log    ${UE6}
#    Set Suite Variable    ${UE6_CRNTI}
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CB009855_A/A009_bip.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#
#A2A Check Four UEs Can Achieve Peak CSI Bundling Bits And Harq Bits
#    ${UE1_LIST_013}=    Get Crnti From Egate Log    ${UE_LIST_013}[0]
#    Set Suite Variable    ${UE1_LIST_013}
#    ${UE2_LIST_013}=    Get Crnti From Egate Log    ${UE_LIST_013}[1]
#    Set Suite Variable    ${UE2_LIST_013}
#    ${UE3_LIST_013}=    Get Crnti From Egate Log    ${UE_LIST_013}[2]
#    Set Suite Variable    ${UE3_LIST_013}
#    ${UE4_LIST_013}=    Get Crnti From Egate Log    ${UE_LIST_013}[3]
#    Set Suite Variable    ${UE4_LIST_013}
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CB009855_A/A013_bip.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
