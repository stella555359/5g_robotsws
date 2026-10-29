*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
...
...
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case automation contact: denis.taupin@nokia.com
...               Creation Date               : 10-December-2021
...               Modified Date               : 23-December-2024
...               Last Modified by            : denis.taupin@nokia.com

Library           BuiltIn
Library           taf.ul.alarms_watchdog  WITH NAME  alarms_watchdog
Library           ../CB008661/resources/python/TranRob_LongTestDuration_NoPerturbation_util.py
Library           ../CB008661/resources/python/emss_alarm_handler.py
Resource          ../CB008661/resources/robot/TranRob_LongTestDuration_NoPerturbation_Keywords.robot
Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          ../CB008661/resources/robot/CB008661_Keywords.robot
Variables         ../../../resources/SWENG/python/ReadConfig.py
Library           ../CB008661/resources/python/startWTS.py
# Ney for syslog
Resource          ../../../resources/SWENG/robot/Btslog.robot
Library           ../CB008661/resources/python/btslogfile.py


Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_SWENG
...               CLOUD_5G_I_BOO_AP_LOO_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Variables ***
${background_sce_duration}     3600
${granularity}                    5


*** Test Cases ***
TranRob_FR2_Campaign_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    CB009092    cb9092    FR2_BKG    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    Step              Allowed alarms before precondition
    Step              Watch alarms
    Step              Check detected alarms
    Step              startWTS
    Step              Disallow alarms after precondition
    Step              Check detected alarms
    Step              Start Sce Background robot    ${background_sce_duration}    scenario_10UEs.sce

    write_to_report   :::::::::: Waiting for pm period where background traffic sce is steady ::::::::::
    Sleep             300s
    Step              write_btslog_to_file   /home/ute/btslog2/btslog.ini
    Step              Start Btslog
    Step              Start Pmc Monitoring robot    Background_Monitoring    ${granularity}
    Step              Start Btslog Monitoring robot

Perturbation tasks
    Wait For Pm Period Index     expected_pm_period=3
    write_to_report   :::::::::: DO START PERTURBATION SCENARIO 01 ::::::::::

    Wait For Pm Period Index     expected_pm_period=6
    write_to_report   :::::::::: DO START PERTURBATION SCENARIO 02 ::::::::::

    Wait For Pm Period Index     expected_pm_period=9
    write_to_report   :::::::::: DO START PERTURBATION SCENARIO 03 ::::::::::

    Wait For Pm Period Index     expected_pm_period=12
    write_to_report   :::::::::: END OF PERTURBATION STEPS ::::::::::

Stop Background Tasks
    Step    Stop Pmc Monitoring robot
    Step    Stop Btslog                      /tmp/btslog2
    Step    Stop Btslog Monitoring robot
    Step    Stop watching alarms
    Step    Stop Sce Background robot

TranRob_FR2_Campaign2_Postlude
    Step    Step_Postlude
