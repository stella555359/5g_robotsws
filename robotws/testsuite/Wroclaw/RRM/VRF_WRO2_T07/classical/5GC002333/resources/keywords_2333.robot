*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC002333

Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/specific_keywords.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002333/resources/test_specific_keywords.py  WITH NAME  2333_kw
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/keywords_723.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002333/resources/test_specific_keywords.py


*** Keywords ***
[1]5GC002333_K_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    Setup transition idle to connected for    scf_params=${scf_params_K_3}    bandwidth=20
    Test transition from idle to connected


[1]5GC002333_K_4_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    Setup transition idle to connected for    scf_params=${scf_params_K_4}    bandwidth=5
    Test transition from idle to connected


[1]5GC002333_K_5_RRC_connection_establishment_failure_in_gNB_CU_CP_RRC_Rejection
    ${original_scf_file}=   Setup and check preconditions in scf   params_to_check=${scf_params_K_5}    bandwidth=20
    AdminUtils.lock_all_cells_except_random_one
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Require Ue   UE_2   capabilities=REAL_ANDROID_UE
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_sctp_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    L1L2.start_gnbmirroring   filename=${test_name}.pcap

    Attach Ue    UE_1
    BuiltIn.Sleep   10s
    Attach UE   UE_2
    BuiltIn.Sleep   10s

    L1L2.stop_gnbmirroring_and_download_logs
    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Check gNB CU RRC rejection

    [Teardown]  Run Keywords
    ...         Detach UE    UE_1               AND
    ...         Detach UE    UE_2               AND
    ...         AdminUtils.unlock_all_cells     AND
    ...         AdminUtils.perform_commissioning   scf_file=${original_scf_file}    AND
    ...         AdminUtils.wait_for_all_cells_on_air_state


[1]5GC002333_J_1_RRC_connection_establishment_failure_in_gNB_DU_RRC_Rejection
    ${original_scf_file}=   Setup and check preconditions in scf   params_to_check=${scf_params_J_1}    bandwidth=20
    AdminUtils.lock_all_cells_except_random_one
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Require Ue   UE_2   capabilities=REAL_ANDROID_UE
    TcpdumpSmod.start_tcpdump_on_smod    filename=5GC002333_J_1_sctp_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    L1L2.start_gnbmirroring   filename=${test_name}.pcap

    Attach Ue    UE_1
    BuiltIn.Sleep   10s
    Run keyword and expect error  *CannotAttachError*   Attach UE   UE_2
    BuiltIn.Sleep   10s

    L1L2.stop_gnbmirroring_and_download_logs
    ${file_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Check gNB DU RRC rejection
    Check if release complete exists   ${file_path}
    Check if rrc reject exists         ${file_path}

    [Teardown]  Run Keywords
    ...         Detach UE    UE_1               AND
    ...         Detach UE    UE_2               AND
    ...         AdminUtils.unlock_all_cells     AND
    ...         AdminUtils.perform_commissioning   scf_file=${original_scf_file}    AND
    ...         AdminUtils.wait_for_all_cells_on_air_state


TC_teardown_2333
    TcpdumpSmod.teardown_tcpdump_on_smod
    Run keyword if test failed    AdminUtils.collect_snapshot
    stop_and_collect_btslog
