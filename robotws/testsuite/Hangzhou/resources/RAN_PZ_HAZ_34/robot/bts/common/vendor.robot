*** Settings ***
Library     String
Library     Collections
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot


*** Variables ***

*** Keywords ***
Modify Vendor File And Full Commissioning
    [Arguments]    ${vendor_parameter_dict}    ${scf_file}=${EMPTY}    ${vendor_dir}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${gnb_index}=0
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${full_scf_path}    Run Keyword If    '${scf_file}'=='${EMPTY}'    COAM Download scf from cluster    connection=${connection}
    ${vendor_file_path}    Join path    ${vendor_dir}    vendor_default.xml

    Log To Console    \n***step1: download vendor file to ${vendor_file_path}***
    coam.download_vendor_file    target_file_name=${vendor_file_path}    connection=${connection}
    Sleep    5s

    Log To Console    \n***step2: modify vendor file with ${vendor_parameter_dict}***
    Modify Vendor File    vendor_parameter_dict=${vendor_parameter_dict}    vendor_file_path=${vendor_file_path}

    Log To Console    \n***step3: set vendor file with ${vendor_file_path}, then full commissioning and check on air***
    coam.set_vendor_file    vendor_file=${vendor_file_path}    connection=${connection}
    Commissioning SCF And Check On Air      scf_path=${full_scf_path}    connection=${connection}
    [Teardown]    Run Keyword and Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify Vendor File
    [Documentation]  Author: shifu.lan@nokia-sbell.com
    [Arguments]    ${vendor_parameter_dict}    ${vendor_file_path}    ${alias}=test_pc
    ...    ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    csn.connect_to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    ${param_keys}    Get Dictionary Keys	${vendor_parameter_dict}
    FOR    ${param_key}    IN    @{param_keys}
        ${param_value}    Get From Dictionary    ${vendor_parameter_dict}    ${param_key}
        ${modify_cmd}   Set Variable    sudo sed -i 's|<p name="${param_key}">.*</p>|<p name="${param_key}">${param_value}</p>|g' ${vendor_file_path}
        csn.execute    command=${modify_cmd}    connection=${alias}
        ${query_cmd}   Set Variable    cat ${vendor_file_path} | grep ${param_key}
        ${result}    csn.execute    command=${query_cmd}    connection=${alias}
        Log To Console    \n***modified the vendor file parameter '${param_key}' result: ${result}
    END
    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=${alias}
