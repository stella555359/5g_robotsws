*** Settings ***
Library  ute_pdu
Library  taf.transport.ssh  WITH NAME  ssh

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  18.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-275 - add KW "Connect To PC And Start FAC Agent" and
...                                                                 "Kill Active Process On PC If Exist"
...  xx.xx.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${FAC_PC_LOGIN}=  plwroper4
${FAC_PC_PASS}=  0per4pa$$


*** Keywords ***
######################
### FAC Interfaces ###
######################

Get ALD Interfaces
    [Arguments]  ${ALD_type}

    Import Variables  ${FAC_CONFIG_FILE_PATH}
    @{ald_interfaces}  Create List
    ${keys}  Get Dictionary Keys  ${INTERFACES}
    FOR  ${interface}  IN  @{keys}
       ${status}  Run Keyword And Return Status  Should Match Regexp  ${interface}  ${ALD_type}.*
       IF  ${status}  Append To List  ${ald_interfaces}  ${interface}
    END

    RETURN  ${ald_interfaces}


Switch DC Using FAC
    [Documentation]  This keyword switches off/on all FAC outlets assigned to ALDs.
    ...
    ...  **Example of simple usage:**
    ...  Switch DC Using FAC  On  ${ret_fac_interfaces}
    ...
    [Arguments]  ${type}   ${fac_interfaces}

    FOR  ${device}  IN  @{fac_interfaces}
       IF  '${type}'=='On'
           PDU Interface  ${type}  ${device}
           Log  Power on ${device} is set ${type}.  console=${True}
           Sleep  1s
       ELSE IF  '${type}'=='Off'
           PDU Interface  ${type}  ${device}
           Log  Power on ${device} is set ${type}.  console=${True}
           Sleep  1s
       END
    END


PDU Interface
    [Documentation]
    ...
    ...  **Example of simple usage:**
    ...  PDU Interface  Off  ${ret}
    ...
    [Arguments]  ${type}  ${if_name}  ${timeout}=10

    PDU Initiation  ${if_name}  ${timeout}
    ${outlet}  Get PDU Outlet  ${if_name}
    ${contactor}  Get PDU Contactor Type  ${if_name}
    IF  '${type}'=='On' and '${contactor}' == 'NORMALLY_OPEN'
        Pdu Outlet On  ${outlet}
    ELSE IF  '${type}'=='On' and '${contactor}' == 'NORMALLY_OPENED'
        Pdu Outlet On  ${outlet}
    ELSE IF  '${type}'=='On' and '${contactor}' == 'NORMALLY_CLOSED'
        Pdu Outlet Off   ${outlet}
    ELSE IF  '${type}'=='Off' and '${contactor}' == 'NORMALLY_OPEN'
        Pdu Outlet Off  ${outlet}
    ELSE IF  '${type}'=='Off' and '${contactor}' == 'NORMALLY_OPENED'
        Pdu Outlet Off  ${outlet}
    ELSE IF  '${type}'=='Off' and '${contactor}' == 'NORMALLY_CLOSED'
        Pdu Outlet On  ${outlet}
    END

    [Teardown]  Run Keyword And Ignore Error  Teardown Pdu


Get PDU Outlet
    [Arguments]  ${if_name}

    RETURN  ${INTERFACES['${if_name}']['OUTLET']}


Get PDU IP
    [Arguments]  ${if_name}

    RETURN  ${INTERFACES['${if_name}']['IP']}


Get PDU Type
    [Arguments]  ${if_name}

    RETURN  ${INTERFACES['${if_name}']['TYPE']}


Get PDU Contactor Type
    [Arguments]  ${if_name}

    ${contactor}  Get Variable Value  ${INTERFACES['${if_name}']['CONTACTOR']}  NORMALLY_OPEN

    RETURN  ${contactor}


PDU Initiation
    [Arguments]  ${if_name}  ${timeout}

    Variable Should Exist  ${INTERFACES['${if_name}']}  Interface not defined in interfaces.yaml
    ${host}  Get PDU IP  ${if_name}
    ${pdu_type}  Get PDU Type  ${if_name}
    ${udp_timeout}  Evaluate  ${timeout}-1
    Setup Pdu  host=${host}  model=${pdu_type}  timeout=${timeout}  udp_timeout=${udp_timeout}


Connect To PC And Start FAC Agent
    [Documentation]  Workaround solution for "No SNMP response received before timeout".
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${FAC_PC_IP}  ${FAC_PORT}

    ${if_pingable}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  15s
    ...  Check If Host Is Reachable  IP=${FAC_PC_IP}
    IF  ${if_pingable}
        Log  FAC PC is reachable
    ELSE IF  not ${if_pingable}
        Fail  msg=FAC PC is not reachable. \nTurn on PC.
    END
    ${if_connected}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2min  30s
    ...  ssh.connect to  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}
    IF  ${if_connected}  Log  SSH connection to FAC PC has been established
    ${if_command_executed}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2min  30s
    ...  ssh.send command  command=cd C:/Users/${FAC_PC_LOGIN}/Desktop/FAC_Setup/fac/fac_agent && python ./agent.py ${FAC_PORT}
    IF  ${if_command_executed}  Log  FAC agent script is running...  console=${true}


Kill Active Process On PC If Exist
    [Documentation]  Kill active process on Windows.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ip}  ${login}  ${password}  ${process}

    ssh.connect to  ${ip}  ${login}  ${password}
    ssh.send command  command=tasklist|findstr "${process}"
    ${output}  ssh.read output
    ${status}  ${output}  Run Keyword And Ignore Error  Get Regexp Matches  ${output}  ${process}
    IF  '${output[0]}'!='${EMPTY}'  Run Keyword And Ignore Error  ssh.send command  command=taskkill /IM ${process} /F
