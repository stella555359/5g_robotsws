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
Resource         ../../../resources/Keywords/gnbbip_convert.robot

*** Variables ***
${GNB_SW_VERSION}                 SBTS00_ENB_9999_250618_000008
${SW_VERSION_TOTAL}             ${EMPTY}    # 0.800.829,SBTS00_ENB_9999_250618_000008
#@{COLUMN_NAME}      UlData_puschReceiveReqGrant_t.modulationOrder      UlData_puschReceiveReqGrant_t.mcs
@{COLUMN_NAME}                UlData_detectedPrachPreambles_t.initialTa     UlData_detectedPrachPreambles_t.initialUlEcidTAdv
@{COLUMN_NAME1}               UlData_detectedPrachPreambles_t.initialTa
@{COLUMN_NAME2}               UlData_detectedPrachPreambles_t.initialUlEcidTAdv
@{COLUMN_NR_TADA}             UlData_detectedPrachPreambles_t.initialUlEcidTAdv
${PLUGIN_DIR_CB013507}         /home/ute/wireshark/plugins/4.2/epan
${MATCH_PREFIX_CB013507}         mcshark-4.
${CB013507_BIP_SCN_TC01}                               /home/ute/logs/CB013507_TC01_Call/gNB/biptaf/TestCase_gnbbip
${CB013507_BIP_SCN_TC02}                               /home/ute/logs/CB013507_TC02_Call/gNB/biptaf/TestCase_gnbbip
${CB013507_BIP_SCN_TC03}                                /home/ute/logs/CB013507_TC03_Call/gNB/biptaf/TestCase_gnbbip
${CB013507_BIP_SCN_TC04}                               /home/ute/logs/CB013507_TC04_FR2/gNB/biptaf/TestCase_gnbbip
${CB013507_BIP_SCN_TC05}                               /home/ute/logs/CB013507_TC05_FR2/gNB/biptaf/TestCase_gnbbip
${CB013507_BIP_SCN_TC06}                               /home/ute/logs/CB013507_TC06_Call/gNB/biptaf/TestCase_gnbbip
${CB013507_BEFORE_DELAY}                      /home/ute/logs/CB013507_TC02_Call/gNB/biptaf/TestCase_gnbbip
${CB013507_AFTER_DELAY}                      /home/ute/logs/CB013507_TC02_Call/gNB/biptaf/TestCase_gnbbip

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

#    #${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
    Manage Mcshark Plugin Files
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}" -T fields
    ...        -e UlData_detectedPrachPreambles_t.initialUlEcidTAdv -e UlData_detectedPrachPreambles_t.initialTa -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Convert BIP To CSV By MCShark with CB013507 delay single TADV
    [Arguments]    ${bip_file}    ${output_file}     ${filter}      ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

#    #${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
    Manage Mcshark Plugin Files
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}" -T fields
    ...        -e UlData_detectedPrachPreambles_t.initialUlEcidTAdv  -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!


Convert BIP To CSV By MCShark CB013507 Check1
    [Arguments]    ${bip_file}    ${output_file}     ${filter}      ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
#    #${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
    Manage Mcshark Plugin Files
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}" -T fields
    ...        -e UlData_detectedPrachPreambles_t.initialUlEcidTAdv -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Convert BIP To CSV By MCShark CB013507 Check2
    [Arguments]    ${bip_file}    ${output_file}     ${filter}      ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

#    #${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
#    ${mcshark_file}    Run    find /home/ute/ -name mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-4.2-1.32.0-SBTS00_ENB_9999_250618_000008+bookworm.so
    Manage Mcshark Plugin Files
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${csv_title}=    Set Variable       ${BIP_CSV_NAME}
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y "${filter}" -T fields
    ...        -e UlData_detectedPrachPreambles_t.initialTa -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Manage Mcshark Plugin Files
    ${all_files}=    Run Keyword And Ignore Error    List Files In Directory    ${PLUGIN_DIR_CB013507}
    ${mcshark_files}=    Evaluate    [f for f in ${all_files} if f.startswith("${MATCH_PREFIX_CB013507}")]    modules=os
    ${mcshark_count}=    Get Length    ${mcshark_files}
    Run Keyword If    ${mcshark_count} > 0    Delete Mcshark Files    ${mcshark_files}
    Extract Version And Download mcshark Plugin

*** Keywords ***
Delete Mcshark Files
    [Arguments]    ${files}
    FOR    ${file}    IN    @{files}
        ${full_path}=    Join Path    ${PLUGIN_DIR_CB013507}    ${file}
        Log    Deleting: ${full_path}
        Remove File    ${full_path}
    END

