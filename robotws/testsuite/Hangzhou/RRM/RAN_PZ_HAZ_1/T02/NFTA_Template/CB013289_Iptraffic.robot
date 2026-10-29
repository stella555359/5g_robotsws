*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot


*** Variables ***
${wireshark_cp_log_path}    /home/ute/debuglogs/CB013289_ST_20240919110735/10.107.123.2_cran13_20240919111215.pcap
${wireshark_up_log_path}    /home/ute/debuglogs/gNB_vCU_11071_po-cran13-upue-0_20240919T111133.pcap.gz

*** Test Cases ***
CB013289-A#B2_TC09_Successful_IRAT_ handover_with_indirect_data_forwarding
    [Tags]    CRT    TC09
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal For TL11071 Cell4
    Parameter Updated In vCU For CB013289
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=0    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0    capabilities=samsung
	${plane_type}    Create List    uplane
	${pod_names}    Create List     po-cran13-upue-0    po-cran13-cpif-0
	Start Ip Traffic Capture In vCU    plane_type=${plane_type}    pod_names=${pod_names}
	Trigger A2 By Modify PA Signal
    Trigger B2 By Modify PA Signal
	Sleep    10s
	Check VONR Call Status after HO
	Stop VONR Call For UE    ue_index=0
	${wireshark_up_log_path}    Stop Ip Traffic Capture In vCU    pod_name=po-cran13-upue-0
    ${wireshark_cp_log_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log For CB013289    wireshark_path=${wireshark_cp_log_path}    uplane_log_path=${wireshark_up_log_path}
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In vCU For CB013289
    @{para_list}          Create List    actInterRatHoSADlDataForward    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod    dataForwarding
	...                                  dataForwarding    dataForwarding    dataForwarding    dataForwarding
    @{mo_list_vcu}        Create List    MRBTS-11071/NRBTS-11071    MRBTS-11071/NRBTS-11071    MRBTS-11071/NRBTS-11071/NRADJECELL-1
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-1    MRBTS-11071/NRBTS-11071/NRDRB_5QI-2
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-5    MRBTS-11071/NRBTS-11071/NRDRB_5QI-7
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-9
    @{value_list_true}    Create List    true    IRATDirectDataFwdOnX2    indirectDataFwd    IRATDataFwd
	...                                  IRATDataFwd    IRATDataFwd    IRATDataFwd    IRATDataFwd
	Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

Trigger A2 By Modify PA Signal
    ${source_pa_port_list}     Create List     10    12
    ${source_pa_value_list}    Create List     0    25
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${5}

Trigger B2 By Modify PA Signal
    ${source_pa_port_list}     Create List     16
    ${source_pa_value_list}    Create List     120    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${60}

Initialize PA Signal For TL11071 Cell4
	SetInitializePAValue    pa_port=1-9;10;11;12;13-16;    pa_value=120;0;120;0;120;

Check VONR Call Status after HO
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status after HO***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Check Wireshark Log For CB013289
    [Arguments]    ${wireshark_path}    ${uplane_log_path}
	${target_5QI_list}    Create List    5    7    1
	Check 5QI values setup in wireshark    wireshark_path=${wireshark_path}    target_5QI_list=${target_5QI_list}
	Check IRAT message in wireshark    wireshark_path=${wireshark_path}
	Check DL Forwarding in HandoverRequired Message    wireshark_path=${wireshark_path}
	Check GTP Tunnel info in wireshark    wireshark_path=${wireshark_path}
	${Qos_flow_list}    Check Qos flow info in wireshark    wireshark_path=${wireshark_path}
	Check DRB Modify info in wireshark    wireshark_path=${wireshark_path}
	Check End Marker For Qos Flow    wireshark_path=${uplane_log_path}    Qos_flow_list=${Qos_flow_list}


Check IRAT message in wireshark
	[Arguments]    ${wireshark_path}
    &{analysis_dict}       Create Dictionary    filter_conditions=ngap.HandoverType == 1 || ngap.radioNetwork == 2
    ${expect_message1}=    Set Variable    HandoverRequired
	${expect_message2}=    Set Variable    HandoverCommand
	${expect_message3}=    Set Variable    UEContextReleaseCommand
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message1}
	Should Contain    ${result}    ${expect_message2}
	Should Contain    ${result}    ${expect_message3}

Check 5QI values setup in wireshark
	[Arguments]    ${wireshark_path}    ${target_5QI_list}    ${filter}=ngap.qosCharacteristics == 0
	${FiveQI}=    Run
    ...    tshark -Y "${filter}" -T fields -e ngap.fiveQI -r ${wireshark_path}
	${FiveQI}    Replace String    ${FiveQI}    \n    ,
	${FiveQI_list}    Split String    ${FiveQI}    ,
    Log To Console    FiveQI_list = ${FiveQI_list}
	FOR    ${FiveQI_id}    IN    @{target_5QI_list}
        Should Contain    ${FiveQI_list}    ${FiveQI_id}
    END

Check DL Forwarding in HandoverRequired Message
	[Arguments]    ${wireshark_path}    ${filter}=s1ap.id == 78    ${Num_ERABs_DL_Forwarding_proposed}=3
	${dL_Forwarding}=    Run
    ...    tshark -Y "${filter}" -T fields -e s1ap.dL_Forwarding -r ${wireshark_path}
	${dL_Forwarding_list}    Split String    ${dL_Forwarding}    ,
	Log To Console    dL_Forwarding_list = ${dL_Forwarding_list}
    ${length}    Get Length    ${dL_Forwarding_list}
	${target_num}    Convert To Integer    ${Num_ERABs_DL_Forwarding_proposed}
    Should Be Equal    ${length}    ${target_num}
    FOR    ${dL_Forwarding_item}    IN    @{dL_Forwarding_list}
        Should Be Equal    ${dL_Forwarding_item}    0
    END

Check GTP Tunnel info in wireshark
	[Arguments]    ${wireshark_path}    ${filter1}=ngap.id == 59    ${filter2}=e1ap.id == 76
    ${gTP_TEID_ngap}=    Run
    ...    tshark -Y "${filter1}" -T fields -e ngap.gTP_TEID -r ${wireshark_path}
	${gTP_TEID_ngap_list}    Split String    ${gTP_TEID_ngap}    ,
	Log To Console    gTP_TEID_ngap_list = ${gTP_TEID_ngap_list}

	${transportLayerAddress_ngap}=    Run
    ...    tshark -Y "${filter1}" -T fields -e ngap.TransportLayerAddressIPv4 -r ${wireshark_path}
	${transportLayerAddress_ngap_list}    Split String    ${transportLayerAddress_ngap}    ,
	Log To Console    transportLayerAddress_ngap_list = ${transportLayerAddress_ngap_list}

	${gTP_TEID_e1ap}=    Run
    ...    tshark -Y "${filter2}" -T fields -e e1ap.gTP_TEID -r ${wireshark_path}
	${gTP_TEID_e1ap_list}    Split String    ${gTP_TEID_e1ap}    ,
	Log To Console    gTP_TEID_e1ap_list = ${gTP_TEID_e1ap_list}

	${transportLayerAddress_e1ap}=    Run
    ...    tshark -Y "${filter2}" -T fields -e e1ap.transportLayerAddressIPv4 -r ${wireshark_path}
	${transportLayerAddress_e1ap_list}    Split String    ${transportLayerAddress_e1ap}    ,
	Log To Console    transportLayerAddress_e1ap_list = ${transportLayerAddress_e1ap_list}

	FOR    ${gTP_TEID_ngap_item}    IN    @{gTP_TEID_ngap_list}
        Should Contain    ${gTP_TEID_e1ap_list}    ${gTP_TEID_ngap_item}
    END

	FOR    ${transportLayerAddress_ngap_item}    IN   @{transportLayerAddress_ngap_list}
        Should Contain    ${transportLayerAddress_e1ap_list}    ${transportLayerAddress_ngap_item}
    END


Check Qos flow info in wireshark
	[Arguments]    ${wireshark_path}    ${filter1}=ngap.id == 59    ${filter2}=e1ap.id == 76
	${Qos_flow_id_ngap}=    Run
    ...    tshark -Y "${filter1}" -T fields -e ngap.qosFlowIdentifier -r ${wireshark_path}
	${Qos_flow_id_ngap_list}    Split String    ${Qos_flow_id_ngap}    ,
	Log To Console    Qos_flow_id_ngap_list = ${Qos_flow_id_ngap_list}

	${Qos_flow_id_e1ap}=    Run
    ...    tshark -Y "${filter2}" -T fields -e e1ap.qoS_Flow_Identifier -r ${wireshark_path}
	${Qos_flow_id_e1ap_list}    Split String    ${Qos_flow_id_e1ap}    ,
	Log To Console    Qos_flow_id_e1ap_list = ${Qos_flow_id_e1ap_list}

	FOR    ${Qos_flow_id_ngap_item}    IN    @{Qos_flow_id_ngap_list}
        Should Contain    ${Qos_flow_id_e1ap_list}    ${Qos_flow_id_ngap_item}
    END
	[Return]   ${Qos_flow_id_e1ap_list}

Check DRB Modify info in wireshark
    [Arguments]    ${wireshark_path}    ${filter}=e1ap.id == 76    ${num_DRB_Modify}=3
	${DRB_id_e1ap}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.dRB_ID -r ${wireshark_path}
	${DRB_id_e1ap_list}    Split String    ${DRB_id_e1ap}    ,
	Log To Console    DRB_id_e1ap_list = ${DRB_id_e1ap_list}
	${length}    Get Length    ${DRB_id_e1ap_list}
	${target_num}    Convert To Integer    ${num_DRB_Modify}
    Should Be Equal    ${length}    ${target_num}

Check End Marker For Qos Flow
    [Arguments]    ${wireshark_path}    ${Qos_flow_list}    ${filter}=gtp.message == 0xfe
	${Qos_flow_id_gtp}=    Run
    ...    tshark -Y "${filter}" -T fields -e gtp.ext_hdr.pdu_ses_con.qos_flow_id -r ${wireshark_path}
	${Qos_flow_id_gtp}    Replace String    ${Qos_flow_id_gtp}    \n    ,
	${Qos_flow_id_gtp_list}    Split String    ${Qos_flow_id_gtp}    ,
	Log To Console    Qos_flow_id_gtp_list = ${Qos_flow_id_gtp_list}

	FOR    ${Qos_flow_item}    IN    @{Qos_flow_list}
        Should Contain    ${Qos_flow_id_gtp_list}    ${Qos_flow_item}
    END


Start Counter For CB013289
    ${rule}    Catenate
        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
        ...         Counter: M55125C02001,M55125C02002;
        ...         Counter rule: max(M55125C02001)>=0 and max(M55125C02002)>=0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
