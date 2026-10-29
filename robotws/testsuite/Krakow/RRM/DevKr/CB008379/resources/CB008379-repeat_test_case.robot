*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008379-common_keywords.robot


*** Keywords ***
# A_b-1a
Repeat ICS with PDU session with nonGBR then modify PDU session with nonGBR and GBR for UE${ue_id_1:\d+}, UE${ue_id_2:\d+} and 5QI${5qi:\d+}
#    Log to console    Testcase A_b-1a, parameterized: UE${ue_id_1}, UE${ue_id_2}, 5QI${5qi}
    Attach UE-${ue_id_1} to gNB2 cell1 with ICS during single PDU session setup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in RRCReconfiguration that UE${ue_id_1} SRB-2 was added

    Add to UE${ue_id_1} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2 and wait 5 seconds

    Attach UE${ue_id_2} without ICS to gNB2 cell1

    Fail adding to UE${ue_id_2} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow
    Verify that AMF1 NGAP InitialContextSetup is rejected due to cause "radio-resources-not-available"

    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2

    # Teardown
    Detach and kill UE${ue_id_1}
    Detach and kill UE${ue_id_2}

# A_b-1b
Repeat ICS with PDU session with 1 nongbr then second PDU session setup with nonGBR and GBR for UE${ue_id:\d+} and 5QI${5qi:\d+}
#    Log to console    Testcase A_b-1b, parameterized: UE${ue_id}, 5QI${5qi}
    Attach UE${ue_id} to gNB2 cell1 with ICS during PDU session setup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added

    Add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Verify that AMF1 NGAP pDUSessionResourceSetup contains 2 QoS Flows
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were added

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds

    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2

    # Teardown
    Detach and kill UE${ue_id}

# A_b-4
Repeat Reactivation of GBR session in ICS without UE capability for UE${ue_id:\d+} and 5QI${5qi_id:\d+}
    Attach UE${ue_id} to gNB2 cell1 without ICS without PDU session
    EXPECT FLOW: AMF1 NGAP initialContextSetup with 1 PDU Sessions
    EXPECT FLOW: UE_${ue_id} NR-RRC UECapabilityEnquiry
    Add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    PASS FLOW: AMF1 NGAP initialContextSetup with 1 PDU Sessions
    PASS FLOW: UE_${ue_id} NR-RRC UECapabilityEnquiry
    Verify that AMF1 NGAP InitialContextSetup does contain 1 PDU session and 2 QoS flows
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Detach and kill UE${ue_id}

# A_b-3
Repeat Reactivation of GBR session in ICS with UE capability - maxNumOfGBRBearersSA check for UE${ue_id:\d+} and 5QI${5qi_id:\d+}
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    Enable including capabilities in ICS for UE${ue_id}
    Wait for UE${ue_id} to enter IDLE state
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    Verify that AMF1 NGAP InitialContextSetup does contain 1 PDU session and 2 QoS flows
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Detach and kill UE${ue_id}

# A_b-2
Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE${ue_id:\d+} and 5QI${5qi_id:\d+}
    Attach UE${ue_id} to gNB2 cell1 with ICS and PDU session setup after ICS
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was added
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was not released
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was not released
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Detach and kill UE${ue_id}

# A_b-5
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi:\d+}: without VoNR, add second nonGBR QoS Flow, add GBR [${5qi_gbr}] flow and release second nonGBR
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list []
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list [6]

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi} and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi}
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Detach and kill UE${ue_id}

# A_b-5
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi:\d+}: with VoNR, add second nonGBR QoS Flow, add GBR [${5qi_gbr}] flow and release second nonGBR
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI1 to gNB2 cell1 with ICS during PDU session setup

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list []
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list [6]

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi} and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi}
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Detach and kill UE${ue_id}

# A_b-6
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi:\d+}: without VoNR, add 2 nonGBR QoS Flows, add GBR [${5qi_gbr}] flow and release 2 nonGBR flows
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6,170] and delete QoS flows with 5QI from list []
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list [6,170]
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi} and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi}
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6,170] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [6,170]
    Detach and kill UE${ue_id}

# A_b-6
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi:\d+}: with VoNR, add 2 nonGBR QoS Flows, add GBR [${5qi_gbr}] flow and release 2 nonGBR flows
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI1 to gNB2 cell1 with ICS during PDU session setup
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6,170] and delete QoS flows with 5QI from list []
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list [6,170]
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi} and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI${qfi}
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [6,170] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [6,170]
    Detach and kill UE${ue_id}

# A_b-7
Repeat UE${ue_id:\d+}: ICS without session, setup nonGBR and GBR [${first_gbr:\d+}], add next GBR [${next_gbr:\d+}] and release first GBR
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${first_gbr} to gNB2 cell1 with ICS without PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${next_gbr}] and delete QoS flows with 5QI from list [${first_gbr}]
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 10 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${next_gbr}]

    Detach and kill UE${ue_id}

# A_b-7
Repeat UE${ue_id:\d+}: ICS without session, setup nonGBR, VoNR and GBR [${first_gbr}], add next GBR [${next_gbr}] and release first GBR
    Attach UE${ue_id} with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${first_gbr} to gNB2 cell1 with ICS without PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${next_gbr}] and delete QoS flows with 5QI from list [${first_gbr}]
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI4 and wait 10 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI4

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${next_gbr}]

    Detach and kill UE${ue_id}

# A_b-8
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+}: ICS with session with nonGBR and GBR [${5qi_gbr:\d+}],release GBR,add GBR,release entire session
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 with ICS during PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2 and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list []

    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1

    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released  # nonGBR default + GBR = 2 DRBs
    Detach and kill UE${ue_id}

# A_b-8
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+}: ICS with session with nonGBR, VoNR and GBR [${5qi_gbr:\d+}],release GBR,add GBR,release entire session
    Attach UE${ue_id} with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 with ICS during PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 1Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2 and wait 1 seconds

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3 and wait 5 seconds
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list []

    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1
    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2

    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 3 DRBs were released  # nonGBR default + VoNR + GBR = 3 DRBs
    Detach and kill UE${ue_id}

#A_g-1
Repeat Feature flag interaction with GBR addition for UE${ue_id:\d+} and 5QI${5qi_id:\d+}
    [Documentation]               Counters pegged in test
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_nongbr>0
    ...                            QFI_SETUP_ATT_nongbr=3
    ...                            QFI_SETUP_SUCC_nongbr=2
    ...                            QFI_REL_nongbr=2
    ...                            QFI_REL_normal_nongbr=0
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_gbr>0
    ...                            QFI_SETUP_ATT_gbr=4
    ...                            QFI_SETUP_SUCC_gbr=2
    ...                            QFI_REL_gbr=2
    ...                            QFI_REL_normal_gbr=0

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and fail with cause=${cause_not_supported_5QI_value}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure   Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_id}]

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Add to UE${ue_id} second PDU session after ICS
    Try to add to UE${ue_id} PDU2 session QoS flows with 5QI from list [${5qi_id}] and fail with cause=${cause_not_supported_5QI_value}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Add to UE${ue_id} PDU2 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Detach and kill UE${ue_id}

#A_g-1-ViNR
Repeat Feature flag interaction with GBR addition for UE${ue_id:\d+} and 5QI2 ViNR
    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue_id} PDU1 session QoS flows with 5QI from list [2] and fail with cause=${cause_invalid_qos_combination}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [2] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [2]

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Add to UE${ue_id} second PDU session after ICS
    Try to add to UE${ue_id} PDU2 session QoS flows with 5QI from list [2] and fail with cause=${cause_invalid_qos_combination}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Add to UE${ue_id} PDU2 session QoS flows with 5QI from list [2] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Detach and kill UE${ue_id}

#A_g-2
Repeat Feature flag interaction with attach with GBR for UE${ue_id:\d+} and 5QI${5qi_id:\d+}
    [Documentation]               Counters pegged in test
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_nongbr>0
    ...                            QFI_SETUP_ATT_nongbr=2
    ...                            QFI_SETUP_SUCC_nongbr=1
    ...                            QFI_REL_nongbr=1
    ...                            QFI_REL_normal_nongbr=0
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_gbr>0
    ...                            QFI_SETUP_ATT_gbr=2
    ...                            QFI_SETUP_SUCC_gbr=1
    ...                            QFI_REL_gbr=1
    ...                            QFI_REL_normal_gbr=0

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Try to attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_id} to gNB2 cell1 and fail with cause=${cause_not_supported_5QI_value}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_id} to gNB2 cell1 with ICS during PDU session setup

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
        #wait until keyword succeeds    2x   30s     Check Mos value and TP
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Detach and kill UE${ue_id}

#A_g-2-ViNR
Repeat Feature flag interaction with attach with GBR for UE${ue_id:\d+} and 5QI2 ViNR
    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  False  bts_id=1
    Try to attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI2 to gNB2 cell1 and fail with cause=${cause_invalid_qos_combination}

    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI2 to gNB2 cell1 with ICS during PDU session setup

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Detach and kill UE${ue_id}

# C_b-1
Repeat UE${ue_id:\d+} PDU${pdu_id:\d+}: ICS with PDU session with GBR [${5qi_gbr:\d+}], add VoNR, delete GBR
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 with ICS during PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2 and wait 1 seconds

    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []
    Run 1Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3 and wait 5 seconds

    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI2
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]

    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI3
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1

    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released  # nonGBR default + VoNR = 2 DRBs
#    Deregister UE${ue_id} and kill if failed
    Detach and kill UE${ue_id}

# C_b-2
Repeat UE${ue_id:\d+}: ICS w/o session, setup session GBR [${5qi_gbr:\d+}], add VoNR in second session, release second session
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 with ICS without PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 1 seconds

    Add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI1 QoS flow
    Run 1Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds
    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2
    Release second PDU session for UE${ue_id}

    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1

    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released  # nonGBR default + GBR = 2 DRBs
#    Deregister UE${ue_id} and kill if failed
    Detach and kill UE${ue_id}

#    ...  ICS w/o session, setup PDU session (default nonGBR + VoNR + GBR), start traffic GBR and VoNR, verify traffic VoNR,
#    ...  delete VoNR, add VoNR, verify traffic GBR, delete GBR,
#    ...  add GBR in second PDU session, start traffic GBR and VoNR, verify traffic GBR and VoNR, release all PDU sessions
# C_b-3
Repeat UE${ue_id:\d+}: ICS w/o session,setup VoNR and GBR [${5qi_gbr:\d+}],delete GBR,add GBR in second session,release sessions
    Attach UE${ue_id} with 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_gbr} to gNB2 cell1 with ICS without PDU session setup
    Run 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds
    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [1]
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []

    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_gbr}]
    Add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow

    Run 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2 and wait 4 seconds
    On failure        Stop and verify 1Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    On failure        Stop and verify 5Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2

    Release first PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released  # nonGBR default + VoNR = 2 DRBs

    Release second PDU session for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were released  # nonGBR default + GBR = 2 DRBs
#    Deregister UE${ue_id} and kill if failed
    Detach and kill UE${ue_id}

#C_b-4
Repeat UE${ue_id:\d+}: ICS w/o session, setup nonGBR+GBR [${old_5qi:\d+}], swap old QoS flows to new nonGBR+GBR [${new_5qi:\d+}] pair
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${old_5qi} to gNB2 cell1 with ICS without PDU session setup

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [6,${new_5qi}] and delete QoS flows with 5QI from list [5,${old_5qi}]

    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI4 and wait 5 seconds
    On failure        Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI3
    On failure        Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI4

    Detach and kill UE${ue_id}

#D_a-1
Repeat Successful intra-gNB inter-cell ${freq_type:intra|inter}-frequency XN Handover with GBR for UE${ue_id:\d+} and 5QI${5qi_gbr:\d+}
    ${freq_type}=    Set Variable  ${freq_type}
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_gbr}] and delete QoS flows with 5QI from list []
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    Perform ${freq_type}-frequency intra-gNB handover from gNB2 cell1 to cell2 for UE${ue_id}
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were added
    On failure        Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    On failure        Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

#D_c-1
Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB${gnb_src} to gNB${gnb_tgt} with 5QI${5qi_gbr} for UE${ue_id:\d+}
    Attach UE${ue_id} with one PDU session and traffic to real gNB then HO to sim gNB${gnb_src} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow
    Perform inter-gNB handover from simulated gNB${gnb_src} to gnb${gnb_tgt} for UE${ue_id} with 5QI${5qi_gbr}
    Verify that handoverRequest message contains pdu session with default and 5QI${5qi_gbr} QoS flow for UE${ue_id}
    Verify data forwarding during successfull XN Handover for UE${ue_id}
    Verify that PathSwitchRequest contains 2 QoS flows for UE${ue_id}
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

#D_c-2
Repeat Successful intra-frequency inter-gnb NG handover from simulated gNB${gnb_src} to gNB${gnb_tgt} with 5QI${5qi_gbr} for UE${ue_id:\d+}
    Attach UE${ue_id} with one PDU session and traffic to real gNB then HO to sim gNB${gnb_src} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow
    UE${ue_id} triggers successful NG HO from simulated_gNB to real_gNB
    Verify that pdu session with default and 5QI${5qi_gbr} QoS flow during NG Handover for UE${ue_id}
    Verify data forwarding during successfull NG Handover for UE${ue_id}
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

#D_c-3
Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB${gnb_src} to gNB${gnb_tgt} with 5QI${5qi_gbr} for UE${ue_id:\d+}
    Attach UE${ue_id} with one PDU session and traffic to real gNB then HO to sim gNB${gnb_src} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow
    UE${ue_id} triggers successful NG HO from simulated_gNB to real_gNB
    Verify that pdu session with default and 5QI${5qi_gbr} QoS flow during NG Handover for UE${ue_id}
    Verify lack of data forwarding during successfull NG Handover for UE${ue_id}
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

# A_f-1
Repeat Successful modification of GBR is sent while only 1 GBR is established for UE${ue_id:\d+} and 5QI${5qi:\d+}
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup

    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session by amf - set DL and UL GFBR to 5000kbps

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    # Teardown
    Execute egate command   cmd=qosflow_modify qos_flow=${5qi} gfbr_dl=6000 gfbr_ul=6000
    Detach and kill UE${ue_id}

# E_a-6
Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs HO to other cell for UE${ue_id:\d+} and 5QI${5qi:\d+}
    Log to console    Testcase E_a-6, parameterized with UE${ue_id}, 5QI${5qi}
    Modify DL and UL GFBR=10000 and MFBR=30000 for 5QI${5qi}

    Log to console    Setting up background UEs...
    # ${background_ues} set in TC setup
    Setup background UEs[${background_ues}] on gNB2 cell1 with DL 20Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test...
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting failure...
    Try add to UE${ue_id} initial PDU session including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail

    Log to console    Freeing bandwidth...
    # Make bandwidth available for UE under test
    Free bandwidth resources by performing intra-gNB HO for background UEs [14,15]

    Log to console    Wait some time for data usage reporting (20s)...
    Sleep  20

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting success...
    Add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Run 20MBps DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds
    Verify 20MBps DL traffic on PDU-2 QFI-2 for UE${ue_id}
    Stop 20MBps UL and DL traffic on UE${ue_id} PDU2 QFI2

    Stop 20Mbps UL and DL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}

#E_a-6 with 3 bg ues
Repeat TDD GBR load reporting-too low UL cap during Flow Addition-background UEs HO to other cell for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[UL]
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[UL]

    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[UL]

    Set for 5QI${5qi} UL GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Attach UE-${ue4} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    Free bandwidth resources by performing intra-gNB HO for background UE${ue2}
    Run keyword and ignore error
    ...             Free bandwidth resources by performing intra-gNB HO for background UE${ue3}
    Sleep    ${wait_until_resources_released}[UL]
    Add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    Run ${traffic_rate}Mbps UL traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue4} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[UL]


# E_a-5
Repeat GBR load reporting-too low DL capacity during QoS Flow Addition-background UEs have GBR released for UE${ue_id:\d+} and 5QI${5qi:\d+}
    Log to console    Testcase E_a-5, parameterized with UE${ue_id}, 5QI${5qi}
    Modify DL and UL GFBR=10000 and MFBR=30000 for 5QI${5qi}

#    ${background_ues} set in TC setup
    Setup background UEs[${background_ues}] on gNB2 cell1 with DL 10Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test...
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting failure...
    Try add to UE${ue_id} initial PDU session including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail

    Free bandwidth resources by releasing 5QI${5qi} in background UEs [13,14]

    Log to console    Wait some time for data reporting (20s)...
    Sleep  20

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting success...
    Add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Run 20Mbps DL traffic on UE${ue_id} PDU2 QFI2 and wait 5 seconds
    Verify 20Mbps DL traffic on PDU-2 QFI-2 for UE${ue_id}
    Stop 20Mbps UL and DL traffic on UE${ue_id} PDU2 QFI2


    Stop 20Mbps UL and DL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}


#E_a-5 3 ues in background
Repeat TDD GBR load reporting-too low DL cap during Flow Addition-background UEs have GBR released for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[DL]

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[DL]

    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[DL]

    Set for 5QI${5qi} DL GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Attach UE-${ue4} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    Free bandwidth resources by releasing 5QI${5qi} in background UE${ue2}
    Run keyword and ignore error
    ...         Free bandwidth resources by releasing 5QI${5qi} in background UE${ue3}
    Sleep    ${wait_until_resources_released}[DL]
    Add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps DL traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue4} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[DL]

#E_a-1
Repeat FDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}
    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-2
Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}
    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-2 3 ues in background
Repeat TDD GBR load reporting-too low DL cap during Qos Flow Addition-background UEs released for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    start_collecting_syslog     prefix=5QI${5qi}_bg1_addition
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    stop collecting syslog
    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[DL]

    start_collecting_syslog     prefix=5QI${5qi}_bg2_addition
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    stop collecting syslog
    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[DL]

    start_collecting_syslog     prefix=5QI${5qi}_bg3_addition
    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    stop collecting syslog
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[DL]

    Set for 5QI${5qi} DL GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Attach UE-${ue4} to gNB2 cell1 with ICS during single PDU session setup
    start_collecting_syslog     prefix=5QI${5qi}_failed_addition
    Try to add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    stop collecting syslog
    Stop ${bg_traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Run keyword and ignore error        Stop ${bg_traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2
    Sleep     2
    Detach and kill UE${ue3}
    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}[DL]
    start_collecting_syslog     prefix=5QI${5qi}_expected_success_addition
    Add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    stop collecting syslog
    Run ${traffic_rate}Mbps DL traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue4} PDU1 QFI2
    Stop ${bg_traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Stop ${bg_traffic_rate}Mbps DL traffic on UE${ue4} PDU1 QFI2
    Sleep       5
    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[DL]




#E_a-3
Repeat FDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}
    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-4
Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}
    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    Run ${traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-4 with 3 bg ues
Repeat TDD GBR load reporting-too low UL cap during Qos Flow Addition-background UEs released for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    start_collecting_syslog     prefix=5QI${5qi}_UL_bg1_addition
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    stop collecting syslog
    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[UL]
    start_collecting_syslog     prefix=5QI${5qi}_UL_bg2_addition
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    stop collecting syslog
    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[UL]

    start_collecting_syslog     prefix=5QI${5qi}_UL_bg3_addition
    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    stop collecting syslog
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[UL]

    Set for 5QI${5qi} UL GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Attach UE-${ue4} to gNB2 cell1 with ICS during single PDU session setup
    start_collecting_syslog     prefix=5QI${5qi}_UL_failed_addition
    Try to add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    stop collecting syslog
    Stop ${bg_traffic_rate}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Run keyword and ignore error        Stop ${bg_traffic_rate}Mbps UL traffic on UE${ue3} PDU1 QFI2
    Sleep     2
    Detach and kill UE${ue3}
    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}[UL]
    start_collecting_syslog     prefix=5QI${5qi}_UL_expected_success_addition
    Add to UE${ue4} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    stop collecting syslog
    Run ${traffic_rate}Mbps UL traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps UL traffic on UE${ue4} PDU1 QFI2
    Stop ${traffic_rate}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Stop ${traffic_rate}Mbps UL traffic on UE${ue4} PDU1 QFI2
    Sleep       5
    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[UL]

#E_a-7
Repeat FDD GBR load reporting-all capacity taken by nonGBR only-Qos flow addition success for UEs: ${ue1:\d+}, ${ue2:\d+} and 5QI${5qi:\d+}
    Attach UE-${ue1} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue1} PDU1 session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list []

    # Downlink
    Run ${E_a_7_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_a_7_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue2} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${E_a_7_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_a_7_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Stop ${E_a_7_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Stop ${E_a_7_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_released}

    # Uplink
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi}]

    Trigger UE${ue1} idle mode exit
    Run ${E_a_7_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_a_7_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Trigger UE${ue2} idle mode exit
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${E_a_7_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_a_7_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2
    Stop ${E_a_7_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Stop ${E_a_7_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2

    Sleep    ${wait_until_resources_released}
    Detach and kill UEs from ${ue1} to ${ue2}

#E_a-8
Repeat FDD GBR load reporting-too low DL capacity during ICS with GBR-background Ues released for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Try to attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}

    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}

    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-8 DL/UL FDD/TDD 3 ues in background
Repeat ${tech} GBR load reporting-too low ${dir} cap during ICS with GBR-background Ues released for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[${dir}]
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[${dir}]

    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[${dir}]

    Set for 5QI${5qi} ${dir} GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Try to attach UE${ue4} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}
    Stop ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2
    Run keyword and ignore error        Stop ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue3} PDU1 QFI2
    Sleep     2
    Detach and kill UE${ue3}
    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}[${dir}]

    Attach UE${ue4} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps ${dir} traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps ${dir} traffic on UE${ue4} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[${dir}]

#E_a-10
Repeat FDD GBR load report-too low DL cap during via a-d ses mod and backgd UEs have GBR rel for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    [Documentation]  This is repeat KW for test: CB008379-E-a_10_FDD GBR load reporting-too low DL capacity during via a-d session modification
    ...              and background UEs have GBR released, each test uses 3 different UEs and another 5QI.

    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue2} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi}]

    Sleep    ${wait_until_resources_released}
    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UEs from ${ue1} to ${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-10 DL/UL FDD/TDD 3 ues in background
Repeat ${tech} GBR load reporting-too low ${dir} cap during via a-d ses mod for UEs: ${ue1},${ue2},${ue3},${ue4} 5QI${5qi:\d+}
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[${dir}]
    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}[${dir}]

    Run keyword and ignore error
    ...    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run keyword and ignore error
    ...    Run ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    Execute egate command  cmd=smf_param id=1 reset
    Sleep    ${wait_until_resources_allocated}[${dir}]

    Set for 5QI${5qi} ${dir} GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps
    Try to attach UE${ue4} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}
    Stop ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue2} PDU1 QFI2
    Run keyword and ignore error        Stop ${bg_traffic_rate}Mbps ${dir} traffic on UE${ue3} PDU1 QFI2
    Sleep     2
    Detach and kill UE${ue3}
    Detach and kill UE${ue2}
    Sleep    ${wait_until_resources_released}[${dir}]

    Attach UE${ue4} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps ${dir} traffic on UE${ue4} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps ${dir} traffic on UE${ue4} PDU1 QFI2

    Detach and kill UE${ue1}
    Detach and kill UE${ue4}
    Sleep    ${wait_until_resources_released}[${dir}]


#E_a-12
Repeat FDD GBR load-not enough DL cap during suc I-RAT incoming HO-addGbrTrafficHo is changed for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+} 5QI${5qi:\d+}
    [Documentation]  This is repeat KW for test: CB008379-E-a_12_TDD GBR load reporting-not enough DL capacity during successful I-RAT incoming
    ...  HO-addGbrTrafficHo is changed, each test uses 3 different UEs and another 5QI.

    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addGbrTrafficHo': '${addGbrTrafficHo_low}'}  # resources not enough for incoming HO

    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Try to attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}

    Perform inter RAT handover to LTE for UE${ue2}
    Verify in NGAP that default nonGBR and 5QI${5qi} QoS flows were requested during interRAT HO for UE${ue2}
    Sleep    ${wait_until_resources_released}

    Attach UE${ue3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup  #background UE
    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Try to perform inter RAT handover from LTE to 5G for UE${ue2} and fail with cause=${cause_radio_resources_not_available}

    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addGbrTrafficHo': '${addGbrTrafficHo_high}'}  # resources enough for incoming HO
    Sleep    ${wait_until_resources_released}

    Perform inter RAT handover from LTE to 5G for UE${ue2}
    Verify in NGAP that default nonGBR and 5QI${5qi} QoS flows were requested during interRAT HO from LTE to 5G for UE${ue2}

    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Stop ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Stop ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Stop ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2

    Detach and kill UEs from ${ue1} to ${ue3}
    Sleep    ${wait_until_resources_released}

#E_a-13
Repeat FDD GBR load reporting-PDU session setup rejected by maxNumOfGBRBearersSA for UEs: ${ue1:\d+}, ${ue2:\d+} and 5QI${5qi:\d+}
    Change eNB parameter value  NRCELL-1.maxNumOfGBRBearersSA  1  bts_id=1
    Attach UE${ue1} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup

    Run 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI1 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI1

    Attach UE-${ue2} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Change eNB parameter value  NRCELL-1.maxNumOfGBRBearersSA  2  bts_id=1
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI1
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI2

    Stop 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue2} PDU1 QFI2

    Sleep    ${wait_until_resources_released}
    Detach and kill UEs from ${ue1} to ${ue2}


#E_a-14
Repeat GBR load reporting (${ue_5qi_mapping}) OK ICS rejected due to maxNumOfGBRBearersSA for UE: ${ue:\d+} with 5QI${5qi:\d+}
    [Documentation]         Counters [Note that specific group depends on received ue_5qi_mapping gbrs used!]
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_nongbr>0
    ...                            QFI_SETUP_ATT_nongbr=6
    ...                            QFI_SETUP_SUCC_nongbr=5
    ...                            QFI_REL_nongbr=5
    ...                            QFI_REL_normal_nongbr=0
    ...
    ...                            AVE_NUMBER_OF_SA_RRC_gbr>0
    ...                            QFI_SETUP_ATT_gbr=6
    ...                            QFI_SETUP_SUCC_gbr=5
    ...                            QFI_REL_gbr=5
    ...                            QFI_REL_normal_gbr=0

    Log to console      Changing maxNumOfGBRBearersSA to 4
    ${ue_5qi_mapping} =         Evaluate    eval("${ue_5qi_mapping}")
    Configure       {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfGBRBearersSA': '4'}
    FOR     ${background_ue}     IN      @{ue_5qi_mapping}
        ${background_ue_5QI}=   Get From Dictionary      ${ue_5qi_mapping}       ${background_ue}
        Log to console      Attaching background UE${background_ue}
        Attach UE${background_ue} with 1 nonGBR and 1 GBR 5QI${background_ue_5QI} to gNB2 cell1 with ICS during PDU session setup
        Run ${traffic_rate}Mbps DL traffic on UE${background_ue} PDU1 QFI2 and wait 5 seconds
        Log to console      Verify background UE${background_ue} traffic over 5QI${background_ue_5QI}
        On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
        ...  Verify ${traffic_rate}Mbps DL traffic on UE${background_ue} PDU1 QFI2
    END
    Log to console      Awaiting stable load reporting
    Sleep    ${wait_until_resources_allocated}
    Log to console      Attaching UT UE - should fail
    Try to attach UE${ue} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}
    #due to lack of resources
    On failure        Detach and kill UE${ue}
    Log to console      Changing maxNumOfGBRBearersSA to 5
    Configure       {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfGBRBearersSA': '5'}
    Log to console      Attaching UT UE - should PASS
    Attach UE${ue} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS during PDU session setup
    Run ${traffic_rate}Mbps DL traffic on UE${ue} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue} PDU1 QFI2
    Stop ${traffic_rate}Mbps DL traffic on UE${ue} PDU1 QFI2
    Detach and kill UE${ue}
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4

#D_d-1
Repeat UE${ue_id:\d+}: Successful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI${5qi:\d+}
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS without PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Perform inter RAT handover to LTE for UE${ue_id}
    Verify in NGAP that default nonGBR and 5QI${5qi} QoS flows were requested during interRAT HO for UE${ue_id}

    Sleep  5    # wait for stable traffic
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#D_d-2
Repeat UE${ue_id:\d+}: Unsuccessful inter-RAT B2 based handover from 5G to LTE with GBR bearer 5QI${5qi:\d+}
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS without PDU session setup

    Set command for handover preparation failure for UE${ue_id}

    Perform unsuccessfull inter RAT handover to LTE due to handover preparation failure for UE${ue_id}
    Verify handover preparation failure during interRAT HO for UE${ue_id}

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Sleep  5    # wait for stable traffic
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On Failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#D_e
Repeat UE${ue_id:\d+}: Successful inter-RAT B2 based handover from LTE to 5G with GBR bearer 5QI${5qi:\d+}
    start_observing_measurements      UE_${ue_id}       technology=5G
    Attach UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 with ICS without PDU session setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 1 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Perform inter RAT handover to LTE for UE${ue_id}
    Verify in NGAP that default nonGBR and 5QI${5qi} QoS flows were requested during interRAT HO for UE${ue_id}
    Sleep  5
    get_active_measurements     UE_${ue_id}         enable_logging=${True}
    Perform inter RAT handover from LTE to 5G for UE${ue_id}
    Verify in NGAP that default nonGBR and 5QI${5qi} QoS flows were requested during interRAT HO from LTE to 5G for UE${ue_id}

    Sleep  5    # wait for stable traffic
    On failure     Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure     Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}
    stop observing measurements  UE_${ue_id}

#E_a-15
Repeat GBR load reporting-incoming HO rejected by maxNumOfGBRBearersSA-PM counters for UE${ue_id_1:\d+}, UE${ue_id_2:\d+} and 5QI${5qi:\d+}
    Log to console    Testcase E_a-15, parameterized with UE${ue_id_1}, UE${ue_id_2} and 5QI${5qi}

    # UE1 - UE under test
    Log to console    Set limit on NRCELL-2.maxNumOfGBRBearersSA to 1 GBR bearer...
    Edit object attributes if other than    NRCELL-2    maxNumOfGBRBearersSA=1
    Discover bts   bts_id=1

    Modify DL and UL GFBR=10000 and MFBR=30000 for 5QI${5qi}

    Attach UE-${ue_id_2} to gNB2 cell2 with ICS during single PDU session setup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions

    Add to UE${ue_id_2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    Run 5Mbps UL and DL traffic on UE${ue_id_2} PDU1 QFI2 and wait 0 seconds

    Log to console    Attaching UE under test to gNB2 cell1...
    Attach UE-${ue_id_1} to gNB2 cell1 with ICS during single PDU session setup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify in RRCReconfiguration that UE${ue_id_1} SRB-2 was added

    Add to UE${ue_id_1} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2 and wait 0 seconds

    Log to console    Sending measurement report from UE under test and expecting no handover...
    Try to perform intra-frequency intra-gNB handover from gNB2 cell1 to cell2 for UE${ue_id_1} and fail

    Log to console    Raising limits on NRCELL-2.maxNumOfGBRBearersSA...
    Edit object attributes if other than    NRCELL-2    maxNumOfGBRBearersSA=10
    Discover bts   bts_id=1

    Log to console    Sending measurement report and expecting successful handover to gNB2 cell2...
    EXPECT FLOW: gNB2 F1AP uEContextModification for HO
    Perform intra-frequency intra-gNB handover from gNB2 cell1 to cell2 for UE${ue_id_1}
    PASS FLOW: gNB2 F1AP uEContextModification for HO

    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2
    On failure        Verify 5Mbps UL and DL traffic on UE${ue_id_2} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id_1} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id_2} PDU1 QFI2
    Detach and kill UE${ue_id_1}
    Detach and kill UE${ue_id_2}

# E_a-9
Repeat GBR load reporting-too low UL capacity during incoming HO with GBR-background UEs released for UE${ue_id} and 5QI${5qi}
    Set test variable   ${src_cell}    1
    Set test variable   ${tgt_cell}    2
    Log to console    Testcase E_a-9, parameterized with UE${ue_id} and 5QI${5qi}, src_cell:${src_cell}, tgt_cell:${tgt_cell}

    Execute egate command    cmd=smf_param id=1 reset
    Modify DL and UL GFBR=17000 and MFBR=30000 for 5QI${5qi}

    # ${background_ues} set in TC setup
    Log to console    Add background UEs...
    Setup background UEs[${background_ues}] on gNB2 cell${tgt_cell} with UL 15Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test and adding 5QI${5qi} QoS flow...
    Attach UE${ue_id} to gNB2 cell${src_cell} with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Log to console    Running traffic...
    Run 20MBps UL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Verify 20MBps UL traffic on PDU-1 QFI-2 for UE${ue_id}

    Log to console    Sending mesurement report for UE${ue_id} and expecting handover failure...
    Try to perform intra-frequency intra-gNB handover from gNB2 cell${src_cell} to cell${tgt_cell} for UE${ue_id} and fail

    Log to console    Freeing resources...
    Free bandwidth resources by detaching background UEs [13,14]
    Sleep  20

    Log to console    Sending mesurement report for UE${ue_id} and expecting handover success...
    Perform intra-frequency intra-gNB handover from gNB2 cell${src_cell} to cell${tgt_cell} for UE${ue_id}

    Verify 20MBps UL traffic on PDU-1 QFI-2 for UE${ue_id}
    Stop 20MBps UL traffic on UE${ue_id} PDU1 QFI2

    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}

#E_a-16
Repeat PDU session setup rejected by too high GFBR -online GFBR change-PM counters for UE${ue_id:\d+} and 5QI${5qi:\d+}
    #info: nidd change [maxDataRateGBRDL and maxDataRateGBRUL] is applied only for new contexts
    Change NIDD parameters DL and UL GFBR=10Mbps for 5QI${5qi}
    Log to console    Attaching UE under test...
    Set for 5QI${5qi} GFBR to 12Mbps and MFBR to 15Mbps
    Attach UE${ue_id_} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting failure...
    Run keyword and continue on failure
    ...    Try add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail
    Verify that gNB failed to setup PDU Session for 5QIs with cause=${cause_radio_resources_not_available}

    Change NIDD parameters DL and UL GFBR=13Mbps for 5QI${5qi}

    Run keyword and continue on failure
    ...    Try add to UE${ue_id} second PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail
    Verify that gNB failed to setup PDU Session for 5QIs with cause=${cause_radio_resources_not_available}
    Detach and kill UE${ue_id}

    Attach UE${ue_id_} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting success...
    Add to UE${ue_id} initial PDU session after ICS
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#E_a-17
Repeat ICS with GBR rejected by too high GFBR and AMF GFBR value change-UE${ue_id:\d+} and 5QI${5qi:\d+}
    Log to console    Attaching UE under test...
    Set for 5QI${5qi} GFBR to 12Mbps and MFBR to 15Mbps

    Attach UE${ue_id} to gNB2 cell1 without ICS without PDU session

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure due to cause radio-resources-not-available

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting failure...
    Run keyword and continue on failure
    ...    Try add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetupFailure due to cause radio-resources-not-available

    Verify that gNB sends InitialContextSetupFailure with cause=${cause_radio_resources_not_available}
    Detach and kill UE${ue_id}
    Set for 5QI${5qi} GFBR to 6Mbps and MFBR to 15Mbps

    Attach UE${ue_id} to gNB2 cell1 without ICS without PDU session

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#E_a-18
Repeat incoming ${freq_type}-frequency HO rejected by too high req GFBR value and online GFBR change for UE${ue1:\d+}, UE${ue2:\d+} and 5QI${5qi:\d+}
    ${freq_type}=    Set Variable  ${freq_type}
    Change NIDD parameters DL and UL GFBR=10Mbps for 5QI${5qi}
    Set for 5QI${5qi} GFBR to 10Mbps and MFBR to 15Mbps
    Log to console    Attaching first UE under test...
    Attach UE${ue1} with one PDU session and traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI${5qi} QoS flow
    Log to console    Trigger HO with 5QI${5qi} QoS flow to UE and expecting success...
    UE${ue1} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI1
    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue1} PDU1 QFI2
    Detach and kill UE${ue1}
    Sleep  5

    Log to console    Attaching second UE under test...
    Attach UE${ue2} with one PDU session and traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI${5qi} QoS flow
    Log to console    Changing GFBR NIDD value...
    Change NIDD parameters DL and UL GFBR=8Mbps for 5QI${5qi}
    Log to console    Trigger HO with 5QI${5qi} QoS flow to UE and expecting failure...
    Run keyword and continue on failure
    ...  Try to perform ${freq_type}-frequency inter-gNB handover from simulated gNB3 to real gNB2 for UE${ue2} and expcet fail
    Detach and kill UE${ue2}

# E_a-11
Repeat GBR load reporting-not enough DL capacity during successful incoming HO-addGbrTrafficHo is changed for UE${ue_id} and 5QI${5qi}
    Set test variable   ${src_cell}    1
    Set test variable   ${tgt_cell}    2
    Log to console    === Testcase E_a-11, parameterized with UE${ue_id} and 5QI${5qi}, src_cell:${src_cell}, tgt_cell:${tgt_cell} ===

    Execute egate command    cmd=smf_param id=1 reset
    Set parameter NRCELL${tgt_cell}.addGbrTrafficHo=0
    Modify DL and UL GFBR=10000 and MFBR=30000 for 5QI${5qi}

    Setup background UEs[${background_ues}] on gNB2 cell${tgt_cell} with DL 10Mbps traffic on 5QI${5qi}

    Log to console    Attaching UE under test and adding 5QI${5qi} QoS flow...
    Attach UE${ue_id} to gNB2 cell${src_cell} with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Run 20MBps DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Verify 20MBps DL traffic on PDU-1 QFI-2 for UE${ue_id}

    Log to console    Waiting for traffic reporting...
    Sleep  20  # Giving more time for traffic reporting to kick in

    Log to console    Sending mesurement report for UE${ue_id} and expecting handover failure...
    Try to perform intra-frequency intra-gNB handover from gNB2 cell${src_cell} to cell${tgt_cell} for UE${ue_id} and fail

    Log to console    Changing extra capacity for incoming handovers...
    Set parameter NRCELL${tgt_cell}.addGbrTrafficHo=10

    Log to console    Sending mesurement report for UE${ue_id} and expecting handover success...
    Perform intra-frequency intra-gNB handover from gNB2 cell${src_cell} to cell${tgt_cell} for UE${ue_id}

    Verify 20MBps DL traffic on PDU-1 QFI-2 for UE${ue_id}
    Stop 20MBps DL traffic on UE${ue_id} PDU1 QFI2

    Stop 15Mbps DL traffic and kill background UEs[${background_ues}]
    Detach and kill UE${ue_id}

# E_d-2
Repeat FDD GBR load reporting-too low DL capacity during PDU session addition-multiple GFBR modified for background UEs for UE${ue_id} and 5QI${5qi}
    Log to console    === Testcase E_d-2, parameterized with UE${ue_id} and 5QI${5qi} ===

    Execute egate command    cmd=smf_param id=1 reset
    Modify DL and UL GFBR=25000 and MFBR=30000 for 5QI${5qi}

    Setup background UEs[${background_ues}] on gNB2 cell1 then batch run DL 7Mbps traffic on 5QI${5qi}
    Log to console    Attaching UE under test and adding 5QI${5qi} QoS flow...
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup

    Log to console    Adding 5QI${5qi} QoS Flow for UE${ue_id} and expecting PDU session modification failure...
    Fail adding to UE${ue_id} second PDU session including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Log to console    Changing GFBR values for background UE...
    Free bandwidth resources by changing UL and DL GFBR to 6000kbit on 5QI${5qi} QoS Flow by amf on background UEs[${bkg_ue_1},${bkg_ue_2}]
    Sleep  2
    Run 5Mbps DL traffic on UE${bkg_ue_1} PDU1 QFI2 and wait 0 seconds
    Run 5Mbps DL traffic on UE${bkg_ue_2} PDU1 QFI2 and wait 0 seconds

    Log to console    Waiting for traffic reporting...
    Sleep  20  # Giving more time for traffic reporting to kick in

    Log to console    Adding 5QI${5qi} QoS Flow for UE${ue_id} and expecting PDU session modification success...
    Modify DL and UL GFBR=24000 and MFBR=30000 for 5QI${5qi}
    ${current_gw_id}     Evaluate    ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}
    Add to UE${ue_id} third PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Run 15Mbps DL traffic on UE${ue_id} PDU3 QFI2 and wait 5 seconds
    Verify 15Mbps DL traffic on PDU-3 QFI-2 for UE${ue_id}
    Stop 15Mbps DL traffic on UE${ue_id} PDU3 QFI2

    Stop 6Mbps DL traffic and kill background UEs[${background_ues}]

    Detach and kill UE${ue_id}

#E_d-3
Repeat Single GBR established DL UL GFBR modification is sent and non-GBR traffic changes accordingly for UEs: ${ue1:\d+} ${ue2:\d+}, 5QI${5qi:\d+}
    [Documentation]  This is repeat KW for test: CB008379-E-d_3 Single GBR established DL and_or UL GFBR modification is sent and non-GBR traffic
    ...  changes accordingly, each test uses 2 different UEs and another 5QI.

    Attach UE-${ue1} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue1} PDU1 session QoS flows with 5QI from list [6] and delete QoS flows with 5QI from list []

    # Downlink
    Run ${E_d_3_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Attach UE-${ue2} to gNB2 cell1 with ICS during single PDU session setup
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${E_d_3_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2
    # Check if non-GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_DL_lower}Mbps DL traffic on UE${ue1} PDU1 QFI2

    Set for UE${ue2} 5QI${5qi} GFBR to ${gfbr_lower}Mbps and MFBR to ${gfbr_lower}Mbps for DL
    Sleep    ${wait_until_resources_released}

    # Check if non-GBR traffic is increased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_DL_higher}Mbps DL traffic on UE${ue1} PDU1 QFI2
    # Check if GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_DL_lower}Mbps DL traffic on UE${ue2} PDU1 QFI2

    Set for UE${ue2} 5QI${5qi} GFBR to ${gfbr_higher}Mbps and MFBR to ${gfbr_higher}Mbps for DL
    Sleep    ${wait_until_resources_released}

    # Check if non-GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_DL_lower}Mbps DL traffic on UE${ue1} PDU1 QFI2
    # Check if GBR traffic is increased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_DL_higher}Mbps DL traffic on UE${ue2} PDU1 QFI2

    Stop ${E_d_3_traffic_nonGBR_DL}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Stop ${E_d_3_traffic_GBR_DL}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_released}

    # Uplink
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [${5qi}]

    Trigger UE${ue1} idle mode exit
    Run ${E_d_3_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    Trigger UE${ue2} idle mode exit
    Add to UE${ue2} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${E_d_3_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2
    # Check if non-GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_UL_lower}Mbps UL traffic on UE${ue1} PDU1 QFI2

    Set for UE${ue2} 5QI${5qi} GFBR to ${gfbr_lower}Mbps and MFBR to ${gfbr_lower}Mbps for UL
    Sleep    ${wait_until_resources_released}

    # Check if non-GBR traffic is increased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_UL_higher}Mbps UL traffic on UE${ue1} PDU1 QFI2
    # Check if GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_UL_lower}Mbps UL traffic on UE${ue2} PDU1 QFI2

    Set for UE${ue2} 5QI${5qi} GFBR to ${gfbr_higher}Mbps and MFBR to ${gfbr_lower}Mbps for UL
    Sleep    ${wait_until_resources_released}

    # Check if non-GBR traffic is decreased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_nonGBR_UL_lower}Mbps UL traffic on UE${ue1} PDU1 QFI2
    # Check if GBR traffic is increased
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${E_d_3_traffic_GBR_DL_higher}Mbps UL traffic on UE${ue2} PDU1 QFI2

    Stop ${E_d_3_traffic_nonGBR_UL}Mbps UL traffic on UE${ue1} PDU1 QFI2
    Stop ${E_d_3_traffic_GBR_UL}Mbps UL traffic on UE${ue2} PDU1 QFI2

    Sleep    ${wait_until_resources_released}
    Detach and kill UEs from ${ue1} to ${ue2}

Repeat ICS without PDU session then PDU sesssion setup, setup and release second 5QI${5qi_id:\d+} for UE${ue_id:\d+} and DRX active
    Attach UE${ue_id} to gNB2 cell1 with ICS and PDU session setup after ICS
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was added
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []
    Verify in RRCReconfiguration that for UE${ue_id} DRX was released
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_id}]
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} common DRX was setup

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1

    Detach and kill UE${ue_id}

Repeat ICS without PDU session then PDU sesssion setup, setup and release VoNR and 5QI${5qi_id:\d+} for UE${ue_id:\d+} and DRX active
    Attach UE${ue_id} to gNB2 cell1 with ICS and PDU session setup after ICS
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was added
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [1] and delete QoS flows with 5QI from list []
    Verify in 1 out of 2 RRCReconfiguration that for UE${ue_id} DRX was released
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} VoNR DRX was setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []
    Verify in RRCReconfiguration that for UE${ue_id} DRX was released
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_id}]
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} VoNR DRX was setup

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [] and delete QoS flows with 5QI from list [1]
    Verify in 1 out of 2 RRCReconfiguration that for UE${ue_id} DRX was released
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} common DRX was setup

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1

    Detach and kill UE${ue_id}

Repeat ICS without PDU session then PDU sesssion setup, setup VoNR and 5QI${5qi_id:\d+}, release VoNR before 5QI for UE${ue_id:\d+} and DRX active
    Attach UE${ue_id} to gNB2 cell1 with ICS and PDU session setup after ICS
    Verify in RRCReconfiguration that UE${ue_id} 1 DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} SRB-2 was added
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [1] and delete QoS flows with 5QI from list []
    Verify in 1 out of 2 RRCReconfiguration that for UE${ue_id} DRX was released
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} VoNR DRX was setup
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi_id}] and delete QoS flows with 5QI from list []
    Verify in RRCReconfiguration that for UE${ue_id} DRX was released
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI3

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [1]
    Verify in RRCReconfiguration that for UE${ue_id} DRX was neither setup nor released

    Add to UE${ue_id} PDU1 session QoS flows with DRX update with 5QI from list [] and delete QoS flows with 5QI from list [${5qi_id}]
    Verify in 2 out of 2 RRCReconfiguration that for UE${ue_id} common DRX was setup

    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    Run Keyword and ignore error        Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1

    Detach and kill UE${ue_id}

#E_b-1
Repeat PDU session setup rejected by too high GFBR and AMF GFBR value change-UE${ue_id:\d+} and 5QI${5qi:\d+}
    Log to console    Attaching UE under test...
    Set for 5QI${5qi} GFBR to 12Mbps and MFBR to 15Mbps
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting failure...
    On failure
    ...    Try add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow and fail
    Verify that gNB failed to setup PDU Session for 5QIs with cause=${cause_radio_resources_not_available}
    Detach and kill UE${ue_id}

    Set for 5QI${5qi} GFBR to 9Mbps and MFBR to 15Mbps

    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session

    Log to console    Adding 5QI${5qi} QoS flow to UE under test and expecting success...
    Add to UE${ue_id} initial PDU session after ICS
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    On failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#E-b_2
GBR not admitted yet-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE${ue_id:\d+} and 5QI${5qi:\d+}
    Set test variable   ${started_traffic}  10

    Log to console    Attaching UE under test...
    Attach UE-${ue_id} to gNB2 cell1 with ICS during single PDU session setup
    Log to console    Adding 5QI${5qi} QoS flow with GFBR DL/UL above maxDataRateGbrDl/Ul and expecting failure...
    Set for 5QI${5qi} GFBR DL to 12000kbps GFBR UL to 12000kbps and MFBR to 15000kbps
    Try to add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}

    Log to console    Adding 5QI${5qi} QoS flow with GFBR DL/UL below maxDataRateGbrDl/Ul and expecting success...
    Set for 5QI${5qi} GFBR DL to 9000kbps GFBR UL to 9000kbps and MFBR to 15000kbps
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Run ${started_traffic}MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run ${started_traffic}MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Log to console    Modification of PDU session with 5QI${5qi} GFBR DL above maxDataRateGbrDl and expecting failure...
    Set for 5QI${5qi} GFBR DL to 15000kbps GFBR UL to 10000kbps and MFBR to 15000kbps
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session and fail with cause=${cause_radio_resources_not_available}

    Log to console    Modification of PDU session with 5QI${5qi} GFBR UL above maxDataRateGbrUl and expecting failure...
    Set for 5QI${5qi} GFBR DL to 10000kbps GFBR UL to 15000kbps and MFBR to 15000kbps
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session and fail with cause=${cause_radio_resources_not_available}

    Log to console    Modification of PDU session with 5QI${5qi} GFBR DL/UL below maxDataRateGbrDl/Ul and expecting success...
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session by amf - set DL and UL GFBR to 10000kbps

    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Stop ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

#E_b-3 addNumOfGBRBearers
Repeat TDD Admission control for maxGBRTrafficLimit and addNumOfGBRBearers with GBR rejected for UEs: ${ue1:\d+} ${ue2:\d+} ${ue3:\d+}, 5QI${5qi:\d+}
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addNumOfGBRBearers': '${E_b_3_addNumOfGBRBearers_low}'}

    Log to console    Attaching first UE under test to real gNB-2, then HO to simGNB-3...
    Attach UE${ue1} with one PDU session without traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI1 QoS flow

    Attach UE${ue2} with 1 nonGBR and 1 GBR 5QI1 to gNB2 cell1 with ICS during PDU session setup  #VoNR
    Run ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2
    Sleep    ${wait_until_resources_allocated}

    # higher addNumOfGBRBearers - it should prevent to add GBR to ue3
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addNumOfGBRBearers': '${E_b_3_addNumOfGBRBearers_high}'}

    Attach UE-${ue3} to gNB2 cell1 with ICS during single PDU session setup
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and fail with cause=${cause_radio_resources_not_available}
    Try to add to UE${ue3} PDU1 session QoS flows with 5QI from list [1] and fail with cause=${cause_radio_resources_not_available}

    Log to console    Trigger HO with 5QI1 QoS flow to UE and expecting success...
    UE${ue1} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement
    Run ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    Stop ${traffic_rate}Mbps DL traffic on UE${ue1} PDU1 QFI2
    #Traffic must be stopped because otherwise even if addNumOfGBRBearers is lower another GBR will not be added due to lack of resources
    Sleep    ${wait_until_resources_released}

    # lower addNumOfGBRBearers - it should allow to add GBR to ue3
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addNumOfGBRBearers': '${E_b_3_addNumOfGBRBearers_low}'}

#    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []
    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2
    Stop ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI2
    Sleep    ${wait_until_resources_released}

    Add to UE${ue3} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list [1]
    Run ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI3 and wait 5 seconds
    On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI3
    Stop ${traffic_rate}Mbps DL traffic on UE${ue3} PDU1 QFI3
    Stop ${traffic_rate}Mbps DL traffic on UE${ue2} PDU1 QFI2

    Detach and kill UEs from ${ue1} to ${ue3}

#E-c_1 new
Repeat Admission control for small BWP UE ${ue_s_1:\d+},${ue_s_2:\d+} and large BWP UE ${ue_l_1:\d+},${ue_l_2:\d+},${ue_l_3:\d+} and 5QI${5qi:\d+}
    Deregister UE${ue_s_1} and kill if failed
    Deregister UE${ue_s_2} and kill if failed
    Deregister UE${ue_l_1} and kill if failed
    Deregister UE${ue_l_2} and kill if failed
    Deregister UE${ue_l_3} and kill if failed

    Log to console      CHECK: small BWP UEs[${ue_s_1},${ue_s_2}], large BWP UEs[${ue_l_1},${ue_l_2},${ue_l_3}], 5QI${5qi}
    Log to console      Change [GFBR, MFBR] to [${gfbr}Mbps, ${mfbr}Mbps] for 5QI${5qi}
    Set for 5QI${5qi} GFBR to ${gfbr}Mbps and MFBR to ${mfbr}Mbps

    Attach background small BWP UE${ue_s_1} to cell1 and run ${bg_trf_small_bwp}Mbps DL traffic on 5QI${5qi} GBR bearer
    Attach background large BWP UE${ue_l_1} to cell1 and run ${bg_trf_large_bwp}Mbps DL traffic on 5QI${5qi} GBR bearer

    Log to console      Awaiting stable load reporting
    sleep  ${wait_until_resources_allocated}


    ${mgfbr_2}=   Remove From List   ${mfgbr_list}   -1
    Log to console      Change [GFBR, MFBR] to [${mgfbr_2}Mbps, ${mgfbr_2}Mbps] for 5QI${5qi}
    Set for 5QI${5qi} GFBR to ${mgfbr_2}Mbps and MFBR to ${mgfbr_2}Mbps

    Log to console      Attaching UT small BWP UE${ue_s_2} - should fail
    Try to attach UE${ue_s_2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}

    Log to console      Attaching UT large BWP UE${ue_l_2} - should PASS
    Attach UE${ue_l_2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 large BWP cell1
    Run ${bg_trf_large_bwp}Mbps DL traffic on UE${ue_l_2} PDU1 QFI2 and wait 5 seconds
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify ${bg_trf_large_bwp}Mbps DL traffic on UE${ue_l_2} PDU1 QFI2

    Log to console      Decreasing small BWP UE${ue_s_1} DL traffic to free resources
    Run ${bg_trf_small_bwp_2}Mbps DL traffic on UE${ue_s_1} PDU1 QFI2 and wait 10 seconds

    Log to console      Attaching UT small BWP UE${ue_s_2} - should PASS
    Attach UE${ue_s_2} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 small BWP cell1
    Run 70Mbps DL traffic on UE${ue_s_2} PDU1 QFI2 and wait 5 seconds
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 70Mbps DL traffic on UE${ue_s_2} PDU1 QFI2

    Log to console      Change [GFBR, MFBR] to [${gfbr_3}Mbps, ${mfbr_3}Mbps] for 5QI${5qi}
    Set for 5QI${5qi} GFBR to ${gfbr_3}Mbps and MFBR to ${mfbr_3}Mbps

    Log to console      Attaching UT large BWP UE${ue_l_3} - should fail
    Try to attach UE${ue_l_3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 cell1 and fail with cause=${cause_radio_resources_not_available}

    Log to console      Decreasing small BWP UE${ue_s_1},${ue_s_2} DL traffic to free resources
    Run 3Mbps DL traffic on UE${ue_s_1} PDU1 QFI2 and wait 0 seconds
    Run 3Mbps DL traffic on UE${ue_s_2} PDU1 QFI2 and wait 10 seconds

    Log to console      Attaching UT large BWP UE${ue_l_3} - should PASS
    Attach UE${ue_l_3} with 1 nonGBR and 1 GBR 5QI${5qi} to gNB2 large BWP cell1
    Run 10Mbps DL traffic on UE${ue_l_3} PDU1 QFI2 and wait 5 seconds
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${wait_until_kw_succ_rep}    ${wait_until_kw_succ_time}
    ...  Verify 10Mbps DL traffic on UE${ue_l_3} PDU1 QFI2

    Log to console      SUCCESS for 5QI${5qi}

    Deregister UE${ue_s_1} and kill if failed
    Deregister UE${ue_s_2} and kill if failed
    Deregister UE${ue_l_1} and kill if failed
    Deregister UE${ue_l_2} and kill if failed
    Deregister UE${ue_l_3} and kill if failed

##E-d_4
GBR already admitted-Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE${ue_id:\d+} and 5QI${5qi:\d+}
    Set test variable   ${started_traffic}  10
    Log to console    Attaching UE with 5QI${5qi} GFBR DL/UL below maxDataRateGbrDl/Ul and expecting success...
    Set for 5QI${5qi} GFBR DL to 10000kbps GFBR UL to 10000kbps and MFBR to 15000kbps
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi} QoS flow

    Run ${started_traffic}MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run ${started_traffic}MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Log to console    Modification of PDU session with 5QI${5qi} GFBR DL above maxDataRateGbrDl and expecting failure...
    Set for 5QI${5qi} GFBR DL to 15000kbps GFBR UL to 10000kbps and MFBR to 15000kbps
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session and fail with cause=${cause_radio_resources_not_available}

    Log to console    Modification of PDU session with 5QI${5qi} GFBR UL above maxDataRateGbrUl and expecting failure...
    Set for 5QI${5qi} GFBR DL to 10000kbps GFBR UL to 15000kbps and MFBR to 15000kbps
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session and fail with cause=${cause_radio_resources_not_available}

    Log to console    Modification of PDU session with 5QI${5qi} GFBR DL/UL below maxDataRateGbrDl/Ul and expecting success...
    Modify existing 5QI${5qi} for UE${ue_id} initial PDU session by amf - set DL and UL GFBR to 10000kbps

    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    On failure   Verify ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Stop ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop ${started_traffic}Mbps UL and DL traffic on UE${ue_id} PDU1 QFI2

    Detach and kill UE${ue_id}

Repeat PDU session modification rejected by too high GFBR and AMF GFBR value change-UE${ue_id:\d+} and 5QI${5qi:\d+}

