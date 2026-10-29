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
...          [xx.xx.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=901630

Resource    ./resources/CB008126_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R3
...           CLOUD_5G_I_MP_AP_LO

Suite Setup  Run Setup    f1ap=${True}

*** Variables ***
${LUA_CFG}=    ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
&{TOPOLOGY_TO_LUA}=
...  CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
...  CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua
...  CLOUD_5G_I_MP_AP_LO:VARIANT_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/SA_TDD_2c_1gNBSim.lua


*** Test Cases ***
CB008126-A-B3 5QI modification success single PDU single nonGBR
    [Tags]    B3_1
    [Documentation]
    ...  DESCRIPTION:
    ...    Test verifies repetition of successful modification of 5QI for an existing non-GBR QoS Flow for single PDU session.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - 5QIs 128, 170, 254 are configured with NRDRB.resType = 'nonGBR'
    ...     - 5QI 128 is configured with NRDRB.rlcMode = 'RLC_AM'
    ...     - 5QI 254 is configured with NRDRB.rlcMode = 'RLC_UM'
    ...     - Each non-GBR 5QI has different setup of NRDRB_MAC.schedulPrio
    ...
    ...  POSTCONDITION:
    ...     - UE is configured with 1 PDU session with 1 QoS Flow with 5QI=9.
    ...     - DL and UL traffic is ongoing for UE
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
    ...      [12.01.2024] - Create first Test Case shape

#    [Setup]    Prepare test environment

    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'False'}

    Set QoS 15(5QI9) as default for UE1 PDU1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify in RRCReconfiguration that QFI1 is configured with 5QI9 for UE1 for PDU1
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

#    Wait for RTPM before test

    Set 5QI5 resType to nonGBR
    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'True'}

    Perform successful PDU1 session modification, QoS Flow=15(5QI9->5QI5) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Perform successful PDU1 session modification, QoS Flow=15(5QI5->5QI6) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Perform successful PDU1 session modification, QoS Flow=15(5QI6->5QI7) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Perform successful PDU1 session modification, QoS Flow=15(5QI7->5QI8) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Perform successful PDU1 session modification, QoS Flow=15(5QI8->5QI9) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Set 5QI5 resType to nonGBR_Signaling
    Perform successful PDU1 session modification, QoS Flow=15(5QI9->5QI5) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Perform successful PDU1 session modification, QoS Flow=15(5QI5->5QI128) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Perform successful PDU1 session modification, QoS Flow=15(5QI128->5QI254) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

#    Set 5QI170 resType to GBR
#    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_mod=15(5QI254->GBR_5QI170)   validation=off
#    Fail, take kw from error case
#    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Set 5QI170 resType to nonGBR
    Perform successful PDU1 session modification, QoS Flow=15(5QI254->5QI170) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Perform successful PDU1 session modification, QoS Flow=15(5QI70->5QI9) for QFI1 for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    # Add counters for failed modification of 5QI-170 (+1 fail)
    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 10  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 10  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_FAIL_SENT

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 10  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C00047  NRCELL-1  eq 10  NG_FLOW_MOD_SUCC
    add_rtpm_for_validation   M55125C00045  NRCELL-1  eq 0  NG_FLOW_MOD_FAIL
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 0  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08502  NRCELL-1  eq 0  NG_FLOW_SETUP_SUCC

    add_rtpm_for_validation   M55163C00023  NRPMQAP-5  eq 2  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-5  eq 2  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-5  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-6  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-6  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-6  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-7  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-7  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-7  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-8  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-8  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-8  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-9  eq 2  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-9  eq 2  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-9  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-10  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-10  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-10  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-11  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-11  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-11  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-13  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-13  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-13  eq 0  NG_FLOW_MOD_FAIL_PMQAP

    add_rtpm_for_validation   M55163C00001  NRPMQAP-5  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-5  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-6  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-6  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-7  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-7  eq 1  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-8  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-8  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-9  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-9  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-10  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-10  eq 1  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-11  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-11  eq 1  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-13  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-13  eq 1  NG_FLOW_SETUP_SUCC_PMQAP

    add_rtpm_for_validation   M55163C00003  NRPMQAP-5  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-6  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-7  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-8  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-9  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-10  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-11  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-13  eq 0  NG_FLOW_REL_PMQAP

    verify_rtpm_counters

    [Teardown]    Cleanup after test B3_1

CB008126-A-B3 5QI modification success single PDU nonGBR and VoNR and GBR and 5QI-5 established
    [Tags]    B3_2
    [Documentation]
    ...  DESCRIPTION:
    ...    UE has single PDU session, which contains nonGBR 5QI5 and 5QI9, GBR and VoNR QoS Flow.
    ...    Test verifies successful modification of 5QI9 for an existing non-GBR QoS Flow
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - Each non-GBR 5QI has different setup of NRDRB_MAC.schedulPrio
    ...     - NRCELL-1.actNonVoNRGbrService = true
    ...     - NRCELL-1.actVoNR = true
    ...
    ...  POSTCONDITION:
    ...     - UE is configured with 1 PDU session with 3 QoS Flows with 5QI6 and 5QI1, 5QI2
    ...     - DL and UL traffic is ongoing for UE
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
    ...      [12.01.2024] - Create first Test Case shape

#    [Setup]    Prepare test environment

    Set QoS 11(5QI5) as default for UE1 PDU1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify in RRCReconfiguration that QFI1 is configured with 5QI5 for UE1 for PDU1
    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_add=15(5QI9)
    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_add=1(5QI1),2(5QI2)
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI3 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI4 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI4

    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_mod=15(5QI9->5QI6)
    Verify in RRCReconfiguration that QFI2 is configured with 5QI9 for UE1 for PDU1
    Verify in RRCReconfiguration that setup bearers have higher IDs than released bearers for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI4

    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_mod=15(5QI6->5QI9)
    Verify in RRCReconfiguration that QFI2 is configured with 5QI9 for UE1 for PDU1
    Verify in RRCReconfiguration that setup bearers have higher IDs than released bearers for UE1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI3
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI4

    [Teardown]    Basic cleanup

CB008126-A-B3 Successful 5QI modification with simultaneous QoS flow addition
    [Tags]    B3_4
    [Documentation]
    ...  DESCRIPTION:
    ...    Test verifies successful modification of 5QI for an existing non-GBR QoS Flow with simultaneous addition
    ...    non-GBR GoS Flow for the same PDU session.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - Each non-GBR 5QI has different setup of NRDRB_MAC.schedulPrio
    ...
    ...  POSTCONDITION:
    ...     - UE is configured with 1 PDU session with 2 QoS Flows with 5QI=6 and 5QI=7
    ...     - DL and UL traffic is ongoing for UE
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
    ...      [12.01.2024] - Create first Test Case shape

#    [Setup]    Prepare test environment

#    Wait for RTPM before test

    Set QoS 15(5QI9) as default for UE1 PDU1
    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Verify in RRCReconfiguration that QFI1 is configured with 5QI9 for UE1 for PDU1
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_mod=15(5QI9->5QI6)    qos_to_add=13(5QI7)
    Verify in RRCReconfiguration that QFI1 is configured with 5QI6 for UE1 for PDU1
    Verify in RRCReconfiguration that QFI2 is configured with 5QI7 for UE1 for PDU1
    Verify in RRCReconfiguration that setup bearers have higher IDs than released bearers for UE1
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI2

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 1  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 1  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_FAIL_SENT

    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 1  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C00047  NRCELL-1  eq 1  NG_FLOW_MOD_SUCC
    add_rtpm_for_validation   M55125C00045  NRCELL-1  eq 0  NG_FLOW_MOD_FAIL
    add_rtpm_for_validation   M55125C08503  NRCELL-1  eq 0  NG_FLOW_REL
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 1  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08502  NRCELL-1  eq 1  NG_FLOW_SETUP_SUCC

    add_rtpm_for_validation   M55163C00023  NRPMQAP-9  eq 0  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-9  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-9  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-6  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-6  eq 1  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-6  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00023  NRPMQAP-7  eq 0  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-7  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-7  eq 0  NG_FLOW_MOD_FAIL_PMQAP

    add_rtpm_for_validation   M55163C00001  NRPMQAP-9  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-9  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-6  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-6  eq 0  NG_FLOW_SETUP_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-7  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-7  eq 1  NG_FLOW_SETUP_SUCC_PMQAP

    add_rtpm_for_validation   M55163C00003  NRPMQAP-9  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-6  eq 0  NG_FLOW_REL_PMQAP
    add_rtpm_for_validation   M55163C00003  NRPMQAP-7  eq 0  NG_FLOW_REL_PMQAP

    verify_rtpm_counters

    [Teardown]    Basic cleanup

*** Keywords ***
Basic cleanup
    restore_initial_qosflow_configuration_in_egate
    Deregister UE1 and kill if failed

Cleanup after test B3_1
    restore_initial_qosflow_configuration_in_egate
    Deregister UE1 and kill if failed
    Run Keyword If Test Failed    Run Keywords
    ...    Set 5QI5 resType to nonGBR_Signaling    AND
    ...    Set 5QI170 resType to nonGBR    AND
    ...    Configure  {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'True'}
