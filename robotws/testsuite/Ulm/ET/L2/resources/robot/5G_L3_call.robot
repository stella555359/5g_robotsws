*** Settings ***
Documentation  This File containes Keywords that are required for the 5G L3 call execution. Some Keywords are required to be defined by the user
...            In the scenario_modifications.robot file.

Library    ./../../libraries/tools.py
Library    ./../../libraries/template_functions.py                         WITH NAME   template
Library    ./../../libraries/ulm_common_library.py                         WITH NAME   ucl

Resource   tracing.robot
Resource   ../../../../resources/Common/wts_ue.robot

*** Keywords ***

5G L3 Call with traffic
    [Arguments]  ${collector_name}=${EMPTY}
    ...          ${traffic_duration}=30s
    ...          ${pm_index}=${EMPTY}
    ...          ${pm_offset}=${EMPTY}
    Log  Starting 5G L3 call for ${scenario_name} with pm_index=${pm_index} and pm_offset=${pm_offset}  console=yes
    tracing.Start X2 and L2 L3 Syscom Trace and Syslogs
    Start/Stop TTI/BIP/DCAP Traces  call_location=before_attach  collector_name=${collector_name}
    Run Feature specific keywords before attach
    ${status}=  run keyword and return status  Attach UEs to specific Cells
    Start/Stop TTI/BIP/DCAP Traces  call_location=after_attach  collector_name=${collector_name}
    IF  '${status}'=='False'
        Stop X2 Syscom Traces and Stop Btslog collection  collector_name=${collector_name}
        Start/Stop TTI/BIP/DCAP Traces  call_location=failed_attach  collector_name=${collector_name}
        RETURN
    END
    Change CSI Report if Configured
    Run Feature specific keywords after attach before traffic is started
    Start Traffic From Traffic List  ${scenario_name}
    ${start_time}=  tools.get_current_time
    Start/Stop TTI/BIP/DCAP Traces  call_location=during_traffic  collector_name=${collector_name}
    ${stop_time}=  tools.get_current_time
    ${time_required_to_start_traces}=  tools.get_elapsed_time  start_time=${start_time}  end_time=${stop_time}
    ${traffic_duration}=  template.get_max_traffic_length  ${scenario_name}
    ${wait_time_for_traffic}=  evaluate  ${traffic_duration} - ${time_required_to_start_traces}
    Run Feature specific keywords during traffic before detach  traffic_duration=${wait_time_for_traffic}
    Stop Traffic From Traffic List  ${scenario_name}  ${start_time}  ${traffic_duration}
    Start/Stop TTI/BIP/DCAP Traces  call_location=after_traffic  collector_name=${collector_name}
    Run Feature specific keywords after traffic before detach
    run keyword and continue on failure    Detach all airphone UEs
    Deactivate used csi_report_profiles
    Run Feature specific keywords after detach
    tracing.Stop and collect running traces  collector_name=${collector_name}  scenario_name=${scenario_name}


Attach UEs to specific Cells
    Run Scripts to attach UE to LTE and perform Sgnb Addition
    Run Scripts to attach UEs to 5G Cell
    Log To Console    all UE's are registered to 5G in SA Mode!


Run Scripts to attach UE to LTE and perform Sgnb Addition
    ${list_of_nsa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    ${num_elems}=  Get Length  ${list_of_nsa_ue_to_be_attached}
    IF    ${num_elems}==${0}   RETURN
    log to console  Attaching UEs to LTE
    FOR  ${nsa_attach_params}  IN  ${list_of_nsa_ue_to_be_attached}
        Run NSA Attach Scripts  ${nsa_attach_params}
    END

Run NSA Attach Scripts
    [Arguments]  ${list_of_nsa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_nsa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"   CONTINUE
        ${optional_args}=  Set Variable  ${ue_parameters["optional_dual_connectivity_args"]}
        ${egate_output}=  ucl.kwrun  wts_ue.Attach UE to LTE  ue_id=${ue_id}  &{optional_args}
        ${rnti}=  tools.fetch_rnti_from   ${egate_output}
        template.set_rnti_for_ue  scenario_name=${scenario_name}  ue_id=${ue_id}  rnti=${rnti}
    END
    ucl.kwrun  wts_ue.Update dual connectivity parameters  id=1  serving_cell_index_range_scg=5:31
    Log to Console  Performing Sgnb Addition
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"   CONTINUE
        ${bearer_id}=  Get from dictionary  ${ue_parameters}  bearer
        ${cell}=  Get from dictionary  ${ue_parameters}  cell
        Log to console  Triggering LTE-NR dual connectivity for UE ${ue_id} on cell ${cell} for bearer ${bearer_id}
        ${status}=  Run Keyword And Return Status
        ...  ucl.kwrun  wts_ue.Trigger LTE dual connectivity and analyze Output  ue_id=${ue_id}  bearer_id=${bearer_id}  target_cells=${cell}
        ...  target_path=${ts_log_dir}/${scenario_name}_attach.json
        IF    '${status}'=='False'    Log  UE ${ue_id} was not attached successfully  level=WARN  console=yes
    END


Run SA Attach Scripts
    [Arguments]  ${list_of_sa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_sa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_sa_ue_to_be_attached}  ${ue_id}
        IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"   CONTINUE
        ${status}=    run keyword and return status
        ...    Try to Register SA UE and save its RNTI    ${ue_id}    ${ue_parameters}
        IF    not ${status}    log    Try to Register SA UE and save its RNTI on UE${ue_id} FAILED!    level=ERROR
        ${status}=    run keyword and return status    ucl.kwrun    wts_ue.Set traffic type
        ...    ue_id=${ue_id}    pdu_id=${ue_parameters["pdu"]}    trf_type=internal
        IF    not ${status}    log    Set traffic type on UE${ue_id} FAILED!    level=ERROR
        ${status}=    run keyword and return status    ucl.kwrun    wts_ue.UE PDU Session Setup and analyze output
        ...    ue_id=${ue_id}    pdu=${ue_parameters["pdu"]}    gw=${ue_id}  nwslice=1    target_path=${ts_log_dir}/${scenario_name}_attach.json
        IF    not ${status}
            log    UE PDU Session Setup on UE${ue_id} FAILED!    level=ERROR
        ELSE
            log to console  UE${ue_id} is registered to 5G in SA Mode!
        END
    END


Run Scripts to attach UEs to 5G Cell
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    ${num_elems}=  Get Length  ${list_of_sa_ue_to_be_attached}
    IF  ${num_elems}==${0}   RETURN
    Log to Console  Attaching UEs to 5G
    FOR  ${sa_attach_params}  IN  ${list_of_sa_ue_to_be_attached}
        Run SA Attach Scripts  ${sa_attach_params}
    END
    Modify PDU Sessions if defined in JSON


Modify PDU Sessions if defined in JSON
    ${ue_id_qos_flow_config}=  template.get_list_of_ues_for_pdu_modification  scenario_name=${scenario_name}  ue_type=sa
    FOR  ${UE_ID}  IN  @{ue_id_qos_flow_config}
        ${qos_flow_list}=  Get from dictionary  ${ue_id_qos_flow_config[${UE_ID}]}  qos_flows
        ${pdu}=  Get from dictionary  ${ue_id_qos_flow_config[${UE_ID}]}  pdu
        ${pdu_modification_required}=  Check if PDU Session Modification is required     qos_flow_list=${qos_flow_list}
        IF  ${pdu_modification_required}  Modify PDU Session  UE_ID=${UE_ID}  pdu=${pdu}  qos_flow_list=${qos_flow_list}
    END

Check if PDU Session Modification is required
    [Arguments]  ${qos_flow_list}
    ${pdu_modification_required}=  Set Variable if  ${qos_flow_list}  ${TRUE}  ${FALSE}
    RETURN  ${pdu_modification_required}


Modify PDU Session
    [Arguments]  ${UE_ID}  ${pdu}  ${qos_flow_list}
    ${status}=  Run Keyword And Return Status
        ...     wts_ue.UE PDU Session Modify  ue_id=${UE_ID}  pdu=${pdu}  qos_flow_list=${qos_flow_list}
    IF    not ${status}    log    Modification of PDU Session (${pdu}) for UE ID: ${UE_ID} FAILED!    level=ERROR


Try to Register SA UE and save its RNTI
    [Arguments]  ${ue_id}  ${ue_parameters}
    ${egate_output}=    ucl.kwrun    wts_ue.UE Register    ue_id=${ue_id}    &{ue_parameters["optional_nr_attach_args"]}
    ${rnti}=    tools.fetch_rnti_from    ${egate_output}
    template.set_rnti_for_ue    scenario_name=${scenario_name}    ue_id=${ue_id}    rnti=${rnti}


Change CSI Report if Configured
    ${commands}  ${auto_activate}=  template.get_csi_report_configured_for_scenario  ${scenario_name}
    IF  '${auto_activate}'=='False'   RETURN
    ${ue_groups}=  Get Dictionary Keys  ${commands}
    FOR  ${ue_group}  IN  @{ue_groups}
        Update UE Channel State Information    profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  &{commands["${ue_group}"]["cqi_params"]}
        ucl.kwrun  Associate UEs to testmode    ue_id=${commands["${ue_group}"]["ue_ids"]}
        ...  testmode=csi_override  profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  scell=${commands["${ue_group}"]["scell"]}  action=activate
    END


Deactivate used csi_report_profiles
    ${commands}  ${auto_activate}=  template.get_csi_report_configured_for_scenario  ${scenario_name}
    ${ue_groups}=  Get Dictionary Keys  ${commands}
    FOR  ${ue_group}  IN  @{ue_groups}
        ucl.kwrun  Associate UEs to testmode    ue_id=${commands["${ue_group}"]["ue_ids"]}
        ...  testmode=csi_override  profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  scell=${commands["${ue_group}"]["scell"]}  action=deactivate
        Sleep    1s  Deactivating ${commands["${ue_group}"]["ue_ids"]}
    END


Start Traffic From Traffic List
    [Arguments]  ${scenario_name}
    ${traffic_commands}=  template.get_traffic_commands  scenario_name=${scenario_name}
    FOR  ${command}  IN  @{traffic_commands}
        Run Keyword And Warn On Failure    wts_ue.Start Data Traffic In Egate  &{command}
    END

Stop Traffic From Traffic List
    [Arguments]  ${scenario_name}  ${start_time}  ${traffic_duration}
    ${traffic_commands}=  template.get_traffic_commands  scenario_name=${scenario_name}
    ${current_time}=  tools.get_current_time
    ${elapsed_time}=  tools.get_elapsed_time  start_time=${start_time}  end_time=${current_time}
    ${traffic_remaining_time}=  Evaluate  ${traffic_duration} - ${elapsed_time}
    IF    ${traffic_remaining_time} > ${0}    Sleep    ${traffic_remaining_time}
    FOR  ${command}  IN  @{traffic_commands}
        ucl.kwrun  Stop data traffic in egate    ue_id=${command["ue_id"]}    direction=bi
    END

Detach all Airphone UEs
    ${list_of_nsa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    Log to Console  Detaching NSA UEs
    FOR  ${nsa_attach_params}  IN  ${list_of_nsa_ue_to_be_attached}
        Detach LTE UE  ${nsa_attach_params}
    END
    Log to Console  Detaching SA UEs
    FOR  ${sa_attach_params}  IN  ${list_of_sa_ue_to_be_attached}
        Detach 5G UE  ${sa_attach_params}
    END


Detach LTE UE
    [Arguments]  ${list_of_nsa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_nsa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"   CONTINUE
        ucl.kwrun  wts_ue.Detach UE from LTE  ue_id=${ue_id}
        log to console  UE${ue_id} is detached from 5G in NSA Mode!
    END


Detach 5G UE
    [Arguments]  ${list_of_sa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_sa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_sa_ue_to_be_attached}  ${ue_id}
        IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"   CONTINUE
        ucl.kwrun  wts_ue.UE Deregister  ${ue_id}
        log to console  UE${ue_id} is deregistered from 5G in SA Mode!
    END
