*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G     SBTS00     SBTS23R1      SBTS23R2    SBTS23R3    CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
...             The aim of the feature is to validate the counters introduced in 8204-C.

Resource        resources/Keywords/CB008204_C_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${NSA_UEID_11}        11
${PROFILE_ID_1}       1
${SCELLID_11}         5
${PROFILE_ID_2}       2
${TESTMODE_NAME}      phr_override
${ACTIVE}             activate
${LOG_DIR}              /home/ute/logs


*** Test Cases ***
[1][2.0] CB008204_C_2_1_PM_Counters_For_time_on_each_leg_NSA_UEs_With_UL_Data_Splitting_Bearer_Added_With_UL_On_NR
    [Documentation]      TC01-2
    [Tags]    QC_28348   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008204_C_2_1
    Link SCOUT SCF to Configuration ID for Reporting
    Run         sudo rm -rf ${LOG_DIR}/${Test_CaseNumber}*
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${LOG_PATH}         Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    Set Test Variable       ${LOG_PATH}
    Log To Console      Starting the test......
    GNB Delta Commission     ${CURDIR}/config/scf/Delta_Configuration_APoABIO_8204Changes_2_1.json
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Create Basic Interface On UTE
    Start UTE WTS      8204_basic.cfg
    Wait For Next Full Pm Interval
    ${get_Pid}      Start PCAP On WTS       ${Test_CaseNumber}
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
    Run       mv ${Test_CaseNumber}.pcap ${LOG_PATH}
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
    [Teardown]      Run Keywords        Stop PCAP On WTS        ${get_Pid}
    ...     AND     Run       mv ${Test_CaseNumber}.pcap ${Test_CaseNumber}
