*** Settings ***
Documentation    Cloud DCAP keywords.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Library          taf.rfrl.cbts.devices.dcap_basic.dcap.DcapBasicCollector    WITH NAME    dcap_api
Library          taf.sw.dcap.rd    WITH NAME    rd

*** Keywords ***

#################################################### Main  Keywords ####################################################

Create DCAP Connection
    [Documentation]             Description:    Create DCAP connection.
    ...                         Input:          hw_type = vCU/vDU
    ...                                         host_ip = DCAP ip
    ...                                         port = DCAP port
    ...                                         username = DCAP login username
    ...                                         password = DCAP login password
    ...                                         alias = alias of created connection, by default keyword is adding
    ...                                                 hw_type at the end of it, but you don't need to remember that
    ...                                                 when you're using alias with another keywords
    ...                         Author:         patryk.tatarek@nokia.com
    [Arguments]                 ${host_ip}     ${port}     ${username}
    ...                         ${password}    ${alias}    ${hw_type}=${None}
    dcap_api.connect_to_dcap    host=${host_ip}
    ...                         port=${port}
    ...                         username=${username}
    ...                         password=${password}
    ...                         conn_alias=${alias}_${hw_type}

Close DCAP Connection
    [Documentation]    Description:       Close all existing DCAP connections.
    ...                Recommendation:    Use it in teardown
    ...                Author:            patryk.tatarek@nokia.com
    dcap_api.teardown

Start Gathering DCAP Logs Using Trace Profile
    [Documentation]    Description:    Start gathering DCAP logs using chosen trace profile.
    ...                                Ony one trace profile can be used at the same time.
    ...                                Ony one logs gathering process is possible at the same time.
    ...                Input:          hw_type = vCU/vDU
    ...                                log_profile = main trace profile available for chosen hw_type,
    ...                                you can check them using "Get Available Trace Profiles" keyword
    ...                                alias = alias used while creating DCAP connection
    ...                Output:         Started trace id
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${log_profile}    ${alias}    ${hw_type}=${NONE}
    ${trace_id}=       Run Keyword If    '${hw_type}'=='vCU'    _Start Gathering DCAP Logs on vCU
    ...                                                         log_profile=${log_profile}
    ...                                                         alias=${alias}_${hw_type}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Start Gathering DCAP Logs on vDU
    ...                                                         log_profile=${log_profile}
    ...                                                         alias=${alias}_${hw_type}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${trace_id}

Start Gathering DCAP Logs Using Custom Profile List
    [Documentation]    Description:    Start gathering DCAP logs using custom profile/s.
    ...                                You can use multiple sutom profiles at the time.
    ...                                Ony one logs gathering process is possible at the same time.
    ...                Input:          hw_type = vCU/vDU
    ...                                log_profile_list = custom trace profile in form of a list,
    ...                                use BuiltIn keyword "Create List" to create this variable.
    ...                                Possible custom profiles for vCU:
    ...                                snapshotVcu, tracerVcu, L2Ps_Component, L2Lo_Component, L2HiRlc_Component,
    ...                                L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa,
    ...                                flowTracerVcu, controlPlane5gVcu, syslogVcu
    ...                                Possible custom profiles for vDU:
    ...                                snapshotVdu, L1StreamVdu, tracerVdu, L2Ps_Component, L2Lo_Component,
    ...                                L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,
    ...                                L2HiPdcp_Sherpa, flowTracerVdu, tssVdu, controlPlane5gVdu, syslogVdu, l1IqVdu
    ...                                alias = alias used while creating DCAP connection
    ...                Output:         Started trace id
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${log_profile_list}    ${alias}    ${hw_type}=${NONE}
    ${trace_id}=       Run Keyword If    '${hw_type}'=='vCU'    _Start Gathering Custom DCAP Logs on vCU
    ...                                                         log_profile_list=${log_profile_list}
    ...                                                         alias=${alias}_${hw_type}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Start Gathering Custom DCAP Logs on vDU
    ...                                                         log_profile_list=${log_profile_list}
    ...                                                         alias=${alias}_${hw_type}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${trace_id}

Stop Gathering DCAP Logs
    [Documentation]    Description:    Stop gathering DCAP logs.
    ...                Input:          hw_type = vCU/vDU
    ...                                trace_id = output from "Start Gathering DCAP Logs..." keyword
    ...                                alias = alias used while creating DCAP connection
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${trace_id}    ${alias}    ${hw_type}=${None}
    dcap_api.stop_dcap_trace    trace_id=${trace_id}    conn_alias=${alias}_${hw_type}

Download DCAP Logs
    [Documentation]    Description:    Download gathered DCAP logs.
    ...                Input:          hw_type = vCU/vDU
    ...                                trace_id = output from "Start Gathering DCAP Logs..." keyword
    ...                                alias = alias used while creating DCAP connection
    ...                Output:         Path to the DCAP log file
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${trace_id}    ${alias}    ${hw_type}=${None}
    ${trace_file}=     dcap_api.download_logs_file
    ...                trace_id=${trace_id}
    ...                conn_alias=${alias}_${hw_type}
    [Return]           ${trace_file}

Get Available Trace Profiles
    [Documentation]    Description:    Check every available trace profile for chosen hw_type
    ...                Input:          hw_type = vCU/vDU
    ...                                alias = alias used while creating DCAP connection
    ...                Output:         List of available trace profiles
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alias}    ${hw_type}=${NONE}
    ${profiles}=       Run Keyword If    '${hw_type}'=='vCU'    rd.get_vcu_profiles    connection=${alias}_${hw_type}
    ...                ELSE IF           '${hw_type}'=='vDU'    rd.get_vdu_profiles    connection=${alias}_${hw_type}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${profiles}

################################################ Supplementary Keywords ################################################

_Start Gathering DCAP Logs on vCU
    [Arguments]         ${log_profile}    ${alias}
    ${target_list}=     Create List    MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/NRCELL-1
    ${trace_id}=        dcap_api.start_dcap_trace
    ...                 ne_type=vcu
    ...                 nr_cell_list=${target_list}
    ...                 conn_alias=${alias}
    ...                 bts_alias=trace_vcu
    ...                 vdu_trace_profile=${log_profile}
    Sleep    10s        reason=Wait until DCAP triggers gathering process
    [Return]            ${trace_id}

_Start Gathering DCAP Logs on vDU
    [Arguments]         ${log_profile}    ${alias}
    ${target_list}=     Create List    MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRCELL-1
    ${trace_id}=        dcap_api.start_dcap_trace
    ...                 ne_type=vdu
    ...                 nr_cell_list=${target_list}
    ...                 conn_alias=${alias}
    ...                 bts_alias=trace_vdu
    ...                 vdu_trace_profile=${log_profile}
    Sleep    10s        reason=Wait until DCAP triggers gathering process
    [Return]            ${trace_id}

_Start Gathering Custom DCAP Logs on vCU
    [Arguments]         ${log_profile_list}    ${alias}
    ${target_list}=     Create List    MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/NRCELL-1
    ${trace_id}=        dcap_api.start_dcap_trace
    ...                 ne_type=vcu
    ...                 nr_cell_list=${target_list}
    ...                 conn_alias=${alias}
    ...                 bts_alias=trace_vcu
    ...                 vcu_custom_profile=${log_profile_list}
    Sleep    10s        reason=Wait until DCAP triggers gathering process
    [Return]            ${trace_id}

_Start Gathering Custom DCAP Logs on vDU
    [Arguments]         ${log_profile_list}    ${alias}
    ${target_list}=     Create List    MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRCELL-1
    ${trace_id}=        dcap_api.start_dcap_trace
    ...                 ne_type=vdu
    ...                 nr_cell_list=${target_list}
    ...                 conn_alias=${alias}
    ...                 bts_alias=trace_vdu
    ...                 vdu_custom_profile=${log_profile_list}
    Sleep    10s        reason=Wait until DCAP triggers gathering process
    [Return]            ${trace_id}
