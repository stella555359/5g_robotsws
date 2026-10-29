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

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/2c_FDD_n66_FR2_n258_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1a_FDD_n66_n258.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_2c_n66_n258.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-B1a_PSCell_Addition_with_multiple_applicable_band_combination_FDD
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test scenario describes establishment of MN terminated split bearer for 3 UEs while UE-NR-Capability
    ...     have multiple matching band combination. For each UE, {DC_n66A-n258G} with corresponding BandCombinationIndex: 2
    ...     should be chosen, but due to different featureSet settings:
    ...         UE1 - featureSetDownlinkPerCC-3 has more MIMO Layers than featureSetDownlinkPerCC-2,
    ...         UE2 - featureSetDownlinkPerCC-3 has higher QAM value than featureSetDownlinkPerCC-2,
    ...         UE3 - featureSetDownlinkPerCC-3 has greater scalingFactor than featureSetDownlinkPerCC-2.
    ...     For each UE, in InitialContextSetup, there is one PDU Session with one non-GBR QoS.
    ...     MN terminated Split Bearer Addition procedure is successfully completed, successful bearer type is changed from MCG
    ...     to MN terminated split bearer and gNB selects the optimal band combination based on maximum data rate.
    ...
    ...  == Precondition: ==
    ...     - NRBTS/NRCELL-1 belongs to NRCELLGRP-0 where NRCELLGRP-0.scs is set to 15kHz
    ...     - NRBTS/NRCELL-1 simulated on AEQA radio module - NR_BAND: n66
    ...     - NRBTS/NRCELL-1 channel bandwidth: 20 MHz
    ...
    ...     - NRBTS/NRCELL-2 belongs to NRCELLGRP-1 where NRCELLGRP-1.scs is set to 120kHz
    ...     - NRBTS/NRCELL-2 simulated on AEUD radio module - NR_BAND: n258
    ...     - NRBTS/NRCELL-2 channel bandwidth: 100MHz
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...  == REQUIREMENTS COVERAGE ==
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...     Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...
    ...  HISTORY:
    ...     [21.11.2022] - Create Test Case
    ...     [28.05.2023] - Test Case added to CRT after review

    [Tags]   D_B1a

    [Setup]  Prepare test environment D-B1a

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:258 and ssb:2043739 for UE1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-1 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes bandCombinationIndex eq 1 and 2 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes allowedFeatureSetsList with 1 items for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 2, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE1 was successfully configured NR-DC for gNB2


    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:258 and ssb:2043739 for UE2
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-1 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes bandCombinationIndex eq 1 and 2 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes allowedFeatureSetsList with 1 items for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 2, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE2 was successfully configured NR-DC for gNB2


    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:258 and ssb:2043739 for UE3
    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-1 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes bandCombinationIndex eq 1 and 2 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes allowedFeatureSetsList with 1 items for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 2, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE3 was successfully configured NR-DC for gNB2

    [Teardown]  Cleanup after test D-B1a
