*** Settings ***
Documentation  This suite contains vCU KWs used in TCs

Resource  cbts_general.robot


*** Keywords ***
Check All Cells From VCU
    [Documentation]  This keyword is used to check the given parameters for all vCU cells.
    ...  Given argument is:
    ...  &{parameters} - which is a dictionary and can be for example: administrative_state=Unlocked  operational_state=Enabled
    ...  An example for using this KW: Check all cells from vCU  administrative_state=Unlocked  operational_state=Enabled
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  &{parameters}

    ${cells_status}  vcu.Get Cells Statuses
    Should Not Be Empty  ${cells_status}
    FOR  ${cell_status}  IN  @{cells_status}
        Verify Parameters For Cell From VCU  ${cell_status}  ${parameters}
    END


Check The Specific Cell From VCU
    [Documentation]  This keyword is used to check the given parameters for one specific cell from vCU.
    ...  Given arguments are:
    ...  ${cell_id} - this is the id of the cell to be checked.
    ...  &{parameters} - which is a dictionary with all the parameters that will be checked.
    ...  An example for using this KW: Check the specific cell from vCU  administrative_state=Unlocked  operational_state=Enabled
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${cell_id}  &{parameters}

    ${cells_status}  vcu.Get Cells Statuses
    FOR  ${cell_status}  IN  @{cells_status}
        Run Keyword If  ${cell_status}[id] == ${cell_id}
        ...  Verify Parameters For Cell From VCU  ${cell_status}  ${parameters}
        ...  ELSE
        ...  Continue For Loop
    END


Open SSH Connection To VCU And Connect To Openshift
    [Documentation]
    ...  This keyword opens connection to vCU and Openshift.
    ...  ${VCU_SSH_IP}, ${VCU_SSH_USERNAME} and ${VCU_SSH_PASSWORD} are set in vcu_frame.robot resource.

    SSHLibrary.Open Connection  ${VCU_SSH_IP}  prompt=$  timeout=20s
    SSHLibrary.Login  ${VCU_SSH_USERNAME}  ${VCU_SSH_PASSWORD}
    SSHLibrary.Write  oc login -u nokiaadmin -p nokiaadmin
    ${oc_login_output}  SSHLibrary.Read Until Prompt
    ${oc_login_status}  Run Keyword And Return Status
    ...  Should Contain  ${oc_login_output}  Login successful
    Run Keyword If  ${oc_login_status}==${FALSE}
    ...  Fail  Connection to Openshift failed. [NOK]
    Log  vCU and Openshift connection successfully done. [OK]  console=true


Verify Parameters For Cell From VCU
    [Documentation]  This keyword is used to verify the value of the given parameters.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${cell_status}  ${parameters}

    FOR  ${parameter}  IN  @{parameters}
        Should Contain  ${parameters}[${parameter}]  ${cell_status}[${parameter}]
    END


Get Total Number Of DUs Linked To CU
    [Documentation]
    ...  This keyword is used to get total number of DUs linked to CU.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com

    ${dus_state}  Get Du State
    ${no_of_locked_dus}  Set Variable  ${dus_state}[administrative_state][locked]
    ${no_of_unlocked_dus}  Set Variable  ${dus_state}[administrative_state][unlocked]
    ${total_dus_ad_state}  Evaluate  ${no_of_locked_dus} + ${no_of_unlocked_dus}
    ${no_of_available_dus}  Set Variable  ${dus_state}[f1_link_status][available]
    ${no_of_unavailable_dus}  Set Variable  ${dus_state}[f1_link_status][unavailable]
    ${total_dus_av_status}  Evaluate  ${no_of_available_dus} + ${no_of_unavailable_dus}
    Should Be Equal As Integers  ${total_dus_ad_state}  ${total_dus_av_status}  Number of DUs obtained from two sources does not correspond. [NOK]

    [Return]  ${total_dus_ad_state}


Verify DUs Linked To CU To Be On Air
    [Documentation]
    ...  This keyword verifies all DUs linked to CU to be on air.
    ...  Number of locked and unavailable DUs should be 0.
    ...  Number of unlocked and available DUs should be equal to ${no_of_dus}.
    ...  ${no_of_dus} can be obtained with "Get total number of DUs linked to CU" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${no_of_dus}

    ${dus_state}  vcu.Get Du State
    Should Be Equal As Integers  ${dus_state}[administrative_state][locked]  0  There is at least one locked DU. [NOK]
    Should Be Equal As Integers  ${dus_state}[administrative_state][unlocked]  ${no_of_dus}  Not all DUs are unlocked. [NOK]
    Should Be Equal As Integers  ${dus_state}[f1_link_status][unavailable]  0  There is at least one unavailable DU. [NOK]
    Should Be Equal As Integers  ${dus_state}[f1_link_status][available]  ${no_of_dus}  Not all DUs are available. [NOK]
    Log  All DUs linked to CU are available and unlocked. [OK]  console=true


Verify CU X2 Links States
    [Documentation]
    ...  This keyword verifies X2 links on CU.
    ...  ${link_status} can be available/unavailable.
    ...  ${locking_state} can be locked/unlocked.
    ...  Example of usage:
    ...  Verify CU X2 links states  ${Available_}
    ...                       ${Unlocked_}
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${link_status}  ${locking_state}

    ${x2_links_info}  Get X2 Links Info
    ${x2_links}  Set Variable  ${x2_links_info}[created]
    Should Not Be Empty  ${x2_links}
    FOR  ${link}  IN  @{x2_links}
        ${x2_link_obj}  Fetch From Right  ${link}[dist_names][config]  /
        Should Contain  ${link_status}  ${link}[x2_link_status]  ${x2_link_obj} / eNodeB-${link}[enb_id] is not ${link_status}. [NOK]
        Should Contain  ${locking_state}  ${link}[x2_link_lock]  ${x2_link_obj} / eNodeB-${link}[enb_id] is not ${locking_state}. [NOK]
    END
    Log  All CU X2 links are ${link_status} and ${locking_state}. [OK]  console=true


Check All PODs On VCU To Be On Air And Verify Their Information
    [Documentation]
    ...  This keyword verifies pods on CU.
    ...  name, instance, availability_status, operational_state, role and ip_addresses are checked.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com

    ${pods_informations}  Get Vnfcs States
    FOR  ${pod}  IN  @{pods_informations}
        Should Not Be Empty  ${pod}[name]  Pod name should be set. [NOK]
        Should Not Be Empty  ${pod}[instance]  Pod instance should be set. [NOK]
        Should Contain  ${ONLINE}  ${pod}[availability_status]  Pod "${pod}[name]" is not on line. [NOK]
        Should Contain  ${ENABLED}  ${pod}[operational_state]  Pod "${pod}[name]" is not enabled. [NOK]
        Should Contain  ${DISABLED}  ${pod}[role]  Pod "${pod}[name]" should have the role: Disabled. [NOK]
        Log  Pod "${pod}[name]" with instance id: "${pod}[instance]" is Online and Enabled and has the role: Disabled.  console=true
        ${ip_addresses_status}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${pod}[ip_interfaces]
        Run Keyword If  ${ip_addresses_status}
        ...  Run Keywords
        ...  Log  \tIP interfaces are:  console=true
        ...  AND
        ...  Log  \t\t$${pod}[ip_interfaces]  console=true
    END


Change Specific Parameter For VCU
    [Documentation]  This keyword is used to change a specific parameter from vCU.
    ...  Given arguments are:
    ...  ${parameter_name} - e.g. jwtExpirationTime
    ...  ${parameter_value} - e.g. 20
    ...  ${distname_of_parameter_obj} - which is the parameter distname from Configuration Management.
    ...                           e.g. MRBTS-1/MNL-1/AMGR-1/LUAC-1
    ...  *AUTHORS*: andreea.burtic@nokia.com
    ...       anna.benzar@nokia.com
    ...  *MAINTAINERS*: andreea.burtic@nokia.com
    ...           anna.benzar@nokia.com
    [Arguments]  ${parameter_name}  ${parameter_value}  ${distname_of_parameter_obj}

    Log  Change vCU ${parameter_name} parameter to be ${parameter_value}  console=true
    ${parameter}  Create Dictionary  parameterName=${parameter_name}  value=${parameter_value}  operation=update
    ${parameter_change_list}  Create List  ${parameter}
    ${changed_parameter}  Create Dictionary  distName=${distname_of_parameter_obj}  operation=update  parameters=${parameter_change_list}
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vcu.Perform Delta Recommissioning  ${changed_parameter_string}


Delete Planned Configurations On VCU
    [Documentation]
    ...  This keyword deletes all planned configurations created, that were not activated.
    ...  ${plans} can be obtained with "Get plan info" keyword from taf.gnb.oam.coam.cu
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${plans}

    FOR  ${plan}  IN  @{plans}
        vcu.Plan Delete  ${plan}[plan_id]
    END


Change JwtExpirationTime Parameter To Desired Value On VCU
    [Documentation]
    ...  This keyword reconnects to vCU and changes jwtExpirationTime to given value.
    ...  ${value} can be given in seconds or minutes.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${value}

    Connect To VCU  host=${VCU_OAM_IP}
    Change Specific Parameter For VCU  jwtExpirationTime  ${value}  MRBTS-1/MNL-1/AMGR-1/LUAC-1


Check If Fault Is Visible In VCU WebEM
    [Documentation]
    ...  This keyword checks if given alarm/fault information matches any active alarms in WebEM.
    ...  If given alarm is found, it's information is set as a test variable.
    [Arguments]  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${severity}

    ${active_alarms}  vcu.Get Active Alarms
    ${alarms_list}  Set Variable  ${active_alarms}[alarms]
    FOR  ${alarm}  IN  @{alarms_list}
        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_alarm_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_name]  ${alarm_name}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        ${status_fault_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_name]  ${fault_name}
        ${status_severity}  Run Keyword And Return Status
        ...  Should Contain  ${severity}  ${alarm}[severity]
        ${match_condition}  Catenate  ${status_alarm_id}  and ${status_alarm_name}  and ${status_fault_id}  and ${status_fault_name}
        ...  and ${status_severity}
        Run Keyword If  ${match_condition}
        ...  Run Keywords
        ...  Set Test Variable  ${ALARM_INFO}  ${alarm}
        ...  AND
        ...  Exit For Loop
    END
    Should Be True  ${match_condition}  Alarm "${alarm_name}", with fault id: ${fault_id}, not found in active alarms list. [NOK]
    Log  Alarm "${alarm_name}", with fault id: ${fault_id}, is visible in WebEM. [OK]  console=true


Check If Fault Is Cleared From VCU WebEM
    [Documentation]
    ...  This keyword checks if given alarm/fault information matches any active alarms in WebEM.
    ...  If alarm is still found active in WebEM, keyword fails.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${alarm_id}  ${fault_id}

    ${active_alarms}  vcu.Get Active Alarms
    ${alarms_list}  Set Variable  ${active_alarms}[alarms]
    FOR  ${alarm}  IN  @{alarms_list}
        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        Run Keyword If  ${status_alarm_id} and ${status_fault_id}
        ...  Fail  Alarm with fault id: ${FAUL_ID} is still visible in WebEM. [NOK]
    END
    Log  Alarm with fault id: ${fault_id}, successfully cleared from WebEM. [OK]  console=true


Open Connection To VCU And Bring Diagnostic Files To Local Machine
    [Documentation]
    ...  This keyword collects Diagnostic files to local machine in ${TEST_RESULTS_DIR}.
    ...  It uses "Get Full Name For Pod" and "Get Full Name For Container" keywords.
    ...  *ATUHOR*:  anna.benzar@nokia.com
    [Arguments]  ${namespace}  ${pod_name}  ${step_index}

    Open SSH Connection To VCU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${namespace}  ${pod_name}
    ${container}  Get Full Name For Container  ${namespace}  ${pod_name}
    ${copy_command}  Catenate  kubectl cp ${pod}:mnt/services/SS_OAM/ASM/working_dir/diagnostic_check/
    ...                        -n ${VCU_CRAN} -c ${container} /var/home/core/diagnostic_check
    SSHLibrary.Write  ${copy_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Get Directory  /var/home/core/diagnostic_check  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${step_index}
    SSHLibrary.Write  rm -rf /var/home/core/diagnostic_check
    SSHLibrary.Read Until Prompt
    ${files}  OperatingSystem.List Files In Directory  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${step_index}
    Should Contain  ${files}  DiagnosticHistoryHistogram.csv  DiagnosticHistoryHistogram.csv not found in directory. [NOK]
    Should Contain  ${files}  DiagnosticReport.csv  DiagnosticReport.csv not found in directory. [NOK]

    [Teardown]  SSHLibrary.Close Connection


Reset VCU And Wait For Ping
    [Documentation]    Reset vCU and wait for ping
    [Arguments]  ${ping_reestablished_timeout}=300

    Reset CU
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=60s
    Run Keyword If  ${ping_lost_status}
    ...  Log  vCU is resetting...  console=true
    ...  ELSE
    ...  Fail  Ping not lost during vCU reset. [NOK]
    ${ping_reestablished_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=${ping_reestablished_timeout}s
    Run Keyword If  ${ping_reestablished_status}
    ...  Log  vCU reset completed.  console=true
    ...  ELSE
    ...  Fail  Ping not reestablished after ${ping_reestablished_timeout}s vCU reset. [NOK]


Check Fault Signature Of Alarm In VCU In WebEM
    [Documentation]  This keyword is used to check fault signature of alarm in WebEM.
    [Arguments]
    ...  ${fault_name}
    ...  ${category}=${EMPTY}
    ...  ${load}=${EMPTY}
    ...  ${scope}=${EMPTY}
    ...  ${minor}=${EMPTY}
    ...  ${extra_info}=${EMPTY}
    ...  ${info}=${EMPTY}
    ...  ${component}=${EMPTY}

    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${historical_alarms}  vcu.Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_info}  Run Keyword If  '${alarm}[fault_name]'=='${fault_name}'
        ...  Run Keywords
        ...  Set Variable  ${alarm}
        ...  AND
        ...  Exit For Loop
    END
    ${faultsig}  Get From Dictionary  ${alarm_info}  fault_signature

    Run Keyword If  '${category}' != '${EMPTY}'
    ...  Should Be Equal  ${faultsig}[category]  ${category}  msg=Category not matched.
    Run Keyword If  '${component}' != '${EMPTY}'
    ...  Should Contain  ${faultsig}[component]  ${component}  msg=Component did not matched.
    Should Match Regexp  ${faultsig}[date]  ${date}  msg=Date not ok.
    Run Keyword If  '${extra_info}' != '${EMPTY}'
    ...  Should Match Regexp  ${faultsig}[extra_info]  ${extra_info}  msg=Extra info did not matched.
    Run Keyword If  '${info}' != '${EMPTY}'
    ...  Should Match Regexp  ${faultsig}[info]  ${info}  msg=Info did not matched.
    Run Keyword If  '${load}' != '${EMPTY}'
    ...  Should Be Equal  ${faultsig}[load_name]  ${load}  msg=Load name did not matched.
    Run Keyword If  '${minor}' != '${EMPTY}'
    ...  Should Be Equal  ${faultsig}[minor]  ${minor}  msg=Minor did not matched.
    Run Keyword If  '${scope}' != '${EMPTY}'
    ...  Should Be Equal  ${faultsig}[scope]  ${scope}  msg=Scope did not matched.

    Log  Fault signature in WebEM is ok.  console=True


VCU Get Parameter Value
    [Documentation]  This keyword returns parameter value based on parameter name and its distname. (not applicable for complex parameters)
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${parameter}  ${dist_name}

    ${object_params}  Get Parameters  ${dist_name}
    ${params_list}  Set Variable  ${object_params}[parameters]
    FOR  ${param_fields}  IN  @{params_list}
        ${simple_param_status}  ${simple_param_name}  Run Keyword And Ignore Error  Get Name By Parameter Type  simple_parameter  ${param_fields}
        ${simple_list_param_status}  ${simple_list_param_name}  Run Keyword And Ignore Error  Get Name By Parameter Type  simple_list_parameter
        ...  ${param_fields}

        ${param_type}  Set Variable If  "${simple_param_status}"=="PASS"  simple_parameter  simple_list_parameter
        ${param_name}  Set Variable If  "${param_type}"=="simple_parameter"  ${simple_param_name}  ${simple_list_param_name}
        IF  "${param_name}"!="${parameter}"  CONTINUE

        ${param_value}  Get Value By Parameter Type  ${param_type}  ${param_fields}
        RETURN  ${param_value}
    END

    Fail  Parameter ${parameter} is not defined.


Get Name By Parameter Type
    [Documentation]  This keyword returns parameter name based on its type (simple_parameter, simple_list_parameter or complex_parameter).
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${parameter_type}  ${parameter_fields}

    ${parameter_obj}  Get From Dictionary  ${parameter_fields}  ${parameter_type}
    ${parameter_obj}  Convert To String  ${parameter_obj}
    ${parameter_name}  Get Regexp matches  ${parameter_obj}  'name': '.*'
    ${parameter_name}  Fetch From Left  ${parameter_name}[0]  ,
    ${parameter_name}  Remove String  ${parameter_name}  'name':${SPACE}
    ${parameter_name}  Get Substring  ${parameter_name}  1  -1

    RETURN  ${parameter_name}


Get Value By Parameter Type
    [Documentation]  This keyword returns parameter value based on its type (simple_parameter or simple_list_parameter).
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${parameter_type}  ${parameter_fields}

    ${parameter_obj}  Get From Dictionary  ${parameter_fields}  ${parameter_type}
    ${parameter_obj}  Convert To String  ${parameter_obj}

    IF  '${parameter_type}'=='simple_parameter'
        ${parameter_value}  Fetch From Right  ${parameter_obj}  'value':${SPACE}'
        ${parameter_value}  Fetch From Left  ${parameter_value}  '
        RETURN  ${parameter_value}
    ELSE
        ${parameter_value_as_list}  Create List
        ${parameter_value}  Fetch From Right  ${parameter_obj}  'value':${SPACE}
        ${parameter_value}  Fetch From Left  ${parameter_value}  ]
        ${parameter_value}  Remove String  ${parameter_value}  [
        ${items}  Split String  ${parameter_value}  ,
        FOR  ${item}  IN  @{items}
            ${item}  Remove String Using Regexp  ${item}  \\n\\s+
            ${item}  Remove String  ${item}  '  "
            Append To List  ${parameter_value_as_list}  ${item}
        END
        RETURN  ${parameter_value_as_list}
    END


Open SHH Connection To VCU And Connect To Openshift
    [Documentation]
    ...  This keyword opens connection to vCU and Openshift.
    ...  ${VCU_SSH_IP}, ${VCU_SSH_USERNAME} and ${VCU_SSH_PASSWORD} are set in vcu_frame.robot resource.
    ...  *AUTHOR*: anna.benzar@nokia.com

    SSHLibrary.Open Connection  ${VCU_SSH_IP}  prompt=$  timeout=20s
    SSHLibrary.Login  ${VCU_SSH_USERNAME}  ${VCU_SSH_PASSWORD}
    SSHLibrary.Write  oc login -u nokiaadmin -p nokiaadmin
    ${oc_login_output}  SSHLibrary.Read Until Prompt
    ${oc_login_status}  Run Keyword And Return Status
    ...  Should Contain  ${oc_login_output}  Login successful
    SSHLibrary.Write  bind 'set enable-bracketed-paste off'  #This is here to remove [?2004l and [?2004h from output. Should not have other impact.
    SSHLibrary.Read Until Prompt
    IF  not ${oc_login_status}  Fail  Connection to Openshift failed. [NOK]
