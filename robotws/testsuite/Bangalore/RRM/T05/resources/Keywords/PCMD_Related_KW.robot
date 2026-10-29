*** Settings ***
Library             ta_pcmd
Library             ta_pcmd.tshark_plugin_configurator
Library             OperatingSystem
Library             ta5g_testline_management
Library             ../PythonLib/UTILS.py
Resource            ../Variables/PCMD_common_variables.robot
Library             taf.wts.runner    WITH NAME    wtsrunner

Documentation   :copyright: Nokia

*** Variables ***
${pluginPath}                               ta5g_testline_management.TSHARK_BIN_PLUGIN_PATH
${TSHARK_BIN_PLUGIN_PATH}                   /home/ute/.local/lib/wireshark/plugins
*** Keywords ***
get tshark version present on wts
    [Documentation]       This keyword to know the version of tshart present on wts
    ...     [return]      (float)current version of tshark on wts
    ...     [usage]       get tshark version present on wts
    ${tshark_version_oetails}       get tshark version
    [return]                        ${tshark_version_oetails}

Add Nestapx Prototcol plugin To Tshark for PCMD
    [Documentation]     This keyword is to add netapx protocol plugin to WTS for PCMD Tshark messages
    run                             sudo rm -rf ${TSHARK_BIN_PLUGIN_PATH}/3.6/epan/nsetapx*
    sleep                           2s
    Load Tshark Bin Plugin          technology=5G
    log to console                  ${TSHARK_BIN_PLUGIN_PATH}

start vm Interface
    Start Vm Ethernet Interface     if_name=eth3:SERVER      ip_with_mask=10.0.1.1/24

stop vm Interface
    stop_vm_ethernet_interface      if_name=eth3:SERVER      ip_with_mask=10.0.1.1/24

Configure PCMD Server
    [Documentation]    This keyword is to configure PCMD server,starts Python PCMD server to which eNB connects
    ...                and sends PCMD reports then starts tshark process with parameters.
    Configure PCMD                  technology=5G            asn1per_decoding=${True}
    sleep                           2s
    Start collecting PCMD reports
    sleep                           2s
    log to console                  PCMD server configured

unconfigure PCMD server
    [Documentation]    Stops tshark process then stops Python server.
    Stop collecting PCMD reports
    sleep                           2s
    Deconfigure PCMD
    sleep                           2s
    log to console                  PCMD server unconfigured

Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49151,49150,49149,49148,49147,49146,49145,49144,49143,49142,49141,49140,49139,49138,49137"
    ...         >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for 1778

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
    ...               File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=    OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    [Return]    ${preferences_exist}
