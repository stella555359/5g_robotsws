# ==============================================================
# ARCHIVED SUITE
# To reactivate: sed -i 's/^#  //' <filename>.robot
# ==============================================================
*** Settings ***
Documentation     [SUITE PURPOSE]  Fake documentation mandatory for merge

*** Test Cases ***
Fake Test Case
    [Tags]    robot:skip
    [Documentation]    Archived suite. To reactivate:
    ...                (1) remove the "#  " prefix from all lines,
    ...                (2) delete this entire "*** Test Cases ***" section (Fake Test Case).
    Fake Keyword

*** Keywords ***
Fake Keyword
    Log To Console    Fake keyword to be delete if you want to recover TC

#  *** Settings ***
#  Documentation     [SUITE PURPOSE]  Transversal Robustness for Long Test Duration
#  ...               Prerequisite : GNB and Airphone should be installed
#  ...               Scope : Transversal Robustness - Implicit Feature Regression
#  ...
#  ...
#  ...               Test Case Scenario author   : gerard.bonhaure@nokia.com
#  ...               Test Case automation contact: denis.taupin@nokia.com
#  ...               Creation Date               : 16-june-2025
#  ...               Modified Date               :
#  ...               Last Modified by            :
#
#  #               Topology/Variant : CLOUD_5G_I_LOO_AP_LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#  #               Config TMO Cells/Ues mapping for background call profile:
#  #                           ||-----------------------------------------||-----------------------------------------||
#  #                           ||                  SA                     ||                  NSA                    ||
#  #          |------|---------||-----------------------------------------||-----------------------------------------||
#  #          | cell | FDD/TDD || Num of Ues | Ue Ids range | Ue Ids used || Num of Ues | Ue Ids range | Ue Ids used ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    1 |   TDD   ||     38     |     1-9,     |   3, 4, 5   ||     49     |    51-99     |  51, 52, 53 ||
#  #          |      |         ||            |     12-40    | 12, 13, 14  ||            |              |             ||
#  #          |      |         ||            |              |   22, 23    ||            |              |             ||
#  #          |      |         ||            |              |   32, 33    ||            |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    2 |   TDD   ||      0     |              |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    3 |   TDD   ||      2     |    10-11     |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    4 |   TDD   ||      0     |              |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |  5-6 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |  7-8 |   FDD   ||      0     |              |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    9 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |10-11 |   FDD   ||      0     |              |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |   12 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #
#  #               Config TMO Cells/Ues mapping for PERTURBATION_01 : Sub-scenario CB000937 call profile:
#  #                           ||-----------------------------------------||-----------------------------------------||
#  #                           ||                  SA                     ||                  NSA                    ||
#  #          |------|---------||-----------------------------------------||-----------------------------------------||
#  #          | cell | FDD/TDD || Num of Ues | Ue Ids range | Ue Ids used || Num of Ues | Ue Ids range | Ue Ids used ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    1 |   TDD   ||     38     |     1-9,     |     1, 2    ||     49     |    51-99     |             ||
#  #          |      |         ||            |     12-40    |             ||            |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    2 |   TDD   ||      0     |              |             ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    3 |   TDD   ||      2     |    10-11     |   10, 11    ||      0     |              |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#
#
#  Library           ./resources/python/startWTS.py
#  Library           ./resources/python/TranRob_LongTestDuration_NoPerturbation_util.py
#  Resource          ./resources/robot/TranRob_LongTestDuration_NoPerturbation_Keywords.robot
#
#  Resource          ../../../resources/SWENG/robot/GenericTest.robot
#  Resource          ../../../resources/SWENG/robot/Setup.robot
#  Resource          ../../../resources/SWENG/robot/Scout.robot
#  Resource          ./resources/robot/common_Keywords.robot
#
#  Variables         ../../../resources/SWENG/python/ReadConfig.py
#
#  Force Tags        CA_5G_SW_FR-Villarceaux   RRM
#  ...               PY39
#  ...               master_classicalbts_all
#  ...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
#  ...               CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#  ...               CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
#  ...               CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
#  ...               CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD
#  ...               CLOUD_5G_I_LO_AP_LO_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_SWENG
#  ...               CLOUD_5G_I_BOO_AP_LOO_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC
#
#  Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
#  Suite Teardown    Setup.Suite Teardown       reset_ap=${True}
#
#
#  *** Variables ***
#  ${background_duration}                                                                                 12600
#  ${pm_interval_sec}                                                                                       900
#  ${pm_interval_min}                                                                                        15
#  ${start_pm_index_1}                                                                                        1
#  ${Nb_loop_before}                                                                                         12
#  ${background_sce}                                                                      bkg_13UEs_SFE_TMO.txt
#  ${SWENG_KPI_DICTIONARY}             ${CURDIR}/../../../resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv
#  ${KPI_DICTIONARY}             ${CURDIR}/config/counter/KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv
#
#
#  *** Test Cases ***
#  TranRob_TMO_LTD_Prelude
#      ${background_scenario_name}
#      ...               Fetch From Left                                        ${background_sce}      .
#                        Set Suite Variable                                     ${background_scenario_name}
#
#      Init Sequence     _
#      Step              Step_TL_Init    ${CURDIR}    TranRobTmo    tranrobtmo    FR1_TMO    activate_sherpa    no_tti    fifo_debug=0
#      Step              Step_TL_Restart
#                        write_to_report                                      INF: Step TL Restart Done
#                        Sleep                                                300s
#                        write_to_report                                      INF: Sleep 300s Done
#    # Step              Step_Configure_HO_And_Restart_TMO
#      Step              alms_hdlr.allowed_alarms_before_precondition
#      Step              alms_hdlr.start_watchdog_alarms
#      Step              alms_hdlr.check_detected_alarms
#      Log_Allowed_and_Detected_Alarms
#
#                        write_to_report                                        :::::::::: startWTS ::::::::::
#      Step              startWTS
#
#      Step              alms_hdlr.check_detected_alarms
#      Log_Allowed_and_Detected_Alarms
#
#                        write_to_report                                        INF: pmIntervalMin = ${pm_interval_min} minutes
#                        write_to_report                                        INF: pmIntervalSec = ${pm_interval_sec} seconds
#                        write_to_report                                        INF: backgroundDurationSec = ${background_duration} seconds
#      Step              Update_Kpi_Dict                                        ${KPI_DICTIONARY}            ${pm_interval_sec}
#
#      Step              Start Sce Background robot                             ${background_duration}       ${background_sce}
#                        write_to_report                                        INF: wait 100 seconds for scenario to start
#      Step              Sleep                                                  100s
#
#      Step              alms_hdlr.disallow_alarms_after_precondition
#      Step              alms_hdlr.check_detected_alarms
#      Log_Allowed_and_Detected_Alarms
#
#                        write_to_report                                        :::::::::: start PmcId Timer Service ::::::::::
#      Step              Start PmcId Timer Service Robot                        ${pm_interval_min}
#
#                        write_to_report                                        :::::::::: WAIT FOR BEGIN OF 1st PM PERIOD ::::::::::
#      Step              Wait For Pm Period Index                               expected_pm_period=1
#
#                        write_to_report                                        :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
#                        write_to_report                                        :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::
#
#
#  Background_IC_01
#      ${step_name_suffix}      Set Variable    ${background_scenario_name}
#      FOR    ${i}    IN RANGE    ${Nb_loop_before}
#          write_to_report                                                      \n:::::::::: START LOOP = ${i} ::::::::::
#          write_to_report                                                      :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
#          write_to_report                                                      :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::
#          Run Keyword And Continue On Failure    TranRob_Background   wait   ${step_name_suffix}   ${start_pm_index_1}   ${Nb_loop_before}
#      END
#      Update Scout Range Date Dictionary Records   ${step_name_suffix}
#
#
#  Scout Post Processing
#      Sleep  1200
#      FOR    ${key}    IN    @{SCOUT_RD_RECORDS.keys()}
#          ${record}=             Get From Dictionary    ${SCOUT_RD_RECORDS}    ${key}
#          ${step_name_suffix}    Get From Dictionary    ${record}    name
#          ${start_date}          Get From Dictionary    ${record}    start
#          ${stop_date}           Get From Dictionary    ${record}    stop
#
#          Step              Post Process Scout kpis Report                       ${step_name_suffix}   ${start_date}    ${stop_date}
#          Step              Update Scout Journal For The Latest Evaluation       ${step_name_suffix}   ${start_date}    ${stop_date}
#          Step              Compare Scout Last Report With Previous One
#      END
#
#  TranRob_TMO_LTD_Postlude
#      Step              Stop PmcId Timer Service Robot
#      Step              alms_hdlr.check_detected_alarms
#      Log_Allowed_and_Detected_Alarms
#      Step              alms_hdlr.stop_watchdog_alarms
#      Step              Stop Sce Background robot
#      Step              Step_Postlude
