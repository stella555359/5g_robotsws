*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB012544 FDD

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012544_FDD/Resources/CB012544_SG3_case_step_cloud_vm.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


Suite Setup         Run Keywords     CB012544_FDD_suite_setup_CLOUD_VM
...                  AND             _prepare_argument_for_12544    gnb_index=${0}
...                                                                 golden_scf=SCF_${stream}.xml
...                                                                 amf_id=${1}
...                                                                 scf_path=${Golden_SCF_Path}

Suite Teardown      CB012544_FDD_suite_teardown_CLOUD_VM


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
${attach_WA_log}                     M60_attach_WA_log.pcap
${enter_idle_WA}                     M60_enter_idle_WA_log.pcap
${enter_rrcinactive_WA}              M60_enter_rrcinactive_WA_log.pcap
${idle_status}                 idle: 1
@{parameter_list_D005}         ranEdrxPagingCycle
@{drxDefaultPaging}            drxDefaultPaging
@{12544_allow_fault_list_VM}     7107    4681    4405    4404    4153    4001    7319    7300    4452    1898    49
${ue_type_MTK60_VM}            ${tl.ues[4].capabilities[1]}


*** Test Cases ***
[1]CB012544_C_001_Core_Network_Paging_for_UE_rrc_idle_with_eDRX_configuration_and_eDRX_Cycle_not_greater_than_10.24s
    [Documentation]
    ...    cover CB012544_A_B_001; CB012544_B_102; CB012544_C_102; CB012544_C_103; CB012544_C_104; CB012544_A_101; CB012544_A102
    ...    UE:RRC_IDLE
    ...    real core network
    ...    actEdrx=idle
    [Tags]    C_001
    [Setup]
    SG3_12544_case_setup_cloud_vm
    ...                          online_ModifySCF=True
    ...                          Modify_Para_Online=${Modify_C_001_VM}
    B_102 set_actEdrx and check_sib for C001 VM
    comment    --A_101_test--
    A_101_test_VM
    comment    --C_001_test--
    MTK60 prepare UE for VM    ue_index=${4}    ue_type=${ue_type_MTK60_VM}
    ${wireshark_attach_C001}     _UE_attach_and_enter_idle_VM    tcpdump_collector_name=${C_001_wireshark_attach}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C001}
    ${wireshark_paging_C001}     ${C_001_bip_paging}
    ...     _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_C001}
    ...                                           tcpdump_collector_name=${C_001_wireshark_paging}
    ...                                           target_file_name=C_001_BIP_paging
    check counters for C_001 VM
    C_001 check_logs vm     wireshark_attach_C001=${wireshark_attach_C001}      wireshark_paging_C001=${wireshark_paging_C001}
    ...                     C_001_bip_paging=${C_001_bip_paging}
    comment    --12544_A_102_test--
    A_102_test_VM
    [Teardown]     Run Keywords
    ...     Run Keyword And Ignore Error    change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    ...     AND    SG3_12544_case_teardown_VM
    ...     AND    Run Keyword And Ignore Error     Common Case TestLine Setup     ModifySCF_Beforecommission=True
    ...                            scf_dir_path=${SUITE_LOG_PATH}
    ...                            scf_path=${Golden_SCF_Path}
    ...                            golden_scf_name=SCF_${stream}.xml
    ...                            ParameterToDelete=${delete_for_FDD}
    ...                            ParamterToModify=${modify_for_FDD}
    ...                            ListToAdd=${addlist_for_FDD}


[1]CB012544_C_003_CN_Paging_for_UE_rrc_idle_with_eDRX_configuration_and_eDRX_Cycle_greater_than_10.24s_and_without_NR_Paging_Time_Window
    [Documentation]
    ...    cover CB012544_A_B_004; CB012544_A_B_006; CB012544_D_201; CB012544_D_202; CB012544_D_002; CB012544_D_003; CB012544_A_B_002
    ...    UE:RRC_IDLE
    ...    real core network
    ...    actEdrx=idle+inactive
    [Tags]    C_003
    [Setup]
    SG3_12544_case_setup_cloud_vm
    ...                      online_ModifySCF=True
    ...                      Modify_Para_Online=${Modify_D_002_VM}
    ...                      Delete_Para_Online=${Delete_Para_D_002_VM}
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Delete_Mo_Online=${Delete_Mo_D_002_VM}
    ####D002_step####
    comment    --D002_test--
    MTK60 prepare UE for VM        ue_index=${4}    ue_type=${ue_type_MTK60_VM}
    ${wireshark_attach_D002}     _UE_attach_and_enter_RRC_inactive_VM    tcpdump_collector_name=${D_002_wireshark_attach}
    _check_rrc_inactivity_in_wireshark    gnb_index=${0}
    ...                file_path=${wireshark_attach_D002}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    ...                dist_name=MRBTS-${global_bts_ID}/NRBTS-${MRBTS_ID}
    ${wireshark_paging_D002}     ${D_002_bip_paging}
    ...     _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_D002}
    ...                                           tcpdump_collector_name=${D_002_wireshark_paging}
    ...                                           target_file_name=D_002_BIP_paging
    run keyword and continue on failure     check counters for D_002 vm
    run keyword and continue on failure     D_002_check_logs_VM    wireshark_paging_D002=${wireshark_paging_D002}
    comment    -- A_B_002_test--
    A_B_002_test_part1_VM
    A_B_002_test_part2_VM
    comment    --C003_test--
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Modify_C_003_VM}
#    Adjust the HBTE attenuation value for cloud vm    gnb_cell3_value=${10}
    ${wireshark_attach_C003}    _UE_attach_and_enter_idle_VM    tcpdump_collector_name=${C_003_wireshark_attach}    sleep_time=90s
    ...                                                         mtk_timeout=${120}
    _check_rrc_inactivity_in_wireshark    gnb_index=${0}
    ...                file_path=${wireshark_attach_C003}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    ...                dist_name=MRBTS-${global_bts_ID}/NRBTS-${MRBTS_ID}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_C003}
    ${wireshark_paging_C003}     ${C_003_bip_paging}
    ...     _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_C003}
    ...                                           tcpdump_collector_name=${C_003_wireshark_paging}
    ...                                           target_file_name=C_003_BIP_paging
    run keyword and continue on failure     check counters for C_003 VM
    run keyword and continue on failure     C_003_check_logs_VM     C_003_bip_paging=${C_003_bip_paging}
    ...                                                             wireshark_paging_C003=${wireshark_paging_C003}
    [Teardown]      Run Keywords
    ...     SG3_12544_case_teardown_VM
    ...     AND    Run Keyword And Ignore Error     Common Case TestLine Setup     ModifySCF_Beforecommission=True
    ...                            scf_dir_path=${SUITE_LOG_PATH}
    ...                            scf_path=${Golden_SCF_Path}
    ...                            golden_scf_name=SCF_${stream}.xml
    ...                            ParameterToDelete=${delete_for_FDD}
    ...                            ParamterToModify=${modify_for_FDD}
    ...                            ListToAdd=${addlist_for_FDD}


[1]CB012544_D_001_Successful_RAN_paging_for_UE_in_RRC_INACTIVE_edrx_Cycel_Tedrx_CN_not_greater_than_10.24s
    [Documentation]
    ...    cover: CB012544_D_001. CB012544_UPD001.UE:RRC_INACTIVE; CB012544_A_B_C_005
    ...    airphone
    ...    actEdrx=idle+inactive
    [Tags]    D_001
    [Setup]
    SG3_12544_case_setup_cloud_vm
    ...                              online_ModifySCF=True
    ...                              Modify_Para_Online=${Modify_D_001_VM}
    ...                              Delete_Mo_Online=${Delete_NTP_Mo_VM}
    comment    --A_B_C_005_test--
    A_B_C_005_test_part1_VM
    MTK60 prepare UE for VM        ue_index=${4}    ue_type=${ue_type_MTK60_VM}
    ${wireshark_attach_ABC005_part1}     _UE_attach_and_enter_RRC_inactive_VM    tcpdump_collector_name=${ABC005_part1_wireshark_attach}
    _check_rrc_inactivity_in_wireshark    gnb_index=${0}
    ...                file_path=${wireshark_attach_ABC005_part1}     parameter_list=${parameter_list_D005}
    ...                dist_name=MRBTS-${global_bts_ID}/NRBTS-${MRBTS_ID}
    ${wireshark_paging_ABC005_part1}    ${ABC005_bip_paging_part1}
    ...             _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_ABC005_part1}
    ...                                        tcpdump_collector_name=${ABC005_part1_wireshark_paging}
    ...                                        target_file_name=biplog_ABC005_paging_part1
    A_B_C_005_checkpoint_VM    ABC005_bip_paging_part1=${ABC005_bip_paging_part1}
    ...                        wireshark_paging_ABC005_part1=${wireshark_paging_ABC005_part1}
    A_B_C_005_test_part2_VM
    A_B_C_005_test_covery_VM
    comment    --D011_test--
    sleep    60s
    ${wireshark_attach_D_001}     _UE_attach_and_enter_RRC_inactive_VM    tcpdump_collector_name=${D_001_wireshark_attach}
    _check_rrc_inactivity_in_wireshark    file_path=${wireshark_attach_D_001}     parameter_list=${parameter_list_D005}
    ...            gnb_index=${0}    dist_name=MRBTS-${global_bts_ID}/NRBTS-${MRBTS_ID}
    ${wireshark_paging_D_001}    ${D_001_bip_paging}
    ...             _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_D_001}
    ...                                        tcpdump_collector_name=${D_001_wireshark_paging}
    ...                                        target_file_name=biplog_D_001_paging
    run keyword and continue on failure     check counters for D_001 VM
    run keyword and continue on failure     D_001 check_logs VM     wireshark_attach_D001=${wireshark_attach_D001}
    ...                                                          wireshark_paging_D001=${wireshark_paging_D001}
    ...                                                          D_001_bip_paging=${D_001_bip_paging}
    [Teardown]     Run Keywords
    ...     run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}
    ...     AND    Run Keyword And Ignore Error    change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    ...     AND    SG3_12544_case_teardown_VM
    ...     AND    Run Keyword And Ignore Error     Common Case TestLine Setup     is_commission=True
    ...                                                                            scf_path=${Golden_SCF_Path}
    ...                                                                            golden_scf_name=SCF_${stream}.xml
