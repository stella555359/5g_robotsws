# CB008933 - NR PMQAP PROFILES AND COUNTERS EXTENSION
Robot test suite for feature CB008933.

## Test line requirements.
* Classical gNB
* NR NSA cell with LTE anchor cell
* NR SA cell
* UE for NSA data transfer
* UE for SA data transfer

## Required initial BTS state (provided directly from SCF)
* gNB is setup for the SA deployment or NSA deployment
* tested cell in gNB is setup for the FR1-FDD
* MRBTS/ NRBTS/NRCELL.cellDepType = 'SANSA'
* The feature CB006898 is activated (NIDD parameter MRBTS/NRBTS.actNrpmqapProfiles is set to True)
* MRBTS/ NRBTS.actIpThpt is set to True 
* There are 64 NRPMQAP Profiles configured by creating MRBTS/ NRBTS/NRPMRNL/NRPMQAP.nrPmqapId MOC instances 
* MRBTS/NRBTS/NRPMRNL/NRPMQAP.cfgProfType is set to both in all profiles
* MRBTS/NRBTS/NRPMRNL/NRPMQAP.actL2Counters is set to TRUE in profiles: 
  - PMQAP#3 until PMQAP#22 
  - PMQAP#42 until PMQAP#60 
  - PMQAP#64 
* NRBTS/NRPMRNL/NRPMQAP.actL2Counters is set to FALSE in profiles:  
  - PMQAP#1, PMQAP#2, PMQAP#23 until PMQAP#41  
  - PMQAP#61 until PMQAP#63 
* MRBTS/NRBTS/NRPMRNL/NRPMQAP.actPacketSchedulerCounters is set to TRUE in profiles: 
  - PMQAP#4 until PMQAP#23 (20 Profiles)  
  - PMQAP#45 until PMQAP#64 (20 Profiles) 
* MRBTS/NRBTS/NRPMRNL/NRPMQAP.actPacketSchedulerCounters is set to FALSE in profiles: 
  - PMQAP#1 until PMQAP#3 
  - PMQAP#24 until PMQAP#44 
* MRBTS/NRBTS/NRPMRNL/NRPMQAP.actCplaneCounters is set to TRUE for all 64 NRPMQAP Profiles 
* MRBTS/NRBTS.actLatencyPmCount is set to True 
* MRBTS/NRBTS.actThpDist is set to True 
  
* miNrPdcpCellNrpmqap is set to 5min  
* miNrHighRlcCellNrpmqap is set to 5min 
* miNrHighRlcLatNrpmqap is set to 5min 
* miNrUeStatNrpmqap is set to 5min 
* miNrPRBthroughputpmqap is set to 5min 
* miNrNsaAcCuNrpmqap is set to 5min 
* miNrSaCuNrpmqap is set to 5min 
* miNrX2ccNrpmqap is set to 5min 
* miNrNgInterfaceNrpmqap is set to 5min 
* miNrSaAcDuNrpmqap is set to 5min 

## Test cases

### CB008933_A_Support_NRPMQAP_profiles_initial_configuration_in_L2_HI__L2_LO__L2_PS__C_plane 
The purpose of this test case is to check whether all counters from list below have been increased in specified profiles

#### Test specific Preconditions
* As in 'Required initial BTS state'

#### Requirements:
* 5G_PM_1507 
* CFAM_CB006898_PMQAP_Profiles_for_NR 
* CFAM_CB008933_PMO 

* Owner: mikolaj.kasian@nokia.com
* Author: magdalena.swierbutowicz@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Attach NSA UE#1 to eNB cell 
  * Expected:  
    UE#1 is successfully attached to eNB Cell#1 
* Step 2:
  * Description:  
    Trigger SqNB Addition procedure for UE#1
  * Expected:  
    UE#1 is successfully added to FDD Cell#3 in gNB as PSCell 
* Step 3:
  * Description:  
    Trigger UE1 DC Release due to SgNB user inactivity timer 
  * Expected:  
    Traffic for UE#1 is stopped. SgNB inactivity timer expires, and SgNB Release is sent from gNB to MeNB. Counters NX2CC_RAB_REL_ATT_SGNB_PMQAP and NX2CC_RAB_REL_NORM_SGNB_PMQAP are increased.
* Step 4:
  * Description:  
    Trigger SqNB Addition procedure for UE#1 
  * Expected:  
    UE#1 is successfully added to FDD Cell#3 in gNB as PSCell.
* Step 5:
  * Description:  
    Trigger UE1 DC Release due to MeNB user inactivity timer
  * Expected:  
    SGNB RELEASE REQUEST is received by gNB. Counter NX2CC_RAB_REL_NORM_MENB_PMQAP is increased.
* Step 6:
  * Description:  
    Trigger SqNB Addition procedure for UE#1 
  * Expected:  
    UE#1 is successfully added to FDD Cell#3 in gNB as PSCell.
* Step 7:
  * Description:  
    Trigger DC Release Due To Transport Resource Unavailable
  * Expected:  
    SGNB RELEASE REQUEST is received by gNB. NX2CC_RAB_REL_ABNOR_MENB_PMQAP is increased.
* Step 8:
  * Description:  
    Detach UE#1
  * Expected:  
    UE#1 is detached.
* Step 9:
  * Description:  
    Register UE#2 in SA mode
  * Expected:  
    UE#2 is successfully register to gNB Cell#3 and PDU session is established
* Step 10:
  * Description:  
    Start UL and DL traffic for  UE#2 
  * Expected:  
    Traffic is started correctly 
* Step 11:
  * Description:  
    Stop traffic and release UE#2 
  * Expected:  
    UE#2 is successfully released from the gNB Cell#3
* Step 12:
  * Description:  
    Verify Pm Counters Are Increased In Specific NRPMQAP 
  * Expected:  
    The following C-Plane counters are increased in all 64 Profiles:
    - CP-CELL  
    M55160C00001 - AVE_NUMBER_OF_NSA_USERS_PMQAP   
    M55160C00002 - AVE_NUM_NSA_USERS_DENOM_PMQAP   
    M55160C00003 - PEAK_NUMBER_OF_NSA_USERS_PMQAP   
    M55161C00001 - AVE_NUMBER_OF_SA_RRC_PMQAP   
    M55161C00002 - AVE_NUMB_OF_SA_RRC_DENOM_PMQAP   
    M55161C00003 - PEAK_NUMB_OF_SA_RRC_USER_PMQAP   
    
    - CP-UE  
    M55162C00001 - NX2CC_RAB_REL_ATT_MENB_PMQAP   
    M55162C00002 - NX2CC_RAB_REL_NORM_MENB_PMQAP   
    M55162C00003 - NX2CC_RAB_REL_ABNOR_MENB_PMQAP   
    M55162C00004 - NX2CC_RAB_REL_ATT_SGNB_PMQAP   
    M55162C00005 - NX2CC_RAB_REL_NORM_SGNB_PMQAP   
    M55162C00007 - NX2CC_RAB_SETUP_ATT_PMQAP   
    M55162C00008 - NX2CC_RAB_SETUP_ACK_PMQAP   
    M55162C00009 - NX2CC_RAB_SETUP_SN_PMQAP   
    M55163C00001 - NG_FLOW_SETUP_ATT_TOT_PMQAP   
    M55163C00002 - NG_FLOW_SETUP_SUCC_PMQAP   
    M55163C00003 - NG_FLOW_REL_PMQAP   
    M55163C00004 - NG_FLOW_REL_NORMAL_PMQAP   
    
    - CP-RT  
    M55193C00001       SA_DRB_DU_INI_REQ_PMQAP  
    
    L2-Hi counters are increased in Profiles: PMQAP#3 until PMQAP#22, PMQAP#42 until PMQAP#60 and PMQAP#64: 
    
    - L2-HI CU  
    M55352C00001 - DL_PDCP_TIME_UE_TPUT_PMQAP   
    M55352C01001 - DL_PDCP_VOL_UE_TPUT_PMQAP  
    
    - L2-HI DU  
    M55353C00001 - UL_RLC_VOL_UE_TPUT_PMQAP   
    M55353C01001 - UL_RLC_TIME_UE_TPUT_PMQAP   
    
    L2-PS and L2-LO counters are increased in Profiles: PMQAP#4 until PMQAP#23, PMQAP#45 until PMQAP#64: 
    
    -  L2-PS  
    M55356C00000 - ACC_UE_DL_DRB_DATA_PMQAP   
    M55356C00001 - ACC_UE_UL_DRB_DATA_PMQAP   
    M55356C00002 - MAX_UE_DL_DRB_DATA_PMQAP   
    M55356C00003 - MAX_UE_UL_DRB_DATA_PMQAP   
    M55363C00001 - DL_PRB_USED_DATA_PMQAP   
    M55363C00002 - UL_PRB_USED_DATA_PMQAP   
    M55363C00003 - DL_PRB_UTIL_SLOT_MAX_PMQAP   
    M55363C00004 - UL_PRB_UTIL_SLOT_MAX_PMQAP   
    
    -  L2-LO  
    M55158C00009 - DL_RLC_SDU_PMQAP  

#### Pass criteria
* PM counters in all NRPMQAP profiles in cell are incremented correctly

#### Automatic TC steps
* Preconditions
* Step 1: Attach UE1 In NSA Mode
* Step 2: Start UL And DL Traffic For UE1
* Step 3: Trigger UE1 DC Release 
* Step 4: Verify Tcpdump Logs 
* Step 5: Verify Pm Counters Are Increased In Specific NRPMQAP For NSA 
* Step 6: Register UE2 In SA Mode 
* Step 7: Start UL And DL Traffic For UE2 
* Step 8: Stop Traffic And Release UE2 
* Step 9: Verify Pm Counters Are Increased In Specific NRPMQAP For SA 

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* On real HW it takes more time to trigger counters, so the test checks the counter values for NSA and SA separately 
  in a different time slot
* This test was tested on simulated TL before. It was based on: 
  https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Wroclaw/RRM/WRO_2/CB008933

#### History of changes
* 10.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1380 - Initial creation
