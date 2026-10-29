*** Settings ***
Force Tags

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: CB005876 5G inter-RAT Handover to LTE based on B2 measurements with data forwarding

Resource        ../../resources/Common/ute_workarounds.robot
Resource        ../../resources/Common/testline.robot
Resource        ../../resources/Common/pmcounters.robot
Resource        ../../resources/Common/btslog.robot
Resource        ../../resources/Common/wts_ue.robot
Resource        ../../resources/Common/tcpdump.robot
Resource          CB005876_B1_Keywords.robot
Resource          CB005876_B1_Commissioning.robot


Suite Setup      Run Keywords
...              Sqd65 Common Setup                                                    AND
...              Activate CB005876 B1
Suite Teardown   Sqd65 Common Teardown


*** Variables ***
@{pdu1_qos_list}  ${2}  ${3}
@{pdu2_qos_list}  ${4}

*** Test Cases ***


CB005876_G_Successful_Inter-Rat_handover_based_on_B2_measurements_with_data_forwarding
    [Documentation]
    ...    There are 2 test instances 1. normal scenario (including End Marker) and 2. Data forwarding is not allowed for 5QI-1 and 5QI-2.
    ...    The two test instances have been clubbed into this testcase. PDU Session 1 has QoS flows with 5qi=5,1,2. As per test instance 2,
    ...    data forwarding will not happen for flows with 5qi=1,2. Only flow with 5qi=5 will be be forwarded. PDU Session 2 has QoS flows
    ...    with 5qi=5,6. So both flows will be forwarded as per test instance 1.
    [Setup]    Perform Preconditions of Testcase
    Start Logging
    UE Register   ue_id=1  nwslice=all
    Set traffic type   ue_id=1   pdu_id=1   trf_type=internal
    Set traffic type   ue_id=1   pdu_id=2   trf_type=internal
    UE PDU Session Setup   ue_id=1  pdu=1  gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf  # forwarding will not be allowed for 2 QoS flows
    UE PDU Session Setup   ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list}  by=amf
    Start data traffic on 2 PDU sessions
    Trigger inter-RAT Handover
    Wait until the current Measurement Period stops
    Collect and verify PM counters
    [Teardown]    Perform Postconditions of Testcase


*** Keywords ***


Perform Preconditions of Testcase
    Prepare WTS Config
    Bring Airphone TL to on Air status     cfg_file=basic_setup_5876_new.cfg   force_cu_type=SA
    Send Egate Command and verify output   amf_timer T_Local=1000
    Send Egate Command and verify output   amf_timer T_NotifyProcessing=500
    Send Egate Command and verify output   upf_param id=1 end_markers_delay=500

Perform Postconditions of Testcase
    Stop data traffic on 2 PDU sessions
    Stop Logging
