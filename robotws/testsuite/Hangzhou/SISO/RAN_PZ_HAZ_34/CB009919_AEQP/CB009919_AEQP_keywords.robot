# @Time    : 2023/2/13 10:11
# @Author  : Qingqing Deng
# @Email   : qingqing.deng@nokia-sbell.com
# @File    : CB009919_AEQP_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation
...    author: Qingqing Deng
...    contact: qingqing.deng@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG02
...    Feature CB009919-SR-A _AEQP common keywords

#Library     taf.selenium.sbts    WITH NAME    selenium_sbts
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

*** Keywords ***
Get Target Rmod RealTime Power Measurement
    [Arguments]    ${rmod}    ${energy_efficiencys}
    FOR    ${energy_efficiency}    IN    @{energy_efficiencys}
        ${object_names}    Get Dictionary Keys    ${energy_efficiency}
        ${is_target_rmod}    Run Keyword And Return Status    Should Contain    ${object_names[0]}    ${rmod}
        ${rmod_power}    Run Keyword If    ${is_target_rmod}
        ...    Set Variable    ${energy_efficiency['${rmod}']['power']}
        Run Keyword If    ${is_target_rmod}    Exit For Loop
    END
    [Return]    ${rmod_power}

Get Once Rmod RealTime Power Measurement
    ${rmod_list}    Create List
    ${rmod_values}    Create List
    ${energy_efficiencys}    coam.get_measurements    measurement_type=realTime    connection=GNB_OAM
    FOR    ${energy_efficiency}    IN    @{energy_efficiencys}
        ${object_names}    Get Dictionary Keys    ${energy_efficiency}
        ${is_rmod}    Run Keyword And Return Status    Should Contain    ${object_names[0]}
        ...    ENERGY_EFFICIENCY/RMOD
        Run Keyword If    ${is_rmod}    Append To List    ${rmod_list}    ${object_names[0]}
    END
    Sort List    ${rmod_list}
    Log to console    ${rmod_list}
    FOR    ${rmod}    IN    @{rmod_list}
        ${rmod_value}    Get Target Rmod RealTime Power Measurement
        ...    rmod=${rmod}    energy_efficiencys=${energy_efficiencys}
        Log to console    ${rmod_value}
        Run Keyword If    '${rmod_value}'!='-'    Append To List    ${rmod_values}    ${rmod_value}
    END
    Log to console    ${rmod_values}
    [Return]    ${rmod_values}

Get Average Rmod RealTime Power Measurement
    Sleep    60s
    ${1_rmod_values}    Get Once Rmod RealTime Power Measurement
    Sleep    60s
    ${2_rmod_values}    Get Once Rmod RealTime Power Measurement
    Sleep    60s
    ${3_rmod_values}    Get Once Rmod RealTime Power Measurement
    ${average_rmod_values}    Create List
    ${rmod_length}    Get Length    ${1_rmod_values}
    FOR    ${i}    IN RANGE    ${rmod_length}
        ${average_rmod_value}    Evaluate    (${1_rmod_values[${i}]}+${2_rmod_values[${i}]}+${3_rmod_values[${i}]})/3
        Append To List    ${average_rmod_values}    ${average_rmod_value}
    END
    Log to console    ${average_rmod_values}
    [Return]    ${average_rmod_values}

