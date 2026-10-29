*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO   SBTS00    SBTS23R1    CONFIGURED    5G_RAN    RAN_5G    CRT
...             CONFIGS_Bangalore/RRM/ET/ABOO_2Cells_Configs/ABOO_2Cells_Config.yml   PY36

Documentation
...
...     INTRODUCTION: CB007873 - Spillover - carrier aggregation - remaining system items of 5GC001390 and 5GC002255
...     5GC001390-FB	CB007873-D	Spillover - carrier aggregation - Advanced flow control - NSA
...
...     RRM domain:
...     This feature introduces This user scenario describes the successful operations, deletion or addition of CA association between FDD cell
...     as PCell and FR1-TDD cell as SCell. The NR relation of the NR Cell can be updated online and UEs already connected to that NR cell as
...     PSCell prior to the change in EN-DC mode shall not be impacted by the change, change will be applied only upon this UE leaves the FDD
...     PSCell (SgNB release or outgoing PSCell change) and connects to the FDD Cell again. New UE connecting to the FDD cell of the gNB DU
...     (either as new EN-DC setup or as incoming PSCell change) shall follow the new configuration.
...
...     Only if the feature CB007873 is activated and CA association between FDD cell and Scell are configured, UE can be configured with
...     carrier aggregation. Otherwise, UE cannot be configured with carrier aggregation.
...
...     TEST SET NAME:  CB007873-D
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : The aim of this test is to trigger of highNackDtx indication from L2-PS which results in L2-HI
...     indicating DL radio link outage (F1-U DDDS with Cause value = 4 (DL RADIO LINK OUTAGE)) for NSA configuration.
...
...     PRECONDITIONS:  GNB and Airphone should be installed
...
...     DEPENDENCIES:  Req ID : 5G_RAN_USR_19287
...
...     TEST INSTANCE SPECIFIC NOTES:
...                 Case 1: CB007873_D_B3_1_hiNackDtx_indication_due_to_bad_radio_conditions_with_dynamic_data
...                  _split_over_PSCell_and_Scell_in_NSA_mode
...                 TEST CASE NAME - CB007873_D_B3_1_hiNackDtx_indication_due_to_bad_radio_conditions_with_dynamic_data
...                 _split_over_PSCell_and_Scell_in_NSA_mode
...                 Purpose: TThe aim of this test is to trigger of highNackDtx indication from L2-PS which results in L2-HI
...                 indicating DL radio link outage (F1-U DDDS with Cause value = 4 (DL RADIO LINK OUTAGE)) for NSA configuration.
...
...     CONTACTS:
...     FOT Leader:
...             Nouha Kayal
...     Product Line Management :
...             Massimiliano Morini
...      BTS EFS:
...             Gabriel Linden
...             Louis Madier
...             Morgan Cormier
...             Marianne Bignon
...             Severine Auburtin
...             Loic Rousseaux
...             Frederic Ribert
...             Christophe Jerome
...             Gerard Lenglet
...             Didier Lacroix
...             Didier Michenaud
...             Agnieszka Czech-Danielska
...             Grzegorz Kurczynski
...             Jakub Skretkowicz
...             Shilpkala Kulkarni
...
...      Focal point Link:
...           https://focalpoint-prod.int.net.nokia.com/fp/workspace/1314/view/12098/tree/24866
...
...      CFAM leader:
...             Ivan Cavlina
...
...      CFAM Path:
...           https://nokia.sharepoint.com/:x:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC1200-5GC1399/5GC001390-5GC002255%20CA%20Feature%20Bundle/
...           5G20B_CA-Bundle_Dependencies.xlsx?d=wcec507a9bc4c450d94c2eeb76de4c12e&csf=1&web=1&e=cLx4Sm
...
...      REFERENCES:  CFAM CB007873-D (5G_RAN_USR_19287)
...
...      TERMS AND ABBREVIATIONS:  -
...
...      HISTORY:  History, current status and TC description is available in repository:
...                [10.12.2021] - Created TCs
...                [30.03.2021] - Updates to Test suite documentation update and Keywords done
...                [18.01.2022] - Test suite documentation update.
...                [21.12.2021] - TC code review completed https://collab.ext.net.nokia.com/ui#review:id=851019
...
...               Test Case Scenario author   : vandana.b@nokia.com
...               Test Case Scenario contact  : vandana.b@nokia.com
...               Test Case automation author : vandana.b@nokia.com
...               Test Case automation contact: vandana.b@nokia.com
...               Creation Date               : 21-December-2021
...               Modified Date               : 30-March-2022
...               Updated Date                : 21-June-2022/11-Aug-2022
...               Last Modified by            : lavanya.p@nokia.com

Library        taf.transport.ssh           WITH NAME    taf_ssh
Library        taf.wts.runner              WITH NAME    wtsrunner
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       robot/CB007873_Keywords_D.robot
#Library        luashark_tools.analyzer       WITH NAME       analyzer
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
Library         ./resources/Lib/hiacknack_csv_analyser.py
#Library         ./resources/Lib/pcell_csv_analyser.py
Library          ute_fsmaccess
#Library          ta5g_commissioning
Library         ta5g_egate
Library         ta5g_enb
Library         ta5g_iphy
Library         ta5g_pm_counters
Library         ta5g_ue_mobility
Library         ta_egate_cmd_parser
#Library         ta5g_tshark
#Library         ute_tshark
Library         ta5g_testline_management

# Bring up the testline with basic configuration
Suite Setup         Run keywords     Suite setup from scratch
...               AND    add routes
...               AND    Add GNB RadParam for PDU_Enabled and SchedDelay_Disabled
...               AND    Add AP RadParam
...               AND     Reboot gNB System Module from Console and check Airscale is ready
...               AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...             AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...               AND    Sleep    5min
...               AND    Perform SCF Delta Commissioning with Hiacknack.json
...               AND    Sleep    2min
...               AND    CB007873_Keywords_D.Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Revert GNB RadParam
...                 AND     Revert AP RadParam
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

*** Variables ***
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${AP_FCT_BOARD_TYPE}           ${EMPTY}
${AP_ASP_BOARD_TYPE}           ${EMPTY}
${gnb_swconfig}    ${CURDIR}/config/gnb_swconfig_pcell.txt
${ap_swconfig}    ${CURDIR}/config/ap_swconfig.txt
@{CAslNone}          none
@{CAslFddFr1Tdd}     ca_Fdd_Fr1Tdd_Sa   #branch 0.800.xxx  (trunk)
@{Activated}     true
&{B_18}          carrierAggregationSupportList=${CAslNone}
&{B_20}          actGrflShd=${Activated}
&{B_17}          carrierAggregationSupportList=${CAslFddFr1Tdd}
${CrntiOK}        false
${Crnti}        true
${wts_cfg_file}     ${CURDIR}/config/basic_setup_2cells_7873_config.cfg
${WTS_DIR}          /opt/iphy/latest
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
${path}     /opt/iphy/epc_latest/uec_1.log
${UE}       UE3
${UE1}       UE1
${IPHY_XML}                     ${CURDIR}/config/iphy.xml
${file_path}                     ${CURDIR}/config/iphy.xml

*** Test Cases ***
[1][1.0] CB007873_D_B3_1_hiNackDtx_indication_due_to_bad_radio_conditions_with_dynamic_data_split_over_PSCell_and_Scell_in_NSA_mode
#Start CPRT Logs
    Start Capture CPRT
#Start collecting the syslogs
    CB007873_Keywords_D.Start Collecting Syslog    NAME=syslog_scell
#Apply BLER
#Set fixed bler for CA Capable UE
#Make the x2 link up
    wtsrunner.enb_x2_link_up          enb=1     target=2
#Configure and activate the bler profile
    wtsrunner.bler_testmode_nr            profile_id=1    dl_bler=500,500,500,500,500,500,500,500     ul_bler=0,0,0,0,0,0,0,0     pdcch_misd_rate=0
#Attach/Detach NSA FDD CA Capable UE and sned max data around 400Mbps
    Attach one FDD CA capable UE and 10 Non CA FDD UEs
    Sleep    300s
#Check 7873-D counters validation for non xero
    Run Keyword And Ignore Error    CB007873 Counters validation
#Wait for 5 mins to get counters update
    Sleep  300s
# Check again counters whether its been invreasing
    Run Keyword And Ignore Error    CB007873 Counters validation Bigger than previous GP
#Activate the Bler profile set
    Run Keyword And Ignore Error    Activate Bler profile
#Wait for 2 PM interval to get counters update
    Sleep  600s
# Check agaiin counters whether its been invreasing or decreasing
    Run Keyword And Ignore Error    CB007873 Counters validation for PCell counter decrement
#Wait for 5 mins to get counters update
#    Sleep  300s
# Check agaiin counters whether its been invreasing or decreasing
#    Run Keyword And Ignore Error    CB007873 Counters validation for Scell
#collect the snasphot for validation of 1ms
    setup.Get Snapshot
#Download the luashark files
#  Get Luashark File
#L2Traces validation for Bler pcell validation
#   L2HiTraces
#stop capturing CPRT
    CB007873_Keywords_D.Stop Capture CPRT
#stop capturing syslogs
    Stop Collecting Syslog    NAME=syslog_scell
