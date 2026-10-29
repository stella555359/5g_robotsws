*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD     5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./CB008509_Resource.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Enable CPRT Debug Log
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_FDD_NBF_7.json
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   360s    reason=wait for RMOD- to comeup
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}


Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...             author:            Navin Kumar Ray, navin.kumar_ray@nokia
...             maintainer:        Navin Kumar Ray, navin.kumar_ray@nokia
...
...             INTRODUCTION:     This scenario covers counter verification of Artificial Load on PDSCH symbols in a
...                               cell when PRB pooling is deactivated, beam forming is disabled and 5GC002558 is enabled

...             TEST SET NAME:    CB008509-A_TC7_covers counter verification of Artificial Load on PDSCH symbols in a
...                               cell when PRB pooling is deactivated, beam forming is disabled and 5GC002558 is enabled
...             TESTING SPLIT:    See CB008509 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB8509 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_19130,CB_FIM_35029

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${TEST_NAME}     TC7
${DL_SLOTS_BELOW_TGT_LOAD}    M55308C00043
${DL_SLOTS_ARTIFICIAL_LOAD}    M55308C00044
${DL_PRB_ARTIFICIAL_LOAD}    M55308C00045
${TRS_SLOTS}    M55308C00046
${SS_BURST_SLOTS}    M55308C00003
${DL_DATA_SLOTS}     M55308C00001
${PRB_USED_PDSCH}     M55308C10001
${MAX_LOAD_PERCENT}    50

*** Test Cases ***
[1][1.0] CB008509-A_TC7_Counter_Validation_Generating_Dummy_load_on_PDSCH_without_PRB_pooling_FDD_non_BF_5GC002558
    ${header}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti    DlData_PdschGrant.numOfPrb
    ...           DlData_PdschGrant.rat0Bitmap   DlData_PdschGrant.mcs    DlData_PdschGrant.mcsTable

    ${targetload}    Calculate Target Load Sector Beam    ${106}    ${1}    ${50}    nbrOfBlankedPRBsHighEdgeDL=${4}
    ...    nbrOfBlankedPRBsLowEdgeDL=${4}
    log to console    targetload-${targetload}
    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log    biptaf
    sleep    1s
    ${scen1}     Stop Log     biptaf    test_scenario=cell_idle
    ${CsvPath1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}
    sleep    300s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    1    ${targetload}
#Step-2: attach 1 UE, UE-1
    ${crnti_list_1}=      MultiUE Register should be Successful    1   1    pdu_id=1     nw_id=1

#Step-3: start data transfer from UE-1 so that no of PRBs used by UE-1(e.g. Y-PRBS) is less than PRB defined by
#        targetTotalLoadSectorBeam (X-PRBs)
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=2     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=2     pdu_id=1    trf_id=1       qfi_id=1
    sleep    120s
    Start Log    biptaf
    sleep    1s
    ${scen2}     Stop Log     biptaf    test_scenario=with_1_real_ue
    ${CsvPath2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}

    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    2    ${targetload}

    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=150     pdu_id=1    trf_id=2       qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=150     pdu_id=1    trf_id=1       qfi_id=1

    Start Log    biptaf
    sleep    1s
    ${scen3}     Stop Log     biptaf    test_scenario=with_1_real_ue
    ${CsvPath3}     Convert PCAP to CSV    ${scen3}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}
    sleep    800s
    Wait until the current Measurement Period stops  additional_time=${1200}
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    3    ${targetload}

    sleep    60s
    Stop MultiUE Data Traffic for SA     1  1
    MultiUE Deregister should be Successful   1  1

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
