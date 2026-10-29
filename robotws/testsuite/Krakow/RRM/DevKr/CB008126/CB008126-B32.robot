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
...          CB008126-SR-A-B32 QoS Flow Modification - 5QI modification - modification reject (USB7)
...
...      CONTACTS:
...          CFAM Leader        : Yiyang Gao (NSB) <yiyang.gao@nokia-sbell.com>
...          ET owner (LPO/APO) : Karolina Zwierz (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...          Entity Testing L3  : Dawid Krawczuk (Nokia) <dawid.krawczuk@nokia.com>
...                               Paulina Jedras (Nokia) <paulina.jedras@nokia.com>
...                               Grzegorz Szymik (Nokia) <grzegorz.szymik@nokia.com>
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
...          [03.01.2024] - Create Test Suite
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
CB008126-A-B32 Rejected 5QI modification due to act5qiAndUlNguTnlQosFlowModification set to false
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario describes the unsuccessful modification of QoS flow for an existing non GBR QoS Flow triggered via PDU Session Resource
    ...    Modification procedure requested by 5GC (single non-GBR for 5QI modification with different DRB profile).
    ...    UE has single PDU session, which contains nonGBR QoS Flow only. DL and UL traffic in ongoing for nonGBR QoS Flow. Then QoS modification
    ...    flag is disabled - NRBTS.act5qiAndUlNguTnlQosFlowModification and because of that, after PDU Session Resource Modify Request,
    ...    QoS flow modification is rejected and gNB sends PDU Session Resource Modify Response (with the PDU Session Resource Fail To Modify
    ...    Response List filled with PDU Session IDs corresponding to the QoS Flows that were not modified, and with Cause = CauseRadioNetwork:
    ...    unspecified) message to the 5GC. Test case verifies also, that there is no UE or traffic drop and relevant counters are updated.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - two different non GBR DRB profiles mapping to 5QI-9 and 5QI-8 with different MAC, PDCP and RLC profiles are configured
    ...
    ...  TEST STEPS:
    ...     1. Setup single PDU session with single nongbr (default) with 5QI-9.
    ...     2. Disable act5qiAndUlNguTnlQosFlowModification
    ...     3. Try to modify 5QI9 to 5QI8. It should fail with cause CauseRadioNetwork:unspecified
    ...
    ...  POSTCONDITION:
    ...     - Requested QoS Flow modification is rejected
    ...     - DL & UL traffic rate for UE is the same as before PDU session resource modify request
    ...     - Relevant counter updated
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_1559;5G_RAN_USR_RRM_23538;OM_GEN_SFS_TRACEMGMNT.4763
    ...       *BACKLOG ID: FCA_5G_L2L3-210200
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Grzegorz Szymik (Nokia) <grzegorz.szymik@nokia.com>
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
    ...      [04.01.2024] - Create first test case shape
    ...      [15.01.2024] - Final test case shape

    [Setup]    Prepare test environment

    rtpm activate
    start rtpm collection interval    wait_for_next_minute_start=True

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup
    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    Configure    {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'false'}

    EXPECT FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=5]: UE_1 NR-RRC RRCReconfiguration
    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_mod=15(5QI9->5QI8)
    FAIL FLOW[timeout=5]: gNB2 E1AP bearerContextModification
    FAIL FLOW[timeout=5]: UE_1 NR-RRC RRCReconfiguration
    Verify that gNB rejects PDU1 session modification with cause = 'unspecified'
    Verify 5Mbps UL and DL traffic on UE1 PDU1 QFI1

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 0  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 1  NNGCC_PDUSESMODRSP_FAIL_SENT
    add_rtpm_for_validation   M55125C03504  NRCELL-1  eq 0  NNGCC_PDUSESMOD_FAIL_RAC
    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 1  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C00045  NRCELL-1  eq 1  NG_FLOW_MOD_FAIL
    add_rtpm_for_validation   M55125C00047  NRCELL-1  eq 0  NG_FLOW_MOD_SUCC
    add_rtpm_for_validation   M55125C09011  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_UNSPECIFIED
    add_rtpm_for_validation   M55125C09012  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_WRONG_MSG
    add_rtpm_for_validation   M55125C10501  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_RRNA

    add_rtpm_for_validation   M55163C00023  NRPMQAP-8  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-8  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-8  eq 1  NG_FLOW_MOD_FAIL_PMQAP

    add_rtpm_for_validation   M55163C00023  NRPMQAP-9  eq 0  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-9  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-9  eq 0  NG_FLOW_MOD_FAIL_PMQAP

    stop rtpm collection interval
    verify_rtpm_counters
    rtpm deactivate

    [Teardown]    Cleanup after test

CB008126-A-B32 Rejected 5QI modification due to act5qiAndUlNguTnlQosFlowModification with simultaneous addition success
        [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario describes the unsuccessful modification of QoS flow for an existing non-GBR QoS Flow with simultaneous successful
    ...    addition of another non-GBR Qos flow triggered via PDU Session Resource Modification procedure requested by 5GC (single non-GBR for 5QI
    ...    modification with different DRB profile). UE has single PDU session, which contains nonGBR QoS Flow only. DL and UL traffic in ongoing
    ...    for nonGBR QoS Flow. Then QoS modification flag is disabled - NRBTS.act5qiAndUlNguTnlQosFlowModification and because of that, after PDU
    ...    Session Resource Modify Request, QoS flow modification is rejected and gNB sends PDU Session Resource Modify Response (with the PDU
    ...    Session Resource Modify Response List filled with qosFlowFailedToAddOrModifyList containing QoS flow ID related to failed to modify 5QI
    ...    with Cause = 'CauseRadioNetwork: unspecified' and qosFlowAddOrModifyResponseList containing QoS flow ID related to added 5QI)
    ...    message to the 5GC. Test case verifies also, that there is no UE or traffic drop and relevant counters are updated.
    ...
    ...  PRECONDITION:
    ...     - NRBTS.act5qiAndUlNguTnlQosFlowMod = true (CB008126)
    ...     - three different non GBR DRB profiles mapping to 5QI-9, 5QI-8 and 5QI-7 with different MAC, PDCP and RLC profiles are configured
    ...
    ...  TEST STEPS:
    ...     1. Setup single PDU session with single nongbr (default) with 5QI-9.
    ...     2. Disable act5qiAndUlNguTnlQosFlowModification
    ...     3. Try to modify 5QI-9 to 5QI-8 and at the same time (in the same message) try to add new qosflow with 5QI-7. Modification should fail
    ...        with cause CauseRadioNetwork:unspecified, but addition of new qos flow should be successful.
    ...
    ...  POSTCONDITION:
    ...     - Requested QoS Flow modification is rejected
    ...     - Requested QoS Flow addition is successful
    ...     - DL & UL traffic rate for UE is the same as before PDU session resource modify request
    ...     - Relevant counter updated
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB (ASIM + ABIP)
    ...     - UE: Airphone (ASIL + ABIO)
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_1559;5G_RAN_USR_RRM_23538;OM_GEN_SFS_TRACEMGMNT.4763
    ...       *BACKLOG ID: FCA_5G_L2L3-210200
    ...
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...      Test owner: Grzegorz Szymik (Nokia) <grzegorz.szymik@nokia.com>
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
    ...      [04.01.2024] - Create first test case shape
    ...      [15.01.2024] - Final test case shape

    [Setup]    Prepare test environment

    rtpm activate
    start rtpm collection interval    wait_for_next_minute_start=True

    Attach UE2 to gNB2 cell1 with ICS during PDU session setup
    Run 5Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds
    Verify 5Mbps UL and DL traffic on UE2 PDU1 QFI1

    Configure    {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'false'}

    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: UE_2 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_2 NR-RRC RRCReconfigurationComplete
    Trigger PDU session modification    ue_id=1    pdu=1    qos_to_add=13(5QI7)    qos_to_mod=15(5QI9->5QI8)
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: UE_2 NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_2 NR-RRC RRCReconfigurationComplete

    Verify in NGAP Qos flows modify for 5QIs [7,8] where [7] succeed and [8] fail for PDU1 with cause=unspecified
    Verify in RRCReconfiguration that qosflows=[2] are successfuly added or modified for UE2
    Verify 5Mbps UL and DL traffic on UE2 PDU1 QFI1

    add_rtpm_for_validation   M55125C03501  NRCELL-1  eq 1  NNGCC_PDUSESMODREQ_RECD
    add_rtpm_for_validation   M55125C03502  NRCELL-1  eq 1  NNGCC_PDUSESMODRSP_SUCC_SENT
    add_rtpm_for_validation   M55125C03503  NRCELL-1  eq 0  NNGCC_PDUSESMODRSP_FAIL_SENT
    add_rtpm_for_validation   M55125C03504  NRCELL-1  eq 0  NNGCC_PDUSESMOD_FAIL_RAC
    add_rtpm_for_validation   M55125C00044  NRCELL-1  eq 1  NG_FLOW_MOD_ATT_TOT
    add_rtpm_for_validation   M55125C00045  NRCELL-1  eq 1  NG_FLOW_MOD_FAIL
    add_rtpm_for_validation   M55125C00047  NRCELL-1  eq 0  NG_FLOW_MOD_SUCC
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 1  NG_FLOW_SETUP_ATT_TOT
    add_rtpm_for_validation   M55125C08501  NRCELL-1  eq 1  NG_FLOW_SETUP_SUCC
    add_rtpm_for_validation   M55125C09011  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_UNSPECIFIED
    add_rtpm_for_validation   M55125C09012  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_WRONG_MSG
    add_rtpm_for_validation   M55125C10501  NRCELL-1  eq 0  NG_FLOW_SETUP_FAIL_RRNA

    add_rtpm_for_validation   M55163C00023  NRPMQAP-7  eq 0  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-7  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-7  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-7  eq 1  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-7  eq 1  NG_FLOW_SETUP_SUCC_PMQAP

    add_rtpm_for_validation   M55163C00023  NRPMQAP-8  eq 1  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-8  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-8  eq 1  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-8  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-8  eq 0  NG_FLOW_SETUP_SUCC_PMQAP

    add_rtpm_for_validation   M55163C00023  NRPMQAP-9  eq 0  NG_FLOW_MOD_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00024  NRPMQAP-9  eq 0  NG_FLOW_MOD_SUCC_PMQAP
    add_rtpm_for_validation   M55163C00025  NRPMQAP-9  eq 0  NG_FLOW_MOD_FAIL_PMQAP
    add_rtpm_for_validation   M55163C00001  NRPMQAP-9  eq 0  NG_FLOW_SETUP_ATT_TOT_PMQAP
    add_rtpm_for_validation   M55163C00002  NRPMQAP-9  eq 0  NG_FLOW_SETUP_SUCC_PMQAP

    stop rtpm collection interval
    verify_rtpm_counters
    rtpm deactivate

    [Teardown]    Cleanup after test

*** Keywords ***
Prepare test environment
    Log to console    Prepare test environment
    Configure    {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'true'}

Cleanup after test
    Log to console    Cleanup after test
    Configure    {'MOC': 'NRBTS', 'act5qiAndUlNguTnlQosFlowMod': 'true'}
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
