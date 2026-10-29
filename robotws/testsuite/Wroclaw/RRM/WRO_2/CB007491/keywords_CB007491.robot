*** Settings ***
Documentation    :copyright: Nokia
...              :authors: andrzej stachowiak
...              :contact: andrzej.stachowiak@nokia.com

*** Keywords ***
Verify Pm Counters
    [Arguments]    ${counter_id_list}    ${counter_name_list}    ${local_moid}    ${pm_counter_file}    ${condition}=1
    ${counters_amount}=    Get length    ${counter_id_list}
    FOR    ${index}    IN RANGE    0    ${counters_amount}
        Verify Any Counters In File
        ...  ${counter_id_list}[${index}]    ${condition}    ${counter_name_list}[${index}]
        ...  local_moid=${local_moid}
        ...  file_path=${pm_counter_file}
    END

Wait For PDU Session Modify Complete
    [Arguments]    ${inactive_timer}
    sleep   ${inactive_timer}

Send Pdu Session Modify And Start VoNR
    [Arguments]    ${ue_id}      ${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    Wait For PDU Session Modify Complete   2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=dl mbps=1 trf_id=1 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=ul mbps=1 trf_id=2 protocol=tcp
    Wait for Traffic to Stabilize    inactive_timer=2
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    Wait For PDU Session Modify Complete    2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=3 dir=dl rtp_codec=amr_12_2 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=3 dir=ul rtp_codec=amr_12_2 trf_id=4
    Wait for Traffic to Stabilize    inactive_timer=5


Trigger A1 Measurement A6
    [Arguments]    ${ue_id}    ${meas_id}    ${Inactive Timer}=5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=90 srsrq_nr=95
    sleep    ${Inactive Timer}

Trigger A6 Measurement
    [Arguments]    ${A6_cmd}
    Execute Egate Command    cmd=ue_measurement_send_nr ${A6_cmd}

Verify Pm Counters HST
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL_P1}    counter_name_list=${COUNTER_NAMEs_PCELL_P1}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}

Start Specific Data UL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=8
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${INDEX} dir=ul mbps=${mbps_per_trf_id}
    END

Start Specific Data DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${mbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=8
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
    END

Trigger A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${SCELL_INDEX}
    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=90 srsrq_nr=95 scell=${SCELL_INDEX} scell_rsrp=5

Set RRC Resume Parameters
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${cmd}
    Execute Egate Command    cmd=${cmd}
    Wait RRC Resume Param    3s
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=resume_request_1 cause=mo_Signalling
    Wait RRC Resume Param    3s

Wait For UE Inactive State
    [Arguments]    ${inactive_timer}
    sleep    ${inactive_timer}

Wait RRC Resume Param
    [Arguments]    ${inactive_timer}
    sleep    ${inactive_timer}

Perform UE Resume
    [Arguments]    ${UE_ID_6CC}    ${SOURCE_CELL_ID}    ${GNB_ID}    ${cmd_ue_resume_configuration}
    ...  ${A1_MEAS_ID}
    Set RRC Resume Parameters    ue_id=${UE_ID_6CC}  cell_id=${SOURCE_CELL_ID}   gnb_id=${GNB_ID}    cmd=${cmd_ue_resume_configuration}
    Wait For UE Inactive State    inactive_timer=128s
    Wait for Traffic to Stabilize    15
    Trigger A1 Measurement A6    ue_id=${UE_ID_6CC}    meas_id=${A1_MEAS_ID}

Perfom HST
    [Arguments]    ${train_cmd}
    Execute Egate Command    cmd=${train_cmd}
