*** Settings ***
Documentation   This library shall contain the keywords that are needed specifically for gnb related operation

Library      Collections
Library      DateTime
Library      OperatingSystem
Library      String
Library      Telnet
Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark
Variables       ta5g_global_var
Variables       ${CURDIR}/../PythonLib/tshark_filters


*** Variables ***
${GNB_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USERNAME}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASSWORD}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${BSR_PACKAGE}      ${CURDIR}/BSR
${BSR_PCG_NAME}     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip


*** Keywords ***
GNB Graceful Reset
    [Documentation]    GNB Graceful Reset is Done using this Keyword
    admin.Setup Admin
    admin.Reset Site
    [Teardown]    admin.Teardown Admin

GNB Delta Commission
    [Documentation]    GNB Delta Commission where delta file is in .json format.
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup Admin
    Log To Console   ${EXEC_DIR}
    admin.Perform Delta Recommissioning        delta_file=${delta_file}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown Admin

Start Pcap Collection In GNB CU
    [Documentation]    Start Pcap collection In GNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0    ${gnb_id}=0
    ${executor_oam_vm}  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.Create Tcpdump Collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.Setup Collectors    names=${name}
    core.Start Collectors    names=${name}
    tcpdump.Set test Alias    ${name}

Stop Pcap Collection In GNB
    [Documentation]    Stop Pcap Collection In GNB name is aleas and path where to store the file.
    [Arguments]        ${name}       ${Log_Path}
    core.Stop Collectors        names=${name}
    core.Collect Collectors     names=${name}       target_dir=${Log_Path}
    core.Teardown Collectors    names=${name}

Online NIDD Parameter Change
    [Documentation]    This Keyword used to update NIDD parameter(one at a time)
    ...                and returns the result
    ...    [Arguments]
    ...    parameter        :  Parameter names to parsed
    ...    paramDst         :  Dist name should be parsed
    ...    paramValue       :  Value for the parameter to be assigned should be parsed
    ...    operation        :  Deffault Value given as update, and can be parsed other operation if required
    ...    should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
    ...    skip_parameter_relation_errors : Default Value is True if you want to set this False
    ...                                     then parse the parameter as False
    [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
    ...                ${paramDst}='None'                  ${operation}=update
    ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.Perform Parameter Recommissioning          parameter=${paramName}
    ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
    ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...        should_activate=${should_activate}    timeout=${timeout}

Get SCF Value From File
    [Documentation]     Get SCF Value From File
    [Arguments]         ${dir_path}=${Log_Path}         ${config_scf}=Configuration_scf
	admin.Setup Admin
	${result}	        admin.Get Current Scf File      ${dir_path}	    ${config_scf}.xml	    60
    Log    ${result}
	[Teardown]          admin.Teardown Admin

Backup Scf
    [Documentation]    This keyword is to back up SCF file
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...    | Input Parameters | Man. | Description |
    ...    | log_dir | Yes | the folder directory to store the scf file |
    ...    | scf_backup_name | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
    ...    Examples:
    ...    | Backup Scf | SUITE_LOG_DIRECTORY | before_suite |
    ...    | Backup Scf | TEST_LOG_DIRECTORY | after_suite |
    [Arguments]    ${log_dir}    ${scf_backup_name}
    Log To Console    Backup Scf...
    Run Keyword And Ignore Error    admin.Setup Admin
    admin.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml     timeout=60
    [Teardown]    Run Keyword And Ignore Error    admin.Teardown Admin

Add RD Parameters To GNB Swconfig File
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | rd_parametrs | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    [Arguments]    ${rd_parametrs}
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB        ${path}

Get Swconfig File From GNB
    [Documentation]    This keyword is to get swconfig.txt from gNB
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_PASSWORD} scp ${GNB_USERNAME}@${GNB_IP}:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Documentation]    This keyword is to send swconfig.txt to gNB and crasign the file
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${GNB_PASSWORD} scp ${path} ${GNB_USERNAME}@${GNB_IP}:/ffs/run/swconfig.txt
    Run      ssh ${GNB_USERNAME}@${GNB_IP} crasign /ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Modify Swconfig File Parameters
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if
    ...                 RD already exists.
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...    This keyword is excuted locally, not on gnb or airphone
    ...    | Input Parameters | Man. | Description |
    ...    | path | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | rd_parametrs | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    [Arguments]    ${path}    ${rd_parametrs}
    ${content}     OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${key}    ${val}    String.Split String    ${item}    =    1
        ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
        ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
        ...    ${content}    ${matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

Get Single Value From Scf File
    [Documentation]    This keyword is to get single parameter value from SCF file
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    ${root}    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}
    ...    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Set Single Value From Scf File
    [Documentation]    Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    ${root}    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Modify VlanId In SCF File
    [Documentation]    Modify VlanId In SCF File
    [Arguments]    ${scf_path}
    ${vlan_id}    Convert To String    ${VLAN_ID}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId
    Log To Console    VlanId in Testline: ${vlan_id}
    Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
    Set Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}

Full Commission With SCF File For UTE
    [Documentation]    Full Commission With SCF File For UTE
    [Arguments]    ${scf_file}
    Modify VlanId In SCF File    ${scf_file}
    # ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_file}
    #     dist_name=${vlanif_distname}     para_name=vlanId
    Get Single Value From Scf File    file_path=${scf_file}    dist_name=${vlanif_distname}     para_name=vlanId
    File Should Exist   ${scf_file}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    admin.Setup Admin
    admin.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    admin.Teardown

Add RD Parameters Directly On GNB
    [Documentation]    This keyword directly appends RD parameters to swconfig.txt on gNB without backup.
    ...                Each parameter is sent separately to avoid "Argument list too long" error.
    ...                Author: bhakti.patel@nokia.com
    ...                Last Modified: 16-July-2025
    ...    | Input Parameters | Man. | Description |
    ...    | rd_parametrs | Yes | str joined by ; like: 0x580019=1;0x580011=0 |
    [Arguments]    ${rd_parametrs}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${cmd}    Set Variable    echo "${item}" >> /ffs/run/swconfig.txt
        Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} '${cmd}'
    END
    Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} 'crasign /ffs/run/swconfig.txt'

Delete Added RD Parameters From GNB
    [Documentation]    This keyword removes previously added RD parameters from swconfig.txt on gNB line-by-line.
    ...                Each parameter is deleted with sed using pattern matching.
    ...                Author: bhakti.patel@nokia.com
    ...                Last Modified: 16-July-2025
    ...    | Input Parameters | Man. | Description |
    ...    | rd_parametrs | Yes | str joined by ; like: 0x580019=1;0x580011=0 |
    [Arguments]    ${rd_parametrs}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${keyval}    String.Split String    ${item}    =    1
        ${key}    Set Variable    ${keyval[0]}
        ${cmd}    Set Variable    sed -i '/^${key}\s*=.*/d' /ffs/run/swconfig.txt
        Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} '${cmd}'
    END
    Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} 'crasign /ffs/run/swconfig.txt'

Update BSR Package For RJIO
    [Documentation]    Update Beamforming packages in RJIO TL
    [Arguments]     ${user}=rfch37      ${Pass}=cmVmdGtuOjAxOjE4MjA3NDA4OTA6OWplOWJ1YUVBenNWbE1kdUc2dHQ0UDJ2M0Jj
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set Variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=${user} --password=${Pass} -P ${CURDIR}/BSR
    admin.Setup Admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    admin.Teardown Admin

