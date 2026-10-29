# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : General_SiSo_RF_module_power_reset.robot
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
General_SiSo_RF_module_power_reset_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/21 14:26
    ${ru_index_list}     Get All RU Index
    SISO Common L3 CALL

    # Step 1: ru power is cut off
    FOR    ${ru_index}    IN    @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END

    # Step 2: ru is powered on
    FOR    ${ru_index}    IN    @{ru_index_list}
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    END
    Wait until keyword succeeds   20min    30s    Verify BTS All Cells Status Is Normal State

    # Step 3: l3 call is normal
    SISO Common L3 CALL

Manual_SiSo_REC_Radio_Module_power_reset_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/02 10:17
    ...    https://rep-portal.ext.net.nokia.com/details/qc-case/3658685/
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589

    # Step 1 - Checking services
    SISO Common L3 CALL
    # Step 2 - Power off Radio Module
    ${ru_index_list}     Get All RU Index
    FOR    ${ru_index}    IN    @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    Verify BTS Single RU Status Is Power Off State
        ...    ru_index=${ru_index}
        Verify BTS Alarm Exist    fault_id=10    fault_name=No connection to unit
        ...    alarm_object_id=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    END
    # Step 3 - Power on Radio Module
    FOR    ${ru_index}    IN    @{ru_index_list}
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    Verify BTS Single RU Status Is Normal State
        ...    ru_index=${ru_index}
    END
    Verify BTS Alarm Not Exist    fault_id=10    fault_name=No connection to unit
    Wait until keyword succeeds   20min    30s    Verify BTS All Cells Status Is Normal State
    # Step 4 - Checking services
    SISO Common L3 CALL

    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
