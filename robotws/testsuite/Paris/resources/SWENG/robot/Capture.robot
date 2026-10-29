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
Library                             taf.collectors.l1l2bip             WITH NAME   l1l2bip
Library                             taf.collectors.core                WITH NAME   corebip
Library                             ../python/StringTool.py
Variables                           ../python/ReadConfig.py
Library                             ../python/Container.py
Variables                           ../python/Captures.py

*** Variables ***
@{filter_protocol}            TCP

*** Keywords ***
#===================================
# Configuration
#===================================
Capture L1L2 Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get L1L2 messages
    ...                             It take into account kind of Airscale, fact we are in FS or L1ByPass
    ...                             if isMirror flag is activated, mirroring on loopback interface will be activated
    [Arguments]                     ${airscale}=${TGNB_DU[0]}               ${isMirror}=${False}
    ${capture}                      copyCaptureL1L2                         entity=${airscale}
    ...                             isMirror=${isMirror}
    ${gnbHw}                        set variable        ${GNB_DU.profil}
    # In case of ASIM use old method, in other cases use taf to launch mirroring
    ${capture.useTafMirror}         set variable if   '${gnbHw}' in ['MO', 'MN', 'ML', 'BOO'] or ${isAIC}
    ...                             ${False}    ${True}
    # To be deleted when ABIP can be captured on webui
    ${to_filter}                    set variable if   '${gnbHw}' in ['MO', 'MN', 'ML', 'BOO']
    ...                             ${True}    ${False}
    # To be deleted when all BOO migrated
    ${capture.useTafMirror}         set variable if   '${GNB_DU.profil}'=='BOO' and '${AP_DU.profil}'=='LOO'
    ...                             ${True}    ${capture.useTafMirror}
    ${capture.filter}               run keyword if   ${to_filter}==${True}
    ...                             Get Filter To Exclude protocols       capture=${capture}     protocolList=${filter_protocol}
    ...                             ELSE
    ...                             set variable    ${EMPTY}
    Set Suite Variable              ${tafMirror}    ${capture.useTafMirror}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for F1X2
#-----------------------------------
Capture CORE Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get CORE messages
    ...                             It take into account kind of Airscale
    [Arguments]                     ${airscale}=${TGNB_DU[0]}
    ${capture}                      copyCaptureCORE                         entity=${airscale}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for CPRT
#-----------------------------------
Capture CPRT Set Upon Config
    [Documentation]                 Return pertinent instance of capture upon context to get CPRT messages
    ...                             It take into account kind of Airscale
    [Arguments]                     ${airscale}=${TGNB_DU[0]}
    ${capture}                      copyCaptureCPRT                         entity=${airscale}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES Specific
#-----------------------------------
Capture on BOO L2LO L2HI
    [Arguments]                     ${entity}=${TGNB_DU[0]}
    [Documentation]                 INTERNAL USAGE
    ...                             Only 2255
    ${ori}                          captureGet                              L1L2_GNB${entity.index}_L1B_BOO_L2LO_L2HI
    ${capture}                      copyInstance                            ${ori}
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
    ...                             ${interface}=L1-L2
    ${capture.prefix}               set Variable                            ${capture.prefix}${suffix}
    ${capture.withTN}               set Variable                            ${withTN}
    ${isBipRunning}                 Get Variable Value               ${BipCollectorStarted}     ${False}
    Run Keyword if                  ${capture.isMirror} and not ${capture.useTafMirror}
    ...                             Mirror Script Install            ${capture.scriptDef}
    return from keyword if          ${isBipRunning}                  BIP is already running
    # To be deleted when all BOO migrated
    ${interface}                    set variable if   '${GNB_DU.profil}'=='BOO' and '${AP_DU.profil}'=='LOO'
    ...                             L2Hi-L2Lo
    ...                             L1-L2
    Run Keyword if                  ${capture.useTafMirror} and not ${isBipRunning}
    ...                             Mirror With Taf            interface=${interface}

    # init the "Capture Stop" script file
    ${script_name}                  Get Variable Value    ${AIC_CAPTURE_STOP_SCRIPT}

    Run Keyword If                  ${isAic} and '${script_name}' == 'None'     Run Keywords
    ...                             Set Suite Variable            ${AIC_CAPTURE_STOP_SCRIPT}    ${LOG_PATH}/CaptureStop.sh
    ...         AND                 Create File                   ${AIC_CAPTURE_STOP_SCRIPT}
    ...         AND                 Append To File                ${AIC_CAPTURE_STOP_SCRIPT}    \#!/bin/bash\n\n
    ...         AND                 Append To File                ${AIC_CAPTURE_STOP_SCRIPT}    source /home/ute/test_repo/bin/activate\n\n
    ...         AND                 Append To File                ${AIC_CAPTURE_STOP_SCRIPT}    echo Removing hal-cli and tcpdump processes ...\n\n
    ...         AND                 run                           chmod +x ${AIC_CAPTURE_STOP_SCRIPT}
    ...         AND                 Dated Log                     Capture Stop script = ${AIC_CAPTURE_STOP_SCRIPT}


Mirror With Taf
    [Documentation]                 Use taf lib to mirror instead of gnbmirroring script
    ...                             see doc: https://taf-collectors-l1l2bip.docs.taf.ute.nsn-rdnet.net/en/stable/interfaces/interface.html
    [Arguments]                     ${interface}=L1-L2    ${remove_zip_file}=${True}
    ...                             ${dest}=Local         ${timeout}=600
    Dated log                       Using Taf lib to mirror instead of gnbmirroring script
    ${webservice}                   Create Dictionary
    ...                                 host=192.168.255.129
    ...                                 user=Nemuadmin
    ...                                 password=nemuuser
    ...                                 port=443
    @{nr_phy_cell_ids}    Create List
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...                                 name=l1l2bip
    ...                                 webservice=${webservice}
    ...                                 nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                 interface=${interface}
    ...                                 destination=${dest}
    ...                                 remove_zip_file=${remove_zip_file}
    ...                                 timeout=${timeout}
    corebip.setup_collectors    names=l1l2bip
    corebip.set_suite_alias     l1l2bip
    Set Suite Variable          ${BipCollectorStarted}    ${True}


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
    ${alias}                        Set variable                            ${scriptDef.host.alias}
    Run Keyword if                  ${alias.startswith('AP_DU')}
    ...                             Mirror Script Launch                    ${scriptDef}                            ${alias}
    ...  ELSE                       Mirror Script Launch w BB Slot          ${scriptDef}                            ${alias}
    Traced Sleep                    duration=30s                msg=Waiting Eth to be up


Mirror Script Launch w BB Slot
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${scriptDef}                            ${alias}
    ${mirrorslot}                   Set Variable If                         '${GNB_DU.domainId}'=='1'
    ...                             1                                       5
    Dated log                       Execute script:[${scriptDef.cmd} ${scriptDef.host.alias} ${mirrorslot}]
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
    # Sleep in case of common script
    Run Keyword If                  '${scriptDef.commonMirrorScript}' == 'True'
    ...                             sleep    10s

Mirror Script Launch
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${scriptDef}                            ${alias}
    Dated log                       Execute script:[${scriptDef.cmd}]
    ${output}                       SSH Cmd                                 command=${scriptDef.cmd}
    ...                             alias=${alias}

#===================================
# Capture Start/Stop
#===================================

Add Capture Stop Cmd To File
    [Documentation]                 Add a command to the "Capture Stop" script file.
    [Arguments]                     ${capture}
    ${capture_stop_cmd}             Get Capture Stop Ssh Command            ${capture}
    Append To File                  ${AIC_CAPTURE_STOP_SCRIPT}              ${capture_stop_cmd}${\n}${\n}


Capture Start
    [Documentation]                 Start a capture.
    ...                             1) full name of capture is computed, upon <withTN> flag
    ...                             2) previous capture is removed if existing
    ...                             3) new capture is launched on host/interface defined in <capture> fields
    ...                             4) if required (<check> flag), check process is running
    [Arguments]                     ${capture}                              # Reference to capture to be launched
    ...                             ${check}=True                           # Should we check tcpdump is running once launched ?
    ...                             ${interface}=L1-L2
    ${isBipStarted}                 run keyword if        ${capture.useTafMirror}      Get Variable Value    ${BipCollectorStarted}     ${False}
    run keyword if                  ${capture.useTafMirror} and not ${isBipStarted}    Mirror With Taf    interface=${interface}
    call method                     ${capture}            start       		${check}
    run keyword if                  ${capture.useTafMirror}    corebip.start_collectors        names=l1l2bip
    # add the associated "Capture Stop" command to the script file
    ${capture_stop_cmd}             Run Keyword If                          ${isAic}
    ...                             Add Capture Stop Cmd To File            ${capture}
    ...                             ELSE
    ...                             Set Variable                            ${EMPTY}
    Dated Log                       Capture Start - capture_stop_cmd = ${capture_stop_cmd}


Filter Pcap File
    [Documentation]                 Create a new .pcap file by applying the provided filter to the provided .pcap file path
    ...                             The new file will erase the existing .pcap file
    ...                             Filter example : "eth[28:2]==34:25" or "not eth[28:2]==34:25" (without double quotes)
    [Arguments]                     ${path}
    ...                             ${filter}
    ${cmd}                          Set variable    tshark -r ${path} -Y "${filter}" -w ${path}.tmp ; mv ${path}.tmp ${path}
    Dated Log                       Filter Pcap File command = ${cmd}
    run                             ${cmd}


Capture Stop
    [Documentation]                 Stop a capture previously launched
    ...                             1) retrieve pid of capture and kill it
    ...                             2) check capture is no more running
    ...                             3) download pcap in logs on VM
    ...                             If "additionalFilter" is provided then a post processing is done to apply the filter  on
    ...                             the .pcap file obtained by the capture. The filtered data will be stored in the same .pcap file path
    [Arguments]                     ${capture}
    ...                             ${additionalFilter}=None
    ${capture.path}                 Set variable                            ${LOG_PATH}/${capture.name}.pcap
    IF              not ${capture.useTafMirror}
                                    call method          ${capture}            stop
    END
    ${isBipStarted}                 run keyword if        ${capture.useTafMirror}      Get Variable Value    ${BipCollectorStarted}     ${False}
    run keyword if                  ${capture.useTafMirror} and ${isBipStarted}    run keyword and ignore error
    ...                             run keywords
    ...                             corebip.stop_collectors        names=l1l2bip
    ...      AND                    corebip.collect_collectors     names=l1l2bip
    ...      AND                    corebip.teardown_collectors    names=l1l2bip
    ...      AND                    set suite variable             ${BipCollectorStarted}    ${False}
    run keyword if                  ${capture.useTafMirror}        Get Pcap Taf    dest=${capture.path}    filter=${capture.filter}
    # if additional filter is provided then filter the pcap using tshark and the provided filter
    Run Keyword If                  '${additionalFilter}' != 'None'
    ...                             Filter Pcap File    path=${capture.path}    filter=${additionalFilter}
    [Return]                        ${capture.path}


Get Capture Stop Ssh Command
    [Documentation]                 Get the command used for killing captures processes
    [Arguments]                     ${capture}
    ${cmd}                          call method    ${capture}    getSshDetailsAndCaptureStopCmd
    [Return]                        ${cmd}


Get Pcap Taf
    [Documentation]                 INTERNAL USAGE : Get the pcap created by taf lib when mirroring and capturing
    [Arguments]                     ${dest}    ${filter}=${EMPTY}
    ${taflogdir}                    set variable      ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/l1l2bip
    ${cmd}                          Set variable    ls -al ${taflogdir}
    ${RES}                          Run And Return RC      cd "${taflogdir}" && mergecap *.pcap -w "${dest}"
    Run Keyword If                  ${RES} == 0            Run Keywords
    ...                             Run             ${cmd}
    ...         AND                 Dated Log                       no_pcap_in=${taflogdir}
    Should Be True                  ${RES} == 0            msg=Failed to merge pcap files in ${taflogdir} to "${dest}"
    Run Keyword If                  "${filter}" != "${EMPTY}"
    ...                             Run And Return RC      tshark -r "${dest}" -w /tmp/tmpCap.pcap -Y '${filter}' && mv /tmp/tmpCap.pcap "${dest}"
    #${RES}                          Run And Return RC      rm -rf "${taflogdir}"
    #Should Be True                  ${RES} == 0            msg=Failed to remove taf dir
    ${RES}                          Run And Return RC      rm -rf "${OUTPUT_DIR}/${SUITE_NAME}"


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
