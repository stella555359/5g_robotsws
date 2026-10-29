*** Settings ***
Documentation
...    author: cris cai
...    contact: cris.cai@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000738 Multiple PLMN ID support

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    Telnet
Library    taf.transport.ssh    WITH NAME    csn
#Library    ../../../../../../resources/python_libs/Attenuation.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${AT_script_path}    C:/Tools/AT
${ue_plmn_default}    at+cops=1,2,24409,7
${enb_b1_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${enb_b1_para}    actDynTrigLteNrDualConnectivity
${enb_default_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_default_para}    defaultLnRelGnbCellId
${dl_port}    ${tl.ues[0].ssh_connection_details.port}
${ul_port}    ${tl.ues[0].iperf_details.port}
${ue_type}    ${tl.ues[0].capabilities[0]}
#${ue_type}    huawei
${ue_type_2}    ${tl.ues[1].capabilities[0]}
${dl_time}    20
${dl_throughput}    140M
${dl_length}    1024B
${ul_time}    10
${ul_throughput}     15M
${ul_length}    1024B
${ul_expect}    0
${dl_expect}    0

${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${gnb_instance_2}     ${tl.gnbs[1].instance_id}

### HBTE PA ###
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
#${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
#${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}

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

${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

*** Keywords ***

Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s



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






Precondition for power UE
    [Arguments]    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

#Attach and check power UE
#    [Arguments]    ${ue_type}    ${5Gstatus}=PASS
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}

Tests Recovery
    [Arguments]    ${x2logname}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    run keyword and ignore error  Stop and Save classical enb x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=gnb

Recover the env atten to normal value
    [Arguments]    ${value1}=${40}    ${value2}=${120}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

Set default cell
    [Arguments]    ${enb_index}    ${value}
    Connect to eNB via ssl   enb_index=${enb_index}
    Modify the parameter on enblte    dist_name=${enb_default_dist}     parameter_name=${enb_default_para}    value=${value}
    enblte.teardown    connection=enblte

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3.5    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}+1
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Start the DL data throughput
    [Arguments]    ${dl_port}    ${ue_index}=${0}
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Start the UL data throughput
    [Arguments]    ${ul_port}    ${ue_index}=${0}
    Close the iperf process on APPserver    port=${ul_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}
    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}    ul_time=${ul_time}
    ...    ul_port=${ul_port}    ul_throughput=${ul_throughput}    ul_length=${ul_length}

Adjust the HBTE attenuation value
    [Arguments]      ${value}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value}
    att.set_attenuation     port=${att_port2}    value=${value}
    att.set_attenuation     port=${att_port3}    value=${value}
    att.set_attenuation     port=${att_port4}    value=${value}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value}

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
