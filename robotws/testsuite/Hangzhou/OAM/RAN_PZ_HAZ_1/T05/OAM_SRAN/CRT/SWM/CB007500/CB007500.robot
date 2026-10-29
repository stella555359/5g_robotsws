*** Settings ***
Documentation     [PURPOSE]
Resource    ../CB010738/CB010738.robot


*** Variables ***
${OfflinePlanFileName}                newMRBTSplan.xml
${IsUIvalue}                          false
${SW_Target_Path}                     /home/ute/BTSSW_bak
${BTS_OnAir_Timeout}                  100
${BTS_Commissioned_Timeout}           30
${ConfigReset_expect_time}            600
${Autoconn_expect_time}               600
${Autoconf_expect_time}               1800
&{BTSsshConfig}          host_ip=192.168.255.1    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu
&{TRSsshConfig}          host_ip=192.168.255.129    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu
&{Switchconfiguration}    host_ip=10.69.238.252    ssh_port=22    ssh_username=jing.1.wan@nokia.com    ssh_password=6666
# &{NETACT_SERVER_INFO_PNP}  IP=10.41.146.134
# ...                        URL=srnclab1015lbwas.srnblr.nsn-rdnet.net
# ...                        USERNAME=omc
# ...                        PASSWORD=Medsql!_1893
# ...                        PORT=22
# ...                        MR=MRC-COMMON/MR-COMMON
# ...                        EXTEND_IP=0a29.9286
# &{NETACT_SERVER_INFO_PNP}  IP=10.82.47.190
# ...                        URL=srnclab2014lbwas.srnblr.nsn-rdnet.net
# ...                        USERNAME=omc
# ...                        PASSWORD=Medsql!_1893
# ...                        PORT=22
# ...                        MR=MRC-COMMON/MR-COMMON
# ...                        EXTEND_IP=
&{NETACT_SERVER_INFO_PNP}  IP=10.43.48.192
...                        URL=srnclab1047lbwas.srnblr.nsn-rdnet.net
...                        USERNAME=omc
...                        PASSWORD=Medsql!_1893
...                        PORT=22
...                        MR=MRC-COMMON/MR-COMMON
...                        EXTEND_IP=
# &{NETACT_SERVER_INFO_PNP}  IP=10.63.2.155
# ...                        URL=srnclab1052lbwas.srnblr.nsn-rdnet.net
# ...                        USERNAME=omc
# ...                        PASSWORD=Medsql!_1893
# ...                        PORT=22
# ...                        MR=MRC-COMMON/MR-COMMON
# ...                        EXTEND_IP=


*** Keywords ***
CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less_kpi
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
    Step1: prepare package on NMS
    Step2: prepare plan with HWID on NMS
    Step3: Configuration reset for CB007500
    Step4: Start Autoconection and Autoconfiguration for HWID
    Step5: Check PnP Log and kpi result

CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Precondition Netact with 7500
    run keyword and ignore error     DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Postcondition Netact with TAF
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
    Step1: prepare package on NMS
    Step2: prepare plan with HWID on NMS
    Step3: Configuration reset for CB007500
    Step4: Start Autoconection and Autoconfiguration for HWID
    Step5: Check PnP Log and result

CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
#    Config_DHCP IPV4 for CB007500
    Config new DHCP IPV4 for CB007500
    Step1: prepare package on NMS
    Step2: prepare plan with SITEID on NMS
    Step3: Configuration reset for CB007500
    Step4: Start Autoconection and Autoconfiguration for SiteID
    Step5: Check PnP Log and result

CB007500_ST_05_01_PNP start with reset to D&RSW by GPS
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
    Step1: prepare package on NMS
    Step2: prepare plan with GPS on NMS
    Step3: Configuration reset for CB007500
    Step4: Start Autoconection and Autoconfiguration for GPS
    Step5: Check PnP Log and result

CB007500_ST_05_05_PNP start with configuration reset to D&RSW with Multi_NMS
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
    Config_DHCP IPV4 Two Netact for CB007500
    Step1: prepare package on NMS
    Step2: prepare plan with GPS on NMS
    Step3: Configuration reset for CB007500
    Step4: Start Autoconection and Autoconfiguration for GPS
    Step5: Check PnP Log and result

LTE4034_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Documentation]    Short description.
    Log To Console     CHANGE TO 7500 NETACT VARIABLE BEFORE:${NETACT_SERVER_INFO}
    Set Test Variable     ${NETACT_SERVER_INFO_ORG}      &{NETACT_SERVER_INFO}
    Run Keyword If    ${NETACT_SERVER_INFO_PNP}     Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_PNP}
    Log To Console     CHANGE TO 7500 NETACT VARIABLE AFTER: ${NETACT_SERVER_INFO}
    Step1: prepare package on NMS
    Step2: prepare plan with HWID on NMS
    Step3: Configuration reset for CB007500
    Step3-1:update FDSW to ff1 and ff2
    Step4: Start Autoconection and Autoconfiguration for HWID
    Step5: Check PnP Log and result for 4034
    Step6: Check configuration file download on SBTS

Step1: prepare package on NMS
    [Documentation]    Short description.
    Log Step Header    Step1: prepare package on NMS
    # Install Library In Loacal PC    ta_xml
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    set test variable    ${NetAct_CM_ExportFileName}     ${BTS_INFO.ID}_explort_SCF.xml
    precondition Netact with 7500
    Prepare BTS ENV and Netact package
    Prepare AutoConnection Parameters

Step2: prepare plan with HWID on NMS
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with HWID on NMS
    register MRBTS to NetAct
    Creation of Site configuration plan with HWID    ${newBTSID}
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    CB007500.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}

Step2: prepare plan with SITEID on NMS
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with SITEID on NMS
    register MRBTS to NetAct
    Creation of Site configuration plan with SiteID    ${newBTSID}
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    CB007500.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}
    ${SCF_NR}    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml

Step2: prepare plan with GPS on NMS
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with GPS on NMS
    register MRBTS to NetAct
    Creation of Site configuration plan with GPS    ${newBTSID}
    NetAct_Create_New_Site    GPSSite${newBTSID}
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    CB007500.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}
    ${SCF_NR}    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml

Step3: Configuration Reset for CB007500
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${user}: <description>
    ...        ${pass}: <description>
    Log Step Header    Step3: Configuration Reset for CB007500
    [Arguments]    ${user}=Nemuadmin    ${pass}=nemuuser
    Start Admin    username=${user}    password=${pass}    alias=hfv
    ${ConfigResetStartTime}=    Get Current Date
    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration    remove_operator_certificates=False
    ...    remove_user_account_credentials=False    alias=hfv    timeout=800    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
#    Wait Until Keyword Succeeds  10 min  5 sec    Connected to D&RSW BTS by RC    ${BTS_INFO.IP}
    Wait Until Keyword Succeeds  15 min  5 sec    Connected to D&RSW BTS by RC
    ${ConfigResetEndTime}=    Get Current Date
    ${ConfigReset_KPI_check}=  Operation_KPI_Check  ${ConfigResetEndTime}  ${ConfigResetStartTime}  ${ConfigReset_expect_time}
    ...  ConfigReset_BTS_KPI
    set suite variable    ${ConfigReset_KPI_check}
    set suite variable    ${ConfigResetStartTime}
    set suite variable    ${ConfigResetEndTime}

Step4: Start Autoconection and Autoconfiguration for HWID
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection and Autoconfiguration for HWID
    Wait Until Keyword Succeeds  5 min  10 sec    Connected to D&RSW BTS by RC
    Manual AutoConnection
    Enable AutoConnetion and Autoconfiguration
    ${AutoConnStartTime}=    Get Current Date
    set suite variable    ${AutoConnStartTime}

Step4: Start Autoconection and Autoconfiguration for SiteID
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection and Autoconfiguration for SiteID
    Wait Until Keyword Succeeds  5 min  10 sec    Connected to D&RSW BTS by RC
    AutoConnection with DHCP
    Enable AutoConnetion and Autoconfiguration
    sleep    60s
    Manual site configuration
    ${AutoConnStartTime}=    Get Current Date
    set suite variable    ${AutoConnStartTime}

Step4: Start Autoconection and Autoconfiguration for GPS
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection and Autoconfiguration for GPS
    Wait Until Keyword Succeeds  5 min  10 sec    Connected to D&RSW BTS by RC
    AutoConnection with DHCP
    Enable GPS on FDSW
    Enable AutoConnetion and Autoconfiguration
    sleep    60s
    Manual site configuration
    ${AutoConnStartTime}=    Get Current Date
    set suite variable    ${AutoConnStartTime}

Step5: Check PnP Log and result
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MRBTS_MO_DIST_NAME}: <description>
    [Arguments]    ${MRBTS_MO_DIST_NAME}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Log Step Header   Step5: Check PnP Log and result
    run keyword and ignore error    Start Capture tcpdump from FDSW    7500_1
    ${PNPstatus}    run keyword and return status    Wait Until Keyword Succeeds    25min    10s    Start Admin_MRAT    alias=default
    run keyword and ignore error       fdsw.download_technical_logs     ${TEMP_LOGS_DIR}
    set test variable    ${PNPstatus}
    run keyword if    '${PNPstatus}'=='False'    run keywords    Save Tcpdump File For PnP
    ...    AND   Fail    PNP failed on FDSW
    ${Commsionedstatus}    run keyword and return status    Wait Until Keyword Succeeds  ${BTS_Commissioned_Timeout}min  20 sec
    ...    Admin Check BTS Procedural and Blocking states  Commissioned
    set test variable    ${Commsionedstatus}
    ${AutoConfEndTime}=    Get Current Date
    CB007500_PnP report from Web
    Set suite variable    ${AutoConnEndTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfStartTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfEndTime}
    ${Autoconn_KPI_check}=    Operation_KPI_Check    ${AutoconnEndTime}    ${AutoconnStartTime}    ${Autoconn_expect_time}    Autoconn_BTS_KPI
    set suite variable    ${Autoconn_KPI_check}
    ${Autoconf_KPI_check}=    Operation_KPI_Check    ${AutoconfEndTime}    ${AutoconfStartTime}    ${Autoconf_expect_time}    Autoconf_BTS_KPI
    set suite variable    ${Autoconf_KPI_check}
    Run Keyword If     ${smod2_variable_exists}      wait until keyword succeeds    95min    30s    Mrat_resource_new._check provision triggered by NE
    Run Keyword If     ${smod2_variable_exists}       Sleep    35min
    ${OnAirstatus}    run keyword and return status    Wait Until Keyword Succeeds     ${BTS_OnAir_Timeout}min  20 sec
    ...    Admin Check BTS Procedural and Blocking states  OnAir
    set test variable    ${OnAirstatus}
    run keyword if    '${OnAirstatus}'=='False'    run keywords    Admin Get Snapshot    AND    Fail    PNP failed on onair check
    precondition netact with 7500
    run keyword and ignore error      taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml
    ${status}=      Run Keyword and return status
    ...    Wait Until Keyword Succeeds       50min  10 sec  Check SBTS SOAM cells and modules
    Run Keyword If      not ${status}      Check if fault 4001 present
#    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Postcondition Netact with TAF
#    Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_ORG}
#    precondition netact with 7500
#    register MRBTS to NetAct       mr=${NETACT_SERVER_INFO.MR}
#    Postcondition Netact with TAF
    [Teardown]    run keyword and ignore error    Stop tcpdump for PnP

Check if fault 4001 present
    [Documentation]    Short description.
    ${active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    Run Keyword If  not ${active_alarms}  Fail  No active alarms found
    ${alarm_4001}  Set variable  ${FALSE}
    FOR  ${alarm}  IN  @{active_alarms}
        ${alarm_4001}  Set variable if  '${alarm}[faultId]'=='4001'  ${TRUE}  ${alarm_4001}
    END
    Run keyword if   ${alarm_4001}     taf.sbts.oam.coam.admin.reset site
    Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=192.168.255.129
    ...  timeout=${FAULT_4001_TIMEOUT}
    Check if BTS is stable after reset
    Wait Until Keyword Succeeds       30min  10 sec  Check SBTS SOAM cells and modules

Check if BTS is stable after reset
    [Documentation]    Short description.
    Log  Check if ping has been regained after BTS reset  console=${TRUE}
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable
    ...  hostname=192.168.255.129  timeout=420
    Run keyword if  ${ping_regain_status}  Log  BTS is reachable after reset  console=${TRUE}
    ...  ELSE  Fail  BTS is not reachable after reset
    Log  Check if target is stable after reset  console=${TRUE}
    Check If Target Is Stable  192.168.255.129

Step5: Check PnP Log and kpi result
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MRBTS_MO_DIST_NAME}: <description>
    [Arguments]    ${MRBTS_MO_DIST_NAME}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Log Step Header   Step5: Check PnP Log and result
    run keyword and ignore error    Start Capture tcpdump from FDSW    7500_1
    ${PNPstatus}    run keyword and return status    Wait Until Keyword Succeeds    15min    10s    Start Admin_MRAT    alias=default
    set test variable    ${PNPstatus}
    run keyword if    '${PNPstatus}'=='False'    run keywords    Save Tcpdump File For PnP
    ...    AND   fdsw.download_technical_logs     ${TEMP_LOGS_DIR}
    ...    AND   Fail    PNP failed on FDSW
    Run Keyword If     ${smod2_variable_exists}      wait until keyword succeeds    95min    30s    Mrat_resource_new._check provision triggered by NE
    ${OnAirstatus}    run keyword and return status    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout}min  20 sec
    ...    Admin Check BTS Procedural and Blocking states  OnAir
    set test variable    ${OnAirstatus}
    ${AutoConfEndTime}=    Get Current Date
    run keyword if    '${OnAirstatus}'=='False'    run keywords    Admin Get Snapshot    AND    Fail    PNP failed on onair check
    precondition netact with 7500
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec  Verify BTS states
    CB007500_PnP report from Web
    Set suite variable    ${AutoConnEndTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfStartTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfEndTime}
    ${Autoconn_KPI_check}=    Operation_KPI_Check    ${AutoconnEndTime}    ${AutoconnStartTime}    ${Autoconn_expect_time}    Autoconn_BTS_KPI
    set suite variable    ${Autoconn_KPI_check}
    ${Autoconf_KPI_check}=    Operation_KPI_Check    ${AutoconfEndTime}    ${AutoconfStartTime}    ${Autoconf_expect_time}    Autoconf_BTS_KPI
    set suite variable    ${Autoconf_KPI_check}
    Postcondition Netact with TAF
    Set Test Variable     ${NETACT_SERVER_INFO}      &{NETACT_SERVER_INFO_ORG}
    precondition netact with 7500
    register MRBTS to NetAct       mr=${NETACT_SERVER_INFO.MR}
    Postcondition Netact with TAF
    [Teardown]    run keyword and ignore error    Stop tcpdump for PnP

Step5: Check PnP Log and result for 4034
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MRBTS_MO_DIST_NAME}: <description>
    [Arguments]    ${MRBTS_MO_DIST_NAME}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Log Step Header   Step5: Check PnP Log and result for 4034
    run keyword and ignore error    Start Capture tcpdump from FDSW    7500_1
    Wait Until Keyword Succeeds  5 min  10 sec    Connected to D&RSW BTS by RC
    ${PNPstatus}    run keyword and return status    Wait Until Keyword Succeeds    15min    5s
    ...    Check Autoconnection status on FDSW    Identification finished
    set test variable    ${PNPstatus}
    Save Tcpdump File For PnP
    run keyword if    '${PNPstatus}'=='False'    run keywords    fdsw.download_technical_logs     ${TEMP_LOGS_DIR}
    ...    AND   Fail    Identification failed on FDSW
    ${PNPdownloadstatus}    run keyword and return status    Wait Until Keyword Succeeds    120min    30s
    ...    Check Autoconnection status on FDSW    Software download finished
    run keyword if    '${PNPdownloadstatus}'=='False'    run keywords    fdsw.download_technical_logs     ${TEMP_LOGS_DIR}
    ...    AND   Fail    PNP Software download failed on FDSW

Step6: Check configuration file download on SBTS
    [Documentation]    Short description.
    Log Step Header    Step6: Check configuration file download on SBTS
    Wait Until Keyword Succeeds    10min    10s    Start Admin_MRAT    alias=default

    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=120
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful configuration download and actviation from NMS DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful configuration download and actviation from NMS...  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained after scf avtibation within timeout

    sleep     60s
    Admin and Infomodel connections reset
    # ${OnAirstatus}    run keyword and return status    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec
    ${OnAirstatus}    run keyword and return status    Wait Until Keyword Succeeds     7min    10 sec
    ...    Admin Check BTS Procedural and Blocking states  OnAir
    set test variable    ${OnAirstatus}
    ${AutoConfEndTime}=    Get Current Date
    run keyword if    '${OnAirstatus}'=='False'    run keywords    Admin Get Snapshot    AND    Fail    PNP failed on onair check
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec  Verify BTS states
    CB007500_PnP report from Web
    Set suite variable    ${AutoConnEndTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfStartTime}    ${IdFinishTime}
    Set suite variable    ${AutoConfEndTime}

    ${Autoconn_KPI_check}=    Operation_KPI_Check    ${AutoconnEndTime}    ${AutoconnStartTime}    ${Autoconn_expect_time}    Autoconn_BTS_KPI
    set suite variable    ${Autoconn_KPI_check}
    # ${Autoconf_KPI_check}=    Operation_KPI_Check    ${AutoconfEndTime}    ${AutoconfStartTime}    ${Autoconf_expect_time}    Autoconf_BTS_KPI
    # set suite variable    ${Autoconf_KPI_check}

    [Teardown]    run keyword and ignore error    Stop tcpdump for PnP

Step3-1:update FDSW to ff1 and ff2
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    taf.fdsw.rc.trigger_factory_reset    1     timeout=60
    sleep    10s
    taf.fdsw.rc.trigger_factory_reset    2     timeout=60
    sleep    10s
    Run Keyword And Ignore Error    taf.fdsw.rc.software_rollback    1    timeout=10
    sleep    10s

    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC

CB007500_PnP report from Web
    [Documentation]    Short description.
    Log to console    CB007500_PnP report from Web
    Start Admin    alias=hfv
    ${Report}    taf.sbts.oam.coam.admin.Get Pnp Report
    ...    ${TEMP_LOGS_DIR}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt    alias=hfv
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    ${IdserverIP}    Get IdserverIP
    ${Report}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt
    should contain    ${Report}    Identification requested
    should contain    ${Report}    Identification finished
    should contain    ${Report}    Software download requested
    should contain    ${Report}    Software activation finished successfully
    should contain    ${Report}    Configuration plan activation success
    ${IdFinishTimetemp}     Get Lines Containing String    ${Report}    Identification finished
    ${endtimeline}    Get Lines Containing String    ${Report}    NMS has registered on NE
    ${IdFinishTimetemp}    get line    ${IdFinishTimetemp}    -1
    ${IdFinishTime}    Get Substring    ${IdFinishTimetemp}    0    23
    ${IdFinishTime}    Replace String    ${IdFinishTime}    T    ${SPACE}
    Set suite variable    ${IdFinishTime}

CB007500_PnP report uploading to Netact
    [Documentation]    Short description.
    Log to console    start check PnP report from NetAct
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    # ${reportID}    get substring    00${newBTSID}    -5
    ${PnPnode}    Get Substring    ${NETACT_SERVER_INFO.URL}    8    19
    ${netact_connection}    Connect To NetAct
    SSHLibrary.Switch Connection    ${netact_connection}
    SSHLibrary.Execute Command    ssh ${PnPnode}node07
    SSHLibrary.Execute Command    ls -lh
    SSHLibrary.Execute Command    cd /d/oss/global/pnpreport/ne3sws
    ${reportlist}    SSHLibrary.Execute Command    ls | grep _{newBTSID}.
    ${reportcount1}    string.get line count    ${reportlist}
    ${reportcount}    Evaluate    ${reportcount1}-1
    ${reportname}    string.get line    ${reportlist}    ${reportcount}
    ${AutoconReport_content}    SSHLibrary.Execute Command    cat ${reportname}
    Should Contain    ${AutoconReport_content}    Configuration plan download start
    Should Contain    ${AutoconReport_content}    Configuration plan validation success
    Should Contain    ${AutoconReport_content}    Autoconfiguration completed

Prepare BTS ENV and Netact package
    [Documentation]    Short description.
    Log to console   Prepare BTS ENV and NetAct package  console=${true}
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    set test variable    ${PASSIVE_SW_BEFORE}
    set test variable    ${ACTIVE_SW_BEFORE}
    ${Active_release}    Fetch from left    ${ACTIVE_SW_BEFORE}    _
    ${Passive_release}    Fetch from left    ${PASSIVE_SW_BEFORE}    _
    set suite variable    ${PnPSWversion}    ${ACTIVE_SW_BEFORE}
    Log    Start to import sw to netact
    CB007500_Import_SW_to_NetAct    ${PnPSWversion}
    Log    Finished to import sw to netact

Check Cert
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Certcont}: <description>
    [Arguments]    ${Certcont}
	${command}   set variable    ls /ffs/fs1/trs_data/active/keystorage
	${certfile}    Execute Remote Command and Return Output    ${command}    ssh    &{BTSsshConfig}
    log    ${certfile}
    Should Be Equal    '${certfile}'    ${Certcont}

PnP_COAM_Site_Preparation_By_WFE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [Arguments]    ${PnPPlanfile}
    Log to console    start PnP_COAM_Site_Preparation_By_WFE
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${myPlanName}    Set Variable    planfilefor${BTS_INFO.ID}_${timestamp}
    Set Test Variable    ${myPlanName}
    ${cmd}=    Catenate    SEPARATOR=${SPACE}
    ...    racclimx.sh -op Unified_PnP_COAM_Site_Preparation -planName ${myPlanName} -UIValues false
    ...    -fileFormat RAML2 -inputFile /var/opt/oss/global/racops/import/tempPnPFileName.xml -v
    Log    ${cmd}

    Run Keyword And Ignore Error    NetAct Delete Plan    ${myPlanName}    ${myPlanName}
    sftp upload    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ...    ${PnPPlanfile}    /var/opt/oss/global/racops/import/tempPnPFileName.xml
    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    SSHLibrary.Write    ${cmd}
    ${COAM_Site_Preparation_log}    SSHLibrary.Read Until    @
    log    ${COAM_Site_Preparation_log}
    ${validation_result}=    Run Keyword and Return Status    Should contain
    ...  ${COAM_Site_Preparation_log}    Status received: Finished    ignore_case=True
    Run Keyword If    ${validation_result}==${FALSE}    Log To Console    Unified PnP COAM Site Preparation failed :(.
    ...    ELSE    Log To Console    Unified PnP COAM Site Preparation Succeed :).
    Should Be True    ${validation_result}

PnP_COAM_Site_Preparation_By_WFE_GPS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [Arguments]    ${PnPPlanfile}
    ${myPlanName}    Set Variable    planfilefor${BTS_INFO.ID}
    Set Test Variable    ${myPlanName}
    ${cmd}=    Catenate    SEPARATOR=${SPACE}
    ...    racclimx.sh -op Unified_PnP_COAM_Site_Preparation -planName ${myPlanName} -UIValues false
    ...    -activateSiteTemplate true -GPSIdentificationUsed true -GPSTolerance 100
    ...    -fileFormat RAML2 -inputFile /var/opt/oss/global/racops/import/tempPnPFileName.xml -v
    Log    ${cmd}
    ${GPSTolerance}    Evaluate    int(100)
    Run Keyword And Ignore Error    RobotWS_HFV2_NetAct.NetAct_CM_Delete_Plan    ${myPlanName}
    sftp upload    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ...    ${PnPPlanfile}    /var/opt/oss/global/racops/import/tempPnPFileName.xml
    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    SSHLibrary.Write    ${cmd}
    ${COAM_Site_Preparation_log}    SSHLibrary.Read Until    @
    Log    ${COAM_Site_Preparation_log}

CB007500_Import_SW_to_NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_build}: <description>
    [Arguments]    ${sw_build}
    Log to console    Start to import SW to NetAct
    ${status}    CB007500_Check Plungin In NetAct    ${sw_build}
    ${release}    Fetch from left    ${sw_build}    _
    set test variable    ${release}
    ${sw_package_build}    Run Keyword If    '9999' in '${sw_build}'
    ...    Replace String Using Regexp    ${sw_build}    ${release}_    SBTS00_
    ...    ELSE    Set variable    ${sw_build}
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}    Choose_Mid_Server4Netact      ${NETACT_SERVER_INFO.IP}
    run keyword if  "${status}"=="False"    build_download_upload_on_remote_server_and_import_to_Netact    ${sw_package_build}    ${release}
    ...    Basic    ${Mid_Server}    ${Mid_Server_usr}    ${Mid_Server_pwd}
    ${status}    CB007500_Check Plungin In NetAct    ${sw_build}
    should be true     "${status}"=="True"
    Log to console    Finished to import SW to NetAct

CB007500_Check Plungin In NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_build}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
    [Arguments]    ${sw_build}
    Precondition Netact with 7500
    ${status}    taf.nms.netact.Is Imported    ${sw_build}
    Postcondition Netact with TAF
    [Return]    ${status}

Common Steps To Prepare SCF For PnP
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${newBTSID}: <description>
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    @{releaselist}    split string    ${PnPSWversion}    _
    ${ReleaseVers}    set variable    ${releaselist[0]}
    ${INTEMO}=    Catenate    SEPARATOR=${SPACE}
    ...    <managedObject class="com.nokia.integrate:INTEGRATE"
    ...    version="INT_01" distName="PLMN-PLMN/MRBTS-${newBTSID}/INTEGRATE-1" operation="create">
    ...    \ \ \ \ \ \ <defaults name="System"/>
    ...    \ \ \ \ \ \ <p name="hostNameEm">${BTS_INFO.IP}</p>
    ...    \ \ \ \ \ \ <p name="hostNameNe3sws">${BTS_INFO.IP}</p>
    ...    \ \ \ \ \ \ <p name="ipVersion">0</p>
    ...    \ \ \ \ \ \ <p name="plannedSWReleaseVersion">${PnPSWversion}</p>
    ...    \ \ \ \ \ \ <p name="securityMode">0</p>
    ...    \ \ \ \ \ \ <p name="systemReleaseVersion">${ReleaseVers}</p>
    ...    \ \ \ \ </managedObject>|//*[@distName='PLMN-PLMN/MRBTS-${newBTSID}']/..
    Log    ${INTEMO}
    Start Admin_MRAT    alias=get_scf
    taf.sbts.oam.coam.admin.get_current_scf_file   ${TEMP_LOGS_DIR}    SCF.xml    timeout=180    connection=get_scf
    taf.sbts.oam.coam.admin.Teardown Admin    alias=get_scf
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    NetAct Export Plan new   ${TEMP_LOGS_DIR}    ${NetAct_CM_ExportFileName}    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ...    ${NetAct_CM_ExportFileName}    actual
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}${NetAct_CM_ExportFileName}
    ${xpath}    set variable    //*[@class='MNL']//*[@name='plannedSWReleaseVersion']
    ${res}=    evaluate_xml_xpath    ${xml}    boolean(${xpath})
    Run Keyword If    ${res}==${TRUE}
    ...    ta_xml_interface.remove_xml_element    ${xml}    ${TEMP_LOGS_DIR}${/}temp0.xml    ${xpath}
    ${xpath}    set variable    //*[@class='INTEGRATE']
    ${res}=    evaluate_xml_xpath    ${xml}    boolean(${xpath})
    Run Keyword If    ${res}==${TRUE}
    ...    ta_xml_interface.remove_xml_element    ${TEMP_LOGS_DIR}${/}temp0.xml
    ...    ${TEMP_LOGS_DIR}${/}temp0.xml    ${xpath}
    Run Keyword If    ${res}==${FALSE}
    ...    OperatingSystem.Copy File    ${TEMP_LOGS_DIR}${/}${NetAct_CM_ExportFileName}    ${TEMP_LOGS_DIR}${/}temp0.xml
    ${xpath}    set variable    //*[@class='MNL']
    ta_xml_interface.add_xml_element    ${TEMP_LOGS_DIR}${/}temp0.xml    ${TEMP_LOGS_DIR}${/}temp.xml
    ...    <p name="plannedSWReleaseVersion">${PnPSWversion}</p>|${xpath}
	${xpath}    set variable    //*[@class='LNADJW']
	Run Keyword And Ignore Error    ta_xml_interface.remove_xml_element    ${TEMP_LOGS_DIR}${/}temp.xml
	...    ${TEMP_LOGS_DIR}${/}temp.xml    ${xpath}
	${xpath}    set variable    //*[@class='LNADJG']
	Run Keyword And Ignore Error    ta_xml_interface.remove_xml_element    ${TEMP_LOGS_DIR}${/}temp.xml
	...    ${TEMP_LOGS_DIR}${/}temp.xml    ${xpath}
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}temp.xml
    ${xml2}    Replace String Using Regexp    ${xml}    BTS-${BTS_INFO.ID}    BTS-${newBTSID}
    ${newxml}    Replace String Using Regexp    ${xml2}    id="[0-9]*"    operation="create"
    ta_xml_interface.add_xml_element    ${newxml}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}    ${INTEMO}
    set test variable    ${PnPPlanfile}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}
    set test variable    ${ReleaseVers}

Post Steps To Prepare SCF For PnP with HWID
    ta_xml_interface.add_xml_element    ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="AutoConnHWID">${BTS_INFO.SERIAL_NUMBER}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element    ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']

Post Steps To Prepare SCF For PnP with SiteID
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    ta_xml_interface.add_xml_element    ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="AutoConnSiteID">Site${newBTSID}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element    ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']

Post Steps To Prepare SCF For PnP with GPS
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    ta_xml_interface.add_xml_element  ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="AutoConnHWID">${BTS_INFO.CORE_SERIAL_NUMBER}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="siteId">GPSSite${newBTSID}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${PnPPlanfile}    ${PnPPlanfile}
	...    <p name="siteCId">1</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${PnPPlanfile}    ${PnPPlanfile}
	...    <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${PnPPlanfile}    ${PnPPlanfile}
    ...    <p name="$maintenanceRegionCId">1</p>|//*[@class='MRBTS']

Creation of Site configuration plan with HWID
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    Log to console    start to Creation of Site configuration plan with HWID
    Common Steps To Prepare SCF For PnP    ${newBTSID}
    Post Steps To Prepare SCF For PnP with HWID

Creation of Site configuration plan with SiteID
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    BuiltIn.Log To Console    start to Creation of Site configuration plan with SiteID
    Common Steps To Prepare SCF For PnP    ${newBTSID}
	Post Steps To Prepare SCF For PnP with SiteID    ${newBTSID}

Creation of Site configuration plan with GPS
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    BuiltIn.Log To Console    start to Creation of Site configuration plan with GPS
    Common Steps To Prepare SCF For PnP    ${newBTSID}
    Post Steps To Prepare SCF For PnP with GPS    ${newBTSID}

Connected to D&RSW BTS by RC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${fdsw_version}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser  ${fdsw_version}=fdsw21c
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
#    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    taf.fdsw.rc.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with IP ${ip_address}
    CB007500_enable_SSH_Access_On_RC

CB007500_enable_SSH_Access_On_RC
    [Documentation]    Short description.
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ethernet_port_security
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ssh_service

Get IdserverIp
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${IdserverIp}: <description>
    @{string}    split string    ${NETACT_SERVER_INFO.IP}    .
    log    ${string[0]}
    ${NodeID}    Evaluate    ${string[3]}+12
#    ${NodeID}    Evaluate    ${string[3]}+13
    ${IdserverIp}    set variable    ${string[0]}.${string[1]}.${string[2]}.${NodeID}
    [Return]    ${IdserverIp}

Get BTS registed RowID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${registedBTSID}: <description>
    ...
    ...    Returns:
    ...        ${ListConnectedRowID}: <description>
    ...        ${ListPlannedRowID}: <description>
    [Arguments]    ${registedBTSID}=${BTS_INFO.ID}
    set test variable    ${ListPlannedRowID}    ${EMPTY}
    set test variable    ${ListConnectedRowID}    ${EMPTY}
    ${NetActConnection}    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    SSHLibrary.Write    /opt/cpf/sbin/netact_status.sh status service PnP
    ${Node Status}    SSHLibrary.Read Until    @
    log    ${Node Status}
    ${nodestring}    Get Line    ${Node Status}    ${0}
    @{nodestringlist}    Split String    ${nodestring}    :
    set test variable    ${PnPNode}    ${nodestringlist[1]}
    ${netact_connection}    Connect To NetAct
    ta_ssh_telnet.Switch Host Connection    ${netact_connection}
    SSHLibrary.Execute Command    ssh ${PnPNode}
    ${ListPlannedStatue}=    SSHLibrary.Execute Command
    ...    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op listPlanned -dn PLMN-PLMN/MRBTS-${registedBTSID} -f raw
    log    ${ListPlannedStatue}
    ${status}    run keyword and return status    Should Contain    ${ListPlannedStatue}    MRBTS-${registedBTSID}
    Run Keyword If    ${status}==True    set test variable    ${planrowIDstring}    ${ListPlannedStatue}
    @{rowIDstring}    split string    '${planrowIDstring}'    ,
    @{rowID}    split string    ${rowIDstring[0]}    :
    set test variable    ${ListPlannedRowID}    ${rowID[2]}
    set test variable    ${ListConnectedRowID}
    ${ListConnectedStatue}=    SSHLibrary.Execute Command
    ...    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op listConnected -dn PLMN-PLMN/MRBTS-${registedBTSID} -f raw
    ${type}    Evaluate    type($ListConnectedStatue)
    log    ${ListConnectedStatue}
    ${status}    run keyword and return status    Should Contain    ${ListConnectedStatue}    MRBTS-${registedBTSID}
    Run Keyword If    ${status}==True    set test variable    ${ConnectedrowIDstring}    ${ListConnectedStatue}
    @{rowIDstring}    split string    '${ConnectedrowIDstring}'    ,
    @{rowID}    split string    ${rowIDstring[0]}    :
    ${ListConnectedRowID}    set variable    ${rowID[2]}
    [Return]    ${ListConnectedRowID}    ${ListPlannedRowID}

Prepare AutoConnection Parameters
    [Documentation]    Short description.
    run keyword and ignore error    Teardown Infomodel
    ${rid}    _Get Runtime ID By Infomodel
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin
    ${NPID}  set variable    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-1
    FOR  ${ID}  IN RANGE    1    50
        ${result}=    run keyword and ignore error    Get Parameter Value By Admin    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}
        ${NPID}    set variable if    "${result[0]}"=="PASS"    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}    ${NPID}
        Exit For Loop If    "${result[0]}"=="PASS"
    END
    FOR  ${ID}  IN RANGE     1     10
        ${result}=      Run Keyword And Ignore Error
        ...    Get Parameter Value By Admin    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-${ID}/IPADDRESSV4_A-1
        Run Keyword if      "${result[0]}" != "PASS"     Continue For Loop
        Run Keyword if      "${result[1]}[localIpAddr]"!="${BTS_INFO.IP}"      Continue For Loop
        ${netPre}=        Get Parameter Value By Admin
        ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-${ID}/IPADDRESSV4_A-1    localIpPrefixLength
        ${IPIFinterfaceDN}=        Get Parameter Value By Admin
        ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-${ID}      interfaceDN
        ${vlanIdresult}=      Run Keyword And Ignore Error    Get Parameter Value By Admin        ${IPIFinterfaceDN}     vlanId
        Set test variable    ${IPIFinterfaceDN}
        Set test variable    ${netPre}
        Set test variable         ${vlanIdresult}
        Exit For Loop
    END
    ${staticRoutes}    Get Parameter Value By Admin   ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPRT_A-1
    ...    staticRoutes
    ${type}    Evaluate    type($staticRoutes)
    ${gateway}    Get From Dictionary    ${staticRoutes}[0]    gateway
    ${netPre}    Evaluate    int(${netPre})
    ${vlanId}    run keyword if    "${vlanIdresult[0]}"=="PASS"     Evaluate    int(${vlanIdresult[1]})
    Set test variable    ${vlanId}
    Set test variable    ${gateway}
    Set test variable    ${netPre}

Manual AutoConnection
    [Documentation]    Short description.
    Log to console    start to config the AutoConnection parameter on RC
    ${IdserverIP}    Get IdserverIP
    run keyword if    '${vlanIdresult[0]}'=='PASS' and 'VLANIF' in '${IPIFinterfaceDN}'
    ...    taf.fdsw.rc.set_autoconnection    primary_ip_address=${BTS_INFO.IP}    primary_prefix_length=${netPre}
    ...    primary_gateway=${gateway}    connection=default       vlan_id=${vlanId}    scenario=private network manual
    ...    identification_entity_ip_address=${IdserverIP}
    ...    ELSE    taf.fdsw.rc.Set Autoconnection    primary_ip_address=${BTS_INFO.IP}    primary_prefix_length=${netPre}
    ...    primary_gateway=${gateway}    connection=default        scenario=private network manual
    ...    identification_entity_ip_address=${IdserverIP}
    Log to console    finish to config the AutoConnection parameter on RC

AutoConnection with DHCP
    [Documentation]    Short description.
    Log to console    start to config the AutoConnection by DHCP on RC
    ${IdserverIP}    Get IdserverIP
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    taf.fdsw.rc.set_autoconnection_parameters_to_default
    Log to console    finish to config the AutoConnection by DHCP on RC

NetAct_Create_New_Site
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${siteid}: <description>
    [Arguments]    ${siteid}
    Log to console    start to create New site from NetAct
    ${time}    Get Time
    ${Rid}    _Get Runtime ID By Infomodel
    Set test variable    ${GNSSMO}    /MRBTS-1/RAT-1/RUNTIME_VIEW-${RID}/MRBTS_R-${RID}/EQM_R-${RID}/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
    ${sitelatitude}    Get Parameter Value By Admin     ${GNSSMO}    gnssAntennaLatitude
    ${sitelongitude}    Get Parameter Value By Admin    ${GNSSMO}    gnssAntennaLongitude
    ${sitealtitude}    Get Parameter Value By Admin     ${GNSSMO}    gnssAntennaAltitude
    ${site_data}=    Create Dictionary    siteId=${siteid}    siteName=None    siteCId=1    streetAddress=None    longitude=${sitelongitude}
    ...    latitude=${sitelatitude}    groundHeight=${sitealtitude}
    taf.nms.netact.Modify Mass Site    assign_to_site=${site_data}    dist_names=PLMN-PLMN/MRBTS-${newBTSID}    overwrite_site_values=True

Manual site configuration
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    taf.fdsw.rc.set_site_identification    Site${newBTSID}
    sleep  5s

Enable GPS on FDSW
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    ${GNSSList}=    taf.fdsw.rc.Get Supported Gnss Constellations
    sleep  5s
    taf.fdsw.rc.enable_gnss_constellations  ${GNSSList[0]}
    sleep  5s
    taf.fdsw.rc.get_gnss_constellations_status
    sleep  5s

Enable AutoConnetion and Autoconfiguration
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    taf.fdsw.rc.enable_autoconnection_service
    taf.fdsw.rc.enable_autoconfiguration_service

Recovery Env
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    15min    30s    _Perform Full Commision By Admin    ${TEMP_LOGS_DIR}${/}BACK_SCF.xml    ${BTS_INFO.ID}

Delete Plan With GPS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${registedPlanBTSID}: <description>
    [Arguments]    ${registedPlanBTSID}=${BTS_INFO.ID}
    run keyword and ignore error    Get BTS registed RowID    ${registedPlanBTSID}
    ${netact_connection}    Connect To NetAct
    ta_ssh_telnet.Switch Host Connection    ${netact_connection}
    SSHLibrary.Execute Command    ssh ${PnPNode}
    run keyword and ignore error    SSHLibrary.Execute Command    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op deleteData
    ...    -deleteFrom connected -rowId ${ListConnectedRowID}
    run keyword and ignore error    SSHLibrary.Execute Command    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op deleteData
    ...    -deleteFrom planned -rowId ${ListPlannedRowID}
    run keyword and ignore error    Stop And Collect Syslog    alias=enb
    run keyword and ignore error    taf.sbts.oam.coam.admin.Collect Snapshot    ${TEMP_LOGS_DIR}${/}snapshot.zip

Remove PnP Report From NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${newBTSID}: <description>
    ...
    ...    Returns:
    ...        ${reportID}: <description>
    [Arguments]    ${newBTSID}=${BTS_INFO.ID}
    ${reportID}    get substring    00${newBTSID}    -5
    ${PnPnode}    Get Substring    ${NETACT_SERVER_INFO.URL}    8    19
    ${netact_connection}    Connect To NetAct
    SSHLibrary.Switch Connection    ${netact_connection}
    SSHLibrary.Execute Command    ssh ${PnPnode}node07
    SSHLibrary.Execute Command    ls -lh
    SSHLibrary.Execute Command    cd /d/oss/global/pnpreport/ne3sws
    run keyword and ignore error    SSHLibrary.Execute Command    rm *AutoconfigurationReport_${reportID}
    [Return]    ${reportID}

Get_Autoconnection_Parameter_From_Admin
    [Documentation]    Short description.
    ${valnID}    Admin get current value    vlanId    ${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ${gateway}    Admin get current value    gateway    ${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1
    ${MplaneIP}    Admin get current value    localIpAddr    ${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${PrefixLenght}    Admin get current value    localIpPrefixLength    ${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${valnID}    Evaluate    int(${valnID})
    ${PrefixLenght}    Evaluate    int(${PrefixLenght})
    Set Test Variable    ${valnID}
    Set Test Variable    ${gateway}
    Set Test Variable    ${MplaneIP}
    Set Test Variable    ${PrefixLenght}
    ${ssh_server_connection}    Connect To Host    host=${NETACT_SERVER_INFO.IP}    port=22    username=${NETACT_SERVER_INFO.USERNAME}
    ...    password=${NETACT_SERVER_INFO.PASSWORD}    conn_type=SSH
    Switch Host Connection    ${ssh_server_connection}
    ${result}    Execute Command    nslookup ${NETACT_SERVER_INFO.URL}
    log    ${result}
    ${Split_result}    Split String    ${result}
    ${Lbwas_IP}    Get From List    ${Split_result}    -5
    Set Test Variable    ${Lbwas_IP}

Start Capture tcpdump from FDSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${id}: <description>
    [Arguments]    ${id}=1
    set test variable    ${id}
    set test variable    ${TEMP_LOGS_DIR}    /home/ute
    ${command}   set variable    tcpdump -i any -s 0 -n -nn -w /ffs/run/config/toor4nsn/${id}
    # ${tcpdumpoutput}    Execute Remote Command and Return Output    ${command}    ssh    &{TRSsshConfig}
    _Remote Command Setup   trsssh    &{TRSsshConfig}
    get connection    trsssh
    # Set Client Configuration	prompt=#
    ${output}    SSHLibrary.Write    ${command} &
    ${output}    SSHLibrary.read until    bytes
    _Remote Command Teardown
    when log to console with time  TCP dump for PnP started

Check Autoconnection Status on FDSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${status}: <description>
    ...        ${timeslot}: <description>
    [Arguments]    ${status}    ${timeslot}=300
    Log to console    Check Autoconnection Status ${status} on FDSW
    # {Autoconnectionresult}    taf.fdsw.rc.get_diagnostics    timeout=50    #connection=default
    ${PNPreportpath}    fdsw.download_autoconfiguration_report    ${TEMP_LOGS_DIR}    timeout=10
    ${pnpreportcontent}    OperatingSystem.get file    ${PNPreportpath}
    should contain     ${pnpreportcontent}    ${status}
    ${FinishTimetemp}     Get Lines Containing String    ${pnpreportcontent}    ${status}
    ${FinishTimetemp}    get line    ${FinishTimetemp}    -1
    ${FinishTime}    Get Substring    ${FinishTimetemp}    0    23
    ${FinishTime}    Replace String    ${FinishTime}    T    ${SPACE}
    run keyword if    '${status}'=='Identification finished'    Set suite variable    ${IdFinishTime}     ${FinishTime}
    ${AutoConfinish}=    Get Current Date
    ${Finishstatus}=    Operation_KPI_Check    ${AutoConfinish}    ${FinishTime}    ${timeslot}    Autoconn_BTS_KPI
    Log to console    Check Autoconnection Status ${status} on FDSW successfully.

Stop tcpdump for PnP
    [Documentation]    Short description.
    Log  Waiting for ping return  console=${TRUE}
    ${cmd}    set variable    kill `pgrep tcpdump`
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    _Remote Command Setup    trsssh   &{TRSsshConfig}
    get connection    trsssh
    # Set Client Configuration	prompt=#
    ${output}    SSHLibrary.Write    ${cmd}
    ${output}    SSHLibrary.Write    exit
    _Remote Command Teardown

Save Tcpdump File For PnP
    [Documentation]    Short description.
    Stop tcpdump for PnP
    Run Keyword And Ignore Error    Get File From System Module    source_path=/ffs/run/config/toor4nsn/${id}
    ...    destination_path=${TEMP_LOGS_DIR}${/}${id}

Start tcpdump on NetAct
    [Documentation]    Short description.
    Set Connection Parameters  ip=${NETACT_SERVER_INFO.IP}  user=${NETACT_SERVER_INFO.USERNAME}  password=${NETACT_SERVER_INFO.PASSWORD}
    SSHLibrary.Write   su - root
    sleep   5s
    SSHLibrary.Write   arthur
    sleep   5s
    SSHLibrary.Write   tcpdump -i any -s 0 -n -nn ip host ${BTS_INFO.IP} -w /tmp/CB007500dump.pcap &

Stop tcpdump on NetAct and save file on local
    [Documentation]    Short description.
    Set Connection Parameters  ip=${NETACT_SERVER_INFO.IP}  user=${NETACT_SERVER_INFO.USERNAME}  password=${NETACT_SERVER_INFO.PASSWORD}
    SSHLibrary.Write   su - root
    sleep   5s
    SSHLibrary.Write   arthur
    sleep   5s
    SSHLibrary.Write   kill `pgrep tcpdump`
    sleep  10s
    SSHLibrary.Execute Command    scp /tmp/CB007500dump.pcap ute@10.68.93.70:/home/ute/CB007500dump.pcap
    sleep   5s
    SSHLibrary.Execute Command    ute@dmin5
    sleep  30s
    SSHLibrary.Execute Command    rm /tmp/CB007500dump.pcap
    SSHLibrary.Close Connection
    ${PC_connection}    SSHLibrary.Open Connection    ${BTS_PC_INFO.IP}
    SSHLibrary.Login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    SSHLibrary.Switch Connection    ${PC_connection}
    SSHLibrary.Execute Command    scp ute@10.68.93.70:/home/ute/CB007500dump.pcap ${TEMP_LOGS_DIR}${/}CB007500dump.pcap
    sleep   5s
    SSHLibrary.Execute Command    ute@dmin5
    sleep  30s
    SSHLibrary.Close Connection

register MRBTS to NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${release}: <description>
    ...        ${DN}: <description>
    ...        ${BTSIP}: <description>
    ...        ${mr}: <description>
    ...        ${security_mode}: <description>
    [Arguments]    ${release}=SBTS23R3    ${DN}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    ${BTSIP}=${BTS_INFO.IP}    ${mr}=MRC-COMMON/MR-COMMON
    ...    ${security_mode}=no TLS
    Log to console    start register MRBTS to NetAct
    Precondition Netact with 7500
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF
    sleep    90s
    ${release}=     Fetch from left    ${active SW version}    _
    Integrate MRBTS With Netact TAF   ${BTSIP}    ${DN}    ${mr}    ${release}    ${security_mode}

#register MRBTS to NetAct_with_DHCP
#    [Arguments]    ${release}=SBTS23R3    ${DN}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    ${BTSIP}=${BTS_INFO.IP}    ${mr}=MRC-COMMON/MR-COMMON
#    ...    ${security_mode}=no TLS
#    Log to console    start register MRBTS to NetAct
#    Precondition Netact with DHCP
#    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF
#    sleep    60s
#    ${release}=     Fetch From Left    ${ENB_BUILD}    _
#    Integrate MRBTS With Netact TAF    ${BTSIP}    ${DN}    ${mr}    ${release}    ${security_mode}
#

Precondition Netact with 7500
    [Documentation]    Short description.
    Run keyword and ignore error    Postcondition Netact with TAF
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect Web Url
    taf.nms.netact.Add Web Url    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}

Integrate MRBTS With Netact TAF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${mrbts_address}: <description>
    ...        ${ENB_ID}: <description>
    ...        ${MRBTS_MO_MR}: <description>
    ...        ${MRBTS_MO_RELEASE}: <description>
    ...        ${SECURITY_MODE}: <description>
    [Arguments]    ${mrbts_address}=${BTS_INFO.IP}    ${ENB_ID}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    ${MRBTS_MO_MR}=MRC-COMMON/MR-COMMON
    ...    ${MRBTS_MO_RELEASE}=${ReleaseVers}    ${SECURITY_MODE}=no TLS    #${NETACT_NAME}=CLAB1014
    ${ip_version}=    Evaluate    ipaddress.ip_address("${mrbts_address}").version     ipaddress
    ${integration_output}=    taf.nms.netact.Integrate MRBTS With Netact    release=${MRBTS_MO_RELEASE}    mr=${MRBTS_MO_MR}
    ...    mrbts_address=${mrbts_address}    dist_name=${ENB_ID}    security_mode=${SECURITY_MODE}
    ...    ip_version=IPv${ip_version}
#    ...    mrbts_em_address=${mrbts_address}    #alias=${NETACT_NAME}
    Log    \n${integration_output}    console=${TRUE}

DeIntegrate Mrbts from Netact TAF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MRBTS_MO_DIST_NAME}: <description>
    [Arguments]    ${MRBTS_MO_DIST_NAME}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    #${NETACT_NAME}=CLAB1014
    ${deintegration_output}=    taf.nms.netact.DeIntegrate Mrbts From Netact    dist_name=${MRBTS_MO_DIST_NAME}    #alias=${NETACT_NAME}
    Log    \n${deintegration_output}    console=${TRUE}

NetAct Export Plan new
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No | Specifies the type of the export operation
    ...                  (plan/actual/reference/template/siteTemplate |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run keyword if    not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    taf.nms.netact.Export Configuration    file_name=${file_name}    local_dir=${local_dir}
    ...  dist_names=${dist_names}    operation_type=${operation_type}    file_format=RAML2
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}
    ...  Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

Check if NR exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf}: <description>
    ...
    ...    Returns:
    ...        ${SCF_NR}: <description>
    [Arguments]    ${scf}
    ${contain}  ${message}=  Run Keyword And Ignore Error   Should Contain   ${scf}  '${BTS_INFO.MRBTS}/NRBTS-${BTS_INFO.ID}/NRCELL'
    Run keyword if    '${contain}'=='PASS'    set variable    ${SCF_NR}    ${True}
    [Return]    ${SCF_NR}

Config_DHCP IPV4 for CB007500
    [Documentation]    Short description.
    # Set Connection Parameters    ip=${SWITCH_INFO.DHCPSERVERIP}    user=${SWITCH_INFO.USERNAME}    password=${SWITCH_INFO.PASSWORD}
    _Remote Command Setup    switchssh   &{Switchconfiguration}
    get connection    switchssh
    Set Client Configuration	prompt=#
    ${output}    SSHLibrary.Write    clear ip dhcp binding *
    ${output}    SSHLibrary.Write    clear ip dhcp conflict *
    ${output}    SSHLibrary.Write    conf ter
    ${output}    SSHLibrary.Write    ip dhcp pool tdltesyve
    ${output}    SSHLibrary.Write    option 43 hex 0000.0000.0104.${NETACT_SERVER_INFO.EXTEND_IP}.0b01.01
    ${output}    SSHLibrary.Write    end
    ${output}    SSHLibrary.Write    show running-config
    _Remote Command Teardown

Config_DHCP IPV4 Two Netact for CB007500
    [Documentation]    Short description.
    # Set Connection Parameters    ip=${SWITCH_INFO.DHCPSERVERIP}    user=${SWITCH_INFO.USERNAME}    password=${SWITCH_INFO.PASSWORD}
    _Remote Command Setup    switchssh   &{Switchconfiguration}
    get connection    switchssh
    Set Client Configuration	prompt=#
    ${output}    SSHLibrary.Write    clear ip dhcp binding *
    ${output}    SSHLibrary.Write    clear ip dhcp conflict *
    ${output}    SSHLibrary.Write    conf ter
    ${output}    SSHLibrary.Write    ip dhcp pool tdltesyve
    ${output}    SSHLibrary.Write    option 43 hex 0000.0000.0104.${NETACT_SERVER_INFO.EXTEND_IP}.1404.0a29.9494.0b01.01
    ${output}    SSHLibrary.Write    end
    ${output}    SSHLibrary.Write    show running-config
    _Remote Command Teardown

Config new DHCP IPV4 for CB007500
    [Documentation]    Short description.
    Open Connection To DHCP Server
    Update IPv4 VEO On DHCP Server Based On MAC
    Close Connection To DHCP Server

Common Transform Wireshark to Txt for 7500
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${wiresharkcaplogpath}: <description>
    ...        ${filterconditions}: <description>
    ...        ${txtname}: <description>
    ...
    ...    Returns:
    ...        ${retFilePath}: <description>
    [Arguments]    ${wiresharkcaplogpath}    ${filterconditions}    ${txtname}=tshark.txt
    ${retFilePath}    Set Variable    ${BTSFiles}${/}${txtname}
    ${PC_connection}    SSHLibrary.Open Connection    ${BTS_PC_INFO.IP}
    SSHLibrary.Login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    SSHLibrary.Switch Connection    ${PC_connection}
    SSHLibrary.Write    cd /home/ute/
    sleep    4s
    SSHLibrary.Write    tshark -r "${wiresharkcaplogpath}" -Y "${filterconditions}" -x -V> "${retFilePath}"
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${retFilePath}
    Comment    Append To File    ${retFilePath}    Frame 99999: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    [Return]    ${retFilePath}

Check dump message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Check_Content}: <description>
    [Arguments]    ${Check_Content}

    sftp_download    192.168.255.129    toor4nsn    oZPS0POrRieRtu    /ffs/run/config/toor4nsn/${id}    ${TEMP_LOGS_DIR}${/}${id}
    ${txtpath}    Common Transform Wireshark to Txt for 7500    ${TEMP_LOGS_DIR}${/}${id}    tcp    tshark.txt
    File Should Contain    ${txtpath}    ${Check_Content}

Recovery BTS after PNP
    [Documentation]    Short description.
    ${activepartID}=    fdsw.get_active_sw_partition    timeout=10
    fdsw.software_rollback    ${activepartID}
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec  Admin Check BTS Procedural and Blocking states  OnAir

CB007500 TC teardown
    [Documentation]    Short description.
    run keyword if    '${PNPstatus}'=='False'    Recovery BTS after PNP
    run keyword if    '${OnAirstatus}'=='False'    Recovery ENV
#    Run Keyword And Ignore Error    taf.fdsw.rc.Teardown
    Common Test Teardown

ASIK TC teardown
    [Documentation]    Short description.
    run keyword if    '${PNPstatus}'=='False'    Recovery BTS after PNP
    run keyword if    '${OnAirstatus}'=='False'    Recovery ENV
    Common Test Teardown
