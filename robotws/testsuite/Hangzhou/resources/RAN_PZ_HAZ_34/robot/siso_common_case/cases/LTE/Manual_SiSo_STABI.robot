*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_STABI
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify stability and durability of the SW when BTS is
    ...    operational with a real data transmission and maintenance actions performed in the background.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.18.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}   ${new_software}=SBTS23R1_ENB_9999_220820_000005
    ${sw_name}    ${sw_full_url}    get sw name    SW=${new_software}
    log to console  NEW_SW_PKG:${sw_name}
    Download software to VM    sw_name=${sw_name}    sw_full_url=${sw_full_url}    package_store_path=${CASE_LOG_PATH}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300
    ...    duration=1200    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100
    ...    duration=1200    ue_index=${ue_index}
    sleep   1min
    ${sw_update_report_start}    selenium_coam.save_sw_update_report
    FOR  ${i}    IN RANGE    3
        coam.update_software     sw_package=${CASE_LOG_PATH}/${sw_name}     should_activate=false    timeout=2400
        sleep    2min
        ${sw_update_report}_${i}    selenium_coam.save_sw_update_report
        Save Coam Snapshot    target_dir=${CASE_LOG_PATH}
    END
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${sw_update_report_end}    selenium_coam.save_sw_update_report
    Should Contain    ${sw_update_report_end}    ${sw_update_report_start}
