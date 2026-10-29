*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    CRT
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Przemyslaw Sas
...              :contact: marcin.plawny@nokia.com

Resource     CB008239_A_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_common.json
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/scf_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_interrat_ho.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008239_A_B3_1_Inter_RAT_ANR_PCI_Resolution_For_Neighbour_Relation_With_RECHECK_Required
    [Documentation]    This user scenario describes the SA gNB behaviour of the handling of update for inter-RAT
    ...                neighbour relation with RE-CHECK state
    ...                5G_RAN_USR_RRM_14665

    Attach Ue And Establish Pdu Session And Send B2 Measurement    ue_id=11  pdu_id=11  gw_id=11  meas_id=3
    Verify Created NRADJECELL And NRRELE Objects
    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=12  pdu_id=12  gw_id=12  meas_id=1
    Set Amf To Fail Handover And Send B2 Measurement   ue_id=12  meas_id=3
    Send B2 Measurement And Attempt Handover    ue_id=12  meas_id=3
    Send B2 Measurement And Attempt Handover    ue_id=12  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    ...    Handover_required_msg=4  Handover_failure=3
    Set Amf To Not Fail Handover Preparation
    Send B2 Measurement And Attempt Handover    ue_id=12  meas_id=3
    Verify Traces For EUTRA CGI Reconfiguration and Successfull InterRAT HO  Handover_required_msg=5
    ...    Handover_command_msg=2  Handover_notify_msg=2  Handover_success_msg=2  Eutra_cgi_report=2
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01501  1  NMOCU_ANR_NRRELE_ADD
    ...    M55147C01502  0  NMOCU_ANR_NRRELE_OVER_LIMIT
    ...    M55124C07001  2  NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    M55124C07002  2  NRRCC_EUTRACGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True


