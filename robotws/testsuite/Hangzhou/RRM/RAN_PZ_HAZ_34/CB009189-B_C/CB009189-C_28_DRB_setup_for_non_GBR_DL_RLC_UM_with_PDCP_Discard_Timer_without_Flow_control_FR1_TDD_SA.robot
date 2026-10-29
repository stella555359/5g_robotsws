*** Settings ***

Documentation
...   author: piao
...   contact: yongji.piao@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB009189_B_C in 5G23R1 program

Force Tags    CRT_TRUNK    CRT_23R1
...   PY36

Suite Setup    robot_common_operations.Common Suite Setup
#Suite Teardown    robot_common_operations.Common Suite Teardown
Suite Teardown     Run keywords    robot_common_operations.Common Suite Teardown    AND    Suite Teardown with SCF
Test Timeout    30min
Resource    Resources/CB009189_keyword.robot
#ERR_WRN_start
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
#ERR_WRN_end
*** Variables ***
${UE_TYPE}    askey
${cell_id}    1
${throughput}    1400M
###5QI 7 -- NRDRB12 -- NRDRB_MAC-2 -- NRDRB_PDCP-2 -- NRDRB_RLC_UM-2
${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc[0].default_ssh_connection_details.password}

*** Test Cases ***
[1]CB009189-C_28_DRB_setup_for_non_GBR_DL_RLC_UM_with_PDCP_Discard_Timer_without_Flow_control_FR1_TDD_SA
    [Documentation]    *****************
    ...    This user scenario describes the gNB behavior for the transmission of PDCP PDUs when
    ...    ‘DiscardTimer based SDU discard’ for non-GBR bearers is enabled.
    ...    ******************
    ...    *******************
    [Tags]
    [Setup]    Precondition
    [Teardown]    Teardown
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Step0: Active CB009189-C flag
    Step1: Configure Out Of Order For 5QI & Discard timer
    Step2: Make UE Attach And Start Traffic
    Step3: Check OoO And discard timer Counters
    Step4: Stop Call
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}

*** Keywords ***
Step0: Active CB009189-C flag
    log to console    \n step 0
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}
    ...    parameter=actServiceAwarePDCPConfig    operation=update    value=true    skip_parameter_relation_errors=True    connection=COAM
Step1: Configure Out Of Order For 5QI & Discard timer
    log to console    \n step 1
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB_PDCP-2
    ...    parameter=outOfOrderDeliveryUl    operation=update    value=true    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB_PDCP-2
    ...    parameter=outOfOrderDeliveryDl    operation=update    value=true    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB-12
    ...    parameter=discardTimer    operation=update    value=10ms    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB-12
    ...    parameter=discardTimerUl    operation=update    value=10ms    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB-12
    ...    parameter=rlcMode    operation=update    value=RLC_UM    skip_parameter_relation_errors=True    connection=COAM
    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB-12
    ...    parameter=dlFlowControlAlgo    operation=update    value=none    skip_parameter_relation_errors=True    connection=COAM
Step2: Make UE Attach And Start Traffic
    log to console    \n step 2
    L3 call setup    ue_index=${0}    UE_TYPE=${UE_TYPE}    ul_throughput=130M    dl_throughput=400M    reset_sol=ue_reboot
    ...    data_transfer_direction=dl

Step3: Check OoO And discard timer Counters
    log to console    \n step 3
    Modify HBTE Channel Vaules    value=44
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='24R2'    Check Counters for 24R1 or older
    ...    ELSE    Check Counters for 24R2 or newer
    Modify HBTE Channel Vaules    value=0

Check Counters for 24R1 or older
    ${counter_list}    Create Dictionary    M55310C19002=BTS/CELLS/NRCELL-${cell_id}/NLRLC
    Check Counters    counter_list=${counter_list}

Check Counters for 24R2 or newer
    ${counter_list}    Create Dictionary    M55310C19002=BTS/MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-${cell_id}/NLRLC
    Check Counters    counter_list=${counter_list}

Step4: Stop Call
    log to console    \n step 4
    L3 call stop    ue_index=${0}    UE_TYPE=${UE_TYPE}
