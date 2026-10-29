*** Settings ***
Documentation
...             == Purpose ==
...             This file contains some tool keywords to be used for the UTE Cloud TL
...
...             == Description ==
...             *Concepts:*
...
...             This is a tool box
...
...             *Mecanism:*
...
...             This module propose mainly keywords to be used in the UTE Cloud TL:
...             - Update TL for UTE Env
...             - Connect to Core Vm
...             - Copy Config Files For WTS
...             - Configure needed IP addresses for WTS
...             - Save Used Basic File
...             - Clean Step2 Files
...             - Additional Checks on Step2 Files
...
...             *Examples:*
...             | Update TL for UTE Env | ${edaemonPort}=${22222} | ${egatePort}=${9880}
...             | Connect to Core Vm
...             | Copy Config Files For WTS
...             | Configure needed IP addresses for WTS
...             | Save Used Basic File | ${edaemonPort}=${22222} | ${egatePort}=${9880}
...             | Clean Step2 Files
...             | Additional Checks on Step2 Files
...


Library    XML
Library    String
Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh
Library    ../python/ReadConfig.py
Library    ../python/OsTool.py

*** Variables ***
# list of IP addresses to add to the test VM --> to check if it can be taken automatically from cfg files
@{IP_LIST}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137    10.0.1.138
...           10.0.1.102    10.0.1.103    10.0.1.104    10.0.1.105    10.0.1.106    10.0.2.121      10.0.1.12

*** Keywords ***
#ET test env additional config for ute cloud
Update TL for UTE Env
    [Documentation]                 To be used as FIRST keyword in Suite Setup
    ...                             Patch testline configure with missing configuration
    ...                             Download needed WTS config files
    ...                             Add IPs taken from @{IP_LIST} to the test VM
    ...
    ...                             This keyword is used to update the testline variable with the WTS configuration
    ...                             It supports both single WTS and multi WTS (MWTS) configurations.
    ...                             It also configures the needed IP addresses for WTS.
    ...                             The keyword connects to the Core VM, checks for the existence of WTS config files,
    ...                             and copies them if they do not exist. It also saves the used basic file with a date stamp.
    ...                             If the WTS config files do not exist, it raises an error.
    ...                             The keyword also cleans up any existing step2 files and performs additional checks on the step2 files.
    ...                             The keyword takes two optional arguments: ${edaemonPort} and ${egatePort},
    ...                             which default to 22222 and 9880, respectively.
    [Arguments]                     ${edaemonPort}=${22222}
    ...                             ${egatePort}=${9880}

    # if "tl.core" is defined --> nothing to do
    Return From Keyword If          ${tl.core}

    IF    ${nbVMwts} <= 1
            # define "_lteemu" and "core" object for "tl" variable
            ReadConfig.add_wts_to_tl_variable    ${tl}    ${edaemonPort}    ${egatePort}
            # add the list of addresses in IP_LIST to the test VM
            Configure needed IP addresses for WTS
            # if WTS config files do not exist then copy them otherwise exit the KW
            ${core_alias}                   Connect to Core Vm
            ${file_exist}                   ssh.File Exists
            ...                             ${tl.core.dir_path}/${tl.core.cfg_filename}
            ...                             connection=${core_alias}
            Run Keyword If                  ${file_exist}                           Run Keywords
            ...                             UteTools.Save Used Basic File
            Additional Checks on Step2 Files
            Copy Config Files For WTS
    ELSE
            # Log all default_ssh_connection_details in ${tl}
            Dated Log                       on "Update TL for UTE Env" starting point nbVMwts=>${nbVMwts}
            FOR    ${idx}                   IN RANGE    0      ${nbVMwts}
                ${core_alias}               Set Variable                          ssh_core_${idx}
                # define "_lteemu" and "core" object for "tl" variable
                ReadConfig.add_wts_to_tl_variable_mwts    ${tl}    ${edaemonPort}    ${egatePort}    ${idx}
                # add the list of addresses in IP_LIST to the test VM the new parameter is not mandatory
                # Configure needed IP addresses for WTS    ${idx}
                # if WTS config files do not exist then copy them otherwise exit the KW
                ${core_alias}                Connect to Core Vm_mwts  ${core_alias}    ${idx}
                # FTS Alias recording
                Append To List               ${alias_list}    ${core_alias}
            END
    END


Connect to Core Vm
    [Documentation]                 SSh connect to Core VM
    [Arguments]                     ${alias}=ssh_core
    ssh.Connect_to                  hostname=${tl.core.default_ssh_connection_details.addr}
    ...                             username=${tl.core.default_ssh_connection_details.username}
    ...                             password=${tl.core.default_ssh_connection_details.password}
    ...                             alias=${alias}
    [Return]                        ${alias}

Connect to Core Vm_mwts
    [Documentation]                 SSh connect to Core VM
    ...                             This is a specific version for MWTS (Multi WTS -Wireless Test System-) entities.
    [Arguments]                     ${alias}=ssh_core    ${idx}=0
    Dated Log                       Connect to Core Vm_mwts alias:${alias} idx:${idx}

    ssh.Connect_to                  hostname=${tl.test_pcs[${idx}].default_ssh_connection_details.addr}
    ...                             username=${tl.test_pcs[${idx}].default_ssh_connection_details.username}
    ...                             password=${tl.test_pcs[${idx}].default_ssh_connection_details.password}
    ...                             alias=${alias}
    [Return]                        ${alias}

Copy Config Files For WTS
    [Documentation]                 Config files are installed by UTE as basic_setup.cfg and AirphoneConfig.xml
    ...                             --> copy them using the "standard" names
    BuiltIn.Log                     Copying WTS config files
    ${core_alias}                   Connect to Core Vm
    # the .cfg file is mandatory
    ${src_path}                     Set Variable                            ${tl.core.dir_path}/basic_setup.cfg
    ${dst_path}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${file_exist}                   ssh.File Exists                         ${src_path}    connection=${core_alias}
    Run Keyword If                  not ${file_exist}
    ...                             Fatal Error                             ERROR - Missing of WTS configuration file ${src_path}
    BuiltIn.Log                     Copying ${src_path} to ${dst_path}
    ${output}                       run                                     cp ${src_path} ${dst_path}
    Run Keyword If                  ${file_exist}                       Run Keywords
    ...                             UteTools.Save Used Basic File
    # get the XML config file file name from the .cfg file
    ${cfg_path}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${cmd}                          set variable                            grep "^set_uec " ${cfg_path} | sed -e "s/.*file=//g" | cut -d " " -f1
    ${xml_file}                     run    ${cmd}
    Return From Keyword if          '${xml_file.replace("\n","").replace("\r","")}'=='set_uec'
    Dated Log                       AirphoneConfig.xml file still delived. Will be renamed as: ${xml_file}
    # copy the XML file
    ${src_path}                     Set Variable                            ${tl.core.dir_path}/AirphoneConfig.xml
    ${dst_path}                     Set Variable                            ${tl.core.dir_path}/${xml_file}
    ${file_exist}                   ssh.File Exists                         ${src_path}    connection=${core_alias}

    # the .xml file may be missing (should not be used anymore)
    Run Keyword If                  not ${file_exist}                       Run Keywords
    ...                             BuiltIn.Log                             WARNING - Missing of ${src_path}
    ...               AND           Return From Keyword                     ${True}
    BuiltIn.Log                     Copying ${src_path} to ${dst_path}
    ${output}                       run                                     cp ${src_path} ${dst_path}

Configure needed IP addresses for WTS
    [Documentation]                 Used for UTE Cloud Airphone TL
    [Arguments]                     ${core_alias}=ssh_core
    ${core_alias}                   Connect to Core Vm    ${core_alias}
    FOR    ${ip}    IN             @{IP_LIST}
       Configure IP for eth3 on VM
       ...                         alias=${core_alias}                     ip=${ip}
    END

Configure IP for eth3 on VM
    [Documentation]                 Used for UTE Cloud Airphone TL
    [Arguments]                     ${alias}                                ${ip}
    ssh.execute                     sudo ip addr add ${ip}/24 dev eth3      connection=${alias}
    ${output}                       ssh.execute
    ...                                 ip add | grep ${ip}                 connection=${alias}
    Should Contain                  ${output}                               ${ip}

Save Used Basic File
    [Documentation]                 Save used basic file, cfg and .lua if present
    [Arguments]                     ${edaemonPort}=${22222}           ${egatePort}=${9880}
    ReadConfig.add_wts_to_tl_variable    ${tl}    ${edaemonPort}    ${egatePort}
    OsTool.saveBasicFileWithDate           ${tl.core.dir_path}        ${tl.core.cfg_filename}      ${LOG_PATH}

Clean Step2 Files
    [Documentation]                 Clean step2 files
    ${cmd}                          Set Variable        rm ${tl.core.dir_path}/*step2.*
    ${cmd_result}    run     ${cmd}

Additional Checks on Step2 Files
    [Documentation]                 Additional Checks on Step2 Files
    ${isSimilar}          OsTool.ExistAndSimilar      ${tl.core.dir_path}/basic_setup.cfg         ${tl.core.dir_path}/${tl.core.cfg_filename}
    Run Keyword If                  ${isSimilar}==${True}             Clean Step2 Files
