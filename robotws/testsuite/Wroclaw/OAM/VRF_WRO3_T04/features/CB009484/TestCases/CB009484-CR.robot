*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/25R1/CB009484/
...    Description:
...        Split G:    Verify configuration of HTTP Security Response Headers on Cloud
...        Split E:    Mutual authentication support for geo-resiliency

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/variables/variables.robot
Resource    ../Resources/CB009484-CR_Keywords.robot

*** Variables ***
${cross_policy}=        Referrer-Policy: strict-origin-when-cross-origin
${perm_policy}=         X-Permitted-Cross-Domain-Policies: none
${embedder_policy}=     Cross-Origin-Embedder-Policy: require-corp
${opener_policy}=       Cross-Origin-Opener-Policy: same-origin
${resource_policy}=     Cross-Origin-Resource-Policy: same-site

${geo_login}=           georesiliency
${geo_password}=        Nokia@123


${tls1.2_message}=      TLSv1.2 Record Layer: Change Cipher Spec Protocol
${tls1.3_message}=      TLSv1.3 Record Layer: Change Cipher Spec Protocol

*** Keywords ***
Verify_All_Cross_Origin_Policies_Cloud_vCU
    Log                Step 2: Verify Referrer-Policy    console=True
    ${output}=         Run    curl -H "Referer: https://nokia.com" -I -k https://${LMP_VCU_IP}
    Should Contain     ${output}    ${cross_policy}
    Log                Step 4: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${output}=         Run    curl -k -H "X-Correlation-ID: correlation123456789" https://${LMP_VCU_IP} -I
    Should Contain     ${output}    ${perm_policy}
    Log                Step 5: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${command}=        Catenate     curl -k -H "User-Agent:
    ...                             Mozilla/5.0 (Windows NT 10.0; Win64; x64)
    ...                             AppleWebKit/537.36 (KHTML, like Gecko)
    ...                             Chrome/91.0.4472.124 Safari/537.36
    ...                             Edge/91.0.864.59" https://${LMP_VCU_IP} -I
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${perm_policy}
    Log                Step 7: Verify Cross-Origin-Embedder-Policy    console=True
    ${command}=        Catenate     curl -k -H "Cross-Origin-Embedder-Policy: require-corp;
    ...                             report-to=\"default\"" -I https://${LMP_VCU_IP}
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${embedder_policy}
    Log                Step 8: Verify Cross-Origin-Opener-Policy    console=True
    ${command}=        Catenate     curl -k -I -X GET https://${LMP_VCU_IP} -H 'Origin: https://attacker.com'
    ...                             -H 'Cross-Origin-Opener-Policy: same-origin'
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${opener_policy}
    Log                Step 9: Verify Cross-Origin-Resource-Policy    console=True
    ${output}=         Run          curl -k -I -X GET https://${LMP_VCU_IP} /resource.js -H 'Origin: https://attacker.com'
    Should Contain     ${output}    ${resource_policy}

Verify_All_Cross_Origin_Policies_Cloud_vDU
    Log                Step 2: Verify Referrer-Policy    console=True
    ${output}=         Run    curl -H "Referer: https://nokia.com" -I -k https://${LMP_VDU_IP}
    Should Contain     ${output}    ${cross_policy}
    Log                Step 4: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${output}=         Run    curl -k -H "X-Correlation-ID: correlation123456789" https://${LMP_VDU_IP} -I
    Should Contain     ${output}    ${perm_policy}
    Log                Step 5: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${command}=        Catenate     curl -k -H "User-Agent:
    ...                             Mozilla/5.0 (Windows NT 10.0; Win64; x64)
    ...                             AppleWebKit/537.36 (KHTML, like Gecko)
    ...                             Chrome/91.0.4472.124 Safari/537.36
    ...                             Edge/91.0.864.59" https://${LMP_VDU_IP} -I
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${perm_policy}
    Log                Step 7: Verify Cross-Origin-Embedder-Policy    console=True
    ${command}=        Catenate     curl -k -H "Cross-Origin-Embedder-Policy: require-corp;
    ...                             report-to=\"default\"" -I https://${LMP_VDU_IP}
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${embedder_policy}
    Log                Step 8: Verify Cross-Origin-Opener-Policy    console=True
    ${command}=        Catenate     curl -k -I -X GET https://${LMP_VDU_IP} -H 'Origin: https://attacker.com'
    ...                             -H 'Cross-Origin-Opener-Policy: same-origin'
    ${output}=         Run          ${command}
    Should Contain     ${output}    ${opener_policy}
    Log                Step 9: Verify Cross-Origin-Resource-Policy    console=True
    ${output}=         Run          curl -k -I -X GET https://${LMP_VDU_IP} /resource.js -H 'Origin: https://attacker.com'
    Should Contain     ${output}    ${resource_policy}

Mutual_authentication_support_for_geo-resiliency_connection
    Log                             Step 0: Preconditions    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Delete All Certificates         hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Configure CMP                   ca_subject_name=CN=CB005999_test    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU    pre-connection=${conn_sec}
    Delete All Certificates         hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Configure CMP on vCU-2          ca_subject_name=CN=CB005999_test    pre-connection=${conn_sec}
    Update CMP Server Settings      hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Initialize Certificate    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Log                             Step 1: Check IP Traffic with only TLS 1.2 on    console=True
    ${dn_prim}=    Create List      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ${pn}=         Create List      tls12Enabled    actEnableTLSv13
    ${pv_12}=      Create List      true    false
    Change Multiple Parameters on BTS    ${dn_prim}    ${pn}    ${pv_12}    hw_type=vCU
    Sleep    90s                    reason=Give some time to the other vCU connected via georesiliency
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${dn_sec}=       Create List    MRBTS-${MRBTS_CU_2}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             MRBTS-${MRBTS_CU_2}/MNL-1/MNLENT-1/MPLANENW-1
    Wait Until Keyword Succeeds     5x    10s    Change Multiple Parameters on BTS
    ...                             ${dn_sec}    ${pn}    ${pv_12}    hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN           connection=${conn_sec}    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
    Sleep    20s                    reason=Wait for automation georesiliency handshake
    ${pcap_path_12}=                Stop TCPdump and Download Pcap    pod_name=po-oamext-0    hw_type=vCU
    Convert pcap to XML    filename=${pcap_path_12}    xml_name=${CURDIR}/tls_handshake_1.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP} && ip.dst==${LMP_VCU_IP_2}
    Convert pcap to XML    filename=${pcap_path_12}    xml_name=${CURDIR}/tls_handshake_2.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP_2} && ip.dst==${LMP_VCU_IP}
    ${inside_pcap_1}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_1.xml
    ${inside_pcap_2}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_2.xml
    Should Contain                  ${inside_pcap_1}    ${tls1.2_message}
    Should Contain                  ${inside_pcap_2}    ${tls1.2_message}
    Should not Contain              ${inside_pcap_1}    ${tls1.3_message}
    Should not Contain              ${inside_pcap_2}    ${tls1.3_message}
    Log                             Step 2: Check IP Traffic with only TLS 1.3 on    console=True
    ${pv_13}=    Create List        false    true
    Change Multiple Parameters on BTS    ${dn_prim}    ${pn}    ${pv_13}    hw_type=vCU
    Sleep    90s                    reason=Give some time to the other vCU connected via georesiliency
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5x    10s    Change Multiple Parameters on BTS
    ...                             ${dn_sec}    ${pn}    ${pv_13}    hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN           connection=${conn_sec}    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
    Sleep    20s                    reason=Wait for automation georesiliency handshake
    ${pcap_path_13}=                Stop TCPdump and Download Pcap    pod_name=po-oamext-0    hw_type=vCU
    Convert pcap to XML    filename=${pcap_path_13}    xml_name=${CURDIR}/tls_handshake_1.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP} && ip.dst==${LMP_VCU_IP_2}
    Convert pcap to XML    filename=${pcap_path_13}    xml_name=${CURDIR}/tls_handshake_2.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP_2} && ip.dst==${LMP_VCU_IP}
    ${inside_pcap_1}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_1.xml
    ${inside_pcap_2}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_2.xml
    Should Contain                  ${inside_pcap_1}    ${tls1.3_message}
    Should Contain                  ${inside_pcap_2}    ${tls1.3_message}
    Should not Contain              ${inside_pcap_1}    ${tls1.2_message}
    Should not Contain              ${inside_pcap_2}    ${tls1.2_message}
    Log                             Step 3: Check IP Traffic with both TLS 1.2 and TLS 1.3 on    console=True
    ${pv_both}=    Create List      true    true
    Change Multiple Parameters on BTS    ${dn_prim}    ${pn}    ${pv_both}    hw_type=vCU
    Sleep    90s                    reason=Give some time to the other vCU connected via georesiliency
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5x    10s    Change Multiple Parameters on BTS
    ...                             ${dn_sec}    ${pn}    ${pv_both}    hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN           connection=${conn_sec}    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
    Sleep    20s                    reason=Wait for automation georesiliency handshake
    ${pcap_path_both}=              Stop TCPdump and Download Pcap    pod_name=po-oamext-0    hw_type=vCU
    Convert pcap to XML    filename=${pcap_path_both}    xml_name=${CURDIR}/tls_handshake_1.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP} && ip.dst==${LMP_VCU_IP_2}
    Convert pcap to XML    filename=${pcap_path_both}    xml_name=${CURDIR}/tls_handshake_2.xml
    ...                    filters=tls.record.content_type==22 && ip.src==${LMP_VCU_IP_2} && ip.dst==${LMP_VCU_IP}
    ${inside_pcap_1}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_1.xml
    ${inside_pcap_2}=               OperatingSystem.Get File    ${CURDIR}/tls_handshake_2.xml
    Should Contain                  ${inside_pcap_1}    ${tls1.3_message}
    Should Contain                  ${inside_pcap_2}    ${tls1.3_message}
    Should not Contain              ${inside_pcap_1}    ${tls1.2_message}
    Should not Contain              ${inside_pcap_2}    ${tls1.2_message}
    [Teardown]    Run Keywords      Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                             connection=${conn_sec}    hw_type=vCU
    ...    AND                      Restore TLS settings
    ...    AND                      Run    rm ${CURDIR}/tls_handshake_1.xml
    ...    AND                      Run    rm ${CURDIR}/tls_handshake_2.xml
    ...    AND                      Run    rm ${pcap_path_12}
    ...    AND                      Run    rm ${pcap_path_13}
    ...    AND                      Run    rm ${pcap_path_both}

TLS_authentication_failure_for_georesiliency_connection
    Log                             Step 0: Preconditions    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Delete All Certificates         hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Configure CMP                   ca_subject_name=CN=CB005999_test    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5x    10s    Restore Default Certificates on BTS
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Delete All Certificates
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Configure CMP on vCU-2          ca_subject_name=CN=CB005999_test    pre-connection=${conn_sec}
    Update CMP Server Settings      hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Initialize Certificate    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Log                             Step 1: Delete certificates from secondary vCU    console=True
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5x    10s    Restore Default Certificates on BTS
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Delete All Certificates
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Log                             Step 2: Wait for TLS connection failure alarm on both vCUs    console=True
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active    alarm=7220    hw_type=vCU
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active on secondary vCU
    [Teardown]    Run Keywords      Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                             connection=${conn_sec}    hw_type=vCU
    ...    AND                      Reinstall certificate on secondary vCU

OAM-ext_reboot_Unforseen_Robustness
    Log                             Step 0: Preconditions    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Delete All Certificates         hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Configure CMP                   ca_subject_name=CN=CB005999_test    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5x    10s    Restore Default Certificates on BTS
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Delete All Certificates
    ...                             hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Configure CMP on vCU-2          ca_subject_name=CN=CB005999_test    pre-connection=${conn_sec}
    Update CMP Server Settings      hw_type=vCU    pre-connection=${conn_sec}
    Wait Until Keyword Succeeds     5x    10s    Initialize Certificate    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    ${alarms_before}=               Get Active Alarms From BTS    hw_type=vCU
    ${alarms_list}=                 Get from Dictionary    ${alarms_before}    alarms
    @{fault_ids_before_vcu1}=       Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_before_vcu1}    ${fault_id}
    END
    Set Test Variable               ${fault_ids_before_vcu1}
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${alarms_before}=               Get Active Alarms From BTS    hw_type=vCU    pre-connection=${conn_sec}
    ${alarms_list}=                 Get from Dictionary    ${alarms_before}    alarms
    @{fault_ids_before_vcu2}=       Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_before_vcu2}    ${fault_id}
    END
    Set Test Variable               ${fault_ids_before_vcu2}
    Disconnect from ADMIN           connection=${conn_sec}    hw_type=vCU
    ${alarms_before}=               Get Active Alarms From BTS    hw_type=vDU
    ${alarms_list}=                 Get from Dictionary    ${alarms_before}    alarms
    @{fault_ids_before_vdu}=        Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_before_vdu}    ${fault_id}
    END
    Set Test Variable               ${fault_ids_before_vdu}
    Log                             Step 1: Delete POD of primary vCU    console=True
    SSHLibrary.Open Connection      host=${SSH_VCU_IP}
    SSHLibrary.Login                username=${SSH_K8S_USERNAME}    password=${SSH_K8S_PASSWORD}
    Sleep    5s                     reason=Wait until terminal execute the command
    SSHLibrary.Write                oc delete pod po-oamext-0 -n cran${MRBTS}
    Sleep    30s                    reason=Wait until POD is deleted
    Log                             Step 2: Wait until POD will be recreated    console=True
    Wait Until Keyword Succeeds     5min     10s    Check if deleted POD was recreated
    Wait Until Keyword Succeeds     10min    10s    Check if Unit Status is OnAir    hw_type=vCU
    Wait Until Keyword Succeeds     10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Wait Until Keyword Succeeds     5min     10s    Check if there is no new alarm after POD recreation on vCU-1
    SSHLibrary.Close Connection
    Log                             Step 3: Delete POD of secondary vCU    console=True
    SSHLibrary.Open Connection      host=${SSH_VCU_IP_2}
    SSHLibrary.Login                username=${SSH_K8S_USERNAME}    password=${SSH_K8S_PASSWORD}
    Sleep    5s                     reason=Wait until terminal execute the command
    SSHLibrary.Write                oc delete pod po-oamext-0 -n cran${MRBTS}
    Sleep    30s                    reason=Wait until POD is deleted
    Log                             Step 4: Wait until POD will be recreated    console=True
    Wait Until Keyword Succeeds     5min     10s    Check if deleted secondary POD was recreated
    ${conn_sec}=                    Wait Until Keyword Succeeds     10x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds     5min     10s    Check if secondary Unit Status is OnAir    conn=${conn_sec}
    Wait Until Keyword Succeeds     10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Wait Until Keyword Succeeds     5min     10s    Check if there is no new alarm after POD recreation on vCU-2
    ...                             ${conn_sec}
    [Teardown]                      Run Keywords    SSHLibrary.Close Connection
    ...    AND                      Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
