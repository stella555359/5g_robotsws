*** Settings ***
Documentation    Suite description

Library     DateTime
Library     String
Library     taf.rfrl.csv4all.CSV4AllTestCases
Library     taf.rfrl.utilities.cloud_manager.artifacts
Library     taf.nms.netact    WITH NAME    netact
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations   WITH NAME    gnb_du_operations
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    gnb_asir_hub_operations
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnb_cell_operations
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library     taf.sbts.oam.sc.rest    WITH NAME    Rest
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   netacts.py



*** Variables ***
${NETACT_NAME}=              ${tl.nms.netact.https_main_info.addr}
${WEB_URL}=                  https://${NETACT_NAME}/authentication/Login
${USERNAME}=                 ${tl.nms.netact.ssh_connections_info.username}
${PASSWORD}=                 ${tl.nms.netact.ssh_connections_info.password}
${NODE_IP}=                  ${tl.nms.netact.ssh_connections_info.addr}
${GNB_ID}=                   ${tl.gnbs[0].global_bts_id}
${MO_MRBTS_ID}=              ${tl.netact_dn}
${MO_ASI_ID}=                ${tl.netact_asir_dn}
${MO_MRBTS_ADDR}=            ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${MRBTS_LMP_ADDR}=           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${MRBTS_LMP_USERNAME}=       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${MRBTS_LMP_PASSWORD}=       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${REMOTE_VM_IP}=             ${tl.test_pc.default_ssh_connection_details.addr}
${WARN_CONTENT_MISMATCH}=    Content mismatch with metadata detected
${SEND_TRUCK_ROLL_EMAIL}=    ${False}


@{CUSTOM_ALARMS}               61648   # LMP connectivity detected
...                            4681    # Sanity Check Error
...                            61649   # LMP access via port $port
...                            4655    # Service account root access is enabled
...                            61524   # SSH enabled
...                            4654    # Ethernet port security is disabled
...                            4420    # GPS receiver alarm: firmware upgrade ongoing
...                            61652   # R&D Service Port enabled
...                            4700    # TX Power too low
...                            4699    # TX Bias Current too low
...                            4479    # Failure detected on assigned antennas - agreed with dev
...                            7107



*** Keywords ***
Test Setup
    [Arguments]    ${service_name}
    Common Preconditions
    Add Node And Web Url    service_name=${service_name}
    coam_admin.Setup Admin    update_interval=500

Test Teardown
    [Arguments]    ${service_name}
    coam_admin.Teardown All Aliases For Admin
    Delete Node And Clean    service_name=${service_name}
    Common Postconditions

Add Node And Web Url
    [Arguments]    ${service_name}
    netact.Add Node    service_name=${service_name}
    ...                hostname=${NODE_IP}
    ...                username=${USERNAME}
    ...                password=${PASSWORD}
    ...                alias=${NETACT_NAME}
    netact.Add Web Url    web_url=${WEB_URL}
    ...                   username=${USERNAME}
    ...                   password=${password}
   ...                   alias=${NETACT_NAME}

Delete Node And Clean
    [Arguments]    ${service_name}
    netact.Delete Node    service_name=${service_name}
    ...                   alias=${NETACT_NAME}
    netact.Clean All    alias=${NETACT_NAME}

Upload ASI Configuration
    ${upload_output}=   netact.Upload Configuration    dist_names=${MO_ASI_ID}
    ...                                                alias=${NETACT_NAME}
    Should Not Contain    ${upload_output}    ${WARN_CONTENT_MISMATCH}
    Should Contain    ${upload_output}    ASiR Upload finished

Pre-activate New Configuration Plan
    ${DATE}=    Get Current Date
    ${plan_name}=    Set Variable    Plan_for_ANTMOD_preactivation_${DATE}
    ${plan_conf}=    netact.Create Plan Configuration    name=${plan_name}
    ...                                                  alias=${NETACT_NAME}
    ${actual_conf}=    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${actual_mo}=    netact.Get Managed Object    configuration=${actual_conf}
    ...                                           mo_id=${MO_ASI_ID}
    ...                                           alias=${NETACT_NAME}
    ${meta_class}=    Set Variable    com.nokia.asi:ANTMOD
    ${ledCotrol_value}=    Set Variable    0
    netact.Create Managed Object    plan=${plan_conf}
    ...                             meta_class=${meta_class}
    ...                             meta_version=${actual_mo.meta_version}
    ...                             operation=UPDATE
    ...                             mo_id=${MO_ASI_ID}/ANTMOD-1
    ...                             alias=${NETACT_NAME}
    ...                             ledControl=${ledCotrol_value}
    FOR    ${iteration}    IN RANGE    2
        ${pre-activation_output}=    netact.Provision Plan    plan_name=${plan_name}
        ...                                              dist_names=${MO_ASI_ID}
        ...                                              backup_plan_name=Backup_${plan_name}
        ...                                              create_backup_plan=${False}
        ...                                              provisioning_operation=preactivate
        ...                                              alias=${NETACT_NAME}
        Should Contain    ${pre-activation_output}    ASiR Plan Validate finished
    END

