*** Settings ***
Documentation    This File contains all Keywords specific for use in CB010386 Features only.
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         XML
Library         Collections
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DeltaConfigDir}          ${CURDIR}/../../config/scf/
${IphyConfigDir}           ${CURDIR}/../../config/ap_iphy/
${UE_ID_NSA}               101
${TOPOLOGY}                CLOUD_5G_I_LO_AP_LO
${Filter_D1}               nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_NR_FR1 && nr-rrc.p_Max
${DRX_setup}               nr-rrc.drx_Config == 1 and not nr-rrc.p_Max == 23
${scellModlistfilter}      nr-rrc.sCellToAddModList == 1 and not nr-rrc.p_Max == 23
${gapFR1_filter}           nr-rrc.mgrp == 2
${DRX_config}              nr-rrc.drx_Config == 0
${B2_HO_Pattern}           Handover from NR to EUTRA completed
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare for test Case - CB0010386_A_10
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_A_10
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_10_delta.json
    ...                                         iphy=${IphyConfigDir}/iphy_new.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               new_N90-100mhz.cfg
    Basic Bring up
    # Basic Bring up gnb          new_N90-100mhz.cfg
    [Return]                    ${Log_Path}

Prepare for test Case - CB0010386_D_1
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_D_1
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_N1_N78_Delta_Changes.json
    ...                                         iphy=${IphyConfigDir}/iphy_N1_N78.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               CB010386_N1N78_CFG_wts.cfg
    Basic Bring up
    Set Test Variable                    ${Log_Path}

Prepare for test Case - CB0010386_D_28
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_D_28
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_D_28_N25_N41_Delta_Changes.json
    ...                                         iphy=${IphyConfigDir}/N25_N41_iphy.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               CB010386_D28_N25_N41.cfg
    Basic Bring up
    Set Test Variable           ${Log_Path}

Prepare for test Case - CB0010386_D_20
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_D_20
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_D_20_N5_N77_Delta_Changes.json
    ...                                         iphy=${IphyConfigDir}/N5_N77_iphy.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               CB010386_D20_N5_N77.cfg
    Basic Bring up
    Set Test Variable           ${Log_Path}

Prepare for test Case - CB0010386_D_48
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_D_48
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_D_48_N66_N77_Delta_Changes.json
    ...                                         iphy=${IphyConfigDir}/N66_N77_iphy.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               CB010386_D48_N66_N77.cfg
    Basic Bring up
    Set Test Variable           ${Log_Path}

Prepare for test Case - CB0010386_E1
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB0010386_E1
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    Commission scf and iphy for 10386           scf=${DeltaConfigDir}/CB010386_E1_delta_changes.json
    ...                                         iphy=${IphyConfigDir}/E1_iphy.xml
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Start UTE WTS               CB010386_E1.cfg
    Basic Bring up
    Set Test Variable           ${Log_Path}

Commission scf and iphy for 10386
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     GNB Delta Commission
    ...    ${scf}

Basic Bring up gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link , X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    log to console      config setup Done
    NG Link Should be UP
    log to console      NG link is up
    X2AP Link Should be UP
    log to console      X2AP link should be Up

SA Call for Feature CB010386
    [Arguments]             ${UE_Id}=1          ${dl_rate}=5            ${ul_rate}=5        ${duration}=60s
    ${PDU_session_setup_output}                 UE Register should be Successful for SA     ${UE_Id}
    sleep   10s
    Traffic should be successful for SA         traffic_dl_rate=${dl_rate}          traffic_ul_rate=${ul_rate}
    sleep   ${duration}
    UE Deregister should be Successful for SA
    [Return]        ${PDU_session_setup_output}

NSA Call for Feature CB010386
    [Arguments]             ${UE_ID_NSA}=101         ${dl_rate}=5        ${ul_rate}=5       ${duration}=60s
    ${ue_attach_output}     LTE Attach should be Successful for NSA      ${UE_ID_NSA}
    UE Attach should be Successful for NSA      ${UE_ID_NSA}
    Start LTE Traffic       ${UE_ID_NSA}            ${dl_rate}          ${ul_rate}         ${duration}
    UE 5GDetach should be Successful for NSA    ${UE_ID_NSA}
    UE Detach should be Successful for NSA      ${UE_ID_NSA}
    [Return]                ${ue_attach_output}

Stop pcap collection in gNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    core.stop_collectors            names=${name}
    core.collect_collectors         names=${name}       target_dir=${Log_Path}
    core.teardown_collectors        names=${name}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    log to console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Get PNR_FR1 value
    [Arguments]        ${pcap_file}    ${filter}=${Filter_D1}        ${field}=nr-rrc.p_NR_FR1
    ${PNR_values}     Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    [Return]          ${PNR_values}

Get P_max value
    [Arguments]        ${pcap_file}    ${filter}=${Filter_D1}        ${field}=nr-rrc.p_Max
    ${Pmax_values}     Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    ${Pmax_list}       split string and return list      ${Pmax_values}    ,
    [Return]           ${Pmax_list}

Suite TearDown for CB010386
    RAT Block Unblock
    Common Suite Teardown

Common test case tear down LO AP LO
    Get SCF Value from file
    Delete Basic Interface on UTE
    Collect Logs For The Test           ${Log_Path}
    Update And Put Iphy Xml         ${IphyConfigDir}/LO_AP_LO_iphy.xml
    Full Commission With SCF File For UTE       ${DeltaConfigDir}/LO_AP_LO_SCF.xml
    Sleep   360s
    Wait Coam Site To Be Ready

Display UE statistics
    [Arguments]    ${id}=${UE_ID}       ${type}=pdsch,pusch    ${scell}=0-10
    wtsrunner.ue_stats_nr       scell=${scell}      type=${type}    id=${id}

Get DRX_Setup value
    [Arguments]             ${pcap_file}    ${filter}=${DRX_setup}        ${field}=nr-rrc.milliSeconds
    ${DRX_setup_Value}      Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    Log to Console          ${DRX_setup_Value}
    Should Not Be Empty     ${DRX_setup_Value}
    [Return]          ${DRX_setup_Value}

Get scelltoAddmodlist value
    [Arguments]        ${pcap_file}    ${filter}=${scellModlistfilter}        ${field}=nr-rrc.physCellId
    ${scelltoAddmodlist}     Get Fields from Pcap       ${pcap_file}          ${filter}        ${field}
    Log to Console           ${scelltoAddmodlist}
    Should Not Be Empty      ${scelltoAddmodlist}
    [Return]                 ${scelltoAddmodlist}

Get measGapconfig gapFR1 value
    [Arguments]        ${pcap_file}    ${filter}=${gapFR1_filter}                 ${field}=nr-rrc.gapFR1
    ${gapFR1}          Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    Log to Console          ${gapFR1}
    Should Not Be Empty     ${gapFR1}
    [Return]                ${gapFR1}

Get DRX_config value
    [Arguments]             ${pcap_file}    ${filter}=${DRX_setup}        ${field}=nr-rrc.drx_Config
    ${DRX_config}      Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    Log to Console          ${DRX_config}
    Should Not Be Empty     ${DRX_config}
    [Return]          ${DRX_config}

Trigger B2 HO and verify
    [Arguments]                 ${UE_ID}=1          ${B2MeasId}=3      ${B2PhyCellId}=11
    ...                         ${verify_patter}=${B2_HO_Pattern}
    Trigger B2 measurement      ${UE_ID}            ${B2MeasId}        ${B2PhyCellId}
    ${output}       Read WTS Output Until Pattern Matches           ${verify_patter}          ${Timeout_NSA}
    Print Matching Lines from Output File          ${output}        Successful handover
