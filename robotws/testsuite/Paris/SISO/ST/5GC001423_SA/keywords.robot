*** Settings ***
Documentation    This file contains the keywords for the 5GC001423_SA test case

Library    BuiltIn
Library    taf.transport.ssh                 WITH NAME    ssh
Library    taf.pdu                           WITH NAME    pdu
Library    taf.gnb.oam.coam.admin          WITH NAME    coam
Library    taf.gnb.oam.coam.cu             WITH NAME    cu
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.pmcounters    WITH NAME    pmcounters
Library    taf.ue    WITH NAME    ue
Library    OperatingSystem
Library    SSHLibrary
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/enb.robot
Resource    coam_cu.robot
Resource    ${CURDIR}/E2E_Throughput_OTA.robot
Resource    ${CURDIR}/../../../RRM/ST/resources/sg_e2e/luashark.robot
Library     taf.rfrl.bts.commissioning

*** Variables ***
${NSP_IP}=               10.0.96.33
${NSP_user}=             nsp
${NSP_pwd}=              i&vsam20
${path}=     /opt/nsp/nfmp/lte/stats/20210609/Nokia-5G-BTS/MRBTS-736/
${host}=         ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${user}=         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${password}=     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${port}=         ${tl.gnbs[0].cu.oam_http_connection_details.port}
${du-host}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${du-user}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${du-password}=        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${group_list}=        Create List    0    1    2
${ENB_BUILD}

*** Keywords ***
Common Suite Setup
    Log To Console        Setting up logs collectors
    Setup Logs Collectors
    #Save Current gNB Configuration
    Upload BIP Mirroring Scripts to gNB

Check Cloud Setup OnAir
    Log To Console    \nChecking onAir state
    gnb_bbu.Wait For Site To Be Onair
    Log To Console    Site is onair.

SSH File Transfer Setup
    [Arguments]     ${ssh-ip}    ${ssh-username}    ${ssh-password}    ${alias}=SSH-Conn
    ssh.connect_to    hostname=${ssh-ip}    username=${ssh-username}     password=${ssh-password}     alias=${alias}

SSH File Download
    [Arguments]     ${ssh-ip}    ${ssh-username}    ${ssh-password}    ${remote_path}    ${Folder}=PM_CU
    SSH File Transfer Setup    ${ssh-ip}    ${ssh-username}    ${ssh-password}    alias=SSH-Get
    Create Directory     ${OUTPUTDIR}/${Folder}/
    ssh.download_file    remote_path=${remote_path}    local_path=${OUTPUTDIR}/${Folder}/*.xml    connection=SSH-Get

Get PM from NSP
    ${date}=      Get Current Date      UTC      exclude_millis=yes
    ${convert}=      Convert Date      ${date}      result_format=%Y%m%d
    Log      ${convert}      console=yes
    #SSH File Download     ${NSP_IP}    ${NSP_user}    ${NSP_pwd}     remote_path=${path}

File Transfer from NSP
    Create Directory     ${OUTPUTDIR}/PM/
    SSHLibrary.Open Connection    ${NSP_IP}
    SSHLibrary.Login      ${NSP_user}     ${NSP_pwd}
    SSHLibrary.Get File     ${path}/*.xml     ${OUTPUTDIR}/PM/

Cloud Site Reset
    cu.Connect To        host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               port=443
    ...               username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...               secure=True
    cu.Reset Cu

Wait For DU reboot
    [Arguments]    ${duration}=1200s
    Sleep    ${duration}

Wait For Web Element Manager Availibity
    [Arguments]    ${ip}
    Log To Console    Waiting for WEM: ${ip}.
    Wait until Keyword Succeeds    20x   30s    coam.connect_to    bts_host=${ip}    admin_api_log_dir=/tmp  name=bts
    coam.enable_ssh_access    connection=bts
    Wait until Keyword Succeeds    20x   10s    taf.rfrl.ue.logs.tput_logs_collecting.Download Logs From Gnb
    ...  remote_path=/tmp/RawAlarmHistory.txt    local_path=/tmp/connection_test
    Log To Console    WEM is available from ${ip}.
    [Teardown]    coam.teardown    connection=bts

# THROUGHPUT SECTION

Data Transfer Start on Real UE And Wait
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}=udp    ${deviation}=25%    ${alias}=UE

    Log    ${deviation}
    Perform Attach and Verify UE Properly Attached     alias=${alias}
    Start Data Transfer on Real UE   dt_name=DT_${direction}  ue_alias=${alias}  direction=${direction}  protocol=${protocol}
    ...  duration=${duration}  tput=${tput}  parallel_streams=1  size_packet=1400B
    ...  buffer_client=${None}  buffer_server=${None}  interval=1  qci=${None}    linux_congestion=${None}
    Wait for truput stabilization

Check Data Transfer on Real UE
    [Arguments]     ${direction}    ${tput}    ${deviation}=25%
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Collect logs during data transfer   direction=${direction}
    ue.Check Data Transfer is Alive     dt_name=DT_${direction}
    ue.Await Data Transfer Finish       dt_name=DT_${direction}
    ue.Verify Average Throughput With Deviation   dt_name=DT_${direction}   tput=${tput}   deviation=${deviation}


Bi-Directional_Throughput_UDP_1-DRB_OTA_eLoner_4CC_1CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=${duration}    tput_dl=2242 Mbits/sec    parallel_streams_dl=4
    ...    tput_ul=120 Mbits/sec    parallel_streams_ul=2    protocol=udp    deviation=20%    size_packet=${size_packet}
    ...    buffer_client_dl=${buffer_client_dl}    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}    interval=${interval}   reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_eLoner_4CC_1CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=${duration}    tput_dl=2242 Mbits/sec    parallel_streams_dl=2
    ...    tput_ul=120 Mbits/sec    parallel_streams_ul=2   protocol=tcp    deviation=20%    size_packet=${size_packet}
    ...    buffer_client_dl=${buffer_client_dl}    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}    interval=${interval}   reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_eLoner_4CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=${duration}    tput=2242 Mbits/sec    protocol=tcp    deviation=20%
    ...    parallel_streams=2    size_packet=${size_packet}    buffer_client=${buffer_client_dl}
    ...    buffer_server=${buffer_server_dl}    interval=${interval}   reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_eLoner_2CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=${duration}    tput=180 Mbits/sec    protocol=tcp    deviation=20%
    ...    buffer_server=${buffer_server_ul}    interval=${interval}    parallel_streams=2
    ...    size_packet=${size_packet}    buffer_client=${buffer_client_ul}   reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_eLoner_4CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=${duration}    tput=2242 Mbits/sec    protocol=udp    deviation=20%
    ...    parallel_streams=4    size_packet=${size_packet}    buffer_client=${buffer_client_dl}
    ...    buffer_server=${buffer_server_dl}    interval=${interval}   reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_eLoner_1CC_contiguous
    [Arguments]    ${duration}=300s
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=${duration}    tput=120 Mbits/sec    protocol=udp    deviation=20%
    ...    buffer_server=${buffer_server_ul}    interval=${interval}    parallel_streams=2
    ...    size_packet=${size_packet}    buffer_client=${buffer_client_ul}   reboot_ue=True
    Throughput_Postconditions

Attach UE and Detach
    [Arguments]    ${alias}=UE_1
    Perform Attach and Verify UE Properly Attached  alias=${alias}
    ue.Detach Ue    ${alias}
    #ue.Release Ue    ${alias}

# COMMISSIONING SECTION
Perform_4CCnon_contiguous_commissioning
    #Perform Full Commissioning on Cloud gNB    prefix_tag=4CC
    Perform Full Commissioning on Classical gNB    prefix_tag=4CC
    Wait For Site To Be Onair

Perform_4CC_2CC_non_contiguous_commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=ENDC_2CCUL
    Wait For Site To Be Onair

Perform_4CC_1CC_contiguous_commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=Contiguous
    Wait For Site To Be Onair

Perform_commissioning_activate_PCMD
    Perform Full Commissioning on Classical gNB    prefix_tag=PCMD_ACT
    Wait For Site To Be Onair

Perform_commissioning_deactivate_PCMD
    Perform Full Commissioning on Classical gNB    prefix_tag=PCMD_DEACT
    Wait For Site To Be Onair

Perform_commissioning_NRCELLTYPE_parameters
    Perform Full Commissioning on Classical gNB    prefix_tag=NRCELLTYPE
    Wait For Site To Be Onair

Perform Cloud CU Commissioning
    [Arguments]     ${prefix_tag}=8CC
    Perform Full Commissioning on CU     prefix_tag=${prefix_tag}
    Wait For Site To Be Onair

Perform Cloud Full Commissioning On CU And All DUs
    [Arguments]     ${prefix_tag}=8CC
    Perform Cloud CU Commissioning    prefix_tag=${prefix_tag}
    Perform All DUs commissioning     prefix_tag=${prefix_tag}
    Wait until keyword succeeds    30min    30 sec    Verify gNB is onAir

Perform All DUs commissioning
    [Arguments]     ${prefix_tag}=4CC
    Perform Full Commissioning on All Dus    prefix_tag=${prefix_tag}
    Wait For Site To Be Onair

Reboot All DUs in Cloud BTS
    [Arguments]     ${DU-ID}    ${counter}
    FOR    ${iteration}    IN RANGE    0    ${counter}
        Log To Console     DU ID : ${DU-ID}, Counter: ${iteration}
        gnb_bbu.Reset gNB                  du_id=${DU-ID}
        Sleep   360s
    #    gnb_bbu.Reset gNB via GUI           du_id=${DU-ID}
    #    Sleep   360s
        Check Cloud Setup OnAir
        gnb_bbu.Verify gNB is onAir         du_id=${DU-ID}
    END

Reboot All RUs in Cloud BTS DU
    [Arguments]    ${du_id}=${0}     ${Counter}=5
    FOR    ${RU-RESET}    IN RANGE    0    ${Counter}
        Log To Console      RESET: ${RU-RESET}
        Reset All gNB Radio Units from GUI    du_id=${du_id}
        Sleep    300s
        Verify All Radio Module Status      du_id=${du_id}
    END

Lock Cell Group from CU
    cu.Connect To    host=${host}    port=${port}     username=${user}     password=${password}    alias=CU_CG
    cu.Lock Cell Group    alias=CU_CG    cell_group_id=${group_list}

Unlock Cell Group from CU
    cu.Unlock Cell Group   alias=CU_CG     cell_group_id=${group_list}

Lock Unlock Cell Group from CU And DU
    Verify CU state is operational
    Lock Cells on CU
    Wait For Cells To Be Disabled
    Verify CU Cells Are Disabled
    Unlock Cells on CU
    #Wait For Cells To Be Enabled
    #Verify CU Cells Are Enabled
    Verify CU state is operational
    Lock All Cell Groups And Then Unlock      verify_x2_link_drop=false
    Verify All Cells Are Unlocked
    Verify CU state is operational

# LOGS COLLECTION

Try to Collect logs during test
    Run Keyword And Ignore Error     Collect logs during test

# Throughput_Preconditions & Throughput_Postconditions

Throughput_Preconditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

Throughput_Postconditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
