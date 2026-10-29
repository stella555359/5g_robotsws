*** Settings ***
Documentation
...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               swconfig_param=${RD}       AND    Suite Setup Copy WTS Config Files From Local
#...               local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
Resource          ./../5GC001817/keywords_1817_common_AP.robot
Library           ./../CB008236/Resources/CB008236_resource.py

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${FULL_SCF}          CB008927_18_ET_scfc.xml
${IPHY_FILE}         ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
${ET23_SCF}          SCF_ET23.xml
${ET23_IPHY}         ${WTS_LOCAL}/ET23_iphy.xml
${ET23_WTS_CFG}      basic_setup_ET23.cfg
${WTS_LOCAL}         ${CURDIR}/Resources/wts
${WTS_CFG}           CB008927_18_ET_AP.cfg
${RD}                0x580839=1;0x580345=1;0x58090b=1
${ttiPath1}          ttitrace1
${ttiPath2}          ttitrace2
${ttitraceFilter}    generate_ttitrace_profile_CB008927.txt
${filter15}          dldata_pdschsendreql1sw||dldata_pdcchsendreql1sw
@{column_name15}     3gpp.sfn    3gpp.slot    3gpp.rnti    3gpp.subcellid
                     ...    DlData_DciInfoL1sw.startSymbolNumber   DlData_DciInfoL1sw.dciSize
                     ...    DlData_PdschGrantL1sw.startSymbol    DlData_PdschGrantL1sw.numOfPdschSymbols
                     ...   DlData_PdschGrantL1sw.startPrb    DlData_PdschGrantL1sw.numOfPrb
${bip_csv}           bip_gnb.csv
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927_23_TDD_RAT1_with_multiple_BWP_based_on_large_240PRB_and_power_saving_bwp
    [Setup]    Prepare TL w gNB_xml '${ET23_SCF}' AP_xml '${ET23_IPHY}' AP_cfg'${ET23_WTS_CFG}'
    Set egate rrc log 'on'
    UE '1'-'13' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'13' PDU ID '1' TRF ID '1' QFI ID '1' with '5'mbps
    Start ul Trafficon on UE '1'-'5' PDU ID '1' TRF ID '1' QFI ID '1' with '1'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '1'mbps on UE '1' of PDU ID '1'
    UE '14'-'15' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Get Egate log and check enter PowerSaving BWP
    Capture Ttitrace for duration '1s' to log dir '${ttiPath1}'
    Verify ttitrace bler should not high than '0.1' in path '${ttiPath1}'
    Start ul Trafficon on UE '14'-'15' PDU ID '1' TRF ID '1' QFI ID '1' with '100'mbps
    Start dl Trafficon on UE '14'-'15' PDU ID '1' TRF ID '1' QFI ID '1' with '100'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '50'mbps on UE '14' of PDU ID '1'
    ${bip}    Capture BIP for'1s' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter15}' and'${column_name15}'
    ${tti}    Capture Ttitrace for duration '1s' to log dir '${ttiPath2}'
    Verify ttitrace bler should not high than '0.1' in path '${ttiPath2}'
    Verify Multi BWP
    Get Egate log and check exit PowerSaving BWP

*** Keywords ***
Verify Multi BWP
    Check Log With Au2anlysis    ${CURDIR}${/}Config${/}CB008927_multi_BWP_trunk.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY}/BIP_GNB/

Get Egate log and check enter PowerSaving BWP
    Log To Console    start to check 'PowerSaving BWP' in egate log
    ${PowerSaving_BWP}=    Set Variable    Bwp switch received from bwpId 1 to 2
    ute_wtssim.Execute Egate Command    sim_log_set flush
    Save Egate Log    /opt/iphy/latest/
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    ${PowerSaving_BWP}    1

Get Egate log and check exit PowerSaving BWP
    Log To Console    start to check 'PowerSaving BWP' in egate log
    ${PowerSaving_BWP}=    Set Variable    Bwp switch received from bwpId 2 to 1
    ute_wtssim.Execute Egate Command    sim_log_set flush
    Save Egate Log    /opt/iphy/latest/
    ${egate_console_file}=    Set Variable    /opt/iphy/latest/egate_console.log
    Check Egate Log With Message     ${egate_console_file}    ${PowerSaving_BWP}    1