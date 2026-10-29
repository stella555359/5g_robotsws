*** Settings ***
Documentation
...  author:  Lukasz Saracyn
...  contact: lukasz.saracyn@nokia.com

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     Collections
Library     String

*** Keywords ***
Ping_one_to_other_subnet
    [Arguments]    ${hw_type}    ${cran}    ${IP_1}    ${IP_2}
    ${ssh_conn_k8s}    Connect to K8s via SSH          alias=ssh_conn_k8s               hw_type=${hw_type}
    Log                Connected to K8s    console=true
    Log                Ping from ${IP_1} to ${IP_2}     console=true
    ${ping_broad}=   SSHLibrary.Execute Command      oc exec -it -n cran1 po-${cran}-cprt-0 -- ping -I ${IP_1} -b -c 5 -W 10 ${IP_2}
    ...                                                connection=${ssh_conn_k8s}
    [Teardown]         Disconnect from K8s via SSH     index_or_alias=${ssh_conn_k8s}
    [Return]           ${ping_broad}

Host_IP_Change_To_Broadcast
    [Documentation]    This keyword changes 4th octet in IP address to have subnet broadcast address
    [Arguments]    ${IP_Host}
    ${IP_Octet}=   Split String    ${IP_Host}    .
    Set List Value    ${IP_octet}    -1    255
    ${IP_Broadcast}=      Catenate    ${IP_octet[0]}.${IP_octet[1]}.${IP_octet[2]}.${IP_octet[3]}
    [Return]    ${IP_Broadcast}
