# CB013025 - 5G PCMD UE Angle of Arrival reporting
Robot test suite for feature CB013025.

## Test line requirements
This section is taken from automation requests done by Palina Krasnova.
* Classical gNB with mMIMO RU capable of beamforming
* Airphone radio simulator   
* NGC Simulator (WTS)
* DCAP/UTF / Wireshark      
* Test Line 5G: CLOUD_5G_O_E_AP_LOO  
* Preinstalled TL variant: SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2

## Test cases

### CB013025_B_IWK1_Interaction_between_MBA_and_SBA_functionality_for_DoA_and_AoA_reporting_different_Trace_Recording_Session_types
The User Scenario describes the interaction between MBA and SBA functionality for DoA  
and AoA reporting in different Trace Recording Session types.  
Trace Recording Session of UE call for MBA is recorded and reports, including Direction of Arrival Trace Record,  
are sent to the TCE when available in BTS. Trace Recording Session of UE call for SBA is recorded and reports,  
including Angle of Arrival Trace Record, are sent to the TCE when available in BTS.  
A Cell Trace Reporting is activated and verified in this User Scenario. 2D DFT beams are used in this User Scenario.  

#### Test Specific Preconditions
* Digital Beamforming for eCPRI based RUs is configured:                       ## 5GC000534 (Digital Beamforming for eCPRI based RUs)
  * NRBTS/NRCELL.actBeamforming is set to true
  * NRBTS/NRCELL.beamSet is configured
* SRS based DL beamforming is configured and activated:                      ## CB008247 (SRS based DL beamforming)
  * NRBTS/NRCELL.actDlSrsBm is set to true
  * NRBTS/NRCELL.actUlSrsBm is set to true
  * NRBTS/NRCELL.srsForBeamMgmt is configured
* NRBTS.actPCMDReport is set to true                                                      ## To activate PCMD functionality
* NRBTS.actSubscriberTraceReport is set to true                                    ## CB007732 (Subscriber Trace for SA)
* NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU is created with the following parameters:
  * nrTcePortNumber is configured
  * actPCMDReporting is set to true
  * tracePCMDCoordinateSystem is set to AoA
* NRBTS/NRCELL.lcsToGcsTranslate is created and following parameters are set:
  * bearingAngle
  * downtiltAngle
  * slantAngle
* NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU is created with the following parameters:
  * actPCMDReporting is set to true
  * tracePCMDCoordinateSystem is set to DoA
  * cellMaxActiveUEsTraced is set to 100
* NRBTS.actCellTraceReport is set to true                                                                ## Cell Trace Report activated
* NRBTS/NRCTRLTS/NRMTRACECU is created with the following parameters:
  * actCellTraceReportingCU is set to true
  * actPCMDReporting is set to false
  * jobType is set to TraceOnly
  * traceNRRRCSetting is set to all
  * cellMaxActiveUEsTraced is set to 100
* TCE is configured under MNL/CEADM/TCE MOC
* Valid IP address is configured by operator (IP address for connection between BTS and TCE)
* NR NSA cells are on air.
* SA or NSA UE is attached to the cell with beamforming configured and DL/UL data transfer is started:
  * UE is capable of TAS SRS. UE’s capability IE ‘supportedSRS-TxPortSwitch’ is one of  
  {t1r1, t1r2, t1r4, t2r4, t2r2, t4r4, t1r4-t2r4}
* A new Cell Trace Session is started in the gNB


#### Requirements:
* CFAM_CB013025 (CB013025 5G PCMD UE Angle of Arrival reporting)
* CFAM_CB007732 (Subscriber Trace for SA)
* OM_GEN_SFS_TRACEMGMNT.4933


* Owner: palina.krasnova@nokia.com
* Author: wojciech.peciak@nokia.com
* Maintainer: wojciech.peciak@nokia.com

#### Test scenario defined by owner

* Step 1: 
  * Description:  
    A new Trace Session and a new Subscriber Trace Session with PCMD content are started in the gNB
  * Expected:  
     * Trace Recording Session of UE call for PCMD Trace content (MBA) is recorded and reports,  
       including Direction of Arrival Trace Record, is sent to the TCE when available in BTS
     * Trace Recording Session of UE call for Subscriber Trace content (SBA) is recorded and reports,  
       including Angle of Arrival Trace Record, is sent to the TCE when available in BTS
     * During PCMD record collection period UE starts to use 2D DFT beam for data transmission in DL PDSCH  
* Step 2: 
  * Description:  
    gNB-DU determines following parameters of the last beam used by UE  
    during PCMD record collection period (i.e. 4096 ms):
    * Beam Usage Time, 
    * Beam Type, 
    * Azimuth angles (two values, one for DoA report, the other for AoA report), 
    * Zenith angle (for AoA report),
    * Elevation angle (for DoA report). 
  * Expected:  
    * Timestamps in scope of MBA and SBA Trace Recording Session of selected UE are the same
    * Beam Usage Time and Beam Type IEs of Direction/Angle of Arrival Trace Records .
      in scope of MBA and SBA Trace Recording Session of selected UE are the same 
* Step 3: 
  * Description:  
    A Cell Trace recording session is reporting for the UE 
  * Expected:  
    TCE receives trace of F1AP messages  


#### Pass criteria
* Trace Recording Session of UE call for PCMD Trace content (MBA) is recorded and reports,  
  including Direction of Arrival Trace Record, is sent to the TCE when available in BTS
* Trace Recording Session of UE call for Subscriber Trace content (SBA) is recorded and reports,  
  including Angle of Arrival Trace Record, is sent to the TCE when available in BTS
* TCE receives trace of F1AP messages 


#### Automatic TC steps
1. Activate Beamforming On Specific Position For One Subcell
2. Attach SA UE And Establish PDU Session
3. Exit Idle Mode And Start Data Traffic
4. Start Subscriber Trace And Wait For angleOfArrivalRecord Reports
5. Validate Trace Recording Session Elements SBA
6. Validate Trace Recording Session Elements MBA
7. Validate 2D DFT Beam Type
8. Validate If Beam Params Are Coherent Across MBA And SBA Reports
9. Validate Cell Trace Recording Session Is Reporting


#### Test case developer notes
* For TCE msgs to be visible in wireshark, listening process needs to be started.  
  Could be done with netcat like so:
  * nc -l 15010 
* MBA directionOfArrivalRecord and SBA angleOfArrivalRecord are compared based on  
  same timestamp (seconds and microseconds) after processing msg to pdml/xml.
* Cell trace is activated automatically when configured on gNB,  
  so validation is based on chosen (F1AP) protocol that is passed on to TCE as a part of tracing.  
  Other msgs are also traced to TCE.
* The BSR package must be installed before running this test.

#### History of changes
* 07.07.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1514 - Initial creation
* 14.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1523 - Delta SCF changes due to changes introduced by CB013789


### CB013025_A_IWK1_Interaction_with_Carrier_Aggregation_Monitoring_PCMD_content_related_to_DoA_reporting_for_PCell_and_SCells
The User Scenario describes the procedure of monitoring PCMD content related to to DoA reporting for PCell and SCell(s). The interaction with CB009855 Extended interband FR1 TDD - FDD DL CA up to 5CC, TDD as PCell has been tested. Refined beams are used in this User Scenario.
  

#### Test Specific Preconditions
* Digital Beamforming for eCPRI based RUs is configured:     ## 5GC000534 (Digital Beamforming for eCPRI based RUs) –  Configured for TDD PCell and one TDD SCell
  * NRBTS/NRCELL.actBeamforming is set to true
  * NRBTS/NRCELL.beamSet is configured
  * NRBTS/NRCELL.beamSet.nrBtsBeamRefinementP2 is set to true
* Support 8 port CSI-RS codebook for SU-MIMO is configured and activated          ## 5GC002200 (Download Closed Loop SU MIMO Enhancement)
* Carrier Aggregation feature is configured and activated                         ## CB009855 (Extended Inter band DL TDD + FDD FR1 CA up to 5CCs (TDD as PCell)):
  * NRBTS/NRCELL.maxNumSCellsDlFr1 is set to 4
  * CA relationships are configured
  * NRBTS.sCellActivationMethod is set to blind
    * NRBTS/NRCELL/NRREL.sCellAdditionMethod is set to blind                          ## For each NRREL object pointing to a SCell candidate
    * NRBTS/NRDU.carrierAggregationSupportList contains the following values to enable FR1 CA features:
      * 3: ca_Fdd_Fdd
      * 200: ca_Fdd_Fr1Tdd_Sa
      * 400: ca_Fr1Tdd_Sa
      * 500: ca_Fr1Tdd_Fdd_Sa
      * 600: ca_Fdd_Any_Sa
      * 700: ca_Fr1Tdd_Any_Sa (mandatory for enabling 3T+2F CA and 2T+3F DL CA)
* NRBTS.actPCMDReport is set to true                                                                      ## To activate PCMD functionality
* NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU is created with the following parameters:
  * actPCMDReporting is set to true
  * tracePCMDCoordinateSystem is set to DoA
  * cellMaxActiveUEsTraced is set to 100
* TCE is configured under MNL/CEADM/TCE MOC
* DCAP/Wireshark capturing is started
* SA or NSA UE is attached to the cell with beamforming configured to TDD PCell with supported beamforming functionality and DL/UL data transfer is started:
  * UE supports 3 TDD + 2 FDD 5CC CA and appropriate band combination
* A new Trace Session with PCMD content is started in the gNB
* UE stays in radio conditions which allows gNB to schedule and activate at least one TDD SCell with supported beamforming functionality


#### Requirements:
* CFAM_CB013025 (CB013025 5G PCMD UE Angle of Arrival reporting)
* OM_GEN_SFS_TRACEMGMNT.4956 - USCB013025-A#IWK1: Interaction with Carrier Aggregation: Monitoring PCMD content related to DoA reporting for PCell and SCell(s)
* CB_FIM_49830 - CB013025 Interacts with 5GC000534, CFAM_5GC000534 (Digital Beamforming for eCPRI based RUs)
* CB_FIM_49751 - CB013025 Interacts with 5GC002200, CFAM_5GC002200 (Download Closed Loop SU MIMO Enhancement)
* CB_FIM_49832 - CB013025 Interacts with CB009855, CFAM_ CB009855 (Extended Inter band DL TDD + FDD FR1 CA up to 5CCs (TDD as PCell))
* CB_FIM_48960 - CB013025 Depends on 5GC001097, CFAM_5GC001097 (Basic PCMD For NSA) 
* CB_FIM_48959 - CB013025 Depends on 5GC000376, CFAM_5GC000376 (PCMD Support For 5G NB) 

* Owner: palina.krasnova@nokia.com
* Author: jakub.magier@nokia.com
* Maintainer: jakub.magier@nokia.com


#### Test scenario defined by owner

* Step 1: 
  * Description:  
    During PCMD record collection period UE starts to use Refined beams for data transmission in DL PDSCH in PCell and SCell(s)
  * Expected:  
     * A new Trace Recording Session with gNB-DU has been established for the UE for its lifetime in the gNB-DU
     * gNB sends periodically Direction of Arrival Trace Record to TCE
* Step 2: 
  * Description:  
    gNB-DU determines following parameters of the last beam used by UE during PCMD record collection period (i.e. 4096 ms): 
    * Beam Usage Time,
    * Beam Type,
    * Azimuth angle,
    * Elevation angle
  * Expected:  
    * Direction of Arrival Trace Record contains IEs corresponding to the most recent estimated DoA based on beam used by UE
    * Timestamp in Direction of Arrival Trace Record indicates the end of usage of beam used for DoA estimation
    * Direction of Arrival Trace Record contains IEs corresponding to PCell; CA Direction of Arrival Trace Record contains IEs corresponding to each of TDD SCell with supported beamforming functionality; CA Direction of Arrival Trace Record is not reported for FDD SCell(s) or TDD SCell(s) with non-beamforming RU


#### Pass criteria
* A new Trace Recording Session with gNB-DU has been established for the UE for its lifetime in the gNB-DU
* gNB sends periodically Direction of Arrival Trace Record to TCE with IEs corresponding to the most recent estimated DoA based on beam used by UE
* Direction of Arrival Trace Record contains IEs corresponding to PCell. CA Direction of Arrival Trace Record contains IEs corresponding to each of TDD SCell with supported beamforming functionality


#### Automatic TC steps
1. Activate Beamforming On Specific Position For One Subcell
2. Attach SA UE And Establish PDU Session
3. Start Data Traffic
4. Start Subscriber Trace And Wait For caSCellDirectionOfArrivalRecord Reports
5. Validate PCell DoA
6. Validate Beam Type
8. Validate SCell DoA


#### Test case developer notes
* For TCE msgs to be visible in wireshark, listening process needs to be started.  
  Could be done with netcat like so:
  * nc -l 15010 
* The BSR package must be installed before running this test.

#### History of changes
* 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1551 - Initial creation


### CB013025_CVR_Monitoring_PCMD_content_related_to_AoA_reporting_for_both_PMI_and_SRS_beams
The User Scenario describes the procedure for monitoring PCMD content related to AoA reporting.  
It verifies new Trace Recording Session establishment, Angle of Arrival Trace Record structure  
and utilization of each PMI and SRS-based beams.


#### Test Specific Preconditions
* Digital Beamforming for eCPRI based RUs is configured:                       ## 5GC000534 (Digital Beamforming for eCPRI based RUs)
  * NRBTS/NRCELL.actBeamforming is set to true
  * NRBTS/NRCELL.beamSet is configured
* SRS based DL beamforming is configured and activated:                      ## CB008247 (SRS based DL beamforming)
  * NRBTS/NRCELL.actDlSrsBm is set to true
  * NRBTS/NRCELL.actUlSrsBm is set to true
  * NRBTS/NRCELL.srsForBeamMgmt is configured
* NRBTS.actPCMDReport is set to true                                                      ## To activate PCMD functionality
* NRBTS/NRCELL.lcsToGcsTranslate is created and following parameters are set:
  * bearingAngle
  * downtiltAngle
  * slantAngle
* NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU is created with the following parameters:
  * actPCMDReporting is set to true
  * tracePCMDCoordinateSystem is set to AoA
  * cellMaxActiveUEsTraced is set to 100
* NRBTS.actCellTraceReport is set to true                                                                ## Cell Trace Report activated
* NRBTS/NRCTRLTS/NRMTRACECU is created with the following parameters:
  * actCellTraceReportingCU is set to true
  * actPCMDReporting is set to false
  * jobType is set to TraceOnly
  * traceNRRRCSetting is set to all
  * cellMaxActiveUEsTraced is set to 100
* TCE is configured under MNL/CEADM/TCE MOC
* A new Cell Trace Session is started in the gNB


#### Requirements:
* CFAM_CB013025 (CB013025 5G PCMD UE Angle of Arrival reporting)
* OM_GEN_SFS_TRACEMGMNT.4933


* Owner: marcel.behen@nokia.com
* Author: wojciech.peciak@nokia.com
* Maintainer: wojciech.peciak@nokia.com


#### Test scenario defined by owner

* Step 1: 
  * Description:  
    BTS is commissioned, and cells are on Air
  * Expected:  
    No unexpected faults/alarms are visible in WebEM
* Step 2: 
  * Description:  
    Attach UE  
  * Expected:  
    UE is attached without any faults 
* Step 3: 
  * Description:  
    Start DL throughput  
  * Expected:  
    DL throughput is started  
* Step 4: 
  * Description:  
    During PCMD record collection period UE starts to use PMI and SRS-based beams 
    for data transmission in DL PDSCH with rank 3 or 4 
  * Expected:  
    * A new Trace Recording Session with gNB-DU has been established for the UE for its lifetime in the gNB-DU.
    * gNB sends periodically Angle of Arrival Trace Record to TCE.
* Step 5: 
  * Description:  
    gNB-DU determines the following parameters of the last beam used by UE during PCMD record collection period (4096 ms):
    * Beam Usage Time (for the list of scheduled beams),
    * Beam Type,
    * Azimuth angle (for both beams),
    * Elevation angle (for both beams)  
  * Expected:  
    * Angle of Arrival Trace Record contains IEs corresponding to the most recent estimated AoA based on beam used by UE 
    * Timestamp in Angle of Arrival Trace Record indicates the end of the PCMD record collection period 
    * Beam Usage Time indicates the time difference between the end of the PCMD collection period and the start of using the second beam
    * Azimuth and Zenith angles in Angle of Arrival Trace Record are in GCS  

#### Pass criteria
* A new Trace Recording Session with gNB-DU has been established for the UE for its lifetime in the gNB-DU 


#### Automatic TC steps
1. Step 1: Configure Number Of Transmission Layers For UE
2. Step 2: Attach Ue And Wait For PMI Beam Type And Start Traffic
3. Step 3: Validate New Trace Recording Session Start Msg
4. Step 4: Validate AoA Msg For PMI Beam
5. Step 5: Validate SRS Beam Type
6. Step 6: Validate AoA Msgs For SRS Beam Are Occurring Periodically
7. Step 7: Validate Rank Indicator In Utilized Beams
8. Step 8: Release PDU Session With Traffic And Validate New Trace Recording Session Stop Msg


#### Test case developer notes
* For TCE msgs to be visible in wireshark, listening process needs to be started.  
  Could be done with netcat like so:
  * nc -l 15010 
* The BSR package must be installed before running this test.
* In egate cmd csi_override_testmode_nr argument ri (rank indicator) starts from 0, so rank 4 is equal to value 3.
* Sure way to get msg with PMI beam is to only attach UE (no PDU session) and let it go Idle. First beam is SSB type, then during state change the PMI beam is used. You could get more PMI beam type msgs if you extend Idle timer on BTS (srbInactivityTimerSA).
* If PMI beam is not captured before data transfer starts then try to extend timer (srbInactivityTimerSA).
* It was stated that beamType=2 (dft beam) is the SRS beam which we are expecting in test.
* If PMI beam is not captured before data transfer start then try to extend timer (srbInactivityTimerSA).

#### History of changes
* 02.09.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1539 - Initial creation
* 11.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1749 - Timeouts refactor due to toggling and .qc entry added
