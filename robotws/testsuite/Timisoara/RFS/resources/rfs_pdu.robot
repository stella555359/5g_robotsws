*** Settings ***
Documentation    Keywords for PDU
Library  taf.hw.pdu  WITH NAME  pdu
Library  python_resources/PduWrapper.py  WITH NAME  pduwrapper

*** Keywords ***

Setup PDU
    [Documentation]
    ...  HELPER KW. Setup connection to the PDU device
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  None

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    ${number_timeout} =  Convert To Number  ${timeout}

    Variable Should Exist  ${INTERFACES['${if_name}']}  Interface not defined in interfaces.yaml

    ${pduport_status} =  Run Keyword And Return Status  Variable Should Exist  ${INTERFACES['${if_name}']['PduPort']}

    Run Keyword If  ${pduport_status}
    ...  pduwrapper.setup_pdu  model=${INTERFACES['${if_name}']['PduPort'].pdu}  alias=${pdu_alias}  timeout=${number_timeout}
    ...  ELSE
    ...  pdu.setup_pdu  host=${INTERFACES['${if_name}']['IP']}  model=${INTERFACES['${if_name}']['TYPE']}
    ...  alias=${pdu_alias}  timeout=${number_timeout}


Teardown PDU
    [Documentation]
    ...  HELPER KW. Teardown PDU connection
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  None

    [Arguments]  ${pdu_alias}=default_pdu
    pdu.teardown_pdu  pdu_device=${pdu_alias}


PDU BTS Interface OFF
    [Documentation]
    ...  Turn OFF the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  None

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${pduport_status} =  Run Keyword And Return Status  Variable Should Exist  ${INTERFACES['${if_name}']['PduPort']}

    Run Keyword If  ${pduport_status}
    ...  pdu.power_off  port=${INTERFACES['${if_name}']['PduPort']}  pdu_device=${pdu_alias}
    ...  ELSE
    ...  pdu.power_off  port=${INTERFACES['${if_name}']['OUTLET']}  pdu_device=${pdu_alias}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU


PDU BTS Interface ON
    [Documentation]
    ...  Turn ON the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  None

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${pduport_status} =  Run Keyword And Return Status  Variable Should Exist  ${INTERFACES['${if_name}']['PduPort']}

    Run Keyword If  ${pduport_status}
    ...  pdu.power_on  port=${INTERFACES['${if_name}']['PduPort']}  pdu_device=${pdu_alias}
    ...  ELSE
    ...  pdu.power_on  port=${INTERFACES['${if_name}']['OUTLET']}  pdu_device=${pdu_alias}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU


PDU BTS Interface Get Status
    [Documentation]
    ...  Return PDU interface status
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description                                  |
    ...  | status        | Returns on/off depending on interface status |

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${pduport_status} =  Run Keyword And Return Status  Variable Should Exist  ${INTERFACES['${if_name}']['PduPort']}

    ${status}=  Run Keyword If  ${pduport_status}
    ...  pdu.get_port_status  port=${INTERFACES['${if_name}']['PduPort']}  pdu_device=${pdu_alias}
    ...  ELSE
    ...  pdu.get_port_status  port=${INTERFACES['${if_name}']['OUTLET']}  pdu_device=${pdu_alias}

    Return From Keyword  ${status}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU


PDU Set Voltage
    [Documentation]
    ...  Set the voltage for the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | voltage       | Yes  |             | Voltage to be set on the interface     |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  None

    [Arguments]  ${if_name}  ${voltage}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    pdu.set_voltage  ${INTERFACES['${if_name}']['OUTLET']}  voltage=${voltage}  pdu_device=${pdu_alias}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU

PDU Get Voltage
    [Documentation]
    ...  Get the voltage for the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  | read_voltage | Voltage value |

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${read_voltage} =  pdu.get_voltage  pdu_device=${pdu_alias}

    Return From Keyword  ${read_voltage}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU

PDU Get Current
    [Documentation]
    ...  Get the current for the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  | read_current | Current value in Amperes |

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${read_current} =  pdu.get_current  pdu_device=${pdu_alias}

    Return From Keyword  ${read_current}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU

PDU Get Energy Consumption
    [Documentation]
    ...  Get the energy consumption for the supplied PDU interface
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default     | Description                            |
    ...  | if_name       | Yes  |             | Interface name from config files       |
    ...  | timeout       | No   | 10          | Timeout for PDU connection             |
    ...  | pdu_alias     | No   | default_pdu | Alias for PDU connection               |
    ...
    ...  *RETURN*
    ...  | read_consumption | Energy consumption value in kWh |

    [Arguments]  ${if_name}  ${timeout}=10  ${pdu_alias}=default_pdu

    Setup PDU  ${if_name}  ${timeout}

    ${read_consumption} =  pdu.get_energy_consumption  pdu_device=${pdu_alias}

    Return From Keyword  ${read_consumption}

    [Teardown]  Run Keyword And Ignore Error  Teardown PDU

Check BTS SMs PDU info definition
    [Documentation]
    ...  Keyword used to check BTS SMs PDU info definition in config files
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description              |
    ...  | alias     | Yes  |         | BTS admin instance alias |
    ...
    ...  *RETURN*
    ...  | BTS_SM_PDU_if_name_list | List of BTS SMs interface names |

    [Arguments]  ${alias}

    ${BTS_SM_PDU_if_name_list}=  Create List

    ${primary_sm_defined}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${INTERFACES}  ${alias.lower()}_fsm
    ${secondary_sm_defined}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${INTERFACES}  ${alias.lower()}_ext_fsm

   Run Keyword If  ${primary_sm_defined}  Run Keywords
    ...  Append To List  ${BTS_SM_PDU_if_name_list}  ${alias.lower()}_fsm
    ...  AND  Log Long String  BTS ${alias} SM primary core PDU info: IP=${INTERFACES['${alias.lower()}_fsm']['IP']},
    ...  PORT=${INTERFACES['${alias.lower()}_fsm']['OUTLET']}  console=True
    ...  ELSE  Run Keywords
    ...  Log  No BTS ${alias} SM primary core PDU info is defined  level=ERROR
    ...  AND  Fail  No BTS ${alias} SM primary core PDU info is defined

    Run Keyword If  ${secondary_sm_defined}  Run Keywords
    ...  Append To List  ${BTS_SM_PDU_if_name_list}  ${alias.lower()}_ext_fsm
    ...  AND  Log Long String  BTS ${alias} SM secondary core PDU info: IP=${INTERFACES['${alias.lower()}_ext_fsm']['IP']},
    ...  PORT=${INTERFACES['${alias.lower()}_ext_fsm']['OUTLET']}  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} SM secondary core PDU info is defined  console=True

    [Return]  ${BTS_SM_PDU_if_name_list}

Check BTS SMs PDU port status
    [Documentation]
    ...  Keyword used to check BTS SMs PDU port status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Default | Description                     |
    ...  | BTS_SM_PDU_if_name_list | Yes  |         | List of BTS SMs interface names |
    ...  | port_status             | Yes  |         | Expected PDU port status        |
    ...
    ...  *RETURN*
    ...  | Parameter | Description                                         |
    ...  | status    | Returns True or False depending on interface status |

    [Arguments]  ${BTS_SM_PDU_if_name_list}  ${port_status}

    ${status}=  Set Variable  ${TRUE}

    FOR  ${item}  IN  @{BTS_SM_PDU_if_name_list}

        ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
        ${status}=  Set Variable If  '${PDU_port_status}' == '${port_status.lower()}'  ${status}  ${FALSE}

    END

    [Return]  ${status}

Set BTS SMs PDU port status
    [Documentation]
    ...  Keyword used to set BTS SMs PDU port status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Default | Description                     |
    ...  | BTS_SM_PDU_if_name_list | Yes  |         | List of BTS SMs interface names |
    ...  | port_status             | Yes  |         | Requested PDU port status       |
    ...
    ...  *RETURN*
    ...  | Parameter | Description                                         |
    ...  | status    | Returns True or False depending on interface status |

    [Arguments]  ${BTS_SM_PDU_if_name_list}  ${port_status}

    ${status}=  Set Variable  ${TRUE}

    FOR  ${item}  IN  @{BTS_SM_PDU_if_name_list}

        ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
        Continue For Loop If  '${PDU_port_status}' == '${port_status.lower()}'

        Run Keyword If  '${port_status.lower()}' == 'on'
        ...  Pdu BTS Interface On  ${item}
        ...  ELSE IF  '${port_status.lower()}' == 'off'
        ...  Pdu BTS Interface Off  ${item}

        ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
        ${status}=  Set Variable If  '${PDU_port_status}' == '${port_status.lower()}'  ${status}  ${FALSE}

    END

    [Return]  ${status}

Recover BTS SMs PDU port status
    [Documentation]
    ...  Keyword used to recover BTS SMs PDU port status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Default | Description                          |
    ...  | BTS_SM_PDU_if_name_list | Yes  |         | List of BTS SMs interface names      |
    ...  | port_status             | Yes  |         | Requested PDU port status            |
    ...  | alias                   | Yes  |         | BTS admin instance alias             |
    ...  | wait_time               | No   | 300     | Waiting time (secs) for BTS recovery |

    [Arguments]  ${BTS_SM_PDU_if_name_list}  ${port_status}  ${alias}  ${wait_time}=300

    ${status}=  Check BTS SMs PDU port status  ${BTS_SM_PDU_if_name_list}  ${port_status}
    Return From Keyword If  ${status}

    ${status}=  Set BTS SMs PDU port status  ${BTS_SM_PDU_if_name_list}  ${port_status}

    Run Keyword If  not ${status}  Run Keywords
    ...  Log  Recover BTS ${alias} SMs PDU port status failed  level=ERROR
    ...  AND  Fail  Recover BTS ${alias} SMs PDU port status failed

    Log  Recover BTS ${alias} SMs PDU port status indicated  console=True
    Log  Wait ${wait_time} seconds for BTS ${alias} reactivity  console=True
    Sleep  ${wait_time}sec
