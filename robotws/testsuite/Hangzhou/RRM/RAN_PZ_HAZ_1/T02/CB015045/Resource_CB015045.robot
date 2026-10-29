*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${carrier_freq_LTE}    2000

*** Keywords ***
start_log_collection
    [Arguments]  ${log_type}=emil+syslog+cell_trace  ${product_type}=gnb
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start  ${log_type}  product_type=${product_type}  bts_index=${0}  cudu_index=${0}
      ...    dict_argument=${dict_argument}

Trigger EPS Fallback during Initial Context Setup
    [Arguments]  ${ue_id}=1    ${pdu_id}=1    ${cell_id}=1    ${5qi5_qos_flow}=2  ${5qi1_qos_flow}=3    ${call_type}=normal
    log to console  \nSetup PDU session with 5QI5 and 5QI1 QoS flows with ARP 2 for a ${call_type} call
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 reset
    ute_wtssim.Execute Egate Command    cmd=ue_location_change id=1 enb=2 cell=${cell_id}
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi5_qos_flow} priority=2 default=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi1_qos_flow} priority=2
    ute_wtssim.Execute Egate Command    cmd=qosflow_disp id=${5qi5_qos_flow}
    ute_wtssim.Execute Egate Command    cmd=qosflow_disp id=${5qi1_qos_flow}
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=${5qi1_qos_flow}

    Run Keyword If    '${call_type}' == 'normal'    ute_wtssim.Execute Egate Command    cmd=amf_param id=1 voice_fallback=on
    ...    ELSE IF    '${call_type}' == 'emergency'    ute_wtssim.Execute Egate Command
            ...    cmd=amf_param id=1 emergency_service_fallback=on target_cn=epc

    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

    Run Keyword If    '${call_type}' == 'normal'    ute_wtssim.Execute Egate Command
    ...    cmd=ue_register id=${ue_id}    pass_regexp=REGISTRATION COMPLETE
    ...    ELSE IF    '${call_type}' == 'emergency'    ute_wtssim.Execute Egate Command
    ...    cmd=ue_register id=${ue_id} registration_type=EmergencyRegistration withSim=yes    pass_regexp=REGISTRATION COMPLETE

    Run Keyword If    '${call_type}' == 'normal'    ute_wtssim.Execute Egate Command
        ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=1
        ...    pass_regexp=UE${ue_id}: Released PDU session
    ...    ELSE IF    '${call_type}' == 'emergency'    ute_wtssim.Execute Egate Command
        ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=1 request_type=initial-emergency-request
        ...    pass_regexp=UE${ue_id}: Released PDU session

    log to console  \nUE-${ue_id} ${call_type} call EPS fallback triggered!

Trigger EPS Fallback during PDU Session Setup
    [Arguments]      @{ue_id_list}    ${cell_id}=1    ${default_qos_flow}=1    ${5qi5_qos_flow}=2  ${5qi1_qos_flow}=3    ${call_type}=normal
    log to console  \nSetup PDU session 1 with default QoS flow
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 reset
    Run Keyword If    '${call_type}' == 'emergency'    ute_wtssim.Execute Egate Command
        ...    cmd=amf_param id=1 emergency_service_fallback=on target_cn=epc
    ...    ELSE IF    '${call_type}' == 'normal'    ute_wtssim.Execute Egate Command
        ...    cmd=amf_param id=1 voice_fallback=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${default_qos_flow} default=on
    ${pdu_id}    Evaluate    0
    FOR  ${ue_id}  IN  @{ue_id_list}
        ute_wtssim.Execute Egate Command    cmd=ue_location_change id=${ue_id} enb=2 cell=${cell_id}
        ute_wtssim.Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=REGISTRATION COMPLETE
        Sleep    1s    reason=wait for the UE to register
        ${pdu_id}    Evaluate    ${pdu_id} + 1
        ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
            ...    pass_regexp=QoS Routing Table
        Sleep    1s    reason=wait for the UE to setup PDU session
        Send NonGBR Throughput    ue_id=${ue_id}     pdu_id=${pdu_id}
        Sleep    1s    reason=UE Start trf DL Data Service
    END
    log to console  \nPDU session ID is ${pdu_id} for the last UE
    log to console  \nSetup PDU session 2 with 5QI5 and 5QI1 QoS flows with ARP 2 for ${call_type} voice call
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi5_qos_flow} priority=2 default=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi1_qos_flow} priority=2
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=${5qi1_qos_flow}
    FOR  ${ue_id}  IN  @{ue_id_list}
        ${pdu_id}    Evaluate    ${pdu_id} + 1
        ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Run Keyword If    '${call_type}' == 'emergency'    ute_wtssim.Execute Egate Command
            ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id} request_type=initial-emergency-request
            ...    pass_regexp=UE${ue_id}: Released PDU session
        ...    ELSE IF    '${call_type}' == 'normal'    ute_wtssim.Execute Egate Command
            ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
            ...    pass_regexp=UE${ue_id}: Released PDU session
        Sleep    1s    reason=wait for the UE to trigger EPS fallback
    END
    log to console  \nPDU session ID is ${pdu_id} for the last UE
    log to console  \nUE-${ue_id} ${call_type} voice call EPS fallback triggered!

Trigger EPS Fallback during PDU Session Modify Based B1 Measurement
    [Arguments]    @{ue_id_list}    ${cell_id}=1    ${default_qos_flow}=1    ${5qi5_qos_flow}=2  ${5qi1_qos_flow}=3
    log to console  \nSetup PDU session 1 with default QoS flow
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 reset
    ute_wtssim.Execute Egate Command    cmd=amf_param id=1 voice_fallback=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${default_qos_flow} default=on
    ${pdu_id}    Evaluate    0
    FOR  ${ue_id}  IN  @{ue_id_list}
        ute_wtssim.Execute Egate Command    cmd=ue_location_change id=${ue_id} enb=2 cell=${cell_id}
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_register id=${ue_id}
        ...    pass_regexp=REGISTRATION COMPLETE
        Sleep    1s    reason=wait for the UE to register
        ${pdu_id}    Evaluate    ${pdu_id} + 1
        ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
        ...    pass_regexp=QoS Routing Table
        Sleep    1s    reason=wait for the UE to setup PDU session
        Send NonGBR Throughput    ue_id=${ue_id}     pdu_id=${pdu_id}
        Sleep    1s    reason=UE Start trf DL Data Service
    END
    log to console  \nPDU session ID is ${pdu_id} for the last UE
    log to console  \nSetup PDU session 2 with 5QI5 and 5QI1 QoS flows with ARP 2 for normal voice call
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi5_qos_flow} priority=2 default=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=${5qi1_qos_flow} priority=2
    FOR    ${ue_id}  IN  @{ue_id_list}
        ${pdu_id}    Evaluate    ${pdu_id} + 1
        ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
        ...    pass_regexp=QoS Routing Table
        Send NonGBR Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1
        sleep    3s    reason=wait for the throughput test
        ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${5qi1_qos_flow} by=amf
        ...    pass_regexp=${None}
#        ...    pass_regexp=Received UE Context Release Complete from GNB-2
        Sleep    1s    reason=wait for the UE to get B1 measurement id
        Send B1 Measurement    ue_id=${ue_id}
        Sleep    1s    reason=wait for the UE to trigger EPS fallback
    END
    log to console  \nPDU session ID is ${pdu_id} for the last UE
    log to console  \nUE normal voice call EPS fallback triggered!

Trigger EPS Fallback for an Emergency Call with normal voice call established
    [Arguments]  ${ue_id}=1  ${cell_id}=1
    log to console  \nSetup PDU session 1 with default QoS flow
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 reset
    ute_wtssim.Execute Egate Command    cmd=ue_location_change id=1 enb=2 cell=${cell_id}
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=81 pdu=1 trf_type=internal
    Sleep    1s    reason=wait for the UE to register
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_register id=${ue_id}
    ...    pass_regexp=REGISTRATION COMPLETE
    Sleep    1s    reason=wait for the UE to register
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=QoS Routing Table
    Sleep    1s    reason=wait for the UE to setup PDU session
    Send NonGBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    sleep    3s    reason=wait for the throughput test
    log to console  \nSetup PDU session 2 with 5QI5 and 5QI1 QoS flows with ARP 2 for a normal voice call
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=2 default=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=2
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=3
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=81 pdu=2 trf_type=internal
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2
    ...    pass_regexp=QoS Routing Table
    Sleep    1s    reason=wait for the UE to setup PDU session
    Send NonGBR Throughput    ue_id=${ue_id}    pdu_id=2    qfi_id=1
    Send GBR Throughput    ue_id=${ue_id}    pdu_id=2    qfi_id=2
    sleep    3s    reason=wait for the throughput test
    log to console  \nSetup PDU session 3 with 5QI5 and 5QI1 QoS flows with ARP 1 for an emergency call
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=1 default=on
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=1
    ute_wtssim.Execute Egate Command    cmd=smf_param id=1 reset
    ute_wtssim.Execute Egate Command    cmd=amf_param id=1 emergency_service_fallback=on target_cn=epc
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=81 pdu=3 trf_type=internal
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3 request_type=initial-emergency-request
#    ...    pass_regexp=UE${ue_id}: Released PDU session    # for pdu session setup scenario
    ...    pass_regexp=QoS Routing Table
    Send NonGBR Throughput    ue_id=${ue_id}    pdu_id=3    qfi_id=1
    sleep    3s    reason=wait for the throughput test
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=3 qosflows_to_add=3 by=amf
    ...    pass_regexp=Received UE Context Release Complete from GNB-2
    Sleep    1s    reason=wait for the UE to trigger EPS fallback
    log to console  \nUE-${ue_id} emergency call EPS fallback triggered!

Trigger sCell addition
    [Arguments]    ${ue_id}=11
    ${a1_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=520110    event_type=A1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a1_meas_id} event=A1 srsrp_nr=80
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=SCellToAddMod-r15 present in SCG

Send NonGBR Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID_for_cell3}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=1 protocol=udp mbps=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=2 protocol=udp mbps=5
    ...    pass_regexp=UE ${ue_id}: UDP UL

Send GBR Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID_for_cell3}    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=2 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP DL
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=2 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP UL

Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software       /home/ute/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Check EPS Fallback Related Messages
    [Arguments]    ${trace_file}
    ${multi_filters}   catenate   SEPARATOR=    "User data"="DL RRC: rrcRelease, redirect to eutra";
    ...    "ZMQ/SCTP name"="NGAP: UEContextReleaseRequest"
    ${json_file_list}=    Log Analysis   check   emil   ${trace_file}   filter_emil=${multi_filters}
        ...    convert_type=json    product_type=gnb
    ${trace_info_list}    Get trace info from json file    ${json_file_list}
    FOR    ${trace}    IN    @{trace_info_list}
        FOR    ${trace}    IN    @{trace}
            ${User_data}=    Set Variable    ${trace}[User_data]
            ${prefix}  ${record_type}   Split String From Right    ${User_data}    :${SPACE}    1
            ${tmp_info}=    Run Keyword If    '${record_type}' == "rrcRelease, redirect to eutra"
                ...    Check RrcRelease Trace Record    ${trace}
            ...    ELSE IF    '${record_type}' == "radioNetwork (ims-voice-eps-fallback-or-rat-fallback-triggered)"
                ...    Check UEContextReleaseRequest Trace Record    ${trace}
            ...    ELSE IF    '${record_type}' == "radioNetwork (redirection)"
                ...    Check UEContextReleaseRequest Trace Record    ${trace}    cause_value=radioNetwork (redirection)
            ...    ELSE     Log To Console    \nThe value of user data is unexpected!
        END
    END

Get trace info from json file
    [Arguments]    ${file_path}
    ${trace_info_list}    Create List
    FOR    ${file}    IN    @{file_path}
        ${parsed_json}    OperatingSystem.Get File    ${file}
        ${context_dict}    json.Loads    ${parsed_json}
        ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
        Run Keyword If    ${trace_info} != []    Append to list    ${trace_info_list}    ${trace_info}
        ...    ELSE    Log    The trace info is empty
    END
    [Return]    ${trace_info_list}

Check RrcRelease Trace Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[DL-DCCH-Message][message][c1][rrcRelease]
    ${eutraFrequency}=    Set Variable    ${record_data}[criticalExtensions][rrcRelease][redirectedCarrierInfo][eutra][eutraFrequency]
    should be equal as integers    ${eutraFrequency}    2000

Check UEContextReleaseRequest Trace Record
    [Arguments]    ${emil_data}    ${cause_value}=radioNetwork (ims-voice-eps-fallback-or-rat-fallback-triggered)
    ${SCTP_name}=    Set Variable    ${emil_data}[ZMQ_SCTP_name]
    ${User_data}=    Set Variable    ${emil_data}[User_data]
    Should Be Equal    ${SCTP_name}    NGAP: UEContextReleaseRequest
    Should Be Equal    ${User_data}    Cause: ${cause_value}

Send B1 Measurement
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    ${b1_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}
    ...    carrierfreq=${carrier_freq_LTE}    event_type=B1    carrierfreq_rat=EUTRAN
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${b1_meas_id} event=B1
    ...   phycell_id=${phycell_id} nrsrp_nr=78 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=78:30:0
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=Received UE Context Release Complete from GNB-2