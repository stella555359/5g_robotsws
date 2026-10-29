*** Settings ***
Documentation    Keywords to integrate and deintegrate vCU/vDU with Mantaray NMS labs.
...              Firewall between VM and NMS Lab should be opened for this to work.
...              Keywords for CNF Deployment supports vCU, vDU, Nokia Sync Operator and Ran Nic Sw Controller.
...              Requires filled out deployment charts and uses variables from init.py such as MRBTS, MRBTS_CU,
...              SSH_K8S_ info, namespaces, location of deployment charts (cluster_preparation, prerequisite, cnf)
...              Author:    Damian Kotula
...              Contact:   damian.kotula@nokia.com

Library     taf.nms.netact          WITH NAME    nms
Library     taf.transport.ssh       WITH NAME    ssh
Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     Collections
Library     String
Library     OperatingSystem
Library     DateTime
Library     ./mantaray.py
Variables   ./mantaray_labs.yaml
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../parameters/parameters.robot
Resource    ../connections/connections.robot

*** Variables ***
${espoo1_artifactory}    https://10.170.21.83
${espoo3_artifactory}    https://10.170.21.85
${artifactory-blr1}      https://10.135.150.153

*** Keywords ***

#################################################### Main  Keywords ####################################################

Integrate Cloud BTS with NMS Lab
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and integrates vCU/vDU to it.
    ...                                After integration node is deleted
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                hw_type = vDU / vCU
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                                expected_status = Succeeded / Ongoing / N/A
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_ip}    ${hw_type}=${NONE}    ${username}=${NMS_USERNAME}    ${password}=${NMS_PASSWORD}
    ...                ${expected_status}=Succeeded    ${blue_green}=${False}
    Log    ${hw_type} integration to Mantaray NMS started, lab ip=${nms_lab_ip}.    console=${True}
    ${release_version}=    _Get Active SW For NMS Integration    hw_type=${hw_type}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${username}    password=${password}
    nms.Detect Nodes
    IF   ${blue_green}
        Run Keyword And Ignore Error    nms.Integrate Mrbts With Netact    release=${release_version}
        ...    mr=MRC-COMMON/MR-CLOUD    mrbts_address=${mrbts_ip}    dist_name=${dist_name}    security_mode=no TLS
    ELSE
        Run Keyword And Ignore Error    nms.Integrate Mrbts With Netact    release=${release_version}
        ...    mr=MRC-COMMON/MR-COMMON    mrbts_address=${mrbts_ip}    dist_name=${dist_name}    security_mode=no TLS
    END

    Wait Until Keyword Succeeds    3 min    5 sec    Check NMS Status On Cloud BTS
    ...    expected_status=${expected_status}    hw_type=${hw_type}
    Log  ${hw_type} integration to Mantaray NMS lab finished.    console=${True}
    [Teardown]    nms.Delete Node    cmwas


Deintegrate Cloud BTS from NMS Lab
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and deintegrates vCU/vDU
    ...                                from this lab. After deintegration node is deleted.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                hw_type = vDU / vCU
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_ip}    ${hw_type}=${NONE}    ${username}=${NMS_USERNAME}    ${password}=${NMS_PASSWORD}
    ...                ${mr}=MRC-COMMON/MR-COMMON
    Log    ${hw_type} deintegration from Mantaray NMS started, lab ip=${nms_lab_ip}.    console=${True}
    ${release_version}=    _Get Active SW For NMS Integration    hw_type=${hw_type}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${username}    password=${password}
    nms.Detect Nodes
    ${deintegration_status}=    Run Keyword And Return Status
    ...    nms.Deintegrate Mrbts From Netact    dist_name=${dist_name}    alias=default
    IF    '${deintegration_status}' == 'False'
        nms.Integrate Mrbts With Netact    release=${release_version}    mr=${mr}
        ...                                mrbts_address=${mrbts_ip}    dist_name=${dist_name}
        ...                                security_mode=no TLS    alias=default
        Wait Until Keyword Succeeds    3 min    5 sec    Check NMS Status On Cloud BTS
        ...    expected_status=Succeeded    hw_type=${hw_type}
        nms.Deintegrate Mrbts From Netact    dist_name=${dist_name}    alias=default
    END
    Wait Until Keyword Succeeds    3 min    5 sec    Check NMS Status On Cloud BTS
    ...    expected_status=N/A    hw_type=${hw_type}
    Log    ${hw_type} deintegration from Mantaray NMS lab finished.    console=${True}
    [Teardown]    nms.Delete Node    cmwas

Integrate FHGW with NMS Lab
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and integrates FHGW to it.
    ...                                After integration node is deleted
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]        ${nms_lab_ip}   ${username}=${NMS_USERNAME}   ${password}=${NMS_PASSWORD}
    Log   FHGW integration to Mantaray NMS started, lab ip=${nms_lab_ip}.    console=${True}
    ${release_version}=    _Get Active SW For NMS Integration    hw_type=FHGW
    ${dist_name}=           Set Variable          PLMN-PLMN/FHGW-${MRBTS}
    ${fhgw_ip}=             Set Variable          ${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.addr}
    nms.Add Node            service_name=cmwas    hostname=${nms_lab_ip}    username=${username}    password=${password}
    nms.Detect Nodes
    nms.Integrate Fhgw With Netact   release=${release_version}    mr=MRC-COMMON/MR-FHGW
    ...                              fhgw_address=${fhgw_ip}       dist_name=${dist_name}    security_mode=no TLS
    [Teardown]    nms.Delete Node    cmwas


Deintegrate FHGW from NMS Lab
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and deintegrates FHGW
    ...                                from this lab. After deintegration node is deleted.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                Output:         none
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]        ${nms_lab_ip}  ${username}=${NMS_USERNAME}    ${password}=${NMS_PASSWORD}
    Log    FHGW deintegration from Mantaray NMS started, lab ip=${nms_lab_ip}.    console=${True}
    ${release_version}=    _Get Active SW For NMS Integration    hw_type=FHGW
    ${dist_name}=           Set Variable          PLMN-PLMN/FHGW-${MRBTS}
    ${fhgw_ip}=             Set Variable          ${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details.addr}
    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${username}    password=${password}
    nms.Detect Nodes
    nms.Deintegrate Ne From Netact   dist_name=${dist_name}      alias=default
    Log    FHGW deintegration from Mantaray NMS lab finished.    console=${True}
    [Teardown]    nms.Delete Node    cmwas


Check NMS Status On Cloud BTS
    [Documentation]    Description:    Checks status of NMS integration. Fails if status is not as expected,
    ...                Input:          expected_status = Succeeded / Ongoing / N/A
    ...                                hw_type = vDU / vCU
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${expected_status}=Succeeded    ${hw_type}=${NONE}

    ${temp_conn}=    connections.Connect to ADMIN    hw_type=${hw_type}
    IF    '${hw_type}'=='vDU'
        ${nms_status}=    vdu_admin.Get Nms    vdu_connection=${temp_conn}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE IF    '${hw_type}'=='vCU'
        ${nms_status}=    vcu_admin.Get Nms    connection=${temp_conn}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}


Integrate Cloud Server with NMS
    [Documentation]    Description:    Integrates cloud server with choosen NMS lab (OCP), which is precondition
    ...                                for deployment.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                hw_type = vDU / vCU
    ...                                id = ID of the hw_type (e.g. 2); default: Empty
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_ip}    ${nms_lab_number}    ${hw_type}=${None}  ${id}=${Empty}

    IF    '${hw_type}' == 'vDU'
        ${cloud_dn} =    Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
    ELSE IF    '${hw_type}' == 'vCU'
        ${cloud_dn} =    Set Variable    PLMN-PLMN/CLOUD-${MRBTS_CU}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    _Add Certificates to OCP    nms_lab_number=${nms_lab_number}    nms_lab_ip=${nms_lab_ip}    hw_type=${hw_type}  id=${id}
    ${is_integrated} =    _Check If Object Is Integrated    nms_lab_ip=${nms_lab_ip}    object_dn=${cloud_dn}
    IF    ${is_integrated} == ${True}    RETURN
    Log    \nIntegrating cloud server with NMS lab ${nms_lab_number}.     console=${True}
    ${ocp_version} =           Get OCP Version for MN                     hw_type=${hw_type}    id=${id}
    &{ocp_version_dict} =      Create Dictionary
    Set To Dictionary          ${ocp_version_dict}                        -version=${ocp_version}
    ${config_file_path} =      _Get Config File From K8s Server           hw_type=${hw_type}    id=${id}
    ${kubeconfig_for_ssd} =    Prepare Kubeconfig File With Parameters    config_path=${config_file_path}
    ...                                                                   cloud_dn=${cloud_dn}
    ...                                                                   destination_dir=${OUTPUT DIR}
    _Connect To NMS            nms_lab_ip=${nms_lab_ip}
    nms.Import SSD             input_file=${kubeconfig_for_ssd}    file_format=JSON    overwrite=${True}
    nms.Integrate Cloud        cloud_dn=${cloud_dn}                parameters=&{ocp_version_dict}
    [Teardown]    nms.Delete Node    service_name=cmwas


Deintegrate Cloud Server from NMS
    [Documentation]    Description:    Deintegrates cloud server from choosen NMS lab.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                hw_type = vDU / vCU
    ...                                force_deintegrate = True / False. If True, deletes CLOUD object
    ...                                even if it is connected to any CNFs.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_ip}    ${nms_lab_number}    ${hw_type}=${None}    ${force_deintegrate}=${False}

    Log    \nDeintegrating cloud server from NMS lab ${nms_lab_number}.    console=${True}
    IF    '${hw_type}' == 'vDU'
        ${cloud_dn} =    Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
    ELSE IF    '${hw_type}' == 'vCU'
        ${cloud_dn} =    Set Variable    PLMN-PLMN/CLOUD-${MRBTS_CU}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    _Connect To NMS          nms_lab_ip=${nms_lab_ip}
    nms.Deintegrate Cloud    cloud_dn=${cloud_dn}    force_deintegrate=${force_deintegrate}
    _Remove Certificates from OCP    nms_lab_number=${nms_lab_number}    hw_type=${hw_type}
    [Teardown]    nms.Delete Node    service_name=cmwas


Perform CNF Deployment
    [Documentation]    Description:    Keyword to deploy CNF from choosen NMS lab. Creates deployment plan with
    ...                                managed object of CNF, validates and deploys it. If choosen sw is not present
    ...                                on NMS lab, it will be downloaded and imported. Yaml charts used for deployment
    ...                                should be filled out for deploying BTS and passed in parameters.
    ...                                KW uses variables from init.py, so it should be filled out
    ...                                and passed in during test run.
    ...                Input:          sw_version = exact sw build to be used, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                hw_type = vDU / vCU if deploying CNF. Default is None.
    ...                                nop_type =  nokia-sync-operator / ran-nic-sw-controller / koredump-operator-vcu /
    ...                                            cnf-lcm-operator-vdu / cnf-lcm-operator-vc if deploying
    ...                                            one of Nokia Operators (NOP). Default is None.
    ...                                ccr_name = name of CCR used for deployment. Default is project1
    ...                                distribution = True / False. If True, SW will be distributed to ccr before deployment.
    ...                                delete_plan = True / False. Specifies if plan should be deleted after deployemnt.
    ...                                blue_green = True / False. If set to true, a blue-green deployment will be performed;
    ...                                             if false, a standard deployment will be executed.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${sw_version}    ${nms_lab_ip}    ${nms_lab_number}    ${hw_type}=${None}    ${nop_type}=${None}
    ...                ${ccr_name}=project1    ${distribution}=${True}    ${delete_plan}=${True}    ${blue_green}=${False}

    IF    ${nms_lab_number} in ${TAMPERE_LABS}
        ${registry_link} =    Set Variable    srnclab${nms_lab_number}lcm.srntre.nsn-rdnet.net:8443/${ccr_name.lower()}
    ELSE
        ${registry_link} =    Set Variable    srnclab${nms_lab_number}lcm.srnblr.nsn-rdnet.net:8443/${ccr_name.lower()}
    END
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}    nop_type=${nop_type}
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    Starting to prepare deployment plan    console=${True}

    IF  ${blue_green}
        ${deployment_plan}=    _Prepare Deployment Plan    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}
        ...                                                registry_link=${registry_link}
        ...                                                hw_type=${hw_type}    nop_type=${nop_type}  blue_green=${True}
    ELSE
        ${deployment_plan}=    _Prepare Deployment Plan    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}
        ...                                                registry_link=${registry_link}
        ...                                                hw_type=${hw_type}    nop_type=${nop_type}  blue_green=${False}
    END
    nms.Validate Cnf Plan Offline    plan_name=${deployment_plan}
    Log    Starting deployment on lab ${nms_lab_number}    console=${True}
    ${feedback}=    nms.Deploy Cnf    plan_name=${deployment_plan}    verbose=${True}    distribution=${distribution}
    Log    Deployment finished.   console=${True}
    [Teardown]    Run Keywords    Run Keyword If    ${delete_plan}    nms.Delete Plan    plan_name=${deployment_plan}
    ...                    AND    nms.Delete Node    service_name=cmwas
    [Return]    ${feedback}

Perform RANCNF Deployment Via LCM Operator
    [Documentation]    Description:    Keyword to deploy RANCNF from choosen NMS lab via LCM operator. . If choosen sw is not present
    ...                                on NMS lab, it will be downloaded and imported.
    ...                Input:          sw_version = exact sw build to be used, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                plan_name = Name of the deployment plan present on the CN Operations Manager
    ...                                dist_names = Specifies the scope of the operation, e.g. PLMN-PLMN/CLOUD-1/NAMESPACE-1/RANCNF-1
    ...                                validation_only = If set to ``True``, the CNF LCM Operator will only validate the plan
    ...                                parameters = optional parameters (-feedbackLevel, -distribution)
    ...                                verbose = If ``True``, returns more detailed output from executed operation
    ...                                ignore_errors = If ``True``, shows warnings instead of raising errors when operation fails
    ...                                timeout = Timeout for executing operation
    ...                Output:         none
    ...                Author:         marek.starzyk@nokia.com
    [Arguments]        ${sw_version}            ${nms_lab_ip}         ${nms_lab_number}
    ...                ${plan_name}             ${dist_names}         ${validation_only}=${False}
    ...                ${parameters}=${None}    ${verbose}=${True}    ${ignore_errors}=${False}
    ...                ${timeout}=7200
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}    nop_type=${None}
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    Starting deployment on lab ${nms_lab_number}    console=${True}
    nms.Deploy Rancnf    plan_name=${plan_name}      dist_names=${dist_names}          validation_only=${validation_only}
    ...                  parameters=${parameters}    ignore_errors=${ignore_errors}    timeout=${timeout}
    ...                  verbose=${verbose}
    Log    Deployment finished.   console=${True}
    [Teardown]    Run Keywords    nms.Delete Plan    plan_name=${plan_name}
    ...                    AND    nms.Delete Node    service_name=cmwas

Terminate CNF
    [Documentation]    Description:    Terminates CNF deployment from NMS lab.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                k8s_objects_to_delete = specifies what type of K8S objects should be deleted.
    ...                                                        Possible values: none, secrets or namespace
    ...                                hw_type = vDU / vCU if deploying CNF. Default is None.
    ...                                nop_type = nokia-sync-operator / ran-nic-sw-controller / koredump-operator-vdu /
    ...                                koredump-operator-vcu / cnf-lcm-operator-vdu / cnf-lcm-operator-vc
    ...                                if deploying one of Nokia Operators (NOP). Default is None.
    ...                                delete_plan = True / False. Specifies if plan should be deleted after deployemnt.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_ip}    ${k8s_objects_to_delete}=namespace    ${deintegrate_mrbts}=${False}
    ...                ${hw_type}=${None}    ${nop_type}=${None}    ${delete_plan}=${True}

    IF    '${hw_type}' == 'vDU'
        ${terminate_plan_name} =    Set Variable    ${MRBTS}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS}
    ELSE IF    '${hw_type}' == 'vCU'
        ${terminate_plan_name} =    Set Variable    ${MRBTS_CU}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS_CU}
    END
    IF    '${nop_type}' == 'nokia-sync-operator'
        ${terminate_plan_name} =    Set Variable    ${MRBTS}2_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS}02
    ELSE IF    '${nop_type}' == 'ran-nic-sw-controller'
        ${terminate_plan_name} =    Set Variable    ${MRBTS}3_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS}03
    ELSE IF    '${nop_type}' == 'koredump-operator-vdu'
        ${terminate_plan_name} =    Set Variable    ${MRBTS}_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS}04
    ELSE IF    '${nop_type}' == 'koredump-operator-vcu'
        ${terminate_plan_name} =    Set Variable    ${MRBTS_CU}_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS_CU}04
    ELSE IF    '${nop_type}' == 'cnf-lcm-operator-vdu'
        ${terminate_plan_name} =    Set Variable    ${MRBTS}_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS}05
    ELSE IF    '${nop_type}' == 'cnf-lcm-operator-vcu'
        ${terminate_plan_name} =    Set Variable    ${MRBTS_CU}_${nop_type}_auto_terminate_plan
        ${cnf_dn} =                 Set Variable    PLMN-PLMN/CNF-${MRBTS_CU}05
    END

    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    ${terminate_plan} =              nms.Create Plan Configuration                  name=${terminate_plan_name}
    nms.Create Managed Object        plan=${terminate_plan}                         mo_id=${cnf_dn}
    ...                              meta_class=com.nokia.cnf.lcm:CNF               meta_version=CNF2.0
    ...                              operation=DELETE
    ${feedback}=                     nms.Terminate Cnf
    ...                              plan_name=${terminate_plan_name}               dist_names=${cnf_dn}
    ...                              delete_k8s_objects=${k8s_objects_to_delete}    verbose=${True}
    ...                              deintegrate_mrbts=${deintegrate_mrbts}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_plan}    nms.Delete Plan
    ...                              plan_name=${terminate_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas
    [Return]    ${feedback}

Terminate RANCNF
    [Documentation]    Description:    Terminates RANCNF deployment from NMS lab.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                dist_names = Specifies the scope of the operation,
    ...                                e.g., `PLMN-PLMN/CLOUD-851201/NAMESPACE-cran878101/RANCNF-1`
    ...                                deintegrate_mrbts = True / False, default True
    ...                                delete_plan = True / False, default True
    ...                Output:         Operation output
    ...                Author:         marek.starzyk@nokia.com
    [Arguments]        ${nms_lab_ip}    ${dist_names}  ${deintegrate_mrbts}=${True}
    ...                ${delete_plan}=${True}

    ${current_date}      Get Current Date  result_format=%d_%m_%Y_%H_%M
    Set Test Variable    ${CURRENT_DATE}                     ${current_date}
    ${terminate_plan_name} =         Set Variable                           ${MRBTS_CU}_auto_terminate_plan_${CURRENT_DATE}
    _Connect To NMS                  nms_lab_ip=${nms_lab_ip}
    ${terminate_plan} =              nms.Create Plan Configuration          name=${terminate_plan_name}
    nms.Create Managed Object        plan=${terminate_plan}                 mo_id=${dist_names}
    ...                              meta_class=com.nokia.k8s.cnf:RANCNF    meta_version=v1alpha2
    ...                              operation=DELETE
    ${plan_parameters}=    Create Dictionary    -deintegrateMRBTS=${deintegrate_mrbts}    -feedbackLevel=parameterLevel
    ${feedback}=                     nms.Terminate Rancnf
    ...                              plan_name=${terminate_plan_name}    dist_names=${dist_names}
    ...                              parameters=${plan_parameters}       verbose=${True}    ignore_errors=${False}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_plan}    nms.Delete Plan
    ...                              plan_name=${terminate_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas
    [Return]    ${feedback}

Perform CNF Upgrade
    [Arguments]   ${nms_lab_ip}    ${sw_version}    ${hw_type}=${None}    ${nop_type}=${None}
    ...           ${download_ru_sw}=${False}    ${distribution}=${True}    ${delete_upgrade_plan}=${True}
    ...           ${delete_rollback_plan}=${False}    ${rollback}=${False}
    [Documentation]    Description:    This keyword performs a CNF upgrade on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${sw_version} - The software version to upgrade to.
    ...                                ${hw_type} - The hardware type (e.g., vDU or vCU).
    ...                                ${nop_type} - The type of NOP (e.g., nokia-sync-operator or ran-nic-sw-controller).
    ...                                ${download_ru_sw} - Boolean flag to indicate whether to download RU software.
    ...                                ${distribution} - Boolean flag to indicate whether to distribute the software.
    ...                                ${delete_upgrade_plan} - Boolean flag to indicate whether to delete the upgrade plan after execution.
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                                ${rollback} - Boolean flag to indicate whether to perform a rollback after the upgrade. Default is False.
    ...                Output:         Executes the CNF upgrade plan and optionally deletes the upgrade/rollback plans and performs a rollback.
    ...                                Logs the progress and results of the upgrade process.
    ...                Author:         damian.kotula@nokia.com
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}    nop_type=${nop_type}
    _Connect To NMS           nms_lab_ip=${nms_lab_ip}
    _Prepare Upgrade Plan    sw_version=${sw_version}    hw_type=${hw_type}    nop_type=${nop_type}
    Log    Starting CNF upgrade to ${sw_version}    console=${True}
    nms.Upgrade CNF    plan_name=${upgrade_plan_name}    rollback_plan_name=${rollback_plan_name}
    ...                verbose=${True}    download_ru_sw=${download_ru_sw}    distribution=${distribution}
    Log    Upgrade finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_upgrade_plan}    nms.Delete Plan
    ...                              plan_name=${upgrade_plan_name}
    ...                    AND       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas
    ...                    AND       Run Keyword If    ${rollback}    Perform CNF Rollback
    ...                              nms_lab_ip=${NMS_LAB_IP}    hw_type=${hw_type}

Perform CNF Rollback
    [Arguments]    ${nms_lab_ip}    ${hw_type}=${None}   ${rollback_plan_name}=${None}  ${cnf_dn}=${None}  ${delete_rollback_plan}=${True}
    [Documentation]    Description:    This keyword performs a CNF rollback operation on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${hw_type} - The hardware type (e.g., vCU or vDU).
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                                ${rollback_plan_name} - Name of rollback plan
    ...                Output:         Executes the rollback plan and optionally deletes the rollback plan and node.
    ...                Notes:          Ensure that the rollback plan and CNF DN are properly configured before running this keyword.
    ...                Author:         roscislaw.szuminski@nokia.com
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    Starting CNF rollback    console=${True}
    nms.Rollback Cnf  plan_name=${rollback_plan_name}  dist_names=${cnf_dn}
    Log    Rollback finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas

Perform FHGW Upgrade
    [Documentation]    Description:    This keyword performs a CNF upgrade on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${sw_version} - The software version to upgrade to.
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]        ${nms_lab_ip}     ${sw_version}
    ${dist_name}=      Set Variable               PLMN-PLMN/FHGW-${MRBTS}
    ${sw_version}=    _Prepare SW on NMS lab      sw_version=${sw_version}    nms_lab_ip=${NMS_LAB_IP}     nop_type=FHGW    mo_type=FHGW
    Set Variable      ${sw_version}
    Integrate FHGW with NMS Lab    nms_lab_ip=${NMS_LAB_IP}
    _Connect To NMS                nms_lab_ip=${NMS_LAB_IP}
    Log    Starting FHGW SW upgrade    console=${True}
    nms.Provision SW    dist_names=${dist_name}    package_name=${sw_version}    timeout=3600
    Log    Upgrade Finished            console=${True}
    [Teardown]    nms.Delete Node      service_name=cmwas

Perform FHGW Rollback
    [Documentation]    Description:    This keyword performs FHGW rollback operation on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]        ${nms_lab_ip}
    ${dist_name}=      Set Variable               PLMN-PLMN/FHGW-${MRBTS}
    _Connect To NMS    nms_lab_ip=${NMS_LAB_IP}
    Log    Starting FHGW rollback    console=${True}
    nms.Rollback Sw    dist_names=${dist_name}    timeout=3600
    Log    Rollback Finished        console=${True}
    [Teardown]    nms.Delete Node      service_name=cmwas

Verify Api On Lab
    [Documentation]    Description:    This keyword verifies api on selected MantaRay Lab.
    ...                                Keyword connects to the core system, retrieves server information,
    ...                                and verifies API accessibility.
    ...                Input:          ${nms_lab_ip} - cmwas node ip of selected NMS Lab
    ...                                ${hw_type} - The hardware type (e.g., vCU or vDU). Default is None.
    ...                Output:         none
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]   ${nms_lab_ip}   ${hw_type}=${None}
    Log    \nStarting API Verification On Lab ${NMS_LAB}     console=${True}
    ${nodes_cmd}=    Set Variable    cat /var/home/core/.kube/config | grep -i server
    ${ssh_conn}=     Connect To Admin via SSH    hw_type=${hw_type}
    ${output}        ssh.Execute     ${nodes_cmd}  connection=${ssh_conn}
    ${after_colon}=  Split String    ${output}    https://
    ${url}=          Get From List   ${after_colon}    1
    ${parts}=        Split String    ${url}    :
    ${hostname}=     Get From List   ${parts}    0
    ${api_cmd}=      Set Variable    nslookup ${hostname}
    ssh.Connect To   hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${output}=      ssh.Execute     ${api_cmd}
    Should Not Contain   ${output}    ** server can't find ${hostname}: NXDOMAIN
    Log    Api Verification On Lab ${NMS_LAB} finished.   console=${True}
    [Teardown]  Run Keyword And Ignore Error  Disconnect from ADMIN via SSH    ${ssh_conn}  hw_type=${hw_type}

Perform CNF BlueGreen Upgrade
    [Arguments]   ${nms_lab_ip}  ${sw_version}  ${hw_type}=${None}  ${delete_upgrade_plan}=${True}  ${delete_rollback_plan}=${False}
    ...  ${additional_values}=${False}
    [Documentation]    Description:    This keyword performs a CNF blue green upgrade on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${sw_version} - The software version to upgrade to.
    ...                                ${hw_type} - The hardware type (e.g., vDU or vCU).
    ...                                ${delete_upgrade_plan} - Boolean flag to indicate whether to delete the upgrade plan after execution.
    ...                                ${additional_values} - The ability to modify the deployment of an
    ...                                                       existing CNF vCU using a blue/green upgrade mechanism.
    ...                Output:         Executes the CNF upgrade plan and optionally deletes the upgrade/rollback plans and performs a rollback.
    ...                                Logs the progress and results of the upgrade process.
    ...                Author:         roscislaw.szuminski@nokia.com
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}
    _Connect To NMS           nms_lab_ip=${nms_lab_ip}
    IF  ${additional_values}
        _Prepare Blue Green Upgrade Plan  sw_version=${sw_version}  hw_type=${hw_type}  additional_values=${True}
    ELSE
        _Prepare Blue Green Upgrade Plan  sw_version=${sw_version}  hw_type=${hw_type}  additional_values=${False}
    END
    ${parameters}=  Create Dictionary  -rollbackPlanName=${rollback_plan_name}  -createNamespace=${True}
    Log    Starting CNF upgrade to ${sw_version}    console=${True}
    nms.Upgrade Sw Cnf Blue Green   plan_name=${upgrade_plan_name}    dist_names=${bg_dist_names}
    ...                             parameters=${parameters}          verbose=${True}
    Log    \nBleuGreen Upgrade finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_upgrade_plan}    nms.Delete Plan
    ...                              plan_name=${upgrade_plan_name}
    ...                    AND       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas

Perform RANCNF BlueGreen Upgrade
    [Arguments]    ${nms_lab_ip}    ${sw_version}    ${upgrade_plan_name}    ${rollback_plan_name}    ${dist_names}=${None}
    ...            ${delete_upgrade_plan}=${True}    ${delete_rollback_plan}=${False}    ${with_scale_in}=${False}
    [Documentation]    Description:    This keyword performs a RANCNF blue green upgrade on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${sw_version} - The software version to upgrade to.
    ...                                ${upgrade_plan_name} - The name of the upgrade plan that will be created before the upgrade
    ...                                ${rollback_plan_name} - The name of the rollback plan that will be created during the upgrade plan execution
    ...                                ${dist_names} - Specifies the scope of the operation, e.g. PLMN-PLMN/CLOUD-1/NAMESPACE-1/RANCNF-1
    ...                                ${delete_upgrade_plan} - Boolean flag to indicate whether to delete the upgrade plan after execution.
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                                ${with_scale_in} - Boolean flag
    ...                Output:         Executes the RANCNF upgrade plan and optionally deletes the upgrade/rollback plans and performs a rollback.
    ...                                Logs the progress and results of the upgrade process.
    ...                Author:         marek.starzyk@nokia.com
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}
    _Connect To NMS           nms_lab_ip=${nms_lab_ip}
    ${plan_parameters}=  Create Dictionary  -withScaleIn=${with_scale_in}
    nms.Prepare Sw Upgrade Plan Rancnf Blue Green  ${upgrade_plan_name}  ${sw_version}  ${dist_names}  parameters=${plan_parameters}

    ${upgrade_parameters}=  Create Dictionary  -feedbackLevel=parameterLevel  -distribution=${True}
    Log    Starting CNF upgrade to ${sw_version}    console=${True}
    nms.Upgrade Sw Rancnf Blue Green   plan_name=${upgrade_plan_name}    dist_names=${None}  rollback_plan_name=${rollback_plan_name}
    ...                             parameters=${upgrade_parameters}          verbose=${True}
    Log    \nBleuGreen Upgrade finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_upgrade_plan}    nms.Delete Plan
    ...                              plan_name=${upgrade_plan_name}
    ...                    AND       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas

Perform RANCNF One Button Upgrade
    [Arguments]    ${nms_lab_ip}    ${sw_version}    ${upgrade_plan_name}    ${rollback_plan_name}    ${dist_names}=${None}
    ...            ${delete_upgrade_plan}=${True}    ${delete_rollback_plan}=${False}    ${validation_only}=${False}
    ...            ${downloadRUSW}=${False}    ${distribution}=${True}
    [Documentation]    Description:    This keyword performs a RANCNF blue green upgrade on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${sw_version} - The software version to upgrade to.
    ...                                ${upgrade_plan_name} - The name of the upgrade plan that will be created before the upgrade
    ...                                ${rollback_plan_name} - The name of the rollback plan that will be created during the upgrade plan execution
    ...                                ${dist_names} - Specifies the scope of the operation, e.g. PLMN-PLMN/CLOUD-1/NAMESPACE-1/RANCNF-1
    ...                                ${delete_upgrade_plan} - Boolean flag to indicate whether to delete the upgrade plan after execution.
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                                ${validation_only} - Boolean flag
    ...                                ${downloadRUSW} - Boolean flag, download RU software, default value False
    ...                                ${distribution} - Boolean flag, distribute CNF package, fefault value True
    ...                Output:         Prepare and executes the RANCNF one button upgrade plan and optionally deletes the upgrade/rollback plans.
    ...                                Logs the progress and results of the upgrade process.
    ...                Author:         marek.starzyk@nokia.com
    _Prepare SW on NMS lab    sw_version=${sw_version}    nms_lab_ip=${nms_lab_ip}
    _Connect To NMS           nms_lab_ip=${nms_lab_ip}

    ${upgrade_parameters}=  Create Dictionary  -feedbackLevel=parameterLevel    -distribution=${distribution}
    ...                                        -downloadRUSW=${downloadRUSW}    -deleteUpgradePlan=${False}
    Log    Starting CNF upgrade to ${sw_version}    console=${True}

    nms.upgrade_rancnf_one_button   plan_name=${upgrade_plan_name}    cnf_sw_id=${sw_version}    dist_names=${dist_names}
    ...                             rollback_plan_name=${rollback_plan_name}  validation_only=${validation_only}
    ...                             parameters=${upgrade_parameters}          verbose=${True}
    Log    \nOne Button Upgrade finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_upgrade_plan}    nms.Delete Plan
    ...                              plan_name=${upgrade_plan_name}
    ...                    AND       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas

Perform CNF BlueGreen Rollback
    [Arguments]    ${nms_lab_ip}  ${rollback_plan_name}=${None}  ${gb_dist_names}=${None}   ${delete_rollback_plan}=${True}
    [Documentation]    Description:    This keyword performs a CNF rollback operation on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${rollback_plan_name} - Name of rollback plan.
    ...                                ${gb_dist_names} - Dist name of green instance.
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                Output:         Executes the blue green rollback plan and optionally deletes the rollback plan and node.
    ...                Author:         roscislaw.szuminski@nokia.com
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    \nStarting CNF BlueGreen rollback    console=${True}
    nms.Rollback Sw Cnf Blue Green  plan_name=${rollback_plan_name}  dist_names=${gb_dist_names}
    Log    Rollback finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas


Perform RANCNF BlueGreen Rollback
    [Arguments]    ${nms_lab_ip}  ${rollback_plan_name}=${None}  ${gb_dist_names}=${None}   ${delete_rollback_plan}=${True}
    [Documentation]    Description:    This keyword performs a CNF rollback operation on the specified NMS lab.
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${rollback_plan_name} - Name of rollback plan.
    ...                                ${gb_dist_names} - Dist name of green instance.
    ...                                ${delete_rollback_plan} - Boolean flag to indicate whether to delete the rollback plan after execution.
    ...                Output:         Executes the blue green rollback plan and optionally deletes the rollback plan and node.
    ...                Author:         roscislaw.szuminski@nokia.com
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    \nStarting CNF BlueGreen rollback    console=${True}
    nms.Rollback Sw Rancnf Blue Green  plan_name=${rollback_plan_name}  dist_names=${None}
    Log    Rollback finished    console=${True}
    [Teardown]    Run Keywords       Run Keyword If    ${delete_rollback_plan}    nms.Delete Plan
    ...                              plan_name=${rollback_plan_name}
    ...                    AND       nms.Delete Node    service_name=cmwas

Import Configuration Plan To Lab
    [Documentation]    Description:    Data is imported to CM Operations Manager in selected nms
    ...                Input:          ${nms_lab_ip} - The IP address of the NMS lab.
    ...                                ${file_name} - Specifies the file name.
    ...                                ${local_dir} - Local patch for the file specified in file_name.
    ...                                ${plan_name} - Specifies a plan name.
    ...                                ${operation_type} - Specifies the type of import operation (plan/template/site/siteTemplate).
    ...                                ${verbose} - If ``True``, returns more detailed output from executed operation.
    ...                                ${ignore_errors} - If ``True``, shows warnings instead of raising errors when operation fails.
    ...                                ${file_format} - Specifies a file format (RAML2/CSV/XLSX).
    ...                                ${timeout} - Timeout for executing operation.
    ...                                ${ui_values} - Specifies if the file should be imported with UI parameters' values.
    ...                Output:         None
    ...                Author:         marek.starzyk@nokia.com
    [Arguments]        ${nms_lab_ip}    ${file_name}    ${local_dir}    ${plan_name}    ${operation_type}=plan
    ...                ${verbose}=True  ${ignore_errors}=False    ${file_format}=RAML2  ${timeout}=900
    ...                ${ui_values}=${None}
    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    Log    \nImport ${plan_name} into the lab    console=${True}
    nms.Import configuration
    ...    file_name=${file_name}
    ...    local_dir=${local_dir}
    ...    plan_name=${plan_name}
    ...    operation_type=${operation_type}
    ...    verbose=${verbose}
    ...    ignore_errors=${ignore_errors}
    ...    file_format=${file_format}
    ...    timeout=${timeout}
    ...    ui_values=${ui_values}
    Log    \nImport ${plan_name} has been finished    console=${True}
    [Teardown]    nms.Delete Node    service_name=cmwas

################################################ Supplementary Keywords ################################################

_Get Active SW For NMS Integration
    [Documentation]    Description:    Gets active SW version and converts it to format needed in NMS integration.
    ...                Input:          hw_type = vDU / vCU
    ...                Output:         SW version in format "25R1VDU"
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${hw_type}=${None}
    @{version_info}=    connections.Get Software Version    hw_type=${hw_type}
    ${release}=    Set Variable    ${version_info}[1]
    IF    '${hw_type}'=='vDU'
        RETURN    ${release}VDU
    ELSE IF    '${hw_type}'=='vCU'
        RETURN    ${release}VCU
    ELSE IF    '${hw_type}'=='FHGW'
        RETURN    FHGW${release}
    ELSE
        Fail    msg=hw_type doesn't exist
    END

_Connect To NMS
    [Documentation]    Description:    Connects to cmwas node of selected NMS lab and adds web user interface data.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${nms_lab_ip}

    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${web_url} =    nms.Detect Web Url
    nms.Add Web Url    web_url=${web_url}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}

_Prepare SW on NMS lab
    [Documentation]    Description:    Keyword checks if SW build is already imported into NMS lab. If not, downloads
    ...                                it to local machine and imports to NMS lab.
    ...                Input:          sw_version = exact sw build to import, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                nop_type = nokia-sync-operator / ran-nic-sw-controller / koredump-operator-vdu /
    ...                                koredump-operator-vcu / cnf-lcm-operator-vdu / cnf-lcm-operator-vcu.
    ...                                Only if downloading NOP SW.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${sw_version}    ${nms_lab_ip}    ${nop_type}=${None}    ${mo_type}=CNF

    ${is_build_on_nms_lab} =    _Check If SW is present on NMS lab    ${sw_version}    ${nms_lab_ip}    ${mo_type}
    @{nop_list}    Create List    nokia-sync-operator      ran-nic-sw-controller    koredump-operator-vdu
    ...                           koredump-operator-vcu    cnf-lcm-operator-vdu     cnf-lcm-operator-vcu
    IF   '${is_build_on_nms_lab}' == '${False}'
        Log    \n${sw_version} is not present on NMS lab.    console=${True}
        IF    "${nop_type}" in "@{nop_list}"
            _Check Available Space On NMS lab    nms_lab_ip=${nms_lab_ip}    space_required=1
        ELSE
            _Check Available Space On NMS lab    nms_lab_ip=${nms_lab_ip}
        END
        IF   '${mo_type}' == 'FHGW'
            ${sw_version}=    Replace String Using Regexp    ${sw_version}    _[^_]*$    ${EMPTY}
        END
        ${sw_version}=    _Download SW To NMS Lab        nms_lab_ip=${nms_lab_ip}    sw_version=${sw_version}    nop_type=${nop_type}
        _Import SW build to NMS lab    nms_lab_ip=${nms_lab_ip}    sw_version=${sw_version}    mo_type=${mo_type}
    ELSE
        Log    \n${sw_version} is already present on NMS lab    console=${True}
    END
    [Return]  ${sw_version}

_Prepare FHGW SW Version for Lab
    [Documentation]    Description:    Unpacks the specified software version, prepares it for import to the lab, and cleans up temporary files.
    ...                Input:          sw_version = The exact software version to unpack, for example: FHGW26R2_003
    ...                Output:         fhgw_sw = Name of the unpacked software file.
    ...                Author:         roscislaw.szuminski@gmail.com
    [Arguments]  ${sw_version}
    Log    Unpack ${sw_version} before import to the lab.    console=${True}
    ${storage_dir}=       Set Variable    /d/oss/global/swmanager/swm_temp/
    ${package_path}=      Set Variable    /${storage_dir}/${sw_version}.zip
    ${unzip_command}=     Set Variable    cd ${storage_dir} && unzip -q ${package_path}
    ssh.Execute  ${unzip_command}
    Log   Unpack ${sw_version} finished   console=${True}
    ${grep_zip_command}=  Set Variable    cd ${storage_dir}/${sw_version} && ls *.zip | xargs basename -s .zip | tr -d '\n'
    ${fhgw_sw}=           ssh.Execute     ${grep_zip_command}
    ${copy_command}=      Set Variable    cp -r ${storage_dir}/${sw_version}/${fhgw_sw}.zip ${storage_dir}
    ssh.Execute  ${copy_command}
    ssh.Execute  rm -r ${storage_dir}/${sw_version}
    ssh.Execute  rm -r ${storage_dir}/${sw_version}.zip
    [Return]    ${fhgw_sw}

_Check If SW is present on NMS lab
    [Documentation]    Description:    Keyword checks if SW build is already imported in NMS lab.
    ...                Input:          sw_version = exact sw build to check, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                mo_type = managed object type. Default is CNF.
    ...                Output:         TRUE if SW build is present, FALSE if not.
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${sw_version}    ${nms_lab_ip}    ${mo_type}=CNF

    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${result} =     nms.is_imported    version_id=${sw_version}    mo_type=${mo_type}
    [Return]      ${result}
    [Teardown]    nms.Delete Node    service_name=cmwas

_Check Available Space On NMS lab
    [Documentation]    Description:    Checks if there is enough available space on NMS lab for SW import.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                space_required = minimum space required for unpacked software. Default is 20GB.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${nms_lab_ip}    ${space_required}=20

    ssh.Connect To    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${output} =         ssh.Execute    df -h --output=avail /var/opt/nokia/oss/global/swm/swm_arch/ | tail -n +2
    ${avail_space} =    Fetch From Left     string=${output}    marker=G
    ${avail_space} =    Convert To Number    ${avail_space}
    Log    \nAvailable space on NMS lab is ${avail_space} GB.    console=${True}
    Should Be True    ${avail_space} >= ${space_required}    msg=At least ${space_required}GB is required to import software.
    [Teardown]    ssh.Disconnect

_Download SW To NMS Lab
    [Documentation]    Description:    Downloads SW from espoo artifactory directly to temp storage of NMS lab.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                sw_version = exact sw build to download, for example: vDUCNF00_0.300.27343-amd64
    ...                                nop_type = nokia-sync-operator / ran-nic-sw-controller / koredump-operator-vdu /
    ...                                koredump-operator-vcu / cnf-lcm-operator-vdu / cnf-lcm-operator-vcu.
    ...                                Only if downloading NOP SW.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${nms_lab_ip}    ${sw_version}    ${nop_type}=${None}

    Log    Downloading ${sw_version} to NMS Lab.    console=${True}
    IF    '${nop_type}' in ['koredump-operator-vdu', 'koredump-operator-vcu']
        ${nop_type} =    Set Variable    koredump-operator
    END
    IF    '${nop_type}' in ['cnf-lcm-operator-vdu', 'cnf-lcm-operator-vcu']
        ${nop_type} =    Set Variable    cnf-lcm-operator
    END
    IF    '${nop_type}' in ['nokia-sync-operator', 'ran-nic-sw-controller', 'koredump-operator', 'cnf-lcm-operator']
        ${primary_artifactory_url} =    Set Variable    ${espoo1_artifactory}/artifactory/rcp-infra-local
        ${secondary_artifactory_url} =  Set Variable    ${espoo3_artifactory}/artifactory/rcp-infra-local
        ${download_url} =               Set Variable    ${primary_artifactory_url}/${nop_type}/${sw_version}.zip
        ${secondary_download_url} =     Set Variable    ${secondary_artifactory_url}/${nop_type}/${sw_version}.zip
    ELSE IF    '${nop_type}'=='FHGW'
        ${release} =                    Fetch From Left    string=${sw_version}    marker=_
        ${build} =                      Fetch From Left    string=${sw_version}    marker=-
        ${primary_artifactory_url} =    Set Variable       ${artifactory-blr1}/artifactory/fhgw-releasedbuilds/builds
        ${download_url}=                Set Variable       ${primary_artifactory_url}/${release}/${build}/${sw_version}.zip
        ${secondary_download_url} =     Set Variable       ${primary_artifactory_url}
    ELSE
        ${release} =                    Fetch From Left    string=${sw_version}    marker=_
        ${build} =                      Fetch From Left    string=${sw_version}    marker=-
        ${primary_artifactory_url} =    Set Variable    ${espoo3_artifactory}/artifactory/mnp5g-central-public-local/System_Release
        ${secondary_artifactory_url} =  Set Variable    ${espoo1_artifactory}/artifactory/mnp5g-central-public-local/System_Release
        ${download_url} =               Set Variable    ${primary_artifactory_url}/${release}/${build}/${sw_version}.zip
        ${secondary_download_url} =     Set Variable    ${secondary_artifactory_url}/${release}/${build}/${sw_version}.zip
    END
    ${wget_cmd} =    Set Variable    wget --user ca_vrf_wro35_auto --password Wr035@ut0 --no-check-certificate ${download_url}
    ${secondary_wget_cmd} =    Set Variable    wget --user ca_vrf_wro35_auto --password Wr035@ut0 --no-check-certificate ${secondary_download_url}
    ${download_sw_cmd} =    Set Variable    cd /d/oss/global/swmanager/swm_temp/ && ${wget_cmd} && chmod 644 ${sw_version}.zip
    ${secondary_download_sw_cmd} =    Set Variable    cd /d/oss/global/swmanager/swm_temp/ && ${secondary_wget_cmd} && chmod 644 ${sw_version}.zip
    ssh.Connect To    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    TRY
        ssh.Execute    ${download_sw_cmd}
        ssh.Assert Exit Status    expected_exit_code=0    msg=Downloading SW build from primary repository failed.
    EXCEPT
        Log    Primary repository download failed, attempting secondary repository.    console=${True}
        ssh.Execute    ${secondary_download_sw_cmd}
        ssh.Assert Exit Status    expected_exit_code=0    msg=Downloading SW build from secondary repository failed.
    END
    Log    Download Finished.    console=${True}
    IF    '${nop_type}'=='FHGW'
        ${fhgw_sw}=       _Prepare FHGW SW Version for Lab           ${sw_version}
    END
    ${sw_version}=        Set Variable If  '${nop_type}'=='FHGW'     ${fhgw_sw}      ${sw_version}
    [Return]      ${sw_version}
    [Teardown]    ssh.Disconnect

_Import SW build to NMS lab
    [Documentation]    Description:    Imports downloaded SW build from NMS lab temp storage.
    ...                Input:          sw_version = exact sw build to import, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                mo_type = managed object type of SW. Default is CNF.
    ...                                distribute_to_ccr = True / False. Distribution to CCR during SW import.
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${sw_version}    ${nms_lab_ip}    ${mo_type}=CNF    ${distribute_to_ccr}=${True}

    nms.Add Node    service_name=cmwas    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    Log    Importing SW build ${sw_version}.    console=${True}
    ${result} =    nms.Import Build    build_or_file_path=${sw_version}.zip    mo_type=${mo_type}
    ...                                version_id=${sw_version}   ccr=${distribute_to_ccr}    clean_temp_storage=${True}
    Log    Import finished.    console=${True}
    [Teardown]     nms.Delete Node     service_name=cmwas

_Check If Object Is Integrated
    [Documentation]    Description:    Checks in Monitor app if object with given DN is integrated.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                object_dn = DN of object to check, for example PLMN-PLMN/CLOUD-8777
    ...                Output:         True / False depending on integration status.
    ...                Author:         damian.kotula@nokia.com
    [Arguments]     ${nms_lab_ip}    ${object_dn}

    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    ${integrated_objects} =    nms.Get Objects From Monitor    mo_class=*[dn() = '${object_dn}']
    IF    ${integrated_objects} == ['${object_dn}']
        Log    \nObject ${object_dn} is already integrated.    console=${True}
        RETURN    ${True}
    ELSE
        Log    \nObject ${object_dn} is not integrated.    console=${True}
        RETURN    ${False}
    END
    [Teardown]    nms.Delete Node    service_name=cmwas

_Add Certificates to OCP
    [Documentation]    Description:    Adds certificates to OCP for given NMS lab. Precondition for deployment.
    ...                Input:          nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                hw_type = vDU / vCU
    ...                                id = ID of the hw_type (e.g. 2); default: Empty
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_number}    ${nms_lab_ip}    ${hw_type}=${None}    ${id}=${Empty}

    IF    ${nms_lab_number} in ${TAMPERE_LABS}
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srntre.nsn-rdnet.net
    ELSE
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srnblr.nsn-rdnet.net
    END
    ${cert_dir} =    Set Variable    /var/home/core/${nms_lab_number}cert
    ${configmap_name} =    Set Variable    registry-clab${nms_lab_number}
    ${get_password_cmd} =    Set Variable   /opt/nokia/oss/bin/syscredacc.sh -user ccradmin -type DB -instance CCR
    ${open_ssl_cmd} =    Set Variable    openssl s_client -showcerts -connect ${nms_link}:8443 </dev/null 2>/dev/null

    ssh.Connect To    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}    alias=nms
    ${password} =    ssh.Execute     ${get_password_cmd}    connection=nms
    ${password} =    Strip String    ${password}
    ssh.Disconnect    connection=nms

    ssh.Connect To    hostname=${SSH_K8S_${hw_type}${id}_IP}    username=${SSH_K8S_USERNAME}    password=${SSH_K8S_PASSWORD}
    ssh.Execute    mkdir ${cert_dir}
    ${download_cert_output} =   ssh.Execute    ${open_ssl_cmd} | openssl x509 -outform PEM >${cert_dir}/ca.crt
    IF    "Unable to load certificate" in """${download_cert_output}"""
        ${second_try} =   ssh.Execute    ${open_ssl_cmd} | openssl x509 -outform PEM >${cert_dir}/ca.crt
        IF    "Unable to load certificate" in """${second_try}"""
            Fatal Error    msg=Failed to load certificate to OCP. Try adding it manually.
        END
    END
    ssh.Execute    oc create configmap ${configmap_name} -n openshift-config --from-file=${nms_link}..8443=${cert_dir}/ca.crt
    ssh.Execute    oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"${configmap_name}"}}}' --type=merge
    ssh.Execute    oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > global_pull_secret
    ssh.Execute    oc registry login --registry="${nms_link}:8443" --auth-basic="admin:${password}" --to=temp_pull_secret
    ssh.Execute    jq -s '.[0] * .[1]' global_pull_secret temp_pull_secret > merged_pull_secret
    ssh.Execute    oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=merged_pull_secret
    _Add Certificates To Each Node   nms_lab_number=${nms_lab_number}
    [Teardown]     ssh.Disconnect

_Remove Certificates from OCP
    [Documentation]    Description:    Removes certificates from OCP for given NMS lab.
    ...                Input:          nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                hw_type = vDU / vCU
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${nms_lab_number}    ${hw_type}=${None}

    ${cert_dir} =    Set Variable    /var/home/core/${nms_lab_number}cert
    ${configmap_name} =    Set Variable    registry-clab${nms_lab_number}

    ssh.Connect To    hostname=${SSH_K8S_${hw_type}_IP}    username=${SSH_K8S_USERNAME}    password=${SSH_K8S_PASSWORD}
    _Remove Certificates From Each Node    nms_lab_number=${nms_lab_number}
    ssh.Execute    oc delete configmap ${configmap_name} -n openshift-config
    ssh.Execute    oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":null}}' --type=merge
    ssh.Execute    rm -rf ${cert_dir}
    ssh.Disconnect

_Add Certificates To Each Node
    [Documentation]    Description:    Adds certificates to each node for given NMS lab. Precondition for deployment.
    ...                Input:          nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                Output:         none
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${nms_lab_number}
    Log   \nStart Adding Certificates To Each Node  console=${True}
    IF    ${nms_lab_number} in ${TAMPERE_LABS}
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srntre.nsn-rdnet.net:8443
    ELSE
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srnblr.nsn-rdnet.net:8443
    END
    ${main_cert_path}=   Set Variable    /var/home/core/${nms_lab_number}cert/ca.crt
    ${node_cert_path}=   Set Variable    /etc/containers/certs.d/${nms_link}
    ${nodes_view}=       ssh.Execute  oc get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
    ${nodes_ip}=         Split String      ${nodes_view}    ${SPACE}
    FOR  ${node_ip}  IN  @{nodes_ip}
         ssh.Execute   ssh -o StrictHostKeyChecking=no core@${node_ip} "sudo mkdir -p ${node_cert_path}"
         ssh.Execute   cat ${main_cert_path} | ssh -o StrictHostKeyChecking=no core@${node_ip} "sudo tee ${node_cert_path}/ca.crt > /dev/null"
    END
    Log  Adding Certificates To Each Node Finished  console=${True}

_Remove Certificates From Each Node
    [Documentation]    Description:    Removes certificates for each node for given NMS lab.
    ...                Input:          nms_lab_number = id number of selected NMS Lab, for example: 1028
    ...                Output:         none
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${nms_lab_number}
    IF    ${nms_lab_number} in ${TAMPERE_LABS}
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srntre.nsn-rdnet.net:8443
    ELSE
        ${nms_link} =    Set Variable    srnclab${nms_lab_number}lcm.srnblr.nsn-rdnet.net:8443
    END
    ${node_cert_path}=   Set Variable    /etc/containers/certs.d/${nms_link}
    ${nodes_view}=       ssh.Execute     oc get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
    ${nodes_ip}=         Split String    ${nodes_view}    ${SPACE}
    FOR  ${node_ip}  IN  @{nodes_ip}
         ssh.Execute   ssh -o StrictHostKeyChecking=no core@${node_ip} "sudo rm -rf ${node_cert_path}"
    END

_Get Config File From K8s Server
    [Documentation]    Description:    Keyword downloads config file from K8s server to local machine.
    ...                Input:          destination_path = path where file will be saved. Test output folder by default.
    ...                                hw_type = vDU / vCU
    ...                                id = ID of the hw_type (e.g. 2); default: Empty
    ...                Output:         path to downloaded config file.
    ...                Author:         damian.kotula@nokia.com

    [Arguments]        ${destination_path}=${OUTPUT DIR}/    ${hw_type}=${None}    ${id}=${Empty}
    Connect to K8s via SSH          hw_type=${hw_type}    id=${id}
    SSHLibrary.File Should Exist    path=/var/home/core/.kube/config
    SSHLibrary.Get File             source=/var/home/core/.kube/config    destination=${destination_path}
    [Teardown]    Disconnect from K8s via SSH
    [Return]      ${destination_path}/config

_Get Chart Versions From SW In NMS
    [Documentation]    Description:    Keyword gets exact chart names from planned SW which is needed for deployment.
    ...                Input:          sw_version = exact sw build to be used, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                Output:         cluster_chart_ver = name of cluster preparation chart in choosen sw build
    ...                                prerequisite_chart_ver = name of prerequisites chart in choosen sw build
    ...                                main_chart_ver = name of main chart in choosen sw build
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${sw_version}    ${nms_lab_ip}

    ssh.Connect To    hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${output} =    ssh.Execute    ls /d/oss/global/var/swm/swm_arch/${sw_version}/extracted/HelmChart | grep tgz
    ${files} =     Split String    ${output}    \r\n
    FOR    ${file}    IN    @{files}
        IF    'cluster' in '${file}'
            ${cluster_chart_ver} =    Set Variable    ${file}
        ELSE IF    'prerequisite' in '${file}'
            ${prerequisite_chart_ver} =    Set Variable    ${file}
        END
    END
    ${main_chart_ver} =    Get Regexp Matches    ${output}    aic-v[cd]u-\\d+\\.\\d+\\.\\d+\\.tgz
    [Teardown]    ssh.Disconnect
    [Return]      ${cluster_chart_ver}    ${prerequisite_chart_ver}    ${main_chart_ver[0]}

_Download Charts For NOPs From NMS
    [Documentation]    Description:    Downloads chart for NOPs deployment from SW package on NMS lab to local machine.
    ...                Input:          sw_version = exact sw build to be used, for example: nokia-sync-operator_5.1.0-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                Output:         version = chart version in choosen sw build
    ...                                output_path = path to chart downloaded on VM
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${sw_version}    ${nms_lab_ip}

    ${remote_dir} =    Set Variable    /d/oss/global/var/swm/swm_arch/${sw_version}/extracted/HelmChart
    ssh.Connect To     hostname=${nms_lab_ip}    username=${NMS_USERNAME}    password=${NMS_PASSWORD}
    ${version} =       ssh.Execute     ls ${remote_dir} | grep tgz
    ${version} =       Strip String    ${version}
    ${chart} =         ssh.Execute     ls ${remote_dir} | grep yaml
    ${chart} =         Strip String    ${chart}
    ssh.Download File    remote_path=${remote_dir}/${chart}    local_path=${OUTPUT DIR}/${chart}
    [Teardown]    ssh.Disconnect
    [Return]      ${version}    ${OUTPUT DIR}/${chart}

_Prepare Deployment Plan
    [Documentation]    Description:    Keyword to create deployment plan with CNF managed object in CM Editor.
    ...                                Supports deployment of vCU, vDU, Nokia Sync Operator and Ran Nic Sw Controller.
    ...                                Yaml charts used for vCU/vDU deployment should be filled out and
    ...                                passed in parameters. KW uses variables from init.py, so it should be filled out
    ...                                and passed in during test run.
    ...                Input:          sw_version = exact sw build to be used, for example: vDUCNF00_0.300.27343-amd64
    ...                                nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                registry_link = registry link of particular NMS lab, for example:
    ...                                                srnclab1028lcm.srnblr.nsn-rdnet.net:8443/project1
    ...                                hw_type = vDU / vCU if deploying CNF. Default is None.
    ...                                nop_type = nokia-sync-operator / ran-nic-sw-controller / koredump-operator-vdu /
    ...                                           koredump-operator-vcu / cnf-lcm-operator-vdu / cnf-lcm-operator-vcu
    ...                                           if deploying one of Nokia Operators (NOP).
    ...                Output:         none
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${sw_version}  ${nms_lab_ip}  ${registry_link}  ${hw_type}=${None}  ${nop_type}=${None}  ${blue_green}=${False}
    #Setting Variables
    IF    '${nop_type}' == 'nokia-sync-operator'
        ${cnf_name} =        Set Variable    CNF-${MRBTS}02
    ELSE IF    '${nop_type}' == 'ran-nic-sw-controller'
        ${cnf_name} =        Set Variable    CNF-${MRBTS}03
    END
    IF    '${nop_type}' == 'ran-nic-sw-controller' or '${nop_type}' == 'nokia-sync-operator'
        ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
        ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${namespace} =           Set Variable    ${nop_type}
        ${deploy_plan_name} =    Set Variable    ${MRBTS}_${nop_type}_auto_deployment_plan
    END
    IF    '${nop_type}' == 'koredump-operator-vdu'
            ${cnf_name} =            Set Variable    CNF-${MRBTS}04
            ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
            ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
            ${namespace} =           Set Variable    koredump-operator
            ${deploy_plan_name} =    Set Variable    ${MRBTS}_${nop_type}_auto_deployment_plan
    END
    IF    '${nop_type}' == 'koredump-operator-vcu'
            ${cnf_name} =            Set Variable    CNF-${MRBTS_CU}04
            ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS_CU}
            ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
            ${namespace} =           Set Variable    koredump-operator
            ${deploy_plan_name} =    Set Variable    ${MRBTS_CU}_${nop_type}_auto_deployment_plan
    END
    IF    '${nop_type}' == 'cnf-lcm-operator-vdu'
            ${cnf_name} =            Set Variable    CNF-${MRBTS}05
            ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
            ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS}05
            ${namespace} =           Set Variable    cnf-lcm-operator
            ${deploy_plan_name} =    Set Variable    ${MRBTS}_${nop_type}_auto_deployment_plan
    END
    IF    '${nop_type}' == 'cnf-lcm-operator-vcu'
            ${cnf_name} =            Set Variable    CNF-${MRBTS_CU}05
            ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS_CU}
            ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}05
            ${namespace} =           Set Variable    cnf-lcm-operator
            ${deploy_plan_name} =    Set Variable    ${MRBTS_CU}_${nop_type}_auto_deployment_plan
    END
    IF    '${hw_type}' == 'vDU'
        ${cnf_name} =            Set Variable    CNF-${MRBTS}
        ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS}
        IF  ${blue_green}
            ${container_registry}=    Create List    PLMN-PLMN/CONTAINER_REGISTRY-1
        END
        ${namespace} =           Set Variable    ${CRAN_VDU}
        ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${deploy_plan_name} =    Set Variable    ${MRBTS}_auto_deployment_plan
        ${main_chart} =          Set Variable    ${tl.gnbs[0].dus[0].cloud_deployment.cnf.yaml_file}
        ${prerequisites_chart} =    Set Variable    ${tl.gnbs[0].dus[0].cloud_deployment.prerequisite.yaml_file}
        ${cluster_preparation_chart} =    Set Variable    ${tl.gnbs[0].dus[0].cloud_deployment.cluster_preparation.yaml_file}
    ELSE IF    '${hw_type}' == 'vCU'
        ${cnf_name} =            Set Variable    CNF-${MRBTS_CU}
        ${cloud_dn} =            Set Variable    PLMN-PLMN/CLOUD-${MRBTS_CU}
        IF  ${blue_green}
            ${container_registry}=    Create List    PLMN-PLMN/CONTAINER_REGISTRY-1
        END
        ${namespace} =           Set Variable    ${CRAN_VCU}
        ${neRelId} =             Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${deploy_plan_name} =    Set Variable    ${MRBTS_CU}_auto_deployment_plan
        ${main_chart} =          Set Variable    ${tl.gnbs[0].cloud_deployment.cnf.yaml_file}
        ${prerequisites_chart} =    Set Variable    ${tl.gnbs[0].cloud_deployment.prerequisite.yaml_file}
        ${cluster_preparation_chart} =    Set Variable    ${tl.gnbs[0].cloud_deployment.cluster_preparation.yaml_file}
    END
    ${cnf_dn} =    Set Variable    PLMN-PLMN/${cnf_name}
    ${actual_conf} =     nms.Get Actual Configuration
    ${object_exist} =    Run Keyword And Return Status    nms.Get Managed Object    configuration=${actual_conf}
    ...                                                   mo_id=PLMN-PLMN/${cnf_name}
    IF    ${object_exist}    Fail    msg=CNF with name ${cnf_name} already exists in NMS. Terminate deployment first.

    #Preparing Charts
    @{nop_list}    Create List    nokia-sync-operator      ran-nic-sw-controller    koredump-operator-vdu
    ...                           koredump-operator-vcu    cnf-lcm-operator-vdu     cnf-lcm-operator-vcu
    IF    "${nop_type}" in "@{nop_list}"
        ${chart_version}    ${nop_chart_path} =    _Download Charts For NOPs From NMS    sw_version=${sw_version}
        ...                                                                              nms_lab_ip=${nms_lab_ip}
        ${chart_base64} =    Update Registry And Convert To Base64    path=${nop_chart_path}
        ...                                                           registry_link=${registry_link}
        @{deployment_profiles} =    Create List
        &{nop_chart} =    Create Dictionary
        Set To Dictionary    ${nop_chart}    chart=${chart_version}    releaseName=${nop_type}-nms
        ...                                  order=0                   values=${chart_base64}
        Append To List    ${deployment_profiles}    ${nop_chart}
        Log    ${deployment_profiles}
    END
    IF    '${hw_type}' == 'vDU' or '${hw_type}' == 'vCU'
        ${cluster_chart_ver}    ${prereq_chart_ver}    ${main_chart_ver} =          _Get Chart Versions From SW In NMS
        ...                                                                         sw_version=${sw_version}
        ...                                                                         nms_lab_ip=${nms_lab_ip}
        ${main_chart_base64} =             Update Registry And Convert To Base64    path=${main_chart}
        ...                                                                         registry_link=${registry_link}
        ${prerequisites_chart_base64} =    Update Registry And Convert To Base64    path=${prerequisites_chart}
        ...                                                                         registry_link=${registry_link}
        ${cluster_chart_base64} =          Convert YAML To Base64                   file_path=${cluster_preparation_chart}
        @{deployment_profiles} =           Create List
        &{chart1} =    Create Dictionary
        &{chart2} =    Create Dictionary
        &{chart3} =    Create Dictionary
        Set To Dictionary    ${chart1}    chart=${cluster_chart_ver}    releaseName=${hw_type.lower()}-cluster-preparation-nms
        ...                               order=0                       values=${cluster_chart_base64}
        Set To Dictionary    ${chart2}    chart=${prereq_chart_ver}     releaseName=${hw_type.lower()}-prerequisite-nms
        ...                               order=1                       values=${prerequisites_chart_base64}
        Set To Dictionary    ${chart3}    chart=${main_chart_ver}       releaseName=${hw_type.lower()}-main-nms
        ...                               order=2                       values=${main_chart_base64}
        Append To List    ${deployment_profiles}    ${chart1}    ${chart2}    ${chart3}
        Log    ${deployment_profiles}
    END

    #Creating Plan
    IF  ${blue_green}
        ${deployment_plan} =    nms.Create Plan Configuration    name=${deploy_plan_name}
        nms.Create Managed Object    plan=${deployment_plan}     mo_id=${cnf_dn}     meta_class=com.nokia.cnf.lcm:CNF
        ...                          meta_version=CNF2.0         operation=CREATE    cloudId=${cloud_dn}
        ...                          containerRegistries=${container_registry}  cnfSwId=${sw_version}  name=${cnf_name}  namespace=${namespace}
        ...                          neRelId=${neRelId}          deploymentProfile=${deployment_profiles}
    ELSE IF    '${nop_type}' in ['cnf-lcm-operator-vdu', 'cnf-lcm-operator-vcu']
        ${deployment_plan} =    nms.Create Plan Configuration    name=${deploy_plan_name}
        nms.Create Managed Object    plan=${deployment_plan}     mo_id=${cnf_dn}     meta_class=com.nokia.cnf.lcm:CNF
        ...                          meta_version=CNF2.0         operation=CREATE    cloudId=${cloud_dn}
        ...                          cnfSwId=${sw_version}       name=${cnf_name}    namespace=${namespace}
        ...                          neRelId=${neRelId}          deploymentProfile=${deployment_profiles}
        ...                          type=NOP_cnf-lcm-operator
    ELSE
        ${deployment_plan} =    nms.Create Plan Configuration    name=${deploy_plan_name}
        nms.Create Managed Object    plan=${deployment_plan}     mo_id=${cnf_dn}     meta_class=com.nokia.cnf.lcm:CNF
        ...                          meta_version=CNF2.0         operation=CREATE    cloudId=${cloud_dn}
        ...                          cnfSwId=${sw_version}       name=${cnf_name}    namespace=${namespace}
        ...                          neRelId=${neRelId}          deploymentProfile=${deployment_profiles}
    END
    nms.Export Configuration    file_name=${deploy_plan_name}    local_dir=${OUTPUT DIR}    dist_names=${cnf_dn}
    ...                         operation_type=plan    plan_name=${deploy_plan_name}
    [Return]    ${deploy_plan_name}

_Prepare Upgrade Plan
    [Arguments]    ${sw_version}    ${hw_type}=${None}    ${nop_type}=${None}
    [Documentation]    Description:    This keyword prepares an upgrade plan for a CNF based on the provided software
     ...                               version, hardware type, and NOP type.
    ...                Input:          ${sw_version} - The software version to be used in the upgrade plan.
    ...                                ${hw_type} - The hardware type (e.g., vDU or vCU). Default is None.
    ...                                ${nop_type} - The type of NOP (e.g., nokia-sync-operator / ran-nic-sw-controller
    ...                                koredump-operator-vdu / koredump-operator-vcu). Default is None.
    ...                Output:         Creates an upgrade plan and sets suite variables for the plan name, CNF name, CNF DN, and rollback plan name.
    ...                Notes:          Ensure that the variables ${MRBTS} and ${MRBTS_CU} are properly defined before calling this keyword.
    ...                Author:         damian.kotula@nokia.com
    Log    Starting to prepare upgrade plan       console=${True}
    ${current_date}      Get Current Date  result_format=%d_%m_%Y_%H_%M
    Set Test Variable    ${CURRENT_DATE}      ${current_date}
    IF    '${nop_type}' == 'nokia-sync-operator'
        Set Suite Variable         ${upgrade_plan_name}       ${MRBTS}02_auto_upgrade_plan
        Set Suite Variable         ${cnf_name}                 CNF-${MRBTS}02
    ELSE IF    '${nop_type}' == 'ran-nic-sw-controller'
        Set Suite Variable         ${upgrade_plan_name}        ${MRBTS}03_auto_upgrade_plan
        Set Suite Variable         ${cnf_name}                  CNF-${MRBTS}03
    ELSE IF    '${nop_type}' == 'koredump-operator-vdu'
        Set Suite Variable         ${upgrade_plan_name}        ${MRBTS}04_auto_upgrade_plan
        Set Suite Variable         ${cnf_name}                  CNF-${MRBTS}04
    ELSE IF    '${nop_type}' == 'koredump-operator-vcu'
        Set Suite Variable         ${upgrade_plan_name}        ${MRBTS_CU}04_auto_upgrade_plan
        Set Suite Variable         ${cnf_name}                  CNF-${MRBTS_CU}04
    END
    IF    '${hw_type}' == 'vDU'
        Set Suite Variable    ${upgrade_plan_name}     ${MRBTS}_auto_upgrade_plan_${CURRENT_DATE}
        Set Suite Variable    ${cnf_name}              CNF-${MRBTS}
    ELSE IF    '${hw_type}' == 'vCU'
         Set Suite Variable    ${upgrade_plan_name}     ${MRBTS_CU}_auto_upgrade_plan_${CURRENT_DATE}
         Set Suite Variable    ${cnf_name}              CNF-${MRBTS_CU}
    END
         Set Suite Variable    ${cnf_dn}                PLMN-PLMN/${cnf_name}
         Set Suite Variable    ${rollback_plan_name}    ${MRBTS}_rollback_before_${sw_version}_${CURRENT_DATE}
    nms.Create Cnf Upgrade Plan    plan_name=${upgrade_plan_name}    dist_names=${cnf_dn}    cnf_sw_id=${sw_version}

_Prepare Blue Green Upgrade Plan
    [Arguments]  ${sw_version}  ${hw_type}=${None}  ${additional_values}=${False}
    [Documentation]    Description:    This keyword prepares an blue-green upgrade plan for a CNF based on the provided software
     ...                               version, hardware type.
    ...                Input:          ${sw_version} - The software version to be used in the upgrade plan.
    ...                                ${hw_type} - The hardware type (e.g., vDU or vCU). Default is None.
    ...                                ${additional_values} - The ability to modify the deployment of an
    ...                                                       existing CNF vCU using a blue/green upgrade mechanism.
    ...                Output:         Creates blue green upgrade plan and sets suite variables for the plan name, blue and green dist names,
    ...                                namespace, and rollback plan name.
    ...                Author:         roscislaw.szuminski@nokia.com
    Log    \nStarting to prepare blue-green upgrade plan       console=${True}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}
    ssh.Connect To   hostname=${nms_lab_ip}  username=${NMS_USERNAME}  password=${NMS_PASSWORD}
    IF  '${hw_type}' == 'vDU'
        Set Suite Variable    ${upgrade_plan_name}     ${MRBTS}_auto_upgrade_plan
        Set Suite Variable    ${blue_dist_name}         PLMN-PLMN/CNF-${MRBTS}
        Set Suite Variable    ${green_dist_name}        PLMN-PLMN/CNF-${MRBTS}99
        Set Suite Variable    ${namecpace}              ${CRAN_VDU}99
    ELSE IF    '${hw_type}' == 'vCU'
         Set Suite Variable    ${upgrade_plan_name}     ${MRBTS_CU}_auto_upgrade_plan
         Set Suite Variable    ${blue_dist_name}         PLMN-PLMN/CNF-${MRBTS_CU}
         Set Suite Variable    ${green_dist_name}        PLMN-PLMN/CNF-${MRBTS_CU}99
         Set Suite Variable    ${namecpace}              ${CRAN_VCU}99
    END
        ${bg_dist_names}=  Create List  ${blue_dist_name}  ${green_dist_name}
        ${gb_dist_names}=  Create List  ${green_dist_name}  ${blue_dist_name}
        Set Suite Variable    ${bg_dist_names}
        Set Suite Variable    ${gb_dist_names}
        Set Suite Variable    ${rollback_plan_name}    ${MRBTS}_rollback_before_${sw_version}
    IF  ${additional_values}
        ${additional_values_path}=  Set Variable  /home/ute/testline_configuration/${hostname}/common_helm_values/additional_values.yaml
        ssh.Upload File  ${additional_values_path}  /var/opt/oss/global/racops/import/additional_values.yaml
        ${parameters}=  Create Dictionary  -mainChartValuesFileChooser=${additional_values_path}
        nms.Prepare Sw Upgrade Plan Cnf Blue Green  plan_name=${upgrade_plan_name}  blue_dist_name=${blue_dist_name}
        ...  green_dist_name=${green_dist_name}  cnf_sw_id=${sw_version}  namespace=${namecpace}  parameters=${parameters}
    ELSE
        nms.Prepare Sw Upgrade Plan Cnf Blue Green  plan_name=${upgrade_plan_name}  blue_dist_name=${blue_dist_name}
        ...  green_dist_name=${green_dist_name}  cnf_sw_id=${sw_version}  namespace=${namecpace}
    END
    [Teardown]  Run Keywords
    ...  ssh.Execute  rm /var/opt/oss/global/racops/import/additional_values.yaml
    ...  AND  ssh.Disconnect

_Enable Credential Management Feature
    [Documentation]    Description:    This keyword enables external credential management feature
    ...                                By default, the network element credential management APIs are not enabled in MantaRay.
    ...                Input:          ${nms_lab_ip} - cmwas node ip of selected NMS Lab.
    ...                Output:         none
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]   ${nms_lab_ip}
    ${command}=  Set Variable  externalCredentialMgmtService.sh --enable
    ssh.Connect To   hostname=${nms_lab_ip}  username=${NMS_USERNAME}  password=${NMS_PASSWORD}
    ${output}=  ssh.Execute  ${command}
    Log  \n${output}  console=${True}
    ssh.Assert Exit Status    expected_exit_code=0    msg=Flag enabling failed.

Get Chart Names
    [Documentation]    Description:    This keyword gets actual chart names, for selected hw_type.
    ...                Input:          ${hw_type} - The hardware type (e.g., vCU or vDU). Default is None.
    ...                                ${conn} - The SSH connection to the cluster. Default is None.
    ...                Output:         Returns a list of chart names that match the specified hardware type.
    ...                                Example: ['vcu-cluster-preparation-nms', 'vcu-main-nms', 'vcu-prerequisite-nms']
    ...                Author:         roscislaw.szuminski@nokia.com
    [Arguments]  ${hw_type}=${None}  ${conn}=${None}
    ${charts_output}=  ssh.Execute  helm list -A -a --output json  connection=${conn}
    ${cleaned_output}=  Strip String  ${charts_output}
    ${charts_json_data}=  Evaluate  json.loads('${cleaned_output}')
    ${deployed_charts}=  Create List
    FOR  ${item}  IN  @{charts_json_data}
        ${name}=       Get From Dictionary  ${item}  name
        ${dict_item}=  Create Dictionary  Name=${name}
        Append To List  ${deployed_charts}  ${dict_item}
    END
    ${deployed_charts}=  Evaluate  [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('${hw_type}')]
    [Return]  ${deployed_charts}

Get Deployed NOP Chart Names
    [Documentation]    Description:    This keyword gets actual chart names other than starting with 'vdu' or 'vcu'.
    ...                Input:          ${conn} - The SSH connection to the cluster. Default is None.
    ...                Output:         Returns a list of chart names that do not start with 'vdu' or 'vcu'.
    ...                                Example: ['koredump-operator-vcu-nms', 'nokia-sync-operator-nms', 'ran-nic-sw-controller-nms']
    ...                Author:         damian.kotula@nokia.com
    [Arguments]  ${conn}=${None}
    ${charts_output}=  ssh.Execute  helm list -A -a --output json  connection=${conn}
    ${cleaned_output}=  Strip String  ${charts_output}
    ${charts_json_data}=  Evaluate  json.loads('${cleaned_output}')
    ${deployed_nops}=  Create List
    FOR  ${item}  IN  @{charts_json_data}
        ${name}=       Get From Dictionary  ${item}  name
        IF    not ('${name}'.startswith('vdu') or '${name}'.startswith('vcu'))
            Append To List  ${deployed_nops}  ${name}
        END
    END
    [Return]  ${deployed_nops}

Remove Existing Charts
    [Arguments]  ${hw_type}=${None}  ${chart_name}=all  ${conn}=${None}
    [Documentation]    Description:    This keyword retrieves chart names, orders them (main, prerequisite, preparation),
    ...                                and removes the specified chart(s).
    ...                Input:          ${hw_type} - The hardware type (e.g., vCU or vDU). Default is None.
    ...                                ${chart_name} - The name of the chart to delete (e.g., main, prerequisite, preparation, or all).
    ...                                ${conn} - The SSH connection to the cluster.
    ...                Output:         Removes the specified chart(s) and logs the operation.
    Log    Removing Existing Charts       console=${True}
    ${ordred_charts}=  Create List
    ${deployed_charts}=  mantaray.Get Chart Names   hw_type=${hw_type}  conn=${conn}
    FOR  ${i}  IN  @{deployed_charts}
        ${index}=  Set Variable  0
        IF  '${i}'.endswith('prerequisite-nms') or '${i}'.endswith('prerequisite')
            ${index}=  Set Variable  1
        ELSE IF  '${i}'.endswith('preparation-nms') or '${i}'.endswith('preparation')
            ${index}=  Set Variable  2
        END
        Insert Into List  ${ordred_charts}  ${index}  ${i}
    END
    Set Test Variable  ${ordred_charts}
    Log    ${ordred_charts}    console=${True}
    Run Keyword If  '${chart_name}'=='main' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[0]} -n ${CRAN_VCU} --no-hooks  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[2]} -n ${CRAN_VCU} --no-hooks  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vcu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[1]} -n ${CRAN_VCU} --no-hooks  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='main' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[0]} -n ${CRAN_VDU} --no-hooks  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[2]} -n ${CRAN_VDU} --no-hooks  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vdu'
    ...  ssh.Execute  helm uninstall ${ordred_charts[1]} -n ${CRAN_VDU} --no-hooks  connection=${conn}
    ssh.Assert Exit Status  0  connection=${conn}

    Run Keyword If  '${chart_name}'=='all' and '${hw_type}'=='vcu'
    ...  mantaray.Delete All Charts And Namespace  hw_type=${hw_type}  namespace=${CRAN_VCU}  list_of_charts=${ordred_charts}  conn=${conn}
    ...  ELSE IF  '${chart_name}'=='all' and '${hw_type}'=='vdu'
    ...  mantaray.Delete All Charts And Namespace  hw_type=${hw_type}  namespace=${CRAN_VDU}  list_of_charts=${ordred_charts}  conn=${conn}

Delete All Charts And Namespace
    [Arguments]  ${hw_type}=${None}   ${namespace}=${None}  ${list_of_charts}=${None}  ${conn}=${None}
    [Documentation]    Description:    This keyword uninstalls all charts in the provided namespace and deletes the namespace.
    ...                Input:          ${hw_type} - The hardware type (e.g., vCU or vDU).
    ...                                ${namespace} - The namespace to delete charts from.
    ...                                ${list_of_charts} - A list of charts to uninstall.
    ...                                ${conn} - The SSH connection to the cluster.
    ...                Output:         Logs the uninstallation of each chart and deletes the namespace.
    ...                Author:         roscislaw.szuminski@nokia.com
    FOR  ${chart}  IN  @{list_of_charts}
        ssh.Execute  helm uninstall ${chart} -n ${namespace} --no-hooks  connection=${conn}
        ${status}=  Run Keyword And Return Status  ssh.Assert Exit Status  0  connection=${conn}  msg=Failed to remove ${chart}.
        IF  ${status}==False
            ssh.Execute  helm uninstall ${chart} -n ${namespace}99 --no-hooks  connection=${conn}
        END
        IF  ${status}    Log  ${chart} uninstalled  console=${true}
    END
    Delete Namespace  hw_type=${hw_type}  connection=${conn}

Delete Namespace
    [Arguments]    ${hw_type}=${None}  ${namespace}=${None}  ${connection}=${None}
    [Documentation]    Description:    This keyword deletes the namespace associated with the given hardware type.
    ...                Input:          ${hw_type} - The hardware type (e.g., vcu or vdu).
    ...                                ${connection} - The SSH connection to the cluster.
    ...                                ${namespace} - Custom namespace to delete.
    ...                Output:         Logs the deletion of the namespace.
    ...                Author:         roscislaw.szuminski@nokia.com
    ${helm_output}=  Run Keyword If  '${hw_type}'=='vcu' and '${namespace}'=='None'
    ...  ssh.Execute  kubectl delete namespaces ${CRAN_VCU}  connection=${connection}
    ...  ELSE IF  '${hw_type}'=='vdu'and '${namespace}'=='None'
    ...  ssh.Execute  kubectl delete namespaces ${CRAN_VDU}  connection=${connection}
    ...  ELSE IF  '${namespace}'!='None'
    ...  ssh.Execute  kubectl delete namespaces ${namespace}  connection=${connection}
    Log  ${helm_output}  console=${True}
