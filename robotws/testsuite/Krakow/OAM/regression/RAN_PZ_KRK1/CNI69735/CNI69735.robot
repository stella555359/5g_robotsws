*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-69735 CRT
...   author: Klaudia Krzych
...   contact: klaudia.krzych@nokia.com


Library         taf.rfrl.bts.devices.du.commissioning.EnbCommissioning              WITH NAME   enb_conf
Library         taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations      WITH NAME   asir
Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations               WITH NAME   gnb_du
Library         taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations           WITH NAME   ru_op
Library         testsuite/Krakow/resources/delta/bts_delta_generator.py
Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        testsuite/Krakow/resources/asir/asir_common_keywords.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       ./resources/deltas.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms


*** Variables ***
@{tc15_barred_cells}    0  1  2
@{tc16_barred_cells}    0  2  3
@{tc28_barred_cells}    1  3
@{tc38_barred_cells}    0  2  3
@{tc39_barred_cells}    0  1  2
#   Call variables
${duration}             90s
${protocol}             udp
${deviation}            30%
${deviation_TC15_TC16}  47%
${buffer_server}        4M
${buffer_client}        4M
${size_packet}          1470B
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}


*** Test Cases ***
[1]CNI-69735-A_TC05_Block_unblock_FDD_TDD_Nrcells_from_WebEM
    Lock All Cells
    Verify All Cell Status    cell_status=Disabled
    Unlock All Cells
    Wait Until Keyword Succeeds    60s   10s    Verify All Cell Status

[1]CNI-69735-A_TC15_UDP_UL_64QAM_15MHz_on_CPRI_FDD_Nrcell
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No X2 link available   No X2 link available for a specific LTEENB
    ...         AND
    ...         Common Preconditions With Watching Alarms and enb cells set to barred  cells=${tc15_barred_cells}
    gnb_scf.Perform Delta Commissioning On gNB  delta=${delta_bw15}
    Wait until keyword succeeds    600 sec    60 sec    asir.Verify Status of All Asir Cells is Operational
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL      duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     tput_dl=200 Mbits/sec
    ...                                     tput_ul=80 Mbits/sec
    ...                                     deviation=${deviation_TC15_TC16}
    ...                                     buffer_client_dl=${buffer_client}
    ...                                     buffer_server_dl=${buffer_server}
    ...                                     buffer_client_ul=${buffer_client}
    ...                                     buffer_server_ul=${buffer_server}
    ...                                     size_packet=${size_packet}
    [Teardown]   Run Keywords
    ...     gnb_scf.Perform Delta Commissioning On gNB  delta=${delta_bw20}
    ...     AND
    ...     Wait Until Keyword Succeeds    600 sec    60 sec        asir.Verify Status of All Asir Cells is Operational
    ...     AND
    ...     Common Postconditions With Watching Alarms and enb cells set to unbarred  cells=${tc15_barred_cells}

[1]CNI-69735-A_TC16_UDP_UL_64QAM_100MHz_on_eCPRI_TDD_Nrcell
    [Setup]     Common Preconditions With Watching Alarms and enb cells set to barred  cells=${tc16_barred_cells}
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL      duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     tput_dl=1150 Mbits/sec
    ...                                     tput_ul=140 Mbits/sec
    ...                                     deviation=${deviation_TC15_TC16}
    ...                                     buffer_client_dl=${buffer_client}
    ...                                     buffer_server_dl=${buffer_server}
    ...                                     buffer_client_ul=${buffer_client}
    ...                                     buffer_server_ul=${buffer_server}
    ...                                     size_packet=${size_packet}
    [Teardown]    Common Postconditions With Watching Alarms and enb cells set to unbarred  cells=${tc16_barred_cells}

[1]CNI-69735-A_TC28_Cells_setup_with_mix_bandwidth_using_LTE_NR_FDD_RFsharing_and_eCPRI_TDD_on_multiple_ABIO_Gen3_DSS_CALL
    [Setup]     Common Preconditions With Watching Alarms and enb cells set to barred  cells=${tc28_barred_cells}
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL      duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     tput_dl=110 Mbits/sec
    ...                                     tput_ul=30 Mbits/sec
    ...                                     deviation=${deviation}
    ...                                     buffer_client_dl=${buffer_client}
    ...                                     buffer_server_dl=${buffer_server}
    ...                                     buffer_client_ul=${buffer_client}
    ...                                     buffer_server_ul=${buffer_server}
    ...                                     size_packet=${size_packet}
    [Teardown]    Common Postconditions With Watching Alarms and enb cells set to unbarred  cells=${tc28_barred_cells}

[1]CNI-69735-A_TC38_UDP_CALL_TDDNRCELL_60_50_or_60_30
    [Setup]     Run Keywords  Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No X2 link available   No X2 link available for a specific LTEENB
    ...         AND
    ...         Common Preconditions With Watching Alarms and enb cells set to barred  cells=${tc38_barred_cells}
    gnb_scf.Perform Delta Commissioning On gNB    delta=${delta_bw60}
    Wait Until Keyword Succeeds    600 sec    60 sec        asir.Verify Status of All Asir Cells is Operational
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL      duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     tput_dl=900 Mbits/sec
    ...                                     tput_ul=90 Mbits/sec
    ...                                     deviation=${deviation}
    ...                                     buffer_client_dl=${buffer_client}
    ...                                     buffer_server_dl=${buffer_server}
    ...                                     buffer_client_ul=${buffer_client}
    ...                                     buffer_server_ul=${buffer_server}
    ...                                     size_packet=${size_packet}
    [Teardown]    Run Keywords
    ...           gnb_scf.Perform Delta Commissioning On gNB   delta=${delta_bw100}
    ...           AND
    ...           Wait Until Keyword Succeeds    600 sec    60 sec    asir.Verify Status of All Asir Cells is Operational
    ...           AND
    ...           Common Postconditions With Watching Alarms and enb cells set to unbarred  cells=${tc38_barred_cells}

[1]CNI-69735-A_TC39_UDP_CALL_FDDNRCEL_20MHz_256QAM
    [Setup]     Common Preconditions With Watching Alarms and enb cells set to barred  cells=${tc39_barred_cells}
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL      duration=${duration}    protocol=${protocol}    tput_dl=210 Mbits/sec
    ...                                     tput_ul=100 Mbits/sec    deviation=${deviation}    buffer_client_dl=${buffer_client}
    ...                                     buffer_server_dl=${buffer_server}    buffer_client_ul=${buffer_client}
    ...                                     buffer_server_ul=${buffer_server}    size_packet=${size_packet}
    [Teardown]    Common Postconditions With Watching Alarms and enb cells set to unbarred  cells=${tc39_barred_cells}


*** Keywords ***
Common Preconditions With Watching Alarms and enb cells set to barred
    [Arguments]    ${cells}
    Common Preconditions With Watching Alarms
    ${delta}  Generate Delta for barred LNCELLs  cells=${cells}
    enb_conf.perform_bts_delta_commissioning    delta=${delta}

Common Postconditions With Watching Alarms and enb cells set to unbarred
    [Arguments]    ${cells}
    Common Postconditions With Watching Alarms
    ${delta}  Generate Delta for not barred LNCELLs  cells=${cells}
    enb_conf.perform_bts_delta_commissioning    delta=${delta}
