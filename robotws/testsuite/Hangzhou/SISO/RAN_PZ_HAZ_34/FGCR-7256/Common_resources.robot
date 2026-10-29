*** Settings ***
Documentation
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1
...   Common keywords for SISO

#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/epc_sim.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR-7256/FGCR-7257-parameter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot

*** Variables ***
@{BTSID}    36011    34711    23311
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
${tl_36012_scf_gnb2_80M}    gy_36012_GNB2_80M.xml
${tl_36012_scf_gnb2_20M}    gy_36012_GNB2_20M.xml
${tl_34712_scf_gnb2_80M}    gy_34712_GNB2_80M.xml
${tl_34712_scf_gnb2_20M}    gy_34712_GNB2_20M.xml
${tl_23312_scf_gnb2_80M}    gy_23312_GNB2_80M.xml
${tl_23312_scf_gnb2_20M}    gy_23312_GNB2_20M.xml

${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_port_1_}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10_}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11_}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12_}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13_}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_}                ${tl.attenuator[0].attenuator_ports[16]}

${enb_instance}     ${tl.enbs[0].instance_id}
${enb_instance2}     ${tl.enbs[1].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${ul_throughput}            80M
${dl_throughput}            980M
${dl_expect_throughput}    900
${ul_expect_throughput}    48
${duration}                1200
${dl_port}      ${tl.ues[0].iperf_details.port}
${ul_port}     ${tl.ues[0].iperf_details.ssh_connection_details.port}
${enb1_gnb1_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enb1_gnb2_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enb2_gnb2_x2_dist}    MRBTS-${enb_instance2}/LNBTS-${enb_instance2}/LNADJGNB-2
${eNB_X2_ON_OFF}    administrativeState
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb2_def_gnb_dist}     MRBTS-${enb_instance2}/LNBTS-${enb_instance2}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
*** Keywords ***
Load SCF for each TL 80M
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2_80M}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2_80M}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2_80M}

Load SCF for each TL 20M
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2_20M}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2_20M}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2_20M}

Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}

Prepare the atten for each TL E2G2
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb2_cell1_value=${0}   gnb2_cell1_value=${0}


Adjust the TL HBTE attenuation value
    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    ...    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}

Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s

UE.killall firefox progress
    UE.TestPC connections
    csn.send command    command=killall firefox    connection=TestPC
    csn.send command    command=killall Xvfb    connection=TestPC
    csn.disconnect    connection=TestPC
    sleep    10s

Setup Case for 80M
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=27    ul=41M    dl=535M    ULTPpercent=5
    ...     DLTPpercent=8
    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=80M    dl=1080M    ULTPpercent=95
    ...     DLTPpercent=90
    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M

power UE.SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22    ${DLTPpercent}=105    ${ULTPpercent}=100
    ${DL_TPUT1}     Evaluate     ${dl[:-1]}*110/100.00
    ${UL_TPUT1}     Evaluate     ${ul[:-1]}*110/100.00
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${UL_TPUT1}M
    Set Test Variable    ${DL_TPUT}    ${DL_TPUT1}M
    ${expect_ul}    Evaluate    ${ul[:-1]}*${ULTPpercent}/100.00/2
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${dl[:-1]}*${DLTPpercent}/100.00
    Set Test Variable    ${expect_dl}

UE.Start DLUL traffic and Caculate throughput for Huawei
    [Arguments]     ${duration}=1800s      ${nrbtsid}=1     ${retry}=10
    Set Suite Variable    ${home}    82
    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput for Huawei
    ...                                 data_transfer_dl=${DL_TPUT}
    ...                                 data_transfer_ul=${UL_TPUT}
    ...                                 duration=${duration}
    ...                                 Expected_Throughput_DL=${expect_dl}
    ...                                 Expected_Throughput_UL=${expect_ul}
    ...                                 nrbtsid=${nrbtsid}
    ...                                 retry=${retry}
    Should be true     ${status}

gNB.Close iperf progress
    [Arguments]
    Set Test Variable    ${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
    Set Test Variable    ${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
    Set Test Variable    ${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
    Set Test Variable    ${dl_port}    ${tl.ues[0].iperf_details.port}
    Set Test Variable    ${ul_port}    ${tl.appserver.iperf_details.port}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on APPserver    port=${ul_port}
