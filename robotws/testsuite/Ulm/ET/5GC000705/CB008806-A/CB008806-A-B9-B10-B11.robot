*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Test Suite for CB008806-A_5GC000705-A#B9/B10/B11


Resource          CB008806-A-B9-B10-B11_Keywords.robot

Suite Setup       Prepare TL
Suite Teardown    Sqd65 Common Teardown

Test Setup        Perform Precondition of Test Scenario
Test Teardown     Perform Postconditions of Test Scenario



*** Test Cases ***


[1]CB008806_A_B9_SCell_A1_measurement_triggered_UL_overload_preventive_inter-frequency_HO_to_configured_SCell_for_SA
   [Documentation]  UE (for which FDD-TDD carrier aggregation is being configured) is configured with A1 measurement on SCell,
   ...              which will trigger UL overload preventive inter-frequency handover with the configured SCell as the target cell.
   ...              Intra-gNB handover is allowed for configured SCell
   [Tags]   B9.1  B9  CRT
   Register UE on FDD-PCell
   Enable PCell change to TDD-SCell
   Verify A1 Measurement is configured for CA
   TDD-SCell addition
   Verify A1 Measurement is configured on TDD-SCell
   FDD-PCell change to TDD-SCell

[2]CB008806_A_B9_SCell_A1_measurement_triggered_UL_overload_preventive_inter-frequency_HO_to_configured_SCell_for_SA
   [Documentation]  UE (for which FDD-TDD carrier aggregation is being configured) is configured with A1 measurement on SCell,
   ...              which will trigger UL overload preventive inter-frequency handover with the configured SCell as the target cell.
   ...              if NRREL.handoverAllowedSA for the configured SCell is set to ‘forbidden’ or ‘onlyNG’,
   ...              then A1 measurement on SCell for UL overload preventive inter-frequency HO to configured SCell will not be configured.
   [Tags]  B9.2  B9  CRT
   Register UE on FDD-PCell
   Disable PCell change to TDD-SCell
   Verify A1 Measurement is configured for CA
   TDD-SCell addition
   Verify A1 Measurement is NOT configured on TDD-SCell

[1]CB008806_A_B10_SCell_A1_measurement_triggered_UL_overload_preventive_inter-frequency_HO_to_configured_SCell_for_SA
   [Documentation]  UE (for which FDD-FDD carrier aggregation is being configured) is configured with A1 measurement on SCell,
   ...              which will trigger UL overload preventive inter-frequency handover with the configured SCell as the target cell.
   ...              Intra-gNB handover is allowed for configured SCell.
   [Tags]   B10.1  B10
   Apply Config for B10
   Register UE on FDD-PCell                                       ue_nr_capabilities=${UE_CAPA_FDD_FDD}
   Verify A1 Measurement is configured for CA
   FDD-SCell addition
   Verify A1 Measurement is configured on FDD-SCell
   FDD-PCell change to FDD-SCell

[2]CB008806_A_B10_SCell_A1_measurement_triggered_UL_overload_preventive_inter-frequency_HO_to_configured_SCell_for_SA
   [Documentation]  UE (for which FDD-FDD carrier aggregation is being configured) is configured with A1 measurement on SCell,
   ...              which will trigger UL overload preventive inter-frequency handover with the configured SCell as the target cell.
   ...              if NRREL.handoverAllowedSA for the configured SCell is set to ‘forbidden’ or ‘onlyNG’,
   ...              then A1 measurement on SCell for UL overload preventive inter-frequency HO to configured SCell will not be configured.
   [Tags]  B10.2  B10
   Register UE on FDD-PCell                                       ue_nr_capabilities=${UE_CAPA_FDD_FDD}
   Verify A1 Measurement is configured for CA
   Disable PCell change to FDD-SCell                              pcell=${FDD_PCELL.lcrId}
   FDD-SCell addition
   Verify A1 Measurement is NOT configured on FDD-SCell

[1]CB008806_A_B11_PCell_A2_measurement_triggered_PCell_change_for_SA
   [Documentation]  UE (for which FR1 TDD - FDD carrier aggregation is being configured) is configured with A2 measurement on PCell,
   ...              which will trigger PCell change inter-frequency handover with the configured SCell as the target cell.
   ...              Intra-gNB handover is allowed for at least one configured SCell
   [Tags]   B11.1  B11   CRT
   Register UE on TDD-PCell
   Verify A1 Measurement is configured for CA
   FDD-SCell addition to TDD-PCell
   Verify A2 Measurement is configured on TDD-PCell
   TDD-PCell change to FDD-SCell

[2]CB008806_A_B11_PCell_A2_measurement_triggered_PCell_change_for_SA
   [Documentation]  UE (for which FR1 TDD - FDD carrier aggregation is being configured) is configured with A2 measurement on PCell,
   ...              which will trigger PCell change inter-frequency handover with the configured SCell as the target cell.
   ...              if NRREL.handoverAllowedSA for the configured SCell is set to ‘forbidden’ or ‘onlyNG’,
   ...              then A2 measurement on PCell for PCell change will not be configured.
   [Tags]  B11.2  B11  CRT
   Register UE on TDD-PCell
   Verify A1 Measurement is configured for CA
   Disable PCell change to FDD-SCell                              pcell=${TDD_PCELL.lcrId}
   FDD-SCell addition to TDD-PCell
   Verify A2 Measurement is NOT configured on TDD-PCell
