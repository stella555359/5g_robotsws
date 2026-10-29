*** Settings ***
Documentation
...   author: qiao.1.zhang@nokia-sbell.com
...   contact: qiao.1.zhang@nokia-sbell.com
...   Description: This case is to to verify intra release
...   upgrade and rollback vDU via NOM
...   CB009087_C_VDUCNF_Upgrade_CRAN

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Library     taf.analyzer.pcap     WITH NAME    cap
#Variables   5GC001200_TestCase_Parameters.py
#Resource    ./common_trans.robot
Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot

Library     taf.gnb.oam.commissioning    WITH NAME    commissioning

*** Variables ***
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/SCF_0.300_vDU.xml
${SCF_Template_path_CU_TL}  ${commissionings_path}/HGZ/${testline_name}/SCF_0.250_vCU.xml
${SUITE_LOG_PATH}    /home/ute/Downloads/
${TS_LOG_PATH_BASE}    /home/ute/Downloads/
${gnb_index}    0
${sudo}    sudo
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Keywords ***
DU SCF Modification and Commission
    [Arguments]    ${scf_file_path}    ${scf_parameters_list}  ${gnb_index}=${0}
	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_file_path}    scf_parameters_list=${scf_parameters_list}
    vDU Full Commission SCF Fix Error    path_of_commission_file=${output_scf_file_path}

vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}     ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    vDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}   ${retries}=1
    [Documentation]   load SCF and active SCF
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    ${temp_validation_id}   Validate Plan By REST  plan_id=${upload_plan_response['plan_id']}   retries=${retries}
    ${out}   Activate Staged Plan By REST   plan_id=${upload_plan_response['plan_id']}

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

CU SCF Modification and Commission
    [Arguments]    ${scf_file_path}    ${scf_parameters_list}
	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_file_path}    scf_parameters_list=${scf_parameters_list}
	CU Full Commission Fix Error    path_of_commission_file=${output_scf_file_path}

CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success





OAM Precondition Cell Should Be Onair
    [Documentation]    Do some common thing for every precondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) initial global test varible
    ...
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.1.2022,chris.l.cao@nokia-sbell.com, remove 'CU Get Cells ID list' to save cell id information
    ...   22.1.2022,chris.l.cao@nokia-sbell.com, remove unused variable ${BACKUP_SCF_PATH_ON_CU} to shorten dryrun time
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***
    set_vdu_pod_container_suite_variables
    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online

    All DUs Container Status Should Be Normal
    #CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair For All DUs

    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd








































