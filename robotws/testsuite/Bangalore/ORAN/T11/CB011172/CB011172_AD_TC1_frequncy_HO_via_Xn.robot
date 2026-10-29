*** Settings ***
Documentation
...     author:                Madhukara M V
...     email:                 madhukara.n_v@nokia.com
...     Feature:               CB011172_CB007145
...     INTRODUCTION:     This user scenario describes  SA call with Multi ues ( 10 ues) and link adpatation.
...     TEST SET NAME:    [1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes NSA SgNBAddition Success,UL and DL Data Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...                        [1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes SA UE Attach Success,UL and DLData Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...      TESTING SPLIT:    See CB007145 testplan
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:       CB011172/CB007145 CFAM
...      Requirement ID:   5G_RAN_USR_RRM_15610,5G_RAN_USR_RRM_15632

Library             ute_wtssim
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../../resources/robot/AIC_Common_Keywords.robot
#../resources/robot/AIC_Common_Keywords.robot
Resource            ../../../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
#Resource            ../../../RRM/5GET_BLR/CB007145/resources/common/CB007145_Resource.robot
Resource            ../resources/ORAN_Keywords.robot
Resource            ../../../resources/robot/WTS_Runner_Keywords.robot
#Resource         ../../../resources/robot/configuration_id.robot
Library      ta5g_commissioning

Suite Setup         Run keywords     Test Suite Setup
#Get and Update RFMplugin   ${RFplugin_file}
#...                 AND     load ncsnapshot     ${ncsnap_path}
#...                 AND     Configure Netconf Credentials
...                 AND             load iphyfile    ${INSTALL_OFGESA}
...                 AND             Sleep    30s
...                 AND             AIC Software Build Info
...                 AND             Fetch Taf Library used in TL
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${vdu_file_path}
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${vcu_file_path}
...                 AND           sleep    200s
##...                 AND              Prepare AIC TL with vcu and vdu full config files   ${vcu_file_path}    ${vdu_file_path}
##...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
##...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
##...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
##...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
##...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
##...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${600}
...                 AND           sleep   600s    reason=f1 link should up
##...                 AND           sleep    10s
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    10s

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/AD_TC1/5G_install_radio_FDD.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_FJRU-N75N3N1-G_0020.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/AD_TC1/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/AD_TC1/basic.cfg
${vcu_file_path}   ${CURDIR}/config/AD_TC1/vcu_scf_fdd.xml
${vdu_file_path}   ${CURDIR}/config/AD_TC1/vdu_scf_fdd.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${1}
${meas_id_sim}      6
${meas_id_real}      3
${phycell_id_sim}       381
${phycell_id_real}       52
*** Test Cases ***
CB011172-CR-AD#TC1_Verify_Inter_and_intra_frequncy_HO_via_Xn
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    HO GNB to Simulated GNB and vice versa

#    UE Register should be Successful simulated gNB  ${sa_st_ue_id}    pdu_id=1    nw_id=1       gw_id=1
    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_st_ue_id}    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  100  pdu_id=1  trf_id=1    qfi_id=1

    sleep   10s


    Trigger A5 RsrpAndRsrq Measurement from real gnb to simulated gNB           ${sa_st_ue_id}     meas_id=2       phycell_id=381
#    Validate DL Traffic For MultiUE for SA     ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=150   pdu_id=1   qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=100   pdu_id=1   qfi_id=1
    sleep   10s

    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB           ${sa_st_ue_id}     meas_id=3       phycell_id=52


    sleep   20s
    Validate DL Traffic For MultiUE for SA     ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=150   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=100   pdu_id=1   qfi_id=1

#    Link SCOUT SCF to Configuration ID for Reporting
    [teardown]  MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}


*** keywords ***
Validate UL Traffic For MultiUE for SA No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput     ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

UE Register should be Successful simulated gNB
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant for simulated gNB
    [Arguments]    ${ue_id}      ${pdu_id}    ${nw_id}     ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    PDU SESSION RESOURCE SETUP RESPONSE    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

HO GNB to Simulated GNB and vice versa
     wtsrunner.gnb_param    id=3        sib1_period=40
     wtsrunner.gnb_param    id=3        sib2_period=40
     wtsrunner.gnb_param    id=3        sib5_period=40
     wtsrunner.ue_history_information_list_add_ngran    id=1    gnb_id=2    cell_type=medium        nrcgi=311:489|0x03      time_ue_stayed_in_cell=100
     wtsrunner.ue_history_information_list  id=1    action=commit
     wtsrunner.ue_enb_param     id=1    ue_history_list=1
     wtsrunner.upf_param    id=1        end_markers_delay=10s
     wtsrunner.smf_ue_pdu_param     id=1    ue=1    pdu=1   switch_upf_address=on
     wtsrunner.gnb_param    id=3      xn_listening_socket=1       send_xn_setup=true  measEvent=A3
#     wtsrunner.ue_change_location2  id=1    enb=3   cell=1

Validate DL Traffic For MultiUE for SA No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput     ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
   	END

Check Average Rate with No Cap on Tput
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    ( int(${output[0]}) > 2 )
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
    log to console      ${mbps}

