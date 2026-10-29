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

#BHR begin new
Library           BuiltIn
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
...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD
...               CLOUD_5G_I_LO_AP_LO_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_SWENG
...               CLOUD_5G_I_BOO_AP_LOO_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}

Variables         ../../../resources/SWENG/python/ReadConfig.py

*** Variables ***
${Nb_loop_before}              63
${Nb_loop_after}               63


*** Test Cases ***
TranRob_FR2_Campaign_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    CB009092    cb9092    FR2_BKG    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    # BHR begin 13/12/2024 : new kws alarms
    # Step              Allowed alarms before precondition    # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.allowed_alarms_before_precondition
    # Step              Watch alarms                          # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.start_watchdog_alarms
    # Step              Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.check_detected_alarms
    #Step              Step_Cell_Setup
    write_to_report   :::::::::: startWTS ::::::::::
    Step              startWTS
    # BHR end
    Step              Start_Background_Scenario    40000    scenario_10UEs.sce   # for 126 loops
    write_to_report   wait 180 seconds for scenario start
    Step    Sleep    180s
    # Step              Disallow alarms after precondition    # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.disallow_alarms_after_precondition
    # Step              Check detected alarms                 # DTN250225: REPLACED BY alarms_handler.py
    Step              alms_hdlr.check_detected_alarms
    # [Teardown]        GenericTest.Display diagnosis


Repeat_Background_Monitoring_Before
    FOR    ${i}    IN RANGE    ${Nb_loop_before}
        Run Keyword And Continue On Failure    TranRob_Background_Monitoring
    END

TranRob_04_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0
    Step              Step_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0    timeout=12hours
    Run Keyword if    '${Verdict_DualConnEndur_1CC_10UE_FR2_DlHighTputBler0_UlMedTputBler0}' == 'FAILED'   FAIL   dependencies issue

Repeat_Background_Monitoring_After
    FOR    ${i}    IN RANGE    ${Nb_loop_after}
        Run Keyword And Continue On Failure    TranRob_Background_Monitoring
    END

TranRob_FR2_Campaign2_Postlude
    Step              Step_Postlude

*** Keywords ***
TranRob_Background_Monitoring
    Step              Step_Background_Monitoring    timeout=12hours
    Run Keyword if    '${Verdict_Background_Monitoring}' == 'FAILED'   FAIL   dependencies issue
