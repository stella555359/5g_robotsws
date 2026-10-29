*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library    Telnet

*** Keywords ***

Setup TDK Lambda Controller
    [Arguments]  ${ip_address}  ${port}=7777  ${tdk_address}=06  #${connection}=${BTS_ID}    #${alias}=${None}
    [Documentation]
    ...  Establish telnet connection to TDK Lambda Controller server
    ...
    ...  **Input Parameters:**
    ...
    ...    +---------------------------+--------+-----------------------------------------+
    ...    | Input Parameters          | Man.   | Description                             |
    ...    +===========================+========+=========================================+
    ...    | tdk_controller_ip_address | Yes    |  TDK Controller server IP address       |
    ...    +------------------+--------+--------------------------------------------------+
    ...    | tdk_controller_ip_port    | No    |  TDK Controller server IP port           |
    ...    +-------------------------+--------+-------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Setup TDK Lambda Controller  10.44.131.183  8888  07

    Logging With Timestamp
    ...  message=Setup TDK Lambda Controller ${ip_address} via port ${port}
    ...  style=ONGOING
    Telnet.Open Connection  ${ip_address}  port=${port}  #connection=${connection}    #alias=${alias}
    Telnet.Set Timeout  0.5s
    Telnet.Write Bare  ADR ${tdk_address}\r\n
    Sleep  1s
    Telnet.Read Until  OK
    Logging With Timestamp
    ...  message=TDK Controller connected !${\n}
    ...  style=DONE

Get Power Voltage From Lambda
    [Arguments]  ${mode}=MV
    [Documentation]
    ...  Get Power Voltage From Lambda (V)
    ...  Can be use in two modes: PV or MV
    ...  MV means actual output voltage
    ...  PV means output voltage setting
    ...
    ...  **Input Parameters:**
    ...
    ...    +---------------------------+--------+-----------------------------------------+
    ...    | Input Parameters          | Man.   | Description                             |
    ...    +===========================+========+=========================================+
    ...    | mode                      | No     |  MV or PV                               |
    ...    +------------------+--------+--------------------------------------------------+
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      ${voltage}  Get Power Voltage From Lambda  PV

    Telnet.Write Bare  ${mode}?\r\n
    Sleep  1s
    ${voltage}  Telnet.Read
    ${voltage}  Remove String  ${voltage}  \r
    [Return]  ${voltage}

Set Power Voltage On Lambda
    [Arguments]  ${voltage}
    [Documentation]
    ...  Set Power Voltage On Lambda (V)
    ...
    ...  **Input Parameters:**
    ...
    ...    +---------------------------+--------+-----------------------------------------+
    ...    | Input Parameters          | Man.   | Description                             |
    ...    +===========================+========+=========================================+
    ...    | voltage                   | Yes    |  Desired voltage for TDK Lambda         |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Set Power Voltage On Lambda  52

    Telnet.Write Bare  PV ${voltage}\r\n
    Sleep  1s
    Telnet.Read Until  OK
    Logging With Timestamp
    ...  message=Voltage set to ${voltage}V OK!

Set Output For TDK Lambda
    [Arguments]  ${output}
    [Documentation]
    ...  Set Output For TDK Lambda
    ...  ON or OFF
    ...  Applicable for recovery from Safe-State (AST OFF)
    ...
    ...  **Input Parameters:**
    ...
    ...    +---------------------------+--------+-----------------------------------------+
    ...    | Input Parameters          | Man.   | Description                             |
    ...    +===========================+========+=========================================+
    ...    | output                    | Yes    |  Set output ON or OFF                   |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Set Power Voltage On Lambda  52

    Telnet.Write Bare  OUT ${output}\r\n
    Sleep  1s
    Telnet.Read Until  OK
    Logging With Timestamp
    ...  message=OUTPUT ${output} set OK!
