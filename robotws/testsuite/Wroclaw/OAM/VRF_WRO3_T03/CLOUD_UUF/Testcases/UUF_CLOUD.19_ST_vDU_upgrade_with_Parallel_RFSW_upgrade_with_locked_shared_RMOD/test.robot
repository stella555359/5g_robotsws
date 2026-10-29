*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        ../../../../cloud_common_resources/certificates/certificates.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot


Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library         Collections
Library         taf.sbts.oam.coam.admin    WITH NAME   admin

Documentation
...  TEST NAME:     UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD
...  AUTHORS:       anna.niedzwiecka@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vDU(CNF based) intra-release upgrade with parallel RFSW upgrade on locked shared RMOD,
...  from N version to another N version via MantaRay NM.
...  It also verifies that all required configuration data(SCF) are migrated according to NIDD migration rules during upgrade.
...  SW upgrade operation consists to delete and re-install CNF instance(s).
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  12.09.2025 - TC Creation

*** Variables ***
${file_path}=    /ffs/run/PERSISTENT_RFSW/OFFLINE/TARGETBD
${file_name}=    preactivationTargetBD.xml
*** Keywords ***
UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:0 Test Preparation
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:1 Select shared RMOD
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:2 Perform RMOD Lock
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:3 Perform Upgrade With Download RU SW
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:4 Perform RMOD Unlock


UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    add_additional_data_to_nertc_for_wft
    mantaray.Verify Api On Lab  ${nms_lab_ip}  hw_type=${hw}
    Set Suite Variable    ${ENB_MPLANE_IP}  ${tl.gnbs[1].oam_ip.v4}
    ${allowed_faults}=     Create List    7102   1931   7104   7114
    Set Test Variable    ${allowed_faults}

UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:1 Select shared RMOD
    Decorate Print  Step: 1 Show lists of RMODs cloud
    ${rmod_info}=   Get Rmods Status    vdu_connection=${admin_connection}
    ${cloud_SN_list_rmods}     Create List
    ${rmods_mapping_cloud}=   Create Dictionary
    FOR  ${item}  IN  @{rmod_info}
        Set To Dictionary  ${rmods_mapping_cloud}  ${item['serial_number']}  ${item['dist_names']['config']}
    END
    Set Test Variable    ${rmods_mapping_cloud}
    Log  \RMODs on cloud: ${rmods_mapping_cloud}  console=${True}

    Decorate Print  Step: 2 Show lists of RMODs classical
    ${ute_admin_alias}  Set Variable     default
    Set Test Variable    ${ute_admin_alias}
    admin.Setup Admin    ${ENB_MPLANE_IP}   443    Nemuadmin    nemuuser    True    ${ute_admin_alias}=default
    ${bts_info}=  admin.get bts info   ${ute_admin_alias}=default
    ${rmods_mapping_classical}=   Create Dictionary
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        Set To Dictionary  ${rmods_mapping_classical}  ${item['serialNumber']}  ${item['id']['configuration']}
    END
    Set Test Variable    ${rmods_mapping_classical}
    Log  \RMODs on classical: ${rmods_mapping_classical}  console=${True}

    Decorate Print  Step: 3 Select shared RMOD
    ${common_sn}=   Evaluate    [sn for sn in ${rmods_mapping_cloud} if sn in ${rmods_mapping_classical}]
    ${selected_sn}=  Evaluate  random.choice(${common_sn})  random
    ${selected_rmod_DN_classical}=    Get From Dictionary     ${rmods_mapping_classical}     ${selected_sn}
    ${selected_rmod_DN_cloud}=        Get From Dictionary     ${rmods_mapping_cloud}     ${selected_sn}
    Set Test Variable     ${selected_rmod_DN_classical}
    Set Test Variable     ${selected_rmod_DN_cloud}
    Log     \RMOD on classical: ${selected_rmod_DN_classical}, RMOD on cloud: ${selected_rmod_DN_cloud}    console=${True}
    ${active_rmod_sw_build}=  Get Rmod Active Sw Version  rmod_dist_name=${selected_rmod_DN_cloud}  vdu_connection=${admin_connection}
    ${component}=  Get Rmod Active Sw Version Component  rmod_sw_build=${active_rmod_sw_build}
    Set Test Variable  ${component}

UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:2 Perform RMOD Lock
    Decorate Print  Step: 4 Perform RMOD lock
    Add Alarms To Watchdog     ${allowed_faults}  ${hw}
    Add Alarms To Watchdog     ${allowed_faults}  ${non_upgraded_cnf}
    vdu_admin.Perform Parameter Recommissioning                     dist_name=${selected_rmod_DN_cloud}
        ...                                                         parameter=actSharedRUIndControl
        ...                                                         operation=update
        ...                                                         value=true
        ...                                                         vdu_connection=${admin_connection}
    admin.Perform Parameter Recommissioning                         dist_name=${selected_rmod_DN_classical}
        ...                                                         parameter=actSharedRUIndControl
        ...                                                         operation=update
        ...                                                         value=true
        ...                                                         connection=${ute_admin_alias}
    ${status}  Run Keyword And Return Status  admin.lock  ${selected_rmod_DN_classical}  timeout=300
    Run Keyword If  not ${status}  admin.lock  ${selected_rmod_DN_classical}  timeout=180
    Log  \RMOD ${selected_rmod_DN_classical} is locked  console=${True}

UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:3 Perform Upgrade With Download RU SW
    Decorate Print  Step: 5 Perform Uprade
    mantaray.Integrate Cloud BTS with NMS Lab    nms_lab_ip=${NMS_LAB_IP}  hw_type=vDU   blue_green=${True}
    _Prepare SW on NMS lab    sw_version=${VDU_SW_VERSION}-amd64_rfsw    nms_lab_ip=${NMS_LAB_IP}    nop_type=${None}    mo_type=MRBTS
    ${rmod_sw_version_after_upgr}=  Get Expected Rmod Sw Build After Update  rmod_sw_build_component=${component}   vdu_sw_build=${VDU_SW_VERSION}
    Set Test Variable     ${rmod_sw_version_after_upgr}
    mantaray.Perform CNF Upgrade
    ...    nms_lab_ip=${NMS_LAB_IP}
    ...    sw_version=${VDU_SW_VERSION}-amd64
    ...    hw_type=${hw}
    ...    download_ru_sw=${True}
    Ensure File Exists On Container   ${CRAN_VDU}   oamfh    ${file_path}    ${file_name}

UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:4 Perform RMOD Unlock
    Decorate Print  Step: 6 Perform Rmod unlock
    Sleep  10s
    ${status}  Run Keyword And Return Status  admin.unlock  ${selected_rmod_DN_classical}  timeout=300
    Run Keyword If  not ${status}  admin.unlock  ${selected_rmod_DN_classical}  timeout=180
    Wait Until Keyword Succeeds  10min  30s  Check If All Cells On Air    hw_type=${hw}    connection=${admin_connection}
    ${active_rmod_sw_build}=  Get Rmod Active Sw Version  rmod_dist_name=${selected_rmod_DN_cloud}    vdu_connection=${admin_connection}
    Should Be Equal  '${active_rmod_sw_build}'  '${rmod_sw_version_after_upgr}'
    Delete Alarms From Watchdog    ${allowed_faults}  ${non_upgraded_cnf}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${hw}
    Delete Temporary Allowed Alarms From Watchdog  hw_type=${non_upgraded_cnf}
    Log    \Waiting for 5 minutes to verify whether any unexpected alarms appear    console=${True}
    Sleep  5m
    Check Alarm List On vCU/vDU  ${hw}
    admin.teardown admin  ${ute_admin_alias}=default

UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:5 Test Specific Teardown
    [Documentation]  Test teardown which unlock selected RMODs.
    Log  \Unlock RMOD ${selected_rmod_DN_classical}    console=${True}
    ${status}  Run Keyword And Return Status  admin.unlock  ${selected_rmod_DN_classical}  timeout=300
    Run Keyword If  not ${status}  admin.unlock  ${selected_rmod_DN_classical}  timeout=180
    admin.teardown admin  ${ute_admin_alias}=default
