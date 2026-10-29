*** Settings ***
Documentation     | Time | Release | Author | Modification |
...               | 2017.10.21 | SRAN | lin licai | first create |
...               | 2017.10.24 | SRAN | lin licai | debug pass |
...               | 2022.09.13 | SRAN | Jet Li | update for UTE |
...
...               Status: Ready to use.
Library           OperatingSystem
Library           connection.py
Library           utils.py

*** Variables ***
${G_IMP_Server}    mrbts-1
${G_IMP_User}     wsuser
${G_IMP_Passwd}    A0zY~rP#8Mx@
${G_IMP_NotifyUrl}    http://10.0.1.1:8081/services
${G_IMP_AgentId}    9876
${G_VTK_SuccessInfo}    Validation Toolkit exiting with return value 0
${G_VTK_FailureInfo}    Validation Toolkit exiting with return value 1
${G_VTK_Sequence_Error}    Checking previous sequence number increasing with 1 failed
${G_CMLib_Path}    /home/ute/cmvtk
${G_ServerIP}     10.0.1.1
${G_BTSID}        1
${G_VTKAlias}     VTKServerConn

*** Keywords ***
Prepare Cmvtk Test Env
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2022.09.13 | SRAN | Jet Li | first create |
    ...
    ...    This KW is to setup CM VTK for UTE ENV.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | N | N | N |
    ...
    ...    Return value: No
    ...
    ...    Precondition:No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | Prepare Cmvtk Test Env |
    Run    sudo rm -rf /home/ute/cmvtk && mkdir -p /home/ute/cmvtk
    #Run    wget http://10.135.73.141/artifactory/netact-fast_pass-local/tools/cm/cmvtk.zip -P /home/ute/cmvtk
	Run    sshpass -p A0zY~rP#8Mx@ scp ute@10.106.210.34:/home/ute/UTE_File_Server/cmvtk.zip /home/ute/cmvtk
	Run    cd /home/ute/cmvtk && unzip cmvtk.zip
	Run    sudo chown ute:ute /etc/hosts && sudo echo '10.0.1.2 mrbts-1' >> /etc/hosts

Prepare Ne3sVTK Test Env
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2022.09.13 | SRAN | Jet Li | first create |
    ...
    ...    This KW is to setup NE3S VTK for UTE ENV.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | N | N | N |
    ...
    ...    Return value: No
    ...
    ...    Precondition:No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | Prepare Ne3sVTK Test Env |
	Log To Console    Start install robot based on jython
    Run    sshpass -p Ut3pa5s#ff97@ scp ute@10.106.164.20:/home/ute/UTE_File_Server/robotframework-3.1.2.zip /home/ute/
	Run    cd /home/ute/ && unzip robotframework-3.1.2.zip && cd /home/ute/robotframework-3.1.2 && jython setup.py install
	${jython_robot}    Run    /opt/ute/jython/bin/robot --version
	Should Contain    ${jython_robot}    Robot Framework 3.1.2
	Log To Console    Start install NE3SVTK, this will take a long time
    Run    sshpass -p Ut3pa5s#ff97@ scp ute@10.106.164.20:/home/ute/UTE_File_Server/ValidationToolKit_21.12.zip /home/ute/
	Run    cd /home/ute/ && unzip ValidationToolKit_21.12.zip
	Log To Console    Start Configurate NE3SVTK
	${ne3svtk_path}    Set Variable    /home/ute/ValidationToolKit_21.12/NE3S_VTK/webservice
	Run    sudo chown ute:ute /etc/hosts && sudo echo '10.0.1.2 mrbts-1' >> /etc/hosts
	Run    sudo chmod -R +x /home/ute/ValidationToolKit_21.12
	Run    cd ${ne3svtk_path} && sed -i 's/1.15/1.18/' VSConfig.xml && sed -i 's/wspassword/A0zY~rP#8Mx@/' VSConfig.xml
	Run    cd ${ne3svtk_path} && sed -i 's/localhost:8080/mrbts-1:8080/' VSConfig.xml && sed -i 's/localhost:8081/10.0.1.1:8081/' VSConfig.xml

VTK Server Connect
    [Arguments]    ${Alias}= ${G_VTKAlias}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.10.26 | SRAN | lin licai | first create |
    ...    | 2022.09.13 | SRAN | Jet Li | update for UTE |
    ...
    ...    This KW is to connect to VTK server
    ...    | Input Parameters | Man. | Description |
    ...    | N | N | N |
    ...
    ...    Return value: VTK Session
    ...
    ...    Precondition: No
    ...
    ...    Exp:
    ...    | VTK Server Connect |
    ...
    ...    Status: Ready to use.
	${PC_PASSWORD}    Run    sudo cat /etc/ute/vncpasswd
    ${VTK_Connection}    Connect    ${G_ServerIP}    ute    ${PC_PASSWORD}    ${Alias}
    Set Suite Variable    ${VTK_Connection}

VTK Server Disconnect
    [Arguments]    ${Alias}=${G_VTKAlias}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.10.26 | SRAN | lin licai | first create |
    ...
    ...    This KW is to disconnect to VTK server
    ...    | Input Parameters | Man. | Description |
    ...    | N | N | N |
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Exp:
    ...    | VTK Server Disonnect |
    ...
    ...    Status: Ready to use.
    Disconnect    ${Alias}

VTK Upload Plan
    [Arguments]    ${alias}=${G_VTKAlias}    ${NotifyUrl}=${G_IMP_NotifyUrl}
    ...    ${AgentId}=${G_IMP_AgentId}    ${Server}=${G_IMP_Server}    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}
    ...    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.9.8 | SRAN | lin licai | first create |
    ...    | 2018.3.2 | SRAN | lin licai | add unregister operations for upload |
    ...    | 2022.09.13 | SRAN | Jet Li | update for UTE |
    ...    This KW is to perfrom the plan upload via VTK command.
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK_Upload_Plan |
    ${timestamp}    Get Timestamp
    ${PlanName}    Set Variable    ${TEST_LOG_DIR}/UploadPlan_${timestamp}.xml
    ${Upload_result}    Set Variable    ${TEST_LOG_DIR}/UploadFeedback_${timestamp}.xml
    ${Unregister_result}    Set Variable    ${TEST_LOG_DIR}/Unregister_${timestamp}.xml
	${cmd_p1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op upload -agenturl http://${Server}:8080/NE3S/1.0 -wsuser ${User}
	${cmd_p2}    Set Variable    -wspass ${Passwd} -planfile ${PlanName} -console_log_level ALL -service_timeout 5 -notifyurl ${NotifyUrl}
	${cmd_p3}    Set Variable    -agentid ${AgentId} >& ${Upload_result}
    Execute Shell Command     ${cmd_p1} ${cmd_p2} ${cmd_p3}    ${alias}
    ${status}    Run Keyword And Return Status    File Should Contain    ${Upload_result}    ${G_VTK_SuccessInfo}
	Run Keyword If    ${status}!=True    File Should Contain    ${Upload_result}    ${G_VTK_Sequence_Error}
    ${PlanFile}    Set Variable    ${PlanName}
    [Return]    ${PlanFile}

VTK Download Plan
    [Arguments]    ${planid}    ${PlanFile}    ${alias}=${G_VTKAlias}
    ...    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}    ${Server}=mrbts-${G_BTSID}
    ...    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}    ${Path}=${G_CMLib_Path}
    Log To Console    ${AgentId}
    Log To Console    ${User}
    Log To Console    ${Passwd}
    ${timestamp}    Get Timestamp
    ${Provision_Result}    Set Variable    ${TA_LOG_DIRECTORY}${/}DownloadFeedback_${timestamp}.xml
	${cmd_p1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op download -planfile ${PlanFile} -agenturl http://${Server}:8080/NE3S/1.0
	${cmd_p2}    Set Variable    -wsuser wsuser -wspass A0zY~rP#8Mx@ \ -notifyurl ${NotifyUrl} -dn PLMN-PLMN/MRBTS-${G_BTSID} -planid ${planid}
    Execute Shell Command    ${cmd_p1} ${cmd_p2} -service_timeout 8 \ >& ${Provision_Result}    ${alias}
    Switch Host    ${alias}
    ${status}    Run Keyword And Return Status    File Should Contain    ${Provision_Result}    ${G_VTK_SuccessInfo}
	Run Keyword If    ${status}!=True    File Should Contain    ${Provision_Result}    ${G_VTK_Sequence_Error}

VTK Activate Plan
    [Arguments]    ${planid}    ${PlanFile}    ${alias}=${G_VTKAlias}
    ...    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}    ${Server}=mrbts-${G_BTSID}
    ...    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}    ${Path}=${G_CMLib_Path}
    Log To Console    ${AgentId}
    Log To Console    ${User}
    Log To Console    ${Passwd}
    ${timestamp}    Get Timestamp
    ${Provision_Result}    Set Variable    ${TA_LOG_DIRECTORY}${/}ActivateFeedback_${timestamp}.xml
	${cmd_p1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op activate -planfile ${PlanFile} -agenturl http://${Server}:8080/NE3S/1.0
	${cmd_p2}    Set Variable    -wsuser wsuser -wspass A0zY~rP#8Mx@ \ -notifyurl ${NotifyUrl} -dn PLMN-PLMN/MRBTS-${G_BTSID} -planid ${planid}
    Execute Shell Command    ${cmd_p1} ${cmd_p2} -service_timeout 8 \ >& ${Provision_Result}    ${alias}
    Switch Host    ${alias}
    ${status}    Run Keyword And Return Status    File Should Contain    ${Provision_Result}    ${G_VTK_SuccessInfo}
	Run Keyword If    ${status}!=True    File Should Contain    ${Provision_Result}    ${G_VTK_Sequence_Error}

VTK Validate Plan
    [Arguments]    ${Planname}    ${alias}=${G_VTKAlias}    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.9.21 | SRAN | lin licai | first create |
    ...
    ...    This KW is to perfrom the plan validate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${PlanFilename} | Y | input the plan file which is already downloaded to IMP|
    ...
    ...    Return value: No
    ...
    ...    Precondition: plan file has been downloaded into IMP server
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK_Validate_PlanFile | /opt/cmvtk/20170921_plan.xml |
    ${timestamp}    Get TimeStamp
    ${ValidateResult}    Set Variable    ${TEST_LOG_DIR}/ValidateFeedback_${timestamp}.xml
    Execute Shell Command    ${Path}/netacttoolkit.sh -op ta_fastpass_validation -validator_ramlfile ${Planname} >& ${ValidateResult}    ${alias}
    File Should Contain    ${ValidateResult}    ${G_VTK_SuccessInfo}

VTK Create PlanfileByUpdate
    [Arguments]    ${DistName}    ${ParaName}    ${ParaValue}    ${LocalPlanFile}    ${CreatePlanFile}    ${alias}=${G_VTKAlias}
    ...    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.09.21 | SRAN | lin licai | first create |
    ...
    ...    This KW is to create the plan file with update the parameter value;
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Path} | Y | Input the CM VTK install path |
    ...    | ${DistName} | Y | Input the DN value for the updated parameter |
    ...    \ | ${ParaName} | Y | Input the parameter which will be updated |
    ...    | ${ParaValue} | Y | Input the parameter value for the updated parameter |
    ...    | ${LocalPlanFile} | Y | Input the local plan file |
    ...    \ | ${CreatePlanFile} | Y | Input the plan file |
    ...
    ...    Return value: No
    ...
    ...    Precondition: No.
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK_Create_PlanFilewithupdate | MRBTS-9/LNBTS-9 | actcelltrace | false | /opt/localplan.xml | /opt/newplan.xml |
	${cmd_p1}    Set Variable    sudo ${Path}/netacttoolkit.sh -op plan_generation -plan_operation update -plan_dn ${DistName} -planid 1234
	${cmd_p2}    Set Variable    -pname ${ParaName} -pvalue \ ${ParaValue} -planfile ${CreatePlanFile} -ramlfile ${LocalPlanFile}
    Execute Shell Command      ${cmd_p1} ${cmd_p2} -qualified_classname true    ${alias}
    OperatingSystem.File Should Exist    ${CreatePlanFile}

VTK Provision Plan
    [Arguments]    ${DN}    ${PlanFile}    ${alias}=${G_VTKAlias}
    ...    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}    ${Server}=${G_IMP_Server}
    ...    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.7.4 | SRAN | lin licai | first create |
    ...    | 2017.8.1 | SRAN | lin licai | 1.use >& to save the result; 2. use "Validation Toolkit exiting with return value 0" to check. \ |
    ...    | 2018.3.2 | SRAN | lin licai | add unregister operations for provision |
    ...
    ...    This KW is to provision the plan file to SBTS and check whether the result is OK.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Path} | Y | Input the CM VTK install path |
    ...    | ${DN} | Y | Input the DN value of SBTS |
    ...    \ | ${PlanFile} | Y | Input the plan file which will be provision |
    ...    | ${NotifyUrl} | Y | Input the notification URL of CM VTK |
    ...    | ${AgentId} | Y | Input the Agent id of SBTS in this CM VTK |
    ...    \ | ${Server} | Y | Input the IMP server ip |
    ...    \ | ${User} | Y | Input the User name of IMP server |
    ...    \ | ${Passwd} | Y | Input the passwd of IMP server |
    ...
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Exp:
    ...    | VTK Provision Plan | /opt/use/bin/cmvtk | PLMN-PLMN/MRBTS-809 | /opt/user/plan.xml
    ...    | http://10.106.214.10:8095/services | 9890 | mrbts-1747 | wsuser | wspasswd |
    ${timestamp}    Get Timestamp
    ${Provision_Result}    Set Variable    ${TEST_LOG_DIR}/ProvisionFeedback_${timestamp}.xml
	${cmd_p1}    Set Variable	${Path}/netacttoolkit.sh -op ne3s -ne_op provision -dn ${DN} -planid 1234 -planfile ${PlanFile} -agenturl
	${cmd_p2}    Set Variable	http://${Server}:8080/NE3S/1.0 -wsuser ${User} -wspass ${Passwd} -service_timeout 8 -notifyurl ${NotifyUrl} -agentid
    Execute Shell Command   ${cmd_p1} ${cmd_p2} ${AgentId} >& ${Provision_Result}    ${alias}
    Switch Host    ${alias}
    ${status}    Run Keyword And Return Status    File Should Contain    ${Provision_Result}    ${G_VTK_SuccessInfo}
	Run Keyword If    ${status}!=True    File Should Contain    ${Provision_Result}    ${G_VTK_Sequence_Error}

VTK Provision Plan Fail
    [Arguments]    ${DN}    ${PlanFile}    ${alias}=${G_VTKAlias}
    ...    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}    ${Server}=${G_IMP_Server}
    ...    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.7.4 | SRAN | lin licai | first create |
    ...    | 2017.8.1 | SRAN | lin licai | 1.use >& to save the result; 2. use "Validation Toolkit exiting with return value 0" to check. \ |
    ...    | 2018.3.2 | SRAN | lin licai | add unregister operations for provision |
    ...    | 2021.9.2 | SRAN | Jet Li | migrate as VTK Provision Plan Fail|
    ...
    ...    This KW is to provision the plan file to SBTS and check whether the result is fail.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Path} | Y | Input the CM VTK install path |
    ...    | ${DN} | Y | Input the DN value of SBTS |
    ...    \ | ${PlanFile} | Y | Input the plan file which will be provision |
    ...    | ${NotifyUrl} | Y | Input the notification URL of CM VTK |
    ...    | ${AgentId} | Y | Input the Agent id of SBTS in this CM VTK |
    ...    \ | ${Server} | Y | Input the IMP server ip |
    ...    \ | ${User} | Y | Input the User name of IMP server |
    ...    \ | ${Passwd} | Y | Input the passwd of IMP server |
    ...
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Exp:
    ...    | VTK Provision Plan | /opt/use/bin/cmvtk | PLMN-PLMN/MRBTS-809 |
    ...    /opt/user/plan.xml | http://10.106.214.10:8095/services | 9890 | mrbts-1747 | wsuser | wspasswd |
    ${timestamp}    Get Timestamp
    ${Provision_Result}    Set Variable    ${TEST_LOG_DIR}/ProvisionFeedback_${timestamp}.xml
	${cmd_p1}    Set Variable	${Path}/netacttoolkit.sh -op ne3s -ne_op provision -dn ${DN} -planid 1234 -planfile ${PlanFile} -agenturl
	${cmd_p2}    Set Variable	http://${Server}:8080/NE3S/1.0 -wsuser ${User} -wspass ${Passwd} -service_timeout 8 -notifyurl ${NotifyUrl} -agentid
    Execute Shell Command   ${cmd_p1} ${cmd_p2} ${AgentId} >& ${Provision_Result}    ${alias}
    Switch Host    ${alias}
    File Should Contain    ${Provision_Result}    ${G_VTK_FailureInfo}
	[Return]    ${Provision_Result}

VTK Create FullPlan
    [Arguments]    ${LocalPlanFile}    ${CreatePlanFile}    ${alias}=${G_VTKAlias}    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.08.01 | SRAN | lin licai | first create |
    ...    | 2017.08.09 | SRAN | lin licai | Remove the DN argument and update the command |
    ...
    ...    This KW is to create the Full plan file via uploaded plan file.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Path} | Y | Input the CM VTK install path |
    ...    | ${LocalPlanFile} | Y | Input the uploaded plan file |
    ...    \ | ${CreatePlanFile} | Y | Input the plan file |
    ...
    ...    Return value: No
    ...
    ...    Precondition: No.
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK Create FullPlan |
	${cmd}    Set Variable    sudo ${Path}/netacttoolkit.sh -op plan_generation -plan_operation update -plan_dn '.*' -planid 1234 -skip_errors true
    Execute Shell Command     ${cmd} -planfile ${CreatePlanFile} -ramlfile ${LocalPlanFile} -full_data true -qualified_classname true    ${alias}
    OperatingSystem.File Should Exist    ${CreatePlanFile}


VTK Provision Plan on Tls
    [Arguments]    ${DN}    ${PlanFile}    ${alias}=${G_VTKAlias}
    ...    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}    ${Server}=${G_IMP_Server}
    ...    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.7.4 | SRAN | lin licai | first create |
    ...
    ...    This KW is to provision the plan file to SBTS and check whether the result is OK.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${DN} | Y | Input the DN value of SBTS |
    ...    \ | ${PlanFile} | Y | Input the plan file which will be provision |
    ...    | ${NotifyUrl} | Y | Input the notification URL of CM VTK |
    ...    | ${AgentId} | Y | Input the Agent id of SBTS in this CM VTK |
    ...    \ | ${Server} | Y | Input the IMP server ip |
    ...    \ | ${User} | Y | Input the User name of IMP server |
    ...    \ | ${Passwd} | Y | Input the passwd of IMP server |
    ...    \| ${Path} | Y | Input the CM VTK install path |
    ...
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ${timestamp}    Get Timestamp
    ${Provision_Result}    Set Variable    ${TEST_LOG_DIR}/ProvisionFeedback_${timestamp}.xml
    Execute Shell Command    printenv | grep VTK*    ${alias}
	${cmd1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op provision -dn ${DN} -planid 1234 -planfile ${PlanFile} -agenturl
	${cmd2}    Set Variable    https://${Server}:8443/NE3S/1.0 -wsuser ${User} -wspass ${Passwd} -service_timeout 8 -notifyurl ${NotifyUrl}
    Execute Shell Command      ${cmd1} ${cmd2} -agentid ${AgentId} >& ${Provision_Result}    ${alias}
    Switch Host    ${alias}
    File Should Contain    ${Provision_Result}    ${G_VTK_SuccessInfo}

VTK Upload Plan on Tls
    [Arguments]    ${alias}=${G_VTKAlias}    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}
    ...    ${Server}=${G_IMP_Server}    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}
    ...    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2017.9.8 | SRAN | lin licai | first create |
    ...
    ...    This KW is to perfrom the plan upload via VTK command.
    ...    | Input Parameters | Man. | Description |
    ...    | ${Path} | Y | Input the CM VTK install path |
    ...    | ${NotifyUrl} | Y | Input the notification URL of CM VTK |
    ...    | ${AgentId} | Y | Input the Agent id of SBTS in this CM VTK |
    ...    \ | ${Server} | Y | Input the IMP server ip |
    ...    \ | ${User} | Y | Input the User name of IMP server |
    ...    \ | ${Passwd} | Y | Input the passwd of IMP server |
    ...
    ...
    ...    Return value: Plan file
    ...
    ...    Precondition: No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK Upload Plan on Tls |
    ${timestamp}    Get Timestamp
    ${PlanName}    Set Variable    ${TEST_LOG_DIR}/UploadPlan_${timestamp}.xml
    ${Upload_result}    Set Variable    ${TEST_LOG_DIR}/UploadFeedback_${timestamp}.xml
    Execute Shell Command    printenv | grep VTK*    ${alias}
	${cmd1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op upload -agenturl https://${Server}:8443/NE3S/1.0 -wsuser ${User} -wspass
	${cmd2}    Set Variable    ${Passwd} -planfile ${PlanName} -console_log_level ALL -service_timeout 5 -notifyurl ${NotifyUrl} -agentid ${AgentId}
    Execute Shell Command      ${cmd1} ${cmd2} >& ${Upload_result}    ${alias}
    File Should Contain    ${Upload_result}    ${G_VTK_SuccessInfo}
    ${PlanFile}    Set Variable    ${PlanName}
    [Return]    ${PlanFile}

VTK UnRegister
    [Arguments]    ${alias}=${G_VTKAlias}    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}
    ...    ${Server}=${G_IMP_Server}    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}
    ...    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2018.9.26 | SRAN | lin licai | first creatation |
    ...    This KW is to register BTSMED or SBTS with VTK.
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK Register |
    ${timestamp}    Get Timestamp
    ${unregister_result}    Set Variable    ${TEST_LOG_DIR}/unregister_${timestamp}.xml
	${cmd1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op unregister -agenturl http://${Server}:8080/NE3S/1.0 -wsuser ${User}
	${cmd2}    Set Variable    -wspass ${Passwd} -service_timeout 5 \ -notifyurl ${NotifyUrl} -agentid ${AgentId} >& ${unregister_result}
    Execute Shell Command     ${cmd1} ${cmd2}    ${alias}
    File Should Contain    ${unregister_result}    ${G_VTK_SuccessInfo}

VTK UnRegister on TLS
    [Arguments]    ${alias}=${G_VTKAlias}    ${NotifyUrl}=${G_IMP_NotifyUrl}    ${AgentId}=${G_IMP_AgentId}
    ...    ${Server}=${G_IMP_Server}    ${User}=${G_IMP_User}    ${Passwd}=${G_IMP_Passwd}
    ...    ${Path}=${G_CMLib_Path}
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2018.9.26 | SRAN | lin licai | first creatation |
    ...    This KW is to register BTSMED or SBTS with VTK.
    ...
    ...    Return value: No
    ...
    ...    Precondition: No
    ...
    ...    Status: Ready to use
    ...
    ...    Exp:
    ...    | VTK Register |
    ${timestamp}    Get Timestamp
    ${unregister_result}    Set Variable    ${TEST_LOG_DIR}/unregister_${timestamp}.xml
	${cmd1}    Set Variable    ${Path}/netacttoolkit.sh -op ne3s -ne_op unregister -agenturl https://${Server}:8443/NE3S/1.0 -wsuser ${User} -wspass
	${cmd2}    Set Variable    ${Passwd} -service_timeout 5 \ -notifyurl ${NotifyUrl} -agentid ${AgentId} >& ${unregister_result}
    Execute Shell Command    ${cmd1} ${cmd2}     ${alias}
    File Should Contain    ${unregister_result}    ${G_VTK_SuccessInfo}

Backup Jython Log
    Run    cp /home/ute/logs/log.html ${TEST_LOG_DIR}/Jython_log.html