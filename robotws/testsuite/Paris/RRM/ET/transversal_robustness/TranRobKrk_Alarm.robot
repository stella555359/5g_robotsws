*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness CRT test from Krakow
...
...               Test Case author   : imported from Krakow team
...               Test Case contact  : gerard.bonhaure@nokia.com
...               Creation Date      : 02-April-2024
...               Modified Date      : 02-April-2024
...               Last Modified by   : gerard.bonhaure@nokia.com
...
...               UE SA TDD cell 1: 1, SA TDD cell 2: 21
...               UE SA FDD cell 3: 51, SA FDD cell 4: 71
...               UE NSA TDD cell 1: 101, NSA TDD cell 2: 121
...               UE NSA FDD cell 3: 151, NSA FDD cell 4: 171


Resource          ./resources/robot/TranRob_LongTestDuration_NoPerturbation_Keywords.robot
Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          ./resources/robot/common_Keywords.robot
Resource          ./resources/robot/TranRobKrk_Alarm_Keywords.robot
Variables         ../../../resources/SWENG/python/ReadConfig.py


Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               CIT    SBTS00    CONFIGURED    RAN_5G    RAN_5G_FDD    5G_RAN
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Test Cases ***
[0]TranRob_FR1_Campaign1_Prelude
    Init Sequence     _
    Step              Step_TL_Init    ${CURDIR}    TranRobKrk    tranrobkrk    FR1_4CELLS    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
    Step              alms_hdlr.allowed_alarms_before_precondition
    Step              alms_hdlr.start_watchdog_alarms
    Step              alms_hdlr.check_detected_alarms
    Step              Step_Cell_Setup
    Step              alms_hdlr.Disallow_alarms_after_precondition
    Step              alms_hdlr.check_detected_alarms


[1][1.0] TranRob_01_Alarms_Check_During_1CC_2UEx4CELL_FR1_DlHighTputBler0
     Step              Step_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check      timeout=12hours
     Run Keyword if    '${Verdict_Traffic_1CC_8UE_FR1_DlHighTputBler0_Alarms_Check}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_02_Alarms_Check_During_1CC_2UEx4CELL_FR1_UlHighTputBler0
    Step              Step_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check     timeout=12hours
    Run Keyword if    '${Verdict_Traffic_1CC_8UE_FR1_UlHighTputBler0_Alarms_Check}' == 'FAILED'    FAIL    dependencies issue

[1][1.0] TranRob_03_Alarms_Check_During_Oam_Online_Offline_Modification
    Step              Step_Alarms_Check_during_Oam_Modifications      timeout=12hours
    Run Keyword if    '${Verdict_Alarms_Check_during_Oam_Modifications}' == 'FAILED'    FAIL    dependencies issue

[0]TranRob_FR1_Campaign1_Postlude
    Step               alms_hdlr.check_detected_alarms
    ${alm_summary}     get_alarms_check_failed_summary      ${ListStep}
                       write_to_report    ${alm_summary}
    Step               alms_hdlr.stop_watchdog_alarms
    Step               Step_Postlude
