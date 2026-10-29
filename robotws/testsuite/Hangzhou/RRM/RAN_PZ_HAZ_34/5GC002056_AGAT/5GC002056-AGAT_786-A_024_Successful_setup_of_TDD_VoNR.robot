*** Settings ***
Force Tags    PY36
Documentation     author: yayun.zhang
...                 contact: yayun.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000786

Resource     ./Resources/5GC000786_common_keyword.robot

Suite Setup    robot_common_operations.Common Suite Setup

Suite Teardown     Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               run keyword and ignore error    5GC000786_common_keyword.Common Suite Teardown for COAM

*** Variables ***
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${gnb_path}           /tmp/
${epc_log_path}       /opt/workspace/CIT/Master/Case_Logs/
${tl_scf_file_name}    golden_TDD.xml
${gnb_scf_SBTS24R1_ENB_0000}    golden_TDD_24R1.xml
${gnb_scf_SBTS23R4_ENB_0000}    golden_TDD_23R4.xml
${gnb_scf_SBTS23R3_ENB_0000}    golden_TDD_23R1.xml
${interface}    any
${nglogname2}    786A024.pcap
${nglogname3_1}    786A024_1.pcap
${nglogname3_2}    786A024_2.pcap
${nglogname3_3}    786A024_3.pcap
${nglogname3_4}    786A024_4.pcap
${nglogname3_5}    786A024_5.pcap
${gnb_instance}    ${tl.gnbs[0].instance_id}
${enb_instance}    ${tl.enbs[0].instance_id}
${connection}     local gnb1
${gnb_filter}     ngap.procedureCode == 26 and ngap.fiveQI == 1
${gnb_filter1}    ngap.procedureCode == 44 and nr-rrc.voiceOverNR == 0
${gnb_filter2}    ngap.procedureCode == 26 && ngap.nas == 0
@{gnb_filter3}    e1ap.procedureCode == 8 and e1ap.fiveQI == 5    e1ap.procedureCode == 9 and e1ap.fiveQI == 7
                  ...    e1ap.procedureCode == 9 and e1ap.fiveQI == 1
@{gnb_filter6}    ngap.fiveQI == 1 and frame.time     ngap.nas == 0 and frame.time
${index0}    0
@{value}    5    7    1
${value1}     28
${phone_number_TL341_1}    ${tl.ues[0].sec_key}    #####18001006405
${phone_number_TL341_2}    ${tl.ues[1].sec_key}    #####18001006302
${phone_number_TL344_1}    ${tl.ues[0].sec_key}    #####18001006254
#${phone_number_TL344_2}    ${tl.ues[1].sec_key}    #####18001006429
${phone_number_TL344_2}    18001006429
${phone_number_TL242_1}    ${tl.ues[0].sec_key}    #####18001006209
#${phone_number_TL242_2}    ${tl.ues[1].sec_key}    #####18001006409
${phone_number_TL242_2}    13100001043
@{diffTL_enb}       34121    5294    242    5395
@{diffTL_enb_ID}    34121    5294    242    5395
${att_port1_341}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port2_341}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port3_341}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port4_341}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port5_341}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port6_341}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port7_341}    ${tl.attenuator[0].attenuator_ports[7]}
${att_port8_341}    ${tl.attenuator[0].attenuator_ports[8]}
${att_port9_341}    ${tl.attenuator[0].attenuator_ports[9]}
${att_port10_341}    ${tl.attenuator[0].attenuator_ports[10]}
${att_port11_341}    ${tl.attenuator[0].attenuator_ports[11]}
${att_port12_341}    ${tl.attenuator[0].attenuator_ports[12]}
###TL344##
${att_port1_gnb1_ru1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port2_gnb1_ru1}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port9_gnb1_ru2}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port10_gnb1_ru2}               ${tl.attenuator[0].attenuator_ports[4]}
#${4GRU_ANT11}                        ${tl.attenuator[1].attenuator_ports[11].port_no}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[12]}

${HBTE_eNB_att_port13}    ${tl.attenuator[0].attenuator_ports[13]}
${HBTE_eNB_att_port14}    ${tl.attenuator[0].attenuator_ports[14]}
${HBTE_eNB_att_port15}    ${tl.attenuator[0].attenuator_ports[15]}
#TL242###
${att_port_5_242}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_242}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_7_242}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_8_242}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_13_242}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_14_242}                ${tl.attenuator[0].attenuator_ports[6]}
${att2_port_5_242}                ${tl.attenuator[0].attenuator_ports[4]}
${att2_port_6_242}                ${tl.attenuator[0].attenuator_ports[3]}
@{branch}    SBTS23R3_ENB_0000    SBTS24R1_ENB_0000
*** Test Cases ***
[1]5GC002056-AGAT_5GC000786-A_024_Repeat_Several_Times_TDD_VoNR_Setup_and_Release
    [Documentation]    Test case description the gNB behaviour for the successful setup of Voice and release
    [Tags]            CDRT_21A    CDRT_TRUNK    CDRT_22R3    5GC002056_AGAT    CDRT_22R4    CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup
    Prepare gNB with cell on air
#    check value of parameter actVoNR
    Adjust gNB1_RU Attenuation to good
    Check UE exist
    Set automatic rotation on UEs
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname2}    interface=${interface}    connection=Local gnb1
    786 UEs attach
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}    connection=Local gnb1
    Check IE wireshark log for Repeat VoNR_Setup_and_Release log    nglogname=${nglogname3_1}    interface=${interface}
    ...    message_filter=${gnb_filter}    message_filter1=${gnb_filter2}    connection=Local gnb1
    Check IE wireshark log for Repeat VoNR_Setup_and_Release log    nglogname=${nglogname3_2}    interface=${interface}
    ...    message_filter=${gnb_filter}     message_filter1=${gnb_filter2}    connection=Local gnb1
    Check IE wireshark log for Repeat VoNR_Setup_and_Release log    nglogname=${nglogname3_3}    interface=${interface}
    ...    message_filter=${gnb_filter}    message_filter1=${gnb_filter2}    connection=Local gnb1
    Check IE wireshark log for Repeat VoNR_Setup_and_Release log    nglogname=${nglogname3_4}    interface=${interface}
    ...    message_filter=${gnb_filter}    message_filter1=${gnb_filter2}    connection=Local gnb1
    Check IE wireshark log for Repeat VoNR_Setup_and_Release log    nglogname=${nglogname3_5}    interface=${interface}
    ...    message_filter=${gnb_filter}    message_filter1=${gnb_filter2}    connection=Local gnb1
    Check timer differ    logname=${nglogname3_1}    message_filter=${gnb_filter6}[0]    message_filter1=${gnb_filter6}[1]
    ...          index00=${index0}     index01=${index0}    value=${value1}
    [Teardown]     Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}
    ...    connection=Local gnb1    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_1}    connection=Local gnb1    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_2}    connection=Local gnb1    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_3}    connection=Local gnb1    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_4}    connection=Local gnb1    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_5}    connection=Local gnb1    AND
    ...    run keyword and ignore error    coam.teardown    connection=Local gnb1    AND
    ...    run keyword and ignore error    CI_interface.Common Case Teardown

*** Keywords ***
Check IE wireshark log for Repeat VoNR_Setup_and_Release log
    [Arguments]    ${nglogname}    ${interface}    ${message_filter}    ${message_filter1}  ${connection}
    Make a voice and Capture log    nglogname=${nglogname}    interface=${interface}    connection=${connection}
    Check IE wireshark log for VONR setup and release    nglogname=${nglogname}    filter_1=${message_filter}
    ...                                                                            filter_2=${message_filter1}

Make a voice and Capture log
    [Arguments]    ${nglogname}    ${interface}   ${connection}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=${connection}
#    Make a voice call on UE
#    Make a VoNR call(+6688)
    Make VoNR separately on TDD TLs
    sleep    50s
    hang up VoNR call
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=${connection}
    sleep    5s

Make VoNR separately on TDD TLs
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Make a VoNR call separately    phone_number=${phone_number_TL341_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Make a VoNR call separately    phone_number=${phone_number_TL344_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Make a VoNR call separately    phone_number=${phone_number_TL242_2}

Check IE wireshark log for VONR setup and release
    [Arguments]    ${nglogname}    ${filter_1}    ${filter_2}
    Check IE wireshark log for VONR setup    logname=${nglogname}    message_filter=${filter_1}
    Check IE wireshark log for VONR Release    logname=${nglogname}    message_filter=${filter_2}
    sleep    5s

Check IE wireshark log for E1 log
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}    ${value}    ${value1}    ${value2}
    Check IE wireshark log for e1apbearerContext     logname=${logname}    message_filter=${message_filter}     value=${value}
    Check IE wireshark log for e1apbearerContext     logname=${logname}    message_filter=${message_filter1}    value=${value1}
    Check IE wireshark log for e1apbearerContext     logname=${logname}    message_filter=${message_filter2}    value=${value2}

Check IE wireshark log for e1apbearerContext
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.fiveQI
    should be equal    ${e1ap_fiveQI[0]}    ${value}

Adjust gNB1_RU Attenuation to good
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust gNB1_RU Topyoung to good
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    run keywords    Adjust gNB1_RU1 HBTE Attenuation to Good    AND
    ...    Adjust gNB2_RU1 HBTE Attenuation to Bad    AND    Adjust gNB2_RU2 HBTE Attenuation to Bad    AND
    ...    Adjust eNB1_RU Attenuation to Bad
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    run keywords    Adjust gNB1_TDD_Cell1 HBTE to 0 for TL242    AND
    ...    Adjust gNB2_FDD_Cells HBTE Attenuation to 120 for TL242    AND    Adjust LTE_Cells HBTE Attenuation to 120 for TL242

Adjust gNB1_RU Topyoung to good
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    Adjust the HBTE attenuation value    value_1=${0}     value_2=${0}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port1_341}
    ...    att_port_2=${att_port2_341}     att_port_3=${att_port3_341}
    ...    att_port_4=${att_port4_341}    atten_ip=${atten_ip}
    Adjust the HBTE attenuation value    value_1=${127}     value_2=${127}     value_3=${127}
    ...    value_4=${127}    att_port_1=${att_port5_341}
    ...    att_port_2=${att_port6_341}     att_port_3=${att_port7_341}
    ...    att_port_4=${att_port8_341}    atten_ip=${atten_ip}
    Adjust the HBTE attenuation value    value_1=${120}     value_2=${120}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port9_341}
    ...    att_port_2=${att_port10_341}     att_port_3=${att_port11_341}
    ...    att_port_4=${att_port12_341}    atten_ip=${atten_ip}

Adjust the Attenuation Value local
    [Arguments]      ${ports}    ${value}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    @{att_connection_port}   Create list    ${ports}
    att.setup_attenuator    ip_addr=${atten_ip}   port=${att_api_port_topyoung}
    ...    attenuation_port_numbers=${att_connection_port}      max_attenuation=${max_attenuation_value_topyoung}
    ...    vendor=${vendor_topyoung}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port}    att.read_attenuation    port=${ports}
    should be equal    ${value_port}    ${value}

Adjust gNB1_RU1 HBTE Attenuation to Good
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port1_gnb1_ru1}      att_port_2=${att_port2_gnb1_ru1}
    ...     att_port_3=${att_port9_gnb1_ru2}     att_port_4=${att_port10_gnb1_ru2}    atten_ip=${atten_ip}
    ...    value_1=${1}    value_2=${1}    value_3=${127}    value_4=${127}

Adjust gNB2_RU1 HBTE Attenuation to Bad
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}      att_port_2=${att_port_2}
    ...     att_port_3=${att_port_3}     att_port_4=${att_port_4}    atten_ip=${atten_ip}
    ...        value_1=${111}    value_2=${111}   value_3=${111}    value_4=${111}

Adjust gNB2_RU2 HBTE Attenuation to Bad
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...        value_1=${111}    value_2=${111}   value_3=${111}    value_4=${111}

Adjust eNB1_RU Attenuation to Bad
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
        adjust the HBTE attenuation value    att_port_1=${HBTE_eNB_att_port13}      att_port_2=${HBTE_eNB_att_port14}
    ...     att_port_3=${HBTE_eNB_att_port15}     att_port_4=${HBTE_eNB_att_port13}    atten_ip=${atten_ip}
    ...        value_1=${111}    value_2=${111}   value_3=${111}    value_4=${111}

Adjust gNB1_TDD_Cell1 HBTE to 0 for TL242
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att2_port_5_242}      att_port_2=${att2_port_6_242}
    ...     att_port_3=${att2_port_5_242}     att_port_4=${att2_port_6_242}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}

Adjust gNB2_FDD_Cells HBTE Attenuation to 120 for TL242
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5_242}      att_port_2=${att_port_6_242}
    ...     att_port_3=${att_port_7_242}     att_port_4=${att_port_8_242}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust LTE_Cells HBTE Attenuation to 120 for TL242
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_13_242}      att_port_2=${att_port_14_242}
    ...     att_port_3=${att_port_13_242}     att_port_4=${att_port_14_242}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}
