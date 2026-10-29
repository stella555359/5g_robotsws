*** Settings ***
Documentation     Usefull Keywords
...               author: Abderrahmane NEZROUK
...               date: 01/07/2025

Library    OperatingSystem
Library    String
Library    Collections

Library    ../python/utilities.py

*** Keywords ***
Reset Egate and Reload Configuration
    [Documentation]                 Reset egate and reload configuration
    ...
    [Arguments]                     ${cfg_file_path}=/opt/iphy/latest/basic_wts_step2.cfg
    ...                             ${time_to_wait}=1s

    ute_wtssim.setup_egate          egate_port=${tl.core.egate_port}
    ...                             host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                             tool_dir=${tl.core.dir_path}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate
    ute_wtssim.execute_egate_command
    ...                             cmd=reset
    ...                             timeout=5s
    ...                             alias=egate
    sleep                           ${time_to_wait}
    ${cmd}=                         Catenate    cfg file=${cfg_file_path}
    ute_wtssim.execute_egate_command
    ...                             cmd=${cmd}
    ...                             timeout=5s
    ...                             alias=egate
    sleep                           ${time_to_wait}
    ute_wtssim.teardown_egate       alias=egate
    sleep                           ${time_to_wait}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    sbts_coam.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

Apply SCF Delta Configuration
    [Documentation]               Dedicated KW to apply a delta commissioning file.
    ...                           It performs delta commissioning and waits until gNB is up again
    ...                           (in case of RAT reset is needed for example)
    ...               Arguments:
    ...                - conn_alias: The alias name of the connection
    ...                - delta_file: Path to SCF delta JSON file
    [Teardown]         Run Keyword And Ignore Error     sbts_coam.teardown            connection=coamCnx
    [Arguments]        ${delta_file}

    # Open connection towards cOAM

    # Verify file exists
    File Should Exist    ${delta_file}    msg=SCF delta file not found: ${delta_file}

    sbts_coam.connect_to          name=coamCnx

    # Apply delta scf
    sbts_coam.Perform Delta Recommissioning
    ...            delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${True}
    ...            should_activate=${True}
    ...            connection=coamCnx
    ...            timeout=300

    OAM wait available

    Log    SCF delta configuration applied successfully    INFO

Download BSR File Using Git and Update BTS SW
     [Arguments]      ${bsr_file}   ${target_dir}
     ${exist}=      Run Keyword And Return Status    File Should Exist    ${target_dir}/${bsr_file}
     ${target}=     Run Keyword If    not ${exist}     GetFiles.download_package_using_git
     ...    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
     ...    BSR
     ...    ${bsr_file}
     ...    NpsVrfToken
     ...    glpat-4yNB_jaBXxz_BsyeAsgL
     ...    target_dir=${target_dir}

     File Should Exist    ${target_dir}/${bsr_file}   msg=BSR file not found: ${target_dir}/${bsr_file}

     log to console   Update Software With Activation: ${target}

     sbts_coam.connect_to          name=coam_gnb

     ADMIN Update Software With Activation
     ...           sw_package=${target_dir}/${bsr_file}
     ...           alias=coam_gnb

Check GNB And Cells Status OnAir
    [Documentation]                 Check GNB And Cells Status
    ...                             proceduralState should be in OnAir
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    # check GNB status
    ${cmd}                          Set Variable    get_bts_statuses
    ${gnb_status}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated Log                       =======> Current GNB status = ${gnb_status}
    Should Contain Any              ${gnb_status['operationalState']}    Enabled   Disabled
    ...                             ignore_case=true
    Should Be Equal                 ${gnb_status['proceduralState']}     OnAir
    ...                             ignore_case=true
    ...                             msg=GNB is not in Test Mode, current status is ${gnb_status}
    Should Be Equal                 ${gnb_status['blockingState']}       Unblocked
    ...                             ignore_case=true
    # check cells status
    ${cmd}                          Set Variable    get_cells_info
    ${cells_info}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated log                       =======> Current cell(s) info = ${cells_info}
    FOR    ${cell}    IN    @{cells_info}
        Should Contain Any    ${cell['status']['proceduralStatus']}    not initialized   configured   OnAir
        ...                   ignore_case=true
        Should be equal       ${cell['status']['administrativeState']}    Unlocked
        ...                   ignore_case=true
    END

Restart OAM and Wait till Available
    OAM Reset SIte         ${GNB_DU.oam}
    OAM Wait Available     ${GNB_DU.oam}     400
    OAM Wait Site Available    ${GNB_DU.oam}
    Reset Egate and Reload Configuration
    Wait Until Keyword Succeeds    10min    30s       Check GNB And Cells Status OnAir    ${GNB_DU.oam}

Register_and_Attach_All_UEs_List
    [Documentation]        Attached all Ue in SA_Ue_List
    [Arguments]            ${SA_UE_List}    ${SA_UeId_List}
    # Dated Log New Line       ---> Attaching all needed UEs
    FOR        ${ue_id}      IN        @{SA_UeId_List}
        &{current_UE}=                  Copy dictionary     ${BASIC_UE_SA}
        Set To Dictionary               ${current_UE}       ue          ${ue_id}
        Set To Dictionary               ${current_UE}       pdu         1
        Append To List                  ${SA_UE_List}       ${current_UE}
        CallSetup.UE Register                     ue=${current_UE.ue}
        Launch PDU Session              ue=${current_UE.ue}    pdu=${current_UE.pdu}    gw=${current_UE.ue}
    END
    Dated Log                ---> All needed UEs are now attached

Detach_all_UEs_List
    [Arguments]            ${SA_UE_List}
    FOR        ${current_ue}            IN         @{SA_UE_List}
        UE Deregister                   id=${current_ue.ue}
    END

Validate Parameters Configuration
    [Documentation]    Validate Parameters Configuration name via OAM/admin API.
    ...    Wraps get_parameter_by_class(class_name, parameter_list, include_children, timeout, detailed_output, connection).
    ...    Requires the library that provides get_parameter_by_class to be imported (e.g. WITH NAME admin).
    [Tags]    DEBUG
    [Arguments]    ${class_name}    ${expected_conf}    ${obj_list}=${None}    ${sub_param_name}=${None}
    ...            ${connection}=${Empty}   ${timeout}=60

    IF    '${sub_param_name}' == '${None}'
        ${parameter_list}= 	Get Dictionary Keys 	${expected_conf} 	sort_keys=False
    ELSE
        ${parameter_list}    Create List    ${sub_param_name}
    END

    ${actual_conf}=    sbts_coam.Get Parameter By Class    ${class_name}
    ...    parameter_list=${parameter_list}
    ...    include_children=${False}
    ...    timeout=${timeout}
    ...    detailed_output=${False}
    ...    connection=${connection}
    Log    ${actual_conf}    console=${True}

    ${errors}=     verify_configuration_parameters   ${actual_conf}   ${expected_conf}
    ...                       obj_list=${obj_list}    sub_param_name=${sub_param_name}

    Run Keyword If    ${errors}    Fail    Dictionaries differ:\n${errors}

    #=======================================================================================================================
# TTI Trace Collection Keywords
#=======================================================================================================================

TTI Trace Collection
    [Documentation]        This keyword will run and collect TTi traces
    ...                     and convert them to json and csv formats for analysis.
    [Arguments]            ${dir_suffix}   ${tti_trace_filename}   ${tti_capture_duration}=2s
    ${TTIdir}               Get TTI Trace Path                      dir_suffix=${dir_suffix}
    Dated Log New Line      Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep            ${tti_capture_duration}    msg=TTI capture
    ${TTIpcap}              Stop TTI Traces in Streaming mode       tti_trace_path=${TTIdir}
    ...                                                             tti_trace_filename=${tti_trace_filename}
    Dated Log New Line      Convert TTItrace to json and csv
    ${TTIjson}              Convert TTItrace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}               ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}
    ...                           num_of_events=10000
    Set Suite Variable     ${TTIjson}
    RETURN     ${TTIcsv}


#=======================================================================================================================
# BIP Trace Collection Keywords
#=======================================================================================================================

Start L1L2 Logs

    [Arguments]       ${L1L2_Name}

    Dated Log                         ======> Get L1L2 Bip Traces

    ${L1L2_Name}=                     Set Variable               ${L1L2_Name}_L1L2

    ${CaptureBIP}                     Capture L1L2 Set Upon Config     airscale=${GNB_DU}

    ${CaptureBIP.prefix}              set Variable               ${L1L2_Name}

  #  ${bipMsgList}                     Set Variable               ${TrafficFilter}
  #  ${Capture_BIP.filter}             Run Keyword                Get Filter For Particular Msgs    ${bipMsgList}

    Capture Init                      ${CaptureBIP}
    Capture start                     ${CaptureBIP}
    Set Global Variable               ${CaptureBIP}



Stop L1L2 Logs

    Capture stop                      ${CaptureBIP}

    Dated Log New Line                === path capture : ${CaptureBIP.path} ===

    Set Global Variable               ${CaptureBIP}

Update Trf ID In UE List
    [Documentation]    Updates the 'trf_id' key for each ue in a list of ue.
    [Arguments]    ${ue_list}    ${new_trf_id}
    ${updated_ue_list}=    Create List
    FOR    ${item}    IN    @{ue_list}
        # Create a copy of the dictionary to avoid modifying the original list in place
        ${modified_item}=    Copy Dictionary    ${item}
        # Update the 'trf_id' key with the new value
        Set To Dictionary    ${modified_item}    trf_id=${new_trf_id}
        # Append the modified dictionary to the new list
        Append To List    ${updated_ue_list}    ${modified_item}
    END
    RETURN    ${updated_ue_list}