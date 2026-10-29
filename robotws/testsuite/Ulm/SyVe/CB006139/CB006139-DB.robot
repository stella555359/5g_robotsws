*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB006139
...             CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library     taf.ue

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/sqd63/common_keywords.robot
Resource    CB006139_commissioning_DB.robot
Resource    CB006139_revert.robot
Resource    CB006139_verification.robot
Resource    CB006139_keywords.robot


Suite Setup     CB006139_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    true
${DL_THROUGHPUT_1}         1000Mbits/sec
${UL_THROUGHPUT_1}         300Mbits/sec
${DURATION_DL_1}           900s
${DURATION_UL_1}           900s
${DL_Protocol}             udp
${UL_Protocol}             udp

@{LOGS}                  testSuiteConfigs
@{ALL_CELLS_GNB0}        1  2  3  4  5  6  7  8  9  10  11
@{GNB0_CELLS_NOT_BLOCK}  1  2  3  4  5  6  7  8  9  10  11


*** Test Cases ***
CB006139_DB_ST_TC06_IWK01_BWPinPS_Pcell_NoStepwiseScellAdd
    [Documentation]    Demonstrate that the gNB-DU does not report a DL buffer criterion notification when the gNB is in CA and the PCell is switched
    ...                to the power saving bandwidth part (PS BWP). This is basically a regression test for the correction implemented for customer
    ...                ticket 03841043
    [Tags]    CB006139_DB  CB006139_DB_TC06  CB006139  TL364
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    Log To Console  Starting UE
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}
    Log To Console  Start Test Part I
    Execution CB006139_DB_Part1

    Log To Console  Start Test Part II
    Execution CB006139_DB_Part2

    Log To Console  Start Test Part III
    Execution CB006139_DB_Part3

    Log To Console  Start Test Part IV
    Execution CB006139_DB_Part4

    taf.ue.Detach UE   ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
    CB006139_keywords.Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB006139_keywords.CB006139 Teardown


*** Keywords ***
Execution CB006139_DB_Part1
    [Documentation]  Starting CB006139_DB_03 Part 1, Step 1& 2
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    Log To Console    \nStart Wireshark Tracing Part1
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${10}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}

    FOR   ${cell_id}   IN   ${target_Scell1}   ${target_Scell2}
        attenuator_scenario.Set Cell Attenuation  globalcellid=${cell_id}
        ...                                       value=${40}
        ...                                       node_id=${source_node_id}
        ...                                       node_type=${source_node_type}
    END
    Log To Console  START Traffic Transfer 1
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    Sleep  10s  reason=wait for downlink Buffer Criterion
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_DB_Part1


Execution CB006139_DB_Part2
    [Documentation]  Starting CB006139_AAC_03 Part 2, Step 3
    Log To Console    \nStart Wireshark Tracing Part2
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_Scell1}  value=${60}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    Sleep  15s  reason=wait for SCell attenuation
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    Sleep  15s  reason=wait for A1 & A2 Measurement

    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_DB_Part2


Execution CB006139_DB_Part3
    [Documentation]  Starting CB006139_DB_03 Part 3, Step 4
    Log To Console    \nStart Wireshark Tracing Part3
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    Sleep  15s  reason=wait for Traffic Stop
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${10}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_Scell1}  value=${40}
    ...    node_id=${source_node_id}  node_type=${source_node_type}

    Sleep  30s  reason=Restore Cell attenuation
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part3}=    CB006139_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${3}
        Set Suite Variable    ${PMCounters_dir_Part3}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_DB_Part3

Execution CB006139_DB_Part4
    [Documentation]  Starting CB006139_DB_03 Part 4, Step 5 & 6
    Log To Console    \nStart Wireshark Tracing Part4
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    Log To Console  START Traffic Transfer 2
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${2}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    Sleep  30s  reason=wait for Traffic Stop
    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${2}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${2}
    Sleep  30s  reason=Wait until traffic is stopped for UE release
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_DB_Part4
