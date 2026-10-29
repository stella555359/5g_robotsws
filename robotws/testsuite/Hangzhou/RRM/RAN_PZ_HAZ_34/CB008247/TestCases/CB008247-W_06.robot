*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008247


Suite Setup         Run keyword    Common Suite Setup for COAM 8247    ParamterToModify=${Lock_GNBCELL}

Suite Teardown      Run keywords    Common Suite Teardown for COAM


Resource         ../Resources/CB008247_case_steps_SG3.robot



*** Variables ***
${ue_num}                     1
${Expect_dl_enable}           100
${8247_wireshark_01}          8247_wireshark_01
${csv_file_good}              8247-W06_good_result.csv
${csv_file_midial}            8247-W06_midial_result.csv
${csv_file_poor}              8247-W06_poor_result.csv
@{good_target}                770    1022    1400
@{midial_target}              550    700     800
@{poor_target}                180    200     400
${dl_throughput}              1150M
${dlexpect_tp_3741199999}               1022


*** Test Cases ***
[1]8247_W_06_Single_UE_Stationary_Performance_8x4_Good_Medium_Worse_15_Points_On_VS_OFF_AWGN_TAS_SRS
    [Documentation]     This user scenario validates the Single UE average 5G DL Throughput Performance for 8247 on vs 2200 on
    ...    TL365 -55--60, 0,25,40.
    ...    TL374 -55--60, 40,60,75
    ...    TL362 -55--60, 25,55,70
    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup
    step1 prepare the envrionment
    step2 prepare MCS
    step3 test procedures
    step4 case check point
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Case TearDown    Modify_Para_Online=${PARAMS_TO_Recovery_W06_${MRBTS_ID}}

*** Keywords ***
step1 prepare the envrionment
    [Arguments]
    Log to console    step1-1 modify scf and commission
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${ONLine_MODIFY_W06_${MRBTS_ID}}
    sleep    180s


step2 prepare MCS
    [Arguments]
    ${cprtPatternIdDict}     Get BeampatternIdDict From CPRT Logs new version    cell_idx=${37401}
    Set Test Variable    ${cprtPatternIdDict}
    NRCellid Set suit varaible    cellid=${2}
    MCS SETUP AND SET ATT
    Prepare MultiUE with client

step3 test procedures
    Log to console    step3-1 attach and capture cpiflog
    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
    ${W06_bip_01}=    Start Traffic And Capture Biplog with new way       dlexpect_tp=${dlexpect_tp_${MRBTS_ID}}
    ...                                                                   aa_sys_addr=${aa_sys_addr_${MRBTS_ID}}
    ...                                                                   dl_throughput=${dl_tput_multiue_${MRBTS_ID}}
    ...                                                                   target_file_name=W06_bip_01
    Start Performance from Good to Worse
    Log to console    step3-2 detach UE
    BuiltIn.Set Test Variable    ${W06_bip_01}
    BuiltIn.Set Test Variable    ${cpif_log_01}
    [Teardown]    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

step4 case check point
    Log to console    step4 start check point
    DFTBeam Should Be Used In BIP with mcshark    file_path=${W06_bip_01}
    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_01}
    Check PUSCH used DFT beam with mcshark    file_path=${W06_bip_01}
    Check CSIRS CELL specific Used    file_path=${cpif_log_01}


MCS SETUP AND SET ATT
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    vertical_distance=${2.1}   horizontal_distance=${0.5}
    ...    att_value_1=${25}     att_value_2=${25}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${-5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${-15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.1}   horizontal_distance=${0.5}
    ...    att_value1=${20}    att_value2=${25}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}

Start Performance from Good to Worse
    [Arguments]     ${csv_file_good}=${csv_file_good}    ${csv_file_midial}=${csv_file_midial}    ${csv_file_poor}=${csv_file_poor}
    Log to console    start performance test
    Run Keyword If    '${MRBTS_ID}'=='10175'    HAOJIN TEST with different ATTs    att_goodpoint=25    att_medialpoint=40    att_poorpoint=55
    ...    begin_θ_h=-60    end_θ_h=55    B1_port=13    B2_port=14    B3_port=15    B4_port=16
    ...    csv_path_good=${epc_log_path}/${csv_file_good}    csv_path_midial=${epc_log_path}/${csv_file_midial}
    ...    csv_path_poor=${epc_log_path}/${csv_file_poor}
    ...    good_target=${good_target}[0]    midial_target=${midial_target}[0]    poor_target=${poor_target}[0]
    Run Keyword If    '${MRBTS_ID}'=='11006'    HBTE TEST with different ATTs    att_goodpoint=${20}    att_medialpoint=${45}    att_poorpoint=${65}
    ...    begin_θ_h=${-60}    end_θ_h=${55}    B1_port=${1}    B2_port=${2}    B3_port=${3}    B4_port=${4}
    ...    csv_path_good=${epc_log_path}/${csv_file_good}    csv_path_midial=${epc_log_path}/${csv_file_midial}
    ...    csv_path_poor=${epc_log_path}/${csv_file_poor}
    ...    good_target=${good_target}[1]    midial_target=${midial_target}[1]    poor_target=${poor_target}[1]


Caculate average tput
    [Arguments]    ${csv_path}
    ${count}    BuiltIn.Get Length    ${list}
    ${sum}     set variable    ${0}
    FOR    ${j}    IN RANGE    ${count}
      ${sum}=    BuiltIn.Evaluate    ${sum}+${list[${j}]}
    END
    ${ave}    BuiltIn.Evaluate    round(${sum}/${count},2)
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=ave_tput    value2=is    value3=${ave}
    Log    average_tput is ${ave}
    Set test variable    ${ave_tput}    ${ave}
    [Return]    ${ave_tput}

Set HAOJIN θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${input_group_id}=${0}    ${horizontal_distance}=${0.5}     ${vertical_distance}=${2.1}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        haojin.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        haojin.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
        sleep    5s
        ${tput}    Check one UE traffic with pioneer client    tput_target=${dlexpect}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Set HBTE θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${horizontal_distance}=${0.5}     ${vertical_distance}=${3.2}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        hbte.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        hbte.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}
        sleep    5s
        ${tput}    Check one UE traffic with pioneer client    tput_target=${dlexpect}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Set TOPYOUNG θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${horizontal_distance}=${0.5}     ${vertical_distance}=${3.2}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        topyoung.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        topyoung.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}
        sleep    5s
        ${tput}    Power UE check throughput with nrcellid     cellid=${nrcellid}     dlexpect=${dlexpect}    ue_type=${ue_type_0}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

HAOJIN TEST with different ATTs
    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_h}    ${end_θ_h}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path_good}    ${csv_path_midial}    ${csv_path_poor}
    ...    ${good_target}    ${midial_target}    ${poor_target}
    Log to console     start good point
    HAOJIN TEST with one ATT    att=${att_goodpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${good_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_good}
    Log to console     start medial point
    HAOJIN TEST with one ATT    att=${att_medialpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${midial_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_midial}
    Log to console     start poor point
    HAOJIN TEST with one ATT    att=${att_poorpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${poor_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_poor}

HBTE TEST with different ATTs
    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_h}    ${end_θ_h}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path_good}    ${csv_path_midial}    ${csv_path_poor}
    ...    ${good_target}    ${midial_target}    ${poor_target}
    Log to console     start good point
    HBTE TEST with one ATT    att=${att_goodpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${good_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_good}
    Log to console     start medial point
    HBTE TEST with one ATT    att=${att_medialpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${midial_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_midial}
    Log to console     start poor point
    HBTE TEST with one ATT    att=${att_poorpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${poor_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_poor}

TOPYOUNG TEST with different ATTs
    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_h}    ${end_θ_h}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path_good}    ${csv_path_midial}    ${csv_path_poor}
    ...    ${good_target}    ${midial_target}    ${poor_target}
    Log to console     start good point
    TopYoung TEST with one ATT    att=${att_goodpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${good_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_good}
    Log to console     start medial point
    TopYoung TEST with one ATT    att=${att_medialpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${midial_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_midial}
    Log to console     start poor point
    TopYoung TEST with one ATT    att=${att_poorpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${poor_target}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_poor}


HAOJIN TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${avg_tput_target}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set HAOJIN θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}
    ${avg_tput}=    Caculate average tput    csv_path=${csv_path}
    ${avg_tput}=    Evaluate    int(${avg_tput})
    ${avg_tput_target}=    Evaluate    int(${avg_tput_target})
    Should Be True    ${avg_tput} >= ${avg_tput_target}

HBTE TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${avg_tput_target}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set HBTE θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}
    ${avg_tput}=    Caculate average tput    csv_path=${csv_path}
    ${avg_tput}=    Evaluate    int(${avg_tput})
    ${avg_tput_target}=    Evaluate    int(${avg_tput_target})
    Should Be True    ${avg_tput} >= ${avg_tput_target}

TopYoung TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${avg_tput_target}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set TOPYOUNG θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}
    ${avg_tput}=    Caculate average tput    csv_path=${csv_path}
    ${avg_tput}=    Evaluate    int(${avg_tput})
    ${avg_tput_target}=    Evaluate    int(${avg_tput_target})
    Should Be True    ${avg_tput} >= ${avg_tput_target}

Case TearDown
    [Arguments]     ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    ...     ${Modify_Para_Online}='NULL'
    Run Keyword And Ignore Error     Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                                                             Modify_Para_Online=${Modify_Para_Online}
    Run Keyword And Ignore Error     stop traffic and detach UE
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown