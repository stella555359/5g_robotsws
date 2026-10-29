# LTE4750 - LTE-NR Dynamic Spectrum Sharing phase II
Robot test suite for feature LTE4750.

## Developer notes
In most test cases, remote connection to gNB is used.
Inside __init__.py file, you need to have a variable like this:

REMOTE_TESTLINES = {'gNB': {'PC_IP1': '\<IP of VM used for management of gNB>'}}

It will be used by Common Test Setup to check gNB module and cell states, alarms, and start syslog, admin and infomodel.

## Test line requirements
This section is taken from automation requests done by Piotr Maj.

### Example configuration
HW LTE: AMIA+ASIB+2xABIA+ RMOD1+RMOD2+RMOD3+RMOD4 (any for band b5)

HW 5G: AMIA+ASIK+ABIL+ RMOD2+RMOD3+RMOD4 (AHLOA  most optimal for calls in the future)

RMOD2, RMOD3 and RMOD4 are shared between eNB and gNB

SHDF cable between ASIA and ASIK

#### LTE cell config

3 LTE cells on RMOD 1 (anchor cells)

1 LTE cell on RMOD2: 4TX/4RX

1 LTE cell on RMOD3: 4TX/4RX

1 LTE cell on RMOD4: 4TX/4RX

#### 5G cell config

1 5G cell on RMOD2: 4TX/4RX

1 5G cell on RMOD3: 4TX/4RX

1 5G cell on RMOD4: 4TX/4RX

### Required initial BTS state (not to be checked but provided directly from SCF)

#### LTE
* Six LTE cells configured, three with DSS disabled all the time (cells unlocked) and three where DSS phase 2 is set
(cells unlocked).

* All cells are unlocked 15 MHz LTE cell is up and running in FDD mode with correct software load supporting this
feature.
* RF sharing between LTE and NR with two CPRI links.
* LTE1710 'Sync Hub Direct Forward' and LTE4461 'NR-LTE FDD concurrent operation for CPRI RUs' is configured between gNb and eNb
* EN-DC is configured between:
  * LTE cell (PCell), that is not the LTE cell that is nominated to share the spectrum with an NR cell,
  * NR cell (PSCell), that is going to share the spectrum with the 15 MHz LTE cell
* lteNrDssMbsfnRatio/ minValue= 20
* lteNrDssMbsfnRatio/ maxValue = 60
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/blankedPucch is set to 0
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/selectOuterPuschRegion  is set to 'None'
* MRBTS/LNBTS/LNCEL/LNCEL_FDD/APUCCH_FDD/selectPrachRegion is not set to 'InnerUpperEdge'
* LNBTS/actLteNrDss = true
* For each cell that should be used as LTE DSS partner cell:
  * LNCEL/lteNrDssMode = DL_CRS_TDM_UL_FDM
  * LNCEL/DSSNR is set in accordance with values and ranges available in the NIDD
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
* lteNrDssMbsfnRatio/ minValue= 20
* lteNrDssMbsfnRatio/ maxValue = 60
* Shared NR cells are unlocked.
* gNb in sync with eNb.
* MRBTS/NRBTS/actLteNrDss = true
* MRBTS/NRBTS/NRCELL/lteNrDssMode = DL_CRS_TDM_UL_FDM

## Test cases

### IWK__dl_single_user_sharing_ratio_dynamic_adaptation__LTE4750
The purpose of this test case is to check percentage of PDSCH nonMBSFN subframes allocated to NR (M8029C217) with activated feature LTE4750.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None

Requirement:  RRM_LTE_SFS_RRM.14021

* Owner: piotr.1.maj@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* eNB and gNB and all cells are onAir
* LTE DL (UDP) call is started in DSS cell. Wait 3 min get value of M8029C217.
* NR DL (UDP) call is started in DSS cell. LTE DL (UDP) call is stopped. Wait 3 min get value of M8029C217.
* LTE DL (UDP) call is started in DSS cell. NR DL (UDP) call is stopped. Wait 3 min get value of M8029C217.


#### Pass criteria
Shared NR and LTE cells are onAir
No unexpected faults
M80029C217 has value
Step2=8
Step3=68
Step4=8

#### Automatic TC steps
* Preconditions
* Step 1: Start LTE DL call in DSS cell
* Step 2: Collect TTI Trace
* Step 3: Collect And Compare Counters
* Step 4: Stop LTE DL Data Transfer
* Step 5: Start NR DL call in DSS cell
* Step 6: Collect And Compare Counters
* Step 7: Stop NR DL Data Transfer
* Step 8: Start LTE DL call in DSS cell
* Step 9: Collect TTI Trace
* Step 10: Collect And Compare Counters
* Step 11: Stop LTE DL Data Transfer

#### History of changes
* 06.08.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-398 - Initial creation
* 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - Import of hran_dsp library (lte_interface=new) updated
* 29.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-775 - Added blanking=true argument for "Check Preconditions For LTE4750 Test" KW
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-920 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
               with 'Collect 4G TTI Trace'
  02.02.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1025 - changed  MCC-244/MNC-08 to MCC-${MCC}/MNC-${MNC}
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'
* 26.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1089 - 'Start Data Transfer' keyword enhancement
* 09.02.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1199 - addapted TC for Klecina TL
* 26.05.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1484  Increased timeout for Detach_UE KW
* 26.03.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1808  Adding apn parametr to Start data transfer KW

### IWK__online_pattern_adaptation_for_otdoa__LTE4750
The purpose of this test is to check that system correctly modifies pattern used
in downlink when LTE495 OTDOA feature will be activated in DSS cell (NR-LTE).
Pattern modification should be checked for three different prsConfigurationIndex/prsNumDlFrames
combinations.

#### Test specific Preconditions
* On eNB side:
  * For DSS cells 1-3: MRBTS/LNBTS/LNCEL/lteNrDssDlRatio/actOtdoa=false
* On gNB side:
  * None

* Owner: piotr.1.maj@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step1: BTS startup (if eNB is online it is not needed to reset it). Check value of crmAsgnSharingPattern for all cells.
* Check point1: For all cells crmAsgnSharingPattern= LMNN0L000L-L0000L000L-LMN00L000L-L0000L000L-LMN00L000L-L0000L000L-LMN00L000L-L0000L000L
* Step2: Attach user to LTE DSS cell then detach.
* Check point2: Attach is successful.
* Step3: Enable OTDOA feature in all three DSS cells -> please refer to 1.7.2
  * Cell1: prsConfigurationIndex=7 prsNumDlFrames=1
  * Cell2: prsConfigurationIndex=47 prsNumDlFrames=1
  * Cell3: prsConfigurationIndex=151 prsNumDlFrames=2
  Check value of crmAsgnSharingPattern
* Check point3: 
  * Cell1: crmAsgnSharingPattern= LMN00L0L0L-L0000LN00L-LM000L000L-L0000LN00L-LM000L000L-L0000LN00L-LM000L000L-L0000LN00L
  * Cell2: crmAsgnSharingPattern= LMN00L000L-L0000L00NL-LM000L000L-L0000L00NL-LM000L0L0L-L0000L00NL-LM000L000L-L0000L00NL
  * Cell3: crmAsgnSharingPattern= LMNN0L000L-L0000L000L-LMN00L000L-L0000L000L-LMN00L000L-L0000L000L-LMN00L000L-LLL00L000L
* Step4: Get LTE TTI trace (there is no need to have a call)
* Step5: Attach user to LTE cell then detach.
* Check point4: Attach is successful.
* Step6: Get snapshot


#### Pass criteria
* Check point 1: 
  * Pass: crmAsgnSharingPattern has expected value for all cells
  * Failed: crmAsgnSharingPattern has no expected value for all cells
* Check point 2
  * Pass: Attach is possible
  * Failed: Attach is not possible
* Check point 3
  * Pass: crmAsgnSharingPattern has expected value for all cells
  * Failed: crmAsgnSharingPattern has no expected value for all cells
* Check point 4
  * Pass: Attach is possible
  * Failed: Attach is not possible

#### Automatic TC steps
* Preconditions
* Step 1: Check Value Of CrmAsgnSharingPattern
* Step 2: Attach UE to LTE DSS Cell
* Step 3: Enable OTDOA In 3 DSS Cells And Check CrmAsgnSharingPattern
* Step 4: Get LTE TTI Trace
* Step 5: Attach UE to LTE DSS Cell


#### History of changes
* 07.10.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-294 - Initial creation
* 29.12.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-775 - Added Start Data Transfer before  Collect LTE TTI Trace
* 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-919 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
               with 'Collect 4G TTI Trace'
* 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1063 - Changed the protocol form 'udp' to 'tcp', added param. 'apn'

### IWK__ul_single_user_sharing_ratio_dynamic_adaptation__LTE4750
The purpose of this test case is to check percentage of PUSCH PRBs allocated to NR (M8029C216) with activated feature LTE4750.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None

Requirement:  RRM_LTE_SFS_RRM.14021

* Owner: piotr.1.maj@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* eNB and gNB and all cells are onAir
* LTE UL (UDP) call is started in DSS cell. Wait 3 min get value of M8029C216.
* NR UL (UDP) call is started in DSS cell. LTE UL (UDP) call is stopped. Wait 3 min get value of M8029C216.
* LTE UL (UDP) call is started in DSS cell. NR UL (UDP) call is stopped. Wait 3 min get value of M8029C216.


#### Pass criteria
Shared NR and LTE cells are onAir
No unexpected faults
M80029C216 has value
Step2=13
Step3=72
Step4=13

#### Automatic TC steps
* Preconditions
* Step 1: Start LTE UL Call In DSS Cell
* Step 2: Collect TTI Trace
* Step 3: Collect And Compare Counters
* Step 4: Stop LTE UL Data Transfer
* Step 5: Start NR UL Call In DSS Cell
* Step 6: Collect TTI Trace
* Step 7: Collect And Compare Counters
* Step 8: Stop NR UL Data Transfer
* Step 9: Start LTE UL Call In DSS Cell
* Step 10: Collect TTI Trace
* Step 11: Collect And Compare Counters
* Step 12: Stop LTE UL Data Transfer

#### History of changes
* 02.09.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-454 - Initial creation
* 09.11.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-517 - Improvement
* 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - Import of hran_dsp library (lte_interface=new) updated
* 14.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-790 - Removing needless step 6
* 06.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-953 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1000 - Replaced 'Collect LTE TTI Trace'
               with 'Collect 4G TTI Trace'
* 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1043 - changed  MCC-244/MNC-08 to MCC-001/MNC-01
* 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1044 - adding two variables  MCC and MNC


### IWK__ul_configuration_error_wrong_resource_allocation__LTE4750
Purpose of this test case is to verify that system informs by generating fault/alarm when uplink resource configuration is not correct (supported).
As extension for CNI-64534 it should also be verified whether additional information is added to the alarm for corresponding case.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None
  
* Owner: piotr.1.maj@nokia.com
* Author: adam.chamera@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Test scenario defined by owner
* Step1: eNB and gNB and all cells are onAir
* Step2:
  * In first cell below parameter is changed.
  * Parameter name | Parameter Value | Managed object
  * selectPrachRegion | None | MRBTS/LNBTS/LNCEL_FDD-0
  * In second cell bellow parameter is changed. 
  * Parameter name | Parameter Value | Managed object
  * maxNrDssRatio | 5 | MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio
  * Third cell shouldn’t be modified.
  * Plan is validated and activated.
* Step3: Wait 5 min. Check alarms and cell status.
  * Additional information is added to the alarm for corresponding case (see exact reasons in CCFM module).
    There should be visible one of the following reasons for fault 6138 (according to NIDD SBTS21B_FM-1.0 version 5.03): 
    * Reason 8007) [feature LTE4750] Subcarriers requested by NR are not adjacent to (contiguous with) the dynamic
      area(s). The dynamic areas are subcarriers that are not reserved nor blanked. It may occur that multiple dynamic
      areas can be derived.
    * Reason 8008) [feature LTE4750] Incorrect number of NR UL reserved areas.
    * Reason 8084) [feature LTE4750/5GC001856] The NR UL maximum share is too low to fulfil resources needed to operate
      the cell.
    * Reason 8085) [feature LTE4750/5GC001856] The UL minimum share of LTE is too low to fulfil resources needed
      to operate an LTE cell.
  * And one of the following reasons for fault 6136 (according to NIDD SBTS21B_FM-1.0 version 5.02):
    * Reason 6003) [feature LTE5635/CB007788] DSS reconfiguration failure due to: NR UL PRB blanking area
      does not match LTE reservation area for NB-IoT (higher than expected, extra blanking done inside LTE grid).
    * Reason 6004) [feature LTE5635/CB007788] DSS reconfiguration failure due to: NR UL PRB blanking area
      does not match LTE reservation area for NB-IoT (lower than expected).
    * Reason 6006) [feature LTE4750] DSS reconfiguration failure due to: Blanked LTE UL PRBs are not blanked
      by NR or blanked NR UL PRBs are not blanked on LTE (checked within LTE grid only).
    * Reason 6009) [feature LTE4750] DSS reconfiguration failure due to: Conflicting UL PRB reservations between
      LTE and NR.
    * Reason 6082) [feature LTE4750] DSS reconfiguration failure due to: There is no common DSS UL sharing ratio
      between LTE and NR due to NR minNrDssRatio higher than LTE maxNrDssRatio.
    * Reason 6083) [feature LTE4750] DSS reconfiguration failure due to: There is no common DSS UL sharing ratio
      between LTE and NR due to LTE minNrDssRatio higher than NR maxNrDssRatio.
    * Reason 6112) [feature LTE4750/5GC001856] DSS reconfiguration failure due to: Max UL NR DSS ratio is too low,
      required minimum UL PRBs could not be reserved for NR.
    * Reason 6113) [feature LTE4750/5GC001856] DSS reconfiguration failure due to: Min UL NR DSS ratio is too high,
      required minimum UL PRBs could not be reserved for LTE.
 * And one of the following reasons for fault 6137 (according to NIDD SBTS21B_FM-1.0 version 5.03):
    * Reason 7009) LTE/NR UL subcarrier reservations overlapping. PRB areas: LTE reserved 3-17 100-102 / blanked -,
      NR reserved 6-12 / blanked - (indexing per NR).
    * Reason 7082) [feature LTE4750] There is no common DSS UL sharing ratio between LTE and NR due to
      NR minNrDssRatio higher than LTE maxNrDssRatio. 
    * Reason 7083) [feature LTE4750] There is no common DSS UL sharing ratio between LTE and NR due to
      LTE minNrDssRatio higher than NR maxNrDssRatio. 
    * Reason 7112) [feature LTE4750/5GC001856] Max UL NR DSS ratio is too low, required minimum UL PRBs
      could not be reserved for NR. 
    * Reason 7113) [feature LTE4750/5GC001856] Min UL NR DSS ratio is too high, required minimum UL PRBs
      could not be reserved for LTE.
* Step4: Attach user to first cell.
* Step5: In first cell below parameter is changed.
  * Parameter name | Parameter Value | Managed object
  * selectPrachRegion | InnerUpperEdge | MRBTS/LNBTS/LNCEL_FDD-0
  * In second cell bellow parameter is changed. 
  * Parameter name | Parameter Value | Managed object
  * maxNrDssRatio | 70 | MRBTS/LNBTS/LNCEL/DSSNR/lteNrDssUlRatio
  * Third cell shouldn't be modified.
  * Plan is validated and activated.
Step6: Wait 5 min. Check alarms and cell status.
Step7: Attach user to first cell.

#### Pass criteria
* Shared NR and LTE cells are onAir
* No unexpected faults
* M80029C217 has value 26 in step2 and value 58 in step 3

#### Automatic TC steps
* Preconditions
* Step 1: Change DSS Related Parameters On eNB Side
* Step 2: Wait 5 Minutes And Check Alarms And Cell Status
* Step 3: Verify Attach To LTE DSS Cell
* Step 4: Restore Changed DSS Related Parameters On eNB Side
* Step 5: Wait 5 Minutes And Check Alarms And Cell Status
* Step 6: Verify Attach To LTE DSS Cell

#### Developer test case notes
* CNI-64534 lead to enhancing old code for this test case with alarm reasons. Alarm reasons are verified using regular
  expressions which use ID of the reason and do not check whole reason text, which looks as follows:
  'Reason (alarm_reason_1|alarm_reason_2|...alarm_reason_(n-1)|alarm_reason_n)'
* In 'Step 2: Wait 5 Minutes And Check Alarms And Cell Status' either alarm with fault ID 6137 or alarm with fault ID
  6138 appears. This is connected with timings and is hard to predict.

#### History of changes
* 08.09.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-456 - Initial creation
* 12.11.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-516 - Regex-or, to catch both faults 6137 or 6138, added;
changed cell to attach from lte-cell2 to lte-cell1; variable ${RECOMMISSIONING_TIMEOUT} added to the variables block
* 17.06.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-675 - Implemented improvements for CNI-64534
* 08.07.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-693 - 'MAINTAINER' updated
* 05.10.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-732 - Delete delta parameters
* 19.01.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-778 - Change for longPucch
* 04.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-928 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1001 - Removed unnecessary import of hran-dsp


### IWK__LTE_DL_dss_counters__LTE4750
Purpose of this test case is check downlink counters related to LTE4750 feature. Below counters should be checked:
M8029C211 NONMBSFN_UTIL_RATIO
M8029C212 MBSFN_NR_UTIL_RATIO
M8029C217 PDSCH_NMBSFN_NR_TTI_UTIL_RATIO
M8029C220 NUM_DL_TTI_UTIL_MAX_NR_DSS
M8029C221 NUM_DL_TTI_UTIL_MIN_NR_DSS
M8029C218 NUM_DL_SHARING_CHNG_NR_DSS

LTE_CCM2_1039; NIDD

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. 

#### Test scenario defined by owner
* Step1: Wait till new counter period is started.
* Step2: Start 5G DL oriented traffic in one shared cell -> call is ongoing.
* Step3: Wait 75s.
* Step4: Start 4G DL oriented traffic in one shared cell -> call is ongoing.
* Step5: Wait 75s.
* Step6: Release 5G DL call.
* Step7: Wait 75s.
* Step8: Start 5G DL oriented traffic in one shared cell -> call is ongoing.
* Step9: Wait 75s.
* Step10: Release 4G DL call.
* Step11: Wait 75s.
* Step12: Wait until new counters collection. Download counters.


#### Pass Criteria
* Counters are analysed for last 15 min (1 sample)
* M8029C211 NONMBSFN_UTIL_RATIO = 85 (that depends on configuration)
* M8029C212 MBSFN_NR_UTIL_RATIO = 15 (that depends on configuration)
* M8029C217 PDSCH_NMBSFN_NR_TTI_UTIL_RATIO > 0
* M8029C220 NUM_DL_TTI_UTIL_MAX_NR_DSS > 0
* M8029C221 NUM_DL_TTI_UTIL_MIN_NR_DSS > 0
* M8029C218 NUM_DL_SHARING_CHNG_NR_DSS > 0


#### Automatic TC steps
* Preconditions
* Step 1: Perform DL Data Transfers
* Step 2: Collect LTE DSS Counters
* Step 3: Check All Counters Values

#### History of changes
* 26.10.2020 - https://jiradc.int.net.nokia.com/browse/IWK-447 - Initial creation
* 13.11.2020 - https://jiradc.int.net.nokia.com/browse/IWK-520 - Converting list of counters from string to intiger type
* 14.02.2022 - https://jiradc.int.net.nokia.com/browse/IWK-793 - Increasing time interval in KW Collect PM Counters
* 04.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-890 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1001 - Removed unnecessary import of hran-dsp;
               added missing DateTime import
* 28.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1051 - Changed paths to counters to comply with newer
               specification, added necessary change to be able to evaluate counters in python3, corrected KW 
               *Get Counters Values* so that it fails when counter value is not assigned to variable.
* 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1185 - Adapt TC to Rozanka TL: add automated attenuator, change 
               several keywords so that the test is compatible from running it from gNB side, adapt TC for 15min counters
               collection
* 11.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1310 - Adapt TC so that it works with TL with DSS_Phase_3 configured.
* 25.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1317 - change maintainer of the TC


### IWK__LTE_UL_dss_counters__LTE4750
Purpose of this test case is check uplink counters related to LTE4750 feature. Below counters should be checked:
M8029C216 PUSCH_NR_PRB_UTIL_RATIO
M8029C219 NUM_UL_SHARING_CHNG_NR_DSS
M8029C222 NUM_UL_PRB_UTIL_MAX_NR_DSS
M8029C223 NUM_UL_PRB_UTIL_MIN_NR_DSS

LTE_CCM2_1039; NIDD

* Owner: piotr.1.maj@nokia.com
* Author: tomasz.stawowczyk@nokia.com
* Maintainer: tomasz.stawowczyk@nokia.com

#### Configuration and mandatory parameters
Configuration and mandatory parameters like in example above. 

#### Test scenario defined by owner
* Step1: Wait till new minute is started
* Step2: Start 5G UL oriented traffic in one shared cell -> call is ongoing.
* Step3: Wait 5s.
* Step4: Start 4G UL oriented traffic in one shared cell -> call is ongoing.
* Step5: Wait 5s.
* Step6: Release 5G UL call.
* Step7: Wait 5s.
* Step8: Start 5G UL oriented traffic in one shared cell -> call is ongoing.
* Step9: Wait 5s.
* Step10: Release 4G UL call.
* Step11: Wait 5s.
* Step12: Wait 240s. Download counters.


#### Pass Criteria
* Counters are analysed for last 5 min (5 samples)
* M8029C216 PUSCH_NR_PRB_UTIL_RATIO>0 in every sample
* M8029C219 NUM_UL_SHARING_CHNG_NR_DSS sum of five values >0
* M8029C222 NUM_UL_PRB_UTIL_MAX_NR_DSS sum of five values >0
* M8029C223 NUM_UL_PRB_UTIL_MIN_NR_DSS sum of five values >0


#### Automatic TC steps
* Preconditions
* Step 1: Perform UL Data Transfers
* Step 2: Collect LTE DSS Counters
* Step 3: Check All Counters Values

#### History of changes
* 26.10.2020 - https://jiradc.int.net.nokia.com/browse/IWK-450 - Initial creation
* 09.11.2020 - https://jiradc.int.net.nokia.com/browse/IWK-518 - Fixing bug in TC name
* 13.11.2020 - https://jiradc.int.net.nokia.com/browse/IWK-520 - Converting list of counters from string to intiger type
* 14.02.2022 - https://jiradc.int.net.nokia.com/browse/IWK-793 - Increasing time interval in KW Collect PM Counters
* 04.10.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-891 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-983 - Moved documentation to robotws
* 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-1001 - Removed unnecessary import of hran-dsp;
               added missing DateTime import
* 28.04.2023 - https://jiradc.ext.net.nokia.com/browse/IWK-1051 - Changed paths to counters to comply with newer
               specification, added necessary change to be able to evaluate counters in python3, corrected KW 
               *Get Counters Values* so that it fails when counter value is not assigned to variable.
