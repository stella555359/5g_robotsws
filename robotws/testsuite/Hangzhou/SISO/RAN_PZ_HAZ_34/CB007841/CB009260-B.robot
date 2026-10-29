*** Settings ***
Force Tags    PY36    STATE_SW_UPLOADED
Documentation     author: Li Na
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Suite Setup       Case Suite Setup
Suite Teardown    Case Suite Teardown


Resource           ./Resources/CB007841_common_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variable ***
${TS_CASE_LOG_PATH}    ${OUTPUT DIR}



*** Test Cases ***
#CB009260-B
[1][1.0] CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
   [Tags]    CRT_TRUNK
   [Setup]   Case Setup
    run keyword and continue on failure     Check no unexpected alarm in WebEM
#    ${dump_file}    Collect dump_file And check power class    log_command=bsh 1:1    bget=bget 1:1
#    ${result_class}     searchSfpPowercClass3    filename=${dump_file}    line1=25    line2=63
#    should be true     ${result_class}
    [Teardown]    robot_common_operations.Common case Teardown

[1]CB009260-SR_1_BTS_startup_SFP_power_level_1-2_compatibility_validation
   [Tags]      CRT_Trunk
   [Setup]    Case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
   [Teardown]    robot_common_operations.Common case Teardown
