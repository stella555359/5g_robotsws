*** Settings ***
Documentation
...  This TC is opening ssh connection to vDU to kill /usr/bin/oamdispinit process from oamdispatcher container.
...  Oam PM pod must not be in reset after this operation.

Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__PM__vDU__Check_Oamdispatcher_Container
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29238
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29238 - Initial TAT creation
    ...  ******************
    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB009067  SW-25R2

    Step1: Kill Oamdispinit Process From Oamdispatcher Container
    Step2: Oampm Pod Should Not Be In Reset


Step1: Kill Oamdispinit Process From Oamdispatcher Container
    Log  \nStep1: Kill Oamdispinit Process From Oamdispatcher Container  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_pod_name}  Get Full Name For Pod  ${VDU_CRAN}  oampm
    ${oamdispatcher_container_name}  Get Full Name For Container  ${VDU_CRAN}  oamdispatcher
    Set Test Variable  ${OAMPM_POD_NAME}
    SSHLibrary.Write  oc exec -it ${OAMPM_POD_NAME} -c ${oamdispatcher_container_name} -n ${VDU_CRAN} -- bash
    SSHLibrary.Read Until Prompt

    SSHLibrary.Write  ps -ef | grep "/usr/bin/oamdispinit"
    ${process_line}  SSHLibrary.Read Until Prompt
    ${line_splitted}  Split String  ${process_line}
    ${initial_pid}  Set Variable  ${line_splitted}[1]

    SSHLibrary.Write  ps -ef | grep "/usr/bin/oamdispinit" | grep -v grep | tr -s " " | cut -d" " -f2 | xargs kill -9
    SSHLibrary.Read Until Prompt

    SSHLibrary.Write  ps -ef | grep "/usr/bin/oamdispinit"
    ${process_line}  SSHLibrary.Read Until Prompt
    ${line_splitted}  Split String  ${process_line}
    Should Not Be Equal As Integers  ${initial_pid}  ${line_splitted}[1]  /usr/bin/oamdispinit process was not killed successfully.
    Log  /usr/bin/oamdispinit process was killed successfully.  console=true

    [Teardown]  SSHLibrary.Close Connection


Step2: Oampm Pod Should Not Be In Reset
    Log  \nStep2: Oampm Pod Should Not Be In Reset  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${oampm_is_resetting}  Run Keyword And Return Status  Wait Until Keyword Succeeds  30s  10s  Check If OAMPM Pod Is Not Running
    ...  ${OAMPM_POD_NAME}  ${VDU_CRAN}
    IF  ${oampm_is_resetting}  Fail  ${OAMPM_POD_NAME} is resetting after killing oam dispatcher container.

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__Check_Oam_Dispatcher_Container


TC Teardown
    Common VDU Teardown
