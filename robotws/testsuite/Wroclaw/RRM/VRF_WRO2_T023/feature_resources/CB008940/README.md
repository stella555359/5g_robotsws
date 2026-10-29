# CB008940: Baseband pooling of DL PRBs - FR1 TDD
Robot test suite for feature CB008940.

## Test line requirements
This section is taken from the automation requests done by Santiago Galindo.

### Example configuration
ASIL, ABIO, AEQE, AEHC, AZHL, 1 5G UE compatible with the band 41.

#### 5G cell config
AEQE:
* Cell-0 [4x4][Band n78][BW: 100 Mhz].

AEHC:
* Cell-3 [4x4][Band n41][BW: 100 Mhz].

AZHL:
* Cell-2 [4x4][Band n41][BW: 100 Mhz].

### Required initial BTS state (not to be checked but provided directly from SCF)
* The LTE and NR RATs are operational without critical alarms or errors.
* The ABIO should be exclusive for: AEQE, AEHC, AZHL and their respective cells. The 3 RMODs should be connected to the 
  same half of the ABIO (it's suggested to use the first three ports), and the other ports should not have any devices
  connected to them.
* At least one UE compatible with the band 41 (TDD 4x4 cell from the AZHL).  
* Regarding the power group (NRPGRP) configuration, It is recommended to set NRPGRP.lbpsRTXMaxLoad to a value strictly
  higher than 2*NRPGRP.lbpsRTXMinLoad (lbpsRTXMaxLoad > 2*lbpsRTXMinLoad) to avoid a scenario in which a cell has its
  TX paths switched off due to the power group load being at or below NRPGRP.lbpsRTXMinLoad and within a few minutes is
  switched on due to the power group load increasing above NRPGRP.lbpsRTXMaxLoad.
* If the third position of the average[] vector (PDCCH) from the syslogs is greater than or equal to lbpsPdcchLoadOffset,
  AND it is the vector's maximum value, then the reference value to determine the load relative to lbpsRTXMinLoad or
  lbpsRTXMaxLoad is:
  * lpsRTXMinLoad- lbpsPdcchLoadOffset
  * lpsRTXMaxLoad- lbpsPdcchLoadOffset
* The DL load (pgLoad) is measured per NRPGRP and calculated based on the number of PRBs available, later, it's
  normalized to a percentage scale. So, to have a straightforward and reliable way to modify the DL load in a NRPGRP
  and induce changes in the energySavingState status of each cell, it's recommended to consider the following throughput
  when performing a DL call:
  * DL tput > lbpsRTXMaxLoad: >400 Mbps (or the maximum possible DL tput).
  * DL tput < lbpsRTXMinLoad: < 25 Mbps.


#### 5G
* Feature CB008392 activated (actNrLBRTXPowerSaving = True).
* Feature CB008940 activated (actBbPoolTddFr1 = True).
* Make sure that the following R&D flag is in the swconfig file:
  * 0x420068=7
  * For 22R3 this flag is mandatory to enable CB008940. This is a long-lead feature and just activating it via
    WebEm does not make it functional.
* The ABIO (EQM/APEQM-1/CABINET/BBMOD-) to which AEQE, AEHC, and AZHL are connected, should have the following parameter
  configured:
  * bbmodBoardConfigType = LTETDD_NRTDD
* All the NR mMIMO cells configured in the BBMOD with bbmodBoardConfigType = LTETDD_NRTDD, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actCsirsMultiplexing = true
* All the NR cells configured in the BTS, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actShortBsrLimitAdaptation = true
* One power group (NRBTS-/NRPGRP-) with 1 cell and set up the following parameters:
  * NRPGRP/lbpsCellList/nrCellId= *existing nrCellId (Cell4)
  * NRPGRP/lbpsPeriodList/lbpsDayOfWeek= *current weekday
  * NRPGRP/lbpsPeriodList/lbpsDuration= *1440 recommended
  * NRPGRP/lbpsPeriodList/lbpsStartTimeHour= 0
  * NRPGRP/lbpsPeriodList/lbpsStartTimeMinute= 0
  * NRPGRP/lbpsLastCellSOEnabled= true
  * NRPGRP/lbpsSOMethod= TX switch off
  * NRPGRP/lbpsPeriodList/lbpsRTXSOffTime= *40 recommended
  * NRPGRP/lbpsPeriodList/lbpsRTXSOnTime= *40 recommended
  * NRPGRP/lbpsRTXMinLoad= lbpsLastCellRTXMinLoad (*20 recommended).
  *	NRPGRP/lbpsRTXMaxLoad= *45 recommended.
  *	NRPGRP/lbpsPdcchLoadOffset= *4 recommended.
  *	NRPMRNL/miNrCellAvailability= 5min.
  *	Leave the other default parameters as they are.
* It is recommended to set NRPGRP.lbpsRTXMaxLoad to a value strictly higher than 2*NRPGRP.lbpsRTXMinLoad
  (lbpsRTXMaxLoad > 2*lbpsRTXMinLoad) to avoid a scenario in which a cell has its TX paths
  switched off due to the power group load being at or below NRPGRP.lbpsRTXMinLoad and within
  a few minutes is switched on due to the power group load increasing above NRPGRP.lbpsRTXMaxLoad.

## Test cases

### CB008940_F4_POST_Inetraction_CB008392_Cell_TX_Path_Switch_On_List
The purpose of this test case is to check the interaction between CB008940 and CB008392.

CB008392 allows cells to have an energySavingState = notEnergySaving (all TXs online) when the cells' DL tput makes the
internally measured value pgLoad be above the value defined in the BTS parameter lpsRTXMaxLoad.

CB008940 introduces FR1 TDD baseband resource pooling in a gNB to optimize L1 resources allocation for processing PRBs
for the cells configured in the BBMOD in use (ABIO).

The L1 resources allocation for processing PRBs provided by CB008940 affects how pgLoad (value monitored in the syslogs
when CB008392 is activated) is calculated, so this TC verifies that pgLoad changes proportionally and as expected based
on the cell's DL throughput and reaches a value above lpsRTXMaxLoad so the cell can switch on all of its TXs paths while
being in energySavingState = notEnergySaving.

* Owner: santiago.galindo@nokia.com
* Author: santiago.galindo@nokia.com
* Maintainer: santiago.galindo@nokia.com

#### Test scenario defined by owner
* Step 1: Set DL tput in the Cell to get:

  pgLoad > lbpsRTXMaxLoad.

  Wait the number of seconds established in lbpsRTXSOnTime.


#### Pass Criteria
* Step 1: The Cell should transition to energySavingState = switchingOnRTX and a few seconds later to
  energySavingState = notEnergySaving.

  All the TX paths of each cell within the NRPGRPs should be online.

  pgLoad > lbpsRTXMinLoad

  Due to the PRBs dynamic redistribution provided by CB008940, there are two possible outcomes for the pgLoad 
  measurements (with small variations of approximately 5%):
  
    pgLoad > lbpsRTXMaxLoad

    OR
  
    lbpsRTXMinLoad < pgLoad < lbpsRTXMaxLoad

  In any case:
    pgLoad > lbpsRTXMinLoad

  Example: If lbpsRTXMaxLoad= 45 and pgLoad= 60, once the cell's energy saving state switches to notEnergySaving, then, 
  due to the PRBs' dynamic redistribution, it's expected that pgLoad could be between 40 and 50, probably with a
  different value for each test execution. Therefore, it's enough to fulfill the following condition:
  pgLoad > lbpsRTXMinLoad


#### Automatic TC steps
* Preconditions
* Step1: DL Data Transfer for TXs Switch On List

#### Test case developer notes
* The waiting timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since
  the real waiting time was a bit longer due to an internal transition state between reducedEnergySaving and notEnergySaving.
* This TC uses the following specific keywords:
  * CB008940 Parameters Activation and Configuration: Enables the feature CB008940 (actBbPoolTddFr1=true), sets
    up the BBMOD configuration for the feature to work properly (bbmodBoardConfigType=LTETDD_NRTDD), and modifies
    other cells to adapt the TL for this test case.
  * Revert CB008940 Configuration: Reverts all the changes performed by the keyword 'CB008940 Parameters Activation and
    Configuration'.
* All the NR mMIMO cells configured in the BBMOD with bbmodBoardConfigType = LTETDD_NRTDD, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actCsirsMultiplexing = true
  Please consider this when including / modifying NR mMIMO cells in the BBMOD with bbmodBoardConfigType = LTETDD_NRTDD.
* All the NR cells configured in the BTS, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actShortBsrLimitAdaptation = true
  Please consider this when including / modifying NR cells in the BTS.
  

#### History of changes
* 07.03.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1039 - initial creation
* 09.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1039 - Modifications after PR701565, PR706777,
  and AQQQA cell configuration.
* 04.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1148 - Added argument to updated Analyze Power Group Load From Syslog For CB008392 in ca_IWK to match new syslog prints
* 22.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1156 - Added in delta symbol $ to parameter actBbPoolTddFr1 to prevent changing other parameters that contain this name. Added actBbPoolTddFr1AlgEnh to delta for releases 24R1 and newer.
* 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1187 - Made changes due to SCF modification - recommissioning is removed
* 19.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1743 - Adding  apn=${APN} parameter to "Start Data Transfer"

### CB008940_F5_POST_Inetraction_CB008392_Cell_TX_Path_Switch_Off_List
The purpose of this test case is to check the interaction between CB008940 and CB008392.

CB008392 allows cells to have an energySavingState = reducedEnergySaving (half TXs offline) when the cells' DL tput makes the
internally measured value pgLoad be below the value defined in the BTS parameter lpsRTXMinLoad.

CB008940 introduces FR1 TDD baseband resource pooling in a gNB to optimize L1 resources allocation for processing PRBs
for the cells configured in the BBMOD in use (ABIO).

The L1 resources allocation for processing PRBs provided by CB008940 affects how pgLoad (value monitored in the syslogs
when CB008392 is activated) is calculated, so this TC verifies that pgLoad changes proportionally and as expected based
on the cell's DL throughput and reaches a value below lpsRTXMinLoad so the cell can switch off half of its TXs paths while
being in energySavingState = reducedEnergySaving.

* Owner: santiago.galindo@nokia.com
* Author: santiago.galindo@nokia.com
* Maintainer: santiago.galindo@nokia.com

#### Test scenario defined by owner
* Step 1: Set DL tput in the Cell4 to get:

  pgLoad < lbpsRTXMinLoad.

  Wait the number of seconds established in lbpsRTXSOnTime.

#### Pass Criteria
* Step 1: The Cell4 should remain in energySavingState = reducedEnergySaving. Half of its TXs should remain offline.
  pgLoad < lbpsRTXMinLoad 

#### Automatic TC steps
* Preconditions
* Step1: DL Data Transfer for TXs Switch Off List

#### Test case developer notes
* The waiting timers: lbpsRTXSOnTime and lbpsRTXSOffTime are increased by 30s, since
  the real waiting time was a bit longer due to an internal transition state between reducedEnergySaving and notEnergySaving.
* This TC uses the following specific keywords:
  * CB008940 Parameters Activation and Configuration: Enables the feature CB008940 (actBbPoolTddFr1=true), sets
    up the BBMOD configuration for the feature to work properly (bbmodBoardConfigType=LTETDD_NRTDD), and modifies
    other cells to adapt the TL for this test case.
  * Revert CB008940 Configuration: Reverts all the changes performed by the keyword 'CB008940 Parameters Activation and
    Configuration'.
* All the NR mMIMO cells configured in the BBMOD with bbmodBoardConfigType = LTETDD_NRTDD, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actCsirsMultiplexing = true
  Please consider this when including / modifying NR mMIMO cells in the BBMOD with bbmodBoardConfigType = LTETDD_NRTDD.
* All the NR cells configured in the BTS, should have the following 
  parameter enabled:
  * MRBTS-/NRBTS-/NRCELL-/actShortBsrLimitAdaptation = true
  Please consider this when including / modifying NR cells in the BTS.

#### History of changes
* 07.03.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1040 - initial creation
* 09.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1040 - Modifications after PR701565, PR706777,
  and AQQQA cell configuration.
* 04.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1148 - Added argument to updated Analyze Power Group Load From Syslog For CB008392 in ca_IWK to match new syslog prints
* 22.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1156 - Added in delta symbol $ to parameter actBbPoolTddFr1 to prevent changing other parameters that contain this name. Added actBbPoolTddFr1AlgEnh to delta for releases 24R1 and newer.
* 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1187 - Made changes due to SCF modification - recommissioning is removed
* 19.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1743 - Adding  apn=${APN} parameter to "Start Data Transfer"
