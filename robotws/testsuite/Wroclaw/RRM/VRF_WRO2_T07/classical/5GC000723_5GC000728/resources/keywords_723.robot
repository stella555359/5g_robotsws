*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC000723

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000521/resources/verify.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME  TcpdumpSmod
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_bbmod.TcpdumpBbmod  WITH NAME  TcpdumpBbmod
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/connections.py   WITH NAME   wro_6_connections
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/bundle_unbundle.py
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/common_keywords.robot


*** Variables ***
${trafic_duration}=     60s
${tput}=                80Mbits/sec


*** Keywords ***
[1]5GC000723_H_1_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [Documentation]  The purpose of this test is to check if is possible successful transition
    ...              from RRC Idle to RRC Connected state.
    Setup transition idle to connected for    scf_params=${scf_params_H_1}   bandwidth=5
    Test transition from idle to connected


[1]5GC000723_H_2_5MHz_checking_if_actSACallProcessingDU_is_properly_handled_FALSE
    [Documentation]  The purpose of this test is to check if cellBarred is properly handled after set up NIDD parameter
    ...              actSACallProcessingDU to FALSE.
    ${original_scf_file}=   setup and check preconditions in scf   params_to_check=${scf_params_H_2}   bandwidth=5
    L1L2.start_gnbmirroring      filename=MIB
    BuiltIn.Sleep  5s   reason=Collecting L1L2 logs
    ${l1l2_pcap}=   L1L2.stop_gnbmirroring_and_download_logs
    Verify cellBarred in MIB information   ${l1l2_pcap}

    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Run keyword and expect error  *CannotAttachError*   Attach UE   UE_1

    [Teardown]   Run keywords
    ...          Run keyword and ignore error   Detach UE    UE_1                    AND
    ...          AdminUtils.perform_commissioning   scf_file=${original_scf_file}    AND
    ...          AdminUtils.wait_for_all_cells_on_air_state


[1]5GC000723_F_1_10MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    Setup transition idle to connected for    scf_params=${scf_params_F_1}   bandwidth=10
    Test transition from idle to connected


[1]5GC000723_F_2_15MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    Setup transition idle to connected for    scf_params=${scf_params_F_2}   bandwidth=15
    Lock all cells except random one
    Test transition from idle to connected
    [Teardown]   Unlock All Cells


[1]5GC000723_F_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    Setup transition idle to connected for    scf_params=${scf_params_F_3}   bandwidth=20
    Test transition from idle to connected


[1]5GC000723_E_2_ACK_for_Bundle_MSG4
    Setup and check preconditions in scf   params_to_check=${scf_params_E_2}    bandwidth=20
    ${cellsetup}    ${communication}   ${ng_pcap}    Run Bundle Unbundle Core Test
    Analyze bundle      ${cellsetup}    ${communication}


Start traffic and check UL DL
    [Arguments]   ${duration}=${trafic_duration}   ${dl_tput}=${tput}   ${ul_tput}=${tput}   ${protocol}=tcp
    Log to console   DL UL starting...
    Start Data Transfer   dt_name=DT_DL           ue_alias=UE_1
    ...                   direction=dl            duration=${duration}
    ...                   packet_size=1200        buffer=4M
    ...                   throughput=${dl_tput}   protocol=${protocol}
    Start Data Transfer   dt_name=DT_UL           ue_alias=UE_1
    ...                   buffer=4M
    ...                   direction=ul            duration=${duration}
    ...                   throughput=${ul_tput}   protocol=${protocol}
    BuiltIn.Sleep  30s  reason=Waiting for data transfer to be established
#    Check Data Transfer Is Alive  DT_DL
#    Check Data Transfer Is Alive  DT_UL
    Log to console  DL UL started..
    Await Data Transfer Finish  DT_DL
    Await Data Transfer Finish  DT_UL
    Log to console  DL UL finished.
    Verify Average Throughput With Deviation   DT_DL   ${dl_tput}   95%
    Verify Average Throughput With Deviation   DT_UL   ${ul_tput}   95%


Start and check DL throughput
    [Arguments]   ${duration}=${trafic_duration}   ${dl_tput}=${tput}    ${protocol}=tcp
    Log to console   DL starting...
    Start Data Transfer   dt_name=DT_DL           ue_alias=UE_1
    ...                   direction=dl            duration=${duration}
    ...                   packet_size=1200        buffer=4M
    ...                   throughput=${dl_tput}   protocol=${protocol}
    BuiltIn.Sleep  30s  reason=Waiting for data transfer to be established
#    Check Data Transfer Is Alive  DT_DL
    Log to console  DL started..

    Await Data Transfer Finish  DT_DL
    Log to console  DL finished.
    Verify Average Throughput With Deviation   DT_DL   ${dl_tput}   95%


Start and check UL throughput
    [Arguments]   ${duration}=${trafic_duration}   ${ul_tput}=${tput}   ${protocol}=tcp
    Log to console   UL starting...
    Start Data Transfer   dt_name=DT_UL           ue_alias=UE_1
    ...                   direction=ul            duration=${duration}
    ...                   buffer=4M
    ...                   throughput=${ul_tput}   protocol=${protocol}
    BuiltIn.Sleep  30s  reason=Waiting for data transfer to be established
#    Check Data Transfer Is Alive  DT_UL
    Log to console  UL started..
    Await Data Transfer Finish  DT_UL
    Log to console  UL finished.
    Verify Average Throughput With Deviation  DT_UL   ${ul_tput}   95%


Start pre-test throughput
    [Arguments]   ${duration}=40s   ${dl_tput}=${tput}   ${ul_tput}=${tput}   ${protocol}=tcp
    Log to console   ||| Pre-test troughput starting |||
    Start Data Transfer   dt_name=DT_DL           ue_alias=UE_1
    ...                   direction=dl            duration=${duration}
    ...                   packet_size=1200        buffer=4M
    ...                   throughput=${dl_tput}   protocol=${protocol}
    Start Data Transfer   dt_name=DT_UL           ue_alias=UE_1
    ...                   buffer=4M
    ...                   direction=ul            duration=${duration}
    ...                   throughput=${ul_tput}   protocol=${protocol}
    BuiltIn.Sleep   30s
    Run keyword and ignore error   Await Data Transfer Finish  DT_DL
    Run keyword and ignore error   Await Data Transfer Finish  DT_UL
    Log to console   ||| Pre-test troughput finished |||


Setup transition idle to connected for
    [Arguments]                            ${scf_params}    ${bandwidth}
    Setup and check preconditions in scf   params_to_check=${scf_params}    bandwidth=${bandwidth}
    Assign inactivity timer


Test transition from idle to connected
    [Arguments]   ${pcap_path}=${test_name}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    BuiltIn.Sleep  30s
    Start pre-test throughput
    TcpdumpSmod.start_tcpdump_on_smod    filename=idle_to_connected    smod_master=${true}    smod_slave=${tl.smod_slave}
    Start traffic and check UL DL
    ${start_time_UL_DL} =  get time from asik
    Wait till UE will entered idle state
    Start and check UL throughput
    ${start_time_UL} =  get time from asik
    Wait till UE will entered idle state
    Start and check DL throughput
    ${start_time_DL} =  get time from asik
    Wait till UE will entered idle state
    ${pcap_path}=  TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Check if UE goes to idle at correct time    ${pcap_path}   ${start_time_UL_DL}   0
    Check if UE goes to idle at correct time    ${pcap_path}   ${start_time_UL}   1
    Check if UE goes to idle at correct time    ${pcap_path}   ${start_time_DL}   2
    [Teardown]   Run keyword
    ...          Detach UE    UE_1


Run Bundle Unbundle Core Test
    ${communication_name}=    Set Variable   ${test_name}_comunication_l1l2.pcap
    ${cellsetup_name}=        Set Variable   ${test_name}_cellsetup_l1l2.pcap
    ${ng_pcap_name}=          Set Variable   ${test_name}_ng_pcap.pcap

    ### cell setup logs
    AdminUtils.trigger_site_reset
    AdminUtils.wait_for_all_bbmods_online_state
    TcpdumpBbmod.start_tcpdump_on_bbmod    filename=${cellsetup_name}    bbmod_master=${false}    bbmod_slave=${true}
    AdminUtils.wait_for_all_cells_on_air_state
    BuiltIn.Sleep   1s
    ${cellsetup}=   TcpdumpBbmod.stop_tcpdump_and_download_logs_from_bbmod

    ### prepare attach
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE

    ### capture rest of comunication
    TcpdumpSmod.start_tcpdump_on_smod    filename=${ng_pcap_name}    smod_master=${true}    smod_slave=${tl.smod_slave}
    L1L2.start_gnbmirroring              filename=${communication_name}
    BuiltIn.Sleep                        3s
    Attach Ue   UE_1
    BuiltIn.Sleep      5s
    ${communication}=      L1L2.stop_gnbmirroring_and_download_logs
    ${ng_pcap}=            TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    [Teardown]   Detach UE    UE_1
    [Return]    ${cellsetup}    ${communication}    ${ng_pcap}


TC_teardown_723
    TcpdumpSmod.teardown_tcpdump_on_smod
    Run keyword if test failed    AdminUtils.collect_snapshot
    stop_and_collect_btslog
