*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG_03
...    feature: CB006112-C

Force Tags    CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...            AND    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
#...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
#...                                          golden_scf_name=${tl_scf_${release_info}}    golden_scf_name_gnb2=${tl_scf2_${release_info}}
...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
...                                          golden_scf_name=${tl_gnb1_scf_${sw_version}}    golden_scf_name_gnb2=${tl_gnb2_scf_${sw_version}}

Suite Teardown    Run Keyword    robot_common_operations.Common Suite Teardown


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006112/Resources/CB006112_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006112/Resources/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
#${tl_scf_file_name1}    Configuration_scf_GNB1_CB008698.xml
#${tl_scf_file_name2}    Configuration_scf_GNB2_CB008698.xml
#${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/

${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}

${nglogname1_1}    6112_C01_01.pcap
${nglogname1_2}    6112_C01_02.pcap
${nglogname1_3}    6112_C01_03.pcap
${nglogname1_4}    6112_C01_04.pcap
${nglogname1_5}    6112_C01_05.pcap
${nglogname1_6}    6112_C01_06.pcap
${nglogname1_7}    6112_C01_07.pcap
${nglogname1_8}    6112_C01_08.pcap
${nglogname3_1}    6112_C03_01.pcap
${nglogname9_1}    6112_C09_01.pcap
${nglogname9_2}    6112_C09_02.pcap
${nglogname9_3}    6112_C09_03.pcap
${nglogname10_1}    6112_C10_01.pcap
${nglogname10_2}    6112_C10_02.pcap
${nglogname10_3}    6112_C10_03.pcap
${nglogname10_4}    6112_C10_04.pcap
${nglogname14_1}    6112_C14_01.pcap
${nglogname14_2}    6112_C14_02.pcap
${nglogname16_1}    6112_C16_01.pcap
${nglogname16_2}    6112_C16_02.pcap
${nglogname16_3}    6112_C16_03.pcap
${nglogname16_4}     6112_C16_04.pcap
${nglogname16_5}    6112_C16_05.pcap
${nglogname17_1}    6112_C17_01.pcap
${nglogname17_2}    6112_C17_02.pcap
${nglogname20_1}    6112_C20_01.pcap
${nglogname20_2}    6112_C20_02.pcap
${nglogname_EDA_04136786}    nglogname_EDA_04136786.pcap
${nglogname_EDA_04136786_2}    nglogname_EDA_04136786_2.pcap


${enblogname9_1}    6112_C09_enb01.pcap
${enblogname20_1}    6112_C20_enb01.pcap
${enblogname6}    749A06_Mate20enb01.pcap

${enb_instance}     ${tl.enbs[0].instance_id}
@{different_redirFreqEutra_value}    4200    4300
@{diffTL_enb_ID}    36721    38221    911    5395
${enbvoiceTDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_TDD-0
${enbvoiceFDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_FDD-0
${enbvoice_para}    actConvVoice
@{enbvoice_value}    true    false
${phone_number_TL343_1}    ${tl.ues[0].sec_key}    #####18001006306
${phone_number_TL343_2}    ${tl.ues[1].sec_key}    #####18001006378
${phone_number_TL382_1}    ${tl.ues[0].sec_key}    #####18001006306
${phone_number_TL382_2}    ${tl.ues[1].sec_key}    #####18001006378
${phone_number_TL367_1}    ${tl.ues[0].sec_key}    #####18001006408
${phone_number_TL367_2}    ${tl.ues[1].sec_key}    #####18001006377

@{maxNumOfGBRBearersSA}    0    1    10    200

${5GRU0_ANT9}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb2 PA
${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb2 PA
${5GRU0_ANT11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb1 cell2 PA
${5GRU0_ANT12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb1 cell2 PA
${5GRU0_ANT7}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #int  gnb1 cell1 PA TL382
${5GRU0_ANT8}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}    #int  gnb1 cell1 PA TL382
${5GRU0_ANT5}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}    #int  gnb2 Cell1 PA  TL343
${5GRU0_ANT6}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}     #int  gnb2 Cell1 PA  TL343
${5GRU0_ANT15}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb1 cell1 PA  TL367
${5GRU0_ANT16}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb1 cell1 PA  TL367
##PA
@{PA_value}    ${35}    ${55}    ${30}    ${0}    ${10}    ${20}    ${40}    ${25}    ${15}   #int list
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}
${att_ipaddr2}               ${tl.attenuator[1].ip_addr}
${att_api_port2}             ${tl.attenuator[1].port}
${att_ipaddr3}               ${tl.attenuator[2].ip_addr}     #TL382 GNB1 cell 1 PA P7P8
${att_api_port3}             ${tl.attenuator[2].port}        #TL382 GNB1 cell 1 PA P7P8
@{att_connection_port}    ${5GRU0_ANT9}    ${5GRU0_ANT10}    ${5GRU0_ANT11}    ${5GRU0_ANT12}    #${5GRU0_ANT3}    ${5GRU0_ANT4}
@{att_connection_port343}    ${5GRU0_ANT5}    ${5GRU0_ANT6}
@{att_connection_port382}    ${5GRU0_ANT7}    ${5GRU0_ANT8}
@{att_connection_port367}    ${5GRU0_ANT15}    ${5GRU0_ANT16}
${HBTE_max_value}           ${120}
${vendor}                    ${tl.attenuator[0].vendor}

${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
#${SCF_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
#${SCF_file_name}    Configuration_scf_GNB1_CB008698.xml
#${SCF_file_name_2}    Configuration_scf_GNB2_CB008698.xml
${enb_path}    /tmp
${ngap_filter}    ngap
${s1ap_filter}    s1ap
${index0}    0
${index1}    1
${index2}    2

${duration}    150
${ul_throughput}    200M
${dl_throughput}    1000M
${ul_throughput2}    2M
${dl_throughput2}    10M

@{expected_value}    0    1    2    380    300    3000    6    8          #TL367
@{expected_value2}    0    2    4    380    300    3000    6    8    2    #TL343 TL382
@{counter_id_C01}   M55125C05001    M55125C05002    M55139C00513    M55138C01014    M55139C00504
@{counter_id_C09}    M55138C01003
@{counter_id_C10}    M55138C01001    M55149C01001    M55138C01002    M55149C01002    M55149C01003    M55138C01005
...    M55138C01006    M55138C01007    M55139C00501    M55139C00502    M55139C00510    M55139C00511    M55139C00512
...    M55145C01501    M55138C01004    M55139C00509    M55138C01008    M55138C01009    M55138C01010    M55140C00501
...    M55139C00504    M55139C00508
@{counter_id_C10_1}    M55138C01001    M55149C01001    M55138C01002    M55149C01002    M55149C01003    M55138C01005
...    M55138C01006    M55138C01007    M55139C00501    M55139C00502    M55139C00510    M55139C00511    M55139C00512
...    M55145C01501
@{counter_id_C10_2}    M55138C01004    M55139C00509    M55138C01008    M55138C01009    M55138C01010    M55140C00501
@{counter_id_C20}    M55337C00001    M55337C01001    M55337C02001    M55337C03001    M55337C04001    M55337C05001
...    M55337C00002    M55337C01002    M55337C02002    M55337C03002    M55337C04002    M55337C05002    M55320C01001
...    M55320C01002    M55320C02001    M55320C02002

@{full_path}    CELLS/NRCELL-1/NRRCC/NR_RRC_RELEASE_REDIR_VFB_LTE

${ue_type}    huawei
${template_file}    sip

## filter command for coverting PDML
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
${gnb_filter1}    ngap.procedureCode == 26 && ngap.nas == 0

${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}

${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}


${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

*** Test Cases ***
[1]CB006112-C_16_Successful_TDD_InterFreq_IntergNB_handover_based_on_A5_measurements_with_5QI1_5QI5_with_non_GBR_bearer
    [Documentation]
    ...    This user scenario describes the gNB behaviour, when a UE for which Inter-frequency A3/A5 measurements have
    ...    been configured sends a Inter-frequency A3/A5 measurement report and gNB performs handover based on the
    ...    measurement report to a cell in the same gNB-DU. UE is configured with 5QI-1 and 5QI-5 and optionally 5QI-2.
    [Tags]     CB006112-C    CRT_TRUNK    CRT_22R3    CRT_22R4
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    EDA_04136786 steps

#    ${release_info}    Get sagnb release
    ${sw_version}=    Get sagnb version for selenium
    Set Test Variable    ${sw_version}
    Recover TopYong Attenuation 6112-C
    set C16 parameter with gnb2
    set value of parameter actVoNrMobilityThresholds    new_value=VoNrMobilityThresholds

#    locked LTE cell
#    Lock The First gNB
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    Check UE exist
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname16_1}    interface=any
    UEs attach    gnb_index=${1}
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_1}
    check point with A2 event    logname=${nglogname16_1}
#    check time to execute below steps
    Prepare with PM counter time to caculate    period=start
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname16_5}    interface=any
    Make a VoNR and ViNR call together on CB6112-C
    sleep    10s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_5}
    Start DL and UL data transfer    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'      Check counter counter on 6112-C10_1 with gnb2       #36721
#    ...     ELSE    Check counter counter on 6112-C10_1 with gnb2_5QI2
    Prepare with PM counter time to caculate    period=end
#    Check counter counter on 6112-C10_1 with gnb2_5QI2
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for 6112-C10_1 with gnb2_5QI2
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for 6112-C10_1 with gnb2_5QI2
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for 6112-C10_1 with gnb2_5QI2
    ...    ELSE    Check trunk counter for 6112-C10_1 with gnb2_5QI2
    Prepare with PM counter time to caculate    period=start
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname16_4}    interface=any
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname16_2}    interface=any
#    Unlock The first cell of First gNB
    sleep    5s
    Change the PA value to trigger HO for C_10
    sleep    10s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_2}
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname16_4}
    sleep    5s
    Prepare with PM counter time to caculate    period=end
    check point with A1 and A5 event of InterFreq and HO success
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'      Check counter counter on 6112-C10_2 with gnb2       #36721
#    ...     ELSE    Check counter counter on 6112-C10_2 with gnb2_5QI2
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for 6112-C10_2 with gnb2_5QI2
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for 6112-C10_2 with gnb2_5QI2
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for 6112-C10_2 with gnb2_5QI2
    ...    ELSE    Check trunk counter for 6112-C10_2 with gnb2_5QI2
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter target gnb1 for EDA03047420
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter target gnb1 for EDA03047420
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter target gnb1 for EDA03047420
    ...    ELSE    Check trunk counter target gnb1 for EDA03047420
    Change the PA value to trigger gnb1 cell1 110db for EDA
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname16_3}    interface=any
    Sleep   20s
    hang up VoNR and ViNR call
    sleep   20s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname16_3}
    Check IE wireshark log for VINR Release(U1 and UE2)    logname=${nglogname16_3}    message_filter=${gnb_filter1}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Sleep    20s    AND    hang up VoNR and ViNR call    AND    UEs detach    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_1}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_5}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname16_2}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB     nglogname=${nglogname16_3}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB     nglogname=${nglogname16_4}    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
    ...    Recover TopYong Attenuation 6112-C    AND
    ...    recover C16 parameter with gnb2    AND
    ...    set value of parameter actVoNrMobilityThresholds    AND
#    ...    Unlocked LTE cell    AND
#    ...    Run Keyword And Ignore Error    Unlock The First gNB    AND
    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
    ...    get and analysis syslog

#[1]CB006112-C_03_TDD_Adaptive_VoIP_TBS_for_Uplink_When_Original_TBS_Too_Large
#    [Documentation]
#    ...    This scenario describes L2-PS measuring the uplink VoIP data received from a UE and adjusting the uplink
#    ...    grant Transport Block Size (TBS) to match the average size of VoIP packets sent from the UE.
#    ...    The benefit of this function is to reduce padding bytes in the uplink transmission if the original
#    ...    uplink TBS is too large. And to eliminate segmentation of the downlink transmission if the original
#    ...    uplink TBS is too small. This scenario describes the case in which the original TBS is too large.
#    [Tags]     CB006112-C
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Recover TopYong Attenuation 6112-C
#    set C03 paramaters
#    prepare c03 with some cells
#    Check UE exist
#    UEs attach
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname3_1}    interface=any
###    Capture TTITrace and download to test pc ASIB
#    Make VoNR separately on CB6112-C
#    hang up VoNR call
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_1}
#    check point with guaranteedFlowBitRateUL    logname=${nglogname3_1}
###    check TBS and rrmbufferedDataULTotal on TTITRace
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    20s    AND    hang up VoNR call    AND    UEs detach    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3_1}    AND
#    ...    Run Keyword And Ignore Error    recover C03 paramaters    AND
#    ...    recover c03 with some cells    AND
#    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB006112-C_09_Unuccessful_setup_of_VoNR_call_with_TDD_NULL_ciphering_due_to_maxNumOfGBRBearersSA_capacity_while_EPS_Fallback_enbale
#    [Documentation]
#    ...    This user scenario describes the gNB behaviour for the successful setup of Voice over NR call with FDD.
#    ...    5QI-5 Qos flow setup request is received as part of PDU Session Resource Setup procedure.
#    ...    5QI-1 QoS flow setup request is received as part of PDU Session Resource Modify procedure.
#    ...    Inter-frequency HO is enabled in the cell.
#    [Tags]     CB006112-C
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Recover TopYong Attenuation 6112-C
#    Locked LTE cell
#    Lock The second cell of First gNB
#    Lock The Second gNB
#    set value of parameter actGBRAdmissionControl    new_value=EnhancedVoNR
#    set value of parameter maxNumOfGBRBearersSA    new_value=@{maxNumOfGBRBearersSA}[1]
#    Check UE exist
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname9_1}    interface=any
#    UEs attach
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_1}
##    check point with A2 event    logname=${nglogname9_1}
#    Unlocked LTE cell
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname9_2}    interface=any
#    Make a VoNR call(+6688)    ue_index=${1}
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_2}
##    check point with A1 and A3 event    logname=${nglogname9_2}
#    check time to execute below steps
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname9_3}    interface=any
#    Enb start capture wireshark log for 6112_C    filename=${enblogname9_1}
#    Make a VoNR call(+6688)
#    hang up VoNR call
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_3}
#    Enb stop and Save classical Logs for 6112_C    filename=${enblogname9_1}
#    Check support 5QI value and related message flow for call reject    logname=${nglogname9_3}
#    Analysis wireshark log on enb for case 6112_C
#    check C09 M55138C01003
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    20s    AND    End UEs VoNR call    AND    UEs detach    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_1}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_2}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname9_3}    AND
#    ...    set value of parameter maxNumOfGBRBearersSA    new_value=@{maxNumOfGBRBearersSA}[2]    AND
#    ...    set value of parameter actGBRAdmissionControl    AND
#    ...    Unlock The second cell of First gNB    AND
#    ...    Unlocked LTE cell    AND
#    ...    Unlock The Second gNB    AND
#    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]CB006112-C_14_Successful_FDD_InterFreq_IntraDU_handover_based_on_A5_measurements_with_5QI1_5QI5
#    [Documentation]
#    ...    This user scenario describes the gNB behaviour, when a UE for which Inter-frequency A3/A5 measurements
#    ...    have been configured sends a Inter-frequency A3/A5 measurement report and gNB performs handover based on the
#    ...    measurement report to a cell in the same gNB-DU. UE is configured with 5QI-1 and 5QI-5 and optionally 5QI-2.
#    [Tags]     CB006112-C
#    [Timeout]    1 hour
#    [Setup]
#    Recover TopYong Attenuation 6112-C14
#    set value of parameter a3MeasEnabled    index=2
#    set value of parameter a5MeasEnabled    new_value=rsrp    index=2
#    locked LTE cell
#    Lock The Second gNB
#    Lock The first cell of First gNB
#    Check UE exist
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname14_1}    interface=any
#    UEs attach
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname14_1}
#    check point with A2 event    logname=${nglogname14_1}
#    Make VoNR separately on CB6112-C
#    Unlock The first cell of First gNB
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname14_2}    interface=any
#    Change the PA value to trigger HO for C_14
#    sleep    10s
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname14_2}
#    check point with A1 and A5 event of IntraFreq   logname=${nglogname14_2}    event_IDs=4
#    [Teardown]    Run Keywords
#    ...     sleep    20s    AND    hang up VoNR call    AND    UEs detach    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname14_1}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname14_2}    AND
#    ...    Recover TopYong Attenuation 6112-C14    AND
#    ...    set value of parameter a3MeasEnabled    new_value=rsrp    index=2    AND
#    ...    set value of parameter a5MeasEnabled    index=2    AND
#    ...    Unlock The Second gNB    AND    Unlocked LTE cell    AND
#    ...    Run Keyword And Ignore Error    Unlock The first cell of First gNB    AND
#    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB006112-C_17_Unsuccessful_FDD_InterFreq_IntergNB_handover_based_on_A3_measurements_with_5QI1_5QI5_5QI2_due_to_maxNumOfGBRBearersSA_limit
#    [Documentation]
#    ...    This user scenario describes the gNB behaviour, when a UE for which Inter-frequency A3/A5 measurements have
#    ...    been configured sends a Inter-frequency A3/A5 measurement report and gNB performs handover based on the
#    ...    measurement report to a cell in the same gNB-DU. UE is configured with 5QI-1 and 5QI-5 and optionally 5QI-2
#    [Tags]     CB006112-C
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Recover TopYong Attenuation 6112-C
#    set C01 value of parameters
#    wait until keyword succeeds    10min   30s     Check the gnb cell status onair    cell_no=1
#    Lock The second cell of First gNB
#    Lock The Second gNB
#    Locked LTE cell
#    Check UE exist
#    check time to execute below steps
#    UEs attach
#    check C01 M55125C05001 M55125C05002
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1_1}    interface=any
#    Make a VoNR call(+6688)
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_1}
#    check points with VoNR successfully    logname=${nglogname1_1}
#    hang up VoNR call
#    power_ue.Prepare UE    ue_type=${ue_type}
#    check time to execute below steps
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}    interface=any
#    Start DL and UL data transfer    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}    ue_index=${1}
#    Make a VoNR call(+6688)
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}
#    check C01 M55139C00513 M55138C01014 M55139C00504
#    check radio resources not available on UEContextModificationFailure    logname=${nglogname1_2}
#    hang up VoNR call
##    UEs detach
##    recover C01 value of parameters
##    Unlock The Second gNB
#
##    Set C17 parameter
##    Lock The First gNB
##    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname17_1}    interface=any
##    UEs attach    gnb_index=${1}
##    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname17_1}
##    check point with A2 event    logname=${nglogname17_1}
##    Make a VoNR and ViNR call together on CB6112-C
##    Unlock The first cell of First gNB
##    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname17_2}    interface=any
##    Change the PA value to trigger HO for C_10
##    sleep    10s
##    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname17_2}
##    check point with A1 and A3 event of unsuccessful case    logname=${nglogname17_2}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    20s    AND    hang up VoNR and ViNR call    AND    UEs detach    AND
##    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname17_1}    AND
##    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname17_2}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_1}    AND
#    ...    Recover TopYong Attenuation 6112-C    AND
#    ...    Run Keyword And Ignore Error    recover C01 value of parameters    AND
##    ...    set value of parameters actRedirect actNormVCfallback voiceFBmode    AND
#    ...    Unlocked LTE cell    AND
#    ...    Run Keyword And Ignore Error    Unlock The First gNB    AND
#    ...    Unlock The Second gNB    AND
#    ...    set value of parameter maxNumOfGBRBearersSA    new_value=@{maxNumOfGBRBearersSA}[2]    AND
#    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB006112-C_20_Successful_InterRAT_handover_based_on_B2_measurements_with_5QI1_5QI5
#    [Documentation]
#    ...    This user scenario describes the gNB behaviour, when a UE for which A2 measurement report has been received
#    ...    is configured with required B2 inter-RAT measurements while the UE has been configured with 5QI-1 and 5QI-5
#    ...    and optionally 5QI-2 bearers.
#    [Tags]     CB006112-C
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Recover TopYong Attenuation 6112-C
#    Lock The First gNB
#    locked LTE cell
#    set C20 parameter
#    Check UE exist
#    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname20_1}    interface=any
#    UEs attach    gnb_index=${1}
#    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname20_1}
#    check point with A2 event    logname=${nglogname20_1}
#    Make a VoNR and ViNR call together on CB6112-C
#    Unlocked LTE cell
#    Start DL and UL data transfer    dl_throughput=${dl_throughput2}    ul_throughput=${ul_throughput2}
#    check time to execute below steps
#    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname20_2}    interface=any
#    Enb start capture wireshark log for 6112_C    filename=${enblogname20_1}
#    Change the PA value to trigger HO for C_20
#    sleep    10s
#    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname20_2}
#    Enb stop and Save classical Logs for 6112_C    filename=${enblogname20_1}
#    check point with B2 event of Inter_RAT HO    logname=${nglogname20_2}
#    check point with B2 event of Inter_RAT HO on enb    logname=${enblogname20_1}
#    hang up VoNR and ViNR call
#    check counter counter on 6112-C20 with gnb2 above 21A
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    20s    AND    hang up VoNR and ViNR call    AND    UEs detach    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname20_1}    AND
#    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname20_2}    AND
#    ...    Recover TopYong Attenuation 6112-C    AND
#    ...    recover C20 parameter    AND
#    ...    Unlocked LTE cell    AND
#    ...    Run Keyword And Ignore Error    Unlock The First gNB    AND
#    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
EDA_04136786 steps
    Start capture syslog via btslog on ute
    Online modify parmeters    parameters_to_update=${EDA_04136786_paras}    gnb_index=${1}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Enable RD flag of rdUeContextRequest
    Prepare with PM counter time to caculate    period=start
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname_EDA_04136786}    interface=any
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname_EDA_04136786_2}    interface=any
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
#    Make a VoNR call(+6688)    ue_index=${1}
#    Sleep    20s
#    check voice call status    ue_index=${1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}
    Sleep    5s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    Sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_EDA_04136786}
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname_EDA_04136786_2}
    Prepare with PM counter time to caculate    period=end
    Check IE wireshark log for 5QI5_setup_PDU_without_UE_Radio_Capability    log_name=${nglogname_EDA_04136786_2}
    Sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${counter_EDA_04136786_M55125C05002['counter_id']}
    ...    dic_path=${counter_EDA_04136786_M55125C05002['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${2}
    Check gnb counter as expected_value
    ...    counter_id=${counter_EDA_04136786_M55125C05003['counter_id']}
    ...    dic_path=${counter_EDA_04136786_M55125C05003['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${2}
    [Teardown]    Run Keywords
#    ...    Disable RD flag of rdUeContextRequest
#    ...    AND    hang up VoNR call    ue_index=${1}
#    ...    AND    Sleep    20s
#    ...    AND    check voice call status    ue_index=${1}    status=${0}
    ...    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    ...    AND    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_EDA_04136786}
    ...    AND    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname_EDA_04136786_2}
    ...    AND    Online modify parmeters
    ...    parameters_to_update=${EDA_04136786_recover_paras}    gnb_index=${1}    skip_parameter_relation_errors=False
    ...    AND    Stop capture syslog via btslog on ute

Check IE wireshark log for 5QI5_setup_PDU_without_UE_Radio_Capability
    [Arguments]    ${log_name}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.procedureCode == 43 and ngap.IMSVoiceSupportIndicator == 0
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_IMSVoiceSupportIndicator}=     cap.get_field_value_by_xpath
    ...    xpath=.//ngap.IMSVoiceSupportIndicator    pcap_parser=test6
    should be equal    ${ngap_IMSVoiceSupportIndicator[0]}      0

Enable RD flag of rdUeContextRequest
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini

Disable RD flag of rdUeContextRequest
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=GNB
    wait until keyword succeeds    1min   10s    csn.connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${ALIAS_ASIK}
    Sleep    2s
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && ls cp_ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/5G/CPUENODE/addons/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE/addons/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    Sleep    2s
    [Teardown]    csn.Disconnect    connection=${ALIAS_ASIK}




get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
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


set value of parameter maxNumOfGBRBearersSA addNumOfGBRBearers
    [Arguments]    ${new_value1}=10    ${new_value2}=0
    ...    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${maxNumOfGBRBearersSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${maxNumOfGBRBearersSA_distname}
    ...    filter_param=Maximum number of GBR data radio bearers in a New Radio cell for SA
    ...    abbr=maxNumOfGBRBearersSA    new_value=${new_value1}
    Set Suite Variable    ${addNumOfGBRBearers_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${addNumOfGBRBearers_distname}
    ...    filter_param=Additional number of GBR DRB resources for handovers
    ...    abbr=addNumOfGBRBearers    new_value=${new_value2}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter actInterRatHoSA a3MeasEnabled
    [Arguments]    ${new_value1}=false    ${new_value2}=none
    ...    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actInterRatHoSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actInterRatHoSA_distname}
    ...    filter_param=Activate inter-RAT handover for SA UE
    ...    abbr=actInterRatHoSA    new_value=${new_value1}
    Set Suite Variable    ${a3MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}/NRHOIF-${index2}
    selenium_coam.set_parameter_value  dist_name=${a3MeasEnabled_distname}
    ...    filter_param=A3 Measurement Configuration Enabled
    ...    abbr=a3MeasEnabled    new_value=${new_value2}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter maxNumOfGBRBearersSA
    [Arguments]    ${new_value}=10    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${maxNumOfGBRBearersSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${maxNumOfGBRBearersSA_distname}
    ...    filter_param=Maximum number of GBR data radio bearers in a New Radio cell for SA
    ...    abbr=maxNumOfGBRBearersSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter actAdaptVoipTbs
    [Arguments]    ${new_value}=false    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actAdaptVoipTbs_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actAdaptVoipTbs_distname}
    ...    filter_param=Activate adaptive VoIP TBS
    ...    abbr=actAdaptVoipTbs    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set C03 paramaters
    set value of parameter actGBRAdmissionControl addNumOfGBRBearers maxNumOfGBRBearersSA actAdaptVoipTbs
    ...    new_value3=${maxNumOfGBRBearersSA}[2]    new_value4=true

recover C03 paramaters
    set value of parameter actGBRAdmissionControl addNumOfGBRBearers maxNumOfGBRBearersSA actAdaptVoipTbs
#    delete value of parameter maxGBRTrafficLimit

set value of parameter actGBRAdmissionControl addNumOfGBRBearers maxNumOfGBRBearersSA actAdaptVoipTbs
    [Arguments]    ${new_value1}=off    ${new_value2}=0    ${new_value3}=10    ${new_value4}=false
    ...    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actGBRAdmissionControl_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actGBRAdmissionControl_distname}
    ...    filter_param=Activation of radio admission control for GBR data radio bearers
    ...    abbr=actGBRAdmissionControl    new_value=${new_value1}
    Set Suite Variable    ${addNumOfGBRBearers_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${addNumOfGBRBearers_distname}
    ...    filter_param=Additional number of GBR DRB resources for handovers
    ...    abbr=addNumOfGBRBearers    new_value=${new_value2}
    Set Suite Variable    ${maxNumOfGBRBearersSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${maxNumOfGBRBearersSA_distname}
    ...    filter_param=Maximum number of GBR data radio bearers in a New Radio cell for SA
    ...    abbr=maxNumOfGBRBearersSA    new_value=${new_value3}
    Set Suite Variable    ${actAdaptVoipTbs_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actAdaptVoipTbs_distname}
    ...    filter_param=Activate adaptive VoIP TBS
    ...    abbr=actAdaptVoipTbs    new_value=${new_value4}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

prepare c03 with some cells
    Lock The second cell of First gNB
    Lock The Second gNB
    Locked LTE cell

recover c03 with some cells
    Unlock The second cell of First gNB
    Unlocked LTE cell
    Unlock The Second gNB

set value of parameter actGBRAdmissionControl maxGBRTrafficLimit addNumOfGBRBearers actFdmScheduling EPSFB
    [Arguments]    ${new_value1}=off    ${new_value2}=75    ${new_value3}=0
    ...    ${new_value_actRedirect}=true    ${new_value_actNormVCfallback}=true    ${new_value_voiceFBmode}=redirection
    ...    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
#    ...    ${new_value_actFdmScheduling}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actGBRAdmissionControl_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actGBRAdmissionControl_distname}
    ...    filter_param=Activation of radio admission control for GBR data radio bearers
    ...    abbr=actGBRAdmissionControl    new_value=${new_value1}
    Set Suite Variable    ${maxGBRTrafficLimit_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${maxGBRTrafficLimit_distname}
    ...    filter_param=Maximum GBR traffic limit
    ...    abbr=maxGBRTrafficLimit    new_value=${new_value2}
    Set Suite Variable    ${addNumOfGBRBearers_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${addNumOfGBRBearers_distname}
    ...    filter_param=Additional number of GBR DRB resources for handovers
    ...    abbr=addNumOfGBRBearers    new_value=${new_value3}
    Set Suite Variable    ${actRedirect_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actRedirect_distname}
    ...    filter_param=Activate RRC Connection Release with redirection
    ...    abbr=actRedirect    new_value=${new_value_actRedirect}
    Set Suite Variable    ${actNormVCfallback_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actNormVCfallback_distname}
    ...    filter_param=Activate normal voice call fallback to LTE
    ...    abbr=actNormVCfallback    new_value=${new_value_actNormVCfallback}
    Set Suite Variable    ${voiceFBmode_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${voiceFBmode_distname}
    ...    filter_param=Voice fallback mode
    ...    abbr=voiceFBmode    new_value=${new_value_voiceFBmode}
#    Set Suite Variable    ${actFdmScheduling_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
#    selenium_coam.set_parameter_value  dist_name=${actFdmScheduling_distname}
#    ...    filter_param=Activate frequency domain scheduling
#    ...    abbr=actFdmScheduling    new_value=${new_value_actFdmScheduling}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter actGBRAdmissionControl
    [Arguments]    ${new_value}=off    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actGBRAdmissionControl_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actGBRAdmissionControl_distname}
    ...    filter_param=Activation of radio admission control for GBR data radio bearers
    ...    abbr=actGBRAdmissionControl    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter addNumOfGBRBearers
    [Arguments]    ${new_value}=0    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${addNumOfGBRBearers_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${addNumOfGBRBearers_distname}
    ...    filter_param=Additional number of GBR DRB resources for handovers
    ...    abbr=addNumOfGBRBearers    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameters actRedirect actNormVCfallback voiceFBmode
    [Arguments]    ${new_value_actRedirect}=true    ${new_value_actNormVCfallback}=true    ${new_value_voiceFBmode}=redirection
    ...    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actRedirect_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actRedirect_distname}
    ...    filter_param=Activate RRC Connection Release with redirection
    ...    abbr=actRedirect    new_value=${new_value_actRedirect}
    Set Suite Variable    ${actNormVCfallback_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actNormVCfallback_distname}
    ...    filter_param=Activate normal voice call fallback to LTE
    ...    abbr=actNormVCfallback    new_value=${new_value_actNormVCfallback}
    Set Suite Variable    ${voiceFBmode_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${voiceFBmode_distname}
    ...    filter_param=Voice fallback mode
    ...    abbr=voiceFBmode    new_value=${new_value_voiceFBmode}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter maxGBRTrafficLimit
    [Arguments]    ${new_value}=75    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${maxGBRTrafficLimit_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${maxGBRTrafficLimit_distname}
    ...    filter_param=Maximum GBR traffic limit
    ...    abbr=maxGBRTrafficLimit    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

delete value of parameter maxGBRTrafficLimit
    [Arguments]    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${maxGBRTrafficLimit_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.delete_parameter  dist_name=${maxGBRTrafficLimit_distname}
    ...    filter_param=Maximum GBR traffic limit
    ...    abbr=maxGBRTrafficLimit
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

remove object NRADJGNB and XNLINK
    [Arguments]    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${NRADJGNB_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRADJGNB-${index}
    Set Suite Variable    ${XNLINK_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/XNLINK-${index2}
    selenium_coam.remove_object  object_name=${NRADJGNB_distname}
    selenium_coam.remove_object  object_name=${XNLINK_distname}
    sleep    3s
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

remove object NRADJGNB and XNLINK for 2 gnbs with CB6112-C
    remove object NRADJGNB and XNLINK
    remove object NRADJGNB and XNLINK    WEBUI_COAM=${WEBUI2_COAM}

Set C17 parameter
    set value of parameter maxNumOfGBRBearersSA addNumOfGBRBearers    new_value1=${maxNumOfGBRBearersSA}[0]
    set value of parameter actInterRatHoSA a3MeasEnabled    new_value2=rsrp    WEBUI_COAM=${WEBUI2_COAM}
#    set value of parameter maxNumOfGBRBearersSA    new_value=@{maxNumOfGBRBearersSA}[0]
#    set value of parameter addNumOfGBRBearers
#    set value of parameter actInterRatHoSA    WEBUI_COAM=${WEBUI2_COAM}
#    set value of parameter a3MeasEnabled    new_value=rsrp    WEBUI_COAM=${WEBUI2_COAM}

set value of parameter actInterRatHoSA
    [Arguments]    ${new_value}=false    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actInterRatHoSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actInterRatHoSA_distname}
    ...    filter_param=Activate inter-RAT handover for SA UE
    ...    abbr=actInterRatHoSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set C20 parameter
    set value of parameter actInterRatHoSA actInterRatHoSADlDataForward miNrNRPFW miNrPDCP1Report miNrPDCP2Report
    ...    new_value1=true    new_value2=true    new_value3=5min    WEBUI_COAM=${WEBUI2_COAM}

recover C20 parameter
    set value of parameter actInterRatHoSA actInterRatHoSADlDataForward miNrNRPFW miNrPDCP1Report miNrPDCP2Report
    ...    WEBUI_COAM=${WEBUI2_COAM}

set value of parameter actInterRatHoSA actInterRatHoSADlDataForward miNrNRPFW miNrPDCP1Report miNrPDCP2Report
    [Arguments]    ${new_value1}=false    ${new_value2}=false    ${new_value3}=disabled    ${index}=1
    ...    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actInterRatHoSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actInterRatHoSA_distname}
    ...    filter_param=Activate inter-RAT handover for SA UE
    ...    abbr=actInterRatHoSA    new_value=${new_value1}
    Set Suite Variable    ${actInterRatHoSADlDataForward_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actInterRatHoSADlDataForward_distname}
    ...    filter_param=Activate DL data forwarding for inter-RAT handover for SA UE
    ...    abbr=actInterRatHoSADlDataForward    new_value=${new_value2}
    Set Suite Variable    ${miNrNRPFW_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-${index}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    selenium_coam.set_parameter_value    dist_name=${miNrNRPFW_distname}
#    ...    filter_param=NR PDU Session DL Forwarding     abbr=miNrNRPFW    new_value=${new_value3}
#    ...    ELSE    selenium_coam.set_parameter_value     dist_name=${miNrNRPFW_distname}
#    ...    filter_param=Measurement interval for NR PDU Session DL Forwarding    abbr=miNrNRPFW    new_value=${new_value3}
    selenium_coam.set_parameter_value    dist_name=${miNrNRPFW_distname}
    ...    filter_param=NR PDU Session DL Forwarding     abbr=miNrNRPFW    new_value=${new_value3}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set C16 parameter with gnb2
    set value of parameter a3MeasEnabled a5MeasEnabled actInterRatHoSA actVoNrMobilityThresholds
    ...    new_value2=rsrp    new_value4=VoNrMobilityThresholds    WEBUI_COAM=${WEBUI2_COAM}    new_value5=false

recover C16 parameter with gnb2
    set value of parameter a3MeasEnabled a5MeasEnabled actInterRatHoSA actVoNrMobilityThresholds
    ...    new_value1=rsrp    new_value3=true    WEBUI_COAM=${WEBUI2_COAM}    new_value5=true

set value of parameter a3MeasEnabled a5MeasEnabled actInterRatHoSA actVoNrMobilityThresholds
    [Arguments]    ${new_value1}=none    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    ...    ${new_value2}=none    ${index3}=1    ${new_value3}=false    ${new_value4}=off    ${new_value5}=false
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${a3MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}/NRHOIF-${index2}
    selenium_coam.set_parameter_value  dist_name=${a3MeasEnabled_distname}
    ...    filter_param=A3 Measurement Configuration Enabled
    ...    abbr=a3MeasEnabled    new_value=${new_value1}
    Set Suite Variable    ${a5MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}/NRHOIF-${index3}
    selenium_coam.set_parameter_value  dist_name=${a5MeasEnabled_distname}
    ...    filter_param=A5 Measurement Configuration Enabled
    ...    abbr=a5MeasEnabled    new_value=${new_value2}
    Set Suite Variable    ${actInterRatHoSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actInterRatHoSA_distname}
    ...    filter_param=Activate inter-RAT handover for SA UE
    ...    abbr=actInterRatHoSA    new_value=${new_value3}
    Set Suite Variable    ${actVoNrMobilityThresholds_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actVoNrMobilityThresholds_distname}
    ...    filter_param=Activation of mobility thresholds for VoNr UEs
    ...    abbr=actVoNrMobilityThresholds    new_value=${new_value4}
    selenium_coam.set_parameter_value  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
    ...    filter_param=Activate slice number extension
    ...    abbr=actSliceNumExt    new_value=${new_value5}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter a3MeasEnabled
    [Arguments]    ${new_value}=none    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${a3MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}/NRHOIF-${index2}
    selenium_coam.set_parameter_value  dist_name=${a3MeasEnabled_distname}
    ...    filter_param=A3 Measurement Configuration Enabled
    ...    abbr=a3MeasEnabled    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter a5MeasEnabled
    [Arguments]    ${new_value}=none    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${a5MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}/NRHOIF-${index2}
    selenium_coam.set_parameter_value  dist_name=${a5MeasEnabled_distname}
    ...    filter_param=A5 Measurement Configuration Enabled
    ...    abbr=a5MeasEnabled    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter actVoNrMobilityThresholds
    [Arguments]    ${new_value}=off    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actVoNrMobilityThresholds_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${index}
    selenium_coam.set_parameter_value  dist_name=${actVoNrMobilityThresholds_distname}
    ...    filter_param=Activation of mobility thresholds for VoNr UEs
    ...    abbr=actVoNrMobilityThresholds    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set C01 value of parameters
    set value of parameter actGBRAdmissionControl maxGBRTrafficLimit addNumOfGBRBearers actFdmScheduling EPSFB
    ...    new_value1=EnhancedVoNR    new_value2=70    new_value3=300
    ...    new_value_actRedirect=false    new_value_actNormVCfallback=false    new_value_voiceFBmode=disabled
#    ...    new_value_actFdmScheduling=false    #default set true from 2022/5/26
#    set value of parameter actGBRAdmissionControl    new_value=EnhancedVoNR
#    set value of parameter maxGBRTrafficLimit    new_value=70
#    set value of parameter addNumOfGBRBearers    new_value=40
#    set value of parameters actRedirect actNormVCfallback voiceFBmode
#    ...    new_value_actRedirect=false    new_value_actNormVCfallback=false    new_value_voiceFBmode=disabled

recover C01 value of parameters
    set value of parameter actGBRAdmissionControl maxGBRTrafficLimit addNumOfGBRBearers actFdmScheduling EPSFB
#    set value of parameter actGBRAdmissionControl
#    delete value of parameter maxGBRTrafficLimit
#    set value of parameter addNumOfGBRBearers

Set default PA value for cases
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == '0000_000800'    Adjust RU0 Attenuation to 0
    Run Keyword If    '${release_info}' == '0011_001800'    Adjust RU0 Attenuation to 0

Change the PA value to trigger HO for C_10
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust gnb_enb the attenuation value for HBTE    #38221
    ...    gnb2_cell1_value=${20}    gnb1_cell1_value=${0}    #enb_cell1_value=${0}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value for HBTE    #343
    ...    gnb2_cell1_value=${30}    gnb1_cell1_value=${0}    #enb_cell1_value=${0}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust gnb_enb the attenuation value for HBTE    #36721
    ...    gnb2_cell1_value=${25}    gnb1_cell1_value=${0}    #enb_cell1_value=${0}

Change the PA value to trigger HO for C_20
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust the attenuation value for HBTE    #TL38221
    ...    value_1=${PA_value}[1]     value_2=${PA_value}[1]
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value for HBTE    #343
    ...    gnb2_cell1_value=${40}     enb_cell1_value=${0}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust gnb_enb the attenuation value for HBTE    #36721
    ...    gnb2_cell1_value=${40}     enb_cell1_value=${0}

Change the PA value to trigger gnb1 cell1 110db for EDA
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust gnb_enb the attenuation value for HBTE    #38221
    ...    gnb1_cell1_value=${30}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value for HBTE    #343
    ...    gnb1_cell1_value=${25}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust gnb_enb the attenuation value for HBTE    #36721
    ...    gnb1_cell1_value=${43}

Adjust TopYong Attenuation 6112-C on TL343
    Adjust TopYong 4ports Attenuation Values     value1=${40}    value2=${40}    value3=${40}    value4=${40}

Adjust TopYong Attenuation 6112-C on TL042
    Adjust TopYong 4ports Attenuation Values     value1=${50}    value2=${50}    value3=${50}    value4=${50}

Recover TopYong Attenuation 6112-C
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Recover HBTE Adjust gNB_eNB_RU Attenuation                #911
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Recover HBTE Adjust gNB_eNB_RU Attenuation                #3822
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'     Recover HBTE Adjust gNB_eNB_RU Attenuation                #36721
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}

Adjust the attenuation value for HBTE
    [Arguments]      ${value_1}=${value_1}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
    should be equal    ${value_port2}    ${value_1}

Adjust the attenuation value for HBTE EDA
    [Arguments]      ${value_1}=${value_1}
    att.setup_attenuator    ip_addr=${att_ipaddr3}    port=${att_api_port3}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT7}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT8}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT7}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT8}
    should be equal    ${value_port2}    ${value_1}

Adjust the attenuation value for HBTE EDA for TL382
    [Arguments]      ${value_1}=${value_1}
    att.setup_attenuator    ip_addr=${att_ipaddr3}    port=${att_api_port3}
    ...    attenuation_port_numbers=${att_connection_port382}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT7}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT8}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT7}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT8}
    should be equal    ${value_port2}    ${value_1}

Adjust the attenuation value for HBTE EDA for TL343
    [Arguments]      ${value_1}=${value_1}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port343}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT5}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT6}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT5}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT6}
    should be equal    ${value_port2}    ${value_1}

Adjust the attenuation value for HBTE EDA for TL367
    [Arguments]      ${value_1}=${value_1}
    att.setup_attenuator    ip_addr=${att_ipaddr2}    port=${att_api_port2}
    ...    attenuation_port_numbers=${att_connection_port367}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT15}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT16}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT15}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT16}
    should be equal    ${value_port2}    ${value_1}

Recover TopYong Attenuation 6112-C20
    Adjust TopYong 4ports Attenuation Values     value1=${10}    value2=${10}    value3=${10}    value4=${10}

Adjust TopYong 4ports Attenuation Values
      [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}
      Adjust the TopYong Attenuation Value 6112-C    ports=${TOPYONG_ANT1}    value=${value1}
      Adjust the TopYong Attenuation Value 6112-C    ports=${TOPYONG_ANT2}    value=${value2}
      Adjust the TopYong Attenuation Value 6112-C    ports=${TOPYONG_ANT3}    value=${value3}
      Adjust the TopYong Attenuation Value 6112-C    ports=${TOPYONG_ANT4}    value=${value4}

Adjust the TopYong Attenuation Value 6112-C
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Change the PA value to trigger HO for C_14
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust TopYong Attenuation 6112-C14 on TL042
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust TopYong Attenuation 6112-C14 on TL343
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust the attenuation value for HBTE 6112-C14
    ...    value_1=${PA_value}[5]     value_2=${PA_value}[5]
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust the attenuation value for HBTE 6112-C14
    ...    value_1=${PA_value}[4]     value_2=${PA_value}[4]

Adjust TopYong Attenuation 6112-C14 on TL343
    Adjust TopYong 4ports Attenuation Values for C14     value1=${10}    value2=${10}    value3=${10}    value4=${10}

Adjust TopYong Attenuation 6112-C14 on TL042
    Adjust TopYong 4ports Attenuation Values for C14     value1=${20}    value2=${20}    value3=${20}    value4=${20}

Recover TopYong Attenuation 6112-C14
#    Adjust TopYong 4ports Attenuation Values for C14     value1=${0}    value2=${0}    value3=${0}    value4=${0}
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value for HBTE 6112-C14
    ...    value_1=${PA_value}[3]     value_2=${PA_value}[3]
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Adjust the attenuation value for HBTE 6112-C14
    ...    value_1=${PA_value}[3]     value_2=${PA_value}[3]

Adjust the attenuation value for HBTE 6112-C14
    [Arguments]      ${value_1}=${value_1}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr2}    port=${att_api_port2}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${5GRU0_ANT11}    value=${value_1}
    att.set_attenuation     port=${5GRU0_ANT12}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT11}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT12}
    should be equal    ${value_port2}    ${value_1}

Adjust TopYong 4ports Attenuation Values for C14
      [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}
      Adjust the TopYong Attenuation Value 6112-C14    ports=${TOPYONG_ANT5}    value=${value1}
      Adjust the TopYong Attenuation Value 6112-C14    ports=${TOPYONG_ANT6}    value=${value2}
      Adjust the TopYong Attenuation Value 6112-C14    ports=${TOPYONG_ANT7}    value=${value3}
      Adjust the TopYong Attenuation Value 6112-C14    ports=${TOPYONG_ANT8}    value=${value4}

Adjust the TopYong Attenuation Value 6112-C14
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr2}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

check time to execute below steps
    gNB connections
    ${time}=    csn.execute    command=date | cut -d ':' -f 2 | cut -d ':' -f 2    connection=gnb
    ${time}=    Convert To Integer    ${time}
    ${ret}=    Evaluate    ${time}%5
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==0    sleep    0.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==1    sleep    0m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==2    sleep    3.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==3    sleep    2.5m
    Run Keyword And Ignore Error    Run Keyword If    ${ret}==4    sleep    1.5m

Check counter ${counter_id} as ${expected_value} on 6112-C
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Check counter ${counter_id} as ${expected_value} on 6112-C with gnb2
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Check counter counter on 6112-C10_1 with gnb2
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    3m    #TL343
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    sleep    2m      #TL382
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    sleep    2m      #TL367
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[0]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[1]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[2]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[3]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[4]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[1]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[5]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[6]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[7]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[8]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[9]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[10]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[11]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[4]

    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[12]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    should be true   ${values[-1]}>=${expected_value}[7]    #TL367
    #### from 22R3,counter not need to check,refre to email title:counter M55139C00512 increase incorrect
#    ...    ELSE    should be true   ${values[-1]}>=@{expected_value}[6]
     ...    ELSE    sleep     1s
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[13]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[1]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process


Get the all PM counter value
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
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections


Check counter for 6112-C10_1 with gnb2_5QI2
    sleep    40s
    # M55139C00511: 06.12.2024 : [SE: Shalab Tripaathi] Counter is obsoleted (set to DIP/Not used) from 25R2
    # due to PR803708 as the values provided by the counter are inaccurate. Paulina Matura
    # M55139C00512: 10.12.2024 : [SE: Shalab Tripaathi] Counter is obsoleted (set to DIP/Not used) from 25R2
    # due to PR803708 as the values provided by the counter are inaccurate. Paulina Matura
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${1}    counter_id=${counter_id_5QI2_gNB12_cell1}    dic_path=${counter_dic_path_5QI2_gNB2_cell1}
    Set suite variable    ${M55138C01001}                   ${counter_value_list}[0]
    Set suite variable    ${M55149C01001}                   ${counter_value_list}[1]
    Set suite variable    ${M55138C01002}                   ${counter_value_list}[2]
    Set suite variable    ${M55149C01002}                   ${counter_value_list}[3]
    Set suite variable    ${M55149C01003}                   ${counter_value_list}[4]

    Set suite variable    ${M55138C01006}                   ${counter_value_list}[5]
    Set suite variable    ${M55138C01007}                   ${counter_value_list}[6]
    Set suite variable    ${M55139C00501}                   ${counter_value_list}[7]
    Set suite variable    ${M55139C00502}                   ${counter_value_list}[8]

#    Set suite variable    ${M55139C00511}                   ${counter_value_list}[9]
    Comment     from 22R3,counter not need to check,refre to email title:counter M55139C00512 increase incorrect
#    Set suite variable    ${M55139C00512}                   ${counter_value_list}[10]
#    Set suite variable    ${M55145C01501}                   ${counter_value_list}[11]
    Set suite variable    ${M55145C01501}                   ${counter_value_list}[9]
    Comment    20230620 add EDA03047420 to Trunk/23R3/23R2 SA_DU_GBR_LACK_RAD_RES_M55139C00504
#    Set suite variable    ${M55139C00504}                   ${counter_value_list}[12]
    Set suite variable    ${M55139C00504}                   ${counter_value_list}[10]

    Should Be True    ${M55138C01001}>=4
    Should Be True    ${M55149C01001}>=2
    Should Be True    ${M55138C01002}>=4
    Should Be True    ${M55149C01002}>=2
    Should Be True    ${M55149C01003}>=2

    Should Be True    ${M55138C01006}>=300
    Should Be True    ${M55138C01007}>=4
    Should Be True    ${M55139C00501}>=4
    Should Be True    ${M55139C00502}>=4

#    Should Be True    ${M55139C00511}>=300
#    Should Be True    ${M55139C00512}>=
    Should Be True    ${M55145C01501}>=2
    Should Be True    ${M55139C00504}==0

Check trunk counter for 6112-C10_1 with gnb2_5QI2
    sleep    40s
    # M55139C00511: 06.12.2024 : [SE: Shalab Tripaathi] Counter is obsoleted (set to DIP/Not used) from 25R2
    # due to PR803708 as the values provided by the counter are inaccurate. Paulina Matura
    # M55139C00512: 10.12.2024 : [SE: Shalab Tripaathi] Counter is obsoleted (set to DIP/Not used) from 25R2
    # due to PR803708 as the values provided by the counter are inaccurate. Paulina Matura
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${1}    counter_id=${counter_id_5QI2_gNB12_cell1}    dic_path=${Trunk_counter_dic_path_5QI2_gNB2_cell1}
    Set suite variable    ${M55138C01001}                   ${counter_value_list}[0]
    Set suite variable    ${M55149C01001}                   ${counter_value_list}[1]
    Set suite variable    ${M55138C01002}                   ${counter_value_list}[2]
    Set suite variable    ${M55149C01002}                   ${counter_value_list}[3]
    Set suite variable    ${M55149C01003}                   ${counter_value_list}[4]

    Set suite variable    ${M55138C01006}                   ${counter_value_list}[5]
    Set suite variable    ${M55138C01007}                   ${counter_value_list}[6]
    Set suite variable    ${M55139C00501}                   ${counter_value_list}[7]
    Set suite variable    ${M55139C00502}                   ${counter_value_list}[8]

#    Set suite variable    ${M55139C00511}                   ${counter_value_list}[9]
    Comment    from 22R3,counter not need to check,refre to email title:counter M55139C00512 increase incorrect
#    Set suite variable    ${M55139C00512}                   ${counter_value_list}[10]
#    Set suite variable    ${M55145C01501}                   ${counter_value_list}[11]
    Set suite variable    ${M55145C01501}                   ${counter_value_list}[9]
    Comment    20230620 add EDA03047420 to Trunk/23R3/23R2 SA_DU_GBR_LACK_RAD_RES_M55139C00504
#    Set suite variable    ${M55139C00504}                   ${counter_value_list}[12]
    Set suite variable    ${M55139C00504}                   ${counter_value_list}[10]

    Should Be True    ${M55138C01001}>=4
    Should Be True    ${M55149C01001}>=2
    Should Be True    ${M55138C01002}>=4
    Should Be True    ${M55149C01002}>=2
    Should Be True    ${M55149C01003}>=2

    Should Be True    ${M55138C01006}>=300
    Should Be True    ${M55138C01007}>=4
    Should Be True    ${M55139C00501}>=4
    Should Be True    ${M55139C00502}>=4

#    Should Be True    ${M55139C00511}>=300
#    Should Be True    ${M55139C00512}>=
    Should Be True    ${M55145C01501}>=2
    Should Be True    ${M55139C00504}==0

Check counter counter on 6112-C10_1 with gnb2_5QI2
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    sleep    3m    #TL343
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    sleep    2m      #TL382
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    sleep    2m      #TL367
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[0]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[1]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[2]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[3]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[4]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[1]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[5]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[6]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[7]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[8]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[9]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[10]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[4]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[11]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[4]

    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[12]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    should be true   ${values[-1]}>=@{expected_value}[7]    #TL367
    #### from 22R3,counter not need to check,refre to email title:counter M55139C00512 increase incorrect
#    ...    ELSE    should be true   ${values[-1]}>=@{expected_value}[6]
#     ...    ELSE    sleep     1s
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[13]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[1]
    Comment    20230620 add EDA03047420 to Trunk/23R3/23R2 SA_DU_GBR_LACK_RAD_RES_M55139C00504
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[20]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}==${expected_value2}[0]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Check counter counter on 6112-C10_2 with gnb2
    sleep    4m
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[14]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[15]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[16]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[17]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[18]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[19]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[2]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process


Check counter for 6112-C10_2 with gnb2_5QI2
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${1}    counter_id=${counter_id_5QI2_gNB12_cell1_2}    dic_path=${counter_dic_path_5QI2_gNB2_cell1_2}
    Set suite variable    ${M55138C01004}                   ${counter_value_list}[0]
    Set suite variable    ${M55139C00509}                   ${counter_value_list}[1]
    Set suite variable    ${M55138C01009}                   ${counter_value_list}[2]
    Set suite variable    ${M55140C00501}                   ${counter_value_list}[3]

    Should Be True    ${M55138C01004}>=4
    Should Be True    ${M55139C00509}>=4
    Should Be True    ${M55138C01009}>=4
    Should Be True    ${M55140C00501}>=2

Check trunk counter for 6112-C10_2 with gnb2_5QI2
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${1}    counter_id=${counter_id_5QI2_gNB12_cell1_2}    dic_path=${Trunk_counter_dic_path_5QI2_gNB2_cell1_2}
    Set suite variable    ${M55138C01004}                   ${counter_value_list}[0]
    Set suite variable    ${M55139C00509}                   ${counter_value_list}[1]
    Set suite variable    ${M55138C01009}                   ${counter_value_list}[2]
    Set suite variable    ${M55140C00501}                   ${counter_value_list}[3]

    Should Be True    ${M55138C01004}>=4
    Should Be True    ${M55139C00509}>=4
    Should Be True    ${M55138C01009}>=4
    Should Be True    ${M55140C00501}>=2


Check counter counter on 6112-C10_2 with gnb2_5QI2
#    sleep    4m
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[14]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[15]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[16]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[17]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[2]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[18]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C10}[19]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value2}[8]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Check trunk counter target gnb1 for EDA03047420
    sleep    5s
    Comment    20230620 add EDA03047420 to Trunk/23R3/23R2 SA_HO_DU_GBR_LACK_RAD_RES_M55139C00508
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_HO_DU_GBR_LACK_RAD_RES['counter_id']}
    ...    dic_path=${Trunk_SA_HO_DU_GBR_LACK_RAD_RES['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_SA_HO_DU_GBR_LACK_RAD_RES['gnb_id']}

Check counter target gnb1 for EDA03047420
    sleep    5s
    Comment    20230620 add EDA03047420 to Trunk/23R3/23R2 SA_HO_DU_GBR_LACK_RAD_RES_M55139C00508
    Check gnb counter as expected_value
    ...    counter_id=${SA_HO_DU_GBR_LACK_RAD_RES['counter_id']}
    ...    dic_path=${SA_HO_DU_GBR_LACK_RAD_RES['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_HO_DU_GBR_LACK_RAD_RES['gnb_id']}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

check counter counter on 6112-C20 with gnb2 above 21A
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Check counter counter on 6112-C20 with gnb2    #TL382
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Check counter counter on 6112-C20 with gnb2    #TL343
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Check counter counter on 6112-C20 with gnb2    #TL367

Check counter counter on 6112-C20 with gnb2
    sleep    1m
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[0]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[1]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[2]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[3]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[4]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[5]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[6]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[7]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[8]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[9]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[10]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[11]
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}[0]
    ####counter_id_C20 12,13,14,15 remove on 2022.6.30 team chart and email with L2HI,
    ####not make sure lost packet or not
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[12]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[13]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[14]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id_C20}[15]
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}[1]
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

check C01 M55125C05001 M55125C05002
    sleep    1.5m
    Check counter ${counter_id_C01}[0] as ${expected_value}[0] on 6112-C
    Check counter ${counter_id_C01}[1] as ${expected_value}[0] on 6112-C

check C01 M55139C00513 M55138C01014 M55139C00504
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    3m        #TL343
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    log    no sleep    #TL382
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    log    no sleep    #TL367
    Check counter ${counter_id_C01}[2] as ${expected_value}[0] on 6112-C
    Check counter ${counter_id_C01}[3] as ${expected_value}[0] on 6112-C
    Check counter ${counter_id_C01}[4] as ${expected_value}[1] on 6112-C

check C09 M55138C01003
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    sleep    5m    #TL343
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    sleep    3m    #TL382
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    sleep    3m    #TL367
    Check counter ${counter_id_C09}[0] as ${expected_value}[1] on 6112-C

check C10_1 counters
    sleep    5m
    Check counter ${counter_id_C10}[0] as ${expected_value}[2] on 6112-C with gnb2
    Check counter ${counter_id_C10}[1] as ${expected_value}[1] on 6112-C with gnb2
    Check counter ${counter_id_C10}[2] as ${expected_value}[2] on 6112-C with gnb2
    Check counter ${counter_id_C10}[3] as ${expected_value}[1] on 6112-C with gnb2
    Check counter ${counter_id_C10}[4] as ${expected_value}[1] on 6112-C with gnb2
#    Check counter @{counter_id_C10}[5] as @{expected_value}[4] on 6112-C with gnb2
    Check counter ${counter_id_C10}[6] as ${expected_value}[4] on 6112-C with gnb2
    Check counter ${counter_id_C10}[7] as ${expected_value}[2] on 6112-C with gnb2
    Check counter ${counter_id_C10}[8] as ${expected_value}[2] on 6112-C with gnb2
    Check counter ${counter_id_C10}[9] as ${expected_value}[2] on 6112-C with gnb2
#    Check counter @{counter_id_C10}[10] as @{expected_value}[4] on 6112-C with gnb2
    Check counter ${counter_id_C10}[11] as ${expected_value}[4] on 6112-C with gnb2
    Check counter ${counter_id_C10}[12] as ${expected_value}[6] on 6112-C with gnb2
    Check counter ${counter_id_C10}[13] as ${expected_value}[1] on 6112-C with gnb2

check C10_2 counters
    sleep    5m
    Check counter ${counter_id_C10}[14] as ${expected_value}[2] on 6112-C with gnb2
    Check counter ${counter_id_C10}[15] as ${expected_value}[2] on 6112-C with gnb2
#    Check counter @{counter_id_C10}[16] as @{expected_value}[1] on 6112-C with gnb2
    Check counter ${counter_id_C10}[17] as ${expected_value}[2] on 6112-C with gnb2
#    Check counter @{counter_id_C10}[18] as @{expected_value}[1] on 6112-C with gnb2
    Check counter ${counter_id_C10}[19] as ${expected_value}[2] on 6112-C with gnb2

Start DL and UL data transfer C01
    [Arguments]    ${dl_throughput}    ${ul_throughput}
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration_C01}
    Start UL data transfer    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration_C01}


stop DL and UL data transfer
    stop DL traffic on 5G
    stop UL traffic on 5G

stop DL traffic on 5G
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl

stop UL traffic on 5G
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

End UEs VoNR call
    hang up VoNR call
    hang up VoNR call    ue_index=${1}

Make VoNR separately on CB6112-C
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Make a VoNR call separately    phone_number=${phone_number_TL343_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Make a VoNR call separately    phone_number=${phone_number_TL382_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Make a VoNR call separately    phone_number=${phone_number_TL367_2}

Make a VoNR and ViNR call together on CB6112-C
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Make a VoNR and ViNR call together    phone_number=${phone_number_TL343_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Make a VoNR and ViNR call together    phone_number=${phone_number_TL382_2}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Make a VoNR and ViNR call together    phone_number=${phone_number_TL367_2}

check points with VoNR successfully
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Contain    ${ngap_fiveQI}    1
    Should Not Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}    pcap_parser=test6
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}    pcap_parser=test6
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextModificationRequest}    pcap_parser=test6
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}    pcap_parser=test6
    ${f1ap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//f1ap.fiveQI    pcap_parser=test6
    Should Contain    ${f1ap_fiveQI}    1
    Should Not Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    cap.get_field_value_by_xpath    xpath=.//f1ap.PDCPSNLength    pcap_parser=test6
    Should Contain    ${f1ap_PDCPSNLength}    1
    ${f1ap_DRXConfigurationIndicator}=    cap.get_field_value_by_xpath    xpath=.//f1ap.DRXConfigurationIndicator    pcap_parser=test6
#    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextModificationResponse}    pcap_parser=test6
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse}    pcap_parser=test6
    ${f1ap_id}=    cap.get_field_value_by_xpath    xpath=.//f1ap.id    pcap_parser=test6
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}    pcap_parser=test6
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}    pcap_parser=test6
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowAddOrModifyResponseList    pcap_parser=test6
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1

check radio resources not available on PDUSessionResourceModifyResponse
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyResponse message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    ${ngap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    22

check radio resources not available on UEContextModificationFailure
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${PDUSessionResourceModifyRequest} =    Catenate    f1ap.F1AP_PDU == 2 and f1ap.procedureCode == 7
    Log To Console    check radioNetwork value on UEContextModificationFailure message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    ${f1ap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Contain    ${f1ap_radioNetwork}    8

check 5QI1 release and UE context release
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Contain    ${ngap_fiveQI}    2
    Should Not Contain    ${ngap_fiveQI}    1

check point with guaranteedFlowBitRateUL
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check values on BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}    pcap_parser=test6
    should be equal    ${BearerContextModificationRequest_status}    ${True}
#    ${filtered_packets}=    cap.filter_packets_by_expression
#    ...    filter_expression=${BearerContextModificationRequest}
#    ${e1ap_maxFlowBitRateDownlink}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//e1ap.maxFlowBitRateDownlink
#    Should Contain    ${e1ap_maxFlowBitRateDownlink}    44000
#    ${e1ap_maxFlowBitRateUplink}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//e1ap.maxFlowBitRateUplink
#    Should Contain    ${e1ap_maxFlowBitRateUplink}    44000
#    ${e1ap_guaranteedFlowBitRateDownlink}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//e1ap.guaranteedFlowBitRateDownlink
#    Should Contain    ${e1ap_guaranteedFlowBitRateDownlink}    44000
#    ${e1ap_guaranteedFlowBitRateUplink}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//e1ap.guaranteedFlowBitRateUplink
#    Should Contain    ${e1ap_guaranteedFlowBitRateUplink}    44000

#check TBS and rrmbufferedDataULTotal on TTITRace
#    [Arguments]    ${logname}

check point with A2 event
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${RRC_Reconfiguration} =    Catenate
    ...    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.eventId == 1)
    Log To Console    check A2 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    should be equal    ${RRC_Reconfiguration_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    ${rrc_eventId}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${rrc_eventId}    1
    #filter rsrp
    ${rrc_a2_Threshold}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.a2_Threshold    pcap_parser=test6
    Should Contain    ${rrc_a2_Threshold}    0
    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.hysteresis    pcap_parser=test6
    Should Contain    ${rrc_hysteresis}    0
    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.timeToTrigger    pcap_parser=test6
    Should Contain    ${rrc_timeToTrigger}    9

check point with no A2 event
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${RRC_Reconfiguration} =    Catenate
    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.criticalExtensions == 0 and nas_5gs.sm.5qi == 5
    Log To Console    check no A2 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    should be equal    ${RRC_Reconfiguration_status}    ${False}

check point with A1 and A3 event
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${RRC_Reconfiguration} =    Catenate
    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.criticalExtensions == 0 and nas_5gs.sm.5qi == 1
    Log To Console    check A1/A3 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    should be equal    ${RRC_Reconfiguration_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    ${rrc_eventId}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${rrc_eventId}[0]    0
    Should Contain    ${rrc_eventId}[1]    2

check point with A1 and A3 event with VoNR specific
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${RRC_Reconfiguration} =    Catenate
    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.criticalExtensions == 0 and nas_5gs.sm.5qi == 1
    Log To Console    check A1/A3 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    should be equal    ${RRC_Reconfiguration_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    ${rrc_eventId}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${rrc_eventId}    0

check point with A1 and A3 event of unsuccessful case
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    lias=test6
    ${HandoverRequest} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 0
    Log To Console    check radioNetwork value on HandoverRequest message
    ${HandoverRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${HandoverRequest}    pcap_parser=test6
    should be equal    ${HandoverRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${HandoverRequest}    pcap_parser=test6
    ${xnap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//xnap.radioNetwork    pcap_parser=test6
    Should Contain    ${xnap_radioNetwork}    1

    ${HandoverPreparationFailure} =    Catenate    xnap.XnAP_PDU == 2 and xnap.procedureCode == 0
    Log To Console    check radioNetwork value on HandoverPreparationFailure message
    ${HandoverPreparationFailure_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${HandoverPreparationFailure}    pcap_parser=test6
    should be equal    ${HandoverPreparationFailure_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${HandoverPreparationFailure}    pcap_parser=test6
    ${xnap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//xnap.radioNetwork    pcap_parser=test6
    Should Contain    ${xnap_radioNetwork}    4

check point with B2 event of Inter_RAT HO
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

#    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}
#    ${PDU_session}=     cap.get_field_value_by_xpath    pdml_list=${5QI_1_packets}
#    ...                                                xpath=.//ngap.fiveQI
#    should contain    ${PDU_session}    1
#    ${5QI_2_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 2
#    ${5QI_2_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_2_filter}
#    ${PDU_session}=     cap.get_field_value_by_xpath    pdml_list=${5QI_2_packets}
#    ...                                                xpath=.//ngap.fiveQI
#    should contain    ${PDU_session}    2
    ${HO_req_filter}=     Catenate    ngap.procedureCode == 12 and ngap.radioNetwork == 32
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.HandoverType    pcap_parser=test6
    should contain    ${HO_req}    1
    ${HO_res_filter}=     Catenate    ngap.procedureCode == 12 and ip.dst == ${asik2_addr}
    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//ngap.HandoverType    pcap_parser=test6
    should contain    ${HO_res}    1
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ip.dst == ${asik2_addr}
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    should contain    ${UE_rel}    41
    ${UE_rel_com_filter}=     Catenate    ngap.procedureCode == 41 and ip.src == ${asik2_addr}
    ${UE_rel_com_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UE_rel_com_filter}    pcap_parser=test6
    ${UE_rel_com}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    should contain    ${UE_rel_com}    41

check point with B2 event of Inter_RAT HO on enb
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${HO_req_filter}=     Catenate    s1ap.procedureCode == 1 and ip.dst == ${enb_address}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//s1ap.radioNetwork    pcap_parser=test6
    should contain    ${HO_req}    18
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
    ${ul_update}=     cap.get_field_value_by_xpath    xpath=.//nas_eps.nas_msg_emm_type    pcap_parser=test6
    should contain    ${ul_update}    74

Get Cell Id common keyword
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell1_id} =    selenium_coam.get_parameter_value    dist_name=${distname_id_1}/NRCELL-1
    ...   abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    ${cell2_id} =    selenium_coam.get_parameter_value    dist_name=${distname_id_1}/NRCELL-2
    ...   abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    set suite variable     ${cell1_id}
    set suite variable     ${cell2_id}
    [teardown]    Run Keywords    Run Keyword And Ignore Error    selenium_coam.logout    AND
                  ...    run keyword and ignore error    CI_interface.Common Case Teardown

check point with A1 and A5 event of IntraFreq
    [Arguments]    ${logname}    ${event_IDs}=2
    Get Cell Id common keyword

    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${measurement_filter}    Catenate     f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell1_id} and nr-rrc.physCellId == ${cell2_id}
    ${measurement_packets}    cap.filter_packets_by_expression    filter_expression=${measurement_filter}    pcap_parser=test6
    ${target_cell}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7  and nr-rrc.eventId == ${event_IDs} and  nr-rrc.physCellId == ${cell1_id}
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}    pcap_parser=test6
    ${eventId}=    cap.get_field_value_by_xpath     xpath=.//nr-rrc.eventId    pcap_parser=test6
    should not be empty    ${eventId}
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5 and nr-rrc.physCellId == ${cell1_id}
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}    pcap_parser=test6
    ${UeModify_res}    cap.get_field_value_by_xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    should be equal    ${UeModify_res[0]}    7
    ${RRC_reconfig_filter}    Catenate    f1ap.procedureCode == 12 and nr-rrc.physCellId == ${cell1_id}
    ${RRC_reconfig_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_reconfig_filter}    pcap_parser=test6
    ${RRC_reconfig}    cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    should be equal    ${RRC_reconfig[0]}    ${cell1_id}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    should be equal    ${RRC_reconfig[1]}    ${cell1_id}
#    should be equal    ${RRC_reconfig[0]}    ${cell1_id}
    @{frame_time}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch    pcap_parser=test6
    ${timestamp}=    convert_to_number    ${frame_time}[-1]
    ${RRC_re_complete_filter}    Catenate    f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier
    ${RRC_re_complete_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_re_complete_filter}    pcap_parser=test6
    ${RRC_re_complete}    cap.get_field_value_by_xpath     xpath=.//f1ap.procedureCode    pcap_parser=test6
    should be equal    ${RRC_re_complete[-1]}    13
    @{frame_time_1}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch    pcap_parser=test6
    ${timestamp_1}=    convert_to_number    ${frame_time_1}[-1]
    ${time_dif1} =    evaluate  float(${timestamp_1})-float(${timestamp})
    should be true    ${time_dif1} > 0
    ${Vonr_release_filter}    Catenate    ngap.procedureCode == 26 and ngap.nas == 0
    ${Vonr_release_filter_packets}    cap.filter_packets_by_expression    filter_expression=${Vonr_release_filter}    pcap_parser=test6
    ${Vonr_release}    cap.get_field_value_by_xpath    xpath=.//ngap.nas    pcap_parser=test6
    should not contain    ${Vonr_release}    0

check point with A1 and A5 event of InterFreq on TL343
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${RRC_Reconfiguration} =    Catenate
    ...    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.eventId == 4)
    Log To Console    check A5 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    should be equal    ${RRC_Reconfiguration_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${RRC_Reconfiguration}    pcap_parser=test6
    ${rrc_eventId}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${rrc_eventId}    0
    #filter rsrp
    ${rrc_a5_Threshold1}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.a5_Threshold1    pcap_parser=test6
    Should Contain    ${rrc_a5_Threshold1}    0
    ${rrc_a5_Threshold2}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.a5_Threshold2    pcap_parser=test6
    Should Contain    ${rrc_a5_Threshold2}    0
    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.hysteresis    pcap_parser=test6
    Should Contain    ${rrc_hysteresis}    0
    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.timeToTrigger    pcap_parser=test6
    Should Contain    ${rrc_timeToTrigger}    9
    ${rrc_eventId}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${rrc_eventId}    4
    #filter rsrp
    ${rrc_a1_Threshold}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.a1_Threshold    pcap_parser=test6
    Should Contain    ${rrc_a1_Threshold}    0
    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.hysteresis    pcap_parser=test6
    Should Contain    ${rrc_hysteresis}    0
    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.timeToTrigger    pcap_parser=test6
    Should Contain    ${rrc_timeToTrigger}    9

check point with HO successfully on TL343
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6

    ${UEContextRelease} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 6
    Log To Console    check UEContextRelease message
    ${UEContextRelease_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextRelease}    pcap_parser=test6
    should be equal    ${UEContextRelease_status}    ${True}

    ${UEContextReleaseCommand} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6
    Log To Console    check radioNetwork value on UEContextReleaseCommand message
    ${UEContextReleaseCommand_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseCommand}    pcap_parser=test6
    should be equal    ${UEContextReleaseCommand_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UEContextReleaseCommand}     pcap_parser=test6
    ${f1ap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Contain    ${f1ap_radioNetwork}    10

    ${UEContextReleaseComplete} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 6
    Log To Console    check UEContextReleaseComplete message
    ${UEContextReleaseComplete_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseComplete}    pcap_parser=test6
    should be equal    ${UEContextReleaseComplete_status}    ${True}

    ####
    ${HandoverRequest} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 0
    Log To Console    check radioNetwork value on HandoverRequest message
    ${HandoverRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${HandoverRequest}    pcap_parser=test6
    should be equal    ${HandoverRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverRequest}    pcap_parser=test6
    ${xnap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//xnap.radioNetwork    pcap_parser=test6
    Should Contain    ${xnap_radioNetwork}    1
    ${HandoverRequestAcknowledge_status}=     Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
    Log To Console    check HandoverRequestAcknowledge message
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${HandoverRequestAcknowledge_status}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    0
    Log To Console    check no handover cancel
    ${Handover_Cancel}=     Catenate    ngap.procedureCode == 10 and ngap.radioNetwork == 5
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${Handover_Cancel}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Not Contain    ${ngap_fiveQI}    5

check point with A1 and A5 event of InterFreq and HO success on TL343
    check point with A1 and A5 event of InterFreq on TL343   logname=${nglogname16_1}
    check point with HO successfully on TL343    logname=${nglogname16_2}

check point with A1 and A5 event of InterFreq and HO success
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'                            #TL343
#    ...    check point with A1 and A5 event of InterFreq and HO success on TL343
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[1]'                            #TL382
#    ...    check point with A1 and A5 event of InterFreq    logname=${nglogname16_2}
#    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'                            #TL367
#    ...    check point with A1 and A5 event of InterFreq    logname=${nglogname16_2}
    Check intergNB HO process on source gNB    logname=${nglogname16_2}
    Check intergNB HO process on target gNB    logname=${nglogname16_4}

check point with A1 and A5 event of InterFreq
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${RRC_Reconfiguration} =    Catenate
    ...    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.eventId == 4)
    Log To Console    check A5 event on RRC Reconfiguration message
    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}
    should be equal    ${RRC_Reconfiguration_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${RRC_Reconfiguration}
    ${rrc_eventId}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.eventId
    Should Contain    ${rrc_eventId}    0
    #filter rsrp
    ${rrc_a5_Threshold1}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.a5_Threshold1
    Should Contain    ${rrc_a5_Threshold1}    0
    ${rrc_a5_Threshold2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.a5_Threshold2
    Should Contain    ${rrc_a5_Threshold2}    0
    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.hysteresis
    Should Contain    ${rrc_hysteresis}    0
    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.timeToTrigger
    Should Contain    ${rrc_timeToTrigger}    9
    ${rrc_eventId}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.eventId
    Should Contain    ${rrc_eventId}    4
    #filter rsrp
    ${rrc_a1_Threshold}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.a1_Threshold
    Should Contain    ${rrc_a1_Threshold}    0
    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.hysteresis
    Should Contain    ${rrc_hysteresis}    0
    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.timeToTrigger
    Should Contain    ${rrc_timeToTrigger}    9

    ${HandoverRequest} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 0
    Log To Console    check radioNetwork value on HandoverRequest message
    ${HandoverRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${HandoverRequest}
    should be equal    ${HandoverRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${HandoverRequest}
    ${xnap_radioNetwork}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//xnap.radioNetwork
    Should Contain    ${xnap_radioNetwork}    1
    ${HandoverRequestAcknowledge_status}=     Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
    Log To Console    check HandoverRequestAcknowledge message
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${HandoverRequestAcknowledge_status}
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//xnap.procedureCode
    Should Be Equal    ${ngap_fiveQI[0]}    0
    Log To Console    check no handover cancel
    ${Handover_Cancel}=     Catenate    ngap.procedureCode == 10 and ngap.radioNetwork == 5
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${Handover_Cancel}
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//xnap.procedureCode
    Should Not Contain    ${ngap_fiveQI}    5

#    ${RRC_Reconfiguration} =    Catenate
#    ...    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 7)) && (nr-rrc.eventId == 1)
#    Log To Console    check A2 event on RRC Reconfiguration message
#    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
#    ...    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}
#    should be equal    ${RRC_Reconfiguration_status}    ${True}
#    ${filtered_packets}=    cap.filter_packets_by_expression
#    ...    filter_expression=${RRC_Reconfiguration}
#    ${rrc_eventId}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//nr-rrc.eventId
#    Should Contain    ${rrc_eventId}    1
#    #filter rsrp
#    ${rrc_a2_Threshold}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//nr-rrc.a2_Threshold
#    Should Contain    ${rrc_a2_Threshold}    0
#    ${rrc_hysteresis}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//nr-rrc.hysteresis
#    Should Contain    ${rrc_hysteresis}    0
#    ${rrc_timeToTrigger}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//nr-rrc.timeToTrigger
#    Should Contain    ${rrc_timeToTrigger}    9

    ${UEContextRelease} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 6
    Log To Console    check UEContextRelease message
    ${UEContextRelease_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextRelease}
    should be equal    ${UEContextRelease_status}    ${True}

    ${UEContextReleaseCommand} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6
    Log To Console    check radioNetwork value on UEContextReleaseCommand message
    ${UEContextReleaseCommand_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseCommand}
    should be equal    ${UEContextReleaseCommand_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${UEContextReleaseCommand}
    ${f1ap_radioNetwork}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.radioNetwork
    Should Contain    ${f1ap_radioNetwork}    10

    ${UEContextReleaseComplete} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 6
    Log To Console    check UEContextReleaseComplete message
    ${UEContextReleaseComplete_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${UEContextReleaseComplete}
    should be equal    ${UEContextReleaseComplete_status}    ${True}

Check support 5QI value and related message flow for call reject
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code26_0}
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${Code26_0}
    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code26_1}
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${Code26_1}
    ${ngap_radioNetwork} =    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.radioNetwork
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code42}
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${Code42}
    ${ngap_radioNetwork} =    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.radioNetwork
    Should Contain    ${ngap_radioNetwork}    41

    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code41}
    should be equal    ${Code41_status}    ${True}

Lock The second cell of First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=${timeout}
    coam.teardown    connection=gnb1

Unlock The second cell of First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=${timeout}
    coam.teardown    connection=gnb1

Lock The first cell of First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=${timeout}
    coam.teardown    connection=gnb1

Unlock The first cell of First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock   dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=${timeout}
    coam.teardown    connection=gnb1

recover close seleium logout
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    1s
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Enb start capture wireshark log for 6112_C
    [Arguments]    ${filename}     ${interface}=br1    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

Enb stop and Save classical Logs for 6112_C
    [Arguments]    ${filename}    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

Analysis wireshark log on enb for case 6112_C
    Check voice falls back to lte to the end of sign for 6112_C    logname=${enblogname9_1}

Check voice falls back to lte to the end of sign for 6112_C
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_12}
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_9}
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_5}
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${Code0_5}
#    ${s1ap_qCI} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//s1ap.qCI
#    Should Be Equal    ${s1ap_qCI[0]}    1

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_13_c6}
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_7}
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${Code0_7}
    ${s1ap_nas} =    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//s1ap.nas
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${Code0_13_ce}
    should be equal    ${Code0_13_ce_status}    ${True}

Check IE wireshark log for VINR Release(U1 and UE2)
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[0]}    0
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[1]}    0
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[2]}    0
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_nas}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[3]}    0

Recover HBTE Adjust gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

Adjust gnb_enb the attenuation value for HBTE
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

###PM counter
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
#    ####PDUSessionResourceModifyRequest
#    Log To Console     PDUSessionResourceModifyRequest
#    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}    pcap_parser=test6
#    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${ngap_fiveQI[0]}   1
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1
    ####RRC ReConfiguration(eventA3)
    ####RRC ReConfiguration(eventA3)

Check intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
#    ####UEContextSetupRequest,RRC ReConfiguration(eventA3)
#    Log To Console    RRC ReConfiguration
#    ${RRC_Rec_filter}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.eventId == 2
#    ${RRC_Rec_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Rec_filter}    pcap_parser=test6
#    ${RRC_Rec}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
#    should contain    ${RRC_Rec}    2
#    ####RRC ReConfiguration Complete
#    Log To Console    RRC ReConfiguration Complete
#    ${RRC_ReCom_filter}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0
#    ${RRC_ReCom_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_ReCom_filter}    pcap_parser=test6
#    ${RRC_ReCom}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
#    Should Be Equal    ${RRC_ReCom}    0
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Setup for Env cell on-air for 2 gnb
    [Arguments]    ${is_commission}=True    ${is_commission_for_second_gnb}=True    ${tl_scf_file_name}=${tl_scf_file_name1}
    ...    ${tl_scf_file_name2}=${tl_scf_file_name2}
    Common Case TestLine Setup    is_commission=${is_commission}    is_commission_for_second_gnb=${is_commission_for_second_gnb}
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name}    golden_scf_name_gnb2=${tl_scf_file_name2}

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
