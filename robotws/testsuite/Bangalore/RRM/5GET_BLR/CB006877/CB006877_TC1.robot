*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     CRT    5G_RAN     SBTS00 

Documentation   :copyright: Nokia
...             :authors: Manasa
...             :contact: manasa.shankarappa@nokia.com
...             INTRODUCTION:     This user scenario describes the Feature activation of actDynUlResAlloc on FDD Cells 
...             TEST SET NAME:    CB006877
...             TESTING SPLIT:    Refer CB006877 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB006877 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_23346



Resource     CB006877_Resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep    60s
...                 AND     Start Log   btslog

Suite Teardown    Run Keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...               AND   Stop Log   btslog    snapshot    sosreport


*** Variables ***
${wts_cfg_file}     basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/

${sa_ue_id1}      51
${en_ue_id1}      60
${sa_ue_id2}      71
${en_ue_id2}      80
${sa_trf_id}    1
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1

${delta_file_name}   TC1_CB006877_Enable.json

*** Test Cases ***
[1]USCB006877-A#1_TC1_Feature_Activation_CB006877_FDD_Cells
    [Tags]      QC_xxxxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}    
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation
    Verify Dynamic PUSCH in CellSetup    ${path1}[cprt]/NODECPRT_GNB.pcap   sctp 

*** Keywords ***
