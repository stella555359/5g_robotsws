*** Settings ***
Force Tags    PY39    RF50

Documentation    This is a test suite for loki driver update
Suite Setup       Common Test Suite setup
Library           taf.ul.vdu.helm    WITH NAME    helm
Library           taf.transport.ssh.interface.ssh    WITH NAME    ssh
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           OperatingSystem
Library           Collections
Library           String
Library           json
Library           ${CURDIR}/../SRAN/resources/python/QTListener.py
Library           ${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Library           ${CURDIR}/../SRAN/resources/python/cloud_keywords.py
Resource          ${CURDIR}/../SRAN/resources/robot/connections.robot
Resource          ${CURDIR}/../SRAN/resources/robot/AIC_common_keywords.robot
Resource          ${CURDIR}/../SRAN/resources/robot/loki_driver.robot
Test Timeout      1 hour

*** Test Cases ***
Undeploy AIC
    [Tags]   loki_driver
    Undeploy AIC
    [Teardown]

Update loki service image
    [Tags]   loki_driver
    Run Keyword If  ${sub_loki_bool}  Run Keywords
    ...  Wait Until Keyword Succeeds    2x    1min  Pull loki host driver image
    ...  AND  Delete the old loki driver and install new one
    ...  AND  Wait Until Keyword Succeeds    5x    2min   Check if loki driver updated
    ...  ELSE  Log To Console   ----> ${\n}New SDK backward compatible with old loki driver,skipped to update loki driver.${\n}
    [Teardown]

*** Keywords ***
Test variables setup
   [Documentation]  Set Suite Variables for vCU
   ...    author: min.zheng
    ${RELEASE}=    Fetch From Left    ${STREAM}    marker=_
    ${par_prefix}   set variable if
    ...   'vDU' in '${STREAM}'    DU
    ...   'VDU' in '${STREAM}'    DU
    ...    'CU' in '${STREAM}'    CU
    ${pre_flag}    set variable if
    ...   'vDU' in '${STREAM}'    vdu
    ...   'VDU' in '${STREAM}'    vdu
    ...    'CU' in '${STREAM}'    vcu
    ${vCU_build_flag}    set variable if    'CU' in '${STREAM}'    True    False
    ${vDU_build_flag}    set variable if
    ...   'vDU' in '${STREAM}'    True
    ...   'VDU' in '${STREAM}'    True
    ...   False
    Set Suite Variable    ${par_prefix}
    Set Suite Variable    ${vCU_build_flag}
    Set Suite Variable    ${vDU_build_flag}
    Set Suite Variable    ${pre_flag}

Common Test Suite setup
    [Documentation]  common setup for loki driver update
    Common variables setup
    Test variables setup
    Get controller host name  ${${par_prefix}_k8s_addr}  ${${par_prefix}_k8s_user}  ${${par_prefix}_k8s_pwd}
    wait until keyword succeeds    5min   30s    OE Authentication  par_prefix=${par_prefix}
    wait until keyword succeeds    3x   1min    Get sub loki version
    ${sub_loki_bool}=  Run Keyword And Return Status  List Should Contain Value
      ...  ${loki_sub_ver_list}  ${loki_driver_sub_ver}
    Set Suite Variable  ${sub_loki_bool}
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Get sub loki version
    [Documentation]  This keyword is used to get sub loki version list from web and also get loki version included
     ...  in SDK version from oe
    ##### start to get loki version list from web #####
    @{output}   Split String From Right     ${LOKI_DRIVER_PATH}      separator=/    max_split=1
    ${loki_download_link}=   Catenate   SEPARATOR=/   https://artifactory-espoo2.int.net.nokia.com/artifactory/ocp-team-local/nic-drivers/loki
    ...   ${output[1]}${/}
    ${res}=  RUN  command=curl --user "ca_ucim:welcome123" ${loki_download_link}
    ${loki_sub_ver_list}=  filter_href_cont  ${res}
    set suite variable    ${loki_sub_ver_list}
    ##### start to get loki version which need to be download from oe #####
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${connection} =    ssh.get connection by alias    alias=RM_alias
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    oc debug node/${CONTROLLER_HOSTNAME}\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Call Method    ${channel}    send    chroot /host\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Call Method    ${channel}    send    uname -r\n
    BuiltIn.Sleep   3s
    ${response}    Call Method    ${channel}    recv    ${65535}
    ${output_str}=  Decode Bytes To String  ${response}  UTF-8
    ${loki_driver_sub_ver}   Split String From Right    ${output_str}   \r\n  2
    ${loki_driver_sub_ver}   strip string   ${loki_driver_sub_ver}[1]
    Set Suite Variable   ${loki_driver_sub_ver}
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

pull loki host driver image
    [Documentation]  this kw is used to pull the loki driver image with specific tag
    @{output}   Split String From Right     ${loki_driver_path}      separator=/    max_split=1
    @{output1}=   Split String    ${output[1]}     -    1
    set suite variable   ${loki_ver}   ${output[1]}
    set suite variable   ${match_loki_driver_ver}   ${output1[1]}
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    ${connection} =    ssh.get connection by alias    alias=RM_alias
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    oc debug node/${CONTROLLER_HOSTNAME}\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Call Method    ${channel}    send    chroot /host\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  sh-
    Log To Console   \n----> Start to pull loki driver pkg: ${loki_driver_path}${:}${loki_driver_sub_ver}
    Call Method    ${channel}    send    podman pull --creds ca_ucim:welcome123 ${loki_driver_path}${:}${loki_driver_sub_ver}\n
    Wait Until Keyword Succeeds  5min   20s  Output pattern matches  ${channel}  Storing signatures
    Call Method    ${channel}    send    podman image ls |grep -i loki\n
    Wait Until Keyword Succeeds  10x   5s  Output pattern matches  ${channel}  ${loki_ver}
    Log To Console   ----> loki package pull done
    Call Method    ${channel}    send    exit\n
    BuiltIn.Sleep   2s
    Call Method    ${channel}    send    exit\n
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect   connection=RM_alias

Check if mcp master update
    [Documentation]  After OE restarted need to wait until mcp master updated
    [Arguments]  ${timeout}=20
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}   password=${DU_k8s_pwd}  alias=RM_alias
    FOR   ${item}   IN RANGE   0    ${timeout}+1
        ${mcp_update}=   ssh.execute   command= oc get mcp master|sed -n 2p|awk '{print $3}'   connection=RM_alias   timeout=10s
        ${mcp_update}=   Strip String   ${mcp_update}
        Exit For Loop If    "${mcp_update}"=="True"
    END
    should be true   ${mcp_update}



