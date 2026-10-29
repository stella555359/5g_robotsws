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
...                     FTS link:              http://nok.it/CB008717_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
...
...               [23.01.2023] - Created TC
...               [09.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=877376)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_E_B1a_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-B1a_NRDC_UE_release_due_to_RRCReestablishment_AMF_cleanup
    [Tags]    E-B1a
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behaviour for UE with established NR-DC connection (with established
    ...  MN-terminated split bearer) during RRC Reestablishment to serving cell.
    ...  During the test, UE has experienced RLF and sends RRC: Reestablishment Request to the same gNB.
    ...  It should cause successfully retrieves of old UE Context for UE with MN-terminated split bearer.
    ...  Next according to US5GC002267-A#B1 Early introduction of RRC connection reestablishment via RRC Setup,
    ...  procedure of Re-establishment via RRC: RRC Setup is successfully performed. Old UE Context is released by AMF.
    ...  Additional UE2 checks that non NRDC UEs performs Re-establishment via RRCReestablishment procedure.
    ...
    ...  PRECONDITION:
    ...  - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - One FR1 cell (NRBTS/NRCELL-3) is active in pure SA mode of operation with enabled NR-DC
    ...  - NRBTS/NRCELL-1 simulated on AEUD radio module - NR_BAND: n260 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AHLOA radio module - NR_BAND: n66 (FDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 20MHz (TDD)
    ...  - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n261 (TDD)
    ...  - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2254267
    ...  - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 260
    ...  - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/NRCELL-1/NRHOIF-2/ssbFrequency is set to 2078011
    ...  - NRBTS/NRCELL-1/NRHOIF-2/freqBandIndicatorNR is set to 261
    ...  - NRBTS/NRCELL-1/NRHOIF-2/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/NRCELL-1.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRCELL-2.actNrDualConnectivity = 'intra-gNB_intra-DU_FR1-FR2'
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS.rrcReestabTypeSA is set to 'sameGNB'
    ...
    ...  POSTCONDITION:
    ...  - UE1 has established MN-terminated split bearer
    ...  - Signalling connections for the old UE1 Context are removed
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_FS_LOO (ASIL + 2xABIO)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15323; 5G_RAN_USR_RRM_15626
    ...       *BACKLOG ID: FCA_5G_L2L3-98471
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak    (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008717_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717/CB008717-E-B1a.robot
    ...
    ...        [23.01.2023] - Created TC
    ...        [09.03.2023] - Approved by EFS (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=877376)
    ...        [13.03.2023] - Test finished
    ...        [13.04.2023] - Extend TC by adding precondition with params setting and cleanup method
    ...        [26.04.2023] - Review closed
    ...        [05.06.2023] - FWA aligement with RFSP index
    ...        [22.06.2023] - ICS fix for unexpected 5GCSim way of work; dedicated SCF file
    ...        [19.07.2023] - Add RD counter check from -DE scope
    ...        [24.07.2023] - -DE scope extended by additional PM period checks
    ...        [04.10.2023] -  PR728511 migrate from PEAK to MAX

    [Setup]  Prepare test environment E-B1a

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Set expected message flows for UE1 Context Release due to UE sends reestablishment to gNB2 with AMF1
    Set expected message flows for not optimized UE1 ICS after reestablishment via RRC Setup, with gNB2 and AMF1
    Set expected message flows for deletion old UE1 Context by AMF1 after reestablishment, with gNB2
    Exclude UECaps from ICS for UE1 and include indexToRFSP eq 87

    UE1 has experienced RLF and sends RRC Reestablishment Request

    Verify expected messages flows for UE1 Context Release due to UE sends reestablishment to gNB2 with AMF1
    Verify expected messages flows for not optimized UE1 ICS after reestablishment via RRC Setup, with gNB2 and AMF1
    Verify expected messages flows for deletion old UE1 Context by AMF1 after reestablishment, with gNB2

    Verify that AMF1 release UE with Cause Group: misc and Cause: 'unspecified'

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-1 for UE1
    Set Test Variable  ${meas_id}
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1

    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1

    Set expected message flows for RRCReestablishment procedure for UE2, gNB2 and AMF1
    UE2 sends RRC Reestablishment Request
    Verify expected messages flows for RRCReestablishment procedure for UE2, gNB2 and AMF1

    # CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (400, 600) for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-2
    #Verify that SUM_UE_NRDC_MN_CU is in range (250, 300) for NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-2
#   #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 2 for NRCELL-2   #waiting for PM3
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 1 for NRCELL-2

    Deregister UE1 from AMF1
    Verify that AMF1 release UE with Cause Group: nas and Cause: 'normal-release'
    Deregister UE2 from AMF1
    Verify that AMF1 release UE with Cause Group: nas and Cause: 'normal-release'

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 2 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (20, 100) for NRCELL-2
    #Verify that SUM_UE_NRDC_MN_CU is in range (10, 50) for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 1 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2

    #Wait for new PM Counter collecting period

    #Verify that MAX_UE_NRDC_CAP is equal to 0 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is equal to 0 for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 0 for NRCELL-2
    #Verify that SUM_UE_NRDC_MN_CU is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2

    [Teardown]  Cleanup after test E-B1a
