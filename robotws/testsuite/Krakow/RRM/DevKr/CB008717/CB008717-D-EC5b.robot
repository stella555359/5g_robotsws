*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...
...      INTRODUCTION:  This subfeature introduces successful establishment of MN terminated split bearer - additional
...                     content.One NR-DC-SN cell, that can act as PSCell in NR-DC, is successfully activated. After
...                     Initial Context Setup, NR DC establishment is attempted for NR DC eligible UEs, MN terminated
...                     Split Bearer Addition procedure is successfully completed and bearer type is successfully
...                     changed from MCG to MN terminated split bearer.
...
...      TEST SET NAME:  CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers,
...                      additional content
...
...      TESTING SCOPE:
...                      CB008717-A NR-DC Cell Activation for a Secondary Node
...                      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...                      CB008717-C UE Context Release Release due to AMF4 measurements
...                      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers,
...                                 additional content
...                      CB008717-E UE Release without bearer takeback
...                      CB008717-G Cell Management for Secondary Node
...                      CB008717-H Configuration and Reception of A
...                      CB008717-I Successful Measurement based PSCell Addition
...                      CB008717-J Interaction with event A4
...                      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...                      CFAM Leader:         Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                                           Jedrzej Jarecki       (Nokia - PL/Krakow) <jedrzej.jarecki@nokia.com>
...                      ET owner (LPO/APO):  Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...                      Entity Testing L3:   Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
...                                           I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...                      CFAM link:        https://gates.nsn-net.net/view/00025f8e#o=731
...                      FTS link:         https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization
...                                        %20WoW/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%
...                                        2Dproductization%2FRAN%20Productization%20WoW%2FShared%20Documents%2F6%2E%20F
...                                        eature%20Documents%2FCB008600%2DCB008799%2FCB008717
...                      L3 ET Test Plan:  https://confluence.ext.net.nokia.com/display/M5FC/CB008717-I+Sub+feature+refi
...                                        nement?src=contextnavpagetreemode
...
...       HISTORY:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...               [01.03.2023] - Created TC
...               [01.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com)

Resource    ./resources/CB008717-common_keywords.robot

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/7c_TDD_n78_n257_n260_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_EC5b_6PSCells.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_7c_n78_n257_n260.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-EC5b_unsuccesfull_PSCell_Addition_due_to_limits_on_CellGroups_with_UE_releases
    [Tags]    D-EC5b
    [Documentation]
    ...
    ...  DESCRIPTION: This user scenario describes that gNB monitors number of NRDC users per each cell group
    ...               maxNumOfNrDcSnUsersCGRP and number of split DRBs per cell group maxNumOfNrDcSnNonGBRBearersCGRP.
    ...               Validation for correct updates of available resources when UEs with NRDC mode are detached from
    ...               gNB.
    ...
    ...  PRECONDITION: Configuration same as in CB008717-D-B1c scenario with difference in:
    ...                NRCELL-2 and NRCELL-3 in the same NRCELLGRP-2
    ...                NRBTS/NRCELL-2/maxNumOfNrDcSnUsers is set to 3
    ...                NRBTS/NRCELL-2/maxNumOfNrDcSnNonGBRBearers is set to 5
    ...                NRBTS/NRCELL-3/maxNumOfNrDcSnUsers is set to 3
    ...                NRBTS/NRCELL-3/maxNumOfNrDcSnNonGBRBearers is set to 5
    ...                NRBTS/NRCELLGRP-2/maxNumOfNrDcSnUsersCGRP is set to 5
    ...                NRBTS/NRCELLGRP-2/maxNumOfNrDcSnNonGBRBearersCGRP is set to 3
    ...
    ...                NRCELL-6 and NRCELL-7 in the same NRCELLGRP-3
    ...                NRBTS/NRCELL-6/maxNumOfNrDcSnUsers is set to 3
    ...                NRBTS/NRCELL-6/maxNumOfNrDcSnNonGBRBearers is set to 5
    ...                NRBTS/NRCELL-7/maxNumOfNrDcSnUsers is set to 3
    ...                NRBTS/NRCELL-7/maxNumOfNrDcSnNonGBRBearers is set to 5
    ...                NRBTS/NRCELLGRP-3/maxNumOfNrDcSnUsersCGRP is set to 2
    ...                NRBTS/NRCELLGRP-3/maxNumOfNrDcSnNonGBRBearersCGRP is set to 5
    ...                NRBTS/NRCELL-2 has better measurement result than NRBTS/NRCELL-3
    ...                NRBTS/NRCELL-6 has better measurement result than NRBTS/NRCELL-7
    ...
    ...  POSTCONDITION: NR_DC call established for UE1 on NRCELL-2
    ...                 NR_DC call established for UE2 on NRCELL-6
    ...                 NR_DC call established for UE3 on NRCELL-7
    ...                 NR_DC call doesn't established for UE4
    ...
    ...  TESTING TOOLS:  AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID: gNB classicBTS in SA mode, gNB(ASIB + ABIO + ABIO), UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  REQUIRED LOGS:  NGAP, F1AP, E1AP, RRC
    ...
    ...  CONTACTS:
    ...         Test owner         : Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...         ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=1052
    ...      Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...        <link_to_testsuite>
    ...         [01.03.2023] - Created TC
    ...         [02.06.2023] - Test Case added to CRT after review

    [Setup]  Prepare test environment D-EC5b

    Attach UE1 without ICS to gNB2 cell1
    Set one PDU session with 2 non-GBR QoS Flow for UE1
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:260 and ssb:2254267 for UE1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measId=1 with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UE1 sends measurement results of NRCELL-3 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains physCellIds eq ${nrcell2_pci} and ${nrcell3_pci} for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 1, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2
    Reset QoS Flow settings on SMF

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:260 and ssb:2254267 for UE2
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measId=2 with CELL-6: rsrp1=100 rsrq1=40 and CELL-7: rsrp2=85 rsrq2=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 sends measurement results of NRCELL-6 received in NR-DC A4 measurement report
    Verify that UE2 sends measurement results of NRCELL-7 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains physCellIds eq ${nrcell6_pci} and ${nrcell7_pci} for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 2, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE2 was successfully configured NR-DC for NRCELL-6 for gNB2

    Attach UE3 without ICS to gNB2 cell1
    Set one PDU session with 2 non-GBR QoS Flow for UE3
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE3
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:260 and ssb:2254267 for UE3
    Expect that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE3, gNB2 and AMF1
    UE3 sends A4 measId=1 with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE3, gNB2 and AMF1
    Reset QoS Flow settings on SMF

    Trigger UE3 to send deregister request

    Attach UE3 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE3
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:260 and ssb:2254267 for UE3
    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measId=2 with CELL-6: rsrp1=85 rsrq1=31 and CELL-7: rsrp2=100 rsrq2=40
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 sends measurement results of NRCELL-6 received in NR-DC A4 measurement report
    Verify that UE3 sends measurement results of NRCELL-7 received in NR-DC A4 measurement report
    Verify that UEContextSetupRequest contains physCellIds eq ${nrcell6_pci} and ${nrcell7_pci} for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 2, SelectedFeatureSetEntryIndex eq 1 for gNB2
    Verify that UE3 was successfully configured NR-DC for NRCELL-7 for gNB2

    Attach UE4 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
#    Add to UE4 initial PDU session with ICS
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE4
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:260 and ssb:2254267 for UE4
    Expect that NR-DC procedure fails due to maxNumOfNrDcSnUsersCGRP exceeded on PSCell for UE4, gNB2 and AMF1
    UE4 sends A4 measId=2 with CELL-6: rsrp1=100 rsrq1=40 and CELL-7: rsrp2=85 rsrq2=31
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnUsersCGRP exceeded on PSCell for UE4, gNB2 and AMF1

    [Teardown]  Cleanup after test D-EC5b
