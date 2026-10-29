*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    master_classicalbts_all    STATE_CONFIGURED
#...               RAN_5G    FR1    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB009855_resource.robot
#
#*** Variables ***
##Common parameters#
#${SCF_PATH}                    ${CURDIR}/Config
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${WTS_CFG}                     basic_B801.cfg
#${3T3F_IPHY}                   ${CURDIR}/Resources/wts/iphy_B801.xml
##B101&B701#
#${FULL_SCF_9855_ET_B101}       FULL_SCF_CB009855_B101.xml
#@{5CC_2T3F_UE10}               10
#@{5CC_3T2F_UE1}                1
#@{5CC_PCELL_ID}                55
#@{5CC_2T3F_SCELL_PCI_LISTS}    ${5CC_2T3F_SCELL_PCI}
#@{5CC_2T3F_SCELL_PCI}          50    51    53    54
#@{5CC_3T2F_SCELL_PCI_LISTS}    ${5CC_3T2F_SCELL_PCI}
#@{5CC_3T2F_SCELL_PCI}          51    52    53    54
#${A1THRESHOLD}                 105
#${A2THRESHOLD}                 70
#${DL_DATA}                     1650
#${UL_DATA}                     100
#${5CC_NUM}                     5
#@{2CC_EXP_UL_TPUT_LIST}        30    10
#@{5CC_EXP_DL_TPUT_LIST}        570    70    70    340    70
#@{4CC_EXP_DL_TPUT_LIST}        670    80    80    0    80
#@{3CC_EXP_DL_TPUT_LIST}        800    0    90    0    90
#@{2CC_EXP_DL_TPUT_LIST}        900    0    0    0    120
#@{1CC_EXP_DL_TPUT_LIST}        1000    0    0    0    0
#@{5CC_EXP_DL_TPUT_B701}        900    0    0    200    0
##B801#
#${FULL_SCF_9855_ET_B801}       FULL_SCF_CB009855_B801.xml
#${UE1}                         1
#${UE10}                        10
#${UE11}                        11
#${UE12}                        12
#${UE13}                        13
#${UE14}                        14
#${UE15}                        15
#@{5CC_SCELL_PCI_3T2F}          51    52    53    54
#@{5CC_SCELL_PCI_2T3F}          50    51    53    54
#@{UE13_4CC_SCELL_PCI}          50    53    54
#${DL_DATA_801}                 370
#${UL_DATA_801}                 40
#${4CC_NUM}                     4
#@{2CC_EXP_UL_TPUT_B801}        10    10
#@{5CC_EXP_DL_TPUT_B801}        100    10    10    50    10
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-ET-B101_Verify_Pucch_Resource_Reconfigured_After_Scell_Release_For_2T3F_UE
#    [Documentation]
#    ...    Test Purpose:Verify payload and DL throughput after A2 scell release for 2T3F UE.
#    ...    Notes:
#    ...    First release TDD scell3, check it will be 4CC and    due to tput keyword limation I will just
#    ...    set the 3rd scell tput to 0 for    ${4CC_EXP_DL_TPUT_LIST}; and verify the following scell release
#    ...    and tput using same method.
#    [Tags]    Owner_j8shen    CRT    Case_B101
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_9855_ET_B101}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA Multi UE Attach With Scell A1 Addition
#    ...    ${5CC_2T3F_UE10}    ${5CC_PCELL_ID}    ${5CC_2T3F_SCELL_PCI_LISTS}    ${A1THRESHOLD}    ${5CC_NUM}
#    SA Multi UE Start DL And UL Traffic    ${5CC_2T3F_UE10}    ${DL_DATA}    ${UL_DATA}
#    Sleep    30s    reason=wait for traffic stable
#    Wait Until Keyword Succeeds    120s    8sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${5CC_2T3F_UE10}    ${2CC_EXP_UL_TPUT_LIST}    ${5CC_EXP_DL_TPUT_LIST}    ${5CC_NUM}
#    Trigger A2 Scell Release One By One    ${5CC_2T3F_UE10}    scell_id=3    meas_id=4
#    Trigger A2 Scell Release One By One    ${5CC_2T3F_UE10}    scell_id=1    meas_id=2
#    Trigger A2 Scell Release One By One    ${5CC_2T3F_UE10}    scell_id=2    meas_id=3
#    Trigger A2 Scell Release One By One    ${5CC_2T3F_UE10}    scell_id=4    meas_id=5
#    Capture Convert Format Ttitrace With Streaming Mode    1s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    A2A Check MaxPayloadSize For Scell Release
#
#*** Keywords ***
#Trigger A2 Scell Release One By One
#    [Arguments]    ${ue_id}    ${scell_id}    ${meas_id}
#    Trigger A2 Scell Release    ${ue_id[0]}    ${scell_id}    70    55    ${meas_id}
#    Sleep    2s    reason=wait for scell release
#
#Trigger A2 Scell Release And Check DLUL Tput
#    [Arguments]    ${ue_id}    ${scell_id}    ${meas_id}    ${exp_ul_tput}    ${exp_dl_tput}    ${CC_num}
#    Trigger A2 Scell Release    ${ue_id[0]}    ${scell_id}    70    55    ${meas_id}
#    Sleep    2s    reason=wait for scell release
#    Wait Until Keyword Succeeds    60s    6sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${ue_id}    ${exp_ul_tput}    ${exp_dl_tput}    ${CC_num}
#
#Trigger A2 Scell Release And Check DL Tput
#    [Arguments]    ${ue_id}    ${scell_id}    ${meas_id}    ${exp_dl_tput}    ${CC_num}
#    Trigger A2 Scell Release    ${ue_id[0]}    ${scell_id}    70    55    ${meas_id}
#    Sleep    2s    reason=wait for scell release
#    Wait Until Keyword Succeeds    60s    6sec    Check Multi UE DLCA Cell L1 Tput    ${ue_id}    ${exp_dl_tput}    ${CC_num}
#
#A2A Check MaxPayloadSize For Scell Release
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B/B101.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}
#
#5CC UE Attach And Start DL UL Big Traffic
#    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${dl_data}    ${ul_data}    ${cc_num}=5
#    SA 5G CA Attach    ${ue_id}
#    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}
#    Override Pcell RI To 4layer And Scells 2layer Per CC Num    ${ue_id}    ${cc_num}
#    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data}
#    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data}
#    Sleep    10s    reason=wait for traffic statble
#
#Check 5CC CA UE DL And UL Pcell Scell TP On Target
#    [Arguments]    ${ue_id}    ${5CC_EXP_DL_TPUT}    ${5CC_EXP_UL_TPUT}    ${5cc_num}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${5CC_EXP_DL_TPUT}    ${5cc_num}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${ue_id}    ${5CC_EXP_UL_TPUT}    ${5cc_num}
#
#Check 2T3F UE 3GPP OAI Deactivated And Activated As Expect
#    Send OAI To GNB    ue_id=10    operation=yes    reducedCCsDL=0    reducedCCsUL=1
#    Check Scell ActiveDeactivate Times    1    5    deactivated    1
#    Sleep    10s    reason=wait for traffic stable
#    Send OAI To GNB    ue_id=10    operation=yes    reducedCCsDL=4    reducedCCsUL=1
#    Check Scell ActiveDeactivate Times    1    5    activated    2
#    Sleep    10s    reason=wait for traffic stable
#    CUDU L2 Capture And Decode TTitrace    log_id=1    duration=1
#    CUDU L2 Check DTXNACK Rate    log_id=1    expect_rate=0.05
#
#Check 3T2F UE 3GPP OAI Deactivated And Activated As Expect
#    Send OAI To GNB    ue_id=1    operation=yes    reducedCCsDL=0    reducedCCsUL=1
#    Check Scell ActiveDeactivate Times    1    5    deactivated    2
#    Sleep    10s    reason=wait for traffic stable
#    CUDU L2 Capture And Decode TTitrace    log_id=2    duration=1
#    CUDU L2 Check DTXNACK Rate    log_id=2    expect_rate=0.05
#    Send OAI To GNB    ue_id=1    operation=yes    reducedCCsDL=1    reducedCCsUL=0
#    Check Scell ActiveDeactivate Times    1    2    activated    3
#    CUDU L2 Capture And Decode TTitrace    log_id=3    duration=1
#    CUDU L2 Check DTXNACK Rate    log_id=3    expect_rate=0.05
