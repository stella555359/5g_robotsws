*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
*** Variables ***



*** Keywords ***
Manual_SiSo_SM_Climate_profile_configuration
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Purpose of this test case is to verify Climate control Profiling parameter
        ...    set by operator via WebEM/SCF.
        ...    taf.selenium.sbts should update to taf.selenium.sbts V0.52
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 9.1.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    [Arguments]    ${system_module}=ASOE SMOD-1/SMOD_R-1
    Test preconditions
    Modify Climate control profile through Webem    paraValue=Low Noise
    Modify Climate control profile through Webem    paraValue=Linear
    Modify Climate control profile through Webem    paraValue=Optimized Cooling
    Modify Climate control profile through SCF    paraValue=Low Noise
    Modify Climate control profile through SCF    paraValue=Linear
    Modify Climate control profile through SCF    paraValue=Optimized Cooling
    Modify Climate control profile through Commissioning Wizard    paraValue=Low Noise    system_module=${system_module}
    Modify Climate control profile through Commissioning Wizard    paraValue=Linear    system_module=${system_module}
    Modify Climate control profile through Commissioning Wizard    paraValue=Optimized Cooling    system_module=${system_module}
    [Teardown]   Selenium Logout And Close Browser



Test preconditions
    Verify all cells should be onair
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
        ...    filter_param=Climate control OCXO temperature learning    p_name=climateControlOcxoTemperatureLearning    value=false
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    selenium logout and close browser
    [Teardown]   Selenium Logout And Close Browser

Modify Climate control profile through Webem
    [Arguments]    ${paraValue}
    log to console    \n***Modify Climate control profile through Webem***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
     ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    10s
    #selenium_coam.enable_virtual_display
    #selenium_coam.login    url=https://${sbts_addr}
    #...                    username=${http_username}
    #...                    password=${http_password}
    #selenium_coam.disable_message_box
    ${currentValue}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue}    ${paraValue}
    [Teardown]    Selenium Logout And Close Browser

Modify Climate control profile through SCF
    [Arguments]   ${paraValue}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    log to console    \n***Modify Climate control profile through SCF***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    append to list    ${modify_params}    ${item}
    Modify Parameters In SCF From Webem And Commission LTE  ${modify_params}    gnb_index=${gnb_index}    connection=${connection}
    sleep  60s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${currentValue}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue}    ${paraValue}
    selenium logout and close browser
    [Teardown]    Selenium Logout And Close Browser
Modify Climate control profile through Commissioning Wizard
    [Arguments]    ${system_module}=ASOE SMOD-1/SMOD_R-1    ${paraValue}=Linear
    log to console    \n***Modify Climate control profile through Commissioning Wizard***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.go_to_commissioning_tab    target_tab_path=System Module Configuration
    selenium_coam.configure_system_module_configuration    system_module=${system_module}    climate_control_profile=${paraValue}
    selenium_coam.submit
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    3s
    ${currentValue}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue}    ${paraValue}
    selenium logout and close browser
    [Teardown]  selenium logout and close browser
