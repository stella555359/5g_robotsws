*** Settings ***
Documentation
...          Just an exemple about how to use the k8s tools

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Airframes.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Setup.py

Suite Setup                         Suite Setup From scratch
#Suite Teardown                      Suite Teardown

*** Test Cases ***
TU Get Pod
    Test Get Pod                    ${GNB_CU}        tl037-cran37-cpcl-0
    Test Get Pod                    ${GNB_CU}        tl037-cran37-cpif-0
    Test Get Pod                    ${GNB_CU}        tl037-cran37-cpnb-0
    Test Get Pod                    ${GNB_CU}        tl037-cran37-cpnrt-0
    Test Get Pod                    ${GNB_CU}        tl037-cran37-cpue-0
    Test Get Pod                    ${GNB_CU}        cpcl-0
    Test Get Pod                    ${GNB_CU}        cpif-0
    Test Get Pod                    ${GNB_CU}        cpnb-0
    Test Get Pod                    ${GNB_CU}        cpnrt-0
    Test Get Pod                    ${GNB_CU}        cpue-0
    Test Get Pod                    ${GNB_CU}        cpue
    Test Get Pod                    ${GNB_CU}        bidon

TU Get Container
    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-cpue
    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-lwsd
    Test Get Container              k8s=${GNB_CU}        name=cpue
    Test Get Container              k8s=${GNB_CU}        name=lwsd
    Test Get Container              k8s=${GNB_CU}        name=alarmdata-init-0
    Test Get Container              k8s=${GNB_CU}        name=config-init

    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-cpcl
    Test Get Container              k8s=${GNB_CU}        name=cpcl
    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-cpcl      podName=tl037-cran37-cpcl-0
    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-cpcl      podName=cpcl-0
    Test Get Container              k8s=${GNB_CU}        name=tl037-cran37-cpcl      podName=dummy
    Test Get Container              k8s=${GNB_CU}        name=cpcl                   podName=tl037-cran37-cpcl-0
    Test Get Container              k8s=${GNB_CU}        name=cpcl                   podName=cpcl-0
    Test Get Container              k8s=${GNB_CU}        name=cpcl                   podName=dummy


TU Cmd
    Test K8s Cmd                    k8s=${GNB_CU}        podName=cpcl-0         containerName=cpcl
    ...                             cmd=ls -lrt          debug=${True}

*** Keywords ***
Test Get Pod
    [Arguments]                     ${k8s}    ${name}
    Dated log                       GET POD[${k8s.name}, name=${name}]
    ${pod}                          K8s Get Pod      k8s=${k8s}             name=${name}
    Dated log                       RESULT=${pod}

Test Get Container
    [Arguments]                     ${k8s}    ${name}       ${podName}=${None}
    Dated log                       GET Container[${k8s.name}, name=${name}, podName=${podName}]
    ${container}                    K8s Get Container       k8s=${k8s}       name=${name}    podName=${podName}
    Dated log                       RESULT=${container}

Test K8s Cmd
    [Arguments]                     ${k8s}          ${podName}         ${containerName}
    ...                             ${cmd}          ${debug}=${False}
    Dated log                       K8s cmd:k8s=${k8s.name} POD=${podName} CONT=${containerName} CMD=[${cmd}] DEBUG=${debug}
    ${res}                          K8s cmd
    ...                             k8s=${k8s}      podName=${podName}     containerName=${containerName}
    ...                             cmd=${cmd}      debug=${debug}
    Dated log                       K8s cmd:RES=[${res}]
    [Return]                        ${res}