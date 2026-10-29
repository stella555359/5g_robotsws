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
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_E_B1a_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-D-EC6a_unsuccesfull_PSCell_Addition_due_to_limits_on_gNB_DU_maxNumOfRrcConnUEsPerDU
    [Tags]    D-EC6a
    [Documentation]
    ...
    ...  DESCRIPTION: This test scenario describes establishment of MN terminated split bearer for UE while UE-NR-Capability
    ...               have multiple matching band combination and considers multiple PSCells candidates. BandCombinationIndex:3
    ...               and FeatureSetEntryIndex: 2 should be chosen as result of MaxDataRate algorithm. Test case checks proper
    ...               handling for multiple entries in FeatureSetEntryIndexes IE. UE Capabilities included by AMF in ICS procedure.
    ...               This user scenario describes that gNB monitors number of connected UEs per DU. NRDC users should be
    ...               counted and if limit of maxNumOfRrcConUEsPerDU is exceeded, PSCell Addition will fail. gNB-DU-SN
    ...               responds with F1AP_UEContextSetupFailure.
    ...               Testcase covers scenario D-B1c.
    ...
    ...  PRECONDITION: Configuration same as in CB008717-D-B1c scenario with difference in:
    ...                MRBTS-1/NRBTS-1/NRDU-1/maxNumOfRrcConUEsPerDU is set to 2
    ...
    ...  POSTCONDITION: NR_DC call established for UE1 on NRCELL-2
    ...                 NR_DC call established for UE2 on NRCELL-2
    ...                 NR_DC call established for UE3 on NRCELL-3
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
    ...         [04.08.2023] - -DE item, counter verification

    [Setup]  Prepare test environment D-EC6a

    #Wait for new PM Counter collecting period

    Prepare Pmi Tickets Config
    Start Collecting Pmi Tickets

    Set ${sufficient_n66_n260_n261} UECaps for UE1
    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for NRDC A4 measurements for UE1 with sufficient UECaps and gNB2
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for NRDC A4 measurements for UE1 with sufficient UECaps and gNB2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE1

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes bandCombinationIndex eq 2 and 3 for gNB2
    Verify in UEContextSetupRequest that allowedBC_ListMRDC includes allowedFeatureSetsList with 2 items for gNB2
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 3, SelectedFeatureSetEntryIndex eq 2 for gNB2
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2
    Exclude UECaps from ICS for UE1 and include indexToRFSP eq 87


    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Exclude UECaps from ICS for UE2 and include indexToRFSP eq 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE2

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2


    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE3
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE3

    Expect that PSCell Addition fails due to maxNumOfRrcConUEsPerDU exceeded for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=2 for NR-DC PSCell addition with phycell_id=53 nrsrp_nr=86 nrsrq_nr=31
    Verify that PSCell Addition fails due to maxNumOfRrcConUEsPerDU exceeded for UE3, gNB2 and AMF1

    Verify in UEContextSetupFailure that cause 'no-radio-resources-available' is present for gNB2

    Set shortened expected message flows for UE1 Release due to AMF1 Context Release, gNB2
    Trigger UE1 to send deregister request
    Verify shortened expected message flows for UE1 Release due to AMF1 Context Release, gNB2

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE3
    Set Test Variable  ${meas_id}

    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=53 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 was successfully configured NR-DC for NRCELL-3 for gNB2

    Stop Collecting Pmi Tickets
    Verify Pmi Counters in Records   3612082192 eq 4    #    NRDC_IA_MN_CU_ADD_REQ
    Verify Pmi Counters in Records   3612082193 eq 3    #    NRDC_IA_MN_CU_ADD_RESP
    Verify Pmi Counters in Records   3612606484 eq 3    #    IA_NRDC_MN_CU_DRB_STP_ATT
    Verify Pmi Counters in Records   3612606485 eq 3    #    IA_NRDC_MN_CU_DRB_STP_SUC
    Verify Pmi Counters in Records   3612082196 eq 3    #    NRDC_IA_MN_CU_ADD_RCF_CMPL
    Verify Pmi Counters in Records   3612082194 eq 1    #    NRDC_IA_MN_CU_ADD_REJ
    Verify Pmi Counters in Records   3612082195 eq 0    #    NRDC_IA_MN_CU_ADD_TEXP
    Verify Pmi Counters in Records   3612672029 eq 1    #    NG_FLOW_REL_NOR_NRDC
    Verify Pmi Counters in Records   3612672030 eq 0    #    NG_FLOW_REL_ABN_NRDC


    #Wait for new PM Counter collecting period
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 4 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 3 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 3 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 3 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 3 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 1 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2
    #Verify that MAX_UE_NRDC_CAP is equal to 3 for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 2 for NRCELL-2

    [Teardown]  Cleanup after test D-EC6a
