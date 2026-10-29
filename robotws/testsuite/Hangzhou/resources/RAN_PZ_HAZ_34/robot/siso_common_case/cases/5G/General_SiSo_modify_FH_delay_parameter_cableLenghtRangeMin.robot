*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***

*** Keywords ***
General_SiSo_modify_FH_delay_parameter_cableLenghtRangeMin
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to validate the cell can be onair with RU supporting timing capability report
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.18.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    Modify actForceUnitAutoReset Parameter    actForceUnitAutoReset=false
    ${modify_params}  create list
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    filter_param=Minimum value of range of cable length between baseband and radio  p_name=cableLenghtRangeMin  value=30
        append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    wait until keyword succeeds   10m   60s   Verify all cells should be onair
    ${modify_params2}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Minimum value of range of cable length between baseband and radio  p_name=cableLenghtRangeMin  value=0
    append to list  ${modify_params2}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params2}
    Wait For Expect Fault Present   timeout=600   faultId=4606
    wait until keyword succeeds    10min    1min  selenium_coam.reset_abil
    wait until keyword succeeds   10m   60s   Verify all cells should be onair
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
