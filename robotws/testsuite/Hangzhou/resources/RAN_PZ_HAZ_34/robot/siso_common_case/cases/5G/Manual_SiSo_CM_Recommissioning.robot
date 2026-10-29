*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify that BTS can be recommissioned by WebEM correctly.
    ...    Commissioning is done using WebEM and previously created SCF.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.19.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}  ${call_cell_id}=${1}  ${nrCellType}=8DL4UL  ${ue_num_each_call}=1
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cell_id_list}  Get All Cell Id  ru_index=${ru_index}
    change nr cell type under ru  cell_id_list=${cell_id_list}    nrCellType=${nrCellType}
    Wait Until Keyword Succeeds    10 min    30 sec    Check all cells info should be onair
    sleep    300
    Get UE From Init File and Make call  cell_list=${cell_id_list}  duration=${300}  ue_num_each_call=${ue_num_each_call}
    [Teardown]  selenium logout and close browser
