*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
#*** Variables ***

*** Keywords ***
General_SiSo_RF_module_power_reset
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
    ...    - 01.09.2020 - - Created
    ...    - 27.10.2021 - - Add call
    ...    - 08.10.2023 - - Updated by mengting.li@nokia-sbell.com, task from PZ tribe, common case TA step should match with QC step
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]  ${ru_index}=1  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}  ${dl_tp}=300M  ${ul_tp}=20M  ${check_ue}=${False}
    ...    ${is_ru_power_off_checked}=${True}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    dl_tp=${dl_tp}    ul_tp=${ul_tp}    check_ue=${check_ue}
    END
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Run keyword if    ${is_ru_power_off_checked}
        ...    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
        ...    ELSE    Wait Until Keyword Succeeds    10min    1min    RU Should Be Offline    ru_index=${ru_index}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Expect FID10 Present    configObjectName=RMOD-${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    Expect FID10 Absent
    Expect FID4589 Absent
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    dl_tp=${dl_tp}    ul_tp=${ul_tp}    check_ue=${check_ue}
    END
    [Teardown]  Power On RU And Check    ru_index_list=${ru_index_list}

Expect FID10 Present
    [Arguments]      ${connection}=GNB_OAM    ${configObjectName}=${None}
    Wait until keyword succeeds  2min  20sec  Expect Fault Should Present    faultId=10    connection=${connection}
    ...    configObjectName=${configObjectName}

Expect FID10 Absent
    [Arguments]      ${connection}=GNB_OAM
    Wait until keyword succeeds  5min  1min  Expect Fault Should Absent    faultId=10    connection=${connection}

Expect FID4589 Absent
    [Arguments]      ${connection}=GNB_OAM
    Wait until keyword succeeds  30s  5s  Expect Fault Should Absent    faultId=4589    connection=${connection}
