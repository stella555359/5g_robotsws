*** Settings ***
#Suite Setup    Setup BTS env and set keyword prority     scf=SCF1_PeakTput_40M_enableMIMO.xml
Suite Setup    Setup BTS env and set keyword prority     scf=SCF1_PeakTput_20M.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      teana.wang@nokia-sbell.com
...   contact:     teana.wang@nokia-sbell.com
...   squad group: MMW_SG7

Force Tags    5G_RRM
...   PY39

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/UEs/Dingli_common_keywords.robot

*** Variables ***
#${EMIL_FLAG}    ${False}
#${AUTO_ANALYSIS_FLAG}    ${False}
#${SNAPSHOT_FLAG}    pass:False,fail:False
#${GNB_BIP_FLAG}    ${False}
#${RESOURCES_LEAKAGE_FLAG}    ${False}
#${RECREATE_WIRESHARK_FLAG}    ${False}
#${SYSCOM_FLAG}    ${False}

#${DEBUG}    ${True}

@{attach_cell1_20M_pa_values}
...    9=${50}
...    10=${55}
...    11=${20}
...    12=${50}

@{attach_cell1_40M_pa_values}
...    9=${50}
...    10=${50}
...    11=${15}
...    12=${45}



*** Test Cases ***
Check_20M_Peak_Throughput_with_Dingli
    [Documentation]
    ...    1. The purpose of this test case is to setup L3 call and check peak traffic for 20MHz cell.
    ...      case step:
    ...         a. L3 call and check preak throughput
    [Tags]    A001    QC_55390
    log to console    check 20MHz Peak throughput...
    Prepare PA To Register Cell1    ${attach_cell1_20M_pa_values}
    DingLi_Client.UE Attach
    DingLi_Client.Check PCI In Attach Info    expect_pci=700
    DingLi UE Start Trf And Check Tput    ul_throughput=30000    dl_throughput=205M    expect_ul_tput=25.8    expect_dl_tput=200.9
    ...    target_avg_percent=0.98    duration=300
    DingLi_Client.Teardown


#Check_40M_Peak_Throughput_with_Dingli
#    [Documentation]
#    ...    1. The purpose of this test case is to setup L3 call and check peak traffic for 40MHz cell.
#    ...      case step:
#    ...         a. L3 call and check preak throughput
#    [Tags]    A002
#    log to console    check 40MHz Peak throughput...
#    OnlineParamChange    ${PARAMS_FOR_CELL_40M}
#    Prepare PA To Register Cell1     ${attach_cell1_40M_pa_values}
#    log to console    UE Attach...
#    DingLi_Client.UE Attach
#    DingLi_Client.Check PCI In Attach Info    expect_pci=700
#    DingLi UE Start Trf And Check Tput    ul_throughput=60000    dl_throughput=430M    expect_ul_tput=57.4    expect_dl_tput=425.3
#    ...    target_avg_percent=0.98    duration=300
#    DingLi_Client.Teardown
#    [Teardown]    Recover Params and Test Teardown




*** Keywords ***
OnlineParamChange
    [Arguments]    ${Online_Param}
    log to console    Online Param Change...
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Recover Params and Test Teardown
    log to console    Recover Params...
    OnlineParamChange    ${PARAMS_FOR_RECOVER}
    Common Test Teardown And Stop Capture Logs

Prepare PA To Register Cell1
    [Arguments]    ${pa_values}
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    Set PA    ${pa_values}
    DingLi_Client.UE Prepare

Set PA
    [Arguments]      ${pa_values}
    #Note: set some ports failed occasionally, so set twice to avoid this issue temporarily
    log to console    Set PA...
    ${cur_values}    set_pa_values    ${pa_values}
    run keyword if  not ${cur_values}==${pa_values}    set_pa_values    ${pa_values}
    sleep    5s

DingLi UE Start Trf And Check Tput
    [Arguments]    ${ue_index}=${0}    ${cellid}=1    ${ue_type}=huawei_sigspark    ${check_source}=aasyslog
    ...    ${ul_throughput}=5000    ${dl_throughput}=10M    ${expect_ul_tput}=5    ${expect_dl_tput}=10
    ...    ${is_do_require_ue}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0.3    ${duration}=180
    Log    DingLi UE Start Trf And Check Tput...    console=${True}
    DingLi_Client.Start Data Transfer    ues_index=${ue_index}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    packetsize=2000
    @{direction_component_list}    Create List    DL    UL
    Check Tput With Power UE    cellid=${cellid}    ue_type=${ue_type}    check_source=${check_source}
    ...    expect_dl_tput=${expect_dl_tput}    expect_ul_tput=${expect_ul_tput}
    ...    duration=${duration}    direction_component_list=@{direction_component_list}
    ...    target_avg_percent=${target_avg_percent}    min_percent=0.85
    [Teardown]    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
