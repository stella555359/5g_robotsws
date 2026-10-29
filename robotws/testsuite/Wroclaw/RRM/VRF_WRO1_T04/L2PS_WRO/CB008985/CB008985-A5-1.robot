*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD__WITH__SBTS23R1    CRT    RAN_5G    RAN_5G_TDD
...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD__WITH__SBTS00

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    CB008985_keywords.py
Library      ute_admin_infomodel


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AZQI_8985_4.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_cb008985_AZQI_A5_1.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_SA.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
${LOCAL_MOID}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${ADMIN_INFOMODEL_ALIAS}=                      infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}=                    ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}=                   infomodel.ims2

*** Test Cases ***
CB008985-A_A5_FR1_TDD_SA_call_on_SuperCell_5GC001208_GP2_multiUE_different_subcell
    Verify Supercell setup
    Set Internal Traffic Type To UE
    Set Beams
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=50   tput_ul=20
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=18
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=49
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=50   tput_ul=20
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=18
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=49
    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=3    pdu=3   tput_dl=50   tput_ul=20
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=18
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=49
    Attach Ue    ue_id=4
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=4    pdu=4   tput_dl=50   tput_ul=20
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=18
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=49
    Move UE Inside Coverage Area
    Check Beam Counters

*** Keywords ***
Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]
    ...    timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

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

Verify Supercell setup
    Start Infomodel Logging
    Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-1/NRCELL_R-1
    ...    parameter=numOfSuperSubCells
    ...    value=4
    Stop Infomodel Logging

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=4 pdu=4 trf_type=internal

Set Beams
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=2,0,1,3 ssbeam_bestbeam=2 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-80
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=beam_control action=activate profile_id=2 beamaction=attach

Start Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Move UE Inside Coverage Area
    Execute Egate Command   cmd=ul_sinr_testmode_nr profile_id=1 pathloss=60 pcmax=-30
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=ul_sinr action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ul_sinr action=activate profile_id=1

Check Beam Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=M55305C00001
    ...    value=${30000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=M55305C01001
    ...    value=${30000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=M55305C00003
    ...    value=${30000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=M55305C01003
    ...    value=${30000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}
