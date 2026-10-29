*** Settings ***
Documentation
...             Common keywords
...             Authors: Dominik Kulaga, dominik.kulaga@nokia.com

Library    Process
Library    String
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    XML
Resource    ../commissioning/parameters.robot
Resource    ../commissioning/commissioning.robot

*** Variables ***
@{IPv4_ADDRESS}    M-Plane=${MPLANE_IPV4}
...                C-Plane=${X2C}
...                U-Plane=${X2U}
@{IPv6_ADDRESS}    M-Plane=${MPLANE_IPV6}

*** Keywords ***
Run Scan
   [Documentation]    Description:      Sending the nmap command to check which ports are open/closed.
   ...                                  The following command is executed:
   ...                                  sudo nmap (-6) ${scan_flag} -p- -vvv --reason --min-rate ${min_rate} --max-rate ${max_rate}
   ...                                  -oA ${TEST_OUTPUT_DIR}/nmap_results/${report_file_name} ${address}. From this
   ...                                  command the output is visible in files: .xml, .html, .gnmap, .nmap and .log.
   ...
   ...                                  From xml file the KW "_Get Ports from XML" searching all ports and the states
   ...                                  and parse to the list. The .html file is for easy manual checking.
   ...                                  The gnmap and nmap files showes the output from console and log files presents
   ...                                  errors and also output.
   ...                Return:           Return all ports from nmap command.
   ...                Author:           jagoda.kubacka@nokia.com
   ...                Modification:     14-05-2024 made by jagoda.kubacka@nokia.com
   [Arguments]         ${scan_type}     #example: TCP/SCTP/UDP
   ...                 ${scan_flag}     #example: -sU, sY
   ...                 ${min_rate}      #minimum rate
   ...                 ${max_rate}      #maximum rate`
   ...                 ${IP}=IPv4       #IPv4/IPv6
   Set Test Variable    ${TEST_OUTPUT_DIR}    ${OUTPUT_DIR}/${TEST_NAME}
   RUN    mkdir ${TEST_OUTPUT_DIR}
   Log    Clear files and create ${TEST_OUTPUT_DIR}/nmap_results folder    console=True
   _Nmap Setup
   Log    Changing the R&D Service Port Status and ethernetPortSecurityEnabled parameters    console=True
   Configure TLS versions    1_2=true
   Turn On TLS
   _Change Security Parameters    False    true
   ${IP_ADDRESSES}=    Set Variable If    '${IP}'=='IPv4'    ${IPv4_ADDRESS}    ${IPv6_ADDRESS}
   &{results}=    Create Dictionary
   FOR    ${ip_address}    IN    @{IP_ADDRESSES}
       ${interface}=    Set Variable    ${ip_address.split('=')[0]}
       ${address}=      Set Variable    ${ip_address.split('=')[1]}
       ${report_file_name}=     Set Variable    ${scan_type}_${interface}
       Log to console           Checking ports for ${interface}. The address is ${address}.    console=True
       ${is_ipv6}=    Evaluate    ":" in """${ip_address}"""
       IF    ${is_ipv6}
           ${result}=    Run Process    ${CURDIR}/nmap_command.sh
           ...    ${scan_flag}    ${min_rate}    ${max_rate}    -oA ${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}    ${address}
           ...    -6    stdout=${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}_output.log
           ...    stderr=${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}_errors.log
       ELSE
           ${result}=    Run Process    ${CURDIR}/nmap_command.sh
           ...    ${scan_flag}    ${min_rate}    ${max_rate}    -oA ${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}    ${address}
           ...    stdout=${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}_output.log
           ...    stderr=${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}_errors.log
       END
       Log          Saving all results (${report_file_name}) and checking the open/closed ports from XML file    console=True
       Log Many	    stdout: ${result.stdout}	stderr: ${result.stderr}
       Should Be Empty    ${result.stderr}
       _Convert XML To HTML    ${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}
       ${open_ports}    ${closed_ports}    ${filtered_ports}    _Get Ports from XML    ${TEST_OUTPUT_DIR}/nmap_results/${report_file_name}.xml
       Set To Dictionary    ${results}    ${interface}
       ...    {"open_ports": ${open_ports}, "closed_ports": ${closed_ports}, "filtered_ports": ${filtered_ports}}
   END
   Log                  Zipping all results    console=True
   _Save All Results    ${TEST_OUTPUT_DIR}
   [Teardown]    Run Keywords    Log    Changing the R&D Service Port and ethernetPortSecurityEnabled parameters    console=True
   ...           AND             _Change Security Parameters    True    false
   [Return]       ${results}

Get Ports From Output
    [Arguments]    ${result}    ${plane}    ${port_type}
    ${data}=    Evaluate    ${result}[${plane}]
    ${dict}=    Convert To Dictionary    ${data}
    ${ports}=    Get From Dictionary    ${dict}    ${port_type}
    [Return]    ${ports}

_Convert XML To HTML
    [Arguments]    ${file}
    Log    Converting XML report to HTML...    console=True
    ${output}=    Run Process    xsltproc    ${file}.xml    -o    ${file}.html
    Log    ${output.stderr}    console=True
    Should Be Empty    ${output.stderr}
    Log    ${output.stdout}    console=True
    [Return]    ${output.stdout}

_Save All Results
    [Arguments]    ${folder_name}
    ${current_date_time}=    Get Current Date
    ${current_date_time}=    Convert Date    ${current_date_time}
    ...    result_format=%d-%m-%Y_%H-%M-%S-%f
    ...    date_format=%Y-%m-%d %H:%M:%S.%f
    ${output}=    Run Process    ${CURDIR}/zip_all.sh    ${folder_name}   nmap_result_${current_date_time}

_Nmap Setup
    RUN                 chmod -R 777 ${CURDIR}/*.sh
    RUN                 rm -rf ${TEST_OUTPUT_DIR}/nmap_results
    RUN                 mkdir ${TEST_OUTPUT_DIR}/nmap_results

_Change Security Parameters
    [Arguments]    ${r&d_port}=False    ${ethernet_port}=true
    Change R&D Service Port Status          enable=${r&d_port}
    Change Parameter On BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     param_name=ethernetPortSecurityEnabled
    ...                                     param_value=${ethernet_port}

_Get Ports from XML
    [Arguments]    ${PATH_TO_XML}
    ${xml}=    OperatingSystem.Get File    ${PATH_TO_XML}
    ${ports}=    Get Elements    ${xml}    .//port
    &{port_state_dict}=    Create Dictionary
    @{open_ports}=    Create List
    @{closed_ports}    Create List
    @{filtered_ports}    Create List
    FOR    ${port}    IN    @{ports}
        ${port_id}=    Get Element Attribute    ${port}    portid
        ${states}=    Get Element    ${port}    state
        ${state}=    Get Element Attribute    ${states}    state
        Set To Dictionary    ${port_state_dict}    ${port_id}    ${state}
    END
    ${keys}=    Get Dictionary Keys    ${port_state_dict}
    FOR    ${key}    IN    @{keys}
        ${value}=    Get From Dictionary    ${port_state_dict}    ${key}
        Run Keyword If    '${value}'=='open'    Append To List    ${open_ports}    ${key}
        ...    ELSE IF    '${value}'=='closed'    Append To List    ${closed_ports}    ${key}
        ...    ELSE IF    '${value}'=='closed'    Append To List    ${filtered_ports}    ${key}
        ...    ELSE    FAIL
    END
    Log    All ports: ${port_state_dict}    console=True
    [Return]    ${open_ports}    ${closed_ports}    ${filtered_ports}

