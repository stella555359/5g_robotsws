*** Settings ***
Documentation    Keywords for uploading corrected packet_iphy.lua
Library      Process

*** Keywords ***
Upload Fixed Iphy Plug
    Log to console    Uploading corrected packet_iphy.lua to /home/ute/.local/lib/wireshark/plugins/
    ${source_file}=    Set Variable    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/packet_iphy.lua
    ${destination_folder}=    Set Variable    /home/ute/.local/lib/wireshark/plugins/
    Run Process     sudo    rm    /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua
    Run Process     sudo    cp    ${source_file}    ${destination_folder}
