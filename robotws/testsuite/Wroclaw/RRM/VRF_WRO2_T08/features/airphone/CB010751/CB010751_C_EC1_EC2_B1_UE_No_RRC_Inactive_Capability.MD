# CB010751 C EC2 Unsuccessful Transition Of RedCap UE Being In RRC INACTIVE State To RRC CONNECTED Due To Radio Admission Control Failure  CB008225-D#E2

## **Requirements:**

- `5G_RAN_USR_RRM_24515`


## 1. DESCRIPTION 

This testcase describes the gNB behavior for RedCap UE in RRC_CONNECTED state that is unsuccessfully transitioned to RRC_INACTIVE state due to Admission Control in gNB-CU-CP (CB008225-D#E2 Alt 1) when actRedCapUeSupport is false.

## 2. TEST ENVIRONMENT AND SETTINGS

### 1. Standard UTE environment

- LO_AP_LO variant 
- 2xAEQE (TDD eCPRI 25) 
- 2xAHLOA (FDD NokiaCPRI)
- Cell deployment type: SA+NSA

### 2. Testing Tools

- Wireshark
- AirPhone
- Tcpdump

### 3. Test Automation

## 3. TEST CASE INFORMATION

### 1. Definitions from the Test Plan

### 2.  Required Logs

  - SysLog
  - Snapshoot
  - PCAPS: x2ap, ngap, f1ap, e1ap, nr-rrc(Uu)
  - PCMD

## 4. TESTING INSTRUCTIONS

### 1. Preconditions

- gNB is up and running
- NR Cell is FR1-TDD deployed as SA
- NRBTS.gNbCuType is equal to 'SA' or to 'SA+NSA'
- NRBTS.SNSSAI.drbInactivityTimerSA/drbRrcInactInactivityTimerSA and NRDRB.drbInactivityTimerSA/drbRrcInactInactivityTimerSA are not configured
- CB009568 is activated for all the gNB cells (For 2Rx RedCap UE: refer to preconditions for USCB009568-A#B1[5G_RAN_USR_RRM_24036],  For 1Rx RedCap UE: refer to preconditions for USCB009568-A#B4[5G_RAN_USR_RRM_24379])
- CB010751 is activated NRBTS.actRrcInactStateRedCap (set to 'TRUE')
- RedCap UE with Inactive state capability is up and running
- NRBTS.drbInactivityTimerSARedCap, NRBTS.drbRrcInactInactivityTimerSARedCap and NRBTS.srbInactivityTimerSARedCap parameters are configured
- NRBTS.activityNotificationLevelSA is configured and set to: 'ue'
- CB008225 is activated and configured
- CB008225-A#B1  CB008225 Feature activation NR Cell Configuration of RAN Area Code and broadcast of SIB1 for RRC Inactive State - RAN Sharing [5G_RAN_USR_RRM_18000]
- PCMD tracing activated and configured as per preconditions for USCB008225-J#B01 gNB-CU UeDuConnectivity Record from gNB-CU-CP during RRC_Connected to RRC_Inactive transition [5G_RAN_USR_RRM_18794]
- RedCap UE has finished RRC connection establishment and Initial Context Setup procedure is finished with PDU session established as per USCB009384-A#B2: RedCap UE identification during call setup
- one or more PDU Session (DRB) is established, no 5QI1 DRB is established
- RedCap UE is served by PLMN where RANAC is configured
- CoreNetworkAssistanceInformationForInactive IE is received in NGAP:InitialContextSetupRequest

### 2. Test Steps


#### Step 1: Attach RedCap UE to Source gNB (RANSIM) with one PDU session

- Description:
  - amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
  - ue_register id=1
  - ue_start_pdu_session ue=1 pdu=1 gw=1

- Expected:
  - UE is in RRC_CONNECTED and PDU Session is successfully setup

#### Step 2: Wait for RRC Release

- Description: gNB sends RRC Release and UE is moved to RRC INACTIVE
- Expected:
  - UE state transition is initiated when both NRBTS.drbRrcInactInactivityTimerSARedCap and  NRBTS.srbInactivityTimerSARedCap timers are expired
  - UE is moved to RRC INACTIVE state
  - RRC Release with Suspend config, NGAP UEContextReleaseRequest and    NGAP UEContextReleaseCommand are present in pcap
 
#### Step 3: Set actRedCapUeSupport to false

- Description: Parameter value change is successful
- Expected:
  - F1AP gNBDUConfigurationUpdate is present in pcap
  - Cell becomes unavailable for RedCap UEs

#### Step 4: Attempt to Modify PDU Session for Inactive UE 

- Description: 
  - ue_deregister id=1 by=ue type=normal
- Expected:
  - Admission control failure in - UE is not resumed 
  - RRC Resume Request 1, RRC Reject visible in pcap

#### Step 5: Set actRedCapUeSupport to true.

- Description: Parameter value change is successfully.
- Expected:
  - F1AP gNBDUConfigurationUpdate is present in pcap
  - Cell becomes available for RedCap UEs
  - UE stays in RRC_INACTIVE state

#### Step 6: Deregister UE

- Description: 
  - ue_deregister id=1 by=amf type=normal
- Expected:
  - UE is deregistered successfully
  - RRC Resume Request 1, RRC Resume, RRC Resume Complete visible in pcap
  - F1AP UEContextReleaseComplete visible in pcap

### 3. Postconditions

- RRC Reject is send in response to RRC Resume Request when actRedCapUeSupport is set to false due to admission control failure.
- UE is deregistered successfully when actRedCapUeSupport is true - UEContextReleaseComplete is present

## 5. REFERENCES

- [1] /RA System General Modules/Common CFAM/010600-010799/CFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNBCFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNB 
- [2] 
  - `5G_RAN_USR_RRM_24515'


## 6. HISTORY

- V 0.1: 02.01.2024: Adarsha P Hegde: initial creation: under review
- V 0.2: 18.03.2024: Marcin Plawny: modify scenario to cover case where RedCap UE support is turned off

---

# CB010751 C EC1 1 Unsuccessful transition of RedCap UE In RRC CONNECTED State To RRC INACTIVE State When CNAI Is Absent In ICS

## **Requirements:**

- `5G_RAN_USR_RRM_24516`


## 1. DESCRIPTION 

This user scenario describes the gNB behavior for UE when Core Network Assistance Information is missing in Initial Context Setup in RRC_CONNECTED state that is unsuccessfully transitioned to RRC_INACTIVE state. Unsuccessful suspend procedure. UE released to RRC_IDLE state.

## 2. TEST ENVIRONMENT AND SETTINGS

### 1. Standard UTE environment

- LO_AP_LO variant 
- 2xAEQE (TDD eCPRI 25) 
- 2xAHLOA (FDD NokiaCPRI)
- Cell deployment type: SA+NSA

### 2. Testing Tools

- Wireshark
- AirPhone
- Tcpdump

### 3. Test Automation

## 3. TEST CASE INFORMATION

### 1. Definitions from the Test Plan

### 2.  Required Logs

  - SysLog
  - Snapshoot
  - PCAPS: x2ap, ngap, f1ap, e1ap, nr-rrc(Uu)
  - PCMD

## 4. TESTING INSTRUCTIONS

### 1. Preconditions

- gNB is up and running
- NR Cell is FR1-TDD deployed as SA
- NRBTS.gNbCuType is equal to 'SA' or to 'SA+NSA'
- NRBTS.SNSSAI.drbInactivityTimerSA/drbRrcInactInactivityTimerSA and NRDRB.drbInactivityTimerSA/drbRrcInactInactivityTimerSA are not configured
- CB009568 is activated for all the gNB cells (For 2Rx RedCap UE: refer to preconditions for USCB009568-A#B1[5G_RAN_USR_RRM_24036],  For 1Rx RedCap UE: refer to preconditions for USCB009568-A#B4[5G_RAN_USR_RRM_24379])
- CB010751 is activated NRBTS.actRrcInactStateRedCap (set to 'TRUE')
- RedCap UE with Inactive state capability is up and running
- NRBTS.drbInactivityTimerSARedCap, NRBTS.drbRrcInactInactivityTimerSARedCap and NRBTS.srbInactivityTimerSARedCap parameters are configured
- NRBTS.activityNotificationLevelSA is configured and set to: 'ue'
- CB008225 is activated and configured
- CB008225-A#B1  CB008225 Feature activation NR Cell Configuration of RAN Area Code and broadcast of SIB1 for RRC Inactive State - RAN Sharing [5G_RAN_USR_RRM_18000]
- PCMD tracing activated and configured as per preconditions for USCB008225-J#B01 gNB-CU UeDuConnectivity Record from gNB-CU-CP during RRC_Connected to RRC_Inactive transition [5G_RAN_USR_RRM_18794]
- RedCap UE has finished RRC connection establishment and Initial Context Setup procedure is finished with PDU session established as per USCB009384-A#B2: RedCap UE identification during call setup
- one or more PDU Session (DRB) is established, no 5QI1 DRB is established
- RedCap UE is served by PLMN where RANAC is configured


### 2. Test Steps


#### Step 1: Attach RedCap UE without RRC Inactive Support to Source gNB (RANSIM) with one PDU session

- Description:
  - ue_register id=1
  - ue_start_pdu_session ue=1 pdu=1 gw=1

- Expected:
  - UE is in RRC_CONNECTED and PDU Session is successfully setup

#### Step 2: Wait for RRC Release

- Description: gNB sends RRC Release and UE is moved to RRC IDLE
- Expected:
  - UE state transition is initiated when both NRBTS.drbRrcInactInactivityTimerSARedCap and  NRBTS.srbInactivityTimerSARedCap timers are expired
  - UE is moved to RRC IDLE state
  - RRC Release without Suspend config, NGAP UEContextReleaseRequest and NGAP UEContextReleaseCommand are present in pcap
 

### 3. Postconditions

- UE is transitioned to RRC_IDLE state. DRB inactivity for RedCap UE is detected based on NRBTS.drbInactivityTimerSARedCap parameter. SRB inactivity is detected based on NRBTS.srbInactivityTimerSARedCap timer expiration.
- PCMD records are collected and reported to TCE.


## 5. REFERENCES

- [1] /RA System General Modules/Common CFAM/010600-010799/CFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNBCFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNB 
- [2] 
  - `5G_RAN_USR_RRM_24516'


## 6. HISTORY

- V 0.1: 02.01.2024: Adarsha P Hegde: initial creation: under review
- V 0.2: 12.03.2024: Marcin Plawny: modify scenario to cover case when CNAI is not broadcasted

---

# CB010751 C B1 Unsuccessful Transition Of RedCap UE Being In RRC CONN State To RRC INACTIVE State UE Has No RRC Inactive Capability

## **Requirements:**

- `5G_RAN_USR_RRM_24509`


## 1. DESCRIPTION 

This testcase describes the gNB behavior for RedCap UE in RRC_CONNECTED state that is unsuccessfully transitioned to RRC_INACTIVE state due to missing UE RRC Inactive Support.

## 2. TEST ENVIRONMENT AND SETTINGS

### 1. Standard UTE environment

- LO_AP_LO variant 
- 2xAEQE (TDD eCPRI 25) 
- 2xAHLOA (FDD NokiaCPRI)
- Cell deployment type: SA+NSA

### 2. Testing Tools

- Wireshark
- AirPhone
- Tcpdump

### 3. Test Automation

## 3. TEST CASE INFORMATION

### 1. Definitions from the Test Plan

### 2.  Required Logs

  - SysLog
  - Snapshoot
  - PCAPS: x2ap, ngap, f1ap, e1ap, nr-rrc(Uu)
  - PCMD

## 4. TESTING INSTRUCTIONS

### 1. Preconditions

- gNB is up and running
- NR Cell is FR1-TDD deployed as SA
- NRBTS.gNbCuType is equal to 'SA' or to 'SA+NSA'
- NRBTS.SNSSAI.drbInactivityTimerSA/drbRrcInactInactivityTimerSA and NRDRB.drbInactivityTimerSA/drbRrcInactInactivityTimerSA are not configured
- CB009568 is activated for all the gNB cells (For 2Rx RedCap UE: refer to preconditions for USCB009568-A#B1[5G_RAN_USR_RRM_24036],  For 1Rx RedCap UE: refer to preconditions for USCB009568-A#B4[5G_RAN_USR_RRM_24379])
- CB010751 is activated NRBTS.actRrcInactStateRedCap (set to 'TRUE')
- UE without Inactive state capability is up and running
- NRBTS.drbInactivityTimerSARedCap, NRBTS.drbRrcInactInactivityTimerSARedCap and NRBTS.srbInactivityTimerSARedCap parameters are configured
- NRBTS.activityNotificationLevelSA is configured and set to: 'ue'
- CB008225 is activated and configured
- CB008225-A#B1  CB008225 Feature activation NR Cell Configuration of RAN Area Code and broadcast of SIB1 for RRC Inactive State - RAN Sharing [5G_RAN_USR_RRM_18000]
- PCMD tracing activated and configured as per preconditions for USCB008225-J#B01 gNB-CU UeDuConnectivity Record from gNB-CU-CP during RRC_Connected to RRC_Inactive transition [5G_RAN_USR_RRM_18794]
- nonRedCap UE has finished RRC connection establishment and Initial Context Setup procedure is finished with PDU session established as per USCB009384-A#B2: RedCap UE identification during call setup
- one or more PDU Session (DRB) is established, no 5QI1 DRB is established
- nonRedCap UE is served by PLMN where RANAC is configured
- CoreNetworkAssistanceInformationForInactive IE is received in NGAP:InitialContextSetupRequest

Trace Session to provide PCMD metrics is activated on gNB-CU-CP.
- TCE is configured in MNL/TCEADM/TCE.
- NRBTS-actPCMDReport set to TRUE.
- NRBTS/NRCTRLTS/NRMTRACECU-actPCMDReporting set to TRUE.
- NRBTS/NRCTRLTS/NRMTRACECU.jobType= ImmediateMDTAndTrace.
- Max number of traced UEs is not reached on gNB cell (NRBTS/NRCTRLTS/NRMTRACECU/cellMaxActiveUEsTraced)
- gNB-CU-CP has selected UE for trace and indicated start of trace recording session to TCE.


### 2. Test Steps


#### Step 1: Attach RedCap UE without RRC Inactive Support to Source gNB (RANSIM) with one PDU session

- Description:
  - amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
  - ue_register id=1
  - ue_start_pdu_session ue=1 pdu=1 gw=1

- Expected:
  - UE is in RRC_CONNECTED and PDU Session is successfully setup

#### Step 2: Wait for RRC Release

- Description: gNB sends RRC Release and UE is moved to RRC IDLE
- Expected:
  - UE state transition is initiated when both NRBTS.drbInactivityTimerSARedCap and  NRBTS.srbInactivityTimerSARedCap timers are expired
  - UE is moved to RRC IDLE state
  - RRC Release without Suspend config, NGAP UEContextReleaseRequest and NGAP UEContextReleaseCommand are present in pcap
 

### 3. Postconditions

- UE is transitioned to RRC_IDLE state. DRB inactivity for RedCap UE is detected based on NRBTS.drbInactivityTimerSARedCap parameter. SRB inactivity is detected based on NRBTS.srbInactivityTimerSARedCap timer expiration.
- PCMD records are collected and reported to TCE.


## 5. REFERENCES

- [1] /RA System General Modules/Common CFAM/010600-010799/CFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNBCFAM_CB010751_RedCap_RRC_Inactive_State_under_Same_gNB 
- [2] 
  - `5G_RAN_USR_RRM_24509'


## 6. HISTORY

- V 0.1: 02.01.2024: Adarsha P Hegde: initial creation: under review
- V 0.2: 12.03.2024: Marcin Plawny: modify scenario to cover case where UE doesnt support RRC Inactive
