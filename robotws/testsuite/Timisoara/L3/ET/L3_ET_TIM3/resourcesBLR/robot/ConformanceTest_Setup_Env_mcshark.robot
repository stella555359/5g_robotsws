*** Settings ***
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           logging
Library           ArchiveLibrary
Library           taf.gnb.oam.commissioning         WITH NAME    commissioning
Library           taf.gnb.oam.megazone_client       WITH NAME    megazone_client
Library           taf.transport.ssh                 WITH NAME    csn
Library           taf.cloud.openstack               WITH NAME    openstack
Library           taf.lteemu                        WITH NAME    lteemu
Library           taf.config.scf                    WITH NAME    scf
Library           taf.sbts.oam.coam.admin            WITH NAME    coam
Library           taf.pdu                           WITH NAME   pdu
Library           taf.gnb.oam.megazone_client            WITH NAME   megazone
#Library           luashark_tools.analyzer(isLuaSharkRequired=False)       WITH NAME       analyzer
Resource          ../NPS/SWENG/robot/Setup.robot
Resource          ../NPS/SWENG/robot/PacketSearch.robot
Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          taf/rfrl/common_resources/robot/libraries_instances.robot
#Library           ../python/conformace_test_verifiers.py
Resource          Gnb.robot
Resource          Connect.robot


*** Variables ***
${SSH_OAM_AUTHENTICATION_TIMEOUT}       10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}    5 s
${SSH_AUTHENTICATION_TIMEOUT}           5 min
@{unwanted_faults}                      1    2    10    16    6202
${TIMEOUT_VM_STARTUP}                   5 min
${nrCell_range}                         ['2','3','4']
${NRCELL_elements_dist_name}            MRBTS-1900/NRBTS-1/NRCELL-
${5GREL}                                5G19
${NCIRREL}                              NCIR17A
@{fPdcchMonOccsnPo_list}                1610
${isAio}                                False
${STACK_TEMP}                           ${OUTPUT DIR}${/}stack_templates
${ue_aten_ip}=              ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${timeout_for_switch_on}    15   s
&{results}
${ruMode_type}
${physcellId}
${beamPatternId}
${polarization}
${test_model_value}
${cprt_node_id}
${format_2}
${frc_index_value}
${dlBW}
${SCS}
${i11Codebook4Ant}
${i2Codebook4Ant}
${result}
${numOfPacket}    1
${P_console}        ${False}
@{LIST_NODE_NAME_5GC002493}                   CPCL    CPNB    UPUE    CPIF    CPRT    CPUE    CPNRT   # L2RT    # L2PS

*** Keywords ***
# ****** Setting Up Environment Keywords ******* #
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Fetch board type
    Connect to DU
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_unit_id 0
    ${SYS_BOARD_TYPE}               SSH Cmd                                 ${cmd} | grep value | cut -d= -f2
    ...                             alias=DU_conn
    ${SYS_BOARD_TYPE}               Remove String                           ${SYS_BOARD_TYPE}    '
    ${SYS_BOARD_TYPE}               getStringFromCmdReturn                  ${SYS_BOARD_TYPE}
    set suite variable    ${Airscale}    ${SYS_BOARD_TYPE}

Fetch domain id
    Connect to DU
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_domain_id 0
    ${SYS_DOMAIN_ID}                SSH Cmd                                 ${cmd} | grep dmid | cut -d= -f2
    ...                             alias=DU_conn
    ${SYS_DOMAIN_ID}               Remove String                           ${SYS_DOMAIN_ID}    \n
    ${SYS_DOMAIN_ID}               getStringFromCmdReturn                  ${SYS_DOMAIN_ID}
    set suite variable    ${DomainId}    ${SYS_DOMAIN_ID}

Activate Test dedicated Mode
    Dated log       Enter in Dedicated Mode
    Fetch board type
    run keyword if    '${AirScale}' == 'ASIB'    Enable Test Dedicated Mode for ASIB
    ...              ELSE IF      '${AirScale}' == 'ASIK'    Enable Test Dedicated Mode for ASIK
    ...              ELSE        Enable Test Dedicated Mode for ASOE
    Dated Log     Reboot Ap And Check Airscale is Ready
    Reboot Ap And Check Airscale is Ready
    Dated Log     Check iRfHead is in service
    Dated Log     Check RU detection
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    5min    20sec    Verify Single BTS is Configured    connection=${oam_alias}
    Wait Until Keyword Succeeds    3min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Dated Log     Test Dedicated State is Enable
#    Check Test Dedicated State    enabled
    Fetch domain id

Enable Test Dedicated Mode for ${AirScale}
    Dated log       \n Enable Test Dedicated Mode
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    # Enable Bip Messages Mirroring
    Dated Log    \n connexion OK
    coam.Reset_To_Test_Dedicated    connection=coam_admin
    Dated Log    \n test dedicated
    run keyword if    '${AirScale}' == 'ASIB'    Check gNB Airscale is Ready - ASIB
    ...              ELSE IF      '${AirScale}' == 'ASIK'    Check gNB Airscale is Ready - ASIK
    ...              ELSE          Check gNB Airscale is Ready - ASOE
    [Teardown]  coam.teardown    connection=coam_admin


Test suite setup
    Create directories for log

    # UTE adaptation (same as for "Setup.Suite Setup")
    Setup Ute Env if required

    ${timestamp}      Get Current Date    result_format=%Y%m%d_%H%M%S%f
    # Replace " " with "_" to have a correct file name (because stupid robot replace _ with spaces)
    ${fullSuiteName}=       replace string  ${SUITE_NAME}      ${SPACE}        _
    Set Suite Variable      ${LOG_PATH}    ${OUTPUT DIR}/Logs/${timestamp}.${fullSuiteName}
    Create Directory        ${LOG_PATH}
    # create temp path
    ${TEMP_PATH}=  OperatingSystem.run     mktemp -d
    Set Suite Variable      ${TEMP_PATH}
    Set Suite Variable      ${snapshot_path}    ${LOG_PATH}/Snapshot.zip
    Get TL Info for TC
    # Upload SWconfig File
    ${boot_ids_after_startup}    Create Dictionary
    Set Suite Variable           ${boot_ids_after_startup}
    Connect to DU
    ${boot_id_startup}=    Get Boot ID    connection=DU_conn    name=fct    boot_ids=${boot_ids_after_startup}
    Set Suite Variable    ${boot_id_startup}
    ${L1byPass_flag}=    Get Variable Value    ${L1byPass_flag}
    Set Suite Variable           ${L1byPass_flag}
    ${EIF2_flag}=    Get Variable Value    ${EIF2_flag}
    Set Suite Variable           ${EIF2_flag}
    Run Keyword If    '${EIF2_flag}'=='EIF2'    Upload EIF2 Workaround Script to DU
    Log Configuration Flags

Set test log path
    ${fullTestName}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set test variable    ${LOG_PATH1}    ${LOG_PATH}
    set test variable    ${LOG_PATH}    ${LOG_PATH}/${fullTestName}
    Create Directory        ${LOG_PATH}

Suite Setup from scratch
    Test suite setup
    common_frt.Kill Previous services on LTEEMU
    Clean Old Logs


Upload EIF2 Workaround Script to DU
    Connect to DU
    csn.upload_file    local_path=${PathToFrt}/config/scripts/l1bypass_eif2/gnb_eif2.sh
    ...    remote_path=/user/toor4nsn/gnb_eif2.sh    connection=DU_conn
    csn.execute    chmod 777 /user/toor4nsn/gnb_eif2.sh    connection=DU_conn


Create directories for log
    Create Directory    ${LOG_PATH}
    Create Directory    ${STACK_TEMP}


Connect to DU
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=DU_conn



Check gNB Airscale is Ready - ${AirScale}
    Dated log   \n  Check gNB Airscale is Ready - ASIB
    ${GNB_NODE_1}=    get variable value  ${AIRSCALE_GNB.listNodeId[0]}
    ${GNB_NODE_2}=    get variable value  ${AIRSCALE_GNB.listNodeId[1]}
    run keyword if    '${AirScale}'=='ASIK'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
    run keyword if    '${AirScale}'=='ASIB'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
    run keyword if    '${AirScale}'=='ASOE'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_1}


gNB Check Airscale One Time for ${node_id_1} and ${node_id_2}
    Dated log        \n  gNB Check Airscale One Time for ${node_id_1} and ${node_id_2}
    csn.disconnect      DU_conn
    Connect to gNB Asik Master
    Dated Log       checking ${node_id_1} board status      first=True
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_1}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11
    Dated log       checking ${node_id_2} board status
    Wait Until Keyword Succeeds    5min  30s        Check HW    ${node_id_2}    alias=DU_conn     CCS_Daemon_node_id=${node_id_1}11



Connect to gNB Asik Master
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=DU_conn


Connect to gNB Asik Slave
     csn.Connect to                 hostname=192.168.253.17
    ...                             username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                             password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                             proxy=DU_conn
    ...                            alias=ASIK_SLAVE_GNB


Connect to DU Classicalbts
    [arguments]    ${my_address}    ${my_login}    ${my_pwd}
    csn.connect_to      hostname=${my_address}
    ...                 username=${my_login}
    ...                 password=${my_pwd}    alias=DU_conn


Check HW
    [Arguments]     ${addr}
    ...             ${alias}
    ...             ${CCS_Daemon_node_id}
    ${status}       verify_hw_status
    ...                 ${addr}
    ...                 alias=${alias}
    ...                 ccs_daemon_node_id=${CCS_Daemon_node_id}
    should be True  ${status}
    Dated Log       Board ${addr} on ${alias} : OK


Reboot Ap And Check Airscale is Ready
#    Ap Hard Reboot
    Check Ap Airscale is Ready


Ap Hard Reboot
    ue Power Reset    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}


ue Power Reset
    [Arguments]    ${pdu_port_num}
    [Documentation]
    ...    Switch off on the indicated ue unit.
    ...    Returns True if the operation succeed, False otherwise.
    Connect to AP PDU
    ${result} =    run keyword and return    Switch off AP on port    ${pdu_port_num}
    BuiltIn.Log    Port switch off result: ${result}   console=yes


Connect to AP PDU
    pdu.setup_pdu      model=${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    ...                host=${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}    alias=ap_pdu_switch


Check Ap Airscale is Ready
    Ap Check Airscale One Time


#Ap Check Airscale One Time
#    ${aliasAP}          SSH Wait for Connect            host=${HOST_AP_ASIK_M}
#    Dated log       checking 0x50 board status    first=True
#    Wait Until Keyword Succeeds    5min  30s
#    ...             Check HW    ${AIRPHONE_airscaleNodeID[0]}
#    ...                 alias=${aliasAP}
#    ...                 CCS_Daemon_node_id=${AIRPHONE_airscaleNodeID[0]}11
#    Dated log       checking 0x52 board status
#    Wait Until Keyword Succeeds    5min  30s
#    ...             Check HW    ${AIRPHONE_airscaleNodeID[1]}
#    ...                 alias=${aliasAP}
#    ...                 CCS_Daemon_node_id=${AIRPHONE_airscaleNodeID[0]}11

Connect to AP
	[Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}  ${alias}=ssh-ap-${ue_id}-${ue_comu_id}
	sleep    300s
    ssh.Connect_to      hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...                 username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...                 password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    [Return]    ${alias}

Ap Check Airscale One Time
    ${aliasAP}          Connect to AP
    Dated log       checking 0x50 board status    first=True
    Wait Until Keyword Succeeds    5min  30s
    ...                 Check HW    0x50
    ...                 alias=${aliasAP}
    ...                 CCS_Daemon_node_id=0x5011
    Dated log       checking 0x52 board status
    Wait Until Keyword Succeeds    5min  30s
    ...                 Check HW    0x52
    ...                 alias=${aliasAP}
    ...                 CCS_Daemon_node_id=0x5011


Switch off AP on port
    [Documentation]
    ...    Powers OFF given port, waits a number of seconds and power ON given port.
    ...    Returns true when the given port is "on" again.
    [Arguments]    ${pdu_port_num}
    ${Ports} =    BuiltIn.Create List    ${pdu_port_num}
    BuiltIn.Log    Port switching off... Ongoing on ${pdu_port_num}   console=yes
    pdu.reset_ports    ports=${Ports}    time_interval=5    pdu_device=ap_pdu_switch
    sleep    ${timeout_for_switch_on}
    ${port_status}=    pdu.get_port_status    port=${pdu_port_num}    pdu_device=ap_pdu_switch
    ${status}=    run keyword if    "${port_status}" == "on"    set variable    ${True}
    ...    ELSE    set variable    ${False}
    Sleep       60s
    [return]    ${status}


Check iRfHead Service
    ${aliasAP}          Connect to AP
    ${output}           common_frt.Ssh Execute With Timeout    ps -edf | grep [i]rfhead   connection=${aliasAP}
    Should Not Be Empty    ${output}
    Should Contain    ${output}    /opt/airphone_irfhead/IRFHeadExe
    ${output}    common_frt.Ssh Execute With Timeout   systemctl status irfheadexe    connection=${aliasAP}
    Should Not Be Empty    ${output}
    Should Contain    ${output}    Active: active (exited)


Verify RF detection
#    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   bts_port=443   name=coam_admin
    wait until keyword succeeds    10min    30sec      Verify RF status
    BuiltIn.Log    RF is now detected    console=yes
#    [Teardown]  coam.teardown    connection=coam_admin


Verify RF status
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    ${output}=    coam.get frm    timeout=30    connection=coam_admin
    Log Many      ${output}
    Should Not Be Empty    ${output}
    FOR    ${elem}    IN    @{output}
    Should contain    ${elem['status']['operationalState']}      Enabled
    Should contain    ${elem['status']['availabilityStatus']}    Online
    END
    [Teardown]  coam.teardown    connection=coam_admin


Get Boot ID
    [Arguments]    ${connection}    ${name}    ${boot_ids}
    [Documentation]     get boot id from journal and store in dict
    ${bootNr}    common_frt.Ssh Execute With Timeout    journalctl --list-boots | tail -n 1 | awk '{print $1}' | tr -d '\r\n'
    ...     connection=${connection}
    Run Keyword If    '${bootNr}'!='0'    FAIL    msg=\n\t${name}: wrong bootNr=${bootNr}\n
    ${bootId}    common_frt.Ssh Execute With Timeout    journalctl --list-boots | tail -n 1 | awk '{print $2}' | tr -d '\r\n'
    ...     connection=${connection}
    Collections.Set To Dictionary    ${boot_ids}    ${name}    ${bootId}
    [Return]    ${bootId}


Log Configuration Flags
    Dated log                   Configuration Flags: EIF2=${EIF2_flag} isAio=${isAio}


Execute delta commissioning
    [Arguments]    ${delta_scf_template}    ${resultDir}    ${gnb_id}=${0}    ${component}=DU    ${timeout}=180
    ${oam_alias}=    ute_cfg_files_mgt.Setup OAM session    gnb_id=${gnb_id}
    ${oam_type}=     ute_cfg_files_mgt.Get OAM type   gnb_id=${gnb_id}
    Run Keyword If    '${oam_type}'=='coam' or ('${oam_type}'=='cloud_coam' and '${component}'=='DU')
    ...    Delta commissioning coam    delta_scf_template=${delta_scf_template}    resultDir=${resultDir}    oam_alias=${oam_alias}
    ...    gnb_id=${gnb_id}     timeout=${timeout}
    ...    ELSE    Delta commissioning megazone    delta_scf_template=${delta_scf_template}  #Replace with cloud coam CU commissioning
    ...    resultDir=${resultDir}    oam_alias=${oam_alias}    gnb_id=${gnb_id}
    Teardown cOAM session    connection=${oam_alias}


Delta commissioning coam
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param delta_scf_template: Path to delta SCF template
    ...    :param resultDir: Result directory to store SCF
    ...    :param oam_alias: Alias of OAM session
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]     ${delta_scf_template}    ${resultDir}    ${oam_alias}    ${gnb_id}=${0}    ${timeout}=180
    #${in_file_temp}=    Get file    ${delta_scf_template}
    ${in_file_temp}=    OperatingSystem.get file    ${delta_scf_template}
    ${out_file_temp}=    Replace variables    ${in_file_temp}
    ${scf_temp}=    Set variable    ${resultDir}/gNB${gnb_id}_delta_SCF.xml
    Create File    ${scf_temp}    ${out_file_temp}


    BuiltIn.Log    Start commissioning of gNB${gnb_id}    console=${P_console}
    ${update_status}   coam.Perform Delta SCF xml recommission
    ...    delta_scf_path=${scf_temp}
    ...    delta_operation=update
    ...    timeout=${timeout}
    ...    alias=${oam_alias}
    BuiltIn.Log    Commissioning of gNB${gnb_id} is done!    console=${P_console}
    [Return]    ${update_status}


Delta commissioning megazone
    [Documentation]    :Author: Vasileios Papoutsis
    ...    replaces variables in scf file, sends the file to gNB and activates it
    ...    keyword fails if variables in scf file are not defined
    ...    :param delta_scf_template: Path to delta SCF template
    ...    :param resultDir: Result directory to store SCF
    ...    :param oam_alias: Alias of OAM session
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${delta_scf_template}    ${resultDir}    ${oam_alias}    ${gnb_id}=${0}
#    ${in_file_temp}=    Get file    ${delta_scf_template}
    ${in_file_temp}=    OperatingSystem.get file    ${delta_scf_template}
    ${out_file_temp}=    Replace Variables    ${in_file_temp}
    ${scf_temp}=    Set variable    ${resultDir}/gNB${gnb_id}_delta_SCF.xml
    Create File    ${scf_temp}    ${out_file_temp}

    BuiltIn.Log    Start commissioning of gNB${gnb_id}    console=${P_console}
    ${out}=    megazone.validate scf    scf_path=${scf_temp}    max_retry=${10}    session=${oam_alias}    timeout=${180}
    @{validatonResult}=    megazone.get validation results    session=${oam_alias}    timeout=${180}
    ${result}=    megazone.perform commissioning    scf_path=${scf_temp}    session=${oam_alias}    timeout=${180}
    BuiltIn.Log    Commissioning of gNB${gnb_id} is done!    console=${P_console}
    [Return]    ${result}

Wait for ${time}
    sleep   ${time}

Test Case Setup with 50MHz BW
   Perform SCF Delta Commissioning with delta_scf_chBw_50MHz_scs_30KHz_TDD.json
   Wait for 5s
   Activate Test dedicated Mode for ASIK

Test Case Setup with 70MHz BW
   Perform SCF Delta Commissioning with delta_scf_chBw_70MHz_scs_30KHz_TDD.json
   Wait for 5s
   Activate Test dedicated Mode for ASIK

Test Case Setup with 90MHz BW
   Perform SCF Delta Commissioning with delta_scf_chBw_90MHz_scs_30KHz_TDD.json
   Wait for 5s
   Activate Test dedicated Mode for ASIK

TCs Teardown
    [Documentation]                 Add reset_ap flag, to launch a restart of Airphone, in case gnb restarts
    [Arguments]                     ${reset_ap}=${False}
    Log to console                  Test Suite Teardown
    OAM Restore Files               reset_ap=${reset_ap}
    # Run Keyword if                  ${TLConfig.isGnbCloud}==${False}          OAM Restore
    Suite Restore Files
    run keyword if any tests failed        Test Teardown if test Fail

Test Teardown if test Fail
    Dated log                       Get Sos Report and Snapshot
    Get Sos Report
    Get Snapshot


Get TL Info for TC
    [Documentation]                 Retrieve several info from GNB OAM, display them and print them in a log file
    ...                             Information retrieved are :
    ...                                 BTS_INFO, MRBTS_ID and NRCELL_DIST_NAME
    ...                                 GNB software version
    ...                                 GNB alarms
    Get TL Info Struct for TC
    Dated log                       Get INFO on TL from OAM
    ${GNB_ALARMS}                   OAM Get Active Alarms                   oam=${AIRSCALE_GNB.oam}
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable              ${sw_version}                           ${GNB_SW_VERSION}
    OAM Get GNB BTS Info            oam=${GNB_DU.oam}
    # Display on console
    Dated log                       \tGNB_SW_VERSION=${GNB_SW_VERSION}
    Dated log                       \tMRBTS_ID=${MRBTS_ID}
    Dated log                       \tNRBTS_ID=${NRBTS_ID}
    Dated log                       \tNRCELL_DIST_NAME=${NRCELL_DIST_NAME}
    # Store in log file
    ${StatusFile}                   set variable                            ${LOG_PATH}/${STATUS_FILE_NAME}
    Create File                     ${StatusFile}
    Append To File                  ${StatusFile}                           ${aliasGNB}:SW =${GNB_SW_VERSION}\n\n
    Append To File                  ${StatusFile}                           ${aliasGNB}:MRBTS_ID = ${MRBTS_ID}\n\n
    Append To File                  ${StatusFile}                           ${aliasGNB}:NRCELL_DIST_NAME = ${NRCELL_DIST_NAME}\n\n
    Append To File                  ${StatusFile}                           ${aliasGNB}:ALARMS = ${GNB_ALARMS}\n\n
    [Teardown]                      OAM Disconnect                          ${AIRSCALE_GNB.oam}


Get TL Info Struct for TC
    Dated Log New Line              Get INFO on TL from SYS/BB cards (GNB and AP)
    Get Info From cards             airscale=${AIRSCALE_GNB}                kind=GNB
    Get Info From cards             airscale=${AIRSCALE_AP}                 kind=AP
    Run Keyword and ignore Error    WA Update Nodes and Logs Def for TC


WA Update Nodes and Logs Def for TC
    wait until keyword succeeds     10min    10s
    ...                            Update Nodes and Logs Def for TC


Update Nodes and Logs Def for TC
    [Documentation]                 Update nodes and logs structure upon dynamic discovery
    ...                             After dynamic discovery of nodes, we resolve those nodes
    ...                             that have no link, but only a directory
    # Dynamic discovery of Nodes
    Nodes Discovery
    # Nodes Resolve Hard Coded
    Nodes Add Capture
    Nodes Display                   ${LIST_NODE}
    ${cprt_node}=         extract_cprt_node_id       ${LIST_NODE}
    set suite variable    ${cprt_node_id}            ${cprt_node}
    Nodes Check Found for TC

    # Build Log definition
    Run keyword if                  ${TLConfig.isGnbCloud}
    ...                             Set Logs Variables for CLOUD
    Logs Build
    Logs UpdateFromNode             listLog=${LIST_LOG}
    ...                             listNode=${LIST_NODE}
    Logs Display Def                listLog=${LIST_LOG}


Nodes Check Found for TC
    [Documentation]                 Check all expected nodes are present
    FOR    ${nodeName}     IN      @{LIST_NODE_NAME_5GC002493}
    ${node}                 Get Node                        ${nodeName}
    Run keyword if          '${node}'=='None'    #and '${nodeName}'!='L2PS'
    ...                     Run keyword if                  ${TLConfig.isGnbCloud}==${False}
    ...                     Run Keywords
    ...                         Dated Log                   ERROR: Node ${nodeName} not found during dynamic discovery
    ...    AND                  Fail                        ERROR: Unable to find node : ${nodeName}
    END
    #\       Run keyword if          '${node}'=='None' and '${nodeName}'=='L2PS'
    #\       ...                     Dated Log                       WARNING:L2PS node not found (but tolerate it)


Capture start based on module
    [Documentation]                 Start a capture.
    ...                             1) full name of capture is computed, upon <withTN> flag
    ...                             2) previous capture is removed if existing
    ...                             3) new capture is launched on host/interface defined in <capture> fields
    ...                             4) if required (<check> flag), check process is running
    [Arguments]                     ${capture}                              # Reference to capture to be launched
    ...                             ${check}=True                           # Should we check tcpdump is running once launched ?
    # Set capture name : either prefix or prefix.<test_name>
    ${TestName}                     getFormattedTestName
    ${capture.name}                 Set variable                            ${capture.prefix}
    ${capture.name}                 Set variable if                         ${capture.withTN}
    ...                             ${capture.name}.${TestName}             ${capture.name}
    # Set Capture Root Path upon host : if host has OAM as proxy, we should use  ${CAPTURE_ROOT_PATH_LOCAL}
    run keyword if                  ${capture.isNode}
    ...                             Capture Prepare from Node               ${capture}
    ...   ELSE                      Capture Root Path Set                   ${capture}
    Dated Log                       CaptureRootPath=(${capture.CaptureRootPath}) CaptureRootPathCmd=(${capture.CaptureRootPathCmd})
    Dated Log                       Capture Node Id = ${capture.node.nodeId}
    # Remove eventual previous local cature file
    ${tcpdumpCmd_path}              Set Variable                            ${capture.CaptureRootPathCmd}/${capture.name}.pcap
    ${tcpdump_path}                 Set Variable                            ${capture.CaptureRootPath}/${capture.name}.pcap
    ${alias}                        SSH Connect                             host=${capture.host}
    csn.execute                     rm -rf ${tcpdump_path}                  connection=${alias}
    # Launch a new capture
    ${sudoPrefix}                   Sudo Prefix                             ${capture.host}
    ${cmd}                          set variable
    ...                             ${sudoPrefix}tcpdump -i ${capture.interface} -w ${tcpdumpCmd_path} ${capture.filter}
    ${cmd}                          set variable if                         ${capture.isNode}
    ...                             lxc-attach -n ${cprt_node_id} -- ${cmd}
    ...                             ${cmd}
    Dated Log                       Start tcpdump on ${alias} (${cmd})
    csn.send_command                ${cmd}                                  connection=${alias}
    # Check corresponding process was properly launched
    run keyword if                  '${check}'=='True'
    ...                             Check Tcpdump Is Running                ${tcpdumpCmd_path}
    ...                             alias=${alias}                          isRunning=True

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Modify Swconfig File Parameters
    [Arguments]    ${path}    ${rd_parametrs}
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if RD already exists.
    ...    This keyword is excuted locally, not on gnb or airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${path} | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | ${rd_parametrs} | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ${content}    OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
         Continue For Loop If    '${item}'=='${EMPTY}'
         ${key}    ${val}    String.Split String    ${item}    =    1
         ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
         ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
    ...    ${content}    @{matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} 'toor4nsn@192.168.255.1:/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt'
    Should Be Equal As Integers    ${rc}    0
