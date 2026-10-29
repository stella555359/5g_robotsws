*** Settings ***
Documentation
...    author: y6lu
...    contact: lu.yu@nokia-sbell.com
...    Description:

Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.transport.ssh  WITH NAME  ssh
Library    ../resources/libraries/dcap_server_1.py
Library    ../resources/libraries/snapshot_files.py
Library    ../resources/libraries/sherpa_server_1.py
Library    ../resources/libraries/ui_operation.py
Resource   ../resources/pm_logs_frame.robot
Resource   ../resources/pm_logs_general.robot
Resource    ../resources/ssh_utils.robot
Resource   ../resources/verdicts.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/emil/test_emil.robot
Resource    ../resources/emil/emil.robot
Resource    ../resources/emil/dcap.robot
Resource    ../resources/emil/test_port.robot
Resource    ../resources/emil/decode.robot
Resource    ../resources/emil/tshark.robot
Resource    ../resources/emil/sherpa.robot

*** Variables ***
${XN_status}
${ZMQ_status}
${CPNRT_status}
${CPRT_status}
${CPIF_status}
${COAM_status}
${CPUE_status}
${NSA_status}
${bbmod_reset_for_1808}    ${false}

*** Keywords ***
TC__CB009514_A_5GC000794_ASOG_CRT
    run keyword and continue on failure   CB009514_1_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
#    run keyword and continue on failure   CB009514_2_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
#    run keyword and continue on failure   CB009514_3_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_bin_file_for_ABIP
#    run keyword and continue on failure   CB009514_4_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_pcap_file_for_ABIP
#    run keyword and continue on failure   CB009514_6_Recommission_Type_of_actEcpri72e

CB009514_1_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    [Timeout]    60min
    Case Setup: CB009514_CRT
    Check SA Msg in the Log    log_path=${output_txt_path}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed


CB009514_2_5GC001808_RRC_XN_NG_ZMQ_and_SYSCOM_via_Emil_1681_RETRY_TEST_for_ABIP
    Case Setup: CB009514_CRT
    Check Xn Msg in the Log    log_path=${output_txt_path}
    Check Zmq Msg in the Log    log_path=${output_txt_path}
    Check CP-NRT Syscom messages    log_path=${output_txt_path}
    Check CP-RT Syscom messages    log_path=${output_txt_path}
    Check CP-IF Syscom messages    log_path=${output_txt_path}
    Check COAM Syscom messages   log_path=${output_txt_path}
    Check CP-UE Syscom messages    log_path=${output_txt_path}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed

CB009514_3_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_bin_file_for_ABIP
    [Timeout]    60min
    Case Setup: CB009514_CRT
    L3 CALL For TTI Bin Prepare
    ${key_TTI}    check snapshot_TTI
    Check TTI Decoder Tool    input_file=${key_TTI}
    [Teardown]  Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed

CB009514_4_5GC001808_D_TTI_Trace_Analyses_Tool_Decode_pcap_file_for_ABIP
    [Timeout]    60min
    ${gnb_custom_profile}   create list    L2Ps_Component
    Cplane and Uplane log Setup For Case   operation=sleep  gnb_custom_profile=${gnb_custom_profile}
    Check TTI Decoder Tool    ${l2ps_log_path}
    [Teardown]  Run keywords
    ...    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Collect Snapshot and Screenshot If Keyword Failed
    ...    AND   CP and UP log Teardown

#CB009514_5_5GC001808_C_CP-Cell_CP-NB_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
#    [Timeout]    60min
#    Case Setup: CB009514_CRT
#    ${gnb_custom_profile}   create list    cp_5g
#    run keyword unless    ${bbmod_reset_for_1808}    Cplane log Setup   operation=resetrat  gnb_custom_profile=${gnb_custom_profile}
#    Check CP-CELL Syscom messages    log_path=${output_txt_path}  # need gnb reboot
#    Check CP-NB Syscom messages    log_path=${output_txt_path}     # need gnb reboot
#    [Teardown]    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Collect Snapshot and Screenshot If Case Failed

CB009514_6_Recommission_Type_of_actEcpri72e
    [Timeout]    60min
    Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=2t4r
    Pre&Post Conditoin: Update Configuration of actEcpri72e     celltype=4t4r
    [Teardown]    Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Collect Snapshot and Screenshot If Keyword Failed

Case Setup: CB009514_CRT
    Cplane log Setup

Cplane log Setup
    [Arguments]     ${operation}=call     ${gnb_custom_profile}=${gnb_custom_type}
    log to console   \n Cplane log Setup
    COAM Login   alias=${coam_alias}
#    ${gnb_release}   Get gnb release
#    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
#    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
    COAM WEBUI Whether Close Start Up View Window
    common.Set Output Log Path
    Configure Logging Agent    uplane_destination=${EMPTY}    source_ip=${EMPTY}
    run keyword and ignore error    Delete Emil script and logs on sherpa
    Start Dcap Basic trace    gnb_custom_profile=${gnb_custom_profile}
    Gnb Operation During Flowtracer Trace    operation=${operation}
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    ${nodeinfo}    Get GNB Node ID After BSH Removed
    set suite variable   ${nodeinfo}
    Upload Emil script and logs on sherpa
    Mkdir for EMil script and logs on sherpa
    Convert emil log at sherpa   log_path_list=${emil_log_file_list}    end_file=5gm
    set suite variable     ${bbmod_reset_for_1808}    ${false}

CP and UP log Teardown
    log to console   \n Cplane and Uplane loge Teardown
    run keyword and ignore error    Stop DCAP log
    run keyword and ignore error    Dcap delete trace    trace_id=${result_id}
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   ssh.Disconnect   connection=${call_alias}


Pre&Post Conditoin: Update Configuration of actEcpri72e
     [Arguments]   ${celltype}=4t4r
#     log to console    Modify_Vendor
#     ${to_4t4r}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">Ecpri72eULDL</p>|g' vendor_5g.xml
#     ${to_2t4r}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">Ecpri72eULDL</p>|g' vendor_5g.xml
#     ${to_defualt}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">disabled</p>|g' vendor_5g.xml
#     coam.connect to    bts_host=${WEBUI_ADDR}    username=${WEBUI_USER}
#     ...   password=${WEBUI_PASSWORD}    name=coam_admin
#     coam.download_vendor_file    target_file_name=${OUTPUT_DIR}/vendor_5g.xml    connection=coam_admin
#     sleep    3s
#     run keyword if    '${celltype}'=='4t4r'   Update Vendor Parameter    ${to_4t4r}
#     ...    ELSE IF    '${celltype}'=='2t4r'   Update Vendor Parameter    ${to_2t4r}
#     ...    ELSE IF    '${celltype}'=='default'   Update Vendor Parameter    ${to_defualt}
     run keyword if   '${celltype}'=='4t4r'    Load and Commission With Cell Type Updated    type_to_update=4T4R
     ...    ELSE IF    '${celltype}'=='2t4r'     Load and Commission With Cell Type Updated    type_to_update=2T4R
     ...    ELSE IF    '${celltype}'=='default'    Load and Commission With Cell Type Updated    type_to_update=default
     Wait Until Keyword Succeeds   5m   30s   gNB not Connected
     Wait Until Keyword Succeeds   5m   10s   Try Connect gNB
#     run keyword if    '${celltype}'!='default'   Online Update BBPOOL Value As WA of CB010891
     Wait Until Keyword Succeeds   1m   30s   COAM Login
     Wait Until Keyword Succeeds   15m   30s   COAM Check All Cells Onair
     [Teardown]    run keyword and ignore error   COAM WEBUI Logout

Load and Commission With Cell Type Updated
    [Arguments]  ${type_to_update}
     run keyword and ignore error    COAM WEBUI Login
#     ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#     Run keyword if   '${result}'=='Validation failed!'
#     ...   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#     sleep   5s
     run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
     selenium_coam.load_commissioning_file_and_check_load_status
     ...   file_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL${Instance_Id}_${type_to_update}.xml   timeout=${120}
     selenium_coam.validate_plan
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    [Teardown]    run keywords   run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
     ...   AND   run keyword and ignore error   COAM WEBUI Logout
     ...   AND   run keyword and ignore error   coam.teardown   connection=coam_admin

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
