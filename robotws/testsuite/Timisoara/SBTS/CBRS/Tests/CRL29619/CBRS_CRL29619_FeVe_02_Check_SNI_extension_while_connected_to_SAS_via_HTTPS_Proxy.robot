*** Settings ***
Documentation
...    = Author = Lukasz Lechowicz
...    lukasz.lechowicz@nokia.com
...    = Maintainer =
...    lukasz.lechowicz@nokia.com
...    = Reviewer =
...    bartosz.rutkowski@nokia.com
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_CRL29619_FeVe_02_Check_SNI_extension_while_connected_to_SAS_via_HTTPS_Proxy
    [Documentation]    This Test Case verifies presence of TLS extension - Server Name Indication - when eNB connects to SAS Server via HTTPS Proxy.

    ${ims_alias}                      Set Variable    RAT_1ST
    ${enb_user}                       Set Variable    ${credentials.enb_username}
    ${enb_password}                   Set Variable    ${credentials.enb_password}
    ${enb_id}                         Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_id}                         Convert To String       ${enb_id}
    ${SAS_IP}                         Set Variable    ${testlines.${testline_id}.vm_ip}
    ${SAS_FQDN}                       Set Variable    testing-sc-02.cbrsfqdn.com
    ${SAS_port}                       Set Variable    4433
    ${FQDN_subdirectory}              Set Variable    v1.2
    ${HTTPS_proxy_ip}                 Set Variable    ${testlines.${testline_id}.vm_ip}
    ${HTTPS_proxy_port}               Set Variable    5555
    ${connectToSasMode}               Set Variable    connect through https proxy
    ${primarySasServer}               Catenate        SEPARATOR=:    ${SAS_FQDN}    ${SAS_port}
    ${primarySasServer_with_subdir}   Catenate        SEPARATOR=/    ${primarySasServer}    ${FQDN_subdirectory}
    ${primaryHttpsProxyServer}        Catenate        SEPARATOR=:    ${HTTPS_proxy_ip}    ${HTTPS_proxy_port}

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}

    Add SAS FQDN To Known Hosts on HTTPS Proxy Server   SAS_server_ip=${SAS_IP}    SAS_FQDN=${SAS_FQDN}
    Add SAS FQDN To Known Hosts On eNB    SAS_FQDN=${SAS_FQDN}    SAS_IP=${SAS_IP}    enb_user=${enb_user}    enb_password=${enb_password}

    ${sas_pid}    ${sas_logs_dir} =              Start SAS Process    port=${SAS_port}    version=1.2
    ${sas_proxy_pid}    ${sas_proxy_log_dir}   Start SAS HTTPS Proxy      alias=default    port=${HTTPS_proxy_port}

    Wait Until BTS Is Not Busy
    ${cbrspr_fqdn_plan}            Replace Variables In File    file_path=${CURDIR}/Data/FeVe02/FeVe_02_cbrspr_update_tmp.json
    ...                              file_destination=${OUTPUT DIR}/FeVe_02_cbrspr_update.json
    ...                              enb_id=${enb_id}
    ...                              connectToSasMode=${connectToSasMode}
    ...                              primarySasServer=${primarySasServer_with_subdir}
    ...                              primaryHttpsProxyServer=${primaryHttpsProxyServer}
    Perform Delta Recommissioning    ${cbrspr_fqdn_plan}    connection=${ims_alias}

    Start Remote TCPDUMP On eNB    enb_user=${enb_user}    enb_password=${enb_password}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered     enb_id=${enb_id}

    ${sas_proxy_log_status}   Run Keyword And Return Status    OperatingSystem.File Should Exist    ${sas_proxy_log_dir}
    IF  ${sas_proxy_log_status}==${false}  OperatingSystem.Copy File  /home/ute/SASSim/default/HttpsProxy.log  ${sas_proxy_log_dir}

    ${sas_proxy_log}   OperatingSystem.Get File    ${sas_proxy_log_dir}

    Should Contain    ${sas_proxy_log}    ${SAS_FQDN}:${SAS_port}
    Stop Remote TCPDUMP On eNB And Download Traces    enb_user=${enb_user}    enb_password=${enb_password}

    Read Trace File And Verify SNI Presence    SAS_FQDN=${SAS_FQDN}
    Wait For All Cells To Be OnAir

    ${recommisioning_plan}         Replace Variables In File    file_path=${CURDIR}/Data/FeVe02/FeVe_02_cbrspr_update_tmp.json
    ...                              file_destination=${OUTPUT DIR}/FeVe_02_cbrspr_update_teardown.json
    ...                              enb_id=${enb_id}
    ...                              connectToSasMode=direct connect to SAS server
    ...                              primarySasServer=${SAS_IP}:${SAS_port}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Get SAS Proxy Logs To Logs Dir    alias=default    AND
    ...    Remove SAS FQDN From Known Hosts On eNB   enb_user=${enb_user}    enb_password=${enb_password}
           ...    SAS_FQDN=${SAS_FQDN}    SAS_IP=${SAS_IP}    AND
    ...    Remove SAS FQDN From Known Hosts on HTTPS Proxy Server    SAS_FQDN=${SAS_FQDN}    AND
    ...    Wait Until Keyword Succeeds    5x    20s    Perform Delta Recommissioning    ${recommisioning_plan}    connection=RAT_1ST    AND
    ...    SSHLibrary.Close All Connections    AND
    ...    Kill All SAS Proxy Processes    AND
    ...    Kill All SAS Processes

Add SAS FQDN To Known Hosts on HTTPS Proxy Server
    [Arguments]        ${SAS_server_ip}    ${SAS_FQDN}
    [Documentation]    Appends local /etc/hosts file with new entry containing FQDN config.
    [Timeout]          3 min

    Run                  sudo chmod 777 /etc/hosts
    Run                  echo '${SAS_server_ip} ${SAS_FQDN}' >> /etc/hosts
    ${hosts_content}   Run    cat /etc/hosts
    Should Contain       ${hosts_content}    ${SAS_FQDN}

Remove SAS FQDN From Known Hosts on HTTPS Proxy Server
    [Arguments]        ${SAS_FQDN}
    [Documentation]    Removes entry containing FQDN config from /etc/hosts.
    [Timeout]          3 min

    ${FQDN_line}        Run    grep -n '${SAS_FQDN}' /etc/hosts | cut -d : -f 1
    Run                   sudo sed -i '${FQDN_line}d' /etc/hosts
    ${hosts_content}    Run    cat /etc/hosts
    Should Not Contain    ${hosts_content}    ${SAS_FQDN}
    Run                   sudo chmod 644 /etc/hosts


