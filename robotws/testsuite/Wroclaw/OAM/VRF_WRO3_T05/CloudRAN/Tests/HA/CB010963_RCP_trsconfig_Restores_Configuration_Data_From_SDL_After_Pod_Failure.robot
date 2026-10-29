*** Settings ***
Documentation
    ...    Test case to verify RCP trsconfig service resiliency. RCP trsconfig service shall persist
    ...    transport configuration data in SDL. When trsconfig is restarted after failure,
    ...    it should restore transport configuration data from SDL and resume its service without CNF reset.
    ...    History of changes:    08.07.2025 - Initial creation
    ...    Author:                damian.kotula@nokia.com
    ...    Arguments:
    ...        - ${hw_type}: CNF to be tested. TC supports vCU / vDU verification.

*** Variables ***
@{keys_to_check}=    nokia-firewall    nokia-ethernet    nokia-vlan    nokia-oam-dispatcher    nokia-qos    nokia-ip-routing
${expected_new_routing}=    "destination-ip":"10.20.30.40","destination-prefix":32,"metric":1,"next-hop":"10.20.30.1"

*** Keywords ***
CB010963 RCP-trsconfig Restores Configuration Data From SDL After Pod Failure
    [Arguments]    ${hw_type}
    Set Test Variable     ${hw_type}
    Step 1: Get Initial TRS And RCPSDL Configs
    Step 2: Change Routing By Adding New Static Route
    Step 3: Compare Initial And Changed Configs
    Step 4: Kill TRS Pod
    Step 5: Verify TRS Config Restored From RCPCDL
    [Teardown]    Restore ${hw_type} Initial Routing


Step 1: Get Initial TRS And RCPSDL Configs
    [Documentation]    In this step initial configurations from TRS and RCPSDL pods are retrieved and compared.
    Log    \nStep 1: Get Initial TRS And RCPSDL Configs    console=${True}
    IF    '${hw_type}' == 'vDU'
        ${namespace}=    Set Variable    ${CRAN_VDU}
    ELSE IF    '${hw_type}' == 'vCU'
        ${namespace}=    Set Variable    ${CRAN_VCU}
    END
    Set Test Variable    ${NAMESPACE}
    &{initial_trs_config}=    Create Dictionary
    &{initial_sdl_config}=    Create Dictionary
    FOR    ${key}    IN    @{keys_to_check}
          ${trs_output}=    Get Config From TRS Pod      hw_type=${hw_type}    key=${key}
          ${sdl_output}=    Get Config From RCPSDL Pod   hw_type=${hw_type}    key=${key}
          Set To Dictionary    ${initial_trs_config}    ${key}=${trs_output}
          Set To Dictionary    ${initial_sdl_config}    ${key}=${sdl_output}
    END
    Should Be Equal      ${initial_trs_config}    ${initial_sdl_config}
    Set Test Variable    ${INITIAL_TRS_CONFIG}
    Set Test Variable    ${INITIAL_SDL_CONFIG}


Step 2: Change Routing By Adding New Static Route
    [Documentation]    In this step a new static route is added to the existing routing configuration.
    Log    \nStep 2: Change Routing By Adding New Static Route    console=${True}
    IF    '${hw_type}' == 'vDU'
        Configure Additional Routing On vDU
    ELSE IF    '${hw_type}' == 'vCU'
        Configure Additional Routing On vCU
    END


Step 3: Compare Initial And Changed Configs
    [Documentation]    In this step the initial and changed configs are compared to ensure that they are stored
    ...                in trs and rcpdsl pods correctly.
    Log    \nStep 3: Compare Initial And Changed Configs    console=${True}
    &{changed_trs_config}=    Create Dictionary
    &{changed_sdl_config}=    Create Dictionary
    FOR    ${key}    IN    @{keys_to_check}
          ${trs_output}=    Get Config From TRS Pod       hw_type=${hw_type}    key=${key}
          ${sdl_output}=    Get Config From RCPSDL Pod    hw_type=${hw_type}    key=${key}
          Set To Dictionary    ${changed_trs_config}    ${key}=${trs_output}
          Set To Dictionary    ${changed_sdl_config}    ${key}=${sdl_output}
    END
    Set Test Variable    ${CHANGED_TRS_CONFIG}
    Should Be Equal      ${CHANGED_TRS_CONFIG}    ${changed_sdl_config}

    FOR    ${key}    IN    @{keys_to_check}
        IF    '${key}' == 'nokia-ip-routing'
              Continue For Loop
        END
        Should Be Equal    ${INITIAL_TRS_CONFIG['${key}']}    ${CHANGED_TRS_CONFIG['${key}']}
        Should Be Equal    ${INITIAL_SDL_CONFIG['${key}']}    ${changed_sdl_config['${key}']}
        Log    ${key} is equal in initial and changed configs    console=${True}
    END
    Should Not Be Equal    ${INITIAL_TRS_CONFIG["nokia-ip-routing"]}    ${CHANGED_TRS_CONFIG["nokia-ip-routing"]}
    Should Not Be Equal    ${INITIAL_SDL_CONFIG["nokia-ip-routing"]}    ${changed_sdl_config["nokia-ip-routing"]}
    Should Not Contain     ${INITIAL_TRS_CONFIG["nokia-ip-routing"]}    ${expected_new_routing}
    Should Not Contain     ${INITIAL_SDL_CONFIG["nokia-ip-routing"]}    ${expected_new_routing}
    Should Contain         ${CHANGED_TRS_CONFIG["nokia-ip-routing"]}    ${expected_new_routing}
    Should Contain         ${changed_sdl_config["nokia-ip-routing"]}    ${expected_new_routing}
    Log    nokia-ip-routing contains new routing as expected    console=${True}


Step 4: Kill TRS Pod
    [Documentation]    In this step TRS pod is changed to not critical and killed to simulate a failure scenario.
    Log    \nStep 4: Kill TRS Pod    console=${True}
    ${rmv_cmd}=  Set Variable  '[{"op": "remove", "path": "/data/containerCriticality.causeVNFRestart", "value":"- ctr-trsconfig\n "}]'
    ${add_cmd}=  Set Variable  '[{"op": "add", "path": "/data/containerCriticality.causeVNFRestart", "value":"- ctr-trsconfig\n "}]'
    ${remove_critical_container_cmd}=  Set Variable    kubectl patch configmap -n ${NAMESPACE} conf-cri-healing-controller --type json -p=${rmv_cmd}
    ${add_critical_container_cmd}=     Set Variable    kubectl patch configmap -n ${NAMESPACE} conf-cri-healing-controller --type json -p=${add_cmd}
    ${ssh_connection}=    Connect to ADMIN via SSH    hw_type=${hw_type}
    ${trsconfig_pod}=     Get Specific Pod    hw_type=${hw_type}    specific_pod=trsconfig
    ${delete_trs_pod_cmd}=    Set Variable    kubectl delete pod ${trsconfig_pod} --grace-period=0 --force --namespace ${NAMESPACE}
    ssh.Send Command    command=${remove_critical_container_cmd}    connection=${ssh_connection}
    ${remove_crit_output}=    ssh.Read Output    connection=${ssh_connection}
    Should Be Equal As Strings    ${remove_crit_output}    configmap/conf-cri-healing-controller patched\n
    ssh.Send Command    command=${delete_trs_pod_cmd}    connection=${ssh_connection}
    ${delete_trs_pod_output}=    ssh.Read Output    connection=${ssh_connection}
    Should Be Equal As Strings    ${delete_trs_pod_output}    pod \"${trsconfig_pod}\" force deleted\n
    Wait Until Keyword Succeeds    1m    1s    Get Pod Status    connection=${ssh_connection}    namespace=${NAMESPACE}
    ...                                                          pod_name=trs    expected_status=Running
    [Teardown]    Run Keywords    ssh.Send Command    command=${add_critical_container_cmd}    connection=${ssh_connection}
                  ...      AND    Disconnect From ADMIN via SSH    connection=${ssh_connection}    hw_type=${hw_type}


Step 5: Verify TRS Config Restored From RCPCDL
    [Documentation]    In this step configuration in TRS pod is compared to config before reset in order to
    ...                verify if it was restored from RCPSDL correctly.
    Log    \nStep 5: Verify TRS Config Restored From RCPCDL    console=${True}
    &{trs_config_after_reset}=    Create Dictionary
    FOR    ${key}    IN    @{keys_to_check}
        ${trs_output}=    Get Config From TRS Pod    hw_type=${hw_type}    key=${key}
        Set To Dictionary    ${trs_config_after_reset}    ${key}=${trs_output}
    END
    ${equal_after_reset}=    Run Keyword And Return Status    Should Be Equal    ${trs_config_after_reset}    ${CHANGED_TRS_CONFIG}
    IF    not ${equal_after_reset}
        Fail   msg=TRS config after reset is not equal to config before reset.
    ELSE
        Log    TRS config is properly restored.    console=${True}
    END


Get Config From TRS Pod
    [Documentation]    This keyword retrieves configuration from TRS pod for a given key.
    [Arguments]  ${hw_type}   ${key}
    ${trsconfig_pod}=    Get Specific Pod    hw_type=${hw_type}    specific_pod=trsconfig
    ${trs_output}=       Execute Command on Fully Given Container    pod=${trsconfig_pod}
    ...                                         container=ctr-trsconfig
    ...                                         command=bash -c "cat /etc/trswsysrepo/data/${key}.startup"
    ...                                         hw_type=${hw_type}
    ${trs_cleaned_output}=    Strip String    ${trs_output}
    [Return]    ${trs_cleaned_output}

Get Config From RCPSDL Pod
    [Documentation]    This keyword retrieves configuration from RCPSDL pod for a given key.
    [Arguments]  ${hw_type}    ${key}
    ${commands}=      Set Variable    redis-cli -h rcpsdl && echo 'get {trs_ds},${key}' | redis-cli -h rcpsdl
    ${rcpsdl_pod}=    Get Specific Pod    hw_type=${hw_type}    specific_pod=rcpsdl
    ${ssh_connection}=    Connect to ADMIN via SSH    hw_type=${hw_type}
    ${cmd}=    ssh.Send Command    kubectl exec ${rcpsdl_pod} -c ctr-rcpsdl -n ${NAMESPACE} -- bash -c "${commands}"
    ...                            connection=${ssh_connection}
    ${output}=    ssh.Read Output    connection=${ssh_connection}
    ${cleaned_output}=    Strip String    ${output}
    [Return]    ${cleaned_output}
    [Teardown]    Disconnect From ADMIN via SSH    connection=${ssh_connection}    hw_type=${hw_type}

Get Pod Status
    [Documentation]    This keyword retrieves the status of a specific pod in a given namespace.
    [Arguments]    ${connection}    ${namespace}    ${pod_name}    ${expected_status}
    ${pod_status}=    ssh.Send Command    command=oc get pods -n ${namespace} |grep ${pod_name}    connection=${connection}
    ${pod_status_output}=    ssh.Read Output    connection=${connection}
    Should Contain    ${pod_status_output}    ${expected_status}

Configure Additional Routing On vDU
    [Documentation]    This keyword retrieves initial static routing from vDU, stores it in test variable and configures
    ...                additional static route to the existing routing configuration.
    ${iprt_dn}=          Set Variable    MRBTS-${MRBTS}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1
    Set Test Variable    ${IPRT_DN}
    @{dist_name}=        Create List    ${IPRT_DN}
    ${original_IPRT}=    vdu_admin.Get Current Plan Objects    dist_names=${dist_name}    vdu_connection=${vdu_connection}
    ${objects}=          Get From Dictionary    ${original_IPRT}       objects
    ${first_object}=     Get From List          ${objects}             0
    ${json_repr}=        Get From Dictionary    ${first_object}        json_repr
    ${parsed_json}=      Evaluate    json.loads('''${json_repr}''')    json
    ${static_routes}=    Get From Dictionary    ${parsed_json}         staticRoutes
    Set Test Variable    ${ORIGINAL_STATIC_ROUTES}    ${static_routes}
    &{additional_iprt_dict}=    Create Dictionary    destIpAddr=10.20.30.40
    ...                                              destinationIpPrefixLength=32
    ...                                              gateway=10.20.30.1
    ${new_static_routes}=    Copy List    ${ORIGINAL_STATIC_ROUTES}
    Append To List    ${new_static_routes}     ${additional_iprt_dict}
    vdu_admin.Perform Parameter Recommissioning     dist_name=${IPRT_DN}
    ...                                             parameter=staticRoutes
    ...                                             operation=update
    ...                                             value=${new_static_routes}
    ...                                             vdu_connection=${vDU_connection}

Configure Additional Routing On vCU
    [Documentation]    This keyword retrieves initial static routing from vCU, stores it in test variable and configures
    ...                additional static route to the existing routing configuration.
    ${iprt_dn}=    Set Variable    MRBTS-${MRBTS_CU}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1
    Set Test Variable    ${IPRT_DN}
    ${tnl_content}=      vcu_admin.Get Parameters    dist_name=${IPRT_DN}
    ...                                              connection=${vCU_connection}
    ${parameters}=       Get From Dictionary    ${tnl_content}      parameters
    ${complex_param}=    Get From Dictionary    ${parameters[0]}    complex_parameter
    ${routes}=           Get From Dictionary    ${complex_param}    value
    @{original_static_routes}=    Create List
    FOR    ${route}    IN    @{routes}
        ${structure_params}=    Get From Dictionary    ${route}    structureParameters
        &{route_dict}=    Create Dictionary
        FOR    ${param}    IN    @{structure_params}
            ${name}=     Get From Dictionary    ${param['simpleParameter']}    name
            ${value}=    Get From Dictionary    ${param['simpleParameter']}    value
            Set To Dictionary    ${route_dict}    ${name}=${value}
        END
        Append To List    ${original_static_routes}    ${route_dict}
    END
    Set Test Variable    ${ORIGINAL_STATIC_ROUTES}
    ${new_static_routes}=    Copy List    ${ORIGINAL_STATIC_ROUTES}
    &{additional_iprt_dict}=    Create Dictionary    destIpAddr=10.20.30.40
    ...                                              destinationIpPrefixLength=32
    ...                                              gateway=10.20.30.1
    Append To List    ${new_static_routes}     ${additional_iprt_dict}
    &{new_routing_dict}=        Create Dictionary    parameterName=staticRoutes
    ...                                              value=${new_static_routes}
    ...                                              operation=crate
    @{new_routing_list}=        Create List          ${new_routing_dict}
    &{delta_dict}=              Create Dictionary    distName=${IPRT_DN}
    ...                                              operation=create
    ...                                              parameters=@{new_routing_list}
    @{delta}=                   Create List          ${delta_dict}
    ${delta_json}=              Evaluate             json.dumps(${delta})    json
    vcu_admin.Perform Delta Recommissioning          delta_file=${delta_json}    connection=${vCU_connection}

Restore vDU Initial Routing
    [Documentation]    This keyword restores initial static routing configuration on vDU.
    Log    \nRestoring Initial vDU Routing    console=${True}
    vdu_admin.Perform Parameter Recommissioning     dist_name=${IPRT_DN}
    ...                                             parameter=staticRoutes
    ...                                             operation=update
    ...                                             value=${ORIGINAL_STATIC_ROUTES}
    ...                                             vdu_connection=${vDU_connection}

Restore vCU Initial Routing
    [Documentation]    This keyword restores initial static routing configuration on vCU.
    Log    \nRestoring Initial vCU Routing    console=${True}
    &{restore_routing_dict}=    Create Dictionary    parameterName=staticRoutes
    ...                                              value=${ORIGINAL_STATIC_ROUTES}
    ...                                              operation=create
    @{restore_routing_list}=    Create List          ${restore_routing_dict}
    &{restore_delta_dict}=      Create Dictionary    distName=${IPRT_DN}
    ...                                              operation=create
    ...                                              parameters=@{restore_routing_list}
    @{restore_delta}=           Create List          ${restore_delta_dict}
    ${restore_delta_json}=      Evaluate             json.dumps(${restore_delta})    json
    vcu_admin.Perform Delta Recommissioning          delta_file=${restore_delta_json}    connection=${vCU_connection}
