# *** Settings ***
# Documentation     author: Sky Mei
# ...                 contact: sky.mei@nokia-sbell.com
# ...                 Feature 5GC001543 in 5G19A program related to COAM.
# Suite Setup       TestSuilt.Init
# Suite Teardown    TestSuilt.Destroy
# Force Tags        RAN_5G  RAN_5G_TDD  CLOUD_5G_CLASSICAL_ASIML_ABIPB1_2xAWHQE_ENB  STATE_SW_UPLOADED  SBTS00  SBTS21B
# ...    PY36
# ...               SBTS22R1
# Resource           ../None_Feature_SG1/OAM_Interface.robot
# 
# *** Variables ***
# #Configure the TL specific variable
# ${USER_LOG_DIR}        /opt/ute/Logs
# ${UPDATE_FILE_PATH}    /opt/ute/tmp
# #${CFGFILE_PATH}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
# ${YAFT_PATH}           /opt/ute/5G18AD/YAFT
# ${EGATE_CFG_NAME}      ${tl.core.cfg_filename}
# ${WTS_FILE_PATH}       ${tl.core.dir_path}
# ${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${UTE_IP}              ${tl.core.default_ssh_connection_details.addr}
# ${UTE_USERNAME}        ${tl.core.default_ssh_connection_details.username}
# ${UTE_PASSWORD}        ${tl.core.default_ssh_connection_details.password}
# ${MRBTS_ID}             MRBTS-${tl.gnbs[0].instance_id}
# ${NRBTS_ID}             NRBTS-${tl.gnbs[0].global_bts_id}
# 
# ${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# #${REAL_EPC_IP}    10.57.252.107
# #${REAL_EPC_USERNAME}    root
# #${REAL_EPC_PASSWORD}    APPpass
# #${UE_IP_FROM_REAL_EPC}    172.252.50.103
# #${DL_TRAFFIC_PORT}    51111
# #${ENBCTLPC_IP}    ${tl.enbs[0].default_ssh_connection_details.addr}
# #${ENBCTLPC_USERNAME}    ${tl.enbs[0].default_ssh_connection_details.username}
# #${ENBCTLPC_PASSWORD}    ${tl.enbs[0].default_ssh_connection_details.password}
# ${PB_PORT}        4001
# ${PB_ASIK_IP}          ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${PB_ASIK_PORT}        ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
# #${PB_5GRU_IP}    ${tl.gnbs[0].du.rus[0].pdu_port.pdu.addr}
# #${PB_5GRU_PORT}    ${tl.gnbs[0].du.rus[0].pdu_port.port_no}
# #${PB_5GRU_IP}     10.57.249.4
# #${PB_5GRU_PORT}    6
# #${PB_4GRU_IP}     1.1.1.1
# #${PB_4GRU_PORT}    3
# #${PB_HDBDE_IP}    ${tl.enbs[0].pdu_port.pdu.addr}
# #${PB_HDBDE_PORT}    ${tl.enbs[0].pdu_port.port_no}
# ${PB_WMPeNB_IP}        ${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${PB_WMPeNB_PORT}      ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}
# ##################define these variable for convenient############################
# ${ALIAS_ASIK}     asik    ##
# ${ALIAS_ASIK_SLAVE}    asik_slave    ##
# ${ALIAS_UTE}      ute    ##
# ${ALIAS_ENBCTLPC}    ENB_PC    ##
# ${ALIAS_SHP}      SHP    ##
# ${ALIAS_E500}     E500    ##
# ${ALIAS_PRISMA}    Prisma    ##
# ${ALIAS_REAL_EPC_SERVER}    Real_EPC    ##
# ${ALIAS_LONER}    LONER    ##
# ${ALIAS_ASP_1A}    ASP_1A  ##
# ########################END of alias Define#######################################
# ${WA_SCF_FILE_BLOW6G}    /home/ute/TA/cfgfile/SBTS5G18A_5g_pid12_classical.xml
# ${WA_SCF_FILE_ABOVE6G}    /home/ute/TA/cfgfile/SBTS5G18A_5g_pid11_classical.xml
# ${HZ_NETACT_URL}         https://na19lbwas.qin1.srnhz.nsn-rdnet.net/startpage/#
# ${HZ_NETACT_USER}        omc
# ${HZ_NETACT_PASSWORD}    Nokia126_
# ${MO_BTS_NAME}              MRBTS-1969
# ${MO_BTS_ID}              NRBTS-1975
# ${MO_BTS_NAME_1}            MRBTS-2003
# ${NETACT_LOGSERVER_IP}            ${tl.nms.addr}
# ${NETACT_LOGSERVER_USERNAME}      omc
# ${NETACT_LOGSERVER_PASSWORD}      Nokia126_
# ${JRE_FORCE_VERSION}   -8-oracle-x64
# #    List Components In Context
# *** Test Cases ***
# [1][1.0] 5GC001543-SA_5GC000940-A_001_Configure two gNBs name to the same in NetAct
#     [Documentation]  Set the BTS name to the one already present, then check set result and IsBtsNameUnique
#     [Tags]    Classicalbts    sky.mei@nokia-sbell.com    CRT_20A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case001    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_002_Configure two cells name to the same in NetAct
#     [Documentation]  Set Cell name to the same and check the result and IsCellNameUnique
#     [Tags]    CRT_20B    CRT_20A   CRT_21A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case002    KW.CaseDestroy
# ##[1]5GC001543-SA_5GC000940-A_003_Configure gNB and cells name in NetAct with cells name are the same
# ##    [Documentation]  Set the gNB name and Cell name to the same and check result and the IsCellNameUnique
# ##    [Tags]    Classicalbts    sky.mei@nokia-sbell.com    QC_390095    CIT
# ##    Robot.RunKeywordMultiTimesToSuccess    TC.Case003    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_004_Initialize synchronization of network with non-network names in NetAct
#     [Documentation]  synchromization check for network and non-network name
#     [Tags]    Classicalbts    sky.mei@nokia-sbell.com    CRT_20A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case004    KW.CaseDestroy
# #[1]5GC001543-SA_5GC000940-A_006_Configure gNB and cells name in NetAct
# #    [Documentation]  Config gNB and Cells name in NetAct successfully
# #    [Tags]    Classicalbts    sky.mei@nokia-sbell.com    QC_390098    CIT
# #    Robot.RunKeywordMultiTimesToSuccess    TC.Case006    KW.CaseDestroy
# #[1]5GC001543-SA_5GC000940-A_007_Configure gNB and cells with operator customized name in webUI
# #    [Documentation]  Configure gNB and Cell Name on WebUI and Check the Result.
# #    [Tags]    Classicalbts    sky.mei@nokia-sbell.com    QC_390099    CIT
# #    Robot.RunKeywordMultiTimesToSuccess    TC.Case007    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_008_Configure presentation name for gNB and cells in NetAct
#     [Documentation]  configure presentation name for gNB and cells in NetAct successfully
#     [Tags]    CRT_20B    CRT_20A     CRT_21A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case008    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_009_Configure two cells with same customized name in webUI
#     [Documentation]  Configure two cells with same customized name in webUI
#     [Tags]    Classicalbts    sky.mei@nokia-sbell.com    CRT_20A    CRT_UTE
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case009    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_010_Check uniqueness of presentation name for gNB and cell in NetAct
#     [Documentation]  Set gNB and Cell NON-Network name to non unique and check the result and IsNameUnique
#     [Tags]    Classicalbts    sky.mei@nokia-sbell.com    CRT_20A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case010    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_011_WebUI display in its User Interface the operator configurable identifiers of gNB and cells
#     [Documentation]  Check Display file name of CELL, and so on
#     [Tags]    CRT_20B    CRT_20A    CRT_TRUNK   CRT_21A   CRT_21B   CRT_UTE    CRT_22R1
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case011    KW.CaseDestroy
# #[1]5GC001543-SA_5GC000940-A_012_System log file names should include the operator customized name
# #    [Documentation]  Check log filename configuration file name and so on
# #    [Tags]    Classicalbts    sky.mei@nokia-sbell.com    QC_390104    CIT
# #    Robot.RunKeywordMultiTimesToSuccess    TC.Case012    KW.CaseDestroy
# #[1]5GC001543-SA_5GC000940-A_013_configure gNB and cells with customized name should not impact the cell status
# #    [Documentation]  Check CELL status while setting BTS name and cell name
# #    [Tags]    Classicalbts    sky.mei@nokia-sbell.com    QC_390105    CIT
# #    Robot.RunKeywordMultiTimesToSuccess    TC.Case013    KW.CaseDestroy
# [1][1.0] 5GC001543-SA_5GC000940-A_005_System log files name should be display with configured name in NetAct
#     [Tags]    Classicalbts    sky.mei@nokia-sbell.com    CRT_20A
#     [Setup]           KW.CaseInit
#     [Teardown]        KW.Teardown
#     [Timeout]         180 minutes
#     Robot.RunKeywordMultiTimesToSuccess    TC.Case005    KW.CaseDestroy
# #Test
# #    [Documentation]  Check log filename configuration file name and so on
# #    [Tags]    Classicalbts    sky.mei@nokia-sbell.com
# #    [Teardown]    Process.Destroy
# #    [Timeout]    30 minutes
# #    COAM.Login
# #    ${info}    COAM.GetCellInfo   1
# #------------End Passed-------------------------------------------------
# #TEST
# #    List Components In Context
# #
# #    ${Notes}       NetAct.CM.GetStatistics    SyncNameToCellName    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    SyncNameToCellName    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    SyncNameToBtsName    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    SyncNameToBtsName    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    SyncCellNameToName    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    SyncCellNameToName    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    SyncBtsNameToName    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    SyncBtsNameToName    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    IsNameUnique    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    IsNameUnique    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    IsCellNameUnique    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    IsCellNameUnique    Warnings
# #    ${Notes}       NetAct.CM.GetStatistics    IsBtsNameUnique    Notes
# #    ${Warnings}    NetAct.CM.GetStatistics    IsBtsNameUnique    Warnings
# *** Keywords ***
# TC.Case001
#     [Timeout]    30 minutes
#     KW.NetActInit
# #    ${envinfo}    run   env
# #    log to console     ${envinfo}
#     KW.NetActStartCMEditor
#     ${path}    NetAct.CM.SelectgNB  ${MO_BTS_NAME_1}
#     ${btsname_1}    NetAct.CM.GetBTSNameByPath    ${path}
#     ${path}    NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     NetAct.CM.SetBTSNameAndActive     ${btsname_1}
#     ${BTS_NAME}  NetAct.CM.GetBTSName
#     Should be equal    ${BTS_NAME}    ${btsname_1}
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics
#     ${result}    NetAct.CM.GetStatistics    IsBtsNameUnique    Warnings
#     Should Be True    ${result}>0
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
# TC.Case002
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartCMEditor
#     NetAct.CM.SetCellNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1    cell_name=TA-${MO_BTS_NAME}-CELL-1-2
#     NetAct.CM.SetCellNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2    cell_name=TA-${MO_BTS_NAME}-CELL-1-2
#     ${CELL-1}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1
#     ${CELL-2}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2
#     Should Be Equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-2
#     Should Be Equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-1-2
#     NetAct.CM.GetBTSName
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics
#     ${result}    NetAct.CM.GetStatistics    IsCellNameUnique    Warnings
#     Should Be True    ${result}>=2
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
# TC.Case003
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartCMEditor
#     KW.SetNetworkNameAndCheckTheValue  TA-${MO_BTS_NAME}-3    TA-${MO_BTS_NAME}-CELL-1-3    TA-${MO_BTS_NAME}-CELL-1-3
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics
#     ${result}    NetAct.CM.GetStatistics    IsCellNameUnique    Warnings
#     Should Be True    ${result}>=2
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
# TC.Case004
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartOperationManger
#     KW.NetActStartCMEditor
#     KW.SetNetworkNameAndCheckTheValue     TA-${MO_BTS_NAME}-4  TA-${MO_BTS_NAME}-CELL-1-4  TA-${MO_BTS_NAME}-CELL-2-4
#     KW.SetNonNetworknameAndCheckTheValue  TA-${MO_BTS_NAME}-4  TA-${MO_BTS_NAME}-CELL-1-4  TA-${MO_BTS_NAME}-CELL-2-4
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics
#     ${result}    NetAct.CM.GetStatistics    SyncNameToBtsName    Notes
#     Should Be True    ${result}==0
#     ${result}    NetAct.CM.GetStatistics    SyncBtsNameToName    Notes
#     Should Be True    ${result}==0
#     ${result}    NetAct.CM.GetStatistics    SyncNameToCellName    Notes
#     Should Be True    ${result}==0
#     ${result}    NetAct.CM.GetStatistics    SyncCellNameToName    Notes
#     Should Be True    ${result}==0
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
# 
#     KW.SetNetworkNameAndCheckTheValue     TA-${MO_BTS_NAME}-4-A  TA-${MO_BTS_NAME}-CELL-1-4-A  TA-${MO_BTS_NAME}-CELL-2-4-A
#     KW.SetNonNetworknameAndCheckTheValue  TA-${MO_BTS_NAME}-4-B  TA-${MO_BTS_NAME}-CELL-1-4-B  TA-${MO_BTS_NAME}-CELL-2-4-B
#     NetAct.SelectCMOperationManager
#     Run Keyword And Ignore error    NetAct.CMOperationManager.DeletePlan       TA_GEN_${MO_BTS_NAME}
#     NetAct.SelectCMEditor
#     NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics    true    TA_GEN_${MO_BTS_NAME}
#     ${result}    NetAct.CM.GetStatistics    SyncNameToBtsName    Notes
#     Should Be True    ${result}>=1
#     ${result}    NetAct.CM.GetStatistics    SyncBtsNameToName    Notes
#     Should Be True    ${result}>=1
#     ${result}    NetAct.CM.GetStatistics    SyncNameToCellName    Notes
#     Should Be True    ${result}>=2
#     ${result}    NetAct.CM.GetStatistics    SyncCellNameToName    Notes
#     Should Be True    ${result}>=2
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
#     NetAct.SelectCMOperationManager
#     NetAct.CMOperationManager.ActiveNewPlan    TA_GEN_${MO_BTS_NAME}
#     NetAct.SelectCMOperationManager
#     NetAct.CMOperationManager.DeletePlan       TA_GEN_${MO_BTS_NAME}
#     NetAct.SelectCMEditor
#     NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     swing.Click On Tree Node    navigationTree    ${BTSPATH.strip()}
#     swing.Select From Popup Menu On Selected Tree Nodes    navigationTree    Refresh Tree
#     Sleep   3s
#     NetAct.SelectCMEditor
#     NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     ${CELL-1}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1
#     ${CELL-2}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2
#     ${BTS_NAME}  NetAct.CM.GetBTSName
#     Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-4-B
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-4-B
#     Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-2-4-B
#     ${CELL-1}    NetAct.CM.GetCellAliasName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1
#     ${CELL-2}    NetAct.CM.GetCellAliasName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2
#     ${BTS_NAME}  NetAct.CM.GetBTSAliasName
#     Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-4-A
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-4-A
#     Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-2-4-A
# TC.Case005
#     [Timeout]    30 minutes
# #    KW.NetActInit
# #    KW.NetActStartOperationManger
# #    KW.NetActStartCMEditor
#     NetAct.LogServer.ClearLogFile    TA-${MO_BTS_NAME}
#     COAM.Login
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     #COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-5
#     #COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     selenium_coam.snapshot_collection_settings  Most important log files    Remote
#     ${error}    selenium_coam.collect_snapshot
#     Sleep   30
#     NetAct.LogServer.CheckLogFileName    ${BTS_NAME}
# #    NetAct.SelectCMOperationManager
# #    Run Keyword And Ignore error    NetAct.CMOperationManager.DeletePlan       TA_${MO_BTS_NAME}
# #    NetAct.SelectCMEditor
# #    NetAct.CM.SelectgNB  ${MO_BTS_NAME}
# #    NetAct.CM.SetBTSNameAndActive  TA-${MO_BTS_NAME}-5
# #    ${BTS_NAME}    NetAct.CM.GetBTSName
# #    Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-5
# #    NetAct.CM.CreateNewPlan    TA_${MO_BTS_NAME}
# #    NetAct.SelectCMOperationManager
# #    NetAct.CMOperationManager.ActiveNewPlan    TA_${MO_BTS_NAME}
# #    NetAct.SelectCMOperationManager
# #    NetAct.CMOperationManager.DeletePlan       TA_${MO_BTS_NAME}
# #    NetAct.SelectCMEditor
# #    NetAct.CM.SelectgNB  ${MO_BTS_NAME}
# 
#     #TODO: check finish and log
# TC.Case006
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartCMEditor
#     ${SpecialName}   Set Variable    12345678901234567890123456789012345678901234567890123456789012345678901234567890
#     KW.SetNetworkNameAndCheckTheValue    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     KW.CheckNetworkNameOnCOAM    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     ${SpecialName}   Set Variable    TA-${MO_BTS_NAME}-`~@#$%^&*()_+=-{}][:;"'<,>.?/1q2w
#     KW.SetNetworkNameAndCheckTheValue    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     KW.CheckNetworkNameOnCOAM    ${SpecialName}    ${SpecialName}    ${SpecialName}
# 
#     KW.SetNetworkNameAndCheckTheValue    TA-${MO_BTS_NAME}-6    ${EMPTY}    ${EMPTY}
#     KW.CheckNetworkNameOnCOAM    TA-${MO_BTS_NAME}-6    ${EMPTY}    ${EMPTY}
# 
#     KW.SetNetworkNameAndCheckTheValue    TA-${MO_BTS_NAME}-6   TA-${MO_BTS_NAME}-CELL-1-6    TA-${MO_BTS_NAME}-CELL-2-6
#     KW.CheckNetworkNameOnCOAM    TA-${MO_BTS_NAME}-6   TA-${MO_BTS_NAME}-CELL-1-6    TA-${MO_BTS_NAME}-CELL-2-6
#     #TODO add check point from other module like PM, FM, Alarm and So on
# TC.Case007
#     [Timeout]    30 minutes
#     KW.CaseInit
#     COAM.Login
#     COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-7
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-1-7
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-2-7
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     ${info}    COAM.GetCellInfo   1
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     ${info}    COAM.GetCellInfo   2
#     ${CELL-2}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-7
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-7
#     Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-2-7
# #    ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
# #    ${CELL-1}    COAM.GetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   Cell name
# #    ${CELL-2}    COAM.GetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   Cell name
# #    Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-7
# #    Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-7
# #    Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-2-7
#     COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-7
#     COAM.DeleteParameter  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name
#     COAM.DeleteParameter  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     ${info}    COAM.GetCellInfo   1
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     ${info}    COAM.GetCellInfo   2
#     ${CELL-2}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-7
#     Should be equal    ${CELL-1}    --
#     Should be equal    ${CELL-2}    --
#     #TODO add check point from other module like PM, FM, Alarm and So on
# TC.Case008
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartCMEditor
#     ${SpecialName}   Set Variable    12345678901234567890123456789012345678901234567890123456789012345678901234567890
#     KW.SetNonNetworknameAndCheckTheValue    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     ${SpecialName}   Set Variable    TA-${MO_BTS_NAME}-`~@#$%^&*()_+=-{}][:;"'<,>.?/1q2w
#     KW.SetNonNetworknameAndCheckTheValue    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     ${SpecialName}   Set Variable    ${EMPTY}
#     KW.SetNonNetworknameAndCheckTheValue    ${SpecialName}    ${SpecialName}    ${SpecialName}
#     KW.SetNonNetworknameAndCheckTheValue    TA-${MO_BTS_NAME}-8    TA-${MO_BTS_NAME}-CELL-1-8    TA-${MO_BTS_NAME}-CELL-2-8
# #    KW.NetActStartMonitor
# #    NetAct.Monitor.SelectNode    PLMN-PLMN|TA-${MO_BTS_NAME}-8
#     #TODO add check point from other module like PM, FM, Alarm and So on
# TC.Case009
#     [Timeout]    30 minutes
#     KW.CaseInit
#     COAM.Login
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-1-9
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-1-9
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${info}    COAM.GetCellInfo   1
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     ${info}    COAM.GetCellInfo   2
#     ${CELL-2}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-9
#     Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-1-9
# 
#     COAM.DeleteParameter  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name
#     COAM.DeleteParameter  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${info}    COAM.GetCellInfo   1
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     ${info}    COAM.GetCellInfo   2
#     ${CELL-2}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${CELL-1}    -
#     Should be equal    ${CELL-2}    -
#     #should be warning
#     #check point modify
# TC.Case010
#     [Timeout]    30 minutes
#     KW.NetActInit
#     KW.NetActStartCMEditor
#     ${path}    NetAct.CM.SelectgNB  ${MO_BTS_NAME_1}
#     ${btsname_1}    NetAct.CM.GetBTSAliasNameByPath    ${path}
#     NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     KW.SetNonNetworknameAndCheckTheValue  ${btsname_1}  TA-${MO_BTS_NAME}-CELL-1-10  TA-${MO_BTS_NAME}-CELL-1-10
#     Wait Until Keyword Succeeds    3 times    10s    NetAct.CM.OpenStatistics
#     ${result}    NetAct.CM.GetStatistics    IsNameUnique    Warnings
#     Should Be True    ${result}>=3
#     Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    defaultBtnCancel
#     NetAct.CM.SetBTSAliasNameAndActive     TA-${MO_BTS_NAME}-10
# TC.Case011
#     [Timeout]    30 minutes
#     KW.CaseInit
#     COAM.Login
#     COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-11
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-1-11
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-2-11
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     ${CELL-1}    COAM.GetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name
#     ${CELL-2}    COAM.GetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name
#     Should be equal    ${BTS_NAME}    TA-${MO_BTS_NAME}-11
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-11
#     Should be equal    ${CELL-2}    TA-${MO_BTS_NAME}-CELL-2-11
#     ${info}    COAM.GetCellInfo   1
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-1-11
#     ${info}    COAM.GetCellInfo   2
#     ${CELL-1}    Get From Dictionary    ${info}    Cell name
#     Should be equal    ${CELL-1}    TA-${MO_BTS_NAME}-CELL-2-11
# TC.Case012
#     [Timeout]    30 minutes
#     KW.CaseInit
#     COAM.Login
#     COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-1
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-12
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     selenium_coam.snapshot_collection_settings  Most important log files    Local
#     ${value}    Run Keyword And Ignore error    selenium_coam.collect_snapshot
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.save_current_alarms
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.save_historical_alarms
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.download_transport_counters    ETHIF
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.download_real_time_measurements_counters    RMOD_R-1 (AEUA)
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.get_active_alarm_info
#     ${alarm}    Run Keyword And Ignore error    Get From Dictionary    @{value[1]}[0]    Alarming object
#     Run Keyword If   '${alarm[0]}'=='PASS'   Should Be True    ${alarm[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.get_history_alarm_info
#     ${alarm}    Run Keyword And Ignore error    Get From Dictionary    @{value[1]}[0]    Alarming object
#     Run Keyword If   '${alarm[0]}'=='PASS'   Should Be True    ${alarm[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.save_fault_toggling_history
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.get_bts_name
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#     ${value}    Run Keyword And Ignore error    selenium_coam.save_bts_configuration
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
#      ${value}    Run Keyword And Ignore error    selenium_coam.save_report
#     Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0
# TC.Case013
#     [Timeout]    30 minutes
#     KW.CaseInit
#     COAM.Login
#     ${info}    COAM.GetCellInfo   1
#     ${info}    Get From Dictionary    ${info}    Status
#     ${pre_state_1}    Get From Dictionary    ${info}    Availability status
#     ${info}    COAM.GetCellInfo   2
#     ${info}    Get From Dictionary    ${info}    Status
#     ${pre_state_2}    Get From Dictionary    ${info}    Availability status
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}   abbr=BTS name    value=TA-${MO_BTS_NAME}-13
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-1-13
#     COAM.SetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name    value=TA-${MO_BTS_NAME}-CELL-2-13
#     COAM.ValidateAndActiveParameters    ${ACTFORCE}
#     #check point modify
#     ${info}    COAM.GetCellInfo   1
#     ${info}    Get From Dictionary    ${info}    Status
#     ${state_1}    Get From Dictionary    ${info}    Availability status
#     ${info}    COAM.GetCellInfo   2
#     ${info}    Get From Dictionary    ${info}    Status
#     ${state_2}    Get From Dictionary    ${info}    Availability status
#     Should be equal    ${state_1}    ${pre_state_1}
#     Should be equal    ${state_2}    ${pre_state_2}
# KW.SetNetworkNameAndCheckTheValue
#     [Arguments]   ${btsName}    ${Cell1Name}    ${Cell2Name}
#     NetAct.CM.SetBTSNameAndActive     ${btsName}
#     NetAct.CM.SetCellNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1    cell_name=${Cell1Name}
#     NetAct.CM.SetCellNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2    cell_name=${Cell2Name}
#     ${CELL-1}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1
#     ${CELL-2}    NetAct.CM.GetCellName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2
#     ${BTS_NAME}  NetAct.CM.GetBTSName
#     Should be equal    ${BTS_NAME}    ${btsName}
#     Should be equal    ${CELL-1}    ${Cell1Name}
#     Should be equal    ${CELL-2}    ${Cell2Name}
# KW.CheckNetworkNameOnCOAM
#     [Arguments]   ${btsName}    ${Cell1Name}    ${Cell2Name}
#     COAM.Login
#     ${BTS_NAME}    COAM.GetParameterValue  ${MO_BTS_NAME}   BTS name
#     ${CELL-1}    COAM.GetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   abbr=Cell name
#     ${CELL-2}    COAM.GetParameterValue  distName=${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   abbr=Cell name
#     Should be equal    ${BTS_NAME}    ${btsName}
#     Should be equal    ${CELL-1}    ${Cell1Name}
#     Should be equal    ${CELL-2}    ${Cell2Name}
# KW.SetNonNetworknameAndCheckTheValue
#     [Arguments]   ${btsName}    ${Cell1Name}    ${Cell2Name}
#     NetAct.CM.SetBTSAliasNameAndActive     ${btsName}
#     NetAct.CM.SetCellAliasNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1    cell_name=${Cell1Name}
#     NetAct.CM.SetCellAliasNameAndActive    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2    cell_name=${Cell2Name}
#     ${CELL-1}    NetAct.CM.GetCellAliasName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-1
#     ${CELL-2}    NetAct.CM.GetCellAliasName    MO_BTS=${MO_BTS_ID}    MO_CELL=NRCELL-2
#     ${BTS_NAME}  NetAct.CM.GetBTSAliasName
#     Should be equal    ${BTS_NAME}    ${btsName}
#     Should be equal    ${CELL-1}    ${Cell1Name}
#     Should be equal    ${CELL-2}    ${Cell2Name}
# KW.CaseInit
#     Log to Console    KW.CaseInit
#     TestCase.Start
# KW.Teardown
#     Log to Console    KW.Teardown
#     TestCase.Stop
# KW.CaseDestroy
#     Log to Console    KW.CaseDestroy
#     Run Keyword And Ignore error    COAM.Logout
#     Run Keyword And Ignore error    KW.NetActDestroy
#     run   command=killall firefox
#     run   command=killall Xvfb
#     run   command=killall geckodriver
# KW.NetActInit
#     Log to Console    KW.NetActInit
#     NetAct.login  ${HZ_NETACT_URL}  ${HZ_NETACT_USER}  ${HZ_NETACT_PASSWORD}
# KW.NetActStartCMEditor
#     [Timeout]    30 minutes
# #    NetAct.StartApp  CM Analyzer
# #    Log to Console    debug:Start CM Analyzer Finished \ successfully.
#     Log to Console    debug:Login Finished \ successfully.
#     NetAct.StartApp   CM Editor
#     Log to Console    debug:Start CM Editor Finished \ successfully.
#     swing.Switch to Application    CM Editor
#     ${path}    NetAct.CM.SelectgNB  ${MO_BTS_NAME}
#     ${INODE}   ${BTSNode}   Split String From Right    string=${path}   separator=|     max_split=1
#     set global variable    ${BTSPATH}    ${path}
#     set global variable    ${INODE}    ${INODE}
#     ${BTSAlias}    NetAct.CM.GetBTSAliasName
#     set global variable    ${BTSALIAS}   ${BTSAlias}
#     Log to Console    debug:SelectgNB Finished \ successfully.
# KW.NetActStartOperationManger
#     NetAct.StartApp   CM Operations Manager
# KW.NetActStartMonitor
#     NetAct.StartApp   Monitor
# KW.NetActDestroy
#     Run Keyword And Ignore error    NetAct.CloseApp    CM Editor
#     Run Keyword And Ignore error    NetAct.CloseApp    CM Operations Manager
#     Run Keyword And Ignore error    NetAct.logout
# KW.CheckCellStatusOnAir
#     Conn.ResetCache
#     gNB.Connect
#     gNB.CheckHWStatusUntilReady
#     gNB.CheckSWStatusUntilReady
# #    run keyword and ignore error    gNB.CheckCPRIStatusUntilReady
# #    gNB.CheckF1StatusUntilReady
# #    gNB.CheckX2StatusUntilReady
#     gNB.Disconnect
# TestSuilt.Init
#     Log to Console    TestSuilt.Init
#     TestSuite.Start
#     Create Directory    ${OUTPUT DIR}/Logs
#     Create Directory    ${OUTPUT DIR}/stack_templates
#     Set Suite Variable    ${LOG_PATH}    ${OUTPUT DIR}/Logs
#     #TestSuilt.UseUserLogPath
#     run   command=killall firefox
#     run   command=killall Xvfb
#     run   command=killall geckodriver
# 
#     set suite variable    ${MO_BTS_NAME}              ${CASE_INPUT_5GC001543['SectionGNB']['MRBTS']}
#     set suite variable    ${MO_BTS_NAME_1}            ${CASE_INPUT_5GC001543['SectionGNB']['MRBTS_1']}
#     set suite variable    ${MO_BTS_ID}                ${CASE_INPUT_5GC001543['SectionGNB']['NRBTS']}
#     set suite variable    ${HZ_NETACT_URL}            ${CASE_INPUT_5GC001543['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_URL']}
#     set suite variable    ${HZ_NETACT_USER}           ${CASE_INPUT_5GC001543['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_USER']}
#     set suite variable    ${HZ_NETACT_PASSWORD}       ${CASE_INPUT_5GC001543['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_PASSWORD']}
#     set suite variable    ${NETACT_LOGSERVER_IP}      ${CASE_INPUT_5GC001543['SectionNETACT']['CMSERVER_INFO']['CMSERVERIP']}
#     set suite variable    ${NETACT_LOGSERVER_USERNAME}       ${CASE_INPUT_5GC001543['SectionNETACT']['CMSERVER_INFO']['CMSERVERUSER']}
#     set suite variable    ${NETACT_LOGSERVER_PASSWORD}       ${CASE_INPUT_5GC001543['SectionNETACT']['CMSERVER_INFO']['CMSERVERPWD']}
#     #KW.CheckCellStatusOnAir
#     set global variable     ${ACTFORCE}    True
# #    COAM.Login
# #    COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-TT
# #    COAM.SetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   Cell name    TA-${MO_BTS_NAME}-CELL-1-TT
# #    COAM.SetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   Cell name    TA-${MO_BTS_NAME}-CELL-2-TT
# #    ${value}    Run Keyword And Ignore error  COAM.ValidateAndActiveParameters    False
# #    Run Keyword If   '${value[0]}'=='PASS'     set global variable     ${ACTFORCE}    False
# #
# #    COAM.Login
# #    COAM.SetParameterValue  ${MO_BTS_NAME}   BTS name    TA-${MO_BTS_NAME}-T
# #    COAM.SetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-1   Cell name    TA-${MO_BTS_NAME}-CELL-1-T
# #    COAM.SetParameterValue  ${MO_BTS_NAME}/${MO_BTS_ID}/NRCELL-2   Cell name    TA-${MO_BTS_NAME}-CELL-2-T
# #    ${value}    Run Keyword And Ignore error  COAM.ValidateAndActiveParameters    True
# #    Run Keyword If   '${value[0]}'=='PASS'     set global variable     ${ACTFORCE}    True
#     #Run Keyword And Ignore error    NetAct.Init
# 
# TestSuilt.Destroy
#     Log to Console    TestSuilt.Destroy
# #    Run Keyword And Ignore error    NetAct.CloseApp  CM Editor
# #    Run Keyword And Ignore error    NetAct.CloseApp  CM Operations Manager
# #    Run Keyword And Ignore error    KW.NetActDestroy
#     run   command=killall firefox
#     run   command=killall Xvfb
#     run   command=killall geckodriver
#     TestSuite.Stop