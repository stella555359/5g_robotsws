# CB013202_A1_Rank2_with_IRC_gain_compensation_TDD_periodic_SRS_actDlSrsBm
Robot test suite for features CB013202_A1.


## Test strategy and priorities
This feature introduces improvements to UL SU-MIMO rank estimation for 2Tx capable UEs, focusing on IRC gain, spectral 
efficiency (SE) check, and handling high noise power variations. It applies to 4Rx (FR1 TDD/FDD) in standalone 
deployments for both classical and cloud environments, leveraging both PUSCH and SRS receptions for rank and PMI 
selection (currently MRC-based). The feature aims to prevent rank underestimation, increasing rank 2 transmissions, 
particularly in the mid-cell region, and yielding an expected average cell throughput gain of 3-5%.  
This functionality is already supported for 8Rx/16Rx. 2Rx is not supported, the IRC gain 
(NRCELL.ulSuMimoEnh.enhRankSelectIrcGain) and SE check (NRCELL.ulSuMimoEnh.enhRankSelectSe) must be deactivated for 2Rx 
gNBs during cell setup. 


## Testing scope
* CB013202_A1_Rank2_with_IRC_gain_compensation_TDD_periodic_SRS_actDlSrsBm - basic scenario


### Example configuration
gNB: ASIM, ABIP, AVHA x2
2 UEs  compatible with the band n41 NR.


#### Cells config
* NR cell(gNB)[Band n41][TDD][100MHz]: AVHA
* NR cell(gNB)[Band n41][TDD][100MHz]: AVHA


## Test cases

### CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells
The purpose of this test case is to verify whether activation of enhRankSelectIrcGain will prevent underestimation of 
rank and help to increase throughput in presence of interference.

* Owner: anna.konior@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: magdalena.swierbutowicz@nokia.com


#### Test specific Preconditions
* gNB is up and running, SA mode, single carrier under TDD FR1, BW=100MHz
* NRCELL.numberOfRxBeamforming = 4Rx
* NRCELL.actUlDftSOfdm is set to false.
* NRCELL.ulSuMimoEnh.enhRankSelectIrcGain is disabled at NIDD.
* NRCELL.ulMimoMode parameter is set to 2x2 closed loop spatial multiplexing.
* NRCELL.actCoverageNonCoherentUEs is set to false.
* NRCELL.actFullPwrMode is set to False
* NRCELL.actUlSrsBm is set to true. NRCELL.actDlSrsSubbandBm is set to false.
* NRCELL.actDlSrsBm is set to true. NRCELL.actUlSrsSubbandBm is set to false.
* User connected to target cell is 2Tx capable.
* Radio conditions are good and allow Rank2 to be measured.
* An UL traffic generator is available.


#### Test scenario defined by owner
* Step 1:
  Description: Attach tester UE and start UL data transfer.
  Expected: UE transmits PUSCH rank2. 5G-L1-UL measures UL rank and UL TPMI based on 4Rx DMRS reception on PUSCH rank2.
  Rank2 transmissions continue thanks to good radio conditions.
  
* Step 2:
  Description: Start the transmission of the interfering UE (full buffer) in border of the adjacent cell.
  Expected: 5G-L1-UL measures rank1 and TPMI on 4Rx DMRS channel estimates.
  UE transmits PUSCH rank1 few slots after radio conditions are degraded.
  Rank1 transmissions continue due to continuous interferences in UL.
  
* Step 3:
  Description: Turn on the feature NRCELL.ulSuMimoEnh.enhRankSelectIrcGain is enabled on tested cell and check radio 
  conditions.
  Expected: 5G-L1-UL measures more rank2 after this change on 4Rx SRS channel estimates.
  UE transmits PUSCH rank2 few slots after radio conditions are improved.


#### Pass Criteria
The scenario is successful when NRCELL.ulSuMimoEnh.enhRankSelectIrcGain is disabled and:
* rank 1 is scheduled few slots after interferer transmission starts
* rank 2 is scheduled only after interferer transmission stops 
When NRCELL.ulSuMimoEnh.enhRankSelectIrcGain is enabled:
* rank2 transmission can be scheduled when interferer is transmitting (either no rank 1 at all or very small rank1 period).
Throughput is equal or improved compared to NRCELL.ulSuMimoEnh.enhRankSelectIrcGain disabled.


#### Automatic TC steps
* Preconditions
* Step 1: Start UL Data Transfer On Tester UE
* Step 2: Check If RANK2 Was Reached On_Tester_UE
* Step 3: Start UL Data Transfer On Interferer UE
* Step 4: Check If RANK1 Was Reached With_Interferer_UE
* Step 5: Activate Rank Selection
* Step 6: Check If RANK2 Was Reached When_enhRankSelectIrcGain_Enabled
* Step 7: Stop Data Transfers And Detach UEs


#### Test case developer notes
* The number of layers is checked in TTI traces.
* 2 UEs were used in the scenario. The first 'tester UE' connected OTA to the AVHA in the chamber. The second one is 
  'interferer UE' connected via pigtails to the AVHA on the wall.
* Test is prone to fail if position of antennas in chamber would change.
* Adjusting test conditions should start with OTA AVHA angles. 
  Find the position where interferer UE is doing the most noise based on SINR values. 
  The radio should somewhat face the interferer antennas.
  Then attenuate OTA AVHA cell to the level where interferer data transfer triggers the scenario.
* SINR and RANK values can be monitored via ComponentTraceHelper (CTH). TL settings are in the ticket IWK-1578
  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1628373384
* Last working OTA AVHA and attenuator setting is in the ticket IWK-1578


#### History of changes
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1520 - initial creation
* 29.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1578 - stabilization and refactor
