*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT    RAN_5G_TDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    CONFIGURED

Resource         ../CB008285/CB008285_Resource.robot
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



Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Madhukara M V
...             maintainer:       madhukara.m_v@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the online enable/disable
...                               of the feature in SA mode
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}   1
${sa_ue_id2}   2
${sa_ue_id3}   3
${nsa_ue_id1} 	101
${nsa_ue_id2} 	102
${nsa_ue_id3} 	103
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC16

${SCFC}=                        ${CURDIR}/config/scfc.xml
${AP_XML}=                      ${CURDIR}/config/iphy.xml
${Delta_scf_feature_enable}     Delta_CB008227_act.json
${Delta_scf_feature_disable}    Delta_CB008227_deact.json
${delta_set_nbr_ul_dl} =        nbrul_dl_TC16.json

*** Test Cases ***
[1]CB008227-A#B5_TC16_Online_modification_Nominal_Bit_Rate_parameters_SA_Downlink_only
    [Tags]     QC_xxxx
    set test variable      ${LOG_PATH}
    log to console   "SA UE Registerrr"
#Step 1. SA ue and NSA Ue attach/regiester with NBR disabled and verify traffic
    Link SCOUT SCF to Configuration ID for Reporting
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    sleep     10s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=30   pdu_id=1   qfi_id=1
    X2AP Link Should be UP
    sleep     5s
    Multiple NSA UE Register   ${nsa_ue_id1}    ${nsa_ue_id1}
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=30
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=20
#Step 2. Enable NBR and register ue id 2 and verify traafic.
    Perform SCF Delta Commissioning with ${Delta_scf_feature_enable}
    Perform SCF Delta Commissioning with ${delta_set_nbr_ul_dl}
    sleep    5s
    Start Log    cprt
    UE Register with ICS+PDU should be Successful   ${sa_ue_id2}
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    2000   2000
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id2}   dl_rate=30   pdu_id=1   qfi_id=1
    Start Log    cprt
    Multiple NSA UE Register   ${nsa_ue_id2}    ${nsa_ue_id2}
    sleep     5s
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    2000    2000
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id2}  ${nsa_ue_id2}   dl_rate=30
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id2}  ${nsa_ue_id2}   dl_rate=20
    Validate DL Traffic For NSA     ${nsa_ue_id1}     30
    Validate UL Traffic For NSA     ${nsa_ue_id1}     20
#Step 3. Disable NBR and register ue id 3 and verify traffic
    Perform SCF Delta Commissioning with ${Delta_scf_feature_disable}
    UE Register with ICS+PDU should be Successful   ${sa_ue_id3}
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id3}  ${sa_ue_id3}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    sleep    5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id3}   dl_rate=30   pdu_id=1   qfi_id=1
    Multiple NSA UE Register   ${nsa_ue_id3}    ${nsa_ue_id3}
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id3}  ${nsa_ue_id3}   dl_rate=30
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id3}  ${nsa_ue_id3}   dl_rate=20
    Validate DL Traffic For NSA     ${nsa_ue_id1}     30
    Validate UL Traffic For NSA     ${nsa_ue_id1}     20
    Validate DL Traffic For NSA     ${nsa_ue_id2}     30
    Validate UL Traffic For NSA     ${nsa_ue_id2}     20
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id3}
# Check NBR deactivated successfully for ue id 3 and ue id 2 not affected   need to write the keyword
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id3}
    Multiple NSA UE Detach   ${nsa_ue_id1}  ${nsa_ue_id3}
    Stop Log   btslog   snapshot






