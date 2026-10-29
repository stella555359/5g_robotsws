*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    CRT
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Przemyslaw Sas
...              :contact: marcin.plawny@nokia.com, przemyslaw.sas@nokia.com

Resource     CB008239_A_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_common.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_interrat_ho.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008239_A_B4_1_Inter_RAT_ANR_PCI_Status_Change_From_Identified_To_Confirmed
    [Documentation]    Combined scenarios B4_1 & EC_2-8.
    ...                B4_1: This user scenario describes the SA gNB behaviour of the handling of failure metrics evaluation
    ...                of inter-RAT neighbour relation. 5G_RAN_USR_RRM_14666
    ...                EC_2: This user scenario describes the gNB behaviour when inter-RAT B2 measurement report is received
    ...                and gNB-CU identifies that there is no PCI on the list that meet cell quality criteria defined
    ...                by operator in inter-RAT ANR profile. 5G_RAN_USR_RRM_14670, 5G_CP_MM_2890
    ...                EC_3: Testcase verifies the gNB behaviour when inter-RAT B2 measurement report is received
    ...                and gNB-CU-CP identifies that UE is not capable for EUTRA CGI reporting
    ...                5G_RAN_USR_RRM_14671, 5G_CP_MM_2892
    ...                EC_4: This user scenario describes the gNB behaviour when B2 measurement report is received
    ...                and gNB-CU-CP identifies that (overall) currently existing NRREL and NRRELE instances for the gNB
    ...                reached the limit (NRBTS.maxNumNrAnrMoiAllowed)
    ...                5G_RAN_USR_RRM_14672, 5G_CP_MM_2898
    ...                Additional checking of counter that indicates the absolute number of EUTRA Neighbor Relations
    ...                that cannot be created in network plan file by Inter-RAT ANR due to NRCELL level limits
    ...                EC_6: This user scenario describes the gNB behaviour when there is a failure of EUTRA PCI resolution
    ...                procedure due to no response on RRC reconfiguration with measurement configuration with
    ...                EUTRA CGI Info report. 5G_RAN_USR_RRM_14674, 5G_CP_MM_2894
    ...                EC_7: This user scenario describes the gNB behaviour when there is a failure of EUTRA PCI resolution
    ...                procedure due to RRC re-establishment instead of response on RRC reconfiguration with measurement
    ...                configuration with EUTRA CGI Info report. Counters Number of inter-RAT reportCGI is incremented.
    ...                RRC Re-establishment procedure is ongoing. 5G_RAN_USR_RRM_14675, 5G_CP_MM_2896
    ...                EC_8: This user scenario describes the gNB behaviour when timer T321 pops up after
    ...                sending RRCReconfigurationComplete after B2 measurement
    ...                After that A2 measurement is reconfigured again. 5G_RAN_USR_RRM_14676, 5G_CP_MM_2894

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=11  pdu_id=11  gw_id=11
    Set Amf To Fail Handover And Send B2 Measurement    ue_id=11  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    ...    Handover_required_msg=1
    Unlock handover in Amf and Attempt To Make Handover Based On A2 And B2 Measurements    ue_id=11  meas_idA2=5
    ...  meas_idB2=7
    Verify Traces For EUTRA CGI Reconfiguration and Successfull InterRAT HO
    Verify Created NRADJECELL And NRRELE Objects
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_obj_removal.json
    Wait For Next Full Pm Interval

    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=2  nrsrp_nr=30
    Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    ...    Eutra_cgi_report=1  Handover_required_msg=2
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07001  0  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  0  NRRCC_EUTRACGI_REPORT_RECV
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=15
    Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    ...    Eutra_cgi_report=1  Handover_required_msg=2
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07001  0  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  0  NRRCC_EUTRACGI_REPORT_RECV
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=10
    Drop EutraCgi    ue_id=10
    Sleep    2s    reason=Delay between sending measurments
    Send B2 Measurement And Attempt Handover    ue_id=10  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO
    ...    Meas_gap=2  Eutra_cgi_report=2
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07001  1  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  0  NRRCC_EUTRACGI_REPORT_RECV
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=12
    RRC Reestablish    ue_id=12
    Sleep    2s    reason=Delay between sending measurments
    Send B2 Measurement And Attempt Handover    ue_id=12  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO with Reestablishment report
    ...    Meas_gap=3  Eutra_cgi_report=3  Reconf_report_noconf=7  Handover_success_msg=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07001  1  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  0  NRRCC_EUTRACGI_REPORT_RECV
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=13
    Delay For T321 Timeout    ue_id=13
    Send B2 Measurement And Attempt Handover    ue_id=13  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO with A2 event
    ...    Meas_gap=4  Eutra_cgi_report=4  Reconf_report_noconf=9  Reconf_a2=3  Handover_success_msg=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07001  1  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  0  NRRCC_EUTRACGI_REPORT_RECV
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1  parameter=maxNumNrAnrMoiAllowed  value=0
    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=4
    Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    ...    Eutra_cgi_report=4  Handover_required_msg=2
    Wait For Fault To Be Up    fault_id=${FAULT_ID_MAX_RELATION_ANR}  timeout=300
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C02004  1  NRRCC_MEAS_B2_REC_UNKEPCI
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1  parameter=maxNumNrAnrMoiAllowed  value=5
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRANRPRE-1  parameter=maxNumAnrNrrelePerCell  value=0
    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=5
    Wait For Next Full Pm Interval
    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=6
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01502  1  NMOCU_ANR_NRRELE_OVER_LIMIT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
