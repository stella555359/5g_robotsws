*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This feature introduces the RRC Inactive state, including RRC state transitions to/from other states under the same gNB,
...      for 5G UEs operating in 3GPP NR Standalone (SA) mode.
...
...      TEST SET NAME: CB008225-G RRC Inactive and interaction with Location Reporting
...
...      TESTING SCOPE:
...          CB008225-A Configuration of RAN Area Code and broadcast of SIB1 for RRC Inactive State
...          CB008225-B Transition from RRC Connected to RRC Inactive State (Suspend)
...          CB008225-C RAN Paging for UE in RRC Inactive State
...          CB008225-D Transition from RRC Inactive to RRC Connected State (Resume)
...          CB008225-E RRC Inactive and interaction with Carrier Aggregation
...          CB008225-F RRC Inactive and interaction with intra gNB NR-DC
...          CB008225-G RRC Inactive and interaction with Location Reporting
...          CB008225-H RRC Inactive and interaction with Idle Mode Mobility Steering
...          CB008225-I RRC Inactive and interaction with other features
...          CB008225-J Tracing and PCMD support for UE in RRC_INACTIVE state
...          CB008225-K RRC Inactive and interaction with CB008311 feature
...          CB008225-L RRC Inactive and interaction with 5G Sleeping Cell Detection
...          CB008225-W Capacity and Performance
...
...      CONTACTS:
...          CFAM Leader        : Lukasz Haracz (Nokia - PL/Wroclaw) <lukasz.haracz@nokia.com>
...          ET owner (LPO/APO) : Karolina Zwierz (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...          Entity Testing L3  : Dawid Krawczuk (Nokia - PL/Krakow) <dawid.krawczuk@nokia.com>
...                               Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
...
...      MAINTAINER:
...          I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...          CFAM link:        https://gates.nsn-net.net/view/000266ca#o=0
...          FTS link:         https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN Productization WoW/
...                            _layouts/15/Doc.aspx?sourcedoc=%7BBF0E0D78-5F93-44B6-B194-28AB9D40A9EC%7D
...          L3 ET Test Plan:  https://nokia-my.sharepoint.com/:w:/p/dawid_krawczuk/EQS_1YWHr45GoH6vG2FutwUBza6siTgzDgiC0cIbrwCq4Q
...
...      HISTORY:
...          History, current status and TC description is available in repository:
...          https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008225
...
...          [20.03.2023] - Create Test Suite
...          [xx.xx.TODO] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=879002)

Resource    ./resources/CB008225_common_keywords.robot
Library    ./resources/custom_LocationControlEncoder.py
Library    ./resources/AMF_RAN_IDS.py

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SANSA_TDD_1c_1eNBsim_1gNBsim.lua

*** Test Cases ***
example
    [Setup]     Run Keywords
    ...         Setup egate  egate_port=20000  alias=default
    ...         AND  Setup devices aliases
    ...         AND  Observe NG-C ICS messages and update database
    # do attach here
    wait_for_number_of_updates      1
    ${ids}=    get last ids
    ${amf_id}=    Get From List    ${ids}    0   #${ids}[0]
    ${ran_id}=    Get From List    ${ids}    1   #${ids}[1]
    ${hex}=       build_LRC       ${amf_id}       ${ran_id}
    Execute egate command    cmd=send_hex source=amf:1 target=gnb:2 hex=${hex}
    clear updates counter


resume
    [Setup]     Run Keywords
    ...         Setup egate  egate_port=20000  alias=default
#    ...         AND   Prepare test environment B2_2
    ...         AND  Setup devices aliases
    ...         AND   Enable internal mirroring for alias  gNB2
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Wait until UE1 goes to RRC_INACTIVE by UAI
    Set verifiers per message
    ...    InitialULRRCMessageTransfer:rrcResumeRequest1 is present and resumeCause eq "highPriorityAccess"
    Sleep     5
    EXPECT FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    Execute egate command  cmd=ue_nr_rrc_resume id=1
    PASS FLOW[timeout=10]: gNB2 F1AP initialULRRCMessageTransfer with rrcResumeRequest1 message
    Execute egate command  cmd=ue_kill id=1


