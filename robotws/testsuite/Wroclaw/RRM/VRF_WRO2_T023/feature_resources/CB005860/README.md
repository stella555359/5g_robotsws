# CB005860 - NR DL peak rate increase in DSS
Robot test suite for feature CB005860.

## Test line requirements
This section is taken from automation requests done by Mariusz Daniel.

### Example configuration
Configuration will be the same as for LTE4750 tests.

### Required initial BTS state (not to be checked but provided directly from SCF)

#### LTE
* Six LTE cells configured, three with DSS disabled all the time (cells unlocked) and three where DSS phase 3 is set
(cells unlocked).

* All cells are unlocked LTE cell is up and running in FDD mode with correct software load supporting this
feature.
* RF sharing between LTE and NR with two CPRI links.
* LTE1710 'Sync Hub Direct Forward' and LTE4461 'NR-LTE FDD concurrent operation for CPRI RUs' is configured between gNb and eNb
* EN-DC is configured between:
  * LTE cell (PCell), that is not the LTE cell that is nominated to share the spectrum with an NR cell,
  * NR cell (PSCell), that is going to share the spectrum with the LTE cell
* lteNrDssDlRatio/ minNrDssRatio= 5
* lteNrDssDlRatio/ maxNrDssRatio = 100
* lteNrDssUlRatio/ minNrDssRatio= 5
* lteNrDssUlRatio/ maxNrDssRatio = 70
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/blankedPucch is set to 0
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/selectOuterPuschRegion  is set to 'None'
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/APUCCH_FDD/selectPrachRegion is not set to 'InnerUpperEdge'
* LNBTS/actLteNrDss = true
* For each cell that should be used as LTE DSS partner cell:
  * LNCEL/lteNrDssMode = DSS_Phase_III
  * LNCEL/DSSNR is set in accordance with values and ranges available in the NIDD
* MRBTS/LNBTS/otdoaProfileList/otdoaPhaseErrorThreshold = 1500
* MRBTS/LNBTS/otdoaProfileList/otdoaSyncSourceType = TOP-P
* Cell 1: 
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 7
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames = 1
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB
* Cell 2:
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 47
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames =1
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB
* Cell 3:
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 151
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames = 2
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB


#### 5G
* gNb operational.
* A cell is configured as shared NR cell.
* Cells are unlocked.
* List of features to be activated on NR side:
  * 5GC000474 X2 Management for NSA mode 3x operation
  * 5GC000577 TRS Support of NSA interfaces (X2 and S1-U) over IPv4 / IPv6
  * 5GC000475 SgNB Addition and Release for NSA mode 3x operation
  * 5GC000570 5G - LTE flow control at X2
  * 5GC000482 UE capability handling for NSA mode 3x operation
  * 5GC000543 Ciphering of U-Plane (NSA option 3x)
  * 5GC000480 Radio Admission Control for NSA mode 3x operation
  * 5GC000479 UE inactivity handling for NSA mode 3x operation
* 5GC001904 enabled.
* All three NR cells configured correctly, sharing enabled on cell level.
* lteNrDssDlRatio/ minNrDssRatio= 5
* lteNrDssDlRatio/ maxNrDssRatio = 100
* lteNrDssUlRatio/ minNrDssRatio= 5
* lteNrDssUlRatio/ maxNrDssRatio = 70
* Shared NR cells are unlocked.
* gNb in sync with eNb.
* MRBTS/NRBTS/actLteNrDss = true
* MRBTS/NRBTS/NRCELL/lteNrDssMode = DSS_Phase_3

## Test cases

### IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860
The purpose of this test case is to check LTE DSS performance in downlink with 10MHz and 95% sharing ratio for feature CB005860.

* Owner: mariusz.daniel@nokia.com
* Author: mariusz.makuch@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:

eNB:
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/minNrDssRatio=95
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/maxNrDssRatio=95
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/minNrDssRatio=50
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/maxNrDssRatio=50
* MRBTS/LNBTS/LNCEL/maxCrPgDl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRa4Dl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRaDl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRaDlHo=0.5
* MRBTS/LNBTS/LNCEL/maxCrSibDl=0.5

gNB: 
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/minNrDssRatio=95
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/maxNrDssRatio=95
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=50
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=50

#### Test scenario defined by owner
* Step 1: eNB and gNB and all cells are onAir
* Step 2: Start NR call with DL oriented tput.
* Step 3: Start LTE DSS call with DL oriented tput
* Step 4: Get TTI Trace from 10s period
* Step 5: Stop LTE DSS call with DL oriented tput.

#### Pass Criteria
* Shared NR and LTE cells are onAir
* No unexpected faults
* Expected performance
    - EN-DC: MINIMUM (Target - 20%) check after dry run
    - LTE: MINIMUM (Target - 20%) check after dry run

#### Automatic TC steps
* Preconditions
* Step 1: Change DSS Related Parameters On eNB Side
* Step 2: Change DSS Related Parameters On gNB Side
* Step 3: Perform 5G DL Data Transfer
* Step 4: Perform LTE DL Data Transfer
* Step 5: Stop 5G Data Transfer

#### History of changes
* 30.09.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-722 - Initial creation
* 29.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-775 - Removed 'Wait Until Keyword Succeeds  5m  10s  Verify BTS States' in step 1
* 11.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-831 - Changed maintainer
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-914 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-973 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
               with 'Collect 4G TTI Trace'
* 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1046 - adding variable "${BLANKED_PUCCH}"
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'
* 12.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1122 - TC adaptation to Karlowice TL
* 25.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1192 - TC adaptation to Klecina TL
* 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1484  Increased timeout for Detach_UE KW
* 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1808  Adding apn parametr to Start data transfer KW

### IWK__ul_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_70__CB005860
The purpose of this test case is to check LTE DSS performance in uplink with 10MHz and 70% sharing ratio for feature CB005860.

* Owner: mariusz.daniel@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:

eNB:
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/minNrDssRatio=95
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/maxNrDssRatio=95
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/minNrDssRatio=70
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/maxNrDssRatio=70
* MRBTS/LNBTS/LNCEL/maxCrPgDl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRa4Dl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRaDl=0.5
* MRBTS/LNBTS/LNCEL/maxCrRaDlHo=0.5
* MRBTS/LNBTS/LNCEL/maxCrSibDl=0.5

gNB: 
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/minNrDssRatio=95
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/maxNrDssRatio=95
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=70
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=70

#### Test scenario defined by owner
* Step 1: eNB and gNB and all cells are onAir
* Step 2: Start NR call with UL oriented tput.
* Step 3: Start LTE DSS call with UL oriented tput
* Step 4: Get TTI Trace from 10s period
* Step 5: Stop LTE DSS call with UL oriented tput.

#### Pass Criteria
* Shared NR and LTE cells are onAir
* No unexpected faults
* Expected performance
    - EN-DC: MINIMUM (Target - 20%) check after dry run
    - LTE: MINIMUM (Target - 20%) check after dry run

#### Automatic TC steps
* Preconditions
* Step 1: Change DSS Related Parameters On eNB Side
* Step 2: Change DSS Related Parameters On gNB Side
* Step 3: Perform 5G UL Data Transfer
* Step 4: Perform LTE UL Data Transfer
* Step 5: Stop 5G Data Transfer

#### History of changes
* 30.09.2021 - https://jiradc.int.net.nokia.com/browse/IWK-723 - Initial creation
* 29.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-775 - Modificated value '${min_nr_dss_ratio_ul}'  65 instead of  70
                                                                 removed 'Wait Until Keyword Succeeds  5m  10s  Verify BTS States' in step 1
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-915 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-973 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
               with 'Collect 4G TTI Trace'
* 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1046 - adding variable "${BLANKED_PUCCH}"
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'
* 12.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1122 - TC adaptation to Karlowice TL
* 25.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1192 - TC adaptation to Klecina TL
* 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1484  Increased timeout for Detach_UE KW
* 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1808  Adding apn parametr to Start data transfer KW

### IWK__interworking_with_CMAS_and_ETWS_emergency_switching__CB005860
Purpose of this test case is to check emergency switching procedure for CB005860 feature
when LTE494 CMAS (Commercial Mobile Alert System)
and LTE843 ETWS (Earthquake and Tsunami Warning System) massage is received by eNB.


#### Test specific Preconditions
* On eNB side:
  * MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/minNrDssRatio=90
  * MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/maxNrDssRatio=90
  * The etwsPrimNotifBcDur parameter should be set from default 60 to 240 - in order to make checking the counter possible within automated test
* On gNB side:
  * MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/minNrDssRatio=90
  * MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/maxNrDssRatio=90
* Before testing, one should add cell from production test line to the CMAS/ETWS system (CBC),
  this ticket can be use as template: https://srvjira.ext.net.nokia.com/browse/SRNSUP-101547,
  also one can check with this instruction:
  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1046771116

* Owner: monika.gabrowska@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step1: Load delta plan with below parameter, validate and activate it. - no unexpected alarms/faults.
  Parameter name: actCMAS, Parameter Value: true, Managed object:MRBTS/LNBTS
* Step2: Start 5G DL oriented traffic in one shared cell - call is ongoing.
* Step3: Wait at least 3 min - sharing ratio is going to increase.
* Step4: Login to CMAS/ETWS simulator and set messages ID = 4370 (CMAS).
* Step5: Start triggering CMAS massage from simulator to eNB cell - CRM is going to work in emergency mode.
* Step6: Collect M8029C217 counter - counter is collected.
* Step7: Kill CMAS massage on simulator - CRM returns back to running mode.
* Step8: Wait at least 3 min - sharing ratio is going to increase.
* Step9: Collect M8029C217 counter - counter is collected.
* Step10: Load delta plan with bellow parameter, validate and activate it. - no unexpected alarms/faults.
  Parameter name: actETWS, Parameter Value: true, Managed object: MRBTS/LNBTS
  Parameter name: actCMAS, Parameter Value: false, Managed object: MRBTS/LNBTS
* Step11: Start 5G DL oriented traffic in one shared cell - call is ongoing.
* Step12: Wait at least 3 min - sharing ratio is going to increase.
* Step13: Login to CMAS/ETWS simulator and set messages ID=4356 (ETWS).
* Step14: Start triggering ETWS massage from simulator to eNB cell - CRM is going to work in emergency mode.
* Step15: Collect M8029C217 counter - counter is collected.
* Step16: Wait 3 min - ETWS massage expires and CRM returns to running mode.
* Step17: Wait at least 3 min - sharing ratio is going to increase.
* Step18: Collect M8029C217 counter - counter is collected.
* Step19: Load delta plan with bellow parameter, validate and activate it. - no unexpected alarms/faults.
  Return to “standard” SCF configuration.
  Parameter name: actETWS, Parameter Value: false, Managed object: MRBTS/LNBTS

#### Pass criteria
* Step1: No unexpected alarms/faults. All cells onAir.
* Step3: Parameter crmStatus = emergency (MRBTS/LNBTS/LNCEL/DSSNR-0/CRMINFO-0/).
* Step6: Counter M8029C217 value is 35.
* Step7: Parameter crmStatus = running.
* Step9: Counter M8029C217 value is 88.
* Step10: No unexpected alarms/faults. All cells onAir.
* Step12: Parameter crmStatus = emergency.
* Step15: Counter M8029C217 value is 35.
* Step16: Parameter crmStatus = running.
* Step18: Counter M8029C217 value is 88.
* Step19. No unexpected alarms/faults. All cells onAir.

#### Automatic TC steps
* Preconditions
* Step 1: Activate CMAS On eNB
* Step 2: Start NR DL
* Step 3: Check If CRM Has Value running
* Step 4: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_BEFORE_AFTER_MSG}
* Step 5: Login To CBE Simulator And Set CMAS Message
* Step 6: Start Triggering CMAS Message From Simulator To eNB Cell
* Step 7: Check If CRM Has Value emergency
* Step 8: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_DURING_MSG}
* Step 9: Kill CMAS Message On Simulator
* Step 10: Check If CRM Has Value running
* Step 11: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_BEFORE_AFTER_MSG}
* Step 12: Deactivate CMAS And Activate ETWS On eNB
* Step 13: Check If CRM Has Value running
* Step 14: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_BEFORE_AFTER_MSG}
* Step 15: Login To CBE Simulator And Set ETWS Message
* Step 16: Start Triggering ETWS Message From Simulator To eNB Cell
* Step 17: Check If CRM Has Value emergency
* Step 18: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_DURING_MSG}
* Step 19: Wait Until ETWS Message Expires
* Step 20: Check If CRM Has Value running
* Step 21: Collect M8029C217 Counter And Check If Its Value Is ${COUNTER_BEFORE_AFTER_MSG}
* Step 22: Deactivate ETWS On eNB

#### Developer test case notes
* This test is using cbe script, sometimes there is some issue with script running from TC.
Manually it's working fine, but automate returns this after TC run:
>>There already is a 'cbe' active, please close it first...

If so, then please reboot the server of this script.

#### History of changes
* 16.09.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-712 - Initial creation
* 23.09.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-729 - Fixed snapshot collecting
* 14.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-792 - Change ETWS channel to 4353
* 06.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-949 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-973 - Moved documentation to robotws
* 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1043 - changed  MCC-244/MNC-08 to MCC-001/MNC-01
* 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1046 - adding two variables  MCC and MNC
* 13.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1058 - Changing duration time for checking if CRM changed status
