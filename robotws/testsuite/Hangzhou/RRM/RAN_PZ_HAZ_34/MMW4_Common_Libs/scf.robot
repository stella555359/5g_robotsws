*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

##Library           taf.sbts.oam.coam.admin              WITH NAME    coam
#Library           taf.transport.ssh    WITH NAME    csn
#Library           taf.selenium.gnb.oam.coam.cu    WITH NAME   selenium_cu
Library            taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot



*** Keywords ***
################### modify scf ##############################
Delete Objects In SCF
    [Documentation]   1.Delete object in scf,you can delete dist_name,list_name,p_name
    ...               2.parameters_lists can reference as below:
    ...               parameters_lists = [dict(dist_name='MRBTS-207/EQM-1/HWTOP-1/CABLINK-3'),
	...               dict(dist_name='MRBTS-207/NRBTS-207/NRCELL-1', list_name='a3MeasSsbRsrp'),
	...               dict(dist_name='MRBTS-207/EQM-1/APEQM-1/RMOD-1', p_name='radioMasterDN')]
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set case variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set case variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set case variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

Modify SCF File and Commissioning
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${default_scf}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${new_scf_file}
    [Teardown]    COAM Teardown gnb connections
