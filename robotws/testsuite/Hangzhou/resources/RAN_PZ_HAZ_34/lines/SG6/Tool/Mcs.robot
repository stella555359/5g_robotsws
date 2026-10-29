*** Settings ***
Documentation    Please do not modify the file without notification to author
...              Author: Chen Jun
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot


*** Keywords ***
Kill mcs process
    [Documentation]    Author: lei.jia
    ...    If MSC controller.exe is opened in control pc, set phase will be failed with "FAIL NO ALLOC" for output port
    ...    in this way it is required to close the mcs window in advance.
    [Arguments]    ${ue_index}=${0}
    ...            ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Wait Until Keyword Succeeds    3x    5sec    Connect to control pc via cygwin    ue_index=${ue_index}
    ...                                                                              hostname=${hostname}
    ...                                                                              username=${username}
    ...                                                                              password=${password}
    csn.send_command   command=taskkill /f /im MCS_Controller.exe    connection=cygwin
    sleep    1s
    csn.send_command   command=tasklist | grep MCS_Controller.exe    connection=cygwin
    sleep    1s
    ${mcs_status}    csn.read_output    connection=cygwin
    Should be empty    ${mcs_status}
    [Teardown]    csn.disconnect      connection=cygwin

Set Phases And Attenuations For TOPYONG MCS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        param begin_input_port/end_input_port:  begin_input_port = 1, mapping output_ids (A1, A2).
    ...                                                begin_input_port = 32, mapping output_ids (A63, A64).
    ...        param begin_output_port/end_output_port: one beam with two ports
    ...        B_Odd=True: it means B10/12, B_Odd=False: it means B9/11
    ...        for B9: Set Odd Attenuations to 90db: it means A1B9/A3B9/A5B9...A63B9
    ...                Set Even Attenuations to 0db: it means A2B9/A4B9/A6B9...A64B9
    ...        for B9/10/11/12:
    ...        topyoung.Set Odd Attenuations For Output Port    attenuation=0    B_Odd=True: for B9/11, set Odd Att to 0db
    ...        topyoung.Set Even Attenuations For Output Port    attenuation=90    B_Odd=True: for B9/B11, set Even Att to 90db
    ...        topyoung.Set Odd Attenuations For Output Port    attenuation=90    B_Odd=False: for B10/12, set Odd Att to 90db
    ...        topyoung.Set Even Attenuations For Output Port    attenuation=0    B_Odd=False: for B10/12, set Even Att to 0db
    [Arguments]    ${att_value}=15    ${frequency}=2600_1_ALL
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...    ${vertical_angle}=${-6}    ${first_beam_horizontal_angle}=${-7}    ${second_beam_horizontal_angle}=${-22}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${mcs_index}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency}    mcs_index=${mcs_index}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    vertical_angle=${vertical_angle}    first_beam_horizontal_angle=${first_beam_horizontal_angle}
    ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=${att_value}    mcs_index=${mcs_index}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}


Set Phases According To Angles For Two Output Groups
    [Documentation]    author:lei.jia@nokis-sbell.com
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...            ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}    ${vertical_angle}=${-6}
    ...             ${first_beam_horizontal_angle}=${-7}    ${second_beam_horizontal_angle}=${-22}
    ...             ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...             ${begin_input_port}=${1}    ${end_input_port}=${32}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}
    ...    mcs_alias=${mcs_alias}    mcs_type=${mcs_type}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${first_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}    horizontal_angle=${first_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}
    ...    mcs_alias=${mcs_alias}    mcs_type=${mcs_type}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}    horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}

Set ATT Value For Four Output Ports
    [Documentation]   author:lei.jia@nokia-sebll.com
    ...              set first beam B5/6/7/8 to 0db
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}    ${att_value}=0
    ...             ${first_beam_begin_output_port}=${5}    ${second_beam_end_output_port}=${8}
    ...             ${begin_input_port}=${1}    ${end_input_port}=${64}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_index=${mcs_index}
    ...    mcs_alias=${mcs_alias}    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}