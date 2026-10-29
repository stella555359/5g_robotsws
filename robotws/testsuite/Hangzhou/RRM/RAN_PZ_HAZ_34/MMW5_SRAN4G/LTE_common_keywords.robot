# @Time    : 2022/6/24 19:36
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : LTE_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is LTE common keywords
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot

*** Keywords ***
UE Attach 4G And Start DL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${throughput}    ${ue_index}=0    ${dl_time}=100    ${dl_port}=45009
    LOG    \n UE attach \n    console=yes
    UE Attach And Verify 4G    ue_index=${ue_index}
    LOG    \n Start UDP-traffic \n    console=yes
    UE Start DL Traffic   throughput=${throughput}    ue_index=${ue_index}    dl_time=${dl_time}    dl_port=${dl_port}

Check Single PM Counter
    [Arguments]    ${counter_id}    ${counter_path}    ${except_value}    ${connection}=GNB_OAM
    LOG    \n Check Single PM Counter \n    console=yes
    ${countervalue}    get_pm_counter_values    counter_id=${counter_id}
    ...    connection=${connection}    dic_path=${counter_path}
    should be true      ${countervalue[0]} > ${except_value}

Check Double PM Counters
    [Arguments]    ${counter1_id}    ${counter2_id}    ${counter_path}    ${connection}=GNB_OAM
    LOG    \n Check Double PM Counters \n    console=yes
    ${counter1_value_list}    get_pm_counter_values    counter_id=${counter1_id}
    ...    dic_path=${counter_path}    connection=${connection}
    ${counter2_value_list}    get_pm_counter_values    counter_id=${counter2_id}
    ...    dic_path=${counter_path}    connection=${connection}
    ${length}    Get Length    ${counter1_value_list}
    FOR    ${index}    IN RANGE  ${length}
        ${back_index}    Evaluate    ${index} - ${length}
        ${counter1_value}    Set Variable    ${counter1_value_list}[${back_index}]
        ${counter2_value}    Set Variable    ${counter2_value_list}[${back_index}]
        Exit For Loop If    ${counter1_value} > 0
    END
    should be true      ${counter1_value} > 0
    should be true      ${counter2_value} > 0
    [Return]    ${counter1_value}    ${counter2_value}

Scf Uploading And Commissioning For Enb
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${Log_directory}    ${SCF_Filename}
    LOG    \nCommissioning eNodeB with ${Log_directory}/${SCF_Filename}
    COAM Commission with scf file    connection=GNB_OAM
    ...    scf_file_path=${Log_directory}/${SCF_Filename}
    ...    is_pdl_checking_needed=${False}    timeout=900
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
    ${alarms}    Get BTS Active Alarms ID List
    List Should Not Contain Value    ${alarms}    ${7319}
    List Should Not Contain Value    ${alarms}    ${7300}

Perform Delta Recommissioning For Enb
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${Log_directory}    ${SCF_Filename}
    LOG    \nCommissioning eNodeB with ${Log_directory}/${SCF_Filename}
    coam.perform_delta_recommissioning    delta_file=${Log_directory}/${SCF_Filename}
    ...    connection=GNB_OAM
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
