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
#  *** Variables ***
#  ${background_duration}                                                                                  3600
#  ${pm_interval_sec}                                                                                       900
#  ${pm_interval_min}                                                                                        15
#  ${start_pm_index_1}                                                                                        1
#  ${Nb_loop_before}                                                                                          2
#  ${background_sce}                                                                      bkg_14UEs_SFE_TMO_VoNR_HO_937.txt
#
#  ${SWENG_KPI_DICTIONARY}             ${CURDIR}/../../../resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv
#  ${KPI_DICTIONARY}             ${CURDIR}/config/counter/KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv
#  #  &{dico0}   name=Background_IC_01_bkg_14UEs_SFE_TMO_VoNR_HO_937
#  &{dico0}   name=Background_IC_01_bkg_14UEs_SFE_TMO_VoNR_HO_937
#  ...        start=2026-03-09 15:45:00
#  ...        stop=2026-03-09 16:45:00
#  ...        short_name=bkg_14UEs_SFE_TMO_VoNR_HO_937
#
#  &{SCOUT_RD_RECORDS}   0=&{dico0}
#
#  *** Test Cases ***
#  TranRob_TMO_LTD_Prelude
#      ${background_scenario_name}
#      ...               Fetch From Left                                        ${background_sce}      .
#                        Set Suite Variable                                     ${background_scenario_name}
#
#      Init Sequence     _
#      Step              Step_TL_Init    ${CURDIR}    TranRobTmo    tranrobtmo    FR1_TMO    activate_sherpa    no_tti    fifo_debug=0
#
#                        Enable Full Kpi Pm Collection
#
#  Scout Post Processing
#      Loop On Range Date Records To Post Process Scout Kpis Report
#
#  Accessibility_NR_5004b_5G-NSA-SgNB-addition-preparation-success-ratio
#     Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5013a_5G-Contention-based-RACH-setup-success-ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5020d_5G-NSA-Non-Stand-Alone-call-accessibility-5G-side
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5022e_5G-NSA-Active-RACH-setup-success-ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5151d_5G-SA-Accessibility-success-ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5152a_5G-Cell-availability-ratio-excluding-planned-unavailability-periods
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5167c_5G-SA-RRC-connection-establishment-success-ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5326a_5G-SA-5QI-1-QoS-Flows-Setup-Success-Ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Accessibility_NR_5345a_5G-SA-QoS-Flow-Setup-Success-Ratio
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5054b_5G-Initial-BLER-in-downlink-transmissions-in-PDSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5055c_5G-Residual-Block-Error-Ratio-(BLER)-for-PDSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5056d_5G-Initial-BLER-in-PUSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5057e_5G-Residual-BLER-in-PUSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5060b_5G-Average-wideband-CQI-64QAM-table
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5061b_5G-Average-wideband-CQI-256QAM-table
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5064a_5G-Average-UE-related-RSSI-for-PUSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5065a_5G-Average-UE-related-SINR-for-PUCCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5066a_5G-Average-UE-related-RSSI-for-PUCCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  Integrity_NR_5099a_5G-Average-UE-related-SINR-for-PUSCH
#      Loop On Range Date Records To Post Process Scout Kpi History
#
#  TranRob_TMO_LTD_Postlude
#      Disable Full Kpi Pm Collection
#      ${excel_file}     Merge Scout Histo NR Files    ${SCOUT_LOG_DIR}   NR_HISTO_SUMMARY.xlsx
#                        write_to_report    :::::::::: NR_HISTO_SUMMARY = ${excel_file} ::::::::::
#
#  Scout_Comparator_Report_Test
#      [Documentation]    Test Scout comparator report generation
#      ${background_scenario_name}
#      ...               Fetch From Left                                        ${background_sce}      .
#                        Set Suite Variable                                     ${background_scenario_name}
#
#      Init Sequence     _
#      Step              Step_TL_Init    ${CURDIR}    TranRobTmo    tranrobtmo    FR1_TMO    activate_sherpa    no_tti    fifo_debug=0
#
#                        Enable Full Kpi Pm Collection
#      Loop On Range Date Records To Post Process Scout Kpis Report
