*** Settings ***
Documentation
...    Author: Nicolae Bulata
...    Maintainer: Nicolae Bulata
...    Test Description: 5GC001577-GA 5GC000371 5G Node B Testability 5G Node B Unit recovery log collecting
...        and 5G NodeB supportability study
...    AC/REQ: LTE_OPR_AC_2809 / LTE_OPR_REQ_8155

#Library     ute_syslog
#Library     ute_admin_infomodel
Library     taf.transport.ssh   WITH NAME   csn
Library     SSHLibrary   WITH NAME   ssh
Library        String

Resource    ../../../resources/system.robot
Resource    ../../../resources/selenium.robot
#Resource    ../../resources/general.robot
Resource    ../../../resources/admin.robot
Resource    ../../../resources/admin_infomodel.robot
Resource    ../../../resources/pretest_posttest.robot
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh


Resource    ./Core_Dump_Common.robot
#Resource    ./OAM_Common.robot

*** Variables ***
${critical_process}=          /opt/CCS/CCSDaemonExe  #/opt/hwr/HWRClimateSExe
#${CCS_process}=               /opt/CCS/CCSDaemonExe
${fault_path_4019}=           /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/CPU_L-1
                                 #/MRBTS-1/EQM-1/SMOD-*/CCU-1/CPU-1
${availabilityStatus_NRBTS}=  regex"Offline|Failed"  #"Failed"
${PROMPT_ENB}                       :~ >


${LSS_addr}                     10.5.25.106
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${6450}=                        ${CURDIR}/6450.json
${Delta_File}=                  ${CURDIR}/delta_lss_and_triggers_faults_4527_6450.json
${BTS_ID}                       10009  #for UTE  #1  #for local  #$10009
${BTS_IP}                       192.168.255.1
${SW_DESTINATION}     /home/ute
${rf_user}                  serviceuser
${rf_password}              Pl(FzaYj5~c5;q

*** Keywords ***

5GC001577_GA-Collect logs after FCT critical process crash happens
#    [Tags]  CRT  CA_BTS_OAM_FMRECOV  QCP_BTS_OAM  QCD_MN_BTS_OAM  QC_2722879
    ADMIN INFOMODEL Check If BTS Is OnAir
    Remove Snapshot from LSS server
    Configure LSS in WebEM
    Run Keyword and Ignore Error  ADMIN.ADMIN Perform Delta Recommissioning     delta_file=${Delta_File}
    ...                                         skip_parameter_relation_errors=True
    ...                                         should_activate=True
    ...                                         timeout=300
    Start collecting BTS ping logs
    Run Keyword and Ignore Error    Prepare RMOD for SSH connection
    #Run Keyword And Continue On Failure  Check condition before kill process
    Log to console  Trigger fault 4527 on RF
    Trigger fault 4527
    Wait Until Keyword Succeeds   600   30    ADMIN Check If Alarm Is Active  fault_id=4527
    Wait Until Keyword Succeeds   600   30   ADMIN INFOMODEL Check If BTS Is OnAir
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    #wait until keyword succeeds  600  60  Check the process after collect snapshot
    Remove Snapshot from LSS server

5GC001577_GA-RF crash logs in technical log collection
    [Tags]  CRT  CA_RAN_BOAM_VERIF   QCP_RAN_ET   QCD_MN_RAN    QC_2722880   #QCP_BTS_OAM  QCD_MN_BTS_OAM
    #Check condition before kill process
    Kill radio via SSH command
   #Run Keyword And Continue On Failure  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/FRI-*/ALARM-* is [faultId=4527]   timeout=900

Kill radio via SSH command
	SYSTEM Open SSH Connection To Enb
	#SSHLibrary.Open
    SSHLibrary.Write    text=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    SSHLibrary.Read Until    expected=${PROMPT_ENB}
    SSHLibrary.Write    ssh root@192.168.254.52
    SSHLibrary.Read Until    expected=password:
    SSHLibrary.Write    root  #umniedziala
    SSHLibrary.Read Until    expected=~    #~# .
    SSHLibrary.Write    ps | grep CCSDaemonExe | awk '{print $1}' | xargs kill -11 $1
    #Sleep   10
    Run Keyword And Continue On Failure  SSHLibrary.Read Until    expected=~
    #${output}=	   SSHLibrary.Read Until Prompt
    #Run Keyword And Continue On Failure  Should contain    ${output}    closed
    SSHLibrary.Close Connection

Kill radio
    #setup enb fsm access
    execute command on enb   ps | grep CCSDaemonExe | awk '{print $1}' | xargs kill -11 $1
#    ${process_pid}=   execute command on enb    ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
#    execute command on enb   kill -11 ${process_pid}



Check core dump processing by kill fct critical process

    Run Keyword And Continue On Failure  is in faults group  active  6450  /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
    ...                                  EFaultId_TechnicalLogUploadRecommended  timeout=120
   #Run Keyword And Continue On Failure  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/FRI-*/ALARM-* is [faultId=4527]   timeout=300
    #Run Keyword And Continue On Failure  is in faults group  active  4019  ${fault_path_4019}  EFaultId_KeepAliveStatusErrorAl  timeout=90



Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /home/coam/Snapshot_MRBTS-${BTS_ID}_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    csn.disconnect    connection=LSS

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-${BTS_ID}_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /home/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=7
    csn.disconnect    connection=LSS

Wait for Site will not be pingable
	Wait Until Host Is Unavailable    ${BTS_IP}      timeout=300
	Log To Console		The site isn't pingable

Setup for Collect logs
    #Disable flag "Autonomous reset disabled" in swconfig
    #OAM_Common Setup
    #OAM_Common Setup for real TL
    #Run Keyword If  '${flag_present}'!='0'  Perform eNB reboot and wait for commissioned state

Teardown for Collect logs
   #OAM_Common Teardown
    #OAM_Common Teardown for real TL

Delta commissioning lss and triggers faults
    ADMIN Perform Delta Recommissioning                 delta_file=${Delta_File}
    ...                                                 skip_parameter_relation_errors=True

Trigger fault 4527
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
    ssh.Write    ssh ${rf_user}@${ip_rmod}
    ssh.Read Until    expected=password:
    ssh.Write    ${rf_password}
    ssh.Read Until    expected=$
    ssh.Write    ps -ef | grep -i "CCSDaemonExe" | egrep -v "grep|bash" | awk '{print $1}'
#    ${process_pid}=   ssh.Read Until    expected=#
    ${process_pid}=   ssh.Read Until    expected=$
    ssh.Write    sudo kill -11 ${process_pid}
#    ssh.Read Until    expected=#
    ssh.Read Until    expected=$
    ssh.Close Connection

Prepare RMOD for SSH connection
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
    ssh.Write    rm /user/toor4nsn/.ssh/known_hosts
    ssh.Read Until    expected=>
    ssh.Write    ssh ${rf_user}@${ip_rmod}
    ssh.Read Until    expected=?
    ssh.Write    yes
    ssh.Read Until    expected=password:
    SSHLibrary.Close Connection

Configure LSS in WebEM
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Sleep   10
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Sleep  3s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Mouse Over       locator=//span[text()="Snapshot"]
    Click Element    locator=//span[text()="LSS User Configuration"]
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="username"]
    ...    text=${LSS_username}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="newPassword"]
    ...    text=${LSS_password}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="confirmPassword"]
    ...    text=${LSS_password}
    Sleep   3s
    Click Button    locator=//*[@id="p-tabpanel-2"]/lss-user-configuration/execution-bar/div/save-lss-button/div/p-button/button
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),"Save succeeded")]
    SeleniumLibrary.Close Browser
    SELENIUM Teardown Enviroment
