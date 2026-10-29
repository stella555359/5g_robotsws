*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start Default Logging Gnb ASIL_ABIO     
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s    

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers 
...                               congestion detection and congestion handling with both
...                               "PDSCH & PUSCH congeztion control" and congWeightAlg set to "prioritylevel"
...                                   
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20653



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC32_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${51}
${sa_ue_id2}      ${52}
${sa_ue_id3}      ${53}
${sa_ue_id4}      ${54}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${QFI_ID3}     4

${TEST_NAME}     TC36
${CELL_ID}    3

${delta_file_name}=             Enable_NBR_Congestion_TC36.json
#${SCFC}=                        ${CURDIR}/config/TC45_SCFC.xml
#${AP_XML}=                      ${CURDIR}/config/TC45_IPHY.xml



*** Test Cases ***
[1]CB008227-D#B1_TC36_NBR_congestion_detection_and_handling_with_pdsch_congestion_control_and_congWeightAlg_prioritylevel
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP 
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID1}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID2}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID3}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    sleep   10s
    Validate DL Traffic For UEs diff QFI   28   104   50   35
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=60   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=60   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=40   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=40   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    sleep   10s
    Validate UL Traffic For UEs diff QFI   60   40
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing    
    Verify Any Counters In File
    ...  M55139C03509  900  SA_DU_DRB_NBR_DL
    ...  M55300C12010  600  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  900  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}    
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Validate DL Traffic For UEs diff QFI
    [Arguments]    ${de_qfi}   ${qfi1}   ${qfi2}   ${qfi3}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${de_qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID1}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${qfi2}   pdu_id=1    qfi_id=${QFI_ID2}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${qfi3}   pdu_id=1    qfi_id=${QFI_ID3}

Validate UL Traffic For UEs diff QFI
    [Arguments]    ${qfi}   ${qfi1}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${qfi}   pdu_id=1    qfi_id=${QFI_ID1}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID2}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID3}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END


