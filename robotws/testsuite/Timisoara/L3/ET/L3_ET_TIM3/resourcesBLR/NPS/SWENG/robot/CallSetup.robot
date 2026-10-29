*** Settings ***
Documentation                       Module to manage main actions required to setup a call
...                                 Main services are :
...                                     - WTS Setup             : start, configure and establish X2 link on WTS
...                                     - SgNB Addition to ENB  : Launch procedure to attach gNB to eNB

Library                             taf.wts.runner                         WITH NAME    wtsemu
Library                             ../python/ReadConfig.py
Resource                            SetConfig.robot
#Resource                            Capture.robot

*** Variables ***
# Default throughtput is 2 mega.
${DEFAUT_THROUGHPUT}                2
${NO_THROUGHPUT}                    0

# Ids for eNB (4G) and gNB (5G) as set in configuration file on WTS
# Changes these calues ONLY accordingly deployed WTS config file
${ENB_ID}                           1
${GNB_ID}                           2
${TARGET_CELLS}                     1

# UE Profile for call Setup         : Dictionary to define different settings required fro call setting
#       ue       :  Ue id
#       profile  : Profile id or None
#       bearer   : bearer id or comma list of bearer ids (2,8,...)
#       tesMode  : should test mode be used (True or False)
#       trf_id   : identifier for the traffic
# List of common useful profiles for traffic
&{UE_NO_PROFILE}                    ue=1                                    profile=None
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE}                        ue=1                                    profile=1
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE_TEST_MODE}              ue=1                                    profile=1
...                                 bearer=2                                testMode=True
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

*** Keywords ***
#===================================
# WTS Setup
#===================================
WTS Setup
    [Documentation]                 Clean WTS (processes, logs), restart ePC simulator
    ...                             and configure it to establish a X2 link between eNB and gNB
    [Arguments]                     ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    ...                             ${nbUe}=1    ${nbSaUe}=0
    ...                             ${shouldUseLua}=${True}
    ...                             ${bypassX2Setup}=${False}
    # Clean WTS from process and logs point of view
    ${isSANSA}                   set variable if    '${NWtype}' == 'SA+NSA'    ${True}    ${False}
    set suite variable    ${isSANSA}
    ${alias}		                SSH Wait For Connect                    host=${HOST_EPCSIM}
    Dated Log New Line              Starting WTS setup (WTS:IP=${HOST_EPCSIM.sshConnection.addr})
    WTS Clear
    # Cloud only
    Run Keyword If                  ${TLConfig.isGnbCloud}
    ...                             WTS Set Backhaul IP                     ${alias}
    # Init lua config file with nb of UE
    ${LuaFileName}                  TxtConfig Init                          nbUe=${nbUe}    nbSaUe=${nbSaUe}
    run keyword unless    ${shouldUseLua}    Check For SaNsa
    # Configure eDaemon and eGate
    WTS Start processes             telnet_egate_addr=${telnet_egate_addr}
    # Launching configuration
    WTS Configure upon format       shouldUseLua=${shouldUseLua}            luaFile=${LuaFileName}
    Dated log                       Wait for SIBs (5min max)
    run keyword if    ${isSANSA}    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=SystemInformationBlockType1-NR updated
    ...                             timeout=300
    run keyword if    ${isSANSA}    UE Cell Setup Check
    return from keyword if          ${bypassX2Setup}==${True}
    # Establish X2 Link, reset reconfigure and retry in case of failure
    ${status}                       Run keyword and return status           WTS Set X2 Link
    Run keyword if                  ${status}==${False}
    ...                             Run keywords
    ...                                 wtsemu.Reset Wtsemu Cfg
    ...     AND                         WTS Configure upon format
    ...                                     shouldUseLua=${shouldUseLua}
    ...                                     luaFile=${LuaFileName}
    ...     AND                         WTS Set X2 Link

WTS Clear
    [Documentation]                 Kill eDaemon and eGate processes, purge WTS logs
    [Arguments]                     ${host}=${HOST_EPCSIM}
    SSH Wait For Connect            ${host}
    wtsemu.kill_wtsemu_edaemon      edaemon_port=${tl.core.edaemon_port}
    ...                             connection=${host.alias}
    wtsemu.kill_wtsemu_egate        egate_port=${tl.core.egate_port}
    ...                             connection=${host.alias}
    wtsemu.stop_wtsemu
    Sleep                           1s
    SSH Cmd                         cd ${tl.core.dir_path}; rm -f *log*     alias=${host.alias}

WTS Start processes
    [Documentation]                 Start eDaemon and eGate, and telnet connexion to it
    ...                             then, invoke a reset of its configuration
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ...                             ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    # Start eDaemon and eGate
    Dated log                       Starting WTS processes
    wtsemu.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}             directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}
    wtsemu.Configure Wtsemu Egate    egate_ssh_alias=${alias}               directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tl.core.egate_port}
    sleep                           3s
    wtsemu.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${tl.core.egate_port}
    sleep                           5s
    Dated Log                       \tResetting WTS configuration
    wtsemu.Reset_Wtsemu_Cfg

WTS Configure upon format
    [Arguments]                     ${shouldUseLua}=${True}
    ...                             ${luaFile}=${EMPTY}
    Run Keyword if                  ${shouldUseLua}
    ...                             WTS Configure                           ConfigFileName=${luaFile}
    ...   ELSE                      WTS Configure                           ConfigFileName=${tl.core.cfg_filename}

WTS Configure
    [Documentation]                 Set configuration for WTS from fiole as pointed in __init__.py
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ...                             ${ConfigFileName}=${tl.core.cfg_filename}
    Dated Log                       \tConfiguring WtsEmu with ${tl.core.dir_path}/${ConfigFileName}
    wtsemu.Configure                file=${tl.core.dir_path}/${ConfigFileName}
    # Check we reach active state
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=CHANGE STATE: ACTIVE - SimMode is ready now
    ...                             timeout=45
    sleep                           30s

WTS Set Backhaul IP
    [Documentation]                 Retrieve "dynamic" IP@ of UPUE backhaul, then update configuration file on WTS consequently
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=sudo ip addr show backhaul | grep -Po 'inet \\K[\\d.]+'
    ...                             host=${HOST_GNB_UPUE}
    ${ip}                           Strip String                            ${output}
    Should Not Be Empty             ${ip}
    Dated log                       \tgNB UPUE backhaul IP: ${ip}
    ${file}                         set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    SSH Cmd                         command= sudo sed -i 's/set ENB2_S1_ADDR=.*/set ENB2_S1_ADDR="${ip}"/g' ${file}
    ...                             alias=${alias}
    SSH Cmd                         sudo fuser -k 2152/udp                  alias=${alias}

WTS Set X2 Link
    [Documentation]                 Establish on WTS the X2 link between eNB and gNB
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    wtsemu.Enb X2 Link Up           enb=${ENB_ID}                               target=${GNB_ID}
    sleep                           3s
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${GNB_ID} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=500
    run keyword unless  ${isSANSA}  wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell Setup completed
    ...                             timeout=500
    sleep                           7s

#===================================
# GNB Attach to ENB
#===================================
SgNB Addition to ENB
    [Documentation]                 Start gnb attach to enb. A SCTP capture is also started during the SgNB addition
    ...                             Also, another capture (for instance, for BIP messages) may be performed on demand
    ...                             Meaning if a <captureCallback> and its asociated <capture> structure is provided
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${expected_gnb_log}=Successfully reconfigured dual connectivity
    ...                             ${withTN}=${False}
    Dated Log New Line              Starting GNB attach to ENB
    ${captureCORE}                  Capture CORE Set Upon Config
    Capture Init                    ${captureCORE}
    ...                                 withTN=${WithTN}
    ...                                 suffix=_GNB_ADDITION_UE${ueSetting.ue}
    Capture Start                   ${captureCORE}
    UE Attach Enb                   ueSetting=${ueSetting}
    Traced Sleep                    duration=5s                    msg=Workaround for pb Attach Gnb
    UE Attach Gnb                   ueSetting=${ueSetting}
    ...                             captureCallback=${captureCallback}
    ...                             capture=${capture}
    ...                             expected_gnb_log=${expected_gnb_log}
    Capture Stop                    ${captureCORE}
    [Teardown]                      Run keyword if                          '${KEYWORD_STATUS}'!='PASS'
    ...                             Capture Stop                            ${captureCORE}
    [Return]                        ${captureCORE.path}

UE Attach Enb
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    # Launch UE Attach with or without profile upon <ueSetting.profile>
    wtsemu.Ue Attach                        id=${ueSetting.ue}
    #Run keyword if                  '${ueSetting.profile}'=='None'
    #...                             wtsemu.Ue Attach                        id=${ueSetting.ue}
    #...     ELSE                    wtsemu.Ue Attach                        id=${ueSetting.ue}
    #...                             profile=${ueSetting.profile}
    wtsemu.Read Wtsemu Output Until Re  expected=UE IS ACTIVE               timeout=10
    Dated Log                       4G Attach is successful (UE=${ueSetting.ue} Profile=${ueSetting.profile})

UE Attach Gnb
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${expected_gnb_log}=Successfully reconfigured dual connectivity
    # Start tcpdump on BIP if required
    Callback Start Capture          callback=${captureCallback}             capture=${capture}
    sleep                           400 ms
    # Launch Enb Start
    wtsemu.enb_ue_dc_start          ue=${ueSetting.ue}
    ...                             target_gnb=${ueSetting.target_gnb}
    ...                             target_cells=${ueSetting.target_cells}
    ...                             bearer=${ueSetting.bearer}
    ...                             type=split_scg
    # Force testModeValue to csi_report_override if not already defined
    ${IsKeyExist}                   Is Key Exist
    ...                             ${ueSetting}                            testModeValue}
    ${ueSetting.testModeValue}      set variable if                         ${IsKeyExist}
    ...                             ${ueSetting.testModeValue}              csi_report_override
    run keyword if                  ${ueSetting.testMode}                   wtsemu.ue testmode set
    ...                             id=${ueSetting.ue}
    ...                             profile_index=${ueSetting.profile}
    ...                             action=activate
    ...                             test_mode=${ueSetting.testModeValue}
    sleep                           1800 ms
    # Stop BIP capture (if required)
    Callback Stop Capture           callback=${captureCallback}              capture=${capture}
    # Check console result
    Dated Log                       sgNb Addition procedure check ${expected_gnb_log}
    wtsemu.Read Wtsemu Output Until  expected=${expected_gnb_log}            timeout=30
    Dated Log                       sgNb Addition procedure is completed successfully
    Sleep                           5

UE Detach Enb
    [Documentation]                 Detach from Enb
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    Dated log                       UE detach UE${ueSetting.ue}
    wtsemu.Ue Detach                id=${ueSetting.ue}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UE${ueSetting.ue}: detached
    ...                             timeout=10

UE Attach Detach
    [Documentation]                 Attempt a re attach then a detach on GNB
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    UE Attach Enb                   ueSetting=${ueSetting}
    sleep                           30s
    UE Attach Gnb                   ueSetting=${ueSetting}
    sleep                           20s
    UE Detach Enb                   ueSetting=${ueSetting}

UE Attach Check
    [Documentation]                 Check in AP that attach is OK
    ...                             previously : Verify AP Classical UE attach
    Grep and check in file          host=${AIRSCALE_AP.sys[0].M}            file=/tmp/APL3.log
    ...                             grep=crnti    pattern=crnti=

UE Cell Setup Check
    [Documentation]                 Check in AP that cell setup is OK
    ...                             previously : Verify AP Classical Cell Setup
    [Arguments]                     ${waitTime}=60s
    Traced Sleep                    duration=${waitTime}                    msg=UE Cell Setup check
    Grep and check in file          host=${AIRSCALE_AP.sys[0].M}            file=/tmp/APL3.log
    ...                             grep=complete                           pattern=Cell Setup completed

Grep and check in file
    [Arguments]                     ${host}                                 ${file}
    ...                             ${grep}                                 ${pattern}
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd
    ...                                 grep ${grep} ${file}
    ...                                 alias=${alias}
    should contain	                ${output}	                            ${pattern}

Check For SaNsa
    ${UE_SIMPLE.ue}              set variable if    ${isSANSA}    11    1
    ${UE_SIMPLE_TEST_MODE.ue}    set variable if    ${isSANSA}    11    1
    ${UE_NO_PROFILE.ue}          set variable if    ${isSANSA}    11    1

WTS Set XpAP and X2 Link
    [Documentation]                 Establish on WTS the XpAP link between eNB and gNB
    [Arguments]                     ${id}=1    ${targetGnb}=2
    Dated log                       Establishing XP link between eNB and gNB
    wtsemu.enb_xp_param             id=${id}    ignore_xp=off    xp_listening_socket=on
    wtsemu.enb_xp_param             id=${id}    xp_peers=${targetGnb}
    sleep                           3s
    wtsemu.enb_xp_link_up           enb=1       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: XpAP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=60
    wtsemu.enb_x2_link_up           enb=1       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=60

DSS Partnership Creation
    [Documentation]                 CRM Partnership Creation
    [Arguments]                     ${cellIdGnb}=2
    Dated log                       CRM Partnership Creation
    wtsemu.enb_dss_param            id=1     feature_flag=on     message_sets=V1,DMS2
    wtsemu.enb_cell_param           enb=1    id=1    lte_nr_dss_mode=DL_CRS_TDM_UL_FDM
    wtsemu.enb_dss_configure_partnership     enb=1   cell=1      dss_peer=2:${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=CRM Partnership Creation
    ...                             timeout=60

DSS Establish Partnership
    [Documentation]                 DSS Establish Partnership
    [Arguments]                     ${cellIdGnb}=2    ${targetGnb}=2
    ${dans}    set variable         0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    Dated log                       DSS Establishing Partnership
    wtsemu.enb_crm_cell_resource_reservation     enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          assigned_dl_minimum_share_to_nr=15     assigned_dl_maximum_share_to_nr=70
    ...                                          assigned_dl_minimum_share_to_lte=15    assigned_dl_maximum_share_to_lte=70
    ...                                          assigned_ul_minimum_share_to_nr=20     assigned_ul_maximum_share_to_nr=70
    wtsemu.enb_dss_establish_partnership         enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell .*: EN DSS UL Cell Subcarrier Resource Coordination\n*success on remote NE
    ...                             timeout=60
    wtsemu.enb_crm_param                         id=1          ul_qos_load_meas_timer=200              dl_qos_load_meas_timer=200
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=DL   allocation_start_time=immediate   dl_allocated_normal_subframes=${dans}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received DSS DL Qos Load Indication SequenceNum\nber=0
    ...                             timeout=60
    wtsemu.enb_dss_resource_allocation           enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          dir=UL        allocation_start_time=immediate         ul_allocated_prb_list=9,30
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Received EN DSS UL Qos Load Indication Sequence\nNumber=0
    ...                             timeout=60
