*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           CRT    SBTS23R2    SBTS00    SBTS23R1    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Adrian Wojtyna, Marcin Szulc
...              :contact: adrian.wojtyna@nokia.com, marcin.szulc@nokia.com

Resource    CB008241_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_TDD_FDD.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8241_common.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_inter_gnb_inter_freq_event_A2_A5.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Wait For Testline Icmp Echo Replies And Ssh Services
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008241_A_B2_SA_ANR_PCI_And_NRREL_Add_Inter_gNB_Inter_gNB
    [Documentation]    This user scenario test gNB behavior:
    ...                - Step 1: unknow PCI from other gNB is reported by UE in intreFreq A5 measurement;
    ...                - Step 2: new NRREL and NRADJNRCELL is reported to OAM;
    ...                - Step 3: via ANR relation gNB perform legacy HO (not ANR HO);
    ...                - Step 4: ANR take care of relation (revalidating it when counter is reached).
    ...                5G_RAN_USR_RRM_15863, 5G_RAN_USR_RRM_15860, 5G_RAN_USR_RRM_15861, 5G_RAN_USR_RRM_15862
    ...                5G_RAN_USR_RRM_15880

    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=1    meas_id=3    target_phycell_id=251
    Verify Created NRADJNRCELL And NRREL Objects    PCI=251    gNB_id=4
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=2    meas_id=3    target_phycell_id=251
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  1  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Traces For Ng Handover
    Verify Traces For Xn Handover     Meas_gap=1    NR_CGI_report=1    Handover_success_msg=1    Handover_request_msg=1    UE_CtxRel_msg=2
    Set Gnb To Fail Handover Preparation    gnb_id=4
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=3    meas_id=3    target_phycell_id=251
    Send A5 Measurement And Attempt Handover    ue_id=3    meas_id=3    target_phycell_id=251
    Send A5 Measurement And Attempt Handover    ue_id=3    meas_id=3    target_phycell_id=251
    Wait And Verify NRREL Object Still Exist    gnb_id=4
    Reset Gnb Param For Successfull Handover Preparation    gnb_id=4
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=4    meas_id=3    target_phycell_id=251
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  0  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  1  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  1  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Traces For Xn Handover    Meas_gap=2    NR_CGI_report=3    Handover_success_msg=2    Handover_request_msg=5    UE_CtxRel_msg=3
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=5    meas_id=4    target_phycell_id=252
    Check If Object Doesnt Exist    object_name=NRREL_A-255    moc=NRREL_A
    Check Bearer Stats    ue_id=5    pdu_id=1    dir=dl
    Stop Data Traffic    ues=5    direction=dl    pdu=1
