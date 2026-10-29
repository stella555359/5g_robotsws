*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces the procedure of NR-DC PSCell addition, triggered by A4 MeasurementReport event, sent by UE with one
...         or more NR-DC PSCell candidates. After the successful procedure appropriate NR-DC PSCell is setup at UE and all NR-DC A4 measurements
...         are deactivated at UE.
...
...      == TEST SET NAME ==
...         CB008717-I Successful Measurement based PSCell Addition
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
...       - Mateusz Matusik <matusik.mateusz@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...       - CB008717 CFAM
...
...      == HISTORY ==
...         [20.01.2023] - Create Test Suite

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-D-B5a_no_NRDC_A4_activation_for_UEs_with_non_eligible_PDU_session
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This user scenario describes the case where PSCell addition is not triggered due to absence of PDU Session in ICS.
    ...  NR-DC A4 Measurements are not configured for PSCells frequencies due to lack of eligible PDU Session.
    ...  In ICS, there are 3 cases:
    ...     - PDU Session with 1 non-GBR signaling QoS Flow and sufficient NR-DC UE-NR-Capabilities are included in ICS,
    ...     - PDU Session with 1 GBR and 1 non-GBR QoS Flow and insufficient for NR-DC UE-NR-Capabilities are included in ICS,
    ...     - no PDU session and UE Radio Capabilities are not included in ICS.
    ...  == Precondition: ==
    ...     Same preconditions as in CB008717-D-B1c scenario,
    ...         - UE1-NR-Capability same as in CB008717-D-B1c,
    ...         - UE2-NR-Capability same as in CB008717-D-B1c scenario with below additions,
    ...         - includeNR-DC - NOT present,
    ...         - UE3-NR-Capability same as in CB008717-D-B3a
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_RRM_15972
    ...  == REQUIRED LOGS ==
    ...     NGAP, RRC, F1AP, E1AP
    ...  == CONTACTS ==
    ...     Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...     https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...  HISTORY:
    ...     [20.01.2023] - Create Test Case
    ...     [25.05.2023] - Test Case added to CRT after review

    [Tags]  D-B5a

    [Setup]  Prepare test environment D-B5a

    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR signalling QoS Flow
    Expect that A4 measurements are not configured for UE1 with sufficient UECaps, gNB2 and AMF1
    Set ${sufficient_n66_n260_n261} UECaps for UE1
    Trigger UE1 idle mode exit
    Verify that A4 measurements are not configured for UE1 with sufficient UECaps, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions


    Prepare NrDc UE2 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Expect that A4 measurements are not configured for UE2 with insufficient UECaps, gNB2 and AMF1
    Set ${insufficient_n66_n260_n261_no_includeNRDC} UECaps for UE2
    Trigger UE2 idle mode exit
    Verify that A4 measurements are not configured for UE2 with insufficient UECaps, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify that gNB2 forwards UECapabilities received from UE2 to AMF1


    Expect that A4 measurements are not configured for UE4 with ICS without PDU session for gNB2 and AMF1
    Attach UE4 to gNB2 cell2 with ICS without PDU session
    Verify that A4 measurements are not configured for UE4 with ICS without PDU session for gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE4

    [Teardown]  Cleanup after test D-B5a
