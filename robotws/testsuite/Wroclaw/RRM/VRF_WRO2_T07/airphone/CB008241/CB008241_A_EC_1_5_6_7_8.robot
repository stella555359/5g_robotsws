*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           CRT    SBTS23R2    SBTS00    SBTS23R1    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Bartosz Grzegorczyk, Marcin Plawny, Tomasz Niedzwiedzki
...              :contact: bartosz.grzegorczyk@nokia.com, marcin.plawny@nokia.com, tomasz.niedzwiedzki@nokia.com

Resource    CB008241_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_TDD_FDD.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8241_A_EC_1_5_6_7_8.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_inter_gnb_inter_freq_event_A2_A5.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_8241_A_EC_1_5_6_7_8.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008241_A_EC1_Failure_NRCGI_report_contains_noSIB1_in_CGI_Info
    [Documentation]    This user scenario describes the gNB behaviour when Inter-Frequency NRCGI report is received
    ...                with noSIB1 set in CGI-Info for SANSA ANR
    ...                5G_RAN_USR_RRM_15866    EDA Action for 03882965

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=2
    Report NoSIB1    ue_id=2
    Get Ue Measurement Configuration    ue_id=2
    Set Gnb To Fail Handover Preparation    gnb_id=3
    Verify Traces For Handover    number_of_messages=0
    Send A5 Measurement And Attempt Handover    ue_id=2    meas_id=3    target_phycell_id=60
    Verify Traces For MeasGapConfig After first A5 Event From UE
    Verify Traces For cellForWhichToReportCGI_60
    Verify Traces For DRX Config Release After A5 Event From UE
    Verify Traces For Handover    number_of_messages=0
    Send A2 Measurement    ue_id=2    meas_id=5
    Send A5 Measurement And Attempt Handover    ue_id=2    meas_id=7    target_phycell_id=151
    Verify Traces For MeasGapConfig After Second A5 Event From UE
    Verify Traces For cellForWhichToReportCGI_151
    Verify Traces For DRX Config Release After A5 Event From UE    number_of_messages=2
    Verify Traces For Handover    number_of_messages=0
    Verify Syslog For Given Number Of Messages    number_of_messages=0    regexp=Error Handler exception report
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C05001  2  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  1  NRRCC_NRCGI_REPORT_RECV
    ...    M55147C00022  1  STA_UNAVAIL_NRREL_HO_FAILS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=all
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008241_A_EC6_Failure_measConfig_T321exp_RRCReconfig_NRCGI_Report_configuration
    [Documentation]    This user scenario describes the gNB behaviour when there is a failure of PCI resolution procedure
    ...                due to no response on RRC reconfiguration with measurement configuration with NR CGI Info report
    ...                5G_RAN_USR_RRM_15871

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=1
    Drop NrCgi    ue_id=1
    Get Ue Measurement Configuration    ue_id=1
    Send A5 Measurement And Attempt Handover Without Delay    ue_id=1    meas_id=3
    Verify Traces For Reconfiguration Containing NR CGI Measurement Report Configuration And HO    Handover_success_msg=0
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C05001  1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  0  NRRCC_NRCGI_REPORT_RECV
    ...    M55147C00022  1  STA_UNAVAIL_NRREL_HO_FAILS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008241_A_EC7_SA_ANR_PCI_FAIL_measConf_NR-CGI_Info_RRCReestablish_ins_RRCReconfComp_while_nrCGI_measReaport_conf
    [Documentation]    This user scenario describes the gNB behaviour when there is a failure of PCI resolution procedure
    ...                due to RRC re-establishment instead of response on RRC reconfiguration with measurement configuration
    ...                with NR-CGI Info report. 5G_RAN_USR_RRM_15872

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=2
    RRC Reestablish    ue_id=2
    Get Ue Measurement Configuration    ue_id=2
    Send A5 Measurement And Attempt Handover Without Delay    ue_id=2  meas_id=3
    Verify Traces For Reconfiguration Containing NR CGI Measurement Report Configuration And HO    Handover_success_msg=0
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C05001  1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  0  NRRCC_NRCGI_REPORT_RECV
    ...    M55147C00022  1  STA_UNAVAIL_NRREL_HO_FAILS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=2
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008241_A_EC8_SA_ANR_PCI_Failure_No_measurement_report_with_NR-CGI_info_T321_timer_expiration
    [Documentation]    This user scenario describes the gNB behaviour when there is a failure of PCI resolution procedure
    ...                due to T321 timer expiration instead of measurement report with NR-CGI Info. 5G_RAN_USR_RRM_15873

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=3
    Delay For T321 Timeout    ue_id=3
    Get Ue Measurement Configuration    ue_id=3
    Send A5 Measurement And Attempt Handover Without Delay    ue_id=3  meas_id=3
    Verify Traces For Reconfiguration Containing NR CGI Measurement Report Configuration And HO    Handover_success_msg=0
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C05001  1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  0  NRRCC_NRCGI_REPORT_RECV
    ...    M55147C00022  1  STA_UNAVAIL_NRREL_HO_FAILS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=3
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008241_A_EC5_Failure_A3A5_MeasReap_When_NRREL_Reached_The_Limit
    [Documentation]    This user scenario describes the gNB behaviour when A3/A5 measurement report is received
    ...                and gNB-CU-CP identifies that (overall) currently existing NRREL instances for the gNB reached
    ...                the limit (NRBTS.maxNumNrAnrMoiAllowed)
    ...                Note: This test have to be last in test suite for other tests counter verification to work properly.
    ...                In a case of adding new tests with counter verification to this test suite, remember about time synchronization.
    ...                You can synchronize time for counter file by using keyword "Wait For Next Full Pm File" in test
    ...                setup of those new tests.
    ...                5G_RAN_USR_RRM_15870

    Perform Parameter Commissioning    parameter=maxNumNrAnrMoiAllowed  value=1
    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=5
    Send A5 Measurement And Attempt Handover Without Delay    ue_id=5
    Verify Traces For No Reconfiguration Containing NR CGI Measurement Report Configuration

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=5
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

