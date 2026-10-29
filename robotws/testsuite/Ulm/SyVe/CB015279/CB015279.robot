*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB006139
...             CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com

# -----------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library     taf.ue

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/pcap_analysis.robot
Resource    ../resources/sqd63/common_keywords.robot
Resource    CB015279_commissioning.robot
Resource    CB015279_keywords.robot


Suite Setup     CB015279_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${WITH_PMCOUNTER_CHECK}    false
${DL_THROUGHPUT_1}         1Mbits/sec
${UL_THROUGHPUT_1}         1Mbits/sec
${DL_THROUGHPUT_2}         2000Mbits/sec
${UL_THROUGHPUT_2}         300Mbits/sec
${DURATION_DL_1}           900s
${DURATION_UL_1}           900s
${DURATION_DL_2}           900s
${DURATION_UL_2}           900s
${DL_PROTOCOL}             udp
${UL_PROTOCOL}             udp


@{LOGS}                  testSuiteConfigs
@{ALL_CELLS_GNB0}        1  2  3  4  5  6  7  8  9  10  11
@{ALL_CELLS_GNB1}        1  2  3  4
@{NR_CELLS_BLOCK}        1  2  3  4  5
@{LTE_CELLS_BLOCK}       1  2  3  4



*** Test Cases ***
CB015279_A_RE_TC03_B2_Config_intra-Freq_meas_during_MeNB_initiated_SgNB_Mod_proc_using_selctd_Meas_Profile_based_UE_CA_NSA
    [Documentation]    This test case describes the SgNB behaviour during MeNB initiated SgNB Modification procedure, UE is configured with required
    ...                intra-frequency measurements (A1/A2/A3/A5) using selected measurement profile based on UE CA capability for NSA call.
    ...                If current PSCell is not changed by SgNB during intra-MeNB handover then configured NR intra-frequency measurements in PSCell
    ...                are not reconfigured and per legacy CB008127 implementation there is no trigger to (re)select measurement profile.
    ...                Behaviour is based on: USCB008127-CD#B2:
    ...                Successful configuration of intra-frequency measurements (A2/A3/A5) during MeNB initiated
    ...                SgNB Modification procedure using selected measurement profile

    [Tags]    CB015279  CB015279_A_RE_TC03  CB015279_A_TC03  TL364
    [Setup]   CB015279_keywords.Perform Preconditions Of Test Scenario

#    hanging_resources.Get Resources Before Test For All Nodes
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        Log To Console    \nPMcounters: Wait for next Measurement Period to start.
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${source_node_id}
    END
    Log To Console  Start Test Part CB015279_A_RE_TC03
    Execution CB015279_A_RE_TC03

#    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
#        ${PMCounters_dir_Part1}=    CB015279_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${1}
#        Set Suite Variable    ${PMCounters_dir_Part1}
#    END
    taf.ue.Detach UE   ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
#    CB015279_keywords.Verify QC Test Case
#    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB015279 Teardown


CB015279_A_RE_TC05_B6_Config_Inter-Freq _A3_A5_and A1_meas_upon_receipt_of_A2MR_using_selctd_Meas_Profile_based_UE_CA_NSA
    [Documentation]    This user scenario describes the SgNB behaviour, when a UE on NSA 3x call (without SRB3), sends A2 measurement report and
    ...                therefore Inter-Freq A3/A5 and A1 measurements are configured using selected measurement profile based on UE CA capability
    ...                for NSA call.
    ...                Behaviour is based on: USCB008127-CD#B5:
    ...                Successful Configuration of A2 measurement using measurement profile upon receiving A1 measurement report


    [Tags]    CB015279  CB015279_A_RE_TC05  CB015279_A_TC05  TL364
    [Setup]   CB015279_keywords.Perform Preconditions Of Test Scenario

    Execution CB015279_A_RE_TC05
    [Teardown]    CB015279 Teardown


CB015279_A_RE_TC07_B9_ALT3_Config_A2_meas_for_PSCell_change_during_SCellAdd_in_inter-gNB_PSCell_change_using_selctd_Meas_Profile_based_UE_CA_NSA
    [Documentation]   This test case intends to verify configuration of A2 measurement on PSCell for PCell change using the selected measurement
    ...               profile based on UE CA capabilites during SCell addition as part of inter-gNB PSCell change for an NSA UE. A2 based PSCell
    ...               change is an inter-frequency PSCell change with the current SCell as the target cell and applied when the SCell has bigger
    ...               coverage than the PSCell and triggered when the PSCell radio conditions degrade to a level below the A2 threshold.
    ...               Behaviour is based on: USCB013142-C#B1:
    ...               Configuration of A2 measurement on PSCell for 'PSCell change' using selected measurement profile based on one or more criteria
    ...               during SCell addition for NSA and
    ...               US CB008542-BB#B6: Configuration of A2 measurement on PSCell for PSCell change for NSA

    [Tags]    CB015279  CB015279_A_RE_TC07  CB015279_A_TC07  TL364
    [Setup]   CB015279_keywords.Perform Preconditions Of Test Scenario

    Execution CB015279_A_RE_TC07
    [Teardown]    CB015279 Teardown


*** Keywords ***
Execution CB015279_A_RE_TC03
    [Documentation]  Starting CB015279_A_TC03 Part1, Step 1
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB015279_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    CB015279_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB015279_A_TC03


Execution CB015279_A_RE_TC05
    [Documentation]  Starting CB015279_A_TC05 Part1, Step 1
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB015279_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    CB015279_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB015279_A_TC05


Execution CB015279_A_RE_TC07
    [Documentation]  Starting CB015279_A_TC07 Part1, Step 1
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_1}

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP
    attenuator_scenario.Set Cell Attenuation  globalcellid=${source_Pcell}  value=${30}
    ...    node_id=${source_node_id}  node_type=${source_node_type}
    taf.ue.Attach UE   ${UE_ALIAS_1}
    ${dl_dt_name}    ${ul_dt_name}=    CB015279_keywords.Start UL And DL Traffic  transfer=${1}  dl_throughput=${DL_THROUGHPUT_1}
    ...    ul_throughput=${UL_THROUGHPUT_1}  duration_dl=${DURATION_DL_1}  duration_ul=${DURATION_UL_1}
    CB015279_keywords.Stop DL And UL Traffic And Check Throughput  dl_dt_name=DT_DL_${UE_ALIAS_1}_${1}    ul_dt_name=DT_UL_${UE_ALIAS_1}_${1}
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB015279_A_TC07

