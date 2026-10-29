*** Settings ***
Documentation
...    Author: mateusz.kowalczyk@nokia.com; adam.superczynski@nokia.com
...    Maintainer: adrian.stawiany@nokia.com
...    Test Description: O-RU startup procedure specific keywords related to CB008205
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: https://gates.nsn-net.net/view/00025e9a#o=0
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=41006
...    Sample execution: pybot --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/ /home/ute/robotlte/
...    testsuite/WMP/SOAM1/CB008205-B/general.robot

*** Variables ***
@{CARRIER_FIRST_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-2/RX_L-0    RX_PU_L-3/RX_L-9    RX_PU_L-4/RX_L-1
...    TX_PU_L-1/TX_L-8    TX_PU_L-2/TX_L-0    TX_PU_L-3/TX_L-9    TX_PU_L-4/TX_L-1
@{CARRIER_SECOND_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-2/RX_L-0    RX_PU_L-3/RX_L-9    RX_PU_L-4/RX_L-1
...    TX_PU_L-1/TX_L-8    TX_PU_L-2/TX_L-0    TX_PU_L-3/TX_L-9    TX_PU_L-4/TX_L-1
@{LINK_FIRST_TYPE}    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-14    RX_PU_L-2/LOW_LEVEL_RX_LINK-0
...    RX_PU_L-2/LOW_LEVEL_RX_LINK-7    RX_PU_L-3/LOW_LEVEL_RX_LINK-9    RX_PU_L-3/LOW_LEVEL_RX_LINK-15
...    TX_PU_L-1/LOW_LEVEL_TX_LINK-8    TX_PU_L-2/LOW_LEVEL_TX_LINK-0    TX_PU_L-3/LOW_LEVEL_TX_LINK-9
...    TX_PU_L-4/LOW_LEVEL_TX_LINK-1
@{LINK_SECOND_TYPE}    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-14    RX_PU_L-2/LOW_LEVEL_RX_LINK-0
...    RX_PU_L-2/LOW_LEVEL_RX_LINK-7    RX_PU_L-3/LOW_LEVEL_RX_LINK-9    RX_PU_L-3/LOW_LEVEL_RX_LINK-15
...    TX_PU_L-1/LOW_LEVEL_TX_LINK-8    TX_PU_L-2/LOW_LEVEL_TX_LINK-0    TX_PU_L-3/LOW_LEVEL_TX_LINK-9
...    TX_PU_L-4/LOW_LEVEL_TX_LINK-1
@{TX_ARRAYS}    Tx-Array-0    Tx-Array-1    Tx-Array-2    Tx-Array-3
@{RX_ARRAYS}    Rx-Array-0    Rx-Array-1    Rx-Array-2    Rx-Array-3
@{TX_ENDPOINTS}    Low-Level-Tx-Endpoint-0    Low-Level-Tx-Endpoint-1    Low-Level-Tx-Endpoint-2    Low-Level-Tx-Endpoint-3
@{RX_ENDPOINTS}    Low-Level-Rx-Endpoint-0    Low-Level-Rx-Endpoint-1    Low-Level-Rx-Endpoint-2    Low-Level-Rx-Endpoint-3
...    Low-Level-Rx-Endpoint-8    Low-Level-Rx-Endpoint-9    Low-Level-Rx-Endpoint-10    Low-Level-Rx-Endpoint-11
@{IQ_COMPRESSION_PARAM}    iq-bitwidth    compression-type    exponent
${DEFAULT_ACCOUNT_NAME}=                xranuser
${DEFAULT_ACCOUNT_PASS}=                xran-password
${ADDITIONAL_ACCOUNT_NAME}=             xranuser2
${ADDITIONAL_ACCOUNT_PASS}=             xran-password

*** Keywords ***
Check Carrier Configuration Messages
    ${output}    Check Message Id In Oru    edit-config.*create
    ${output}    Fetch From Right    ${output}    "
    FOR    ${index}    IN RANGE    0    10
        ${message_id}    Evaluate    ${output}+${index}
        ${message_id}    Set Variable    message-id="${message_id}"
        ${message_output}    Check Message In Logs On Oru   ${message_id}
        Should Contain    ${message_output}
		...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><user-plane-configuration
        Should Contain    ${message_output}    <ok/></rpc-reply>
    END
    ${message}    Check Message In Logs On Oru    edit-config.*create
    FOR    ${carrier}    IN    @{CARRIER_NAME}
        Should Contain    ${message}    ${carrier}
    END
    Should Contain    ${message}    ${PROC_ELEM}
    FOR    ${link}    IN    @{LINK_NAME}
        Should Contain    ${message}    ${link}
    END
    FOR    ${endpoint}    IN    @{ENDPOINT_NAME}
        Should Contain    ${message}    ${endpoint}
    END

Check Iq Compression Message
    ${iq_compression_id}    Check Message Id
    ...    <ru-capabilities><min-power-per-pa-antenna/><max-power-per-pa-antenna/><format-of-iq-sample><compression-method-supported/>
    Should Not Be Empty    ${iq_compression_id}
    ${iq_compression}    Check Message In Netconf Trace File    ${iq_compression_id}
    Should Contain    ${iq_compression}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><module-capability xmlns="urn:o-ran:module-cap
    Should Contain    ${iq_compression}     <data><module-capability xmlns="urn:o-ran:module-cap:1.0"><ru-capabilities>
    FOR    ${param}    IN    @{IQ_COMPRESSION_PARAM}
        Should Contain    ${iq_compression}    ${param}
    END

Check Tx Arrays Message
    ${tx_array_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0">
	...    <tx-arrays
	...    tail -n 1
    Should Not Be Empty    ${tx_array_id}
    ${tx_array}    Check Message In Netconf Trace File    ${tx_array_id}
    Should Contain     ${tx_array}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><tx-arrays>
    FOR    ${array}    IN    @{TX_ARRAYS}
        Should Contain    ${tx_array}    ${array}
    END

Check Rx Arrays Message
    ${rx_array_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree">
	...    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><rx-arrays
    ...    tail -n 1
    Should Not Be Empty    ${rx_array_id}
    ${rx_array}    Check Message In Netconf Trace File    ${rx_array_id}
    Should Contain     ${rx_array}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><rx-arrays>
    FOR    ${array}    IN    @{RX_ARRAYS}
        Should Contain    ${rx_array}    ${array}
    END

Check Tx Endpoints Message
    ${tx_endpoint_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree">
	...    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-tx-endpoints
    ...    tail -n 1
    Should Not Be Empty    ${tx_endpoint_id}
    ${tx_endpoint}    Check Message In Netconf Trace File    ${tx_endpoint_id}
    Should Contain     ${tx_endpoint}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-tx-endpoints>
    FOR    ${endpoint}    IN    @{TX_ENDPOINTS}
        Should Contain    ${tx_endpoint}    ${endpoint}
    END

Check Rx Endpoints Message
    ${rx_endpoint_id}    Check Message Id
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
	...    <filter type="subtree"><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-rx-endpoints
    ...    tail -n 1
    Should Not Be Empty    ${rx_endpoint_id}
    ${rx_endpoint}    Check Message In Netconf Trace File    ${rx_endpoint_id}
    Should Contain     ${rx_endpoint}
    ...    <data><user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0"><static-low-level-rx-endpoints>
    FOR    ${endpoint}    IN    @{RX_ENDPOINTS}
        Should Contain    ${rx_endpoint}    ${endpoint}
    END

Check Processing Element Configuration Message
    ${proc_elem_id}    Check Message Id
    ...    <processing-elements xmlns="urn:o-ran:processing-element:1.0"
	...    xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="merge">
    ...    tail -n 1
    Should Not Be Empty    ${proc_elem_id}
    ${proc_elem}    Check Message In Netconf Trace File    ${proc_elem_id}
    Should Contain     ${proc_elem}
    ...    <ok/></rpc-reply>
    Should Contain     ${proc_elem}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/>
    ${proc_element}    Get Parameter Value From Message With The Following Id    name    ${proc_elem_id}
    Set Test Variable    ${PROC_ELEM}    ${proc_element}
    ${proc_elem_id}    Fetch From Right    ${proc_elem_id}    "
    Set Test Variable    ${PROC_ELEM_ID}    ${proc_elem_id}

Check Static Prach Configuration Message
    ${prach_id}    Check Message Id
    ...    <static-prach-configurations nc:operation="create">
    ...    tail -n 1
    Should Not Be Empty    ${prach_id}

Check Iq Compression Parameter
    [Arguments]    ${parameter}=iqCompression
    ...            ${distname}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1001
    ${state}    Get Parameters    ${parameter}    ${distname}
    Should Be Equal As Strings    ${state['${parameter}']}    eCPRI IQ14

Check Sync Status Message
    ${sync_id}    Check Message Id
    ...    <filter type="subtree"><sync xmlns="urn:o-ran:sync:1.0"><sync-status>
    ...    tail -n 1
    Should Not Be Empty    ${sync_id}
    ${sync}    Check Message In Netconf Trace File    ${sync_id}
    Should Contain     ${sync}
    ...    <data><sync xmlns="urn:o-ran:sync:1.0"><sync-status>
    Should Contain     ${sync}
    ...    <get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="subtree"><sync
    ${sync_status}    Get Parameter Value From Message With The Following Id    sync-state    ${sync_id}
    Set Test Variable    ${SYNC_STATUS}    ${sync_status}
    ${sync_id}    Fetch From Right    ${sync_id}    "
    Set Test Variable    ${SYNC_ID}    ${sync_id}

Check Carrier Activation Message
    ${carrier_id}    Check Message Id
    ...    <user-plane-configuration xmlns="urn:o-ran:uplane-conf:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"><tx-array-carriers>
    ...    tail -n 1
    Should Not Be Empty    ${carrier_id}
    ${carrier_activation}    Check Message In Netconf Trace File    ${carrier_id}
    Should Contain     ${carrier_activation}
    ...    <ok/></rpc-reply>
    Should Contain     ${carrier_activation}
    ...    <edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><user-plane-configuration
    FOR    ${carrier}    IN    @{CARRIER_NAME}
        Should Contain    ${carrier_activation}    ${carrier}
    END
    ${carrier_id}    Fetch From Right    ${carrier_id}    "
    Run Keyword If    ${carrier_id} > ${SYNC_ID}    Should Be Equal As Strings    LOCKED    ${SYNC_STATUS}
    ...    ELSE    Fail    sync-state = LOCKED message was not sent before activating carrier

Check Processing Element In WebEM
    [Arguments]    ${proc_element_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/PROCESSING_ELEMENT-1
    ${proc_element_param}    Get Parameters    .*    ${proc_element_path}
    Should Be Equal As Strings    ${proc_element_param['processingElementName']}    ${PROC_ELEM}

Check Tx Endpoints In WebEM
    [Arguments]    ${low_level_endpoint_1_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-1
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_1_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${TX_ENDPOINTS}    ${endpoint}
        Remove Values From List    ${TX_ENDPOINTS}    ${endpoint}
    END
    Should Be Empty    ${TX_ENDPOINTS}

Check Rx Endpoints In WebEM
    [Arguments]    ${low_level_endpoint_2_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-2
    ...            ${low_level_endpoint_3_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/LOW_LEVEL_ENDPOINT_TYPE-3
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_2_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${RX_ENDPOINTS}    ${endpoint}
        Remove Values From List    ${RX_ENDPOINTS}    ${endpoint}
    END
    FOR    ${index}    IN RANGE    0    4
        ${endpoints_info}    Get Parameters    .*    ${low_level_endpoint_3_path}
        ${endpoint}    Set Variable    ${endpoints_info['endpoints'][${index}]}
        List Should Contain Value    ${RX_ENDPOINTS}    ${endpoint}
        Remove Values From List    ${RX_ENDPOINTS}    ${endpoint}
    END
    Should Be Empty    ${RX_ENDPOINTS}

Check Rx Arrays Object
    [Arguments]    ${rx_arrays_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/RX_PU_L-
    FOR    ${index}    IN RANGE    1    5
        ${rx_arrays_info}    Get Parameters    .*    ${rx_arrays_path}${index}
        ${array}    Set Variable    ${rx_arrays_info['rp1Name']}
        List Should Contain Value    ${RX_ARRAYS}    ${array}
        Remove Values From List    ${RX_ARRAYS}    ${array}
    END
    Should Be Empty    ${RX_ARRAYS}

Check Tx Arrays Object
    [Arguments]    ${tx_arrays_path}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/TX_PU_L-
    FOR    ${index}    IN RANGE    1    5
        ${tx_arrays_info}    Get Parameters    .*    ${tx_arrays_path}${index}
        ${array}    Set Variable    ${tx_arrays_info['rp1Name']}
        List Should Contain Value    ${TX_ARRAYS}    ${array}
        Remove Values From List    ${TX_ARRAYS}    ${array}
    END
    Should Be Empty    ${TX_ARRAYS}

Check Parameters Under SFP_R Object
    [Arguments]    ${sfp_r_1_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/SFP_R-1
    ...            ${sfp_r_2_path}=${EQM_PATH}/APEQM_R-1/RMOD_R-1/SFP_R-2
    ${sfp_info}    Get Parameters    .*    ${sfp_r_1_path}
    ${physical_port_1}    Evaluate    @{SFP_1_PARAM}[0]+1
    Should Be Equal As Strings    ${sfp_info['physicalPort']}    OPT_IF${physical_port_1}
    Should Be Equal As Strings    ${sfp_info['vendorName']}    @{SFP_1_PARAM}[1]
    Should Be Equal As Strings    ${sfp_info['vendorPartNumber']}    @{SFP_1_PARAM}[2]
    Should Be Equal As Strings    ${sfp_info['vendorRevision']}    @{SFP_1_PARAM}[3]
    Should Be Equal As Strings    ${sfp_info['serialNumber']}    @{SFP_1_PARAM}[4]
    ${connector_type}    Replace String    @{SFP_1_PARAM}[5]    -    _
    Should Be Equal As Strings    ${sfp_info['connectorType']}    ${connector_type}    ignore_case=True
    ${physical_port_2}    Evaluate    @{SFP_2_PARAM}[0]+1
    ${sfp_info}    Get Parameters    .*    ${sfp_r_2_path}
    Should Be Equal As Strings    ${sfp_info['physicalPort']}    OPT_IF${physical_port_2}
    Should Be Equal As Strings    ${sfp_info['vendorName']}    @{SFP_2_PARAM}[1]
    Should Be Equal As Strings    ${sfp_info['vendorPartNumber']}    @{SFP_2_PARAM}[2]
    Should Be Equal As Strings    ${sfp_info['vendorRevision']}    @{SFP_2_PARAM}[3]
    Should Be Equal As Strings    ${sfp_info['serialNumber']}    @{SFP_2_PARAM}[4]
    ${connector_type}    Replace String    @{SFP_2_PARAM}[5]    -    _
    Should Be Equal As Strings    ${sfp_info['connectorType']}    ${connector_type}    ignore_case=True

Get Invunit Path Belonging To Rmod
    [Arguments]    ${type}    ${inv_path}
    FOR    ${index}    IN RANGE    1    100
        ${final_path}=    Catenate    SEPARATOR=    ${inv_path}    ${index}
        &{invunit_params}=    taf.sbts.oam.coam.admin.Get Parameters    ${final_path}    alias=${ADMIN_ALIAS}
        ${passed}=    Run Keyword And Return Status    Assert Invunit Type Is Correct And RuntimeDN Contains Rmod
                                                        ...    type=${type}
                                                        ...    parameters=${invunit_params}
        Run Keyword If    ${passed}    Exit For Loop
    END
    [Return]    ${final_path}

Assert Invunit Type Is Correct And RuntimeDN Contains Rmod
    [Arguments]    ${type}    ${parameters}
    ${inv_type}=    Get From Dictionary    dictionary=${parameters}    key=inventoryUnitType
    ${runtime_dn}=    Get From Dictionary    dictionary=${parameters}    key=runtimeDN
    Should Match Regexp       ${inv_type}    ${type}
    Should Contain    ${runtime_dn}    RMOD

Check Carrier Status
    ${state}    Check Array Carriers In Netconf Traces
    @{objects}=    Run Keyword If    '${state}' == 'True'    Set Variable    ${CARRIER_SECOND_TYPE}
    ...    ELSE    Set Variable    ${CARRIER_FIRST_TYPE}
    @{carrier_name}    Create List
    FOR    ${carrier}    IN    @{objects}
            ${carrier_info}    Get Parameters    .*    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/${carrier}
            Should Be Equal As Strings    ${carrier_info['stateInfo']['availabilityStatus']}    Online
            Should Be Equal As Strings    ${carrier_info['stateInfo']['proceduralState']}    carrierActivated
            ${status}    Run Keyword And Return Status    Should Contain    ${carrier}    RX
            Run Keyword If    ${status}    Append To List    ${carrier_name}    ${carrier_info['ecpriRxArrayCarrier']['rxArrayCarrierName']}
            ...    ELSE    Append To List    ${carrier_name}    ${carrier_info['ecpriTxArrayCarrier']['txArrayCarrierName']}
    END
    Set Test Variable    ${CARRIER_NAME}    ${carrier_name}

Check Link Name And Endpoint Name In WebEM
    ${state}    Check Array Carriers In Netconf Traces
    @{objects}=    Run Keyword If    '${state}' == 'True'    Set Variable    ${LINK_SECOND_TYPE}
    ...    ELSE    Set Variable    ${LINK_FIRST_TYPE}
    @{link_name}    Create List
    @{endpoint_name}    Create List
    FOR    ${links}    IN    @{objects}
            ${links_info}    Get Parameters    .*    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/${links}
            ${status}    Run Keyword And Return Status    Should Contain    ${links}    RX
            Run Keyword If    ${status}    Run Keywords
            ...    Append To List    ${endpoint_name}    ${links_info['rxEndPointName']}    AND
            ...    Append To List    ${link_name}    ${links_info['rxLinkName']}
            ...    ELSE    Run Keywords
            ...    Append To List    ${endpoint_name}    ${links_info['txEndPointName']}    AND
            ...    Append To List    ${link_name}    ${links_info['txLinkName']}
    END
    Set Test Variable    ${LINK_NAME}    ${link_name}
    Set Test Variable    ${ENDPOINT_NAME}    ${endpoint_name}

Check Array Carriers In Netconf Traces
    ${msg}    Check Message In Netconf Trace File    <state>READY</state>
    ${state}    Run Keyword And Return Status    Should Contain    ${msg}    NR1.TX1_1_1_3_9
    [Return]    ${state}

Check Capability
    [Arguments]    ${list}    ${uri}
    FOR    ${value}    IN   @{list}
        ${passed}=    Run Keyword And Return Status    Should Contain    ${uri}    ${value}
        Run Keyword If    ${passed}    Remove Values From List    ${list}    ${value}
        Run Keyword If    ${passed}    Exit For Loop
    END
    [Return]    ${list}

Get Parameter Value From Message With The Following Id
    [Arguments]    ${parameter_name}
    ...            ${message_id}
    ...            ${grep_option}=tail -n 1
    ${output}    Run     grep -o 'id=${message_id}.*>.*</${parameter_name}' ${NETCONF_TRACE_LOCAL_PATH} | ${grep_option}
    ${value_tmp}=    Fetch From Right    ${output}    >
    ${value}=    Fetch From Left    ${value_tmp}    </${parameter_name}
    Log To Console     Value of parameter '${parameter_name}' read from Netconf trace file: ${value}
    [Return]    ${value}

Get First Parameter Value From Message With The Following Id
    [Arguments]    ${parameter_name}
    ...            ${message_id}
    ...            ${parameter_name_2}=${parameter_name}
    ...            ${grep_option}=tail -n 1
    ${output}    Run     grep -o -P 'id=${message_id}.*?<${parameter_name}>.*?</${parameter_name_2}>' ${NETCONF_TRACE_LOCAL_PATH} | ${grep_option}
    ${value_tmp}=    Fetch From Right    ${output}    <${parameter_name}>
    ${value}=    Fetch From Left    ${value_tmp}    </${parameter_name_2}>
    Log To Console     Value of parameter '${parameter_name_2}' read from Netconf trace file: ${value}
    [Return]    ${value}

Split Supervisord Logs
    [Arguments]    ${split_line}
    ...            ${path_default_acc}=${SPLITTED_LOGS_DEFAULT_ACC}
    ...            ${path_non_default_acc}=${SPLITTED_LOGS_NON_DEFAULT_ACC}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ${split_line}    Evaluate    ${split_line}-1
    Send Cmd To Docker Shell    cat ${supervisord_path} | sed -n '1,${split_line}p' >> ${path_default_acc}
    Send Cmd To Docker Shell    cat ${supervisord_path} | sed -n '${split_line},$p' >> ${path_non_default_acc}

Split Netconf Traces
    [Arguments]    ${split_line}
    ...            ${path_default_acc}=${SPLITTED_TRACES_DEFAULT_ACC}
    ...            ${path_non_default_acc}=${SPLITTED_TRACES_NON_DEFAULT_ACC}
    ...            ${nc_traces_path}=${NETCONF_TRACE_REMOTE_PATH}
    SYSTEM Open SSH Connection To Enb
    ${split_line}    Evaluate    ${split_line}-1
    SSHLibrary.Write    cat ${nc_traces_path} | sed -n '1,${split_line}p' >> ${path_default_acc}
    SSHLibrary.Read Until    :~ >
    SSHLibrary.Write    cat ${nc_traces_path} | sed -n '${split_line},$p' >> ${path_non_default_acc}
    SSHLibrary.Read Until    :~ >
    [Teardown]    SYSTEM Close SSH Connection To Enb

Get Line Number Of Message From Oru File
    [Arguments]    ${message_to_find}
    ...            ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    awk '/${message_to_find}/ {print FNR}' ${supervisord_path}
    ${number}    SSHLibrary.Read Until    root@
    Should Not Be Empty     ${number}
    ${number}    Get Line    ${number}    0
    [Return]    ${number}
    [Teardown]  Clear SSH Session To Docker

Get Line Number Of Message From gNB File
    [Arguments]    ${message_to_find}
    ...            ${file_path}=${NETCONF_TRACE_REMOTE_PATH}
    SYSTEM Open SSH Connection To Enb
    ${number}     SSHLibrary.Execute Command    awk '/${message_to_find}/ {print FNR}' ${file_path}
    Should Not Be Empty     ${number}
    ${number}    Get Line    ${number}    0
    [Return]    ${number}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Move File In Oru
    [Arguments]    ${source}
    ...            ${destination}
    ...            ${docker_name}=${DOCKER_NAME}
    send cmd to docker shell    mv ${source} ${destination}     ${docker_name}

Move File In gNB
    [Arguments]    ${source}
    ...            ${destination}
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Execute Command    mv ${source} ${destination}
    [Teardown]    SYSTEM Close SSH Connection To Enb