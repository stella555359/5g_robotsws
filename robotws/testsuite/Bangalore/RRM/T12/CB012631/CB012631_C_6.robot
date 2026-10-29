*** Settings ***
Documentation    :copyright: Nokia
...              :author   : Bhakti Kapatel
...              :contact  : bhakti.ka_patel@nokia.com
Resource         resources/Keywords/CB012631_Keywords.robot
Library         taf.converters.eventdecoder
Library          ../TtiTraceAutomation/tti_trace_verification/main.py
Library          ../TtiTraceAutomation/tti_trace_verification/tti_utilities/eventcsv_conversion.py
Suite Setup      Updated Suite Setup
Suite Teardown   Common Suite Teardown


*** Variables ***
${UE_51}         51
${UE_52}         52
${UE_56}         56
@{cell_id}       57
${low_rate}      3
${high_rate}     10
${kbps}          kbps
${mbps}          mbps
${pcap_file}     /home/ute/logs/CB012631/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.pcap
${SCF_file}      /home/ute/logs/CB012631/SCF_TTI.xml
${CSV_PATH}      /home/ute/logs/CB012631.dlAndUl.csv


*** Test Cases ***
[1][1.0] CB012631_C_6_Verify_eMBB_UE_Semi_Automatic_SSSG_configuration_FDD
    [Tags]    QC_279841    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    Verify gNB behavior when configuring multiple eMBB UEs with SSSG > 0 using semi-automatic config in FDD.
    [Setup]   Prepare Test for CB012631 C 6
    Log To Console    \nStarting test case execution...
    Wait For Next Full Pm Interval
    Common Start Ttitrace With Streaming Mode 3 Custom    @{cell_id}
    slog.Start Syslog    ${Log_Path}    syslog.LOG

    UE Register And Verify Searchspace Config    ${UE_51}    ${monitorsl4_0}
    Sleep    60s
    Run And Validate Traffic    UE_ID=${UE_51}    unit=${mbps}    dl_rate=${high_rate}    ul_rate=${high_rate}

    Sleep    30s
    Log To Console    \nRegistering and validating UE 52
    UE Register And Verify Searchspace Config    ${UE_52}    ${monitorsl4_1}
    Sleep    40s
    Run And Validate Traffic    UE_ID=${UE_52}    unit=${mbps}    dl_rate=${high_rate}    ul_rate=${high_rate}

    Sleep    60s
    Log To Console    \nRegistering and validating UE 56
    UE Register And Verify Searchspace Config    ${UE_56}    ${monitorsl4_2}
    Sleep    40s
    Run And Validate Traffic    UE_ID=${UE_56}    unit=${mbps}    dl_rate=${high_rate}    ul_rate=${high_rate}

    Sleep    60s
    Stop Ttitrace Collection    ${log_path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    @{val144}=    Get Pm Counter Value    M55308C00144    MRBTS-1/NRBTS-1/NRCELL-7    ${pm_counter_file}
    Log To Console    \nM55308C00144 value = @{val144}

    @{val145}=    Get Pm Counter Value    M55308C00145    MRBTS-1/NRBTS-1/NRCELL-7    ${pm_counter_file}
    Log To Console    \nM55308C00145 value = @{val145}

    Log To Console    \nCounter verification for REDCAP UE...
    @{val148}=    Get Pm Counter Value    M55308C00148    MRBTS-1/NRBTS-1/NRCELL-7    ${pm_counter_file}
    Log To Console    \nM55308C00148 value = @{val148}

    @{val149}=    Get Pm Counter Value    M55308C00149    MRBTS-1/NRBTS-1/NRCELL-7    ${pm_counter_file}
    Log To Console    \nM55308C00149 value = @{val149}

    Validate Zero At Required Indexes    ${val144}    ${val145}
    Validate Zero At Required Indexes    ${val148}    ${val149}
    Eventdecoder To Convert Pcap To Eventcsv
    ${Event_CSV}     to_event_csv     ${CSV_PATH}

    ${result}=    sssgValidation   ${Event_CSV}     ${SCF_file}
    Log To Console    \nSSSG validation result: ${result}

    [Teardown]    Run Keyword And Ignore Error    Tear Down For CB012631


*** Keywords ***
Eventdecoder To Convert Pcap To Eventcsv
    taf.converters.eventdecoder.Create Eventdecoder Converter
    ...          name=converter_1
    ...          input_file_path=${pcap_file}
    ...          output_file_path=${Log_path}
    taf.converters.eventdecoder.Convert     converter_1