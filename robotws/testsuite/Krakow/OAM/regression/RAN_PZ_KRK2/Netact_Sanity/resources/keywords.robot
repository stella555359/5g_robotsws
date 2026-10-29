*** Settings ***
Documentation
...    Author: Barbara Wozniak, barbara.wozniak@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Library     DateTime
Library     String
Library     re
Library     taf.sw.reporting_portal
Library     taf.nms.netact    WITH NAME    netact
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations   WITH NAME    gnb_du_operations
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME   gnb_commissioning
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    gnb_asir_hub_operations
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnb_cell_operations
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnb_alarm_verification
Library     taf.sbts.oam.coam.admin.interface.admin    WITH NAME    admin
Library     keywords.py
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.FR_5GC002421.custom_methods
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   netacts.py
Variables   qc_instances.py

*** Variables ***
${NETACT}                          srnclab2021
${NETACT_NAME}                     ${netacts['${NETACT}']['URL']}
${WEB_URL}                         https://${NETACT_NAME}/authentication/Login
${USERNAME}                        omc
${PASSWORD}                        Medsql!_1893
${SERVICE_USERNAME}                wsuser
${OLD_SERVICE_USERNAME}            wsuser
${SERVICE_PASSWORD}                A0zY~rP8Mx@
${OLD_SERVICE_PASSWORD}            A0zY~rP#8Mx@
${NODE_IP}                         ${netacts['${NETACT}']['IP']}
${CMP}                             ${netacts['${NETACT}']['CMP']}
${DELTA_CMP}                       ${cmps['cmp_${CMP}']}
${GNB_ID}                          ${tl.gnbs[0].global_bts_id}
${MO_MRBTS_ID}                     PLMN-PLMN/MRBTS-${GNB_ID}
${MO_ASI_ID}                       PLMN-PLMN/ASI-${GNB_ID}
${MO_MRBTS_ADDR}                   ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split('/')[0]}
${MO_ASI_MR}                       ${netacts['${NETACT}']['MR_ASI']}
${MO_MRBTS_MR}                     ${netacts['${NETACT}']['MR_MRBTS']}
${MRBTS_LMP_ADDR}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${MRBTS_LMP_USERNAME}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${MRBTS_LMP_PASSWORD}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${reference_number}                ${key['cmp_${CMP}']['reference_number']}
${preshared_key}                   ${key['cmp_${CMP}']['preshared_key']}
${PNP_PATH}                        /home/ute/pnp
${DOWNLOAD_PATH}                   /home/ute
${ARTIFACTORY_URL}                 https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${WARN_CONTENT_MISMATCH}           Content mismatch with metadata detected
${SHOULD_BE_REPORTED}              ${True}
@{CUSTOMERS_LIST}                  Generic
@{CUSTOM_ALLOWED_ALARMS}           61648   # LMP connectivity detected
...                                4681    # Sanity Check Error
...                                61649   # LMP access via port $port
...                                4655    # Service account root access is enabled
...                                61524   # SSH enabled
...                                4654    # Ethernet port security is disabled
...                                4420    # GPS receiver alarm: firmware upgrade ongoing
...                                61652   # R&D Service Port enabled
...                                4700    # TX Power too low
...                                4699    # TX Bias Current too low
...                                4479    # Failure detected on assigned antennas - agreed with dev
...                                6261    # Failure in internal BTS connection or connection to 3rd party tool
...                                6327    # Setup of X2 connectivity to gNB failed
...                                7308    # Transport layer connection failure in X2 interface
...                                61074   # CRL Update failure or certificate revoked
...                                7319    # No X2 link available for a specific LTEENB
...                                61510   # Automatic BTS Operator Certificate retrieval unsuccessful
@{ASIR_ALLOWED_ALARMS}             ${61648}    ${61510}
${QC_DOMAIN}                       MN_RAN
${QC_PROJECT}                      RAN_VRF
${RP_CA}                           VRF_OAM
${RP_ORGANIZATION}                 VRF_KRK_T02
${RP_LOCATION}                     VRF_KRK

&{BLOCK_ANTMOD_STATUS}             localState=blocked  operationalState=disabled
&{UNBLOCK_ANTMOD_STATUS}           localState=unblocked  operationalState=enabled

${UUF_PACKAGE}                     SBTS25R1_ENB_0000_001152_000000
${ITERATIONS}                      3
${TLS}                             ON

${INTEGRATION_MRBTS}               ${True}
${INTEGRATION_ASIR}                ${True}
*** Keywords ***
Suite Setup
    ${DATE}    Get Current Date
    Set Global Variable    ${DATE}
    ${package_items}    Split String    ${ENB_BUILD}    separator=_    max_split=2
    ${RELEASE}    Set Variable If    "${package_items}[0]"=="SBTS00"    SBTS26R3    ${package_items}[0]
    Set Global Variable    ${RELEASE}
    ${QC_PROJECT}    Set Variable If    "${RELEASE}"=="SBTS24R3"   RAN_ST    RAN_VRF
    Set Global Variable    ${QC_PROJECT}
    Set Global Variable    ${PACKAGE_VERSION}    ${package_items}[2]
    Set Global Variable    ${ENB_BUILD}    ${RELEASE}_${package_items}[1]_${package_items}[2]
    ${SECURITY_MODE}    Set Variable If    "${TLS}"=="ON" or "${TLS}"=="on"    TLS    no TLS
    Set Global Variable    ${SECURITY_MODE}
    Set Suite Variable    ${ASIR_ALLOWED_ALARMS}
    Common Suite Setup With OnAir Test Line Preparation
    ...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...              increase_time_for_checking_cells=600
    ...              increase_timeout_for_update_sw=1800
    ...              list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS}

    Run Keyword If    "${SECURITY_MODE}"=="no TLS"
    ...              gnb_commissioning.Perform Bts Delta Commissioning    delta=${oamtls_off}
    Run Keyword If    "${SECURITY_MODE}"=="TLS"    OamTLS ON
    Add Node And Check SW    service_name=fmwas    check_sw=${False}
    Run Keyword If    ${INTEGRATION_MRBTS}    Integrate_Mrbts
    Run Keyword If    ${INTEGRATION_ASIR}    Integrate_Asir
    Delete Node and Alias    service_names=fmwas

Change Service Account Password
    ${connection}    admin.Connect To
    Run Keyword And Ignore Error    admin.Modify Web Service User    username=${SERVICE_USERNAME}
    ...                                                              password=${SERVICE_PASSWORD}
    ...                                                              old_username=${OLD_SERVICE_USERNAME}
    ...                                                              old_password=${OLD_SERVICE_PASSWORD}
    ...                                                              connection=${connection}
    admin.Teardown    connection=${connection}

OamTLS ON
    gnb_commissioning.Perform Bts Delta Commissioning    delta=${oamtls_on}
    gnb_commissioning.Perform Bts Delta Commissioning    delta=${DELTA_CMP}
    gnb_du_operations.Set Certificate Automatic Managment    reference_number=${reference_number}  preshared_key=${preshared_key}
    ${connection}    admin.Connect To
    admin.Cmp Initialize Certificate       connection=${connection}     timeout=120s
    admin.Teardown    connection=${connection}

Integrate_Mrbts
    Deintegrate MRBTS    dist_name=${MO_MRBTS_ID}
    ...                  delete_db=${False}
    Change Service Account Password
    Sleep    60s    Wait for deintegration
    Integrate MRBTS With NetAct

Integrate_Asir
    Deintegrate ASI
    Sleep    60s    Wait for deintegration
    Integrate ASI With NetAct

Suite Teardown
    Common Suite Teardown

Test Setup
    [Arguments]    ${service_name}
    ...            ${check_sw}=${True}
    Set Test Variable    @{allowed_alarms}   @{CUSTOM_ALLOWED_ALARMS}
    Common Preconditions
    Add Node And Check SW   service_name=${service_name}    check_sw=${check_sw}

Add Node And Check SW
    [Arguments]    ${service_name}
    ...            ${check_sw}=${True}
    Add Node And Web Url    service_name=${service_name}
    admin.Setup Admin    update_interval=500
    ${gnb_active_sw_before_test}    admin.Get Sw Version
    Set Suite Variable    ${gnb_active_sw_before_test}
    Return From Keyword If    "${check_sw}"=="${False}"
    Should Be True    "${gnb_active_sw_before_test}"=="${ENB_BUILD}"


Test Teardown
    [Arguments]    ${service_name}
    Delete Node and Alias    service_name=${service_name}
    Common Postconditions

Delete Node and Alias
    [Arguments]    ${service_name}
    admin.Teardown All Aliases For Admin
    Delete Node And Clean    service_name=${service_name}

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

Deintegrate MRBTS
    [Arguments]    ${dist_name}
    ...            ${delete_db}=${False}
    Run Keyword And Ignore Error    netact.Deintegrate MRBTS From Netact    dist_name=${dist_name}
    ...                                                                     alias=${NETACT_NAME}
    Run Keyword And Expect Error    OSError:*    netact.Upload Alarms    dist_name=${dist_name}
    ...                                                                  alias=${NETACT_NAME}
    Return From Keyword If    not ${delete_db}
    ssh.Connect To    ${MRBTS_LMP_ADDR}    ${MRBTS_LMP_USERNAME}    ${MRBTS_LMP_PASSWORD}
    ssh.Execute    rm /rom/config/ne3sadapt/configs/ne3sadaptdata.db
    Sleep  30    Sleep for execute
    admin.Reset Site
    gnb_du_operations.Wait For Site To Be Onair

Deintegrate ASI
    ${deintegration_asir_result}    ${output}    Run Keyword And Ignore Error    netact.Deintegrate NE From Netact    dist_name=${MO_ASI_ID}
    ...                                                                                                               alias=${NETACT_NAME}
    Set Suite Variable    ${deintegration_asir_result}

Integrate MRBTS With NetAct
    ${integration_mrbts_result}    ${output}    Run Keyword And Ignore Error    netact.Integrate MRBTS With Netact    release=${RELEASE}
    ...                                                                                              mr=${MO_MRBTS_MR}
    ...                                                                                              mrbts_address=${MO_MRBTS_ADDR}
    ...                                                                                              dist_name=${MO_MRBTS_ID}
    ...                                                                                              security_mode=${SECURITY_MODE}
    ...                                                                                              alias=${NETACT_NAME}
    Should Match Regexp    ${output}    Completed to configure NE: \\[${MO_MRBTS_ID}\\]
    Should Match Regexp    ${output}    NE3S registration status: ${MO_MRBTS_ID}...\\s+\\[OK\\]
    Run Keyword If    '${integration_mrbts_result}'=='PASS'    Should Match Regexp    ${output}    Completed to verify NE: \\[${MO_MRBTS_ID}\\]
    Set Suite Variable    ${integration_mrbts_result}
    Return From Keyword If    '${integration_mrbts_result}'=='PASS'
    Log    \n\tProblem with verification, additional checks executed    console=${True}
    ${alarm_upload_match}    re.search     Alarm upload for object:    ${MO_MRBTS_ID}...\\s+\\[ NOK \\]    ${output}
    Run Keyword If    $alarm_upload_match is not None    Upload Alarms    dist_name=${MO_MRBTS_ID}
    ${cm_upload_match}    re.search    CM upload for ${MO_MRBTS_ID} \\[ NOK \\]    ${output}
    Run Keyword If    $cm_upload_match is not None    Upload MRBTS Configuration

Integrate ASI With NetAct
    ${release}    Replace String    ${RELEASE}    SBTS    ASI
    ${integration_asir_result}    ${output}    Run Keyword And Ignore Error    netact.Integrate ASI With Netact    release=${release}
    ...                                                          mr=${MO_ASI_MR}
    ...                                                          asi_address=${MO_MRBTS_ADDR}
    ...                                                          dist_name=${MO_ASI_ID}
    ...                                                          security_mode=${SECURITY_MODE}
    ...                                                          alias=${NETACT_NAME}
    Should Match Regexp    ${output}    Completed to configure NE: \\[${MO_ASI_ID}\\]
    Should Match Regexp    ${output}    NE3S registration status: ${MO_ASI_ID}...\\s+\\[OK\\]
    Run Keyword If    '${integration_asir_result}'=='PASS'    Should Match Regexp    ${output}    Completed to verify NE: \\[${MO_ASI_ID}\\]
    Set Suite Variable    ${integration_asir_result}
    Return From Keyword If    '${integration_asir_result}'=='PASS'

Block Cell
    gnb_cell_operations.Block All Cells
    Wait Until Keyword Succeeds    60 sec    10 sec    gnb_cell_operations.Verify All Cells Are Blocked

Unblock Cell
    gnb_cell_operations.Unblock All Cells
    Wait Until Keyword Succeeds    60 sec    10 sec    gnb_cell_operations.Verify All Cells Are Unblocked
    Wait Until Keyword Succeeds    60 sec    10 sec    gnbcell.Verify All Cells are OnAir

Upload Alarms
    [Arguments]    ${dist_name}
    ${upload_output}    netact.Upload Alarms    dist_name=${dist_name}
    ...                                         alias=${NETACT_NAME}
    Should Contain    ${upload_output}    Alarm Upload: SUCCESS

Alarm Upload For MRBTS
    Upload Alarms    dist_name=${MO_MRBTS_ID}
    Run Keyword and Ignore Error    netact.Cancel Alarms    dist_name=${MO_MRBTS_ID}
    ...                                                     alarm_number=41003
    ...                                                     alias=${NETACT_NAME}
    ${netact_alarms}    netact.Get Alarms    dist_name=${MO_MRBTS_ID}
    ...                                      alias=${NETACT_NAME}
    ${mrbts_alarms}    admin.Get Active Alarms Number
    ${fault_id}    Set Variable    ${49}
    ${fault_name}    Set Variable    Cell blocked
    gnb_alarm_verification.Verify Alarm Is Active    fault_name=${fault_name}
    ...                                              fault_id=${fault_id}
    Length Should Be    ${netact_alarms}    ${mrbts_alarms}
    Should Contain    ${netact_alarms}[0][additionalText3]    FaultID=${fault_id}

Block ANTMOD
    @{antenna_ids}    gnb_asir_hub_operations.Get All Antenna Ids
    gnb_asir_hub_operations.Block Antenna    ant_id=${antenna_ids}[0]
    Wait Until Keyword Succeeds    60 sec    10 sec    gnb_asir_hub_operations.Verify Antmod Status    ant_ids=${antenna_ids}[0]
    ...                                                                                                expected_statuses=${BLOCK_ANTMOD_STATUS}

Unblock ANTMOD
    @{antenna_ids}    gnb_asir_hub_operations.Get All Antenna Ids
    gnb_asir_hub_operations.Unblock Antenna    ant_id=${antenna_ids}[0]
    Wait Until Keyword Succeeds    60 sec    10 sec    gnb_asir_hub_operations.Verify Antmod Status    ant_ids=${antenna_ids}[0]
    ...                                                                                                expected_statuses=${UNBLOCK_ANTMOD_STATUS}
    Wait Until Keyword Succeeds    60 sec    10 sec    gnbcell.Verify All Cells are OnAir

Alarm Upload For ASI
    Upload Alarms    dist_name=${MO_ASI_ID}
    ${netact_alarms}    netact.Get Alarms    dist_name=${MO_ASI_ID}
    ...                                      alias=${NETACT_NAME}
    ${fault_id}    Set Variable    ${4348}
    ${fault_name}    Set Variable    Ant Blocked
    gnb_asir_hub_operations.Verify Alarm Is Active    fault_id=${fault_id}
    Length Should Be    ${netact_alarms}    1
    Should Contain    ${netact_alarms}[0][additionalText3]    FaultId=${fault_id}

Alarm Lifting
    ${lte_cell_tuple}    gnb_cell_operations.Get All Global Cell Ids    cell_type=lte
    Set Test Variable    ${CELL_ID}    ${lte_cell_tuple}
    gnb_commissioning.Perform Bts Delta Commissioning    delta=${earfcn_700}
    ${fault_id}    Set Variable    ${4484}
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    gnb_asir_hub_operations.Verify Alarm Is Active    fault_id=${fault_id}
    Upload Alarms    dist_name=${MO_ASI_ID}
    ${netact_alarms}    netact.Get Alarms    dist_name=${MO_ASI_ID}
    ...                                      alias=${NETACT_NAME}
    Length Should Be    ${netact_alarms}    4
    Should Contain    ${netact_alarms}[0][additionalText3]    FaultId=${fault_id}

Alarm Cancel from NE
    gnb_commissioning.Perform Bts Delta Commissioning    delta=${earfcn_1800}
    ${fault_id}    Set Variable    ${4484}
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    gnb_asir_hub_operations.Verify Alarm Is Not Active    fault_id=${fault_id}
    Upload Alarms    dist_name=${MO_ASI_ID}
    ${netact_alarms}    netact.Get Alarms    dist_name=${MO_ASI_ID}
    ...                                      alias=${NETACT_NAME}
    Length Should Be    ${netact_alarms}    0
    Should Be Empty    ${netact_alarms}

Delete EQM From Configuration
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${mo}    Run Keyword And Ignore Error    netact.Get Managed Object   configuration=${actual_conf}
    ...                                                                  mo_id=${MO_MRBTS_ID}/EQM-1
    ...                                                                  alias=${NETACT_NAME}
    Return From Keyword If    '${mo}[0]'=='FAIL'
    netact.Delete Managed Object    managed_object=${mo}[1]
    Run Keyword And Expect Error    ManagedObjectNotFound*    netact.Get Managed Object   configuration=${actual_conf}
    ...                                                                                   mo_id=${MO_MRBTS_ID}/EQM-1
    ...                                                                                   alias=${NETACT_NAME}

Upload MRBTS Configuration
    &{parameters}    Create Dictionary    -sranBtsHwContentInUse=${True}
    ${upload_output}   netact.Upload Configuration    dist_names=${MO_MRBTS_ID}
    ...                                                parameters=&{parameters}
    ...                                                alias=${NETACT_NAME}
    Should Not Contain    ${upload_output}    ${WARN_CONTENT_MISMATCH}
    Should Contain    ${upload_output}    Upload is Successful

Upload MRBTS Configuration And Verify
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${mo_id}    Set Variable    EQM-1
    Run Keyword And Expect Error    ManagedObjectNotFound*    netact.Get Managed Object   configuration=${actual_conf}
    ...                                                                                   mo_id=${MO_MRBTS_ID}/${mo_id}
    ...                                                                                   alias=${NETACT_NAME}
    Upload MRBTS Configuration
    netact.Get Managed Object   configuration=${actual_conf}
    ...                         mo_id=${MO_MRBTS_ID}/${mo_id}
    ...                         alias=${NETACT_NAME}

Delete ANTMOD From Configuration
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    @{antenna_ids}    gnb_asir_hub_operations.Get All Antenna Ids
    ${mo}    netact.Get Managed Object   configuration=${actual_conf}
    ...                                   mo_id=${MO_ASI_ID}/ANTMOD-${antenna_ids}[0]
    ...                                   alias=${NETACT_NAME}
    netact.Delete Managed Object    managed_object=${mo}
    Run Keyword And Expect Error    ManagedObjectNotFound*    netact.Get Managed Object   configuration=${actual_conf}
    ...                                                                                   mo_id=${MO_ASI_ID}/ANTMOD-${antenna_ids}[0]
    ...                                                                                   alias=${NETACT_NAME}

Upload ASI Configuration
    ${upload_output}   netact.Upload Configuration    dist_names=${MO_ASI_ID}
    ...                                                alias=${NETACT_NAME}
    Should Not Contain    ${upload_output}    ${WARN_CONTENT_MISMATCH}
    Should Contain    ${upload_output}    ASiR Upload finished

Upload ASI Configuration And Verify
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    @{antenna_ids}    gnb_asir_hub_operations.Get All Antenna Ids
    Upload ASI Configuration
    FOR    ${antenna_id}    IN    @{antenna_ids}
        netact.Get Managed Object   configuration=${actual_conf}
        ...                         mo_id=${MO_ASI_ID}/ANTMOD-${antenna_id}
        ...                         alias=${NETACT_NAME}
    END

Check Configuration
    ${bts_info}   admin.Get Bts Info
    Set Test Variable    ${old_bts_name}    ${bts_info}[name]
    ${output}    Run Keyword And Ignore Error    admin.Perform Parameter Recommissioning    dist_name=MRBTS-${GNB_ID}
    ...                                                                                           parameter=btsName
    ...                                                                                           value=${old_bts_name}
    ...                                                                                           operation=update
    Return From Keyword If    '${output}[0]'=='PASS'
    Fail    msg=Possible errors in configuration, fix it manually

Provision New Configuration Plan With MRBTS Name
    ${new_bts_name}    Set Variable    MRBTS-${GNB_ID} - (${DATE})
    ${plan_name}    Set Variable    Plan_Sanity_Provision_${DATE}
    ${plan_conf}    netact.Create Plan Configuration    name=${plan_name}
    ...                                                  alias=${NETACT_NAME}
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${actual_mo}    netact.Get Managed Object    configuration=${actual_conf}
    ...                                           mo_id=${MO_MRBTS_ID}
    ...                                           alias=${NETACT_NAME}
    netact.Create Managed Object    plan=${plan_conf}
    ...                             meta_class=${actual_mo.meta_class}
    ...                             meta_version=${actual_mo.meta_version}
    ...                             operation=CREATE
    ...                             mo_id=${MO_MRBTS_ID}
    ...                             alias=${NETACT_NAME}
    ...                             btsName=${new_bts_name}
    ${provision_output}    netact.Provision Plan    plan_name=${plan_name}
    ...                                              dist_names=${MO_MRBTS_ID}
    ...                                              backup_plan_name=Backup_${plan_name}
    ...                                              create_backup_plan=${True}
    ...                                              alias=${NETACT_NAME}
    Should Contain    ${provision_output}    5G/LTE/SRAN plan provision finished
    ${bts_info}   admin.Get Bts Info
    ${actual_bts_name}    Set Variable    ${bts_info}[name]
    Should Be True    "${actual_bts_name}"=="${new_bts_name}"
    gnb_du_operations.Wait For Site To Be Onair

Restore MRBTS Name
    ${bts_info}   admin.Get Bts Info
    Return From Keyword If    "${bts_info}[name]"=="${old_bts_name}"
    admin.Perform Parameter Recommissioning    dist_name=MRBTS-${GNB_ID}
    ...                                             parameter=btsName
    ...                                             value=${old_bts_name}
    ...                                             operation=update

Delete HWResetReq Objects
    ${netact}    Get Library Instance    name=netact
    Delete HWResetReqs    netact=${netact}
    ...                   asi_mo_id=${MO_ASI_ID}
    ...                   alias=${NETACT_NAME}

Provision New Configuration Plan To Reset Ant
    ${plan_name}    Set Variable    Plan_Sanity_Reset_Ant_${DATE}
    ${plan_conf}    netact.Create Plan Configuration    name=${plan_name}
    ...                                                  alias=${NETACT_NAME}
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${actual_mo}    netact.Get Managed Object    configuration=${actual_conf}
    ...                                           mo_id=${MO_ASI_ID}
    ...                                           alias=${NETACT_NAME}
    ${meta_class}    Set Variable    com.nokia.asi:HWRESETREQ
    @{antenna_ids}    gnb_asir_hub_operations.Get All Antenna Ids
    FOR    ${antenna_id}    IN    @{antenna_ids}
        netact.Create Managed Object    plan=${plan_conf}
        ...                             meta_class=${meta_class}
        ...                             meta_version=${actual_mo.meta_version}
        ...                             operation=CREATE
        ...                             mo_id=${MO_ASI_ID}/CMD-1/HWRESETREQ-${antenna_id}
        ...                             alias=${NETACT_NAME}
        ...                             targetHwResetUDN=ASI-${GNB_ID}/ANTMOD-${antenna_id}
    END
    ${reset_start}    Get Current Date
    ${provision_output}    netact.Provision Plan    plan_name=${plan_name}
    ...                                              dist_names=${MO_ASI_ID}
    ...                                              backup_plan_name=Backup_${plan_name}
    ...                                              create_backup_plan=${True}
    ...                                              alias=${NETACT_NAME}
    Should Contain    ${provision_output}    ASiR Plan Activate finished
    Sleep    10    Wait for activate plan on ASiR
    Run Keyword And Expect Error    IncorrectStatuses*    gnb_du_operations.Verify BTS Is OnAir
    gnb_du_operations.Wait For Site To Be Onair    timeout=300
    ${reset_end}    Get Current Date
    ${reset_time}    Subtract Date From Date    date1=${reset_end}
    ...                                             date2=${reset_start}
    ...                                             result_format=verbose
    ...                                             exclude_millis=${True}
    Log To Console    \n\tReset ant finished in ${reset_time}

Provision New Configuration Plan To Reset Hub
    ${plan_name}    Set Variable    Plan_Sanity_Reset_Hub_${DATE}
    ${plan_conf}    netact.Create Plan Configuration    name=${plan_name}
    ...                                                  alias=${NETACT_NAME}
    ${actual_conf}    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${actual_mo}    netact.Get Managed Object    configuration=${actual_conf}
    ...                                           mo_id=${MO_ASI_ID}
    ...                                           alias=${NETACT_NAME}
    ${meta_class}    Set Variable    com.nokia.asi:HWRESETREQ
    @{hub_ids}    gnb_asir_hub_operations.Get All Hub Ids
    FOR    ${hub_id}    IN    @{hub_ids}
        netact.Create Managed Object    plan=${plan_conf}
        ...                             meta_class=${meta_class}
        ...                             meta_version=${actual_mo.meta_version}
        ...                             operation=CREATE
        ...                             mo_id=${MO_ASI_ID}/CMD-1/HWRESETREQ-${hub_id}
        ...                             alias=${NETACT_NAME}
        ...                             targetHwResetUDN=ASI-${GNB_ID}/HUBMOD-${hub_id}
    END
    ${reset_start}    Get Current Date
    ${provision_output}    netact.Provision Plan    plan_name=${plan_name}
    ...                                              dist_names=${MO_ASI_ID}
    ...                                              backup_plan_name=Backup_${plan_name}
    ...                                              create_backup_plan=${True}
    ...                                              alias=${NETACT_NAME}
    Should Contain    ${provision_output}    ASiR Plan Activate finished
    Sleep    10    Wait for activate plan on ASiR
    Run Keyword And Expect Error    IncorrectStatuses*    gnb_du_operations.Verify BTS Is OnAir
    gnb_du_operations.Wait For Site To Be Onair    timeout=1000
    Wait Until Keyword Succeeds    600 sec    10 sec    gnbcell.Verify All Cells are OnAir
    ${reset_end}    Get Current Date
    ${reset_time}    Subtract Date From Date    date1=${reset_end}
    ...                                             date2=${reset_start}
    ...                                             result_format=verbose
    ...                                             exclude_millis=${True}
    Log To Console    \n\tReset hub finished in ${reset_time}

Upload SW Version
    ${upload_output}   Upload SW    dist_names=${MO_MRBTS_ID}
    ...                              alias=${NETACT_NAME}
    Should Contain    ${upload_output}    SUCCESS
    ${status_after_upload}    netact.Get MO Status    dist_names=${MO_MRBTS_ID}
    ...                                                alias=${NETACT_NAME}
    Log    \n\tActive SW:\t${status_after_upload}[${MO_MRBTS_ID}][active_sw]    console=${True}
    Log    \tPassive SW:\t${status_after_upload}[${MO_MRBTS_ID}][passive_sw]    console=${True}
    Should Be True    "${status_after_upload}[${MO_MRBTS_ID}][last_sw_op]"=="SWUpload"
    Should Be True    "${status_after_upload}[${MO_MRBTS_ID}][last_op_status]"=="SUCCESS"
    Should Be True    "${gnb_active_sw_before_test}"=="${status_after_upload}[${MO_MRBTS_ID}][active_sw]"

Download Build
    ${build_already_downloaded}    Check If File Exists    ${package_path}
    ${file_size}    Run keyword if    ${build_already_downloaded}==${True}    Get File Size    ${package_path}
    ...             ELSE    Get zero value
    ${build_already_downloaded}    Set variable if    ${file_size}>10000    ${True}    ${False}
    Run keyword if    ${build_already_downloaded}==${True}    Verify File Exists    ${package_path}
    Return from keyword if    ${build_already_downloaded}==${True}

    Log to console    \nDownloading ${package_filename}
    Run    cd ${DOWNLOAD_PATH}; wget -O ${package_filename} ${package_URL}
    Verify file exists    ${package_path}
    ${file_size}    Get File Size    ${package_path}
    Should be true    ${file_size}>10000    msg=Failed to correctly download build
    Run    cd ${DOWNLOAD_PATH}; mv ${package_filename} ${ENB_BUILD}.zip

Import Build To Upgrade
    ${import_status}    netact.Is Imported    version_id=${ENB_BUILD}
    ...                                        alias=${NETACT_NAME}
    Return From Keyword If    ${import_status}

    Set Test Variable    ${package_filename}    ${ENB_BUILD}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${package_path}    ${DOWNLOAD_PATH}/${package_filename}
    Set Test Variable    ${package_path_build}    ${DOWNLOAD_PATH}/${ENB_BUILD}.zip
    ${package_URL}    Replace String    ${ARTIFACTORY_URL}/${RELEASE}/${ENB_BUILD}/${package_filename}
    ...                                  SBTS26R3
    ...                                  SBTS00
    Set Test Variable    ${package_URL}
    Download Build
    ${releases}    Create List    SBTS24R3    SBTS25R1    SBTS25R2    SBTS25R3    SBTS26R1    SBTS26R2    SBTS26R3
    ${import_output}    netact.Import Build    build_or_file_path=${package_path_build}
    ...                                        release=All
    ...                                        alias=${NETACT_NAME}
    Sleep    100    Wait for activate build on Netact

    ${import_status}    netact.Is Imported    version_id=${ENB_BUILD}
    ...                                       alias=${NETACT_NAME}
    Should Be True    ${import_status}

Rollback SW
    ${rollback_start}    Get Current Date
    ${rollback_output}   netact.Rollback SW    dist_names=${MO_MRBTS_ID}
    ...                                        timeout=3600
    ...                                        alias=${NETACT_NAME}
    Should Contain    ${rollback_output}   SUCCESS
    admin.Teardown All Aliases For Admin
    admin.Setup Admin    update_interval=500
    gnb_du_operations.Wait For Site To Be Onair
    Wait Until Keyword Succeeds    600 sec    10 sec    gnbcell.Verify All Cells are OnAir
    Verify GPS Upgrade Ongoing
    ${rollback_end}    Get Current Date
    ${rollback_time}    Subtract Date From Date    date1=${rollback_end}
    ...                                            date2=${rollback_start}
    ...                                            result_format=verbose
    ...                                            exclude_millis=${True}
    Log To Console    \n\t\tRollback finished in ${rollback_time}

Rollback SW If Needed
    ${active_version}    admin.Get Sw Version
    Return From Keyword If    "${active_version}"!="${ENB_BUILD}"
    Rollback SW
    ${active_version_after_rollback}   admin.Get Sw Version
    Should Be True    "${active_version_after_rollback}"!="${ENB_BUILD}"
    Set Test Variable    ${gnb_active_sw_before_test}   ${active_version_after_rollback}

Upgrade To Target SW
    Set Start Time
    Set Test Variable    ${ITERATION_START_TIME}   ${START_TIME}
    ${upgrade_output}    netact.Provision SW    dist_names=${MO_MRBTS_ID}
    ...                                         package_name=${ENB_BUILD}
    ...                                         timeout=9000
    ...                                         alias=${NETACT_NAME}
    Should Contain    ${upgrade_output}   SUCCESS
    Reset Admin Connection
    gnb_du_operations.Wait For Site To Be Onair
    Wait Until Keyword Succeeds    600 sec    10 sec    gnbcell.Verify All Cells are OnAir
    Verify GPS Upgrade Ongoing
    Set End Time
    ${upgrade_time}    Subtract Date From Date    date1=${END_TIME}
    ...                                           date2=${START_TIME}
    ...                                           result_format=verbose
    ...                                           exclude_millis=${True}
    Log To Console    \n\t\tUpgrade finished in ${upgrade_time}
    ${gnb_sw_in_netact}    netact.Get MO Status    dist_names=${MO_MRBTS_ID}
    ...                                             alias=${NETACT_NAME}
    ${gnb_active_sw_after_upgrade}    admin.Get Sw Version
    Should Be True    "${gnb_active_sw_after_upgrade}"=="${gnb_sw_in_netact}[${MO_MRBTS_ID}][active_sw]"
    Should Be True    "${gnb_active_sw_after_upgrade}"=="${ENB_BUILD}"

Rollback To Source SW
    Rollback SW
    Sleep    90    Wait for perform operation on Netact
    ${gnb_sw_in_netact}    netact.Get MO Status    dist_names=${MO_MRBTS_ID}
    ...                                             alias=${NETACT_NAME}
    ${gnb_active_sw_after_rollback}    admin.Get Sw Version
    Should Be True    "${gnb_sw_in_netact}[${MO_MRBTS_ID}][active_sw]"=="${gnb_active_sw_after_rollback}"

Rollback SW And Report
    ${rollback_result}    ${error}    Run Keyword And Ignore Error    Rollback To Source SW
    Run Keyword If  "${rollback_result}"=="FAIL"  Log  \nFailed due to Error:${\n}${error}    ERROR    console=${True}
    Set Suite Variable    ${ROLLBACK_RESULT}    ${rollback_result}

Upgrade SW And Report
    ${upgrade_result}    ${error}    Run Keyword And Ignore Error    Upgrade To Target SW
    Run Keyword If  "${upgrade_result}"=="FAIL"  Log  \nFailed due to Error:${\n}${error}    ERROR    console=${True}
    Set Suite Variable    ${UPGRADE_RESULT}    ${upgrade_result}

Verify GPS Upgrade Ongoing
    ${gnss_result}    ${error}    Run Keyword And Ignore Error    gnb_alarm_verification.Verify Alarm Is Active
    ...                                         fault_id=4420
    ...                                         fault_name=GPS receiver alarm: firmware upgrade ongoing
    Run Keyword If  "${gnss_result}"=="PASS"    Run Keywords
    ...                                         gnb_alarm_verification.Wait For Alarm Deactivation    fault_id=4420    awaiting_time=600
    ...                                         AND    Sleep    300s    Wait for COAM will be available
    ...                                         AND    admin.Wait Sw Update Possible

Run UUF Iteration
    Set Suite Variable    ${UPGRADE_RESULT}    FAIL
    Set Suite Variable    ${ROLLBACK_RESULT}    FAIL
    Set Test Variable    ${ITERATION_START_TIME}    ${EMPTY}
    Set Test Variable    ${ITERATION_END_TIME}    ${EMPTY}
    Upgrade SW And Report
    Rollback SW And Report
    Return From Keyword If    "${UPGRADE_RESULT}"=="PASS" and "${ROLLBACK_RESULT}"=="PASS"
    Fail    Iteration failed

Run UUF Iteration And Report
    ${iteration_result}    ${error}    Run Keyword And Ignore Error    Run UUF Iteration
    Run Keyword If  "${iteration_result}"=="FAIL"  Log  \nFailed due to Error:${\n}${error}    ERROR    console=${True}
    Report To Reporting Portal    name=UPGRADE_ROLLBACK_USING_NETACT
    ...                           result=${iteration_result}ED
    ...                           case_type=Upgrade
    ...                           start_time=${ITERATION_START_TIME}
    ...                           end_time=${ITERATION_END_TIME}
    ...                           uuf_test=${True}
    Append To List   ${LOOP_RESULTS}    ${iteration_result}

Run UUF Loop
    @{LOOP_RESULTS}    Create List
    Set Test Variable    ${LOOP_RESULTS}
    FOR    ${N}    IN RANGE    1    ${ITERATIONS} + 1
        Log To Console    \n\tIteration: ${N}/${ITERATIONS}
        Run UUF Iteration And Report
    END
    ${passed}    Count Values In List    ${LOOP_RESULTS}    PASS
    ${failed}    Count Values In List    ${LOOP_RESULTS}    FAIL
    Log To Console    \n\tUUF finished with result: ${passed}/${ITERATIONS}
    Log To Console    \tPassed iterations: ${passed}, failed iterations: ${failed}
    List Should Not Contain Value    ${LOOP_RESULTS}    FAIL

Reset Admin Connection
    gnb_du_operations.Connect    force=True
    admin.Teardown Admin
    admin.Setup Admin    update_interval=500

Set Reporting Portal Variables
    ${bts_info}  admin.Get Bts Info
    ${HW_ID}  uuf_rfrl_common.Get HW ID  ${bts_info}
    Set Test Variable  ${HW_ID}
    ${RU_TYPE}  uuf_rfrl_common.Get Rmods  ${bts_info}
    Set Test Variable  ${RU_TYPE}
    ${TDD_FDD_VARIANT}  uuf_rfrl_common.Get Technology Variant  ${bts_info}
    Set Test Variable  ${TDD_FDD_VARIANT}

    ${rc}  ${hostname_tmp}  Run And Return Rc And Output  hostname
    ${hostname_tmp}  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}  Convert To String  ${hostname_tmp}
    ${hostname_part}  Split String  ${hostname_tmp}  _
    ${hostname_combined}  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

Report To Reporting Portal
    [Arguments]    ${name}    ${result}    ${case_type}    ${qc_id}=${EMPTY}    ${start_time}=${START_TIME}
    ...            ${end_time}=${END_TIME}    ${uuf_test}=${False}
    Remove String      ${START_TIME}    -
    Remove String      ${END_TIME}    -
    ${link_to_rep}     taf.sw.reporting_portal.Report To Rp
    ...                name=${name}
    ...                result=${result}
    ...                ca=${RP_CA}
    ...                testline=${HOSTNAME}
    ...                build=${ENB_BUILD}
    ...                qc_domain=${QC_DOMAIN}
    ...                qc_project=${QC_PROJECT}
    ...                qc_testlab_path=${EMPTY}
    ...                qc_id=${qc_id}
    ...                uuf_test=${uuf_test}
    ...                location=${RP_LOCATION}
    ...                organization=${RP_ORGANIZATION}
    ...                parameter_1=${UUF_PACKAGE}
    ...                starttime=${start_time}
    ...                endtime=${end_time}
    ...                case_type=${case_type}
    ...                ru_type=${RU_TYPE}
    ...                tdd/fdd_variant=${TDD_FDD_VARIANT}
    ...                hw_id=${HW_ID}
    ...                tool=MantaRay
    ...                customers=${CUSTOMERS_LIST}
    Log To Console     \n\t\t${name}, link to REP:\n\t\t${link_to_rep}

Set Start Time
    ${START_TIME}    uuf_rfrl_common.Get Time Now
    Set Test Variable  ${START_TIME}

Set End Time
    ${END_TIME}    uuf_rfrl_common.Get Time Now
    Set Test Variable  ${END_TIME}

Get zero value
    Log    Keyword to set value of 0
    [Return]    ${0}

