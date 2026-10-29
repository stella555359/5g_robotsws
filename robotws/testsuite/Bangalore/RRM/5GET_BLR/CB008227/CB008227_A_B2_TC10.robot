*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO     
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   60s

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of 
...                               Non GBR QoS Flow with configured DL Nominal Bit Rate in DRB profile which 
...                               is triggered by Initial Context Setup Request procedure.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/A_B2_TC10_basic_setup.cfg
${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${51}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Pdu_session_ID2}      2
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1
${CELL_ID}    3

${delta_file_name}    Enable_NBR_A_B2_TC10.json

*** Test Cases ***
CB008227-A#B2_TC10 Support Nominal Bit Rate of nonGBR bearers setup with 2nd PDU Session Setup (SA) FDD Downlink only
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    log to console   "UE attach trigerring now"
#Step 1. Attach SA UE-1 with ICS during ue register on cell-1 and Start Data Traffic
    Start Log    cprt
    UE Register with ICS should be Successful   ${sa_ue_id1}
    sleep    1s
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30    
    sleep   5s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_NBR_disable
    Verify Any Counters In File
    ...  M55139C03509  0  SA_DU_DRB_NBR_DL
    ...  M55139C03510  0  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    
#Perform delta commissioning with 8227 enable    
    Perform SCF Delta Commissioning with ${delta_file_name}
#Step 1. Attach SA UE-1 with ICS during ue register on cell-1 and Start Data Traffic
    Sleep   60s
    Wait until the next Measurement Period starts
    Start Log    cprt
    UE Register with ICS should be Successful   ${sa_ue_id1}
    sleep    1s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup_NBR_enable
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path2}[cprt]/NODECPRT_GNB.pcap    sctp    1   1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30
    sleep    5s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_NBR_enable
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  M55139C03510  300  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
#Step 1. Add second PDU session and verify NBR foor it
    Start Log    cprt
    sleep   1s
    UE PDU Addition should be Successful   ${sa_ue_id1}   ${Pdu_session_ID2}   1    1
    sleep  1s
    ${path3}    Stop Log    cprt   test_scenario=bearersetup_NBR_Enable_2nd_PDU
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path3}[cprt]/NODECPRT_GNB.pcap    sctp    1   1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   mbps   30   ${Pdu_session_ID2}   1     1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   mbps   30   ${Pdu_session_ID2}   1     1
    sleep   5s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   30   ${Pdu_session_ID2}   1
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   30   ${Pdu_session_ID2}   1
    Wait until the next Measurement Period starts
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_NBR_enable_2PDU_session
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  M55139C03510  600  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}



