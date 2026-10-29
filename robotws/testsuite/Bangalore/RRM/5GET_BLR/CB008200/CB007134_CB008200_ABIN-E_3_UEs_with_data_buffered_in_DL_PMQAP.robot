*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008200_Resource.robot
Resource         ./resources/common/common_setup_teardown.robot
Library          ./resources/python/PM_Counter_Verify.py
Resource           ../resources/robot/common_log_collection.robot

Suite Setup           Run keywords    Prepare TL with all config files
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_VONR_MultiUE.json
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:           Santhosh G N, g.n_santhosh@nokia.com
...             maintainer:       Santhosh G N, g.n_santhosh@nokia.com
...
...             INTRODUCTION:      Feature provides counters for measuring VoNR statistics for clear understanding of the performance of Voice over
...              NR calls in the network.The feature provides counters related to Retainability, Accessibility , Utilzation and VoNR Quality
...             The feature also provides some counters at PMQAP level.
...             TEST SET NAME:    CB008200-E_3_UEs_with_data_buffered_in_DL_PMQAP.
...                                The purpose of this test is to verify the PM Counter ACC_UE_DL_DRB_DATA_PMQAP to count the number of UEs in the DL
...                                that have buffered data to be created as a PMQAP profile counter.
...                                The profile counter shall count only for the configured Profile parameters.

...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:      5G_PM_462

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_tdd_multi_ue_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CB008200/config/SCF/TDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CB008200/config/SCF/TDD_2cell_iphy.xml

*** Test Cases ***
[1]CB008200-E_3_UEs_with_data_buffered_in_DL_PMQAP
    [Tags]     QC_201855     QC_194791    QCD_MN_RAN    QCP_RAN_ET
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}


#Step 1. Attach 10 VONR UEs, with PDU session 5QI-6 nonGBR qosflow which is default
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1

#Step 2. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=2   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=2    trf_id=1       qfi_id=2

#Step 3. Establish pdu_id=2 for 5QI-1 VoNR Call
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=2      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=2     num_trf_id=20    qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=2     num_trf_id=20    qfi_id=3    rtp_codec=custom
    sleep       300s
    Wait until the current Measurement Period stops  additional_time=${0}
    CB008200_Resource.Collect PM Counters
    Get buffer counters and validate  M55356C00000  M55356C00001  M55356C00002    M55356C00003    M55308C01000    M55308C01001
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}


*** Keywords ***
Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3


