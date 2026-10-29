*** Settings ***

Documentation    :copyright: Nokia

Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/wro_2/resources/common_functions.py

Library      ta5g_egate
Library      ute_wtssim
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_ue_measurements
Library      ta5g_throughput
Library      ta5g_testline_management
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb
Library      taf.transport.ssh           WITH NAME    taf_ssh
Library      taf.sw.scout    WITH NAME     scout
Library      OperatingSystem
Library      taf.sbts.oam.coam.admin    WITH NAME   coam

*** Variables ***
@{odd_ues}=         1    3    5    7    9    11
@{subpool0_UEs}=    3    4    11    12
@{rdFlag_UL_15MCS}=        0x580367=0xFFFF #rdParam to limit UL MCS to 15
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py

*** Keywords ***
Prepare Test Setup For One Real Gnb
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc}=SCFC    ${cfg}=cfg
    ${iphy}=    Create Config File Path Variable Name     filetype=${iphy}    name=${tc_id}
    ${scfc}=    Create Config File Path Variable Name     filetype=${scfc}    name=${tc_id}
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}

    ${iphy_filename}=    Get Variable Value    ${iphy}
    ${scfc_filename}=    Get Variable Value    ${scfc}
    ${cfg_filename}=     Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Backup And Modify Swconfig File    parameters_list=@{rdFlag_UL_15MCS}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}
    ...    AND         Wait For Testline Icmp Echo Replies And Ssh Services
    ...    AND         Set VM Ethernet Interfaces for Simulated Core Network
    ...    AND         Check Radios Availability
    ...    AND         Update BSR Package
    ...    AND         Reach Onair    lua_cfg=${cfg_filename}
    ...    AND         Activate And Check If X2 Link is active

Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Update BSR Package
    Log To Console    BSR package uploading...
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/CB015149_BSR
    ${filename}    Set variable     BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    Run     sudo wget ${dllink}/${filename} --user=${ARTI_USER} --password=${ARTI_PASS} -P ${CURDIR}/CB015149_BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/CB015149_BSR/BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    coam.teardown admin

Generate UL MIMO SRS BEAM POS NR Profile for UE
    [Arguments]    ${p_id}    ${i_p}    ${s_p}
    Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=${p_id} mode=fixed init_quad_pos=${i_p} init_sub_quad_pos=${s_p} test_type=UL_MIMO

Active UL MIMO SRS BEAM PS NR Profile
    [Arguments]    ${ue_id}    ${profile_id}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}

Dective UL MIMO SRS BEAM PS NR Profile
    [Arguments]    ${ue_id}    ${profile_id}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=${profile_id}

Start Data Traffic for Ue
    [Arguments]    ${ue_id}    ${trf_id}    ${pdu}    ${throughput}
    Start Data Traffic    ues=${ue_id}    pdu=${pdu}    direction=ul    throughput=${throughput}    traffic_id=${trf_id}

Verify Traffic on PUSCH for UE
    [Arguments]    ${ue_id}    ${expected_throughput}
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}     expected_throughput=${expected_throughput}      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=average    margin=30%

Setup PDU Session Configure UL-MIMO and Start Data Traffic For Multiple UEs
    [Arguments]    ${ue_ids}
    Generate UL MIMO SRS BEAM POS NR Profile for UE    p_id=1    i_p=0    s_p=0
    Generate UL MIMO SRS BEAM POS NR Profile for UE    p_id=2    i_p=2    s_p=3
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Set Internal Traffic Type For UE    ue=${ue_ids}[${ue_index}]    pdu=1
        Establish PDU Session    ue_id=${ue_ids}[${ue_index}]
        IF    str(${ue_ids}[${ue_index}]) in ${odd_ues}
            Active UL MIMO SRS BEAM PS NR Profile    ue_id=${ue_ids}[${ue_index}]    profile_id=1
        ELSE
            Active UL MIMO SRS BEAM PS NR Profile    ue_id=${ue_ids}[${ue_index}]    profile_id=2
        END
        Start Data Traffic for Ue    ue_id=${ue_ids}[${ue_index}]    pdu=1    trf_id=1    throughput=100mbps
    END

Generate Full Tput for Subpool-0 And Decrease UEs Tput For Subpools-1-2-3
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        IF    str(${ue_ids}[${ue_index}]) in ${subpool0_UEs}
            Start Data Traffic for Ue    ue_id=${ue_ids}[${ue_index}]    pdu=1    trf_id=${ue_ids}[${ue_index}]      throughput=100mbps
        ELSE
            Start Data Traffic for Ue    ue_id=${ue_ids}[${ue_index}]    pdu=1    trf_id=${ue_ids}[${ue_index}]      throughput=15mbps
        END
    END

Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated With AMBR Limiting Throughput
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify Traffic on PUSCH for UE    ue_id=${ue_ids}[${ue_index}]    expected_throughput=10
        Sleep    3s
    END

Verify Traffic on PUSCH For Every UE After Fullboard Capacity Activated
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify Traffic on PUSCH for UE    ue_id=${ue_ids}[${ue_index}]    expected_throughput=90
        Sleep    3s
    END

Verify Traffic on PUSCH For Every UE After Decrease Tput In Three Subpools and Increase In Subpool-0
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        IF    str(${ue_ids}[${ue_index}]) in ${subpool0_UEs}
            Verify Traffic on PUSCH for UE    ue_id=${ue_ids}[${ue_index}]     expected_throughput=90
            Sleep    3s
        ELSE
            Verify Traffic on PUSCH for UE    ue_id=${ue_ids}[${ue_index}]     expected_throughput=15
            Sleep    3s
        END
    END

Verify Traffic on PUSCH For Every UE After Generating Remote Interferences
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
      Verify Traffic on PUSCH for UE    ue_id=${ue_ids}[${ue_index}]     expected_throughput=5
      Sleep    3s
    END

AMBR Limit Change By Triggering PDU Session Modification For UE
    [Arguments]    ${ue_id}    ${dl_limit}    ${ul_limit}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 session_ambr_dl=${dl_limit}:Mbps session_ambr_ul=${ul_limit}:Mbps by=amf

AMBR Limit Change By Triggering PDU Session Modification For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        AMBR Limit Change By Triggering PDU Session Modification For UE    ue_id=${ue_ids}[${ue_index}]     dl_limit=100    ul_limit=120
    END

Generate Remote Interferences
    ${base}=    Set Variable    remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32
    ${noise}=   Catenate    SEPARATOR=    noise_power_values=-63,-65,-67,-69,-71,-73,-75,-79,-81,-83,
    ...                              -85,-87,-89,-93,-95,-98,-101,-105,-110,-115,-115,-115,-115,-115,
    ...                              -115,-115,-115,-115,-115,-115,-115,-115
    ${prepare_command}=    Catenate    ${base}    ${noise}
    Execute Egate Command    cmd=${prepare_command}

Activate Testmode With Remote Interferences For Cell-1
    Execute Egate Command    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Deactivate Testmode With Remote Interferences For Cell-1
    Execute Egate Command    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate

Generate RIM-RS Profile
    ${prepare_command}=    Catenate
    ...                    rimrs_testmode_nr profile_id=1 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=22223 propagation_delay=16
    ...                    rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50 rsPattern2Period=25  factorRsSequence=0 offsetRsSequence=0
    ...                    startRbForRs=1,100 repetitionRsType1=4 numRsType1SetId=65536
    Execute Egate Command
    ...    cmd=${prepare_command}

Activate Testmode With RIM-RS For Cell-1
    Execute Egate Command    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=1 action=activate

Deactivate Testmode With RIM-RS For Cell-1
    Execute Egate Command    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=1 action=deactivate

UE Exit Idle Mode After Geting Released Due to Remote Interference And Start Data Traffic
    Dective UL MIMO SRS BEAM PS NR Profile    ue_id=2    profile_id=2
    Wait 10s For UL MIMO SRS BEAM PS NR Profile Deactivation
    Exit Idle Mode Without Confirmation     ue_id=2
    Wait 10s For UE To Exit Idle Mode
    Active UL MIMO SRS BEAM PS NR Profile     ue_id=2    profile_id=2
    Start Data Traffic for Ue    ue_id=2    pdu=1    throughput=100mbps    trf_id=1
    Wait 10s For Traffic To Stabilize
