*** Settings ***
Documentation   This library shall contain the keywords that are needed specifically for gnb related operation

Library      String
Library      OperatingSystem
Library      DateTime
Library      Telnet
Library      Collections
Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark
Library      ta5g_commissioning
Variables       ta5g_global_var

*** Keywords ***
GNB Delta commission
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    Log to Console   ${EXEC_DIR}
    admin.Perform Delta Recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}     should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Start pcap collection in gNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0    ${gnb_id}=0
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop pcap collection in gNB CU
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

Get SCF Value from file
    [Documentation]    :Author: Vikash Kumar
    [Arguments]         ${dir_path}=${Log_Path}         ${config_scf}=Configuration_scf
	admin.Setup Admin
	${result}	        admin.Get Current Scf File      ${dir_path}	    ${config_scf}.xml	    60
	[Teardown]          admin.Teardown admin

Backup Scf
    [Arguments]    ${log_dir}    ${scf_backup_name}
    [Documentation]    This keyword is to back up SCF file
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${scf_backup_name} | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
    ...
    ...    Examples:
    ...    | Backup Scf | ${SUITE_LOG_DIRECTORY} | before_suite |
    ...    | Backup Scf | ${TEST_LOG_DIRECTORY} | after_suite |
    Log To Console    Backup Scf...
    Run Keyword And Ignore Error    admin.Setup admin
    admin.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml
    [Teardown]    Run Keyword And Ignore Error    admin.Teardown admin

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    [Documentation]    This keyword is to get swconfig.txt from gNB
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    [Documentation]    This keyword is to send swconfig.txt to gNB and crasign the file
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Run      ssh toor4nsn@192.168.255.129 crasign /ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Modify Swconfig File Parameters
    [Arguments]    ${path}    ${rd_parametrs}
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if
    ...                 RD already exists.
    ...                 Author: tom.toby@nokia.com
    ...                 Last Modified: 13-september-2023
    ...    This keyword is excuted locally, not on gnb or airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${path} | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | ${rd_parametrs} | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ${content}    OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
         Continue For Loop If    '${item}'=='${EMPTY}'
         ${key}    ${val}    String.Split String    ${item}    =    1
         ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
         ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
    ...    ${content}    @{matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Modify VlanId In SCF File
    [Arguments]    ${scf_path}
    ${vlan_id}    Convert To String    ${VLAN_ID}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    Log To Console    VlanId in Testline: ${vlan_id}
    Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
    Set Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}

Full Commission With SCF File For UTE
    [Arguments]    ${scf_file}
    Modify VlanId In SCF File    ${scf_file}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_file}    dist_name=${vlanif_distname}     para_name=vlanId
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
