*** Settings ***
Documentation     [PURPOSE]
#Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/RobotWS_HFV2.robot
#Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/RobotWS.robot
#Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Lib/OAM3_Autoconnection_resources.robot


*** Variables ***
${OfflinePlanFileName}                newMRBTSplan.xml
${IsUIvalue}                          false
${SW_Target_Path}                     /home/ute/BTSSW_bak
${ConfigReset_expect_time}            600
&{BTSsshConfig}          host_IP=192.168.255.1    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu
&{TRSsshConfig}          host_IP=192.168.255.129    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu
${BTS_OnAir_Timeout}                  900


*** Keywords ***
RP001540_A_05_01_Trigger Autoconnection by HW ID with DHCP after Power-up at SBTS20A
    [Documentation]    Short description.
    Step1: prepare package on NMS
    Step2: prepare plan with HWID on NMS
    Step3: Configuration Reset for PR001540
    Step4: Start Autoconection and Autoconfiguration for HWID
    Step5: Check PnP Log and result
    [Teardown]    Postcondition Netact with TAF

RP001540_A_05_03_Trigger AutoConnection with SiteID information with DHCP
    [Documentation]    Short description.
    Step1: prepare package on NMS
    Step2: prepare plan with SITEID on NMS
    Step3: Configuration Reset for PR001540
    Step4: Start Autoconection and Autoconfiguration for SiteID
    Step5: Check PnP Log and result
    [Teardown]    Postcondition Netact with TAF

Step1: prepare package on NMS
    [Documentation]    Short description.
    Log Step Header    Step1: prepare package on NMS
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    set test variable    ${NetAct_CM_ExportFileName}           ${BTS_INFO.ID}_explort_SCF.xml
    Precondition Netact with TAF
    Prepare BTS ENV and Netact package

Step2: prepare plan with HWID on NMS
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with HWID on NMS

    register MRBTS to NetAct    ${ReleaseVers}
    Creation of Site configuration plan with HWID    ${newBTSID}
    Prepare AutoConnection Parameters
    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    RP001540_R3.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}
    _back to passive package

Step2: prepare plan with SITEID on NMS
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with SITEID on NMS
    register MRBTS to NetAct    ${ReleaseVers}
    Creation of Site configuration plan with SiteID    ${newBTSID}
    Prepare AutoConnection Parameters
    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    RP001540_R3.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}
    ${SCF_NR}    Check if NR exist    ${Temp Logs Dir}${/}SCF.xml
    _back to passive package

Step3: Configuration Reset for PR001540
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${user}: <description>
    ...        ${pass}: <description>
    Log Step Header    Step3: Configuration Reset for CB007500
    [Arguments]    ${user}=Nemuadmin    ${pass}=nemuuser
    Log to console    start to configuration reset
    ${ConfigResetStartTime}=    Get Current Date
    Start Admin    username=${user}    password=${pass}    alias=hfv
    taf.sbts.oam.coam.admin.Reset Configuration    true    true    alias=hfv    timeout=800
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    Wait Until Keyword Succeeds  10 min  5 sec  Admin Check BTS Procedural and Blocking states  NotCommissioned
    ${ConfigResetEndTime}=    Get Current Date
    ${ConfigReset_KPI_check}=    Operation_KPI_Check    ${ConfigResetEndTime}    ${ConfigResetStartTime}    ${ConfigReset_expect_time}
    ...    ConfigReset_BTS_KPI
    set suite variable    ${ConfigResetEndTime}
    set suite variable    ${ConfigResetStartTime}

Step4: Start Autoconection and Autoconfiguration for HWID
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection
    Manual AutoConnection
    run keyword and ignore error    Capture tcpdump for whole process    1540_1

Step4: Start Autoconection and Autoconfiguration for SiteID
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection for SiteID
    Manual AutoConnection
    Manual site configuration
    run keyword and ignore error    Capture tcpdump for whole process    1540_2

Step5: Check PnP Log and result
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MRBTS_MO_DIST_NAME}: <description>
    [Arguments]    ${MRBTS_MO_DIST_NAME}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    Log Step Header   Step5: Check PnP Log and result
    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout} s  10 sec  Admin Check BTS Procedural and Blocking states
    ...   OnAir    alias=default
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    RP001540_B_05_04_PnP report uploading to WebUI
    #RP001540_B_ST_05_05_PnP report uploading to Netact

RP001540_B_05_04_PnP report uploading to WebUI
    [Documentation]    Short description.
    Log Step Header    start check PnP report from WebUI
    Start Admin    alias=hfv
    ${Report}    taf.sbts.oam.coam.admin.Get Pnp Report
    ...    ${Temp Logs Dir}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt    alias=hfv
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    ${IdserverIP}    Get IdserverIP
    ${Report}    OperatingSystem.Get File    ${Temp Logs Dir}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt
    should contain    ${Report}    Starting Auto Connection
    should contain    ${Report}    NMS identification successful
    should contain    ${Report}    SW download success
    should contain    ${Report}    Configuration plan activation success
    should contain    ${Report}    Autoconfiguration completed
    should contain    ${Report}    Receive ReRegisterNotificationACK with status OK, URL = http://${IdserverIP}:80/NE3S/1.0
    ${starttimeline}    Get Lines Containing String    ${Report}    Starting Auto Connection
    ${endtimeline}    Get Lines Containing String    ${Report}    NMS has registered on NE
    ${starttime}    Get Substring    ${starttimeline}    0    23
    ${endtime}    Get Substring    ${endtimeline}    0    23
    ${Duration}    DateTime.Subtract Date From Date    ${endtime}    ${starttime}
    comment    Should Be True    ${Duration}<600

RP001540_B_ST_05_05_PnP report uploading to Netact
    [Documentation]    Short description.
    Log Step Header    start check PnP report from NetAct
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    #${reportID}    get substring    00${newBTSID}    -5
    ${PnPnode}    Get regexp Matches     ${NETACT_SERVER_INFO.URL}    clab[0-9]+
    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    #SSHLibrary.Execute Command     ls -lh
    sleep    2s
    SSHLibrary.Execute Command     cd /d/oss/global/pnpreport/ne3sws
    sleep    3s
    ${reportlist}    SSHLibrary.Execute Command     ls | grep _${newBTSID}.
    ${reportcount1}    string.get line count    ${reportlist}
    ${reportcount}    Evaluate    ${reportcount1}-1
    ${reportname}    string.get line    ${reportlist}    ${reportcount}
    ${AutoconReport_content}    SSHLibrary.Execute Command     cat ${reportname}
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
    @{releaselist}    split string    ${PnPSWversion}    _
    set test variable    ${ReleaseVers}    ${releaselist[0]}
    Log    Start to import sw to netact
    CB007500_Import_SW_to_NetAct    ${PnPSWversion}
    Log    Finished to import sw to netact

Check Cert
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Certcont}: <description>
    [Arguments]    ${Certcont}
    ta_ssh_telnet.Connect To Host    host=192.168.255.1    port=22    username=toor4nsn    password=oZPS0POrRieRtu
    ...    conn_type=SSH    prompt=>    timeout=30
    ta_ssh_telnet.Set Shell Timeout    10
    ta_ssh_telnet.Set Shell Prompt    $
    ta_ssh_telnet.Execute Shell Command    cd /ffs/fs1/trs_data/active/keystorage
    ${certfile}=    ta_ssh_telnet.Execute Shell Command    ls
    log    ${certfile}
    Should Be Equal    '${certfile}'    ${Certcont}

PnP_COAM_Site_Preparation_By_WFE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [Arguments]    ${PnPPlanfile}
    Log to console    start PnP_COAM_Site_Preparation_By_WFE
    ${myPlanName}    Set Variable    planfilefor${BTS_INFO.ID}
    Set Test Variable    ${myPlanName}
    ${cmd}=    Catenate    SEPARATOR=${SPACE}
    ...    racclimx.sh -op Unified_PnP_COAM_Site_Preparation -planName ${myPlanName} -UIValues false
    ...    -fileFormat RAML2 -inputFile /var/opt/oss/global/racops/import/tempPnPFileName.xml -v
    Log    ${cmd}

    Run Keyword And Ignore Error    NetAct Delete Plan    ${myPlanName}    ${myPlanName}
    sftp upload    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ...    ${PnPPlanfile}    /var/opt/oss/global/racops/import/tempPnPFileName.xml
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    Write    ${cmd}
    ${COAM_Site_Preparation_log}    Read Until    @
    log    ${COAM_Site_Preparation_log}

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
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    Write    ${cmd}
    ${COAM_Site_Preparation_log}    Read Until    @
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
    ...  Replace String Using Regexp    ${sw_build}    ${release}_    SBTS00_
    ...    ELSE    Set variable    ${sw_build}
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}    Choose_Mid_Server4Netact
    run keyword if  "${status}"=="False"    build_download_upload_on_remote_server_and_import_to_Netact    ${sw_package_build}
    ...    ${release}    Basic    ${Mid_Server}    ${Mid_Server_usr}    ${Mid_Server_pwd}
    ${status}    CB007500_Check Plungin In NetAct    ${sw_build}
    should be true     "${status}"=="True"
    Log    Finished to import SW to NetAct

CB007500_Check Plungin In NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_build}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
    [Arguments]    ${sw_build}
    Precondition Netact with TAF
    ${status}    taf.nms.netact.Is Imported    ${sw_build}
    Postcondition Netact with TAF
    [Return]    ${status}

Creation of Site configuration plan with HWID
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
    Log to console    start to Creation of Site configuration plan with HWID
    Start Admin_MRAT    alias=get_scf
    taf.sbts.oam.coam.admin.Collect Scf   ${TEMP_LOGS_DIR}${/}SCF.xml     export_type=configuration   timeout=600    alias=get_scf
    taf.sbts.oam.coam.admin.Teardown Admin    alias=get_scf
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    NetAct Export Plan new   ${TEMP_LOGS_DIR}    ${NetAct_CM_ExportFileName}    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ...    ${NetAct_CM_ExportFileName}    actual

    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}${NetAct_CM_ExportFileName}
    ${xpath}    set variable    //*[@class='MNL']
    ta_xml_interface.Add Xml Element    ${xml}    ${TEMP_LOGS_DIR}${/}temp.xml    <p name="plannedSWReleaseVersion">${PnPSWversion}</p>|${xpath}
    ta_xml_interface.add_xml_element    ${TEMP_LOGS_DIR}${/}temp.xml    ${TEMP_LOGS_DIR}${/}temp1.xml
    ...    <p name="AutoConnHWID">${BTS_INFO.CORE_SERIAL_NUMBER}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element    ${TEMP_LOGS_DIR}${/}temp1.xml    ${TEMP_LOGS_DIR}${/}temp2.xml
    ...    <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}temp2.xml
    ${xml2}    Replace String Using Regexp    ${xml}    BTS-${BTS_INFO.ID}    BTS-${newBTSID}
    ${newxml}    Replace String Using Regexp    ${xml2}    id="[0-9]*"    operation="create"
    ta_xml_interface.add_xml_element    ${newxml}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}    ${INTEMO}
    set test variable    ${PnPPlanfile}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}
    set test variable    ${ReleaseVers}

Creation of Site configuration plan with SiteID
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
    BuiltIn.Log To Console    start to Creation of Site configuration plan with SiteID
    Start Admin_MRAT    alias=get_scf
    taf.sbts.oam.coam.admin.Collect Scf   ${TEMP_LOGS_DIR}${/}SCF.xml     export_type=configuration   timeout=600    alias=get_scf
    taf.sbts.oam.coam.admin.Teardown Admin    alias=get_scf
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    NetAct Export Plan new   ${TEMP_LOGS_DIR}    ${NetAct_CM_ExportFileName}    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ...    ${NetAct_CM_ExportFileName}    actual

    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}${NetAct_CM_ExportFileName}
    ${xpath}    set variable    //*[@class='MNL']
    ta_xml_interface.add_xml_element    ${xml}    ${TEMP_LOGS_DIR}${/}temp.xml    <p name="plannedSWReleaseVersion">${PnPSWversion}</p>|${xpath}
    ta_xml_interface.add_xml_element    ${TEMP_LOGS_DIR}${/}temp.xml    ${TEMP_LOGS_DIR}${/}temp1.xml
    ...    <p name="AutoConnSiteID">Site${newBTSID}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element    ${TEMP_LOGS_DIR}${/}temp1.xml    ${TEMP_LOGS_DIR}${/}temp2.xml
    ...    <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']
    Comment    XML.save xml    ${xml}    ${TEMP_LOGS_DIR}${/}temp.xml
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}temp2.xml
    ${xml2}    Replace String Using Regexp    ${xml}    BTS-${BTS_INFO.ID}    BTS-${newBTSID}
    ${newxml}    Replace String Using Regexp    ${xml2}    id="[0-9]*"    operation="create"
    ta_xml_interface.add_xml_element    ${newxml}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}    ${INTEMO}
    set test variable    ${PnPPlanfile}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}
    set test variable    ${ReleaseVers}

Creation of Site configuration plan with GPS
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
    BuiltIn.Log To Console    start to Creation of Site configuration plan with GPS
    Start Admin_MRAT    alias=get_scf
    taf.sbts.oam.coam.admin.Collect Scf   ${TEMP_LOGS_DIR}${/}SCF.xml     export_type=configuration   timeout=600    alias=get_scf
    taf.sbts.oam.coam.admin.Teardown Admin    alias=get_scf
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    NetAct Export Plan new  ${TEMP_LOGS_DIR}  ${NetAct_CM_ExportFileName}  PLMN-PLMN/MRBTS-${BTS_INFO.ID}  ${NetAct_CM_ExportFileName}  actual
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}${NetAct_CM_ExportFileName}
    ${xpath}    set variable    //*[@class='MNL']
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    ta_xml_interface.add_xml_element    ${xml}    ${TEMP_LOGS_DIR}${/}temp.xml  <p name="plannedSWReleaseVersion">${PnPSWversion}</p>|${xpath}
    ta_xml_interface.add_xml_element  ${TEMP_LOGS_DIR}${/}temp.xml  ${TEMP_LOGS_DIR}${/}temp1.xml
    ...    <p name="AutoConnHWID">${BTS_INFO.CORE_SERIAL_NUMBER}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${TEMP_LOGS_DIR}${/}temp1.xml  ${TEMP_LOGS_DIR}${/}temp.xml
    ...    <p name="siteId">GPSSite${newBTSID}</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element  ${TEMP_LOGS_DIR}${/}temp.xml  ${TEMP_LOGS_DIR}${/}temp1.xml  <p name="siteCId">1</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element
    ...    ${TEMP_LOGS_DIR}${/}temp1.xml  ${TEMP_LOGS_DIR}${/}temp.xml  <p name="$maintenanceRegionId">PNP</p>|//*[@class='MRBTS']
    ta_xml_interface.add_xml_element
    ...    ${TEMP_LOGS_DIR}${/}temp.xml  ${TEMP_LOGS_DIR}${/}temp1.xml  <p name="$maintenanceRegionCId">1</p>|//*[@class='MRBTS']
    ${xml}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}temp1.xml
    ${xml2}    Replace String Using Regexp    ${xml}    BTS-${BTS_INFO.ID}    BTS-${newBTSID}
    ${newxml}    Replace String Using Regexp    ${xml2}    id="[0-9]*"    operation="create"
    ta_xml_interface.add_xml_element  ${newxml}  ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}    ${INTEMO}
    set test variable    ${PnPPlanfile}    ${TEMP_LOGS_DIR}${/}${OfflinePlanFileName}
    set test variable    ${ReleaseVers}

Get IdserverIp
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${IdserverIp}: <description>
    @{string}    split string    ${NETACT_SERVER_INFO.IP}    .
    log    ${string[0]}
    ${NodeID}    Evaluate    ${string[3]}+11
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
    ${NetActConnection}    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    Write    /opt/cpf/sbin/netact_status.sh status service PnP
    ${Node Status}    Read Until    @
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
    FOR  ${ID}  IN RANGE    ${1}    ${20}
        ${result}=    run keyword and ignore error    Get Parameter Value By Admin    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}
        ${NPID}    set variable if    "${result[0]}"=="PASS"    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}    ${NPID}
    END
    ${vlanIdresult}    run keyword and ignore error    Get Parameter Value By Admin
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/ETHSVC_A-1/ETHIF_A-1/VLANIF_A-1    vlanId
    ${localIpPrefixLength1}    run keyword and ignore error    Get Parameter Value By Admin
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-1/IPADDRESSV4_A-1    localIpPrefixLength
    ${localIpPrefixLength2}    run keyword and ignore error    Get Parameter Value By Admin
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-2/IPADDRESSV4_A-1    localIpPrefixLength
    ${IPIFDN}    set variable if     '${localIpPrefixLength1[0]}'=='PASS'
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-1
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPIF_A-2
    ${netPre}    Get Parameter Value By Admin    ${IPIFDN}/IPADDRESSV4_A-1    localIpPrefixLength
    ${IPIFinterfaceDN}    Get Parameter Value By Admin    ${IPIFDN}    interfaceDN
    ${staticRoutes}    Get Parameter Value By Admin   ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/TNLSVC_A-1/TNL_A-1/IPNO_A-1/IPRT_A-1
    ...    staticRoutes
    ${type}    Evaluate    type($staticRoutes)
    ${gateway}    Get From Dictionary    ${staticRoutes}[0]    gateway
    ${netPre}    Evaluate    int(${netPre})
    ${vlanId}    run keyword if    "${vlanIdresult[0]}"=="PASS"     Evaluate    int(${vlanIdresult[1]})
    Set test variable    ${vlanIdresult}
    Set test variable    ${IPIFinterfaceDN}
    Set test variable    ${gateway}
    Set test variable    ${netPre}
    Set test variable    ${vlanId}

Manual AutoConnection
    [Documentation]    Short description.
    Log to console    start to Manual AutoConnection on Admin
    ${IdserverIP}    Get IdserverIP
    Start Admin    alias=hfv
    ${netPre}    Evaluate    int(${netPre})
    ${vlanId}    run keyword and ignore error    Evaluate    int(${vlanIdresult[1]})
    run keyword if    '${vlanIdresult[0]}'=='PASS' and 'VLANIF' in '${IPIFinterfaceDN}'    taf.sbts.oam.coam.admin.Set Autoconnection Transport Params
    ...    alias=hfv    mPlaneIpAddress=${BTS_INFO.IP}    mPlaneIpPrefix=${netPre}    defaultGateway=${gateway}
    ...    identificationServerIpAddress=${IdserverIP}    vlanId=${vlanId[1]}
    ...    ELSE    taf.sbts.oam.coam.admin.Set Autoconnection Transport Params  alias=hfv  mPlaneIpAddress=${BTS_INFO.IP}  mPlaneIpPrefix=${netPre}
    ...    defaultGateway=${gateway}    identificationServerIpAddress=${IdserverIP}
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv

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
    Start Admin    alias=hfv
    taf.sbts.oam.coam.admin.Set Autoconnection Site Id    Site${newBTSID}    alias=hfv
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv

Recovery Env
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    15min    30s    _Perform Full Commision By Admin    ${Temp Logs Dir}${/}BACK_SCF.xml

Delete Plan With GPS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${registedPlanBTSID}: <description>
    [Arguments]    ${registedPlanBTSID}=${BTS_INFO.ID}
    run keyword and ignore error    Get BTS registed RowID    ${registedPlanBTSID}
    ${netact_connection}    Connect To NetAct
    ta_ssh_telnet.Switch Host Connection    ${netact_connection}
    ta_ssh_telnet.Execute Shell Command    ssh ${PnPNode}
    run keyword and ignore error    ta_ssh_telnet.Execute Shell Command
    ...    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op deleteData -deleteFrom connected -rowId ${ListConnectedRowID}
    run keyword and ignore error    ta_ssh_telnet.Execute Shell Command
    ...    /opt/oss/Nokia-pnpautoconnection/bin/pnpclimx.sh -op deleteData -deleteFrom planned -rowId ${ListPlannedRowID}
    run keyword and ignore error    Stop And Collect Syslog    alias=enb
    run keyword and ignore error    taf.sbts.oam.coam.admin.Collect Snapshot    ${Temp Logs Dir}${/}snapshot.zip

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
    ta_ssh_telnet.Switch Host Connection    ${netact_connection}
    ta_ssh_telnet.Set Shell Timeout    30s
    ta_ssh_telnet.Execute Shell Command    ssh ${PnPnode}node07
    ta_ssh_telnet.Execute Shell Command    ls -lh
    ta_ssh_telnet.Execute Shell Command    cd /d/oss/global/pnpreport/ne3sws
    run keyword and ignore error    ta_ssh_telnet.Execute Shell Command    rm *AutoconfigurationReport_${reportID}
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

Capture tcpdump
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${id}: <description>
    [Arguments]    ${id}
    set test variable    ${id}
    Start TCP dump for PnP    ${id}1
    wait until keyword Succeeds    20min    5s    Check Pnp process pass    NMS identification successful
    Stop tcpdump for PnP
    wait until keyword Succeeds    20min    5s    Check Pnp process pass    BTS configuration provision
    Start TCP dump for PnP    ${id}2
    linux_ping.Wait Until Ping Failed    192.168.255.1    300
    Start TCP dump for PnP    ${id}3
    wait until keyword Succeeds    10min    5s    Check Pnp process pass    Autoconfiguration completed
    [Teardown]    Save Tcpdump File For PnP

Capture tcpdump for whole process
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${id}: <description>
    [Arguments]    ${id}
    #Start Admin    alias=checkreport
    when log to console with time    start to check NMS identification successful
    set test variable    ${id}
    Start TCP dump for PnP    ${id}1
    wait until keyword Succeeds    15min    5s    Check Pnp process pass    NMS identification successful
    when log to console with time   NMS identification successful
    wait until keyword Succeeds    20min    5s    Check Pnp process pass    SW download success
    when log to console with time    SW download success
    #Start TCP dump for PnP    ${id}2
    Wait for target to be not reachable  hostname=192.168.255.1  timeout=600
    when log to console with time   start to check BTS configuration provision
    Start TCP dump for PnP    ${id}3
    #Log    check BTS configuration provision successful    console=${true}
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.1  timeout=600
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed after Planfile download during autoconfiguration.  console=${true}
    when log to console with time   start to check Autoconfiguration completed
    Start TCP dump for PnP    ${id}4
    wait until keyword Succeeds    10min    5s    Check Pnp process pass    Autoconfiguration completed
    when log to console with time   check Autoconfiguration completed successful
    #Stop tcpdump for PnP
    [Teardown]    Save Tcpdump File For PnP

Start TCP dump for PnP
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${id}: <description>
    [Arguments]    ${id}
    set test variable    ${id}
    ${command}   set variable    tcpdump -i any -s 0 -n -nn -w /ffs/run/config/toor4nsn/${id}
    ${tcpdumpoutput}    Execute Remote Command and Return Output    ${command}    ssh    &{TRSsshConfig}
    when log to console with time  TCP dump for PnP started

check startup status
    [Documentation]    Short description.
    when log to console with time   Waiting for ping return
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=600
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout

    ${ping stable status}     Run Keyword And Return Status  Check If Target Is Stable  192.168.255.129
    ...  min_uptime=20  max_downtime=0  timeout=35
    Run keyword if    not ${ping_regain}  Fail  Ping has not been stable
    Set Connection Parameters  ip=192.168.255.129  user=toor4nsn  password=oZPS0POrRieRtu
    ${startupstauts}   Run Remote Linux Command    find /ffs/run/config/toor4nsn

    run keyword if  '''No such file or directory''' in '''${startupstauts}'''  run keyword  Fail  Startup does not finish
    when log to console with time  BTS has Startup

Stop tcpdump for PnP
    [Documentation]    Short description.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Set Connection Parameters  ip=192.168.255.129  user=toor4nsn  password=oZPS0POrRieRtu
    ${stoptcpdump}   Run Remote Linux Command    kill `pgrep tcpdump`

Save Tcpdump File For PnP
    [Documentation]    Short description.
    Stop tcpdump for PnP
    Run Keyword And Ignore Error  Get File From System Module  source_path=/rom/config/toor4nsn/${id}1  destination_path=${Temp Logs Dir}${/}
    Run Keyword And Ignore Error  Get File From System Module  source_path=/rom/config/toor4nsn/${id}2  destination_path=${Temp Logs Dir}${/}
    Run Keyword And Ignore Error  Get File From System Module  source_path=/rom/config/toor4nsn/${id}3  destination_path=${Temp Logs Dir}${/}
    Run Keyword And Ignore Error  Get File From System Module  source_path=/rom/config/toor4nsn/${id}4  destination_path=${Temp Logs Dir}${/}

Check Pnp process pass
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${process}: <description>
    [Arguments]    ${process}
    Start Admin    alias=checkreport
    ${Report}    taf.sbts.oam.coam.admin.Get Pnp Report
    ...    ${Temp Logs Dir}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt    alias=checkreport
    taf.sbts.oam.coam.admin.Teardown Admin    alias=checkreport
    ${reportcontent}    OperatingSystem.Get File    ${Temp Logs Dir}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt
    should contain    ${reportcontent}    ${process}

register MRBTS to NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${release}: <description>
    ...        ${DN}: <description>
    ...        ${BTSIP}: <description>
    ...        ${mr}: <description>
    ...        ${security_mode}: <description>
    [Arguments]    ${release}=${ReleaseVers}FSM3    ${DN}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    ${BTSIP}=${BTS_INFO.IP}    ${mr}=MRC-COMMON/MR-COMMON
    ...    ${security_mode}=no TLS
    Log to console    start register MRBTS to NetAct
    Precondition Netact with TAF
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF
    sleep    60s
    Integrate MRBTS With Netact TAF    ${BTSIP}    ${DN}    ${release}    ${mr}    ${security_mode}

Integrate MRBTS With Netact TAF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${mrbts_address}: <description>
    ...        ${ENB_ID}: <description>
    ...        ${MRBTS_MO_RELEASE}: <description>
    ...        ${MRBTS_MO_MR}: <description>
    ...        ${SECURITY_MODE}: <description>
    [Arguments]    ${mrbts_address}=${BTS_INFO.IP}    ${ENB_ID}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}    ${MRBTS_MO_RELEASE}=${ReleaseVers}FSM3
    ...    ${MRBTS_MO_MR}=MRC-COMMON/MR-COMMON    ${SECURITY_MODE}=no TLS    #${NETACT_NAME}=CLAB1014
    ${integration_output}=    taf.nms.netact.Integrate MRBTS With Netact    release=${MRBTS_MO_RELEASE}    mr=${MRBTS_MO_MR}
    ...    mrbts_address=${mrbts_address}    dist_name=${ENB_ID}    security_mode=${SECURITY_MODE}
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
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
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

_back to passive package
    [Documentation]    Short description.
    Log to console    Start to go back to passive package
    Start Admin
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    ${PASSIVE_SW_Version}    run keyword if
    ...  '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${PASSIVE_SW_BEFORE}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${PASSIVE_SW_BEFORE}
    ${passiveSWbuild_path}    Download_Specify_Build_By_Aria    ${PASSIVE_SW_Version}    Basic    ${SW_Target_Path}/
    Start Admin    alias=SWupdatetopassive
    taf.sbts.oam.coam.admin.update software    sw_package=${passiveSWbuild_path}    should_activate=True    timeout=30min    alias=SWupdatetopassive
    taf.sbts.oam.coam.admin.Teardown admin    alias=SWupdatetopassive
    #Linux_ping.Wait Until Ping Failed    ${BTS_INFO.IP}    timeout=500
    sleep    5min
    ${ACTIVE_SW_after}    ${PASSIVE_SW_after}    Admin Get BTS SW Version
    should be True    '${ACTIVE_SW_after}'=='${PASSIVE_SW_BEFORE}'
    Wait Until Keyword Succeeds  15 min  10 sec   Admin Check BTS Procedural and Blocking states  OnAir
    Log to console    Finished to SW update to passive package
