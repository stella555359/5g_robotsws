*** Settings ***
Documentation     author: jack.zeng
...                 contact: jack.zeng@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB010764
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/convert_aW_to_dBm.py
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_variables.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Variables ***
${ue_type}           ${tl.ues[0].capabilities[0]}
${brand}          samsung
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${tl_scf_dir_path}    /opt/workspace/SCF/
${gnb_instance}     ${tl.gnbs[0].instance_id}
@{BTSID}    36011    34711    23311    38411
@{prach_PRB_number}     ${6}      ${12}
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36011_scf_gnb1_24R1}    gy_36011_GNB1_24R1.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_38411_scf_gnb1}    gy_38411_GNB1.xml
${tl_scf_file_name}    gy_36011_GNB1.xml
${gnb_path}    /tmp/
${connection}    gnb

${tshark_path}      /usr/bin/tshark
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
#${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${vendor}                    ${tl.attenuator[0].vendor}
${SN}                       ${tl.ues[0].serial_number}
${enb_instance}     ${tl.enbs[0].instance_id}
@{gnb_list}    ${0}
${UTE_IP}            ${tl.test_pc.default_ssh_connection_details.addr}

###path###
${swconfig}                 /opt/workspace/SCF/swconfig.txt
###BTS###
${MRBTS1_ID}                ${tl.gnbs[0].instance_id}
#${MRBTS2_ID}                ${tl.gnbs[1].instance_id}
#${ENB1_ID}                  ${tl.enbs[0].instance_id}
#${ENB2_ID}                  ${tl.enbs[1].instance_id}

###PA###
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_13_36011}        ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_36011}        ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_36011}        ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_36011}        ${tl.attenuator[0].attenuator_ports[16]}
${att_port_5_36011}         ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_36011}         ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_36011}         ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_36011}         ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_36012}         ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10_36012}        ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11_36012}        ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12_36012}        ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_36021}         ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_36021}         ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_36022}         ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_36022}         ${tl.attenuator[0].attenuator_ports[4]}
${att_port_13_23311}        ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_23311}        ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_23311}        ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_23311}        ${tl.attenuator[0].attenuator_ports[16]}
${att_port_5_23311}         ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_23311}         ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_23311}         ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_23311}         ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_23312}         ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10_23312}        ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11_23312}        ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12_23312}        ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_23321}         ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_23321}         ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_23322}         ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_23322}         ${tl.attenuator[0].attenuator_ports[4]}

${att_port_1_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_5_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_6_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_7_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${att_port_8_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${att_port_9_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${att_port_10_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${att_port_11_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${att_port_12_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}
${att_port_13_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_14_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${att_port_15_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${att_port_16_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${gnb_logs_install_path}       /home/ute/gnb_logs
${localFilePath}       /opt/workspace/SCF/swconfig_CB010764/swconfig.txt
@{allow_fault_list}    7311    7107    7523    4681
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

####----TL362PA----####
${vendor_10318}                     HBTE
${att_api_port_10318}               ${tl.attenuator[1].port}
${model_10318}                      ${tl.attenuator[1].model}
${att_ipaddr_10318}                 ${tl.attenuator[1].ip_addr}

${att_port_1_cell1_10318}         ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell1_10318}         ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell1_10318}         ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell1_10318}         ${tl.attenuator[1].attenuator_ports[4]}
${att_port_5_cell3_10318}         ${tl.attenuator[1].attenuator_ports[5]}
${att_port_6_cell3_10318}         ${tl.attenuator[1].attenuator_ports[6]}
${att_port_7_cell3_10318}         ${tl.attenuator[1].attenuator_ports[7]}
${att_port_8_cell3_10318}         ${tl.attenuator[1].attenuator_ports[8]}
${att_port_9_ENB1cell1_10318}       ${tl.attenuator[1].attenuator_ports[9]}
${att_port_10_ENB1cell1_10318}       ${tl.attenuator[1].attenuator_ports[10]}
${att_port_11_ENB2cell1_10318}       ${tl.attenuator[1].attenuator_ports[11]}
${att_port_12_ENB2cell1_10318}       ${tl.attenuator[1].attenuator_ports[12]}

*** Keywords ***
####CB010764 common *** keywords ***
Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${duration}=${600}    #${dl_port}=${DL_PORT}        #${protocol}=udp
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}    ${duration}=${600}     #${protocol}=udp
    ...    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

Stop DL or UL IMS traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

Start DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}     ${protocol}=udp    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${dl_port}

Start UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}     ${protocol}=udp    ${ul_port}=${UL_PORT}    ${duration}=${600}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${ul_port}

Start UE DLUL UDP traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${ul_throughput}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${tput_ul_cell}=${tput_ul_cell}     ${dl_throughput}=${dl_throughput}    ${tput_dl_cell}=${tput_dl_cell}
    ...    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${duration}=${600}    #${protocol}=udp
    Start UE DLUL UDP traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    @{nrcellid_cell_1}    Create list  ${nrcellid_cell}
    Check Bi direction throughput    ue_index=${ue_index}    ue_type=${ue_type}    ultarget_throughput=${tput_ul_cell}
    ...    dltarget_throughput=${tput_dl_cell}    list_of_cell_ids=${nrcellid_cell_1}    gnb_index=${gnb_index}
    sleep    5s
    Stop UL DL data transfer    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}    ul_port=${ul_port}

Start UE DLUL UDP traffic
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_type}    ${dl_throughput}=${dl_throughput}    ${ul_throughput}=${ul_throughput}
    ...    ${dl_port}=${dl_port}    ${duration}=600
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}
    ...                          dl_port=${dl_port}    duration=${duration}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}

###BTS keyword###

Setup for Env cell on-air for 2 gnb
    [Arguments]    ${is_commission}=True    ${is_commission_for_second_gnb}=True
    Common Case TestLine Setup    is_commission=${is_commission}    is_commission_for_second_gnb=${is_commission_for_second_gnb}
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    golden_scf_name_gnb2=${tl_scf_file_name2}

Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Load Scf depends on Release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[3]'
    ...    Common Case TestLine Setup    is_commission=True
    ...     golden_scf_name=${tl_38411_scf_gnb1}

Load Scf depends on Release
    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     #${connection}==du_coam
    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'     Common Case TestLine Setup    is_commission=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}
    ...    ELSE     Common Case TestLine Setup    is_commission=True
    ...     golden_scf_name=${tl_36011_scf_gnb1_24R1}

#Setup for Env cell on-air
#    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
#    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
#    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the gNB cells onair status
#    should be equal    '${cell_status}'    'True'

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get_cell_id_multi_cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${cell_list}=    coam.get_cell_list    connection=GNB_OAM
#    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
#        @{cell_ids}=    set variable    ${cell['physicalCellId']}
#    END
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get BTS parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    #${distname_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
#    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${0}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${MO_ID}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get nrCellIdentity value
    [Arguments]    ${gnb_index}=${0}    ${distname_id}=${0}
    ${nrCellIdentity_value}=    get parameter value    class_name=NRCELL    Abbreviation=nrCellIdentity
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    Set Test Variable    ${nrCellIdentity_value}    ${nrCellIdentity_value}

get required value of parameter
    [Arguments]    ${Abbreviation}    ${class_name}=NRCELL    ${gnb_index}=${0}    ${distname_id}=${0}
    ${parameter_value}=    get parameter value    class_name=${class_name}    Abbreviation=${Abbreviation}
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    [Return]    ${parameter_value}

###enb parameter
Modify parameter on enb
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify the enblte parameter    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]    #${dist_name1}=${enb_dist_name2}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb MME IP
    [Arguments]    ${dist_name}=${enb_dist_name}[1]    ${parameter}=${enb_para}[1]    ${value}=${enb_value}[2]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

###UE keywordWords###
Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}

Step2: UE setup VoNR call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}


UE attach verify with adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${distname_id}=${0}
    ${cell_id}=    get_attached_nr_cell_id_on_ue
    ...    host=${hostname}    username=${username}    password=${password}    sn=${serial_number}
    get nrCellIdentity value    gnb_index=${gnb_index}    distname_id=${distname_id}
    ${reslut}=    Run Keyword And Return Status    Should Be Equal As Strings    ${nrCellIdentity_value}    ${cell_id}
    Run Keyword If    '${reslut}'=='${True}'    Log to console    INFO:5G UE setup successfully.
    ...    ELSE IF    '${reslut}'=='${False}'    Fail    5G UE setup not successfully.

Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
#    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}
#    Setup Variable for attenuator
#    Setup Variable for cellID

check hanging resource for per UE on gnb
    [Arguments]    ${gnb_ips}    ${UE_Type_Index}=${2}
    ${ue_num}    get length    ${tl.ues}
#    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[${UE_Type_Index}]}    ue_index=${ue_index}
        make airplane mode to enable    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Should Be Equal    ${passed}    ${True}
    END
    Check hanging resource for gnb    gnb_ips=${gnb_ips}

UE Detach With Power UE Index
    [Arguments]    ${ue_index}    ${ue_type}=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UE Detach With Power UE for 3UES
    [Arguments]    ${ue_type}=${ue_type}    ${ue_num}=3
    FOR    ${ue_no}    IN RANGE    0    ${ue_num}
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_no}
    END

###check wireshark log###




###PM counter
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Prepare wait 10mins time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%600
    ${utc} =    set variable if    '${period}'=='start'     ${utc+600}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    600-${utc0}%600
    sleep    ${left_timer}

Get current PM counter time
#    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
#    ${utc0} =    Evaluate    ${utc0}+28800
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${left_timer} =    Evaluate    300-${utc0}%300
    ${utc0} =     Evaluate      ${utc0}+${left_timer}-600
    ${utc0_counter} =     Convert Date	    ${utc0}    exclude_millis=yes     result_format=%Y/%m/%d/%H/%M/00
    ##${utc0_counter2} =     Convert Date	    ${1699317600}    exclude_millis=yes     result_format=%Y/%m/%d/%H/%M/00
    [Return]    ${utc0_counter}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter greater expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}>=${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter contain expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should contain any    ${counter_value}    ${1}    ${2}
    [Teardown]    COAM Teardown gnb connections



###-------PA--------###
Adjust the GNB1CELL1 HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS1_ID}    ${gnb1_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_${tl}}    ${att_port_14_${tl}}
    ...    ${att_port_15_${tl}}    ${att_port_16_${tl}}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_13_${tl}}    att_ipaddr=${att_ipaddr}

Adjust the GNB1CELL2 HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS1_ID}    ${gnb1_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_${tl}}    ${att_port_6_${tl}}
    ...    ${att_port_7_${tl}}    ${att_port_8_${tl}}
    ###create value list####
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_13_${tl}}    att_ipaddr=${att_ipaddr}

Adjust the GNB2CELL1 HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS2_ID}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_${tl}}    ${att_port_10_${tl}}
    ...    ${att_port_11_${tl}}    ${att_port_12_${tl}}
    ###create value list####
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_9_${tl}}    att_ipaddr=${att_ipaddr}

Adjust the ENB1CELL1 HBTE attenuation value
    [Arguments]     ${tl}=${ENB1_ID}    ${enb1_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_${tl}}    ${att_port_2_${tl}}
    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}    ${enb1_cell1_value}    ${enb1_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr}

Adjust the ENB2CELL1 HBTE attenuation value
    [Arguments]     ${tl}=${ENB2_ID}    ${enb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb2_cell1}    Create List    ${att_port_3_${tl}}    ${att_port_4_${tl}}
    ###create value list####
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}    ${enb2_cell1_value}    ${enb2_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_3_${tl}}    att_ipaddr=${att_ipaddr}

Adjust HBTE gNB_eNB_RU Attenuation
    Adjust the GNB1CELL1 HBTE attenuation value
    Adjust the GNB1CELL2 HBTE attenuation value
    Adjust the GNB2CELL1 HBTE attenuation value
    Adjust the ENB1CELL1 HBTE attenuation value
    Adjust the ENB2CELL1 HBTE attenuation value

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
    #get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

#Capture biplog and download
#    [Arguments]        ${bbmod_slots}=1    ${target_dir}=${epc_log_path}
#    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}    times=1s    nr_phy_cell_ids=@{nr_phy_cell_ids}
#    ${tmpbip}=     Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}
#    Set Test Variable    ${tmpbip}    ${tmpbip[0]}
#    [Return]     ${tmpbip}


###------------capture log with gnb_logs---------###
Capture Logs With gNB_logs_exe File local
    [Documentation]    Auther: liujia
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    log to console    --- check gnb_logs tool version and upgrade---
    upgrade gnb logs tool on VM    tool_download_path=/home/ute/
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${output}    ssh.Execute    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    [Documentation]    Auther: liujia
#    [Arguments]    ${bbmod_slots}=1
#    ...            ${duration}=2
#    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
#    ...            ${gnb_index}=0
#    ...            ${du_index}=0
#    ...            ${log_type}=BIP
#    log to console    --- check gnb_logs tool version and upgrade---
#    upgrade gnb logs tool on VM    tool_download_path=/home/ute/
#    log to console    --- start gnb_logs collection---
#    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m
#    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...               username=${tl.test_pc.default_ssh_connection_details.username}
#    ...               password=${tl.test_pc.default_ssh_connection_details.password}
#    ...               alias=ute
#    ssh.send command    command=cd ${gnb_logs_script_path}&&rm *${log_type}.zip   connection=ute
#    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c ${bbmod_slots} -${log_type_to_command_mapping['${log_type}']} ${duration}
#    ssh.send command    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
#    ${output_status}    Run Keyword And Return Status    ssh.read output until    finished    timeout=600    connection=ute
#    Run Keyword If    '${output_status}' == 'False'    Run Keywords
#    ...    upgrade_gnb_logs    cd_command=cd ${gnb_logs_script_path}    ex_command=./${start_capture_command}
#    ...    pc_ip=${TestPC_addr}    pc_name=${TestPC_username}    pc_pwd=${TestPC_password}    AND
#    ...    csn.send command    command=./${start_capture_command}   connection=ute    AND
#    ...    ssh.read output until    finished    timeout=600    connection=ute
#    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute



Capture Logs With WebUI without wait_to_finish
    [Documentation]    Auther: Jack
    [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log     ${Capture_bip_time}=2s    ${nr_phy_cell_ids}=None
    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}    times=${Capture_bip_time}
    ...                                                      target_file_name=${target_file_name}
    ...                                                      nr_phy_cell_ids=${nr_phy_cell_ids}

Start to Capture Logs With WebUI without wait_to_finish
    [Documentation]    Auther: Jack
    [Arguments]    ${target_file_name}=l1l2bip_log     ${nr_phy_cell_ids}=None
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}
    ...                                         nr_phy_cell_ids=${nr_phy_cell_ids}



Capture BIPlog with WebUI and Download
    [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log
    ${biplog_path}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}
    ...                                                                       target_file_name=${target_file_name}
    [Return]    ${biplog_path}[0]

Get Captured BIP File from UTE on local
    [Documentation]    Auther: liujia
    [Arguments]    ${gnb_logs_script_path}=${gnb_logs_install_path}
    ...            ${target_dir}=${epc_log_path}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    ...            ${target_file_name}=L2L1_Bip
    OperatingSystem.Run   command=cd ${target_dir}; rm -rf BTS-*_BIP
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    @{bip_files}    List Files In Directory	${gnb_logs_script_path}	   BTS-*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS-*_${gnb_ip}_*.zip    ${target_dir}
    ${bip_file}    Set Variable    ${bip_files[0]}
    ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
    Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
    ${specific_bip_file}    List Files In Directory    ${target_dir}/${file_name}/bip
    ...                                                *Bip*.pcap*
    ...                                                absolute=${True}
    ${all_bip_file_list}     Combine Lists     ${specific_bip_file}    ${all_bip_file_list}
    ${bipfile_num}=    get length    ${all_bip_file_list}
    FOR    ${index}    IN RANGE    ${bipfile_num}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}/${file_name};touch test_${index}.pcap
        OperatingSystem.Run
        ...    command=cd ${target_dir}/${file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${all_bip_file_list[${index}]}
    END
    log to console    all captured bip file list : ${all_bip_file_list}
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir};rm *_BIP.zip
    ${full_log_path}    Create List    ${target_dir}${/}${file_name}${/}${target_file_name}.pcap
    [Return]     ${full_log_path}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/gNB_${gnb_ip}_*_${log_type}.zip

Download gnb_logs after log collection finsished
    [Arguments]    ${gnb_logs_script_path}=${gnb_logs_install_path}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    #...            ${log_type}=BIP
    ${biplogs}    Get Captured BIP File from UTE on local    gnb_logs_script_path=${gnb_logs_script_path}
    ...            target_dir=${epc_log_path}     gnb_index=${gnb_index}     du_index=${du_index}
    [Return]     ${biplogs[0]}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Check IE prachPreambleIndex not exist in BIP Log with mcshark
    [Documentation]    Author: jack.zeng@nokia-sbell.com
    ...                This keyword is Check IE prachPreambleIndex not exist in BIP Log with mcshark, filter uldata_prachreceiveind
    [Arguments]    ${file_path}
    #...    ${phyCellId}=${None}
    #...    ${alias}=parser
    #...    ${filter}=uldata_prachreceiveind
    Run	   tshark -r ${file_path} -Y "uldata_prachreceiveind" -T pdml >${file_path}.txt
    sleep     60s
    ${result}=     Check String Exist In Txt File
    ...                 txt_file=${file_path}.txt    string_name=prachPreambleIndex
    Should Be Equal As Strings    ${result}    False
    [Return]     ${result}

Check noisepower in BIP Log with mcshark
    [Documentation]    Author: jack.zeng@nokia-sbell.com
    ...                This keyword is Check IE prachPreambleIndex not exist in BIP Log with mcshark, filter uldata_prachreceiveind
    [Arguments]    ${file_path}
    #...    ${phyCellId}=${None}
    #...    ${alias}=parser
    ...    ${filter}=uldata_prachreceiveind
    ${noisePower_value}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=!(3gpp.rnti == 65535)
    ...    xpath=.//UlData_prachReceiveIndSubcell_t.noisePower
    [Return]    ${noisePower_value}

Get Item Value From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}    ${filter_expression}    ${xpath}    ${filter}    #${alias}=parser
    ${bipList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            filter_expression=${filter_expression}   xpath=${xpath}     filter=${filter}
    ${bipList}    Remove Duplicates    ${bipList}
    ${bipList_length}    get length     ${bipList}
#    Should Be True    ${bipList_length} > 0    msg="Get Item From BIP Log Failed"
    [Return]    ${bipList}

Get Item numbers From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get numbers from bip log
    [Arguments]    ${file_path}    ${filter_expression}    ${xpath}    ${filter}    #${alias}=parser
    ${bipList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            filter_expression=${filter_expression}   xpath=${xpath}     filter=${filter}
    ${bipList_length}    get length     ${bipList}
    [Return]    ${bipList_length}

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${date}=all    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}     date=${date}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Get the all PM counter value for E56002
    [Arguments]    ${counter_id}    ${dic_path}    ${date}=all    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}     date=${date}
        append to list    ${counter_value_list}    ${counter_value}
    END
    [Return]    ${counter_value_list}

Get the all PM counter value for B#2_001
    [Arguments]    ${counter_id}    ${dic_path}    ${date}=all    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}     date=${date}
        append to list    ${counter_value_list}    ${counter_value}
    END
    [Return]    ${counter_value_list}

Get the all PM counter value should be Null
    [Arguments]    ${counter_id}    ${dic_path}    ${date}=all    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}     date=${date}
        Should Be Equal As Strings    ${counter_value}    None
    END

Get the all PM counter value with lastest 2times
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        ${counter_values}    Evaluate    ${counter_value[0]}+${counter_value[1]}
        append to list    ${counter_value_list}    ${counter_values}
    END
    [Return]    ${counter_value_list}

Check counter for CB010764_gnb1_A
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ${counter_value_list}    Get the all PM counter value with lastest 2times
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}
    ${M55303C17001_PUCCH_Format3_DTX}    Set Variable    ${counter_value_list[0]}
    ${M55303C18001_PUCCH_Format3_non-DTX}    Set Variable    ${counter_value_list[1]}
    ${PUCCH_Format3_DTX_Ratio}    Evaluate
    ...       round(${${M55303C17001_PUCCH_Format3_DTX}/(${M55303C17001_PUCCH_Format3_DTX}+${M55303C18001_PUCCH_Format3_non-DTX})},9)
    [Return]     ${PUCCH_Format3_DTX_Ratio}

Check the PM counter should be matached
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    #${value}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
#	    ${counter_expected_value}    Convert To Integer    ${value[${index}]}
#	    Should contain    ${counter_value}    ${counter_expected_value}
        log to console     ${counter_value}
    END
    [Teardown]    COAM Teardown gnb connections

#Adjust the TL Topyoung attenuation value
#    [Arguments]    ${enb1_cell1_value}=${120}    ${enb1_cell2_value}=${120}    ${gnb1_cell1_value}=${120}
#    ...    ${gnb1_cell2_value}=${120}    ${gnb1_cell3_value}=${120}
#    ####create cell list#####
#    @{att_ports_enb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
#    @{att_ports_enb1_cell2}    Create List    ${att_port_1_}    ${att_port_2_}
#    ...    ${att_port_3_}    ${att_port_4_}
#    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
#    ...    ${att_port_3_}    ${att_port_4_}
#    @{att_ports_gnb1_cell2}    Create List    ${att_port_9_}    ${att_port_10_}
#    ...    ${att_port_11_}    ${att_port_12_}
#    @{att_ports_gnb1_cell3}    Create List    ${att_port_15_}    ${att_port_16_}
#    ###create value list####
#    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
#    @{values_enb1_cell2}    Create List    ${enb1_cell2_value}    ${enb1_cell2_value}    ${enb1_cell2_value}    ${enb1_cell2_value}
#    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
#    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
#    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}
#
#    ###Adjust the HBTE attenuation value###
#    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
#    ...    att_ipaddr=${att_ipaddr}
#    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell2}    values=${values_enb1_cell2}
#    ...     att_ipaddr=${att_ipaddr}
#    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
#    ...    att_ipaddr=${att_ipaddr}
#    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
#    ...     att_ipaddr=${att_ipaddr}
#    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
#    ...     att_ipaddr=${att_ipaddr}

Adjust the TL Topyoung attenuation value
    [Arguments]    ${enb1_cell1_value}=${120}    ${gnb1_cell1_value}=${120}    ${gnb1_cell2_value}=${120}    ${gnb1_cell3_value}=${120}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    ...    ${att_port_3_}    ${att_port_4_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_15_}    ${att_port_16_}
    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...     att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...     att_ipaddr=${att_ipaddr}

start DL UL
    [Arguments]        ${ue_index}=${0}     ${duration}=${duration}    #${gnb_index}=${0}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${duration}    ue_index=${ue_index}
    sleep    15s
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=${duration}    ue_index=${ue_index}

start UL
    [Arguments]        ${ue_index}=${0}     ${duration}=${duration}    #${gnb_index}=${0}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=${duration}    ue_index=${ue_index}

Check DLUL tput
    [Arguments]    ${gnb_index}=${0}    ${lcrid}=${1}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${tput_log}    power_ue.Collect Tput    duration=1m    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${dl_expect}
    power_ue.Check Tput    direction=UL    cells=${list_of_cell_ids}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${ul_expect}

UE Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}    ${abil_index}=${1}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    abil_index=${abil_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}    abil_index=${abil_index}

Prepare gnb_logs and mcshark setup
    Run     cat /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB10764.json >>/home/ute/.ssh/authorized_keys
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin
    sleep    2s
    csn.Send Command    command=scp /cygdrive/c/tool/gnb_logs.zip ute@${UTE_IP}:/home/ute    connection=cygwin
    sleep    60s
    Run     unzip -o /home/ute/gnb_logs.zip -d /home/ute
    sleep    80s
    Run     sudo chmod 777 /home/ute/gnb_logs/gnb_logs
    Run     sudo mkdir -p /opt/workspace/
    Run     sudo chmod 777 /opt/workspace/
    Run     sudo chmod 777 /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/
    Run     cp /home/ute/gnb_logs/mcshark-4.2.so /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/

Start bursty UL data transmission on Commercial with first UE
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    #${open_iperf_location}=${open_iperf_location}
    ...    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${buffer_size}=1372     ${ue_index}=${0}     ${time}=600
    ...     ${iperf_button}=${iperf_button}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Run Keyword And Ignore Error     csn.disconnect    connection=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   3s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin
    sleep   3s
    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    ...    connection=cygwin
    sleep    2s
    #####tap the spare space of magic iperf to focus on input line#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${iperf_space}    connection=cygwin
    sleep   2s
    FOR	${i}	IN RANGE	10
        Retry send command in cygwin    command=adb -s ${serial_number} shell input keyevent 67
        sleep    0.5
    END
    ${ul_cmd}    set variable
    ...  iperf\%s-c\%s${EPC_IP}\%s-u\%s-e\%s-t\%s${time}\%s-i\%s1\%s-l\%s${buffer_size}\%s--isochronous=\%s10:10m\%s--trip-times\%s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input text ${ul_cmd}
    sleep   3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input tap ${iperf_button}
    sleep   3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell ps -ef | grep -w iperf| grep -v grep|awk '{print $2}'
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}

Check csi2 dtx rate in BIP Log with mcshark
    [Documentation]    Author: jack.zeng@nokia-sbell.com
    ...                This keyword is Check IE prachPreambleIndex not exist in BIP Log with mcshark, filter uldata_prachreceiveind
    [Arguments]    ${file_path}
    #...    ${phyCellId}=${None}
    #...    ${alias}=parser
    #...    ${filter}=UlData_UePuschReceiveRespPs
    ${dtxCsiPart2_counter}    Get Item numbers From BIP Log with mcshark    file_path=${file_path}    filter_expression=!(3gpp.rnti == 65535)
    ...    filter=UlData_UePuschReceiveRespPs_t.dtxMetricCsiPart2 != 0 && UlData_UePuschReceiveRespPs_t.dtxCsiPart2 == 1
    ...    xpath=.//UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ${none_dtxCsiPart2_counter}    Get Item numbers From BIP Log with mcshark    file_path=${file_path}    filter_expression=!(3gpp.rnti == 65535)
    ...    filter=UlData_UePuschReceiveRespPs_t.dtxMetricCsiPart2 != 0 && UlData_UePuschReceiveRespPs_t.dtxCsiPart2 == 0
    ...    xpath=.//UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    #set suite variable    ${dtxCsiPart2_DTX_Ratio}     ${1}
    Should Be True    ${dtxCsiPart2_counter} >= 0
    Should Be True    ${none_dtxCsiPart2_counter} >= 0
    Set Test Variable    ${dtxCsiPart2_DTX_Ratio}    ${0}
    run keyword if    '${none_dtxCsiPart2_counter}'!='${0}'     Calculator dtxCsiPart2_DTX_Ratio
    ...   dtxCsiPart2_counter=${dtxCsiPart2_counter}     none_dtxCsiPart2_counter=${none_dtxCsiPart2_counter}
    run keyword if    '${none_dtxCsiPart2_counter}'!='${0}'
    ...   Set Test Variable    ${dtxCsiPart2_DTX_Ratio}    ${Calculator_dtxCsiPart2_DTX_Ratio}
    [Return]    ${dtxCsiPart2_DTX_Ratio}

Common commissioning for Cloud gNB
    [Timeout]    90min
    [Documentation]  common commisioning for hz test line.
    ...   Keyword depends on variables from command line, keyword will return directly without them.
    ...   Keyword supports both classical and cloud gnb.
    ...   Keyword supports both hz ci and ute cloud test line.
    ...   For test line on ute cloud, keyword will install package again if fault 23 raises.
    ...   Keyword do normal commissioning for classical bts.
    ...   Keyword do cu and du commissioning for cloud bts.
    ...   Tester needs to put SCF to scf_base_path with particular name.
    [Arguments]   ${gnb_index}=${0}    #${du_index}=${0}    ${common_unit_index}=${0}     ${connection}==du_coam
#    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#    CI_commssion.Connect To Du With F1 Or LMP    connection=${connection}    du_host=&{var_dict}[du_host]
#    ...        username=&{var_dict}[username]    password=&{var_dict}[password]
#    ${scf_path}    CI_commssion.Get SCF File Path    testline=&{var_dict}[testline]
#    ...    stream=&{var_dict}[stream]  gnb_type=&{var_dict}[gnb_type]    cu_or_du=DU    gnb_index=${gnb_index}
    ${scf_path}    CI_commssion.Get SCF File Path    testline=7_5_UTE5G402T384
    ...    stream=SBTS00   gnb_type=ClassicalBts    cu_or_du=DU    gnb_index=${gnb_index}
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    scf_path=${scf_path}
    ...    ParamterToModify=${CB010764_E_ParamterToModify}    ParameterToDelete=${CB010764_E_ParamterToDelete}
    ...    MOsToAdd=${CB010764_E_MOsToAdd}

Check counter for CB010764_gnb1_UL_RIP_scheduled_PRB
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_2001}    dic_path=${counter_dic_path_B_2001}
    [Return]    ${counter_value_list}

Check noisepowerLinear_value and prach_PRB_number
    [Arguments]    ${noisepowerLinear_value}     ${prach_PRB_number}
    ${noisepowerlenth}    Get Length    ${noisepowerLinear_value}
    ${aW_value_list}    create list
    FOR    ${index}    IN RANGE    ${noisepowerlenth}
            ${aW_value}    Evaluate
    ...       round(${${noisepowerLinear_value[${index}]}/${prach_PRB_number}},2)
            ${result_value}    convert_aW_to_dBm    aW=${aW_value}
            Should Be True     ${result_value} < -100
            append to list    ${aW_value_list}    ${result_value}
    END
    Sort List      ${aW_value_list}
    [Return]    ${aW_value_list[-1]}

Update the swconfig file classical gNB
    [Arguments]    ${localFilePath}=${localFilePath}   ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master with gnbindex   gnb_index=${gnb_index}    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}    ${release_info.split('_')[0]}
    [Return]    ${release_info}

Collect Biplog on WEBUI
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: Collect biplog on webui for 10764
    [Arguments]     ${target_dir}    ${target_file_name}=l1l2bip_log     ${Capture_bip_time}=2s    ${nr_phy_cell_ids}=None
    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}    times=${Capture_bip_time}
    ...                                                      target_file_name=${target_file_name}
    ...                                                      nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep     15s
    ${biplog_path}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}
    ...                                                                       target_file_name=${target_file_name}
    [Return]    ${biplog_path}[0]

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=True     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=1
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.75      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

#Adjust PA step by step
#    [Arguments]        ${start_value}    ${step}     ${target_value}
#    ...    ${enb1_cell1_value}=${120}    ${enb1_cell2_value}=${120}    ${gnb1_cell1_value}=${120}
#    ...    ${gnb1_cell2_value}=${120}    ${gnb1_cell3_value}=${120}     ${sleep}=${2}
#    ${step_value}    Evaluate    float((${target_value}-${start_value})/${step})
#    Adjust the TL Topyoung attenuation value    enb1_cell1_value=${enb1_cell1_value}
#    ...    enb1_cell2_value=${enb1_cell2_value}    gnb1_cell1_value=${gnb1_cell1_value}
#    ...    gnb1_cell2_value=${gnb1_cell2_value}    gnb1_cell3_value=${gnb1_cell3_value}
#    FOR  ${index}    IN RANGE    ${0}     ${step}+${1}      1
#         ${index} =    evaluate    abs(${index})
#         ${pa_value} =    evaluate    int(${start_value}+${step_value}*${index})
#         run keyword if  '${gnb1_cell1_value}'!='${120}'    Set Test Variable    ${gnb1_cell1_value}    ${pa_value}
#         run keyword if  '${gnb1_cell2_value}'!='${120}'    Set Test Variable    ${gnb1_cell2_value}    ${pa_value}
#         run keyword if  '${gnb1_cell3_value}'!='${120}'    Set Test Variable    ${gnb1_cell3_value}    ${pa_value}
#         Adjust the TL Topyoung attenuation value    enb1_cell1_value=${enb1_cell1_value}
#         ...    enb1_cell2_value=${enb1_cell2_value}    gnb1_cell1_value=${gnb1_cell1_value}
#         ...    gnb1_cell2_value=${gnb1_cell2_value}    gnb1_cell3_value=${gnb1_cell3_value}
#         sleep    ${sleep}s
#    END

Adjust PA step by step
    [Arguments]        ${start_value}    ${step}     ${target_value}
    ...    ${enb1_cell1_value}=${120}    ${gnb1_cell1_value}=${120}
    ...    ${gnb1_cell2_value}=${120}    ${gnb1_cell3_value}=${120}     ${sleep}=${2}
    ${step_value}    Evaluate    float((${target_value}-${start_value})/${step})
    Adjust the TL Topyoung attenuation value    enb1_cell1_value=${enb1_cell1_value}
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}    gnb1_cell3_value=${gnb1_cell3_value}
    FOR  ${index}    IN RANGE    ${0}     ${step}+${1}      1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    int(${start_value}+${step_value}*${index})
         run keyword if  '${gnb1_cell1_value}'!='${120}'    Set Test Variable    ${gnb1_cell1_value}    ${pa_value}
         run keyword if  '${gnb1_cell2_value}'!='${120}'    Set Test Variable    ${gnb1_cell2_value}    ${pa_value}
         run keyword if  '${gnb1_cell3_value}'!='${120}'    Set Test Variable    ${gnb1_cell3_value}    ${pa_value}
         Adjust the TL Topyoung attenuation value    enb1_cell1_value=${enb1_cell1_value}
         ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}    gnb1_cell3_value=${gnb1_cell3_value}
         sleep    ${sleep}s
    END

Prepare UEs in airplane mode
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S21UI3.1
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

SUITE SETUP FOR UTE
    [Documentation]    only used for cloud ute case
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Prepare mcshark setup
#    set suite variable    ${epc_log_path}    ${TS_CASE_LOG_PATH}
#    set suite variable    ${TS_LOG_PATH_BASE}     ${TS_CASE_LOG_PATH}
    set suite variable    ${epc_log_path}    ${SUITE_LOG_PATH}
    set suite variable    ${TS_LOG_PATH_BASE}     ${SUITE_LOG_PATH}
    Prepare UEs in airplane mode

Prepare mcshark setup
    Run     cat /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB10764.json >>/home/ute/.ssh/authorized_keys
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin
    sleep    2s
    csn.Send Command    command=scp /cygdrive/c/tool/mcshark-4.2.so ute@${UTE_IP}:/home/ute    connection=cygwin
    sleep    10s
    Run     sudo chmod 777 /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/
    Run     cp /home/ute/mcshark-4.2.so /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/


Calculator dtxCsiPart2_DTX_Ratio
    [Arguments]    ${dtxCsiPart2_counter}    ${none_dtxCsiPart2_counter}
    ${dtxCsiPart2_DTX_Ratio_value}    Evaluate
    ...       round(${${dtxCsiPart2_counter}/(${dtxCsiPart2_counter}+${none_dtxCsiPart2_counter})},9)
    Set Test Variable    ${Calculator_dtxCsiPart2_DTX_Ratio}    ${dtxCsiPart2_DTX_Ratio_value}
    [Return]    ${Calculator_dtxCsiPart2_DTX_Ratio}

#Adjust the HBTE attenuation value
#    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}
#    ...    ${enb_cell1_value}=${127}
#
#    ####create cell list#####
#    @{att_ports_gnb_cell1}    Create List    ${att_port_13_cell1_${tl}}      ${att_port_14_cell1_${tl}}
#    @{att_ports_gnb_cell3}    Create List    ${att_port_15_cell3_${tl}}      ${att_port_16_cell3_${tl}}    #share with lte
#    @{att_ports_enb_cell1}    Create List    ${att_port_7_ENBcell1_${tl}}
#    ###create value list####
#    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}
#    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}
#    @{values_enb_cell1}    Create List    ${enb_cell1_value}
#    ###Adjust the HBTE attenuation value###
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
#     Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}

Adjust the HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}
    ...    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}

    ####create cell list#####
    @{att_ports_gnb_cell1}    Create List    ${att_port_1_cell1_${tl}}      ${att_port_2_cell1_${tl}}
    ...                                      ${att_port_3_cell1_${tl}}      ${att_port_4_cell1_${tl}}
    @{att_ports_gnb_cell3}    Create List    ${att_port_5_cell3_${tl}}      ${att_port_6_cell3_${tl}}
    ...                                      ${att_port_7_cell3_${tl}}      ${att_port_8_cell3_${tl}}
    @{att_ports_enb1_cell1}    Create List    ${att_port_9_ENB1cell1_${tl}}    ${att_port_10_ENB1cell1_${tl}}
    @{att_ports_enb2_cell1}    Create List    ${att_port11_ENB2cell1_${tl}}    ${att_port_12_ENB2cell1_${tl}}
    ###create value list####
    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}