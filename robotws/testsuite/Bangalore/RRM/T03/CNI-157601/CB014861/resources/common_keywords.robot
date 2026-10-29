*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../../resources/robot/TTI_Traces.robot
Library           ../../../../../resources/python/CPRT_Capture.py
Resource         ../../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../../../../resources/robot/Setup_Env.robot
Resource         ../../../../../resources/robot/Airphone.robot
Resource         ../../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../../resources/robot/PM_Counters.robot
Resource         ../../../../../resources/robot/common_log_collection.robot
Resource         ../../../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../../../resources/robot/BBpooling_MuMIMO.robot
Library          ../../../../../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String
Library          verify_rnti_bwpid.py
Library          tti_parser_dl_muting.py


*** Variables ***
${wts_cfg_folder}     ${CURDIR}/../config/wts
${scf_folder}       ${CURDIR}/../config/scf/
${bsr_iphy_folder}     ${CURDIR}/../config/
${wts_cfg_file}     ${wts_cfg_folder}/egate_TMOUS.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${start_ue_id}    31
${end_ue_id}      34
${es_start_ue}   1
${es_end_ue}    30
${es_mu_start_ue}   1
${es_mu_end_ue}    21
${es_ca_start_ue}   1
${es_ca_end_ue}    20
${fdd_ca_start_ue}   51
${fdd_ca_end_ue}    60
${sa_ue_id1}      1
${sa_ue_id2}      2
${sa_ue_id3}      3
${sa_ue_id4}      4
${nsa_ue_id1}      ${101}
${nsa_ue_id2}      ${102}
${nsa_ue_id3}      ${103}
${nsa_ue_id4}      ${104}
${start_ue_id4}    41
${end_ue_id4}    46
${phy_id_tc56}    50
${phy_id_iwk12}    51
${phy_id1}   51
${phy_id3}   53
${phy_id4}   54
${pm_cellID}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}   1
${Pdu_ID}      1
${Pdu_ID2}    2
${TRF_ID}     1
${TRF_ID2}    2
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${QFI_ID5}    5
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${Q_O_ADD5}    5
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
${no_of_cells}   12
${no_of_cells_TC56}   6
${CELL_ID}    1
${CELL_ID2}    2
${CELL_ID3}    3
${CELL_ID4}    4
${CELL_ID10}    10
${local_moid}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL
${epc_log_path}    /tmp/
${TC1_act_json_file}    ${scf_folder}/CB008227_feature_act.json
${TC1_deact_json_file}    ${scf_folder}/CB008227_feature_deact.json
${Enable_congweight_json}    ${scf_folder}/Enable_congweight.json
${Disable_congweightjson}    ${scf_folder}/Disable_congweight.json
#TC32 Variables
${wts_cfg_file_TC32}     ${wts_cfg_folder}/basic_setup_TC32_TC15.cfg
${wts_cfg_file_TC56}     ${wts_cfg_folder}/wts_DL_MUMIMO_Enh.cfg
${wts_cfg_file_TC06}     ${wts_cfg_folder}/basic_setup_TC06.cfg
${wts_cfg_file_iwk12}     ${wts_cfg_folder}/wts_DL_CA_T_T.cfg
${wts_cfg_file_alt1}     ${wts_cfg_folder}/B501_ALT1.cfg
${iphy_file_TC56}     ${bsr_iphy_folder}/iphy_DLMUMIMO.xml
${iphy_file_TC06}     ${bsr_iphy_folder}/iphy_AHEGG_TC6.xml
${iphy_file_iwk12}     ${bsr_iphy_folder}/iphy_TMO_DLMUMIO_CA.xml
${TC32_nsa_ue_id1}      ${101}
${TC32_nsa_ue_id2}      ${102}
${TC32_nsa_ue_id3}      ${103}
${TC32_nsa_ue_id4}      ${104}
${TC04_delta_file_name}=        ${scf_folder}/SU_MIMO_enable.json
${TC02_delta_file_name}=        ${scf_folder}/MU_MIMO_enable.json
${TC04_revert_changes}=        ${scf_folder}/SU_default_changes.json
${TC02_revert_changes}=        ${scf_folder}/MU_default_changes.json
${enable_exhaustive_scheduling}=        ${scf_folder}/enable_exhaustive_scheduling.json
${TC56_delta_file_name}=        ${scf_folder}/TC56_DL_MUMIMO_Enh.json
${TC56_revert_changes}=        ${scf_folder}/TC56_DL_MUMIMO_Enh_revert.json
${TC32_delta_file_name}=        ${scf_folder}/TC32_Enable_NBR_maxNumOfNbrBearers_0.json
${TC32_delta_file_name1}=       ${scf_folder}/TC32_maxNumOfNbrBearers_2.json
${TC32_revert_delta}=           ${scf_folder}/TC32_Disable_NBR.json
${TC06_delta_file_name}=        ${scf_folder}/TC06_CB006877_disable.json
${iwk12_delta_file_name}    ${scf_folder}/CB014861_DL_CA_enable.json
${iwk12_revert_changes}    ${scf_folder}/CB014861_DL_CA_disable.json
${alt1_delta_file_name}    ${scf_folder}/B501_ALT1_enable.json
${alt1_revert_changes}    ${scf_folder}/B501_ALT1_disable.json
${FIELDS}    (itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.muStatus == 0x15)
${LTE_cell_id1}    1
${LTE_cell_id2}    2
${LTE_INTRA_HO_egate_message}    Intra-eNB handover from ENB-1.1 to ENB-1.2 perfo\nrmed
${TC32_nbr_dl_value}    400
${TC32_nbr_ul_value}    80
${ACC_SCHED_UE_PDSCH}   M55308C17001
${PRB_USED_PDSCH}   M55308C10001
${MU_MIMO_PAIR_DL_SUCC}   M55308C34030
${SA_DU_DRB_NBR_DL}    M55139C03509
#TC15 Variables
${TC15_delta_file_name}    ${scf_folder}/Enable_NBR_TC15_TC27.json
${TC15_nsa_ue_id1}      ${131}
${TC15_nsa_ue_id2}      ${132}
${TC15_nsa_ue_id3}      ${133}
${TC15_nsa_ue_id4}      ${134}
${TC15_CELL_ID}         ${3}

#CB013233-A#IWK101_1 Variables
${CB013233_sa_ue_id1}    ${51}
${CB013233_A_delta_file_name}     ${scf_folder}/Enable_CB013233_RRC_Inactive.json
${CB013233_revert_delta}          ${scf_folder}/Disable_CB013233_RRC_Inactive.json
${CB013233_CELL_ID}         ${7}
${drb_inactivity_timer}=    60
${srb_inactivity_timer}=    60
${delta}=   30

#TC57_Variables
${TC57_sa_ue_id1}      ${1}
${TC57_sa_ue_id2}      ${2}
${TC57_sa_ue_id3}      ${3}
${TC57_sa_ue_id4}   ${4}
@{FIELDS_PAIREDUE}    pairedUe   sfn  slot
${wts_cfg_file_TC57}   ${wts_cfg_folder}/basic_setup_TC57.cfg
${TC57_delta}      ${scf_folder}/TC57_Delta.json

${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py

#CNI_105919 Variables

${CNI_105919_delta_file_1}    ${scf_folder}/Enable_actPdcpHfnDesyncDetectAlgo.json
${CNI_105919_delta_file_2}    ${scf_folder}/Enable_VONR_ROHC.json
${HFN_DecipheredPackets_pattern}   "HFNDESYNCDETECTED due to 20 consecutiveDecipheredPacketsValidationFailures"
${HFN_DecompressedPackets_pattern}    "HFNDESYNCDETECTED due to 20 consecutiveDecompressedPacketsValidationFailures"
${105919_sa_ue_id1}    ${5}
${105919_sa_ue_id2}    ${6}
${105919_sa_ue_id3}    ${7}
${105919_sa_ue_id4}    ${8}
${105919_sa_ue_id5}    ${9}
${105919_sa_ue_id6}    ${10}

#CNI_140556 Variables

${CNI_140556_sa_ue_id1}    ${1}
${CNI_140556_delta_filename}=      ${scf_folder}/delta_CNI_140556_enable.json
${CNI_140556_delta_filename1}=     ${scf_folder}/delta_CNI_140556_disable.json

${tti_dir_name1}=       No_DL_muting
${tti_dir_name2}=       DL_muting
@{muted_slot}=     8   9

#CB006877 TC37 Variables

${sa_ue_id_cell4}      71
${en_ue_id_cell4}      75
${sa_ue_id_cell5}      91
${en_ue_id_cell5}      95

${TC37_cell_subgroup_id}    7

${nbrOfBlankedPRBsLowEdgeUL}    1

${TC37_basic_cfg}           ${wts_cfg_folder}/basic_setup_TC37.cfg

${TC37_delta_file_name}     ${scf_folder}/TC37_CB006877_CNI_94156_Enable.json
${TC37_delta_file_name1}    ${scf_folder}/TC37_CB006877_UL_PRB_Blanking.json
${TC37_delta_file_name2}    ${scf_folder}/TC37_CB006877_disable.json
${TC37_dummy_json}          ${scf_folder}/TC37_CB006877_dummy.json
@{pathlist}    startPrb
${filter}   ${EMPTY}
${startPacket}   1
${endPacket}   1000
${num_of_prbs_using_lower_pcsi}   0
${num_of_prbs_using_upper_pcsi}   0
${num_of_prbs_lower_pcsi}   0
${count_of_prbs_using_lower_pcsi}   0

#CB013233-A#B101 Variables
${13233_A_B101_basic_cfg}    ${wts_cfg_folder}/basic_setup_13233_A_B101.cfg
${13233_A_B101_delta_file_name}    ${scf_folder}/Enable_DRX_GBR.json
${13233_A_B101_delta_file_name_1}    ${scf_folder}/Disable_DRX_GBR.json

*** Keywords ***
Update bsr package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${bsr_iphy_folder} ${BSR_FILEPATH}    shell=yes
    ADMIN Setup Admin
    ADMIN Update Software With Activation    sw_package=${bsr_iphy_folder}/${BSR_FILENAME}

fix vlan in scf and commission
    ${mod_scfc}     Fix Vlan Id In Scfc   ${scf_folder}SCF_TC06_SANSA_35Mhz_ASOH_GMC.xml
    Send Full Commissioning   ${mod_scfc}


Testcase setup with delta Commissioning
    [Arguments]    ${josn_file}   ${wts_file}   ${num_of_cells}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    30min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Send Delta Commissioning     ${josn_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_file}   ${num_of_cells}
    Check gNB Bulid

Testcase Setup
    [Arguments]    ${IPHY_xml}   ${scfc_file}   ${wts_file}   ${num_of_cells}
    Modify IPHY File And Send to Airphone Custom    ${IPHY_xml}
    Find Scfc And Fix And Send Full Commissioning  scfc_filename=${scfc_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_file}   ${num_of_cells}
    Check gNB Bulid

Testcase Setup ASOH
    [Arguments]    ${IPHY_xml}   ${scfc_file}   ${wts_file}   ${num_of_cells}
    Modify IPHY File And Send to Airphone Custom    ${IPHY_xml}
    Find Scfc And Fix And Send Full Commissioning  scfc_filename=${scfc_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH      ${wts_file}   ${num_of_cells}
    Check gNB Bulid

common Teardown
     Run Keyword and Ignore Error    Stop Log    snapshot   btslog
     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Attach 10 UEs with dedicated PDU session
    FOR    ${ue_id}    IN RANGE    ${fdd_ca_start_ue}     ${fdd_ca_end_ue}+${1}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep   1s
        wtsrunner.trf_data_start     ue=${UE_ID}    trf_id=1   pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...     dir=dl    protocol=tcp    mbps=170
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    trf_id=2   pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...     dir=dl    protocol=tcp    mbps=170
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...     dir=ul    protocol=tcp    mbps=60
        sleep    5s
    END


Check UEs scells traffic
    FOR    ${ue_id}    IN RANGE    ${fdd_ca_start_ue}     ${fdd_ca_end_ue}+${1}
        wtsrunner.ue_stats_nr    id=${ue_id}    type=pdsch    scell=0   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${dl_avg_tput_scell0}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${dl_avg_tput_scell0}=    Set Variable If    "${dl_avg_tput_scell0}"=="0.0"    0    ${dl_avg_tput_scell0}
#Check Scell1 DL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}   type=pdsch    scell=1   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${dl_avg_tput_scell1}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${dl_avg_tput_scell1}=    Set Variable If    "${dl_avg_tput_scell1}"=="0.0"    0    ${dl_avg_tput_scell1}
#Check Scell0 UL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}    type=pusch   scell=0   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${ul_avg_tput_scell0}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${ul_avg_tput_scell0}=    Set Variable If    "${ul_avg_tput_scell0}"=="0.0"    0    ${ul_avg_tput_scell0}
#Check Scell0 UL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}    type=pusch   scell=1   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${ul_avg_tput_scell1}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${ul_avg_tput_scell1}=    Set Variable If    "${ul_avg_tput_scell1}"=="0.0"    0    ${ul_avg_tput_scell1}
        Run Keyword and continue on Failure     should be true  ${dl_avg_tput_scell0} > 0
        Run Keyword and continue on Failure     should be true  ${dl_avg_tput_scell1} > 0
        Run Keyword and continue on Failure     should be true  ${ul_avg_tput_scell0} > 0
        Run Keyword and continue on Failure     should be true  ${ul_avg_tput_scell1} > 0
    END

Attach 20 UEs with dedicated PDU session
    wtsrunner.ue_meas_cfg_disp    id=1    meas_obj_type=nr
    FOR    ${ue_id}    IN RANGE    ${es_ca_start_ue}     ${es_ca_end_ue}+${1}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep   1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...     dir=dl    protocol=tcp    mbps=100
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...     dir=ul    protocol=tcp    mbps=5
        #sleep    1s
        #wtsrunner.ue_measurement_send_nr    id=${UE_ID}   meas_id=5    event=A1    srsrp_nr=80
        sleep    1s
    END

Check UEs scells for zero traffic
    FOR    ${ue_id}    IN RANGE    ${es_ca_start_ue}     ${es_ca_end_ue}+${1}
#Check Scell0 DL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}    type=pdsch    scell=0   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${dl_avg_tput_scell0}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${dl_avg_tput_scell0}=    Set Variable If    "${dl_avg_tput_scell0}"=="0.0"    0    ${dl_avg_tput_scell0}
#Check Scell1 DL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}   type=pdsch    scell=1   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${dl_avg_tput_scell1}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${dl_avg_tput_scell1}=    Set Variable If    "${dl_avg_tput_scell1}"=="0.0"    0    ${dl_avg_tput_scell1}
#Check Scell0 UL Avg Tput
        wtsrunner.ue_stats_nr    id=${ue_id}    type=pusch   scell=0   format=long
        ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
        ...                     timeout=30
        ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
        ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
        ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
        ${ul_avg_tput_scell0}=    Evaluate    sum(map(float,${avg_tp_list}))
        ${ul_avg_tput_scell0}=    Set Variable If    "${ul_avg_tput_scell0}"=="0.0"    0    ${ul_avg_tput_scell0}
        Run Keyword and continue on Failure     should be true  ${dl_avg_tput_scell0} > 0
        Run Keyword and continue on Failure     should be true  ${dl_avg_tput_scell1} > 0
        Run Keyword and continue on Failure     should be true  ${ul_avg_tput_scell0} > 0
    END

Attach 30 UEs with multiple PDU session
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}     ${es_end_ue}-${19}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        sleep  2s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=dl    protocol=tcp    size=4048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})>0
    END
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}+${10}     ${es_end_ue}-${9}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep   2s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=dl    protocol=tcp    size=4048    burst=60
        sleep    2s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
    END
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}+${20}     ${es_end_ue}+${1}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        sleep   1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD3}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD4}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD5}   by=amf
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=dl    protocol=tcp    size=1048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID4}
        ...    dir=dl    mbps=2    protocol=tcp
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID4}
        ...    dir=ul    kbps=200    protocol=tcp
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID5}
        ...    dir=dl    mbps=2    protocol=tcp
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID5}
        ...    dir=ul    kbps=200    protocol=tcp
   END

Attach 20 UEs with multiple PDU session
    FOR    ${ue_id}    IN RANGE    ${es_mu_start_ue}     ${es_mu_end_ue}-${10}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        sleep  2s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=dl    protocol=tcp    size=8048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
    END
    FOR    ${ue_id}    IN RANGE    ${es_mu_start_ue}+${10}     ${es_mu_end_ue}
        wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${Pdu_ID}    trf_type=internal
        wtsrunner.ue_register   id=${ue_id}
        sleep   1s
        wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${Pdu_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
        ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
        Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
        sleep   1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD3}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD4}   by=amf
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=dl    protocol=tcp    size=1048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=ul    protocol=tcp    size=1048    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID4}
        ...    dir=dl    mbps=1    protocol=tcp
        sleep    1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID4}
        ...    dir=ul    kbps=500    protocol=tcp
    END

Check UEs for zero traffic
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}     ${es_end_ue}-${19}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=ul
        ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
        ${cell_ul_tput}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}+${10}     ${es_end_ue}-${9}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=ul
        ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
        ${cell_ul_tput}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${es_start_ue}+${20}     ${es_end_ue}+${1}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=dl
        ${dl_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_dl_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=ul
        ${ul_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_ul_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID4}   dir=dl
        ${dl_avg_tput4}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput4}    Average data rate +(\\d+)    1
        ${cell_dl_tput4}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID4}   dir=ul
        ${ul_avg_tput4}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput4}    Average data rate +(\\d+)    1
        ${cell_ul_tput4}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID5}   dir=dl
        ${dl_avg_tput5}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput5}    Average data rate +(\\d+)    1
        ${cell_dl_tput5}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID5}   dir=ul
        ${ul_avg_tput5}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput5}    Average data rate +(\\d+)    1
        ${cell_ul_tput5}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput4} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput4} > 0
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput5} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput5} > 0
   END

Check 20 UEs for zero traffic
    FOR    ${ue_id}    IN RANGE    ${es_mu_start_ue}     ${es_mu_end_ue}-${10}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=ul
        ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
        ${cell_ul_tput}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${es_mu_start_ue}+${10}     ${es_mu_end_ue}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=dl
        ${dl_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_dl_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=ul
        ${ul_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_ul_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID4}   dir=dl
        ${dl_avg_tput4}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput4}    Average data rate +(\\d+)    1
        ${cell_dl_tput4}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID4}   dir=ul
        ${ul_avg_tput4}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput4}    Average data rate +(\\d+)    1
        ${cell_ul_tput4}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput4} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput4} > 0
    END

Attach UE with GBR/NBR/non-NBR
    Register UE${sa_ue_id1} and establish VoNR Call
    sleep     1s
    Register UE${sa_ue_id2} and establish NBR Call
    sleep     1s
    Register UE${sa_ue_id3} and establish nGBR without NBR Call
    sleep     1s
    Register UE${sa_ue_id4} and establish nGBR without NBR Call
    sleep     1s

Validate DL UL Traffic For all UEs with NBRPRB 90%
    Validate DL UL Throughput For UE     ${sa_ue_id1}   ${Pdu_session_ID}   ${QFI_ID4}  0.022   0.022
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   300    55
    Validate DL UL Throughput For UE     ${sa_ue_id3}   ${Pdu_session_ID}   ${QFI_ID2}   210   25
    Validate DL UL Throughput For UE     ${sa_ue_id4}   ${Pdu_session_ID}   ${QFI_ID2}   210   20

Validate DL UL Traffic For all UEs with NBRPRB 10%
    Validate DL UL Throughput For UE     ${sa_ue_id1}   ${Pdu_session_ID}   ${QFI_ID4}  0.021   0.021
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   300    35
    Validate DL UL Throughput For UE     ${sa_ue_id3}   ${Pdu_session_ID}   ${QFI_ID2}   210   25
    Validate DL UL Throughput For UE     ${sa_ue_id4}   ${Pdu_session_ID}   ${QFI_ID2}   210   11

Register UE${sa_ue_id} and establish VoNR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Success   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    1s    reason=wait command finish
    FOR    ${Q_O_ADD}    IN RANGE    ${Q_O_ADD2}     ${Q_O_ADD4}+${1}
         UE PDU Modfication should be Successful     ${sa_ue_id}    ${Pdu_session_ID}    ${Q_O_ADD}
         sleep  1s
    END
    FOR    ${QFIID}    IN RANGE    ${QFI_ID3}     ${QFI_ID4}+${1}
         Trigger VoNR DL Traffic for SA     ${sa_ue_id}    ${Pdu_session_ID}   ${TRF_ID}   ${QFIID}   rtp_codec=custom
         Trigger VoNR UL Traffic for SA     ${sa_ue_id}    ${Pdu_session_ID}   ${TRF_ID}   ${QFIID}   rtp_codec=custom
         sleep  1s
    END

Register UE${sa_ue_id} and establish NBR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

Register UE${sa_ue_id} and establish nGBR without NBR Call
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful    ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    UE PDU Modfication should be Successful     ${sa_ue_id}    ${Pdu_session_ID}    ${Q_O_ADD2}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA     ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID2}
        Trigger UL Traffic SA     ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID2}
        sleep  1s
    END

Deregister UEs
    [Arguments]    ${sa_ue_id1}    ${sa_ue_id2}
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id2}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

Detach UEs
    [Arguments]    ${ue_start_id}    ${ue_end_id}
    FOR	  ${ue_idx}   IN RANGE    ${ue_start_id}   ${ue_end_id}+1
        wtsrunner.ue_deregister    id=${ue_idx}    ue_deregister_type=switch_off
    END

Attach multiple SA UEs with two NBR bearer traffic
    [Arguments]    ${ue_id1}    ${ue_id2}
    log to console   UE attach trigerring now...
    FOR      ${ue_idx}   IN RANGE    ${ue_id1} 	  ${ue_id2}+1
        UE Register should be Success      ue_id=${ue_idx}
        sleep   1s
        NBR_QFI2_3    ${ue_idx}
        sleep   1s
        QFI_2_3 traffic   ${ue_idx}
    END

Register multiple NSA UE to cell
    [Arguments]    ${cell}   ${first_ue_id}    ${last_ue_id}
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         LTE Attach should be Successful    ${ue_id}
         UE Attach should be Successful     ${ue_id}   ${cell}
    END

Attach multiple SA UE with traffic
    [Arguments]    ${first_ue}      ${last_ue}
    FOR    ${ue_id}    IN RANGE    ${first_ue}     ${last_ue}+${1}
          UE Register should be Success    ${ue_id}
          Trigger DL Traffic SA   ${ue_id}   50
          sleep   1s
          Trigger UL Traffic SA   ${ue_id}   100
          sleep   1s
    END
    sleep   20s

Check cell level UL tput SA
    [Arguments]   ${first_ue}    ${last_ue}
    ${cell_ul_tput}   set variable  0
    FOR     ${ue_idx}   IN RANGE    ${first_ue}    ${last_ue}+1
    wtsrunner.bearer_stats   ue=${ue_idx}   pdu=${Pdu_session_ID}   qfi=${QFI_ID}   dir=ul
    ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
    ${cell_ul_tput}     Evaluate    ${cell_ul_tput} + int(${output[0]})
    END
    [Return]   ${cell_ul_tput}

Check cell level UL tput SA using ue_stats
    [Arguments]   ${first_ue}    ${last_ue}
    ${cell_ul_tput}   set variable  0
    FOR   ${ue_idx}   IN RANGE    ${first_ue}    ${last_ue}+1
          ${ul_avg_tput}    Get AVG UL DATA TRAFFIC For Given CC    ${ue_idx}   ${0}
          ${cell_ul_tput}     Evaluate    ${cell_ul_tput} + int(${ul_avg_tput})
    END
    [Return]   ${cell_ul_tput}

Start and validate UL and DL traffic NSA UE
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}   ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  2s
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${ul_rate}
         sleep  2s
    END
    sleep   10s


Check cell level UL tput NSA
    [Arguments]   ${first_ue}    ${last_ue}
    ${cell_ul_tput}   set variable  0
    FOR     ${ue_idx}   IN RANGE    ${first_ue}    ${last_ue}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   id=2   dir=ul
    ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
    ${cell_ul_tput}     Evaluate    ${cell_ul_tput} + int(${output[0]})
    END
    [Return]   ${cell_ul_tput}

NBR_QFI2_3
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

Validate SA UEs Throughput
    FOR      ${ue_idx}   IN RANGE    ${sa_ue_id1} 	  ${sa_ue_id2}+1
        QFI2_3_traffic_validation   ${ue_idx}
    END

QFI2_3_traffic_validation
   [Arguments]    ${ue_id}
   FOR    ${qfi}   IN RANGE   1   3+${1}
       ${dl}=   set variable if    ${qfi} > 1   40   30
       Validate DL UL Throughput For UE    ${ue_id}   1   ${qfi}   ${dl}   30
   END

QFI_2_3 traffic
    [Arguments]    ${ue_id}
    FOR    ${qfi}   IN RANGE   1   3+${1}
        MultiUE Trigger DL Traffic for SA   ${ue_id}  ${ue_id}  Traffic_rate=Mbps  dl_rate=150  trf_id=${TRF_ID}  qfi_id=${qfi}
        MultiUE Trigger UL Traffic for SA   ${ue_id}  ${ue_id}  Traffic_rate=Mbps  ul_rate=50  trf_id=${TRF_ID}  qfi_id=${qfi}
    END

Multiple NSA UEs Register with NBR traffic
    [Arguments]    ${ue_id1}    ${ue_id2}
    Multiple NSA UE Register    ${ue_id1}    ${ue_id2}   10
    FOR    ${ue_idx}   IN RANGE    ${ue_id1} 	  ${ue_id2}+1
        LTE_QCI3_4   ${ue_idx}
        sleep   5s
        Trigger DL & UL Traffic   ${ue_idx}
    END

LTE_QCI3_4
    [Arguments]    ${ue_id}
    FOR   ${qci}   IN RANGE   3   4+${1}
        wtsrunner.bearer_add    ue=${ue_id}   id=${qci}  filter=0  precedence=${qci}
        sleep   1s
        wtsrunner.enb_ue_dc_modify   ue=${ue_id}   bearer_to_add=${qci}   by=enb   cause=RN_CauseRadioNetwork_unspecified
        sleep   1s
    END

Trigger DL & UL Traffic
    [Arguments]    ${ue_id}
    FOR   ${qci}   IN RANGE   2   4+${1}
        Trigger DL Traffic for NSA   ${ue_id}   mbps   30    ${qci}
        sleep   2s
        Trigger UL Traffic for NSA   ${ue_id}   mbps   10    ${qci}
    END

Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Start Log    cprt
    log to console   UE attach trigerring now...
    ${crnti_list}       Create List
    FOR      ${ue_id}   IN RANGE    ${start_ue_id4} 	  ${end_ue_id4}+${1}
        ${rnti}     UE Registered with Rach validation      ue_id=${ue_id}
        Append To List    ${crnti_list}   ${rnti}
    END
    set suite variable    ${crnti_list}
    #UE1 MOVING FROM LARGE  BWP PROFILE TO SMALL BWP PROFILE
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}     ${end_ue_id4}-${4}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD3}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD4}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD5}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_del=${Q_O_ADD2}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_del=${Q_O_ADD3}   by=amf
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID5}
        ...    dir=dl    protocol=tcp    size=500    burst=60
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID5}
        ...    dir=ul    protocol=tcp    size=500    burst=60
    END
    #UE2 MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE DUE TO LOW DATA
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${1}     ${end_ue_id4}-${3}
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=dl    protocol=tcp    mbps=10
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID}
        ...    dir=ul    protocol=tcp    mbps=10
    END
    #UE3 MOVING TO SBWP DUE TO HIGH DATA
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${2}     ${end_ue_id4}-${2}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep     1s
       wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=dl    protocol=tcp    mbps=50
        sleep    1s
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=ul    protocol=tcp    mbps=50
        sleep    1s
   END
   #UE4/5/6 MOVING TO LBWP
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${3}     ${end_ue_id4}+${1}
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD2}   by=amf
        sleep     1s
        wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID}  qosflows_to_add=${Q_O_ADD3}   by=amf
        sleep     1s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=dl    mbps=150    protocol=tcp
        sleep    2s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID2}
        ...    dir=ul    mbps=50    protocol=tcp
        sleep    2s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID3}
        ...    dir=dl    mbps=150    protocol=tcp
        sleep    2s
        wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_ID}   qfi=${QFI_ID3}
        ...    dir=ul    mbps=50    protocol=tcp
    END
    sleep   20s    reason=Wait for successful BWP switch
    Check UEs for data traffic
    ${bwpid}    Create List     3    2    1   1   1   1
    Stop Log   cprt
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}   pysical_cell_ids=${phy_id4}

Check UEs for data traffic
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}     ${end_ue_id4}-${4}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID5}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID5}   dir=ul
        ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
        ${cell_ul_tput}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${1}     ${end_ue_id4}-${3}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=dl
        ${dl_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput}    Average data rate +(\\d+)    1
        ${cell_dl_tput}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID}   dir=ul
        ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
        ${cell_ul_tput}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${2}     ${end_ue_id4}-${2}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=dl
        ${dl_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_dl_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=ul
        ${ul_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_ul_tput2}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput2} > 0
    END
    FOR    ${ue_id}    IN RANGE    ${start_ue_id4}+${3}     ${end_ue_id4}+${1}
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=dl
        ${dl_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_dl_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID2}   dir=ul
        ${ul_avg_tput2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput2}    Average data rate +(\\d+)    1
        ${cell_ul_tput2}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID3}   dir=dl
        ${dl_avg_tput3}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${dl_avg_tput3}    Average data rate +(\\d+)    1
        ${cell_dl_tput3}     Evaluate    int(${output[0]})
        wtsrunner.bearer_stats   ue=${ue_id}   pdu=${Pdu_ID}   qfi=${QFI_ID3}   dir=ul
        ${ul_avg_tput3}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        ${output}         Get Regexp Matches    ${ul_avg_tput3}    Average data rate +(\\d+)    1
        ${cell_ul_tput3}     Evaluate    int(${output[0]})
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput2} > 0
        Run Keyword and continue on Failure     should be true  ${cell_dl_tput3} > 0
        Run Keyword and continue on Failure     should be true  ${cell_ul_tput3} > 0
   END

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Verify PSBWP through TTI trace
    ${bwpid}    Create List     3    3    2    1   1    1
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    mBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}   pysical_cell_ids=${phy_id4}

Send DL data to UEs and check throughput
   [Arguments]    ${ue_id1}   ${ue_id2}
   FOR    ${ue_id}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
      ${Pdu_session_ID}=    Set Variable If    ${ue_id}==2    2   1
      ${QFI_ID}=    Set Variable If    ${ue_id}==2    2   1
      Trigger DL Traffic SA    ${ue_id}   175    ${Pdu_session_ID}   1    ${QFI_ID}
       sleep  1s
   END
   Wait '20s ' to stable
   Validate Throughput   ${ue_id1}   ${ue_id2}

Activate CSI Override command
    wtsrunner.csi_override_testmode_nr    profile_id=1    cqi=15   ri=0
    wtsrunner.ue_testmode_set_nr    id=1-2    testmode=csi_override    action=activate    profile_id=1

Set UE1 and UE2 Pos
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=1   mode=fixed   init_quad_pos=0   init_sub_quad_pos=0
    wtsrunner.ue_testmode_set_nr   id=1   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=1
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=2   mode=fixed   init_quad_pos=0   init_sub_quad_pos=1
    wtsrunner.ue_testmode_set_nr   id=2   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=2

Modify PDU session for UE
    [Arguments]    ${ue_id}   ${Pdu_ID2}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_ID2}  qosflows_to_add=${Q_O_ADD2}   by=amf
    Sleep    1s

Validate Throughput
    [Arguments]    ${ue_id1}   ${ue_id2}
    FOR    ${ue_id}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
        ${Pdu_session_ID}=    Set Variable If    ${ue_id}==2    2   1
        ${QFI_ID}=    Set Variable If    ${ue_id}==2    2   1
        ${dlrate}=    Set Variable If    ${ue_id}==2    175   175
        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${dlrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    END

Decode TTITrace
   [Arguments]    ${ttitrace_path}=${tti}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    #Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv

Wait '${time} ' to stable
    sleep    ${time}

Attach Multi-UE and trigger nNBR/NBR data
    Start Log    cprt
    log to console   UE attach trigerring now...
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    Sleep    1s
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    Sleep    1s
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID3}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID3}
    Sleep    1s
    END
    set suite variable    ${crnti_list}
    Sleep    1s
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     2    1    3
    Stop Log   cprt
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${phy_id3}

UE Registered Successfully & Rach validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log     ${crnti_string}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s1.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    NBR_QFI   ${ue_id}
    [Return]      ${crnti_string}

UE Registered with Rach validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log     ${crnti_string}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s1.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${crnti_string}

NBR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

Deregister UEs TC19
    Stop Data Traffic for SA     ue_id=${sa_ue_id1}
    Stop Data Traffic for SA     ue_id=${sa_ue_id2}
    Stop Data Traffic for SA     ue_id=${sa_ue_id3}
    UE Deregister should be Successful   ue_id=${sa_ue_id1}
    UE Deregister should be Successful   ue_id=${sa_ue_id2}
    UE Deregister should be Successful   ue_id=${sa_ue_id3}

Set Power Class For UE 1
    wtsrunner.phr_override_testmode_nr    profile_id=1     pc_max=23
    sleep     2s
    wtsrunner.ue_testmode_set_nr    id=1    testmode=phr_override    action=activate    profile_id=1
    sleep     2s

Set Power Class For UE 2

     wtsrunner.phr_override_testmode_nr    profile_id=1    pc_max=23
    sleep     2s
     wtsrunner.ue_testmode_set_nr    id=2    testmode=phr_override    action=activate    profile_id=1
    sleep     2s

#TC23 keywords
Attach NBR UE with HPA
    [Arguments]    ${sa_ue_id}
    log to console   UE${sa_ue_id} attach trigerring now...
    wtsrunner.ue_nr_rrc_setup_param    id=${sa_ue_id}    establishment_cause=highPriorityAccess
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

Register NBR UE and establish NBR Call
    [Arguments]    ${sa_ue_id}
    log to console   UE${sa_ue_id} attach trigerring now...
    UE Register should be Successful   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   175    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   80    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END

Validate DL UL Traffic For NBR UE TC23
    Validate DL UL Throughput For UE     ${sa_ue_id2}   ${Pdu_session_ID}   ${QFI_ID}   50   20

Deregister UEs TC23
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id3}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

#TC28 keywords
Inter-gNB HO for UE to simulated gNB
    [Arguments]    ${ue_id}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=52 nrsrp_nr=100

Inter-gNB HO for UE to actual gNB
     [Arguments]    ${ue_id}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=2    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100

#TC49 keywords
Enable ENDC for all Bearer
     wtsrunner.enb_param   id=1   endc_capable_qci=all

NSA CA UE Start DL Traffic for new Bearer
    [Arguments]    ${ue_id}    ${bearer_id}   ${dl_rate}
    Trigger High DL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     dl_rate=${dl_rate}      bearer_id=${bearer_id}

Validate DL Traffic For NSA CA UE
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id49}     dl_rate=140   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id49}     dl_rate=250   id=7

Add new LTE Bearer for NSA CA UE
    [Arguments]    ${ue_id}   ${bearer_id}   ${precedence}
    Add new LTE Bearer TC49  ${ue_id}    ${bearer_id}   ${precedence}
    ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}

NSA CA UE Detach
    [Arguments]    ${ue_id}
    UE Detach should be Successful    ${ue_id}

NSA CA UE Register
    [Arguments]    ${ue_id}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful     ${ue_id}     ${2}

Add new LTE Bearer TC49
    [Arguments]    ${ue_id}   ${bearer_id}    ${precedence}
    wtsrunner.bearer_add    ue=${ue_id}   id=${bearer_id}  filter=0  precedence=${precedence}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_Bearer_creation_success_TC49}    ${30}
    Print Matching Lines from Output File    ${output}    ${LTE_Bearer_creation_success_TC49}
    Log to console    New LTE Bearer addition is Success

#TC57 Keywords
Validate UL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}    ${ue4_tput}
    Run Keyword and continue on Failure   Validate PUSCH UE Stats for Given CC    ue_id=${sa_ue_id1}  scell_idx=0   ul_data_rate=${ue1_tput}
    Run Keyword and continue on Failure   Validate PUSCH UE Stats for Given CC    ue_id=${sa_ue_id2}  scell_idx=0   ul_data_rate=${ue2_tput}
    Run Keyword and continue on Failure   Validate PUSCH UE Stats for Given CC    ue_id=${sa_ue_id3}  scell_idx=0   ul_data_rate=${ue3_tput}
    Run Keyword and continue on Failure   Validate PUSCH UE Stats for Given CC    ue_id=${sa_ue_id4}  scell_idx=0   ul_data_rate=${ue4_tput}
#    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID2}
#    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
#    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID2}
#    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id4}     ul_rate=${ue4_tput}   pdu_id=1    qfi_id=${QFI_ID}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END

Set And Activate Srs beam position
    [Arguments]    ${first_ue_id}
    #UE-1 postion (0,0)
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=1   mode=fixed init_quad_pos=0   init_sub_quad_pos=0
    wtsrunner.ue_testmode_set_nr    id=${first_ue_id}    testmode=ul_mimo_srs_beam_pos     action=activate   profile_id=1
    #UE-2 postion (2,2)
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=2   mode=fixed init_quad_pos=2   init_sub_quad_pos=1
    wtsrunner.ue_testmode_set_nr    id=${first_ue_id+1}   testmode=ul_mimo_srs_beam_pos    action=activate   profile_id=2
    #UE-3 postion (3,1)
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=3   mode=fixed init_quad_pos=3   init_sub_quad_pos=1
    wtsrunner.ue_testmode_set_nr    id=${first_ue_id+2}   testmode=ul_mimo_srs_beam_pos    action=activate   profile_id=3
    #UE-4 postion (1,1)
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=4   mode=fixed init_quad_pos=1   init_sub_quad_pos=1
    wtsrunner.ue_testmode_set_nr    id=${first_ue_id+3}   testmode=ul_mimo_srs_beam_pos    action=activate   profile_id=4
#    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=2   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
#    wtsrunner.ue_testmode_set_nr   id=${first_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=2   scell=0
#    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=3   mode=fixed   init_quad_pos=1   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
#    wtsrunner.ue_testmode_set_nr   id=${first_ue_id+1}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=3   scell=0
#    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
#    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
#    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=1   init_sub_quad_pos=1   step=5   trigger_puxch_update=0
#    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
#    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=2   init_sub_quad_pos=3   step=3   trigger_puxch_update=0
#    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0

get matched packet in a list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}

get matched packet in a list with path list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             pathList=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}
Get Value as Dict In Packet Match
    [Documentation]                 Return value of a field retrieved in a packetMatch as Dict
    ...                             if not found, it return an empty string
    [Arguments]                     ${packetMatch}                      ${field}
    ...                             ${kind}=show
    @{paired_ue_list}=      Create List
    @{sfn_slot_list}=       Create List
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            Run keyword if  '${fieldName}'=='${field}[0]'     Append To List        ${paired_ue_list}  ${packetMatch.fields['${path}'].${kind}}
            Run keyword if  '${fieldName}'=='${field}[1]'     Append To List        ${sfn_slot_list}   ${packetMatch.fields['${path}'].${kind}}
            Run keyword if  '${fieldName}'=='${field}[2]'     Append To List        ${sfn_slot_list}   ${packetMatch.fields['${path}'].${kind}}
    END
    [Return]        ${paired_ue_list}   ${sfn_slot_list}

Verify UE Pairing
    [Arguments]      ${pcapFile}   ${rnti_list}
    @{prev_sfnslot}=    Create List   0   0
    @{prev_paired_ue}=  Create List   0   0
    ${loop}=    Set Variable    1
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         (uldata_puschreceivereq) && (3gpp.rnti != 65521)
    @{list_of_values}    get matched packet in a list with path list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_PAIREDUE}
    FOR      ${ue_packet}     IN      @{list_of_values}
        ${pairedue_value}    ${cur_sfnslot}           Get Value as Dict In Packet Match
        ...                   packetMatch=${ue_packet}
        ...                   field=${FIELDS_PAIREDUE}
        Log to console    ${pairedue_value}
        Log to console    ${cur_sfnslot}
#        Continue For Loop If   '${loop}'=='1'
#        Continue For Loop If   '${prev_sfnslot}[0]'=='${cur_sfnslot}[0]' and '${prev_sfnslot}[1]'=='${cur_sfnslot}[1]'
        ${loop}=     Evaluate    ${loop}+1
        Run Keyword if       '${prev_sfnslot}[0]'=='${cur_sfnslot}[0]' and '${prev_sfnslot}[1]'=='${cur_sfnslot}[1]'
        ...    Append To List   ${pairedue_value}   ${prev_paired_ue}[0]    ${prev_paired_ue}[1]
        Run Keyword if       '${prev_sfnslot}[0]'=='${cur_sfnslot}[0]' and '${prev_sfnslot}[1]'=='${cur_sfnslot}[1]'
        ...    check PairedUe    ${rnti_list}   ${pairedue_value}
        ${prev_sfnslot}=    copy list     ${cur_sfnslot}
        ${prev_paired_ue}=   copy list     ${pairedue_value}
    END
    Run Keyword If    ${loop}==${1}    Log to console   TC Failure due to No ULMU Pairing.
    ${result}=    Evaluate    ${loop}>${1}
    Run Keyword and Continue on Failure    Should Be True    ${result}

Check PairedUe
    [Arguments]     ${rnti_list}    ${pairedue_value}
    ${paired_ue_count}=  Set Variable   ${0}
    FOR  ${element}  IN   @{pairedue_value}
         ${paired_ue_count}=   Check PairedUE List with Rnti List  ${rnti_list}   ${element}   ${paired_ue_count}
    END
    Run Keyword and Continue on Failure    Should Be Equal As Integers     ${paired_ue_count}  ${4}

Check PairedUE List with Rnti List
    [Arguments]     ${rnti_list}  ${pairedue}   ${paired_ue_count}
    FOR   ${rnti_element}   IN   @{rnti_list}
           ${paired_ue_count}=   Set Variable if   ${pairedue}==${rnti_element}   ${paired_ue_count+1}     ${paired_ue_count}
    END
    [Return]   ${paired_ue_count}

#TC42 Keywords

MultiUE Register should be Successful with diff slice
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
       UE Register should be Successful   ue_id=${ue_id}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
       ${nwslice_ID}=      Evaluate       ${nwslice_ID}+1
       ${gw_ID}=      Evaluate       ${gw_ID}+1
    END

Validate DL Traffic For all UEs TC42
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id2}     dl_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id3}     dl_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Validate UL Traffic For all UEs TC42
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

#TC32 Keywords
Change UE location
    [Arguments]    ${ue_id}   ${ue_cell_id}   ${enb_id}
    wtsrunner.ue_change_location   id=${ue_id}   enb=${enb_id}    cell=${ue_cell_id}


Enable ENDC for LTE cell
    [Arguments]    ${cell_id}
    wtsrunner.enb_cell_param   enb=1   id=${cell_id}   allow_endc=on

Perform Intra LTE HO
    [Arguments]    ${nsa_ue_id1}    ${LTE_cell_id2}
    wtsrunner.ue_ho   id=${nsa_ue_id1}   ho_mode=INTRA_LTE   enb=1   cell=${LTE_cell_id2}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_INTRA_HO_egate_message}    ${60}
    Print Matching Lines from Output File    ${output}    ${LTE_INTRA_HO_egate_message}
    Should Contain    ${output}    ${LTE_INTRA_HO_egate_message}    ignore_case=True

Multiple NSA UE Start DL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Trigger High DL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     dl_rate=${dl_rate}       bearer_id=${bearer_id}
        sleep   1s
    END

Multiple NSA UE Start UL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High UL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     ul_rate=${ul_rate}      bearer_id=${bearer_id}
    END

Add new LTE Bearer for Multiple UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${precedence}
     FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Add new LTE Bearer   ${ue_id}    ${bearer_id}   ${precedence}
        ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}
     END

Validate DL UL Traffic For all UEs TC32
    FOR    ${ue_id}    IN RANGE    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}+${1}
        Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${ue_id}     dl_rate=10   id=2
        Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${ue_id}     dl_rate=10   id=7
        Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${ue_id}     ul_rate=10   id=2
        Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${ue_id}     ul_rate=10   id=7
    END

Verify nbrDrbSpecificParams In usersetupreq with nbrdl and nbrul
    [Arguments]      ${logpath}       ${filter_req}     ${nbr_dl_value}    ${nbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${2}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrUl_item$
    ...                                                endPacket=${2}
    Should Contain    ${allowNBR_DL}    ${nbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${nbr_ul_value}

#TC15 Keywords
Validate DL Traffic For all UEs TC15
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id1}     data_rate=30   id=2   dir=dl
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id2}     data_rate=30   id=2   dir=dl
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id1}     data_rate=100   id=7   dir=dl
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id2}     data_rate=100   id=7   dir=dl

Validate Traffic For NSA UE
    [Arguments]    ${ue_id}     ${data_rate}     ${id}=${Bearer_ID}   ${dir}=dl
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    int(${output[0]}) > ${data_rate}
    Run Keyword and continue on Failure     should be true  ${result}

Validate UL Traffic For all UEs TC15
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id1}     data_rate=24   id=2   dir=ul
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id2}     data_rate=24   id=2   dir=ul
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id1}     data_rate=24   id=7   dir=ul
    Run Keyword and continue on Failure   Validate Traffic For NSA UE   ue_id=${TC15_nsa_ue_id2}     data_rate=24   id=7   dir=ul

#TC36 Keywords1
Validate DL Traffic For UEs diff QFI
    [Arguments]    ${de_qfi_data}   ${qfi1_data}   ${qfi2_data}   ${qfi3_data}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${TC36_sa_ue_id1}     dl_rate=${de_qfi_data}
    ...   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${TC36_sa_ue_id1}     dl_rate=${qfi1_data}
    ...   pdu_id=1    qfi_id=${QFI_ID2}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${TC36_sa_ue_id1}     dl_rate=${qfi2_data}
    ...   pdu_id=1    qfi_id=${QFI_ID3}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${TC36_sa_ue_id1}     dl_rate=${qfi3_data}
    ...   pdu_id=1    qfi_id=${QFI_ID4}

Validate UL Traffic For UEs diff QFI
    [Arguments]    ${qfi_data}   ${qfi1_data}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${TC36_sa_ue_id1}     ul_rate=${qfi_data}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${TC36_sa_ue_id1}     ul_rate=${qfi_data}   pdu_id=1    qfi_id=${QFI_ID2}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${TC36_sa_ue_id1}     ul_rate=${qfi1_data}   pdu_id=1   qfi_id=${QFI_ID3}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${Tc36_sa_ue_id1}     ul_rate=${qfi1_data}   pdu_id=1   qfi_id=${QFI_ID4}

TC15_Support_NBR_nonGBR_bearers_setup_with_SgNB_Modification_NSA_both_UL_DL
    Send Delta Commissioning   ${TC15_delta_file_name}
    Enable ENDC for all Bearer
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Start Log    cprt
    Multiple NSA UE Register    ${TC15_nsa_ue_id1}     ${TC15_nsa_ue_id2}    ${TC15_CELL_ID}
    sleep     10s
    ${path1}    Stop Log    cprt   test_scenario=TC15_usersetup
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id2}   100
    Start Log    cprt
    Add new LTE Bearer for Multiple UE    ${TC15_nsa_ue_id1}   ${TC15_nsa_ue_id2}    7     7
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id2}   7    500
    sleep   60s
#Due to AP restrcition on bearer stats output, checking ue_stats
    Validate DL Traffic For all UEs TC15
    Validate PDSCH UE Stats for Given CC    ue_id=${TC15_nsa_ue_id1}  scell_idx=8   dl_data_rate=507
    Validate PDSCH UE Stats for Given CC    ue_id=${TC15_nsa_ue_id2}  scell_idx=8   dl_data_rate=507
    Stop Data Traffic for NSA    ${TC15_nsa_ue_id1}
    Stop Data Traffic for NSA    ${TC15_nsa_ue_id2}
    sleep   5s
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id2}   50
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id2}   7    80
    sleep   60s
#Due to AP restrcition on bearer stats output, checking ue_stats
    Validate UL Traffic For all UEs TC15
    Validate PUSCH UE Stats for Given CC    ue_id=${TC15_nsa_ue_id1}  scell_idx=8   ul_data_rate=58
    Validate PUSCH UE Stats for Given CC    ue_id=${TC15_nsa_ue_id2}  scell_idx=8   ul_data_rate=58
    Stop Data Traffic for NSA    ${TC15_nsa_ue_id1}
    Stop Data Traffic for NSA    ${TC15_nsa_ue_id2}
    Multiple NSA UE Register    ${TC15_nsa_ue_id3}     ${TC15_nsa_ue_id4}    ${TC15_CELL_ID}
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id4}   10
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id4}   10
    Add new LTE Bearer for Multiple UE    ${TC15_nsa_ue_id3}   ${TC15_nsa_ue_id4}    7     7
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id4}   7    10
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${TC15_nsa_ue_id1}    ${TC15_nsa_ue_id4}   7    10
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${TC15_CELL_ID}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  1800  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  1800  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${TC15_CELL_ID}
    ...  file_path=${pm_counter_file}

TC32_Support_NBR_nonGBR_bearers_for_Intra-DU_PSCell_change_procedure_NSA
#Perform Delta changes with maxNumOfNbrBearers set to "0"
    Send Delta Commissioning    ${TC32_delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for LTE cell    ${LTE_cell_id1}
    Enable ENDC for LTE cell    ${LTE_cell_id2}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Multiple NSA UE Register    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id1}   ${TC32_nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs TC32
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  4  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  0  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Wait until the next Measurement Period starts
    Start Log    cprt
    Perform Intra LTE HO    ${TC32_nsa_ue_id1}    ${LTE_cell_id2}
    ${path1}    Stop Log    cprt   test_scenario=LTE_INTRA_HO_max_nbr_bearer_0
##  Validate CPRT logs for UE context modification with NBR IE for sgnb modification for Inter MeNB INTRA cell HO
    Verify nbrDrbSpecificParams In usersetupreq with nbrdl and nbrul   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp     ${TC32_nbr_dl_value}
    ...    ${TC32_nbr_ul_value}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  3600  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  3600  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Validate DL UL Traffic For all UEs TC32
    Multiple NSA UE Detach    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}
## Set maxNumOfNbrBearers to 2
    Send Delta Commissioning    ${TC32_delta_file_name1}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Change UE location    ${TC32_nsa_ue_id1}   ${1}    ${LTE_cell_id1}
    Multiple NSA UE Register    ${TC32_nsa_ue_id1}     ${TC32_nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${TC32_nsa_ue_id1}   ${TC32_nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${TC32_nsa_ue_id1}    ${TC32_nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs TC32
    Perform Intra LTE HO    ${TC32_nsa_ue_id1}    ${LTE_cell_id2}
#    Wait until the next Measurement Period starts
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter3
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Validate DL UL Traffic For all UEs TC32


Successful_early_DRX_setup_for_UE_in_SA_mode_during_RRC_Inactive_to_RRC_Connected_transition_FDD
    Send Delta Commissioning    ${CB013233_A_delta_file_name}
    Log to console    "waiting until the next Measurement Period starts..."
    Wait until the next Measurement Period starts
#Step 1: Attach UE and check for Early DRX steup in UE contextsetup and start Data traffic
    log to console   "SA UE attach "
    Start Log    cprt
    sleep    2s
    Set AMF core network assistance info   ue_id=${CB013233_sa_ue_id1}
    ${sa_ue_id1_rnti}=  UE Register should be Successful And Fetch RNTI    ${CB013233_sa_ue_id1}
    sleep     2s
    ${path1}    Stop Log    cprt   test_scenario=CB013233_usersetup
    Verify DRXcycle in F1AP_UEContextSetupRequest   ${path1}[cprt]/NODECPRT_GNB.pcap   ${sa_ue_id1_rnti}
    ${ue_id1_gnb_cu_id}=    Get gnb CU UEID from CRNTI   ${path1}[cprt]/NODECPRT_GNB.pcap   ${sa_ue_id1_rnti}
    Trigger DL Traffic SA   ue_id=${CB013233_sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger UL Traffic SA   ue_id=${CB013233_sa_ue_id1}    ul_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   10s
#    Validate DL Traffic For SA   ue_id=${CB013233_sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
#    Validate UL Traffic For SA   ue_id=${CB013233_sa_ue_id1}    ul_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Validate PDSCH UE Stats for Given CC    ue_id=${CB013233_sa_ue_id1}  scell_idx=0   dl_data_rate=150
    Validate PUSCH UE Stats for Given CC    ue_id=${CB013233_sa_ue_id1}  scell_idx=0   ul_data_rate=110
    sleep   10s
#Step2: Stop data traffic and check for UE moves to Inactive state
    Start Log    cprt
    ${inactive_time_start}=    Stop data and get timestamp for UE    ue_id=${CB013233_sa_ue_id1}
    Sleep till inactivity timer expiry
    ${inactive_time_stop}=     Check UE RRC State Inactive and get Timestamp   ue_id=${CB013233_sa_ue_id1}
    Verify UE stats   ue_id=${CB013233_sa_ue_id1}   state=UE_INACTIVE
    ${path2}    Stop Log    cprt   test_scenario=rrcinactive
#Step3: Start DL data for paging and RRC Resume. Check DRX is configured as part of RRCresume in UE contextsetup request
    Start Log    cprt
    Trigger RRC Resume for RANPaging with DL Data   ue_id=${CB013233_sa_ue_id1}
    ${path3}    Stop Log    cprt   test_scenario=rrcresume
    Verify DRXcycle in F1AP_UEContextSetupRequest with gnb_cu_ueid    ${path3}[cprt]/NODECPRT_GNB.pcap   ${ue_id1_gnb_cu_id}
    Validate DL Traffic For SA   ue_id=${CB013233_sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
#Step4: Verify counters for RRC Inactive and DRX
    Wait until the current Measurement Period stops
    sleep   60s
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File Classical   output_dirpath=${OUTPUT DIR}/pmcounter1
#    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55124C00010  1  NRRCC_RRC_RESUME_SUCC
    ...  M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >1000   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CB013233_CELL_ID}
    ...  file_path=${pm_counter_file}

Verify DRXcycle in F1AP_UEContextSetupRequest with gnb_cu_ueid
    [Arguments]   ${drx_cprt_pcap}   ${gnb_cu_ueid}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${gnb_cu_ueid}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ueid}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)


Set AMF core network assistance info
    [Arguments]   ${ue_id}
    wtsrunner.amf_ue_ics_param       id=1         ue=${ue_id}
    ...     trace_activation=on    trace_plmn=311:489     trace_ref_id=1     trace_rec_session_ref_id=1
    ...     trace_depth=minimum     ifaces_to_trace=NG-C     tce_ip=10.0.1.1
    ...     core_network_assistance_info=on     ue_identity_index_value=1     ue_specific_drx=64
    ...     periodic_registration_update_timer=1:1min       plmn_id=311:489     tac_id=200

Trigger RRC Resume for RANPaging with DL Data
    [Arguments]   ${ue_id}
    Log to console   "Trigger DL data for RRC Resume"
    sleep   10s
    wtsrunner.trf_data_start    ue=${ue_id}   pdu=${Pdu_session_ID}   qfi=${QFI_ID}    trf_id=1  dir=dl   mbps=150
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Started Downlink Internal traffic Receiver   timeout=10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-onDurationTimer    partial_match=${TRUE}
    should contain   ${output1}   ms10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-InactivityTimer    partial_match=${TRUE}
    should contain   ${output1}   ms80
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerDL    partial_match=${TRUE}
    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerUL    partial_match=${TRUE}
    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-LongCycleStartOffset     partial_match=${TRUE}
    should contain   ${output1}   ms160
    ${output1}         Get Lines Matching Regexp    ${output}    drx-SlotOffset    partial_match=${TRUE}
    should contain   ${output1}   0
    should contain   ${output}   rrcResumeComplete
    should not contain   ${output}   rrcReconfiguration

Sleep till inactivity timer expiry
    Log to Console          Wait ${drb_inactivity_timer}s for UE to move inactive state
    sleep   ${drb_inactivity_timer}s
    sleep   ${delta}s       #add extra delta

Stop data and get timestamp for UE
    [Arguments]   ${ue_id}
    wtsrunner.trf_data_stop     ue=${ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID}   trf_id=1  dir=bi
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Stopped*    timeout=10
    ${time}         Get Lines Matching Regexp    ${output}     UPF-1: Stop       partial_match=${TRUE}
    ${time}    Split String      ${time}      ${SPACE}
    [Return]      ${time}

Verify UE stats
    [Arguments]   ${ue_id}   ${state}
    Log to console   "chekcing UE stats"
    wtsrunner.ue_disp    id=${ue_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Security    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    state   partial_match=${TRUE}
    Should Contain    ${output}   ${state}
    Log to Console    UE: ${ue_id} moved to ${state} state

Check UE RRC State Inactive and get Timestamp
    [Arguments]    ${ue_id}
    Log to console    "waiting for rrcRelease with suspendConfig for UE to move to inactive state"
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Is INACTIVE    timeout=100
    Log to console   ${output}
    ${output1}         Get Lines Matching Regexp    ${output}    UE${ue_id}: Is INACTIVE    partial_match=${TRUE}
    Log to console   ${output1}
    ${time}    Split String      ${output1}      ${SPACE}
    Log to console   ${time}
    [Return]    ${time}

Verify DRXcycle in F1AP_UEContextSetupRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ue_id}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)

Get gnb CU UEID from CRNTI
    [Arguments]      ${logpath}       ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       (3gpp.rnti == ${crnti}) && (itf_l2_ps_user_bearersetupreq)
    ${cu_ue_id}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearersetupreq
    ...                                                path=.*ueIdCu$
    ...                                                endPacket=${1}
    [Return]   ${cu_ue_id}

Verify DRXcycle in F1AP_ICS
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ue_id}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)

Verify partial DRB admitted
    [Arguments]   ${drx_cprt_pcap}
    [Documentation]      This KW Verifies the Partial DRB admitted in PDU session
    log to console       Checking Partial DRB admitted in PDU session
    ${pdu_fail} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}   (ngap.id == 54)
    ${pdu_fail1}    analyzer.get_shownames            pdmlFile=${pdu_fail}
    ...                             packetName=PDUSessionResourceModifyResponse
    ...                             kind=showname
    ...                             path=.*radioNetwork$
    ...                             endPacket=1
    Should Be True    ${pdu_fail1} == ['radioNetwork: invalid-qos-combination (23)']

Register non-CA UE${sa_ue_id} with multiple bearer traffic
    log to console   non-CA UE${sa_ue_id} attach trigerring now...
    ${crnti_1}   UE Register should be Successful And Fetch RNTI   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
#Attach dedicated non-GBR bearer (5QI-7)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID2}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID2}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
#Attach dedicated GBR bearer (5QI-2)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID3}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID3}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_not_started
#Attach dedicated GBR bearer (5QI-3)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID4}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID4}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Can not start UL/DL traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Provided pdu and qfi combinations does not exist for this UE    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_not_started
    set suite variable   ${crnti_1}

Check ue stats Avg Data rate
    [Arguments]    ${data_rate}   ${exp_data_rate}    ${dir}
    ${result}         Evaluate    (${exp_data_rate} * 1.1) > ${data_rate} > (${exp_data_rate} * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${data_rate}
    ...               ELSE    Log to Console     ${dir} Average data rate: ${data_rate}   Expected data rate: ${exp_data_rate}   level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Validate PDSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0   ${dl_data_rate}=0
    ${dl_avg_rate}=    Get AVG DL DATA TRAFFIC For Given CC    ${ue_id}   ${scell_idx}
    Check ue stats Avg Data rate   ${dl_avg_rate}   ${dl_data_rate}    DL

Validate PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0   ${ul_data_rate}=0
    ${ul_avg_rate}=    Get AVG UL DATA TRAFFIC For Given CC    ${ue_id}   ${scell_idx}
    Check ue stats Avg Data rate   ${ul_avg_rate}   ${ul_data_rate}   UL

Validate PDSCH Multi UE Stats for Given CC
    [Arguments]   ${start_ue_id}   ${end_ue_id}   ${dl_data_rate}=0   ${scell_idx}=0
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
            Validate PDSCH UE Stats for Given CC     ${ue_idx}   ${scell_idx}   ${dl_data_rate}
    END

Validate PUSCH Multi UE Stats for Given CC
    [Arguments]   ${start_ue_id}   ${end_ue_id}   ${ul_data_rate}=0    ${scell_idx}=0
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
            Validate PUSCH UE Stats for Given CC    ${ue_idx}   ${scell_idx}   ${ul_data_rate}
    END

CB008227-E_B7_TC57_NBR_interworking_with_MU_MIMO_UL
    Send Delta Commissioning    ${TC57_delta}
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    ${rnti_list}   MultiUE Register should be Successful    ${TC57_sa_ue_id1}     ${TC57_sa_ue_id4}
    sleep     2s
    Log to console   ${rnti_list}
    Add new Bearer for Multiple SA UE    ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID5}
    Add new Bearer for Multiple SA UE    ${TC57_sa_ue_id3}    ${TC57_sa_ue_id3}    ${Pdu_session_ID}    ${QFI_ID5}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id1}    ${TC57_sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id2}    ${TC57_sa_ue_id2}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id3}    ${TC57_sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${TC57_sa_ue_id4}    ${TC57_sa_ue_id4}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   60s
#Validate all UE thput before MIMO position is activated
    Validate UL Traffic For all UEs   52   8   52   8
    Set And Activate Srs beam position   ${TC57_sa_ue_id1}
    sleep   60s
#Validate all UE thput After MIMO position is activated
    Validate UL Traffic For all UEs   109   109   109    109
#   Validate UL MuMIMO Pairing either in TTI or BIP traces
    Start Log   biptaf
    Sleep   10s
    ${bip_path1}   Stop Log    biptaf    test_scenario=UL_MuMIMO
    Verify UE Pairing     ${bip_path1}[biptaf]/BIP_L1L2.pcap   ${rnti_list}
#Check Counters
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  M55139C03510  600  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}

Fetch PM counter value
    ${pi_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}
    ${pi_list}=  Create List  M55308C17001
    ${actual_pm_values}=  Get Counter Value   ${pi_dir}   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   ${pi_list}
    [Return]    ${actual_value}

CNI-105919#B3_TC4_UE_Release_on_PDCP_PDU_discards_due_to_the_RoHC_decompression_failures_with_Multiple_Ues_multiple_DRB
    Send Delta Commissioning    ${CNI_105919_delta_file_1}
    Set HFN Desyn on AP    ${105919_sa_ue_id1}   ${9}
    Set HFN Desyn on AP    ${105919_sa_ue_id2}   ${9}
    Set HFN Desyn on AP    ${105919_sa_ue_id3}   ${9}
    Wait until the next Measurement Period starts
    log to console   "UE attach trigerring now"
#Step 1. Attach multiple SA UE-1 cell-1 and Start UL Data Traffic
    Start Log    cprt
    MultiUE Register should be Successful   ${105919_sa_ue_id1}    ${105919_sa_ue_id6}
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=1   qosflows_to_add=5
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=1   qosflows_to_add=6
    MultiUE PDU Addition should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   nw_id=1
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   qosflows_to_add=5
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   qosflows_to_add=6
    ${path1}    Stop Log    cprt   btslog   test_scenario=ue_register
    Start Log    cprt   btslog
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=3
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=3
    sleep   60s
    wtsrunner.ue_summary
    wtsrunner.ue_summary
    ${path2}    Stop Log    cprt   btslog   test_scenario=ue_release
    Run Keyword and continue on Failure   Check UE release in egate    ${105919_sa_ue_id1}
    Run Keyword and continue on Failure   Check UE release in egate    ${105919_sa_ue_id2}
    Run Keyword and continue on Failure   Check UE release in egate    ${105919_sa_ue_id3}
    Run Keyword and continue on Failure   Check HFN release in syslog  3   ${HFN_DecipheredPackets_pattern}   ${path2}
    MultiUE Deregister should be Successful   ${105919_sa_ue_id1}    ${105919_sa_ue_id6}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_HFN_DESYNC
    Verify Any Counters In File
    ...  M55350C00032  3  HFN_SN_DESYNC_DETECT_DRB
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    sleep  60s
#Perform delta commissioning with VONR and ROHC enabled
    Send Delta Commissioning    ${CNI_105919_delta_file_2}
    Set HFN Desyn on AP    ${105919_sa_ue_id1}   ${6}
    Set HFN Desyn on AP    ${105919_sa_ue_id2}   ${6}
    Set HFN Desyn on AP    ${105919_sa_ue_id3}   ${6}
#Step 1. Attach multiple SA VONR and Start UL Data Traffic
    Wait until the next Measurement Period starts
    Start Log    cprt   btslog
    MultiUE Register should be Successful   ${105919_sa_ue_id1}    ${105919_sa_ue_id6}
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=1   qosflows_to_add=2
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=1   qosflows_to_add=3
    MultiUE PDU Addition should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   nw_id=1
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   qosflows_to_add=5
    MultiUE PDU Modfication should be Successful    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   pdu_id=2   qosflows_to_add=6
    ${path3}    Stop Log    cprt   btslog   test_scenario=rohc_ue_register
    Start Log    cprt    btslog
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=3
    MultiUE Trigger UL Traffic for SA    ${105919_sa_ue_id1}    ${105919_sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=3
    sleep   60s
    ${path3}    Stop Log    cprt   btslog  test_scenario=rohc_ue_release
    ${105919_sa_ue_id1_AMF}   Evaluate   ${105919_sa_ue_id1}+${11}
    ${105919_sa_ue_id2_AMF}   Evaluate   ${105919_sa_ue_id2}+${11}
    ${105919_sa_ue_id3_AMF}   Evaluate   ${105919_sa_ue_id3}+${11}
    Run Keyword and continue on Failure    Check UE release in egate    ${105919_sa_ue_id1_AMF}
    Run Keyword and continue on Failure    Check UE release in egate    ${105919_sa_ue_id2_AMF}
    Run Keyword and continue on Failure    Check UE release in egate    ${105919_sa_ue_id3_AMF}
    Run Keyword and continue on Failure   Check HFN release in syslog  3   ${HFN_DecompressedPackets_pattern}   ${path3}
    MultiUE Deregister should be Successful   ${105919_sa_ue_id1}    ${105919_sa_ue_id1}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_HFN_DESYNC
    Verify Any Counters In File
    ...  M55350C00032  3  HFN_SN_DESYNC_DETECT_DRB
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}

Set HFN Desyn on AP
    [Arguments]     ${ue_id}    ${drb_id}
    wtsrunner.ue_pdcp_hfn_desync_testmode   ue_id=${ue_id}   num_of_normal_pkts=1000   hfn_jump_count=100   sn_jump_count=2000
    ...  num_of_invalid_pkts=20000   drb_id=${drb_id}

Check UE release in egate
    [Arguments]     ${ue_id}   ${count}=1
    ${output}   Run    grep -ci "UE CONTEXT RELEASE REQUEST: gNB=2, AMF_UE_NGAP_ID=${ue_id}" /opt/iphy/latest/egate_console.log
    Should contain   ${output}   ${count}

Check HFN release in syslog
    [Arguments]     ${count}   ${pattern}   ${path}
    ${output}   Run    grep -ci ${pattern} ${path}[btslog]/gnb_syslog.log
    Should contain   ${output}   ${count}

MultiUE Trigger High DL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    FOR   ${id}  IN RANGE   ${start_ue_id}    ${end_ue_id}+1
        Trigger High DL Traffic SA    ${id}    ${dl_rate}   ${pdu_id}   ${qfi_id}
    END


#CB006877_TC37 Keywords

Verify prbs in uldata_puschreceivereq_prb_blank
    [Arguments]     ${pcapFile}   ${nbrOfBlankedPRBsLowEdgeUL}    ${cell_subgroup_id}
    ${pdmlFile}=         Get filtered PDML file from pcap    ${pcapFile}     (uldata_puschreceivereq) && (3gpp.subcellid == ${cell_subgroup_id})
    @{list_of_values}    Get Packet Match List     ${pdmlFile}   uldata_puschreceivereq    ${pathlist}
    ...                  ${filter}   ${1}   ${1000}
    ${total_uldata_pusch}   get length   ${list_of_values}
    FOR      ${prb_packet}     IN      @{list_of_values}
        Get Value In Match Packet PRB Blank     ${prb_packet}     startPrb    ${nbrOfBlankedPRBsLowEdgeUL}
    END

Get Value In Match Packet PRB Blank
    [Arguments]      ${packetMatch}   ${field}   ${blanked_prbs}   ${kind}=show
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            ${startprb}=   Run Keyword if     '${fieldName}'=='${field}'   Set Variable   ${packetMatch.fields['${path}'].${kind}}
            ${startprb}=    convert to integer      ${startprb}
            Should be True   ${startprb} > ${blanked_prbs}
    END

Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    [Arguments]
    ...      ${pcapFile}   ${cell_id}    ${bwp_id}
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}    syscom
    ${pathlist}    Create List     longPucchStartPuschPrb_item    longPucchNumPuschPrb_item
    ...      longPucchStartDynPuschPrb_item   longPucchNumDynPuschPrb_item
    ...      itf_l2_ps_cell_CellSetupReq_t.lcrId   itf_l2_ps_cell_Bwp.bwpType
    @{list_of_values}    Get Packet Match List     ${pdmlFile}     itf_l2_ps_cell_cellsetupreq
    ...                  ${pathlist}
    FOR   ${prb_packet}     IN      @{list_of_values}
            ${list}   Get Value in Match Packet for PUCCH PRB Blank    ${prb_packet}   ${cell_id}    ${bwp_id}
            Exit For Loop IF   ${list[4]} == ${cell_id}
    END
#   List 0, 1, 2, 3 ==> StaticStartPuschPrb, StaticNumPuschPrb, DynStartPuschPrb ,DynNumPuschPrb
#   Condition is  ${StartDynPuschPrb} < ${StartPuschPrb}   and ${NumDynPuschPrb} > ${NumPuschPrb}
    Run Keyword and continue on Failure    should be true  ${list[2]} < ${list[0]}
    Run Keyword and continue on Failure    should be true  ${list[3]} > ${list[1]}
    [Return]      ${list[0]}    ${list[2]}

Get Value in Match Packet for PUCCH PRB Blank
    [Arguments]    ${packetMatch}   ${cell_id}     ${bwp_id}
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    ${packet_bwpid}=    Set Variable   'None'
    ${packet_DynStartPuschPrb}=     Set Variable    'None'
    ${packet_DynNumPuschPrb}=     Set Variable      'None'
    ${packet_StaticStartPuschPrb}=    Set Variable   'None'
    ${packet_StaticNumPuschPrb}=     Set Variable    'None'
    FOR   ${path}  IN   @{listPath}
        ${fieldName}            Get Field Name From Path            ${path}
        ${packet_lcrid}=        Set Variable if     '${fieldName}'=='lcrId'    ${packetMatch.fields['${path}'].show}   ${packet_lcrid}
        ${packet_bwpid}=        Set Variable if     '${fieldName}'=='bwpType'   ${packetMatch.fields['${path}'].show}   ${packet_bwpid}
        ${packet_DynNumPuschPrb}=     Set Variable if     '${fieldName}'=='bwpType'   None
        ${packet_StaticStartPuschPrb}=    Set Variable if     '${fieldName}'=='longPucchStartPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}    ${packet_StaticStartPuschPrb}
        ${packet_StaticNumPuschPrb}=     Set Variable if     '${fieldName}'=='longPucchNumPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}   ${packet_StaticNumPuschPrb}
        ${packet_DynStartPuschPrb}=    Set Variable if     '${fieldName}'=='longPucchStartDynPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}   ${packet_DynStartPuschPrb}
        ${packet_DynNumPuschPrb}=     Set Variable if     '${fieldName}'=='longPucchNumDynPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}      ${packet_DynNumPuschPrb}
        ${condition_flag}     Run Keyword if
        ...      ${packet_lcrid} == ${cell_id} and ${packet_bwpid} == ${bwp_id} and ${packet_DynNumPuschPrb} != None
        ...      Set Variable  TRUE
        Exit For Loop IF      '${condition_flag}' == 'TRUE'
    END
    [Return]   ${packet_StaticStartPuschPrb}   ${packet_StaticNumPuschPrb}   ${packet_DynStartPuschPrb}
    ...   ${packet_DynNumPuschPrb}   ${packet_lcrid}

MultiUE Trigger Bursty DL Traffic for SA
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${period_ms}   ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}
    ...    period_ms=${period_ms}    ${Traffic_rate}=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully


MultiUE Trigger Bursty UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}   ${period_ms}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}
    ...    period_ms=${period_ms}    ${Traffic_rate}=${ul_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    END
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Verify DRXcycle in F1AP_UEContextSetupRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
         Verify DRXcycle in F1AP_UEContextSetupRequest   ${cprt_pcap}   ${rnti}
    END

Verify DRXcycle in F1AP_UEContextModificationRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
        Verify DRXcycle in F1AP_UEContextModificationRequest    ${cprt_pcap}    ${rnti}  longDRXCycleLength: ms40 (3)
    END

Verify DRXrelease in F1AP_UEContextModificationRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
        Verify DRXrelease in F1AP_UEContextModificationRequest   ${cprt_pcap}   ${rnti}
    END

MultiUE Register should be Successful with DRX
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}   Read WTS Output Until Pattern Matches    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${output1}         Get Lines Matching Regexp    ${output}    drx-onDurationTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-InactivityTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms100
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerDL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerUL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-LongCycleStartOffset     partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms160
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

Verify DRXrelease in F1AP_UEContextModificationRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXrelease IE in F1AP_UEContextModificationRequest
    Log to console       Checking DRXRelease IE in F1AP_UEContextModificationRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   ((f1ap.procedureCode == 7) && (f1ap.GNB_CU_UE_F1AP_ID == ${gnb_cu_ue_id}) && (f1ap.DRXConfigurationIndicator == 0))
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.DRXConfigurationIndicator
    ...                             kind=showname
    ...                             value=DRXConfigurationIndicator: release (0)

Verify DRXcycle in F1AP_UEContextModificationRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}   ${longDRXCycleLength}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextModificationRequest
    log to console       Checking DRXCycle IE In F1AP_UEContextModificationRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   ((f1ap.procedureCode == 7) && (f1ap.GNB_CU_UE_F1AP_ID == ${gnb_cu_ue_id}))
       analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=${longDRXCycleLength}

