# CB008370 - PDSCH shared symbol with PDCCH
Robot test suite for feature CB008370.

## Test line requirements
This section is taken from automation requests done by Michal Kowalczyk.
* CloudRAN gNB (#6.1 SKT in SA mode),
* RINLINE2 RAN NIC,
* vDU,
* vCU,
* FHGW,
* GPS antenna - FYGC,
* 1x real AMF,
* 1x TDD FR1 Radio (e.g. 1xAVQL or AQQS with n78 band),
* UE PC with operation system installed,
* UE with 5G support

### Required initial BTS state (not to be checked but provided directly from SCF)
* gNB is setup for the SA deployment or NSA deployment.
* gNB is setup for the FR1-TDD deployment.
* The adaptive retransmission is activated (NIDD parameter /NRBTS/NRCELL/actAdaptiveReTxResMcs is set to True)
* The feature CB008370 is deactivated (NIDD parameter /NRBTS/NRCELL/actPdcchSharingWithPdsch is set to False)
* The PRB pooling feature CB008940 is deactivated (NIDD parameters /NRBTS/actBbPoolTddFr1 (TDD only)
  is set to FALSE), only if the HW is not ABIP/ABIQ. For ABIP/ABIQ boards, the features shall be activated.
  (see Common_HW_Validation_Rules_199 for reason).
* FDM scheduling is activated (NIDD parameter /NRBTS/actFdmScheduling is set to TRUE)
* The carrier aggregation is deactivated NRBTS/NRDU.carrierAggregationSupportList is set to 0
* The static aggregation level (AL4) is used for PDCCH (NIDD parameter NRBTS/bwp_profile.pdcch.alselection is set to 0)
* The feature CB008367 Dynamic PDCCH symbol usage on all dedicated BWPs is disabled (NIDD parameter
  /NRBTS/NRCELL/actDynPdcchTdMode is set to disabled) (TDD only)
* The PRB/RBG location randomization feature CB009426 is deactivated (NIDD parameter NRBTS/NRCELL/actDlRbgRandomization
  set to False)
* The DL intercell interference avoidance feature CB008955 is deactivated (NIDD parameter
  NRBTS/NRCELL/actDlInterferenceAvoidance set to False)
* The PA warm-up for adequate PDSCH EVM feature CB010359 is deactivated (NIDD parameter
  NRBTS/NRCELL/actDlPaWarmUp set to False)
* The UE under test is attached to the cell
* A nonGBR bearer (RLC AM) is setup in DL and UL for the UE
* NRCELL.actEnhancedPDSCHSchSplSlot set to TRUE

## Test cases

### CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions
The purpose of this test case is to check if activation of CB008370 increases DL cell throughput
during DL traffic in comparison to situation when CB008370 is deactivated. This test case checks
single UE scenario.

#### Test specific Preconditions
* None

#### Requirements:
* CFAM CB008370
* 5G_RAN_USR_RRM_24055
* 5G_PM_1556


* Owner: michal.kowalczyk@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Start collecting syslog for actPdcchSharingWithPdsch=false case.
  * Expected:  
    Collection of syslog has started successfully.
* Step 2:
  * Description:  
    Start full buffer DL UDP traffic in good radio conditions (around 80 dBm RSRP or higher)
    when actPdcchSharingWithPdsch is set to false. Let it run for few minutes.
  * Expected:  
    Full buffer DL UDP traffic are being sent to its destinations.
* Step 3:
  * Description:  
    Stop full buffer DL UDP traffic and save the tput results, stop logs collection
    for actPdcchSharingWithPdsch=false case.
  * Expected:  
    Collection of syslog has stopped successfully.
* Step 4:
  * Description:  
    Verify counters in NetAct or WebEM.
   * Expected:  
     Counters that shouldn?t be incremented:
     * NUM_1_PDCCH_SYMB_SHARE_PDSCH (M55335C02019)
     * NUM_2_PDCCH_SYMB_SHARE_PDSCH (M55335C02020)
    Counters that should be incremented:
     * PDSCH_OFDM_SYMBOLS (M55308C03001)
     * PDSCH_OFDM_SYMBOLS_TIME (M55308C03005)
* Step 5:
  * Description:  
    Start collecting syslog for actPdcchSharingWithPdsch=true case.
  * Expected:  
    Collection of syslog has started successfully.
* Step 6:
  * Description:  
    Start full buffer DL UDP traffic in good radio conditions (around 80 dBm RSRP or higher)
    when actPdcchSharingWithPdsch is set to true. Let it run for few minutes.
  * Expected:  
    Full buffer DL UDP traffic is being sent to its destinations.
* Step 7:
  * Description:  
    Stop full buffer DL UDP traffic and save the tput results, stop logs collection
    for actPdcchSharingWithPdsch=true case.
  * Expected:  
    Collection of syslog has stopped successfully.
* Step 8:
  * Description:  
    Verify counters in NetAct or WebEM.
  * Expected:  
    Counters that should be incremented:
    * PDSCH_OFDM_SYMBOLS (M55308C03001)
    * PDSCH_OFDM_SYMBOLS_TIME (M55308C03005)
    * NUM_1_PDCCH_SYMB_SHARE_PDSCH (M55335C02019) (if one PDCCH symbol is shared with PDSCH
      during the measurement interval)
    * NUM_2_PDCCH_SYMB_SHARE_PDSCH (M55335C02020) (if two PDCCH symbols are shared with PDSCH
      during the measurement interval)
* Step 9:
  * Description:  
    Stop collecting syslog for actPdcchSharingWithPdsch=true case.
  * Expected:  
    Collection of syslog has ended successfully.

#### Pass criteria
* PM counter with respect to throughput, PDCCH symbol sharing with PDSCH (see 5G_PM_1556 CB008370 PMO#1)
  and PDSCH symbols are updated with the test. Cell throughput put reaches TVTN values for used configuration.
* In both cases when CB008370 is activated or deactivated (NIDD parameter /NRBTS/NRCELL/actPdcchSharingWithPdsch
  is set to True/False):
  * The data transfer in DL is maintained if user data is available in transmission buffer.
* When CB008370 is activated (NIDD parameter /NRBTS/NRCELL/actPdcchSharingWithPdsch is set to True):
  * The cell throughput increases in DL.
  * Details to the throughput are specified with CB008370-W
  * During first measurement interval (when actPdcchSharingWithPdsch is set to False),
    new counters are not incremented and are reported with a value of 0
    (provided there are no sharing based on CB008367). Legacy counters mentioned above are incremented
    as per NIDD decription and update conditions.
  * During second measurement interval (when actPdcchSharingWithPdsch is set to True),
    new and legacy counters are incremented as per NIDD decription and update conditions.

#### Automatic TC steps
* Preconditions
* Step 1: Perform Data Transfer
* Step 2: Collect Counters
* Step 3: Activate CB008370
* Step 4: Perform Data Transfer
* Step 5: Collect Counters
* Step 6: Analyze Counter Values
* Step 7: Compare Throughput Values


#### Test case developer notes
* Counters M55308C03001, M55308C03005, M55335C02019, M55335C02020 only require DL throughput to work correctly.
  Due to this and issues with UL data transfer during test development only DL data transfer is being run in test case.
* NUM_2_PDCCH_SYMB_SHARE_PDSCH (M55335C02020) which is updated if two PDCCH symbols are shared with PDSCH during
  the measurement interval - this counter will currently not be incremented due to using only single UE in test and
  current TL configuration
* NUM_1_PDCCH_SYMB_SHARE_PDSCH (M55335C02019) which is updated if one PDCCH symbol is shared with PDSCH during
  the measurement interval - this counter should be incremented when feature is active.
* PDSCH_OFDM_SYMBOLS (M55308C03001) and PDSCH_OFDM_SYMBOLS_TIME (M55308C03005) should be incremented regardless
  of whether feature is active or not.
* Due to having OTA configuration throughput in test is lower.
* Logs required in test are snapshot, syslog (collected in snapshot, but also using KW from former ET)
  and PM files.

#### History of changes
* 17.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1308 - Initial creation
* 14.08.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1329 - Made changes to timings and counter collection
                                                                  due to change in configuration and renamed test
* 20.08.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1331 - Added C-plane logs collecting; changed number
                                                                  of counter files collected and counting start time;
                                                                  changed when recommissioning in teardown is performed
* 06.09.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1338 - Adjusting test case to work with multiple APNs
* 18.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1362 - Separating NRBTS and MRBTS
* 24.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1404 - Modified delta recommissioning operation
* 04.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1418 - Data transfer duration extended
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1434 - Fixed issue with vCU/vDU disconnecting after gathering counters
* 30.04.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1466 - Fixed issue with UE attach to cell being down after feature activation
* 02.12.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1661 - Changed name of 'Get Full APN Name For Android UE' KW
