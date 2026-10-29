*** Settings ***
Documentation
...    author:          Julia Wijas    Anna Sheiko
...    contact:         julia.wijas@nokia.com    anna.sheiko@nokia.com
...    Description:     Test Cases to feature CB009482

Resource            ../Resources/Keywords_B.robot
Resource            ../../../../cloud_common_resources/certificates/certificates.robot
Resource            ../../../../cloud_common_resources/alarms/alarms.robot
Resource            ../../../../cloud_common_resources/resets/resets.robot
Resource            ../../../../cloud_common_resources/logs/logs.robot
Resource            ../../../cloud_common_resources/tls/tls.robot
Resource            ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource            ../../../cloud_common_resources/mantaray/mantaray.robot
Resource            ../../../cloud_common_resources/syslog/syslog.robot

*** Variables ***
${ECDSA_SUBJECT_NAME}=      CN=CB010265_EC_Cloud
${RSA_SUBJECT_NAME}=        CN=srnblrna1
${RSA_HOST}=                10.96.129.254
${CNUM_username}            omc
${CNUM_password}            Medsql!_1893
${SYSLOG_IP}=               10.42.63.247
${CNUM_PORT}=               389
${SYSLOG_LOGIN}             kali
${SYSLOG_PASS}              kali
${error_tls_syslog}         tls: protocol version not supported
${error_cert_syslog}        certificate verification failed
${login_error}              AuthenticationFailed    #Communication error with Centralized Network User Management
${error_LDAP}               certificate verify failed
${error_cert_LDAP}          no cipher match
${error_alarm}              Configuration error
${fault_ID_SYSLOG}=         4752
${fault_ID_LDAP}=           4776
${ALETRNATIVE_ECDSA_CA}     CN=CB005999_test
${PREF_NMS_LAB}=            srnclab1047

@{CRAN}                     vCU  vDU

*** Keywords ***
CB09482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    FOR    ${i}    IN    @{CRAN}

        ${MRBTS_ID}    Set Variable If    '${i}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
        ${CRAN}=    Set Variable If    '${i}'=='vCU'    ${CRAN_VCU}    ${CRAN_VDU}
        ${LMP_IP}=    Set Variable If    '${i}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
        ${SSH_IP}=    Set Variable If    '${i}'=='vCU'    ${SSH_VCU_IP}    ${SSH_VDU_IP}
        ${POD}=    Set Variable If    '${i}'=='vCU'    upue    cprt
        ${pcap_pod}=    Get Specific Pod   hw_type=${i}    specific_pod=oamext

        Log  Setting preconditions                                                                          console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CRLH-1
        ...                             param_name=usageEnabled          param_value=Disabled     hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                             param_name=enableUserAccountCtrlAlarm   param_value=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                             param_name=actRestrictLoginToCnum   param_value=false    hw_type=${i}
        Restore Default Certificates on BTS    hw_type=${i}

        Log  Step 2: Integrate BTS with NMS                                                                 console=true
        ${NMS_LAB}=   Integrate Cloud BTS with NMS Lab with TLS   preferred_lab=${PREF_NMS_LAB}   hw_type=${i}
        ${NMS_VCU}    Set Variable If  '${i}'=='vCU'    ${NMS_LAB}
        ${NMS_VDU}    Set Variable If  '${i}'=='vDU'    ${NMS_LAB}
        ${CNUM}       Set Variable If  '${i}'=='vCU'          ${NMS_VCU}    ${NMS_VDU}
        nms.activate_cnum         ne_id_value=PLMN-PLMN/MRBTS-${MRBTS_ID}
        ...                       alias=${CNUM}
        ...                       ip_type=IPv4
        Import Variables       ${CURDIR}/../../../cloud_common_resources/mantaray/config/netact/${CNUM}.py
        Set Test Variable      ${CNUM_IP}       ${LBWAS_IP}

        Log  Step 4: Setting preconditions after NMS integration                                            console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                             param_name=certTypeForTlsAuth    param_value=ECDSA        hw_type=${i}

        Log  Step 5: Adding remoteSyslogConfig structure
        Syslog Configuration             syslog_DSCP=0
        ...                              syslog_format=RFC5424
        ...                              syslog_server_host=10.42.63.247
        ...                              syslog_port=6517
        ...                              syslog_transmision_duration=10080
        ...                              syslog_protocol=TLS
        ...                              hw_type=${i}

        Log  Step 6: Reconfigureing the BTS to enable CNUM LDAP connectivity control alarm                  console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1
        ...                             param_name=enableCnumLdapCtrlAlarm
        ...                             param_value=true
        ...                             hw_type=${i}

        Log  Step 7: Reconfigureing the BTS to enable TLS                                                   console=true
        TLS Configuration               tls12Enabled=true
        ...                             actEnableTLSv13=true
        ...                             oamTls=forced
        ...                             hw_type=${i}

        Log  Step 8, 9: Install ECDSA certificate for syslog on BTS                                         console=true
        Update CMP Server Settings      key_pool_type=ECDSA    hw_type=${i}
        Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}            server_type=ECDSA      hw_type=${i}
        Initialize Certificate          key_pool_type=ECDSA        hw_type=${i}

        Log  Step 10: Verify successful TLS connection (pcap logs) on ${i} to TLS servers and syslog output    console=true
        Start TCPdump    capture_type=pod       pod_names=${pcap_pod}        hw_type=${i}
        Sleep       30s  reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        Log  Log in to the WebEM using the centralized user account                                         console=true
        ${connection_CNUM}=             Connect to ADMIN                username=${CNUM_username}
        ...                                                             password=${CNUM_password}
        ...                                                             hw_type=${i}
        Sleep    10s    reason=Wait until handshake occurs
        ${pcap_path}=    Stop TCPdump and Download Pcap      pod_name=${pcap_pod}                   hw_type=${i}
        ${pid}=    Collect PCAP from syslog server    test${i}.pcap
        Log  Start syslog transmission to a remote server                                                   console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                             param_name=actRemoteSyslogTransmission
        ...                             param_value=true
        ...                             hw_type=${i}
        ...                             pre-connection=${connection_CNUM}
        Sleep    20s    reason=Wait until handshake occurs
        Run keyword and Continue on Failure    Stop and colledt PCAP from syslog server    ${pid}    test${i}.pcap
        Run keyword and Continue on Failure
        ...   Test TLS Handshake    file_path=${pcap_path}       IP_client=${LMP_IP}     IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}     hw_type=${i}
        Run keyword and Continue on Failure
        ...   Test TLS Handshake    file_path=/home/ute/test${i}.pcap  IP_client=${SSH_IP}   IP_server=${SYSLOG_IP}  hw_type=${i}
        Alarm Should not be Active   alarm=4752    hw_type=${i}
        Alarm Should not be Active   alarm=4776    hw_type=${i}

        Log  Step 11: Initiate the procedure of TLS connection failure on ${i} to trigger faults 4752,4776  console=true
        Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                                param_name=actRemoteSyslogTransmission
        ...                                param_value=false
        ...                                hw_type=${i}
        Log  On BTS set unsupported TLS version by syslog server                                            console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=actEnableTLSv13
        ...                             param_value=false
        ...                             hw_type=${i}
        Start TCPdump    capture_type=pod       pod_names=${pcap_pod}        hw_type=${i}
        Sleep       30s  reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        Log  On BTS set wrong RSA certificate                                                               console=true
        Restore Default Certificates on BTS    hw_type=${i}
        Initialize Certificate          key_pool_type=ECDSA        hw_type=${i}
        Update CMP Server Settings      key_pool_type=RSA                                 hw_type=${i}
        Configure CMP                   ca_subject_name=${ALETRNATIVE_ECDSA_CA}     server_type=RSA    hw_type=${i}
        Wait Until Keyword Succeeds     5x    1min   Initialize Certificate          key_pool_type=RSA         hw_type=${i}
        Log  Log in to the WebEM using the centralized user account and expect error                        console=true
        Run Keyword And Expect Error     *${login_error}*      Connect to ADMIN
        ...                                                    username=${CNUM_username}
        ...                                                    password=${CNUM_password}
        ...                                                    hw_type=${i}
        ${pid}=    Collect PCAP from syslog server    test${i}1.pcap
        Log  Start syslog transmission to a remote server                                                   console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                             param_name=actRemoteSyslogTransmission
        ...                             param_value=true
        ...                             hw_type=${i}
        ${pcap_path}=    Stop TCPdump and Download Pcap      pod_name=${pcap_pod}                   hw_type=${i}
        Run keyword and Continue on Failure    Stop and colledt PCAP from syslog server    ${pid}    test${i}1.pcap

        Log  Step 12: Check Active alarms on ${i} in WebEM       console=true
        Sleep   60s      reason=Waiting until alarms occure
        Alarm Should be Active   alarm=4752    hw_type=${i}
        Alarm Should be Active   alarm=4776    hw_type=${i}

        Log  Step 13: Verify details of faults 4752 and 4776       console=true
        Checke Details of Alarm         fault_id=4752              error=${error_tls_syslog}        hw_type=${i}
        Checke Details of Alarm         fault_id=4776              error=${error_LDAP}              hw_type=${i}

        Log  Step 14: Verify collected pcap logs       console=true
        Run keyword and Continue on Failure    Run Keyword and Expect Error     *          Test TLS Handshake
        ...                                    file_path=/home/ute/test${i}1.pcap    IP_client=${SSH_IP}
        ...                                    IP_server=${SYSLOG_IP}     hw_type=${i}
        Run keyword and Continue on Failure    Run Keyword and Expect Error      *          Test TLS Handshake
        ...                                    file_path=${pcap_path}     IP_client=${LMP_IP}
        ...                                    IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}      hw_type=${i}

        Log  Step 15: Deleting the ${POD} pod on ${i}                                                       console=true
        Delete Specific Pod    hw_type=${i}    specific_pod=${POD}
        Sleep    120s    reason=Wait until pod is deleted

        Log  Step 16: Waiting until BTS is onAir state                                                      console=true
        Wait Until Keyword Succeeds  20x  1min       Check if Unit Status is OnAir    hw_type=${i}
        Sleep   60s                  reason=waiting until all alarms occure

#        Log  Step 18: Checking alarms on the opposite unit                                                  console=true
#
#        IF    '${i}' == 'vCU'
#            Alarm Should not be Active    alarm=4752    hw_type=vDU
#            Alarm Should not be Active    alarm=4776    hw_type=vDU
#        ELSE IF    '${i}' == 'vDU'
#            Alarm Should not be Active    alarm=4752    hw_type=vCU
#            Alarm Should not be Active    alarm=4776    hw_type=vCU
#        END

        Log  Step 19: Checking if alarms with fault 4752 and 4776 are visibled in ${i}                      console=true
        Alarm Should be Active          alarm=4752    hw_type=${i}
        ${fault_4752_time}              Get Information of Active Alarms         4752       appear_time    ${i}
        Alarm Should be Active          alarm=4776    hw_type=${i}
        ${fault_4776_time}              Get Information of Active Alarms         4776       appear_time    ${i}

        Log  Step 20: Verifiing details of faults                                                           console=true
        Checke Details of Alarm         fault_id=4752              error=${error_tls_syslog}        hw_type=${i}
        ${result}=    Run Keyword And Ignore Error    Checke Details of Alarm    fault_id=4776    error=${error_LDAP}     hw_type=${i}
        Run Keyword If    '${result[0]}' == 'FAIL'    Checke Details of Alarm    fault_id=4776    error=${error_alarm}    hw_type=${i}

        Log  Step 21: Initiate the procedure of faults cancellation one by one on ${i}                      console=true
        Change Parameter on BTS               dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                                   param_name=actRemoteSyslogTransmission
        ...                                   param_value=false
        ...                                   hw_type=${i}
        Log  On BTS set correct RSA certificate                                                             console=true
        Restore Default Certificates on BTS   hw_type=${i}
        Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME}
        ...                             server_type=RSA
        ...                             ca_server_host=${RSA_HOST}
        ...                             server_path=pkix
        ...                             ca_server_port=8080
        ...                             ee_subject_name=CN=${MRBTS_ID}-${i}
        ...                             hw_type=${i}
        Update CMP Server Settings      ref_number=56215    psk_key=X2gd-4PJa-QLo2-rk9k     key_pool_type=RSA   hw_type=${i}
        Wait Until Keyword Succeeds     5x    1min   Initialize Certificate          key_pool_type=RSA
        ...                             hw_type=${i}
        Wait Until Keyword Succeeds     5x    1min   Initialize Certificate          key_pool_type=ECDSA        hw_type=${i}
        Start TCPdump    capture_type=pod       pod_names=${pcap_pod}        hw_type=${i}
        Sleep       30s  reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        Log  Log in to the WebEM using the centralized user account                                         console=true
        Connect to ADMIN                username=${CNUM_username}
        ...                             password=${CNUM_password}
        ...                             hw_type=${i}
        ${pid}=    Collect PCAP from syslog server    test${i}2.pcap
        Log  Start syslog transmission to a remote server                                                   console=true
        Change Parameter on BTS               dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                                                                   param_name=actRemoteSyslogTransmission
        ...                                                                   param_value=true
        ...                                                                   hw_type=${i}
        ${pcap_path}=    Stop TCPdump and Download Pcap      pod_name=${pcap_pod}                   hw_type=${i}
        Run keyword and Continue on Failure    Stop and colledt PCAP from syslog server    ${pid}    test${i}2.pcap

        Log  Step 22: Checking active alarms on ${i}                                                        console=true
        Alarm Should be Active          alarm=4752    hw_type=${i}
        Alarm Should not be Active      alarm=4776    hw_type=${i}
        Log    Stop syslog transmission                                                                     console=true
        Change Parameter on BTS               dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                                   param_name=actRemoteSyslogTransmission
        ...                                   param_value=false
        ...                                   hw_type=${i}

        Log  Step 23: Verification of collected pcap logs                                                   console=true
        Run keyword and Continue on Failure
        ...   Test TLS Handshake    file_path=${pcap_path}       IP_client=${LMP_IP}     IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}     hw_type=${i}
        Run keyword and Continue on Failure    Run Keyword and Expect Error     *          Test TLS Handshake
        ...                                    file_path=/home/ute/test${i}1.pcap    IP_client=${SSH_IP}
        ...                                    IP_server=${SYSLOG_IP}     hw_type=${i}

        Log  Step 24: Continue the procedure of faults cancellation one by one on ${i}                      console=true
        Log  On BTS set supported TLS version by syslog server                                              console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=actEnableTLSv13
        ...                             param_value=true
        ...                             hw_type=${i}
        Log  Verify successful TLS connection (pcap logs) on ${i} to TLS servers and syslog output          console=true
        Start TCPdump    capture_type=pod       pod_names=${pcap_pod}        hw_type=${i}
        Sleep       30s  reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        Log  Log in to the WebEM using the centralized user account                                         console=true
        ${connection_CNUM}=             Connect to ADMIN                username=${CNUM_username}
        ...                                                             password=${CNUM_password}
        ...                                                             hw_type=${i}
        Sleep    10s    reason=Wait until handshake occurs
        ${pcap_path}=    Stop TCPdump and Download Pcap      pod_name=${pcap_pod}                   hw_type=${i}
        ${pid}=    Collect PCAP from syslog server    test${i}3.pcap
        Log  Start syslog transmission to a remote server                                                   console=true
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                             param_name=actRemoteSyslogTransmission
        ...                             param_value=true
        ...                             hw_type=${i}
        ...                             pre-connection=${connection_CNUM}
        Sleep    20s    reason=Wait until handshake occurs
        Run keyword and Continue on Failure    Stop and colledt PCAP from syslog server    ${pid}    test${i}3.pcap

        Log  Step 25: Checking active alarms on ${i}                                                        console=true
        Alarm Should not be Active   alarm=4752    hw_type=${i}
        Alarm Should not be Active   alarm=4776    hw_type=${i}

        Log    Stop syslog transmission                                                                     console=true
        Change Parameter on BTS               dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...                                   param_name=actRemoteSyslogTransmission
        ...                                   param_value=false
        ...                                   hw_type=${i}

        Log  Step 27: Veryfing pcap logs                                                                    console=true
        Run keyword and Continue on Failure
        ...   Test TLS Handshake    file_path=${pcap_path}       IP_client=${LMP_IP}     IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}     hw_type=${i}
        Run keyword and Continue on Failure
        ...   Test TLS Handshake    file_path=/home/ute/test${i}3.pcap   IP_client=${SSH_IP}   IP_server=${SYSLOG_IP}  hw_type=${i}

        Log  Step 28: Checking alarm history on ${i}                                                        console=true
        ${appear_history_time_4752}=            Get Apper Time of Historical Alarms         4752       ${i}
        ${appear_history_time_string_4752}=          Convert To String                          ${appear_history_time_4752}
        Should Contain       ${appear_history_time_string_4752}    ${fault_4752_time}
        ${appear_history_time_4776}=          Get Apper Time of Historical Alarms         4776         ${i}
        ${appear_history_time_string_4776}=          Convert To String                          ${appear_history_time_4776}
        Should Contain       ${appear_history_time_string_4776}    ${fault_4776_time}

        Log  Step 29: Verifing detailes of historical alarms                                                console=true
        ${additional_info_4752}=     Get Additional Info of Specified Historical Alarm           ${fault_4752_time}     ${i}
        ${additional_info_string_4752}=          Convert To String           ${additional_info_4752}
        Should Contain          ${additional_info_string_4752}               ${error_tls_syslog}
        ${additional_info_4776}=     Get Additional Info of Specified Historical Alarm           ${fault_4776_time}     ${i}
        ${additional_info_string_4776}=          Convert To String           ${additional_info_4776}
        ${result}=    Run Keyword And Ignore Error    Should Contain          ${additional_info_string_4776}               ${error_LDAP}
        Run Keyword If    '${result[0]}' == 'FAIL'    Should Contain          ${additional_info_string_4776}               ${error_alarm}

        Log  Deintegrate ${i} from NMS                                                                      console=true
        Run Keyword and Ignore Error    Deactivate CNUM    LAB_NAME=${NMS_LAB}    hw_type=${i}
        Run Keyword and Ignore Error    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}   hw_type=${i}
    END
    [Teardown]    Run keywords        Log    Teardown started   console=true
    ...            AND            Run Keyword and Ignore Error    Deactivate CNUM    LAB_NAME=${NMS_LAB}    hw_type=vDU
    ...            AND            Run Keyword and Ignore Error    Deactivate CNUM    LAB_NAME=${NMS_LAB}    hw_type=vCU
    ...            AND            Run Keyword and Ignore Error    Deintegrate Cloud BTS from NMS Lab   LAB_NAME=${NMS_LAB}    hw_type=vDU
    ...            AND            Run Keyword and Ignore Error    Deintegrate Cloud BTS from NMS Lab   LAB_NAME=${NMS_LAB}    hw_type=vCU
    ...            AND            Run Keyword And Ignore Error    Teardown for Syslog and CNUM Actions   ${pid}

CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    [Arguments]    ${hw_type}=vDU
    ${MRBTS_ID}    Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
    ${CRAN}=    Set Variable If    '${hw_type}'=='vCU'    ${CRAN_VCU}    ${CRAN_VDU}
    ${LMP_IP}=    Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${SSH_IP}=    Set Variable If    '${hw_type}'=='vCU'    ${SSH_VCU_IP}    ${SSH_VDU_IP}
    Log  Step 1: Setting preconditions                        console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                param_name=actRestrictLoginToCnum
    ...                                param_value=false
    ...                                hw_type=${hw_type}
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                param_name=enableUserAccountCtrlAlarm
    ...                                param_value=false
    ...                                hw_type=${hw_type}
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CRLH-1
    ...                                param_name=usageEnabled
    ...                                param_value=Disabled
    ...                                hw_type=${hw_type}
    Restore Default Certificates on BTS    hw_type=${hw_type}

    Log    Step 1a: Integrate with NMS               console=true
    ${NMS_LAB}=   Integrate Cloud BTS with NMS Lab with TLS   preferred_lab=${PREF_NMS_LAB}   hw_type=${hw_type}
    Activate CNUM user   LAB_NAME=${NMS_LAB}    hw_type=${hw_type}
    Import Variables       ${CURDIR}/../../../cloud_common_resources/mantaray/config/netact/${NMS_LAB}.py
    Set Test Variable      ${CNUM_IP}       ${LBWAS_IP}

    Log    Step 2: Setup syslog settings    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=certTypeForTlsAuth
    ...                                param_value=ECDSA
    ...                                hw_type=${hw_type}

    Syslog Configuration             syslog_DSCP=0
    ...                              syslog_format=RFC5424
    ...                              syslog_server_host=${SYSLOG_IP}
    ...                              syslog_port=6517
    ...                              syslog_transmision_duration=10080
    ...                              syslog_protocol=TLS
    ...                              hw_type=${hw_type}

    Log    Step 3: Configure enableCnumLdapCtrlAlarm     console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1
    ...                                param_name=enableCnumLdapCtrlAlarm
    ...                                param_value=true
    ...                                hw_type=${hw_type}

    Log    Step 4: Configure TLS    console=true
    Configure TLS versions          1_2=true    1_3=true    hw_type=${hw_type}
    Turn On/Off TLS                 state=on     hw_type=${hw_type}

    Log    Step 5: Initialize ECDSA certificate    console=true
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=${hw_type}
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}    server_type=ECDSA    hw_type=${hw_type}
    Wait Until Keyword Succeeds    5x    1min      Initialize Certificate    key_pool_type=ECDSA    hw_type=${hw_type}

    Log    Step 6: Start collecting tcpdump    console=true
    ${pid}=    Collect PCAP from syslog server    test03${hw_type}.pcap
    Start TCPdump    capture_type=plane    plane_type=mplane    hw_type=${hw_type}

    Log    Step 7: Start syslog transmission and login with CNUM user    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=true
    ...                                hw_type=${hw_type}
    Connect to ADMIN                   username=${CNUM_username}
    ...                                password=${CNUM_password}
    ...                                hw_type=${hw_type}
    Sleep    60    reason=Wait until handshake occurs

    Log    Step 8: Stop TCPdump and check TLS handshake    console=true
    Stop and colledt PCAP from syslog server    ${pid}    test03${hw_type}.pcap
    ${pcap}=    Stop TCPdump and Download Pcap     hw_type=${hw_type}    pod_name=oamext
    Run keyword and Continue on Failure
    ...   Test TLS Handshake    file_path=${pcap}       IP_client=${LMP_IP}     IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}     hw_type=${hw_type}
    Run keyword and Continue on Failure
    ...  Test TLS Handshake    file_path=/home/ute/test03${hw_type}.pcap  IP_client=${SSH_IP}   IP_server=${SYSLOG_IP}  hw_type=${hw_type}

    Log    Step 9: Check if alarms are not active    console=true
    Alarm Should not be Active   alarm=4752    hw_type=${hw_type}
    Alarm Should not be Active   alarm=4776    hw_type=${hw_type}

    Log    Stop syslog transmission    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=false
    ...                                hw_type=${hw_type}

    Log  Step 11: Initiate the procedure of TLS connection failure to trigger faults 4752,4776      console=true
    Log  On BTS set wrong certificates                                                               console=true
    Restore Default Certificates on BTS    hw_type=${hw_type}
    Update CMP Server Settings      key_pool_type=RSA                                 hw_type=${hw_type}
    Configure CMP                   ca_subject_name=${ALETRNATIVE_ECDSA_CA}    server_type=RSA        hw_type=${hw_type}
    Configure CMP                   ca_subject_name=${ALETRNATIVE_ECDSA_CA}    server_type=ECDSA      hw_type=${hw_type}
    Wait Until Keyword Succeeds     5x    1min   Initialize Certificate        key_pool_type=RSA      hw_type=${hw_type}
    Wait Until Keyword Succeeds     5x    1min   Initialize Certificate        key_pool_type=ECDSA    hw_type=${hw_type}

    Log    Step 12: Start TCPdump    console=true
    ${pid}=    Collect PCAP from syslog server    test03${hw_type}1.pcap
    Start TCPdump    capture_type=plane    plane_type=mplane    hw_type=${hw_type}

    Log    Step 13: Login with cnum user and start syslog transmission     console=true
    Log  Start syslog transmission to a remote server                                                   console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=true
    ...                                hw_type=${hw_type}
    Log  Log in to the WebEM using the centralized user account and expect error                        console=true
    Run Keyword And Expect Error     *${login_error}*      Connect to ADMIN
    ...                                                    username=${CNUM_username}
    ...                                                    password=${CNUM_password}
    ...                                                    hw_type=${hw_type}
    Sleep    10
    Log  Step 14: Verification of collected pcap logs              console=true
    ${pcap}=    Stop TCPdump and Download Pcap     hw_type=${hw_type}    pod_name=oamext
    Stop and colledt PCAP from syslog server    ${pid}    test03${hw_type}1.pcap
    ${syslog_filters}=     Catenate    ip.addr == ${SSH_IP}  and ip.addr == ${SYSLOG_IP} and tls.record.content_type == 21
    ${syslog_err}=    Run    tshark -r /home/ute/test03${hw_type}1.pcap -Y "${syslog_filters}"
    Run keyword and Continue on Failure    Should Contain         ${syslog_err}    Level: Fatal
    Run keyword and Continue on Failure    Should Contain         ${syslog_err}    Unknown CA

    ${CNUM_filters}=     Catenate    ip.addr == ${LMP_IP}  and ip.addr == ${CNUM_IP} and tls.record.content_type == 21
    ${CNUM_err}=    Run    tshark -r ${pcap} -Y "${CNUM_filters}"
    Run keyword and Continue on Failure    Should Contain         ${CNUM_err}    Level: Fatal
    Run keyword and Continue on Failure    Should Contain         ${CNUM_err}    Unknown CA

    Log    Step 15: Check if alarms are active    console=true
    Alarm Should be Active   alarm=4752    hw_type=${hw_type}
    Alarm Should be Active   alarm=4776    hw_type=${hw_type}
    Log    Step 16: Check if alarms have additional info    console=true
    Checke Details of Alarm    fault_id=4752        error=${error_cert_syslog}          hw_type=${hw_type}
    Checke Details of Alarm    fault_id=4776        error=${error_LDAP}            hw_type=${hw_type}

    Log    Step 17: Perform the procedure of site reset on the ${hw_type}          console=true
    Perform Reset and Wait for Expected State    state=onAir   hw_type=${hw_type}

    Log  Step 19: Check if alarms are active    console=true
    Alarm Should be Active   alarm=4752    hw_type=${hw_type}
    Alarm Should be Active   alarm=4776    hw_type=${hw_type}

    Log  Step 20: Verifiing details of faults                                                           console=true
    Checke Details of Alarm         fault_id=4752              error=${error_cert_syslog}        hw_type=${hw_type}
    ${result}=    Run Keyword And Ignore Error    Checke Details of Alarm    fault_id=4776    error=${error_LDAP}     hw_type=${hw_type}
    Run Keyword If    '${result[0]}' == 'FAIL'    Checke Details of Alarm    fault_id=4776    error=${error_alarm}    hw_type=${hw_type}

    Log  Step 21: Initiate the procedure of TLS connection faults cancellation      console=true

    Log    Stop syslog transmission    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=false
    ...                                hw_type=${hw_type}

    Restore Default Certificates on BTS   hw_type=${hw_type}
    Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME}
    ...                             server_type=RSA
    ...                             ca_server_host=${RSA_HOST}
    ...                             server_path=pkix
    ...                             ca_server_port=8080
    ...                             ee_subject_name=CN=MRBTS-${MRBTS_ID}-${hw_type}
    ...                             hw_type=${hw_type}
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}    server_type=ECDSA    hw_type=${hw_type}
    Update CMP Server Settings      ref_number=56215    psk_key=X2gd-4PJa-QLo2-rk9k     key_pool_type=RSA   hw_type=${hw_type}
    Wait Until Keyword Succeeds     5x    1min   Initialize Certificate        key_pool_type=RSA      hw_type=${hw_type}
    Wait Until Keyword Succeeds     5x    1min   Initialize Certificate        key_pool_type=ECDSA    hw_type=${hw_type}

    Log    Step 22: Start collecting tcpdump    console=true
    ${pid}=    Collect PCAP from syslog server    test03${hw_type}2.pcap
    Start TCPdump    capture_type=plane    plane_type=mplane    hw_type=${hw_type}

    Log    Step 23: Start syslog transmission and login with CNUM user    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=true
    ...                                hw_type=${hw_type}

    Connect to ADMIN                   username=${CNUM_username}
    ...                                password=${CNUM_password}
    ...                                hw_type=${hw_type}
    Sleep    60    reason=Wait until handshake occurs

    Log    Step 24: Stop TCPdump and check TLS handshake    console=true
    Stop and colledt PCAP from syslog server    ${pid}    test03${hw_type}2.pcap
    ${pcap}=    Stop TCPdump and Download Pcap     hw_type=${hw_type}    pod_name=oamext
    Run keyword and Continue on Failure
    ...   Test TLS Handshake    file_path=${pcap}       IP_client=${LMP_IP}     IP_server=${CNUM_IP}    IP_port=${CNUM_PORT}     hw_type=${hw_type}
    Run keyword and Continue on Failure
    ...   Test TLS Handshake    file_path=/home/ute/test03${hw_type}2.pcap  IP_client=${SSH_IP}   IP_server=${SYSLOG_IP}  hw_type=${hw_type}

    Log    Step 25: Check if alarms are not active    console=true
    Alarm Should not be Active   alarm=4752    hw_type=${hw_type}
    Alarm Should not be Active   alarm=4776    hw_type=${hw_type}

    Log    Stop syslog transmission    console=true
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=false
    ...                                hw_type=${hw_type}

    [Teardown]     Run keywords    Log    Teardown started   console=true
    ...            AND             Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                            param_name=actRemoteSyslogTransmission
    ...                            param_value=false
    ...                            hw_type=${hw_type}
    ...            AND             Change Parameter on BTS            dist_name=MRBTS-${MRBTS_ID}/MNL-1/AMGR-1
    ...                            param_name=enableCnumLdapCtrlAlarm
    ...                            param_value=false
    ...                            hw_type=${hw_type}
    ...    AND     Run keyword and ignore error    Stop and colledt PCAP from syslog server    ${pid}    test03${hw_type}_teardown.pcap
    ...    AND     Run keyword and ignore error    Stop TCPdump and Download Pcap     hw_type=${hw_type}    pod_name=oamext
    ...    AND     Run keyword and ignore error    Deactivate CNUM    LAB_NAME=${NMS_LAB}    hw_type=${hw_type}
    ...    AND     Run keyword and ignore error    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}   hw_type=${hw_type}

