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
${UE_TYPE}    ${tl.ues[0].capabilities[-1]}
${UE1_TYPE}    ${tl.ues[-1].capabilities[-1]}
${SCF_TEMPLATE_PATH}       ${commissionings_path}/HGZ/${testline_name}
${sleep_time}    3min
&{all_tp_0}     average=0.00    peak=0.00   minimum=0.00

*** Test Cases ***
[1]CB008941-C_04_CB007731_CB007449_baisc_function_verify_ 2_subsectors
    [Documentation]    BF+7449+100M+subsector
    [Tags]    CRT_TRUNK    CRT_23R3
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_${stream}.xml    is_pdl_checking_needed=${False}
	Check CB007731 enable
	Set Test Variable    ${UE_TYPE}
	Set Test Variable    ${UE1_TYPE}
	Prepare UE for ${ue_type}
    FOR    ${i}    IN RANGE    1
        UE Attach and verify attach    ue_type=${UE_TYPE}    ue_index=${0}
        Start traffic and check result for subsector UE1   ultp_expected=45    data_send_ul=50M   tp_direction=ul    ue_index=0
	    ...    sleep_time=${sleep_time}
	    #UE Detach for    ue_type=${UE_TYPE}     ue_index=${0}
        sleep    3s
    END
  	Prepare UE for xiaomi
    FOR    ${i}    IN RANGE    1
  	    UE Attach and verify attach    ue_type=${UE1_TYPE}    ue_index=${1}
        Start traffic and check result    ultp_expected=80    data_send_dl=50M   tp_direction=ul    ue_index=${1}
	    ...    sleep_time=${sleep_time}
	    UE Detach for    ue_type=${UE1_TYPE}    ue_index=${1}
        sleep    3s
    END
    #UE Detach for    ue_type=${UE_TYPE}     ue_index=${0}
    [Teardown]    Test case teardown
[1]CB008941-B_02_DL_UP_Dynamic_Fragmentation_Activation_None_BF_2_SubSectors_100MHz
    [Documentation]   2SS
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
    ${stream}    Get Stream
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_${stream}.xml   scf_parameters=${MODIFY_SCF_B_02}
	Check CB008941 enable
	Prepare UE for xiaomi
    DL Small data check-xiaomi
	UE Detach for    ue_type=xiaomi    ue_index=${1}
    DL Peak Tput check-xiaomi    data_send_dl=1500M    dltp_expected=1400
    UE Detach for    ue_type=xiaomi    ue_index=${1}	
    [Teardown]    Test case teardown			
	
[1]CB008941-C_05_DL_UP_Dynamic_Fragmentation_Activation_FD_BF
   [Documentation]   BF+CB008941+2UE
   [Setup]    robot_common_operations.Common Case Setup  
    ${stream}    Get Stream	
	Test Case setup to on air with CB008941 enable
	...    scf_name=${scf_file_template_path}/SCF_${stream}.xml    scf_parameters=${MODIFY_SCF_C_05}
	Check CB008941 enable
	Check CB007731 enable
	DL and UL Small data check-2UE
	UE Detach for    ue_type=samsung   ue_index=${0}
	UE Detach for    ue_type=xiaomi   ue_index=${1}
    [Teardown]    Run Keywords    Test case teardown    AND   Restore swconfig to default
    ...    AND    UE Detach for    ue_type=samsung   ue_index=${0}
    ...    AND    UE Detach for    ue_type=xiaomi   ue_index=${0}	
	
	
*** Keywords ***
Test case teardown
	robot_common_operations.Common Case Teardown

Test Case setup to on air
    [Arguments]    ${scf_name}     ${is_pdl_checking_needed}=${False}
    COAM Create log directory
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

Start traffic and check result for subsector UE1
    [Arguments]    ${ue_index}    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=1m
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}    ue_index=${ue_index}
    AAsys log captrue    sleep_time=${sleep_time}
    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}


Check CB007731 enable
    Check syslog contains expected value
	...    filter_print=ExtType12    expected_print="actUlEcpriExtType12":true   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log
    Check syslog contains expected value
	...    filter_print=ExtType12    expected_print="actDlEcpriExtType12":true   log_path=/ram/node_CPRT00/tmp/startup_cp_rt.log


Prepare UE for xiaomi
    log to console      Prepare UE for xiaomi
    power_ue.Prepare UE    ue_index=${1}    ue_type=xiaomi     ui_version=Mi12UI13.0.12
	sleep    40s
DL and UL Small data check-2UE
    Prepare UE for ${ue_type}
	UE Attach and verify attach    ue_type=samsung    ue_index=${0}
    Start traffic according to direction and protocol  data_send_dl=10M   tp_direction=both
    ...            data_send_ul=10M    ue_index=${0}
    Prepare UE for xiaomi
	UE Attach and verify attach    ue_type=xiaomi   ue_index=${1}
    Start traffic according to direction and protocol  data_send_dl=10M    tp_direction=both
    ...            data_send_ul=10M    ue_index=${1}
	 AAsys log captrue    sleep_time=${sleep_time}
    #Check throughput according to direction and protocol    dltp_expected=100
    #...    tp_direction=both    ultp_expected=20
DL Small data check-xiaomi
    UE Attach and verify attach    ue_type=xiaomi   ue_index=${1}
    Start traffic and check result    dltp_expected=50    data_send_dl=50M   tp_direction=dl
	...    sleep_time=${sleep_time}    ue_index=${1}    ultp_expected=0
    #UE Detach for    ue_type=${UE_TYPE}    ue_index=${1}	
DL Peak Tput check-xiaomi
    [Arguments]    ${dltp_expected}    ${data_send_dl}
    UE Attach and verify attach    ue_type=xiaomi   ue_index=${1}
    Start traffic and check result    dltp_expected=${dltp_expected}     data_send_dl=${data_send_dl}   tp_direction=dl
	...    sleep_time=${sleep_time}    ue_index=${1}    ultp_expected=0
    #UE Detach for    ue_type=${UE_TYPE}    ue_index=${1}	
