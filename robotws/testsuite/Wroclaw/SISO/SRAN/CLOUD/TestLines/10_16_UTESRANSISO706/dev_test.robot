*** Settings ***
Documentation
...  Author: dawid.bak@nokia.com
...  Maintainer: dawid.bak@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot

Suite Setup       AiC Suite Setup
#Suite Teardown    AiC Suite Teardown

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/Trunk/vCU_8471_conf_b.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/Trunk/vDU_8471_conf_b.xml

${TEST_RUN_COUNT}=      1
${vDU_OAM_password}  Nokia@123
${VDU_URL}           https://10.42.126.114/
${CELLS_COUNT}=   2

*** Test Cases ***
[CB011039-CR-I][1.0] Automated_Failsafemode
    [Setup]  AiC Test Setup
    Snapshot Collection During Fail Safe Mode Loop Execution
    ...  rmod_ids=L1174815324
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=1
