*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: fabrice.delecroix@nokia.com, denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites

Library           BuiltIn
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           DateTime
Library           taf.lteemu                              WITH NAME    lteemu
Library           taf.sbts.oam.coam.admin                 WITH NAME    sbts_coam
Library           taf.wts.runner                          WITH NAME    wtsemu
Library           ta_emss
Library           ../../../resources/python/robot_extension.py
Library           ../python/create_pretty_counter_file.py
Library           ../python/create_pretty_kpi_file.py
library           ../python/create_pretty_load_meas_file.py
Library           ../python/create_scripts.py
Library           ../python/create_ues.py
Library           ../python/dcap_interface.py
Library           ../python/diff_resource_usage.py
Library           ../python/evaluate_tti_events.py
Library           ../python/evaluate_sherpa.py
Library           ../python/extract_time_marker.py
Library           ../python/extract_tti_events.py
# Library           ../python/extract_load_measurements.py (BHR 28/08/2024 replaced by create_pretty_load_meas_file.py)
Library           ../python/read_bts_info.py
Library           ../python/createUeScenario.py
Library           ../python/createFullScenario.py
Library           ../python/createMasterScenario.py
Library           ../python/launch_write_telnet.py
Library           ../python/writeTelnetOnce.py
Library           ../python/update_kpi_dictionary.py


Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/Hardening.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          Handover-Keywords.robot
Resource          OAM_Keywords.robot

*** Variables ***
# preset of variables for QC report
${Verdict_TL_Init}                                                                               FAILED
${Verdict_TL_Custom_Config}                                                                      FAILED
${Verdict_TL_Restart}                                                                            FAILED
${Verdict_TL_Restart_DSS_PRB}                                                                    FAILED
${Verdict_Background_Scenario}                                                                   FAILED
${Verdict_Configure_HO_And_Restart}                                                              FAILED
${Verdict_Cell_Setup}                                                                            FAILED
${Verdict_Cell_Block}                                                                            FAILED
${Verdict_Cell_Unblock}                                                                          FAILED
${Verdict_Cell_Setup_DSS_PRB}                                                                    FAILED
${Verdict_Est_Part_DSS}                                                                          FAILED
${Verdict_Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0}                                           FAILED
${Verdict_Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0}                                           FAILED
${Verdict_Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0}                                   FAILED
${Verdict_Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0}                                           FAILED
${Verdict_Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0}                                          FAILED
${Verdict_Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}                                   FAILED
${Verdict_Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}                                   FAILED
${Verdict_Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}                                   FAILED
${Verdict_DualConn_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}                                  FAILED
${Verdict_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0}                             FAILED
${Verdict_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0}                             FAILED
${Verdict_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}                             FAILED
${Verdict_DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0}                             FAILED
${Verdict_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0}                                 FAILED
${Verdict_HO_2CC_10UE_DlHighTputBler0_UlBler0}                                                   FAILED
${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0}                                               FAILED
${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB}                                       FAILED
${Verdict_Traffic_2CC_5UE_DlHighTputBler0_UlBler0}                                               FAILED
${Verdict_Traffic_2CC_10UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_2CC_20UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_2CC_30UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB}                                      FAILED
${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0}                                       FAILED
${Verdict_Traffic_2CC_100UE_DlHighTputBler0_UlBler0}                                             FAILED
${Verdict_Traffic_2CC_100UE_DlHighTputBler9_UlBler0}                                             FAILED
${Verdict_Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0}                                      FAILED
${Verdict_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0}                                           FAILED
${Verdict_Traffic_4CC_10UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_4CC_20UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_4CC_40UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_4CC_60UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_4CC_80UE_DlHighTputBler0_UlBler0}                                              FAILED
${Verdict_Traffic_4CC_100UE_DlHighTputBler0_UlBler0}                                             FAILED
${Verdict_Traffic_4CC_100UE_DlHighTputBler9_UlBler0}                                             FAILED
${Verdict_Traffic_6CC_24UE_DlMedTputBler0_UlBler0}                                               FAILED
${Verdict_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0}                                          FAILED
${Verdict_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0}                                        FAILED
${Verdict_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0}                                      FAILED
${Verdict_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0}                                      FAILED
${Verdict_Multiple-Cell-Block-Unblock}                                                           FAILED
${Verdict_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0}                                   FAILED
${Verdict_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0}                                           FAILED
${Verdict_RLF_2CC_6UE_DlHighTputBler0_UlBler0}                                                   FAILED
${Verdict_RLF_2CC_10UE_DlHighTputBler0_UlBler0}                                                  FAILED
${Verdict_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9}                                   FAILED
${Verdict_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release}                                FAILED
${Verdict_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release}                                FAILED
${Verdict_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check}                                      FAILED
${Verdict_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check}                                      FAILED
${Verdict_Alarms_Check_during_Oam_Modifications}                                                 FAILED
${Verdict_Traffic_1CC_30UE_DlUlLowTputBler0_10UE_SetupRelease}                                   FAILED
${Verdict_Traffic_1CC_70UE_DlUlLowTputBler0_30UE_SetupRelease}                                   FAILED
${Verdict_Background}                                                                            FAILED
${Verdict_Background_Monitoring}                                                                 FAILED
${Verdict_Perturbation_5GC000937}                                                                FAILED
${Verdict_Endurance}                                                                             FAILED
${Verdict_Postlude}                                                                              FAILED

*** Keywords ***

Update_Kpi_Dict
    [Arguments]            ${KPI_DICTIONARY}    ${PERIOD_DURATION}
    write_to_report        :::::::::: Updated KPI from dictionary ::::::::::
    write_to_report        INF: KPI_DICTIONARY = ${KPI_DICTIONARY}
    write_to_report        INF: PERIOD_DURATION = ${PERIOD_DURATION}
    ${UPDATED_KPI}         update_kpi_dictionary        ${KPI_DICTIONARY}     ${PERIOD_DURATION}
    FOR    ${element}    IN    @{UPDATED_KPI}
        write_to_report    ${element}
    END

Step_TL_Init
    [Arguments]            ${feature_dir}    ${long_feature_name}    ${short_feature_name}    ${config_name}
    ...                    ${sherpa_mode}    ${tti_mode}    ${fifo_debug}
    Set Suite Variable     ${Verdict_TL_Init}    FAILED
    write_to_report        TL_Init
    write_to_report        INF: Step_TL_Init - feature_dir: ${feature_dir}
    write_to_report        INF: Step_TL_Init - config_name: ${config_name}
    Set Suite Variable     ${feature_dir}
    Set Suite Variable     ${long_feature_name}
    Set Suite Variable     ${short_feature_name}
    Set Suite Variable     ${config_name}
    Set Suite Variable     ${sherpa_mode}
    Set Suite Variable     ${tti_mode}
    Set Suite Variable     ${fifo_debug}
    Set Suite Variable     ${snapshot_at_egate_error}    True
    save_config_files      Init
    create_scripts         /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/script
    # create_scripts         ${CURDIR}/../../script
    generate_qc_script
    initialize_counter_history_script
    initialize_KPI_history_script
    initialize_load_meas_history_script
    create_ues             /opt/wts/latest/basic_setup.cfg    /opt/wts/latest/basic_wts_step2.cfg    ${feature_dir}    ${config_name}
    # DTN250207: COMMENTED FOR DEBUG - PB WITH ONLINE Modifications
    # run keyword if         '${config_name}' == 'FR1_TMO'     change_fr1_tmo
    run keyword if         '${config_name}' == 'FR1'         change_fr1_parameters
    run keyword if         '${config_name}' == 'FR1_IBCA'    change_ibca_parameters
    Update gNB Swconfig
    Update VM config
    Extract Board info
    Set Suite Variable     ${Verdict_TL_Init}    PASS

Step_TL_Custom_Config
    Set Suite Variable     ${Verdict_TL_Custom_Config}    FAILED
    set_custom_config      ${config_name}
    Set Suite Variable     ${Verdict_TL_Custom_Config}    PASS

Restart_OAM
    OAM Reset Site         ${GNB_DU.oam}
    OAM Wait Available     ${GNB_DU.oam}     400

Step_TL_Restart
    Set Suite Variable     ${Verdict_TL_Restart}    FAILED
    write_to_report        TL_Restart
    Restart OAM
    Restart.Restart TL     isOAMRebooted=True
    Set Suite Variable     ${Verdict_TL_Restart}    PASS

# DTN250613 updated to avoid Fault signature for crash or failure, severity: Warning, alarm_id: 7115, fault_id: 4590
# Step_TL_Restart
#     Set Suite Variable     ${Verdict_TL_Restart}    FAILED
#     write_to_report        TL_Restart
#     Restart.Restart TL
#     Set Suite Variable     ${Verdict_TL_Restart}    PASS

Step_TL_Restart_DSS_PRB
    Set Suite Variable     ${Verdict_TL_Restart_DSS_PRB}    FAILED
    Set SCF Context DSS PRB
    write_to_report        TL_Restart_DSS_PRB
    #Restart.Restart TL
    Set Suite Variable     ${Verdict_TL_Restart_DSS_PRB}    PASS

Step_Configure_HO_And_Restart
    Set Suite Variable     ${Verdict_Configure_HO_And_Restart}    FAILED
    write_to_report        Configure_HO_And_Restart
    run keyword if         '${GNB_BTS_INFO['name']}' != 'INTRA_GNB_HO'
    ...                    Perform Full Commissioning With Intra Gnb Ho Configuration
    ...         ELSE       Restart.Restart TL
    Set Suite Variable     ${Verdict_Configure_HO_And_Restart}    PASS

Step_Cell_Setup
    Set Suite Variable     ${Verdict_Cell_Setup}    FAILED
    write_to_report        Cell_Setup
    #set_oam_parameter      MRBTS-1/NRBTS-1/NRCELL-3    maxNumOfSCellAlloc    250
    #run keyword if         '${config_name}' == 'FR2_CA'    block_2cells
    initialize_wts
    run_script             once    X2_Link_Setup.sce
    # DTN250318: comment sherpa activation
    # activate_sherpa_traces
    write_to_report        Cell_Setup Done
    Set Suite Variable     ${Verdict_Cell_Setup}    PASS

# DTN 26/11/2024 adding background scenario : BEG
Start_Background_Scenario
    [Arguments]            ${background_duration}    ${UE_Scenario}
    Set Suite Variable     ${path_scenario}          ${CURDIR}/../../config/background_scenario/
    Set Suite Variable     ${UE_Scenario}            ${path_scenario}/${UE_Scenario}
    Set Suite Variable     ${master_scenario}        master_scenario.txt
    Set Suite Variable     ${Verdict_Background_Scenario}    FAILED
    write_to_report        Start Background Scenario
    write_to_report        createUeScenario UeScenario = ${UE_Scenario} - path = ${path_scenario}
    createUeScenario       ${UE_Scenario}    ${path_scenario}
    write_to_report        createFullScenario path = ${path_scenario} - background duration = ${background_duration}
    createFullScenario     ${path_scenario}    ${background_duration}
    write_to_report        createMasterScenario path = ${path_scenario} - master_scenario = ${master_scenario}
    createMasterScenario    ${path_scenario}    ${master_scenario}
    write_to_report        start telnet scenario path = ${path_scenario}
    launch_write_telnet    ${path_scenario}    ${OUTPUT_DIR}
    Set Suite Variable     ${Verdict_Background_Scenario}    PASS
# DTN 26/11/2024 adding background scenario : END

Step_Cell_Block
    [Arguments]            ${cellId1}=NA    ${cellId2}=NA    ${cellId3}=NA    ${cellId4}=NA
    Set Suite Variable     ${Verdict_Cell_Block}    FAILED
    write_to_report        Cell_Block
    ${gnb_alias}           Set Variable    gNodeB
    ${connection}          sbts_coam.connect_to    name=${gnb_alias}
    run keyword if         '${cellId1}' != 'NA'    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/${cellId1}    connection=${gnb_alias}
    run keyword if         '${cellId2}' != 'NA'    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/${cellId2}    connection=${gnb_alias}
    run keyword if         '${cellId3}' != 'NA'    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/${cellId3}    connection=${gnb_alias}
    run keyword if         '${cellId4}' != 'NA'    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/${cellId4}    connection=${gnb_alias}
    sbts_coam.teardown_admin    connection=${connection}
    write_to_report        Cell_Block Done
    Set Suite Variable     ${Verdict_Cell_Block}    PASS

Step_Cell_Unblock
    [Arguments]            ${cellId1}=NA    ${cellId2}=NA    ${cellId3}=NA    ${cellId4}=NA
    Set Suite Variable     ${Verdict_Cell_Unblock}    FAILED
    write_to_report        Cell_Unblock
    ${gnb_alias}           Set Variable    gNodeB
    ${connection}          sbts_coam.connect_to    name=${gnb_alias}
    run keyword if         '${cellId1}' != 'NA'    sbts_coam.unblock_cell    dist_name=MRBTS-1/NRBTS-1/${cellId1}    connection=${gnb_alias}
    run keyword if         '${cellId2}' != 'NA'    sbts_coam.unblock_cell    dist_name=MRBTS-1/NRBTS-1/${cellId2}    connection=${gnb_alias}
    run keyword if         '${cellId3}' != 'NA'    sbts_coam.unblock_cell    dist_name=MRBTS-1/NRBTS-1/${cellId3}    connection=${gnb_alias}
    run keyword if         '${cellId4}' != 'NA'    sbts_coam.unblock_cell    dist_name=MRBTS-1/NRBTS-1/${cellId4}    connection=${gnb_alias}
    sbts_coam.teardown_admin    connection=${connection}
    # DTN250318: comment sherpa activation
    # activate_sherpa_traces
    write_to_report        Cell_Unblock Done
    Set Suite Variable     ${Verdict_Cell_Unblock}    PASS

Step_Cell_Setup_DSS_PRB
    Set Suite Variable     ${Verdict_Cell_Setup_DSS_PRB}    FAILED
    write_to_report        Cell_Setup_DSS_PRB
    create_scripts         /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/script
    # create_scripts         ${CURDIR}/../../script
    set_oam_parameter      MRBTS-1/NRBTS-1/NRCELL-3    maxNumOfSCellAlloc    250
    CallSetup.Setup Wtsemu SA
    # DTN250318: comment sherpa activation
    # activate_sherpa_traces
    CallSetup.WTS Set XpAP and X2 Link    id=1    targetGnb=2
    write_to_report        Cell_Setup_DSS_PRB Done
    Set Suite Variable     ${Verdict_Cell_Setup_DSS_PRB}    PASS

Step_Est_Part_DSS
    Set Suite Variable     ${Verdict_Est_Part_DSS}    FAILED
    write_to_report        Est_Part_DSS
    Configure Partnership DSS Phase 2
    Est Part and Alloc DSS Phase 2
    Set Suite Variable     ${Verdict_Est_Part_DSS}    PASS

Configure Partnership DSS Phase 2
    [Documentation]                 Configure the DSS partnership between eNB/gNB on terget cell.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id gNB (default value = 2)
    [Arguments]                     ${cellIdGnb}=2
    Dated log                       CRM Partnership Creation
    wtsemu.enb_dss_param            id=1     feature_flag=on     message_sets=V1,DMS2
    wtsemu.enb_cell_param           enb=1    id=1    lte_nr_dss_mode=DL_CRS_TDM_UL_FDM
    wtsemu.enb_dss_configure_partnership     enb=1   cell=1      dss_peer=2:${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=CRM Partnership Creation
    ...                             timeout=60

Est Part and Alloc DSS Phase 2
    [Documentation]                 Establish the DSS partnership by configure CRM resource reservation and resource allocation in UL and DL.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id Gnb (default value = 2)
    ...                             - *targetGnb*: targetGnb to use (default value = 2)
    [Arguments]                     ${cellIdGnb}=2    ${targetGnb}=2
    ${dans}    set variable         0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    Dated log                       DSS Establishing Partnership
    wtsemu.enb_crm_cell_resource_reservation     enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          assigned_dl_minimum_share_to_nr=15     assigned_dl_maximum_share_to_nr=70
    ...                                          assigned_dl_minimum_share_to_lte=15    assigned_dl_maximum_share_to_lte=70
    ...                                          assigned_ul_minimum_share_to_nr=20     assigned_ul_maximum_share_to_nr=70
    wtsemu.enb_dss_establish_partnership         enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell .*: EN DSS UL Cell Subcarrier Resource Coordination.*\n*.*success on remote NE
    ...                             timeout=60
    wtsemu.enb_crm_param                         id=1          ul_qos_load_meas_timer=200              dl_qos_load_meas_timer=200
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=DL   allocation_start_time=immediate   dl_allocated_normal_subframes=${dans}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received DSS DL Qos Load Indication SequenceNum\nber=0
    ...                             timeout=60
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=UL        allocation_start_time=immediate         ul_allocated_prb_list=0,5|9,30|45,5
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received EN DSS UL Qos Load Indication Sequence\nNumber=0
    ...                             timeout=60

Step_Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_SetupNSA_DL150mbps.sce
    run_script             once         UE_1_StartTrafficNSA_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_SetupNSA_DL580mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_5_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_10_SetupNSA_DL580mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_10_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_10_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_20_SetupNSA_DL580mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_20_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_SetupNSA_DL580mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_40_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_40_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_80_SetupNSA_DL570mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_80_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_80_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0
    run_script             once         AutoGen_UE_1_to_80_SetupNSA_DL485mbps.sce
    run_script             once         AutoGen_UE_1_to_80_DlBler9.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_80_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_80_DlBler0.sce
    run_script             once         AutoGen_UE_1_to_80_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0}    PASS

Step_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_1_to_80_SetupNSA_DL570mbps_UL30mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_80_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_80_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_96_SetupNSA_DL570mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_96_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_96_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_96_SetupNSA_DL430mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_96_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_96_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0}    PASS

# DTN 26/11/2024 adding background scenario : BEG
Step_Background
    [Timeout]              12hours
    [Arguments]            ${perturbation_sce}    ${reportingIntervalPm}    ${step_name_suffix}=${EMPTY}    ${KPI_DICTIONARY}=SWENG
    Set Suite Variable     ${Verdict_Background}     FAILED
    ${step_name}           set variable    Perturbation${step_name_suffix}
    Run Keyword If         '${step_name_suffix}' != '${EMPTY}'    Set Suite Variable    ${step_name}    ${step_name_suffix}
    write_to_report        INF: step_name = ${step_name}
    write_to_report        INF: reportingIntervalPm = ${reportingIntervalPm}
    write_to_report        INF: repeat until end of pm period = ${perturbation_sce}
    write_to_report        INF: KPI_DICTIONARY = ${KPI_DICTIONARY}
    # ${compare_pm_metric}   set variable    kpi
    ${compare_pm_metric}   set variable    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/counter/metric/5G_TOP_KPI_25R3.csv
    ${pm_path}   ${syslog}   run_probation_period
    ...                      ${step_name}   ${perturbation_sce}   no_timemarker   until_next_pm_start   ${reportingIntervalPm}
    write_to_report        INF: end of probation period
    write_to_report        INF: pm_path=${pm_path}
    ${pm_path}             get_last_pm     ${reportingIntervalPm}
    write_to_report        INF: pm_path=${pm_path}
    ${is_run_checks_pass}     Run Keyword And Return Status    run_checks
    ...                       ${step_name}_${reportingIntervalPm}    DualConnEndur    ${pm_path}    ${syslog}
    ...                       max_syslog_rate=800    check_tti=no    compare_pm_metric=${compare_pm_metric}
    ...                       KPI_DICTIONARY=${KPI_DICTIONARY}

    ${is_detected_alarm_pass}   Run Keyword And Return Status    alms_hdlr.check_detected_alarms
    Run Keyword If    not ${is_detected_alarm_pass}            write_to_report    ERR: run_checks - detected alarm FAIL
    Run Keyword If    ${is_detected_alarm_pass}                write_to_report    INF: run_checks - detected alarm PASS
    write_to_report    ::::::::::::::::::::::::::::::::::::::::::::::::::::
    ${runCheck_and_alarms}         Evaluate    ${is_run_checks_pass} and ${is_detected_alarm_pass}
    # BHR begin 13/12/2024: Check detect alarms
    # Step              Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
    # Step              alms_hdlr.check_detected_alarms
    # BHR end
    Run Keyword If         not ${runCheck_and_alarms}     Fail    failure during run_checks
    Set Suite Variable     ${Verdict_Background}    PASS

# Step_Background_Monitoring
#    [Timeout]              12hours
#    [Arguments]            ${perturbation_sce}    ${reportingIntervalPm}    ${step_name_suffix}=${EMPTY}
#    Set Suite Variable     ${Verdict_Background_Monitoring}    FAILED
#    ${step_name}           set variable    Background_Monitoring_TMO_PowerSaving
#    Run Keyword If         '${step_name_suffix}' != '${EMPTY}'    Set Suite Variable    ${step_name}    Background_Monitoring_${step_name_suffix}
#    write_to_report        INF: step_name = ${step_name}
#    write_to_report        INF: perturbation_sce = ${perturbation_sce}
#    write_to_report        INF: reportingIntervalPm = ${reportingIntervalPm}
#    # ${compare_pm_metric}   set variable    kpi
#    ${compare_pm_metric}   set variable    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/counter/metric/5G_TOP_KPI_25R3.csv
#    # ${pm_path}   ${syslog}   run_probation_period   ${step_name}    UE_Summary.sce    timemarker_mode=no_timemarker    mode=just_wait
#    ${pm_path}   ${syslog}   run_probation_period
#    ...                     ${step_name}   ${perturbation_sce}   timemarker_mode=no_timemarker   mode=until_next_pm_start   reportingIntervalPm=15min
#    write_to_report        INF: Step_Background_Monitoring - pm_path = ${pm_path}
#    ${is_run_checks_pass}=    Run Keyword And Return Status    run_checks
#    ...                     ${step_name}    DualConnEndur    ${pm_path}    ${syslog}
#    ...                     max_syslog_rate=800    check_tti=no    compare_pm_metric=${compare_pm_metric}
#    write_to_report        INF: is_run_checks_pass = ${is_run_checks_pass}
#    # BHR begin 13/12/2024: Check detect alarms
#    # Step              Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
#    Step              alms_hdlr.check_detected_alarms
#    # BHR end
#    Run Keyword If         not ${is_run_checks_pass}     Fail    failure during run_checks
#    Set Suite Variable     ${Verdict_Background_Monitoring}    PASS

Step_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             by_telnet_once         AutoGen_UE_61_to_70_SetupNSA.sce
    ${pm_path}   ${syslog}   run_probation_period   ${step_name}   AutoGen_UE_61_to_70_DualConnEndur_oneloop.sce   no_timemarker    by_telnet_pm
    run_script             by_telnet_once         AutoGen_UE_61_to_70_ReleaseNSA.sce
    run_checks             ${step_name}    DualConnEndur    ${pm_path}    ${syslog}    max_syslog_rate=800    check_tti=no
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

#Step_Perturbation
#    [Timeout]              12hours
#    [Arguments]            ${perturbation_sce}    ${reportingIntervalPm}    ${step_name_suffix}=${EMPTY}
#    Set Suite Variable     ${Verdict_Perturbation}    FAILED
#    ${step_name}           set variable    Perturbation${step_name_suffix}
#    Run Keyword If    '${step_name_suffix}' != '${EMPTY}'    write_to_report    INF: step_name_suffix=${step_name_suffix}
#    Run Keyword If    '${step_name_suffix}' != '${EMPTY}'    Set Suite Variable    ${step_name}    Perturbation_${step_name_suffix}
#    ${pm_path}   ${syslog}   run_probation_period   ${step_name}   ${perturbation_sce}   no_timemarker   until_next_pm_start   ${reportingIntervalPm}
#    run_checks             ${step_name}    DualConnEndur    ${pm_path}    ${syslog}    max_syslog_rate=800    check_tti=no
#    Set Suite Variable     ${Verdict_Perturbation}    PASS
# DTN 26/11/2024 adding background scenario : END

Step_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    #Sherpa.Deactivate Sherpa and Stop Collect
    run_script             once         AutoGen_UE_1_to_60_SetupNSA_DL570mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_61_to_70_SetupNSA.sce
    ${pm_path}   ${syslog}   run_probation_period   ${step_name}   AutoGen_UE_61_to_70_DualConnEndur.sce   collect_timemarker
    run_script             once         AutoGen_UE_1_to_70_ReleaseNSA.sce
    run_checks             ${step_name}    DualConnEndur    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    #Sherpa.Deactivate Sherpa and Stop Collect
    run_script             once         AutoGen_UE_1_to_80_SetupNSA_DL570mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_81_to_96_SetupNSA.sce
    ${pm_path}   ${syslog}   run_probation_period   ${step_name}   AutoGen_UE_81_to_96_DualConnEndur.sce   collect_timemarker
    run_script             once         AutoGen_UE_1_to_96_ReleaseNSA.sce
    run_checks             ${step_name}    DualConnEndur    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_DualConn_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_DualConn_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    DualConn_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0
    run_script             once         AutoGen_UE_1_to_80_SetupNSA_DL570mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_81_to_96_SetupNSA.sce
    wtsemu.script          file=${CURDIR}/../../script/UE_81_to_96_DualConn.sce
    OAM Get Snapshot
    ${script_status}       wait until keyword succeeds    12hours    1s    is_script_finished
    run_script             once         AutoGen_UE_1_to_96_ReleaseNSA.sce
    Set Suite Variable     ${Verdict_DualConn_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_SetupNSA_DL485mbps.sce
    run_script             once         AutoGen_UE_101_to_105_SetupNSA_DL485mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_5_ReleaseNSA.sce
    run_script             once         AutoGen_UE_101_to_105_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_11_to_20_SetupNSA_DL450mbps_UL15mbps.sce
    run_script             once         AutoGen_UE_111_to_120_SetupNSA_DL450mbps_UL15mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_11_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_11_to_20_ReleaseNSA.sce
    run_script             once         AutoGen_UE_111_to_120_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_11_to_20_SetupNSA_DL450mbps_UL15mbps.sce
    run_script             once         AutoGen_UE_111_to_120_SetupNSA_DL450mbps_UL15mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_11_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_11_to_20_ReleaseNSA.sce
    run_script             once         AutoGen_UE_111_to_120_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_11_to_20_SetupNSA_DL450mbps_UL15mbps.sce
    run_script             once         AutoGen_UE_111_to_120_SetupNSA_DL450mbps_UL15mbps.sce
    run_script             once         AutoGen_UE_21_to_25_SetupNSA.sce
    ${pm_path}   ${syslog}   run_probation_period   ${step_name}   AutoGen_UE_21_to_25_DualConnEndur.sce   collect_timemarker
    run_script             once         AutoGen_UE_11_to_25_ReleaseNSA.sce
    run_script             once         AutoGen_UE_111_to_120_ReleaseNSA.sce
    run_checks             ${step_name}    DualConnEndur    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_11_to_20_SetupNSA_DL450mbps_UL15mbps.sce
    run_script             once         AutoGen_UE_111_to_120_SetupNSA_DL450mbps_UL15mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_11_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_11_to_20_ReleaseNSA.sce
    run_script             once         AutoGen_UE_111_to_120_ReleaseNSA.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0}    PASS

Step_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0
    [Timeout]               12hours
    [Arguments]             ${number_of_iterations}=10
    Set Suite Variable      ${Verdict_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}            set variable    CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0
    ${original_scf_file}    OAM Get SCF File    file=${step_name}-original.xml
    ${delta_create_file}    Replace String    ${original_scf_file}    original    create
    ${delta_delete_file}    Replace String    ${original_scf_file}    original    delete
    prepare_delta_files     ${original_scf_file}    ${delta_create_file}    ${delta_delete_file}
    check_cell_states
    run_script              once         AutoGen_UE_1_to_5_SetupNSA_DL485mbps.sce
    run_script              once         AutoGen_UE_101_to_105_SetupNSA_DL485mbps.sce
    ${gnb_alias}            Set Variable    gNodeB
    sbts_coam.connect_to    name=${gnb_alias}
    FOR     ${iteration}        IN RANGE    1    ${number_of_iterations} + 1
        run_script              once         AutoGen_UE_1_to_5_ReleaseNSA.sce
        delete_cell             ${delta_delete_file}    ${gnb_alias}
        create_cell             ${delta_create_file}    ${gnb_alias}
        check_cell_states
        run_script              once         AutoGen_UE_1_to_5_SetupNSA_DL485mbps.sce
        write_to_report         CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0 end of iteration ${iteration}
    END
    sbts_coam.teardown      connection=${gnb_alias}
    # DTN250318: comment sherpa activation
    # activate_sherpa_traces
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_Stats.sce    collect_timemarker
    run_script              once         AutoGen_UE_1_to_5_ReleaseNSA.sce
    run_script              once         AutoGen_UE_101_to_105_ReleaseNSA.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable      ${Verdict_CellDeleteCreate_2CC_10UE_FR2_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_1UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_1UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_Setup_DL150mbps.sce
    run_script             once         UE_1_StartTraffic_DL290mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_Stats.sce
    run_script             once         UE_1_StopTraffic.sce
    run_script             once         AutoGen_UE_1_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB}    FAILED
    ${step_name}           set variable    Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB
    run_script             once         AutoGen_UE_1_Setup_DL150mbps.sce
    run_script             once         UE_1_StartTraffic_DL290mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_Stats.sce
    run_script             once         UE_1_StopTraffic.sce
    run_script             once         AutoGen_UE_1_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB}    PASS

Step_Traffic_2CC_5UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_5UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_5UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_Stats.sce
    run_script             once         AutoGen_UE_1_to_5_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_5UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_4CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_10UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_10UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_101_to_105_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_5_Release.sce
    run_script             once         AutoGen_UE_101_to_105_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_10UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_10UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_10UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_10_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_10_Stats.sce
    run_script             once         AutoGen_UE_1_to_10_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_10UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_4CC_20UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_20UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_20UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_10_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_101_to_110_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_10_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_10_Release.sce
    run_script             once         AutoGen_UE_101_to_110_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}    max_syslog_rate=430
    Set Suite Variable     ${Verdict_Traffic_4CC_20UE_DlHighTputBler0_UlBler0}    PASS

Step_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_10_Setup_DL10mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_10_Stats.sce
    run_script             once         AutoGen_UE_1_to_10_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_TrafficPcell_2CC_10UE_DlLowTputBler0_UlBler0}    PASS

Step_Traffic_2CC_20UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_20UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_20UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_20_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_20_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_20UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_4CC_40UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_40UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_40UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_20_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_101_to_120_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_20_Release.sce
    run_script             once         AutoGen_UE_101_to_120_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_40UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_30UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_30UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_30UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_30_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_30_Stats.sce
    run_script             once         AutoGen_UE_1_to_30_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_30UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_4CC_60UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_60UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_60UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_30_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_101_to_130_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_30_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_30_Release.sce
    run_script             once         AutoGen_UE_101_to_130_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_4CC_60UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_40UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_40UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_40_Stats.sce
    run_script             once         AutoGen_UE_1_to_40_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_4CC_80UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_80UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_80UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_101_to_140_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_40_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_40_Release.sce
    run_script             once         AutoGen_UE_101_to_140_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_80UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB}    FAILED
    ${step_name}           set variable    Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_40_Stats.sce
    run_script             once         AutoGen_UE_1_to_40_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB}    PASS

Step_Traffic_2CC_50UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_50UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_41_to_50_Setup_DL11mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL430mbps_UL20mbps.sce
    run_script             once         AutoGen_UE_41_to_50_Setup_DL11mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_4CC_100UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_100UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_100UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_41_to_50_Setup_DL11mbps.sce
    run_script             once         AutoGen_UE_101_to_140_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_141_to_150_Setup_DL11mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_script             once         AutoGen_UE_101_to_150_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_100UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_100UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_100UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_100UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_41_to_100_Setup_DL11mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_100_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_100_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}    max_syslog_rate=500
    Set Suite Variable     ${Verdict_Traffic_2CC_100UE_DlHighTputBler0_UlBler0}    PASS

Step_Traffic_2CC_100UE_DlHighTputBler9_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_2CC_100UE_DlHighTputBler9_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_100UE_DlHighTputBler9_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL330mbps.sce
    run_script             once         AutoGen_UE_41_to_100_Setup_DL30mbps.sce
    run_script             once         AutoGen_UE_1_to_100_DlBler9.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_100_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_100_DlBler0.sce
    run_script             once         AutoGen_UE_1_to_100_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}    max_syslog_rate=500
    Set Suite Variable     ${Verdict_Traffic_2CC_100UE_DlHighTputBler9_UlBler0}    PASS

Step_Traffic_4CC_100UE_DlHighTputBler9_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_4CC_100UE_DlHighTputBler9_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_4CC_100UE_DlHighTputBler9_UlBler0
    run_script             once         AutoGen_UE_1_to_40_Setup_DL380mbps.sce
    run_script             once         AutoGen_UE_41_to_50_Setup_DL11mbps.sce
    run_script             once         AutoGen_UE_101_to_140_Setup_DL380mbps.sce
    run_script             once         AutoGen_UE_141_to_150_Setup_DL11mbps.sce
    run_script             once         AutoGen_UE_1_to_50_DlBler9.sce
    run_script             once         AutoGen_UE_101_to_150_DlBler9.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_50_DlBler0.sce
    run_script             once         AutoGen_UE_101_to_150_DlBler0.sce
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_script             once         AutoGen_UE_101_to_150_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_4CC_100UE_DlHighTputBler9_UlBler0}    PASS

Step_Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_1_to_80_Setup_DL65mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_101_to_180_Setup_DL400mbps_UL30mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_80_Stats.sce    collect_timemarker
    run_script             once         AutoGen_UE_1_to_80_Release.sce
    run_script             once         AutoGen_UE_101_to_180_Release.sce
    run_checks             ${step_name}    Overload    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0}    PASS

Step_Traffic_6CC_24UE_DlMedTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_6CC_24UE_DlMedTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    Traffic_6CC_24UE_DlMedTputBler0_UlBler0
    run_script             once         AutoGen_UE_25_to_32_Setup_DL90mbps.sce
    run_script             once         AutoGen_UE_33_to_48_Setup_DL300mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_25_to_48_Stats.sce
    run_script             once         AutoGen_UE_25_to_48_Release.sce
    run_checks             ${step_name}    CNI-102921    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_Traffic_6CC_24UE_DlMedTputBler0_UlBler0}    PASS

Step_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_Setup_DL5mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_5_ScellActivEndur_DL250mbps.sce
    run_script             once         AutoGen_UE_1_to_5_Release.sce
    run_checks             ${step_name}    ScellActivEndur    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_5UE_DlMedTputBler0_UlBler0}    PASS

Step_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_50_Setup_DL5mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_ScellActivEndur_DL495mbps.sce
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_checks             ${step_name}    ScellActivEndur    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_50UE_DlHighTputBler0_UlBler0}    PASS

Step_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_100_Setup_DL30mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_100_Stats.sce
    run_script             once         AutoGen_UE_1_to_100_Release.sce
    run_checks             ${step_name}    ScellActivEndur    ${pm_path}    ${syslog}    max_syslog_rate=1700
    Set Suite Variable     ${Verdict_ScellActivEndur_2CC_100UE_DlLowTputBler0_UlBler0}    PASS

Step_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0
    set_oam_parameter      MRBTS-1/NRBTS-1/NRCELL-3    maxNumOfSCellAlloc    5
    run_script             once         AutoGen_UE_1_to_5_Setup_DL440mbps.sce
    run_script             once         AutoGen_UE_6_to_10_Setup_DL11mbps.sce
    set_oam_parameter      MRBTS-1/NRBTS-1/NRCELL-3    maxNumOfSCellAlloc    250
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_10_Stats.sce
    run_script             once         AutoGen_UE_1_to_10_Release.sce
    run_checks             ${step_name}    Traffic    ${pm_path}    ${syslog}
    Set Suite Variable     ${Verdict_MaxNumOfSCellAlloc_2CC_10UE_DlHighTputBler0_UlBler0}    PASS

Step_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_32_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_33_to_55_SetupEndur_DL8mbps.sce
    run_script             once         AutoGen_UE_1_to_32_Release.sce
    run_checks             ${step_name}    SetupEndur    ${pm_path}    ${syslog}    max_syslog_rate=400
    Set Suite Variable     ${Verdict_SetupEndur_2CC_55UE_DlHighTputBler0_UlBler0}    PASS

Step_RLF_2CC_6UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_RLF_2CC_6UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    RLF_2CC_6UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_6_RLF_DL20mbps.sce
    run_script             once         AutoGen_UE_1_to_5_Release.sce
    run_checks             ${step_name}    RLF    ${pm_path}    ${syslog}    max_syslog_rate=600
    Set Suite Variable     ${Verdict_RLF_2CC_6UE_DlHighTputBler0_UlBler0}    PASS

Step_RLF_2CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_RLF_2CC_10UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    RLF_2CC_10UE_DlHighTputBler0_UlBler0
    run_script             once         AutoGen_UE_1_to_5_Setup_DL440mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_6_to_10_RLF_DL1mbps.sce
    run_script             once         AutoGen_UE_1_to_5_Release.sce
    run_checks             ${step_name}    RLF    ${pm_path}    ${syslog}    max_syslog_rate=600
    Set Suite Variable     ${Verdict_RLF_2CC_10UE_DlHighTputBler0_UlBler0}    PASS

Step_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_1_to_60_Setup_DL300mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_61_to_120_Setup_DL300mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_121_to_180_Setup_DL300mbps_UL30mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_181_to_190_RLF_DL1mbps.sce
    run_script             once         AutoGen_UE_1_to_180_Release.sce
    run_checks             ${step_name}    RLF    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0}    PASS

Step_HO_2CC_10UE_DlHighTputBler0_UlBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}    ${enable_pcap}=False
    Set Suite Variable     ${Verdict_HO_2CC_10UE_DlHighTputBler0_UlBler0}    FAILED
    ${step_name}           set variable    HO_2CC_10UE_DlHighTputBler0_UlBler0${step_name_suffix}
    run_script             once            AutoGen_UE_1_to_10_Setup_DL440mbps.sce
    Run Keyword If    ${enable_pcap}       Start_pcap_asim_abip
    ${pm_path}    ${syslog}                run_probation_period    ${step_name}    AutoGen_UE_1_to_5_HO.sce
    #need to get snapshot as sosReport bts_snapshot is not concistant
    # ${snapshot_file}       OAM Get Snapshot    #commented as I see BLER during HO in bts_snashot in sosReport
    Run Keyword If    ${enable_pcap}       Stop_pcap_asim_abip
    run_script             once            AutoGen_UE_1_to_10_Release.sce
    run_checks             ${step_name}    Handover    ${pm_path}    ${syslog}    max_syslog_rate=700
    Set Suite Variable     ${Verdict_HO_2CC_10UE_DlHighTputBler0_UlBler0}    PASS

Step_RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0
    [Timeout]              12hours
    [Arguments]            ${step_name_suffix}=${EMPTY}
    Set Suite Variable     ${Verdict_RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0}    FAILED
    ${step_name}           set variable    RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0${step_name_suffix}
    run_script             once         AutoGen_UE_1_to_50_Setup_DL300mbps_UL30mbps.sce
    run_script             once         AutoGen_UE_61_to_110_Setup_DL300mbps_UL30mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_111_to_120_RLF_DL1mbps.sce
    run_script             once         AutoGen_UE_1_to_50_Release.sce
    run_script             once         AutoGen_UE_61_to_110_Release.sce
    run_checks             ${step_name}    RLF    ${pm_path}    ${syslog}    max_syslog_rate=800
    Set Suite Variable     ${Verdict_RLF_2CC_110UE_DlMedTputBler0_UlMedTputBler0}    PASS

Step_Endurance
    [Timeout]              100hours
    [Arguments]            ${repeat_kw}    ${nb_loop}
    Set Suite Variable     ${Verdict_Endurance}    FAILED
    Run Keyword            ${repeat_kw}
    ${resources_usage1}    Hardening.Get Resources
    FOR     ${iteration}   IN RANGE    1    1 + ${nb_loop}
        Run Keyword            ${repeat_kw}
        ${resources_usage2}    Hardening.Get Resources
        ${resources_diff}      Hardening.Compare Resources With Tolerance    ${resources_usage1}    ${resources_usage2}
        ...                    ${CURDIR}/../../config/resource_usage/tolerance.csv
        write_to_report        Iteration ${iteration}, Resource usage differences: ${resources_diff}
        # commented by DTN 20/06/2024: test is not failed even if difference in resources, only report in the log
        # should be empty        ${resources_diff}
    END
    Set Suite Variable     ${Verdict_Endurance}    PASS

Step_Multiple-Cell-Block-Unblock
    [Timeout]               12hours
    [Arguments]             ${cell-to-block}=1    ${nb_block-unblock}=20     ${nbUE}=1
    Set Suite Variable      ${Verdict_Multiple-Cell-Block-Unblock}    FAILED
    write_to_report         Multiple-Cell-Block-Unblock
    ${gnb_alias}            Set Variable    gNodeB
    sbts_coam.connect_to    name=${gnb_alias}
    ${cell_name}            Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell-to-block}
    Empty Buffer For Egate
    ${iSAct}                SSH Wait For Connect and Cmd
    ...     command=grep 'SCellIndex 1 activated successfully at airphone' ${tl.core.dir_path}/egate_console.log|wc -l
    ...     host=${HOST_EPCSIM}
    FOR     ${round}       IN RANGE    1    ${nb_block-unblock} + 1
        run_script              once          AutoGen_UE_1_Setup_DL150mbps.sce
        run_script              once          UE_1_StartTraffic_DL290mbps.sce
        wait until keyword succeeds     1min    10s
        ...                     Check sCellAddition in AP log    nbUE=${nbUE}   nbScellAct=${round}   iSAct=${iSAct}
        run_script              once          AutoGen_UE_1_Stats_Short.sce
        sbts_coam.block_cell    dist_name=${cell_name}    connection=${gnb_alias}
        write_to_report         ${cell_name} Blocked
        Sleep                   20sec
        sbts_coam.unblock_cell  dist_name=${cell_name}    connection=${gnb_alias}
        write_to_report         ${cell_name} Unblocked
        ${nbCell}               evaluate         ${round}+6
        ${nbCell}               convert to string        ${nbCell}
        wait until keyword succeeds     5min    10s
        ...                             Check SIB MultiCell    nbCell=${nbCell}
        write_to_report         Block/Unblock Cell=${cell-to-block} number ${round} to ${nb_block-unblock}
    END
    Set Suite Variable      ${Verdict_Multiple-Cell-Block-Unblock}    PASS

# start of section with steps from Krakow CRT Tansversal Robustness added from 20/03/2024 by denis.taupin@nokia.com
Step_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9}    FAILED
    ${step_name}           set variable    Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9
    run_script             once         AutoGen_UE_1_to_50_Setup_DL50mbps_UL150mbps.sce
    run_script             once         AutoGen_UE_1_to_50_UlBler9.sce
    # BHR begin 31/10/2024 : Re introduce collect_timemarker argument
    ${pm_path}    ${syslog}    run_probation_period   ${step_name}   AutoGen_UE_1_to_50_Stats.sce   collect_timemarker
    # ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_50_Stats.sce
    # BHR end
    run_script             once         AutoGen_UE_1_to_50_UlBler0.sce
    run_script             once         AutoGen_UE_1_to_50_UlDlStop_Release.sce
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_50UE_FR1_DlLowTputBler0_UlHighTputBler9}    PASS

Step_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release}    FAILED
    ${step_name}           set variable    Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release
    run_script             once         AutoGen_UE_1_to_20_DlBler9.sce
    run_script             once         AutoGen_UE_1_to_20_Setup_DL200mbps_UL100mbps.sce
    # BHR begin 31/10/2024 : Re introduce collect_timemarker argument
    ${pm_path}    ${syslog}    run_probation_period   ${step_name}   AutoGen_UE_1_to_20_Stats.sce   collect_timemarker
    # ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce
    # BHR end
    run_script             once         AutoGen_UE_1_to_20_UlDlStop_Release.sce
    run_script             once         AutoGen_UE_1_to_20_DlBler0.sce
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_DL_Bler_During_Attach_And_Release}    PASS

Step_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release}    FAILED
    ${step_name}           set variable    Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release
    run_script             once         AutoGen_UE_1_to_20_UlBler9.sce
    run_script             once         AutoGen_UE_1_to_20_Setup_DL200mbps_UL100mbps.sce
    # BHR begin 31/10/2024 : Re introduce collect_timemarker argument
    ${pm_path}    ${syslog}    run_probation_period   ${step_name}   AutoGen_UE_1_to_20_Stats.sce   collect_timemarker
    # ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce
    # BHR end
    run_script             once         AutoGen_UE_1_to_20_UlDlStop_Release.sce
    run_script             once         AutoGen_UE_1_to_20_UlBler0.sce
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_UL_Bler_During_Attach_And_Release}    PASS

Step_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release}    FAILED
    ${step_name}           set variable    Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release
    run_script             once         AutoGen_UE_1_to_20_DlBler9_UlBler9.sce
    run_script             once         AutoGen_UE_1_to_20_Setup_DL200mbps_UL100mbps.sce
    # BHR begin 31/10/2024 : Re introduce collect_timemarker argument
    ${pm_path}    ${syslog}    run_probation_period   ${step_name}   AutoGen_UE_1_to_20_Stats.sce   collect_timemarker
    # ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_20_Stats.sce
    # BHR end
    run_script             once         AutoGen_UE_1_to_20_UlDlStop_Release.sce
    run_script             once         AutoGen_UE_1_to_20_DlBler0_UlBler0.sce
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_20UE_FR1_DL_UL_Bler_During_Attach_And_Release}    PASS

Step_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check}    FAILED
    ${step_name}           set variable    Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check
    # ---------------------------------------------------------------------
    # For DL traffic
    # ---------------------------------------------------------------------
    # Attach SA and NSA Ues on each 4 cells
    # -------------------------------------
    run_script             once         AutoGen_UE_1_Setup.sce
    run_script             once         AutoGen_UE_21_Setup.sce
    run_script             once         AutoGen_UE_51_Setup.sce
    run_script             once         AutoGen_UE_71_Setup.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_101_SetupNSA.sce
    run_script             once         AutoGen_UE_121_SetupNSA.sce
    run_script             once         AutoGen_UE_151_SetupNSA.sce
    run_script             once         AutoGen_UE_171_SetupNSA.sce
    alms_hdlr.check_detected_alarms

    # Start DL traffic for SA and NSA UE on each 4 cell
    # --> Check detected alarms when start cell by cell
    # -------------------------------------------------
    run_script             once         AutoGen_UE_1_StartTraffic_DL100mbps.sce
    run_script             once         AutoGen_UE_101_StartTrafficNSA_DL100mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_21_StartTraffic_DL100mbps.sce
    run_script             once         AutoGen_UE_121_StartTrafficNSA_DL100mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_51_StartTraffic_DL100mbps.sce
    run_script             once         AutoGen_UE_151_StartTrafficNSA_DL100mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_71_StartTraffic_DL100mbps.sce
    run_script             once         AutoGen_UE_171_StartTrafficNSA_DL100mbps.sce
    alms_hdlr.check_detected_alarms

    # Enter ZOI Probative period
    # ---------------------------
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_1_to_171_Stats.sce  collect_timemarker

    # Stop Traffic DL and Dettach SA and NSA Ues on each 4 cells
    # ----------------------------------------------------------
    run_script             once         AutoGen_UE_1_StopTraffic_DL_Release.sce
    run_script             once         AutoGen_UE_21_StopTraffic_DL_Release.sce
    run_script             once         AutoGen_UE_51_StopTraffic_DL_Release.sce
    run_script             once         AutoGen_UE_71_StopTraffic_DL_Release.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_101_StopTraffic_DL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_121_StopTraffic_DL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_151_StopTraffic_DL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_171_StopTraffic_DL_ReleaseNSA.sce
    alms_hdlr.check_detected_alarms
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check}    PASS

Step_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check}    FAILED
    ${step_name}           set variable    Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check
    # ---------------------------------------------------------------------
    # For UL traffic
    # ---------------------------------------------------------------------
    # Attach SA and NSA Ues on each 4 cells
    # -------------------------------------
    run_script             once         AutoGen_UE_1_Setup.sce
    run_script             once         AutoGen_UE_21_Setup.sce
    run_script             once         AutoGen_UE_51_Setup.sce
    run_script             once         AutoGen_UE_71_Setup.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_101_SetupNSA.sce
    run_script             once         AutoGen_UE_121_SetupNSA.sce
    run_script             once         AutoGen_UE_151_SetupNSA.sce
    run_script             once         AutoGen_UE_171_SetupNSA.sce
   alms_hdlr.check_detected_alarms

    # Start UL traffic for SA and NSA UE on each 4 cell
    # --> Check detected alarms when start cell by cell
    # -------------------------------------------------
    run_script             once         AutoGen_UE_1_StartTraffic_UL50mbps.sce
    run_script             once         AutoGen_UE_101_StartTrafficNSA_UL50mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_21_StartTraffic_UL50mbps.sce
    run_script             once         AutoGen_UE_121_StartTrafficNSA_UL50mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_51_StartTraffic_UL50mbps.sce
    run_script             once         AutoGen_UE_151_StartTrafficNSA_UL50mbps.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_71_StartTraffic_UL50mbps.sce
    run_script             once         AutoGen_UE_171_StartTrafficNSA_UL50mbps.sce
    alms_hdlr.check_detected_alarms

    # Enter ZOI Probabtive period
    # ---------------------------
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}   AutoGen_UE_1_to_171_Stats.sce   collect_timemarker

    # Stop Traffic UL and Dettach SA and NSA Ues on each 4 cells
    # -----------------------------------------------------------
    run_script             once         AutoGen_UE_1_StopTraffic_UL_Release.sce
    run_script             once         AutoGen_UE_21_StopTraffic_UL_Release.sce
    run_script             once         AutoGen_UE_51_StopTraffic_UL_Release.sce
    run_script             once         AutoGen_UE_71_StopTraffic_UL_Release.sce
    alms_hdlr.check_detected_alarms
    run_script             once         AutoGen_UE_101_StopTraffic_UL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_121_StopTraffic_UL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_151_StopTraffic_UL_ReleaseNSA.sce
    run_script             once         AutoGen_UE_171_StopTraffic_UL_ReleaseNSA.sce
    alms_hdlr.check_detected_alarms
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450
    Set Suite Variable     ${Verdict_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check}    PASS

Step_Alarms_Check_during_oamModifications
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Alarms_Check_during_oamModifications}    FAILED
    ${step_name}           set variable    Alarms_Check_during_oamModifications

    # Change cells parameter without gNB reset
    # --> Check detected alarms
    # ----------------------------------------
    change cells parameter without gNB reset

    # Change gNB parameter without gNB reset
    # --> Check detected alarms
    # --------------------------------------
    change gnb parameter without gNB reset

    # Change gNB parameter with gNB reset
    # --> Check detected alarms
    # --------------------------------------
    change gNB parameter with gNB reset

    # Change cells parameter with gNB reset
    # --> Check detected alarms
    # --------------------------------------
    change cells parameter with gNB reset
    Set Suite Variable     ${Verdict_Alarms_Check_during_oamModifications}    PASS

Change gNB parameter without Gnb reset
    Check detected alarms
    ta_emss.Configure    {'MOC': 'NRBTS', 'ID': '1', 'actFullPlmnList': 'true', 'actETWS': 'true', "actPCMDReport": 'true'}
    Check detected alarms
    ta_emss.Configure    {'MOC': 'NRBTS', 'ID': '1', 'actFullPlmnList': 'false', 'actETWS': 'false', "actPCMDReport": 'false'}
    Check detected alarms
# end of section with Krakow CRT Tansversal Robustness

# BHR begin 14/08/2024 / updated DTN 20/08/2024: section for CNI-110775 Test Cases
# --------------------------------------------------------
Step_Traffic_1CC_30UE_DlUlLowTputBler0_10UE_SetupRelease
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_30UE_DlUlLowTputBler0_10UE_SetupRelease}  FAILED
    ${step_name}           set variable    Traffic_1CC_30UE_DlUlLowTputBler0_10UE_SetupRelease
    run_script             once         AutoGen_UE_1_to_30_Setup_DL150mbps_UL30Mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_31_to_40_SetupEndur.sce
    run_script             once         AutoGen_UE_1_to_30_Release_CNI110775.sce
    run_checks             ${step_name}    ScellActivEndur    ${pm_path}    ${syslog}    max_syslog_rate=1700
    Set Suite Variable     ${Verdict_Traffic_1CC_30UE_DlUlLowTputBler0_10UE_SetupRelease}    PASS

Step_Traffic_1CC_70UE_DlUlLowTputBler0_30UE_SetupRelease
    [Timeout]              12hours
    Set Suite Variable     ${Verdict_Traffic_1CC_70UE_DlUlLowTputBler0_30UE_SetupRelease}  FAILED
    ${step_name}           set variable    Traffic_1CC_70UE_DlUlLowTputBler0_30UE_SetupRelease
    run_script             once         AutoGen_UE_1_to_70_Setup_DL350mbps_UL70Mbps.sce
    ${pm_path}    ${syslog}    run_probation_period    ${step_name}    AutoGen_UE_71_to_100_SetupEndur.sce
    run_script             once         AutoGen_UE_1_to_70_Release_CNI110775.sce
    run_checks             ${step_name}    ScellActivEndur    ${pm_path}    ${syslog}    max_syslog_rate=1700
    Set Suite Variable     ${Verdict_Traffic_1CC_70UE_DlUlLowTputBler0_30UE_SetupRelease}    PASS

# BHR/DTN end

Step_Postlude
    Set Suite Variable     ${Verdict_Postlude}    FAILED
    write_to_report        Executed steps:
    FOR                    ${step}    IN    @{ListStep}
        write_to_report    ${step}
    END
    save_config_files      Postlude
    Run                    cp /opt/wts/latest/egate_console.log.* ${LOG_PATH}/
    Run                    cp /opt/wts/latest/*.cfg ${LOG_PATH}/
    Run                    pip list > ${LOG_PATH}/pip_list.log
    Run                    git log -1 > ${LOG_PATH}/git_status.log
    Run                    git status >> ${LOG_PATH}/git_status.log
    ${snapshot_file}       OAM Get Snapshot
    Set Suite Variable     ${Verdict_Postlude}    PASS
    # BHR begin 30/09/2024 : SWENG kw to update automatically RP/QC mandatory configuration_id field
    Produce Scout Data
    # BHR end

Block-Unblock-PCells
    write_to_report         Block-Unblock-PCells
    ${gnb_alias}            Set Variable    gNodeB
    sbts_coam.connect_to    name=${gnb_alias}
    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    connection=${gnb_alias}
    sbts_coam.block_cell    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    connection=${gnb_alias}
    sbts_coam.unblock_cell  dist_name=MRBTS-1/NRBTS-1/NRCELL-1    connection=${gnb_alias}
    sbts_coam.unblock_cell  dist_name=MRBTS-1/NRBTS-1/NRCELL-5    connection=${gnb_alias}
    run_script              once    AutoGen_UE_1_to_200_Deregister.sce

get_alarm_list
    ${gnb_alias}            Set Variable    gNodeB
    sbts_coam.connect_to    name=${gnb_alias}
    ${historic_alarms}      sbts_coam.get_historic_alarms    connection=${gnb_alias}
    ${active_alarms}        sbts_coam.get_active_alarms      connection=${gnb_alias}
    write_to_report         HISTORIC: ${historic_alarms}
    write_to_report         ACTIVE: ${active_alarms}

run_probation_period
    [Arguments]            ${step_name}    ${script_name}    ${timemarker_mode}=no_timemarker    ${mode}=pm_period    ${reportingIntervalPm}=5min
    run keyword if         '${tti_mode}'=='collect_tti'    dcap_start_tti    duration_seconds=60
    ${syslog}              SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${step_name}
    run_script             ${mode}    ${script_name}    reportingIntervalPm=${reportingIntervalPm}
    ${pm_path}             Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    write_to_report        parametre passed to Collect PM files from BTS = ${LOG_PATH}/PM
    SYSLOG Stop            syslog=${syslog}
    run keyword if         '${timemarker_mode}'=='collect_timemarker'    get_snapshot_and_process    ${step_name}
    # run keyword if         '${sherpa_mode}'=='activate_sherpa'    collect_sherpa
    [return]               ${pm_path}    ${syslog}

collect_sherpa
    write_to_report        Collecting sherpa trace
    Run                    sudo tshark -ni eth3 -w /tmp/sherpa.pcap -a filesize:20000 -a duration:20 port 5678
    Run                    sudo chmod a+r /tmp/sherpa.pcap
    write_to_report        Sherpa trace collected

get_snapshot_and_process
    [Arguments]            ${step_name}
    ${snapshot_file}       OAM Get Snapshot
    # BHR begin 17/06/2024 : Comment kw
    # BHR begin 14/10/2024 : Un comment kw to re activate taimemarker collection
    extract_time_marker    ${snapshot_file}   ${OUTPUT_DIR}/TimeMarker   ${short_feature_name}   ${step_name}
    # BHR end
    # BHR begin 31/10/2024: Added
    update_timemarker_script             ${step_name}
    # BHR end
    extract_tti_events     ${snapshot_file}   ${OUTPUT_DIR}/TtiEvents    ${step_name}
    Run                    rm ${snapshot_file}
    # BHR begin 22/10/2024 : To add to Jenkins archive at the end of the test
    Run   cp -rp /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/resources/perf_portal ${OUTPUT_DIR}
    # BHR end

run_script
    [Arguments]            ${mode}    ${script_name}    ${reportingIntervalPm}=5min
    write_to_report        run_script: ${script_name} - with mode: ${mode}
    run keyword if         '${mode}' == 'once'         run_script_once                   ${script_name}
    run keyword if         '${mode}' == 'pm_period'    repeat_script_during_pm_period    ${script_name}
    run keyword if         '${mode}' == 'just_wait'    just_wait    256
    run keyword if         '${mode}' == 'until_next_pm_start'    until_next_pm_start    ${reportingIntervalPm}    ${script_name}
    run keyword if         '${mode}' == 'by_telnet_once'    run_sce_by_telnet_once           ${script_name}
    run keyword if         '${mode}' == 'by_telnet_pm'      run_sce_by_telnet_during_pm      ${script_name}

just_wait
    [Arguments]             ${waiting_time}
    write_to_report         sleep for ${waiting_time} seconds
    Sleep                   ${waiting_time}s

until_next_pm_start
    [Arguments]               ${reportingIntervalPm}      ${script_name}=wait    ${until_new_pm_only}=yes
    Set Suite Variable        ${offset_pm}                5
    Set Suite Variable        ${count_pm_period}          0
    Set Suite Variable        ${intervals}                2
    Set Suite Variable        ${time_until_next_5min}    -1
    Set Suite Variable        ${run_sce_duration}        99999
    Set Suite Variable        ${full_pm_left}            -1
    Set Suite Variable        ${temp_full_pm_left}       -1
    Set Suite Variable        ${current_interval}        -1
    Set Suite Variable        ${log_interval}            60
    Set Suite Variable        ${iteration_count}         -1
    Set Suite Variable        ${run_sce}                 True
    Set Suite Variable        ${enough_time_to_run_before_next_pm}                 True
    ${run_sce}=               Evaluate    ('${script_name}' != 'wait') and ${enough_time_to_run_before_next_pm}
    write_to_report           INF: reportingIntervalPm=${reportingIntervalPm}
    write_to_report           INF: until_new_pm_only=${until_new_pm_only}
    write_to_report           INF: script_name=${script_name}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    @{pm_interval_start}    0  1  2  3  4  5  6  7  8  9  10  11
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    @{pm_interval_start}    0  3  6  9
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    @{pm_interval_start}    0
    ...    ELSE        write_to_report     ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${intervals}    2
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${intervals}    4
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${intervals}    13
    ...    ELSE       write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${pm_duration}    300
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${pm_duration}    900
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${pm_duration}    3600
    ...    ELSE       write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    Run Keyword If    '${until_new_pm_only}' == 'yes'     Set Suite Variable    ${intervals}    2
    write_to_report           INF: pm_interval_start=${pm_interval_start}
    write_to_report           INF: intervals to count=${intervals}
    ${stay_in_while}=   Evaluate    True
    WHILE    ${stay_in_while}
        ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Run Keyword If    ${iteration_count} % ${log_interval} == 0    write_to_report
        ...    :::::: ${current_time} count_pm_period=${count_pm_period} - current_interval=${current_interval} - run_sce_duration=${run_sce_duration}
        Run Keyword If    ${iteration_count} % ${log_interval} == 0    write_to_report
        ...    :::::: ${current_time} pmLeft=${full_pm_left} - timeLeft=${time_until_next_5min} - stay_in_while=${stay_in_while} - run_sce=${run_sce}
        ${iteration_count}=    Evaluate    ${iteration_count} + 1
        Run Keyword If    ${run_sce_duration} == 99999    Sleep    1s
        Run Keyword If    ${run_sce}    write_to_report     INF: run_sce_by_telnet_once with ${script_name}
        # write_to_report           DTN250225: run_sce_duration = ${run_sce_duration}
        ${run_sce_duration}=      Run Keyword If    ${run_sce}    run_sce_by_telnet_once     ${script_name}
        # write_to_report           DTN250225: run_sce_duration = ${run_sce_duration}
        Run Keyword If            not ${run_sce}    Set Suite Variable        ${run_sce_duration}        99999
        # write_to_report           DTN250225: run_sce_duration = ${run_sce_duration}
        check_current_pm
        ${current_interval}      Evaluate           int(${current_interval})
        ${full_pm_left}=         Run Keyword If    '${reportingIntervalPm}' == '5min'     Evaluate    (1 - ${current_interval}) % 1
        ...                             ELSE IF    '${reportingIntervalPm}' == '15min'    Evaluate    (2 - ${current_interval}) % 3
        ...                             ELSE IF    '${reportingIntervalPm}' == '60min'    Evaluate    (11 - ${current_interval}) % 12
        ...                             ELSE   write_to_report        ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
        ${is_not_in_start_interval}=             Check Value In List   ${current_interval}    @{pm_interval_start}
        ${less_than_reportingInterval}=          Evaluate    ${count_pm_period} < ${intervals}
        ${enough_time_to_run_before_next_pm}=    Evaluate    ${run_sce_duration} < ${time_until_next_5min} + ${full_pm_left} * 300
        # write_to_report           DTN250225: run_sce_duration = ${run_sce_duration}
        # write_to_report           DTN250225: time_until_next_5min = ${time_until_next_5min}
        # write_to_report           DTN250225: full_pm_left = ${full_pm_left}
        # write_to_report           DTN250225: stay_in_while = ${stay_in_while}
        # write_to_report           DTN250225: run_sce = ${run_sce}
        ${stay_in_while}=                  Evaluate    ${less_than_reportingInterval} or ${is_not_in_start_interval}
        # write_to_report           DTN250225: stay_in_while = ${stay_in_while}
        ${run_sce}=                        Evaluate    ('${script_name}' != 'wait') and ${enough_time_to_run_before_next_pm}
        # write_to_report           DTN250225: run_sce = ${run_sce}
    END
    ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    write_to_report    :::::::::: ${current_time} count_pm_period=${count_pm_period} - current_interval=${current_interval}
    # write_to_report    :::::::::: is_not_in_start_interval=${is_not_in_start_interval} - less_than_reportingInterval=${less_than_reportingInterval}
    # write_to_report    :::::::::: End of until_next_pm_start

Check Value In List
    [Arguments]    ${value}    @{input_list}
    ${found}=    Set Variable    False
    ${value}=    Evaluate    int(${value})
    FOR    ${item}    IN    @{input_list}
        ${item}=     Evaluate    int(${item})
        ${found}=    Evaluate    ${item} == ${value}
        # write_to_report    :::::::::: Check Value In List: value=${value} - item=${item} - found=${found}
        Run Keyword If    ${found}    Exit For Loop
    END
    ${found}=    Evaluate    not ${found}
    [Return]    ${found}

repeat_script_during_pm_period
    [Arguments]            ${script_name}
    ${zoi}                 ZOI Start    40    300    60
    ZOI Repeat Until End   ${zoi}    run_script_once    ${script_name}

run_sce_by_telnet_once
    [Arguments]             ${script_name}
    ${start_time}=          Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    writeTelnetOnce         ${script_name}      ${OUTPUT_DIR}
    ${stop_time}=           Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${run_sce_duration}=    Subtract Date From Date    ${stop_time}   ${start_time}    exclude_millis=yes
    write_to_report         INF: writeTelnetOnce duration = ${run_sce_duration} seconds
    [Return]                ${run_sce_duration}

run_sce_by_telnet_during_pm
    [Arguments]               ${script_name}
    Set Suite Variable        ${count_pm_period}     0
    Set Suite Variable        ${intervals}           3
    Set Suite Variable        ${current_interval}    -1
    WHILE    ${count_pm_period} < ${intervals}
        ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        write_to_report        :::::::::: run_sce_by_telnet_during_pm
        check_current_pm
        write_to_report        current_interval=${current_interval}
        writeTelnetOnce        ${script_name}    ${OUTPUT_DIR}
        ${stop_time}=          Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    END

check_current_pm
    ${current_time}     Get Current Date    result_format=%H:%M:%S
    ${minutes_str}=     Evaluate            str("${current_time}"[3:5])
    ${seconds_str}=     Evaluate            str("${current_time}"[6:8])
    ${minutes}=         Evaluate            "${minutes_str}".lstrip("0") if "${minutes_str}" != "00" else 0
    ${seconds}=         Evaluate            "${seconds_str}".lstrip("0") if "${seconds_str}" != "00" else 0
    ${total_seconds}    Evaluate            int(${minutes}) * 60 + int(${seconds})
    ${interval}         Evaluate            ${total_seconds} // 300
    ${time_until_next_5min}    Evaluate    300 - (${total_seconds} % 300)
    # write_to_report        Current PM interval is : ${interval}
    ${start_time_minutes}     Evaluate           (${interval} * 5) // 60
    ${start_time_seconds}     Evaluate           (${interval} * 5) % 60
    ${end_time_minutes}       Evaluate           (${interval} * 5 + 5) // 60
    ${end_time_seconds}       Evaluate           (${interval} * 5 + 5) % 60
    ${start_time}             Evaluate           "{:02d}:{:02d}:00".format(${start_time_minutes}, ${start_time_seconds})
    ${end_time}               Evaluate           "{:02d}:{:02d}:00".format(${end_time_minutes}, ${end_time_seconds})
    # write_to_report           DTN250225: Current time is within the interval ${interval} : ${start_time} - ${end_time}
    Run Keyword If            '${interval}' != '${current_interval}'         Increment Count
    Set Suite Variable        ${current_interval}             ${interval}
    Set Suite Variable        ${time_until_next_5min}     ${time_until_next_5min}
    # write_to_report           DTN250225: time_until_next_5min = ${time_until_next_5min}

Increment Count
    ${count_pm_period}    Evaluate    ${count_pm_period} + 1
    Set Suite Variable    ${count_pm_period}    ${count_pm_period}
    write_to_report       :::::::::: Count of PM is now ${count_pm_period}

get_last_pm
    [Arguments]        ${reportingIntervalPm}=5min
    ${is_the_last_pm_file}     Set Variable   False
    WHILE    not ${is_the_last_pm_file}
        ${pm_path}                   Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        ${is_the_last_pm_file}=      Check Minutes    ${pm_path}    ${reportingIntervalPm}
        write_to_report       INF: is_the_last_pm_file condition = ${is_the_last_pm_file}
        Run Keyword If    not ${is_the_last_pm_file}      Sleep          5s
    END
    write_to_report       INF: get_last_pm is pm_path=${pm_path}
    [return]                  ${pm_path}

Check Minutes
    [Arguments]     ${pm_path}    ${reportingIntervalPm}
    ${max_delta}    Set Variable    4
    Run Keyword If    '${reportingIntervalPm}' == '5min'     Set Suite Variable    ${max_delta}    4
    ...    ELSE IF    '${reportingIntervalPm}' == '15min'    Set Suite Variable    ${max_delta}    14
    ...    ELSE IF    '${reportingIntervalPm}' == '60min'    Set Suite Variable    ${max_delta}    59
    ...    ELSE        write_to_report     ERR: NOT A VALID reportingIntervalPm = ${reportingIntervalPm}
    write_to_report           INF: reportingIntervalPm = ${reportingIntervalPm}
    write_to_report           INF: max_delta = ${max_delta}
    write_to_report           INF: pm_path = ${pm_path}
    ${matches}=               Get Regexp Matches    ${pm_path}    .+\\d{8}.\\d{2}\(\\d{2}\)\\d{2}.ANY.xml    1
    ${minutes}=               Get From List         ${matches}    0
    ${current_minute}=        Get Current Date    result_format=%M
    ${current_minute_str}=    Evaluate    str("${current_minute}")
    ${minutes_str}=           Evaluate    str("${minutes}")
    ${current_minute}=        Evaluate    "${current_minute_str}".lstrip("0") if "${current_minute_str}" != "00" else 0
    ${minutes}=               Evaluate    "${minutes_str}".lstrip("0") if "${minutes_str}" != "00" else 0
    write_to_report           INF: minutes from current date, MM = ${current_minute}
    write_to_report           INF: minutes from pm file, MM = ${minutes}
    ${delta}=    Evaluate     int(str(${current_minute})) - int(str(${minutes}))
    write_to_report           INF: delta between minutes = ${delta}
    ${result}=   Evaluate     ${minutes} <= ${current_minute} and ${delta} < ${max_delta}
    [return]     ${result}

run_script_once
    [Arguments]            ${script_name}
    # Action 596 run keyword if         '${sherpa_mode}'=='activate_sherpa' and '${script_name}'!='X2_Link_Setup.sce'    activate_sherpa_tcpdump
    wtsemu.script          file=/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/script/${script_name}
    # wtsemu.script          file=${CURDIR}/../../script/${script_name}
    ${output}              wtsemu.read_wtsemu_output_until    PROCESSING    20
    ${output}              wtsemu.read_wtsemu_output_until_prompt    5
    ${script_status}       wait until keyword succeeds    12hours    1s    is_script_finished
    ${error_in_status}=    Run Keyword And Return Status    Should Contain    ${script_status}    error
    # Action 596 run keyword if  '${sherpa_mode}'=='activate_sherpa' and '${script_name}'!='X2_Link_Setup.sce'  stop_tcpdump  ${error_in_status}
    # BHR begin 25/04/2024 call wait_and_take_snapshot_then_sos_report instead of wait_and_take_snapshot
    # run keyword if         ${error_in_status} and ${snapshot_at_egate_error}      wait_and_take_snapshot
    run keyword if         ${error_in_status} and ${snapshot_at_egate_error}      wait_and_take_snapshot_then_sos_report
    # BHR end
    should not match regexp    ${script_status}    error

is_script_finished
    wtsemu.script_status
    ${output}              wtsemu.read_wtsemu_output_until    Status of script    5
    ${script_status}       wtsemu.read_wtsemu_output_until_prompt    5
    # ${log_string}          remove string using regexp    ${script_status}    (=|-| {6,}|\n)
    # ${log_string}          replace string   ${log_string}    description    description${\n}${SPACE}
    # ${log_string}          catenate    Script status:${\n}    ${log_string}
    # Dated Log              ${log_string}    first=True
    should not match regexp    ${script_status}    ( active | paused )
    [Return]               ${script_status}

wait_and_take_snapshot
    Dated log              take snapshot at first error detection during run_script_once
    OAM wait available
    OAM Get Snapshot
    Set Suite Variable     ${snapshot_at_egate_error}     False

wait_and_take_snapshot_then_sos_report
    Dated log              take snapshot then sos report at first error detection during run_script_once
    OAM wait available
    setup.Get Snapshot
	setup.Get Sos Report
    Set Suite Variable     ${snapshot_at_egate_error}     False

write_to_report
    [Arguments]            ${report_string}
    ${date}                DateTime.Get Current Date
    ${formatted_date}      DateTime.Convert Date    ${date}    result_format=%Y%m%d_%Hh%Mm%S
    Log To Console         ${report_string}
    Append To File         ${OUTPUT_DIR}/report.txt    ${formatted_date} Step ${StepNb} - ${report_string} \n
    Append To File         ${OUTPUT_DIR}/../report.txt    ${formatted_date} Step ${StepNb} - ${report_string} \n

generate_qc_script
    ${script}              set variable         ${OUTPUT_DIR}/../qc_script.sh
#    ${tl_topo}                convert to string    ${TLConfig.topo}
#    ${robot_file_name}     get_robot_file_name
#    Append To File         ${script}    echo TL name: ${TLConfig.configName} \n
#    Append To File         ${script}    echo TL address: ${tl.test_pc.default_ssh_connection_details.addr} \n
#    Append To File         ${script}    echo TL topology: ${tl_topo} \n
#    # Append To File         ${script}    echo gNodeB version: ${TLConfig.topo.gnbVersion} \n
#    # Append To File         ${script}    echo gNodeB branch: ${TLConfig.topo.getBranchName()} \n
#    Append To File         ${script}    echo gNodeB build: ${ENB_BUILD} \n
#    Append To File         ${script}    echo Test OUTPUT_DIR: ${OUTPUT_DIR} \n
#    Append To File         ${script}    ssh -o StrictHostKeyChecking=no -o CheckHostIP=no -i /home/ca_psci5g/.ssh/id_rsa_ute ute@
#    Append To File         ${script}    ${tl.test_pc.default_ssh_connection_details.addr} ${SPACE}
#    Append To File         ${script}    /home/ute/test_repo/bin/ute_reporting_portal send -ie ${SPACE}
#    Append To File         ${script}    -ro ${OUTPUT_DIR}/output.xml ${SPACE}
#    Append To File         ${script}    -tl ${TLConfig.configName} --info "${tl_topo}" -v ${SPACE}
#    Append To File         ${script}    --file_path ${feature_dir}/${robot_file_name} ${SPACE}
#    Append To File         ${script}    --sw_version "${ENB_BUILD}" --username "app_cloud_regression" ${SPACE}
#    Append To File         ${script}    -l "${tl_topo}" \n
    Append To File         ${script}    echo This script is not used anymore, job done by update_rep_portal.py \n

run_checks
    [Arguments]     ${step_name}    ${test_type}    ${pm_path}    ${syslog}
    ...             ${max_syslog_rate}=400    ${check_tti}=yes    ${compare_pm_metric}=none
    ...             ${KPI_DICTIONARY}=SWENG

    ${branchName}          set variable    ${TLConfig.topo.getBranchName()}
    ${KPI_DICT_SWENG}      Set Variable    /home/ute/CrtRoot/robotws/testsuite/Paris/resources/SWENG/config/KPI/${branchName}/KPI_Definitions.csv
    ${KPI_DICT_TO_USE}     Set Variable    ${None}
    write_to_report        INF: KPI_DICTIONARY before check = ${KPI_DICTIONARY}
    # following condition is to set the KPI_DICT_TO_USE = ${None} in case the SWENG dictionary is used
    ${KPI_DICT_TO_USE}     Run Keyword If      "${KPI_DICTIONARY}" != "SWENG"    Set Variable    ${KPI_DICTIONARY}
    write_to_report        INF: run_checks - KPI_DICT_SWENG = ${KPI_DICT_SWENG}
    write_to_report        INF: run_checks - KPI_DICTIONARY = ${KPI_DICTIONARY}
    write_to_report        INF: run_checks - KPI_DICT_TO_USE = ${KPI_DICT_TO_USE}
    write_to_report        INF: run_checks - step_name: ${step_name}
    write_to_report        INF: run_checks - test_type: ${test_type}
    write_to_report        INF: run_checks - pm_path: ${pm_path}

    # status are used to check either the kw is Fail (False) or Pass (True), is it updated after execution by the kw Run Keyword And Return Status
    # the kw run_checks is Fail only if one of the following check is Fail (False is returned by Run Keyword And Return Status if Fail)
    ${is_check_counter_and_kpi_pass}         set variable    True
    ${is_check_tti_events_pass}              set variable    True
    ${is_compare_pm_pass}                    set variable    True
    ${is_history_pm_pass}                    set variable    True
    ${is_check_syslog_pass}                  set variable    True
    ${is_syslog_parsing_pass}                set variable    True

    # check the counter and KPI are in the expected constraints
    ${is_check_counter_and_kpi_pass}=    Run Keyword And Return Status    check_counter_and_kpi_constraints
    ...                                                                   ${pm_path}    ${step_name}    ${KPI_DICT_TO_USE}
    # write_to_report        INF: status check_counter_and_kpi_constraints PASS = ${is_check_counter_and_kpi_pass}
    update_counter_history_script          ${step_name}    ${pm_path}    ${is_check_counter_and_kpi_pass}
    # BHR begin 11/06/2024: create update_kpi_history_script
    Run Keyword If      "${KPI_DICTIONARY}" == "SWENG"    update_kpi_history_script       ${step_name}    ${pm_path}    ${KPI_DICT_SWENG}
    Run Keyword If      "${KPI_DICTIONARY}" != "SWENG"    update_kpi_history_script       ${step_name}    ${pm_path}    ${KPI_DICTIONARY}
    # BHR end
    # BHR begin 27/08/2024: create update_load_meas_history_script
    update_load_meas_history_script        ${step_name}    ${pm_path}    ${syslog}
    # BHR end
    # BHR begin 15/05/2024: No longer need to call this kw, call of this kw is commented.
    # BHR begin 14/10/2024: Re introduce this function
    # BHR begin 31/10/2024: Commented here , and moved to kw get_snapshot_and_process
    # update_timemarker_script             ${step_name}
    # BHR end

    # check some tti event presence in the tti trace
    ${is_check_tti_events_pass}=    Run Keyword And Return Status    Run Keyword If     '${check_tti}' == 'yes'    check_tti_events       ${step_name}

    # check error in sherpa trace COMMENTED since SHEPRA being deprecated
    # run keyword if         '${sherpa_mode}'=='activate_sherpa'    check_sherpa    ${step_name}

    # compare the counter or KPI from the two last PM files
    ${is_compare_pm_pass}=    Run Keyword And Return Status    Run Keyword If    '${compare_pm_metric}' != 'none'    compare_pm
    ...                      ${step_name}    ${OUTPUT_DIR}
    ...                      history=last    metric=${compare_pm_metric}    deviation=10    delta=0.01
    write_to_report        INF: status compare_pm PASS = ${is_compare_pm_pass}
    ${is_history_pm_pass}=    Run Keyword And Return Status    history_pm
    ...                      ${step_name}    ${OUTPUT_DIR}    metric=${compare_pm_metric}
    write_to_report        INF: status history_pm PASS = ${is_history_pm_pass}
    # below setting is needed not to fail the run_checks kw in case compare_pm is not run (metric = none)
    Run Keyword If    '${compare_pm_metric}' == 'none'    Set Variable    ${is_compare_pm_pass}    True
    Run Keyword If    '${compare_pm_metric}' == 'none'    write_to_report    INF: run_checks - compare PM is not run
    # write_to_report        INF: status compare_pm PASS = ${is_compare_pm_pass}

    # check new ERR and WRN in the syslog
    ${is_check_syslog_pass}=      Run Keyword And Return Status   check_syslog    ${step_name}    ${test_type}    ${syslog}    ${max_syslog_rate}
    # write_to_report        INF: status check_syslog PASS = ${is_check_syslog_pass}

    # check presence of existing signatures
    ${is_syslog_parsing_pass}=    Run Keyword And Return Status    syslog_parsing         ${syslog}
    # write_to_report        INF: status syslog_parsing PASS = ${is_syslog_parsing_pass}

    # final check to log result and Fail or Pass the kw run_checks
    write_to_report    ::::::::::::::::::::::::::::::::::::::::::::::::::::
    write_to_report    :::::::::: Summary result for run_checks :::::::::::
    write_to_report    ::::::::::::::::::::::::::::::::::::::::::::::::::::

    Run Keyword If    not ${is_compare_pm_pass}                       write_to_report    ERR: run_checks - compare PM FAIL
    Run Keyword If    ${is_compare_pm_pass}                           write_to_report    INF: run_checks - compare PM PASS
    Run Keyword If    not ${is_check_tti_events_pass}                 write_to_report    ERR: run_checks - check tti events FAIL
    Run Keyword If    ${is_check_tti_events_pass}                     write_to_report    INF: run_checks - check tti events PASS
    Run Keyword If    not ${is_check_syslog_pass}                     write_to_report    ERR: run_checks - syslog new ERR/WRN FAIL
    Run Keyword If    ${is_check_syslog_pass}                         write_to_report    INF: run_checks - syslog new ERR/WRN PASS
    Run Keyword If    not ${is_syslog_parsing_pass}                   write_to_report    ERR: run_checks - syslog existing signature FAIL
    Run Keyword If    ${is_syslog_parsing_pass}                       write_to_report    INF: run_checks - syslog existing signature PASS
    Run Keyword If    not ${is_check_counter_and_kpi_pass}            write_to_report    ERR: run_checks - counter and kpi constraints FAIL
    Run Keyword If    ${is_check_counter_and_kpi_pass}                write_to_report    INF: run_checks - counter and kpi constraints PASS
    write_to_report    ::::::::::::::::::::::::::::::::::::::::::::::::::::

    Run Keyword If    not ${is_check_tti_events_pass}                 Fail    failure during run_checks
    Run Keyword If    not ${is_check_counter_and_kpi_pass}            Fail    failure during run_checks
#    Run Keyword If    not ${is_compare_pm_pass}                       Fail    failure during run_checks  # commented not to fail the test
    Run Keyword If    not ${is_check_syslog_pass}                     Fail    failure during run_checks
    Run Keyword If    not ${is_syslog_parsing_pass}                   Fail    failure during run_checks


initialize_counter_history_script
    ${script}              set variable    ${OUTPUT_DIR}/Counter/counter_history_script.sh
    Append To File         ${script}    echo This script will be run on Jenkins host \n
    Run                    cp ${CURDIR}/../python/evaluate_counter_history.py ${OUTPUT_DIR}/Counter/
    # BHR begin 29/10/2024 : COmment following line extract_tput is nolonger used
    # Run                    cp ${CURDIR}/../python/extract_tput.py ${OUTPUT_DIR}/Counter/
    # BHR end
    Run                    cp ${CURDIR}/../../config/counter/counter_history/list_excluded_missing_counter.csv ${OUTPUT_DIR}/Counter/

update_counter_history_script
    [Arguments]            ${step_name}    ${pm_path}    ${is_check_counter_and_kpi_pass}
    write_to_report        INF: update_counter_history_script - running...
    ${path_parts}=       Split String    ${pm_path}    /
    ${pm_file_name}=       Get From List    ${path_parts}    -1
    ${pm_file_name_fail}=     Set Variable    ${pm_file_name}fail
    Remove From List    ${path_parts}    -1
    ${pm_dir_path}=    Catenate    SEPARATOR=/    @{path_parts}
    ${pm_file_name_fail_path}=    Set Variable    ${pm_dir_path}/${pm_file_name_fail}
    # write_to_report        INF: update_counter_history_script - OUTPUT_DIR = ${OUTPUT_DIR}
    # write_to_report        INF: update_counter_history_script - CURDIR = ${CURDIR}
    write_to_report        INF: update_counter_history_script - pm_path = ${pm_path}
    # write_to_report        DTN241203: DBG: pm_file_name_fail = ${pm_file_name_fail}
    # write_to_report        DTN241203: DBG: pm_file_name_fail_path = ${pm_file_name_fail_path}
    ${branchName}          set variable    ${TLConfig.topo.getBranchName()}
    ${pretty_counter_file}    create_pretty_counter_file    ${pm_path}    ${OUTPUT_DIR}/Counter/${step_name}/
    ...                    ${CURDIR}/../../../../../resources/SWENG/config/KPI/${branchName}/Counter_Definitions.csv
    ${script}              set variable    ${OUTPUT_DIR}/Counter/counter_history_script.sh
    Append To File         ${script}    echo RUN: evaluate_counter_history.py ${step_name} \n
    Append To File         ${script}    python3 Counter/evaluate_counter_history.py ${SPACE}
    Append To File         ${script}    ute 10.14.38.159 /ceph/VRF/COMMON/TranRob/${long_feature_name}/Counter/${branchName} ${SPACE}
    Append To File         ${script}    ${step_name} ${pretty_counter_file}.csv\n
    Run                    cp ${pm_path} ${OUTPUT_DIR}/Counter/${step_name}/

    # DTN: 241203 adding a file named xmlfail, only in case the check_KPI is not passed
    Run Keyword If    not ${is_check_counter_and_kpi_pass}
    ...       Run Keywords    write_to_report        INF: update_counter_history_script - enter code for condition False (Fail)
    ...       AND             Run Keyword And Warn On Failure    Run    cp ${pm_path} ${OUTPUT_DIR}/Counter/${step_name}/${pm_file_name_fail}

    # BHR begin 17/06/2024 : Comment kw
    # ${pbi_script}          set variable    ${OUTPUT_DIR}/Counter/powerbi_counter_script.sh
    # BHR end
    #Append To File         ${pbi_script}    echo Processing ${step_name} \n
    #Append To File         ${pbi_script}    echo Processing ${step_name} \n
    #Append To File         ${pbi_script}    python3 et_counters_value.py --branch MASTER ${SPACE}
    #Append To File         ${pbi_script}    --xmlFile ../../Counter/${step_name}/${pretty_counter_file}.xml ${SPACE}
    #Append To File         ${pbi_script}    --swVersion ${GNB_BTS_INFO['swInfo']['swVersion']} --testName ${short_feature_name}_${step_name}\n
    # BHR begin 17/06/2024 : Comment kws
    # Append To File         ${pbi_script}    echo This script is not used anymore, job done by keyword PowerBI Upload PM File \n
    # run_keyword_and_warn_on_failure    PowerBI Upload PM File    pm_path=${pm_path}    tc_name=${short_feature_name}_${step_name}
    # BHR end

# BHR begin 19/06/2024: kw added
initialize_kpi_history_script
    ${script}              set variable    ${OUTPUT_DIR}/Counter/kpi_history_script.sh
    Append To File         ${script}    echo This script will be run on Jenkins host \n
    Run                    cp ${CURDIR}/../python/evaluate_kpi_history.py ${OUTPUT_DIR}/Counter/
    Run                    cp ${CURDIR}/../../config/counter/counter_history/list_excluded_missing_kpi.csv ${OUTPUT_DIR}/Counter/
# BHR end

# BHR begin 10/06/2024: kw added - Updates 18/06/2024
Update_kpi_history_script
    [Arguments]            ${step_name}    ${pm_path}    ${KPI_DICTIONARY}
    write_to_report        INF: Update_kpi_history_script - running...
    ${branchName}          set variable    ${TLConfig.topo.getBranchName()}
    ${pretty_kpi_file}     create_pretty_kpi_file    ${pm_path}    ${OUTPUT_DIR}/Counter/${step_name}/
    ...                    ${CURDIR}/../../../../../resources/SWENG/config/KPI/${branchName}/Counter_Definitions.csv
    # ...                    ${CURDIR}/../../../../../resources/SWENG/config/KPI/${branchName}/KPI_Definitions.csv
    ...                    ${KPI_DICTIONARY}
    ${script}              set variable    ${OUTPUT_DIR}/Counter/kpi_history_script.sh
    Append To File         ${script}    echo RUN: evaluate_kpi_history.py ${step_name} \n
    Append To File         ${script}    python3 Counter/evaluate_kpi_history.py ${SPACE}
    Append To File         ${script}    ute 10.14.38.159 /ceph/VRF/COMMON/TranRob/${long_feature_name}/Counter/${branchName} ${SPACE}
    Append To File         ${script}    ${step_name} ${pretty_kpi_file}.csv\n
    Run                    cp ${pm_path} ${OUTPUT_DIR}/Counter/${step_name}/
    # ${pbi_script}          set variable    ${OUTPUT_DIR}/Counter/powerbi_counter_script.sh
    # #Append To File         ${pbi_script}    echo Processing ${step_name} \n
    # #Append To File         ${pbi_script}    echo Processing ${step_name} \n
    # #Append To File         ${pbi_script}    python3 et_counters_value.py --branch MASTER ${SPACE}
    # #Append To File         ${pbi_script}    --xmlFile ../../Counter/${step_name}/${pretty_counter_file}.xml ${SPACE}
    # #Append To File         ${pbi_script}    --swVersion ${GNB_BTS_INFO['swInfo']['swVersion']} --testName ${short_feature_name}_${step_name}\n
    # Append To File         ${pbi_script}    echo This script is not used anymore, job done by keyword PowerBI Upload PM File \n
    # run_keyword_and_warn_on_failure    PowerBI Upload PM File    pm_path=${pm_path}    tc_name=${short_feature_name}_${step_name}
# BHR end

# BHR begin 27/08/2024 : Kws added for load measurement history
initialize_load_meas_history_script
    ${script}              set variable    ${OUTPUT_DIR}/Load/load_meas_history_script.sh
    Append To File         ${script}    echo This script will be run on Jenkins host \n
    Run                    cp ${CURDIR}/../python/evaluate_load_meas_history.py ${OUTPUT_DIR}/Load/
    Run                    cp ${CURDIR}/../python/create_pretty_load_meas_file.py ${OUTPUT_DIR}/Load/

update_load_meas_history_script
    [Arguments]            ${step_name}    ${pm_path}     ${syslog}
    write_to_report        INF: update_load_meas_history_script - running...
    ${branchName}          set variable    ${TLConfig.topo.getBranchName()}
    ${pretty_load_meas_file}    create_pretty_load_meas_file    ${pm_path}   ${syslog.externalPath}
	...   ${OUTPUT_DIR}/Load/${step_name}/
    ${script}              set variable    ${OUTPUT_DIR}/Load/load_meas_history_script.sh
    Append To File         ${script}    echo RUN: evaluate_load_meas_history.py ${step_name} \n
    Append To File         ${script}    python3 Load/evaluate_load_meas_history.py ${SPACE}
    Append To File         ${script}    ute 10.14.38.159 /ceph/VRF/COMMON/TranRob/${long_feature_name}/Load/${branchName} ${SPACE}
    Append To File         ${script}    ${step_name} ${pretty_load_meas_file}.csv\n
# BHR end

Edit_sosReport.cfg
    Dated log              INF: Edit_sosReport.cfg - running...
    ${sos_config}          set variable     /opt/wts/latest/sosReport.cfg

    # Read current file content
    ${file_content}        OperatingSystem.Get File    ${sos_config}

    # Check and modify L1_MODE
    ${l1_mode_ok}=         Run Keyword And Return Status
    ...                    Should Match Regexp    ${file_content}    L1_MODE\\s*=\\s*fullstack

    Run Keyword If         not ${l1_mode_ok}
    ...                    Dated log    INF: Modification of L1_MODE=fullstack in ${sos_config}

    ${file_content}=       Run Keyword If         not ${l1_mode_ok}
    ...                    Replace String Using Regexp    ${file_content}    L1_MODE\\s*=\\s*\\w+    L1_MODE=fullstack
    ...                    ELSE
    ...                    Set Variable    ${file_content}

    # Check and modify ENABLE_BIP_LOG
    ${bip_log_ok}=         Run Keyword And Return Status
    ...                    Should Match Regexp    ${file_content}    ENABLE_BIP_LOG\\s*=\\s*1

    Run Keyword If         not ${bip_log_ok}
    ...                    Dated log    INF: Modification of ENABLE_BIP_LOG=1 in ${sos_config}

    ${file_content}=       Run Keyword If         not ${bip_log_ok}
    ...                    Replace String Using Regexp    ${file_content}    ENABLE_BIP_LOG\\s*=\\s*\\d+    ENABLE_BIP_LOG=1
    ...                    ELSE
    ...                    Set Variable    ${file_content}

    # Check and modify LOG_PATH
    ${log_path_ok}=        Run Keyword And Return Status
    ...                    Should Match Regexp    ${file_content}    LOG_PATH\\s*=\\s*"${LOG_PATH}"

    Run Keyword If         not ${log_path_ok}
    ...                    Dated log    INF: Modification of LOG_PATH="${LOG_PATH}" in ${sos_config}

    ${file_content}=       Run Keyword If         not ${log_path_ok}
    ...                    Replace String Using Regexp    ${file_content}    LOG_PATH\\s*=\\s*"[^"]*"    LOG_PATH="${LOG_PATH}"
    ...                    ELSE
    ...                    Set Variable    ${file_content}

    # Check and modify BIP_NUMBER_OF_FILES
        ${bip_number_ok}=      Run Keyword And Return Status
        ...                    Should Match Regexp    ${file_content}    BIP_NUMBER_OF_FILES\\s*=\\s*25

        Run Keyword If         not ${bip_number_ok}
        ...                    Dated log    INF: Modification of BIP_NUMBER_OF_FILES=25 in ${sos_config}

        ${file_content}=       Run Keyword If         not ${bip_number_ok}
        ...                    Replace String Using Regexp    ${file_content}    BIP_NUMBER_OF_FILES\\s*=\\s*\\d+    BIP_NUMBER_OF_FILES=25
        ...                    ELSE
        ...                    Set Variable    ${file_content}

    # Write modified file
    OperatingSystem.Create File    ${sos_config}    ${file_content}

    Dated log              INF: File ${sos_config} checked and modified if needed

Start_pcap_asim_abip
    Edit_sosReport.cfg
    Dated log              INF: Start_pcap_asim_abip - running...

    # Non-blocking launch of the startup script
    ${handle}=    Start Process    /opt/wts/latest/sosReport_ASIL/startTest_ASIL.sh
    ...           shell=True
    ...           stdout=${OUTPUT_DIR}/startTest_stdout.log
    ...           stderr=${OUTPUT_DIR}/startTest_stderr.log

    # Wait for the confirmation message to appear in stdout
    Wait Until Keyword Succeeds    10min    5s
    ...    Check Start Message    ${OUTPUT_DIR}/startTest_stdout.log

    Dated log              INF: Start_pcap_asim_abip - mirroring and tcpdump started

    # Save the handle for stop (optional, to verify it's still running)
    Set Suite Variable     ${PCAP_HANDLE}    ${handle}

Stop_pcap_asim_abip
    Dated log              INF: Stop_pcap_asim_abip - running... + sos report

    # Launch the stop script (blocking, waits for collection to complete)
    ${result}=    Run Process    /opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh
    ...           shell=True
    ...           stdout=${OUTPUT_DIR}/stopTest_stdout.log
    ...           stderr=${OUTPUT_DIR}/stopTest_stderr.log
    ...           timeout=1200s

    # Log warning if non-zero return code (but do NOT fail the test)
    Run Keyword If    ${result.rc} != 0
    ...    Dated log    WRN: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Run Keyword If    ${result.rc} != 0
    ...    Dated log    WRN: stopTest_ASIL.sh returned non-zero rc=${result.rc}
    Run Keyword If    ${result.rc} == -15
    ...    Dated log    WRN: This is a WARNING only - test continues normally timeout may have occurred Value set = ${timeout}
    Run Keyword If    ${result.rc} != 0
    ...    Dated log    WRN: This is a WARNING only - test continues normally
    Run Keyword If    ${result.rc} != 0
    ...    Dated log    WRN: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    Dated log              INF: Stop_pcap_asim_abip - completed rc=${result.rc}

    # Verify that the start process has terminated (cleanup)
    ${is_running}=    Is Process Running    ${PCAP_HANDLE}
    Run Keyword If    ${is_running}    Terminate Process    ${PCAP_HANDLE}

Check Start Message
    [Documentation]    Verifies that the confirmation message is present in the log
    [Arguments]    ${log_file}
    ${content}=    OperatingSystem.Get File    ${log_file}
    Should Contain    ${content}    Done. You can now start your tests in egate
    ...    msg=The startTest_ASIL.sh script did not display the confirmation message

    # Positive trace on the console (only executed if Should Contain passes)
    Dated log    INF: Confirmation message found - startTest_ASIL.sh is ready
update_timemarker_script
    [Arguments]            ${step_name}
    Run                    cat ${OUTPUT_DIR}/TimeMarker/${step_name}_to_portal.sh >> ${OUTPUT_DIR}/TimeMarker/perf_portal.sh
    Run                    rm ${OUTPUT_DIR}/TimeMarker/${step_name}_to_portal.sh

check_syslog
    [Arguments]            ${step_name}       ${test_type}    ${syslog}    ${max_syslog_rate}    ${nolimit}=True
    write_to_report        INF: check_syslog - running...
    # BHR begin 28/08/2024 : Comment following block has been replaced by create_pretty_load_maes_file
    # @{measurements}        extract_load_measurements          ${syslog.externalPath}
    # FOR                    ${measurement}    IN    @{measurements}
    #     write_to_report    ${measurement}
    # END
    # BHR end

    @{errors}              SYSLOG Evaluate    syslog=${syslog}
    ...                                       exclusion=CB008661.${test_type}.csv
    ...                                       maxRate=${max_syslog_rate}
    ...                                       nolimit=${nolimit}
    #Run                    gzip --force ${LOG_PATH}/syslog/${step_name}.log
    # BHR begin 16/08/2024: Previous line is commented, as a consequence:
    # git pipeline warning : 1350, 28: W0919 Keyword argument '${step_name}' is not used
    # Work around by adding a print of this argument to use it.
    write_to_report   Report info with step_name: ${step_name}
    # BHR end
    # write_to_report        Syslog errors: ${errors}
    # FOR    ${line}    IN    @{errors}
    #     write_to_report    ERR: check_syslog : ${line}
    # END
    should be empty        ${errors}
    write_to_report        check syslog for ${step_name} is PASS
    [return]               PASS

syslog_parsing
    [Arguments]            ${syslog}
    # DTN241203  adding a new KW to perform a second check on syslog to look for specific pattern
    write_to_report        INF: syslog_parsing - running...
    write_to_report        INF: syslog_parsing - syslog.externalPath: ${syslog.externalPath}
    ${STD_PATH}=           Evaluate    os.path.dirname('${syslog.externalPath}')    modules=os
    # write_to_report        INF: syslog_parsing - STD_PATH: ${STD_PATH}
    ${file_name}=          Evaluate    os.path.splitext(os.path.basename('${syslog.externalPath}'))[0]    modules=os
    ${current_date}=       Evaluate    datetime.datetime.now().strftime('%Y%m%d_%Hh%M')    modules=datetime
    ${new_file_name}=      Set Variable    ${file_name}.${current_date}.INCLUDE.log
    ${output_file}=        Set Variable    ${new_file_name}
    # ${output_file}=        Set Variable    ${STD_PATH}/parsingSyslog.log
    # write_to_report        INF: syslog_parsing - output_file: ${output_file}
    ${log_to_analyse}=     Set Variable    ${syslog.externalPath}
    ${pattern_exclude}=    Set Variable    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/syslog/exclusion/patternExclude.csv
    ${pattern_include}=    Set Variable    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/syslog/exclusion/patternInclude.csv
    ${output}=             Run Process    python    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/resources/python/parsingSyslog.py
    ...                                   --log    ${log_to_analyse}
    ...                                   --patternExclude    ${pattern_exclude}
    ...                                   --patternInclude    ${pattern_include}
    ...                                   --output    ${STD_PATH}/${output_file}
    ...                                   stdout=${STD_PATH}/stdout.txt       stderr=${STD_PATH}/stderr.txt
    ${output}=             OperatingSystem.Get File    ${STD_PATH}/${output_file}
    ${matched_lines}=      Evaluate    [line for line in '''${output}'''.splitlines() if line.strip()]    modules=ast
    write_to_report        INF: syslog_parsing - output_file: ${STD_PATH}/${output_file}
    # write_to_report        INF: syslog_parsing - matched_lines: ${matched_lines}
    FOR    ${line}    IN    @{matched_lines}
        write_to_report    ERR: syslog_parsing - signature matching an error pattern: ${line}
    END
    Should Be Empty        ${matched_lines}
    # write_to_report        syslog parsing for ${step_name} is PASS
    [return]               PASS

check_counter_and_kpi_constraints
    [Arguments]            ${pm_path}    ${step_name}    ${KPI_DICT_TO_USE}=${None}
    write_to_report        INF: check_counter_and_kpi_constraints - Checking ${step_name} counters and KPIs from file
    write_to_report        INF: check_counter_and_kpi_constraints - pm_path = ${pm_path}
    write_to_report        INF: check_counter_and_kpi_constraints - KPI_DICT_TO_USE = ${KPI_DICT_TO_USE}
    KPI Evaluate           pmFile=${pm_path}
    ...                    constraintsFile=${CURDIR}/../../config/counter/constraint/${step_name}.csv
    ...                    failOnError=${True}
    ...                    localKpiFile=${KPI_DICT_TO_USE}
    write_to_report        Counters and KPIs check for ${step_name} is PASS
    [return]               PASS

check_tti_events
    [Arguments]            ${step_name}
    write_to_report        Checking ${step_name} tti events
    write_to_report        INF: check_tti_events - running...
    ${errors}    ${measurements}    evaluate_tti_events    ${OUTPUT_DIR}/TtiEvents/${step_name}/${step_name}.json    ${fifo_debug}
    FOR                    ${measurement}    IN    @{measurements}
        write_to_report    ${measurement}
    END
    write_to_report        tti events errors: ${errors}
    should be empty        ${errors}
    write_to_report        tti events check for ${step_name} is PASS
    [return]               PASS

check_sherpa
    [Arguments]            ${step_name}
    write_to_report        Checking ${step_name} sherpa trace
    ${errors}    ${statistics}    evaluate_sherpa    /tmp/sherpa.pcap
    write_to_report        sherpa statistics: ${statistics}
    write_to_report        sherpa errors: ${errors}
    should be empty        ${errors}
    write_to_report        sherpa check for ${step_name} is PASS

#DTN241203 : adding a kw to compare the last two PM available under : BEG
compare_pm
    [Arguments]            ${step_name}    ${OUTPUT_DIR}    ${history}=last    ${metric}=kpi    ${deviation}=10    ${delta}=0.01
    write_to_report        INF: compare_pm - running...
    # write_to_report        INF: compare_pm - CURDIR = ${CURDIR}
    # write_to_report        INF: compare_pm - OUTPUT_DIR = ${OUTPUT_DIR}
    # write_to_report        INF: compare_pm - step_name = ${step_name}
    # write_to_report        INF: compare_pm - history = ${history}
    write_to_report        INF: compare_pm - metric = ${metric}
    ${path_parts}=         Split String    ${OUTPUT_DIR}    /
    ${feature_name}=       Get From List    ${path_parts}    -1
    ${feature_name}=       Strip String    ${feature_name}
    # write_to_report        INF: compare_pm - feature_name = ${feature_name}
    Remove From List       ${path_parts}    -1
    ${base_path}=          Catenate    SEPARATOR=/    @{path_parts}
    ${base_path}=          Strip String    ${base_path}
    write_to_report        INF: compare_pm - base_path = ${base_path}
    ${output}=             Run Process    python    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/resources/python/comparePM.py
    ...                                   --path    ${base_path}    --feature    ${feature_name}
    ...                                   --test    ${step_name}    --compare    ${history}    --deviation    ${deviation}    --delta    ${delta}
    ...                                   ${metric}
    ...                                   stdout=${base_path}/${feature_name}/Counter/${step_name}/comparePM_stdout.txt
    ...                                   stderr=${base_path}/${feature_name}/Counter/${step_name}/comparePM_stderr.txt
    ${signal_file_path}=    Set Variable    /${OUTPUT_DIR}/Counter/${step_name}/signal_file.txt
    ${file_path}=           OperatingSystem.Get File    ${signal_file_path}
    ${file_content}=        OperatingSystem.Get File    ${file_path.strip()}
    write_to_report         INF: compare_pm - comparison summary file_path: ${file_path}
    # write_to_report         ${file_content}

    ${line_count}=    Set Variable    0
    write_to_report    ::::::::: print compare_pm results
    FOR    ${line}    IN    @{file_content.splitlines()}
        IF              ${line_count} == 0
                            write_to_report    INF: compare_pm - header : ${line}
        ELSE
                            write_to_report    ERR: compare_pm - metric above max deviation : ${line}
        END
        # write_to_report        INF: compare_pm - metric above max deviation : ${line}
        ${line_count}=    Evaluate    ${line_count}+1
    END
    ${line_count_int}=    Convert To Integer    ${line_count}
    # write_to_report        DBG: compare_pm - Number of lines: ${line_count}
    Run Keyword If    ${line_count_int} > 1    write_to_report    ERR: compare_pm - deviation exists between two PM files
    Run Keyword If    ${line_count_int} > 1    Fail    "deviation exists between two PM files"
    write_to_report        INF: compare_pm - no deviation detected
# DTN241203 : END

history_pm
    [Arguments]            ${step_name}    ${OUTPUT_DIR}    ${metric}=kpi
    write_to_report        INF: history_pm - running...
    write_to_report        INF: history_pm - CURDIR = ${CURDIR}
    write_to_report        INF: history_pm - OUTPUT_DIR = ${OUTPUT_DIR}
    write_to_report        INF: history_pm - step_name = ${step_name}
    write_to_report        INF: history_pm - metric = ${metric}
    ${path_parts}=         Split String    ${OUTPUT_DIR}    /
    ${feature_name}=       Get From List    ${path_parts}    -1
    ${feature_name}=       Strip String    ${feature_name}
    write_to_report        INF: history_pm - feature_name = ${feature_name}
    Remove From List       ${path_parts}    -1
    ${base_path}=          Catenate    SEPARATOR=/    @{path_parts}
    ${base_path}=          Strip String    ${base_path}
    write_to_report        INF: history_pm - base_path = ${base_path}
    ${output}=             Run Process    python    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/resources/python/comparePM.py
    ...                                   --path    ${base_path}    --feature    ${feature_name}
    ...                                   --test    ${step_name}
    ...                                   ${metric}
    ...                                   stdout=${base_path}/${feature_name}/Counter/${step_name}/historyPM_stdout.txt
    ...                                   stderr=${base_path}/${feature_name}/Counter/${step_name}/historyPM_stderr.txt
# DTN241203 : END

Extract Board info
    write_to_report        :::::::::: GNB_BTS_INFO START SECTION ::::::::::
    write_to_report        :::::::::: ___GNB_BTS_INFO EXTRACT___ ::::::::::
    ${BOARD_INFO}          read_bts_info          ${GNB_BTS_INFO}
    write_to_report        ${BOARD_INFO}
    write_to_report        :::::::::: _GNB_BTS_INFO END SECTION_ ::::::::::

initialize_wts
    run keyword if         '${config_name}' != 'FR2_CA'    Setup Wtsemu SA
    run keyword if         '${config_name}' == 'FR2_CA'    CallSetup.WTS Setup    shouldUseLua=${False}
    ...                    bypassSIB=${True}    bypassX2Setup=${True}
    run keyword if         '${config_name}' == 'FR2_CA'    load_wts_lua_config

load_wts_lua_config
    write_to_report        Loading lua
    wtsemu.sim_cfg         file=${CURDIR}/../../script/1S_4CC_BF.lua
    write_to_report        Waiting ACTIVE state
    wtsemu.read_wtsemu_output_until    CHANGE STATE: ACTIVE - SimMode is ready now    300
    write_to_report        SIM READY

Check sCellAddition in AP log
    [Documentation]         Check sCellAddition messages on egate console.
    ...                     *Argument details:*
    ...                     - *nbUE*: number of IBCA UEs) to check for msg "sCellAddition" (default value = 1)
    [Arguments]         ${nbUE}=1       ${nbScellAct}=1     ${iSAct}=0
    Dated log               Wait for sCellAdditions
    Empty Buffer For Egate
    ${grepnbScellAct}       SSH Wait For Connect and Cmd
    ...     command=grep 'SCellIndex 1 activated successfully at airphone' ${tl.core.dir_path}/egate_console.log|wc -l
    ...     host=${HOST_EPCSIM}
    ${check}                evaluate         ${nbScellAct}*${nbUE}
    ${grepnbScellAct}       convert to integer      ${grepnbScellAct.strip()}
    ${grepnbScellAct}       evaluate        ${grepnbScellAct}-${iSAct}
    should be equal         ${grepnbScellAct}     ${check}

Set SCF Context DSS PRB
    ${SCF_MODIFIED}         OAM Change String in SCF          oldVal=MRBTS-1/NRBTS-1     newVal=MRBTS-1/NRBTS-2
    SCF StartSession                scf_file=${SCF_MODIFIED}

    ${dist_name}         Set Variable    MRBTS-1
    SCF Set element    dist_name=${dist_name}    element_name=btsName  element_value=${long_feature_name}_DSS_PRB

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2
    SCF Set element    dist_name=${dist_name}    element_name=actGeneralConnectivityGold  element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actLteNrDss   element_value=true
    #SCF Set element    dist_name=${dist_name}    element_name=sCellActivationMethod   element_value=blind

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-1
    #SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    #SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-2
    SCF Set element    dist_name=${dist_name}    element_name=actPRBBlanking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschAtSsbSlots   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschRmCsirsForTracking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=lteNrDssMode   element_value=DL_CRS_TDM_UL_FDM
    SCF Set element    dist_name=${dist_name}    element_name=msg1FrequencyStart   element_value=9
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeDL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeUL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pagingOffset   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pucchF3ModulationScheme   element_value=pi2bpsk
    SCF Set element    dist_name=${dist_name}    element_name=trsMutingInBlankedPRBsEnabled   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=type0SearchSpaceConfigurationIndex   element_value=15
    #SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    SCF Remove list    dist_name=${dist_name}    list_name=cellBwpList
    SCF Add list       dist_name=${dist_name}    list_name=cellBwpList

    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-162   cellBwpId=0
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}
    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-173   cellBwpId=1
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}

    SCF Set element in List    dist_name=${dist_name}    list_name=csirsForTracking     element_name=csirsTrackingPeriod   element_value=40ms

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-2/NRREL-0
    SCF Set element    dist_name=${dist_name}    element_name=gNbId   element_value=2

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-2
    SCF Set element    dist_name=${dist_name}    element_name=siWindowLength   element_value=s160
    SCF Set element    dist_name=${dist_name}    element_name=systemInformationTargetRate   element_value=0

    SCF Remove list    dist_name=${dist_name}    list_name=sibSchedulingList
    SCF Add list       dist_name=${dist_name}    list_name=sibSchedulingList

    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType2
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType3
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType4
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType5
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}

	${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRPMRNL-1
	SCF Set element    dist_name=${dist_name}    element_name=miNrEnDssPerCell   element_value=5min

    SCF StopSession      scf_file=${SCF_MODIFIED}
    Dated Log    ----> Modifications completed.\n

    OAM Perform Full Commissioning          scf_file=${SCF_MODIFIED}
    WA Airscale Wait For Ready                  ${GNB_DU}
    Dated Log    ----> Airscale Ready.\n

change_fr1_tmo
    write_to_report        change_fr1_tmo start
    ${reportingIntervalPm}         Set Variable       5min
    write_to_report        DBG:DTN250207 - reportingIntervalPm=${reportingIntervalPm}

    &{modify_paramtest}         Create Dictionary
    ...                                 parameter=reportingIntervalPm
    ...                                 dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
    ...                                 value=${reportingIntervalPm}
    &{modify_param0}            Create Dictionary
    ...                                 parameter=reportingIntervalPm
    ...                                 dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
    ...                                 value=${reportingIntervalPm}
    &{modify_param1}            Create Dictionary
    ...                                 parameter=miNrRRCC
    ...                                 dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...                                 value=${reportingIntervalPm}
    &{modify_param2}            Create Dictionary
    ...                                 parameter=miNrPdcch
    ...                                 dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...                                 value=${reportingIntervalPm}
    &{modify_param3}            Create Dictionary
    ...                                 parameter=miNrPowerSavingBwp
    ...                                 dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...                                 value=${reportingIntervalPm}
    @{modify_param}=            Create List                ${modify_paramtest}
    ...                                                    ${modify_param0}
    ...                                                    ${modify_param1}
    ...                                                    ${modify_param2}
    ...                                                    ${modify_param3}
    write_to_report        DBG:DTN250207 - modify_param=${modify_param}
    Oam.OAM Set Params                  ${modify_param}

#    set_oam_parameter           MRBTS-1/MNL-1/MNLENT-1/PMCADM-1    reportingIntervalPm    5min
#    set_oam_parameter           MRBTS-1/NRBTS-1/NRPMRNL-1    miNrRRCC    5min
#    set_oam_parameter           MRBTS-1/NRBTS-1/NRPMRNL-1    miNrPdcch    5min
#    set_oam_parameter           MRBTS-1/NRBTS-1/NRPMRNL-1    miNrPowerSavingBwp    5min
    write_to_report        change_fr1_tmo end

change_fr1_parameters
    write_to_report        change_fr1_parameters start
    # actPdschRmCsirsForTracking modification will be
    # removed once https://jiradc.ext.net.nokia.com/browse/ETS4UTE-8 is fixed
    # set_oam_parameter    MRBTS-1/NRBTS-1/NRCELL-1    actPdschRmCsirsForTracking    false
    # set_oam_parameter    MRBTS-1/NRBTS-1/NRCELL-3    actPdschRmCsirsForTracking    false
    # set_oam_parameter    MRBTS-1/NRBTS-1/NRCELL-5    actPdschRmCsirsForTracking    false
    # set_oam_parameter    MRBTS-1/NRBTS-1/NRCELL-6    actPdschRmCsirsForTracking    false
    write_to_report        change_fr1_parameters end

change_ibca_parameters
    write_to_report        change_ibca_parameters start
    ${branchName}          set variable    ${TLConfig.topo.getBranchName()}
    set_oam_parameter      MRBTS-1/NRBTS-1/NRCELL-5/NRREL-1    lcrId    6
    change_fr1_parameters
    write_to_report        change_ibca_parameters end

save_config_files
    [Arguments]            ${prefix}
# DTN 250430 - update gNB address to .129
#    Run                    scp 192.168.255.1:/ffs/run/swconfig.txt ${LOG_PATH}/${prefix}_gNB_swconfig.txt
    Run                    scp 192.168.255.129:/ffs/run/swconfig.txt ${LOG_PATH}/${prefix}_gNB_swconfig.txt
    Run                    scp 192.168.200.1:/ffs/run/swconfig.txt ${LOG_PATH}/${prefix}_AP_swconfig.txt
    Run                    scp 192.168.200.1:/ffs/run/simmode/iphy.xml ${LOG_PATH}/${prefix}_AP_iphy.xml

set_custom_config
    [Arguments]            ${config_name}
    write_to_report        set_custom_config start
    Apply Custom Config    scfc=${feature_dir}/config/scf/${config_name}.xml    iphy=${feature_dir}/config/iphy/${config_name}.xml
    write_to_report        set_custom_config end

Update VM config
    write_to_report        Update VM config start
    ${before}              Run    sudo sysctl net.sctp.rto_min
    write_to_report        Before: ${before}
    Run                    sudo sysctl -w net.sctp.rto_min=100
    ${after}               Run    sudo sysctl net.sctp.rto_min
    write_to_report        After: ${after}
    write_to_report        Update VM config end

Update gNB Swconfig
    # ${enable_fifo_enhancement}    Set Variable If    ${fifo_mode} == 0    0    1
    # ${tti_too_long_threshold}     Set Variable If    '${config_name}' == 'FR2_CA'    150    0xFFFFFFFF
    ${radCcs_AaSysLogInputLevel}                                          create dictionary    field=0x1003F     value=2
    # ${rdEnableFifoEnhancement}                                            create dictionary    field=0x58066D    value=${enable_fifo_enhancement}
    # ${rdMessageQueuesDebugLogByTtiTracesLevel}                            create dictionary    field=0x58066E    value=${fifo_mode}
    # ${rdDynamicTooLongTtiThreshold}                                       create dictionary    field=0x58016C    value=${tti_too_long_threshold}
    # ${rdEventTimeBudgetInUsForPrio1}                                      create dictionary    field=0x58065B    value=10010010
    # ${rdMaxOverloadQueueSizeForPrio3}                                     create dictionary    field=0x580661    value=40020020
    # ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio1}    create dictionary    field=0x580667    value=5004004
    # ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio2}    create dictionary    field=0x580668    value=10004004
    # ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio3}    create dictionary    field=0x580669    value=80004004
    # ${rdSlotMeasurementConfidenceFactor}                                  create dictionary    field=0x5806A4    value=0
    # ${rdFifoLogFrequencyForPrio1}                                         create dictionary    field=0x58068C    value=0
    # ${rdFifoLogFrequencyForPrio2}                                         create dictionary    field=0x58068D    value=0
    # ${rdFifoLogFrequencyForPrio3}                                         create dictionary    field=0x58068E    value=0
    ${swconfig_gnb}                 Create List    ${radCcs_AaSysLogInputLevel}
    # ...                                            ${rdEnableFifoEnhancement}
    # ...                                            ${rdMessageQueuesDebugLogByTtiTracesLevel}
    # ...                                            ${rdDynamicTooLongTtiThreshold}
    # ...                                            ${rdEventTimeBudgetInUsForPrio1}
    # ...                                            ${rdMaxOverloadQueueSizeForPrio3}
    # ...                                            ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio1}
    # ...                                            ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio2}
    # ...                                            ${rdMaxConsecutiveSlotsWithOldestDelayedEventNeverFlushedForPrio3}
    # ...                                            ${rdSlotMeasurementConfidenceFactor}
    # ...                                            ${rdFifoLogFrequencyForPrio1}
    # ...                                            ${rdFifoLogFrequencyForPrio2}
    # ...                                            ${rdFifoLogFrequencyForPrio3}
    Set Fields in swconfig DU       param_list=${swconfig_gnb}


#Capture L1L2
#    ${CaptureL1L2}                  Capture L1L2 Set Upon Config            airscale=${GNB_DU}
#    ${CaptureL1L2}                  Capture L1L2 Set Upon Config            airscale=${GNB_DU}
#    Capture Init                    ${CaptureL1L2}                          withTN=True
#    Capture Start         ${CaptureL1L2}
#    Sleep                 120s
#    Capture Stop          ${CaptureL1L2}


# --------------------------------------------------------------------------------------------------------------------
# BHR begin 01/10/2024 : WA to fix dcap collect issue. Aim of WA is to patch VM-UTE image

DCM ET UTF Lab Controller Start
    [Documentation]    Firstly,
    ...                   check if test env has latest UTF lab version,
    ...                   if not, upgrade UTF lab to latest version.
    ...                Then,
    ...                   UTF Lab Controller Start if not started,
    ...                   UTF Lab Controller restart if service has been started.
    ...                \n Author: huijun.rong@nokia-sbell.com
    [Timeout]    40 min
    DCM ET UTF Lab Upgrade
    Log To Console      UTF Lab Controller Start
    ${output}           OperatingSystem.Run     utf_lab-controller status
    ${utf_lab_inact}    Run Keyword And Return Status
    ...     Should Contain    ${output}    is not in running state   ignore_case=True
    ${result}           Run Keyword If      ${utf_lab_inact}
    ...     OperatingSystem.Run     utf_lab-controller start
    Run Keyword And Return If      ${utf_lab_inact}    Run Keywords
    ...   Should Contain   ${result}  Lab containers started successfully   ignore_case=True
    ...   AND   Log To Console   UTF Lab containers started successfully
    ${output}           OperatingSystem.Run    utf_lab-controller restart
    Should Contain      ${output}    containers restarted successfully   ignore_case=True
    Log To Console   UTF Lab containers re-started successfully

DCM ET UTF Lab Upgrade
    [Documentation]    check latest UTF Lab version, and upgrade current UTF to latest,
    ...                the upgrade will be skipped if latest version=current version
    ...                \n Author: huijun.rong@nokia-sbell.com
    [Timeout]    30 min
    Log To Console      UTF Lab Upgrade
    ${output}           OperatingSystem.Run   utf_lab-updates
    ${cur_ver}          Get Regexp Matches    ${output}
    ...    Currently installed version\\s+:\\s+([A-Z0-9]+\.[0-9]+)    1
    ${latest_ver}       Get Regexp Matches    ${output}
    ...    Latest released version\\s+:\\s+([A-Z0-9]+\.[0-9]+)        1
    ${cur_ver}          Set Variable         ${cur_ver[0]}
    ${latest_ver}       Set Variable         ${latest_ver[0]}
    Log To Console      cur_ver:${cur_ver}, latest_ver:${latest_ver}
    ${no_need_update}   Run Keyword And Return Status
    ...    Should Be Equal As Strings     ${cur_ver}    ${latest_ver}    ignore_case=True
    Run Keyword And Return If    ${no_need_update}
    ...    Log To Console    latest version is the same as current version, need not upgrade UTE Lab
    ${upgrade_sh}       Get Regexp Matches    ${output}
    ...    has been downloaded to:\\s+(/home/ute/Downloads/utf_lab_installer\.[A-Z0-9]+\.[0-9]+\.sh)   1
    ${upgrade_sh}       Set Variable          ${upgrade_sh[0]}
    Log To Console      ${upgrade_sh}
    ${cmd1}             Set Variable          sudo UTE_CLOUD=1 bash ${upgrade_sh} 127.0.0.1
    ${cmd2}             Set Variable          &> /home/ute/logs${/}update.log
    ${output}           OperatingSystem.Run   ${cmd1} ${cmd2}
    Should Contain      ${output}     SUCCESS: UTF Lab ${latest_ver} installed
    ...    ignore_case=True

# BHR end
# --------------------------------------------------------------------------------------------------------------------
