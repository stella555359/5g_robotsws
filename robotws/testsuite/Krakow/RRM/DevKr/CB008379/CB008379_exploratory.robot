*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...         CB008379 exploratory ET
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [24.05.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup

*** Variables ***
${LUA_CFG}=                            ${CURDIR}/config/SA_TDD_1c_1gNBsim.lua

*** Test Cases ***
CB008379-exploratory-1 - try adding two GBRs to one PDU session for one UE and fail
    [Tags]    exploratory_1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test checks that UE can't have two non-VoNR GBRs (e.g. 5QI-3 and 5QI-4) set up at the same time.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'off'
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...
    ...  HISTORY:
    ...     [24.05.2022] - Create Test Case

    Attach UE-1 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE1 PDU1 session QoS flows with 5QI from list [3] and delete QoS flows with 5QI from list []
    Try to add to UE1 PDU1 session QoS flows with 5QI from list [4] and fail with cause=${cause_invalid_qos_combination}

    [Teardown]   Detach and kill UE1


CB008379-exploratory-2 - try adding two GBRs in different PDU sessions for one UE and fail
    [Tags]    exploratory_2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Test checks that UE can't have two non-VoNR GBRs (e.g. 5QI-3 and 5QI-4) set up at the same time in 2 PDU sessions.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'off'
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...
    ...  HISTORY:
    ...     [24.05.2022] - Create Test Case

    Attach UE-1 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE1 PDU1 session QoS flows with 5QI from list [3] and delete QoS flows with 5QI from list []
    Try add to UE1 second PDU session without ICS including 1 nonGBR and 1 GBR 5QI4 QoS flow and fail
    Verify that gNB failed to setup PDU Session for 5QIs with cause=${cause_invalid_qos_combination}

    [Teardown]   Detach and kill UE1


CB008379-exploratory-3 - mismatch between resType for user-defined 5QIs 128 and higher
    [Tags]    exploratory_3
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Check GBR/nonGBR mapping in DevKr/CB008379/config/yaml_config/GBR_5QI_1_2_3_4_71_72_76_128_170_212_254.yaml
    ...  == Info==
    ...  Purpose of this testcase is to show that trying to modify nonGBR 5QI as GBR 5QI should fail.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'off'
    ...  - NRDRB-23.resType = 'nonGBR' (refers to 5QI-170)
    ...  - NRDRB_5QI-14.fiveqiValueList = [170]
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...
    ...  HISTORY:
    ...     [24.05.2022] - Create Test Case

    Set test variable    ${5qi_miscfg_as_GBR}           170

    Attach UE-1 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE1 PDU1 session QoS flows with 5QI from list [${5qi_miscfg_as_GBR}] and delete QoS flows with 5QI from list []
    Run 10Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 5 seconds
    Try to modify existing 5QI${5qi_miscfg_as_GBR} for UE1 initial PDU session by AMF - set DL and UL GFBR to 7700kbps
    Verify that UE-1 PDUSessionResourceModify payload does not have GFBR set

    On failure        Verify 10Mbps UL traffic on UE1 PDU1 QFI2
    Stop 10Mbps UL and DL traffic on UE1 PDU1 QFI2

    [Teardown]   Run keywords
    ...    Detach and kill UE1
    ...    Detach and kill UE2


CB008379-exploratory-4 - doubling GFBR after UE detach should fail UE attach
    [Tags]    exploratory_4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This testcase shows that re-attach of UE to cell with exhausted bandwidth should fail.
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = ~15%
    ...
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...
    ...  == REQUIRED LOGS ==
    ...     NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...
    ...  HISTORY:
    ...     [24.05.2022] - Create Test Case

    [Setup]    Prepare exploratory environment 4

    Set test variable    ${5qi_gbr}     3

    Modify DL and UL GFBR=14000 and MFBR=30000 for 5QI${5qi_gbr}
    Attach UE-2 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE2 PDU1 session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list []
    Run 14Mbps UL and DL traffic on UE2 PDU1 QFI2 and wait 10 seconds
    Verify 14Mbps UL traffic on UE2 PDU1 QFI2
    Detach and kill UE2

    Modify DL and UL GFBR=28000 and MFBR=30000 for 5QI${5qi_gbr}
    Attach UE-1 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE1 PDU1 session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list []
    Run 28Mbps UL and DL traffic on UE1 PDU1 QFI2 and wait 20 seconds
    Verify 28Mbps UL traffic on UE1 PDU1 QFI2

    Try to attach UE2 with 1 nonGBR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}

    [Teardown]   Run keywords
    ...    Detach and kill UE1    AND
    ...    Detach and kill UE2    AND
    ...    Configure  {'MOC': 'NRCELL', 'ID': '1', 'maxGbrTrafficLimit': '90'}


*** Keywords ***
Prepare exploratory environment 4
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'actGBRAdmissionControl': 'GBRService', 'maxGbrTrafficLimit': '15'}

Try to modify existing 5QI${5qi:\d+} for UE${ue_id:\d+} initial PDU session by AMF - set DL and UL GFBR to ${rate:\d+}kbps
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
    Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${rate} gfbr_ul=${rate}
    Sleep  1
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_modify=${QoS_FLOW_ID} by=amf

    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

Verify that UE-${ue_id} PDUSessionResourceModify payload does not have GFBR set
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (guaranteedFlowBitRateDL is not present)
    ...     and
    ...     (guaranteedFlowBitRateUL is not present)
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}
