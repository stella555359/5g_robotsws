# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : General_SiSo_RU_module_reset_from_GUI.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
General_SiSo_RU_module_reset_from_GUI_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/15 21:14
    ${ru_index_list}     Get All RU Index
    Selenium Login And Disable Screen Lock
    FOR    ${ru_index}    IN    @{ru_index_list}
        selenium_sbts.reset_ru    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=${ru_index}
        Verify BTS OnAir Ready For L3call
        SISO Common L3 CALL
    END
    Selenium Logout And Close Browser

General_SiSo_RU_module_reset_from_GUI_3.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/08 11:02
    # Step1: Radio module resetting button position is determined in tested web element manager.
    # Radio module properties are checked.
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    ${ru_index_list}     Get All RU Index
    Selenium Login And Disable Screen Lock
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}    selenium_sbts.get_ru_info    ru_index=${ru_index}
        Should Be Equal As Strings    ${ru_info["Status"]["Operational state"]}    enabled
        Should Be Equal As Strings    ${ru_info["Status"]["Availability status"]}    -
        Should Be Equal As Strings    ${ru_info["Status"]["Procedural status"]}    configured
        Should Be Equal As Strings    ${ru_info["Product code"]}
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].product_code}
        Should Be Equal As Strings    ${ru_info["Serial number"]}
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].serial_number}

        # Step2: Radio module reset is invoked by user from GUI
        selenium_sbts.reset_ru    ru_index=${ru_index}

        # Step3: Radio module state is checked after reset
        Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    20s    Verify BTS Single RU's Cells Status Is Reset State    ru_index=${ru_index}
        Verify BTS OnAir Ready For L3call
        ${ru_info}    selenium_sbts.get_ru_info    ru_index=${ru_index}
        Should Be Equal As Strings    ${ru_info["Status"]["Operational state"]}    enabled
        Should Be Equal As Strings    ${ru_info["Status"]["Availability status"]}    -
        Should Be Equal As Strings    ${ru_info["Status"]["Procedural status"]}    configured
        Should Be Equal As Strings    ${ru_info["Product code"]}
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].product_code}
        Should Be Equal As Strings    ${ru_info["Serial number"]}
        ...    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].serial_number}

        # Step4: Call with UE is performed on cells commissioned on rebooted radio unit
        SISO Common L3 CALL
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    Selenium Logout And Close Browser