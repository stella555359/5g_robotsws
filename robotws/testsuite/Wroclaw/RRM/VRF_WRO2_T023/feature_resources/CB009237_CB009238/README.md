# CB009237/CB009238 - LTE-NR/NR-LTE DSS: NR PDCCH Load use for Resource Allocation
Robot test suite for features CB009237/CB009238.

## Test strategy and priorities
The purpose of that feature is to enable LTE-NR DSS (DSS phase 3 only) algorithm to consider NR PDCCH load in DL resource sharing algorithm. 
The capacity of NR PDCCH is directly dependent on the amount of DL subframes assigned to NR.
Feature delivers use of NR PDCCH load in DSS resource allocation to possibly increase the DL resources 
allocated to NR when NR PDCCH load is higher than NR PDSCH load. 


## Testing scope
* CB009237-A: LTE-NR DSS: NR PDCCH load use for Resource Allocation - basic scenarios
* CB009238-A: NR-LTE DSS: NR PDCCH Load use for Resource Allocation - basic scenarios


### Example configuration
gNB: ASIL, ABIO, AHEGC, 
eNB: ASIA, ABIA, AHEGC,

1 UE  compatible with the bands b75 LTE and DSS.
4 UEs  compatible with the band b1 5G and DSS.


#### Cells config

* LTE DSS cell(eNB)[Band n75][FDD]: AHEGC
* NR DSS cell(gNB)[Band n1][FDD]: AHEGC


## Test cases

### CB009237_CB009238_Multi_UE_NR_DL_data_transfer__high_PDCCH_load_with_low_LTE_load
The purpose of this scenario is to show that NR PDCCH load for DL scheduling is influencing the DL sharing ratio when LTE load is low. 

* Owner: dawid.1.kurowski@nokia.com
* Author: mikolaj.kasian@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions
* The test environment is configured Similar to CRM User Scenario CB007738-A/CB005738-A-#3: 
  Activation DSS with superfast allocation rate - 'good case' (CRM_1630).
* MRBTS.NRBTS.NRCELL.NRCELL_FDD.chBwDl = '10MHz'
* MRBTS.LNBTS.LNCEL.DSSNR.lteNrDssDlRatio.maxNrDssRatio='100'
* MRBTS.NRBTS.NRCELL.NRDSSLTE.lteNrDssDlRatio.maxNrDssRatio='100'
* MRBTS.LNBTS.LNCEL.DSSNR.lteNrDssDlRatio.minNrDssRatio='5'
* MRBTS.NRBTS.NRCELL.NRDSSLTE.lteNrDssDlRatio.minNrDssRatio='5'
* MRBTS.LNBTS.LNCEL.DSSNR.lteNrDssUlRatio.maxNrDssRatio='70'
* MRBTS.NRBTS.NRCELL.NRDSSLTE.lteNrDssUlRatio.maxNrDssRatio='70'
* MRBTS.LNBTS.LNCEL.DSSNR.lteNrDssUlRatio.minNrDssRatio='5' 
* MRBTS.NRBTS.NRCELL.NRDSSLTE.lteNrDssUlRatio.minNrDssRatio='5'
* BWP_PROFILE of MRBTS.NRBTS.BWP_PROFILE.bwpType = 'dedicated'
* MRBTS.NRBTS.BWP_PROFILE.locationAndBandwidthDl.cRbSizeDl = 'allRb'
* MRBTS.NRBTS.BWP_PROFILE.PDCCH.PDCCH_CONFIG_DEDICATED.coresetDedicated.size = size 
  of full dedicated BWP (excluding potential blanking according to PDCCH config tool)
* MRBTS.NRBTS.BWP_PROFILE(both profiles).PDCCH.alSelection is set to 'static'
* MRBTS.NRBTS.BWP_PROFILE(both profiles).PDCCH.dciDedicatedAggregationLevel is set to 'AL4'
* MRBTS.NRBTS.NRCELL.NRDSSLTE.actLteNrDssPdcchLoadResAlloc NIDD parameter enabling the feature is set to true
* MRBTS.NRBTS.NRCELL.NRDSSLTE.dssMaxNumberOfDlDcis is set to '1'

#### Test scenario defined by owner
* Step 1:
  Description: Plan from precondition is activated.
  Expected: BTS, DSS cells are onAir. No unexpected errors and faults.
  
* Step 2:
  Description: Multiple NR UEs are transferring DL data (small, frequent packets - generating constant low DL throughput) on the NR side 
  to achieve very high (around 100%) PDCCH load (3 UEs shall be enough with 10MHz settings).
  Expected: High NR PDCCH Load (~100%) is visible in NR XP: EN DSS DL QOS LOAD INDICATION messages or CRM traces. 
  The NR DL share shall be greater than or equals 80%.
  
* Step 3:
  Description: Generate DL load on LTE side by single UE (around 30% of DL LTE cell capacity).
  Expected: No interrupted LTE traffic is performed. LTE load is reported in CRM ~30%
  
* Step 4:
  Description: After 15-30 minutes of interrupted LTE and NR traffic, verify counters: 
  M8029C216; M55332C00001; M55332C01001; M55332C02001; M55332C02002.  
  Expected: M55332C00001 should increase, M8029C216 and M55332C01001 should decrease, M55332C02001 and M55332C02002 should not change

* Postconditions
  CRM traces report NR DL SHARE >=80%, LTE DL Share ~20%. No unexpected faults and errors.
  NR PDCCH load = 100%


#### Pass Criteria
* CRM traces report NR DL SHARE >=80%, LTE DL Share ~20%. No unexpected faults and errors. NR PDCCH load is ~100%

#### Automatic TC steps

* Step 1: Attach Ues
* Step 2: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side
* Step 3: Generate Dl And Ul Load On Lte Side
* Step 4: Wait For Traffic Stabilize
* Step 5: Wait For Next Two Counters Periods
* Step 6: Collect Snapshots When Feature Is Off
* Step 7: Stop Data Transfer
* Step 8: Detach UEs
* Step 9: Get Initial Counters Values  
  
* Step 10: Activate Feature  
  
* Step 11: Attach Ues
* Step 12: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side
* Step 13: Wait For Traffic Stabilize
* Step 14: Start eNB Syscomdump Collection
* Step 15: Wait For Logs Capture
* Step 16: Stop Syscomdump Collection
* Step 17: Check Nr Pdcch Load
* Step 18: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load 0 Percents
* Step 19: Generate Dl And Ul Load On Lte Side
* Step 20: Wait For Traffic Stabilize
* Step 21: Start eNB Syscomdump Collection
* Step 22: Wait For Logs Capture
* Step 23: Stop Syscomdump Collection
* Step 24: Check Nr Pdcch Load
* Step 25: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load About 30 Percents

* Step 26: Wait For Next Two Counters Periods
* Step 27: Collect Snapshots When Feature Is On
* Step 29: Stop Data Transfer
* Step 30: Detach UEs
* Step 31: Check Counters

#### Test case developer notes
* Counters are checked by comparison final values from after the test with initial values from before the test.
* Snapshots are collected with and without feature under traffic load, because inside Snapshots, there are crucial CRM logs for comparison.
* Snapshots should be collected under traffic load, other way new logs overwrite logs that are we interested in.

#### History of changes
* 17.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1413 - initial creation
