*** Settings ***
Library     DateTime
#Library     L3Call.py
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
#Library     ./../../common/delete_ue_and_sip_context.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Resource    ./../../5GC001927-T/Resources/5GC001927-T_coam_common_keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ./5GC000749A_common_keywords.robot
Resource    ./5GC000749_coam_common_keywords.robot

Documentation
...   author: Shi Ming
...   contact: ming.shi@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC000749

*** Variables ***
${gnb_path}    /tmp
${connection}    gnb
${epc_log_path}    /tmp
${tshark_path}      /usr/bin/tshark
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_PEER}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${enb_instance}     ${tl.enbs[0].instance_id}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${TOPYONG_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}

@{diffTL_enb_ID}    40    38221    911    5395    342

${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    HBTE
${max_attenuation_value}     ${127}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[8]}

${f1_sctp_port}    38472
${x2_sctp_port}    38422

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${ALIAS_5GC}      5gc

${749A08_01_status}    False
@{gnb_list}    ${0}    ${1}

*** Keywords ***
Prepare env with UE
    power_ue.Prepare UE    ue_type=huawei

Setup for SA Env cell on-air
    Prepare SA classical COAM BTS cell onair
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair
    Perform full commission for COAM SA gnb    scf=${SCF_path}${SCF_file_name}
    Check gnb COAM classical normally
    Check the gnb cell status onair    cell_no=1

Perform full commission for COAM SA gnb
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections


Check gnb COAM classical normally
#    Check Airscale HW module status
    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    sleep    30s
    Run Keyword And Ignore Error    Check the gnb RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP    port_num=${x2_sctp_port}

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
    Get info status check    info_status=${ru1_status}


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

Check gnb2 COAM classical normally
#    Check gnb2 HW module status
    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp UP on gnb2    port_num=${f1_sctp_port}
    sleep    30s
    wait until keyword succeeds    10min    20s    Check the gnb2 RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP on gnb2    port_num=${x2_sctp_port}

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
    Get info status check    info_status=${ru1_status}

Check the gnb2 cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

unlocked LTE cell
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    unlocked LTE cell on TL40 and TL42    #40
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    unlocked LTE cell on TL40 and TL42    #38221
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    unlocked LTE cell on TL343            #911
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[3]'    unlocked LTE cell on TL40 and TL42    #5395
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[4]'    unlocked LTE cell on TL40 and TL42    #342

unlocked LTE cell on TL40 and TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

#unlocked LTE cell on TL343
#    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
#    ...    parameter=administrativeState
#    ...    value=unlocked
#    sleep    10s

unlocked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

locked LTE cell
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    locked LTE cell on TL40 and TL42    #40
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    locked LTE cell on TL40 and TL42    #38221
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    locked LTE cell on TL343            #911
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[3]'    locked LTE cell on TL40 and TL42    #5395
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[4]'    locked LTE cell on TL40 and TL42    #342


locked LTE cell on TL40 and TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

#locked LTE cell on TL343
#    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
#    ...    parameter=administrativeState
#    ...    value=locked
#    sleep    10s

locked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Check phone attach successfully on SA env
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Make a voice call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
    sleep     10s
    End a call on UE    ue_index=${ue_index}    serial_number=${serial_number}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    Connect to control pc via cygwin
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
    #####make a call on UE with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep   15s

End a call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    #####hang up with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=cd /tmp&&tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
#    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=${connection}
    sleep    3

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute

check value of parameter actRedirect
    [Arguments]    ${value}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actRedirect_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${actRedirect_value}=    selenium_coam.get_parameter_value    dist_name=${actRedirect_distname}
    ...    filter_param=Activate RRC Connection Release with redirection    abbr=actRedirect
    Should Be Equal    ${actRedirect_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter actNormVCfallback
    [Arguments]    ${value}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actNormVCfallback_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${actNormVCfallback_value}=    selenium_coam.get_parameter_value    dist_name=${actNormVCfallback_distname}
    ...    filter_param=Activate normal voice call fallback to LTE    abbr=actNormVCfallback
    Should Be Equal    ${actNormVCfallback_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter actNormVCfallback
    [Arguments]    ${new_value}=true    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actNormVCfallback_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${actNormVCfallback_distname}
    ...    filter_param=Activate normal voice call fallback to LTE
    ...    abbr=actNormVCfallback    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter voiceFBmode
    [Arguments]    ${value}=redirection
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${voiceFBmode_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1
    ${voiceFBmode_value}=    selenium_coam.get_parameter_value    dist_name=${voiceFBmode_distname}
    ...    filter_param=Voice fallback mode    abbr=voiceFBmode
    Should Be Equal    ${voiceFBmode_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter redirRat
    [Arguments]    ${value}=eutra
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${redirRat_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1/NRREDRT-0
    ${redirRat_value}=    selenium_coam.get_parameter_value    dist_name=${redirRat_distname}
    ...    filter_param=RAT for Redirection    abbr=redirRat
    Should Be Equal    ${redirRat_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get init value of parameter redirFreqEutra
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${redirFreqEutra_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1/NRREDRT-0
    ${redirFreqEutra_value}=    selenium_coam.get_parameter_value    dist_name=${redirFreqEutra_distname}
    ...    filter_param=E-UTRA frequency for Redirection    abbr=redirFreqEutra
    Set Suite Variable    ${init_redirFreqEutra_value}    ${redirFreqEutra_value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter redirFreqEutra
    [Arguments]    ${value}=${init_redirFreqEutra_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${redirFreqEutra_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1/NRREDRT-0
    ${redirFreqEutra_value}=    selenium_coam.get_parameter_value    dist_name=${redirFreqEutra_distname}
    ...    filter_param=E-UTRA frequency for Redirection    abbr=redirFreqEutra
    Should Be Equal    ${redirFreqEutra_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter drbInactivityTimerSA
    [Arguments]    ${value}=600seconds
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${drbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${drbInactivityTimerSA_value}=    selenium_coam.get_parameter_value    dist_name=${drbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE DRB inactivity timer    abbr=drbInactivityTimerSA
    Should Be Equal    ${drbInactivityTimerSA_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter drbInactivityTimerSA
    [Arguments]    ${new_value}=600seconds    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${drbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${drbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE DRB inactivity timer
    ...    abbr=drbInactivityTimerSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter srbInactivityTimerSA
    [Arguments]    ${value}=60seconds
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${srbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${srbInactivityTimerSA_value}=    selenium_coam.get_parameter_value    dist_name=${srbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE SRB inactivity timer    abbr=srbInactivityTimerSA
    Should Be Equal    ${srbInactivityTimerSA_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter srbInactivityTimerSA
    [Arguments]    ${new_value}=60seconds    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${srbInactivityTimerSA_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${srbInactivityTimerSA_distname}
    ...    filter_param=Stand alone UE SRB inactivity timer
    ...    abbr=srbInactivityTimerSA    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter reportingIntervalPm
    [Arguments]    ${value}=5min
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${reportingIntervalPm_distname}    MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    ${reportingIntervalPm_value}=    selenium_coam.get_parameter_value    dist_name=${reportingIntervalPm_distname}
    ...    filter_param=Performance measurement data reporting interval    abbr=reportingIntervalPm
    Should Be Equal    ${reportingIntervalPm_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

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

Lock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=GNB_OAM
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}    ${timeout}=60
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
#    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}
    coam_gnb_classical.Connect to gnb coam via ssl    bts_host=${bts_host}
#    coam.connect to   bts_host=${bts_host}
#    ...               bts_port=${port}    name=${alias}
#    coam.lock_cell    dist_name=/${administrativeState_distname}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.lock_cell    dist_name=/${administrativeState_distname}
#    ...    connection=${alias}                     #TL367
#    ...    ELSE    coam.lock    dist_name=/${administrativeState_distname}    connection=${alias}
    coam.lock    dist_name=${administrativeState_distname}    timeout=${timeout}    connection=${alias}
    coam.teardown          connection=${alias}

unLock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=GNB_OAM
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}    ${timeout}=60
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
#    coam.connect to   bts_host=${bts_host}    bts_port=${port}    name=${alias}
    coam_gnb_classical.Connect to gnb coam via ssl    bts_host=${bts_host}
#    coam.unlock_cell    dist_name=${administrativeState_distname}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.unlock_cell    dist_name=${administrativeState_distname}
#    ...    connection=${alias}    #TL367
#    ...    ELSE    coam.unlock    dist_name=/${administrativeState_distname}    connection=${alias}
    coam.unlock    dist_name=/${administrativeState_distname}    timeout=${timeout}    connection=${alias}
    coam.teardown          connection=${alias}

lock gnb1 cell2
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

unlock gnb1 cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

lock gnb1 cell${cellID}
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=${cellID}   bts_host=${asik_addr}

unlock gnb1 cell${cellID}
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=${cellID}   bts_host=${asik_addr}

check value of parameter a3MeasEnabled
    [Arguments]    ${value}=none
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${a3MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1
    ${a3MeasEnabled_value}=    selenium_coam.get_parameter_value  dist_name=${a3MeasEnabled_distname}
    ...    filter_param=a3 Measurement Configuration Enabled
    ...    abbr=a3MeasEnabled
    Should Be Equal    ${a3MeasEnabled_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter a3MeasEnabled
    [Arguments]    ${new_value}=none    ${despite_errors}=False
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${a3MeasEnabled_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    selenium_coam.set_parameter_value  dist_name=${a3MeasEnabled_distname}
    ...    filter_param=a3 Measurement Configuration Enabled
    ...    abbr=a3MeasEnabled    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
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

Huawei Mate X20 UE detach
#    Commercial UE detach
    power_ue.UE Detach    ue_type=huawei

Check support 5QI value and related message flow for call reject
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
#    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_0}
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
#    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_0}
#    ${ngap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//ngap.fiveQI
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
#    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
#    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
#    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//ngap.radioNetwork
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
#    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code42}
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
#    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code42}
#    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//ngap.radioNetwork
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check not support 5QI value and related message flow for call reject
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
    should be equal    ${Code26_1_status}    ${True}

    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.radioNetwork
    Should Be Equal    ${ngap_radioNetwork[0]}    34

#    ${Code42} =    Catenate    ngap.procedureCode == 42
#    Log    check UEContextReleaseRequest
#    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code42}
#    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//ngap.radioNetwork
#    ${empty_list}=    Create List
#    should be equal    ${ngap_radioNetwork}    ${empty_list}

Check voice falls back to lte to the end of sign
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
#    ${s1ap_qCI} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//s1ap.qCI
#    Should Be Equal    ${s1ap_qCI[0]}    1

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
#    ${s1ap_nas} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//s1ap.nas
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}


Check RedirectionVoiceFallback is possible
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code14_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log    check InitialContextSetupRequest
    ${Code14_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code14_0}    pcap_parser=test6
    should be equal    ${Code14_0_status}    ${True}

    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code14_0}    pcap_parser=test6
    ${ngap_RedirectionVoiceFallback} =    get_field_value_by_xpath    xpath=.//ngap.RedirectionVoiceFallback    pcap_parser=test6
    Should Be Equal    ${ngap_RedirectionVoiceFallback[0]}    0

check UE attached
    [Arguments]    ${alias}=ABIL Master    ${Bearers_num}=numOfBearers 1
    Connect to Capacity Unit Master    alias=${alias}
    ssh.send_command    command=journalctl -f | grep -i "l2_lo_tb"    connection=${alias}
    ${numOfBearers}=    ssh.Read Output Until    Rcvd|Sent    timeout=10    connection=${alias}
    Should Contain    ${numOfBearers}    ${Bearers_num}
    ssh.disconnect      connection=${alias}

gnb2 connection
    ssh.Connect to    hostname=${asik2_addr}    username=${asik2_username}    password=${asik2_password}    alias=gnb2

gnb2 disconnection
    csn.disconnect      connection=gnb2

Start Capture Wireshark Logs on gNB2
    [Arguments]     ${nglogname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    gnb2 connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb2
    sleep    3s

Stop Capture Wireshark Logs on gNB2
    [Arguments]    ${nglogname}
    gnb2 connection
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb2
    sleep    15
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb2
    sleep    30
    gnb2 disconnection

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

Teardown for disconnect all connections
    Run Keyword And Ignore Error    csn.Disconnect    connection=gnb
    Run Keyword And Ignore Error    csn.Disconnect    connection=cygwin
    Run Keyword And Ignore Error    csn.Disconnect    connection=EPCAPP
    Run Keyword And Ignore Error    csn.Disconnect    connection=enb
    Run Keyword And Ignore Error    enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

Recover TopYong Attenuation
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Recover TopYong Attenuation on TL40       #40
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Recover TopYong Attenuation on TL42       #38221
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Recover TopYong Attenuation on TL343      #911
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[4]'    Recover TopYong Attenuation on TL342      #342

Recover TopYong Attenuation on TL40
    Adjust the TopYong 4ports Attenuation Value for 749     value1=${0}    value2=${0}    value3=${0}    value4=${0}

Recover TopYong Attenuation on TL42
    Adjust the TopYong 4ports Attenuation Value for 749     value1=${0}    value2=${0}    value3=${0}    value4=${0}

Recover TopYong Attenuation on TL343
    Adjust the TopYong 4ports Attenuation Value for 749     value1=${0}    value2=${0}    value3=${0}    value4=${0}

Recover TopYong Attenuation on TL342
    adjust HBTE attenuation    value_1=${10}    value_2=${10}    value_3=${10}    value_4=${10}

Adjust the TopYong 4ports Attenuation Value for 749
      [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}
      Adjust the TopYong Attenuation Value 749    ports=${TOPYONG_ANT1}    value=${value1}
      Adjust the TopYong Attenuation Value 749    ports=${TOPYONG_ANT2}    value=${value2}
      Adjust the TopYong Attenuation Value 749    ports=${TOPYONG_ANT3}    value=${value3}
      Adjust the TopYong Attenuation Value 749    ports=${TOPYONG_ANT4}    value=${value4}

Adjust the TopYong Attenuation Value 749
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

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

adjust HBTE attenuation
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_4}

Save snapshot Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections



#####end to end make EPS fallback voice call
TL342 and TL343 Setup for SA Env cell on-air
    #####TL342 Setup for SA Env cell on-air
    Setup for SA Env cell on-air on gnb342
    #####TL343 Setup for SA Env cell on-air
    Setup for SA Env cell on-air


Setup for SA Env cell on-air on gnb342
    Prepare SA classical COAM BTS cell onair on gnb342
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair on gnb342
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair on gnb342
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair on gnb342
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair on gnb342
    Perform full commission for COAM SA gnb342    scf=${SCF_path}${SCF_file_name_342}    gnb_ip=${tl.gnbs[3].cu.oam_ssh_connection_details.addr}
    Check gnb342 COAM classical normally
    Check the gnb342 cell status onair    cell_no=1

Perform full commission for COAM SA gnb342
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[3].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   connection=GNB342_OAM    bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    connection=GNB342_OAM    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections    connection=GNB342_OAM

Check gnb342 COAM classical normally
#    Check gnb2 HW module status
    ${res} =    Feature 1514 Enabled    host=${tl.gnbs[3].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[3].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[3].cu.oam_ssh_connection_details.password}
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp UP on gnb342    port_num=${f1_sctp_port}
    sleep    30s
    wait until keyword succeeds    10min    20s    Check the gnb342 RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP on gnb342    port_num=${x2_sctp_port}

Check the gnb342 RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=https://${tl.gnbs[3].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[3].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[3].cu.oam_http_connection_details.password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    20s    get gnb342 RU status
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get gnb342 RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
    Get info status check    info_status=${ru1_status}

Check the gnb342 cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[3].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[3].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[3].cu.oam_http_connection_details.password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout




check type of system board on TL342 and TL343
    #####check type of system board on TL343
    checking type of system board
    #####check type of system board on TL342
    checking type of system board       hostname=${tl.gnbs[3].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[3].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[3].cu.oam_ssh_connection_details.password}    connection=gnb342    TL=TL342

checking type of system board
    [Arguments]    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    ${connection}=gnb343     ${TL}=TL343
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${connection}
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=${connection}
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Setting variable br1 for interface name on ${TL}
    Run Keyword If    '${status}' == 'False'    Setting variable fp0 for interface name on ${TL}
    csn.disconnect      connection=${connection}

lock TL342 and TL343 gnb2 cell
    #####lock TL343 gnb2 cell
    Lock_gnb2_Cell    url=https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
    ...    bts_host=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
    #####lock TL342 gnb2 cell
    Lock_gnb2_Cell    url=https://${tl.gnbs[4].cu.oam_http_connection_details.addr}
    ...    bts_host=${tl.gnbs[4].cu.oam_ssh_connection_details.addr}

TL342 and TL343 UE prepare
    #####TL342 UE detach
    TL UE prepare    ue_index=${1}
    #####TL343 UE detach
    TL UE prepare

TL UE prepare
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}

TL UE detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=huawei    ue_index=${ue_index}

Prepare env with UEs
    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}

check value of parameter actVoNR
    [Arguments]    ${value}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${actVoNR_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1
    ${actVoNR_value}=    selenium_coam.get_parameter_value    dist_name=${actVoNR_distname}
    ...    filter_param=Activate voice over NR call support in the NR cell.    abbr=actVoNR
    Should Be Equal    ${actVoNR_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check value of parameter algorithm
    [Arguments]    ${value1}=9    ${value2}=0    ${value3}=0    ${value4}=0    ${value5}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${algorithm_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${nea0_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=${Null_ciphering}    abbr=nea0
    ${return1}=    Run Keyword And Return Status    Should Be Equal    ${nea0_value}    ${value1}
    Run Keyword If    '${return1}' == 'True'    sleep    0.5s
    Run Keyword If    '${return1}' == 'False'    set value of parameter algorithm    filter_param=${Null_ciphering}
    ...    abbr=nea0    new_value=${value1}
    ${nea1_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=${SNOW_3G-based}    abbr=nea1_128
    ${return2}=    Run Keyword And Return Status    Should Be Equal    ${nea1_128_value}    ${value2}
    Run Keyword If    '${return2}' == 'True'    sleep    0.5s
    Run Keyword If    '${return2}' == 'False'    set value of parameter algorithm    filter_param=${SNOW_3G-based}
    ...    abbr=nea1_128    new_value=${value2}
    ${nea2_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=${AES-based}    abbr=nea2_128
    ${return3}=    Run Keyword And Return Status    Should Be Equal    ${nea2_128_value}    ${value3}
    Run Keyword If    '${return3}' == 'True'    sleep    0.5s
    Run Keyword If    '${return3}' == 'False'    set value of parameter algorithm    filter_param=${AES-based}
    ...    abbr=nea2_128    new_value=${value3}
    ${nea3_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=${ZUC-based}    abbr=nea3_128
    ${return4}=    Run Keyword And Return Status    Should Be Equal    ${nea3_128_value}    ${value4}
    Run Keyword If    '${return4}' == 'True'    sleep    0.5s
    Run Keyword If    '${return4}' == 'False'    set value of parameter algorithm    filter_param=${ZUC-based}
    ...    abbr=nea3_128    new_value=${value4}
    ${nullFallback_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=${nullFallback_accepted}    abbr=nullFallback
    ${return5}=    Run Keyword And Return Status    Should Be Equal    ${nullFallback_value}    ${value5}
    Run Keyword If    '${return5}' == 'True'    sleep    0.5s
    Run Keyword If    '${return5}' == 'False'    set value of parameter algorithm    filter_param=${nullFallback_accepted}
    ...    abbr=nullFallback    new_value=${value5}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter algorithm
    [Arguments]    ${filter_param}=${Null_ciphering}    ${abbr}=nea0    ${new_value}=9
    selenium_coam.set_parameter_value  dist_name=${algorithm_distname}
    ...    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s

Check UE exist
    Check UE device exist
    Check UE device exist    ue_index=${1}

check voiceOverNR support
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${UERadioCapabilityInfoIndication} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 44
    Log To Console    check voiceOverNR value on UERadioCapabilityInfoIndication message
    ${UERadioCapabilityInfoIndication_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UERadioCapabilityInfoIndication}
    should be equal    ${UERadioCapabilityInfoIndication_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UERadioCapabilityInfoIndication}
    ${nr_rrc_voiceOverNR}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.voiceOverNR
    Should Be Equal    ${nr_rrc_voiceOverNR[0]}    0

check Algorithm value
    [Arguments]    ${logname}    ${Algorithm_value}=0
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${BearerContextSetupRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 8
    Log To Console    check cipheringAlgorithm value on BearerContextSetupRequest message
    ${BearerContextSetupRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextSetupRequest}
    should be equal    ${BearerContextSetupRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${BearerContextSetupRequest}
    ${e1ap_cipheringAlgorithm}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.cipheringAlgorithm
    Should Be Equal    ${e1ap_cipheringAlgorithm[0]}    ${Algorithm_value}

Make a VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    phone_number=${phone_number}
    answer ViNR call    ue_index=${1}

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    5s

Make a VoNR call separately
    [Arguments]    ${phone_number}=18001006306
    Get VoNR and ViNR pointer variable
    Make a VoNR call    phone_number=${phone_number}
    answer VoNR call    ue_index=${1}

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
    sleep    25s

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

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
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    25s

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}
    sleep    25s

hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep    5s

Get VoNR and ViNR pointer variable
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[3]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro on TL351
    run keyword if    '${brand}'=='HUAWEI' and '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Get VoNR and ViNR pointer variable with mate30 pro on TL42

Get VoNR and ViNR pointer variable with mate30 pro
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    836 2149
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728


Get VoNR and ViNR pointer variable with mate30 pro on TL351
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    828 1952
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

Get VoNR and ViNR pointer variable with mate30 pro on TL42
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    759 2151
    Set Suite Variable    ${switch_to_VoNR}    908 1735
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

check points with VoNR and ViNR call together
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    2
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    2

check points with VoNR and ViNR call release together
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    2
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_ID}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    Should Contain any    ${e1ap_dRB_ID}    5    6    7
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    2

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse}
    ${nr_rrc_drx_Config}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.drx_Config
#    Should Contain    ${nr_rrc_drx_Config}    1

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with ViNR call release
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    1
    ${e1ap_dRB_ID}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
#    Should Not Contain    ${e1ap_dRB_ID}    6
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    1

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with VoNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Not Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Not Contain    ${f1ap_fiveQI}    2
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
#    ${f1ap_PDCPSNLength}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//f1ap.PDCPSNLength
#    Should Contain    ${f1ap_PDCPSNLength}    0
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRXConfigurationIndicator}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
#    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

check points with ViNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    2
    Should Not Contain    ${ngap_fiveQI}    1

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    2
    Should Not Contain    ${f1ap_fiveQI}    1
#    ${f1ap_PDCPSNLength}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//f1ap.PDCPSNLength
#    Should Contain    ${f1ap_PDCPSNLength}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

786 UEs attach
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Prepare UE    ue_type=huawei
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

786 UEs detach
    power_ue.Prepare UE    ue_type=huawei
    power_ue.UE Detach    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}
    power_ue.UE Detach    ue_type=huawei    ue_index=${1}

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

Set automatic rotation on UEs
    Set automatic rotation
    Set automatic rotation    ue_index=${1}

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
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
    #selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Get the gNB Cell Id
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell1_id} =    selenium_coam.get_parameter_value    dist_name=${distname_id}/NRCELL-1
    ...   abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    ${cell2_id} =    selenium_coam.get_parameter_value    dist_name=${distname_id}/NRCELL-2
    ...   abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    set suite variable     ${cell1_id}
    set suite variable     ${cell2_id}
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    #    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Delete all NRADJGNB object
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM_PEER}    distname_ID=${distname_id_2}
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM_LOCAL}    distname_ID=${distname_id_1}

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
