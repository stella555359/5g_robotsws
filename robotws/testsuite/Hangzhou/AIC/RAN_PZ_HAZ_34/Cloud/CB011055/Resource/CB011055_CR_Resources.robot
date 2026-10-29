*** Settings ***
Documentation     author:Wang Bin
...               Group: HGZ_SG1
...               contact: bin.3.wang@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process
Library        SeleniumLibrary
Library        SSHLibrary
Library        taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library        taf.gnb.oam.coam.cu    WITH NAME    coam_vcu
Library        taf.gnb.oam.coam.vdu    WITH NAME    coam_vdu

*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

@{du_id}     1
##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.General_SiSo_Cell_block_and_unblock
    [Documentation]   Block and unblock NR cells,then check L3 call OK or NOK
    [Arguments]  ${cell_id}=${CASE_INPUT_CB011055['cell_id']}
    log to console    Start block and unblock cell for AQQQ
    Run Keyword And Continue On Failure    KW.block cell    ${cell_id}
    sleep    30s
    Run Keyword And Continue On Failure     KW.unblock cell    ${cell_id}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    log to console    Start check l3call after block and unblock cell
    Run Keyword And Continue On Failure    MultiUE.L3Call    UECFG=${CASE_INPUT_CB011055['MultiUECFG1']}


TC.Manual_SiSo_CM_Recommissioning
    [Documentation]   Modify diff parameters,then check cell status,l3call
    [Arguments]  ${Online_delta.json}=${CFGFILE_PATH}Online_delta.json
            ...  ${ObjectLocking_delta.json}=${CFGFILE_PATH}ObjectLocking_delta.json
            ...  ${SiteReset_delta.json}=${CFGFILE_PATH}SiteReset_delta.json
            ...  ${DU_host}=${CASE_INPUT_CB011055['CB011055']['vDU_host']}
    log to console    Modify online parameter t304
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    wait until keyword succeeds    3min    1min    coam_vdu.perform_delta_recommissioning
    ...                            delta_file=${Online_delta.json}
    run keyword and ignore error  coam_vdu.disconnect
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    log to console    Modify object locking parameter pMax
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}   port=443    username=Nemuadmin    password=Nokia@123    secure=true
    wait until keyword succeeds    3min    1min    coam_vdu.perform_delta_recommissioning
    ...                            delta_file=${ObjectLocking_delta.json}
    run keyword and ignore error  coam_vdu.disconnect
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    log to console    Modify site reset needed parameter chBw
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    wait until keyword succeeds    3min    1min    coam_vdu.perform_delta_recommissioning
    ...                            delta_file=${SiteReset_delta.json}
    run keyword and ignore error   coam_vdu.disconnect
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Continue On Failure    MultiUE.L3Call      UECFG=${CASE_INPUT_CB011055['MultiUECFG2']}

TC.General_SiSo_Auto_Cloud_PM_5G_uDTX
    [Documentation]   compare power consumption between uDTX enable and uDTX disable
    [Arguments]  ${mo_dn}=${CASE_INPUT_CB011055['CM']['mo_dn4']}
            ...  ${updated_paras_list}=${CASE_INPUT_CB011055['CM']['updated_paras_list4']}
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    log to console    enable ssh via vDU WebEM
    Run Keyword And Continue On Failure    Change The Password Of Serviceuser Account Via Webem
    Run Keyword And Continue On Failure    Active SSH Access and Port for RUs
    log to console    Start Check power with actMicroDTX=true
    log to console    Check power of RMOD-1
    wait until keyword succeeds     2min    30s     Login to RUs via SSH
    ...          host=10.0.179.42
    ...          port=51201
    ...          username=serviceuser
    ...          password=Nokia@123
    ${power1_with_uDTX}=    Run Keyword And Continue On Failure    Get power from RU via FRMON command
    Run Keyword And Continue On Failure    Logout RU
    log to console    Check power of RMOD-2
    wait until keyword succeeds     2min    30s     Login to RUs via SSH
    ...          host=10.0.179.42
    ...          port=51202
    ...          username=serviceuser
    ...          password=Nokia@123
    ${power2_with_uDTX}=    Run Keyword And Continue On Failure    Get power from RU via FRMON command
    Run Keyword And Continue On Failure    Logout RU
    log to console    Start Check power with actMicroDTX=false
    wait until keyword succeeds     15min    30s     vdu rest login
    Run Keyword And Continue On Failure    VDU Online Modify Parameters By Delta Plan REST
        ...  mo_dn=${mo_dn}
        ...  updated_paras_list=${updated_paras_list}
    log to console    Check power of RMOD-1
    wait until keyword succeeds     2min    30s     Login to RUs via SSH
    ...          host=10.0.179.42
    ...          port=51201
    ...          username=serviceuser
    ...          password=Nokia@123
    ${power1_without_uDTX}=    Run Keyword And Continue On Failure    Get power from RU via FRMON command
    Run Keyword And Continue On Failure    Logout RU
    log to console    Check power of RMOD-2
    wait until keyword succeeds     2min    30s     Login to RUs via SSH
    ...          host=10.0.179.42
    ...          port=51202
    ...          username=serviceuser
    ...          password=Nokia@123
    ${power2_without_uDTX}=    Run Keyword And Continue On Failure    Get power from RU via FRMON command
    Run Keyword And Continue On Failure    Logout RU
    Run Keywords    Should be true     ${power1_with_uDTX}/${power1_without_uDTX} < 0.9    AND
    ...             Should be true     ${power2_with_uDTX}/${power2_without_uDTX} < 0.9

TC.Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]   Reset vDU
    [Arguments]  ${loop_times}=${CASE_INPUT_CB011055['vDU_reset']['loop_times']}
            ...  ${duration_target}=${CASE_INPUT_CB011055['vDU_reset']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    vDU Rest Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to  Reset  vDU loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   5s    vdu.reset_vdu
        Sleep  180s
        log to console    check cell status should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell status should be  enabled for cu...
        wait until keyword succeeds     10min    5s    Verify All Cells Are Enabled for CU
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error    vDU Rest Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Log to console    The duration of vDU reset is ${duration_KPI}s
    Should be true    ${duration_KPI} < ${duration_target}


KW.CU lock_unlock VDU
    [Arguments]   ${gnb_index}=0
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_19b
    cu.lock_du    du_id=@{du_id}
    sleep    1min
    cu.unlock_du    du_id=@{du_id}
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


Setup Suite
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables         ${CFGFILE_PATH}/TLConfiguration.py
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB011055['CB011055']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB011055['CB011055']['NRBTS_ID']}
##    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
##      ...    modified_cfgfile_CU=${LOG_PATH}/8914_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
##      ...    modified_cfgfile_DU=${LOG_PATH}/8914_DU_SCF.xml    ResourceFolder=${CURDIR}
##      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
##      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
##      ...    list_to_add_CU=LIST_TO_ADD_CU
##      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
##      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
##      ...    list_to_add_DU=LIST_TO_ADD_DU
    KW.Cloud Commission And Check On Air    CU_SCF=${CFGFILE_PATH}24R3_TL2228_vCU_base_SCF.xml
      ...                                   CU_host=${CASE_INPUT_CB011055['CB011055']['vCU_host']}
      ...                                   DU_SCF=${CFGFILE_PATH}24R3_TL2228_vDU_base_SCF.xml
      ...                                   DU_host=${CASE_INPUT_CB011055['CB011055']['vDU_host']}
    Conn.ResetCache

Teardown Suite
    log to console     Suite teardown


Setup case
    log to console     Case Start


Teardown case
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.Cloud Commission And Check On Air
    [Arguments]    ${CU_SCF}    ${DU_SCF}    ${CU_host}    ${DU_host}
    CB011055 CU Full Commission        path_of_commission_file=${CU_SCF}    host=${CU_host}
    CB011055 vDU Full Commission    path_of_commission_file=${DU_SCF}    host=${DU_host}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


CB011055 CU Full Commission
    [Arguments]    ${path_of_commission_file}    ${host}
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    wait until keyword succeeds     15min    30s    coam_vcu.connect_to
     ...   host=${host}   port=443    username=Nemuadmin    password=Nokia@123    secure=true
    coam_vcu.perform_commissioning   scf_file=${path_of_commission_file}
    [Teardown]    run keyword and ignore error   coam_vcu.disconnect


CB011055 vDU Full Commission
    [Arguments]     ${path_of_commission_file}    ${host}
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
     ...   host=${host}   port=443    username=Nemuadmin    password=Nokia@123    secure=true
    coam_vdu.perform_commissioning   scf_file=${path_of_commission_file}
    [Teardown]    run keyword and ignore error   coam_vdu.disconnect

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan fix error ***
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}
    [Documentation]   load SCF and active SCF
    log to console   \n*** Start plan upload operation ***
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    wait until keyword succeeds  10s  1s
    ...    Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    log to console   \n*** Start plan fix error ***
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    log to console   \n*** Start plan validate operation ***
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10s  1s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    log to console   \n*** Start plan activate operation ***
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10m  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}

Fix vCU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success
    log to console    Upload Plan Success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success
    log to console    Validate Plan Success

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking activate plan operation status should be successful
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
    log to console    Activate Plan Success


KW.Reset VDU
    [Arguments]    ${restapi_version}=cuoam_19b   ${vdu_index}=0
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    ${out}   vdu.reset_vdu    vdu_connection=${alias}
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error


KW.block cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_19b
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.block_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout


KW.unblock cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_19b
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.unblock_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout

Change The Password Of Serviceuser Account Via Webem
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${serviceuser_new_pwd}=Nokia@123
    Log To Console   Change The Password Of Serviceuser Account Via Webem
    vDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${response}    vdu.update_service_account_password     username=serviceuser
    ...                                                    password=${EMPTY}
    ...                                                    new_password=${serviceuser_new_pwd}
    Should Be Equal    ${response['content']}    Success
    [Teardown]       VDU Rest Logout

Active SSH Access and Port for RUs
    [Arguments]
    vDU Rest Login
    Run Keyword And Continue On Failure    vdu.config_ssh_tunnel
    ...    dist_name=MRBTS-37235/EQM-1/APEQM-1/RMOD-1    operation=Enable
    sleep  5s
    Run Keyword And Continue On Failure    vdu.config_ssh_tunnel
    ...    dist_name=MRBTS-37235/EQM-1/APEQM-1/RMOD-2    operation=Enable


    vDU Logout

Login to RUs via SSH
    [Arguments]  ${host}=0.0.0.0
    ...          ${port}=51201
    ...          ${username}=serviceuser
    ...          ${password}=Nokia@123
    wait until keyword succeeds     30s    30s     SSHLibrary.Open Connection
    ...                host=${host}
    ...                port=${port}
    wait until keyword succeeds     2min    30s     SSHLibrary.Login
    ...                username=${username}
    ...                password=${password}

Logout RU
    SSHLibrary.close connection

Get power from RU via FRMON command
    [Arguments]  ${cmd1}=echo "/ action create PsuMeasurements /psum /rf/psu"|frmonShellClient 127.0.0.1 2000
    ...          ${cmd2}=echo "/psum get power_support"|frmonShellClient 127.0.0.1 2000
    ...          ${cmd3}=echo "/psum action measure"|frmonShellClient 127.0.0.1 2000
    Log to console    Start check power via FRMON command
    SSHLibrary.Start Command    ${cmd1}
    Sleep  2s
    SSHLibrary.Start Command    ${cmd2}
    Sleep  2s
    ${power}      set variable    0
    FOR  ${i}   IN RANGE   ${3}
           Sleep    3
           Wait Until Keyword Succeeds  60s   20s    SSHLibrary.Start Command    ${cmd3}
           ${_power_tmp}=    SSHLibrary.Read Command Output
           ${_power_tmp}    Split String    ${_power_tmp}    POWER
           ${_power_tmp}    Get From List    ${_power_tmp}    1
           ${_power_tmp}    Split String    ${_power_tmp}    \n
           ${_power_tmp}    Get From List    ${_power_tmp}    0
           ${power}    Evaluate   int(${_power_tmp})+${power}
    END
    ${power}    Evaluate   round(${power}/${3}, 2)
    [Return]   ${power}




