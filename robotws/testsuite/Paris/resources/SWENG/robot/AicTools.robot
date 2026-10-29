*** Settings ***

Documentation
...           Useful keywords being used to run some specific commands on FHGW and on VDU

Library       BuiltIn
Library       DateTime
Library       OperatingSystem
Library       String

Library       taf.transport.ssh                     WITH NAME    ssh

*** Keywords ***

Get FHGW SW version
    [Documentation]         INTERNAL USAGE
    ...                     Get the FHGW software version
    ssh.Connect To   hostname=${AIC_FHGW_IP}    username=${AIC_FHGW_USER}    password=${AIC_FHGW_PASSWORD}    alias=sshfhgw
    ${FHGW_SW_version}=    ssh.Execute    command=cat /etc/fhgw-release | grep release | grep -Po '\\d+.\\d+.\\d+.\\d+.\\d+'    connection=sshfhgw
    SSH.Disconnect    connection=sshfhgw

Check Ruproxy Pod
    [Documentation]         INTERNAL USAGE
    ...                     Check that ruproxy pods are available on FHGW
    [Arguments]             ${alias}=sshfhgw
    ${docker_ps_result}=    ssh.Execute    command=docker ps    connection=${alias}
    Dated Log               --> docker_ps_result=${docker_ps_result}
    ${check_result}         should_contain_x_times    item1=${docker_ps_result}    item2=ruproxy    count=2

    Run Keyword If          '${check_result}'=='True'     Run Keywords
    ...                     Dated Log   --> FHGW ruproxy-1 && ruproxy-2 pods are available
    ...        AND          Return From Keyword           PASS

    Run Keyword If          '${check_result}'=='False'    Run Keywords
    ...                     Dated Log   --> FHGW ruproxy-1 && ruproxy-2 pods are not yet available
    ...        AND          Return From Keyword           FAIL

Create Ruproxy Pod
    [Documentation]         INTERNAL USAGE
    ...                     start Ruproxy on the FHGW
    ssh.Connect To   hostname=${AIC_FHGW_IP}   username=${AIC_FHGW_USER}    password=${AIC_FHGW_PASSWORD}    alias=sshfhgw
    ${result}=     ssh.Execute    command=python3 create_ruproxy_new.py 1 1    connection=sshfhgw
    should contain      ${result}    Commit is successful     msg=FHGW ruproxy-1 could not be created
    # Dated Log         --> FHGW ruproxy-1 create
    ${result}=     ssh.Execute    command=python3 create_ruproxy_new.py 2 2    connection=sshfhgw
    should contain      ${result}    Commit is successful     msg=FHGW ruproxy-2 could not be created
    # Dated Log         --> FHGW ruproxy-2 create
    wait until keyword succeeds    2min    30s      Check Ruproxy Pod    alias=sshfhgw
    ssh.Execute    command=redis-cli hmset interfaceDB.config.cpriPort:Ethernet1 ethernetBitRate 184320    connection=sshfhgw
    ssh.Execute    command=redis-cli hmset interfaceDB.config.cpriPort:Ethernet2 ethernetBitRate 184320    connection=sshfhgw
    Dated Log         --> FHGW Ethernet1 and Ethernet2 ethernetBitRate configured
    SSH.Disconnect    connection=sshfhgw

Remove Ruproxy Pod
    [Documentation]         INTERNAL USAGE
    ...                     remove Ruproxy on the FHGW
    ssh.Connect To   hostname=${AIC_FHGW_IP}    username=${AIC_FHGW_USER}    password=${AIC_FHGW_PASSWORD}    alias=sshfhgw
    ssh.Execute    command=python3 removePod_new.py 1    connection=sshfhgw
    Dated Log         --> FHGW ruproxy-1 remove
    ssh.Execute    command=python3 removePod_new.py 2    connection=sshfhgw
    Dated Log         --> FHGW ruproxy-2 remove
    sleep    30s    reason=waiting for ruproxy pod remove done
    ${docker_ps_result}=    ssh.Execute    command=docker ps    connection=sshfhgw
    ${check_result}    Run Keyword And Return Status    should_not_contain    ${docker_ps_result}    ruproxy
    Run Keyword If    '${check_result}'=='True'     Dated Log         --> FHGW ruproxy-1 && ruproxy-2 pods remove successful
    Run Keyword If    '${check_result}'=='False'    Dated Log         --> FHGW ruproxy-1 && ruproxy-2 pods remove fail, please check it
    SSH.Disconnect    connection=sshfhgw


Check FHGW MRI States
    [Documentation]         INTERNAL USAGE
    ...                     Check Ruproxy status on the FHGW
    [Arguments]             ${expected_mri_states}
    ssh.Connect To   hostname=${AIC_FHGW_IP}    username=${AIC_FHGW_USER}    password=${AIC_FHGW_PASSWORD}    alias=sshfhgw
    ${FHGW_RMOD1_MRI_States}=    ssh.Execute    command=redis-cli -h redis -n 18 GET mriState    connection=sshfhgw
    ${FHGW_RMOD2_MRI_States}=    ssh.Execute    command=redis-cli -h redis -n 19 GET mriState    connection=sshfhgw
    Dated Log         --> FHGW RMOD-1 MRI States:${FHGW_RMOD1_MRI_States}
    Dated Log         --> FHGW RMOD-2 MRI States:${FHGW_RMOD2_MRI_States}
    ${RMOD1_result}    Run Keyword And Return Status    should_contain    ${FHGW_RMOD1_MRI_States}    ${expected_mri_states}
    ${RMOD2_result}    Run Keyword And Return Status    should_contain    ${FHGW_RMOD2_MRI_States}    ${expected_mri_states}
    Run Keyword If    '${RMOD1_result}'=='False'
    ...               Dated Log         --> maybe FHGW redisDB not update,please try re-create ruproxy-1 pod to fix it
    Run Keyword If    '${RMOD2_result}'=='False'
    ...               Dated Log         --> maybe FHGW redisDB not update,please try re-create ruproxy-2 pod to fix it
    SSH.Disconnect    connection=sshfhgw
    Should Be True    '${RMOD1_result}'=='True' and '${RMOD2_result}'=='True'


Adding DCI syscom route in vDU L2RT
    [Documentation]         INTERNAL USAGE
    ...                     Add DCI SYSCOM route to VDU L2RT

    [Arguments]
    ...                     ${debug}=${False}

    ${kcmd}                 Set variable
    ...                     bash -c "(echo aasyscomgw -a 0x573A 192.168.218.20 29211 192.168.218.84 29211;sleep 5) | telnet 0 15006"
    ${res}                  K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=l2rt
    ...                     cmd=${kcmd}         debug=${True}
    Run keyword If          ${debug}
    ...                     Dated log           Adding DCI syscom route : RES=[${res}]


Adding DCI BIP route in vDU L2RT
    [Documentation]         INTERNAL USAGE
    ...                     Add DCI BIP route to VDU L2RT

    [Arguments]
    ...                     ${debug}=${False}

    ${kcmd}                 Set Variable
    ...                     hal-cli show port table | grep -A2 MAC-ADDR | grep -Po '\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}' | tr -d '\\r\\n'
    ${src_mac_addr}         K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=l2rt
    ...                     cmd=${kcmd}         debug=${True}
    Run keyword If          ${debug}
    ...                     Dated log           Adding DCI BIP route : src_mac_addr=[${src_mac_addr}]

    ${kcmd}                 Set Variable
    ...                     bipcli node -a 0x432 -p 0 -o ${src_mac_addr} -u 9000 -c 02:40:43:80:40:34
    ${res}                  K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=l2rt
    ...                     cmd=${kcmd}         debug=${True}
    Run keyword If          ${debug}
    ...                     Dated log           Adding DCI BIP route : res=[${res}]

    ${kcmd}                 Set Variable
    ...                     bipcli node -s
    ${bip_route_list}       K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=l2rt
    ...                     cmd=${kcmd}         debug=${True}
    Run keyword If          ${debug}
    ...                     Dated log           Adding DCI BIP route : bip_route_list=[${bip_route_list}]

    Should Contain          ${bip_route_list}      0x432


Nft Firewall Flush On vDU
    [Documentation]         INTERNAL USAGE
    ...                     Run NFT firewall flush commands on nftmgmt container

    [Arguments]
    ...                     ${debug}=${True}

    # kubectl exec -it po-6-6-ute5g002-up-0 -c ctr-6-6-ute5g002-nftmgmt -n 6-6-ute5g002 -- nft list ruleset

    ${kcmd}                 Set variable
    ...                     nft list ruleset

    ${res}                  K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=nftmgmt
    ...                     cmd=${kcmd}         debug=${True}

    Run keyword If          ${debug}
    ...                     Dated log           Nft list ruleset : RES=[${res}]

    # kubectl exec -it po-6-6-ute5g002-up-0 -c ctr-6-6-ute5g002-nftmgmt -n 6-6-ute5g002 -- nft flush ruleset

    ${kcmd}                 Set variable
    ...                     nft flush ruleset

    ${res}                  K8s cmd
    ...                     k8s=${GNB_DU}       podName=up-0     containerName=nftmgmt
    ...                     cmd=${kcmd}         debug=${True}

    Run keyword If          ${debug}
    ...                     Dated log           Nft flush ruleset : RES=[${res}]

