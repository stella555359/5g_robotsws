*** Settings ***
Documentation
...             == Purpose ==
...             Library to ease access/manipulations on pods/containers of Kubernetes node
...
...             == Description ==
...             *Concepts:*
...
...             A Kubernetes (K8s) Entity (vDU or vCU) is supporting several "NAMESPACEs".
...             A namespace is corresponding to a sort of particular work environment.
...             It is used to separate several logical entities on the same physical machine.
...             For a particula namespace, the vCU/vDU is containing a set of PODs (kind of VM).
...             And each Pod is supporting a container (sort of process and its context).
...
...             For instance, a K8S machine support the cran37 namespace, and contains more than 10 pods :
...             - NAME                                                     READY   STATUS    RESTARTS   AGE
...             - tl037-cran37-cprt-0                                      4/4     Running   0          2d18h
...             - tl037-cran37-lwsd-0                                      1/1     Running   0          2d18h
...             - tl037-cran37-oam-0                                       19/19   Running   0          2d18h
...             - tl037-cran37-pm-0                                        2/2     Running   0          2d18h
...             - tl037-cran37-up-0                                        5/5     Running   0          2d18h
...             - tl037-cran37-rcpfm-0                                     1/1     Running   0          2d18h
...             - tl037-cran37-rcpsdl-0                                    1/1     Running   0          2d18h
...             - ...
...             And one Pod (for instance, tl037-cran37-cprt-0) supports several containers (4, here) :
...             - tl037-cran37-nwmgmt
...             - tl037-cran37-cprt
...             - tl037-cran37-nftmgmt
...             - tl037-cran37-givaxi

...             *Mecanism:*
...
...             At dynamic discovery step, all pods and related containers are identified and store.
...             They can be used by following KWs. For each pod or container, we store its name, but we also compute its suffix.
...             The suffix is the "generic" part of the name, meaning the part after the namespace.
...
...             For instance, for "tl037-cran37-cprt-0" pod, the name is : "tl037-cran37-cprt-0" and the suffix is : "cprt-0"
...
...             *API:*
...             Following KWs hereafter are proposed to :
...             - retreive a Pod knowing its name (or suffix)
...             - retreive a Container knowing its name (or suffix) and optionally the name (or suffix of its pod)
...             - execute a command on a container

Library                             ../python/Airframes.py
Library                             ../python/OsTool.py

*** Keywords ***
K8s Get Pod
    [Documentation]                 To retrieve a pod in an entity, knowing its name or its suffix.
    ...                             name can be : tl037-cran37-cpcl-0 (full name) or cpcl-0 (suffix).
    ...                             Returned value is a reference on the concerned Pod, or None if not found.
    [Arguments]                     ${k8s}
    ...                             ${name}
    ${pod}                          call method                             ${k8s}
    ...                             getPod                                  name=${name}
    [Return]                        ${pod}

K8s Get Pod Status
    [Documentation]                 To retrieve a pod in an entity, knowing its name or its suffix.
    ...                             name can be : tl037-cran37-cpcl-0 (full name) or cpcl-0 (suffix).
    ...                             Returned value is a reference on the concerned Pod, or None if not found.
    [Arguments]                     ${k8s}
    ...                             ${name}
    ${pod}                          call method                             ${k8s}
    ...                             getPodStatus                            name=${name}
    [Return]                        ${pod}

K8s Get Container
    [Documentation]                 To retrieve a container in an entity, knowing its name or its suffix,
    ...                             and optionally the name (or suffix) of its pod.
    ...                             It will return the reference on the first matching container, or None
    ...                             name can be : tl037-cran37-cpcl (full name) or cpcl (suffix).
    [Arguments]                     ${k8s}
    ...                             ${name}
    ...                             ${podName}=${None}
    ${container}                    call method                             ${k8s}
    ...                             getContainer
    ...                             name=${name}                            podName=${podName}
    [Return]                        ${container}


K8s Container Cmd
    [Documentation]                 Execute a linux command on a container.
    ...                             Container argument should be a reference on an existing container.
    ...                             Reference to a container can be retrieved thanks to "K8s Get Container" KW.
    ...                             Returned value is the output of the command.
    ...                             In case, debug flag is activated, additional traces (command and results) will be traces into console.
    [Arguments]                     ${container}
    ...                             ${cmd}                                  ${debug}=${False}
    ${output}                       call method                             ${container}
    ...                             cmd
    ...                             cmd=${cmd}                              debug=${debug}
    [Return]                        ${output}

K8s Cmd
    [Documentation]                 Execute a linux command on a container.
    ...                             Container is specified thanks to its name (or suffix) and the name (or suffix) of its pod.
    ...                             Returned value is the output of the command.
    ...                             In case, debug flag is activated, additional traces (command and results) will be traces into console.
    [Arguments]                     ${k8s}
    ...                             ${podName}                              ${containerName}
    ...                             ${cmd}                                  ${debug}=${False}
    ${output}                       call method                             ${k8s}
    ...                             cmd
    ...                             containerName=${containerName}          podName=${podName}
    ...                             cmd=${cmd}                              debug=${debug}
    [Return]                        ${output}


K8s get Log
    [Documentation]                 Search in a container, in tmp directory, for startup_DEFAULT.log or LINUX_startup.log.
    ...                             or for a .zip or .xz file.
    ...                             Then, file is transfert in root path : /tmp/LOGS/<ContainerName>.
    ...                             If required, the file is unzipped (unzip for .zip file, or unxz for .xz file)
    ...                             Returned value is a AirframeFile (see AirframeFiles.py), defined with a path, a name and a k8sNode.
    ...                             also, a fullpath (concatenation of path and name).
    [Arguments]                     ${k8s}
    ...                             ${podName}                              ${containerName}
    ${container}                    K8s Get Container
    ...                             k8s=${k8s}                              name=${containerName}
    ...                             podName=${podName}
    ${log}                          call method                             ${container}
    ...                             getLog
    [Return]                        ${log}

K8s Download File
    [Documentation]                 Download a file from a Kubernetes
    [Arguments]                     ${airframeFile}
    ...                             ${localPath}
    ...                             ${debug}=${False}
    Dated log                       Download file [${airframeFile.k8sNode.name}]:${airframeFile} to ${localPath}
    call method                     ${airframeFile.k8sNode}
    ...                             downloadFile
    ...                                 remotePath=${airframeFile.fullPath}
    ...                                 localPath=${localPath}
    ...                                 debug=${debug}

Private Prepare Aashell Infos
    [Documentation]
    ...     used to get infos for get and set rad param
    ...
    ...     | rad_param | Rad Parameter [0x580017] |
    ...     | gnb   | var globale GNB_DU or GNB_CU       |
    ...     | domain_nom   | eg. cprt  |
    ...     | domain_elem  | eg cprt-0 |
    ...
    ...    *Returns* IF rad_param is empty prints all non default R&D parameters of RadMaster.
    ...              Else the "Current val" of rad_param. in a list e.g.: [u'0x0']
    ...
    [Arguments]   ${gnb}=${GNB_DU}   ${domain_nom}=cprt   ${domain_elem}=cprt-0

    ${kcmd}=    Set Variable     ss -aptunl
    ${pod_name}=                      Set Variable    ${domain_nom}
    #Dated Log                         >> pod_name= ${pod_name}
    ${container_name}=                Set Variable    ${domain_elem}
    #Dated Log                         >> container_name= ${container_name}
    ${tcp_ports}                      K8s Cmd    k8s=${gnb}    podName=${pod_name}    containerName=${container_name}    cmd=${kcmd}
    #Dated Log                         >> tcp_ports= ${tcp_ports}

    ${namespace}        Run Keyword If     '${gnb}'=='${GNB_DU}'      Set Variable     ${GNB_DU.mainNode.k8s.namespace}
    ...              ELSE            Set Variable         ${GNB_CU.mainNode.k8s.namespace}
    #Dated Log                         >> namespace= ${namespace}

    ${aashell_infos}     Create Dictionary
    ...                 pod=${pod_name}
    ...                 namespace=${namespace}
    ...                 tcp_ports=${tcp_ports}
    #Dated Log                         >> aashell_infos= ${aashell_infos}
    [Return]            ${aashell_infos}


Create Non-Zero Rad Parameters List
    [Documentation]
    ...     Parse RAD master output and create a list of non-zero RAD parameters.
    ...
    ...     This keyword processes the output from RAD master command and extracts
    ...     all parameters that have non-zero values.
    ...
    ...     | nonDefaultRadMaster | Output string from RAD master command |
    ...
    ...     *Returns* A list of dictionaries, where each dictionary contains:
    ...     | rad_param  | RAD parameter identifier (e.g., '0x580017') |
    ...     | rad_name   | RAD parameter name                          |
    ...     | rad_value  | Current value of the parameter              |
    ...
    ...     *Example:*
    ...     | ${radMaster}=     | Get RAD Master Output           |
    ...     | ${nonZeroList}=   | Create Non-Zero Rad Parameters List | ${radMaster} |
    ...     | # Returns: [{'rad_param': '0x580017', 'rad_name': 'paramName', 'rad_value': '5'}, ...]
    ...
    [Arguments]    ${nonDefaultRadMaster}
    ${nonZeroRadParams}=              Create List
    @{lines}=                         Split To Lines    ${nonDefaultRadMaster}
    FOR    ${line}    IN    @{lines}
        ${parts}=                     Split String    ${line}    ${SPACE}
        ${rad_param}=                 Set Variable    ${parts}[0]
        ${rad_param}=                 Replace String    ${rad_param}    [    ${EMPTY}
        ${rad_param}=                 Replace String    ${rad_param}    ]    ${EMPTY}
        ${rad_name}=                  Set Variable    ${parts}[1]
        ${rad_name}=                  Replace String    ${rad_name}    '    ${EMPTY}
        ${value}=                     Set Variable    ${parts}[3]
        IF    ${value} != 0
            &{rad_dict}=              Create Dictionary    rad_param=${rad_param}    rad_name=${rad_name}    rad_value=${value}
                                      Append To List    ${nonZeroRadParams}    ${rad_dict}
        END
    END
    #Dated Log                         >> Non-zero rad parameters: ${nonZeroRadParams}
    [Return]    ${nonZeroRadParams}

Get Rad Value Using Aashell3
    [Documentation]
    ...     Get all non-default R&D parameters with non-zero values from RadMaster.
    ...
    ...     This keyword executes RAD master command via AaShell on Cloud RAN (VDU/VCU)
    ...     to retrieve all non-default RAD parameters and filters those with non-zero values.
    ...
    ...     | rad_param    | RAD parameter identifier (not used, kept for compatibility) |
    ...     | gnb          | GNB instance (${GNB_DU} or ${GNB_CU})                       |
    ...     | domain_nom   | Domain name (e.g., 'cprt', 'L2PS', 'RLC', 'MAC')            |
    ...     | domain_elem  | Domain element (e.g., 'cprt-0')                             |
    ...
    ...     *Returns* A list of dictionaries with non-zero RAD parameters. Each dictionary contains:
    ...     | rad_param  | RAD parameter identifier (e.g., '0x580017') |
    ...     | rad_name   | RAD parameter name                          |
    ...     | rad_value  | Current non-zero value of the parameter     |
    ...
    ...     *Example:*
    ...     | ${radParams}=  | Get Rad Value Using Aashell3 | gnb=${GNB_DU} | domain_nom=cprt | domain_elem=cprt-0 |
    ...     | # Returns: [{'rad_param': '0x580017', 'rad_name': 'rdFeatureFlagBitmapLevel', 'rad_value': '4'}, ...]
    ...
    [Arguments]   ${rad_param}=${EMPTY}   ${gnb}=${GNB_DU}   ${domain_nom}=cprt   ${domain_elem}=cprt-0

    ${aashell_infos}                Private Prepare Aashell Infos
    ...                   gnb=${gnb}    domain_nom=${domain_nom}       domain_elem=${domain_elem}

    ${pod}=    Get From Dictionary    ${aashell_infos}    pod
    ${namespace}=    Get From Dictionary    ${aashell_infos}    namespace
    ${tcp_ports}=    Get From Dictionary    ${aashell_infos}    tcp_ports
    ${proxy}=       Run Keyword If     '${gnb}'=='${GNB_DU}'       Create Dictionary
    ...     host=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    ...     user=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.username}
    ...     password=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.password}
    ...     ELSE              Create Dictionary
    ...     host=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    ...     user=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.username}
    ...     password=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.password}

    #extract domain from rad
    ${domain}        OsTool.extract_domain_from_rad     ${rad_param}

    ${nonDefaultRadMaster}        OsTool.execute_aashell_command
    ...      command=rad -mr ${domain}   pod=${pod}     namespace=${namespace}    tcp_port=${tcp_ports}    proxy=${proxy}

    #Dated Log                         >> nonDefaultRadMaster= ${nonDefaultRadMaster}
    ${radMasterValue}=                Create Non-Zero Rad Parameters List    ${nonDefaultRadMaster}
    [Return]   ${radMasterValue}

Get Rad Parameter Dictionary
    [Documentation]
    ...     Search for a specific RAD parameter in a list and return its dictionary.
    ...
    ...     This keyword searches through a list of RAD parameter dictionaries to find
    ...     a specific parameter by its identifier. The search is case-insensitive.
    ...
    ...     | rad_params_list       | List of RAD parameter dictionaries                     |
    ...     | rad_param_identifier  | RAD parameter identifier to search for (e.g. '0x580017') |
    ...
    ...     *Returns* The dictionary containing the RAD parameter details if found, None otherwise.
    ...     Dictionary format: {'rad_param': '0x580017', 'rad_name': 'paramName', 'rad_value': '5'}
    ...
    ...     *Example:*
    ...     | ${radList}=      | Get Rad Value Using Aashell3 | gnb=${GNB_DU}           |
    ...     | ${radDict}=      | Get Rad Parameter Dictionary | ${radList} | 0x580017 |
    ...     | # Returns: {'rad_param': '0x580017', 'rad_name': 'rdFeatureFlagBitmapLevel', 'rad_value': '4'}
    ...
    [Arguments]    ${rad_params_list}    ${rad_param_identifier}
    ${result}=                        Set Variable    None
    FOR    ${rad_dict}    IN    @{rad_params_list}
        ${rad_param_lower}=           Convert To Lower Case    ${rad_dict}[rad_param]
        ${rad_param_identifier_lower}=    Convert To Lower Case    ${rad_param_identifier}
        IF    ${rad_param_lower} == ${rad_param_identifier_lower}
            ${result}=                Copy Dictionary    ${rad_dict}
            Exit For Loop
        END
    END
    [Return]    ${result}

Set Rad Parameter Using Aashell
    [Documentation]
    ...     Set a RAD parameter value for Classical or Cloud RAN (AIC).
    ...
    ...     This keyword sets a RAD parameter using AaShell command.
    ...     It automatically detects the architecture (Classical vs AIC) and uses
    ...     the appropriate method.
    ...
    ...     | rad_param_value | RAD parameter value to set (e.g., '10', '0x2')      |
    ...     | rad_param       | RAD parameter identifier (e.g., '0x580017')         |
    ...     | gnb             | GNB instance (${GNB_DU} or ${GNB_CU}) for AIC only  |
    ...     | domain_nom      | Domain name (e.g., 'cprt') for AIC only             |
    ...     | domain_elem     | Domain element (e.g., 'cprt-0') for AIC only        |
    ...
    ...     *Example:*
    ...     | # For Classical architecture:
    ...     | Set Rad Parameter Using Aashell | rad_param_value=10 | rad_param=0x580017 |
    ...     | # For AIC architecture:
    ...     | Set Rad Parameter Using Aashell | rad_param_value=10 | rad_param=0x580017 | gnb=${GNB_DU} | domain_nom=cprt | domain_elem=cprt-0 |
    ...
    [Arguments]  ${rad_param_value}    ${rad_param}=${EMPTY}     ${gnb}=${GNB_DU}   ${domain_nom}=cprt   ${domain_elem}=cprt-0
    IF                  not ${isAic}
                        OsTool.execute_aashell_command_gNB   command=rad -mw ${rad_param} ${rad_param_value}
    ELSE
                        Set Rad Parameter Using Aashell AIC    rad_param_value=${rad_param_value}    rad_param=${rad_param}    gnb=${gnb}
                        ...                                    domain_nom=${domain_nom}   domain_elem=${domain_elem}
    END


Set Rad Parameter Using Aashell AIC
    [Documentation]
    ...     Set RAD parameter value on Cloud RAN (AIC) using AaShell.
    ...
    ...     This keyword sets a RAD parameter on Cloud RAN VDU/VCU using AaShell
    ...     command executed through SSH proxy to the Kubernetes pod.
    ...
    ...     | rad_param_value | RAD parameter value to set (e.g., '10', '0x2')      |
    ...     | rad_param       | RAD parameter identifier (e.g., '0x580017')         |
    ...     | gnb             | GNB instance (${GNB_DU} or ${GNB_CU})               |
    ...     | domain_nom      | Domain name (e.g., 'cprt', 'L2PS', 'RLC', 'MAC')    |
    ...     | domain_elem     | Domain element/pod suffix (e.g., 'cprt-0')          |
    ...
    ...     *Example:*
    ...     | Set Rad Parameter Using Aashell AIC | rad_param_value=0x2 | rad_param=0x580017 |
    ...     | ...                                  | gnb=${GNB_DU} | domain_nom=cprt | domain_elem=cprt-0 |
    ...
    [Arguments]  ${rad_param_value}    ${rad_param}=${EMPTY}     ${gnb}=${GNB_DU}   ${domain_nom}=cprt   ${domain_elem}=cprt-0

    ${aashell_infos}                Private Prepare Aashell Infos
    ...                   gnb=${gnb}    domain_nom=${domain_nom}       domain_elem=${domain_elem}

    ${pod}=    Get From Dictionary    ${aashell_infos}    pod
    ${namespace}=    Get From Dictionary    ${aashell_infos}    namespace
    ${tcp_ports}=    Get From Dictionary    ${aashell_infos}    tcp_ports
    ${proxy}=       Run Keyword If     '${gnb}'=='${GNB_DU}'       Create Dictionary
    ...     host=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    ...     user=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.username}
    ...     password=${GNB_DU.mainNode.k8s.master_node.k8s_connection_details.password}
    ...     ELSE              Create Dictionary
    ...     host=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.ip_addr}
    ...     user=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.username}
    ...     password=${GNB_CU.mainNode.k8s.master_node.k8s_connection_details.password}

    ${nonDefaultRadMaster}
    ...     OsTool.execute_aashell_command   command=rad -mw ${rad_param} ${rad_param_value}
    ...                                           pod=${pod}
    ...                                           namespace=${namespace}
    ...                                           tcp_port=${tcp_ports}
    ...                                           proxy=${proxy}

