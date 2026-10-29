*** Settings ***
Suite Setup           robot_common_operations.Common Suite Setup
Suite Teardown        robot_common_operations.Common Suite Teardown
Test Setup            Run Keywords     robot_common_operations.Common Case Setup
...                   AND    Case preparation
Test Teardown         Run Keywords     robot_common_operations.Common Case Teardown
...                   AND    Case teardown  
Test Timeout         100 min

Resource     ./Resources/CB007963_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables    ./Resources/CB007963_parameters.py

Documentation
...    Author:fangmin wu
...    contact:fangmin.wu@nokia-sbell.com
...    squad group:mmw_SG_03
...    Feature CB007963 for Pulsar


*** Variables ***
${TS_LOG_PATH_BASE}    /home/ute/Downloads/
${default_scf_path}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
${scf_name}    SCF_8T8R_SBTS00.xml
@{file_name_original}    ptp_7963_original_port1.pcap   ptp_7963_original_port2.pcap
@{file_name_two}       ptp_7963_two_port1.pcap   ptp_7963_two_port2.pcap

*** Test Cases ***
[1]CB007963-SR-G_001_Upgrade_to_new_SW_version_supporting_sync_resiliency_without_activating_resiliency
#    BTS_site_reset for 7963
    Check ClockState and MaterUsed      ok_num_expect=${1}   index_begin=${0}   index_end=${2}
    Check complete PTP messages for All ports       file_name=${file_name_original}
    Add one element and set value     start_num=${0}     end_num=${1}
    Check ClockState and MaterUsed      ok_num_expect=${2}   index_begin=${0}   index_end=${2}
    Check Two Structure Log in Wireshark Log for SSM and PTP    file_name=${file_name_two}

[1]CB007963-SR-G_002_Parameter_ruECpriPortNumber_of_ToP_Master_1_configured_to_same_or_different_value_set_by_system_parameter_topSlavePortNumber
    ${PortNumber_used}    ${PortNumber_notused}     Set ruECpriPortNumber from topMasterUsed is used
    Check status and port used       PortNumber=${PortNumber_used}     is_or_not_used=used
    Set ruECpriPortNumber from topMasterUsed is not used      PortNumber_notused=${PortNumber_notused}
    Check status and port used       PortNumber=${PortNumber_notused}     is_or_not_used=used
    #SG2_Common_setup_teardown.COAM commission scf and wait cell setup     scf_file_path=${backup_scf_file}

[1]CB007963-SR-G_003_Activate_resiliency_by_configuring_a_ToP_Master_2
    Check status and port used before activate resiliency
    Add one element and set value     start_num=${0}     end_num=${1}
    Check topMasterUsed distribution
    Check status and port used after activate resiliency

[1]CB007963-SR-G_006_Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master
    Add one element and set value     start_num=${0}     end_num=${1}
    Check topMasterUsed distribution
    COAM delete objects via rest api    objects_to_delete_via_api=${DELETE_CABLINK}
    Wait For Expect Fault Present    faultId=61631    timeout=120
    check status and port used after recovery
    run keyword and ignore error    COAM add several MOs via rest api     objects_to_add_via_api=${ADD_CABLINK}
    sleep     5min
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Wait For Expect Fault To Disappear    faultId=61631    timeout=120

[1]CB007963-SR-G_007_Other_ToP_Master_becomes_better_than_still_usable_current_best_ToP_Master
    Add one element and set value     start_num=${0}     end_num=${1}
    Check topMasterUsed distribution
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_7963_LOCALPRIOPROTY}
    Wait until keyword succeeds    11min    1min    Check topMasterUsed distribution


[1]CB007963-SR-G_009_UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch
    Add one element and set value     start_num=${0}     end_num=${1}
#    Check topMasterUsed distribution
    UE Prepare and UE attach
    Check UE DL throughput is stable during the switchover
    Check UE UL throughput is stable during the switchover


*** Keywords ***



Case preparation
    COAM Create log directory    is_set_to_test_case_level=${False}
    Connect to gnb coam via ssl
	${stream}    Get Stream
    COAM Commission with scf file    scf_file_path=${default_scf_path}/SCF_8T8R_${stream}.xml     is_pdl_checking_needed=${False}
  	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    #COAM add several MOs via rest api     objects_to_add_via_api=${ADD_CABLINK}
    Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=${LOG_PATH}


Case teardown    
    run keyword and ignore error    COAM selenium logout
    COAM Teardown gnb connections

Get Stream
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    [Return]       ${stream}