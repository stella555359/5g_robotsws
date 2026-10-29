*** Settings ***
Documentation
...    = Author = Michał Moskała
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_CRL29619_FeVe_03_Check_SNI_message_extension_with_direct_connection_without_FQDN
    [Documentation]    This Test Case verifies presence of TLS extension - Server Name Indication - when eNB uses direct connection to SAS Server.
    [Timeout]          20 min

    ${ims_alias}      Set Variable    RAT_1ST
    ${enb_user}       Set Variable    ${credentials.enb_username}
    ${enb_password}   Set Variable    ${credentials.enb_password}
    ${enb_id}         Set Variable    ${testlines.${testline_id}.enb_id}
    ${SAS_ip}         Set Variable    ${testlines.${testline_id}.vm_ip}
    ${SAS_port}       Set Variable    4433

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
    ...    parameter=primarySasServer
    ...    operation=update
    ...    value=${SAS_ip}:${SAS_port}
    ...    connection=${ims_alias}

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    port=${SAS_port}    version=1.2

    Start Remote TCPDUMP On eNB    enb_user=${enb_user}    enb_password=${enb_password}
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered     enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Stop Remote TCPDUMP On eNB And Download Traces    enb_user=${enb_user}    enb_password=${enb_password}
    Read Trace File And Assert Lack Of SNI Presence    IP_address=${SAS_ip}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir            alias=default
    ...                                                               AND
    ...                           SSHLibrary.Close All Connections    AND
    ...                           Kill All SAS Processes
