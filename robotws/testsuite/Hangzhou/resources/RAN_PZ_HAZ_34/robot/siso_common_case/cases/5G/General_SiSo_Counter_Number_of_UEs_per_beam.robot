*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***

*** Keywords ***
General_SiSo_Counter_Number_of_UEs_per_beam
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to Check The "Number of Ues per beam" counter
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.19.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}
    selenium login and disable screen lock
    ${origin_value}    Change NrBeamforming PM Interval    interval=5min
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300M
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    sleep   10min
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    connect to common unit master
    Sync data is verified after make call    change_interval=5min
    Change NrBeamforming PM Interval    interval=${origin_value}
    [Teardown]  run keywords  csn.Disconnect  connection=ASIK Master    AND    selenium logout and close browser
