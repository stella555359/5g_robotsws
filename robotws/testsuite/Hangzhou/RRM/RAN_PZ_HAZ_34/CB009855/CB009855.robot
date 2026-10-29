# @Time    : 2023/11/16 10:03
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009855_A.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009855-A

Suite Setup         MMW5 Common Suite Setup
Suite Teardown      Run Keywords    MMW5 Common Suite Teardown
...    AND     Connect to gnb coam via ssl
...    AND     Run Keyword And Ignore Error    Modify Parameter On BTS With Activate
...    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-221    parameter=administrativeState    value=unlocked
...    AND     Sleep    15s
...    AND     Run Keyword And Ignore Error    coam.perform_delta_recommissioning
...    delta_file=${CURDIR}/${MRBTS_ID}_PWS_active.json    skip_parameter_relation_errors=True
...    should_activate=True    timeout=${600}    connection=GNB_OAM
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB009855_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

*** Variables ***
${3CC_SCELL_PHY_IDS}    55,50,52
${4CC_SCELL_PHY_IDS}    55,266,50,52
@{5CC_GLOBAL_CELL_IDS}    1    2    4    5    6
${5CC_SCELL_PHY_IDS}    55,266,271,50,52
@{maxPayloadSize_Scell_release}    20    16    12    8
@{maxCodeRate_Scell_release}    1    0
${4scells_release}    1,2,3,4
${5CC_SCELL_PHY_IDS_for_SBTS2040}    50,266,271,52,55
${5CC_SCELL_PHY_IDS_for_SBTS2040_PcellFDD}    266,271,50,52,55
${101_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-101.pcap
${101_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-101-rrc.pcap
${102_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-102.pcap
${102_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-102-rrc.pcap
${103_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-103.pcap
${103_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-103-rrc.pcap
${104_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-104.pcap
${104_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-104-rrc.pcap
${107_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-107.pcap
${107_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-107-rrc.pcap
${109_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-A-109.pcap
${109_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-A-109-rrc.pcap
${701_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-B-701.pcap
${701_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-B-701-rrc.pcap
${502_WIRESHARK_LOG}    ${OUTPUT_DIR}/9855-B-502.pcap
${502_WIRESHARK_RRC}    ${OUTPUT_DIR}/9855-B-502-rrc.pcap
${DELTE_CA}         ${CURDIR}/CB009855A_Resources/DELETE_CA.json
${ADD_CA}           ${CURDIR}/CB009855A_Resources/ADD_CA.json
${CHANGE_SCELL}     ${CURDIR}/CB009855A_Resources/CHANGE_SCELL.json
${SCF_A101}         ${CURDIR}/CB009855A_Resources/SCF_A101.xml
${SCF_A102}         ${CURDIR}/CB009855A_Resources/SCF_A102.xml
${SCF_A103}         ${CURDIR}/CB009855A_Resources/SCF_A103.xml
${SCF_A107}         ${CURDIR}/CB009855A_Resources/SCF_A107.xml
${SCF_A109}         ${CURDIR}/CB009855A_Resources/SCF_A109.xml
${SCF_B102}         ${CURDIR}/CB009855B_Resources/SCF_B102.xml
${SCF_B204}         ${CURDIR}/CB009855B_Resources/SCF_B204.xml
${SCF_A104}         ${CURDIR}/CB009855A_Resources/SCF_A104.xml
${SCF_B701}         ${CURDIR}/CB009855B_Resources/SCF_B701.xml
${SCF_B502}         ${CURDIR}/CB009855B_Resources/SCF_B502.xml
${SCF_W102_103}     ${CURDIR}/CB009855W_Resources/SCF_W102_103.xml

${FILTER_PUCCH}         uldata_pucchreceivereq
@{FIELDS_PUCCH_UCI}     UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation
${FILTER_PUSCH}         uldata_puschreceivereq
@{FIELDS_PUSCH_UCI}     UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
...    UlData_puschReceiveReqGrant_t.numOfUciAckBits
&{PUSCH_UCI_PRE}        UlData_puschReceiveReqGrant_t.numOfUciAckBits=20
${B102_PUCCH_CSV}       ${TS_CASE_LOG_PATH}/b102_pucch.csv
${B102_PUSCH_CSV}       ${TS_CASE_LOG_PATH}/b102_pusch.csv

${B204_SRS_CSV}         ${TS_CASE_LOG_PATH}/B204_SRS.csv
${FILTER_SRS}           uldata_srsreceivereq
@{FIELDS_SRS}           3gpp.subcellid
@{FIELDS_PATTERN_ID}    3gpp.subcellid    UlData_eCpriConfigStruct_t.patternId_item

${dcap_ip}     10.101.60.54
${dcap_port}    443
${WEBUI_IP}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
@{traces}    create list   cp_5g
@{ul_cell_list}    609107970    609107972
@{dl_cell_list}    	609107969    	609107970    609107972    609107973    609107974

*** Test Cases ***
CB009855_A_101_Blind_based_Scell_addition_and_activation_for_TDD_PCell_with_5CC_DL_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 10:33
    [Tags]    101
    COAM Commission with scf file    ${SCF_A101}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    Start To Capture Wireshark Log From DU
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Sleep    10s
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    ...    parameter=maxNumScellsDlFr1    value=4
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${101_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${101_WIRESHARK_LOG}    ${101_WIRESHARK_RRC}
    # check 4cc list, maxpayload = 20, maxCodeRate >= 0.25, maxCodeRate: zeroDot08 (0), maxCodeRate: zeroDot25 (2)
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${4CC_SCELL_PHY_IDS}
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxPayloadSize    20
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxCodeRate    2

    Start To Capture Wireshark Log From DU
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${101_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${101_WIRESHARK_LOG}    ${101_WIRESHARK_RRC}
    # check 5cc list, maxpayload = 24, maxCodeRate >= 0.25, maxCodeRate: zeroDot08 (0), maxCodeRate: zeroDot25 (2)
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${5CC_SCELL_PHY_IDS}
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxPayloadSize    24
    Check Field Value Via Wireshark    ${101_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxCodeRate    2

CB009855_A_102_3T+2F_DL_5CC_activation_with_different _pucchF3ModulationSchemand_pucchF3MaxCodeRate_configuration
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 13:22
    [Tags]    102
    COAM Commission with scf file    ${SCF_A102}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${102_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${102_WIRESHARK_LOG}    ${102_WIRESHARK_RRC}
    Check Field Value Via Wireshark    ${102_WIRESHARK_RRC}    nr-rrc.PUCCH_ResourceSet_element    nr-rrc.pucch_ResourceSetId    0,1

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    ...    parameter=pucchF3MaxCodeRate    value=zeroDot08

    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=100
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${102_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${102_WIRESHARK_LOG}    ${102_WIRESHARK_RRC}
    # maxCodeRate >= 0.45, maxCodeRate: zeroDot08 (0), maxCodeRate: zeroDot25 (2), maxCodeRate: zeroDot45 (4)
    Check Field Value Via Wireshark    ${102_WIRESHARK_RRC}    nr-rrc.PUCCH_ResourceSet_element    nr-rrc.pucch_ResourceSetId    0,1,2
    Check Field Value Via Wireshark    ${102_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxPayloadSize    24
    Check Field Value Via Wireshark    ${102_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${5CC_SCELL_PHY_IDS}

CB009855_A_103_3T+2F_DL_5CC_activation_with_additionalDmrs_enable_and_counter_update
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 15:09
    [Tags]    103
    COAM Commission with scf file    ${SCF_A103}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}
    ...    ultarget_throughput=0    dltarget_throughput=50
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${103_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${103_WIRESHARK_LOG}    ${103_WIRESHARK_RRC}
    # maxCodeRate >= 0.45, maxCodeRate: zeroDot08 (0), maxCodeRate: zeroDot25 (2), maxCodeRate: zeroDot45 (4)
    Check Field Value Via Wireshark    ${103_WIRESHARK_RRC}    nr-rrc.setup_element    nr-rrc.maxCodeRate    4
    Sleep    60s
    Verify 5CC Counters Update Normal

CB009855_A_104_Coverage_based_Scell_addition_and_release_for_3T+2F_DL_5CC
    [Documentation]    Author: xiaofei.zhao@nokia-sbell.com
    ...    Init Define: 2023/12/20 10:35
    [Tags]    104
    COAM Commission with scf file    ${SCF_A104}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    # SET PA to initial value
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    1=21    2=21    14=21    15=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=26    4=26
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=10    6=10   7=10    8=10
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=22    10=22    11=22   12=22
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    # Start wireshark log and attech UE
    Start To Capture Wireshark Log From DU
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    Sleep    20s
    # release one scell: cell2
    ${channels_to_modify}    create dictionary    3=60    4=60
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    Sleep    5s
    # release one scell: cell1
    ${channels_to_modify}    create dictionary    1=45    2=45    14=45    15=45
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    Sleep    5s
    # release one scell: cell6
    ${channels_to_modify}    create dictionary    9=60    10=60    11=60    12=60
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    Sleep    5s
    # release one scell: cell5
    ${channels_to_modify}    create dictionary    5=45    6=45    7=45    8=45
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    5s
    # release UE and stop wireshark log
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${104_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${104_WIRESHARK_LOG}    ${104_WIRESHARK_RRC}
    # check 5cc add successfully, check maxpayload and maxCodeRate(maxCodeRate: zeroDot08 (0), maxCodeRate: zeroDot15 (1)) after scells release.
    Check Field Value Via Wireshark    ${104_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId
    ...    ${5CC_SCELL_PHY_IDS_for_SBTS2040}
    ${true_value}    Get Field Value Via Wireshark    ${104_WIRESHARK_RRC}    nr-rrc.sCellToReleaseList   nr-rrc.maxPayloadSize    sort_time=True
    Lists Should Be Equal    ${true_value}    ${maxPayloadSize_Scell_release}
    ${true_value}    Get Field Value Via Wireshark    ${104_WIRESHARK_RRC}    nr-rrc.sCellToReleaseList    nr-rrc.maxCodeRate    sort_time=True
    Lists Should Be Equal    ${true_value}    ${maxCodeRate_Scell_release}

CB009855_A_107_3T+2F_DL_5CC_activation_and deactivation_with_cDRX_disable
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/17 10:45
    [Tags]    107
    COAM Commission with scf file    ${SCF_A107}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${107_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${107_WIRESHARK_LOG}    ${107_WIRESHARK_RRC}
    Check Field Value Via Wireshark    ${107_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${5CC_SCELL_PHY_IDS}

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    ...    parameter=maxNumScellsDlFr1    value=3
    UE Stop Traffic And Release UE
    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${107_WIRESHARK_LOG}

    Filter Wireshark Log To RRC    ${107_WIRESHARK_LOG}    ${107_WIRESHARK_RRC}
    Check Field Value Via Wireshark    ${107_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${4CC_SCELL_PHY_IDS}

CB009855_A_109_3T+2F_DL_5CC_Deactivation
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/17 11:20
    [Tags]    109
    AlarmWatchdog.add_allow_alarms    fault_id=7331
    COAM Commission with scf file    ${SCF_A109}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    # Step 1:
    # UE at location of good coverage from cell4, cell5, cell6, cell1 and cell2.UE attach cell4.
    # UE successfully attached to the Pcell cell4, 3T+2F Dl 5CC will be addition after A1 measurement report received.
    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M    duration=1200
    Sleep    10s
    Stop To Capture Wireshark Log From DU    local_pcap_path=${109_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${109_WIRESHARK_LOG}    ${109_WIRESHARK_RRC}
    # check 5cc list
    Check Field Value Via Wireshark    ${109_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${5CC_SCELL_PHY_IDS}

    # Step 2
    # do delta commission from WebEM: delete "700: ca_Fr1Tdd_Any_Sa" from NRBTS/NRDU.carrierAggregationSupportList
    # delete success, UE also remain in DL 5CC.
    coam.perform_delta_recommissioning    delta_file=${DELTE_CA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50

    # Step 3:
    # UE detach, then attach to cell4 again.
    # UE successfully attached to the Pcell cell4 again, but only 3CC can be addtion when A1 MR received.
    UE Stop Traffic And Release UE
    Start To Capture Wireshark Log From DU
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M    duration=1200
    Sleep    10s
    Stop To Capture Wireshark Log From DU    local_pcap_path=${109_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${109_WIRESHARK_LOG}    ${109_WIRESHARK_RRC}
    # check 4cc list
    Check Field Value Via Wireshark    ${109_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${3CC_SCELL_PHY_IDS}

    # Step 4:
    # release UE. do delta commission from WebEM: Add back "700: ca_Fr1Tdd_Any_Sa" from NRBTS/NRDU.carrierAggregationSupportList
    # call release successfully.
    UE Stop Traffic And Release UE
    coam.perform_delta_recommissioning    delta_file=${ADD_CA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM

    # Step 5:
    # do delta commission from WebEM: Delete one of the candidate scell(cell2) of cell4, add one inter-gNB
    # cell(cell-x) as the candidate scell of cell4.
    # cell 4 candidate scells:cell5,cell6,cell1,cell-x(inter-gNB)	delta commission active successfully.
    coam.perform_delta_recommissioning    delta_file=${CHANGE_SCELL}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM

    # Step 6:
    # UE at location of good coverage from cell4, cell5, cell6, cell1. UE attach cell4.
    # UE successfully attached to the Pcell cell4 , only 4CC can be addtion when A1 MR received.
    # The inter-gNB cell can not be selected to add as the scell of cell4.
    # Step 7:
    # release UE call release successfully.
    Start To Capture Wireshark Log From DU
    Sleep    10s
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M    duration=1200
    Sleep    10s
    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${109_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${109_WIRESHARK_LOG}    ${109_WIRESHARK_RRC}
    # check 4cc list
    Check Field Value Via Wireshark    ${109_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId    ${4CC_SCELL_PHY_IDS}

CB009855_B_102_3T+2F_DL_5CC_activation_with_Peak_UCI_load_on_Thor
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/19 16:28
    [Tags]    b102
    COAM Commission with scf file    ${SCF_B102}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Start to collect bip log new    ${5CC_SCELL_PHY_IDS}
    UE Attach With Verify Attach
    UE Start DL Traffic    throughput=1500M    dl_time=1200    parallel=3
    Sleep    10s
    Stop to collect bip log new    ${TS_CASE_LOG_PATH}
    ${merged_bip_file}    Merge Multiple Bip Files Into One File
    Convert BIP To CSV By MCShark    bip_file=${merged_bip_file}
    ...    output_file=${B102_PUCCH_CSV}    filter=${FILTER_PUCCH}    csv_title_list=${FIELDS_PUCCH_UCI}
    ${uci_value}    get_the_special_item_value    file_path=${B102_PUCCH_CSV}    special_item=${FIELDS_PUCCH_UCI[0]}

    ${pucch_result}   Run Keyword And Return Status    Should Contain Any    ${uci_value}    60
    Run keyword if  ${pucch_result}==False   B_102_pusch_check_without_UL_traffic  merged_bip_file=${merged_bip_file}
    Run keyword if  ${pucch_result}   B_102_pusch_check_with_UL_traffic
    UE Stop Traffic And Release UE

CB009855_B_204_IWK13_IWK6_DL_5CC_interworking_SRS_based_UL_beamforming
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/25 22:12
    [Tags]    b204
    COAM Commission with scf file    ${SCF_B204}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=qct_dx50
    Ue attach with index    ue_index=0
    turn mobile data on    alias=UE_0
    UE Start UL&DL UDP Traffic    ul_tp=500M    dl_tp=1500M    parallel=3   duration=1200

    start btslog capture
    Start to collect bip log new    ${5CC_SCELL_PHY_IDS}
    Sleep    10s
    Stop to collect bip log new    ${TS_CASE_LOG_PATH}
    stop btslog and collect logs    status=FAIL
    UE Stop Traffic And Release UE

    ${merged_bip_file}    Merge Multiple Bip Files Into One File
    Convert BIP To CSV By MCShark    bip_file=${merged_bip_file}
    ...    output_file=${B204_SRS_CSV}    filter=${FILTER_SRS}    csv_title_list=${FIELDS_SRS}
    ${srs_value}    get_the_special_item_value    file_path=${B204_SRS_CSV}    special_item=${FIELDS_SRS[0]}

    Convert BIP To CSV By MCShark    bip_file=${merged_bip_file}
    ...    output_file=${B204_SRS_CSV}    filter=${FILTER_PUSCH}    csv_title_list=${FIELDS_PATTERN_ID}
    &{pre_srs}    Create Dictionary    ${FIELDS_PATTERN_ID[0]}=${srs_value[0]}
    ${best_beam_ids_from_bip}    get_the_special_item_value_with_preconditon    file_path=${B204_SRS_CSV}
    ...    special_item=${FIELDS_PATTERN_ID[1]}    precondition=${pre_srs}
    ${best_beam_ids_from_syslog}    get_best_beam_ids_syslog
    ${include_count}    Set Variable    0
    FOR    ${id}    IN    @{best_beam_ids_from_bip}
        @{ids}    Split String    ${id}    ,
#        ${include}    Run Keyword And Return Status    List Should Contain Value    ${best_beam_ids_from_syslog}    ${ids[0]}
#        ${include_count}    Run Keyword If    ${include}    Evaluate    ${include_count}+1
        ${value}    Convert To Integer    ${ids[0]}
        ${status}    Evaluate    1000<${value}<10000
        ${include_count}    Run Keyword If    ${status}    Evaluate    ${include_count}+1
        ...    ELSE    Evaluate    ${include_count}+0
    END
    Should Be True    ${include_count}>0

CB009855_W_102_NR_peak_UDP_Tput_per_UE_for_3T+2F(nonDSS)_DL_CA_and_T+F_UL_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/15 13:34
    [Tags]    W102
    COAM Commission with scf file    ${SCF_W102_103}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Get Theory CA Dl Ul Tput
    UE root
    Sleep    10s
    Wait Until Keyword Succeeds    2 times  1s  W_102_check_UDP_peak_multiple_times

CB009855_W_103_NR_peak_TCP_Tput_per_UE_for_3T+2F(nonDSS)_DL_CA_and_T+F_UL_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/15 13:34
    [Tags]    W103
    COAM Commission with scf file    ${SCF_W102_103}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    Get Theory CA Dl Ul Tput
    UE root
    Sleep    10s
    Wait Until Keyword Succeeds    3 times  1s  W_103_check_TCP_peak_multiple_times

CB009855_B_701_IWK5_DL_T+F_5CC_interworking_with_A2_based_Pcell_Change
    [Documentation]    Author: xiaofei.zhao@nokia-sbell.com
    ...    Init Define: 2023/12/20 10:35
    [Tags]    701
    COAM Commission with scf file    ${SCF_B701}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    # SET PA to initial value
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    1=21    2=21    14=63    15=63
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=21    4=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=21    6=21   7=21    8=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=21    10=21    11=21   12=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    # Start wireshark log
    Start To Capture Wireshark Log From DU
    # start VoNR call and data
    #Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Make VoNR Call
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Verify UE VoNR Call Status
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    Sleep    20s
    # give lower RSRP to Pcell:cell4 to trriger Pcell change to scell:cell1
    ${channels_to_modify}    create dictionary    5=35    6=35    7=35    8=35
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    5s
    #check VoNR successfully after handover
    Verify UE VoNR Call Status
    # release UE and stop wireshark log
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${701_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${701_WIRESHARK_LOG}    ${701_WIRESHARK_RRC}
    # check handover successfully
    # check 5cc 2F+3T(FDD as Pcell) add successfully after handover
    # check counter update successfully after handover
    Check Field Value Via Wireshark    ${701_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId
    ...    ${5CC_SCELL_PHY_IDS_for_SBTS2040_PcellFDD}
    Check Field Value Via Wireshark    ${701_WIRESHARK_RRC}    nr-rrc.sCellToReleaseList == 4    nr-rrc.SCellIndex    ${4scells_release}
    Sleep    300s
    Verify M55118C02016 M55118C07510 Update Normal

CB009855_B_502_IWK9_DL_T+F_5CC_interworking_with_A6_based_Scell_swap
    [Documentation]    Author: xiaofei.zhao@nokia-sbell.com
    ...    Init Define: 2023/12/20 10:35
    [Tags]    502
    COAM Commission with scf file    ${SCF_B502}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    # SET PA to initial value
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    1=21    2=21    14=63    15=63
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=21    4=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=21    6=21   7=21    8=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=21    10=21    11=21   12=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    # Start wireshark log
    Start To Capture Wireshark Log From DU
    # start VoNR call and data
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=10M    dl_tp=3900M
    Run Keyword And Ignore Error    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=50
    Sleep    20s
    # give lower RSRP to scell:cell1 to trriger scell swap to cell11
    ${channels_to_modify}    create dictionary    1=45    2=45    14=21    15=21
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    Sleep    5s
    # release UE and stop wireshark log
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${502_WIRESHARK_LOG}
    Filter Wireshark Log To RRC    ${502_WIRESHARK_LOG}    ${502_WIRESHARK_RRC}
    # check Scell swap success, scell 1 will be released, new scell(pci 66) add.
    Check Field Value Via Wireshark    ${502_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element    nr-rrc.physCellId
    ...    ${5CC_SCELL_PHY_IDS_for_SBTS2040}
    Check Field Value Via Wireshark    ${502_WIRESHARK_RRC}    nr-rrc.sCellToAddModList == 1    nr-rrc.physCellId    66
    Check Field Value Via Wireshark    ${502_WIRESHARK_RRC}    nr-rrc.sCellToReleaseList == 1    nr-rrc.SCellIndex    1

*** Keywords ***
B_102_pusch_check_without_UL_traffic
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]    ${merged_bip_file}
    Convert BIP To CSV By MCShark    bip_file=${merged_bip_file}
    ...    output_file=${B102_PUSCH_CSV}    filter=${FILTER_PUSCH}    csv_title_list=${FIELDS_PUSCH_UCI}
    ${uci_value}    get_the_special_item_value_with_preconditon    file_path=${B102_PUSCH_CSV}
    ...    special_item=${FIELDS_PUSCH_UCI[0]}    precondition=${PUSCH_UCI_PRE}
    List Should Contain Value    ${uci_value}    39
B_102_pusch_check_with_UL_traffic
    Start to collect bip log new    ${5CC_SCELL_PHY_IDS}
    UE Start UL Traffic    throughput=500M    ul_time=1200
    Sleep    30s
    Stop to collect bip log new    ${TS_CASE_LOG_PATH}
    ${merged_bip_file}    Merge Multiple Bip Files Into One File
    B_102_pusch_check_without_UL_traffic  merged_bip_file=${merged_bip_file}

Check CA Tput via backup APPserver
    UE Stop Traffic And Release UE
    UE Attach With Verify Attach
    Sleep    30s
    UE Start DL Traffic    throughput=1376M    dl_time=600s   hostname=10.71.207.149    parallel=3
    Sleep    30s
    UE Start UL Traffic    throughput=200M    ul_time=600s   appserver_addr=10.71.207.149
    Check CA Throught From Asslog    duration=5m   
    ...    ul_tp=${theoretical_ul_2CC_sum}   dl_tp=${theoretical_dl_5CC_sum}
    ...    ul_list=${ul_cell_list}    dl_list=${dl_cell_list}

W_103_check_TCP_peak_multiple_times
    UE Attach With Verify Attach
    UE Start UL&DL TCP Traffic    duration=600s    iperf_path=/data/iperf    app_iperf=iperf
    Check CA Throught From Asslog    duration=5m     ul_tp=${theoretical_ul_2CC_sum}    dl_tp=${theoretical_dl_5CC_sum}
    ...    ul_list=${ul_cell_list}    dl_list=${dl_cell_list}
    UE Stop Traffic And Release UE

W_102_check_UDP_peak_multiple_times
    UE Attach With Verify Attach
    Sleep    10s
    UE Start DL Traffic    throughput=1376M    dl_time=600s    parallel=3
    Sleep    10s
    UE Start UL Traffic    throughput=200M    ul_time=600s
    ${first_result}   Run Keyword And Return Status    Check CA Throught From Asslog    duration=5m
    ...    ul_tp=${theoretical_ul_2CC_sum}   dl_tp=${theoretical_dl_5CC_sum}
    ...    ul_list=${ul_cell_list}    dl_list=${dl_cell_list}
    Run Keyword If   ${first_result}==False    Check CA Tput via backup APPserver
    UE Stop Traffic And Release UE



UE root
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root  connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

