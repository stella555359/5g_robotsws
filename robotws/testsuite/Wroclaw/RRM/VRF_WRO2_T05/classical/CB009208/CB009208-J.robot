*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208.py    WITH NAME    CB009208

*** Variables ***
${ps_low_tput_dl_bandwith}         15 Kbits/sec
${ps_low_tput_ul_bandwith}         10 Kbits/sec
${ps_tput_bandwith}                10 MBits/sec
${ps_tput_duration}                900s
${ps_packet_size}                  170
${apn_name}                        internet
${ps_config}                       ${CURDIR}${/}resources${/}ps_configs${/}basic_config.csv
${resource_path_9208-J}            ${CURDIR}${/}resources

*** Keywords ***
CB009208-5G_6_Enable_and_disable_of_PRACH_format_0_in_TDD_FR1
    # CB009208.delta_commisioning    json_delta=CB009208-5G_6_PRACH
    # Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

    CB009208_kw.Load scf for NR 9208    ${resource_path_9208-J}    SCFs    CB009208-5G_6_PRACH.xml

    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${ps_config}

    Start New L1L2 Logs  suffix=prachSequenceTypeUnrestricted
    Start TTI trace streaming
    sleep  5s
    Attach Ue     UE_4
    sleep  30s
    Detach Ue     UE_4
    Stop TTI trace  decoded_output_file=prachSequenceTypeUnrestricted
    Stop New L1L2 Logs And Download PCAP  suffix=prachSequenceTypeUnrestricted
    Check rach based on ttitrace  decoded_output_file=prachSequenceTypeUnrestricted

    CB009208.Lock cell  501
    Wait until keyword succeeds    5 min    1 min    CB009208.Verify cell locked with admin  501
    CB009208.Set prachSequenceType on cell  501  RestrictedTypeA
    CB009208.Unlock cell  501
    Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

    Start New L1L2 Logs  suffix=prachSequenceTypeRestrictedTypeA
    Start TTI trace streaming
    Attach Ue     UE_4
    sleep  30s
    Detach Ue     UE_4
    Stop TTI trace  decoded_output_file=prachSequenceTypeRestrictedTypeA
    Stop New L1L2 Logs And Download PCAP  suffix=prachSequenceTypeRestrictedTypeA
    Check rach based on ttitrace  decoded_output_file=prachSequenceTypeRestrictedTypeA

    CB009208_kw.Verify PM Counters For PRACH

    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB009208-5G_10_Switch to power saving BWP and switch to large BWP with UL and DL tput increasing SA
    # CB009208.delta_commisioning    json_delta=CB009208-5G_10_MU_scheduling_v1.0_aka_power_saving
    # Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

    CB009208_kw.Load scf for NR 9208    ${resource_path_9208-J}    SCFs    CB009208-5G_10_Power_saving_BWP.xml

    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${ps_config}

    Attach Ue     UE_4

    Start Data Transfer  dt_name=DT_DL_SA_initial  ue_alias=UE_4  direction=dl  duration=${ps_tput_duration}
    ...                  throughput=${ps_low_tput_dl_bandwith}  protocol=udp  packet_size=${ps_packet_size}  #apn=${apn_name}
    Start Data Transfer  dt_name=DT_UL_SA_initial  ue_alias=UE_4  direction=ul  duration=${ps_tput_duration}
    ...                  throughput=${ps_low_tput_ul_bandwith}  protocol=udp  packet_size=${ps_packet_size}  #apn=${apn_name}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA_initial
    Check Data Transfer Is Alive               DT_UL_SA_initial

    Await Data Transfer Finish                 DT_DL_SA_initial
    Await Data Transfer Finish                 DT_UL_SA_initial

    CB009208_kw.Verify PM Counters For Power Saving Step 1

    Start Data Transfer  dt_name=DT_DL_SA_final  ue_alias=UE_4  direction=dl  duration=${ps_tput_duration}
    ...                  throughput=${ps_tput_bandwith}  protocol=udp  packet_size=${ps_packet_size}  #apn=${apn_name}
    Start Data Transfer  dt_name=DT_UL_SA_final  ue_alias=UE_4  direction=ul  duration=${ps_tput_duration}
    ...                  throughput=${ps_tput_bandwith}  protocol=udp  packet_size=${ps_packet_size}  #apn=${apn_name}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA_final
    Check Data Transfer Is Alive               DT_UL_SA_final

    Await Data Transfer Finish                 DT_DL_SA_final
    Await Data Transfer Finish                 DT_UL_SA_final

    CB009208_kw.Verify PM Counters For Power Saving Step 2

    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter