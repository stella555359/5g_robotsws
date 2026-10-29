*** Settings ***
Documentation
...     author:                Pradeep Kumar K L
...     email:                 pradeep.kumar_k_l@nokia.com
...     Feature:               CCB014151
...     INTRODUCTION:     This user scenario describes Successful operation of buffer based blind Scell addition
...     TEST SET NAME:    CB014151_CR-B_Buffer_based_SDL_scell_addition
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:       CB014151 CFAM

Library             ute_wtssim
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../../resources/robot/AIC_Common_Keywords.robot
#Resource            ../../../resources/robot/Capture.robot
Resource            ../../../resources/robot/Common_Keywords.robot
Resource            ../resources/ORAN_Keywords.robot
Resource            ../../../resources/robot/WTS_Runner_Keywords.robot
#Resource            ../../../ORAN/T11/CB014151/CB014151_Keywords.robot
Resource            ../../../ORAN/T08/CB008048/resources/CB008048_keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
#Resource            taf/rfrl/common_resources/robot/coam.robot Resource
Library            ta5g_commissioning
Library            ta5g_setups_and_teardowns

Library      ta5g_pm_counters
Library     ta5g_admin_operations




Suite Setup         Run keywords     Enable Cloud
...                 AND     Test Suite Setup
#Get and Update RFMplugin   ${RFplugin_file}
#...                 AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Load netconf credentials
...                 AND             load iphyfile     ${INSTALL_OFGESA}
...                 AND             Sleep    30s
...                 AND             AIC Software Build Info
...                 AND             Fetch Taf Library used in TL
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${vdu_file_path}
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${vcu_file_path}
...                 AND           sleep    200s
#...                 AND              Prepare AIC TL with vcu and vdu full config files   ${vcu_file_path}    ${vdu_file_path}
#...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
#...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
#...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
#...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${300}
...                 AND           sleep   100s    reason=f1 link should up
...                 AND           sleep    10s
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    10s

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/SBTS26R2/5G_install_radio_FDD_SDL.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_FJRU-N75N3N1-G_0020.zip
#${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/SBTS26R2/iphy-SDL.xml
${iphy_file_path}  ${CURDIR}/config/SBTS26R2/iphy-SDL.xml
${wts_cfg_file}    ${CURDIR}/config/SBTS26R2/basic_FDD_NSA_ORAN_SDL.cfg
${vcu_file_path}   ${CURDIR}/config/SBTS26R2/Vcu_scf_SDL_UTEAICTL2.xml
${vdu_file_path}   ${CURDIR}/config/SBTS26R2/vdu_scf_new_SDL_cloud.xml
${rmod}            ${CURDIR}/config/SBTS26R2/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id}      ${151}
${nsa_ue_id1}      ${152}
${nsa_ue_id2}      ${153}

${Trgt_Cell}         ${1}
${x2_UP_pattern_with_simulated_gnb}    ENB-1: X2AP Link with GNB-3 .* is up
${UE_attach_pattern_RA}                   Bearer-type change from MCG to SCG-split is\n successful, HandoverType = DCHO_INACTIVE
${UE_attach_pattern}                   reported successful RA
${timeout}    20
${TRF_ID}     1

${sdl_addition_complete_pattern}         sCellIndex 9
${sdl_complete_pattern}    physCellId 50


${Bearer_ID}      2
#${AIRSCALE_GNB}    2
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${a1meas_id}   2
${Target_Cells}    3
${2CC_SDL_CELL}             ('9', '50', '75')
${id}        9
*** Test Cases ***
CB014151_CR-B_Buffer_based_SDL_scell_addition
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    UE Attach and ENDC should be Successful sim   ${nsa_ue_id}  Trgt_Cell=3   Trgt_gNB3=2  Bearer_ID=2
    Start Data and trigger for scell addition
    sleep    5s
    [teardown]   Multiple NSA UE Detach       ${nsa_ue_id}    ${nsa_ue_id}


*** keywords ***

X2AP Link Should be UP  #NSA
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=1    target=2
    Read WTS Output For Pattern And Print matching Lines    ENB-1: X2AP Link with GNB-2 .* is up    ${Timeout_NSA}
    BuiltIn.Log    x2_is_ok

UE Attach and ENDC should be Successful sim  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB3}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    X2AP Link Should be UP
    LTE Attach should be Successful    ${nsa_ue_id}
    Get Configured Measurements of UE${nsa_ue_id}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB3}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg

verify the SDL scell addition
    ${output}    Read WTS Output Until Pattern Matches    sCellIndex 9    ${Timeout_SA}
    Log to Console    ---> ${sdl_addition_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${sdl_complete_pattern}

Start Data and trigger for scell addition
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    sleep    10s
    Run Keyword And Continue on Failure    Validate DL Traffic For NSA for Maximum high data   ue_id=${nsa_ue_id}    dl_rate=650
    Run Keyword and Continue on Failure    Verify DL Tput For 2CC NSA TDD FDD

Verify Counters_scelladd
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${2}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2

Verify Counters_scelldeact
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${2}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-2
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2


Validate PM Counters_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-2

Verify Counters_scelladd M55115C03001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${2}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-1

Verify DL Tput For 2CC NSA TDD FDD
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${nsa_ue_id}   scell_idx=8    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${nsa_ue_id}   scell_idx=9    unit=Mbps
    Should Be True    ${pcell_tput} > ${150}
    Should Be True    ${scell_tput} > ${100}

Verify Low Data Traffic NSA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Kbps
    Should Be True    ${pcell_tput} < ${60}
    Verify There is No TPUT On Scell    ue_id=${nsa_ue_id}   scell_idx=9

Get And Check Scell Infos
    [Arguments]    ${scells_info}    ${egate_file}=/opt/iphy/latest/egate_console.log.001
    [Documentation]    This keyword is to get and check Scell Info from egate Log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scells_info} | Yes |expected scell info with the format ('sCellIndex', 'physCellId', 'frequencyBandList') |
    ...    | ${egate_file | No | the egate Log path|
    ...    The keyword return a tuple list, then check whether it include above expected infos defined in ${scells_info}
    ...    Examples:
    ...    | Get And Check Scell Infos | ('9', '50', '75')|
    ${content}    OperatingSystem.Get File    ${egate_file}

    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\s+{\\s+(?P<frequencyBandList>\\d+)\\s+},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    BuiltIn.Log    ${ret}
    ${new_ret}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${new_ret}    u    ${EMPTY}
    Log to console    ${ret}
    Should Contain    ${ret}    ${scells_info}



Verfiy Scells Are Activation
    [Arguments]     ${id}
    Log To Console    verify Scell Info...
        ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully
        ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log.001*|grep -i "${scell_activation}"|wc -l
        Should Be True    ${check_rst}==1

Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}     Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}     Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}     Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID3}
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}     Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID4}
    Trigger UL Traffic for NSA    ue_id=${nsa_ue_id}     Traffic_rate=mbps     ul_rate=170       trf_id=${TRF_ID}
    sleep   15s    reason=Wait for successful traffic start

