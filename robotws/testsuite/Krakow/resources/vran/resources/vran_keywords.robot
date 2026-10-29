*** Settings ***
Documentation    Keywords for vran tests automation

Library    Collections
Library    taf.gnb.oam.coam.vdu       WITH NAME    coam_vdu
Library    taf.gnb.oam.coam.cu        WITH NAME    coam_vcu
Library    ute_fsmaccess
Library    ute_async
Library    os
Resource   taf/rfrl/cbts/interfaces.robot
Resource   testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot

*** Keywords ***
###   Throughput   ###
Start Streams For DL And UL Data Transmission For Specified Time For UDP
    [Arguments]    ${data_transfer_time}    ${ul_throughput}     ${dl_throughput}
    [Documentation]    Keyword starts UDP traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param ul_throughput:    level of throughput in uplink direction
    ...                :param dl_throughput:    level of throughput in downlink direction
    ...                :protocol:    protocol type tcp/udp
    Log To Console    Start DL and UL data transmission for specified time
    ute_ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE_1
    ...                 direction=ul    duration=${data_transfer_time}s    protocol=udp   throughput=${ul_throughput}
    ...                 packet=1320    buffer_client=4M
    Sleep    2s   reason=Wait a while to start DL traffic
    ute_ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE_1
    ...                  direction=dl    duration=${data_transfer_time}s    protocol=udp   throughput=${dl_throughput}
    ...                  packet=1320    buffer=4M
    Sleep    1s    reason=Wait a while to stabilize throughput

Await DL And UL Data Transmission Finish
    Log To Console    Await DL and UL data transmission finish
    ute_ue.Await Data Transfer Finish    DT_1_UL
    ute_ue.Await Data Transfer Finish    DT_1_DL

Verify DL And UL Data Transmission Loss For UDP
    [Arguments]    ${deviation}=5
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss parameter value.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param deviation:   max allowed data loss value in percentage, e.g: '25' for 25%
    Log To Console    Verify DL and UL data transmission loss
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_1_DL    tput=100000000 bits/sec    deviation=${deviation}%
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_1_UL    tput=10000000 bits/sec    deviation=${deviation}%
    ${avg_UL_tput}=      ute_ue.Get Average Throughput   DT_1_UL
    Log To Console   Average UL TPUT: ${avg_UL_tput} Mbps
    ${avg_DL_tput}=      ute_ue.Get Average Throughput   DT_1_DL
    Log To Console   Average DL TPUT: ${avg_DL_tput} Mbps

Stop DL And UL Data Transmission
    Log To Console    Stop DL and UL data transmission
    ute_ue.Stop Data Transfer    dt_name=DT_1_UL
    ute_ue.Stop Data Transfer    dt_name=DT_1_DL

### Status of components ###
Check If Hardware Components Are Available
    [Documentation]    Runs checks to determine if critical HW components are available.
    Wait Until Keyword Succeeds    3 times    3s    Wait for response from gnb components
    Wait Until Keyword Succeeds    5m    10s    Verify RMODs Availability Status Is OnLine
    Wait Until Keyword Succeeds    5m    10s    F1 link should be available
    Wait Until Keyword Succeeds    5m    10s    Check If Cells Are Configured

Wait For Response From Gnb Components
    ute_async.start_async     ute_fsmaccess     wait_until_host_is_available     ${OAM_DU}[host]     alias=vdu       timeout=20
    ute_async.start_async     ute_fsmaccess     wait_until_host_is_available    ${OAM_CU}[host]        alias=vcu       timeout=20

    Log To Console   Waiting on the response from gnb components
    ute_async.wait_for_async_result    alias=vdu    timeout=20
    ute_async.wait_for_async_result    alias=vcu    timeout=20

Verify RMODs Availability Status Is OnLine
    ${conn_du}    coam_vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${rmods_statuses}=  coam_vdu.get_rmods_status  vdu_connection=${conn_du}
    FOR  ${status}  IN  @{rmods_statuses}
        Dictionary Should Contain Item  ${status}  availability_status  on line  msg=RMOD status is not \'on line\':${\n}${status}
    END
    Log To Console  RMOD: Status is online
    [Teardown]  coam_vdu.disconnect  vdu_connection=${conn_du}

F1 Link Should Be Available
    ${conn_cu}    coam_vcu.connect_to   host=${OAM_CU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${du_state}=  coam_vcu.get_du_state  connection=${conn_cu}
    Should Be Equal  ${du_state}[f1_link_status][available]  ${1}
    Log To Console  CU: F1 link is available
    [Teardown]  coam_vcu.disconnect  connection=${conn_cu}

Check If Cells Are Configured
    ${conn_du}    coam_vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  coam_vdu.get_vdu_cells_status    vdu_connection=${conn_du}
    Should Be Equal   ${cell_info[0]["procedural_status"]}   configured
    Log To Console    Cells are configured
    [Teardown]    coam_vdu.disconnect   vdu_connection=${conn_du}

#### Resets ####
Reboot CU
    Log To Console  Reset vCU
    ${conn_cu}    coam_vcu.connect_to   host=${OAM_CU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    coam_vcu.reset_cu  connection=${conn_cu}
    [Teardown]    coam_vcu.disconnect   connection=${conn_cu}

Reboot vDU
    Log To Console  Reset vDU
    ${conn_du}    coam_vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    coam_vdu.reset_vdu   vdu_connection=${conn_du}
    [Teardown]    coam_vdu.disconnect   vdu_connection=${conn_du}

Reboot RU
    Log To Console  Reset RU
    ${conn_du}    coam_vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${rmods_list}    coam_vdu.get_rmods_status
    ${rmods_ids}     Evaluate   [rmod['id'] for rmod in ${rmods_list}]
    coam_vdu.reset_rmods    rmods_list=${rmods_ids}
    [Teardown]    Run Keyword And Ignore Error    coam_vdu.disconnect   connection=${conn_du}

###   Logs   ###
Collect Snasphot From vDU And CU
    [Documentation]    Collect Snapshot from vCU and vDU in CLOUD deployment via M2M REST API.
    ...                Supports independent user flags ``skip:snapshot`` for skipping collection steps.
    ...                - ``log_dir``: Directory for COAM data, Default: ``$\{TEST_log_dir\}/``
    ...                Example:
    ...                | robot -v skip:snapshot test_suite.robot
    Create Directory                ${log_dir}/Snapshot/vDU
    Create Directory                ${log_dir}/Snapshot/vCU
    Trigger And Save Local Snapshot For vDU    local_snapshot_folder=${log_dir}/Snapshot/vDU     compressed_or_not=True
    Trigger And Save Local Snapshot For CU     local_snapshot_folder=${log_dir}/Snapshot/vCU

Import TL Variables
    [Documentation]    Imports TL configuration file from testline_configuration directory.
    ${uname}    os.Uname
    ${tl_name}    Replace String    ${uname.nodename}    -    _
    ${filepath}    Set Variable    /home/ute/testline_configuration/${tl_name}/__init__.py
    Log to Console    Importing TL config file for ${tl_name}
    File Should Exist    ${filepath}
    Import Variables    ${filepath}
    Variable Should Exist    ${tl}
    Set suite variable  ${NAMESPACE_CU}  ${tl.cloud_hostings[0].namespace}
    Set suite variable  ${NAMESPACE_DU}  ${tl.cloud_hostings[1].namespace}
    Set suite variable  &{MASTER_CU}
    ...  hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...  alias=cu_master
    Set suite variable  &{MASTER_DU}
    ...  hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...  alias=du_master
    Set suite variable  &{OAM_CU}
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  secure=${True}
    ...  alias=cu_admin
    Set suite variable  &{OAM_DU}
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...  secure=${True}
    ...  connection_name=du_admin

    Set suite variable  ${VCU_MASTER_IP}   ${OAM_CU}[host]
    Set suite variable  ${VDU_MASTER_IP}   ${OAM_DU}[host]
