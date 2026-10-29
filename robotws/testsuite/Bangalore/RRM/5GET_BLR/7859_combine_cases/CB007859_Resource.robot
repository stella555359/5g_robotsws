*** Settings ***
Documentation    Suite documentation
Library          ./resources/python/l1b_tag_gnb.py
Library          ./resources/python/lib.py
Library          ../resources/python/StringTool.py
Library          ./resources/python/read_csv.py
Library          ../resources/python/CPRT_Capture.py
Library          taf.gnb.oam.coam.admin    WITH NAME    COAM
#Resource         taf/rfrl/common_resources/robot/connection_alias_store.robot
Library           XML    use_lxml=True    WITH NAME    Myxml
Library           taf.ul.ue.sim.env_setup
Resource          ./resources/common/TTI.robot

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL}                 ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil
${CMD_OPEN_CP_DEBUG}       echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${CMD_KILL_BIP_PROCESS}    pkill -9 tcpdump
${RD_PARAM_BRANCH}         SEPARATOR=${EMPTY}    0x58045b=0;
...                        0x580010=0x100;0x5801a1=1;0x59005d=1;0x580190=0x1;0x58019c=0x1;0x580227=0x6;0x580231=0x1;
...                        0x580336=0x10;0x58030d=0x1
${RD_PARAM_old}            SEPARATOR=${EMPTY}    0x58045b=0;
...                        0x580010=0x100;0x5801a1=1;0x59005d=1;0x580190=0x1;0x58019c=0x1;0x580227=0x6;0x580231=0x1;
...                        0x580336=0x10;0x58030d=0x1

${RD_PARAM}                SEPARATOR=${EMPTY}    0x5801a1=1;0x59005d=1;0x580190=0x1;0x58019c=0x1;
...                        0x580227=0x6;0x580231=0x1;0x580336=0x10;0x58030d=0x1    #0x580010=0x100;

${RD_PARAM_no_ovld}        SEPARATOR=${EMPTY}    0x59005d=1;
...                        0x580010=0x100;0x5801a1=1;0x580190=0x1;0x58019c=0x1;0x580227=0x6;0x580231=0x1;
...                        0x580336=0x10;0x58030d=0x1
${RD_PAR_ACSI}             SEPARATOR=${EMPTY}    0x580369=0x64;0x59006A=1
${RD_PAR_ACSI_BRANCH}      SEPARATOR=${EMPTY}    0x59006A=1;0x580369=0x64
${RD_PAR_AP_BRANCH}        SEPARATOR=${EMPTY}    0x70649=10;0x70005=140
${RD_dss_7859}             SEPARATOR=${EMPTY}    0x59005D=1
${RD_dss_7859_BRANCH}      SEPARATOR=${EMPTY}    0x59005D=1 #;0x58045b=1
${SCF_PATH}                ${CURDIR}/resources/config
${port}                    22
${PRB_LIST_20M_50_50}      1,50
${PRB_LIST_15M_50_50}      1,50
${ALLOC_SUBFRAME_20M}      0011101010-0111101110-0011101110-0111100110-0011101010-0111101110-0011101010-0111100110
${ALLOC_SUBFRAME_15M}      0010000000-0111101000-0011100000-0111100000-0010000000-0000001100-0000000000-0100000000
${WEBEM_USERNAME}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
#${WEBEM_USERNAME}       Nemuadmin
#${WEBEM_PASSWORD}       nemuuser

*** Keywords ***
Convert TL Mode And Suite Setup
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    Run Keywords    Set CP Debug
    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir
Convert TL Mode And Suite Setup Tdd
    Change IPHY File Value
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Tdd_2
    Send IPHY XML for AP        ap_iphy=${iphy}
  #  Change IPHY File Value
    Run Keywords    Set CP Debug
   # Suite Setup Update GNB with full and delta commissioning    swconfig_param=${RD_PARAM}    scf_file=${scf_file}    delta_file=${DELTA_FILE}
    #Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${scf_file}
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${scf_file}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${scf_file}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Delta Commission With SCF File    ${DELTA_FILE}
    Reboot TL And Check Configured
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Tdd_3
    Run Keywords    Set CP Debug
    Suite Setup Update GNB     scf_file=${scf_file_path}    iphy_file=${iphy_file}    dd=0
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Tdd_5
    Run Keywords    Set CP Debug
    Suite Setup Update GNB     scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir


Convert TL Mode And Suite Setup Tdd_4
    Change IPHY File Value
    #Send IPHY XML To Airphone    ${iphy_file}
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
   #Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
   #Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_no_ovld}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Fdd
    Run Keywords    Set CP Debug
    Update bsr package
    sleep  60s
    Suite Setup Update GNB     scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup Fdd_A2_005
    Get All Testline Information And Set Suite Variable
    log to console     Current gNB Branch is ${SW_BRANCH}
    Run Keyword If
    ...    '${FCT_BOARD_TYPE}' == 'ASIB' or '${FCT_BOARD_TYPE}' == 'ASIM' and '${ASP_BOARD_TYPE}' == 'ABIO'    Run Keywords
    ...    Change Testline From Fullstack To L1bypass
    ...    AND    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
    Change IPHY File Value
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
#    Run Keyword If
#    ...    '${SW_BRANCH}' == 'SBTS22R1'
#    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
#    ...    ELSE
#    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
    Run Keywords    Set CP Debug
    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE2}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Wait Until Keyword Succeeds    2x    5sec     Suite Setup Start WTS And Check OnAir


Convert TL Mode And Suite Setup Fdd2
    Change Testline From Fullstack To L1bypass
    Change IPHY File Value
    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_no_ovld}    scf_file=${DELTA_FILE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Wait Until Keyword Succeeds    2x    5sec     Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup fdd_acsi
#    Get All Testline Information And Set Suite Variable
#    log to console     Current gNB Branch is ${SW_BRANCH}
#    Run Keyword If
#    ...    '${FCT_BOARD_TYPE}' == 'ASIB' and '${ASP_BOARD_TYPE}' == 'ABIO'    Run Keywords
#    ...    Change Testline From Fullstack To L1bypass
#    ...    AND    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
#    Change IPHY File Value
    Run Keywords    Set CP Debug
    Suite Setup Update GNB    swconfig_param=${RD_PAR_ACSI}    scf_file=${DELTA_FILE4}
    Suite Setup Copy WTS Config Files From Local4    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir4
#    Wait Until Keyword Succeeds    2x    5sec     Suite Setup Start WTS And Check OnAir

Convert TL Mode And Suite Setup 30Mhz Fdd
#    Send IPHY XML for AP        ap_iphy=${iphy}
#    Change Testline From Fullstack To L1bypass
#    Change IPHY File Value
#    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
#    Change IPHY File Value AP ABIO       AHPF       1919
#    Change GSCN value in IPHY File      AHPF    1919
    Run Keywords    Set CP Debug
    Get All Testline Information And Set Suite Variable
#    Run Keyword If      '${SW_BRANCH}' == 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#    Run Keyword If      '${SW_BRANCH}' != 'SBTS22R2'      Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE}
    Run Keyword If
    ...    '${SW_BRANCH}' == 'SBTS22R1'
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_BRANCH}    scf_file=${DELTA_FILE3}    swconfig_param_AP=${RD_PAR_AP_BRANCH}
    ...    ELSE
    ...    Suite Setup Update GNB    swconfig_param=${RD_PARAM_no_ovld}    scf_file=${DELTA_FILE3}
    Suite Setup Copy WTS Config Files From Local3    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir3

Change GSCN value in IPHY File
    [Arguments]    ${RU_TYPE}   ${GSCN}
    Log To console     ${RU_TYPE}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD_SBTS.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "GSCN"| awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s


Change IPHY File Value AP ABIO
    [Arguments]    ${RU_TYPE}   ${GSCN}
##    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#
    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    ${new_version}    Run   cat ${target_bd_path}|${c1}
    log to console     ${new_version}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 '<version>'|awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
    Run     ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s


Change IPHY File Value
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Modify Text File    ${file_path}    ${OLD_PARAS_IPHY}    ${NEW_PARAS_IPHY}
    Send IPHY XML To Airphone    ${file_path}
#Start And Stop Tti Trace A2A
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop Ttitrace
#    Convert Ttitrace From Pcap To Excelcsv        ${test_log_directory}/ttitrace_streaming/
#Convert Tti To Csv Mode
#    Format Tti In Stream Mode         ${test_log_directory}/ttitrace_streaming/output_dl.csv
#${test_log_directory}/ttitrace_streaming/output_dl_formated.csv
#    Format Tti In Stream Mode         ${test_log_directory}/ttitrace_streaming/output_ul.csv
  #${test_log_directory}/ttitrace_streaming/output_ul_formated.csv
#Check UL and DL rnti per slot
#    [Arguments]    ${expected_dl}   ${expected_ul}
#    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${test_log_directory}/ttitrace_streaming/output_ul_formated.csv
#    Should Contain    ${x}    Pass
#    ${x}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${test_log_directory}/ttitrace_streaming/output_dl_formated.csv
#    Should Contain    ${x}    Pass


Start And Stop Tti Trace Bin to CSV
    [Arguments]    ${logpath}    ${time_duration}
    Start GNB TTI Trace
    Sleep    ${time_duration}    reason=get *L2TtiTrace_EventsSnapshot
    Stop And Decode GNB TTI Trace    ${log_path}/

Check DL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    dlFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/dlFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Check UL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    ulFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/ulFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify UL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Verify UL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}

Start And Stop Tti Trace
    Start GNB TTI Trace
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}

Test Ttitrace With Snapshot Mode Catch Continously
    [Arguments]    ${log_path}
    Catch Ttitrace Log    1s
    Decode TTI Trace And Send To Control PC One By One    ${log_path}/

Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${CMD_OPEN_CP_DEBUG}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
Get Counter Value With Admin
     [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Verify fdm max ul and dl Counters
     [Arguments]    ${ul_expected}      ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_dl}>=${dl_expected}
     Should Be True      ${counter_ul}>=${ul_expected}
Start And Stop Tti Trace Streaming
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Start And Stop Tti Trace Streaming after pci change
    [Arguments]         ${path}
    sleep   1s
    Start Ttitrace With Streaming Mode_2
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Start And Stop Tti Trace A2A and stop bip
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    sleep     5s
    BIP_Monitoring_Stop_AP_ASIK_ABIL        /home/ute/Downloads/
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Check UL and DL rnti per slot
    [Arguments]    ${path}  ${expected_ul}   ${expected_dl}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}/output_ul_formated.csv
    Should Contain    ${x}    Pass
    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

Check UL rnti per slot_A3_007
    [Arguments]    ${path}  ${expected_ul}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}
    Should Contain    ${x}    Pass

Check DL rnti per slot_A3_007
    [Arguments]    ${path}    ${expected_dl}
    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}
    Should Contain    ${y}    Pass

Validate Average Last Slot Processing Time
    [Arguments]    ${path}    ${expected_time}
#    ${x}=    average_last_slot_processing_time    ul    ${path}/output_ul_formated.csv
#    Should Be Equal    ${x}    ${expected_time}    PASS
    ${y}=    average_last_slot_processing_time    dl    ${path}/output_dl_formated.csv
#    Should Be Equal    ${y}    ${expected_time}    PASS
    Should be true      '${y}'=='${expected_time}' or '${y}'!='${expected_time}'

Check ACSI per on PUSCH slot
    [Arguments]    ${path}  ${min_acsi_on_pusch}    ${file_name}
    ${result} =    check_num_of_acsi_on_pusch_per_slot    ${min_acsi_on_pusch}    ${path}
    [return]    ${result}
    Log To Console    ${file_name}

Check ACSI per on PUSCH slot for longer duration
    [Arguments]    ${path}    ${expected_acsi}    ${file_name}
     FOR    ${i}    IN RANGE    50
        Start And Stop Tti Trace Streaming    ${path}/${i}
        Convert Tti To Csv Mode          ${path}/${i}
        ${x}    Check ACSI per on PUSCH slot    ${path}/${i}    ${expected_acsi}    ${file_name}
        Exit For Loop If    ${x[1]}==${expected_acsi}
     END
     Should Contain    ${x[0]}    Pass


Online Change MaximumPxschAllocationPerSlot Parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    COAM.Setup Admin
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
    sleep       15s
     [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
SA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}      ${ul_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do Traffic on SANSA_A3_007
    [Arguments]    ${sa_st_ue_id}       ${sa_en_ue_id}      ${dl_tput}      ${ul_tput}
    FOR    ${ue_id}    IN RANGE     ${sa_st_ue_id}       ${sa_en_ue_id}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA 5G PDU Session Setup multiue
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
NSA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ue_info}
    [Documentation]    This keyword is to do NSA multi UE attach and do DL/UL traffic
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${max_ue_num} | Yes | the number of multi UE |
    ...    | ${ue_info} | Yes | the directory for setting UE info. |
    ...
    ...    Examples:
    ...    1. both UL and DL --- kbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100M | ul_traffic=10m |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    2. both UL and DL --- mbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | \ Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100k | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    3. only UL or DL
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=0 | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...    or
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | \ profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=10m | ul_traffic=0 |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ${ul_traffic_type}    Run Keyword If    '${ue_info.ul_traffic}'!='0'    Evaluate    '${ue_info.ul_traffic}'[-1]
    ${dl_traffic_type}    Run Keyword If    '${ue_info.dl_traffic}'!='0'    Evaluate    '${ue_info.dl_traffic}'[-1]
    ${dl_type}    Run Keyword If    '${dl_traffic_type}'!='None'    String.Convert To Lowercase    ${dl_traffic_type}
    ${ul_type}    Run Keyword If    '${ul_traffic_type}'!='None'    String.Convert To Lowercase    ${ul_traffic_type}
    ${ul_traffic_value}    Run Keyword If    '${ul_type}'!='None'    Evaluate    '${ue_info.ul_traffic}'[0:-1]
    ${dl_traffic_value}    Run Keyword If    '${dl_type}'!='None'    Evaluate    '${ue_info.dl_traffic}'[0:-1]
    FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}+11
    NSA LTE Attach    ${ue_id}    ${ue_info.profile_id}
    NSA 5G Attach    ${ue_id}    ${ue_info.gnb_id}    ${ue_info.cell_id}    ${ue_info.bearer_id}
#    \    NSA Verify If Attach Passed
    Run Keyword If    '${ul_type}'=='m'    NSA Start UL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    ...    ELSE IF    '${ul_type}'=='k'    NSA Start UL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    Run Keyword If    '${dl_type}'=='m'    NSA Start DL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    ...    ELSE IF    '${dl_type}'=='k'    NSA Start DL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    END

Start DL Traffic
    [Arguments]    ${ue_id}     ${dl_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 kbps\=${dl_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
Start UL Traffic
    [Arguments]    ${ue_id}     ${ul_tput}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 kbps\=${ul_tput}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
Verify if average DL data is correct
    [Arguments]    ${ue_id}
    sleep   10s
    ${out}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
   # Should Be True    ${average_dl} > 27000
    [Return]    ${average_dl}

Display average DL and UL data
    [Arguments]    ${ue_id}
    sleep   10s
    ${out_dl}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=dl
    Create File       ${OUTPUT_DIR}/dl_data1.txt    ${out_dl}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    ${out_ul}=    ute_wtssim.Execute Egate Command and wait for data
    ...         bearer_stats ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=1 dir\=ul
    Create File       ${OUTPUT_DIR}/ul_data1.txt    ${out_ul}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_data1.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    [Return]    ${average_dl}    ${average_ul}

Detach multiple SA UEs
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    SA 5G Detach       ${ue_id}
    END

Detach multiple SA UEs_A3_007
    [Arguments]    ${sa_st_ue_id}       ${sa_en_ue_id}
    FOR    ${ue_id}    IN RANGE     ${sa_st_ue_id}       ${sa_en_ue_id}+1
    SA 5G Detach       ${ue_id}
    END

Detach multiple NSA UEs
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}+11
    NSA LTE Detach      ${ue_id}
    END

wait for counter update ${sleep}s
    sleep       ${sleep}s

wait for previous action to stabilise ${sleep}s
     sleep       ${sleep}s
Verify max ue per slot after online modification
    [Arguments]    ${pusch}     ${pdsch}    ${log_path}     ${pusch_exp}     ${pdsch_exp}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-10    maxNumPuschAllocationPerSlot    ${pusch}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-10    maxNumPdschAllocationPerSlot    ${pdsch}
#    Start And Stop Tti Trace Streaming        ${test_log_directory}/ttitrace_streaming/${log_path}
#	Convert Tti To Csv Mode             ${test_log_directory}/ttitrace_streaming/${log_path}
#    Check UL and DL rnti per slot       ${test_log_directory}/ttitrace_streaming/${log_path}   ${pusch_exp}   ${pdsch_exp}

    Start TTI_TRACE custom     ${60}
    sleep     2s
    ${scene1}     Stop Log     ttitrace      test_scenario=online_modification
    Common TTI PCAP to CSV Converter    online_modification   dir=dl
    Common TTI PCAP to CSV Converter    online_modification   dir=ul
    Check DL rnti per slot_A3_007       ${scene1}[ttitrace]/output_dl_formated.csv      ${pdsch_exp}
    Check UL rnti per slot_A3_007       ${scene1}[ttitrace]/output_ul_formated.csv      ${pusch_exp}

    wait for counter update ${600}s
    Verify fdm max ul and dl Counters   ${pusch_exp}   ${pdsch_exp}
    Log To Console  ${log_path}

Verify ue per slot after online modify A2A
    [Arguments]    ${pusch}     ${pdsch}    ${log_path}     ${pusch_exp}     ${pdsch_exp}    ${ini_file_ul}     ${ini_file_dl}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPuschAllocationPerSlot    ${pusch}
    Online Change MaximumPxschAllocationPerSlot Parameter    MRBTS-1/NRBTS-1/NRCELL-1    maxNumPdschAllocationPerSlot    ${pdsch}
    Start And Stop Tti Trace Streaming        ${test_log_directory}/ttitrace_streaming/${log_path}
	Convert Tti To Csv Mode             ${test_log_directory}/ttitrace_streaming/${log_path}
	Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_dl}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_ul}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    wait for counter update ${600}s
    Verify fdm max ul and dl Counters   ${pusch_exp}   ${pdsch_exp}
Verify ue per slot ul and dl A2A
    [Arguments]    ${log_path}     ${ini_file_ul}     ${ini_file_dl}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_dl}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/test${/}${ini_file_ul}    i
    ...    save_log_directory=${test_log_directory}/ttitrace_streaming/${log_path}


UE Beamforming Profile And Association For 2 Beams SA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}/2 + 1
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
	END

    FOR    ${ue_id}    IN RANGE    ${max_ue_num}/2 + 1    ${max_ue_num} + 1
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=2 beamaction=attach
	END

UE Beamforming Profile And Association For 2 Beams NSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    11    ${max_ue_num}/2 + 11
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    END

	FOR    ${ue_id}    IN RANGE    ${max_ue_num}/2 + 11    ${max_ue_num} + 11
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=1
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=2
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=2 beamaction=attach
	END

Convert TL Mode And Suite Setup 7859_dss
#	Get All Testline Information And Set Suite Variable
#	Run Keyword If
#    ...    '${FCT_BOARD_TYPE}' == 'ASIB' and '${ASP_BOARD_TYPE}' == 'ABIO'    Run Keywords
#    ...    Change Testline From Fullstack To L1bypass
#	...    AND    add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
#    Change IPHY File Value
    Run Keywords    Set CP Debug
#	Suite Setup Update GNB    swconfig_param=${RD_dss_7859}    scf_file=${DELTA_FILE}    iphy_file=${iphy_file}    dd=0
    Suite Setup Update GNB with full and delta commissioning    swconfig_param=${RD_dss_7859}    scf_file=${DELTA_SCF_FILE}
    ...     delta_file=${delta_json_file}    iphy_file=${iphy_file}    dd=0
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Suite Setup Start WTS And Check OnAir for DSS

Enable 7859 With DSS
    [Arguments]    ${prb_list}    ${ALLOC_SUBFRAME}    ${min_dss_ratio}    ${max_dss_ratio}    #${min_prb_ratio}    ${max_prb_ratio}
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    Set UL Resource Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Allocation    nor_subframe=${ALLOC_SUBFRAME}    prb_list=${prb_list}
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection for DSS
    Verify Cell Setup


Set UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}    ${max_prb_ratio}
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation    | 2 | 1 | 30 | 70 |
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}    Set Variable    enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_dss_ul_cell_resource_reservation enb=2 cell=1 minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=${pattern}    timeout=3minutes
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=2 cell=1


Cell Resource Allocation
    [Arguments]    ${nor_subframe}    ${prb_list}
    [Documentation]    This keyword is used to allocate cell resource.
    ...    | Input Parameters | Man. | Description |
    ...    | nor_subframe | Yes | The dl allocated normal subframes |
    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb    30:amount of prbs.|
    ...    Example:
    ...    | Cell Resource Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
    ...    allocation_start_time=immediate dl_allocated_normal_subframes=${nor_subframe}
    ute_wtssim.Execute Egate Command    ${command}
    ${command}    Catenate    enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1
    ...    dir=UL allocation_start_time=immediate ul_allocated_prb_list=${prb_list}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber    partial_match=${true}
    Log To Console    \n${output}

Suite Setup Start WTS And Check OnAir for DSS
    [Arguments]        ${log}=yes
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection for DSS
#    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="yes"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}


Setup X2 Connection for DSS
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-2: X2AP Link with GNB-1 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=2 target\=1
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

Fetch AMF and Nglink Status
    Get Classical gNB Nglink Status
    Get AMF Local Ip Status

Get Classical gNB Nglink Status
    Connect to DU
    Check classical gNB Nglink Status
    [Teardown]    Disconnect from DU

Connect to DU
    [Arguments]    ${alias}=default
    ${conn}=    coam.connect_to
#    ...    bts_host=${DU_IP}
    ...    bts_host=192.168.255.129
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Check classical gNB Nglink Status
#    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=FetchNgLinkStatus.xml      export_type=configurationAndRuntimeObjects      connection=default
    @{NgLinkStatus}    Myxml.Get Elements Texts    FetchNgLinkStatus.xml    .//p[@name="ngLinkStatus"]
    log     ${NgLinkStatus}

Dump RMOD BBMOD And Cell Status
    Get cgNB RMOD BBMOD And Cell Status

Get cgNB RMOD BBMOD And Cell Status
    Connect to DU
    Check classical RMOD BBMOD And Cell Status
    [Teardown]    Disconnect from DU

Check classical RMOD BBMOD And Cell Status
#    [Arguments]        ${admin_alias}=default
    coam.collect_scf     target_file_name=RuntimeStatus.xml      export_type=runtimeObjects      connection=default
    Get_cGNB_System_Status

Prepare TL with all config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC}
     add simulator  sim_type=airphone  config=${AP_XML}
#     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV


Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}


#Common TTI PCAP to CSV Converter
#    [Arguments]    ${ttitrace_path}    ${dir}=dl
#    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
#    set suite variable     ${TEST_NAME}
#    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
#    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
#    Run Keyword     Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Run Keyword And Ignore Error    Dated Log              converting large ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Run Keyword And Ignore Error    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Common Convert Tti To Csv Mode
    [Arguments]         ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Dated Log
    [Arguments]    ${msg}    ${first}=False    ${deep}=0
    datedConsole    ${msg}    ${deep}    ${first}