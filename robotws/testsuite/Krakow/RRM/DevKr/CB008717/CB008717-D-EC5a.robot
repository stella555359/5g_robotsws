*** Settings ***
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
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...               [01.03.2023] - Created TC
...               [25.03.2023] - Review closed
...               [10.05.2023] - Migration to AP_LO

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/7c_TDD_n78_n257_n260_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_EC5b_6PSCells.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_7c_n78_n257_n260.xml

${nrcell2_pci}=  52

*** Test Cases ***
CB008717-D-EC5a_unsuccesfull_PSCell_Addition_due_to_limit_maxNumOfNRDCUsersPerCell_with_online_param_value_change
    [Tags]    D-EC5a-2
    [Documentation]
    ...
    ...  DESCRIPTION: This user scenario describes gNB rejection to configure SCG after PSCell user limits for SN contexts
    ...               are exceeded. First attempt of PSCell addition procedure ends with failure due to
    ...               NRCELL-2/maxNumOfNrDcSnUsers=0 and NRCELL-3/maxNumOfNrDcSnUsers=0 - limits exceeded. Then there is
    ...               online change of NRCELL-3/maxNumOfNrDcSnUsers=1. Second attempt of PSCell addition procedure ends
    ...               with successful NR-DC SCG configuration with NRCELL-3 as PSCell.
    ...
    ...  PRECONDITION: Configuration same as in CB008717-D-B1c scenario with difference in:
    ...                NRCELL-2 and NRCELL-3 in the same NRCELLGRP-2
    ...                MRBTS-1/NRBTS-1/NRCELL-2/maxNumOfNrDcSnUsers is set to 0
    ...                MRBTS-1/NRBTS-1/NRCELL-3/maxNumOfNrDcSnUsers is set to 0
    ...                MRBTS-1/NRBTS-1/NRCELL-4/maxNumOfNrDcSnUsers is set to 0
    ...                MRBTS-1/NRBTS-1/NRCELL-5/maxNumOfNrDcSnUsers is set to 0
    ...                MRBTS-1/NRBTS-1/NRCELL-1/a4PeriodicMeasControlSA/a4Fr2SupervisionTimer is set to 10000
    ...
    ...  POSTCONDITION: NR_DC call established for UE1 on NRCELL-3
    ...
    ...
    ...  TESTING TOOLS:  AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID: gNB classicBTS in SA mode, gNB(ASIB + ABIO + ABIO), UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  REQUIRED LOGS:  NGAP, F1AP, E1AP, RRC
    ...
    ...  CONTACTS:
    ...         Test owner         : Konrad Krzyzak      (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...         ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=1052
    ...      Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...         [01.03.2023] - Created TC
    ...         [25.03.2023] - Review closed
    ...         [10.05.2023] - Migration to AP_LO

    [Setup]  Prepare test environment D-EC5a-2

    Set insufficient UECaps with wrong appliedFreqBandListFilter for UE2

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87

    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify in UECapabilityEnquiry that message includes request for bands:n78,n257,n260 for UE2
    Verify that gNB2 forwards UECapabilities received from UE2 to AMF1

    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-3, band:257 and ssb:2073115 for UE2

    Expect that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE2, gNB2 and AMF1
    UE2 sends A4 measId=1 with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE2, gNB2 and AMF1

    Configure    {'MOC': 'NRCELL', 'ID': '3', 'maxNumOfNrDcSnUsers': '1'}

    Set expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE2, gNB2
    Verify expected messages flows for A4 measurements instalation after A4SupervisionTimer expiry for UE2, gNB2

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE2

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measId=${meas_id} with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1

    Verify that UE2 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UE2 sends measurement results of NRCELL-3 received in NR-DC A4 measurement report

    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-3 for gNB2
    Verify in UECtxSetupReq that ServCellIndex eq 1 for gNB2
    Verify that UE2 was successfully configured NR-DC for NRCELL-3 for gNB2

    [Teardown]  Cleanup after test D-EC5a-2

CB008717-D-EC5a_unsuccesfull_PSCell_Addition_due_to_limit_maxNumOfNRDCNonGBRBearers_with_PDU_session_modification
    [Tags]    D-EC5a-1
    [Documentation]
    ...
    ...  DESCRIPTION: This user scenario describes gNB rejection to configure SCG after PSCell DRB limits for SN contexts
    ...               are exceeded. First attempt of PSCell addition procedure ends with failure due to PDU session with
    ...               3 non-GBR Qos Flows and NRCELL-2/maxNumOfNrDcSnNonGBRBearers=2 and NRCELL-3/maxNumOfNrDcSnNonGBRBearers=2
    ...               - limits exceeded. Then removal of 1 non-GBR Qos Flow is performed. Second attempt of PSCell addition
    ...               procedure ends with successful NR-DC SCG configuration with NRCELL-2 as PSCell, due to PDU session
    ...               with 2 non-GBR Qos Flows and NRCELL-2/maxNumOfNrDcSnNonGBRBearers=2 - limit meets. NRCELL-2 is chosen
    ...               as PSCell as it has better measurement result than NRCELL-3.
    ...
    ...  PRECONDITION: Configuration same as in CB008717-D-B1c scenario with difference in:
    ...                NRCELL-2 and NRCELL-3 in the same NRCELLGRP-2
    ...                MRBTS-1/NRBTS-1/NRCELL-2/maxNumOfNrDcSnNonGBRBearers is set to 2
    ...                MRBTS-1/NRBTS-1/NRCELL-3/maxNumOfNrDcSnNonGBRBearers is set to 2
    ...                MRBTS-1/NRBTS-1/NRCELL-4/maxNumOfNrDcSnNonGBRBearers is set to 2
    ...                MRBTS-1/NRBTS-1/NRCELL-5/maxNumOfNrDcSnNonGBRBearers is set to 2
    ...
    ...                Configure 1 DRB, where:
    ...                MRBTS-1/NRBTS-1/NRDRB-10/nsaDrbParam/ulDataPath is set to ulOverNr
    ...                MRBTS-1/NRBTS-1/NRDRB-10/resType is set to non-GBR_Signaling
    ...                MRBTS-1/NRBTS-1/NRDRB-10/nsaDrbParam/dlDataSplitMode is set to dlOverF1UX2U
    ...                MRBTS-1/NRBTS-1/NRDRB_5QI-1/fiveqiValueList is set to value '5'
    ...
    ...                Configure 3 DRBs, where x={11, 13, 14}:
    ...                MRBTS-1/NRBTS-1/NRDRB-x/nsaDrbParam/ulDataPath is set to ulOverNr
    ...                MRBTS-1/NRBTS-1/NRDRB-x/resType is set to non-GBR
    ...                MRBTS-1/NRBTS-1/NRDRB-x/nsaDrbParam/dlDataSplitMode is set to dlOverF1UX2U
    ...                MRBTS-1/NRBTS-1/NRDRB_5QI/fiveqiValueList is set to value in the range of = [6...9] or [128...254]
    ...
    ...  POSTCONDITION: NR_DC call established for UE1 on NRCELL-2
    ...
    ...
    ...  TESTING TOOLS:  AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID: gNB classicBTS in SA mode, gNB(ASIB + ABIO + ABIO), UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  REQUIRED LOGS:  NGAP, F1AP, E1AP, RRC
    ...
    ...  CONTACTS:
    ...         Test owner         : Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
    ...         ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link:              https://gates.nsn-net.net/view/00025f8e#o=1052
    ...      Sub-feature refinement: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...         [01.03.2023] - Created TC
    ...         [25.03.2023] - Review closed

    [Setup]  Prepare test environment D-EC5a-1

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell1
    Set PDU session with 2 additional non-GBR QoS Flow for UE1

    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1

    Expect that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE1, gNB2 and AMF1
    UE1 sends A4 measId=1 with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify that NR-DC procedure fails due to maxNumOfNrDcSnNonGBRBearersCGRP exceeded on PSCell for UE1, gNB2 and AMF1

    Add to UE1 PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [9]

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-2 for UE1
    Set Test Variable  ${meas_id}
    Sleep  2s

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measId=${meas_id} with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1

    Verify that UE1 sends measurement results of NRCELL-2 received in NR-DC A4 measurement report
    Verify that UE1 sends measurement results of NRCELL-3 received in NR-DC A4 measurement report

    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for gNB2
    Verify in UECtxSetupReq that ServCellIndex eq 1 for gNB2
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2

    #Wait for new PM Counter collecting period
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 1 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-1
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 1 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 1 for NRCELL-1
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-1
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-1
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-1
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-1
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-1

    [Teardown]  Cleanup after test D-EC5a-1
