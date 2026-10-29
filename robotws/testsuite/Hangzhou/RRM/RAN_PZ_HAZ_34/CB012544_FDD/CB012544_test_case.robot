*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB012544 FDD

Resource         Resources/CB012544_SG3_case_step.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


Suite Setup         Run Keywords     CB012544_FDD_suite_setup
...                  AND             _prepare_argument_for_12544
...                  AND             Common Case TestLine Setup     ModifySCF_Beforecommission_GNB2=True
...                                                                 scf_path=${scf_path_12544}
...                                                                 golden_scf_name_gnb2=${TL2_ID}_${release_info}.xml
...                                                                 Is_Swconfig_for_GNB2=True
...                                                                 swconfig_file_gnb2=${swconfig_file}
...                                                                 swconfig_modify_gnb2=${swconfig_12544}
Suite Teardown      CB012544_FDD_suite_teardown


Force Tags    PY36




*** Variables ***
${C_001_wireshark_attach}         C_001_wireshark_attach.pcap
${C_003_wireshark_attach}         C_003_wireshark_attach.pcap
${C_007_wireshark_attach}         C_007_wireshark_attach.pcap
${D_001_wireshark_attach}         D_001_wireshark_attach.pcap
${D_002_wireshark_attach}         D_002_wireshark_attach.pcap
${D_005_wireshark_attach}         D_005_wireshark_attach.pcap
${D_007_wireshark_attach}         D_007_wireshark_attach.pcap
${ABC005_part1_wireshark_attach}         ABC005_part1_wireshark_attach.pcap
${eda_wireshark_attach_gnb1}      eda_wireshark_attach_gnb1.pcap
${eda_wireshark_attach_gnb2}      eda_wireshark_attach_gnb2.pcap
${C_010_wireshark_attach}         C_010_wireshark_attach.pcap
${C_011_wireshark_attach}         C_011_wireshark_attach.pcap
${C_001_wireshark_paging}         C_001_wireshark_paging.pcap
${C_003_wireshark_paging}         C_003_wireshark_paging.pcap
${C_007_wireshark_paging}         C_007_wireshark_paging.pcap
${D_001_wireshark_paging}         D_001_wireshark_paging.pcap
${D_002_wireshark_paging}         D_002_wireshark_paging.pcap
${D_005_wireshark_paging}         D_005_wireshark_paging.pcap
${D_007_wireshark_paging}         D_007_wireshark_paging.pcap
${C_010_wireshark_paging}         C_010_wireshark_paging.pcap
${C_011_wireshark_paging}         C_011_wireshark_paging.pcap
${AB002_wireshark_attach}         AB002_wireshark_attach.pcap
${AB002_wireshark_paging}         AB002_wireshark_paging.pcap
${ABC005_part1_wireshark_paging}         ABC005_part1_wireshark_paging.pcap
${config_command_C007_01}         amf_registration_param id=1 tmsi=4097\n
...                               amf_paging_param id=1 max_paging_retries=1 default_drx=256
${config_command_D005_01}         amf_registration_param id=1 tmsi=4097 include_edrx=on edrx_value=2.56s extended_paging_time_window=1.28s\n
...                               amf_paging_param id=1 max_paging_retries=1 default_drx=256\namf_ue_ics_param id=1 ue=1
...                               core_network_assistance_info=on ue_identity_index_value=1 periodic_registration_update_timer=24:30secs
...                               plmn_id=001:01 tac_id=270 extended_ue_identity_index_value=1 hashed_ue_identity_index_value=1421
...                               nr_paging_edrx_cycle=hfquarter nr_paging_time_window=s1
${config_command_C010}            amf_registration_param id=1 tmsi=4097\n
...                               amf_paging_param id=1 max_paging_retries=1 default_drx=128
${config_command_D007}            amf_registration_param id=1 tmsi=4097 include_edrx=on edrx_value=20.48s\namf_paging_param id=1 max_paging_retries=1
...                               default_drx=256\namf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
...                               periodic_registration_update_timer=24:30secs plmn_id=001:01 tac_id=270 extended_ue_identity_index_value=1
...                               hashed_ue_identity_index_value=1421 nr_paging_edrx_cycle=hf2
${config_command_C011}            amf_registration_param id=1 tmsi=4097\namf_paging_param id=1 max_paging_retries=10 default_drx=256
${config_command_D001}            amf_registration_param id=1 tmsi=4097\namf_registration_param id=1 include_edrx=on edrx_value=10.24s
...                               extended_paging_time_window=40.96s\namf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
...                               ue_identity_index_value=1 ue_specific_drx=256 periodic_registration_update_timer=24:30secs plmn_id=001:01
...                               tac_id=270 extended_ue_identity_index_value=1 hashed_ue_identity_index_value=1421 nr_paging_edrx_cycle=hf1
...                               nr_paging_time_window=s32
${tmsi_paging}                 4097
${tmsi_fake1}                  8193     #200537
${tmsi_fake2}                  12289    #204633
${tmsi_fake3}                  16385    #208729
${tmsi_fake4}                  20481    #212825
${tmsi_fake5}                  24577    #216921
${idle_status}                 idle: 1
@{parameter_list_D005}         ranEdrxPagingCycle
@{drxDefaultPaging}            drxDefaultPaging
${warning_msg}                 C001_CASE_TEST
${CBS_btoadcast_stop_command}       cbs_broadcast_stop amf=1 cancel_all=on



*** Test Cases ***
[1]CB012544_C_001_Core_Network_Paging_for_UE_rrc_idle_with_eDRX_configuration_and_eDRX_Cycle_not_greater_than_10.24s
    [Documentation]
    ...    cover CB012544_A_B_001; CB012544_B_102; CB012544_C_102; CB012544_C_103; CB012544_C_104; CB012544_A_101; CB012544_A102
    ...    UE:RRC_IDLE
    ...    real core network
    ...    actEdrx=idle
    [Tags]    C_001
    [Setup]
    SG3_12544_case_setup
    ...                      online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_C_001}
    B_102 set_actEdrx and check_sib for C001
    comment    --A_101_test--
    A_101_test
#    start_capture_btslogs
    comment    --C_001_test--
    MTK60 prepare UE        ue_index=${2}    ue_type=${ue_type_MTK60}
    ${wireshark_attach_C001}     _UE_attach_and_enter_idle    tcpdump_collector_name=${C_001_wireshark_attach}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C001}
    ${wireshark_paging_C001}     ${C_001_bip_paging}
    ...     _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_C001}
    ...                                        tcpdump_collector_name=${C_001_wireshark_paging}
    ...                                        target_file_name=C_001_BIP_paging
    check counters for C_001
    C_001 check_logs     wireshark_attach_C001=${wireshark_attach_C001}      wireshark_paging_C001=${wireshark_paging_C001}
    ...                  C_001_bip_paging=${C_001_bip_paging}
    comment    --12544_A_102_test--
    A_102_test
    [Teardown]     Run Keywords
    ...     Run Keyword And Ignore Error     A_101_modify_GNB3_output_configuration    Modify_Para_Online=${Modify_A_101_covery}
    ...     AND    SG3_12544_case_teardown
    ...     AND    Run Keyword And Ignore Error     Common Case TestLine Setup     is_commission_for_second_gnb=True
    ...                                                                            scf_path=${scf_path_12544}
    ...                                                                            golden_scf_name_gnb2=${scf_TL344_TRUNK}


[1]CB012544_C_003_CN_Paging_for_UE_rrc_idle_with_eDRX_configuration_and_eDRX_Cycle_greater_than_10.24s_and_without_NR_Paging_Time_Window
    [Documentation]
    ...    cover CB012544_A_B_004; CB012544_A_B_006; CB012544_D_201; CB012544_D_202; CB012544_D_002; CB012544_D_003; CB012544_A_B_002
    ...    UE:RRC_IDLE
    ...    real core network
    ...    actEdrx=idle+inactive
    [Tags]    C_003
    [Setup]
    SG3_12544_case_setup
    ...                      online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_D_002}
    ...                      Delete_Para_Online=${Delete_Para_D_002}
    AlarmWatchdog.add_allow_alarms    fault_id=${12544_allow_fault_list}
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Delete_Mo_Online_GNB2=${Delete_NTP_Mo}
    ####EDA_04136786_step####
#    EDA_04136786_steps
#    EDA_04136786_checkpoint
#    start_capture_btslogs
    ####D002_step####
    comment    --D002_test--
    MTK60 prepare UE        ue_index=${2}    ue_type=${ue_type_MTK60}
    ${wireshark_attach_D002}     _UE_attach_and_enter_RRC_inactive    tcpdump_collector_name=${D_002_wireshark_attach}
    _check_rrc_inactivity_in_wireshark
    ...                file_path=${wireshark_attach_D002}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    ${wireshark_paging_D002}     ${D_002_bip_paging}
    ...     _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_D002}
    ...                                        tcpdump_collector_name=${D_002_wireshark_paging}
    ...                                        target_file_name=D_002_BIP_paging
    run keyword and continue on failure     check counters for D_002
    run keyword and continue on failure     D_002_check_logs    wireshark_paging_D002=${wireshark_paging_D002}
    ####A_B_002_TEST####
    comment    -- A_B_002_test--
    A_B_002_test_part1
    A_B_002_test_part2     ###test on cell2###
    ####C003_step test on cell1####
    comment    --C003_test--
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${Modify_C_003}
    Adjust the HBTE attenuation value for 12544    gnb2_cell1_value=${10}
    ${wireshark_attach_C003}      _UE_attach_and_enter_idle      tcpdump_collector_name=${C_003_wireshark_attach}    sleep_time=90s
    _check_rrc_inactivity_in_wireshark
    ...                file_path=${wireshark_attach_C003}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C003}
    ${wireshark_paging_C003}     ${C_003_bip_paging}
    ...     _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_C003}
    ...                                        tcpdump_collector_name=${C_003_wireshark_paging}
    ...                                        target_file_name=C_003_BIP_paging
    run keyword and continue on failure     check counters for C_003
    run keyword and continue on failure     C_003_check_logs     C_003_bip_paging=${C_003_bip_paging}
    ...                                                          wireshark_paging_C003=${wireshark_paging_C003}
    [Teardown]     SG3_12544_case_teardown

[1]CB012544_C_007_CN_Paging_for_mutli_UEs_with_eDRX_Cycle_not_greater_than_10.24s_during_overload_and_set_eDRXBasedDiscardPagingRecord_true
    [Documentation]
    ...    cover eDRXBasedDiscardPagingRecord=ture: CB012544_B_102; eDRXBasedDiscardPagingRecord=false: CB012544_C_008; CB012544_D_007
    ...    UE:RRC_INACTIVE
    ...    airphone
    ...    FDDCELL1:idle; FDDCELL2:idle+inactive
    [Tags]    C_007
    [Setup]
    SG3_12544_case_setup     online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_C_007}
    B_102 set_actEdrx and check_sib for C007
    config_simulation_core_network    config_command=${config_command_C007_01}
    MTK60 prepare UE     ue_index=${2}    ue_type=${ue_type_MTK60}
#    start_capture_btslogs
    comment    --C007_test--
    ${wireshark_attach_C007}     _UE_attach_and_enter_idle    tcpdump_collector_name=${C_007_wireshark_attach}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C007}
    ${paging_command_C007}     C007_Paging_command_get
    Prepare to caculate PM counter     period=start    gnb_index=${1}
    check_inactivity_status_with_simulation     ue_configured_status=${idle_status}
    Start capture wireshark log on master     filename=${C_007_wireshark_paging}    gNB_index=${1}
    ${C_007_bip_paging}    send_paging_command_during_bip_collect     target_file_name=biplog_C007_paging    paging_command=${paging_command_C007}
    ${wireshark_paging_C007}    Stop and download the wiresharklog from master    filename=${C_007_wireshark_paging}    gNB_index=${1}
    Prepare to caculate PM counter     period=end    gnb_index=${1}
    run keyword and continue on failure     check counters for C_007
    run keyword and continue on failure     C_007 check_logs    wireshark_paging_C007=${wireshark_paging_C007}
    ...                                                         C_007_bip_paging=${C_007_bip_paging}
    # --start D_005 case test-- #
    comment    --D005_test--
    Common Case TestLine Setup      ModifySCF_Aftercommission_for_GNB2=True
    ...                             Modify_Para_Online_GNB2=${Online_Modify_D005}
    Adjust the HBTE attenuation value for 12544    gnb2_cell2_value=${10}
    config_simulation_core_network    config_command=${config_command_D005_01}
    ${wireshark_attach_D005}     _UE_attach_and_enter_RRC_inactive    tcpdump_collector_name=${D_005_wireshark_attach}
    ${UE_DL_port}    ${UE_IP}    Get IP address from wireshark log and set ue_port     get_ip_from_cpif=${wireshark_attach_D005}
    _check_rrc_inactivity_in_wireshark    file_path=${wireshark_attach_D005}     parameter_list=${parameter_list_D005}
    ${paging_command_D005}     D005_Paging_command_get
    Prepare to caculate PM counter     period=start    gnb_index=${1}
    ${wireshark_paging_D005}    ${D_005_bip_paging}    ${check_tput_result}
    ...         D005_start_simulator_and_traffic_failed     tcpdump_collector_name=${D_005_wireshark_paging}
    ...                                                     target_file_name=biplog_D005_paging
    ...                                                     paging_command=${paging_command_D005}
    ...                                                     dl_port=${UE_DL_port}
    ...                                                     ue_addr=${UE_IP}
    ...                                                     cellid=${nrcellid2}
    run keyword and ignore error    Close the iperf process on APPserver    port=${UE_DL_port}
    run keyword and continue on failure     check counters for D_005
    run keyword and continue on failure     D_005 check_logs    wireshark_paging_D005=${wireshark_paging_D005}
    ...                                                         D_005_bip_paging=${D_005_bip_paging}
    [Teardown]     SG3_12544_case_teardown


[1]CB012544_C_010_CN_Paging_for_UE_rrc_inactive_during_paging_overload_and_with_paging_prioritization_when_set_eDRXBasedDiscardPagingRecord_false
    [Documentation]
    ...    cover: CB012544_C_009:eDRXBasedDiscardPagingRecord=true; CB012544_D_007
    ...    UE:RRC_INACTIVE->IDLE
    ...    airphone
    ...    FDDCELL1:actEdrx=idle+inactive; FDDCELL2:idle
    [Tags]    C_010
    [Setup]
    SG3_12544_case_setup     online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_C_010}
    config_simulation_core_network    config_command=${config_command_C010}
#    start_capture_btslogs
    MTK60 prepare UE        ue_index=${2}    ue_type=${ue_type_MTK60}
    comment    --C010_test--
    ${wireshark_attach_C010}     _UE_attach_and_enter_idle     tcpdump_collector_name=${C_010_wireshark_attach}
    C_001 check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C010}
    ${paging_command_C010}     C010_Paging_command_get
    Prepare to caculate PM counter     period=start    gnb_index=${1}
    check_inactivity_status_with_simulation     ue_configured_status=${idle_status}
    Start capture wireshark log on master     filename=${C_010_wireshark_paging}    gNB_index=${1}
    ${C_010_bip_paging}    send_paging_command_during_bip_collect     target_file_name=biplog_C010_paging    paging_command=${paging_command_C010}
    ${wireshark_paging_C010}    Stop and download the wiresharklog from master    filename=${C_010_wireshark_paging}    gNB_index=${1}
    set test variable     ${wireshark_paging_C010}
    Prepare to caculate PM counter     period=end    gnb_index=${1}
    set test variable     ${C_010_bip_paging}
    run keyword and continue on failure     check counters for C_010
    run keyword and continue on failure     C_010 check_logs
    ###--start D_007 case test on cell2--###
    comment    --D007_test--
    Common Case TestLine Setup      ModifySCF_Aftercommission_for_GNB2=True
    ...                             Modify_Para_Online_GNB2=${Online_Modify_D007}
    Adjust the HBTE attenuation value for 12544    gnb2_cell2_value=${10}
    config_simulation_core_network    config_command=${config_command_D007}
    ${wireshark_attach_D007}     _UE_attach_and_enter_RRC_inactive    tcpdump_collector_name=${D_007_wireshark_attach}
    ${UE_DL_port}    ${UE_IP}    Get IP address from wireshark log and set ue_port     get_ip_from_cpif=${wireshark_attach_D007}
    _check_rrc_inactivity_in_wireshark    file_path=${wireshark_attach_D007}     parameter_list=${parameter_list_D005}
    ${paging_command_D007}     D007_Paging_command_get
    ${wireshark_paging_D007}    ${D_007_bip_paging}
    ...                    _start_simulator_and_traffic     tcpdump_collector_name=${D_007_wireshark_paging}
    ...                                                     target_file_name=biplog_D007_paging
    ...                                                     paging_command=${paging_command_D007}
    ...                                                     dl_port=${UE_DL_port}
    ...                                                     ue_addr=${UE_IP}
    ...                                                     cellid=${nrcellid2}
    run keyword and ignore error    Close the iperf process on APPserver    port=${UE_DL_port}
    run keyword and continue on failure     check counters for D_007
    run keyword and continue on failure     D_007 check_logs     wireshark_paging_D007=${wireshark_paging_D007}
    ...                                                          D_007_bip_paging=${D_007_bip_paging}
    comment    --B102_test--
    B_102 set_actEdrx and check_sib for C010
    [Teardown]     SG3_12544_case_teardown

[1]CB012544_C_011_Core_Network_Paging_for_UE_rrc_idle_with_eDRX_configuration_IWK_with_5GC000747_ETWS
    [Documentation]
    ...    cover: CB012544_C_011. UE:RRC_IDLE; CB012544_A_B_C_005
    ...    airphone
    ...    FDDCELL1:actEdrx=idle+inactive; FDDCELL2:idle
    [Tags]    C_011
    [Setup]
    SG3_12544_case_setup     online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_C_011}
    B_102 set_actEdrx and check_sib for C011
    config_simulation_core_network    config_command=${config_command_C011}
    MTK60 prepare UE        ue_index=${2}    ue_type=${ue_type_MTK60}
    ${wireshark_attach_C011}     _UE_attach_and_enter_idle    tcpdump_collector_name=${C_011_wireshark_attach}
    C_001 check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C011}
    ${paging_command_C011}     C011_Paging_command_get
    Start capture wireshark log on master     filename=${C_011_wireshark_paging}    gNB_index=${1}
    ${C_011_bip_paging}    send_paging_command_during_bip_collect     target_file_name=biplog_C011_paging    paging_command=${paging_command_C011}
    ${wireshark_paging_C011}    Stop and download the wiresharklog from master    filename=${C_011_wireshark_paging}    gNB_index=${1}
    set test variable     ${wireshark_paging_C011}
    run keyword and ignore error    stop_btoadcast_action    stop_command=${CBS_btoadcast_stop_command}
    run keyword and continue on failure     C011 check_logs    C_011_bip_paging=${C_011_bip_paging}
    [Teardown]     SG3_12544_case_teardown



[1]CB012544_D_001_Successful_RAN_paging_for_UE_in_RRC_INACTIVE_edrx_Cycel_Tedrx_CN_not_greater_than_10.24s
    [Documentation]
    ...    cover: CB012544_D_001. CB012544_UPD001.UE:RRC_INACTIVE; CB012544_A_B_C_005
    ...    airphone
    ...    actEdrx=idle+inactive
    [Tags]    D_001
    [Setup]
    SG3_12544_case_setup
    ...                      online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_D_001}
    ...                      Delete_Mo_Online=${Delete_NTP_Mo}
    comment    --A_B_C_005_test--
    A_B_C_005_test_part1
    MTK60 prepare UE        ue_index=${2}    ue_type=${ue_type_MTK60}
#####    start_capture_btslogs
    ${wireshark_attach_ABC005_part1}     _UE_attach_and_enter_RRC_inactive    tcpdump_collector_name=${ABC005_part1_wireshark_attach}
    _check_rrc_inactivity_in_wireshark    file_path=${wireshark_attach_ABC005_part1}     parameter_list=${parameter_list_D005}
    ${wireshark_paging_ABC005_part1}    ${ABC005_bip_paging_part1}
    ...             _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_ABC005_part1}
    ...                                        tcpdump_collector_name=${ABC005_part1_wireshark_paging}
    ...                                        target_file_name=biplog_ABC005_paging_part1
    A_B_C_005_checkpoint    ABC005_bip_paging_part1=${ABC005_bip_paging_part1}
    ...                     wireshark_paging_ABC005_part1=${wireshark_paging_ABC005_part1}
    A_B_C_005_test_part2
    A_B_C_005_test_covery
    comment    --D011_test--
    sleep    60s
    ${wireshark_attach_D_001}     _UE_attach_and_enter_RRC_inactive    tcpdump_collector_name=${D_001_wireshark_attach}
    _check_rrc_inactivity_in_wireshark    file_path=${wireshark_attach_D_001}     parameter_list=${parameter_list_D005}
    ${wireshark_paging_D_001}    ${D_001_bip_paging}
    ...             _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_D_001}
    ...                                        tcpdump_collector_name=${D_001_wireshark_paging}
    ...                                        target_file_name=biplog_D_001_paging
    run keyword and continue on failure     check counters for D_001
    run keyword and continue on failure     D_001 check_logs     wireshark_attach_D001=${wireshark_attach_D001}
    ...                                                          wireshark_paging_D001=${wireshark_paging_D001}
    ...                                                          D_001_bip_paging=${D_001_bip_paging}
    [Teardown]     Run Keywords
    ...     SG3_12544_case_teardown
    ...     AND    Run Keyword And Ignore Error     A_101_modify_GNB3_output_configuration    Modify_Para_Online=${Modify_A_101_covery}
    ...     AND    Run Keyword And Ignore Error     Common Case TestLine Setup     is_commission_for_second_gnb=True
    ...                                                                            scf_path=${scf_path_12544}
    ...                                                                            golden_scf_name_gnb2=${scf_TL344_TRUNK}
