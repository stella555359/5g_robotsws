*** Settings ***
Resource           ./Resources/CB007723_keywords.robot

Documentation    Suite description
...   author: wang liya
...   contact: liya.wang@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature CB007723
...   migrated to krk by klaudia.horyn@nokia.com

Suite Setup    Suite Setup

*** Test Cases ***
[1]CB007723-A-0101-PRACH_format_B4_4cc_2GPSymbols_regularCellOnly
    [Documentation]    Author: wang liya
    ...    check prach format B4 in regular and extend cell
    ...    immediatel without any alarm or service interruption.
    [Setup]    Run Keywords    Test Setup    scf_prefix_tag=CB007723
    ...        AND             Perform Delta Commissioning On gNB    delta=${delta}    timeout=600

    Perform Delta Commissioning On gNB    delta=${delta_prachConfigurationIndex_136}    timeout=600
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir
    Attach UE    desired_5g_cell_pci=${abstract_lib_config.CELLS.GNB1.CELL1.PCI}
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=20 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=20
    Check SSB And CSI-RS From X2 Log    pcap_file=${pcap_name}
    ue.Detach Ue    UE_1

    [Teardown]    Common Test Teardown

[1]CB007723-B-0110-4CC-Random_Access_by_UE_to_multiple_cells_configuration_with_mixed_GP_symbols
    [Documentation]    Author: wang liya
    ...    check different GP attach for B4 format
    ...    immediatel without any alarm or service interruption.
    [Setup]    Test Setup    scf_prefix_tag=CB007723

    Perform Delta Commissioning On gNB    delta=${delta_B_0110_gp_10Symbols}    timeout=600
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir
    Attach UE    desired_5g_cell_pci=${abstract_lib_config.CELLS.GNB1.CELL1.PCI}
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=20 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=20
    Check SSB And CSI-RS From X2 Log    pcap_file=${pcap_name}    csi-rs-list=87    ssb='ff:00:00:ff:ff:00:00:ff'
    ue.Detach Ue    UE_1

    Specify NR Cell For Dual Connectivity    lnrelgnbcell_instance=2
    Perform Delta Commissioning On gNB    delta=${delta_B_0110_gp_6Symbols}    timeout=600
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir
    Attach UE    desired_5g_cell_pci=${abstract_lib_config.CELLS.GNB1.CELL2.PCI}
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=20 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=20
    Check SSB And CSI-RS From X2 Log    pcap_file=${pcap_name}    csi-rs-list=87    ssb='ff:00:00:ff:ff:00:00:ff'
    ue.Detach Ue    UE_1

    [Teardown]    Run Keywords    Specify NR Cell For Dual Connectivity    lnrelgnbcell_instance=1
    ...           AND             Common Test Teardown

[1]CB007723-C-0105-4CC-Cells_configurations_with_mixed_range_and_different_GP_symbols
    [Documentation]    Author: wang liya
    ...    check different GP adn different range attach for B4 format
    ...    immediatel without any alarm or service interruption.
    [Setup]    Test Setup    scf_prefix_tag=CB007723

    Specify NR Cell For Dual Connectivity    lnrelgnbcell_instance=3
    Perform Delta Commissioning On gNB    delta=${delta_C_0105}    timeout=600
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir
    Attach UE    desired_5g_cell_pci=${abstract_lib_config.CELLS.GNB1.CELL11.PCI}
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=20 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=20
    Check SSB And CSI-RS From X2 Log    pcap_file=${pcap_name}    csi-rs-list=87    ssb='ff:00:00:ff:ff:00:00:ff'
    ue.Detach Ue    UE_1

    Specify NR Cell For Dual Connectivity    lnrelgnbcell_instance=4
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir
    Attach UE    desired_5g_cell_pci=${abstract_lib_config.CELLS.GNB1.CELL12.PCI}
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=20 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=20
    Check SSB And CSI-RS From X2 Log    pcap_file=${pcap_name}    csi-rs-list=87    ssb='ff:00:00:ff:ff:00:00:ff'
    ue.Detach Ue    UE_1

    [Teardown]    Run Keywords    Specify NR Cell For Dual Connectivity    lnrelgnbcell_instance=1
    ...           AND             Common Test Teardown
