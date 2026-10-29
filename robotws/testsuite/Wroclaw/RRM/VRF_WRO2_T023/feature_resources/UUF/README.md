# Test Plan for Cloud BTS UUF test cases

## Test line requirements
It is required for test line to have Cloud BTS configuration.

## UEs:
No UEs needed.

## BTS configuration
* CloudRAN gNB,
* Operational gNB - vCU, vDU

## Test cases

### VDU Reset Test
The purpose of this test case is to verify if vDU reset performed through WebEM works correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* No UEs currently used in this test.

#### Test scenario defined by owner
* Step 1: Check vDU and vCU state before loop and collect logs (snapshot from vCU, snapshot from vDU, syslog).
* Step 2: Perform vDU reset
* Step 3: Wait for vDU to lose connection.
* Step 4: Wait for vDU to respond to ping.
* Step 5: Wait for TL to go on air.
* Step 6: Wait for unexpected alarms to appear for time defined by user.
* Step 7: Collect logs.
* Step 8: Check loop state, if it is first passed loop or its status is failed keep logs otherwise
          delete logs directory.

#### Pass Criteria
* No unexpected faults.
* BTS goes back on air after vDU reset.

#### Automatic TC steps
* FOR  ${loop_index}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
    * Preconditions
    * Perform VDU Reset
    * Check BTS State After VDU Reset
    * Wait For Unexpected Alarms
    * Collect Logs
    * Verify Loop Result
* END
* Log Loops Summary

#### Test case developer notes
* In case of configuration with simulator, please make sure that it is set up before running this test.
* This test case will only work for configurations with 1x vCU and 1x vDU.
* This test only collects logs from vCU and vDU.
* Currently available values for vCU version (${cu_oam_version_vcu}) and vDU version (${cu_oam_version_vdu})
  can be found respectively under following links:
    * https://taf-gnb-oam-coam-cu.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.gnb.oam.coam.cu.interface.cu.connect_to
    * https://taf-gnb-oam-coam-vdu.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.gnb.oam.coam.vdu.interface.vdu.connect_to
* Currently, no report is being sent to Reporting Portal nor to Quality Center.
* During reset operation following alarms are added to list of allowed alarms:
  * Alarm ID 7114, Fault ID 7104, Matching ServedCell not found over F1-C (on vCU)
  * Alarm ID 7115, Fault ID 4592, BTS Reset Cause (on vDU)
* If parameter stop_after_consecutive_fails is set to True execution will stop in case of 3 consecutive fails.

#### History of changes
* 04.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1407 - Initial creation
* 23.06.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1504 - Added graceful shutdown option for cells during vDU reset


### Create Init File
The purpose of 'Create Init File' is to support tester with creation of __init__.py file.

* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Automatic steps
* Create Init File

#### Developer notes
* 'Create Init File' creates a simple __init__.py file for cloud BTS configuration with 1x vDU and 1x vCU.
* It does not include rannic, simulator, PDUs, RMODs, classical BTS in created file.

#### History of changes
* 04.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1417 - Initial creation
