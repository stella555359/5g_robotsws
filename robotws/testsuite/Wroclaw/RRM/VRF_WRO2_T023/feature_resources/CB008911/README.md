# CB008911: PCMD for Carrier Aggregation and Periodical Timing Advance reporting
Robot test suite for feature CB008911.

## Test Strategy and priorities
Per Call Measurement Data (PCMD) provides call level measurements and statistics. 
The BTS reports PCMD for every UE periodically or when events occur 
(for example UE setup, UE release, handover, radio link failure (RLF)).
  
## Testing Scope
This feature is subsequent step in the evolution of Nokia 5G Per Call Measurement Data reporting capability. 
Following enhancements are in its scope:
* 5G SA Carrier Aggregation- allow full visibility of CA usage and performance per user (intra-site CA)
* CU & DU Control Plane reporting- CA configuration setup modification or release event-based reporting
* DU- User Plane Selected Pcell and Scell parameters (NRCGI, PRB bandwidth, ARFCN)
* DU- User Plane Scell Beam usage statistics (overall sent the UP records supported for PCell) - 
Scheduling Record, Radio Bearer RLC Measurement Trace Record
* DU- User Plane DL/UL RLC measurements for PCell & SCell (s) (FR1 and FR2 band combinations)
* Timing Advance (TA) for SA & NSA reported periodically (all cells in case of CA operational mode).

### Example configuration
ASIL, ABIO, 2xABIP, 2xAHEGC, 2xAZQH, 1 UE compatible with the bands n3 and n78 and supports CA 3CC FDD-TDD (e.g. SDX65)

#### 5G cell config
* PCell(gNB)[Band n3][FDD]: AHEGC
* SCell1(gNB)[Band n78][TDD]: AZQH
* SCell2(gNB)[Band n78][TDD]: AZQH

### Required initial BTS 5G state (not to be checked but provided directly from SCF)
* CA 3CC FDD-TDD activated
* gNB-CU-CP and gNB-DU has registered resources to trace framework.
* Trace Session to provide PCMD metrics is activated on gNB-CU-CP and gNB-DU.
* TCE is configured in MNL/TCEADM/TCE.
* NRBTS-actPCMDReport set to TRUE.
* NRBTS/NRCTRLTS/NRMTRACECU.actPCMDReporting set to TRUE.
* NRBTS/NRCTRLTS/NRMTRACECU.jobType= TraceOnly or ImmediateMDTAndTrace.
* NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU.actPCMDReporting set to TRUE.
* NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU.jobType= TraceOnly
* Max number of traced UEs is not reached on gNB cell (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced 
 NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU/cellMaxActiveUEsTraced).
* gNB-CU-CP and gNB-DU has selected UE for trace and indicated start of trace recording session to TCE.
* actPCMDReport=true

## Test cases

### CB008911__PCMD_records_during_CA_call_SA_3CC_DL
This user scenario validates the PCMD records reported by gNB-DU and gNB-CU-CP during CA 3CC SA call.

* Owner: mariusz.daniel@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions
gNB related pre-conditions:
* gNB is configured with FDD and FR1-TDD cells.
* Enabler for Inter L2-RT scheduling feature (5GC002255) is activated (actInterNumerologyCa = true).
* Inter-band FDD FR1-TDD CA feature (5GC001390) is activated: carrierAggregationSupportList enumeration 
parameter is set to 2 (ca_Fdd_Fr1Tdd).
* Support of long PUCCH is selected for all the FDD cells of the gNB-DU 
(NIDD parameter pucchModeSelect is set to longPucch).
* FDD cell contains NRREL object referring to the FR1-TDD cell with optional sCellAdditionMethod parameter set to blind.
* NIDD parameter maxNumScellsDl is set to 2.
* Cell deployment type NIDD parameter allows SA access to the FDD cell: cellDepType is set to 1 (SA) or 2 (both).
* Beamforming is not activated on FR1-TDD cell (actBeamforming = false).
* DSS is disabled in FDD Cell(NRBTS/actLteNrDss = false)
* DRX is disabled in FDD Cell(NRBTS/NRCELL/actCDrx = false)
* Simultaneous Harq Ack Nack and CSI is supported (See 5G_L3_4319).
* FR1-TDD cell is configured with frame structure type according to 5GC001208
* Both FDD and FR1-TDD Cell are configured and on-air

UE related pre-conditions:
* 5G-UE is capable of inter-band FDD FR1-TDD CA with up to 3 CCs and UE supports the bands combination configured in gNB

UTF related preconditions:
* Trace collector entity ip address (tceIpAddress parameter in TCE object) should be the same as the UTF server IP address used for the log collection. This is required for the cell traces to be collected correctly.

#### Test scenario defined by owner
* Step 1:
  Description: Attach UE to the FDD NR cell and perform CA DL call.
  Expected: Attach successful, data transfer via PCell and SCells is ongoing.
* Step 2:
  Description: Check PCMD records related to SCells addition.
  Expected: PCMD records are as in 5G_RAN_USR_RRM_20770, OM_GEN_SFS_TRACEMGMNT.4615, OM_GEN_SFS_TRACEMGMNT.4616
* Step 3:
  Description: Check PCMD records related to INITIAL Timing Advance.
  Expected: PCMD records are as in OM_GEN_SFS_TRACEMGMNT.4626.
* Step 4:
  Description: Check PCMD records related to PERIODIC Timing Advance.
  Expected: PCMD records are as in OM_GEN_SFS_TRACEMGMNT.4627.
* Step 5:
  Description: Check Value Of tagId In Timing Advance PCMD Records
  Expected: tagId is equal to 0, as in pronto 03863460.
* Step 6:
  Description: Check PCMD records related to Downlink Carrier Aggregation Scheduling scenarios.
  Expected: PCMD records are as in OM_GEN_SFS_TRACEMGMNT.4630.
* Step 7:
  Description: Check PCMD records related to Downlink RLC Throughput measurements.
  Expected: PCMD records are as in OM_GEN_SFS_TRACEMGMNT.4638.
* Step 8:
  Description: Increase attenuation of SCell to trigger SCell release.
  Expected: SCell is released, PCMD records are as in 5G_RAN_USR_RRM_21251.

#### Pass Criteria
* gNB-DU sent the DU CA Configuration Record to TCE.
* gNB-CU-CP sent the gNB-CU CA Configuration Record to TCE.

#### Automatic TC steps
* Preconditions
* Step 1: Start Collecting Control Plane Logs
* Step 2: Perform NR DL Data Transfer
* Step 3: Stop NR Data Transfer
* Step 4: Stop Collecting Control Plane Logs
* Step 5: Extract EMIL Logs
* Step 6: Parse EMIL Logs
* Step 7: Check PCMD Records Related To SCells Addition
* Step 8: Check PCMD Records Related To INITIAL Timing Advance
* Step 9: Check PCMD Records Related To PERIODIC Timing Advance
* Step 10: Check Value Of tagId In Timing Advance PCMD Records
* Step 11: Check PCMD Records Related To Downlink Carrier Aggregation Scheduling Scenarios
* Step 12: Check PCMD Records Related To Downlink RLC Throughput Measurements
* Step 13: Check PCMD Records Related To SCell Release

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* EMIL logs are collected with DCAP. You require to have DCAP server set beforehand.
  Please make sure that it is up-to-date before reporting pronto.
* EMIL logs are converted to CSV using EMIL installed on UE PC. Please make sure
  to keep it up to date. In case this test is moved to a different configuration,
  please remember to install EMIL as this is not included in this test.
* In case this test is interrupted please make sure that logs on UE PC in path: ${WINDOWS_TEMP_LOGS_DIR}
  are cleared as well as all traces on DCAP server for this BTS are stopped.
* CSV files in ${LOG_PATH}/dcap_logs/CSV are merged into one file and saved in this location as combined_result.csv.
* In case of problems with DCAP or EMIL it is possible to consult them on DCAP Basic and R&D Emil
  support site: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic.
* In steps 9,11, and 12, the periodicity of records is also checked. They should be visible approximately every 4 sec.

#### History of changes
* 20.10.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1146 - initial creation
* 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1202 - add KW Check If Traces Are Running after starting
  DCAP log collection
* 15.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1209 - move DCAP credentials from test to yaml file
* 27.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1220 - add TCE IP address check to Preconditions
* 14.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1311 - Fix setting attenuation of scells before UE attach.
* 18.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1312 - remove import to old_common_resources_iwk.robot
* 25.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1317 - change maintainer of the TC
* 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1319 - add checking tagId of collected TimingAdvanceTraceRecords.
* 31.07.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1326 - change KWs collecting EMIL logs to match new DCAP folders
* 23.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1479 - change attenuation to correctly perform CA
* 28.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1485 - move test from old rmod AZQH to newer AZQP
