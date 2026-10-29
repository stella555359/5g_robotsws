*** Settings ***
Documentation     author: Sky Mei
...               contact: sky.mei@nokia-sbell.com
...               Feature 5GC000092 in 5G19A program related to COAM.
Library             taf.fdsw.rc    WITH NAME    rc
Resource          ../../None_Feature_SG1/OAM_Interface.robot
Library           ../../None_Feature_SG1/OAM_Interface.py
Library           OAM_Interface.fdsw_oam_extend     WITH NAME     fdsw_oam_extend
Library           OAM_Interface.sshservice     WITH NAME     sshservice
#Library           taf.sbts.oam.coam.admin     WITH NAME     COAM_ADMIN
Library           Collections
Library           String
#Variables         ${CFGFILE_PATH}/TLDelta.py
*** Variables ***
#Configure the TL specific variable
#${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}     /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${DELTA_PATH}           ${CFGFILE_PATH}/5GC000092/Delta.py


${USER_LOG_DIR}      /opt/ute/Logs
${UPDATE_FILE_PATH}  /opt/ute/5GC000092
${YAFT_PATH}         /opt/ute/5GC000092/YAFT
${ASIK_IP}           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UTE_IP}            ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}      ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}      ${tl.test_pc.default_ssh_connection_details.password}
${WEBUI_IP}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_URL}         https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${PB_ASIK_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}      ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_WMPeNB_IP}      ${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_WMPeNB_PORT}    ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}
##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_E500}               E500                                                ##
${ALIAS_PRISMA}             Prisma                                              ##
${ALIAS_REAL_EPC_SERVER}    Real_EPC                                            ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
########################END of alias Define#######################################
${WA_SCF_FILE_BLOW6G}      /home/ute/TA/cfgfile/SBTS5G18A_5g_pid12_classical.xml
${WA_SCF_FILE_ABOVE6G}     /home/ute/TA/cfgfile/SBTS5G18A_5g_pid11_classical.xml
#${HZ_NETACT_URL}           https://clab1218lbwas.netact.nsn-rdnet.net/startpage/
#${HZ_NETACT_USER}          omc
#${HZ_NETACT_PASSWORD}      omc
#${MO_BTS_NAME}             MRBTS-1964
#${MO_BTS_NAME_1}           MRBTS-2003
${NETACT_LOGSERVER_IP}            ${tl.nms.addr}
${NETACT_LOGSERVER_USERNAME}      omc
${NETACT_LOGSERVER_PASSWORD}      Nokia126_
${JRE_FORCE_VERSION}       -8-oracle-x64
${FDSWServerPath}          http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/LN/
#${BTSSWServerPath}         https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
#${BTSSWServerPath}         https://artifactory-hz1.int.net.nokia.com:443/artifactory/mnp5g-central-public-local/System_Release
#${BTSSWServerPath}         https://artifactory-hz1.int.net.nokia.com:443/artifactory/mnp5g-central-public-remote/System_Release
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
${CS_FDSW_PATH}             /tmp/ZHJ
#${BOARD}                    ASIK
#${POSTFIX}                  ${EMPTY}
#${FDSWNEW}                  LN_WN_FDSW19A_0000_000128_000000
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}

${POSTFIX}                  ${EMPTY}
*** Keywords ***
TC.TEST
    #KW.PreparePnPPlanAndClearIPsec    method=SN    mode=DHCPv4CAIPsec    #mode for IPv4/IPv6 in SCF
    #KW.ReStartDHCP   mode=DHCPv4None
   FDSW.Connect

TC.CB005863_001_General PnP with IPV4
    KW.FDSWNewPreInstalled    method=SN    mode=DHCPv4None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned

TC.CB005863_002_General PnP with IPV6
    KW.FDSWNewPreInstalled    method=SN    mode=DHCPv6None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
#[1]5GC000092_010_Configure DU connectivity from WebEM with DHCP-Less model
#    [Documentation]  The purpose of this test case is to check the FDSW old can get PnP necessary
#    ...                information from configuration file but not DHCP server,
#    ...                the configuration was configured from WebEM
#    [Tags]            CIT    Classicalbts    case10    sky.mei@nokia-sbell.com    QC_321594
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    KW.DHCPLessMode
#    Set Suite Variable    ${PNPState}    NotStart
#[1]5GC000092_001_Plan pre-validation and upload to PnP AC service
#    [Documentation]  The purpose of this test case is to prepare the PNEI,
#    ...                SCF and other necessary parameters to the classical BTS Plug and Play
#    [Tags]            CIT    Classicalbts    case1    sky.mei@nokia-sbell.com    QC_419955
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    Should contain any    ${PlanState}    PlanConfigured
#[1]5GC000092_002_DHCP discover FDSW old
#    [Documentation]  The purpose of this test case is to check the FDSW old can be discover
#    ...                by DHCP server
#    ...                and get needed IP address from it
#    [Tags]            CIT    Classicalbts    case2    sky.mei@nokia-sbell.com    QC_321586
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=oldDHCPDiscovered
#[1]5GC000092_003_DNAT identify FDSW old protocol
#    [Documentation]  The purpose of this test case is to check the DNAT identify FDSW old
#    [Tags]            CIT    Classicalbts    case3    sky.mei@nokia-sbell.com    QC_419956
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=oldidentified
#[1]5GC000092_005_Compatilibity Server download FDSW new over FDSW old
#    [Documentation]  The purpose of this test case is to check the Compatibility Server
#    ...                download FDSW new over FDSW old
#    [Tags]            CIT    Classicalbts    case5    sky.mei@nokia-sbell.com    QC_419958
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=FDSWnewactive
#[1]5GC000092_004_DNAT identify FDSW new protocol
#    [Documentation]  The purpose of this test case is to check the DNAT identify FDSW new
#    [Tags]            CIT    Classicalbts    case4    sky.mei@nokia-sbell.com    QC_419957
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=identified
#[1]5GC000092_006_PnP Auto-Connection Service identify NE and update model
#    [Documentation]  The purpose of this test case is to check the Autoconnection server can identify
#    ...                the NE,then update model to FDSW new
#    [Tags]            CIT    Classicalbts    case6    sky.mei@nokia-sbell.com    QC_419959
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=identified
#[1]5GC000092_007_Target software download
#    [Documentation]  The purpose of this test case is to check the target software can be download
#    ...                success to FDSW
#    [Tags]            CIT    Classicalbts    case7    sky.mei@nokia-sbell.com    QC_419960
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=SoftwareDownloaded
#[1]5GC000092_008_BTS activate and reset
#    [Documentation]  The purpose of this test case is to check the FDSW can be activate and reset
#    ...                after target software download success
#    [Tags]            CIT    Classicalbts    case8    sky.mei@nokia-sbell.com    QC_419961
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    Run Keyword If   '${PNPState}'=='NotStart'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    KW.CheckPnPState    src=${PNPState}    dst=RestartWithTargetSW
TC.5GC000092_029_BTS commission
    [Documentation]
	...    Aim to test gNB can upgrade to target SW and commission prepared SCF automatically by NetAct
	...        when gNB is running FDSW build with manual IPV4.
	...    Precondition: config java env on UTE / PnP plan file
    ...    Note: These test steps are testing on ASIL. For the test of other ASIx, add later.
	...    TestSteps:
	...        Step1: Download FDSW and target SW to UTE
	...        Step2: Import target SW to NetAct
	...        Step3: Clear gNB config and YAFT to FDSW build
	...        Step4: Delete old PnP plan and Import related PnP plan file to NetAct
	...        Step5: Set NCF parameters on gNB
	...        Step6: Check gNB is upgraded to target SW automatically
	...        Step7: Check gNB is commissioned
	...    Configuration Parameters:
	...        TL configuration: N/A
	...        TC configuration:
	...                  set "oamTls"=off in PnP plan file
	...                  NetAct and NCF related information can refer {CASE_INPUT_5GC000092} in TLDelta.py in TL1107
	...        Checkpoint configuration: N/A
#    Run Keyword If   '${BOARD}'!='ASIL'    KW.FDSWOldPreInstalled    method=SN    mode=Manualv4None
#    Run Keyword If   '${BOARD}'=='ASIL'    KW.FDSWNewPreInstalled    method=SN    mode=Manualv4None
    KW.FDSWNewPreInstalled    method=SN    mode=Manualv4None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
##[1]5GC000092_009_Check BTS PnP report
##    [Documentation]  The purpose of this test case is to check the FDSW can be activate and reset
##    ...                after target software download success
##    [Tags]            CIT    Classicalbts    case9    sky.mei@nokia-sbell.com
##    [Setup]           KW.CaseInit
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    Fail    Known step
##    #TODO: how to check the content of PnP report file
TC.5GC000092_025_PnP with IPV6 and FDSW new pre-installed
    KW.FDSWNewPreInstalled  method=SN    mode=Manualv6None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
TC.5GC000092_026_PnP with IPV6 and FDSW old pre-installed
    KW.FDSWOldPreInstalled    method=SN    mode=Manualv6None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned

#[1]5GC000092_011_Configure TLS between BTS and PnP Server(NetAct)
#    [Documentation]  The purpose of this test case is to check the TLS connection between BTS and NetAct
#    [Tags]            Classicalbts    case11    sky.mei@nokia-sbell.com    QC_419962
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         200 minutes
#    KW.FDSWNewPreInstalled  method=SN    mode=Manualv4CA
#    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
#    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
#    KW.FDSWNewPreInstalled  method=SN    mode=Manualv6CA
#    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
#    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
#    #TODO: How to configure TLS by NetAct and gNB
#    #Fail    Known step
#    #TODO: How to configure IPSec by NetAct and gNB
TC.5GC000092_012_Configure IPSec tunnel between BTS and PnP Server(NetAct)
    KW.MultiRun    KW.FDSWNewPreInstalled  method=SN    mode=DHCPv4CAIPsec    times=2
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
    KW.MultiRun    KW.FDSWOldPreInstalled    method=SN    mode=DHCPv4CAIPsec    times=2
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
    KW.MultiRun    KW.FDSWNewPreInstalled  method=SN    mode=Manualv6CAIPsec    times=2
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
    KW.MultiRun    KW.FDSWOldPreInstalled    method=SN    mode=Manualv6CAIPsec    times=2
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
    Run Keyword If    '${TlsMode}'=='false'    Fail    TlsMode == false
TC.5GC000092_027_PnP with IPV4 and FDSW new pre-installed
    KW.FDSWNewPreInstalled  method=SN    mode=Manualv4None
    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
#[1]AddForTest
#    KW.InstallOldAndActive
#    KW.FDSWNewPreInstalled    method=BYID   mode=DHCPv4None
#    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned
##[1]5GC000092_013_Restart Compatibility Server
##    [Documentation]  The purpose of this test case is to check the Compatibility Server can be restart seperately
##    [Tags]            CIT    Classicalbts    case13    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: How to restart compatibility server on NetAct
##[1]5GC000092_014_Upgrade Compatibility Server
##    [Documentation]  The purpose of this test case is to check the Compatibility Server can be upgrade seperately
##    [Tags]            CIT    Classicalbts    case14    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: How to upgrade compatibility server on NetAct
##[1]5GC000092_015_Preprovisioning failed
##    [Documentation]   The purpose of this test case is to check the recovery of preprovisioning failed before PnP startup
##    [Tags]            CIT    Classicalbts    case15    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: No
##[1]5GC000092_016_DHCP connection and CA exchange FDSW old failed
##    [Documentation]  The purpose of this test case is to check the recovery of preprovisioning failed before PnP startup
##    [Tags]            CIT    Classicalbts    case16    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_017_gNB FDSW old should retry and log when connect to DNAT failed
##    [Documentation]  The purpose of this test case is to test the function gNB FDSW(old)
##    ...                should retry and log when connect to DNAT failed.
##    [Tags]            CIT    Classicalbts    case17    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_018_gNB should log the error in report log when download FDSW new failed for gNB issue
##    [Documentation]  The purpose of this test case is to test the function gNB should log the error in report log
##    ...                when download FDSW new failed for gNB issue.
##    [Tags]            CIT    Classicalbts    case18    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_019_Compatibility Server should log the error when download FDSW new failed for Compatibility Server issue
##    [Documentation]   The purpose of this test case is to test the function compatibility Server should log the error
##    ...                 when download FDSW new failed for Compatibility Server issue.
##    [Tags]            Classicalbts    case19    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_020_gNB should fallback and retry when active FDSW new failed
##    [Documentation]  The purpose of this test case is to test the recovery action of gNB  when active FDSW(new) failed.
##    ...                gNB should fallback and retry the PnP procedure, the retry action will write in PnP report log.
##    [Tags]            CIT    Classicalbts    case20    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_021_FDSW new should retry when PnP AC service is unreachable or has network connectivity issues
##    [Documentation]  The purpose of this test case is to test the recovery action of gNB when PnP A/C service is
##    ...                unreachable or has network connectivity issues.
##    [Tags]            CIT    Classicalbts    case21    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
#
##[1]5GC000092_023_FDSW new should retry to download the target SW when download failed
##    [Documentation]   The purpose of this test case is to test the gNB FDSW(new) should  retry to download the
##    ...                target SW when download failed and the max number of retries should write in the PnP report log.
##    [Tags]            CIT    Classicalbts    case23    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
##[1]5GC000092_024_gNB should report alarm to NetAct to indicate that the target SW activation failed
##    [Documentation]  The purpose of this test case is to test the gNB should report alarm to NetAct when target
##    ...                SW activation failed during PnP procedure.
##    [Tags]            CIT    Classicalbts    case24    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: NO, How to trigger the issue
#
##[1]5GC000092_022_FDSW new should retry when PnP automation connection service identifies gNB failed
##    [Documentation]  The purpose of this test case is to test the recovery action of gNB and NetAct when PnP
##    ...                automation connection service identifies gNB failed.
##    [Tags]            CIT    Classicalbts    case22    sky.mei@nokia-sbell.com
##    [Setup]           KW.CaseInit
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         60 minutes
##    KW.ReStartDHCP  type=v4   protocol=NE3S
##    KW.TryEnableSSH
##    KW.DeleteNCF
##    KW.YaftFDSW    filename=${FDSWNEW}_release_BTSSM_downloadable.zip
##    Sleep    60
##    ${con}=    KW.FDSWConnect
##    Wait until keyword succeeds   2times   60s   fdsw_oam_extend.autoconnection_restore_defaults   conn=${con}
##    Sleep    180
##    Wait until keyword succeeds   12min   1min   KW.DHCPWithProtocol    con=${con}
##    ...    protocol=NE3S    source=DHCP
##    Repeat Keyword    2    KW.SeTIMOSIPandCheckRestartAC    con=${con}
#
##[1]5GC000092_028_Compatibility Server can handle 100s of NEs per hour
##    [Documentation]  The purpose of this test case is to test the performance PnP,  the Compatibility Server can handle [100s]
##    ...                of NEs per hour (at a minimum & scalable) with a reasonable response time limit (time-outs).
##    ...                Note: Small Cells may have a high number. NetAct manual work-flow configuration (is a rate-limiting factor).
##    [Tags]            CIT    Classicalbts    case28    sky.mei@nokia-sbell.com
##    [Setup]
##    [Teardown]        KW.CaseDestroy
##    [Timeout]         30 minutes
##    KW.CaseInit
##    #TODO: Can't TA
#    #TODO: How to get the initial SCF
#[1]5GC000092_027_PnP with IPV4 and FDSW new pre-installed
#    [Documentation]  The purpose of this test case is to test the PnP function when FDSW(new) is pre-installed.
#    [Tags]            CIT    Classicalbts    case27    sky.mei@nokia-sbell.com
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    KW.FDSWNewPreInstalled
#    KW.CheckPnPState    src=${PNPState}    dst=BTSCommissioned

KW.FDSWOldPreInstalled
    [Arguments]   ${method}=SN    ${mode}=DHCPv4None
    log to console    KW.FDSWOldPreInstalled=${mode}
    Set Suite Variable    ${PNPState}    NotStart
    Set Suite Variable    ${TlsMode}    false
    Set Suite Variable    ${CMServerState}    NotStart
    Run Keyword And Ignore error    KW.PreparePackageAndUploadPlugin
    Run Keyword And Ignore error    KW.InstallOldAndActive
    Run Keyword And Ignore error    KW.ConfigTlsOnNetAct    mode=${mode}
    Run Keyword And Ignore error    KW.PreparePnPPlanAndClearIPsec    method=${method}    mode=${mode}
    Run Keyword And Ignore error    KW.PrepareFDSWNewOnServer

    KW.IdentifyOld    mode=${mode}
    KW.DownloadNewAndActive
#    KW.SetParameterOnFDSWNew    mode=${mode}
    KW.IdentifyNew    mode=${mode}
    KW.CheckTLsMode    mode=${mode}
    KW.DownloadTargetSWAndActive
    KW.Commission
#    KW.WaitOnAir
KW.FDSWNewPreInstalled
    [Arguments]   ${method}=BYID    ${mode}=DHCPv4None
    log to console    KW.FDSWNewPreInstalled=${mode}
    Set Suite Variable    ${PNPState}    NotStart
    Set Suite Variable    ${TlsMode}    false
    KW.PreparePackageAndUploadPlugin
    KW.InstallNewAndActive
    Run Keyword And Ignore error    KW.ConfigTlsOnNetAct    mode=${mode}
    KW.PreparePnPPlanAndClearIPsec    method=${method}    mode=${mode}    #mode for IPv4/IPv6 in SCF
    KW.SetParameterOnFDSWNew    mode=${mode}
    KW.IdentifyNew    mode=${mode}    #mode for DHCP
    KW.CheckTLsMode    mode=${mode}
    KW.DownloadTargetSWAndActive
    KW.Commission
#    KW.WaitOnAir
KW.MultiRun
    [Arguments]   ${keyword}    ${method}=SN    ${mode}=DHCPv4None    ${times}=2
    FOR    ${i}    IN RANGE    ${times}
         ${res}    Run Keyword And Ignore error    ${keyword}    ${method}    ${mode}
         Return From Keyword if   '${res[0]}'=='PASS'
    END
    Fail  Run '${keyword}' failed after retry '${times}' times
KW.CheckTLsMode
    [Arguments]    ${mode}=Manualv4CA
    return from keyword if    ${mode.count("CA")} < 1
    Run Keyword And Ignore error    KW.TryEnableSSH
    Conn.ConnectTo  IP=${ASIK_IP}  username=${ASIK_USERNAME}  password=${ASIK_PASSWORD}    alias=ASIK
    ${res}    Conn.Execute  cmd=cat /ffs/run/config/NCF.xml |grep tlsMode|grep 0    alias=ASIK
    #should be true    ${res.count("tlsMode")} > 0
    ${tls}    Set Variable If     ${res.count("tlsMode")} == 0   true    false
    Set Suite Variable    ${TlsMode}    ${tls}
    log to console    ${TlsMode}
    #Conn.Execute  cmd=rm /ffs/run/config/*NCF* -rf    alias=ASIK
    Conn.Disconnect  ASIK
KW.PreparePackageAndUploadPlugin
    log to console    PreparePackageAndUploadPlugin start
    return from keyword if     '${PreparePackageStatus}'=='prepared'
    Wait until keyword succeeds     3times    30s     KW.DownloadPackage    FDSWOLD=${FDSWOLD}    FDSWNEW=${FDSWNEW}    BTSSW=${FILENAME}
    #rename in upload package and upload
    #Set Suite Variable    ${PackageDownloadStatus}    prepared
    KW.GetTargetBDVersion
    Wait until keyword succeeds     3times    30s     KW.UploadPackage     FDSWNEW=${FDSWNEW}    BTSSW=${TARGETSW}
    Wait until keyword succeeds     3times    30s     KW.UploadPlugin    version=${TARGETSWNAME}
    Set Suite Variable    ${PreparePackageStatus}     prepared
    log to console    PreparePackageAndUploadPlugin end
KW.ConfigTlsOnNetAct
    [Arguments]     ${mode}=None
    return from keyword if    '${TLSServiceConfigured}'=='TLSServiceConfigured'
    log to console    ConfigTlsOnNetAct start
    KW.ConfigCACert    mode=${mode}
    #return from keyword if    '${TLSServiceConfigured}'=='TLSServiceConfigured'
    ${tls}    Set Variable If    ${mode.count("CA")} > 0    true    false
    Conn.ConnectTo  IP=${CMSERVERIP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    alias=CMServer
    Basic.SedReplaceLine    matchValue=com.nokia.pnp.autoconnection.tls_forced
    ...    newValue=com.nokia.pnp.autoconnection.tls_forced=${tls}
    #...    file=/root/pnp_autoconnection.properties    alias=CMServer
    ...    file=/opt/oss/Nokia-pnpautoconnection/conf/pnp_autoconnection.properties    alias=CMServer
    Conn.Execute  cmd=smanager.pl stop service pnp_autoconnection    alias=CMServer
    Conn.Execute  cmd=smanager.pl start service pnp_autoconnection    alias=CMServer
    ${result}    Conn.Execute  cmd=smanager.pl status service pnp_autoconnection    alias=CMServer
    should contain     ${result}    started
    Conn.Disconnect  alias=CMServer
    #Set Suite Variable    ${TLSServiceConfigured}    TLSServiceConfigured
    log to console    ConfigTlsOnNetAct end
KW.PreparePnPPlanAndClearIPsec
    [Arguments]   ${method}=SN    ${mode}=DHCPv4None
    log to console    PreparePnPPlan start
    Wait until keyword succeeds     3times    30s    KW.PreparePnPPlan    method=${method}    mode=${mode}
    Wait until keyword succeeds     10times    30s    KW.ClearIPsecTunnel
    log to console    PreparePnPPlan end
KW.PrepareFDSWNewOnServer
    log to console    PrepareFDSWNewOnServer start
    ${res}    Run Keyword And Ignore error    KW.ConfigFDSWNewOnCMServer
    Run Keyword If   '${res[0]}'!='PASS'    log   Config FDSWNew On CMServer Failed
    log to console    PrepareFDSWNewOnServer end
KW.InstallOldAndActive
    log to console    InstallOldAndActive start
    Run Keyword And Ignore error    KW.StopDHCP
    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF
    log to console    YAFT After Stop DHCP and delete NCF
    KW.YaftFDSW    filename=${FDSWOLD}_release_BTSSM_downloadable.zip
    ${con}=    FDSW.Connect

    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF
    log to console    YAFT After Stop DHCP and delete NCF
    KW.YaftFDSW    filename=${FDSWOLD}_release_BTSSM_downloadable.zip
    ${con}=    FDSW.Connect

    Set Suite Variable    ${PNPState}    FDSWOldactive
    log to console    InstallOldAndActive start
KW.IdentifyOld
    [Arguments]   ${mode}=DHCPv4None
    log to console    IdentifyOld start
    Run Keyword If    '${PNPState}'!='FDSWOldactive'    Fail    PnP is not FDSWOldactive.
    Run Keyword If    ${mode.count("DHCP")} > 0    KW.ReStartDHCP    mode=${mode}
    ...    ELSE    KW.SetACParametersViaWebUI      mode=${mode}    protocol=NE3S
    ${con}    Run Keyword If    ${mode.count("DHCP")} > 0    FDSW.Connect
    ...    ELSE    set variable    ${FDSWCONN}
    #log to console    Reset PnP
    #FDSW.ResetParameters    con=${con}
    @{keys}    Create List    IP_connectivity
    @{values}    Create List    Succeeded
    Wait until keyword succeeds   30min    5s    FDSW.CheckKeyValue    keys=${keys}   values=${values}   con=${con}
    Set Suite Variable    ${PNPState}    oldDHCPDiscovered
    @{keys}    Create List      Connection_to_Identification_Entity
    @{values}    Create List    Connected
    Wait until keyword succeeds   30min    5s    FDSW.CheckKeyValue    keys=${keys}   values=${values}   con=${con}
    Set Suite Variable    ${PNPState}    oldidentified
    log to console    IdentifyOld end
KW.DownloadNewAndActive
    Run Keyword If    '${PNPState}'!='oldidentified'    Fail    PnP is not oldidentified.
    log to console    DownloadNewAndActive start
    ${con}=    FDSW.Connect
    @{keys}    Create List    Connection_to_Identification_Entity    Software_download
    @{values}    Create List    Connected    Successful
    Wait until keyword succeeds   60min    5s    FDSW.CheckKeyValue    keys=${keys}   values=${values}   con=${con}
    Wait until keyword succeeds   20min    20s    gNB.CheckgNBReset
    #-------FDSW New--------
    ${con}=    FDSW.Connect
    ${sw}    FDSW.GetActiveSWversion   con=${con}
    Should be equal    ${sw}    ${FDSWNEW}
    Set Suite Variable    ${PNPState}    FDSWnewactive
    log to console    DownloadNewAndActive end
KW.InstallNewAndActive
    log to console    InstallNewAndActive start
    Run Keyword And Ignore error    KW.StopDHCP
    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF
    log to console    YAFT After Stop DHCP and delete NCF
    KW.YaftFDSW    filename=${FDSWNEW}_release_BTSSM_downloadable.zip
    ${con}=    FDSW.Connect
    FDSW.SetBTSID    ${MO_BTS_NAME}    ${con}

    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF
    log to console    YAFT After Stop DHCP and delete NCF
    KW.YaftFDSW    filename=${FDSWNEW}_release_BTSSM_downloadable.zip
    ${con}=    FDSW.Connect
    FDSW.SetBTSID    ${MO_BTS_NAME}    ${con}
    #FDSW.ResetParameters    con=${con}
    Set Suite Variable    ${PNPState}    FDSWnewactive
    log to console    InstallNewAndActive end
KW.SetParameterOnFDSWNew
    [Arguments]   ${mode}=DHCPv4None
    Run Keyword If    '${PNPState}'!='FDSWnewactive'    Fail    PnP is not FDSWnewactive.
    #Set Suite Variable    ${PNPState}    identifying
    Run Keyword If    ${mode.count("DHCP")} > 0    KW.ReStartDHCP   mode=${mode}
    ...    ELSE    KW.SetACParametersViaWebUI      mode=${mode}      protocol=NE3S
KW.IdentifyNew
    [Arguments]   ${mode}=DHCPv4None
    log to console    IdentifyNew start
    Run Keyword If    '${PNPState}'!='FDSWnewactive'    Fail    PnP is not FDSWnewactive.
    Set Suite Variable    ${PNPState}    identifying
    Wait until keyword succeeds   30min    5s    KW.IdentifyNewWithRetry
    Set Suite Variable    ${PNPState}    identified
    log to console    IdentifyNew end
KW.IdentifyNewWithRetry
    ${con}    FDSW.Connect
    @{keys}    Create List    Connection_to_Identification_Entity
    @{values}    Create List    identified
    FDSW.CheckKeyValue    keys=${keys}   values=${values}   con=${con}
KW.DownloadTargetSWAndActive
    Run Keyword If    '${PNPState}'!='identified'    Fail    PnP is not identified.
    log to console    DownloadTargetSWAndActive start
    ${con}=    FDSW.Connect
    @{keys}    Create List    Connection_to_Identification_Entity    Software_download
    @{values}    Create List    identified    succeeded
    Wait until keyword succeeds   90min    5s    FDSW.CheckKeyValue    keys=${keys}   values=${values}   con=${con}
    Set Suite Variable    ${PNPState}    SoftwareDownloaded
    Run Keyword If    '${PNPState}'!='SoftwareDownloaded'    Fail    PnP is not SoftwareDownloaded.
    Wait until keyword succeeds   20min    20s    gNB.CheckgNBReset
    #Run Keyword And Ignore error    KW.ClearIPsecTunnel
    Set Suite Variable    ${PNPState}    RestartWithTargetSW
    log to console    DownloadTargetSWAndActive end
KW.Commission
    Run Keyword If    '${PNPState}'!='RestartWithTargetSW'    Fail    PnP is not RestartWithTargetSW.
    log to console    Commission start
    #KW.ClearIPsecTunnel
    Wait until keyword succeeds   10min    20s    gNB.PingOAM
    Wait until keyword succeeds   30min    20s    gNB.CheckgNBReset
    Wait until keyword succeeds   10min    20s    gNB.PingOAM
    Wait until keyword succeeds   30min    60s    KW.CheckCommissioned
    Set Suite Variable    ${PNPState}    BTSCommissioned
    log to console    Commission end
KW.PreparePnPPlan
    [Arguments]   ${method}=SN    ${mode}=DHCPv4None
    log to console    PreparePnPPlan start
    return from keyword if    '${PlanState}'=='skipPlanConfigured'
#    return from keyword if    '${PlanMode}'='${method}${protocol}'
    Should contain any    ${PNPState}    FDSWOldactive    FDSWnewactive
    Run Keyword If   ${mode.count("v4")} > 0   Run    cp ${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml ${LOG_PATH}/PnP_Plan.xml
    ...    ELSE    Run    cp ${CFGFILE_PATH}/PnP_Plan_V6_${STREAM}.xml ${LOG_PATH}/PnP_Plan.xml
    Basic.SedReplaceLine    plannedSWReleaseVersion
    ...    \\<p name=\\"plannedSWReleaseVersion\\"\\>${TARGETSWNAME}\\<\\/p\\>
    ...    ${LOG_PATH}/PnP_Plan.xml
    Basic.SedReplaceLine    btsName
    ...    \\<p name=\\"btsName\\"\\>5G_PNP_HZIV_SG1_${MO_BTS_NAME}\\<\\/p\\>
    ...    ${LOG_PATH}/PnP_Plan.xml
    Run Keyword If    '${method}'!='SN'    Basic.SedReplaceLine    AutoConnHWID
    ...    \\<p name=\\"AutoConnSiteID\\"\\>${MO_BTS_NAME}\\<\\/p\\>
    ...    ${LOG_PATH}/PnP_Plan.xml
    log to console    Start NetAct NE deletion
    NetAct.Login    url=${HZ_NETACT_URL}
    ...    username=${HZ_NETACT_USER}   password=${HZ_NETACT_PASSWORD}
    NetAct.StartApp  app_name=CM Operations Manager
    #Run Keyword And Ignore error     NetAct.CMOperationManager.Resetautoconnection    name=TA_PnP_TL11
    NetAct.CMOperationManager.NEDelete     BTSMO=PLMN-PLMN/${MO_BTS_NAME}
    #Run Keyword And Ignore error     NetAct.CMOperationManager.DeletePlan   name=TA_PnP_TL11
    log to console    Start Create New Plan
    NetAct.CMOperationManager.CreatAndValidatePnPPlan   filename=${LOG_PATH}/PnP_Plan.xml   PlanName=TA_PnP_${MO_BTS_NAME}
    Set Suite Variable    ${PlanState}    PlanConfigured
    log to console    PreparePnPPlan end
#    Set Suite Variable    ${PlanMode}    ${method}${protocol}
KW.SetACParametersViaWebUI
#Manualv4None Manualv6None   Manualv4CA    Manualv6CA
    [Arguments]     ${mode}=v4None    ${protocol}=LEGACY
    log to console    SetACParametersViaWebUI start
#    ${certificateServerParameters}    Create Dictionary    directory=
#    ...    ipAddress=    serverPort=    subjectName=    vpnGatewayIpAddress=
#    ${certificateServerParametersNone}    Create Dictionary    directory=
#    ...    ipAddress=    serverPort=    subjectName=    vpnGatewayIpAddress=
#    ${managementPlaneParameters}    Create Dictionary    ipAddress=
#    ...    gateway=    prefixLength=     omsIpAddress=
#    ${section}    set variable if    ${mode.count("v4")} > 0    SectionGNB    SectionGNBIPv6
#
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    ASIK_IP
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${managementPlaneParameters}    ipAddress=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    PrefixLen
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${managementPlaneParameters}    prefixLength=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    Gateway
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${managementPlaneParameters}    gateway=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    IdentifyIP
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${managementPlaneParameters}    omsIpAddress=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    CMPServer
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${certificateServerParameters}    ipAddress=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    CMPPort
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${certificateServerParameters}    serverPort=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    CMPSubject
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${certificateServerParameters}    subjectName=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    CMPDir
#    Run Keyword If   '${value[0]}'=='PASS'   Set To Dictionary    ${certificateServerParameters}    directory=${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    ${section}    VNPGateway
#    Run Keyword If   '${value[0]}'=='PASS' and ${mode.count("IPsec")} > 0
#    ...    Set To Dictionary    ${certificateServerParameters}    vpnGatewayIpAddress=${value[1]}
#
#    ${certificateServerParametersInuse}    set variable if     ${mode.count("CA")} > 0     ${certificateServerParameters}
#    ...    ${certificateServerParametersNone}
#    ${certificateServerParametersInuse}    set variable if     ${mode.count("IPsec")} > 0     ${certificateServerParameters}
#    ...    ${certificateServerParametersInuse}
#
#    ${params}    Create Dictionary    certificateServerParameters=${certificateServerParametersInuse}
#    ...    managementPlaneParameters=${managementPlaneParameters}
#    Log Dictionary    ${certificateServerParametersInuse}
#    Log Dictionary    ${params}
    &{IPs}    Create Dictionary    primary_ip_address=${None}  primary_prefix_length=${None}  primary_gateway=${None}
    ...    identification_entity_ip_address=${None}  primary_vlan_id=${None}
    ...    secondary_ip_address=${None}  secondary_prefix_length=${None}  secondary_vlan_id=${None}
    &{Security}    Create Dictionary    CMPServer=${None}  CMPPort=${None}  CMPSubject=${None}  CMPDir=${None}  VNPGateway=${None}
    &{parameters}    Create Dictionary   protocol=${protocol}    IPs=${IPs}     Security=${Security}
    Run Keyword If   ${mode.count("v4")} > 0
    ...   Set To Dictionary     ${parameters}
    ...   IPs=${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv4']}
    ...    ELSE    Set To Dictionary     ${parameters}    IPs=${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv6']}
    Run Keyword If   ${mode.count("CA")} > 0 and ${mode.count("v4")} > 0
    ...   Set To Dictionary     ${parameters}
    ...   Security=${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv4CATLS']}
    Run Keyword If   ${mode.count("CA")} > 0 and ${mode.count("v6")} > 0
    ...   Set To Dictionary     ${parameters}
    ...   Security=${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv6CATLS']}
    log to console    ${parameters}

    ${con}=    FDSW.Connect
    Set Suite Variable    ${FDSWCONN}    ${con}
#    FDSW.EnableSSH    con=${con}
    log to console    DHPC Less Mode Test
    ##change another way to set auto connection  parameters
    FDSW.SetParameters    con=${con}    parameters=${parameters}
     #fdsw_oam_extend.set_autoconnection_userparams   conn=${con}    params=${params}    protocol=${protocol}
#    @{keys}    Create List    IP_connectivity    DHCP_Server_Connection
#    @{values}    Create List    succeeded    skipped
#    Wait until keyword succeeds   6min    5s    FDSW.CheckKeyValue  keys=${keys}   values=${values}   con=${con}
    log to console    SetACParametersViaWebUI end
KW.ConfigCACert
    [Arguments]     ${mode}=None
    return from keyword if    '${CAConfigured}'=='skipCAConfigured'
    log to console    ConfigCACert
    ${tls}    Set Variable If    ${mode.count("CA")} > 0    true    false
    run keyword if    '${tls}'=='false'    log to console     No need to configure CA TLS=off
    return from keyword if    '${tls}'=='false'
    ${cert}    Set Variable If    ${mode.count("v6")} > 0    kungfuIPV6    kungfu1216
    ${IP}     KW.GetVMNodeByService
    ${cmd}    set variable    ./smcert_apply_certificate.sh --systemName ${cert} --usecaseName
    ${asccon}  ${ascch}    ShellConnectAndInvokeShell    ip=${IP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    port=22

    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} netact_webapps\n    timeout=60
    should contain    ${result}    Enter Y
    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=y\n    timeout=120
    should contain    ${result}    Certificate configuration was successful

    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} dirsrv_access\n    timeout=60
    should contain    ${result}    Enter Y
    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=y\n    timeout=300
    should contain    ${result}    Certificate configuration was successful

    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} ne3sws\n    timeout=80
    should contain    ${result}    Enter Y
    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd=y\n    timeout=330
    should contain    ${result}    Certificate configuration was successful

#    ${result}    ShellExecuteCommand   ${ascch}    cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} dirsrv_access\n    30
#    should contain    ${result}    Enter Y
#    ${result}    ShellExecuteCommand   ${ascch}    y\n    120
#    should contain    ${result}    Certificate configuration was successful
#
#    ${result}    ShellExecuteCommand   ${ascch}    cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} ne3sws\n    30
#    should contain    ${result}    Enter Y
#    ${result}    ShellExecuteCommand   ${ascch}    y\n    120
#    should contain    ${result}    Certificate configuration was successful
    ShellDisconnect    ${asccon}
    #Conn.ConnectTo  IP=${IP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    alias=CMServer
    #Conn.Execute  cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} netact_webapps     alias=CMServer
    #Conn.Execute  cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} dirsrv_access     alias=CMServer
    #Conn.Execute  cmd=cd /opt/oss/NSN-sm_conf_cert/bin &&${cmd} ne3sws     alias=CMServer
#    Conn.Execute  cmd=./smcert_apply_certificate.sh --systemName ${cert} --usecaseName netact_webapps    alias=CMServer
#    Conn.Execute  cmd=./smcert_apply_certificate.sh --systemName ${cert} --usecaseName dirsrv_access    alias=CMServer
#    Conn.Execute  cmd=./smcert_apply_certificate.sh --systemName ${cert} --usecaseName ne3sws    alias=CMServer
    #Conn.Disconnect  alias=CMServer
    log to console    ConfigCACert ${cert} end
KW.GetVMNodeByService
    [Arguments]     ${service}=dmgr
    Conn.ConnectTo  IP=${CMSERVERIP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    alias=CMServer
    ${res}    Conn.Execute  cmd=smanager.pl status service ${service}  alias=CMServer
    ${NodeService}   ${Node}    ${status}    Split String From Right    string=${res}   separator=:     max_split=2
    ${res}    Conn.Execute  cmd=cat /etc/hosts|grep ${Node}|grep 10.    alias=CMServer
    ${IP}   ${left}    Split String    string=${res}   separator=${SPACE}     max_split=1
    Conn.Disconnect  alias=CMServer
    [Return]    ${IP}
KW.ClearIPsecTunnel
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    SectionGNB    IPSECSERVER
#    Run Keyword If   '${value[0]}'=='PASS'   set global variable    ${IPSECSERVER}    ${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    SectionGNB    IPSECUSER
#    Run Keyword If   '${value[0]}'=='PASS'   set global variable    ${IPSECUSER}    ${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    SectionGNB    IPSECPASSWD
#    Run Keyword If   '${value[0]}'=='PASS'   set global variable    ${IPSECPASSWD}    ${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    SectionGNB    ASIK_IP
#    Run Keyword If   '${value[0]}'=='PASS'   set global variable    ${ASIK_IP_IPV4}    ${value[1]}
#    ${value}    Run Keyword And Ignore error  config.getvalue    ${CFGFILE_PATH}TA.ini    SectionGNBIPv6    ASIK_IP
#    Run Keyword If   '${value[0]}'=='PASS'   set global variable    ${ASIK_IP_IPV6}    ${value[1]}

    ${asccon}  ${ascch}    ShellConnectAndInvokeShell    ip=${IPSECSERVER}    username=${IPSECUSER}    password=${IPSECPASSWD}   port=22
    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd= show router 9 route-table ipv6\n    timeout=5
    log to console     ${result}
    ${result}    ShellExecuteCommand   ascch=${ascch}    cmd= show router 9 route-table ipv4\n    timeout=5
    log to console     ${result}
    ShellExecuteCommand   ascch=${ascch}    cmd= clear ipsec gateway name Gaoliang tunnel ${ASIK_IP_IPV4}:500\n    timeout=5
    ShellExecuteCommand   ascch=${ascch}
    ...         cmd= clear ipsec gateway name "Gaoliang-v6" tunnel [${ASIK_IP_IPV6}]:500\n    timeout=5
    ${result_1}    ShellExecuteCommand   ascch=${ascch}    cmd= show router 9 route-table ipv6\n    timeout=5
    log to console     ${result_1}
    ${result_2}    ShellExecuteCommand   ascch=${ascch}    cmd= show router 9 route-table ipv4\n    timeout=5
    log to console     ${result_2}
    ShellDisconnect    ${asccon}
    ${ASIK_IP_IPV6_Byte}=   Encode String To Bytes   ${ASIK_IP_IPV6}   UTF-8
    ${ASIK_IP_IPV4_Byte}=   Encode String To Bytes   ${ASIK_IP_IPV4}   UTF-8
    should not contain    ${result_1}    ${ASIK_IP_IPV6_Byte}
    should not contain    ${result_2}    ${ASIK_IP_IPV4_Byte}
#    Conn.ConnectTo  IP=10.57.143.155    username=admin    password=admin    alias=CMServer
#    Conn.Execute  cmd=clear ipsec gateway name Gaoliang tunnel 10.57.251.188:500\n  alias=CMServer
##    Conn.Execute  cmd=clear ipsec gateway name "Gaoliang-v6" tunnel [2a00:8a00:8000:136:10:57:251:105]:500  alias=CMServer
#    Conn.Disconnect  alias=CMServer
#    [Return]    ${IP}
KW.ConfigFDSWNewOnCMServer
    log to console    ConfigFDSWNewOnCMServer start
    return from keyword if    '${CMServerState}'=='FDSWNewConfiguredOnCMServer'
    Conn.ConnectTo  IP=${CMSERVERIP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    alias=CMServer
    Conn.Execute  cmd=cd /var/opt/oss/Nokia-pnpcompatibility/httpDocRoot && rm -rf ${FDSWNEW} && mkdir ${FDSWNEW}   alias=CMServer
    Conn.UploadFile  local_path=${UPDATE_FILE_PATH}/${FDSWNEW}_release_BTSSM_downloadable.zip
    ...    remote_path=/var/opt/oss/Nokia-pnpcompatibility/httpDocRoot/${FDSWNEW}/${FDSWNEW}_release_BTSSM_downloadable.zip
    ...    alias=CMServer
    Conn.Execute  cmd=cd /var/opt/oss/Nokia-pnpcompatibility/httpDocRoot/${FDSWNEW} && unzip ${FDSWNEW}_release_BTSSM_downloadable.zip
    ...    alias=CMServer
    Conn.Execute  cmd=chown -R cmcompsrv:sysop /var/opt/oss/Nokia-pnpcompatibility/    alias=CMServer
    Conn.Execute  cmd=cp /etc/opt/oss/Nokia-pnpcompatibility/custom/conf/pnpcompatibility-conf.ini ~/pnpcompatibility-conf.ini
    ...    alias=CMServer
    Conn.Execute  cmd=/opt/oss/Nokia-pnpcompatibility/bin/set_custom_property.sh TlsMode off    alias=CMServer
    Conn.Execute  cmd=/opt/oss/Nokia-pnpcompatibility/bin/set_custom_property.sh FDSW ${FDSWNEW}    alias=CMServer
#    Conn.Execute  cmd=cp ~/pnpcompatibility-conf.ini /etc/opt/oss/Nokia-pnpcompatibility/custom/conf/pnpcompatibility-conf.ini
#    ...    alias=CMServer
    Conn.Execute  cmd=smanager.pl stop service pnp_compatibility    alias=CMServer
#    ${result}    Conn.Execute  cmd=systemctl status pnp_compatibility    alias=CMServer
    Conn.Execute  cmd=smanager.pl start service pnp_compatibility    alias=CMServer
    ${result}    Conn.Execute  cmd=smanager.pl status service pnp_compatibility    alias=CMServer
    should contain     ${result}    started
    Conn.Disconnect  alias=CMServer
    Set Suite Variable    ${CMServerState}    FDSWNewConfiguredOnCMServer
    log to console    ConfigFDSWNewOnCMServer end
KW.CheckCommissioned
    KW.CaseDestroy
    COAM.login
    ${btsname}    selenium_coam.get_bts_name
    log to console    btsname=${btsname}
    Should be true    ${btsname.count("${MO_BTS_NAME}")} > 0
    COAM.Logout
KW.DeleteNCF
    Conn.ConnectTo  IP=${ASIK_IP}  username=${ASIK_USERNAME}  password=${ASIK_PASSWORD}    alias=ASIK
    Conn.Execute  cmd=mount -o rw,remount /ffs/fs2    alias=ASIK
    Conn.Execute  cmd=mount -o rw,remount /ffs/fs1    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/NCF.xml    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/NCF.xml    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/tmp_NCF.xml    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/tmp_NCF.xml    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/oamPnpReport.log    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/oamPnpReport.log    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/trsAutoconnReport.log    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/trsAutoconnReport.log    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/ne3sadapt/configs/ne3sadaptdata.db    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs1/config/ne3sadapt/managers    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs1/config/ne3sadapt    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/ne3sadapt/configs/ne3sadaptdata.db    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs2/config/ne3sadapt/managers    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs2/config/ne3sadapt    alias=ASIK
    Conn.Execute  cmd=rm -rf /ram/tmp/certificates/*    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs1/trs_data/active/keystorage/certs/*    alias=ASIK
    Conn.Execute  cmd=rm -rf /ffs/fs2/trs_data/active/keystorage/certs/*    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/envdata -rf    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/envdata -rf    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs1/config/*.*    alias=ASIK
    Conn.Execute  cmd=rm /ffs/fs2/config/*.*    alias=ASIK
    Conn.Execute  cmd=rm /ffs/stb/config/* -rf    alias=ASIK
    Run Keyword If   '${BOARD}'=='ASIL'    Conn.Execute  cmd=rm /usr/bin/soc-update-info    alias=ASIK

    #Conn.Execute  cmd=rm /ffs/run/config/*NCF* -rf    alias=ASIK
    Conn.Disconnect  ASIK
#    sshservice.setup    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    host=${ASIK_IP}
#    sshservice.deleteNCF
KW.StopDHCP
    log to console    stop dhcp start
    ssh.Connect to    hostname=${CMSERVERIP}    username=${CMSERVERUSER}
    ...               password=${CMSERVERPWD}     alias=NetActServer
    ${cmd}=  Catenate    /opt/cpf/bin/cpfdhcp_operation.py --disable && /opt/cpf/bin/cpfdhcp_operation.py --status
    ${out}    Conn.Execute    cmd=${cmd}    alias=NetActServer
    Should Contain Any    ${out}    Status of DHCPv4 service is disabled     Status of DHCPv6 service is disabled
    Conn.Disconnect     alias=NetActServer
    log to console    stop dhcp end

KW.ReStartDHCP
    #DHCPv4None    DHCPv4TLS    DHCPv4IPsec    DHCPv6None    DHCPv6TLS    DHCPv6IPsec
    [Arguments]   ${mode}=None
    log to console    ReStartDHCP start
    ssh.Connect to    hostname=${CMSERVERIP}    username=${CMSERVERUSER}
    ...               password=${CMSERVERPWD}     alias=NetActServer
    ${cmd}=  Catenate    cd /etc/dhcp/config.d/ &&
    ...     /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op updatePnpDhcpConfiguration -ipVersion IPV4
    ...     -configurationFileName dhcpv4.json &&
    ...     /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op updatePnpDhcpConfiguration -ipVersion IPV6
    ...     -configurationFileName dhcpv6.json
    Conn.Execute    cmd=${cmd}    alias=NetActServer
    ${cmd}=  Catenate    /opt/cpf/bin/cpfdhcp_operation.py --disable && /opt/cpf/bin/cpfdhcp_operation.py --status
    ${out}    Conn.Execute    cmd=${cmd}    alias=NetActServer
    Should Contain Any    ${out}    Status of DHCPv4 service is disabled     Status of DHCPv6 service is disabled
    Run Keyword If    '${mode}'=='DHCPv4None'    KW.DisableDHCPv6ANDEnableDHCPv4
    ...    ELSE IF    '${mode}'=='DHCPv6None'    KW.DisableDHCPv4ANDEnableDHCPv6
    Conn.Disconnect     alias=NetActServer
    log to console    ReStartDHCP end
KW.DisableDHCPv6ANDEnableDHCPv4
    [Arguments]
    ${cmd}=  Catenate    cd /etc/dhcp/config.d/ && mv PnP_IPv6.conf PnP.conf
    Conn.Execute    cmd=${cmd}    alias=NetActServer
    ${cmd}=  Catenate    /opt/cpf/bin/cpfdhcp_operation.py --enable && /opt/cpf/bin/cpfdhcp_operation.py --status
    ${out}    Conn.Execute    cmd=${cmd}    alias=NetActServer
    Should Contain Any     ${out}    Status of DHCPv4 service is enabled     Status of DHCPv6 service is disabled
KW.DisableDHCPv4ANDEnableDHCPv6
    [Arguments]
    ${cmd}=  Catenate    cd /etc/dhcp/config.d/ && mv PnP_IPv4.conf PnP.conf
    Conn.Execute    cmd=${cmd}    alias=NetActServer
    ${cmd}=  Catenate    /opt/cpf/bin/cpfdhcp_operation.py --enable && /opt/cpf/bin/cpfdhcp_operation.py --status
    ${out}    Conn.Execute    cmd=${cmd}    alias=NetActServer
    Should Contain Any     ${out}    Status of DHCPv6 service is enabled     Status of DHCPv4 service is disabled

KW.FDSW.EnableSSH
    ${con}    FDSW.Connect
    FDSW.EnableSSH    ${con}
    FDSW.DisConnect
KW.COAM.EnableSSH
    COAM.Login
    COAM.EnableSSH
    COAM.Logout
KW.TryEnableSSH
    ${value}    Run Keyword And Ignore error    ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}
    ...    password=${ASIK_PASSWORD}     alias=${ALIAS_ASIK}
    Run Keyword And Ignore error    Conn.Disconnect    alias=${ALIAS_ASIK}
    Return From Keyword if    '${value[0]}'=='PASS'
    ${value}    Run Keyword And Ignore error    KW.FDSW.EnableSSH
    Return From Keyword if    '${value[0]}'=='PASS'
    ${value}    Run Keyword And Ignore error    KW.COAM.EnableSSH
    Return From Keyword if    '${value[0]}'=='PASS'
    Fail    Enable ssh failed.
KW.YAFT
    [Arguments]    ${filename}=AS__*.zip
    ${gNBSoftwareFile}=  run  ls ${UPDATE_FILE_PATH}/${filename}
    Should Not Be Empty   ${gNBSoftwareFile}
    log   ${gNBSoftwareFile}
    ${yaft_command}    Set Variable If   '${BOARD}'=='ASIL'
    ...    cd ${YAFT_PATH} &&sudo python ./yaft.py -i ${ASIK_IP} -z ${gNBSoftwareFile} -K --ignore_FSPs
    ...    cd ${YAFT_PATH} &&sudo python ./yaft.py -i ${ASIK_IP} -z ${gNBSoftwareFile} -K --ignore_FSPs
    log  ${yaft_command}
    ${result}  run  ${yaft_command}
    Should Contain Any   ${result}   Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot
KW.YaftFDSW
    [Arguments]   ${filename}    ${YAFT_PATH}=/opt/ute/5GC000092/YAFT
    ${gNBSoftwareFile}=  run  ls ${UPDATE_FILE_PATH}/${filename}
    Should Not Be Empty   ${gNBSoftwareFile}
    log   ${gNBSoftwareFile}
    ${res}    Run Keyword And Ignore error    SoftwareUpdate.YAFT   filepath=${gNBSoftwareFile}    YAFT_PATH=${YAFT_PATH}
#    Run Keyword If   '${res[0]}'!='PASS'    Power.ResetgNB
    Run Keyword If   '${res[0]}'!='PASS'    Sleep   300
    KW.TryEnableSSH
##    Run Keyword If   '${res[0]}'!='PASS'    Run Keyword And Ignore error    KW.FDSW.EnableSSH
    Run Keyword If   '${res[0]}'!='PASS'    Run keywords
    ...    Run Keyword And Ignore error    gNB.ModifySSHDConfig
    ...    AND    SoftwareUpdate.YAFT   filepath=${gNBSoftwareFile}    YAFT_PATH=${YAFT_PATH}
#KW.CheckAutoConnectionStatus
#    [Arguments]   ${KeyValue}
#    Conn.ConnectTo  IP=${ASIK_IP}  username=${ASIK_USERNAME}  password=${ASIK_PASSWORD}    alias=ASIK
#    Wait until keyword succeeds     40min    30sec  KW.CheckAutoConnection    KeyValue=${KeyValue}
#    Conn.Disconnect  ASIK
#KW.CheckAutoConnection
#    [Arguments]   ${KeyValue}
#    ${result}    Conn.Execute    cmd=cat /ffs/run/config/trsAutoconnReport.log    ASIK
#    Should Contain  ${result}   ${KeyValue}
KW.CaseInit
    Log to Console    KW.CaseInit
    TestCase.Start
KW.CaseDestroy
    Log to Console    KW.CaseDestroy
    Run Keyword And Ignore error    KW.StopDHCP
    Run Keyword And Ignore error    COAM.Logout
    Run Keyword And Ignore error    NetAct.Logout
    Run Keyword And Ignore error    FDSW.DisConnect
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
    Run Keyword And Ignore error   TestCase.Stop
KW.DownloadPackage
    [Arguments]   ${FDSWOLD}=LN_WN_FDSW19_0000_000117_000000    ${FDSWNEW}=LN_WN_FDSW19_0000_000117_000000    ${BTSSW}=6.8351.1231
    return from keyword if    '${PackageDownloadStatus}'=='prepared'
    log to console    DownloadPackage start
    run     rm ${UPDATE_FILE_PATH}/*.zip
    run     rm ${UPDATE_FILE_PATH}/*.zip.md5
    WFT.DownloadPackage   link_to_Artifact=${FDSWServerPath}   filename=${FDSWOLD}_release_BTSSM_downloadable.zip
    ...    UPDATE_FILE_PATH=${UPDATE_FILE_PATH}
    WFT.DownloadPackage   link_to_Artifact=${FDSWServerPath}   filename=${FDSWNEW}_release_BTSSM_downloadable.zip
    ...    UPDATE_FILE_PATH=${UPDATE_FILE_PATH}
#    WFT.DownloadPackage   link_to_Artifact=${BTSSWServerPath}/${TARGETSW}   filename=${FILENAME}   md5=true
#    ...    UPDATE_FILE_PATH=${UPDATE_FILE_PATH}
    SoftwareUpdate.DownloadPackageFromWFT    build_version=${TARGETSW}
    Set Suite Variable    ${PackageDownloadStatus}    prepared
KW.GetTargetBDVersion
    run   rm -rf ${UPDATE_FILE_PATH}/BTSSW
    run   mkdir ${UPDATE_FILE_PATH}/BTSSW
    run   cd ${UPDATE_FILE_PATH}&&unzip ${FILENAME} -d ${UPDATE_FILE_PATH}/BTSSW
   #run  cd ${UPDATE_FILE_PATH}&&rm bts_sw -rf&&rm btsmed* -rf&&rm *.xml -rf&&rm *.json -rf
    #run  cd ${UPDATE_FILE_PATH}&&rm *pdl_validation_service_plugin.zip -rf&&unzip ${FILENAME}
    ${res}    run    cd ${UPDATE_FILE_PATH}/BTSSW/bts_sw/ && ls TargetBD*.xml
    ${res}	Replace String	${res}   TargetBD_    ${EMPTY}
    ${res}	Replace String	${res}   .xml    ${EMPTY}
    Set Suite Variable    ${TARGETSWNAME}    ${res}
    run    rm -rf ${UPDATE_FILE_PATH}/BTSSW
    run    mv ${UPDATE_FILE_PATH}/${FILENAME} ${UPDATE_FILE_PATH}/${TARGETSWNAME}.zip
    log to console    DownloadPackage end
KW.UploadPackage
    [Arguments]   ${FDSWNEW}=LN_WN_FDSW19_0000_000117_000000    ${BTSSW}=6.8351.1231
    log to console    UploadPackage start
    NetAct.SWM.Open
#    ${resultFdsw}    NetAct.SWM.Upload    Path=${UPDATE_FILE_PATH}/${FDSWNEW}_release_BTSSM_downloadable.zip
#    Set Suite Variable    ${DeleteFDSW}    ${resultFdsw}
    ${resultBTSSW}    NetAct.SWM.Upload    Path=${UPDATE_FILE_PATH}/${TARGETSWNAME}.zip
    Set Suite Variable    ${DeleteBTSSW}    ${resultBTSSW}
    run keyword if     '${DeleteBTSSW}'=='Failed'    KW.SWMDeleteTempFile
    run keyword if     '${DeleteBTSSW}'=='Failed'    Fail    upload package failed.
    log to console    UploadPackage end
KW.SWMDeleteTempFile
    Conn.ConnectTo  IP=${SWMSERVERIP}  username=${CMSERVERUSER}  password=${CMSERVERPWD}    alias=swmserver
    Conn.Execute  cmd=rm /d/oss/global/swmanager/swm_temp/${TARGETSWNAME}* -rf    alias=swmserver
    Conn.Execute  cmd=rm /var/opt/nokia/oss/global/swm/swm_arch/${TARGETSWNAME}* -rf    alias=swmserver
    #Conn.Execute  cmd=rm /ffs/run/config/*NCF* -rf    alias=ASIK
    Conn.Disconnect  swmserver
KW.UploadPlugin
    [Arguments]    ${version}
    return from keyword if    '${BTSMED}'!='TRUE'
    log to console    UploadPlugin start
    NetAct.Login    url=${HZ_NETACT_URL}   username=${HZ_NETACT_USER}   password=${HZ_NETACT_PASSWORD}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.StartApp  app_name=CM Editor
    NetAct.SelectCMEditor
    NetAct.CM.OpenPlan  name=TA_TL9991_DoNotDelete
    NetAct.CM.SetPluginVersion    name=TA_TL9991_DoNotDelete    version=${version}    node=MRBTS-9991
    NetAct.SelectCMOperationManager
    NetAct.CMOperationManager.PreActiveNewPlan    name=TA_TL9991_DoNotDelete
    log to console    UploadPlugin stop
#KW.PreparePackages
#    ${value}    Run Keyword And Ignore error    KW.PackagePrepareAndUpload
#    Run Keyword If   '${value[0]}'!='PASS'    Set Suite Variable    ${TARGETSW}    6.8351.1296
#KW.CkeckTargetSW
#    COAM_ADMIN.connect_to    bts_host=192.168.255.129
#    ${sw}    COAM_ADMIN.get_sw_version
#    ${alarm}    COAM_ADMIN.get_active_alarms
#    COAM_ADMIN.teardown
#    ${sw}    Replace String    ${sw}    0    ${EMPTY}
#    ${rl}    ${sw1}    ${sw2}    ${sw3}    Split String From Right    string=${sw}   separator=_     max_split=3
#    ${sw}    Catenate    SEPARATOR=.    ${sw1}    ${sw2}    ${sw3}
#    ${count}    Evaluate    len(@{alarm})
#    Should Be True    '${count}'=='0'
#    Should Be True    '${sw}'=='${TARGETSW}'
#KW.SeTIMOSIPandCheckRestartAC
#    [Arguments]   ${con}
#    @{checkkey}    Create List    secondsToRestart    omsIpAddress
#    ${res}=    fdsw_oam_extend.fetch_value_by_checkkey    conn=${con}    checkkeys=@{checkkey}
#    Run keyword if    '${res[1]}'=='${NETACT_LOGSERVER_IP}'    KW.SetACChanges    con=${con}    protocol=NE3S
#    Wait until keyword succeeds    5min    30s    KW.GetReststartTime    con=${con}    checkkey=@{checkkey}
#    ${res}=    fdsw_oam_extend.fetch_value_by_checkkey    conn=${con}    checkkeys=@{checkkey}
#    ${sleeptime}    Set Variable If    ${res[0]-20}>10    ${res[0]-20}    ${res[0]}
#    Sleep    ${sleeptime}
#    Wait until keyword succeeds    120s   2s    KW.GetRestartStatus    con=${con}   point=${True}
#    Wait until keyword succeeds    10min   2s    KW.GetRestartStatus    con=${con}   point=${False}
#KW.SetACChanges
#    [Arguments]   ${con}    ${protocol}
#    &{changes}    Create Dictionary     omsIpAddress=10.32.180.31
#    fdsw_oam_extend.set_autoconnection_changes    conn=${con}    changes=${changes}    protocol=${protocol}
#    Sleep    60
#KW.GetReststartTime
#    [Arguments]   ${con}    ${checkkey}
#    ${res}=    fdsw_oam_extend.fetch_value_by_checkkey    conn=${con}    checkkeys=${checkkey}
#    Should Be True    ${res[0]}>0
#KW.GetRestartStatus
#    [Arguments]   ${con}    ${point}
#    @{checkkey}    Create List    secondsToRestart    IP_connectivity
#    ${res}=    fdsw_oam_extend.fetch_value_by_checkkey    conn=${con}    checkkeys=@{checkkey}
#    Run keyword if    '${point}'=='${True}'    Should Be True    '@{res}[0]'=='None'
#    ...    ELSE    Should Be True    @{res}[0]>0
#    Run keyword if    '${point}'=='${True}'    Should Be True    '@{res}[1]'!='succeeded'
#    ...    ELSE    Should Be True    '@{res}[1]'=='succeeded'
#KW.EnableCSserver
#    [Arguments]   ${host}    ${username}    ${password}    ${fdswnew}    ${localpath}    ${remotepath}
#    sshservice.setup    username=${username}    password=${password}    host=${host}
#    sshservice.upload_uzip    filename=${fdswnew}_release_BTSSM_downloadable.zip
#    ...    localpath=${localpath}    remotepath=${remotepath}
#    #EnableCSservercmd
KW.TestSuiteInit
    Log to Console    TestSuilt.Init
    TestSuite.Start
    Basic.CheckVariableValid    var=CASE_INPUT_5GC000092['SectionNETACT']['MR']['$maintenanceRegionId']
    ...                         default_value=NULL
    Basic.CheckVariableValid    var=CASE_INPUT_5GC000092['SectionNETACT']['MR']['$maintenanceRegionCId']
    ...                         default_value=NULL
    Basic.CheckVariableValid    var=CASE_INPUT_5GC000092['SectionGNB']['SN']
    ...                         default_value=NULL

    set suite variable    ${FDSWNEW}                  ${CASE_INPUT_5GC000092['FDSWNEW']}
    set suite variable    ${FDSWOLD}                  ${CASE_INPUT_5GC000092['FDSWOLD']}
    set suite variable    ${IPSECSERVER}              ${CASE_INPUT_5GC000092['IPSECSERVER_INFO']['IPSECSERVERIP']}
    set suite variable    ${IPSECUSER}                ${CASE_INPUT_5GC000092['IPSECSERVER_INFO']['IPSECUSER']}
    set suite variable    ${IPSECPASSWD}              ${CASE_INPUT_5GC000092['IPSECSERVER_INFO']['IPSECPASSWD']}

    set suite variable    ${ASIK_IP_IPV4}             ${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv4']['primary_ip_address']}
    set suite variable    ${ASIK_IP_IPV6}             ${CASE_INPUT_5GC000092['5GC000092_NCF']['ipv6']['primary_ip_address']}
    set suite variable    ${MO_BTS_NAME}              ${CASE_INPUT_5GC000092['SectionGNB']['MRBTS']}
    set suite variable    ${MO_BTS_NAME_1}            ${CASE_INPUT_5GC000092['SectionGNB']['MRBTS_1']}
    set suite variable    ${BTSMED}                   ${CASE_INPUT_5GC000092['SectionGNB']['BTSMED']}

    set suite variable    ${BOARD}                    ${CASE_INPUT_5GC000092['SectionGNB']['BOARD']}
    set suite variable    ${HZ_NETACT_URL}            ${CASE_INPUT_5GC000092['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_URL']}
    set suite variable    ${HZ_NETACT_USER}           ${CASE_INPUT_5GC000092['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_USER']}
    set suite variable    ${HZ_NETACT_PASSWORD}       ${CASE_INPUT_5GC000092['SectionNETACT']['HZ_NETACT_INFO']['HZ_NETACT_PASSWORD']}
    set suite variable    ${CMSERVERIP}               ${CASE_INPUT_5GC000092['SectionNETACT']['CMSERVER_INFO']['CMSERVERIP']}

    set suite variable    ${CMSERVERUSER}             ${CASE_INPUT_5GC000092['SectionNETACT']['CMSERVER_INFO']['CMSERVERUSER']}
    set suite variable    ${CMSERVERPWD}              ${CASE_INPUT_5GC000092['SectionNETACT']['CMSERVER_INFO']['CMSERVERPWD']}
    set suite variable    ${SWMSERVERIP}              ${CASE_INPUT_5GC000092['SectionNETACT']['SWMSERVERIP']}

    set suite variable    ${SWMSERVERIP}              ${CASE_INPUT_5GC000092['SectionNETACT']['SWMSERVERIP']}

    set suite variable    ${MRID}                     ${CASE_INPUT_5GC000092['SectionNETACT']['MR']['$maintenanceRegionId']}
    set suite variable    ${MRCID}                    ${CASE_INPUT_5GC000092['SectionNETACT']['MR']['$maintenanceRegionCId']}
    set suite variable    ${SystemModuleSN}           ${CASE_INPUT_5GC000092['SectionGNB']['SN']}

    Set Suite Variable    ${fdswOld}    LN_WN_FDSW18A_0000_100164_000000
    set global variable    ${FDSWNEW}    ${CASE_INPUT_5GC000092['FDSWNEW']}

    ${PNPStates}    Create list    NotStart    FDSWOldactive    oldDHCPDiscovered    oldidentified    FDSWnewactive
    ...    IPConnectivitied    identifying    identified    SoftwareDownloaded    RestartWithTargetSW    BTSCommissioned
    Set Suite Variable    ${PNPState}    NotStart
    Set Suite Variable    ${PNPStates}    ${PNPStates}
    Set Suite Variable    ${DeleteFDSW}    Failed
    Set Suite Variable    ${DeleteBTSSW}    Failed
    Set Suite Variable    ${PlanState}    NotStart
    Set Suite Variable    ${CMServerState}    NotStart
    Set Suite Variable    ${PackageDownloadStatus}    NotStart
    Set Suite Variable    ${PreparePackageStatus}    NotStart
    Set Suite Variable    ${PlanMode}    NotStart
    Set Suite Variable    ${TLSServiceConfigured}    NotStart
    Set Suite Variable    ${CAConfigured}    NotStart
    Set Suite Variable    ${TlsMode}    false

    ${path}   ${BTSSW}    ${filename}    Split String From Right    string=${AF_PATH}   separator=/     max_split=2
    log to console    afpath:${AF_PATH}
    log to console    path:${path}
    log to console    btssw:${BTSSW}
    log to console    filename:${filename}
    Set Suite Variable    ${TARGETSW}    ${BTSSW}
    Set Suite Variable    ${FILENAME}    ${filename}

#    ${V1}   ${V2}    ${V3}    Split String   string=${TARGETSW}   separator=.
#    ${V1}     Evaluate    "{:0>4d}".format(int(${V1}))
#    Set Suite Variable    ${TARGETSWNAME}    SBTS21B_ENB_0000_001152_000000
#    Set Suite Variable    ${PackageDownloadStatus}    prepared
#    Set Suite Variable    ${PreparePackageStatus}    prepared

    Set Suite Variable    ${CAConfigured}    skipCAConfigured
    Set Suite Variable    ${CMServerState}    FDSWNewConfiguredOnCMServer
    Set Suite Variable    ${TLSServiceConfigured}    TLSServiceConfigured
    ${streamInfo}    Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    Set Suite Variable    ${STREAM}       ${streamInfo['StreamPrefix']}
    Set Suite Variable    ${GoldenSCF}    ${streamInfo['GoldenSCF']}
    log to console    ${STREAM}
    Run Keyword And Ignore error    KW.GeneratePnPPlanFile

KW.GetSCFForPlan
    COAM_WebEM.VerifyAllCellsAreOnline
    ${SWVersion}    L3Call.COAM_Admin.GetActiveSoftwareVersion
    ${PrefixCurrent}        Basic.GetStreamAndVersion    vstring=${SWVersion}
    ${PrefixTarget}         Basic.GetStreamAndVersion
    ${trunk}    set variable if     ${SWVersion.count('ENB_999')}>0 and ${AF_PATH.count('ENB_999')}>0
    ...     true      false
    ${BackupSCF}  run keyword if     '${PrefixCurrent}'=='${PrefixTarget}' or '${trunk}'=='true'    COAM_Admin.BackupSCF
    ...    ELSE    Fail    GetSCF target and current version Not match
    [Return]    ${BackupSCF}
KW.GeneratePnPPlanFile
    return from keyword if    '${MRID}'=='NULL'
    ${res}    run keyword and ignore error   KW.GetSCFForPlan
    ${BackupSCF}    set variable if     '${res[0]}'=='FAIL'     ${CFGFILE_PATH}/SCF_${STREAM}.xml     ${res[1]}

    scf.Load Scf          file_path=${BackupSCF}
    ${MNLNIDDVersion}          scf.get_mo_attribute    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1      attribute=version
    #${systemReleaseVersion}    scf.get_mo_attribute    dist_name=${MRBTS_ID}      attribute=version
    scf.Save Scf          file_path=${BackupSCF}
    #${systemReleaseVersion}    get regexp matches    ${systemReleaseVersion}    SBTS[0-9A-Z]+
    GNB.GenerateCaseSCF    InputFile=${BackupSCF}
    ...    OutputFile=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    ...    ResourceFolder=${CURDIR}
    ...    ParameterToDelete=PARAMS_TO_DELETE_092_COMMON
    ...    MOsToAdd=MOS_TO_ADD_092_COMMON
    ...    ParamterToModify=PARAMS_TO_MODIFY_092_COMMON
    ...    ListParamterToModify=LIST_PARAMS_TO_MODIFY_092_COMMON
    ${string_prefix}        Basic.GetSBTSStreamPrefix
    Basic.SedReplaceString    matchValue=MNLNIDDVersion    newValue=${MNLNIDDVersion}    file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    Basic.SedReplaceString    matchValue=SystemModuleSN    newValue=${SystemModuleSN}    file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    Basic.SedReplaceString    matchValue=MRID    newValue=${MRID}    file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    Basic.SedReplaceString    matchValue=MRCID    newValue=${MRCID}    file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    Basic.SedReplaceString    matchValue=systemReleaseVersionValue
    ...    newValue=${string_prefix}  file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml
    Basic.SedReplaceString    matchValue=\\\"${MRBTS_ID}
    ...    newValue=\\\"PLMN-PLMN\\\/${MRBTS_ID}    file=${CFGFILE_PATH}/PnP_Plan_V4_${STREAM}.xml

KW.TestSuiteDestroy
    Log to Console    TestSuilt.Destroy
    #Run Keyword And Ignore error    KW.RecoverBTSEnv
    #Run Keyword And Ignore error   KW.DeleteAllPackagesFromSWM
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
    TestSuite.Stop

KW.CheckPnPState
    [Arguments]    ${src}    ${dst}
    ${srcindex}   set variable    0
    ${dstindex}   set variable    0
    ${index}   set variable    0
    FOR  ${state}  IN  @{PNPStates}
        ${srcindex}    set variable if  '${state}'=='${src}'    ${index}    ${srcindex}
        ${dstindex}    set variable if  '${state}'=='${dst}'    ${index}    ${dstindex}
        ${index}    Evaluate    ${index}+1
    END
    should be true   ${srcindex}>=${dstindex}
