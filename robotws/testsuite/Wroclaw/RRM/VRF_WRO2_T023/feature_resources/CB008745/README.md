# CB008745
Robot test suite for feature CB008745.

## Test line requirements
This section is taken from automation requests done by Mariusz Daniel

### Example configuration

HW LTE: AMIA+ASIA+ABIA+ RMOD1 + RMOD2

HW 5G: AMIA+ASIK+ABIL+ RMOD3 + RMOD4

SHDF cable between ASIA and ASIK

#### LTE cell config

* 1 LTE cell on RMOD1: 4TX/4RX
* 2 LTE cell on RMOD2

#### 5G cell config

* 1 5G cell on RMOD3
* 2 5G cell on RMOD4

### Test environment and settings:

WebEM, real eNB 4G, real gNB 5, real core, BTS Log

### UEs:

* LTE NSA(QC8150 NA or similar) or
* LTE capable UE + 5G capable UE

### Required initial BTS state (not to be checked but provided directly from SCF)

* LTE4088 is activated, i.e. actLteNrDualConnectivity is set to 'true'
* UE has been configured with MCG bearer with NR PDCP according to User Scenario LTE4088-A#1.1
* ERAB has been converted into a Split Bearer according to User Scenario LTE4088-C#1.1
* Lte4873 is deactivated  (actSecRatRep =false)
* NR status of the LNRELGNBCELL is set to available
* EN-DC supports lteNrDualConnectSupport and NR PDCP Profile index nrPdcpProfidx parameters are configured for at least one OCI profile
* All radio modules are properly detected
* There are no unexpected alarms active

### References:

OM_LTE_SFS_RNL.28375, OM_LTE_SFS_RNL.28376, RRM_LTE_SFS_RRMT_15238, RRM_LTE_SFS_RRMT_6978, RRM_LTE_SFS_RRMT_15239, RRM_LTE_SFS_RRMT_15240

5G_RAN_USR_COM_16818, 5G_RAN_USR_COM_16819, 5G_CP_ARC_ALG_8706, 5G_CP_ARC_ALG_8711
5G_CP_ARC_ALG_8706; 5G_CP_ARC_ALG_8711; 5G_RAN_USR_COM_16818; 5G_RAN_USR_COM_16819;

## Test cases

### CB008745__LTE_cell_switch_on_off
TC will check LTE cell switch on/off due to power saving feature improvement
* Owner: mariusz.daniel@nokia.com
* Author: mateusz.guziana@nokia.com
* Maintainer: mateusz.guziana@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:

* eNB: LTE FDD/TDD RU
* UE: LTE capable UE
* eNB has as minimum one power group with at least two LTE cells
  * First LTE cell: lbpsCellSOOrder = 100.
  * Second LTE cell: lbpsCellSOOrder = 1.
* LTE1103 feature is activated for the BTS (actLBPowerSaving = 'True')
* Create loadSettings structure for every LTE cell
* Create PSGRP object under LNBTS
* Add at least two cells to "lbpsCellList"
* Add the same cells to "lbpsCellPeriodList"
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* Operator defines lbpsLastCellSOEnabled=false (only cells with lbpsCellSOOrder < 100 will be switched off)
* CB008745 feature is activated for the BTS (actLbpsCtrlLogicEnh = 'True')
* Operator defines lbpsMonWinForCellSOff, lbpsMonWinForCellSOn for the monitoring time of Cell Switch off/on. 
  * Note: lbpsMonWinForCellSOff default Value is 300, set lbpsMonWinForCellSOff as 60(minimal value) in this case. 
lbpsMonWinForCellSOn default Value is 120, set lbpsMonWinForCellSOn as 60 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=MinValueMethod
* Operator defines lbpsSOffTrRule=MaxValueMethod
* Operator defines lbpsCellSOMethod=cell Switch Off
* Operator defines lbpsLoadCalcMethod=Max(G_N_combined, P)
* Operator defines lbpsCellSOMethod=cell Switch Off
* Operator defines shutdownWindow=6
* Operator defines lbpsMinLoad=20
* Operator defines lbpsMaxLoad=50
* Operator defines lbpsPdcchLoadOffset=20

Syslog flags needed:
* #ENBC
  * 0x110001=1
  * 0x110002=1
  * 0x110003=1
  * 0x110004=1

Syslog filter: "pgLoadMaxGNCombined:"

After BTS restart wait till one LTE cell will be disabled due to power saving 


#### Test scenario defined by owner
* Step1: Attach UE1 and DL data call is started in first LTE cell belonging to power group.
* Step2: Attach UE2 to second LTE cell, make DL data call, deattach.
* Step3: UE1 DL data call is stopped in LTE first cell belonging to power group.


#### Pass Criteria
* Check point 1: pgLoadMaxGNCombined is above lbpsMaxLoad during next six load measurements (lbpsMonWinForCellSOn), then second LTE cell switch on procedure shall be started. 
  * Energy saving state: NotEnergySaving, Operational state: enabled
* Check point 2: Attach and data call is successfull
* Check point 3: pgLoadMaxGNCombined is below lbpsMinLoad during next six load measurements (lbpsMonWinForCellSOff), then second LTE cell switch off procedure shall be started
  * Energy saving state: EnergySaving, Operational state: disabled


#### Automatic TC steps
* Preconditions
* Step 1: Attach And Start DL Data Transfer In Power Group
* Step 2: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is NotEnergySaving
* Step 3: Trigger HO To Lte Cell
* Step 4: Await Data Transfer Finish In Power Group And Detach UE
* Step 5: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is EnergySaving


#### History of changes
* 09.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-986 - CB008745__LTE_cell_switch_on_off
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1110 - Adapt test cases from Optimus TL for robotws migration
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1147 - Optimize the number of files for Optimus
* 29.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1160 - Optimize the number of files for Optimus part 2


### CB008745__LTE_load_calculation
TC will check LTE load calculation when power saving feature improvement is enabled.

* Owner: mariusz.daniel@nokia.com
* Author: mateusz.guziana@nokia.com
* Maintainer: mateusz.guziana@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:
* eNB: LTE FDD/TDD RU
* UE: LTE capable UE
* eNB has as minimum one power group with at least two LTE cells
  * First LTE cell: lbpsCellSOOrder = 100.
  * Second LTE cell: lbpsCellSOOrder = 1.
* LTE1103 feature is activated for the BTS (actLBPowerSaving = 'True')
* Create loadSettings structure for every LTE cell
* Create PSGRP object under LNBTS
* Add at least two cells to "lbpsCellList"
* Add the same cells to "lbpsCellPeriodList"
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* Operator defines lbpsLastCellSOEnabled=false (only cells with lbpsCellSOOrder < 100 will be switched off)
* Set cellCapClass=100 for LTE cells - if both have equal BW
* Set nomNumPrbNonGbr=5 for LTE cells
* Set schedulWeight=5 for QCI9
* CB008745 feature is activated for the BTS (actLbpsCtrlLogicEnh = 'True')
* Operator defines lbpsMonWinForCellSOff, lbpsMonWinForCellSOn for the monitoring time of Cell Switch off/on.
  * Note: lbpsMonWinForCellSOff default Value is 300, set lbpsMonWinForCellSOff as 60(minimal value) in this case.
lbpsMonWinForCellSOn default Value is 120, set lbpsMonWinForCellSOn as 60 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=MinValueMethod
* Operator defines lbpsSOffTrRule=MaxValueMethod
* Operator defines lbpsLoadCalcMethod=Max(G, W, P)
* Operator defines lbpsCellSOMethod=cell Switch Off
* Operator defines shutdownWindow=6
* Operator defines lbpsMinLoad=15
* Operator defines lbpsMaxLoad=45
* Operator defines lbpsPdcchLoadOffset=20

Syslog flags needed:
* #ENBC
  * 0x110001=1
  * 0x110002=1
  * 0x110003=1
  * 0x110004=1

Syslog filter: "pgLoadMacGWP" and "pgLoadMaxGNCombined:"


#### Test scenario defined by owner
* Step1: Attach UE1 and DL data call is started with max tput in LTE cell belonging to power group. Duration 240s.
* Step2: Deattach UE1.
* Step3: Change lbpsLoadCalcMethod=Max(G_N_combined, P), wait till second cell goes to energysaving state
* Step4: Attach UE1 and DL data call is started with max tput in LTE cell belonging to power group. Duration 240s.
* Step5: Deattach UE1.

#### Pass Criteria
* Check point 1: pgLoadMacGWP is 49 for one active cell, 24.5 for two active cells (need to check on target TL)
* Check point 2: Deattach successful
* Check point 3: Plan is accepted and activated
* Check point 4: pgLoadMaxGNCombined is 99 for one active cell, 49 for two active cells
* Check point 5: Deattach successful

#### Automatic TC steps
* Preconditions
* Step 1: Attach And Start DL Data Transfer In Power Group
* Step 2: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is NotEnergySaving
* Step 3: Await Data Transfer Finish In Power Group And Detach UE
* Step 4: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is EnergySaving
* Step 5: Change LbpsLoadCalcMethod for Power Group
* Step 6: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is EnergySaving
* Step 7: Attach And Start DL Data Transfer In Power Group
* Step 8: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is NotEnergySaving
* Step 9: Await Data Transfer Finish In Power Group And Detach UE
* Step 10: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is EnergySaving
    

#### History of changes
* 15.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-990 - CB008745__LTE_load_calculation
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1110 - Adapt test cases from Optimus TL for robotws migration
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1147 - Optimize the number of files for Optimus
* 29.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1160 - Optimize the number of files for Optimus part 2

### CB008745__LTE_TX_patch_switch_on_off
TC will check LTE TX patch switch on/off due to power saving feature improvement

* Owner: mariusz.daniel@nokia.com
* Author: mateusz.guziana@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:
* eNB: LTE FDD/TDD RU
* UE: LTE capable UE
* eNB has as minimum one power group with at least one LTE cell
* LTE cell: lbpsCellSOOrder = 1.
* Cell MIMO 4x4
* LTE1203 feature is activated for the BTS (actLBRTXPowerSaving = 'True')
* Create loadSettings structure for every LTE cell
* Create PSGRP object under LNBTS
* Add one cell to "lbpsCellList"
* Add cell to "lbpsCellPeriodList"
* Set lbpsLastCellSOEnabled='true'
* Set cellCapClass=100 for LTE cell
* Set nomNumPrbNonGbr=10 for LTE cell
* Set schedulWeight=5 for QCI9
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* CB008745 feature is activated for the BTS (actLbpsCtrlLogicEnh = 'True')
* Operator defines lbpsMonWinForRtxSOff, lbpsMonWinForRtxSOn for the monitoring time of Cell Switch off/on. Note: lbpsMonWinForRtxSOff default Value is 300, set lbpsMonWinForRtxSOff as 30(minimal value) in this case. lbpsMonWinForRtxSOn default Value is 120, set lbpsMonWinForRtxSOn as 30 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=SlidingAverageMethod
* Operator defines lbpsSOffTrRule= SlidingAverageMethod
* Operator defines lbpsLoadCalcMethod= Max(G, W, P)
* Operator defines lbpsCellSOMethod=Tx Paths Switch Off
* Operator defines shutdownWindow=6
* Operator defines lbpsRTXMinLoad=16
* Operator defines lbpsRTXMaxLoad=45
* Operator defines lbpsLastCellRTXMinLoad=15
* Operator defines lbpsRTXCellCapOffset=50
* Operator defines lbpsPdcchLoadOffset=20
* Operator defines actOnlineTXSwitch='true'

Syslog flags needed:

* #ENBC
  * 0x110001=1
  * 0x110002=1
  * 0x110003=1
  * 0x110004=1

Syslog filter: "MinLoad:" and "MaxLoad:"


After BTS restart wait till half TXes in LTE cell will be disabled due to power saving.


#### Test scenario defined by owner
* Step1: Attach UE and DL data call is started in LTE cell belonging to power group.
* Step2: UE1 DL data call is stopped in LTE first cell belonging to power group.

#### Pass Criteria
* Check point 1: MaxLoad is above lbpsRTXMaxLoad. LTE TX patch switch on procedure shall be started. 
  * Energy saving state: NotEnergySaving, Operational state: enabled
* Check point 2: MinLoad is below lbpsRTXMinLoad after switch off. LTE TX patch switch off procedure shall be started.
  * Energy saving state: ReducedEnergySaving, Operational state: enabled

#### Automatic TC steps
* Preconditions
* Step 1: Attach And Start DL Data Transfer
* Step 2: Check Admin To Confirm That LTE Cell State Is notEnergySaving
* Step 3: Await Data Transfer Finish
* Step 4: Check Admin To Confirm That LTE Cell State Is ReducedEnergySaving

#### Test case developer notes
* With the transfer of the test to TL Beamskupin, many changes have been made. The changes include:
  * Change the layout of the TC into separate steps
  * Removing some KWs that used to be added to TC but are in ca_IWK and ca_INTER_RAT. Keywords like Check Energy Saving State For NR Cell and Get Time From BTS
  * Changed parameter to recommission to make it proper for Beamskupin SCF
  * Verifing of average throughput that was performed during test was changed to verifing of average throughput that was performed before energy saving state was changed to notEnergySaving because it gives more info about that part of the test. Verifing of average throughput that was performed after energy saving state was changed to measure it after it happened, not after predetermined time like it was.
  * Removed Analyze Power Group Load From Syslog For CB008745 from test because it was not working due to Syslog changes. The developer informed that we should not pass this TC based on syslog logs.
  * Due to problems with NR NSA attach there was added option to do the test just with LTE. After solving problem with NSA it is no longer in use but it was left in code and can be activated after changing ${LTE_ONLY} to True.
  * TL Beamskupin's version of this test case is in file CB008745__LTE_TX_patch_switch_on_off_TL_Beamskupin.robot

#### History of changes
* 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-988 - CB008745__LTE_TX_patch_switch_on_off
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1110 - Adapt test cases from Optimus TL for robotws migration
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1147 - Optimize the number of files for Optimus
* 29.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1160 - Optimize the number of files for Optimus part 2
* 26.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1275 - Adapt test case to work on Beamskupin TL



### CB008745__NR_cell_switch_on_off
TC will check NR cell switch on/off due to power saving feature improvement

* Owner: mariusz.daniel@nokia.com
* Author: mateusz.guziana@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:
* gNB: NR FDD/TDD RU
* UE: NR capable UE
* gNB has as minimum one power group with at least two NR cells 
  * First NR cell: lbpsCellSOOrder = 100.
  * Second NR cell: lbpsCellSOOrder = 1.
* 5GC000431 feature is activated for the BTS (actNrLBPowerSaving = 'True')
* Create NRPGRP object under NRBTS
* Add two cells to lbpsCellList
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* CB008745 feature is activated for the NRBTS (actLbpsCtrlLogicEnh = 'True')
* Operator defines lbpsMonWinForCellSOff, lbpsMonWinForCellSOn for the monitoring time of Cell Switch off/on.
  * Note: lbpsMonWinForCellSOff default Value is 300, set lbpsMonWinForCellSOff as 60(minimal value) in this case.
lbpsMonWinForCellSOn default Value is 120, set lbpsMonWinForCellSOn as 60 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=SlidingAverageMethod
* Operator defines lbpsSOffTrRule=SlidingAverageMethod
* Operator defines lbpsLoadCalcMethod=Max(G, C, P)
* Operator defines lbpsSOMethod=cell switch off
* Operator defines shutdownWindow=6
* Operator defines lbpsMinLoad=16
* Operator defines lbpsMaxLoad=80

Syslog flag needed:

* #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
  * 0x590072=1

Syslog filter: "pgLoadAverCellSwitchOn:" and "pgLoadAverCellSwitchOff:"

After BTS restart wait till second NR cell in power group will be disabled due to power saving 

#### Test scenario defined by owner
* Step1: Attach UE1 and DL data call is started in first NR cell belonging to power group.
* Step2: Attach UE2 to second NR cell, make DL data call, deattach.
* Step3: UE1 DL data call is stopped in NR first cell belonging to power group.

#### Pass Criteria
* Check point 1: pgLoadAverCellSwitchOn is above lbpsMaxLoad then second NR cell switch on procedure shall be started.
  * Energy saving state: NotEnergySaving, Operational state: enabled
* Check point 2: Attach and data call is successfull
* Check point 3: pgLoadAverCellSwitchOff is below lbpsMinLoad after switch off, then second NR cell switch off procedure shall be started
  * Energy saving state: EnergySaving, Operational state: disabled


#### Automatic TC steps
* Preconditions
* Step 1: Attach And Start DL Data Transfer
* Step 2: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is notEnergySaving
* Step 3: Trigger HO To 2nd Cell
* Step 4: Await Data Transfer Finish
* Step 5: Check Measurements In Syslog And Admin To Confirm That 2nd Cell State Is energySaving

#### Test case developer notes
* With the transfer of the test to TL Beamskupin, many changes have been made. The changes include:
  * Change the layout of the TC into separate steps
  * Removing some KWs that used to be added to TC but are in ca_IWK and ca_INTER_RAT. Keywords like Check Energy Saving State For NR Cell and Get Time From BTS
  * Changed parameter to recommission to make it proper for Beamskupin SCF
  * Verifing of average throughput that was performed during test was changed to verifing of average throughput that was performed before HO because it's gives more info about that part of the test. Verifing of average throughput that was performed after HO was changed to measure it after it happened, not after predetermined time like it was.
  * TL Beamskupin's version of the test case is in file CB008745__NR_cell_switch_on_off_TL_Beamskupin.robot

#### History of changes
* 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-987 - CB008745__NR_cell_switch_on_off
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1110 - Adapt test cases from Optimus TL for robotws migration
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1147 - Optimize the number of files for Optimus
* 29.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1160 - Optimize the number of files for Optimus part 2
* 26.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1275 - Adapt test case to work on Beamskupin TL
* 10.06.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1498 - Added parameter "buffer=32M" to Start Data Transfer KW



### CB008745_CB012123_NR_cell_switch_on_off_TL_TMO_US
TC will check NR cell switch on/off due to power saving feature improvement on TL TMO_US with additional parameter 'lbpsMonWinForCellSOn' which was delivered within CB012123.


* Owner: mariusz.daniel@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:
* gNB: NR FDD/TDD RU
* UE: NR capable UE
* gNB has as minimum one power group with at least two NR cells 
  * First NR cell: lbpsCellSOOrder = 100.
  * Second NR cell: lbpsCellSOOrder = 1.
* 5GC000431 feature is activated for the BTS (actNrLBPowerSaving = 'True')
* Create NRPGRP object under NRBTS
* Add two cells to lbpsCellList
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* CB008745 feature is activated for the NRBTS (actLbpsCtrlLogicEnh = 'True')
* CB012123 parameter 'lbpsMonWinForCellSOn' should be configured
* Operator defines lbpsMonWinForCellSOff, lbpsMonWinForCellSOn for the monitoring time of Cell Switch off/on.
  * Note: lbpsMonWinForCellSOff default Value is 300, set lbpsMonWinForCellSOff as 60(minimal value) in this case.
lbpsMonWinForCellSOn default Value is 120, set lbpsMonWinForCellSOn as 60 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=SlidingAverageMethod
* Operator defines lbpsSOffTrRule=SlidingAverageMethod
* Operator defines lbpsLoadCalcMethod=Max(G, C, P)
* Operator defines lbpsSOMethod=cell switch off
* Operator defines shutdownWindow=6
* Operator defines lbpsMinLoad=16
* Operator defines lbpsMaxLoad=80

Syslog flag needed:

* #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
  * 0x590072=1

Syslog filter: "pgLoadAverCellSwitchOn:" and "pgLoadAverCellSwitchOff:"

After BTS restart wait till second NR cell in power group will be disabled due to power saving 

#### Test scenario defined by owner
* Step1: Attach UE1 and DL data call is started in first NR cell belonging to power group.
* Step2: Attach UE2 to second NR cell, make DL data call, deattach.
* Step3: UE1 DL data call is stopped in NR first cell belonging to power group.

#### Pass Criteria
* Check point 1: pgLoadAverCellSwitchOn is above lbpsMaxLoad then second NR cell switch on procedure shall be started.
  * Energy saving state: NotEnergySaving, Operational state: enabled
* Check point 2: Attach and data call is successfull
* Check point 3: pgLoadAverCellSwitchOff is below lbpsMinLoad after switch off, then second NR cell switch off procedure shall be started
  * Energy saving state: EnergySaving


#### Automatic TC steps
* Preconditions
* Step 1: Start DL Data Transfer In First NR Cell Belonging To Power Group
* Step 2: Check That NR Cell ${NR_CELL_ID2} State Is NotEnergySaving
* Step 3: Check That NR Cell ${NR_CELL_ID2} Is Accessible For Data Transfer
* Step 4: Stop DL Data Transfer In First NR Cell Belonging To Power Group
* Step 5: Check That NR Cell ${NR_CELL_ID2} State Is EnergySaving

#### Test case developer notes
* TL TMO's version of the test case is in file CB008745_CB012123_NR_cell_switch_on_off_TL_TMO_US.robot
* Parameter Load-based PS monitoring window for cell switch on 'lbpsMonWinForCellSOn' should be configured in SCF

#### History of changes
* 24.09.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1352 - initial creation

### CB008745__NR_load_calculation
TC will check NR load calculation when power saving feature improvement is enabled.

* Owner: mariusz.daniel@nokia.com
* Author: mateusz.guziana@nokia.com
* Maintainer: mateusz.guziana@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:

* gNB: NR FDD/TDD RU
* UE: NR capable UE
* gNB has as minimum one power group with at least two NR cells
  * First NR cell: lbpsCellSOOrder = 100.
  * Second NR cell: lbpsCellSOOrder = 1.
* 5GC000431 feature is activated for the BTS (actNrLBPowerSaving = 'True')
* Create NRPGRP object under NRBTS
* Add two cells to lbpsCellList
* The local time is within a valid (not suspended) power group load-based power saving period - please add every day to "lbpsPeriodList"
* CB008745 feature is activated for the BTS (actLbpsCtrlLogicEnh = 'True')
* Operator defines lbpsMonWinForCellSOff, lbpsMonWinForCellSOn for the monitoring time of Cell Switch off/on.
  * Note: lbpsMonWinForCellSOff default Value is 300, set lbpsMonWinForCellSOff as 60(minimal value) in this case.
lbpsMonWinForCellSOn default Value is 120, set lbpsMonWinForCellSOn as 60 (minimal value) in this case.
* Operator defines lbpsSOnTrRule=MinValueMethod
* Operator defines lbpsSOffTrRule=MaxValueMethod
* Operator defines lbpsLoadCalcMethod=Max(G, C, P)
* Operator defines lbpsSOMethod=cell switch off
* Operator defines shutdownWindow=6
* Operator defines lbpsMinLoad=15
* Operator defines lbpsMaxLoad=80

Syslog flag needed:

* #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
  * 0x590072=1

Syslog filter: "pgLoad:"

#### Test scenario defined by owner
* Step1: Attach UE1 and DL data call is started with max tput in NR cell belonging to power group. Duration 240s.
* Step2: Deattach UE1.
* Step3: Change lbpsLoadCalcMethod=Max(G_N_combined, P), wait till second cell goes to energysaving state
* Step4: Attach UE1 and DL data call is started in NR cell belonging to power group. Duration 240s.
* Step5: Deattach UE1.

#### Pass Criteria
* Check point 1: pgLoad is 100 for one active cell, 50 for two active cells (need to check on target TL)
* Check point 2: Deattach successful
* Check point 3: Plan is accepted and activated
* Check point 4: pgLoad is 100 for one active cell, 50 for two active cells
* Check point 5: Deattach successful

#### Automatic TC steps
* Preconditions
* Step 1: Attach And Start DL Data Transfer In Power Group
* Step 2: Check Measurements In Syslog And Admin To Confirm That Nr Cell State Is notEnergySaving
* Step 3: Await Data Transfer Finish In Power Group And Detach UE
* Step 4: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is energySaving
* Step 5: Change LbpsLoadCalcMethod for Power Group
* Step 6: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is energySaving
* Step 7: Attach And Start DL Data Transfer In Power Group
* Step 8: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is notEnergySaving
* Step 9: Await Data Transfer Finish In Power Group And Detach UE
* Step 10: Check Measurements In Syslog And Admin To Confirm That Lte Cell State Is energySaving

#### History of changes
* 15.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-989 - CB008745__NR_load_calculation
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1110 - Adapt test cases from Optimus TL for robotws migration
* 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1147 - Optimize the number of files for Optimus
* 29.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1160 - Optimize the number of files for Optimus part 2
