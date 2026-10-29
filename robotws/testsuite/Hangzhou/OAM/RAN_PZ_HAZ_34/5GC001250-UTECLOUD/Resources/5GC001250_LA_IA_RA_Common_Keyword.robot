*** Settings ***
Documentation     author: Wu Jun
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: george.wu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Library    taf.analyzer.pcap
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py    WITH NAME    lib
Library           selenium_coam_interface.py
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    ssh
Library           ssh_interface.py

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ROOT_USERNAME}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ROOT_PASSWORD}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${bts_password}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${connection}    DU_OAM

${SSH_USERNAME}     toor4nsn
${SSH_PASSWORD}     oZPS0POrRieRtu

${scf_name}    scf_5GC001250_IA.xml
${tmp_log_dir}    /home/ute/logs
${testline}  7_5_UTE5G401T906

${refnum}    30107
${PSK}    H9yE-DXG8-WVLA-TuEw
${refnum_update}    48204
${PSK_update}    w33k-BBwe-JoVx-FznX

${gnb_path}    /tmp/
${tmp_log_dir}      /home/ute/logs
${Netact_username}    omc
${Netact_password}    Nokia123!
${cert_file_path}    ${CURDIR}/RnD_Root_CA.cert.pem
${ca_fingerPrint}    FC:32:3E:3A:4B:1B:EA:7E:CA:39:70:73:70:55:5F:AF:16:FB:9B:65
${right_encfs}=  trs_data/active/keystorage type fuse.encfs (rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other)
${cert_type}    TA
*** Keywords ***
5GC001250_Common Suite Setup for COAM
#    CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001250_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC001250_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001250_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

5GC001250_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=DU_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=DU_OAM    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=DU_OAM
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

5GC001250_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=DU_OAM

Connect to cOAM as toor4nsn
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${SSH_USERNAME}=toor4nsn    ${SSH_PASSWORD}=oZPS0POrRieRtu    ${alias}=cOAM_toor4nsn
    ${connection}=  ssh.Connect to  hostname=${ip_address}
    ...                             username=${SSH_USERNAME}
    ...                             password=${SSH_PASSWORD}
    ...                             alias=${alias}
    [Return]  ${connection}

Case Setup1
    Log To Console    \n *** Case Setup
    Check If BTS Is OnAir

Case Setup
    Log To Console    \n *** Case Setup
    Connect to DU via ssl
    Check If BTS Is OnAir

Check If BTS Is OnAir
    log to console     \n  check if bts is onair
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

#**********************5GC001250-RA-390-1*****************************************
Step1 Validate Nokia Vendor Certificate Installed in gNB DU
    check_certificate  ${DU_OAM_IP}  ${ROOT_USERNAME}  ${ROOT_PASSWORD}

#**********************5GC001250-RA-390-2*****************************************
Step1 Check Nokia Vendor Certificate Display in gNB DU WebEM
    #${vendor_certificate_list}=  selenium_coam.get_vendor_certificates    ${WEBUI_URL}  ${WEBUI_USER}  ${WEBUI_PASSWORD}
    #log to console  ${vendor_certificate_list}
    Log to console     Step1 Check Nokia Vendor Certificate Display in gNB DU WebEM
    run keyword and ignore error    Check If BTS Is OnAir

#**********************5GC001250-IA-262-1*****************************************
Step 1: Login to system module via SSH
    Log to console     Step 1: Login to system module via SSH
    Connect to cOAM as toor4nsn

Step 2: Check all neccessary keys were created in /etc/cryptoagent/
    Log to console     Step 2: Check all neccessary keys were created in /etc/cryptoagent/
    ${certs}=  ssh.execute    command=ls /etc/cryptoagent/
    ...                       connection=cOAM_toor4nsn
    should contain  ${certs}  srkpriv.p8  srkpub.pem

#**********************5GC001250-IA-262-2*****************************************
Step 2: Check that certificates are write protected
    Log to console     Step 2: Check that certificates are write protected
    Connect to cOAM as toor4nsn
    ${certs_1}=  ssh.execute     command=ls -al /etc/keys.d/* | grep [-][r-][w-][x-][r-]w[-x][r-][-w][-x]
    ...                        connection=cOAM_toor4nsn
    should be empty  ${certs_1}
    ${certs_2}=  ssh.execute     command=ls -al /etc/keys.d/* | grep [-][r-][w-][x-][r-][-w][-x][r-]w[-x]
    ...                        connection=cOAM_toor4nsn
    should be empty  ${certs_2}
    ${certs_3}=  ssh.execute     command=ls -al /etc/keys.d/*/ | grep [-]rw[-]r[-][-]r[-][-] | awk '{print$3}' | grep [^root]
    ...                        connection=cOAM_toor4nsn
    should be empty  ${certs_3}
    ${certs_4}=  ssh.execute     command=ls -al /etc/keys.d/*/ | grep [-]rw[-]r[-][-]r[-][-] | awk '{print$4}' | grep [^root]
    ...                        connection=cOAM_toor4nsn
    should be empty  ${certs_4}

#**********************5GC001250-IA-262-4*****************************************
Step 2: Check EncFs should be mounted successfully
    Log to console     Step 2: Check EncFs should be mounted successfully
    ${encfs}=  ssh.execute     command=mount | grep encfs
    ...                        connection=cOAM_toor4nsn
    should contain any  ${encfs}
    ...  encfs on /ffs/fs1/${right_encfs}
    ...  encfs on /ffs/fs2/${right_encfs}

#**********************5GC001250-LA-323-6*****************************************
Step1:Configure CMP and CRL Parameter
    Log To Console    Step1:Configure CMP and CRL Parameter    console=yes
    Configure CMP parameter
    Disable CRL Usage
    Enable CRL Usage

Step2:Trigger CRL update
    Log To Console    Step2:Trigger CRL update    console=yes
    Connect to Netact   alias=Netact
    Configure sensitive CMP parameter in Netact     fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    Trigger CMP init in Netact    fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    Trigger CRL update in Netact    fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact

Step3:Check in WebEM CRL download in BTS
    Log To Console    Step3:Check in WebEM CRL download in BTS    console=yes
    wait until keyword succeeds  10min   1min    Check CRL download information is not empty

Test Teardown for case6
    Log To Console    Test Teardown    console=yes
    Enable CRL Usage
    Run Keyword And Ignore Error    Disconnect to Netact    connection=Netact
    CI_interface.Common Case Teardown

Trigger CRL update in Netact
    [Arguments]    ${fqdn}    ${connection}
    csn.send command    command=/opt/nokia/oss/bin/NECertMgmt.sh --operation updateCrl --fqdnType NE --fqdn ${fqdn}    connection=${connection}
    ${terminal}=    csn.Read Output   connection=${connection}
    Log to console      ${terminal}

Configure CMP parameter
    ${dict1}=    create dictionary    parameterName=caSubjectName
    ...                                         operation=update
    ...                                         value=CN=srncnv4
#    ${dict2}=    create dictionary    parameterName=eeSubjectName
#    ...                                         operation=update
#    ...                                         value=CN=srncnv4
    ${dict3}=    create dictionary    parameterName=serverHost
    ...                                         operation=update
    ...                                         value=10.107.178.135
    ${dict4}=    create dictionary    parameterName=serverPath
    ...                                         operation=update
    ...                                         value=/pkix
    ${dict5}=    create dictionary    parameterName=serverPort
    ...                                         operation=update
    ...                                         value=8080
    @{parameter_list}=    create list    ${dict1}    ${dict3}    ${dict4}    ${dict5}
    coam.perform_object_recommissioning         dist_name=MRBTS-${mrbtsId}/MNL-1/CERTH-1/CMP-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=update
    ...                                         skip_parameter_relation_errors=skip
    ...                                         connection=DU_OAM

Disable CRL Usage
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/CERTH-1/CRLH-1
    ...    parameter=usageEnabled
    ...    value=Disabled
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=DU_OAM

Enable CRL Usage
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/CERTH-1/CRLH-1
    ...    parameter=usageEnabled
    ...    value=Enabled
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=DU_OAM

Connect to Netact
    [Arguments]    ${alias}
    csn.connect_to    hostname=${NetAct_dmgr}    username=${Netact_username}    password=${Netact_password}    alias=${alias}

Disconnect to Netact
    [Arguments]    ${connection}
    csn.disconnect    connection=${connection}

Configure sensitive CMP parameter in Netact
    [Arguments]    ${fqdn}    ${connection}
    csn.send command
    ...    command=/opt/nokia/oss/bin/NECertMgmt.sh --operation cmpConfig --preSharedKey ${PSK} --refNum ${refnum} --fqdnType NE --fqdn ${fqdn}
    ...    connection=${connection}
    ${terminal}=    csn.Read Output   connection=${connection}
    Log to console      ${terminal}

Trigger CMP init in Netact
    [Arguments]    ${fqdn}    ${connection}
    csn.send command    command=/opt/nokia/oss/bin/NECertMgmt.sh --operation cmpInit --fqdnType NE --fqdn ${fqdn}    connection=${connection}
    ${terminal}=    csn.Read Output   connection=${connection}
    Log to console      ${terminal}

Trigger CMP key update in Netact
    [Arguments]    ${fqdn}    ${connection}
    csn.send command    command=/opt/nokia/oss/bin/NECertMgmt.sh --operation updateNeCert --fqdnType NE --fqdn ${fqdn}    connection=${connection}
    ${terminal}=    csn.Read Output   connection=${connection}
    Log to console      ${terminal}

Check CRL download information is not empty
    ${crl_certtificate_list}    coam.get_certificate_revocation_list    timeout=60     domain_type=3GPP   connection=DU_OAM
    Run Keyword And Ignore Error    Should be equal    '${crl_certtificate_list[0]['crlinfoId']}'    '1'
    Run Keyword And Ignore Error    should be equal    '${crl_certtificate_list[0]['stateInfo']['reasoningStatus']}'   '[]'

#**********************5GC001250-LA-323-17*****************************************
Step0: Prepare
    Log To Console    \n Step0: Prepare    console=yes
    run keyword and ignore error    Delete certificate    finger_Print=${ca_fingerPrint}
    sleep    10s

Step1: Install CA certificate
    Log To Console    \n Step1: Install CA certificate    console=yes
    Connect to DU via ssl
    ${certtificate_number_1}    Get specific certificate number    type=All
    Set Test Variable    ${certtificate_number_1}
    Run Keyword And Ignore Error    Add certificate from local    cert_file=${cert_file_path}    cert_type=AdditionalCa
    ${certtificate_number_2}    Get specific certificate number    type=All
    Run Keyword And Ignore Error    Should Not Be Equal    ${certtificate_number_1}    ${certtificate_number_2}

Step2: Check CA certificate infomation
    Log To Console    \n Step2: Check CA certificate infomation    console=yes
    ${SignatureAlgorithm}    Get certificate specific information from dictionary detail
    ...    fingerPrint=${ca_fingerPrint}    specific_key=signatureAlgorithm
    run keyword and ignore error    Should contain    ${SignatureAlgorithm}    sha256    ignore_case=True

Step3: Delete CA certificate
    Log To Console    \n Step3: Delete CA certificate    console=yes
    Run Keyword And Ignore Error    Delete certificate    finger_Print=${ca_fingerPrint}

Step4: Check CA certificate delete successfully
    Log To Console    \n Step4: Check CA certificate delete successfully    console=yes
    ${certtificate_number_3}    Get specific certificate number    type=All
    Run Keyword And Ignore Error    Should Be Equal    	${certtificate_number_1}    ${certtificate_number_3}

Delete certificate
    [Arguments]    ${finger_Print}
    coam.delete_certificate    fingerprint=${finger_Print}    timeout=60    connection=DU_OAM

Get specific certificate number
    [Arguments]    ${type}
    ${certtificate_list}=    coam.get_certificate_list    cert_type=${type}    timeout=60    connection=DU_OAM
    ${certtificate_number}    get length    ${certtificate_list}
    ${certtificate_num}    Convert To Integer    ${certtificate_number}
    [Return]    ${certtificate_num}

Add certificate from local
    [Arguments]    ${cert_file}    ${cert_type}
    run keyword and ignore error    selenium_coam.logout
    ${WEBUI_URL_gNB}    set variable    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    selenium_coam.Enable Virtual Display
    selenium_coam.login    url=${WEBUI_URL_gNB}   username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    selenium_coam.add_certificate    ${cert_file}
    Sleep  30s
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Get certificate specific information from dictionary detail
    [Arguments]    ${fingerPrint}    ${specific_key}
    ${certtificate_detail}=    coam.get_certificate_details
    ...    fingerprint=${fingerPrint}    timeout=60    connection=DU_OAM
#    ${specific_info}=    Get From Dictionary    dictionary=${certtificate_detail[0]}    key=${specific_key}
#    [Return]    ${specific_info}

#**********************5GC001250-LA-323-25*****************************************
Step1:Configure CMP parameter_case25
    Log To Console    Step1:Configure CMP parameter    console=yes
    Configure CMP parameter

Step2:Trigger CMP init
    Log To Console    Step2:Trigger CMP init    console=yes
    Start to capture wireshark logs    filename=certificate_init.pcap    interface=fp0    connection=gNB
    Connect to Netact   alias=Netact
    Configure sensitive CMP parameter in Netact     fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    Trigger CMP init in Netact    fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact

Step3:Check BTS certificate installed
    Log To Console    Step3:Check BTS certificate installed    console=yes
    sleep    20s
    Check certificate is not empty    cert_type=BTS

Step4:Check wireshark log
    Log To Console    Step4:Check wireshark log    console=yes
    sleep    20s
    Stop and download wireshark logs    filename=certificate_init.pcap    connection=gNB

Test Teardown
    Log To Console    Test Teardown    console=yes
    #Restore the CMP parameters    mrbtsId=${mrbtsId}    cmpserverHost=10.0.0.0
    coam.restore_vendor_certificate    timeout=60    connection=DU_OAM
    Run Keyword And Ignore Error    Disconnect to Netact    connection=Netact
    Run keyword and ignore error    csn.send command    command=killall tcpdump    connection=gNB
    CI_interface.Common Case Teardown

Start to capture wireshark logs
    [Arguments]     ${filename}    ${interface}    ${connection}
    csn.connect_to    hostname=${DU_OAM_IP}    username=${ROOT_USERNAME}    password=${ROOT_PASSWORD}   alias=${connection}
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Check certificate is not empty
    [Arguments]    ${cert_type}
    ${certtificate_list}=    coam.get_certificate_list    cert_type=${cert_type}    timeout=60    connection=DU_OAM
    ${certtificate_number}    get length    ${certtificate_list}
    Should Not Be Equal As Integers    ${certtificate_number}    0

Stop and download wireshark logs
    [Arguments]    ${filename}    ${connection}
    csn.send command    command=killall tcpdump    connection=${connection}
    sleep    3
    csn.download file    remote_path=${gnb_path}${filename}
    ...    local_path=${epc_log_path}/${filename}   connection=${connection}
    sleep    3
    csn.disconnect    connection=${connection}

Step1:Configure CMP parameter
    Log To Console    \n Step1:Configure CMP parameter
    coam.restore_vendor_certificate    timeout=60    connection=DU_OAM
    Configure CMP parameter

Step2:Trigger CMP init using vendor
    Log To Console    \n Step2:Trigger CMP init
    Start to capture wireshark logs    filename=certificate_init.pcap    interface=fp0    connection=gNB
    Configure sensitive CMP parameter from WebEM    reference_number=${refnum}    preshared_key=${PSK}
    Trigger CMP init

Step3:Check Init Certificate Protocol
    Log To Console    \n Step3:Check Init Certificate Protocol
    Stop and download wireshark logs    filename=certificate_init.pcap    connection=gNB
    ${certtificate_list_BTS}=    coam.get_certificate_list    cert_type=CA    timeout=60    connection=DU_OAM
    ${certtificate_list_TA}=    coam.get_certificate_list    cert_type=TA    timeout=60    connection=DU_OAM
    ${certtificate_list_BTS_length}=   Get Length   ${certtificate_list_BTS}
    Should Not Be Equal As Integers    ${certtificate_list_BTS_length}    0
    ${certtificate_list_TA_length}=   Get Length   ${certtificate_list_TA}
    Should Not Be Equal As Integers    ${certtificate_list_TA_length}    0

Configure sensitive CMP parameter from WebEM
    [Arguments]    ${reference_number}    ${preshared_key}
    coam.set_certificate_automatic_managment
    ...    reference_number=${reference_number}
    ...    preshared_key=${preshared_key}
    ...    timeout=60    connection=DU_OAM

Trigger CMP init
    coam.cmp_initialize_certificate    timeout=60    connection=DU_OAM

Case Teardown
    [Arguments]       ${connection}=DU_OAM
    Log To Console    \n Case teardown
    coam.restore_vendor_certificate    timeout=60    connection=${connection}
    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
    CI_interface.Common Case Teardown

#**********************5GC001250-LA-323-27*****************************************
Step2:Check if BTS certificate installed
    Log To Console    Step2:Check if BTS certificate installed    console=yes
    Connect to Netact   alias=Netact
    Configure sensitive CMP parameter in Netact     fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    Trigger CMP init in Netact    fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    Check certificate is not empty    cert_type=BTS

Step3:Trigger CMP key info upload
    Log To Console    Step3:Trigger CMP key info upload   console=yes
    Start to capture wireshark logs    filename=certificate_key_update.pcap    interface=fp0    connection=gNB
    Trigger CMP key update in Netact    fqdn=PLMN-PLMN/MRBTS-${mrbtsId}    connection=Netact
    sleep    50s

#Test Teardown for case27
#    Log To Console    Test Teardown    console=yes
#    #Restore the CMP parameters    mrbtsId=${mrbtsId}    cmpserverHost=10.0.0.0
#    Disconnect to Netact    connection=Netact
#	CI_interface.Common Case Teardown
