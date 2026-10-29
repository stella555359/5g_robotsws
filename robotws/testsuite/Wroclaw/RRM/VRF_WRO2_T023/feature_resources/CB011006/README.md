# CB008935_CB011006: 50 MHz FDD cell bandwidth
Robot test suite for feature CB008935_CB011006.

## Test strategy and priorities
Focus on requirements listed in scope but also exploratory testing with part of robustness area.

The following pre-requisite features must be activated
* In order to activate the CB008935-SR-A the parameter EQM.APEQM.RMOD.legacyWideCarrierMode shall be set to true. 
* In order to activate the CB011006-SR-A  the parameter EQM.APEQM.RMOD.legacyWideCarrierMode shall be set to false.

Activation/Deactivation steps:
* CB008935-SR-A and CB011006-SR-A don't have a dedicated Activation Flag. 
* CB008935-SR-A and CB011006-SR-A "50 MHz cell bandwidth - FR1 - FDD" can be activated and 		
Deactivated with the parameter NRBTS/NRCELL/NRCELL_FDD-chBwDl
* To activate NRBTS/NRCELL/NRCELL_FDD-chBwDl shall be set equal to '50'.
* To deactivate NRBTS/NRCELL/NRCELL_FDD-chBwDl shall not be set equal to '50'.

## Testing scope
* MADE2 support
* CPRI radio 50MHz triple RATs operation with ABIP/ABIQ+ABIA

### Example configuration
ASIL, ABIA, ABIQ, 3xAHEGHA, 1 UE (Mediatek) compatible with the bands n1, n3 and n7

#### 5G cell config
* 50MHz cell(gNB)[Band n7][FDD]: AHEGHA
* 50MHz cell(gNB)[Band n3][FDD]: AHEGHA
* 50MHz cell(gNB)[Band n1][FDD]: AHEGHA

### Required initial BTS state (not to be checked but provided directly from SCF)
* NRCELL.NRCELL_FDD.chBwDl = 50MHz
* NRCELL.NRCELL_FDD.chBwUl = 50MHz
* EQM.APEQM.RMOD.legacyWideCarrierMode=false

## Test cases

### CB011006-A_B1_Successful_UE_attachment_and_traffic_NSA_Mode_ABIQ

* Owner: dawid.1.kurowski@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test specific Preconditions
* gNB is up and running
* RRH is configured in the band n1, n3, n7
* EQM.APEQM.RMOD.legacyWideCarrierMode=false
* One subcell configured with FR1-FDD BW 50MHz
* NRCELL.NRCELL_FDD.chBwDl = 50MHz
* NRCELL.NRCELL_FDD.chBwUl = 50MHz
* Available X2-C link between LTE eNB (MeNB) and gNB (SgNB)
* 5G cell in "OnAir" state
* A UL traffic generator is available
* The UE has BW 50MHz on Band n1, n3, n7 capability
* NRCELL.pucchModeSelect=longPucch
* actDl256Qam = false
* actUl256Qam = false
* iqCompression = any CPRI supported
* BB: ABIQ

#### Test scenario defined by owner
* Step 1:
  Description: Attach UE to 50MHz cell.
  Expected: UE is attached to LTE nad NR NSA cell.
* Step 2:
  Description: Start DL data traffic.
  Expected: DL data is received.
* Step 3:
  Description: Start UL data traffic.
  Expected: UL data are generated.
* Step 4:
  Description: Stop DL/UL traffic. Enable UL and DL 256QAM for 50MHz bandwidth (actDl256Qam = true; actUl256Qam = true).
  Expected: Cell onAir, no validation or configuration errors are visible.
* Step 5:
  Description: Repeat step 2 and 3.
  Expected: DL/UL traffic are generated without BLER/ drops/ interruption.
* Step 6:
  Description: Block/unblock 50Mz cell.
  Expected: No unExpected: crash/faults.
* Step 7:
  Description: Reset RU.
  Expected: No unExpected: crash/faults.

#### Pass Criteria
* UE attach, UL/DL data transmission goes on with expected: throughput without BLER.

#### Automatic TC steps
* Preconditions
* Step 1: Perform NR DL And UL Data Transfer
* Step 2: Disable UL And DL 256QAM
* Step 3: Check Data Transfer Without 256QAM
* Step 4: Perform OAM Operations

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* In the regression test, we first check throughput for 256QAM and then without 256QAM.
It does not matter for the test result.
* Few % BLER is acceptable for OTA connection.
* Step 4 checks OAM operations like block/unblock 50Mz cell and AHEGHA reset.

#### History of changes
* 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1264 - initial creation


### CB011006-A_B2_Successful_UE_attachment_and_traffic_SA_Mode_ABIQ

* Owner: dawid.1.kurowski@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test specific Preconditions
* gNB is up and running
* RRH is configured in the band n7
* EQM.APEQM.RMOD.legacyWideCarrierMode=false
* One subcell configured with FR1-FDD BW 50MHz
* NRCELL.NRCELL_FDD.chBwDl = 50MHz
* NRCELL.NRCELL_FDD.chBwUl = 50MHz
* 5G cell in "OnAir" state
* A UL traffic generator is available
* The UE has BW 50MHz on Band n1, n3, n7 capability
* NRCELL.pucchModeSelect=longPucch
* actDl256Qam = false
* actUl256Qam = false
* iqCompression = any CPRI supported
* cellDepMode = SA+NSA / SA
* BB: ABIQ

#### Test scenario defined by owner
* Step 1:
  Description: Attach UE to 50MHz cell.
  Expected: UE is attached to 5G SA cell.
* Step 2:
  Description: Start DL data traffic.
  Expected: DL data is received.
* Step 3:
  Description: Start UL data traffic.
  Expected: UL data are generated.
* Step 4:
  Description: Stop DL/UL traffic. Enable UL and DL 256QAM for 50MHz bandwidth (actDl256Qam = true; actUl256Qam = true).
  Expected: Cell onAir, no validation or configuration errors are visible.
* Step 5:
  Description: Repeat step 2 and 3.
  Expected: DL/UL traffic are generated without BLER/ drops/ interruption.

#### Pass Criteria
* UE attach, UL/DL data transmission goes on with expected: throughput without BLER.

#### Automatic TC steps
* Preconditions
* Step 1: Check Data Transfer And BLER
* Step 2: Disable UL And DL 256QAM
* Step 3: Perform Data Transfer Without 256QAM

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* In the regression test, we first check throughput for 256QAM and then without 256QAM.
It does not matter for the test result.
* Few % BLER is acceptable for OTA connection.

#### History of changes
* 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1265 - initial creation
