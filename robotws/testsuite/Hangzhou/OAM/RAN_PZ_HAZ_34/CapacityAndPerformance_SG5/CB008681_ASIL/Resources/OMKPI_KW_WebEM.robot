*** Settings ***
Documentation      author: Zhang Xuewen
...                contact: xuewen.zhang@nokia-sbell.com
...                History:
...                This robot file is for CB008681 ASIL C&P


Resource       ../../../common/NetAct_swing.robot
Resource       L3_Call_Common_Keyword.robot
Library    taf.sbts.oam.coam.admin   WITH NAME   DU_Rest
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.nms.netact    WITH NAME    netact


*** Variables ***
#Configure the TL specific variable

${connection}   COAM
${global_bts_id}           ${tl.gnbs[0].global_bts_id}
${instance_id}              ${tl.gnbs[0].instance_id}
${DU_OAM}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}

####only for debug###########
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}


######## KeyWords for CB006443 #######
*** Keywords ***
#---------------------COAM basic operation (COAM_Admin_ indacates backend lib,COAM_WebEM_ indicates frontend lib.-------
COAM_Admin.Login
    [Arguments]   ${bts_host}=${WEBUI_IP}   ${username}=${WEBUI_USERNAME}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM

    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    ${BTSInfo}      coam.get_bts_info      connection=${alias}
    ${release}      String.Split String    ${BTSInfo['swInfo']['swVersion']}   _
    ${release}      set variable           ${release}[0]
    coam.teardown   connection=${alias}
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    ...   release=${release}

COAM_Admin.Logout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

COAM_Admin.GetBTSInfo
    [Arguments]   ${bts_host}=${WEBUI_IP}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    name=GNB_COAM
    ${BTSInfo}=    coam.get_bts_info    connection=GNB_COAM
    coam.teardown      connection=GNB_COAM
    [Return]   ${BTSInfo}

COAM_Admin.BackupSCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=60
    ${backupfile}=   Join Path   ${local_dir}   ${file_name}
    COAM_Admin.Logout
    [Return]  ${backupfile}

COAM_Admin.GetActiveSoftwareVersion
    [Arguments]   ${bts_host}=${WEBUI_IP}
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${bts_host}
    ${swVersion}    set variable    ${BTSInfo['swInfo']['swVersion']}
    [Return]        ${swVersion}

COAM_Admin.ResetSite
    [Arguments]  ${timeout}    ${connection}=COAM
    log to console    Start reseting gNB!
    coam.reset_site   timeout=${timeout}  connection=${connection}
    log to console    Finish reseting gNB!

COAM_Admin.VerifyCellOnAir
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    wait until keyword succeeds   3x   1min    COAM_Admin.CheckBTSOnAir
    COAM_Admin.Logout

COAM_Admin.CheckBTSOnAir
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${status}   Set Variable   ${bts_info['status']['proceduralState']}
    Should Contain   ${status}   OnAir

COAM_WebEM.ModifyParameters
    [Arguments]    ${DistName}=MRBTS-1907/NRBTS-7/NRCELL-1    ${FilterParam}=Timer t301    ${NewValue}=600ms
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}

    COAM_WebEM.ValidateAndActiveParameters

COAM_WebEM.GetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${distName}    filter_param=${abbr}
    [Return]       ${value}

COAM_WebEM.SetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name    ${value}=TL012    ${Abbreviation}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...   selenium_coam.set_parameter_value   dist_name=${distName}   filter_param=${abbr}   new_value=${value}
    ...   abbr=${Abbreviation}

COAM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

COAM_WebEM.Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${version}=SBTS21B
    UTE.CleanFirefox
    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    version=${version}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

COAM_WebEM.Logout
    [Arguments]     ${virtual_disable}=${TRUE}
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    selenium_coam.logout
    run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display

COAM_WebEM.VerifyCellOnAir
    [Arguments]    ${cell_idx}=ALL
    COAM_WebEM.VerifyAllCellsAreOnline    cell_idx=${cell_idx}

COAM_WebEM.VerifyAllCellsAreOnline
    [Documentation]   This kw is to check all cells are online in COAM
    [Arguments]     ${cell_idx}=ALL
    COAM_WebEM.Login
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${CellNum}
        ${Idx}    Evaluate     1+${i}
        run keyword if   '${cell_idx}'!='ALL' and '${cell_idx}'!='${Idx}'    Continue For Loop
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${Idx}
        log    ${cell_info} and ${cell_info['Status']['Availability status']}
        Should be equal as strings
        ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
#        ${res1}  Run Keyword And Return Status  Should be equal as strings
#        ...      ${cell_info['Status']['Availability status']}  Online    ignore_case=${True}
#        should be true  ${res} or ${res1}
    END
    COAM_WebEM.Logout

KW.CP_GetgNBType
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNBType}    Set Variable   ${BTSInfo['gNbCuType']}
    [Return]   ${gNBType}

##########Start commmon keyword for CB006443#############
Get SW release by ADMIN API
    [Arguments]   ${connection_AdminApi}=COAM   ${StreamVersion}=${StreamVersion}
    ...    ${Login_Flag}=${False}
    DU_Rest.connect_to
    ...    bts_host=${DU_OAM}    name=${connection_AdminApi}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    ${BTSInfo}      coam.get_bts_info      connection=${connection_AdminApi}
    Set Test Variable    ${BTSInfo}
    ${key1}    Check Parameter valid    Parameter=BTSInfo['swInfo']['swVersion']    default_value=${empty}
    ${key2}    Check Parameter valid    Parameter=BTSInfo['swInfo']['nrRatVersion']   default_value=${empty}
    ${key3}    Check Parameter valid    Parameter=BTSInfo['swInfo']['lteRatVersion']    default_value=${empty}
    @{release_tmp}    create list   ${EMPTY}
    ${release}    Run Keyword if    '${key1}'!='${empty}'
    ...    String.Split String    ${key1}   _
    ...    ELSE IF    '${key2}'!='${empty}'
    ...    String.Split String    ${key2}   _
    ...    ELSE IF    '${key3}'!='${empty}'
    ...    String.Split String    ${key3}   _
    ...    ELSE   Copy List    ${release_tmp}
    ${len}    Run Keyword And Ignore Error    Get Length     ${release}
    ${StreamVersion}      Run Keyword if    '${len[0]}'=='PASS' and '${Empty}' not in ${release}
    ...    set variable    ${release}[0]
    ...    ELSE    set variable    ${StreamVersion}
    Run Keyword if    '${Login_Flag}'=='True'    Connect to DU by ADMIN API
    ...    connection_AdminApi=${connection_AdminApi}    StreamVersion=${StreamVersion}
    [Return]   ${StreamVersion}
    [TearDown]    Run Keyword if    '${Login_Flag}'=='False'
    ...    Run Keyword And Ignore Error    DisConnect to DU by ADMIN API

Check Parameter valid
    [Arguments]    ${Parameter}    ${default_value}=None
    ${res}    run keyword and ignore error   log    ${${Parameter}}
    Run Keyword if    '${res[0]}'=='FAIL'   set suite variable    ${${Parameter}}    ${default_value}
    [Return]   ${${Parameter}}

Connect to DU by ADMIN API
    [Arguments]      ${connection_AdminApi}=${connection}    ${StreamVersion}=${StreamVersion}
    DU_Rest.connect_to
    ...    bts_host=${DU_OAM}    name=${connection_AdminApi}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    ...    release=${StreamVersion}
    [Return]   ${connection_AdminApi}

Get stream version
    [Documentation]  This is KW is just for SBTS
    [Arguments]      ${Stream_Master}=${KPI['Stream_Version']}
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}
    ${StreamVersion}    set variable if    '${ci_var_dict}[stream]'=='SBTS00'
    ...    ${Stream_Master}    ${ci_var_dict}[stream]
    log to console    Stream version is ${StreamVersion}
    [Return]   ${StreamVersion}

DisConnect to DU by ADMIN API
     [Arguments]      ${connection_AdminApi}=${connection}
     DU_Rest.teardown    connection=${connection_AdminApi}


DU_WebEM.Get alarm in DU
    [Documentation]  This KW is for get all activate alarm  and history alarm in DU
    [Arguments]    ${active_fault_list}=${Empty}    ${historic_fault_list}=${Empty}
    ...    ${ParameterInput}=True    ${check_history}=True

    ${active_fault_list}    Run Keyword If   '${ParameterInput}'=='False'
    ...    DU_Rest.get_active_alarms    connection=${connection}   timeout=20
    ...    ELSE IF    '${ParameterInput}'=='True'     Set Variable    ${active_fault_list}
    ${len}=    Get Length    ${active_fault_list}

    FOR    ${index}    IN RANGE    ${len}
        Keep In Dictionary    ${active_fault_list[${index}]}
        ...   faultId    configObjectName    btsObservationTime
    END
    @{historic_fault_list_0}    create list   ${empty}
    ${historic_fault_list_1}        Run Keyword If   '${ParameterInput}'=='False' and '${check_history}'=='True'
    ...    DU_Rest.get_historic_alarms    connection=${connection}   timeout=20
    ...    ELSE IF    '${ParameterInput}'=='True' and '${check_history}'=='True'
    ...    Set Variable    ${historic_fault_list}
    ...    ELSE IF    '${check_history}'=='False'    Set Variable    @{historic_fault_list_0}
    ${len1}=    Get Length    ${historic_fault_list_1}
    FOR    ${index}    IN RANGE    ${len1}
         Keep In Dictionary    ${historic_fault_list_1[${index}]}
         ...   faultId    configObjectName    eventTime
    END
    [Return]     ${active_fault_list}    ${historic_fault_list_1}

DU_WebEM.check alarm by string
    [Documentation]  This KW is for get all activate alarm  and history alarm in DU
    ...    parameter 'FaultFlag' can be set to 'Raised' or 'Cleared'
    [Arguments]       ${fault_id}=${49}    ${FaultFlag}=Raised
    ${active_fault_list}=    DU_Rest.get_active_alarms    connection=${connection}   timeout=20
    ${historic_fault_list}=    DU_Rest.get_historic_alarms    connection=${connection}   timeout=20
    ${active_fault_string}    Convert To String    ${active_fault_list}
    Run Keyword If   '${FaultFlag}'=='Raised'
    ...    Should Contain    ${active_fault_string}    'faultId':${Space}${fault_id}
    ...    ELSE IF    '${FaultFlag}'=='Cleared'
    ...    Should Not Contain    ${active_fault_string}    'faultId':${Space}${fault_id}

    [Return]   ${active_fault_list}     ${historic_fault_list}

DU_WebEM.Check alarm in DU
    [Documentation]  This KW is for check new alarm is reported after some operations
    [Arguments]       ${alarm1}    ${alarm2}
    ${len}=    Get Length    ${alarm1}
    ${len1}=    Get Length    ${alarm2}
    @{new_alarm_list}   Create List
    FOR    ${index}    IN RANGE    ${len1}
        Run Keyword If  ${alarm2[${index}]} not in @{alarm1}    Append To List    ${new_alarm_list}    ${alarm2[${index}]}
    END
    [Return]    @{new_alarm_list}

DU_WebEM.Validate alarm is raised or canceled in DU
    [Documentation]  This KW is for check new alarm is reported after some operations
    ...    alarm status have two values:raised,canceled
    [Arguments]    ${active_fault_list_0}    ${historic_fault_list_0}
    ...    ${active_fault_list}    ${historic_fault_list}    ${expected_alarm_index}    ${alarm_status}
    ...    ${check_history}=True
    ${new_faultid_list}    DU_WebEM.Check alarm in DU   alarm1=${active_fault_list_0}    alarm2=${active_fault_list}
    ${history_faultid_list}     Run keyword if    '${check_history}' == 'True'
    ...    DU_WebEM.Check alarm in DU   alarm1=${historic_fault_list_0}   alarm2=${historic_fault_list}
    ${len}=    Get Length    ${new_faultid_list}
    ${len1}    Run keyword if    '${check_history}' == 'True'   Get Length    ${history_faultid_list}
    Run keyword if    '${alarm_status}' == 'raised' and '${check_history}' == 'True'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${1}    AND
    ...    Should Be Equal    ${new_faultid_list[0]['faultId']}    ${expected_alarm_index}    AND
    ...    Should Be Equal    ${len1}  ${0}
    ...    ELSE IF    '${alarm_status}' == 'canceled' and '${check_history}' == 'True'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${0}    AND
    ...    Should Be Equal    ${len1}  ${1}    AND
    ...    Should Be Equal    ${history_faultid_list[0]['faultId']}    ${expected_alarm_index}
    ...    ELSE IF    '${alarm_status}' == 'raised' and '${check_history}' == 'False'
    ...    RUN KEYWORDS    Should Be Equal    ${len}  ${1}    AND
    ...    Should Be Equal    ${new_faultid_list[0]['faultId']}    ${expected_alarm_index}
    ...    ELSE IF    '${alarm_status}' == 'canceled' and '${check_history}' == 'False'
    ...    Should Be Equal    ${len}  ${0}

DU_WebEM.Get NR Cell distname and id
    [Arguments]    ${connection}=${connection}
    [Documentation]  This KW is for get cell distname and id list

    ${cell_info}=    DU_Rest.get_cells_info    cell_type=nr    timeout=30    connection=${connection}
    @{cell_id_list}    create list
    FOR    ${elem}    IN    @{cell_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${cell_id_list}   ${elem['id']}
        Set Suite Variable    ${cell_id_list}
    END

DU_WebEM.Check NR Cell status
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}    ${timeout}    ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    log to console  timeout:${timeout}
    ${cell_info}=    DU_Rest.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=${connection}
    Run keyword if   '${operational_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
    Run keyword if   '${procedural_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['proceduralStatus']}    ${procedural_Status}     ignore_case=true
    Run keyword if   '${availability_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['availabilityStatus']}    ${availability_Status}    ignore_case=true
    Run keyword if   '${blockingState}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
    Run keyword if   '${administrative_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['administrativeState']}    ${administrative_State}    ignore_case=true
    [Return]    PASS


DU_WebEM.Check all NR Cell status
    [Documentation]  This KW is for get and check all cell status
    [Arguments]    ${cell_id_list}    ${all_flag}    ${connection}=COAM    ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    log to console  procedural_Status:${procedural_Status}
    # log to console    check all cell status start
    @{check_status_list}    create list
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${cell_info}=    DU_Rest.get_cell_specific_info
        ...   cell_id=${cell_id['internal']}   timeout=30    connection=${connection}
		${status}    Run Keyword And Return Status    Should be equal    ${cell_info['status']['operationalState']}
		...    ${operational_State}    ignore_case=true
        Run keyword if    "${all_flag}" == "False"    Run Keywords    Append to list    ${check_status_list}    ${status}
        ...    AND           set test variable    ${check_status_list}
        Run keyword if    "${all_flag}" == "True" and '${operational_State}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${availability_Status}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['availabilityStatus']}
        ...    ${availability_Status}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${blockingState}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
        Run keyword if    "${all_flag}" == "True" and '${administrative_State}' != '${empty}'
        ...    Should be equal    ${cell_info['status']['administrativeState']}
        ...    ${administrative_State}    ignore_case=true
    END
	Run keyword if    "${all_flag}" == "False"      List Should Contain Value    ${check_status_list}    ${True}


DU_WebEM.LogIn and Check all NR Cell On Air
    [Arguments]    ${login_flag}=${True}    ${connection}=COAM    ${reset_flag}=${False}
    ...    ${wait_time}=20min
    Run keyword if    "${login_flag}"=="${True}"    Wait Until Keyword Succeeds    ${wait_time}    15s
    ...    Connect to DU by ADMIN API    connection_AdminApi=${connection}
    DU_WebEM.Get NR Cell distname and id      connection=${connection}
    ${cell_status}    RUN KEYWORD AND RETURN STATUS
    ...    Wait Until Keyword Succeeds    ${wait_time}    15s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True    connection=${connection}
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    run keyword if    '${cell_status}'=='${False}' and '${reset_flag}'=='${True}'    RUN KEYWORDS
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    taf.sbts.oam.coam.admin.reset_site     timeout=300
    ...    connection=${connection}    wait_for_reconnection=${True}
    ...    AND    RUN KEYWORD AND CONTINUE ON FAILURE    Wait Until Keyword Succeeds    ${wait_time}    15s
    ...    Connect to DU by ADMIN API    connection_AdminApi=${connection}
    ...    AND    Wait Until Keyword Succeeds    ${wait_time}    15s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked    connection=${connection}
    [Teardown]    Run keyword if    "${login_flag}" == "${True}"
    ...    run keyword and ignore error  DisConnect to DU by ADMIN API     connection_AdminApi=${connection}

Update or Create parameter by Admin API
    [Documentation]  This KW is for update one parameter
    [Arguments]       ${class_name}    ${parameter_Abbreviation}
	...    ${Expected_Value}    ${Dist_name}    ${Operation}=update    ${connection_AdminApi}=${connection}

	 ${out_parameters_list}     taf.sbts.oam.coam.admin.get_managed_objects
        ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
    ${parameter_value}    Get From Dictionary    ${out_parameter}    	${parameter_Abbreviation}
     run keyword if    '${parameter_value}'!='${Expected_Value}'
	 ...    taf.sbts.oam.coam.admin.perform_parameter_recommissioning   dist_name=${Dist_name}
	 ...    parameter=${parameter_Abbreviation}    operation=${Operation}    value=${Expected_Value}
     ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=True
    [Return]    ${parameter_value}

Update or Create parameter based on NIDD
    [Documentation]  This KW is for update one parameter,will spend more time,
    ...    but if there is new parameter added, it will work
    [Arguments]    ${class_name}    ${filelocation}
	...    ${Expected_Value}    ${Dist_name}    ${MOCName}   ${exception_list}
	...    ${sheet_name}=Parameters    ${connection_AdminApi}=${connection}
	...    ${filter}=MNL-productVariantPlanned==5gClassicalBTS, then this parameter MUST NOT be configured

	${parameter_list}=    read_pm_parameter_from_nidd   filelocation=${filelocation}
    ...    sheet=${sheet_name}    MOCName=${MOCName}    filter=${filter}     exception_list=@{exception_list}
	${out_parameters}     taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter_list}    Get From Dictionary    ${out_parameters[0]}    parameters
	${len}    get length    ${parameter_list}
	FOR    ${i}    IN RANGE    ${len}
         ${parameter_value}    Get From Dictionary    ${out_parameter_list}   	${parameter_list[${i}]}
         run keyword if    '${parameter_value}' != '${Expected_Value}' and '${parameter_value}' != '${empty}'
	 ...    Run Keyword And Ignore error    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
	 ...    dist_name=${Dist_name}   parameter=${parameter_list[${i}]}   operation=update    value=${Expected_Value}
     ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=True
         run keyword if    '${parameter_value}' == '${empty}'
	 ...    Run Keyword And Ignore error    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
	 ...    dist_name=${Dist_name}   parameter=${parameter_list[${i}]}     operation=create   value=${Expected_Value}
     ...   connection=${connection_AdminApi}    skip_parameter_relation_errors=True
    END

Update or Create Object based on NIDD
    [Arguments]    ${class_name}    ${filelocation}
	           ...    ${Expected_Value}    ${Dist_name}    ${MOCName}   ${exception_list}
	           ...    ${sheet_name}=Parameters    ${connection_AdminApi}=${connection}
	           ...    ${filter}=MNL-productVariantPlanned==5gClassicalBTS, then this parameter MUST NOT be configured
	${parameter_list}=    read_pm_parameter_from_nidd   filelocation=${filelocation}
    ...    sheet=${sheet_name}    MOCName=${MOCName}    filter=${filter}     exception_list=@{exception_list}
	${out_parameters}     taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}    connection=${connection_AdminApi}
    ${out_parameter_list}    Get From Dictionary    ${out_parameters[0]}    parameters
	${len}    get length    ${parameter_list}
    @{MO_parameter_list}     Create List
	FOR    ${i}    IN RANGE    ${len}
        ${parameter_value}    Get From Dictionary    ${out_parameter_list}   	${parameter_list[${i}]}
        ${param_dict}    run keyword if
     ...    '${parameter_value}' != '${Expected_Value}' and '${parameter_value}' != '${empty}'
	 ...    Create Dictionary    parameterName=${parameter_list[${i}]}  value=${Expected_Value}    operation=update
     ...    ELSE IF    '${parameter_value}' == '${empty}'
	 ...    Create Dictionary    parameterName=${parameter_list[${i}]}  value=${Expected_Value}    operation=create
	    ${res1}    Run Keyword And Return Status    Dictionary Should Contain Key    ${param_dict}    parameterName
         run keyword if    '${res1}'!='False'    Append to list   ${MO_parameter_list}    ${param_dict}
         # ${MO_parameter_list}    set variable    ${MO_parameter_list}
    END
    ${len}    get length   ${MO_parameter_list}
    run keyword if    '${len}'!='${0}'    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${Dist_name}
    ...    parameter=${MO_parameter_list}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection_AdminApi}

##########End commmon keyword for CB006443#############

##########Start keyword for CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration#############
DU_WebEM.Get BBMOD distname and id
    [Documentation]  This KW is for get BBMOD distname and id list
    ${BBMOD_info}=    DU_Rest.get_fbb_info    timeout=30    connection=${connection}
    @{BBMOD_id_list}    create list
    FOR    ${elem}    IN    @{BBMOD_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${BBMOD_id_list}   ${elem['id']}
        Set Suite Variable    ${BBMOD_id_list}
    END

DU_WebEM.reset BBMOD
    [Documentation]  This KW is for checking service downtime of reseting BBMOD
    [Arguments]    ${BBMOD_id}    ${connection}=COAM
    ...    ${KPI5_MAX}=${1}
    # Timer.Start
    wait until keyword succeeds   5min   3s    DU_Rest.reset_unit
    ...    dist_name=${BBMOD_id['internal']}    reset_type=Warm   timeout=300    connection=${connection}

    Wait Until Keyword Succeeds    10min    60s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    Sleep    10s
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI5}    TimeEndString=${kEY_TIMEEND_KPI5}
    ...    select_start=head    select_end=tail

    ${reset_status}=    set variable if  ${0}<${duration_time_tmp}<${KPI5_MAX}     PASS     FAIL
    [Return]   ${reset_status}   ${duration_time_tmp}
##########End keyword for CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration#############

##########Start keyword for CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time#############
PB.Power on or off one RU
    [Documentation]  This is KW is for power on or off one RU by RU index
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${model}=FACOM
     ...    ${KPI54A_MAX}=${1}
     PB.PowerOnOff     pdu_ip=${pdu_ip}    Port_Number=${Port_Number}    Action=power_off    model=${model}
	 RUN KEYWORD AND CONTINUE ON FAILURE
	    ...    Wait Until Keyword Succeeds    8min    5s     DU_WebEM.Check all NR Cell status
        ...    cell_id_list=${cell_id_list}     all_flag=False
        ...    operational_State=Disabled    procedural_Status=not initialized
        ...    blockingState=Unblocked    administrative_State=Unlocked
    ${timestartTmp}    KW.TimerStart
	PB.PowerOnOff     pdu_ip=${pdu_ip}    Port_Number=${Port_Number}    Action=power_on    model=${model}
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait Until Keyword Succeeds    8min    20s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
     ${duration_1}     KW.TimerStop    timestart=${timestartTmp}
     should be true    ${0}<${duration_1}<${KPI54A_MAX}
     [Return]   ${duration_1}

PB.PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off    ${model}=HBTE
    taf.pdu.Setup Pdu       host=${pdu_ip}    model=${model}
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='power_on'    taf.pdu.power_on    port=${Port_Number}
    ...    ELSE IF   '${Action}'=='both'    Run Keywords    taf.pdu.power_off    port=${Port_Number}    AND    sleep    10s
    ...    AND    taf.pdu.power_on    port=${Port_Number}

##########End keyword for CB006443_HA_04_OAM_KPI_54a_RU_cold_Reset_Time#############

##########Start keyword for CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time#############
DU_WebEM.Get RMOD ID
    [Documentation]  This KW is for get RMOD distname and id list
    ${RMOD_info}=    DU_Rest.get_frm    timeout=30    connection=${connection}
    @{RMOD_id_list}    create list
    FOR    ${elem}    IN    @{RMOD_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${RMOD_id_list}   ${elem['id']}
        Set Suite Variable    ${RMOD_id_list}
    END

DU_WebEM.Get RMOD NAME
    wait until keyword succeeds     8min   3s     connect to DU by ADMIN API
    ${RMOD_info}=    DU_Rest.get_frm    timeout=30    connection=${connection}
    @{RMOD_name_list}    create list
    @{RMOD_id_list}    create list
    &{RMODs_dict}  create dictionary
    FOR    ${elem}    IN    @{RMOD_info}
        Append to list    ${RMOD_name_list}   ${elem['productName']}
        Append to list    ${RMOD_id_list}   ${elem['id']}
        set to dictionary    ${RMODs_dict}   ${elem['id']['configuration']}=${elem['productName']}
    END
    Set Suite Variable    ${RMODs_dict}
    Set Suite Variable    ${RMOD_id_list}
    Set Suite Variable    ${RMOD_name_list}
    [Return]   ${RMOD_name_list}


DU_WebEM.loop reset all RMOD
   [Arguments]    ${RMOD_id_list}    ${connection}=COAM
   ...    ${reset_times}=${1}    ${KPI51_MAX}=${1}     ${KPI51_AVG}=${1}
   ...    ${Login_Flag}=${True}   ${Check_Call}=${False}    ${call_loop}=${2}
   ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
   ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
   ...    ${duration_ul}=300    ${duration_dl}=300
   log to console  reset_times:${reset_times}
   log to console  KPI51_AVG:${KPI51_AVG}
   log to console  Login_Flag:${Login_Flag}
   log to console  call_loop:${call_loop}
   @{result_list}    create list
   FOR    ${RMOD}    IN    @{RMOD_id_list}
        ${res}     RUN KEYWORD AND CONTINUE ON FAILURE     DU_WebEM.reset one RMOD    loop=${1}
        ...    RMOD_id=${RMOD}     connection=${connection}     Login_Flag=${True}        KPI51_MAX=${KPI51_MAX}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
        KW.CaseStatusCaluate    duration=${duration_time_tmp}
        ...    max=${KPI51_MAX}
        ${RMOD_name}=	   Get From Dictionary   	${RMODs_dict}	   ${RMOD_id_list[0]['configuration']}
        log to console     [${RMOD_name}]RU reset loop:${1} duration:${duration_time_tmp} result:${reset_status}
        #Get common info     case_result=${reset_status}    case_name=rf_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
       ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot

        Run Keyword If    '${reset_status}'=='pass' and '${Check_Call}'=='${True}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=2
   END

DU_WebEM.loop reset one RMOD
    [Arguments]       ${RMOD_id}    ${connection}=COAM    ${retry_times}=1
    ...    ${KPI51_MAX}=${1}    ${KPI51_AVG}=${1}
    ...    ${Login_Flag}=${True}     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    @{result_list}    create list
    FOR    ${i}    IN RANGE    1    ${retry_times}
        ${res}     RUN KEYWORD AND CONTINUE ON FAILURE     DU_WebEM.reset one RMOD    loop=${i+1}
        ...    RMOD_id=${RMOD_id}     connection=${connection}     Login_Flag=${Login_Flag}        KPI51_MAX=${KPI51_MAX}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
        KW.CaseStatusCaluate    duration=${duration_time_tmp}
        ...    max=${KPI51_MAX}
        ${loop_counter}    set variable if    ${retry_times}==1      1    ${loop_counter+1}
        ${RMOD_name}=	   Get From Dictionary   	${RMODs_dict}	   ${RMOD_id['configuration']}
        log to console     [${RMOD_name}]RU reset loop:${loop_counter} duration:${duration_time_tmp} result:${reset_status}
        #Get common info     case_result=${reset_status}    case_name=rf_reset   loop_number=${i+1}  duration_time=${duration_time_tmp}
       ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${reset_status}'=='pass' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=2
    END
    KW.CaseStatusFinnal    case_avg=${KPI51_AVG}    max_loop=${retry_times}


DU_WebEM.reset one RMOD
    [Arguments]    ${loop}    ${RMOD_id}    ${connection}=COAM    ${Login_Flag}=${True}
    ...    ${KPI51_MAX}=${1}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Run Keyword if    '${Login_Flag}'=='True'    Connect to DU by ADMIN API
    ...    connection_AdminApi=${connection}   StreamVersion=${StreamVersion}
    #${timestartTmp}   Get Current Date
    ${reset_RF}     Run Keyword And Return Status
    ...    wait until keyword succeeds   1min   3s    DU_Rest.reset_unit
    ...    dist_name=${RMOD_id['internal']}    timeout=300    connection=${connection}
    ${reset_status_Tmp}     Run Keyword If   '${reset_RF}'=='True'
    ...    Run Keyword And Return Status     Check all cells Should Be On Air
    ...    ELSE    set variable    False
    #${timestart}      convert date    ${timestartTmp}    epoch
    #${timeendTmp}     Get Current Date
    #${timeend}        convert date    ${timeendTmp}     epoch
    #${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${duration_time_tmp}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI51a}
    ...    TimeEndString=${kEY_TIMEEND_KPI51a}    select_start=head    select_end=tail
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<${KPI51_MAX}   pass      fail
    ${RMOD_name}=	   Get From Dictionary   	${RMODs_dict}	   ${RMOD_id_list[0]['configuration']}
     Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${RMOD_name}_${loop}
    [Return]    ${reset_status}   ${duration_time_tmp}
    [TearDown]    Run Keyword if    '${Login_Flag}'=='True'
    ...    Run Keyword And Ignore Error    DisConnect to DU by ADMIN API    connection_AdminApi=${connection}

#########KW for FA_02############
Check exist session
	@{EM_session_list}    create list
	${sessionlist_EM}    DU_Rest.check_link_status    connection=${connection}
	FOR    ${element}    IN    @{sessionlist_EM}
	    Run keyword if     '${element['stateInfo']['usageState']}'=='Active' and '${element['type']}'=='EM'
     ...    Append to list   ${EM_session_list}    ${element}
    END
    ${session_number}    get length    ${EM_session_list}
    log to console    The number of existed session in DU is ${session_number}
	[Return]    ${session_number}


#######Check call######
Verify UE send full UDP UL data and full UDP DL data
    [Arguments]    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
	...   ${throuthput_dl}=600M    ${protocol}=udp    ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
	...   ${duration_ul}=300    ${duration_dl}=300
    L3 call start    ue_index=${ue_index}
    Start Capture wireshark log
	power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput= ${throuthput_ul}    duration=${duration_ul}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
	power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${throuthput_dl}    duration=${duration_dl}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
    sleep   10s
	Check none release
	${res}    Run Keyword And Return Status
	...    Run keyword and continue on failure    check ul and dl throughput of one cell
	...    ultp=${exepected_ul_tp}     ul_throughput=${0}
	...    dltp=${exepected_dl_tp}    NR_cell_id=${NR_cell_id}    dl_throughput=${0}
	${snapshot_file}    Run Keyword If    '${res}'=='${False}'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
   [Teardown]    RUN KEYWORDS
   ...    run keyword and ignore error    power_ue.Stop traffic
   ...    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_type=via_command
   ...    AND     run keyword and ignore error    power_ue.Stop traffic
   ...    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_type=via_command
   ...    AND     run keyword and ignore error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}


check ul and dl throughput of one cell
    [Arguments]    ${ultp}=${100}    ${dltp}=${500}    ${NR_cell_id}=${15024129}    ${ul_throughput}=${0}
    ...    ${dl_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_ul.txt
    ${ul_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate UL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${NR_cell_id}
    ${ul_throughput}=    Evaluate    ${ul_throughput}+${ul_throughput_tmp}
    Log to console    ul_throughput = ${ul_throughput}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_dl.txt
    ${dl_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate DL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${NR_cell_id}
    ${dl_throughput}=    Evaluate    ${dl_throughput}+${dl_throughput_tmp}
    Log to console    dl_throughput = ${dl_throughput}
    Run keyword and continue on failure    should be true    ${ul_throughput} > ${ultp}
    Run keyword and continue on failure    should be true    ${dl_throughput} > ${dltp}

Do site reset to recovery gnb
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    Run Keyword And Ignore Error     Check all cells Should Be On Air
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore Error    COAM_WebEM.Logout
