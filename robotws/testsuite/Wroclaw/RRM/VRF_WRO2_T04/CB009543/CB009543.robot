*** Settings ***
Documentation
...   feature keywords

Library    ute_ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_collector.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009543/resources/keywords_9543.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009543/resources/keywords_9543.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007517/resources/keywords_7517_B.robot
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009543/resources/variables_9543.py

*** Keywords ***
CB009543_C1_IWK1_03_SA_EIRP_Counters_FDD_Supercell_subcell_switch_through_all_subcells
    Set Initial Attenuation For FDD Supercell Test
    &{base_counter_values}=     Get Scell Add Counter Values    ${ALL_COUNTERS_9543}
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}
    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=160Mbits/sec    duration=100s
    Start L1L2 Collection   l1l2_all_L1L2.pcap    1   cell_ids=6
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    Stop L1L2 Collection
    Verify DL Tput For Ue    ${MTK_UE}
    &{counters_values_all}=     Get Scell Add Counter Values    ${ALL_COUNTERS_9543}
    ${failed_counters_all}    Compare Counters    ${base_counter_values}[NRCELL-6]    ${counters_values_all}[NRCELL-6]
    Detach Ue    ${MTK_UE}
    Attenuate All Subcells

    counters.Wait For Pm Counters Interval
    Clear Attenuaton On Subcell    1
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}
    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=160Mbits/sec    duration=100s
    Start L1L2 Collection   l1l2_s1_L1L2.pcap    1   cell_ids=6
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    Stop L1L2 Collection
    Verify DL Tput For Ue    ${MTK_UE}
    Detach Ue    ${MTK_UE}
    &{counters_values_1}=     Get Scell Add Counter Values    ${ALL_COUNTERS_9543}
    &{failed_counters_1}    Compare Counters    ${base_counter_values}[NRCELL-6]    ${counters_values_1}[NRCELL-6]

    Attenuate Subcell    1
    counters.Wait For Pm Counters Interval
    Clear Attenuaton On Subcell    2    attenuation=10
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}
    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=160Mbits/sec    duration=100s
    Start L1L2 Collection   l1l2_s2_L1L2.pcap    1   cell_ids=6
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    Stop L1L2 Collection
    Verify DL Tput For Ue    ${MTK_UE}
    Detach Ue    ${MTK_UE}
    &{counters_values_2}=     Get Scell Add Counter Values    ${ALL_COUNTERS_9543}
    &{failed_counters_2}    Compare Counters    ${base_counter_values}[NRCELL-6]    ${counters_values_2}[NRCELL-6]

    Attenuate Subcell    2
    counters.Wait For Pm Counters Interval
    Clear Attenuaton On Subcell    3
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}
    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=160Mbits/sec    duration=100s
    Start L1L2 Collection   l1l2_s3_L1L2.pcap    1   cell_ids=6
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    Stop L1L2 Collection
    Verify DL Tput For Ue    ${MTK_UE}
    Detach Ue    ${MTK_UE}
    ${counters_values_3}=     Get Scell Add Counter Values    ${ALL_COUNTERS_9543}
    &{failed_counters_3}    Compare Counters    ${base_counter_values}[NRCELL-6]    ${counters_values_3}[NRCELL-6]
    Should Be Empty    ${failed_counters_all}  Some counters failed [all subcells]
    Should Be Empty    ${failed_counters_1}  Some counters failed [1st subcell]
    Should Be Empty    ${failed_counters_2}  Some counters failed [2nd subcell]
    Should Be Empty    ${failed_counters_3}  Some counters failed [3rd subcell]
    [Teardown]    Detach Ue    ${MTK_UE}

