*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta_pcmd
Library     ../../PCMD/verifier_msg_for_pcmd.py

*** Variables ***

*** Keywords ***
Start PCMD message collection
    Configure PCMD    technology=5G    asn1per_decoding=${True}
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
