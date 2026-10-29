*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
#Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      CB010784_keywords.py
Library     taf.sbts.oam.coam.admin
Library     Collections
Library     String

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1AEQE_100M_addExtDelay_50.xml
    ...                        swconfig_flags_list=@{SW_CONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB010784_prach_145_addExtDelay_50_4DL2UL.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg
    ...        AND             ADMIN Setup Admin       alias=admin
Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs
    ...    AND   ADMIN Teardown Admin    alias=admin

*** Variables ***
@{SW_CONFIG_FLAGS}=             0x340000 = 5 # PM counter interval
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${vlue_DownlinkSymbols}=    (nrofDownlinkSymbols 9)
${TA_RACH_RESP_BIN_17}=     M55307C01017

*** Test Cases ***
CB010784-A_B2_UE_call_to_regular_cell_with_3rdPS_SA_CB009007_disabled
    Verify NR of Downlink Symbols
    Verify Guard Period Lengh    expected_value=3Symbols
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic SA
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=98.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=98.5
    Verify Timing Advance Counters
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
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
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic SA
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Verify Timing Advance Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
	Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${TA_RACH_RESP_BIN_17}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
