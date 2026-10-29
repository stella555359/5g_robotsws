*** Settings ***
Force Tags    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CLOUD_5G_I_LO_AP_LO    CONFIGURED
...           PY310    CIT    SBTS00    SBTS23R2    NoResUsage    RAN_5G_TDD    RAN_5G    RF50

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Adrian Wojtyna
...              :contact: marcin.plawny@nokia.com, adrian.wojtyna@nokia.com

Resource    CB008241_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_scfc.xml
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_TDD_FDD.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8241_9009_common.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_inter_gnb_inter_freq_8239.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_scfc.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008241_A_B1_SA_ANR_PCI_And_NRREL_Add_Intra_gNB_UE_Based
    [Documentation]    This user scenario describes the gNB behaviour for the automatic addition of new Inter Frequency,
    ...                Intra-gNB Intra-NR Neighbour for SA and also gNB behaviour when there is a delta plan update from CU-OAM
    ...                and ANR functionality for SA is enabled but there are no conflicts detected according to 5G_CP_ARC_ALG_1379.
    ...                5G_RAN_USR_RRM_15859, 5G_RAN_USR_RRM_15861, 5G_RAN_USR_RRM_15862, 5G_RAN_USR_RRM_15876

    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=1  meas_id=3
    Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And Inter Frequency HO
    ...    meas_id_to_remove_list=2    Handover_success_msg=2
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
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_with_conflicts_to_trigger_B_B3_scenario.json
    Wait For Object To Exist    object_name=XNLINK_A-2  moc=XNLINK_A  timeout=${NRREL_OBJECT_CREATION_TIME}
    Check If Object Doesnt Exist    object_name=NRADJGNB_A-3  moc=NRADJGNB_A
    Wait And Verify Created NRREL Object    gnb_id=1
    Attach UE    ue_id=2
    Establish PDU Session With Traffic    ue_id=2  pdu_id=2  gw_id=2
    Add Scout External Execution ID To Reporting Portal

CB009009_B_B6_1_Inter_RAT_ANR_SA_Disable_UL_Proactive_Grant_Scheduling_To_Allow_Inter_RAT_ANR_EUTRA_CGI_Measurement_Reporting
    [Documentation]    This test case describes the gNB behaviour when UL proactive grant scheduling is disabled for the UE,
    ...                to give more time to read SIB information of neighbor cell.
    ...                gNB receive B2 measurement report from UE and indetifies that PCIs (Physical Cell ID) are not present
    ...                in any of NRADJECELL pointed by NRRELE cell configuration. gNB identify neighbour cell whose quality
    ...                indicators meets the operator defined thresholds. If UE has capability for eutra-CGI-Reporting
    ...                and Long DRX cycle (discontinuous reception) is supported, than gNB shall release measurement gap.
    ...                After measurement gap is released in UE, DRX need to be setup. When DRX configuration is setup
    ...                gNB disable the UL proactive grant scheduling for UE (When proactive scheduling is disabled,
    ...                then gNB periodically doesn't schedule UL grant towards UE. UE won't send UL transmission which
    ...                unnecessarily creates some UL interferences). Object NRRELE has to be created in SCF and Inter-RAT
    ...                handover procedure finished successfully. 5G_RAN_USR_RRM_1511

    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=11
    Send B2 Measurement    ue_id=11    meas_id=5
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_SEND_TO_DU}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_MEAS_GAP_SET_TO_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTERRAT}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_INTERRAT}
    Verify Existing NRRELE
    Verify Successfull InterRAT HO
    Add Scout External Execution ID To Reporting Portal

5GC002198_A_B1_4_ENDC_PCI_Resolution_And_Neighbour_Relation_Addition_Intra_GNB_UE_Based_With_MeNB_Coordination_No_SRB3
    [Documentation]    This Test Case verifies gNB behaviour for the automatic addition of new Inter Frequency, Intra-gNB Neighbour for EN-DC
    ...                After UE sends A5 measurement NRCGI is being sent automatically
    ...                After HO is done NNREL-256 for CELL-1 should be created
    ...                Seperate delta for removing NRREL is done because if test fails before HO, NRREL is not created and whole delta would fail.
    ...                In Suite Teardown, Stop Default Processes And Gather Logs And Compress Logs is not the last keyword
    ...                because default delta causes reset site which would interrupt collecting logs

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_2198.json
    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=21
    Attach Ue To Enb                 ue_id=21
    Start Gnb Addition Procedure     ue=21    target_gnb=2    target_cells=2    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Send Custom Ue Measurement Nr    id=21    meas_id=1    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=21    meas_id=4    event=A5    srsrp_nr=19    phycell_id=50    nrsrp_nr=68
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${DRX_SETUP}    number_of_messages=1    relation_symbol=>=
    Verify Existing NRREL
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C05001   +1    NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05001   +1    RRCC_NRCGI_REPORT_RECV
    ...    M55147C01001   +1    NMOCU_ANR_NRREL_ADD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal
