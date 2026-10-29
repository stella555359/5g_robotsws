# CB008133: Power Saving mMIMO
Robot test suite for feature CB008133.

## Test line requirements
This section is taken from automation requests done by Piotr Maj.

### Example configuration
ASIB+ABIL+ABIO+ABIO+AEQE+AEHC+AQQK+AQQQA+RMOD LTE

#### Cell config
AEQE:
* Cell[Band b5+n78]: NR NSA
AEHC:
* Cell[Band b5+n41]: NR NSA
AQQK:
* Cell[Band n77]: NR SA
AQQQA:
* Cell[Band n77]: NR SA
RMOD LTE:
* Cell[Band 1]: LTE Anchor

### Required initial BTS config (not to be checked but provided directly from SCF)
* Feature CB008133 activated (actNrLBmMimoRTXPowerSaving = True).
* Create power groups (NRBTS-/NRPGRP) for every cell and set up the following parameters:
  * lbpsCellList/nrCellId= *existing nrCellId
  * lbpsCSONCtlEnabled= false
  * lbpsLastCellMinLoad= 0
  * lbpsLastCellRTXMinLoad= 20
  * lbpsLastCellSOEnabled= true
  * lbpsMaxLoad= 60
  * lbpsMinLoad= 20
  * lbpsMonWinForCellSOff= 300
  * lbpsMonWinForCellSOn= 120
  * lbpsPdcchLoadOffset= 100
  * lbpsRTXCellCapOffset= 80
  * lbpsRTXMaxLoad= 60
  * lbpsRTXMinLoad= 20
  * lbpsRTXSOffTime= 30
  * lbpsRTXSOnTime= 30
  * lbpsSOMethod= TX switch off
  * lbpsPeriodList/lbpsDayOfWeek= *all weekdays should be added one by one with following setup:
  * lbpsDuration= *1440 recommended
  * lbpsStartTimeHour= 0
  * lbpsStartTimeMinute= 0
  * lbpsSuspended= notSuspended
  * lbpsRTXSOffTime= *30 recommended
  * lbpsRTXSOnTime= *30 recommended
  * NRPMRNL/miNrCellAvailability= 5min.
  * Leave the other default parameters as they are.


## Test cases

### CB008133_A_Power_reduction_by_32TRX_path_switch_off_on_nGBR_load_trigger
This case is to verify the functionality of 32TRX path switched off/on for eCPRI based TDD massive MIMO cell for nGBR load trigger

* Owner: piotr.1.maj@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Test scenario defined by owner
* Step 1:
Description: Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold (max tput 1,5Gb/s). Wait 1min.
* Step 2:
Description: Traffic (nGBR load) is generated in tested NRPGP below minimum load threshold (25Mb/s). Wait 1min.
* Step 3:
Description: Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold (max tput 1,5Gb/s). Wait 1 min.
* Step 4:
Description: Steps 1-3 are repeated several times.

#### Pass Criteria
* Step 1: Cells in tested NRPGRP have state energySavingState = notEnergySaving. 
* Step 2: Cells in tested NRPGRP change state to energySavingState = reducedEnergySaving. 
* Step 3: Cells in tested NRPGRP have state energySavingState = notEnergySaving.
* Step 4: Same as in steps 1-3.

#### Automatic TC steps
* Preconditions
* Step 1: Perform Data Transfer Above Maximum Load Threshold
* Step 2: Perform Data Transfer Below Minimum Load Threshold
* Step 3: Perform Data Transfer Above Maximum Load Threshold
* Steps 1-3 looped 3 times

#### Test case developer notes
* Before any PR will be raised there is needed to check syslogs and analyse
  pgLoad in power group powerGroup.id: 0, pgLoad: 8. When pgLoad is lower/higher than adequate thresholds (lbpsRTXMinLoad=10.
  lbpsRTXMaxLoad=40) switch on/off procedure is started (Increasing switch-off delay counter [1/3], cells will not be switched-off now).
  The pgLoad must be continuously lower/higher than adequate thresholds for adequate on/off time (lbpsRTXSOnTime/ lbpsRTXSOffTime).
  If any of the measurements will not have the correct value trigger system will reset counter incrementation.
  
  Syslog print: 
  
  226039 16.12 14:57:48.409 [192.168.255.129] 6e ASC-1515-2-Cprt <2022-12-16T13:57:48.399979Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:160 [CELL] nrCellIdentity:65765376 collected 4 measurements, average=[0, 18, 5, 0]
  226040 16.12 14:57:48.409 [192.168.255.129] 6f ASC-1515-2-Cprt <2022-12-16T13:57:48.399980Z> 8D-cp_rt 
  DBG/cp_rt/EnergySavingAlgorithm.cpp:160 [CELL] nrCellIdentity:65765382 collected 4 measurements, average=[0, 0, 0, 0]
  226041 16.12 14:57:48.409 [192.168.255.129] 70 ASC-1515-2-Cprt <2022-12-16T13:57:48.400013Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1110 [NRPGRP] currentTime: Fri145748, **powerGroup.id: 0, pgLoad: 8**
  226042 16.12 14:57:48.409 [192.168.255.129] 71 ASC-1515-2-Cprt <2022-12-16T13:57:48.400023Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1126 [PowerSaving][slidingAverage] powerGroup.id: 0, pgLoadAverCellSwitchOn: 0, lbpsMonWinForCellSOn: 120
  226043 16.12 14:57:48.419 [192.168.255.129] 72 ASC-1515-2-Cprt <2022-12-16T13:57:48.400025Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1137 [PowerSaving][slidingAverage] powerGroup.id: 0, pgLoadAverCellSwitchOff: 0, lbpsMonWinForCellSOff: 300
  226044 16.12 14:57:48.419 [192.168.255.129] 73 ASC-1515-2-Cprt <2022-12-16T13:57:48.400070Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:542 PowerGroup0 lastCellSO is Enabled and pgLoadEstimated=9 **pgLoad=8 lbpsRTXMinLoad=10. lbpsRTXMaxLoad=40**.
  1 cell(s) will have s-off TXs (nrCellIdentity: [65765382])
  226045 16.12 14:57:48.419 [192.168.255.129] 74 ASC-1515-2-Cprt <2022-12-16T13:57:48.400126Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:776 **Increasing switch-off delay counter [1/3], cells will not be switched-off now**
* Adittional setting information available in jira ticket

#### History of changes
* 18.01.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1015 - initial creation
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1103 - added new variables to adjust tput and delay values 
before checking powerSavingState after changing old SCF to Golden SCF
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1101 - changed the way 'periodicCsiAcquisition' parameters are 
selected for deletion to work properly with 23R4, which adds a new parameter (scramblingIdStep) to 'periodicCsiAcquisition'
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1100 - added test CB008133_A_Power_reduction_by_32TRX_path_switch_off_on_nGBR_load_trigger on AQQQA
* 20.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1139 - increased waiting time after SCF parameters changes


### CB008133_B_Power_reduction_by_32TRX_path_switch_off_on_nGBR_load_trigger
This case is to verify interworking between power saving (CB008133) and:
* delivery of beam set realization to gNB (5GC001866). 
* 5GC002200 Support 4x8 port CSI-RS codebook for SU-MIMO
* CB008247 SRS based downlink beamforming
  
* Owner: piotr.1.maj@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Test scenario defined by owner
* Step 1:
Description: Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold (max tput 1,5Gb/s). Wait 1min.
* Step 2:
Description: Traffic (nGBR load) is generated in tested NRPGP below minimum load threshold (25Mb/s). Wait 1min.
* Step 3:
Description: Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold (max tput 1,5Gb/s). Wait 1 min.

#### Pass Criteria
* Step 1: Cells in tested NRPGRP have state energySavingState = notEnergySaving. 
* Step 2: Cells in tested NRPGRP change state to energySavingState = reducedEnergySaving. 
* Step 3: Cells in tested NRPGRP have state energySavingState = notEnergySaving.

#### Automatic TC steps
* Preconditions
* Step 1: Perform Data Transfer Above Maximum Load Threshold
* Step 2: Perform Data Transfer Below Minimum Load Threshold
* Step 3: Perform Data Transfer Above Maximum Load Threshold

#### Test case developer notes
* Before any PR will be raised there is needed to check syslogs and analyse
  pgLoad in power group powerGroup.id: 0, pgLoad: 8. When pgLoad is lower/higher than adequate thresholds (lbpsRTXMinLoad=10.
  lbpsRTXMaxLoad=40) switch on/off procedure is started (Increasing switch-off delay counter [1/3], cells will not be switched-off now).
  The pgLoad must be continuously lower/higher than adequate thresholds for adequate on/off time (lbpsRTXSOnTime/ lbpsRTXSOffTime).
  If any of the measurements will not have the correct value trigger system will reset counter incrementation.
  
  Syslog print:
  
  226039 16.12 14:57:48.409 [192.168.255.129] 6e ASC-1515-2-Cprt <2022-12-16T13:57:48.399979Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:160 [CELL] nrCellIdentity:65765376 collected 4 measurements, average=[0, 18, 5, 0]
  226040 16.12 14:57:48.409 [192.168.255.129] 6f ASC-1515-2-Cprt <2022-12-16T13:57:48.399980Z> 8D-cp_rt 
  DBG/cp_rt/EnergySavingAlgorithm.cpp:160 [CELL] nrCellIdentity:65765382 collected 4 measurements, average=[0, 0, 0, 0]
  226041 16.12 14:57:48.409 [192.168.255.129] 70 ASC-1515-2-Cprt <2022-12-16T13:57:48.400013Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1110 [NRPGRP] currentTime: Fri145748, **powerGroup.id: 0, pgLoad: 8**
  226042 16.12 14:57:48.409 [192.168.255.129] 71 ASC-1515-2-Cprt <2022-12-16T13:57:48.400023Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1126 [PowerSaving][slidingAverage] powerGroup.id: 0, pgLoadAverCellSwitchOn: 0, lbpsMonWinForCellSOn: 120
  226043 16.12 14:57:48.419 [192.168.255.129] 72 ASC-1515-2-Cprt <2022-12-16T13:57:48.400025Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:1137 [PowerSaving][slidingAverage] powerGroup.id: 0, pgLoadAverCellSwitchOff: 0, lbpsMonWinForCellSOff: 300
  226044 16.12 14:57:48.419 [192.168.255.129] 73 ASC-1515-2-Cprt <2022-12-16T13:57:48.400070Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:542 PowerGroup0 lastCellSO is Enabled and pgLoadEstimated=9 **pgLoad=8 lbpsRTXMinLoad=10. lbpsRTXMaxLoad=40**.
  1 cell(s) will have s-off TXs (nrCellIdentity: [65765382])
  226045 16.12 14:57:48.419 [192.168.255.129] 74 ASC-1515-2-Cprt <2022-12-16T13:57:48.400126Z> 8D-cp_rt
  DBG/cp_rt/EnergySavingAlgorithm.cpp:776 **Increasing switch-off delay counter [1/3], cells will not be switched-off now**
* Adittional setting information available in every jira ticket 
* Interworking with 5GC001866 needs BSR file (include both muting and unmuting beamset) is loaded to gNB. Development creates BSR file
  for a specific type of radia (AEHC in this case, file added to jira ticket IWK-1007)
  Proper BSR file name is added in NRCELL/customBeamSetName.
* This test case covers: 
  CB008133_interworking_with_5GC001866 
  CB008133_interworking_with_5GC002200
  CB008133_interworking_with_CB008247
  
  
  



#### History of changes
* 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1004 - initial creation
* 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1006 - initial creation
* 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1007 - initial creation
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1103 - added new variables to adjust tput and delay values 
before checking 'powerSavingState' after changing old SCF to Golden SCF
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1100 - added test CB008133_interworking_with_5GC002200 on AQQQA
* 26.09.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1126 - added to test CB008133_B_interworking_with_5GC001866 downloading BSR File from UEPC and uploading it to BTS


### CB008133_B_interworking_with_5GC001991
This case check interactions between CB008133 and 5GC001991 Antenna tilt for 2D GoB. When CB008133 is enabled the valid 
tiltOffset will be limited by 32TRX beamset steering range instead of 64TRX beamset steering range. When tiltOffset is 
set out of 32TRX beamset steering range (even if it will be on 64TRX beamset steering range) 
fault 4598: EFaultId_TiltOffsetOutOfRangeAl should be raised.

* Owner: piotr.1.maj@nokia.com
* Author: michal.hadrysiak@nokia.com
* Maintainer: michal.hadrysiak@nokia.com

#### Test scenario defined by owner
* Step 1:
Description: For cell belonged to NRPGRP the operator changes tiltOffset to value inside 32TRX beamset steering range. 
Validation and activation are triggered.
* Step 2:
Description: For cell belonged to NRPGRP the operator changes tiltOffset to value outside 64TRX beamset steering range. 
Validation and activation are triggered.
* Step 3:
Description: For cell belonged to NRPGRP the operator changes tiltOffset to value inside 64TRX beamset steering range 
but outside 32TRX beamset steering range. Validation and activation is triggered.
* Step 4:
Description: Repeat step 1.

#### Pass Criteria
* Step 1: After unlocking cell reach onAir state.
* Step 2: After unlocking fault 4598: EFaultId_TiltOffsetOutOfRangeAl is raised. 
* Step 3: After unlocking fault 4598: EFaultId_TiltOffsetOutOfRangeAl is raised.
* Step 4: Cell is locked/unlocked. After unlocking cell reach onAir state.

#### Automatic TC steps
* Preconditions
* Step 1: Changing TiltOffset To Value Inside 32TRX
* Step 2: Changing TiltOffset To Value Outside 64TRX
* Step 3: Changing TiltOffset To Value Inside 64TRX
* Step 4: Changing TiltOffset To Value Inside 32TRX


#### History of changes
* 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1008 - initial creation


### CB008133_A_View_Power_Saving_Performance_ Management_Counters
This case checks counters related to power saving feature (CB008133)
  
* Owner: piotr.1.maj@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* Step 1:
Traffic (nGBR load) is generated in tested NRPGP below minimum load threshold.
* Step 2:
Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold.
* Step 3:
Step1 and Step2 repeat 3 times. 
* Step4:
Counter M55601C02001 Cell state changes to "reduced TX power saving mode" is verified in WebEM and NMS.
* Step5:
Traffic (nGBR load) is generated in tested NRPGP below minimum load threshold.
* Step6:
Wait till new counter period and after that wait 2 min.
* Step7:
Traffic (nGBR load) is generated in tested NRPGP above maximum load threshold.
* Step8:
Wait 3 min.
* Step9:
Counter M55601C02002 Samples when the cell is in "reduced TX power saving mode" is verified in WebEM and NMS in 150-180s.

#### Pass Criteria
* Step 9: Counters are visible in WebEM and NMS and have correct value (M55601C02001=3, M55601C02002=150-180). 

#### Automatic TC steps
* Preconditions
* Step 1: Start DL Data Transfer Below Minimum Load Threshold
* Step 2: Start and Stop DL Data Transfer Above Maximum Load Threshold Several Times
* Step 3: Collect And Compare Counters M55601C02001 M55601C02002

#### Test case developer notes
* Description of TC has been developed for case when counter measurement period is 5 min. 
  TC is automated for counter measurement period 15 min. Testing RMOD is AEQE on TL Beamskupin.

#### History of changes
* 03.02.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1005 - initial creation
* 02.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1103 - added new variables to adjust tput and delay values 
before checking 'powerSavingState' after changing old SCF to Golden SCF
* 05.12.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1165 - adjustment of lower and upper limits of counter M55601C02002 to correspond to better transfer stability with taf.ue.proxy than older library
* 16.04.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1455 - increased tput time to prevent data transfer from ending early
* 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1476 - packet_size set for low tput because default value on new iperf servers is too high
