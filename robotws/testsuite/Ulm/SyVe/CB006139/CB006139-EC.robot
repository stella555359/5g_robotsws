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
Resource    CB006139_commissioning_EC.robot
Resource    CB006139_revert.robot
Resource    CB006139_verification.robot
Resource    CB006139_keywords.robot


Suite Setup     CB006139_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    true
${DL_THROUGHPUT_1}         1Mbits/sec
${UL_THROUGHPUT_1}         1Mbits/sec
${DL_THROUGHPUT_2}         2000Mbits/sec
${UL_THROUGHPUT_2}         300Mbits/sec
${DURATION_DL_1}           900s
${DURATION_UL_1}           900s
${DURATION_DL_2}           900s
${DURATION_UL_2}           900s
${DL_Protocol}             udp
${UL_Protocol}             udp


@{LOGS}                  testSuiteConfigs
@{ALL_CELLS_GNB0}        1  2  3  4  5  6  7  8  9  10  11
@{GNB0_CELLS_NOT_BLOCK}  1  2  3  4  6  7  8  9  10  11
@{ALL_CELLS_GNB1}        1  2  3  4
@{GNB1_CELLS_NOT_BLOCK}  1  3  4
@{ALL_CELLS_ENB0}        1  2  3  4  5
@{ENB0_CELLS_NOT_BLOCK}  1  2  3  5


*** Test Cases ***
CB006139_EC_ST_TC01_B2_MeasCA_A1A4Mix_InterGNB_StepwiseScellAdd_MultiStep
    [Documentation]    This test case verifies the gNB behavior that ext-SCell is not selected for step-wise SCell Addition
    ...                if intra-gNB CA configured at UE.

    [Tags]    CB006139_EC  CB006139_EC_TC01  CB006139  TL364
    [Setup]   CB006139_keywords.Perform Preconditions Of Test Scenario

    hanging_resources.Get Resources Before Test For All Nodes
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    Log To Console  Start Test Part CB006139_EC
    Execution CB006139_EC Part1
    Execution CB006139_EC Part2
    Execution CB006139_EC Part3
    Execution CB006139_EC Part4
    Execution CB006139_EC Part5

    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=    CB006139_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    taf.ue.Detach UE   ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
    CB006139_keywords.Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB006139 Teardown


*** Keywords ***
Execution CB006139_EC Part1
    [Documentation]  Starting CB006139_EC_01 Part1, Step 1
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EC_Part1


Execution CB006139_EC Part2
    [Documentation]  Starting CB006139_EC_01 Part2, Step 2

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_Scell1}  value=${40}
    ...    node_id=${target_node_id}  node_type=${target_node_type}

    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${24}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EC_Part2


Execution CB006139_EC Part3
    [Documentation]  Starting CB006139_EC_01 Part3, Step 3
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${2}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    Sleep  30s   reason=wait for some traffic
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EC_Part3


Execution CB006139_EC Part4
    [Documentation]  Starting CB006139_EC_01 Part4, Step 4
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_Scell3}  value=${30}
    ...    node_id=${target_node_id}  node_type=${target_node_type}
    Sleep  30s   reason=wait for some traffic
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EC_Part4


Execution CB006139_EC Part5
    [Documentation]  Starting CB006139_EC_01 Part5, Step 5&6
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${target_Scell2}  value=${30}
    ...    node_id=${target_node_id}  node_type=${target_node_type}
    Sleep  60s   reason=wait for some traffic
    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${2}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${2}
    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EC_Part5
