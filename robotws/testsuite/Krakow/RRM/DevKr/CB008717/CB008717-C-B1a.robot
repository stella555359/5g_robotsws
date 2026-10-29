*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces successful RRC release procedure initiated by AMF. It describes the gNB behavior for the successful
...         transition of UE with established NR-DC connection (with established MN-terminated split bearer) from RRC-CONNECTED to RRC IDLE mode.
...
...      == TEST SET NAME ==
...         CB008717-C-B1a UE Release due to AMF Context Release
...
...      == TESTING SPLIT==
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      == AUTHORS ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...       - CB008717 CFAM
...
...      == HISTORY ==
...         [13.07.2022] - Create Test Suite
...         [28.04.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot
Resource    ./resources/CB008717-verify_ContextRelease.robot
Library     ./resources/message_verifiers.py

Force Tags    CRT    NoResUsage    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/common/2c_TDD_n78_FR2_n257_NRDC.lua
${SCFC}=                   Krakow/CB008717/common/SCFC_FS_n78_n257.xml
${AP_XML}=                 Krakow/CB008717/common/iphy_FS_2c_n78_n257.xml
*** Test Cases ***
CB008717-C-B1a-UE_Release_due_to_AMF_Context_Release
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Test scenario shows successful RRC release procedure initiated by AMF. It describes the gNB behavior for the
    ...  successful transition of UE with established NR-DC connection (with established MN-terminated split bearer)
    ...  from RRC-CONNECTED to RRC IDLE mode.
    ...  == Precondition: ==
    ...  - Same preconditions as in subfeature CB008717-B1
    ...  - The scenario from USCB008717-B#B1a is executed and as a result UE has NR-DC split bearer established
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_15210
    ...  == REQUIRED LOGS ==
    ...  - NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...  Adrianna Zenczak <adrianna.zenczak@nokia.com>
    ...  == REFERENCES ==
    ...  CB008717 CFAM:
    ...  CB008717-C-B1a UE Release due to AMF Context Release
    ...  HISTORY:
    ...  [25.08.2022] - Create Test Case
    ...  [07.10.2022] - Add TC to CRT after EFS review
    ...  [28.04.2023] - Migration to new AP_LO
    ...  [05.10.2023] - PR728511 migrate from PEAK to MAX
    ...  [22.11.2023] - Alignment do CB008490-C changes

    [Tags]  C-B1a

    [Setup]  Prepare test environment B_B1a

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE1 for gNB
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE1 for gNB

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (500, 600) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (500, 600) for NRCELL-1

    Set expected message flows for UE1 Release due to AMF1 Context Release, gNB2
    Trigger UE1 to send deregister request
    Verify expected message flows for UE1 Release due to AMF1 Context Release, gNB2
    Verify in NGAP UEContextReleaseCommand that cause:nas:normal-release is present for AMF1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_CAP is in range (250, 450) for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 2 for NRCELL-1
    #Verify that SUM_UE_NRDC_MN_CU is in range (250, 450) for NRCELL-1

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 0 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 0 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 0 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 0 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 0 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-1
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 1 for NRCELL-1
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-1

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-1

    [Teardown]  Cleanup after test C_B1a
