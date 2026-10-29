*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To check RU recovery after power reset
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.22
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${list_of_cell_ids}    Get List of NR Cell ID
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        csn.reset_cache
        log to console    \n***UE Attach***
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    power_reset=${power_reset}
        power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
        log to console    \n***Start traffic***
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
        ...    apn_address=${apn_address}    duration=${duration}
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=${ul_tp}
        ...    apn_address=${apn_address}    duration=${duration}    iperf_type=${iperf_type}
        log to console    \n***Check Bi Tput***
        ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_duration}
        ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
        ...    ultarget_throughput=${ul_target}    dltarget_throughput=${dl_target}
        ...    target_avg_percent=${avg_percent}    min_percent=${min_percent}
        log to console    \n***Stop traffic***
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    apn_address=${apn_address}
        log to console    \n***UE Detach***
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    END
    [Teardown]    Manual_SiSo_REC_Radio_Module_power_reset_Teardown

Manual_SiSo_REC_Radio_Module_power_reset_Teardown
    Selenium Logout And Close Browser
