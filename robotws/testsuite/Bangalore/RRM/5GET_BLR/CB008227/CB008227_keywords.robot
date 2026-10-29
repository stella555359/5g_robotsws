*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Library           ../resources/python/CPRT_Capture.py
Resource         ../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/BBpooling_MuMIMO.robot
Library          ../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String
Library        ./resource/verify_rnti_bwpid.py

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_AEHC.cfg
${wts_cfg_file_TC40}     ${CURDIR}/config/wts_DA_PDCCH_AEHC.cfg
${wts_cfg_file_TC49}     ${CURDIR}/config/wts_NSA_CA_NBR.cfg
${wts_cfg_file_TC55}     ${CURDIR}/config/mBWP_nbr_wts.cfg
${wts_cfg_file_TC56}     ${CURDIR}/config/wts_DL_MUMIMO_Enc.cfg
${wts_cfg_file_TC64}     ${CURDIR}/config/3bwp_tdd_wts.cfg
${wts_cfg_file_TC31}     ${CURDIR}/config/wts_aehc_new.cfg
${wts_cfg_file_TC19}     ${CURDIR}/config/wts_AEHC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${ue_id1}      1
${ue_id2}      2
${ue_id3}      3
${ue_id4}      4
${start_ue_id}    1
${end_ue_id}      4
${sa_ue_id1}      1
${sa_ue_id2}      2
${sa_ue_id3}      3
${sa_ue_id4}      4
${nsa_ue_id}      11
${nsa_ue_id1}      11
${nsa_ue_id2}      ${12}
${nsa_ue_id3}      ${13}
${nsa_ue_id4}      ${14}
${nsa_ue_id49}      ${16}
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
${cell_id_TC56}   50
${CELL_ID}    1
${CELL_ID1}    1
${CELL_ID2}    2
${no_of_cells}   2
${no_of_cells_1}   1
${epc_log_path}    /tmp/
${IPHY_FILE}     ${CURDIR}/config/iphy_AEHC.xml
${IPHY_FILE_TC49}     ${CURDIR}/config/iphy_NSA_CA.xml
${IPHY_FILE_TC55}     ${CURDIR}/config/mBWP_NBR_iphy.xml
${IPHY_FILE_TC56}     ${CURDIR}/config/iphy_AEQE_DL_MUMIMO_Enc.xml
${IPHY_FILE_TC64}     ${CURDIR}/config/3bwp_tdd_iphy.xml
${IPHY_TC31}   ${CURDIR}/config/iphy_ASOH_AEHC.xml
${IPHY_TC19}   ${CURDIR}/config/iphy_ASOH_AEHC.xml
${scf_TC31}   CB008227_IntraDU_IntragNB_scf_100M_feature_on_ASOH.xml
${scf_TC19}   CB008227_fullcommissioning_scf_ASOH.xml
${scf_TC20}   CB008227_FR1_TDD_60mhz_scf_off.xml
${scf_TC23}     CB008227_FR1_TDD_HPA.xml
${scf_TC28}     CB008227_IntergNB_HO_scf_100M_feature_on.xml
${scf_TC2}   CB008227_fullcommissioning_scf.xml
${scf_TC40}   CB008227_DA_FR1_TDD_PDCCH_scf.xml
${scf_TC49}   SCF_NSA_CA_NBR.xml
${scf_TC55}   mBWP_NBR_scfc.xml
${scf_TC56}   CB008227_FR1_TDD_DL_MUMIMO_ENC_scf.xml
${scf_TC64}   3bwp_tdd_scf.xml
${delta_commissioning_on_json}    Delta_CB008227_act.json
${delta_commissioning_off_json}    Delta_CB008227_deact.json
${Enable_congweight_json}    Enable_congweight.json
${Disable_congweightjson}    Disable_congweight.json
${FIELDS}    (itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.muStatus == 0x15)
${LTE_Bearer_creation_success_TC49}        Bearer-.* .*EBI=.*Q\nCI=.*.* created

#TC57 Variables
${SCFC_TC57}=      ${CURDIR}/config/TC57_SCFC_UL_MuMIMO_GMC.xml
${AP_XML_TC57}=    ${CURDIR}/config/TC57_IPHY.xml
@{FIELDS_PAIREDUE}    pairedUe   sfn  slot
${BSR_SW_FILE}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
${wts_cfg_file_TC57}=   ${CURDIR}/config/TC57_basic_setup.cfg
${TC57_sa_ue_id1}      ${1}
${TC57_sa_ue_id2}      ${2}
${TC57_sa_ue_id3}      ${3}


#TC42 Variables
${SCFC_TC42}=        ${CURDIR}/config/TC42_SCFC_SLICE_NBR.xml
${AP_XML_TC42}=      ${CURDIR}/config/TC42_IPHY.xml
${wts_cfg_file_TC42}=     ${CURDIR}/config/TC42_basic_setup_3PLMN.cfg

#TC32 Variables
${wts_cfg_file_TC32}     ${CURDIR}/config/TC32_basic_setup.cfg
${TC32_nsa_ue_id1}      ${101}
${TC32_nsa_ue_id2}      ${102}
${TC32_nsa_ue_id3}      ${103}
${TC32_nsa_ue_id4}      ${104}
${TC32_delta_file_name}=        TC32_Enable_NBR_maxNumOfNbrBearers_0.json
${TC32_delta_file_name1}=       TC32_maxNumOfNbrBearers_2.json
${TC32_revert_delta}=           TC32_Disable_NBR.json

${LTE_cell_id1}    1
${LTE_cell_id2}    2
${LTE_INTRA_HO_egate_message}    Intra-eNB handover from ENB-1.1 to ENB-1.2 perfo\nrmed
${TC32_nbr_dl_value}    400
${TC32_nbr_ul_value}    80

#TC15 Variables
${wts_cfg_file_TC15}     ${CURDIR}/config/TC15_TC27_basic_setup.cfg
${TC15_delta_file_name}    Enable_NBR_TC15_TC27.json

#TC36 Variables
${wts_cfg_file_TC36}     ${CURDIR}/config/TC32_ASOH_basic_setup.cfg
${TC36_sa_ue_id1}      ${51}
${TC36_sa_ue_id2}      ${52}
${TC36_sa_ue_id3}      ${53}
${TC36_sa_ue_id4}      ${54}
${TC36_delta_file_name}=   Enable_NBR_Congestion_TC36_ASOH.json
${TC36_revert_delta}=      TC36_Disable_NBR.json
${TC36_CELL_ID}       3

#TC8 Variables
${wts_cfg_file_TC8}     ${CURDIR}/config/wts_AHLOA.cfg
${IPHY_TC8}             ${CURDIR}/config/iphy_AHLOA_ASOH.xml
${scf_TC8}              CB008227_FR1_FDD_TC8_ASOH.xml

*** Keywords ***
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
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id4}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
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
    Multiple NSA UE Register    ${ue_id1} 	  ${ue_id2}
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
        Trigger DL Traffic for NSA   ${ue_id}   mbps   150    ${qci}
        sleep   2s
        Trigger UL Traffic for NSA   ${ue_id}   mbps   50    ${qci}
    END

Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Start Log    cprt
    log to console   UE attach trigerring now...
    #Multi UE registration and no rach validation
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${3}+1
    ${rnti}     UE Registered Successfully & Rach validation TC55      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    END
    ${crnti}     UE Register should be Successful And Fetch RNTI    ue_id=4
    #PDU session modification for UE4
    NBR_QFI2   4
    Append To List    ${crnti_list}   ${crnti}
    set suite variable    ${crnti_list}
    Sleep    1s
    #UE1 MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE DUE TO LOW DATA
    MultiUE Trigger DL Traffic for SA    1   1    Traffic_rate=kbps    dl_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   1    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID}

    #UE2 MOVING FROM LARGE  BWP PROFILE TO SMALL BWP PROFILE
    MultiUE Trigger DL Traffic for SA    2   2    Traffic_rate=kbps    dl_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID4}
    MultiUE Trigger UL Traffic for SA    2   2    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID4}
    MultiUE Trigger DL Traffic for SA    2   2    Traffic_rate=kbps    dl_rate=10   trf_id=${TRF_ID}    qfi_id=${QFI_ID5}
    MultiUE Trigger UL Traffic for SA    2   2    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID5}

    #UE3 MOVING TO SBWP DUE TO HIGH DATA
    MultiUE Trigger DL Traffic for SA    3   3    Traffic_rate=mbps   dl_rate=50    trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger UL Traffic for SA    3   3    Traffic_rate=mbps   ul_rate=50    trf_id=${TRF_ID}    qfi_id=${QFI_ID2}

    #UE4 MOVING TO LBWP
    MultiUE Trigger DL Traffic for SA    4   4    Traffic_rate=mbps     dl_rate=170     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger DL Traffic for SA    4   4    Traffic_rate=mbps     dl_rate=170     trf_id=${TRF_ID2}    qfi_id=${QFI_ID3}
    MultiUE Trigger UL Traffic for SA    4   4    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger UL Traffic for SA    4   4    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID2}    qfi_id=${QFI_ID3}
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    2    1
    Stop Log   cprt
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

UE Registered Successfully & Rach validation TC55
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
    ...     bwp-Id\\s2.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    Run Keyword if   ${ue_id}==2   VoNR_QFI   2
    Run Keyword if   ${ue_id}==3   NBR_QFI TC55   3
    [Return]      ${crnti_string}

NBR_QFI TC55
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s

NBR_QFI2
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

VoNR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=4   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=5   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_del=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_del=3   by=amf

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Verify PSBWP through TTI trace TC55
    ${bwpid}    Create List     3    3    2    1
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    mBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}

Validate Throughput For UEs TC55
    Validate DL UL Throughput For UE   1   1   1   0.01   0.01
    Validate DL UL Throughput For UE   2   1   4   0.01   0.01
    Validate DL UL Throughput For UE   3   1   2   50   50
    Validate DL UL Throughput For UE   4   1   2   170   50
    Validate DL UL Throughput For UE   4   1   3   170   50

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
    wtsrunner.ue_srs_beam_pos_nr    profile_id=1    srsMode=fixed    init_pos=1
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ue_srs_beam_pos    action=activate    profile_id=1
    wtsrunner.ue_srs_beam_pos_nr    profile_id=2    srsMode=fixed    init_pos=3
    wtsrunner.ue_testmode_set_nr    id=2    testmode=ue_srs_beam_pos    action=activate    profile_id=2

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

Deregister UEs TC56
    FOR    ${ueid}    IN RANGE    ${ue_id1}    ${ue_id2}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

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
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    3BWP    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

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

NBR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

Verify PSBWP through TTI trace
    ${bwpid}    Create List     2    1   3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    mBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}

Validate Throughput For UEs
    Validate DL UL Throughput For UE   1   1   1   35   25
    Validate DL UL Throughput For UE   1   1   2   35   23
    Validate DL UL Throughput For UE   1   1   3   35   25
    Validate DL UL Throughput For UE   2   1   1   33   22
    Validate DL UL Throughput For UE   2   1   2   32   25
    Validate DL UL Throughput For UE   2   1   3   31   25
    Validate DL UL Throughput For UE   3   1   1   32   25
    Validate DL UL Throughput For UE   3   1   2   31   25
    Validate DL UL Throughput For UE   3   1   3   29   25

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
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID2}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END

Set And Activate Srs beam position
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=2   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${first_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=2   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=3   mode=fixed   init_quad_pos=1   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${first_ue_id+1}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=3   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=1   init_sub_quad_pos=1   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=2   init_sub_quad_pos=3   step=3   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0

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
    ${loop}=    Set Variable    1
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list with path list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_PAIREDUE}
    FOR      ${ue_packet}     IN      @{list_of_values}
        ${pairedue_value}    ${cur_sfnslot}           Get Value as Dict In Packet Match
        ...                   packetMatch=${ue_packet}
        ...                   field=${FIELDS_PAIREDUE}
        Log to console    ${pairedue_value}
        Log to console    ${cur_sfnslot}
        Continue For Loop If   '${pairedue_value}[0]'=='0' and '${loop}'=='1'
        Continue For Loop If   '${pairedue_value}[0]'=='0' and '${prev_sfnslot}[0]'=='${cur_sfnslot}[0]' and '${prev_sfnslot}[1]'=='${cur_sfnslot}[1]'
        ${loop}=     Evaluate    ${loop}+1
        Check PairedUe    ${rnti_list}   ${pairedue_value}
        ${prev_sfnslot}=    copy list     ${cur_sfnslot}
    END

Check PairedUe
    [Arguments]     ${rnti_list}    ${pairedue_value}
    ${paired_ue_count}=  Set Variable   ${0}
    FOR  ${element}  IN   @{pairedue_value}
         ${paired_ue_count}=   Check PairedUE List with Rnti List  ${rnti_list}   ${element}   ${paired_ue_count}
    END
    Run Keyword and Continue on Failure    Should Be Equal As Integers     ${paired_ue_count}  ${2}

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
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${TC32_nsa_ue_id1}     dl_rate=83   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${TC32_nsa_ue_id2}     dl_rate=82   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${TC32_nsa_ue_id1}     dl_rate=323   id=7
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${TC32_nsa_ue_id2}     dl_rate=323   id=7


Validate UL Traffic For all UEs TC15
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${TC32_nsa_ue_id1}     ul_rate=50   id=2
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${TC32_nsa_ue_id2}     ul_rate=50   id=2
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${TC32_nsa_ue_id1}     ul_rate=65   id=7
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${TC32_nsa_ue_id2}     ul_rate=65   id=7

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

