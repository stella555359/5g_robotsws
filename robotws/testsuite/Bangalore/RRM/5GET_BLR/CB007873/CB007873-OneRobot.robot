*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO     SBTS00    SBTS23R1    CONFIGURED    5G_RAN    RAN_5G    CRT
...           	SANSA_FS_ECPRI_CMWV_FDD+TDD   PY39

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
...    Only if the feature CB007873 is activated and CA association between FDD cell and Scell are configured, UE can be configured with
...    carrier aggregation. Otherwise, UE cannot be configured with carrier aggregation.
...
...     TEST SET NAME:  CB007873-D
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : The aim of this test is to check that after succesfull call setup with FDD  FR1-TDD Carrier aggregation for
...     the single UE ( with dynamic flow control, data split over PCell and SCell, with Buffer based SCell
...     activation of the FR1-TDD SCell ) DL data of the nonGBR bearer  will be only scheduled on FDD Pcell & FR1
...     TDD SCell.While UL Data will be scheduled only on Pcell.
...

Library        taf.transport.ssh           WITH NAME    taf_ssh
Library        taf.wts.runner              WITH NAME    wtsrunner
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       resources/CB007873_Keywords_D.robot
Resource       resources/CB007873_E_Keywords.robot
#Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
Library         taf.sbts.oam.coam.admin     WITH NAME   ute_adm
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
Resource        ../resources/robot/common_log_collection.robot
Library         ./resources/Lib/scell_csv_analyser.py
Library          ute_fsmaccess
#Library          ta5g_commissioning
Library         ta5g_egate
Library         ta5g_enb
Library         ta5g_iphy
Library         ta5g_pm_counters
Library         ta5g_ue_mobility
Library         ta_egate_cmd_parser
#Library         ute_tshark
Library         taf.collectors.tshark
Library         ta5g_testline_management


# Bring up the testline with basic configuration
Suite Setup         Run keywords     Suite setup from scratch

Suite Teardown      Run Keywords     Revert GNB RadParam
...                 AND     Revert AP RadParam
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

*** Variables ***
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${AP_FCT_BOARD_TYPE}           ${EMPTY}
${AP_ASP_BOARD_TYPE}           ${EMPTY}
${gnb_swconfig}    ${CURDIR}/config/gnb_swconfig_scell.txt
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
${wts_cfg_file_E}     ${CURDIR}/config/CB007873_E_basic.cfg
${UE_NONCA_FDD}     14
${UE_NONCA_TDD}     13
${UE1_CA_FDD}       11
${UE2_CA_FDD}       12
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}      1
${a3meas_id}   1
${a1meas_id}   2
${epc_log_path}    /tmp/
${Lock}         Bearer-type change from SCG-split to MCG
${UnLock}       MasterInformationBlock-NR Updated
${Scell_addition}       SCellIndex 9
${Timeout}       60
*** Test Cases ***

#
#[1][1.0] CB007873_E_B5_11_Cell_Lock_of_TDD_Cell_without_Graceful_Cell_Shutdown_with_Scell_Blind_based_Addition_Buffer_Based_Activation_Mixed_Mode
#    [Documentation]  Verifying TDD Unlock during buffer based Scell Activation
#    [Tags]
#    [Setup]      Testcase Setup 7873_E
#    ${TEST_NAME}    Set Variable   7873_E
#    set suite variable     ${TEST_NAME}
#    ${LOG_PATH1}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${LOG_PATH1}
#    X2AP Link Should be UP
#    Link SCOUT SCF to Configuration ID for Reporting
#    Perform SCF Delta Commissioning with ScellActivation_bufferBased.json
#    Attach CA FDD and check Scell Addition for bufferbased Scell Activation    ${UE1_CA_FDD}
#    Attach NONCA FDD    ${UE_NONCA_FDD}
#    Attach NONCA TDD    ${UE_NONCA_TDD}
#    Verify Counters CB007873
#    Perform SCF Delta Commissioning with delta_TDD_lock.json
#    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Lock}    ${Timeout}
#    Verify Counters CB007873
#    sleep    5s
#    UE Detach should be Successful      ${UE1_CA_FDD}
#    sleep    3s
#    UE Detach should be Successful      ${UE_NONCA_FDD}
#    sleep    3s
#    UE Detach should be Successful      ${UE_NONCA_TDD}
#    Perform SCF Delta Commissioning with delta_TDD_Unlock.json
#    [Teardown]    Run Keywords   Perform SCF Delta Commissioning with delta_to_set_to_default.json

[1][2.0] CB007873_D_B2_9_Single_UE_Call_with_dynamic_data_split_over_PSCell_and_Scell_Buffer_based_Scell_Activation_Deactivation_UL_DL_in_NSA_mode
     Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    [Setup]      Testcase Setup 7873_D
    ${TEST_NAME}    Set Variable   7873_D
    set suite variable     ${TEST_NAME}
    ${LOG_PATH2}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH2}
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
#Attach/Detach NSA FDD CA Capable UE and send max data around 400Mbps
    Attach one FDD CA capable UE and 10 Non CA FDD UEs
    Sleep    300s
#Check 7873-D counters validation for non xero
    Run Keyword And Ignore Error    CB007873 Counters validation
#Wait for 5 mins to get counters update
    Sleep  300s
# Check again counters whether its been increasing
    Run Keyword And Ignore Error    CB007873 Counters validation Bigger than previous GP
#Activate the Bler profile set
    Run Keyword And Ignore Error    Activate Bler profile
#Wait for 2 PM interval to get counters update
    Sleep  600s
# Check agaiin counters whether its been increasing or decreasing
    Run Keyword And Ignore Error    CB007873 Counters validation for PCell counter decrement
#Wait for 5 mins to get counters update
#    Sleep  300s
# Check agaiin counters whether its been increasing or decreasing
#    Run Keyword And Ignore Error    CB007873 Counters validation for Scell
#collect the snasphot for validation of 1ms
    setup.Get Snapshot
#Download the luashark files
    #Get Luashark File
#L2Traces validation for Bler pcell validation
  #  L2HiTraces
#stop capturing CPRT
    CB007873_Keywords_D.Stop Capture CPRT
#stop capturing syslogs
    Stop Collecting Syslog    NAME=syslog_scell

***keywords****

Testcase Setup 7873_E
    Perform SCF Delta Commissioning with ScellActivation_blind.json
    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file_E}


Testcase Setup 7873_D
    add routes
    Add GNB RadParam for PDU_Enabled and SchedDelay_Enabled
    Add AP RadParam
    Reboot gNB System Module from Console and check Airscale is ready
    Start Default Logging    output_dirpath=${LOG_PATH}
#   Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#   Sleep    5min
    Perform SCF Delta Commissioning with PDUenbaled_SchedEnabled_Bufferbased_Scell_26r3.json
    Sleep    2min
    Start WTS Using WTS_Runner      ${wts_cfg_file}
