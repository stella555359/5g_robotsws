# CNI-119369: Change Smart RF thermal management functionalities from public to internal
Robot test suite for CNI-119369.

## Developer notes
If manual thresholds change is needed follow the instruction below:
* Login to SM
* Enter the lxc container: lxc-attach -n <address>
* ssh to radio by rfsw login
* perform command: sudo dapd -duc tcs_parameters
  * this command creating tcs_parameters.json file where RU settings are stored
* Edit /var/tmp/tcs_parameters.json : T_sym_blank_off, T_sym_blank_on, T_sym_blank_timer
* Save file
* Perform command: sudo dapd -ciuc tcs_parameters.json
  * this command prevents of rollback tcs_parameters.json file to default values after reboot
* reboot RU from command line

## Test line requirements
This section is taken from automation requests done by Anna Konior - TC QC reference:
* real gNB (in case of SA configuration)
* real eNB (in case of NSA configuration)
* real Core
* ASIB/ASIM, ASOE
* ABIO/ABIN
* AVQL or AVQE
* UE supports band n78

### Example configuration
* ASIL+ABIO+AVQL

### Required initial BTS state (not to be checked but provided directly from SCF)

* At least one TDD cell configured on AVQL/AVQE (any cell bandwidth supported by radio module).
* gNB is up and running without any faults and/or warning messages.

## Test cases

### RRM_CB005788-SR-A_Counters_verification

Purpose of this test case is to verify counters introduced in CB005788 (internal feature) and moved to R&D Counters in CNI-119369.

* Owner: anna.konior@nokia.com
* Author: szymon.startek@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions

Subframe configuration for tested TDD cell:
* MRBTS/NRBTS/NRCELL/tddFrameStructure:
* frameStructureType set to: semiStatic
* guardPeriodLength set to: 2Symbols
* tdLteUlDlConfig set to: tdLteConfig2
* ulDlDataSlotRatio set to: 3/7

#### Test scenario defined by owner

* Step 1: Check BTS status.
* Step 2: Attach UE and start data traffic (non GBR) in the cell trigger overheating of the radio module to start slot blanking (all slot blanking phase: OFF, 17%, 35%, 50%).
* Step 3: Check counters related to CNI-119369:
NR_CELL_RF_COOL_MODE0_SAMPLES, NR_CELL_RF_COOL_MODE0_CHNG_TO, NR_CELL_RF_COOL_MODE2_SAMPLES, NR_CELL_RF_COOL_MODE2_CHNG_TO.

#### Pass Criteria

* Step 1: RU is detected and cell is on air.
* Step 2: Slot blanking is performed according to the specification
* Step 3: Following counters are incremented according to the specification:
  * NR_CELL_RF_COOL_MODE0_SAMPLES -> This counter is incremented by 1 approximately every second when the cell is in RF cooling mode0 (tgtMutingRatio = OFF).
  * NR_CELL_RF_COOL_MODE0_CHNG_TO -> This counter is incremented by 1 when the RF cooling state of the NR cell changes to "OFF."
  * NR_CELL_RF_COOL_MODE2_SAMPLES -> This counter is incremented by 1 approximately every second when the cell is in RF cooling mode2 (tgtMutingRatio = 35).
  * NR_CELL_RF_COOL_MODE2_CHNG_TO -> This counter is incremented by 1 when the RF cooling state of the NR cell changes to "35%."

#### Automatic TC steps
* Preconditions
    * Setup Temperature Thresholds At RMOD By JSON File
    * Wait Until BTS Is OnAir
    * UE Is Ready For Test
* Step 1: Check If RMOD Is Ready For Test And To Start DL Call
* Step 2: Wait Until tgtMutingRatio Reach 35%
* Step 3: Collect And Check Counters

#### History of changes
* 12.09.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1342 - Initial creation 
* 10.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1379 - Changed count of counter periods from 1 to 2
* 07.04.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1451 - Changed RMOD login user from rfsw to serviceuser
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version
  and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1568 - modified import path due to moving CB008224_keywords.py
  to resources
* 28.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1584 - 'Print Thresholds After RU Reboot' keyword enhancement
* 02.12.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1660 - 'Print Thresholds After RU Reboot And Validating Threshold Values' keyword enhancement
* 09.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1788 - 'Print Thresholds After RU Reboot And Validating Threshold Values'
  keyword changing download file directory
* 17.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1799 - 'Setup Temperature Thresholds at RMOD' keyword changing dapd command
