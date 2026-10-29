*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to ONAP CM operation for SBTS cases.
...               KW 'Get Informations From ONAP' must be called before using this resource to operate on real ONAP.
...
...    ******************
...    History of changes
...    ******************
...    - 19.05.2023 - Xu Yuyan commit to robotws
...    - 14.11.2023 - Liu Bin, add new KWs.
...    - 27.02.2025 - Kang Lixin, optimize KWs for ccn check
Library           XML    use_lxml=True    WITH NAME    L_XML
Library           SSHLibrary
Library           Collections
Library           String
Library           OperatingSystem

*** Variables ***
${ONAP_INFOR}     ${None}
${ONAP_IGNORE_PARAMS_FILE}    /home/ute/testline_configuration/10_5_UTESRAN1905/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml

*** Keywords ***
Get Informations From ONAP
    [Arguments]    ${host_ip}    ${user}    ${pwd}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Obtain the basic information of ONAP and initialize the variable ${ONAP_INFOR} for all subsequent operations on ONAP.
    ...    This KW must be called before using this resource to operate on ONAP.
    ...
    ...    return ${ONAP_INFOR} as:
    ...    {'certFingerPrint': '23:56:0B:8E:7B:83:6B:FA:E1:28:A0:D9:B4:E6:60:9B:E2:3B:58:C9',
    ...    'netconf_server': 'netconf-server-55bd874b6c-ns76h',
    ...    'ves_collector': 'dev-dcae-ves-collector-565d78cdf6-ntl6w',
    ...    'ves_collector_5g': 'dep-dcae-ves-collector-5g-6dcfcd5555-mj65l',
    ...    'ves_worker': 'onap-k8s-7',
    ...    'ves_worker_5g': 'onap-k8s-1',
    ...    'ves_worker_ip': '100.70.230.201',
    ...    'ves_worker_ip_5g': '100.70.230.205'}
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    ${ONAP_INFOR}    Create Dictionary
    SSHLibrary.Write    kubectl -n onap get pods |grep netconf-server- --color=never | grep Running
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${netconf_server}    Should Match Regexp    ${out_put.split()[0]}    netconf-server-\\w+-\\w+
    Set To Dictionary    ${ONAP_INFOR}    netconf_server    ${netconf_server}
    ${tmp1}    Set Variable    kubectl -n onap exec -it dev-sdnc-0 -- /bin/bash -c 'openssl x509 -fingerprint -noout
    ${cmd_certFingerPrint}    Set Variable    ${tmp1} -in /var/custom-certs/cert.pem | sed -e"s/SHA1 Fingerprint//; s/=//; s/=//p"'
    SSHLibrary.Write    ${cmd_certFingerPrint}
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${certFingerPrint}    Should Match Regexp    ${out_put}    \\w\\w[:\\w\\w]*
    Set To Dictionary    ${ONAP_INFOR}    certFingerPrint    ${certFingerPrint}
    SSHLibrary.Write    kubectl get pods -n onap -o=wide | grep dep-dcae-ves-collector-5g- --color=never |grep Running
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${ves_worker_5g}    Set Variable    ${out_put.split()[6].strip()}
    ${ves_collector_5g}    Should Match Regexp    ${out_put.split()[0]}    dep-dcae-ves-collector-5g-\\w+-\\w+
    SSHLibrary.Write    kubectl get nodes -o wide | grep ${ves_worker_5g} --color=never
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${ves_worker_ip_5g}    Should Match Regexp    ${out_put.split()[5]}    \\d+\\.\\d+\\.\\d+\\.\\d+
    Set To Dictionary    ${ONAP_INFOR}    ves_collector_5g    ${ves_collector_5g}
    Set To Dictionary    ${ONAP_INFOR}    ves_worker_5g    ${ves_worker_5g}
    Set To Dictionary    ${ONAP_INFOR}    ves_worker_ip_5g    ${ves_worker_ip_5g}
    SSHLibrary.Write    kubectl get pods -n onap -o=wide | grep dev-dcae-ves-collector- --color=never |grep Running
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${ves_worker}    Set Variable    ${out_put.split()[6].strip()}
    ${ves_collector}    Should Match Regexp    ${out_put.split()[0]}    dev-dcae-ves-collector-\\w+-\\w+
    SSHLibrary.Write    kubectl get nodes -o wide | grep ${ves_worker} --color=never
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${ves_worker_ip}    Should Match Regexp    ${out_put.split()[5]}    \\d+\\.\\d+\\.\\d+\\.\\d+
    Set To Dictionary    ${ONAP_INFOR}    ves_collector    ${ves_collector}
    Set To Dictionary    ${ONAP_INFOR}    ves_worker    ${ves_worker}
    Set To Dictionary    ${ONAP_INFOR}    ves_worker_ip    ${ves_worker_ip}
    ${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    ${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    Set Test Variable    ${ONAP_IGNORE_PARAMS}
    Set Test Variable    ${ONAP_INFOR}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${ONAP_INFOR}

Create MPLANEONAP object
    [Arguments]    ${BTS_ID}    ${mPlaneAddressDN}    ${certFingerPrint}
    [Documentation]    This keyword creates MPLANEONAP object, with it's parameters
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | BTS_ID | yes | SBTS ID |
    ...    | mPlaneAddressDN | yes | IPADDRESSV4 point to mplane IP |
    ...    | certFingerPrint | yes | Get from ONAP VM |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | ${mplane_onap} | DN of MPLANEONAP |
    ...
    ...    *Example*
    ...    | Integrate SBTS To ONAP | 1894 | MRBTS-1894/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 | ${ONAP_INFOR['certFingerPrint']} |
    ${mplane_onap}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dic_actCmEventsReporting}    create dictionary    parameterName=actCmEventsReporting    operation=update    value=false
    ${dic_pushCompleteCMDB}    create dictionary    parameterName=pushCompleteCMDB    operation=update    value=false
    ${dict_heartBeatSendingInterval}    create dictionary    parameterName=heartBeatSendingInterval    operation=update    value=0
    ${dict_mPlaneAddressDN}    create dictionary    parameterName=mPlaneAddressDN    operation=update    value=${mPlaneAddressDN}
    ${dict_activateOranO1NetconfService}    create dictionary    parameterName=activateOranO1NetconfService    operation=update    value=true
    ${dict_activateSendingBulkPmEvents}    create dictionary    parameterName=activateSendingBulkPmEvents    operation=update    value=false
    ${dict_activateSendingFmEvents}    create dictionary    parameterName=activateSendingFmEvents    operation=update    value=false
    ${dict_activateSendingPnfRegistration}    create dictionary    parameterName=activateSendingPnfRegistration    operation=update    value=false
    ${dict_pnfRegistrationEventSendingInterval}    create dictionary
    ...    parameterName=pnfRegistrationEventSendingInterval    operation=update    value=300
    ${dict_pnfRegistrationScenarioTimeout}    create dictionary    parameterName=pnfRegistrationScenarioTimeout    operation=update    value=1440
    ${dict_vesAckTimeout}    create dictionary    parameterName=vesAckTimeout    operation=update    value=5
    ${dic_ves_Feedback}    create dictionary    parameterName=vesCMFeedbackNotificationInt    operation=update    value=60
    ${dic_certToNameMapping}    create dictionary    certFingerPrint=${certFingerPrint}    mapType=specified    userName=cmuser
    ${value_certToNameMapping}    Create List    ${dic_certToNameMapping}
    ${dic_certToNameMappingList}    create dictionary    parameterName=certToNameMappingList    operation=update    value=${value_certToNameMapping}
    @{parameter_list}    Create List    ${dict_heartBeatSendingInterval}    ${dict_mPlaneAddressDN}    ${dict_activateOranO1NetconfService}
    ...    ${dict_activateSendingBulkPmEvents}    ${dict_activateSendingFmEvents}
    ...    ${dict_activateSendingPnfRegistration}    ${dict_pnfRegistrationEventSendingInterval}    ${dict_pnfRegistrationScenarioTimeout}
    ...    ${dict_vesAckTimeout}    ${dic_certToNameMappingList}    ${dic_ves_Feedback}
    coam.Perform Object Recommissioning    dist_name=${mplane_onap}    operation=create    parameter=@{parameter_list}
    [Return]    ${mplane_onap}

Delete MPLANEONAP object
    [Arguments]    ${BTS_ID}
    [Documentation]    This keyword deletes MPLANEONAP object
    ...    *AUTHOR* anna.benzar@nokia.com
    ${parameter_list}    Create list
    ${mplane_onap}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    coam.Perform Object Recommissioning    dist_name=${mplane_onap}    operation=delete    parameter=${parameter_list}

Add VESENDPOINT-ID
    [Arguments]    ${BTS_ID}    ${vesend_no}    ${worker_ip}    ${worker_port}=30420
    [Documentation]    This keyword adds VESENDPOINT ids to ONAP object
    ...    *AUTHOR* anna.benzar@nokia.com
    ${vesend}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${vesend_no}
    ${dict_enableHostnameValidation}    create dictionary    parameterName=enableHostnameValidation    operation=update    value=False
    ${dict_vesEndpointId}    create dictionary    parameterName=vesEndpointId    operation=update    value=${vesend_no}
    ${dict_vesEndpointIpAddress}    create dictionary    parameterName=vesEndpointIpAddress    operation=update    value=${worker_ip}
    ${dict_vesEndpointPortNumber}    create dictionary    parameterName=vesEndpointPortNumber    operation=update    value=${worker_port}
    @{parameter_list}    create list
    ...    ${dict_enableHostnameValidation}    ${dict_vesEndpointId}    ${dict_vesEndpointIpAddress}    ${dict_vesEndpointPortNumber}
    coam.Perform Object Recommissioning    dist_name=${vesend}    operation=create    parameter=@{parameter_list}
    [Return]    ${vesend}

SSH to ONAP
    [Arguments]    ${host_ip}    ${user}    ${pwd}
    ${ssh_index}    SSHLibrary.Open Connection    host=${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=#
    Run Keyword If    '${user}'!='root'    Run Keywords    SSHLibrary.Write    sudo -i
    ...    AND    SSHLibrary.Read Until Prompt
    [Return]    ${ssh_index}

Integrate SBTS To ONAP
    [Arguments]    ${BTS_ID}    ${host_ip}    ${user}    ${pwd}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    SBTS needs to set 'PriorityLabel' as BTS ID and 'dnPrefix' as SubNetwork=BTS ID before integrate SBTS to ONAP.
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | BTS_ID | yes | SBTS ID |
    ...    | host_ip | yes | ONAP VM IP |
    ...    | user | yes | ONAP VM username |
    ...    | pwd | yes | ONAP VM passowrd |
    ...
    ...    *Example*
    ...    | Integrate SBTS To ONAP | 1894 | host_ip=10.110.73.138 | user=ute | pwd=Ut3pa5s#84b8 |
    ${scf_contain}    L_XML.Parse XML    ${BTS_scf_initial}
    ${distName}    L_XML.Get Element Attribute    ${scf_contain}    distName
    ...    .//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/p[@name="localIpAddr" and text()="${MPLANE_IP}"]/..
    Log To Console    Create MPLANEONAP object
    ${mplane_onap}    Create MPLANEONAP object    ${BTS_ID}    ${distName}    02:${ONAP_INFOR['certFingerPrint']}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Log To Console    Add VESENDPOINT-ID
    ${vesend_1}    Add VESENDPOINT-ID    ${BTS_ID}    1    ${ONAP_INFOR['ves_worker_ip_5g']}
    ${vesend_2}    Add VESENDPOINT-ID    ${BTS_ID}    2    ${ONAP_INFOR['ves_worker_ip_5g']}
    ${dic_vesCmCollectorEndpointDN}    create dictionary    parameterName=vesCmCollectorEndpointDN    operation=update    value=${vesend_1}
    ${dic_vesFaultCollectorEndpointDN}    create dictionary    parameterName=vesFaultCollectorEndpointDN    operation=update    value=${vesend_2}
    ${dic_pushCompleteCMDB}    create dictionary    parameterName=pushCompleteCMDB    operation=update    value=true
    ${dic_actCmEventsReporting}    create dictionary    parameterName=actCmEventsReporting    operation=update    value=true
    ${dict_activateSendingFmEvents}    create dictionary    parameterName=activateSendingFmEvents    operation=update    value=true
    ${dict_activateOranO1NetconfService}    create dictionary    parameterName=activateOranO1NetconfService    operation=update    value=true
    @{parameter_list}    Create List    ${dic_vesCmCollectorEndpointDN}    ${dic_vesFaultCollectorEndpointDN}    ${dic_pushCompleteCMDB}
    ...    ${dic_actCmEventsReporting}    ${dict_activateSendingFmEvents}    ${dict_activateOranO1NetconfService}
    coam.Perform Object Recommissioning    dist_name=${mplane_onap}    operation=update    parameter=@{parameter_list}
    ${cmd}    Catenate    curl --request PUT -k --url
    ...    https://${ONAP_INFOR['ves_worker_ip_5g']}:30205/restconf/config/network-topology:network-topology/topology/topology-netconf/node/MRBTS
    ...    --header 'accept: application/json'
    ...    --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ=='
    ...    --header 'content-type: application/xml'
    ...    --cookie JSESSIONID=1o6tqx4jyrgsw49gaffvai1j1    --data '<node xmlns="urn:TBD:params:xml:ns:yang:network-topology">
    ...    <node-id>MRBTS</node-id>    <key-based xmlns="urn:opendaylight:netconf-node-topology">
    ...    <key-id xmlns="urn:opendaylight:netconf-node-topology">ODL_private_key_0</key-id>
    ...    <username xmlns="urn:opendaylight:netconf-node-topology">fm-pm</username>
    ...    </key-based>    <host xmlns="urn:opendaylight:netconf-node-topology">${MPLANE_IP}</host>
    ...    <port xmlns="urn:opendaylight:netconf-node-topology">6513</port>
    ...    <tcp-only xmlns="urn:opendaylight:netconf-node-topology">false</tcp-only>
    ...    <protocol xmlns="urn:opendaylight:netconf-node-topology">    <name xmlns="urn:opendaylight:netconf-node-topology">TLS</name>
    ...    </protocol>    <max-connection-attempts xmlns="urn:opendaylight:netconf-node-topology">2</max-connection-attempts>    </node>'
    Log To Console    ${cmd}
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Write    ${cmd}
    ${out_put}    SSHLibrary.Read Until Prompt
    Log To Console    ${out_put}
    ${cmd}    Catenate    curl -k --request GET --url
    ...    https://${ONAP_INFOR['ves_worker_ip_5g']}:30205/restconf/operational/network-topology:network-topology/topology/topology-netconf
    ...    --header 'accept: application/json'
    ...    --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ=='
    ...    --header 'content-type: application/json'    --cookie JSESSIONID=wjj28qtrpu8q1p2zsiibrde3 | json_pp
    SSHLibrary.Write    ${cmd}
    ${out_put}    SSHLibrary.Read Until Prompt
    Log To Console    ${out_put}
    [Teardown]    SSHLibrary.Close Connection

Integrate SBTS To ONAP Simulator
    [Arguments]    ${BTS_ID}    ${ves_simulator_ip}    ${certFingerPrint}=02:13:BD:0E:BE:9E:60:4D:DD:EF:91:8F:6E:FC:DD:DF:FE:6D:F9:A3:E4
    ${scf_contain}    L_XML.Parse XML    ${BTS_scf_initial}
    ${distName}    L_XML.Get Element Attribute    ${scf_contain}
    ...    distName    .//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/p[@name="localIpAddr" and text()="${MPLANE_IP}"]/..
    Log To Console    Create MPLANEONAP object
    ${mplane_onap}    Create MPLANEONAP object    ${BTS_ID}    ${distName}    ${certFingerPrint}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Log To Console    Add VESENDPOINT-ID
    ${vesend_1}    Add VESENDPOINT-ID    ${BTS_ID}    1    ${ves_simulator_ip}    30510
    ${vesend_2}    Add VESENDPOINT-ID    ${BTS_ID}    2    ${ves_simulator_ip}    30510
    ${dic_vesCmCollectorEndpointDN}    create dictionary    parameterName=vesCmCollectorEndpointDN    operation=update    value=${vesend_1}
    ${dic_vesFaultCollectorEndpointDN}    create dictionary    parameterName=vesFaultCollectorEndpointDN    operation=update    value=${vesend_2}
    ${dic_pushCompleteCMDB}    create dictionary    parameterName=pushCompleteCMDB    operation=update    value=true
    ${dic_actCmEventsReporting}    create dictionary    parameterName=actCmEventsReporting    operation=update    value=true
    ${dict_activateSendingFmEvents}    create dictionary    parameterName=activateSendingFmEvents    operation=update    value=true
    ${dict_activateOranO1NetconfService}    create dictionary    parameterName=activateOranO1NetconfService    operation=update    value=true
    @{parameter_list}    Create List    ${dic_vesCmCollectorEndpointDN}    ${dic_vesFaultCollectorEndpointDN}    ${dic_pushCompleteCMDB}
    ...    ${dic_actCmEventsReporting}    ${dict_activateSendingFmEvents}    ${dict_activateOranO1NetconfService}
    coam.Perform Object Recommissioning    dist_name=${mplane_onap}    operation=update    parameter=@{parameter_list}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms

Deintegrate SBTS From ONAP
    [Arguments]    ${BTS_ID}
    Delete MPLANEONAP object    ${BTS_ID}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Start VES Log Listen
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${BTS_ID}=${EMPTY}    ${regrex_filter}=VESEvent
    ...    ${log_file_name}=TA_ONAP_VES    ${smod_SN}=${EMPTY}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Access to VES pod and start filter VES log for special fields.
    ...    Unassigning parameters ${BTS_ID} and ${smod_SN} will result in a large amount of redundant information.
    ...    The priority of parameter ${smod_SN} is higher than ${BTS ID}, and ${smod_SN} can filter out the feedback CCN.
    ...    It is recommended to use ${smod_SN}, which is the primary SMOD core SN of SBTS.
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | host_ip | yes | ONAP VM IP |
    ...    | user | yes | ONAP VM username |
    ...    | pwd | yes | ONAP VM passowrd |
    ...    | pod | yes | VES pod on ONAP VM |
    ...    | BTS_ID | no | |
    ...    | regrex_filter | no | 'VESEvent' for CCN messages |
    ...    | log_file_name | no | File to save filter resulte on VES pod |
    ...    | smod_SN | no | Primary SMOD core SN |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | log_file_name | Created log file name on VES pod |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | smod_SN=L1230610684 |
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=\@
    SSHLibrary.Write    kubectl -n onap exec -it ${pod} bash
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    cd logs
    ${out_put}    SSHLibrary.Read Until Prompt
    ${time}    Get Time    epoch
    ${log_file_name}    Set Variable    ${log_file_name}_${time}
    ${cmd}    Set Variable If    '${BTS_ID}' == '${EMPTY}'
    ...    nohup stdbuf -oL tail -Fn0 collector.log    nohup stdbuf -oL tail -Fn0 collector.log | stdbuf -oL grep -E "MRBTS.${BTS_ID}" -i
    ${cmd}    Set Variable If    '${smod_SN}' == '${EMPTY}'    ${cmd}
    ...    nohup stdbuf -oL tail -Fn0 collector.log | stdbuf -oL grep -E "NOK_${smod_SN}" -i
    ${cmd}    Set Variable If    '${regrex_filter}' == '${EMPTY}'
    ...    ${cmd} > ${log_file_name}.log 2>&1 &    ${cmd} | stdbuf -oL grep -E "${regrex_filter}" > ${log_file_name}.log 2>&1 &
    SSHLibrary.Write    ${cmd}
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    pwd
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    [Return]    ${log_file_name}

Tear VES Log Listener
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${log_file_name}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Access to VES pod and stop filter VES log for special fields.
    ...    Must call KW 'Start VES Log Listen' and get ${log_file_name} from it before this KW.
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=\@
    SSHLibrary.Write    kubectl -n onap exec -it ${pod} bash
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    cd logs
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ps aux | grep tail\\ \\-f\\ collector.log|grep ${log_file_name}|grep -v grep | awk '{print $2}'
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${got_process_id}    Run Keyword And Return Status    Convert To Integer    ${out_put.split()[0]}
    Run Keyword If    ${got_process_id}    Run Keywords    SSHLibrary.Write    kill -9 ${out_put.split()[0]}
    ...    AND    SSHLibrary.Read Until Prompt
    sleep    2s
    SSHLibrary.Set Client Configuration    prompt=\#
    SSHLibrary.Write    exit
    ${out_put}    SSHLibrary.Read Until Prompt

Stop VES Log Listen And Get Messages
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${log_file_name}    ${log_file_path}=${BTSFiles}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Stop the VES log listener, get the file from VES pod to folder ${BTSFiles} and transfer the content to list of VES CCN messages.
    ...    Must call KW 'Start VES Log Listen' and get ${log_file_name} from it before this KW.
    ...
    ...    Return likes:
    ...
    ...    [{
    ...    "event": {
    ...    "commonEventHeader": {
    ...    "domain": "other",
    ...    "eventId": "other-vsCmOperation366FeedbackNotification1",
    ...    "eventName": "Other_mrbts-Nokia_VsCmOperationFeedbackNotification",
    ...    "lastEpochMicrosec": 1699417565966665,
    ...    "priority": "Normal",
    ...    "reportingEntityName": "NOKL1230610684",
    ...    "sequence": 0,
    ...    "sourceName": "NOKL1230610684",
    ...    "startEpochMicrosec": 1699417565966665,
    ...    "version": "4.1",
    ...    "vesEventListenerVersion": "7.2"
    ...    },
    ...    "otherFields": {
    ...    "hashMap": [
    ...    {
    ...    "messageResult": "ok",
    ...    "messageid": "66",
    ...    "operationName": "provision",
    ...    "sessionid": "3",
    ...    "status": "completed",
    ...    "version": "1.0"
    ...    }
    ...    ],
    ...    "otherFieldsVersion": "3.0"
    ...    }}},
    ...    ......]
    Tear VES Log Listener    ${host_ip}    ${user}    ${pwd}    ${pod}    ${log_file_name}
    SSHLibrary.Write    kubectl cp onap/${pod}:/opt/app/VESCollector/logs/${log_file_name}.log /tmp/${log_file_name}.log
    ${out_put}    SSHLibrary.Read Until Prompt
    sleep    2s
    SSHLibrary.Write    kubectl -n onap exec -it ${pod} rm /opt/app/VESCollector/logs/${log_file_name}.log
    SSHLibrary.Get File    /tmp/${log_file_name}.log    ${log_file_path}/${log_file_name}.log
    Sleep    5s
    SSHLibrary.Write    rm /tmp/${log_file_name}.log
    ${VES_CCN_Sample_str}    OperatingSystem.Get File    ${log_file_path}/${log_file_name}.log
    ${VES_CCN_lines}    Split To Lines    ${VES_CCN_Sample_str}
    ${VES_CCN_msgs}    Create List
    FOR    ${VES_CCN_line}    IN    @{VES_CCN_lines}
        ${tmpstr}    Fetch From Left    ${VES_CCN_line}    }'
        ${tmpstr}    Fetch From Right    ${tmpstr}    '{
        ${tmpstr}    Set Variable    {${tmpstr}}
        ${tmpstr}    Replace String Using Regexp    ${tmpstr}    :[\\s]*true[\\s]*    :"true"
        ${tmpstr}    Replace String Using Regexp    ${tmpstr}    :[\\s]*false[\\s]*    :"false"
        ${ret}    ${tmp_dic}    Run Keyword And Ignore Error    Evaluate    ${tmpstr}
        Continue For Loop If    '${ret}'=='FAIL'
        Append To List    ${VES_CCN_msgs}    ${tmp_dic}
    END
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${VES_CCN_msgs}

Filter VES CCN MSG
    [Arguments]    ${commonEventHeader_filter}    ${VES_CCN_msgs}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Filter out CCN messages that match the message header from the VES CCN message list.
    ...    The message header usually defines the type of CCN message, such as notifyMoiChanges, VsCmOperationFeedbackNotification, and so on.
    ${msg_to_get}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_msgs}
        ${is_header_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["commonEventHeader"]}    ${commonEventHeader_filter}
        Run Keyword If    ${is_header_match}    Append To List    ${msg_to_get}    ${VES_CCN_msg}
    END
    [Return]    ${msg_to_get}

Filter VES moiChanges MSN
    [Arguments]    ${moiChanges}    ${target_DN}    ${oper}    ${dic_param_value}
    ${target_CCNs}    Create List
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${bts_id}    Fetch From Right    ${bts}    -
    ${params}    Get Dictionary Keys    ${dic_param_value}
    #change SCF DN to ONAP DN, like "MRBTS-1896/TNLSVC-1" to "SubNetwork=1896,ManagedElement=MRBTS-1896,TNLSVC=1"
    FOR    ${param}    IN    @{params}
        ${value}    Get From Dictionary    ${dic_param_value}    ${param}
        ${is_scf_dn}    Run Keyword And Return Status    Should Match Regexp    ${value}    ^\\w+-\\d+(/\\w+-\\d+)*
        Run Keyword If    not ${is_scf_dn}    Continue For Loop
        ${value}    Fetch From Right    ${value}    ${bts}
        ${value}    Set Variable    SubNetwork=${bts_id},ManagedElement=${bts}${value.replace("-","=").replace("/",",")}
        Set To Dictionary    ${dic_param_value}    ${param}    ${value}
    END
    #find out moiChange those matched
    FOR    ${moiChange}    IN    @{moiChanges}
        #op 'add' for add MO, 'remove' for delete MO, 'replace' for parameter update
        Continue For Loop If    '${moiChange["op"]}'!='${oper}'
        ${path}    Get From Dictionary    ${moiChange}    path
        ${protocols}    Get Regexp Matches    ${path}    (?<=/)(.*?)(?=:)
        ${is_for_MO}    Run Keyword And Return Status    Should Not End With    ${path}    /attributes
        ${path}    Replace String Using Regexp    ${path}    /.*:    /
        ${path}    Remove String    ${path}    /ManagedElement=
        ${scf_path}    Set Variable If    "${path}"=="${bts}"    ${path}    ${bts}${path}
        ${scf_path}    Set Variable    ${scf_path.replace("=","-").replace("/attributes","")}
        ${not_same}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${scf_path}    ${target_DN}    ignore_case=True
        #skip if this moiChange is not for target_DN
        Continue For Loop If    ${not_same}
        #for delete MO
        Run Keyword If    "${oper}"=="remove" and "${is_for_MO}"=="${True}"    Append To List    ${target_CCNs}    ${moiChange}
        Continue For Loop If    "${oper}"=="remove" and "${is_for_MO}"=="${True}"
        #for add MO
        ${key}    Set Variable    ${protocols[-1]}:${scf_path.split("/")[-1].split("-")[0]}:attributes
        ${dic_val}    Set Variable If    ${is_for_MO}    ${moiChange["value"]["${key}"]}    ${moiChange["value"]}
        ${contain_value}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${dic_val}    ${dic_param_value}
        Run Keyword If    "${oper}"=="add" and "${is_for_MO}"=="${True}"    Append To List    ${target_CCNs}    ${moiChange}
        Continue For Loop If    "${oper}"=="add" and "${is_for_MO}"=="${True}"
        #for add/modify parameter only
        ${empty_list}    Create List
        ${list_deleted_params}    Pop From Dictionary    ${dic_param_value}    !DELETE!    ${empty_list}
        ${contain_value}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${dic_val}    ${dic_param_value}
        ${not_delete_param}    Run Keyword And Return Status    Should Be Empty    ${list_deleted_params}
        Run Keyword If    ${contain_value} and ${not_delete_param}    Append To List    ${target_CCNs}    ${moiChange}
        Continue For Loop If    ${contain_value} and ${not_delete_param}
        #for containing delete parameter
        ${ves_keys}    Get Dictionary Keys    ${dic_val}
        ${not_deleted}    Run Keyword And Return Status    List Should Contain Sub List    ${ves_keys}    ${list_deleted_params}
        Set To Dictionary    ${dic_param_value}    !DELETE!    ${list_deleted_params}
        Continue For Loop If    ${not_deleted}
        Run Keyword If    ${contain_value}    Append To List    ${target_CCNs}    ${moiChange}
    END
    [Return]    ${target_CCNs}

_Filter VES FeedbackHashMap
    [Arguments]    ${hashMaps}    ${oper}    ${status}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Internal KW, please use 'Filter VES VsCmOperationFeedbackNotification CCN'
    ${found_hashMap}    Set Variable    ${False}
    ${filter}    Create Dictionary    operationName=${oper}    status=${status}
    FOR    ${hashMap}    IN    @{hashMaps}
        ${found_hashMap}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${hashMap}    ${filter}
        Exit For Loop If    ${found_hashMap}
    END
    [Return]    ${found_hashMap}

Filter VES NotifyHeartbeat CCN_bak20250227
    [Arguments]    ${VES_CCN_msgs}    ${target_DN}    ${core_SN}    ${mplane_ip}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${target_VES_CCN_msg} | Filter VES NotifyHeartbeat CCN | ${VES_CCN_msgs} | MRBTS-1894 | L1230610684 | ${mplane_ip} |
    ${dic_standard_head}    Create Dictionary    sourceName=NOK${core_SN}    reportingEntityName=NOK${core_SN}    priority=Normal
    ...    eventName=StndDefined_mrbts-Nokia_3gppNotifyHeartBeat    sequence=${0}
    ...    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Heartbeat
    ${VES_CCN_notifyMOIChanges}    Filter VES CCN MSG    ${dic_standard_head}    ${VES_CCN_msgs}
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${bts_id}    Fetch From Right    ${bts}    -
    ${systemDN}    Set Variable    SubNetwork=${bts_id},ManagedElement=MRBTS-${bts_id}
    ${dic_data_head}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyHeartbeat    href=${mplane_ip}
    ${target_VES_CCN_msg}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_notifyMOIChanges}
        ${is_header_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    ${dic_data_head}
        Run Keyword If    not ${is_header_match}    Continue For Loop
        Append To List    ${target_VES_CCN_msg}    ${VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Filter VES NotifyHeartbeat CCN
    [Arguments]    ${VES_CCN_msgs}    ${target_DN}    ${core_SN}    ${mplane_ip}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${target_VES_CCN_msg} | Filter VES NotifyHeartbeat CCN | ${VES_CCN_msgs} | MRBTS-1894 | L1230610684 | ${mplane_ip} |
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${bts_id}    Fetch From Right    ${bts}    -
    ${systemDN}    Set Variable    SubNetwork=${bts_id},ManagedElement=MRBTS-${bts_id}
    ${dic_commonEventHeader}    Create Dictionary    sourceName=NOK${core_SN}    reportingEntityName=NOK${core_SN}    priority=Normal
    ...    eventName=StndDefined_mrbts-Nokia_3gppNotifyHeartBeat    sequence=${0}
    ...    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Heartbeat
    ${dic_stndDefinedFields}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyHeartbeat    href=${mplane_ip}
    ${target_VES_CCN_msg}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_msgs}
        ${is_common_match}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["commonEventHeader"]}    ${dic_commonEventHeader}
        Run Keyword If    '${is_common_match}'!='PASS'    Continue For Loop
        ${is_stndDefined_match}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    ${dic_stndDefinedFields}
        Run Keyword If    '${is_stndDefined_match}'!='PASS'   Continue For Loop
        Append To List    ${target_VES_CCN_msg}    ${VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Filter VES NotifyMOIChanges CCN_bak20250227
    [Arguments]    ${VES_CCN_msgs}    ${target_DN}    ${core_SN}    ${mplane_ip}    ${oper}    ${dic_param_value}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...    | oper | yes | replace or add or delete, use replace for cell create as special scenario |
    ...    | dic_param_value | yes | for MO create or delete, could give an empty dic |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${dic_param} | Create Dictionary | btsname=new_name |
    ...    | ${target_CCN_msg} | Filter VES NotifyMOIChanges CCN | ${VES_CCN_msgs} | MRBTS-1894 | L1230610684 | ${m_ip} | replace | ${dic_param} |
    ${dic_standard_head}    Create Dictionary    sourceName=NOK${core_SN}    reportingEntityName=NOK${core_SN}    priority=Normal
    ...    eventName=StndDefined_mrbts-Nokia_3gppNotifyMoiChanges    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Provisioning
    ${VES_CCN_notifyMOIChanges}    Filter VES CCN MSG    ${dic_standard_head}    ${VES_CCN_msgs}
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${bts_id}    Fetch From Right    ${bts}    -
    ${systemDN}    Set Variable    SubNetwork=${bts_id},ManagedElement=MRBTS-${bts_id}
    ${dic_data_head}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyMOIChanges    href=${mplane_ip}
    ${target_VES_CCN_msg}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_notifyMOIChanges}
        ${is_header_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    ${dic_data_head}
        Run Keyword If    not ${is_header_match}    Continue For Loop
        ${moiChanges}    Get From Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    moiChanges
        ${target_CCNs}    Filter VES moiChanges MSN    ${moiChanges}    ${target_DN}    ${oper}    ${dic_param_value}
        Continue For Loop If    "${target_CCNs.__len__()}"=="${0}"
        ${tmp_VES_CCN_msg}    Copy Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    deepcopy=${True}
        Set To Dictionary    ${tmp_VES_CCN_msg}    moiChanges    ${target_CCNs}
        Append To List    ${target_VES_CCN_msg}    ${tmp_VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Filter VES NotifyMOIChanges CCN
    [Arguments]    ${VES_CCN_msgs}    ${target_DN}    ${product}    ${vesSourceName}    ${dnPrefix}    ${mplane_ip}    ${oper}    ${dic_param_value}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...    - 05.19.2025 - Xu Yuyan updated for Cloud
    ...
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...    | oper | yes | replace or add or delete, use replace for cell create as special scenario |
    ...    | dic_param_value | yes | for MO create or delete, could give an empty dic |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${dic_param} | Create Dictionary | btsname=new_name |
    ...    | ${target_CCN_msg} | Filter VES NotifyMOIChanges CCN | ${VES_CCN_msgs} | MRBTS-1894 | L1230610684 | ${m_ip} | replace | ${dic_param} |
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${bts_id}    Fetch From Right    ${bts}    -
    ${systemDN}    Set Variable    ${dnPrefix},ManagedElement=MRBTS-${bts_id}
    ${eventName}    Set Variable If  "${product.lower()}"=="vcu"
    ...    StndDefined_vCu-Nokia_3gppNotifyMoiChanges    StndDefined_vDu-Nokia_3gppNotifyMoiChanges
    ${dic_commonEventHeader}    Create Dictionary    sourceName=${vesSourceName}    reportingEntityName=${vesSourceName}    priority=Normal
    ...    eventName=${eventName}    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Provisioning
    ${dic_stndDefinedFields}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyMOIChanges    href=${mplane_ip}
    ${target_VES_CCN_msg}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_msgs}
        ${is_common_match}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["commonEventHeader"]}    ${dic_commonEventHeader}
        Run Keyword If    '${is_common_match}'!='PASS'    Continue For Loop
        ${is_stndDefined_match}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    ${dic_stndDefinedFields}
        Run Keyword If    '${is_stndDefined_match}'!='PASS'   Continue For Loop
        ${moiChanges}    Get From Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    moiChanges
        ${target_CCNs}    Filter VES moiChanges MSN    ${moiChanges}    ${target_DN}    ${oper}    ${dic_param_value}
        Continue For Loop If    "${target_CCNs.__len__()}"=="${0}"
        ${tmp_VES_CCN_msg}    Copy Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    deepcopy=${True}
        Set To Dictionary    ${tmp_VES_CCN_msg}    moiChanges    ${target_CCNs}
        Append To List    ${target_VES_CCN_msg}    ${tmp_VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Filter VES VsCmOperationFeedbackNotification CCN_bak20250227
    [Arguments]    ${VES_CCN_msgs}    ${core_SN}    ${oper}    ${status}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${dic_param} | Create Dictionary | btsname=new_name |
    ...    | ${target_VES_CCN_msg} | Filter VES VsCmOperationFeedbackNotification CCN | ${VES_CCN_msgs} | L1230610684 | provision | complete |
    ${dic_standard_head}    Create Dictionary    sourceName=NOK${core_SN}    reportingEntityName=NOK${core_SN}    priority=Normal
    ...    eventName=Other_mrbts-Nokia_VsCmOperationFeedbackNotification    vesEventListenerVersion=7.2
    ${VES_CCN_FeedbackNotification}    Filter VES CCN MSG    ${dic_standard_head}    ${VES_CCN_msgs}
    ${target_VES_CCN_msg}    Create List
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_FeedbackNotification}
        ${hashMaps}    Set Variable    ${VES_CCN_msg["event"]["otherFields"]["hashMap"]}
        ${found_hashMap}    _Filter VES FeedbackHashMap    ${hashMaps}    ${oper}    ${status}
        Run Keyword If    ${found_hashMap}    Append To List    ${target_VES_CCN_msg}    ${VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Filter VES VsCmOperationFeedbackNotification CCN
    [Arguments]    ${VES_CCN_msgs}    ${product}    ${vesSourceName}    ${oper}    ${status}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...    - 07.02.2025 - Xu Yuyan updated for Cloud
    ...    Filter heartbeat messages from the VES CCN message list.
    ...
    ...    *INPUT*
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | VES_CCN_msgs | yes | list of VES CCN messages |
    ...    | target_DN | yes | DN of SBTS |
    ...    | core_SN | yes | Primary SMOD core SN |
    ...    | mplane_ip | yes | mplane IP |
    ...
    ...    *OUTPUT*
    ...    | Return Value | Description |
    ...    | target_VES_CCN_msg | list of VES CCN message |
    ...
    ...    *Example*
    ...    | ${ves_ccn_file} | Start VES Log Listen | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | L1230610684 |
    ...    | ${VES_CCN_msgs} | Stop VES Log Listen And Get Messages | ${ip} | ute | pwd | ${ONAP_INFOR['ves_collector_5g']} | ${ves_ccn_file} |
    ...    | ${dic_param} | Create Dictionary | btsname=new_name |
    ...    | ${target_VES_CCN_msg} | Filter VES VsCmOperationFeedbackNotification CCN | ${VES_CCN_msgs} | L1230610684 | provision | complete |
    ${eventName}    Set Variable If  "${product.lower()}"=="vcu"
    ...    Other_vCu-Nokia_VsCmOperationFeedbackNotification    Other_vDu-Nokia_VsCmOperationFeedbackNotification
    ${dic_commonEventHeader}    Create Dictionary    sourceName=${vesSourceName}    reportingEntityName=${vesSourceName}    priority=Normal
    ...    eventName=${eventName}    vesEventListenerVersion=7.2
    ${filter}      Create Dictionary    operationName=${oper}    status=${status}
    ${target_VES_CCN_msg}    Create List
    ${found_hashMap}    Set Variable    ${False}
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_msgs}
        ${is_common_match}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary
        ...    ${VES_CCN_msg["event"]["commonEventHeader"]}    ${dic_commonEventHeader}
        Run Keyword If    '${is_common_match}'!='PASS'    Continue For Loop
        ${is_hashMap_has}    ${msg}    Run Keyword And Ignore Error    Dictionary Should Contain Key
        ...    ${VES_CCN_msg["event"]}    otherFields
        Run Keyword If    '${is_hashMap_has}'!='PASS'    Continue For Loop
        ${hashMaps}   Set Variable    ${VES_CCN_msg["event"]["otherFields"]["hashMap"]}
#        FOR    ${hasMap}    IN    @{hashMaps}
#            ${found_hashMap}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
#            ...    ${hasMap}    ${filter}
#            Run Keyword If    ${found_hashMap}    Append To List    ${target_VES_CCN_msg}    ${VES_CCN_msg}
#        END
        # change due to PR843037
        ${found_hashMap}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary
        ...    ${hashMaps}    ${filter}
        Run Keyword If    ${found_hashMap}    Append To List    ${target_VES_CCN_msg}    ${VES_CCN_msg}
    END
    [Return]    ${target_VES_CCN_msg}

Exucute One Command On Netconf CLI
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${sbts_ip}    ${cmd}
    ...    ${ssh_cmd_timeout}=120s
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Write this KW due to don't know how to implement SSH link interaction in tool netopeer2-cli.
    ${ssh_index}    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Write    kubectl -n onap exec -it ${pod} bash
    ${out_put}    SSHLibrary.Read Until Prompt
    SSHLibrary.Set Client Configuration    timeout=${ssh_cmd_timeout}
    SSHLibrary.Write    (echo "connect --tls --host ${sbts_ip}";sleep 30s;echo "${cmd}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    Log    ${ret}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${ret}

Restructure ONAP Alarm Dict
    [Arguments]    ${alm_ves}
    ${distName}    Set Variable    ${alm_ves['href'].replace("=","-")}
    ${faultId}    Fetch From Left    ${alm_ves['specificProblem']}    _
    ${alarmId}    Fetch From Right    ${alm_ves['specificProblem']}    _
    ${fault_name}    Fetch From Left    ${alm_ves['additionalText']}    ;
    ${alarm_name}    Fetch From Right    ${alm_ves['additionalText']}    ;
    Set To Dictionary    ${alm_ves}    faultId=${faultId}    alarmId=${alarmId}    distName=${distName}

Get File From Pod To Local
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${pod_file_path}    ${local_file_path}=${EMPTY}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *Example*
    ...    | Get File From Pod To Local | 10.110.73.138 | ute | Ut3pa5s#84b8 | ${ONAP_INFOR['ves_collector_5g']} | /tmp/abc.xml |
    ${local_file_path}    Set Variable If
    ...    '${local_file_path}'=='${EMPTY}'    ${OUTPUT DIR}/${pod_file_path.split('/')[-1]}    ${local_file_path}
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Write    kubectl cp onap/${pod}:${pod_file_path} /tmp/${pod_file_path.split('/')[-1]}
    ${out_put}    SSHLibrary.Read Until Prompt
    sleep    10s
    SSHLibrary.Get File    /tmp/${pod_file_path.split('/')[-1]}    ${local_file_path}
    sleep    10s
    SSHLibrary.Write    kubectl -n onap exec -it ${pod} rm ${pod_file_path}
    [Teardown]    SSHLibrary.Close Connection

Put File From Local To Pod
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${pod_file_path}    ${local_file_path}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *Example*
    ...    | Put File From Local To Pod | 10.110.73.138 | ute | Ut3pa5s#84b8 | ${ONAP_INFOR['ves_collector_5g']} | /tmp/abc.xml | /tmp/abc.xml |
    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
    SSHLibrary.Put File    ${local_file_path}    /tmp/${local_file_path.split('/')[-1]}
    SSHLibrary.Write    kubectl cp /tmp/${local_file_path.split('/')[-1]} onap/${pod}:${pod_file_path}
    ${out_put}    SSHLibrary.Read Until Prompt
    [Teardown]    SSHLibrary.Close Connection

Get List Value From SCF
    [Arguments]    ${dn}    ${scf_param_name}    ${scf_content}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get MO Different List Parameters Of Netconf Get'.
    ${list_param_val}    Create List
    ${param_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${dn}"]/list[@name="${scf_param_name}"]/p
    FOR    ${param_element}    IN    @{param_elements}
        ${scf_param_val}    L_XML.Get Element Text    ${param_element}
        Append To List    ${list_param_val}    ${scf_param_val}
    END
    [Return]    ${list_param_val}

Get Structure Value From SCF
    [Arguments]    ${dn}    ${scf_param_name}    ${scf_content}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get MO Different Struture Parameters Of Netconf Get'.
    ${scf_item_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${dn}"]/list[@name="${scf_param_name}"]/item
    ${list_scf_items}    Create List
    FOR    ${scf_item_element}    IN    @{scf_item_elements}
        ${dic_scf_grand}    Get Item Values From SCF    ${scf_item_element}
        Append To List    ${list_scf_items}    ${dic_scf_grand}
    END
    [Return]    ${list_scf_items}

Get Item Values From SCF
    [Arguments]    ${scf_item_element}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get Structure Value From SCF'.
    ${scf_param_grand_elements}    L_XML.Get Child Elements    ${scf_item_element}
    ${dic_scf_grand}    Create Dictionary
    FOR    ${scf_param_grand_element}    IN    @{scf_param_grand_elements}
        ${scf_param_name}    L_XML.Get Element Attribute    ${scf_param_grand_element}    name
        ${scf_param_val}    L_XML.Get Element Text    ${scf_param_grand_element}
        Set To Dictionary    ${dic_scf_grand}    ${scf_param_name}    ${scf_param_val}
    END
    [Return]    ${dic_scf_grand}

Transfer ONPA DN To MO Path
    [Arguments]    ${onap_value}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Some value of parameter in SBTS is a DN, such as CABLINK.firstEndpointDN, value of it is 'MRBTS-1894/EQM-1/APEQM-1/CABINET-1/BBMOD-6',
    ...    value of it on ONAP SCF could be 'SubNetwork=1894,ManagedElement=MRBTS-1894,EQM=1,APEQM=1,CABINET=1,BBMOD=6'.
    ...    This KW transfer ONAP DN to SBTS DN if the value match that type.
    ${onap_value}    Convert To String    ${onap_value}
    ${ret}    Run Keyword And Return Status    Should Not Match Regexp
    ...    ${onap_value}    (?i)SubNetwork=\\d\+,ManagedElement=MRBTS-\\d\+\[,\\w\+=\\d\+\]\*
    Return From Keyword If    ${ret}    ${onap_value}
    ${transfered_value}    Set Variable    ${onap_value}
    ${btsid}    Should Match Regexp    ${onap_value}    (?i)MRBTS-\\d\+
    ${btsid}    Set Variable    ${btsid.split("-")[-1]}
    ${ret}    Run Keyword And Return Status    Should Not Match Regexp
    ...    ${onap_value}    (?i)SubNetwork=${btsid},ManagedElement=MRBTS-${btsid}\[,\\w\+=\\d\+\]\*
    Return From Keyword If    ${ret}    ${transfered_value}
    ${tmp}    Should Match Regexp    ${onap_value}    (?i)MRBTS-${btsid}\[,\\w\+=\\d\+\]\*
    ${transfered_value}    Set Variable    ${tmp.replace('=','-').replace(',','/')}
    [Return]    ${transfered_value}

Transfer SCF DN To Xpath Of ONAP Get Result
    [Arguments]    ${dn}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Transfer SBTS SCF DN to Xpath of ONAP SCF file.
    ...
    ...    *Example*
    ...    | ${xpath} | Transfer SCF DN To Xpath Of ONAP Get Result | MRBTS-1894/MNL-1/MNLENT-1 |
    ...    ${xpath} shall be ManagedElement/MNL/id[text()="1"]/../MNLENT/id[text()="1"]/..
    ${dn_steps}    Split String    ${dn}    /
    Remove From List    ${dn_steps}    0
    ${xpath_steps}    Create List    ManagedElement
    FOR    ${dn_step}    IN    @{dn_steps}
        ${type}    Fetch From Left    ${dn_step}    -
        ${id}    Fetch From Right    ${dn_step}    -
        Append To List    ${xpath_steps}    /${type}/id[text()="${id}"]/..
    END
    ${xpath}    Catenate    SEPARATOR=    @{xpath_steps}
    LOG    ${xpath}
    [Return]    ${xpath}

Get List Value From ONAP Get Result
    [Arguments]    ${xpath}    ${scf_param_name}    ${onap_get_content}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get MO Different List Parameters Of Netconf Get'.
    ${count_onap}    L_XML.Get Element Count    ${onap_get_content}    ${xpath}/attributes/${scf_param_name}/simpleId
    ${list_param_val}    Create List
    FOR    ${index}    IN RANGE    ${0}    ${count_onap}
        ${onap_param_val}    L_XML.Get Element Text    ${onap_get_content}
        ...    ${xpath}/attributes/${scf_param_name}/simpleId[text()="[${index}]"]/../${scf_param_name}
        ${onap_param_val}    Transfer ONPA DN To MO Path    ${onap_param_val}
        Append To List    ${list_param_val}    ${onap_param_val}
    END
    [Return]    ${list_param_val}

Get Structure Value From ONAP Get Result
    [Arguments]    ${xpath}    ${scf_param_name}    ${list_scf_items}    ${onap_get_content}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get MO Different Struture Parameters Of Netconf Get'.
    ${count_onap}    L_XML.Get Element Count    ${onap_get_content}    ${xpath}/attributes/${scf_param_name}/complexId
    ${list_param_val}    Create List
    FOR    ${index}    IN RANGE    ${0}    ${count_onap}
        ${empty_list}    Create List
        ${child_names}    Run Keyword If    '${list_scf_items.__len__()}'!='${0}'    Get Dictionary Keys    ${list_scf_items[${index}]}
        ${child_names}    Set Variable If    '${list_scf_items.__len__()}'!='${0}'    ${child_names}    ${empty_list}
        ${onap_item_element}    L_XML.Get Element    ${onap_get_content}    ${xpath}/attributes/${scf_param_name}/complexId[text()="[${index}]"]/..
        ${dic_onap_item}    Get Value From ONAP Item Element    ${onap_item_element}    ${child_names}
        Append To List    ${list_param_val}    ${dic_onap_item}
    END
    [Return]    ${list_param_val}

Get Value From ONAP Item Element
    [Arguments]    ${onap_item_element}    ${child_names}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Get Structure Value From ONAP Get Result'.
    ${dic_onap_item}    Create Dictionary
    FOR    ${child_name}    IN    @{child_names}
        ${found_on_onap}    Run Keyword And Return Status    L_XML.Element Should Exist    ${onap_item_element}    .//${child_name}
        Run Keyword If    not ${found_on_onap}    Continue For Loop
        ${onap_param_val}    L_XML.Get Element Text    ${onap_item_element}    .//${child_name}
        ${onap_param_val}    Transfer ONPA DN To MO Path    ${onap_param_val}
        Set To Dictionary    ${dic_onap_item}    ${child_name}    ${onap_param_val}
    END
    [Return]    ${dic_onap_item}

Get MO Different P Parameters Of Netconf Get
    [Arguments]    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Compare all parameters of ${dn} between ${scf_content} and ${onap_get_content}, save them to ${diff_values} and ${not_exist_values}.
    ...    ${not_exist_values} stored those not found in ${onap_get_content}.This KW can not be used for parameter type of list or structrure.
    ${param_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${dn}"]/p
    Return From Keyword If    '${param_elements.__len__()}'=='${0}'    ${diff_values}    ${not_exist_values}
    ${xpath}    Transfer SCF DN To Xpath Of ONAP Get Result    ${dn.replace("PLMN-PLMN/","")}
    FOR    ${param_element}    IN    @{param_elements}
        ${scf_param_name}    L_XML.Get Element Attribute    ${param_element}    name
        ${scf_param_val}    L_XML.Get Element Text    ${param_element}
        ${found_on_onap}    Run Keyword And Return Status    L_XML.Element Should Exist    ${onap_get_content}
        ...    ${xpath}/attributes/${scf_param_name}
        ${tmp_dic}    Create Dictionary    val_scf=${scf_param_val}    val_onap=NOT_EXIST
        Run Keyword If    not ${found_on_onap}    Set To Dictionary    ${not_exist_values}    ${scf_param_name}    ${tmp_dic}
        Run Keyword If    not ${found_on_onap}    Continue For Loop
        ${onap_param_val}    L_XML.Get Element Text    ${onap_get_content}    ${xpath}/attributes/${scf_param_name}
        ${onap_param_val}    Transfer ONPA DN To MO Path    ${onap_param_val}
        ${ret}    Run Keyword And Return Status    Should Be Equal As Strings    ${scf_param_val}    ${onap_param_val}
        ${tmp_dic}    Create Dictionary    val_scf=${scf_param_val}    val_onap=${onap_param_val}
        Run Keyword If    not ${ret}    Set To Dictionary    ${diff_values}    ${scf_param_name}    ${tmp_dic}
    END

Get MO Different List Parameters Of Netconf Get
    [Arguments]    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Compare all list parameters of ${dn} between ${scf_content} and ${onap_get_content}, save them to ${diff_values} and ${not_exist_values}.
    ...    ${not_exist_values} stored those not found in ${onap_get_content}.This KW can be used for parameter type of list only.
    ${list_param_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${dn}"]/list/p/..
    Return From Keyword If    '${list_param_elements.__len__()}'=='${0}'    ${diff_values}    ${not_exist_values}
    ${xpath}    Transfer SCF DN To Xpath Of ONAP Get Result    ${dn.replace("PLMN-PLMN/","")}
    FOR    ${list_param_element}    IN    @{list_param_elements}
        ${scf_param_name}    L_XML.Get Element Attribute    ${list_param_element}    name
        ${list_param_val_of_SCF}    Get List Value From SCF    ${dn}    ${scf_param_name}    ${scf_content}
        ${found_on_onap}    Run Keyword And Return Status    L_XML.Element Should Exist    ${onap_get_content}
        ...    ${xpath}/attributes/${scf_param_name}
        ${tmp_dic}    Create Dictionary    val_scf=${list_param_val_of_SCF}    val_onap=NOT_EXIST
        Run Keyword If    not ${found_on_onap}    Set To Dictionary    ${not_exist_values}    ${scf_param_name}    ${tmp_dic}
        Run Keyword If    not ${found_on_onap}    Continue For Loop
        ${list_param_val_of_ONAP}    Get List Value From ONAP Get Result    ${xpath}    ${scf_param_name}    ${onap_get_content}
        ${ret}    Run Keyword And Return Status    Lists Should Be Equal    ${list_param_val_of_SCF}    ${list_param_val_of_ONAP}
        ${tmp_dic}    Create Dictionary    val_scf=${list_param_val_of_SCF}    val_onap=${list_param_val_of_ONAP}
        Run Keyword If    not ${ret}    Set To Dictionary    ${diff_values}    ${scf_param_name}    ${tmp_dic}
    END

Get MO Different Struture Parameters Of Netconf Get
    [Arguments]    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Compare all list parameters of ${dn} between ${scf_content} and ${onap_get_content}, save them to ${diff_values} and ${not_exist_values}.
    ...    ${not_exist_values} stored those not found in ${onap_get_content}. This KW can be used for parameter type of structure only.
    ${structure_param_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${dn}"]/list/item/..
    Return From Keyword If    '${structure_param_elements.__len__()}'=='${0}'    ${diff_values}    ${not_exist_values}
    ${xpath}    Transfer SCF DN To Xpath Of ONAP Get Result    ${dn.replace("PLMN-PLMN/","")}
    FOR    ${structure_param_element}    IN    @{structure_param_elements}
        ${scf_param_name}    L_XML.Get Element Attribute    ${structure_param_element}    name
        ${list_scf_items}    Get Structure Value From SCF    ${dn}    ${scf_param_name}    ${scf_content}
        ${list_onap_items}    Get Structure Value From ONAP Get Result    ${xpath}    ${scf_param_name}    ${list_scf_items}    ${onap_get_content}
        ${ret}    Run Keyword And Return Status    Lists Should Be Equal    ${list_scf_items}    ${list_onap_items}
        ${tmp_dic}    Create Dictionary    val_scf=${list_scf_items}    val_onap=${list_onap_items}
        Run Keyword If    not ${ret}    Set To Dictionary    ${diff_values}    ${scf_param_name}    ${tmp_dic}
    END

Remove Ignore Parameters-delete
    [Arguments]    ${source_dic}    ${ignored_dic}=${ONAP_IGNORE_PARAMS}
    ${MOs}    Get Dictionary Keys    ${ignored_dic}
    FOR    ${MO}    IN    @{MOs}
        ${has_not_MO}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${source_dic}    ${MO}
        Continue For Loop If    ${has_not_MO}
        ${param_names}    Get From Dictionary    ${ignored_dic}    ${MO}
        Remove From Dictionary    ${source_dic['${MO}']}    @{param_names}
        ${count}    Get Length    ${source_dic['${MO}']}
        Run Keyword If    ${count}==${0}    Remove From Dictionary    ${source_dic}    ${MO}
    END
    [Return]    ${source_dic}

Remove Ignore Parameters
    [Arguments]    ${source_dic}
    ${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    ${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    Set Test Variable    ${ONAP_IGNORE_PARAMS}
    ${MOs}    Get Dictionary Keys    ${ONAP_IGNORE_PARAMS}
    FOR    ${MO}    IN    @{MOs}
        ${has_not_MO}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${source_dic}    ${MO}
        Continue For Loop If    ${has_not_MO}
        ${param_names}    Get From Dictionary    ${ONAP_IGNORE_PARAMS}    ${MO}
        Remove From Dictionary    ${source_dic['${MO}']}    @{param_names}
        ${count}    Get Length    ${source_dic['${MO}']}
        Run Keyword If    ${count}==${0}    Remove From Dictionary    ${source_dic}    ${MO}
    END
    [Return]    ${source_dic}

Generate Filter Strings For Create And Remove MOs
    [Arguments]    ${scf_dns}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    return as:
    ...    ['ManagedElement/LNBTS/id[text()="3552"]/../LNCEL/id[text()="8"]',
    ...    'ManagedElement/LNBTS/id[text()="3552"]/../LNCEL/id[text()="8"]/..']
    ...
    ...    *Example*
    ...    | ${cmd_head} | Set Variable | get-config --source running --filter-xpath |
    ...    | ${dns} | Create List | MRBTS-1894/LNBTS-3552/LNCEL-8 | MRBTS-1894/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-8 |
    ...    | ${onap_remove_filter_str} | ${onap_create_filter_str} | Generate Filter Strings For Create And Remove MOs | ${dns} |
    ...    | ${cmd_delete_mos} | Set Variable | ${cmd_head} ${onap_remove_filter_str} --out=/tmp/f1.xml |
    ...    | ${cmd_mos_backup} | Set Variable | ${cmd_head} ${onap_create_filter_str} --out=/tmp/f2.xml |
    ...    | Execute NetConf Command On ONAP Simulator | ${cmd_delete_mos} |
    ...    | Execute NetConf Command On ONAP Simulator | ${cmd_mos_backup} |
    ${onap_scf_dns_remove}    Create List
    ${onap_scf_dns_create}    Create List
    FOR    ${scf_dn}    IN    @{scf_dns}
        ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${scf_dn}
        Append To List    ${onap_scf_dns_create}    ${onap_path}
        ${onap_path}    Split String From Right    ${onap_path}    /..    1
        Append To List    ${onap_scf_dns_remove}    ${onap_path[0]}
    END
    ${onap_remove_filter_str}    Catenate    SEPARATOR=|    @{onap_scf_dns_remove}
    Log    ${onap_remove_filter_str}
    ${onap_create_filter_str}    Catenate    SEPARATOR=|    @{onap_scf_dns_create}
    Log    ${onap_create_filter_str}
    [Return]    ${onap_remove_filter_str}    ${onap_create_filter_str}

Modify ONAP Plan Create Or Delete MOs
    [Arguments]    ${parsed_xml}    ${scf_dns}    ${oper}
    [Documentation]    Modify element 'ManagedElement' from parsed ONAP SCF file using library XML without lxml.
    ...    Will not save file.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | parsed_xml | Yes |element get from ONAP SCF |
    ...    | scf_dns | Yes | DN from SBTS SCF |
    ...    | oper | Yes | must be one of [delete,create] |
    ...
    ...    *EXAMPLE*
    ...    | ${oper} | Set Variable | create |
    ...    | ${dns} | Create List | MRBTS-1894/LNBTS-3552/LNCEL-8 |
    ...    | ${xml} | XML.Parse Xml | 1894.xml |
    ...    | ${parsed_xml} | XML.Get Element |${xml} | ManagedElement |
    ...    | Modify ONAP Plan Create Or Delete MOs | ${parsed_xml} | ${dns} | ${oper} |
    Should Be Equal As Strings    ${parsed_xml.tag}    ManagedElement
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    FOR    ${scf_dn}    IN    @{scf_dns}
        _Modify ONAP Plan Create Or Delete MO    ${parsed_xml}    ${scf_dn}    ${oper}
    END

_Modify ONAP Plan Create Or Delete MO
    [Arguments]    ${parsed_xml}    ${scf_dn}    ${oper}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Called by KW 'Modify ONAP Plan Create Or Delete MOs'.
    ${tag}    Set Variable    ${scf_dn.split('/')[-1].split('-')[0]}
    ${dn_id}    Set Variable    ${scf_dn.split('-')[-1]}
    ${count}    XML.Get Element Count    ${parsed_xml}    .//${tag}
    ${index}    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    ${1}    ${count+1}
        ${id}    XML.Get Element Text    ${parsed_xml}    .//${tag}\[${i}\]/id
        Continue For Loop If    '${dn_id}'!='${id}'
        ${index}    Set Variable    ${i}
    END
    Should Not Be Equal    ${index}    ${EMPTY}
    XML.Set Elements Attribute    ${parsed_xml}    nc:operation    ${oper}    .//${tag}\[${index}\]

Modify ONAP Plan Parameters Of MO
    [Arguments]    ${scf_dn}    ${dic_param}    ${element_ManagedElement}    ${oper}=modify
    [Documentation]    Modify element 'ManagedElement' from parsed ONAP SCF file using library XML without lxml.
    ...    Will not save file.
    ...    For parameter type is list, should be param_name[position], like refNrCellGroup[1].
    ...    For parameter type is structure, should be param_name[position].sub_param_name,like a2MeasReleaseSsbRsrp[1].a2HysteresisReleaseSsbRsrp.
    ...    Position is the Xpath position, the index of the parameter in source_scf_file, starts from 1.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | scf_dn | Yes | DN from SBTS SCF |
    ...    | dic_params | Yes | {param1:val1,param2:val2} |
    ...    | element_ManagedElement | Yes | element get from ONAP SCF |
    ...    | oper | No | must be one of [modify,delete,create] |
    ...
    ...    *EXAMPLE*
    ...    | ${oper} | Set Variable | delete |
    ...    | ${dic_param1} | Create Dictionary | refNrCellGroup[2] | ${EMPTY} | refNrCellGroup[1] | 0 |
    ...    | ${dns} | Create List | MRBTS-1894/LNBTS-3552/LNCEL-8 |
    ...    | ${xml} | XML.Parse Xml | 1894.xml |
    ...    | ${parsed_xml} | XML.Get Element | ${xml} | ManagedElement |
    ...    | Modify ONAP Plan Parameters Of MO | ${scf_dn} | ${dic_param1} | ${parsed_xml} | ${oper} |
    Should Be Equal As Strings    ${element_ManagedElement.tag}    ManagedElement
    XML.Set Element Attribute    ${element_ManagedElement}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    ${tag}    Set Variable    ${scf_dn.split('/')[-1].split('-')[0]}
    ${dn_id}    Set Variable    ${scf_dn.split('-')[-1]}
    ${count}    XML.Get Element Count    ${element_ManagedElement}    .//${tag}
    ${index}    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    ${1}    ${count+1}
        ${id}    XML.Get Element Text    ${element_ManagedElement}    .//${tag}\[${i}\]/id
        Continue For Loop If    '${dn_id}'!='${id}'
        ${index}    Set Variable    ${i}
    END
    Should Not Be Equal    ${index}    ${EMPTY}
    ${onap_path}    Set Variable    .//${tag}\[${index}\]/attributes
    ${p_names}    Get Dictionary Keys    ${dic_param}
    FOR    ${p_name}    IN    @{p_names}
        ${position}    Get Regexp Matches    ${p_name.split('.')[0]}    \\[\\d+\\]
        Should Be True    ${position.__len__()} < 2    ${p_name} is not a valid parameter name.
        ${has_index}    Evaluate    "${position.__len__()}"=="1"
        ${first_name}    Set Variable If    ${has_index}    ${p_name.split('[')[0]}    ${EMPTY}
        ${last_name}    Set Variable    ${p_name.split('.')[-1].split('[')[0]}
        ${position}    Run Keyword If    ${has_index}    Should Match Regexp    ${position[0]}    \\d+
        ${position}    Run Keyword If    ${has_index}    Convert To Integer    ${position}
        ${xpath}    Set Variable If    "${first_name}"==""    ${onap_path}/${last_name}    ${onap_path}/${first_name}\[${position}\]/${last_name}
        Run Keyword If    "${oper}"=="modify"    XML.Set Element Text    ${element_ManagedElement}    ${dic_param["${p_name}"]}    xpath=${xpath}
        Run Keyword If    "${oper}"=="delete"    XML.Set Element Attribute    ${element_ManagedElement}    nc:operation    delete    xpath=${xpath}
        Run Keyword If    "${oper}"=="create"    XML.Set Element Attribute    ${element_ManagedElement}    nc:operation    create    xpath=${xpath}
    END

Generate Delta Plan For NetConf
    [Arguments]    ${dic_params}    ${source_scf_file}    ${new_scf_file}    ${oper}=modify
    [Documentation]    Modify given ONAP SCF file and save as a new ONAP SCF file.
    ...    For parameter type is list, should be param_name[position], like refNrCellGroup[1]
    ...    For parameter type is structure, should be param_name[position].sub_param_name,
    ...    like a2MeasReleaseSsbRsrp[1].a2HysteresisReleaseSsbRsrp
    ...    Position is the Xpath position, the index of the parameter in source_scf_file, starts from 1
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | dic_params | Yes | {dn1:{param1:val1,param2:val2},dn2:{param1:val1,param2:val2}...} |
    ...    | source_scf_file | Yes | ONAP SCF file name |
    ...    | new_scf_file | Yes | Generated ONAP SCF file name |
    ...    | oper | No | must be one of [modify,delete,create] |
    ...
    ...    *EXAMPLE*
    ...    | ${oper} | Set Variable | create \ |
    ...    | ${dic_param1} | Create Dictionary | refNrCellGroup[2] | ${EMPTY} | refNrCellGroup[1] | 0 |
    ...    | ${dic_param2} | Create Dictionary | a2MeasReleaseSsbRsrp[1].a2HysteresisReleaseSsbRsrp | 2.2 | actARPBasedAC | on |
    ...    | ${dic_params} | Create Dictionary | MRBTS-1894/NRBTS-10534/NRDU-1=${dic_param1} | MRBTS-1894/NRBTS-10534/NRCELL-2=${dic_param2} |
    ...    | ${source_scf_file} | Set Variable | ${BTSFiles}/1894_debug_m.xml |
    ...    | ${new_scf_file} | Set Variable | ${BTSFiles}/new_1894_debug_m.xml |
    ${parsed_xml}    XML.Parse XML    ${source_scf_file}
    ${e_onap}    Run Keyword If    '${parsed_xml.tag}'!='ManagedElement'    XML.Get Element    ${parsed_xml}    ManagedElement
    ${e_manageElement}    Set Variable If    '${parsed_xml.tag}'!='ManagedElement'    ${e_onap}    ${parsed_xml}
    ${scf_dns}    Get Dictionary Keys    ${dic_params}
    FOR    ${scf_dn}    IN    @{scf_dns}
        ${dic_param}    Get From Dictionary    ${dic_params}    ${scf_dn}
        Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_manageElement}    ${oper}
    END
    XML.Save XML    ${e_manageElement}    ${new_scf_file}

Execute NetConf Command On ONAP Simulator
    [Arguments]    ${host_name}    ${host_ip}    ${user}    ${pwd}    ${cmd}    ${ssh_cmd_timeout}=360
    [Documentation]    Keyword used for execute NetConf Command On ONAP Simulator
    ...    - 05.19.2025 - Xu Yuyan updated for Cloud
    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=${ssh_cmd_timeout}
    #${cmd_conn}    Catenate    connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem
    #...    --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem
    ${cmd_conn}    Catenate    connect --tls --host ${host_name} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${ret}

Get File From Simulator To Local
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${simulator_path}    ${local_file_path}=${EMPTY}
    [Documentation]    Keyword used for get file from simulator path to local path
    ...   - 25.06.2025 - Kang Lixin updated for Cloud
    ...   | Input Parameters | Man. | Description |
    ...   | host_ip          | yes  | Simulator VM ip |
    ...   | user             | yes  | Simulator VM username |
    ...   | pwd              | yes  | Simulator VM passowrd |
    ...   | simulator_path   | yes  | File on Simulator path |
    ...   | local_file_path  | yes  | File on current VM path |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Get File From Simulator To Local | host_ip=10.97.78.55 | user=ute | pwd=ute |
    ...    | simulator_path=/tmp/${fileName_init} | local_file_path=${Test Results Dir}/${fileName_init} |
    ${local_file_path}    Set Variable If
    ...    '${local_file_path}'=='${EMPTY}'    ${TEST_LOG_DIRECTORY}/${simulator_path.split('/')[-1]}    ${local_file_path}
    SSHLibrary.Open Connection    host=${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=#
    SSHLibrary.Get File    /tmp/${simulator_path.split('/')[-1]}    ${local_file_path}
    sleep    10s
    [Teardown]    SSHLibrary.Close Connection

Put File From Local To Simulator
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${simulator_path}    ${local_file_path}
    [Documentation]    Keyword used for put file from local path to simulator path
    ...   | Input Parameters | Man. | Description |
    ...   | host_ip          | yes  | Simulator VM ip |
    ...   | user             | yes  | Simulator VM username |
    ...   | pwd              | yes  | Simulator VM passowrd |
    ...   | local_file_path  | yes  | File on current VM path |
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Put File From Local To Simulator | host_ip=10.97.78.55 | user=ute | pwd=ute |
    Log To Console    ${simulator_path}
    SSHLibrary.Open Connection    host=${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=#
    SSHLibrary.Put File    ${local_file_path}    /tmp/${local_file_path.split('/')[-1]}
    [Teardown]    SSHLibrary.Close Connection

Start VES Log Listen On ONAP Simulator
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${ves_path}=/home/ute/ves
    [Documentation]    Keyword used for start collect ccn log on ONAP simulator
    ...   | Input Parameters | Man. | Description |
    ...   | host_ip          | yes  | Simulator VM ip |
    ...   | user             | yes  | Simulator VM username |
    ...   | pwd              | yes  | Simulator VM passowrd |
    ...   | ves_path         | no  | VES Simulator installed path |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Start VES Log Listen On ONAP Simulator | host_ip=10.97.78.55 | user=ute | pwd=ute |
    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Write    cd ${ves_path}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ps aux | grep VES_simulator.py|grep -v grep | awk '{print $2}'
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${got_process_id}    Run Keyword And Return Status    Convert To Integer    ${out_put.split()[0]}
    Run Keyword If    ${got_process_id}    Run Keywords    SSHLibrary.Write    kill -9 ${out_put.split()[0]}
    ...    AND    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    rm ${ves_path}/log_text.text
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    nohup python3 VES_simulator.py > out.log 2>&1 &
    SSHLibrary.Read Until Prompt
    [Teardown]    SSHLibrary.Close Connection

Stop VES Log Listen On ONAP Simulator
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${ves_path}=/home/ute/ves    ${log_path}=${TEST_LOG_DIRECTORY}
    [Documentation]    Keyword used for stop collect ccn log on ONAP simulator, and return CCN messages by a list
    ...   | Input Parameters | Man. | Description |
    ...   | host_ip          | yes  | Simulator VM ip |
    ...   | user             | yes  | Simulator VM username |
    ...   | pwd              | yes  | Simulator VM passowrd |
    ...   | ves_path         | no  | VES Simulator installed path |
    ...   | log_path         | no  | default value is ${Test Results Dir} |
    ...
    ...   | Return Value | Description |
    ...   | VES_CCN_msgs | list, return CCN messages |
    ...
    ...    Example
    ...    | VES_CCN_msgs | Stop VES Log Listen On ONAP Simulator | host_ip=10.97.78.55 | user=ute | pwd=ute |
    ${VES_CCN_msgs}    Create List
    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Write    ps aux | grep VES_simulator.py|grep -v grep | awk '{print $2}'
    ${out_put}    SSHLibrary.Read Until Prompt
    ${out_put}    Set Variable    ${out_put.replace("\x1b[?2004l\r","")}
    ${got_process_id}    Run Keyword And Return Status    Convert To Integer    ${out_put.split()[0]}
    Run Keyword If    ${got_process_id}    Run Keywords    SSHLibrary.Write    kill -9 ${out_put.split()[0]}
    ...    AND    SSHLibrary.Read Until Prompt
    ${ccn_not_catched}    Run Keyword And Return Status    SSHLibrary.File Should Not Exist    ${ves_path}/log_text.text
    Return From Keyword If    ${ccn_not_catched}    ${VES_CCN_msgs}
    ${time}    Get Time    epoch
    SSHLibrary.Get File    ${ves_path}/log_text.text    ${log_path}/ves_log_text_${time}.txt
    SSHLibrary.Write    rm ${ves_path}/log_text.text
    ${VES_CCN_Sample_str}    OperatingSystem.Get File    ${log_path}/ves_log_text_${time}.txt
    ${VES_CCN_lines}    Split String    ${VES_CCN_Sample_str}    POST
    FOR    ${VES_CCN_line}    IN    @{VES_CCN_lines}
        Continue For Loop If    """${VES_CCN_line.strip()}"""==""""""
        ${VES_CCN_line}    Replace String Using Regexp    ${VES_CCN_line}    :[\\s]*true[\\s]*    :"true"
        ${VES_CCN_line}    Replace String Using Regexp    ${VES_CCN_line}    :[\\s]*false[\\s]*    :"false"
        ${dic_CCN}    Evaluate    ${VES_CCN_line.strip()}
        Append To List    ${VES_CCN_msgs}    ${dic_CCN}
    END
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${VES_CCN_msgs}