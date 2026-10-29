*** Settings ***
Documentation
...  Verify that the oam-ne3sadapt service auto-recovers after repeated process failures, leading to a pod reset.
...  Connect to the container and confirm ne3sadapt is configured as non-critical in AppDef.txt.
...  Kill the ne3sadapt_runner.sh process 6 times (7s sleep between kills) using ps -ef and xargs kill -9.
...  Verify that the pod restarts (i.e., pod age is reset or RESTARTS count increases).
...  Use oc describe pod to confirm:
...  - NE3SADAPT_SERVICE_NAME: oam-ne3sadapt
...  - NE3SADAPT_SERVICE_PORT: 50017

Resource  ../../common_resources/vcu_frame.robot


*** Keywords ***
TC__PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29235
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  30.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29235 - TC creation
    ...  24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29610 - Refactor pod name construction

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB009744  SW-vCU25

    Step0: TC Preconditions
    Step1: Connect To Container And Confirm Ne3sadapt Is Configured As Noncritical In AppDef.txt
    Step2: Kill The Ne3sadapt_runner.sh Process 6 Times
    Step3: Verify That The Pod Restarts
    Step4: Check NE3SADAPT_SERVICE_NAME And NE3SADAPT_SERVICE_PORT


Step0: TC Preconditions
    Log  \nStep0: TC Prerequisites  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${oamext_pod_name}  Get Full Name For Pod  ${VCU_CRAN}  oamext
    ${ne3sadapt_container_name}  Get Full Name For Container  ${VCU_CRAN}  ne3sadapt
    Set Test Variable  ${OAMEXT_POD_NAME}
    Set Test Variable  ${NE3SADAPT_CONTAINER_NAME}
    ${restarts_comm}  Catenate  SEPARATOR=${SPACE}  oc get pod ${OAMEXT_POD_NAME} -n ${VCU_CRAN} -o
    ...  jsonpath='{.status.containerStatuses[*].restartCount}' | tr ' ' '\\n' | awk '{s+=$1} END {print "RESTARTS: " s}'
    Set Test Variable  ${RESTARTS_COMM}
    SSHLibrary.Write  ${RESTARTS_COMM}
    ${output}  SSHLibrary.Read Until Prompt
    ${restarts_number}  Get Regexp Matches  ${output}  [0-9]+
    ${NO_RESTARTS}  Convert To Integer  ${restarts_number}[0]
    Set Test Variable  ${NO_RESTARTS}
    Log  ${output}  console=true

    [Teardown]  SSHLibrary.Close Connection


Step1: Connect To Container And Confirm Ne3sadapt Is Configured As Noncritical In AppDef.txt
    Log  \nStep1: Connect To Container And Confirm Ne3sadapt Is Configured As Noncritical In AppDef.txt  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${pm_reports_comm}  Catenate  SEPARATOR=${SPACE}  oc exec -it ${OAMEXT_POD_NAME} -c ${NE3SADAPT_CONTAINER_NAME} -n
    ...  ${VCU_CRAN} -- cat /opt/nokia/SS_RCPCCSMCU/AppDef.txt
    SSHLibrary.Write  ${pm_reports_comm}
    ${output}  SSHLibrary.Read Until Prompt
    Log  ${output}  console=true

    [Teardown]  SSHLibrary.Close Connection


Step2: Kill The Ne3sadapt_runner.sh Process 6 Times
    Log  \nStep2: Kill The Ne3sadapt_runner.sh Process 6 Times  console=true
    Open SSH Connection To VCU And Connect To Openshift
    SSHLibrary.Write  oc exec -it ${OAMEXT_POD_NAME} -c ${NE3SADAPT_CONTAINER_NAME} -n ${VCU_CRAN} -- bash
    ${output}  SSHLibrary.Read Until Prompt
    ${container}  Should Match Regexp  ${output}  bash-[0-9]+\.[0-9$]+$
    FOR  ${index}  IN RANGE  1  7
        SSHLibrary.Write  ps -ef | grep "/bin/bash /opt/nokia/SS_OAM/NE3SADAPT/ne3sadapt_runner.sh" | awk '{print \$2}' | xargs kill -9
        ${ps_output}  SSHLibrary.Read Until Prompt
        Sleep  7s  Time for restart of process.
        ${status_container}  Run Keyword And Return Status  Should Contain  ${ps_output}  ${container}
        SSHLibrary.Set Client Configuration  timeout=3s
        ${status_output}  Run Keyword And Return Status  SSHLibrary.Read Until  ]$
        IF  ${status_output}
            Log  The process was killed of 6 time![OK]  console=true
            BREAK
        ELSE IF  ${status_container}
            Log  Wait until another kill command is sent for the process...  console=true
        ELSE
           Fail  The process not was killed of 6 time![NOK]
        END
    END
    Sleep  15s  Time for restart of pod.

    [Teardown]  SSHLibrary.Close Connection


Step3: Verify That The Pod Restarts
    Log  \nStep3: Verify That The Pod Restarts  console=true
    Open SSH Connection To VCU And Connect To Openshift
    SSHLibrary.Write  oc get pods -n ${VCU_CRAN}
    Sleep  1s  Time for obtaining the pod.
    ${pods_output}  SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${RESTARTS_COMM}
    ${output}  SSHLibrary.Read Until Prompt
    ${restarts_number}  Get Regexp Matches  ${output}  [0-9]+
    ${final_no_restarts}  Convert To Integer  ${restarts_number}[0]
    IF  ${final_no_restarts} > ${NO_RESTARTS}
        Log  The process has reset![OK]  console=true
    ELSE
        Fail  The process has not reset![NOK]
    END

    [Teardown]  SSHLibrary.Close Connection


Step4: Check NE3SADAPT_SERVICE_NAME And NE3SADAPT_SERVICE_PORT
    Log  \nStep4: Check NE3SADAPT_SERVICE_NAME And NE3SADAPT_SERVICE_PORT  console=true
    Open SSH Connection To VCU And Connect To Openshift
    SSHLibrary.Write  oc describe pod ${OAMEXT_POD_NAME} -n ${VCU_CRAN} | grep NE3SADAPT_SERVICE_NAME
    ${service_name}  SSHLibrary.Read Until Prompt
    Should Contain  ${service_name}  oam-ne3sadapt
    SSHLibrary.Write  oc describe pod ${OAMEXT_POD_NAME} -n ${VCU_CRAN} | grep NE3SADAPT_SERVICE_PORT
    ${service_port}  SSHLibrary.Read Until Prompt
    Should Contain  ${service_port}  50017

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VCU Setup
    Modify Resource Search Order  PM__vCU__OAMNE3SADAPT_service_shall_be_restored_automatically_after_process_failure


TC Teardown
    Common VCU Teardown
