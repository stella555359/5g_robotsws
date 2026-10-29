# CB008541: CA Scell small BWP power saving
Robot test suite for feature CB008541.

## Test line requirements
This section is taken from automation requests done by Daniel Majda.

### Example configuration
ASIL, ABIO, ABIL, AHEGC, AZQH, 1 UE compatible with the bands n1 and n78.

#### 5G cell config
AHEGC:
* Cell1(gNB)[2x2][Band n1]: NR FDD 40MHz (NRCELL-1)

AZQH:
* Cell2(gNB)[2x2][Band n78]: NR TDD 60MHz (NRCELL-4)

### Required initial BTS state (not to be checked but provided directly from SCF)
* The gNB (SA) are operational without critical alarms or errors.
* UE configured in SA mode on the band n78 and n1
* CA is required

#### 5G
* CB007552 feature flag (NRBTS.actMultipleDedicatedBWPs) is enabled
* CB008541-A flag NRCELL.actEnhMultipleDedicatedBWPs = TRUE
* UE shall capable to use powerSaving BWP: bwp-SwitchingDelay IE shall be present, 
  bwp-SameNumerology IE shall be present, dl-SchedulingOffset-PDSCH-TypeA shall be present in the UE capability
* 5GC00937 feature active (NRCELL:actPowerSavingBWP=true) and configured NRBTS:actMeasBasedSCellAddition=true
* NR gNB with 5G cell configured:
  PSCell - TDD cell with cell bandwidth higher than 20 MHz
  SCellA - TDD cell with cell bandwidth higher than 20 MHz.
  PSCell and SCellA are not contiguous
* 2 dedicated BWP profiles linked to the P(S)Cell:
  large BWP with bandwidth equal to the cell bandwidth
  small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP
* 1 power saving BWP profile linked to the PCell with bandwidth smaller than small BWP
  "small", "large" and "power saving" BWP profiles linked to the PCell have configured different PDCCH settings 
  for User Specific search space  and have different coreset.
* 2 dedicated BWP profiles linked to the SCell:
  large BWP with bandwidth equal to the cell bandwidth
  small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP
* 1 power saving BWP profile linked to the SCell with bandwidth smaller than small BWP
  "small", "large" and "power saving" BWP profiles linked to the SCell have configured different PDCCH settings 
  for User Specific search space and have different coreset.
* P(S)Cell has CA NRREL relation to ScellA with sCellAdditionMethod =covBasedA1, indicating A1 measurement based Scell 
  addition method.
* Values of parameters miNrCaDuCp and miNrPowerSavingBwp should be set in accordance to the values for counter collections in the automated TC
 
## Test cases

### CB008541_CA_SCell_Small_BWP_SCell_SA
Purpose of this test case is to verify the common gNB behavior regards to CA UE context setup when UE supporting 
small BWP for Pcell and small BWP for Scell with active 5GC000937 UE Power Saving: Dynamic BWP Adaptation feature.

* Owner: daniel.majda@nokia.com
* Author: lukasz.parzybut@nokia.com
* Maintainer: magdalena.swierbutowicz@nokia.com

#### Test scenario defined by owner
* Step 1: Attach UE to PCell.
* Step 2: Verify RRC SETUP procedure.
* Step 3: Verify whether SCell Addition proceeds successful.
* Step 4: Perform DL and UL data call.
* Step 5: Verify RRC Reconfiguration procedure.
* Step 6: Verify data call.

#### Pass Criteria
* Step 1: Attach is performed.
* Step 2: The UE returns the RRC Reconfiguration Completed message.
* Step 3: The UE returns the RRC Reconfiguration Completed message.
* Step 4: When the PCell quality goes above the threshold for the configured A1 measurement event, 
  5GUE sends RRC: Measurement report to the gNB for A1 event. gNB-CU selects the CA band combination which indicates 
  support for small BWP bandwidth for P(S)Cell and small BWP bandwidth for SCell and proceeds with SCell Addition.
* Step 5: The UE returns the RRC Reconfiguration Completed message.
* Step 6: After a while, data rate increases for DL data above configuration parameter downlink data rate threshold for 
  switching from power saving bandwidth part. ScellA is activated. DL data transfer is preset on SCellA.

#### Automatic TC steps
* Preconditions
* Perform Attach With Valid Cell Order
* Start Data Transfer And Wait 
* Postconditions
* Verification

#### Test case developer notes
* DL and UL data transfer is realized via the configured small BWP and power saving BWP
* The small dedicated BWP is configured for SCellA
* Successful UL/DL data transmission over 5G radio starting on small BWP
* After a few hundreds of milliseconds, DL/UL data are generated both with low data rate below threshold for switching 
  to power saving bandwidth part, BWP is switched to power saving BWP and UL/DL data
  transmissions is on power saving BWP
* ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP.
* A few hundreds of milliseconds after data rate increase, BWP is switched to small BWP and data transmission is on 
  small BWP. ScellA is activated.
* When data transmission is on small BWP, no throughput loss compared with feature Dynamic BWP adaptation
  feature deactivated.
* RRC configuration of the dedicated long PUCCH resources are aggregated at the bottom edge of the carrier 
  bandwidth, and it is included in the smallest dedicated BWP.
* Long PUCCH resources are configured correctly indicated by successfully received CSI reports, HARQ ACKs, 
  Scheduling Requests.
* Random Access procedure success rate is as expected since transmitted common PUSCH resource and PRACH resource 
  are protected against dedicated PUSCH transmissions.

#### History of changes
* 21.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-803 - initial creation

### RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B_TL_DeLorean
Purpose of this test case is to verify the common gNB behavior regards to CA UE context setup when UE supporting 
small BWP for Pcell and small BWP for Scell with active 5GC000937 UE Power Saving: Dynamic BWP Adaptation feature.

* Owner: daniel.majda@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* Step 1: Attach UE to PCell.
* Step 2: Verify RRC SETUP procedure.
* Step 3: Verify whether SCell Addition proceeds successful.
* Step 4: Perform DL and UL data call.
* Step 5: Verify RRC Reconfiguration procedure.
* Step 6: Verify data call.

#### Pass Criteria
* Step 1: Attach is performed.
* Step 2: The UE returns the RRC Reconfiguration Completed message.
* Step 3: The UE returns the RRC Reconfiguration Completed message.
* Step 4: When the PCell quality goes above the threshold for the configured A1 measurement event, 
  5GUE sends RRC: Measurement report to the gNB for A1 event. gNB-CU selects the CA band combination which indicates 
  support for small BWP bandwidth for P(S)Cell and small BWP bandwidth for SCell and proceeds with SCell Addition.
* Step 5: The UE returns the RRC Reconfiguration Completed message.
* Step 6: After a while, data rate increases for DL data above configuration parameter downlink data rate threshold for 
  switching from power saving bandwidth part. ScellA is activated. DL data transfer is preset on SCellA.

#### Automatic TC steps
* Preconditions
* Start DL Data Transfer
* Collect And Compare Counters M55167C00002 M55167C00003 
* Check If Print Appeared In Syslog

#### Test case developer notes
* DL and UL data transfer is realized via the configured small BWP and power saving BWP
* Please upload on your SDX-xx UE two files(cap_feature_band_nr and cap_limit_bw) which shoud by genereted special for your bands and bandwidth
  configuration .
* The small dedicated BWP is configured for SCellA
* Successful UL/DL data transmission over 5G radio starting on small BWP
* After a few hundreds of milliseconds, DL/UL data are generated both with low data rate below threshold for switching 
  to power saving bandwidth part, BWP is switched to power saving BWP and UL/DL data
  transmissions is on power saving BWP
* ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP.
* A few hundreds of milliseconds after data rate increase, BWP is switched to small BWP and data transmission is on 
  small BWP. ScellA is activated.
* When data transmission is on small BWP, no throughput loss compared with feature Dynamic BWP adaptation
  feature deactivated.
* RRC configuration of the dedicated long PUCCH resources are aggregated at the bottom edge of the carrier 
  bandwidth, and it is included in the smallest dedicated BWP.
* Long PUCCH resources are configured correctly indicated by successfully received CSI reports, HARQ ACKs, 
  Scheduling Requests.
* Random Access procedure success rate is as expected since transmitted common PUSCH resource and PRACH resource 
  are protected against dedicated PUSCH transmissions.
* UE uses Small BWP profile on SCell is checked by two counters M55167C00002 M55167C00003
* UE uses Power Saving BWP profile is confirmed by checking message in syslog.

#### History of changes
* 21.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-803 - initial creation
* 11.12.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1169 - adaptation for TL DeLorean

### RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B
Purpose of this test case is to verify the common gNB behavior regards to CA UE context setup when UE supporting 
small BWP for Pcell and small BWP for Scell with active 5GC000937 UE Power Saving: Dynamic BWP Adaptation feature.

* Owner: daniel.majda@nokia.com
* Author: michal.piechowski@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test scenario defined by owner
* Step 1: Attach UE to PCell.
* Step 2: Verify RRC SETUP procedure.
* Step 3: Verify whether SCell Addition proceeds successful.
* Step 4: Perform DL and UL data call.
* Step 5: Verify RRC Reconfiguration procedure.
* Step 6: Verify data call.

#### Pass Criteria
* Step 1: Attach is performed.
* Step 2: The UE returns the RRC Reconfiguration Completed message.
* Step 3: The UE returns the RRC Reconfiguration Completed message.
* Step 4: When the PCell quality goes above the threshold for the configured A1 measurement event, 
  5GUE sends RRC: Measurement report to the gNB for A1 event. gNB-CU selects the CA band combination which indicates 
  support for small BWP bandwidth for P(S)Cell and small BWP bandwidth for SCell and proceeds with SCell Addition.
* Step 5: The UE returns the RRC Reconfiguration Completed message.
* Step 6: After a while, data rate increases for DL data above configuration parameter downlink data rate threshold for 
  switching from power saving bandwidth part. ScellA is activated. DL data transfer is preset on SCellA.

#### Automatic TC steps
* Preconditions
* Step 1: Start DL Data Transfer
* Step 2: Collect Counters
* Step 3: Stop DL Data Transfer
* Step 3: Check Counters Values

#### Test case developer notes
* DL and UL data transfer is realized via the configured small BWP and power saving BWP
* Please upload on your SDX-xx UE two files(cap_feature_band_nr and cap_limit_bw) which shoud by genereted special for your bands and bandwidth
  configuration, example tickets are available here: https://jiradc.ext.net.nokia.com/browse/IOTIS-2088, https://jiradc.ext.net.nokia.com/browse/IOTIS-2324.
* The small dedicated BWP is configured for SCellA
* Successful UL/DL data transmission over 5G radio starting on small BWP
* After a few hundreds of milliseconds, DL/UL data are generated both with low data rate below threshold for switching 
  to power saving bandwidth part, BWP is switched to power saving BWP and UL/DL data
  transmissions is on power saving BWP
* ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP.
* A few hundreds of milliseconds after data rate increase, BWP is switched to small BWP and data transmission is on 
  small BWP. ScellA is activated.
* When data transmission is on small BWP, no throughput loss compared with feature Dynamic BWP adaptation
  feature deactivated.
* RRC configuration of the dedicated long PUCCH resources are aggregated at the bottom edge of the carrier 
  bandwidth, and it is included in the smallest dedicated BWP.
* Long PUCCH resources are configured correctly indicated by successfully received CSI reports, HARQ ACKs, 
  Scheduling Requests.
* Random Access procedure success rate is as expected since transmitted common PUSCH resource and PRACH resource 
  are protected against dedicated PUSCH transmissions.
* UE uses Small BWP profile on SCell is checked by two counters M55167C00002 (Number of CA UEs having at least 1 SCell configured with smaller BWP) and M55167C00003 (Number of CA UEs having all SCells configured with large BWP).
* UE uses Power Saving BWP profile is confirmed by checking the counter M55351C00001 (Maximum number of UEs with active Power Saving BWP).

#### History of changes
* 21.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-803 - initial creation
* 15.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1288 - adaptation for TL Rozanka based on the RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B_TL_DeLorean TC
* 25.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1317 - change maintainer of the TC
* 28.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1485 - move test from old rmod AZQH to newer AZQP
