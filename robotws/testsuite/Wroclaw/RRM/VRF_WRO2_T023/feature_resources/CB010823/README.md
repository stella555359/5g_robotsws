# CB010823 RU HW and SW diagnostic test on demand
Robot test suite for feature CB010823.

## Test line requirements
Any testline with RMODs which supports CB010823

### Example configuration
HW required:
ASIL/ASIB/ASIM/ASOE/+ABIN/O/P/L + AQQK/AQQL/AZHL/AZQS/AVQL or other RMOD where CB010823 is supported

### Required initial BTS state (not to be checked but provided directly from SCF)
BTS has RUs with CB010823 support.

## Test cases

### CB010823_CP41_Run_Diagnostic_check_from_WebEM
Test cases was adapted from CB010823 SiSo test case:SiSo_FM_RU_Diagnostic_check_Memory_uasge.robot created by lukasz.wystup@nokia.com.
The purpose of this test case is to verify if check point 41 (CP41) related to Memory usage is in state OK for defined RMOD.


* Owner: krzysztof.mirecki@nokia.com
* Author: krzysztof.mirecki@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Configuration and mandatory parameters
RMOD with CB010823 support is available in BTS configuration.


#### Test scenario defined by owner
* Step 1: Check if RMOD defined by SN is available in configuration.
* Step 2: Execute Diagnostic Check 41 (CP41)
* Step 3: Check if in Diagnostic Check Report status for Check Point 41 (CP41) is OK


#### Pass Criteria
* Expected1: RMOD is available.
* Expected2: Diagnostic Check is executed.
* Expected3: Diagnostic Check Report for CP1 gives status OK


#### Automatic TC steps
* Step 1: Check if RMOD defined by SN is available in configuration.
* Step 2: Execute Diagnostic Check 41 (CP41)
* Step 3: Check if in Diagnostic Check Report status for Check Point 41 (CP41) is OK


#### History of changes
* 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1188 - Initial creation
* 11.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1383 - Updated reading requestMessage to new structure
