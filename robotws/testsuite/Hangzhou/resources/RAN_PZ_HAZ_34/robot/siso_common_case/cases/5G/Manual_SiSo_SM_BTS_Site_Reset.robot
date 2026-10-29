*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Library       taf.selenium.sbts    WITH NAME    selenium_coam
*** Variables ***
${ue_type}    ${tl.ues[0].capabilities[1]}


*** Keywords ***
Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify success rate of gNB site reset activated from
    ...    WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.25 - - Created
    ...    - 2023.10.07 - - Updated by mengting.li@nokia-sbell.com from PZ tribe task that ST case TA should match as QC step
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${list_of_cell_ids}    Get List of NR Cell ID
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}
    Manual_SiSo_SM_BTS_Site_Reset_L3call    list_of_cell_ids=${list_of_cell_ids}    ue_type=${ue_type}    ue_index=${ue_index}
       ...    power_reset=${power_reset}    apn_address=${apn_address}    duration=${duration}
       ...    dl_tp=${dl_tp}     ul_tp=${ul_tp}    iperf_type=${iperf_type}    log_duration=${log_duration}
       ...    ul_target=${ul_target}    dl_target=${dl_target}    avg_percent=${avg_percent}    min_percent=${min_percent}
    FOR	${i}	IN RANGE	3
        Selenium Logout And Close Browser
        Perform BTS Site Reset Cancel
        Perform BTS Site Reset
        sleep    60s
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
        csn.reset_cache
        log to console    \n***UE Attach***
        Manual_SiSo_SM_BTS_Site_Reset_L3call    list_of_cell_ids=${list_of_cell_ids}    ue_type=${ue_type}    ue_index=${ue_index}
        ...    power_reset=${power_reset}    apn_address=${apn_address}    duration=${duration}
        ...    dl_tp=${dl_tp}     ul_tp=${ul_tp}    iperf_type=${iperf_type}    log_duration=${log_duration}
        ...    ul_target=${ul_target}    dl_target=${dl_target}    avg_percent=${avg_percent}    min_percent=${min_percent}
    END
    [Teardown]    Manual_SiSo_SM_BTS_Site_Reset_Teardown

Manual_SiSo_SM_BTS_Site_Reset_L3call
    [Arguments]    ${list_of_cell_ids}    ${ue_type}   ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=100MKbits/sec    ${apn_address}=dxdata1    ${duration}=600    ${ul_tp}=100MKbits/sec    ${iperf_type}=via_app
    ...    ${log_duration}=3m    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.5    ${min_percent}=0.5
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

Perform BTS Site Reset Cancel
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    \n***Start to cancel reset***
    selenium_coam.reset_nr    cancel=${True}
    [Teardown]  COAM selenium logout

Manual_SiSo_SM_BTS_Site_Reset_Teardown
    Selenium Logout And Close Browser

