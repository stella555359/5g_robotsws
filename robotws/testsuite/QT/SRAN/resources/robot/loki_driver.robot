*** Settings ***
Documentation     File containing keywords used for loki driver testing

Library           OperatingSystem
Library           Collections
Library           Telnet
Library           String
Library           taf.transport.ssh.interface.ssh            WITH NAME    ssh

*** Keywords ***
Pull loki driver image
    [Documentation]  This keyword is used to repull loki driver image when loki driver status is failed.
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${du_hostname}=  ssh.execute  command=hostname   connection=RM_alias  timeout=30s
    ${CONTROLLER_HOSTNAME}=  Strip String  ${du_hostname}
    ${cluster_name}=   ssh.execute  command=oc get nokiaclusters.nokia.com|awk 'NR==2'|awk '{print $1}'   connection=RM_alias  timeout=30s
    ${cluster_name}=   Strip String  ${cluster_name}
    ${ocp_sub_ver}=    ssh.execute
    ...  command=oc describe nokiaclusters.nokia.com ${cluster_name} | grep "Nokia Release"|awk 'NR==1'|awk -F ':' '{print $2}'
    ...  connection=RM_alias  timeout=60s
    ${ocp_sub_ver}=    Strip String  ${ocp_sub_ver}
    ${loki_sub_version}=   ssh.execute  command=uname -r   connection=RM_alias  timeout=30s
    ${loki_sub_version}=   Strip String  ${loki_sub_version}
    ${cmd}=  set variable   kubectl get mc |grep -i loki|awk '{print $1}'
    Log To Console   \n Start to check if image exist with command: ${cmd} \t
    ssh.send_command  command=${cmd}   connection=RM_alias
    ${output}=  ssh.read_output   connection=RM_alias
    ${loki_node}  Strip String  ${output}
    ${output}=  ssh.execute
    ...  command=kubectl get mc loki-driver-load-master -o yaml|grep -E '\\sExecStart='|awk -F'[:|/]' '{print $(NF-1)}'
    ...  connection=RM_alias
    ...  timeout=60s
    ${loki_ver}=  Remove String  ${output}  \r\n
    set suite variable  ${loki_ver}
    @{output_split}=  Split String   ${loki_ver}    -  1
    set suite variable   ${match_loki_driver_ver}   ${output_split[1]}
    ${loki_image_server}=  Strip String  ocp-team-local.artifactory-espoo2.int.net.nokia.com:443/nic-drivers/loki/${loki_ver}
    Set Suite Variable  ${loki_image_server}
    Log To Console   \n Start to pull loki image with command: podman pull --creds ca_ucim:welcome123 ${loki_image_server}:${loki_sub_version} \t
    ${connection} =    ssh.get connection by alias    alias=RM_alias
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    oc debug node/${CONTROLLER_HOSTNAME}\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Call Method    ${channel}    send    chroot /host\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Call Method    ${channel}    send    podman pull --creds ca_ucim:welcome123 ${loki_image_server}:${loki_sub_version}\n
    ${pull_loki_image_bool}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5min   20s  Output pattern matches  ${channel}  Storing signatures
    Run Keyword If  ${pull_loki_image_bool}  Log To Console   ----> ${\n}loki image pull done.${\n}
    ...  ELSE  Fail   ${\n}!!!Warning!!! Loki image pull failed, pls manually check!${\n}

Delete and install loki driver
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=   ssh.execute   command=oc patch mcp master --patch '{"spec":{"paused":true}}' --type=merge
    ...    connection=RM_alias   timeout=20s
    should contain   ${output}    patched
    ${loki_name}=   ssh.execute   command= kubectl get mc |grep -i loki   connection=RM_alias   timeout=20s
    ${loki_name}=   Strip String   ${loki_name}
    ${loki_name}=   ssh.execute   command= oc delete mc ${loki_name}   connection=RM_alias   timeout=60s
    Log To Console   ----> Previous loki driver delete done
    ssh.upload file   remote_path=/var/home/core/loki-driver-load-master-loki.yaml
    ...    local_path=${CURDIR}/../../../SRAN/configs/loki-driver-load-master-loki.yaml
    ...    connection=RM_alias
    BuiltIn.Sleep   2s
    ${output}=   ssh.execute
    ...   command=cat /var/home/core/loki-driver-load-master-loki.yaml|grep ocp-team-local|awk -F '/' '{print $16}'
    ...   connection=RM_alias   timeout=20s
    ${output}=   Strip String  ${output}
    @{template_loki_dir}     Split String From Right     ${output}      separator=:    max_split=1
    ${output}=   ssh.execute
    ...   command=sed -i "s/${template_loki_dir[0]}/${loki_ver}/g" /var/home/core/loki-driver-load-master-loki.yaml
    ...   connection=RM_alias   timeout=20s
    Log To Console   ----> Upload loki yaml file to OE done
    BuiltIn.Sleep   1s
    ${output}=   ssh.execute   command=oc apply -f /var/home/core/loki-driver-load-master-loki.yaml   connection=RM_alias
    should contain   ${output}   created
    BuiltIn.Sleep   3s
    Log To Console   ----> mcp will get into updating state and it will trigger OE host reboot automatically
    ${output}=    ssh.execute   command= oc patch mcp/master --patch '{"spec":{"paused":false}}' --type=merge   connection=RM_alias
    should contain   ${output}   patched
    BuiltIn.Sleep    20s

Delete the old loki driver and install new one
    Delete and install loki driver
    ${res}=   Run Keyword And Return Status   Check if OE is restart
    Run Keyword If  ${res}  wait until keyword succeeds    8min   30s    OE Authentication  par_prefix=DU
    ...  ELSE  Run Keywords
    ...  Log To Console   ----> OE was not automatically restarted , reboot command will be performed!
    ...  AND   ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ...  AND   ssh.send_command   command=sudo systemctl reboot   connection=RM_alias
    ...  AND   BuiltIn.Sleep   3s
    ...  AND   Check if OE is restart
    ...  AND   wait until keyword succeeds    8min   30s    OE Authentication  par_prefix=DU
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check if loki driver is active
    [Documentation]  Sometimes ahm and up pod are always in pending status due to loki-driver-load failed.add this kw to
    ...   recover this service when failed before deployment
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=   ssh.execute   command=systemctl status loki-driver-load.service|grep Active:   connection=RM_alias  timeout=20s
    ${output}=   Strip String  ${output}
    Run Keyword If    'Active: failed' in '${output}'    Run Keywords
    ...   Log To Console   ----> ${\n}!!!Warning!!! Loki driver status is nok and it will be restarted!${\n}   WARN
    ...   AND   Run Keyword And Ignore Error  Pull loki driver image
    ...   AND   ssh.send_command   command=sudo systemctl restart loki-driver-load.service   connection=RM_alias
    ...   AND   BuiltIn.Sleep   5s
    ...   AND   Check loki driver service status
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check if loki driver updated
    Log To Console   ----> Start to check loki-driver status
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${output}=  ssh.execute   command=systemctl status loki-driver-load.service|grep Active:   connection=RM_alias  timeout=20s
    ${res_bool}=  Run Keyword And Return Status  Should Contain   ${output}   Active: active
    Run Keyword If  ${res_bool}  Log To Console   ----> Loki driver update Done
    ...  ELSE  Fail  ${\n}!!!Warning!!! Loki status failed after updating, pls manually check!${\n}
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check loki driver service status
    ${res_bool}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   5min   30s   check loki-service status
    Run Keyword If  ${res_bool}  Log To Console   ----> ${\n}Loki driver restart ok.${\n}
    ...  ELSE  Fail   ${\n}!!!Warning!!! Loki driver restart failed, pls manually check!${\n}

check loki-service status
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ssh.send_command   command=systemctl status loki-driver-load.service|grep Active:   connection=RM_alias  timeout=60s
    ${output}=   ssh.read_output   connection=RM_alias
    Should Contain   ${output}   Active: active

