*** Settings ***
Documentation
...
...      INTRODUCTION: During analysis of PR721160, 5GC000637_Xn_management_for_SA_option_2 feature was not
...                    properly implemented on EFS and Dev level. After 5G_L3_27779 requirement amendments
...                    Xn Setup Request should be sent only when NRADJGNB with xnLinkId configured and Xn-C
...                    link state to "unavailable" are processed.
...
...      TEST SET NAME:  LBT27659-A-B1
...
...      TESTING SCOPE:
...      LBT27659-A-B1
...
...      CONTACTS:
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...
...      REFERENCES:    PR link:    https://pronto.ext.net.nokia.com/pronto/problemReportSearch.html?freeText
...                                 dropDownID=prId&searchTopText=PR721160
...                     PR link:    https://pronto.ext.net.nokia.com/pronto/problemReportSearch.html?freeText
...                                 dropDownID=prId&searchTopText=PR739358
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/LBT27659
...
...               [26.10.2023] - Created TC
...               [05.11.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=897879)

Resource    ./resources/LBT27659-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua

*** Test Cases ***
LBT27659-A-B1_Xn_Setup_procedure_XnSetupRequest_timeout
    [Documentation]
    ...  DESCRIPTION: This test covers the scenario when XNLINK-1 object is being configured without correlated NRADJGNB.
    ...  After XN SetupRequest message is sent for XNLINK-1, NRBTS.xnSetupRespTmr timer expired and XN SetupResponse
    ...  message does not occur. According to NIDD parameters, retry connection is trying to be established.
    ...  After the second attempt, XN SetupResponse is being sent properly. In result NRADJGNB-1 object is created and
    ...  XN link setup succeeds.
    ...
    ...  PRECONDITION:
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Cell-1 has NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - simulated gNB3 is up and running with one cell
    ...  - NRBTS.maxNumXnSetupRetry = 20
    ...  - NRBTS.maxParallelXnSetup = 5
    ...  - NRBTS.retryXnSetupTmr = 10
    ...  - NRBTS.xnSetupReqTmr = 60
    ...  - NRBTS.xnSetupRespTmr = 5
    ...
    ...  POSTCONDITION:
    ...  - Successful establishment of XNLINK-1
    ...  - NRADJGNB-1 is created
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ASIO) with simulated 2 AEQE radio modules - NR_BAND: n78
    ...  - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...  - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_L3_27779
    ...       *BACKLOG ID: FCA_5G_L2L3-204045
    ...
    ...  REQUIRED LOGS: XNAP, SCTP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski   (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:    PR link:    https://pronto.ext.net.nokia.com/pronto/problemReportSearch.html?freeText
    ...                             dropDownID=prId&searchTopText=PR721160
    ...                 PR link:    https://pronto.ext.net.nokia.com/pronto/problemReportSearch.html?freeText
    ...                             dropDownID=prId&searchTopText=PR739358
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/LBT27659
    ...
    ...  [26.10.2023] - Create first Test Case
    ...  [05.11.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=897879)

    [Tags]  A-B1-2   SKIPRUN

    [Setup]     Prepare Test Environment A-B1

    Log To Console  Configure XNLINK-1 without correlated NRADJGNB-1
    Expect that SCTP connection between 10.0.1.2 and 10.0.1.31 will be established
    EXPECT FLOW[timeout=60]: gNB3 XNAP xnSetup
    Configure  ${setup_xnlink-1}
    Verify that SCTP connection between 10.0.1.2 and 10.0.1.31 has been established
    FAIL FLOW[timeout=60]: gNB3 XNAP xnSetup

#   after retryXnSetupTmr=30 expired, XnSetupRequest should be send again
    EXPECT FLOW[timeout=60]: gNB3 XNAP xnSetup
    PASS FLOW[timeout=60]: gNB3 XNAP xnSetup

    Sleep    10
    Verify NRADJGNB-1 status is set to Unlocked
    Verify NRADJGNB-1 amfRegionInformation section is present
    Verify XNLINK-1 status is set to available

    [Teardown]   Cleanup after test A-B1

LBT27659-A-B1_Xn_Setup_procedure_XnSetupRequest_timeout_alternate_scenario
    [Documentation]
    ...  DESCRIPTION: This test covers the scenario when NRADJGNB-1 object is being configured with correlated XNLINK-1.
    ...  After XN SetupRequest message is sent for XNLINK-1, NRBTS.xnSetupRespTmr timer expired and XN SetupResponse
    ...  message does not occur. According to NIDD parameters, retry connection is trying to be established.
    ...  After the second attempt, XN SetupResponse is being sent but with wrong globalGNb ID.
    ...  In result NRADJGNB-2 object is created and establishment of XNLINK-1 should be visible.
    ...
    ...  PRECONDITION:
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Cell-1 has NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - simulated gNB3 is up and running with one cell
    ...  - NRBTS.maxNumXnSetupRetry = 20
    ...  - NRBTS.maxParallelXnSetup = 5
    ...  - NRBTS.retryXnSetupTmr = 10
    ...  - NRBTS.xnSetupReqTmr = 60
    ...  - NRBTS.xnSetupRespTmr = 5
    ...
    ...  POSTCONDITION:
    ...  - Successful establishment of XNLINK-1
    ...  - NRADJGNB-2 is created
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ASIO) with simulated 2 AEQE radio modules - NR_BAND: n78
    ...  - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...  - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_L3_27779
    ...       *BACKLOG ID: FCA_5G_L2L3-204045
    ...
    ...  REQUIRED LOGS: XNAP, SCTP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski   (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS       (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/LBT27659
    ...
    ...  [26.10.2023] - Create first Test Case
    ...  [05.11.2023] - Approved by (Kamil Zborowski, https://collab.ext.net.nokia.com/ui#review:id=897879)

    [Tags]  A-B1-3   SKIPRUN

    [Setup]     Prepare Test Environment A-B1

    Log To Console  Configure XNLINK-1 with corelated NRADJGNB-1
    Expect that SCTP connection between 10.0.1.2 and 10.0.1.31 will be established
    EXPECT FLOW[timeout=60]: gNB3 XNAP xnSetup
    Configure  ${setup_nradjgnb_and_xnlink}
    Verify that SCTP connection between 10.0.1.2 and 10.0.1.31 has been established
    FAIL FLOW[timeout=60]: gNB3 XNAP xnSetup

#   after retryXnSetupTmr=30 expired, XnSetupRequest should be send again
    EXPECT FLOW[timeout=60]: gNB3 XNAP xnSetup
    PASS FLOW[timeout=60]: gNB3 XNAP xnSetup

    Sleep    10
    Verify NRADJGNB-1 status is set to Unlocked
    Verify NRADJGNB-1 amfRegionInformation section is present
    Verify XNLINK-1 status is set to available

    [Teardown]   Cleanup after test A-B1

*** Keywords ***
Prepare Test Environment A-B1
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actConflictConfiguration': 'true'}
    Execute egate command    cmd=link_drop link=xn by=gnb:3 to=gnb:2 msg_type=shutdown
    Create sctp json source
    Set XN Setup timers: xnSetupRespTmr=5 retryXnSetupTmr=60
    Trigger gNB3 to NOT respond to 1 XN:SetupRequest message

Cleanup after test A-B1
    Execute egate command    cmd=gnb_xn_setup_param id=3 reset
    Configure  ${delete_nradjgnb_and_xnlink}
