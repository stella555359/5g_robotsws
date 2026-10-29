*** Settings ***
Documentation
...  DESCRIPTION:
...                CB013708 Test description
...  AUTHOR:       riyad.ferrag@nokia.com

Resource           resources/robot/CB013708_keywords.robot

Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}
...                automaticTeardown=${False}

Suite Teardown     CB013708 Test Suite Teardown

Test Teardown      CB013708 Test Teardown


*** Variables ***
${Delta_SCF}                    ${CURDIR}/resources/config/Delta_SCF_CB013708.json


*** Test Cases ***
[1][1.0] CB013708_SR_B1_001_Reduced_Periodic_CSI_processing_for_eligible_UEs
    [Tags]    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    [Documentation]      Verify the percentage of periodic CSI reports - including both Channel Quality Indicator (CQI)
    ...                  and beam reports - that are skipped in reception and processing for low-priority UEs when the
    ...                  periodic CSI processing load reduction functionality is active
    [Setup]    Run Keywords
    ...                         Init Trace Color                      AND
    ...                         Create Test Suite Folder              AND
    ...                         Capture Session Initialization

    CB013708 Main Scenario      ${A1}       ${Delta_SCF}
