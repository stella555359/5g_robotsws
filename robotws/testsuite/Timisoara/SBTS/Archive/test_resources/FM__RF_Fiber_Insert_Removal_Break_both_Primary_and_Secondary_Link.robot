*** Settings ***
Library    Telnet
Resource    ../../common_resources/ca_FM_general.robot


*** Variables ***
${OM_IP_ADDRESS}   10.44.194.188   #Optical Matrix IP Address - default port 10001.
${RF_CONNECTIONS}      11,22       #Connection I/O.
${RM_CONNECTIONS}      17,28       #Connection I/O.

*** Keywords ***
TC__FM__RF_Fiber_Insert_Removal_Break_both_Primary_and_Secondary_Link
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19965
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  The purpose of this test case is to verify the BTS and RF go back to working normal after
    ...  hot insert & removal primary and secondary fiber link
    ...  This case can't be executed in only one fiber configuration .
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19965 - initial creation
    ...  - 20.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22244 - Changes due to CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard


    Set Tags    CA-DEV    OWNER-krzysztof.chycki@nokia.com    AUTHOR-krzysztof.chycki@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_4    PHASE-CRT    SW-N/A

    Step 1: Remove fibers form RF
    Step 2: Insert Primary Link
    Step 3: Insert Secondary Link

Step 1: Remove fibers form RF
    Log  \n Step 1: Remove fibers form RF   console=True
    ${RM_CONNECTIONS}=  Split String  ${RM_CONNECTIONS}  ,
    Set Test Variable  ${RM_CONNECTIONS}
    Telnet.Open Connection  host=${OM_IP_ADDRESS}  port=10001
    FOR  ${con}  IN  @{RM_CONNECTIONS}
        Telnet.Write Bare  set${con}\n
        ${con1}=  Telnet.Write  set?
        ${con1}=  Fetch From Left  ${con1}  \r
        Run Keyword If  '${con1}'!='connetion ${con}'  Telnet.Read Until   connetion ${con}
    END
    Log  Break both primary and secondary fiber links on SBTS side.  console=${True}
    Assert alarm active    parameters="faultId=10, severity=Critical"    timeout=10 minutes

Step 2: Insert Primary Link
    Log  \n Step 2: Insert Primary Link   console=True
    ${CONNECTIONS}=  Split String  ${RF_CONNECTIONS}  ,
    Set Test Variable  ${CONNECTIONS}
    Telnet.Write Bare  set${CONNECTIONS[0]}\n
    ${con1}=  Telnet.Write  set?
    ${con1}=  Fetch From Left  ${con1}  \r
    Run Keyword If  '${con1}'!='connetion ${CONNECTIONS[0]}'  Telnet.Read Until   connetion ${CONNECTIONS[0]}
    Log  Connected only primary fiber link to BTS  console=${True}
    Assert alarm inactive    parameters="faultId=10, severity=Critical"    timeout=10 minutes
    Assert alarm active    parameters="faultId=2002, severity=Critical"    timeout=10 minutes
    Wait Until Keyword Succeeds  600s  1s
    ...  Assert parameters for any  WNCEL  operationalState=regex"(?i)Enabled", availabilityStatus=regex"Online|None"
    Wait Until Keyword Succeeds  600s  1s
    ...  Assert parameters for every  GNCEL  operationalState=regex"(?i)Enabled", availabilityStatus=regex"Online|None"

Step 3: Insert Secondary Link
    Log  \n Step 3: Insert Secondary Link   console=True
    Telnet.Write Bare  set${CONNECTIONS[1]}\n
    ${con1}=  Telnet.Write  set?
    ${con1}=  Fetch From Left  ${con1}  \r
    Run Keyword If  '${con1}'!='connetion ${CONNECTIONS[1]}'  Telnet.Read Until   connetion ${CONNECTIONS[1]}
    Log  Connected secondary fiber link to BTS.  console=${True}
    Assert alarm inactive    parameters="faultId=2002, severity=Critical"    timeout=10 minutes
    Wait Until Keyword Succeeds  600s  1s  Assert parameters for every  WNCEL
    ...  availabilityStatus=regex"Online|None", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
    Wait Until Keyword Succeeds  600s  1s  Assert parameters for every  LNCEL
    ...  availabilityStatus=regex"Online|None", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled"

Recovery Link
    Telnet.Open Connection  host=${OM_IP_ADDRESS}  port=10001
    ${CONNECTIONS}=  Split String  ${RF_CONNECTIONS}  ,
    FOR  ${con}  IN  @{CONNECTIONS}
        Telnet.Write Bare  set${con}\n
        ${con1}=  Telnet.Write  set?
        ${con1}=  Fetch From Left  ${con1}  \r
        Run Keyword If  '${con1}'!='connetion ${con}'  Telnet.Read Until   connetion ${con}
    END
    Telnet.Close All Connections

TC Setup
    Common Test Setup

TC Teardown
    Telnet.Close All Connections
    Recovery Link
    Common Test Teardown
