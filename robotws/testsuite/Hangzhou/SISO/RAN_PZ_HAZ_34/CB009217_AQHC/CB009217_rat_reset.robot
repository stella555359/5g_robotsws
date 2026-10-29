*** Settings ***
Documentation    This is for CB009217 AQHC regression

Suite Setup          Suite Setup
Suite Teardown       Suite Teardown
Test Setup           SBTS Test Setup    allowed_faults_ids=4291
Test Teardown        SBTS Test Teardown
Test Timeout         100 min


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_LTE_RAT_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot


Force Tags

*** Variables ***
${if_commissioning}    True
${ssh_username}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
${ssh_password}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.password}


*** Test Cases ***
[1]CB009217-SR-J_07_AQHC_Manual_SiSo_SM_LTE_RAT_reset
    Manual_SiSo_SM_LTE_RAT_reset


*** Keywords ***
Suite Setup
    robot_common_operations.Common Suite Setup
    log to console    \n***SBTS Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    run keyword if     ${if_commissioning} and '${testline_name}' == 'null'    CI_interface.Common Suite Setup
    ${pingable}    Run Keyword And Return Status    Check SBTS Ping Enable    bts_host=${sbts_addr}
    ${sbts_addr_temp}    set variable if    ${pingable}==${False}    192.168.255.129   ${sbts_addr}
    Connect to gnb coam via ssl    bts_host=${sbts_addr_temp}    username=${http_username}
    ...    password=${http_password}
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get SBTS SCF File Path    sw_version=${Active_SW_version}
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _20_20_20.xml
    run keyword if     ${if_commissioning} and '${testline_name}' != 'null'
    ...    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    set suite variable      ${Golden_SCF_Path}
    Generate SBTS Suite Log Path
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    bts_host=${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    add fault to the allowed fault list    faultId=${4681}
    add fault to the allowed fault list    faultId=${4291}
    log to console  MRBTS_ID:${MRBTS_ID}, NRBTS_ID:${NRBTS_ID}

Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
    robot_common_operations.Common Suite Teardown
    log to console    \n***SBTS Suite Teardown***
    COAM Teardown gnb connections
