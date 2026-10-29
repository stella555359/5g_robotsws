*** Settings ***
Documentation
...     author:                Madhukara M V
...     email:                 madhukara.n_v@nokia.com
...     Feature:               CB011172_CB007145
...     INTRODUCTION:     This user scenario describes  SA call with slice aware scheduler with slice wigght 10-20 and 20-50%
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
...                 AND             load iphyfile     ${INSTALL_OFGESA}
...                 AND             Sleep    30s
...                 AND             AIC Software Build Info
...                 AND             Fetch Taf Library used in TL
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${vdu_file_path}
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${vcu_file_path}
...                 AND           sleep    300s
#...                 AND              Prepare AIC TL with vcu and vdu full config files   ${vcu_file_path}    ${vdu_file_path}
#...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
#...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
#...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
#...                 AND           AP Reboot Wait For Connection    ${120}
#...                 AND           Verify RMODs Online Status   ${800}
#...                 AND           sleep   600s    reason=f1 link should up
#...                 AND           sleep    10s
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    10s
...                 AND           X2AP Link Should be UP

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/AD_TC3/5G_install_radio_FDD.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_FJRU-N75N3N1-G_0020.zip
#${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/AD_TC3/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/AD_TC3/basic_FDD_NSA_ORAN.cfg
${vcu_file_path}   ${CURDIR}/config/AD_TC3/vcu_scf_fdd_nsa.xml
${vdu_file_path}   ${CURDIR}/config/AD_TC3/vdu_scf_fdd_nsa.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id}      ${151}

${Trgt_Cell}         ${1}
${x2_UP_pattern_with_simulated_gnb}    ENB-1: X2AP Link with GNB-3 .* is up
${UE_attach_pattern_RA}                   Bearer-type change from MCG to SCG-split is\n successful, HandoverType = DCHO_INACTIVE
${UE_attach_pattern}                   reported successful RA
${timeout}    20
${TRF_ID}     1

*** Test Cases ***
CB011172-CR-AD#TC3_Verify_ENDC_Mobilty
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    X2AP Link Should be UP with simulated ENB and simulated GNB    src=1   target=3
     UE Attach and ENDC should be Successful sim   ${nsa_ue_id}  Trgt_Cell=1   Trgt_gNB3=3  Bearer_ID=2
      sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id}  ${nsa_ue_id}   dl_rate=175
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id}  ${nsa_ue_id}   dl_rate=175
    sleep    5s

#step 3: Trigger the A3 measuusremts report from NSA ue from Simuated GNB 4 about the target GNB(real) cell (phycell id 50)
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change    ue_id=${nsa_ue_id}    meas_id=3    phycell_id=52

    Validate DL Traffic For NSA     ${nsa_ue_id}     175
    Validate UL Traffic For NSA     ${nsa_ue_id}     175







#    Link SCOUT SCF to Configuration ID for Reporting
    [teardown]   Multiple NSA UE Detach       ${nsa_ue_id}    ${nsa_ue_id}


*** keywords ***

X2AP Link Should be UP  #NSA
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=1    target=2
    Read WTS Output For Pattern And Print matching Lines    ENB-1: X2AP Link with GNB-2 .* is up    ${Timeout_NSA}
    BuiltIn.Log    x2_is_ok


X2AP Link Should be UP with simulated ENB and simulated GNB    # This is for setting ENDC call with ENB and GNB ( both simulated)
    [Arguments]     ${src}   ${target}
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${src}    target=${target}
    Read WTS Output For Pattern And Print matching Lines    ${x2_UP_pattern_with_simulated_gnb}    ${timeout}
    BuiltIn.Log    x2_is_ok





UE Attach and ENDC should be Successful sim  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB3}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    LTE Attach should be Successful    ${nsa_ue_id}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB3}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern_RA}    ${timeout}
    [Return]      ${output}


Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Inter Sgnb Handover is successful   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    Inter Sgnb Handover is successful    partial_match=${TRUE}
    Log to Console    ${output}
