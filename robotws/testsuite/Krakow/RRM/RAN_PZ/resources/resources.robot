*** Settings ***
Library    DateTime
Library    Collections
Library    OperatingSystem
Library    String
Library    SSHLibrary
Library    taf.gnb.oam.coam.admin     WITH NAME    coam
Library    taf.ul.oam.selenium_coam   WITH NAME    selenium_coam
Library    taf.collectors.core        WITH NAME    core
Library    taf.collectors.tcpdump     WITH NAME    tcpdump
#Library    taf.ue                     WITH NAME    ue
Library    ute_ue
Library    DeltaStore.py              WITH NAME   delta_store
Library    taf.analyzer.pdml
Library    ute_fsmaccess
Library    ta5g_iphy
Library    ta5g_testline_management
Library    configuration_management__wro.py
Library    AdminHelper.py
Library    pm_counters.py
Library    keyword_resource.py
Library    pdml_verification.py
Library    SwConfigModifier.py
Resource   message_verification.robot
Resource   mimo_keywords.robot


*** Variables ***
${BTS_HOST_IP}              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
${WEBUI_USER}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${snapshot_path}            ${CURDIR}/Snapshot
${bts_port}                 443


*** Keywords ***
Suite cOAM setup with UE
    [Arguments]   ${bts_port}=3600    ${capabilities}=REAL_UE
    Create cOAM session with alias    port=${bts_port}
    ute_ue.Require Ue  AT_BASED_UE_1  capabilities=REAL_UE
    #Require cell        ENB_1_CELL_1    ${tl.enbs[0].global_bts_id}   1
    #Set ue location     UE    ENB_1_CELL_1

Suite cOAM
    [Arguments]   ${bts_port}=3600    ${capabilities}=REAL_UE
    Create cOAM session with alias    port=${bts_port}

Suite cOAM Teradown
    Teardown cOAM session

Test Setup with setup collector
    Setup tcpdump collector

Test Teardown
    Run Keyword If Test Failed    Collect snapshot

Collect snapshot
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/snapshot_${date}.zip
    ...        coverage=Full
    ...        force=True
    ...        timeout=720
    [Return]    ${snapshot_path}/snapshot_${date}.zip

Attach and detach
    Attach ue    UE
    Wait for UE to be attached
    Detach ue    UE

Attach detach and Verification
    Start tcpdump collector
    Attach Ue  AT_BASED_UE_1
    Detach Ue  AT_BASED_UE_1
    Stop tcpdump collector
    ${status}    Run Keyword and Return Status  Verify attach procedure from packet trace on X2 link
    Append To List    ${attach_results}    ${status}

Attach detach with DL and UL
    [Arguments]    ${tput_dl}     ${tput_ul}    ${duration}
    Start tcpdump collector
    Attach Ue    AT_BASED_UE_1
    Start and Verify Downlink and Uplink UDP
    ...     tput_dl=${tput_dl}
    ...     tput_ul=${tput_ul}
    ...     duration=${duration}
    ...     deviation=20%
    Stop tcpdump collector
    [Teardown]  Detach UE   AT_BASED_UE_1

Attach detach with DL and UL for success rate
    [Arguments]    ${tput_dl}     ${tput_ul}    ${duration}
    ${status}    Run Keyword and Return Status  Attach detach with DL-UL and Verification    ${tput_dl}     ${tput_ul}    ${duration}
    Append To List    ${attach_results}    ${status}

Attach detach with DL-UL and Verification
    [Arguments]    ${tput_dl}     ${tput_ul}    ${duration}
    Attach detach with DL and UL  ${tput_dl}     ${tput_ul}    ${duration}
    Verify attach procedure from packet trace on X2 link

Attach detach with DL
    [Arguments]    ${tput}    ${duration}
    Start tcpdump collector
    Attach Ue  AT_BASED_UE_1
    Start and Verify Downlink UDP    throughput=${tput}     duration=${duration}    deviation=20%
    Detach Ue  AT_BASED_UE_1
    Stop tcpdump collector

Attach detach with UL
    [Arguments]    ${tput}    ${duration}
    Start tcpdump collector
    Attach UE   AT_BASED_UE_1
    Start and Verify Uplink UDP    throughput=${tput}     duration=${duration}    deviation=20%
    Detach UE   AT_BASED_UE_1
    Stop tcpdump collector

Reserve UE for tests
    Require Ue    UE    capabilities=PRISMA_UE

Wait for UE to be attached
    Sleep  60s

Start tcpdump collector
    core.Start collectors    ${tcpdump_collector_name}

Stop tcpdump collector
    core.Stop collectors      ${tcpdump_collector_name}
    core.Collect collectors   ${tcpdump_collector_name}    target_dir=${OUTPUTDIR}
    Convert pcap to xml

Setup tcpdump collector
#    ${vlan_id_x2cplane}   Get vlan id for x2cplane
    Set suite variable    ${tcpdump_collector_name}    gnb_oam_tcpdump
    ${executor_oam_vm}    Create Dictionary
    ...     host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    tcpdump.Create tcpdump collector
    ...     name=${tcpdump_collector_name}
    ...     options=-i fp0  #${vlan_id_x2cplane}
    ...     executor=${executor_oam_vm}
    core.Setup collectors    ${tcpdump_collector_name}
    core.Set Suite Alias     ${tcpdump_collector_name}

Start and Verify Downlink UDP
    [Arguments]    ${throughput}    ${duration}    ${deviation}=20%
    Start Data Transfer  dt_name=DT_DL_1  ue_alias=AT_BASED_UE_1  direction=dl  duration=${duration}    throughput=${throughput}  packet_size=1400
    # in case of android usage use line above
#    Start Data Transfer  dt_name=DT_DL_1  ue_alias=UE  direction=dl  duration=${duration}    throughput=${throughput}  len=1400
    Sleep  10
#    Check Data Transfer is Alive   DT_DL_1
#    Stop Data Transfer    DT_DL_1
    Await Data Transfer Finish  DT_DL_1
    Verify Average Throughput With Deviation   DT_DL_1  ${throughput}   ${deviation}

Start and Verify Uplink UDP
    [Arguments]    ${throughput}    ${duration}    ${deviation}=20%
    Start Data Transfer  dt_name=DT_UL_1  ue_alias=AT_BASED_UE_1  direction=ul  duration=${duration}    throughput=${throughput}  packet_size=1400
    # in case of android usage use line above
#    Start Data Transfer  dt_name=DT_UL_1  ue_alias=UE  direction=ul  duration=${duration}    throughput=${throughput}  len=1400
    Sleep  10
#    Check Data Transfer is Alive   DT_UL_1
#    Stop Data Transfer     DT_UL_1
    Await Data Transfer Finish  DT_UL_1
    Verify Average Throughput With Deviation   DT_UL_1   ${throughput}   ${deviation}

Start and Verify Downlink and Uplink UDP
    [Arguments]    ${tput_dl}    ${tput_ul}    ${duration}=60s    ${deviation}=20%
    ### For this moment keyword Start Sata Transfer supports only one parameter throughput (sum throghput DL
    ### and UL) in close futre there will be two separte parameters
    Start and Verify Downlink UDP     ${tput_dl}    ${duration}    ${deviation}
    Start and Verify Uplink UDP   ${tput_ul}    ${duration}    ${deviation}

Check throughput
    [Arguments]    ${dt_name}    ${tput}    ${deviation}
    ${output}    Run Keyword And Ignore Error    Verify Average Throughput With Deviation
    ...         dt_name=${dt_name}
    ...         tput=${tput}
    ...         deviation=${deviation}

Create list to store attach KPI rate
    ${attach_results}   Create list
    Set Test Variable    ${attach_results}

Start Downlink and Uplink UDP
    [Arguments]    ${throughput_dl}     ${throughput_ul}    ${duration}='forever'
    Start Data Transfer  dt_name=DT_DL  ue_alias=UE  direction=dl  duration=${duration}
    ...                  throughput=${throughput_dl}  protocol=udp
    Start Data Transfer  dt_name=DT_UL  ue_alias=UE  direction=ul  duration=${duration}
    ...                  throughput=${throughput_ul}  protocol=udp
    Sleep   10s
    Check Data Transfer Is Alive   DT_DL
    Check Data Transfer Is Alive   DT_UL

Stop and verify Downlink and Uplink UDP
    [Arguments]     ${throughput_dl}     ${throughput_ul}
    Stop Data Transfer  dt_name=DT_DL
    Stop Data Transfer  dt_name=DT_UL
    Verify Average Throughput With Deviation   DT_DL   ${throughput_dl}   20%
    Verify Average Throughput With Deviation   DT_UL   ${throughput_ul}   20%

Enable SRB3 Support
    Configure srb3support parameter    value=true

Disable SRB3 Support
    Initialise Delta Store   name=srb3_disable
    Configure srb3support parameter    value=false
    Recommission with delta

Set MCS Parameter For QPSK
    Fail    Not implemented

Set MCS Parameter For 16 QAM
    Fail    Not implemented

Disable 256QAM Modulation
    [Arguments]  ${physical_cell_id}
    Configure general connectivity silver   value=false
    Configure 256qam Parameter   physical_cell_id=${physical_cell_id}   value=false

Enable 256QAM Modulation
    [Arguments]  ${physical_cell_id}
    Configure general connectivity silver   value=true
    Configure 256qam Parameter   physical_cell_id=${physical_cell_id}   value=true

Enable Rank1 MIMO For Uplink And Downlink
    Fail    Not Implemented

Disable PTRS Parameter
    Update PTRS Parameter    value=Off

Enable PTRS Parameter
    Update PTRS Parameter    value=On

Update PTRS Parameter
    [Arguments]    ${value}
    Fail    Not Implemented

Sleep After Call Setup
    Sleep    60s

Validate RRC Reconf
    Fail    Not Implemented

Validate DMRS Additional Position
    Fail    Not Implemented

Configure UE for mUE Mode
    Fail    Not Implemented

Validate GRC
    Fail    Not Implemented

Configure UE for 2UE Mode
    Fail    Not Implemented

Simulate UE Travel Speed
    [Arguments]    ${speed}
    Fail    Not Implemented

Update Channel Width
    [Arguments]    ${width}
    Fail    Not Implemented

Configure UE for StaticUE Mode
    Fail    Not Implemented

Validate VRC
    Fail    Not Implemented

Enable Link Adapdation
    Fail    Not Implemented

Move UE to the second cell
    Fail    Not impelmented yet

Move UE to the third cell
    Fail    Not impelmented yet

Verify success rate
    Fail  Not implemented

Verify Counters Are Updated
    [Arguments]   ${Pre_Test_Count}    ${Post_Test_Count}
    Run Keyword If   ${Post_Test_Count}<=${Pre_Test_Count}    Fail
    ...    The counter is not updated Previous Count : ${Pre_Test_Count} and Post Count : ${Post_Test_Count}

Test setup coam and selenium session
    [Arguments]    ${bts_port}
    Create cOAM session with alias    port=443
    Login to GUI

Test teardown coam and selenium session
    Run Keyword If Test Failed    Collect snapshot coam
    Logout From GUI
    coam.teardown

Test teardown coam
    Run Keyword If Test Failed    Collect snapshot coam
    coam.teardown

Create cOAM session with alias
    [Arguments]         ${gnb_id}=0      ${port}=3600      ${alias}=default
    [Documentation]  Connect to Node B.
    ...     gnb_id:  BTS gnb id in Testline configuration i.e ${tl.gnbs[]}
    ...     port:  BTS gNB port ID. default 3600
    ...     alias:   AdminConnection object or if used, string name alias
    comment  Release cOAM session before creation to avoid multiple session open
    Teardown cOAM session
    coam.Connect to   bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}   bts_port=${port}  name=${alias}

Teardown cOAM session
    [Arguments]         ${alias}=default
    [Documentation]  Disconnects and destroy node.js daemon
    ...     alias:   AdminConnection object or if used, string name alias
    run keyword and ignore error        coam.teardown          connection=${alias}

Wait for OnAir
    [Arguments]   ${timeout}=60s
    Wait Until Keyword Succeeds   ${timeout}   60sec   Verify all Cells are OnAir with Admin CLI

Collect snapshot coam
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}   ${snapshot_coverage}=Full
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/snapshot_${date}.zip
    ...        coverage=${snapshot_coverage}
    ...        force=True
    ...        timeout=720
    [Return]    ${snapshot_path}/snapshot_${date}.zip

Lock given cell and verify
    [Arguments]    ${cell}
    selenium_coam.lock_cell      ${cell}
    Wait Until Keyword Succeeds    6x    10s    Is cell is locked with selenium    ${cell}

Unlock given cell and verify
    [Arguments]     ${cell}
    selenium_coam.unlock_cell    ${cell}
    Wait Until Keyword Succeeds    6x    10s    Is cell is unlocked with selenium   ${cell}

Check if the given RU is not detected
    [Arguments]    ${rmod}
    ${ru_info}   selenium_coam.get_ru_info    ru_index=${rmod}
    Should Be Equal    &{ru_info}[Availability status]    Offline
    Should Be Equal    &{ru_info}[Operational state]    Disabled

Login to GUI
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     run keyword and ignore error    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    run keyword and ignore error      selenium_coam.disable_message_box


Get RU Status From GUI
    ${ru_status}=    selenium_coam.get_ru_info
    [Return]    ${ru_status}

Check RU STATUS
    [Arguments]    ${RU_Status}
    Run Keyword And Continue On Failure    should match regexp    ${RU_Status['Operational state']}    Enabled
    ...    msg=mismatch in RU Operational State
    Run Keyword And Continue On Failure    should match regexp    ${RU_Status['Availability status']}    Online
    ...    msg=mismatch in RU Availability Status
    Run Keyword And Continue On Failure    should match regexp    ${RU_Status['Administrative state']}    Unlocked
    ...    msg=mismatch in RU Administrative State
    Run Keyword And Continue On Failure    should match regexp    ${RU_Status['Procedural status']}    configured
    ...    msg=mismatch in RU Procedural Status

Check RU Status is Ok
    ${radio_unit_inforamtion}    Get RU Status From GUI
    Check RU STATUS    ${radio_unit_inforamtion['Status']}

Logout From GUI
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Set Log Variables
    ${SNAPSHOT_NEEDED}    set variable    True
    set global variable    ${SNAPSHOT_NEEDED}

Custom Teardown
    coam.Connect to    bts_host=${BTS_HOST_IP}
    ...    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    run keyword and continue on failure    Collect Snapshot From Admin    snapshot_dir_path=${snapshot_path}

Collect Snapshot From Admin
    [Arguments]    ${snapshot_dir_path}=none
    Return From Keyword If      "${SNAPSHOT_NEEDED}"=="False"
    Log to console    collecting snapshot
    coam.Get_snapshot
    ...    target_file_name=${snapshot_dir_path}/${TEST_NAME}_Snapshot.zip
    ...    coverage=Full
    ...    timeout=600
    [Teardown]    coam.teardown

Reset RU with Retry
    wait until keyword succeeds    1min    30S    selenium_coam.reset_ru

Wait Till RU is Available
    wait until keyword succeeds    10min    30S    Check RU Status is Ok

Triger reset if 19B
    ${sw_version}       Get sw version
    Run keyword if      '${sw_version}'=='5G19B'
    ...                 Reset site and wait until onair

Reset site and wait until onair
    [Arguments]         ${alias}=ASIK
    coam.Connect_to     name=${alias}
    coam.Reset_site     connection=${alias}
    Verify if all cells are onair
    [Teardown]          coam.Teardown      connection=${alias}

Verify if all cells are onair
    [Arguments]    ${duration}=900 sec    ${interval}=60 sec
    Wait until keyword succeeds    ${duration}    ${interval}    verify_all_cells_are_onair_with_admin

Get sw version
    [Arguments]         ${alias}=ASIK
    coam.Connect to     name=${alias}
    ${full_ver}         coam.Get sw version   connection=${alias}
    ${ver}              Fetch from left    ${full_ver}    _
    [Return]            ${ver}
    [Teardown]          coam.Teardown      connection=${alias}

Cell setup with given parameters
    [Arguments]     ${bandwidth}    ${enable_256QAM}
    ${cell_list}    Create list    50    51    52
    ${coreset_index}    Create dictionary    5MHz=0    10MHz=6
    ...                                      15MHz=6   20MHz=6
    Log to console   __Cell setup ${bandwidth}
    ${mrbts_id}      get_mrbts_id
    ${nrbts_id}      get_nrbts_id
    Initialise Delta Store   name=config_${bandwidth}
    :FOR    ${cell}    IN    @{cell_list}
    \    ${cell_dist}    get_dist_name_nrcell    ${cell}
    \    Add param to delta  ${cell_dist}        type0CoresetConfigurationIndex         value=${coreset_index['${bandwidth}']}
    \    Add param to delta  ${cell_dist}/NRCELL_FDD-1   chBwDl                         value=${bandwidth}
    \    Add param to delta  ${cell_dist}/NRCELL_FDD-1   chBwUl                         value=${bandwidth}
    \    Add param to delta  ${mrbts_id}/${nrbts_id}     actGeneralConnectivitySilver   value=${enable_256QAM}
    \    Add param to delta     ${cell_dist}             actDl256Qam                    value=${enable_256QAM}
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    Log to console      __Cell setup ended

Wait an hour
    Log to console      --Waiting 60 minutes--
    FOR    ${index}    IN RANGE    1    6
        Sleep       10 minutes
        Log to console      --${index}0 minutes passed--
    END

Reset Testline And Wait For Rmods
    Reset Testline
    Check Radios Availability

Enable CP_UE logging
    [Arguments]    ${reboot}=${False}
    Add Flags To Swconfig
    ...    flags=${SW_CONFIG_ADDITIONAL}
    ...    filepath=GNB
    ...    host=${GNB_IP}
    ...    nokia_login=${NOKIA_LOGIN}
    ...    nokia_pass=${NOKIA_PASS}
    ...    reboot=${False}
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    echo "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    run keyword if    ${reboot}    SSHLibrary.execute command     sync; reboot
    SSHLibrary.close connection
