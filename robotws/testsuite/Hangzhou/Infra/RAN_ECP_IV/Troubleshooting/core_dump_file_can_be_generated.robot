*** Settings ***
Suite Setup       core dump suite setup
Suite Teardown    core dump suite teardown
Library           String
Library           DateTime
Resource          ../resources/infra_common_resources.robot

*** Test Cases ***
Cloud_General_Logging_CaaS_OCP_container_core_dump_file_can_be_generated
    [Setup]    container core dump setup
    Login_ocp_and_set_corepattern
    ${ret}    sshi.execute    oc new-project koredump    check_result=False
    ${result}=    Run Keyword And Return Status    Should Contain    ${ret}    already exists
    Run Keyword If    ${result}==False    install_koredump
    ${node}    Enter_debug_mode
    Generate_core_dump_and_exist_debug_mode
    Enter_app_node    ${node}
    Check_core_dump_is_generated
    [Teardown]    container core dump teardown

Cloud_General_Logging_CaaS_OCP_core_dump_file_can_be_generated
    [Documentation]    DESCRIPTION: Check if OCP core dump is OK
    ...
    ...    TEST EXECUTION:
    ...    1. check kdump serivce status and configuration
    ...    2. force core crash by command
    ...    3. wait for OCP host restarted and ready
    ...    4. check if core dump file is generated
    ...
    ...    EXPECTED RESULTS:
    ...    1. kdump service is active and the path of configuration is /var/crash
    ...    2. force OCP core crash, it will restart immediately
    ...    3. OCP will be ready and ssh connection is ok
    ...    4. New core dump file will be generated in /var/crash
    [Setup]    node core dump setup
    Check Kdump Service And Configuration
    Force Kernel Crash
    Wait OCP Restart And Ready
    Check Created Dump File
    [Teardown]    node core dump teardown

*** Keywords ***
core dump suite setup
    common_suite_setup_for_infra
    local_cmd.execute_local_cmd    ssh-keygen -f ~/.ssh/known_hosts -R ${VCU_OCP_SSH_ACCESS}[ip]

core dump suite teardown
    common_suite_teardown_for_infra

container core dump setup
    common_suite_setup_for_infra
    Set Suite Variable    ${TEMP_CORE_DUMP_FILE}    /tmp/tmpfile_coredump
    Set Suite Variable    ${HTTP_PROXY}    "http://10.158.100.1:8080"
    Set Suite Variable    ${HTTPS_PROXY}    "http://10.158.100.1:8080"
    ${no_proxy1}=    Set Variable    localhost,127.0.0.1,*.local,nsn-net.net,inside.nokiasiemensnetworks.com,access.nokiasiemensnetworks.com
    ${no_proxy2}=    Set Variable    nsn-intra.net,nsn-rdnet.net,halebopp.eecloud.dynamic.nsn-net.net,artifactory-espoo1.ext.net.nokia.com
    ${no_proxy3}=    Set Variable    artifactory-espoo1.int.net.nokia.com,nesc.nokia.net,microsoftonline.com,onmicrosoft.com,*.svc
    ${no_proxy}=    Catenate    SEPARATOR=,    ${no_proxy1}    ${no_proxy2}    ${no_proxy3}
    Set Suite Variable    ${NO_PROXY}    ${no_proxy}
    log    ${no_proxy}

container core dump teardown
    common_test_teardown_for_infra

node core dump setup
    common_test_setup_for_infra
    SSH.Open_Connection    ${VCU_OCP_SSH_ACCESS}[ip]    alias=conn1
    SSH.Login    ${VCU_OCP_SSH_ACCESS}[username]    ${VCU_OCP_SSH_ACCESS}[password]

node core dump teardown
    common_test_teardown_for_infra
    SSH.Close_All_Connections

Check Kdump Service And Configuration
    ${output}    SSH.Execute_Command    systemctl is-active kdump
    Should Contain    ${output}    active    kdump service is not actived
    ${output}    SSH.Execute_Command    cat /etc/kdump.conf | grep path
    Should Contain    ${output}    /var/crash    kdump configuration error
    ${output}    SSH.Execute_Command    ls /var/crash

Force Kernel Crash
    SSH.Write    sudo -i
    ${output}    SSH.Read Until    expected=#
    SSH.Write    rm -rf /var/crash/*
    ${output}    SSH.Read Until    expected=#
    SSH.Write    sync
    ${output}    SSH.Read Until    expected=#
    SSH.Write    echo 1 > /proc/sys/kernel/sysrq
    ${output}    SSH.Read Until    expected=#
    SSH.Write    echo c > /proc/sysrq-trigger
    SSH.Close_All_Connections

Wait OCP Restart And Ready
    local_cmd.wait_until_restarted    ${VCU_OCP_SSH_ACCESS}[ip]    15
    local_cmd.wait_until_pingable    ${VCU_OCP_SSH_ACCESS}[ip]    420
    sleep    10s
    local_cmd.wait_until_ssh_enable    ${VCU_OCP_SSH_ACCESS}[ip]    ${VCU_OCP_SSH_ACCESS}[username]    ${VCU_OCP_SSH_ACCESS}[password]    300

Check Created Dump File
    SSH.Open_Connection    ${VCU_OCP_SSH_ACCESS}[ip]    alias=conn2
    SSH.Login    ${VCU_OCP_SSH_ACCESS}[username]    ${VCU_OCP_SSH_ACCESS}[password]
    ${output}    SSH.Execute_Command    ls /var/crash
    ${count}    Get Line Count    ${output}
    Should Be True    ${count}==1    coredump folder number error
    Should Contain    ${output}    127.0.0.1    coredump folder name error
    ${output}    SSH.Execute_Command    ls -l /var/crash/${output} | grep vmcore | grep -v dmesg | awk '{print $5}'
    ${result}    Convert To Integer    ${output}
    Should Be True    ${result}>=1048576    vmcore size is error

Login_ocp_and_set_corepattern
    ${conn1}    sshi.connect_to    ${VCU_OCP_SSH_ACCESS}[ip]    ${VCU_OCP_SSH_ACCESS}[username]    ${VCU_OCP_SSH_ACCESS}[password]
    ${alert}    sshi.execute    \n\n    False
    ${first_alert}=    Get Lines Containing String    ${alert}    \(y/n\):
    ${length}=    Get Length    ${first_alert}
    Run Keyword If    ${length}!=0    sshi.execute    y
    sshi.execute    sudo su
    sshi.execute    echo "|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h %e" > /proc/sys/kernel/core_pattern; exit

Enter_debug_mode
    ${out}    sshi.execute    oc get node|sed 1d
    ${node}    Split String    ${out}    ${SPACE}${SPACE}${SPACE}    10
    ${Dnode}=    Catenate    SEPARATOR=    node    /    ${node[0].strip('\n')}
    sshi.execute    oc debug ${Dnode}    check_result=False
    [Return]    ${node}    # result of "oc get node"

Generate_core_dump_and_exist_debug_mode
    sshi.execute    chroot /host sleep 999 & kill -XCPU %1;
    sshi.execute    exit

Enter_app_node
    [Arguments]    ${node}    # result of "oc get node"
    ${debugPod}    Split String    ${node}[0]    .    1
    ${clusterInfo}    sshi.execute    kubectl config current-context
    ${clusterSubinfo1}    Split String    ${clusterInfo}    /
    ${clusterSubinfo2}    Split String    ${clusterSubinfo1}[1]    -
    ${appNode}=    Catenate    SEPARATOR=    https://    ${clusterSubinfo2}[0].    ${debugPod}[1]    :6443
    sshi.execute    oc login -u nokiaadmin -p nokiaadmin ${appNode}    delay=1

Check_core_dump_is_generated
    sshi.execute    echo >${TEMP_CORE_DUMP_FILE}
    sshi.execute    koredumpctl list >${TEMP_CORE_DUMP_FILE}    check_result=False
    ${out}    sshi.execute    cat ${TEMP_CORE_DUMP_FILE}|grep 'Signal: SIGXCPU'    check_result=False
    Should Match Regexp    ${out}    Signal:\\s*SIGXCPU    check_result=False
    sshi.execute    oc delete project koredump    check_result=False

install_koredump
    ${ret}    sshi.execute    oc new-project koredump    check_result=False
    sshi.execute    export https_proxy=${HTTPS_PROXY}
    sshi.execute    export http_proxy=${HTTP_PROXY}
    sshi.execute    export no_proxy=${NO_PROXY}
    sshi.execute    helm repo add koredump https://nokia.github.io/koredump/
    sshi.execute    helm repo update
    ${repo}=    Set Variable    image.repository=rcp-poc-local.esisoj70.emea.nsn-net.net/koredump/koredump
    sshi.execute    helm install -n koredump koredump koredump/koredump --set ${repo}    check_result=False
