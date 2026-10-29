*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED


Documentation    :copyright: Nokia
...              :author: Ashutosh Jaiswal
...              :contact: ashutohsh.k.jaiswal@nokia.com
...
...             INTRODUCTION:     This user scenario describes UL power limited UEs will not be able to meet their NBR but they
...                               will achieve greater than or equal to the UL throughput that they had achieved prior to NBR being enabled
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20632



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
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_AEHC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${delta_commissioning_on_json}    Delta_CB008227_act.json
${delta_commissioning_off_json}    Delta_CB008227_deact.json
${no_of_cells}    2

*** Test Cases ***

CB008227-B#B1_TC19_UL_power_with_limited_UE_will_not_be_able_to_meet_their_NBR both UL_DL
    [Documentation]  This user scenario describes UL power limited UEs will not be able to meet their NBR but they
    ...              will achieve greater than or equal to the UL throughput that they had achieved prior to NBR being enabled
    Perform SCF Delta Commissioning with ${delta_commissioning_off_json}
    sleep   5s
    Start Log    btslog     bip
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful      ${sa_ue_id2}
    UE Register should be Successful Vonr          ${sa_ue_id3}
    Set Power Class For UE 1
    Set Power Class For UE 2
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    Trigger DL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    Trigger UL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   ul_rate=20   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   ul_rate=20   pdu_id=1   qfi_id=1
    Deregister UEs
    Stop Log   btslog   bip
    Perform SCF Delta Commissioning with ${delta_commissioning_on_json}
    log to console   UE attach trigerring now...
    Start Log    btslog    bip
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful      ${sa_ue_id2}
    UE Register should be Successful Vonr          ${sa_ue_id3}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=20        pdu_id=1     trf_id=1     qfi_id=1
    Trigger DL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    Trigger UL Traffic for SA Vonr    ${sa_ue_id3}   1    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   ul_rate=20   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   ul_rate=20   pdu_id=1   qfi_id=1
    Deregister UEs
    Stop Log   btslog   bip
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


***keywords****
Deregister UEs
    Stop Data Traffic for SA     ue_id=${sa_ue_id1}
    Stop Data Traffic for SA     ue_id=${sa_ue_id2}
    Stop Data Traffic for SA     ue_id=${sa_ue_id3}
    UE Deregister should be Successful   ue_id=${sa_ue_id1}
    UE Deregister should be Successful   ue_id=${sa_ue_id2}
    UE Deregister should be Successful   ue_id=${sa_ue_id3}

Set Power Class For UE 1
    wtsrunner.phr_override_testmode_nr    profile_id=1     pc_max=23
    sleep     2s
    wtsrunner.ue_testmode_set_nr    id=1    testmode=phr_override    action=activate    profile_id=1
    sleep     2s

Set Power Class For UE 2

     wtsrunner.phr_override_testmode_nr    profile_id=1    pc_max=23
    sleep     2s
     wtsrunner.ue_testmode_set_nr    id=2    testmode=phr_override    action=activate    profile_id=1
    sleep     2s


