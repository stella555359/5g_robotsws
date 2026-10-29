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
...         [07.11.2022] - Create Test Suite
...         [06.12.2022] - Complete Test Suite

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-D-B4a_B4b_B4c_PSCell_Addition_with_different_ulDataPath
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info=
    ...     This user scenario describes successful establishment of MN terminated split bearer with Operator defined Radio Admission Control
    ...     and setting of UL-data path.
    ...     UE1, UE2 are configured with SCG after reception of NR-DC A4 MeasurementReport with UL data path
    ...     set to MCG/SCG legs.
    ...     UE4 and UE5 are configured with SCG after reception of NR-DC A4 MeasurementReport with no UL data path
    ...     set to MCG/SCG due to lack of UEs capabilities for splitting DRBs.
    ...     Testcase covers scenario D-B1a, D-B1b, D-B1c.
    ...  == Precondition: ==
    ...     NRBTS/NRDRB-13/nsaDrbParam/ulDataPath is set to ulOverNr
    ...     NRBTS/NRDRB-13/nsaDrbParam/dlDataSplitMode is set to dlOverF1U
    ...     NRBTS/NRDRB-13/resType is set to nonGBR
    ...     NRBTS/NRDRB-14/nsaDrbParam/ulDataPath is set to ulOverNr
    ...     NRBTS/NRDRB-14/nsaDrbParam/dlDataSplitMode is set to dlOverF1U
    ...     NRBTS/NRDRB-14/resType is set to nonGBR
    ...     UE-NR-Capability same as in CB008717-D-B1c, UE is split capable
    ...
    ...     Reconfigured during test to:
    ...     NRBTS/NRDRB-13/nsaDrbParam/ulDataPath is set to ulOverLteNr_PrimaryPathOverLte
    ...     NRBTS/NRDRB-13/nsaDrbParam/ulDataSplitThreshold is set to 11 (b102400)
    ...     NRBTS/NRDRB-13/nsaDrbParam/dlDataSplitMode is set to dlOverF1UX2U
    ...     NRBTS/NRDRB-14/nsaDrbParam/ulDataPath is set to ulOverNr
    ...     NRBTS/NRDRB-14/nsaDrbParam/dlDataSplitMode is set to dlOverF1U
    ...
    ...     Reconfigured during test to:
    ...     NRBTS/NRDRB-13/nsaDrbParam/ulDataPath is set to ulOverLteNr_PrimaryPathOverNr
    ...     NRBTS/NRDRB-13/nsaDrbParam/ulDataPathForUlSplitNotCapableUe is set to ulPrimaryPathOverLte
    ...     NRBTS/NRDRB-13/nsaDrbParam/dlDataSplitMode is set to dlOverX2U
    ...     NRBTS/NRDRB-14/nsaDrbParam/ulDataPath is set to ulOverLteNr_PrimaryPathOverLte
    ...     NRBTS/NRDRB-14/nsaDrbParam/ulDataSplitThreshold is set to 11 (b102400)
    ...     NRBTS/NRDRB-14/nsaDrbParam/ulDataPathForUlSplitNotCapableUe is set to ulPrimaryPathOverNr
    ...     NRBTS/NRCELL-1/enforcePrimaryPathOverLte is set to 1
    ...     UE4 and UE5 with UE-NR-Capability/nrdc-Parameters/generalParametersNRDC/splitDRB-withUL-Both-MCG-SCG is absent
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_15959
    ...  == REQUIRED LOGS ==
    ...  NGAP, RRC, F1AP, E1AP
    ...  == CONTACTS ==
    ...  Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...  HISTORY:
    ...  [05.01.2023] - Create Test Case
    ...  [07.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=869207)
    ...  [08.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=869788)
    ...  [07.12.2022] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=869788)
    ...  [12.07.2023] - Changes related to -T SI implemented

    [Tags]   D-B4abc

    [Setup]  Prepare test environment D-B4a_B4b_B4c

    Attach UE1 without ICS to gNB2 cell2
    Set one PDU session with 2 non-GBR QoS Flow for UE1
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify that AMF1 NGAP InitialContextSetup contains 2 non-GBR QoS Flows
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify in 1 out of 2 that BearerContextModificationRequest UL-Config: 'only', cellGroupID: 1, dL-TXStop: 'stop' for gNB2
    Verify in UECtxSetupReq that uLUEConfiguration eq 'only' for gNB2
    Verify in UECtxSetupResp that CellGroupID eq 1 for gNB2
    Verify in RRCReconfiguration for UE1 that cellGroup eq 1 and ul-DataSplitTreshold eq 'inf'
    Verify that UE1 was successfully configured NR-DC for gNB2

    Reset QoS Flow settings on SMF
    Configure    ${yaml_D_B4b}

    Attach UE2 without ICS to gNB2 cell2
    Set one PDU session with 2 non-GBR QoS Flow for UE2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify 1 out of 2 BearerCtxModReq for ulDataPath set to ulOverLteNrPrimaryPathOverLte for gNB2 for SN context
    Verify UECtxSetupReq for ulDataPath set to ulOverLteNrPrimaryPathOverLte for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 3, SelectedFeatureSetEntryIndex eq 2 for gNB2
    Verify RRCReconfiguration for ulDataPath set to ulOverLteNrPrimaryPathOverLte for UE2
    Verify that UE2 was successfully configured NR-DC for gNB2

    Reset QoS Flow settings on SMF
    Configure    ${yaml_D_B4c_UE4}

    Attach UE4 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    UE4 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    Verify 1 out of 2 BearerCtxModReq ulDataPath: ulOverLteNrPrimaryPathOverNr, UL-Config: 'no-data' for gNB2 for SN context
    Verify UECtxSetupReq for ulDataPath: ulOverLteNrPrimaryPathOverNr, uLUEConfiguration: 'no-data' for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 3, SelectedFeatureSetEntryIndex eq 2 for gNB2
    Verify in RRCReconfiguration for UE4 that cellGroup eq 0 and ul-DataSplitTreshold eq 'inf'
    Verify that UE4 was successfully configured NR-DC for NRCELL-2 for gNB2

    Configure    ${yaml_D_B4c_UE5}

    Attach UE5 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Set expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    Verify 1 out of 2 BearerCtxModReq ulDataPath: ulOverLteNrPrimaryPathOverNr, UL-Config: 'only' for gNB2 for SN context
    Verify UECtxSetupReq for ulDataPath: ulOverLteNrPrimaryPathOverNr, uLUEConfiguration: 'only' for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 3, SelectedFeatureSetEntryIndex eq 2 for gNB2
    Verify in RRCReconfiguration for UE5 that cellGroup eq 1 and ul-DataSplitTreshold eq 'inf'
    Verify that UE5 was successfully configured NR-DC for gNB2

    [Teardown]  Cleanup after test D-B4a_B4b_B4c
