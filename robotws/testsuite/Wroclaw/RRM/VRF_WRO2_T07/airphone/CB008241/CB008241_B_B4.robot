*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC   CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           CRT    SBTS23R2    SBTS00    SBTS23R1    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Bartosz Grzegorczyk, Przemyslaw Sas
...              :contact: bartosz.grzegorczyk@nokia.com

Resource    CB008241_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy_TDD_FDD.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_8241_common.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_inter_gnb_inter_freq_event_A2_A5.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND             Perform Parameter Commissioning
...                               dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=maxNumOfRrcSA    value=275
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_8241_common.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRCELL1_NRREL256.json
...              AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRADJNRCELL.json

*** Test Cases ***
CB008241_B_B4_SA_ANR_Neighbour_relation_removal_due_to_consecutive_RE-CHECK_state_reporting
    [Documentation]    This user scenario describes the gNB behaviour when there is a consecutive RE-CHECK PCI status
    ...                reported for neighbour relation. This test don't verify deletion of NRADJNRCELL object.
    ...                Checking for measGap config presence after A2 event.
    ...                Added CNI130950 Check by UE#5 and UE#6, after CNI at re-check gNB should update all NRADJNRCELL's parameters,
    ...                at this test we checking fiveGsTac will be updated after recheck to value from ng-cgi report.
    ...                SCF: CNI_130950_before_change_TAC_788.xml and CNI_130950_after_ANRchange_TAC_788.xml should be the same
    ...                [1. Detail Test Steps:]
    ...                |-->[SubTest01_Neighbour_relation_removal_due_to_consecutive_RE-CHECK_state_reporting_inter_gNB]
    ...                 UE 1 perform NRREL-256 and NRADJNRCELL-12288 creation via ANR to PCI 151
    ...                 UE 2 perform HO fails for NRREL-256 delete due consecutive recheck
    ...                   for HO fails test useing EGATE command gnb_xn_handover_preparation_param action=force_failure id=
    ...                |-->[SubTest02_Neighbour_relation_removal_due_to_consecutive_RE-CHECK_state_reporting_intra_gNB]
    ...                UE 3 perform NRREL-256 creation via ANR to PCI 51 UE 4 perform NRREL-256 delete due consecutive recheck
    ...                UE 4 perform HO fails for NRREL-256 delete due consecutive recheck
    ...                  for HO fails test useing gNB parameter change in target cell: maxNumOfRrcSA=0 and 5GC000876 RAC fails
    ...                |-->[SubTest03_CNI130950_NRADJNRCELL_update_due_to_RE-CHECK_and_old_CB008241_A_B2]
    ...                UE 5 perform NRREL-256 and NRADJNRCELL-12287 creation via ANR to PCI 153 User perform delta commisioning
    ...                and change NRADJNRCELL-12287 fiveGsTAC value from 788 to 313
    ...                UE 6 perform NRREL-256 and NRADJNRCELL-12287 re-check ANR with HO success to change fiveGsTAC to 788 check
    ...                NRADJNRCELL-12287 have got correct fiveGsTAC value 788
    ...                |-->[SubTest04_EDA_03034748_action]
    ...                UE 7 checking EDA_03034748
    ...                  Checking: ANR enabled with no default NRANRPR or available dedicated ANR profile.
    ...                  No HO and ANR object creation, UE should still be in source cell and shouln't be droped.
    ...                5G_RAN_USR_RRM_15877, 5G_RAN_USR_RRM_15863, 5G_RAN_USR_RRM_15860, 5G_RAN_USR_RRM_15861, 5G_RAN_USR_RRM_15862
    ...                5G_RAN_USR_RRM_15880, EDA_03034748

    SubTest 01 Neighbour Relation Removal Due To Consecutive RECHECK State Reporting Inter gNB
    SubTest 02 Neighbour Relation Removal Due To Consecutive RECHECK State Reporting Intra gNB
    SubTest 03 CNI130950 NRADJNRCELL Update Due To RECHECK And Old CB008241 A B2
    SubTest 04 EDA 03034748 Action

*** Keywords ***
SubTest 01 Neighbour Relation Removal Due To Consecutive RECHECK State Reporting Inter gNB
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=1  meas_id=3  target_phycell_id=151
    Verify Created NRADJNRCELL And NRREL Objects
    Attach Ue And Establish Pdu Session    ue_id=2
    Set Gnb To Fail Handover Preparation
    Send A2 Measurement    ue_id=2  meas_id=1
    Send A5 Measurement And Attempt Handover    ue_id=2  meas_id=3  target_phycell_id=151
    Send A5 Measurement And Attempt Handover    ue_id=2  meas_id=3  target_phycell_id=151
    Send A5 Measurement And Attempt Handover    ue_id=2  meas_id=3  target_phycell_id=151
    Wait And Verify NRREL Object Still Exist    gnb_id=3
    Send A2 Measurement    ue_id=2  meas_id=6
    Verify Traces For MeasGapConfig After A2 Event From UE2
    Send A5 Measurement And Attempt Handover    ue_id=2  meas_id=8  target_phycell_id=151
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-256  moc=NRREL_A  timeout=${NRREL_OBJECT_CREATION_TIME}
    Verify Traces For Xn Handover     Meas_gap=2    NR_CGI_report=2    Handover_success_msg=1    Handover_request_msg=5    UE_CtxRel_msg=1
    Reset Gnb Param For Successfull Handover Preparation

SubTest 02 Neighbour Relation Removal Due To Consecutive RECHECK State Reporting Intra gNB
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=3  meas_id=3  target_phycell_id=51
    Wait And Verify Created NRREL Object    gnb_id=1
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=maxNumOfRrcSA    value=0
    Attach Ue And Establish Pdu Session    ue_id=4
    Send A2 Measurement    ue_id=4  meas_id=1
    Send A5 Measurement And Attempt Handover    ue_id=4  meas_id=3  target_phycell_id=51
    Send A5 Measurement And Attempt Handover    ue_id=4  meas_id=3  target_phycell_id=51
    Send A5 Measurement And Attempt Handover    ue_id=4  meas_id=3  target_phycell_id=51
    Wait And Verify NRREL Object Still Exist    gnb_id=1
    Send A2 Measurement    ue_id=4  meas_id=6
    Send A5 Measurement And Attempt Handover    ue_id=4  meas_id=8  target_phycell_id=51
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-256  moc=NRREL_A  timeout=${NRREL_OBJECT_CREATION_TIME}

SubTest 03 CNI130950 NRADJNRCELL Update Due To RECHECK And Old CB008241 A B2
    Wait For Next Full Pm Interval
    Reset Gnb Param For Successfull Handover Preparation
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=5  meas_id=3  target_phycell_id=153
    Verify Created NRADJNRCELL And NRREL Objects    PCI=153    NRADJNRCELL_ID=12287    NRREL_ID=256
    Get Scfc File    output_filepath=${OUTPUT_DIR}/CNI_130950_before_change_TAC_788.xml
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_CNI_130950.json
    Get Scfc File    output_filepath=${OUTPUT_DIR}/CNI_130950_after_delta_TAC_313.xml
    Attach Ue And Establish Pdu Session    ue_id=6
    Set Gnb To Fail Handover Preparation
    Send A2 Measurement    ue_id=6  meas_id=1
    Send A5 Measurement And Attempt Handover    ue_id=6  meas_id=3  target_phycell_id=153
    Send A5 Measurement And Attempt Handover    ue_id=6  meas_id=3  target_phycell_id=153
    Reset Gnb Param For Successfull Handover Preparation
    Send A5 Measurement And Attempt Handover    ue_id=6  meas_id=3  target_phycell_id=153
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55147C01001  1  NMOCU_ANR_NRREL_ADD
    ...    M55147C01002  0  NMOCU_ANR_NRREL_OVER_LIMIT
    ...    M55124C05001  2  NRRCC_NRCGI_REPORT_CONF_SENT
    ...    M55124C05002  2  NRRCC_NRCGI_REPORT_RECV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Get Scfc File    output_filepath=${OUTPUT_DIR}/CNI_130950_after_ANRchange_TAC_788.xml
    Get Bts Snapshot    output_filepath=${OUTPUT_DIR}/SNAPSHOT_CNI_130950_after_ANRchange_TAC_788.zip
    Verify Created NRADJNRCELL And NRREL Objects    PCI=153    NRADJNRCELL_ID=12287    NRREL_ID=256   fiveGsTac=788
    Verify Traces For Xn Handover    Meas_gap=6    NR_CGI_report=7    Handover_success_msg=3    Handover_request_msg=9    UE_CtxRel_msg=3

SubTest 04 EDA 03034748 Action
    Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO    ue_id=7    meas_id=4    target_phycell_id=252
    Check If Object Doesnt Exist    object_name=NRREL_A-255    moc=NRREL_A
    Check Bearer Stats    ue_id=5    pdu_id=1    dir=dl
    Stop Data Traffic    ues=5    direction=dl    pdu=1
