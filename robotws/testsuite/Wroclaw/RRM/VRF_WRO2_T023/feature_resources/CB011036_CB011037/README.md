# CB011036/CB011037: Coordinated 4G-5G power saving part 3
Robot test suite for feature CB011036/CB011037.

## Test strategy and priorities
The features CB011036 and CB011037 make possible to switch off the LTE and NR DSS cells in LTE-NR DSS configuration. 
When the features CB011036 and CB011037 are activated together then significant power saving is possible also for 
the DSS layer: If both LTE and NR load is low both the LTE and NR cells sharing the carrier can be switched off 
and furthermore the power amplifiers (PA) of the radio unit serving the DSS cell can be switched off if no other cells 
(RF carriers) are transmitted by the same PA.
The LTE DSS cell shall not be candidate cell for switching-off in a PSGRP if NR DSS side is not in energySaving state 
or "not up and running".

## Testing scope
* CB011036-A: Cell switches on/off SA/NSA cell.  
  Feature flag online modification.
* CB011036-B: Interaction with other functionalities.  
  MIMO muting.
* CB011037-A: Establish XP interface between eNB and gNB.  
  Exchange cell state information between eNB and gNB.  
  No faults are triggered when coordinated NR DSS cell is in energy saving state.  
  LTE DSS cell switch off when PSGRP load is lower according to legacy LTE1103 algorithm and coordinated NR DSS cell 
  is in energy saving state.
  LTE DSS cell switch on when PSGRP load is higher according to legacy LTE1103 algorithm or NR indication.  
* CB011037-B: Interaction with MIMO muting feature.

### Example configuration
gNB: ASIL, ABIO, AHEGC, 
eNB: ASIA, ABIO, AHEGC,
1 UE (Nokia 8.3) compatible with the bands b1 LTE and DSS.

#### Cells config
* LTE DSS cell(eNB)[Band n1][FDD]: AHEGC
* LTE non-DSS cell(eNB)[Band n3][FDD]: AHEGC
* NR DSS cell(gNB)[Band n1][FDD]: AHEGC
* NR non-DSS cell(gNB)[Band n1][FDD]: AHEGC

### Required initial BTS state (not to be checked but provided directly from SCF)
* eNB: object PSGRP is configured. LTE non-DSS cell is the first (lbpsCellSOOrder=1) and LTE DSS cell is the last cell 
  of a PSGRP (lbpsCellSOOrder=100). Additionally set lbpsSOMethod= TX switch off.
* gNB: object NRPGRP is configured. NR non-DSS cell is the first cell of a NRPGRP. 
  NR DSS cell is added as the last cell (lbpsCellSOOrder=100) to the NRPGRP during test.

## Test cases

### CB011037_LTE_DSS_cell_TX_paths_switching_off_on_when_LTE1103_and_LTE1203_are_activated
The purpose of this test is to check the operation of energy saving on LTE DSS cell when LTE1103 and LTE1203 
are activated. The eNodeB determines the DSS Cell TX Paths Switch Off List for the Power Saving Group Cells. DSS cell 
is the last cell of a PSGRP, it follows LTE1103 and LTE1203 power saving mode to switch off/on cell TX paths when PSGRP 
load is lower than lbpsLastCellRTXMinLoad or higher than lbpsLastCellRTXMaxLoad.

* Owner: dawid.1.kurowski@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions
* CB011036 is activated - NRBTS.actCoordEnDssPowerSaving is equal to true 
* CB011037 is activated - LNBTS.actCoordEnDssPowerSaving is equal to true 
* LTE1203 and SR003080 are activated - LNBTS.actLBRTXPowerSaving = true and actOnlineTXSwitch = true 
* DSS Cell Power Saving Configuration-1 in "Configure Load-Based Power Saving Controls for DSS cell" 
  use case is downloaded and activated successfully. 
* The Operator configured the power saving threshold parameter values of LTE1203 which the eNodeB 
  uses to detect Load-Based Power Saving eligibility within a Power Saving Group. PSGRP::lbpsRTXMaxLoad, lbpsRTXMinLoad, 
  lbpsLastCellRTXMinLoad, lbpsPdcchLoadOffset, lbpsRTXCellCapOffset. 
* Follow the precondition in OM_LTE_SFS_RNL.29255 Determine Cell TX Path Switch Off List
* DSS cell is set as last cell in PSG. 

#### Test scenario defined by owner
* Step 1:
  Description: BTS is onAir after activation plan from precondition. Data traffic is performed.
  Coordinated NR DSS cell is in Not Energy Saving state.  
  Expected: No unexpected faults after activation plan from 'precondition' chapter.
* Step 2:
  Description: Reduce traffic load in the PSGRP with DSS cell in LTE side, until the non DSS cell is added into 
  The Cell Switch Off List in OM_LTE_SFS_RNL.29254 Determine Cell Switch Off List.   
  Expected: Non LTE DSS cell is switched off. Non DSS LTE cell status: LNCEL/energySaving. 
  LTE eNB notifies gNB of LTE DSS cell disabled/energySaving state via XP interface.
* Step 3:
  Description: Continue to reduce traffic load in the PSGRP with DSS cell in LTE side, until it is below 
  lbpsLastCellRTXMinLoad like it in OM_LTE_SFS_RNL.29255 Determine Cell TX Path Switch Off List.  
  Expected: The DSS cell TX paths is switched off and goes to enabled/reducedEnergySaving state.
  eNB shall inform NMS and BTS EM about the changed DSS cell state.
* Step 4:
  Description: Increase traffic load of last DSS cell in the PSGRP until it is above lbpsLastCellRTXMaxLoad.  
  Expected: LTE cell TX is switched ON. LTE DSS cell status in webEM: LNCEL/notEnergySaving. 
  eNB shall inform NMS and BTS EM about the changed DSS cell state.

#### Pass Criteria
* LTE DSS cell TX paths is switched off for power saving, it can still provide service.
* LTE DSS cell TX paths is switched on.

#### Automatic TC steps
* Preconditions
* Step 1: Start DL Data Transfer
* Step 2: Reduce Traffic Load To Switch Off Non DSS Cell
* Step 3: Continue To Reduce Traffic Load To Switch Off DSS Cell
* Step 4: Check If TX Paths Are Switched Off
* Step 5: Increase Traffic Load To Switch On DSS Cell

#### Test case developer notes
* Please make sure that power saving groups are set on the BTSes (gNB: NRPGRP, eNB: PSGRP).
* UDP tput is checked. This is required by the feature. 
* When half of TX paths are switched off, then the throughput will be equal to half of the max tput. 
  In step 4 we perform max tput to check whether TX paths are switched off.
* After starting data transfer, test waits 3 min. for the cell energy saving status to change. 
  It is important in regard to cell switch off/on timer.

#### History of changes
* 28.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1318 - initial creation
* 23.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1479 - change tput to lower the pgLoad below threshold
* 02.07.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1506 - changing upper coefficient cause th-put is better


### CB011036_CB011037_DSS_cells_switch_off_due_to_energy_saving_interaction_with_CB007777
The purpose of this test is to check Power Saving phase 3 interaction with CB007777. The gNB and eNB determines the DSS 
Cell Switch Off List for the Power Saving Group Cells.

* Owner: dawid.1.kurowski@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions
* AHEGC used as RU for testing (supported by CB007777 feature). 
* The precondition is same as USCB011036-A#B0, EN DSS is running as expected.  
* Operator configures power saving related parameters and activates CB011036 as USCB011036-A#B1. 
* Feature CB011037 is deactivated in eNB (LNBTS.actCoordEnDssPowerSaving = 1). 
* Feature CB011036 is deactivated in eNB (NRBTS.actCoordEnDssPowerSaving = 1). 
* Feature CB008951 is activated in gNB (NRBTS.actCoordinated4g5gPowerSaving =1). 
* Feature CB009920 is activated in eNB (LNBTS.actCoordinated4g5gPowerSaving =1). 
* EN CP-RT link is created between gNB and eNB. 
* DSS Cell Power Saving Configuration-2 in "UC: Configure Load-Based Power Saving Controls for DSS cell" 
  use case is downloaded and activated successfully. 
* DSS Cell Power Saving Configuration-2 in "UC: Configure Load-Based Power Saving Controls for DSS cell" use case 
  is downloaded and activated successfully. [CB011037-B start] ALTERNATIVE: SWITCH_OFF_DSS-CELL_IN_CB008800/ALTERNATIVE: 
  SWITCH_OFF_DSS-CELL_IN_CB008745 [CB011037-B /end]. 
* Follow the precondition in [Before CB011037-UPD001] OM_LTE_SFS_RNL.29254 [CB011037-UPD001] OM_LTE_SFS_RNL.29555 
  [End CB011037-UPD001] Determine Cell Switch Off List. 
* MNL.MNLENT.featcadm.actPowerMeter = true 
* MNL.MNLENT.PMMNL.mtBtsEnergyMonitoring = 15min 
* MNL.MNLENT.PMMNL.mtSBTSRfmEnergyMonitoring = 15min 
* MNL.MNLENT.PMMNL.mtSBTSSmEnergyMonitoring = 15min 

#### Test scenario defined by owner
* Step 1:  
  Description: Set actCoordEnDssPowerSaving = true on both gNB and eNB.  
  Expected: Feature successfully activated. Cells that are in Power Saving groups enter energy saving state. Cells enter
  energy saving state in correct order as configured. No unexpected alarms. When lbpsLastCellSOEnabled = true, cell(s) 
  with lbpsCellSOOrder = 100 enter power saving state. Expected call flow (as in CB011037-620; CB011036-594 [CFAM]).
* Step 2:  
  Description: Collect and analyze counters related to CB007777.  
  M55601C00502  
  M55601C00501  
  M40004C5  
  M40004C4  
  M40004C3  
  M40004C2  
  M40004C1  
  M40004C0  
  M40003C5  
  M40003C4  
  M40003C3  
  M40003C2  
  M40003C1  
  M40003C0  
  M40002C2  
  M40002C1  
  M40002C0  
  Expected: Counter (energy consumption) values when cells are in energy saving state should be lower than on air state.
* Step 3:  
  Description: Increase traffic load to wake up DSS cells.  
  Expected: DSS cells are switched ON. Cells status in webEM: NotEnergySaving.

#### Pass Criteria
Counter (energy consumption) values when cells are in energy saving state should be lower than on air state. 
The NR DSS cell is in energySaving state.   
    * NRCELL.operationalState='disabled'   
    * NRCELL.energySavingState='energySaving'   
The NR DSS cell status is informed to eNB.

#### Automatic TC steps
* Preconditions
* Step 1: Collect Counters In Not Energy Saving State 
* Step 2: Feature Activation
* Step 3: Collect Counters In Energy Saving State
* Step 4: Analyze Counters Related To CB007777
* Step 5: Start Traffic Load To Switch On DSS Cells

#### Test case developer notes
* Please make sure that power saving groups are set on the BTSes (gNB: NRPGRP, eNB: PSGRP).
* UDP tput is checked. This is required by the feature.
* The test waits 4 min. before checking the cell energy saving status. It is important in regard to cell switch off/on 
  timer. The 'lbpsMonWinForCellSOff' parameter determines the time after which the cells in a given power group will go 
  to sleep. In this case it is 60 s. The cells switch off one by one, in the order set in the power group. Four cells 
  are tested, so the waiting time for all cells to switch to energy saving mode is approximately 4 minutes. 
* Counters on the RUs and SM should be smaller or equal when power saving is turned on. However, we assume a possibility
  of 5% uncertainty.
* It is important to remember that counters should be collected every 15 minutes.  
  'mtBtsEnergyMonitoring'=15min  
  'mtSBTSSmEnergyMonitor'=15min  
  'mtSBTSRfmEnergyMonito'=15min

#### History of changes
* 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1323 - initial creation
