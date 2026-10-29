# CB008415 22R3-SR Resource Pooling for ABIO/N ASOE stage 5
Robot test suite for feature CB008415.

## Test line requirements
This section is taken from automation requests done by Kamila Gmerek

### Example configuration
ASIB/ASIL+ABIO
Radio modules supported LTE TDD

### Required initial BTS state (not to be checked but provided directly from SCF)

* 12x cells TDD between 5 and 20 MHz, but at least one 5 MHz (band - no specific, depends on selected radios) connected 
  to ABIO board

* eNB is up and running without any faults and/or warning messages
* All 12 cells shall be up and running without any faults or errors.


## Test cases

### RRM_DSS__call_after_5_MHz_TDD_cell_lock_unlock_and_block_unblock__CB008415-C_B1
Purpose of this test case is to verify that call is possible after 5 MHz cell block/unblock, lock/unlock operation.

* Owner: kamila.gmerek@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Test specific Preconditions
MRBTS/LNBTS/LNCEL/cellTechnology must be set to 1:TDD

#### Test scenario defined by owner
* Step 1: Lock 5 MHz cell.
* Step 2: Unlock 5 MHz cell.
* Step 3: Perform call in 5 MHz cell (traffic in dl direction udp).
* Step 4: Block 5 MHz cell.
* Step 5: Unblock 5 MHz cell.
* Step 6: Perform call in 5 MHz cell (traffic in dl direction udp).

#### Pass Criteria
* Check point 1: 5 MHz cell locked. eNB shall be in operational mode without any unpredictable alarms. All other cells 
  shall be up and running without any faults or errors.
* Check point 2: 5 MHz cell unlocked. eNB shall be in operational mode without any unpredictable alarms. All other cells
  shall be up and running without any faults or errors.
* Check point 3: Call is established.
* Check point 4: 5 MHz cell blocked. eNB shall be in operational mode without any unpredictable alarms. All other cells 
  shall be up and running without any faults or errors.
* Check point 5: 5 MHz cell unblocked. eNB shall be in operational mode without any unpredictable alarms. All other 
  cells shall be up and running without any faults or errors.
* Check point 6: Call is established.

#### Automatic TC steps
* Preconditions
* Step 1: Lock LTE Cell And Check States
* Step 2: Unlock LTE Cell And Check States
* Step 3: Perform call in 5 MHz cell
* Step 4: Block 5 MHz cell
* Step 5: Unblock 5 MHz cell
* Step 6: Perform call in 5 MHz cell

#### History of changes
* 15.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-799 - Initial creation
* 31.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-965 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-979 - Moved documentation to robotws
* 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - Replace KWs from hran-dsp library 
               with a KWs based on new libraries


### RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1
Purpose of this test case is to verify performance of 5 MHz cell on ABIO in both UL and DL directions.

* Owner: kamila.gmerek@nokia.com
* Author: szymon.kotlinski@nokia.com
* Maintainer: szymon.kotlinski@nokia.com

#### Test specific Preconditions
* MRBTS/LNBTS/LNCEL/cellTechnology must be set to 1:TDD
* MRBTS/LNBTS/LNCEL/LNCEL_TDD/APUCCH_TDD/assignedNCqiRb must be equal 2

#### Test scenario defined by owner
* Step 1: Add one UE into 5 MHz cell and perform a maximum TCP traffic for DL direction. Check DL performance for this 
  one UE
* Step 2: Using the same UE stop traffic for DL and perform a maximum TCP traffic for UL direction.
* Step 3: Without stopping traffic for UL direction add other UE into the same 5 MHz cell and perform a maximum TCP 
  traffic in DL direction

#### Pass Criteria
* Check point 1: UE attached to the cell and can carry DL traffic. Expected DL throughput +/- 10% depending on 
  configured modulation, MIMO mode.
* Check point 2: UE stop DL traffic and then can carry UL traffic. Expected UL throughput +/- 10%.
* Check point 3: New added UE is attached. Both UEs can carry traffic. Expected UL and DL throughput +/- 10%.

#### Automatic TC steps
* Preconditions
* Step 1: Perform dl Data Transfer In LTE Cell on LTE_UE1
* Step 2: Perform ul Data Transfer In LTE Cell on LTE_UE1
* Step 3: Perform dl Data Transfer In LTE Cell on LTE_UE2

#### History of changes
* 15.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-798 - Initial creation
* 31.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-964 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-979 - Moved documentation to robotws
* 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1056 - Replace KWs from hran-dsp library 
               with a KWs based on new libraries
