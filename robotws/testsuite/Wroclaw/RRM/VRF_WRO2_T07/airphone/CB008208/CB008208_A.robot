*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS23R2
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    RAN_5G    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Jakub Wroblewski
...              :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource     CB008208_Keywords.robot
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta_pcmd
Library      ta5g_bearers
Library      ta5g_enb
Library      ta5g_delta

Suite Setup     Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND              Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_pcmd_activation.json
    ...         AND              Reach OnAir    lua_cfg=${CURDIR}/config/egate_custom_8208.lua
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_a5_activation.json
    ...         AND              Start Server Interface
    ...         AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup      Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...         AND              Setup PCMD

Test Teardown    Run Keywords    Detach Ue    ue_id=${UE_ID_NSA}
    ...          AND             Teardown PCMD
    ...          AND             Restart Scout Monitoring On Test Line If Needed
    ...          AND             Add Scout External Execution ID To Reporting Portal
    ...          AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    check_errors_or_warnings=both

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_pcmd_activation_teardown.json
    ...           AND            Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_a5_activation.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UE_ID_SA} =     1
${UE_ID_NSA} =    11
${BEARER_ID} =    3

*** Test Cases ***
CB008208_5G_A_B110_1_Intra_DU_PSCell_Change_For_NSA_Without_SRB3
    [Documentation]    Testcase verifies:
    ...                MeNB Connectivity record (CB008208-5G-A-B110, requirement OM_GEN_SFS_TRACEMGMNT.4257)
    ...                gNB-CU Bearer record (CB008208-5G-A-B104, requirement OM_GEN_SFS_TRACEMGMNT.4250)
    ...                SgNB initiated SgNB Modification record (CB008208-5G-A-B107, requirement OM_GEN_SFS_TRACEMGMNT.4251)
    ...                Procedure is to perform successful intra-gNB HO and compare each record to coresponding yaml file.
    ...                This test also validates gNB behavior to send gNB-CU UeDUConnectivity PCMD record during successful NSA
    ...                3x Intra-Freq intra-gNB intra-DU PSCell change (CB009225-5G-B, requirement 5G_RAN_USR_COM_15792)

    Attach Ue To Enb    ue_id=${UE_ID_NSA}
    Start Gnb Addition Procedure    ue=${UE_ID_NSA}   target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
    Wait for PCMD Records    1    UeDuConnectivityTraceRecord   30
    Clear Already Collected Pcmd Reports
    Send Custom UE Measurement NR    id=${UE_ID_NSA}  meas_id=1 index=0 nrs_result=68:19:0 event=A5 phycell_id=51 nrsrp_nr=68 srsrp_nr=19
    ...                              pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA    timeout=10

    Wait for PCMD Records    1    SgNBInitiatedSgNBModificationTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=SgNBInitiatedSgNBModificationTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/SgNBInitiatedSgNBModificationTraceRecord.yaml
    Wait for PCMD Records    1    MeNBConnectivityTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=MeNBConnectivityTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/MeNBConnectivityTraceRecord.yaml
    Wait for PCMD Records    1    CuBearerTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=CuBearerTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/CuBearerTraceRecord_add_bearer.yaml
    Perform Records Verification
    Wait for PCMD Records    2    UeDuConnectivityTraceRecord   30
    Add record for verification
    ...     record_name_with_alias=UeDuConnectivityTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/UeDuConnectivityTraceRecord_modification.yaml
    Add record for verification
    ...     record_name_with_alias=UeDuConnectivityTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/UeDuConnectivityTraceRecord_setup.yaml
    Perform Records Verification

CB008208_5G_A_B110_10_Unsuccessful_PSCell_Change_Due_To_TDCoverall_Timer_Expiry
    [Documentation]    Testcase verifies:
    ...                MeNB Connectivity record (CB008208-5G-A-B110, requirement OM_GEN_SFS_TRACEMGMNT.4257)
    ...                gNB-CU Bearer record (CB008208-5G-A-B104, requirement OM_GEN_SFS_TRACEMGMNT.4250)
    ...                SgNB initiated SgNB Modification record (CB008208-5G-A-B107, requirement OM_GEN_SFS_TRACEMGMNT.4251)
    ...                Procedure is to perform unsuccessful intra-gNB HO and compare each record to coresponding yaml file.

    Attach Ue To Enb    ue_id=${UE_ID_NSA}
    Perform Parameter Commissioning    parameter=tDCoverall  value=100
    Start Gnb Addition Procedure    ue=${UE_ID_NSA}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
    Reconfigure RRC For TDCoverall Expiry
    Wait for PCMD Records    1    CuBearerTraceRecord    30
    Clear Already Collected Pcmd Reports
    Send Custom UE Measurement NR    id=${UE_ID_NSA}  meas_id=1 index=0 nrs_result=68:19:0 event=A5 phycell_id=51 nrsrp_nr=68 srsrp_nr=19
    ...                              pass_regexp=Successfully reconfigured dual connectivity    timeout=10

    Wait for PCMD Records    1    SgNBInitiatedSgNBModificationTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=SgNBInitiatedSgNBModificationTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/SgNBInitiatedSgNBModificationTraceRecord_failure.yaml
    Wait for PCMD Records    1    MeNBConnectivityTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=MeNBConnectivityTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/MeNBConnectivityTraceRecord_failure.yaml
    Wait for PCMD Records    1    CuBearerTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=CuBearerTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/CuBearerTraceRecord_failure.yaml
    Perform Records Verification

CB008208_5G_A_B105_9_1_SgNB_Modification_Procedure_To_Delete_E_RAB
    [Documentation]    Testcase verifies MenbInitiatedSgnbModification and gNB-CU Bearer PCMD records. Procedure is to create new bearer
    ...                which is first added to UE and then released. During this scenario 4 records should be reported:
    ...                2x MeNBInitiatedSgNBModificationTraceRecord (CB008208-5G-A-B105, requirement OM_GEN_SFS_TRACEMGMNT.4255)
    ...                2x CuBearerTraceRecord (CB008208-5G-A-B102, requirement OM_GEN_SFS_TRACEMGMNT.4250).
    ...                Records are verified by comparing to coresponding yaml files.

    Attach Ue To Enb    ue_id=${UE_ID_NSA}
    Add Bearer    ue_id=${UE_ID_NSA}     bearer_id=${bearer_id}    filter=0    precedence=0    pass_regexp=PGW-initiated Bearer Creation. Bearer-3
    Start Gnb Addition Procedure    ue=${UE_ID_NSA}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

    Clear Already Collected Pcmd Reports
    Setup Bearer    ${UE_ID_NSA}     ${bearer_id}
    Wait for PCMD Records    1    MeNBInitiatedSgNBModificationTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=MeNBInitiatedSgNBModificationTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/MeNBInitiatedSgNBModificationTraceRecord.yaml
    Wait for PCMD Records    1    CuBearerTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=CuBearerTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/CuBearerTraceRecord_add_bearer.yaml
    Perform Records Verification

    Clear Already Collected Pcmd Reports
    Release Bearer    ${UE_ID_NSA}     ${bearer_id}
    Wait for PCMD Records    1    MeNBInitiatedSgNBModificationTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=MeNBInitiatedSgNBModificationTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/MeNBInitiatedSgNBModificationTraceRecord.yaml
    Wait for PCMD Records    1    CuBearerTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=CuBearerTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/CuBearerTraceRecord_release_bearer.yaml
    Perform Records Verification

*** Keywords ***
Reconfigure RRC For TDCoverall Expiry
    Execute Egate Command    cmd=ue_rrc_reconf_param id=${UE_ID_NSA} if_contains=any action=drop nth=1
