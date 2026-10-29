*** Settings ***
Documentation
...    author: Kamil Bielecki, Mikolaj Borkowski
...    contact: kamil.bielecki@nokia.com, mikolaj.borkowski@nokia.com


Library    DateTime
Library    Collections
Library    taf.sbts.oam.coam.admin                                           WITH NAME  coam
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning            WITH NAME  gnbscf
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME  asir
Library    taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate                     WITH NAME  gnb_sw_update
Library    taf.rfrl.utilities.test_config.DefaultFileLocation                WITH NAME  dfl
Library    taf/rfrl/common_resources/python/reset_bts_configuration.py
Library    taf/rfrl/bts/devices/ru/ru_operations.py
Library    ./suite_specific_keywords.py
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/enb.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    taf/rfrl/bts/alarms/classical_alarms_definition.py
Variables    ./variables.py


*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}
...    ${CLASSICAL_FAULT_23}
...    ${CLASSICAL_FAULT_4479}
...    ${CLASSICAL_FAULT_4420}

@{ADDITIONAL_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...    ${CLASSICAL_FAULT_7311}
...    ${CLASSICAL_FAULT_6450}
...    ${CLASSICAL_FAULT_4479}
...    ${CLASSICAL_FAULT_4592}
#7311 - No Xn link available
#6450 - Diagnostic Files collected
#4479 - Failure detected on assigned antennas
#4592 - BTS Reset Cause

${Source_SW}                     ${None}
${Target_SW}                     ${None}
${SW Update Timeout}             3000
${SW_package_path}               /home/ute/.ute-ca/cache/bts/

*** Keywords ***
Suite Setup
    Log Action To Console    Suite Setup
    Append To List    ${ALLOWED_ALARMS_DURING_TL_PREPARATION}    @{ADDITIONAL_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    Run Keyword If    '${Source_SW}' == '${None}' and '${Target_SW}' == '${None}'
    ...    Find And Assign builds
    Download SW Package to Local VM     ${Source_SW}
    Download SW Package to Local VM     ${Target_SW}
    coam.Setup Admin
    reset_bts_configuration.reset_configuration_with_software_upgrade
    ...    software_path=${SW_package_path}${Source_SW}/${Source_SW}_release_BTSSM_downloadable_A54.zip
    ...    reset_admin_connection=${True}
    coam.enable_ssh_access
    suite_specific_keywords.prepare_main_and_lte_neighbour
    ...    increase_time_for_checking_bbmod=600
    ${asirhub_1_version}=   Get Current ASIR SW Version    hub_id=1
    ${asirhub_2_version}=   Get Current ASIR SW Version    hub_id=0
    ${asirhub_3_version}=   Get Current ASIR SW Version    hub_id=2
    Set Suite Variable      ${asirhub_1_version}
    Set Suite Variable      ${asirhub_2_version}
    Set Suite Variable      ${asirhub_3_version}

Suite Teardown
    Log Action To Console       Suite Teardown
    Common Suite Teardown
    coam.Teardown Admin

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${True}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

RU SW Only Test Setup
    Log Action To Console       RU SW Only Test Setup
    Common Preconditions With Watching Alarms
    gnbscf.Perform Bts Delta Commissioning    delta=${ru_only_upgrade}    bts_id=0

RU+DU Test Setup
    Log Action To Console       RU+DU Test Setup
    Common Preconditions With Watching Alarms

RU SW Only Test Teardown
    Log Action To Console       RU Only test teardown
    Common Postconditions With Watching Alarms
    coam.Collect Snapshot       ${OUTPUT DIR}/snapshot.zip

RU+DU Test Teardown
    Log Action To Console       RU+DU test teardown
    Common Postconditions With Watching Alarms
    coam.Collect Snapshot       ${OUTPUT DIR}/snapshot.zip

Rollback RU SW Only
    Log Action To Console       Rollback RU SW to Source Build
    gnbscf.Perform Bts Delta Commissioning    delta=${simultaneous_activation}    bts_id=0
    coam.Update Software  sw_package=${SW_package_path}${Source_SW}/${Source_SW}_release_BTSSM_downloadable_A54.zip
    ...  should_activate=True  timeout=2000    independent_sw_update_type=All   should_reset_radios=True
    Sleep   60s
    Wait until all cells are onair
    Verify only allowed alarms present on gNB

Rollback DU SW
    Log Action To Console       Rollback DU SW to Source Build
    ${is_active}=    Run Keyword And Return Status    Assert Alarm Active    faultId=4420
    Run Keyword If    ${is_active}    Assert Alarm Inactive    faultId=4420    timeout=1500s
    Sleep   300s
    coam.Rollback Software    timeout=1200

Check For DU Rollback Rejected After Ru Only Upgrade
    Run Keyword And Expect Error        *       coam.Rollback Software    timeout=300

Download SW Package to Local VM
    [Arguments]    ${SW_Build}
    Log Action To Console    Downloading SW build ${SW_Build} to: ${SW_package_path}${SW_Build}/
    ${file_exists}=     Run Keyword and Return Status
    ...    OperatingSystem.File Should Exist    ${SW_package_path}${SW_Build}/${SW_Build}_release_BTSSM_downloadable_A54.zip
    Run Keyword If      ${file_exists} is False     gnb_sw_update.Download SW package    sw_version=${SW_Build}
    ...    target_dir=${SW_package_path}${SW_Build}/

Get Current ASIR SW Version
    [Arguments]    ${hub_id}=0
    ${hub_version}=    suite_specific_keywords.get_rfsw_asir_version    hub_id=${hub_id}
    [Return]    ${hub_version}

Check ASIR SW Updated
    [Arguments]    ${source_hub_version}    ${hub_id}
    ${target_hub_version}=      Get Current ASIR SW Version    hub_id=${hub_id}
    Should Not Be Equal As Strings      ${source_hub_version}       ${target_hub_version}

Check ASIR SW Not Updated
    [Arguments]    ${source_hub_version}    ${hub_id}
    ${target_hub_version}=      Get Current ASIR SW Version    hub_id=${hub_id}
    Should Be Equal As Strings      ${source_hub_version}       ${target_hub_version}

Wait until all cells are onair
    [Arguments]    ${waiting_time}=20min    ${checking_interval}=15s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    gnbcell.Verify All Cells Statuses    du_id=0
    ...                                 operational_state=Enabled    procedural_status=configured
    ...                                 availability_status=Online    administrative_state=Unlocked

Verify only allowed alarms present on gNB
    Verify Allowed Alarms on gNB    allowed_alarms=${ALLOWED_ALARMS}    gnb_id=0    du_id=${0}

Verify Alarm 23 Visible On Not Upgraded RU
    Verify Alarm is Active on gNB       fault_name=Incompatible SW version detected     fault_id=23
    ...     alarm_id=7111

Perform RU SW Only Upgrade With Simultaneous RU Activation Reset
    [Documentation]    This Keyword Performs SW Upgrade with RU Only option enabled and
    ...    ruPhaseSwActivationResetPolicy set to Simultaneous. All HUBMOD should reset at the same time.
    Log Action To Console    Performing RU SW Only Upgrade with Simultaneous RU Activation

    ${RuSwOnly_info}=    Start RU SW Only Upgrade    ${simultaneous_activation}    timeout=1200
    @{hubmod_ids}=       Create List    1    2    3
    Verify Simultaneous Hubmod Reset    @{hubmod_ids}

    coam.Collect Keyword Result    ${RuSwOnly_info}    timeout=${SW Update Timeout}
    Wait until all cells are onair
    Verify only allowed alarms present on gNB
    Check ASIR SW Updated    source_hub_version=${asirhub_1_version}    hub_id=1
    Check ASIR SW Updated    source_hub_version=${asirhub_2_version}    hub_id=0
    Check ASIR SW Updated    source_hub_version=${asirhub_3_version}    hub_id=2

Check Which Hubmod Is Disabled
    [Documentation]    KW returns id of first disabled HUBMOD starting from 1
    ${expected_status_disabled}    Create Dictionary       operationalState=disabled
    ${hubmod_1_status}=     Run Keyword And Return Status   asir.Verify Hubmod Status
    ...     hub_ids=1       expected_statuses=${expected_status_disabled}
    IF    ${hubmod_1_status} is ${TRUE}
        RETURN    1
    END
    ${hubmod_1_status}=     Run Keyword And Return Status   asir.Verify Hubmod Status
    ...     hub_ids=2       expected_statuses=${expected_status_disabled}
    IF    ${hubmod_1_status} is ${TRUE}
        RETURN    2
    END
    ${hubmod_1_status}=     Run Keyword And Return Status   asir.Verify Hubmod Status
    ...     hub_ids=3       expected_statuses=${expected_status_disabled}
    IF    ${hubmod_1_status} is ${TRUE}
        RETURN    3
    END
    RETURN    0

Start RU SW Only Upgrade
    [Arguments]    ${delta}    ${timeout}=2000
    Log Action To Console    Starting RU SW Only Upgrade with delta=${delta}
    Wait Until Keyword Succeeds    300 sec    15 sec
    ...    gnbscf.Perform Bts Delta Commissioning    delta=${delta}    bts_id=0
    ${RuSwOnly_info}=    coam.Run Keyword In Background
    ...    Update Software    sw_package=${SW_package_path}${Target_SW}/${Target_SW}_release_BTSSM_downloadable_A54.zip
    ...    should_activate=True    timeout=${timeout}    independent_sw_update_type=RuSwOnly    should_reset_radios=True
    [Return]    ${RuSwOnly_info}

Finalize RU SW Only Upgrade
    [Arguments]    ${RuSwOnly_info}
    coam.Collect Keyword Result    ${RuSwOnly_info}    timeout=${SW Update Timeout}
    Wait until all cells are onair
    Verify only allowed alarms present on gNB
    Check ASIR SW Updated    source_hub_version=${asirhub_1_version}    hub_id=1
    Check ASIR SW Updated    source_hub_version=${asirhub_2_version}    hub_id=0
    Check ASIR SW Updated    source_hub_version=${asirhub_3_version}    hub_id=2

Verify Next Sequential Hubmod Reset
    [Arguments]    ${hubmod_ids_to_reset}    ${hubmod_ids_to_verify}    ${expected_status_enabled}
    Wait Until Keyword Succeeds    1200 sec    15 sec
    ...    Run Keyword And Expect Error    InvalidStatuses*    asir.Verify Hubmod Status
    ...    hub_ids=${hubmod_ids_to_reset}    expected_statuses=${expected_status_enabled}
    ${disabled_hubmod_id}=    Check Which Hubmod Is Disabled
    Remove Values From List    ${hubmod_ids_to_reset}    ${disabled_hubmod_id}
    Remove Values From List    ${hubmod_ids_to_verify}    ${disabled_hubmod_id}
    asir.Verify Hubmod Status    hub_ids=${hubmod_ids_to_verify}    expected_statuses=${expected_status_enabled}

Verify User Defined Hubmod Reset
    [Arguments]    ${disabled_id}    @{enabled_ids}
    [Documentation]    Helper for User Defined RU activation order.
    ${expected_status_disabled}=    Create Dictionary    operationalState=disabled
    ${expected_status_enabled}=     Create Dictionary    operationalState=enabled
    Wait Until Keyword Succeeds    1200 sec    10 sec
    ...    asir.Verify Hubmod Status    hub_ids=${disabled_id}    expected_statuses=${expected_status_disabled}
    Sleep    15s
    asir.Verify Hubmod Status    hub_ids=${enabled_ids}    expected_statuses=${expected_status_enabled}

Verify Simultaneous Hubmod Reset
    [Arguments]    @{hubmod_ids}
    ${expected_statuses}=    Create Dictionary    operationalState=disabled
    Wait Until Keyword Succeeds    2000 sec    10 sec
    ...    asir.Verify Hubmod Status    hub_ids=${hubmod_ids}    expected_statuses=${expected_statuses}

Perform RU SW Only Upgrade With Sequential RU Activation Reset
    [Documentation]    RU-only upgrade with ruPhaseSwActivationResetPolicy=Sequential.
    Log Action To Console    Performing RU SW Only Upgrade with Sequential RU Activation
    ${RuSwOnly_info}=    Start RU SW Only Upgrade    ${sequential_activation}    timeout=2000
    ${expected_status_enabled}=    Create Dictionary    operationalState=enabled
    @{hubmod_ids_to_reset}=    Create List    1    2    3
    @{hubmod_ids_to_verify}=  Create List    1    2    3

    Verify Next Sequential Hubmod Reset    ${hubmod_ids_to_reset}    ${hubmod_ids_to_verify}
    ...    ${expected_status_enabled}
    Verify Next Sequential Hubmod Reset    ${hubmod_ids_to_reset}    ${hubmod_ids_to_verify}
    ...    ${expected_status_enabled}
    Verify Next Sequential Hubmod Reset    ${hubmod_ids_to_reset}    ${hubmod_ids_to_verify}
    ...    ${expected_status_enabled}

    Finalize RU SW Only Upgrade    ${RuSwOnly_info}


Perform RU SW Only Upgrade With User Defined RU Activation Reset
    [Documentation]    RU-only upgrade with ruPhaseSwActivationResetPolicy=User Defined.
    Log Action To Console    Performing RU SW Only Upgrade with User Defined RU Activation
    ${RuSwOnly_info}=    Start RU SW Only Upgrade    ${user_defined_activation}    timeout=2000

    Verify User Defined Hubmod Reset    1    2    3
    Verify User Defined Hubmod Reset    2    1    3
    Verify User Defined Hubmod Reset    3    1    2

    Finalize RU SW Only Upgrade    ${RuSwOnly_info}


Perform DU SW Upgrade With Simultaneous RU Activation Reset
    [Documentation]    This Keyword Performs SW Upgrade with RU only option, and then performs upgrade with DU option
    ...     meaning legacy upgrade. HUBMOD 1 should be upgraded first in RU only upgrade and then
    ...     HUBMOD 2 in DU upgrade. HUBMOD 3 should not be upgraded since it has option No Upgrade enabled.
    Log Action To Console    Performing DU SW Upgrade with Simultaneous RU Activation
    ${RuSwOnly_info}=    Start RU SW Only Upgrade    ${du_upgrade}    timeout=1200
    Verify User Defined Hubmod Reset    1    2    3

    coam.Collect Keyword Result    ${RuSwOnly_info}    timeout=${SW Update Timeout}
    Wait until all cells are onair
    Verify only allowed alarms present on gNB
    Check ASIR SW Updated        source_hub_version=${asirhub_1_version}    hub_id=1
    Check ASIR SW Not Updated    source_hub_version=${asirhub_2_version}    hub_id=0
    Check ASIR SW Not Updated    source_hub_version=${asirhub_3_version}    hub_id=2

    coam.Update Software    sw_package=${SW_package_path}${Target_SW}/${Target_SW}_release_BTSSM_downloadable_A54.zip
    ...    should_activate=True    timeout=1200    independent_sw_update_type=All
    Sleep    120s
    ${expected_status_enabled}=    Create Dictionary    operationalState=enabled
    @{hubmod_ids}=    Create List    1    2
    Wait Until Keyword Succeeds    900 sec    30 sec
    ...    asir.Verify Hubmod Status    hub_ids=${hubmod_ids}    expected_statuses=${expected_status_enabled}
    Check ASIR SW Updated        source_hub_version=${asirhub_1_version}    hub_id=1
    Check ASIR SW Updated        source_hub_version=${asirhub_2_version}    hub_id=0
    Check ASIR SW Not Updated    source_hub_version=${asirhub_3_version}    hub_id=2
    Sleep    120s
    Verify Alarm 23 Visible On Not Upgraded RU

Find And Assign builds
    ${result}=    suite_specific_keywords.find source build with different asihub and older version
    ${Target_SW}=    Get From List    ${result}    0
    ${Source_SW}=    Get From List    ${result}    1
    Set Suite Variable    ${Target_SW}
    Set Suite Variable    ${Source_SW}
