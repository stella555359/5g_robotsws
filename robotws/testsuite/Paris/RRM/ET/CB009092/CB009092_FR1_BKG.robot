*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
...
...
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case automation contact: denis.taupin@nokia.com
...               Creation Date               : 10-December-2021
...               Modified Date               : 09-June-2025
...               Last Modified by            : denis.taupin@nokia.com

#BHR begin new
Library           BuiltIn
Library           Collections
Library           String
Library           ../CB008661/resources/python/startWTS.py
Library           taf.ul.alarms_watchdog  WITH NAME  alarms_watchdog
Library           ../CB008661/resources/python/TranRob_LongTestDuration_NoPerturbation_util.py
# Library           ../CB008661/resources/python/emss_alarm_handler.py    # DTN250225: REPLACED BY alarms_handler.py
Library           ../CB008661/resources/python/alarms_handler.py                 WITH NAME    alms_hdlr
Resource          ../CB008661/resources/robot/TranRob_LongTestDuration_NoPerturbation_Keywords.robot
#BHR end

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          ../CB008661/resources/robot/CB008661_Keywords.robot


Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_SWENG
...               CLOUD_5G_I_BOO_AP_LOO_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}

Variables         ../../../resources/SWENG/python/ReadConfig.py

*** Variables ***
${Nb_loop_before}              1
${Nb_loop_perturbation}        1
${Nb_loop_after}               1
${perturbation_sce}            Perturbation_5GC000937.sce
# ${background_sce}              Background_13UEs_TMO.txt
${background_sce}              bkg_13UEs_SFE_TMO.txt
# ${background_sce}              backgroundScenario_1UE_VoNR.txt
${background_duration}         3600
${pmInterval}                  15min
# ${PERIOD_DURATION}           15
${SWENG_KPI_DICTIONARY}        /home/ute/CrtRoot/robotws/testsuite/Paris/resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv
${KPI_DICTIONARY}    /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/counter/KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv



*** Test Cases ***
TranRob_FR2_Campaign_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    CB009092    cb9092    FR1_TMO    activate_sherpa    no_tti    fifo_debug=0
    # Step              Step_Configure_HO_And_Restart
    Step              Step_TL_Restart
    # BHR begin 13/12/2024 : new kws alarms
    # Step            Allowed alarms before precondition    # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.allowed_alarms_before_precondition
    # Step            Watch alarms                          # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.start_watchdog_alarms
    # Step            Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.check_detected_alarms
    #Step              Step_Cell_Setup
    write_to_report   :::::::::: startWTS ::::::::::
    Step              startWTS
    # BHR end

    write_to_report            INF: Nb_loop_before = ${Nb_loop_before}
    write_to_report            INF: Nb_loop_perturbation = ${Nb_loop_perturbation}
    write_to_report            INF: Nb_loop_after = ${Nb_loop_after}
    write_to_report            INF: pmInterval = ${pmInterval}
    ${pmIntervalMin}=          Split String  ${pmInterval}  min
    ${pmIntervalMin}=          Get From List  ${pmIntervalMin}  0
    ${pmIntervalSec}        Set Variable    ${60 * ${pmIntervalMin}}
    write_to_report            INF: pmIntervalSec = ${pmIntervalSec} seconds
    ${background_duration}     Set Variable    ${${pmIntervalSec} * (${Nb_loop_before} + ${Nb_loop_perturbation} + ${Nb_loop_after}) + 900}
    write_to_report            INF: background_duration = ${background_duration} seconds

    # Set Suite Variable     ${KPI_DICTIONARY}
    Step              Update_Kpi_Dict    ${KPI_DICTIONARY}    ${pmIntervalSec}
    Step              Start_Background_Scenario    ${background_duration}    ${background_sce}
    write_to_report   INF: wait 100 seconds for scenario to start
    Step              Sleep    100s
    # Step              Disallow alarms after precondition    # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.disallow_alarms_after_precondition
    # Step              Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.check_detected_alarms
    until_next_pm_start    15min    until_new_pm_only=yes
    # [Teardown]        GenericTest.Display diagnosis

Repeat_Background_Before_Perturbation
    ${background_scenario_name}=    Split String     ${background_sce}               .txt
    ${background_scenario_name}=    Get From List    ${background_scenario_name}     0
    ${step_name_suffix}=     Set Variable    ${background_scenario_name}
    FOR    ${i}    IN RANGE    ${Nb_loop_before}
        Run Keyword And Continue On Failure    TranRob_Background   wait   ${step_name_suffix}
    END

Background_with_Perturbation
    ${background_scenario_name}=       Split String     ${background_sce}                 .txt
    ${background_scenario_name}=       Get From List    ${background_scenario_name}       0
    ${perturbation_scenario_name}=     Split String     ${perturbation_sce}               .sce
    ${perturbation_scenario_name}=     Get From List    ${perturbation_scenario_name}     0
    ${step_name_suffix}=     Set Variable     ${background_scenario_name}_${perturbation_scenario_name}
    # Run Keyword         TranRob_Background    ${perturbation_sce}    ${step_name_suffix}
    FOR    ${i}    IN RANGE    ${Nb_loop_perturbation}
        Run Keyword And Continue On Failure    TranRob_Background   ${perturbation_sce}   ${step_name_suffix}
    END

Repeat_Background_After_Perturbation
    ${background_scenario_name}=    Split String     ${background_sce}               .txt
    ${background_scenario_name}=    Get From List    ${background_scenario_name}     0
    ${step_name_suffix}=     Set Variable    ${background_scenario_name}
    FOR    ${i}    IN RANGE    ${Nb_loop_after}
        Run Keyword And Continue On Failure    TranRob_Background    wait   ${step_name_suffix}
    END

TranRob_FR2_Campaign2_Postlude
    Step              Step_Postlude

*** Keywords ***
TranRob_Background
    [Arguments]     ${perturbation_sce}    ${step_name_suffix}
    Step            Step_Background
    ...             timeout=12hours   perturbation_sce=${perturbation_sce}   reportingIntervalPm=${pmInterval}   step_name_suffix=${step_name_suffix}
    ...             KPI_DICTIONARY=${KPI_DICTIONARY}
    Run Keyword if    '${Verdict_Background}' == 'FAILED'   FAIL   dependencies issue
