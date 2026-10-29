*** Settings ***
Documentation
...    Author: rafal.kaczmarski@nokia.com
...    Maintainer: rafal.kaczmarski@nokia.com

Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     ta_attenuator
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     OperatingSystem
Library     DateTime
Library     ute_admin_infomodel
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${LOG_PATH}         ${OUTPUT DIR}
${gNB_IP}           ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${gNB_ID}           ${tl.gnbs[0].global_bts_id}
${VM_IP}            ${tl.test_pc.default_ssh_connection_details.addr}

*** Keywords ***
TC01_Feature_Activation_Deactivation_and_SIB1_transmission_with_cellReservedForOperatorUse_2PLMNs
    Log To Console    \nStarting Test...
    Set CB009010 parameters    true    reserved
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Intra-gNB HO
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_on.json
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_on.json    0
    Run Keyword And Ignore Error    Delete All NRELLs
    Detach Ue    UE_1
    Set CB009010 parameters    false    notReserved
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Intra-gNB HO
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_off.json
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_off.json    1


TC05_Intra-Freq_NSA_ANR_reportCGI_reception_and_populating_ADJ_NRPLMNSET_NSA_for_inter-gNB_neighbors
    Log To Console    \nStarting Test...
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    Check Proper Values For NRPLMNSET Objects For GNB1
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB1 To GNB2
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_3_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_1_CELL_1    GNB_2_CELL_1    90    0db
    ELT.Stop Log Collecting
    ${elt_log_back}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2
    Check Proper Values For NRPLMNSET Objects For GNB2
    Stop Collecting Syslog For All
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB2 To GNB1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json   1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json    1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    1


TC07_Handover_restriction_on_the_source_when_UE_using_PLMN_that_is_reserved_on_the_Target_cell_ADJ_NRPLMNSET_NSA
    Log To Console    \nStarting Test...
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    Check Proper Values For NRPLMNSET Objects For GNB1
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB1 To GNB2
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_3_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_1_CELL_1    GNB_2_CELL_1    90    0db
    ELT.Stop Log Collecting
    ${elt_log_back}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2
    Check Proper Values For NRPLMNSET Objects For GNB2
    Stop Collecting Syslog For All
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB2 To GNB1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json   1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json    1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    1
    Start Collecting Syslog
    Set cellReservedForOperatorUse    reserved
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_to_50832_reserved.json
    Stop Collecting Syslog    reserved_50831
    Detach Ue    UE_1
    Verify Handover Not Allowed From Reserved ADJ_NRPLMNSET_NSA


TC09_Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_NSA
    Log To Console    \nStarting Test...
    Set cellReservedForOperatorUse Flags For TC09    reserved
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    Check Proper Values For NRPLMNSET Objects For GNB1
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB1 To GNB2
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_3_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_1_CELL_1    GNB_2_CELL_1    90    0db
    ELT.Stop Log Collecting
    ${elt_log_back}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2 For TC09
    Check Proper Values For NRPLMNSET Objects For GNB2 For TC09
    Stop Collecting Syslog For All
    Verify Handover Not Allowed To Reserved ADJ_NRPLMNSET_NSA


TC13_Intra-Freq_NSA_ANR_reportCGI_reception_and_populating_ADJ_NRPLMNSET_NSA_for_inter-gNB_neighbors
    Log To Console    \nStarting Test...
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json
    Detach Ue    UE_1
    Sleep    10s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    Check Proper Values For NRPLMNSET Objects For GNB1
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB1 To GNB2
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_3_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_1_CELL_1    GNB_2_CELL_1    90    0db
    ELT.Stop Log Collecting
    ${elt_log_back}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json
    Detach Ue    UE_1
    Sleep    60s
    Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2
    Check Proper Values For NRPLMNSET Objects For GNB2
    Stop Collecting Syslog For All
    Verify Inter Frequency Inter Gnb Handover Succeeded From GNB2 To GNB1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json   1
    Validate Cell Reserved For Operator    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json   1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50831_to_50832.json    1
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    1
    Start Collecting Syslog For All    revalidate_50831    revalidate_50832
    Delete NRPLMNSET_SA And NRPLMNSET_NSA From Target
    Set Capacity Parameters    0    0
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    30    10db
    Detach Ue    UE_1
    Set Capacity Parameters    250    275
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_2_CELL_1    GNB_1_CELL_1    90    10db
    Detach Ue    UE_1
    Stop Collecting Syslog    revalidate_50831
    Stop Collecting Syslog From Remote    revalidate_50832
    Check Updated NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    Check Proper Values For Updated NRPLMNSET Objects For GNB1


TC06_Access_restriction_for_UE_for_reserved_PLMN_and_handover_restrictions_ADJ_NRPLMNSET_NSA
    Log To Console    \nStarting Test...
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Log To Console    \nAttach completed...
    Sleep    15s
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50831_attach.json
    Detach Ue    UE_1
    Set Attenuation    ${CELL_1_ALIAS}    90dB
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_3_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    5s
    Trigger Inter-gNB HO    GNB_1_CELL_1    GNB_2_CELL_1    30    0db
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json
    Detach Ue    UE_1
    Stop Collecting Syslog For All
    Sleep    60s
    Verify Attach To Neutral PLMN Failed
    Verify Handover Not Allowed To Neutral PLMN
    Validate Cell Cgi Rslt    ${LOG_PATH}/${test_name}/elt_log_50832_to_50831.json    0


Test Setup
    [Arguments]    ${ELT}=${FALSE}    ${DELETE_NRPLMNSET}=${FALSE}    ${CREATE_NRPLMNSET}=${FALSE}    ${UPLOAD_SCF}=${FALSE}
    ...    ${CREATE_TARGET_NRPLMNSET}=${FALSE}    ${ACTIVATE_FEATURE}=${FALSE}
    Remove Special Characters From Anr Testname
    Set Test Variable    ${ELT}    ${ELT}
    Set Test Variable    ${DELETE_NRPLMNSET}    ${DELETE_NRPLMNSET}
    Set Test Variable    ${CREATE_NRPLMNSET}    ${CREATE_NRPLMNSET}
    Set Test Variable    ${CREATE_TARGET_NRPLMNSET}    ${CREATE_TARGET_NRPLMNSET}
    Set Test Variable    ${UPLOAD_SCF}    ${UPLOAD_SCF}
    Set Test Variable    ${ACTIVATE_FEATURE}    ${ACTIVATE_FEATURE}
    Run Keyword And Ignore Error    Delete All NRELLs
    IF    ${DELETE_NRPLMNSET}    Delete NRPLMNSET_SA
    IF    ${UPLOAD_SCF}    Upload SCF    NEUTRAL
    Prepare Ue
    Collect SCF Before Test
    Start Collecting Syslog For All
    IF    ${ELT}    Run Keywords    ELT.Setup    AND    ELT.Set Logging Filter    OTA


Teardown
    Run Keyword If Test Failed    Stop Collecting Syslog For All
    Make Snapshot In Case Of Error
    Add Scout Scf Id To Test Data
    IF    ${ACTIVATE_FEATURE}    Set CB009010 parameters    true    notReserved
    IF    ${CREATE_NRPLMNSET}    Create NRPLMNSET_SA
    IF    ${CREATE_NRPLMNSET}    Set cellReservedForOperatorUse Flags For TC09    notReserved
    IF    ${CREATE_TARGET_NRPLMNSET}    Run Keyword And Ignore Error    Add NRPLMNSET_SA And NRPLMNSET_NSA In Target
    Run Keyword And Ignore Error    Delete All NRELLs
    IF    ${UPLOAD_SCF}    Upload SCF    Non-NEUTRAL
    ELT.Shutdown
    Run Keyword And Ignore Error    Detach Ue    UE_1
    Release Attenuator
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin


Remove Special Characters From Anr Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}


Upload SCF
    [Arguments]    ${scf_type}
    Perform SCF Commissioning      ${scf_type}
    Sleep    60s
    Wait For X2 Link Available


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${gNB_IP}     name=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb


Start Collecting Syslog
    [Arguments]    ${alias_source}=reserved_50831
    taf_syslog.Start Syslog  log_dir=${LOG_PATH}/${test_name}/syslog/  log_name=syslog_${alias_source}.log
    ...  ip=192.168.255.126  alias=${alias_source}  virtualenv_dir=/home/ute/test_repo
    Set Test Variable    ${reserved_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias_source}.log


Start Collecting Syslog For All
    [Arguments]    ${alias_source}=50831    ${alias_remote}=50832
    taf_syslog.Start Syslog  log_dir=${LOG_PATH}/${test_name}/syslog/  log_name=syslog_${alias_source}.log
    ...  ip=192.168.255.126  alias=${alias_source}  virtualenv_dir=/home/ute/test_repo
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias_source}.log
    Sleep  5s
    taf_syslog.Start Syslog  log_dir=${LOG_PATH}/${test_name}/syslog/  log_name=syslog_${alias_remote}.log
    ...  ip=192.168.255.126  host_ip=10.44.149.147  alias=${alias_remote}  virtualenv_dir=/home/ute/test_repo
    Set Test Variable    ${remote_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias_remote}.log
    Sleep  5s


Stop Collecting Syslog
    [Arguments]    ${alias_source}=50831
    ${file_path_1}    taf_syslog.Collect Syslog Results    alias=${alias_source}
    RETURN      ${file_path_1}


Stop Collecting Syslog From Remote
    [Arguments]    ${alias_remote}=50832
    ${file_path_2}    taf_syslog.Collect Syslog Results    alias=${alias_remote}
    RETURN      ${file_path_2}


Stop Collecting Syslog For All
    Stop Collecting Syslog
    Stop Collecting Syslog From Remote


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Wait For X2 Link Available
    [Arguments]    ${admin_alias}=source
    Wait Until Keyword Succeeds  30  10  taf_admin.Setup Admin    bts_host=${gNB_IP}    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Wait For X2 Link Available For Remote
    [Arguments]    ${admin_alias}=remote
    Wait Until Keyword Succeeds  30  10  taf_admin.Setup Admin    remote_host=10.44.149.147    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Delete NRPLMNSET_SA And NRPLMNSET_NSA From Target
    taf_admin.Setup Admin      remote_host=10.44.149.147    name=nrplmnset_del_remote
    taf_admin.Perform Delta Recommissioning
    ...    delta_file=testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB009010/resources/nrplmnset_remove_delta.json
    ...    connection=nrplmnset_del_remote
    taf_admin.Teardown Admin    connection=nrplmnset_del_remote
    Wait For X2 Link Available For Remote


Add NRPLMNSET_SA And NRPLMNSET_NSA In Target
    taf_admin.Setup Admin      remote_host=10.44.149.147    name=nrplmnset_add_remote
    taf_admin.Perform Delta Recommissioning
    ...    delta_file=testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB009010/resources/nrplmnset_add_delta.json
    ...    connection=nrplmnset_add_remote
    taf_admin.Teardown Admin    connection=nrplmnset_add_remote
    Wait For X2 Link Available For Remote


Set cellReservedForOperatorUse Flags For TC09
    [Arguments]  ${cellReservedForOperatorUse}
    Log To Console    \nSetting cellReservedForOperatorUse parameter...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=cellReservedForOperatorUse
    taf_admin.Create Delta    delta_id=cellReservedForOperatorUse
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRPLMNSET_NSA-1    cellReservedForOperatorUse
    ...                                           ${cellReservedForOperatorUse}    delta_id=cellReservedForOperatorUse
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRPLMNSET_SA-1    cellReservedForOperatorUse
    ...                                           ${cellReservedForOperatorUse}    delta_id=cellReservedForOperatorUse
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRPLMNSET_SA-2    cellReservedForOperatorUse
    ...                                           ${cellReservedForOperatorUse}    delta_id=cellReservedForOperatorUse
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRPLMNSET_SA-3    cellReservedForOperatorUse
    ...                                           ${cellReservedForOperatorUse}    delta_id=cellReservedForOperatorUse
    ${delta}    taf_admin.Get Delta    delta_id=cellReservedForOperatorUse
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=cellReservedForOperatorUse
    taf_admin.Teardown Admin    alias=cellReservedForOperatorUse


Delete NRPLMNSET_SA
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrrel_del
    ${params}=    get_empty_list
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRPLMNSET_SA-4
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del
    Wait For X2 Link Available


Create NRPLMNSET_SA
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrrel_create
    ${params}=    get_parameters_for_nrplmnset_sa
    taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-50831/NRBTS-50831/NRCELL-1/NRPLMNSET_SA-4
    ...                                         parameter=${params}
    ...                                         operation=create
    ...                                         connection=nrrel_create
    taf_admin.Teardown Admin    connection=nrrel_create
    Wait For X2 Link Available


Delete All NRELLs
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrrel_del
    ${params}=    get_empty_list
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-255
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del
    taf_admin.Setup Admin      remote_host=10.44.149.147    name=nrrel_del_remote
    ${params}=    get_empty_list
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-50832/NRBTS-50832/NRCELL-${cell_1_id}/NRREL-255
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del_remote
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-50832/NRBTS-50832/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del_remote
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del_remote
    taf_admin.Teardown Admin    connection=nrrel_del_remote


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2  GNB_2_CELL_1   GNB_2_CELL_2
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${CELL_1_ALIAS}    90dB
    Set Attenuation    ${CELL_2_ALIAS}    90dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Set Attenuation    ${CELL_4_ALIAS}    90dB
    Sleep  2s


Trigger Intra-gNB HO
    Log To Console    \nStarting Inter-gNB Handover...
    Set Attenuation    GNB_1_CELL_2    10db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END


Trigger Inter-gNB HO
    [Arguments]      ${Cell_1}    ${Cell_2}    ${final_att}    ${att}
    Log To Console    \nStarting Inter-gNB Handover...
    Set Attenuation    ${Cell_1}    ${att}
    FOR    ${i}  IN RANGE  20  ${final_att}  2
        Set Attenuation  ${Cell_2}  ${i}db
        Sleep  1s
    END


Activate CB009010 Feature For Both GNBs
    Log To Console    \nActivating CB009010 on both GNBs...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Create_Delta    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actPlmnCellResForOpUse    true    delta_id=activation
    ${delta}    taf_admin.Get_Delta    delta_id=activation
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=activation
    taf_admin.Teardown Admin    connection=activation
    taf_admin.Setup Admin      remote_host=10.44.149.147   name=activation_remote
    taf_admin.Create_Delta    delta_id=activation_remote
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-50832/NRBTS-50832    actPlmnCellResForOpUse    true    delta_id=activation_remote
    ${delta_remote}   taf_admin.Get_Delta    delta_id=activation_remote
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta_remote}    connection=activation_remote
    taf_admin.Teardown Admin    connection=activation_remote


Set CB009010 parameters
    [Arguments]    ${value_1}    ${value_2}
    Log To Console    \nSetting CB009010 parameters
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Create_Delta    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actPlmnCellResForOpUse    ${value_1}    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRPLMNSET_SA-1    cellReservedForOperatorUse
    ...                                         ${value_2}    delta_id=activation
    ${delta}    taf_admin.Get_Delta    delta_id=activation
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=activation
    taf_admin.Teardown Admin    connection=activation


Set cellReservedForOperatorUse
    [Arguments]    ${cellReservedForOperatorUse}    ${distname}=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-12288/ADJ_NRPLMNSET_NSA-1
    Log To Console    \nSetting cellReservedForOperatorUse parameter...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Create_Delta    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta    ${distname}    cellReservedForOperatorUse
    ...                                           ${cellReservedForOperatorUse}    delta_id=activation
    ${delta}    taf_admin.Get_Delta    delta_id=activation
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=activation
    taf_admin.Teardown Admin    connection=activation


Set Capacity Parameters
    [Arguments]    ${maxNumOfSCellAlloc}    ${maxNumOfUsersPerCell}
    Log To Console    \nSetting capacity parameters...
    taf_admin.Setup Admin      remote_host=10.44.149.147    name=activation
    taf_admin.Create_Delta    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-50832/NRBTS-50832/NRCELL-1    maxNumOfSCellAlloc
    ...                                           ${maxNumOfSCellAlloc}    delta_id=activation
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-50832/NRBTS-50832/NRCELL-1    maxNumOfUsersPerCell
    ...                                           ${maxNumOfUsersPerCell}    delta_id=activation
    ${delta}    taf_admin.Get_Delta    delta_id=activation
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=activation
    taf_admin.Teardown Admin    connection=activation


Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nradjnrcell_status
    ${nrrel_status}    taf_admin.Get Scf    connection=nradjnrcell_status
    ${distname_1}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}
    ${distname_2}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_NSA-1
    ${distname_3}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-1
    ${distname_4}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-2
    ${distname_5}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-3
    ${distname_6}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRREL-25
    Should Contain    ${nrrel_status}    ${distname_1}
    Should Contain    ${nrrel_status}    ${distname_2}
    Should Contain    ${nrrel_status}    ${distname_3}
    Should Contain    ${nrrel_status}    ${distname_4}
    Should Contain    ${nrrel_status}    ${distname_5}
    Should Contain    ${nrrel_status}    ${distname_6}
    taf_admin.Teardown Admin    connection=nradjnrcell_status


Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2
    taf_admin.Setup Admin      remote_host=10.44.149.147   name=nradjnrcell_status_remote
    ${nrrel_status}    taf_admin.Get Scf    connection=nradjnrcell_status_remote
    ${distname_1}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}
    ${distname_2}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_NSA-1
    ${distname_3}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-1
    ${distname_4}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-2
    ${distname_5}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-3
    ${distname_6}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-4
    ${distname_7}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRCELL-1/NRREL-25
    Should Contain    ${nrrel_status}    ${distname_1}
    Should Contain    ${nrrel_status}    ${distname_2}
    Should Contain    ${nrrel_status}    ${distname_3}
    Should Contain    ${nrrel_status}    ${distname_4}
    Should Contain    ${nrrel_status}    ${distname_5}
    Should Contain    ${nrrel_status}    ${distname_6}
    Should Contain    ${nrrel_status}    ${distname_7}
    taf_admin.Teardown Admin    connection=nradjnrcell_status_remote


Check NRADJNRCELL NRREL And NRPLMNSETs Not Exists On GNB2
    taf_admin.Setup Admin      remote_host=10.44.149.147   name=nradjnrcell_status_remote
    ${nrrel_status}    taf_admin.Get Scf    connection=nradjnrcell_status_remote
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288/ADJ_NRPLMNSET_NSA-1
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288/ADJ_NRPLMNSET_SA-1
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288/ADJ_NRPLMNSET_SA-2
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRADJNRCELL-12288/ADJ_NRPLMNSET_SA-3
    Should Not Contain    ${nrrel_status}    distName="MRBTS-50832/NRBTS-50832/NRCELL-1/NRREL-25
    taf_admin.Teardown Admin    connection=nradjnrcell_status_remote


Check NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB2 For TC09
    taf_admin.Setup Admin      remote_host=10.44.149.147   name=nradjnrcell_status_remote
    ${nrrel_status}    taf_admin.Get Scf    connection=nradjnrcell_status_remote
    ${distname_1}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}
    ${distname_2}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_NSA-1
    ${distname_3}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-1
    ${distname_4}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-2
    ${distname_5}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-3
    ${distname_6}    Should Match Regexp    ${nrrel_status}    MRBTS-50832/NRBTS-50832/NRCELL-1/NRREL-25
    Should Contain    ${nrrel_status}    ${distname_1}
    Should Contain    ${nrrel_status}    ${distname_2}
    Should Contain    ${nrrel_status}    ${distname_3}
    Should Contain    ${nrrel_status}    ${distname_4}
    Should Contain    ${nrrel_status}    ${distname_5}
    Should Contain    ${nrrel_status}    ${distname_6}
    taf_admin.Teardown Admin    connection=nradjnrcell_status_remote


Check Updated NRADJNRCELL NRREL And NRPLMNSETs Exists On GNB1
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nradjnrcell_status
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  scf_update.xml  connection=nradjnrcell_status
    ${nrrel_status}    taf_admin.Get Scf    connection=nradjnrcell_status
    ${distname_1}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}
    ${distname_2}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_NSA-1
    ${distname_3}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-1
    ${distname_4}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-2
    ${distname_5}    Should Not Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}/ADJ_NRPLMNSET_SA-3
    ${distname_6}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRREL-25
    Should Contain    ${nrrel_status}    ${distname_1}
    Should Contain    ${nrrel_status}    ${distname_2}
    Should Contain    ${nrrel_status}    ${distname_3}
    Should Contain    ${nrrel_status}    ${distname_4}
    Should Not Contain    ${nrrel_status}    ${distname_1}/ADJ_NRPLMNSET_SA-3
    Should Contain    ${nrrel_status}    ${distname_6}
    taf_admin.Teardown Admin    connection=nradjnrcell_status


Verify Inter Frequency Inter Gnb Handover Succeeded From GNB1 To GNB2
    Log To Console    \nChecking HO Success...
    Confirm Handover Succeeded    syslog_path=${current_syslog_path}


Verify Inter Frequency Inter Gnb Handover Succeeded From GNB2 To GNB1
    Log To Console    \nChecking HO Success...
    Confirm Handover Succeeded    syslog_path=${remote_syslog_path}


Verify Handover Not Allowed From Reserved ADJ_NRPLMNSET_NSA
    Log To Console    \nChecking HO not allowed due to reserved PLMN...
    Confirm Handover Not Allowed   syslog_path=${reserved_syslog_path}


Verify Handover Not Allowed To Reserved ADJ_NRPLMNSET_NSA
    Log To Console    \nChecking HO not allowed due to reserved PLMN...
    Confirm Handover Not Allowed    syslog_path=${remote_syslog_path}


Verify Handover Not Allowed To Neutral PLMN
    Log To Console    \nChecking HO not allowed due to neutral PLMN...
    Confirm Handover Not Allowed To Neutral PLMN    syslog_path=${remote_syslog_path}


Verify Attach To Neutral PLMN Failed
    Log To Console    \nChecking Attach To Neutral PLMN Failed...
    confirm_attach_not_allowed    syslog_path=${current_syslog_path}


Check Proper Values For NRPLMNSET Objects For GNB1
    [Arguments]
    Log To Console    \nChecking NRPLMNSET values...
    Setup Infomodel    address=192.168.255.1    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nrplmnset_nsa}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_NSA_A-*    alias=infomodel
    ${query_nrplmnset_sa_1}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-1    alias=infomodel
    ${query_nrplmnset_sa_2}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-2    alias=infomodel
    ${query_nrplmnset_sa_3}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-3    alias=infomodel
    FOR    ${q}    IN    ${query_nrplmnset_nsa}
        Set Test Variable    ${distname_nrplmnset_nsa}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_1}
        Set Test Variable    ${distname_nrplmnset_sa_1}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_2}
        Set Test Variable    ${distname_nrplmnset_sa_2}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_3}
        Set Test Variable    ${distname_nrplmnset_sa_3}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${params_nrplmnset_nsa}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_nsa}    connection=status
    ${params_nrplmnset_sa_1}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_1}    connection=status
    ${params_nrplmnset_sa_2}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_2}    connection=status
    ${params_nrplmnset_sa_3}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_3}    connection=status
    taf_admin.Teardown Admin    connection=status
    FOR    ${parameter}    IN    ${params_nrplmnset_nsa}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-1
        Should Be Equal   ${parameter['nrPlmnDNList'][1]}    MRBTS-50831/NRBTS-50831/NRPLMN-2
        Should Be Equal   ${parameter['nrPlmnDNList'][2]}    MRBTS-50831/NRBTS-50831/NRPLMN-3
        Should Be Equal   ${parameter['nrPlmnDNList'][3]}    MRBTS-50831/NRBTS-50831/NRPLMN-4
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_1}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-1
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_2}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-2
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_3}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-3
    END


Check Proper Values For NRPLMNSET Objects For GNB2
    [Arguments]    ${cellReservedForOperatorUse}=notReserved
    Log To Console    \nChecking NRPLMNSET values...
    Setup Infomodel    address=192.168.255.129    remote_host=10.44.149.147    port=3600    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nrplmnset_nsa}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_NSA_A-*    alias=infomodel
    ${query_nrplmnset_sa_1}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-1    alias=infomodel
    ${query_nrplmnset_sa_2}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-2    alias=infomodel
    ${query_nrplmnset_sa_3}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-3    alias=infomodel
    ${query_nrplmnset_sa_4}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-4    alias=infomodel
    FOR    ${q}    IN    ${query_nrplmnset_nsa}
        Set Test Variable    ${distname_nrplmnset_nsa}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_1}
        Set Test Variable    ${distname_nrplmnset_sa_1}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_2}
        Set Test Variable    ${distname_nrplmnset_sa_2}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_3}
        Set Test Variable    ${distname_nrplmnset_sa_3}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_4}
        Set Test Variable    ${distname_nrplmnset_sa_4}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      remote_host=10.44.149.147    alias=status
    ${params_nrplmnset_nsa}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_nsa}    connection=status
    ${params_nrplmnset_sa_1}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_1}    connection=status
    ${params_nrplmnset_sa_2}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_2}    connection=status
    ${params_nrplmnset_sa_3}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_3}    connection=status
    ${params_nrplmnset_sa_4}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_4}    connection=status
    taf_admin.Teardown Admin    connection=status
    FOR    ${parameter}    IN    ${params_nrplmnset_nsa}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    ${cellReservedForOperatorUse}
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-1
        Should Be Equal   ${parameter['nrPlmnDNList'][1]}    MRBTS-50832/NRBTS-50832/NRPLMN-2
        Should Be Equal   ${parameter['nrPlmnDNList'][2]}    MRBTS-50832/NRBTS-50832/NRPLMN-3
        Should Be Equal   ${parameter['nrPlmnDNList'][3]}    MRBTS-50832/NRBTS-50832/NRPLMN-4
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_1}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-1
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_2}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-2
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_3}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-3
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_4}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-4
    END


Check Proper Values For NRPLMNSET Objects For GNB2 For TC09
    Log To Console    \nChecking NRPLMNSET values...
    Setup Infomodel    address=192.168.255.1    remote_host=10.44.149.147    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nrplmnset_nsa}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_NSA_A-*    alias=infomodel
    ${query_nrplmnset_sa_1}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-1    alias=infomodel
    ${query_nrplmnset_sa_2}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-2    alias=infomodel
    ${query_nrplmnset_sa_3}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-3    alias=infomodel
    FOR    ${q}    IN    ${query_nrplmnset_nsa}
        Set Test Variable    ${distname_nrplmnset_nsa}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_1}
        Set Test Variable    ${distname_nrplmnset_sa_1}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_2}
        Set Test Variable    ${distname_nrplmnset_sa_2}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_3}
        Set Test Variable    ${distname_nrplmnset_sa_3}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      remote_host=10.44.149.147    alias=status
    ${params_nrplmnset_nsa}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_nsa}    connection=status
    ${params_nrplmnset_sa_1}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_1}    connection=status
    ${params_nrplmnset_sa_2}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_2}    connection=status
    ${params_nrplmnset_sa_3}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_3}    connection=status
    taf_admin.Teardown Admin    connection=status
    FOR    ${parameter}    IN    ${params_nrplmnset_nsa}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    reserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-1
        Should Be Equal   ${parameter['nrPlmnDNList'][1]}    MRBTS-50832/NRBTS-50832/NRPLMN-2
        Should Be Equal   ${parameter['nrPlmnDNList'][2]}    MRBTS-50832/NRBTS-50832/NRPLMN-3
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_1}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    reserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-1
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_2}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    reserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-2
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_3}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    reserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50832/NRBTS-50832/NRPLMN-3
    END


Check Proper Values For Updated NRPLMNSET Objects For GNB1
    [Arguments]
    Log To Console    \nChecking NRPLMNSET values...
    Setup Infomodel    address=192.168.255.1    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nrplmnset_nsa}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_NSA_A-*    alias=infomodel
    ${query_nrplmnset_sa_1}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-1    alias=infomodel
    ${query_nrplmnset_sa_2}=    Query Infomodel    query=get object //ADJ_NRPLMNSET_SA_A-2    alias=infomodel
    FOR    ${q}    IN    ${query_nrplmnset_nsa}
        Set Test Variable    ${distname_nrplmnset_nsa}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_1}
        Set Test Variable    ${distname_nrplmnset_sa_1}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrplmnset_sa_2}
        Set Test Variable    ${distname_nrplmnset_sa_2}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${params_nrplmnset_nsa}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_nsa}    connection=status
    ${params_nrplmnset_sa_1}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_1}    connection=status
    ${params_nrplmnset_sa_2}=    taf_admin.Get Parameters    dist_name=${distname_nrplmnset_sa_2}    connection=status
    taf_admin.Teardown Admin    connection=status
    FOR    ${parameter}    IN    ${params_nrplmnset_nsa}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-1
        Should Be Equal   ${parameter['nrPlmnDNList'][1]}    MRBTS-50831/NRBTS-50831/NRPLMN-2
        Should Be Equal   ${parameter['nrPlmnDNList'][2]}    MRBTS-50831/NRBTS-50831/NRPLMN-3
        Should Not Contain   ${parameter['nrPlmnDNList']}    MRBTS-50831/NRBTS-50831/NRPLMN-4
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_1}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-1
    END
    FOR    ${parameter}    IN    ${params_nrplmnset_sa_2}
        Should Be Equal   ${parameter['cellReservedForOperatorUse']}    notReserved
        Should Be Equal   ${parameter['nrPlmnDNList'][0]}    MRBTS-50831/NRBTS-50831/NRPLMN-2
    END
