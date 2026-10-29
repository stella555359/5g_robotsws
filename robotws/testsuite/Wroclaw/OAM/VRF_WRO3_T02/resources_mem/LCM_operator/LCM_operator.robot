*** Settings ***
Documentation    LCM operator keywords.
...              Authors:    Marek Starzyk
...              Contact:    marek.starzyk@nokia.com

Library         String
Library         Collections
Library         ./LCM_operator.py
Library         taf.gnb.oam.coam.cu  WITH NAME  vcu_admin
Resource        ../common.robot
Resource        ../../../cloud_common_resources/alarms/alarms.robot

*** Variables ***
${sw_artifactory}=             https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${sw_path}=                    /var/home/core/Downloads/
${CRAN_VDU}=            ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${CRAN_VCU}=            ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}

*** Keywords ***

#################################################### Main  Keywords ####################################################

Install or Upgrade LCM Operator
    [Documentation]    Description:    Installs the latest or a provided version of the LCM operator.
    ...                                If the operator is already installed with an older version,
    ...                                it will be upgraded to the specified version.
    ...                                If the operator is already installed with the desired version,
    ...                                the installation or upgrade will be skipped.
    ...                Input:          ssh_connection: An object representing the SSH connection to the server
    ...                                where the LCM operator will be installed.
    ...                                This is the output of the 'Connect to ADMIN via SSH' keyword from
    ...                                cloud_common_resources/connections/connections.robot.
    ...                                ccr: Acceptable values are 'wl' or 'wg'.
    ...                                sw_version: Defaults to 'latest'. To install a specific version,
    ...                                provide it in the format: 'cnf-lcm-operator_3.4.0-amd64.zip'.
    ...                Author:         marek.starzyk@nokia.com
    [Arguments]    ${ssh_connection}    ${ccr}    ${sw_version}=latest
    ${lcm_operator_status}    _Check LCM Operator Status    sw_version=${sw_version}    ssh_connection=${ssh_connection}
    Run Keyword If    ${lcm_operator_status}[is_installed] and ${lcm_operator_status}[needs_upgrade]
    ...    _Update LCM Operator To Latest Version    ${lcm_operator_status}    ${ccr}    ${ssh_connection}
    Run Keyword If    ${lcm_operator_status}[is_installed] and not ${lcm_operator_status}[needs_upgrade]
    ...    Log
    ...    The LCM operator is already installed in the latest version, no installation or update is needed.
    ...    console=True
    Run Keyword If    not ${lcm_operator_status}[is_installed]
    ...    _Install LCM Operator    ${lcm_operator_status}    ${ccr}    ${ssh_connection}

Uninstall LCM Operator
    [Documentation]    Description:    Uninstall the LCM operator
    ...                Input:          ssh_connection: An object representing the SSH connection to the server
    ...                                where the LCM operator is installed.
    ...                                This is the output of the 'Connect to ADMIN via SSH' keyword from
    ...                                cloud_common_resources/connections/connections.robot.
    ...                Author:         marek.starzyk@nokia.com
    [Arguments]  ${ssh_connection}
    ssh.Execute    helm uninstall cnf-lcm-operator -n cnf-lcm-operator   connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ssh.Execute              kubectl delete namespace cnf-lcm-operator    connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    Log  The cnf-lcm-operator was uninstalled successfully.  console=True

Upgrade CNF via LCM Operator
    [Documentation]    Description:    Upgrade vCU or vDU via LCM operator
    ...                Input:          ssh_connection: An object representing the SSH connection to the server
    ...                                where the LCM operator will be installed.
    ...                                This is the output of the 'Connect to ADMIN via SSH' keyword from
    ...                                cloud_common_resources/connections/connections.robot.
    ...                                ccr: Acceptable values are 'wl' or 'wg'.
    ...                                CNF_SW: To deploy a specific version for vCU or vDU,
    ...                                provide it in the format: 'vCUCNF25R2_25.250.396'.
    ...                Author:         mateusz.gadek@nokia.com
    [Arguments]    ${CNF_SW}    ${ccr}    ${ssh_connection}    ${hw}
    Get Non Upgraded CNF  ${hw}
    ${non_upgraded_cnf}=   Get Non Upgraded CNF  ${hw}
    Set Test Variable  ${non_upgraded_cnf}
    &{wdog_start_status}    Create Dictionary    ${hw}=${False}    ${non_upgraded_cnf}=${False}
    Set Test Variable    ${WDOG_START_STATUS}    &{wdog_start_status}
    Start Cloud Watchdog   hw_type=${hw}
    ${admin_connection}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
    Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    Sleep    60s
    ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
    Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw} during test execution.
    Set Test Variable    ${hw}
    ${hw_conv}=  Convert To Lower Case  ${hw}
    IF    '${hw}'=='vCU'
    ${SW_VCU}=    Set Variable    ${CNF_SW}
    Set Test Variable    ${SW_VCU}
    END
    IF    '${hw}'=='vDU'
    ${SW_VDU}=    Set Variable    ${CNF_SW}
    Set Test Variable    ${SW_VDU}
    END
    ${rancnf_file}=  Set Variable  /home/ute/testline_configuration/${hostname}/LCM/${hw}/rancnf_${hw}.yaml
    ${du_trunk_scf}=   Set Variable   /home/ute/testline_configuration/${hostname}/vDUCNF00/scf_du.xml
    ${cu_trunk_scf}=   Set Variable   /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    ${registry}=  Set Variable  ccr-${ccr}-vrf-${hw_conv}-01.wroclaw.nsn-rdnet.net:443/${hw_conv}
    ${updates}=    Create Dictionary
    ...    spec.cnfConfig.imageRegistry=${registry}
    ...    spec.cnfConfig.cnfSWBuild=${CNF_SW}-amd64
    _Update RANCNF LCM Operator File    ${rancnf_file}    ${updates}
    _Upload rancnf file to core   ${rancnf_file}  ${ssh_connection}
    ${cnf_name}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.name
    ${cnf_name}=    Set Variable    ${cnf_name}
    ${namespace}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.namespace
    ${namespace}=    Set Variable    ${namespace}
    Log    Downloading and image onboarding package: ${CNF_SW}  console=True
    ${package_path}  Download required software files  SW_PACKAGE=${CNF_SW}    ssh_conn=${ssh_connection}    operation_type=upgrade
    ...    conversion=${False}  onboarding=${False}
    Set Test Variable  ${package_path}
    Unpack required software files  package_path=${package_path}[0]   conversionApp_path=${False}  onboardingApp_path=${False}
    ...                             storage_dir=${storage_dir}[upgrade]  conn=${ssh_connection}
    Images Onboarding  hw_type=${hw_conv}  ccr_location=${ccr}  operation_type=upgrade
    ${image_path}    get_ccr_image_path_list_variable   IMAGE_PATH_LIST
    Set Suite Variable    ${CCR_IMAGE_PATH_LIST}    ${image_path}
    Sleep   10s
    Log     Starting ${hw} upgrade on namespace: ${namespace} with SW: ${CNF_SW}   console=True
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    ssh.Execute    kubectl apply -f rancnf_${hw}.yaml   connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    Wait Until Keyword Succeeds    600s    15s    wait_for_cnf_status   ${ssh_connection}    ${namespace}    ${cnf_name}
    IF  '${hw}'=='vCU'
            ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
            Set Test Variable  ${admin_connection_vcu}
            Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vcu}
            Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
            Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
            Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
            Log to Console  Waiting for 5 minutes to verify whether any unexpected alarms appear
            Sleep  5m
            Check Alarm List On vCU/vDU  ${hw}
            ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
            Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
            Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    END
    IF  '${hw}'=='vDU'
            ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
            Set Test Variable  ${admin_connection_vdu}
            Wait Until Keyword Succeeds  80min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection_vdu}
            Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
            Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
            Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
            Sleep  5m
            Check Alarm List On vCU/vDU  ${hw}
            ${watchdog_alarms}=  Stop Cloud Watchdog And Get Faults  ${hw}
            Run Keyword If  '${watchdog_alarms}'!='[]'  Fail  Unexpected faults were detected on the ${hw_type} during test execution.
            Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    END
    Start Cloud Watchdog  hw_type=${hw}  add_temporary_allowed_faults=${True}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}

CNF Deploy via LCM Operator
    [Documentation]    Description:    Deploy vCU or vDU via LCM operator
    ...                Input:          ssh_connection: An object representing the SSH connection to the server
    ...                                where the LCM operator will be installed.
    ...                                This is the output of the 'Connect to ADMIN via SSH' keyword from
    ...                                cloud_common_resources/connections/connections.robot.
    ...                                ccr: Acceptable values are 'wl' or 'wg'.
    ...                                CNF_SW: To deploy a specific version for vCU or vDU,
    ...                                provide it in the format: 'vCUCNF25R2_25.250.396'.
    ...                Author:         mateusz.gadek@nokia.com
    [Arguments]    ${CNF_SW}    ${ccr}    ${ssh_connection}    ${hw}
    Set Test Variable    ${hw}
    ${hw_conv}=  Convert To Lower Case  ${hw}
    IF    '${hw}'=='vCU'
    ${SW_VCU}=    Set Variable    ${CNF_SW}
    Set Test Variable    ${SW_VCU}
    END
    IF    '${hw}'=='vDU'
    ${SW_VDU}=    Set Variable    ${CNF_SW}
    Set Test Variable    ${SW_VDU}
    END
    ${rancnf_file}=  Set Variable  /home/ute/testline_configuration/${hostname}/LCM/${hw}/rancnf_${hw}.yaml
    ${du_trunk_scf}=   Set Variable   /home/ute/testline_configuration/${hostname}/vDUCNF00/scf_du.xml
    ${cu_trunk_scf}=   Set Variable   /home/ute/testline_configuration/${hostname}/vCUCNF00/scf_cu.xml
    ${registry}=  Set Variable  ccr-${ccr}-vrf-${hw_conv}-01.wroclaw.nsn-rdnet.net:443/${hw_conv}
    ${updates}=    Create Dictionary
    ...    spec.cnfConfig.imageRegistry=${registry}
    ...    spec.cnfConfig.cnfSWBuild=${CNF_SW}-amd64
    _Update RANCNF LCM Operator File    ${rancnf_file}    ${updates}
    _Upload rancnf file to core   ${rancnf_file}  ${ssh_connection}
    ${cnf_name}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.name
    ${cnf_name}=    Set Variable    ${cnf_name}
    ${namespace}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.namespace
    ${namespace}=    Set Variable    ${namespace}
    _Prepare CNF Namespace    ${ssh_connection}    ${namespace}
    Log    Starting the installation of ${CNF_SW}  console=True
    ${package_path}  Download required software files  SW_PACKAGE=${CNF_SW}    ssh_conn=${ssh_connection}    operation_type=upgrade
    ...    conversion=${False}  onboarding=${False}
    Set Test Variable  ${package_path}
    Unpack required software files  package_path=${package_path}[0]   conversionApp_path=${False}  onboardingApp_path=${False}
    ...                             storage_dir=${storage_dir}[upgrade]  conn=${ssh_connection}
    Images Onboarding  hw_type=${hw_conv}  ccr_location=${ccr}  operation_type=upgrade
    ${image_path}    get_ccr_image_path_list_variable   IMAGE_PATH_LIST
    Set Suite Variable    ${CCR_IMAGE_PATH_LIST}    ${image_path}
    Sleep   10s
    Log     Starting ${hw} deployment on namespace: ${namespace} with SW: ${CNF_SW}   console=True
    ssh.Execute    kubectl create -f rancnf_${hw}.yaml   connection=${ssh_connection}
    ssh.Assert Exit Status   0    connection=${ssh_connection}
    Wait Until Keyword Succeeds    600s    10s    wait_for_cnf_status   ${ssh_connection}    ${namespace}    ${cnf_name}
    IF  '${hw}'=='vCU'
            ${admin_connection_vcu}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
            Set Test Variable  ${admin_connection_vcu}
            vcu_admin.Perform Commissioning  scf_file=${cu_trunk_scf}  connection=${admin_connection_vcu}
    END
    IF  '${hw}'=='vDU'
            ${admin_connection_vdu}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
            Set Test Variable  ${admin_connection_vdu}
            vdu_admin.Perform Commissioning  scf_file=${du_trunk_scf}  vdu_connection=${admin_connection_vdu}
    END

CNF Termination via LCM Operator
    [Documentation]    Description:    Terminate vCU or vDU via LCM operator
    ...                Input:          ssh_connection: An object representing the SSH connection to the server
    ...                                where the LCM operator is installed.
    ...                                This is the output of the 'Connect to ADMIN via SSH' keyword from
    ...                                cloud_common_resources/connections/connections.robot.
    ...                Author:         mateusz.gadek@nokia.com
    [Arguments]       ${ssh_connection}    ${hw}
    ${rancnf_file}=  Set Variable  /home/ute/testline_configuration/${hostname}/LCM/${hw}/rancnf_${hw}.yaml
    ${namespace}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.namespace
    ${cnf_name}=    _Read Data From RANCNF File  ${rancnf_file}   metadata.name
    ssh.Execute    kubectl delete rancnf ${cnf_name} -n ${namespace}   connection=${ssh_connection}

Prepare XML LCM Deployment Plan Before Upload To MR
    [Arguments]    ${path_to_the_plan}  ${image_registry}  ${sw_build}
    Log  Setting image registry: ${image_registry} and sw_build: ${sw_build} into the XML deployment plan
    prepare_xml_plan  ${path_to_the_plan}  ${image_registry}  ${sw_build}

################################################ Supplementary Keywords ################################################

_Update LCM Operator To Latest Version
    [Arguments]    ${lcm_operator_status}    ${ccr}    ${ssh_connection}
    Log    ${\n}LCM operator current version: ${lcm_operator_status}[current_version], Update is needed!    console=True
    Log    Starting the update to version ${lcm_operator_status}[target_software_version]    console=True
    _Prepare SW Package    ${lcm_operator_status}[target_software_version]    ${ccr}    ${ssh_connection}
    ...    create_registry_secret=${False}
    ${sw_version}    Replace String    ${lcm_operator_status}[target_software_version]    -amd64.zip    ${Empty}
    _Helm Update LCM Operator
    ...  /var/home/core/${sw_version}/HelmChart/
    ...  ${sw_version}
    ...  ${ssh_connection}
    Sleep   10s
    ${lcm_operator_deployed}    get_lcm_operator_deployment_status    ${ssh_connection}
    ssh.Execute    rm -rf /var/home/core/${sw_version}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    Run Keyword If    not ${lcm_operator_deployed}    Fatal Error    LCM Operator Update Failed!
    Log    The LCM Operator was updated successfully.    console=${True}

_Install LCM Operator
    [Arguments]    ${lcm_operator_status}    ${ccr}    ${ssh_connection}
    Log    ${\n}LCM operator is not installed.    console=${True}
    Log    Starting the installation of ${lcm_operator_status}[target_software_version]    console=True
    _Prepare LCM Namespace    ${ssh_connection}
    _Prepare SW Package       ${lcm_operator_status}[target_software_version]    ${ccr}    ${ssh_connection}
    ${sw_version}    Replace String    ${lcm_operator_status}[target_software_version]    -amd64.zip    ${Empty}
    _Helm Install LCM Operator
    ...  ccr-${ccr}-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu/
    ...  /var/home/core/${sw_version}/HelmChart/
    ...  ${sw_version}
    ...  ${ssh_connection}
    Sleep   20s
    ${lcm_operator_deployed}    get_lcm_operator_deployment_status    ${ssh_connection}
    ssh.Execute    rm -rf /var/home/core/${sw_version}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    Run Keyword If    not ${lcm_operator_deployed}    Fatal Error    LCM Operator Installation Failed!
    Log    The LCM Operator was deployed successfully.    console=${True}


_Helm Install LCM Operator
    [Arguments]    ${ccr_url}    ${path_to_package}    ${sw_version}    ${ssh_connection}
    ${package}    Replace String    ${sw_version}    _    -
    ${ccr_address}    Replace String    ${ccr_url}    https://    ${Empty}
    ${command_1}     Set Variable    helm install cnf-lcm-operator -n cnf-lcm-operator
    ${command_2}     Set Variable    --set global.image.registry=${ccr_address}cnf-lcm-operator ${path_to_package}${package}.tgz
    ${full_command}  Set Variable    ${command_1} ${command_2}
    ssh.Execute      ${full_command}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

_Helm Update LCM Operator
    [Arguments]    ${path_to_package}    ${sw_version}    ${ssh_connection}
    ${package}     Replace String    ${sw_version}    _    -
    ${command}     Set Variable    helm upgrade -n cnf-lcm-operator cnf-lcm-operator ${path_to_package}${package}.tgz --reuse-values
    ssh.Execute    ${command}      connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

_Push Images To CCR
    [Arguments]    ${ccr_url}    ${path_to_package}    ${ssh_connection}
    ${ccr_address}    Replace String    ${ccr_url}    https://    ${Empty}
    ${command_1}    Set Variable    cd ${path_to_package} && for image_tar_file in `ls ./Image`; do echo $image_tar_file;
    ${command_2}    Set Variable    load_output=$(podman load -i ./Image/$image_tar_file); old_tag=\${load_output##* };
    ${command_3}    Set Variable    new_tag=${ccr_address}cnf-lcm-operator/\${old_tag##*/}; podman tag \${old_tag} \${new_tag};
    ${command_4}    Set Variable    podman push --tls-verify=false \${new_tag}; podman rmi $old_tag; done
    ${full_command}    Set Variable    ${command_1} ${command_2} ${command_3} ${command_4}
    ssh.Execute    ${full_command}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}


_Check LCM Operator Status
    [Arguments]                   ${sw_version}    ${ssh_connection}
    ${latest_version}             get_lcm_latest_version
    ${target_software_version}    Set Variable If    '${sw_version}'=='latest'    ${latest_version}    ${sw_version}
    ${current_version}            get_lcm_operator_version_if_installed    ${ssh_connection}
    ${is_installed}               Set Variable If    "${current_version}"!="${None}"    ${True}    ${False}
    ${instalation_nedeed}         Evaluate    '${current_version}' not in '''${target_software_version}'''
    ${needs_upgrade}              Set Variable If    ${is_installed}    ${instalation_nedeed}    ${False}
    ${lcm_operator_status}        Create Dictionary
    ...    is_installed=${is_installed}
    ...    needs_upgrade=${needs_upgrade}
    ...    current_version=${current_version}
    ...    target_software_version=${target_software_version}
    [Return]    ${lcm_operator_status}

_Prepare LCM Namespace
    [Arguments]    ${ssh_connection}
    Log    Creating 'cnf-lcm-operator' namespace ...    console=True
    ${output}             ssh.Execute    kubectl get namespace cnf-lcm-operator    connection=${ssh_connection}
    ${nemespace_exist}    Evaluate       'Error' not in '''${output}'''
    Run Keyword If        ${nemespace_exist}    Run Keywords
    ...    ssh.Execute              kubectl delete namespace cnf-lcm-operator    connection=${ssh_connection}  AND
    ...    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ssh.Execute    oc new-project cnf-lcm-operator    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    Log    'cnf-lcm-operator' namespace has been created.    console=True

_Prepare SW Package
    [Arguments]    ${sw_package}    ${ccr}    ${ssh_connection}    ${create_registry_secret}=${True}
    _Download SW From Artifactory    ${sw_package}    ${ssh_connection}
    ${path_to_sw_package}=    _Unpack SW Package    ${sw_package}    ${ssh_connection}
    Create CCR Certs On Core    ${ssh_connection}
    ${ccr_url}=      Set Variable    https://ccr-${ccr}-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu/
    ${certs_dir}=    Set Variable    /var/home/core/vrfrepos/
    Login To CCR    ccr_url=${ccr_url}    certs_dir=${certs_dir}    ccr_location=${ccr}
    ...             hw_type=vdu           ssh_connection=${ssh_connection}
    Run Keyword If    ${create_registry_secret}
    ...               _Create Docker Registry Secret    ${ccr}    ${ccr_url}    ${ssh_connection}
    _Push Images To CCR    ${ccr_url}    ${path_to_sw_package}    ${ssh_connection}

_Create Docker Registry Secret
    [Arguments]     ${ccr}    ${ccr_url}    ${ssh_connection}
    ${username}     Set Variable    robot\\$vrf
    &{passwords}    Create Dictionary
    ...    wl=m7SRFboceS9eRedcLu1yGvAoMq2YKX5o
    ...    wg=zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9
    ${command_1}       Set Variable       kubectl create secret docker-registry nokia-cnf-ccr-creds --docker-server=${ccr_url}
    ${command_2}       Set Variable       --docker-username=${username} --docker-password=${passwords}[${ccr}] -n cnf-lcm-operator
    ${full_command}    Set Variable       ${command_1} ${command_2}
    ssh.Execute        ${full_command}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

_Unpack SW Package
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

_Download SW From Artifactory
    [Arguments]    ${sw_package}    ${ssh_connection}
    ${artifactory_link}    Set Variable    https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/cnf-lcm-operator/
    ssh.Execute    curl -O ${artifactory_link}${sw_package}    connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}

_Prepare CNF Namespace
    [Arguments]    ${ssh_connection}    ${namespace}
    Log    Creating cnf namespace ${namespace}    console=True
    ${output}             ssh.Execute    kubectl get namespace ${namespace}    connection=${ssh_connection}
    ${nemespace_exist}    Evaluate       'Error' not in '''${output}'''
    Run Keyword If        ${nemespace_exist}   Run Keywords
    ...    ssh.Execute              kubectl delete namespace ${namespace}    connection=${ssh_connection}  AND
    ...    ssh.Assert Exit Status   0    connection=${ssh_connection}
    ssh.Execute    oc create namespace ${namespace}     connection=${ssh_connection}
    ssh.Assert Exit Status    0    connection=${ssh_connection}
    Log    '${namespace}' namespace has been created.    console=True

_Upload rancnf file to core
    [Documentation]  Description: KW uploads rancnf file to core.
    [Arguments]    ${rancnf_file}    ${ssh_connection}
    ${output}=  ssh.Upload File  ${rancnf_file}  /var/home/core/rancnf_${hw}.yaml  connection=${ssh_connection}
    Log   ${output}  console=${true}
    ${file_exist}=  ssh.Execute  test -f "/var/home/core/rancnf_${hw}.yaml" && echo OK || echo FAIL  connection=${ssh_connection}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK

_CNF Status Should Be Succeed
    [Arguments]    ${namespace}    ${cnf_name}
    ${output}=    Run Process    kubectl get rancnf -n ${namespace}    stdout=TRUE
    Log    ${output.stdout}
    ${lines}=    Split To Lines    ${output.stdout}
    Should Be True    ${lines[1].startswith(${cnf_name})}
    ${columns}=    Split String    ${lines[1]}    whitespace=True
    ${status}=    Get From List    ${columns}    4
    Should Be Equal    ${status}    Succeed

_Read Data From RANCNF File
    [Documentation]    Description:    KW return dictionary value for the given key from rancnf file
    ...                Input:          path: location of rancnf file
    ...                                /home/ute/testline_configuration/10_16_UTESRANCLOUD2130/LCM/vDU/rancnf_vDU.yaml
    ...                                dict_key: dictionary key     e.g metadata.namespace           will return    cran8527lcm
    ...                                              spec.cnfConfig.cnfSWBuild    will return    vCUCNF00_0.250.30881-amd64
    ...                Author:         mateusz.gadek@nokia.com
    [Arguments]    ${path}    ${dict_key}
    ${hw_conv}=  Convert To Lower Case  ${hw}
    ${data}=    load_yaml_as_dict    ${path}
    ${search_value}=    get_value_by_path   ${data}    ${dict_key}
    [Return]    ${search_value}

_Update RANCNF LCM Operator File
    [Arguments]  ${path}  ${updates}
    Log    ${updates}       console=True
    update_rancnf_file   ${path}    ${updates}