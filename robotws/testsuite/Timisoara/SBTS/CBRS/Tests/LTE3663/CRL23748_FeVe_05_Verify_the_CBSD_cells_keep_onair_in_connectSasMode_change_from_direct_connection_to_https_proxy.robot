*** Settings ***
Documentation
...    = Author =
...    albert.sakowicz@nokia.com
...    = Maintainer =
...    albert.sakowicz@nokia.com
...    = Reviewers =
...    michal.moskala@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific
...    = Summary =
...    Purpose of this test is to verify whether eNB is able to perform kind of online connection switch from
...    direct connection to through https proxy without an interruption on serviceability


*** Keywords ***
CRL23748_FeVe_05_Verify_the_CBSD_cells_keep_onair_in_connectSasMode_change_from_direct_connection_to_https_proxy
    [Documentation]    Requirement ID: OM_GEN_SFS_NetSec.2038
    [Timeout]  25min
    Log    Step 0: Killing old SAS if existing, initializing variables    console=true
    ${vm_ip}              Set Variable    ${testlines.${testline_id}.vm_ip}
    ${alias}              Set Variable    RAT_1ST
    ${enb_id}             Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_ip}             Set Variable    ${testlines.${testline_id}.mplane_ip_addr}
    ${sas_port}           Set Variable    4433
    ${https_proxy_port}   Set Variable    4434
    @{allowed_alarms}     Set Variable    ${enb_allowed_alarms}
    Kill All SAS Processes
    Kill All SAS Proxy Processes
    Check If Cells Are Disabled    ${enb_id}

    Log    Step 1: Setting https proxy IP on the eNB    console=true
    Wait Until BTS Is Not Busy
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
    ...    parameter=primaryHttpsProxyServer
    ...    operation=update
    ...    value=${vm_ip}:${https_proxy_port}
    ...    connection=${alias}

    Log    Step 2: Starting SAS Sim and Https Proxy    console=true
    ${sas_pid}            ${sas_log}           Start SAS Process        alias=default    port=${sas_port}
    ${https_proxy_pid}    ${https_proxy_log}   Start SAS HTTPS Proxy    alias=default    port=${https_proxy_port}

    Log    Step 3: Waiting to get onair    console=true
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Capturing Historical Alarms

    Log    Step 4: Changing connection mode to https proxy    console=true
    Wait Until BTS Is Not Busy
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
    ...    parameter=connectToSasMode
    ...    operation=update
    ...    value=connect through https proxy
    ...    connection=${alias}

    Log    Step 5: Waiting for connection switch    console=true
    Repeat Keyword    30    Check If Cell Status Remains Onair

    Log    Step 6: Logs verification    console=true
    ${https_log_check}   Run    grep "created a tunnel ${enb_ip}" ${https_proxy_log} | grep "${vm_ip}:${sas_port}" | wc -l
    ${sas_log_check}     Run    grep "accepted new connection from ${vm_ip}:*" ${sas_log} | wc -l
    Should Be True    ${https_log_check}
    Should Be True    ${sas_log_check}

    Log    Step 7: Checking if it's still onair    console=true
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir

    Log    ALL GOOD, time for teardown    console=true
    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Get SAS Proxy Logs To Logs Dir    alias=default    AND
    ...                           Run Keyword And Continue On Failure    Save And Check Historical Alarms
    ...                           expected_alarms=@{allowed_alarms}    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Perform Parameter Recommissioning
    ...                           dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
    ...                           parameter=connectToSasMode
    ...                           operation=update
    ...                           value=direct connect to SAS server
    ...                           connection=${alias}    AND
    ...                           Kill All SAS Proxy Processes