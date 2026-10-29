*** Settings ***
Documentation    Generic kr=eywords for CB008232 Feature

*** Keywords ***
Validate PMCounters Feature
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Syslog should contain paging record in callback list
    [Arguments]      ${NAME}      ${paging_callback_list}
    log to console     Verifying CPRT paging record in callback list in syslog
    FOR   ${item}   IN    @{paging_callback_list}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep ${item}
          Should Not Be Empty    ${status}
    END

Syslog Validate paging records in PdschPayloadTBSendReq
    [Arguments]     ${NAME}      ${syslog_paging_records}
    log to console     Validating paging records in PdschPayloadTBSendReq in syslog
    FOR   ${item}   IN    @{syslog_paging_records}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep ${item}
          Should Not Be Empty    ${status}
    END

Syslog Validate Dropped paging records
    [Arguments]     ${NAME}      ${syslog_dropped_UEs}
    log to console     Validating Dropped Paging Record Details in syslog
    FOR   ${item}   IN    @{syslog_dropped_UEs}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep ${item}
          Should Not Be Empty    ${status}
    END

Configure TMSI Values for MultiUEs
    [Arguments]     ${TMSIs1}
    Log to console    ${TMSIs1}
    wtsrunner.amf_registration_param   id=1   tmsi=${TMSIs}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=2
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=2
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=2
    Log to Console    ${output}
    Run Keyword And Ignore Error      wtsrunner.amf_registration_param   id=1
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=2
    Log to Console    ${output}

Move MultiUEs to RRC_Idle_State
   [Arguments]     ${start_ue_id}    ${end_ue_id}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_ng_ctx_release     id=${ue_idx}   cause=NAS_normal_release
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=IS IDLE    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    IS IDLE    partial_match=${TRUE}
    Log to Console    ${output}
    END

MultiUE RRC_State_Display_Idle
    [Arguments]     ${start_ue_id}    ${end_ue_id}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=PDN    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    IDLE    partial_match=${TRUE}
    Log to Console    ${output}
    Log to Console    UE: ${ue_idx} moved to RRC Idle state
    END
	Log to Console    All_ues_Moved_to_RRC_Idle_State

MultiUE RRC_State_Active
    [Arguments]     ${Active_UEs}
	FOR     ${i}      IN      @{Active_UEs}
       wtsrunner.ue_disp     id=${i}
       ${output}   wtsrunner.read_wtsemu_output_until_re        expected=PDN    timeout=10
       ${output}         Get Lines Matching Regexp    ${output}    ACTIVE    partial_match=${TRUE}
       Log to Console    ${output}
	   Log to Console    UE: ${i} moved to RRC Active state
    END
	wtsrunner.ue_disp
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}


MultiUE RRC_State_Idle
    [Arguments]     ${Idle_UEs}
	FOR     ${i}      IN      @{Idle_UEs}
       wtsrunner.ue_disp     id=${i}
       ${output}   wtsrunner.read_wtsemu_output_until_re        expected=PDN    timeout=10
       ${output}         Get Lines Matching Regexp    ${output}    IDLE    partial_match=${TRUE}
       Log to Console    ${output}
	   Log to Console    UE: ${i} moved to RRC IDLE state
    END
	wtsrunner.ue_disp
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}

MultiUE RRC_State_Display_Active
    [Arguments]     ${start_ue_id}    ${end_ue_id}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}       Wait Until Keyword Succeeds  3 min   2 sec   Get UE_Status
    Get Lines Matching Regexp    ${output}    UE-${ue_idx}    partial_match=${TRUE}
    Get Lines Matching Regexp    ${output}    state .* ACTIVE    partial_match=${TRUE}
    ${status}    run keyword and return status    Get Lines Matching Regexp    ${output}    UE-${ue_idx}    partial_match=${TRUE}
    ${status}    run keyword and return status    Get Lines Matching Regexp    ${output}    state .* ACTIVE    partial_match=${TRUE}
    Run keyword if  ${status}==${True}     Builtin.log to console   ${ue_idx} is ACTIVE
    ...  ELSE  Log to Console  ${ue_idx} IDLE
    Log to Console    ${output}
    wtsrunner.ue_disp
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    END

Get UE_Status
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    Should Contain     ${output}    PDN
    [Return]          ${output}

Verify NGAP PagingPriority for UE
    [Arguments]      ${logpath}       ${filter_req}     ${pagingprio_value}
    [Documentation]      this KW Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    log to console       Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${pdml_entries}     taf_pdml_analyser.Get Pdml Entries     ${pdmlFile}
    ...          field_name=ngap.PagingPriority     attrib_name=showname     attrib_value=${pagingprio_value}
    ${attrib_values}    taf_pdml_analyser.Get Attrib Value From Pdml Entries    ${pdml_entries}
    ...    field_name=ngap.PagingPriority    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    log to console       ${attrib_values}
    log to console       ${pagingprio_value}
    should contain    ${attrib_values}     ${pagingprio_value}

Verify F1AP PagingPriority for UE
    [Arguments]      ${logpath}       ${filter_req}     ${pagingprio_value}
    [Documentation]      this KW Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    log to console       Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${pdml_entries}     taf_pdml_analyser.Get Pdml Entries     ${pdmlFile}
    ...          field_name=f1ap.PagingPriority     attrib_name=showname     attrib_value=${pagingprio_value}
    ${attrib_values}    taf_pdml_analyser.Get Attrib Value From Pdml Entries    ${pdml_entries}
    ...    field_name=f1ap.PagingPriority    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    log to console       ${attrib_values}
    log to console       ${pagingprio_value}
    should contain    ${attrib_values}     ${pagingprio_value}

Verify F1AP NO PagingPriority for UE
    [Arguments]      ${logpath}       ${filter_req}        ${pagingprio_value}
    [Documentation]      this KW Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    log to console       Verifies the PagingPriority level for PagingPriority IE captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${pdml_entries}     taf_pdml_analyser.Get Pdml Entries     ${pdmlFile}
    ...          field_name=f1ap.PagingPriority     attrib_name=showname     attrib_value=${pagingprio_value}
    ${attrib_values}    taf_pdml_analyser.Get Attrib Value From Pdml Entries    ${pdml_entries}
    ...    field_name=f1ap.PagingPriority    attrib_name=showname
    #${attrib_values}     convert to string    ${attrib_values}
    log to console       ${attrib_values}
    log to console       ${pagingprio_value}
    should be empty    ${attrib_values}

Get MCShark Version
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${sw_version}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}
    ${sw_version}    Get MCShark Version
    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
    set suite variable     ${MCShark}
    ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
    log to console    download mcshark successfully to UTE

