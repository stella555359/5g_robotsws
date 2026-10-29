# CB008224: 5G Supplemental DL Cell FR1
Robot test suite for feature CB008224.

### Example configuration
ASIL, ABIO, AHFIC, AZQF, 1 UE supports CA 2CC FDD-TDD

#### 5G cell config
* PCell(gNB)[Band n78][TDD]: AQQL
* SCell1(gNB)[Band n7][FDD]: AHEGHA

### Required initial BTS 5G state (not to be checked but provided directly from SCF)
* CA 2CC FDD-TDD activated
* NRBTS/NRCELL.cellBarred parameter value is set to barred for SDL Cells 
* NRBTS/NRCELL.intraFreqReselection shall be set to notAllowed for SDL cells 
* NRBTS/NRCELL.nrCellType with rules for values 2DL0UL and 4DL0UL
* NRBTS/NRCELL/NRREL.handoverAllowedSA shall be set to forbidden
* NRBTS/NRCELL/NRREL.handoverAllowedSARedCap shall be set to forbidden
* NRBTS/NRCELL/NRREL.sCellOperationalMode shall be set to dlOnly

## Test cases

### CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
This user scenario describes the successful activation and operation of the inter-band FR1 TDD-FDD DL CA

* Owner: mariusz.daniel@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Test specific Preconditions
* carrierAggregationSupportList enumeration parameter is set to ca_Fr1Tdd_Fdd_Sa
* CA relation is defined by defining NRREL object for each TDD cell pointing to the another FDD (SDL) cell having coverage overlaid with the previous 
one 
* Within NRREL object add sCellAdditionMethod parameter and set it to blind. 

#### Test scenario defined by owner
* Step 1:
UE attach to TDD cell and are operating in SA mode
* Step 2:
UE (with appropriate TDD-FDD CA UE capabilities) attached to FDD cell after CA features activation. Perform DL data traffic.

#### Pass Criteria
* Step 1: Attach successful.
* Step 2: In the DL, Data is sent via PCell as well as SCells.

#### Automatic TC steps
* Preconditions
* Step 1: Perform NR DL Data Transfer
* Step 2: Collect NR TTI
* Step 3: Verify CA activation

#### Test case developer notes
* Step 2 from Pass Criteria can be checked in QXDM - two DL values should be visible there. Second method is to download TTI Trace
and verify that values of dlFdSchedData.maxDataVolumeDl column appear for two cells.
* Please make sure that all parameters from preconditions are set on the BTS. Rest of necessary parameters are set in the test.
* This test covers TC CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA (cells n78 and n7) and CB008224_B_n75_SDL_SCell_Addition_-_Blind_Mode_SA (cells n1 and n75)
#### History of changes
* 20.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1235 - initial creation
* 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1272 - TTI trace collecting time is changed
* 11.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1348 - Collecting NR TTI traces improvement
* 17.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1431 - Updating list of parameters for delta_AHSB.json
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version
  and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1568 - modified import path due to moving CB008224_keywords.py
  to resources


### CB008224_C_SDL_SCell_Swap_-_SDL_To_SDL_SCell_SA
This user scenario describes a successful swap from one SDL cell to another in 2CC CA. 

* Owner: mariusz.daniel@nokia.com
* Author: michal.hadrysiak@nokia.com
* Maintainer: michal.hadrysiak@nokia.com

#### Test specific Preconditions
* carrierAggregationSupportList enumeration parameter is set to ca_Fr1Tdd_Fdd_Sa
* There is a Pcell (TDD cell), and two SDL cells (FDD) having the same frequency coverage.
* CA relation is defined by two NRREL objects for Pcell pointing to SDL cells with different priority. 
* Within NRREL object add sCellAdditionMethod parameter and set it to blind. 

#### Test scenario defined by owner
* Step 1:
UE is attached to TDD PCell and CA with FDD SCell 1, data call is ongoing. 
* Step 2:
Attenuation of SCell 1 on gNB increases while attenuation of SCell 2 on gNB decreases. 
* Step 3:
gNB performs Inter-gNB SCell swap. 

#### Pass Criteria
* Step 1: DL data transfer ongoing through PCell and SCell 1. SCell 2 is configured on gNB.
* Step 2: gNB initiates Inter-gNB SCell swap from current SCell 1 to SCell 2. 
* Step 3: DL data transfer ongoing through PCell and SCell 2. 

#### Automatic TC steps
* Preconditions
* Step 1: Perform NR DL Data Transfer
* Step 2: Collect NR TTI
* Step 3: Verify CA activation
* Step 4: Perform SDL Cell Swap
* Step 5: Collect NR TTI
* Step 6: Verify CA activation

#### Test case developer notes
* CA activation is verified by collecting TTI traces from the two cells where the UE should be attached, and checking the dlFdSchedData.maxDataVolumeDl column to see if data is transfered through both of them.
* There is possibility that KW collecting TTI traces will gather more than one file. Then files are named using numbers like "tcpdump_dl.0.csv". Because in this verification only the existance of two instances in column dlFdSchedData.maxDataVolumeDl is checked, this case does not affect the execution.

#### History of changes
* 20.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1235 - initial creation
* 31.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1327 - move test from TL Kozanow to TL Beamskupin
* 11.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1348 - Collecting NR TTI traces improvement
* 28.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1409 - Removed delta recommissioning
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version
  and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1568 - modified import path due to moving CB008224_keywords.py
  to resources
* 19.01.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1743 - Adding  apn=${APN} parameter to "Start Data Transfer"
