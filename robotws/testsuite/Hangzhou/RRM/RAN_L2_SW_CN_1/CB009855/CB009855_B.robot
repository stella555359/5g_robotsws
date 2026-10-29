*** Settings ***
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../CUDU_L2/common_multi_UE_resource.robot
Resource          ./Resources/CB009855_resource.robot
Library           ./../CB008236/Resources/CB008236_resource.py

Force Tags        SBTS00    CN1_SG09_SM2    RAN_5G    CRT

*** Variables ***
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${LOCAL_WTS_DIR}       ${CURDIR}/Config/
${SCF_DIR}             ${CURDIR}/Config/
${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
${WTS_CFG_B7a}         wts_cfg_B7a.cfg
${IPHY_B7a}            ${CURDIR}/Config/iphy_B7a.xml
${SCF_B7a}             ${CURDIR}/Config/SCF_B7a.xml
@{SCELL_PHYSICALID_LIST}    ${5CC_SCELL_PHYSICALID_1}    ${5CC_SCELL_PHYSICALID_2}
@{5CC_SCELL_PHYSICALID_1}    51    52    55    56
@{5CC_SCELL_PHYSICALID_2}    51    52    53    55
@{SCELL_PHYSICALID_LIST_CHANGED}    ${5CC_SCELL_PHYSICALID_1_CHANGED}    ${5CC_SCELL_PHYSICALID_2_CHANGED}
@{5CC_SCELL_PHYSICALID_1_CHANGED}    51    54    55    56
@{5CC_SCELL_PHYSICALID_2_CHANGED}    51    52    54    55
@{5CC_UE_LIST}    1    2
@{5CC_PCELL_ID_LIST}    54    54
@{5CC_PCELL_CHANGED_ID_LIST}    52    53
${A1THRESHOLD}    100

*** Test Cases ***
CB009855-B7a_Verify_A2_measurement_triggered_PCell_change_from_TDD_PCell_to_FDD_Scell
    [Documentation]
    ...    CB009855 para:
    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
    ...                 scellAdditionMethod = covBasedA1
    ...                 scellActivationMethod = bufferBased
    ...                 scellDeactivationTimerGNB = ms1280
    ...   Test Steps:
    ...                 Step1. Attach UE1 and UE2 to cell4.
    ...                 Step2. Send A1 report (higher than FDD and TDD threshold) for all UEs.
    ...                 Step3. Start DL and UL traffic.
    ...                 Step4. Send A2 report (lower than cell4's a2MeasPCellSwitchSsbRsrp) for all UEs.
    ...    Check points:
    ...                 1.In Step2, A1 measurement triggers SCell addition, cell1, cell2, cell5 and cell6 are added as SCells for
    ...                 UE1 (UE1 is configured with 3T + 2F CA); cell5, cell1, cell2 and cell3 are added as SCells for
    ...                 UE2 (UE2 is configured with 2T + 3F CA).
    ...                 2. In step4, Handover to original FDD SCell completes successfully (UE1 handovers to cell2;
    ...                 UE2 handovers to cell3) and data transfer resumes successfully in the new PCell after handover.
    ...                 After handover is completed, SCell(s) can be added in new PCell based on UE capability and CA configuration in gNB.
    ...                 3. Counter updated

    [Tags]    case_B501    Manual_Abby Wang    TA_Abby Wang
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B7a}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B7a}    iphy_file=${IPHY_B7a}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    # Step1 & Step2 & Checkpoint1
    SA Multi UE Attach With Scell A1 Addition    ${5CC_UE_LIST}    ${5CC_PCELL_ID_LIST}
    ...    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    5
    # Step3
    SA Multi Continuous UE Start DL And UL Traffic    1    2    700    100
    Wait Untill Scell Activated    4    1
    # Checkpoint3
    wait until keyword succeeds    20min    5min    Check PM Counter Before PCell Change  2
    # Step4
    A2 Triggered Pcell Change    1    6    115    90
    A2 Triggered Pcell Change    2    6    90    115
    # Checkpoint2
    SA Multi UE Scell A1 Addition    ${5CC_UE_LIST}    ${5CC_PCELL_CHANGED_ID_LIST}
    ...    ${SCELL_PHYSICALID_LIST_CHANGED}    ${A1THRESHOLD}    5
    Wait Untill Scell Activated    4    1
    # Checkpoint3
    wait until keyword succeeds    20min    5min    Check PM Counter After PCell Change  2
    SA 5G Detach    ue_id=all

*** Keywords ***
Check PM Counter Before PCell Change
    [Arguments]    ${numofcaues}=1
    ${min}=  evaluate    ${numofcaues}-1
    ${max}=  evaluate    ${numofcaues}*300+1
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C02016    CELLS/NRCELL-4/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-1/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-2/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-3/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-5/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-6/NCAC    ${min}    ${max}

Check PM Counter After PCell Change
    [Arguments]    ${numofcaues}=1
    ${min}=  evaluate    ${numofcaues}-1
    ${max}=  evaluate    ${numofcaues}*300+1
    #Wait Until PM Counter Update    5min
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C02016    CELLS/NRCELL-2/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C02016    CELLS/NRCELL-3/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-1/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-2/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-4/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-5/NCAC    ${min}    ${max}
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55118C07510    CELLS/NRCELL-6/NCAC    ${min}    ${max}
