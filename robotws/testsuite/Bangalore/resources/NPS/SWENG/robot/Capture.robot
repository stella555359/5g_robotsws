*** Settings ***
Documentation                       Module to put in place and start/stop a capture
...                                 Main KW are :
...                                     - Capture Init          <capture>   [<suffix>]        [<withTN>]
...                                     - Capture Start         <capture>   [<check>]
...                                     - Capture Stop          <capture>
...                                 A capture is a data dictionary that embeds all information required
...                                 to put in place mirroring (if required) and to launch capture (interface, host,...)
...                                 To ease build of Capture structure some pre-prepared structure are provided(capture BIP, capture SCTP)
...                                 Some KW are proposed to get pertinent capture structure upon we are in L1ByPass or in Full Stack:
...                                     - Capture L1L2 Set Upon Config
...                                     - Capture CORE Set Upon Config
...
...                                 So, typical sequence is (let say for capture BIP):
...                                 ${capture}          Capture L1L2 Set Upon F1
...                                 Capture init        ${capture}          [<suffix>]        [<withTN>]
...                                 Capture Start       ${capture}
...                                 Capture Stop        ${capture}
...
...                                 Also, some additional services are provided to manage Callback for BIP messages captures
...                                 Main service is : Callback Capture L1L2, that is an example of Capture callback
...                                 That can be provided to some high level services such as "SgNB Addition to ENB" Keyword (see CallSetup.robot)
...
...                                 Captures files:
...                                 - When defining (or reusing) a capture, a prefix is set
...                                 - during init (Capture Init), a suffix and/or TestName can be added. This will be built in Capture.name
...                                 - at Capture Start, a tcpdump will be launched with option : -w /tmp/<Capture.name>.pcap
...                                 - at Capture Stop, this file is downloaded in local, under ${LOG_PATH}
...                                 Example :
...                                 ${capture}          Capture L1L2 Set Upon Config
...                                 # We are in Full Stack, capture.prefix = BIP_GNB_ABIL_M
...                                 Capture Init         ${capture}        suffix=_GNB_ATTACH           withTN=True
...                                 # capture.prefix is now    : BIP_GNB_ABIL_M_GNB_ATTACH
...                                 # capture.name   is set to : BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>
...                                 Capture Start        ${capture}
...                                 # A tcpdump is launched with option -w /tmp/BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>.pcap
...                                 Capture Stop         ${capture}
...                                 # remote pcap file is transferred to : <LOG_PATH>/BIP_GNB_ABIL_M_GNB_ATTACH.<TestName>.pcap

Resource                            Connect.robot
Resource                            Tools.robot
Resource                            Setup.robot
Resource                            CaptureFilter.robot
Library                             ../python/StringTool.py
Variables                           ../python/ReadConfig.py
Library                             ../python/Container.py

*** Variables ***
# SCRIPTDEF for mirroring            : Dictionaries, that should contain:
#   host     : reference to host on which script must be run
#   names    : list of files names of script to be downloaded
#   destPath : location on taget where to download them
#   cmd      : final cmd to launch

&{SCRIPTDEF_MIRROR_AP_FS}           host=${AIRSCALE_AP.sys[0].M}
...                                 names=apMirroring.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh apMirroring.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}  host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring.sh,gnbMirroringConfig.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=/ffs/run/config/scripts/gnbMirroring.sh
...                                 commonMirrorScript=True

&{SCRIPTDEF_MIRROR_GNB_FS_BO_2slot}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ABIO_2slot_right_BIP_FS.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ABIO_2slot_right_BIP_FS.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_FS_CPRT_BO_2slot}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ABIO_2slot_right_CPRT_FS.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ABIO_2slot_right_CPRT_FS.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_L1B_BO}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ASIB_ABIO_L1Bypass.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ASIB_ABIO_L1Bypass.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_GNB_L1B_BL}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring.sh
...                                 commonMirrorScript=True

&{SCRIPTDEF_MIRROR_GNB_L1B_LO}      host=${AIRSCALE_GNB.sys[0].M}
...                                 names=gnbMirroring_ASIL_ABIO_L1Bypass.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh gnbMirroring_ASIL_ABIO_L1Bypass.sh
...                                 commonMirrorScript=False

&{SCRIPTDEF_MIRROR_AP_ASOE}         host=${AIRSCALE_AP.sys[0].M}
...                                 names=apMirroringASOE.sh
...                                 remotePath=/ffs/run/config/scripts
...                                 cmd=cd /ffs/run/config/scripts;sh apMirroringASOE.sh
...                                 commonMirrorScript=False

# CAPTURE                         : Dictionaries, that should contain:
#   isMirror  : toogle indicating if a mirroring should be previously done via script
#   scriptDef : reference to sxript def  structure
#   host      : reference to host on which capture should be launched
#   interface : interface on which capture will be launched (tcpdump -i <interface>)
#   prefix    : first part of pcap file name
#   name      : full name (without extension) if pcap file name. (Set during Init)
#   path      : full path of pcap once captured and uploaded on test VM. It is set at capture stop
#   withTN    : Indicate if test name should be embeded in pcap file name
#   filter    : filter for tcpdump
#
# Capture launched on CPIF during SgNB Addition PRACH : Kept for old Cloud code compatibility
&{CAPTURE_SCTP_CLOUD}               host=${HOST_GNB_CPIF}                   isNode=${False}
...                                 interface=any sctp
...                                 isMirror=False                          scriptDef=
...                                 prefix=SCTP_CLOUD                       name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

#==========================================================================================
# CAPTURE STRUCTURES
#==========================================================================================
#-----------------------------------
# CAPTURE for CORE
#-----------------------------------
# Add of interface FP0 to support ASIK
&{CAPTURE_CORE_GNB_SYS0_FP0}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=fp0
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_FP0              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
# Add of interface eth1 on WTS to support Cloud configuration
&{CAPTURE_CORE_WTS_ETH3}            host=${HOST_EPCSIM}                     isNode=${False}
...                                 interface=eth3
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_WTS_ETH3                    name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
# Add of interface BR1 to support ASIB
&{CAPTURE_CORE_GNB_SYS0_BR1}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=br1
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_BR1              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

# Add of interface BR0 to support ASIL
&{CAPTURE_CORE_GNB_SYS0_BR0}        host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=br0
...                                 isMirror=False                          scriptDef=
...                                 prefix=CORE_GNB_SYS0_M_BR0              name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

#-----------------------------------
# CAPTURE for CPRT
#-----------------------------------
&{CAPTURE_CPRT_AP_SYS0_ETHA01}      host=${AIRSCALE_AP.sys[0].S}            isNode=${False}
...                                 interface=etha01
...                                 isMirror=False                          scriptDef=
...                                 prefix=CPRT_AP_SYS0_S_ETHA01            name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
&{CAPTURE_CPRT_NODE}                host=None                               isNode=${True}
...                                 interface=any                           node=CPRT
...                                 isMirror=False                          scriptDef=
...                                 prefix=NODECPRT_GNB                     name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

#-----------------------------------
# CAPTURE for BIP
#-----------------------------------
&{CAPTURE_L1L2_GNB_FS_ASIK_ABIL}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=pepbp1
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
...                                 prefix=L1L2_GNB_FS_KL                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
&{CAPTURE_L1L2_GNB_FS_ASIB_ABIL}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=eths2
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
...                                 prefix=L1L2_GNB_FS_BL                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
&{CAPTURE_L1L2_GNB_FS_ASIL_ABIO}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=nac_eth2
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
...                                 prefix=L1L2_GNB_FS_LO                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
&{CAPTURE_L1L2_GNB_FS_ASIM_ABIP}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=etha01
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
...                                 prefix=L1L2_GNB_FS_LO                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
# FDD only
&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=eths3
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_DEFAULT}
...                                 prefix=L1L2_GNB_FS_BO                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_BIP}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=eths3
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_BO_2slot}
...                                 prefix=L1L2_GNB_FS_BO_2slots_BIP                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

&{CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_CPRT}    host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=eths3
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_FS_CPRT_BO_2slot}
...                                 prefix=L1L2_GNB_FS_BO_2slots_CPRT                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

# TDD in l1 bypass due to restrictions
&{CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIO}
...                                 host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=eths2
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_BO}
...                                 prefix=L1L2_GNB_L1B_BO                  name=
...                                 path=                                   withTN=False
...                                 filter=\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}<0xf000\'
&{CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIL}
...                                 host=${AIRSCALE_GNB.sys[0].S}           isNode=${False}
...                                 interface=etha01
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_BL}
...                                 prefix=L1L2_GNB_L1B_BL                  name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
&{CAPTURE_L1L2_GNB_L1BYPASS_ASIL_ABIO}
...                                 host=${AIRSCALE_GNB.sys[0].M}           isNode=${False}
...                                 interface=nac_eth2
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_GNB_L1B_LO}
...                                 prefix=L1L2_GNB_L1B_LO                  name=
...                                 path=                                   withTN=False
...                                 filter=\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}<0xf000\'

&{CAPTURE_L1L2_L1BYPASS_AP}         host=${AIRSCALE_AP.sys[0].S}            isNode=${False}
...                                 interface=etha01
...                                 isMirror=False                          scriptDef=
...                                 prefix=L1L2_AP_L1B_LO                   name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

# CAPTURE_L1L2_FS_AP_IPV6 => CAPTURE_L1L2_FS_AP since no more triggering upon IP kind (all are IPv6)
&{CAPTURE_L1L2_FS_AP}               host=${AIRSCALE_AP.bb[0].S}             isNode=${False}
...                                 interface=ethbp1
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_AP_FS}
...                                 prefix=L1L2_FS_AP                       name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

&{CAPTURE_L1L2_AP_ASOE}             host=${AIRSCALE_AP.sys[0].S}             isNode=${False}
...                                 interface=etha01
...                                 isMirror=True                           scriptDef=${SCRIPTDEF_MIRROR_AP_ASOE}
...                                 prefix=L1L2_AP_ASOE                       name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}
*** Keywords ***
#===================================
# Configuration
#===================================
Capture L1L2 Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ${capture}                      Run Keyword if                          '${airscale.name}'=='${AIRSCALE_GNB.name}'
    ...                             Capture L1L2 GNB Set Upon Config        ${airscale}
    ...   ELSE                      Capture L1L2 AP Set Upon Config         ${airscale}
    [Return]                        ${capture}

Capture L1L2 GNB Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ${capture}                      Run Keyword if                          '${airscale.sys[0].M.boardType}'=='ASOE'
    ...                             Capture L1L2 AP Set Upon Config ASOE
    ...     ELSE IF                 ${TLConfig.isL1BP}==${True}
    ...                             Capture L1L2 GNB Set Upon Board L1B     ${airscale}
    ...     ELSE                    Capture L1L2 GNB Set Upon Board FS      ${airscale}
    [Return]                        ${capture}


Capture L1L2 GNB Set Upon Board L1B
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ${capture}                      Run Keyword if
    ...                             '${airscale.sys[0].M.boardType}'=='ASIB' and '${airscale.bb[0].M.boardType}'=='ABIO'
    ...                             Dictionary Get                         ${CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIO}
    ...     ELSE IF                 '${airscale.sys[0].M.boardType}'=='ASIL' and '${airscale.bb[0].M.boardType}'=='ABIO'
    ...                             Dictionary Get                         ${CAPTURE_L1L2_GNB_L1BYPASS_ASIL_ABIO}
    ...     ELSE                    Dictionary Get                         ${CAPTURE_L1L2_GNB_L1BYPASS_ASIB_ABIL}
    [Return]                        ${capture}

Capture L1L2 GNB Set Upon Board FS
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ${capture}                      Run Keyword if
    ...                             '${airscale.sys[0].M.boardType}'=='ASIL' and ('${airscale.bb[0].M.boardType}'=='ABIO' or 'ABIN')
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIL_ABIO}
    ...                             ELSE IF                                '${airscale.bb[0].M.boardType}'=='ABIO'
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIO}
    ...                             ELSE IF                                '${airscale.bb[0].M.boardType}'=='ABIN'
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIO}
    ...                             ELSE IF                                 '${airscale.sys[0].M.boardType}'=='ASIB'
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIL}
    ...                             ELSE IF
    ...                             '${airscale.sys[0].M.boardType}'=='ASIM' and ('${airscale.bb[0].M.boardType}'=='ABIP')
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIM_ABIP}
    ...     ELSE                    Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIK_ABIL}
    [Return]                        ${capture}

Capture L1L2 AP Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_AP}
    log to console                  ${airscale}
    ${capture}                      Run Keyword if                          ${TLConfig.isL1BP}==${True}
    ...                             Dictionary Get                          ${CAPTURE_L1L2_L1BYPASS_AP}
    ...     ELSE                    Dictionary Get                          ${CAPTURE_L1L2_FS_AP}
    [Return]                        ${capture}

Capture on ABIO 2 slots
    [Arguments]                     ${captureType}=BIP
    ${capture}                      Run Keyword if
    ...                             '${captureType}'=='BIP'
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_BIP}
    ...                             ELSE IF                                 '${captureType}'=='CPRT'
    ...                             Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIO_2slot_CPRT}
    ...     ELSE                    Dictionary Get                          ${CAPTURE_L1L2_GNB_FS_ASIB_ABIO}
    [Return]                        ${capture}

Capture L1L2 AP Set Upon Config ASOE
    ${capture}                      Dictionary Get                          ${CAPTURE_L1L2_AP_ASOE}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for F1X2
#-----------------------------------
Capture CORE Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ...                             ${sysIndex}=0
    ${capture}                      Run Keyword if                          '${airscale.hw}'=='GNB'
    ...                             Capture CORE GNB Set Upon Config        sysIndex=${sysIndex}
    ...     ELSE                    Fail                                    No capture provided for AP for the moment
    #...     ELSE                    Dictionary Get                          ${CAPTURE_CORE_AP_SYS0_FP0}
    [Return]                        ${capture}

Capture CORE GNB Set Upon Config
    [Arguments]                     ${sysIndex}=0
    ${capture}                      Run Keyword If                          ${TLConfig.isGnbCloud}
    ...                             Dictionary Get                          ${CAPTURE_CORE_WTS_ETH3}
    ...   ELSE                      Capture CORE GNB Classical Set Upon Config
    ...                                 sysIndex=${sysIndex}
    [Return]                        ${capture}

Capture CORE GNB Classical Set Upon Config
    [Documentation]                 ASIK : fp0, ASIB : br1, ASIL : br0
    [Arguments]                     ${sysIndex}=0
    log to console                  ${sysIndex}
    ${capture}                      Run Keyword if                          '${AIRSCALE_GNB.sys[0].M.boardType}'=='ASIB'
    ...                             Dictionary Get                          ${CAPTURE_CORE_GNB_SYS0_BR1}
    ...    ELSE IF                  '${AIRSCALE_GNB.sys[0].M.boardType}'=='ASIL' or '${AIRSCALE_GNB.sys[0].M.boardType}'=='ASOE'
    ...                             Dictionary Get                          ${CAPTURE_CORE_GNB_SYS0_BR0}
    ...    ELSE                     Dictionary Get                          ${CAPTURE_CORE_GNB_SYS0_FP0}
    [Return]                        ${capture}

#-----------------------------------
# CAPTURES for CPRT
#-----------------------------------
Capture CPRT Set Upon Config
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ...                             ${sysIndex}=0
    log to console                  ${sysIndex}
    ${capture}                      Run Keyword if                          '${airscale.hw}'=='GNB'
    ...                             Dictionary Get                          ${CAPTURE_CPRT_NODE}
    ...     ELSE                    Dictionary Get                          ${CAPTURE_CPRT_AP_SYS0_ETHA01}
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
    @{scriptList}                   Split String                            ${scriptDef.names}      separator=,
    ${alias}                        SSH Wait For Connect                    ${scriptDef.host}
    FOR    ${script}        IN     @{scriptList}
        SSH Upload Script           alias=${alias}                          scriptFile=${script}
        ...                         remotePath=${scriptDef.remotePath}
    END
    # Hard coded for the moment ...
    Run Keyword if                 '${GNB_DU.sys[0].M.boardType}'=='ASOE'
    ...                            Mirror Script Launch AP         ${scriptDef}                            ${alias}
    ...  ELSE                      Mirror Script Launch GNB        ${scriptDef}                            ${alias}
    # Mirror Script Launch AP         ${scriptDef}                            ${alias}

Capture Set Mirror
    [Documentation]                 Apply a mirroring setting
    [Arguments]                     ${mirror}
    # Apply mirroring for sport1, and sport2 if required
    Dbgrrc Mirror                   ${mirror.sport1}                        ${mirror.dport}         ${mirror.host}
    Dbgrrc Mirror                   ${mirror.sport2}                        ${mirror.dport}         ${mirror.host}

Dbgrrc Mirror
    [Documentation]                 Basic service to mirror a source port onto a destination port
    [Arguments]                     ${sport}                                ${dport}
    ...                             ${host}
    Run Keyword if                  ${sport}>0                              Run Keywords
    ...                             Dated log                               Set mirror on ${host.alias} : mirror sport ${sport} on ${dport}
    ...                             AND
    ...                             SSH Wait For Connect and Cmd            dbgrrc mirror sport ${sport} dport ${dport} enable both
    ...                             host=${host}

Mirror Script Launch GNB
    [Arguments]                     ${scriptDef}                            ${alias}
    ${dom_ID}                       Get Domain Id                           ${AIRSCALE_GNB.sys[0].M}
    ${mirrorslot}                   Set Variable If                         '${dom_ID}'=='1'
    ...                             1                                       5
    Dated log                       Execute script:[${scriptDef.cmd} ${AIRSCALE_GNB.bb[0].M.boardType} ${mirrorslot}]

    ${mirror_cmd}                   Run Keyword If    '${scriptDef.commonMirrorScript}' == 'True'
    ...                                 Catenate
    ...                                     nohup ${scriptDef.cmd}
    ...                                     --bb_board_type=${AIRSCALE_GNB.bb[0].M.boardType}
    ...                                     --bb_slot_${mirrorslot}='true'
    ...                                     &
    ...                             ELSE
    ...                                 Set Variable    ${scriptDef.cmd}

    ${read_output}                  Run Keyword If    '${scriptDef.commonMirrorScript}' == 'True'
    ...                                 Set Variable    False
    ...                             ELSE
    ...                                 Set Variable    True

    ${output}                       SSH Cmd
    ...                             command=${mirror_cmd}
    ...                             readOuput=${read_output}
    ...                             alias=${alias}

    # Check no error was detected : inhibited for the moment, since some "failure" still exist in V17 script version
    # should not contain              ${output}                               failure

    Run Keyword If                  '${scriptDef.commonMirrorScript}' == 'True'
    ...                             sleep    10s

Mirror Script Launch AP
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
    [Arguments]                     ${capture}
    ${capture.node}                 getNodeFromCaptureNode
    ...                             listNode=${LIST_NODE}
    ...                             captureNode=${capture.node}
    ${capture.host}                 set variable                            ${capture.node.host}
    ${capture.CaptureRootPathCmd}   set variable                            ${CAPTURE_ROOT_PATH_LOCAL}
    ${capture.CaptureRootPath}      set variable
    ...                             ${CAPTURE_ROOT_PATH_LOCAL}/node_${capture.node.id}/${capture.CaptureRootPathCmd}

Capture Root Path Set
    [Documentation]                 Set path in which capture should be done
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
    [Documentation]                 Basic service to check a capture is running, based on its path for pcap
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
    [Documentation]                 Example of call back for capture start/stop
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

Modify BIP Script File
    [Arguments]     ${BIP_SCRIPT_PATH}
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='5'    Capture.Modify BB Slot      ${BIP_SCRIPT_PATH}

Modify BB Slot
    [Arguments]     ${BIP_SCRIPT_PATH}
    Capture.Modify File Parameter    ${BIP_SCRIPT_PATH}/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Capture.Modify File Parameter    ${BIP_SCRIPT_PATH}/gnbMirroringConfig.sh    BB_SLOT_5='false'    BB_SLOT_5='true'

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}
