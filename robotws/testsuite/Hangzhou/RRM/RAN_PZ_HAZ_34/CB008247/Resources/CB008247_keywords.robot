*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:lei.jia@nokia-sbell.com, jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Tool/gnb_logs.robot

*** Keywords ***
8247 Suite Setup
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]      ${is_need_to_kill_mcs}=${True}    ${ue_index}=${0}
#    Clone Gnblogs Tool
    robot_common_operations.Common Suite Setup
    ${gnb_status_by_sommon_scf}    Run Keyword And Return Status    SISO Coam Suite Setup
    run keyword if    not ${gnb_status_by_sommon_scf}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable     ${stream}
    Get SCF File Path
    Run keyword if    ${is_need_to_kill_mcs}    Wait Until Keyword Succeeds    3 min    30 sec
    ...    CB008247_keywords.Kill mcs process    ue_index=${ue_index}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred

8247 Suite TearDown
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    Commissioning SCF With Given Path    scf_file_path=${scf_file_path}    scf_name=${scf_name}
    ${scf_file_full_name}    set variable    Configuration_IWK_${stream}.xml
    ${scf_file_full_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${recover_scf_file_full_path}    set variable if    'SBTS00' in '${stream}'    ${scf_file_full_path}    ${Golden_SCF_Path}
    COAM Commission with scf file    scf_file_path=${recover_scf_file_full_path}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    force_radio_reset=${True}    timeout=${900}    connection=${connection}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections

8247 Case SetUp
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_id_assigned}=${None}    ${scf_file_path}=${Golden_SCF_Path}    ${scf_name}=None
    robot_common_operations.Common Case Setup
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred
    Run Keyword If    '${scf_name}'!='${None}'    Case Setup With CA    cell_id_assigned=${cell_id_assigned}
    ...                                       scf_file_path=${scf_file_path}    scf_name=${scf_name}
    ...    ELSE     Case SetUp Without CA    cell_id_assigned=${cell_id_assigned}


8247 Case TearDown
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${swconfig_modify}=${None}    ${ue_index}=${0}
    run keyword if    'mtk' in '${ue_type}'    Run Keyword And Ignore Error    Stop Traffic With MTK UE    ue_index=${ue_index}
    ...    ELSE    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If Test Failed    Run Keyword And Ignore Error    COAM Save snapshot via rest api    timeout=${600}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    robot_common_operations.Common Case Teardown
    run keyword if    ${swconfig_modify}!=${None}    run keywords
    ...    Connect to Common Unit Master    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...    Run Keyword And Ignore Error    CB008247_keywords.COAM gNB Reset site    AND
    ...    Run Keyword And Ignore Error    sleep    60s
    run keyword and continue on failure    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Case SetUp Without CA
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_id_assigned}=${None}
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${cell_idx}    Get cellid on GNB    cell_id_assigned=${cell_id_assigned}
    Set Test Variable    ${cell_idx}
    COAM Create log directory
    ${cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${cprtPatternIdDict}
    Keep only Pcell notbarred for CA testing    pcell_index=${cell_idx}
    Generate Pcell Mapping Info    pcell_index=${cell_idx}
    Wait Gnb Ready And Cell On Air

Case Setup With CA
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_id_assigned}=${None}    ${scf_file_path}=${Golden_SCF_Path}    ${scf_name}=None
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Commissioning SCF With Given Path    scf_file_path=${scf_file_path}    scf_name=${scf_name}
    COAM Create log directory
    ${cell_idx}    Get cellid on GNB    cell_id_assigned=${cell_id_assigned}
    Set Test Variable    ${cell_idx}
    Keep only Pcell notbarred for CA testing    pcell_index=${cell_idx}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${cell_idx}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0

Commissioning SCF With Given Path
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${scf_file_path}=${Golden_SCF_Path}    ${scf_name}=None
    ${scf_name_prefix}    Set Variable    ${scf_file_path.split('.xm')[0]}
    ${scf_last_name}    Run Keyword If    '${scf_name}' != 'None'    Set Variable    ${scf_name.split('_')[-1]}
    Run Keyword If    '${scf_name}' != 'None'    Commissioning SCF And Check On Air      scf_path=${scf_name_prefix}_${scf_last_name}

COAM gNB Reset site
    [Documentation]         Reset site
    [Arguments]    ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    coam.reset_site         connection=${connection}
    [Teardown]    COAM Teardown gnb connections

Keep only Pcell notbarred for CA testing
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    Keep only Pcell to not barred status, and set all other cells to barred status
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${pcell_index}    ${connection}=GNB_OAM
    @{expected_pcell_list}    create list    ${pcell_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}
    ...    connection=${connection}    timeout=${180}

Kill mcs process
    [Documentation]    Author: lei.jia
    ...    If MSC controller.exe is opened in control pc, set phase will be failed with "FAIL NO ALLOC" for output port
    ...    in this way it is required to close the mcs window in advance.
    [Arguments]    ${ue_index}=${0}
    Wait Until Keyword Succeeds    3x    5sec    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command   command=taskkill /f /im MCS_Controller.exe    connection=cygwin
    sleep    1s
    csn.send_command   command=tasklist | grep MCS_Controller.exe    connection=cygwin
    sleep    1s
    ${mcs_status}    csn.read_output    connection=cygwin
    Should be empty    ${mcs_status}
    [Teardown]    csn.disconnect      connection=cygwin

TOPYONG MCS ON AEHC With QC UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        update 20220916: after add multiue for 8360-B, one more "two-in-one power divider" added for B5/6/7/8/9/10/11/12,
    ...                         rsrp degrade about 3db.
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
    [Arguments]    ${att_value1}=10    ${att_value2}=10    ${frequency}=2600_1_ALL
#    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...    ${vertical_angle}=${-6}    ${first_beam_horizontal_angle}=${-7}    ${second_beam_horizontal_angle}=${-22}
    ${mcs_type}    mcs_common.Get MCS Type
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency}
    CB008247_keywords.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    vertical_angle=${vertical_angle}    first_beam_horizontal_angle=${first_beam_horizontal_angle}
    ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
    Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}
    ...    att_value1=${att_value1}    att_value2=${att_value2}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}

Set Phases According To Angles For Two Output Groups
    [Documentation]    author:lei.jia@nokis-sbell.com
    [Arguments]    ${mcs_type}    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}    ${vertical_angle}=${-6}
    ...             ${first_beam_horizontal_angle}=${-7}    ${second_beam_horizontal_angle}=${-22}
    ...             ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...             ${begin_input_port}=${1}    ${end_input_port}=${32}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${first_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}    horizontal_angle=${first_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}    horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}

Set Odd And Even ATT For Four Output Ports With Different Values
    [Documentation]   author:lei.jia@nokia-sebll.com
    ...              set first beam B9/10 to 0db, set second beam B11/12 to 5db
    [Arguments]    ${mcs_type}    ${att_value1}=0    ${att_value2}=5
    ...             ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...             ${begin_input_port}=${1}    ${end_input_port}=${64}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value1}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${first_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value2}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}

###########mcs setting used for perform testing
Set Topypoung θ poll for horizontal
    [Documentation]    used for topyoung mcs to run performance testing.
    ...                  port5/6 θ_h: [-45, 35], θ_v:-12  ATT=22 for good, ATT=32 for medium, ATT=42 for Worse
    ...                  port7/8 θ_h: [-35, 45], θ_v:-12  ATT=22 for good, ATT=32 for medium, ATT=42 for Worse
    ...                  stay 5s at each step.
    [Arguments]    ${att_value1}=19    ${att_value2}=19
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${begin_θ_h}=-45    ${end_θ_h}=35    ${θ_h_increment}=10
    ...    ${vertical_angle}=${-12}    ${sleep_time}=5s    ${range_step}=5
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}
    ...    att_value1=${att_value1}    att_value2=${att_value2}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    mcs_common.Set θ Poll For Horizontal Angle    mcs_type=${mcs_type}
    ...    B1_port=${first_beam_begin_output_port}    B2_port=${first_beam_end_output_port}
    ...    B3_port=${second_beam_begin_output_port}    B4_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    θ_h_increment=${θ_h_increment}
    ...    vertical_angle=${vertical_angle}    sleep_time=${sleep_time}    range_step=${range_step}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}

Capturing Aasyslog through all the performance testing
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                Author: lei.jia
    [Arguments]    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt    ${Teardown_after_finished}=${True}
    ...    ${att_value1}=19    ${att_value2}=19
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${begin_θ_h}=-45    ${end_θ_h}=35    ${θ_h_increment}=10
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...    ${vertical_angle}=${-12}    ${sleep_time}=5s
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress
    Set Topypoung θ poll for horizontal    att_value1=${att_value1}    att_value2=${att_value2}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    θ_h_increment=${θ_h_increment}
    ...    vertical_angle=${vertical_angle}    sleep_time=${sleep_time}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'    Teardown the Aasyslog save progress

Check Tput Without Power UE Collcet Tput
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Descrition: Verify throughput for performance testing during all the process, collect tput before.
    [Arguments]    ${tput_log}
    ...            ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput}=${None}
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${target_avg_percent}=0.9
    ...            ${min_percent}=0.5
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ${list_nrcell_ids}    check_android_ue_l3_call_process.Get NRCELLID based on CELLID
    ...    cellid=${cellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    FOR    ${item}    IN   UL  DL
        ${direction}    Set Variable    ${item.split('_')}[0]
        ${expect_tput}    Set Variable If    '${direction}'=='UL'     ${expect_ul_tput}
        ...                                  '${direction}'=='DL'     ${expect_dl_tput}
        Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
        ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
        ...                                                           target_throughput=${expect_tput}
        ...                                                           target_avg_percent=${target_avg_percent}
        ...                                                           actCarrierAggregation=${actCarrierAggregation}
        ...                                                           check_source=${check_source}
        ...                                                           min_percent=${min_percent}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Make_L3_Call_With_Power_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${True}
    ...            ${get_attach_cell_index_needed}=${True}
    ...            ${is_wireshark_log_capture}=${True}
    ...            ${wireshark_log_prefix}=ue_attach
    ...            ${4G_check}=${False}
    ...            ${reset_sol}=none
    ...            ${sleep_interval}=10 sec
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=600M
    ...            ${duration}=1800
    ...            ${ue_index}=${0}
    ...            ${dl_process_num}=2
    Log To Console    \n***start ue attach ***\n
    ${attach_info}    Start UE Attach With Power UE    is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                wireshark_log_prefix=${wireshark_log_prefix}
    ...                                                4G_check=${4G_check}
    ...                                                reset_sol=${reset_sol}
    ...                                                sleep_interval=${sleep_interval}
    ...                                                get_attach_cell_index_needed=${get_attach_cell_index_needed}
    ...                                                is_do_require_ue=${is_do_require_ue}
    ...                                                ue_index=${ue_index}
    ${cpif_log_path}    Set Variable If    '${get_attach_cell_index_needed}'=='${True}'
    ...    ${attach_info['cpif_log_path']}    ${attach_info}
    Log To Console    \n***start to transfer traffic ***\n
    Run Keyword And Continue On Failure    Start L3 Call With Power UE
    ...                                    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    duration=${duration}
    ...                                    ue_index=${ue_index}
    ...                                    dl_process_num=${dl_process_num}
    [Return]    ${cpif_log_path}

Stop Traffic With MTK UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  this keyword stop ul/dl traffic, never detach mtk ue!
    [Arguments]    ${ue_index}=${1}
    ...             ${iperf_type}=via_app
    ...             ${apn_address}=wap1nokiacom
    ...             ${protocol}=udp
    ${data_direction_list}    create list    ul    dl
    FOR    ${direction}    IN    @{data_direction_list}
        run keyword and continue on failure    power_ue.Stop traffic    ue_type=qct_dx50
        ...                                                             direction=${direction}
        ...                                                             dt_name=dt_${direction}
        ...                                                             protocol=${protocol}
        ...                                                             iperf_port=default
        ...                                                             iperf_type=${iperf_type}
        ...                                                             ue_index=${ue_index}
        ...                                                             apn_address=${apn_address}
    END
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnon Airplane Mode    ue_index=${ue_index}

Make_L3_Call_With_MTK_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]
#    ...            ${is_do_require_ue}=${True}
#    ...            ${get_attach_cell_index_needed}=${True}
#    ...            ${is_wireshark_log_capture}=${True}
    ...            ${wireshark_log_prefix}=ue_attach
#    ...            ${4G_check}=${False}
#    ...            ${reset_sol}=none
    ...            ${sleep_interval}=60 sec
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=600M
    ...            ${duration}=1800
    ...            ${ue_index}=${0}
    ...            ${enb_index}=${1}
    ...            ${mode}=SA
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${dl_process_num}=2
    Log To Console    \n***start ue attach for MTK ***\n
    ${attach_info}    MTK_common_keywords.Start UE Attach With MTK    wireshark_log_prefix=${wireshark_log_prefix}
    ...                                                               sleep_interval=${sleep_interval}
    ...                                                               coam_connection=${coam_connection}
    ...                                                               mode=${mode}
    ...                                                               ue_index=${ue_index}
    ...                                                               enb_index=${enb_index}
    ${attach_wireshark}    Set Variable If    '${mode}'=='NSA'
        ...    ${attach_info['enb_wireshark_log_path']}    ${attach_info['cpif_log_path']}
    Log To Console    \n***start ue transfer traffic ***\n
    L3call.Start L3 Call Data Transfer                                ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${duration}
    ...                                                               need_get_ue_ip=${True}
    ...                                                               cpif_log_path=${attach_wireshark}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               mode=${mode}
    ...                                                               ue_index=${ue_index}
    ...                                                               dl_process_num=${dl_process_num}
    ${cpif_log_path}    Set Variable    ${attach_info['cpif_log_path']}
    [Return]    ${cpif_log_path}


Make_L3_Call_And_Check_Tput
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${True}
    ...            ${get_attach_cell_index_needed}=${True}
    ...            ${is_wireshark_log_capture}=${True}
    ...            ${wireshark_log_prefix}=ue_attach
    ...            ${4G_check}=${False}
    ...            ${reset_sol}=none
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=600M
    ...            ${start_traffic_duration}=1800
    ...            ${select_scell_index}=${None}
    ...            ${target_DL_avg_percent}=0.95
    ...            ${target_UL_avg_percent}=0.95
    ...            ${min_DL_percent}=0.1
    ...            ${min_UL_percent}=0.1
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${check_pcell_tput}=${True}
    ...            ${check_scell_tput}=${False}
    ...            ${is_need_stop_traffic}=${True}
    ...            ${duration}=180
    ...            ${is_need_bip_capture}=${True}
    ...            ${wireshark_sleep_interval}=15 sec
#    ...            ${sleep_interval}=3 sec
#    ...            ${asib_interface}=eths3
    ...            ${scell_mapping}=${None}
    ...            ${ue_index}=${0}
    ...            ${mode}=SA
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${is_askey_used}=${False}
#    ...            ${cell_index}=301
    ...            ${bip_duration}=5sec
    ...             ${dl_process_num}=2
    ${ue_type_index}    Set Variable If    ${is_askey_used}==${True}     ${0}    ${ue_index}
    run keyword and ignore error    csn.disconnect    connection=${connection}
    connection_alias_store.Connect to Common Unit Master
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_type_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Run keyword if    '${ue_type}' == 'mtk'    Make_L3_Call_With_MTK_UE
    ...                                                               wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                               mode=${mode}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${start_traffic_duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               mode=${mode}
    ...                                                               ue_index=${ue_index}
    ...                                                               dl_process_num=${dl_process_num}
    ...      ELSE              Make_L3_Call_With_Power_UE
    ...                                                is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                4G_check=${4G_check}
    ...                                                reset_sol=${reset_sol}
    ...                                                sleep_interval=${wireshark_sleep_interval}
    ...                                                get_attach_cell_index_needed=${get_attach_cell_index_needed}
    ...                                                is_do_require_ue=${is_do_require_ue}
    ...                                                ue_index=${ue_index}
    ...                                                ul_data_transfer=${ul_data_transfer}
    ...                                                dl_data_transfer=${dl_data_transfer}
    ...                                                duration=${start_traffic_duration}
    ...                                                dl_process_num=${dl_process_num}
    Run Keyword And Continue On Failure    Check Tput For CA Group    ue_type=${ue_type}
    ...                                           addition_scell_index_list=${select_scell_index}
    ...                                           target_DL_avg_percent=${target_DL_avg_percent}
    ...                                           target_UL_avg_percent=${target_UL_avg_percent}
    ...                                           min_DL_percent=${min_DL_percent}
    ...                                           min_UL_percent=${min_UL_percent}
    ...                                           check_pcell_tput_type=${check_pcell_tput_type}
    ...                                           check_scell_tput_type=${check_scell_tput_type}
    ...                                           check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                           check_pcell_tput=${check_pcell_tput}
    ...                                           check_scell_tput=${check_scell_tput}
    ...                                           duration=${duration}
    ...                                           scell_mapping=${scell_mapping}
    ${bip_log_path}    Run Keyword If    '${is_need_bip_capture}'=='${True}'    Start And Stop Bip Capture
#    ...                                                                                                       sleep_interval=${sleep_interval}
#    ...                                                                                                       asib_interface=${asib_interface}
#    ...                                                                                                       cell_index=${cell_index}
    ...                                                                                                       duration=${bip_duration}
    Run Keyword If    '${is_need_stop_traffic}'=='${True}'    Run Keyword And Ignore Error    Stop Traffic With Power UE
    [Return]    ${cpif_log_path}    ${bip_log_path}

Start And Stop Bip Capture
    [Documentation]    author:lei.jia@nokis-sbell.com
    [Arguments]    ${duration}=5sec
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    target_file_name=bip_${timestamp}
    Sleep    ${duration}
    ${bip_log_full_path}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                             target_file_name=bip_${timestamp}
    [Return]    ${bip_log_full_path[0]}

Start And Stop Bip Capture With gnbMirroring
    [Documentation]    author:lei.jia@nokis-sbell.com
    [Arguments]        ${sleep_interval}=3 sec
    ...                 ${asib_interface}=eths3
    Start Bip Capture
    Sleep    ${sleep_interval}
    ${bip_log_list}    Stop Bip Capture   asib_interface=${asib_interface}
    ${bip_log_path}    Set Variable    ${bip_log_list[0]}
    [Return]    ${bip_log_path}

Get patternIdDict From CPRT Logs
    [Documentation]   Author: Jia Lei
    ...                Desription: Get patternIdDict from cprt log.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=SCellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*SCellParametersReq(.*?)ruMaxRemasks*
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfoList From CPRT Logs    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch patternId Of Different Beams From Output    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}

Get PatternIdInfoList From CPRT Logs
    [Documentation]   Author: Jia Lei
    ...                Desription: Get PatternIdInfoList Log info from cprt log
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=patternIdInfoList
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${fsm_type}=    coam_gnb_classical.COAM Get FSM Type    connection=${connection}
    ${cell_mapping}=    coam_gnb_classical.get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${nrcellid}=    Evaluate    int(${cell_mapping[${cell_idx}]['nrCellIdentity']})
    ${alias}    set variable if    '${fsm_type}'=='ASIB'    ASIK Slave    ASIK Master
    Run Keyword If    '${fsm_type}'=='ASIB'    Connect to Common Unit Master    alias=${alias}
    ...    ELSE    Connect to Common Unit Slave    alias=${alias}
    ${cprt_patternIdList} =    set variable    cat /tmp/node_CPRT*/tmp/startup_cp_rt.log| grep -i '${grep_info}'
    ${cprt_xz_patternIdList} =  set variable  xzcat /ffs/run/logs/CPRT*_aasyslog/startup_cp_rt.log.xz| grep -i '${grep_info}'
    ${cprt_xz_output} =    csn.execute    command=${cprt_xz_patternIdList}   connection=${alias}
    ${cprt_xz_match} =    run keyword and ignore error    should contain    ${cprt_xz_output}    ${grep_info}
    ${cprt_output}    run keyword if    '${cprt_xz_match[0]}'=='FAIL'    csn.execute    command=${cprt_patternIdList}    connection=${alias}
    ${patternIdInfoList_log}    set variable if    '${cprt_xz_match[0]}'=='FAIL'    ${cprt_output}    ${cprt_xz_output}
    [Return]    ${patternIdInfoList_log}    ${nrcellid}

Fetch PatternIdInfoList From CPRT Logs
    [Documentation]   Author: Jia Lei
    ...                Desription: Fetch PatternIdInfoList from cprt log, used for 2200 not enabled.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=patternIdInfoList
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
#    ${cprtPatternIdDict}    Fetch patternId Of Different Beams From Output    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${patternIdInfoList_log}

Fetch patternId Of Different Beams From Output
    [Documentation]   Author: Jia Lei
    ...                Desription: Get patternIdInfoList from cprt log.
    [Arguments]    ${patternIdInfoList_log}    ${predefined_beam}=PREDEFINED    ${PMI_beam}=DYNAMIC    ${DFT_beam}=DFTNORMAL
    ...    ${DFT_muted_beam}=DFTNORMALMUTED    ${DFT_TAPERING_beam}=DFTTAPERING    ${PMI_muted_beam}=DYNAMICMUTED
    &{cprtPatternIdDict}    Create Dictionary
    ${beamSetType_list}    create list        ${predefined_beam}    ${PMI_beam}    ${DFT_beam}    ${DFT_muted_beam}
    ...    ${DFT_TAPERING_beam}    ${PMI_muted_beam}
    FOR  ${beamSetType}  IN  @{beamSetType_list}
     ${patternIdMin_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.:(\\d+)
     ${patternIdMax_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.*?patternIdMax.:(\\d+)
     ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
     ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
     ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
     ${patternId_list}    Remove Duplicates    ${patternId_list}
     Set To Dictionary    ${cprtPatternIdDict}    ${beamSetType}    ${patternId_list}
    END
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch patternId For DFT Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch patternId For PMI Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId For PMI Beam
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC    ${PMI_exp}=DYNA
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_exp}.*<LOG.*>.*dMin.:(\\d+).*beamSetType
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_exp}.*<LOG.*>.*dMin.*?patternIdMax.:(\\d+).*beamSetType
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch patternId For PMI Beam again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId For PMI Beam again
    [Documentation]   Author: Jia Lei
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_beam}...patternIdMin.*<LOG.*>(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Fetch patternId For DFT Beam
    [Documentation]   Author: Jia Lei
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*<LOG.*>..(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}    Fetch patternId For DFT Beam again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId For DFT Beam again
       [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL    ${DFT_exp}=DFT
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_exp}.*<LOG.*>.*dMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_exp}.*<LOG.*>.*dMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}

Get Scell physicalCellId
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]     ${pcell_index}    ${scell_index_list}
    ${scell_phyCellId}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    ...                                                                 is_need_to_get_weighted_scell_list=${False}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=${Frist_TDD_index_in_sorted_scell_weight_list}
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_phyCellId}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        Append To List    ${scell_physical_cellid_list}    ${scell_physical_cellid}
    END

Get patternId From BIP Log
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}
    ...    ${phyCellId}=${None}
    ...    ${filter}=dldata_pdschsendreq||dldata_pdcchsendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    Convert Bip Pcap To Pdml    file_path=${file_path}
    ...                    luashark_path=${luashark_path}
    ...                    filter=${filter}
    ${bipPatternId_filter_with_phyCellId}    Catenate    !(DlData_PdschSendReq.grants_item_0.rnti == 65535) &&
    ...                                                  (DlData_PdschSendReq.grants_item_0.numOfPrb>0x0000000f) &&
    ...                                                  DlData_PdschSendReq.grants_item_0.dmrsScramblingSequenceInt == ${phyCellId}
    ${bipPatternId_filter_wo_phyCellId}    Catenate    !(DlData_PdschSendReq.grants_item_0.rnti == 65535) &&
    ...                                                  (DlData_PdschSendReq.grants_item_0.numOfPrb>0x0000000f)
    ${filter_expression}=    Set Variable IF     '${phyCellId}' != '${None}'    ${bipPatternId_filter_with_phyCellId}
    ...                                                                         ${bipPatternId_filter_wo_phyCellId}
    ${bipPatternIdList0}    Get Field Value From Pdml
    ...                                               filter_expression=${filter_expression}
    ...                                               xpath=.//DlData_PdschSendReq.patternId.patternId_item_0
    ${bipPatternIdList1}    Get Field Value From Pdml
    ...                                               filter_expression=${filter_expression}
    ...                                               xpath=.//DlData_PdschSendReq.patternId.patternId_item_1
    ${bipPatternIdList0}    Remove Duplicates    ${bipPatternIdList0}
    ${bipPatternIdList0}    Evaluate    list(map(lambda x: int(x, 16), ${bipPatternIdList0}))
    ${bipPatternIdList_length}    get length     ${bipPatternIdList0}
    Should Be True    ${bipPatternIdList_length} > 0    msg="Get patternId From BIP Log Failed"
    ${bipPatternIdList1}    Remove Duplicates    ${bipPatternIdList1}
    ${bipPatternIdList1}    Evaluate    list(map(lambda x: int(x, 16), ${bipPatternIdList1}))
    ${bipPatternIdList}    Combine Lists    ${bipPatternIdList0}    ${bipPatternIdList1}
    ${bipPatternIdList}    Remove Duplicates    ${bipPatternIdList}
    [Return]    ${bipPatternIdList}

Get BeamId From BIP Log
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}
    ...    ${filter}=dldata_pdschsendreq||dldata_pdcchsendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    Convert Bip Pcap To Pdml    file_path=${file_path}
    ...                    luashark_path=${luashark_path}
    ...                    filter=${filter}
    ${BeamIdList}    Get Field Value From Pdml    filter_expression=!(DlData_PdcchSendReq.dciInfo_item_0.rnti == 65535)
    ...                                               xpath=.//DlData_PdcchSendReq.PdcchSendReq.beamId
    ${BeamIdList}    Remove Duplicates    ${BeamIdList}
    ${BeamIdList}    Evaluate    list(map(lambda x: int(x, 16), ${BeamIdList}))
    [Return]    ${BeamIdList[0]}

Get PatternidList From CPRT and BIP
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${beamSetType}=DFTNORMAL    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${cprtPatternIdList}    Get From Dictionary    ${cprtPatternIdDict}    ${beamSetType}
    ${bipPatternIdList}    Get patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
    [Return]    ${cprtPatternIdList}    ${bipPatternIdList}

Get PatternidList From CPRT and BIP For Pcell
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${beamSetType}=DFTNORMAL
    ${cprtPatternIdList}    Get From Dictionary    ${pcell_cprtPatternIdDict}    ${beamSetType}
    ${pcell_phyCellId}    Set Variable    ${PCELL_MAPPING['physicalCellId']}
    ${bipPatternIdList}    Get patternId From BIP Log    file_path=${file_path}    phyCellId=${pcell_phyCellId}
    [Return]    ${cprtPatternIdList}    ${bipPatternIdList}

Compare PatternidList From CPRT and BIP
    [Arguments]    ${cprtPatternIdList}    ${bipPatternIdList}
    FOR    ${bipPatternId}    IN    @{bipPatternIdList}
        ${compare_status}     run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${bipPatternId} <= ${cprtPatternIdList[1]}
        return from keyword if    ${compare_status}!= ${True}    ${False}
    END
    [Return]    ${compare_status}

DFTBeam Should Be Used In BIP
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=DFTNORMAL    luashark_path=${luashark_path}
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "DFT Beam is not used!"

DFTBeam Should Be Used In BIP For Pcell
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP For Pcell
    ...    file_path=${file_path}    beamSetType=DFTNORMAL
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "DFT Beam is not used!"

PMIBeam Should Be Used In BIP For Scell
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${scell_index_list}    ${beamSetType}=DYNAMIC
    ${scell_physical_cellid_list}    Create List
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_physical_cellid}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        Append To List    ${scell_physical_cellid_list}    ${scell_physical_cellid}
        ${scell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${item}
        ${scellcprtPatternIdList}    Get From Dictionary    ${scell_cprtPatternIdDict}    ${beamSetType}
        ${scellbipPatternIdList}    Get patternId From BIP Log    file_path=${file_path}    phyCellId=${scell_physical_cellid}
        ${compare_status}   Compare PatternidList From CPRT and BIP
        ...    cprtPatternIdList=${scellcprtPatternIdList}    bipPatternIdList=${scellbipPatternIdList}
        Run Keyword And Continue On Failure    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"
    END

PMIBeam Should Be Used
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=DYNAMIC    luashark_path=${luashark_path}
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"

PMIBeam Should Be Used In BIP For Pcell
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP For Pcell
    ...    file_path=${file_path}    beamSetType=DYNAMIC
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"

SSBBeam Should Be Used
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=PREDEFINED
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "SSB Beam is not used!"

Get SRSResourceSet From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${SRSusageList}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSet_element/nr-rrc.usage
    ...            attribute_name=showname
    ...            filter=nr-rrc
    [Return]    ${SRSusageList}

Get rrcReestablishmentRequestCause From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${rrcReestablishmentRequest_causeList}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReestablishmentRequest_element
    ...            xpath=.//nr-rrc.reestablishmentCause
    ...            attribute_name=showname
    [Return]    ${rrcReestablishmentRequest_causeList}

Get nrofSRS_Ports From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${rrc_wpdu}    Set Variable
    ...           (nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList) && (nas-5gs)
    ${rrc_wopdu}    Set Variable
    ...           (nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList) && !(nas-5gs)
    ${filter_expression}    set variable if    '${rrc_with_pdu}' == '${True}'    ${rrc_wpdu}    ${rrc_wopdu}
#    ${filter_expression}    Set Variable
#    ...           ((nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceSetToAddModList)) && (nr-rrc.resourceType == 2)
    ${xpath}    Set Variable    .//nr-rrc.SRS_Resource_element/nr-rrc.nrofSRS_Ports
    ${nrofSRS_PortsList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            file_path=${file_path}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=show
    ${nrofSRS_PortsList}    Remove Duplicates    ${nrofSRS_PortsList}
    [Return]    ${nrofSRS_PortsList}

Get nrofPorts From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${rrc_filter}    Set Variable
    ...           (nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList) && (nr-rrc.nzp_CSI_RS_ResourceToAddModList)
    ${rrc_wpdu}    Set Variable    (nas-5gs)
    ${rrc_wopdu}    Set Variable    !(nas-5gs)
    ${filter_expression}    set variable if    '${rrc_with_pdu}' == '${True}'    ${rrc_wpdu}    ${rrc_wopdu}
#    ${rrc_wpdu}    Set Variable
#    ...           (nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList) && (nr-rrc.nzp_CSI_RS_ResourceToAddModList) && (nas-5gs)
#    ${rrc_wopdu}    Set Variable
#    ...           (nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList) && (nr-rrc.nzp_CSI_RS_ResourceToAddModList) && !(nas-5gs)
    Setup Pcap File    file_path=${file_path}     filter=${rrc_filter}
    ${nrofPortsList}    Get Field Value From PCAP    field_name=nr-rrc.nrofPorts
    ...                                              filter_expression=${filter_expression}
    ...                                              attribute_name=showname
#    ${filter_expression}    set variable if    '${rrc_with_pdu}' == '${True}'    ${rrc_wpdu}    ${rrc_wopdu}
#    ${xpath}    Set Variable    .//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
#    ${nrofPortsList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
#    ...            filter_expression=${filter_expression}
#    ...            xpath=${xpath}
#    ...            attribute_name=showname
    ${nrofPortsList}    Remove Duplicates    ${nrofPortsList}
    [Return]    ${nrofPortsList}

Get srsForBeamMgmt From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${message_filter_expression}    Set Variable
    ...           ((nr-rrc.rrcReconfiguration_element) && (nr-rrc.srs_ResourceToAddModList)) && (nr-rrc.resourceType == 2)
    ${c_SRSList}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_Resource_element/nr-rrc.freqHopping_element/nr-rrc.c_SRS
    ...            attribute_name=show
    ${b_SRSList}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_Resource_element/nr-rrc.freqHopping_element/nr-rrc.b_SRS
    ...            attribute_name=show
    ${periodicityAndOffsetList}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_Resource_element/nr-rrc.resourceType/nr-rrc.periodic_element/nr-rrc.periodicityAndOffset_p
    ...            attribute_name=showname
    ${c_SRSList}    Remove Duplicates    ${c_SRSList}
    ${b_SRSList}    Remove Duplicates    ${b_SRSList}
    ${periodicityAndOffsetList}    Remove Duplicates    ${periodicityAndOffsetList}
    [Return]    ${c_SRSList[0]}    ${b_SRSList[0]}    ${periodicityAndOffsetList[0]}

Check 2 SRS Ports Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        for nr-rrc.nrofSRS_Ports = 1(ports2), it means UL is configured as 2 ports.
    ...        before scell addtion, rrc reconfiguration contains NAS PDU session establishment accept
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${nrofSRS_PortsList}    Get nrofSRS_Ports From CPIF Log    file_path=${file_path}    rrc_with_pdu=${rrc_with_pdu}
    Should Contain    ${nrofSRS_PortsList}   1    msg=nrofSRS_Ports is not 2 in RRC!

Check 1 SRS Port Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        for nr-rrc.nrofSRS_Ports = 0(port2), it means UL is configured as 1 port.
    ...        before scell addtion, rrc reconfiguration contains NAS PDU session establishment accept
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${nrofSRS_PortsList}    Get nrofSRS_Ports From CPIF Log    file_path=${file_path}    rrc_with_pdu=${rrc_with_pdu}
    Should Be Equal    ${nrofSRS_PortsList[0]}   0    msg=nrofSRS_Ports is not 2 in RRC!

Check cell specific CSIRS Used in RRC Message For Pcell
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        for ue specific CSIRS, p4 is uesd; for cell specific CSIRS, nrofPorts: p8
    ...        used for P-SRS, before scell addtion, rrc reconfiguration contains NAS PDU session establishment accept
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${nrofPortsList}    Get nrofPorts From CPIF Log    file_path=${file_path}    rrc_with_pdu=${rrc_with_pdu}
#    Should Contain    ${nrofPortsList[0]}   p8    msg=cell specific CSIRS is not used in RRC!
    Check CSIRS Infor Is Correct    nrofPortsList_infor=${nrofPortsList}    nrofPort_target=p8

Check ue specific CSIRS Used in RRC Message For Pcell
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        for ue specific CSIRS, p4 is uesd; for cell specific CSIRS, nrofPorts: p8
    ...        used for P-SRS, before scell addtion, rrc reconfiguration contains NAS PDU session establishment accept
    [Arguments]    ${file_path}    ${rrc_with_pdu}=${True}
    ${nrofPortsList}    Get nrofPorts From CPIF Log    file_path=${file_path}    rrc_with_pdu=${rrc_with_pdu}
#   Should Contain    ${nrofPortsList[0]}   p4    msg=cell specific CSIRS is not used in RRC!
    Check CSIRS Infor Is Correct    nrofPortsList_infor=${nrofPortsList}    nrofPort_target=p4

Check CSIRS Infor Is Correct
    [Arguments]    ${nrofPortsList_infor}    ${nrofPort_target}
    ${nrofPortsList_infor_length}    Get Length    ${nrofPortsList_infor}
    Should Be True    ${nrofPortsList_infor_length}>0
    FOR    ${nrofPortsList}    IN    @{nrofPortsList_infor}
        ${nrofPort}    Remove Duplicates    ${nrofPortsList}
        Should Contain    ${nrofPort[0]}    ${nrofPort_target}    msg=cell specific CSIRS is not used in RRC!
    END

Get nrofPorts From CPIF Log For Scell
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${phyCellId}=${None}
    ${scell_csirs}    Set Variable
    ...    (nr-rrc.rrcReconfiguration_element) && (nr-rrc.sCellToAddModList) && (nr-rrc.nzp_CSI_RS_ResourceToAddModList)
    ${filter_expression}    Catenate    ${scell_csirs} and (nr-rrc.physCellId == ${phyCellId})
    ${xpath}    Set Variable    .//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ${nrofPortsList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=showname
    ${nrofPortsList}    Remove Duplicates    ${nrofPortsList}
    [Return]    ${nrofPortsList}

Check cell specific CSIRS Used in RRC Message For Scell
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...        for ue specific CSIRS, p4 is uesd; for cell specific CSIRS, nrofPorts: p8
    ...        used for P-SRS, before scell addtion, rrc reconfiguration contains NAS PDU session establishment accept
    [Arguments]    ${file_path}    ${scell_index_list}
    ${scell_physical_cellid_list}    Create List
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_physical_cellid}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        ${nrofPortsList}    Get nrofPorts From CPIF Log For Scell    file_path=${file_path}    phyCellId=${scell_physical_cellid}
        Should Contain    ${nrofPortsList[0]}   p8    msg=cell specific CSIRS is not used in RRC!
    END

Check TAS SRS Is Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  used for 1086 on + 8274 on
    [Arguments]    ${file_path}
    ${SRSusageList}    Get SRSResourceSet From CPIF Log    file_path=${file_path}    srs_ResourceSetToAddModList=2
    Should Contain    ${SRSusageList[0]}    codebook    msg=Codebook SRS resource is not Assigned in RRC Message!
    Should Contain    ${SRSusageList[1]}    antennaSwitching    msg=TAS SRS resource is not Assigned in RRC Message!

Check Periodic SRS Is Not Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...    APeriodic SRS is found in RRC for GOB beam, used for 1086 + 8247 off
    [Arguments]    ${file_path}
    ${SRSusageList}    Get SRSResourceSet From CPIF Log    file_path=${file_path}    srs_ResourceSetToAddModList=1
    Should Be Empty      ${SRSusageList}    msg=Periodic SRS resource is used in RRC Message while 1086+8247 off!

Check rrcReestablishmentRequest Is Not Exist in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...    rrcReestablishmentRequest is not found in CPIF
    [Arguments]    ${file_path}
    ${rrcReestablishmentRequest_causeList}    Get rrcReestablishmentRequestCause From CPIF Log    file_path=${file_path}
    Should Be Empty      ${rrcReestablishmentRequest_causeList}    msg=rrcReestablishmentRequest Exist!

Check srsForBeamMgmt Is Same in SCF And RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${cell_idx}=1
    ${c_SRS}    ${b_SRS}    ${periodicityAndOffset}    Get srsForBeamMgmt From CPIF Log    file_path=${file_path}
    ${bSRS}    ${cSRS}    ${srsUePeriodicity}    Get srsForBeamMgmt From SCF    cell_idx=${cell_idx}
    Should Contain    ${periodicityAndOffset}    ${srsUePeriodicity}    msg=SRS srsUePeriodicity is not the same in gnb and RRC!
    Should Be Equal    ${c_SRS}   ${cSRS}    msg=SRS cSRS is not the same in gnb and RRC!
    Should Be Equal    ${b_SRS}   ${bSRS}    msg=SRS bSRS is not the same in gnb and RRC!

Check TAS SRS and Codebook AP SRS Is Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 used for 1086 off + 8247 on
    [Arguments]    ${file_path}
    ${SRSusageList}    Get SRSResourceSet From CPIF Log    file_path=${file_path}    srs_ResourceSetToAddModList=1
    Should Contain    ${SRSusageList[0]}    antennaSwitching    msg=TAS SRS resource is not Assigned in RRC Message!
    Should Not Contain    ${SRSusageList[0]}    codebook    msg=Codebook SRS resource is not Assigned in RRC Message!

Check CodeBook SRS Is Used in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  used for 1086 + 8247 on, UE incapable of TAS
    [Arguments]    ${file_path}    ${srs_ResourceSet}=1
    ${SRSusageList}    Get SRSResourceSet From CPIF Log    file_path=${file_path}    srs_ResourceSetToAddModList=${srs_ResourceSet}
    Should Contain    ${SRSusageList[0]}    codebook    msg=Codebook SRS resource is not Assigned in RRC Message!
    Should Not Contain    ${SRSusageList[0]}    antennaSwitching    msg=Codebook SRS resource is not Assigned in RRC Message!

Create srsForBeamMgmt parameters
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]     ${cell_idx}=1
    ...              ${bSRS}=none    ${cSRS}=none    ${srsUePeriodicity}=none
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
    ${srs_params}    create dictionary    bSRS=${bSRS}    cSRS=${cSRS}    srsUePeriodicity=${srsUePeriodicity}
    ${srs_params_list}    create list    ${srs_params}
    ${srs_mo}    create dictionary    dist_name=${dist_name}    value=${srs_params_list}
    ...    parameter=srsForBeamMgmt
    ${srs_mo_list}    create list    ${srs_mo}
    [Return]    ${srs_mo_list}

Get srsForBeamMgmt From SCF
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]      ${cell_idx}=1
    ...              ${connection}=GNB_OAM
#    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
#    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${timeout}=600
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${modify_params}    Create srsForBeamMgmt parameters    cell_idx=${cell_idx}
    ${srsForBeamMgmt_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${bSRS}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['bSRS']}
    ${cSRS}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['cSRS']}
    ${srsUePeriodicity}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['srsUePeriodicity']}
    ${srsUePeriodicity}    set variable if    '${srsUePeriodicity}'=='slots40'    sl40    ${srsUePeriodicity}
    ${srsUePeriodicity}    set variable if    '${srsUePeriodicity}'=='slots80'    sl80    ${srsUePeriodicity}
    [Return]    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get cellid on MultiRAT BTS
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...    cell_id_assigned: can be a string, like 1, used to assign cell idex by yourself if more than one nrcells configured
    ...                   Default to None: only one nrcell on GNB, will fetch this cell index from gnb automatically.
    [Arguments]  ${cell_id_assigned}=${None}  ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${bts_info}    coam.get_bts_info    connection=${connection}
    ${cell_num}    Get Length    ${bts_info['cells']['nr']}
    ${cell_idx}    set variable if    ${cell_num} > 1    ${cell_id_assigned}    ${bts_info['cells']['nr'][0]['globalCellId']}
    [Return]    ${cell_idx}

Get cellid on GNB
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...    cell_id_assigned: can be a string, like 1, used to assign cell idex by yourself if more than one nrcells configured
    ...                   Default to None: only one nrcell on GNB, will fetch this cell index from gnb automatically.
    [Arguments]  ${cell_id_assigned}=${None}  ${connection}=GNB_OAM
    ${multiRAT}    Check If MultiRAT BTS    connection=${connection}
    ${cell_idx}    run keyword if    ${multiRAT}    Get cellid on MultiRAT BTS
    ...    cell_id_assigned=${cell_id_assigned}  connection=${connection}
    ...    ELSE     Get cellid on Normal GNB    cell_id_assigned=${cell_id_assigned}  connection=${connection}
    [Return]    ${cell_idx}

Get cellid on Normal GNB
    [Documentation]  Author: lei.jia@nokia-sbell.com
    [Arguments]  ${cell_id_assigned}=${None}  ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${cell_id_list}  Get All Cell Id    connection=${connection}
    ${cell_num}    get length  ${cell_id_list}
    ${cell_idx}    set variable if    ${cell_num} > 1    ${cell_id_assigned}    ${cell_id_list[0]}
    [Return]    ${cell_idx}

Modify Paras via Admin API
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify paramters online via admin CLI.
    [Arguments]      ${parameters_to_update}    ${timeout}=15 min
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    Wait Gnb Ready And Cell On Air    timeout=${timeout}
    Sleep 	90s 	Wait for calibration setup

Modify Paras via SCF
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify paramters online via scf.
    [Arguments]      ${parameters_to_update}    ${is_dynamic_pdcch_update}=${False}
    ...              ${scf_dir_path}=${TS_CASE_LOG_PATH}    ${is_case_level_update_params_exist}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${cur_scf_file}    COAM Download scf from cluster  scf_dir_path=${scf_dir_path}
    Common_setup_and_teardown.Case Common SetUp    update_param_name=${parameters_to_update}
    ...                  is_dynamic_pdcch_update=${is_dynamic_pdcch_update}
    ...                  is_case_level_update_params_exist=${is_case_level_update_params_exist}
    ...                  scf_file_path=${cur_scf_file}
    Sleep 	90s 	Wait for calibration setup

Get codebook ResourceSetId of TAS And Codebook P-SRS in ToAddModList
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 1086 + 8247 on
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${codebook_resourcesetid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.SRS_ResourceSet_element/nr-rrc.srs_ResourceSetId
    [Return]    ${codebook_resourcesetid}

Get tas ResourceSetId of TAS And Codebook P-SRS in ToAddModList
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 1086 + 8247 on
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${tas_resourcesetid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[2]/nr-rrc.SRS_ResourceSet_element/nr-rrc.srs_ResourceSetId
    [Return]    ${tas_resourcesetid}

Get SRSResourceSetId in SRSResourceToAddModList
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 1086 off + 8247 on, only one item in srs_ResourceToAddModList
    ...                 1086 on + 8247 on, 2 item in srs_ResourceToAddModList
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=1
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${tas_resourcesetid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSet_element/nr-rrc.srs_ResourceSetId
    [Return]    ${tas_resourcesetid}

Get SRSResourceSetId in SRSResourceSetToReleaseList
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 1086 off + 8247 on, only one item in srs_ResourceToAddModList
    ...                 1086 on + 8247 on, 2 item in srs_ResourceToAddModList
    [Arguments]    ${file_path}    ${srs_ResourceSetToReleaseList}=1
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.srs_ResourceSetToReleaseList == ${srs_ResourceSetToReleaseList}
    ${tas_resourcesetid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSetId
    [Return]    ${tas_resourcesetid}

Check All SRSResources Are Released in RRC Message
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 1086 off + 8247 on, only one item in srs_ResourceToAddModList
    ...                 1086 on + 8247 on, 2 item in srs_ResourceToAddModList
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=1
    ${tas_resourcesetid_toadd}    Get SRSResourceSetId in SRSResourceToAddModList
    ...    file_path=${file_path}    srs_ResourceSetToAddModList=${srs_ResourceSetToAddModList}
    ${tas_resourcesetid_torelease}    Get SRSResourceSetId in SRSResourceSetToReleaseList
    ...    file_path=${file_path}    srs_ResourceSetToReleaseList=${srs_ResourceSetToAddModList}
    Should Be Equal    ${tas_resourcesetid_toadd}    ${tas_resourcesetid_torelease}
    ...    msg=TAS SRS resource is not released for T+F CA after scell addition!

Get Pcell Tput Type For UL Layer1
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]       ${ul_layer}=layer1
    ${pcell_technology}    Set Variable    ${pcell_mapping['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${pcell_technology}'=='TDD'    chBw    chBwUl
    ${pcell_chbw}    Set Variable    ${pcell_mapping['detail_cells_info']['${chbw_param_name}']}
    ${check_pcell_tput_type_ul_layer1}    Set Variable    ${pcell_chbw}_${ul_layer}
    [Return]    ${check_pcell_tput_type_ul_layer1}

Get Tput Table For FDD DL Layer4
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${scell_index_list}=${None}    ${index_in_scell_list}=0
    ${check_cell_tput_type}    Run Keyword If    ${scell_index_list}    Get Tput Table For FDD Scell DLLayer4
    ...                                          scell_index_list=${scell_index_list}    index_in_scell_list=${index_in_scell_list}
    ...                         ELSE    Get Tput Table For FDD Pcell DLLayer4
    [Return]    ${check_cell_tput_type}

Get Tput Table For FDD Pcell DLLayer4
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]       ${dl_layer}=layer4
    ${pcell_technology}    Set Variable    ${pcell_mapping['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${pcell_technology}'=='TDD'    chBw    chBwDl
    ${pcell_chbw}    Set Variable    ${pcell_mapping['detail_cells_info']['${chbw_param_name}']}
    ${check_pcell_tput_type}    Set Variable    ${pcell_chbw}_${dl_layer}
    [Return]    ${check_pcell_tput_type}

Get Tput Table For FDD Pcell UL
    [Documentation]   Author:lei.jia@nokia-sbell.com
    ...                This is only used for TL278 non-DSS, as its peak is the same as TL072/307 DSS_phase_3
    ${pcell_technology}    Set Variable    ${pcell_mapping['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${pcell_technology}'=='TDD'    chBw    chBwUl
    ${pcell_chbw}    Set Variable    ${pcell_mapping['detail_cells_info']['${chbw_param_name}']}
    ${check_ul_pcell_tput_type}    Set Variable    ${pcell_chbw}_DSS_Phase_3
    [Return]    ${check_ul_pcell_tput_type}

Get Tput Table For FDD Scell DLLayer4
    [Documentation]   Auther:lei.jia@nokia-sbell.com
    [Arguments]       ${dl_layer}=layer4    ${scell_index_list}=${None}    ${index_in_scell_list}=0
    ${scell_index}    set variable     ${scell_index_list[${index_in_scell_list}]}
    ${scell_technology}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['technology']}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
    ${check_scell_tput_type}    Set Variable    ${scell_chbw}_${dl_layer}
    [Return]    ${check_scell_tput_type}


Online Modification weightForSCellSelection value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${cell_index}=2    ${value}=10    ${connection}=GNB_OAM    ${gnb_index}=0
    ${value}    Convert To String    ${value}
    &{params_to_modify_dict}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...                                              parameter=weightForSCellSelection    value=${value}
    ${params_to_modify}    Evaluate    [&{params_to_modify_dict}]
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Get codebook SRSResourceId From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${codebooksourceid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.SRS_ResourceSet_element/nr-rrc.srs_ResourceIdList/_/nr-rrc.SRS_ResourceId
    [Return]    ${codebooksourceid}

Get TAS SRSResourceId From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${TASSRSresourceid}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[2]/nr-rrc.SRS_ResourceSet_element/nr-rrc.srs_ResourceIdList/_/nr-rrc.SRS_ResourceId
    [Return]    ${TASSRSresourceid}

Get TAS SRSResourceSetId in SRS ResourceSetToReleaseList From CPIF Log
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${srs_ResourceSetToReleaseList}=1
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToReleaseList == ${srs_ResourceSetToReleaseList}
    ${TASSRS_releaseResourceSetId}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSetId
    [Return]    ${TASSRS_releaseResourceSetId}

############################################################################################
#####################SG3####################################################################
############################################################################################
Get XpatternId From BIP Log
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}    ${filter_expression}    ${xpath}
    ...    ${filter}=dldata_pdschsendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    Convert Bip Pcap To Pdml    file_path=${file_path}
    ...                    luashark_path=${luashark_path}
    ...                    filter=${filter}
    ${bipPatternIdList}    Get Field Value From Pdml    filter_expression=${filter_expression}    xpath=${xpath}
    ${bipPatternIdList}    Remove Duplicates    ${bipPatternIdList}
    ${bipPatternIdList}    Evaluate    list(map(lambda x: int(x, 16), ${bipPatternIdList}))
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Should Be True    ${bipPatternIdList_length} > 0    msg="Get patternId From BIP Log Failed"
    [Return]    ${bipPatternIdList}

Get PDSCH_patternId From BIP Log
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}
    ...    ${filter}=dldata_pdschsendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${bippdschPatternIdList0}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...    filter_expression=!(DlData_PdschSendReq.grants_item_0.rnti == 65535)
    ...    xpath=.//DlData_PdschSendReq.patternId.patternId_item_0
    ${bippdschPatternIdList1}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...    filter_expression=!(DlData_PdschSendReq.grants_item_0.rnti == 65535)
    ...    xpath=.//DlData_PdschSendReq.patternId.patternId_item_1
    ${bippdschPatternIdList}    Combine Lists    ${bippdschPatternIdList0}    ${bippdschPatternIdList1}
    ${bippdschPatternIdList}    Remove Duplicates    ${bippdschPatternIdList}
    run keyword if     '${bippdschPatternIdList1[0]}'=='0' or '${bippdschPatternIdList1[0]}'=='65535'
    ...     Return From Keyword      ${bippdschPatternIdList0}
    [Return]    ${bippdschPatternIdList}

Get CSIRS_patternId From BIP Log
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}    ${csirs_config}=0x04
    ...    ${filter}=dldata_csirssendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${csirsPatternIdList0}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...    filter_expression=DlData_CsiRsSendReq.csiRsResources_item_0.csiRsConfig == ${csirs_config}
    ...    xpath=.//dldata_csirssendreq/dldata_csirssendreq[1]/dldata_csirssendreq[2]/DlData_CsiRsSendReq.patternId.patternId_item_0
    ${csirsPatternIdList1}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...    filter_expression=DlData_CsiRsSendReq.csiRsResources_item_0.csiRsConfig == ${csirs_config}
    ...    xpath=.//dldata_csirssendreq/dldata_csirssendreq[1]/dldata_csirssendreq[2]/DlData_CsiRsSendReq.patternId.patternId_item_2
    ${csirsPatternIdList}    Combine Lists    ${csirsPatternIdList0}    ${csirsPatternIdList1}
    ${csirsPatternIdList}    Remove Duplicates    ${csirsPatternIdList}
    run keyword if     '${csirsPatternIdList1[0]}'=='0'     ${csirsPatternIdList}     ${csirsPatternIdList0}
    [Return]    ${csirsPatternIdList}

Get PDCCH_patternId From BIP Log
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}
    ...    ${filter}=dldata_pdcchsendreq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${pdcchPatternIdList}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...      filter_expression=!(DlData_PdcchSendReq.dciInfo_item_0.rnti == 65535)
    ...      xpath=.//DlData_PdcchSendReq.patternId.patternId_item_0
    [Return]    ${pdcchPatternIdList}

Get PUSCH_patternId From BIP Log
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter uldata_puschreceivereq
    [Arguments]    ${file_path}
    ...    ${filter}=uldata_puschreceivereq
    ...    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${puschPatternIdList}    Get XpatternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}    filter=${filter}
    ...      filter_expression=uldata_puschreceivereq
    ...      xpath=.//UlData_PuschReceiveReq.patternId.patternId_item_0
    [Return]    ${puschPatternIdList}


Check PDCCH PUSCH and CSIRS used DFT beam
    [Arguments]    ${file_path}    ${luashark_path}=/home/ute/luashark/luashark.lua    ${csirs_config}=0x04
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=DFTNORMAL     luashark_path=${luashark_path}
#    ${PDCCHpatternidlist}    Get PDCCH_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
    ${CSIRSpatternidlist}    Get CSIRS_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
    ...    csirs_config=${csirs_config}
    ${PUSCHpatternidlist}    Get PUSCH_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
#    ${PDCCH_compare_status}    run keyword and return status    should be true
#        ...    ${cprtPatternIdList[0]} <= ${PDCCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
    ${PUSCH_compare_status}    run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${PUSCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
    ${CSIRS_compare_status}    run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${CSIRSpatternidlist[0]} <= ${cprtPatternIdList[1]}
#    Run Keyword If   ${PDCCH_compare_status}!= ${True}    FAIL    "PDCCH DFT Beam is not used!"
    Run Keyword If   ${PUSCH_compare_status}!= ${True}    FAIL    "PUSCH DFT Beam is not used!"
    Run Keyword If   ${CSIRS_compare_status}!= ${True}    FAIL    "CSIRS DFT Beam is not used!"

Check PDCCH PUSCH used DFT beam
    [Arguments]    ${file_path}    ${luashark_path}=/home/ute/luashark/luashark.lua
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=DFTNORMAL     luashark_path=${luashark_path}
#    ${PDCCHpatternidlist}    Get PDCCH_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
    ${PUSCHpatternidlist}    Get PUSCH_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
#    ${PDCCH_compare_status}    run keyword and return status    should be true
#        ...    ${cprtPatternIdList[0]} <= ${PDCCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
    ${PUSCH_compare_status}    run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${PUSCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
#    Run Keyword If   ${PDCCH_compare_status}!= ${True}    FAIL    "PDCCH DFT Beam is not used!"
    Run Keyword If   ${PUSCH_compare_status}!= ${True}    FAIL    "PUSCH DFT Beam is not used!"

Check CSIRS used PMI beam when CELL specific used
    [Arguments]    ${file_path}    ${luashark_path}=/home/ute/luashark/luashark.lua    ${csirs_config}=0x08
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP
    ...    file_path=${file_path}    beamSetType=DYNAMIC     luashark_path=${luashark_path}
    ${CSIRSpatternidlist}    Get CSIRS_patternId From BIP Log    file_path=${file_path}    luashark_path=${luashark_path}
    ...    csirs_config=${csirs_config}
    ${CSIRS_compare_status}    run keyword and return status    should be true
    ...    ${cprtPatternIdList[0]} <= ${CSIRSpatternidlist[0]} <= ${cprtPatternIdList[1]}
    Run Keyword If   ${CSIRS_compare_status}!= ${True}    FAIL    "CSIRS PMI Beam is not used!"

Get Aperiodic SRS From CPIF Log
    [Documentation]
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 0
    ${SRSusageList_0}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSet_element/nr-rrc.usage
    ...            attribute_name=showname
    ${SRSusageList_1}=    String.Split String    ${SRSusageList_0[0]}    :${SPACE}
    ${SRSusageList}=    String.Split String    ${SRSusageList_1[1]}    ${SPACE}(
    [Return]    ${SRSusageList}

Get CSI-RS nrofRBs from RRC Message
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${nrofPorts}=2    ${csirs_filter}=nr-rrc.rrcSetup_element
    ${message_filter_expression}     Catenate     ${csirs_filter} &&
    ...                                           nr-rrc.nrofPorts == ${nrofPorts}
    ${CSIRS_nrofRBs}    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${file_path}
    ...    filter=nr-rrc
    ...    filter_expression=${message_filter_expression}
    ...    xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.freqBand_element/nr-rrc.nrofRBs
    ...    attribute_name=show
    ${CSIRS_nrofRBs}    Remove Duplicates    ${CSIRS_nrofRBs}
    [Return]    ${CSIRS_nrofRBs}

Get CSIRS nrofPorts from RRC Message
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_nrofPorts_0}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...            attribute_name=showname
    ${num}     get length    ${CSIRS_nrofPorts_0}
    ${CSIRS_nrofPorts}=    Create List
    FOR    ${i}    IN RANGE    ${num}
       ${CSIRS_nrofPorts_1}=    String.Split String    ${CSIRS_nrofPorts_0[${i}]}    :${SPACE}
       ${CSIRS_nrofPorts_2}=    String.Split String    ${CSIRS_nrofPorts_1[1]}    ${SPACE}(
       Append To List    ${CSIRS_nrofPorts}    ${CSIRS_nrofPorts_2[0]}
    END
    [Return]    ${CSIRS_nrofPorts}

Get CSI-RS frequencyDomainAllocation
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${message_filter_expression}     Catenate     nr-rrc.rrcSetup_element &&
    ...                                           nr-rrc.csi_MeasConfig == 1
    ${CSIRS_freqDomain}    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${file_path}
    ...    filter=nr-rrc
    ...    filter_expression=${message_filter_expression}
    ...    xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.frequencyDomainAllocation/nr-rrc.row4
    ...    attribute_name=show
    ${CSIRS_freqDomain}    Remove Duplicates    ${CSIRS_freqDomain}
    [Return]    ${CSIRS_freqDomain}

Get CELL Spcific CSI-RS frequencyDomainAllocation
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${num}
    ${message_filter_expression}     Catenate     nr-rrc.rrcReconfiguration_element &&
    ...                                           nr-rrc.csi_MeasConfig == 1
    ${CSIRS_freqDomain}    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${file_path}
    ...    filter=nr-rrc
    ...    filter_expression=${message_filter_expression}
    ...    xpath=.//_[${num}]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.frequencyDomainAllocation/nr-rrc.other
    ...    attribute_name=show
    ${CSIRS_freqDomain}    Remove Duplicates    ${CSIRS_freqDomain}
    [Return]    ${CSIRS_freqDomain}

Get CSI-RS TimeDomainAllocation
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${message_filter_expression}     Catenate     nr-rrc.rrcSetup_element &&
    ...                                           nr-rrc.csi_MeasConfig == 1
    ${CSIRS_timeDomain}    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${file_path}
    ...    filter=nr-rrc
    ...    filter_expression=${message_filter_expression}
    ...    xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.firstOFDMSymbolInTimeDomain
    ...    attribute_name=show
    ${CSIRS_timeDomain}    Remove Duplicates    ${CSIRS_timeDomain}
    [Return]    ${CSIRS_timeDomain}

Get CELL Specific CSI-RS TimeDomainAllocation
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${num}
    ${message_filter_expression}     Catenate     nr-rrc.rrcReconfiguration_element &&
    ...                                           nr-rrc.csi_MeasConfig == 1
    ${CSIRS_timeDomain}    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${file_path}
    ...    filter=nr-rrc
    ...    filter_expression=${message_filter_expression}
    ...    xpath=.//_[${num}]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.firstOFDMSymbolInTimeDomain
    ...    attribute_name=show
    ${CSIRS_timeDomain}    Remove Duplicates    ${CSIRS_timeDomain}
    [Return]    ${CSIRS_timeDomain}

Check SRSresource reuse in RRC Message
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2    ${resource_reues_status}=${True}
    ${TASSRSresourceid}    Get TAS SRSResourceId From CPIF Log    file_path=${file_path}
    ...    srs_ResourceSetToAddModList=${srs_ResourceSetToAddModList}
    ${codebooksourceid}    Get codebook SRSResourceId From CPIF Log    file_path=${file_path}
    ...    srs_ResourceSetToAddModList=${srs_ResourceSetToAddModList}
    ${reusestatus}=    Run Keyword And Return Status    Should be Equal    ${TASSRSresourceid[0]}    ${codebooksourceid[0]}
    Should Be Equal    ${reusestatus}    ${resource_reues_status}

Get p0NominalSrs from cpif log
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${p0}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSet_element/nr-rrc.p0
    ...            attribute_name=show
    [Return]    ${p0[1]}


Create p0NominalSrs parameters
    [Arguments]     ${cell_idx}=1
    ...              ${p0NominalSrs}=none
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
    ${p0NominalSrs_params}    create dictionary    p0NominalSrs=${p0NominalSrs}
    ${p0NominalSrs_params_list}    create list    ${p0NominalSrs_params}
    ${p0_mo}    create dictionary    dist_name=${dist_name}    value=${p0NominalSrs_params_list}
    ...    parameter=ulPowerControlCommon
    ${p0_mo_list}    create list    ${p0_mo}
    [Return]    ${p0_mo_list}

Get p0NominalSrs From SCF
    [Arguments]      ${cell_idx}=1
    ...              ${connection}=GNB_OAM
#    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
#    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${timeout}=600
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${modify_params}    Create p0NominalSrs parameters    cell_idx=${cell_idx}
    ${ulPowerControlCommon_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${p0NominalSrs}    Set Variable    ${ulPowerControlCommon_values[0]['value'][0]['p0NominalSrs']}
    [Return]    ${p0NominalSrs}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Check p0 Is Same in SCF And RRC Message
    [Arguments]    ${file_path}    ${cell_idx}=1
    ${p0_rrc}     Get p0NominalSrs from cpif log     file_path=${file_path}
    ${p0_scf}     Get p0NominalSrs From SCF     cell_idx=${cell_idx}
    Should Be Equal     ${p0_rrc}    ${p0_scf}     msg=p0NominalSrs is not modify success


Check p0NominalSrs has changed
    [Arguments]    ${file_path_old}    ${file_path_new}
    ${p0_old}    Get p0NominalSrs from cpif log    file_path=${file_path_old}
    ${p0_new}    Get p0NominalSrs from cpif log    file_path=${file_path_new}
    Should not Be Equal     ${p0_old}    ${p0_new}

Check CSIRS UE specific Used
    [Arguments]     ${file_path}    ${nrofports}=p4
    ${CSIRS_nrofPorts}    Get CSIRS nrofPorts from RRC Message    file_path=${file_path}
    Should Be Equal    ${CSIRS_nrofPorts[0]}    ${nrofports}

Check CSIRS CELL specific Used
    [Arguments]     ${file_path}    ${nrofports}=p8
    ${CSIRS_nrofPorts}    Get CSIRS nrofPorts from RRC Message    file_path=${file_path}
    Should Be Equal    ${CSIRS_nrofPorts[0]}    ${nrofports}

##-----mcshark-----##
Get patternId From BIP Log with mcshark
    [Documentation]    Author: jia-rebecca.liu@nokia-sbell.com
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}
    ...    ${phyCellId}=${None}
    ...    ${filter}=dldata_pdschsendreql1sw    ${PCI_filter}=3gpp.dmrsScramblingSequenceInt    ${rnti}=${None}
    ...    ${xpath_name}=DlData_PdschGrantL1sw
    ${bipPatternId_filter_with_phyCellId}    Catenate    3gpp.rnti != 65535 &&
    ...                                                  3gpp.rnti != 65534 &&
    ...                                                  (${PCI_filter} == ${phyCellId})
    ${bipPatternId_filter_wo_phyCellId}    Catenate      3gpp.rnti != 65535 &&
    ...                                                  3gpp.rnti != 65534
    ${bipPatternId_filter_with_phyCellId_and_rnti}    Catenate      (3gpp.rnti == ${rnti} && 3gpp.rnti != 65535 &&
    ...                                                  3gpp.rnti != 65534) &&
    ...                                                  (${PCI_filter} == ${phyCellId})
    ${filter_expression}=    Set Variable IF
    ...    '${phyCellId}' != '${None}' and '${rnti}'=='${None}'    ${bipPatternId_filter_with_phyCellId}
    ...    '${phyCellId}' != '${None}' and '${rnti}'!='${None}'    ${bipPatternId_filter_with_phyCellId_and_rnti}
    ...    ${bipPatternId_filter_wo_phyCellId}
    ${bipPatternIdList0}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...                                               filter_expression=${filter_expression}
    ...                                               xpath=.//_[3]/${xpath_name}.patternId_item[1]
    ${bipPatternIdList1}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...                                               filter_expression=${filter_expression}
    ...                                               xpath=.//_[3]/${xpath_name}.patternId_item[2]
    ${bipPatternIdList0}    Remove Duplicates    ${bipPatternIdList0}
    ${bipPatternIdList_length}    get length     ${bipPatternIdList0}
#    Should Be True    ${bipPatternIdList_length} > 0    msg="Get patternId From BIP Log Failed"
    ${bipPatternIdList1}    Remove Duplicates    ${bipPatternIdList1}
    ${bipPatternIdList}    Combine Lists    ${bipPatternIdList0}    ${bipPatternIdList1}
    ${bipPatternIdList}    Remove Duplicates    ${bipPatternIdList}
    [Return]    ${bipPatternIdList}

Get XpatternId From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}    ${filter_expression}    ${xpath}    ${filter}
#    cap.load_pcap_file    pcap_file=${file_path}        alias=${alias}
#    ${bipPatternIdList}    Get Field Value From Pdml    filter_expression=${filter_expression}    xpath=${xpath}
    ${bipPatternIdList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            filter_expression=${filter_expression}   xpath=${xpath}     filter=${filter}
    ${bipPatternIdList}    Remove Duplicates    ${bipPatternIdList}
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
#    Should Be True    ${bipPatternIdList_length} > 0    msg="Get patternId From BIP Log Failed"
    [Return]    ${bipPatternIdList}

Get Item Value From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}    ${filter_expression}    ${xpath}    ${filter}
    ${bipList}    Check Target Item Value on CPIF Tcpdump    file_path=${file_path}
    ...            filter_expression=${filter_expression}   xpath=${xpath}     filter=${filter}
    ${bipList}    Remove Duplicates    ${bipList}
    ${bipList_length}    get length     ${bipList}
#    Should Be True    ${bipList_length} > 0    msg="Get Item From BIP Log Failed"
    [Return]    ${bipList}

Get PDSCH_patternId From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}    ${filter}=dldata_pdschsendreq
    ${filter_illegal_value}    Catenate    3gpp.rnti != 65535 &&
    ...                                    3gpp.rnti != 65534
    ${bippdschPatternIdList0}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${filter_illegal_value}
    ...    xpath=.//_[3]/DlData_PdschGrant.patternId_item[1]
    ${bippdschPatternIdList1}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${filter_illegal_value}
    ...    xpath=.//_[3]/DlData_PdschGrant.patternId_item[2]
    ${bippdschPatternIdList}    Combine Lists    ${bippdschPatternIdList0}    ${bippdschPatternIdList1}
    ${bippdschPatternIdList}    Remove Duplicates    ${bippdschPatternIdList}
    run keyword if     '${bippdschPatternIdList1[0]}'=='0' or '${bippdschPatternIdList1[0]}'=='65535'
    ...     Return From Keyword      ${bippdschPatternIdList0}
    [Return]    ${bippdschPatternIdList}

Get PUSCH_patternId From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter uldata_puschreceivereq
    [Arguments]    ${file_path}    ${filter}=uldata_puschreceivereql1ru
    ...       ${xpath}=.//UlData_puschReceiveReqGrantL1ru_t.patternId_item
    ${puschPatternIdList}    Get Item Value From BIP Log with mcshark     file_path=${file_path}    filter=${filter}
    ...      filter_expression=!(3gpp.rnti == 65521)
    ...      xpath=${xpath}
    [Return]    ${puschPatternIdList}

Get CSIRS_patternId From BIP Log with mcshark
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}    ${csirs_config}=04     ${filter}=dldata_csirssendreq
    ${csirsPatternIdList0}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=DlData_CsiRsResource_t.csiRsConfig == ${csirs_config}
    ...    xpath=.//_[2]/DlData_CsiRsResource_t.patternId_item[1]
    ${csirsPatternIdList1}    Get XpatternId From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=DlData_CsiRsResource_t.csiRsConfig == ${csirs_config}
    ...    xpath=.//_[2]/DlData_CsiRsResource_t.patternId_item[3]
    ${csirsPatternIdList}    Combine Lists    ${csirsPatternIdList0}    ${csirsPatternIdList1}
    ${csirsPatternIdList}    Remove Duplicates    ${csirsPatternIdList}
    run keyword if     '${csirsPatternIdList1[0]}'=='0'     ${csirsPatternIdList}     ${csirsPatternIdList0}
    [Return]    ${csirsPatternIdList}

Get PatternidList From CPRT and BIP with mcshark
    [Documentation]   Author: jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${beamSetType}=DFTNORMAL    ${cprtPatternIdDict}=${cprtPatternIdDict}    ${phyCellId}=${None}
    ...    ${rnti}=${None}    ${filter}=dldata_pdschsendreql1sw    ${PCI_filter}=3gpp.dmrsScramblingSequenceInt    ${xpath}=DlData_PdschGrantL1sw

    ${cprtPatternIdList}    Get From Dictionary    ${cprtPatternIdDict}    ${beamSetType}
    ${bipPatternIdList}    Get patternId From BIP Log with mcshark    file_path=${file_path}    phyCellId=${phyCellId}
    ...    rnti=${rnti}    filter=${filter}   PCI_filter=${PCI_filter}    xpath_name=${xpath}
    [Return]    ${cprtPatternIdList}    ${bipPatternIdList}

DFTBeam Should Be Used In BIP with mcshark
    [Documentation]   Author: jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${cprtPatternIdDict}=${cprtPatternIdDict}    ${phyCellId}=${None}
    ...            ${filter}=dldata_pdschsendreql1sw    ${pdsch_xpath}=DlData_PdschGrantL1sw
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DFTNORMAL    cprtPatternIdDict=${cprtPatternIdDict}    phyCellId=${phyCellId}
    ...    filter=${filter}    xpath=${pdsch_xpath}
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Return From Keyword If    ${bipPatternIdList_length} == 0
    ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
    Return From Keyword If    '${cprtPatternIdList_length}'=='0'
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "DFT Beam is not used!"

SSBBeam Should Be Used with mcshark
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=PREDEFINED
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Return From Keyword If    ${bipPatternIdList_length} == 0
    ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
    Return From Keyword If    '${cprtPatternIdList_length}'=='0'
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "SSB Beam is not used!"

Check PUSCH and CSIRS used DFT beam with mcshark
    [Arguments]    ${file_path}    ${csirs_config}=4
    ...       ${pusch_xpath}=.//UlData_puschReceiveReqGrantL1ru_t.patternId_item
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DFTNORMAL
    ${CSIRSpatternidlist}    Get CSIRS_patternId From BIP Log with mcshark    file_path=${file_path}    csirs_config=${csirs_config}
    ${PUSCHpatternidlist}    Get PUSCH_patternId From BIP Log with mcshark    file_path=${file_path}     xpath=${pusch_xpath}
    ${PUSCH_compare_status}    run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${PUSCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
    ${CSIRS_compare_status}    run keyword and return status    should be true
        ...    ${cprtPatternIdList[0]} <= ${CSIRSpatternidlist[0]} <= ${cprtPatternIdList[1]}
    Run Keyword If   ${PUSCH_compare_status}!= ${True}    FAIL    "PUSCH DFT Beam is not used!"
    Run Keyword If   ${CSIRS_compare_status}!= ${True}    FAIL    "CSIRS DFT Beam is not used!"

Check CSIRS used PMI beam when CELL specific used with mcshark
    [Arguments]    ${file_path}    ${csirs_config}=8
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DYNAMIC
    ${CSIRSpatternidlist}    Get CSIRS_patternId From BIP Log with mcshark    file_path=${file_path}
    ...    csirs_config=${csirs_config}
    ${CSIRS_compare_status}    run keyword and return status    should be true
    ...    ${cprtPatternIdList[0]} <= ${CSIRSpatternidlist[0]} <= ${cprtPatternIdList[1]}
    Run Keyword If   ${CSIRS_compare_status}!= ${True}    FAIL    "CSIRS PMI Beam is not used!"

PMIBeam Should Be Used with mcshark
    [Documentation]   Author: jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${filter}=dldata_pdschsendreq    ${pdsch_xpath}=DlData_PdschGrant
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DYNAMIC
    ...    filter=${filter}    xpath=${pdsch_xpath}
    ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
    Return From Keyword If    '${cprtPatternIdList_length}'=='0'
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"

Check PUSCH used DFT beam with mcshark
    [Arguments]    ${file_path}    ${filter}=uldata_puschreceivereql1ru
    ...     ${pusch_xpath}=.//UlData_puschReceiveReqGrantL1ru_t.patternId_item
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DFTNORMAL
    ${PUSCHpatternidlist}    Get PUSCH_patternId From BIP Log with mcshark    file_path=${file_path}
    ...                            filter=${filter}      xpath=${pusch_xpath}
    ${PUSCH_compare_status}    run keyword and return status    should be true
    ...    ${cprtPatternIdList[0]} <= ${PUSCHpatternidlist[0]} <= ${cprtPatternIdList[1]}
    Run Keyword If   ${PUSCH_compare_status}!= ${True}    FAIL    "PUSCH DFT Beam is not used!"

Get BeamId From BIP Log with mcshark
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${file_path}
    ...    ${filter}=dldata_pdcchsendreq
    ${BeamIdList}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=!(3gpp.rnti == 65535)
    ...    xpath=.//DlData_PdcchSendReq_t.beamId
    [Return]    ${BeamIdList[0]}

Get PatternidList From CPRT and BIP For Pcell with mcshark
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${beamSetType}=DFTNORMAL
    ${filter}    Set Variable If    'SBTS00' in '${stream}'    dldata_pdschsendreql1sw    dldata_pdschsendreq
    ${xpath_name}     Set Variable If    'SBTS00' in '${stream}'    DlData_PdschGrantL1sw    DlData_PdschGrant
    ${cprtPatternIdList}    Get From Dictionary    ${pcell_cprtPatternIdDict}    ${beamSetType}
    ${pcell_phyCellId}    Set Variable    ${PCELL_MAPPING['physicalCellId']}
    ${bipPatternIdList}    Get patternId From BIP Log with mcshark    file_path=${file_path}    phyCellId=${pcell_phyCellId}
    ...                                                               filter=${filter}    xpath_name=${xpath_name}
    [Return]    ${cprtPatternIdList}    ${bipPatternIdList}

DFTBeam Should Be Used In BIP For Pcell with mcshark
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP For Pcell with mcshark
    ...    file_path=${file_path}    beamSetType=DFTNORMAL
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Return From Keyword If    ${bipPatternIdList_length} == 0
    ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
    Return From Keyword If    '${cprtPatternIdList_length}'=='0'
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "DFT Beam is not used!"

PMIBeam Should Be Used In BIP For Pcell with mcshark
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP For Pcell with mcshark
    ...    file_path=${file_path}    beamSetType=DYNAMIC
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Return From Keyword If    ${bipPatternIdList_length} == 0
    ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
    Return From Keyword If    '${cprtPatternIdList_length}'=='0'
    ${compare_status}    Compare PatternidList From CPRT and BIP
    ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"

PMIBeam Should Be Used In BIP For Scell with mcshark
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${scell_index_list}    ${beamSetType}=DYNAMIC
    ${scell_physical_cellid_list}    Create List
    ${filter}    Set Variable If    'SBTS00' in '${stream}'    dldata_pdschsendreql1sw    dldata_pdschsendreq
    ${xpath_name}     Set Variable If    'SBTS00' in '${stream}'    DlData_PdschGrantL1sw    DlData_PdschGrant
    FOR  ${item}  IN   @{scell_index_list}
        ${scell_physical_cellid}     Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_physical_cellid}    convert to string     ${scell_physical_cellid}
        Append To List    ${scell_physical_cellid_list}    ${scell_physical_cellid}
        ${scell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${item}
        ${scellcprtPatternIdList}    Get From Dictionary    ${scell_cprtPatternIdDict}    ${beamSetType}
        ${scellbipPatternIdList}    Get patternId From BIP Log with mcshark    file_path=${file_path}    phyCellId=${scell_physical_cellid}
        ...                                                                    filter=${filter}    xpath_name=${xpath_name}
        ${bipPatternIdList_length}    get length     ${scellbipPatternIdList}
        Return From Keyword If    ${bipPatternIdList_length} == 0
        ${scellcprtPatternIdList_length}    get length    ${scellcprtPatternIdList}
        Return From Keyword If    '${scellcprtPatternIdList_length}'=='0'
        ${compare_status}   Compare PatternidList From CPRT and BIP
        ...    cprtPatternIdList=${scellcprtPatternIdList}    bipPatternIdList=${scellbipPatternIdList}
        Run Keyword And Continue On Failure    Run Keyword If   ${compare_status}!= ${True}    FAIL    "PMI Beam is not used!"
    END

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_pre}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename_pre}   Set Variable    7_5${TLNAME_pre}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename_pre}
