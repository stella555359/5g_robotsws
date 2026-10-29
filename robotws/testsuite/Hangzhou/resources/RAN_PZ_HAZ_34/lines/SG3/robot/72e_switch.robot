*** Settings ***
Documentation    The keyword for test mode switch of 72a/72e
...              Author: Liu Jia
...              Contact: Jia-rebecca.liu@nokia-sbell.com

Library          taf.sbts.oam.coam.admin    WITH NAME    coam
Resource         taf/rfrl/common_resources/robot/coam_selenium.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Act Ecpri_RRU Mode Switch
    [Arguments]    ${scf_path}    ${swconfig_modify}
    ...      ${swconfig_template_path}=/opt/workspace/SCF/swconfig.txt
    ...      ${pooling_switch}=disable    ${gnb_index}=0    ${log_path}=${TS_CASE_LOG_PATH}
    ...      ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    Modify_Swconfig_and_upload_to_Gnb    swconfig_template_path=${swconfig_template_path}    swconfig_modify=${swconfig_modify}
    ...                                  swconfig_target_path=${swconfig_target_path}     gnb_index=${gnb_index}
    ${vendor_file_name}    Download Vendor File from WEBEM    gnb_index=${gnb_index}    log_path=${log_path}
    Sleep    5sec
    Modify Vendor file offline    vendor_file_name=${vendor_file_name}    pooling_switch=${pooling_switch}
    Sleep    5sec
    Load Vendor File And Commission on WEBEM    scf_path=${scf_path}
    ...                                         vendor_file_name=${vendor_file_name}
    ...                                         gnb_index=${gnb_index}
    ...                                         log_path=${log_path}

Download Vendor File from WEBEM
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${vendor_file_name}    Set Variable    ${log_path}/vendor_download.xml
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    coam.download_vendor_file    target_file_name=${vendor_file_name}    connection=${connection}
    [Return]    ${vendor_file_name}
    [Teardown]    Run Keyword and Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify Vendor file offline
    [Arguments]    ${vendor_file_name}
    ...            ${pooling_switch}=disable
    ...            ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log To Console    \n***start to Modify Vendor file***
    ${pooling_param_value}    Set Variable If    '${pooling_switch}'=='enable'    true    false
    ${vendor_pooling_72e}    Catenate
    ...    sudo sed -i 's|<p name="actBbPoolingTddFr1Ecpri72e">.*</p>|<p name="actBbPoolingTddFr1Ecpri72e">${pooling_param_value}</p>|g'
    ...    ${vendor_file_name}
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    csn.execute    command=${vendor_pooling_72e}    connection=${alias}
    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=${alias}

Load Vendor File And Commission on WEBEM
    [Arguments]    ${scf_path}    ${vendor_file_name}    ${timeout}=${120}    ${gnb_index}=${0}
    ...            ${save_location}=Local    ${log_path}=${TS_CASE_LOG_PATH}
    ...            ${gnb_type}='SA'    ${is_x2_check_from_gnb_needed}=False    ${connection}=GNB_OAM
    Log    ${save_location}
    Wait Until Keyword Succeeds    5min    20sec    COAM Navigate to login page via webUI    timeout=${timeout}
    ...                                                                                      gnb_index=${gnb_index}
    ...                                                                                      download_dir=${log_path}
    selenium_coam.enable_virtual_display
    ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Run keyword if   '${result}'=='Validation failed!'    selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Sleep   5sec
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}   timeout=${180}
    Log To Console    Start to validate and activate
    selenium_coam.validate_plan    timeout=300
    selenium_coam.activate_plan    timeout=300    activate_plan_despite_errors=${True}
    Sleep   60 sec
    Log To Console    activate done!wait for gnb on air......
    COAM Wait For Gnb Ready And Cell Setup
    ...    timeout=30 min    gnb_type=${gnb_type}    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    gnb_index=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    selenium_coam.disable_message_box    AND
    ...                           Run Keyword And Ignore Error    COAM selenium logout

Modify SCF file and download to UTE
    [Documentation]
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    ...              two ways can be used for commission:
    ...              '${scf_file_name}' != '${None}, commission with given ${scf_path}/${scf_file_name}
    ...              set ${scf_file_name} to ${None}, download current scf from cluster, modify it and perform commission.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]       ${scf_file_name}=${None}
    ...               ${scf_path}=/opt/workspace/SCF/
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ...               ${gnb_index}=${0}
    ...               ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${modified_scf_file_path}    Run keyword if    '${scf_file_name}'=='${None}'    Load Current SCF And Define modified scf path
    ...    ELSE    Load SCF and Define modified scf path    scf_file_name=${scf_file_name}    scf_path=${scf_path}
    ...    gnb_index=${gnb_index}
    run keyword if  not ${ParameterToDelete}=='NULL'     Remove object or Mo or list or element in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with the Given version
    ...                                                   parameters_lists=${MOsToAdd}
    ...                                                   gnb_index=${gnb_index}
    run keyword if  not ${ParamterToModify}=='NULL'     Add or Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements only to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists and elements to SCF     parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    [Return]    ${modified_scf_file_path}
    [Teardown]    Run Keyword and Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify_Swconfig_and_upload_to_Gnb
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                    ['0x580002=0', '0x580121=0']
    ...                ${swconfig_template_path}: swconfig file path.Should be like:/opt/workspace/swconfig/swconfig.txt
    [Arguments]    ${swconfig_template_path}    ${swconfig_modify}=${None}    ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    ...    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master    ${reset_site}=True
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${swconfig_target_path}
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}
    Run keyword if    ${reset_site}!=${None}    COAM gNB Reset site and check gnb onair    gnb_index=${gnb_index}
    [Teardown]    Run Keywords
    ...             Run Keyword And Ignore Error    csn.disconnect    connection=${alias}
    ...      AND    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=coam_admin


