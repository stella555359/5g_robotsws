#  CB008322 Sounding-based downlink short-term sub-band beamforming for NR FR1-TDD

## Test line requirements
* Real SBTS environment.
* RU that supports CB009496.
* 4 Real UEs with TAS SRS capability 2T4R or 1T4R or 4T4R,
  It was agreed with the FO that the automatic TC would be simplified to 2 UEs
* Sea Container/OTA Wall/Phase Shifter.
* The number of steps has also been reduced to cover only 2 UEs


### Example configuration
ASIL + ABIO/ABIP
RMODs AQQE/AQQL
Massive MIMO radio modules supported NR cells

### Required initial BTS state 
All required files are provided in prepared files available in testline_configuration repository:
* SCF for configuration ASIL+ABIO+ABIP and AQQL+2xAQQE created at release 24R2
* Parameters provided in SCF:
  * srsForBeamMgmt : all parameters inside item
  * subbandDm, maxnumUE, srsSwitch, sinrTreshold, cbcTasConflictPolicy
  * rankThreshold, rankHysteresis
  * prbRatioThreshold, prbRatioHysteresis
  * wbSrsPowerThreshold, wbSrsPowerHysteresis
* Phase Shifter configuration file
* Script to optical switch Leoni used for changing RMODs connection beetwen BBMODs



## Test cases

### CB008322-G_Beamforming_counters_verification
* This test case will verify new and legacy counters for CB008322 feature.

#### Test specific Preconditions
* CB008322-B#3 Wide band TAS SRS configuration algorithm must be delivered.
* Parameters are set the same as CB008322-B#3.
* CB008322 is activated (actDlSrsSubbandBm=true).
* DlSrs and UlSrs BF always ON

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
* Step 1: 
Description: Enable all counters group
Expected: Counters enabled and reported in WebEM
* Step 2:
Description: 1x 8247/1086 with TAS 
Expected: L3Call tested but without condition to switch SB SRS to WB SRS
* Step 3:
Description: 1x 8247/1086 with TAS + 1x 8322 UE
Expected: L3Call tested but 1xUE without condition to switch SB SRS to WB SRS, and one with WB SRS
* Step 4:
Description: 2x 8247/1086 with TAS + 2x 8322 UE
Expected: L3Call tested but 2xUE without condition to switch SB SRS to WB SRS, and 2xUE with WB SRS
* Step 5:
Description: 4x 8322 UEs - various power level, 1 UE to rank 3 for short time
Expected: L3Call tested with all 4 UEs with WB SRS
* Step 6:
Description: 1x SSB UE + 1x 8247 UE non-TAS
Expected: L3Call tested with SSB BF UE and nonTAS UE
* Step 7:
Description: Activated power saving feature (8133)  and add 2UE with 8322
Expected: L3Call tested with power saving, both has WBSRS and subband BF but after power saving enabling WBSRS 
is still in use but with DFT beams
* Step 8:
Description: Check counters value for all groups
Expected: Values are correctly updated according to 8322 technical.xlsx (sharepoint.com)

#### Pass criteria
* The UEs are connected to the cell.
* Counter values are correctly updated according to 8322 technical.xlsx (sharepoint.com)
* No unexpected faults appeared

#### Automatic TC steps
* Preconditions
* Step 1: Start Low DT For First UE
* Step 2: Collect Counters And BIP Logs For SB SRS Call
* Step 3: Analyze Counters For SRS Call
* Step 4: Start High DT For Second UE
* Step 5: Collect Counters And BIP Logs For SB And WB SRS Calls
* Step 6: Analyze Counters For SB And WB SRS Calls

### Developer notes
* Step 2 description: "1x 8247/1086 with TAS" means start low data transfer,
  to ensure UE reach 8247/1086 mode (in our configuration low tput means ~50Mbps)
* Step 3 description: "Description: 1x 8247/1086 with TAS + 1x 8322 UE" means start low data transfer
  at 1x UE to reach 8247/1086 and high data transfer (~1.5Gbps) for 1 UE to ensure 8322 mode
* to cover the CB012449 feature, two counters (M55371C00192 and M55371C00159) have been removed from the list of counters.

#### History of changes
* 31.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1198 - Initial creation
* 29.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1221 - Adjustment to SCF with RMODs connected to ABIO
* 14.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1229 - Improvements in counters checking
* 12.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1267 - Moving config preparation to testsuite
* 28.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1366 - Some impromevents to coverage CB008322+CB012449 features

### CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK
This test case will cover fallback scenario with reduction numOfLayers (RANK) 
and check corresponding R&D SB_BF_CONF_REL_RANK counter.

#### Test specific Preconditions
* Parameters set during test, provided by TC owner:
* channelStabilityHysteresis=10
* channelStabilityThreshold=30
* enableSbSrsVolatilityCheck=false
* maxWbSbSwitch=10
* numWbSrsConfigSample=100
* numWbSrsReleaseSample=100
* prbRatioHysteresis=20
* prbRatioThreshold=50
* prbSampleHighLowPercentage=60
* rankHysteresis=1
* rankThreshold=4
* rlqBadPercentage=50
* rlqGoodPercentage=20
* seHysteresis=50
* seThreshold=91
* sortingMetric=DL Spectral Efficiency
* wbSrsConfigProhibitTimer=100
* wbSrsPowerHysteresis=2
* wbSrsPowerThreshold=-130
* srsPowerThresholdForDlBm=-150
* srsPowerThreshold==-150

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
The number of repetitions was agreed with the owner at 5

* Step 1: 
Description: Setup 8322 (WB SRS) call (4 rank)
Expected: Call is ongoing with stable value of rank4
* Step 2:
Description: Change rank from 4 to 2 by setting attenuation at two layers on PS to 90dBm 
Expected: Attenuation changed successful, call is ongoing with stable value of rank2
* Step 3:
Description: Change rank from 2 to 4 by reducing attenuation on PS
Expected: Attenuation changed successful, call is ongoing with stable value of rank4
* Steps2-3 should be repeated x times
* Step 4:
Description: check counter M55330CRD50010 - its value should be equal to number of steps with reduction (step2)
Expected: Value of counter M55330CRD50010 is visible and equal to number of steps with reduction

#### Pass criteria
* The UE is connected to the cell
* Call is going without interruption
* Counter values are correctly updated
* No unexpected faults appeared

#### Automatic TC steps
* Preconditions
* Step 1: Start High Data Transfer
* Looped Steps For SB_BF_CONF_REL_RANK
  * Step 2: Check If RANK4 Was Reached Before_reduction
  * Step 3: Set Attenuation At Two Phase Shifter Outputs
  * Step 4: Check If RANK2 Was Reached With_reduced
  * Step 5: Collect BIP Logs For Rank2
  * Step 6: Reduce Attenuation At Two Phase Shifter Outputs
  * Step 7: Check If RANK4 Was Reached After_reduction
  * Step 8: Collect BIP Logs For Rank4
* Step 9: Wait Required Period And Collect RD Counters
* Step 10: Stop Data Transfer
* Step 11: Analyze SB_BF_CONF_REL_RANK Counter

### Developer notes
* 8322 (WB SRS) call means high DL data transfer (~1.5Gbps) for UE
* Keywords used in this test case come from the resource CB008322-G2_Enhancement_for_dynamic_fallback_keywords.robot
* In order to save disk space it was agreed that BIP logs would be collected only in first loop iteration

#### History of changes
* 26.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1252 - Initial creation
* 28.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1366 - added missing parameters to delta recommissioning
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.

### CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB
This test case will cover fallback scenario with reduction tput value 
and check corresponding R&D SB_BF_CONF_REL_SCHED_PRB counter.

#### Test specific Preconditions
* Parameters set during test, provided by TC owner:
* channelStabilityHysteresis=0
* channelStabilityThreshold=0
* enableSbSrsVolatilityCheck=false
* maxWbSbSwitch=10
* numWbSrsConfigSample=10
* numWbSrsReleaseSample=10
* prbRatioHysteresis=30
* prbRatioThreshold=70
* prbSampleHighLowPercentage=100
* rankHysteresis=1
* rankThreshold=1
* rlqBadPercentage=100
* rlqGoodPercentage=100
* seHysteresis=0
* seThreshold=0
* sortingMetric=DL Spectral Efficiency
* wbSrsConfigProhibitTimer=100
* wbSrsPowerHysteresis=2
* wbSrsPowerThreshold=-130
* srsPowerThresholdForDlBm=-150
* srsPowerThreshold==-150

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
The number of repetitions was agreed with the owner at 5

* Step 1: 
Description: Setup 8322 (WB SRS) call
Expected: Call is ongoing
* Step 2:
Description: Reduce tput to use 30% of available PRBs 
Expected: Tput reduced, call is ongoing
* Step 3:
Description: Bring back full tput
Expected: Full tput reached, call is ongoing
* Steps2-3 should be repeated x times
* Step 4:
Description: check counter M55330CRD50012 - its value should be equal to number of steps with reduction (step2)
Expected: Value of counter M55330CRD50012 is visible and equal to number of steps with reduction

#### Pass criteria
* The UE is connected to the cell
* Calls are going without interruption
* Counter values are correctly updated
* No unexpected faults appeared

#### Automatic TC steps
* Preconditions
* Step 1: Start High Data Transfer
* Looped Steps For SB_BF_CONF_REL_SCHED_PRB
  * Step 2: Start Low Data Transfer
  * Step 3: Stop High Data Transfer
  * Step 4: Collect BIP Logs For Low_DT
  * Step 5: Start High Data Transfer
  * Step 6: Stop Low Data Transfer
  * Step 7: Collect BIP Logs For High_DT
* Step 8: Wait Required Period And Collect RD Counters
* Step 9: Stop Data Transfer
* Step 10: Analyze SB_BF_CONF_REL_SCHED_PRB Counter

### Developer notes
* 8322 (WB SRS) call means high DL data transfer (~1.5Gbps) for UE
* Keywords used in this test case come from the resource CB008322-G2_Enhancement_for_dynamic_fallback_keywords.robot
* In order to save disk space it was agreed that BIP logs would be collected only in first loop iteration

#### History of changes
* 26.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1262 - Initial creation
* 07.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1309 - README.md update due change M55330CRD50004->M55330CRD50012
* 28.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1366 - added missing parameters to delta recommissioning

### CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER
This test case will cover fallback scenario with increasing and decreasing attenuation at all output ports 
and check corresponding R&D SB_BF_CONF_REL_SRS_POWER counter.

#### Test specific Preconditions
* Parameters set during test, provided by TC owner:
* channelStabilityHysteresis=10
* channelStabilityThreshold=30
* enableSbSrsVolatilityCheck=false
* maxWbSbSwitch=10
* numWbSrsConfigSample=100
* numWbSrsReleaseSample=100
* prbRatioHysteresis=20
* prbRatioThreshold=50
* prbSampleHighLowPercentage=60
* rankHysteresis=1
* rankThreshold=1
* rlqBadPercentage=50
* rlqGoodPercentage=20
* seHysteresis=50
* seThreshold=91
* sortingMetric=DL Spectral Efficiency
* wbSrsConfigProhibitTimer=100
* wbSrsPowerHysteresis=10
* wbSrsPowerThreshold=-95
* srsPowerThresholdForDlBm=-150
* srsPowerThreshold==-150

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
The number of repetitions was agreed with the owner at 5

* Step 1: 
Description: Setup 8322 (WB SRS) call
Expected: Call is ongoing
* Step 2:
Description: Increase attenuation on PS to reduce srs power bellow -110dBm
Expected: Attenuation changed successful, call is ongoing
* Step 3:
Description: Decrease attenuation on PS to original value
Expected: Attenuation changed successful, call is ongoing
* Steps2-3 should be repeated x times
* Step 4:
Description: check counter M55330CRD50013 - its value should be equal to number of steps with reduction (step2)
Expected: Value of counter M55330CRD50013 is visible and equal to number of steps with reduction

#### Pass criteria
* The UE is connected to the cell
* Call is going without interruption
* Counter values are correctly updated
* No unexpected faults appeared

#### Automatic TC steps
* Preconditions
* Step 1: Start High Data Transfer
* Looped Steps For SB_BF_CONF_REL_SRS_POWER
  * Step 2: Check If Srs Power Is Above Target
  * Step 3: Set Attenuation At All Phase Shifter Outputs
  * Step 4: Check If Srs Power Is Below Target
  * Step 5: Collect BIP Logs For below_target
  * Step 6: Reduce Attenuation At All Phase Shifter Outputs
  * Step 7: Check If Srs Power Is Above Target
  * Step 8: Collect BIP Logs For above_target
* Step 9: Wait Required Period And Collect RD Counters
* Step 10: Stop Data Transfer
* Step 11: Analyze SB_BF_CONF_REL_SRS_POWER Counter

### Developer notes
* 8322 (WB SRS) call means high DL data transfer (~1.5Gbps) for UE
* Keywords used in this test case come from the resource CB008322-G2_Enhancement_for_dynamic_fallback_keywords.robot
* In order to save disk space it was agreed that BIP logs would be collected only in first loop iteration

#### History of changes
* 26.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1263 - Initial creation
* 07.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1309 - README.md update due change M55330CRD50005->M55330CRD50013
* 28.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1366 - added missing parameters to delta recommissioning
* 22.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1525 - moving TTI_reader.py to resources VRF_WRO2_T023
