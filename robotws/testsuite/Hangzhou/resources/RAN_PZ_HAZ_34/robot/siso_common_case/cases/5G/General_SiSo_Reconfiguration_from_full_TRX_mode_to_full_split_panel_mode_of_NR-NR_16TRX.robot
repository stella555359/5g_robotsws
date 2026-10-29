*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_Reconfiguration_from_full_TRX_mode_to_full_split_panel_mode_of_NR-NR_16TRX
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to reconfigure from Full TRX mode to Full split mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${cell2_physCellId}    get_physCellId_via_admin    cell_id=${2}
    ${cell2_physCellId_temp}    convert to number  ${cell2_physCellId}
    ${cell3_physCellId}    evaluate  ${cell2_physCellId_temp}+1
    ${cell3_physCellId}    convert to string    ${cell3_physCellId}
    ${cell3_physCellId}    get substring    ${cell3_physCellId}     0    -2
    Selenium Login And Disable Screen Lock
    delete cell via webUI  cell_id=${2}  cellgrp_id=${1}
    ${cell1_list}    Get split mode modify parameters list    cell_id=${1}    band=${100}    mMimoAntArrayMode=Full 32TRX Array (2x8x2)
    Modify Parameters On Webem    modify_params=${cell1_list}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    add new cell via webUI    physCellId=${cell2_physCellId}  cell_id=${2}  cellgrp_id=${1}
    add new cell via webUI    physCellId=${cell3_physCellId}  cell_id=${3}  cellgrp_id=${2}
    delete cell via webUI  cell_id=${1}  cellgrp_id=${0}
    ${cell2_list}    Get split mode modify parameters list    cell_id=${2}    band=${60}    mMimoAntArrayMode=Top 16TRX Array (1x8x2)
    ${cell3_list}    Get split mode modify parameters list    cell_id=${3}    band=${30}    mMimoAntArrayMode=Bottom 16TRX Array (1x8x2)
    ${cell_list}    combine lists    ${cell2_list}    ${cell3_list}
    Modify Parameters On Webem    modify_params=${cell_list}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
