*** Settings ***
Documentation
...   author:       Mateusz Cieciura
...   contact:      mateusz.cieciura@nokia.com
...   maintainer:   mateusz.cieciura@nokia.com
...   Description:  This feature describes and verify graceful shutdown procedure according to 5GC000501 feauture

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/test_specific_keywords_501.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/test_specific_keywords_501.py
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
# TODO: OLD VARIABLES, LEFT FOR INTERFACE COMPATIBILITY
${first_cell_number}      1
${second_cell_number}     2
${third_cell_number}      3
${rsrp_threshold}         40


*** Keywords ***
[1.0] 5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    Set Test Variables
    Graceful Comissioning
    Run Keyword             ${START_UE}[${CALL_FLAG}]
    Log to console          Measure TX power before graceful shutdown procedure
    Run Keyword             ${BEFORE_CHECK}[${CHECK_TYPE}]
    Log to console          Starting graceful cell shutdown for ${SHUTDOWN_WINDOW}s in ${SHUTDOWN_STEP_AMOUNT} steps
    Start graceful shutdown procedure
    Run Keyword             ${WHILE_CHECK}[${CHECK_TYPE}]
    Log to console          Wait 11s for cell shutdown
    BuiltIn.Sleep  11s
    Check cell state after graceful shutdown procedure
    Log to console          Stop using UE
    Run Keyword             ${STOP_UE}[${CALL_FLAG}]
    Log to console          Check if for every step TX power dropped by 3dB +/- ${DEVIATION}
    Verify power reduction  ${before_shutdown}  ${while_shutdown}  ${DEVIATION}


[1.0] 5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling

    prepare_swconfig    custom_swconfig_flags=${custom_swconfig_flags}
    TcpdumpSmod.start_tcpdump_on_smod    filename=L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    BuiltIn.Sleep   30  reason=SMOD tracing buffer
    Require Ue   ${UE_ALIAS}    REAL_UE_SA
    Prepare UE AT
    ${pcap_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${lock_cell}=   Get attached cell   ${pcap_path}
    log to console   ${lock_cell}
    ${ho_params}=   Set HO params     ${lock_cell}    ${second_cell_number}
    scf_verifier.Setup and check preconditions in scf    ${ho_params}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Start Data Transfer   dt_name=DT_DL           ue_alias=UE_1
    ...                   direction=dl            duration=150s
    ...                   packet_size=1200        buffer=4M
    ...                   protocol=tcp
    Perform shutting down    ${lock_cell}
    BuiltIn.Sleep   100  reason=Waiting for cell to shut down
    Await Data Transfer Finish  DT_DL
    Check HO related messages

    [Teardown]  Run Keywords
    ...         Run Keyword and Ignore Error   Detach UE   ${UE_ALIAS}      AND
    ...         Cell unlock after shutdown      ${lock_cell}                AND
    ...         AdminUtils.wait_for_all_cells_on_air_state


[1][1.0] 5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling
    Graceful Cell shutdown for concurrent mode NSA and SA configuration invalid parameters values handling      ${first_cell_number}


[1][1.0] 5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
    Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check     ${first_cell_number}
    Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check     ${second_cell_number}
    Graceful Cell shutdown for concurrent mode NSA and SA configuration operators parameters check     ${third_cell_number}
