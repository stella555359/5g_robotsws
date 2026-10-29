*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
Resource        resources/Keywords/CB012631_Keywords.robot
Suite Setup    Updated Suite Setup
Suite Teardown  Common Suite Teardown


*** Variables ***
${UE_1}        1
${UE_2}        2
${UE_6}        6
@{cell_id}      51
${low_rate}     3
${high_rate}    10
${kbps}         kbps
${mbps}         mbps


*** Test Cases ***
[1][1.0] CB012631_C_5_Verify_eMBB_UE_Semi_Automatic_SSSG_configuration_TDD
    [Tags]    QC_290869    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    The purpose of this test case is to verify configuration of gNB behaviour when configuring
    ...     multiple UEs with a SSSG>0 through semi-automatic configuration.
    [Setup]    Prepare Test For CB012631 C 5
    Log To Console    \nStarting test case execution...
    Wait For Next Full Pm Interval
    Common Start Ttitrace With Streaming Mode 3 Custom    @{cell_id}
    slog.Start Syslog       ${Log_Path}     syslog.LOG
    Log To Console     \nRegistering and validating UE 1
    UE Register And Verify Searchspace Config For TDD    ${UE_1}
    Sleep     30s
    Run And Validate Traffic    UE_ID=${UE_1}   unit=${mbps}  dl_rate=${high_rate}  ul_rate=${high_rate}
    Sleep    30s

    Log To Console    \nRegistering and validating UE 2
    UE Register And Verify Searchspace Config For TDD    ${UE_2}
    Sleep     30s
    Run And Validate Traffic    UE_ID=${UE_2}    unit=${mbps}  dl_rate=${high_rate}  ul_rate=${high_rate}
    Sleep    30s

    Log To Console    \nRegistering and validating Redcap UE 6
    UE Register And Verify Searchspace Config For TDD    ${UE_6}
    Sleep     30s
    Run And Validate Traffic    UE_ID=${UE_6}    unit=${mbps}  dl_rate=${high_rate}  ul_rate=${high_rate}
    Sleep    60s

    Stop Ttitrace Collection    ${log_path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    @{val144}=    Get Pm Counter Value    M55308C00144   MRBTS-1/NRBTS-1/NRCELL-1   ${pm_counter_file}
    Log To Console    \nM55308C00144 value = @{val144}

    @{val145}=    Get Pm Counter Value  M55308C00145   MRBTS-1/NRBTS-1/NRCELL-1   ${pm_counter_file}
    Log To Console    \nM55308C00145 value = @{val145}

    @{val148}=    Get Pm Counter Value   M55308C00148  MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    Log To Console    \nM55308C00148 value = @{val148}

    @{val149}=    Get Pm Counter Value  M55308C00149   MRBTS-1/NRBTS-1/NRCELL-1   ${pm_counter_file}
    Log To Console    \nM55308C00149 value = @{val149}

    @{val142}=    Get Pm Counter Value    M55308C00142    MRBTS-1/NRBTS-1/NRCELL-1   ${pm_counter_file}
    Log To Console    \nM55308C00142 value = @{val142}

    @{val143}=    Get Pm Counter Value  M55308C00143    MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    Log To Console    \nM55308C00143 value = @{val143}

    @{val146}=    Get Pm Counter Value   M55308C00146   MRBTS-1/NRBTS-1/NRCELL-1   ${pm_counter_file}
    Log To Console    \nM55308C00146 value = @{val146}

    @{val147}=    Get Pm Counter Value   M55308C00147   MRBTS-1/NRBTS-1/NRCELL-1    ${pm_counter_file}
    Log To Console    \nM55308C00147 value = @{val147}

    Validate Zero At Required Indexes    ${val144}    ${val145}
    Validate Zero At Required Indexes    ${val148}    ${val149}
    Validate Equal At Required Indexes    ${val142}    ${val143}
    Validate Equal At Required Indexes    ${val146}    ${val147}
    [Teardown]    Tear Down For CB012631 C 5