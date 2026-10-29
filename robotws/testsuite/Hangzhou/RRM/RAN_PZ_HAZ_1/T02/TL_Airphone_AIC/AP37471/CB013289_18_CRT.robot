*** Settings ***
Documentation
...    Author: Sun Shuangfeng
...    Contact: Shuangfeng.f.sun@nokia-sbell.com
...    this file is for CB013289.
...    Please do not modify the file without notification to author

#Suite Setup    Common Suite Setup For AIC
#Suite Teardown     Custom Suite Teardown For AIC
Suite Setup    Airphone Operation    operation=eth_config    product_type=${None}
...    eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/ap_tl248.json

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
#Resource          ../../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource          ../../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${ue_id}    3
@{pdu1_qos_list}  ${3}  ${4}
@{pdu2_qos_list}  ${2}  ${7}
@{pdu3_qos_list}  ${2}  ${7}  ${8}
@{pdu_qos_list}  ${2}
${TL37471_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/APCFG/wts_37471_CB013289.cfg
*** Test Cases ***
Update Local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...                   eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/ap_tl248.json
    ...                   ap_build=${None}
    OperatingSystem.Run    cp ${TL37471_wts} /opt/wts/latest/basic_setup.cfg

CB013289-A#B3_TC18_Successful_Inter-RAT_handover_with_direct_data_forwarding_when_LTE_neighbour_cell_is_discovered_using_ANR
    [Tags]    TC18    RAN_PZ_HAZ_1    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
    [Setup]    Case Precondition
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRANRPRE-2 iRatDataForwardingMethod with directDataFwd
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
#    Start Counter
    ${plane_type}    Create List    uplane
    ${pod_names}    Create List     po-cran12-upue-0    po-cran12-cpif-0
    Run Keyword And Ignore Error    Stop Ip Traffic Capture In vCU    pod_name=po-cran12-upue-0
    Start Ip Traffic Capture In vCU    plane_type=${plane_type}    pod_names=${pod_names}
    SA UE register and PDU setup    ue_id=3    ue_gw=1
    UE PDU Session Modify1    ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
    sleep    10s
    Send A2 Measurement    ue_id=3
    Configure ECGI For ANR    ue_id=3
    Send B2 Measurement And trigger Handover    ue_id=3
    sleep    5s    wait for all data sent
	${wireshark_up_log_path}    Stop Ip Traffic Capture In vCU    pod_name=po-cran12-upue-0
	${wireshark_cp_log_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
#    Collect And Check Counter
    CB013289 AB1 TC18 Check Ponit        wireshark_cp_log_path=${wireshark_cp_log_path}    wireshark_up_log_path=${wireshark_up_log_path}
    [Teardown]    Airphone_TearDown_Cloud

*** Keywords ***
Common Suite Setup For AIC
    Config Iphy Ip For Local Env_248      ap_version=4.0.31311

Case Precondition
    Case Precondition For AP    tag=37471_CB013289    product_type=vdu    operation=env_setup_sa
    sleep    10s

Case Postcondition
    Case Postcondition For AP

Airphone_TearDown_Cloud
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}


SA UE register and PDU setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Log To Console    ${pass_regexp}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s    wait for all data sent
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s    wait for all data sent
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s    wait for all data sent

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

Send Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10

trigger handover to LTE
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1   ${B2_meas_id}=3   ${check}=Successful handover from EXT_ENB-2.3 to ENB-4.1
    Execute Egate Command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    sleep    5s    wait for all data sent
    ${cmd_part1}   set variable    ue_measurement_send_nr id=${ue_id} meas_id=${B2_meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${cmd_part2}   set variable    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}         catenate    ${cmd_part1}   ${cmd_part2}
    Log To Console    execute on wts: ${cmd}
    Execute Egate Command    cmd=${cmd}
    ...    pass_regexp=${check}

trigger handover to 5G
    [Arguments]     ${ue_id}=1    ${check}=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.3 performed   ${target_cell}=3
    ${cmd}  set variable   gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=311:489
    Log To Console    execute on wts: ${cmd}
    Execute Egate Command   cmd=${cmd}    pass_regexp=${check}
    sleep     2s   wait for all data sent

Check CU Counter Update For HO
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C02001;
    ...         Counter rule: max(M55125C02001)>0;
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C02002;
    ...         Counter rule: max(M55125C02002)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C00048;
    ...         Counter rule: max(M55125C00048)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C00049;
    ...         Counter rule: max(M55125C00049)>=1;
    ${rule_list}    Create List    ${rule2}    ${rule1}    ${rule3}    ${rule4}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Active Feature CB013289 On ${interface:(IRATDirectDataFwdOnNg|IRATDirectDataFwdOnXn|IRATDirectDataFwdOnX2|noIRATDirectDataFwd)}
    @{para_list}    Create List    actInterRatHoDirectDlDataFwd
    @{mo_list}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list}    Create List    ${interface}
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Parameter Updated In vCU
    @{para_list}          Create List    actInterRatHoSADlDataForward
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu

Set NRDRB_5QI-${5QI_id:\d+} dataForwarding with ${value:(IRATDataFwd|noIRATDataFwd)}
    @{para_list}    Create List    dataForwarding
    @{mo_list}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDRB_5QI-${5QI_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Set NRADJECELL-${NRADJ_id:\d+} iRatDataForwardingMethod with ${value:(directDataFwd|indirectDataFwd|noDataFwd)}
    @{para_list}    Create List    iRatDataForwardingMethod
    @{mo_list}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJECELL-${NRADJ_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

UE Register And 2PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

UE PDU Session Modify and traffic
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=3 by=amf
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=4 by=amf
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=2 qosflows_to_add=2 by=amf
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=2 qfi=2 trf_id=1 mbps=5 dir=dl seconds=6000s
    sleep    5s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=2 qosflows_to_add=7 by=amf
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=2 qfi=3 trf_id=1 mbps=5 dir=dl seconds=6000s

UE PDU Session Modify1
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 2 and 3, which are pre-configured in
    ...    basic_setup.cfg and necessary for VoNR.
    ...
    ...    | ue_id              | Specified UE ID                                          |
    ...    | pdu                | PDU Session to be modified                               |
    ...    | list qos_flow_list | list of all the used qos_flows that should be added      |
    ...    | by                 | Device type initiating the procedure ue|amf              |
    ...    | pass_regexp        | regexp to pass the KW if found in egate command response |
    ...    | fail_regexp        | regexp to fail the KW if found in egate command response |
    ...
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=QosFlow with QFI
    ${default_qos_list}   Create List   ${3}   ${4}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
        sleep    10s
    END
    sleep    10s

UE PDU Session Setup
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ${cmd1}    Catenate    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd1}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    5s

UE${ue_id:\d+} And PDU Session-${pdu_id:\d+} Gateway-${gw_id:\d+} Setup
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s

CB013289 AB1 TC18 Check Ponit
    [Arguments]    ${wireshark_cp_log_path}    ${wireshark_up_log_path}
    ...            ${first_filter}=s1ap.id == 78
    ...            ${second_filter}=ngap.id == 249
	...            ${third_filter}=e1ap.id == 131
	...            ${fourth_filter}=e1ap.id == 76
	${target_5QI_list}    Create List    5    7
	Check 5QI values setup in wireshark    wireshark_path=${wireshark_cp_log_path}    target_5QI_list=${target_5QI_list}
	Check IRAT message in wireshark    wireshark_path=${wireshark_cp_log_path}
	Check Direct Data Forwarding in HandoverRequired Message    wireshark_path=${wireshark_cp_log_path}    filter=${first_filter}
	Check Direct Data Forwarding in HandoverCommand Message    wireshark_path=${wireshark_cp_log_path}    filter=${second_filter}
    Check GTP Tunnel info in wireshark    wireshark_path=${wireshark_cp_log_path}    filter1=${second_filter}    filter2=${third_filter}
	${Qos_flow_list}    Check Qos flow info in wireshark    wireshark_path=${wireshark_cp_log_path}    filter=${third_filter}
	Check DRB Modify info in wireshark    wireshark_path=${wireshark_cp_log_path}    filter=${third_filter}
	CB013289 Check Direct Data Forwarding By NG interface    wireshark_path=${wireshark_cp_log_path}    filter=${fourth_filter}
    Check End Marker For Qos Flow    wireshark_path=${wireshark_up_log_path}    Qos_flow_list=${Qos_flow_list}

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

Check Direct Data Forwarding in HandoverRequired Message
    [Arguments]    ${wireshark_path}    ${filter}=s1ap.id == 78    ${Num_ERABs_DL_Forwarding_proposed}=2
	${DirectForwardingPathAvailability}=    Run
    ...    tshark -Y "${filter}" -T fields -e ngap.DirectForwardingPathAvailability -r ${wireshark_path}
    Log To Console    DirectForwardingPathAvailability = ${DirectForwardingPathAvailability}
	Should Be Equal    ${DirectForwardingPathAvailability}    0

	${target_ERAB_list}    Create List    0    1
	${ERAB_id}=    Run
    ...    tshark -Y "${filter}" -T fields -e s1ap.e_RAB_ID -r ${wireshark_path}
	${ERAB_id_list}    Split String    ${ERAB_id}    ,
	Log To Console    ERAB_id_list = ${ERAB_id_list}

    FOR    ${ERAB_id_item}    IN    @{target_ERAB_list}
        Should Contain     ${ERAB_id_list}    ${ERAB_id_item}
    END

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

Check Direct Data Forwarding in HandoverCommand Message
    [Arguments]    ${wireshark_path}    ${filter}=ngap.id == 249
	${target_ERAB_list}    Create List    0    1
	${ERAB_id}=    Run
    ...    tshark -Y "${filter}" -T fields -e ngap.e_RAB_ID -r ${wireshark_path}
	${ERAB_id_list}    Split String    ${ERAB_id}    ,
	Log To Console    ERAB_id_list = ${ERAB_id_list}

    FOR    ${ERAB_id_item}    IN    @{target_ERAB_list}
        Should Contain     ${ERAB_id_list}    ${ERAB_id_item}
    END

Check GTP Tunnel info in wireshark
	[Arguments]    ${wireshark_path}    ${filter1}=ngap.id == 59    ${filter2}=e1ap.id == 131
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
	[Arguments]    ${wireshark_path}    ${filter}=e1ap.id == 131
	${Qos_flow_id_e1ap}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.qoS_Flow_Identifier -r ${wireshark_path}
	${Qos_flow_id_e1ap_list}    Split String    ${Qos_flow_id_e1ap}    ,
	Log To Console    Qos_flow_id_e1ap_list = ${Qos_flow_id_e1ap_list}
	${target_Qos_flow_list}    Create List    1    1    2    2
	FOR    ${Qos_flow_id_ngap_item}    IN    @{target_Qos_flow_list}
        Should Contain    ${Qos_flow_id_e1ap_list}    ${Qos_flow_id_ngap_item}
    END
	[Return]   ${Qos_flow_id_e1ap_list}

Check DRB Modify info in wireshark
	[Arguments]    ${wireshark_path}    ${filter}=e1ap.id == 131    ${num_DRB_Modify}=2
	${DRB_id_e1ap}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.dRB_ID -r ${wireshark_path}
	${DRB_id_e1ap_list}    Split String    ${DRB_id_e1ap}    ,
	Log To Console    DRB_id_e1ap_list = ${DRB_id_e1ap_list}
	${length}    Get Length    ${DRB_id_e1ap_list}
	${target_num}    Convert To Integer    ${num_DRB_Modify}
    Should Be Equal    ${length}    ${target_num}

CB013289 Check Direct Data Forwarding By NG interface
    [Arguments]    ${wireshark_path}
    ...            ${filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.RANUEID -r ${wireshark_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Equal    ${ranue_id}    ff98000000000000

CB013289 Check Direct Data Forwarding By X2 interface
    [Arguments]    ${wireshark_path}
    ...            ${filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.RANUEID -r ${wireshark_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Equal    ${ranue_id}    fe00000000000000

CB013289 Check Direct Data Forwarding By XN interface
    [Arguments]    ${wireshark_path}
    ...            ${filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${filter}" -T fields -e e1ap.RANUEID -r ${wireshark_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

Check End Marker For Qos Flow NG
    [Arguments]    ${wireshark_path}    ${Qos_flow_list}    ${filter}=gtp.message == 0xff
	${Qos_flow_id_gtp}=    Run
    ...    tshark -Y "${filter}" -T fields -e gtp.ext_hdr.pdu_ses_con.qos_flow_id -r ${wireshark_path}
	${Qos_flow_id_gtp}    Replace String    ${Qos_flow_id_gtp}    \n    ,
	${Qos_flow_id_gtp_list}    Split String    ${Qos_flow_id_gtp}    ,
	Log To Console    Qos_flow_id_gtp_list = ${Qos_flow_id_gtp_list}

	FOR    ${Qos_flow_item}    IN    @{Qos_flow_list}
        Should Contain    ${Qos_flow_id_gtp_list}    ${Qos_flow_item}
    END

Check End Marker For Qos Flow XN
    [Arguments]    ${wireshark_path}    ${Qos_flow_list}    ${filter}=gtp.message == 0xfe
	${Qos_flow_id_gtp}=    Run
    ...    tshark -Y "${filter}" -T fields -e gtp.ext_hdr.pdu_ses_con.qos_flow_id -r ${wireshark_path}
	${Qos_flow_id_gtp}    Replace String    ${Qos_flow_id_gtp}    \n    ,
	${Qos_flow_id_gtp_list}    Split String    ${Qos_flow_id_gtp}    ,
	Log To Console    Qos_flow_id_gtp_list = ${Qos_flow_id_gtp_list}

	FOR    ${Qos_flow_item}    IN    @{Qos_flow_list}
        Should Contain    ${Qos_flow_id_gtp_list}    ${Qos_flow_item}
    END

Start data traffic on 2 PDU sessions
    [Arguments]   ${ue_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=2 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=3 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=2 qfi=1 trf_id=1 mbps=5 dir=dl
    sleep    5s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=2 qfi=2 trf_id=2 mbps=5 dir=dl

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} Mbps=${traffic_rate}
    sleep    5s

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

Set NRANRPRE-${ANR_id:\d+} iRatDataForwardingMethod with ${value:(directDataFwd|indirectDataFwd|noDataFwd)}
    @{para_list}    Create List    iRatDataForwardingMethod
    @{mo_list}    Create List    MRBTS-37471/NRBTS-37471/NRANRPRE-${ANR_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Send A2 Measurement
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1
    Execute Egate Command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    sleep    5s    wait for all data sent

Configure ECGI For ANR
    [Arguments]  ${ue_id}=1
    ${cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi_eutra anr_cgi_delay=100
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Send B2 Measurement And trigger Handover
    [Arguments]     ${ue_id}=1    ${B2_meas_id}=3
    ${cmd_part1}   set variable    ue_measurement_send_nr id=${ue_id} meas_id=${B2_meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${cmd_part2}   set variable    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}         catenate    ${cmd_part1}   ${cmd_part2}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=Received HandoverNotify
    ...                   timeout=100s

Delete MRBTS-${MRBTS_id:\d+} NRBTS-${NRBTS_id:\d+} NRANRPRE-${ANR_id:\d+} Object
    COAM_Admin.Login
    @{parameter_delta_list}=       create list
    COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRANRPRE-${ANR_id}
    ...    parameter_delta_list=${parameter_delta_list}   operation=delete
    sleep    10s

Start Counter
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55147C01501;
    ...         Counter rule: max(M55147C01501)>=1;
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C02001;
    ...         Counter rule: max(M55125C02001)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C02002;
    ...         Counter rule: max(M55125C02002)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
    ...         Counter: M55125C00048;
    ...         Counter rule: max(M55125C00048)>=1;
    ${rule_list}    Create List    ${rule2}    ${rule1}    ${rule3}    ${rule4}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
