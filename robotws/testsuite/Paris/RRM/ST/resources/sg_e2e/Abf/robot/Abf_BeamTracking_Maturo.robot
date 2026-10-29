*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         ute_ue

Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh
Library         ${CURDIR}/../../Maturo_api/maturo_utils.py
Library         ${CURDIR}/../AbfSet/BeamSetLib.py                  WITH NAME   Abf_beamSet
Library         ${CURDIR}/../beams_tracking_utilities.py

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../beamKeyword.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../QCT_androidUe_useful_keywords.robot
Resource        ${CURDIR}/../../robot_utilities.robot


*** Variables ***
${Ue_Alias}=         UE_1
${duration}=        680s
${DL_Tput}=         200Mbits/sec
${UL_Tput}=         85Mbits/sec
${protocol}=        udp
${Rota_Axis_Offset}=     7

*** Keywords ***
Abf BeamTracking Maturo
    [Documentation]     The purpose of this test case is to check Beamtracking procedure UE reporting the 2 best beams.
    ...             and beam change.
    ...             Test Step
    ...                 1. Set BeamSetFR2_16_8_8 on gNG
    ...                 2. Perform UE attach with traffic
    ...                 3. Move RRH positioner to perform beam switching
    ...                 4. Capture gNB L1/L2 traces and UE traces.
    [Arguments]     ${beamset}    ${beam_offset}=0    ${panel_num}=0
    [Teardown]      Run keyword and ignore error      Abf Beam tracking Maturo Teardown

    ${tcpdump_filter}         Run Keyword If     '${5GRelease}'=='5G20B'
    ...    catenate    SEPARATOR=${SPACE}\\x26\\x26${SPACE}
    ...      ether[0x18:2]!=0xe101    ether[0x18:2]!=0x0122    ether[0x18:2]!=0xe103    ether[0x18:2]!=0xe206
    ...      ether[0x18:2]!=0x0108    ether[0x18:2]!=0x0131    ether[0x18:2]!=0xe208    ether[0x18:2]!=0xe20d
    ...      ether[0x18:2]!=0xe20b    ether[0x18:2]!=0xe20c    ether[0x18:2]!=0xe217    ether[0x18:2]!=0xe105
    ...    ELSE
    ...    catenate    SEPARATOR=${SPACE}\\x26\\x26${SPACE}
    ...      ether[0x18:2]!=0xe101    ether[0x18:2]!=0x0122    ether[0x18:2]!=0xe103    ether[0x18:2]!=0xe206
    ...      ether[0x18:2]!=0x0108    ether[0x18:2]!=0x0131    ether[0x18:2]!=0xe208    ether[0x18:2]!=0xe20d
    ...      ether[0x18:2]!=0xe20b    ether[0x18:2]!=0xe20c    ether[0x18:2]!=0xe217    ether[0x18:2]!=0xe105
    Set Suite Variable    ${tcpdump_filter}    ${tcpdump_filter}

    ${lxc_name}    beamKeyword.Get Container Name
    Set Suite Variable    ${lxc_name}    ${lxc_name}

    #Load BeamSetLib for beamset operation handler
    ${beamset_dir}     join path    ${CURDIR}    ../AbfSet/BeamSets/
    Abf_beamSet.load_beamSet    ${beamset}    ${beamset_dir}

    # Check if test mode is activated in sw config local
    # rdEnableBeamformingTestMode=1
    ${swconfig_file_path}    Set Variable    /ffs/run/swconfig.txt
    ${testmode}            ssh.execute            command=cat ${swconfig_file_path} | grep -i "^ *0x5800C7=1"   connection=asikFhCnx
    run keyword if  len($testmode) == 0     configuration.Modify bits in swconfig   "#0x5800C7=1"    ${swconfig_file_path}    asikFhCnx

    Run Traffic Scenario and Traces Collection Maturo    ${panel_num}

    ${index}=    Set Variable   ${0}
    ${parsed_L1L2_traces}     Create List
    configuration.luashark config       expand_field=0         expand_struct=1
    FOR    ${L1L2_trace}    IN    @{L1L2_traces_list}
        ${finename}    catenate    SEPARATOR=    parsed_L1L2_row${index}.csv
        ${parsed_L1L2_trace}     Parse L1L2 Traces Maturo    ${L1L2_trace}   ${finename}
        Append To List    ${parsed_L1L2_traces}    ${parsed_L1L2_trace}
        ${index}=    Evaluate    ${index}+1
    END
    configuration.luashark config
    ${index}=    Set Variable   ${0}
    FOR    ${parsed_L1L2_trace}    IN    @{parsed_L1L2_traces}
        ${ssbidx}=    Abf_beamSet.get_list_of_ssbidx    panel_num=${panel_num}    row_num=${index}
        L1L2_beam_tracking    filepath=${parsed_L1L2_trace}    ssbidx=${ssbidx}    beam_offset=${beam_offset}
        ${index}=    Evaluate    ${index}+1
    END

Parse L1L2 Traces Maturo
    [Documentation]     Analyse Beam Tracking change procedure  scenario per row number
    ...                 ${row} beamid list row to check ${csv_file_name} output csv file name
    [Arguments]     ${L1L2_trace}    ${csv_file_name}
    ${csv_file}    join path      ${logs_path}     ${csv_file_name}
    ${cmd}    catenate     tshark -X lua_script:/opt/luashark/luashark.lua -r ${L1L2_trace}
    ...     -T fields -Y "dldata_pdcchsendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps"
    ...     -e _ws.col.Info -e frame.time_epoch
    ...     -e DlData_PdcchSendReq.PdcchSendReq.sfn -e DlData_PdcchSendReq.PdcchSendReq.slot
    ...     -e UlData_PucchReceiveReq.PucchReceiveReq.sfn -e UlData_PucchReceiveReq.PucchReceiveReq.slot
    ...     -e  UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn  -e UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot
    ...     -e DlData_PdcchSendReq.PdcchSendReq.beamId
    ...     -e UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation -e UlData_PucchReceiveReq.pucchResources_item_0.nANPucch
    ...     -e UlData_PucchReceiveRespPs.uciBits.uciBits
    ...     -E header=y -E separator=, > ${csv_file}
    Run       ${cmd}
    [Return]       ${csv_file}

    # ...     -e UlData_PucchReceiveReq.pucchResources_item_175.numOfBitsOfUciInformation -e UlData_PucchReceiveReq.pucchResources_item_175.nANPucch


Run Traffic Scenario and Traces Collection Maturo
    [Documentation]     Run the test scenario:
    ...                 laucnch a traffic with ABF scenario and collect Ue and L1L2 tcpdump traces
    [Arguments]     ${panel_num}
    [Teardown]      Run keyword and ignore error     ute_ue.Stop Data Transfer      DT_1

    # Ue preparation
    ${local_dir}    joinpath       ${res_path}     Ue_logs
    Prepare lib and Ue    ${Ue_alias}
    Run keyword and ignore error      ute_ue.Attach Ue    ${Ue_alias}   timeout=45
    #  Preparation of Mirroring Scripts
    ${path_of_mirroring_script_on_ASIK}    gnbMirroring.Prepare gnbMirroring Script    connection=asikFhCnx
    Set Suite Variable    ${path_of_mirroring_script_on_ASIK}    ${path_of_mirroring_script_on_ASIK}
    gnbMirroring.Update gnbMirroringConfig Script    file_size_mbytes=350    filtering=on
    ...                                       filter=${tcpdump_filter}     connection=asikFhCnx
    ## copy writer on /ffs/run/config folder
    beamKeyword.Prepare Abf Writer     connection=asikFhCnx

    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=DL
    ...     duration=${duration}
    ...     throughput=${DL_Tput}
    ...     protocol=${protocol}
    Sleep   10s
    #ute_ue.Start Data Transfer
    #...     dt_name=DT_2
    #...     ue_alias=${Ue_alias}
    #...     direction=UL
    #...     duration=${duration}
    #...     throughput=${UL_Tput}
    #...     protocol=${protocol}
    #Sleep   10s
    ute_ue.Check Data Transfer Is Alive    DT_1
    #ute_ue.Check Data Transfer Is Alive    DT_2

    #ABF Beam Tracking Execusion Senario    ${trackingbeamId_list}       ${beamId_list_to_off}

    # Run keyword and ignore error      configuration.Close Connections SSH
    ${rows_count}=      Abf_beamSet.Get Rows Count    panel_num=${panel_num}
    ${L1L2_traces_list}    Create List
    # Load Specific panel offset and elevation position for each row
    FOR    ${rowNum}    IN RANGE    ${rows_count}
        ${ssbidx}=    Abf_beamSet.get_list_of_beams    panel_num=${panel_num}    row_num=${rowNum}

        ${vertPos}    ${l_rotaPos}=       Abf_beamSet.Get Left Edge Position    panel_num=${panel_num}    row_num=${rowNum}
        ${l_rotaPos}=    Evaluate    ${l_rotaPos} + ${Rota_Axis_Offset}
        ${vertPos}    ${r_rotaPos}=       Abf_beamSet.Get Right Edge Position    panel_num=${panel_num}    row_num=${rowNum}
        ${r_rotaPos}=    Evaluate    ${r_rotaPos} - ${Rota_Axis_Offset}
        ${L1L2_trace}    Move Maturo Robot and Collect Traces    ${vertPos}    ${l_rotaPos}
        ...                                               ${r_rotaPos}    ${rowNum}    ${ssbidx}
        Append To List    ${L1L2_traces_list}    ${L1L2_trace}
    END
    Set Suite Variable    ${L1L2_traces_list}    ${L1L2_traces_list}
    # Run keyword and ignore error     ute_ue.Await Data Transfer Finish      DT_1
    # Run keyword and ignore error     ute_ue.Await Data Transfer Finish      DT_2
    # Run keyword and ignore error     ute_ue.Verify Average Throughput With Deviation    DT_1    ${DL_Tput}     5%
    # Run keyword and ignore error     ute_ue.Verify Average Throughput With Deviation    DT_2    ${UL_Tput}     5%

    Run keyword and ignore error     ute_ue.Stop Data Transfer      DT_1
    # Run keyword and ignore error     ute_ue.Stop Data Transfer      DT_2

Move Maturo Robot and Collect Traces
    [Documentation]
    [Arguments]    ${vertPos}    ${l_rotaPos}    ${r_rotaPos}   ${rowNumber}    ${ssbidx}

    # set a beam attenuation
    ${beams_att_pattern}    Abf 32 Beams Set Attenuation Pattern  ${ssbidx}    ssbidx_att=\\x1E
    beamKeyword.Set Beam Attenuation for New RuGen    ${beams_att_pattern}    ${lxc_name}

    # Set Maturo robot to position (-45.0°, 0.0°)
    ${result}    moveRobot_to_Position    h_angle=${l_rotaPos}   v_angle=${vertPos}
    should be empty    ${result}

    gnbMirroring.Start Customized Mirroring Traces    ${path_of_mirroring_script_on_ASIK}    connection=asikFhCnx
    ${tcpdump_fname}    joinpath       ${res_path}     logs/tcpdump/tcpdumpL2L1_row${rowNumber}.pcap
    gnbMirroring.Check tcpdump Process is Running    connection=asikFhCnx

    #Move Robot Azimuth Position
    ${result}    moveRobot_to_Position    h_angle=${r_rotaPos}   v_angle=${vertPos}
    ${result}    moveRobot_to_Position    h_angle=${l_rotaPos}   v_angle=${vertPos}

    ${path_tmp}       gnbMirroring.Stop and Collect Mirroring Traces    connection=asikFhCnx    filtering=on
    ...                                                                 clean_scripts=no

    Move File    ${path_tmp}    ${tcpdump_fname}

    [Return]     ${tcpdump_fname}

Abf Beam tracking Maturo Teardown
    Clean Mirroring Script    connection=asikFhCnx
    ${beams_att_pattern}=    Catenate    SEPARATOR=    "\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00"


    beamKeyword.Set Beam Attenuation for New RuGen    ${beams_att_pattern}    ${lxc_name}

    Run Keyword and Ignore Error    Delete Writer on Asik
    Run keyword and ignore error      configuration.Close Connections SSH
