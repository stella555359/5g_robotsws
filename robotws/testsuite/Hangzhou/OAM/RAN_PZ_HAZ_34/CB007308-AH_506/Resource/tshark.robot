*** Settings ***

Library  Process
Library  taf.transport.ssh  WITH NAME  transport_ssh
Library  OperatingSystem
Library  String
Library  Collections
Library  pcapFiltering.py


*** Variables ***
${SerwerConnectionAlias}     SerwerConnection

*** Keywords ***
# 10.42.209.252

capture pcap
    [Arguments]  ${outputPath}   ${captureTimeInSeconds}


#    ${outputPath}   set variable   /home/ute/testRemote.pcap
    Run     tshark -i eth0 -w /home/ute/Remote.pcap -F pcap -a duration:${captureTimeInSeconds}
    ${captureTimeInSeconds}=    Convert To Integer   ${captureTimeInSeconds}
    sleep  ${captureTimeInSeconds + 1}
    ${output}=    run and return rc and output    tshark -r /home/ute/Remote.pcap
#    log to console  ${output}



check if pcap contains logs with filter
    [Arguments]   ${filter}      ${capturePath}
    ${return_code}   ${logs} =    Run And Return Rc And Output    tshark -r "${capturePath}" -F pcap -Y "${filter}"
    should be equal as integers    0    ${return_code}     Some error ocurred during running tshark: ${logs}
    ${lines}     get packets from string  ${logs}
#    log  filtered logs: ${lines}
    ${number_of_captured_packages}  get length  ${lines}
    return from keyword if  ${number_of_captured_packages} > 0   ${True}
    [Return]  ${False}
