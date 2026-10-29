*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
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
...      TEST SET NAME:  CB008717-DE
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
...               [04.08.2023] - Created TC
...               [11.08.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=891399)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_E_B1a_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-DE-PM3-5_PDU_Session_Modification_with_TB_and_UE_release
    [Tags]   DE-PM3-5
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  The purpose of this testcase is to verify counters NG_FLOW_REL_NOR_NRDC  NG_FLOW_REL_ABN_NRDC, NG_FLOW_REL_NRDC_RRC_RCFG.
    ...  This test cover CB008717-F-B1_ALT1 user scenario in which AMF requests modification of PDU which is already in split mode.
    ...  AMF provides request for deletion of non-last QoS flow. gNB detects that affected PDU operates in NRDC and triggers Takeback.
    ...  After Takeback is completed QoS flow release is performed including sending NGAP:PDUSessionResourceModifyResponse.
    ...  Also error scenario with PDU Session modification failure will be covered.
    ...
    ...  PRECONDITION:
    ...  Same preconditions as in CB008717-E-B1a scenario with difference in:
    ...  NRBTS/NRPMRNL/miNrRSACU = 5min
    ...  NRBRS/NRPMRNL/miNrCUCM = 5min
    ...  NRBTS/NRPMRNL/miNrNGCC  = 5min
    ...  POSTCONDITION:
    ...  - gNB and AMF released all resources related to UE1, UE2, UE3
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
    ...        [04.08.2023] - Created TC
    ...        [11.08.2023] - Approved by EFS (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=877376)
    ...        [06.09.2023] - Test finished
    ...        [04.10.2023] -  PR728511 migrate from PEAK to MAX

    [Setup]  Prepare test environment for DE-PM3-5

    Attach UE1 without ICS to gNB2 cell2
    Add to UE1 initial PDU session with ICS
    Add to UE1 PDU1 session QoS flows with 5QI from list [9,8] and delete QoS flows with 5QI from list []
    Trigger UE1 to enter idle mode

    Attach UE2 without ICS to gNB2 cell2
    Add to UE2 initial PDU session with ICS
    Add to UE2 PDU1 session QoS flows with 5QI from list [9,8] and delete QoS flows with 5QI from list []
    Trigger UE2 to enter idle mode

    Attach UE3 without ICS to gNB2 cell2
    Add to UE3 initial PDU session with ICS
    Add to UE3 PDU1 session QoS flows with 5QI from list [9,8] and delete QoS flows with 5QI from list []
    Trigger UE3 to enter idle mode

    #Wait for new PM Counter collecting period

    Exit idle mode and setup NRDC for UE1
    Remove QoS flows with 5QI from list [8] from NRDC splitted PDU1 at UE1 and expect TakeBack occured
    Verify that QosFlowToRelaseList recieved with cause:radioNetwork:unspecified
    Deregister UE1 from AMF1
    Verify that AMF1 release UE with Cause Group: nas and Cause: 'normal-release'

    Exit idle mode and setup NRDC for UE2
    Remove QoS flows with 5QI from list [8] from NRDC splitted PDU1 at UE2 and expect TakeBack failure
    Verify that QosFlowToRelaseList recieved with cause:radioNetwork:unspecified
    Deregister UE2 from AMF1
    Verify that AMF1 release UE with Cause Group: nas and Cause: 'normal-release'

    Exit idle mode and setup NRDC for UE3
    Remove QoS flows with 5QI from list [8,9] from NRDC splitted PDU1 at UE3 and expect PDUModification failure
    Verify that QosFlowToRelaseList recieved with cause:radioNetwork:unspecified

    #Wait for new PM Counter collecting period
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 4 for NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 3 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 3 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 9 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 9 for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-2

    [Teardown]  Cleanup after test DE-PM3-5
