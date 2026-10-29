*** Settings ***
Documentation
...   author:
...   contact:

Library            ute_ue
Resource           ./resources/keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py

*** Variables ***
${UE_CAPABILITIES}      REAL_UE
${UE_ALIAS}             UE_1
${DT_ALIAS}             DT_DL_1
${TPUT_DURATION}        10s
${TPUT_BANDWITH}        100Mbits/sec
${TPUT_DEVIATION}       10%


*** Keywords ***
CB007877-HB_Max_Tput_with_CA_config_in_Scell_DRX_enabled_UL_overload_preventive_inter_frequency_HO_with_A1_threshold_based_FDD_Scell_addition
    [Documentation]   This test scenario describes maximum tput with CA configured to Pcell from Scell and the gNB behavior, when a UE,
    ...    for which FDD ? FDD carrier aggregation has been configured in addition to A1 measurement on FDD SCell in order to trigger UL
    ...    overload preventive inter -frequency handover with the configured FDD SCell as the target cell, sends an A1 measurement report
    ...    for FDD SCell and gNB performs intra-DU inter - frequency handover to the cell, which is currently configured as FDD SCell for
    ...    the UE. Handover is triggered in order to prevent UL overload on the PCell.
    Prepare attenuator
    Prepare preventive HO for 3CC
    Tcpdump.Start Tcpdump On SMOD   smod_slave=${FALSE}
    Require Ue                       UE_1   capabilities=UE_1
    Attach Ue                        UE_1
    Trigger Scell Addition
    Perform data transfer
    ...     dt_alias=${DT_ALIAS}
    ...     ue_alias=${UE_ALIAS}
    ...     direction=DL
    ...     duration=${TPUT_DURATION}
    ...     throughput=${TPUT_BANDWITH}
    ...     protocol=udp
    Trigger Better Conditions On Scell 3CC
    ${filename_path}=    Tcpdump.Stop tcpdump and download logs from SMOD
    Verify A1 Event Values RSRP    pcap_file=${filename_path}
    Verify 3CC    log_path=${filename_path}
    Verify HO
    ...    pcap_file=${filename_path}
    ...    phy_cell_id=56
    [Teardown]   Run Keywords
    ...          Test teardown                   AND
    ...          Deactivate PCellSwitch
