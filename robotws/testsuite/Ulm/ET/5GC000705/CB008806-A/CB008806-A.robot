*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: NG HO source gNB part
...    Link to Feature Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/
...    15/Doc.aspx?sourcedoc=%7BC8E7B513-C85C-4B5A-9BA4-726D6A9C9732%7D&file=Feature_Test_Strategy_705_ver01.docx&isSPOFile=1&sourceId=&
...    params=%7B%22AppName%22%3A%22Teams-Desktop%22%2C%22AppVersion%22%3A%2227%2F22010300411%22%7D&cid=6025fa04-0090-4b91-beab-d2bf0d7c5fb1
...    UTE Testline Type: CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE


Resource            CB008806-A_Keywords.robot

Suite Setup         Prepare TL for CB008806-A
#Suite Teardown      Sqd65 Common Teardown

Test Teardown       CB008806-A_Keywords.Perform Postconditions of Test Case

*** Test Cases ***

[1]CB008806-A_B3_Successful_Inter-gNB_NG_based_Handover_based_on_A3_A5 measurements_with_indirect_DL_data_forwarding
    [Documentation]   This test case covers 2 instances from B3 and 1 instance from B30:
    ...    1. Successful Intra-frequency Inter-gNB NG based Handover based on A3/A5 measurements with indirect DL data forwarding
    ...    5. Counter updates with CB008200/CB007564 interaction
    ...    B30. Activation of cell trace content on source gNB
    [Tags]    B3  B30  B3_intra_freq  CIT
    [Setup]  Setup for CB008806-A_B3    pcmd=${TRUE}
    Start Logging
    Start Tshark
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Trigger A2 Measurement Report B3_EC10
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC10_B3
    Trigger NG HO intra_freq
    CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC10_B3
    Sleep  5s
    Verify UPLINK RAN STATUS TRANSFER in Cell Trace
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    Verify B3 message sequence
    ${gNB_sw_branch}=    testline.Get gNB SW Branch
    IF    '${gNB_sw_branch}'=='SBTS00' or '${gNB_sw_branch}'=='SBTS25R2'    Verify B3 pmcounters IAF   ${pm_files}
    ...    ELSE    Verify B3 pmcounters IAF   ${pm_files}  trunk_or_25R2_onwards=False
    Verify B3 pmcounters instance 5   ${pm_files}
    UE Deregister

[2]CB008806-A_B3_Successful_Inter-gNB_NG_based_Handover_based_on_A3_A5 measurements_with_indirect_DL_data_forwarding
     [Documentation]    This test case covers 1 instance from B3 and 1 instance from B32:
    ...     2. Successful Inter-frequency Inter-gNB NG based Handover based on A3/A5 measurements with indirect DL data forwarding
    ...     B32. Deactivation of cell trace content on source gNB via actCellTraceReport
    [Tags]    B3  B32  B3_inter_freq  CIT
    [Setup]  Setup for CB008806-A_B3    pcmd=${TRUE}
    Start Logging
    Start Tshark
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Trigger A2 Measurement Report B3_EC10
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B3_EC10}  by=amf
    Disable Cell Tracing
    CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC10_B3
    Trigger NG HO B3_EC10_inter_freq
    CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC10_B3
    Sleep  5s
    Verify UPLINK RAN STATUS TRANSFER not in Cell Trace
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    Verify B3 message sequence
    Verify B3 pmcounters IEF   ${pm_files}
    UE Deregister

[3]CB008806-A_B3_Successful_Inter-gNB_NG_based_Handover_based_on_A3_A5 measurements_with_indirect_DL_data_forwarding
    [Documentation]   alternate scenario instance 3: Source gNB does not receive NGAP: UE CONTEXT RELEASE COMMAND
    [Tags]    B3  B3_alt  CRT
    [Setup]  Setup for CB008806-A_B3
    Apply Config for CB008806-A_B3_alternate_scenario_1
    Start Logging
    get resources taken before_test
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Trigger A2 Measurement Report B3_EC10
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC10_B3
    Trigger NG HO intra_freq
    CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC10_B3
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    Verify B3 pmcounters alternate scenario   ${pm_files}
    get resources taken after_test
    verify resource usage

CB008806_A_B8_Reestablishment_to_source_gNB_during_an_inter-gNB_Ng_based_HO
    [Documentation]   RRC Restablishment causes NG HO failure
    [Tags]    B8  CRT
    [Setup]  Setup for CB008806-A_B3
    Apply Config for CB008806-A_B8
    Start Logging       pmcounter_enabled=${FALSE}
    tcpdump.Start Tcpdump on TestPc         options=-i any    collector=ue1_reestablish
    get resources taken before_test
    UE Register                             ue_id=1           nwslice=1
    Set traffic type                        ue_id=1           pdu_id=1          trf_type=internal
    UE PDU Session Setup                    ue_id=1              pdu=1             gw=1
    Send Egate Command and verify output    ue_meas_cfg_disp id=1    pass_regexp=NR MEASUREMENT IDENTITIES:

    Start data traffic in egate             ue_id=1           pdu=1             direction=dl    trf_id=1    qfi=1    mbps=1
    ...                                     size=1000         protocol=udp
    Set UE for RRC Reestablishment then trigger NG HO
    Verify B8 with pcap trace
    Verify B8 message sequence
    UE Deregister
    Sleep   3s
    get resources taken after_test
    verify resource usage

CB008806_A_B31_Deactivation_of_cell_trace_content_on_source_gNB_via_actIntraNrNgHo
    [Documentation]    Verify there is no NG HO related cell trace content if feature is deactivated
    [Tags]    B31  CRT
    [Setup]  Setup for CB008806-A_B3    pcmd=${TRUE}
    Start Logging    pmcounter_enabled=${FALSE}
    Start Tshark
    get resources taken before_test
    UE Register
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Apply Config for 5GC000705-A_B2
    Trigger A3 Handover B2    meas_id=2
    Verify UPLINK RAN STATUS TRANSFER not in Cell Trace
    UE Deregister
    Sleep   3s
    get resources taken after_test
    verify resource usage

CB008806_A_B4_PDU_Session_Resource_Setup_Release_Modification_during_inter-gNB_Ng_based_Handover_on_source_gNB
    [Documentation]   This test case contains four test instances:
    ...               1. PDU Session Resource Setup during inter-gNB Ng based Handover on source gNB
    ...               2. PDU Session Resource Release during inter-gNB Ng based Handover on source gNB
    ...               3. PDU Session Resource Modification during inter-gNB Ng based Handover on source gNB
    ...               4. NGAP PDU Session management message received after handover preparation phase
    [Tags]    B4  CRT
    [Setup]  Setup for CB008806-A_B3
    Start Logging              pmcounter_enabled=${FALSE}

    Trigger A3 Handover with Concurrent AMF Msg    id=1    amf_msg=ng_pdu_session_setup           action=send_concurrent_msg
    Trigger A3 Handover with Concurrent AMF Msg    id=2    amf_msg=ng_pdu_session_release         action=send_concurrent_msg
    Trigger A3 Handover with Concurrent AMF Msg    id=3    amf_msg=ng_pdu_session_modification    action=send_concurrent_msg
    Trigger A3 Handover with Concurrent AMF Msg    id=4    amf_msg=ng_pdu_session_setup           action=send_concurrent_msg_after_ho_command

    Verify PDU Session Resource Setup during inter-gNB Ng based Handover on source gNB
    Verify PDU Session Resource Release during inter-gNB Ng based Handover on source gNB
    Verify PDU Session Resource Modification during inter-gNB Ng based Handover on source gNB
    Verify NGAP PDU Session management message received after handover preparation phase

CB008806_A_B5_DL_NAS_message_transfer_during_inter-gNB_Ng_based_Handover_on_source_gNB
    [Documentation]   This test case contains two test instances:
    ...               1. DL NAS message transfer during inter-gNB Ng based Handover on source gNB
    ...               2. DL NAS message is received after Handover Command
    [Tags]    B5  CRT
    [Setup]  Setup for CB008806-A_B3
    Start Logging              pmcounter_enabled=${FALSE}

    Trigger A3 Handover with Concurrent AMF Msg    id=1    amf_msg=ng_dl_nas_transport           action=send_concurrent_msg
    Verify B5 RRC DL Information Transfer Message

    Trigger A3 Handover with Concurrent AMF Msg    id=2    amf_msg=ng_dl_nas_transport           action=send_concurrent_msg_after_ho_command

    Verify DL NAS message transfer during inter-gNB Ng based Handover on source gNB
    Verify DL NAS message is received after Handover Command

CB008806_A_EC5_Different_RLC mode_configuration
    [Documentation]   test case covers both instances of EC5
    ...    [1] target gNB has RLC-AM bearer while source gNB has no RLC-AM bearer
    ...    [2] target gNB has no RLC-AM bearer but has RLC_UM bearers for non-GBR while source gNB has RLC-AM bearer
    [Tags]    EC5  CRT
    [Setup]  Setup for CB008806-A_EC5
    Start Logging
    get resources taken before_test
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_EC5}  by=amf
    CB008806-A_Keywords.Start data traffic on PDU session EC5
    Trigger NG HO intra_freq
    CB008806-A_Keywords.Stop data traffic on PDU session EC5
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    Verify EC5
    UE Deregister
    get resources taken after_test
    verify resource usage

[1]CB008806_A_EC10_Inter-gNB_NG_based_Handover_based_on_A3_A5 measurements_without_indirect_DL_data_forwarding
    [Documentation]   Successful Intra-frequency Inter-gNB NG based Handover based on A3/A5 measurements without indirect DL data forwarding
    [Tags]    EC10  EC10_intra_freq  CRT
    [Setup]  Setup for CB008806-A_EC10
    Start Logging
    get resources taken before_test
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Trigger A2 Measurement Report B3_EC10
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC10_B3
    Trigger NG HO intra_freq
    CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC10_B3
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    UE Deregister
    get resources taken after_test
    verify resource usage

[2]CB008806_A_EC10_Inter-gNB_NG_based_Handover_based_on_A3_A5 measurements_without_indirect_DL_data_forwarding
    [Documentation]   Successful Inter-frequency Inter-gNB NG based Handover based on A3/A5 measurements without indirect DL data forwarding
    [Tags]    EC10  EC10_inter_freq  CRT
    [Setup]  Setup for CB008806-A_EC10
    Start Logging
    get resources taken before_test
    UE Register
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Trigger A2 Measurement Report B3_EC10
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B3_EC10}  by=amf
    CB008806-A_Keywords.Start data traffic on 2 PDU sessions EC10_B3
    Trigger NG HO B3_EC10_inter_freq
    CB008806-A_Keywords.Stop data traffic on 2 PDU sessions EC10_B3
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    UE Deregister
    get resources taken after_test
    verify resource usage

[1]CB008806_A_B61_Interworking_with_CB006999_with_successful_Ng_HO_on_source_gNB
    [Documentation]   AMF Status Indication message received during inter-gNB Ng based Handover on source gNB
    [Tags]    B61_1  CRT
    [Setup]  Setup for CB008806-A_B61
    Start Logging  pmcounter_enabled=${FALSE}
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=2   pdu_id=1   trf_type=internal

    Send Egate Command and verify output   ue_nr_rrc_setup_param id=1 registered_amf=311:489|1:2:1
    Send Egate Command and verify output   amf_registration_param id=1 guami_index=1
    get resources taken before_test
    UE Register  ue_id=1
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1

    Send Egate Command and verify output   ue_nr_rrc_setup_param id=2 registered_amf=311:489|1:2:2
    Send Egate Command and verify output   amf_registration_param id=1 guami_index=2
    UE Register  ue_id=2
    UE PDU Session Setup    ue_id=2  pdu=1  gw=2

    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   seconds=20
    Start data traffic in egate   ue_id=2   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   seconds=20
    ${cmd}    Catenate    amf_ue_ng_handover_param id=1 action=send_concurrent_msg msg=amf_status_indication
    ...   timer_guami_removal=on ue=1 backup_amf_index=1
    Send Egate Command and verify output  ${cmd}
    ${cmd}    Catenate    amf_ue_ng_handover_param id=1 action=send_concurrent_msg msg=amf_status_indication
    ...   timer_guami_removal=off ue=2 backup_amf_index=1
    Send Egate Command and verify output  ${cmd}
    Trigger NG HO intra_freq
    Trigger NG HO B61_intra_freq_UE2
    Verify B61_1
    UE Deregister
    get resources taken after_test
    verify resource usage

[2]CB008806_A_B61_Interworking_with_CB006999_with_successful_Ng_HO_on_source_gNB
    [Documentation]   UE TNLA BINDING RELEASE REQUEST message during inter-gNB Ng based Handover on source gNB
    [Tags]    B61_2  CRT
    [Setup]  Setup for CB008806-A_B61
    Start Logging   pmcounter_enabled=${FALSE}
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Send Egate Command and verify output   ue_nr_rrc_setup_param id=1 registered_amf=311:489|1:2:1
    Send Egate Command and verify output   amf_registration_param id=1 guami_index=1
    get resources taken before_test
    UE Register  ue_id=1
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   seconds=20
    Send Egate Command and verify output  amf_ue_ng_handover_param id=1 action=send_concurrent_msg msg=ue_tnla_binding_release_request ue=1
    Trigger NG HO intra_freq
    Verify B61_2
    UE Deregister
    get resources taken after_test
    verify resource usage

CB008806_A_EC1_Handover_preparation_rejection_robustness
    [Documentation]    attach 10 UEs, sending A3 report 100 times for each UE.
    [Tags]    EC1_1_robust  CRT
    [Setup]  Setup for CB008806-A_EC1_robust_mulUEs
    Apply Config for CB008806-A_EC1_robust
    Start Logging
    get resources taken before_test
    Attach 10 UEs with 2 PDU sessions and start DL traffic
    Trigger A3 Handover Radio Resources not available robustness test mul UEs
    Stop Traffic and teardown all UEs
    ${pm_files}=   5GC000705-A_Keywords.Collect PM Counters
    5GC000705-A_Keywords.PM Counter Verification
    ...   counter_files=${pm_files}  counter_names=${EC1_1_PM_COUNTER}   counter_value=1000
    get resources taken after_test
    verify resource usage

CB008806_A_B7_Intra-frequency_inter-gNB_NG_based_Handover_interaction_with_ANR
    [Documentation]    First A3 triggers Objects internal creation, second A3 triggers HO and Objects creation in scf
    [Tags]    B7  CRT
    [Setup]  Setup for CB008806-A_B7
    Start Logging   pmcounter_enabled=${FALSE}
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    UE Register
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   trf_id=1   pdu=1   qfi=1   mbps=1   seconds=20
    Trigger A3 Handover inter gNB B7 HO successful
    5GC000705-A_Keywords.Verify NRREL Object Creation   scf_B7_inter_gNB_verify_2.xml
    UE Deregister

EDA_04087344_Successful_Inter-gNB_NG_based_Handover_with_secondary_plmn
    [Documentation]    This test case verifies successful inter gNB NG Handover based on PR 04087344.
    ...    04087344: [24R1 MP2.1][CBN Henan][Field][5G][FDD][SBTS24R1_ENB_0000_001516_000004][ASIB+ABIO+AHPF]After upgraded to SRAN24R1, the success
    ...    rate of NG-HO in CBN Henan has degraded
    [Tags]    EDA
    [Setup]  Setup for CB008806_A_EDA_04087344 Scenario
    UE Register   ue_id=1
    Set traffic type   ue_id=1  pdu_id=1  trf_type=internal
    UE PDU Session Setup   ue_id=1  pdu=1  gw=1
    Start data traffic in egate   ue_id=1  direction=dl  protocol=udp  pdu=1  qfi=1  mbps=10
    Trigger A3 Handover inter gNB B7 HO successful
    Stop data traffic in egate   ue_id=1  direction=dl
    UE Deregister   ue_id=1
    [Teardown]   Tear Down for CB008806_A_EDA_04087344 Scenario
