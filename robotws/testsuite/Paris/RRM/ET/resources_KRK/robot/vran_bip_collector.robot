*** Settings ***

Documentation
...   author: Mateusz Pajor
...   contact: mateusz.pajor@nokia.com
...   description:  Common Robot keywords for Vran Bip Collector

Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    ../python/bip.py


*** Keywords ***
Collect BIP logs during ${seconds} seconds
    Start collecting BIP logs on vDU    ${vdu_namespace}  ${POD}    ${nwmgmt_container}
    BuiltIn.sleep  ${seconds}
    Stop collecting BIP logs on vDU


Get information about containers
    Log to console  "getting information about containers"
    ${vdu_namespace}=  get vdu namespace
    Set suite variable  ${vdu_namespace}
    ${pod}  get pod  l2rt
    Set Suite Variable  ${POD}
    ${l2rt_container}    get container  ${POD}  l2rt
    Set Suite Variable  ${l2rt_container}
    ${nwmgmt_container}  get container  ${POD}  nwmgmt
    Set Suite Variable  ${nwmgmt_container}
    ${vdu_ssh_details}=  get vdu ssh details
    Set Suite Variable  ${vdu_ssh_details}

Start collecting BIP logs on vDU
    Get information about containers
    Start mirroring l1up    ${POD}    ${l2rt_container}
    &{vdu}=    Create Dictionary
    ...    host=${vdu_ssh_details.addr}
    ...    user=${vdu_ssh_details.username}
    ...    password=${vdu_ssh_details.password}
    tcpdump.Create K8s kubectl tcpdump Collector
    ...    name=bip
    ...    options=-i lo ether proto 0x8951 -U
    ...    kubectl_exec_options=-n ${vdu_namespace} ${pod} -c ${nwmgmt_container}
    ...    executor=${vdu}
    core.Set Suite Alias    bip
    core.setup_collectors    names=bip
    core.start_collectors    names=bip

Stop collecting BIP logs on vDU
    [Arguments]  ${dir_path}  ${delay}
    Sleep  ${delay}
    core.stop_collectors    names=bip
    core.collect_collectors    names=bip  target_dir=${dir_path}
    core.teardown_collectors    names=bip
    Stop mirroring l1up    ${POD}    ${l2rt_container}
