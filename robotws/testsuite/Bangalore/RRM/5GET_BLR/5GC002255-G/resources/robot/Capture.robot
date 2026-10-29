*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage Capture of pcap file on one particular interface on a TL
...
...             == Description ==
...             *Concepts:*
...
...             The Capture class is implemented in Captures.py, and encapsule all information/material
...             to perform a particular capture on a TL. It contains following attributes:
...             | host      | reference to host on which tcpdump command should be launched                                      |
...             | interface | name of interface (etha01, ...) on which tcpdump command should be launched                        |
...             | node      | name of the node in the case capture should be launched on a node                                  |
...             | isNode    | toggle to indicate if capture should be done on a host or on a node                                |
...             | scriptDef | reference to script definition in case some mirroring commands are required                        |
...             | isMirror  | toglle that indicate if a mirroring should be applied                                              |
...             | prefix    | String for start of the name of the capture                                                        |
...             | withTN    | toggle to indicate if the name of the capture should be postfix with the name of the test          |
...             | name      | final name of the capture, computed with prefix, withTN and an eventual postfix (see capture init) |
...             | path      | Final path on VM where pcap file will be stored at the end of the capture                          |
...             | filter    | Optionally a filter can be applied natively on tcpdump command                                     |
...
...             This module is managing 3 kinds of capture :
...             | CORE Capture | Capture between gNB and WTS (which simulate the CORE network) to catch F1AP and X2AP messages  |
...             | CPRT Capture | Capture on CPRT container. Done via lxc attach                                                 |
...             | L1L2 Capture | To capture BIP messages. This capture needs to put in place a particular mirroring             |
...             For CORE captures on Classical TL, it is done at gNB side. Interface on which capture is initiated depends on the hardware
...             (ex: fp0 for ASIK, br1 for ASIB, br0 for ASIL/ASOE...)\n
...             For CORE captures on CloudBTS TL, it is done at WTS side and only X2AP messages are caught.
...
...
...             Concerning L1L2 captures, capture is done on a particular interface (eths2, eths3, pepbp1,...) and a particular
...             Mirroring script (sh script from shell directory) is used to map pertinent ports\n
...             See CAPTURE_L1L2_... definition (in Captures.py) for more details.
...
...             *Mecanism:*
...
...             This module propose mainly 4 KWs to manage captures, and they must be used in this order :
...             | Capture xxxx set upon config | To get an instance of pertinent capture. XXXX is for CORE, CPRT or L1L2 |
...             | Capture Init                 | To finalize naming of capture and install mirroring if required         |
...             | Capture Start                | To launch tcpdump command on TL on pertinent interface                  |
...             | Capture Stop                 | To stop tcpdump command and transfer pcap file on VM                    |
...             Naming convention for capture file are as follows :
...             - upon context (FS/L1ByPass, interface kind, ...), Capture XXXX Set Upon Config will select pertinent instance of capture
...             - This capture has a prefix that will start the name of capture file
...             - Invoking Capture Init KW will allow to add a suffix and optionally the name of the test
...             - At Capture Stop invocation, the final pcap file will be downloaded on VM in $[LOG_PATH} path
...             - then, <capture>.path variable will contain the full path on pcap file
...
...             *Example:*
...
...             | # We want to capture BIP messages, so invoking *Capture L1L2 Set upon Config* service
...             | ${capture} \ \ \ \ \ \ \ \ Capture L1L2 Set Upon Config
...             | # We are in Full Stack, capture.prefix = BIP_GNB_ABIL_M
...             | Capture Init \ \ \ \ \ \ ${capture} \ \ \ \ \ \ \ \ \ \ \ suffix=_GNB_ATTACH \ \ \ \ \ withTN=True
...             | # Capture.prefix is now    : BIP_GNB_ABIL_M_GNB_ATTACH
...             | # capture.name   is set to : BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>
...             | Capture Start \ \ \ \ \ ${capture}
...             | # A tcpdump is launched with option -w /tmp/BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>.pcap
...             | Capture Stop \ \ \ \ \ \ ${capture}
...             | # remote pcap file is transferred to : <LOG_PATH>/BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>.pcap
...
...             *Callbacks:*.
...
...             Also, some additional services are provided to manage Callback for BIP messages captures.\n
...             Main service is : Callback Capture L1L2, that is an example of single Capture callback
...             that can be provided to some high level services such as "SgNB Addition to ENB" (see in CallSetup.robot)
...             or Traffic KWs (see Traffic.robot).
...
...             Example:
...             | ${MyCaptureL1L2}        | Capture L1L2 Set Upon Config          |
...             | SgNB Addition to ENB    | captureCallback=Callback Capture L1L2 | capture=${MyCaptureL1L2} |
...             Then, during SGNB addition procedure, a L1L2 capture will be launched. At end of SGNB addition,
...             the corresponding pcap file will be retrieved in ${MyCaptureL1L2.path} variable
...

Resource                            Connect.robot
Resource                            Tools.robot
Resource                            Setup.robot
Resource                            CaptureFilter.robot
Library                             ../../../resources/NPS/SWENG/python/StringTool.py
Variables                           ../../../resources/NPS/SWENG/python/ReadConfig.py
Library                             ../../../resources/NPS/SWENG/python/Container.py
Variables                           ../../../resources/NPS/SWENG/python//Captures.py

*** Variables ***
*** Keywords ***
#===================================
# Configuration
#===================================
Capture L1L2 Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get L1L2 messages
    ...                             It take into account kind of Airscale, fact we are in FS or L1ByPass
    [Arguments]                     ${airscale}=${GNB_DU}
    ${capture}                      copyCaptureL1L2                         entity=${airscale}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for F1X2
#-----------------------------------
Capture CORE Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get CORE messages
    ...                             It take into account kind of Airscale
    [Arguments]                     ${airscale}=${GNB_DU}
    ${capture}                      copyCaptureCORE                         entity=${airscale}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for CPRT
#-----------------------------------
Capture CPRT Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get CPRT messages
    ...                             It take into account kind of Airscale
    [Arguments]                     ${airscale}=${GNB_DU}
    ...                             ${sysIndex}=0
    ${capture}                      copyCaptureCPRT                         entity=${airscale}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES Specific
#-----------------------------------
Capture on BOO L2LO L2HI
    [Documentation]                 INTERNAL USAGE
    ...                             Only 2255
    ${capture}                      copyInstance                            ${CAPTURE_L1L2_GNB_L1B_BOO_L2LO_L2HI}
    [Return]                        ${capture}

#===================================
# INIT
#===================================
Capture Init
    [Documentation]                 Entry point for capture init : put in place expected mirroring if required
    ...                             input argument is a <capture>.
    ...                             A suffix may be added to prefix capture
    ...                             Also, if <withTN> is set to True, Test Name will be part of the pcap file
    ...                             Final name of pcap will be : <prefix>[<suffix>][<TestName>]
    [Arguments]                     ${capture}
    ...                             ${withTN}=False
    ...                             ${suffix}=${EMPTY}
    ${capture.prefix}               set Variable                            ${capture.prefix}${suffix}
    ${capture.withTN}               set Variable                            ${withTN}
    Run Keyword if                  ${capture.isMirror}
    ...                             Mirror Script Install                   ${capture.scriptDef}

Mirror Script Install
    [Documentation]                 Install mirroring script on target
    ...                             1) Extract list of scripts in <scriptDef.names> and download them on host
    ...                             2) Execute dedicated command on host
    [Arguments]                     ${scriptDef}
    # Split list of script file names into a table, and parse table to download each file
    Dated log                       Download scripts for mirroring:${scriptDef.names}
    ${alias}                        SSH Wait For Connect                    ${scriptDef.host}
    FOR    ${script}        IN      @{scriptDef.names}
        SSH Upload Script           alias=${alias}                          scriptFile=${script}
        ...                         remotePath=${scriptDef.remotePath}
    END
    # Hard coded for the moment ...
    Run Keyword if                 '${GNB_DU.sys[0].M.boardType}'=='ASOE'
    ...                            Mirror Script Launch AP         ${scriptDef}                            ${alias}
    ...  ELSE                      Mirror Script Launch GNB        ${scriptDef}                            ${alias}
    # For LO_AP_KL_SANSA_L1B the nac_eth2 needs time to get up aand also BOO - so this sleep is generic now
    Traced Sleep                    duration=30s                msg=Waiting Eth to be up


Mirror Script Launch GNB
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${scriptDef}                            ${alias}
    ${mirrorslot}                   Set Variable If                         '${GNB_DU.domainId}'=='1'
    ...                             1                                       5
    Dated log                       Execute script:[${scriptDef.cmd} ${GNB_DU.bb[0].M.boardType} ${mirrorslot}]
    ${mirror_cmd}                   Run Keyword If    ${scriptDef.commonMirrorScript}
    ...                                 Catenate
    ...                                     nohup ${scriptDef.cmd}
    ...                                     --bb_slot_${mirrorslot}='true'
    ...                                     &
    ...                             ELSE
    ...                                 Set Variable    ${scriptDef.cmd}
    Dated log                       Mirror CMD=[${mirror_cmd}]
    ${output}                       SSH Cmd
    ...                             command=${mirror_cmd}
    ...                             readOuput=${False}
    ...                             alias=${alias}

    # Storing result of mirroring in a file in logs
    # ${nohupFile}                    Set variable                            ${LOG_PATH}/MIRRORING.${scriptDef.names[0]}.nohup
    # Create File                     ${nohupFile}
    # Append To File                  ${nohupFile}                            ${output}
    # Dated log                       Mirror traces generated in : ${nohupFile}

    # Sleep in case of common script
    Run Keyword If                  '${scriptDef.commonMirrorScript}' == 'True'
    ...                             sleep    10s

Mirror Script Launch AP
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${scriptDef}                            ${alias}
    Dated log                       Execute script:[${scriptDef.cmd}
    ${output}                       SSH Cmd                                 command=${scriptDef.cmd}
    ...                             alias=${alias}

#===================================
# Capture Start/Stop
#===================================
Capture Start
    [Documentation]                 Start a capture.
    ...                             1) full name of capture is computed, upon <withTN> flag
    ...                             2) previous capture is removed if existing
    ...                             3) new capture is launched on host/interface defined in <capture> fields
    ...                             4) if required (<check> flag), check process is running
    [Arguments]                     ${capture}                              # Reference to capture to be launched
    ...                             ${check}=True                           # Should we check tcpdump is running once launched ?
    # Set capture name : either prefix or prefix.<test_name>
    ${TestName}                     getFormattedName
    ${capture.name}                 Set variable                            ${capture.prefix}
    ${capture.name}                 Set variable if                         ${capture.withTN}
    ...                             ${capture.name}.${TestName}             ${capture.name}
    # Set Capture Root Path upon host : if host has OAM as proxy, we should use  ${CAPTURE_ROOT_PATH_LOCAL}
    run keyword if                  ${capture.isNode}
    ...                             Capture Prepare from Node               ${capture}
    ...   ELSE                      Capture Root Path Set                   ${capture}
    Dated Log                       CaptureRootPath=(${capture.CaptureRootPath}) CaptureRootPathCmd=(${capture.CaptureRootPathCmd})
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
    ...                             lxc-attach -n ${capture.node.nodeId} -- ${cmd}
    ...                             ${cmd}
    Dated Log                       Start tcpdump on ${alias} (${cmd})
    csn.send_command                ${cmd}                                  connection=${alias}
    # Check corresponding process was properly launched
    run keyword if                  '${check}'=='True'
    ...                             Check Tcpdump Is Running                ${tcpdumpCmd_path}
    ...                             alias=${alias}                          isRunning=True

Capture Prepare from Node
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}
    ${capture.node}                 getNodeFromCaptureNode                  captureNode=${capture.node}
    ${capture.host}                 set variable                            ${capture.node.host}
    ${capture.CaptureRootPathCmd}   set variable                            ${CAPTURE_ROOT_PATH_LOCAL}
    ${capture.CaptureRootPath}      set variable
    ...                             ${CAPTURE_ROOT_PATH_LOCAL}/node_${capture.node.id}/${capture.CaptureRootPathCmd}

Capture Root Path Set
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}
    ${capture.CaptureRootPath}      set variable                            ${CAPTURE_ROOT_PATH_LOCAL}
    ${capture.CaptureRootPathCmd}   set variable                            ${capture.CaptureRootPath}

Capture Stop
    [Documentation]                 Stop a capture previously launched
    ...                             1) retrieve pid of capture and kill it
    ...                             2) check capture is no more running
    ...                             3) download pcap in logs on VM
    [Arguments]                     ${capture}
    # Retrieve pid of corresponding capture and kill it
    ${tcpdumpCmd_path}              Set Variable                            ${capture.CaptureRootPathCmd}/${capture.name}.pcap
    ${sudoPrefix}                   Sudo Prefix                             ${capture.host}
    ${cmd}                          set variable
    ...            ${sudoPrefix}kill `ps -ef | grep tcpdump | grep ${tcpdumpCmd_path} | grep "${sudoPrefix}" | grep -v grep | awk '{print $2}'`
    Dated Log                       Stop Tcpdump on ${capture.host.alias} (${tcpdumpCmd_path}) prefix=(${sudoPrefix}) CMD=(${cmd})
    SSH Cmd                         ${cmd}
    ...                             alias=${capture.host.alias}
    # Check no more identical capture is running
    Check Tcpdump Is Running        ${tcpdumpCmd_path}                      alias=${capture.host.alias}
    ...                             isRunning=False
    # Set capture path on VM
    ${capture.path}                 Set variable                            ${LOG_PATH}/${capture.name}.pcap
    # Update path on remote to pcap file
    ${tcpdump_path}                 Set Variable                            ${capture.CaptureRootPath}/${capture.name}.pcap
    # Download from master to VM
    csn.download_file               remote_path=${tcpdump_path}
    ...                             local_path=${capture.path}
    ...                             connection=${capture.host.alias}        # instead AliasProxy
    [Return]                        ${capture.path}

Check Tcpdump Is Running
    [Documentation]                 INTERNAL USAGE
    ...                             Basic service to check a capture is running, based on its path for pcap
    [Arguments]                     ${path}                                 # path of capture file to search
    ...                             ${alias}                                # alias of host on which search
    ...                             ${isRunning}=True                       # check to be done
    Sleep                           1                                       # To ensure process is properly down
    ${output}                       SSH Cmd
    ...                             ps -ef | grep tcpdump | grep ${path} | grep -v grep
    ...                             alias=${alias}
    run keyword if                  '${isRunning}'=='False'                 should be empty         ${output}
    run keyword if                  '${isRunning}'=='True'                  should not be empty     ${output}


#===================================
# Callback services
#===================================
Callback Capture L1L2
    [Documentation]                 Example of call back for a single capture start/stop.
    ...                             When invoked START action, it will start the correponding capture.
    ...                             When invoked STOP action, it will stop the correponding capture.
    [Arguments]                     ${capture}=None                         # Reference of the capture dictionary
    ...                             ${Action}=START                         # Action to perform : START or STOP
    run keyword if                  '${Action}'=='STOP'                     Capture Stop    ${capture}
    run keyword if                  '${Action}'=='START'                    Capture Start   ${capture}

Callback Several Capture L1L2
    [Documentation]                 Example of call back for to manage start/stop for several capture
    ...                             In this case, <capture> should be a list of capture
    [Arguments]                     ${capture}=None                         # Reference of the list of capture dictionary
    ...                             ${Action}=START                         # Action to perform : START or STOP
    FOR    ${c}        IN          @{capture}
        run keyword if              '${Action}'=='STOP'                     Capture Stop    ${c}
        run keyword if              '${Action}'=='START'                    Capture Start   ${c}
    END

Callback Run Capture
    [Documentation]                 To execute a capture by invoking a callback if provided
    [Arguments]                     ${callback}=None                        # Reference to Callback service (KW)
    ...                             ${capture}=None                         # Reference to capture structure
    ...                             ${duration}=60s                         # Delay of capture
    Callback Start Capture          callback=${callback}                    capture=${capture}
    Sleep                           ${duration}
    Callback Stop Capture           callback=${callback}                    capture=${capture}

Callback Start Capture
    [Documentation]                 To start a capture by invoking a callback if provided
    [Arguments]                     ${callback}=None                        # Reference to Callback service (KW)
    ...                             ${capture}=None                         # Reference to capture structure
    run keyword if                  '${callback}'!='None'
    ...                             ${callback}                             ${capture}      START

Callback Stop Capture
    [Documentation]                 To stop a capture by invoking a callback if provided
    [Arguments]                     ${callback}=None                        # Reference to Callback service (KW)
    ...                             ${capture}=None                         # Reference to capture structure
    run keyword if                  '${callback}'!='None'
    ...                             ${callback}                             ${capture}      STOP
