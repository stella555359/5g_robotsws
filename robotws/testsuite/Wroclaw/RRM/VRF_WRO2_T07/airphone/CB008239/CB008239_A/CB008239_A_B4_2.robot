*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310    SBTS00    CRT
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource     CB008239_A_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8239_common.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_interrat_ho.lua
...            AND             Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRANR-1  parameter=consecHoFailThresEutra  value=2
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008239_A_B4_2_Inter_RAT_ANR_Consecutive_Handover_Failure_Count_Reset
    [Documentation]    This user scenario describes the SA gNB behaviour of the handling of failure metrics evaluation
    ...                of inter-RAT neighbour relation
    ...                5G_RAN_USR_RRM_14666

    Attach Ue And Establish Pdu Session And Send B2 Measurement   ue_id=11    meas_id=3    pdu_id=11    gw_id=11
    Verify Created NRADJECELL And NRRELE Objects
    Attach Ue And Establish Pdu Session And Send A2 Measurement   ue_id=12   pdu_id=12  gw_id=12
    Set Amf To Fail Handover And Send B2 Measurement   ue_id=12  meas_id=3
    Set Amf To Not Fail Handover Preparation
    Send B2 Measurement And Attempt Handover    ue_id=12   meas_id=3
    Verify Traces For Failed And Successful HO Without PCI Resoultion
    Attach Ue And Establish Pdu Session And Send A2 Measurement   ue_id=13   pdu_id=13  gw_id=13
    Set Amf To Fail Handover And Send B2 Measurement   ue_id=13  meas_id=3
    Send B2 Measurement And Attempt Handover    ue_id=13   meas_id=3
    Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And 2nd Consecutive HO Failure
    Send B2 Measurement And Attempt Handover    ue_id=13   meas_id=3
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}  number_of_messages=2

*** Keywords ***
Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And 2nd Consecutive HO Failure
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}    number_of_messages=5
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_PREPARATION_FAILURE}    number_of_messages=3

