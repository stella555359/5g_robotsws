*** Settings ***
Library                             taf.transport.ssh                 WITH NAME    csn
Variables                           ../python/ReadConfig.py
Resource                            Connect.robot
Library                             ../python/Container.py

*** Variables ***
# List of nodes, those that will be dynamically dicovered
@{LIST_NODE}
# List of Associated logs
@{LIST_LOG}
# List of capture assocaited to each node
@{LIST_CAPTURE_NODE}
# Minimal List of nodes (only names) expected on a TL
@{LIST_NODE_NAME}                   CPCL    CPNB    UPUE    CPIF    CPRT    CPUE    CPNRT   L2RT    # L2PS
# TODO   =>  adapt prefix and postfix for CLOUD
# based on        ${TLConfig.isGnbCloud}
# can we reuse:  OAM Get GNB BTS Info  from oam.robot?

# List of LOG files with reference to node (placeholders in log postfix is replaced in Container.py LogsUpdateFromNode() )
&{LOG_CPRT_DEF}                     name=CPRT_DEF       prefix=/tmp         postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
&{LOG_CPRT}                         name=CPRT           prefix=/tmp         postfix=/tmp/startup_cp_rt.log      isNodeUsed=${True}
&{LOG_CPUE_DEF}                     name=CPUE_DEF       prefix=/tmp         postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
&{LOG_CPUE}                         name=CPUE           prefix=/tmp         postfix=/tmp/startup_cp_ue.log      isNodeUsed=${True}
&{LOG_CPCL_DEF}                     name=CPCL_DEF       prefix=/tmp         postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
&{LOG_CPCL}                         name=CPCL           prefix=/tmp         postfix=/tmp/startup_cp_cl.log      isNodeUsed=${True}
&{LOG_CPIF_DEF}                     name=CPIF_DEF       prefix=/tmp         postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
&{LOG_CPIF}                         name=CPIF           prefix=/tmp         postfix=/tmp/startup_cp_if.log      isNodeUsed=${True}
&{LOG_CPNB_DEF}                     name=CPNB_DEF       prefix=/tmp         postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
&{LOG_CPNB}                         name=CPNB           prefix=/tmp         postfix=/tmp/startup_cp_nb.log      isNodeUsed=${True}
&{LOG_UPUE_DEF}                     name=UPUE_DEF       prefix=/tmp         postfix=/tmp/FCTL-E00A_startup.log  isNodeUsed=${True}
&{LOG_L2RT}                         name=L2RT           prefix=/tmp         postfix=/tmp/ASP-<NodeId>_startup.log   isNodeUsed=${True}
#&{LOG_L2RT}                         name=L2RT           prefix=/tmp         postfix=/tmp/ASP-<domainid>740_startup.log   isNodeUsed=${True}

# Default structure for a capture on a node.
# Host is set to None, isNode is true and node will be updated (after node discovery) consequently
&{CAPTURE_NODE}                     host=None                               isNode=${True}
...                                 interface=any                           node=None
...                                 isMirror=False                          mirror=
...                                 prefix=${EMPTY}                         name=
...                                 path=                                   withTN=False
...                                 filter=${EMPTY}

*** Keywords ***
WA Update Nodes and Logs Def
    wait until keyword succeeds     10min    10s
    ...                             Update Nodes and Logs Def

Update Nodes and Logs Def
    [Documentation]                 Update nodes and logs structure upon dynamic discovery
    ...                             After dynamic discovery of nodes, we resolve those nodes
    ...                             that have no link, but only a directory
    # Dynamic discovery of Nodes
    Nodes Discovery
    # Nodes Resolve Hard Coded
    Nodes Add Capture
    Nodes Display                   ${LIST_NODE}
    Nodes Check Found

    # Build Log definition
    Run keyword if                  ${TLConfig.isGnbCloud}
    ...                             Set Logs Variables for CLOUD
    Logs Build
    Logs UpdateFromNode             listLog=${LIST_LOG}
    ...                             listNode=${LIST_NODE}
    Logs Display Def                listLog=${LIST_LOG}

Nodes Resolve Hard Coded
    [Documentation]                 Nodes that are named "0x..." are conventional directories
    ...                             But not link.
    ...                             Here is a hard coded behavior : only L2PS is in this case
    ...                             so, in this case we rename node into L2PS
    FOR    ${node}     IN          @{LIST_NODE}
            ${node.name}            set variable if                         ${node.name.startswith('0x')}
            ...                     L2PS                                    ${node.name}

    END

Nodes Discovery
    [Documentation]                 Full dynamic disovery of nodes in IPv6. We parse all hosts of the airscale
    ...                             to retrieve all nodes (as node_0x... in /tmp) and buid consequently list of nodes
    @{LIST_NODE}                    Create List
    Set suite Variable              ${LIST_NODE}
    Nodes Discovery From Host       ${AIRSCALE_GNB.sys[0].M}
    Nodes Discovery From Host       ${AIRSCALE_GNB.sys[0].S}
    # no BB in ASOE test line
    # Dated Log                       AIRSCALE_GNB.sys[0].M.boardType=${AIRSCALE_GNB.sys[0].M.boardType}
    Run Keyword if                  '${AIRSCALE_GNB.sys[0].M.boardType}'!='ASOE'
    ...                             BB Nodes Discovery
    Run keyword if                  ${TLConfig.isGnbCloud}==${True}          Nodes Discovery From Controller
    ...                             ${HOST_GNB_OAM_CU}

BB Nodes Discovery
    Nodes Discovery From Host       ${AIRSCALE_GNB.bb[0].M}
    Nodes Discovery From Host       ${AIRSCALE_GNB.bb[0].S}
    Run Keyword If    '${airscale_GNB.bb[0].M.boardType}'!='ABIN'    Nodes Discovery From Host       ${AIRSCALE_GNB.bb[0].L1}

Nodes Discovery From Host
    [Documentation]                 Retrieve all nodes as defined as node_0x... in /tmp
    ...                             We add only non-existing nodes in final list ${LIST_NODE}
    [Arguments]                     ${host}
    ${alias}                        SSH Connect                     ${host}
    ${output}                       SSH Cmd                         cd /tmp;ls -lrt | grep node_0x
    ...                             alias=${alias}
    @{listNodeHost}                 getListNodeFromHost             str=${output}   host=${host}
    ${L2RTFound}                    Set variable                    ${False}
    FOR    ${node}     IN          @{listNodeHost}
            ${LOG_L2RT.isNodeUsed}  set variable if                 ${node.name.startswith('0x')}
            ...                     ${False}                        ${True}
            ${node.name}            set variable if                 ${node.name.startswith('0x')}
            ...                     L2RT                            ${node.name}
            ${nodeExist}            Get Node                        ${node.name}
            run keyword if          '${nodeExist}'=='None'
            ...                     append to list                  ${LIST_NODE}        ${node}
            ${L2RTFound}            Set Variable if                 '${node.name}'=='L2RT'
            ...                     ${True}                         ${L2RTFound}
    END

Nodes Discovery From Controller
    [Documentation]                 Retrieve all nodes from OAM controller
    [Arguments]                     ${host}
    ${alias}                        SSH Connect directly            ${host}
    ${output}                       SSH Cmd                         arp -a | grep ".local"
    ...                             timeout=120                     alias=${alias}
    Dated Log                       arp result: ${output}
    @{listNodeHost}                 getListNodeCloud                str=${output}   host=${host}
    FOR    ${node}     IN          @{listNodeHost}
            ${nodeExist}            Get Node                        ${node.name}
            run keyword if          '${nodeExist}'=='None'
            ...                     append to list                  ${LIST_NODE}        ${node}
    END
    Dated Log                       Controller node list built: ${listNodeHost}

Nodes Check Found
    [Documentation]                 Check all expected nodes are present
    FOR    ${nodeName}     IN      @{LIST_NODE_NAME}
            ${node}                 Get Node                        ${nodeName}
            Run keyword if          '${node}'=='None'    #and '${nodeName}'!='L2PS'
            ...                     Run keyword if                  ${TLConfig.isGnbCloud}==${False}
            ...                     Run Keywords
            ...                         Dated Log                   ERROR: Node ${nodeName} not found during dynamic discovery
            ...    AND                  Fail                        ERROR: Unable to find node : ${nodeName}
    END

Nodes Add Capture
    [Documentation]                 Create a capture struct corelated to each node
    ...                             Global variable ${LIST_CAPTURE_NODE} is updated consequently
    @{LIST_CAPTURE_NODE}            Create list
    FOR    ${node}     IN          @{LIST_NODE}
            ${capture}              Dictionary get      ${CAPTURE_NODE}
            ${capture.node}         set variable        ${node.name}
            ${capture.prefix}       set variable        NODE${node.name}_GNB
            ${node.capture}         set variable        ${capture}
            set suite variable      ${node}
            Append to list          ${LIST_CAPTURE_NODE}    ${capture}
    END
    Set suite variable              ${LIST_CAPTURE_NODE}


Logs Build
    @{LIST_LOG}                     Create list
    Set suite variable              ${LIST_LOG}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPRT_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPRT}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPUE_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPUE}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPCL_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPCL}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPIF_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPIF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPNB_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_CPNB}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_UPUE_DEF}
    AddLogDefToList                 list=${LIST_LOG}    logDef=${LOG_L2RT}

Set Logs Variables for CLOUD
    Set To Dictionary 	 ${LOG_CPUE_DEF}       name=cpue_DEF       prefix=/tmp     postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPUE}           name=cpue           prefix=/tmp     postfix=/tmp/startup_cp_ue.log      isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPCL_DEF}       name=cpcl_DEF       prefix=/tmp     postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPCL}           name=cpcl           prefix=/tmp     postfix=/tmp/startup_cp_cl.log      isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPIF_DEF}       name=cpif_DEF       prefix=/tmp     postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPIF}           name=cpif           prefix=/tmp     postfix=/tmp/startup_cp_if.log      isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPNB_DEF}       name=cpnb_DEF       prefix=/tmp     postfix=/tmp/startup_DEFAULT.log    isNodeUsed=${True}
    Set To Dictionary    ${LOG_CPNB}           name=cpnb           prefix=/tmp     postfix=/tmp/startup_cp_nb.log      isNodeUsed=${True}
    Set To Dictionary    ${LOG_UPUE_DEF}       name=upue_DEF       prefix=/tmp     postfix=/tmp/FCTL-E00A_startup.log  isNodeUsed=${True}
    Set To Dictionary    ${LOG_L2RT}           name=upue           prefix=/tmp     postfix=ASP-<domainid>740_startup.log    isNodeUsed=${True}


Get Capture
    [Arguments]                     ${nodeName}
    ${capture}                      getCaptureFromNodeName
    ...                                 listNode=${LIST_NODE}
    ...                                 nodeName=${nodeName}
    [Return]                        ${capture}


Get Node
    [Arguments]                     ${name}
    ${node}                         getNodeFromName
    ...                                 listNode=${LIST_NODE}
    ...                                 name=${name}
    [Return]                        ${node}


Get Log
    [Arguments]                     ${name}
    ${log}                          getLogFromName
    ...                                 listLog=${LIST_LOG}
    ...                                 name=${name}
    [Return]                        ${log}
