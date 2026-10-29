*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS23R2
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    RAN_5G    PY310    RF50
...           SBTS23R1    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Jakub Gabrys
...              :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource     CB009225_Keywords.robot

Suite Setup     Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND              Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_pcmd_activation.json
    ...         AND              Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_a5_activation.json
    ...         AND              Start Server Interface
    ...         AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup      Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...         AND              Setup PCMD

Test Teardown     Run Keywords    Deregister Ue Without Confirmation     ue_id=${UE_ID_SA}
    ...           AND             Teardown PCMD
    ...           AND             Restart Scout Monitoring On Test Line If Needed
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    check_errors_or_warnings=both

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_pcmd_activation.json
    ...           AND            Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_a5_activation.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UE_ID_SA} =     1

*** Test Cases ***
CB009225_5G_A_B01_1_Intra_GNB_HO_Source_Trace_Record_And_Intra_GNB_HO_Target_Trace_Record_During_Successful_SA_Intra_GNB_Intra_DU_Handover
    [Documentation]    This test case validates that gNB-CU notifies Trace Collection Entity properly of
    ...                intraGNB HO Src and Tgt records (CB009225-5G-A-B01 requirement 5G_RAN_USR_COM_15639)
    ...                during Intra-gNB Intra-DU Handover for SA procedure.
    ...                Record is verified by comparing to coresponding yaml file.

    Attach UE    ue_id=${UE_ID_SA}
    Establish PDU Session With Traffic    ue_id=${UE_ID_SA}   pdu_id=1    gw_id=1
    Clear Already Collected Pcmd Reports
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=${False}
    Send Custom UE Measurement NR    id=${UE_ID_SA} meas_id=1 event=A5 srsrp_nr=19 phycell_id=51 nrsrp_nr=68
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed     timeout=10

    Wait for PCMD Records    1    IntragNBHoSrcTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=IntragNBHoSrcTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/IntragNB_HoSrcRecord.yaml
    Wait for PCMD Records    1    IntragNBHoTgtTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=IntragNBHoTgtTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/IntragNB_HoTgtRecord.yaml
    Perform Records Verification
