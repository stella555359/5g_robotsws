*** Settings ***
Documentation     author:jiajing.cheng
...               Group: HGZ_SG1
...               contact:jiajing.1.cheng@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

#Resource          ../../../../AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       ../../CB009444_V_B3/Resource/CB009444_V_B3_Resources.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process


*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}

${CU_namespace}              ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${CU_ssh_IP}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${CU_OAM_IP}                ${tl.gnbs[0].cu.oam_http_connection_details.addr}

##################define these variable for convenient############################
${ALIAS_CU}                 CU
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    [Documentation]    Will run 6 cases:
    ...       0. Deploy with 4 CPCL instance, shall be done before case start.
    ...       1. Commission CU SCF and check CU and DUs onair (DUs Commission not stable current not Commissioned)
    ...       2. Check cells/DU and CPCL instance mapping, cells/DU shall be mapping to different CPCL instance
    ...       3. NG link lock/unlock
    ...       4. SA UE attach and DL/UL traffic start (no TP check)
    ...       5. Check counter M55140C00001(PEAK_NUMBER_OF_SA_RRC_USERS_CU),
    ...                        M55140C00002(PEAK_NBR_OF_SA_NGBR_USERS_CU), M55140C00501(PEAK_NBR_OF_SA_GBR_USERS_CU)
    KW.Adjust PA To Default Value For CB009789
    set suite variable     ${CASESTEP}    1
    KW.GenerateCaseSCFCU4DU
    KW.Cloud Commission And Check On Air_4DU     CU_SCF=${LOG_PATH}/9789_CU_SCF.xml
    ...       DU1_SCF=${LOG_PATH}/9789_DU1_SCF.xml
    ...       DU2_SCF=${LOG_PATH}/9789_DU2_SCF.xml
    ...       DU3_SCF=${LOG_PATH}/9789_DU3_SCF.xml
    ...       DU4_SCF=${LOG_PATH}/9789_DU4_SCF.xml
    set suite variable     ${CASESTEP}    1
    KW.check_CPCL_cell_mapping
    set suite variable     ${CASESTEP}    2
    #CB009789_DA_3_01_Multiple_Pair_CPCL_NG_Setup_Success
    #CB009789_A_1_02_Commission_Multiple_Pair_CPCL_Cells_Mapping
    KW.NG_Lock_unLock
    KW.UE attach with ULDL traffic  cells=@{cell1_ID}    time_length=60s   apn_address=${APN}
    set suite variable     ${CASESTEP}    3
    #CB009789_DB_24_01_Multiple_Pair_CPCL_NG_Link_Lock
    #CB009789_DD_1_01_Multiple_Pair_CPCL_SA_Call_Setup
    Wait until keyword succeeds   16min   2min     KW.CheckCB009789Counters_Attach
    set suite variable     ${CASESTEP}    4
    #CB009789_E_1_01_Multiple_Pair_CPCL_SA_peak_UEs_counter

TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful_CB009789_DH_3
    [Documentation]    Will run 6 cases:
    ...       0. Deploy with 4 CPCL instance, shall be done before case start.
    ...       1. Commission CU SCF and check CU and DUs onair (DUs Commission not stable current not Commissioned)
    ...       2. Check cells/DU and CPCL instance mapping, cells/DU shall be mapping to different CPCL instance
    ...       3.Make CPCL instance(both active and standby OutOfService), bts reset and fault present in history
    ...       4. NG link lock/unlock
    ...       5. SA UE attach and DL/UL traffic start (no TP check)
    ...       6. Check counter M55140C00001(PEAK_NUMBER_OF_SA_RRC_USERS_CU),
    ...                        M55140C00002(PEAK_NBR_OF_SA_NGBR_USERS_CU), M55140C00501(PEAK_NBR_OF_SA_GBR_USERS_CU)
    KW.Adjust PA To Default Value For CB009789
    KW.GenerateCaseSCFCU4DU
    KW.Cloud Commission And Check On Air_4DU     CU_SCF=${LOG_PATH}/9789_CU_SCF.xml
    ...       DU1_SCF=${LOG_PATH}/9789_DU1_SCF.xml
    ...       DU2_SCF=${LOG_PATH}/9789_DU2_SCF.xml
    ...       DU3_SCF=${LOG_PATH}/9789_DU3_SCF.xml
    ...       DU4_SCF=${LOG_PATH}/9789_DU4_SCF.xml
    KW.check_CPCL_cell_mapping
    KW.check_DH_3_F1_Link_And_Cell_status
    KW.NG_Lock_unLock
    KW.UE attach with ULDL traffic  cells=@{cell1_ID}    time_length=60s   apn_address=${APN}
    Run Keyword And Ignore error    KW.Detach UE with Stop traffic    apn_address=${APN}   ue_mode=SA
    Wait until keyword succeeds   16min   2min     KW.CheckCB009789Counters_Attach

TC.CB009789_A_1_02_Commission_Multiple_Pair_CPCL_Cells_Mapping
    [Documentation]  CU cpounter:
    run keyword if     '${CASESTEP}'=='0'    TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    run keyword if     ${CASESTEP}<2     Fail    Case failed

TC.CB009789_DA_3_01_Multiple_Pair_CPCL_NG_Setup_Success
    [Documentation]  CU cpounter:
    run keyword if     '${CASESTEP}'=='0'    TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    run keyword if     ${CASESTEP}<2     Fail    Case failed

TC.CB009789_DD_1_01_Multiple_Pair_CPCL_SA_Call_Setup
    [Documentation]  CU cpounter:
    run keyword if     '${CASESTEP}'=='0'    TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    run keyword if     ${CASESTEP}<3     Fail    Case failed


TC.CB009789_E_1_01_Multiple_Pair_CPCL_SA_peak_UEs_counter
    [Documentation]  CU cpounter:
    run keyword if     '${CASESTEP}'=='0'    TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    run keyword if     ${CASESTEP}<4     Fail    Case failed

TC.CB009789_B_4_01_Multiple_Pair_CPCL_VDU_Deletion_Via_DeltaPlan
    [Documentation]  Will run 1 case:
    ...       0. Check Multiple CPCL (at least 2 CPCL instance) deployed.
    ...       1. Delete NRDU and corresponding NRCELLGRP/NRCELL in delta plan and activate.
    ...       2. UE do attach to other cell, DU deletion no impact to other cell's call.
    ...       3. Commission Backup SCF to recover CU ENV.
    log to console     0. Check Multiple CPCL (at least 2 CPCL instance) deployed.
    KW.Check_Multiple_CPCL_Deployed
    ${backupscf}    KW.BackupSCF
    &{parameters}   Create Dictionary    ${CASE_INPUT_CB009789['CB009789']['NRDU']}=1
    ...                                  ${CASE_INPUT_CB009789['CB009789']['NRCELLGRP']}=2
    ...                                  ${CASE_INPUT_CB009789['CB009789']['NRCELL']}=3
    ...                                  ${CASE_INPUT_CB009789['CB009789']['NRREL']}=4

    log to console     1.Delete NRDU and corresponding NRCELLGRP/NRCELL in delta plan and activate.
    CU Delta Commission Delete MO    parameters=&{parameters}
    ...       log_dir=${LOG_PATH}

#    ${dulist}       Create list    0    1   3
    ${dulist}       Create list    0
    KW.Wait On Air     dulist=${dulist}
    log to console     2. UE do attach to other cell, DU deletion no impact to other cell's call.
    KW.Adjust PA To Default Value For CB009789
    KW.UE attach with ULDL traffic  cells=@{cell1_ID}    time_length=60s   apn_address=${APN}
    Run Keyword And Ignore error    KW.Detach UE with Stop traffic    apn_address=${APN}   ue_mode=SA
    log to console     3. Commission Backup SCF to recover CU ENV.
    CU Full Commission    path_of_commission_file=${backupscf}
#    ${dulist}       Create list    0    1   2   3
#    ${dulist}       Create list    0    1
    ${dulist}       Create list    0
    Run Keyword And Ignore error      KW.Wait On Air     dulist=${dulist}

TC.CB009789_C_5_02_3Pair_CPCL_2VDU_2pair_shutdown_VCU_Reset_After_Timer_Expire
    [Documentation]  Make CPCL instance(both active and standby OutOfService), bts reset and fault present in history
    Log  ${CU_namespace}
    KW.Check_Multiple_CPCL_Deployed
    KW.Make_CPCL_OutOfService
    Sleep    1min
    Wait until keyword succeeds   16min    20s    KW.CheckReset
    ${alarms}    Wait until keyword succeeds    10min    20s    CU Get Historical Alarms
    KW.Make_CPCL_BackToService
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        ${present_status}    set variable if
    ...        '${alarm['fault_name']}'=='BTS site autonomous reset as recovery action' and '${alarm['alarm_id']}'=='7101'
    ...        ${True}    ${False}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}   Fail    alarm not present

TC.CB009789_DB_24_01_Multiple_Pair_CPCL_NG_Link_Lock
    [Documentation]  CU cpounter:
    run keyword if     '${CASESTEP}'=='0'    TC.CB009789_H_1_04_Deploy_Multiple_Pair_CPCL_CU_CNF_successful
    run keyword if     ${CASESTEP}<3     Fail    Case failed

TC.CB009789_DC_1_01_Multiple_Pair_CPCL_NSA_Call_Setup
    [Documentation]  CU cpounter:
    KW.GenerateCaseSCFCU4DU

TC.CB009789_F_3_01_Multiple_Pair_CPCL_PCMD_Trace
    [Documentation]  CU cpounter:
    KW.GenerateCaseSCFCU4DU

TC.CB009789_DF_28_Multiple_Pair_CPCL_SA_intra_Freq_intra_gNB_intra_DU_intra_CPCL_HO
    [Documentation]  Will run 1 case:
    ...       0. Check Multiple CPCL (at least 2 CPCL instance) deployed.
    ...       1. Delete NRREL, generate SA HO A5 Case SCF and commission SCF.
    ...       2. change UE mode to SA
    ...       3. UE do attach to source cell (DU1-CELL1(PCI50)).
    ...       4. Adjust PA to let HO happen, check HO counter.
    ...       5. Detach.

    KW.Check_Multiple_CPCL_Deployed
    KW.GenerateCaseSCFCU_9789_DF28
    KW.Cloud Commission And Check On Air_1DU    CU_SCF=${LOG_PATH}/9789_CU_DF28_SCF.xml    DU1_SCF=${LOG_PATH}/9789_DU1_DF28_SCF.xml
    KW.Adjust PA To Default Value For CB009789
    KW.Prepare UE And Attach    UECFG=${UECFG_SA}
    KW.Adjust PA To HO Value For CB009789 A5
    Sleep    1min
    Run Keyword And Ignore error        MultiUE.Detach    UECFG=${UECFG_SA}
    Wait until keyword succeeds   16min   2min    KW.CheckCB009789_DF_HO_Counter


TC.CB009789_DF_14_Multiple_Pair_CPCL_NSA_Successful_PSCell_change_with_radio_admission_control_Intra_DU_Intra_CPCL
    [Documentation]  Will run 1 case:
    ...       0. Check Multiple CPCL (at least 2 CPCL instance) deployed.
    ...       1. Delete NRREL, generate NSA HO A3 Case SCF and commission SCF.
    ...       2. change UE mode to NSA
    ...       3. UE do attach to source cell (DU2-CELL3(PCI52)).
    ...       4. Adjust PA to let HO happen, target cell (DU4-cell5(PCI54))(inter_CPCL HO due to MTK issue)
    ...       5. Detach.
    KW.Check_Multiple_CPCL_Deployed
    KW.GenerateCaseSCFCU_9789_DF14
    KW.Cloud Commission And Check On Air_2DU    CU_SCF=${LOG_PATH}/9789_CU_DF14_SCF.xml
    ...    DU2_SCF=${LOG_PATH}/9789_DU2_DF14_SCF.xml    DU4_SCF=${LOG_PATH}/9789_DU4_DF14_SCF.xml


####Case Level Keywords#####
Setup Suite for CB009789
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables       ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${CASESTEP}    0
    set suite variable     ${UECFG_SA}         ${TLCommonConfig_SAUE['MultiUECFG']}
    set suite variable     ${UECFG_NSA}        ${TLCommonConfig_NSAUE['MultiUECFG']}
    set suite variable     ${eNBRU_PA_Ports}       ${CASE_INPUT_CB009789['CB009789']['eNBRU_PA_Ports']}
    set suite variable     ${STU1_5GRU1_PA1_Ports}       ${CASE_INPUT_CB009789['CB009789']['STU1_5GRU1_PA1_Ports']}
    set suite variable     ${STU1_5GRU2_PA1_Ports}       ${CASE_INPUT_CB009789['CB009789']['STU1_5GRU2_PA1_Ports']}
    set suite variable     ${STU1_5GRU3_PA1_Ports}       ${CASE_INPUT_CB009789['CB009789']['STU1_5GRU3_PA1_Ports']}
    set suite variable     ${STU1_5GRU5_PA2_Ports}       ${CASE_INPUT_CB009789['CB009789']['STU1_5GRU5_PA2_Ports']}
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB009789['CB009789']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB009789['CB009789']['NRBTS_ID']}
    set suite variable     ${APN}        ${CASE_INPUT_CB009789['CB009789']['APN']}
    set suite variable     ${9789_SA_dist_name}      ${CASE_INPUT_CB009789['CB009789']['SA_Counter_dist_name']}
    set suite variable     @{cell1_ID}       ${CASE_INPUT_CB009789['CB009789']['cell1_ID']}
    set suite variable     @{cell2_ID}       ${CASE_INPUT_CB009789['CB009789']['cell2_ID']}
    set suite variable     @{cell3_ID}       ${CASE_INPUT_CB009789['CB009789']['cell3_ID']}
    set suite variable     @{cell4_ID}       ${CASE_INPUT_CB009789['CB009789']['cell4_ID']}
    set suite variable     @{cell5_ID}       ${CASE_INPUT_CB009789['CB009789']['cell5_ID']}
    Conn.ResetCache

Teardown Suite for CB009789
    log to console     Suite teardown

Setup case for CB009789
    log to console     Case Start

Teardown case for CB009789
    Run Keyword And Ignore Error    KW.Adjust PA To Default Value For CB009789
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown

KW.GenerateCaseSCFCU4DU
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU1_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU1_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789     mo_to_add_CU=MOs_TO_ADD_CU_9789
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_9789     mo_to_add_DU=MOs_TO_ADD_DU_9789
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_9789     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_9789
      ...    list_to_add_DU=LIST_TO_ADD_DU_9789
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU2_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU2_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789     mo_to_add_CU=MOs_TO_ADD_CU_9789
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_9789     mo_to_add_DU=MOs_TO_ADD_DU_9789
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_9789     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_9789
      ...    list_to_add_DU=LIST_TO_ADD_DU_9789
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU3_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU3_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789     mo_to_add_CU=MOs_TO_ADD_CU_9789
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_9789     mo_to_add_DU=MOs_TO_ADD_DU_9789
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_9789     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_9789
      ...    list_to_add_DU=LIST_TO_ADD_DU_9789
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU4_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU4_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789     mo_to_add_CU=MOs_TO_ADD_CU_9789
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_9789     mo_to_add_DU=MOs_TO_ADD_DU_9789
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_9789     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_9789
      ...    list_to_add_DU=LIST_TO_ADD_DU_9789

KW.GenerateCaseSCFCU_9789_DF28
      gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_DF28_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU1_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU1_DF28_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789_DF28     mo_to_add_CU=MOs_TO_ADD_CU_9789_DF28
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789_DF28     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789_DF28
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789_DF28
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU_9789_DF28     mo_to_add_DU=MOs_TO_ADD_DU_9789_DF28
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU_9789_DF28     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU_9789_DF28
      ...    list_to_add_DU=LIST_TO_ADD_DU_9789_DF28

KW.GenerateCaseSCFCU_9789_DF14
      gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_DF14_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU2_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU2_DF14_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789_DF14     mo_to_add_CU=MOs_TO_ADD_CU_9789_DF14
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789_DF14     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789_DF14
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789_DF14
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU2_9789_DF14     mo_to_add_DU=MOs_TO_ADD_DU2_9789_DF14
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU2_9789_DF14     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU2_9789_DF14
      ...    list_to_add_DU=LIST_TO_ADD_DU2_9789_DF14

      gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9789_CU_DF14_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU4_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9789_DU4_DF14_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU_9789_DF14     mo_to_add_CU=MOs_TO_ADD_CU_9789_DF14
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU_9789_DF14     list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU_9789_DF14
      ...    list_to_add_CU=LIST_TO_ADD_CU_9789_DF14
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU4_9789_DF14     mo_to_add_DU=MOs_TO_ADD_DU4_9789_DF14
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU4_9789_DF14     list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY_DU4_9789_DF14
      ...    list_to_add_DU=LIST_TO_ADD_DU4_9789_DF14


KW.Cloud Commission And Check On Air_4DU
    [Arguments]    ${CU_SCF}    ${DU1_SCF}    ${DU2_SCF}  ${DU3_SCF}  ${DU4_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
#    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU1_SCF}
#    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU2_SCF}
#    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU3_SCF}
#    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU4_SCF}
    sleep    1min
#    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
    ...      vdu_index=0    gnb_index=0
#    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
#    ...      vdu_index=1    gnb_index=0
#    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
#    ...      vdu_index=2    gnb_index=0
#    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
#    ...      vdu_index=3    gnb_index=0


KW.Wait On Air
    [Arguments]    ${dulist}
    FOR    ${du}    IN    @{dulist}
        wait until keyword succeeds     15min    30s      vDU Verify All Cells Status Should Be Onair
        ...      vdu_index=${du}    gnb_index=0
    END
#    wait until keyword succeeds     5min    30s     CU Verify All Cells Status Are Onair

KW.Make_CPCL_OutOfService
    KW.connect_CU_server
    log to console      Backup StatefulSet Image Set
    ${CPCL_Image_backup_cmd1}=  set variable    kubectl get pod -n ${CU_namespace} po-${CU_namespace}-cpcl-0 -o
    ${CPCL_Image_backup_cmd2}=  set variable
    ...      custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[1].image|awk 'NR==2'|awk '{print $2}'
    ${CPCL_Image_backup}        ssh.Execute    command=${CPCL_Image_backup_cmd1} ${CPCL_Image_backup_cmd2}
    ...      connection=${ALIAS_CU}
    set suite variable      ${CPCL_Image_backup}        ${CPCL_Image_backup.replace('\r\n','')}
    log to console      ${CPCL_Image_backup}  Next Set Fake Image in StatefulSet, will make standby CPCL pod Out of Service
    ${CPCL_Fake_Image}=  set variable    image-registry.openshift-image-registry.svc:5000/tl1100/cpcl:0.250.12944
    ${CPCL_FakeImageSet_cmd1}=  set variable    kubectl set image sts -n ${CU_namespace}
    ${CPCL_FakeImageSet_cmd2}=  set variable    po-${CU_namespace}-cpcl ctr-${CU_namespace}-cpcl=${CPCL_Fake_Image}
    ${CPCL_ImageSetReturn}    ssh.Execute
    ...      command=${CPCL_FakeImageSet_cmd1} ${CPCL_FakeImageSet_cmd2}
    ...      connection=${ALIAS_CU}
    log to console      ${CPCL_ImageSetReturn} Next Kill Active CPCL pod let whole CPCL instance Out of Service
    ${CPCL_DeleteReturn}      ssh.Execute     command=kubectl delete pod -n ${CU_namespace} po-${CU_namespace}-cpcl-0
    ...      connection=${ALIAS_CU}
    log to console      ${CPCL_DeleteReturn}   Next Check Reset case
    KW.disconnect_CU_server

KW.Make_CPCL_BackToService
    KW.connect_CU_server
    ${CPCL_SetBackReturn}        ssh.Execute
    ...      command=kubectl set image sts -n ${CU_namespace} po-${CU_namespace}-cpcl ctr-${CU_namespace}-cpcl=${CPCL_Image_backup}
    ...      connection=${ALIAS_CU}
    log to console     ${CPCL_SetBackReturn}
    log to console      Check CPCL pod Back to running
    wait until keyword succeeds     10min    10s     KW.Check_CPCL_Running
    KW.disconnect_CU_server

KW.Check_CPCL_Running
    ${CPCL_0_Pod_Status}      ssh.Execute
    ...      command=kubectl get pods -n ${CU_namespace} | grep po-${CU_namespace}-cpcl-0
    ...      connection=${ALIAS_CU}
    ${CPCL_1_Pod_Status}      ssh.Execute
    ...      command=kubectl get pods -n ${CU_namespace} | grep po-${CU_namespace}-cpcl-1
    ...      connection=${ALIAS_CU}
    Should Contain    ${CPCL_0_Pod_Status}      Running
    Should Contain    ${CPCL_1_Pod_Status}      Running

KW.CheckCB009789Counters_Attach
    KW.Check vCU PM Counter
    ...     measurement_id=55140     dist_name=${9789_SA_dist_name}    counter_id=M55140C00001    expected_value=1
    KW.Check vCU PM Counter
    ...     measurement_id=55140     dist_name=${9789_SA_dist_name}    counter_id=M55140C00002    expected_value=1
    KW.Check vCU PM Counter
    ...     measurement_id=55140     dist_name=${9789_SA_dist_name}    counter_id=M55140C00501    expected_value=0

KW.CheckCB009789_DF_HO_Counter
    #When RRC Reconfiguration Complete for HO is received by the gNB. Updated to the source cell.
    KW.Check vCU PM Counter
    ...     measurement_id=55145     dist_name=${CASE_INPUT_CB009789['CB009789']['HOCounter_dist_name']}
    ...     counter_id=M55145C00302    expected_value=1

KW.connect_CU_server
    ssh.Connect to    hostname=${CU_ssh_IP}    username=${CU_username}
    ...  password=${CU_password}    alias=${ALIAS_CU}

KW.disconnect_CU_server
    run keyword and ignore error    ssh.disconnect    connection=${ALIAS_CU}

KW.Check_Multiple_CPCL_Deployed
    KW.connect_CU_server
    ${Pod_Status}      ssh.Execute
    ...      command=kubectl get pods -n ${CU_namespace}
    ...      connection=${ALIAS_CU}
    Should Contain    ${Pod_Status}      po-${CU_namespace}-cpcl-0
    Should Contain    ${Pod_Status}      po-${CU_namespace}-cpcla1-0
    KW.disconnect_CU_server

KW.check_CPCL_cell_mapping
    KW.connect_CU_server
    ${CPCL}      ssh.Execute    command=kubectl logs po-tl1124-cpcl-0 -c ctr-tl1124-cpcl -n tl1124 | grep -i 'handles commissioned cells: '
    ...      connection=${ALIAS_CU}
    ${CPCLA1}    ssh.Execute    command=kubectl logs po-tl1124-cpcla1-0 -c ctr-tl1124-cpcl -n tl1124 | grep -i 'handles commissioned cells: '
    ...      connection=${ALIAS_CU}
    ${CPCLA2}    ssh.Execute    command=kubectl logs po-tl1124-cpcla2-0 -c ctr-tl1124-cpcl -n tl1124 | grep -i 'handles commissioned cells: '
    ...      connection=${ALIAS_CU}
    ${CPCLA3}    ssh.Execute    command=kubectl logs po-tl1124-cpcla3-0 -c ctr-tl1124-cpcl -n tl1124 | grep -i 'handles commissioned cells: '
    ...      connection=${ALIAS_CU}
    Should Contain    ${CPCL}      ${cell1_ID}
    Should Contain    ${CPCL}      ${cell2_ID}
    Should Contain    ${CPCLA1}    ${cell3_ID}
    Should Contain    ${CPCLA2}    ${cell4_ID}
    Should Contain    ${CPCLA3}    ${cell5_ID}
    KW.disconnect_CU_server

KW.Adjust PA To Default Value For CB009789
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU1_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU1 default value, UE can search RU1.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU2_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU2 default value, UE can't search RU2.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU3_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_2']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU3 default value, UE can't search RU3.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU5_PA2_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA1 values for RU5 default value, UE can't search RU5.

KW.Adjust PA To HO Value For CB009789
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU1_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_3']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU1 default value, UE can search RU1 but lower.
    Sleep   10s
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU2_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU2 default value, UE can search RU2 and signal better.

KW.Adjust PA To HO Value For CB009789 A5
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU1_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_5']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU1 default value, UE can search RU1 but lower.
    Sleep   10s
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${STU1_5GRU2_PA1_Ports}
    ...    value=${CASE_INPUT_CB009789['CB009789']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA1 values for RU2 default value, UE can search RU2 and signal better.

KW.Check vCU PM Counter
    [Arguments]   ${measurement_id}     ${dist_name}    ${counter_id}    ${expected_value}       ${gnb_index}=0    ${how_many}=1
    [Documentation]  For example: M55157C00003, measurement_id is 55157
    ...     CU Login is use cu_version=cuoam_19b, counter check will fail
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_23r2
    ${res}=  cu.get_counter    measurement_id=${measurement_id}     dimension_dist_name=${dist_name}    counter_id=${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    log  The latest one is: ${counter_values[-1]}
    should be equal    ${counter_values[-1]["value"]}  ${expected_value}
    [Teardown]   CU Logout

KW.BackupSCF
    CU Login      gnb_index=0    cu_version=cuoam_23r2
    ${time_stamp}=  Get Time   exclude_millis=yes
    ${time_stamp}=  replace string  ${time_stamp}  ${SPACE}  \
    ${time_stamp}=  replace string  ${time_stamp}  -   \
    ${time_stamp}=  replace string  ${time_stamp}  :   \
    ${backupscf}=   set variable    ${LOG_PATH}/${CU_namespace}CU_backupSCF_${time_stamp}.xml
    cu.get_current_plan_file    ${backupscf}
    [Return]     ${backupscf}
    [Teardown]   run keyword and ignore error   CU Logout

KW.PingOAM
    [Arguments]    ${ip}
    ${result}  run   command=ping ${ip} -c 10
    should contain    ${result}    64 bytes from ${ip}

KW.CheckReset
    ${status}    Run Keyword And Return Status    KW.PingOAM   ip=${CU_OAM_IP}
    Should Be True    '${status}'=='False'

KW.NG_Lock_unLock
    [Arguments]     ${gnb_index}=0
    [Documentation]  For example: M55157C00003, measurement_id is 55157
    ...     CU Login is use cu_version=cuoam_19b, counter check will fail
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_23r2
    @{ng_links_list}      Create List       1
    cu.lock_ng_links    ng_links_ids=@{ng_links_list}    connection=${None}
    sleep      60s
    cu.unlock_ng_links    ng_links_ids=@{ng_links_list}    connection=${None}
#    ${res}=   cu.search_parameters_of_current_plan     parameter_name=administrativeState    items_per_page=${30}
#    ${ng_link_status}=    set variable     ${res["items"]}
    [Teardown]   CU Logout

KW.Cloud Commission And Check On Air_1DU
#    [Arguments]    ${CU_SCF}
    [Arguments]    ${CU_SCF}    ${DU1_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU1_SCF}
    sleep    1min
#    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    1min      vDU Verify All Cells Status Should Be Onair
    ...      vdu_index=0    gnb_index=0


KW.Cloud Commission And Check On Air_2DU
    [Arguments]    ${CU_SCF}    ${DU2_SCF}  ${DU4_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU2_SCF}    vdu_index=1
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU4_SCF}    vdu_index=3
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
    ...      vdu_index=1    gnb_index=0
    wait until keyword succeeds     5min    30s      vDU Verify All Cells Status Should Be Onair
    ...      vdu_index=3    gnb_index=0


KW.Prepare UE And Attach
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    set suite variable    ${UECFG}    ${UECFG}
    set suite variable    ${MultiUEL3Call_${ue_index}_disable_call}    true
    ${res}  run keyword and ignore error   power_ue.Prepare UE
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
    ...    detach_request=${UECFG['${ue_index}']['detach_request']}
    ...    power_reset=${UECFG['${ue_index}']['power_reset']}
    Run Keyword And Ignore Error    power_ue.UE Detach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=${UECFG['${ue_index}']['power_reset']}
    Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_Result           default_value=Failed
    Run Keyword And Continue On Failure    Huawei_UE.Attach     UECFG=${UECFG}    ue_index=${ue_index}   default_ue_index=${default_ue_index}
    sleep    5s

KW.check_DH_3_F1_Link_And_Cell_status
    [Arguments]
    Log  ${CU_namespace}
    KW.Check_Multiple_CPCL_Deployed
    ${before_f1_link_value}     KW.Check_F1_status

    KW.Make_CPCL_OutOfService
    Sleep    1min
    ${after_f1_link_value}     KW.Check_F1_status
    Run Keyword And Continue On Failure    Run Keyword If    ${before_f1_link_value} < ${after_f1_link_value}
    ...    log to console     Check F1 link status pass
    ...   ELSE    Fail    Check F1 link status fail
    ${cell_operability_state}    KW.Check_cell_operability_states
    should be equal       ${cell_operability_state}     disabled

    KW.Make_CPCL_BackToService
    wait until keyword succeeds     15min    1min      vDU Verify All Cells Status Should Be Onair
    ...      vdu_index=0    gnb_index=0


KW.Check_F1_status
    CU Login
    ${du_state}=    cu.get_du_state
    ${f1_link_value}   Convert To Integer     ${du_state["f1_link_status"]["unavailable"]}
    run keyword and ignore error   CU Logout
    [Return]  ${f1_link_value}

KW.Check_cell_operability_states
    CU Login
    ${cells_status}=    cu.get_cells_statuses
    ${operability_state}=     set variable    ${cells_status[0]['operational_state']}
    should be equal       ${operability_state}     disabled
    run keyword and ignore error   CU Logout
    [Return]  ${operability_state}
