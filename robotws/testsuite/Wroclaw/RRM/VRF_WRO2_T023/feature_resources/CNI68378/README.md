# CNI68378 - Increase resources usable for NR UL only traffic
Robot test suite for feature CNI68378.

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
* MRBTS/LNBTS/ actDssDlShareAlgNrUlLoad = false
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

### IWK_CNI-68378_DL_sharing_algorithm_with_NR_UL_load_no_DL_traffic_UL_NR_traffic_DSSp3
The purpose of this test case is to check LTE DSS performance in uplink with disabled and enabled dlResourceSharingAlgo ratio for feature CNI68378.

* Owner: kamila.lisztwan@nokia.com
* Author: mariusz.makuch@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. Differences listed below:

eNB:
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/minNrDssRatio=5
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssDlRatio/maxNrDssRatio=100
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/minNrDssRatio=5
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/maxNrDssRatio=70
* MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio/dlResourceSharingAlgo=DL PRB load based
* MRBTS/LNBTS/dlResourceSharingAlgo=true/false (CNI parameter)


gNB: 
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/minNrDssRatio=5
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssDlRatio/maxNrDssRatio=100
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=5
* MRBTS/NRBTS/NRCELL/NRDSSLTE/lteNrDssUlRatio/minNrDssRatio=70

#### Test scenario defined by owner
* Step 1: eNB Anchor and DSS and gNB DSS are onAir
* Step 2: actDssDlShareAlgNrUlLoad is disabled
* Step 3: Start NR UL UDP max throughput and start LTE UL UDP max throughput
* Step 4: End NR UL and LTE UL UDP call
* Step 5: actDssDlShareAlgNrUlLoad is enabled
* Step 6: Start NR UL UDP max throughput and start LTE UL UDP max throughput

#### Pass Criteria
* Shared NR and LTE cells are onAir
* No unexpected faults
* Expected performance:
    - NR UL with actDssDlShareAlgNrUlLoad enabled is higher than when actDssDlShareAlgNrUlLoad is disabled

#### Automatic TC steps
* Preconditions
* Step 1: Perform NR UL Data Transfer
* Step 2: Perform LTE UL Data Transfer
* Step 3: Verify UL Throughput
* Step 4: Activate actDssDlShareAlgNrUlLoad On eNB
* Step 5: Perform NR UL Data Transfer
* Step 6: Perform LTE UL Data Transfer
* Step 7: Verify UL Throughput With Activated Feature

#### History of changes
* 15.10.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-738 - Initial creation
* 11.05.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-831 - Changed maintainer
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-911 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-981 - Moved documentation to robotws
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'


