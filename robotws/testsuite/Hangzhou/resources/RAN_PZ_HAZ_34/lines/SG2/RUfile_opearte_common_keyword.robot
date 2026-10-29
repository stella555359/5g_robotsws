*** Settings ***
Documentation    This is for RU file operate
...              file_path:Files to be processed on RU,for example:/mnt/factory/configs/unit/paths.txt
...              Contacts: lu.1.yu@nokia-sbell.com

Library        OperatingSystem
Library        Collections
Library        BuiltIn
Library        String
Library        taf.transport.ssh    WITH NAME    csn
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Variables     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/line_sg2_common_variable.py


*** Keywords ***
Delete RU file on RU
    [Arguments]  ${file_path}=${file_path}
    log to console    \n delete ${file_path}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP
    Dlete RU file      file_path=${file_path}    connection=RU
    BTS Site Rest

Add RU file on RU
    [Arguments]    ${file_path}=${file_path}   ${file_content}=${file_content}   ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master
    ...            ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254   ${connection}=GNB_OAM
    ...            ${asik_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...            ${asik_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    log to console    \n add ${file_path}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    ${ru_ip_addr}     Auto Get RU IP Address
    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${asik_username}
    ...                                         ru_password=${asik_password}
    ...                                         ru_index=${ru_index}
    ...                                         coam_connection=${connection}
    csn.send command    command=sudo touch ${file_path}   connection=RU
    csn.execute    command=sudo chmod 777 ${file_path}    connection=RU
    csn.send command    command=sudo echo -e "${file_content}" > ${file_path}   connection=RU
    ${file_output}    csn.execute    command=sudo cat ${file_path}    connection=RU
    log to console    \n ${file_output}
    BTS Site Rest

BTS Site Rest
    Perform BTS Site Reset
    Sleep    30s
    Run Keyword And Continue On Failure    COAM Wait for gnb ready and cell setup

Dlete RU file
    [Arguments]   ${file_path}    ${connection}
    csn.send command    command=sudo rm -rf ${file_path}   connection=${connection}
    sleep    3s

Auto Get RU IP Address
    [Arguments]  ${ru_index}=${1}   ${asik_alias}=ASIK Master   ${connection}=GNB_OAM
    ...          ${container_id}=0x1018
    ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    [Return]    ${ru_ip_addr}
