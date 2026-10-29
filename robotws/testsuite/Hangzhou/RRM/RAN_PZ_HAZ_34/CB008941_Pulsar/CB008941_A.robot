*** Settings ***
Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001358-DA
Force Tags
...    PY36
Resource    ./Resources/CB008941_common_keywords.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%
${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}
${sleep_time}    3min
&{all_tp_0}     average=0.00    peak=0.00   minimum=0.00
*** Test Cases ***

[1]CB008941-A_01_UL_UP_Dynamic_Fragmentation_Activation_FD_BF_1116_100MHz
    [Documentation]    BF+8941_UL_100M  
    [Tags]    CRT_TRUNK    CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup  
    ${stream}    Get Stream	
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_A_1}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    UL Small data check
    UL Peak Tput check    data_send_ul=115M   ultp_expected=100
    [Teardown]    Test case teardown  
	
[1]CB008941-A_05_UL_UP_Dynamic_Fragmentation_Activation_2_Subsectors_100MHz
    [Documentation]    2SS_8941_UL
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_A_5}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    UL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    UL Peak Tput check    data_send_ul=85M    ultp_expected=80
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    [Teardown]    Test case teardown  

[1]CB008941-A_07_UL_UP_Dynamic_Fragmentation_Deactivation_None-BF
    [Documentation]    2SS_8941_UL
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_A_5}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    UL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    UL Peak Tput check    data_send_ul=85M    ultp_expected=80
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}	
    [Teardown]    Test case teardown  

[1]CB008941-B_01_DL_UP_Dynamic_Fragmentation_Activation_None_BF_4D4U_40MHz

    [Documentation]   None-beamforming_8941_DL_40MHz
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_4T4R_${stream}.xml    scf_parameters=${MODIFY_SCF_B_01}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    DL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    DL Peak Tput check    data_send_dl=650M    dltp_expected=590
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}	
    [Teardown]    Test case teardown

[1]CB008941-B_02_DL_UP_Dynamic_Fragmentation_Activation_None_BF_2_SubSectors_100MHz
    [Documentation]   2SS
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_B_02}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    DL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    DL Peak Tput check    data_send_dl=1500M    dltp_expected=1490
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}	
    [Teardown]    Test case teardown

[1]CB008941-B_03_DL_UP_Dynamic_Fragmentation_Activation_None_BF_4_SubSectors_20MHz

    [Documentation]    4SS
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_B_03}
	Check CB008941 enable
	Prepare UE for ${ue_type}
    DL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    DL Peak Tput check    data_send_dl=170M    dltp_expected=150 
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}   	
    [Teardown]    Test case teardown

[1]CB008941-B_04_DL_UP_Dynamic_Fragmentation_Activation_None_BF_Non_loki
	[Documentation]    ABIL+CB008941
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_B_04}	
	#Check CB008941 disable
	Prepare UE for ${ue_type}
    DL Small data check
	UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
    DL Peak Tput check    data_send_dl=170M    dltp_expected=150
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}	
    [Teardown]    Test case teardown
*** Keywords ***
Test case teardown
    Restore swconfig to default	
	robot_common_operations.Common Case Teardown
			
UL Small data check
    UE Attach and verify attach    ue_type=${UE_TYPE}    ue_index=${0}
    Start traffic and check result    ultp_expected=10    data_send_ul=10M   tp_direction=ul
	...    sleep_time=${sleep_time}    ue_index=${0}    dltp_expected=0
    #UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
DL Small data check
    UE Attach and verify attach    ue_type=${UE_TYPE}    ue_index=${0}
    Start traffic and check result    dltp_expected=50    data_send_dl=50M   tp_direction=dl
	...    sleep_time=${sleep_time}    ue_index=${0}    ultp_expected=0
    #UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
DL Peak Tput check
    [Arguments]    ${dltp_expected}    ${data_send_dl}
    UE Attach and verify attach    ue_type=${UE_TYPE}    ue_index=${0}
    Start traffic and check result    dltp_expected=${dltp_expected}     data_send_dl=${data_send_dl}   tp_direction=dl
	...    sleep_time=${sleep_time}    ue_index=${0}    ultp_expected=0
    #UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}	

UL Peak Tput check	
    [Arguments]    ${ultp_expected}    ${data_send_ul}
    UE Attach and verify attach    ue_type=${UE_TYPE}    ue_index=${0}
    Start traffic and check result    ultp_expected=${ultp_expected}     data_send_ul=${data_send_ul}   tp_direction=ul
	...    sleep_time=${sleep_time}    ue_index=${0}    dltp_expected=0
    UE Detach for    ue_type=${UE_TYPE}    ue_index=${0}
