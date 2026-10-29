*** Settings ***
Documentation
...   Keywords file for CNI130136_ASIR
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library    netact_custom.py    WITH NAME    netact_custom
Library    asir_ops_custom.py    WITH NAME    gnb_asir
Library    commissioning_custom.py    WITH NAME    gnbscf_custom
Library    cni130136_kw.py
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/sshrmod/Fault_verifier.py
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/sshrmod/common.py    WITH NAME    CB012097_common
Variables  variables/asir_cmd.py
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/sshrmod/SSHRMOD.py                               ${conn_level_map}    WITH NAME    SSHRMOD
Library    ../../CB012097/resources/keywords_CB012097_02.py                               WITH NAME    lib02
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library      on_air_tl_preparation.testline_preparation_resources
Library     taf.rfrl.procedures.resources.python.config_operations.ConfigOperations        WITH NAME  config_operations
Library     taf.rfrl.procedures.resources.python.connections                          WITH NAME   connections
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library    String
Library    Collections

*** Variables ***

${CUSTOM_ADDITIONAL_ALARMS_DURING_PREP}=    ${None}     # provide single alarm or comma separated list of alarms enclosed with ""

*** Keywords ***
Custom Suite ASIR Setup
    @{param_list}=    Set Variable    0x450027=1 #EnableDeveloperAccount
    ...                               0x9D0000=5 # PMStat_PmIntervalShrinkRatio
    cni130136_kw.copy_and_modify_swconfig    ${param_list}
    ...                                  source_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                  target_path=/tmp/custom_swconfig.txt
    IF    $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP
        @{list_argument}=    Evaluate    [el.strip() for el in $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP.split(',')]
        Log    list_argument=${list_argument}  console=True
        @{ADDITIONAL_ALARMS_DURING_PREP}=    Create List    @{ADDITIONAL_ALARMS_DURING_PREP}    @{list_argument}
        Log    ADDITIONAL_ALARMS_DURING_PREP=${ADDITIONAL_ALARMS_DURING_PREP}  console=True
    END
    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}

Prepare Netact Connection
    netact_custom.Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    netact_custom.Add Node    fmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    ${web_url}=    netact_custom.Detect WEB URL    alias=${NETACT_NAME}
    netact_custom.Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}

Set RMOD Variables for Test Case
    [Documentation]
    ...    KW sets variables necessary to detemine which RMOD to test,
    ...    i.e. rmod_sn as APHG_sn for APHG , RMOD_RUNTIME, FAN_RUNTIME
    ...    rmod_type: radio_type from __init__ in tl.gnbs[0].dus[0].airscale.core_units[0].rus object, eg. APHG
    ...    rmod_id: entry of same rmod_type from __init__, 0..n-1 or 'random',
    ...    0 is first rmod in rmod list tl.gnbs[0].dus[0].airscale.core_units[0].rus
    ...    rmod_list: tl.gnbs[0].dus[0].airscale.core_units[0].rus object from __init__.py

    [Arguments]
    ...    ${rmod_type}
    ...    ${rmod_id}=0
    ...    ${rmod_list}=${RMOD_LIST}

    ${sn}=    Get Variable Value    $${rmod_type}_${rmod_id}_sn    ${None}
    IF    '${sn}' == '${None}'
        ${rmod_sn}=    CB012097_common.get_rmod_sn_from_rmod_list    ${rmod_type}    ${rmod_id}    ${rmod_list}
    ELSE
        ${rmod_sn}    Set Variable    ${${rmod_type}_${rmod_id}_sn}
    END
    Set Test Variable    ${${rmod_type}_${rmod_id}_sn}    ${rmod_sn}

    ${RMOD_FAN_RUNTIME}=    CB012097_common.get_rmod_and_fan_dist_names    ${rmod_type}    ${rmod_sn}    id_type=runtime
    Set Test Variable    ${RMOD_${rmod_id}_FAN_RUNTIME}    ${RMOD_FAN_RUNTIME}
    Log    ${rmod_type}_${rmod_id} SN: ${${rmod_type}_${rmod_id}_sn}\nRMOD_${rmod_id}_FAN_RUNTIME: ${RMOD_${rmod_id}_FAN_RUNTIME}     console=True

    ${RMOD_CONF_DN}=    CB012097_common.get_rmod_and_fan_dist_names    ${rmod_type}    ${rmod_sn}    id_type=configuration
    Set Test Variable    ${RMOD_${rmod_id}_CONF_DN}    ${RMOD_CONF_DN[0]}
    Log    RMOD_${rmod_id}_CONF_DN: ${RMOD_${rmod_id}_CONF_DN}     console=True

Set SMOD SFP LANE Variables for Test Case
    [Documentation]
    ...    KW sets variables necessary to set which SFP and LANE object to verify in faults

    [Arguments]
    ...    ${sfp_id}=1
    ...    ${lane_id}=1

    ${SFP}=    cni130136_kw.get_object_dn_sn_conf_dn    MRBTS-{}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${sfp_id}
    Log   SFP_${sfp_id}_PARAMS:\n ${SFP}[0]\n --- SN: ${SFP}[1]\n --- configDN: ${SFP}[2]    console=True
    Set Test Variable    ${SFP_${sfp_id}_PARAMS}    ${SFP}
    ${LANE}=    cni130136_kw.get_lane_dn_sn_conf_dn    MRBTS-{}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${sfp_id}/LANE_R-${lane_id}
    Log    LANE_${sfp_id}_PARAMS:\n ${LANE}[0]\n --- SN: ${LANE}[1]\n --- configDN: ${LANE}[2]    console=True
    Set Test Variable    ${LANE_${sfp_id}_PARAMS}    ${LANE}

Set FAN IDs for Test Case
    Set Test Variable    ${fan_1932}    1
    Set Test Variable    ${fan_1933}    3
    Set Test Variable    ${kpi_fan}    2

Prepare SSH connection to Container
    ${sshrmod}=    Get Library Instance    SSHRMOD
    Set Test Variable    ${sshrmod}
    SSHRMOD.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD.Attach To Container
    Log To Console    Attached to container

Prepare RMOD ${rmod_type:APHG|APHA} with sn:${rmod_sn} environment
    IF    not $FAST_TRIGGER
        CB012097_common.Login To Rmod    ${sshrmod}    ${rmod_type}    ${rmod_sn}
        lib02.Prepare Rmod Swconfig    ${sshrmod}    ${rmod_type}    swconfig=${{{'APHA': $APHA_swconfig}}}
        lib02.Prepare Tcs    ${sshrmod}    ${rmod_type}    tcs_fetch=${tcs_fetch}    tcs_store=${tcs_store}
        SSHRMOD.Logout From Rmod    ${rmod_type}
        Log To Console    RMOD ${rmod_type} with sn:${rmod_sn} environment prepared
    ELSE
        Log To Console    RMOD ${rmod_type} with sn:${rmod_sn} environment not prepared, KW omitted due to robot FAST_TRIGGER flag
    END

Trigger FID 10 on ${rmod_type:APHA|APHG} with sn:${rmod_sn:\w+} for 2 minutes by ssh reboot.
    Prepare SSH connection to Container
    CB012097_common.reboot_rmod_by_ssh    ${sshrmod}    ${rmod_type}    ${rmod_sn}
    [Teardown]    SSHRMOD.Close Connection

Trigger FID 10 on ${rmod_dn} by lane locking.
    @{rmod}=    Evaluate    $rmod_dn.rsplit('/', 1)[1].split('-')
    gnbbbu.lock_all_sfp_links_for_radio_unit    ${rmod[1]}    ${rmod[0]}
    Fault_verifier.wait_for_alarm_activation    10
    gnb_asir.wait_for_alarm_activation    10

Clear FID 10 on ${rmod_dn} by lane unlocking.
    @{rmod}=    Evaluate    $rmod_dn.rsplit('/', 1)[1].split('-')
    gnbbbu.unlock_all_sfp_links_for_radio_unit    ${rmod[1]}    ${rmod[0]}
    Fault_verifier.wait_for_alarm_deactivation    10    awaiting_time=${180}
    gnb_asir.wait_for_alarm_deactivation    10

${trigger:Trigger|Clear} Fault 1932 on ${rmod_type:APHA|APHG} with sn:${rmod_sn:\w+} from fan(s) [${fans}]${skip:, skip reboot|}.
    lib02.Fault 1932 Toggle    ${sshrmod}    ${rmod_type}    ${fans}    trigger=${trigger}    skip_reboot=${skip}    rmod_sn=${rmod_sn}

${trigger:Trigger|Clear} Fault 1933 on ${rmod_type:APHA} with sn:${rmod_sn:\w+} from fan(s) [${fans}]${skip:, skip reboot|}.
    lib02.Fault 1933 APHA Toggle    ${sshrmod}    ${rmod_type}    ${fans}    trigger=${trigger}    skip_reboot=${skip}    rmod_sn=${rmod_sn}

${value:Prepare|Clear} ANTANTL on APHA with sn:${rmod_sn:\w+} fault generation${skip:, skip reboot|}.
    cni130136_kw.change_antantl_swconfig_flag    ${sshrmod}    prep=${value}  skip_reboot=${skip}  rmod_sn=${rmod_sn}

Trigger ANTANTL fault ${fault_id:1907|1908|1911} on ${rmod_type:APHA} with sn:${rmod_sn:\w+} from prrh ${prrh:\d} on antennas [${antennas}].
    cni130136_kw.trigger_antantl_alarm    ${sshrmod}    ${fault_id}    ${prrh}    ${antennas}    ${rmod_type}    rmod_sn=${rmod_sn}

Clear ANTANTL fault ${fault_id:1907|1908|1911} on ${rmod_type:APHA} with sn:${rmod_sn:\w+} from prrh ${prrh:\d}.
    cni130136_kw.trigger_antantl_alarm    ${sshrmod}    ${fault_id}    ${prrh}    ${EMPTY}    ${rmod_type}    rmod_sn=${rmod_sn}

Trigger prepared KPI alarms
    gnbscf_custom.perform_parameter_recommissioning
    ...    MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actKpiAlarms
    ...    update
    ...    true

Clear KPI Alarms
    gnbscf_custom.perform_parameter_recommissioning
    ...    MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actKpiAlarms
    ...    update
    ...    false

Get alarms from BTS
    Log    Get alarms from BTS...    console=True
    ${webem_alarms}=    Fault_verifier.get_alarms
    Set Test Variable    ${webem_alarms}

Get alarms from ASiR
    Log    Get alarms from ASiR...    console=True
    ${webem_asir_alarms}=    gnb_asir.get_active_asir_webem_alarms
    Set Test Variable    ${webem_asir_alarms}

Get alarms from Netact
    Log    Get alarms from Netact...    console=True
    ${out}=    netact_custom.try_upload_alarms    ${NETACT_DN}    alias=${NETACT_NAME}
    Log     ${out}
    Builtin.Sleep   10
    ${netact_alarms}=    netact_custom.get_alarm_list    ${NETACT_DN}    alias=${NETACT_NAME}
    Set Test Variable    ${netact_alarms}

Get ASiR alarms from Netact
    Log    Get ASiR alarms from Netact...    console=True
    ${out}=    netact_custom.try_upload_alarms    ${NETACT_DN}    alias=${NETACT_NAME}
    Log     ${out}
    Builtin.Sleep   10
    ${netact_asir_alarms}=    netact_custom.get_alarm_list    ${NETACT_ASIR_DN}    alias=${NETACT_NAME}
    Set Test Variable    ${netact_asir_alarms}


Trigger and Get Netact Report Snapshot
    [Arguments]    ${report_ident}=${EMPTY}

    Log    Trigger and Get Netact Report Snapshot...    console=True
    IF    $report_ident
        Set Local Variable    ${report_ident}    _${report_ident}
    END
    @{time} = 	Builtin.Get Time 	year month day hour min sec    time_=UTC
    ${time_suffix}=    Set Variable    _${time[0]}${time[1]}${time[2]}_${time[3]}${time[4]}${time[5]}_UTC
    ${report_name}=    Set Variable    ${WORKING_SET}${report_ident}${time_suffix}
    ${out}=   netact_custom.reports_save_snapshot    working_set=${WORKING_SET}
    ...  report_name=${report_name}
    ...  description=Test_automation${report_ident}
    ...  alias=${NETACT_NAME}
    ${file_path}=   netact_custom.reports_export_and_get_file    report_name=${report_name}  local_dir=${NETACT_EXPORTS}
                                                    ...    alias=${NETACT_NAME}
    ${netact_export}=    cni130136_kw.get_data_from_json_file
                ...    ${file_path[0]}/${file_path[1]}
    Set Test Variable    ${netact_export}

    [Return]    ${file_path[0]}    ${file_path[1]}    ${report_name}


Block ASiR Antenna
    [Arguments]    ${hubmod_sn}
            ...    ${id_on_hub}=0
    ${antmod_id}=    builtin.Wait Until Keyword Succeeds    6x    10s
    ...    gnb_asir.get_antmod_id_connected_to_hubmod    hubmod_sn=${hubmod_sn}    id_on_hub=${id_on_hub}
    Log    Blocking ASiR antenna ${antmod_id} on SN:${hubmod_sn}...    console=True
    builtin.Wait Until Keyword Succeeds    3x    10s    gnb_asir.block_antenna    ant_id=${antmod_id}

Unblock ASiR Antenna
    [Arguments]    ${hubmod_sn}
            ...    ${id_on_hub}=0
    ${antmod_id}=    builtin.Wait Until Keyword Succeeds    2x    10s
    ...    gnb_asir.get_antmod_id_connected_to_hubmod    hubmod_sn=${hubmod_sn}    id_on_hub=${id_on_hub}
    Log    Unblocking ASiR antenna ${antmod_id} on SN:${hubmod_sn}...    console=True
    builtin.Wait Until Keyword Succeeds    3x    10s    gnb_asir.unblock_antenna    ant_id=${antmod_id}


Close Netact Connection
    IF    $REPORT_DELETE_LIST
        netact_custom.reports_delete    report_name=${REPORT_DELETE_LIST}  alias=${NETACT_NAME}
    END
    netact_custom.Delete Node    cmwas    alias=${NETACT_NAME}
    netact_custom.Delete Node    fmwas    alias=${NETACT_NAME}
    netact_custom.Clean All    alias=${NETACT_NAME}

Test Teardown with Watching Alarms
    Log    Test Teardown with Watching Alarms    console=True
    Builtin.Sleep   30
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    common_setups_and_teardowns.Common Postconditions With Watching Alarms    collect_syslog=${False}  collect_snapshot_from_ru=${False}

