*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This feature allows the modification of parameters for established QoS Flows and PDU sessions.
...      The procedure is initiated by the AMF with a PDU SESSION RESOURCE MODIFY REQUEST message.
...      With this feature, the following parameters can be modified by this procedure:
...      - 5QI
...        - Modification of 5QI is only allowed for nonGBR QoS Flows i.e. modification of 5QI for GBR QoS Flows is rejected
...        - Modification of 5QI from nonGBR to GBR QoS Flow is rejected
...        - Depending on the configuration (5QI to DRB profile mapping), a new DRB profile can be used and new settings
...          are used by the scheduler and lead to UE reconfiguration.
...        - Only modification of non-dynamic 5QI is supported
...      - UL NG-U UP TNL (UPF endpoint of the NG-U transport bearer, for delivery of UL PDUs)
...        - On modification request, the gNB updates the transport layer information for the uplink data accordingly for
...          the concerned transport bearers identified by the UL NG-U UP TNL Information IE for the concerned PDU session
...
...      TEST SET NAME: CB008126-SR-A QoS Flow Modification for classical
...
...      TESTING SCOPE:
...          CB008126-SR-A-B2 QoS Flow Modification - UL NG-U TNL address modification - success (USB5)
...          CB008126-SR-A-B22 QoS Flow Modification - UL NG-U TNL address modification - failure (US#B8)
...
...      CONTACTS:
...          CFAM Leader        : Yiyang Gao (NSB) <yiyang.gao@nokia-sbell.com>
...          ET owner (LPO/APO) : Karolina Zwierz (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...          Entity Testing L3  : Dawid Krawczuk (Nokia) <dawid.krawczuk@nokia.com>
...                               Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
...
...      MAINTAINER:
...          I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:
...          CFAM link:        https://gates.nsn-net.net/view/00026ad2#o=0
...          FTS link:         https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/
...                            _layouts/15/Doc.aspx?sourcedoc=%7BDE1867F4-6925-49C6-B50C-F97B8A941454%7D
...          L3 ET Test Plan:  https://nokia-my.sharepoint.com/:x:/p/dawid_krawczuk/EZoQ8mvgZ3JCoGXAAoqGOpwB6SHOf9l0Ls1pAkzIAAGO4w?e=02pNQ0
...
...      HISTORY:
...          History, current status and TC description is available in repository:
...          https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
...
...          [27.11.2023] - Create Test Suite
...          [07.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=901630)

Resource    ./resources/CB008126_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R3    SKIPRUN
...           CLOUD_5G_I_MP_AP_LO

Suite Setup  Run Setup    f1ap=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
&{TOPOLOGY_TO_LUA}=
...  CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
...  CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
...  CLOUD_5G_I_MP_AP_LO:VARIANT_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua


*** Test Cases ***
CB008126-A-B2 TNL modification for single PDU session with nonGBR only
    [Tags]    B2_1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...    UE has single PDU session, which contains nonGBR QoS Flow only. DL and UL traffic in ongoing for nonGBR QoS Flow.
    ...    Test case verifies, that when AMF request to modify UL NG-U UP TNL address for PDU session, there is no UE or traffic drop.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...
    ...  POSTCONDITION:
    ...     - DL & UL traffic rate for UE is the same as before UL NG-U UP TNL address modification
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/00026ad2#o=0
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
    ...
    ...      [27.11.2023] - Create first Test Case shape
    ...      [07.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=901630)


    [Setup]    Prepare test environment

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that primary UL NG-U UP TNL address is configured for initial PDU1 for UE1
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Wait for RTPM before test
    start collecting syslog    prefix=B2_1

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=teid_only
    Verify that UL NG-U UP TNL TEID only is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 3  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 3  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_FAIL_SENT

    add_rtpm_for_validation   M55133C01004  NRCUUP-1  eq 3  NE1US_CTXT_MOD_REQ_RECD
    add_rtpm_for_validation   M55133C01005  NRCUUP-1  eq 3  NE1US_CTXT_MOD_RSP_SENT
    add_rtpm_for_validation   M55135C00505  NRBTS-1  eq 3  NE1CS_CTXT_MOD_REQ_SENT
    add_rtpm_for_validation   M55135C00506  NRBTS-1  eq 3  NE1CS_CTXT_MOD_RSP_RECD

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 0  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 0  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL
    verify_rtpm_counters

    # CB008126-A-B2 TNL modification with the currently configured address
    # Trigger again PDUSessionResourceModifyRequest with the same contens as above, with the same UL NG-U UP TNL address
    # execute egate command  cmd=send_hex source=amf:1 target=gnb:2 hex=<hex_message>

    [Teardown]    Cleanup after test


CB008126-A-B2 TNL modification for single PDU session with GBR and VoNR and nonGBR
    [Tags]    B2_2
    [Documentation]
    ...  DESCRIPTION:
    ...    UE has single PDU session, which contains nonGBR, GBR and VoNR QoS Flow. DL and UL traffic in ongoing
    ...    on each QoS Flow.
    ...    Test case verifies, that when AMF request to modify UL NG-U UP TNL address for PDU session, there is no UE or traffic drop.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - NRCELL-1.actVoNR = true (5GC000786)
    ...     - NRCELL-1.actNonVoNRGbrService = true (CB008379)
    ...
    ...  POSTCONDITION:
    ...     - DL & UL traffic rate for UE is the same as before UL NG-U UP TNL address modification
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/00026ad2#o=0
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
    ...
    ...      [27.11.2023] - Create first Test Case shape
    ...      [07.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=901630)

    [Setup]    Prepare test environment


    Set QoS 11(5QI5) as default for UE1 PDU1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that primary UL NG-U UP TNL address is configured for initial PDU1 for UE1
    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_add=1(GBR_5QI1),2(GBR_5QI2)

    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI3 and wait 10 seconds

    Wait for RTPM before test
    start collecting syslog    prefix=B2_2

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI2 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI3 UE1 is present only on new UL NG-U UP TNL address

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=teid_only
    Verify that UL NG-U UP TNL TEID only is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI2 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI3 UE1 is present only on new UL NG-U UP TNL address

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 2  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 2  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_FAIL_SENT
    add_rtpm_for_validation   M55125C03504  NRCELL-1  eq 0  NNGCC_PDUSESMOD_FAIL_RAC

    add_rtpm_for_validation   M55133C01004  NRCUUP-1  eq 2  NE1US_CTXT_MOD_REQ_RECD
    add_rtpm_for_validation   M55133C01005  NRCUUP-1  eq 2  NE1US_CTXT_MOD_RSP_SENT
    add_rtpm_for_validation   M55135C00505  NRBTS-1  eq 2  NE1CS_CTXT_MOD_REQ_SENT
    add_rtpm_for_validation   M55135C00506  NRBTS-1  eq 2  NE1CS_CTXT_MOD_RSP_RECD

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 0  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 0  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL
    sleep  60  To make sure that rtpm from full TC will be collected
    verify_rtpm_counters
    clear_rtpm_verification_queue

    [Teardown]    Cleanup after test

CB008126-A-B22 Failed TNL modification for single PDU with nonGBR only with FAF disabled
    [Tags]    B22_1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...    UE has single PDU session, which contains nonGBR QoS Flow only. DL and UL traffic in ongoing for nonGBR QoS Flow.
    ...    Test case verifies, that modification of UL NG-U UP TNL address is rejected when:
    ...    - CB008126 is deactivated
    ...    - modification is requested for unknown PDU session
    ...   Test verifies, that after failed modification it is possible to successfully modify the address
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...
    ...  POSTCONDITION:
    ...     - DL & UL traffic rate for UE is the same as before UL NG-U UP TNL address modification
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/00026ad2#o=0
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
    ...
    ...      [27.11.2023] - Create first Test Case shape
    ...      [07.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904289)

    [Setup]    Prepare test environment

    Wait for RTPM before test
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that primary UL NG-U UP TNL address is configured for initial PDU1 for UE1
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'False'}

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE11
    FAIL FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB rejects PDU1 session modification with cause = 'Unspecified'

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on old UL NG-U UP TNL address

    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'True'}

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address

    # CB008126-A-B22 Failed TNL modification due to wrong PDU session

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModificationFailure
    Trigger PDU session modification    ue_id=1    pdu=2    ul_tnl=teid_only    validation=off
    Verify that UL NG-U UP TNL TEID only is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModificationFailure
    Verify that modification of UL NG-U UP TNL address for PDU2 is rejected by CU-UP with cause 'unknown-PDU-Session-ID'
    Verify that gNB rejects PDU1 session modification with cause = 'Unspecified'

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on old UL NG-U UP TNL address

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=teid_only
    Verify that UL NG-U UP TNL TEID only is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 4  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 2  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 2  NNGCC_PDUSESMODRSP_FAIL_SENT
    add_rtpm_for_validation   M55125C03504  NRCELL-1  eq 0  NNGCC_PDUSESMOD_FAIL_RAC

    add_rtpm_for_validation   M55133C01004  NRCUUP-1  eq 3  NE1US_CTXT_MOD_REQ_RECD
    add_rtpm_for_validation   M55133C01005  NRCUUP-1  eq 3  NE1US_CTXT_MOD_RSP_SENT
    add_rtpm_for_validation   M55135C00505  NRBTS-1  eq 3  NE1CS_CTXT_MOD_REQ_SENT
    add_rtpm_for_validation   M55135C00506  NRBTS-1  eq 3  NE1CS_CTXT_MOD_RSP_RECD

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 0  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 0  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL

    verify_rtpm_counters

    [Teardown]    Cleanup after test


CB008126-A-B22 Failed TNL modification for single PDU with GBR established with FAF disabled
    [Tags]    B22_2    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...    UE has single PDU session, which contains nonGBR, GBR and VoNR QoS Flow. DL and UL traffic in ongoing.
    ...    Test case verifies, that modification of UL NG-U UP TNL address is rejected when CB008126 is deactivated
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...
    ...  POSTCONDITION:
    ...     - DL & UL traffic rate for UE is the same as before UL NG-U UP TNL address modification
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:
    ...       *BACKLOG ID:
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
    ...      ET team   : I_EXT_ETK4_GMS (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...      CFAM link: https://gates.nsn-net.net/view/00026ad2#o=0
    ...      Sub-feature refinement: [TODOCONFLUENCE_LINK]
    ...
    ...  HISTORY:
    ...      History, current status and TC description is available in repository:
    ...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008126
    ...
    ...      [27.11.2023] - Create first Test Case shape
    ...      [07.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904289)

    [Setup]    Prepare test environment

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify that primary UL NG-U UP TNL address is configured for initial PDU1 for UE1
    Add to UE1 PDU1 session QoS flows with 5QI from list [1,2] and delete QoS flows with 5QI from list []
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI3 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3

    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'False'}

    Wait for RTPM before test

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE11
    FAIL FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB rejects PDU1 session modification with cause = 'Unspecified'

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU2 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU3 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on old UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI2 UE1 is present only on old UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI3 UE1 is present only on old UL NG-U UP TNL address

    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'True'}

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Trigger PDU session modification    ue_id=1    pdu=1    ul_tnl=ip_teid
    Verify that UL NG-U UP TNL IP and TEID is requested to be modified for PDU1 for UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify that gNB applies new UL NG-U UP TNL address for PDU1 for UE1

    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU2 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU3 QFI1
    Capture traffic for 5 seconds
    Verify that UL traffic for PDU1 QFI1 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI2 UE1 is present only on new UL NG-U UP TNL address
    Verify that UL traffic for PDU1 QFI3 UE1 is present only on new UL NG-U UP TNL address

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 2  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 1  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 1  NNGCC_PDUSESMODRSP_FAIL_SENT
    add_rtpm_for_validation   M55125C03504  NRCELL-1  eq 0  NNGCC_PDUSESMOD_FAIL_RAC

    add_rtpm_for_validation   M55133C01004  NRCUUP-1  eq 1  NE1US_CTXT_MOD_REQ_RECD
    add_rtpm_for_validation   M55133C01005  NRCUUP-1  eq 1  NE1US_CTXT_MOD_RSP_SENT
    add_rtpm_for_validation   M55135C00505  NRBTS-1  eq 1  NE1CS_CTXT_MOD_REQ_SENT
    add_rtpm_for_validation   M55135C00506  NRBTS-1  eq 1  NE1CS_CTXT_MOD_RSP_RECD

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 0  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C00047  NRCELL-1  eq 0  NG_FLOW_MOD_SUCC
    add_rtpm_for_validation   M55125C00045  NRCELL-1  eq 0  NG_FLOW_MOD_FAIL
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 0  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08502  NRCELL-1  eq 0  NG_FLOW_SETUP_SUCC

    verify_rtpm_counters

    [Teardown]    Cleanup after test


*** Keywords ***
Prepare test environment
    Setup tshark for traffic verification

Cleanup after test
    Stop collecting syslog
    Deregister UE1 and kill if failed
    stop_tshark  alias=GTP_traffic
