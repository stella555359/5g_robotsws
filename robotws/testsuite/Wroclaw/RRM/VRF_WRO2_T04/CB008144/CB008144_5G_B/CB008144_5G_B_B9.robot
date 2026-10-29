*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    SBTS23R2    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Ewa Wrzesinska
...              :contact: ewa.wrzesinska@nokia.com
...              :testsuite description: Feature CB008144 introduces sleeping cell detection methods and recovery
...              actions to 5G. Detection and recovery actions are based on newly introduced counters.

Resource        ../CB008144_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_b_b9_activation.json
    ...         AND             Set Counter Collecting Interval To Five Minutes
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords   Detach Ue     ue_id=101
    ...          AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Roll Delta Back   initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                                             delta_scf_filename=delta_b_b9_activation.json
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***

CB008144_5G_B_B9_Successful_SgNB_Addition_Without_Continuous_DL_Data_Transmission
    [Documentation]     Test scenario checks SgNB Addition without continuous DL data transmission.
    ...                 Parameter "actDlDataForwardingX2 - Activate DL data forwarding over X2" should be set to false
    ...                 (DL data forwarding won't be supported). After gNB addition procedure, data traffic on a specified
    ...                 bearer is started. Successful RA procedure towards 5G cell and DL data transmission over 5G radio are performed.
    ...                 Following counters should be updated:
    ...                 M55112C07501 - indicates the number of successful admissions for initial SgNB Addition procedures.
    ...                 M55113C03003 - Indicates the number of UE context setup requests received by DU for the given cell.
    ...                 M55113C03004 - Indicates the number of UE context setup responses sent by DU for the given cell.
    ...                 M55113C03011 - Indicates the number of F1AP: UE Context Setup Request messages sent from gNB-CU
    ...                 to gNB-DU as a part of initial SgNB Addition procedure.
    ...                 M55113C03012 - Indicates the number of F1AP: UE Context Setup Response messages received
    ...                 at gNB-CU from gNB-DU as a part of initial SgNB Addition procedure.
    ...                 Requirement ID: 5G_RAN_USR_RRM_15112.

    Attach UE To eNB    ue_id=101
    Start gNB Addition Procedure   ue=101  target_gnb=2  target_cells=1  bearer=2  dc_type=split_scg
    Start Logged Data Traffic For Given Period Of Time   ue_id=101  bearer_id=2  direction=dl  period=16s  throughput=mbps=5
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55112C07501   +1   SGNB_ADD_AC_SUCC_NRCELL
    ...    M55113C03003   +1   NRDU_F1AP_UECTX_STPREQ_REC_CEL
    ...    M55113C03004   +1   NRDU_F1AP_UECTX_STPRESP_CELL
    ...    M55113C03011   +1   F1_UECTXT_STP_REQSENT_SGNBADD
    ...    M55113C03012   +1   F1_UECTXT_STP_RESPRECD_SGNBADD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal
