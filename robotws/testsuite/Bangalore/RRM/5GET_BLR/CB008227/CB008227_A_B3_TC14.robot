*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of Non GBR bearer with configured 
...                               DL/UL Nominal Bit Rate in DRB profile which is triggered by SgNB addition procedure with RAN Sharing
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_FR1_TDD_60mhz_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_AEHC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      ${1}
${nsa_ue_id}      ${11}
${nsa_ue_id1}      ${11}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC14
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${no_of_cells}    2

*** Test Cases ***

CB008227-A#B3_TC14 Support Nominal Bit Rate of nonGBR bearers setup with SgNB addition (NSA) both UL/DL- RAN sharing
    [Documentation]   This user scenario describes the gNB behaviour for the successful setup of Non GBR bearer with configured 
    ...               DL/UL Nominal Bit Rate in DRB profile which is triggered by SgNB addition procedure with RAN Sharing
    Verify actNbrForNonGbrBearers In CellSetupReq
    log to console   Trigerring NSA UE attach now...
    Start Log    btslog   cprt   bip
    X2AP Link Should be UP
    Multiple NSA UE Register   ${nsa_ue_id}    ${nsa_ue_id1}
    sleep     5s
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In BearerSetupReq   ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    1   1
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=50
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=30
    sleep     15s    
    Multiple NSA UE Detach   ${nsa_ue_id}  ${nsa_ue_id1}
    Stop Log   btslog   bip
