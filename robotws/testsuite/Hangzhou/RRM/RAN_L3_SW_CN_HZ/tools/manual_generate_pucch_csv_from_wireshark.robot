*** Settings ***
Documentation    Put this robot file under path "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/tools"
Resource         ../resources/DevHZ5_resource.robot

*** Variables ***
${wireshark_pcap}    ${EMPTY}
${flag}    ra

*** Test Cases ***
Manual Generate Pucch Csv From Wireshark
    ${csv}=    Generate Pucch Csv From Wireshark    wireshark_pcap=${wireshark_pcap}    flag=${flag}
    Log To Console    ${csv}

*** Keywords ***
