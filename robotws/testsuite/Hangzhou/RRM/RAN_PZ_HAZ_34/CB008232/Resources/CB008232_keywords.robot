*** Settings ***
Documentation    This is for feature CB008232 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com; yue.1.gong@nokia-sbell.com
...              Squard: HZ SG3



Variables     ../TestData/CB008232_variables.py
Variables     ../TestData/CB008232_Split_parameter.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
###path###
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${GNB1_GSC_Trunk}           gy_36011_GNB1.xml
${GNB2_GSC_Trunk}           gy_36012_GNB2.xml
${GNB1_GSC_branch}            gy_23311_GNB1.xml
${GNB2_GSC_branch}            gy_23312_GNB2.xml
#${GNB1_GSC_Trunk}           MRBTS-36011_T360_gNB1_AEHC_AHLOA.xml
#${GNB1_GSC_23R1}            MRBTS-23311_T233_GNB1_AEHC_AHLOA.xml
#${GNB2_GSC_Trunk}           MRBTS-36012_T360_gNB2_AWHHF.xml
#${GNB2_GSC_23R1}            MRBTS-23312_T233_GNB2_AWHHF.xml
${swconfig}                 /opt/workspace/SCF/swconfig.txt
###BTS###
${MRBTS1_ID}                ${tl.gnbs[0].instance_id}
${MRBTS2_ID}                ${tl.gnbs[1].instance_id}
${ENB1_ID}                  ${tl.enbs[0].instance_id}
${ENB2_ID}                  ${tl.enbs[1].instance_id}
###UE###
${ue_type}                  ${tl.ues[0].capabilities[0]}
${dl_throughput}            50M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${DL_PORT_1}                  ${tl.ues[0].iperf_details.port}
${DL_PORT_2}                  ${tl.ues[1].iperf_details.port}
${DL_PORT_3}                  ${tl.ues[2].iperf_details.port}
${nrcellid_cell1}           1
${nrcellid_cell2}           2
${nrcellid_cell3}           3
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
@{gnb_ips_h}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}

@{gnb_list}    ${0}    ${1}
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
*** Keywords ***
8232 Suite Setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${MRBTSx_ID}=${MRBTS1_ID}    ${swconfig_modify}=${None}
    Common Suite Setup for COAM
    Set suite variable      ${MRBTS_ID}     ${MRBTSx_ID}
#    ${release_info}    Get sagnb release
#    set suite variable    ${release_info}
    Run Keyword If    '${MRBTS_ID}' == '36011'
    ...    Common Case TestLine Setup    is_commission=True
    ...                           golden_scf_name=${GNB1_GSC_Trunk}
    ...                           Is_Swconfig=True
    ...                           swconfig_file=${swconfig}
    ...                           swconfig_modify=${swconfig_modify}
    ...                           wait_gnb_up_timeout=30 min
    Run Keyword If    '${MRBTS_ID}' == '23311'
    ...    Common Case TestLine Setup    is_commission=True
    ...                           golden_scf_name=${GNB1_GSC_branch}
    ...                           Is_Swconfig=True
    ...                           swconfig_file=${swconfig}
    ...                           swconfig_modify=${swconfig_modify}



8232 Case TearDown
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    Common Case Teardown for COAM
    Check hanging resource for gnb    gnb_ips=@{gnb_ips_h}
    Adjust the GNBENB HBTE attenuation value
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    get and analysis syslog
#    run keyword and continue on failure    CI_interface.Common Case Teardown
#    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
#    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
#    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
#    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
#    run keyword and ignore error    COAM Teardown gnb connections


Adjust the GNBENB HBTE attenuation value
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${127}
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${127}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${127}
    Adjust the ENB1CELL1 HBTE attenuation value    enb1_cell1_value=${127}
    Adjust the ENB2CELL1 HBTE attenuation value    enb2_cell1_value=${127}


Set suite variable for ${case_key}
    Set Suite Variable    ${TestLine_ID}    BTS_${MRBTS_ID}
    Run Keyword And Ignore Error    Set Suite Variable    ${GNB2_GSC}      ${8232_store['${case_key}']['${TestLine_ID}']['GNB2_GSC']}
    Run Keyword And Ignore Error    set suite variable    ${cellid}          ${8232_store['${case_key}']['${TestLine_ID}']['cellid']}
    Run Keyword And Ignore Error    set suite variable    ${target_APN1}        ${8232_store['${case_key}']['${TestLine_ID}']['target_APN1']}
    Run Keyword And Ignore Error    set suite variable    ${drb-Identity_value}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['drb-Identity_value']}
    Run Keyword And Ignore Error    set suite variable    ${Modify_Para_Online}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['Modify_Para_Online']}
    Run Keyword And Ignore Error    set suite variable    ${phone_number}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['phone_number']}
    Run Keyword And Ignore Error    set suite variable    ${gnb2_cell1_pa}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['gnb2_cell1_pa']}
    Run Keyword And Ignore Error    set suite variable    ${gnb1_cell1_pa}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['gnb1_cell1_pa']}
    Run Keyword And Ignore Error    set suite variable    ${intergnb_ho_measid}
    ...                                                                    ${8232_store['${case_key}']['${TestLine_ID}']['intergnb_ho_measid']}





###-------PA--------###
Adjust the GNB1CELL1 HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS1_ID}    ${gnb1_cell1_value}=${0}
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

###--------UE--------###
Attach UE for 8232 test
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    ...    attach
    [Arguments]    ${wiresharklog}    ${ue_index}    ${DL_PORT}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ...    ${4G_check}=False
    ...    ${traffic_need}=True
    ...    ${options}=-i any sctp -s 0
    ...    ${ui_version}=S20UI2.1
    ...    ${Attach_status}=True
    Log To Console    \n***prepare UE_${ue_index} ***\n
    Precondition for Sansumg UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Log To Console    \n***start cpif log capture ***\n
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}    options=${options}    gnb_index=${gnb_index}
    Log To Console    \n***start ue_${ue_index} attach ***\n
    UE Attach With Power UE Index    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}
    ...                              gnb_index=${gnb_index}    Attach_status=${Attach_status}
    run keyword if    ${traffic_need}    run keywords
    ...    Log To Console    \n***start dl traffic ***\n    AND
    ...    Run Keyword And Continue On Failure    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${ue_index}    process_num=${1}    ue_type=${ue_type}
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

UE Attach With Power UE Index
    [Arguments]    ${ue_index}    ${ue_type}=${ue_type}    ${4G_check}=False    ${gnb_index}=${0}    ${Attach_status}=True
    ${Attach_value}=    Run Keyword And Return Status
    ...    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    Should Be True    '${Attach_value}' == '${Attach_status}'

UE Detach With Power UE Index
    [Arguments]    ${ue_index}    ${ue_type}=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UE Detach With Power UE for 3UES
    [Arguments]    ${ue_type}=${ue_type}    ${ue_num}=3
    FOR    ${ue_no}    IN RANGE    0    ${ue_num}
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_no}
    END

Stop Traffic for 3UES with Power UE
    [Arguments]    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT_1}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT_2}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT_3}

UE Detach and Stop traffic with Power UE
    [Arguments]    ${dl_port}    ${ue_index}    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to Test_need_APN
    [Arguments]     ${target_APN}    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${4G_check}=False
    ...             ${ui_version}=S20UI2.1     ${APN_ui_version}=one ui 3.1
    Precondition for Sansumg UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Run Keyword And Ignore Error    UE Attach With Power UE Index
    ...                             ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${target_APN}    ui_version=one ui 3.1
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${target_APN}    ui_version=${APN_ui_version}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Make an EMC call dial 911 with adb
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call dial 911 on UE    ue_index=${ue_index}
    End a call on UE with adb    ue_index=${ue_index}

Make a call dial 911 on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:911    connection=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cygwin${ue_index}
    sleep   30s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

End a call on UE with adb
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    Log To Console    \n***END A call***
    csn.send_command    command=adb -s ${serial_number} shell input tap 584 2000    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call to another UE
    [Arguments]    ${ue_index_dialing}=${2}    ${ue_index_incoming}=${1}    ${phone_number}=13100010725
    Make a VoNR call with adb    ue_index=${ue_index_dialing}    phone_number=${phone_number}
    sleep    2s
    Answer VoNR call with adb    ue_index=${ue_index_incoming}
    sleep    10s
    End a call on UE with adb    ue_index=${ue_index_dialing}

Make a VoNR call with adb
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=13100010725
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap 540 2270    connection=cygwin${ue_index}
    sleep    5s
    Log To Console    \n***make VoNR call***
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

Answer VoNR call with adb
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap 540 2270    connection=cygwin${ue_index}
    sleep    5s
    Log To Console    \n***Answer VoNR call***
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

Disable Moble_data with adb
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap 540 2270    connection=cygwin${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell svc data disable    connection=cygwin${ue_index}
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}


Enable Moble_data with adb
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap 540 2270    connection=cygwin${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin${ue_index}
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}


Enable Moble_data and detached
    [Arguments]    ${ue_index}=${1}
    Enable Moble_data with adb    ue_index=${ue_index}
    UE Detach With Power UE Index    ue_index=${ue_index}



Attach UE_1 for 8232_C
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    ...    attach
    [Arguments]     ${ue_index}=${1}     ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ...    ${4G_check}=False
    ...    ${ui_version}=S21UI4.0
    #...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log To Console    \n***prepare UE_${ue_index} ***\n
    Precondition for Sansumg UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Log To Console    \n***start ue_${ue_index} attach ***\n
    UE Attach With Power UE Index    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}
    ...                                    gnb_index=${gnb_index}
    Disable Moble_data with adb    ue_index=${ue_index}


Get Samsung UE IP
    [Documentation]    get UE IP
    ...    :param  command: common which to get UE IP
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${command}=adb -s ${serial_number} shell ip -f inet addr |grep 'scope global' | cut -d '/' -f 1 |head -n 1|awk '{print $2}'
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Log To Console    \n***get UE_ims ip ***\n
    csn.send_command    command=${command}
    ...    connection=cygwin
    ${UE_IP}    csn.Read Output    connection=cygwin
    ${UE_IP}    Strip String    ${UE_IP}
    ${UE_IP}    set variable if      '${UE_IP}'==''    127.0.0.1    ${UE_IP}
    Should Not Contain      ${UE_IP}      192.168
    [Return]     ${UE_IP}
    [Teardown]    csn.disconnect      connection=cygwin

Start Ping on iperf_APP
    [Arguments]    ${ue_index}    ${UE1_IP}    ${UE2_IP}
    Wait Until Keyword Succeeds     1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.execute    command=ping ${UE1_IP} -c 1 & ping ${UE2_IP} -c 1    connection=EPCAPP


###--------biplog---------###
Capture BIPlog with gnb_logs and Download
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    Capture Logs With gNB_logs_exe File    bbmod_slots=${bbmod_slots}      duration=${duration}
    ...            gnb_logs_script_path=${gnb_logs_script_path}
    ...            gnb_index=${gnb_index}       du_index=${du_index}      log_type=${log_type}
    ${biplogs}    Get Captured BIP File from UTE on local    gnb_logs_script_path=${gnb_logs_script_path}
    ...            target_dir=${epc_log_path}     gnb_index=${gnb_index}     du_index=${du_index}      log_type=${log_type}
    [Return]     ${biplogs[0]}

Get Captured BIP File from UTE on local
    [Documentation]    Auther: liujia
    [Arguments]    ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${target_dir}=${epc_log_path}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    ...            ${target_file_name}=L2L1_Bip
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
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${file_name};rm test_*.pcap
    ${full_log_path}    Create List    ${target_dir}${/}${file_name}${/}${target_file_name}.pcap
    [Return]     ${full_log_path}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/gNB_${gnb_ip}_*_${log_type}.zip


###--------log analysis-------###
Convert CPIF Pcap log To Pdml
    [Documentation]    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    #...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=nr-rrc
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Get Field Value From Pdml file
    [Documentation]    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Get TMSI from RRC_Registration_request_or_accept
    [Arguments]    ${file_path}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${file_path}    #tshark_path=${tshark_path}
    ####DownlinkNASTransport,Registration request_or_accept
    ${Registration_request_or_accept}=     Catenate    nas-5gs.5g_tmsi
    ${Registration_request_or_accept_packets}=    cap.filter_packets_by_expression    filter_expression=${Registration_request_or_accept}
    ${TMSI_ID}=     cap.get_field_value_by_xpath    pdml_list=${Registration_request_or_accept_packets}
    ...                                                xpath=.//nas-5gs.5g_tmsi
    [Return]    ${TMSI_ID}

Check Target Item Value on CPIF Tcpdump log
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
#    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert CPIF Pcap log To Pdml    file_path=${file_path}
#    ...                          tshark_path=${tshark_path}
    ...                          filter=${filter}
    ...                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml file    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}


Get EstablishmentCause from RRC_Setup_Request
    [Arguments]    ${file_path}    #${index}=0
    ${message_filter_expression}    Catenate    f1ap.initiatingMessage_element
    ${EstablishmentCause}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.establishmentCause
    ...            attribute_name=showname
    ${EstablishmentCause_1}=    String.Split String    ${EstablishmentCause[0]}    :${SPACE}
    ${EstablishmentCause}=    String.Split String    ${EstablishmentCause_1[1]}    ${SPACE}(
    [Return]    ${EstablishmentCause[0]}

Check EstablishmentCause from RRC_Setup_Request
    [Arguments]    ${file_path}    ${EstablishmentCause_value}    ${index}=0
    ${EstablishmentCause}=    Get EstablishmentCause from RRC_Setup_Request    file_path=${file_path}    index=${index}
    Should Contain    ${EstablishmentCause}    ${EstablishmentCause_value}

Get release_cause from UEContextRelease_Request
    [Arguments]    ${file_path}    ${index}=1
    ${message_filter_expression}    Catenate    ngap.initiatingMessage_element
    ${ReleaseCause}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.radioNetwork
    ...            attribute_name=showname
    ${ReleaseCause_1}=    String.Split String    ${ReleaseCause[0]}    :${SPACE}
    ${ReleaseCause_1}=    String.Split String    ${ReleaseCause_1[1]}    ${SPACE}(
    ${ReleaseCause_2}=    String.Split String    ${ReleaseCause[1]}    :${SPACE}
    ${ReleaseCause_2}=    String.Split String    ${ReleaseCause_1[1]}    ${SPACE}(
    [Return]    ${ReleaseCause_${index}}

Check release_reson from UEContextRelease_Request
    [Arguments]    ${file_path}    ${ReleaseCause_value}    ${index}=0
    ${ReleaseCause}=    Get release_cause from UEContextRelease_Request    file_path=${file_path}    index=${index}
    Should Contain    ${ReleaseCause}    ${ReleaseCause_value}

Get RRC_Reject_Reason from RRC_Reject
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.UEContextReleaseCommand_element
    ${RejectReason}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//f1ap.radioNetwork
    ...            attribute_name=showname
    ${RejectReason_1}=    String.Split String    ${RejectReason[0]}    :${SPACE}
    ${RejectReason}=    String.Split String    ${RejectReason_1[1]}    ${SPACE}(
    [Return]    ${RejectReason[0]}

Check RRC_Reject_Reason from RRC_Reject
    [Arguments]    ${file_path}    ${RejectReason_value}
    ${RejectReason}=    Get RRC_Reject_Reason from RRC_Reject    file_path=${file_path}
    Should Contain    ${RejectReason}    ${RejectReason_value}

Get Failure_Reason from InitialContextSetup
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.InitialContextSetupFailure_element
    ${Failure_Reason}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.radioNetwork
    ...            attribute_name=showname
    ${Failure_Reason_1}=    String.Split String    ${Failure_Reason[0]}    :${SPACE}
    ${Failure_Reason}=    String.Split String    ${Failure_Reason_1[1]}    ${SPACE}(
    [Return]    ${Failure_Reason[0]}

Check Failure_Reason from InitialContextSetup
    [Arguments]    ${file_path}    ${Failure_Reason_value}
    ${Failure_Reason}=    Get Failure_Reason from InitialContextSetup    file_path=${file_path}
    Should Contain    ${Failure_Reason}    ${Failure_Reason_value}

Get normal_release from rrc_release
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.UEContextReleaseCommand_element
    ${normal_release}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//f1ap.radioNetwork
    ...            attribute_name=showname
    ${normal_release_1}=    String.Split String    ${normal_release[0]}    :${SPACE}
    ${normal_release}=    String.Split String    ${normal_release_1[1]}    ${SPACE}(
    [Return]    ${normal_release[0]}

Check normal_release from rrc_release
    [Arguments]    ${file_path}    ${normal_release}=normal-release
    ${normal_release}=    Get normal_release from rrc_release    file_path=${file_path}
    Should Contain    ${normal_release}    ${Failure_Reason_value}

Check PM counter for 8232
    [Arguments]    ${counter_id}    ${counter_dic_path}    ${counter_should_value}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Get PM counter for 8232    counter_id=${counter_id}
    ...    dic_path=${counter_dic_path}    value=${counter_should_value}    gnb_index=${gnb_index}


Get PM counter for 8232
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should contain    ${counter_value}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check PM counter for 8232_failed case
    [Arguments]    ${counter_id}    ${counter_dic_path}    ${counter_should_value}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Get PM counter for failed    counter_id=${counter_id}
    ...    dic_path=${counter_dic_path}    value=${counter_should_value}    gnb_index=${gnb_index}

Get PM counter for failed
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    '${counter_value}' > '${value[${index}]}'
    END
    [Teardown]    COAM Teardown gnb connections

Get ra_Prio from BIP_SIB1
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    dldata_pdschpayloadtbsendreq && 3gpp.subcellid == 0
    ${ra_Prio}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.ra_PrioritizationForAI_r16
    ...            attribute_name=show
    [Return]    ${ra_Prio[0]}

Check ra_Prio from BIP_SIB1
    [Arguments]    ${file_path}    ${ra_Prio_value}
    ${ra_Prio}=    Get ra_Prio from BIP_SIB1    file_path=${file_path}
    Should Contain    ${ra_Prio}    ${ra_Prio_value}

Get A3_measreport from wiresharklog
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.measurementReport_element
    ${A3_measID}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.measId
    ...            attribute_name=show
    [Return]    ${A3_measID}

Check measID is A3_measreport
    [Arguments]    ${file_path}    ${A3_measID_value}
    ${A3_measID}=    Get A3_measreport from wiresharklog    file_path=${file_path}
    Should Contain    ${A3_measID}    ${A3_measID_value}

Get nRCellIdentity from RRCReconfiguration
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.value_element
    ${nRCellIdentity}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//f1ap.nRCellIdentity
    ...            attribute_name=showname
    ${nRCellIdentity}=    String.Split String    ${nRCellIdentity[0]}    :${SPACE}
    ${nRCellIdentity_1}=    String.Split String    ${nRCellIdentity[1]}    value${SPACE}
    ${nRCellIdentity_2}=    String.Split String    ${nRCellIdentity_1[1]}    ]
    ${nRCellIdentity}=    String.Split String    ${nRCellIdentity_2[0]}
    [Return]    ${nRCellIdentity}

Check nRCellIdentity is nrcellid
    [Arguments]    ${file_path}    ${nrcellid}
    ${nRCellIdentity}    Get nRCellIdentity from RRCReconfiguration    file_path=${file_path}
    Should Be True    '${nRCellIdentity[0]}' == '${nrcellid}'

Get HO_failure_reason from HPF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    xnap.HandoverPreparationFailure_element
    ${HO_failure_reason}    Check Target Item Value on CPIF Tcpdump log
    ...            filter=xnap
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//xnap.radioNetwork
    ...            attribute_name=showname
    ${HO_failure_reason_1}=    String.Split String    ${HO_failure_reason[0]}    :${SPACE}
    ${HO_failure_reason}=    String.Split String    ${HO_failure_reason_1[1]}    ${SPACE}(
    [Return]    ${HO_failure_reason}

Check HO_failure_reason is expect
    [Arguments]    ${file_path}    ${HO_failure_expect}
    ${HO_failure_reason}    Get HO_failure_reason from HPF    file_path=${file_path}
    Should Contain     ${HO_failure_reason}    ${HO_failure_expect}

Get ra_Prio from RRCReconfiguration_SIB1
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element
    ${ra_Prio}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.ra_PrioritizationForAI_r16
    ...            attribute_name=show
    [Return]    ${ra_Prio[0]}

Check ra_Prio from RRCReconfiguration_SIB1
    [Arguments]    ${file_path}    ${ra_Prio_value}
    ${ra_Prio}=    Get ra_Prio from RRCReconfiguration_SIB1    file_path=${file_path}
    Should Contain    ${ra_Prio}    ${ra_Prio_value}

Get ho from handoverRequest
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    xnap.HandoverRequest_element
    ${radioNetwork}    Check Target Item Value on CPIF Tcpdump log
    ...            filter=xnap
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//xnap.radioNetwork
    ...            attribute_name=show
    [Return]    ${radioNetwork}

Get hoack from HandoverRequestAcknowledge
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate     xnap.procedureCode
    ${HRACK}    Check Target Item Value on CPIF Tcpdump log
    ...            filter=xnap
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//xnap.HandoverRequestAcknowledge_element
    ...            attribute_name=showname
    [Return]    ${HRACK}

Get RRCRecomplete from RRCReCC
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.initiatingMessage_element
    ${rrcRe_Co}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.rrcReconfigurationComplete_element
    ...            attribute_name=showname
    [Return]    ${rrcRe_Co}

Check inter-Gnb HO success in Targetcell
    [Arguments]    ${file_path}
    ...            ${radioNetwork_value}=${1}
    ...            ${HRACK_value}=HandoverRequestAcknowledge
    ...            ${rrcRe_Co_value}=rrcReconfigurationComplete
    ${radioNetwork}    Get ho from handoverRequest    file_path=${file_path}
    ${HRACK}    Get hoack from HandoverRequestAcknowledge    file_path=${file_path}
    ${rrcRe_Co}    Get RRCRecomplete from RRCReCC    file_path=${file_path}
    Should Be True    '${radioNetwork[0]}' == '${radioNetwork_value}'
    Should Contain    ${HRACK}     ${HRACK_value}
    Should Contain    ${rrcRe_Co}     ${rrcRe_Co_value}

Get 5QI_value from pdusession
    [Arguments]    ${file_path}    ${pdusession_element}=ngap.PDUSessionResourceModifyRequestTransfer_element
    ${message_filter_expression}    Catenate    ${pdusession_element}
    ${5QI_value}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.fiveQI
    ...            attribute_name=show
    [Return]    ${5QI_value}

Get 5QI1_value from pdusession
    [Arguments]    ${file_path}    ${pdusession_element}=ngap.PDUSessionResourceModifyRequestTransfer_element
    ${message_filter_expression}    Catenate    ${pdusession_element}
    ${5QI_value}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.fiveQI
    ...            attribute_name=show
    ...            filter=ngap.procedureCode == 26 && ngap.fiveQI ==1
    [Return]    ${5QI_value}

Get 5QI5_value from pdusession
    [Arguments]    ${file_path}    ${pdusession_element}=ngap.PDUSessionResourceModifyRequestTransfer_element
    ${message_filter_expression}    Catenate    ${pdusession_element}
    ${5QI_value}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.fiveQI
    ...            attribute_name=show
    ...            filter=ngap.procedureCode == 29 && ngap.fiveQI ==5
    [Return]    ${5QI_value}

Get drb_Identity from UEContext
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.drb_Identity==4
    ${drb_Identity}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.drb_Identity
    ...            attribute_name=showname
    [Return]    ${drb_Identity}


Check 5QI1 and 5QI5 both exist
    [Arguments]    ${file_path}    ${drb-Identity_value}
    #${5QI_1}=    Get 5QI_value from pdusession    file_path=${file_path}
    ${5QI_1}=    Get 5QI1_value from pdusession    file_path=${file_path}    pdusession_element=(ngap.procedureCode == 26 && ngap.fiveQI ==1)
    ${5QI_5}=    Get 5QI5_value from pdusession    file_path=${file_path}    pdusession_element=(ngap.procedureCode == 29 && ngap.fiveQI ==5)
    Should Be True    '${5QI_1[0]}' == '${1}' and '${5QI_5[0]}' == '${5}'
    ${drb_Identity}=    Get drb_Identity from UEContext    file_path=${file_path}
    Should Contain    ${drb_Identity}    ${drb-Identity_value}
#    Should Contain X times    ${drb_Identity}    drb-Identity: 7    2

Get normal_release from PDU_Session
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.NGAP_PDU
    ${normal_release}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.nas
    ...            attribute_name=showname
    [Return]    ${normal_release}

Check Call normal release
    [Arguments]    ${file_path}
    ${normal_release}=    Get normal_release from PDU_Session    file_path=${file_path}
    Should Contain X times    ${normal_release}    nas: normal-release (0)    2



Check No_failure and reject MSG
    [Arguments]    ${file_path}
    ${Failure_Reason}=    Run Keyword And Return Status    Get Failure_Reason from InitialContextSetup    file_path=${file_path}
    Should Be True    '${Failure_Reason}'    'False'
    ${RejectReason}=    Run Keyword And Return Status    Get RRC_Reject_Reason from RRC_Reject    file_path=${file_path}
    Should Be True    '${RejectReason}'    'False'

Get user_inactivity from UEContextRelease
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.UEContextReleaseRequest_element
    ${user_inactivity}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.radioNetwork
    ...            attribute_name=showname
    ${user_inactivity_1}=    String.Split String    ${user_inactivity[0]}    :${SPACE}
    ${user_inactivity}=    String.Split String    ${user_inactivity_1[1]}    ${SPACE}(
    [Return]    ${user_inactivity[0]}

Check idle status
    [Arguments]    ${file_path}
    ${user_inactivity}=    Get user_inactivity from UEContextRelease    file_path=${file_path}
    Should Contain    ${user_inactivity}    user-inactivity

Get PagingPriority from Paging
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.Paging_element
    ${PagingPriority}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.PagingPriority
    ...            attribute_name=show
    [Return]    ${PagingPriority}

Check PagingPriority
    [Arguments]    ${file_path}
    ${PagingPriority}    Get PagingPriority from Paging    file_path=${file_path}
    Should Contain    '${PagingPriority}'    '${1}'
    Should Contain    '${PagingPriority}'    '${3}'

Check TMSI_Part2 from server_request
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.initiatingMessage_element
    ${TMSI_Part2}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.ng_5G_S_TMSI_Part2
    ...            attribute_name=showname
    ${TMSI_Part2}=    String.Split String    ${TMSI_Part2[0]}    :${SPACE}
    ${TMSI_Part2}=    String.Split String    ${TMSI_Part2[0]}
    Should Contain X times    ${TMSI_Part2}    ng-5G-S-TMSI-Part2    1

Get TMSI from RRC_Registration_request
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nas_5gs.5g_tmsi
    ${TMSI}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nas_5gs.5g_tmsi
    ...            attribute_name=show
    ${TMSI}=     Evaluate    float(${TMSI}[-1])%2
    [Return]    ${TMSI}

Get UE TMSI
    [Arguments]    ${file_path}
    ${TMSI}    Get TMSI from RRC_Registration_request_or_accept    file_path=${file_path}
    ${TMSI}=     Evaluate    float(${TMSI}[-1])%2
    [Return]    ${TMSI}


Check 5QI9 exist
    [Arguments]    ${file_path}
    ${5QI_9}=    Get 5QI_value from pdusession    file_path=${file_path}    pdusession_element=ngap.PDUSessionResourceSetupRequestTransfer_element
    Should Contain    '${5QI_9}'    '${9}'
    Should Contain    '${5QI_9}'    '${7}'

Get DRBs_ToBeReleased_Item exist
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    f1ap.initiatingMessage_element
    ${DRBs_ToBeReleased}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//f1ap.DRBs_ToBeReleased_Item_element
    ...            attribute_name=showname
    [Return]    ${DRBs_ToBeReleased}

Get PDUSessionResourceNotify
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.PDUSessionResourceNotify_element
    ${PDUSessionResourceNotify}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.radioNetwork
    ...            attribute_name=showname
    ${PDUSessionResourceNotify}=    String.Split String    ${PDUSessionResourceNotify[0]}    :${SPACE}
    ${PDUSessionResourceNotify}=    String.Split String    ${PDUSessionResourceNotify[1]}    ${SPACE}(
    [Return]    ${PDUSessionResourceNotify}

Check one DRB_released after handover
    [Arguments]    ${file_path}
    ${DRBs_ToBeReleased}    Get DRBs_ToBeReleased_Item exist    file_path=${file_path}
    Should Contain X times    ${DRBs_ToBeReleased}    DRBs-ToBeReleased-Item    1
    ${PDUSessionResourceNotify}    Get PDUSessionResourceNotify    file_path=${file_path}
    Should Contain    ${PDUSessionResourceNotify}    radio-resources-not-available

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}    ${release_info.split('_')[0]}
    [Return]    ${release_info}

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