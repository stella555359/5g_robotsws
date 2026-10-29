# CB005738 - LTE-NR DSS with Superfast Coordination and CB007738 NR-LTE DSS: Superfast coordination
Robot test suite for features CB005738 and CB007738.

## Test line requirements
This section is taken from automation requests.

### Example configuration
Configuration will be the same as for 5GC001745 and CB005860 tests.

### Required initial BTS state (not to be checked but provided directly from SCF)

#### LTE
* Six LTE cells configured, three with DSS disabled all the time (cells unlocked) and three where DSS phase 3 is set
(cells unlocked).

* All cells are unlocked LTE cell is up and running in FDD mode with correct software load supporting this
feature.
* RF sharing between LTE and NR with two CPRI links.
* LTE1710 'Sync Hub Direct Forward' and LTE4461 'NR-LTE FDD concurrent operation for CPRI RUs' is configured between gNb and eNb
* EN-DC is configured between:
  * LTE cell (PCell), that is not the LTE cell that is nominated to share the spectrum with an NR cell,
  * NR cell (PSCell), that is going to share the spectrum with the LTE cell
* lteNrDssDlRatio/ minNrDssRatio= 5
* lteNrDssDlRatio/ maxNrDssRatio = 100
* lteNrDssUlRatio/ minNrDssRatio= 5
* lteNrDssUlRatio/ maxNrDssRatio = 70
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/blankedPucch is set to 0
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/selectOuterPuschRegion  is set to 'None'
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/APUCCH_FDD/selectPrachRegion is not set to 'InnerUpperEdge'
* LNBTS/actLteNrDss = true
* For each cell that should be used as LTE DSS partner cell:
  * LNCEL/lteNrDssMode = DSS_Phase_III
  * LNCEL/DSSNR is set in accordance with values and ranges available in the NIDD
  * MRBTS/LNBTS/LNCEL/DSSNR/actLteNrDssFastAlloc = true
* MRBTS/LNBTS/otdoaProfileList/otdoaPhaseErrorThreshold = 1500
* MRBTS/LNBTS/otdoaProfileList/otdoaSyncSourceType = TOP-P
* Cell 1:
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 7
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames = 1
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB
* Cell 2:
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 47
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames =1
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB
* Cell 3:
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsConfigurationIndex = 151
  * MRBTS/LNBTS/LNCEL/LNCEL_FDD/prsNumDlFrames = 2
  * MRBTS/LNBTS/LNCEL/prsBandwidth = 50 PRB


#### 5G
* gNb operational.
* A cell is configured as shared NR cell.
* Cells are unlocked.
* List of features to be activated on NR side:
  * 5GC000474 X2 Management for NSA mode 3x operation
  * 5GC000577 TRS Support of NSA interfaces (X2 and S1-U) over IPv4 / IPv6
  * 5GC000475 SgNB Addition and Release for NSA mode 3x operation
  * 5GC000570 5G - LTE flow control at X2
  * 5GC000482 UE capability handling for NSA mode 3x operation
  * 5GC000543 Ciphering of U-Plane (NSA option 3x)
  * 5GC000480 Radio Admission Control for NSA mode 3x operation
  * 5GC000479 UE inactivity handling for NSA mode 3x operation
* 5GC001904 enabled.
* All three NR cells configured correctly, sharing enabled on cell level.
* lteNrDssDlRatio/ minNrDssRatio= 5
* lteNrDssDlRatio/ maxNrDssRatio = 100
* lteNrDssUlRatio/ minNrDssRatio= 5
* lteNrDssUlRatio/ maxNrDssRatio = 70
* Shared NR cells are unlocked.
* gNb in sync with eNb.
* MRBTS/NRBTS/actLteNrDss = true
* MRBTS/NRBTS/NRCELL/lteNrDssMode = DSS_Phase_3
* MRBTS/NRBTS/NRCELL/NRDSSLTE/actLteNrDssFastAlloc = true

## Test cases

### CB005738_CB007738_5G_in_SBTS_with_Superfast
### CB005738_CB007738_DSS_LTE-NR_SuperFast_allocation_verification_15Mhz_SA
The purpose of this test is to check basic functionality of CB005738 and CB007738 features.

#### Test specific Preconditions
* On eNB side:
  * For tested cell:
    * LNCEL/actDrx = true
    * LNCEL/actSmartDrx = true
    * LNCEL/DRX and SDRX in all profiles "drxInactivityT = 10" or lowest possible value
      if 10 is unavailable, "drxOnDuratT = 10" or lowest possible value if 10 is unavailable,
      "drxRetransT = 16" or lowest possible value if 16 is unavailable
* On gNB side:
  * None

* Owner: adam.szczerba@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step1: Start NR DSS burst traffic
* Step2: Start LTE DSS burst traffic for about 5min
* Step3: Release calls

#### Pass criteria
* Shared NR and LTE cells are onAir
* No unexpected faults
* During 5min call no unexpected radio link failure or reconfiguration. Call is stable.
* From CRM logs DSS allocation changes happens with 10ms time at least periodically

#### Automatic TC steps
* Preconditions
* Step 1: Start Collecting EMIL Logs
* Step 2: Start LTE And NR Burst Call
* Step 3: Wait 5 Min And Search For CRM Messagess In Syslog
* Step 4: Stop Burst Traffic
* Step 5: Wait For EMIL To Stop
* Step 6: Analyze Time Difference Of CRM Prints
* Step 7: Parse EMIL logs

#### Developer test case notes
* This test case covers CB005738_CB007738_5G_in_SBTS_with_Superfast
  and CB005738_CB007738_DSS_LTE-NR_SuperFast_allocation_verification_15Mhz_SA.
  The difference is that they need to be run o different configurations.
  Name of automatic test case: CB005738_CB007738_5G_in_SBTS_with_Superfast.
* How to analyze CRM logs from snapshot can be found on our DSS Hints Conflu page
  https://confluence.ext.net.nokia.com/display/CV/DSS+Hints
* This test case requires eNB swconfig flag for enabling CRM prints for superfast in syslog:
  0x670016=0x10
* This test uses iperf 3. Please make sure it is installed on server used for this test.
  Recommended version is >= 3.7 (checked on version 3.9: iperf3 --version
  iperf 3.9 (cJSON 1.7.13)
  Linux SRAN_Iperf_SRN 5.9.12-1.el7.elrepo.x86_64 #1 SMP Tue Dec 1 14:23:29 EST 2020 x86_64
  Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm
  setting, sendfile / zerocopy, socket pacing)
* It is a good idea to run required steps of 'DEV__Emil_env_preparation'
  to prepare TL for this TC. If this is not done, please perform required
  actions manually: installation of EMIL on VM where this TC is executed,
  downloading and extracting SACKs for current ENB SW, copying SACKs to remote
  Windows host, creating emil.csv.
* This test only changes parameters: 'actDrx', 'actSmartDrx' for tested cell. Other precondition
  parameters ('drxInactivityT', 'drxOnDuratT', 'drxRetransT') need to be set for this test in SCF
  before the test.
* EMIL in this test runs in asynchronous mode using async library. Due to this
  please be careful when aborting this test case. It is better to wait until
  the thread has finished.
* Parsing of EMIL logs is performed on remote Windows host. Data for this host is taken
  from first UE in ta_us_config.yaml. This is required since Linux EMIL does not support
  conversion of logs to CSV format. It also means that EMIL needs to be already installed
  on Windows host for this test to work correctly ('DEV__Emil_env_preparation' TC does not
  handle this operation).
* List of causes in 'radioNetwork' cause group that this test searches for in step 7:
  * 'unspecified'
  * 'radio-connection-with-ue-lost'
  * 'radio-resources-not-available'
  * 'failure-in-radio-interface-procedure'
  * 'cell-not-available'
* If test will be aborted or fail in the middle of the test please clean all remaining EMIL logs
  in order to prevent them from mixing with logs from next execution in case of using the same
  logs paths.
* In case of problems with EMIL due to software changes or new version of EMIL required
  for Linux please contact EMIL support group:
  I_MBB_LTE, Emil_Support (Nokia - Global) <emil_support.i_mbb_lte@nokia.com>

#### History of changes
* 17.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-718 - Initial creation
             - https://jiradc.ext.net.nokia.com/browse/IWK-743 - Initial creation
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-912 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-972 - Moved documentation to robotws


### CB005738_CB007738_Superfast_DSS_with_NR_CDRX_functionality
The purpose of this case is to check if CDRX is correctly configured for 5G SA UE in shared DSS cell with CB005738_CB007738_Superfast feature .

#### Test specific Preconditions
* on eNB and gNB actLteNrDssFastAlloc=true
* on gNB actRateMatchedCsiIm=true

* Owner: adam.szczerba@nokia.com
* Author: oleksandr.kulieshov@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Test scenario defined by owner
* Step1: Perform 5G SA UE attach to 5G DSS cell and reach max Tput for DL and UL correlated with administered sharing ratios.
* Step2: Verify if F1AP: UEContextModificationRequest message contains “id-DRXCycle” section
* Step3: Verify if F1AP: UEContextModificationResponse is sent back from UE and that it contains drx-Config setup data with expected values

#### Pass criteria
* Attach to 5G DSS cell successful.
  Max Tput reached for DL and UL.
* Request from NR to UE to configure cDRX is sent
* Response from UE to NR with configured cDRX parameters is received.
  cDRX parameters corresponds to NR cDRX configuration

#### Automatic TC steps
* Preconditions
* Step 1: Start DL/UL DT In NR Cell And Verify T-put
* Step 2: Verify If F1AP Messages Contain DRXCycle Section
* Step 3: Compare CDrx Value Between SCF And Tcpdump

#### History of changes
* 28.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-744 - Initial creation
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-913 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-972 - Moved documentation to robotws
* 23.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1045 - fixed KW Start Data Transfer throughput=${NR_EXPECTED_UL_TPUT} Mbits/sec
  Start Data Transfer  throughput=${NR_EXPECTED_DL_TPUT} Mbits/sec
* 24.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1046 - Changing 'Sleep' times for download tcpdump from SBTS
* 13.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1058 - Changing 'Sleep' times for download tcpdump from TL Partynice
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'

### CB005738_CB007738_DL_LTE_GBR_data_transfers_with_concurrent_NR_and_LTE_non_GBR_connections_20MHz
The purpose of this test is to check NR and LTE traffic with VoLTE.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None

* Owner: kamila.gmerek@nokia.com
* Author: przemyslaw.szmaj@nokia.com
* Maintainer: oleksandr.kulieshov@nokia.com

#### Test scenario defined by owner
1.  Perform nGBR traffic in downlink direction on NR UE. Iperf command in iperf server
iperf -c ip address of NRUE -u -i 1 -t 600 -p 6050 -l 1350 -b 200M.
2. Step 2 have to be performed during step 1 execution. nGBR traffic in dolnlink LTE UE call. iperf command on iperf server
iperf -c ip address of LTEUE -u -i 1 -t 600 -p 6050 -l 1350 -b 100M.
3. During nGBR LTE and NR downlink traffic perform VoLTE call between 2 VoLTE UEs.

After logs collection release all calls.

#### Pass criteria
* Call is stable.
* During VoLTE call in CRM logs DSS allocation changes happens with 10ms time at lease periodically, sharing ratio for LTE calls can not be less than 50%
* Xp_logs from syscomdump: during VoLTE call GBR load have to be visible in both DL and UL direction (enDssUlQosLoadMeasurement.measuredGbrLoad and enDssDlQosLoadMeasurement.measuredGbrLoad greater than 0), but some logs with GBR load with value 0 are acceptable
* Xp_logs: nGBR LTE and NR load  for DL direction (dssDlQosLoadMeasurement. measuredNgbrNnbrLoad) is stable with value around 90% - 100% (but not higher!)

#### Automatic TC steps
* Preconditions 
* Step 1: Start DL NR Call
* Step 2: Start DL LTE Call
* Step 3: Collect Syscomdump Without VoLTE
* Step 4: Analyze Syscomdump Without VoLTE
* Step 5: Start Syslog Collection
* Step 6: Start Voice Call
* Step 7: Collect Syscomdump With VoLTE
* Step 8: Analyze Syscomdump With VoLTE
* Step 9: Wait For CRM Message In Syslog
* Step 10: End Syslog Collection 
* Step 11: Stop DL LTE Call and NR Call
* Step 12: Stop Voice Call
* Step 13: Analyze Time Difference Of CRM Prints

#### History of changes
* 10.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-742 - Initial creation
* 04.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-889 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-972 - Moved documentation to robotws
* 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1051 - changed the name of the test variable with
               with physical LTE cell ID to describe it more accurately, changed steps of TC so that syscomdump
               is divided in two parts (with and without VoLTE), also analysis of the logs is separated from its
               collection, added necessary teardown for Tshark, increased iperf bandwidths to create max tput conditions
* 22.03.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1222 - adapt TC for Klecina TL: add additional syslog collection
               for checking the CRM prints, adjust iperf tput values, change VoLTE voice call
               so that it is performed to autoresponder rather than between two UEs, parametrize all necessary
               variables, change setup/teardown to Inter RAT.
* 16.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1350  application of taf.sw.syslog library, adjustment of the search method the print of syslog
* 08.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1390  Adjustment regexp for 25R1 branch
* 27.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1398  fixed incorrect regex
* 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1484  Increased timeout for Detach_UE KW
* 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1808  Adding apn parametr to Start data transfer KW

### CB005738_CB007738_UL_superfast_allocation_improvement
Purpose of this test case is to check Superfast allocation during UL traffic.

#### Test specific Preconditions
* Add the following flags to eNB SW config file:
    * 0x670016 = 0x10
    * 0x67001E = 1
* 1 x gNB with NR-DSS Ph3 cell (DL: maxNrDssRatio=100, minNrDssRatio=5, UL: maxNrDssRatio=70, minNrDssRatio=5)
* 1 x eNB with LTE-DSS Ph3 cell (DL: maxNrDssRatio=100, minNrDssRatio=5, UL: maxNrDssRatio=70, minNrDssRatio=5)
* DL buffer level based=DL PRB load based
* actLteNrDssFastAlloc=false

* Owner: anna.konior@nokia.com
* Author: krystian.wojakiewicz@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
* Step 1: Perform LTE UE attach to DSS cell and start UL traffic (no 5G traffic)
* Step 2: Release call
* Step 3: Perform LTE UE attach to DSS cell and start UL burst traffic (watch -n 0.06 /data/iperf-android -c 10.42.211.158 -u -b 10M -l 1400 -p 35678 -i 1 -t 0.03)
* Step 4: Release call
* Step 5: Perform 5G UE attach to DSS cell and start UL traffic (no LTE traffic)
* Step 6: Release call
* Step 7: Perform 5G UE attach to DSS cell and start UL burst traffic (watch -n 0.06 /data/iperf-android -c 10.42.211.158 -u -b 10M -l 1400 -p 35678 -i 1 -t 0.03)
* Step 8: Release call
* Step 9: actLteNrDssFastAlloc=true
* Step 10: Perform Step 1 to Step 8.

#### Pass criteria
* For non burst traffic average measured UL throughput with actLteNrDssFastAlloc=true should not be worst than average measured UL throughput with actLteNrDssFastAlloc=false
* For burst traffic average measured UL throughput with actLteNrDssFastAlloc=true should be better than average measured UL throughput with actLteNrDssFastAlloc=false
* From CRM logs DSS allocation changes happens with 10ms time at lease periodically (For non burst traffic and for burst traffic with actLteNrDssFastAlloc=true)

#### Automatic TC steps
* Preconditions
* Step 1: Attach NR UE with UL WITHOUT superfast
* Step 2: Attach NR UE with BURST UL WITHOUT superfast
* Step 3: Attach LTE UE with UL WITHOUT superfast
* Step 4: Attach LTE UE with BURST UL WITHOUT superfast
* Step 5: Change fast allocation parameter to true
* Step 6: Attach NR UE with UL WITH superfast
* Step 7: Attach NR UE with BURST UL WITH superfast
* Step 8: Attach LTE UE with UL WITH superfast
* Step 9: Attach LTE UE with BURST UL WITH superfast
* Step 10: Compare throughputs
* Step 11: Analyse CRM logs

#### History of changes
* 25.10.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-749 - Initial creation
* 06.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-954 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-972 - Moved documentation to robotws
* 30.06.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1107 - analyse_crm_logs_with_superfast for steps 6 and 8 (so traffic without burst) was deleted from step 11
* 26.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1217 - Adaptation for Klecina TL.
* 16.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1350  application of taf.sw.syslog library, adjustment of the search method the print of syslog
* 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1808  Adding apn parametr to Start data transfer KW
