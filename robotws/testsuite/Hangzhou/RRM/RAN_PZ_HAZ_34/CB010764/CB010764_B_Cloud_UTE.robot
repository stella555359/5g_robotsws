# *** Settings ***
# Documentation
# ...    author: jack.zeng
# ...    contact: jack.zeng@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB010764-B
# 
# Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
# ...    PY36
# ...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_2xAWHHF_ENB    SBTS00
# 
# Suite Setup    Run Keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    CI_interface.Common Suite Setup    AND
# ...    Run Keyword And Ignore Error    Prepare gnb_logs and mcshark setup    AND
# ...    Run Keyword And Ignore Error    Common Suite Setup for COAM
# 
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown
# ...    AND        Run Keyword And Ignore Error    Common Suite Teardown for COAM
# ...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.robot
# 
# *** Variables ***
# ${gnb_logs_install_path}     /home/ute/gnb_logs
# 
# 
# *** Test Cases ***
# [1]CB010764-B#2_001_PRACH_noise_power_real_estimate_reported_without_pegging_of_CB008021_PM_counters
#     [Documentation]    CB010764-B
#     [Tags]    CB010764-B    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_1}    skip_parameter_relation_errors=True
#     Comment    capture the BIP log and syslog when 5G cell on air without attach
#     ${CB010764_gnb1_B_2001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#     Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#     ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#     Should Be Equal As Strings    ${noisePower_value}    ['10']
#     Comment    step3 set the NRBTS/NRCELL/actPrachNoPreambleNoisePwrEst=true
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_2}    skip_parameter_relation_errors=True
#     Comment    capture the BIP log and syslog when 5G cell on air without attach
#     ${CB010764_gnb1_B_2001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#     Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#     ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#     Should not Be Equal As Strings    ${noisePower_value}    ['10']
#     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#     ...     prach_PRB_number=@{prach_PRB_number}[0]
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#     Comment    step7.change the value of actnrulripmeasurement = enabledWithoutPRACH and capture the BIP log and syslog
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_3}    skip_parameter_relation_errors=True
#     Comment    capture the BIP log and syslog when 5G cell on air without attach
#     ${CB010764_gnb1_B_2001_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#     Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#     ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#     Should not Be Equal As Strings    ${noisePower_value}    ['10']
#     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#     ...     prach_PRB_number=@{prach_PRB_number}[0]
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
# ##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# #
# #
# [1]CB010764-B#3_001_PRACH_noise_power_real_estimate_reported_with_pegging_of_CB008021_PM_counters
#     [Documentation]    CB010764-B
#     [Tags]    CB010764-B    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_1}    skip_parameter_relation_errors=True
#     Comment    capture the BIP log and syslog when 5G cell on air without attach
#     ${CB010764_gnb1_B_3001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#     Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
#     ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
#     Should not Be Equal As Strings    ${noisePower_value}    ['10']
#     ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#     ...     prach_PRB_number=@{prach_PRB_number}[0]
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     Check counter for B3001_gnb1_UL_RIP_scheduled_PRB    max_aW_value= ${max_aW_value}
#     Comment    step4 change the value of actnrulripmeasurement = enabledWithPRACH_PUCCH_F1 and capture the BIP log and syslog
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_2}    skip_parameter_relation_errors=True
#     Comment    capture the BIP log and syslog when 5G cell on air without attach
#     ${CB010764_gnb1_B_3001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#     Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
#     ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
#     Should not Be Equal As Strings    ${noisePower_value}    ['10']
#     ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#     ...     prach_PRB_number=@{prach_PRB_number}[0]
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     Check counter for B3001_gnb1_UL_RIP_scheduled_PRB    max_aW_value= ${max_aW_value}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ##...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#     ${counter_time}=    Get current PM counter time
#     Get the all PM counter value should be Null
#     ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_2001}    dic_path=${counter_dic_path_B_2001}
#     ...    date=${counter_time}
#     ${counter_value_list2}    Get the all PM counter value
#     ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_2001_2}    dic_path=${counter_dic_path_B_2001}
#     ${counter_lenth}    Get Length    ${counter_value_list2}
#     :For    ${index}    IN RANGE    ${counter_lenth}
#     \    ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
#     \    Should Be True      ${counter_value} == 0
# 
# Check counter for B3001_gnb1_UL_RIP_scheduled_PRB
#     [Arguments]    ${max_aW_value}
#     ${counter_value_list}    Get the all PM counter value
#     ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001}    dic_path=${counter_dic_path_B_2001}
#     ${counter_lenth}    Get Length    ${counter_value_list}
#     :For    ${index}    IN RANGE    ${counter_lenth}
#     \    ${counter_value}    Set Variable    ${counter_value_list[${index}]}
#     \    Should Be True     -130 < ${counter_value} < -100
#     ${counter_value_list2}    Get the all PM counter value
#     ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_max}    dic_path=${counter_dic_path_B_2001}
#     ${counter_lenth2}    Get Length    ${counter_value_list2}
#     :For    ${index}    IN RANGE    ${counter_lenth2}
#     \    ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
#     \    Should Be True     -130 < ${counter_value} < -100
#     \    Should Be True      ${counter_value} <= ${max_aW_value}
#     [Return]    ${counter_value_list}