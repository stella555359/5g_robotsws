*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS23R2
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    RAN_5G    PY310
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Jakub Wroblewski
...              :contact: jakub.1.wroblewski@nokia.com

Resource     CB008208_Keywords.robot
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta_pcmd
Library      ta5g_enb
Library      ta5g_delta

Suite Setup     Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND              Start Multiple Vms Interfaces
    ...         AND              Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_pcmd_activation.json
    ...         AND              Reach OnAir    lua_cfg=${CURDIR}/config/egate_custom_8208_gnb_sim.lua
    ...         AND              Setup X2 Link    initiator_device=1     complementary_device=3
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_a5_activation.json
    ...         AND              Start Server Interface
    ...         AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup      Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...         AND              Setup PCMD

Test Teardown    Run Keywords    Detach Ue    ue_id=${ue_id}
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
    ...           AND            Stop Multiple Vms Interfaces

*** Variables ***
${UE_ID} =    11

*** Test Cases ***
CB008208_5G_A_B111_SgNB_Change_Record_For_NSA_Inter_En_gNB_Mobility
    [Documentation]    Testcase verifies SgnbChange PCMD record. Procedure is to perform successful inter-gNB handover.
    ...                During this scenario Sgnb Change message should be reported with 1 following PCMD trace record.
    ...                Record is verified by comparing to coresponding yaml file.

    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
    Send Custom UE Measurement NR    id=11 meas_id=1 index=0 nrs_result=68:19:0 event=A5 phycell_id=52 nrsrp_nr=68 srsrp_nr=19
    ...                              pass_regexp=Proxy \\(eNB 3 cell 1\\) reported successful RA    timeout=10

    Wait for PCMD Records    1    SgNBChangeTraceRecord    30
    Add record for verification
    ...     record_name_with_alias=SgNBChangeTraceRecord
    ...     yaml_path=${CURDIR}/record_yamls/SgNBChangeTraceRecord.yaml
    Perform Records Verification

*** Keywords ***
Start Multiple Vms Interfaces
      Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
      Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.4/24
      Start Vm Ethernet Interface    if_name=eth3:Server     ip_with_mask=10.0.1.132/24

Stop Multiple Vms Interfaces
     Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2      ip_with_mask=10.0.1.3/24
     Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG      ip_with_mask=10.0.1.4/24
     Stop Vm Ethernet Interface    if_name=eth3:Server       ip_with_mask=10.0.1.132/24

