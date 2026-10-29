*** Settings ***
Library    XML
Library    String
Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh
Library    ../python/ReadConfig.py

*** Variables ***
# list of IP addresses to add to the test VM --> to check if it can be taken automatically from cfg files
@{IP_LIST}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137    10.0.1.138

*** Keywords ***
#ET test env additional config for ute cloud
Update TL for UTE Env
    [Documentation]                 To be used as FIRST keyword in Suite Setup
    ...                             Patch testline configure with missing configuration
    ...                             Download needed WTS config files from ???,
    ...                             Add IPs taken from @{IP_LIST} to the test VM
    # if "tl.core" is defined --> nothing to do
    Return From Keyword If          ${tl.core}
    # define "_lteemu" and "core" object for "tl" variable
    ReadConfig.add_wts_to_tl_variable    ${tl}
    # add the list of addresses in IP_LIST to the test VM
    Configure needed IP addresses for WTS
    # if WTS config files do not exist then copy them otherwise exit the KW
    ${core_alias}                   Connect to Core Vm
    ${file_exist}                   ssh.File Exists
    ...                             ${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             connection=${core_alias}
    Run Keyword If                  ${file_exist}                           Run Keywords
    ...                             BuiltIn.Log                             WTS config file exist, nothing to do
    ...               AND           Return From Keyword
    Return From Keyword If          ${file_exist}
    Copy Config Files For WTS

Connect to Core Vm
    [Documentation]                 SSh connect to Core VM
    [Arguments]                     ${alias}=ssh_core
    ssh.Connect_to                  hostname=${tl.core.default_ssh_connection_details.addr}
    ...                             username=${tl.core.default_ssh_connection_details.username}
    ...                             password=${tl.core.default_ssh_connection_details.password}
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
    ...                             Run Keywords
    ...                                 BuiltIn.Log                         ERROR - Missing of ${src_path} --> exit
    ...               AND               Return From Keyword    ${False}
    BuiltIn.Log                     Copying ${src_path} to ${dst_path}
    ${output}                       run                                     cp ${src_path} ${dst_path}
    # get the XML config file file name from the .cfg file
    ${cfg_path}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${cmd}                          set variable                            grep "^set_uec " ${cfg_path} | sed -e "s/.*file=//g" | cut -d " " -f1
    ${xml_file}                     run    ${cmd}
    # copy the XML file
    ${src_path}                     Set Variable                            ${tl.core.dir_path}/AirphoneConfig.xml
    ${dst_path}                     Set Variable                            ${tl.core.dir_path}/${xml_file}
    ${file_exist}                   ssh.File Exists                         ${src_path}    connection=${core_alias}
    # the .xml file may be missing (should not be used anymore)
    Run Keyword If                  not ${file_exist}
    ...                             BuiltIn.Log                             WARNING -  Missing of ${src_path}
    ...               AND           Return From Keyword    ${True}
    BuiltIn.Log                     Copying ${src_path} to ${dst_path}
    ${output}                       run                                     cp ${src_path} ${dst_path}

Configure needed IP addresses for WTS
    [Documentation]                 Used for UTE Cloud Airphone TL
    ${core_alias}                   Connect to Core Vm
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

