*** Settings ***
Library         String
Library         Collections
Library         taf.gnb.oam.coam.cu  WITH NAME  vcu_admin
Resource        common.robot

Documentation    NOP related keywords
...              Authors:    Tomasz Januszkiewicz
...              Contact:    tomasz.januszkiewicz@nokia.com

*** Variables ***
${sw_artifactory}=             https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${sw_path}=                    /var/home/core/Downloads/

*** Keywords ***
Upgrade Incompatible NOP
    [Documentation]    Description:    The keyword performs all required steps for the NOP install/upgrade to the default
    ...                                NOP version based on the WFT information for the planned vCU/vDU software.
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]  ${hw_sw_build}    ${nop_ns}    ${ccr_nop_cli}
    add_additional_data_to_nertc_for_wft
    Get Default NOP Version From WFT    ${hw_sw_build}    ${nop_ns}
    Get installed NOP Version    ${nop_ns}     ${ssh_conn}
    Run keyword if    '${deployed_nop_version}'!='[]'    Compare NOP version release
    Run keyword if    '${nop_version}'=='${deployed_nop_version}'    Run Keywords
    ...    Log to console    NOP installed version is the same as NOP default sw for ${hw} planned sw
    ...    AND    Return from Keyword
    ${nops_type}    Set Variable    ('${nop_ns}'=='koredump-operator' or '${nop_ns}'=='nokia-sync-operator')
    ${nops_type_version}    Set Variable    '${nop_version}'!='${deployed_nop_version}'
    Run keyword if    '${deployed_nop_version}'!='[]' and ${nops_type_version} and ${nops_type}    Run keywords
    ...    Log to console    NOP installed version is different than default value. Installation started
    ...    AND    Helm Uninstall NOP    ${nop_ns}    ${ssh_conn}
    Run keyword if    '${deployed_nop_version}'!='[]' and '${nop_version}'!='${deployed_nop_version}'    Run keywords
    ...    sleep  20s
    ...    AND    Prepare SW Package_NOP_default
           ...    ${nop_version}-amd64.zip
           ...    ${ccr_nop_cli}
           ...    ${nop_ns}
    ...    AND    Helm Install NOP
           ...  ccr-${ccr_nop_cli}-vrf-${hw_conv_nop}-01.wroclaw.nsn-rdnet.net:443/${hw_conv_nop}/
           ...  /var/home/core/${nop_version}/HelmChart/
           ...  ${nop_ns}
           ...  ${nop_version}
           ...  ${ssh_conn}
    ...    AND    sleep    10s
    ...    AND    Wait Until Keyword Succeeds    300s    5s    Check NOP status after installation
           ...  ${nop_ns}
           ...  ${ssh_conn}
    Run keyword if    '${nop_version}'!='${deployed_nop_version}' and '${deployed_nop_version}'=='[]'    Run Keywords
    ...    Log to console    ${nop_ns} not installed. ${nop_ns} installation started
    ...    AND    Prepare NOP Namespace    ${nop_ns}    ${ssh_conn}
    ...    AND    Prepare SW Package_NOP_default
           ...    ${nop_version}-amd64.zip
           ...    ${ccr_nop_cli}
           ...    ${nop_ns}
           ...    ${True}
    ...    AND    Helm Install NOP
           ...  ccr-${ccr_nop_cli}-vrf-${hw_conv_nop}-01.wroclaw.nsn-rdnet.net:443/${hw_conv_nop}/
           ...  /var/home/core/${nop_version}/HelmChart/
           ...  ${nop_ns}
           ...  ${nop_version}
           ...  ${ssh_conn}
    ...    AND    sleep    10s
    ...    AND    Wait Until Keyword Succeeds    300s    5s    Check NOP status after installation
           ...  ${nop_ns}
           ...  ${ssh_conn}
#    Helm Uninstall NOP    ${nop_ns}    ${ssh_conn}

Get Default NOP Version From WFT
    [Documentation]    Description:    Keyword verifies default version of NOP for upgraded vDU or vCU sw build
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]  ${hw_sw_build}  ${nop_namespace}
    ${wft_api_link_vcu}=    Set Variable          "https://wft.int.net.nokia.com:8091/api/v1/CRAN/CI_CRAN/builds/${hw_sw_build}/attributes.json"
    ${attributes}=          Set Variable          curl -s --netrc-file /home/ute/.netrc ${wft_api_link_vcu}
    ${output}=              Run Process           bash    -c    ${attributes}    stdout=PIPE    stderr=PIPE
    ${json_text}=           Convert To String     ${output.stdout}
    ${nop_full_match}=      Get Regexp Matches    ${json_text}    \\\\"${nop_namespace}_default\\\\": \\\\"${nop_namespace}_[^\\"]+\\\\"
    Should Not Be Empty     ${nop_full_match}     Cannot Find ${nop_namespace}_default
    ${nop_line}=            Set Variable          ${nop_full_match[0]}
    ${nop_value_match}=     Get Regexp Matches    ${nop_line}    ${nop_namespace}_\\d+(?:\\.\\d+)+(?:-[\\w\\d]+)?
    Should Not Be Empty     ${nop_value_match}    Cannot Find ${nop_namespace}
    ${nop_version}=         Set Variable          ${nop_value_match[0]}
    Set Test Variable    ${nop_version}
    Log to console   ${nop_namespace} default version: ${nop_version}
    [Return]    ${nop_version}

Get installed NOP Version
    [Documentation]    Description:    Get active NOP software version
    ...                Output:         Koredump version i.e. : koredump-operator_1.14.6
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${nop_namespace}    ${ssh_connection}
    ${data}    ssh.Execute    helm list -n ${nop_namespace}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ${nop_installed_version}   Get Regexp Matches    ${data}    (.*)(${nop_namespace}-\\d+\\S*)    2
    Run keyword if    not ${nop_installed_version}    Run keywords
    ...    Set Test Variable    ${deployed_nop_version}    ${nop_installed_version}
    ...    AND    Log to console    ${nop_namespace} is not installed
    ...    AND     Return From Keyword
    ${nop_installed_version_a}    Set Variable    ${nop_installed_version[0]}
    ${nop_installed_version_}=  Replace String    ${nop_installed_version_a}    operator-    operator_
    ${rannic_installed_version_}=  Replace String    ${nop_installed_version_a}    controller-    controller_
    Run keyword if    '${nop_namespace}'=='koredump-operator' or '${nop_namespace}'=='nokia-sync-operator'
    ...    Set Test Variable    ${deployed_nop_version}    ${nop_installed_version_}
     Run keyword if    '${nop_namespace}'=='ran-nic-sw-controller'
    ...    Set Test Variable    ${deployed_nop_version}    ${rannic_installed_version_}
    Log to console   ${nop_namespace} installed version: ${deployed_nop_version}
    [Return]    ${deployed_nop_version}

Compare NOP version release
    [Documentation]    Description:    Keyword compares installed NOP version release with default NOP version release
    ...                                from WFT for planned vCU/vDU sw build
    ...                Output:         Installed NOP release sw version is the same as default NOP release sw for planned vDU upgrade
    ...                Author:         tomasz.januszkiewicz@nokia.com
    ${suffix}=    Get Regexp Matches    ${deployed_nop_version}    _[0-9.]+-(.+)
    ${suffix1}    Run Keyword If    ${suffix}    Set Variable    ${suffix[0]}    ELSE    Set Variable    ${EMPTY}
    ${installed_nop_branch}    Set Variable    ${suffix1}
    ${suffix_default}=    Get Regexp Matches    ${nop_version}    _[0-9.]+-(.+)
    ${suffix_default1}    Run Keyword If    ${suffix_default}    Set Variable    ${suffix_default[0]}    ELSE    Set Variable    ${EMPTY}
    ${default_nop_branch}    Set Variable    ${suffix_default1}
    Run keyword if    '${installed_nop_branch}'=='${default_nop_branch}'
    ...    log to console    Installed NOP release sw version is the same as default NOP release sw for planned ${hw} upgrade
    ${nop_newer_version}=    Compare NOP sw version    ${deployed_nop_version}    ${nop_version}
    Set Test Variable    ${nop_newer_version}
    Run keyword if    '${installed_nop_branch}'=='${default_nop_branch}'
    ...    Log to console    Newer version of NOP: ${nop_newer_version}

Compare NOP sw version
    [Documentation]    Description:    The keyword compares the installed NOP version with the default NOP version
    ...                                and provides information about which one is newer
    ...                Output:         Newer version of NOP: ran-nic-sw-controller_3.18.2
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${v1}    ${v2}
    ${v1_clean}=    Split String    ${v1}    _
    ${v2_clean}=    Split String    ${nop_version}    _
    ${v1_num}=      Set Variable    ${v1_clean[-1]}
    ${v2_num}=      Set Variable    ${v2_clean[-1]}
    ${v1_parts}=    Split String    ${v1_num}    .
    ${v2_parts}=    Split String    ${v2_num}    .
    ${v1_major}=    Convert To Integer    ${v1_parts[0]}
    ${v1_minor}=    Convert To Integer    ${v1_parts[1]}
    ${v1_patch}=    Convert To Integer    ${v1_parts[2]}
    ${v2_major}=    Convert To Integer    ${v2_parts[0]}
    ${v2_minor}=    Convert To Integer    ${v2_parts[1]}
    ${v2_patch}=    Convert To Integer    ${v2_parts[2]}
    Run Keyword If    ${v1_major} > ${v2_major}    Return From Keyword    ${v1}
    Run Keyword If    ${v1_major} < ${v2_major}    Return From Keyword    ${v2}
    Run Keyword If    ${v1_minor} > ${v2_minor}    Return From Keyword    ${v1}
    Run Keyword If    ${v1_minor} < ${v2_minor}    Return From Keyword    ${v2}
    Run Keyword If    ${v1_patch} > ${v2_patch}    Return From Keyword    ${v1}
    Run Keyword If    ${v1_patch} < ${v2_patch}    Return From Keyword    ${v2}
    # When all values are equal:
    Return From Keyword    versions are equal

Prepare NOP Namespace
    [Documentation]    Description:    Keyword prepares namespace for planned NOP installation
    ...                Output:         'koredump-operator' namespace has been created
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${nop_namespace}    ${ssh_connection}
    Log    Creating 'NOP' namespace ...    console=True
    ${output}             ssh.Execute    kubectl get namespace ${nop_namespace}    connection=${ssh_connection}
    ${nemespace_exist}    Evaluate       'Error' not in '''${output}'''
    Run Keyword If        ${nemespace_exist}    Run Keywords
    ...    ssh.Execute              kubectl delete namespace ${nop_namespace}    connection=${ssh_connection}  AND
    ...    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ssh.Execute    oc new-project ${nop_namespace}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    Log    '${nop_namespace}' namespace has been created.    console=True

Download NOP SW From Artifactory
    [Documentation]    Description:    Keyword download sw for planned NOP installation
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${sw_package}    ${nop_namespace}    ${ssh_connection}
    ${artifactory_link}    Set Variable    https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/${nop_namespace}/
    ssh.Execute    curl -O ${artifactory_link}${sw_package}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

Prepare SW Package_NOP_default
    [Documentation]    Description:    Keyword prepares sw package with ccr certs and images pushing to ccr
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${sw_package}    ${ccr}    ${nop_namespace}    ${create_registry_secret}=${False}
    Download NOP SW From Artifactory    ${sw_package}    ${nop_namespace}    ${ssh_conn}
    ${path_to_sw_package}=    Unpack NOP SW Package    ${sw_package}    ${ssh_conn}
    Create CCR Certs On Core    ${ssh_conn}
    ${hw_conv_nop}=  Convert To Lower Case  ${hw}
    Set Test Variable    ${hw_conv_nop}
    ${ccr_url}=      Set Variable    https://ccr-${ccr}-vrf-${hw_conv_nop}-01.wroclaw.nsn-rdnet.net:443/${hw_conv_nop}/
    ${certs_dir}=    Set Variable    /var/home/core/vrfrepos/
    Login To CCR    ccr_url=${ccr_url}    certs_dir=${certs_dir}    ccr_location=${ccr}
    ...             hw_type=${hw}           ssh_connection=${ssh_conn}
    Run Keyword If    ${create_registry_secret}
    ...               Create Docker Registry Secret NOP    ${ccr}    ${ccr_url}    ${nop_namespace}    ${ssh_conn}
    Push NOP Images To CCR    ${ccr}    ${ccr_url}    ${path_to_sw_package}    ${nop_namespace}    ${ssh_conn}

Create Docker Registry Secret NOP
    [Documentation]    Description:    Keyword prepares docker registry secret for NOP sw package
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]     ${ccr}    ${ccr_url}    ${nop_namespace}    ${ssh_connection}
    ${username}     Set Variable    robot\\$vrf
    &{passwords_vdu}    Create Dictionary
    ...    wl=m7SRFboceS9eRedcLu1yGvAoMq2YKX5o
    ...    wg=zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9
    &{passwords_vcu}    Create Dictionary
    ...    wl=biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR
    ...    wg=swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R
    ${command_1}       Set Variable       kubectl create secret docker-registry nokia-cnf-ccr-creds --docker-server=${ccr_url}
    ${command_2}       Set Variable       --docker-username=${username} --docker-password=${passwords_vdu}[${ccr}] -n ${nop_namespace}
    ${command_3}       Set Variable       --docker-username=${username} --docker-password=${passwords_vcu}[${ccr}] -n ${nop_namespace}
    ${full_command_vdu}    Set Variable       ${command_1} ${command_2}
    ${full_command_vcu}    Set Variable       ${command_1} ${command_3}
    Run keyword if    '${hw}'=='vDU'
    ...    ssh.Execute        ${full_command_vdu}    connection=${ssh_connection}
    Run keyword if    '${hw}'=='vCU'
    ...    ssh.Execute        ${full_command_vcu}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}


Unpack NOP SW Package
    [Documentation]    Description:    Keyword unpacks NOP sw package
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${sw_package}    ${ssh_connection}
    Check if unzip and wget installed    ${ssh_connection}
    ${sw_version}    Replace String    ${sw_package}    -amd64.zip    ${Empty}
    ssh.Execute    rm -rf ${sw_version} && mkdir ${sw_version}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ssh.Execute    unzip -d ${sw_version}/ ${sw_package}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ssh.Execute    rm ${sw_package}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ssh.Execute    cd ${sw_version} && unzip ${sw_package} && rm ${sw_package}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    [Return]     /var/home/core/${sw_version}

Push NOP Images To CCR
    [Documentation]    Description:    Keyword pushes NOP images to ccr
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${ccr}    ${ccr_url}    ${path_to_package}    ${nop_namespace}    ${ssh_connection}
    &{passwords_vdu}    Create Dictionary
    ...    wl=m7SRFboceS9eRedcLu1yGvAoMq2YKX5o
    ...    wg=zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9
    &{passwords_vcu}    Create Dictionary
    ...    wl=biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR
    ...    wg=swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R
    ${ccr_address}    Replace String    ${ccr_url}    https://    ${Empty}
    ${command_1}    Set Variable    cd ${path_to_package} && for image_tar_file in `ls ./Image`; do echo $image_tar_file;
    ${command_2}    Set Variable    load_output=$(podman load -i ./Image/$image_tar_file); old_tag=\${load_output##* };
    ${command_3}    Set Variable    new_tag=${ccr_address}${nop_namespace}/\${old_tag##*/}; podman tag \${old_tag} \${new_tag};
    ${command_4}    Set Variable    podman push --creds robot$vrf:${passwords_vdu}[${ccr}] \${new_tag}; podman rmi $old_tag; done
    ${command_5}    Set Variable    podman push --creds robot$vrf:${passwords_vcu}[${ccr}] \${new_tag}; podman rmi $old_tag; done
    ${full_command_vdu}    Set Variable    ${command_1} ${command_2} ${command_3} ${command_4}
    ${full_command_vcu}    Set Variable    ${command_1} ${command_2} ${command_3} ${command_5}
    Run keyword if    '${hw}'=='vDU'
    ...    ssh.Execute        ${full_command_vdu}    connection=${ssh_connection}
    Run keyword if    '${hw}'=='vCU'
    ...    ssh.Execute        ${full_command_vcu}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}


Helm Install NOP
    [Documentation]    Description:    Keyword installs NOP
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${ccr_url}    ${path_to_package}    ${nop_namespace}    ${sw_version}    ${ssh_connection}
    ${package}    Replace String    ${sw_version}    _    -
    ${ccr_address}    Replace String    ${ccr_url}    https://    ${Empty}
    ${command_1}     Set Variable    helm install ${nop_namespace} -n ${nop_namespace}
    ${command_1a}     Set Variable    helm upgrade ${nop_namespace} -n ${nop_namespace}
    ${command_2}     Set Variable    --set global.image.registry=${ccr_address}${nop_namespace} ${path_to_package}${package}.tgz
    ${command_3}     Set Variable    --set image.registry=${ccr_address}${nop_namespace} ${path_to_package}${package}.tgz
    ${full_command}  Set Variable    ${command_1} ${command_2}
    ${full_command_rannic}  Set Variable    ${command_1} ${command_3}
    ${full_command_rannic_upgrade}  Set Variable    ${command_1a} ${command_3}
    Run Keyword If    '${nop_namespace}'=='koredump-operator' or '${nop_namespace}'=='nokia-sync-operator'    Run Keywords
    ...    ssh.Execute    ${full_command}    connection=${ssh_connection}
    ...    AND    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ...    AND    ssh.Execute    rm -rf ${sw_version}    connection=${ssh_connection}
    ...    AND    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ...    AND    Return From Keyword
    Run Keyword If    '${nop_namespace}'=='ran-nic-sw-controller' and '${deployed_nop_version}'=='[]'    Run Keywords
    ...    ssh.Execute    ${full_command_rannic}    connection=${ssh_connection}
    ...    AND    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ...    AND    Log to console    ${nop_namespace} is not installed. Installation started
    ...    AND    ssh.Execute    rm -rf ${sw_version}    connection=${ssh_connection}
    ...    AND    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ...    AND    Return from keyword
    ${rannic_type}    Set Variable    '${nop_namespace}'=='ran-nic-sw-controller'
    ${rannic_type_version}    Set Variable    '${nop_newer_version}'!='${nop_version}'
    Run Keyword If    ${rannic_type} and '${deployed_nop_version}'!='[]' and ${rannic_type_version}    Run Keywords
    ...    Helm Uninstall NOP    ${nop_namespace}    ${ssh_connection}
    ...    AND    ssh.Execute    ${full_command_rannic}    connection=${ssh_connection}
    ...    AND    Log to console    ${nop_namespace} installed version is different than default value. Installation started
    ...    ELSE IF    ${rannic_type} and '${deployed_nop_version}'!='[]' and '${nop_newer_version}'=='${nop_version}'    Run Keywords
    ...    ssh.Execute    ${full_command_rannic_upgrade}    connection=${ssh_connection}
    ...    AND    Log to console    ${nop_namespace} installed version is different than default value. Upgrade started
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ssh.Execute    rm -rf ${sw_version}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

Helm Uninstall NOP
    [Documentation]    Description:    Keyword Uninstalls NOP
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]  ${nop_namespace}    ${ssh_connection}
    ssh.Execute    helm uninstall ${nop_namespace} -n ${nop_namespace}   connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ${nop_deletion_status}    ssh.Execute    helm list -n ${nop_namespace}    connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ${nop_chart_lines}=    Split To Lines    ${nop_deletion_status}
    ${count_chart_lines}=    Get Length    ${nop_chart_lines}
    Wait Until Keyword Succeeds    120s    5s    Should Be Equal As Integers    ${count_chart_lines}    1
    Log  The ${nop_namespace} was uninstalled successfully.  console=True

Check NOP status after installation
    [Documentation]    Description:    Keyword checks NOP pods and deployment status after nop sw installation
    ...                Author:         tomasz.januszkiewicz@nokia.com
    [Arguments]    ${nop_namespace}    ${ssh_connection}
    ${nop_chart_state}    ssh.Execute    helm list -n ${nop_namespace}    connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    Log to console   Checking if ${nop_namespace} is deployed
    ${nop_deployment_status}    Run Keyword And Return Status    Should Contain    ${nop_chart_state}    deployed
    Run Keyword if    ${nop_deployment_status}    Log to console   ${nop_namespace} is deployed
    ${pods_output}    ssh.Execute    oc get pods -n ${nop_namespace}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    ${lines}=    Split To Lines    ${pods_output}
    FOR    ${line}    IN    @{lines[1:]}
        Run Keyword If    '${line}' == ''    Continue For Loop
        ${columns}=    Split String    ${line}
        ${pod_name}=    Set Variable    ${columns[0]}
        ${ready}=       Set Variable    ${columns[1]}
        ${status}=    Set Variable    ${columns[2]}
        Log to console   Checking pod: ${pod_name} | STATUS=${status}
        Should Be Equal    ${status}    Running    msg=Pod ${pod_name} has wrong status: ${status}
    END
