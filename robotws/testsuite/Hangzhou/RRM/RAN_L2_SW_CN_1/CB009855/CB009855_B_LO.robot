*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown 2
#Test Teardown     Common Test Teardown 2
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_log_capture.robot
#Resource          ./../CUDU_L2/common_multi_UE_resource.robot
#Resource          ./Resources/CB009855_resource.robot
#Resource          ../CB008532/keywords_CB008532_common_AP.robot
#
#Force Tags        SBTS00    CN1_SG09_SM2    RAN_5G    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/
#${SCF_DIR}             ${CURDIR}/Config/
#${RD}                  0x4B000F=1;0x58012d=4
#${WTS_CFG_B6a_05}         wts_cfg_B6a_05.cfg
#${IPHY_B6a_05}            ${CURDIR}/Config/iphy_B6a_05.xml
#${SCF_B6a_05}             ${CURDIR}/Config/SCF_B6a_05.xml
#@{SCELL_PHYSICALID_LIST_B6A_05}    50    51    52    54
#${CC_NUMS_5}    5
#${RD_B}                  0x4B000F=1;0x58012d=4
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-B6a-05_Verify_Optimized_PUCCH_resource_allocation_for_2T3F_DL_CA_TDD_as_Pcell
#    [Documentation]
#    ...    CB009855 para:
#    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
#    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
#    ...                 scellAdditionMethod = blind
#    ...                 scellActivationMethod = blind
#    ...                 scellDeactivationTimerGNB = infinity
#    ...    Test Steps:
#    ...                 Step1. Attach UE to Cell1 and trigger blind SCell Addition for the UE.
#    ...                 Step2. Start DL and UL traffic.
#    ...    Check points:
#    ...                 1. In step1,2T+3F 5CC DL and T+F 2CC UL CA is configured for UE.
#    ...                     4 Scell’s PUCCH resources are successfully assigned.
#    ...                 2. Traffic are ok, no dtx.
#    [Tags]    case_B6a_05    Manual_Mike Ma    TA_Susie Hou
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B6a_05}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B6a_05}    iphy_file=${IPHY_B6a_05}    swconfig_param=${RD_B}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    # Step 1
#    SA 5G CA Attach    ${ue_id}
#    # Checkpoint 1
#    sleep    10s
#	ute_wtssim.Execute Egate Command    sim_log_set flush
#    Check Scell Activated    4    1
#    Check Num Of CSIRS    5    2    53    52
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_PHYSICALID_LIST_B6A_05}    ${CC_NUMS_5}
#    # Step 2
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    700
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    100
#    Sleep    10s    reason=wait for traffic statble
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check CsiPart1 Bits    53    19
#    Check CsiPart1 Bits    52    18
#    # Checkpoint 2
#    Wait Until Keyword Succeeds    2min    20s    Check CA Cell Sum Average Throughput    ${UE_ID}    dl    550    5
#    Wait Until Keyword Succeeds    2min    20s    Check CA Cell Sum Average Throughput    ${UE_ID}    ul    53    2
#    CUDU_L2 Check DTXNACK Rate    1
#    CUDU_L2 Check UL DTXCRC Rate    1
#
#*** Keywords ***
#Check CsiPart1 Bits
#    [Arguments]    ${cell_id}    ${csipart1_bits}=19    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace/1    ${csv_file}=output_ul.csv
#    Set Test Variable    ${test_cell_id}    ${cell_id}
#    Set Test Variable    ${test_csi_part1_bits}    ${csipart1_bits}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB009855_B/CB009855_CsiPart1.ini    ${csv_file}    ${log_dir}
