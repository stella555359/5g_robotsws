*** Settings ***
Documentation     author: yayun.zhang && Xing Jing
...                 contact: yayun.zhang@nokia-sbell.com && jing.1.xing@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB006112

Library     DateTime
#Library     L3Call.py
Library    taf.analyzer.pcap    WITH NAME    cap
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.analyzer.pcap   WITH NAME    parser
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
#Library     ./../../common/delete_ue_and_sip_context.py
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.rfrl.common_resources.python.SWConfig   WITH NAME    SWConfig
#Variables   ../Resources/786_Case_Commission_Classical/__init__.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Library    sigspark.SigSpark    WITH NAME    spark

*** Variables ***
${gnb_path}    /tmp
${enb_path}    /tmp
${connection}    gnb
${tshark_path}      /usr/bin/tshark
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${distname_id_3}      MRBTS-${tl.gnbs[2].instance_id}/NRBTS-${tl.gnbs[2].instance_id}
${SUT_IP}         ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.addr}
${SUT_NAME}       ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.username}
${SUT_PWD}        ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.password}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${enb_instance}     ${tl.enbs[0].instance_id}
${TOPYONG_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${att2_port_5}                ${tl.attenuator[1].attenuator_ports[5]}
${att2_port_6}                ${tl.attenuator[1].attenuator_ports[6]}
${atten_ip}    ${tl.attenuator[0].ip_addr}
${5G2RU1_ANT12}    ${tl.attenuator[0].attenuator_ports[12]}
${5G1RU1_ANT9}    ${tl.attenuator[0].attenuator_ports[9]}
${5G1RU1_ANT10}    ${tl.attenuator[0].attenuator_ports[10]}
${5G1RU2_ANT11}    ${tl.attenuator[0].attenuator_ports[11]}
${4G1RU1_ANT15}    ${tl.attenuator[0].attenuator_ports[15]}
${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${TS_CASE_LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
###UE ###
${ue_type}    huawei
${duration}    8000
${deviation}    15
${ABIO_ALIAS}    ASIB_ABIO
${tl_scf_filename_enb}    eNB_6112_C_20.xml
${command_template_with_f1ap}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_with_ngap}    {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${command_template_with_rrc}    {tshark_path} -r {pcap_file} -Y  \"ngap or nr-rrc\"  -T pdml
${command_template_with_f1rrc}    {tshark_path} -r {pcap_file} -Y  \"f1ap or nr-rrc or ngap or e1ap\"  -T pdml
${command_template_with_e1ap}    {tshark_path} -r {pcap_file} -Y  \"e1ap or ngap\"  -T pdml
${command_template_with_e1apFrame}    {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
${command_template_with_f1nr}    {tshark_path} -r {pcap_file} -Y  \"f1ap or nr-rrc\"  -T pdml
${command_template_with_ngxn}    {tshark_path} -r {pcap_file} -Y  \"xnap or ngap\"  -T pdml
${command_template_with_f1xn}    {tshark_path} -r {pcap_file} -Y  \"f1ap or nr-rrc or xnap\"  -T pdml
${command_template_with_s1ap}    {tshark_path} -r {pcap_file} -Y  \"f1ap or nr-rrc or s1ap\"  -T pdml
${command_template_with_f1xn2}    {tshark_path} -r {pcap_file} -Y  \"f1ap or xnap_16_5_0_2103_n03\"  -T pdml
${command_template_with_ngxn2}    {tshark_path} -r {pcap_file} -Y  \"xnap_16_5_0_2103_n03 or ngap\"  -T pdml


*** Keywords ***
###attenuator###
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT9}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT10}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${atten_ip}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}     ${att_port_3}=${att_port_3}
    ...             ${att_port_4}=${att_port_4}     ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    1s

adjust the HBTE attenuation single port value
    [Arguments]     ${value_1}     ${att_port_1}=${att_port_1}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    sleep    1s

Adjust gNB2_FDD_Cells HBTE Attenuation to 120
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}


Change the PA value to trigger HO for C_14
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${5}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${20}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${10}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${10}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${15}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${5}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${20}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${3}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${25}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${0}

Change the PA value to trigger HO for B_08
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${2}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${20}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${4}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${10}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${6}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${5}
    Adjust gNB2_FDD_Cell2 HBTE Attenuation to value    value=${8}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${0}

Change the PA value to trigger HO for A_010
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${20}
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${5}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${15}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${10}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${5}
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${10}
    sleep     5s
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${15}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${3}
    Adjust gNB2_FDD_Cell1 HBTE Attenuation to value    value=${0}
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${18}
    sleep     2s
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${21}
    sleep     2s
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${23}

Change the PA value to trigger gnb1 cell1 110db for EDA
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${25}
    sleep     5s
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${32}
    sleep     5s
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value    value=${35}

Change the PA value to attach on gNB1 cell1
    adjust the HBTE attenuation single port value    value_1=${127}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${0}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${0}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU2_ANT11}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${4G1RU1_ANT15}

Change the PA value to attach on gNB1 cell2
    adjust the HBTE attenuation single port value    value_1=${127}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${0}    att_port_1=${5G1RU2_ANT11}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${4G1RU1_ANT15}

Change the PA value to attach on gNB2 cell1
    adjust the HBTE attenuation single port value    value_1=${18}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${5G1RU2_ANT11}
    adjust the HBTE attenuation single port value    value_1=${127}    att_port_1=${4G1RU1_ANT15}

Change the PA value to trigger HO for A_010 for trunk
    adjust the HBTE attenuation single port value    value_1=${25}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${5}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${5}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${30}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${2}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${2}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${32}      att_port_1=${5G2RU1_ANT12}
    adjust the HBTE attenuation single port value    value_1=${0}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${0}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${33}      att_port_1=${5G2RU1_ANT12}


Change the PA value to trigger HO for B_08 for trunk
    adjust the HBTE attenuation single port value    value_1=${1}      att_port_1=${5G1RU2_ANT11}
    adjust the HBTE attenuation single port value    value_1=${25}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${25}    att_port_1=${5G1RU1_ANT10}
    ##adjust the HBTE attenuation single port value    value_1=${2}      att_port_1=${5G1RU2_ANT11}
    adjust the HBTE attenuation single port value    value_1=${20}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${20}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${15}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${15}    att_port_1=${5G1RU1_ANT10}
    adjust the HBTE attenuation single port value    value_1=${10}    att_port_1=${5G1RU1_ANT9}
    adjust the HBTE attenuation single port value    value_1=${10}    att_port_1=${5G1RU1_ANT10}



Adjust gNB2_FDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_5}      att_port_2=${att_port_6}
    ...     att_port_3=${att_port_5}     att_port_4=${att_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${value}   value_3=${value}    value_4=${value}

Adjust gNB2_FDD_Cell2 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_7}      att_port_2=${att_port_8}
    ...     att_port_3=${att_port_7}     att_port_4=${att_port_8}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${value}   value_3=${value}    value_4=${value}

Adjust LTE_Cells HBTE Attenuation to 120
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_13}      att_port_2=${att_port_14}
    ...     att_port_3=${att_port_13}     att_port_4=${att_port_14}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust LTE_Cells HBTE Attenuation to 0
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_13}      att_port_2=${att_port_14}
    ...     att_port_3=${att_port_13}     att_port_4=${att_port_14}    atten_ip=${atten_ip}
    ...        value_1=${0}    value_2=${0}   value_3=${0}    value_4=${0}

Adjust gNB1_TDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att2_port_5}      att_port_2=${att2_port_6}
    ...     att_port_3=${att2_port_5}     att_port_4=${att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}

Adjust gNB1_gNB2_TDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att2_port_5}      att_port_2=${att2_port_6}
    ...     att_port_3=${att2_port_5}     att_port_4=${att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${30}   value_3=${value}    value_4=${30}

##BTS keyword##
Common Suite Teardown for COAM
    [Arguments]    ${gnb_index}=${0}
    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=gnb${gnb_index}
    ...         bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    #Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=gnb${gnb_index}    timeout=900
    Run Keyword And Ignore Error    coam.teardown    connection=gnb${gnb_index}


##BTS keyword##
Setup for SA Env cell on-air
    Prepare SA classical COAM BTS cell onair
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair
    set global variable    ${cell_status}

Prepare gNB with cell on air status
    [Arguments]    ${gnb_index}=${0}     ${tl_scf_file_name}=${tl_scf_file_name}
    ${L3call_status}    run keyword and return status    Prepare SA COMA classical BTS cell onair    gnb_index=${gnb_index}
    ...        tl_scf_file_name=${tl_scf_file_name}
    #Run Keyword And Ignore Error    CB006895_common_keywords.locked LTE cell    enb_index=${2}    enb_cell_id=${211}
    #Run Keyword And Ignore Error    Lock The Third gNB
    #Run Keyword And Ignore Error    CB006895_common_keywords.Check UE1 exist    ue_index=${0}
    set suite variable    ${L3call_status}

Prepare SA COMA classical BTS cell onair
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    #Lock SNSSAI     gnb_index=${gnb_index}
    Perform full commission for COAM SA gnb    scf=${SCF_path}${tl_scf_file_name}    gnb_index=${gnb_index}
    Check gnb COAM classical normally
    CB006895_common_keywords.Check the gnb cell status onair    cell_no=1

Perform full commission for COAM SA gnb
    [Arguments]    ${scf}=${SCF_path}${tl_scf_file_name}    ${gnb_index}=${0}
    Connect to gnb coam via ssl   bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Check gnb COAM classical normally
    ${res} =    Feature 1514 Enabled
    sleep    30s
    Run Keyword And Ignore Error    Check the gnb RU ready

Check the gnb RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    20s    get RU status
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
     CB006895_common_keywords.Get info status check    info_status=${ru1_status}

Check the gnb cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${gnb_ip}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    1min    30s    CB006895_common_keywords.Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Check gnb2 COAM classical normally
    sleep    3s
    wait until keyword succeeds    10min    20s    Check the gnb2 RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP on gnb2    port_num=${x2_sctp_port}

Lock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.lock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Unlock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.unlock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Lock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Unlock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Lock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.lock_cell    dist_name=/${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

unLock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.unlock_cell    dist_name=${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

lock gnb1 cell2
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

unlock gnb1 cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

lock gnb1 cell1
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=1    bts_host=${asik_addr}

Setup for SA Env cell on-air on gnb2
    Prepare SA classical COAM BTS cell onair on gnb2
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair on gnb2
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair on gnb2
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair on gnb2
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair on gnb2
    Perform full commission for COAM SA gnb2    scf=${SCF_path}${SCF_file_name_2}    gnb_ip=${asik2_addr}
    Check gnb2 COAM classical normally
    Check the gnb2 cell status onair    cell_no=1

Perform full commission for COAM SA gnb2
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   connection=GNB2_OAM    bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    connection=GNB2_OAM    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections    connection=GNB2_OAM

Check the gnb2 RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    20s    get gnb2 RU status
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get gnb2 RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
    CB006895_common_keywords.Get info status check    info_status=${ru1_status}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check the gnb2 cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    CB006895_common_keywords.Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Get all cell info
    [Arguments]    ${cell_no}
    FOR    ${cell_idx}    IN    1    ${cell_no}
        CB006895_common_keywords.Get cell info    cell_idx=${cell_idx}
    END

Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    CB006895_common_keywords.Get info status check    info_status=${cell_status}

gnb2 connection
    ssh.Connect to    hostname=${asik2_addr}    username=${asik2_username}    password=${asik2_password}    alias=gnb2

gnb2 disconnection
    csn.disconnect      connection=gnb2

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}
    Log To Console    Start Capture Wireshark Logs on gNB
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s

Start Capture Wireshark Logs on gNB without sctp
    [Arguments]     ${nglogname}    ${interface}
    Log To Console    Start Capture Wireshark Logs on gNB
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}/${nglogname}   connection=${connection}

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}
     Log To Console    Stop Capture Wireshark Logs on gNB
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=${connection}
    sleep    3

Start Capture Wireshark Logs on gNB2
    [Arguments]     ${nglogname}    ${interface}
    Log To Console    Start Capture Wireshark Logs on gNB2
    RUN KEYWORD AND IGNORE ERROR    gnb2 connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb2
    sleep    3s

Stop Capture Wireshark Logs on gNB2
    [Arguments]    ${nglogname}
    Log To Console    Stop Capture Wireshark Logs on gNB2
    gnb2 connection
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb2
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb2
    sleep    3
    gnb2 disconnection

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${gnb_index}=0
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    ${administrativeState_value}=    selenium_coam.get_parameter_value    dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state    abbr=administrativeState
    Should Be Equal    ${administrativeState_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set and check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
#    check value of parameter administrativeState on MO SNSSAI    value=${value}

set value of parameter administrativeState of gnb2 on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set and check value of parameter administrativeState of gnb2 on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState of gnb2 on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
#    check value of parameter administrativeState of gnb2 on MO SNSSAI    value=${value}

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    Log To Console    Modify parameters online for cases
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Get the gNB Cell Id
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}     ${distname_id}=${distname_id_1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell1_id} =    selenium_coam.get_parameter_value    dist_name=${distname_id}/NRCELL-1
    ...   abbr=nrCellIdentity    filter_param=NR Cell Identity    timeout=60
    set suite variable     ${cell1_id}
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[3]}_${info.split('_')[4]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

checking type of system board on gnb1
    gNB connections
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=${connection}
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Setting variable br1 for interface name on gnb1
    Run Keyword If    '${status}' == 'False'    Setting variable fp0 for interface name on gnb1
    csn.disconnect      connection=${connection}

checking type of system board on gnb2
    gnb2 connection
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=gnb2
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Setting variable br1 for interface name on gnb2
    Run Keyword If    '${status}' == 'False'    Setting variable fp0 for interface name on gnb2
    csn.disconnect      connection=gnb2

Setting variable br1 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    br1
    Log    The system board of gnb1 is ASIB
    Log To Console    The system board of gnb1 is ASIB

Setting variable fp0 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    fp0
    Log    The system board of gnb1 is ASIK
    Log To Console    The system board of gnb1 is ASIK

Setting variable br1 for interface name on gnb2
    Set Suite Variable    ${gnb2_interface_name}    br1
    Log    The system board of gnb2 is ASIB
    Log To Console    The system board of gnb2 is ASIB

Setting variable fp0 for interface name on gnb2
    Set Suite Variable    ${gnb2_interface_name}    fp0
    Log    The system board of gnb2 is ASIK
    Log To Console    The system board of gnb2 is ASIK

Teardown for disconnect all connections
    Run Keyword And Ignore Error    csn.Disconnect    connection=gnb
    Run Keyword And Ignore Error    csn.Disconnect    connection=cygwin
    Run Keyword And Ignore Error    csn.Disconnect    connection=EPCAPP
    Run Keyword And Ignore Error    csn.Disconnect    connection=enb
    Run Keyword And Ignore Error    enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

Save snapshot Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Check counter ${counter_id} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}

Check counter ${counter_id} equal ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}==${expected_value}


Check the bts counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    log to console    \n *** Check the bts counters are triggered
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55308C23002 as 100
    Check counter M55308C24001 as 100
    Check counter M55308C24002 as 100
    Check counter M55308C25001 as 100
    Check counter M55308C25002 as 100
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

###UE keywordWords###
Prepare env with UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}

Check phone attach successfully on SA env two times
    ${UE_status}    run keyword and return status     Check phone attach successfully on SA env
    run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env

Check phone attach successfully on SA env
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}    ue_index=${ue_index}
    Run keyword and ignore error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${ue_index}

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${during}=90s
    log to console    \n *** Make a VoNR call(+6688)
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    ${during}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    \n *** hang up VoNR call
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Set automatic rotation on UEs
    Set automatic rotation
    Set automatic rotation    ue_index=${1}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

UE attach successfully
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${ue_index}=${0}    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}
    Run keyword and ignore error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    5Grach_ed=${5Grach_ed}    4G_check=False

Make a voice call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
    End a call on UE    ue_index=${ue_index}    serial_number=${serial_number}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make a call on UE with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep   15s

End a call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####hang up with +6688#####
    log to console    \n *** End a call on UE
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

ADB Service Restart
    [Documentation]  Use adb command to recover adb service
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot ADB Service on ${cpc_alias}!
    csn.execute    command=sudo adb -s ${serial_number} kill-server    connection=${cpc_alias}
    csn.execute    command=sudo adb -s ${serial_number} start-server    connection=${cpc_alias}
    sleep   2s

Check adb devices status
    [Documentation]  check phone status by serial number
    ...    :param serial_number: the serial number of phone
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    csn.send_command   command=adb devices  connection=${cpc_alias}      timeout=5
    Sleep   2s
    ${result}    csn.read_output    connection=${cpc_alias}
    ${device_line}    Get lines Containing String    string=${result}    pattern=${serial_number}
    ...    case_insensitive=False
    ${device_status}    Get Substring    string=${device_line}    start=-6
    ${return_value}=    Set variable if    '${device_status}' == 'device'    PASS    FAIL
    [Return]    ${return_value}

Prepare env with UEs
    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}

Check ADB devices and restart ADB service
    [Documentation]   Sometimes ue is adb offline. Reboot adb service first, then reboot UEPC as a workaround.
    [Arguments]   ${ue_index}
    wait until keyword succeeds   5m   30s      Check adb devices status     ue_index=${ue_index}

Check UE1 exist
    [Arguments]   ${ue_index}= ${0}
    Check ADB devices and restart ADB service    ue_index=${ue_index}
    Check UE device exist     ue_index=${ue_index}

Check UE exist
    Check ADB devices and restart ADB service    ue_index=${0}
    Check UE device exist
    Check ADB devices and restart ADB service    ue_index=${1}
    Check UE device exist    ue_index=${1}

Start UL data transfer
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Check the UL throughput
    [Arguments]    ${ul_expected_throughput}    ${cell_id}=${cell1_id}    ${gnb_index}=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}    gnb_index=${gnb_index}

Check the DL throughput
    [Arguments]    ${dl_expected_throughput}        ${cell_id}=${cell1_id}    ${gnb_index}=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}    gnb_index=${gnb_index}

Start DL and UL data transfer
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${ue_index}=${0}
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    dl_throughput=${dl_throughput}    ue_index=${ue_index}
    Run keyword and ignore error    Start UL data transfer    ul_throughput=${ul_throughput}    ue_index=${ue_index}

Check the DL and UL throughput
    [Arguments]    ${dl_expected_throughput}    ${ul_expected_throughput}    ${gnb_index}=${0}
    Check the DL throughput    dl_expected_throughput=${dl_expected_throughput}    gnb_index=${gnb_index}
    Check the UL throughput    ul_expected_throughput=${ul_expected_throughput}    gnb_index=${gnb_index}
s
check voiceOverNR support
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${UERadioCapabilityInfoIndication} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 44
    Log To Console    check voiceOverNR value on UERadioCapabilityInfoIndication message
    ${UERadioCapabilityInfoIndication_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UERadioCapabilityInfoIndication}
    should be equal    ${UERadioCapabilityInfoIndication_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UERadioCapabilityInfoIndication}
    ${nr_rrc_voiceOverNR}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.voiceOverNR
    Should Be Equal    ${nr_rrc_voiceOverNR[0]}    0

Make a VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306    ${MOT_index}=${0}   ${MPT_index}=${1}
    Log to console     Make a VoNR and ViNR call together
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    phone_number=${phone_number}    ue_index=${MOT_index}
    answer ViNR call    ue_index=${MPT_index}

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    Log to console      Make a VoNR and ViNR call
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_T}    connection=cygwin
    sleep    5s

Make a VoNR call separately
    [Arguments]    ${phone_number}=18001006306    ${MOT_index}=${0}   ${MPT_index}=${1}
    Log To Console      Make a VoNR call separately
    Get VoNR and ViNR pointer variable
    Make a VoNR call    ue_index=${MOT_index}     phone_number=${phone_number}
    answer VoNR call    ue_index=${MPT_index}

Make a ViNR call separately
    Make a ViNR call
    answer ViNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s

answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s

Make a ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_S}    connection=cygwin${ue_index}
    sleep    5s

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin
    sleep    3s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input swipe ${swap_answer_ViNR_button}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}

hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep    5s

Get VoNR and ViNR pointer variable
    run keyword if    '${brand}'=='HUAWEI'
    ...    Get VoNR and ViNR pointer variable with mate30 pro

Get VoNR and ViNR pointer variable with mate30 pro
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    828 1985
    Set Suite Variable    ${switch_to_VoNR}    900 1726
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728
    Set Suite Variable    ${swap_answer_ViNR_button}     580 2000 920 2000

check points with VoNR and ViNR call together
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    2
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    2

check points with VoNR and ViNR call release together
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    2
    ${e1ap_dRB_ID}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    Should Contain    ${e1ap_dRB_ID}    6
    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    2

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${nr_rrc_drx_Config}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.drx_Config
#    Should Contain    ${nr_rrc_drx_Config}    1

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with ViNR call release
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    1
    ${e1ap_dRB_ID}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
#    Should Not Contain    ${e1ap_dRB_ID}    6
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    1

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with VoNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Not Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Not Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
#    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

check points with ViNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    2
    Should Not Contain    ${ngap_fiveQI}    1

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    2
    Should Not Contain    ${f1ap_fiveQI}    1
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

UE1 attach
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    Run keyword and ignore error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

UEs attach
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}
    Run keyword and ignore error    Trigger HUAWEI UE connect    ue_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}
    Run keyword and ignore error    Trigger HUAWEI UE connect    ue_index=${1}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

UEs detach
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

###check the 6112 wireshark log###
Check IE wireshark log for attach
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for VONR CDRX config
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for VONR_Release CDRX config
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for drx_onDurationTimer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${drx_onDurationTimer}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.milliSeconds
    should be equal    ${drx_onDurationTimer[0]}    ${value}

Check IE wireshark log for drx_InactivityTimer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${drx_InactivityTimer}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
    should be equal    ${drx_InactivityTimer[0]}    ${value}

Check IE wireshark log for longDRXCycleLength
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${longDRXCycleLength}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.longDRXCycleLength
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value}

Delete all NRADJGNB object
    Delete NRADJGNB object on gnb    url=${WEBUI2_COAM}    distname_ID=${distname_id_2}
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM}    distname_ID=${distname_id_1}

Delete NRADJGNB object on gnb
    [Arguments]    ${url}    ${distname_ID}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-2
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-2
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    selenium_coam.logout

###ENB common keyword###
locked LTE cell
    [Arguments]    ${enb_index}=${0}    ${enb_cell_id}=${1}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    [Arguments]    ${enb_index}=${0}    ${enb_cell_id}=${1}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute

enb connection
    csn.Connect To    hostname=${enb_address}    username=${enb_username}    password=${enb_password}    alias=enb

Enb start capture wireshark log
    [Arguments]    ${filename}     ${interface}=br1    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

Enb stop and Save classical Logs
    [Arguments]    ${filename}    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

Capture TTITrace and download to test pc ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}
    Log To Console    Capture TTITrace and download to test pc ASIB
    Start TTI trace log capturing ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    2s
    Stop TTI trace log capturing    connection_for_abil=${ABIO_ALIAS}
    sleep     10s
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${epc_log_path}
    ...                         connection_for_abil=${ABIO_ALIAS}
    Set suite variable    ${ttitrace_localpath}    ${dict_csv_file_path['DL']}

Start TTI trace log capturing ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${connection_for_abio}=${None}    ${du_index}=${0}
    Run keyword if    '${connection_for_abio}'=='${None}'
    ...    Create default connection ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}    du_index=${du_index}
    ${connection_for_abio}    Set variable if    '${connection_for_abio}'=='${None}'    ${ABIO_ALIAS}    ${connection_for_abio}
    tti.prepare_for_tti_trace_log_capturing    connection=${connection_for_abio}
    tti.start_tti_trace    connection=${connection_for_abio}

Create default connection ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${du_index}=${0}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    ...                                                      alias=${ABIO_ALIAS}    du_index=${du_index}

TL UE detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=huawei    ue_index=${ue_index}

Check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${ngap_nas}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[0]}    0

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    Log To Console    Check IE wireshark log for VONR setup
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_ngap}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    1

Check IE wireshark log for RLF
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_f1ap}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${f1ap_cause}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.radioNetwork
    should be equal    ${f1ap_cause[0]}    12

Check IE wireshark log for VONR attach
    [Arguments]     ${logname}    ${message_filter}    ${message_filter1}    ${value}    ${value1}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_ngap}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    ${value}
    ${filter_expression}=     Catenate    ${message_filter1}
    ${filtered_packets}=    parser.Filter Packets By Expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    ${value1}

Trigger HUAWEI UE connect
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin${ue_index}
    sleep    10s

gNB.Close iperf progress
    [Arguments]
    Set Test Variable    ${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
    Set Test Variable    ${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
    Set Test Variable    ${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
    Set Test Variable    ${dl_port}    ${tl.ues[0].iperf_details.port}
    Set Test Variable    ${ul_port}    ${tl.appserver.iperf_details.port}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on APPserver    port=${ul_port}

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>2    sleep   2min
    Run Keyword If    ${utc_min}<=2    sleep    5s


Check IE wireshark log for CDRX config
    [Arguments]    ${logname}    ${message_filter}    ${value1}    ${value2}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_f1nr}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    #${drx_onDurationTimer}=     parser.get_field_value_by_xpath   pdml_list=${filtered_packets}
    #...                                                xpath=.//nr-rrc.milliSeconds
    #should be equal    ${drx_onDurationTimer[0]}    ${value1}
    ${drx_InactivityTimer}=     parser.get_field_value_by_xpath   pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
    should be equal    ${drx_InactivityTimer[0]}    ${value1}
    ${drx_LongCycleStartOffset}=     parser.get_field_value_by_xpath   pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.drx_LongCycleStartOffset
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value2}

Check IE wireshark log for discardtimer config
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}       command_template=${command_template_with_f1rrc}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${discard_Timer}=     parser.get_field_value_by_xpath   pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.discardTimer
    should be equal    ${discard_Timer[0]}    ${value}

Check the bts discard counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    Log To Console     Check the bts discard counters are triggered
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C23002 as 100
    Check counter M55310C19001 as 1
    Check counter M55308C24001 as 100
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts discard counters are not be triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    Log To Console     Check the bts discard counters are not be triggered
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C23002 as 100
    Check counter M55310C19001 equal 0
    Check counter M55308C24001 as 100
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout


Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    Log To Console     Check timer differ
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    evaluate  float(${time2})-float(${time1})
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index0}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...                  command_template=${command_template_with_e1apFrame}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    @{frame_time}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//frame.time_epoch
    #    ${timelist} =   Evaluate    ${frame_time}[${index}].split('|')
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
#    ${timestamp} =     Caculate the wireshark timevalue to seconds    input_value=${timelist}   index=${index0}
    [Return]    ${timestamp}

Update the swconfig file
    [Arguments]    ${localFilePath}     ${gnb_index}=${0}
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master   alias=ASIK    du_index=${0}    gnb_index=${gnb_index}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK
    csn.Disconnect    connection=ASIK

Reboot UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    csn.send_command   command=adb -s ${serial_number} reboot     connection=${cpc_alias}      timeout=5
    Sleep   5s

clear UTE memery cache
    [Arguments]     ${alias}=ute_cache
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...             username=${tl.test_pc.default_ssh_connection_details.username}
    ...             password=${tl.test_pc.default_ssh_connection_details.password}    alias=${alias}
    sleep     10s
    Log To Console     before clear UTE memery cache
    ${cache_status}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status}
    sleep     5s
    Run Keyword And Ignore Error    csn.send command
    ...    command=sudo -i -u root -- sh -c 'echo 3 > /proc/sys/vm/drop_caches'    connection=${alias}
    sleep     5s
    Log To Console     after clear UTE memery cache
    ${cache_status2}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status2}
   [Teardown]     csn.disconnect    connection=${alias}

#######check MOS#######################
open pionner
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn Pioneer2
    ...    connection=cygwin
    sleep    85s

close Pioneer
    [Arguments]    ${ue_index}=${0}
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    ue_index=${ue_index}
    csn.Execute       command=taskkill /F /IM Pioneer.exe       connection=cygwin

Check MOS from csv
    [Arguments]    ${csv_num}=${1}
    ${num}    Run    more ${LOG_PATH}UE${csv_num}.csv |grep 20|wc -l
    should be true    ${num} > 2
     FOR  ${i}    IN RANGE    2   ${num}+1
         ${rc}    ${content}     OperatingSystem.Run And Return Rc And Output
            ...    cat ${LOG_PATH}UE${csv_num}.csv |sed -n "${i}p" | cut -d "," -f 5 |sed 's/\"//g'
         run keyword and continue on failure    should be true    ${content} > 3
         ${i}    evaluate    ${i}+1
    END

Prepare test plan
    [Arguments]    ${TestPlansLocation}=${TestPlansLocation}
    log to console    open pionner
    open pionner
    log to console    require_platform
    Run Keyword And Ignore Error    spark.require_platform    ue_alias=UE_0
    sleep    10s
    Run Keyword And Ignore Error    spark.disconnect_ues     ue_alias=UE_0
    close Pioneer
    log to console    open pionner
    open pionner
    log to console    create_test_plan
    spark.create_test_plan    ue_alias=UE_0    testplanslocation=${TestPlansLocation}
    Run Keyword And Ignore Error    Run    rm -rf ${LOG_PATH}UE*

Perform full commission for COAM enb BTS
    [Arguments]    ${scf_file_path_enb}=${SCF_path}${tl_scf_filename_enb}
    Connect to eNB via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte
