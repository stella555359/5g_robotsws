*** Settings ***
Documentation   This is a Robot Test Suite for feature: CB006139-AAD / CVR
...             CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Team: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library     taf.ue

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/sqd63/common_keywords.robot
Resource    ../resources/pcap_analysis.robot
Resource    CB006139_commissioning_AAD.robot
Resource    CB006139_revert.robot
Resource    CB006139_verification.robot
Resource    CB006139_keywords.robot


Suite Setup     CB006139_keywords.Prepare TL For Testing
Suite Teardown  common_keywords.Save All Logs And Teardown TL


*** Variables ***
${UE_ALIAS_1}              UE_1
${UE_ALIAS_2}              UE_2
${WITH_PMCOUNTER_CHECK}    true
${DL_THROUGHPUT}           750Mbits/sec
${UL_THROUGHPUT}           100Mbits/sec
${DURATION}                500s
${DL_PARALLEL_STREAMS}     4
${DL_Protocol}             udp
${UL_Protocol}             udp



@{LOGS}                  testSuiteConfigs
@{NR_CELLS_BLOCK}        5  6  11  12  16  17  20
@{LTE_CELLS_BLOCK}       1  2  7  8  11  12


*** Test Cases ***
CB006139_AAD_ST_TC07_TMOUS_CVR_001_DLULCA_IntraGNB
    [Documentation]    Applicable for TMO FR1 SA cases only. Primary test scenarios should be on 5CC (3T+2F)
    ...                and 6CC(3T+3F) cases for TMO bands (although most of the utilization will happen for upto
    ...                4CC scenarios.
    ...                Band: n41, n25,n71,n66. Typical combos will be 100+80 T and 100+90 and 100+60+10 T and
    ...                for FDD bands combos including 20 and 10 MHz carriers. Additionally, Testing should focus
    ...                on the interactions of MIMO layers with Scell addition for the net gain comparing the scenarios
    ...                of no 6139 with 6139 activated. This feature can have significant implications (Positive I think),
    ...                so should be tested more thoroughly for even some fringe scenarios.


    [Tags]    CB006139_AAD  CB006139_AAD_ST_TC07  CB006139  TL395  TL224
    [Setup]   CB006139_keywords.Perform Preconditions Of Test Scenario

    hanging_resources.Get Resources Before Test For All Nodes

    Log To Console  Start Test Part CB006139_AAD_ST_TC07
    taf.ue.Require UE  ${UE_ALIAS_1}  capabilities=${UE_ALIAS_1}
    taf.ue.Require UE  ${UE_ALIAS_2}  capabilities=${UE_ALIAS_2}
    taf.ue.Detach UE   ${UE_ALIAS_1}
    taf.ue.Detach UE   ${UE_ALIAS_2}
    Execution CB006139_AAD  Part=1
    Execution CB006139_AAD  Part=2
    Execution CB006139_AAD  Part=3

    CB006139_keywords.Verify QC Test Case
    hanging_resources.Get Resources After Test For All Nodes

    [Teardown]    CB006139 Teardown


*** Keywords ***
Execution CB006139_AAD
    [Documentation]  Part1: Starting CB006139_AAD_ST_TC07: DL 6CC + UL 2CC
    ...              Part2: Starting CB006139_AAD_ST_TC07: DL 5CC + UL 2CC
    ...              Part3: Starting CB006139_AAD_ST_TC07: DL 4CC
    [Arguments]  ${Part}
    Log To Console  Starting Execution CB006139_AAD Part${Part}
    IF    '${Part}'!='1'
        Run keyword  CB006139_commissioning_AAD.Execute GNB Delta Commission JSON For CB006139_AAD GNB-0 Part${Part}
        ...    nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
        ...    target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part${Part}}
        ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part${Part}}
    END

    Log To Console    \nPMcounters: Wait for next Measurement Period to start.
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${SOURCE_NODE_ID}
    END

    pcap_analysis.Start PCAP Tracing On Eth Port For SCTP And TCP

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}  ${27}
    ...                                                       ${SOURCE_SCELL1}  ${110}
    ...                                                       ${SOURCE_SCELL2}  ${110}
    ...                                                       ${SOURCE_SCELL3}  ${110}
    ...                                                       ${SOURCE_SCELL4}  ${110}
    ...                                                       ${SOURCE_SCELL5}  ${110}

    taf.ue.Attach UE   ${UE_ALIAS_1}  timeout=180
    ${dl_dt_name}    ${ul_dt_name}=    CB006139_keywords.Start UL And DL Traffic  transfer=${Part}  dl_throughput=${DL_THROUGHPUT}
    ...    ul_throughput=${UL_THROUGHPUT}  duration_dl=${DURATION}  duration_ul=${DURATION}  parallel=${DL_PARALLEL_STREAMS}

    Run keyword  Cell Scenario Part${Part}

    taf.ue.Detach UE   ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of UE resources
    pcap_analysis.Stop PCAP Tracing And Save As    tcp_file=UE1_CB006139_AAD_Part${Part}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        ${PMCounters_dir}=    CB006139_PMverification.Fetch And Rename PM Counter Dirs    gnb_id=${0}  PM_Part=${Part}
        Set Suite Variable    ${PMCOUNTERS_DIR_PART${Part}}  ${PMCounters_dir}
    END


Cell Scenario Part1
    [Documentation]  Cell Scenario for Part1, time critical therefore not as attenuator file

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}  ${33}
    ...                                                       ${SOURCE_SCELL2}  ${33}
    ...                                                       ${SOURCE_SCELL3}  ${34}
    ...                                                       ${SOURCE_SCELL4}  ${40}
    ...                                                       ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}
    Sleep  15s  reason=Wait for Scell Attach, 6CC

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}   ${27}
    ...                                                       ${SOURCE_SCELL5}  ${110}
    Sleep  90s  reason=Wait ~60sec for the sCellExcludelistTimerFr1 expiry: Scell5 released, bad RLQ, 5CC

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}  ${15}
    Sleep  15s  reason=Wait for Scell Attach, 6CC

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}   ${27}
    ...                                                       ${SOURCE_SCELL3}  ${110}
    ...                                                       ${SOURCE_SCELL5}  ${110}
    Sleep  90s  reason=Wait ~60sec for the sCellExcludelistTimerFr1 expiry: Scell3&5 released, bad RLQ, 4CC

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL3}  ${34}
    ...                                                       ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}
    Sleep  30s  reason=Wait for Scell Attach


Cell Scenario Part2
    [Documentation]  Cell Scenario for Part2, time critical therefore not as attenuator file

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}  ${33}
    ...                                                       ${SOURCE_SCELL2}  ${33}
    ...                                                       ${SOURCE_SCELL3}  ${34}
    ...                                                       ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}

    Sleep  15s  reason=Wait for Scell Attach, 5CC DL + 2CC UL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}   ${27}
    ...                                                       ${SOURCE_SCELL5}  ${110}
    Sleep  90s  reason=Wait ~90sec for the sCellExcludelistTimerFr1 expiry: Scell4 released, Bad RLQ, 4CC DL + 2CC UL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}
    Sleep  15s  reason=Wait for Scell Attach: 5CC DL + 2CC UL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}   ${27}
    ...                                                       ${SOURCE_SCELL3}  ${110}
    ...                                                       ${SOURCE_SCELL5}  ${110}
    Sleep  90s  reason=Wait ~90sec for the sCellExcludelistTimerFr1 expiry, Scell3&5 released, Bad RLQ, 3CC DL + 1 CC UL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL3}  ${34}
    ...                                                       ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}
    Sleep  30s  reason=Wait for Scell Attach, 5CC DL + 2CC UL


Cell Scenario Part3
    [Documentation]  Cell Scenario for Part3, time critical therefore not as attenuator file
    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL1}  ${33}
    ...                                                       ${SOURCE_SCELL2}  ${33}
    ...                                                       ${SOURCE_SCELL5}  ${0}
    ...                                                       ${SOURCE_PCELL}   ${15}
    Sleep  15s  reason=Wait for Scell Attach, 4CC DL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}    ${27}
    ...                                                       ${SOURCE_SCELL5}   ${110}
    Sleep  90s  reason=Wait ~90sec for the sCellExcludelistTimerFr1 expiry, Scell5 release, Bad RLQ, 3CC DL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL5}    ${0}
    ...                                                       ${SOURCE_PCELL}    ${15}
    Sleep  15s  reason=Wait for Scell Attach, 4CC DL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_PCELL}    ${27}
    ...                                                       ${SOURCE_SCELL2}   ${110}
    ...                                                       ${SOURCE_SCELL5}   ${110}
    Sleep  90s  reason=Wait ~90sec for the sCellExcludelistTimerFr1 expiry, Scell release, Bad RLQ, 2 CC DL

    CB006139_keywords.Set Cell Attenuation On  SOURCE NODE    ${SOURCE_SCELL2}   ${33}
    ...                                                       ${SOURCE_SCELL5}   ${0}
    ...                                                       ${SOURCE_PCELL}    ${15}
    Sleep  30s  reason=Wait for Scell Attach, 4 CC DL
