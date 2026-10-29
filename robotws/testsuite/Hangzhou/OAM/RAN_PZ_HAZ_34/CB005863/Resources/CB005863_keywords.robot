*** Settings ***
Documentation     author: y6lu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: lu.yu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin     WITH NAME     COAM_ADMIN
Library    OperatingSystem
Library    String
Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh

Resource    ../../None_Feature_SG1/OAM_Interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           OAM_Interface.sshservice     WITH NAME     sshservice

*** Variables ***
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${PNP_Plan}     PnP_Plan_V4_trunk.xml

${DU_connection}    GNB_OAM
${UPDATE_FILE_PATH}  /opt/ute/CB005863
${LPM_IP_fp0}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LMP_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ALIAS_LMP}    asik
${LMP_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${LMP_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_URL}         https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${MO_BTS_NAME}             MRBTS-${tl.gnbs[0].instance_id}

${YAFT_PATH}         /opt/ute/CB005863/YAFT/

${HZ_NETACT_URL}           https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
${HZ_NETACT_USER}          omc
${HZ_NETACT_PASSWORD}      Nokia126_

${FDSW_DIR}      /home/ute/casetest/
${FDSWServerPath}          http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/LN
${BTSSWServerPath}         https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
${AF_PATH}    https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-central-public-remote/System_Release/0.400.1047/AirScale-0.400.1047.zip
*** Keywords ***

Login DU WEBEM
    [Arguments]     ${connection}=${DU_connection}
    wait until keyword succeeds     2s    1s
    ...      COAM_ADMIN.connect to   bts_host=${LMP_IP}
    ...      username=${WEBUI_USERNAME}
    ...      password=${WEBUI_PASSWORD}
    ...      name=${connection}

update TargetSW in DU
    Run Keyword And Ignore error    KW.TryEnableSSH
	Run Keyword And Ignore error    KW.YAFT    filename=${filename}

upload swconfig to DU by ssh
    ssh.reset_cache
    wait until keyword succeeds     8min    1s   ssh.Connect To    hostname=${LMP_IP}    username=${LMP_USERNAME}   password=${LMP_PASSWORD}
    ...    alias=SSH_connection2

	Run Keyword And Ignore error   ssh.SendCommand
	...    command=cd /rom && rm swconfig_before.txt ; mv swconfig.txt swconfig_before.txt ; touch swconfig.txt    connection=SSH_connection2

    ssh.Upload File    local_path=${swconfig_file}    remote_path=/ffs/run/swconfig.txt    connection=SSH_connection2
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=SSH_connection2

Commission with backup SCF
	wait until keyword succeeds     8min    1s   Login DU WEBEM    connection=${DU_connection}
	COAM_ADMIN.perform_commissioning    scf_file=${file}    timeout=900    connection=${DU_connection}

CMOperationManager.CreatAndValidatePnPPlan
    [Arguments]     ${filename}     ${PlanName}=TA_PnP_TL11
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
#    swing.Insert Into Text Field    FilterTextField     ${PlanName}
#    Sleep    2s
#    swing.Send Keyboard Event     VK_ENTER
#    Sleep    5s
    swing.Select From Main Menu And Wait    Tools|Workflow Engine...
    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Components In Context
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Exist    Start
    swing.Get Combobox Values      OperationListComboBox
    swing.Select From Combo Box    OperationListComboBox    Unified PnP - Direct Integration Planning
    Sleep   2s
    swing.List Components In Context

    swing.Click On Table Cell    OperationTable    3    1
#    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Sleep   10s
    swing.Insert Into Text Field    4    ${PlanName}
    swing.Insert Into Text Field    Input_File_Choose_Field     ${filename}
    Run Keyword And Ignore error    swing.Get Combobox Values      3
    swing.Select From Combo Box    3    No
    Sleep   2s
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    swing.List Windows
    swing.List Components In Context
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Create BTS configuration plan: Finished.*|^Unified PnP - COAM - Create BTS configuration plan: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Create Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Windows
    swing.Get Selected Window Title
    swing.List Components In Context
    swing.Click On Table Cell    OperationTable    5    1
    Sleep   10s
    #Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Validate configuration plan: Finished.*|^Unified PnP - COAM - Validate configuration plan: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Validate Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Windows
    swing.Get Selected Window Title
    swing.List Components In Context
    swing.Click On Table Cell    OperationTable    7    1
    Sleep   10s
    #Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Activate autoidentification: Finished.*|^Unified PnP - COAM - Activate autoidentification: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Active Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button     CloseWorkflowButton
    log to console    Create Plan Success

DownloadPackage
    [Arguments]   ${link_to_Artifact}    ${filename}    ${md5}=false    ${UPDATE_FILE_PATH}=/opt/ute/5GC000092
    [Timeout]         20 minutes
    ${result}=   run    ls ${UPDATE_FILE_PATH}/${filename}
    ${result}=	 Remove String    ${result}    '
    Return From Keyword if     '${result}'=='${UPDATE_FILE_PATH}/${filename}'
    run    wget ${link_to_Artifact}/${filename} -P ${UPDATE_FILE_PATH}
    run keyword if    '${md5}'=='true'    run    wget ${link_to_Artifact}/${filename}.md5 -P ${UPDATE_FILE_PATH}
    ${md5_src}    run keyword if    '${md5}'=='true'    run     md5sum ${UPDATE_FILE_PATH}/${filename}
    ${md5_dec}    run keyword if    '${md5}'=='true'    run     cat ${UPDATE_FILE_PATH}/${filename}.md5
    run keyword if    '${md5}'=='true'    should contain    ${md5_src}    ${md5_dec}
    ${result}=   run    ls ${UPDATE_FILE_PATH}/${filename}
    ${result}=	 Remove String    ${result}    '
    Should Be True    '${result}'=='${UPDATE_FILE_PATH}/${filename}'


KW.DownloadPackage
    log to console    \n DownloadPackage start
    [Arguments]    ${BTSSW}=0.400.664
    run     rm ${UPDATE_FILE_PATH}/*.zip
    run     rm ${UPDATE_FILE_PATH}/*.zip.md5
#    WFT.DownloadPackage    link_to_Artifact=${FDSWServerPath}    filename=${FDSW_Target}_release_BTSSM_downloadable.zip
#    ...     UPDATE_FILE_PATH=${UPDATE_FILE_PATH}
    DownloadPackage    link_to_Artifact=${BTSSWServerPath}/${TARGETSW}    filename=${FILENAME}    md5=true
    ...     UPDATE_FILE_PATH=${UPDATE_FILE_PATH}
    run     cp ${FDSW_DIR}/${FDSW_Target}_release_BTSSM_downloadable.zip ${UPDATE_FILE_PATH}
    log to console    \n DownloadPackage end

KW.UploadPackage
    [Arguments]   ${FDSWNEW}=LN_WN_FDSW19_0000_000117_000000    ${BTSSW}=6.8351.1231
    log to console    UploadPackage start
    Wait until keyword succeeds     3times   60s    NetAct.Login
    ...    url=${HZ_NETACT_URL}    username=${HZ_NETACT_USER}   password=${HZ_NETACT_PASSWORD}    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
#    ${resultFdsw}    NetAct.SWM.Upload    Path=${UPDATE_FILE_PATH}/${FDSWNEW}_release_BTSSM_downloadable.zip
#    Set Suite Variable    ${DeleteFDSW}    ${resultFdsw}
    run    cd ${UPDATE_FILE_PATH} && rm bts_sw -rf && rm btsmed* -rf && rm *pdl_validation_service_plugin.zip -rf && unzip ${FILENAME}
    ${res}    run    cd ${UPDATE_FILE_PATH}/bts_sw/ && ls TargetBD*.xml
    ${res}	Replace String	${res}   TargetBD_    ${EMPTY}
    ${res}	Replace String	${res}   .xml    ${EMPTY}
    Set Suite Variable    ${TARGETSWNAME}    ${res}
    run    cp ${UPDATE_FILE_PATH}/${FILENAME} ${UPDATE_FILE_PATH}/${TARGETSWNAME}.zip
    ${resultBTSSW}    NetAct.SWM.Upload    Path=${UPDATE_FILE_PATH}/${TARGETSWNAME}.zip
    Set Suite Variable    ${DeleteBTSSW}    ${resultBTSSW}
    run keyword if     '${DeleteBTSSW}'=='Failed'    KW.SWMDeleteTempFile
    run keyword if     '${DeleteBTSSW}'=='Failed'    Fail    upload package failed.
    log to console    UploadPackage end

KW.SWMDeleteTempFile
    Conn.ConnectTo    IP=${SWMSERVERIP}    username=${CMSERVERUSER}    password=${CMSERVERPWD}    alias=swmserver
    Conn.Execute    cmd=rm /d/oss/global/swmanager/swm_temp/${TARGETSWNAME}.* -rf    alias=swmserver
    Conn.Execute    cmd=rm /var/opt/nokia/oss/global/swm/swm_arch/${TARGETSWNAME}.* -rf    alias=swmserver
    #Conn.Execute  cmd=rm /ffs/run/config/*NCF* -rf    alias=ASIK
    Conn.Disconnect    swmserver

KW.CaseDestroy
    Log to Console    KW.CaseDestroy
    Run Keyword And Ignore error    COAM.Logout
    Run Keyword And Ignore error    NetAct.Logout
    Run Keyword And Ignore error    FDSW.DisConnect
    Run Keyword And Ignore error    run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error    run   command=killall Xvfb
    Run Keyword And Ignore error    run   command=killall geckodriver

KW.CheckCommissioned
    KW.CaseDestroy
    COAM.login
    ${btsname}    selenium_coam.get_bts_name
    log to console    btsname=${btsname}
    Should be true    ${btsname.count("${MO_BTS_NAME}")} > 0
    COAM.Logout

KW.DeleteNCF
    Conn.ConnectTo  IP=${LMP_IP}  username=${LMP_USERNAME}  password=${LMP_PASSWORD}    alias=ASIK
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

    #Conn.Execute  cmd=rm /ffs/run/config/*NCF* -rf    alias=ASIK
    Conn.Disconnect  ASIK
#    sshservice.setup    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    host=${ASIK_IP}
#    sshservice.deleteNCF

KW.FDSW.EnableSSH
    ${con}    Wait until keyword succeeds     10min    30s   rc.connect_to
    ...    ip_address=${LMP_IP}    port=443    username=${LMP_USERNAME}     password=${LMP_PASSWORD}
    FDSW.EnableSSH    ${con}
    FDSW.DisConnect
KW.COAM.EnableSSH
    COAM.Login
    COAM.EnableSSH
    COAM.Logout

KW.TryEnableSSH
    ${value}    Run Keyword And Ignore error    ssh.Connect to    hostname=${LMP_IP}    username=${LMP_USERNAME}
    ...    password=${LMP_PASSWORD}     alias=${ALIAS_LMP}
    Run Keyword And Ignore error    Conn.Disconnect    alias=${ALIAS_LMP}
    Return From Keyword if    '${value[0]}'=='PASS'
    ${value}    Run Keyword And Ignore error    KW.FDSW.EnableSSH
    Return From Keyword if    '${value[0]}'=='PASS'
    ${value}    Run Keyword And Ignore error    KW.COAM.EnableSSH
    Return From Keyword if    '${value[0]}'=='PASS'
    Fail    Enable ssh failed.

KW.YAFT
    [Arguments]    ${filename}=AS__*.zip
    ${gNBSoftwareFile}=   run    ls ${UPDATE_FILE_PATH}/${filename}
    Should Not Be Empty    ${gNBSoftwareFile}
    log    ${gNBSoftwareFile}
    ${yaft_command}=    Set Variable    cd ${YAFT_PATH} &&python ./yaft.py -i ${LMP_IP} -z ${gNBSoftwareFile} -K
    log    ${yaft_command}
    ${result}    run    ${yaft_command}
    Should Contain Any    ${result}    Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot

KW.YaftFDSW
    [Arguments]   ${filename}
    ${res}    Run Keyword And Ignore error    KW.YAFT    filename=${filename}
    Run Keyword If   '${res[0]}'!='PASS'    Power.ResetgNB
    Run Keyword If   '${res[0]}'!='PASS'    Sleep   300
#    Run Keyword If   '${res[0]}'!='PASS'    Run Keyword And Ignore error    KW.FDSW.EnableSSH
    Run Keyword If   '${res[0]}'!='PASS'    KW.YAFT    filename=${filename}

KW.CaseDestroy.AdditionalSteps.5GDU
    Log to Console    KW.CaseDestroy.AdditionalSteps.5GDU
	Run Keyword If   '${TEST_STATUS}' == 'FAIL'       Run Keyword And Ignore error    update TargetSW in DU
	Run Keyword If    "${swconfig_file}"!="${EMPTY}"    upload swconfig to DU by ssh
	...    ELSE    log to console    "no swconfig.txt in DU"
	Run Keyword And Ignore error    Commission with backup SCF
	Run Keyword And Ignore error    run   command=cd ${UPDATE_FILE_PATH};rm -rf `ls ${UPDATE_FILE_PATH}| grep -v -E "YAFT|SCF_backup|swconfig"`

KW.PreparePnPPlan
    [Arguments]   ${method}=SN
    log to console    PreparePnPPlan start
    Run    cp ${CFGFILE_PATH}/${PNP_Plan} ${LOG_PATH}/PnP_Plan.xml
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
    NetAct.CMOperationManager.NEDelete     BTSMO=PLMN-PLMN/${MO_BTS_NAME}
    log to console    Start Create New Plan
    CMOperationManager.CreatAndValidatePnPPlan   filename=${LOG_PATH}/PnP_Plan.xml   PlanName=TA_PnP_${MO_BTS_NAME}
    log to console    PreparePnPPlan end

CheckgNBReset
    ${status}    Run Keyword And Return Status    PingOAM
    Should Be True    '${status}'=='False'

PingOAM
    ${result}  run   command=ping ${LMP_IP} -c 10
    should contain    ${result}    64 bytes from ${LMP_IP}

download swconfig from DU by ssh
    [Arguments]    ${dir}    ${timestamp}
	${status}    Run Keyword And Return Status   ssh.Download File    remote_path=/ffs/run/swconfig.txt
    ...    local_path=${dir}/swconfig_${timestamp}.txt    connection=SSH_connection1

	Run Keyword If    '${status}'=='True'    Set Suite Variable    ${swconfig_file}    ${dir}/swconfig_${timestamp}.txt

YaftFDSWAndActive
    log to console    InstallFDSWAndActive start
    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF
    log to console    YAFT After delete NCF
    KW.YaftFDSW    filename=${FDSW_Target}_release_BTSSM_downloadable.zip
    Run Keyword And Ignore error    KW.TryEnableSSH
    Run Keyword And Ignore error    KW.DeleteNCF

Precondition
    ${OUTPUT DIR}    fetch from left    ${OUTPUT DIR}    artifact
    ${CFGFILE_PATH}=    Catenate    SEPARATOR=    ${OUTPUT DIR}    testline_configuration/    ${testline_name}
    Set Suite Variable    ${CFGFILE_PATH}
    log to console   testline_configuration path is ${CFGFILE_PATH}
    ${path}   ${BTSSW}    ${filename}    Split String From Right    string=${AF_PATH}   separator=/     max_split=2
    Set Suite Variable    ${FILENAME}    ${filename}
    Set Suite Variable    ${TARGETSW}    ${BTSSW}
    Set Suite Variable    ${FDSW_Target}    ${fdswOld}
    log to console    \n save Current SCF file
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    wait until keyword succeeds     5min    1s   Login DU WEBEM    connection=${DU_connection}
    ${file}    COAM_ADMIN.get_current_scf_file    local_dir_path=${UPDATE_FILE_PATH}    file_name=SCF_backup_${timestamp}.xml
    ...    connection=${DU_connection}
	Set Suite Variable    ${file}

    log to console    \n save Current Swconfig file
	${timestamp}    Get current date    result_format=%Y%m%d%H%M%Sg
	ssh.reset_cache
    wait until keyword succeeds     8min    1s   ssh.Connect To    hostname=${LMP_IP}    username=${LMP_USERNAME}   password=${LMP_PASSWORD}
    ...    alias=SSH_connection1
	ssh.SendCommand    command=cd /rom && ls /rom |grep -x swconfig.txt     connection=SSH_connection1
	${result} =    ssh.read_output   connection=SSH_connection1
	${result}    fetch from left    ${result}    \n
    Run Keyword If    "${result}"=="swconfig.txt"     download swconfig from DU by ssh    dir=${UPDATE_FILE_PATH}    timestamp=${timestamp}
