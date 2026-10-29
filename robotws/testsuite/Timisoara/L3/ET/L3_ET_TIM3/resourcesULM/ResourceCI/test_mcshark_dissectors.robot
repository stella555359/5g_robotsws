*** Settings ***
Resource   ../testline.robot
Library    ../python/MCSharkDissectors.py

*** Test Cases ***

Test Update of mcshark 
    [TAGS]            MCSHARK
    ${gnb_version}=   Get gNB SW version    gnb_id=${0}
    Log To console    \nfor gNodeb Version ${gnb_version}

    Update MCshark Dissector      ${gnb_version}   force=${True}
    
    ${installed_dissector}=    Get mcshark Dissector Name
    Log To Console    \nMCshark Dissector: ${installed_dissector}
