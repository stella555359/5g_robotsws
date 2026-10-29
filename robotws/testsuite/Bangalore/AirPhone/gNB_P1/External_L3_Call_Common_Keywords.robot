*** Settings ***
Documentation     This contains keywords related to leveraging the L3 call suite.
Library           taf.transport.ssh    WITH NAME    ssh
Library           OperatingSystem
Library           String
Library           ./Resources/utils_keywords.py

*** Variables ***
@{verification_list}     ng_link_status_is_ok    address_distribution_is_ok    cell_setup_is_ok
...    ue_sib_decoding_is_ok    x2_is_ok    ue_register_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    lte_attach_is_ok    ue_attach_is_ok    traffic_is_ok
...    5gdetach_is_ok    detach_is_ok    ue_reattach_is_ok
@{verification_list_seq}    ng_link_status_is_ok    address_distribution_is_ok    cell_setup_is_ok
...    ue_sib_decoding_is_ok    x2_is_ok    ue_register_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    lte_attach_is_ok    ue_attach_is_ok    nsa_traffic_is_ok
...    sa_traffic_is_ok    sa_ue_deregister_is_ok    5gdetach_is_ok    detach_is_ok    reattach_is_ok
@{verification_list_seq_custom}    ng_link_status_is_ok    address_distribution_is_ok    cell_setup_is_ok
...    ue_sib_decoding_is_ok    x2_is_ok    ue_register_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    lte_attach_is_ok    ue_attach_is_ok    nsa_traffic_is_ok
...    sa_traffic_is_ok    sa_ue_deregister_is_ok    5gdetach_is_ok    detach_is_ok
...    reattach_is_ok    OAM_Operation_with_L3_call_is_ok
@{verification_list_nsa}     x2_is_ok    cell_setup_is_ok    lte_attach_is_ok
...    ue_attach_is_ok    traffic_is_ok    5gdetach_is_ok    detach_is_ok    ue_reattach_is_ok
@{verification_list_sa}    ng_link_status_is_ok    address_distribution_is_ok    ue_sib_decoding_is_ok
...    cell_setup_is_ok    ue_register_is_ok    sa_traffic_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    sa_ue_deregister_is_ok
@{verification_list_combo}    ng_link_status_is_ok    address_distribution_is_ok   ue_sib_decoding_is_ok
...    cell_setup_is_ok    4g_attach_is_ok    ue_register_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    lte_attach_nsa_is_ok    ue_attach_is_ok    traffic_is_ok
...    4g_detach_is_ok    4g_reattach_is_ok    ue_detach_nsa_is_ok    ue_reattach_nsa_is_ok
@{verification_list_vran}    x2_is_ok    ue_sib_decoding_is_ok    cell_setup_is_ok
...    ue_register_is_ok    ue_deregister_is_ok    ue_re-register_is_ok    lte_attach_is_ok
...    ue_attach_is_ok    traffic_is_ok    5gdetach_is_ok    detach_is_ok    ue_reattach_is_ok
@{verification_list_6g}    ng_link_status_is_ok    address_distribution_is_ok    ue_sib_decoding_is_ok
...    cell_setup_is_ok    ue_register_is_ok    ue_deregister_is_ok    ue_re-register_is_ok
...    sa_traffic_is_ok    sa_ue_deregister_is_ok
@{verification_list_custom}    ng_link_status_is_ok    address_distribution_is_ok    cell_setup_is_ok
...    ue_sib_decoding_is_ok    x2_is_ok    ue_register_is_ok    ue_deregister_is_ok
...    ue_re-register_is_ok    lte_attach_is_ok    ue_attach_is_ok    traffic_is_ok
...    5gdetach_is_ok    detach_is_ok    ue_reattach_is_ok    OAM_Operation_with_L3_call_is_ok
${listener}    ${CURDIR}/Resources/QTListener.py

*** Keywords ***
Perform L3 call and check status
    [Arguments]    ${topology}    ${component_carrier}=1    ${suite}=${testsuite}    ${verification}=@{verification_list}
    ...        ${variable_section}=
    Perform L3 call    ${topology}    ${component_carrier}    ${suite}    ${variable_section}
    Check L3 call status    @{verification}

Perform L3 call
    [Arguments]    ${topology}    ${component_carrier}=1    ${suite}=${testsuite}    ${variable_section}=
    ${hostname}    Get Base Hostname
    ${command}     Catenate    cd /home/ute
    ...            && robot -L TRACE -d ${OUTPUT_DIR} -l ${TOPOLOGY}_L3_call.html
    ...            -o ${TOPOLOGY}_L3_call.xml -b L3_debug.log -v TOPOLOGY:${topology}
    ...            -V /home/ute/testline_configuration/${hostname}/
    ...            ${variable_section}
    ...            --listener ${listener}:${OUTPUT_DIR} ${suite}
    Run    ${command}
    Log    Dummy logging for now ${component_carrier}
    Download gNB and AP logs

Perform L3 call without listener and check status
    [Arguments]    ${topology}    ${component_carrier}=1    ${suite}=${testsuite}    ${verification}=@{verification_list}
    ...        ${variable_section}=
    Perform L3 call without listener    ${topology}    ${component_carrier}    ${suite}    ${variable_section}
    Check L3 call status    @{verification}

Perform L3 call without listener
    [Arguments]    ${topology}    ${component_carrier}=1    ${suite}=${testsuite}    ${variable_section}=
    ${hostname}    Get Base Hostname
    ${command}     Catenate    cd /home/ute
    ...            && robot -L TRACE -d ${OUTPUT_DIR} -l ${TOPOLOGY}_L3_call.html
    ...            -o ${TOPOLOGY}_L3_call.xml -b L3_debug.log -v TOPOLOGY:${topology}
    ...            -V /home/ute/testline_configuration/${hostname}/
    ...            ${variable_section}  ${suite}
    Run And Return Rc And Output    ${command}
    Log    Dummy logging for now ${component_carrier}
    Download gNB and AP logs

Download gNB and AP logs
    Run And Return Rc And Output    cp -rf /home/ute/logs/ ${OUTPUT_DIR}
    Run And Return Rc And Output    cp /opt/wts/latest/egate_console.log ${OUTPUT_DIR}/logs/

Check L3 call status
    [Arguments]    @{msg_list}
    FOR    ${msg}   IN    @{msg_list}
        Run keyword And Continue On Failure    Check AP Debug Log     ${msg}
    END

Check AP Debug Log
    [Arguments]         ${grep_text}
    ${debug_check}      Run    grep "INFO - ${grep_text}" ${OUTPUT_DIR}/L3_debug.log
    ${str}=             Remove String    ${grep_text}    _is_ok
    Should Contain      ${debug_check}    ${grep_text}    msg="Failed at ${str}"

Perform NSA call and check status
    [Arguments]    ${topology}
    Perform NSA call    ${topology}
    Check L3 call status    @{verification_list_nsa}

Perform NSA call
    [Arguments]    ${topology}
    ${command}     Catenate    cd /home/ute
    ...            && robot -L TRACE -d ${OUTPUT_DIR} -l ${TOPOLOGY}_L3_call.html
    ...            -o ${TOPOLOGY}_L3_call.xml -b L3_debug.log -v TOPOLOGY:${topology}
    ...            -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} --include NSA ${testsuite_seq}
    Run    ${command}
    Download gNB and AP logs

Perform Combo call and check status
    [Arguments]    ${topology}        ${variable_section}=
    Perform Combo call    ${topology}            variable_section=${variable_section}
    Check L3 call status    @{verification_list_combo}

Perform Combo call
    [Arguments]    ${topology}    ${component_carrier}=1        ${variable_section}=
    ${command}     Catenate    cd /home/ute
    ...            && robot -L TRACE -d ${OUTPUT_DIR} -l ${TOPOLOGY}_L3_call.html
    ...            -o ${TOPOLOGY}_L3_call.xml -b L3_debug.log -v TOPOLOGY:${topology} -v COMPONENT_CARRIER:${component_carrier}
    ...            ${variable_section}
    ...            --listener ${listener}:${OUTPUT_DIR} ${testsuite_combo}
    Run    ${command}
    Download gNB and AP logs
