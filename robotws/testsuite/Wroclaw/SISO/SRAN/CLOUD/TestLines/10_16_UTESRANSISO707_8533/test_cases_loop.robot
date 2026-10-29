*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=False

*** Variables ***
${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vCU.xml

${TEST_RUN_COUNT}=      2

*** Test Cases ***
[1][1.0] Automated_AIC_vDU_Reset
    [Setup]  AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
