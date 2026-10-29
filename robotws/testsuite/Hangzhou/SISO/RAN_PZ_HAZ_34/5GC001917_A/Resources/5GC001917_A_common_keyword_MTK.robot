*** Settings ***
Documentation
...    author: liuxu
...    contact:xu.2.liu@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : 5GC001917_A


Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.pdu
Library    Telnet  WITH NAME   telnets
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library     taf.config.testline    WITH NAME    testline
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
#Library    ../../../../RRM/Hangzhou/libraries/L3Call.py
Library      taf.ul.messaging.mtk    WITH NAME    mtk
#Resource    taf/rfrl/common_resources/robot/resources/common/stream_manager.robot   pipline fail if exist
#Resource    taf/rfrl/common_resources/robot/resources/common/gnb_classical.robot    pipline fail if exist
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    ../../../../../testsuit/SISO/Hangzhou/common/RRH_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_average_throughput.py
#Library    ../../../../../resources/python_libs/Attenuation.py
#Library    ../../../../../resources/python_libs/TestCaseRequirement.py    WITH NAME    TestCaseRequirement
Library    taf.ue  WITH NAME   ute_ue
#Library    MTKUE_extend.MTKUE    WITH NAME   MTKUE    pipline fail if exist
#Library    Attenuation.Attenuation    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001917_A/Resources/__init__.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
#${tl_scf_dir_path}    /home/ute/SQ3project/SCF/
#${tl_scf_filename}    TL236_gnb_scf_1917A09.xml
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${enb_default_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_default_para}    defaultLnRelGnbCellId
${ALIAS_ASIK}    ASIK
${enb_instance}    ${tl.enbs[0].instance_id}

## Attenuator parameter ##
#${atten_ip}    ${tl.attenuator[0].ip_addr}
#${att_port_1}    ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2}    ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_3}    ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_4}    ${tl.attenuator[0].attenuator_ports[4]}
#${att_api_port}    ${tl.attenuator[0].port}
#${vendor}    HBTE
#${vendor1}    TOPYOUNG
#${max_attenuation_value}    ${127}

${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${fsp2a_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].addr}
${ue_type}     ${tl.ues[0].capabilities[0]}
${ul_port}    ${tl.appserver.iperf_details.port}
${dl_port}    ${tl.ues[0].iperf_details.port}
${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
${enbx2_para}    administrativeState
${x2_sctp_port}    29211
${tl_scf_filename_gnb}    TL345_gnb_SCF_2x2_Open_dlMimoMode.xml
${tl_scf_filename_enb}    TL345_240_enb_2cell_scf.xml
${ue_index}     0

#${DL_TPUT}    20
#${UL_TPUT}    200
#${expect_dl}    5
#${expect_ul}    50
${sleep_time}    10


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
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

*** Keywords ***
Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}    is_pdl_checking_needed=False

Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}


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


PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=FACOM
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE    taf.pdu.power_on    port=${Port_Number}
    sleep   15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    Run Keyword If    '${Action}'=='power_off'    should be equal    ${state}    off
    ...    ELSE    should be equal    ${state}    on


Make l3 call only
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}

Make ULDL Traffic and verify TP
    [Arguments]    ${dlexpect_tp}    ${ulexpect_tp}    ${cell_id}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=10M
    ...    duration=300s    iperf_port=${dl_port}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=10M
    ...    duration=300s    iperf_port=${ul_port}    ue_index=${ue_index}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=dl    throughput=${dlexpect_tp}
    ...    ue_type=${ue_type}   ue_index=${ue_index}    cellid=${cell_id}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=ul    throughput=${ulexpect_tp}
    ...    ue_type=${ue_type}   ue_index=${ue_index}    cellid=${cell_id}
    [Teardown]    run keywords
    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}    ue_index=${ue_index}
    ...    AND
    ...    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}    ue_index=${ue_index}


Case env recovery
    Cell Should Be Unlocked    cell_idx=${1}    cell_group_idx=${0}    timeout=10    connection=GNB_OAM
    Run keyword and ignore error    disconnect all connections

Case env recovery for L3 call
    Case env recovery
    adjust the HBTE attenuation value    value_1=${26}    value_2=${26}   value_3=${26}    value_4=${26}
    Run Keyword And Ignore error    MTK Detach


Restart UE Control PC
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    Connect to UE control pc enhanced    ue_index=${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect      connection=cpc_${ue_index}

Connect to UE control pc enhanced
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
    ${cpc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_usrname} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_passwd} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${cpc_status}    run keyword and return status      Connect to control pc
    ...     cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               restart cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}
    ...    cpc_passwd=${cpc_passwd}
    run keyword if    '${cpc_status}'=='False' and ${telnet}      Connect to control pc
    ...         cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}


Case env recovery for cell lock
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    Perform Cell Unlock
    ...    cell_idx=${1}
    Case env recovery for L3 call


Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    Perform full commission for COAM gnb
    Check gnb COAM classical start normally
    Wait the gNB cell onair

Perform full commission for COAM gnb BTS
    [Arguments]    ${scf}=${tl_scf_dir_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Perform full commission for COAM gnb
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    sleep    1min


Check gnb COAM classical start normally for 1514
    wait until keyword succeeds    15min   30s    Check the gnb RU status ready



Check gnb COAM classical start normally
    #Check Airscale HW module status
    sleep    60s
    Check the gnb RU status ready


Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections


Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections


Check the gnb all cell status onair
    [Arguments]    ${cell_no}=1    #${gnb_ip}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}      username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error   
    ...    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Get all cell info
    [Arguments]    ${cell_no}
    FOR   ${cell_idx}    IN     1    ${cell_no}
        Get cell info    cell_idx=${cell_idx}
    END

Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell1_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    Get info status check for gnb    info_status=${cell1_status}


Get info status check for gnb
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
#    ${opr_state} =   get from dictionary    ${status}    Operational state
#    should be equal    ${opr_state}    enabled
#    ${avi_state} =   get from dictionary    ${status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Wait the gNB cell onair
#    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    wait until keyword succeeds    15min   30s    Check the gnb cell status onair

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

#Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}

#Common Suite Teardown for COAM
#    connect to gnb coam via ssl
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
#    COAM Teardown gnb connections

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Evaluate DL throughput
    [Arguments]    ${dl_expect}
    wait until keyword succeeds    1min    30s    Caculate DL throughput on gnb side
    ...    hw_slot=${1}    abil_alias=abil1    dl_expect=${dl_expect}

Evaluate UL throughput
    [Arguments]    ${ul_expect}
    wait until keyword succeeds    1min    30s    Caculate UL throughput on gnb side
    ...    hw_slot=${1}    abil_alias=abil1    ul_expect=${ul_expect}

Caculate DL throughput on gnb side
    [Documentation]  This keyword check the DL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${hw_slot}    ${abil_alias}    ${dl_expect}
    wait until keyword succeeds    1 min    10 sec    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    ...    alias=${abil_alias}
    ${dl_tp_l2lo}=    Get_And_Calculate_DL_throughput    alias=${abil_alias}    duration=30    location=${16}
    should be true    ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=${abil_alias}    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master

Caculate UL throughput on gnb side
    [Documentation]  This keyword check the UL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${hw_slot}    ${abil_alias}    ${ul_expect}
    wait until keyword succeeds    1 min    10 sec    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    ...    alias=${abil_alias}
    ${ul_tp_l2lo} =    Get_And_Calculate_UL_throughput    alias=${abil_alias}    duration=30
    should be true    ${ul_tp_l2lo} > ${ul_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=${abil_alias}    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master


disconnect all connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1
    Run keyword and ignore error    csn.Disconnect    connection=RU_2
    Run keyword and ignore error    csn.Disconnect    connection=RU_3

adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}
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
    sleep    5s


Prepare env with UE
    power_ue.Prepare UE    ue_type=huawei

Start UL traffic
#    [Arguments]    ${iperf_port}=${ul_port}
    power_ue.Start traffic    ue_type=huawei    direction=ul    throughput=20M    duration=600    protocol=udp
    ...    ue_index=0    dt_index=0    iperf_port=${ul_port}    interval=1    buffer_size=1024B    dt_name==DT_1
    ...    ue_alias=UE_1

Start DL traffic
#    [Arguments]    ${iperf_port}=${dl_port}
    power_ue.Start traffic    ue_type=huawei    direction=dl    throughput=100M    duration=600    protocol=udp
    ...    ue_index=0    dt_index=0    iperf_port=${dl_port}    interval=1    buffer_size=1024B    dt_name==DT_1
    ...    ue_alias=UE_1

Stop UL traffic
    power_ue.Stop traffic    ue_type=huawei    direction=ul    ue_index=0

Stop DL traffic
    power_ue.Stop traffic    ue_type=huawei    direction=dl    ue_index=0

disconnect BTS connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1


Perform full commission for COAM BTS
    [Arguments]    ${BTS}    ${scf_file_path}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${BTS}
    COAM Commission with scf file    scf_file_path=${scf_file_path}    timeout=600    connection=enblte
    ...    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Check the enb cell status onair
    [Arguments]    ${eNB_BTS}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${eNB_BTS}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Modify the parameter on enb bts
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=${dist_name}     parameter_name=${parameter}    value=${value}
    enblte.teardown    connection=enblte

Prepare with COMA classical gnb BTS cell onair
    Perform full commission for COAM gnb BTS
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally for 1514
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Check the gnb all cell status onair    cell_no=2

Prepare with COMA classical gnb BTS cell onair TL347
    Perform full commission for COAM gnb BTS
    Connect and Modify the parameter on enblte for 1917    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally for 1514
    Connect and Modify the parameter on enblte for 1917    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Check the gnb all cell status onair    cell_no=2

Set default cell
    [Arguments]    ${enb_index}    ${value}
    Connect to eNB via ssl   enb_index=${enb_index}
    Modify the parameter on enblte    dist_name=${enb_default_dist}     parameter_name=${enb_default_para}    value=${value}
    enblte.teardown    connection=enblte


Connect and Modify the parameter on enblte for 1917
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl   enb_index=${1}
    Modify the parameter on enblte    dist_name=${dist_name}     parameter_name=${parameter}    value=${value}
    enblte.teardown    connection=enblte


Prepare the atten
    Adjust RU1 Attenuation to ${5}
#    Adjust RU2 Attenuation to ${5}

Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT1}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}    attenuation_port_numbers_oneport=${5G${RU}_ANT2}

Adjust the Attenuation Value
    [Arguments]     ${ports}    ${value}    ${attenuation_port_numbers_oneport}
    ...     ${atten_ip}=${atten_ip}    ${att_api_port}=${att_api_port}    #${vendor}=${vendor1}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}    vendor=${vendor1}
    attenuator.set_attenuation     port=${ports}    value=${value}
    ${value_port_1}    attenuator.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${value}
    sleep    5s

Verify 5GRACH success times on gnb side
    [Arguments]    ${abil}=asp1a    ${gnb_index}=1
    wait until keyword succeeds    1 min    10 sec    Connect to BB${gnb_index} master     alias=asik
    wait until keyword succeeds    1 min    10 sec    Connect to ${abil}    alias=${abil}    proxy=asik
    ${output} =    csn.execute    command=journalctl -b | grep "flow control starts" |grep -v grep
    ...                           connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=asik
    @{list}    split string    ${output}    \n
    ${len} =    Get Length    ${list}
    [return]    ${len}

Adjust RU Attenuation ${value1} ${value2}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

get CellID
    [Arguments]    ${lcrid}
    ${cell1_id}    COAM Get nrcellid with the lcrid    lcrid=${lcrid}
    set suite variable    ${cell1_id}

COAM get cell id
    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ${info_cell1}    selenium_coam.get_cell_info    cell_idx=${1}
    ${info_cell2}    selenium_coam.get_cell_info    cell_idx=${2}
    set suite variable    ${cell1_id}    ${info_cell1['NR cell ID']}
    set suite variable    ${cell2_id}    ${info_cell2['NR cell ID']}
    selenium_coam.logout

Start DL UL traffic and monitor throughput
    [Arguments]    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=1200s
    ...    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=1200s
    ...    ue_index=${ue_index}
    Evaluate throughput on source cell    cell_id=${cell_id}    ue_index=${ue_index}


Evaluate throughput on source cell
    [Arguments]     ${ue_index}=${0}        #${gnb_index}=${0}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_tp_expect}    ue_index=${ue_index}
    ...    cellid=${cell_id}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_tp_expect}    ue_index=${ue_index}
    ...    cellid=${cell_id}

Evaluate throughput on target cell
    [Arguments]    ${cell_id}=${cell2_id}     ${ue_index}=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}
    ...    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_expect}
    ...    ue_index=${ue_index}
    ...    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}

Start Capture Classical x2_WS Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=ASIK    interface=any

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and Save classical x2_WS Logs
    [Arguments]    ${x2logname}
    gNB connections
    Stop and download Logs    logname=${x2logname}    connection=ASIK

Kill tcpdump process
    [Arguments]    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}
    ...    connection=${connection}
    sleep    3

Tests Recovery
    [Arguments]    ${x2logname}    ${value1}=${5}    ${value2}=${5}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    run keyword and ignore error    Stop and Save classical x2_WS Logs    x2logname=${x2logname}
    csn.disconnect    connection=enb
    csn.disconnect    connection=ASIK
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Close the iperf process on APPserver    dl_port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${0}
    Recover the env atten to normal value    value1=${value1}    value2=${value2}

Recover the env atten to normal value
    [Arguments]    ${value1}    ${value2}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

##power UE
Precondition for power UE
    [Arguments]    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset
    ...    detach_request=${true}

#Attach and check power UE
#    [Arguments]    ${ue_type}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}

Stop power UE dl traffic
    [Arguments]     ${ue_type}    ${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Detach power UE
    [Arguments]    ${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Stop power UE dl traffic and detach
    [Arguments]     ${ue_type}    ${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}


Get Cell num and RU num
    [Arguments]    ${connection}=GNB_OAM
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Log to console    Get Cell num and RU num
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${cell_no}     RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    Set Suite Variable    ${cell_no}
    Set Suite Variable    ${count_RUs}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

power UE.Start DLUL traffic
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}
    Attach and check power UE     ue_type=${ue_type}
    ${nrcell_id}    get nrCellid    cellid=1
    Log to console    \nINFO:power_ue.Start traffic ul
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    sleep     5s
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    Log to console    \nINFO:power_ue.Start traffic dl


UE.Start DLUL traffic
    power UE.Start DLUL traffic    data_transfer_dl=${DL_TPUT}
    ...      data_transfer_ul=${UL_TPUT}
    ...      duration=1200s


UE.Start DLUL traffic and Caculate throughput
    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput
    ...    data_transfer_dl=${DL_TPUT}
    ...    data_transfer_ul=${UL_TPUT}
    ...    duration=1800s
    ...    Expected_Throughput_DL=${expect_dl}
    ...    Expected_Throughput_UL=${expect_ul}
    Should be true     ${status}

power UE.Start DLUL traffic and Caculate throughput
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...     ${Expected_Throughput_UL}
    Attach and check power UE     ue_type=${ue_type}
    ${nrcell_id}    get nrCellid    cellid=1
    Log to console    \nINFO:power_ue.Start traffic ul
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    sleep     20s
    Run Keyword And Ignore Error    UE.Check throughput     ue_type=${ue_type}     direction=ul
    ...     throughput=${Expected_Throughput_UL}     cellid=${nrcell_id}    sleep_time=${sleep_time}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    Log to console    \nINFO:power_ue.Start traffic dl
    sleep     240s
    #sleep     ${duration}
    UE.Check throughput     ue_type=${ue_type}     direction=dl     throughput=${Expected_Throughput_DL}
    ...     cellid=${nrcell_id}    sleep_time=${sleep_time}
    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown


UE.Check throughput
    [Arguments]    ${ue_type}    ${direction}    ${throughput}    ${deviation}=10
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${gnb_index}=${0}    #${ue_alias}=UE_${ue_index}
    ...    ${du_index}=${0}
    ...            ${hw_slot}=${1}    ${sample}=${8}    ${start_offset}=${2}    ${sleep_time}=${10}
    ...    ${cellid}=${EMPTY}
    ...            ${log_type}=Aasyslog
    [Documentation]    Check throughput from started traffic.
    [Timeout]      10min
    Log to console    \nINFO:power_ue.Check throughput
    Wait Until Keyword Succeeds    8min    30sec    power_ue.Check throughput     ue_type=${ue_type}
    ...     direction=${direction}     throughput=${throughput}     cellid=${cellid}    sleep_time=${sleep_time}
    ...     deviation=${deviation}     ue_index=${ue_index}     dt_index=${dt_index}    ue_alias=$UE_${ue_index}
    ...     gnb_index=${gnb_index}     du_index=${du_index}     hw_slot=${hw_slot}    sample=${sample}
    ...     start_offset=${start_offset}     log_type=${log_type}

UE.traffic.Teardown
    Log to console    \nINFO:Stop traffic
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul     iperf_port=${ul_port}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    Run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

Detach for power UE
    [Arguments]    ${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}


Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
     [Return]    ${value}

get nrCellid
    [Arguments]    ${cellid}
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-1/NRCELL-${cellid}
    ...    filter_name=NR Cell Identity
    [Return]    ${value}

Restore env for huawei UE
    Run keyword and ignore error    UE.traffic.Teardown
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Run keyword and ignore error    Kill tcpdump process    connection=ASIK
    Run keyword and ignore error    disconnect BTS connections

COAM_WebEM.Login
    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s

COAM_WebEM.Logout
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Lock Cell
    [Arguments]   ${cell_idx}=2    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"
    ...                selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    Sleep  4min
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Locked"

Unlock Cell
    [Arguments]   ${cell_idx}=2    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"
    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
    Sleep  4min
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Unlocked"

power UE.SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22    ${DLTPpercent}=90    ${ULTPpercent}=90
    ${DL_TPUT1}     Evaluate     ${dl[:-1]}*110/100.00
    ${UL_TPUT1}     Evaluate     ${ul[:-1]}*110/100.00
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${UL_TPUT1}M
    Set Test Variable    ${DL_TPUT}    ${DL_TPUT1}M
    ${expect_ul}    Evaluate    ${ul[:-1]}*${ULTPpercent}/100.00/2
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${dl[:-1]}*${DLTPpercent}/100.00
    Set Test Variable    ${expect_dl}

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
