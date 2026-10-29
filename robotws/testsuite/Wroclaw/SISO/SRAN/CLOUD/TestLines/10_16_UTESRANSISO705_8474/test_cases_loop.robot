*** Settings ***
Documentation  To be done
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
${VDU_DELTA_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vDU_delta.xml

#${FHGW_IP}=          10.42.201.113
#${FHGW_USERNAME}=    toor4nsn
#${FHGW_PASSWORD}=    Fhgw@nokia1253
#${FHGW_PORT}=        22

#@{L1181111025_OFF}=      1  1  4  1  1  1
#@{L1181111025_ON}=       1  1  1  1  1  1
#
#&{SWITCH_OFF_ALL_DICT}=  L1181111025=@{L1181111025_OFF}
#&{SWITCH_ON_ALL_DICT}=   L1181111025=@{L1181111025_ON}

${TEST_RUN_COUNT}=      10

*** Test Cases ***
[1][1.0] Automated_AIC_vDU_Reset
    [Setup]  AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    ...  get_teardown_logs=False
