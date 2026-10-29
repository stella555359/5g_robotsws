*** Settings ***
Documentation    Resource file for PDU operation.
...   contact: Szymon Startek

Library          taf.hw.pdu  WITH NAME  pdu
Library          Collections


*** Keywords ***
Print Information About PDU Ports From Init
    [Documentation]
    ...  This KW is used to print info about PDU (ip address, model and ports) based on __init__.py.
    ...
    ...  | **Author:** szymon.startek@nokia.com


    FOR  ${pdu}  IN  @{tl.pdus}
        @{ports}=  Get PDU Ports From Init  ${tl}  ${pdu.addr}
        Log  \nModel: ${pdu.model}  console=True
        Log  IP: ${pdu.addr}  console=True
        Log  List of PDU ports: ${ports}  console=True
    END


Turn Off PDU Ports
    [Documentation]
    ...  This KW is used to turn off PDU ports.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+------------+--------------------------------------------------------+
    ...  | Parameter  | Mandatory? | Description                                            |
    ...  +============+============+========================================================+
    ...  | model      | Yes        | Model of PDU                                           |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | ip         | Yes        | IP address of PDU                                      |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | ports      | Yes        | List of PDU ports to turn off                          |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | version    | No         | Version of PDU. Needed for PDUs other than EPC 8220-1. |
    ...  |            |            | Default value is "" (empty string).                    |
    ...  +------------+------------+--------------------------------------------------------+
    ...
    ...  .. code-block:: robotframework
    ...
    ...     @{ports}=  Create List  1  2  4  6  7  8
    ...     Turn Off PDU Ports  model=EPC  ip=12.34.56.78  ports=${ports}  version=8221-1

    [Arguments]    ${model}  ${ip}  ${ports}  ${version}=""

    pdu.Setup PDU  model=${model}  host=${ip}  alias=BTS_mypdu_temp  version=${version}
    FOR  ${port}  IN  @{ports}
        pdu.Power Off  ${port}  BTS_mypdu_temp
    END


Turn On PDU Ports
    [Documentation]
    ...  This KW is used to turn on PDU ports.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+------------+--------------------------------------------------------+
    ...  | Parameter  | Mandatory? | Description                                            |
    ...  +============+============+========================================================+
    ...  | model      | Yes        | Model of PDU                                           |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | ip         | Yes        | IP address of PDU                                      |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | ports      | Yes        | List of PDU ports to turn off                          |
    ...  +------------+------------+--------------------------------------------------------+
    ...  | version    | No         | Version of PDU. Needed for PDUs other than EPC 8220-1. |
    ...  |            |            | Default value is "" (empty string).                    |
    ...  +------------+------------+--------------------------------------------------------+
    ...
    ...  .. code-block:: robotframework
    ...
    ...     @{ports}=  Create List  1  2  4  6  7  8
    ...     Turn On PDU Ports  model=EPC  ip=12.34.56.78  ports=${ports}  version=8221-1

    [Arguments]    ${model}  ${ip}  ${ports}  ${version}=""

    pdu.Setup PDU  model=${model}  host=${ip}  alias=BTS_mypdu_temp  version=${version}
    FOR  ${port}  IN  @{ports}
        pdu.Power On  ${port}  BTS_mypdu_temp
    END


Turn Off All PDU Ports From Init
    [Documentation]
    ...  This KW is used to turn off PDU ports based on __init__.py.
    ...
    ...  | **Author:** szymon.startek@nokia.com

    FOR  ${pdu}  IN  @{tl.pdus}
        @{ports}=  Get PDU Ports From Init  ${tl}  ${pdu.addr}
        Turn Off PDU Ports  ${pdu.model}  ${pdu.addr}  ${ports}  ${pdu.version}
    END


Turn On All PDU Ports From Init
    [Documentation]
    ...  This KW is used to turn on PDU ports based on __init__.py.
    ...
    ...  | **Author:** szymon.startek@nokia.com

    FOR  ${pdu}  IN  @{tl.pdus}
        @{ports}=  Get PDU Ports From Init  ${tl}  ${pdu.addr}
        Turn On PDU Ports  ${pdu.model}  ${pdu.addr}  ${ports}  ${pdu.version}
    END


Get PDU Ports From Init
    [Documentation]
    ...  This KW returns list of ports of PDU with IP address ${ip} based on __init__.py.
    ...  KW is not intended for use outside this resource.
    ...  It is used in "Turn Off All PDU Ports From Init" and "Print Information About PDU Ports From Init".
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+------------+---------------------------------------------+
    ...  | Parameter  | Mandatory? | Description                                 |
    ...  +============+============+=============================================+
    ...  | tl         | Yes        | Object of tl                                |
    ...  +------------+------------+---------------------------------------------+
    ...  | ip         | Yes        | IP address of PDU                           |
    ...  +------------+------------+---------------------------------------------+


    [Arguments]  ${tl}  ${ip}

    @{list}=  Create List

    ${enb_range}=  Run Keyword If  "${tl.enbs}"!="None"  Get Length  ${tl.enbs}  ELSE  Set Variable  ${0}
    FOR  ${i}  IN RANGE  ${enb_range}
        ${enb}=  Get From List  ${tl.enbs}  ${i}
        ${list}=  Get Rmod PDU Ports  ${enb.rms}  ${ip}  @{list}
        Run Keyword If  "${enb.system_module.common_units[0].pdu_port.pdu.addr}" == "${ip}"
        ...  Append To List  ${list}  ${enb.system_module.common_units[0].pdu_port.port_no}
    END

    ${gnb_range}=  Run Keyword If  "${tl.gnbs}"!="None"  Get Length  ${tl.gnbs}  ELSE  Set Variable  ${0}
    FOR  ${i}  IN RANGE  ${gnb_range}
        ${gnb}=  Get From List  ${tl.gnbs}  ${i}
        ${list}=  Get Rmod PDU Ports  ${gnb.dus[0].rus}  ${ip}  @{list}
        Run Keyword If  "${gnb.dus[0].airscale.common_units[0].pdu_port.pdu.addr}" == "${ip}"
        ...  Append To List  ${list}  ${gnb.dus[0].airscale.common_units[0].pdu_port.port_no}
    END

    @{list}=  Evaluate  set(@{list})
    Sort List  ${list}
    [Return]  @{list}


Get Rmod PDU Ports
    [Documentation]
    ...  This KW returns list of PDU ports from rmod list.
    ...  KW is not intended for use outside this resource. It is used in GET PDU PORTS FROM INIT.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+------------+---------------------------------------------+
    ...  | Parameter  | Mandatory? | Description                                 |
    ...  +============+============+=============================================+
    ...  | rmods      | Yes        | List of rmods                               |
    ...  +------------+------------+---------------------------------------------+
    ...  | ip         | Yes        | IP address of PDU                           |
    ...  +------------+------------+---------------------------------------------+
    ...  | list       | Yes        | List of PDU ports to append new ones        |
    ...  +------------+------------+---------------------------------------------+

    [Arguments]  ${rmods}  ${ip}  @{list}

    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  "${rmod.pdu_port.pdu.addr}" == "${ip}"  Append To List  ${list}  ${rmod.pdu_port.port_no}
    END
    [Return]  @{list}
