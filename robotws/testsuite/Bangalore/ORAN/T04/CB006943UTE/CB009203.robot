*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com


Resource    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/CB009203_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource          ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/UTE_Common_resource.robot

Library    taf.sw.scout    WITH NAME    scout
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
#Library    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/verify_passwords.py    WITH NAME    VerifyPasswords

Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags	CRT    FL00    QCD_MN_RAN   QCP_RAN_VRF    TRUNK_SG04

*** Variables ***
${LMP_IP}                   192.168.255.129
${ROOT_USERNAME}            toor4nsn
${ROOT_PASSWORD}            oZPS0POrRieRtu


${Nemuadmin_password}     nemuuser
${toor4nsn_password}      oZPS0POrRieRtu
${sericeuser_password}    Pl(FzaYj5~c5;q
${wsuser_password}        A0zY~rP#8Mx@
${dcuser_password}        nE&e3Q*ptK8
${coam_password}          zO&n1W*ktp7
${developer_password}     $developer#

${toor4nsn_hash}          $6$ZuTtnMHn$4KLAf7LqouunwIMUd97jg3hC7dv0/D2pBrdlnchj4j7VutozJy/6KHJSLRievzXNVsWneV1man3izt9tEXXTg/
${serviceuser_hash}       $6$TULJ2v8D$sFSzI/QLy31GJzVI7kyaA8uB4JFT25qDBuDOyhWQlo.b0tKfHDLcTo/t08jXoq9NA58iJYsjdl7IXDIahQhBy.
${bigtom_hash}            $6$wM23w.q0$Bfvcmea8XXd7AJMIIISVdFkcQ5ML7lfp/sWpwIaIYVh5lBZGNNEP60/0DqeP8/IzTOEojS0PVf7/cn.OTBu0X0

&{[1]CB009203_CB006428-5G-A_Default_users_pass_check_unprotected_files}
...    QC_ID_FL00=QC_31665    QC_ID_SBTS25R3=QC_140910


*** Test Cases ***

[1]CB009203_CB006428-5G-A_Default_users_pass_check_unprotected_files
    #[Tags]    TRUNK_SG04_No    9203    QCD_MN_RAN    QCP_RAN_VRF
    #[Teardown]    run keywords
    #...      Test teardown
    #...      Set QC_Tag
	#admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
    Default_users_pass_check_unprotected_files

*** Keywords ***


Connect to BTS
    [Documentation]    SSH to BTS, by default with BTS LMP IP address.
    [Arguments]        ${ip_address}=${LMP_IP}  ${username}=${ROOT_USERNAME}
    ...                ${password}=${ROOT_PASSWORD}  ${proxy}=${None}  ${port}=22
    ...                ${alias}=cOAM_toor4nsn
    ${connection}=     ssh.Connect to  ${ip_address}
    ...                                ${username}
    ...                                ${password}
    ...                                port=${port}
    ...                                proxy=${proxy}
    ...                                alias=${alias}
    Log                Successfully connected with BTS
    ...                console=${TRUE}
    [Return]           ${connection}
Disconnect from BTS
    [Arguments]     ${connection}=cOAM_toor4nsn
    ssh.disconnect  ${connection}

Default_users_pass_check_unprotected_files
    ${conn}=    Connect to BTS
    Verify if each default passwords is not stored in plain text on BTS in file_extension  json
    Verify if each default passwords is not stored in plain text on BTS in file_extension  txt
    Verify if each default passwords is not stored in plain text on BTS in file_extension  log
    Verify if each default passwords is not stored in plain text in directory  /var/log
    Verify if each default passwords is not stored in plain text in binary file  /opt/SysAdapter/SysAdapter
    Verify if each default passwords is not stored in plain text in binary file  /opt/BTSOM/BTSOMexe
    Verify if each default passwords is not stored in plain text in popular system files
    [Teardown]    Run Keyword And Ignore Error    Disconnect from BTS    ${conn}
Test teardown
    Log to console   \n--Test teardown Started--\n
    Check BTS is OnAir
    RP Settings
    sleep    5
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    sleep    10
    interface.Common step trigger
    Log to console   \n--Test teardown completed--\n

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    coam.setup_admin    bts_host=192.168.255.129
    ${bts_status}    coam.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
    coam.teardown_admin

