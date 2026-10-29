*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008126-SR ET -A B2 Regression using TMO configuration.
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

Test Timeout       60 minutes

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
${parameter}           act5qiAndUlNguTnlQosFlowMod
${dist_name}           MRBTS-1/NRBTS-1

*** Test Cases ***
CB008126-A-B2 TNL modification for single PDU session with GBR and VoNR and nonGBR
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO TMO configuration
    ...    Description:
    ...    This case aims to monitor tunneling IP change.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B4_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Setup VoNR call on the UE =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=5,6 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Trigger tunneling IP modification =============${\n}
    Run Keyword And Ignore Error    Connect To One Site FCT
    Start tcpdump by command For Remote
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 switch_ul_tunnel_endpoint=ip_teid by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Sleep    20s
    Stop tcpdump And download by command For Remote
    Log To Console      ${\n}============= Check WireShark logs =============${\n}
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}

CB008126-A-B22 Failed TNL modification for single PDU with nongbr only with FAF disabled
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO TMO configuration
    ...    Description:
    ...    This case aims to monitor tunneling IP change is failed when CB008126 is disabled.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B4_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Log To Console      ${\n}============= Disable CB008126 =============${\n}
    Disable CB008126
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Trigger tunneling IP modification =============${\n}
    Start tcpdump by command For Remote
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 switch_ul_tunnel_endpoint=ip_teid by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Sleep    20s
    Stop tcpdump And download by command For Remote
    Log To Console      ${\n}============= Check WireShark logs =============${\n}
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Check PDURESOURCEMODIFYFAILRESPONSE In Wireshark Log    ${capture_file_path_source}

CB008126-A-B22 Failed TNL modification followed by outgoing HO
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B22_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Log To Console      ${\n}============= Disable CB008126 =============${\n}
    Disable CB008126
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone Attach    ue_id=1    call_type=SA
    Sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone Start Traffic    mbps=5m
    Sleep    3s
    Airphone Start Traffic    mbps=5m    dir=ul
    Sleep    10s
    Log To Console      ${\n}============= Trigger tunneling IP modification =============${\n}
    Run Keyword And Ignore Error    Connect To One Site FCT
    Start tcpdump by command For Remote
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    switch_ul_tunnel_endpoint=ip_teid by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Sleep    5s
    Log To Console      ${\n}============= Trigger Handover to check tunneling IP in Request message =============${\n}
    Airphone Send Measurement NR    ue_id=1    meas_id=3    phycell_id=7
    Sleep    10s
    Stop tcpdump And download by command For Remote
    Log To Console      ${\n}============= Check WireShark logs =============${\n}
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Check PDUSESSIONSETUP In Wireshark Log    ${capture_file_path_source}

*** Keywords ***
Disable CB008126     #Disable 5QI, UL TNL tunnel IP modification function
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    false
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap.PDUSessionResourceModifyListModRes == 1'
    ...    filter_expression='ngap.TransportLayerAddressIPv4 == 10.0.1.150'
    ...    input_file=${capture_file_path}

Check PDURESOURCEMODIFYFAILRESPONSE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap.PDUSessionResourceFailedToModifyListModRes == 1'
    ...    filter_expression='ngap.radioNetwork == 0'
    ...    input_file=${capture_file_path}

Check PDUSESSIONSETUP In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=xnap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    HandoverRequest
    Should Contain    ${output}    HandoverRequestAcknowledge

    ${output}    Parse Pcap by expressionbackup
    ...    filter='xnap.pduSessionResourcesToBeSetup_List == 1'
    ...    filter_expression='xnap.TransportLayerAddressIPv4 == 10.0.1.1'
    ...    input_file=${capture_file_path}