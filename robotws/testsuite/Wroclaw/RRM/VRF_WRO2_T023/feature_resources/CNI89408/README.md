# CNI89408 - Counters for Setup fail due to UE not supporting Rate matching
Robot test suite for feature CNI89408.

## Test line requirements
This section is taken from automation requests done by Adam Szczerba.

### Example configuration
Configuration will be the same as for CB005860 tests.

### Required initial BTS state (not to be checked but provided directly from SCF)
Existing configuration with DSS2 or DSS3 where available is attach to SA and NSA DSS cell.

## Test cases

### CNI-89408_DSS_NSA_and_SA_Counters_verification
The purpose of this test case is to verify newly introduced counters

M55112C08002 - X2_SGNB_ADD_REQ_REJ_DSS_SENT
Number of SGNB ADDITION REQUEST REJECT sent to LTE eNB for call setup due to UE not supporting DSS

M55125C13026 - NNGCC_CTXT_STP_FAIL_DSS_SENT
Number of INITIAL CONTEXT SETUP FAILURE sent due to UE not supporting DSS

* Owner: tomasz.stawowczyk@nokia.com
* Author: adam.szczerba@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Configuration and mandatory parameters
To run this TC required is prepared QC chipset UE without DSS support (no crs-rate-matching in UE capability)
https://jiradc.ext.net.nokia.com/browse/IOTIS-2829
https://jiradc.ext.net.nokia.com/browse/IOTIS-3112
TC requires two separate UEs (one for SA and one for NSA).

#### Test scenario defined by owner
* Step 1: Attach UE in NSA to anchor  cell
* Step 2: Attach SA
* Step 3: Collect counters M55112C08002 and M55125C13026

#### Pass Criteria
* Expected1: UE is attached only to LTE anchor, SgNBaddition should be rejected
* Expected2: UE is attached but PDU session is rejected which will cause that UE will not get IP
* Expected3: Counter values are collected
* Counters M55112C08002 and M55125C13026 have non 0 values in DSS cell where attach was performed.
* In other cells those counters are equal to 0.
* If possible, count exact number of SgNBaddition rejects for counter M55112C08002 
* and InitialContextSetupFailure - "release-due-to-ngran-generated-reason" for M55125C13026
* then compare number of occurrences with counters values.

#### Automatic TC steps
* Preconditions
* Step 1: Attach NSA Ue
* Step 2: Attach SA Ue
* Step 3: Collect Counters
* Step 4: Check All Counters Values
* Step 5: Check Number Of Packets

#### History of changes
* 18.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-961 - Initial creation
* 03.02.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1026 - Fixes requires for Python 3
* 07.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1054 - Additional variable for blanking check
* 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1212 - Adaptation Test Setup and Teardown and counter collection period


