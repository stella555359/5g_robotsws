*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***

*** Keywords ***
General_SiSo_Activation_and_configuration_of_NR-NR_16TRX_half_split_panel_antenna_array_mode
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to activate and configure to support half split mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    delete cell via webUI  cell_id=${2}  cellgrp_id=${1}
    ${cell1_list}    Get split mode modify parameters list    cell_id=${1}    band=${60}    mMimoAntArrayMode=Top 16TRX Array (1x8x2)
    Modify Parameters On Webem    modify_params=${cell1_list}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
