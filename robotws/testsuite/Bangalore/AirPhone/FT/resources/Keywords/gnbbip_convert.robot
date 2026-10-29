*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Sharanya Arvind Bhadrapur
                 ...              :contact      : sharanya.arvind_bhadrapur@nokia.com
                 ...              :Description  : This file contains general common keywords
                 ...                              Any changes review needed before commit

Library           Process
Library           String
Library           BuiltIn
Library           OperatingSystem
Library    ute_wtssim
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
Variables      ../PythonLib/UTILS.py
Library     CSV_validation_and_check1.py
#Resource     ../../L3CALL/resources/Variables/L3_variables.robot

*** Variables ***
${GNB_SW_VERSION}               SBTS00_ENB_9999_250226_000004
${SW_VERSION_TOTAL}             ${EMPTY}    # 0.800.829,SBTS00_ENB_9999_250226_000004
@{COLUMN_NAME}      UlData_puschReceiveReqGrant_t.modulationOrder      UlData_puschReceiveReqGrant_t.mcs
${path_SCN_1}                      /home/ute/logs/L3_Call/gNB/biptaf/TestCase_gnbbip
${SSH_COMMAND}               sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129
${TARGET_PATH}               /ffs/run/TargetBD_*.xml
${BASE_URL}                  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/
${PLUGIN_DIR}                /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan
${header_to_repo}    'X-JFrog-Art-Api: AKCp8oiHU5YVmxybvkJef917wNemeaeHb5LMqX8272B2AU1dcGx4fHim1ifQ8JVJcZR6kZYMj'
*** Keywords ***
Collect BIP and decode
    [Arguments]    ${test_scenario}      ${column_name}=${COLUMN_NAME}
    Log to console      ${SW_VERSION_TOTAL}
    Log to console      ${test_scenario}
    Log to console      ${column_name}
    ${SW_VERSION_TOTAL}  Set Variable      ${GNB_SW_VERSION}
    Set Suite Variable    ${SW_VERSION_TOTAL}
#    Start BIP capture taf
#    sleep    120s
#    Stop BIP capture taf     test_scenario=${test_scenario}

Start BIP capture taf
     [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]    ${gNB_common_unit}=ASIL    ${bb_mods}=[ABIO]    ${l1_type}=FS    ${dir}=L1L2_BIP_Logs
    bip_collection.Configure Bip Collection     l1_type=${l1_type}
    ...                                         gNB_common_unit=${gNB_common_unit}
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    ...                                         script_parameters=--bb_slot_1='false' --bb_slot_5='true'
    bip_collection.Start Bip Trace
    Log to console      ${dir}
    Log to console    BIP logs collecting started

Stop BIP capture taf
     [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${dir}=L1L2_BIP_Logs     ${test_scenario}=TestCase_gnbbip
    ${common_log_path}      Create Dictionary
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${log_dir_gnb}           Set Variable          ${Log_Path}/${TEST_NAME}/gNB/biptaf/${test_scenario}
    Set suite Variable       ${log_dir_gnb}
    ${log_dir}    Set Variable    ${log_dir_gnb}
    Create directory  path=${log_dir}
    Create directory  path=/tmp/${dir}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${dir}
    ${rc}=    Run And Return Rc  mergecap /tmp/${dir}/*.pcap* -w /tmp/${dir}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${dir}/tcpdump.pcap    ${log_dir}/BIP_L1L2.pcap
    Remove directory    /tmp/${dir}    recursive=True
    Log to console  BIP logs collecting finished

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

#    #${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-4.2-1.31.0-SBTS00_ENB_9999_250226_000004+bookworm.so
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-4.2-1.31.0-SBTS00_ENB_9999_250226_000004+bookworm
#    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Extract Version And Download mcshark Plugin
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}"
    ...    -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Extract Version And Download mcshark Plugin
    [Documentation]    SSH to remote, extract TargetBD XML version, build SO name, and download from Artifactory
    ${result}=    Run Process    ${SSH_COMMAND} ls ${TARGET_PATH}    shell=True    stdout=PIPE    stderr=PIPE
    ${output}=    Set Variable    ${result.stdout}
    Log    Raw SSH Output:\n${output}
    ${lines}=    Split String    ${output}    \n
    ${target_line}=    Set Variable    ${EMPTY}
    FOR    ${line}    IN    @{lines}
        IF    ${line.startswith("/ffs/run/TargetBD_")}
            ${target_line}=    Set Variable    ${line}
            Exit For Loop
        END
    END
    Log    Full XML Path: ${target_line}
    ${filename_with_xml}=    Replace String    ${target_line}    /ffs/run/TargetBD_    ${EMPTY}
    Log    Filename With XML: ${filename_with_xml}
    ${version_raw}=    Replace String    ${filename_with_xml}    .xml    ${EMPTY}
    Log    Version Raw: ${version_raw}
    ${gNB_final_version_detected}=    Replace String    ${version_raw}    SBTS25R3    SBTS00
    Log    Final gNB Version: ${gNB_final_version_detected}
    ${final_so_name}=    Set Variable    mcshark-4.2-1.32.0-${gNB_final_version_detected}+bookworm.so
    Log    Final SO File Name: ${final_so_name}
    ${URL_MC_shark_download}=    Set Variable    ${BASE_URL}${gNB_final_version_detected}/${final_so_name}
    Log    Download URL: ${URL_MC_shark_download}
    OperatingSystem.Run     sudo wget --header=${header_to_repo} -P ${PLUGIN_DIR} ${URL_MC_shark_download}
#    OperatingSystem.Run     sudo wget -r -l0 --no-parent -P ${PLUGIN_DIR} ${URL_MC_shark_download}
#    ${download_cmd}=    Set Variable    sudo wget -r -l0 --no-parent ${URL_MC_shark_download}
#    Run Keyword And Ignore Error    OperatingSystem.Run    ${download_cmd}    cwd=${PLUGIN_DIR}

