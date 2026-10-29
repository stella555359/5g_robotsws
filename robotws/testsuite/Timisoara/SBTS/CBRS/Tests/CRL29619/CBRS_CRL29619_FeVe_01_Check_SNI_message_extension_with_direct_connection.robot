*** Settings ***
Documentation
...    = Author = Lukasz Lechowicz
...    lukasz.lechowicz@nokia.com
...    = Maintainer =
...    lukasz.lechowicz@nokia.com
...    = Reviewer =
...    albert.sakowicz@nokia.com
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_CRL29619_FeVe_01_Check_SNI_message_extension_with_direct_connection
    [Documentation]    This Test Case verifies presence of TLS extension - Server Name Indication - when eNB uses direct connection to SAS Server.


    ${ims_alias}           Set Variable    RAT_1ST
    ${enb_id}              Set Variable    ${testlines.${testline_id}.enb_id}
    ${SAS_IP}              Set Variable    ${testlines.${testline_id}.vm_ip}
    ${enb_user}            Set Variable    ${credentials.enb_username}
    ${enb_password}        Set Variable    ${credentials.enb_password}
    ${SAS_FQDN}            Set Variable    testing-sc-02.cbrsfqdn.com
    ${SAS_port}            Set Variable    4433
    ${FQDN_subdirectory}   Set Variable    v1.2

    Add SAS FQDN To Known Hosts On eNB    SAS_FQDN=${SAS_FQDN}    SAS_IP=${SAS_IP}    enb_user=${enb_user}    enb_password=${enb_password}
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}

    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${cbrspr_object}   Query Infomodel
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBRSPR_A-1
    ...    timeout=60
    ...    alias=${ims_alias}
    ${primary_sas_backup}   Set Variable    ${cbrspr_object['primarySasServer']}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Parameter Recommissioning    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
    ...                                         parameter=primarySasServer
    ...                                         operation=update
    ...                                         value=${SAS_FQDN}:${SAS_port}/${FQDN_subdirectory}
    ...                                         connection=${ims_alias}

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    port=${SAS_port}    version=1.2

    Start Remote TCPDUMP On eNB    enb_user=${enb_user}    enb_password=${enb_password}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered     enb_id=${enb_id}
    Start Watchdog Alarm Detection
    Stop Remote TCPDUMP On eNB And Download Traces    enb_user=${enb_user}    enb_password=${enb_password}
    Read Trace File And Verify SNI Presence    SAS_FQDN=${SAS_FQDN}

    [Teardown]    Run Keywords    Remove SAS FQDN From Known Hosts On eNB    enb_user=${enb_user}    enb_password=${enb_password}
    ...                                                                      SAS_FQDN=${SAS_FQDN}    SAS_IP=${SAS_IP}    AND
    ...                           Set Primary Sas Server    bts_id=${enb_id}    sas_ip=${primary_sas_backup}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           SSHLibrary.Close All Connections
