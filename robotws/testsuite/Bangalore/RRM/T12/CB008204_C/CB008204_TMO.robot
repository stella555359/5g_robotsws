*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G     SBTS00      SBTS23R1     SBTS23R2    SBTS23R3    CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
...              The aim of the feature is to validate the counters introduced in 8204-C.

Resource        resources/Keywords/CB008204_TMO_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${NSA_UEID_11}             11
${PROFILE_ID_1}             1
${SCELLID_11}               5
${PROFILE_ID_2}             2
${TESTMODE_NAME}            phr_override
${ACTIVE}                   activate
${MODIFICATION_CHECK}       Sending SgNB Modification Confirm
${LOG_DIR}            /home/ute/logs
${SCF_C1}             Delta_Configuration_APoABIO_8204Changes_1_TMO.json
${Rev_SCF_C1}         Delta_Configuration_APoABIO_8204Changes_1_reverse_TMO.json
${SCF_C2}             Delta_Configuration_APoABIO_8204Changes_2_TMO.json
${Rev_SCF_C2}         Delta_Configuration_APoABIO_8204Changes_2_Rev_TMO.json
${SCF_C3}             Delta_Configuration_APoABIO_8204Changes_3_TMO.json
${Rev_SCF_C3}         Delta_Configuration_APoABIO_8204Changes_3_Rev_TMO.json
${SCF_C4}             Delta_Configuration_APoABIO_IADU_IntergNB_IAFR_NSA_TMO.json
${Rev_SCF_C4}         Delta_Configuration_APoABIO_IADU_IntergNB_IAFR_NSA_TMO_Rev.json
${CFG_XN_4}           basic_IADU_IntergNB_NSA_TMO.cfg
${CFG_123}            8204_basic_TMO.cfg


*** Test Cases ***
[1][2.0] CB008204_C_1_1_PM_Counters_For_time_on_each_leg_With_UL_Data_Splitting_Bearer_Added_With_UL_On_LTE_NR
    [Documentation]      TC01 - 1
    [Tags]    QC_28347   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Prepare TestCase For TC Setup   CB008204_C1     ${SCF_C1}       ${CFG_123}
    Wait For Next Full Pm Interval
    slog.Start Syslog     ${Log_Path}       SysLogC1.LOG
    ${get_Pid}      Start PCAP On WTS       CB008204_C1
    Set Test Variable        ${get_Pid}
    X2AP Link Should Be UP
    Sleep   20s
    Setup PHR Testmode        1     -23     -23     -63
    Setup PHR Testmode        2     40     40     63
    Make ENDC Call
    Sleep   30s
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Activate TestMode       ${NSA_UEID_11}      ${TESTMODE_NAME}    ${active}    ${PROFILE_ID_1}    ${SCELLID_11}
    Sleep    180s
    Log To Console      PHR activation for Resuming Radio Link
    Activate TestMode       ${NSA_UEID_11}      ${TESTMODE_NAME}    ${active}    ${PROFILE_ID_2}    ${SCELLID_11}
    Sleep       180s
    Stop Traffic    ${NSA_UEID_11}      1
    UE 5GDetach Should Be Successful For NSA    11
    Stop PCAP On WTS        ${get_Pid}
    Run         mv CB008204_C1.pcap ${Log_Path}
    UE Detach Should Be Successful For NSA 8204      11
    Wait For Next Full Pm Interval
    Log To Console      PM counter Validation
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55146C00001   >0     ENDC_UL_DATA_TIME_LTE
    ...     M55146C00002   0     ENDC_UL_DATA_TIME_NR
    ...     M55146C00003   >0     ENDC_UL_DATA_TIME_LTENR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Run     cp ${pm_counter_file} ${Log_Path}
    [Teardown]    Run Keyword And Ignore Error  TearDown TC For CB008204    CB008204_C1.pcap    ${Rev_SCF_C1}

[1][2.0] CB008204_C_2_1_PM_Counters_For_time_on_each_leg_NSA_UEs_With_UL_Data_Splitting_Bearer_Added_With_UL_On_NR
    [Documentation]      TC01-2
    [Tags]    QC_28348   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Prepare TestCase For TC Setup     CB008204_C_2_1      ${SCF_C2}     ${CFG_123}
    Wait For Next Full Pm Interval
    slog.Start Syslog     ${Log_Path}       SysLogC2.LOG
    ${get_Pid}      Start PCAP On WTS       CB008204_C_2_1
    Set Test Variable        ${get_Pid}
    X2AP Link Should Be UP
    Sleep    60s
    Setup PHR Testmode        1     -23     -23     -63
    Setup PHR Testmode        2     40     40     63
    Make ENDC Call
    Sleep   30s
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Log To Console      PHR activation for RLO
    Activate TestMode       ${NSA_UEID_11}      ${Testmode_name}    ${active}    ${Profile_Id_1}    ${Scellid_11}
    Sleep    180s
    Check Egate Logs And Extract Timestamp
    Log To Console      PHR activation for Resuming Radio Link
    Activate TestMode       ${NSA_UEID_11}      ${Testmode_name}    ${active}    ${Profile_Id_2}    ${Scellid_11}
    Sleep    180s
    Check Egate Logs And Extract Timestamp
    Stop Traffic    ${NSA_UEID_11}      1
    UE 5GDetach Should Be Successful For NSA   11
    UE Detach Should Be Successful For NSA 8204     11
    Stop PCAP On WTS        ${get_Pid}
    Run       mv CB008204_C_2_1.pcap ${LOG_PATH}
    Wait For Next Full Pm Interval
    Log To Console      PM counter Validation
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55146C00001   >0     ENDC_UL_DATA_TIME_LTE
    ...     M55146C00002   >0     ENDC_UL_DATA_TIME_NR
    ...     M55146C00003   0     ENDC_UL_DATA_TIME_LTENR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Run     cp ${pm_counter_file} ${LOG_PATH}
    [Teardown]      Run Keyword And Ignore Error        TearDown TC For CB008204    CB008204_C_2_1.pcap     ${Rev_SCF_C2}

[1][2.0] CB008204_C_3_1_PM_Counters_For_time_on_each_leg_NSA_UEs_With_UL_Data_Splitting_Bearer_Added_With_UL_On_LTE
    [Documentation]      TC01-3
    [Tags]    QC_28350   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Prepare TestCase For TC Setup   CB008204_C3     ${SCF_C3}       ${CFG_123}
    Wait For Next Full Pm Interval
    slog.Start Syslog     ${Log_Path}       SysLogC3.LOG
    ${get_Pid}      Start PCAP On WTS       CB008204_C3
    Set Test Variable        ${get_Pid}
    X2AP Link Should Be UP
    Make ENDC Call
    Sleep   30s
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Sleep    30s
    Stop Traffic    ${NSA_UEID_11}      1
    UE 5GDetach Should Be Successful For NSA    11
    Stop PCAP On WTS        ${get_Pid}
    Run       mv CB008204_C3.pcap ${LOG_PATH}
    UE Detach Should Be Successful For NSA 8204      11
    Wait For Next Full Pm Interval
    Log To Console      PM counter Validation
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55146C00001   >0     ENDC_UL_DATA_TIME_LTE
    ...     M55146C00002   0     ENDC_UL_DATA_TIME_NR
    ...     M55146C00003   0     ENDC_UL_DATA_TIME_LTENR
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Run     cp ${pm_counter_file} ${LOG_PATH}
    [Teardown]       Run Keyword And Ignore Error        TearDown TC For CB008204    CB008204_C3.pcap    ${Rev_SCF_C3}

[1][2.0] CB008204_C_4_4_PM_Counters_For_time_on_each_leg_NSA_UEs_With_UL_Data_Splitting_Bearer_Added_With_UL_On_LTE_HO_Case
    [Documentation]      TC04-4
    [Tags]    QC_28349   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Prepare TestCase For TC Setup   CB008204_C4     ${SCF_C4}     ${CFG_XN_4}
    Wait For Next Full Pm Interval
    slog.Start Syslog     ${Log_Path}       SysLogC4.LOG
    ${get_Pid}      Start PCAP On WTS       CB008204_C4
    Set Test Variable        ${get_Pid}
    X2AP Link Should Be UP
    Setup X2 With RANSIM GNB
    Make ENDC Call
    Sleep   30s
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Sleep        30s
    Log To Console      HO from Real to RANSIM
    Stop Traffic    ${NSA_UEID_11}      1
    UE 5GDetach Should Be Successful For NSA    11
    UE Detach Should Be Successful For NSA 8204      11
    Stop PCAP On WTS        ${get_Pid}
    Run       mv CB008204_C4.pcap ${LOG_PATH}
    [Teardown]      Run Keyword And Ignore Error        TearDown TC For CB008204    CB008204_C4.pcap    ${Rev_SCF_C4}
