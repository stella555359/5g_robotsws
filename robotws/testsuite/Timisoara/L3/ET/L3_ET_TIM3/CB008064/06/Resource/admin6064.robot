*** Settings ***
Documentation   Keywords regarding ADMIN API connections and procedures.
...             Author:     Jakub Aniszewski
...             Contact:    jakub.aniszewski@nokia.com

Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library         taf.transport.ssh        WITH NAME   ssh
Library         taf.config.scf           WITH NAME   scf
Library         ../../../resources/admin_utils.py
Library         DateTime
Library         Collections
Library         String
Resource        ../../../resources/connections/connections.robot


*** Variables ***
${LMP_IP}=                  192.168.255.129  # ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBEM_USERNAME}=          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}=          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TEMP_ADMIN_CONN}=         temporary_admin_connection
${mrbts}=                   ${tl.gnbs[0].global_bts_id}

*** Keywords ***

Get Active Alarms From BTS 8064
    [Arguments]           ${connection}=${NONE}
#    ${connection}=        admin_utils.create connection if not exist
    ${connection}=        create connection if not exist 1
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    ${active_alarms}=     coam_admin.get_active_alarms
    ...                   connection=${connection}
    ${fault_ids}=         Get Fault Ids From Alarms 1
    ...                   active_alarms=${active_alarms}

    [Return]              ${active_alarms}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Create Connection If Not Exist 1
    [Arguments]    ${connection}    ${alias}

    IF    '${connection}' == '${NONE}'
        ${connection}=    admin.Connect to ADMIN    alias=${alias}
    END

    [Return]    ${connection}

Get Fault Ids From Alarms 1
    [Arguments]    ${active_alarms}

    ${fault_ids}=    Create List

    FOR    ${alarm}    IN    @{active_alarms}
        Append To List    ${fault_ids}    ${alarm['faultId']}
    END

    [Return]    ${fault_ids}
