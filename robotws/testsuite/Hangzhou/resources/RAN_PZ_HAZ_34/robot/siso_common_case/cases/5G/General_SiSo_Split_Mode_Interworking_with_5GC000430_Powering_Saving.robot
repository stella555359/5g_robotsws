*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***

*** Keywords ***
General_SiSo_Split_Mode_Interworking_with_5GC000430_Powering_Saving
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to check interwork with 5GC000430 RU power saving feature when split mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${cell1_list}    Get split mode modify parameters list    cell_id=${1}    band=${60}    mMimoAntArrayMode=Top 16TRX Array (1x8x2)
    ${cell2_list}    Get split mode modify parameters list    cell_id=${2}    band=${30}    mMimoAntArrayMode=Bottom 16TRX Array (1x8x2)
    ${cell_list}    combine lists    ${cell1_list}    ${cell2_list}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=true
    append to list  ${modify_params}  ${item}
    ${mix_list}    combine lists    ${cell_list}    ${modify_params}
    Modify Parameters On Webem    modify_params=${mix_list}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
