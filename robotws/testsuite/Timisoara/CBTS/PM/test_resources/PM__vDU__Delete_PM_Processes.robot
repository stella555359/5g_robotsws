*** Settings ***
Documentation
    ...  This TC is checking if oampm pod from vDU is restoring by itself.
    ...  1 process from oampm and pmdataserver containers are killed.
    ...  Then oampm pod is deleted and TC is checking if the 2 containers mentioned
    ...  above will be recreated and running within 6 minutes.
    ...  In the end, snapshot will be collected even if TC is passed.

Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__PM__vDU__Delete_PM_Processes
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26696
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26696 - Initial TAT creation
    ...  ******************
    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB009746

    Step0: Set OAMPM Pod Name
    Step1: Kill PMStat Process
    Step2: Kill PMDataServer Process
    Step3: Delete OAMPM Pod
    Step4: Check OAMPM Pod To Restore By Itself


Step0: Set OAMPM Pod Name
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    Set Test Variable  ${OAMPM_POD_NAME}

    [Teardown]  SSHLibrary.Close Connection


Step1: Kill PMStat Process
    Log  \nStep1: Kill PMStat process.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_container_name}  Get Full Name For Container  ${VDU_CRAN}  oampm
    SSHLibrary.Write  oc exec -it ${OAMPM_POD_NAME} -c ${oampm_container_name} -n ${VDU_CRAN} -- bash
    SSHLibrary.Read Until Prompt
    ${kill_process}  Catenate  ps -ef | grep "/opt/nokia/SS_OAM/PMStat/run.sh" |  awk '{print $2}' | xargs kill -9
    SSHLibrary.Write  ${kill_process}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step2: Kill PMDataServer Process
    Log  \nStep2: Kill PMDataServer process.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${pmdataserver_container_name}  Get Full Name For Container  ${VDU_CRAN}  pmdataserver
    SSHLibrary.Write  oc exec -it ${OAMPM_POD_NAME} -c ${pmdataserver_container_name} -n ${VDU_CRAN} -- bash
    SSHLibrary.Read Until Prompt
    ${kill_process}  Catenate  ps -ef | grep "/opt/nokia/SS_OAM/PMDataServer/run.sh" |  awk '{print $2}' | xargs kill -9
    SSHLibrary.Write  ${kill_process}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step3: Delete OAMPM Pod
    Log  \nStep3: Delete OAMPM pod  console=true
    Open SSH Connection To VDU And Connect To Openshift
    SSHLibrary.Write  kubectl delete pod ${OAMPM_POD_NAME} -n ${VDU_CRAN}
    ${delete_comm_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${delete_comm_output}  pod "${OAMPM_POD_NAME}" deleted  ${OAMPM_POD_NAME} pod was not deleted.
    Log  ${OAMPM_POD_NAME} was deleted.  console=true

    [Teardown]  SSHLibrary.Close Connection


Step4: Check OAMPM Pod To Restore By Itself
    Log  \nStep4: Check OAMPM pod to restore by itself  console=true
    Open SSH Connection To VDU And Connect To Openshift
    SSHLibrary.Write  oc get pods -n ${VDU_CRAN}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${oampm_line}  Get Lines Containing String  ${pods_output}  ${OAMPM_POD_NAME}
    Should Contain  ${oampm_line}  ContainerCreating  ${OAMPM_POD_NAME} is not going to be recreated.
    Log  ${OAMPM_POD_NAME} is going to be recreated.  console=true

    Wait Until Keyword Succeeds  360  1
    ...  Check If OAMPM Pod Is Running
    Log  ${OAMPM_POD_NAME} is running after restoring within ${RESTORE_TIME} time interval.  console=true

    [Teardown]  SSHLibrary.Close Connection


Check If OAMPM Pod Is Running
    SSHLibrary.Write  oc get pods -n ${VDU_CRAN}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${oampm_line}  Get Lines Containing String  ${pods_output}  ${OAMPM_POD_NAME}
    Should Contain  ${oampm_line}  Running
    ${matches}  Get Regexp Matches  ${oampm_line}  \\d{1,2}(s|m)
    Set Test Variable  ${RESTORE_TIME}  ${matches}[0]


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__Delete_PM_Processes


TC Teardown
    Set Test Variable  ${COLLECT_SNAPSHOT}  always
    Common VDU Teardown
