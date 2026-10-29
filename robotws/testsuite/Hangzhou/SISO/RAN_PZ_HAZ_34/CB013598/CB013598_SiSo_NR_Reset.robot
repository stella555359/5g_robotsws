*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03

Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB013598_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T2065
${scf_file}    SCF_SBTS00.xml


*** Test Cases ***

[1][1.0] General_SiSo_Auto_RAT_reset_with_L3call
    [Tags]    HAZ3_T03
    [Setup]    robot_common_operations.Common Case Setup
    Scf commission and wait on-air    scf_name=SCF_SBTS00_6cells.xml
    Run Keyword and Continue on Failure    NR reset 3 times
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown
