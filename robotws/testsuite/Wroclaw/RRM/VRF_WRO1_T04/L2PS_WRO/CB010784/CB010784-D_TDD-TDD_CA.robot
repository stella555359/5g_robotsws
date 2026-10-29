*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_MP_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB008985/CB008985_keywords.py
Library      BuiltIn
Library      Collections
Library      ute_admin_infomodel
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE_addExtDelay_160_PCell.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=scfc_10784_TDD-TDD_CA_delay_160_ABIP.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Tshark With Alias
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_CA_TDD-TDD.lua

Suite Teardown     Run Keywords    Print Active Alarms
    ...        AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${LOCAL_MOID}=                    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${ADMIN_INFOMODEL_ALIAS}=         infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}=       ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}=      infomodel.ims2
${TA_RACH_RESP_BIN_26}=           M55307C01026
${TSHARK_ALIAS}=                  tshark_uu_alias_01
${TSHARK_DIR}=                    ${OUTPUT_DIR}/Tshark_logs

*** Test Cases ***
CB010784-D_IWK5_UE_call_to_regular_cell_in_CA_Pcell_TDD_with_3rdPS_Scell_TDD
    Check Guard Period Length For PCell     expected_value=6Symbols
    Attach SA UE-1 to TDD PCell
    Start DL and UL Data Traffic SA And Expect Scell Activation
    Verify DL and UL Tput SA
    Check Timing Advance Counters
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA    ue_id=1
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Attach SA UE-${ue_id} to TDD PCell
    Check nrofDownlinkSymbols Is Aligned With GP Length For PCell      expected_value=6
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    gw_id=1

Start Tshark With Alias
    Start Tshark
    ...    log_filename=10784_uu.pcapng
    ...    alias=${TSHARK_ALIAS}
    ...    eth_interface=eth4
    ...    capture_filter=''
    ...    log_dirpath=${TSHARK_DIR}

Stop Tshark With Alias
    Stop Tshark    alias=${TSHARK_ALIAS}
    Remove Directory    path=${TSHARK_DIR}    recursive=True

Check nrofDownlinkSymbols Is Aligned With GP Length For PCell
    [Arguments]      ${expected_value}
    Stop Capturing    alias=${TSHARK_ALIAS}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${TSHARK_ALIAS}
    ...    packet_filter=nr-rrc.nrofDownlinkSymbols==${expected_value}&&iphy.cell_id==1
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]
    ...    timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Query Infomodel And Expect List Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${list}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${list}.${parameter}=${value}]
    ...      timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Start Infomodel Logging
    ute_admin_infomodel.Setup infomodel    address=192.168.255.129    port=443    alias=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Connect infomodel    alias=${ADMIN_INFOMODEL_ALIAS}

Stop Infomodel Logging
    [Arguments]    ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Save Infomodel Log    filename=${log_dir}/${filename}  alias=${alias}
    ute_admin_infomodel.Disconnect Infomodel  alias=${alias}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

Check Guard Period Length For PCell
    [Arguments]      ${expected_value}
    Start Infomodel Logging
    Query Infomodel And Expect List Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-1/NRCELL_A-1
    ...    parameter=guardPeriodLength
    ...    list=tddFrameStructure
    ...    value=${expected_value}
    Stop Infomodel Logging

Start DL and UL Data Traffic SA And Expect Scell Activation
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=175 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=4
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=3
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1
    ...    pass_regexp=SCellIndex 1 activated successfully
    Sleep    20s

Verify DL and UL Tput SA
    ${pcell_tput_dl}=    Get Max Data Traffic For Given Cc    ue_id=1    cc=0    direction=dl    unit=Mbps
    ${scell_tput_dl}=    Get Max Data Traffic For Given Cc    ue_id=1    cc=1    direction=dl    unit=Mbps
    ${pcell_tput_ul}=    Get Max Data Traffic For Given Cc    ue_id=1    cc=0    direction=ul    unit=Mbps
    Should Be True    ${pcell_tput_dl} > ${250}
    Should Be True    ${scell_tput_dl} > ${290}
    Should Be True    ${pcell_tput_ul} > ${70}

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${max_tput} > ${expected_tput}

Create Timing Advance Counter List
    @{TA_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${1}    ${10}
        Append To List    ${TA_COUNTERS}    M55307C0100${ID}
    END
    FOR    ${ID}    IN RANGE    ${10}    ${33}
        Append To List    ${TA_COUNTERS}    M55307C010${ID}
    END
    Set Test Variable    @{TA_COUNTERS}

Check Timing Advance Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Create Timing Advance Counter List

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${TA_RACH_RESP_BIN_26}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${TA_COUNTERS}    ${TA_RACH_RESP_BIN_26}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{TA_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Stop All Data Transfers And Detach UE SA
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off


