*** Settings ***

Documentation  Maintainer: mateusz.kawka@nokia.com

Library    ca_BSRF_radio_operation.py
Resource   ca_BSSM_Ssh_telnet_connection_to_Rmod.robot
#Resource   hran_frame_sbts_siso.robot  # for testing
#Resource   ca_BSRF_general.robot  # for testing
#Library    hran_radio  #  for testing

*** Keywords ***
Get DAPD TX Power For All Pipes
    [Documentation]
    ...  KW returns dictionary
    ...  with RU tx power
    ...  for all antenna lines
    ...  If `print_table` argument is True (default)
    ...  KW prints table with tx power
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${rmod_sn}  ${print_table}=True  ${alias}=default

    ${dapd_tx_power_dict}  Create Dictionary
    ${product_name}  Get RU Product Name  ${rmod_sn}  alias=${alias}
    ${antennas}  Get Antenna Lines For RU  ${product_name}  TX  type_of_ant=virtual
    ${ru_family}  Get RU Family  ${product_name}

    Open Connection To Radio Module With Serial Number  ${rmod_sn}
    Run Keyword If  '${ru_family}'=='6.1'
    ...  Connect To SoC  First

    ${lists}  Get Dictionary Values  ${antennas}

    ${counter}  Set Variable  ${1}

    FOR  ${ants}  IN  @{lists}
        Run Keyword If  ${counter}==2
        ...  Connect To SoC  Second
        Get DAPD TX Power For Pipes  ${ants}  ${dapd_tx_power_dict}
        ${counter}  Set Variable  ${counter+1}
    END

     Run Keyword If  ${print_table}
    ...  DAPD Print Tx Power Table  ${dapd_tx_power_dict}  ${product_name}  ${RMOD_IP}

    [Return]  ${dapd_tx_power_dict}

    [Teardown]  SSHLibrary.Close Connection

Get DAPD TX Power For Pipes
    [Arguments]  ${antenna_lines}  ${dict}

    FOR  ${ant}  IN  @{antenna_lines}
        SSHLibrary.Write  dapd -vstat antenna${ant}
        ${output}  SSHLibrary.Read  delay=1s
        ${output}  Remove String Using Regexp  ${output}  \r|\n
        Run Keyword If  'status = Fail' in '${output}'
        ...  Fail  Cannot read TX power for antenna${ant} ! Maybe wrong ants mapping in ca_BSRF_radio_operation.py !
        ${power}  Evaluate  re.search(r'(?<=forwardPower = )\\d+.\\d+|-inf', '${output}').group(0)  re
        Run Keyword If  'inf' in '${power}' or '0.00' in '${power}'
        ...  Set To Dictionary  ${dict}  ant${ant}  OFF
        ...  ELSE  Run Keywords  Convert To Number  ${power}
        ...  AND  Set To Dictionary  ${dict}  ant${ant}  ${power}
    END

Get FRMON Power For All Carriers
    [Documentation]
    ...  KW returns dictionary
    ...  with RU tx or rx carriers power
    ...  for all antenna lines
    ...  If `print_table` argument is True (default)
    ...  KW prints table with tx or rx power
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${rmod_sn}  ${direction}  ${print_table}=True  ${alias}=default

    ${direction}  Evaluate  '${direction}'.lower()

    ${final_dict}  Create Dictionary
    ${product_name}  Get RU Product Name  ${rmod_sn}  alias=${alias}
    ${antennas}  Get Antenna Lines For RU  ${product_name}  ${direction}  type_of_ant=frmon
    ${ru_family}  Get RU Family  ${product_name}

    Open Connection To Radio Module With Serial Number  ${rmod_sn}  alias=${alias}
    Run Keyword If  '${ru_family}'=='6.1'
    ...  Connect To SoC  First

    ${lists}  Get Dictionary Values  ${antennas}
    ${flat_list}  Evaluate  [x for xs in ${lists} for x in xs]

    ${dict_of_power}  Evaluate  ({'ant'+ str(i):{} for i in ${flat_list}})

    ${counter}  Set Variable  ${1}

    FOR  ${ants}  IN  @{lists}
        Run Keyword If  ${counter}==2
        ...  Connect To SoC  Second
        ${carriers_power}  Get FRMON Power For Carriers  ${direction}  ${ants}  ${dict_of_power}
        Merge Dictionaries  ${final_dict}  ${carriers_power}
        ${counter}  Set Variable  ${counter+1}
    END

    ${final_dict}  FRMON Convert To Physical Antennas  ${final_dict}  ${product_name}  ${direction}
    Run Keyword If  ${print_table}
    ...  FRMON Print Carriers Power Table  ${final_dict}  ${product_name}  ${RMOD_IP}  ${direction}

    [Return]  ${final_dict}

Merge Dictionaries
    [Arguments]  ${final_dict}  ${carriers_power}

    FOR  ${key}  ${value}  IN ZIP  ${carriers_power.keys()}  ${carriers_power.values()}
        Set To Dictionary  ${final_dict}  ${key}  ${value}
    END


Get FRMON Power For Carriers
    [Arguments]  ${direction}  ${ants}  ${dict_of_power}

    ${cmd_map}  FRMON Set Carriers Map Command  ${ants}  ${direction}

    sshLibrary.Write  echo $'${cmd_map}' | frmonShellClient localhost 2000
    ${get_tx_ids_output}  sshLibrary.Read Until  connection closed

    ${command_list}  FRMON Set Carriers Power Command  ${get_tx_ids_output}
    sshLibrary.Write  echo $'${command_list}' | frmonShellClient localhost 2000
    ${measured_power_output}  sshLibrary.Read Until  connection closed
    ${carrier_power_dict}  FRMON Get Carriers Power Dictionary  ${measured_power_output}  ${dict_of_power}


    [Return]  ${carrier_power_dict}


Get FRMON Data For All Carriers
    [Documentation]
    ...  KW returns dictionary
    ...  with RU tx or rx carriers data
    ...  for all antenna lines
    ...  If `print_table` argument is True (default)
    ...  KW prints table with tx or rx carriers data
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${rmod_sn}  ${direction}  ${print_table}=True  ${alias}=default

    ${direction}  Evaluate  '${direction}'.lower()

    ${final_dict}  Create Dictionary
    ${product_name}  Get RU Product Name  ${rmod_sn}  alias=${alias}
    ${antennas}  Get Antenna Lines For RU  ${product_name}  ${direction}  type_of_ant=frmon
    ${ru_family}  Get RU Family  ${product_name}

    Open Connection To Radio Module With Serial Number  ${rmod_sn}  alias=${alias}
    Run Keyword If  '${ru_family}'=='6.1'
    ...  Connect To SoC  First

    ${lists}  Get Dictionary Values  ${antennas}
    ${flat_list}  Evaluate  [x for xs in ${lists} for x in xs]

    ${dict_of_data}  Evaluate  ({'ant'+ str(i):{} for i in ${flat_list}})

    ${counter}  Set Variable  ${1}

    FOR  ${ants}  IN  @{lists}
        Run Keyword If  ${counter}==2
        ...  Connect To SoC  Second
        ${carriers_data}  Get FRMON Data For Carriers  ${direction}  ${ants}  ${dict_of_data}
        Merge Dictionaries  ${final_dict}  ${carriers_data}
        ${counter}  Set Variable  ${counter+1}
    END

    ${final_dict}  FRMON Convert To Physical Antennas  ${final_dict}  ${product_name}  ${direction}
    Run Keyword If  ${print_table}
    ...  FRMON Print Carriers Data Table  ${final_dict}

    [Return]  ${final_dict}

Get FRMON Data For Carriers
    [Arguments]  ${direction}  ${ants}  ${dict_of_data}

    ${cmd_map}  FRMON Set Carriers Map Command  ${ants}  ${direction}

    sshLibrary.Write  echo $'${cmd_map}' | frmonShellClient localhost 2000
    ${get_tx_ids_output}  sshLibrary.Read Until  connection closed

    ${command_list}  FRMON Set Carriers Data Command  ${get_tx_ids_output}
    sshLibrary.Write  echo $'${command_list}' | frmonShellClient localhost 2000
    ${carriers_data_output}  sshLibrary.Read Until  connection closed
    ${carrier_data_dict}  FRMON Get Carriers Data Dictionary  ${carriers_data_output}  ${dict_of_data}

    [Return]  ${carrier_data_dict}

Connect To SoC
    [Documentation]
    ...  KW connects to first or second SoC
    ...  First SoC has IP 192.168.101.2
    ...  Second SoC has IP 192.168.101.3
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${soc}

    ${soc}  Convert To Lower Case  ${soc}
    Run Keyword If  '${soc}'=='first'
    ...  SSHLibrary.Write  ssh 192.168.101.2
    ...  ELSE IF  '${soc}'=='second'  SSHLibrary.Write  ssh 192.168.101.3
    ${output}  SSHLibrary.Read  delay=1s
    ${fingerprint}=  Run Keyword And Return Status   Should Contain  ${output}  fingerprint
    Run Keyword If  ${fingerprint}  SSHLibrary.Write  y

Get RU Product Name
    [Documentation]
    ...  KWs returns RU product name based on serial number
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${RMOD_SN}  ${alias}=default

    ${rmods_info}  Get Parameters For All  RMOD  alias=${alias}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${product_name}  Set Variable  ${rmod['productName']}
    END

    ${prod_exists}  Run Keyword And Return Status  Variable Should Exist  ${product_name}
    Run Keyword If  ${prod_exists}  Return From Keyword  ${product_name}
    ...  ELSE  Fail  RMOD with SN ${RMOD_SN} doesn't exists in configuration !


#for resource testing
#*** Test Cases ***
#[Setup]
#    Set Library Search Order  ute_admin  taf.sbts.oam.admin.admin
#    setup admin
#    setup infomodel
#    connect infomodel
#Test
##
##    #Get FRMON Power For Carriers
##    #Get DAPD TX Power For All Pipes  BL2221N4069
##    Get FRMON Data For All Carriers  L1182013373  RX
#    Get FRMON Power For All Carriers  L1181207093  TX
#    Get FRMON Data For All Carriers  L1181207093  TX
##    #Get Rx Power  172.16.9.129  192.168.255.1  ARGA
##    #Get Tx Carrier Data  172.16.9.130  192.168.255.1  AHFIG
##    #Log TX Power For All RU  method=frmon
##    #Get TX Carrier Data  172.16.33.128  192.168.255.1  AHEB
##
#[Teardown]
#    teardown admin
#    teardown infomodel




