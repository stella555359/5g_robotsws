# CNI-152560: Dynamic SSB Beam Generation
Robot test suite for feature CNI-152560.

### Example configuration
ASIM, ABIP, AVQA

#### 5G cell config
* PCell(gNB) configured with AVQA

## Test cases

### CNI-152560_Feature_activation_and_deactivation
This user scenario describes the successful activation and deactivation of the Dynamic SSB Beam Generation feature
and validates that data performance remains stable.

* Owner: adam.szczerba@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test specific Preconditions
* Configuration with AVQA is operational
* actDynSsbBeamGen parameter is initially set to False
* DL and UL data performance baseline established

#### Test scenario defined by owner
* Step 1:
Verify legacy RJIO configuration with AVQA is operational
* Step 2:
Check DL and UL data performance as a reference level
* Step 3:
Activate CNI-152560 (actDynSsbBeamGen=true)
* Step 4:
Check if DL and UL data performance same as in step 2
* Step 5:
Deactivate CNI-152560 (actDynSsbBeamGen=false)

#### Pass Criteria
* Step 1: RJIO configuration with AVQA is confirmed operational.
* Step 2: DL and UL data performance baseline successfully recorded.
* Step 3: Feature activation successful, actDynSsbBeamGen=true confirmed.
* Step 4: DL and UL data performance matches baseline from step 2.
* Step 5: Feature deactivation successful, actDynSsbBeamGen=false confirmed.

#### Post-Conditions
* No unexpected faults on BTS
* Performance as a reference level

#### Automatic TC steps
* Preconditions
* Step 1: Perform And Verify NR DL And UL Data Transfer
* Step 2: CNI-152560 Feature Activation
* Step 3: Perform And Verify NR DL And UL Data Transfer Post-Activation

#### Test case developer notes
* Verify no unexpected alarms or faults appear on BTS during feature activation/deactivation.
* Logs should be collected for troubleshooting purposes(Syslog, Snapshot).

#### History of changes
* 11.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1790 - initial creation