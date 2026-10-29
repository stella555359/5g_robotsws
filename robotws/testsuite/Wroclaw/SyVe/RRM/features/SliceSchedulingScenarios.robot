*** Settings ***
Documentation
...  Common resource with DL and UL  Slice aware scheduler (SAS) scenarios
...
...  author/contact: rafal.skrok@nokia.com


Library    testsuite.Wroclaw.SyVe.RRM.features.SliceSchedulingLib
Resource   testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

*** Keywords ***

Scenario_B02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_FDD_FDM_ON
    Given gNB is up and running in a SA mode in FDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the FDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then PM counters are checked to be NOT collected when tput was active
      And data tput is stopped and UEs are detached


Scenario_B04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_SA_TDD_FDM_ON
    Given gNB is up and running in a SA mode in TDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then PM counters are checked to be NOT collected when tput was active
    And data tput is stopped and UEs are detached


Scenario_B07_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_FDD
    Given gNB is up and running in a SA mode in FDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the FDD cell with various radio conditions with different DNNs
      And Data Tx of the nonGBR DRBs is started for the UEs
      And Data transfer is related to configured quotas before disabling the slice aware scheduler
    When Slice Aware Scheduler Is Disabled
    Then PM counters are not stored when feature disabled
    When Slice Aware Scheduler Is Enabled
    Then Data transfer is related to configured quotas after enabling the slice aware scheduler
    When One slice is removed from configuration
    Then Data transfer for the UE using removed slice is not scheduled
    When One slice is added to configuration
    Then Data transfer for the UE using added slice is scheduled
    When Slices quotas are reconfigured
    Then Data transfers for the UEs using changed quotas is scheduled
      And Data tput is stopped
      And Restore Original Scf Quotas


Scenario_B08_Dynamic_slice_aware_scheduler_with_slice_configuration_change_via_online_modification_TDD
    Given gNB is up and running in a SA mode in TDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
      And Data Tx of the nonGBR DRBs is started for the UEs
      And Data transfer is related to configured quotas before disabling the slice aware scheduler
    When Slice Aware Scheduler Is Disabled
    Then PM counters are not stored when feature disabled
    When Slice Aware Scheduler Is Enabled
    Then Data transfer is related to configured quotas after enabling the slice aware scheduler
    When One slice is removed from configuration
    Then Data transfer for the UE using removed slice is not scheduled
    When One slice is added to configuration
    Then Data transfer for the UE using added slice is scheduled
    When Slices quotas are reconfigured
    Then Data transfers for the UEs using changed quotas is scheduled
      And Data tput is stopped
      And Restore original scf quotas


Scenario_C01_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_FDD
    Given gNB is up and running in a NSA mode in FDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the FDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And NSA PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then NSA PM counters are checked to be NOT collected when tput was active
      And data tput is stopped and UEs are detached


Scenario_C02_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA_mode_only_TDD
    Given gNB is up and running in a NSA mode in TDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And NSA PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then NSA PM counters are checked to be NOT collected when tput was active
      And data tput is stopped and UEs are detached


Scenario_C03_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_FDD
    Given gNB is up and running in a SA NSA mode in FDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the FDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And PM counters are checked to be collected when tput was active
      And NSA PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then PM counters are checked to be NOT collected when tput was active
      And NSA PM counters are checked to be NOT collected when tput was active
      And data tput is stopped and UEs are detached


Scenario_C04_Dynamic_slice_aware_scheduler_with_no_interworkings_in_NSA+SA_mode_TDD
    Given gNB is up and running in a SA NSA mode in TDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Tx of the nonGBR DRBs is started for the UEs at different times
      And PM counters are checked to be collected when tput was active
      And NSA PM counters are checked to be collected when tput was active
      And data tput is stopped and UEs are detached
      And PM counters flags are disabled for counters collecting
      And Data Tx of the nonGBR DRBs is again started for the UEs at different times
    Then PM counters are checked to be NOT collected when tput was active
      And NSA PM counters are checked to be NOT collected when tput was active
      And data tput is stopped and UEs are detached


Scenario_C05_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_FDD
    Given gNB is up and running in a SA NSA mode in FDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the FDD cell with various radio conditions with different DNNs
      And Data Tx of the nonGBR DRBs is started for the UEs
      And Data transfer is related to configured quotas before disabling the slice aware scheduler
      And NSA PM counters are checked to be collected when tput was active
    When Slice Aware Scheduler Is Disabled
    Then PM counters are not stored when feature disabled
      And NSA PM counters are checked to be NOT collected when tput was active
    When Slice Aware Scheduler Is Enabled
    Then Data transfer is related to configured quotas after enabling the slice aware scheduler
      And NSA PM counters are checked to be collected when tput was active
    When Slices quotas are reconfigured
      And Nsa quotas are reconfigured
    Then Data transfers for the UEs using changed quotas is scheduled
       And NSA PM counters are checked to be collected when tput was active
       And Data tput is stopped
       And Restore original scf quotas
       And Restore original NSA scf quotas


Scenario_C06_Dynamic_slice_aware_scheduler_(NSA+SA)_with_slice_configuration_change_via_online_modification_TDD
    Given gNB is up and running in a SA NSA mode in TDD with configured multiple slices and their PM counters
      And Slice Aware Scheduler is Enabled
      And Slice Aware Scheduler is set to True
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
      And Data Tx of the nonGBR DRBs is started for the UEs
      And Data transfer is related to configured quotas before disabling the slice aware scheduler
      And NSA PM counters are checked to be collected when tput was active
    When Slice Aware Scheduler Is Disabled
    Then PM counters are not stored when feature disabled
      And NSA PM counters are checked to be NOT collected when tput was active
    When Slice Aware Scheduler Is Enabled
    Then Data transfer is related to configured quotas after enabling the slice aware scheduler
      And NSA PM counters are checked to be collected when tput was active
    When Slices quotas are reconfigured
      And Nsa quotas are reconfigured
    Then Data transfers for the UEs using changed quotas is scheduled
       And NSA PM counters are checked to be collected when tput was active
       And Data Tput Is Stopped
       And Restore Original Scf Quotas
       And Restore original NSA scf quotas

EDA02753244_EDA03030618_Dynamic_slice_aware_scheduler_with_low_trafic_DRBs
    Given gNB is up and running in a SA mode in FDD with configured for low traffic DRBs
      And Add scout external execution id to the reporting portal
      And Two UEs are attached to the FDD cell with various radio conditions with different DNNs
      And Low buffer Data Tx of the nonGBR DRBs is started for the UEs
      And PRB_USED_PDSCH_PLMN and other slices counters for two ones are verified
      And Relation between legacy counters and SAS counters is verified
      And data tput is stopped and the two UEs are detached

Scenario_CB008709-A#AUTO_SLICE_AWARE_UPLINK_SCHEDULER_FOR_THE_SPECIAL_CASE_OF_SINGLE_RG_PER_UE
    Given GNB is up and running in a SA NSA mode in TDD with uplink SAS enabled with proper quotas for NRRGs
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Rx of the nonGBR DRBs is started for the UEs at different times
    Then PM counters for uplink are checked to be collected when tput was active with achieved share per NRRG
      And Data tput is stopped and UEs are detached
    When Empty NR Resource Groups are removed and NRPMQAP objects for both PLMNs created
      And Multiple UEs are attached again to the TDD cell
      And Low buffer Data Rx of the nonGBR DRBs is started for one UE and full buffer Rx for the rest UEs
    Then PM Counters and target share per NRRG with low buffer UL are correct
      And NRPMQAP PM counters for PLMNs match the NRRGs counters for these PLMNs
      And Data tput is stopped and UEs are detached and low buffer traffic is as expected
    When Multiple UEs are attached again to the TDD cell
      And Data Rx of the nonGBR DRBs is started for the UEs at different times is again started with full buffer
    Then PM Counters and target share per NRRG with full buffer UL are correct
      And NRPMQAP PM counters for PLMNs match the NRRGs counters for these PLMNs
      And Data tput is stopped and UEs are detached
    When Gnb is up and running in SA NSA mode in FDD with UL and DL SAS enabled with different RG configuration
      And Two UEs are attached to the FDD cell with various radio conditions with different DNNs
      And Data Rx and TX of the nonGBR DRBs is started for the UEs at different times
      And Pm Counters and target share per NRRG with parallel traffic DL are correct
      And Pm Counters and target share per NRRG with parallel traffic UL are correct
      And Both directions data tput is stopped and UEs are detached

Scenario_CB008709-H-AUTO_SLICE_AWARE_UPLINK_SCHEDULER_INTERACTS_WITH_NBR
    Given GNB is up and running in a SA mode in TDD with uplink SAS and NBR activated
      And Add scout external execution id to the reporting portal
      And Multiple UEs are attached to the TDD cell with various radio conditions with different DNNs
    When Data Rx of the nonGBR DRBs is started for the UEs at different times
    Then PM counters for uplink are checked to be collected when tput was active with nbr activated
      And Data tput is stopped and UEs are detached
    When NBR Congestion control for PUSCH is activated for the cell
      And Multiple UEs are attached again to the TDD cell
      And Data Rx of the nonGBR DRBs is started for the UEs at different times
    Then PM counters for uplink are checked to be collected when tput was active with achieved share per NRRG
      And Data tput is stopped and UEs are detached
