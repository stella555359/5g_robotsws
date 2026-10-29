# @Time    : 2024/2/19 14:04
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : ru.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Get RU-${ID} Current Temperature
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/19 14:05
    Connect to gnb coam via ssl    connection=GNB_OAM
    @{radios}    Create List    ${ID}
    ${detail}    coam.start_rf_statistic_diagnostic_test    force_act_remove_rf_diag=True
    ...    radios_array=${radios}
    ...    high_threshold=8
    ...    low_threshold=-8
    ...    connection=GNB_OAM
    ...    timeout=90
    [Return]    ${detail[0]["results"]["rfTemperatureSupervision"][0]["temperatureValue"]}
