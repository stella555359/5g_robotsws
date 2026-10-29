*** Settings ***
Library           taf.gnb.oam.coam.cu                                   WITH NAME     coam_cu
Library           taf.gnb.oam.coam.vdu                                  WITH NAME     coam_vdu
Library           taf.rfrl.cbts.utilities.generic_utils                 WITH NAME    generic_utils
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library           taf.rfrl.cbts.connections.rest_conn_vcu.GenericCU     WITH NAME    vcu_gen
Resource          taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_cm.robot

*** Keywords ***
Backup Cloud vDU SCF From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0   ${include_runtime_data}=${False}   ${alias}=default
    [Documentation]  Get Cloud VDU SCF From Current Plan
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | include_runtime_data | no | include_runtime_data, default is ${False} |
    ...
    ...    *RETURN VALUE*

    ...    *******************
    ...
    ${conn_alias}   generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}

    ${backup_scf_path}    set variable    ${TEST_LOG_DIRECTORY()}/back_scf/
    ${dirctory_status}  Run Keyword and Return Status  Directory Should Exist  ${backup_scf_path}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${backup_scf_path}

    ${file_name}    generic_utils.get_unique_id_string  prefix=scf_vdu_   suffix=.xml   precise=LOW
    ${vdu_backup_scf_path}    vdu.get_current_plan_file
      ...   local_dir_path=${backup_scf_path}  filename=${file_name}  include_runtime_data=${include_runtime_data}   vdu_connection=${conn_alias}
    Log To Console   backup vDU scfc file:${vdu_backup_scf_path}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Backup Cloud vCU SCF From Current Plan
    [Arguments]    ${gnb_index}=0   ${alias}=default    ${timeout}=60
    [Documentation]  Backup Cloud vCU SCF From Current Plan

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    | alias     | yes | return value rest login |
    ...    | timeout    | No | time out |
    ...
    ...    *RETURN VALUE*

    ...
    ${conn_alias}   generic_utils.get_unique_id_string
    vcu_gen.login_rest   gnb_index=${gnb_index}   alias=${conn_alias}

    ${file_name}   generic_utils.get_unique_id_string  prefix=scf_vcu_   suffix=.xml   precise=LOW
    ${backup_vcu_scf_path}    set variable    ${TEST_LOG_DIRECTORY()}/back_scf
    ${dirctory_status}  Run Keyword and Return Status  Directory Should Exist  ${backup_vcu_scf_path}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${backup_vcu_scf_path}
    cu.get_current_plan_file   path=${backup_vcu_scf_path}/${file_name}  timeout=${timeout}    connection=${conn_alias}
    Log To Console    vcuback file name=${backup_vcu_scf_path}/${file_name}
    [Teardown]    vcu_gen.logout_rest    alias=${conn_alias}

Get Cloud vCU SW Version
	[Arguments]   ${gnb_id}=${0}
    [Documentation]
    ...     Get Cloud vCU SW Version
    ...     This keyword returns the CU software version in the specified gNB.
    ...
    ...     | gnb_id  | Id of gnb |
    ...
    ...     *Returns*   string with CU software version
    ...
    ${conn_alias}   generic_utils.get_unique_id_string
    ${cu_oam_session}   coam_cu.connect to
    ...   host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...   port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    ...   username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...   password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...   secure=${True}
    ...   alias=${conn_alias}
    ${cu_sw_version}   coam_cu.get_active_software_version   connection=${conn_alias}
    Log To Console    CU_sw_version: ${cu_sw_version}
    ${cu_sw}   testline.reform_coam_sw_version   ${cu_sw_version}
    Log To Console   CU SW Version: ${cu_sw}
    [Return]     ${cu_sw}
    [Teardown]   Run Keyword And Ignore Error    coam_cu.disconnect   ${cu_oam_session}


Get Cloud vDU SW Version
    [Documentation]
    ...
    ...     Get Cloud vDU SW Version
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    ...     *Returns*   the DU SW version as a string
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    ${conn_alias}   generic_utils.get_unique_id_string
    ${du_oam_session}   coam_vdu.connect to
    ...         host=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.addr}
    ...         port=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.port}
    ...         username=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.username}
    ...         password=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.password}
    ...         secure=${True}
    ...         connection_name=${conn_alias}

    Log To Console    conn_alias=${conn_alias}
    Log To Console    du_oam_session=${du_oam_session}

    ${info}     coam_vdu.get_vdu_state_data     vdu_connection=${du_oam_session}
    ${du_sw_version}   get from dictionary    ${info}    software_version
    ${du_sw}    testline.reform_coam_sw_version    ${du_sw_version}
    ${result}    Split String    ${du_sw_version}    separator=_    max_split=1
    Log To Console    result: ${result}
    ${branch}    Replace String    ${result[0]}    vDUCNF    ${EMPTY}
    Log To Console    branch: ${branch}
    Set Global Variable    ${BRANCH}    ${branch}
#    ${du_sw}    set variable    ${info['software_version']
    Log To Console  \nDU SW Version: ${du_sw}
    [Return]    ${du_sw}
    [Teardown]   Run Keyword And Ignore Error   coam_vdu.disconnect   ${du_oam_session}
