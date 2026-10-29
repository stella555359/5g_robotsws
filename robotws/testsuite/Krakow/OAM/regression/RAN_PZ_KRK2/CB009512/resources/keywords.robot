*** Settings ***
Documentation
...    Author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Library        OperatingSystem
Library        taf.transport.ssh        WITH NAME   ssh
Library        taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Library        taf.sbts.oam.sc.rest.rest    WITH NAME   rest
Library        taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME   commissioning
Library        taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations         WITH NAME   asir
Library        testsuite/Krakow/resources/NJ_Resources/Resources/python/DevNJ_analyze_ATL_log.py
Library        testsuite/Krakow/resources/NJ_Resources/Resources/python/DevNJ_sbts_keywords.py
Library        testsuite/Krakow/resources/NJ_Resources/Resources/python/DevNJ_sbts_selenium.py
Library        testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME    AsirWebEM
Library        ./utils/helpers.py
Library        ./utils/TLSHandshakeTests.py    WITH NAME   tls_tests
Resource       testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_emssim.robot
Resource       testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_sbts_setup.robot
Resource       testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_wireshark_resource.robot
Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables      ./deltas.py

*** Variables ***
${virtual_enable}                       ${True}
${bts_id}                               ${tl.gnbs[0].global_bts_id}
${asi_id}                               ${tl.gnbs[0].global_bts_id}
${OAM_IP}                               ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ROOT_USERNAME}                        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}                        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${mplane_ip}                            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${vm_ip}                                ${tl.test_pc.default_ssh_connection_details.addr}
${network_interface}                    br0.503
${host_ip}                              10.83.177.82
${NEIPAddress}                          192.168.255.129:3601
${NEMPLANEIPAddress}                    ${mplane_ip}:3601
${ClientIPAddress}                      192.168.255.126

#override DEVNJ_wireshark_resource variables
${ASIK_IP_LMP}                          ${OAM_IP}
${ASIK_username}                        ${ROOT_USERNAME}
${ASIK_password}                        ${ROOT_PASSWORD}

&{expected_status_cells}                administrativeState=Unlocked  operationalState=Enabled
&{expected_status_unlock_hubmod}        localState=Unblocked  operationalState=Enabled
&{expected_status_block_antmod}         localState=blocked  operationalState=disabled
&{expected_status_unblock_antmod}       localState=unblocked  operationalState=enabled

${cert_path}                            ${CURDIR}/certificates
${emssim_ssl_path}                      /opt/emssim/proxy/ssl/
${emssim_apache_key}                    /etc/apache2/ssl.key/
${emssim_apache_crt}                    /etc/apache2/ssl.crt/

@{CUSTOM_ALLOWED_ALARMS}                Automatic BTS Operator Certificate retrieval unsuccessful    Operator Certificate About to Expire or Expired

*** Keywords ***
Set Allowed Alarms
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         LMP access via port 443
    ...                                         LMP connectivity detected
    ...                                         CBRS Vendor Certificate is about to expire or expired
    ...                                         CRL Update Failure
    ...                                         CRL Update failure or certificate revoked
    ...                                         Automatic BTS Operator Certificate retrieval unsuccessful
    ...                                         Operator Certificate About to Expire or Expired

Set Allowed Alarms For ASiR
    Set Test Variable    @{ASIR_ALLOWED_ALARMS}    ${61648}

CB009512 Postconditions
    Run Keyword And Ignore Error  AsirWebEM.Logout  online_mode=${True}
    AsirWebEM.Clean Browser
    Perform Full Commissioning on gnb ASIR hub
    Sleep    60    Waiting for ASIR
    Wait for onAir on all DUs
    Common Postconditions

CB009512 Suite Setup
   Common Suite Setup With OnAir Test Line Preparation
   ...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
   ...               increase_time_for_checking_cells=600
   ...               increase_timeout_for_update_sw=1800
   ...               prefix_tag=CB009512
   ...               list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS}
    Setup environment for EMSSIM

CB009512 Test Setup
    Set Allowed Alarms
    Set Allowed Alarms For ASiR
    Common preconditions

Custom Suite Setup
    OperatingSystem.Run  sudo iptables -I INPUT --proto tcp --match multiport --dport 80,443,8080,8443,6080,6000 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 6443 -j ACCEPT
    Common Suite Setup

Setup environment for EMSSIM
    [Documentation]  Keyword including emssim configurations on VM.
    [Arguments]               ${enable_tls}=1
    ${host_ip}    helpers.get_vm_ip
    Set Global Variable    ${host_ip}
    ${update}=                RUN                       /opt/emssim/util/upgrade_emssim.pl -t
    Log                       Emssim updated
    ...                       console=${TRUE}
    RUN    sudo killall -u asir${bts_id}
    RUN    sudo userdel -r asir${bts_id}
    RUN    sudo pkill -f "emssim"
    Run keyword if  ${enable_tls} == 1
    ...    Run keywords
    ...    Log                       Setup environment for EMSSIM started
    ...                              console=${TRUE}
    ...    AND  Certificates Copy
    ...    AND  Strings Replacing
    ...    AND  Apache Restart
    ...    AND  Log                        Configuring TLS on BTS...
    ...                                    console=${TRUE}
    ...    AND                             commissioning.perform_bts_delta_commissioning    delta=${oamtls_on}
    ...    AND  Log                        Configuring certificates on BTS...
    ...                                    console=${TRUE}
    ...    AND                             commissioning.perform_bts_delta_commissioning    delta=${cmp}
    ...    ELSE
    ...    commissioning.perform_bts_delta_commissioning    delta=${oamtls_off}
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}

Strings Replacing
    [Documentation]  Keyword is responsible for replacing necessary string in files on VM.
    Log    Replacing strings in files    console=True
    Run   sed -i 's/CipherString = DEFAULT@SECLEVEL=[0-9]/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
    Run   sed -i '34i\ SSLCertificateChainFile /etc/apache2/ssl.crt/cacert.pem' /home/ute/default-ssl.conf

Apache Restart
    [Documentation]  Keyword is responsible for restarting Apache.
    Log    Restart apache2    console=True
    RUN   sudo systemctl restart apache2

Certificates Copy
    [Documentation]  Keyword is responsible for copying unpleasant certificates on VM.

    Log    Copying certificates    console=True
    Run    sudo cp ${cert_path}/*.pem ${emssim_ssl_path}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_key}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_crt}

Convert pcap to XML
    [Arguments]  ${filename}  ${filters}  ${xml_name}
    Run    tshark -r ${filename} -Y "${filters}" -T pdml > ${xml_name}

Check OpenSSL version
    ${connection}=                             Connect To BTS
    ${output}=                                 ssh.execute  command=cd /etc & openssl version
                                               ...          connection=${connection}
    Should Contain                             ${output}   OpenSSL 3

Connect to BTS
    [Documentation]    SSH to BTS, by default with BTS LMP IP address.
    [Arguments]        ${ip_address}=${OAM_IP}  ${username}=${ROOT_USERNAME}
    ...                ${password}=${ROOT_PASSWORD}  ${proxy}=${None}  ${port}=22
    ...                ${alias}=toor4nsn
    ${connection}=     ssh.Connect to  ${ip_address}
    ...                                ${username}
    ...                                ${password}
    ...                                port=${port}
    ...                                proxy=${proxy}
    ...                                alias=${alias}
    Log                Successfully connected with BTS
    ...                console=${TRUE}
    [Return]           ${connection}

Collect ATL logs and stop Tcpdump
    Wait Until Keyword Succeeds    5x    5s    Run EMSSIM Command    ne3s_upload_atl -time 1
    ...                                                              bts_id=${bts_id}
    ...                                                              get_full_data=True
    ...                                                              alias=asirAC
    Sleep    60    Waiting for package
    Wait Until Keyword Succeeds  5x  5s  Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep    60    Waiting for package
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====

Activate EMSSIM
    ${path}  Start Tcpdump On gNB  options=-i ${network_interface}
    Sleep    15    Waiting for package
    Run EMSSIM Command  ne3s_activate  bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Sleep    60    Waiting for package
    [Return]    ${path}

Activate EMSSIM and Collect Tcpdump
    ${path}  Start Tcpdump On gNB  options=-i ${network_interface}
    Sleep    15    Waiting for package
    Run EMSSIM Command  ne3s_activate -tls 1  bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Sleep    60    Waiting for package
    Stop Tcpdump On gNB
    [Return]    ${path}

Script to get alarms
    Log To Console  \n ==== Start to execuate script to get alarms ====

    FOR  ${index}  IN RANGE  1  1200
        rest.connect_to
        ...  host=${NEIPAddress.split(":")[0]}  port=${NEIPAddress.split(":")[1]}  username=Nemuadmin  password=nemuuser
        rest.get_active_alarms
        rest.disconnect
    END

    Log To Console  \n ==== Execuate script to get alarms end====

Compare ATL logs
    [Arguments]    ${alt_log}    ${additiontext}    ${operation}=Reconfiguration
    ${compare_dict}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                   AdditionalText=${additiontext}
    ...                   ClientIPAddress=${ClientIPAddress}
    ...                   LogStatus=success
    ...                   Operation=${operation}
    ${compare_dict_midify}  Transfer to SCF Comparer  ${compare_dict}

    ${list_comparer}  Create List  ${compare_dict_midify}
    ${res}    Atl Log Compare    dict_zip_content=${alt_log}    list_comparer=${list_comparer}
    Should Be Equal As Strings    first=${res}[res]    second=True

Pick from Pcap Gzip OAtS
    [Arguments]    ${path_to_wireshark_file}
    ${alt_log}    Pick Attachments From Pcap    pcap_path=${path_to_wireshark_file}
    ...                                         recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"]
    [Return]    ${alt_log}

Pick from Pcap tar OAtS
    [Arguments]    ${path_to_wireshark_file}
    ${alt_log}    Pick Attachments From Pcap    pcap_path=${path_to_wireshark_file}    recog_xml_regexes=["tar", "oats"]
    [Return]    ${alt_log}

ASiR Selenium Modify Parameter
    [Arguments]    ${variable}=ASI_9512_Test_Tesla    ${para_abbr}=asiName
    AsirWebEM.Set Virtual Enable    virtual_enable=${virtual_enable}
    AsirWebEM.Login
    AsirWebEM.Enter Config Man
    ${new_variable}    Set Variable    ${variable}
    ${select_para_dict}    Create Dictionary    para_mo=ASI-${asi_id}    para_abbr=${para_abbr}    value=${new_variable}
    ${select_para_list_to_modify}    Create List    ${select_para_dict}
    Wait Until Keyword Succeeds    2x    60s    AsirWebEM.Modify Parameter    ${select_para_list_to_modify}
    Sleep    2    Waiting for ASIR
    &{dict_res_prevalidate}    AsirWebEM.Prevalidate
    Sleep    2    Waiting for ASIR
    Should Be Equal As Strings    first=${dict_res_prevalidate}[ret]    second=True
    AsirWebEM.Activate
    Run Keyword And Ignore Error    AsirWebEM.Logout
    AsirWebEM.Clean Browser

ASiR WebEm State Operations
    [Arguments]    ${additiontext}    ${operation}=UnitReset
    ${compare_dict}    Create Dictionary    NEIPAddress=${NEMPLANEIPAddress}
    ...                                     AdditionalText=${additiontext}
    ...                                     LogStatus=success
    ...                                     Operation=${operation}
    ${compare_dict_new}    Transfer to SCF Comparer    ${compare_dict}
    [Return]    ${compare_dict_new}