*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 navin.kumar_ray@nokia.com
...             maintainer:             navin.kumar_ray@nokia.com
...
...             INTRODUCTION:      CB008927_A_B101_1
...             TEST SET NAME:     CB008927_A_B101_1_FeatAct-Deact_FDD-20MHZ-LO-AP-LO.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID:        5G_RAN_USR_RRM_22990

Resource         ./CB008927_resource.robot

Suite Setup         Run keywords            Log To console  Suitesetup
...                 AND      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta-FDD-35MHZ-LO-AP-LO_3rd4thCell_A-B1.json
...                 AND     sleep    75s
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
...                 ${wts_cfg_file}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_LO_LO_TDD_FDD.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1.
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq
...                            || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus
...                            DlData_PdschGrant.startPrb      DlData_PdschGrant.numOfPrb    nr-rrc.c1
...                            DlData_PdschGrant.rachStatus      uci.an

*** Test Cases ***
[1]CB008927_A_B101_1 Feature Activation and Deactivation for RAT1 resource allocation on FR1 FDD
#rat1 activation
# cell 3
    Modify NIDD parameters      actRat1Alloc      false        update      MRBTS-1/NRBTS-1/NRCELL-3
    sleep    70s
    start log     cprt
    Modify NIDD parameters      actRat1Alloc      true        update      MRBTS-1/NRBTS-1/NRCELL-3
    sleep    70s
    ${path_CPRT_1}    Stop log      cprt    test_scenario=CPRT1
    set suite variable    ${path_CPRT_1}
    Verify rat1_active     ${path_CPRT_1}[cprt]     itf_l2_ps_cell_cellsetupreq
    ...     actRat1Alloc


#rat1 deactivation#
# cell 1
    start log     cprt
    Modify NIDD parameters      actRat1Alloc      false        update      MRBTS-1/NRBTS-1/NRCELL-3
    ${path_CPRT_3}    Stop log      cprt    test_scenario=CPRT3
    set suite variable    ${path_CPRT_3}
#verify parameter de-activation for cell1
    Verify rat1_inactive     ${path_CPRT_3}[cprt]     itf_l2_ps_cell_cellsetupreq
    ...     actRat1Alloc





