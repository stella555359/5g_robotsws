*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS25R3    SBTS00    CLOUD_5G_I_MP_AP_LOOO

Documentation   :copyright: Nokia
...             :authors: Milosz Dunikowski

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       CB015149_keywords.robot

Library        ta5g_file_system
Library        ta5g_commissioning
Library        ta5g_cell_operations
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup        Enable C-Plane Debug Logs    with_reboot=${false}

Suite Teardown    Compress Test Logs

Test Teardown      Run Keywords    Add Scout Scf Id To Test Data
...                AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                AND             Collect Selected Debug Files
...                                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                                omit_collectors=sos_report

*** Variables ***
${cfg_A_B1_B3_IWK12}=      ${CURDIR}/config/no_iwf_CB015149.cfg
${IPHY_A_B1_B3_IWK12}=     ${CURDIR}/config/iphy_6_AVQL.xml
${SCFC_A_B1_B3_IWK12}=     CB015149_8DL8UL_4RXBeamforming_TMO_frame.xml
${cfg_A_B2_IWK3}=          ${CURDIR}/config/no_iwf_CB015149.cfg
${IPHY_A_B2_IWK3}=         ${CURDIR}/config/iphy_6_AVQL.xml
${SCFC_A_B2_IWK3}=         CB015149_8DL8UL_8RXBeamforming_TMO_frame_RIM.xml
${CB015149_delta}=         Delta_CB015149_activation.json
${AMBR_delta}=             Delta_AMBR_activation.json
${Delta_add_cells}=        Delta_cell_3_4_5_6_addition.json
@{ue_ids}=                 1    2    3    4    5    6    7    8    9    10    11    12
@{cell_1_2_ues}=           1    2    3    4
@{cell_3_4_5_6_ues}=       5    6    7    8    9    10    11    12
@{cell1_ues_RIM}=          1    2

*** Test Cases ***
CB015149_A_B3_TC5_UL_PRB_pooling_on_new_full_mode_deployment_on_ABIP_8DL4ULMIMO_8ULSTREAMS__8RXBEAMFORMING_4RXBEAMFORMING_1_4_framestructure
    [Setup]       Run Keywords    Prepare Test Setup For One Real Gnb    A_B1_B3_IWK12
    ...           AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Find Scfc And Send Delta Commissioning    scfc_filename=${CB015149_delta}
    Wait For All Cells To Be Enabled
    Find Scfc And Send Delta Commissioning    scfc_filename=${AMBR_delta}
    Wait For All Cells To Be Enabled
    Attach Multiple UEs    first_ue_id=1    last_ue_id=12    enb='2'
    Setup PDU Session Configure UL-MIMO and Start Data Traffic For Multiple UEs    ue_ids=${ue_ids}
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated With AMBR Limiting Throughput    ue_ids=${ue_ids}
    AMBR Limit Change By Triggering PDU Session Modification For Multiple UEs    ue_ids=${ue_ids}
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated      ue_ids=${ue_ids}
    Generate Full Tput for Subpool-0 And Decrease UEs Tput For Subpools-1-2-3    ue_ids=${ue_ids}
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Decrease Tput In Three Subpools and Increase In Subpool-0    ue_ids=${ue_ids}

CB015149_A_B2_TC1_Cell_addition_deletion_new_full_mode_deployment_on_ABIP_main
    [Setup]       Run Keywords    Prepare Test Setup For One Real Gnb    A_B2_IWK3
    ...           AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Find Scfc And Send Delta Commissioning    scfc_filename=${CB015149_delta}
    Wait For All Cells To Be Enabled
    Attach Multiple UEs    first_ue_id=1    last_ue_id=4    enb='2'
    Setup PDU Session Configure UL-MIMO and Start Data Traffic For Multiple UEs    ue_ids=${cell_1_2_ues}
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated      ue_ids=${cell_1_2_ues}
    Find Scfc And Send Delta Commissioning    scfc_filename=${Delta_add_cells}
    Wait For All Cells To Be Enabled
    Attach Multiple UEs    first_ue_id=5    last_ue_id=12    enb='2'
    Setup PDU Session Configure UL-MIMO and Start Data Traffic For Multiple UEs    ue_ids=${cell_3_4_5_6_ues}
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated      ue_ids=${cell_3_4_5_6_ues}
    Generate Remote Interferences
    Activate Testmode With Remote Interferences For Cell-1
    Generate RIM-RS Profile
    Activate Testmode With RIM-RS For Cell-1
    Wait 10s For Traffic To Stabilize
    Verify Traffic on PUSCH For Every UE After Generating Remote Interferences    ue_ids=${cell1_ues_RIM}
    Wait Until Keyword Succeeds   20 min   30 sec   Verify If Admin Fault Is Up    fault_id=7525
    Wait Until Keyword Succeeds   30 min   30 sec   Verify If Admin Fault Is Up    fault_id=7527
    Deactivate Testmode With Remote Interferences For Cell-1
    Deactivate Testmode With RIM-RS For Cell-1
    Wait Until Keyword Succeeds   16 min   30 sec   Verify If Admin Fault Is Down    fault_id=7525
    Wait Until Keyword Succeeds   16 min   30 sec   Verify If Admin Fault Is Down    fault_id=7527
    Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated      ue_ids=${ue_ids}
