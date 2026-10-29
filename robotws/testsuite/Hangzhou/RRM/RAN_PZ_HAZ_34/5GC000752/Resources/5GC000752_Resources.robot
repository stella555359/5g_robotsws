*** Settings ***
Documentation    author: Liu Geng, Lou Shuhui
...               contact: geng.liu@nokia-sbell.com,shuhui.lou@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000752-Z
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py
Library           ../../5GC000638/Resources/coam_close.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

#${CFGFILE_PATH}             /home/ute/TAF/cfgfile/
${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC000752/
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

${lua_script_path}          /home/ute/TAF/cfgfile/luashark/generated_luashark/luashark.lua
${Original_CFGFILE}         ${LOG_PATH}/752_SCF.xml
${Original_CFGFILE_752G}    ${LOG_PATH}/Configuration_scf_for_752G.xml
${MODIFIED_CFGFILE_1}       ${LOG_PATH}/notification_ue.xml
${MODIFIED_CFGFILE_2}       ${LOG_PATH}/notification_drb.xml
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  4001

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${IMSI}                     ${tl.ues[0].imsi}

${APN1_IP}                  ${tl.ues[0].wapserver[0].addr}
${APN1_USERNAME}            ${tl.ues[0].wapserver[0].username}
${APN1_PASSWORD}            ${tl.ues[0].wapserver[0].password}

${APN2_IP}                  ${tl.test_pc.default_ssh_connection_details.addr}
${APN2_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${APN2_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}

${UL_TP}                    5
${DL_TP}                    10

${MRBTS_ID}   				MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}


${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}                MTKPC                                             ##
${ALIAS_APN1}               APN1                                                ##
${ALIAS_APN2}               APN2                                                ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000752_C_09_Initial Context Setup with one or multiple PDU sessions without UE Radio Capability
#    [Setup]    Setup case
    [Tags]    5GC000752_C    CIT_19B    CIT_TRUNK    CIT_20A    CIT_20B    CIT_21A
#    [Teardown]  Teardown case
#    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Clear UE info from AMF
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_UE_capability.pcap
    sleep    5s
#    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
#    Run Keyword And Ignore Error        spark.power_off    ue_alias=${UE_alias}
#    sleep    10s
#    Run Keyword And Ignore Error        spark.power_on     ue_alias=${UE_alias}
#    spark.enable_ue_data_service    ue_alias=${UE_alias}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'

    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=600
    ...    apn_address=mdrbnokiacom
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=600
    ...    apn_address=mdrbnokiacom
    sleep    60
#    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=120
#    COAM_WebEM.Login
#    &{output}    selenium_coam.get_cell_info
#    ${list_of_cell_ids}    Create list   &{output}[NR cell ID]
#    Power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${tput_log}    cells=${list_of_cell_ids}
#    ...    ultarget_throughput=5    dltarget_throughput=50   target_avg_percent=0.9    min_percent=0.7
    process.check_Bi_throughput    ue_type=${UE_TYPE}   ultarget_throughput=5    dltarget_throughput=10
    ...    target_avg_percent=0.9    min_percent=0.7    cell_idx=1
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5    start_offset=${0}
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2    start_offset=${0}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl       apn_address=mdrbnokiacom
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul       apn_address=mdrbnokiacom
#    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_UE_capability.pcap
    sleep    5s
    Wireshark.ReadLog    filename=NG_UE_capability.pcap    filter=ngap.procedureCode == 44
    Wireshark.Check PDUsession without UEcapability
    Wireshark.Action.Close

TC.5GC000752_B_07_PDU_session_resource_release with no PDU session remain
#    [Setup]    Setup case
    [Tags]    5GC000752_B    CRT_19B    CRT_19B    CRT_TRUNK    CRT_20A    CRT_20B    CRT_21A
#    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_1st_pdu_release.pcap
    sleep    5s
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}
#    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
#    Run Keyword And Ignore Error        spark.power_off    ue_alias=${UE_alias}
#    sleep    10s
#    Run Keyword And Ignore Error        spark.power_on     ue_alias=${UE_alias}
#    power_ue.Verify attach    ue_type=${UE_TYPE}
#    spark.enable_ue_data_service    ue_alias=${UE_alias}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'

    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=600
    ...    apn_address=mdrbnokiacom
    sleep    60s
#    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=120
#    COAM_WebEM.Login
#    &{output}    selenium_coam.get_cell_info
#    ${list_of_cell_ids}    Create list   &{output}[NR cell ID]
#    Power_ue.Check Tput    ue_type=${UE_TYPE}    log=${tput_log}    cells=${list_of_cell_ids}
#    ...    direction=ul    target_throughput=5    target_avg_percent=0.9    min_percent=0.7
    process.check_Bi_throughput    ue_type=${UE_TYPE}   ue_index=${0}   ultarget_throughput=5
    ...    dltarget_throughput=0    target_avg_percent=0.9    min_percent=0.7    cell_idx=1

#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul     apn_address=mdrbnokiacom
#    spark.disable_ue_data_service    ue_alias=${UE_alias}
#    sleep    5s
#    power_ue.UE Detach    ue_type=${UE_TYPE}
#    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    sleep     5s
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_1st_pdu_release.pcap
    Wireshark.ReadLog    filename=NG_1st_pdu_release.pcap    filter=ngap.NGAP_PDU == 0
    Wireshark.Check PDU sessionn release    compare_value=1
    Wireshark.Action.Close
#    [Teardown]  Teardown case

#[1]5GC000752_C_10_Initial Context Setup with one or multiple PDU sessions with UE Radio Capability
#    [Setup]    Setup case
#    [Tags]    5GC000752_C    CRT_19B    CRT_19B    CRT_TRUNK    CRT_20A
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    Wireshark.Action.Capture    filename=NG_one_pdu_setup.pcap    conn=${ALIAS_ASIK}
#    sleep    5s
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}
#    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=120
#    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=120
#    sleep    30
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
#    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
#    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
#    power_ue.UE Detach    ue_type=${UE_TYPE}
#    Wireshark.Action.Stop_And_Download    filename=NG_one_pdu_setup.pcap    conn=${ALIAS_ASIK}
#    sleep    5s
#    Wireshark.ReadLog    filename=NG_one_pdu_setup.pcap    filter=ngap.NGAP_PDU == 0
#    Wireshark.Check PDUsession with UEcapability
#    Wireshark.Action.Close
#    [Teardown]  Teardown case

# need get multidrbip from wireshark
TC.5GC000752_F_22_Cplane counters check for PDU session setup
#    [Setup]    Setup case
    [Tags]    5GC000752_F    CRT_19B    CRT_19B    CRT_20B
#    [Teardown]  Teardown case
    COAM_Admin.Login
    COAM_Admin.ResetSite    timeout=15min
    COAM_Admin.Logout
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=120
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=120
    sleep    30
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
#    spark.disable_ue_data_service    ue_alias=${UE_alias}
#    power_ue.UE Detach    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    sleep    5
#    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=120
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=120
    sleep    30
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
#    spark.disable_ue_data_service    ue_alias=${UE_alias}
    sleep    5
#    power_ue.UE Detach    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    
    sleep    5
    COAM_WebEM.Login
    Wait until keyword succeeds   5x   4min    Check Cplane counter from gNB
    COAM_WebEM.Logout

#[1]5GC000752_F_23_Uplane counters check for PDU session setup
#    [Setup]    Setup case
#    [Tags]    5GC000752_F   CRT_19B    CRT_19B    CRT_TRUNK    CRT_20A
#    [Teardown]  Teardown case
#    COAM_WebEM.Login
#    Wait until keyword succeeds   5x   8min    Check Uplane counter from gNB
#    COAM_WebEM.Logout

TC.5GC000752_G_02_Enhancement by UE Capabilities initial context setup optimized with PDU Session and UE Capabilities
#    [Setup]    Setup case
    [Tags]    5GC000752_G    CRT_19B    CRT_19B    CRT_TRUNK    CRT_20A    CRT_20B    CRT_21A
    #ChangeSwcofigByFlag    flag=0x590048    value=1
    #gNB.Commission    scf_file=${Original_CFGFILE_752G}    timeout=${2400}
    #Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Clear UE info from AMF
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=Modification.pcap    nodename=CPIF
    #Wireshark.CaptureBIPLog
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#   ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=600
    ...      apn_address=mdrbnokiacom
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=600
    ...       apn_address=mdrbnokiacom
    sleep    60
#    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=120
#    COAM_WebEM.Login
#    &{output}    selenium_coam.get_cell_info
#    ${list_of_cell_ids}    Create list   &{output}[NR cell ID]
#    Power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${tput_log}    cells=${list_of_cell_ids}
#    ...    ultarget_throughput=5    dltarget_throughput=50    target_avg_percent=0.9    min_percent=0.7
    process.check_Bi_throughput    ue_type=${UE_TYPE}   ultarget_throughput=5    dltarget_throughput=10
    ...    target_avg_percent=0.9    min_percent=0.7    cell_idx=1
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2

    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl     apn_address=mdrbnokiacom
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul     apn_address=mdrbnokiacom
#    power_ue.UE Detach    ue_type=${UE_TYPE}
#    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    gNB.Connect
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    #Wireshark.Action.Stop_And_Download    listen_port=ethbp1    localname=BIP256QAM.pcap    conn=${ALIAS_ASIK}
    wireshark.DownloadLogToUTEFromContainer    filename=Modification.pcap   nodename=CPIF
    gNB.Disconnect
    Wireshark.ReadLog    filename=Modification.pcap    filter=f1ap.procedureCode == 7
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    f1ap.F1AP_PDU==1
    Wireshark.ReadLog    filename=Modification.pcap    filter=f1ap.procedureCode == 7
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    f1ap.F1AP_PDU==0
    Wireshark.Action.Close
#    [Teardown]  Teardown case

#[1]5GC000752_G_05_Enhancement by UE Capabilities 256 QAM enabled and 4x4 Open Loop MIMO
#    [Setup]    Setup case
#    [Tags]    5GC000752_G    CRT_19B    CRT_19B    CRT_TRUNK    CRT_20A
#    Wireshark.ReadBIPLog      filename=BIP256QAM.pcap   filepath=${LOG_PATH}   filter=dldata_pdschsendreq
#    Run Keyword And Continue On Failure   Wireshark.CheckExpression   expression=DlData_PdschSendReq.PdschSendReq.mcsTable == 1
#    Wireshark.Action.Close
#    Wireshark.ReadLog    filename=Modification.pcap    filter=f1ap
#    Run Keyword And Continue On Failure    Wireshark.CheckExpression    nr-rrc.maxMIMO_Layers == 4
#    Run Keyword And Continue On Failure    Wireshark.CheckExpression    nr-rrc.maxNumberMIMO_LayersPDSCH == 1
#    Wireshark.Action.Close
#    [Teardown]  Teardown case

#[1]5GC000752-J_01_User Inactivity cause UE context release procedure both DRB and SRB inactivity detected
#    [Setup]    Setup case
#    [Tags]    5GC000752_J   CRT_19B   CRT_19B    CRT_TRUNK    CRT_20A
#    [Teardown]  Teardown case
#    ChangeSwcofigByFlag    flag=0x590048    value=0
#    Process.ModifyAndCommissionAndCheckOnair
#    ...    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${MODIFIED_CFGFILE_1}    parameters_to_modify=${PARAMS_TO_MODIFY_NOTI_TO_UE}
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    Wireshark.Action.Capture    filename=NG_user_inactivity_UE.pcap    conn=${ALIAS_ASIK}
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#    spark.enable_ue_data_service    ue_alias=${UE_alias}
#    sleep    180s
#    Wireshark.Action.Stop_And_Download    filename=NG_user_inactivity_UE.pcap    conn=${ALIAS_ASIK}
#    Wireshark.ReadLog    filename=NG_user_inactivity_UE.pcap    filter=ngap.NGAP_PDU == 0
#    Wireshark.Check UE context released cause
#    Wireshark.Action.Close
#    power_ue.UE Detach    ue_type=${UE_TYPE}

TC.5GC000752-J_02_User Inactivity cause UE context release procedure when DRB inactivity detected
#    [Setup]    Setup case
    [Tags]    5GC000752_J   CRT_19B   CRT_19B    CRT_20A    CRT_20B
#    [Teardown]  Teardown case
    Process.ModifyAndCommissionAndCheckOnair
    ...    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${MODIFIED_CFGFILE_2}    parameters_to_modify=${PARAMS_TO_MODIFY_NOTI_TO_DRB}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_user_inactivity_DRB.pcap
#    power_ue.UE Attach    ue_type=${UE_TYPE}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=True
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
#    Run Keyword And Ignore Error        spark.power_off    ue_alias=${UE_alias}
#    sleep    10s
#    Run Keyword And Ignore Error        spark.power_on     ue_alias=${UE_alias}
#    spark.enable_ue_data_service    ue_alias=${UE_alias}
    sleep    360s
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_user_inactivity_DRB.pcap
    Wireshark.ReadLog    filename=NG_user_inactivity_DRB.pcap    filter=ngap.NGAP_PDU == 0
    Run Keyword And Ignore Error    Wireshark.Check UE context released cause
    Wireshark.Action.Close
#    power_ue.UE Detach    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_alias=${UE_alias}     ue_type=${UE_TYPE}    power_reset=True
    gNB.connect
    Run Keyword And Continue On Failure    gNB.Check DRB inactivity at gNB side



Process.ModifyAndCommissionAndCheckOnair
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
    ModifyParametersToSCF   input_scf=${original_cfgfile}
    ...    output_scf=${modified_cfgfile}   modify_parameters_lists=${parameters_to_modify}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

ModifyParametersToSCF
    [Documentation]   Modify Parameters in ${modify_parameters_lists} to ${input_scf}
    [Arguments]    ${input_scf}    ${output_scf}    ${modify_parameters_lists}
    ${exist}=    run keyword and return status    File Should Exist    ${CFGFILE_ON_GIT}/Delta_SCF.py
    run keyword if    ${exist}    commissioning.modify_scf    input_scf=${input_scf}
    ...    output_scf=${output_scf}    parameters_lists=${modify_parameters_lists}

#gNB.CommissionWithRetry
#    [Arguments]    ${scf_file}
#    ${status}   Run Keyword And Return Status   gNB.Commission    scf_file=${scf_file}    timeout=${1800}
#    Run keyword if    '${status}'=='False'    gNB.Power.ResetAndCommission    scf_file=${scf_file}

#gNB.Power.ResetAndCommission
#    [Arguments]    ${scf_file}
#    Power.Reset5GRU
#    Power.ResetgNB
#    Sleep    10min
#    wait until keyword succeeds    15min    1min    gNB.VerifyOnAirViaOAMUntilReady
#    gNB.Commission    scf_file=${scf_file}    timeout=${2400}

COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}    ${abbr}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}    abbr=${abbr}

COAM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    ssh.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null | head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    ssh.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

Connect to 5GC
    [Arguments]    ${hostname}=${5GC_IP}   ${username}=${5GC_USERNAME}    ${password}=${5GC_PASSWORD}    ${alias}=${ALIAS_5GC}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=${alias}

Disconnect from 5GC
    [Arguments]    ${connection}=${ALIAS_5GC}
    ssh.disconnect    connection=${connection}

#Wireshark.StartCaptureLog
#    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
#    ssh.send command    tcpdump -s 0 -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

Wireshark.Action.Capture
    [Arguments]   ${filename}    ${conn}    ${listen_port}=fp0    ${log_dir}=/tmp
    ASIK.Connect   alias=${conn}
    Wireshark.StartCaptureLog    listen_port=fp0    log_dir=/tmp     filename=${filename}    connection=${conn}
    sleep    2

Wireshark.Action.Stop_And_Download
    [Arguments]   ${conn}=${ALIAS_ASIK}    ${filename}=tcpdumpL2L1_filtering_off.pcap0
    ...   ${log_dir}=/tmp    ${listen_port}=fp0    ${localname}=${filename}
    sleep    2
    Wireshark.StopCapturinglog    connection=${conn}    listen_port=${listen_port}
    sleep    2
    Wireshark.DownloadLogToUTE    filename=${filename}   connection=${conn}    localname=${localname}
    sleep    5

Wireshark.Check PDUsession without UEcapability
    [Arguments]
    [Documentation]  check the UEcapability
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   ngap.procedureCode == 44

Wireshark.StopCapturingALLlog
    ASIK.Connect   alias=${ALIAS_ASIK}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
    ASIK.Disconnect    alias=${ALIAS_ASIK}


Wireshark.Check PDU sessionn release
    [Arguments]    ${compare_value}
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   nas_5gs.sm.message_type == 0xd4
    #${value} =  Run Keyword And Continue On Failure   Wireshark.GetElementValue    ngap.pDUSessionID
    # ...                             ${0}    True   ngap.procedureCode == 28
    #Should Contain   ${value}   ${compare_value}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=${DL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure  gNB.GetDLThroughput
    ...    ALIAS_ASP_1A=${ALIAS_ASP_1A}  duration=10    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Process.GetULBlerAndTP
    [Arguments]    ${ULThroughput}=${UL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}      Run Keyword And Continue On Failure   gNB.GetULThroughput   ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    #Set Test Variable    ${bler}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}

Check Cplane counter from gNB
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55124C03001    target_value=3
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55124C03002    target_value=3
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55124C03003    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55124C03004    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02501    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02502    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02504    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02505    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02506    target_value=0
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02507    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55125C02508    target_value=1


COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}>=${target_value}

Wireshark.Check UE context released cause
    [Arguments]
    [Documentation]  check UE context released cause is user-inactivity
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   ngap.radioNetwork == 20

gNB.Check DRB inactivity at gNB side
    wireshark.DownloadLogToUTEFromContainer    filename=startup_cp_ue.log   nodename=CPUE
    ${output}=    run    command=cat ${LOG_PATH}/startup_cp_ue.log | grep "inactiv"
    Should Contain    ${output}    Drbs are inactive for

ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Setup suite
    TestSuite.Start
    Import Variables    ${CFGFILE_ON_GIT}Delta_SCF.py
    Create Log Directories
    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    #power_ue.UE Detach    ue_type=${UE_TYPE}
    ${outputfile}    gNB.Generate TL SCF
	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	...                  TestLineSCF_cell_num=${1}    cell_type=Both
	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE}    ${outputfile}
    #ChangeSwcofigByFlag    flag=0x10043    value=50002
    gNB.ModifySCF    InputFile=${Original_CFGFILE}    OutputFile=${LOG_PATH}/752_SCF.xml
    ...     ParameterToDelete=${PARAMS_TO_DELETE_752}    ParamterToModify=${PARAMS_TO_MODIFY_752}
    ...    MOsToAdd=${ADD_MOs_752}    ListToAdd=${ADD_TO_List_752}
    gNB.Commission    scf_file=${LOG_PATH}/752_SCF.xml    timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Conn.ResetCache

KW.CaseInit
    TestCase.Start
    Log to console    Case setup

KW.CaseDestroy
    Run Keyword And Ignore Error    gNB.connect
    Run Keyword And Ignore Error    Wireshark.StopCaptureNGLog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE    filename=NG_UE_capability.pcap
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    Wireshark.StopCapturingALLlog
    Conn.ResetCache
    TestCase.Stop

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

GetAttachvalue
    [Arguments]
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    30s
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${0}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'

TestSuilt.Destroy
    Run Keyword And Ignore Error    run    cat ${TP_FILE}
    TestSuite.Stop
