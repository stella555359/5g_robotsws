# CB008392: Load based MIMO muting for Energy Efficiency
Robot test suite for feature CB008392.

## Test line requirements
This section is taken from automation requests done by Santiago Galindo.

### Example configuration
ASIL, ABIO, 2xAHEGC (or 2 similar FDD CPRI radios 4x4), 2 UEs compatible with the bands n1 and n3.

#### 5G cell config
AHEGC1:
* Cell1(gNB)[4x4][Band n1]: NR (DSS).
* Cell2(gNB)[4x4][Band n1]: NR (non-DSS).
* Cell3(gNB)[4x4][Band n3]: NR (non-DSS).

#### LTE cell config
AHEGC2:
* Cell4(eNB)[4x4][Band 3]: LTE Anchor DSS (ENDC)
* Cell5(eNB)[4x4][Band 1]: LTE (DSS).

All cells with the same channel BW= 15 MHz. It is recommended for all cells in the NRPGRP
to have the same channel BW to have the same proportion of PRB resources for each cell.

### Required initial BTS state (not to be checked but provided directly from SCF)
* The eNB and the gNB (SA) are operational without critical alarms or errors (DSS properly configured).
* Cell5 and Cell1 set up as the DSS pair.
* UEs configured with ONLY ONE preferred band in SA and NONE in NSA to ease testing with 2 UEs,
  each one in one cell at the same time (i.e. UE1 attached to Cell2 and UE2 attached to Cell3).
* If the third position of the average[] vector (PDCCH) from the syslogs is greater than or equal
  to lbpsPdcchLoadOffset, AND it is the vector's maximum value, then the reference value to
  determine the load relative to lbpsRTXMinLoad or lbpsRTXMaxLoad is:
  * lpsRTXMinLoad- lbpsPdcchLoadOffset
  * lpsRTXMaxLoad- lbpsPdcchLoadOffset
* The DL load (pgLoad) is measured per NRPGRP and calculated based on the number of PRBs available,
  later, it's normalized to a percentage scale. So, to have a straightforward and reliable way
  to modify the DL load in a NRPGRP and induce changes in the energySavingState status of each cell,
  it's recommended to consider the following throughput when performing a DL call:
  * DL tput < lbpsRTXMinLoad: 15 Mbps.
  * lbpsRTXMinLoad < DL tput < lbpsRTXMaxLoad: 80 Mbps.
  * DL tput > lbpsRTXMaxLoad: >220 Mbps (or the maximum possible DL tput).

#### 5G
* Feature CB008392 activated (actNrLBRTXPowerSaving = True).
* In the gNB, create 1 power group (NRBTS-/NRPGRP-1) with 1 cell (Cell2) and set up the following parameters:
  * NRPGRP/lbpsCellList/nrCellId= *existing nrCellId
  * NRPGRP/lbpsPeriodList/lbpsDayOfWeek= *all weekdays should be added one by one
  * NRPGRP/lbpsPeriodList/lbpsDuration= *1440 recommended
  * NRPGRP/lbpsPeriodList/lbpsStartTimeHour= 0
  * NRPGRP/lbpsPeriodList/lbpsStartTimeMinute= 0
  * NRPGRP/lbpsLastCellSOEnabled= true
  * NRPGRP/lbpsSOMethod= TX switch off
  * NRPGRP/lbpsPeriodList/lbpsRTXSOffTime= *50 recommended
  * NRPGRP/lbpsPeriodList/lbpsRTXSOnTime= *50 recommended
  * NRPGRP/lbpsRTXMinLoad= lbpsLastCellRTXMinLoad (*10 recommended).
  * NRPGRP/lbpsRTXMaxLoad= *40 recommended. - currently set to 80
  * NRPGRP/lbpsPdcchLoadOffset= *2 recommended. - currently set to 22
  * NRPMRNL/miNrCellAvailability= 5min. - currently set to 15 min
  * Leave the other default parameters as they are.
* Create a second power group (NRBTS-/NRPGRP-2) with 1 cell (Cell3) and set up its parameters
  as in the previous power group.
* Configure the following EIRP parameters per cell to later verify the power consumption of each cell:
  * actEirpControl= true
  * antennaMechanicalDowntilt= 0
  * eirpControl= Include one list with the default values.
  * eirpControlPowerReductionFactorList = include one list with 0 dB.
  * externalAntennaGain= 0
* Configure the individual power monitoring parameters:
  * PMMNL/mtBtsEnergyMonitoring= 15min
  * PMMNL/mtSBTSRfmEnergyMonitoring= 15min
  * PMMNL/mtSBTSSmEnergyMonitoring= 15min
* It is recommended to set NRPGRP.lbpsRTXMaxLoad to a value strictly higher than 2*NRPGRP.lbpsRTXMinLoad
  (lbpsRTXMaxLoad > 2*lbpsRTXMinLoad) to avoid a scenario in which a cell has its TX paths
  switched off due to the power group load being at or below NRPGRP.lbpsRTXMinLoad and within
  a few minutes is switched on due to the power group load increasing above NRPGRP.lbpsRTXMaxLoad.

## Test cases

### CB008392_A_4TX_Switch_Off_TX_Paths_Verification
The purpose of this test is to check if lbpsSOMethod='TX switch off' works
correctly when maximum performance is not nneded and instead energy efficiency
is expected.
The gNB monitors the current capacity needed by a Power Group (NRPGRP)
and whether its cells may have half of their TX Paths switched off to achieve
energy efficiency. The gNB uses the current power group DL Load (pgLoad)
determination and the configured Load-Based Reduced TX Paths Power Saving
control parameters determine what action to take. This test case is invoked
for each Power Group that exists at the gNB which selected Switch Off method
(lbpsSOMethod) is 'TX switch off'.
IF pgLoad<lbpsRTXMinLoad<lbpsRTXMaxLoad during lbpsRTXSOffTime,
THEN: half of the cell's TX paths should be switched-off.

* Owner: santiago.galindo@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test scenario defined by owner
* Step 1: Do not set any DL tput and make sure that no cell in the NRPGRPs has DL Load.
  Wait the number of seconds established in lbpsRTXSOffTime.
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad ...
  Timer lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter ...
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 2: Set DL tput in NRPGRP-1 to get: pgLoad < lbpsRTXMinLoad (DL call in Cell2).
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH].
* Step 3: Set DL tput in NRPGRP-1 to get: lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad (DL call in Cell2).
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH]
* Step 4: While there's still DL tput in NRPGRP-1, disable the feature CB008392 by switching
  actNrLBRTXPowerSaving = False. Validate and activate the plan.
* Step 5: Set DL tput in NRPGRP-1 to get: pgLoad < lbpsRTXMinLoad (DL call in Cell2).
  Wait the number of seconds stablished in lbpsRTXSOnTime.
* Step 6: Set DL tput in NRPGRP-1 and NRPGRP-2 to get: pgLoad < lbpsRTXMinLoad.
  Wait the number of seconds stablished in lbpsRTXSOffTime.
* Step 7: While there's still DL tput in NRPGRP-1 and NRPGRP-2, enable the feature CB008392
  by switching actNrLBRTXPowerSaving = True. Validate and activate the plan.
* Step 8: Wait the number of seconds stablished in lbpsRTXSOffTime.
* Step 9: Delete the NRPGRP-2 and include the Cell3 in the NRPGRP-1:
  Cell2 lbpsCellSOOrder= 1
  Cell3 lbpsCellSOOrder= 2
  Validate and activate the plan.
  Wait the twice number of seconds stablished in lbpsRTXSOffTime.
* Step 10: Stop DL tput in the all the NRPGRP-1 cells and wait the number of seconds established in lbpsRTXSOffTime.

#### Pass Criteria
* Step 1: Cell2 and Cell3 should transition to energySavingState = switchingOffRTX and a few seconds later
  to energySavingState = reducedEnergySaving. Half of the TX paths of each cell within the NRPGRP-1
  should be offline.
* Step 2: Each cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should remain offline.
* Step 3: Each cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should remain offline.
* Step 4: All the gNB cells (in NRPGRP-1 as well as in NRPGRP-2) should switch to the state
  energySavingState = notEnergySaving and all cells should have all their TX paths online.
  The ongoing call should be persistent. No new alarms or errors should be raised.
* Step 5: Each cell in the gNB (in NRPGRP-1 as well as in NRPGRP-2) should remain
  as energySavingState = notEnergySaving. All the TX paths of each cell should remain online.
* Step 6: Each cell in the gNB (in NRPGRP-1 as well as in NRPGRP-2) should remain
  as energySavingState = notEnergySaving. All the TX paths of each cell should remain online.
* Step 7: No new relation errors, definition errors, nor alarms should appear. Activation should be successful.
* Step 8: Each cell state in NRPGRP-1 and NEPGRP-2 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 and NRPGRP-2 should be offline.
* Step 9: No new relation errors, definition errors, nor alarms should appear. Activation should be successful.
  Each cell state in NRPGRP-1 should be in energySavingState = reducedEnergySaving.
* Step 10: Each cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should remain offline

#### Automatic TC steps
* Preconditions
* Step 1: Check Measurements In Syslog
* Step 2: Start DL Data Transfer In Power Group 1
* Step 3: Start Additional DL Data Transfer In Power Group 1
* Step 4: Turn Off Energy Saving
* Step 5: Stop Additional DL Data Transfer In Power Group 1
* Step 6: Start Additional DL Data Transfer In Power Group 2
* Step 7: Turn On Energy Saving
* Step 8: Delete NRPGRP-2
* Step 9: Stop All Data Transfers

#### Test case developer notes
* This Test sets Suite Variables: ENERGY_SAVING_ON (boolean value determining
  if CB008392 is turned on by checking if actNrLBRTXPowerSaving=true)
  and CB008392_ACTIVATION_CHECKED (boolean value determining if it was verified
  whether CB008392 is active)
* For correct load values it is important to set correct lbpsPdcchLoadOffset
  at the time of writing this test case it was set to 22
* Wait timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since real
  waiting time was longer. This was discussed with the owner of this test case.
* At the end of this test case modifications made in SCF: deactivation of feature,
  removal of one power group and moving cell to a different power group are reverted.
  If for some reason test case was stopped without completing teardown, please make sure
  that SCF is correct.
* Additional files saved during this test:
  * ${LOG_PATH}/misc_logs/SCF_gNB.xml - SCF from gNB saved at the beginning of the test
  * ${LOG_PATH}/misc_logs/feature_check_SCF_gNB.xml - SCF from gNB used for checking
    if feature is active.
  * ${LOG_PATH}/misc_logs/original_SCF.xml - original SCF for gNB before deleting
    power group
  * ${LOG_PATH}/misc_logs/modified_SCF.xml - SCF from gNB created by calculating delta
    for deleting power group and moving cell from it to a different one
  * ${LOG_PATH}/misc_logs/SCF_removed_gr2.xml - SCF from gNB downloaded after recommissioning
    where power group is deleted and cell is moved from old power group to a different one
  * ${LOG_PATH}/misc_logs/delta_remove_gr2.json - delta for gNB for deleting power group and moving
    cell from it to a different one
  * ${LOG_PATH}/misc_logs/delta_revert.json - delta for gNB for reverting deletion of power group
    and moving cell from it to a different one
  * syslogDebug1.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingAlgorithm.*
  * syslogDebug2.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingService.*
* This test expects only one cell in power group 1 and one in power group 2 - it checks only energy
  saving state for those two cells.
* Keyword 'Debug Syslog Prints' in teardown collects syslog prints for regular expressions:
  'EnergySavingAlgorithm.*' and 'EnergySavingService.*' which may be useful during debugging.
* This test case assumes that lbpsRTXMaxLoad and lbpsRTXMinLoad are the same for power group 1 and 2.

#### History of changes
* 25.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-941 - initial creation
* 09.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1261 - Update KW for creating SCF modification list
* 30.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1281 - Remove unused KW from test setup
* 25.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1317 - change maintainer of the TC
* 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1476 - packet_size set for low tput because default value on new iperf servers is too high
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.

### CB008392_A_4TX_Switch_On_TX_Paths_Verification
The purpose of this test is to check if lbpsSOMethod='TX switch off' works
correctly when maximum performance is needed.
The gNB monitors the current capacity need of a Power Group (NRPGRP)
and whether its cells may need all their TX Paths switched on to achieve
maximum performance and leave a reduced energy saving state. The gNB uses
the current power group DL Load determination (pgLoad) and the configured
Load-Based Reduced TX Paths Power Saving control parameters determine
what action to take. This test case is invoked for each Power Group that exists
at the gNB and of which selected Switch On method (lbpsSOMethod) is 'TX switch off'.
IF pgLoad>lbpsRTXMaxLoad>lbpsRTXMinLoad during lbpsRTXSOnTime,
THEN: all the cell's TX paths should be switched-on.

* Owner: santiago.galindo@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1: Do not set any DL tput and make sure that no cell in the NRPGRPs has DL Load.
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad ...
  Timer lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter ...
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 2: Set DL tput in NRPGRP-1 to get: lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH]
* Step 3: Set DL tput in NRPGRP-1 to get: pgLoad > lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:720 PowerGroup1 pgLoad ...
  Timer lbpsRTXSOnTime:
  EnergySavingAlgorithm.cpp:675 Increasing switch-on delay counter ...
  *Note: the switch-on delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 4: Set DL tput in NRPGRP-1 to get:
  lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH]
* Step 5: Stop DL tput in NRPGRP-1 and wait the amount seconds established in lbpsRTXSOffTime.
* Step 6: Set DL tput in NRPGRP-1 to get:
  pgLoad > lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> ... average[GBR, non-GBR, PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:720 PowerGroup1 pgLoad ...
  Timer lbpsRTXSOnTime:
  EnergySavingAlgorithm.cpp:675 Increasing switch-on delay counter ...
  *Note: the switch-on delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 7: While there's still DL tput in NRPGRP-1, disable the feature CB008392 by switching
  actNrLBRTXPowerSaving = False. Validate and activate the plan.
* Step 8: Set DL tput in NRPGRP-1 to get:
  pgLoad < lbpsRTXMinLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime.
* Step 9: Set DL tput in NRPGRP-1 and NRPGRP-2 to get:
  lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad
  Wait the number of seconds stablished in lbpsRTXSOffTime.
* Step 10: While there's still DL tput in NRPGRP-1 and NRPGRP-2, enable the feature CB008392
  by switching actNrLBRTXPowerSaving = True. Validate and activate the plan.
* Step 11: Wait the number of seconds stablished in lbpsRTXSOffTime.
* Step 12: Stop DL tput within the all the NRPGRPs and wait the amount seconds established in lbpsRTXSOffTime.

#### Pass Criteria
* Step 1: Cell2 and Cell3 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell within the NRPGRP-1 should be offline.
* Step 2: Each cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should remain offline.
* Step 3: Each cell state in NRPGRP-1 should transition to energySavingState = switchingOnRTX
  and a few seconds later to energySavingState = notEnergySaving.
  All the TX paths of each cell in NRPGRP-1 should be online.
* Step 4: Each cell state in NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of each cell in NRPGRP-1 should remain online.
* Step 5: Each cell state in NRPGRP-1 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should be offline.
* Step 6: Each cell state in NRPGRP-1 should transition to energySavingState = switchingOnRTX
  and a few seconds later to energySavingState = notEnergySaving.
  All the TX paths of each cell in NRPGRP-1 should be online.
* Step 7: All the gNB cells (in NRPGRP-1 as well as in NRPGRP-2) should switch
  to the state energySavingState = notEnergySaving and all cells should have all their TX paths
  online. The ongoing call should be persistent. No new alarms or errors should be raised.
* Step 8: Each cell in the gNB (in NRPGRP-1 as well as in NRPGRP-2) should remain
  as energySavingState = notEnergySaving. All the TX paths of each cell should remain online.
* Step 9: Each cell in the gNB (in NRPGRP-1 as well as in NRPGRP-2) should remain
  as energySavingState = notEnergySaving. All the TX paths of each cell should remain online.
* Step 10: No new relation errors, definition errors, nor alarms should appear.
  Activation should be successful.
* Step 11: Each cell in the gNB (in NRPGRP-1 as well as in NRPGRP-2) should remain
  as energySavingState = notEnergySaving. All the TX paths of each cell should remain online.
* Step 12: Each cell state in NRPGRP-1 and NRGRP-2 should transition
  to energySavingState = switchingOffRTX and a few seconds later
  to energySavingState = reducedEnergySaving. Half of the TX paths of each cell
  in NRPGRP-1 and NRPGRP-2 should be offline.

#### Automatic TC steps
* Preconditions
* Step 1: Check Measurements In Syslog
* Step 2: Start DL Data Transfer In Power Group 1
* Step 3: Start Additional DL Data Transfer In Power Group 1
* Step 4: Stop Additional DL Data Transfer In Power Group 1
* Step 5: Stop DL Data Transfer In Power Group 1
* Step 6: Start DL Data Transfer In Power Group 1
* Step 7: Turn Off Energy Saving
* Step 8: Stop Additional DL Data Transfer In Power Group 1
* Step 9: Start Additional DL Data Transfer In Power Groups 1 and 2
* Step 10: Turn On Energy Saving
* Step 11: Stop All Data Transfers

#### Test case developer notes
* This Test sets Suite Variables: ENERGY_SAVING_ON (boolean value determining
  if CB008392 is turned on by checking if actNrLBRTXPowerSaving=true)
  and CB008392_ACTIVATION_CHECKED (boolean value determining if it was verified
  whether CB008392 is active)
* For correct load values it is important to set correct lbpsPdcchLoadOffset
  at the time of writing this test case it was set to 22
* Wait timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since real
  waiting time was longer. This was discussed with the owner of this test case.
* At the end of this test case modifications made in SCF - deactivation of feature
  is reverted. If for some reason test case was stopped without completing teardown,
  please make sure that SCF is correct.
* Additional files saved during this test:
  * ${LOG_PATH}/misc_logs/SCF_gNB.xml - SCF from gNB saved at the beginning of the test
  * ${LOG_PATH}/misc_logs/feature_check_SCF_gNB.xml - SCF from gNB used for checking
    if feature is active.
  * syslogDebug1.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingAlgorithm.*
  * syslogDebug2.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingService.*
* This test expects only one cell in power group 1 and one in power group 2 - it checks only energy
  saving state for those two cells.
* Keyword 'Debug Syslog Prints' in teardown collects syslog prints for regular expressions:
  'EnergySavingAlgorithm.*' and 'EnergySavingService.*' which may be useful during debugging.
* This test case assumes that lbpsRTXMaxLoad and lbpsRTXMinLoad are the same for power group 1 and 2.

#### History of changes
* 25.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-942 - initial creation
* 23.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-996 - corrected test name in documentation
* 16.04.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1455 - adjustment of low tput to make pgLoad higher than 0


### CB008392_Interaction_with_DSS_Features
The purpose of this test is verification of CB008392 when there is a DSS cell in a power group.
CB008392 does not address any dynamic inter-RAT energy saving specific coordination mechanisms. For RF sharing radio, 
the energy saving gain is limited as RF HW (PA, TDD switch, DFE) which served for LTE are not allowed to be switched off 
if LTE energy saving features (LTE1203/SR003080) are not activated.
Consequently, it is possible to protect the DSS configuration by designating NR-DSS cells pair as 'last cells' 
(lbpsCellSOOrder) with last cell TX switch off enabled set to 'false' (lbpsLastCellSOEnabled= false). 
This configuration allows to prevent respective NR-DSS cells' TXs paths to be switched off for energy saving purposes.

* Owner: santiago.galindo@nokia.com
* Author: magdalena.tomczuk@nokia.com
* Maintainer: magdalena.tomczuk@nokia.com

#### Test scenario defined by owner
* Step 1: Do not set any DL tput and make sure that no cell in the NRPGRP-1 has DL Load.
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad 
  Timer lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter 
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10
* Step 2: Set DL tput in NRPGRP-1 to get:
  pgLoad < lbpsRTXMinLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
* Step 3: Set DL tput in NRPGRP-1 to get:
  lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
* Step 4: Set DL tput in NRPGRP-1 to get:
  pgLoad > lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:720 PowerGroup1 pgLoad 
  Timer lbpsRTXSOnTime:
  EnergySavingAlgorithm.cpp:675 Increasing switch-on delay counter 
  *Note: the switch-on delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 5: Stop DL tput in NRPGRP-1.
  Wait the number of seconds stablished in lbpsRTXSOffTime
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad 
  Timer  lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter 
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 6: Block the DSS cell on the eNB.
* Step 7: Set DL tput in NRPGRP-1 to get:
  pgLoad < lbpsRTXMinLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
* Step 8: Stop DL tput in NRPGRP-1.
  Wait the number of seconds stablished in lbpsRTXSOffTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
* Step 9: Unblock the DSS cell on the eNB.
  Wait until the Cell1 is on-air and wait the number of seconds stablished in lbpsRTXSOffTime
* Step 10: Set DL tput in NRPGRP-1 to get:
  pgLoad > lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:720 PowerGroup1 pgLoad 
  Timer lbpsRTXSOnTime:
  EnergySavingAlgorithm.cpp:675 Increasing switch-on delay counter 
  *Note: the switch-on delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 11: Stop DL tput in NRPGRP-1.
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad 
  Timer lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter 
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.

#### Pass Criteria
* Step 1: The NR non-DSS cell state in theNRPGRP-1 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of the NR non-DSS cell in NRPGRP-1 should be offline.
  The NR-DSS cell state in the NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online
* Step 2: The NR non-DSS cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of the NR non-DSS cell in the NRPGRP-1 should remain offline.
  The NR-DSS cell state in the NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online.
* Step 3: The NR non-DSS cell state in NRPGRP-1 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of the NR non-DSS cell in the NRPGRP-1 should remain offline.
  The NR-DSS cell state in the NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online
* Step 4: The NR non-DSScell state in NRPGRP-1 should transition to energySavingState = switchingOnRTX
  and a few seconds later to energySavingState = notEnergySaving.
  All the TX paths of each NR non-DSS cell in NRPGRP-1 should be online.
  The NR-DSS cell state in the NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online
* Step 5: The NR non-DSS cell state in NRPGRP-1 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of the NR non-DSS cell in NRPGRP-1 should be offline.
  The NR-DSS cell state within the NRPGRP should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online.
* Step 6: An alarm should be raised on the NR DSS cell:
  Alarm ID 7114 "EN DSS De-activated on partner side" (Fault ID 7513). 
  All cells' states should switch to energySavingState = notEnergySaving
  All the TX paths of the NR non-DSS cells in the NRPGRP-1 should be online.
  The DSS cell should have its TX paths as "Offline" or "Degraded".
* Step 7: All cells' states should remain as energySavingState = notEnergySaving
* Step 8: All cells' states should remain as energySavingState = notEnergySaving
* Step 9: The alarm from the step 6 (Alarm ID 7114) should disappear.
  The NR non-DSScell state in NRPGRP-1 should transition to energySavingState = switchingOffRTX
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half the TX paths of the NR non-DSS cell in NRPGRP-1 should be offline.
  The NR-DSS cell state within the NRPGRP should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online
* Step 10: Each NR non-DSScell state in NRPGRP-1 should transition to energySavingState = switchingOnRTX 
  and a few seconds later to energySavingState = notEnergySaving.
  All the TX paths of the NR non-DSS cell in NRPGRP-1 should be online.
  The NR-DSS cell state in the NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online
* Step 11: The NR non-DSS cell state in NRPGRP-1 should transition to energySavingState = switchingOffRTX 
  and a few seconds later to energySavingState = reducedEnergySaving.
  Half of the TX paths of the NR non-DSS cell in NRPGRP-1 should be offline.
  The NR-DSS cell state within the NRPGRP should remain as energySavingState = notEnergySaving.
  All the TX paths of the NR-DSS cell within NRPGRP-1 should be online.

#### Automatic TC steps
* Preconditions
* Step 1: Check Measurements In Syslog
* Step 2: Start 1ST DL Data Transfer In Power Group 1
* Step 3: Start 2ND DL Data Transfer In Power Group 1
* Step 4: Start 3RD DL Data Transfer In Power Group 1
* Step 5: Stop DL Data Transfer In Power Group 1
* Step 6: Block LTE DSS Cell And Check Fault On NR DSS Cell
* Step 7: Start 4TH DL Data Transfer In Power Group 1
* Step 8: Stop DL Data Transfer In Power Group 1
* Step 9: Unblock LTE DSS Cell And Check Fault On NR DSS Cell
* Step 10: Start 5TH DL Data Transfer In Power Group 1
* Step 11: Stop DL Data Transfer In Power Group 1

#### Test case developer notes
* This Test sets Suite Variables: ENERGY_SAVING_ON (boolean value determining
  if CB008392 is turned on by checking if actNrLBRTXPowerSaving=true)
  and CB008392_ACTIVATION_CHECKED (boolean value determining if it was verified
  whether CB008392 is active)
* For correct load values it is important to set correct lbpsPdcchLoadOffset
* Wait timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since real
  waiting time was longer. This was discussed with the owner of this test case.
* At the end of this test case modifications made in SCF - deactivation of feature
  is reverted. If for some reason test case was stopped without completing teardown,
  please make sure that SCF is correct.
* Additional files saved during this test:
  * ${LOG_PATH}/misc_logs/SCF_gNB.xml - SCF from gNB saved at the beginning of the test
  * ${LOG_PATH}/misc_logs/feature_check_SCF_gNB.xml - SCF from gNB used for checking
    if feature is active.
  * syslogDebug1.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingAlgorithm.*
  * syslogDebug2.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingService.*
* This test expects two cells in power group 1 (one cell with DSS), 
  but it checks energy saving state for cell without DSS.
* Keyword 'Debug Syslog Prints' in teardown collects syslog prints for regular expressions:
  'EnergySavingAlgorithm.*' and 'EnergySavingService.*' which may be useful during debugging.

#### History of changes
* 23.09.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-944 - initial creation


### CB008392_F_EIRP_Counters_Control_and_Monitoring
The main purpose of CB008392 is to reduce the energy consumption per cell by around 50% when the cell 
is in energySavingState= reducedEnergySaving with respect to when it is in energySavingState= notEnergySaving.
This can be verified by monitoring the following power counters per cell:
M55324C00464
M55324C00701
M55324C00802

* Owner: santiago.galindo@nokia.com
* Author: magdalena.tomczuk@nokia.com
* Maintainer: magdalena.tomczuk@nokia.com

#### Test scenario defined by owner
* Step 1: Do not set any DL tput and make sure that no cell in the NRPGRP-1 has DL Load.
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad 
  Timer lbpsRTXSOffTime:
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter 
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.
* Step 2: Set DL tput in NRPGRP-1 to get: lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
  Check that the Rank from the UE side is 2.
* Step 3: Consider the DL tput value of the DL load from step 2 as: Ref_DL.
* Step 4: Monitor the values of the following EIRP counters:
  From the Cell2 in the NRPGRP-1:
  M55324C00464
  M55324C00701
  M55324C00802
  Wait 95 mins (it takes around 20 mins for the counters to reach a steady level, 
  and 75 mins of power measurements is a good data sample).
  Average the values of each counter from the 20th minute to the 95th minute, 
  so the actual value to be considered per counter is its own average from the 75 mins window.
* Step 5: Set DL tput in NRPGRP-1 to get: pgLoad > lbpsRTXMaxLoad (DL call in Cell2)
  Wait the number of seconds stablished in lbpsRTXSOnTime
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs per cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:720 PowerGroup1 pgLoad 
  Timer lbpsRTXSOnTime:
  EnergySavingAlgorithm.cpp:675 Increasing switch-on delay counter 
  *Note: the switch-on delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10
* Step 6: Set DL tput in NRPGRP-1 to get Ref_DL:
  lbpsRTXMinLoad < Ref_DL < lbpsRTXMaxLoad
  Wait the number of seconds stablished in lbpsRTXSOffTime.
  Suggestion:
  This can be checked by monitoring the average[] vector from the syslogs rer cell: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
* Step 7: Attenuate to the maximum possible level 2 antenna pipes from the RMOD.
  Suggestion:
  Check that the Rank from the UE side is actually 2 as on the step 2.
  Check that the average[] vector from the syslogs is very similar or identical to the one from the step 2: 
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[GBR, non-GBR, PDCCH]
* Step 8: Monitor the values of the following EIRP counters:
  From the Cell2 in the NRPGRP-1:
  M55324C00464
  M55324C00701
  M55324C00802
  Wait 95 mins (it takes around 20 mins for the counters to reach a steady level, 
  and 75 mins of power measurements is a good data sample).
  Average the values of each counter from the 20th minute to the 95th minute, 
  so the actual value to be considered per counter is its own average from the 75 mins window.
* Step 9: Compare the arrays: cellEIRP_res[] vs cellEIRP_nes[]
* Step 10: Stop DL tput in NRPGRP-1 (No DL tput in the Cell2).
  Wait the number of seconds stablished in lbpsRTXSOffTime
  Suggestion:
  Check the load component measurement in the syslogs:
  Per cell:
  EnergySavingAlgorithm.cpp:134 [CELL] nrCellIdentity:<*NRcellID*> average[0,0,PDCCH]
  Per NRPGRP:
  EnergySavingAlgorithm.cpp:513 PowerGroup1 pgLoad 
  Timer lbpsRTXSOffTime::
  EnergySavingAlgorithm.cpp:607 Increasing switch-off delay counter 
  *Note: the switch-off delay counter is updated every 10 s, so its value is displayed as: lbpsRTXSOffTime/10.

#### Pass Criteria
* Step 1: Cell2 should transition to energySavingState = switchingOffRTX and a few seconds later to 
  energySavingState = reducedEnergySaving. 
  Half of the Cell2 should be offline
* Step 2: The Cell2 should remain as energySavingState = reducedEnergySaving.
  Half of the TX paths of each cell in NRPGRP-1 should remain offline
* Step 3: The DL load value Ref_DL will be used as a reference DL load to evaluate the energy efficiency performance
* Step 4: Consider the average values from the 4 EIRP counters as an array: cellEIRP_res[]
  Keep in mind that when the Cell2 is in energySavingState = reducedEnergySaving, the rank indicator is 2, 
  so on the step 7, it will be necessary to have the same conditions by attenuating 2 antenna pipes. 
* Step 5: The Cell2 in NRPGRP-1 should transition to energySavingState = switchingOnRTX and a few seconds later to
  energySavingState = notEnergySaving.
  All the TX paths of the Cell2 in NRPGRP-1 should be online.
* Step 6: The Cell2 state in NRPGRP-1 should remain as energySavingState = notEnergySaving.
  All the TX paths of the Cell2 in NRPGRP-1 should remain online.
* Step 7: Rank= 2
* Step 8: Consider the average values from the 4 EIRP counters as an array: cellEIRP_nes[]
* Step 9: All the values within the array cellEIRP_res[] should be between 45% and 55% of their correspondent 
  values in cellEIRP_nes[]: 0.45*cellEIRP_not_ES[]</= cellEIRP_reduced_ES[]</= 0.55*cellEIRP_not_ES[]
* Step 10: The Cell2 in the NRPGRP should transition to energySavingState = switchingOffRTX and a few seconds later to 
  energySavingState = reducedEnergySaving.
  Half the TX paths of the Cell2 within the NRPGRP should be offline.

#### Automatic TC steps
* Preconditions
* Step 1: Check Measurements In Syslog
* Step 2: Start DL Data Transfer In Power Group 1
* Step 3: Monitor The Values Of The Following EIRP Counters
* Step 4: Start 2ND DL Data Transfer In Power Group 1
* Step 5: Start 3RD DL Data Transfer In Power Group 1
* Step 6: Monitor The New Values Of The Following EIRP Counters
* Step 7: Compare The Arrays With EIRP Counters
* Step 8: Stop DL Data Transfer In Power Group 1

#### Test case developer notes
* This Test sets Suite Variables: ENERGY_SAVING_ON (boolean value determining
  if CB008392 is turned on by checking if actNrLBRTXPowerSaving=true)
  and CB008392_ACTIVATION_CHECKED (boolean value determining if it was verified
  whether CB008392 is active)
* In this TC three EIRP counters are checking (after agreeing with the owner of the TC)
* For correct load values it is important to set correct lbpsPdcchLoadOffset
* Wait timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since real
  waiting time was longer. This was discussed with the owner of this test case.
* At the end of this test case modifications made in SCF - deactivation of feature
  is reverted. If for some reason test case was stopped without completing teardown,
  please make sure that SCF is correct.
* Additional files saved during this test:
  * ${LOG_PATH}/misc_logs/SCF_gNB.xml - SCF from gNB saved at the beginning of the test
  * ${LOG_PATH}/misc_logs/feature_check_SCF_gNB.xml - SCF from gNB used for checking
    if feature is active.
  * syslogDebug1.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingAlgorithm.*
  * syslogDebug2.txt - debug log for syslog prints filtered with regular expression:
    EnergySavingService.*
* This test expects one cell in power group 1 (on which EIRP counters will be checked)
* Keyword 'Debug Syslog Prints' in teardown collects syslog prints for regular expressions:
  'EnergySavingAlgorithm.*' and 'EnergySavingService.*' which may be useful during debugging.

#### History of changes
* 23.09.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-943 - initial creation
