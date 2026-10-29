*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...
...      INTRODUCTION:
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
...      TEST SET NAME:  CB008717-E
...
...      TESTING SCOPE:
...      CB008717-E UE Release without bearer takeback
...
...      CONTACTS:
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                           Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
...                     FTS link:              http://nok.it/CB008083_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
...
...               [07.03.2023] - Created TC
...               [17.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=878951)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-B9a_NRDC_UE_release_due_to_NG_Full_Reset_AMF_initated
    [Tags]    E-B9a
    [Documentation]
    ...
    ...  DESCRIPTION: Scenario describes the gNB behavior for the successful transition of UE with established NR-DC connection to RRC IDLE
    ...  due to NG Full Reset initiated by AMF - reset of all UEs is triggered. Number of F1AP/E1AP Resets depends on number of CP-UE.
    ...  Each ABIO contains 2 instances of CP-UE. In this testcase there is 1 SA and 2 NRDC users.
    ...
    ...  PRECONDITION:
    ...  Same preconditions as in CB008717-D-B1c with addition to:
    ...     - NRBTS/actNgcFlexSaMode is set to false
    ...
    ...  POSTCONDITION:
    ...     - UE1, UE2, UE3 are successfully transmitted from RRC-CONNECTED to RRC-IDLE state
    ...     - Signaling connections for the UE1, UE2, UE3 in Uu and NG interface are removed
    ...     - Internal resources allocated in: gNB-CU-CP, gNB-CU-UP, gNB-DU are released successfully
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15323; 5G_RAN_USR_RRM_16137
    ...       *BACKLOG ID: FCA_5G_L2L3-98480
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk    (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008083_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
    ...
    ...        [07.03.2023] - Created TC
    ...        [17.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=878951)

    [Setup]  Prepare test environment E-B9a

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE1
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE1 for gNB
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE1 for gNB

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE2
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE2 for gNB
    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE2 for gNB

    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE3
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE3
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE3 for gNB

    Set expected messages flow for AMF Initiated Full Reset for AMF1 and gNB2
    Trigger AMF Initiated Full Reset
    Verify expected messages flow for AMF Initiated Full Reset for AMF1 and gNB2
    Verify in NGAP:Reset that ResetType eq 'partOfNG-Interface':'reset-all'
    Verify in NGAP Reset that cause:misc:unspecified is present for gNB
    Verify in all F1AP Reset that cause:transport:unspecified is present for gNB

    # CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 2 for NRCELL-2
    #Verify that NG_FLOW_REL_NRDC_RRC_RCFG is equal to 0 for NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2

    #Wait for new PM Counter collecting period
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NRDC_RRC_RCFG is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2

    [Teardown]  Cleanup after test E-B9a

CB008717-E-B9c_NRDC_UE_release_due_to_NG_Partial_Reset_AMF_initiated
    [Tags]    E-B9c
    [Documentation]
    ...
    ...  DESCRIPTION: Scenario describes the gNB behavior for the successful transition of UE with established NR-DC connection to RRC IDLE
    ...  due to NG Partial Reset initiated by AMF - reset of only one UE is triggered. Number of F1AP/E1AP Resets depends on number of CP-UE.
    ...  Each ABIO contains 2 instances of CP-UE. In this testcase there is 1 SA and 2 NRDC users.
    ...
    ...  PRECONDITION:
    ...  Same preconditions as in CB008717-D-B1c
    ...
    ...  POSTCONDITION:
    ...     - UE1, UE2, UE3 are successfully transmitted from RRC-CONNECTED to RRC-IDLE state
    ...     - Signaling connections for the UE1, UE2, UE3 in Uu and NG interface are removed
    ...     - Internal resources allocated in: gNB-CU-CP, gNB-CU-UP, gNB-DU are released successfully
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15323; 5G_RAN_USR_RRM_16137
    ...       *BACKLOG ID: FCA_5G_L2L3-98482
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk    (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008083_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
    ...
    ...        [07.03.2023] - Created TC
    ...        [17.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=878958)

    [Setup]  Prepare test environment E-B9c

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE1

    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE1 for gNB

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2

    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE1 for gNB

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE2
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE2

    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE2 for gNB

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2

    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE2 for gNB

    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:260 and ssb:2254267 for UE3
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-2, band:261 and ssb:2078011 for UE3

    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE3 for gNB

    Set expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF1 and gNB2
    Trigger AMF Initiated Partial Reset for UE1
    Verify expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF1 and gNB2
    Verify in NGAP:Reset that ResetType contains 'partOfNG-Interface'
    Verify in NGAP Reset that cause:misc:unspecified is present for gNB
    Verify in F1AP Reset that cause:transport:unspecified is present for gNB

    Set expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF1 and gNB2
    Trigger AMF Initiated Partial Reset for UE2
    Verify expected messages flow for AMF Initiated Partial Reset for UE with NRDC for AMF1 and gNB2
    Verify in NGAP:Reset that ResetType contains 'partOfNG-Interface'
    Verify in NGAP Reset that cause:misc:unspecified is present for gNB
    Verify in F1AP Reset that cause:transport:unspecified is present for gNB

    Set expected messages flow for AMF Initiated Partial Reset for UE without NRDC for AMF1 and gNB2
    Trigger AMF Initiated Partial Reset for UE3
    Verify expected messages flow for AMF Initiated Partial Reset for UE without NRDC for AMF1 and gNB2
    Verify in NGAP:Reset that ResetType contains 'partOfNG-Interface'
    Verify in NGAP Reset that cause:misc:unspecified is present for gNB

    # CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 2 for NRCELL-2
    #Verify that NG_FLOW_REL_NRDC_RRC_RCFG is equal to 0 for NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2

    #Wait for new PM Counter collecting period
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NRDC_RRC_RCFG is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2

    [Teardown]  Cleanup after test E-B9c
