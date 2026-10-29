*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_Reconfiguration_from_half_split_panel_mode_of_NR-NR_16TRX_to_full_TRX_mode
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to reconfigure from half split mode to full TRX mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${cell2_physCellId}    get_physCellId_via_admin    cell_id=${2}
    Selenium Login And Disable Screen Lock
    delete cell via webUI  cell_id=${2}  cellgrp_id=${1}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    add new cell via webUI    physCellId=${cell2_physCellId}  cell_id=${2}  cellgrp_id=${1}
    delete cell via webUI  cell_id=${1}  cellgrp_id=${0}
    ${cell1_list}    Get split mode modify parameters list    cell_id=${2}    band=${100}    mMimoAntArrayMode=Full 32TRX Array (2x8x2)
    Modify Parameters On Webem    modify_params=${cell1_list}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
