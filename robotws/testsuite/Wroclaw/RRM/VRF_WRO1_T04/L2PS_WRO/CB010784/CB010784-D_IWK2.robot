*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_MP_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Documentation
...    copyright: Nokia
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    variant: SANSA_FS_ECPRI_CMWV_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      taf.transport.ssh  WITH NAME  ssh
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      CB010784_keywords.py
Library      taf.sbts.oam.coam.admin
Library      Collections
Library      String
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Scf And Ap
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...        AND             ADMIN Setup Admin       alias=admin1

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs
    ...    AND   ADMIN Teardown Admin    alias=admin1

*** Variables ***
${LOCAL_MOID}=              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${vlue_DownlinkSymbols}=    (nrofDownlinkSymbols 7)
${TA_RACH_RESP_BIN_20}=     M55307C01020
${NOISE_POWER_FOR_RI}=      SEPARATOR=
...                         -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                         -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Test Cases ***
CB010784-D_IWK2_UE_call_to_regular_cell_with_3rdPS_NSA
    Verify NR of Downlink Symbols
    Verify Guard Period Lengh    expected_value=5Symbols
    Set Up X2 link
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic    ue_id=11
    Sleep    10s
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=95.5
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=85.5
    Verify Timing Advance Counters
    Perform Delta Commisioning To Enable ActNRrim
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=1200
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Update Scf And Ap
    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/iphy_1AEQE_100M_addExtDelay_120.xml
    Find Scfc And Fix And Send Full Commissioning   scfc_filename=CB010784_prach_148_addExtDelay_120_ABIP.xml

Verify NR of Downlink Symbols
    Verify Egate Content    expected_pattern=${vlue_DownlinkSymbols}

Verify guardPeriodLengh
    [Arguments]    ${expected_value}
    ${out}    Check guardPeriodLength Value For Cell      cell_id=1
    Should Contain   ${out}    ${expected_value}

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Object Distname And Id List
    [Documentation]    Get object dist name (im path) and separetly list of object's ids
    ...    usage example: for class_name=NRCELL_A keyword returns full distname without id (output example below):
    ...    out_object_distName: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-15/SCF-1/MRBTS_A-50370/NRBTS_A-50370/NRCELL_A
    ...    and list of object's ids (output example below):
    ...    out_object_id_list: [u'2', u'1']
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${object_parameters}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    alias=${alias}
    ${out_object_id_list}    Create List
    FOR    ${element}    IN    @{object_parameters}
        ${distName}    Get From Dictionary    ${element}    distName
        ${out_object_distName}    ${id}    Split String From Right    ${distName}    -    1
        Append To List    ${out_object_id_list}    ${id}
    END
    [Return]    ${out_object_distName}    ${out_object_id_list}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin1
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin1
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg

Start DL and UL Data Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=100
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=90

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Timing Advance Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
	Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${TA_RACH_RESP_BIN_20}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Perform Delta Commisioning To Enable ActNRrim
     Find Scfc and Send Delta Commissioning    scfc_filename=actNrRim_Activate.json
     Find Scfc and Send Delta Commissioning    scfc_filename=delta_enable_actRimCmFmReport.json
     Sleep    30s

Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
