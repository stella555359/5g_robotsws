*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces successful establishment of MN terminated split bearer - additional content.
...         One NR-DC-SN cell, that can act as PSCell in NR-DC, is successfully activated. After Initial Context Setup,
...         NR DC establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is
...         successfully completed and bearer type is successfully changed from MCG to MN terminated split bearer.
...
...      == TEST SET NAME ==
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
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
...         [21.11.2022] - Create Test Suite

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/2c_FS_TDD_n41_FR2_n258_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B3a_BF.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_2c_n41_n258.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-B3a_PSCell_Addition_with_Beam_refinement_enabled_TDD
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test scenario describes establishment of MN terminated split bearer for 2 UEs while and during SCG setup,
    ...     after reception of NR-DC A4 MeasurementReport:
    ...         UE1 with beam management capability in FR1 and FR2 eq maxNumberSSB-CSI-RS-ResourceOneTx=n8 is re-configured,
    ...         UE2 with beam management capability in FR1 eq maxNumberSSB-CSI-RS-ResourceOneTx=n8 and in FR2 eq n16 is not re-configured.
    ...  == Precondition: ==
    ...     - NRCELL-1/actBeamforming = true
    ...     - NRCELL-1/beamSet.nrBtsBeamRefinementP2 = true
    ...     - NRCELLGRP-1.numberOfTransmittedSsBlocks = 1
    ...     - NRCELL-2/actBeamforming = true
    ...     - NRCELL-2/beamSet.nrBtsBeamRefinementP2 = false
    ...     - NRCELLGRP-2.numberOfTransmittedSsBlocks = 32
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_RRM_15667
    ...  == REQUIRED LOGS ==
    ...     NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...     Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...     https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...  HISTORY:
    ...     [23.12.2022] - Create Test Case
    ...     [25.05.2023] - Test Case added to CRT after review

    [Tags]   D_B3a

    [Setup]  Prepare test environment D-B3a

    Attach UE5 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
#    Add to UE5 initial PDU session with ICS
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 1, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify in UEContextSetupResponse that csi-ResourceConfigId: 10, SSB-Index: 0 for gNB2
    Verify in RRCReconfiguration that Beam refinement configuration is not removed towards the UE5
    Verify that UE5 was successfully configured NR-DC for gNB2

    Sleep    5

    Attach UE4 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
#    Add to UE4 initial PDU session with ICS
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    UE4 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 1, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify in UEContextSetupResponse that csi-ResourceConfigId: 10, SSB-Index: 0 for gNB2
    Verify in RRCReconfiguration that Beam refinement configuration is removed towards the UE4
    Verify that UE4 was successfully configured NR-DC for gNB2

    [Teardown]  Cleanup after test D-B3a
