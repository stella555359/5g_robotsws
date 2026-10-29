*** Settings ***
Documentation    Keywords for CB010265
...              authors: Lukasz Skoczylas, Aleksandra Faliszek
...              contact: lukasz.skoczylas@nokia.com, aleksandra.faliszek@nokia.com

Library     testsuite/Krakow/OAM/regression/resources/openssl_utilities.py
Library     taf.rfrl.utilities.logger.custom_logger                            WITH NAME    logger
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME    asir
Resource    testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_emssim.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${host_ip}=              ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}=        ${tl.test_pc.default_ssh_connection_details.username}
${host_password}=        ${tl.test_pc.default_ssh_connection_details.password}
${OAM_IP}=               ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${host_for_emssim}=      ${tl.emssim_config["host_for_emssim"]}
${cert_RSA_password}=    fZYV-J5Vq-XbJR-faz6
${cert_RSA_path}=        ${CURDIR}/certs/RSA
${cert_SHA1_password}=   rKp9-yn95-VdxR-TnLi
${cert_SHA1_path}=       ${CURDIR}/certs/SHA1


*** Keywords ***
Common Test Setup And Backup Sbts
    Common Preconditions
    logger.Log info To Console  Backup init configuration
    Save Current gNB Configuration

Common Test Teardown And Recover Sbts
    logger.Log info To Console  Recover to init configuration
    gnb_asir.Disconnect
    Perform Full Commissioning On Classical Gnb   scf_path=${scf_local_path}  force_reconnect=${True}
    Wait for onAir on all DUs
    gnbbbu.Restore Vendor Certificate
    logger.Log info To Console  Recovery successful
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
    Prepare ASiR EMSSim Setup   host=${host_for_emssim}   mplane_ip=${OAM_IP}
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
    [Return]           ${res}

ASiR NE de-integration to EMSsim
    Run Emssim Command       ne3s_deactivate

Verify ASiR NE de-integration to EMSsim
    ${report_file}=    Run    ls /var/log/emssim/fbox*.log -altr | tail -n1 | awk '{print $9}'
    ${res}=            Run    cat ${report_file} |grep -E "Ne3sUnregister flow success" | wc -l
    Should Be True     ${res} >= ${1}
    Run   mv /var/log/emssim/${report_file} ${LOG_PATH}
    Run   rm -rf /var/log/emssim/*
    Teardown Emss

Verify OamTlsStatus
    asir.Verify Status Of Asir Connection To Nms    notConnected

EMSsim get alarm from ASiR
    Run Emssim Command       alarm_status

Install RSA cert
    logger.Log info To Console  Install RSA cert
    gnb_asir.Disconnect
    Create Certificate pkcs12  ${cert_RSA_path}  ${cert_RSA_password}
    gnbbbu.Install Certificate  cert_file=${cert_RSA_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_RSA_password}  key_pool_type=RSA

Integrate ASiR to emssim with TLSv1.2 RSA
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2
    ASiR NE integration to EMSsim  ${cert_RSA_path}
    Sleep   60s
    ${res} =     Verify ASiR NE integration to EMSsim
    Should Be True    ${res} >= ${1}
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2 successfully

De-integrate ASiR to emssim
    logger.Log info To Console  De-integrate ASiR to emssim
    ASiR NE de-integration to EMSsim
    Sleep   60s
    Verify ASiR NE de-integration to EMSsim
    logger.Log info To Console  Check oamTlsStatus
    Verify OamTlsStatus
    logger.Log info To Console  De-integrate successfully

Install RSA SHA1 cert
    logger.Log info To Console  Install RSA SHA1 cert
    gnb_asir.Disconnect
    Create Certificate pkcs12  ${cert_SHA1_path}  ${cert_SHA1_password}
    gnbbbu.Install Certificate  cert_file=${cert_SHA1_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_SHA1_password}  key_pool_type=RSA

Convert pcap to XML
    [Arguments]  ${filename}  ${filters}  ${xml_name}
    Run    tshark -r ${filename} -Y "${filters}" -T pdml > ${xml_name}

ASiR block and unblock antenna
    asir.Block Antenna        ant_id=6
    Sleep   30s
    asir.Unblock Antenna      ant_id=6
    Sleep   30s

Collect ATL logs
    Run EMSSIM Command    ne3s_upload_atl -time 1
    ...                   get_full_data=True
    Sleep   30s
