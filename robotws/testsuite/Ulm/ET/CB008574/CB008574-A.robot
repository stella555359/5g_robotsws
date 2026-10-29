*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description:


Resource            ./CB008574_Keywords.robot

Suite Setup         Setup TL for CB008574
Suite Teardown      CB008574 Teardown

Test Setup          Perform Precondition of Test Scenario


*** Test Cases ***
[1]CB008574_A_B3_RRE_to_target_cell_after_NG_HO_ACK_before_RRC_ReconfigComplete
    [Documentation]    TDD to TDD, Intra-freq NG HO, RRE Request with reason handover failure
    ...                source gnb with CB008140 inter-gNB CA, target gnb CA with CB008311 & 5GC001390
    [Tags]    CRT  B3  B3_1
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=3 crnti=source cause=handoverFailure delay=1000 nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    Start and Stop 850mbps DL for CA Setup and Release
    Stop TCE tracing
    Verify B3_1 PM Counters
    [Teardown]  Perform Postconditions of Test Scenario

[2]CB008574_A_B3_RRE_to_target_cell_after_NG_HO_ACK_before_RRC_ReconfigComplete
    [Documentation]    TDD to FDD, Inter-freq NG HO, RRE Request with reason other failure
    ...                DownlinkRANStatusTransfer is received after RRE Request
    ...                source gnb with CB008140 inter-gNB CA, target gnb with CB008140 inter-gNB CA
    [Tags]    B3  B3_2
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=otherFailure nth=1
    Send Egate Command and verify output   cmd=amf_ran_status_transfer_param id=1 gnb=2 action=delay nth=1 ntimes=1 time_to_wait=1500
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    Wait for delayed NG HO to finish
    Start and Stop 850mbps DL for CA Setup and Release
    Stop TCE tracing
    Verify B3_2 PM Counters
    [Teardown]  Perform Postconditions of Test Scenario

[1]CB008574_A_B4_RRE_to_other_cell_after_NG_HO_ACK_before_RRC_ReconfigComplete
    [Documentation]    FDD to TDD, Intra-freq NG HO, RRE Request with reason handover failure
    ...                RRE to prepared FDD cell
    [Tags]    CRT  B4  B4_1
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=2
    Send NR Measurement Report             ue_id=2  event=A2  carrier_freq=127450
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure delay=1000 nth=1
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    Sleep    2
    Stop TCE tracing
    Verify B4_1 PM Counters
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error                UE Deregister  ue_id=2    AND
    ...    Perform Postconditions of Test Scenario

[2]CB008574_A_B4_RRE_to_other_cell_after_NG_HO_ACK_before_RRC_ReconfigComplete
    [Documentation]    TDD to FDD, Intra-freq NG HO, RRE Request with reason handover failure
    ...                source gnb with intra-gNB CA
    ...                RRE to prepared FDD cell
    [Tags]    B4  B4_2
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=3 crnti=source cause=otherFailure delay=1000 nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    Sleep    2
    Stop TCE tracing
    Verify B4_2 PM Counters
    [Teardown]  Perform Postconditions of Test Scenario

CB008574_A_B9_Online_modification_of_actInterGnbRREPreparedCell_via_NG
    [Documentation]
    [Tags]    B9
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=2
    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=2
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed

    Set actInterGnbRREPreparedCell    gnb_id=${1}    value=false

    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=Initial Context Setup Successful
    Sleep    10    reason=wait for ue context release for UE-2

    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2 cell=2 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=12  carrier_freq=127450
    ...    pass_regexp=Initial Context Setup Successful

    Stop TCE tracing
    Collect PM counters from both gNBs
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error                UE Deregister  ue_id=2        AND
    ...    Perform Postconditions of Test Scenario                                   AND
    ...    Set actInterGnbRREPreparedCell              gnb_id=${1}  value=true

CB008574_A_EC5_Lack_of_RRC_ReestabComplete_during_B3
    [Documentation]
    ...    UE-1 triggers RRE to target cell and doesn't send RRC ReestabComplete, therefore RRE failed and UE is released by target gNB
    ...    UE-2 triggers RRE to prepared cell and doesn't send RRC ReestabComplete, therefore RRE failed and UE is released by target gNB
    [Tags]    EC5
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output   cmd=ue_rrc_reestablish_param id=1 if_contains=any action=drop
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=UE CONTEXT RELEASE REQUEST.*handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output   cmd=ue_rrc_reestablish_param id=2 if_contains=any action=drop
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=UE CONTEXT RELEASE REQUEST.*handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    Stop TCE tracing
    ${_}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-EC_PM}    pm_dir=${pm_files_tgt}   distname_suffix=1
    Verify PM Counter Reference Table  reference_table=${A-EC_PM}    pm_dir=${pm_files_tgt}   distname_suffix=2
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=2    AND
    ...    Perform Postconditions of Test Scenario                           AND
    ...    Run Keyword And Ignore Error            Send Egate Command and verify output  cmd=ue_rrc_reestablish_param id=2 reset

CB008574_A_EC6_Invalid_RRC_ReestabComplete_during_B3
    [Documentation]
    ...    UE-1 triggers RRE to target cell and sends invalid RRC ReestabComplete, therefore RRE failed and UE is released by target gNB
    ...    UE-2 triggers RRE to prepared cell and sends invalid RRC ReestabComplete, therefore RRE failed and UE is released by target gNB
    [Tags]    EC6
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output   cmd=ue_rrc_reestablish_param id=1 if_contains=any action=invalid_tid
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=UE CONTEXT RELEASE REQUEST.*handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output   cmd=ue_rrc_reestablish_param id=2 if_contains=any action=invalid_tid
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=UE CONTEXT RELEASE REQUEST.*handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    Stop TCE tracing
    ${_}  ${pm_files_tgt}   Collect PM counters from both gNBs
    Verify PM Counter Reference Table  reference_table=${A-EC_PM}    pm_dir=${pm_files_tgt}   distname_suffix=1
    Verify PM Counter Reference Table  reference_table=${A-EC_PM}    pm_dir=${pm_files_tgt}   distname_suffix=2
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=2    AND
    ...    Perform Postconditions of Test Scenario                           AND
    ...    Run Keyword And Ignore Error            Send Egate Command and verify output  cmd=ue_rrc_reestablish_param id=2 reset

CB008574_A_EC13_Lack_of_RRC_ReconfigComplete_during_B3
    [Documentation]
    ...    UE-1 triggers RRE to target cell and doesn't send RRC ReconfigurationComplete, therefore RRE failed and UE is released by target gNB
    ...    UE-2 triggers RRE to prepared cell and doesn't send RRC ReconfigurationComplete, therefore RRE failed and UE is released by target gNB
    [Tags]    EC13
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source nth=1 if_contains=any action=drop nth=2
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=Received UE CONTEXT RELEASE REQUEST from GNB-2 handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source nth=1 if_contains=any action=drop nth=2
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=Received UE CONTEXT RELEASE REQUEST from GNB-2 handled successfully    fail_regexp=Received HandoverNotify    timeout=20s

    Stop TCE tracing
    Collect PM counters from both gNBs
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=2    AND
    ...    Perform Postconditions of Test Scenario

CB008574_A_EC14_Invalid_RRC_ReconfigComplete_during_B3
    [Documentation]
    ...    UE-1 triggers RRE to target cell and sends invalid RRC ReconfigurationComplete, therefore RRE failed and UE is released by target gNB
    ...    UE-2 triggers RRE to prepared cell and sends invalid RRC ReconfigurationComplete, therefore RRE failed and UE is released by target gNB
    [Tags]    EC14
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source nth=1 if_contains=any action=invalid_tid nth=2
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=IDLE    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source nth=1 if_contains=any action=invalid_tid nth=2
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=IDLE    fail_regexp=Received HandoverNotify    timeout=20s

    Stop TCE tracing
    Collect PM counters from both gNBs
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=2    AND
    ...    Perform Postconditions of Test Scenario

CB008574_A_EC19_NGAP_DownlinkRANStatusTransfer_timout_or_invalid_content_during_B3
    [Documentation]
    ...    UE-1 triggers RRE to target cell and AMF sends invalid DownlinkRANStatusTransfer, therefore UE is released by target gNB
    ...    UE-2 triggers RRE to prepared cell and AMF sends invalid DownlinkRANStatusTransfer, therefore UE is released by target gNB
    ...    UE-3 triggers RRE to target cell and AMF doesn't send DownlinkRANStatusTransfer, therefore UE is released by target gNB
    ...    UE-4 triggers RRE to prepared cell and AMF doesn't send DownlinkRANStatusTransfer, therefore UE is released by target gNB
    [Tags]    EC19
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output
    ...    cmd=amf_ran_status_transfer_param id=1 gnb=2 action=delay_with_abstract_syntax_error nth=1 ntimes=1 time_to_wait=100
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=(IDLE)|(CONTEXT RELEASE.*successfully)    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output
    ...    cmd=amf_ran_status_transfer_param id=1 gnb=2 action=delay_with_abstract_syntax_error nth=1 ntimes=1 time_to_wait=100
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=(IDLE)|(CONTEXT RELEASE.*successfully)    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=3  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=3  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output
    ...    cmd=amf_ran_status_transfer_param id=1 gnb=3 action=drop nth=1 ntimes=1
    Send NR Measurement Report             ue_id=3  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=(IDLE)|(CONTEXT RELEASE.*successfully)    fail_regexp=Received HandoverNotify    timeout=20s

    UE Attach with VoNR Call and start traffic    ue=4  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=4 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send Egate Command and verify output
    ...    cmd=amf_ran_status_transfer_param id=1 gnb=3 action=drop nth=1 ntimes=1
    Send NR Measurement Report             ue_id=4  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=(IDLE)|(CONTEXT RELEASE.*successfully)    fail_regexp=Received HandoverNotify    timeout=20s

    Stop TCE tracing
    Collect PM counters from both gNBs
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=2    AND
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=3    AND
    ...    Run Keyword And Ignore Error            UE Deregister  ue_id=4    AND
    ...    Perform Postconditions of Test Scenario

[1]CB008574_A_EC4_Unaccepted_RRE_due_to_failure_in_CU_CP_during_B3
    [Documentation]
    ...    UE-1 checks NG HO is taking target resource, therefore RRE failed due to lack of resource
    ...    UE-2 checks prepared cell has maxNumOfNonGBRBearersSA=0, RRE failed due to lack of resource
    [Tags]    EC4  EC4_1
    Start TCE tracing
    Set maxNumOfNonGBRBearersSA    gnb_id=${1}    cell_id=2    value=1
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    UE Attach with VoNR Call and start traffic    ue=2  pdu=1  enb=2  cell=1
    Send NR Measurement Report             ue_id=1  event=A2  carrier_freq=518910
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=22  carrier_freq=127450
    ...    pass_regexp=IDLE    fail_regexp=Received HandoverNotify

    Set maxNumOfNonGBRBearersSA    gnb_id=${1}    cell_id=2    value=0
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=2  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=Initial Context Setup Failure.*RAN radio resources not available    fail_regexp=Received HandoverNotify
    Sleep    2
    Stop TCE tracing
    Verify EC4 PM Counters
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error                UE Deregister  ue_id=2        AND
    ...    Perform Postconditions of Test Scenario                                   AND
    ...    Set maxNumOfNonGBRBearersSA         gnb_id=${1}  cell_id=2  value=550

[3]CB008574_A_EC4_Unaccepted_RRE_due_to_failure_in_CU_CP_during_B3
    [Documentation]
    ...    UE-1 is doing NG HO to target cell, RRE prepared cell supports different SNSSAI, therefore RRE failed and UE in IDLE
    [Tags]    EC4  EC4_3
    [Setup]   Test Setup for EC4_3
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=Initial Context Setup Failure.*with cause RAN slice not supported    fail_regexp=Received HandoverNotify
    Stop TCE tracing
    Verify EC4 PM Counters
    [Teardown]  Test Teardown for EC4_3

[2]CB008574_A_EC4_Unaccepted_RRE_due_to_failure_in_CU_CP_during_B3
    [Documentation]
    ...    UE-1 is doing NG HO to target cell, RRE prepared cell supports different PLMN, therefore RRE failed and UE in IDLE
    [Tags]    EC4  EC4_2
    [Setup]   Test Setup for EC4_2
    Start TCE tracing
    UE Attach with VoNR Call and start traffic    ue=1  pdu=1  enb=2  cell=1
    Send Egate Command and verify output
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=3 cell=4 crnti=source cause=handoverFailure nth=1
    Send NR Measurement Report             ue_id=1  event=A3  meas_values=phycell_id=21  carrier_freq=518910
    ...    pass_regexp=Initial Context Setup Successful    fail_regexp=Received HandoverNotify
    Stop TCE tracing
    Verify EC4 PM Counters
    [Teardown]  Test Teardown for EC4_2
