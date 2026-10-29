*** Settings ***
Documentation     author: Jerry Wu
...               contact: jerry.wu@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-A
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_CB012512_A_B3
#Suite Setup       SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012512/Resource/CB012512_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Loop_Collect_Snapshot.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${if_commissioning}    True


*** Test Cases ***
General_SiSo_Commissioning_BTS_Template_Commissioning_A_B3
    [Documentation]    Modify bbmodBoardConfigType parameter and restore
    [Tags]    AQHC    PARAM_MODIFY    bbmodBoardConfigType
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown