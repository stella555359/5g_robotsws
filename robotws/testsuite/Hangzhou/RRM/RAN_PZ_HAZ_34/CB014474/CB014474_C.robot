*** Settings ***
Documentation      Author: yayun.zhang@nokia-sbell.com
...                squad group: SG_03
...                feature : CB014474_C

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014474/Resources/CB014474_case_step.robot



Suite Setup         BuiltIn.Run Keywords     CB014474_suite_setup
...                 AND                      Common Case TestLine Setup     is_commission=True
...                                                                         golden_scf_name=${SCF_name_${gnb1_instance}}_${release_info}.xml

Suite Teardown      CB014474_suite_teardown


*** Variables ***
${UE1_dl_throughput}    50M
${UE2_dl_throughput}    5M
${UE1_tput_dl_cell}     45
${UE2_tput_dl_cell}     2
${C01_TTI_disable}                      C01_TTI_disable
${C02_TTI_disable}                      C02_TTI_disable
${C03_TTI_disable}                      C03_TTI_disable
${C04_TTI_disable}                      C04_TTI_disable
${UE1_attach}                           UE1_attach.pcap
${UE2_attach}                           UE2_attach.pcap
${UE1_attach_B202}                      UE1_attach_B202.pcap
${UE2_attach_B202}                      UE2_attach_B202.pcap
${logname1}                             logname1.pcap
${logname2}                             logname2.pcap
${logname1_B202}                        logname1_B202.pcap
${logname2_B202}                        logname2_B202.pcap
${frequency_364}    2600_0.25_ALL | 0DB~90DB
${APN_36411}    ${tl.ues[0].pdn}
${process_num_36411}    ${3}
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${tshark_path}      /usr/bin/tshark
${change_apn}      at+cgdcont=1,"IP","mdrb.nokia.com"
${recovery_apn}    at+cgdcont=1,"IP","wap2.nokia.com"
${UE2_imsi}    ${tl.ues[1].imsi}
${add5QI65rule}     ADD-5QI65-ZYY
${dele5QI65rule}    DEL-5QI65-ZYY
${add5QI83rule}     ADD-APP245-5QI83-VRF3
${dele5QI83rule}    DEL-APP245-5QI83-VRF3
@{gnb_list}         ${0}

*** Test Cases ***
[1]USCB014474-C_B3_04_MC-GBR_VoNR_bearer_interworking_with_HR_and_usage_minimum_PRB_granularity_IWK_CB014861
    [Documentation]
    ...    FCA_VRF_RRM-30595;12701519
    [Tags]    C01USCB014474-C_B3_04
    [Setup]
    CB014474_case_setup
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    log to console    Scenario 1 UE2 5QI9 nonGBR small traffic HR prb>=4
    change UE APN    uegroup=${uegroup}[1]    apn=${change_apn}
    ${UE1_RNTI_ID}    Signal UE attach and get UE_RNTI_ID    filename=${UE1_attach}    ue_alias=${uegroup}[0]    apn=${APN_${gnb_instance0}}
    ${UE2_RNTI_ID}    Signal UE attach and get UE_RNTI_ID    filename=${UE2_attach}    ue_alias=${uegroup}[1]    apn=${APN_${gnb_instance0}}
    Start capture gNB log on master    filename=${logname1}   gNB_index=${0}
    Start multi UE traffic and check TPUT    cellid=1    gnb_index=${0}
    ...                                     UE1_dl_throughput=${UE1_dl_throughput}    UE2_dl_throughput=${UE2_dl_throughput}
    ${nr_phy_cell_gnb1cell1}    get physicalCellId from coam_gnb_classical    lcrid=${1}    gnb_index=${0}
    Start Ttitrace With Admin Mode    names=${C01_TTI_disable}    nr_phy_cell_ids=${nr_phy_cell_gnb1cell1}    gNB_index=${0}
    sleep    2s
    Stop Ttitrace With Admin Mode    names=${C01_TTI_disable}    target_dir=${epc_log_path}
    Stop and download the Logs    filename=${logname1}    gNB_index=${0}
    Convert Ttitrace From Pcap To Excelcsv    names=${C01_TTI_disable}    target_dir=${epc_log_path}
    C01_TTI_analyze    RNTI_ID=${UE2_RNTI_ID}
    log to console    Scenario 2 add UE2 5QI65 GBR contain prb<4
    add 5QIx and start DL 5QIx DL 1k traffic    filename=${logname2}   imsi=${UE2_imsi}    rule=${add5QI65rule}
    ...                                         ue_addr=${${uegroup}[1]_IP}    names=${C02_TTI_disable}
    C02_TTI_analyze    RNTI_ID=${UE2_RNTI_ID}
    [Teardown]    Run Keywords    Common Case Teardown for COAM
    ...    AND    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download the Logs    filename=${logname1}    gNB_index=${0}
    ...    AND    change UE APN    uegroup=${uegroup}[1]    apn=${recovery_apn}
    ...    AND    Detech and stop multiues traffic     UE_NUM=${2}

[1]USCB014474-C_B2_02_Scheduling_of_multiple_UEs_each_having_a_non-GBR_and_GBR_HR_DRBs_DC-GBR_IWK_CB014861
    [Documentation]
    ...    FCA_VRF_RRM-30595;12701513
    [Tags]    C01USCB014474-C_B2_02    CRT
    [Setup]
    CB014474_case_setup    online_ModifySCF_GNB1=True
    ...                    Modify_Para_Online_GNB1=${Online_Modify_C_B2_02}
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    log to console    Scenario 1 UE2 5QI9 nonGBR small traffic HR prb>=4
    change UE APN    uegroup=${uegroup}[1]    apn=${change_apn}
    ${UE1_RNTI_ID}    Signal UE attach and get UE_RNTI_ID    filename=${UE1_attach_B202}    ue_alias=${uegroup}[0]    apn=${APN_${gnb_instance0}}
    ${UE2_RNTI_ID}    Signal UE attach and get UE_RNTI_ID    filename=${UE2_attach_B202}    ue_alias=${uegroup}[1]    apn=${APN_${gnb_instance0}}
    Start capture gNB log on master    filename=${logname1_B202}   gNB_index=${0}
    Start multi UE traffic and check TPUT    cellid=1    gnb_index=${0}
    ...                                     UE1_dl_throughput=${UE1_dl_throughput}    UE2_dl_throughput=${UE2_dl_throughput}
    ${nr_phy_cell_gnb1cell1}    get physicalCellId from coam_gnb_classical    lcrid=${1}    gnb_index=${0}
    Start Ttitrace With Admin Mode    names=${C03_TTI_disable}    nr_phy_cell_ids=${nr_phy_cell_gnb1cell1}    gNB_index=${0}
    sleep    2s
    Stop Ttitrace With Admin Mode    names=${C03_TTI_disable}    target_dir=${epc_log_path}
    Stop and download the Logs    filename=${logname1_B202}    gNB_index=${0}
    Convert Ttitrace From Pcap To Excelcsv    names=${C03_TTI_disable}    target_dir=${epc_log_path}
    C03_TTI_analyze    RNTI_ID=${UE2_RNTI_ID}
    log to console    Scenario 2 add UE2 5QI83 GBR contain prb<4
    add 5QIx and start DL 5QIx DL 1k traffic    filename=${logname2_B202}   imsi=${UE2_imsi}    rule=${add5QI83rule}
    ...                                         ue_addr=${${uegroup}[1]_IP}    names=${C04_TTI_disable}
    C04_TTI_analyze    RNTI_ID=${UE2_RNTI_ID}
    [Teardown]    Run Keywords    Common Case Teardown for COAM
    ...    AND    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download the Logs    filename=${logname1_B202}    gNB_index=${0}
    ...    AND    change UE APN    uegroup=${uegroup}[1]    apn=${recovery_apn}
    ...    AND    Detech and stop multiues traffic     UE_NUM=${2}


*** Keywords ***
add 5QIx and start DL 5QIx DL 1k traffic
    [Arguments]    ${filename}    ${imsi}    ${rule}    ${names}    ${ue_addr}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    sleep    2s
    add or delete 5QI via npc dynamic rule     imsi=${UE2_imsi}    rule=${rule}
    sleep    10s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    sleep    5s
#    ${ue_addr}    get Second DRB IP addr    filename=${filename}
    Start MUE dltraffic with appserver      ue_addr=${ue_addr}    dl_port=${${dl_port}-${3599}}
    ...    dl_throughput=${UE2_dl_throughput}
    sleep    30s
    ${nr_phy_cell_gnb1cell1}    get physicalCellId from coam_gnb_classical    lcrid=${1}    gnb_index=${gNB_index}
    Start Ttitrace With Admin Mode    names=${names}    nr_phy_cell_ids=${nr_phy_cell_gnb1cell1}    gNB_index=${gNB_index}
    sleep    2s
    Stop Ttitrace With Admin Mode    names=${names}    target_dir=${epc_log_path}
    sleep    5s
    Convert Ttitrace From Pcap To Excelcsv    names=${names}    target_dir=${epc_log_path}
    [Teardown]    Run Keywords
    ...    add or delete 5QI via npc dynamic rule     imsi=${imsi}    rule=${rule}
    ...    AND     Run Keyword And Ignore Error    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

get Second DRB IP addr
    [Arguments]    ${filename}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${filename}    alias=test6
    ${filter_expression}=     Catenate    (ngap.procedureCode == 26) && (nas-5gs.sm.pdu_addr_inf_ipv4)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pdu_addr_inf_ipv4}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.pdu_addr_inf_ipv4    pcap_parser=test6
    [Return]    ${pdu_addr_inf_ipv4}[0]

Check UEs traffic with pioneer client
    [Arguments]    ${UE1_tput_target}    ${UE2_tput_target}    ${direction}=dl    ${UE_define}=NULL
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'    ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
      ${tput_dic}    client.getparammac    ue=${uegroup}[${i}]
      ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
      ...                 ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
      run keyword if    '${i}'=='0'    should be true    ${tput_output} > ${UE1_tput_target}
      ...    ELSE                      should be true    ${tput_output} >= ${UE2_tput_target}
    END

Start multi UE traffic and check TPUT
    [Arguments]    ${cellid}=${1}    ${gnb_index}=${0}    ${dl_port}=${DL_PORT}    ${UE1_dl_throughput}=${UE1_dl_throughput}
    ...    ${UE2_dl_throughput}=${UE2_dl_throughput}    #${duration}=100s    ${direction}=DL    ${ue_type}=huawei
    Start MUE dltraffic with appserver      ue_addr=${${uegroup}[0]_IP}    dl_port=${dl_port}
    ...    dl_throughput=${UE1_dl_throughput}
    Start MUE dltraffic with appserver      ue_addr=${${uegroup}[1]_IP}    dl_port=${${dl_port}+${100}}
    ...    dl_throughput=${UE2_dl_throughput}
    sleep    30s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
#    Check single direction throughput     ue_index=${0}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
#    ...    expect_throughput=${UE1_tput_dl_cell}    gnb_index=${gnb_index}    duration=${duration}
#    check single direction throughput     ue_index=${1}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
#    ...    expect_throughput=${UE2_tput_dl_cell}    gnb_index=${gnb_index}    duration=${duration}
    Check UEs traffic with pioneer client     UE1_tput_target=${UE1_tput_dl_cell}    UE2_tput_target=${UE2_tput_dl_cell}

change UE APN
    [Arguments]    ${uegroup}=${uegroup}[0]    ${apn}=${recovery_apn}    ${until_timeout}=${300}
    client.sendat    command=${apn}    until_timeout=${until_timeout}    ue=${uegroup}
    sleep    15s

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[-1]

Signal UE attach and get UE_RNTI_ID
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${ue_alias}=${uegroup}[0]    ${apn}=${APN_${gnb_instance0}}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    sleep    5s
    MultiUE one Attach with client    ue_alias=${ue_alias}    apn=${apn}
    sleep    15s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${filename}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Return]    ${UE_RNTI_ID}

Multi UE attach and get UE_RNTI_ID
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${UE_NUM}=${1}    ${ue_alias}=${uegroup}[0]
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    Run keyword if     "${UE_NUM}" == "${1}"
    ...    MultiUE one Attach with client    ue_alias=${ue_alias}    apn=${APN_${gnb_instance0}}
    ...    ELSE     MultiUEs Attach with client    apn=${APN_${gnb_instance0}}
    sleep    5s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${filename}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Return]    ${UE_RNTI_ID}

C01_TTI_analyze
    [Arguments]    ${RNTI_ID}
    ${numOfPrb_value}    get_value_from_csv_file_dlFdSchedData_numOfPrb    file_path=${epc_log_path}/${C01_TTI_disable}_dl.csv
    ...                                                                       filter_name_1=rnti
    ...                                                                       filter_name_2=${RNTI_ID}
    ...                                                                       filter_name_3=dlFdSchedData.numOfPrb

C02_TTI_analyze
    [Arguments]    ${RNTI_ID}
    ${numOfPrb_value}    get_value_numOfPrb_priorityIndex    file_path=${epc_log_path}/${C02_TTI_disable}_dl.csv
    ...                                                                       filter_name_1=rnti
    ...                                                                       filter_name_2=${RNTI_ID}
    ...                                                                       filter_name_3=dlFdSchedData.numOfPrb
    ...                                                                       filter_name_4=dlFdSchedData.priorityIndex

C03_TTI_analyze
    [Arguments]    ${RNTI_ID}
    ${numOfPrb_value}    get_value_from_csv_file_dlFdSchedData_numOfPrb    file_path=${epc_log_path}/${C03_TTI_disable}_dl.csv
    ...                                                                       filter_name_1=rnti
    ...                                                                       filter_name_2=${RNTI_ID}
    ...                                                                       filter_name_3=dlFdSchedData.numOfPrb

C04_TTI_analyze
    [Arguments]    ${RNTI_ID}
    ${numOfPrb_value}    get_C03_value_numOfPrb_priorityIndex    file_path=${epc_log_path}/${C04_TTI_disable}_dl.csv
    ...                                                                       filter_name_1=rnti
    ...                                                                       filter_name_2=${RNTI_ID}
    ...                                                                       filter_name_3=dlFdSchedData.numOfPrb
    ...                                                                       filter_name_4=dlFdSchedData.priorityIndex


prepare MultilUE and MCS
    [Arguments]    ${att_value_UE0}=${10}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${87}    ${horizontal_1}=${14}   ${vertical_2}=${86}    ${horizontal_2}=${29}
    ...    ${vertical_3}=${82}    ${horizontal_3}=${-14}    ${vertical_4}=${80}    ${horizontal_4}=${-30}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    Log to console    step2 prepare UE and MCS
    Prepare and setup MCS
    MCS 2UE AND SET ATT    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    att1_value_UE0=${att1_value_UE0}    att1_value_UE1=${att1_value_UE1}
    ...    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    ...    vertical_5=${vertical_5}    horizontal_5=${horizontal_5}    vertical_6=${vertical_6}    horizontal_6=${horizontal_6}
    ...    vertical_7=${vertical_7}    horizontal_7=${horizontal_7}    vertical_8=${vertical_8}    horizontal_8=${horizontal_8}
    Prepare MultiUE with client

Prepare and setup MCS
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='topyoung'
    ...    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency_364}

MCS 2UE AND SET ATT
    [Arguments]
    ...    ${att_value_UE0}=${90}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${90}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${87}    ${horizontal_1}=${14}   ${vertical_2}=${86}    ${horizontal_2}=${29}
    ...    ${vertical_3}=${82}    ${horizontal_3}=${-14}    ${vertical_4}=${80}    ${horizontal_4}=${-30}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    Log to console    Set MCS PA
    Run keyword if    '${mcs_type}'=='haojin'
    ...    HAOJIN MCS SETUP AND SET ATT for MultiUE    mcs_type=${mcs_type}
    ...    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    P5_out=${9}     P6_out=${10}    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}
    ...    P7_out=${11}    P8_out=${12}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    Run keyword if    '${mcs_type}'=='topyoung'     Run Keywords
    ...    TOPYOUNG MCS SETUP AND SET ATT for Two UEs with different ATT    mcs_type=${mcs_type}
    ...    att_value_UE0=${att1_value_UE0}    att_value_UE1=${att1_value_UE1}
    ...    P1_out=${5}    P2_out=${6}    vertical_1=${vertical_5}    horizontal_1=${horizontal_5}
    ...    P3_out=${7}    P4_out=${8}    vertical_2=${vertical_6}    horizontal_2=${horizontal_6}
    ...    P5_out=${13}     P6_out=${14}    vertical_3=${vertical_7}    horizontal_3=${horizontal_7}
    ...    P7_out=${15}    P8_out=${16}    vertical_4=${vertical_8}    horizontal_4=${horizontal_8}
    ...    AND    TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${90}
    ...    att_value2=${90}     first_beam_begin_output_port=${5}      first_beam_end_output_port=${8}    begin_input_port=${65}
    ...    second_beam_begin_output_port=${13}    second_beam_end_output_port=${15}    end_input_port=${128}

Detech and stop multiues traffic
    [Arguments]    ${appserver}=APPserver    ${UE_NUM}=${1}    ${alias}=pioneer
    FOR    ${index}    IN RANGE   ${UE_NUM}
        Close the iperf process on APPserver    port=${dl_port}   appserver=${appserver}
        Detach MultiUE    ue=${uegroup}[${index}]
        ${dl_port}    Evaluate    ${dl_port}+100
    END
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${${dl_port}-${3799}}  appserver=${appserver}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}