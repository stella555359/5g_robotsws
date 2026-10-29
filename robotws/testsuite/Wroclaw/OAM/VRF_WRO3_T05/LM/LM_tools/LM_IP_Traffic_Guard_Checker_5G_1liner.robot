*** Settings ***
Documentation
        ...  WIP not usable
	    ...  Traffic_backup - stores file before any changes
	    ...  Traffic_file - sotres file that will be uploaded if
        ...  the file on remote server is incorect
	    ...
	    ...  Todo:
        ...  check SM, now only works for asia

Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.nms.netact
Resource        ../LM_resources/lib_SFE.robot

Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}    AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Set Suite Variable    ${5G}    TRUE    AND
...                           Get And Set Enb Parameters

Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Teardown Infomodel    AND
...                             Teardown Admin


*** Variables ***
${NMS_LAB}              srnclab2009
${ENB_ROOT_USER}        toor4nsn
${ENB_ROOT_PASS}        oZPS0POrRieRtu
@{backup_list}
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans
${SSH_IP}               192.168.255.129
@{modules_list}         SWEM for SRAN CM


*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    ${DCAP_log}=    Run    DCAP_Basic_controller start
    Log    \nStart DCAP:\n ${DCAP_log}    console=True

Provision and Check 1
    [Documentation]    This test checks if ip traffic guard is correct for SM
    Open Connection And Log In
    Log    \nIp Traffic Guard file backup started    console=True
    Get File    /ffs/run/trs_data/active/ipTrafficCapacityBackup   ${CURDIR}/../LM_resources/LM_IP_Traffic_Capacity_Backup
    Log    \nIp Traffic Guard file backup Completed    console=True

    ${ip_traff_guard}=    Run Keyword And Return Status    Check Ip Traffic File Guard
    Log    \n1.IptrafficGuard file is correct: ${ip_traff_guard}    console=True
    Run Keyword If    not ${ip_traff_guard}    SSH Command   (cd /opt/trs/bin ; ./trs-iptrafficlim-d execute SetRndParams 5 5 5)
    Run Keyword If    not ${ip_traff_guard}    Sleep    60s
    Run Keyword If    not ${ip_traff_guard}    SSH Command    (cd /opt/trs/bin ; ./trs-iptrafficlim-d execute SetRndParams 0 0 0)
    Run Keyword If    not ${ip_traff_guard}    Log    \nTraffic guard reset done, starting reboot soon    console=True
    Run Keyword If    not ${ip_traff_guard}    SSH Command    reboot
    Run Keyword If    not ${ip_traff_guard}    Sleep    60s    #waiting for reboot to start
    Run Keyword If    not ${ip_traff_guard}    Log    \nWaiting for BTS onAir    console=True
    Run Keyword If    not ${ip_traff_guard}    Wait Until keyword Succeeds   25min    1min     ENB Status Check
    Run Keyword If    not ${ip_traff_guard}    Log    \nReboot done    console=True
    Run Keyword If    not ${ip_traff_guard}    Open Connection And Log In

    ${ip_traff_file}=    Run Keyword And Return Status    Check Ip Traffic File Value
    Log    \nIp Traffic File file is correct: ${ip_traff_file}    console=True
    Run Keyword If    not ${ip_traff_file}    Put File    ${CURDIR}/../LM_resources/LM_IP_Traffic_Capacity_1liner
    ...    /ffs/run/trs_data/active/ipTrafficCapacityBackup    mode=0644
    Run Keyword If    not ${ip_traff_file}    Log    \nTraffic file uploaded starting reboot    console=True
    Run Keyword If    not ${ip_traff_file}    SSH Command    reboot
    Run Keyword If    not ${ip_traff_file}    Sleep    60s    #waiting for reboot to start
    Run Keyword If    not ${ip_traff_file}    Log    \nWaiting for BTS onAir    console=True
    Run Keyword If    not ${ip_traff_file}    Wait Until keyword Succeeds   25min    1min     ENB Status Check
    Run Keyword If    not ${ip_traff_file}    Log    \nReboot done and BTS onAir    console=True
    Run Keyword If    not ${ip_traff_file}    Open Connection And Log In
    ${ip_traff_file}=    Run Keyword And Return Status    Check Ip Traffic File Value
    Log    \nNew Ip Traffic File uploaded and file is correct: ${ip_traff_file}    console=True

    Close Connection

Final Checkpoint
    [Documentation]    This test restores initial eNB configuration and checks if it is OnAir.
    Run Keyword And Ignore Error    Wait Until keyword Succeeds   15min    1min     ENB Status Check
    #Check If Reset Counter Did Not Change
    Log    \nTest passed!    console=True


*** Keywords ***
ENB Status Check
    Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled

#WIP
Check System Module
    [Arguments]  ${alias}=default
    [Documentation]  This keyword checks SM release
    ${path}=    Set Variable  //RUNTIME_VIEW-${ENB_SIDE}//SMOD_R-*
    ${system_modules}  Query Infomodel  query=get list ${path}  alias=${alias}
    : FOR  ${system_module}  IN  @{system_modules}
    \  ${dist_name}    Get From Dictionary  ${system_module}  dist_name
    \  ${isMaster}   lib_SFE.Get Parameter From Infomodel    ${dist_name}   activeRole
    \  Run Keyword If    ${isMaster} == "Primary"    Return    ${dist_name}    #works on dual core scenario
    \  Run Keyword If    ${isMaster} == ""    Return    ${dist_name}    #works on single core scenario

Check Ip Traffic File Value
    [Documentation]  checks if 7000000 is contained in traffic file
    Start Command    (cat /ffs/run/trs_data/active/ipTrafficCapacityBackup)
    ${stdout}   Read Command Output
    #Log    \ncommand is cat /ffs/run/trs_data/active/ipTrafficCapacityBackup and output is: ${stdout}.    console=True    #uncomment only for debug
    ${isContained}    Should Contain    ${stdout}    7000000

Check Ip Traffic File Guard
    [Documentation]  checks if initRate and leakRate is equal 0
    Start Command    (cat /ffs/run/trs_data/active/ipTrafficCapacityBackup)
    ${stdout}   Read Command Output
    #Log    \ncommand is cat /ffs/run/trs_data/active/ipTrafficCapacityBackup and output is: ${stdout}.    console=True
    ${isContained}    Should Contain    ${stdout}    initRate_|0
    ${isContained}    Should Contain    ${stdout}    leakRate_|0

Open Connection And Log In
   SSHLibrary.Open Connection     ${SSH_IP}
   SSHLibrary.Login               ${ENB_ROOT_USER}        ${ENB_ROOT_PASS}

SSH Command
   [Arguments]        ${command}
    SSHLibrary.Execute Command    ${command}

Close Connection
    SSHLibrary.Close Connection

SWEM Reports Generation
    [Documentation]  This keyword generates SWEM reports based on specific module.
    : FOR  ${swem_module}  IN  @{modules_list}
    \    ${module}=    Get Module    moduleName=${swem_module}    detailed=${FALSE}
    \    Log    Generated module is:${module}    console=True
    \    ${report_id}=    Generate Reports    ${module}
    \    Log    Current module ID is:${report_id}    console=True
