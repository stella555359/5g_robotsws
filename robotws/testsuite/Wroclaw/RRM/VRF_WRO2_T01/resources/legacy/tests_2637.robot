*** Settings ***
Documentation
...  Author:        Mateusz Cieciura, Maciej Cupial
...  Contact:       mateusz.cieciura@nokia.com, maciej.cupial@nokia.com
...  Maintainer:    mateusz.cieciura@nokia.com, maciej.cupial@nokia.com
...  Description:   The feature introduces UE throughput counters and additions to cell throughput counters.
...                 The following user plane counters are going to be introduced in 5GC002736 feature:
...                 Classical gNB downlink/uplink throughput per bearer (cell level):
...                 DL at PDCP cell level (considering the LTE throughput in case of EN-DC).
...                 Both average and maximum throughputs will be counted,
...                 UL at RLC cell level according to 28.552. Both average and maximum throughputs will be counted
...                 Supplementary cell level PM counters for DL/UL MAC throughput:
...                 Accumulated number of slots with DL data buffered,
...                 Accumulated number of slots with UL data buffered,
...                 Accumulated number of UEs in DRX-sleep state with DL DRB data buffered
...                 MAX cell level UL/DL DTCH throughput in MAC layer:
...                 MAX DL DTCH throughput in MAC layer,
...                 MAX UL DTCH throughput in MAC layer

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_2637.robot
#Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Library         taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
@{SINGLE_UE}                  UE_1
@{MULTI_UE}                   UE_1  UE_2
${GNB_CONNECTION_ALIAS}       gNB
${ENB_CONNECTION_ALIAS}       eNB
${THROUGHPUT}                 800Mbits/sec
${DATA_TRANSFER_LONG}         11min
${DATA_TRANSFER_SHORT}        30s
${WAIT_IN_CA_TC}              270s
@{DL_TPUT_COUNTERS}           M55309C12001  M55309C01001
@{UL_TPUT_COUNTERS}           M55309C12002  M55309C02001
@{DRX_COUNTERS}               M55308C26001  M55308C26002  M55308C27001
@{NSA_TC_TPUT_COUNTERS}       M55350C06001  M55350C04001  M55350C02001
@{CA_TPUT_COUNTERS}           M55350C04001  M55349C02001  M55350C03009  M55349C01009  M55350C00009  M55349C00009
@{CA_AV_TPUT_IPERF_COUNTERS}  M55350C04001  M55349C02001
@{CA_DATA_IPERF_COUNTERS}     M55350C03009  M55349C01009
@{CA_TIME_IPERF_COUNTERS}     M55350C00009  M55349C00009

*** Keywords ***
[1]5GC002637-A-B1_PDCP_RLC_throughput_counters_NSA_5G_2CC_multiple_Ues
    [Documentation]
    ...    !!! Despite TC name, TC is performed in SA mode !!!
    ...    The scenario objective is to verifying PDCP layer counters values incrementation in gNB once 2 Ues
    ...    DL and UL throughput is finished in SA CA configured cells.
    Download SCF
    Perform carrier aggregation gNB commissioning
    Bar LTE cells
    Attach UEs and start tput                       ${MULTI_UE}  udp  both        ${DATA_TRANSFER_SHORT}
    ${av_tputs}  ${max_tputs}                       Wait for tput finish 2637     ${MULTI_UE}
    Wait for counter interval 2637                  ${WAIT_IN_CA_TC}
    ${counters_values}                              Get counters value            ${CA_TPUT_COUNTERS}
    Check if counters values differ from zero 2637  ${counters_values}            ${CA_TPUT_COUNTERS}
    ${sCell_counters_values}                        Get counters value for sCell  ${CA_TPUT_COUNTERS}
    Check if sCell counters value equal zero        ${sCell_counters_values}      ${CA_TPUT_COUNTERS}
    Verify CA average tput counters                 ${counters_values}            ${CA_TPUT_COUNTERS}  ${av_tputs}
    Verify CA data tput counters                    ${counters_values}            ${CA_TPUT_COUNTERS}  ${max_tputs}
    Verify CA time tput counters                    ${counters_values}            ${CA_TPUT_COUNTERS}
    Wait for counter interval 2637
    Attach UEs and start tput                       ${MULTI_UE}  tcp  both        ${DATA_TRANSFER_SHORT}
    ${av_tputs}  ${max_tputs}                       Wait for tput finish 2637     ${MULTI_UE}
    Wait for counter interval 2637                  ${WAIT_IN_CA_TC}
    ${counters_values}                              Get counters value            ${CA_TPUT_COUNTERS}
    Check if counters values differ from zero 2637  ${counters_values}            ${CA_TPUT_COUNTERS}
    ${sCell_counters_values}                        Get counters value for sCell  ${CA_TPUT_COUNTERS}
    Check if sCell counters value equal zero        ${sCell_counters_values}      ${CA_TPUT_COUNTERS}
    Verify CA average tput counters                 ${counters_values}            ${CA_TPUT_COUNTERS}  ${av_tputs}
    Verify CA data tput counters                    ${counters_values}            ${CA_TPUT_COUNTERS}  ${max_tputs}
    Verify CA time tput counters                    ${counters_values}            ${CA_TPUT_COUNTERS}
    [Teardown]   Run Keywords
    ...          Collect Snapshot
    ...          Recommission to default
    ...          Unbar LTE cells

[1]5GC002637-A-B1_PDCP_RLC_throughput_counters_NSA_both_LTE_5G_multiple_Ues
    [Documentation]
    ...     !!! Despite TC name, TC uses one UE !!!
    [Arguments]    ${new_ue_alias}=@{EMPTY}
    run keyword if    "${new_ue_alias}"!="@{EMPTY}"  set test variable  ${SINGLE_UE}  ${new_ue_alias}
    Sleep   300s
    ${counters_values}                              Get counters value       ${NSA_TC_TPUT_COUNTERS}
    Check if counters values equal zero             ${counters_values}       ${NSA_TC_TPUT_COUNTERS}
    Attach UEs and start tput                       ${SINGLE_UE}  udp  both  ${DATA_TRANSFER_SHORT}
    Wait for tput finish 2637                       ${SINGLE_UE}
    Wait for counter interval 2637
    ${counters_values}                              Get counters value       ${NSA_TC_TPUT_COUNTERS}
    Check if counters values differ from zero 2637  ${counters_values}       ${NSA_TC_TPUT_COUNTERS}

[1]5GC002637-A-B3_MAC_layer_maximum_throughput_counters_SA_multiple_Ues
    [Documentation]
    ...     !!! Despite TC name, TC uses one UE !!!
    ...     The scenario objective is verifying MAC layer counters values incrementation in gNB while DL and UL
    ...     throughput in a DRX enabled cell. Small file data transfer is completed, then stopped so as Ue gets
    ...     into DRX-sleep state. Next, small data transfer is executed anew for confirming paging/DRX state exit.
    ...     During the scenario execution it is confirmed that M55308C26001 and M55308C26002 are incremented while DL
    ...     and UL DRB data is buffered (i.e. tput is active) for Ue which is not in DRX-sleep state. Furthermore,
    ...     it is confirmed that M55308C27001 is incremented in each slot by a number of Ues that are in DRX-sleep state.
    Bar LTE cells
    Perform consecutive calls to trigger DRX state
    Wait for counter interval 2637
    Verify DRX-sleep counters    ${DRX_COUNTERS}
    [Teardown]  Unbar LTE cells

[2]5GC002637-A-B3_MAC_layer_maximum_throughput_counters_SA_single_Ue
    [Documentation]
    ...     !!! Despite TC name, TC uses two UEs !!!
    ...     The scenario objective is to verifying MAC layer counter value incrementation in gNB, while DL throughput.
    ...     During the scenario execution it is confirmed that M55309C12001 is not smaller than average volume
    ...     transferred per second.
    Bar LTE cells
    Attach UEs and start tput          ${MULTI_UE}  udp  dl       ${DATA_TRANSFER_LONG}
    ${av_tputs}  ${max_tputs}          Wait for tput finish 2637  ${MULTI_UE}
    Verify base throughput counters    ${DL_TPUT_COUNTERS}        ${av_tputs}
    Attach UEs and start tput          ${MULTI_UE}  tcp  dl       ${DATA_TRANSFER_LONG}
    ${av_tputs}  ${max_tputs}          Wait for tput finish 2637  ${MULTI_UE}
    Verify base throughput counters    ${DL_TPUT_COUNTERS}        ${av_tputs}
    [Teardown]  Unbar LTE cells

[1]5GC002637-A-B3_MAC_layer_maximum_throughput_counters_SA_single_Ue
    [Documentation]
    ...     !!! Despite TC name, TC uses two UEs !!!
    ...     The scenario objective is to verifying MAC layer counter value incrementation in gNB, while UL throughput.
    ...     During the scenario execution it is confirmed that M55309C12002 is not smaller than average volume
    ...     transferred per second.
    Bar LTE cells
    Attach UEs and start tput          ${MULTI_UE}  udp  ul       ${DATA_TRANSFER_LONG}
    ${av_tputs}  ${max_tputs}          Wait for tput finish 2637  ${MULTI_UE}
    Verify base throughput counters    ${UL_TPUT_COUNTERS}        ${av_tputs}
    Attach UEs and start tput          ${MULTI_UE}  tcp  ul       ${DATA_TRANSFER_LONG}
    ${av_tputs}  ${max_tputs}          Wait for tput finish 2637  ${MULTI_UE}
    Verify base throughput counters    ${UL_TPUT_COUNTERS}        ${av_tputs}
    [Teardown]  Unbar LTE cells
