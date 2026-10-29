*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***

*** Keywords ***
General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF statistics diagnostic test can be run by WebEM
    ...    and test result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.02.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${cell_id}=${1}    ${radio_id}=${1}
    ...    ${RF_temperature_high_threshold}=${90}    ${min_temperature}=-5    ${max_temperature}=90
    ...    ${rf_port_id}=0    ${ul_tput}=100M    ${dl_tput}=300M
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}    Calculate Send Tput And Expected Tput
    ...    peak_dl_tp=${dl_tput}    peak_ul_tp=${ul_tput}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tput}
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tput}
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    sleep   3min
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60    check_source=Aasyslog
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    target_avg_percent=0.1
    ...    min_percent=0.1
    log to console    ${output}
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    sleep  30
    Check Statistics General Information    radio_id=${radio_id}
    Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}
    ...    max_temperature=${max_temperature}
    Check RF Ethernet Packet Monitoring    radio_id=${radio_id}    rf_port_id=${rf_port_id}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]  selenium logout and close browser
