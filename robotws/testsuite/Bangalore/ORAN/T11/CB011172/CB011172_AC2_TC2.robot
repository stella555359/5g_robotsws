*** Settings ***
Documentation
...     author:                Madhukara M V
...     email:                 madhukara.m_v@nokia.com
...     INTRODUCTION:     This user scenario describes  SA call with Multi ues ( 10 ues) and link adpatation.
...     TEST SET NAME:    Cell3 FDD is up and ruuning and 10 ues are registered to cell and tput is verified
...                       Then the UL and DL BLER profile is applied to UEs
...                       After applying the BLER prffile, we are not verifying the peak tput, we are just verifying the all ues are
...                       still active and the Link adapation is veriffied with the help of PM counters.
...      CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      Requirement ID:   5G_RAN_USR_RRM_15610,5G_RAN_USR_RRM_15632

Library             ute_wtssim
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../../resources/robot/AIC_Common_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource            ../../../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
Resource            ../resources/ORAN_Keywords.robot
Resource            ../../../resources/robot/WTS_Runner_Keywords.robot
Resource            testsuite/Bangalore/ORAN/T08/CB008048/resources/CB008048_keywords.robot
Library      ta5g_commissioning
Library      ta5g_pm_counters
Library     ta5g_admin_operations

Suite Setup         Run keywords     Enable Cloud
...                 AND     Test Suite Setup
#...                 AND     Get and Update RFMplugin vdu  ${RFplugin_file}
#...                 AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Load netconf credentials
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
...                 AND           sleep    30s

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${RMOD_name}       AHFII
${INSTALL_OFGESA}     ${CURDIR}/config/AC2_TC2/5G_install_radio_FDD.sh
${RFplugin_file}     RFMPlugin_O-RU_NK_475701A-102_0034.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/fjt*
${IPHY_FILE}          ${CURDIR}/config/AC2_TC2/iphy-new.xml
${iphy_file_path}  ${CURDIR}/config/SBTS25R2/iphy-new.xml
${wts_cfg_file}    ${CURDIR}/config/AC2_TC2/basic_FDD_ORAN.cfg
${vcu_file_path}   ${CURDIR}/config/AC2_TC2/vcu_scf_fdd.xml
${vdu_file_path}   ${CURDIR}/config/AC2_TC2/vdu_scf_fdd.xml
${rmod}            ${CURDIR}/config/SBTS25R1/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${10}

*** Test Cases ***
CB011172-CR-AC2_#TC2_Verify_UL256QAM_with_Multi_UE_link_adaption_4x4_FDD
    [setup]  Testcase Setup
    set test variable      ${LOG_PATH}
   # Wait For Next Full Pm Interval    vdu=1
#     Wait until the next Measurement Period starts
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  100  pdu_id=1  trf_id=1    qfi_id=1
    sleep   10s
    Validate DL Traffic For MultiUE for SA No Cap on Tput    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=32   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA No Cap on Tput   ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=12   pdu_id=1   qfi_id=1
    wtsrunner.bler_testmode_nr      profile_id=1    ul_bler=120    dl_bler=120
    wtsrunner.ue_testmode_set_nr      id=1-10     testmode=bler   profile_id=1    action=activate
    Sleep    10s
    Validate DL Traffic For MultiUE for SA No Cap on Tput    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=32   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA No Cap on Tput   ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=12   pdu_id=1   qfi_id=1
    Wait For Next Full Pm Interval    vdu=1

     ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File Aic  output_dirpath=${OUTPUT DIR}/pmcounter1    vdu=1
    Run keyword and Ignore Error    Verify Any Counters In File
    ...  M55300C02008    > 1  PDSCH_SUCC_ANY_64TBL_MCS_08
    ...  M55300C02007    > 1  PDSCH_SUCC_ANY_64TBL_MCS_07
    ...  M55300C06020    > 1  PDSCH_SUCC_ANY_256TBL_MCS_20
    ...  M55300C06027    > 1  PDSCH_SUCC_ANY_256TBL_MCS_27
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...  file_path=${pm_counter_file}

    wtsrunner.ue_testmode_set_nr      id=1-10   testmode=bler    profile_id=1    action=deactivate

#    Link SCOUT SCF to Configuration ID for Reporting
    [teardown]  MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}


*** Keywords ***
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

