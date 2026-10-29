*** Settings ***
Documentation
...    Author:            Patryk Tatarek
...    Contact:           patryk.tatarek@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/24R3/CB009857/
...    Description:

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     taf.transport.ssh       WITH NAME    ssh
Library     SSHLibrary
Library     Collections
Library     String
Resource    ../../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../../cloud_common_resources/alarms/alarms.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/tls/tls.robot
Resource    ../../../../cloud_common_resources/emssim/emssim_setup.robot
Resource    ../Resources/NESAS-C_Cloud_Keywords.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../../cloud_common_resources/connections/connections.robot

Variables    ../Resources/aashell_ports.py

*** Variables ***
${SSH_USERNAME}=           ${SSH_K8S_USERNAME}
${SSH_PASSWORD}=           ${SSH_K8S_PASSWORD}
${perm_error}=             drop permissions failed
${no_mount_error}=         `mount` not found
${wrong_user_error}=       must be superuser to use mount
${command_error}=          command terminated
${ashell_addr}=            127.0.0.1
${aashell_error_1}=        Invalid command
${aashell_error_2}=        not a valid command
${all_packet_lost}=        100% packet loss
${ping_success}=    0% packet loss
${ping_fail}=       100% packet loss
${local_password}=          Qwerty!23$
${local_invalid_password}=  abcde
@{pods}=                    cprt
...                         oamext
...                         oamfh
${RSA_SUBJECT_NAME}=        C=PL, O=Common, CN=IPSEC
${TOO_SHORT}                ${CURDIR}/certificates/servercert.pem
${vm_ipv4}                  10.44.180.38
@{CIPHER_SUITES1_2}=        TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_RSA_WITH_AES_128_GCM_SHA256


*** Keywords ***
Perform_Mount_Options_Check_vCU
    Log              Step 2: Try to mount filesystem on each pod as non-root user    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Trying to mount filesystem on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}     command=mount /something /tmp
        ...                                                 raw_output=${True}    hw_type=vCU
        Run Keyword and Continue on Failure    Should Contain Any    ${output}
        ...                                    ${perm_error}    ${no_mount_error}
        ...                                    ${wrong_user_error}    ${command_error}
    END
    Log              Step 3: Try to mount filesystem on every container of each pod as non-root user    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vCU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VCU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Trying to mount filesystem on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=mount /something /tmp    raw_output=${True}    hw_type=vCU
            Run Keyword and Continue on Failure    Should Contain Any    ${output}
            ...                                    ${perm_error}    ${no_mount_error}
            ...                                    ${wrong_user_error}    ${command_error}
        END
    END

Perform_Mount_Options_Check_vDU
    Log              Step 2: Try to mount filesystem on each pod as non-root user    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Trying to mount filesystem on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}     command=mount /something /tmp
        ...                                                 raw_output=${True}    hw_type=vDU
        Run Keyword and Continue on Failure    Should Contain Any    ${output}
        ...                                    ${perm_error}    ${no_mount_error}
        ...                                    ${wrong_user_error}    ${command_error}
    END
    Log              Step 3: Try to mount filesystem on every container of each pod as non-root user    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vDU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VDU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Trying to mount filesystem on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=mount /something /tmp    raw_output=${True}    hw_type=vDU
            Run Keyword and Continue on Failure    Should Contain Any    ${output}
            ...                                    ${perm_error}    ${no_mount_error}
            ...                                    ${wrong_user_error}    ${command_error}
        END
    END

Unexpected_input_command_in_Aashell_vCU
    Log                           Step 1: Get list of available pods    console=true
    ${all_pods}=                  Execute Command on Cluster
    ...                           command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=                 Split String    ${all_pods}    ${SPACE}
    SSHLibrary.Open Connection    host=${SSH_VCU_IP}
    SSHLibrary.Login              username=${SSH_USERNAME}    password=${SSH_PASSWORD}
    Sleep    3                    reason=Wait until terminal execute the command
    ${valid_pods}=                Get Dictionary Keys    ${vcu_ports}
    Log                           Step 2-5: Verify AaShell on every pods    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        FOR  ${valid_pod}  IN  @{valid_pods}
            ${valid}=           Run Keyword and Return Status    Should Contain    ${single_pod}    ${valid_pod}
            IF                  not ${valid}    CONTINUE
            SSHLibrary.Write    kubectl exec -it ${single_pod} -n ${CRAN_VCU} -- /bin/bash
            Sleep    2          reason=Wait until terminal execute the command
            ${ports}=           Get From Dictionary    ${vcu_ports}    ${valid_pod}
            ${is_list}=         Evaluate    isinstance(${ports}, list)
            ${ports}=           Run Keyword If    not ${is_list}    Create List    ${ports}
            ...                 ELSE    Set Variable    ${ports}
            FOR  ${port}  IN  @{ports}
                Log    Verifying port ${port} of ${valid_pod} pod    console=true
                SSHLibrary.Write      nc ${ashell_addr} ${port}
                Sleep    1            reason=Wait until terminal execute the command
                SSHLibrary.Write      atrace -m START
                Sleep    1            reason=Wait until terminal execute the command
                ${output}=            SSHLibrary.Read
                Should Contain Any    ${output}    ${aashell_error_1}    ${aashell_error_2}
                SSHLibrary.Write      quit
                SSHLibrary.Write      ${SPACE}    #Exiting AaShell requires additional action after quit command
            END
            SSHLibrary.Write    exit
            Sleep    1          reason=Wait until terminal execute the command
            Exit For Loop If    ${valid}
        END
    END
    [Teardown]    Run Keywords    SSHLibrary.Write    quit
    ...    AND                    SSHLibrary.Write    ${SPACE}
    ...    AND                    SSHLibrary.Write    exit
    ...    AND                    SSHLibrary.Close Connection

Unexpected_input_command_in_Aashell_vDU
    Log                           Step 1: Get list of available pods    console=true
    ${all_pods}=                  Execute Command on Cluster
    ...                           command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=                 Split String    ${all_pods}    ${SPACE}
    SSHLibrary.Open Connection    host=${SSH_VDU_IP}
    SSHLibrary.Login              username=${SSH_USERNAME}    password=${SSH_PASSWORD}
    Sleep    3                    reason=Wait until terminal execute the command
    ${valid_pods}=                Get Dictionary Keys    ${vdu_ports}
    Log                           Step 2-5: Verify AaShell on every pods    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        FOR  ${valid_pod}  IN  @{valid_pods}
            ${valid}=           Run Keyword and Return Status    Should Contain    ${single_pod}    ${valid_pod}
            IF                  not ${valid}    CONTINUE
            SSHLibrary.Write    kubectl exec -it ${single_pod} -n ${CRAN_VDU} -- /bin/bash
            Sleep    2          reason=Wait until terminal execute the command
            ${ports}=           Get From Dictionary    ${vdu_ports}    ${valid_pod}
            ${is_list}=         Evaluate    isinstance(${ports}, list)
            ${ports}=           Run Keyword If    not ${is_list}    Create List    ${ports}
            ...                 ELSE    Set Variable    ${ports}
            FOR  ${port}  IN  @{ports}
                Log    Verifying port ${port} of ${valid_pod} pod    console=true
                SSHLibrary.Write      nc ${ashell_addr} ${port}
                Sleep    1            reason=Wait until terminal execute the command
                SSHLibrary.Write      atrace -m START
                Sleep    1            reason=Wait until terminal execute the command
                ${output}=            SSHLibrary.Read
                Should Contain Any    ${output}    ${aashell_error_1}    ${aashell_error_2}
                SSHLibrary.Write      quit
                SSHLibrary.Write      ${SPACE}    #Exiting AaShell requires additional action after quit command
            END
            SSHLibrary.Write    exit
            Sleep    1          reason=Wait until terminal execute the command
            Exit For Loop If    ${valid}
        END
    END
    [Teardown]    Run Keywords    SSHLibrary.Write    quit
    ...    AND                    SSHLibrary.Write    ${SPACE}
    ...    AND                    SSHLibrary.Write    exit
    ...    AND                    SSHLibrary.Close Connection

Protecion_from_buffer_overflows_vCU
    Log               Step 1: Get list of available pods    console=true
    ${all_pods}=      Execute Command on Cluster
    ...               command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=     Split String    ${all_pods}    ${SPACE}
    Log               Step 3: Check the value of kernel.randomize_va_space    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying value of kernel.randomize_va_space on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                                 command=cat /proc/sys/kernel/randomize_va_space
        ${status}=    Run Keyword and Return Status    Should be Equal    ${output}    2\n
        Run Keyword and Continue on Failure    Should be Equal    ${output}    2\n
        IF            ${status}    CONTINUE
        Log           Step 4: Change value of kernel.randomize_va_space in ${single_pod} pod to 2    console=true
        Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                   command=sysctl -w kernel.randomize_va_space=2
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                                 command=cat /proc/sys/kernel/randomize_va_space
        Run Keyword and Continue on Failure    Should be Equal    ${output}    2\n
    END

Protecion_from_buffer_overflows_vDU
    Log               Step 1: Get list of available pods    console=true
    ${all_pods}=      Execute Command on Cluster
    ...               command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=     Split String    ${all_pods}    ${SPACE}
    Log               Step 3: Check the value of kernel.randomize_va_space    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying value of kernel.randomize_va_space on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                                 command=cat /proc/sys/kernel/randomize_va_space
        ${status}=    Run Keyword and Return Status    Should be Equal    ${output}    2\n
        Run Keyword and Continue on Failure    Should be Equal    ${output}    2\n
        IF            ${status}    CONTINUE
        Log           Step 4: Change value of kernel.randomize_va_space in ${single_pod} pod to 2    console=true
        Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                   command=sysctl -w kernel.randomize_va_space=2
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                                 command=cat /proc/sys/kernel/randomize_va_space
        Run Keyword and Continue on Failure    Should be Equal    ${output}    2\n
    END

Traffic_Separation_vCU
    Log               Step 1: Check traffic from Uplane to Cplane    console=true
    ${output}=        Execute Command on Specific Pod    specific_pod=upue    command=ping ${F1C_VCU} -I ${F1U_VCU} -w 5
    ...                                                  hw_type=vCU
    Should Contain    ${output}    ${all_packet_lost}
    Log               Step 2: Check traffic from Cplane to Uplane    console=true
    ${output}=        Execute Command on Specific Pod    specific_pod=cpif    command=ping ${F1U_VCU} -I ${F1C_VCU} -w 5
    ...                                                  hw_type=vCU
    Should Contain    ${output}    ${all_packet_lost}

Traffic_Separation_vDU
    Log               Step 1: Check traffic from Uplane to Cplane    console=true
    ${output}=        Execute Command on Specific Pod    specific_pod=l2nrt    command=ping ${F1C_VDU} -I ${F1U_VDU} -w 5
    ...                                                  hw_type=vDU
    Should Contain    ${output}    ${all_packet_lost}
    Log               Step 2: Check traffic from Cplane to Uplane    console=true
    ${output}=        Execute Command on Specific Pod    specific_pod=cprt    command=ping ${F1U_VDU} -I ${F1C_VDU} -w 5
    ...                                                  hw_type=vDU
    Should Contain    ${output}    ${all_packet_lost}

Proxy_ARP_Disabling_vCU
    Log              Step 2: Check proxy settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying proxy settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_arp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_ndp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_arp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_ndp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
    END
    Log              Step 3: Check proxy settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vCU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VCU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying proxy settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_arp* -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_ndp* -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_arp* -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_ndp* -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        END
    END

Proxy_ARP_Disabling_vDU
    Log              Step 2: Check proxy settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying proxy settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_arp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_ndp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_arp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_ndp* -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
    END
    Log              Step 3: Check proxy settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vDU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VDU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying proxy settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_arp* -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv4/conf/ -type f -name proxy_ndp* -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_arp* -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=find /proc/sys/net/ipv6/conf/ -type f -name proxy_ndp* -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        END
    END

IP_Multicast_Handling_vCU
    Log              Step 2: Verify that IP multicast on each pod is disabled    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log                 Verifying multicast settings on ${single_pod} pod    console=true
        ${interfaces}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                 command=ifconfig | grep MULTICAST | awk '{print $1}'
        ${not_empty}=       Run Keyword and Return Status    Should not be Empty    ${interfaces}
        IF                  not ${not_empty}    CONTINUE
        ${interfaces}=      Split String    ${interfaces}    \n
        Remove From List    ${interfaces}    -1    #Remove last '\n'
        FOR  ${interface}  IN  @{interfaces}
            ${output}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
            ...             command=cat /proc/sys/net/ipv4/conf/${interface[0:-1]}/mc_forwarding
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        END
    END
    Log              Step 3: Verify that IP multicast on every container of each pod is disabled    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=     Execute Command on Cluster    hw_type=vCU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VCU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log                 Verifying multicast settings on ${single_container} container under ${single_pod} pod
            ...                 console=true
            ${interfaces}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
            ...                 command=ifconfig | grep MULTICAST | awk '{print $1}'
            ${not_empty}=       Run Keyword and Return Status    Should not be Empty    ${interfaces}
            IF                  not ${not_empty}    CONTINUE
            ${interfaces}=      Split String    ${interfaces}    \n
            Remove From List    ${interfaces}    -1    #Remove last '\n'
            FOR  ${interface}  IN  @{interfaces}
                ${output}=      Execute Command on Fully Given Container    pod=${single_pod}
                ...             container=${single_container}    hw_type=vCU
                ...             command=cat /proc/sys/net/ipv4/conf/${interface[0:-1]}/mc_forwarding
                Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            END
        END
    END

IP_Multicast_Handling_vDU
    Log              Step 2: Verify that IP multicast on each pod is disabled    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log                 Verifying multicast settings on ${single_pod} pod    console=true
        ${interfaces}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                 command=ifconfig | grep MULTICAST | awk '{print $1}'
        ${not_empty}=       Run Keyword and Return Status    Should not be Empty    ${interfaces}
        IF                  not ${not_empty}    CONTINUE
        ${interfaces}=      Split String    ${interfaces}    \n
        Remove From List    ${interfaces}    -1    #Remove last '\n'
        FOR  ${interface}  IN  @{interfaces}
            ${output}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
            ...             command=cat /proc/sys/net/ipv4/conf/${interface[0:-1]}/mc_forwarding
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        END
    END
    Log              Step 3: Verify that IP multicast on every container of each pod is disabled    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=     Execute Command on Cluster    hw_type=vDU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VDU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log                 Verifying multicast settings on ${single_container} container under ${single_pod} pod
            ...                 console=true
            ${interfaces}=      Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
            ...                 command=ifconfig | grep MULTICAST | awk '{print $1}'
            ${not_empty}=       Run Keyword and Return Status    Should not be Empty    ${interfaces}
            IF                  not ${not_empty}    CONTINUE
            ${interfaces}=      Split String    ${interfaces}    \n
            Remove From List    ${interfaces}    -1    #Remove last '\n'
            FOR  ${interface}  IN  @{interfaces}
                ${output}=      Execute Command on Fully Given Container    pod=${single_pod}
                ...             container=${single_container}    hw_type=vDU
                ...             command=cat /proc/sys/net/ipv4/conf/${interface[0:-1]}/mc_forwarding
                Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            END
        END
    END

Gratuitous_ARP_Disabling_vCU
    Log              Step 2: Check gratuitous arp settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying gratuitous arp settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=cat /proc/sys/net/ipv4/conf/*/drop_gratuitous_arp
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=cat /proc/sys/net/ipv4/conf/*/arp_accept
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=cat /proc/sys/net/ipv4/conf/*/arp_notify
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
    END
    Log              Step 3: Check gratuitous arp settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vCU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VCU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying gratuitous arp settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/drop_gratuitous_arp    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/arp_accept    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/arp_notify    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        END
    END

Gratuitous_ARP_Disabling_vDU
    Log              Step 2: Check gratuitous arp settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying gratuitous arp settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=cat /proc/sys/net/ipv4/conf/*/drop_gratuitous_arp
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=cat /proc/sys/net/ipv4/conf/*/arp_accept
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=cat /proc/sys/net/ipv4/conf/*/arp_notify
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
    END
    Log              Step 3: Check gratuitous arp settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vDU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VDU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying gratuitous arp settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/drop_gratuitous_arp    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/arp_accept    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...           command=cat /proc/sys/net/ipv4/conf/*/arp_notify    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        END
    END

Broadcast_ICMP_Handling_vCU
    Log              Step 2: Check broadcast settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vCU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying broadcast settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name accept_redirects -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name send_redirects -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
        Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_all
        Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
        Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vCU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
        Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
    END
    Log              Step 3: Check broadcast settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vCU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VCU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying broadcast settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=find /proc/sys/net/ipv4/conf/ -type f -name accept_redirects -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=find /proc/sys/net/ipv4/conf/ -type f -name send_redirects -exec cat {} \\;    hw_type=vCU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses    hw_type=vCU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_all    hw_type=vCU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr    hw_type=vCU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts    hw_type=vCU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
        END
    END

Broadcast_ICMP_Handling_vDU
    Log              Step 2: Check broadcast settings on each pod    console=true
    ${all_pods}=     Execute Command on Cluster
    ...              command=kubectl get pods -o jsonpath='{.items[*].metadata.name}'    hw_type=vDU
    @{pods_list}=    Split String    ${all_pods}    ${SPACE}
    FOR  ${single_pod}  IN  @{pods_list}
        Log           Verifying broadcast settings on ${single_pod} pod    console=true
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name accept_redirects -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...           command=find /proc/sys/net/ipv4/conf/ -type f -name send_redirects -exec cat {} \\;
        Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
        Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_all
        Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
        Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
        ${output}=    Execute Command on Fully Given Pod    pod=${single_pod}    hw_type=vDU
        ...                                    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
        Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
    END
    Log              Step 3: Check broadcast settings on every container of each pod    console=true
    FOR  ${single_pod}  IN  @{pods_list}
        ${pod_containers}=    Execute Command on Cluster    hw_type=vDU
        ...    command=kubectl get pod ${single_pod} -n ${CRAN_VDU} -o jsonpath='{.spec.containers[*].name}'
        @{containers_list}=    Split String    ${pod_containers}    ${SPACE}
        FOR  ${single_container}  IN  @{containers_list}
            Log           Verifying broadcast settings on ${single_container} container under ${single_pod} pod
            ...           console=true
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=find /proc/sys/net/ipv4/conf/ -type f -name accept_redirects -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=find /proc/sys/net/ipv4/conf/ -type f -name send_redirects -exec cat {} \\;    hw_type=vDU
            Run Keyword and Continue on Failure    Should Match Regexp    ${output}    ^(0\n)*$
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses    hw_type=vDU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_all    hw_type=vDU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr    hw_type=vDU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    0\n
            ${output}=    Execute Command on Fully Given Container    pod=${single_pod}    container=${single_container}
            ...    command=cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts    hw_type=vDU
            Run Keyword and Continue on Failure    Should be Equal    ${output}    1\n
        END
    END

NESAS-PACK-C-TC_Directed_Broad_Disabling
    ${ping_broad_1}=    Ping_one_to_other_subnet    hw_type=vDU    cran=${CRAN_VDU}    IP_1=${F1C_VDU}    IP_2=${F1C_VCU}
    Log                Ping packets: ${ping_success}     console=true
    Should_Contain     ${ping_broad_1}    ${ping_success}
    ${IP_Broadcast_Uplane}=    Host_IP_Change_To_Broadcast    IP_Host=${F1C_VDU}
    Log                Ping from ${F1C_VDU} to ${IP_Broadcast_Uplane}     console=true
    ${ping_broad_2}=    Ping_one_to_other_subnet    hw_type=vDU    cran=${CRAN_VDU}    IP_1=${F1C_VDU}    IP_2=${IP_Broadcast_Uplane}
    Log                Ping packets: ${ping_fail}     console=true
    Should_Contain     ${ping_broad_2}    ${ping_fail}
    ${IP_Broadcast_Cplane}=    Host_IP_Change_To_Broadcast    IP_Host=${F1C_VCU}
    Log                Ping from ${F1C_VDU} to ${IP_Broadcast_Cplane}     console=true
    ${ping_broad_3}=   Ping_one_to_other_subnet    hw_type=vDU    cran=${CRAN_VDU}    IP_1=${F1C_VDU}    IP_2=${IP_Broadcast_Cplane}
    Log                Ping packets: ${ping_fail}     console=true
    Should_Contain     ${ping_broad_3}    ${ping_fail}

NESAS-CR_EMSSIM_Certificate_Management
    Log    Preconditions            console=true
    Delete All Certificates                        hw_type=vDU
    Restore Default Certificates on BTS            hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=certTypeForTlsAuth    param_value=RSA    hw_type=vDU
    Log    Step 1: Set the oamTlsStatus to true    console=true
    Turn On/Off TLS                 state=on       hw_type=vDU
    Log    Step 2: Setup the EMSSIM environmental  console=true
    Setup environment for EMSSIM    cert_type=RSA  hw_type=vDU
    Log    Step 3: Connecting the VM to the M-Plane with EMSSIM                   console=true
    Run Keyword and Expect Error      *            Connect and Activate EMSSIM    hw_type=vDU
    Log    Step 4: Install too short certificate   console=true
    Run Keyword and Expect Error      *            Install Certificate            cert_path=${TOO_SHORT}
    ...                                                                           cert_type=CA
    ...                                                                           hw_type=vDU
    Log    Step 5, 6: Connecting the VM to the M-Plane with EMSSIM                console=true
    Setup environment for EMSSIM                   cert_type=RSA                  hw_type=vDU
    Run Keyword and Expect Error      *            Connect and Activate EMSSIM    hw_type=vDU
    Log    Step 7: Delete Certificates             console=true
    Delete All Certificates                        hw_type=vDU
    Log    Step 8, 9 : Configure CMP and Update CMP server settings               console=true
    Update CMP Server Settings        key_pool_type=RSA
    ...                               hw_type=vDU
    Configure CMP                     ca_subject_name=${RSA_SUBJECT_NAME}
    ...                               server_type=RSA
    ...                               hw_type=vDU
    Log    Step 10: Initialize Certificate         console=true
    Wait Until Keyword Succeeds    5x    1min      Initialize Certificate         key_pool_type=RSA
    ...                                                                           hw_type=vDU
    Log    Step 11: Checke if certificate is instaled                             console=true
    ${cert_list}=                     Check Certificates                          hw_type=vDU
    ${cert}=                          Convert to String                           /C=PL/O=Common/CN=IPSEC
    ${cert_list_string}=              Convert to String                           ${cert_list}
    Should Contain                    ${cert_list_string}                         ${cert}
    Log    Step 12: Start TCPDUMP     console=true
    Start TCPdump                     capture_type=pod
    ...                               pod_names=po-cran1-oamext-0
    ...                               hw_type=vDU
    Sleep  3s                         reason=TCPdump
    Log    Step 13, 14: Connecting the VM to the M-Plane with EMSSIM              console=true
    Setup environment for EMSSIM      cert_type=RSA                               hw_type=vDU
    ${emssim_conn}=                   Connect and Activate EMSSIM       hw_type=vDU
    Log    Step 15: Stop TCPDUMP      console=true
    Sleep  3s                         reason=TCPdump
    ${pcap_path}=  Stop TCPdump and Download Pcap    pod_name=po-cran1-oamext-0   hw_type=vDU
    Convert pcap to XML    filename=${pcap_path}     xml_name=${CURDIR}/tls.txt
    ...                    filters=tls.handshake.type == 1 && ip.src == ${LMP_VDU_IP} && ip.dst == ${vm_ipv4}
    ${inside_pcap}=        OperatingSystem.Get File  ${CURDIR}/tls.txt
    Should Contain         ${inside_pcap}            TLS 1.2
    Log    Step 16, 17: Checking cipher suites       console=true
    ${cipher_suite_filters}=    Catenate      tls and ip.src == ${LMP_VDU_IP} and ip.dst == ${vm_ipv4} and
    ...                                       tls.record.content_type == 22
    ${cipher_suite}=            Run           tshark -r ${pcap_path} -Y "${cipher_suite_filters}" -V | grep -E "Cipher Suite: "
    FOR    ${cipher}     IN    @{CIPHER_SUITES1_2}
        Should Contain    ${cipher_suite}     ${cipher}
    END
    Log    Step 18: Disconect from EMSSIM       console=true
    Disconnect From EMSSIM                      hw_type=vDU
    ...                                         connection=${emssim_conn}
    Log    Step 19: Delete Certificate          console=true
    Delete All Certificates                     hw_type=vDU
    Restore Default Certificates on BTS         hw_type=vDU

NESAS-CR_Filesystem_Authorization_Privileges
    ${ssh_conn}=           Connect to ADMIN via SSH    hw_type=vDU
    FOR   ${pod}       IN    @{pods}
        ${id_comment}=         ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- id     connection=${ssh_conn}
        Should Not Contain     ${id_comment}        uid=0
        ${proceses}=           ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- ps -ef | awk '{print $2}'
        ...                                         connection=${ssh_conn}
        @{proceses_list}=      Split String    ${proceses}
        FOR    ${proces}    IN     @{proceses_list}[1:]
            ${status}=       ssh.Execute      kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- cat proc/${proces}/status | grep [UG]id
            ...                               connection=${ssh_conn}
            Should Not Contain    ${status}   0
        END
        ${groups}=             ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- cat /etc/group
        ...                                         connection=${ssh_conn}
        Should Contain         ${groups}            root:x:0:
        ${users}=              ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- cat /etc/passwd
        ...                                         connection=${ssh_conn}
        Should Contain         ${users}             root:x:0:0:Super User:/root:/bin/bash
        ${password}=           ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- cat /etc/shadow
        ...                                         connection=${ssh_conn}
        Should Contain         ${password}          cat: /etc/shadow: Permission denied
        ${password}=           ssh.Execute          kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- cat /etc/security/opasswd
        ...                                         connection=${ssh_conn}
        Should Contain         ${password}          cat: /etc/security/opasswd: Permission denied
        ${command}=            Catenate             kubectl exec -it -n ${CRAN_VDU} po-${CRAN_VDU}-${pod}-0 -- find /
        ...                                         -xdev -type d -perm /002 | sort -u | grep find
        ${find_commend}        ssh.Execute          ${command}
        ...                                         connection=${ssh_conn}
        @{list_find}=          Split String         ${find_commend}         find
        FOR    ${find}    IN     @{list_find}[1:]
            Should Contain     ${find}       Permission denied
        END
    END
    Disconnect from ADMIN via SSH           connection=${ssh_conn}    hw_type=vDU

NESAS-CR_Password_Webem_Management_VCU
    Log  Step 1: Connecting to vCU using System Administrator account     console=true
    Connect to ADMIN      hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=1
    ...                             hw_type=vCU
    Log  Step 2: Changing password for System Administrator account       console=true
    Change Local User Account Password    ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${local_password}  hw_type=vCU
    Log  Step 3: Login with new password and checkin alarms               console=true
    ${connection}=    Connect to ADMIN      username=${WEBEM_USERNAME}
    ...                                     password=${local_password}
    ...                                     hw_type=vCU
    No Alarm Should be Active             hw_type=vCU
    ...                                   pre-connection=${connection}
    Log  Step 4: Changing password for System Administrator account        console=true
    Run Keyword and Expect Error    *           Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${local_invalid_password}
    ...                                         connection=${connection}
    ...                                         hw_type=vCU
    Log  Step 5: Login with invalid password                                console=true
    Run Keyword and Expect Error    *       Connect to ADMIN      username=${WEBEM_USERNAME}
    ...                                                           password=${local_invalid_password}
    ...                                                           hw_type=vCU
    Log  Step 6: Changing password to password in history                  console=true
    Run Keyword and Expect Error    *           Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${WEBEM_PASSWORD}
    ...                                         connection=${connection}
    ...                                         hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=0
    ...                             hw_type=vCU
    ...                             pre-connection=${connection}
    Log   Step 7: Redeploing vDU to default values
    Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${WEBEM_PASSWORD}
    ...                                         connection=${connection}
    ...                                         hw_type=vCU
    ${conn}=    Connect to ADMIN                 hw_type=vCU
    Check if Unit Status is OnAir    hw_type=vCU

NESAS-CR_Password_Webem_Management_VDU
    Log  Step 1: Connecting to vDU using System Administrator account     console=true
    Connect to ADMIN      hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=1
    ...                             hw_type=vDU
    Log  Step 2: Changing password for System Administrator account       console=true
    Change Local User Account Password    ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${local_password}  hw_type=vDU
    Log  Step 3: Login with new password and checkin alarms               console=true
    ${connection}=    Connect to ADMIN      username=${WEBEM_USERNAME}
    ...                                     password=${local_password}
    ...                                     hw_type=vDU
    No Alarm Should be Active             hw_type=vDU
    ...                                   pre-connection=${connection}
    Log  Step 4: Changing password for System Administrator account        console=true
    Run Keyword and Expect Error    *           Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${local_invalid_password}
    ...                                         connection=${connection}
    ...                                         hw_type=vDU
    Log  Step 5: Login with invalid password                                console=true
    Run Keyword and Expect Error    *       Connect to ADMIN      username=${WEBEM_USERNAME}
    ...                                                           password=${local_invalid_password}
    ...                                                           hw_type=vDU
    Log  Step 6: Changing password to password in history                  console=true
    Run Keyword and Expect Error    *           Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${WEBEM_PASSWORD}
    ...                                         connection=${connection}
    ...                                         hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=0
    ...                             hw_type=vDU
    ...                             pre-connection=${connection}
    Log   Step 7: Redeploing vDU to default values
    Change Password For Specified Connection    username=${WEBEM_USERNAME}
    ...                                         password=${local_password}
    ...                                         new_password=${WEBEM_PASSWORD}
    ...                                         connection=${connection}
    ...                                         hw_type=vDU
    ${conn}=    Connect to ADMIN                 hw_type=vDU
    Check if Unit Status is OnAir    hw_type=vDU
