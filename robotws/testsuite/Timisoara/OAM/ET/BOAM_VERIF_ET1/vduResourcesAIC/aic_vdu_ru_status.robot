*** Settings ***
Documentation
...     26.05.2025 -- RF5.0 issues

Resource          aic_vdu_collect_log.robot
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.hw.fhgw.cli                       WITH NAME    issh

*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_OAM_PODS_NAME}      po-${CLUSTER_NAME}-oam-0
${G_OAMFH_PODS_NAME}    po-${CLUSTER_NAME}-oamfh-0
${G_USER}               core

*** Keywords ***
Check RU upgrade successfully
    [Documentation]  Check RU upgrade successfully
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check RU upgrade successfully |
    ${command}=  catenate  SEPARATOR=  kubectl exec -it ${G_OAM_PODS_NAME} -c ctr-${CLUSTER_NAME}-oamfh -n ${CLUSTER_NAME} -- cat /mnt/services/
    ...     SS_OAMDU/OAMFH/working_dir/fileHost/RegisteredRU.json
    ${IsUpgrade}    tafssh.Execute   ${command}
    Should Contain    ${IsUpgrade}    "ruUpgradeStatus" : "successful"

#Check RMOD Status
#    [Documentation]  Check RMOD Status
#    ...  author: yingguo.ying@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    None
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...   | Check RMOD Status |
#    Collect Container Logs    ${G_OAM_PODS_NAME}   ctr-${CLUSTER_NAME}-oamfh
#    ${status} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'operationalState: 1 - Enabled'
#    Should Contain    ${status}    RMOD_L-1 | operationalState: 1 - Enabled

Connect to Radio Unit
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0     ${alias}=default   ${ru_index}=1   ${timeout}=150
    [Documentation]    Connect to Radio Unit/connect to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   9.6.2021,chris.l.cao@nokia-sbell.com, change 'Connect to FHGW' to 'Connect to FHGW Gracefully'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | alias            | No | alias name, default value is default |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    | Connect to Radio Unit |
    ...    | ${out} | issh.Execute | command=hostname |
    ...    | ${out} | issh.Execute | command=hostname | alias=default |
    ...    | ${out} | issh.Execute | command=hostname | alias=default | ru_index=1 |
    ...    | ${out} | issh.Execute | command=hostname | alias=default | ru_index=1 | check_result=${False} |
    ...    | Disconnect Interactive Connection |
    ...
    Connect to FHGW Gracefully  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}  timeout=${timeout}
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
    ${ip}   Get Radio Unit Ip Address  ru_index=${ru_index}
    issh.Set Prompt      \\[root@controller\\(FHGW.*\\).*\\]|root@nahka-Node\\d+:\\S*\#   alias=${alias}
    ${opt}  set variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${out}   issh.Execute    command=docker exec -it ${container_id} ssh ${opt} root@${ip}    check_result=${False}   alias=${alias}
    sleep  1
    ${out}   issh.Execute    command=hostname     alias=${alias}
    ${hostname}   strip prompt  ${out}
    should be true   "${hostname}"=="nahka"

    [Return]  ${alias}

Check RF Power for VDU
    [Arguments]  ${ru_index}=1  ${type}=AHCA
    [Documentation]  Check RF Power for VDU
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check RF Power for VDU |
    Connect to Radio Unit    alias=default  ru_index=${ru_index}
    ${output0}   run keyword if  """${type}"""=="""AHCA"""    issh.Execute    command=/usr/bin/dapd -pwr 0    alias=default
    ...     ELSE    issh.Execute    command=/usr/bin/dapd -pwr 2    alias=default
    ${output1}   run keyword if  """${type}"""=="""AHCA"""    issh.Execute    command=/usr/bin/dapd -pwr 1    alias=default
    ...     ELSE    issh.Execute    command=/usr/bin/dapd -pwr 3    alias=default
    log to console      \n${output0}
    log to console      \n${output1}
    should not contain    ${output0}    =0.0
    should not contain    ${output0}    -inf
    should not contain    ${output1}    =0.0
    should not contain    ${output1}    -inf
    [Teardown]    issh.Disconnect

Check RF Power By Kuafu
    [Arguments]     ${kuafu_dir}
    log to console     \n ***----Starting check rf power by kuafu...
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   51-check-ru-tx-power.sh
    ${return}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./51-check-ru-tx-power.sh
    log to console  ${return}
    should not contain  ${return}   =0.0
    should not contain  ${return}   -inf
    should not contain  ${return}   status = Fail
    should contain  ${return}   TX=
    should not contain  ${return}   Aborted
    should not contain  ${return}   exception

Check TDD RMOD Status
    [Documentation]  Check RMOD Status
    ...  author: lingjiao.feng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check TDD RMOD Status |
    Collect Container Logs    ${G_OAM_PODS_NAME}   ctr-${CLUSTER_NAME}-oamfh
    ${status} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'operationalState'
    Should Contain    ${status}    - - -      "operationalState" : "enabled"

Ecpri_ru_power_check
    [Documentation]    Ecpri_ru_power_check
    ...    *AUTHOR* yingguo.ying@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.07.2021,yingguo.ying@nokia-sbell.com, create
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...    Example
    ...    | Ecpri_ru_power_check |
    Collect Container Logs    ${G_OAMFH_PODS_NAME}   ctr-${CLUSTER_NAME}-oamfh
    ${command}=  catenate  SEPARATOR=   kubectl exec -n ${CLUSTER_NAME} ${G_OAMFH_PODS_NAME} -c ctr-${CLUSTER_NAME}-oamfh -- bash
    ...     -c "{ echo \\"aasyscomgw -r\\";sleep 1;echo \\"quit\\"; } | telnet 0 15067;" 2>&1 | grep -a "192." | awk \'{print $7}\'
    ${ru_ip_list} =    tafssh.execute   ${command}
    #@{ru_ip_list}=    Split To Lines    ${ru_ip_list}
    log to console    ${ru_ip_list}

    tafssh.Execute    command=sudo ip link add link ens1f1 name rutest.295 type vlan id 295
    tafssh.Execute    command=sudo ip addr add 192.168.254.60/26 dev rutest.295
    tafssh.Execute    command=sudo ip link set dev rutest.295 up

    ${serviceuser_psw}=    set variable  bdS%ztWG3v7%SjreCVA79wTPb
    ${internal_ru_ip}=    set variable  192.168.101.2

    FOR   ${ru_ip}  IN   @{ru_ip_list}
        ${made}=    set variable
    ...     "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${internal_ru_ip} /usr/bin/dapd_app -pwr 0"
        ${power}=    tafssh.execute
    ...     sshpass -p ${serviceuser_psw} ssh -q -o UserKnownHostsFile\=/dev/null -o StrictHostKeyChecking\=no serviceuser@${ru_ip} ${made}
        log to console    ${power}
        should not contain    ${power}    0.0
        should not contain    ${power}    -inf
    END
    tafssh.Execute    command=sudo ip link del rutest.295 type vlan

Check RMOD Status
    [Arguments]  ${rmod_status}     #${rmod_index}=0
    [Documentation]  Check RU Enabled
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | rmod_status | yes | enabled or disabled |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Check RU Enabled |
    #@{rmod_status}=   vdu.get_rmods_status
    #&{rmod_status}=   set variable    @{rmod_status}[${rmod_index}]
    run keyword if  """${rmod_status}"""=="""enabled"""   should be equal  ${rmod_status.operational_state}    enabled
    run keyword if  """${rmod_status}"""=="""disabled"""   should be equal  ${rmod_status.operational_state}    disabled

Check Specific RF Power By Kuafu
    [Arguments]     ${kuafu_dir}      ${ru_index}
    log to console     \n ***----Starting check rf power by kuafu...
    ${return}   tafssh.Execute  command=cd ${kuafu_dir};. ./10-vdu-l3call-test.sh
    should contain  ${return}   51-check-ru-tx-power.sh
    ${result}   tafssh.Execute  command=cd ${kuafu_dir}/scenarios/vdu_l3call;./51-check-ru-tx-power.sh
    ${index}    Evaluate    ${ru_index}+1
    ${return}    Run   echo "${result}"|tr -d '\r\n'|awk -F "ruproxy" '{print $${index}}'
    log to console  ${return}
    set test variable   ${return}
    should not contain  ${return}   =0.0
    should not contain  ${return}   -inf
    should not contain  ${return}   status = Fail
    should contain  ${return}   TX=
    should not contain  ${return}   Aborted
    should not contain  ${return}   exception
