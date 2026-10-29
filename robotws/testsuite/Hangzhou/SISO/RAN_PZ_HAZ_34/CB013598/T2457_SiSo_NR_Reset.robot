*** Settings ***
Documentation     author: Wen Xuewen
...               contact: xuewen.wen@nokia.com
...               squad group: VRF HAZ T01

Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    200 min

Resource    ./Resources/T2457_Robust_Common_Keyword.robot

*** Variables ***
${testline_name}    7_5_UTE5G402T2457
${scf_file}			SCF_SBTS00.xml
${times}				50
${allowed_faults_ids}	4639,4459,4655,4654,61524,61652
${ALLOWED_ALARMS}    '4592', '61524', '61649', '61652', '4334', '4340', '4654', '4655', '4681', '61524', '7313', '6826', '62003'
...    '4741', '61641', '7300', '7319', '6327' '4293', '4589', '6825', '6832', '6829', '49', '4614', '50', '4003', '7509', '4459', '4639', '7107'
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}/SBTS00

*** Test Cases ***

[1][1.0] General_SiSo_Auto_RAT_reset_with_L3call
    [Tags]    SISO_NR_Reset
    [Setup]    robot_common_operations.Common Case Setup	allowed_faults_ids=${allowed_faults_ids}
	Log To Console		${commissionings_path}HGZ/${testline_name}/SBTS00
    Scf commission and wait on-air    scf_name=${scf_file}
    Run Keyword and Continue on Failure    NR reset ${times} times
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown