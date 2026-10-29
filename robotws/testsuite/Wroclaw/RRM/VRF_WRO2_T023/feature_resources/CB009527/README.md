# CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells
Robot test suite for features CB009527-D.


## Test strategy and priorities
The purpose of that feature is to enable the advanced SRS based DL subband beamforming for 7-2e and enhance the subband 
BF size to 2 PRB granularity.


## Testing scope
* CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells - basic scenario


### Example configuration
gNB: ASIM, ABIP, AVHA
1 UE  compatible with the band n41 NR.


#### Cells config
* NR cell(gNB)[Band n41][TDD][20MHz]: AVHA
* NR cell(gNB)[Band n41][TDD][30MHz]: AVHA
* NR cell(gNB)[Band n41][TDD][40MHz]: AVHA
* NR cell(gNB)[Band n41][TDD][50MHz]: AVHA


## Test cases

### CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells
The purpose of this scenario is to verify functionalities of SVD/RZF based SB BF with SB SRS configuration over 7-2e 
split for multi CC configuration. 

* Owner: adam.szczerba@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: magdalena.swierbutowicz@nokia.com


#### Test specific Preconditions
* 4 cells TDD NR with beamforming enabled
* 7-2e enabled
* numOfSrsSubbandInput=4 configured


#### Test scenario defined by owner
* Step 1:
  Description: Enable subband BF on all cells.
  Expected: No validation error, after activation all cells are in OnAir state.
  
* Step 2:
  Description: L3 Call on first cell.
  Expected: If all threshold criteria are above, then UE is using WB SRS and subband BF for PDSCH and CSI-RS.
  
* Step 3:
  Description: Repeat Step 2 for next cells.
  Expected: The same as in Step 2.
  
* Step 4:
  Description: Check if counters related with subband BF are correctly updated.
  Expected: All cells have correct value in all SB BF counters:   
  M55330C00017 : SLOT_UE_SCHD_SB_BF  
  M55330C00018 : NUM_UE_SCHD_SB_BF  
  M55330C00042 : NUM_SB_BF_UE_SCHD_LEG_BF  
  M55330C00020 : MAX_PDSCH_PRB_SCHD_SB_BF  
  M55330C00021 : ACC_PDSCH_PRB_SCHD_SB_BF  
  M55196C00010: ACC_UE_CONF_SB_BF_TAS_SRS  
  M55196C00012: MAX_UE_CONF_SB_BF_TAS_SR


#### Pass Criteria
* The value of all counters should be >0.


#### Automatic TC steps
* Preconditions
* Step 1: Enable Subband BF On All Cells
* Looped Steps
* Step 5: Check SCF Modifications

In Looped Steps:
* Step 2: Perform L3 Call 
* Step 3: Get Counters Values 
* Step 4: Check Counters Values


#### Test case developer notes
* In Looped Steps, the scenario for the next cells is checked.
* Test case creates a dictionary with counter values and checks whether any value is not equal to 0.
* If some value of counters are equal 0, please make sure that throughput in L3 call is high enough, more than few Mb/s.
* In Step 5, the parameters: bfSubbandSize, maxNumUeSrs, numOfSrsSubbandInput on the cells are modified to detect 
  possible faults and crashes during reconfiguration.


#### History of changes
* 08.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1470 - initial creation
