*** Settings ***

Library           ${EXECDIR}/testsuite/Beijing/ET/common/resources/lib/info_checker

*** Variables ***

${log_path}          ${TEST_LOG_DIRECTORY}
${test_point_1_json}  ${CURDIR}/resources/test_point_1.json


MY TEST CASE test01

    check info     json_file=${test_point_1_json}     base_path=${log_path}
