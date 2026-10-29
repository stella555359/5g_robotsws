*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008509_Resource.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Suite Setup         Run keywords     Suite setup from scratch
#...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Enable CPRT Debug Log
...                 AND     Perform SCF Delta Commissioning with D_TC3.json
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     Start Log    btslog

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...             author:            Vaibhav 3. Tyagi (Nokia) <vaibhav.3.tyagi@nokia.com>
...             maintainer:        Vaibhav 3. Tyagi (Nokia) <vaibhav.3.tyagi@nokia.com>
...
...             INTRODUCTION:     This scnrio covers verifn of legacy and newcounters generation of Dummy ld on PDSCH,
...                               PDCCH and SSB symbols in a cell when PRB pooling, PRB Blanking is activated and Beam
...                               forming is Deactivated.
...                               M55308C10001(PRB_USED_PDSCH)
...                               M55338C00001(PRB_USED_PDSCH_PLMN)
...                               M55308C00017(DATA_SLOT_PDSCH)
...                               M55308C00015(SSB_SLOT_PDSCH)
...                               M55308C00017(TRS_SLOT_PDSCH)
...                               M55138C00008(AVE_NUMBER_OF_SA_RRC)
...                               M55308C00001(DL_DATA_SLOTS)
...                               M55114C00008(AVE_NUMBER_OF_NSA_USERS)
...                               M55308C00043(DL_SLOTS_BELOW_TGT_LOAD)
...                               M55308C00044(DL_SLOTS_ARTIFICIAL_LOAD)
...                               M55308C00045(DL_PRB_ARTIFICIAL_LOAD)
...                               M55308C00046(TRS_SLOTS)
...                               M55308C00003(SSB_SLOTS)
...             TEST SET NAME:    CB008509-D_TC3_Verify_Legacy_Counters_with_Dummy_load_on_PDSCH_PDCCH_SSB_TRS_with
...                               _PRB_pooling_TDD_without_BeamForming
...             TESTING SPLIT:    See CB009425 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009425 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_17671

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_max_gfbr_30_tdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${2}
${TEST_NAME}     TC3
${PRB_USED_PDSCH}              M55308C10001
${DL_DATA_SLOTS}               M55308C00001
${SS_BURST_SLOTS}              M55308C00003
${DATA_SLOT_PDSCH}             M55308C00005
${SSB_SLOT_PDSCH}              M55308C00015
${TRS_SLOT_PDSCH}              M55308C00017
${DL_SLOTS_BELOW_TGT_LOAD}     M55308C00043
${DL_SLOTS_ARTIFICIAL_LOAD}    M55308C00044
${DL_PRB_ARTIFICIAL_LOAD}      M55308C00045
${TRS_SLOTS}                   M55308C00046
${AVE_NUMBER_OF_SA_RRC}        M55138C00008
${AVE_NUMBER_OF_NSA_USERS}     M55114C00008
${MAX_LOAD_PERCENT}    ${25}
${CellBW}              ${273}



*** Test Cases ***
[1]CB008509-D_TC3_Verify_Legacy_Counters_with_Dummy_load_on_PDSCH_PDCCH_SSB_TRS_with_PRB_pooling_TDD_without_BeamForming

    ${pdschheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_PdschGrant.numOfPrb    DlData_PdschGrant.rat0Bitmap    DlData_PdschGrant.mcs
    ...    DlData_PdschGrant.mcsTable    DlData_PdschGrant.patternId_item

    ${pdcchheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_DciInfo.startSymbolNumber    DlData_DciInfo.numOfSymbols    DlData_DciInfo.startCce
    ...    DlData_DciInfo.aggregationLevel    DlData_DciInfo.coresetFreqDomain    DlData_DciInfo.interleaverRows
    ...    DlData_DciInfo.regBundleSize    DlData_DciInfo.coresetFreqDomainRbShift    DlData_DciInfo.patternId_item

    ${actualtargetload}    Evaluate    (${CellBW}*${MAX_LOAD_PERCENT})/${100}
    ${targetloadpdsch}    Calculate Target Load Sector Beam    ${CellBW}    ${1}    ${MAX_LOAD_PERCENT}
    ...    nbrOfBlankedPRBsHighEdgeDL=${0}    nbrOfBlankedPRBsLowEdgeDL=${0}
    log to console    targetloadpdsch-${targetloadpdsch}

    ${pdcchtargetload}    Calculate Target Load Sector Beam PDCCH    ${CellBW}    ${MAX_LOAD_PERCENT}
    log to console    targetloadpdsch-${pdcchtargetload}

    ${targetload}    get_max_prb     ${targetloadpdsch}     ${pdcchtargetload}
    log to console    targetload-${targetload}

    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log    biptaf
    sleep    1s
    ${scen1}     Stop Log     biptaf     test_scenario=cell_idle
    ${CsvPathpdsch1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdschsendreql1sw    dldata_pdschsendreql1sw
    ...    @{pdschheader}
    ${CsvPathpdcch1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdcchsendreql1sw    dldata_pdcchsendreql1sw
    ...    @{pdcchheader}
    sleep    120s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New

    Get counters and validate     ${PRB_USED_PDSCH}     ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}     ${DATA_SLOT_PDSCH}
    ...    	${SSB_SLOT_PDSCH}    ${TRS_SLOT_PDSCH}     ${DL_SLOTS_BELOW_TGT_LOAD}	${DL_SLOTS_ARTIFICIAL_LOAD}
    ...     ${DL_PRB_ARTIFICIAL_LOAD}     ${TRS_SLOTS}    ${AVE_NUMBER_OF_SA_RRC}     ${AVE_NUMBER_OF_NSA_USERS}
    ...     1    2    1    ${actualtargetload}    ${targetload}

#Step-2: attach 2 UEs, UE-1 and UE-2
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_1}=      MultiUE Register should be Successful    1   2    pdu_id=1     nw_id=1

#Step-3: start data transfer from UE-1 so that no of PRBs used by UE-1(e.g. Y-PRBS) is less than PRB defined by
#        targetTotalLoadSectorBeam (X-PRBs)

    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=mbps     dl_rate=80     pdu_id=1    trf_id=1      qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=mbps     ul_rate=40     pdu_id=1    trf_id=1      qfi_id=1
    X2AP Link Should be UP
    MultiUE Attach for NSA    101    101
    MultiUE DL Traffic Start for NSA    101    101    mbps    80     id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    101    101    mbps    20     id=2    trf_id=1
    sleep    120s
    Start Log    biptaf
    sleep    1s
    ${scen2}     Stop Log     biptaf    test_scenario=with_3_real_ue
    ${CsvPathpdsch2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw
    ...    @{pdschheader}
    ${CsvPathpdcch2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdcchsendreql1sw    dldata_pdcchsendreql1sw
    ...    @{pdcchheader}
    sleep    600s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get counters and validate     ${PRB_USED_PDSCH}     ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}
    ...    	${DATA_SLOT_PDSCH}     ${SSB_SLOT_PDSCH}    ${TRS_SLOT_PDSCH}     ${DL_SLOTS_BELOW_TGT_LOAD}
    ...     ${DL_SLOTS_ARTIFICIAL_LOAD}     ${DL_PRB_ARTIFICIAL_LOAD}     ${TRS_SLOTS}    ${AVE_NUMBER_OF_SA_RRC}
    ...     ${AVE_NUMBER_OF_NSA_USERS}     2    ${2}    ${1}    ${actualtargetload}    ${targetload}

    Stop MultiUE Data Traffic for SA     1  2
    MultiUE Detach for NSA    101    101
    MultiUE Deregister should be Successful   1  2
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


