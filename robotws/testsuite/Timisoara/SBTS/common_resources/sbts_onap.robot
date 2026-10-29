*** Settings ***
Library  python_resources/onap_resource.py

Documentation  This suite contains KWs used by ONAP TCS.


*** Keywords ***
Delete And Recreate MPLANEONAP Object
    [Documentation]  This keyword is used to delete and recreate MPLANEONAP object
    [Arguments]  ${recovery_timeout}

    Log  Deleting MPLANEONAP object  console=true
    Delete MPLANEONAP Object
    Wait Until Keyword Succeeds  ${recovery_timeout}  30
    ...  Check Modules And Cells
    Log  Creating MPLANEONAP object  console=true
    Create MPLANEONAP Object


Create MPLANEONAP Object
    [Documentation]
    ...  This keyword creates MPLANEONAP object, with it's parameters
    ...  *AUTHOR* anna.benzar@nokia.com

    ${mplane_onap}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dict_heart_beat_sending_interval}  Create Dictionary  parameterName=heartBeatSendingInterval  operation=update  value=0
    ${dict_m_plane_address_dn}  Create Dictionary  parameterName=mPlaneAddressDN  operation=update
    ...  value=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${dict_activate_oran_o1_netconf_service}  Create Dictionary  parameterName=activateOranO1NetconfService  operation=update  value=false
    ${dict_activate_sending_bulk_pm_events}  Create Dictionary  parameterName=activateSendingBulkPmEvents  operation=update  value=false
    ${dict_activate_sending_fm_events}  Create Dictionary  parameterName=activateSendingFmEvents  operation=update  value=false
    ${dict_activate_sending_pnf_registration}  Create Dictionary  parameterName=activateSendingPnfRegistration  operation=update  value=false
    ${dict_pnf_registration_event_sending_interval}  Create Dictionary  parameterName=pnfRegistrationEventSendingInterval  operation=update
    ...  value=300
    ${dict_pnf_registration_scenario_timeout}  Create Dictionary  parameterName=pnfRegistrationScenarioTimeout  operation=update  value=1440
    ${dict_ves_ack_timeout}  Create Dictionary  parameterName=vesAckTimeout  operation=update  value=5
    @{parameter_list}  Create List  ${dict_heart_beat_sending_interval}  ${dict_m_plane_address_dn}  ${dict_activate_oran_o1_netconf_service}
    ...  ${dict_activate_sending_bulk_pm_events}  ${dict_activate_sending_fm_events}  ${dict_activate_sending_pnf_registration}
    ...  ${dict_pnf_registration_event_sending_interval}  ${dict_pnf_registration_scenario_timeout}  ${dict_ves_ack_timeout}
    Perform Object Recommissioning  dist_name=${mplane_onap}  operation=create  parameter=@{parameter_list}


Delete MPLANEONAP Object
    [Documentation]
    ...  This keyword deletes MPLANEONAP object
    ...  *AUTHOR* anna.benzar@nokia.com

    ${parameter_list}  Create List
    ${mplane_onap}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    Perform Object Recommissioning  dist_name=${mplane_onap}  operation=delete  parameter=${parameter_list}


Add Certificates To CMP Object
    [Documentation]
    ...  This keyword adds certificates to CMP object
    ...  CMP object is used for ONAP object creation
    ...  *AUTHOR* anna.benzar@nokia.com

    ${cmp_dn}  Set Variable  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${cmp_dn}  update  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  caSubjectName  C=PL, O=Common, CN=IPSEC  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  serverHost  10.42.54.13  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  serverPort  8080  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  delta_file.json  delta_id=${delta_id}
    Perform Delta Recommissioning  delta_file.json  skip_parameter_relation_errors=True


Add VESENDPOINT-ID
    [Documentation]
    ...  This keyword adds VESENDPOINT ids to ONAP object
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${vesend_no}

    ${vesend}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${vesend_no}
    ${dict_enable_hostname_validation}  Create Dictionary  parameterName=enableHostnameValidation  operation=update  value=False
    ${dict_ves_endpoint_id}  Create Dictionary  parameterName=vesEndpointId  operation=update  value=${vesend_no}
    ${dict_ves_endpoint_ip_address}  Create Dictionary  parameterName=vesEndpointIpAddress  operation=update  value=${WORKER_IP}
    ${dict_ves_endpoint_port_number}  Create Dictionary  parameterName=vesEndpointPortNumber  operation=update  value=30420
    @{parameter_list}  Create List  ${dict_enable_hostname_validation}  ${dict_ves_endpoint_id}  ${dict_ves_endpoint_ip_address}
    ...  ${dict_ves_endpoint_port_number}
    Perform Object Recommissioning  dist_name=${vesend}  operation=create  parameter=@{parameter_list}


VES Endpoint Reference Change
    [Documentation]
    ...  This keyword changes VESENDPOINT reference in ONAP object
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${vesend_ref}  ${vesend_no}

    ${vesend}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${vesend_no}
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1  parameter=${vesend_ref}  operation=update
    ...  value=${vesend}  skip_parameter_relation_errors=${True}  timeout=180


ONAP Parameter Change
    [Documentation]
    ...  This keyword changes parameters value in ONAP
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${parameter}  ${value}

    Wait Until Keyword Succeeds  4 min  10 sec
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...  parameter=${parameter}
    ...  operation=update
    ...  value=${value}
    ...  skip_parameter_relation_errors=${TRUE}
    ...  should_activate=${TRUE}
    ...  timeout=180
    Log  Parameter ${parameter} changed to ${value}.  console=true


Configure NetConf Sever
    [Documentation]
    ...  This keyword was created to configure NetConf server on BTS.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${id}  ${certficate_fingerprint}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${id}/MNL-1/MNLENT-1/MPLANEONAP-1  activateOranO1NetconfService  true  ${delta_id}
    ${structure}  Create Dictionary
    Set To Dictionary  ${structure}  certFingerPrint  ${certficate_fingerprint}
    Set To Dictionary  ${structure}  mapType  specified
    Set To Dictionary  ${structure}  userName  fm-pm
    Append Complex Item To Delta  MRBTS-${id}/MNL-1/MNLENT-1/MPLANEONAP-1  list_name=certToNameMappingList  &{structure}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_netconf.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_netconf.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Check If Netconf Server Is Running
    [Documentation]  This keyword is used to check if netconf server is running

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  alias=bts_connection  prompt=>
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    SSHLibrary.Start Command  netstat -alnp | grep tcp
    ${output}  SSHLibrary.Read Command Output
    ${line}  Get Lines Containing String  ${output}  netopeer2-ser
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${line}  LISTEN
    Run Keyword If  ${status}
    ...  Log  NetConf server is running and listening for connection on port TCP:6513.  console=true
    ...  ELSE
    ...  Set Test Restriction  NetConf server is not running on BTS.
    SSHLibrary.Close Connection


Get AlarmList On Netconf
    [Documentation]
    ...  This keyword was created to retrive alarmRecords list on NetConf interface.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${id}  ${mplane}  ${onap_worker_ip}

    ${integration_command}  Catenate  SEPARATOR=${SPACE}  curl --request PUT -k \
    ...  --url https://${onap_worker_ip}:30205/restconf/config/network-topology:network-topology/topology/topology-netconf/node/MRBTS \
    ...  --header 'accept: application/json' \
    ...  --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==' \
    ...  --header 'content-type: application/xml' \  --cookie JSESSIONID=1o6tqx4jyrgsw49gaffvai1j1 \
    ...  --data '<node xmlns="urn:TBD:params:xml:ns:yang:network-topology">  <node-id>MRBTS</node-id>
    ...  <key-based xmlns="urn:opendaylight:netconf-node-topology">
    ...  <key-id xmlns="urn:opendaylight:netconf-node-topology">ODL_private_key_0</key-id>
    ...  <username xmlns="urn:opendaylight:netconf-node-topology">fm-pm</username>  </key-based>
    ...  <host xmlns="urn:opendaylight:netconf-node-topology">${mplane}</host>  <port xmlns="urn:opendaylight:netconf-node-topology">6513</port>
    ...  <tcp-only xmlns="urn:opendaylight:netconf-node-topology">false</tcp-only>  <protocol xmlns="urn:opendaylight:netconf-node-topology">
    ...  <name xmlns="urn:opendaylight:netconf-node-topology">TLS</name>  </protocol>
    ...  <max-connection-attempts xmlns="urn:opendaylight:netconf-node-topology">2</max-connection-attempts>  </node>'
    ${integration_output}  Run  ${integration_command}
    Checking Connection Status On Netconf  ${mplane}  ${onap_worker_ip}
    ${url_value}  Catenate  SEPARATOR=  https://${onap_worker_ip}:30205/restconf/operational/network-topology:network-topology
    ...  /topology/topology-netconf/node/MRBTS/yang-ext:mount/_3gpp-common-managed-element:ManagedElement/MRBTS-${id} \
    ${get_command}  Catenate  SEPARATOR=${SPACE}  curl -k --request GET \  --url ${url_value}  --header 'accept: application/json' \
    ...  --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==' \
    ...  --header 'content-type: application/xml' \  --cookie JSESSIONID=wjj28qtrpu8q1p2zsiibrde3
    ${get_output}  Run  ${get_command}
    ${string_1}  Fetch From Right  ${get_output}  "alarmRecords":[
    ${string_2}  Fetch From Left  ${string_1}  ],"administrativeState"
    ${string_3}  Remove String Using Regexp  ${string_2}  \\n[0-9]+.*[0-9]+.*\\n
    @{records}  Split String  ${string_3}  },{
    @{alarm_records_list}  Create List
    FOR  ${item}  IN  @{records}
        ${var_1}  Remove String  ${item}  {  }
        ${var_2}  Replace String  ${var_1}  "  '
        ${var_3}  Replace String  ${var_2}  :'  :${SPACE}'
        ${var_4}  Replace String  ${var_3}  ','  ':${SPACE}'
        ${var_5}  Remove String  ${var_4}  '
        ${dict}  Convert String To Dictionary  ${var_5}  :${SPACE}
        Append To List  ${alarm_records_list}  ${dict}
    END
    ${delete_command}  Catenate  SEPARATOR=${SPACE}  curl --request DELETE -k \
    ...  --url https://${onap_worker_ip}:30205/restconf/config/network-topology:network-topology/topology/topology-netconf/node/MRBTS \
    ...  --header 'accept: application/json' \
    ...  --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==' \
    ...  --header 'content-type: application/xml' \  --cookie JSESSIONID=1o6tqx4jyrgsw49gaffvai1j1
    ${delete_output}  Run  ${delete_command}

    [Return]  ${alarm_records_list}


Checking Connection Status On Netconf
    [Documentation]
    ...  This keyword was created to checking integration/connection status between MRBTS and ONAP on NetConf via RESTCONF API.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${mplane}  ${onap_worker_ip}

    ${connection_command}  Catenate  SEPARATOR=${SPACE}  curl -k --request GET \
    ...  --url https://${onap_worker_ip}:30205/restconf/operational/network-topology:network-topology/topology/topology-netconf \
    ...  --header 'accept: application/json' \
    ...  --header 'authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==' \
    ...  --header 'content-type: application/json' \  --cookie JSESSIONID=wjj28qtrpu8q1p2zsiibrde3 | json_pp
    ${connection_output}  Run  ${connection_command}
    ${connection_status}  Run Keyword And Return Status
    ...  Should Contain Any  ${connection_output}
    ...  "netconf-node-topology:connection-status" : "connecting"
    ...  "netconf-node-topology:connection-status" : "connected"
    ${topology_host}  Run Keyword And Return Status
    ...  Should Contain  ${connection_output}  "netconf-node-topology:host" : "${mplane}"
    Run Keyword If  ${connection_status} and ${topology_host}
    ...  Log  Connection status on NetConf OK.  console=true
    ...  ELSE
    ...  Set Test Restriction  Connection status on NetConf NOK.


Convert String To Dictionary
    [Documentation]
    ...  Keyword uses Split String keyword to convert given string to a dictionary.
    ...  Given string should have format: dictionary_key1<seperator>value1<seperator>dictionary_key2<seperator>value2...
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${dict_string}  ${separator}

    @{items}  Split String  ${dict_string}  ${separator}
    ${dict}  Create Dictionary  @{items}

    [Return]  ${dict}


Get AlarmId And NotificationId For Specific Alarm From AlarmRecords
    [Documentation]  This keyword is used to get alarmId and notificationId for specific alarm from alarmRecords
    [Arguments]  ${list}  ${specific_problem}

    FOR  ${item}  IN  @{list}
        ${alarm_id}  Set Variable If  ${item}[specificProblem] == ${specific_problem}  ${item}[alarmId]
        ${notification_id}  Set Variable If  ${item}[specificProblem] == ${specific_problem}  ${item}[notificationId]
        Run Keyword If  ${item}[specificProblem] == ${specific_problem}
        ...  Exit For Loop
    END

    [Return]  ${alarm_id}  ${notification_id}


Check AlarmId Format
    [Documentation]
    ...  This KW is created to check ONAP alarm id given on VES/NetConf interface.
    ...  Alarm should have following format "faultId / alarmNumber / observationTime/ alarm resource distname".
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${id}  ${fault_number}  ${alarm_number}  ${date}  ${alarm_notifier}  ${observation_time}

    ${string_eqm_id}  Fetch From Right  ${alarm_notifier}  /EQM_R-
    ${eqm_id}  Fetch From Left  ${string_eqm_id}  /APEQM_R-
    ${string_apeqm_id}  Fetch From Right  ${alarm_notifier}  /APEQM_R-
    ${apeqm_id}  Fetch From Left  ${string_apeqm_id}  /CABINET_R-
    ${string_cabinet_id}  Fetch From Right  ${alarm_notifier}  /CABINET_R-
    ${cabinet_id}  Fetch From Left  ${string_cabinet_id}  /SMOD_R-
    ${string_smod_id}  Fetch From Right  ${alarm_notifier}  /SMOD_R-
    ${smod_id}  Fetch From Left  ${string_smod_id}  /EAC_R-
    ${eac_id}  Fetch From Right  ${alarm_notifier}  /EAC_R-
    ${alarm_resource}  Catenate  SEPARATOR=,  MRBTS=${BTS_ID}  EQM_R=${eqm_id}  APEQM_R=${apeqm_id}  CABINET_R=${cabinet_id}  SMOD_R=${smod_id}
    ...  EAC_R=${eac_id}
    ${format}  Get Current Date  result_format=%Y%m%d
    ${string_time}  Remove String  ${observation_time}  ${format}
    ${time}  Convert To List  ${string_time}
    ${hour}  Catenate  SEPARATOR=:  ${time}[0]${time}[1]  ${time}[2]${time}[3]  ${time}[4]${time}[5]
    Convert To String  ${hour}
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${id}  ${fault_number}${alarm_number}${date}T${hour}.[0-9]+[+][0-9]+[:][0-9]+${alarm_resource}
    Run Keyword If  ${status}
    ...  Log  Alarm id format is ok.  console=true
    ...  ELSE
    ...  Fail  Alarm id format is not ok.


Compare Notification Ids
    [Documentation]  This keyword is used to compare notification ids
    [Arguments]  ${notification_id_1}  ${notification_id_2}  ${operation}

    ${status}  Run Keyword And Return Status
    ...  ${operation}  ${notification_id_1}  ${notification_id_2}
    Run Keyword If  ${status}
    ...  Log  ${operation} : ${notification_id_1} and ${notification_id_2} [OK].  console=true
    ...  ELSE
    ...  Fail  ${operation} : ${notification_id_1} and ${notification_id_2} [NOK].


Get Alarm Notifier From Alarm In WebEM
    [Documentation]  This keyword is used to get alarm notifier from alarm in WebEM
    [Arguments]  ${fault_id}

    ${active_alarms}  coam.Get Active Alarms
    FOR  ${item}  IN  @{active_alarms}
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${item}[faultId]  ${fault_id}
        ${alarm_notifier}  Set Variable If  ${status}  ${item}[notifier]
        Exit For Loop If  ${status}
    END

    [Return]  ${alarm_notifier}


Get Alarm BtsObservationTime From Alarm In WebEM
    [Documentation]  This keyword is used to get alarm btsObservationTime from alarm in WebEM
    [Arguments]  ${fault_id}

    ${active_alarms}  coam.Get Active Alarms
    FOR  ${item}  IN  @{active_alarms}
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${item}[faultId]  ${fault_id}
        ${alarm_bts_observation_time}  Set Variable If  ${status}  ${item}[btsObservationTime]
        Exit For Loop If  ${status}
    END

    [Return]  ${alarm_bts_observation_time}


Change Parameter ActivateSendingFmEvents
    [Documentation]
    ...  This keyword was created to update activateSendingFmEvents parameter value.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${value}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${get_parameter_value}  Get ActivateSendingFmEvents Value From Infomodel
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  activateSendingFmEvents
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=300
    ...  AND
    ...  Log  activateSendingFmEvents parameter changed to ${value}.  console=true


Get ActivateSendingFmEvents Value From Infomodel
    [Documentation]
    ...  This keyword is created to check activateSendingFmEvents parameter value from infomodel.
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${parameter_conf}  coam.Get Parameters
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/MPLANEONAP_CONF_M-1/MPLANEONAP_R-1/CONF_REF-1  distName
    ${parameter_object}  coam.Get Parameters  ${parameter_conf}[distName]  activateSendingFmEvents
    ${parameter_object_value_string}  Convert To String  ${parameter_object}[activateSendingFmEvents]
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Connect To ONAP
    [Documentation]
    ...  This keyword opens ssh connection to ONAP server.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${onap_ip}  ${onap_username}  ${onap_password}  ${onap_alias}=onap_connection  ${prompt}=$

    SSHLibrary.Open Connection  host=${onap_ip}  prompt=${prompt}  alias=${onap_alias}  timeout=60
    SSHLibrary.Switch Connection  ${onap_alias}
    SSHLibrary.Login  ${onap_username}  ${onap_password}
    Run Keyword If  '${onap_username}'=='ute'
    ...  Run Keywords
    ...  SSHLibrary.Set Client Configuration  prompt=#
    ...  AND
    ...  SSHLibrary.Write  sudo -i
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    Log  Connection to ONAP (${onap_ip}) is opened.  console=true


Connect To ONAP Container
    [Documentation]
    ...  This keyword connects to a 5G ONAP container.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${onap_alias}=onap_connection

    SSHLibrary.Switch Connection  ${onap_alias}
    ${containers}  SSHLibrary.Write  kubectl -n onap get pods
    ${containers}  SSHLibrary.Read Until Prompt
    ${ves_containers}  Get Lines Containing String  ${containers}  ves
    ${5g_container}  Get Lines Containing String  ${ves_containers}  5g
    ${running_container}  Get Lines Containing String  ${5g_container}  Running
    ${container}  Fetch From Left  ${running_container}  ${SPACE}
    SSHLibrary.Write  kubectl -n onap exec -it ${container} bash
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Read Until Prompt


Set Date And Time From ONAP
    [Documentation]
    ...  This keyword returns complete date and time and the current date from ONAP connection
    ...  Must connect to ONAP container first
    ...  *AUTHOR* anna.benzar@nokia.com

    Connect To ONAP Container
    SSHLibrary.Write  date +"%Y-%m-%d %H:%M:%S"
    ${output_date_time}  SSHLibrary.Read Until Prompt
    ${complete_date_time}  Split To Lines  ${output_date_time}  end=-1
    Set Test Variable  ${COMPLETE_DATE_TIME}  ${complete_date_time}[0]
    ${current_date}  Fetch From Left  ${COMPLETE_DATE_TIME}  ${SPACE}
    Set Test Variable  ${CURRENT_DATE}  ${current_date}
    SSHLibrary.Write  exit
    SSHLibrary.Set Client Configuration  prompt=#
    ${output}  SSHLibrary.Read Until Prompt


Check FM Event VES
    [Documentation]
    ...  This keyword checks FM events present in ONAP
    ...  Must connect to ONAP container first
    ...  Last five events of the given event type are collected, using one command
    ...  Every event time is checked and variable ${no_of_events} is incremented
    ...  Number of times of the given event present in ONAP, is printed
    ...  Must be used with keyword: Set date and time from ONAP
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${event_type}

    Connect To ONAP Container
    SSHLibrary.Write  cat logs/collector.log | grep ${event_type} | grep ${BTS_ID} | grep ${CURRENT_DATE} | tail -n 5
    SSHLibrary.Set Client Configuration  timeout=40s
    ${events}  SSHLibrary.Read Until Prompt
    ${list_of_events}  Split To Lines  ${events}  end=-1
    ${no_of_events}  Set Variable  0
    FOR  ${event}  IN  @{list_of_events}
        ${event_date_time}  Fetch From Left  ${event}  ${SPACE}INFO
        ${status_3_gpp}  Run Keyword And Return Status
        ...  Should Contain  ${event}  3GPP-FaultSupervision
        ${no_of_events}  Run Keyword If  '${event_date_time}'>'${COMPLETE_DATE_TIME}' and ${status_3_gpp}
        ...  Evaluate  ${no_of_events} + 1
        ...  ELSE
        ...  Set Variable  0
    END
    Run Keyword If  ${no_of_events} == 0
    ...  Fail  ${event_type} event not visible in ONAP.
    ...  ELSE
    ...  Log  ${event_type} event visible at least ${no_of_events} times in ONAP and is compatible with 3GPP standard.  console=true


Get VES Event With Given Text
    [Documentation]
    ...  This keyword was created to check FM events presence on VES Endpoint.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${text}  ${date}  ${file}=logs/collector.log

    Connect To ONAP Container
    SSHLibrary.Write  grep --text -n ${text} ${file} | grep ${BTS_ID} | grep ${date} | tail -1
    ${output}  SSHLibrary.Read Until Prompt
    ${output}  Get Regexp Matches  "${output}"  {"event".*}}}
    ${ves_event_json}  Evaluate  json.loads(${output}[0])  json

    [Return]  ${ves_event_json}


Setup For CB007010
    [Documentation]  This keyword is used to setup for CB007010

    Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=Initial_scf_file.xml
    Set Test Variable  ${SCF_PATH}  ${BTS_FILES}/Initial_scf_file.xml
    ${fingerprint}  Get Fingerprint
    Create MPLANEONAP Object For CB007010
    Create CertificateToNameMappingList  ${fingerprint}
    ${ves_ip}  Get VES IP
    FOR  ${ves_id}  IN RANGE  1  4
        Wait Until Keyword Succeeds  15min  1min
        ...  Create VESENDPOINT Object For CB007010  ${ves_id}  ${ves_ip}
    END
    Initialize Certificate
    Wait Until Keyword Succeeds  15min  1min
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...  parameter=activateOranO1NetconfService
    ...  operation=update
    ...  value=true
    ${param_dict_rmod}  Get List Of Params For Eac 1 Object RMOD
    ${param_dict_smod}  Get List Of Params For Eac 1 Object
    Wait Until Keyword Succeeds  15min  1min
    ...  Create EAC Object For CB007010  RMOD  IN  1  ${param_dict_rmod}
    Wait Until Keyword Succeeds  15min  1min
    ...  Create EAC Object For CB007010  SMOD  IN  1  ${param_dict_smod}
    Wait Until Keyword Succeeds  15min  1min
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...  parameter=vesFaultCollectorEndpointDN
    ...  operation=update
    ...  value=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    Wait Until Keyword Succeeds  15min  1min
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...  parameter=activateSendingFmEvents
    ...  operation=update
    ...  value=true


Get Fingerprint
    [Documentation]  This keyword is used to get fingerprint

    Connect To ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    ${cmd_cert_finger_print}  Catenate  kubectl -n onap exec -it dev-sdnc-0 -- /bin/bash -c 'openssl x509 -fingerprint -noout
    ...  -in /var/custom-certs/cert.pem | sed -e"s/SHA1 Fingerprint//; s/=//; s/=//p"'
    SSHLibrary.Write  ${cmd_cert_finger_print}
    ${fingerprint}  SSHLibrary.Read Until Prompt
    ${cert_finger_print}  Split String  ${fingerprint}

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${cert_finger_print}[0]


Create MPLANEONAP Object For CB007010
    [Documentation]  This keyword is used to create MPLANEONAP object for CB007010

    ${dist_name}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${params_list}  Get List Of Params For Mplaneonap Object  ${BTS_ID}
    Perform Object Recommissioning  dist_name=${dist_name}  parameter=${params_list}  operation=create  skip_parameter_relation_errors=${FALSE}
    ...  should_activate=${True}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30
    ...  Check Modules And Cells
    Log  MPLANEONAP object was created.  console=true


Create CertificateToNameMappingList
    [Documentation]  This keyword is used to create certificateToNameMappingList
    [Arguments]  ${fingerprint}

    ${scf_name}  Fetch From Right  ${COMMISSIONING_PATH}  node1/
    ${base_scf_path}  Collect Scf  target_file_name=${scf_name}
    Log  Scf collected.  console=true
    &{params}  Create Dictionary  certFingerPrint=02:${fingerprint}  mapType=specified  userName=cmuser
    ${new_scf_path}  Modify Scf  ${BTS_ID}  ${params}  ${base_scf_path}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30
    ...  Check Modules And Cells
    Log  Uploading scf.  console=true
    Perform Commissioning  scf_file=${new_scf_path}  skip_parameter_relation_errors=False  should_activate=True  timeout=900
    Log  Scf uploaded  console=true


Get VES IP
    [Documentation]  This keyword is used to get VES ip

    Connect To ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    SSHLibrary.Write  kubectl get pods -n onap -o=wide | grep ves | grep 5g | grep Running
    ${output}  SSHLibrary.Read Until Prompt
    ${get_onap_name}  Split String  ${output}
    SSHLibrary.Write  text=kubectl get nodes -o=wide | grep ${get_onap_name}[6]
    ${output1}  SSHLibrary.Read Until Prompt
    ${get_ves_ip}  Split String  ${output1}

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${get_ves_ip}[5]


Create VESENDPOINT Object For CB007010
    [Documentation]  This keyword is used to create VESENDPOINT object for CB007010
    [Arguments]  ${id}  ${ves_ip}

    ${dist_name}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${id}
    ${params_list}  Get List Of Params For Vesendpoint Object  ${id}  ${ves_ip}
    Perform Object Recommissioning  dist_name=${dist_name}  parameter=${params_list}  operation=create  skip_parameter_relation_errors=${FALSE}
    ...  should_activate=${True}


Create EAC Object For CB007010
    [Documentation]  Creating EAC_IN object under proper SMOD object
    [Arguments]  ${eac_type}  ${eac_direct}  ${eac_id}  ${param_dict}

    ${eac_obj_dist_name}  Run Keyword If  '${eac_type}'=='SMOD'
    ...  Set Variable  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_${eac_direct}-${eac_id}
    ...  ELSE
    ...  Set Variable  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1/EAC_${eac_direct}-${eac_id}
    ${recom_state_dict}  Perform Object Recommissioning  dist_name=${eac_obj_dist_name}  parameter=${param_dict}  operation=create
    ...  skip_parameter_relation_errors=${False}  should_activate=true  timeout=900

    [Return]  ${recom_state_dict}


Check Active Alarm In VES
    [Documentation]  This keyword is used to check active alarm in VES
    [Arguments]  ${operation}  ${alarm}

    Connect To ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    SSHLibrary.Write  kubectl -n onap get pods |grep ves | grep Running | grep 5g
    ${output}  SSHLibrary.Read Until Prompt
    ${pod_name}  Should Match Regexp  ${output}  ${REGEX_VES}
    SSHLibrary.Write  text=kubectl -n onap exec -it ${pod_name} bash
    ${output1}  SSHLibrary.Read Until  $
    ${output}  SSHLibrary.Write  cat logs/collector.log | grep ${BTS_ID} | grep '${alarm}' | grep '${operation}' > /tmp/pz.log
    SSHLibrary.Write  tail -n 6 /tmp/pz.log | grep 'Received a VESEvent'
    Sleep  10  Wait for command output.
    ${log}  SSHLibrary.Read
    Log To Console  ${log}

    [Teardown]  Run Keywords
    ...  SSHLibrary.Write  rm /tmp/pz.log
    ...  AND
    ...  SSHLibrary.Close Connection
    [Return]  ${log}


Check Cleared Alarm In VES
    [Documentation]  This keyword is used to check cleared alarm in VES
    [Arguments]  ${object}

    Connect To ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    SSHLibrary.Write  kubectl -n onap get pods |grep ves | grep Running | grep 5g
    ${output}  SSHLibrary.Read Until Prompt
    ${pod_name}  Should Match Regexp  ${output}  ${REGEX_VES}
    SSHLibrary.Write  text=kubectl -n onap exec -it ${pod_name} bash
    ${output1}  SSHLibrary.Read Until  $
    Sleep  30  Wait for command output.
    ${output}  SSHLibrary.Write  cat logs/collector.log | grep ${BTS_ID} | grep ${object} | grep "CLEARED" > /tmp/pz.log
    SSHLibrary.Write  tail -n 4 /tmp/pz.log | grep 'Received a VESEvent'
    Sleep  10  Wait for command output.
    ${log}  SSHLibrary.Read

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${log}


Get Alarms From ONAP
    [Documentation]  This keyword is used to get alarms from ONAP
    [Arguments]  ${onap_ip}  ${onap_username}  ${onap_password}

    Connect To ONAP  ${onap_ip}  ${onap_username}  ${onap_password}
    SSHLibrary.Write  kubectl -n onap get pods |grep netconf-server- --color=never | grep Running
    ${output}  SSHLibrary.Read Until Prompt
    ${pod_name}  Should Match Regexp  ${output}  ${REGEX}
    Sleep  10  Wait for command output.
    SSHLibrary.Write  text=kubectl -n onap exec -it ${pod_name} bash
    ${connecting_output}  SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo connect --tls --host ${MPLANE_IP} > test.txt
    SSHLibrary.Write  echo get >> test.txt
    SSHLibrary.Write  netopeer2-cli < test.txt
    Sleep  5  Wait for command output.
    ${get_output}  SSHLibrary.Read Until  expected=</AlarmList>

    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${get_output}


Initialize Certificate
    [Documentation]  This keyword is used to initialize certificate

    ${cmp_dn}  Set Variable  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ${dict_ca_subject_name}  Create Dictionary  parameterName=caSubjectName  operation=update  value=${CERTS_SUBJECT_NAME}
    ${dict_server_host}  Create Dictionary  parameterName=serverHost  operation=update  value=${CA_SERVER_IP}
    ${dict_server_path}  Create Dictionary  parameterName=serverPath  operation=update  value=${CA_SERVER_PATH}
    ${dict_server_port}  Create Dictionary  parameterName=serverPort  operation=update  value=${CA_DEFAULT_PORT}
    @{parameter_list}  Create List  ${dict_ca_subject_name}  ${dict_server_host}  ${dict_server_path}  ${dict_server_port}
    Perform Object Recommissioning  dist_name=${cmp_dn}  operation=update  parameter=@{parameter_list}
    Cmp Initialize Certificate


Delete And Recreate MPLANEONAP Object For CB007010
    [Documentation]  This keyword is used to delete and recreate MPLANEONAP object for CB007010
    [Arguments]  ${recovery_timeout}

    Log  Deleting MPLANEONAP object  console=true
    Delete MPLANEONAP Object
    Wait Until Keyword Succeeds  ${recovery_timeout}  30
    ...  Check Modules And Cells
    Log  Creating MPLANEONAP object  console=true
    Setup For CB007010


Check Alarm In VES After Reset
    [Documentation]  This keyword is used to check alarm in VES after reset

    Connect To ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    SSHLibrary.Write  kubectl -n onap get pods |grep ves | grep Running | grep 5g
    ${output}  SSHLibrary.Read Until Prompt
    ${pod_name}  Should Match Regexp  ${output}  ${REGEX_VES}
    SSHLibrary.Write  text=kubectl -n onap exec -it ${pod_name} bash
    ${output1}  SSHLibrary.Read Until  $
    ${output}  SSHLibrary.Write  cat logs/collector.log | grep ${BTS_ID} | grep 'notifyAlarmListRebuilt' > /tmp/pz.log
    SSHLibrary.Write  tail -n 6 /tmp/pz.log | grep 'Received a VESEvent'
    Sleep  10  Wait for command output.
    ${log}  SSHLibrary.Read
    Log To Console  ${log}

    [Teardown]  Run Keywords
    ...  SSHLibrary.Write  rm /tmp/pz.log
    ...  AND
    ...  SSHLibrary.Close Connection
    [Return]  ${log}
