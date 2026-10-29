# CB007065 - Parity energy savings for RU connected in Cloud RAN
Robot test suite for feature CB007065.

## Test line requirements
This section is taken from automation requests done by Adrian Tomczyk.
* CloudRAN gNB (#6.1 SKT in SA mode),
* RINLINE2 RAN NIC,
* Operational gNB in NSA/SA - vCU, vDU
* mMIMO radio unit

### Required initial BTS state (not to be checked but provided directly from SCF)
* The CB008133 feature is activated for the gNB (actNrLBmMimoRTXPowerSaving = True).
* At least one power group has switch-off method configured as TX switch-off (lbpsSOMethod = TX switch off).
* At least one power group has switch-off method configured as cell switch off (lbpsSOMethod = cell switch off).
* Load-based power saving is NOT suspended for a current power saving period:
  (NRPGRP:lbpsPeriodList:lbpsSuspended = False).
* The local time is within a power group load-based power saving period
  (NRPGRP:lbpsPeriodList(lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute, lbpsDuration)
* actLbpsCtrlLogicEnh=true
* gNB has neighbor eNB connected by X2 link
* NR Cell is configured as NSA cell


## Test cases

### CB007065_B_CB008133_Power_reduction_via_load_based_massive_MIMO_power_saving_with_32TRX_path_switch_off
The purpose of this test case is to check if energy saving counters (M55601C02001 and M55601C02002)
change their value and if power reduction via load based massive MIMO power saving with 32TRX path
switch off works correctly.

#### Test specific Preconditions
* 64T64R mMIMO radio unit
* actNrLBmMimoRTXPowerSaving = True
* Power group has switch-off method configured as TX switch-off (lbpsSOMethod = TX switch off)
* NRBTS.NRPMRNL.miNrCellAvailability needs to be set for counters to be collected

#### Requirements:
* 5G_RAN_USR_RRM_25872
* 5G_RAN_OP_2466
* 5G_RAN_OP_2399
* OM_GEN_SFS_SYSM.6428
* 5G_RAN_OP_2460


* Owner: adrian.tomczyk@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Wait for counters M55601C02001 and M55601C02002 to be collected and check their value.
  * Expected:  
    Collection of counters is successful and values are correct.
* Step 2:
  * Description:  
    Attach UE to cell and check energy saving state.
  * Expected:  
    UE attach performed without issues. Cells in tested NRPGRP have state energySavingState = reducedEnergySaving.
    Half TXes in tested NRPGRP are muted.
* Step 3:
  * Description:  
    Generate traffic (nGBR load) in tested NRPGP above maximum load threshold and check energy saving state.
  * Expected:  
    Cells in tested NRPGRP have state energySavingState = notEnergySaving. All TXes in tested NRPGRP are unmuted.
* Step 4:
  * Description:  
    Stop data transfer and detach UE. Check energy saving state.
  * Expected:  
    Data transfer is stopped and UE is detached. Cells in tested NRPGRP have state
    energySavingState = reducedEnergySaving. Half TXes in tested NRPGRP are muted.
* Step 5:
  * Description:  
    Check values of counters M55601C02001 and M55601C02002.
  * Expected:  
    Collection of counters is successful and values are correct.


#### Automatic TC steps
* Preconditions
* Step 1: Collect And Analyze Counters
* Step 2: Perform Attach
* Step 3: Perform Data Transfer
* Step 4: Stop Data Transfer
* Step 5: Collect And Analyze Counters


#### Test case developer notes
* M55601C02001 will increment when cell changes state to 'reducedEnergySaving', so after stopping
  data transfer (+switch off timer).
* M55601C02002 will decrease if cell leaves energy saving (goes into 'notEnergySaving' state). If cell
  is in 'reducedEnergySaving' for full counter period it will have value of that period x 60 (since it
  calculates number of samples (approximately seconds) when cell is in energy saving
  ('reducedEnergySaving' or 'switchingOnTX')).

#### History of changes
* 16.10.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1349 - Initial creation
* 18.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1362 - Separating NRBTS and MRBTS
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1434 - Fixed issue with vCU/vDU disconnecting after gathering counters
* 02.12.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1661 - Changed name of 'Get Full APN Name For Android UE' KW


### CB007065_B_CB010471_Interworking_with_5GC000431
The purpose of this test case is to check if energy saving with 'TX switch off'
and 'cell switch off' switch off methods work properly when configured on the same TL.

#### Test specific Preconditions
* Different cells configured in different power saving groups (PSGs)
* actNrLBPowerSaving = True
* One power group has switch-off method configured as TX switch-off (lbpsSOMethod = TX switch off)
* One power group has switch-off method configured as cell switch-off (lbpsSOMethod = cell switch off)
* Parameter lbpsLastCellSOEnabled is set to false for both PSGs (done inside test). Cells in both PSGs
  are in notEnergySaving state.

#### Requirements:
* 5G_RAN_USR_RRM_25875


* Owner: adrian.tomczyk@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Perform attach to cell with lbpsSOMethod=TX switch off and lbpsLastCellSOEnabled=false.
  * Expected:  
    Attach performed correctly.
* Step 2:
  * Description:  
    Perform attach to cell with lbpsSOMethod=cell switch off and lbpsLastCellSOEnabled=false.
  * Expected:  
    Attach performed correctly.
* Step 3:
  * Description:  
    Perform recommissioning for lbpsLastCellSOEnabled=true for both power saving groups.
  * Expected:  
    Recommissioning performed correctly. No unexpected alarms appeared.
* Step 4:
  * Description:  
    Wait for energy saving state to change for cells from both power groups.
  * Expected:  
    Cell in power group with lbpsSOMethod=TX switch off is in reducedEnergySaving state.
    Cell in power group with lbpsSOMethod=cell switch off is in energySaving state.


#### Automatic TC steps
* Preconditions
* Step 1: Attach UE To Cell With TX Switch Off
* Step 2: Attach UE To Cell With Cell Switch Off
* Step 3: Activate TX And Cell Switch Off
* Step 4: Check Energy Saving State


#### Test case developer notes
* Parameter lbpsLastCellSOEnabled is changed to false at the beginning of the test and then back to true
  at the end for tested power groups.
* It is assumed that there is only 1 cell in each of the tested power groups.
* During test it is checked if following messages exist: x2ap.procedureCode == 27 (4 packets), x2ap.procedureCode == 28
  (2 packets), x2ap.radioNetwork == 11 (1 packet).
* It was discussed with test owner that checking timings for cell changes is not crucial in this test therefore timeout
  for switch on and switch off for both tested cells is defined in respectively SWITCH_ON_TIMEOUT and SWITCH_OFF_TIMEOUT
  user variables.
* It was discussed that cell used in test can be NSA or SA - it does not matter. In test NSA cell was used.
* In preconditions additional wait was added for cells to go into energy saving and reduced energy saving states
  in case they were not in those states before that point.
* It was discussed with test owner that attach is only for the purpose of having UE in the cells at the start
  (UE for second cell will not be able to stay in NR since it will be switched off).

#### History of changes
* 18.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1351 - Initial creation
* 24.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1403 - Modified delta recommissioning operation
* 17.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1771 - Obsolete KW removal


### CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
The purpose of the test instance is to check the gNB behaviour when the MeNB requests to switch on one NR cell, and then CB010442 is activated.


#### Test specific Preconditions
* One power group has switch-off method configured as cell switch-off (lbpsSOMethod = cell switch off)
* Parameter lbpsLastCellSOEnabled is set to true for dedicated NRPGRP. Cell is in energySaving state.
* Feature CB010443 is activated on LTE side: actCoordinated4g5gPowerSaving = 2 (cellDeactAndReact)
* Feature CB010442 is activated in on 5G side:

    In CU
    * actCoordinated4g5gPowersaving = 2 (cellDeactAndReact)  

    In DU
    * actCoordinated4g5gPowersaving = 2 (cellDeactAndReact) 
    * actNrLBPowerSaving = True
* Check counters ENDC_CELL_ACT_ACC_X2 and NR_CELL_ACT_MENB_REQ before test case execution

#### Requirements:  
* 5G_RAN_USR_RRM_25870
* 5G_RAN_OP_2734

* Owner: adrian.tomczyk@nokia.com
* Author: mikolaj.kasian@nokia.com
* Maintainer: mikolaj.kasian@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Start load in LTE PSG Cell higher than lbpsMaxLoadNrAct.
  * Expected:  
    MeNB sends X2AP: EN-DC Cell Activation Request message to activate a NR cell (identified by NRCGI) 
    that is in EnergySaving state and one NRCELL that is unknown in the gNB. Only the first NR cell is used by gNB. 
    In step 2, gNB-CU-CP replies with X2AP: EN-DC Cell Activation Response message to the MeNB with the NR-CGI of the NR cell 
    in Energy Saving state in the Activated NR Cell List IE.
    EN-DC Cell Activation Request is visible over X2AP. Only the first NR cell is used by gNB
* Step 2:
  * Description:  
    gNB-CU-CP replies with X2AP: EN-DC Cell Activation Response message to the MeNB with the NR-GCI of the NR cell in the Activated NR Cell List IE.
  * Expected:  
    EN-DC Cell Activation Response message is received by the MeNB with correct information on NR Cell which is to be activated.
* Step 3:
  * Description:  
    Configuration Update message is sent to gNB-DU with Cells-to-be-Activated-List
  * Expected:  
    Expected result: Configuration Update message is received by the gNB.
* Step 4:
  * Description:  
    gNB-CU-CP replies to gNB-DU with F1AP: gNB-DU Configuration Update Acknowledge message.
  * Expected:  
    F1AP message: gNB-DU Configuration Update Acknowledge is received by gNB.  
* Postconditions  
MeNB is informed that the NR cell is activated The NR cell is in notEnergySaving state.  
Counters ENDC_CELL_ACT_ACC_X2 and NR_CELL_ACT_MENB_REQ shall increment after successful NR cell switch on.  
Below counter shall be available to check in WebEM  
  * ENDC_CELL_ACT_REQ_X2   
  * ENDC_CELL_ACT_ACC_X2  
  * ENDC_CELL_ACT_REJ_X2  
  * NR_CELL_ACT_MENB_REQ
  * NR_CELL_ACT_MENB_SUC


#### Automatic TC steps
* Preconditions 
    * Set parameters from preconditions to gNB only (eNB is simulated by WTS)  
    * Check initial counters values  
* Step 1: MeNB sends X2AP: EN-DC Cell Activation Request message  
* Postconditions  
      * Check messages (Steps 1-4 in test scenario defined by owner) by filters in pcap file
      * Check final counters values.


#### Test case developer notes
* Load in LTE PSG Cell is not started. It is not necessary because eNB is simulated. 
  And it is possible directly trigger sending EN-DC Cell Activation Request message
* During test, it is checked if following messages exist (1 packet per message):  
    * x2ap.ENDCCellActivationRequest_element && x2ap.nRcellIdentifier == 00:87:a0:00:20
    * x2ap.ENDCCellActivationResponse_element && x2ap.nRcellIdentifier == 00:87:a0:00:20
    * f1ap.GNBCUConfigurationUpdate_element && f1ap.Cells_to_be_Activated_List && f1ap.nRCellIdentity == 00:87:a0:00:20
    * f1ap.GNBDUConfigurationUpdateAcknowledge_element
    * f1ap.GNBDUConfigurationUpdate_element && f1ap.Cells_Status_List && f1ap.service_state == 0 && f1ap.nRCellIdentity == 00:87:a0:00:20
    * f1ap.GNBDUConfigurationUpdateAcknowledge_element
* In final counters values: ENDC_CELL_ACT_REQ_X2, ENDC_CELL_ACT_ACC_X2 increased by one, ENDC_CELL_ACT_REJ_X2 is with no changes.
* It was discussed with test owner that there are 3 "GNB CU ConfigurationUpdate" messages on f1ap interface with Cells_to_be_Activated_List 
  instead of one, and it is normal, even when one of them fails. For distinguishing proper message in confirmation, 
  filter was extended with f1ap.GNB_CUSystemInformation_element
* It was discussed with test owner that counters NR_CELL_ACT_MENB_REQ, NR_CELL_ACT_MENB_SUC can't be checked, because eNB is simulated

#### History of changes
* 09.12.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1353 - Initial creation
* 23.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1402 - Fixed issue with absent counters
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1434 - Fixed issue with vCU/vDU disconnecting after gathering counters

