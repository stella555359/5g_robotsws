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
Resource    CB006139_commissioning_AA_EA.robot
Resource    CB006139_revert.robot
Resource    CB006139_verification.robot
Resource    CB006139_keywords.robot


Suite Setup     CB006139_keywords.Prepare TL for Testing
Suite Teardown  common_keywords.Save all Logs and Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    false
${DL_THROUGHPUT_1}         1Mbits/sec
${UL_THROUGHPUT_1}         1Mbits/sec
${DL_THROUGHPUT_2}         2000Mbits/sec
${UL_THROUGHPUT_2}         300Mbits/sec
${DURATION_DL_1}           1500s
${DURATION_UL_1}           1500s
${DURATION_DL_2}           1500s
${DURATION_UL_2}           1500s
${DL_Protocol}             udp
${UL_Protocol}             udp

@{LOGS}                  testSuiteConfigs
@{NR_CELLS_BLOCK}        4  11  12  16  17  19
@{LTE_CELLS_BLOCK}       1  2  7  8  11  12


*** Test Cases ***
CB006139_AA_ST_TC07_B4_BlindCA_partialScellRel_MultiScell
    [Documentation]    In the scope of this test, the user scenario USCB006139-AA#B4:
    ...                Step-wise SCell addition after multiple partial SCell Releases due to poor SCell RLQ will be verified.
    ...                Demonstrate multiple blind step-wise SCell Additions after Partial SCell releases. “TDD-FDD - 3CC”


    [Tags]    CB006139_AA  CB006139_AA_TC07  CB006139_AA_ST_TC07  CB006139  TL224
    [Setup]    Perform Preconditions of Test Scenario
    hanging_resources.Get resources before test for all nodes
    Log To Console  Starting UE
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}
    Log To Console  Start Test Part I
    Execution CB006139_AA_Part1

    Log To Console  Start Test Part II
    Execution CB006139_AA_Part2

    Log To Console  Start Test Part III
    Execution CB006139_AA_Part3

    CB006139_keywords.Stop DL and UL Traffic and check throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${5}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${5}
    Sleep  30s  reason=Wait until traffic is stopped for UE release
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
    CB006139_keywords.Verify qc test case
    hanging_resources.Get resources after test for all nodes

    [Teardown]    CB006139 Teardown


*** Keywords ***
Execution CB006139_AA_Part1
    [Documentation]  Starting CB006139_AA_07 Part 1, Step 1 to 5
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait until the next Measurement Period starts  gnb_id=${SOURCE_NODE_ID}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}  ${10}
    taf.ue.Attach Ue   ${UE_ALIAS_1}

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}    ${30}
    ...                                                       ${SOURCE_SCELL2}    ${30}
    ...                                                       ${SOURCE_SCELL3}    ${30}
    ...                                                       ${SOURCE_SCELL4}    ${10}

    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL and DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL and DL Traffic  transfer=${2}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}

    CB006139_keywords.Stop DL and UL Traffic and check throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${2}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${2}

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}    ${82}
    Sleep  20s  reason=wait for sCellExcludelistTimerFr1 expiry (min. 12sec)
    Cb006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}    ${30}
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL and DL Traffic  transfer=${3}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=    CB006139_PMverification.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_AA_Part1


Execution CB006139_AA_Part2
    [Documentation]  Starting CB006139_AA_07 Part 2, Step 6 to 9
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait until the next Measurement Period starts  gnb_id=${SOURCE_NODE_ID}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    CB006139_commissioning_AA_EA.Execute gNB Delta Commission JSON For CB006139_AA gnb-0 Part2  nrbts_id=${nrbts_id_0}  gnb_id=${SOURCE_NODE_ID}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part2}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part2}

    CB006139_keywords.Stop DL and UL Traffic and check throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${3}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${3}

     CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL4}    ${82}
    Sleep  20s  reason=wait for sCellExcludelistTimerFr1 expiry (min. 12sec)
    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL4}    ${10}

    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL and DL Traffic  transfer=${4}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}

    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part2}=  CB006139_PMverification.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${2}
        Set Suite Variable    ${PMCounters_dir_Part2}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_AA_Part2


Execution CB006139_AA_Part3
    [Documentation]  Starting CB006139_AA_07 Part 3, Step 10 to 14
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait until the next Measurement Period starts  gnb_id=${SOURCE_NODE_ID}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    CB006139_keywords.Stop DL and UL Traffic and check throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${4}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${4}
    Sleep  120s  reason=Only Pcell is used for data transmission

    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL and DL Traffic  transfer=${5}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    Sleep  30s  reason=Keep some traffic running
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part3}=    CB006139_PMverification.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${3}
        Set Suite Variable    ${PMCounters_dir_Part3}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_AA_Part3
