*** Settings ***
Documentation
...
...      INTRODUCTION: The feature CB008083 will implement the following gNB enhancements on NG-C interface:
...      - Support of GUAMI Type IE in NG Setup Response and AMF Configuration Update messages
...      - Maximum number of NG Setup Retries increased to 1000 (from 100)
...      - Controlled shutdown of the NG-C link , i.e. SCTP association is gracefully shutdown when
...          - NG-C link is locked, and NG Flex feature is not activated (currently supported when NG Flex
...            feature is activated)
...          - last SA cell is removed/deactivated
...      - Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...
...      TEST SET NAME:  CB008083-D
...
...      TESTING SCOPE:
...      CB008083-D Support of optional RAN Node Name IE in the NG Setup Request and RAN Configuration Update messages
...      - CB008083-D#B1: MSC 5G_CP_CONF_669 NG Setup
...      - CB008083-D#B2: MSC 5G_CP_CONF_669 NG RAN Configuration Update
...
...      CONTACTS:
...      CFAM Leader        : Mateusz Basiejko      (Nokia - PL/Krakow) <mateusz.basiejko@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Dawid Krawczuk        (Nokia - PL/Krakow) <dawid.krawczuk@nokia.com>
...                           Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
...                           Marek Kieltyka        (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000263b7#o=0
...                     FTS link:              http://nok.it/CB008083_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008083-SR
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
...
...               [23.11.2022] - Created TC
...               [02.01.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872572)

Resource    ./resources/CB008083_common_keywords.robot
Resource    ./resources/CB008083_setups_and_teardowns.robot
Resource    ta_messaging/single_message_observer.robot

Library     resources/message_verifier.py
#Library     resources/live_guami_view.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...    Run keywords
...     Create AMF device with alias 'AMF1' identified by ip=10.0.1.11    AND
...     Create AMF device with alias 'AMF2' identified by ip=10.0.1.12    AND
...     Create AMF device with alias 'AMF3' identified by ip=10.0.1.13    AND
...     Create GNB device with alias 'gNB2' identified by ip=10.0.1.2

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim_3amf_TC6.lua

*** Test Cases ***
CB008083-D-B1-B2 NGSetupRequest and NGRANConfigurationUpdate with RAN Node Name IE
    [Tags]    B-TC1
    [Documentation]
    ...
    ...  DESCRIPTION: Test verifies that gNB sends to AMFs NGSetupRequest and NGRANConfigurationUpdate with correct
    ...               RAN Node Name IE based on NRBTS.gNbCuName.
	...
    ...  PRECONDITION:
    ...  - Real gNB2 is up and running
    ...  - AMF1, AMF2 and AMF3 are up and running
    ...  - SCTP associations for NG-C links between gNB2 and AMF1, AMF2, AMF3 are established
    ...  - NRBTS.actEnhancedNgRanSupport = true (CB008083)
    ...  - NRBTS.actNgcFlexSaMode = True
    ...  - NRBTS.gNbCuName = gNBCN2
	...
    ...  POSTCONDITION:
    ...  - NG-C links with AMFs are setup and proper status is updated to OAM
    ...  - Counters:
    ...  - E1_GNB_CUCP_CONFIG_UPD_SENT = 3
    ...  - E1_GNB_CUCP_CONFIG_ACK_RCV = 3
    ...  - NG_CU_RAN_CONFIG_UPD_SENT = 8
    ...  - NG_CU_RAN_CONFIG_ACK_RCV = 8
	...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_17572, 5G_RAN_OP_2492, 5G_RAN_USR_RRM_17573
    ...       *BACKLOG ID: FCA_5G_L2L3-116450;FCA_5G_L2L3-130814;FCA_5G_L2L3-124935
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/000263b7#o=0
    ...  FTS link:              http://nok.it/CB008083_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008083-SR
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
    ...
    ...        [23.11.2022] - Created TC
    ...        [02.01.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=872572)

    [Setup]     Prepare test environment D-TC1

    Lock NGAP link to AMF1
    EXPECT FLOW: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP rANConfigurationUpdate
    Configure gNbCuName to gNBCN3
    FAIL FLOW: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW: AMF3 NGAP rANConfigurationUpdate
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to gNBCN3
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to gNBCN3

    EXPECT FLOW: AMF1 NGAP nGSetup
    Unlock NGAP link to AMF1
    PASS FLOW: AMF1 NGAP nGSetup
    Verify that NG Setup Request to AMF1 contains RANNodeName set to gNBCN3

    Reconfigure gNbCuName to gNBCN4 and set actEnhancedNgRanSupport to false

    EXPECT FLOW: AMF1 NGAP nGSetup
    Reset NG link to AMF1
    PASS FLOW: AMF1 NGAP nGSetup
    Verify that NG Setup Request to AMF1 does not contain RANNodeName

    EXPECT FLOW: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW: AMF3 NGAP rANConfigurationUpdate
    Reconfigure gNbCuName to gNBCN5 and set actEnhancedNgRanSupport to true
    PASS FLOW: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW: AMF3 NGAP rANConfigurationUpdate
    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNBCN5
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to gNBCN5
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to gNBCN5

    EXPECT FLOW: AMF1 NGAP nGSetup
    EXPECT FLOW: AMF2 NGAP nGSetup
    EXPECT FLOW: AMF3 NGAP nGSetup
    Reset NG link to AMF1
    Reset NG link to AMF2
    Reset NG link to AMF3
    PASS FLOW: AMF1 NGAP nGSetup
    PASS FLOW: AMF2 NGAP nGSetup
    PASS FLOW: AMF3 NGAP nGSetup
    Verify that NG Setup Request to AMF1 contains RANNodeName set to gNBCN5
    Verify that NG Setup Request to AMF2 contains RANNodeName set to gNBCN5
    Verify that NG Setup Request to AMF3 contains RANNodeName set to gNBCN5

    EXPECT FLOW[timeout=120]: AMF1 NGAP rANConfigurationUpdate
    EXPECT FLOW[timeout=120]: AMF2 NGAP rANConfigurationUpdate
    EXPECT FLOW[timeout=120]: AMF3 NGAP rANConfigurationUpdate
    Delete gNbCuName
    Configure gNbCuName to gNBCN6
    PASS FLOW[timeout=120]: AMF1 NGAP rANConfigurationUpdate
    PASS FLOW[timeout=120]: AMF2 NGAP rANConfigurationUpdate
    PASS FLOW[timeout=120]: AMF3 NGAP rANConfigurationUpdate
    Verify that RAN Configuration Update to AMF1 contains RANNodeName set to gNBCN6
    Verify that RAN Configuration Update to AMF2 contains RANNodeName set to gNBCN6
    Verify that RAN Configuration Update to AMF3 contains RANNodeName set to gNBCN6

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved

    Run keyword and continue on failure  Verify PM counters for RANNodeName update: E1_SENT:3, E1_ACK:3, NG_SENT:8, NG_ACK:8

    [Teardown]   Cleanup after test D-TC1

*** Keywords ***
Reconfigure gNbCuName to ${gnbcu_name} and set actEnhancedNgRanSupport to ${value}
    Create new plan
    Edit Planned Object Attributes   NRBTS-1    actEnhancedNgRanSupport=${value}
    Edit Planned Object Attributes   NRBTS-1    gNbCuName=${gnbcu_name}
    Apply planned changes
