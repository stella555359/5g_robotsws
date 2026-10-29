*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008200
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
#Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/ssh_pcf.py
#Library     ssh_pcf.pcf   WITH NAME    PCF
Library     taf.pdu  WITH NAME   pdu
#Variables   ../Resources/CB008200_variables.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/PCF_sim.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py

*** Variables ***
${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
${testline_name}      null
${CONFIGURATION}      null
${tl_scf_file_name3}    SCF_SBTS00.xml

${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${tl_scf_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_0000}    25R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R1_ENB_0000}    25R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R3_ENB_0000}    24R3_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_0000}    24R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R4_ENB_0000}    Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R3_ENB_0000}    Configuration_scf_GNB1_CB008698.xml

${tl_scf_EDA_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS24R3_ENB_9999}    Trunk_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS25R2_ENB_0000}    Trunk_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS24R3_ENB_0000}    Trunk_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS23R4_ENB_0000}    Configuration_scf_GNB1_EDA.xml
${tl_scf_EDA_SBTS23R3_ENB_0000}    Configuration_scf_GNB1_EDA.xml

${tl_scf2_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_0000}    25R2_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R1_ENB_0000}    25R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R3_ENB_0000}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R4_ENB_0000}    Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R3_ENB_0000}    Configuration_scf_GNB2_CB008698.xml

#${tl_scf_dir_path_golden}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
#${tl_scf_file_name1_golden}    Configuration_scf_GNB1_CB008698.xml
#${tl_scf_file_name2_golden}    Configuration_scf_GNB2_CB008698.xml
#${tl_scf_file_name1}    Configuration_scf_GNB1_CB008200.xml
#${tl_scf_file_name2}    Configuration_scf_GNB2_CB008200.xml
${gnb_path}    /tmp/
${connection}    gnb
${epc_log_path}    /tmp/
${tshark_path}      /usr/bin/tshark
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
#${att_ipaddr}      ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.attenuator.attenuation_port_numbers}
#${att_api_port}              ${tl.attenuator.port}
#${vendor}                    ${tl.attenuators}
${vendor}                    HBTE
${max_attenuation_value}     ${127}


${att_api_ports}    ${tl.attenuator[0].port}
#${vendor}                    ${tl.attenuator[0].vendor}
#${max_attenuation_value}      ${127}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_10}               ${tl.attenuator[0].attenuator_ports[2]}
${atten_ip}                  ${tl.attenuator[0].ip_addr}
${SN}                       ${tl.ues[0].serial_number}
${ue_types}                  ${tl.ues[0].capabilities[0]}

@{Xpath}        .//ngap.emergencyFallbackRequestIndicator
        ...     .//ngap.emergencyServiceTargetCN
        ...     .//ngap.UEContextModificationResponse_element//ngap.protocolIEs
        ...     .//ngap.UEContextReleaseRequest_element//ngap.radioNetwork
        ...     .//ngap.UEContextReleaseCommand_element//ngap.radioNetwork
        ...     .//ngap.UEContextModificationFailure_element//ngap.protocolIEs
        ...     .//ngap.UEContextModificationFailure_element//ngap.radioNetwork
        ...     .//ngap.InitialContextSetupFailure_element//ngap.protocolIEs

${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml

${new_ims}    46002
${ims}    310260
${PCF_IP}    ${tl.core[2].pcf.oam_ssh_connection_details.addr}
${PCF_username}    ${tl.core[2].pcf.oam_ssh_connection_details.username}
${PCF_password}    ${tl.core[2].pcf.oam_ssh_connection_details.password}
${ALIAS_PCF}    PCF
${five_qi}    1
${priorityLevel_1}    3
${priorityLevel_2}    2
####due to there is one iperf server ip in TL init file, so need to define 2 IPs to test
${server_ip1}    10.57.240.20
${server_ip2}    10.57.240.21


${ru_pdu_ip}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${ru_pdu_port}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
@{enb_id}    342    34441    4226    241    383    911    358    36721
@{pci_id}    342    120    352

@{cell_id1}    481    483
@{cell_id2}    38    383
@{cell_id3}    38    383

${HBTE_max_value}           ${120}

${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_911}     ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_911}     ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_911}     ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_911}     ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_911}     ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_911}     ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_911}     ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_911}     ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_38221}     ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_38221}     ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_38221}     ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_38221}     ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_38221}     ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_38221}     ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_38221}     ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_38221}     ${tl.attenuator[0].attenuator_ports[16]}
@{diffTL_enb_ID}    36721    38221    911
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
@{branch}    SBTS23R3_ENB_0000    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000

*** Keywords ***
###attenuator###
#Setup Variable for attenuator
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0] or ${enb_instance} == @{enb_id}[1] or ${enb_instance} == @{enb_id}[2]
#    ...    Setup Variables for attenuator
#    ...    ELSE    Setup Variables for attenuator with multi cell
#
#Setup Variables for attenuator
#    Set Suite Variable    ${att_ipaddr}    ${tl.attenuator.ip_addr}
#    Set Suite Variable    ${att_api_port}    ${tl.attenuator.port}
#
#Setup Variables for attenuator with multi cell
#    Set Suite Variable    ${att_ipaddr}    ${tl.attenuator[0].ip_addr}
#    Set Suite Variable    ${att_api_port}    ${tl.attenuator[0].port}
#
#PA one cell 0 on and set other cell value
#    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${5}
#    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
#    FOR  ${index}    IN RANGE    ${total_cell}
#        ${cellnum} =    evaluate    ${index}+1
#        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
#    END
#    Change Attenuation value    cell=4Gcell1    value=${127}
#
##PA one cell 0 on and set other cell value
##    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${5}    ${cell_type}=SA
##    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
##    FOR  ${index}    IN RANGE    ${total_cell}
##        ${cellnum} =    evaluate    ${index}+1
##        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
##    END
##    run keyword if    '${cell_type}'=='NSA'    run keywords
##    ...    Change Attenuation value    cell=4Gcell2    value=${0}    AND
##    ...    Change Attenuation value    cell=4Gcell1    value=${127}
##    run keyword if    '${cell_type}'=='SA'    run keywords
##    ...    Change Attenuation value    cell=4Gcell1    value=${127}    AND
##    ...    Change Attenuation value    cell=4Gcell2    value=${127}
#
#Change Attenuation value
#    [Arguments]    ${cell}    ${value}
#    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
#    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
#
#Change Attenuation value 4 port
#    [Arguments]    ${cell}    ${value}
#    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
#    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
#    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
#    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}
#
#Set the Attenuation Value
#    [Arguments]    ${ports}    ${value}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${ports}    value=${value}
#
#Set HBTE attenuation
#    [Arguments]    ${port1}=${5Gcell1_ANT1}    ${port2}=${5Gcell1_ANT2}    ${port3}=${5Gcell1_ANT3}
#    ...    ${port4}=${5Gcell1_ANT4}    ${origin_value}=${0}    ${target_value}=${50}
#    add attenuation for 1db 4 port    port1=${port1}    port2=${port2}
#    ...    port3=${port3}    port4=${port4}    origin_value=${origin_value}    target_value=${target_value}
#
#add attenuation for 1db 4 port
#    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${origin_value}    ${target_value}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${port1}    value=${origin_value}
#    atten.set_attenuation     port=${port2}    value=${origin_value}
#    atten.set_attenuation     port=${port3}    value=${origin_value}
#    atten.set_attenuation     port=${port4}    value=${origin_value}
#    FOR  ${origin_value}    IN RANGE    ${target_value}
#       ${origin_value}    evaluate     ${origin_value}+1
#       atten.set_attenuation     port=${port1}    value=${origin_value}
#       atten.set_attenuation     port=${port2}    value=${origin_value}
#       atten.set_attenuation     port=${port3}    value=${origin_value}
#       atten.set_attenuation     port=${port4}    value=${origin_value}
#       sleep    1s
#    END
#
#Set HBTE attenuation decrease
#    [Arguments]    ${port1}=${5Gcell1_ANT1}    ${port2}=${5Gcell1_ANT2}    ${port3}=${5Gcell1_ANT3}
#    ...    ${port4}=${5Gcell1_ANT4}    ${origin_value}=${50}    ${target_value}=${0}
#    decrease attenuation for 1db 4 port    port1=${port1}    port2=${port2}
#    ...    port3=${port3}    port4=${port4}    origin_value=${origin_value}    target_value=${target_value}
#
#decrease attenuation for 1db 4 port
#    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${origin_value}    ${target_value}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${port1}    value=${origin_value}
#    atten.set_attenuation     port=${port2}    value=${origin_value}
#    atten.set_attenuation     port=${port3}    value=${origin_value}
#    atten.set_attenuation     port=${port4}    value=${origin_value}
#    FOR  ${origin_value}    IN RANGE    ${target_value}
#       ${origin_value}    evaluate     ${origin_value}-1
#       atten.set_attenuation     port=${port1}    value=${origin_value}
#       atten.set_attenuation     port=${port2}    value=${origin_value}
#       atten.set_attenuation     port=${port3}    value=${origin_value}
#       atten.set_attenuation     port=${port4}    value=${origin_value}
#       sleep    1s
#    END
#
#add attenuation for 1db
#    [Arguments]    ${port1}    ${port2}    ${origin_value}    ${target_value}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${port1}    value=${origin_value}
#    atten.set_attenuation     port=${port2}    value=${origin_value}
#    FOR  ${origin_value}    IN RANGE    ${target_value}
#       ${origin_value}    evaluate     ${origin_value}+1
#       atten.set_attenuation     port=${port1}    value=${origin_value}
#       atten.set_attenuation     port=${port2}    value=${origin_value}
#       sleep    1s
#    END

#Adjust Attenuation to expect value
#    [Arguments]    ${port1}    ${port2}    ${value}    ${att_ipaddr}=${att_ipaddr}    ${att_api_port}=${att_api_port}
#    ...    ${att_connection_port}=${att_connection_port}    ${max_attenuation_value}=${max_attenuation_value}
#    ...    ${vendor}=${vendor}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
##    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${port1}    value=${value}
#    atten.set_attenuation     port=${port2}    value=${value}
#    ${value_port1}    att.read_attenuation    port=${att_port1}
#    should be equal    ${value_port1}    ${value}
#    ${value_port2}    att.read_attenuation    port=${att_port1}
#    should be equal    ${value_port2}    ${value}
#
#adjust HBTE attenuation
#    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_1}
#    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
#    ...    ${att_ipaddr}=${att_ipaddr}    ${att_api_port}=${att_api_port}
##    ...    ${att_connection_port}=${att_connection_port}    ${max_attenuation_value}=${max_attenuation_value}
##    ...    ${vendor}=${vendor}
#    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
##    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    atten.set_attenuation     port=${att_port1}    value=${value_1}
#    atten.set_attenuation     port=${att_port2}    value=${value_2}
#    atten.set_attenuation     port=${att_port3}    value=${value_3}
#    atten.set_attenuation     port=${att_port4}    value=${value_4}
#    ${value_port1}    att.read_attenuation    port=${att_port1}
#    should be equal    ${value_port1}    ${value_1}
#    ${value_port2}    att.read_attenuation    port=${att_port2}
#    should be equal    ${value_port2}    ${value_2}
#    ${value_port3}    att.read_attenuation    port=${att_port3}
#    should be equal    ${value_port3}    ${value_3}
#    ${value_port4}    att.read_attenuation    port=${att_port4}
#    should be equal    ${value_port4}    ${value_4}

#Set HBTE attenuation to trigger RLF
#    Change Attenuation value 4 port    cell=5Gcell1    value=${127}
#
#Recover HBTE attenuation to trigger RLF
#    Change Attenuation value 4 port    cell=5Gcell1    value=${0}
#
#Set attenuation to trigger
#    Change Attenuation value    cell=5Gcell1    value=${127}
#
#Recover attenuation to trigger
#    Change Attenuation value    cell=5Gcell1    value=${0}
#
#Recover attenuation to trigger for 8200E001
#    Run keyword if    '${enb_instance}'=='${911}'    Change Attenuation value for 343 Cell1    cell=5Gcell1    value=${0}
#    ...    ELSE    Change Attenuation value    cell=5Gcell1    value=${0}
#
#Repeat set HBTE attenuation
#    Set HBTE attenuation
#    Set HBTE attenuation decrease
#    check voice call status    status=${2}
#    sleep    1m

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Run Keyword If     '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE IF     '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[2]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE IF     '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[2]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${tl}=${tl}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_${tl}}     ${att_port_2_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_${tl}}     ${att_port_4_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_${tl}}     ${att_port_6_${tl}}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_${tl}}     ${att_port_8_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}

###BTS keyword###
Setup Variable for cellID
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[3]
    ...    Set Variable for 348 cell
    ...    ELSE IF    ${enb_instance} == ${enb_id}[4]
    ...    Set Variable for 383 cell
    ...    ELSE IF    ${enb_instance} == ${enb_id}[6]
    ...    Set Variable for 358 cell

Set Variable for 348 cell
    Set Suite Variable    ${cell1_id}    ${cell_id1}[0]
    Set Suite Variable    ${cell2_id}    ${cell_id1}[1]

Set Variable for 383 cell
    Set Suite Variable    ${cell1_id}    ${cell_id2}[0]
    Set Suite Variable    ${cell2_id}    ${cell_id2}[1]

Set Variable for 358 cell
    Set Suite Variable    ${cell1_id}    ${cell_id3}[0]
    Set Suite Variable    ${cell2_id}    ${cell_id3}[1]

Pre Condition with ute cloud
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAMEs}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAMEs}[0]
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[1]    Default directory with ute cloud

Default directory with ute cloud
    Set Suite Variable    ${epc_log_path}    ${TS_CASE_LOG_PATH_cloud}
    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    CI_interface.Common Suite Setup

Setup Env for test for cell on air
    Common Case TestLine Setup    is_commission=True    scf_path=${tl_scf_dir_path_golden}
    ...    golden_scf_name=${tl_scf_file_name1_golden}

Setup Env for test
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[0] or ${enb_instance} == ${enb_id}[2]
    ...    Setup for Env cell on-air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name1}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[3] or ${enb_instance} == ${enb_id}[4] or ${enb_instance} == ${enb_id}[6]
    ...    Setup for Env cell on-air for 2 gnb
    ...    ELSE IF    ${enb_instance} == ${enb_id}[1]
    ...    CI_interface.Common Suite Setup

Setup for Env cell on-air for 2 gnb
    Setup for Env cell on-air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name1}
    Setup for Env cell on-air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_name2}

Setup for Env cell on-air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
    should be equal    '${cell_status}'    'True'

Lock cells for test
    Lock cell online coam    gnb_index=${0}    cell_index=${2}
    Lock cell online coam    gnb_index=${1}    cell_index=${1}

Unlock cells for test
    Unlock cell online coam    gnb_index=${0}    cell_index=${2}
    Unlock cell online coam    gnb_index=${1}    cell_index=${1}

Lock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    coam.lock_cell
    coam.lock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Unlock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    coam.unlock_cell
    coam.unlock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Lock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.lock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
#    coam.lock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Unlock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
    coam.unlock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
#    coam.unlock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.teardown    connection=gnb2

Lock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
#    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Unlock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
    coam.unlock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
#    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl    bts_host=${asik2_addr}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Save snapshot Teardown
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}    connection=${connection}
    COAM Save snapshot via rest api    log_path=${epc_log_path}    connection=${connection}
    COAM Teardown gnb connections    connection=${connection}

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}    timeout=${timeout}
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




###enb parameter
Modify parameter on enb
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify the enblte parameter    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb MME IP
    [Arguments]    ${dist_name}=${enb_dist_name}[1]    ${parameter}=${enb_para}[1]    ${value}=${enb_value}[2]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

###UE keywordWords###
Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

Step2: UE setup VoNR call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: Samsung UE setup VoNR call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a Samsung VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: UE setup EMC call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    Make EMC call on UE    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step3: UE hang up VoNR call
    [Arguments]    ${ue_index}=${0}
    hang up VoNR call    ue_index=${ue_index}

Step3: Samsung UE hang up VoNR call
    [Arguments]    ${ue_index}=${0}
    hang up VoNR call    ue_index=${ue_index}

Step3: UE hang up EMC call
    [Arguments]    ${ue_index}=${0}
    hang up EMC call    ue_index=${ue_index}

Step4: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
#    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}
#    Setup Variable for attenuator
#    Setup Variable for cellID

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make a Samsung VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
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
    #####Samsung S21/S23 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:00${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   10s
    #####Samsung S23 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin${ue_index}
    sleep    2s
    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make EMC call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    look_for_keys=False
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    look_for_keys=False
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    look_for_keys=False
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=${status}




###check wireshark log###
Check attach successful message
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code14_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log To Console    check InitialContextSetupRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code14_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    run keyword if    ${5qi[0]} == 5 or ${5qi[0]} == 7
    ...    Set Suite Variable    ${var}    true
    ...    ELSE    Set Suite Variable    ${var}    false
    should be equal    ${var}    true
    ${Code29_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 29
    Log To Console    check PDUSessionResourceSetupRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code29_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    run keyword if    ${5qi[0]} == 5 or ${5qi[0]} == 7
    ...    Set Suite Variable    ${var}    true
    ...    ELSE    Set Suite Variable    ${var}    false
    should be equal    ${var}    true

Check VoNR success message
    [Arguments]    ${logname}
    Check wireshark log for PDUSessionResourceModifyRequest ok    logname=${logname}
    Check wireshark log for PDUSessionResourceModifyResponse ok    logname=${logname}

Check wireshark log for PDUSessionResourceModifyRequest ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code26_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${5qi[0]}    1

Check wireshark log for PDUSessionResourceModifyResponse ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${criticality} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${criticality[0]}    0

#    Check EIAP log name    logname=${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check RRCreconfigurecomplete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    ${criticality} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.criticality
    Should Be Equal    ${criticality[0]}    1

Check VoNR release success message
    [Arguments]    ${logname}
    Analysis wireshark log for VoNR success release    logname=${logname}

Analysis wireshark log for VoNR success release
     [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_nas} =    get_field_value_by_xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_id} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${ngap_id[0]}    0

Check EIAP log name
    [Arguments]  ${logname}
    ${logname}=    Catenate    ${E1AP}    ${logname}
    [return]    ${logname}

Check EPSFB message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EPSFB mesage on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

check into idle status
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code42_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
    Log To Console    check UEContextReleaseRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code42_0}    pcap_parser=test6
    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    20
    ${Code41_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
    Log To Console    check UEContextReleaseCommand
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code41_0}    pcap_parser=test6
    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    20

Check idle EMC fallback message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code14_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log    check InitialContextSetupRequest
    ${Code14_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code14_0}    pcap_parser=test6
    should be equal    ${Code14_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code14_0}    pcap_parser=test6
    ${ngap_fiveQI} =    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should contain    ${ngap_fiveQI}    5
    should contain    ${ngap_fiveQI}    1

    ${Code14_2} =    Catenate    ngap.NGAP_PDU == 2 and ngap.procedureCode == 14
    Log    check InitialContextSetupFailure
    ${Code14_2_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code14_2}    pcap_parser=test6
    should be equal    ${Code14_2_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code14_2}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

Check EMC fallback message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EMC fallback message on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

Check invalid QoS Combination message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    23

Convert to string and check with diff tl
    [Arguments]    ${wireshark_id}    ${pci_id}
    ${release_enb_id}    Convert To String    ${pci_id}
    Should Be Equal    ${wireshark_id}    ${release_enb_id}

Check QosFlow Release message with redirection
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${Measurement_Report} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check Measurement Report
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Measurement_Report}
    ${nr_rrc_physCellId} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.physCellId
    Run Keyword If    ${enb_instance} == '${enb_id}[0]'
    ...    Convert to string and check with diff tl    wireshark_id=${nr_rrc_physCellId[0]}    pci_id=${pci_id}[0]
    ...    ELSE IF    ${enb_instance} == '${enb_id}[1]'
    ...    Convert to string and check with diff tl    wireshark_id=${nr_rrc_physCellId[0]}    pci_id=${pci_id}[1]
    ...    ELSE IF    ${enb_instance} == '${enb_id}[2]'
    ...    Convert to string and check with diff tl    wireshark_id=${nr_rrc_physCellId[0]}    pci_id=${pci_id}[2]

    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${UEContextReleaseRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${UEContextReleaseRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextReleaseRequest}    pcap_parser=test6
    should be equal    ${UEContextReleaseRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${UEContextReleaseRequest}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    41

Check QosFlow Release message with redirection on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    Log    check InitialUEMessage/Tracking area update request
    ${tau_request_filter}    Catenate     s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    ${tau_request_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${tau_request_filter}    pcap_parser=test6
    should be equal    ${tau_request_status}    ${True}
    Log    check InitialContextSetupRequest/Tracking area update accept
    ${tau_accept_filter}    Catenate     s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    ${tau_accept_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${tau_accept_filter}    pcap_parser=test6
    should be equal    ${tau_accept_status}    ${True}
    Log    check UplinkNASTransport/Tracking area update complete
    ${tau_complete_filter}    Catenate     s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13
    ${tau_complete_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${tau_complete_filter}    pcap_parser=test6
    should be equal    ${tau_complete_status}    ${True}
    Log    check E-RABModificationIndication
    ${RABModificationIndication_filter}    Catenate     s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 50
    ${RABModificationIndication_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${RABModificationIndication_filter}
    ${s1ap_e_RAB_ID}=     cap.get_field_value_by_xpath    pdml_list=${RABModificationIndication_packets}
    ...                                                xpath=.//s1ap.e_RAB_ID
    should not be empty    ${s1ap_e_RAB_ID}
    Log    check E-RABModificationConfirm
    ${RABModificationConfirm_filter}    Catenate     s1ap.S1AP_PDU == 1 and s1ap.procedureCode == 50
    ${RABModificationConfirm_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${RABModificationConfirm_filter}
    ${s1ap_e_RAB_ID}=     cap.get_field_value_by_xpath    pdml_list=${RABModificationConfirm_packets}
    ...                                                xpath=.//s1ap.e_RAB_ID
    should not be empty    ${s1ap_e_RAB_ID}

Check VoNR call failed message with unspecified
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${UEContextModificationRequired} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 8
    Log To Console    check UEContextModificationRequired
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${UEContextModificationRequired}
    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.radioNetwork
    Should Be Equal    ${f1ap_radioNetwork[0]}    12

    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${UEContextReleaseRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${UEContextReleaseRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextReleaseRequest}    pcap_parser=test6
    should be equal    ${UEContextReleaseRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${UEContextReleaseRequest}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    0

check message with B2 event of Inter_RAT HO
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6

    ${HO_req_filter}=    Catenate    ngap.procedureCode == 12 and ngap.radioNetwork == 17
    ####    2011/11/11 22R4/23R1/TRUNK are the same filter
#    ${HO_req_filter}=     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Catenate
#    ...    ngap.procedureCode == 12 and ngap.radioNetwork == 32
#    ...    ELSE     Catenate    ngap.procedureCode == 12 and ngap.radioNetwork == 17
    ####    2022/10/18 PR671279 change meaasge HandoverRequired "radio Network" from radioNetwork: ng-inter-system-handover-triggered (32)
    ####    to radioNetwork: time-critical-handover (17)
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.HandoverType    pcap_parser=test6
    should contain    ${HO_req}    1
    ${HO_res_filter}=     Catenate    ngap.procedureCode == 12 and ip.dst == ${asik_addr}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//ngap.HandoverType    pcap_parser=test6
    should contain    ${HO_res}    1
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ip.dst == ${asik_addr}
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    should contain    ${UE_rel}    41
    ${UE_rel_com_filter}=     Catenate    ngap.procedureCode == 41 and ip.src == ${asik_addr}
    ${UE_rel_com_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UE_rel_com_filter}    pcap_parser=test6
    ${UE_rel_com}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    should contain    ${UE_rel_com}    41

check message with B2 event of Inter_RAT HO on enb
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${HO_req_filter}=     Catenate    s1ap.procedureCode == 1 and ip.dst == ${enb_address}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//s1ap.radioNetwork    pcap_parser=test6
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    should contain    ${HO_req}    18
#    ...    ELSE    should contain    ${HO_req}    17
    ####    2022/10/18 PR671279 change meaasge HandoverRequired "radio Network" from radioNetwork: ng-inter-system-handover-triggered (32)
    ####    to radioNetwork: time-critical-handover (17)
    ####    2011/11/11 22R4/23R1/TRUNK are the same filter
    should contain    ${HO_req}    17
    ${HO_res_filter}=     Catenate    s1ap.procedureCode == 1 and ip.src == ${enb_address}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//s1ap.procedureCode    pcap_parser=test6
    should contain    ${HO_res}    1
    ${notify_filter}=     Catenate    s1ap.procedureCode == 2
    ${notify_packets}=    cap.filter_packets_by_expression    filter_expression=${notify_filter}    pcap_parser=test6
    ${notify}=     cap.get_field_value_by_xpath    xpath=.//s1ap.procedureCode    pcap_parser=test6
    should contain    ${notify}    2
    ${DL_accept_filter}=     Catenate    s1ap.procedureCode == 11 and s1ap.id == 124
    ${DL_accept_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${DL_accept_filter}    pcap_parser=test6
    ${DL_accept}=     cap.get_field_value_by_xpath    xpath=.//s1ap.id    pcap_parser=test6
    should contain    ${DL_accept}    124
    ${ul_update_filter}=     Catenate    s1ap.procedureCode == 13
    ${ul_update_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${ul_update_filter}    pcap_parser=test6
#    ${ul_update}=     cap.get_field_value_by_xpath    xpath=.//nas_eps.nas_msg_emm_type    pcap_parser=test6
    ${ul_update}=     cap.get_field_value_by_xpath    xpath=.//nas-eps.nas_msg_emm_type    pcap_parser=test6
#    should contain    ${ul_update}    74
    should contain    ${ul_update}    0x4a

Check VoNR call success message with intra gnb HO
    [Arguments]    ${logname}    ${event_ID}=2
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${measurement_filter}    Catenate     f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell1_id}
    ${measurement_packets}    cap.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     cap.get_field_value_by_xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7  and nr-rrc.eventId == ${event_ID} and  nr-rrc.physCellId == ${cell1_id}
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventIds}=    cap.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.eventId
    should not be empty    ${eventIds}
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    cap.get_field_value_by_xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should be equal    ${UeModify_res[0]}    7
    ${RRC_reconfig_filter}    Catenate    f1ap.procedureCode == 12
    ${RRC_reconfig_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_reconfig_filter}
    ${RRC_reconfig}    cap.get_field_value_by_xpath    pdml_list=${RRC_reconfig_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should be equal    ${RRC_reconfig[0]}    ${cell2_id}
    ${RRC_re_complete_filter}    Catenate    f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier == 2
    ${RRC_re_complete_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_re_complete_filter}
    ${RRC_re_complete}    cap.get_field_value_by_xpath    pdml_list=${RRC_re_complete_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should be equal    ${RRC_re_complete[0]}    13

Check VoNR call success message with inter gnb HO source
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}
    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_req}    0
    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik2_addr}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}
    ${HO_res}=     cap.get_field_value_by_xpath    pdml_list=${HO_res_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_res}    0
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

Check VoNR call success message with inter gnb HO target
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}
    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_req}    0
    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik2_addr}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}
    ${HO_res}=     cap.get_field_value_by_xpath    pdml_list=${HO_res_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_res}    0
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik2_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_req_filter}
    ${PathS_req}=     cap.get_field_value_by_xpath    pdml_list=${PathS_req_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_req}    25
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik2_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_ACK_filter}
    ${PathS_ACK}=     cap.get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_ACK}    25
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

Check VoNR call success message with intra gnb re-establish
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${RRC_Reestablishment_Req_filter}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11
    ${RRC_Reestablishment_Req_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reestablishment_Req_filter}
    ${RRC_Reestablishment_Req}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Reestablishment_Req_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should contain    ${RRC_Reestablishment_Req}    ${cell1_id}

    #####RRC Reestablishment MAC=0xd5c7b0db
    ${Reestablishment} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check Reestablishment
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Reestablishment}
    ${nr_rrc_criticalExtensions} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.criticalExtensions
    Should Be Equal    ${nr_rrc_criticalExtensions[0]}    0

    ${UEContextModificationRequired} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 8
    Log To Console    check UEContextModificationRequired
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${UEContextModificationRequired}
    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.radioNetwork
    Should Be Equal    ${f1ap_radioNetwork[0]}    12

    #####RRC Reestablishment Complete MAC=0xd6dc9cb9
    ${Reestablishment_Complete} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check Reestablishment Complete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Reestablishment_Complete}
    ${nr_rrc_criticalExtensions} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.criticalExtensions
    Should Be Equal    ${nr_rrc_criticalExtensions[0]}    0

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check UEContextModificationRequired
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    ${e1ap_dRB_ID} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    ${length_drb_id}    Get Length    ${e1ap_dRB_ID}
    ${drb_id}    Evaluate    ${length_drb_id}%3
    ${string_drb_id}    Convert To String    ${drb_id}
    Should Be Equal    ${string_drb_id}    0

Check IE wireshark log for radioNetwork cause
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_with_Y}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}
    ${filtered_value}=     cap.Get Field Value By Xpath    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}





Check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    should be equal    ${ngap_nas[0]}    0

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    1

Check IE wireshark log for RLF
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}     alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_cause}=     cap.Get Field Value By Xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    should be equal    ${f1ap_cause[0]}    12

Check IE wireshark log for VONR attach
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${value}   ${value1}
    Check IE wireshark log for VONR attach_5QI5    logname=${logname}    message_filter=${message_filter}     value=${value}
    Check IE wireshark log for VONR attach_5QI7    logname=${logname}    message_filter=${message_filter1}    value=${value1}

Check IE wireshark log for VONR attach_5QI5
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    ${value}

Check IE wireshark log for VONR attach_5QI7
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    ${value}

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    evaluate  float(${time2})-float(${time1})
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    @{frame_time}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch     pcap_parser=test6
    #    ${timelist} =   Evaluate    ${frame_time}[${index}].split('|')
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
#    ${timestamp} =     Caculate the wireshark timevalue to seconds    input_value=${timelist}   index=${index0}
    [Return]    ${timestamp}

Update the swconfig file
    [Arguments]    ${localFilePath}    ${gNB_index}=${0}
    wait until keyword succeeds    1min    10s    Connect gNB   gnb_index=${gNB_index}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=gNB${gNB_index}
    csn.Disconnect    connection=gNB${gNB_index}

Check IE wireshark log for CDRX config
    [Arguments]    ${logname}    ${message_filter}    ${value1}    ${value2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    #${drx_onDurationTimer}=     cap.get_field_value_by_xpath   pdml_list=${filtered_packets}
    #...                                                xpath=.//nr-rrc.milliSeconds
    #should be equal    ${drx_onDurationTimer[0]}    ${value1}
    ${drx_InactivityTimer}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.drx_InactivityTimer    pcap_parser=test6
    should be equal    ${drx_InactivityTimer[0]}    ${value1}
    ${drx_LongCycleStartOffset}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.drx_LongCycleStartOffset   pcap_parser=test6
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value2}

Check IE wireshark log for discardtimer config
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${discard_Timer}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.discardTimer    pcap_parser=test6
    should be equal    ${discard_Timer[0]}    ${value}

#Connect to PCF server
#    [Arguments]    ${alias}=${ALIAS_PCF}
#    csn.Connect to    hostname=${PCF_IP}
#    ...    username=${PCF_username}
#    ...    password=${PCF_password}
#    ...    alias=${alias}
#    [Return]    ${alias}
#
#Exit the PCF service
#    Connect to PCF server
#    csn.send command  ps -ef | grep sim | grep -v grep | grep 5g | awk '{print $2}' | xargs kill -2    connection=${ALIAS_PCF}
#    sleep    5S
#
#Start PCF service
#    [Arguments]    ${ims}    ${ip}
#    ssh_pcf.pcf_connect    ip=${PCF_IP}    username=${PCF_username}    password=${PCF_password}
#    ssh_pcf.pcf_start    ims=${ims}    ip=${ip}
#
#Start PCMsim
#    run keyword and ignore error    Exit the PCF service
#    Start PCF service    ims=${ims}    ip=${PCF_IP}
#    sleep    10s
#
#Set 2 5QI1
#    [Arguments]    ${five_qi}    ${priorityLevel1}    ${priorityLevel2}    ${server_ip1}    ${server_ip2}
##    PCF.pcf_add_first_5QI1    five_qi=${five_qi}    priorityLevel=${priorityLevel1}    server_ip=${server_ip1}
##    sleep    5s
#    pcf_add_second_5QI1    five_qi=${five_qi}    priorityLevel1=${priorityLevel1}    priorityLevel2=${priorityLevel2}
#    ...    server_ip1=${server_ip1}    server_ip2=${server_ip2}
#    sleep    5s
#    execute_policy_all
#
#Execute PCF sim command for set 2 5QI1
#    Set 2 5QI1    five_qi=${five_qi}    priorityLevel1=${priorityLevel1}
#    ...    priorityLevel2=${priorityLevel2}    server_ip1=${server_ip1}    server_ip2=${server_ip2}
#
#Execute PCF sim command for delete 2 5QI1
#    delete_policy_all
#    execute_policy_all
#
#Recover PCF sim command
##    Execute PCF sim command for delete 2 5QI1
#    run keyword and ignore error    Exit the PCF service





###PM counter
Check PM counter Result
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${counter_increase}=True
    ${counter_value}    Check PM counter from webui    counter_id=${counter_id}    full_path=${dic_path}    gnb_index=${gnb_index}
    ${counter_sum}    Sum the list value    ${counter_value}
    Run keyword if    "${counter_increase}" == "True"    should be true    ${counter_sum} >= ${1}
    ...    ELSE    should be true     ${counter_sum} == ${0}
    [Return]    ${counter_sum}

Check PM counter from webui
    [Arguments]    ${counter_id}    ${full_path}    ${gnb_index}=${0}    ${date}=all
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR  ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%15
    ${utc_left} =    Evaluate    15-${utc_min}+1
    set global variable    ${utc_left}
    sleep    ${utc_left} min

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Prepare with PM counter time to caculate 1 min
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%60
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    60-${utc0}%60
    sleep    ${left_timer}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb last second counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[1]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Add PM counter list for case
    [Arguments]    ${pm_counters}
    FOR  ${pm_counter}  IN   @{pm_counters}
        Append To List    ${PM_all_list}    ${pm_counter}
    END

Get greater than all counters
    [Arguments]    ${expected_value}
    FOR  ${pm_counter}  IN   @{pm_all_list}
        ${counter_value}    Check gnb counter greater than expected_value    gnb_id=${pm_counter['gnb_id']}
        ...                                counter_id=${pm_counter['counter_id']}
        ...                                dic_path=${pm_counter['dic_path']}
        should be true   ${counter_value[0]}>=${expected_value}
    END

Get equal than all counters
    [Arguments]    ${expected_value}
    FOR  ${pm_counter}  IN   @{pm_all_list}
        ${counter_value}    Check gnb counter greater than expected_value    gnb_id=${pm_counter['gnb_id']}
        ...                                counter_id=${pm_counter['counter_id']}
        ...                                dic_path=${pm_counter['dic_path']}
        should be true   ${counter_value[0]}==${expected_value}
    END

Check gnb counter greater than expected_value
#    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
#    should be true   ${counter_value[0]}>=${expected_value}
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${counter_value}

Check gnb counter greater expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}>=${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check multi cell of gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    ${counter_value_5min}    Evaluate
    ...    ${counter_value[0]} + ${counter_value[1]} + ${counter_value[2]} + ${counter_value[3]} + ${counter_value[4]} + ${counter_value[5]}
    should be true   ${counter_value_5min}==${expected_value}
#    should be true   ${counter_value[4]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check inactive counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    ${counter_value_inactive}    Evaluate
    ...    ${counter_value[0]} + ${counter_value[1]}
    should be true   ${counter_value_inactive}==${expected_value}
#    should be true   ${counter_value[4]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections



###RU
Power reset RU
    [Arguments]  ${ru_pdu_ip}   ${ru_pdu_port}   ${ue_pdu_model}=FACOM
    pdu.setup_pdu    model=${ue_pdu_model}
    ...              host=${ru_pdu_ip}
    ...              alias=pdu_devices_connect
    pdu.power_off    port=${ru_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s
    pdu.power_on    port=${ru_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   60s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    [Teardown]    csn.disconnect    connection=cygwin

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

get dict kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}
