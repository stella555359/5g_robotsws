*** Settings ***
Documentation    Keywords for CB008254
...              authors: Lukasz Skoczylas, Aleksandra Faliszek
...              contact: lukasz.skoczylas@nokia.com, aleksandra.faliszek@nokia.com

Library     testsuite/Krakow/OAM/regression/resources/openssl_utilities.py
Library     testsuite/Krakow/OAM/regression/resources/ipsec_utilities.py
Resource    testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_emssim.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${host_ip}=              ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}=        ${tl.test_pc.default_ssh_connection_details.username}
${host_password}=        ${tl.test_pc.default_ssh_connection_details.password}
${OAM_IP}=               ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${IPSEC_OAM_IP}=         ${tl.emssim_config["ipsec_oam_ip"]}
${host_for_emssim}=      ${tl.emssim_config["host_for_emssim"]}


*** Keywords ***
Common Test Setup And Backup Sbts
    Common Preconditions
    Log To Console  \n===Backup init configuration===
    Save Current gNB Configuration
    Log To Console  \n===IPSec Start on UTE===
    Configure IPSec on UTE  ca_cert_path=${cert_RSA_path}/RootCA.pem
    ...                     cert_path=${cert_RSA_path}/debianSeGW.pem
    ...                     key_path=${cert_RSA_path}/server.key
    ...                     ipsec_conf_path=${ipsec_path}/ipsec.conf
    ...                     ipsec_secrets_path=${ipsec_path}/ipsec.secrets
    Start IPSec on UTE

Common Test Teardown And Recover Sbts
    Log To Console  \n===Recover to init configuration===
    gnb_asir.Disconnect
    Perform Full Commissioning On Classical Gnb   scf_path=${scf_local_path}  force_reconnect=${True}
    Update BTS Mplane Ip and Reset Admin connections   ${OAM_IP}
    Wait for onAir on all DUs
    gnbbbu.Restore Vendor Certificate
    Log To Console  \n===Recovery successful===
    Common Postconditions

Update BTS Mplane Ip and Reset Admin connections
    [Arguments]    ${ip_addr}
    gnbbbu.Disconnect
    Update BTS Mplane Ip    ${ip_addr}

Create Certificate pkcs12
    [Arguments]    ${cert_path}   ${cert_password}
    openssl_pkcs12_export  certs=${cert_path}/btscerts.pem  private_key=${cert_path}/btsprivatekey.pem
    ...                    output_name=${cert_path}/btscert.p12  password=${cert_password}

ASiR NE integration to EMSsim
    [Arguments]    ${cert_path}
    Prepare ASiR EMSSim Setup   host=${host_for_emssim}   mplane_ip=${IPSEC_OAM_IP}
    sleep    10s
    Run Emssim Command      slog
    Run Emssim Command      log on 1
    ${command}=     Catenate   proxy_ssl_cert -cert ${cert_path}/servercert.pem -key
    ...   ${cert_path}/serverprivkey.pem -cacert ${cert_path}/cacert.pem
    Run Emssim Command       ${command}
    Run Emssim Command       ne3s_activate -tls 1

Verify ASiR NE integration to EMSsim
    ${report_file}=    Run    ls /var/log/emssim/fbox*.log -altr | tail -n1 | awk '{print $9}'
    ${res}=            Run    cat ${report_file} |grep -E "Ne3sUpload flow success" | wc -l
    Should Be True    ${res} >= ${1}

ASiR NE de-integration to EMSsim
    Run Emssim Command       ne3s_deactivate

Verify ASiR NE de-integration to EMSsim
    ${report_file}=    Run    ls /var/log/emssim/fbox*.log -altr | tail -n1 | awk '{print $9}'
    ${res}=            Run    cat ${report_file} |grep -E "Ne3sUnregister flow success" | wc -l
    Should Be True     ${res} >= ${1}
    Run   mv /var/log/emssim/${report_file} ${LOG_PATH}
    Run   rm -rf /var/log/emssim/*
    Teardown Emss

EMSsim get alarm from ASiR
    Run Emssim Command       alarm_status
