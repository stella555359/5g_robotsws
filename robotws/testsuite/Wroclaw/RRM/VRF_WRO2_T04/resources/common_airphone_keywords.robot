*** Settings ***
Documentation
...   author: Lukasz Klimowicz
...   contact: lukasz.klimowicz@nokia.com

Resource    taf/rfrl/bts/robot/common/gnb_ru.robot
Library      ta5g_cell_operations


*** Keywords ***

Modify PDU By Adding Additional DRB
    [Arguments]    ${ue_id}    ${pdu_id}=3    ${qos_flows}=3    ${timeout}=5
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_flows} by=amf
    ...    timeout=${timeout}

Start Data Traffic
    [Arguments]    ${mbps_list}    ${qfi_id_list}    ${trf_id_list}    ${ue_id}=1   ${pdu_id}=1    ${dir}=dl    ${protocol}=tcp    ${size}=200
    ${traffics_amount}=    Get length    ${trf_id_list}
    FOR    ${index}    IN RANGE    0    ${traffics_amount}
        ${cmd} =    Catenate
        ...    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id_list}[${index}]
        ...    trf_id=${trf_id_list}[${index}]
        ...    dir=${dir} mbps=${mbps_list}[${index}] protocol=${protocol}
        ${cmd} =    Run Keyword If    '${size}' != '200'    Catenate  ${cmd}  size=${size}
        ...    ELSE    Catenate    ${cmd}
        Execute Egate Command    cmd=${cmd}
    END

Release Multiple UEs
    [Arguments]    ${ue_ids}   ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Release UE    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}

Lock And Unlock Cell
    [Arguments]    ${cell_id}
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    parameter=administrativeState    value=Locked
    Wait For Cells Are In Correct State    cell_ids=${cell_id}    search_key=operationalState    cells_status=Disabled
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    parameter=administrativeState    value=Unlocked
    Wait For Cells Are In Correct State    cell_ids=${cell_id}    search_key=operationalState    cells_status=Enabled

Lock And Unlock RMOD And Wait For Cell To Be In Operational State Again
    [Arguments]    ${rmod_id}    ${cell_id}
#    gnb_ru.Reset gNB Radio Unit from GUI    radio_unit_id=${rmod_id}
    gnb_ru.Lock Radio Unit on gNB from GUI    radio_unit_id=${rmod_id}
    BuiltIn.Sleep    30
    gnb_ru.Unlock Radio Unit on gNB from GUI    radio_unit_id=${rmod_id}
    BuiltIn.Sleep    5
    Wait For Cells Are In Correct State    cell_ids=${cell_id}    search_key=operationalState    cells_status=Enabled

Lock And Unlock AMF And Wait For Cell To Be In Operational State Again
    [Arguments]    ${amf_id}    ${cell_id}
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-${amf_id}    parameter=administrativeState    value=Locked
    Wait For Cells Are In Correct State    cell_ids=${cell_id}    search_key=operationalState    cells_status=Disabled
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-${amf_id}    parameter=administrativeState    value=Unlocked
    Wait For Cells Are In Correct State    cell_ids=${cell_id}    search_key=operationalState    cells_status=Enabled
