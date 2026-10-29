# CB010369 - Successful transition of UE from RRC Connected to RRC Inactive State due to expiration of RFSP based Inactivity timer with CB008225
Robot test suite for feature CB010369.

## Test line requirements
This section is taken from automation requests done by Michal Kowalczyk.
* CloudRAN gNB in SA mode (#6.1 SKT)
* Switched fronthaul connection for CloudRAN (FHGW),
* RINLINE2 RAN NIC,
* vDU,
* vCU,
* GPS antenna - FYGC
* Airphone

### Required initial BTS state (not to be checked but provided directly from SCF)
* gNB configured with two TDD cells, eg. (100MHz, n78)
* gNB configured with inter-frequency handover for given origin cell
* gNB origin cell and handover managed object configured with A3 measurements
* All inter-frequency HO, CB008225, CB010369 related parameters and their settings are included in general delta files.  
  Under path:  
  testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB010369_CB008225/delta/vcu.json
  testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB010369_CB008225/delta/vdu.json

## Test cases

### TC__CB010369_B_Successful_transition_of_UE_from_RRC_Connected_to_RRC_Inactive_state_due_to_expiration_of_RFSP_Inactivity_timer_IWK_with_CB008225

The purpose of the test case is to verify the transition of UE from RRC_Connected to RRC_Inactive state due to 
expiration of Inactivity timer for a configured RFSP. Test case is checking interaction with CB008225: RRC Inactive 
State transitions under same gNB (SA mode). UE enters to the NR cell via handover from another NR cell configured 
on the same vDU.

#### Test specific Preconditions
* NR SA cells are on air.
* NRBTS.NRPMRNL.miNrX2ccNrpmqap is activated.
* NRBTS.actRfspIndex is set to TRUE.
* NRBTS.activityNotificationLevelSA is set to UE.
* NRBTS.actSpidRfspInactTimers is set to TRUE.
* NRBTS.NRRFSP_PROFILE.rfsp is configured.
* NRBTS.NRRFSP_PROFILE.rfspInactivityTimer is configured.
* NRBTS.NRRFSP_PROFILE.rfspRrcInactInactivityTimer is configured.
* NRBTS.drbInactivityTimerSA is configured.
* NRBTS.srbInactivityTimerSA is configured.


#### Requirements:
* CFAM CB010369
* 5G_RAN_USR_RRM_23653
* CB_FIM_43435
* 5G_RAN_USR_RRM_1650


* Owner: michal.kowalczyk@@nokia.com
* Author: wojciech.peciak@nokia.com
* Maintainer: wojciech.peciak@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Start collecting syslog and pcap logs.
  * Expected:  
    Collection of syslog and pcap logs has started successfully.
* Step 2:
  * Description:  
    Attach UE to NR Cell#1 on vDU#1 and handover to NR Cell#2 on the same vDU#1 by increasing NR Cell#1 attenuation 
    and by decreasing NR Cell#2 to allow UE to HO to NR Cell#2.
  * Expected:  
    Intra-vDU, Intra-vCU HO from NR Cell#1 to NR Cell#2 succeeded.
* Step 3:
  * Description:  
    Wait until srbInactivityTimerSA is exceeded.
  * Expected:
    gNB-CU-UP sends E1AP: BearerContextInactivityNotification msg for each DRB (if notification level 
    activityNotificationLevelSA is set to DRB) or one msg when all DRBs are inactive (if notification level activityNotificationLevelSA is set to UE).
* Step 4:
  * Description:  
    Stop collecting syslog and pcap logs.
  * Expected:  
    Collection of syslog and pcap logs has ended successfully.

#### Pass criteria
* Successful UE state transition from RRC_connected to RRC_Inactive due to expiration of RFSP based Inactivity timer.
* Expiration of RFSP based Inactivity timer led to UE state transition from RRC_connected to RRC_Inactive.

#### Automatic TC steps

* Preconditions 
* Step 1: Attach Ue And Establish Pdu Session
* Step 2: Verify Rfsp And RfspRrcInactInactivityTimer Sent To Ue
* Step 3: Perform InterFreq Handover UE To Second Cell
* Step 4: Verify Expiration Of Timer Causing Transfer To RRC_Inactive

#### Test case developer notes
* For the nr-rrc packets coming from simulated UE to be visible in tshark,  
  we need to change NR Encryption Algorithms and NR Integrity Algorithms declared on eGate .cfg file like so:  
  set_ue simulated id=1 (...) nia=aes nea=null (...)
* To be able to perform HO, both cells need to have power saving turned off for the time being.
* For the simUE to switch into RRC_INACTIVE info here:  
  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1527238049
* For the simUE to have RFSP on AMF configured refer to this page:  
  https://confluence.ext.net.nokia.com/display/AirPhoneWTS/5GC000710+Mobility+profiles+-+User+Manual
* Packets on tshark with alias "default_F1_E1_RRC" are captured from tcpdump CPIF pod on vCU   
  and streamed to the VM via vCU master server to be visible in tshark.  
* In KW "Wait For Target Cell State Due To Power Saving" is hardcoded 300s timeout for cell to change in given state  
  due to power saving settings. This KW is necessary to enable Target cell for handover and then restore its state after  
  the test ends.

#### History of changes
* 12.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1430 - Initial creation
