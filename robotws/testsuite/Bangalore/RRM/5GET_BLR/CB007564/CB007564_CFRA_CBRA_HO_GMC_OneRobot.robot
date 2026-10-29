*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB007564/CB007564_NSA_IntragNB_HO_CBRA.yml
#Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB007564/CB007564_NSA_IntragNB_HO_CBRA.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Documentation
...
...     INTRODUCTION:This feature provides new Performance Measurement counters that are used for Network Performance
...     measurement and the creation of new or improvement of existing KPIs.
...     The Feature introduces PM counters related to :
...     Stand Alone Architecture: (CB007564 A & B)
...         Accessibility counters:
...             These counters are used to measure the accessibility or successful setup of QoS Flow.
...         Retainability counter:
...             These counters are used to measure the issues causing QOS Flow releases in the network
...             These counters are used to measure the issues causing DRB to be released in the gNB
...     Non-Stand Alone Architecture: ( CB007564-C )
...         RACH counters
...             These counters are used to measure the success of the RACH procedure for both
...             CFRA (Contention Free Random Access ), CBRA (Contention Based Random Access)
...
...     TEST SET NAME:  CB007564-C
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : CB007564-C to check the Rach counters for CBRA_INIT, CFRA_INIT, CBRA_HO and CFRA_HO
...     Test Cases Review (Collaborator Details):
...         Test Plan               :  https://collab.ext.net.nokia.com/ui#review:id=844749
...         Testability Requirement :  https://collab.ext.net.nokia.com/ui#review:id=843927
...         Robot scripts Review    :  https://collab.ext.net.nokia.com/ui#review:id=849955
...         Feature Test Strategy   :  https://collab.ext.net.nokia.com/ui#review:id=847285
...         ET Confluence Page Link :  https://confluence.ext.net.nokia.com/display/ETB/CB007564-C
...
...     REFERENCES:  CFAM CB00756-C
...
...     TERMS AND ABBREVIATIONS:  -
...
...     HISTORY:  History, current status and TC description is available in repository:
...                [20.12.2021] - Created TCs
...                [18.01.2021] - Updates to Test suite documentation update and Keywords done
...                [18.01.2022] - Test suite documentation update.
...
...               Test Case Scenario author   : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case Scenario contact  : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case automation author : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case automation contact: Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Creation Date               : 1-December-2021
...               Modified Date               : 27-January-2022
...               Modified Date                :22-June-2022  - ( updated the script for EDA to include intragNB HO)
...               Last Modified by            : Nagesh.k_v@nokia.com,vandana.b@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ./resources/Lib/induce_delay.py
#Resource         resources/CB007564_Keywords.robot
Resource         resources/CB007564_Keywords_CBRA_HO_GMC.robot
Resource         resources/CB007564_Keywords_suitesetup.robot
Resource         resources/CB007564_Resource_suitesetup.robot
Resource         ../resources/robot/common_log_collection.robot


#Suite Setup        Run keywords     Prepare TL with all config files
#...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
##Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Perform SCF Delta Commissioning with delta_cfra_init.json
#...                 AND     CB007564_Resource_suitesetup.Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     CB007564_Keywords_suitesetup.Check gNB Bulid

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     CB007564_Resource_suitesetup.Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     CB007564_Keywords_suitesetup.Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Test Setup       Start_capture_testcase_default_logging
#Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${SCFC}=        Bangalore/RRM/ET/CB007564/CB007564_NSA_IntragNB_HO_CBRA_scf.xml
${AP_XML}=      Bangalore/RRM/ET/CB007564/CB007564_NSA_IntragNB_HO_CBRA_iphy.xml
${wts_cfg_file}     ${CURDIR}/config/basic_setup_intragnb_NSA_HO_GMC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        151
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${a3meas_id}   1
${a1meas_id}   3
${Target_Cells}    3
${epc_log_path}    /tmp/
${EXPECTED_PCELL_VALUE1}   300
${EXPECTED_PCELL_VALUE2}   300
${EXPECTED_PCELL_VALUE3}   1
${EXPECTED_SCELL_VALUE1}   27000
${EXPECTED_SCELL_VALUE2}   1
${TEST_NAME}     CFRA_HO
#${TEST_NAME_2}      CBRA_HO

*** Test Cases ***
[1]CB007564-C_TC2_CFRA_HO_procedure_Counter_M55125C09022_total_number_of_times_dedicated_preambles_are_sent_to_Ue
    [Documentation]  Verifying the CFRA HO counters

    ${TEST_NAME}    Set Variable   CFRA_HO
    set suite variable     ${TEST_NAME}
    Perform SCF Delta Commissioning with delta_cfra_init_HO_GMC.json
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with delta_Create_NRREL.json
    ${start_time}=      DateTime.Get Current Date    result_format=%H:%M:%S
    log to console        /***************The current time is ${start_time} ****************/
    Link SCOUT SCF to Configuration ID for Reporting
    Wait until the next Measurement Period starts
    Attach UE and Trigger A3 Measurement
    UE Detach should be Successful
    sleep    5s
    Attach UE and Trigger A3 Measurement
    UE Detach should be Successful
    sleep    5s
    Attach UE and Trigger A3 Measurement
    UE Detach should be Successful
    Wait until the next Measurement Period starts
    Verify Counters CB007564 CFRA HO GMC
    [Teardown]      Run Keywords
    ...             Perform SCF Delta Commissioning with delta_default_cbrapreamble_4cells_HO_GMC.json
    ...             AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

[1]CB007564-C_TC7_CBRA_HO_procedure_counter_M55306C09007_Number_of_time_RA_setup_is_successful_with_CRC_OK_and_Contention_is_resolved_due_to_HO
    [Documentation]  Verifying the CFRA HO & CBRA HO counters as part of EDA https://jiradc.ext.net.nokia.com/browse/MNRCA-70427
    ...    This file CB007564_CBRA_IntraGnb_HO_EDA_GMC.robot created as part of GMC migration.

    ${TEST_NAME}    Set Variable   CBRA_HO
    set suite variable     ${TEST_NAME}
    CB007564_Resource_suitesetup.Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
    sleep   30s
    Perform SCF Delta Commissioning with delta_cfra_init_Cell-4.json
    sleep   30s
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
#As part of EDA https://jiradc.ext.net.nokia.com/browse/MNRCA-70427
#Adding The CFRA HO counters (M55125C09022),(M55306C09001) and CBRA Init & CBRA counters (M55306C09011),(M55306C09006),(M55306C09007)
    Wait until the next Measurement Period starts
    Link SCOUT SCF to Configuration ID for Reporting
    Attach UE and Trigger A3 Measurement CBRA
    Trigger HO to Target cell       1   53
    sleep    5s
    Trigger HO to Target cell       1   52
#As part of EDA https://jiradc.ext.net.nokia.com/browse/MNRCA-70427
#Adding The CBRA HO counters (M55306C09007),(M55306C09015)
    Verify Counters CB007564 CFRA HO EDA GMC
    Perform SCF Delta Commissioning with delta_cbra_init_Cell-4.json
    Wait until the next Measurement Period starts
    sleep       5s
    Trigger HO to Target cell       1   53
    sleep       6s
    Verify Counters CB007564 CBRA HO EDA GMC
    UE Detach should be Successful


*** Keywords ***
Attach UE and Trigger A3 Measurement
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID}
    CB007564_Keywords_CBRA_HO_GMC.UE Attach should be Successful    ${UE_ID}
    Get Configured Measurements of UE${UE_ID}
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO   ${UE_ID}    ${a3meas_id}   53

Attach UE and Trigger A3 Measurement CBRA
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID}
    CB007564_Keywords_CBRA_HO_GMC.UE Attach should be Successful    ${UE_ID}

Trigger HO to Target cell
    [Arguments]     ${a3meas_id}   ${Target_cell}
    Get Configured Measurements of UE${UE_ID}
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO   ${UE_ID}    ${a3meas_id}   ${Target_cell}

Start Big Data and trigger A1 for scell addition
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger A1 Measurement and verify Scell added successfully   ${UE_ID}    ${a1meas_id}
    sleep    10s
    Run Keyword And Continue on Failure    Validate DL Traffic For NSA for Maximum high data   ue_id=${UE_ID}     dl_rate=400
    Verify DL Tput For 2CC NSA
    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add

Start Low Data Traffic And Check Scell Deactivation
    Start Collecting Syslog     NAME=scell_remove
#    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=1     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=2     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=3     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=4     dir=dl

    Trigger DL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     dl_rate=10     trf_id=1
    sleep    5s
    Trigger UL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     ul_rate=10     trf_id=1
    sleep    5s     reason=Wait for successful traffic start
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
	Run Keyword and continue on failure   Verify Low Data Traffic NSA
#	Run Keyword and Ignore error    Stop CPRT capture   ${CaptureCPRT}
    Run Keyword and Ignore error    Stop Collecting Syslog      NAME=scell_remove
    Run Keyword and Ignore error   Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=0.010
    UE Detach should be Successful
    Run Keyword and continue on failure    Verify Counters_scelldeact    300    0    0    0    0


Verify Counters_scelladd
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-3

Verify Counters_scelldeact
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-3
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-3


Validate PM Counters_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-3

Verify Counters_scelladd M55115C03001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
