*** Settings ***

Force Tags    CB008423   SBTS22R2    STATE_CONFIGURED    CRT    RAN_5G   RAN_5G_FDD    SBTS00

Documentation
...
...     INTRODUCTION:  5GCB008423-5G ABIO NR legacy features support TDD CPRI
...     Within this feature CB008423, legacy features (SiSo, TRS, Operability and RRM/Telecom domain) are needed to parity
...     to ABIO to make sure NR TDD CPRI working on ABIO.
...
...     RRM domain:
...     RRM/Telecom features already ported to ABIO (already supported in TDD eCPRI on ABIO) in previous releases but might require
...     additional work/verification with TDD CPRI support
...
...     TEST SET NAME:  CB008423
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : 5GC002255-G 5GC001390-G gNB reconfiguration (Cell Lock/Unlock with/without Graceful Cell Shutdown) and ABIL Failure
...     handling and recovery
...
...     PRECONDITIONS:  GNB and Airphone should be installed
...
...     DEPENDENCIES:  -
...
...     TEST INSTANCE SPECIFIC NOTES:
...                 Case 1: 5GC002255_G_B1_2_B1_Lock_FDD_Cell_WithGracefulShutdown_UE_Attached_On_TDD
...                 TEST CASE NAME - 5GC002255_G_B1_2_B1_Lock_FDD_Cell_WithGracefulShutdown_UE_Attached_On_TDD
...                 Purpose: This test is to check the UE (non CA, attached on TDD scell) behaviour when FDD cell (pcell)
...                 is locked with gracefully shutdown
...                 Cell Lock with Graceful Cell Shutdown enabled is performed on the FDD cell which is the PCell for UEs
...                 configured for Carrier Aggregation.5G UE in SA ABIO setup
...
...     CONTACTS:
...     FOT Leader: Plamowska, Justyna (Nokia - PL/Wroclaw)
...      L1 EFS:
...             Hu, Wenquan (Nokia - FI/Espoo)
...             Antonio RodriguezEmilio (Nokia - FI/Espoo)
...             Raappana, Janne (Nokia - FI/Espoo)
...      OAM EFS:
...             Jimenez, Renee (Nokia - PH/Taguig City)
...             Liu, Wei 9. (NSB - CN/Hangzhou)
...             Xu, Haijing (NSB - CN/Hangzhou)
...
...      Focal point Link:
...            https://focalpoint-prod.int.net.nokia.com/fp/workspace/1314/view/12098/element/27536
...
...      CFAM leader:
...             Yang, Biao 1. (NSB - CN/Hangzhou)
...
...      CFAM Path:
...            https://nokia.sharepoint.com/sites/ASCOP/AS%20Documents/Forms/AllItems.aspx?csf=1&web=1&e=cqeuDR&cid=f098bf7f%2D008d%2D459b%2Db0f
...            3%2D32ecb0497025&FolderCTID=0x012000D96F54C70C4C3547AE19DA5D399C6414&viewid=73435348%2D8379%2D4262%2Da3aa%2Dffe0b7322e0c&id=%2Fsi
...            tes%2FASCOP%2FAS%20Documents%2FFS1TAs%2DCFAMs%2FCB%2FCB008000%20%2D%20CB008499%2FCFAM%2FCB008423%20ABIO%20NR%20legacy%20features%
...            20support%20TDD%20CPRI
...
...      FS1TA:
...             https://nokia.sharepoint.com/sites/ASCOP/AS%20Documents/Forms/AllItems.aspx?csf=1&web=1&e=cqeuDR&cid=f098bf7f%2D008d%2D459b%2Db0f
...             3%2D32ecb0497025&FolderCTID=0x012000D96F54C70C4C3547AE19DA5D399C6414&viewid=73435348%2D8379%2D4262%2Da3aa%2Dffe0b7322e0c&id=%2Fsi
...             tes%2FASCOP%2FAS%20Documents%2FFS1TAs%2DCFAMs%2FCB%2FCB008000%20%2D%20CB008499%2FFS1TA%2FCB008423%20ABIO%20NR%20legacy%20features
...             %20support%20TDD%20CPRI
...
...      FIVE:
...            The final planning/results document is now placed in Sharepoint:https://nokia.sharepoint.com/sites/RFPdocuments/5G/Forms/AllItems.
...             aspx?originalPath=aHR0cHM6Ly9ub2tpYS5zaGFyZXBvaW50LmNvbS86Zjovcy9SRlBkb2N1bWVudHMvRXZmNU5ORmdOODVKdnZjQ3dodHN2N2dCeUpyWkk3UFJ3a3F
...             McnREYnUyVWp0Zz9ydGltZT1NSk1xV0xPeDJFZw&isAscending=false&OR=Teams%2DHL&CT=1632907674908&id=%2Fsites%2FRFPdocuments%2F5G%2FField%
...             20Verification%20FOT%20deliverables%2FCB008423%20ABIO%20NR%20legacy%20features%20support%20TDD%20CPRI%20RadFld%5FFiVe%5F5G&sortFi
...             eld=Modified&viewid=443081e0%2D6304%2D4fc8%2Dbaf2%2D6fe793322a17
...
...      REFERENCES:  CFAM CB008423 (5G_RAN_USR_17249)
...
...      TERMS AND ABBREVIATIONS:  -
...
...      HISTORY:  History, current status and TC description is available in repository:
...                [20.12.2021] - Created TCs
...                [18.01.2021] - Updates to Test suite documentation update and Keywords done
...                [18.01.2022] - Test suite documentation update.
...                [21.12.2021] - TC code review completed https://collab.ext.net.nokia.com/ui#review:id=851019
...
...               Test Case Scenario author   : vandana.b@nokia.com
...               Test Case Scenario contact  : vandana.b@nokia.com
...               Test Case automation author : vandana.b@nokia.com
...               Test Case automation contact: vandana.b@nokia.com
...               Creation Date               : 21-December-2021
...               Modified Date               : 18-January-2022
...               Last Modified by            : vandana.b@nokia.com

Library        taf.transport.ssh           WITH NAME    taf_ssh
Library        taf.wts.runner              WITH NAME    wtsrunner
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       robot/5GC002255_Keywords.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.core   WITH NAME   core
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/Airphone.robot
Resource       ../resources/robot/WTS_Runner_Keywords.robot
Library        ../resources/python/BIP_Capture.py
Library        ../resources/python/CPRT_Capture.py
Resource       ../resources/robot/PM_Counters.robot
Resource       ../resources/NPS/SWENG/robot/Counters.robot
Resource        ../resources/NPS/SWENG/Pm/pmc.robot
Library         ./resources/Lib/UE_Release_Valdation_fdd.py

# Bring up the testline with basic configuration
Suite Setup         Run keywords     Suite setup from scratch
...               AND    Delete routes
...               AND    Get swconfig files for gNB
...               AND    Get swconfig files for AP
#...               AND     Full Commission SCF         SCFC_with_gracefulshutdown.xml
...               AND     Sleep    5min
...               AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner

*** Variables ***
${DELTA_LOCK_FILE}        delta_FDD_lock.json
${DELTA_UNLOCK_FILE}      delta_FDD_Unlock.json
${XML_PARAMS_DICT}     6486
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${AP_FCT_BOARD_TYPE}           ${EMPTY}
${AP_ASP_BOARD_TYPE}           ${EMPTY}
${gnb_swconfig}    ${CURDIR}/config/gnb_swconfig.txt
${ap_swconfig}    ${CURDIR}/config/ap_swconfig.txt
@{CAslNone}          none
@{CAslFddFr1Tdd}     ca_Fdd_Fr1Tdd_Sa   #branch 0.800.xxx  (trunk)
@{Activated}     true
&{B_18}          carrierAggregationSupportList=${CAslNone}
&{B_20}          actGrflShd=${Activated}
&{B_17}          carrierAggregationSupportList=${CAslFddFr1Tdd}
${CrntiOK}        false
${Crnti}        true
${wts_cfg_file}     ${CURDIR}/config/TL63_Basic_CA_L1BPulptrdisabled.cfg
${WTS_DIR}          /opt/iphy/WTS
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID3}     1
${gw_ID2}     2
${gw_ID1}     3
${gw_ID4}     4
${Pdu_session_ID3}       3
${Pdu_session_ID2}       2
${Pdu_session_ID1}       1
${Pdu_session_ID4}       4
${UE_ID3}        3
${UE_ID4}        4
${UE_ID2}        2
${UE_ID1}        1
${QFI_ID}    1
${TRF_ID1}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${TRF_ID5}    5
${TRF_ID6}    6
${TRF_ID7}    7
${TRF_ID8}    8
${TRF_ID9}    9
${TRF_ID10}    10
${TRF_ID11}    11
${TRF_ID12}    12
${TRF_ID13}    13
${TRF_ID14}    14
${TRF_ID15}    15
${TRF_ID16}    16
${TRF_ID17}    17
${TRF_ID18}    18
${TRF_ID19}    19
${TRF_ID20}    20
${path}     /opt/iphy/WTS/uec.log
${UE}       UE3
${UE1}       UE1
${IPHY_XML}                     ${CURDIR}/config/iphy.xml
${file_path}                     ${CURDIR}/config/iphy.xml

*** Test Cases ***
[1][1.0] 5GC002255_G_B1_2_B1_Lock_FDD_Cell_WithGracefulShutdown_UE_Attached_On_TDD
    [Tags]  Atach_FDD
    # Start CPRT logs
    5GC002255_Keywords.Start Capture CPRT
    #Start collecting the syslogs
    Start Collecting Syslog     NAME=syslog_fdd_with_graceful_shutdown
    # Attach CA capable SA UE - UE3
    WTS_Runner_Keywords.UE Register should be Successful     ${UE_ID3}    ${Pdu_session_ID1}    ${nwslice_ID}    ${gw_ID3}
    #Attach UE 2  : non CA      : TDD
    WTS_Runner_Keywords.UE Register should be Successful     ${UE_ID2}    ${Pdu_session_ID2}    ${nwslice_ID}    ${gw_ID2}
    #Attach UE 1  : non CA      : TDD
    WTS_Runner_Keywords.UE Register should be Successful     ${UE_ID1}    ${Pdu_session_ID3}    ${nwslice_ID}    ${gw_ID1}
    #Attach UE 4  : non CA      : FDD
    WTS_Runner_Keywords.UE Register should be Successful     ${UE_ID4}    ${Pdu_session_ID4}    ${nwslice_ID}    ${gw_ID4}
    #Start the traffic with 4 streams to get the better Tput for CA capable SA UE - UE3
    Generate 300mpbs traffic     ${ue_id3}    ${Pdu_session_ID1}    ${QFI_ID}
    #Start the traffic with 4 streams to get the better Tput for UE 2  : non CA : TDD
    Generate 40mpbs traffic     ${ue_id2}    ${Pdu_session_ID2}    ${QFI_ID}
    #Start the traffic with 4 streams to get the better Tput for UE 1  : non CA : TDD
    Generate 40mpbs traffic     ${ue_id1}    ${Pdu_session_ID3}    ${QFI_ID}
    #Start the traffic with 4 streams to get the better Tput for UE 4  : non CA : FDD
    Generate 40mpbs traffic     ${ue_id4}    ${Pdu_session_ID4}    ${QFI_ID}
    sleep   20s
    #Check DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    #Check DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    #Check DL RLC PDU volume transmitted over secondary path - QoS Group 06 (M55311C44006)
    #Check DL RLC PDUs transmitted over secondary path- QoS Group 06 (M55311C45006)
    #Check DL RLC PDU volume transmitted over primary path - QoS Group 06 (M55311C42006)
    #Check DL RLC PDUs transmitted over primary path- QoS Group 06 (M55311C43006)
    #DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55310C01006   #CELLS/NRCELL-1/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55310C01006   #CELLS/NRCELL-2/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 06 (M55311C44006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C44006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDUs transmitted over secondary path- QoS Group 06 (M55311C45006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C45006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_SEC_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over primary path - QoS Group 06 (M55311C42006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C45006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDUs transmitted over primary path- QoS Group 06 (M55311C43006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C43006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_PRI_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over primary path - QoS Group 06 (M55311C42006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C42006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_06
    Check counter value is non zero     ${status}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 06 (M55311C44006)
    ${status} =    5GC002255_Keywords.Get Max PM Counter Value With Admin    M55311C44006   #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_06
    Check counter value is non zero     ${status}
    #Lock the FDD Cell
    Delta Commission With SCF File    ${DELTA_LOCK_FILE}
    #validation for FDD Cell Lock
    ${egate_fdd_lock_validation}      validate_ue     ${path}
    Run Keyword And Continue On Failure    Should Be True    ${egate_fdd_lock_validation}
    #Unlock the FDD Cell
    Delta Commission With SCF File    ${DELTA_UNLOCK_FILE}
    #stop capturing CPRT
    5GC002255_Keywords.Stop Capture CPRT
    #stop capturing syslogs
    Stop Collecting Syslog       NAME=syslog_fdd_with_graceful_shutdown
