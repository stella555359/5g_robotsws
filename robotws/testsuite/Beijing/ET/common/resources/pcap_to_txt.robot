*** Settings ***
Documentation    Author: sheng.1.ye@nokia-sbell.com

Library    taf.transport.ssh           WITH NAME    ssh
Library    glob


*** Variables ***

${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark_na

${UTE_ADDRESS}      127.0.0.1
${UTE_USERNAME}     ute
${UTE_PASSWORD}     ute

*** Keywords ***

Connect To UTE
    SSH.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...   password=${UTE_PASSWORD}    alias=UTE

Convert Pcap To Text UTE
    [Arguments]  ${source}   ${filter}=""   ${target}=${None}   ${connection}=UTE

    ${new_target}       Set Variable          ${source}.txt
    ${target}             Set Variable If    ${target}==${None}     ${new_target}        ${target}
   
    Return From Keyword If     "${source}".endswith(".txt")
    Run Keyword If        not os.path.exists("${source}")      Log To Console        File ${source} does not exist!
    Return From Keyword If     not os.path.exists("${source}")

    SSH.send_command
    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    SSH.await execution end    connection=${connection}  timeout=30min
    Run Keyword If     os.path.exists("${target}")
    ...    Log To Console    Converting pcap file: ${source} to text: ${target} Done
    ...    ELSE   Log To Console    Converting pcap file: ${source} to text: ${target} Fail
    [Return]  ${target}

Batch Convert Pcap To Text UTE
    [Arguments]  ${source}   ${filter}=""    ${connection}=UTE
    @{source_list}      glob.glob         ${source}
    :FOR     ${source_file}   IN     @{source_list} 
    \        Convert Pcap To Text UTE     source=${source_file}   filter=${filter}   connection=${connection}
