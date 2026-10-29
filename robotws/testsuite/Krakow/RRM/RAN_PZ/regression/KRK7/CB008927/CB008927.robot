*** Settings ***
Documentation
...    Test suite for regression testing for feature CB008927
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Resource    resources/keywords.robot

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...            list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}
...            swconfig_from_path=testsuite/Krakow/RRM/RAN_PZ/regression/KRK7/CB008927/resources/swconfig.txt
...            prefix_tag=CB008927
...            increase_time_for_checking_cells=1800
Suite Teardown    Common Suite Teardown
Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                       AND    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
@{ADDITIONAL_ALLOWED_ALARMS}    Wifi Client Connected    Wifi Enabled Alarm
@{CUSTOM_ALLOWED_ALARMS}    Cell blocked
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${UE_DEFAULT_ALIAS_NAME}    UE
${DATA_TRANSFER_DEFAULT_DURATION}    120s
${DEFAULT_PACKET_SIZE}    1380
${DEFAULT_PROTOCOL}    tcp
${DEFAULT_DEVIATION}    20%
${pcap_capture_filter}    'sctp and (port 36412 or port 36472 or port 36462 or port 36422)'
@{CELL_ALL_PORTS}   ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
              ...   ${9}    ${10}   ${11}   ${12}   ${13}   ${14}   ${15}   ${16}


*** Test Cases ***
[1]CB008927_01_A_Verify_Feature_Activation_and_Deactivation_for_RAT1_resource_allocation_on_FR1_FDD_SA_should_be_successful
    [Tags]    T01
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_ID}
    bipcollector.Start Bip Trace Log Capturing
    ${executor}=    Create Dictionary    host=192.168.255.1
    ...                                  user=toor4nsn
    ...                                  password=oZPS0POrRieRtu
    sg7keywords.Block cells    [11,13]
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actRat1Alloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-13
    ...                                            parameter=actRat1Alloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=30dB     db_level_lte=30dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}
    tcpdump.Create Tcpdump Collector    name=tcpdump
    ...                                 options=-i any -C 100 -vv ${pcap_capture_filter}
    ...                                 executor=${executor}
    core.Setup Collectors    names=tcpdump
    core.Start Collectors    names=tcpdump
    Check data transfer with Mediatek With Block And Unblock Cell    throughput_DL=550 Mbits/sec
    ...                                                              throughput_UL=170 Mbits/sec
    ...                                                              cell_block=12
    ...                                                              cell_unblock=13
    ...                                                              desired_pci=12
    core.Stop Collectors    names=tcpdump
    core.Collect Collectors    names=tcpdump    target_dir=${OUTPUT_DIR}/Test_Case_T01
    core.Teardown Collectors    names=tcpdump
    bipcollector.Stop Bip Trace Log Capturing
    bipcollector.Download Bip Logs    download_dir=${OUTPUT_DIR}/Test_Case_T01
    @{expected_pcap_result}    Create List    1    1
    Check ResourceAllocation Field Value In Pcap File    result_dir=${OUTPUT_DIR}/Test_Case_T01
    ...                                                  expected_result_list=@{expected_pcap_result}
    ...                                                  time_epoch_no=${1}
    ...                                                  additional_options=-c 1
    Check ResourceAllocation Field Value In Pcap File    result_dir=${OUTPUT_DIR}/Test_Case_T01
    ...                                                  expected_result_list=@{expected_pcap_result}
    ...                                                  time_epoch_no=${2}
    ...                                                  additional_options=-c 1
    @{expected_bip_result}    Create List    ${empty}
    Check Rat0Bitmap Filed Value In Bip Logs    result_dir=${OUTPUT_DIR}/Test_Case_T01
    ...                                         expected_result_list=@{expected_bip_result}
    [Teardown]    Teardown_01_A


[1]CB008927_13_L_Check_single_UE_peak_throughput_with_FDD_actDlDynSwitchAlloc_activation
    [Tags]    T02
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_ID}
    ${executor}=    Create Dictionary    host=192.168.255.1
    ...                                  user=toor4nsn
    ...                                  password=oZPS0POrRieRtu
    tcpdump.Create Tcpdump Collector    name=tcpdump
    ...                                     options=-i any -C 100 -vv ${pcap_capture_filter}
    ...                                     executor=${executor}
    sg7keywords.Block cells    [12,13]
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=5
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=30dB     db_level_lte=30dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}

    ${ul_dl_tput_1}=    Get data transfer with Mediatek    throughput_DL=550 Mbits/sec
    ...                                                    throughput_UL=170 Mbits/sec
    ...                                                    desired_pci=11
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-11
    ...                                            parameter=actRat1Alloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-11
    ...                                            parameter=actDlDynSwitchAlloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    gnbbbu.Wait For Site To Be Onair
    core.Setup Collectors    names=tcpdump
    core.Start Collectors    names=tcpdump
    ${ul_dl_tput_2}=    Get data transfer with Mediatek    throughput_DL=550 Mbits/sec
    ...                                                    throughput_UL=170 Mbits/sec
    ...                                                    desired_pci=11
    core.Stop Collectors    names=tcpdump
    core.Collect Collectors    names=tcpdump    target_dir=${OUTPUT_DIR}/Test_Case_T13
    core.Teardown Collectors    names=tcpdump
    @{expected_pcap_result}    Create List    1    1
    Check ResourceAllocation Field Value In Pcap File    result_dir=${OUTPUT_DIR}/Test_Case_T13
    ...                                                  expected_result_list=@{expected_pcap_result}
    ...                                                  time_epoch_no=${1}
    ...                                                  additional_options=-c 1
    tools.Compare Tput    before_tput=${ul_dl_tput_1}    after_tput=${ul_dl_tput_2}
    [Teardown]    Teardown_13_L


[1]CB008927_17_Exploratory_Verify_ single UE peak throughput with FDD actDlDynSwitchAlloc activation_on_ASiR_SFN_configuration
    [Tags]    T03
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_ID}
    ${executor}=    Create Dictionary    host=192.168.255.1
    ...                                  user=toor4nsn
    ...                                  password=oZPS0POrRieRtu
    tcpdump.Create Lxc Tcpdump Collector    name=tcpdump
    ...                                     options=-i any -C 100
    ...                                     executor=${executor}
    ...                                     container=CPIF
    sg7keywords.Block cells    [11,13]
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=30dB     db_level_lte=30dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}
    ${ul_dl_tput_1}=    Get data transfer with Mediatek    throughput_DL=100 Mbits/sec
    ...                                                    throughput_UL=60 Mbits/sec
    ...                                                    desired_pci=12
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actRat1Alloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actDlDynSwitchAlloc
    ...                                            value=true
    Perform Delta Commissioning On gNB    delta=${delta}
    gnbbbu.Wait For Site To Be Onair
    core.Setup Collectors    names=tcpdump
    core.Start Collectors    names=tcpdump
    ${ul_dl_tput_2}=   Get data transfer with Mediatek    throughput_DL=100 Mbits/sec
    ...                                                   throughput_UL=60 Mbits/sec
    ...                                                   desired_pci=12
    core.Stop Collectors    names=tcpdump
    core.Collect Collectors    names=tcpdump    target_dir=${OUTPUT_DIR}/Test_Case_T17
    core.Teardown Collectors    names=tcpdump
    @{expected_pcap_result}    Create List    1    1
    Check ResourceAllocation Field Value In Pcap File    result_dir=${OUTPUT_DIR}/Test_Case_T17
    ...                                                  expected_result_list=@{expected_pcap_result}
    ...                                                  time_epoch_no=${1}
    ...                                                  additional_options=-c 1
    tools.Compare Tput    before_tput=${ul_dl_tput_1}    after_tput=${ul_dl_tput_2}
    [Teardown]    Teardown_17_E
