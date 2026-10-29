*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the  verification of Interface message with feature flag during
...                               1. cell setup, 2.Bearer setup,parameter range and PDL rule validations
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
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_fullcommissioning_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
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
${epc_log_path}    /tmp/
${TEST_NAME}        A_B1_TC2_3_4
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${delta_commissioning_on_json}    Delta_CB008227_act.json
${delta_commissioning_off_json}    Delta_CB008227_deact.json
${no_of_cells}   2

*** Test Cases ***

CB008227-A#B1_TC2_Feature_flag_activation_Interface_message_verification
    [Documentation]   This user scenario describes the  verification of Interface message with feature flag during
    ...               1. cell setup, 2.Bearer setup,parameter range and PDL rule validations
#Step 1. Verifying feature activation in usersetup message with Full recommissioning
    log to console   TC2 Verifying feature activation in Full recommissioning
    Verify actNbrForNonGbrBearers In CellSetupReq
#Step 2. SA ue attach with NBR enabled
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt   bip
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
#Step 3. Verifying NBR parameters in bearersetup message
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    Stop Log   btslog   bip
#Step 4. Deactivating feature with delta commissioning
    log to console   TC3_4 Verifying feature activation : Online modification SA + NSA
    Perform SCF Delta Commissioning with ${delta_commissioning_off_json}
    sleep   5s
    Start Log    btslog   cprt
#Step 5. Activating feature with delta commissioning
    Perform SCF Delta Commissioning with ${delta_commissioning_on_json}
    sleep   5s
#Step 6. SA ue attach with NBR enabled
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    sleep   5s
    X2AP Link Should be UP
    Multiple NSA UE Register   ${nsa_ue_id}    ${nsa_ue_id1}
    sleep     5s
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
#Step 7. Verifying feature activation in usersetup & bearersetup message with online  modification
    Verify actNbrForNonGbrBearers In CellReconfigurationReq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp
    Verify nbrDrbSpecificParams In bearersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    9955   9955
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=50
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id}  ${nsa_ue_id1}   dl_rate=30
    sleep     5s
    Multiple NSA UE Detach   ${nsa_ue_id}  ${nsa_ue_id1}
    Stop Log   btslog
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
