# Test Plan for Reliance India test cases

## Test line requirements
Configuration for test line should be the same as customer configuration.
E.g. ASOE+3xAQQJ+AHPJ+AHPB

## UEs:
1xUE supporting CA
No other specific requirements apart from customer band support.

## BTS configuration
* ANR (for EUTRA and NR neighbor) and HO (IRAT, Intra-Frequency and Inter-Gnb) configured. Mandatory parameters:
  * NRANRPRE/nrAnrPrEId set to 1
  * NRBTS/actSaUeBasedAnrEutra set to true
  * NRBTS/actSaUeBasedAnrNr set to true
* CA configured on at least one cell
  * NRREL configured under primary cell (n28 FDD) for secondary cell (n78 TDD)
  * NRDU/CarrierAggregationSupportList needs to have 'ca_Fdd_Fr1Tdd_Sa'
* UE Power Saving activated for TDD cells (5GC000937)
  * actPowerSavingBWP=true
  * BWP_PROFILE MO configured for bwpType=powerSaving
  * Power saving BWP profile dist name assigned in NRCELL/cellBwpList/bwpDN

## Test cases

### Rjio_E2E_03_Power_Reset_Rf
The purpose of this test case is to verify if power reset of radio modules is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* No UEs currently used in this test.

#### Test scenario defined by owner
* Step 1: Turn off RMOD using PDU and check status.
* Step 2: Turn on RMOD using PDU and check status.
* Step 3: Repeat Step 1 and 2 for all RMODs.

#### Pass Criteria
* No unexpected faults.
* BTS goes back on air after turning RMODs on.

#### Automatic TC steps
* The same as in UUF 'RMOD_POWER_RESET' test case, please refer to UUF documentation.

#### Test case developer notes
* Calls/data transfer can be added later as enhancement.
* TC is using UUF 'RMOD_POWER_RESET', so in case of problems please refer to UFF documentation.
* UUF TC performs power reset for one RMOD in one loop, so in case of 5 RMODs in configuration for all 
  of them to have power reset performed on them number of loops needs to be set to equal to number of RMODs.
  In testsuite variable for this is named 'RMOD_AMOUNT'. It is possible to make more loops
  and in case tester wants to make operation 3 times on all rmods number of loops needs to be set
  to 3xRMODs amount.

#### History of changes
* 22.09.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1123 - Initial creation


### Rjio_E2E_05_Radio_Lock_Unlock
The purpose of this test case is to verify if lock and unlock of radio modules is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE

#### Test scenario defined by owner
* Step 1: Lock RMOD and check status.
* Step 2: Unlock RMOD and check status.
* Step 3: Repeat Step 1 and 2 for all RMODs.
* Step 4: Perform UL and DL data transfer and check throughputs.
  * Step 1: Set attenuation on ports
  * Step 2: Start wireshark logs collecting
  * Step 3: Attach UE and start DL and UL data transfers
  * Step 4: Check throughputs
  * Step 5: Stop data transfer, collect logs and set attenuation to max on all ports.

#### Pass Criteria
* No unexpected faults.
* BTS goes back on air after unlocking RMODs.
* Throughputs have correct values for configuration.

#### Automatic TC steps
* The same as in UUF 'RMOD_LOCK_UNLOCK' test case, please refer to UUF documentation.
* Steps for Attach keyword:
  * Preconditions - Data Transfer On RJIO
  * Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO
  * Step 2: Check Throughputs - Data Transfer On RJIO
  * Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO

#### Test case developer notes
* Currently data trnasfer is only performed in last loop. The other loops are skipped.
  Calls/data transfer for more cells can be added later as enhancement.
* TC is using UUF 'RMOD_LOCK_UNLOCK', so in case of problems please refer to UFF documentation.
* TC requires test variable (dictionary) for attenuator named 'ATTENUATOR'. The dictionary should
  contain following keys: ip, port, attenuation_port_numbers, max_attenuation, vendor
* TC also requires test variables: 'NR_EXPECTED_DL_TPUT' - expected NR DL throughput in Mbps,
  'NR_EXPECTED_UL_TPUT' - expected NR UL throughput in Mbps and 'NR_CELL_ID' - global NR cell ID
  and 'L3_CALL_FOR_LAST_RMOD' - this is variable for RMOD TCes, if set to True it allows to run
  data transfer KW for last loop only, instead of every loop.
* UUF TC locks and unlocks one RMOD in one loop, so in case of 5 RMODs in configuration for all 
  of them to be locked and unlocked number of loops needs to be set to equal to number of RMODs.
  In testsuite variable for this is named 'RMOD_AMOUNT'. It is possible to make more loops
  and in case tester wants to make operation 3 times on all rmods number of loops needs to be set
  to 3xRMODs amount.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 22.09.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1124 - Initial creation
* 06.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1377 - RJIO_Data_Transfer Improvement
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changing tput commands for RJIO
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1450 - Refactored test to work with both iPhone UEs
               and Android UEs


### Rjio_E2E_26_CA_Call
The purpose of this test case is to verify if carrier aggregation call is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE supporting CA

#### Test scenario defined by owner
* Step 1: Perform carrier aggregation data transfer for both DL and UL.
* Step 2: Verify throughput values.

#### Pass Criteria
* Throughputs have correct values for configuration.

#### Automatic TC steps
* Preconditions
* Step 1: Perform Data Transfer In Cell With Carrier Aggregation
* Step 2: Verify Throughput Values
* Step 3: Check BTS State

#### Test case developer notes
* Currently data transfer is verified based on sum of throughput for both primary and secondary cell.
  Expected value for DL should be higher than value passed in 'NR_EXPECTED_DL_TPUT',
  this will be significantly higher than throughput for only FDD cell to which UE should be attached.
  For UL expected value is verified as 'NR_EXPECTED_UL_TPUT' +/-20%, since it is not higher than
  without CA configured (since currently used UE does not support UL CA).
* TC requires test variable (dictionary) for attenuator named 'ATTENUATOR'. The dictionary should
  contain following keys: ip, port, attenuation_port_numbers, max_attenuation, vendor
* Carrier aggregation for TL configuration at the time of writing this test is configured for cells
  with bands n28 (primary, FDD) and n78 (secondary, TDD).
* Changing qRxLevMin value for secondary cell to value for which UE will not attach to it may be useful
  since UE will still be able to use cell in CA, but will not be attaching to it.
* Verification through TTIs for CA in DL was added. Verification is based on checking if number of cells is equal to 2.
  For this verification to work, following L3PS flags need to be set on BTS:
  rdComponentBitMapProfile=31 - Use RnD Parameters and rdComponentBitMapVector4=0x10, which can be set in swconfig as
  0x5808ff = 2147483648 and 0x580904 = 16.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 04.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1128 - Initial creation
* 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1141 - Changed test to use Mbps instead of Kbps
* 22.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1422 - Added BTS state check
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changed tput commands for RJIO
* 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1567 - Added TTI verification
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1447 - Refactored test to work with both iPhone UEs
               and Android UEs


### Rjio_E2E_24_Site_Reset_With_L3_Call
The purpose of this test case is to verify if site reset is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE

#### Test scenario defined by owner
* Step 1: Perform site reset and check status.
* Step 2: Perform UL and DL data transfer and check throughputs.
  * Step 1: Set attenuation on ports
  * Step 2: Start wireshark logs collecting
  * Step 3: Attach UE and start DL and UL data transfers
  * Step 4: Check throughputs
  * Step 5: Stop data transfer, collect logs, check hanging resources and set attenuation to max on all ports.

#### Pass Criteria
* No unexpected faults.
* BTS goes back on air after site reset.
* Throughputs have correct values for configuration.

#### Automatic TC steps
* The same as in UUF 'E2E TL SITE RESET WITH OAM KPI' test case, please refer to CSV4ALL documentation.
* Steps for Attach keyword:
  * Preconditions - Data Transfer On RJIO
  * Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO
  * Step 2: Check Throughputs - Data Transfer On RJIO
  * Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO

#### Test case developer notes
* TC is using UUF 'E2E TL SITE RESET WITH OAM KPI', so in case of problems please refer to CSV4ALL documentation.
* TC requires test variable (dictionary) for attenuator named 'ATTENUATOR'. The dictionary should
  contain following keys: ip, port, attenuation_port_numbers, max_attenuation, vendor
* TC also requires test variables: 'NR_EXPECTED_DL_TPUT' - expected NR DL throughput in Mbps,
  'NR_EXPECTED_UL_TPUT' - expected NR UL throughput in Mbps and 'NR_CELL_ID' - global NR cell ID
  and 'L3_CALL_FOR_LAST_RMOD' - this is variable for RMOD TCes, so it should be set to False for this test.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 04.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1129 - Initial creation
* 06.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1377 - RJIO_Data_Transfer Improvement
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changing tput commands for RJIO
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1450 - Refactored test to work with both iPhone UEs
               and Android UEs

### Rjio_E2E_35_Power_Saving_BWP_Switch
The purpose of this test case is to verify if UE power saving (feature 5GC000937) is triggered.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE supporting power saving

#### Test scenario defined by owner
* Step 1: Wait For Next Counter Period.
* Step 2: Perform DL data transfer in cell with UE power saving feature (5GC00937) activated.
  Data transfer should cross threshold set for BWP power saving.
* Step 3: Stop data transfer.
* Step 4: Check if print indicating use of power saving BWP profile by UE appeared in syslog. 
* Step 5: Check If Wait For Next Counter Period Is Needed.
* Step 6: Collect And Verify Counters M55351C00001, M55351C00002, M55351C01001, M55351C01002.
* Step 7: Repeat steps 2-6 five times.
* Step 8: Check BTS state after test.

#### Pass Criteria
* Data transfer was performed.
* Print 'switched to bwpType=POWER_SAVING.*' appeared in syslog after performing data transfer.
* For each loop counters should have following values: M55351C00001=1, M55351C00002=0, M55351C01001=1, M55351C01002=0.

#### Automatic TC steps
* Preconditions
* Step 1: Wait For Next Counter Period
* Looped Steps
  * Step 2: Perform Data Transfer In Cell With UE Power Saving
  * Step 3: Stop Data Transfer
  * Step 4: Check If Print Appeared In Syslog
  * Step 5: Check If Wait For Next Counter Period Is Needed
  * Step 6: Collect And Verify Counters
* Step 7: Check BTS State

#### Test case developer notes
* Data transfer run to trigger print should be high (~600 Mbps was run during creation of this test)
  after that either a low troughput needs to be run or simply stopping the previous one is enough
  (during developement of this test stopping was enough).
* UE needed for this test needs to support power saving. This can be checked during attach in wireshark.
  In packet InitialContextSetupRequest search for field bwp-SwitchingDelay: type2 (1) in UE capabilities.
  Display filter: nr-rrc.bwp_SwitchingDelay == 1.
* BWP profile for power saving needs to be configured before the test. This test will only check basic
  parameters to see if it is configured.
* This test checks if print matching 'switched to bwpType=POWER_SAVING.*' appeared after data transfer five times.
  It fails if print did not appear in every loop.
* BWP switching used to be verified using syslog print 'switched to bwpType=POWER_SAVING.*'. 
  However due to multiple instances of prints not appearing while feature counters were counted correctly print
  verification step was changed to support only debugging and will not fail anymore. In case of fail a warning
  will now be printed.
* Currently test is verified by checking counters:
  * Maximum number of UEs with active Power Saving BWP (M55351C00001)
  * Average number of UEs with active Power Saving BWP (M55351C00002)
  * Maximum number of UEs configured with 2 BWPs (M55351C01001)
  * Average number of UEs configured with 2 BWPs (M55351C01002)
* Added log collection: emil, L2L1 and TTI trace in case of lower than expected tput due to 
  PR807287: [25R1][RJIO][ST][ASOE][AQQJ][TDD] Low DL tput during Power Saving BWP Switch.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.
* Added L1IQ log collection and changed emil, L2L1 and TTI trace collection for every loop due to
  PR867867[CDRT][SBTS26R1][RJIO][ST][ASOE][AQQJ][TDD] Low DL tput during Power Saving BWP Switch.

#### History of changes
* 19.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1130 - Initial creation
* 22.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
* 17.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1378 - Added sleep 30s to trigger switch BWP profile to ES, 
due to new SCF.
* 05.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1420 - Added DateTime library import
             - https://jiradc.ext.net.nokia.com/browse/IWK-1424 - Added BTS state check

* 06.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1416 - Add emil,L2L1 and TTI trace due to tput problem.
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changing tput commands for RJIO
* 05.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Add emil,L2L1(BIP) and TTI trace collection
for every loop.
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1446 - Refactored test to work with both iPhone UEs
               and Android UEs
* 03.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1742 - Add L1IQ DL trace collection by UTF for every loop.
* 09.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1762 - Add Check If Wait For Next Counter Period Is Needed due to long iteration.

### Rjio_E2E_21_Snapshot_Content_Compare
The purpose of this test case is to verify if RFSW logs from radio module are included in snapshot.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* No UEs currently used in this test.

#### Test scenario defined by owner
* Step 1: Wait for 600s then connect to SMOD.
* Step 2: Connect to RMOD via FHNET container.
* Step 3: Collect RFSW logs on RMOD and download them to VM.
* Step 4: Collect snapshot and get RFSW file list from it.
* Step 5: Verify if every RFSW log exists in snapshot file list.
* Step 6: Check if startup, runtime and SOAP files exist in RMOD logs.
* Step 7: Close connection to RU and FHNET container.
* Step 8: Repeat steps 2-7 for each RMOD.
* Step 9: Check BTS state and history alarms.

#### Pass Criteria
* Connection to SMOD, RMODs and FHNET successful.
* RFSW logs are collected successfully.
* Snapshot is collected successfully.
* All RFSW log files found in snapshot file list.
* Startup, runtime and SOAP files exist in RMOD logs.
* Connections closed successfully.
* BTS on air, no unexpected faults.

#### Automatic TC steps
* Preconditions
* Looped Steps
  * Step 1: Connect To SMOD And Get RMOD Data
  * Step 2: Connect To RMOD Via FHNET Container
  * Step 3: Get RFSW Log File List From RMOD
  * Step 4: Collect Snapshot And Get RFSW File List
  * Step 5: Verify If Every RFSW Log Exists In Snapshot
  * Step 6: Check Startup Runtime And SOAP File In RMOD Logs
  * Step 7: Close Connection To RMOD
* Step 8: Check BTS State

#### Test case developer notes
* In 'Step 6: Check Startup Runtime And SOAP File In RMOD Logs' RMODs have assigned numbers.
  those numbers depend on amount of Made units RMOD has. E.g. for AQQJ, number is 8, because
  its HW family is cMAAr6.2_32T32R.
* At the moment of writing this note, library taf.ul.bts_components is maintained by MN RAN RD VRF WRO1 4 (Robert Wsiaki).

#### History of changes
* 18.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1138 - Initial creation
* 01.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1195 - Modified alarms verification
* 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1293 - Made changes for RF5.0
* 17.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1396 - Rjio_E2E_21_Snapshot_Content_Compare Improvement
* 17.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1378 - Add FID 4592 BTS Reset Cause to 
                                                                  ${SNAPSHOT_ALLOWED_FAULT_IDS}. Alarm visible after sw upgrade.
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1419 - Made changes to steps order and execution conditions
             - https://jiradc.ext.net.nokia.com/browse/IWK-1421 - Improved BTS state check
* 06.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1467 - Replaced taking data from FRIP.txt due to PR819027
* 12.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1547 - Refactoring test case to work with taf.ul.bts_components
                                                                  library for connecting to RMOD


### Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor
The purpose of this test case is to verify if ANR for NR neighbour works correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE

#### Test scenario defined by owner
* Step 1: Remove NRADJNRCELL and NRREL if any exist.
* Step 2: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 3: Perform attach to source cell.
* Step 4: Change attenuation for source and target cells, so UE will see target cell and source cell
  will be attenuated.
* Step 5: Detach UE.
* Step 6: Repeat steps 2-5.
* Step 7: Check if NR-NR neighbour was created by checking if NRADJNRCELL and NRREL exist.
* Step 8: Check BTS state.

#### Pass Criteria
* Attach performed.
* NRADJNRCELL and NRREL created.
* BTS on air, no unexpected faults.

#### Automatic TC steps
* Preconditions
* Step 1: Remove NRADJNRCELL And NRREL If Any Exist
* Looped Steps
  * Step 2: Set Attenuation On Ports
  * Step 3: Perform Attach
  * Step 4: Change Attenuation
  * Step 5: Detach UE
* Step 6: Check If NR-NR Neighbour Was Created
* Step 7: Check BTS State

#### Test case developer notes
* Name of automated test case: Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based.
* EMIL logs for control plane (with extension *.5gm) and IP capturing
  (capture point: A: IP traffic to/from BTS) are collected with UTF.
  You require to have UTF server set beforehand. Please make sure
  that it is up-to-date before reporting pronto.
* In case this test is interrupted please make sure that all traces on DCAP server
  as well as IP traffic capturing for both main BTS and HO BTS are stopped.
* This test uses UTF to collect logs which may be later used for debugging purposes.
  As such it should not fail due to those logs failing to start or stop.
  In such case warning message should be printed.
* This test requires variable to be imported before it starts:
  'DCAP_HOST' with keys 'ip', 'port', 'login', 'password'.
* In case of problems with UTF (former DCAP) it is possible to rise issues on DCAP Basic
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 09.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1142 - Initial creation
* 12.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1227 - Changed name of virtual environment variable
* 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
             - https://jiradc.ext.net.nokia.com/browse/IWK-1241 - Adapted test for RJIO2 TL
             - https://jiradc.ext.net.nokia.com/browse/IWK-1295 - Implemented additional logs collecting
               for debugging purposes
             - https://jiradc.ext.net.nokia.com/browse/IWK-1296 - Modified way of checking BTS state
             - https://jiradc.ext.net.nokia.com/browse/IWK-1297 - Updated 'Start Data Transfer' KW
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1423 - Improved BTS state check
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1490 - Modified virtual environment path
* 03.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1481 - Delete KW Get UE Info All
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1448 - Refactored test to work with both iPhone UEs
               and Android UEs

### Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_Ng_Based_With_Feature_IWK
The purpose of this test case is to verify if intra-frequency and inter-gNB HO is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real NR UE

#### Test scenario defined by owner
* Step 1: Remove NRADJNRCELL and NRREL if any exist.
* Step 2: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 3: Perform attach to source cell.
* Step 4: Change attenuation for source and target cells, so UE will see target cell and source cell
  will be attenuated.
* Step 5: Detach UE.
* Step 6: Repeat steps 2-5.
* Step 7: Check if NR-NR neighbour was created by checking if NRADJNRCELL and NRREL exist.
* Step 8: Check BTS state.
* Step 9: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 10: Perform attach to source cell.
* Step 11: Start collecting wireshark logs on VM connected to target gNB.
* Step 12: Start DL data transfer.
* Step 13: Change attenuation for source and target cells, so HO is performed.
* Step 14: Stop and collect wireshark logs.
* Step 15: Check messages for Inter-GNB HO.
* Step 16: Stop data transfer.
* Step 17: Check BTS state.

#### Pass Criteria
* Attach and data transfer were performed.
* NRADJNRCELL and NRREL created.
* HO was performed correctly.
* Expected messages appeared during HO.
* BTS on air, no unexpected faults.

#### Automatic TC steps
* Preconditions
* Step 1: Remove NRADJNRCELL And NRREL If Any Exist
* Looped Steps
  * Step 2: Set Attenuation On Ports
  * Step 3: Perform Attach
  * Step 4: Change Attenuation
  * Step 5: Detach UE
* Step 6: Check If NR-NR Neighbour Was Created
* Step 7: Check BTS State
* Step 8: Set Attenuation On Ports
* Step 9: Perform Attach
* Step 10: Start Collecting Wireshark Logs
* Step 11: Start DL Data Transfer
* Step 12: Change Attenuation
* Step 13: Stop And Collect Wireshark Logs
* Step 14: Check Messages For Inter GNB HO
* Step 15: Stop Data Transfer
* Step 16: Check BTS State

#### Test case developer notes
* Name of automated test case: Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based.
* EMIL logs for control plane (with extension *.5gm) and IP capturing
  (capture point: A: IP traffic to/from BTS) are collected with UTF.
  You require to have UTF server set beforehand. Please make sure
  that it is up-to-date before reporting pronto.
* In case this test is interrupted please make sure that all traces on DCAP server
  as well as IP traffic capturing for both main BTS and HO BTS are stopped.
* This test uses UTF to collect logs which may be later used for debugging purposes.
  As such it should not fail due to those logs failing to start or stop.
  In such case warning message should be printed.
* This test requires variable to be imported before it starts:
  'DCAP_HOST' with keys 'ip', 'port', 'login', 'password'.
* In case of problems with UTF (former DCAP) it is possible to rise issues on DCAP Basic
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 09.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1143 - Initial creation
* 12.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1227 - Changed name of virtual environment variable
* 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
             - https://jiradc.ext.net.nokia.com/browse/IWK-1242 - Adapted test for RJIO2 TL
             - https://jiradc.ext.net.nokia.com/browse/IWK-1295 - Implemented additional logs collecting
               for debugging purposes
             - https://jiradc.ext.net.nokia.com/browse/IWK-1296 - Modified way of checking BTS state
             - https://jiradc.ext.net.nokia.com/browse/IWK-1297 - Updated 'Start Data Transfer' KW
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1423 - Improved BTS state check
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changing tput commands for RJIO
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1490 - Modified virtual environment path
* 03.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1481 - Delete KW Get UE Info All
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1448 - Refactored test to work with both iPhone UEs
               and Android UEs

### Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
The purpose of this test case is to verify if ANR for EUTRA neighbour works correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real UE supporting both NR and LTE

#### Test scenario defined by owner
* Step 1: Remove NRADJECELL and NRRELE if any exist.
* Step 2: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 3: Perform attach to source cell.
* Step 4: Change attenuation for source and target cells, so UE will see target cell and source cell
  will be attenuated.
* Step 5: Detach UE.
* Step 6: Repeat steps 2-5.
* Step 7: Check if NR-LTE neighbour was created by checking if NRADJECELL and NRRELE exist.
* Step 8: Check BTS state.

#### Pass Criteria
* Attach performed.
* NRADJECELL and NRRELE created.
* BTS on air, no unexpected faults.

#### Automatic TC steps
* Preconditions
* Step 1: Remove NRADJECELL And NRRELE If Any Exist
* Looped Steps
  * Step 2: Set Attenuation On Ports
  * Step 3: Perform Attach
  * Step 4: Change Attenuation
  * Step 5: Detach UE
* Step 6: Check If NR-LTE Neighbour Was Created
* Step 7: Check BTS State

#### Test case developer notes
* Name of automated test case: Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR.
* This test assumes there is only one NRANRPRE object on source BTS. It may be
  worth considering changing this in the future.
* EMIL logs for control plane (with extension *.emil and *.5gm) and IP capturing
  (capture point: A: IP traffic to/from BTS) are collected with UTF.
  You require to have UTF server set beforehand. Please make sure
  that it is up-to-date before reporting pronto.
* In case this test is interrupted please make sure that all traces on DCAP server
  as well as IP traffic capturing for both main BTS and HO BTS are stopped.
* This test uses UTF to collect logs which may be later used for debugging purposes.
  As such it should not fail due to those logs failing to start or stop.
  In such case warning message should be printed.
* This test requires variable to be imported before it starts:
  'DCAP_HOST' with keys 'ip', 'port', 'login', 'password'.
* In case of problems with UTF (former DCAP) it is possible to rise issues on DCAP Basic
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.

#### History of changes
* 09.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1144 - Initial creation
* 12.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1227 - Changed name of virtual environment variable
* 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
             - https://jiradc.ext.net.nokia.com/browse/IWK-1298 - Adapted test for RJIO2 TL
             - https://jiradc.ext.net.nokia.com/browse/IWK-1295 - Implemented additional logs collecting
               for debugging purposes
             - https://jiradc.ext.net.nokia.com/browse/IWK-1296 - Modified way of checking BTS state
             - https://jiradc.ext.net.nokia.com/browse/IWK-1297 - Updated 'Start Data Transfer' KW
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1425 - Improved BTS state check
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1490 - Modified virtual environment path
* 03.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1481 - Delete KW Get UE Info All
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1449 - Refactored test to work with both iPhone UEs
               and Android UEs

### Rjio_E2E_64_Mobility_IRAT_Data_HO_With_N26
The purpose of this test case is to verify if inter RAT HO is performed correctly.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real UE supporting both NR and LTE

#### Test scenario defined by owner
* Step 1: Remove NRADJECELL and NRRELE if any exist.
* Step 2: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 3: Perform attach to source cell.
* Step 4: Change attenuation for source and target cells, so UE will see target cell and source cell
  will be attenuated.
* Step 5: Detach UE.
* Step 6: Repeat steps 2-5.
* Step 7: Check if NR-LTE neighbour was created by checking if NRADJECELL and NRRELE exist.
* Step 8: Check BTS state.
* Step 9: Set attenuation on ports, so that source cell is visible for UE and target cell is attenuated.
* Step 10: Perform attach to source cell.
* Step 11: Start collecting wireshark logs on VM connected to target eNB.
* Step 12: Start DL data transfer.
* Step 13: Change attenuation for source and target cells, so HO is performed.
* Step 14: Stop and collect wireshark logs.
* Step 15: Check messages with B2 event for Inter RAT HO for eNb.
* Step 16: Stop data transfer.
* Step 17: Check BTS state.

#### Pass Criteria
* Attach and data transfer were performed.
* NRADJECELL and NRRELE created.
* HO was performed correctly.
* Expected messages appeared during HO.
* BTS on air, no unexpected faults.

#### Automatic TC steps
* Preconditions
* Step 1: Remove NRADJECELL And NRRELE If Any Exist
* Looped Steps
  * Step 2: Set Attenuation On Ports
  * Step 3: Perform Attach
  * Step 4: Change Attenuation
  * Step 5: Detach UE
* Step 6: Check If NR-LTE Neighbour Was Created
* Step 7: Check BTS State
* Step 8: Set Attenuation On Ports
* Step 9: Perform Attach
* Step 10: Start Collecting Wireshark Logs
* Step 11: Start DL Data Transfer
* Step 12: Change Attenuation
* Step 13: Stop And Collect Wireshark Logs
* Step 14: Check Messages With B2 Event For Inter RAT HO For Enb
* Step 15: Stop Data Transfer
* Step 16: Check BTS State

#### Test case developer notes
* Name of automated test case: Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR.
* This test assumes there is only one NRANRPRE object on source BTS. It may be
  worth considering changing this in the future.
* EMIL logs for control plane (with extension *.emil and *.5gm) and IP capturing
  (capture point: A: IP traffic to/from BTS) are collected with UTF.
  You require to have UTF server set beforehand. Please make sure
  that it is up-to-date before reporting pronto.
* In case this test is interrupted please make sure that all traces on DCAP server
  as well as IP traffic capturing for both main BTS and HO BTS are stopped.
* This test uses UTF to collect logs which may be later used for debugging purposes.
  As such it should not fail due to those logs failing to start or stop.
  In such case warning message should be printed.
* This test requires variable to be imported before it starts:
  'DCAP_HOST' with keys 'ip', 'port', 'login', 'password'.
* In case of problems with UTF (former DCAP) it is possible to rise issues on DCAP Basic
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.


#### History of changes
* 09.11.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1145 - Initial creation
* 12.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1227 - Changed name of virtual environment variable
* 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1237 - Replaced old attenuator solution with new one
             - https://jiradc.ext.net.nokia.com/browse/IWK-1299 - Adapted test for RJIO2 TL
             - https://jiradc.ext.net.nokia.com/browse/IWK-1295 - Implemented additional logs collecting
               for debugging purposes
             - https://jiradc.ext.net.nokia.com/browse/IWK-1296 - Modified way of checking BTS state
             - https://jiradc.ext.net.nokia.com/browse/IWK-1297 - Updated 'Start Data Transfer' KW
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1425 - Improved BTS state check
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1428 - Changing tput commands for RJIO
* 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1490 - Modified virtual environment path
* 03.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1481 - Delete KW Get UE Info All
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1449 - Refactored test to work with both iPhone UEs
               and Android UEs

### Voice_over_NR
The purpose of this test case is to verify if VoNR call is performed.

* Author: monika.ceglarek@nokia.com
* Maintainer: marcel.behen@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* Real UE supporting NR

#### Test scenario defined by owner
* Step 1: Start wireshark.
* Step 2: Start DCAP - 5G full call scenario SIP Signalling logs collecting
* Step 3: Attach UE and start VoNR call.
* Step 4: Wait 330s for call to finish.
* Step 5: Collect DCAP logs.
* Step 6: Collect wireshark logs.
* Step 7: Check if VoNR was started by checking if correct packet appeared in wireshark logs.
* Step 8: Check if VoNR was stopped correctly by checking if correct packet appeared in wireshark logs.
* Step 9: Check if VoNR related counters (M55125C09515, M55125C09505, M55113C00003, M55125C09514) have correct values.
* Step 10: Check if correct SIP messages appeared in DCAP (EMIL) logs (only for branch 24R1 or earlier).

#### Pass Criteria
* Attach and VoNR were performed.
* Correct packet is visible in wireshark.
* One packet can be found in wireshark logs when using display filter:
  'ngap && ngap.qosFlowIdentifier == 1 && ngap.NGAP_PDU == 1'
* At least one packet (number may be higher than one if there was additional attach attempt)
  can be found in wireshark logs when using display filter:
  'ngap.pDUSessionID == 2 && ngap.nas == 0 && ngap.procedureCode == 28'
* At least one packet (number may be higher than one if there was additional attach attempt)
  can be found in wireshark logs when using display filter: 'ngap.nas == 2'
* Counters have correct values:
  * M55125C09515 = 0
  * M55125C09505 = 0
  * M55113C00003 = 0
  * M55125C09514 = 1
* 'REGISTER', 'SUBSCRIBE' and 'BYE' appeared in SIP messages collected with DCAP (only for branch 24R1 or earlier).

#### Automatic TC steps
* Preconditions
* Step 1: Start Wireshark Logs
* Step 2: Start SIP Logs Collecting
* Step 3: Perform VoNR
* Step 4: Stop DCAP Traces and Download Logs
* Step 5: Stop Wireshark Logs
* Step 6: Check If VoNR Was Performed
* Step 7: Check If VoNR Was Finished Correctly
* Step 8: Counter Verification
* Step 9: Check BTS State
* Return From Keyword If  not ${PERFORM_SIP_VERIFICATION}
* Step 10: Extract EMIL logs
* Step 11: Parse EMIL logs
* Step 12: Check BTS State

#### Test case developer notes
* This test checks if VoNR was performed by filtering packets in tshark with display filter:
  'ngap && ngap.qosFlowIdentifier == 1 && ngap.NGAP_PDU == 1' and checking if there is one such packet.
* This test checks if VoNR was finished correclty by filtering packets in tshark with display filters:
  'ngap.pDUSessionID == 2 && ngap.nas == 0 && ngap.procedureCode == 28' and 'ngap.nas == 2'
  and checking if there is at least one such packet. The number may be higher than one in case
  there is more than one attach attempt.
* This test checks if VoNR was finished without issues by checking counter values:
  * M55125C09515 = 0 (Number of 5QI-1 QoS flows released due to abnormal causes)
  * M55125C09505 = 0 (Number of 5QI-1 QoS flows released due to lost connection to UE)
  * M55113C00003 = 0 (Number of incoming UE CONTEXT MODIFICATION FAILURE received from gNB-DU)
  * M55125C09514 = 1 (Number of 5QI-1 QoS Flows releases considered to be Normal release)
* This test currently only supports SIP checking on branches 24R1 and lower due to change in trunk.
  More regarding this issue can be viewed inthoes threads and pronto:
  * https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic/-/issues/1049
  * https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic/-/issues/1052
  * https://pronto.ext.net.nokia.com/pronto/problemReportSearch.html?freeTextdropDownID=prId&searchTopText=PR756999
  There is CNI opened for adding this funcionality, but it will be available in later release:
  https://jiradc.ext.net.nokia.com/browse/CNI-121453. After it is added some parts of code
  may need updates for the test to work with new solution (most likely the part where parsing is done).
* EMIL logs (with extension *.5gm) are collected with DCAP. You require to have DCAP server set beforehand.
  Please make sure that it is up-to-date before reporting pronto.
* EMIL logs are converted to CSV using EMIL installed on UE PC. Please make sure
  to keep it up to date. In case this test is moved to a different configuration,
  please remember to install EMIL as this is not included in this test.
* Please make sure that path ${WINDOWS_TEMP_LOGS_DIR} exists on UE PC before running test.
* In case this test is interrupted please make sure that logs on UE PC in path: ${WINDOWS_TEMP_LOGS_DIR}
  are cleared as well as all traces on DCAP server for this BTS are stopped.
* CSV files in ${LOG_PATH}/dcap_logs/CSV are generated per trace. Those traces are later merged
  into one file and saved in ${LOG_PATH}/misc_logs/merged.csv.
* Since SIP messages are split, this test instead of searching for SIP first searches for
  'ITF_L2LOG_CU_HI_STREAMGTPUTRACEIND_ID' in which it searches for all strings matching regexp:
  'SIP/.{0,4} 200 OK.+?CSeq: \d+ [A-Za-z]+'. '.+?' is lazy quantifier - it means it when
  'SIP/.{0,4} 200 OK' is found it will look for the first appearance of substring matching
  'CSeq: \d+ [A-Za-z]+'. This way CSeq related to correct SIP should be chosen.
  After finding matches it searches in them for strings matching ' REGISTER$', ' SUBSCRIBE$' and " BYE$".
  If all are found Step 10 should pass.
* In case of problems with DCAP or EMIL it is possible to consult them on DCAP Basic and R&D Emil
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* Currently test should be able to support Android and Iphone UEs.
* This test requires variables to be imported before it: 'EMIL_HOST' with keys 'ip',
  'login', 'password' and 'DCAP_HOST' with keys 'ip', 'port', 'login', 'password'.
* To use iPhone UE instead of the Android UE test variable ${ADDITIONAL_UE_CAPABILITY} needs to be
  passed as REAL_IPHONE_UE. Otherwise, the test will use Android UE as default one.
* This test collects baseband logs for iPhone UE. The logs are saved in ${LOG_PATH}/baseband/
  and /Users/sranwro2/Downloads/ on Mac PC. Collecting and copying baseband logs from Mac to VM
  may take a few minutes.
* For baseband logs to be collected for iPhone UE dictionary ${MAC} needs to be created before the test.
  The dictionary should contain following keys: ip (IP of Mac PC), username (username for Mac PC),
  password (password for Mac PC). ${MAC} dictionary may be added, e.g. to UE configuration file.
* Logs on Mac are currently not removed from Mac PC. If you need them removed, please do so manually.
* Based on discussions in https://jiradc-mn.ext.net.nokia.com/servicedesk/customer/portal/2/SRNSUP-36005 
  and https://jiradc.ext.net.nokia.com/browse/IOTIS-6651, as well as chat with Kacper Sulima the method
  of verification for stopping VoNR was modified. It is related to the feature on iPhone that only drops
  the voice bearer while maintaining signaling link. This causes that UE only needs to request
  a new Voice QoS Flow (Dedicated Bearer), since it already is connected to IMS Core when making a second call.
  Therefore, the new packet which is verified during test can be found with display filter in wireshark:
  ngap.pDUSessionID != 1 && ngap.nas == 0 && ngap.id == 137 && ngap.procedureCode == 26.
  This is due to UE releasing only the Voice QoS Flow, while still keeping the PDU Session active,
  unlike before when UE also lost its IP address associated with that PDU session. The packets for
  ngap.procedureCode == 28 are no longer expected. At the point of writing this: if those packets
  are needed they may still be filtered if NAS-5GS protocol in wireshark has: 
  'Try to detect and decode 5G-EA0 ciphered messages' option marked.

#### History of changes
* 18.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1183 - Initial creation
* 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1249 - Changed verification method for VoNR
* 23.05.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1302 - Made changes for RF5.0
* 24.09.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1345 - Fixed error regarding incorrect number of arguments
                                                                  in 'Copy Emil Logs To Windows' KW
* 07.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1426 - Added BTS state check
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Removed the argument ${is_trunk_sw} from 
Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1566 - Fixed library conflict for 'Get Time'
* 05.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1600 - Delete sip-signalling-vonr from UTF log collection,
due to log collection issue.
* 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1602 - Increase the call duration and check
the UE information more quickly after VoNR.
* 21.11.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1607 - Refactored test to work with both iPhone UEs
               and Android UEs in one test case in testsuite
             - https://jiradc.ext.net.nokia.com/browse/IOTIS-6651 - Modified verification for stopping VoNR

### Upload_Baseline_SCF_After_SW_Upgrade
The purpose of this test case is to verify whether there is a baseline SCF on the BTS or if it needs to be uploaded.

* Author: mateusz.guziana@nokia.com
* Maintainer: mateusz.guziana@nokia.com

#### Configuration and mandatory parameters
* No additional requirements

#### UEs:
* No UEs currently used in this test.

#### Test scenario defined by owner
* Step 1: Check BTS State
* Step 2: Check if Active software on BTS is different than expected.
* Step 3: Check if baseline SCF is uploaded.
* Step 4: Migrate Scf
* Step 5: Perform Commissioning
* Step 6: Check BTS State

#### Pass Criteria
* Active software on BTS is the same as expected.
* SCF is uploaded
* BTS is on air
* No unexpected alarms appeared

#### Automatic TC steps
* Preconditions
* Step 1: Check the BTS state.
* Step 2: Verify if the active software on the BTS is different from what is expected.
* Step 3: Confirm if the baseline SCF is uploaded.
* Step 4: Migrate the SCF.
* Step 5: Perform Commissioning.
* Step 6: Check the BTS state again.

#### Test case developer notes
* The baseline SCF needs to be prepared for the dedicated release.
* The test will collect a snapshot from the first passed loop and all failed ones.

#### History of changes
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1505 - Initial creation
