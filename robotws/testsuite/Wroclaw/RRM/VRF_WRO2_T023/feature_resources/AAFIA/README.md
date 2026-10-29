# Test Plan for LTE4529 regression AirScale Dual MAA 16T16R B25/66 200W AAFIA

## Test Strategy and priorities
This is ad-hoc test plan for T-Mobile AAFIA regression coverage. 
Main goal is to perform basic NB-IoT calls on two different AAFIA sector configurations.
* Single Sector configuration covered by CB007256
* Dual Sector configuration covered by LTE4529
* NB-IoT basic calls and OAM scenario covered by LTE4852
Additionally, there will be also test for LTE switching transmission mode between TM4 and TM9
* Switching transmission modes between TM4 and TM9 covered by LTE5151
  
## TESTING SCOPE
* NB-IoT dual sector feature activation deactivation via SCF
* NB-IoT single sector feature activation deactivation via SCF
* Reconfiguration dual sector to single sector (online change)
* Reconfiguration single sector to dual sector (online change)
* NB-IoT paging and calls on single and dual sector 
* NB-IoT reconfiguration to non-anchor carrier
* Additional Layer 1 performance measurements for NB-IoT
* Switching transmission modes between TM4 and TM9 

## Test line requirements
2xASIA + 4xABIA + AAFB + AAIB + AHLOA
0x340000 = 5 # flag to speed up PM counters to 3 minute should be set

## UEs:
Real LTE UE - Nokia x20; 
NB-IoT (Quectel BC660K)

## References:
LTE4529
TF_LTE_SFS_RL1_3843
LTE4852



## Test cases

### RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition
The purpose of this test case is to verify non anchor carrier addition and guard band NB-IoT tput performed on anchor 
and non-anchor carrier on AAIB dual sector (part of AAFIA) radio.
The purpose of this test case is to also verify following counters related to Downlink Non-anchor carrier in SBTS environment:
M8204C0 - Sum of RRC connected NB-IoT UEs assigned to all DL non-anchor carriers.
M8204C3 - MAC PDU volume in DL for NB-IoT UEs assigned to all DL non-anchor carriers.
M8204C6 - Number of used NB-IoT DL resources on DL non-anchor carriers.
M8204C7 - Available NB-IoT DL resources on DL non-anchor carriers.

* Owner: piotr.smolak@nokia.com
* Author: oleksandr.kulieshov@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Configuration and mandatory parameters
- eNB configuration base on T-Mobile network settings
- HW LTE: AMIA + 2xASIA + 4xABIA + AAFB + AAIB with NBIoT + AHLOA
- LTE cells bandwidth 15MHz with guardband NBIoT define
- Dual sectors configured on AAIB and AAFB (part of AAFIA radio module)
- For counters checking flag should be set (0x340000 = 5) counters will be calculated every 3 minutes.
- Script for AT commands sending should be located on UE PC (e.g.: C:/Users/sranwro2/Desktop/at_send_command.py )

#### UEs:

Real LTE UE - Nokia x20; 
NB-IoT (Quectel BC660K)

#### Test scenario defined by owner
* Step 1: BTS are commissioned and onAir with NB-IoT cells configured on dual sector
* Step 2: Perform reconfiguration NB-IoT cells to add 3 non-amchor carriers (numDlNonAnchCarrierNB, numUlNonAnchCarrierNB) in DL and UL.
* Step 3: Perform attach to NBIoT cell and DL call in NB-IoT cell. 
* Step 4:Check DL counters to NB-IoT non-anchor carriers:
         M8204C0 should have value: 180
         M8204C3 should have value: > 490000
         M8204C6 should have value: > 24500 
         M8204C7 should have value: 540000

#### Pass Criteria
* No unexpected faults after adding non-anchor carriers 
* The values of the counters are as expected.

#### Automatic TC steps
* Preconditions
* Step 1  Activate Additional Non-Anchor Carriers
* Step 2: Start Data Transfer In NB-IoT cell
* Step 3: Collect And Compare Counters Values

#### Test case developer notes
This test-case covers two types of configurations for AAFIA scope of test-cases:
 - RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition __LTE4852_LTE4529
 - RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition__ LTE4852_CB007256
For this test-case in the test suite have been defined variables to provide the connectivity to the UEPC and FTP server:
${FTP_IOT}, ${PC_IOT}. The values of checked counters are expected for specific configuration.  


#### History of changes
30.11.2022  https://jiradc.ext.net.nokia.com/browse/IWK-1014 - Initial creation
11.01.2024  https://jiradc.ext.net.nokia.com/browse/IWK-1178 Change counters collection interval from 3 min. to 15 min
19.01.2026  https://jiradc.ext.net.nokia.com/browse/IWK-1746 - Adjusted test cases to new config

### RRM__Online_reconfiguration_dual_sector_to_single_sector__CB007256
The purpose of this test case is to verify online sector reconfiguration via delta-commissioning from dual sector configuration to single sector 
configuration without restart BTS.

* Owner: piotr.smolak@nokia.com
* Author: oleksandr.kulieshov@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Configuration and mandatory parameters
- eNB configuration base on T-Mobile network settings
- HW LTE: AMIA + 2xASIA + 4xABIA + AAFB + AAIB with NBIoT + AHLOA
- LTE cells bandwidth 15MHz with guardband NBIoT define
- Dual sectors configured on AAIB and AAFB (part of AAFIA radio module)
- For counters checking flag should be set (0x340000 = 5) counters will be calculated every 3 minutes.
- Script for AT commands sending should be located on UE PC (e.g.: C:/Users/sranwro2/Desktop/at_send_command.py )

#### UEs:

Real LTE UE - Nokia x20; 
NB-IoT (Quectel BC660K)

#### Test scenario defined by owner
* Preconditions
  - T-Mobile dual sector configuration on AAFIA RF module (AAFB and AAIB)
  - guardband NBIoT define on AAIB RF module 
* Step 1: BTS are commissioned and onAir with NB-IoT cells configured on dual sector AAIB RF module.
* Step 2: Perform online recommissioning dual sector configuration to single sector configuration 
          on both AAIB and AAFB RF modules with Massive MIMO profile set to SingleSectorBFProf(0 degree)
* Step 3: Perform data transfer via LTE single cell configuration on AAIB RF module and NB-IoT call.

#### Pass Criteria
* No unexpected faults occur during test ongoing


#### Automatic TC steps
* Preconditions
* Step 1: Perform Online Recomissioning To Single Sector
* Step 2: Perform LTE DL Data Transfer
* Step 3: Perform Data Transfer In NB-IoT cell

#### Test case developer notes
Since this is a client configuration, all object IDs remain the same as the client. So in this TC some objects have fixed names e.g.: MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-204 or
MRBTS-${LNBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-204 or
MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-61/CAREL-4
For this test-case in the test suite have been defined variables to provide the connectivity to the UEPC and FTP server:
${FTP_IOT}, ${PC_IOT}.

#### History of changes
16.01.2023  https://jiradc.ext.net.nokia.com/browse/IWK-1014 - Initial creation


### RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256
The purpose of this test case is to verify if configuration is applied correctly in loop. There will be following transitions:
1_Dual Sector with NBIoT (original SCF)                 -> 
2_Dual Sector without NBIoT    (online)                 -> 
3_Single Sector with NBIoT                              -> 
4_Single Sector without NBIoT  (online)                 -> 
1_Dual Sector with NBIoT (Original SCF)
Reconfiguration via SCF upload should be repeated 5 times.

* Owner: piotr.smolak@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  BTS are commissioned and onAir with NB-IoT cells configured on dual sector AAIB RF module.
* Step 2:
  Perform offline BTS recommissioning by loading configuration Dual Sector with NBIoT guardband cells.
* Step 3:
  Perform online BTS recommissioning by loading configuration Dual Sector without NBIoT guardband cells.
* Step 4:
  Perform offline BTS recommissioning by loading configuration Single Sector with guardband NBIoT
* Step 5:
  Perform online BTS recommissioning by loading configuration Single Sector without guardband NBIoT
* Step 6:
  Repeat steps 2-5 5 times.
* Step 7:
  Perform offline BTS recommissioning by loading configuration Dual Sector with NBIoT guardband cells

#### Pass Criteria
* No unexpected faults occur during test ongoing

#### Automatic TC steps
* Preconditions
* Looped Steps
  * Step 1: Perform Offline Recomissioning To Dual Sector With NB-IoT
  * Step 2: Check If Configuration Has Dual Sector And NB-IoT
  * Step 3: Perform Online Recomissioning To Dual Sector Without NB-IoT
  * Step 4: Check If Configuration Has Dual Sector And No NB-IoT
  * Step 5: Perform Offline Recomissioning To Single Sector With NB-IoT
  * Step 6: Check If Configuration Has Single Sector And NB-IoT
  * Step 7: Perform Online Recomissioning To Single Sector Without NB-IoT
  * Step 8: Check If Configuration Has Single Sector And No NB-IoT

#### Test case developer notes
* At the end of test if variable 'REVERT_TO_ORIGNAL' is set to True test will revert to SCF saved at the beginning of the test.

#### History of changes
* 24.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1047 - initial creation
* 08.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1062 - moved 'Calculate Delta Between SCFs' to ca_IWK.robot resource file
* 19.01.2026  https://jiradc.ext.net.nokia.com/browse/IWK-1746 - Adjusted test cases to new config


### RRM__Guardband_NB-IoT_cell_handling_block_unblock
The purpose of this test case is to verify OAM block/unblock scenario to check
that guard band NB-IoT call is possible after OAM operation on AAIB dual sector
(part of AAFIA) radio.

#### Test specific Preconditions
  * guardband NBIoT defined on AAIB RF module
  * nonAnchor carriers not defined
  * For dual sector:
    * T-Mobile dual sector configuration on AAFIA RF module (AAFB and AAIB)
  * For single sector:
    * T-Mobile single sector configuration on AAFIA RF module (AAFB and AAIB)

* Owner: piotr.smolak@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  BTS is commissioned and onAir with NB-IoT cells configured on dual sector AAIB RF module.
* Step 2:
  Perform attach to NB-IoT cell before blocking LTE cells.
* Step 3:
  Make DL call in NB-IoT cell.
* Step 4:
  Release ongoing data call in NB-IoT cell. Wait for the UE to be dropped to ECM idle state, (can be verified in wireshark logs).
* Step 5:
  Block LTE cell handling guardband NB-IoT cell.
* Step 6:
  Check fault and corresponding alarm for blocked cell. Both LTE and NB-IoT cells should have raised fault 49 about blocked cell.
* Step 7:
  Unblock LTE cell. Cell should change state to unblocked. Fault and corresponding alarm should be cleared.
* Step 8:
  Perform attach to NB-IoT cell.
* Step 9:
  Make DL call in NB-IoT cell.
* Step 10:
  Release ongoing data call in NB-IoT cell. Wait for the UE to be dropped to ECM idle state, (can be verified in wireshark logs).
* Step 11:
  Check if NB-IoT UE can be paged with ping or downlink data transfer.
* Step 12:
  Repeat scenario for steps 9, 10, 11 3 times.


#### Pass Criteria
* No unexpected faults occur during test ongoing

#### Automatic TC steps
* Preconditions
* Step 1: Perform Attach To NB-IoT Cell
* Step 2: Perform Data Transfer In NB-IoT Cell
* Step 3: Check If UE Changed State To Idle After Attach
* Step 4: Check If UE Changed State To Idle After Data Transfer
* Step 5: Block LTE Cell Related To NB-IoT Cell
* Step 6: Check BTS State After Cell Block
* Step 7: Unblock LTE Cell Related To NB-IoT Cell
* Step 8: Check BTS State After Cell Unblock
* Step 9: Perform Attach To NB-IoT Cell
* Step 10: Check If UE Changed State To Idle After Attach
* Looped Steps
  * Step 11: Perform Data Transfer In NB-IoT Cell
  * Step 12: Check If UE Changed State To Idle After Data Transfer
  * Step 13: Check Paging For NB-IoT Cell
* Step 14: Check BTS State After Paging

#### Test case developer notes
* In case of dual sector configuration only one LTE cell is blocked, not both.
* If needed QRX level for second NB-IoT cell (dual sector configuration) can be changed in testsuite.
* Sector type is checked in testsuite at the moment of adding this test to repository.
* This test case covers: RRM__Guardband_NB-IoT_cell_handling_block_unblock__LTE4852_LTE4529
  and RRM__Guardband_NB-IoT_cell_handling_block_unblock__LTE4852_CB007256

#### History of changes
* 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1055 - initial creation
* 09.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1534 - removed CNI-61110 check
* 19.01.2026  https://jiradc.ext.net.nokia.com/browse/IWK-1746 - Adjusted test cases to new config


### RRM__LTE_data_transfer_switching_TM4_TM9
The purpose of this test case is to verify LTE downlink throughput on AAIB
(part of AAFIA) dual or single sector radio, considering transmission mode switch
between TM4 and TM9 via RRC reconfiguration depending on operator trigger conditions.

Counters should be also verified and compared to the number of RRC reconfiguration
messages from UE side when transmission mode switches from TM4 to TM9 or from TM9 to TM4:
* RRC Connection Reconfiguration attempts for switching from TM4 to TM9 (M8008C43)
* RRC Connection Reconfiguration success for switching from TM4 to TM9 (M8008C44)
* RRC Connection Reconfiguration attempts for switching from TM9 to TM4 (M8008C45)
* RRC Connection Reconfiguration success for switching from TM9 to TM4 (M8008C46)


#### Test specific Preconditions
  * guardband NBIoT defined on AAIB RF module
  * For dual sector:
    * T-Mobile dual sector configuration on AAFIA RF module (AAFB and AAIB)
  * For single sector:
    * T-Mobile single sector configuration on AAFIA RF module (AAFB and AAIB)

* Owner: piotr.smolak@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
For dual sector configuration:
* Step 1:
  BTS are commissioned and onAir with NB-IoT cells configured
  and 8x4 LTE MIMO cell configured on dual sector AAIB RF module.
* Step 2:
  Block LTE cell form dual sector configuration on AAIB.
* Step 3:
  Check fault and corresponding alarm for blocked cell. Both LTE and NB-IoT
  cells should have raised fault 49 about blocked cell.
* Step 4:
  Perform attach to LTE one not blocked sector and make DL call in dual sector
  configuration on AAIB RF module
* Step 5:
  Increase attenuator above threshold define by parameters: tm4to9CqiTh or tm4to9CqiTh256QAM
* Step 6:
  Check and count number of transmission mode change from transmissionMode-r10 tm4
  to transmissionMode-r10 tm9-v1020 via RRCConnectionReconfigurationRadio
* Step 7:
  Decrease attenuator below threshold define by parameters: tm9to4CqiTh or tm9to4CqiTh256QAM
* Step 8:
  Check and count number of transmission mode change from transmissionMode-r10 tm9-v1020
  to transmissionMode-r10 tm4 via RRCConnectionReconfigurationRadio
* Step 10:
  Compare number of transmission modes that was changed during
  RRCConnectionReconfigurationRadio with dedicated counters:
  RRC Connection Reconfiguration attempts for switching from TM4 to TM9 (M8008C43)
  RRC Connection Reconfiguration attempts for switching from TM9 to TM4 (M8008C45)
  RRC Connection Reconfiguration success for switching from TM4 to TM9 (M8008C44)
  RRC Connection Reconfiguration success for switching from TM9 to TM4 (M8008C46)

For single sector configuration:
* Step 1:
  BTS are commissioned and onAir with NB-IoT cells configured
  and 8x4 LTE MIMO cell configured on single sector AAIB RF module.
* Step 2:
  Perform attach to LTE sector in single sector configuration on AAIB RF module
* Step 3:
  Increase attenuator above threshold define by parameters: tm4to9CqiTh or tm4to9CqiTh256QAM
* Step 4:
  Check and count number of transmission mode change from transmissionMode-r10 tm4
  to transmissionMode-r10 tm9-v1020 via RRCConnectionReconfigurationRadio
* Step 5:
  Decrease attenuator below threshold define by parameters: tm9to4CqiTh or tm9to4CqiTh256QAM
* Step 6:
  Check and count number of transmission mode change from transmissionMode-r10 tm9-v1020
  to transmissionMode-r10 tm4 via RRCConnectionReconfigurationRadio
* Step 7:
  Compare number of transmission modes that was changed during
  RRCConnectionReconfigurationRadio with dedicated counters:
  RRC Connection Reconfiguration attempts for switching from TM4 to TM9 (M8008C43)
  RRC Connection Reconfiguration success for switching from TM4 to TM9 (M8008C44)
  RRC Connection Reconfiguration attempts for switching from TM9 to TM4 (M8008C45)
  RRC Connection Reconfiguration success for switching from TM9 to TM4 (M8008C46)

#### Pass Criteria
* No unexpected faults occur during test ongoing

#### Automatic TC steps
* Preconditions
* Step 1: Start Collecting Control Plane Logs
* Step 2: Perform LTE DL Data Transfer
* Step 3: Waiting For New Counter Period To Begin
* Step 4: Waiting For New Counter Period To Begin
* Step 5: Increase Cell Attenuation
* Step 6: Decrease Cell Attenuation
* Step 7: Waiting For New Counter Period To Begin
* Step 8: Collect PM Counters
* Step 9: Stop LTE Data Transfer
* Step 10: Stop Collecting Control Plane Logs
* Step 11: Extract EMIL logs
* Step 12: Parse EMIL logs

#### Test case developer notes
* In case of dual sector configuration one LTE cell is blocked.
* Values of attenuation needed during test need to take into consideration
  values of CQI parameters on the configuration. Parameters:
  * TMSWPR/tmSwitchThresholdMMimoDef/tm4to9CqiTh,
  * TMSWPR/tmSwitchThresholdMMimoDef/tm9to4CqiTh,
  * TMSWPR/tmSwitchThresholdMMimoDef256QAM/tm4to9CqiTh256QAM,
  * TMSWPR/tmSwitchThresholdMMimoDef256QAM/tm9to4CqiTh256QAM
* Please make sure that value of parameter SIB/qrxlevmin has proper value.
* Sector type is checked in testsuite at the moment of adding this test to repository.
* EMIL logs are collected with DCAP. You require to have DCAP server set beforehand.
  Please make sure that it is up-to-date before reporting pronto.
* EMIL logs are converted to CSV using EMIL installed on UE PC. Please make sure
  to keep it up to date. In case this test is moved to a different configuration,
  please remember to install EMIL as this is not included in this test.
* This test case covers: RRM__LTE_data_transfer_switching_TM4_TM9__LTE5151_LTE4529
  and RRM__LTE_data_transfer_switching_TM4_TM9__LTE5151_CB007256
* It is assumed that counters verified during this test should have values higher than 0.
  It is not necessarily problem with software if those values are 0. It may be
  connected with radio conditions, so please make sure that attenuation required
  in test is set correctly. However since this test should check if counter works
  it was decided that this value should be greater than 0, so if it is not test will fail.
  It was also discussed with test owner that number of attempts and number of successes
  for both pairs of counters (M8008C43 and M8008C44 as well as M8008C45 and M8008C46) should
  be equal.
* In case this test is interrupted please make sure that logs on UE PC in path: ${WINDOWS_TEMP_LOGS_DIR}
  are cleared as well as all traces on DCAP server for this BTS are stopped.
* PM files timestamp has format: "YYYY-mm-dd HH:MM:SS<'+' or '-'>HH:MM", e.g. 2023-07-01 00:51:00+02:00.
  EMIL logs do not have the +/- part, but they have microseconds e.g. 2023-06-30 20:54:42.432485.
  Time format for PM files is converted during test (the file names are not changed it is only used
  to pass time constraints for 'search_and_count_transmission_mode_changes' method from Emil.py).
* CSV files in ${LOG_PATH}/dcap_logs/CSV are generated per trace. Those traces are later merged
  into one file and saved in ${LOG_PATH}/misc_logs/merged.csv. This is the reason why date/time
  in those files may not be chronological (e.g. overlapping connections).
* Due to DCAP/EMIL creating separate EMIL file at XX:00 and XX:30 (full hour and half-past)
  before starting LTE data transfer if current minutes on BTS are outside of <0;15) and <30;45)
  range a sleep is added that waits until XX:00 or XX:30. This was done because in new file
  CSV conversion is not able to read call that did not start in this file (it started in
  the previous one). This solution was possible since steps during which data transfer
  is ongoing should not take more than 15min. In case this changes please consider changing
  this solution to a different one.
* In case of problems with DCAP or EMIL it is possible to consult them on DCAP Basic and R&D Emil
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* This TC needs 'DCAP_HOST' dictionary imported from ${ABSTRACT_LIB_CONFIG}.
  Dictionary should contain keys 'ip', 'port', 'login' and 'password' for connecting with UTF

#### History of changes
* 23.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1105 - initial creation
* 11.01.2024  https://jiradc.ext.net.nokia.com/browse/IWK-1178 Change counters collection interval from 3 min. to 15 min
* 07.03.2024  https://jiradc.ext.net.nokia.com/browse/IWK-1224 Move DCAP credentials to yaml file
* 15.03.2024  https://jiradc.ext.net.nokia.com/browse/IWK-1231 Add "Check Status Of Traces" KW
* 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1333 - remove  "dir_search_str=controlPlane" from "Convert Files To CSV On Remote Windows Host" KW
* 10.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1347 - added variable ${APN} for 'Start Data Transfer' KW
* 28.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1433 - Replaced Run Keyword Unless with IF block
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.
* 09.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1534 - removed CNI-61110 check
* 19.01.2026  https://jiradc.ext.net.nokia.com/browse/IWK-1746 - Adjusted test cases to new config
