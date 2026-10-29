*** Settings ***
Documentation
...    author: Li Yingying
...    contact: yingying.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001358-C
Force Tags
...    PY36
Resource       ./Resources/5GC001358_DA_common_keywords.robot
Resource       ./Resources/5GC001358_common_keyword.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Variables      ./Resources/5GC001358_variables.py

Suite Setup     robot_common_operations.Common Suite Setup
Suite Teardown       robot_common_operations.Common Suite Teardown

*** Variables ***
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%
${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}

*** Test Cases ***
[1]5GC001358-C_002_40MHz_throughput_check_5GC001116_B4
    [Documentation]
    ...    The purpose of test case is verify tp can be reached when chbw is 40Mz
    [Tags]    CRT_TRUNK      CDRT_22R2      CRT_22R2
    [Setup]   Run keywords    Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_4T4R_SBTS00.xml    scf_parameters=${MODIFY_SCF_40M}
	 ...    AND    robot_common_operations.Common Case Setup
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_2538_10}
    Connect to gnb coam via ssl
    ${list_of_cell}      Get nrCellIdentity for specific cell     cell_id=1
    Set Suite Variable    @{list_of_cell}    ${list_of_cell}
    Prepare UE for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    dltp_expected=${dltp_40MHz}    data_send_dl=${dldata_40MHz}    tp_direction=dl
    UE Detach for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    ultp_expected=${ultp_40MHz}    data_send_ul=${uldata_40MHz}    tp_direction=ul
    UE Detach for ${ue_type}
    [Teardown]    robot_common_operations.Common Case Teardown

[1]5GC001358-C_003_60MHz_throughput_check_5GC001070
    [Documentation]
    ...    The purpose of test case is verify tp can be reached when chbw is 60Mz
    [Tags]    CRT_TRUNK      CDRT_22R2      CRT_22R2
    [Setup]   Run keywords    Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_4T4R_SBTS00.xml    scf_parameters=${MODIFY_SCF_60M}
	 ...    AND    robot_common_operations.Common Case Setup	
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_2538_10}
    Prepare UE for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    dltp_expected=${dltp_60MHz}    data_send_dl=${dldata_60MHz}    tp_direction=dl
    UE Detach for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    ultp_expected=${ultp_60MHz}    data_send_ul=${uldata_60MHz}    tp_direction=ul
    UE Detach for ${ue_type}
    [Teardown]    robot_common_operations.Common Case Teardown
	
[1]5GC001358-C_004_80MHz_throughput_check_5GC001116_C2
    [Documentation]
    ...    The purpose of test case is verify tp can be reached when chbw is 80Mz
    [Tags]    CRT_TRUNK      CDRT_22R2      CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_80M}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
    Prepare UE for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    dltp_expected=${dltp_80MHz}    data_send_dl=${dldata_80MHz}    tp_direction=dl
    UE Detach for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    ultp_expected=${ultp_80MHz}    data_send_ul=${uldata_80MHz}    tp_direction=ul
    UE Detach for ${ue_type}
    [Teardown]    robot_common_operations.Common Case Teardown
	
[1]5GC001358-C_001_20MHz_throughput_check_5GC001116_C2
    [Documentation]
    ...    The purpose of test case is verify tp can be reached when chbw is 20Mz
    [Tags]    CRT_TRUNK      CDRT_22R2      CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
    Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_20M}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
    Prepare UE for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    dltp_expected=${dltp_20MHz}    data_send_dl=${dldata_20MHz}    tp_direction=dl
    UE Detach for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    ultp_expected=${ultp_20MHz}    data_send_ul=${uldata_20MHz}    tp_direction=ul
    UE Detach for ${ue_type}
    [Teardown]    robot_common_operations.Common Case Teardown
*** Keywords ***
