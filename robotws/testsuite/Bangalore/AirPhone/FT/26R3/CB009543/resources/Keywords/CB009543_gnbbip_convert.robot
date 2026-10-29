*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Sharanya Arvind Bhadrapur
                 ...              :contact      : sharanya.arvind_bhadrapur@nokia.com
                 ...              :Description  : This file contains general common keywords
                 ...                              Any changes review needed before commit


Library           OperatingSystem
Library           BuiltIn
Library    ute_wtssim
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
Resource          ../../../../resources/Keywords/gnbbip_convert.robot

*** Variables ***
${GNB_SW_VERSION}                 SBTS00_ENB_9999_260108_000005
${SW_VERSION_TOTAL}             ${EMPTY}    # 0.800.829,SBTS00_ENB_9999_260108_000005


@{COLUMN_NAME1}                  3gpp.subcellid == 1
@{COLUMN_NAME2}                  3gpp.subcellid == 2
@{COLUMN_NAME3}                  3gpp.subcellid == 3
@{COLUMN_NAME4}                  3gpp.subcellid == 0
@{COLUMN_NAME5}                  3gpp.subcellid


${PLUGIN_DIR_CB009543}         /home/ute/wireshark/plugins/4.4/epan
${MATCH_PREFIX_CB009543}         mcshark-4.
${CB009543_BIP_SCN_TC01}                                /home/ute/logs/CB009543_TC01_SUBCELL_ATTACH_ALL_CELL/gNB/biptaf/TestCase_gnbbip


*** Keywords ***

Convert BIP To CSV By MCShark with column
    [Arguments]    ${bip_file}    ${output_file}     ${filter}      ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

    Manage Mcshark Plugin Files
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}" -T fields
    ...        -e 3gpp.subcellid  -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!


Manage Mcshark Plugin Files
    ${all_files}=    Run Keyword And Ignore Error    List Files In Directory    ${PLUGIN_DIR_CB009543}
    ${mcshark_files}=    Evaluate    [f for f in ${all_files} if f.startswith("${MATCH_PREFIX_CB009543}")]    modules=os
    ${mcshark_count}=    Get Length    ${mcshark_files}
    Run Keyword If    ${mcshark_count} > 0    Delete Mcshark Files    ${mcshark_files}
    Extract Version And Download mcshark Plugin

*** Keywords ***
Delete Mcshark Files
    [Arguments]    ${files}
    FOR    ${file}    IN    @{files}
        ${full_path}=    Join Path    ${PLUGIN_DIR_CB009543}    ${file}
        Log    Deleting: ${full_path}
        Remove File    ${full_path}
    END

