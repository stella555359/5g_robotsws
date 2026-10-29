*** Settings ***
Documentation
...   This is for 1778 TA common keywords
...   author: Ren Biyao
...   contact: biyao.ren@nokia-sbell.com
...   squad group: MMW_SG1
Variables     ../TestData/1778_nidd_modify.py
Resource    ./1778_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ../../5GC002157/Resources/5GC002157_keywords.robot
Library      ../TestData/add_obj.py

*** Keywords ***
Pre condition
    [Documentation]    author: Ren Biyao
    [Arguments]    ${cu_scf_parameters_list}=${None}    ${du_scf_parameters_list}=${DU_TIMEZONE_SCF}    ${timeout}=15min
    ...    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}      ${is_need_ue_attach}=${False}
    ${SCF_DEFAULT_FILE_PATH_CU}    Get SCF template path for CU
    Set suite variable    ${SCF_DEFAULT_FILE_PATH_CU}
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${du_temp_after_process}    ${cu_temp_after_process}       Process scf before commsion
    ...    cu_scf_template_path=${SCF_DEFAULT_FILE_PATH_CU}
    ...    du_scf_template_path=${SCF_DEFAULT_FILE_PATH_DU}
    ...    temp_after_process_dir=${SUITE_LOG_PATH}

    Common suite setup preparation    cu_scf_parameters_list=${cu_scf_parameters_list}    cu_scf_template_path=${cu_temp_after_process}
    ...    du_scf_parameters_list=${DU_TIMEZONE_SCF}    du_scf_template_path=${du_temp_after_process}
    ...    is_pdl_checking_needed=${False}    cu_timeout=${timeout}    swconfig_template_path=${swconfig_template_path}

Case preparation
    [Documentation]     author: Ren Biyao
    [Arguments]    ${du_url}=https://${tl.gnbs[${0}].dus[${0}].f1_m_ip_addr}
    COAM Create log directory
    COAM Navigate to login page via webUI    url=${du_url}
    Get current plmn from bts

Create TCEADM object on DU
    [Documentation]     author: Ren Biyao
    ...     Description: the keyword is to create TCEADM object and related element.
    ...     :para${tceIdentifier_value}: the value of tceIdentifier
    ...     :para${tceIpAddress_value}: the vlaue of tceIpAddress
    [Arguments]    ${tceIpAddress_value}=${tl.test_pcs[0].default_ssh_connection_details.addr}    ${tceIdentifier_value}=${1}
    selenium_coam.add_object     object_name=MNL-1   object_class_name=TCEADM    plan_to_copy_from=${None}
    ...    id_value=1    copy_from=${None}    include_subobject=${False}    is_load_default_values=${True}
    selenium_coam.add_object     object_name=MNL-1/TCEADM-1    object_class_name=TCE    plan_to_copy_from=${None}
    ...    id_value=1    copy_from=${None}    include_subobject=${False}    is_load_default_values=${True}
    selenium_coam.set_parameter_value    dist_name=${TCE}
    ...    filter_param=Trace collector entity identifier    new_value=${tceIdentifier_value}
    selenium_coam.set_parameter_value    dist_name=${TCE}
    ...    filter_param=Trace collector entity ip address    new_value=${tceIpAddress_value}

Create NRCTRLTSDU object on DU
    [Documentation]     author: Ren Biyao
    ...     Description: the keyword is to create NRCTRLTSDU object and related element.
    ...     :para${actPCMDReporting_value} : the value of actPCMDReporting
    ...     :para${nrMtraceDuId_value} : the value of nrMtraceDuId
    ...     :para${nrTceIdentifier_value} : the value of nrTceIdentifier
    ...     :para${scope_value} : the value of Scope of New Radio Resource

    [Arguments]    ${actPCMDReporting_value}=true    ${nrTceIdentifier_value}=${1}    ${scope_value}=allResources    ${nrtrace_id_value}=${1}
    selenium_coam.add_object     object_name=NRDU-1   object_class_name=NRCTRLTSDU    plan_to_copy_from=${None}
    ...    id_value=1   copy_from=${None}     is_load_default_values=${True}
    selenium_coam.add_object     object_name=NRDU-1/NRCTRLTSDU-1   object_class_name=NRMTRACEDU
    ...    id_value=1    copy_from=${None}    include_subobject=${False}    is_load_default_values=${True}
    ...    plan_to_copy_from=${None}
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=Activate PCMD reporting    new_value=${actPCMDReporting_value}
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=New Radio Trace Collector Entity identifier    new_value=${nrTceIdentifier_value}
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=Scope of New Radio Resource    new_value=${scope_value}
    selenium_coam.add_element    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=NR trace reference
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=NR trace reference trace Id    new_value=${nrtrace_id_value}

    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=NR trace reference MCC    new_value=${BTS_MCC}
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=NR trace reference MNC    new_value=${BTS_MNC}
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=NR trace reference MNC length    new_value=${BTS_MNC_LEN}

Create NRRESOURCEDU object on DU
     [Documentation]     author: Ren Biyao
     ...     Description: the keyword is to create NRRESOURCEDU object and related element.
     ...     :para${typeNrDu_value}: the value of Type of New Radio Resource
     [Arguments]    ${typeNrDu_value}
     selenium_coam.add_object     object_name=NRMTRACEDU-1    object_class_name=NRRESOURCEDU    plan_to_copy_from=${None}
     ...    id_value=1    copy_from=${None}    include_subobject=${False}    is_load_default_values=${True}
     selenium_coam.set_parameter_value    dist_name=NRMTRACEDU-1/NRRESOURCEDU-1
     ...    filter_param=New Radio Resource DU Trace Session instance identifier    new_value=1
     selenium_coam.set_parameter_value    dist_name=NRMTRACEDU-1/NRRESOURCEDU-1
     ...    filter_param=Resource distinguished name   new_value=${NR_CELL_NAME}
     selenium_coam.set_parameter_value    dist_name=NRMTRACEDU-1/NRRESOURCEDU-1
     ...    filter_param=Type of New Radio Resource   new_value=${typeNrDu_value}

Modify NRRESOURCEDU_type and NRRESOURCEDU_resourceDN to create error on DU
    [Documentation]     author: Ren Biyao
    ...     Description: only one relationship error is ecpected.
    ...                    :para${typeNrDu_value}: the value of Type of New Radio Resource(NRRESOURCEDU_resourceDN)
    ...                     :para${scope_value}: the value of Scope of New Radio Resource(NRRESOURCEDU_type)
    log to console    /*** NRMTRACEDU-1.scope(value:allResources)&&NRRESOURCEDU-1.typeNrCu(value:cell), check error ***/
    Create TCEADM object on DU
    Create NRCTRLTSDU object on DU    scope_value=allResources
    Create NRRESOURCEDU object on DU     typeNrDu_value=cell
    selenium_coam.validate_plan
    ${err1}      selenium_coam.get_relation_errors
    ${err1_obj_dist_name}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ${err1_description} =   catenate      Whenever NRMTRACEDU-1 having NRMTRACEDU-1.scope (value: allResources) equal to
    ...    allResources, it is required that the number of MOs NRRESOURCEDU-* under ${err1_obj_dist_name} equal to 0
    run keyword and continue on failure      Check expected expected relationship error on DU
    ...    error=${err1}    exp_obj_dist_name=${err1_obj_dist_name}    exp_error_descrip=${err1_description}
    log to console    /*** NRRESOURCEDU-1.scope(value:specificResources)&&NRRESOURCEDU-1.typeNrCu(value:central), check error ***/
    selenium_coam.set_parameter_value    dist_name=NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ...    filter_param=Scope of New Radio Resource    new_value=specificResources
    selenium_coam.set_parameter_value    dist_name=NRMTRACEDU-1/NRRESOURCEDU-1
    ...    filter_param=Type of New Radio Resource   new_value=central
    selenium_coam.validate_plan
    ${err2}    selenium_coam.get_relation_errors
    ${err2_obj_dist_name}    set variable
    ...    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1/NRRESOURCEDU-1
    ${err2_description} =   catenate
    ...    Whenever NRMTRACEDU-1 having NRMTRACEDU-1.scope (value: specificResources) equal to specificResources,
    ...    NRRESOURCEDU-1 having NRRESOURCEDU-1.typeNrDu (value: central) equal to central, it is required that embedded
    ...    assertion valid (Namely: It is required that there exist MOs NRBTS-* having NRBTS.distname equal to
    ...    NRRESOURCEDU-1.resourceDN (value: MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1))
    run keyword and continue on failure      Check expected expected relationship error on DU
    ...    error=${err2}    exp_obj_dist_name=${err2_obj_dist_name}    exp_error_descrip=${err2_description}
    log to console    /*** change NRRESOURCEDU-1.resourceDN to erase error ***/
    selenium_coam.set_parameter_value    dist_name=NRMTRACEDU-1/NRRESOURCEDU-1
    ...    filter_param=Resource distinguished name   new_value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    selenium_coam.validate_plan
    ${err2_erase}    selenium_coam.get_relation_errors
    should not contain    ${err2_erase}    ${err2_description}   msg=the error should be erased!


Modify NRRESOURCEDU_type and NRRESOURCEDU_resourceDN to create error on CU
    [Documentation]     author: Ren Biyao
    ...     Description: only one relationship error is ecpected.
    ...                    :para${typeNrDu_value}: the value of Type of New Radio Resource(NRRESOURCEDU_resourceDN)
    ...                     :para${scope_value}: the value of Scope of New Radio Resource(NRRESOURCEDU_type)
    [Arguments]    ${plan_name}=${CU_DELTA_PLAN}
    CU Delta Commission update    parameters=${CU_SCF_CELLTRACE_PCMD_TRUE}
    CU Delta Commission Add MO    parameters=${TCEADM_OBJ}
    add_NRCTRLTS_obj    parameters=${NRCTRLTS_OBJ_ERROR1}    cu_ip=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ...   log_dir=${TS_CASE_LOG_PATH}
    Create cOAM CU session    browser=Firefox
    coam_cu.Choose Plan    plan_name=${plan_name}
    ${err1}    coam_cu.validate_plan
    log to console    /*** NRMTRACECU-1.scope(value:allResources)&&NRRESOURCECU-1.typeNrCu(value:cell), check error ***/
    ${err1_description} =   catenate    Whenever NRMTRACECU-1 having NRMTRACECU-1.scope (value: allResources) equal to allResources,
    ...    it is required that the number of MOs NRRESOURCECU-* under ${NRMTRACECU} equal to 0
    run keyword and continue on failure    Check expected relationship error on CU
    ...   error=${err1}    exp_obj_dist_name=${NRMTRACECU}    exp_error_descrip=${err1_description}
    log to console    /*** NRMTRACECU-1.scope(value:specificResources)&&NRRESOURCECU-1.typeNrCu(value:central), check error ***/
    add_NRCTRLTS_obj    parameters=${NRCTRLTS_OBJ_ERROR2}    cu_ip=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ...   log_dir=${TS_CASE_LOG_PATH}
    coam_cu.Choose Plan    plan_name=${plan_name}
    ${err2}      coam_cu.validate_plan
    ${err2_description} =   catenate    Whenever NRMTRACECU-1 having NRMTRACECU-1.scope (value: specificResources) equal to specificResources,
    ...    NRRESOURCECU-1 having NRRESOURCECU-1.typeNrCu (value: central) equal to central, it is required that embedded assertion valid
    ...    (Namely: It is required that there exist MOs NRBTS-* having NRBTS.distname equal
    ...    to NRRESOURCECU-1.resourceDN (value: MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1))
    Check expected relationship error on CU      error=${err2}    exp_obj_dist_name=${NRRESOURCECU}    exp_error_descrip=${err2_description}
    [Teardown]    run keyword and ignore error     Remove plan on CU    plan_name=${plan_name}

Check expected relationship error on CU
   [Documentation]     author: Ren Biyao
   ...    :para${error}: is dict type
   [Arguments]      ${error}    ${exp_obj_dist_name}    ${exp_error_descrip}
   ${relationship_error}    set variable     ${error}[Parameter Relation Errors]
   run keyword and continue on failure     should contain     ${relationship_error[0]}[Object distinguished name]    ${exp_obj_dist_name}
   run keyword and continue on failure     should contain   ${relationship_error[0]}[Error description]    ${exp_error_descrip}
   ...    msg=the description of error is not as expected!

Check expected expected relationship error on DU
   [Documentation]     author: Ren Biyao
   ...    :para${error}: is a list of dict
   [Arguments]      ${error}    ${exp_obj_dist_name}    ${exp_error_descrip}
   run keyword and continue on failure      should contain    ${error}[${exp_obj_dist_name}]    ${exp_error_descrip}
   ...    msg=the description of error is not as expected!

Remove plan on CU
    [Documentation]     author: Ren Biyao
    [Arguments]    ${plan_name}=${CU_DELTA_PLAN}
    coam_cu.Choose Plan    plan_name=${plan_name}
    sleep    2s
    coam_cu.delete_plan

Post case conditions
    [Documentation]     author: Ren Biyao
    Common case teardown
    coam_cu.logout
    COAM selenium logout

Add object on CU and DU
    [Documentation]     author: Ren Biyao
    [Arguments]    ${plan_name}=${CU_DELTA_PLAN}
    log to console    /*** Add object and modify parameter on CU ***/
    Modify NRRESOURCEDU_type and NRRESOURCEDU_resourceDN to create error on CU via rest api
    Wait until keyword succeeds    3min    5 sec    CU Verify All Cells Status Are Onair
    log to console    /*** Add object and modify parameter on DU ***/
    DU update several parameters via rest api    parameters=${DU_SCF_CELLTRACE_PCMD_TRUE}
    Create TCEADM object on DU
    Create NRCTRLTSDU object on DU    scope_value=specificResources
    Create NRRESOURCEDU object on DU     typeNrDu_value=cell
    selenium_coam.validate_plan
    selenium_coam.activate_plan      activate_plan_despite_errors=${True}
    Wait until keyword succeeds    3min    5 sec    CU Verify All Cells Status Are Onair

Check dcapuser server status
    [Documentation]     author: Ren Biyao
    [Arguments]     ${dcapuser_addr}=${tl.test_pcs[0].default_ssh_connection_details.addr}
    Connect to Common Unit Master
    ${response}=    ssh.execute    command=ping ${dcapuser_addr} -c 3    connection=ASIK Master
    should contain   ${response}    0% packet loss    msg=dcapuser is not pingable!!!

Get current plmn from bts
    [Documentation]     author: Ren Biyao
    ${bts_mnc}    selenium_coam.get_parameter_value    dist_name=${NR_NAME}    filter_param=MNC in PLMN
    ${bts_mnc_len}    selenium_coam.get_parameter_value    dist_name=${NR_NAME}
    ...    filter_param=MNC length of PLMN ID in primary PLMN of gNB
    ${bts_mcc}    selenium_coam.get_parameter_value    dist_name=${NR_NAME}    filter_param=MCC in PLMN
    set test variable     ${BTS_MNC}    ${bts_mnc}
    set test variable     ${BTS_MNC_LEN}     ${bts_mnc_len}
    set test variable     ${BTS_MCC}    ${bts_mnc_len}

Process scf before commsion
   [Documentation]   author: Ren Biyao
   ...    Description : this keyword is to delete th object before commision.
   [Arguments]     ${cu_scf_template_path}=${SCF_DEFAULT_FILE_PATH_CU}
   ...     ${du_scf_template_path}=${SCF_DEFAULT_FILE_PATH_DU}
   ...     ${temp_after_process_dir}=${SUITE_LOG_PATH}
   ${process_template}    join path     ${temp_after_process_dir}    pro_temp
   create directory     ${process_template}
   ${du_temp_after_process}      Copy file    source=${du_scf_template_path}   destination=${process_template}
   scf.load_scf    file_path=${du_temp_after_process}
   Remove object if it exsists    obj_name=${MR_BTS_NAME}/MNL-1/TCEADM-1
   Remove object if it exsists    obj_name=${MR_NR_BTS_NAME}/NRDU-1/NRCTRLTSDU-1
   scf.save_scf    file_path=${du_temp_after_process}
   ${cu_temp_after_process}      Copy file    source=${cu_scf_template_path}    destination=${process_template}
   scf.load_scf    file_path=${cu_temp_after_process}
   Remove object if it exsists    obj_name=${MR_BTS_NAME}/MNL-1/TCEADM-1
   Remove object if it exsists    obj_name=${MR_NR_BTS_NAME}/NRCTRLTS-1
   scf.save_scf    file_path=${cu_temp_after_process}    xml_declaration=${False}    standalone=${False}
   [Return]    ${du_temp_after_process}    ${cu_temp_after_process}

Remove object if it exsists
   [Documentation]   author: Ren Biyao
   [Arguments]     ${obj_name}
   ${is_obj_exists}    scf.is_object_in_scf    dist_name=${obj_name}
   run keyword if      ${is_obj_exists}    scf.remove_mo_with_descendant_mos    dist_name=${obj_name}

Modify NRRESOURCEDU_type and NRRESOURCEDU_resourceDN to create error on CU via rest api
   [Documentation]    author: Ren Biyao
   CU Delta Commission update    parameters=${CU_SCF_CELLTRACE_PCMD_TRUE}
   CU Delta Commission Add MO    parameters=${TCEADM_OBJ}
   CU Delta Commission Add MO    parameters=${NRCTRLTS_OBJ}
