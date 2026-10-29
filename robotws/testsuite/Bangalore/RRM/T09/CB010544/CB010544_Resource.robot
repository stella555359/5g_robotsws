*** Settings ***
Documentation    :copyright: Nokia
...              :authors: CB010544 feature team
...              :contact: ganesha.u@nokia.com

Resource         ../../../resources/robot/common_log_collection.robot

*** Keywords ***
Check Rach msg
    ${output1}        wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output1}    Rach Config Common is missing     partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output1}    rrcReconfigurationComplete   partial_match=${TRUE}

Verify Beam Recovery in AP Syslog
    [Arguments]     ${NAME}
    log to console     Verifying syslog
    FOR      ${UE}     IN     @{crnti_list}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${NAME}.log | grep -i "successful Beam recovery"
    Should contain    ${status}     ${UE}
    END
    Log to Console    Beam Recovery verified in AP syslog

UE Registered Successfully & Rach validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log     ${crnti_string}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s2.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${crnti_string}

