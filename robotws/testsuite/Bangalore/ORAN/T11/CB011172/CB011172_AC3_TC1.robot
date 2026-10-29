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
Resource         ../../../resources/robot/PM_Counters.robot
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
...                 AND           sleep    200s
#...                 AND              Prepare AIC TL with vcu and vdu full config files   ${vcu_file_path}    ${vdu_file_path}
#...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
#...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
#...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A  4892
#...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
#...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${600}
...                 AND           sleep   200s    reason=f1 link should up
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep    60s

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/AC3_TC1/5G_install_radio_FDD.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_FJRU-N75N3N1-G_0020.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/AC3_TC1/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/AC3_TC1/basic_FDD_ORAN.cfg
${vcu_file_path}   ${CURDIR}/config/AC3_TC1/vcu_scf_fdd.xml
${vdu_file_path}   ${CURDIR}/config/AC3_TC1/vdu_scf_fdd.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${4}
${sa_en_ue_id}      ${4}

*** Test Cases ***
CB011172-CR-AC3_#TC1_Verify_Interband_3CC_CA_FDD_PCELL_TDD_Scell
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=2    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=3    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=4    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=5    qfi_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=6    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  100  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  100  pdu_id=1  trf_id=2    qfi_id=1
    sleep   60s
#    Validate DL Traffic For MultiUE for SA     ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=32   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=190   pdu_id=1   qfi_id=1
#     Verify Traffic on PCell and scell
	sleep     10s
    ${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_en_ue_id}     0    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${pcell_tput}       182
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_en_ue_id}     1    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}       127
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_en_ue_id}     2    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}       127
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_en_ue_id}     3    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}       127
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
Check Average Data Rate
    [Arguments]       ${output}    ${mbps}
    ${result}         Evaluate    (${mbps} * 1.1) > int(${output}) > (${mbps} * 0.9)
    Run Keyword if    ${result}    Log to Console    DL Average data rate: ${output}
    ...               ELSE    BuiltIn.Log     DL Average data rate: ${output}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=DL Average data rate failed!
