*** Settings ***

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB008379/resources/common/common_setup_teardown.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          String
Library             ../resources/python/CPRT_Capture.py
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource        ../resources/robot/wts_sim_keywords.robot
Resource        ../resources/robot/common_log_collection.robot
Library           json
Library             utils.py

*** Variables ***
${mrbts_id}     1
${dist_name}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
${BBMOD_Runtime}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1

***Keywords***
Get Diagnostic Snapshot Destination
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}    
    ${diagSnapDestination}    get from dictionary    ${json_repr}    diagSnapDestination
    [Return]  ${diagSnapDestination}
    [Teardown]  vDU Rest Logout

Activate_L1_IQ_capture
    ${cellid}       Set Variable        0
    ${eventcapture}     Set Variable     True
    ${subcelldict}      Create Dictionary       nrCellId=${1}        subCellId=${${cellid}}
    ${subcelllist0}     Create List     ${subcelldict}
    VDU Rest Login
    ${operationid}    activate_l1_iq_data_configuration	capture_on_event=${${eventcapture}}
    ... 	dl_nr_subcell_list=${subcelllist0} 			ul_nr_subcell_list=${subcelllist0}      buffer_cycle=1024_FRAMES
    Wait Until Keyword succeeds     1min   10sec       Verify l1 iq capture started        ${operationid}
    [Teardown]  vDU Rest Logout

Verify l1 iq capture started
    [Arguments]     ${operationid}
    ${status}       get_operation_status_of_activating_l1_iq_data_configuration   operation_id=${operationid}
    Dictionary Should Contain Value     ${status}       success

Update Snapshot Configuration of LSS
    Log To Console   \nUpdate Snapshot Configuration of LSS
    ${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${lssConfig}    create dictionary    lssIPaddress=192.168.255.126     lssPortNo=22
    ${payload}    run keyword if    '${diagSnapDestination}'=='lss'    create dictionary    lssConfig=${lssConfig} 
    ...    ELSE    create dictionary    diagSnapDestination=lss    lssConfig=${lssConfig}
    ${payload}    json.dumps    ${payload}
    Operate Fast Activation and Check Status    payload=${payload}    operation=update    operation_status=success

Update parameter for rlf
    ${rlfthreshold}    create dictionary    rlpDetCsiBsiThreshold=1     actGnbInitRlf=true
    ${payload}    json.dumps    ${rlfthreshold}
    Operate Fast Activation and Check Status    payload=${payload}    operation=update    operation_status=success

Add Lss account
#    ${ssh_passwd}       Find Value from testline environment variable   CM_PASSWORD
#    Log To Console      ${tl.test_pc.default_ssh_connection_details.username}
    ${newusername}      Set Variable        ute3
    ${newpass}          Set Variable        Ute@12345
    Run     sudo useradd ${newusername}
    Run     echo '${newusername}:${newpass}' | sudo chpasswd
    Run     sudo mkhomedir_helper ${newusername}
    VDU Rest Login
    ${status}	vdu.account_users_lss	username=${newusername}
	...	password=${newpass}
    Should Contain  ${status}[content]  Success
    [Teardown]  vDU Rest Logout
    
Add Trigger Fault
    [Arguments]     ${faultnum}
    ${alarm_dict}    create dictionary    faultNumber=${faultnum}    triggerType=onFaultDetection
    ${faultSnapshotTriggers}    create list    ${alarm_dict}
    ${payload}    create dictionary    faultSnapshotTriggers    ${faultSnapshotTriggers}
    ${payload}    json.dumps    ${payload}
    Operate Fast Activation and Check Status    payload=${payload}    operation=update    operation_status=success
    ${alarm_dict_string}    convert to string    ${alarm_dict}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${faultSnapshotTriggers_string}    convert to string    ${faultSnapshotTriggers}
    should contain    ${faultSnapshotTriggers_string}   ${faultnum}

Get Snapshot Fault list
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${status}    run keyword and return status    dictionary should contain key    ${json_repr}    faultSnapshotTriggers
    ${faultSnapshotTriggers}    run keyword if    ${status}    get from dictionary    ${json_repr}    faultSnapshotTriggers
    ...    ELSE    create list
    [Return]  ${faultSnapshotTriggers}
    [Teardown]  vDU Rest Logout

Operate Fast Activation and Check Status
    [Arguments]  ${payload}    ${operation}=update    ${operation_status}=success
    VDU Rest Login
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${feedback}    vdu.fast_activations_for_delta_plan    class_name=TRBLCADM    dist_name=${distname}
    ...    operation=${operation}    payload=${payload}
     wait until keyword succeeds    3min    10sec    Check Fast Activation Status    operation_id=${feedback['id']}
    ...    operation_status=${operation_status}
    [Teardown]  vDU Rest Logout

Check Fast Activation Status
    [Arguments]  ${operation_id}    ${operation_status}=success
    ${status}    vdu.get_fast_activation_operation_of_delta_plan    operation_id=${operation_id}
    should be true    '${status['status'].lower()}'=='${operation_status}'

Update RAD Debug Parameter
    [Arguments]    ${scenario}         ${subcellId}=0
    VDU Rest Login
    &{para_dict1}=   Create Dictionary    name=rdAbnormalEventTriggerOnlineEnable    value=1
    &{para_dict2}=   Create Dictionary    name=rdAbnormalEventTriggerNumber    value=3
    &{para_dict3}=   Create Dictionary    name=rdAbnormalEventTriggerSubcellIdForIqCapture    value=${subcellId}
    ${para_dict4}   Run Keyword If  '${scenario}'=='rlf'    Create Dictionary    name=rdAbnormalEventRlfEnabled     
    ...     value=1       ELSE      Create Dictionary       name=rdAbnormalEventRachFailureEnabled      value=1
    @{para_list}    Create List    ${para_dict1}    ${para_dict2}    ${para_dict3}      ${para_dict4}
    ${update_params}    vdu.update_rad_debug_params    persistency=oneReset   domain_name=L2PS    parameters=${para_list}
    sleep  15s
    ${current_update_operation}    vdu.get_rad_debug_params_update_operation    operation_id=${update_params['operation_id']}
    ${rad_debug_params}    vdu.get_rad_debug_params_summary
    Should Be Equal    '${rad_debug_params}'   'True'
    [Teardown]  vDU Rest Logout

Update RAD Debug Parameter Antenna snapshot
    [Arguments]    ${subcellId}=0
    VDU Rest Login
    &{para_dict1}=   Create Dictionary    name=rdAbnormalEventTriggerOnlineEnable    value=1
    &{para_dict2}=   Create Dictionary    name=rdRlcFastAntennaSnapshotThreshold     value=2000
    &{para_dict3}=   Create Dictionary    name=rdAbnormalEventTriggerSubcellIdForIqCapture    value=${subcellId}
    @{para_list}    Create List    ${para_dict1}    ${para_dict3}
    ${update_params}    vdu.update_rad_debug_params    persistency=oneReset   domain_name=L2PS    parameters=${para_list}
    sleep  15s
    ${current_update_operation}    vdu.get_rad_debug_params_update_operation    operation_id=${update_params['operation_id']}
    @{para_list}    Create List     ${para_dict2}
    ${update_params}    vdu.update_rad_debug_params    persistency=oneReset   domain_name=L2HIDU    parameters=${para_list}
    sleep  15s
    ${current_update_operation}    vdu.get_rad_debug_params_update_operation    operation_id=${update_params['operation_id']}
    ${rad_debug_params}    vdu.get_rad_debug_params_summary
    Should Be Equal    '${rad_debug_params}'   'True'
    [Teardown]  vDU Rest Logout

Trigger corrupt data
    ${mac_testmode}     Set Variable    mac_testmode_nr profile_id=2 delete=off ul_custom_tbs=0414800BB88001F5FFFFFFFFFFFFFFFFFFFFFFFFFFFF
    ${ue_testmode}      Set Variable    ue_testmode_set_nr id=1 testmode=mac action=activate profile_id=2
    ute_wtssim.Execute Egate Command    ${mac_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}

############# classical keywords ####
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

COAM Set RAD Param
    [Arguments]    ${domain}   ${name}    ${value}   ${persistency}=NotPersistent   ${connection}=COAM   ${timeout}=600
    set_rad_debug_parameters    domain=${domain}    name=${name}    value=${value}    persistency=${persistency}
    ...   connection=${connection}   timeout=${timeout} 

Configure Uplane L1 Iq Data For 5G
    [Documentation]  Parameter module_dn must be a Runtime DN of BBMOD or SMOD DN that support embeded BBMOD
    ...              one of dlNrSubcellList|ulNrSubcellList| dlLteCellList|ulLteCellList must be configured, maxItems is 2
    ...    Example request:     "moduleDN":"/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
    ...                         "dlNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-1","subcellId":1}],
    ...                         "ulNrSubcellList": [{"nrcell_rDN": "/NRCELL_R-2","subcellId":2}],
    ...                         "dlLteCellList": [1],
    ...                         "ulLteCellList": [1],
    ...                         "captureOnEvent": true
    [Arguments]  ${module_dn}=${BBMOD_Runtime}    ${subcell_id}=0
    ...    ${captureOnEvent}=${true}        ${connection}=${connection}
    connect to gnb coam via ssl    connection=${connection}
    ${dlNrSubcellList}  Create List    [{"nrcell_rDN": "/NRCELL_R-1","subcellId":0}]
    ${ulNrSubcellList}  Create List    [{"nrcell_rDN": "/NRCELL_R-1","subcellId":0}]
    admin.configure_uplane_l1_iq_data    module_dn=${module_dn}
    ...                                      dl_nr_subcell_list=${dlNrSubcellList}
    ...                                      ul_nr_subcell_list=${ulNrSubcellList}
    ...                                      capture_on_event=${captureOnEvent}
    ...                                      connection=${connection}
    Log To Console      ${subcell_id}
    [Teardown]     run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Update_rad_parameter_for_rach_failure
    connect to gnb coam via ssl    connection=${connection}
    COAM Set RAD Param   domain=L2PS   name=rdAbnormalEventTriggerOnlineEnable    value=1
    COAM Set RAD Param   domain=L2PS   name=rdAbnormalEventRachFailureEnabled    value=1
    COAM Set RAD Param   domain=L2PS   name=rdAbnormalEventRlfEnabled   value=1
    COAM Set RAD Param   domain=L2PS   name=rdAbnormalEventTriggerSubcellIdForIqCapture    value=0
    COAM Set RAD Param   domain=L2PS   name=rdAbnormalEventTriggerNumber    value=3
    [Teardown]     run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Configure Lss account classical
    Log To Console  ${tl.test_pc.default_ssh_connection_details.addr}, ${tl.test_pc.default_ssh_connection_details.username}
    Log To Console  ${tl.test_pc.default_ssh_connection_details.password}
    ${ssh_passwd}       Find Value from testline environment variable   CM_PASSWORD
    connect to gnb coam via ssl    connection=GNB_OAM
    configure_lss_account    ${tl.test_pc.default_ssh_connection_details.username}    ${ssh_passwd}    connection=GNB_OAM
    [Teardown]     run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM


Connect to gnb coam via ssl
    [Arguments]  ${connection}=default    ${gnb_index}=0
    ...    ${bts_host}=10.68.126.153
    ...    ${username}=ute
    ...    ${password}=ute
    ...    ${ignore_get_release_error}=${True}

    admin.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}
    Log To Console     ${gnb_index},${ignore_get_release_error} 

COAM Teardown gnb connections
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=${connection}

Introduce_msg3_rach_failure
	${cont_testmode}		Set Variable		cont_res_testmode_nr profile_id=1 missed_ra_resp=15
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=1 testmode=contention_resolution action=activate profile_id=1
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}

Trigger RLF Command
    ${rlf_testmode}     Set Variable    rlf_testmode_nr profile_id=1 num_stop_csi_report=15
    ${ue_testmode}      Set Variable    ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=1
    ute_wtssim.Execute Egate Command    ${rlf_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=${EGATE_COMMAND_TIMEOUT}

Register UE
	[Arguments]    ${ue_id}
	${ue_reg_cmd}   SET VARIABLE        ue_register id=${ue_id}
	${reg_output}	ute_wtssim.Execute Egate Command And Wait For Data    ${ue_reg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}     pass_regexp=detached
	[Return]	${reg_output}

Register UE and verify Rach failure
    ${reg_output}   Register UE     1
	Should Contain		${reg_output}	    T300 expiration

Verify snapshot file is generated
	${output}	Run		sudo ls -lrt /home/ute3/ | grep -i "Snapshot"
	Should not be empty		${output}
    ${output}   Run     sudo find /home/ute3/Snapshot* -name snapshot_file_list.txt
    Should not be empty     ${output}

Clear snapshot in home directory
    ${output}	Run		sudo rm -rf /home/ute3/Snapshot*
    ${output}	Run		sudo ls -lrt /home/ute3/ | grep -i "Snapshot"

Verify Iq snapshot is collected
    ${snappath}     Set Variable        /home/ute3/SnapshotVerify
    Run     sudo cp -r /home/ute3/Snapshot* ${snappath}
    Run     sudo chmod -R 777 ${snappath}
    ${snapshot_content}   parse_snapshot_file_list    ${snappath}
    #Should contain Match    ${snapshot_content}      glob=*ContIqSnapshotBuffer*
    ${value}    Get Dictionary Values    ${snapshot_content}
    ${value}    Convert to string   ${value}
    ${verifyiq}    Get Lines Containing String    ${value}      ContIqSnapshotBuffer
    Should Not Be Empty     ${verifyiq}
    ${zipfile}      Get Dictionary Keys     ${snapshot_content}
    FOR     ${i}    IN  @{zipfile}
    ${zipcontent}    Run     unzip -l ${snappath}/${i} | grep -i _ContIqSnapshotBuffer
    ${filesize}    Run Keyword If      '${zipcontent}' != '${EMPTY}'       Run
    ...     unzip -l ${snappath}/${i} | grep -i _ContIqSnapshotBuffer | awk '{print$1}'
    Should Not Be Equal     ${filesize}     0
    END

Find Value from testline environment variable
	[Arguments]		${name}
	${path}		Run			find /home/ute/testline_init_results/execution/logs -name env_variables.txt
	${value}	Run			cat ${path} | grep -i ${name} | awk -F "=" '{print $2}'
	[Return]	${value}
