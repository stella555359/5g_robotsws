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
#  ...               Modified Date               : 13-nov-2025
#  ...               Last Modified by            : denis.taupin@nokia.com
#
#  #               Topology/Variant : CLOUD_5G_I_LOO_AP_LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#  #               Config TMO Cells/Ues mapping for bkg_SFE_TMO_13UEs:
#  #                           ||-----------------------------------------||-----------------------------------------||
#  #                           ||                  SA                     ||                  NSA                    ||
#  #          |------|---------||-----------------------------------------||-----------------------------------------||
#  #          | cell | FDD/TDD || Num of Ues | Ue Ids range | Ue Ids used || Num of Ues | Ue Ids range | Ue Ids used ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    1 |   TDD   ||     19     |     1-19     |   1-5, 7    ||     19     |   101-119    |   101-105,  ||
#  #          |      |         ||            |              |  9, 10, 15  ||            |              |   110, 115  ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    2 |   TDD   ||     10     |    21-30     |             ||     10     |   121-130    |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    3 |   TDD   ||     10     |    31-40     |             ||     10     |   131-140    |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    4 |   TDD   ||     10     |    41-50     |             ||     10     |   141-150    |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |  5-6 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    7 |   FDD   ||     10     |    51-60     |             ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    8 |   FDD   ||     10     |    71-80     |             ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |    9 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |   10 |   FDD   ||      0     |    81-90     |             ||     10     |   181-190    |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |   11 |   FDD   ||      0     |    91-100    |             ||     10     |   191-200    |             ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #          |   12 |   TDD   ||     NA     |      NA      |      NA     ||     NA     |       NA     |      NA     ||
#  #          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#  #
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
#  # Test Teardown     Scout Data Teardown  # replaced by OAM Get Snapshot, for FUSE
#  Test Teardown     OAM Get Snapshot
#
#  *** Variables ***
#  ${background_duration}                                                                                        900
#  ${pm_interval_sec}                                                                                            900
#  ${pm_interval_min}                                                                                             15
#  ${start_pm_index_1}                                                                                             1
#  ${Nb_loop_before}                                                                                               4
#  # ${background_sce}                                                                 bkg_16UEs_SFE_TMO_VoNR_HO.txt
#  ${background_sce}                                                                             bkg_2UEs_SA_NSA.txt
#  ${isX2LinkUp}                                                                                             ${True}
#  ${FEATURE_ROOT_DIR}                                                                                     ${CURDIR}
#  ${SWENG_KPI_DICTIONARY}        ${FEATURE_ROOT_DIR}/../../../resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv
#  ${KPI_DICTIONARY}        ${FEATURE_ROOT_DIR}/config/counter/KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv
#  ${DELTA_COMMISSIONING_JSON}                      ${FEATURE_ROOT_DIR}/config/commissioning/TMO_HO_VoNR_format.json
#
#
#  *** Test Cases ***
#  TranRob_TMO_LTD_Prelude
#      Do TranRob TMO LTD Prelude    ${FEATURE_ROOT_DIR}    ${DELTA_COMMISSIONING_JSON}
#
#  Background_IC_01
#      ${step_name_suffix}      Set Variable    ${background_scenario_name}
#      FOR    ${i}    IN RANGE    ${Nb_loop_before}
#          write_to_report                                                      \n:::::::::: START LOOP = ${i} ::::::::::
#          write_to_report                                                      :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
#          write_to_report                                                      :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::
#          Run Keyword And Continue On Failure    TranRob_Background   wait   ${step_name_suffix}   ${start_pm_index_1}   ${Nb_loop_before}
#      END
#     #  Update Scout Range Date Dictionary Records   ${step_name_suffix}
#     #  snapshot at the end of the step during Test Teardown, for FUSE
#
#  TranRob_TMO_LTD_Postlude
#      Do TranRob TMO LTD Postlude
