# CB011169 - Parity RINLINE2 Legacy Features Support Step 5
Robot test suite for feature CB011169.

## Test line requirements
This section is taken from automation requests done by Michal Kowalczyk.
* CloudRAN gNB (#6.1 SKT in SA mode) with GNSS synchronization and 1x TDD FR1 AVQL RU with n78 band,
* Switched fronthaul connection for CloudRAN (FHGW),
* RINLINE2 RAN NIC,
* vDU,
* vCU,
* 1x real core network,
* UE PC with ELT installed,
* 1x TDD FR1 Radio (e.g. 1xAVQL or AQQS with n78 band),
* 3 x UE with 5G SA support, each with different band capabilities (100 MHz, 80 MHz and 20 MHz):
  * 100 MHz - Mediatek_M70_MT6885_Petrus as UE1,
  * 80 MHz - Nokia 8.3 with EFS reducing BW capability to 80MHz as UE2,
  * 20 MHz - Qualcomm SDx55 with EFS reducing BW capability to 20MHz as UE3

### Required initial BTS state (not to be checked but provided directly from SCF)
* gNB configured with TDD cell (100MHz, n78)
* CB007552 activation flag is enabled (NRBTS.actMultipleDedicatedBWPs = true)
* No PRBs blanked at 5G cell (NRBTS.actPRBBlanking = false)
* actSubscriberTraceReport = true
* actCellTraceReport = true
* actPCMDReport = true 
* actMDTTraceReport = true
* actUlNrEcIdPosMethod = true
* NRBTS.NRPMRNL.miNrCellUtilization = 15min (to check different intervals working)
* NRBTS.NRPMRNL.miNrRSADU = 30min (to check different intervals working
* NRBTS.NRPMRNL.miNrCCD = 5min (to check different intervals working)

## Test cases

### CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock
The purpose of this test case is to validate legacy and new counters for 3 BWP configuration
of TDD cell. All counters shall be checked in WebEM (appropriate counter assignment to vDU or vCU).

#### Test specific Preconditions
* None

#### Requirements:
* CFAM CB008954
* 5G_PM_1299
* 5G_RAN_USR_RRM_21319
* CFAM CB011169
* 5G_RAN_USR_RRM_24864


* Owner: michal.kowalczyk@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Make a cell lock and after some time cell unlock.
  * Expected:  
    Cell locks and unlocks itself and goes to on air after unlocking operation.
* Step 2:
  * Description:  
    Attach UE1 (with max BW capability = 100MHz), UE2 (with max BW capability = 80MHz)
    and UE3 (with max BW capability = 20MHz) to NR cell 1 on band n78.
    Send UL & DL throughput to all UEs at once. Additionally, make a VoNR call to autoresponder
    (call to 0105).
  * Expected:  
    UE1 attached, expected throughput and BLER.
* Step 3:
  * Description:  
    Go to MantaRay or WebEM and check following counters:
    * UE1 related
      * ACC_UE_DL_SCH_SLOT_BWP3 (M55308C00081)
      * ACC_UE_UL_SCH_SLOT_BWP3 (M55308C00083)
      * GNB_SA_DU_ADM_SUCC_BWP3 (M55139C02504)
      * MAX_UE_DL_SCH_SLOT_BWP3 (M55308C00082)
      * MAX_UE_UL_SCH_SLOT_BWP3 (M55308C00084)
      * PRB_USED_PDSCH_BWP3 (M55308C00085)
      * PRB_USED_PUSCH_BWP3 (M55308C00086)
      * SA_DU_ADM_ATT_GBR_BWP3 (M55139C04509)
      * SA_DU_ADM_SUCC_GBR_BWP3 (M55139C04510)
    * UE2 related:
      * ACC_UE_DL_SCH_SLOT_BWP2 (M55308C28005)
      * ACC_UE_UL_SCH_SLOT_BWP2 (M55308C28007)
      * GNB_SA_DU_ADM_SUCC_BWP2 (M55139C02502)
      * MAX_UE_DL_SCH_SLOT_BWP2 (M55308C28006)
      * MAX_UE_UL_SCH_SLOT_BWP2 (M55308C28008)
      * PRB_USED_PDSCH_BWP2 (M55308C29003)
      * PRB_USED_PUSCH_BWP2 (M55308C29004)
      * SA_DU_ADM_ATT_GBR_BWP2 (M55139C04507)
      * SA_DU_ADM_SUCC_GBR_BWP2 (M55139C04508)
    * UE3 related:
      * ACC_UE_DL_SCH_SLOT_BWP1 (M55308C28001)
      * ACC_UE_UL_SCH_SLOT_BWP1 (M55308C28003)
      * GNB_SA_DU_ADM_SUCC_BWP1 (M55139C02501)
      * MAX_UE_DL_SCH_SLOT_BWP1 (M55308C28002)
      * MAX_UE_UL_SCH_SLOT_BWP1 (M55308C28004)
      * PRB_USED_PDSCH_BWP1 (M55308C29001)
      * PRB_USED_PUSCH_BWP1 (M55308C29002)
      * SA_DU_ADM_ATT_GBR_BWP1 (M55139C04505)
      * SA_DU_ADM_SUCC_GBR_BWP1 (M55139C04506)
  * Expected:  
    Following counters are updated as per description in NIDD.
* Step 4:
  * Description:  
    Detach UE1 (with max BW capability = 100MHz), UE2 (with max BW capability = 80MHz) and UE3
    (with max BW capability = 20MHz) from NR cell 1.
  * Expected:  
    UE1, UE2 and UE3 are detached.

#### Pass criteria
* gNB and 5G cell are configured correctly
* Counters are properly assigned to vDU and/or vCU (accordingly with NIDD and MIND).
* Counters activation flags are properly assigned to vDU and or/vCU (accordingly with NIDD and MIND).
* Below counters are incremented as per description in NIDD:
  * ACC_UE_DL_SCH_SLOT_BWP1 (M55308C28001)
  * ACC_UE_UL_SCH_SLOT_BWP1 (M55308C28003)
  * GNB_SA_DU_ADM_SUCC_BWP1 (M55139C02501)
  * MAX_UE_DL_SCH_SLOT_BWP1 (M55308C28002)
  * MAX_UE_UL_SCH_SLOT_BWP1 (M55308C28004)
  * PRB_USED_PDSCH_BWP1 (M55308C29001)
  * PRB_USED_PUSCH_BWP1 (M55308C29002)
  * SA_DU_ADM_ATT_GBR_BWP1 (M55139C04505)
  * SA_DU_ADM_SUCC_GBR_BWP1 (M55139C04506)
  * ACC_UE_DL_SCH_SLOT_BWP2 (M55308C28005)
  * ACC_UE_UL_SCH_SLOT_BWP2 (M55308C28007)
  * GNB_SA_DU_ADM_SUCC_BWP2 (M55139C02502)
  * MAX_UE_DL_SCH_SLOT_BWP2 (M55308C28006)
  * MAX_UE_UL_SCH_SLOT_BWP2 (M55308C28008)
  * PRB_USED_PDSCH_BWP2 (M55308C29003)
  * PRB_USED_PUSCH_BWP2 (M55308C29004)
  * SA_DU_ADM_ATT_GBR_BWP2 (M55139C04507)
  * SA_DU_ADM_SUCC_GBR_BWP2 (M55139C04508)
  * ACC_UE_DL_SCH_SLOT_BWP3 (M55308C00081)
  * ACC_UE_UL_SCH_SLOT_BWP3 (M55308C00083)
  * GNB_SA_DU_ADM_SUCC_BWP3 (M55139C02504)
  * MAX_UE_DL_SCH_SLOT_BWP3 (M55308C00082)
  * MAX_UE_UL_SCH_SLOT_BWP3 (M55308C00084)
  * PRB_USED_PDSCH_BWP3 (M55308C00085)
  * PRB_USED_PUSCH_BWP3 (M55308C00086)
  * SA_DU_ADM_ATT_GBR_BWP3 (M55139C04509)
  * SA_DU_ADM_SUCC_GBR_BWP3 (M55139C04510)

#### Automatic TC steps
* Preconditions
* Step 1: Lock Cell
* Step 2: Unlock Cell
* Step 3: Start Data Transfers And Start Voice Call For UE 1
* Step 4: Collect And Analyze Counters For UE 1
* Step 5: Analyze TTI Traces For UE 1
* Step 6: Start Data Transfers And Start Voice Call For UE 2
* Step 7: Collect And Analyze Counters For UE 2
* Step 8: Analyze TTI Traces For UE 2
* Step 9: Start Data Transfers And Start Voice Call For UE 3
* Step 10: Collect And Analyze Counters For UE 3
* Step 11: Analyze TTI Traces For UE 3


#### Test case developer notes

* It was discussed with test owner that for UE3 capability may be reduced to 40MHz instead of 20MHz.
* Cell lock is performed only from vDU side. It is possible to perform cell lock also from vCU side.
* It was discussed with test owner that counter period can be set as the same for all parameters (e.g. 5min).
* It was discussed with test owner that DL, UL and VoNR do not need to be run for all UEs at the same time.
* UE logs in new feature testing were used for PRB checking so they are not necessarily needed in this test,
  since verification is done via TTI traces.
* As mentioned above test requires UE supporting 100MHz and 2 with lower capability (80MHz and 40MHz).
  UE may already have lower capability in which case no changes should be needed. If it does not it requires
  EFS files to be uploaded to it. This can be done using PCAT, entering EFS Explorer and choosing path:
  /nv/modem/nr5g/RRC then dragging EFS files there (UE restart may be needed). Files need to have specific names:
  cap_limit_bw, cap_add_bw (depending on the type of EFS that is being added).
* EFS files for Qualcomm SDX55 can be found in jira ticket https://jiradc.ext.net.nokia.com/browse/IWK-1332.
  They were provided by Adam Czapski.
* For this test to be able to download tti-dec (for parsing TTI traces) authentication token for artifactory
  needs to exist under path: /etc/token/ca_ute_artifactory_readonly. If it doesn't exist the test will fail.
* BWP PROFILE MOs for 80MHz and 40MHz need to exist for this test to work. It will only assign them to bwpDN.
* Test assumes a couple of conditions are met to simplify code:
  * there are only two BWP_PROFILES assigned to tested cell
  * apart from cellBwpId and bwpDN parameters in each item of cellBwpList are the same
* DIAG.cfg file is required for UE logs to be collected properly. Instruction on how to create it
  can be found under following link: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1384868005
* Licence Keeper needs to be running on UE PC for UE logs to be collected.
* For UE logs to be collected parameters: diag_cfg_path, server_dir and qcat_exe_path need to be added
  to UE configuration file. E.g.:
  UE_2:
                CAPABILITIES:
                    - NOKIA_UE
                    - REAL_ANDROID_UE
                    - NR_LOCKED
                CLASS: AndroidUe
                CONSTRUCTOR_PARAMETERS:
                    serial_number: 'HZQN1876AAKA1300230'
                    configuration:
                        ue_pc_address: '10.44.72.10'
                        diag_cfg_path: 'C:/taf_proxy/DIAG.cfg'
                        server_dir: 'C:/taf_proxy/'
                        qcat_exe_path: 'C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe'
                        data_transfer:
                            iperf:
                                app_server: *APP_1
                                interval: 1
                        ue_pc_port: '80'
* In case TTI conversion is taking too many of VM's resources it is possible to modify parameters of event decoder.
  Please refer to following conversation if more information is needed: https://teams.microsoft.com/l/message/
  19:7c14f321090e4594a2d86d5f330db93a@thread.skype/1727972568807?tenantId=5d471751-9675-428d-917b-70f44f9630b0&groupId
  =aaac7a75-7d1a-4bf8-93fb-8da9e50fbc57&parentMessageId=1727972568807&teamName=TAF&channelName=
  %F0%9F%90%9B%20Bugs%20and%20problems&createdTime=1727972568807. Information can also be found on taf.converters.eventdecoder library page:
  https://taf-converters-eventdecoder.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.converters.
  eventdecoder.interface.eventdecoder.create_eventdecoder_converter.
* TTI envent decoder was expanded with additional filtering parameter to lower the VM's resources usage. 
  Currently, eventdecoder_options are set to be split after 200000 events and include only events listed in file  
  "${CURDIR}${/}resources${/}Included_TTI_Events_List.txt", which holds only one filter "dlFdSchedData" on decoded events.


#### History of changes
* 23.09.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1332 - Initial creation
* 18.11.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1362 - Separating NRBTS and MRBTS
* 24.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1406 - Modified commissioning operation
* 29.01.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1411 - Refactor of TTI Trace handling in CB011169 TC
* 24.03.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1434 - Fixed issue with vCU/vDU disconnecting after gathering counters
* 27.10.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1580 - Refactor of VCU SCF modification
* 02.12.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1661 - Changed name of 'Get Full APN Name For Android UE' KW
