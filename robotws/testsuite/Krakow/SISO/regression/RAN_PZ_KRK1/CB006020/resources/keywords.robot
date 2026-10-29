*** Settings ***
Documentation    Resource file contains keywords for CB006020


Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME      enbscf
Library     taf.rfrl.procedures.resources.python.beamset_configurator
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB006020.resources.resources.GnbRadioExtension
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB006020.resources.resources.GnbFeatureLicensing
Library     taf.rfrl.utilities.logger.custom_logger
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
@{licensing_params_list}    actGeneralConnectivityBronze    actGeneralConnectivitySilver    actGeneralConnectivityGold

*** Keywords ***
Activate Multiband
    [Documentation]    Activate multiband by setting actDualSectorRu parameter to true
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=MRBTS-{}/NRBTS-{}
    ...     param_name=actDualSectorRu
    ...     param_value=true
    ...     skip_parameter_relation_errors=${True}

Deactivate Multiband
    [Documentation]    Deactivate multiband by setting actDualSectorRu parameter to false
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=MRBTS-{}/NRBTS-{}
    ...     param_name=actDualSectorRu
    ...     param_value=false
    ...     skip_parameter_relation_errors=${True}

Disable Licensing
    [Documentation]     Disables licensing by setting the desired licensing level to false.
    ...                 If all given licenses are disabled keyword doesn't perform recomissioning.
    ...     :param licenses: single license or list of licenses: bronze, silver and gold
    ...     :param gnb_id:    ID of gNB, default set to 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    [Arguments]    ${licenses}    ${gnb_id}=${0}    ${du_id}=${0}
    Modify Feature Licensing If Needed    licenses=${licenses}    operation=disable    gnb_id=${gnb_id}
    ...    du_id=${du_id}

Enable Licensing
    [Documentation]     Enables licensing by setting the desired licensing level to true.
    ...                 If all given licenses are enabled keyword doesn't perform recomissioning.
    ...     :param licenses: single license or list of licenses: bronze, silver and gold
    ...     :param gnb_id:    ID of gNB, default set to 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    [Arguments]    ${licenses}    ${gnb_id}=${0}    ${du_id}=${0}
    Modify Feature Licensing If Needed    licenses=${licenses}    operation=enable    gnb_id=${gnb_id}
    ...    du_id=${du_id}

Verify Extension Module State
    [Arguments]     ${operationalState}=enabled     ${administrativeState}=unlocked    ${usageState}=active
    Verify Statuses On Ru       DU=${0}     RU_id=${extension_ru_id}    operationalState=${operationalState}
    ...                         administrativeState=${administrativeState}    usage_state=${usageState}
    ...                         skip_ru_if_not_configured=${True}

Check Main and Extension RU are Unlocked
    Log to console    === Checking Main RU ===
    Verify Statuses On Ru    RU_id=${main_ru_id}   DU=${0}    administrativeState=unlocked    operationalState=enabled
    ...                      skip_ru_if_not_configured=${True}
    Log to console    === Checking Extension RU ===
    Verify Extension Module State    administrativeState=unlocked    operationalState=enabled

Check Main and Extension RU are Locked
    Log to console    === Checking Main RU ===
    Verify Statuses On Ru    RU_id=${main_ru_id}    DU=${0}    administrativeState=locked    operationalState=enabled
    ...                      usage_state=Idle       skip_ru_if_not_configured=${True}
    Log to console    === Checking Extension RU ===
    Verify Extension Module State    administrativeState=locked    operationalState=enabled    usageState=Idle

Lock Main Radio Unit via WebUI
    Log to console    === Locking main RU ===
    Lock Radio Unit on gNB from GUI  radio_unit_id=${main_ru_id}
    Sleep   30s

Unlock Main Radio Unit via WebUI
    Log to console    === Unlocking main RU ===
    Unlock Radio Unit on gNB from GUI  radio_unit_id=${main_ru_id}
    Sleep   30s

Perform Call On Main Unit
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}=udp    ${deviation}=25%
    ...  ${parallel_streams_dl}=2    ${parallel_streams_ul}=1    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}
    ...  ${buffer_client_ul}=${None}    ${buffer_server_ul}=${None}
    [Documentation]     Attach, Data Transfer DL and UL, Verification Average Troughput and Detach
    ...  :param duration: Duration of transmision, exaple: 600s 30s
    ...  :param tput_dl: Expected tput for DL, example 100 Mbits/sec
    ...  :param tput_ul: Expected tput for UL, example 100 Mbits/sec
    ...  :param protocol: udp or TCP
    ...  :param deviation: Percentage of deviation in tput, example: 25%
    ...  :param parallel_streams_dl: Number of parallel streams for DL
    ...  :param parallel_streams_ul: Number of parallel streams for UL
    ...  :param buffer_client_dl: Parameter -w in iPerf for client (downlink)
    ...  :param buffer_server_dl: Parameter -w in iPerf for server (downlink)
    ...  :param buffer_client_ul: Parameter -w in iPerf for client (uplink)
    ...  :param buffer_server_ul: Parameter -w in iPerf for server (uplink)
    Log to console    === Perform call on main radio unit with Main_Radio_UE ===
    Prepare Ue for L3 Call    capabilities=REAL_UE    alias=Main_Radio_UE
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...  protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...  parallel_streams_ul=${parallel_streams_ul}    buffer_client_dl=${buffer_client_dl}
    ...  buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...  buffer_server_ul=${buffer_server_ul}    alias=Main_Radio_UE

Perform Call On Extension Unit
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}=udp    ${deviation}=25%
    ...  ${parallel_streams_dl}=2    ${parallel_streams_ul}=1    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}
    ...  ${buffer_client_ul}=${None}    ${buffer_server_ul}=${None}
    [Documentation]    Attach, Data Transfer DL and UL, Verification Average Troughput and Detach
    ...  :param duration: Duration of transmision, exaple: 600s 30s
    ...  :param tput_dl: Expected tput for DL, example 100 Mbits/sec 2170 Mbits/sec
    ...  :param tput_ul: Expected tput for UL, example 100 Mbits/sec 255 Mbits/sec
    ...  :param protocol: udp or TCP
    ...  :param deviation: Percentage of deviation in tput, example: 25%
    ...  :param parallel_streams_dl: Number of parallel streams for DL
    ...  :param parallel_streams_ul: Number of parallel streams for UL
    ...  :param buffer_client_dl: Parameter -w in iPerf for client (downlink)
    ...  :param buffer_server_dl: Parameter -w in iPerf for server (downlink)
    ...  :param buffer_client_ul: Parameter -w in iPerf for client (uplink)
    ...  :param buffer_server_ul: Parameter -w in iPerf for server (uplink)
    Log to console    === Perform call on extension unit with Extension_UE ===
    Prepare Ue for L3 Call    capabilities=REAL_UE_EXT   alias=Extension_UE
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...  protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...  parallel_streams_ul=${parallel_streams_ul}    buffer_client_dl=${buffer_client_dl}
    ...  buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...  buffer_server_ul=${buffer_server_ul}    alias=Extension_UE

Lock All Radio Cells
    Log To Console            === Perform locking of all radio module cells ===
    Perform Cell Operation      operation=lock        rmod_id=${main_ru_id}

Unlock All Radio Cells
    Log To Console            === Perform unlocking of all radio module cells ===
    Perform Cell Operation      operation=unlock      rmod_id=${main_ru_id}

Lock All Extension Module Cells
    Log To Console            === Perform locking of all extension module cells ===
    Perform Cell Operation      operation=lock        rmod_id=${extension_ru_id}

Unlock All Extension Module Cells
    Log To Console            === Perform unlocking of all extension module cells ===
    Perform Cell Operation      operation=unlock      rmod_id=${extension_ru_id}

Verify Only Extension Cells Are Locked
    Log To Console    === Verify all extension module cells are locked and all main ru cells are unlocked ===
    Verify Cells State    radio_cells_locked=${False}    extension_cells_locked=${True}

Verify Only Main RU Cells Are Locked
    Log To Console    === Verify all main ru cells are locked and all extension module cells are unlocked ===
    Verify Cells State    radio_cells_locked=${True}    extension_cells_locked=${False}

Change defaultLnRelGnbCellId on eNB
    [Arguments]    ${defaultLnRelGnbCellId_value}
    enbscf.perform_configuration_parameter_recommissioning    dist_name=MRBTS-{}/LNBTS-{}/LNCEL-1
    ...                                                       parameter=defaultLnRelGnbCellId
    ...                                                       operation=update
    ...                                                       value=${defaultLnRelGnbCellId_value}

Verify Call
    [Arguments]    ${duration}    ${main_tput_dl}    ${main_tput_ul}    ${ext_tput_dl}    ${ext_tput_ul}    ${protocol}=udp
    ...  ${deviation}=25%    ${parallel_streams_dl}=2    ${parallel_streams_ul}=1    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}
    ...  ${buffer_client_ul}=${None}    ${buffer_server_ul}=${None}
    [Documentation]    Attach, Data Transfer DL and UL, Verification Average Troughput and Detach
    ...  :param duration: Duration of transmision, exaple: 600s 30s
    ...  :param tput_dl: Expected tput for DL, example 100 Mbits/sec 2170 Mbits/sec
    ...  :param tput_ul: Expected tput for UL, example 100 Mbits/sec 255 Mbits/sec
    ...  :param protocol: udp or TCP
    ...  :param deviation: Percentage of deviation in tput, example: 25%
    ...  :param parallel_streams_dl: Number of parallel streams for DL
    ...  :param parallel_streams_ul: Number of parallel streams for UL
    ...  :param buffer_client_dl: Parameter -w in iPerf for client (downlink)
    ...  :param buffer_server_dl: Parameter -w in iPerf for server (downlink)
    ...  :param buffer_client_ul: Parameter -w in iPerf for client (uplink)
    ...  :param buffer_server_ul: Parameter -w in iPerf for server (uplink)
    Log to console    === Perform call on main radio unit ===
    Change defaultLnRelGnbCellId on eNB    defaultLnRelGnbCellId_value=1
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${main_tput_dl}    tput_ul=${main_tput_ul}
    ...  protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...  parallel_streams_ul=${parallel_streams_ul}    buffer_client_dl=${buffer_client_dl}
    ...  buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...  buffer_server_ul=${buffer_server_ul}    alias=UE
    Log to console    === Perform call on extension unit ===
    Change defaultLnRelGnbCellId on eNB    defaultLnRelGnbCellId_value=2
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${ext_tput_dl}    tput_ul=${ext_tput_ul}
    ...  protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...  parallel_streams_ul=${parallel_streams_ul}    buffer_client_dl=${buffer_client_dl}
    ...  buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...  buffer_server_ul=${buffer_server_ul}    alias=UE
    [Teardown]
    Change defaultLnRelGnbCellId on eNB    defaultLnRelGnbCellId_value=1
