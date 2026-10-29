*** Settings ***
Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008509_Resource.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Library             OperatingSystem
Library             ./python/CB008509_Verification.py
Resource            ../resources/robot/BBpooling_MuMIMO.robot


Suite Setup         Run keywords  Test Suite Setup
#...                 AND           download_mcshark        ${mcshark_d}    ${filename}
...                 AND           AIC Software Build Info
...                 AND           Fetch Taf Library used in TL
...                 AND           Modify Inputrc file VDU
...                 AND           Log to console    vDU delta commissioning
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                 AND           sleep    300s
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           sleep    600s
...                 AND           Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND           log to console   loading cfg file....
...                 AND           Configure UTE ETH3 IPs
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep   120s

Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner


Documentation
...
...             author:            Navin Kumar Ray (Nokia) <navin.kumar_ray@nokia.com>
...             maintainer:        Navin Kumar Ray (Nokia) <navin.kumar_ray@nokia.com>
...
...             INTRODUCTION:     This user scenario describes L2-PS behaviour in generating Dummy load for PDSCH & PDCCH
...                               on DL slots when actConfDlInterferenceGen is set to PDSCH+PDCCH
...             In this test case we check for three scenarios: a)No Ue attached b)1 UE attached with UL DL Throughput
...             c)7 UEs attached with UL DL Throughput.
...             The feature allows to generate artificial load in the cell in downlink direction for both PDCCH & PDSCH.
...             The operator can configure Cell_data_threshold [%] which would reserve some number of PRBs in the cell to
...             provide dummy traffic up to configured level.
...             Feature will not interfere with the ongoing traffic in a cell where the feature is activated.
...             If the cell already generates load (to the regular UEs in the cell), which is equal or above
...             the configurable threshold, artificial load will not be added.
...             There is no Competition between Real UEs and Fake UEs. (Real UE has the priority,
...             dummy data would be fill in up to the remaining PRBs, if any, up to the threshold.
...             TEST SET NAME:    CB008509-B_TC2_Generating Dummy load on PDCCH_without_PRB_pooling_TDD_non_BF
...             TESTING SPLIT:    See CB008509 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008509 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_19132

*** Variables ***
${delta_vdu}        ${CURDIR}/config/SBTS24R2/8509_TC2_Delta_SCF_vdu.xml
${delta_cu}         ${CURDIR}/config/SBTS24R2/Delta_8509_B_TC2_VCU.xml
#${wts_cfg_file}     ${CURDIR}/config/wts/SANSA_2Cell_72ues.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/CB010412_8509_TC2_TDD_AiC.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${2}
${TEST_NAME}     TC2
${log_path_1}    /home/ute/
${START_UE_SA_cell1}   1
${END_UE_SA_cell1}     8
${Pdu_session_ID}      1
${nwslice_ID}          1
${DL_Rate}             80
${UL_Rate}             10
${start_trf_id}        1
${end_trf_id}          1
${QFI_ID}              1
${Trf_rate_SA}         mbps
${scell_id}            0
${mcshark_s}           /home/shh/rotta4internal/5G_2/bangalore/BLR_ET/8509_mcshark_so_file/
${mcshark_d}           /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/
#${filename}            mcshark-4.0-1.27.0-vDUCNF00_0.300.19231_buster.so
${filename}            mcshark-4.0-1.29.0-vDUCNF00_0.300.22255+bookworm.so


*** Test Cases ***
[1]CB008509-B_TC2_Generating_Dummy_load_on_PDCCH_without_PRB_pooling_TDD_non_BF
    set test variable      ${LOG_PATH}
    ${crnti}     Create list    65535
    ${pdschheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti    DlData_PdschGrant.numOfPrb
    ...    DlData_PdschGrant.rat0Bitmap    DlData_PdschGrant.mcs    DlData_PdschGrant.mcsTable    DlData_PdschGrant.patternId_item

    ${pdcchheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_DciInfo.startSymbolNumber    DlData_DciInfo.numOfSymbols    DlData_DciInfo.startCce
    ...    DlData_DciInfo.aggregationLevel    DlData_DciInfo.coresetFreqDomain    DlData_DciInfo.interleaverRows
    ...    DlData_DciInfo.regBundleSize    DlData_DciInfo.coresetFreqDomainRbShift    DlData_DciInfo.patternId_item

    ${pdccharg}     Create list    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_DciInfo.numOfSymbols    DlData_DciInfo.aggregationLevel

    ${usablepdschonssb}         Set Variable          ${0}

#Step-1: Capture TTI-trace and verify that Artificial Load is getting generated by dummy RNTIs with mcs defined by
#        mcsIndexForArtificialLoad parameter and numofPrb=targetTotalLoadSectorBeam(X-PRBs)

    ${bip_pcap1}     AiC Start & Stop BIP Log    ${5}     test_scenario=cell_idle
    ${CsvPathpdsch1}     Convert PCAP to CSV    ${bip_pcap1}    dldata_pdschsendreq    dldata_pdschsendreq    @{pdschheader}
    ${CsvPathpdcch1}     Convert PCAP to CSV    ${bip_pcap1}    dldata_pdcchsendreq    dldata_pdcchsendreq    @{pdcchheader}
    ${res_pdsch}    validation_of_pdsch    ${CsvPathpdsch1}    dldata_pdschsendreq    0    ${pdschheader}[1:]
    ...    ${crnti}    ${273}    ${1}    ${30}    ${28}    ${0}    ${usablepdschonssb}
    ...    maxpdschinslot=${6}    nbrOfBlankedPRBsHighEdgeDL=${0}    nbrOfBlankedPRBsLowEdgeDL=${0}    beam=${1}
    Should contain    ${res_pdsch}    Pass    ignore_case=True
    ${res_pdcch}    validation_of_pdcch    ${CsvPathpdcch1}   dldata_pdcchsendreq    0    ${crnti}    ${273}    ${30}    ${pdccharg}
    Should contain    ${res_pdcch}    Pass    ignore_case=True

#Step-2: attach 2 UEs, UE-1 and UE-2

    ${crnti_list_1}      MultiUE Register should be Successful    1   8    pdu_id=1     nw_id=1
    ${crnti}    Combine Lists    ${crnti_list_1}    ${crnti}

#Step-3: start data transfer from UE-1 so that no of PRBs used by UE-1(e.g. Y-PRBS) is less than PRB defined by
#        targetTotalLoadSectorBeam (X-PRBs)
    MultiUE Trigger DL Traffic for SA    1  1    Traffic_rate=mbps     dl_rate=50     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1    Traffic_rate=mbps     ul_rate=20     pdu_id=1    trf_id=1       qfi_id=1
    sleep    60s


#Step-4: Capture TTI-trace and verify that Artificial Load and UE-1 data are scheduled in same slot and Artificial Load
#        will use remaining (X-Y) PRBs with mcs defined by mcsIndexForArtificialLoad

    ${bip_pcap2}     AiC Start & Stop BIP Log    ${5}     test_scenario=with_1_real_ue
    ${CsvPathpdsch2}     Convert PCAP to CSV    ${bip_pcap2}   dldata_pdschsendreq    dldata_pdschsendreq    @{pdschheader}
    ${CsvPathpdcch2}     Convert PCAP to CSV    ${bip_pcap2}   dldata_pdcchsendreq    dldata_pdcchsendreq    @{pdcchheader}

    # tti verification code need to be added
    ${res_pdsch}    validation_of_pdsch    ${CsvPathpdsch2}    dldata_pdschsendreq    0    ${pdschheader}[1:]
    ...    ${crnti}    ${273}    ${1}    ${30}    ${28}    ${0}    ${usablepdschonssb}
    ...    maxpdschinslot=${6}    nbrOfBlankedPRBsHighEdgeDL=${0}    nbrOfBlankedPRBsLowEdgeDL=${0}    beam=${1}
    Should contain    ${res_pdsch}    Pass    ignore_case=True
    ${res_pdcch}    validation_of_pdcch    ${CsvPathpdcch2}   dldata_pdcchsendreq    0    ${crnti}    ${273}    ${30}    ${pdccharg}
    Should contain    ${res_pdcch}    Pass    ignore_case=True

#Step-5: start data transfer from UE-2 so that no of PRBs used by UE-2 is greater than or equals to PRB defined by
#        targetTotalLoadSectorBeam
    MultiUE Trigger DL Traffic for SA    2  8    Traffic_rate=mbps     dl_rate=80     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  8    Traffic_rate=mbps     ul_rate=10     pdu_id=1    trf_id=1       qfi_id=1

#Step-6: Capture TTI-trace and verify that the slots were UE-1 & UE-2 or UE-2 alone are scheduled on that slots no
#        Artificial Loads are generated.Artificial Loads are only observed when UE-1 and dummy RNTIs are scheduled together.
    ${bip_pcap3}     AiC Start & Stop BIP Log    ${5}     test_scenario=with_8_real_ue
    ${CsvPathpdsch3}     Convert PCAP to CSV    ${bip_pcap3}   dldata_pdschsendreq    dldata_pdschsendreq    @{pdschheader}
    ${CsvPathpdcch3}     Convert PCAP to CSV    ${bip_pcap3}   dldata_pdcchsendreq    dldata_pdcchsendreq    @{pdcchheader}
    # tti verification code need to be added
    ${res_pdsch}    validation_of_pdsch    ${CsvPathpdsch3}    dldata_pdschsendreq    0    ${pdschheader}[1:]
    ...    ${crnti}    ${273}    ${1}    ${30}    ${28}    ${0}    ${usablepdschonssb}
    ...    maxpdschinslot=${6}    nbrOfBlankedPRBsHighEdgeDL=${0}    nbrOfBlankedPRBsLowEdgeDL=${0}    beam=${1}
    Should contain    ${res_pdsch}    Pass    ignore_case=True
    ${res_pdcch}    validation_of_pdcch    ${CsvPathpdcch3}   dldata_pdcchsendreq    0    ${crnti}    ${273}    ${30}    ${pdccharg}
    Should contain    ${res_pdcch}    Pass    ignore_case=True

#Common Step Stop Data and UE Deregister
    Stop MultiUE Data Traffic for SA     1  8    
    [Teardown]  Run Keywords   MultiUE Deregister should be Successful      1    8
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
AiC Start & Stop BIP Log
    [Arguments]    ${duration}     ${test_scenario}
    ${alias}    vdu_log.VDU Begin BIP Log Collection Using HAL-CLI   port_name=l1up   pod_name=l2rt-0    ctr_name=l2rt
    sleep    ${duration}s
    ${log_dir_gnb}           Set Variable          ${LOG_PATH}/${TEST_NAME}/gNB/bip/${test_scenario}
    vdu_log.VDU Stop And Save BIP Log To Local   dst_log_path=${log_dir_gnb}   bip_collection_alias=${alias}
    ...     port_name=l1up   pod_name=l2rt-0   ctr_name=l2rt
    [return]    ${log_dir_gnb}
#
Modify Inputrc file VDU
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0  ${using_tenant}=${True}  ${conn_prompt}=${EMPTY}
    log to console  add set enable-bracketed-paste off in etc/inputrc of VDU
    ${alias}    generic_utils.get_unique_id_string
    ssh_conn.connect_to_vdu_cloud_hosting
    ...  using_tenant=${True}
    ...  vdu_index=${vdu_index}
    ...  gnb_index=${gnb_index}
    ...  prompt=${conn_prompt}
    ...  alias=${alias}
    ssh_conn.execute_normal_cmd    base_command=sudo chmod +777 /etc/inputrc     alias=${alias}
    ssh_conn.execute_normal_cmd    base_command=sudo echo 'set enable-bracketed-paste off'>>/etc/inputrc     alias=${alias}


