*** Settings ***
Documentation  This resource contains all common keywords for Netact usage.

Library  taf.nms.netact  WITH NAME  netact
Library  python_resources/netact_check.py

*** Variables ***
${NETACT_USER}  omc
${NETACT_PASSWORD}  Medsql!_1893
${DISABLE_NETACT_CHECK}  ${FALSE}  # False or True. If set to True : setup, teardown and alarm check in Netact will be skipped.
${MRBTS_DN}  ${EMPTY}


*** Keywords ***
Setup NetAct
    [Documentation]
    ...  This KW is used for set up NetAct connection by adding all its services that are needed.
    ...  To add services ip addresses for each service must be known and one of them is chosen. For that purpose TC
    ...  is trying to connect to one ip address allocated for any service to run two commands and analyze their outputs.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    Log  Setup NetAct  console=true
    ${netact_info}  coam.Get Nms State
    Should Not Be Empty  ${netact_info}[0][managerInfo]  msg=SBTS is not integrated in NetAct!
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    IF  '${manager_id}' == '${EMPTY}'  Fail  NetAct web_url is missing!
    ${web_url}  ${netact_name}  Get Web Url And Netact Name  ${manager_id}
    Add_web_url  ${web_url}  ${NETACT_USER}  ${NETACT_PASSWORD}
    Open Ssh Connection To NetAct  ${web_url}
    ${services}  Create List  cmwas  fmwas  itsmwas    #nwi3
    ${service_ip_dict}  Get Ip Address For All Services  ${services}  ${netact_name}
    FOR  ${service}  IN  @{service_ip_dict.keys()}
        Add Node  ${service}  ${service_ip_dict}[${service}]  ${NETACT_USER}  ${NETACT_PASSWORD}
    END

    Set MRBTS Dist Name
    Set Test Variable  ${NA_CONNECTION_ESTABLISHED}  ${TRUE}
    Log  End of Setup NetAct  console=true

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close Connection


Get Manager Id For NetAct
    [Documentation]  This keyword is used to get manager id and ip for NetAct
    [Arguments]  ${netact_info}

    ${manager_info_list}  Set Variable  ${netact_info}[0][managerInfo]
    FOR  ${manager_info_item}  IN  @{manager_info_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${manager_info_item}[managerId]  nsn-rdnet.net
        IF  ${status}  RETURN  ${manager_info_item}[managerId]
    END

    RETURN  ${EMPTY}


Get Web Url And Netact Name
    [Documentation]  This keyword is used to get web url and netact name
    [Arguments]  ${manager_id}

    @{manager_id_split}  Split String  ${manager_id}  _
    ${web_url}  Set Variable  ${manager_id_split}[1]
    ${netact_name}  Fetch From Left  ${web_url}  lb

    RETURN  ${web_url}  ${netact_name}


Open Ssh Connection To NetAct
    [Documentation]
    ...  Keyword will try to open ssh connection to Netact.
    ...  Keyword is trying to login to hostname from node01.
    ...  If hostname is not available keyword will fail.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${web_url}

    ${hostname}  Replace String Using Regexp  ${web_url}  lbwas  node01
    SSHLibrary.Open Connection  ${hostname}
    ${status}  Run Keyword And Return Status  SSHLibrary.Login  ${NETACT_USER}  ${NETACT_PASSWORD}
    IF  ${status}  RETURN
    Fail  Cannot open ssh connection to NetAct!


Get Ip Address For All Services
    [Documentation]
    ...  This KW returns a dictionary with services as keys and the ip address for allocating each service
    ...  as value.
    ...  TC is connected to one ip address available from the range explained in the previous KW.
    ...  The ip_used_list is created for adding ip addresses after they will be allocated for the services.
    ...  For each service several steps are followed:
    ...  1. all nodes must be found through '/opt/cpf/sbin/netact_status.sh status service [service_name]' (e.g cmwas)
    ...  command
    ...  2. ip address for each node is found through 'nslookup [node_name]' (e.g srnclab1019node18) command
    ...  3. all ip addresses obtained in step 2. are added in a list called all_ip_addresses
    ...  4. one ip address from all_ip_addresses list is chosen using one of this options:
    ...  a. if all of the ip addresses are already set up for another services, then all this addresses are removed
    ...   from the ip_used_list and the first ip address from all_ip_addresses list is chosen and added in
    ...   the dictionary
    ...  b. otherwise, the first ip address from all_ip_addresses list that is not set up for any service is chosen
    ...   and added in the dictionary
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${services}  ${netact_name}

    ${ip_used_list}  Create List
    ${service_ip_dict}  Create Dictionary
    FOR  ${service}  IN  @{services}
        ${nodes_for_service}  Get Nodes For ${service} After ${netact_name}
        ${all_ip_addresses}  Get All Ip Addresses Available For Service  ${nodes_for_service}
        ${status}  Run Keyword And Return Status  List Should Contain Sub List  ${ip_used_list}  ${all_ip_addresses}
        IF  ${status}  Remove Values From List  ${ip_used_list}  @{all_ip_addresses}
        ${ip_address}  Get One Ip Address From List  ${all_ip_addresses}  ${ip_used_list}
        Set To Dictionary  ${service_ip_dict}  ${service}=${ip_address}
        Append To List  ${ip_used_list}  ${ip_address}
    END

    RETURN  ${service_ip_dict}


Get Nodes For ${service} After ${netact_name}
    [Documentation]  This keyword is used to get nodes for a specific service.

    ${output}  SSHLibrary.Execute Command  /opt/cpf/sbin/netact_status.sh status service ${service}
    ${pattern}  Catenate  SEPARATOR=  ${netact_name}  [a-zA-Z0-9]+:
    ${nodes_for_service}  Get Regexp Matches  ${output}  ${pattern}
    ${nodes_for_service}  Remove Duplicates  ${nodes_for_service}

    RETURN  ${nodes_for_service}


Get All Ip Addresses Available For Service
    [Documentation]  This keyword is used to get all ip addresses available for service
    [Arguments]  ${nodes_for_service}

    ${ip_addresses_for_service}  Create List
    FOR  ${line}  IN  @{nodes_for_service}
        ${node_name}  Remove String  ${line}  :
        ${output}  SSHLibrary.Execute Command  nslookup ${node_name}
        ${line_with_ip_addr}  Get Regexp Matches  ${output}  Address: [0-9.]+
        ${ip}  Fetch From Right  ${line_with_ip_addr}[0]  Address:${SPACE}
        Append To List  ${ip_addresses_for_service}  ${ip}
    END

    RETURN  ${ip_addresses_for_service}


Get One Ip Address From List
    [Documentation]  This keyword is used to get one ip address from list
    [Arguments]  ${all_ip_address}  ${ip_used_list}

    FOR  ${ip}  IN  @{all_ip_address}
        ${status}  Run Keyword And Return Status  List Should Not Contain Value  ${ip_used_list}  ${ip}
        IF  ${status}  RETURN  ${ip}
    END


Set MRBTS Dist Name
    [Documentation]  This keyword is used to set MRBTS dist name

    ${bts_info_result}  Get Bts Info
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/${bts_info_result}[id][configuration]


Teardown NetAct
    [Documentation]
    ...  This KW is used for closing the NetAct connection by deleting all services that are used. These operations are
    ...  performed if NetAct connection is successfully established.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${number_of_expected_disconnections}=0  ${allow_to_fail}=${FALSE}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    Log  Teardown NetAct  console=true
    Variable Should Exist  ${NA_CONNECTION_ESTABLISHED}  Setup NetAct failed. Teardown NetAct will not be performed.
    ${services}  Create List  cmwas  fmwas  itsmwas  nwi3
    FOR  ${service}  IN  @{services}
        Delete Node  ${service}
    END
    Check IMS for NMS disconnections  ${number_of_expected_disconnections}  ${allow_to_fail}
    Log  End of Teardown NetAct  console=true


Check IMS for NMS disconnections
    [Documentation]  Checks IMS log for NMS disconnection events during test execution.
    ...  Verifies the number of expected disconnections and optionally allows the check to fail.
    [Arguments]  ${number_of_expected_disconnections}=0  ${allow_to_fail}=${FALSE}

    Log  Check IMS for NMS disconnections  console=true
    ${ims}  Set Variable  ${BTS_FILES}/IM/ims_for_netact_check.ims2
    Collect Infomodel Log From Current Session  target_file_name=${ims}  timeout=300  leave_disconnect_logs=True
    @{ims_paths}  OperatingSystem.List Files In Directory  ${BTS_FILES}/IM  pattern=*.ims2  absolute=${TRUE}
    Check NMS State During Test Execution  ims_paths=${ims_paths}
    ...                                    number_of_expected_disconnections=${number_of_expected_disconnections}
    ...                                    allow_to_fail=${allow_to_fail}


Fast Pass Setup
    [Documentation]  This keyword is used to fast pass setup

    Variable Should Exist  ${SRNCLAB}  SRNCLAB not provided.
    Variable Should Exist  ${FB_BUILD}  FP build was not provided.
    ${netact_id}  Fetch From Right  ${SRNCLAB}  SRNCLAB
    @{configuration}  Split String  ${CONFIGURATION}  .
    @{tl_params}  Split String  ${configuration}[1]  _
    ${testline_name}  Set Variable  ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    ${testline_id}  Remove String Using Regexp  ${tl_params}[2]  UTESRANCLOUD1
    Set Suite Variable  ${TESTLINE_ID}  10${testline_id}
    Import Variables  /home/ute/robotlte/config/Timisoara/${testline_name}/variables.yaml
    Set Suite Variable  ${NETACT}  ${NETACT_LIST}[NETACT_${SRNCLAB}]

    Setup Netact Connection
    Check If SBTS Is Integrated To NetAct At Start
    Integrate SBTS To NetAct

    Import Library  testsuite/SBTS/FM/tc_variables/FastPassFeedback.py
    Send Feedback FB  ${FB_BUILD}.zip  ${SRNCLAB}  started  CRT_FM


Fast Pass Teardown
    [Documentation]  This keyword is used to fast pass teardown

    Run Keyword And Ignore Error  Deintegrate MRBTS From Netact  PLMN-PLMN/MRBTS-${TESTLINE_ID}
    Delete Node  cmwas
    ${tests_status}  Set Variable  passed
    ${tests_status}  Run Keyword If Any Tests Failed  Set Variable  failed
    Send Feedback FB  ${FB_BUILD}.zip  ${SRNCLAB}  ${tests_status}  CRT_FM


Setup Netact Connection
    [Documentation]  This keyword is used to setup netact connection

    Add Node  cmwas  ${NETACT['was_host']}  ${NETACT['user']}  ${NETACT['password']}


Check If SBTS Is Integrated To NetAct At Start
    [Documentation]  This keyword is used to check if SBTS is integrated to NetAct at start

    Setup Infomodel
    Connect Infomodel
    ${ne3sadapt}  Query Infomodel  check //NE3SADAPT-*  allow_negative_result=True
    ${netact_session}  IF  ${ne3sadapt}  Query Infomodel  get object //NE3S_SESSION-*  allow_negative_result=True
    ${session_status}  Run Keyword And Return Status  Should Not Be Equal  ${netact_session.stateInfo.operationalState}  Disabled
    IF  ${session_status}
        Deintegrate SBTS From Current Netact  ${netact_session}
    ELSE
        Log  SBTS is not integrated to any Netact.  console=true
    END

    [Teardown]  Teardown Infomodel


Integrate SBTS To NetAct
    [Documentation]  This keyword is used to integrate SBTS to NetAct

    Log  Integrate SBTS to Netact.  console=true
    ${bts_info}  coam.Get Parameters For All  BTS
    ${btsMplaneIp6V}  Get From Dictionary  ${bts_info}[0]  btsMplaneIp6V
    IF  $btsMplaneIp6V is $None
        ${mrbts_address}  ${ip_version}  Set Variable  ${MPLANE_IP}  IPV4
    ELSE
        ${mrbts_address}  ${ip_version}  Set Variable  ${btsMplaneIp6V}  IPV6
    END
    TRY
        Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mrbts_address}  dist_name=${MRBTS_DN}
        ...  security_mode=no TLS  ip_version=${ip_version}
    EXCEPT  IntegrationError: *  type=GLOB
        Log  \nFailed integration with MRC-COMMON/MR-COMMON, trying with MRC-Common/MR-Common.  console=true
        Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-Common/MR-Common  mrbts_address=${mrbts_address}  dist_name=${MRBTS_DN}
       ...  security_mode=no TLS  ip_version=${ip_version}
    END
    ${netact_info}  coam.Get Nms State
    Should Not Be Empty  ${netact_info}[0][managerInfo]  Didn't manage to reintegrate SBTS to netact. [NOK]


Deintegrate SBTS From Current Netact
    [Documentation]  This keyword is used to deintegrate SBTS from current netact
    [Arguments]  ${netact_session}

    ${na_managerid}  Set Variable  ${netact_session.managerInfo}
    FOR  ${info}  IN  @{na_managerid}
        ${status}  ${srnclab_at_start}  Run Keyword And Ignore Error  Get Regexp Matches  ${info}[managerId]  srnclab....
        IF  '${status}' == 'PASS'  BREAK
    END
    ${srnclab_at_start}  Convert To Uppercase  ${srnclab_at_start}[0]
    ${srnclab_at_start}  Set Variable  NETACT_${srnclab_at_start}
    ${netact_at_start}  Set Variable  ${NETACT_LIST}[${srnclab_at_start}]
    Import Library  taf.nms.netact  WITH NAME  netact
    Deintegrate MRBTS From Netact  PLMN-PLMN/MRBTS-${TESTLINE_ID}


Verify If SBTS Is Connected To Netact
    [Documentation]  This keyword is used to check if SBTS is connected to Netact without BTS Med.
    ...  *AUTHOR* bogdan.boldurean@nokia.com

    ${NE3SADAPT}  Query Infomodel  check //NE3SADAPT-*  allow_negative_result=True
    Set Test Variable  ${NE3SADAPT}
    IF  ${NE3SADAPT}
        Log  SBTS is connected to NetAct.  console=true
    ELSE
        Log  SBTS is not connected to NetAct.  console=true
    END


Check NetAct Status
    [Documentation]  KW to get NetAct session Operation State.
    ...  *AUTHOR* bogdan.boldurean@nokia.com

    ${netact_session}  Query Infomodel  get object //NE3S_SESSION-*
    ${netact_status}  Run Keyword And Return Status  Should Be Equal As Strings  '${netact_session.stateInfo.operationalState}'  'Enabled'
    IF  ${netact_status}
        Log  NetAct Operational State is Enabled.  console=true
    ELSE
        Set Test Restriction  Operational State is ${netact_session.stateInfo.operationalState}.
    END


Check Additional Information For Given Alarm And Fault
    [Documentation]
    ...  **Mandatory parameters: fault_id, fault_name, alarm_id, alarm_name, severity.
    ...  KW checks if given alarm/fault information maches any active alarms in NA.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${fault_id}=${None}
    ...  ${fault_name}=${None}
    ...  ${alarm_id}=${None}
    ...  ${alarm_name}=${None}
    ...  ${severity}=${None}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${additional_fault_id}=${None}
    ...  ${suppl_info}=${None}
    ...  ${dist_name}=${MRBTS_DN}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        Return From Keyword
    END
    ${netact_alarms}  netact.Get Alarms  dist_name=${dist_name}
    ${fault_id}  Convert To String  ${fault_id}
    ${severity_uppercase}  Convert To Upper Case  ${severity}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additionalText1_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  None
        ${additionalText3_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText3]  None
        IF  ${additionalText1_is_None} or ${additionalText3_is_None}  CONTINUE
        ${fault_id_na}  Fetch From Left  ${na_alarm}[additionalText3]  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Contain  ${fault_id}  ${fault_id_na}
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  ${fault_name}
        ${check_alarm_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[specificProblem]  ${alarm_id}
        ${check_alarm_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[alarmText]  ${alarm_name}
        ${additional_severity_uppercase}  IF  '${additional_severity}' != '${EMPTY}'  Convert To Upper Case  ${additional_severity}
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${na_alarm}[additionalAttributes][severity]  (?i)(${severity_uppercase}|${additional_severity_uppercase})
        ${object_id_status}  Set Variable  ${TRUE}
        ${additional_fault_id_status}  Set Variable  ${TRUE}
        ${suppl_info_status}  Set Variable  ${TRUE}
        IF  $object_id is not $None
            ${object_id_status}  Run Keyword And Return Status  Should Contain  ${na_alarm}[dn]  ${object_id}
        END
        IF  $additional_fault_id is not $None
            ${additional_fault_id_status}  Run Keyword And Return Status
            ...  Should Contain  ${na_alarm}[additionalText3]  additionalFaultID=${additional_fault_id}
        END
        IF  $suppl_info is not $None
            ${suppl_info_status}  Run Keyword And Return Status  Should Match Regexp  ${na_alarm}[additionalText3]  .*supplAlarmInfo=${suppl_info}.*
        END
        ${match_condition}  Catenate  ${check_fault_id} and ${check_fault_name} and ${check_alarm_id} and ${check_alarm_name}
        ...  and ${check_alarm_severity} and ${object_id_status} and ${additional_fault_id_status} and ${suppl_info_status}
        IF  ${match_condition}  RETURN
    END
    Fail  Alarm with fault id: ${fault_id} not active in Netact.


Check Unit_Name In Alarm Additional Text
    [Documentation]
    ...  KW checks if given alarm/fault information maches any active alarms in NA.
    ...  Kw checks if alarm additonalText3 contain "Unit name" in case of alarming object.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${unit_name}  ${module}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        Return From Keyword
    END
    ${check}  Set Variable  False
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${check}  Run Keyword And Return Status  Should Match Regexp  ${na_alarm}[dn]  ${module}_R-
        IF  not ${check}  CONTINUE
        ${alarm_unit_name}  Get Regexp Matches  ${na_alarm}[additionalText3]  unitName=([a-zA-Z0-9_]*)${SPACE}  1
        Should Be Equal As Strings  ${unit_name}  ${alarm_unit_name}[0]
        RETURN
    END


Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
    [Documentation]
    ...  **Mandatory parameters: fault_id, fault_name, alarm_id, alarm_name, severity, time_from.
    ...  KW checks if given alarm/fault information maches any acknowledged or unacknowledged and cleared alarm in Netact.
    ...  KW will use get_cleared_alarms from taf.nms.netact with filtering time_from and time_to as arguments.
    ...  If the alarm is not in cleared and acknowledged alarms list, KW will execute get_alarms with only_active parameter set on False.
    ...  In this case, KW check if the alarm is cleared and unacknowledged.
    ...  If both methods don't find the given alarm, KW will fail.
    ...
    ...  *AUTHOR* laura.craciunel@nokia.com
    ...  *MAINTAINER* andrada-lavinia.baleti@nokia.com
    [Arguments]
    ...  ${fault_id}=${None}
    ...  ${fault_name}=${None}
    ...  ${alarm_id}=${None}
    ...  ${alarm_name}=${None}
    ...  ${severity}=${None}
    ...  ${time_from}=${None}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${additional_fault_id}=${None}
    ...  ${suppl_info}=${None}
    ...  ${dist_name}=${MRBTS_DN}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${status_acked_alarms}  Check Alarm In Cleared And Acknowledged Alarms List From NA  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}
    ...  ${severity}  ${time_from}  ${time_to}  ${additional_severity}  ${object_id}  ${additional_fault_id}  ${suppl_info}  ${dist_name}
    IF  ${status_acked_alarms}  RETURN
    ${status_unacked_alarms}  Check Alarm In Cleared And Unacknowledged Alarms List From NA  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}
    ...  ${severity}  ${time_from}  ${time_to}  ${additional_severity}  ${object_id}  ${additional_fault_id}  ${suppl_info}  ${dist_name}
    IF  ${status_unacked_alarms} == ${FALSE}
        Fail  Fault ${fault_id} - ${fault_name} with alarm ${alarm_id} - ${alarm_name} is not cleared in Netact.
    ELSE
        Log  Fault ${fault_id} - ${fault_name} with alarm ${alarm_id} - ${alarm_name} found in Netact cleared alarm.  console=true
    END


Check Alarm In Cleared And Acknowledged Alarms List From NA
    [Documentation]  This keyword is used to check alarm in cleared and acknowledged alarms list from NA
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${time_from}
    ...  ${time_to}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${additional_fault_id}=${None}
    ...  ${suppl_info}=${None}
    ...  ${dist_name}=${MRBTS_DN}

    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${dist_name}  time_from=${time_from}  time_to=${time_to}
    ${fault_id}  Convert To String  ${fault_id}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${status_error_event_type}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[eventType]  PROCESSINGERROR
        ${additionalText1_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  None
        ${additionalText3_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText3]  None
        IF  ${status_error_event_type} or ${additionalText1_is_None} or ${additionalText3_is_None}  CONTINUE
        ${fault_id_na}  Fetch From Left  ${na_alarm}[additionalText3]  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Contain  ${fault_id}  ${fault_id_na}
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${fault_name}  ${na_alarm}[additionalText1]
        ${check_alarm_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm_id}  ${na_alarm}[specificProblem]
        ${check_alarm_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm_name}  ${na_alarm}[alarmText]
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${na_alarm}[additionalAttributes][severity]  (?i)(${severity}|${additional_severity})
        ${object_id_status}  Set Variable  ${TRUE}
        ${additional_fault_id_status}  Set Variable  ${TRUE}
        ${suppl_info_status}  Set Variable  ${TRUE}
        IF  $object_id is not $None
            ${object_id_status}  Run Keyword And Return Status  Should Contain  ${na_alarm}[dn]  ${object_id}
        END
        IF  $additional_fault_id is not $None
            ${additional_fault_id_status}  Run Keyword And Return Status
            ...  Should Contain  ${na_alarm}[additionalText3]  additionalFaultID=${additional_fault_id}
        END
        IF  $suppl_info is not $None
            ${suppl_info_status}  Run Keyword And Return Status  Should Match Regexp  ${na_alarm}[additionalText3]  .*${suppl_info}.*
        END
        ${condition}  Catenate  ${check_fault_id} and ${check_fault_name} and ${check_alarm_id} and ${check_alarm_name}
        ...  and ${check_alarm_severity} and ${object_id_status} and ${additional_fault_id_status} and ${suppl_info_status}
        IF  ${condition}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Check Alarm In Cleared And Unacknowledged Alarms List From NA
    [Documentation]  This keyword is used to check alarm in cleared and unacknowledged alarms list from NA
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${time_from}
    ...  ${time_to}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${additional_fault_id}=${None}
    ...  ${suppl_info}=${None}
    ...  ${dist_name}=${MRBTS_DN}

    ${alarms_not_acked}  netact.Get Alarms  ${dist_name}  only_active=False
    ${fault_id}  Convert To String  ${fault_id}
    FOR  ${na_alarm}  IN  @{alarms_not_acked}
        ${additionalText3_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText3]  None
        IF  not ${additionalText3_is_None}
            ${fault_id_na}  Fetch From Left  ${na_alarm}[additionalText3]  ${SPACE}
            ${faultId_is_as_expected}  Run Keyword And Return Status  Should Contain  ${fault_id}  ${fault_id_na}
        ELSE
            ${faultId_is_as_expected}  Set Variable  ${FALSE}
        END
        ${clearTime_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[clearTime]  None
        IF  ${clearTime_is_None} or not ${faultId_is_as_expected}  CONTINUE
        ${alarm_datetime}  Convert To Datetime Format  ${na_alarm}[clearTime]
        IF  ('${alarm_datetime}' < '${time_from}') or ('${alarm_datetime}' > '${time_to}')  CONTINUE
        ${fault_name_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  ${fault_name}
        ${alarm_id_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${na_alarm}[specificProblem]  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[alarmText]  ${alarm_name}
        ${severity_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${na_alarm}[perceivedSeverity]  (?i)(${severity}|${additional_severity})
        ${object_id_status}  Set Variable  ${TRUE}
        ${additional_fault_id_status}  Set Variable  ${TRUE}
        ${suppl_info_status}  Set Variable  ${TRUE}
        IF  $object_id is not $None
            ${object_id_status}  Run Keyword And Return Status  Should Contain  ${na_alarm}[dn]  ${object_id}
        END
        IF  $additional_fault_id is not $None
            ${additional_fault_id_status}  Run Keyword And Return Status
            ...  Should Contain  ${na_alarm}[additionalText3]  additionalFaultID=${additional_fault_id}
        END
        IF  $suppl_info is not $None
            ${suppl_info_status}  Run Keyword And Return Status  Should Match Regexp  ${na_alarm}[additionalText3]  supplAlarmInfo=${suppl_info}
        END
        ${condition}  Catenate  ${fault_name_status} and ${alarm_id_status} and ${alarm_name_status} and ${severity_status}
        ...  and ${object_id_status} and ${additional_fault_id_status} and ${suppl_info_status}
        IF  ${condition}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Convert To Datetime Format
    [Documentation]  This keyword is used to convert to datetime format
    [Arguments]  ${time}

    ${operation_symbol}  Set Variable If  '+' in '${time}'  +  -
    ${datetime}  Replace String  ${time}  T  ${SPACE}
    ${additional_hours}  Fetch From Right  ${datetime}  ${operation_symbol}
    ${additional_hours}  Get Substring  ${additional_hours}  0  2
    ${datetime}  Fetch From Left  ${datetime}  ${operation_symbol}
    IF  '${operation_symbol}' == '+'
        ${datetime}  Subtract Time From Date  ${datetime}  ${additional_hours}:00:00
    ELSE
        ${datetime}  Add Time To Date  ${datetime}  ${additional_hours}:00:00
    END

    RETURN  ${datetime}


Check Fault Signature Of Alarm In Netact
    [Documentation]
    ...  Keyword checks if given fault signature matches regexp.
    ...  Expected fault id nedeed as argument for filtering out the alarms in Netact cleared alarms.
    ...  Keyword will use Get Cleared Alarms from Netact Monitor with filtering time_from and time_to as arguments.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${fault_id}
    ...  ${time_from}
    ...  ${category}=${EMPTY}
    ...  ${component}=${EMPTY}
    ...  ${extra_info}=${EMPTY}
    ...  ${info}=${EMPTY}
    ...  ${load_name}=${EMPTY}
    ...  ${minor}=${EMPTY}
    ...  ${reset_counter}=${EMPTY}
    ...  ${rfm_cpri}=${EMPTY}
    ...  ${rfm_fpga}=${EMPTY}
    ...  ${rfm_gpp}=${EMPTY}
    ...  ${scope}=${EMPTY}
    ...  ${full_product_name}=${EMPTY}
    ...  ${serial_number}=${EMPTY}
    ...  ${core_serial_number}=${EMPTY}
    ...  ${vendor_unit_number}=${EMPTY}
    ...  ${core_vendor_unit_number}=${EMPTY}
    ...  ${unit_position}=${EMPTY}
    ...  ${core_unit_position}=${EMPTY}
    ...  ${dist_name}=${MRBTS_DN}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        Return From Keyword
    END
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${bts_date}  Get BTS time in UTC format  %Y-%m-%d
    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${dist_name}  time_from=${time_from}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text5}  Get From Dictionary  ${na_alarm}  additionalText5
        IF  $additional_text5 is $None  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${fault_id_na}  Fetch From Left  ${additional_text3}  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${fault_id}  ${fault_id_na}
        IF  '${check_fault_id}'=='${FALSE}'  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END

    Log  Matching alarm found in Netact, fault signature will be checked: ${netact_alarms}
    ${additional_text5}  Get From Dictionary  ${netact_alarms}[0]  additionalText5
    ${text5_dict}  Create Additional_text5 Dict  ${additional_text5}
    Check Regexp  ${text5_dict}[CATEGORY]  ${category}  Category field did not matched.
    Check Component Field  ${text5_dict}[COMPONENT]  ${component}  ${full_product_name}  ${serial_number}  ${core_serial_number}
    ...  ${vendor_unit_number}  ${core_vendor_unit_number}  ${unit_position}  ${core_unit_position}
    ${status_date}  Run Keyword And Return Status  Check Regexp  ${text5_dict}[DATE]  ${bts_date}  None
    IF  not ${status_date}
        ${yesterday_date}  Subtract Time From Date  ${bts_date}  1 day
        ${yesterday_date_status}  Run Keyword And Return Status  Check Regexp  ${text5_dict}[DATE]  ${yesterday_date}  None
        IF  not ${yesterday_date_status}  Fail  Date field did not matched.
    END
    Check Regexp  ${text5_dict}[EXTRA_INFO]  ${extra_info}  Extra info field did not matched.
    Check Regexp  ${text5_dict}[INFO]  ${info}  Info field did not matched.
    Check Equality  ${text5_dict}[LOAD_NAME]  ${load_name}  Load name field did not matched.
    Check Regexp  ${text5_dict}[MINOR]  ${minor}  Minor field did not matched.
    Check Regexp  ${text5_dict}[RESET_COUNTER]  ${reset_counter}  msg=Reset counter field is null.
    Check Equality  ${text5_dict}[RFM_CPRI]  ${rfm_cpri}  rfmCpri field did not matched.
    Check Equality  ${text5_dict}[RFM_FPGA]  ${rfm_fpga}  rfmFpga field did not matched.
    Check Regexp  ${text5_dict}[RFM_GPP]  ${rfm_gpp}  rfmGpp field did not matched.
    Check Equality  ${text5_dict}[SCOPE]  ${scope}  Scope field did not matched.
    Log  Fault signature of alarm in Netact is field correctly. [OK]  console=True


Create Additional_text5 Dict
    [Documentation]  This keyword is used to create additional_text5 dict
    [Arguments]  ${additional_text5}

    ${element_list}  Split String  ${additional_text5}  ] [
    Remove Values From List  ${element_list}  [FAULT_SIGNATURE
    ${dict}  Create Dictionary  CATEGORY=-  COMPONENT=-  DATE=-  EXTRA_INFO=-  INFO=-  LOAD_NAME=-  MINOR=-  RESET_COUNTER=-  RFM_CPRI=-  RFM_FPGA=
    ...  RFM_GPP=-  SCOPE=-
    FOR  ${element}  IN  @{element_list}
        ${value}  Remove String  ${element}  [  ]
        ${key}  Fetch From Left  ${value}  :
        Set To Dictionary  ${dict}  ${key}  ${value}
    END

    RETURN  ${dict}


Check Fault Signature In Netact For Radio Recovery Reset Scenario
    [Documentation]
    ...  Keyword checks if given fault signature matches regexp. Keyword checks fault signature for radio reset recovery scenarios.
    ...  Exemple of fault signature field in Netact :
    ...  [FAULT_SIGNATURE] [DATE: 2022-10-17T08:49:04+03:00] [CATEGORY: OAM_RESET] [RESET_COUNTER: 112] [SCOPE: RFM]
    ...  [LOAD_NAME: SBTS23R1_ENB_9999_221006_000007] [COMPONENT: 1M221226682] [EXTRA_INFO: gracefully_shutdown_cells=LTE:1,2,3NR:1,2,3]
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${fault_id}  ${serial_number}  ${category}  ${scope}  ${exta_info}  ${load}  ${time_from}  ${numbers_of_appearances}=3

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        Return From Keyword
    END
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${MRBTS_DN}  time_from=${time_from}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text5}  Get From Dictionary  ${na_alarm}  additionalText5
        IF  '${additional_text5}' == 'None'  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${additional_text5}  Get From Dictionary  ${na_alarm}  additionalText5
        ${fault_id_na}  Fetch From Left  ${additional_text3}  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${fault_id}  ${fault_id_na}
        ${serial_no_3}  Run Keyword And Return Status  Should Contain  ${additional_text3}  ${serial_number}
        ${serial_no_5}  Run Keyword And Return Status  Should Contain  ${additional_text5}  ${serial_number}
        IF  ${check_fault_id} == ${FALSE}  Remove Values From List  ${netact_alarms}  ${na_alarm}
        IF  ${serial_no_3} == ${FALSE} and ${serial_no_5} == ${FALSE}  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    Log  Matching alarms found: ${netact_alarms}
    ${alarm_count_by_rmod}  Set Variable  0
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text5}  Get From Dictionary  ${na_alarm}  additionalText5
        ${text5_dict}  Create Additional_text5 Dict  ${additional_text5}
        Check Regexp  ${text5_dict}[DATE]  ${date}  msg=Date field did not matched.
        Check Equality  ${text5_dict}[CATEGORY]  CATEGORY:${SPACE}${category}  Category field did not matched.
        Check Equality  ${text5_dict}[SCOPE]  SCOPE:${SPACE}${scope}  Scope field did not matched.
        Check Equality  ${text5_dict}[LOAD_NAME]  LOAD_NAME:${SPACE}${load}  Load name field did not matched.
        Check Component Field  ${text5_dict}[COMPONENT]  COMPONENT:${SPACE}${serial_number}
        Check Regexp  ${text5_dict}[EXTRA_INFO]  EXTRA_INFO:${SPACE}${exta_info}  Extra info field did not matched.
        ${alarm_count_by_rmod}  Evaluate  ${alarm_count_by_rmod}+1
    END
    ${compare_alarm_count}  Run Keyword And Return Status  Should Be Equal As Integers  ${alarm_count_by_rmod}  ${numbers_of_appearances}
    IF  ${compare_alarm_count}
        Log  Fault signature of alarm in Netact is field correctly. [OK]  console=True
    ELSE
        Fail  Fault signature of alarm in Netact is NOT filled correctly. [NOK]
    END


Check Fault Signature In Netact For All Radio Modules
    [Documentation]  This keyword is used to check fault signature of alarm in Netact for all radio modules.
    [Arguments]  ${fault}  ${rmods_serial_numbers}  ${test_category}  ${test_scope}  ${test_extra_info}  ${active_software}  ${time}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    FOR  ${rmod_serial_number}  IN  @{rmods_serial_numbers}
        ${check_signature_na}  Run Keyword And Return Status
        ...  Check Fault Signature In Netact For Radio Recovery Reset Scenario  ${fault}
        ...                                                                     ${rmod_serial_number}
        ...                                                                     ${test_category}
        ...                                                                     ${test_scope}
        ...                                                                     ${test_extra_info}
        ...                                                                     ${active_software}
        ...                                                                     ${time}
        IF  ${check_signature_na}
            Log  Fault signature in Netact is field correctlly.  console=true
        ELSE
            Fail  Fault signature in Netact is not field correctlly.
        END
    END


Check If Alarms From WebEM And NetAct Are The Same
    [Documentation]  This keyword is used to check if alarms from WebEM and NetAct are the same

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    ${webem_alarms}  coam.Get Active Alarms
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    ${webem_alarms_ids}  Get Ids From Webem Alarms  ${webem_alarms}
    ${netact_alarms_ids}  Get Ids From Netact Alarms  ${netact_alarms}
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${webem_alarms_ids}  ${netact_alarms_ids}  ignore_order=True
    IF  ${status}
        Log  Alarms from WebEM and NetAct are the same [OK].  console=true
    ELSE
        Set Test Restriction  msg=Alarms from WebEM and NetAct are not the same [NOK].
    END


Get Ids From Webem Alarms
    [Documentation]  This keyword is used to get ids from webem alarms
    [Arguments]  ${alarm_list}

    ${ids_list}  Create List
    FOR  ${alarm}  IN  @{alarm_list}
        ${result}  Convert To Integer  ${alarm}[faultId]
        Append To List  ${ids_list}  ${result}
    END
    Sort List  ${ids_list}

    RETURN  ${ids_list}


Get Ids From Netact Alarms
    [Documentation]  This keyword is used to get ids from netact alarms
    [Arguments]  ${alarm_list}

    ${ids_list}  Create List
    FOR  ${alarm}  IN  @{alarm_list}
        IF  '${alarm}[additionalText3]'=='None'  CONTINUE
        ${fault_id}  Fetch From Left  ${alarm}[additionalText3]  ${SPACE}
        ${result}  Convert To Integer  ${fault_id}
        Append To List  ${ids_list}  ${result}
    END
    Sort List  ${ids_list}

    RETURN  ${ids_list}


Import Plan To Netact
    [Documentation]    Helper keyword used for Import plan to NetAct from local_dir/file_name place
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description |
    ...  | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...  | file_name | Yes | File name for local stored plan |
    ...  | plan_name | Yes | Name of plan on NetAct |
    [Arguments]  ${local_dir}  ${file_name}  ${plan_name}

    ${use_object}  Create Dictionary  -useObjectOperationDefinedInImportFile=true
    ${status}  ${plan}  Run Keyword And Ignore Error  Get Plan Configuration  ${plan_name}
    IF  '${status}' == 'PASS'  Delete Plan From Netact  ${plan_name}  ${plan}
    OperatingSystem.File Should Exist  ${local_dir}/${file_name}
    ${status}  Run Keyword And Return Status
    ...  Import Configuration  local_dir=${local_dir}  file_name=${file_name}  plan_name=${plan_name}  parameters=${use_object}
    IF  ${status}
        Log  Plan ${plan_name} at ${local_dir}/${file_name} import success.  level=INFO  console=True
    ELSE
        Fail  Plan ${plan_name} at ${local_dir}/${file_name}
    END


Delete Plan From Netact
    [Documentation]  This keyword is used to delete plan from netact
    [Arguments]  ${name}  ${plan}

    netact.Delete Plan  ${name}
    ${status}  Run Keyword And Return Status  Get Plan Configuration  ${name}
    IF  ${status}
        Fail  Plan deletion failed!
    ELSE
        Log  Plan successfully deleted: ${plan}  console=True
    END


Prepare And Import All Plans From Directory
    [Documentation]
    ...  Replacing default values in NA plan template and imports it to NA

    Log  Preparing and importing plans from ${TEST_DATA_FILES}  console=true
    @{test_data_files_content}  OperatingSystem.List Files In Directory  path=${TEST_DATA_FILES}
    FOR  ${file}  IN  @{test_data_files_content}
        Prepare Each Plan  ${file}
        ${file_name}  Fetch From Left  ${file}  .xml
        Import Plan To Netact  local_dir=${BTS_FILES}/xml_plans  file_name=${ENB_ID}_${file}  plan_name=${ENB_ID}_${file_name}
    END


Prepare Each Plan
    [Documentation]  This keyword is used to prepare each plan
    [Arguments]  ${xml_file}

    ${xml}  Parse XML  ${TEST_DATA_FILES}/${xml_file}
    ${elements}  Get Elements  ${xml}  .//managedObject
    FOR  ${element}  IN  @{elements}
        Set Element Attribute  ${element}  version  ${ENB_RELEASE}
        ${dist_name_attribute}  Get Element Attribute  ${element}  distName
        ${dist_name_attribute}  Replace String  ${dist_name_attribute}  %PLMN%  ${PLMN}
        ${dist_name_attribute}  Replace String  ${dist_name_attribute}  %ENB_ID%  ${ENB_ID}
        Set Element Attribute  ${element}  distName  ${dist_name_attribute}
        Create Directory  ${BTS_FILES}/xml_plans
        Save XML  ${xml}  ${BTS_FILES}/xml_plans/${ENB_ID}_${xml_file}
    END


Verify Parameter For A Specific Netact Alarm
    [Documentation]
    ...  This keyword checks if a certain parameter from Netact alarm, has the desired value.
    ...  Alarm has to be active while checking.
    ...  E.g. Verify parameter for a specific Netact alarm  1837  VSWR major alarm  alarmCount  1
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${fault_id}  ${fault_name}  ${given_parameter}  ${desired_value}

    IF  ${DISABLE_NETACT_CHECK}
        Log  Netact check is disabled, check will be skipped.  console=true  level=ERROR
        RETURN
    END
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    ${fault_id}  Convert To String  ${fault_id}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${check_fault_id}  Run Keyword And Return Status  Should Contain  ${additional_text3}  ${fault_id}
        ${additional_text1}  Get From Dictionary  ${na_alarm}  additionalText1
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${additional_text1}  ${fault_name}
        ${given_parameter_value}  Get From Dictionary  ${na_alarm}  ${given_parameter}
        ${check_given_parameter}  Run Keyword And Return Status  Should Contain  ${given_parameter_value}  ${desired_value}
        IF  ${check_fault_id} and ${check_fault_name} and ${check_given_parameter}  RETURN
    END
    Fail  ${given_parameter} parameter from alarm ${fault_id}:${fault_name} is not equal to ${desired_value}.


Check Fault 4592 Information In Netact Alarm History
    [Documentation]  Keyword designed to check duration and reason for fault 4592 in Netact cleared alarms.
    ...  Alarm should appear 5 minutes after BTS reset and it should be active in WebEm for the time defined by fault4592CancellationTimer parameter.
    ...  Alarm should be send to Netact after apperence in WebEM.
    ...  Alarm duration is calculated as the diference between clear_time and alarmTime.
    ...  Alarm duration time is checked to be in fault4592CancellationTimer-10s and fault4592CancellationTimer10s time period.
    [Arguments]  ${fault_reason}  ${time_from}  ${fault_id}=4592

    ${list}  Create List  fault4592CancellationTimer
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${timer}  Set Variable  ${parameter}[0][parameters][fault4592CancellationTimer]
    ${timer}  Convert To Integer  ${timer}
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${MRBTS_DN}  time_from=${time_from}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${status_error_event_type}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[eventType]  PROCESSINGERROR
        ${additionalText1_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  None
        ${additionalText3_is_None}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText3]  None
        IF  ${status_error_event_type} or ${additionalText1_is_None} or ${additionalText3_is_None}  CONTINUE
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${fault_id_na}  Fetch From Left  ${additional_text3}  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${fault_id}  ${fault_id_na}
        ${alarm}  Set Variable If  ${check_fault_id}  ${na_alarm}
        IF  ${check_fault_id}  BREAK
    END
    ${alarm_time}  Set Variable  ${alarm}[alarmTime]
    ${clear_time}  Set Variable  ${alarm}[clearTime]
    Log  ${alarm_time}  console=true
    Log  ${clear_time}  console=true
    ${alarm_time}  Convert To Datetime Format  ${alarm_time}
    ${clear_time}  Convert To Datetime Format  ${clear_time}
    ${alarm_duration}  Subtract Date From Date  ${clear_time}  ${alarm_time}
    ${alarm_total_time}  Evaluate  ${timer}-10 <= ${alarm_duration} <= ${timer}+10
    IF  ${alarm_total_time}
        Log  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value within tolerance defined by fault4592CancellationTimer=${timer}.
        ...  console=true
    ELSE
        Fail  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value not within tolerance defined by fault4592CancellationTimer=${timer}.
    END
    ${additional_text3}  Get From Dictionary  ${alarm}  additionalText3
    Should Contain  ${additional_text3}  ${fault_reason}  Reset reason not OK.
    Log  Reset reason OK.  console=true


Checking Netact Integration State And Alarm in Cleared Alarms In Netact
    [Documentation]  This Keyword verifies if SBTS remains connected to Netact.
    ...  If connected, it checks for alarms in the cleared alarms section of NetAct.
    ...  If not connected, integration is performed, followed by the alarm check in the cleared alarms section.
    [Arguments]
    ...  ${fault_id}=${None}
    ...  ${fault_name}=${None}
    ...  ${alarm_id}=${None}
    ...  ${alarm_name}=${None}
    ...  ${severity}=${None}
    ...  ${time_from}=${None}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${additional_fault_id}=${None}
    ...  ${suppl_info}=${None}

    ${netact_info}  coam.Get Nms State
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${netact_info}[0][managerInfo]
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    IF  ${status} == ${FALSE} or '${manager_id}' == '${EMPTY}'
        Log  SBTS is not integrated into NetAct, but will be integrated immediately.  console=true
        Integrate MRBTS With Netact  release=${ENB_BRANCH}
        ...                          mr=MRC-COMMON/MR-COMMON
        ...                          mrbts_address=${MPLANE_IP}
        ...                          dist_name=${MRBTS_DN}
        ...                          security_mode=no TLS
    END
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
    ...  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}
    ...  ${severity}  ${time_from}  ${additional_severity}  ${object_id}  ${additional_fault_id}  ${suppl_info}
    Log  Fault ${fault_id} "${fault_name}" was reported & cleared from NetAct with the correct supplementary info.  console=true


Get Alarm From List Of Alarms In Netact
    [Documentation]  Keyword will return a given alarm from Netact cleared alarms list.
    ...  Keyword will return alarm based on faultid, fault name, alarm id, alarm name, severity and dist name.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${alarm_list}
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${additional_severity}=${None}
    ...  ${dn}=${None}

    FOR  ${alarm}  IN  @{alarm_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${alarm}[additionalText1]  \n
        IF  ${status}
            ${alarm_additionalText1}  Remove String  ${alarm}[additionalText1]  \n
        ELSE
            ${alarm_additionalText1}  Set Variable  ${alarm}[additionalText1]
        END
        ${condition}  Catenate  SEPARATOR=${SPACE}or${SPACE}
        ...  '${alarm}[eventType]'=='PROCESSINGERROR'
        ...  '${alarm_additionalText1}'=='None'
        ...  '${alarm}[additionalText3]'=='None'
        IF  ${condition}  Remove Values From List  ${alarm_list}  ${alarm}
    END
    FOR  ${alarm}  IN  @{alarm_list}
        IF  $dn is not $None
            ${check_dn}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[dn]  ${dn}
        ELSE
            ${check_dn}  Set Variable  ${TRUE}
        END
        ${alarm_additional_attributes}  Get From Dictionary  ${alarm}  additionalAttributes
        ${alarm_severity}  Set Variable  ${alarm_additional_attributes}[severity]
        ${severity_uppercase}  Convert To Upper Case  ${severity}
        ${additional_severity_uppercase}  Set Variable  ${None}
        ${additional_severity_uppercase}  IF  $additional_severity is not $None  Convert To Upper Case  ${additional_severity}
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm_severity}  (?i)(${severity_uppercase}|${additional_severity_uppercase})
        ${fault_id}  Convert To String  ${fault_id}
        ${check_fault_id}  Run Keyword And Return Status  Should Contain  ${alarm}[additionalText3]  ${fault_id}
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[additionalText1]  ${fault_name}
        ${check_alarm_id}  Run Keyword And Return Status  Should Be Equal As Integers  ${alarm}[specificProblem]  ${alarm_id}
        ${check_alarm_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[alarmText]  ${alarm_name}
        ${alarm_condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}
        ...  ${check_fault_id}
        ...  ${check_fault_name}
        ...  ${check_alarm_id}
        ...  ${check_alarm_name}
        ...  ${check_alarm_severity}
        ...  ${check_dn}
        IF  ${alarm_condition}  BREAK
    END

    RETURN  ${alarm}


Get lcm Service URL
    [Documentation]  Create lcm URL based on web url.

    Log  Connect To lcm Service VM.  console=true

    ${netact_info}  Get Nms State
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    ${web_url_and_netact_name}  Get Web Url And Netact Name  ${manager_id}
    ${lcm_url}  Replace String Using Regexp  ${web_url_and_netact_name}[0]  lbwas  lcm

    RETURN  ${lcm_url}
