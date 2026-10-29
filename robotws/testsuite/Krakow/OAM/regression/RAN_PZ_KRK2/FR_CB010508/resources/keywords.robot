*** Settings ***
Documentation
...    Author: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
...    Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Library      OperatingSystem
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    GnbDuOp
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    GnbCellOp
Library      taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate    WITH NAME    GenericSwUp
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.sbts.oam.coam.admin.interface    WITH NAME    Admin
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/SwUpdate.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${UPDATE_TEST_ITERATION}=    1
${SHOULD_BE_REPORTED}=       ${False}
@{CUSTOMERS_LIST}=           Generic
@{CRITICAL_FAULTS}=          0010  0016  1806  1868  4341  4352  4383
${SW_SOURCE_N-2-N}           ${None}
${SW_SOURCE_N-1-N}           ${None}
${SW_SOURCE_N-N}             ${None}
${UPDATE_TEST_FAILED}        ${False}
${QC_DOMAIN}=                MN_RAN
${QC_PROJECT}=               RAN_VRF
${QC_ID_UPGRADE}=            ${None}
${QC_ID_RESET}=              ${None}
${REMOTE_VM_IP}=             ${tl.test_pc.default_ssh_connection_details.addr}
@{CUSTOM_ALARMS}=            61648   # LMP connectivity detected
...                          4681    # Sanity Check Error
...                          61649   # LMP access via port $port
...                          4655    # Service account root access is enabled
...                          61524   # SSH enabled
...                          4654    # Ethernet port security is disabled
...                          4420    # GPS receiver alarm: firmware upgrade ongoing
...                          61652   # R&D Service Port enabled
...                          4700    # TX Power too low
...                          4699    # TX Bias Current too low
...                          4479    # Failure detected on assigned antennas - agreed with dev
...                          6327    # Setup of X2 connectivity to gNB failed
${CURRENT_SW}=               ${None}
${UTE_SW}=                   ${None}
${SW_PATH}=                  ${None}
${SW_YAFT_DOWNLOAD_PATH}=    /home/ute/.ute-ca/cache/bts
${SW_YAFT_PATH}=             /home/ute/.ute-ca/cache/bts/${SW_SOURCE_N-2-N}_release_BTSSM_downloadable_A54.zip
${SW_TARGET}=                basic_sw
${TIMEOUT}=                  3600
${CELL_TYPE}=                all
${OPERATIONAL_STATE}=        enabled
${ADDITIONAL_PARAM}=         --clean_to_default
${RELEASE}=                  ${None}
@{ALARMS_LIST}               Setup of X2 connectivity to gNB failed
...                          Failure detected on assigned antennas
${SCOUT_HOSTNAME}            7_7_UTE5GCLOUDT1SK055
&{NODE1}                     testline_object=${tl.gnbs[0]}
...                          source_sw=${SOURCE_SW}
...                          target_sw=${TARGET_SW}
...                          custom_allowed_alarms=${CUSTOM_ALARMS}
...                          testline_scout_name=${SCOUT_HOSTNAME}
@{NODES}                     ${NODE1}
@{UPGRADE_NODES}             ${NODE1}
${RP_CA}                     VRF_SiSo
${RP_ORGANIZATION}           VRF_KRK_T02
${RP_LOCATION}               VRF_KRK
${TARGET_SW}                 ${None}
${SOURCE_SW}                 ${None}


*** Keywords ***
Set Allowed Alarms
    Set Suite Variable    @{allowed_alarms}    SSH enabled
    ...                                        R&D Service Port enabled
    ...                                        Service account root access is enabled
    ...                                        Ethernet port security is disabled
    ...                                        LMP access via port 443
    ...                                        Setup of X2 connectivity to gNB failed
    ...                                        LMP connectivity detected
    ...                                        Diagnostic Check Error
    ...                                        Sanity Check Error
    ...                                        Unit power reset
    ...                                        BTS Reset Cause

Check SW Version
    gnbcell.connect    force=True
    ${SWVER}    Get Software Version
    Set Suite Variable  ${CURRENT_SW}  ${SWVER}

Check SW Version Installed By UTE
    ${SWVER}    Get Software Version
    Set suite Variable  ${UTE_SW}  ${SWVER}

Prepare Source SW
    [Arguments]    ${proper_sw}
    Check SW Version
    Get And Set Current Time
    IF    "${CURRENT_SW}" != "${proper_sw}"
        Log To Console    [${timestamp}] Diffrent SW detected. Updating...
        Update Source SW    sw_version=${proper_sw}
    ELSE
        Log To Console    [${timestamp}] SW are matching, skipping update...
    END

Update Source SW
    [Arguments]    ${sw_version}
    Get And Set Current Time
    Log To Console    [${timestamp}] Downloading ${sw_version} to ${SW_PATH}
    GenericSwUp.download_sw_package
    ...    sw_version=${sw_version}
    ...    target_dir=${SW_PATH}
    Get And Set Current Time
    Log To Console    [${timestamp}] ${sw_version} downloaded! Starting SW update...
    GenericSwUp.update_software
    ...    sw_package_dir=${SW_PATH}/${sw_version}_release_BTSSM_downloadable_A54.zip
    ...    timeout=${TIMEOUT}
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting 5 minutes to SW apply and reset...
    Sleep    300 sec    reason=Time for SW to apply
    Disconnect from BTS

Wait For BTS To Be OnAir
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting for site to be onAir...
    GnbDuOp.wait_for_site_to_be_onair
    Wait Until Keyword Succeeds    600 sec    60 sec
    ...    GnbCellOp.verify_all_cells_statuses    cell_type=${CELL_TYPE}
    ...                                           operational_state=${OPERATIONAL_STATE}
    Check SW Version
    Get And Set Current Time
    Log To Console    [${timestamp}] Site is onAir! Current SW: ${CURRENT_SW}

Custom Test Teardown
    Run Keyword If Test Failed    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

Disconnect from BTS
    gnbcell.disconnect

Prepare Proper SW Version
    Get And Set Current Time
    Log To Console    [${timestamp}] Downloading yaft...
    GenericSwUp.download_yaft
    Get And Set Current Time
    Log To Console    [${timestamp}] Downloading SW: ${SW_SOURCE_N-2-N}
    GenericSwUp.download_sw_package
    ...               sw_version=${SW_SOURCE_N-2-N}
    ...               target_dir=${SW_YAFT_DOWNLOAD_PATH}
    Get And Set Current Time
    Log To Console    [${timestamp}] SW downloaded to: ${SW_YAFT_DOWNLOAD_PATH}
    Get And Set Current Time
    Log To Console    [${timestamp}] Starting update SW via yaft!
    GenericSwUp.update_software_via_yaft
    ...               sw_package_path=${SW_YAFT_PATH}
    ...               additional_options=${ADDITIONAL_PARAM}
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting 5 minutes to SW apply and reset...
    Sleep             300 sec    reason=Time for SW to apply
    Disconnect from BTS
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting for site to be operational...
    Wait Until Keyword Succeeds    300 sec    60 sec
    ...               GnbDuOp.verify_bts_is_not_commissioned
    Get And Set Current Time
    Log To Console    [${timestamp}] SW: ${SW_SOURCE_N-2-N} is activated!
    Log To Console    [${timestamp}] Removing yaft_image files...
    Run               sudo rm -rf /home/ute/yaft_latest/YAFT_IMAGE
    Disconnect from BTS

Suite Setup Custom
    Check If N-2-N SW Is Not Set To None
    Verify If Yaft is required
    Check SW Version
    Check Release    sw=${CURRENT_SW}
    Set Additional Allowed Alarms
    Common Suite Setup With OnAir Test Line Preparation
    ...    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...    increase_timeout_for_update_sw=900
    ...    incompatible_error_timer=900
    ...    scfs_path=commissionings/Krakow/7_7_UTE5GCLOUDT1SK055/${RELEASE}
    ...    list_of_additional_allowed_alarms=@{ALARMS_LIST}
    Set Allowed Alarms
    Remove SW Package
    ...    build=${SW_SOURCE_N-2-N}
    ...    path=${SW_YAFT_DOWNLOAD_PATH}

Verify If Yaft Is Required
    Get And Set Current Time
    Log To Console    [${timestamp}] Waiting few minutes for site to be operational...
    TRY
        Wait Until Keyword Succeeds    300 sec    30 sec
        ...               GnbDuOp.verify_bts_is_not_commissioned
    EXCEPT    AS    ${error}
        ${contains}    Run Keyword And Return Status    Should Contain    ${error}
        ...    Current unexpected state is: onair
        IF    "${contains}" == "${True}"
            Wait For BTS To Be OnAir
        ELSE
            Fail    Unexpected BTS state!
        END
    END
    Check SW Version Installed By UTE
    Get And Set Current Time
    Log To Console    [${timestamp}] Checking if SW change is necessary...
    Run Keyword If    "${UTE_SW}" != "${SW_SOURCE_N-2-N}"    Prepare Proper SW Version
    ...    ELSE    no operation

Check Release
    [Arguments]    ${sw}
    ${package_items}    Split String    ${sw}
    ...                                 separator=_
    ...                                 max_split=2
    ${RELEASE}    Set Variable    ${package_items}[0]
    Set Suite Variable    ${RELEASE}

Set Additional Allowed Alarms
    Set Suite Variable    @{additional_allowed_alarms}    @{ALARMS_LIST}

Get And Set Current Time
    ${timestamp}    BuiltIn.Get Time    result_format=%d-%m-%Y %H:%M:%S
    Set Suite Variable    ${timestamp}

Remove SW Package
    [Arguments]    ${build}    ${path}
    Get And Set Current Time
    Log To Console    [${timestamp}] Removing SW: ${build} from ${path}
    Run               sudo rm -f ${path}/${build}_release_BTSSM_downloadable_A54.zip

Check If N-2-N SW Is Not Set To None
    IF    "${SW_SOURCE_N-2-N}" == "${None}"
      ${SW_SOURCE_N-2-N}    Set Variable    ${SW_SOURCE_N-1-N}
    END
    IF    "${SW_SOURCE_N-1-N}" == "${None}"
      IF    "${SW_SOURCE_N-2-N}" == "${None}"
         ${SW_SOURCE_N-2-N}    Set Variable    ${SW_SOURCE_N-N}
      END
    END
    Set Suite Variable    ${SW_SOURCE_N-2-N}
    Set Suite Variable    ${SW_YAFT_PATH}    /home/ute/.ute-ca/cache/bts/${SW_SOURCE_N-2-N}_release_BTSSM_downloadable_A54.zip

Upgrade Rollback with OAM KPI
    [Arguments]    ${Target_build}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID_UPGRADE}
    ...    sw_build=${Target_build}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    restore_to_target_sw=${False}
    Disconnect from BTS

Update SOURCE_SW And TARGET_SW Variable
    [Arguments]    ${source}
    ${NODE1}    Set To Dictionary    ${NODE1}    source_sw=${source}
    Set Suite Variable    ${NODE1}    ${NODE1}

Update SW_PATH Variable
    [Arguments]    ${build}
    Check Release    sw=${build}
    ${SW_PATH}    Set Variable    /home/ute/UUF_SW/SBTS/${RELEASE}
    Set Suite Variable    ${SW_PATH}

Update All Necessary Variables
    [Arguments]    ${source}    ${build}
    Update SOURCE_SW And TARGET_SW Variable    source=${source}
    Update SW_PATH Variable    build=${build}

Create UUF_SW Directory With Proper Release
    Run    mkdir -p /home/ute/UUF_SW/SBTS/
    ${result}    Run    mkdir /home/ute/UUF_SW/SBTS/${RELEASE}
    IF    "${result}" == "${EMPTY}"
        Log To Console    Directory /home/ute/UUF_SW/SBTS/${RELEASE} created successfully!
    ELSE
        Log To Console    Directory already exist!
    END
