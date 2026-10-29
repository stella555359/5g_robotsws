*** Settings ***
Documentation     :copyright: Nokia
...               :author   : Bhakti Kapatel
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown
Resource        resources/Keywords/CB012631_Keywords.robot
Library         taf.converters.eventdecoder
Library          ../TtiTraceAutomation/tti_trace_verification/main.py
Library          ../TtiTraceAutomation/tti_trace_verification/tti_utilities/eventcsv_conversion.py


*** Variables ***
@{UE_LIST}        1    2    3    4    5    6    7    8    9    10
@{cell_id}        51
${mbps}         mbps
${dl}     10
${ul}       10
&{UE_GROUP_MAP}
...    1=GROUP1
...    5=GROUP1
...    9=GROUP1
...    2=GROUP2
...    6=GROUP2
...    10=GROUP2
...    3=GROUP3
...    7=GROUP3
...    4=GROUP4
...    8=GROUP4

@{GROUP1_PATTERNS}    ${searchSpacesToAddModList}    ${S39}    ${S38}    ${S37}    ${S36}
@{GROUP2_PATTERNS}    ${searchSpacesToAddModList}    ${S35}    ${S34}    ${S33}    ${S32}
@{GROUP3_PATTERNS}    ${searchSpacesToAddModList}    ${S31}    ${S27}    ${S26}    ${S25}
@{GROUP4_PATTERNS}    ${searchSpacesToAddModList}    ${S24}    ${S23}    ${S22}    ${S21}
${pcap_file}     /home/ute/logs/CB012631_CVR/l2stream3_ttitrace/tcpdump_ttitrace/tcpdump_ttitrace.pcap
${SCF_file}      /home/ute/logs/CB012631_CVR/SCF_TTI.xml
${CSV_PATH}      /home/ute/logs/CB012631_CVR.dlAndUl.csv


*** Test Cases ***
[1][1.0] CB012631_TMOUS_CVR_001_Verify_TMOUS_CVR_scenarios
    [Documentation]     Register 10 UEs and verify searchspace configuration group-wise
    [Tags]      QC_292619   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test For CB012631 CVR
    LOG TO CONSOLE    \nStarting CB012631 execution...
    Wait For Next Full Pm Interval
    Common Start Ttitrace With Streaming Mode 3 Custom    @{cell_id}
    slog.Start Syslog       ${Log_Path}     syslog.LOG
    FOR    ${UE_ID}    IN    @{UE_LIST}
        Register And Validate UE    ${UE_ID}
    END
    FOR    ${UE_ID}    IN    @{UE_LIST}
        Run And Validate Traffic    ${UE_ID}    ${mbps}    ${dl}    ${ul}
    END

    LOG TO CONSOLE    \nstarting HO for UE1...
    wtsrunner.Trf Data Stop     ue=1     pdu=1    qfi=1    dir=bi
    ue_meas_cfg_disp     id=1
    Trigger A2 Measurement    1    1    51
    ue_meas_cfg_disp     id=1
    Trigger A3 Measurement    1    7    53

    LOG TO CONSOLE    \n Starting HO for UE 2
    wtsrunner.Trf Data Stop     ue=2     pdu=1    qfi=1    dir=bi
    ue_meas_cfg_disp     id=2
    Trigger A2 Measurement    2    1    51
    ue_meas_cfg_disp     id=2
    Trigger A3 Measurement    1    6    57

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
    [Teardown]    Tear Down For CB012631 CVR


*** Keywords ***
Register And Validate UE
    [Arguments]    ${UE_ID}
    Log To Console    \n--- Registering UE ${UE_ID} ---
    wtsrunner.UE Register   id=${UE_ID}
    ${output}=    Read WTS Output Until Pattern Matches   ${UE_register_complete_pattern}   ${Timeout_SA}
    Initial Success Message For UE Register And Reregister   ${output}
    wtsrunner.Set Pdu Param  ue=${UE_ID}  pdu=${Pdu_session_ID}  trf_type=${Trf_type}  upf=1
    wtsrunner.UE Pdu Session Setup   pdu=${Pdu_session_ID}  ue=${UE_ID}  nwslice=1   gw=${gw_ID}
    ${group}=    Get From Dictionary    ${UE_GROUP_MAP}    ${UE_ID}
    Validate Searchspace By Group    ${group}
    ${PDU_session_setup_output}         Read Wts Output For Pattern And Print Matching Lines
    ...                       ${Initial_context_setup_pattern}       ${Timeout_SA}

Validate Searchspace By Group
    [Arguments]    ${group}
    Run Keyword If    '${group}'=='GROUP1'
    ...    Verify Searchspace Patterns    @{GROUP1_PATTERNS}
    ...    ELSE IF    '${group}'=='GROUP2'
    ...    Verify Searchspace Patterns    @{GROUP2_PATTERNS}
    ...    ELSE IF    '${group}'=='GROUP3'
    ...    Verify Searchspace Patterns    @{GROUP3_PATTERNS}
    ...    ELSE
    ...    Verify Searchspace Patterns    @{GROUP4_PATTERNS}

Verify Searchspace Patterns
    [Arguments]    @{patterns}
    FOR    ${pattern}    IN    @{patterns}
        RUN KEYWORD AND IGNORE ERROR    Read WTS Output Until Pattern Matches    ${pattern}   ${time}
    END

Eventdecoder To Convert Pcap To Eventcsv
    taf.converters.eventdecoder.Create Eventdecoder Converter
    ...          name=converter_1
    ...          input_file_path=${pcap_file}
    ...          output_file_path=${Log_path}
    taf.converters.eventdecoder.Convert     converter_1