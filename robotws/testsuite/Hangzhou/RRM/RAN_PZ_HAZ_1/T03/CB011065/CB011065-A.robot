*** Settings ***
Documentation
...   author: Xiaofeng Nie
...   contact: xiaofeng.nie@nokia-sbell.com
...   Description: This is CB011065-SR-A ET CRT in TMO configuration
...   Topology: CLOUD_5G_I_LOO_AP_LOOO
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Test Timeout       90 minutes


*** Variables ***
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}
${Ignore_Cell_Id_For_Sib}    5    6    9    12
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}


*** Test Cases ***
CB011065-SR-A_01_intrafreq_XnHO_counter
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to check CB011065-A counters for intra-Freq XnHO
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO_Xn
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    Start tcpdump by command For Remote
    Counter Collection intrafreq for Xn Handover
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=6
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start inter-gNB UE intrafreq XnHO to target sim cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=no_radio_resources_available
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=no_radio_resources_available_in_target_cell
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=transport_resource_unavailable
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=control_processing_overload
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=not_enough_user_plane_processing_resources
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=rSN_not_available_for_the_UP
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=invalid_QoS_combination
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=not_supported_5QI_value
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=slice_not_supported_by_NG_RAN
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=handover_target_not_allowed
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=cell_not_available
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=npn_access_denied
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=o_and_M_intervention
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    sleep    1s
     Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=force_failure cause\=invalid_AMF_Set_ID
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=send_error_indication cause\=off
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB011065

CB011065-SR-A_02_interfreq_NgHO_counter
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to check CB011065-A counters for inter-Freq NgHO
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO_Ng
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    Start tcpdump by command For Remote
    Counter Collection interfreq for Ng Handover
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=6
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=7 phycell_id\=51
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_radio_resources_not_available
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_no_radio_resources_available_in_target_cell
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=TRANSPORT_transport_resource_unavailable
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=MISC_control_processing_overload
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=MISC_not_enough_user_plane_processing_resources
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_RSN_not_available_for_the_UP
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_invalid_qos_combination
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_not_supported_5QI_value
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_slice_not_supported
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_ho_target_not_allowed
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_cell_not_available
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_NPN_access_denied
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=MISC_om_intervention
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
     Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=ho_preparation_failure cause\=RN_unknown_PDU_session_ID
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 reset
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=no_response
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=7 event\=A3 srsrp_nr\=19 phycell_id\=8 nrsrp_nr\=100
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB011065


*** Keywords ***
Counter Collection intrafreq for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00025;
    ...    Counter rule: sum(M55143C00025)==6;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00026;
    ...    Counter rule: sum(M55143C00026)==3;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00027;
    ...    Counter rule: sum(M55143C00027)==4;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00028;
    ...    Counter rule: sum(M55143C00028)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00029;
    ...    Counter rule: sum(M55143C00029)==1;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00030;
    ...    Counter rule: sum(M55143C00030)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Collection interfreq for Ng Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00007;
    ...    Counter rule: sum(M55209C00007)==6;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00008;
    ...    Counter rule: sum(M55209C00008)==3;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00009;
    ...    Counter rule: sum(M55209C00009)==4;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00010;
    ...    Counter rule: sum(M55209C00010)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00011;
    ...    Counter rule: sum(M55209C00011)==1;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00012;
    ...    Counter rule: sum(M55209C00012)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Check CB011065
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Start Capture Emil Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    ${local_file_path}    Log Collection    stop_and_download    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}
