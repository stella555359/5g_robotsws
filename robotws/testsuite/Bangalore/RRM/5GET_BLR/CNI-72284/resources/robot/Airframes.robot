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