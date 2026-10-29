*** Settings ***

Documentation   Common KWs for AIC vDU


Library   OperatingSystem

Library   taf.collectors.kubernetes      WITH NAME    kubelog
Library   taf.collectors.core            WITH NAME    core
Library   taf.gnb.oam.coam.vdu           WITH NAME    coam_vdu
Library   python/testline.py             WITH NAME    testline_py   
Library   python/aic_commissioning.py    WITH NAME    aic_comm_py
Library   python/robot_extension.py      WITH NAME    rbext_py
Library   python/aic_gnb.py

Resource    testline.robot
Resource    networking.robot


*** Keywords ***
Connect to OAM DU
    [Documentation]
    ...
    ...     Creates a Session to connect to OAM vDU. 
    ...     If no alias given in `alias` an alias is constructed in following way: gnb-`gnb_id`-du-`du_id`-oam-vdu
    ...
    ...     | gnb_id | Id of gnb                         |
    ...     | du_id  | Id of du                          |
    ...     | alias  | alias to identify this connection |
    ...
    ...     *Returns*   oam session to specified vDU
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}    ${alias}=gnb-${gnb_id}-du-${du_id}-oam-vdu
    ${du_oam_session}   coam_vdu.connect to
    ...         host=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.addr}
    ...         port=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.port}
    ...         username=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.username}
    ...         password=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.password}
    ...         secure=${True}
    ...         connection_name=${alias}
    [Return]    ${du_oam_session}


Get Amount of VDUs
    [Documentation]
    ...
    ...     Gets the number of vDUs in specified gnb.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    ...     *Returns*   number of vDUs
    ...
    [Arguments]    ${gnb_id}
    ${amount_of_vdus}    Get Length    ${tl.gnbs[${gnb_id}].dus}
    [Return]   ${amount_of_vdus}


Reboot all VDUs
    [Documentation]
    ...
    ...     Reboot all vDUs sequencially and wait until vDU oam http connection address is reachable.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]    ${gnb_id}=${0}
    ${amount_of_vdus}   Get Amount of VDUs   gnb_id=${gnb_id}
    FOR   ${du_id}   IN RANGE    ${amount_of_vdus}
        Reboot VDU    gnb_id=${gnb_id}   du_id=${du_id}
    END


Reboot VDU
    [Documentation]
    ...
    ...     Reboot VDU and wait until vDU oam http connection address is reachable.
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]  ${gnb_id}=${0}   ${du_id}=0
    ${session}   Connect to OAM dU  gnb_id=${gnb_id}   du_id=${du_id}
    coam_vdu.Reset Vdu    vdu_connection=${session}
    Wait Until Ping Failed      ip_addr=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.addr}
    ...                         iterations=500
    Wait Until Ping Succeeds    ip_addr=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.addr}
    ...                         iterations=500
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Wait until VDU is ready
    [Documentation]
    ...
    ...     Should Wait until specified vDU is in ready state. But does not seem to do that. 
    ...     this causes the keyword that calls this to misbehave. TO CHECK LATER!
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${session}             Connect to OAM DU               gnb_id=${gnb_id}  du_id=${du_id}
    ${rmods_summary}       coam_vdu.get_rmods_summary      vdu_connection=${session}
    ${vdu_state_summary}   coam_vdu.get_vdu_state_data     vdu_connection=${session}

    Should Be Equal   ${rmods_summary['operational_state']['disabled']}          ${0}
    ...               msg=Found '${rmods_summary['operational_state']['disabled']}' rmod(s) in disabled state!
    ...               values=${False}

    ${expected_states}   Create List    integrated to RAN    configured    onAir
    Should Be True     '${vdu_state_summary['operational_state']}' in ${expected_states}

    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Wait until All VDU are ready
    [Documentation]
    ...
    ...     Waits until all vDUs are in ready state.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]  ${gnb_id}=${0}
    ${nbr_of_connected_vdu}     Get Length  ${tl.gnbs[${gnb_id}].dus}
    FOR     ${vdu}  IN RANGE    ${nbr_of_connected_vdu}
        Log To Console  \nCheck VDU '${vdu}':
        Wait until VDU is ready     gnb_id=${gnb_id}    du_id=${vdu}
    END


Wait until VDU is onAir
    [Documentation]
    ...
    ...     Waits until specified vDU is in onAir state. Fails if timeout is reached without reaching onAir state.
    ...
    ...     | gnb_id  | Id of gnb                 |
    ...     | du_id   | Id of du                  |
    ...     | timeout | timeout for the operation |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}   ${timeout}=2min
    Wait Until Keyword Succeeds     10s   ${timeout}
    ...        Operational State of VDU should be on Air   gnb_id=${gnb_id}
    ...                                                    du_id=${du_id}


Wait until All VDU are onAir
    [Documentation]
    ...
    ...     Waits until all vDUs are in onAir state. 
    ...     Fails if timeout is reached without all vDUs reaching onAir state.
    ...
    ...     | gnb_id  | Id of gnb                 |
    ...     | timeout | timeout for the operation |
    ...
    [Arguments]  ${gnb_id}=${0}     ${timeout}=2min
    ${nbr_of_connected_vdu}     Get Length  ${tl.gnbs[${gnb_id}].dus}
    FOR     ${vdu}  IN RANGE    ${nbr_of_connected_vdu}
        Log To Console  \nCheck VDU '${vdu}':
        Wait until VDU is onAir     gnb_id=${gnb_id}    du_id=${vdu}    timeout=${timeout}
    END


Operational State of VDU should be on Air
    [Documentation]
    ...
    ...     Checks the operational vDU state and fails if not on Air.
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${session}   Connect to OAM dU  gnb_id=${gnb_id}   du_id=${du_id}
    ${vdu_state_summary}    coam_vdu.get_vdu_state_data     vdu_connection=${session}
    Should Be Equal   ${vdu_state_summary['operational_state']}          onAir     msg=OAM VDU is not onAir
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Get Pods Info
    [Documentation]
    ...
    ...     Gets information about the Pods. Does not return anything but Pod info is visible in the robot logs.
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${session}  Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${info}     coam_vdu.get_pods_info  ${session}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Get DU Cell Summary
    [Documentation]
    ...
    ...     Gets DU cell summary. Does not return anything but cell summary is visible in the robot logs.
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${session}  Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${info}     coam_vdu.get_vdu_cells_summary  vdu_connection=${session}
    ${info}     coam_vdu.get_vdu_state_data     vdu_connection=${session}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Get DU SW Version
    [Documentation]
    ...
    ...     Get the DU software version
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    ...     *Returns*   the DU SW version as a string
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${session}  Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${info}     coam_vdu.get_vdu_state_data     vdu_connection=${session}
    ${du_sw}    testline_py.reform_coam_sw_version    ${info['software_version']}
    Log To Console  \nDU SW Version: ${du_sw}
    [Return]    ${du_sw}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Get DU current plan file
    [Documentation]
    ...
    ...     Gets the current vDU plan file (scf) and copies it to the location given
    ...     in the `resultConfigDir`. If no path given the file is placed in
    ...     the Test Suite Config Directory. If filename not given in `gnbScfName`
    ...     a default name if constructed in following way: scf_gnb_`gnb_id`_du.xml
    ...
    ...     | gnbScfName      | scf file name                    |
    ...     | resultConfigDir | path where to copy the plan file |
    ...     | gnb_id          | Id of gnb                        |
    ...     | du_id           | Id of du                         |
    ...
    ...     *Returns*   plan filename with full path
    ...
    [Arguments]  ${gnbScfName}=${None}  ${resultConfigDir}=${None}  ${gnb_id}=${0}    ${du_id}=${0}
    ${resultConfigDir}  Run Keyword If  '${resultConfigDir}' == 'None'
    ...             testline.Get Test Suite Config Directory
    ...     ELSE    Set Variable  ${resultConfigDir}
    ${gnbScfName}  Set Variable if  '${gnbScfName}' == 'None'  scf_gnb_${gnb_id}_du.xml  ${gnbScfName}
    ${session}  Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${scf_path}    coam_vdu.get_current_plan_file  local_dir_path=${resultConfigDir}  filename=${gnbScfName}  vdu_connection=${session}
    ...             include_runtime_data=${False}
    [Return]    ${scf_path}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${session}


Collect vDU Btslog
    [Documentation]
    ...
    ...     This keyword collects vDU bts log per pods.
    ...
    ...     | pod_name   | Pod name where you want to collect [e.g cprt, oamext] |
    ...     | gnb_id     | Id of gnb                                             |
    ...     | du_id      | Id of du                                              |
    ...     | target_dir | location of log storage                               |
    ...
    [Arguments]  ${pod_name}    ${gnb_id}=${0}    ${du_id}=${0}    ${target_dir}=${None}
    ${target_dir}  Run Keyword If  '${target_dir}' == 'None'
    ...                testline.Create testcase log directory
    ...                ELSE    Set Variable  ${target_dir}
    Create Directory    ${target_dir}
    ${session}     connect.Connect to gNB vDu    gnb_id=${gnb_id}   du_id=${du_id}
    ${namespace}=	  Set Variable  ${tl.gnbs[${gnb_id}].cloud_deployment.cloud_hosting.namespace}
    ${syslog_name}=	Set Variable  ${namespace}-${pod_name}-${gnb_id}_syslog.log

    Ssh.Execute  kubectl logs -n ${namespace} ute-${namespace}-${pod_name}-${gnb_id} --all-containers > ${syslog_name}
    ...          connection=${session}    timeout=30s
    Ssh.Download File    remote_path=/var/home/core/${syslog_name}
    ...                 local_path=${target_dir}/${syslog_name}    connection=${session}
    [Return]    ${target_dir}/${syslog_name}
    [Teardown]      Run Keyword And Ignore Error    Ssh.Disconnect   connection=${session}


Collect vDU Btslog 2
    [Documentation]
    ...     This keyword will replace the original after https://jiradc.ext.net.nokia.com/browse/TAF-3089
    ...
    ...     This keyword collects vDU bts log per pods.
    ...
    ...     | pod_name   | Pod name where you want to collect [e.g cprt, oamext] |
    ...     | gnb_id     | Id of gnb                                             |
    ...     | du_id      | Id of du                                              |
    ...     | target_dir | location of log storage                               |
    ...     | collector  |  Name of collector *Impact on log filename*           |
    ...
    [Arguments]  ${pod_name}    ${gnb_id}=${0}    ${du_id}=${0}    ${target_dir}=${None}    ${collector}=${pod_name}-${gnb_id}-btslog
    ${target_dir}  Run Keyword If  '${target_dir}' == 'None'
    ...                testline.Create testcase log directory
    ...                ELSE    Set Variable  ${target_dir}

    ${namespace}       Set Variable  ${tl.gnbs[${gnb_id}].cloud_deployment.cloud_hosting.namespace}

    ${gnbvdu_ssh_config}  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].dus[${du_id}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].dus[${du_id}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].dus[${du_id}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    kubelog.create_kubernetes_collector
    ...    name=${collector}
    ...    namespace=${namespace}
    ...    pod_name=ute-${namespace}-${pod_name}-${gnb_id}
    ...    executor=${gnbvdu_ssh_config}
    ...    target_file_name=${collector}.tgz
    core.setup_collectors    names=${collector}
    core.start_collectors    names=${collector}
    sleep  60
    core.stop_collectors    names=${collector}
    core.collect_collectors    names=${collector}    target_dir=${target_dir}
    core.teardown_collectors    names=${collector}
    BuiltIn.Log    \nBtslog on gNB VDU on pod ${pod_name} started successfully    console=${P_console}

    [Return]    ${target_dir}/${collector}


Disconnect from OAM DU
    [Documentation]
    ...
    ...     Releases the connection to OAM vDU.
    ...
    ...     | alias | alias to identify the connection |
    ...
    [Arguments]  ${alias}
     rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${alias}


Get CU DU SW Branch From gNB SW Version
    [Documentation]
    ...
    ...     Get the vDU and CU version string from gnb software version.
    ...
    ...     | gnb_sw_version | gnb software version string. |
    ...
    ...     *Returns*   branch name for CU:DU delimited by colon
    ...
    [Arguments]  ${gnb_sw_version}=${Empty}
    ${CU_part}        Fetch From Left    ${gnb_sw_version}   :
    ${DU_part}        Fetch From Right   ${gnb_sw_version}   :
    ${CU_branch}      Fetch From Left    ${CU_part}          _
    ${DU_branch}      Fetch From Left    ${DU_part}          _
    @{CU_DU_Branch}   Create List        ${CU_branch}:${DU_branch}
    [Return]          ${CU_DU_Branch}


Get distNames from aic VDU
    [Documentation]
    ...
    ...     This TL specific keyword returns a list of distnames that are present in the DU OAM Plan
    ...
    ...     | regex     | Regular expression of the distname that is required to be matched with the DU OAM plan  |
    ...     | gnb_id    | Id of gnb |
    ...     | du_id     | Id of du  |
    ...
    ...     *Returns*   a list of distnames matching the regular expression given
    ...
    [Arguments]     ${regex}  ${gnb_id}=0  ${du_id}=0
    ${DU_alias}    Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${distNames}  aic_gnb.extract_distnames_from_aic_vdu  alias=${DU_alias}  regex=${regex}
    [Return]    ${distNames}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${DU_alias}


### Private ###
Validating vDU Delta Plan Operation Should Be Successful
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword check if status=success for validation of vDU delta plan. 
    ...     Will fail if status in response not success.
    ...
    ...     | delta_plan_id | id of delta plan           |
    ...     | action_id     | Id of validation procedure |
    ...     | gnb_id        | Id of gnb                  |
    ...     | du_id         | Id of du                   |
    ...
    [Arguments]  ${delta_plan_id}  ${action_id}   ${gnb_id}=0     ${du_id}=0
    ${DU_alias}   Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${res}     coam_vdu.get_validate_delta_plan_operation_status   ${delta_plan_id}  ${action_id}   vdu_connection=${DU_alias}
    Should Be Equal As Strings  ${res['status']}  success
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${DU_alias}


Activating vDU Delta Plan Operation Should Be Successful
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword check if status=success for activation of vCU delta plan. 
    ...     Will fail if status in response not success.
    ...
    ...     | delta_plan_id | id of delta plan           |
    ...     | operation_id  | Id of activation procedure |
    ...     | gnb_id        | Id of gnb                  |
    ...     | du_id         | Id of du                   |
    ...
    [Arguments]  ${delta_plan_id}    ${operation_id}    ${gnb_id}=0    ${du_id}=0
    ${DU_alias}   Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${res}   coam_vdu.get_activate_delta_plan_operation_status   ${delta_plan_id}  ${operation_id}   vdu_connection=${DU_alias}
    Log to Console    ${res}
    Should Be Equal As Strings  ${res['status']}  success
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${DU_alias}


Get gNB Physical Cell ID From AiC
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This TL specific keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value. It is recommended to use the dedicated
    ...     wrapper KW in the test suite `Get gNB Physical Cell ID`.
    ...
    ...     | gnb_id    | Id of gnb |
    ...     | du_id     | Id of du  |
    ...
    ...     *Returns*   a dictionary with key cell name and the respective physical cell id
    ...
    [Arguments]     ${gnb_id}=0  ${du_id}=0
    ${DU_alias}    Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${nrcell_objects}  aic_gnb.extract_physcellid_from_vdu     alias=${DU_alias}
    [Return]  ${nrcell_objects}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   ${DU_alias}
