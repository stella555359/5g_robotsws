*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB014009
...             CB014009 Buffer-based step-wise NR FR1 SCell addition
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library     taf.ue

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/sqd63/common_keywords.robot
Resource    CB014009_TC03_commissioning.robot
#Resource    CB014009_revert.robot
Resource    CB014009_verification.robot
Resource    CB014009_keywords.robot


Suite Setup     CB014009_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    true
${DL_THROUGHPUT_1}         10kbits/sec
${UL_THROUGHPUT_1}         10kbits/sec
${DL_THROUGHPUT_2}         1000Mbits/sec
${UL_THROUGHPUT_2}         300Mbits/sec
${DURATION_DL_1}           3600s
${DURATION_UL_1}           3600s
${DURATION_DL_2}           900s
${DURATION_UL_2}           900s
${DL_Protocol}             udp
${UL_Protocol}             udp

@{LOGS}                  testSuiteConfigs



*** Test Cases ***
CB014009_RE_TC03_IWK_CB008140_InterGNB_ScellConfigAttempts_Success_DLUL
    [Documentation]    The User scenario describes the CA configuration attempts and success counters for all CA type (Intra gNB and Inter gNB)
    ...                for SA. This Test Case will cover the Inter-GNB case!
    [Tags]    CB014009  CB014009_TC03  TL364
    [Setup]    Perform Preconditions Of Test Scenario
    hanging_resources.Get Resources Before Test For All Nodes
    Log To Console  Starting UE
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}
    Log To Console  Start Test Part I
    Execution CB014009_TC03_Part1

    Log To Console  Start Test Part II
    Execution CB014009_TC03_Part2

    Log To Console  Start Test Part III
    Execution CB014009_TC03_Part3

    Log To Console  Start Test Part IV
    Execution CB014009_TC03_Part4

    Log To Console  STOP BIG Traffic Transfer 5
    CB014009_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${5}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${5}
    Log To Console  STOP SMALL Traffic
    CB014009_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    Sleep  20s  reason=Wait until traffic is stopped for UE release
    taf.ue.Detach UE   ${UE_ALIAS_1}

    CB014009_keywords.Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB014009_keywords.CB014009 Teardown


*** Keywords ***
Execution CB014009_TC03_Part1
    [Documentation]  Starting CB014009_TC03 Part 1, Step 1& 2
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${10}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}

    FOR   ${cell_id}   IN   ${target_Scell1}   ${target_Scell2}   ${target_Scell3}
        attenuator_scenario.Set Cell Attenuation  globalcellid=${cell_id}
        ...                                       value=${30}
        ...                                       node_id=${target_node_id}
        ...                                       node_type=${target_node_type}
    END
    Log To Console  START SMALL Traffic Transfer 1
    ${dl_dt_name}    ${ul_dt_name}=    CB014009_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    Log To Console  START BIG Traffic Transfer 2
    ${dl_dt_name}    ${ul_dt_name}=    CB014009_keywords.Start UL And DL Traffic  transfer=${2}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB014009_TC03_Part1


Execution CB014009_TC03_Part2
    [Documentation]  Starting CB014009_TC03 Part 2, Step 3&4
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    Log To Console  STOP BIG Traffic Transfer 2
    CB014009_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${2}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${2}
    Sleep  30s  reason=wait Stop Traffic (30s) plus ext-sCell1 release expiry
    Log To Console  START BIG Traffic Transfer 3
    ${dl_dt_name}    ${ul_dt_name}=    CB014009_keywords.Start UL And DL Traffic  transfer=${3}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}

    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part2}=  CB014009_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${2}
        Set Suite Variable    ${PMCounters_dir_Part2}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB014009_TC03_Part2


Execution CB014009_TC03_Part3
    [Documentation]  Starting CB014009_TC03 Part 3, Step 5 to 6
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    Log To Console  STOP BIG Traffic Transfer 3
    CB014009_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${3}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${3}
    Sleep  60s  reason=Stop traffic (30s) pls wait for ext-sCell1 & 2 release expiry
    Log To Console  START BIG Traffic Transfer 4
    ${dl_dt_name}    ${ul_dt_name}=    CB014009_keywords.Start UL And DL Traffic  transfer=${4}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part3}=    CB014009_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${3}
        Set Suite Variable    ${PMCounters_dir_Part3}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB014009_TC03_Part3

Execution CB014009_TC03_Part4
    [Documentation]  Starting CB014009_TC03 Part 4, Step 7 to 9
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    Log To Console  STOP BIG Traffic Transfer 4
    CB014009_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${4}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${4}
    Sleep  120s  reason=wait for Stop traffic (30s) plus wait for ext-sCell1,2 & 3 release expiry
    Log To Console  START BIG Traffic Transfer 5
    ${dl_dt_name}    ${ul_dt_name}=    CB014009_keywords.Start UL And DL Traffic  transfer=${5}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part4}=    CB014009_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${4}
        Set Suite Variable    ${PMCounters_dir_Part4}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB014009_TC03_Part4
