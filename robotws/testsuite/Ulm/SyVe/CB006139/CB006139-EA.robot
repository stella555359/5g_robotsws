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


Suite Setup     CB006139_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    false
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
@{NR_CELLS_BLOCK_0}       11  12
@{NR_CELLS_BLOCK_1}       2
@{LTE_CELLS_BLOCK}        7  8


*** Test Cases ***
CB006139_EA_ST_TC05_B2_Alt2_InterGNB_BlindCA_MultiExtScell
    [Documentation]    The scenario shows blind step-wise inter-gNB SCell Addition of ext-SCell after partial
    ...    SCell Release (UE is in CA after the ext-SCell Release). In this user scenario, there is only one
    ...    Potential ext-SCell Addition Candidate after the ext-SCell Release.
    ...    The main scenario assumes the gNB is configured for 4CC inter-gNB CA and the UE supports 4CC NR CA.
    ...    Alternative scenario 2.: Step-wise SCell addition after addition of ext-SCell

    [Tags]    CB006139_EA  CB006139_EA_TC05  CB006139  TL224  TL395
    [Setup]   Perform Preconditions Of Test Scenario

    hanging_resources.Get Resources Before Test For All Nodes
    Log To Console  Start Test Part CB006139_EA
    Execution CB006139_EA Part1
    Execution CB006139_EA Part2

    Sleep  20s  reason=wait release of resources
    CB006139_keywords.Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB006139 Teardown


*** Keywords ***
Execution CB006139_EA Part1
    [Documentation]  Starting CB006139_EA_05 Part1
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${SOURCE_NODE_ID}
    END
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP

    CB006139_commissioning_AA_EA.Execute GNB Test Commissionion JSON For CB006139_EA GNB-0 Part1
    ...    nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
    ...    target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1_1}
    ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part1_1}

    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=    CB006139_PMverification.Fetch and Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EA_Part1


Execution CB006139_EA Part2
    [Documentation]  Starting CB006139_EA_05 Part2
    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${SOURCE_NODE_ID}
    END
    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP

    CB006139_commissioning_AA_EA.Execute GNB Test Commissionion JSON For CB006139_EA GNB-0 Part2
    ...    nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
    ...    target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part2}
    ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part2}

    Set Cell Attenuation On  SOURCE NODE  ${SOURCE_PCELL}  ${10}
    taf.ue.Attach UE   ${UE_ALIAS_1}

    Set Cell Attenuation On  TARGET NODE  ${TARGET_SCELL1}  ${30}
    ...                                   ${TARGET_SCELL2}  ${30}
    ...                                   ${TARGET_SCELL3}  ${30}

    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${2}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}

    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${2}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${2}

    Set Cell Attenuation On  TARGET NODE  ${TARGET_SCELL2}  ${86}
    ...                                   ${TARGET_SCELL3}  ${86}
    Sleep  30s  reason=wait for sCellExcludelistTimerFr1 expiry (30sec)

    Set Cell Attenuation On  TARGET NODE  ${TARGET_SCELL2}  ${30}
    ...                                   ${TARGET_SCELL3}  ${30}

    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${3}  dl_throughput=${DL_THROUGHPUT_2}
    ...    ul_throughput=${UL_THROUGHPUT_2}  duration_dl=${DURATION_DL_2}  duration_ul=${DURATION_UL_2}
    Sleep  10s  reason=wait for Traffic
    CB006139_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${3}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${3}
    CB006139_keywords.Stop DL And UL Traffic And check throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    taf.ue.Detach Ue   ${UE_ALIAS_1}

    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir_Part1}=    CB006139_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${2}
        Set Suite Variable    ${PMCounters_dir_Part1}
    END

    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_EA_Part2
