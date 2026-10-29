*** Settings ***
Documentation
...   author: Marta Irasiak-Gaciarek
...   contact: marta.irasiak-gaciarek@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB012669


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012669/resources/test_specific_keywords_669.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py


*** Variables ***
@{cells_to_be_locked}=        1    2    3    5    6    7    8    9
${pcap_name_on}=         on
${pcap_name_off}=        off
${number_of_deprio_PRB}       5
${max_prb_for verification}     88
${min_prb_for_verification}     72
${num_of_RBG}    14
${number_of_prio_RBG}     9
@{cells to modify for 669}    4
${ue_capabilities}        REAL_UE


*** Keywords ***
CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz
    ${pre_changed_scf}    Backup Current SCF
    Feature activation 669   ${cells to modify for 669}
    BuiltIn.Sleep                 5s
    AdminUtils.Lock Cells     ${cells_to_be_locked}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Require UE            UE_1   capabilities=${ue_capabilities}
    Attach And Throughput Start DL
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rnti}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Start logging BIP     ${pcap_name_on}
    Check data transfer is alive    dt_name=DT_DL
    BuiltIn.Sleep                 10s
    Stop logging BIP
    Stop data transfer    DT_DL
    Detach Ue  UE_1
    ${list_of_dict}    Check BIP logs      ${LOG_PATH}/CB012669_on_L1L2.pcap
    ${dict_per_cell}    Sort by cell id    ${list_of_dict}
    ${selected_msg}    Find Msg To Further Verification     ${dict_per_cell}
    ...         ${max_prb_for verification}   ${min_prb_for_verification}    ${rnti[0]}
    ${all_msg_on}  ${fully_allocated_msg_on}  Analyse bit map     ${selected_msg}     ${number_of_deprio_PRB}
    ...                                                           ${num_of_RBG}       ${number_of_prio_RBG}
    Check_randomization      ${dict_per_cell}   ${rnti[0]}     ${max_prb_for verification}
    AdminUtils.Unlock All Cells
    Log to Console     >>>>>>>>>>>> Verification with feature ON done <<<<<<<<<<<<<<<
    BuiltIn.Sleep    5s

    Feature deactivation 669      ${cells to modify for 669}
    BuiltIn.Sleep    5s
    AdminUtils.Lock Cells             ${cells_to_be_locked}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach And Throughput Start DL
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rnti}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Start logging BIP             ${pcap_name_off}
    Check data transfer is alive    dt_name=DT_DL
    BuiltIn.Sleep     10
    Stop logging BIP
    ${list_of_dict}    Check BIP logs        ${LOG_PATH}/CB012669_off_L1L2.pcap
    ${dict_per_cell}    sort_by_cell_id      ${list_of_dict}
    ${selected_msg}    Find Msg To Further Verification     ${dict_per_cell}
    ...         ${max_prb_for verification}   ${min_prb_for_verification}     ${rnti[0]}
    ${all_msg_off}  ${fully_allocated_msg_off}  Analyse bit map     ${selected_msg}     ${number_of_deprio_PRB}
    ...                                                             ${num_of_RBG}       ${number_of_prio_RBG}
    Check_randomization      ${dict_per_cell}    ${rnti[0]}    ${max_prb_for verification}
    Log to Console     >>>>>>>>>>>> Verification with feature OFF done <<<<<<<<<<<<<<<

    Final verification    ${all_msg_on}     ${all_msg_off}    ${fully_allocated_msg_on}      ${fully_allocated_msg_off}

    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          Run Keyword And Ignore Error    Stop logging BIP    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1     AND
    ...          Revert SCF                     ${pre_changed_scf}


CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz_pooling_off
    ${pre_changed_scf}    Backup Current SCF
    Feature activation 669 pooling off  ${cells to modify for 669}
    BuiltIn.Sleep                 5s
    AdminUtils.Lock Cells     ${cells_to_be_locked}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Require UE            UE_1   capabilities=${ue_capabilities}
    Attach And Throughput Start DL
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rnti}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Start logging BIP     ${pcap_name_on}
    Check data transfer is alive    dt_name=DT_DL
    BuiltIn.Sleep                 10s
    Stop logging BIP
    Stop data transfer    DT_DL
    Detach Ue  UE_1
    ${list_of_dict}    Check BIP logs      ${LOG_PATH}/CB012669_on_L1L2.pcap
    ${dict_per_cell}    Sort by cell id    ${list_of_dict}
    ${selected_msg}    Find Msg To Further Verification     ${dict_per_cell}
    ...         ${max_prb_for verification}   ${min_prb_for_verification}    ${rnti[0]}
    ${all_msg_on}  ${fully_allocated_msg_on}  Analyse bit map     ${selected_msg}     ${number_of_deprio_PRB}
    ...                                                           ${num_of_RBG}       ${number_of_prio_RBG}
    Check_randomization      ${dict_per_cell}   ${rnti[0]}     ${max_prb_for verification}
    AdminUtils.Unlock All Cells
    Log to Console     >>>>>>>>>>>> Verification with feature ON done <<<<<<<<<<<<<<<
    BuiltIn.Sleep    5s

    Feature deactivation 669      ${cells to modify for 669}
    BuiltIn.Sleep    5s
    AdminUtils.Lock Cells             ${cells_to_be_locked}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    Attach And Throughput Start DL
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rnti}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    Start logging BIP             ${pcap_name_off}
    Check data transfer is alive    dt_name=DT_DL
    BuiltIn.Sleep     10
    Stop logging BIP
    ${list_of_dict}    Check BIP logs        ${LOG_PATH}/CB012669_off_L1L2.pcap
    ${dict_per_cell}    sort_by_cell_id      ${list_of_dict}
    ${selected_msg}    Find Msg To Further Verification     ${dict_per_cell}
    ...         ${max_prb_for verification}   ${min_prb_for_verification}     ${rnti[0]}
    ${all_msg_off}  ${fully_allocated_msg_off}  Analyse bit map     ${selected_msg}     ${number_of_deprio_PRB}
    ...                                                             ${num_of_RBG}       ${number_of_prio_RBG}
    Check_randomization      ${dict_per_cell}    ${rnti[0]}    ${max_prb_for verification}
    Log to Console     >>>>>>>>>>>> Verification with feature OFF done <<<<<<<<<<<<<<<

    Final verification    ${all_msg_on}     ${all_msg_off}    ${fully_allocated_msg_on}      ${fully_allocated_msg_off}

    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          Run Keyword And Ignore Error    Stop logging BIP    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1     AND
    ...          Revert SCF                     ${pre_changed_scf}

############################# Other kewords #######################################


Attach And Throughput Start DL
    Attach UE    UE_1
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=1000s
    ...                   packet_size=1200            throughput=20 Mbits/sec         protocol=udp
    ...                   iperf_version=2
    Check_data_transfer_is_alive    dt_name=DT_DL
    Log to console      Tput transfer started
