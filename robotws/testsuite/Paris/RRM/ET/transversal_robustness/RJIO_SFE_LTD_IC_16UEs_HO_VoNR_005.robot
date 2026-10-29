*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness for Long Test Duration
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness - Implicit Feature Regression
...
...
...               Test Case Scenario author   : gerard.bonhaure@nokia.com
...               Test Case automation contact: gerard.bonhaure@nokia.com
...               Creation Date               : 06-January-2026
...               Modified Date               :
...               Last Modified by            : denis.taupin@nokia.com      13-nov-2025
...               Last Modified by            : gerard.bonhaure@nokia.com   17-Mar-2026     25R3 --> 26R2   aligment

#               Topology/Variant : CLOUD_5G_O_E_AP_LOOO / SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2
#               Config TMO Cells/Ues mapping for bkg_SFE_RJIO_16UEs:
#                           ||-----------------------------------------||-----------------------------------------||
#                           ||                  SA                     ||                  NSA                    ||
#          |------|---------||-----------------------------------------||-----------------------------------------||
#          | cell | FDD/TDD || Num of Ues | Ue Ids range | Ue Ids used || Num of Ues | Ue Ids range | Ue Ids used ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    1 | TDD 78  ||     40     |     1-40     |     1-5, 7  ||            |              |             ||
#          |      |         ||            |              |      8-17   ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    2 | TDD 78  ||     10     |    41-80     |             ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    3 | TDD 78  ||     10     |    81-100    |      7      ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    4 | FDD 28  ||     10     |    41-50     |             ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    5 | FDD 28  ||     NA     |      NA      |             ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          |    6 | FDD 28  ||     10     |    51-60     |             ||            |              |             ||
#          |------|---------||------------|--------------|-------------||------------|--------------|-------------||
#          Note :
#             UEs 7                                                             are HO(cell1-cell3)   capables
#             UEs 9                                                             are VoNR              capables

Library           ./resources/python/startWTS.py
Library           ./resources/python/TranRob_LongTestDuration_NoPerturbation_util.py
Resource          ./resources/robot/TranRob_LongTestDuration_NoPerturbation_Keywords.robot

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          ../../../resources/SWENG/robot/Scout.robot
Resource          ./resources/robot/common_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_O_E_AP_LOOO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
...               CLOUD_5G_O_E_AP_LOOO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Variables ***
${background_duration}                                                                                  7200
${pm_interval_sec}                                                                                       900
${pm_interval_min}                                                                                        15
${start_pm_index_1}                                                                                        1
${Nb_loop_before}                                                                                          4

${background_sce}                                                             bkg_16UEs_SFE_RJIO_VoNR_HO.txt
${isX2LinkUp}                                                                                       ${False}
${FEATURE_ROOT_DIR}                                                                                ${CURDIR}

${SWENG_KPI_DICTIONARY}        ${CURDIR}/../../../resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv
${KPI_DICTIONARY}              ${CURDIR}/config/counter/KPI_Definitions_TOPKPI_25R3_withoutMissingCounter.csv
${IS_RJIO_ACCESSIBILITY}       ${True}

# BSR package
&{RJIO_AQQJ_6_H6_ALN45_ARP45_P00_Dic}
...                            BSR_file_name=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471_1.zip
...                            BSR_folder=BSR

# GNB DELTA COMMISSIONING
${RJIO_InactivityTimer_7200s}  ${CURDIR}/config/commissioning/RJIO_InactivityTimer_7200s.json
${RJIO_PMRNL_measId_15min}     ${CURDIR}/config/commissioning/RJIO_PMRNL_measId_15min.json
${RJIO_HO_Cell1-Cell3}     ${CURDIR}/config/commissioning/RJIO_HO_Cell1-Cell3.json


*** Test Cases ***
TranRob_RJIO_LTD_Prelude
    Do TranRob RJIO LTD Prelude    ${FEATURE_ROOT_DIR}   ${RJIO_InactivityTimer_7200s}   ${RJIO_PMRNL_measId_15min}   ${RJIO_HO_Cell1-Cell3}


Background_RJIO_IC_01
    ${step_name_suffix}      Set Variable    ${background_scenario_name}
    FOR    ${i}    IN RANGE    ${Nb_loop_before}
        write_to_report                                                      \n:::::::::: START LOOP = ${i} ::::::::::
        write_to_report                                                      :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
        write_to_report                                                      :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::
        Run Keyword And Continue On Failure    TranRob_Background   wait   ${step_name_suffix}   ${start_pm_index_1}   ${Nb_loop_before}
    END
    Update Scout Range Date Dictionary Records   ${step_name_suffix}


Scout Post Processing
    Sleep  1200
    Loop On Range Date Records To Post Process Scout Kpis Report

Accessibility_NR_5004b_5G-NSA-SgNB-addition-preparation-success-ratio_RIJO
   Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5013a_5G-Contention-based-RACH-setup-success-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5020d_5G-NSA-Non-Stand-Alone-call-accessibility-5G-side_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5022e_5G-NSA-Active-RACH-setup-success-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5151d_5G-SA-Accessibility-success-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5152a_5G-Cell-availability-ratio-excluding-planned-unavailability-periods_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5167c_5G-SA-RRC-connection-establishment-success-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5326a_5G-SA-5QI-1-QoS-Flows-Setup-Success-Ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_NR_5345a_5G-SA-QoS-Flow-Setup-Success-Ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_NR_5032e_5G-NSA-SgNB-triggered-abnormal-release-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_NR_5635a_5G-SA-5QI1-QoS-Flow-Drop-Ratio-User-view-doubleNg-mapped-to-UElost_RJIO
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_NR_5636a_5G-SA-QoS-Flow-Drop-Ratio-User-view-doubleNg-mapped-to-UElost_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5054b_5G-Initial-BLER-in-downlink-transmissions-in-PDSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5055c_5G-Residual-Block-Error-Ratio-(BLER)-for-PDSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5056d_5G-Initial-BLER-in-PUSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5057e_5G-Residual-BLER-in-PUSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5060b_5G-Average-wideband-CQI-64QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5061b_5G-Average-wideband-CQI-256QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5064a_5G-Average-UE-related-RSSI-for-PUSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5065a_5G-Average-UE-related-SINR-for-PUCCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5066a_5G-Average-UE-related-RSSI-for-PUCCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5099a_5G-Average-UE-related-SINR-for-PUSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5886a_5G-SA-Average-UL-Scheduling-delay-for-VoNR_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5887a_5G-DL-PDCP-SDU-end-user-throughput-per-DRB-for-QoS-group-5-to-20_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5888a_5G-UL-RLC-SDU-throughput-per-DRB-for-QoS-groups-5-to-20_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5906a_5G-Average-delay-DL-air-interface-for-AM-RLC-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5907a_5G-Average-delay-DL-in-CU-UP-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5908a_5G-Average-PDCP-re-ordering-delay-in-the-UL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5909a_5G-Average-DL-scheduling-delay-in-MAC-with-UE-in-DRX-with-active-time-of-DRX-Cycle-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5911a_5G-Average-Initial-Burst-scheduling-delay-in-DL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5912a_5G-Average-UL-Grant-delay-after-SR-reception-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_5913a_5G-Average-UL-MAC-contention-delay-after-BSR-reception-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_6095a_5G-Average-air-interface-UM-RLC-SDU-delay-in-DL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

# 25R3 --> 26R2 aligment : suppressed no longer supported from MIND
# Integrity_NR_6096a_5G-Average-gNB-DU-AM-RLC-SDU-delay-in-DL-per-cell_RIJO
#     Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_6098a_5G-Average-gNB-DU-burst-RLC-SDU-delay-in-DL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_6097a_5G-Average-gNB-DU-RLC-SDU-delay-in-DL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_6094a_5G-Average-air-interface-MAC-SDU-delay-in-UL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_NR_6099a_5G-Average-gNB-DU-RLC-SDU-delay-in-UL-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5067a_5G-Average-MCS-used-in-downlink-for-PDSCH-with-64QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5068a_5G-Average-MCS-used-in-downlink-for-PDSCH-with-256QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5069a_5G-Average-rank-used-in-downlink_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5076b_5G-Average-MCS-used-in-uplink-for-PUSCH-with-64QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5088d_5G-MAC-PDU -Cell-throughput-on-active-PDSCH-data-slots-on-initial-HARQ-transmissions_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5089e_5G-MAC-PDU-Cell-throughput-on-active-PUSCH-data-slots-on-initial-HARQ-transmissions_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5100c_5G-Average-MAC-layer-user-throughput-in-downlink_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5101b_5G-Average-MAC-layer-user-throughput-in-uplink_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5105a_5G-Average-MCS-used-in-uplink-for-PUSCH-with-256QAM-table_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5108e_5G-Spectral-efficiency-in-downlink_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5109g_5G-Spectral-efficiency-in-uplink_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5114b_5G-PRB-utilization-for-PDSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5115a_5G-PRB-utilization-for-PUSCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5149a_5G-Average-PDCCH-CCE-starvation-ratio-in-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5244e_5G-Scheduled-user-throughput-in-downlink-considering-PRB-utilization_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5245d_5G-Scheduled-user-throughput-in-uplink-considering-PRB-utilization_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5258a_5G-Maximum-MAC-SDU-Cell-Throughput-in-DL-on-DTCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5259a_5G-Maximum-MAC-SDU-Cell-Throughput-in-UL-on-DTCH_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5432b_5G-Average-aggregation-level-used-on-PDCCH-uplink-grants_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5433b_5G-Average-aggregation-level-used-on-PDCCH-downlink-grants_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5436a_5G-SA-Percentage-of-DL-inactivity-time-of-VoNR-calls_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5437a_5G-SA-Percentage-of-UL-inactivity-time-of-VoNR-calls_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5504a_5G-Average-value-of-scheduled-MIMO-layers-per-PRB-in-the-UL_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5513b_5G-Average-value-of-scheduled-MIMO-layers-per-PRB-in-the-DL_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageUtilization_NR_5889a_5G-SA-PUSCH-PRB-usage-ratio-for-5QI1_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5121a_5G-Average-number-of-active-UEs-with-data-in-the-buffer-for-DRBs-in-UL_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5124c_5G-NSA-Average-number-of-NSA-users-in-selected-area_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5125a_5G-NSA-Maximum-number-of-NSA-users-per-cell_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5128c_5G-SA-Average-number-of-SA-RRC-connected-users-in-selected-area_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5129a_5G-SA-Maximum-number-of-SA-RRC-connected-users_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

# 25R3 --> 26R2 aligment : new version NR_5333b
# UsageCapacity_NR_5333a_5G-SA-Average-number-of-active-VoNR-UEs-in-selected-area_RIJO
#     Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5415a_5G-Average-number-of-active-UEs-with-data-in-the-buffer-for-DRBs-in-DL-excluding-DRX_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5593a_5G-Average-number-of-MU-MIMO-eligible-UEs-per-DL-PRB_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

# 25R3 --> 26R2 aligment : new version NR_5333b
# UsageCapacity_NR_5634a_5G-Average-number-of-UEs-per-UL-PRB-MU-MIMO_RIJO
#     Loop On Range Date Records To Post Process Scout Kpi History

Mobility_NR_5177b_5G-SA-intra-frequency-intra-gNB-intra-DU-handover-total-success-ratio_RIJO
    Loop On Range Date Records To Post Process Scout Kpi History

# 25R3 --> 26R2 aligment : suppressed
# Usage_Energy_Efficiency_MRBTS_5600a_SBTS-Energy-consumption-in-system-modules_RIJO
#     Loop On Range Date Records To Post Process Scout Kpi History

# 25R3 --> 26R2 aligment : suppressed
# Usage_Energy_Efficiency_MRBTS_5602a_SBTS_Energy_consumption_in_BTS_RIJO
#     Loop On Range Date Records To Post Process Scout Kpi Histor


# New tests to be added for 5g top kpis 25R3 -> 26R2 aligment
# -----------------------------------------------------------

Integrity_NR_5482b_5G-DL-PDCP-SDU-discard-ratio-per-BTS
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5333b_5G-SA-Average-number-of-active-VoNR-UEs-in-selected-area
    Loop On Range Date Records To Post Process Scout Kpi History

UsageCapacity_NR_5634b_5G-Average-number-of-UEs-per-UL-PRB-MU-MIMO
    Loop On Range Date Records To Post Process Scout Kpi History

Others_SCOUT_NR_5597b_Else_5G-Average-UE-distance-in-RACH-setup-Else
    Loop On Range Date Records To Post Process Scout Kpi History

Others_SCOUT_NR_5598b_Else_5G-Average-UE-distance-during-RRC-connected-Else
    Loop On Range Date Records To Post Process Scout Kpi History

Others_SCOUT_NR_226_5G-Average-Timing-Advance-index-in-RACH-setup
    Loop On Range Date Records To Post Process Scout Kpi History

Others_SCOUT_NR_227b_5G-Average-Timing-Advance-index-during-RRC-connected-based-on-SCS
    Loop On Range Date Records To Post Process Scout Kpi History


# New tests to be added to parser legacy ctrs and kpis histoty
# ------------------------------------------------------------

Accessibility_Legacy_Tranrob_M55113C00001_Number-of-outgoing-UE-CONTEXT-MODIFICATION-REQUEST-sent-to-gNB-DU
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_Legacy_Tranrob_M55113C00002_Number-of-incoming-UE-CONTEXT-MODIFICATION-RESPONSE-received-from-gNB-DU
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_Legacy_Tranrob_M55113C00003_Number-of-incoming-UE-CONTEXT-MODIFICATION-FAILURE-received-from-gNB-DU
    Loop On Range Date Records To Post Process Scout Kpi History

Accessibility_Legacy_Tranrob_M55113C00004-Number-of-not-received-UE-CONTEXT-MODIFICATION-RESPONSE-from-gNB-DU-on-time
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_Legacy_Tranrob_M55125C08503_Number-of-FlowIDs-Released-for-SA-call
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_Legacy_Tranrob_M55125C01001_Number-of-UE-Context-Release-Request-sent
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_Legacy_Tranrob_M55125C09005_Number-of-QoS-flows-released-due-to-lost-connection-to-UE
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_Legacy_Tranrob_M55138C00004_The-number-of-non-GBR-DRB-radio-admission-releases-for-SA-user
    Loop On Range Date Records To Post Process Scout Kpi History

Retainability_Legacy_Tranrob_M55139C00012_The-number-of-non-GBR-DRB-radio-admission-releases-for-SA-user-in-DU
    Loop On Range Date Records To Post Process Scout Kpi History

Integrity_Legacy_Tranrob_SCOUT_NR_417a_NR-417a
    Loop On Range Date Records To Post Process Scout Kpi History

Usage-Capacity_Legacy_Tranrob_NR_5120a_5G-Average-number-of-active-UEs-with-data-in-the-buffer-for-DRBs-in-DL
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C00001_Maximum-number-of-UEs-with-active-Power-Saving-BWP
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C00002_Average-number-of-UEs-with-active-Power-Saving-BWP
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01003_Number-of-incoming-Cell-BWP-1-switches-by-DCI
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01004_Number-of-incoming-Cell-BWP-2-switches-by-DCI
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01007_Number-of-outgoing-Cell-BWP-1-switches-by-DCI
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01008_Number-of-outgoing-Cell-BWP-2-switches-by-DCI
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01011_Number-of-incoming-Cell-BWP-1-switches-without-UE-confirmation
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01012_Number-of-incoming-Cell-BWP-2-switches-without-UE-confirmation
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01015_Number-of-successful-UE-active-Cell-BWP-1-recoveries
    Loop On Range Date Records To Post Process Scout Kpi History

PS-BWP_M55351C01016_Number-of-successful-UE-active-Cell-BWP-2-recoveries
    Loop On Range Date Records To Post Process Scout Kpi History


TranRob_RJIO_LTD_Postlude
    Do TranRob LTD Postlude



