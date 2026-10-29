*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta_pcmd
Library     ../../PCMD/verifier_msg_for_pcmd.py
Library     ../../../../../VRF_WRO2_T07/resources_btc/suite_setup.py
Library    OperatingSystem
Library    BuiltIn

*** Keywords ***
Install Wireshark Plugins
    ${wireshark_version}=  suite_setup.Get Wireshark Version
    suite_setup.Detect Plugin    ${wireshark_version}
    suite_setup.Download Wireshark Plugins  ${wireshark_version}

Wait for Error
    [Arguments]    ${keyword}    ${args}    ${expected_error}    ${timeout}
    ${end_time}=    Evaluate    time.time() + ${timeout}    modules=time
    FOR    ${i}    IN RANGE    0    10
        ${error}=    Run Keyword and Ignore Error    Run Keyword And Expect Error
        ...          ${expected_error}    ${keyword}    &{args}
        Run Keyword If    '${error[0]}' == 'PASS'    Install Wireshark Plugins
        Run Keyword If    '${error[0]}' == 'PASS'    Return From Keyword    ${error[1]}
        Sleep    1s
        ${time_now}=    Evaluate    time.time()
        Run Keyword If    ${time_now} > ${end_time}    Log    Success: Plugin loaded successfully.
    END

Start PCMD message collection
    &{args}=    Create Dictionary    ip=10.0.1.1    port=49150    technology=5G    asn1per_decoding=True
    Wait For Error    keyword=Configure PCMD    args=&{args}    expected_error=PluginInstallationFailed    timeout=30
    Start collecting PCMD reports

Start VRAN PCMD message collection
    Configure PCMD    technology=5G    asn1per_decoding=${True}    ip=192.168.100.126     tshark_interface=eth5
    Start collecting PCMD reports

Stop PCMD message collection
    Stop collecting PCMD reports
    Deconfigure PCMD

Clear PCMD records
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Clear Already Collected Pcmd Reports

Reset PCMD database
    Clear PCMD records
    Clear yaml variables
    Clear Fields Saved From Messages
    Remove All Records For Verification
