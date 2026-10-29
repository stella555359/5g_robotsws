*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: fabrice.delecroix@nokia.com, denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites

Library         ../python/TranRobKrk_Alarm_util.py


*** Variables ***
${Verdict_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check}                                      FAILED
${Verdict_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check}                                      FAILED
${Verdict_Alarms_Check_during_Oam_Modifications}                                                 FAILED

*** Keywords ***
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

    # Stop Traffic DL and Detach SA and NSA Ues on each 4 cells
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
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450    check_accessibility=${False}
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

    # Stop Traffic UL and Detach SA and NSA Ues on each 4 cells
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
    run_checks             ${step_name}    Krakow_CRT    ${pm_path}    ${syslog}    max_syslog_rate=450    check_accessibility=${False}
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


    # Change cells parameter with gNB reset
    # --> Check detected alarms
    # --------------------------------------
    change cells parameter with gNB reset

    # Change gNB parameter with gNB reset
    # --> Check detected alarms
    # --------------------------------------
    change gNB parameter with gNB reset

    Set Suite Variable     ${Verdict_Alarms_Check_during_oamModifications}    PASS

Change gNB parameter without Gnb reset
    Check detected alarms
    ta_emss.Configure    {'MOC': 'NRBTS', 'ID': '1', 'actFullPlmnList': 'true', 'actETWS': 'true', "actPCMDReport": 'true'}
    Check detected alarms
    ta_emss.Configure    {'MOC': 'NRBTS', 'ID': '1', 'actFullPlmnList': 'false', 'actETWS': 'false', "actPCMDReport": 'false'}
    Check detected alarms
