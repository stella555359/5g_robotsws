*** Settings ***
Documentation
...                  == Purpose ==
...                  Module to manage main actions required to setup a call on simulator WTS module set (Airphone, ePCSim, LTESim).
...
...                  == Description ==
...                  This library support NSA and SA calls by using the simulator WTS module set (Airphone, ePCSim, LTESim).
...                  This library does not contain keyword to manage UE traffic.
...                  Main services are :
...                          - WTS Setup              : Start, configure and establish X2 link on WTS.
...                          - Check cell setup       : Checking cell setup messages on eGate console and/or Airphone log file.
...                          - SgNB Addition to ENB   : Trig secondary gNB addition of a NSA UE after attach procedure.
...                          - UE attach/detach       : Attach and detach precedures for NSA UE.
...                          - UE register/deregister : Register and deregister precedures for SA UE.
...                          - DSS                    : DSS configuration and establishment.
...
...                 The CallSetup library is part of the SWENG environment. So to use this library in a robot test,
...                 it is important to import the SWENG Setup.robot library to define the 'Setup Suite' and the 'Teardown Suite' keywords.
...                 Without the use of the 'Setup Suite' of the SWENG environment, the CallSetup library could malfunction because
...                 variables linked to the environment would not be initialized.
...
...                 A certain number of keywords is based on a dictionary (mainly corresponding to the ueSetting argument) to describe the UE profile
...                 and which allows the expected good processing. This dictionary is also used by traffic keywords in the traffic.robot library
...                 (see traffic.robot).
...
...                 Overview of directory structure:
...                  - ue            : Ue id from config.cfg of Airphone.
...                  - profile       : Profile id or None (used in UE Attach NSA).
...                  - bearer        : One or more bearer id. In case of several bearer id, the format is a string containing a list of bearer id \
...                                    with each bearer id separated by a comma (2,8,...).
...                  - tesMode       : Should test mode be used (True or False) for NSA mode.
...                  - trf_id        : Id for the traffic.
...                  - pdu           : Used for SA mode.
...                  - qfi           : Used for SA mode.
...                  - target_gnb    : Used by UE Attach in NSA mode.
...                  - target_cells  : Camped cell of UE.
...                  - type          : Used by bearer stat for traffic checking.
...                  - burts         : Specific usage when start traffic.
...                  - throughput    : Throughput requested to be generated on the bearer.
...                  - testModeValue : Used in UE Attach gNB in NSA mode during RACH procedure.
...
...          4 variables based on the distionay structure to define UE profile in CallSetup library.
...
...          _3 variables for NSA call_:
...
...          *&{UE_NO_PROFILE}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          *&{UE_SIMPLE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          *&{UE_SIMPLE_TEST_MODE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | True                 |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          _1 variable for SA call_:
...
...          *{BASIC_UE_SA}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | ${None}              |
...            | pdu           | 1                    |
...            | bqfi          | 1                    |
...            | bearer        | ${None}              |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | ${None}              |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...        _Other variables are defined in library CallSetup.robot_:
...        | ${DEFAUT_THROUGHPUT} | 2 | Default throughtput is 2 mega |
...        | ${NO_THROUGHPUT}     | 0 | Define no throughput          |
...        | ${ENB_ID}            | 1 | Id for eNB (4G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${GNB_ID}            | 2 | Id for gNB (5G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${TARGET_CELLS}      | 1 |                               |
...
...          _Example_:
...
...          Do an 5G call setup and do traffic:
...          - Setup WTS with 2 cells
...          - Register a UE in SA mode on 5G core network
...          - Open a PDU session
...          - Modify the QoSFlow of a PDU session 2 times
...          - Do a traffic (see Traffic.robot library)
...          - Deregister the UE from 5G core network
...          | *** Settings ***
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/Setup.robot
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/CallSetup.robot
...          | Resource \ \ \ \ \ \ \ \ \ \ \ \ \ \ ../../../resources/SWENG/robot/Traffic.robot
...          |
...          | Suite Setup \ \ \ \ \ \ \ \ \ \ \ Suite Setup
...          | Suite Teardown \ \ \ \ \ \ \ \ Suite Teardown
...          |
...          | *** Test Cases ***
...          | Do a call with traffic
...          | \ \ \ Setup Wtsemu SA \ \ \ \ \ \ \ \ nbCell=2
...          | \ \ \ UE Register \ \ \ \ \ \ \ \ \ \ \ \ ue=3
...          | \ \ \ Launch PDU Session \ \ \ \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ gw=3
...          | \ \ \ UE PDU Session Modify \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ qfta=2 \ \ \ by=amf
...          | \ \ \ UE PDU Session Modify \ \ ue=3 \ \ \ \ \ \ \ \ \ pdu=3 \ \ \ qfta=3 \ \ \ by=amf
...          | \ \ \ #
...          | \ \ \ # Do traffic during n secondes by using Traffic.robot library
...          | \ \ \ #
...          | \ \ \ UE Deregister \ \ \ \ \ \ \ \ \ id=3
...

Library                             taf.wts.runner                         WITH NAME    wtsemu
Library                             ../python/ReadConfig.py
Resource                            SetConfig.robot
Resource                            Capture.robot

*** Variables ***
# Default throughtput is 2 mega.
${DEFAUT_THROUGHPUT}                2
${NO_THROUGHPUT}                    0

# Ids for eNB (4G) and gNB (5G) as set in configuration file on WTS
# Changes these values ONLY accordingly deployed WTS config file
${ENB_ID}                           1
${GNB_ID}                           2
${TARGET_CELLS}                     1

# UE Profile for call Setup         : Dictionary to define different settings required fro call setting
#       ue            : Ue id from config.cfg of Airphone.
#       profile       : Profile id or None (used in UE Attach NSA).
#       bearer        : One or more bearer id. In case of several bearer id, the format is a string containing a list of bearer id with
#                       each bearer id separated by a comma (2,8,...).
#       tesMode       : Should test mode be used (True or False) for NSA mode.
#       trf_id        : Id for the traffic.
#       pdu           : Used for SA mode.
#       qfi           : Used for SA mode.
#       target_gnb    : Used by UE Attach in NSA mode.
#       target_cells  : Camped cell of UE.
#       type          : Used by bearer stat for traffic checking.
#       burts         : Specific usage when start traffic.
#       throughput    : Throughput requested to be generated on the bearer.
#       testModeValue : Used in UE Attach gNB in NSA mode during RACH procedure.
# List of common useful profiles for traffic
&{UE_NO_PROFILE}                    ue=1                                    profile=None        type=l3
...                                 pdu=${None}                             qfi=${None}
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE}                        ue=1                                    profile=1           type=l3
...                                 pdu=${None}                             qfi=${None}
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE_TEST_MODE}              ue=1                                    profile=1           type=l3
...                                 pdu=${None}                             qfi=${None}
...                                 bearer=2                                testMode=True
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{BASIC_UE_SA}                      ue=1                                    profile=None        type=${None}
...                                 pdu=1                                   qfi=1
...                                 bearer=${None}                          testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=${None}                      target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

*** Keywords ***
#===================================
# WTS Setup
#===================================
WTS Setup
    [Documentation]                 Clean WTSEmu (processes, logs), restart ePC simulator (ePCSim)
    ...                             and configure it to establish a X2 link between eNB and gNB if gNB is configured in NSA mode.
    ...                             Wait for SIB-NR if not NSA and check cell setup.
    ...
    ...                             *Argument details:*
    ...                             - *telnet_egate_addr*: eGate VM IP address (default: dynamically retrieved)
    ...                             - *nbUe*: nb total of UE(s) to set in basic-setup LUA file (default value = 1)
    ...                             - *nbSaUe*: nb of SA UE(s) to set in basic-setup LUA file (default value = 0)
    ...                             - *shouldUseLua*: flag to choose between cfg or LUA basic-setup file (default value = True)
    ...                             - *bypassX2Setup*: flag to bypass the X2 setup - usually for SA (default value = False)
    ...                             - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value = 1)
    ...                             - *list_of_UE_tobe_created*: list of UEs structure to be created when using lua (default value = None)
    ...                                 mandatory params: ue & target_cells &{my_UE_SA}     ue=1    target_cells=2
    ...
    ...                             Exemple:
    ...                             | If nbUe = 10 and nbSaUe = 0, \ \ \ \ \ 10 NSA UE from 1 to 10, 0 SA UE
    ...                             | If nbUe = 10 and nbSaUe = 5, \ \ \ \ \ \ 5 NSA UE from 1 to 5, 5 SA UE from 6 to 10
    ...                             | If nbUe = 10 and nbSaUe = 10, \ \ \ \ \ 0 NSA UE, 10 SA UE from 1 to 10
    [Arguments]                     ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    ...                             ${nbUe}=1
    ...                             ${nbSaUe}=0
    ...                             ${shouldUseLua}=${True}
    ...                             ${bypassX2Setup}=${False}
    ...                             ${bypassSIB}=${False}
    ...                             ${nbCell}=1
    ...                             ${list_of_UE_tobe_created}=${None}
    ${cell_len}        Get length           ${GNB_BTS_INFO['cells']['nr']}
    ${cell_len}        Convert to string    ${cell_len}
    ${cell_nr}         set variable if      ${nbCell}==1    ${cell_len}    ${nbCell}
    set suite variable     ${cell_nr}
    # Clean WTS from process and logs point of view
    ${isSANSA}                   set variable if    '${NWtype}' == 'SA+NSA'    ${True}    ${False}
    set suite variable    ${isSANSA}
    ${isNSA}                     set variable if    '${NWtype}' == 'NSA'       ${True}    ${False}
    set suite variable    ${isNSA}
    ${alias}		                SSH Wait For Connect                    host=${HOST_EPCSIM}
    Dated Log New Line              Starting WTS setup (WTS:IP=${HOST_EPCSIM.sshConnection.addr})
    WTS Clear
    # Cloud only
    Run Keyword If                  ${TLConfig.isGnbCloud}
    ...                             WTS Set Backhaul IP                     ${alias}
    # Init lua config file with nb of UE
    ${LuaFileName}                  TxtConfig Init     nbUe=${nbUe}    nbSaUe=${nbSaUe}    list_of_UE_tobe_created=${list_of_UE_tobe_created}
    run keyword unless    ${shouldUseLua}    Check For SaNsa
    # Configure eDaemon and eGate
    WTS Start processes             telnet_egate_addr=${telnet_egate_addr}
    # Launching configuration
    WTS Configure upon format       shouldUseLua=${shouldUseLua}            luaFile=${LuaFileName}
    run keyword if                  not ${isNSA} and not ${bypassSIB}       wait until keyword succeeds     5min    10s
    ...                             Check SIB MultiCell    nbCell=${cell_nr}
    # launch cell setup check except for NSA topo, will be done after X2 setup
    run keyword if                  not ${isNSA}    UE Cell Setup Check
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

Setup Wtsemu SA
    [Documentation]                WTSEmu Setup for SA call. This is a call to keyword 'WTS Setup':
    ...                            | WTS Setup
    ...                            | ...   telnet_egate_addr=${tl.core.default_ssh_connection_details.addr}
    ...                            | ...   nbUe=1
    ...                            | ...   nbSaUe=${nbSaUe}
    ...                            | ...   shouldUseLua=${shouldUseLua}
    ...                            | ...   bypassX2Setup=${True}
    ...                            | ...   bypassSIB=${False}
    ...                            | ...   nbCell=${nbCell}
    ...                            See keyword 'WTS Setup' for more details.
    ...
    ...                            *Argument details:*
    ...                            - *nbSaUe*: number of SA UE to use (default value = 1, should be >= 1)
    ...                            - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value= 0 dynamically retrieved)
    ...                            - *shouldUseLua*: flag to choose between cfg or lua basic-setup file (default value = False)
    ...                            - *list_of_UE_tobe_created*: list of UEs structure to be created when using lua (default value = None)
    ...                                 mandatory params: ue & target_cells &{my_UE_SA}     ue=1    target_cells=2
    [Arguments]        ${nbUe}=1    ${nbCell}=1    ${nbSaUe}=1    ${shouldUseLua}=${False}    ${list_of_UE_tobe_created}=${None}
    CallSetup.WTS Setup         nbUe=${nbUe}    nbSaUe=${nbSaUe}    nbCell=${nbCell}    bypassX2Setup=${True}    shouldUseLua=${shouldUseLua}
    ...                         list_of_UE_tobe_created=${list_of_UE_tobe_created}

Empty Buffer For Egate
    [Documentation]                 INTERNAL USAGE
    ...                             to flush egate buffer (need to send 4096 bytes until "sim_log set flush" command implemented in taf)
    [Arguments]         ${max_loop}=5
    FOR    ${i}    IN RANGE    0    ${max_loop}
        wtsemu.sim_state_disp
    END

Check SIB MultiCell
    [Documentation]                 Check SIB-NR messages on egate console according to number of cells.
    ...                             *Argument details:*
    ...                             - *nbCell*: number of cell(s) to check for msg "SystemInformationBlockType1-NR" (default value = 1)
    [Arguments]         ${nbCell}=1
    Dated log                       Wait for SIBs
    Empty Buffer For Egate
    ${check_sibs}        SSH Wait For Connect and Cmd
    ...                 command=grep 'SystemInformationBlockType1-NR updated' ${tl.core.dir_path}/egate_console.log|wc -l    host=${HOST_EPCSIM}
    should be equal                 ${check_sibs.strip()}    ${nbcell}

WTS Clear
    [Documentation]                 Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs.
    ...
    ...                             *Argument details:*
    ...                             - host: vm ip address (default value = ${HOST_EPCSIM})
    [Arguments]                     ${host}=${HOST_EPCSIM}
    SSH Wait For Connect            ${host}
    wtsemu.stop_wtsemu
    wtsemu.kill_wtsemu_edaemon      edaemon_port=${tl.core.edaemon_port}
    ...                             connection=${host.alias}
    wtsemu.kill_wtsemu_egate        egate_port=${tl.core.egate_port}
    ...                             connection=${host.alias}
    Sleep                           1s
    SSH Cmd                         cd ${tl.core.dir_path}; rm -f *log*     alias=${host.alias}

WTS Start processes
    [Documentation]                 Start eDaemon and eGate, Establish an eGate connexion
    ...                             and remove configure of WTSEmu eGate controller.
    ...
    ...                             *Argument details:*
    ...                             - alias: VM connection alias (default value = dynamically retrieved)
    ...                             - telnet_egate_addr: VM eGate address (default value = dynamically retrieved)
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
    [Documentation]                 Configure WTSEmu by using a configuration file .cfg or .lua basic-setup file by using a command in eGate console
    ...                             and wait for the simulator to be ready.
    ...
    ...                             *Argument details:*
    ...                             - *shouldUseLua*: To use .lua file (default value = True)
    ...                             - *luaFile*: basic-setup lua file to use (value generated during execution of keyword 'WTS Setup')
    [Arguments]                     ${shouldUseLua}=${True}
    ...                             ${luaFile}=${EMPTY}
    Run Keyword if                  ${shouldUseLua}
    ...                             WTS Configure                           ConfigFileName=${luaFile}
    ...   ELSE                      WTS Configure                           ConfigFileName=${tl.core.cfg_filename}

WTS Configure
    [Documentation]                 INTERNAL USAGE
    ...                             Set configuration for WTS from file as pointed in __init__.py.
    [Arguments]                     ${ConfigFileName}=${tl.core.cfg_filename}
    ...                             ${pass_regexp}=CHANGE STATE: ACTIVE - SimMode is ready now
    Dated Log                       \tConfiguring WtsEmu with ${tl.core.dir_path}/${ConfigFileName}
    wtsemu.Configure                file=${tl.core.dir_path}/${ConfigFileName}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=${pass_regexp}
    ...                             timeout=300
    sleep                           30s

WTS Set Backhaul IP
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve "dynamic" IP@ of UPUE backhaul, then update configuration file on WTS consequently.
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ${vmUPUE}                       call method                             ${GNB_CU.oam}
    ...                             getVM                                   UPUE
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=sudo ip addr show backhaul | grep -Po 'inet \\K[\\d.]+'
    ...                             host=${vmUPUE}
    ${ip}                           Strip String                            ${output}
    Should Not Be Empty             ${ip}
    Dated log                       \tgNB UPUE backhaul IP: ${ip}
    ${file}                         set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    SSH Cmd                         command= sudo sed -i 's/set ENB2_S1_ADDR=.*/set ENB2_S1_ADDR="${ip}"/g' ${file}
    ...                             alias=${alias}
    SSH Cmd                         sudo fuser -k 2152/udp                  alias=${alias}

WTS Set X2 Link
    [Documentation]                 Establish on WTSEmu the X2 link between eNB and gNB.
    ...                             Wait for cell cetup for each cell by using keyword 'UE Cell Setup Check'.
    ...                             See keyword 'UE Cell Setup Check' for more details.
    ...
    ...                             *Argument details:*
    ...                             - alias: vm connection alias (default value = dynamically retrieved)
#    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    wtsemu.Enb X2 Link Up           enb=${ENB_ID}                               target=${GNB_ID}
    sleep                           3s
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${GNB_ID} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=500
    run keyword unless  ${isSANSA}  wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell Setup completed
    ...                             timeout=500
    sleep                           7s
    UE Cell Setup Check

#===================================
# GNB Attach to ENB
#===================================
SgNB Addition to ENB
    [Documentation]          Attach a NSA UE via eNB by using keyword 'UE Attach Enb' (for more details see keyword 'UE Attach Enb').
    ...                      Then trig the SgNB Addition procedure by using keyword 'UE Attach Gnb' (for more details see keyword 'UE Attach Gnb').
    ...                      A SCTP capture is also started during the SgNB addition.
    ...                      Also, another capture (for instance, for BIP messages) may be performed on demand:
    ...                      meaning if a <captureCallback> and its asociated <capture> structure is provided through arguments.
    ...                      Return path of trace capture file.
    ...
    ...                      *Argument details:*
    ...                      - *ueSetting*:        Reference to UE Settings  (default value = UE_NO_PROFILE)
    ...                      - *captureCallback*:  Reference to a KW call back or None  (default value = None)
    ...                      - *capture*:          Associated <Capture> structure if Callback is provided  (default value = None)
    ...                      - *expected_gnb_log*: Msg to validate enb_ue_dc_start (default value = Successfully reconfigured dual connectivity)
    ...                      - *withTN*:           If set to True, Test Name will be part of the pcap file (default value = False)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${captureCallback}=None
    ...                             ${capture}=None
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
    [Documentation]                 Attach specified NSA UE (signaling on eNB).
    ...                             Wait for '4G Attach is successful' message to appear on eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:       Reference to UE Settings structure  (default value = UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    wtsemu.Ue Attach                id=${ueSetting.ue}
    wtsemu.Read Wtsemu Output Until Re  expected=UE IS ACTIVE               timeout=10
    Dated Log                       4G Attach is successful (UE=${ueSetting.ue} Profile=${ueSetting.profile})

UE Attach Gnb
    [Documentation]           Launch enb_ue_dc_start commande in eGate console to trig SgNB Addition procedure for NSA UE.
    ...                       Wait for message "sgNb Addition procedure is completed successfully" to appear on eGate console.
    ...                       The capture of BIP traces in gNB are started before the procedure triggering and stopped 2.2 seconds later.
    ...
    ...                       *Argument details:*
    ...                       - *ueSetting*:        Reference to UE Settings structure  (default value = UE_NO_PROFILE)
    ...                       - *captureCallback*:  Reference to a KW call back or None (default value = None)
    ...                       - *capture*:          Associated <Capture> structure if Callback is provided (default value = None)
    ...                       - *expected_gnb_log*: Msg to validate enb_ue_dc_start (default value = Successfully reconfigured dual connectivity)
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
    Dated Log                       Checking sgNb Addition procedure...
    Empty Buffer For Egate
    wtsemu.Read Wtsemu Output Until  expected=${expected_gnb_log}            timeout=30
    Dated Log                       sgNb Addition procedure is completed successfully
    Sleep                           5

UE Detach Enb
    [Documentation]                 Detach specified NSA UE (signaling on eNB).
    ...                             Wait for detach message to appear on eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:        Reference to UE Settings structure (default value = UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    Dated log                       UE detach: UE ${ueSetting.ue}
    wtsemu.Ue Detach                id=${ueSetting.ue}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UE${ueSetting.ue}: detached
    ...                             timeout=10

UE Attach Detach
    # Keyword deprecated            TO BE REMOVED
    [Documentation]                 INTERNAL USAGE. Attempt a re-attach then a detach on GNB.
    ...                             *Argument details:*
    ...                             - *ueSetting*:        Reference to UE Settings structure  (default: UE_NO_PROFILE)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    UE Attach Enb                   ueSetting=${ueSetting}
    sleep                           30s
    UE Attach Gnb                   ueSetting=${ueSetting}
    sleep                           20s
    UE Detach Enb                   ueSetting=${ueSetting}

UE Attach Check
    [Documentation]                 Check in Airphone log file (/tmp/APL3.log) that message 'crnti=' is present.
    ...                            This keyword is only supported in mono UE.
    #...                             previously : Verify AP Classical UE attach
    Grep and check in file          host=${AP_DU.sys[0].M}            file=/tmp/APL3.log
    ...                             grep=crnti    pattern=crnti=

UE Cell Setup Check
    [Documentation]                 Check in Airphone that cell setup is OK for each cell by the presence of
    ...                             message 'Cell Setup completed for' in log file (/tmp/APL3.log).
    ...
    ...                             *Argument details:*
    ...                             - *waitTime*:   Time to wait (default value = 60s)
    #...                             previously : Verify AP Classical Cell Setup
    [Arguments]                     ${waitTime}=60s
    Traced Sleep                    duration=${waitTime}                          msg=UE Cell Setup check
    Grep and check is equal to cell number          host=${AP_DU.sys[0].M}               file=/tmp/APL3.log
    ...                             pattern='Cell Setup completed for \\[CELL_ID:'

Grep and check in file
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${host}                                 ${file}
    ...                             ${grep}                                 ${pattern}
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd
    ...                                 grep ${grep} ${file}
    ...                                 alias=${alias}
    should contain                  ${output}                               ${pattern}

Grep and check is equal to cell number
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${host}                                 ${file}
    ...                             ${pattern}
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd
    ...                                 grep ${pattern} ${file} | wc -l
    ...                                 alias=${alias}
    should be equal	                ${output.strip()}                               ${cell_nr}

Check For SaNsa
    [Documentation]                 INTERNAL USAGE
    ${UE_SIMPLE.ue}              set variable if    ${isSANSA}    11    1
    ${UE_SIMPLE_TEST_MODE.ue}    set variable if    ${isSANSA}    11    1
    ${UE_NO_PROFILE.ue}          set variable if    ${isSANSA}    11    1

WTS Set XpAP and X2 Link
    [Documentation]                 DSS Establishment on WTSEmu by up the XpAP and X2AP interface between eNB and gNB.
    ...                             The checking of XpAP up interface is done by the presence of the message 'XpAP Link with ... is up'
    ...                             on the eGate console.
    ...                             The checking of X2AP up interface is done by the presence of the message 'X2AP Link with ... is up'
    ...                             on the eGate console.
    ...
    ...                             *Argument details:*
    ...                             - *id*:        id to use (default value = 1)
    ...                             - *targetGnb*: targetGnb to use (default value = 2)
    [Arguments]                     ${id}=1    ${targetGnb}=2
    Dated log                       Establishing XP link between eNB and gNB
    wtsemu.enb_xp_param             id=${id}    ignore_xp=off    xp_listening_socket=on
    wtsemu.enb_xp_param             id=${id}    xp_peers=${targetGnb}
    sleep                           3s
    wtsemu.enb_xp_link_up           enb=${id}       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: XpAP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=120
    wtsemu.enb_x2_link_up           enb=${id}       target=${targetGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${targetGnb} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=60

DSS Partnership Creation
    [Documentation]                 Configure the DSS partnership between eNB/gNB on terget cell.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id gNB (default value = 2)
    [Arguments]                     ${cellIdGnb}=2
    Dated log                       CRM Partnership Creation
    wtsemu.enb_dss_param            id=1     feature_flag=on     message_sets=V1,DMS2
    wtsemu.enb_cell_param           enb=1    id=1    lte_nr_dss_mode=DL_CRS_TDM_UL_FDM
    wtsemu.enb_dss_configure_partnership     enb=1   cell=1      dss_peer=2:${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=CRM Partnership Creation
    ...                             timeout=60

DSS Establish Partnership
    [Documentation]                 Establish the DSS partnership by configure CRM resource reservation and resource allocation in UL and DL.
    ...
    ...                             *Argument details:*
    ...                             - *cellIdGnb*: Cell Id Gnb (default value = 2)
    ...                             - *targetGnb*: targetGnb to use (default value = 2)
    [Arguments]                     ${cellIdGnb}=2    ${targetGnb}=2
    ${dans}    set variable         0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    Dated log                       DSS Establishing Partnership
    wtsemu.enb_crm_cell_resource_reservation     enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    ...                                          assigned_dl_minimum_share_to_nr=15     assigned_dl_maximum_share_to_nr=70
    ...                                          assigned_dl_minimum_share_to_lte=15    assigned_dl_maximum_share_to_lte=70
    ...                                          assigned_ul_minimum_share_to_nr=20     assigned_ul_maximum_share_to_nr=70
    wtsemu.enb_dss_establish_partnership         enb=1    cell=1    tgt_enb=${targetGnb}    tgt_cell=${cellIdGnb}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=Cell .*: EN DSS UL Cell Subcarrier Resource Coordination.*\n*.*success on remote NE
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

UE Register
    [Documentation]           Register SA UE (signaling on gNB) and checking by apparition of message 'crnti' on eGate console.
    ...
    ...                       *Argument details:*
    ...    - *ue*:         Specified UE ID (default value = 1)
    ...    - *nwslice*:    id of the Network Slice containing the requested NSSAI (default: 1)
    ...    - *timeout*:    (default: 30)
    [Arguments]    ${ue}=1    ${timeout}=30
    wtsemu.ue_register    id=${ue}
    #...           nwslice=${nwslice}
    ${output}         wtsemu.Read Wtsemu Output Until Re
    ...               expected=crnti
    ...               timeout=${timeout}
    [Return]      ${output}

UE Deregister
    [Documentation]                 Deregister a SA UE (signaling on gNB) and checking by apparition of message 'UE Context Release Complete'
    ...                             on eGate console.
    ...
    ...                             *Argument details:*
    ...     - *id*:                 UE ID (default value = 1)
    ...     - *ue_deregister_type*: UE deregister type (default value = switch_off)
    ...     - *by*:                 device initiating the deregister procedure (default value = ue)
    [Arguments]    ${id}=1    ${ue_deregister_type}=switch_off    ${by}=ue
    Dated log                       UE detach: UE ${id}
    wtsemu.ue_deregister            id=${id}    ue_deregister_type=${ue_deregister_type}    by=${by}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UE Context Release Complete
    ...                             timeout=10

Launch PDU Session
    [Documentation]        Open a PDU session:
    ...                    - Set parameters of session.
    ...                    - Open the PDU session by using the keyword 'UE PDU Session Setup' (for more details see keyword 'UE PDU Session Setup').
    ...
    ...                    *Argument details:*
    ...    - *ue*:      the UE identifier (default value = 1)
    ...    - *pdu*:     the PDU identifier (default value = 1)
    ...    - *gw*:      the gateway identifier (default value = 1)
    ...    - *nwslice*: the network slice identifier (default value = 1)
    [Arguments]             ${ue}=1                  ${pdu}=1
    ...                     ${gw}=1                  ${nwslice}=1
    wtsemu.set_pdu_param    ue=${ue}                 pdu=${pdu}
    ...                     trf_type=internal
    UE PDU Session Setup    ue=${ue}
    ...                     pdu=${pdu}               gw=${gw}
    ...                     nwslice=${nwslice}
    Dated Log               PDU Session setup OK (ue=${ue})

UE PDU Session Setup
    [Documentation]           Open a PDU session.
    ...                       Check the message 'Initial Context Setup Successful' on eGate console.
    ...                       Return the IP address assigned to UE.
    ...
    ...                       *Argument details:*
    ...    - *pdu*:        PDU Session ID  (default = 1)
    ...    - *ue*:         Specified UE ID (default = 1)
    ...    - *nwslice*:    Requested Network Slice for the PDU Session  (default = 1)
    ...    - *gw*:         PDU Gateway ID. Specifies gateway to use for this PDU session OPTIONAl --> TBRM  (default = 1)
    ...    - *timeout*:    Timeout for message "Initial Context Setup Successful" (default = 30)
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${timeout}=30
    wtsemu.ue_pdu_session_setup
    ...               pdu=${pdu}                ue=${ue}
    ...               nwslice=${nwslice}        gw=${gw}
    ${output}         wtsemu.Read Wtsemu Output Until Re
    ...               expected=Initial Context Setup Successful
    ...               timeout=${timeout}
    ${output}         StringTool.getStringFromCmdReturn    ${output}
    ${pattern}=       Catenate                  Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...               UE IP address:([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})
    ${ue_ip}=         Get Regexp Matches        ${output}
    ...               ${pattern}                1
    [Return]      ${ue_ip[0]}

UE PDU Session Modify
    [Documentation]       Modify the QoSFlow of a PDU session.
    ...
    ...                   *Argument details:*
    ...    - *pdu*:        PDU Session ID  (default = 3)
    ...    - *ue*:         Specified UE ID (default = 3)
    ...    - *qfta*:       qosflows_to_add (default = 2)
    ...    - *by*:         by              (default = amf)
    [Arguments]    ${ue}=3    ${pdu}=3    ${qfta}=2    ${by}=amf
    Dated Log     Start "UE PDU Session Modify"
    wtsemu.ue_pdu_session_modify    ue=${ue}    pdu=${pdu}    qosflows_to_add=${qfta}    by=${by}
    ${output}    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=UPF-1: Added QosFlow with QFI:${qfta} fiveQI
    ...                             timeout=120
    Sleep    1s    reason=Waiting command to be executed
    [Return]    ${output}

Get UEid upon Topology
    [Documentation]                 INTERNAL USAGE.
    ...                             Return the UE_id values usable in some KW according to used topology.
    ...                             At the moment the value is 11 for SANSA, 1 for others.
    ${UE_id}                        Set Variable If                         ${isSANSA}
    ...                             11                                      1
    [Return]                        ${UE_id}
