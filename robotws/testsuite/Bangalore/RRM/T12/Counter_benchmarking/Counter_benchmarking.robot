*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 This test case is used to benchmark counters for CB008159
...                 M55125C09025,M55125C09026

Library           Collections
Library           DateTime
Library           String
Library           ute_ue
Library           taf.collectors.pmcounters    WITH NAME    gnb_pmcounters
Library           taf.analyzer.pmcounter    WITH NAME    analyser
resource          resources/Keywords/counter_benchmark_resource.robot
resource          resources/Keywords/CB008159_keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown

*** Test cases ***
[1][1.0] Counter_benchmarking_for_CB008159_insession_counters
    [Documentation]      This testcase does Counter_benchmarking_for_CB008159_insession_counters
    [Tags]    QC_170353   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       \nStarting the test......
    [Setup]              Prepare for test Case - CB008159
    Cell1_MultiUE call with traffic
#    Cell2_MultiUE call with traffic
    Cell3_MultiUE call with traffic
#    Cell4_MultiUE call with traffic
    Stop traffic for all UEs and check UEs are in Idle state
    Validate insession counters for normal and abnormal release
    [Teardown]     Tear Down for test Case - CB008159
