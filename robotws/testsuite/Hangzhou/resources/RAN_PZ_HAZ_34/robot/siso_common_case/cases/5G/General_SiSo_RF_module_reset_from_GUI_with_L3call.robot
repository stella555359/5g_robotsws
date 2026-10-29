*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***

*** Keywords ***
General_SiSo_RF_module_reset_from_GUI_with_L3call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.30  - Created
    ...    *******************
    ...    Owner_jiayi.tangg@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5    ${check_source}=spark
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    Sleep    60s
    Wait Until Keyword Succeeds    20min    5s    verify all cells should be onair    connection=${connection}
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        ${list_of_cell_ids}    Get List of NR Cell ID
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
        ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_duration}    check_source=${check_source}
        power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
        ...    ultarget_throughput=${ul_target}    dltarget_throughput=${dl_target}
        ...    target_avg_percent=${avg_percent}    min_percent=${min_percent}
        log to console    \n***Stop traffic***
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    apn_address=${apn_address}
        log to console    \n***UE Detach***
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    END
    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    verify all cells should be onair    connection=${connection}
    [Teardown]    General_SiSo_RF_module_reset_from_GUI_Teardown

General_SiSo_RF_module_reset_from_GUI_Teardown
    Selenium Logout And Close Browser

