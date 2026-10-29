*** Settings ***

Documentation     Keywords related to RF attenuator handling
...               :Author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

#Library    taf.hw.rf_attenuator               WITH NAME    attenuator
Library    taf.hw.rf_attenuator

*** Variables ***
&{P_attenuators}           &{EMPTY}


*** Keywords ***
Set eNB cell attenuation
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param ru_id: (default=0) Id/Number of radio module
    ...    :param port_id: (default=0) Id/Number of port of radio module
    [Arguments]    ${value_in_db}    ${enb_id}=${0}    ${ru_id}=${0}    ${port_id}=${0}
    ${attenuation_port}=    Set variable    ${tl.enbs[${enb_id}].rms[${ru_id}].attenuation_ports[${port_id}]}
    Set cell port attenuation    attenuation_port=${attenuation_port}    value_in_db=${value_in_db}
    Log    Attenuation of eNB${enb_id} RM${ru_id} port${attenuation_port.port_no} is set to ${value_in_db}dB
    ...    console=${P_console}


Set gNB cell attenuation
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    ...    :param port_id: (default=0) Id/Number of port of radio unit
    [Arguments]    ${value_in_db}    ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}    ${port_id}=${0}
    ${attenuation_port}=    Set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].attenuation_ports[${port_id}]}
    Set cell port attenuation    attenuation_port=${attenuation_port}    value_in_db=${value_in_db}
    Log    Attenuation of gNB${gnb_id} DU${du_id} RU${ru_id} port${attenuation_port.port_no} is set to ${value_in_db}dB
    ...    console=${P_console}


Set eNB all ports attenuation
    [Documentation]    :Author: Michele
    ...    :iterate the ports of HBTE Highly Beyond The Expectation defined in __init__.py file
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    [Arguments]    ${value_in_db}    ${enb_id}=${0}    ${ru_id}=${0}
    ${Att_port_num}=    Get length    ${tl.enbs[${enb_id}].rms[${ru_id}].attenuation_ports}
    FOR    ${Att_port_id}    IN RANGE    ${Att_port_num}
          Set eNB cell attenuation    value_in_db=${value_in_db}    enb_id=${enb_id}    ru_id=${ru_id}    port_id=${Att_port_id}
    END


Set gNB all ports attenuation
    [Documentation]    :Author: Michele
    ...    :iterate the ports of HBTE Highly Beyond The Expectation defined in __init__.py file
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param ru_id: (default=0) Id/Number of radio unit
    [Arguments]    ${value_in_db}   ${gnb_id}=${0}    ${du_id}=${0}    ${ru_id}=${0}
    ${Att_port_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].attenuation_ports}
    FOR    ${Att_port_id}    IN RANGE    ${Att_port_num}
        Set gNB cell attenuation    value_in_db=${value_in_db}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}    port_id=${Att_port_id}
    END


Attenuate all cells in testline
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in a testline
    ...    :param off_value: Attenuation value in db
    ...    :param is_sran_tl: boolean flag indicating whether the attenuation command shall be excuted once for GNB or twice (GNB and ENB) node type
    [Arguments]    ${off_value}=${95}    ${is_sran_tl}=${False}
    IF   not ${is_sran_tl}
        ${enb_num}=    Get length    ${tl.enbs}
        FOR    ${enb_id}    IN RANGE    ${enb_num}
            Set attenuation to all 4G RMs   enb_id=${enb_id}    off_value=${off_value}
        END
    END
    ${gnb_num}=    Get length    ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Set attenuation to all 5G DUs   gnb_id=${gnb_id}    off_value=${off_value}
    END


Set attenuation to all 4G RMs
    [Documentation]    :Author: Michele
    ...    attenuate all cells in 4G eNB
    ...    :param enb_id: id of eNB to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${enb_id}    ${off_value}=${95}
    ${rm_num}=    Get length    ${tl.enbs[${enb_id}].rms}
    FOR    ${ru_id}    IN RANGE    ${rm_num}
        Set eNB all ports attenuation    value_in_db=${off_value}    enb_id=${enb_id}    ru_id=${ru_id}
    END


Set attenuation to all 5G DUs
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in 5G gNB
    ...    :param gnb_id: id of gNB to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${gnb_id}    ${off_value}=${95}
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Set attenuation to all 5G radio units    ${gnb_id}     ${du_id}    ${off_value}
    END


Set attenuation to all 5G radio units
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    attenuate all cells in 5G gNB DU
    ...    :param gnb_id: id of gNB to be attenuated
    ...    :param du_id: id of DU to be attenuated
    ...    :param off_value: Attenuation value in db
    [Arguments]    ${gnb_id}     ${du_id}     ${off_value}=${95}
    ${ru_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus}
    FOR    ${ru_id}    IN RANGE    ${ru_num}
        Set GNB All Ports Attenuation    value_in_db=${off_value}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    END

### Private ###
Set Cell Port Attenuation
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...
    ...    :param attenuation_port: Attenuation port object
    ...    :param value_in_db: (String or Integer) Attenuation value in db
    ...
    [Arguments]    ${attenuation_port}    ${value_in_db}
    ${value_in_db}=    Convert to Integer    ${value_in_db}
    ${existing_attenuator_device}=    Check if attenuator is already setup
    ...    attenuator_ip=${attenuation_port.attenuator.ip_addr}
    ${random}=    Evaluate    random.randint(0, 10000)    modules=random, sys
    ${attenuator_device}=    IF    '${existing_attenuator_device}'=='None'    taf.hw.rf_attenuator.setup_attenuator
    ...    attenuator=${attenuation_port.attenuator}
    ...    alias=attenuator_device_${random}
    ...    ELSE
    ...    Set Variable    ${existing_attenuator_device}
    IF    '${existing_attenuator_device}'=='None'    Set to dictionary    ${P_attenuators}
    ...    ${attenuation_port.attenuator.ip_addr}=${attenuator_device}
    taf.hw.rf_attenuator.set_attenuation    port=${attenuation_port.port_no}    value=${value_in_db}    attenuator_device=${attenuator_device}
    ${attenuation}=    taf.hw.rf_attenuator.read_attenuation    port=${attenuation_port.port_no}    attenuator_device=${attenuator_device}
    Should Be Equal    ${attenuation}    ${value_in_db}


Check If Attenuator Is Already Setup
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...
    ...    :param attenuator_ip: IP of the attenuator
    ...
    [Arguments]    ${attenuator_ip}
    ${attenuator_ips}=    Get Dictionary Keys    ${P_attenuators}
    ${count}=    Get Match Count    ${attenuator_ips}    ${attenuator_ip}
    ${attenuator_device}=    IF    '${count}'!='${0}'    Get From Dictionary    ${P_attenuators}    ${attenuator_ip}
    RETURN    ${attenuator_device}


Set Attenuator To Max Value
    [Documentation]    :Author: Antje Jooss
    ...    This function shall be used to close all attenuator ports at the ende of a test suite.
    ...    Check if attenuator setup is done, count number of attenuator ports and set all port to defined value
    ...    :param existing_attenuator_device: attenuator device defined in __init__.py
    ...    :param attenuator_ip: IP address of attenuator device

    ${attenuator_counter}=  Get Length  ${tl.attenuators}

    FOR  ${i}  IN RANGE  ${0}  ${attenuator_counter}
        ${existing_attenuator_device}=    Check If Attenuator Is Already Setup
        ...    attenuator_ip=${tl.attenuators[${i}].ip_addr}
        ${attenuator_device}=    IF    '${existing_attenuator_device}'=='None'    taf.hw.rf_attenuator.setup_attenuator
        ...    attenuator=${tl.attenuators[${i}]}
        ...    alias=attenuator_device
        ...    ELSE
        ...    Set variable    ${existing_attenuator_device}
        IF    '${existing_attenuator_device}'=='None'    Set To Dictionary    ${P_attenuators}
        ...    ${tl.attenuators[${i}].ip_addr}=${attenuator_device}
        Set Attenuation For Each Attenuation Port  index=${i}  attenuator_device=${attenuator_device}
    END


Set Attenuation For Each Attenuation Port
    [Documentation]    :Author: Antje Jooss
    ...    This function shall be used to close all attenuator ports at the ende of a test suite.
    ...    Check if attenuator setup is done, count number of attenuator ports and set all port to defined value
    ...    :param port_counter: counts all ports of defined attenuator device
    [Arguments]    ${index}=${i}  ${attenuator_device}=${attenuator_device}
    # robocop: disable=too-few-calls-in-keyword
    FOR  ${port_no}  IN  @{tl.attenuators[${index}].attenuation_port_numbers}
        taf.hw.rf_attenuator.set_attenuation  port=${port_no}  value=${110}  attenuator_device=${attenuator_device}
    END


Set single cell attenuator
    [Arguments]    ${gnb_id}    ${on_value}=${0}   ${ru_id}=0
    ${Att_port_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[0].rus[${ru_id}].attenuation_ports}
    Set attenuation on each Port    ${Att_port_num}    ${ru_id}    ${gnb_id}    ${on_value}


Set attenuation on each Port
    [Arguments]    ${Att_port_num}    ${ru_id}    ${gnb_id}     ${on_value}=${0}
    # robocop: disable=too-few-calls-in-keyword
    FOR    ${Att_port_id}    IN RANGE    ${Att_port_num}
       Set gNB cell attenuation  value_in_db=${on_value}  gnb_id=${gnb_id}  du_id=${0}  ru_id=${ru_id}  port_id=${Att_port_id}
    END


Set attenuator
    [Arguments]    ${gnb_id}    ${on_value}=${0}
    ${ru_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[0].rus}
    FOR    ${ru_id}    IN RANGE    ${ru_num}
        ${Att_port_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[0].rus[${ru_id}].attenuation_ports}
        Set attenuation on each Port    ${Att_port_num}    ${ru_id}    ${gnb_id}    ${on_value}
    END

