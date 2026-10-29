# *** Settings ***
# Documentation      author: Chen Xiaodong
# ...                contact: xiaodong.d.chen@nokia-sbell.com
# ...                Group: HGZ_SG2
# Suite Setup       Run Keyword And Ignore Error    679 Suite Setup
# Suite Teardown    Run Keyword And Ignore Error    679 Suite TearDown
# Force Tags        5G_RRM          CB006667
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          Resources/5GC000679_common_keyword_Dingli.robot
# Resource          ../5GC001655/Resources/1347_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         Resources/6667_modify_para.py
# 
# *** Variables ***
# ${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${679_Korea_default_scf}    ${tmp_swconfig_dir}/6667_default_scf.xml
# ${apn1}    ${tl.core.pdns[0].apn}
# 
# ${scf_path_24R2}     /home/ute/Downloads/SCF/SBTS24R2
# ${scf_path_24R1}     /home/ute/Downloads/SCF/SBTS24R1
# ${scf_path_24R3}     /home/ute/Downloads/SCF/SBTS24R3
# 
# #22R1/22R2 pdsch filter
# ${pdsch_filter}    \"dldata_pdschsendreq\"
# ${luashark_path_22R3}    /home/ute/Downloads/Lua_SBTS22R3/generated_luashark/luashark.lua
# ${luashark_path_22R2}    /home/ute/Downloads/Lua_SBTS22R2/generated_luashark/luashark.lua
# ${command_template_DL_22R3}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R3} -Y ${pdsch_filter} -T pdml
# ${command_template_DL_22R2}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R2} -Y ${pdsch_filter} -T pdml
# ${pdsch_rnti_dl_22R3}    DlData_PdschSendReq.grants_item_0.rnti
# ${pdsch_rnti_dl_22R2}    DlData_PdschSendReq.grants_item_0.rnti
# ${pdsch_sfn_dl}    DlData_PdschSendReq.PdschSendReq.sfn    
# ${pdsch_slot_dl}    .//DlData_PdschSendReq.PdschSendReq.slot
# 
# #22R1/22R2 pusch filter
# ${pusch_filter}    \"uldata_puschreceivereq\"
# ${command_template_UL_22R3}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R3} -Y ${pusch_filter} -T pdml
# ${command_template_UL_22R2}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R2} -Y ${pusch_filter} -T pdml
# ${pusch_rnti_ul_22R3}    .//UlData_PuschReceiveReq.grants_item_0.rnti
# ${pusch_rnti_ul_22R2}    .//UlData_PuschReceiveReq.grants_item_0.rnti
# ${pusch_sfn_ul}    UlData_PuschReceiveReq.PuschReceiveReq.sfn
# ${pusch_slot_ul}    .//UlData_PuschReceiveReq.PuschReceiveReq.slot
# 
# ${data_transfer_dl}     250Mbits/sec
# ${data_transfer_ul}     50Mbits/sec
# ${Expected_Throughput_DL}     10
# ${Expected_Throughput_UL}     1
# 
# *** Test Cases ***
# [1]CB006667_5G_HA_1_NonDBF_CPRI_NSA_TDD_FR1_DL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    6667    NSA    DLUL    100M
#     [Setup]    Case Setup 6667
#     #GNB is ready
#     #Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case1.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=40
#     Check throughput on gNB    direction=ul    throughput=5
#     All UEs Check Tput    num=16
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    16
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    16
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    273
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    237
#     Check FDM for 6667    FDM_UE_num_dl=16    FDM_UE_num_ul=16
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    j=16    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=16    apn_address=${apn1}
# 
# [1]CB006667_5G_HA_2_NonDBF_CPRI_NSA_TDD_FR1_UL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    6667    NSA    DLUL    80M
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_80MHz}
#     Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case2.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=40
#     Check throughput on gNB    direction=ul    throughput=5
#     All UEs Check Tput    num=16
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    14
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    16
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    217
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    181
#     Check FDM for 6667    FDM_UE_num_dl=14    FDM_UE_num_ul=16
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    j=16    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=16    apn_address=${apn1}
# 
# [1][1.0] CB006667_5G_HA_3_NonDBF_CPRI_NSA_TDD_FR1_DL_UL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    CRT    6667    NSA    100M    8UE    
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_60MHz}
#     Run Keyword And Ignore Error    Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case3.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "8UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    duration=3s    
#     Run Keyword And Ignore Error    Start Bip Logs Capture and download logs via webUI
#     sleep    5s
#     log to console      "8UE_check_Tput"
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=40
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=5
#     Run Keyword And Ignore Error    All UEs Check Tput    num=8
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_DL}    8
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     #Run Keyword And Ignore Error    Should Contain    ${counter_allPRB_DL}    273
#     #Check FDM for 6667    FDM_UE_num_dl=8    FDM_UE_num_ul=8
#     log to console      "8UE_stop_Tput"
#     All UEs Stop traffic    j=8    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=8    apn_address=${apn1}
# 
# [1][1.0] FGCR_8181_BB_01_SA_TDD_UL_scheduling_10UEs_with_2subcell_100MHz_cmW(Full_buffer_all_UEs_half_in_goodRC)
#     [Tags]    CRT    6667    NSA    100M    8UE    
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_60MHz}
#     Run Keyword And Ignore Error    Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case3.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "8UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    duration=3s    
#     Run Keyword And Ignore Error    Start Bip Logs Capture and download logs via webUI
#     sleep    5s
#     log to console      "8UE_check_Tput"
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=40
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=5
#     Run Keyword And Ignore Error    All UEs Check Tput    num=8
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_DL}    8
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     #Run Keyword And Ignore Error    Should Contain    ${counter_allPRB_DL}    273
#     #Check FDM for 6667    FDM_UE_num_dl=8    FDM_UE_num_ul=8
#     log to console      "8UE_stop_Tput"
#     All UEs Stop traffic    j=8    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=8    apn_address=${apn1}
# 
# [1][1.0] FGCR_8181_BA_01_NSA_TDD_UL_scheduling_10UEs_with_2subcell_100MHz_cmW(Full_buffer_all_UEs_half_in_goodRC)
#     [Tags]    CRT    6667    NSA    100M    8UE    
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_60MHz}
#     Run Keyword And Ignore Error    Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case3.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "8UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    duration=3s    
#     Run Keyword And Ignore Error    Start Bip Logs Capture and download logs via webUI
#     sleep    5s
#     log to console      "8UE_check_Tput"
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=40
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=5
#     Run Keyword And Ignore Error    All UEs Check Tput    num=8
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_DL}    8
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     #Run Keyword And Ignore Error    Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     #Run Keyword And Ignore Error    Should Contain    ${counter_allPRB_DL}    273
#     #Check FDM for 6667    FDM_UE_num_dl=8    FDM_UE_num_ul=8
#     log to console      "8UE_stop_Tput"
#     All UEs Stop traffic    j=8    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=8    apn_address=${apn1}
# 
# [1]CB006667_5G_HA_4_NonDBF_CPRI_NSA_TDD_FR1_DL_UL_IncreasedFdm_16UEs_longPucch_differentQCIWeight
#     [Tags]    6667    NSA    DLUL    20M
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_20MHz}
#     Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case4.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=40
#     Check throughput on gNB    direction=ul    throughput=5
#     All UEs Check Tput    num=16
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    8
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    51
#     Check FDM for 6667    FDM_UE_num_dl=8    FDM_UE_num_ul=8
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    j=16    apn_address=${apn1}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    n=16    apn_address=${apn1}
# 
# [1]CB006667_5G_HA_5_NonDBF_CPRI_SA_TDD_FR1_DL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    6667    SA    DLUL    90M
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_90MHz}
#     #Load Case SCF and Commission    scf_file=${6667_case5}
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    apn_address=ims    ue_mode=SA    attach_mode=5G_SA
#     #All UEs attach again    attach_mode=5G_SA
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=40
#     Check throughput on gNB    direction=ul    throughput=5
#     All UEs Check Tput    num=16
#     sleep    300s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    16
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    16
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    245
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    197
#     Check FDM for 6667    FDM_UE_num_dl=16    FDM_UE_num_ul=16
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    ue_mode=SA     apn_address=ims    j=16
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    ue_mode=SA     apn_address=ims    n=16
# 
# [1]CB006667_5G_HA_6_NonDBF_CPRI_SA_TDD_FR1_UL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    6667    SA    DLUL    60M
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_60MHz}
#     #Load Case SCF and Commission    scf_file=${6667_case6}
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    apn_address=ims    ue_mode=SA    attach_mode=5G_SA
#     #All UEs attach again    attach_mode=5G_SA
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=40
#     Check throughput on gNB    direction=ul    throughput=5
#     All UEs Check Tput    num=16
#     sleep    300s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    11
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    16
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    162
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    124
#     Check FDM for 6667    FDM_UE_num_dl=11    FDM_UE_num_ul=16
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    ue_mode=SA     apn_address=ims    j=16
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    ue_mode=SA     apn_address=ims    n=16
# 
# [1]CB006667_5G_HA_7_NonDBF_CPRI_SA_TDD_FR1_DL_UL_IncreasedFdm_16UEs_longPucch_differentBandwidth
#     [Tags]    6667    SA    DLUL    20M
#     [Setup]    Case Setup 6667
#     #GNB is ready    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_20MHz}
#     #Load Case SCF and Commission    scf_file=${6667_case7}
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "16UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    apn_address=ims    ue_mode=SA    attach_mode=5G_SA
#     #All UEs attach again    attach_mode=5G_SA
#     Common Capture BIP log and download
#     sleep    5s
#     log to console      "16UE_check_Tput"
#     Check throughput on gNB    direction=dl    throughput=15
#     Check throughput on gNB    direction=ul    throughput=1
#     All UEs Check Tput    num=16
#     sleep    300s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    8
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    51
#     Check FDM for 6667    FDM_UE_num_dl=8    FDM_UE_num_ul=8
#     log to console      "16UE_stop_Tput"
#     All UEs Stop traffic    ue_mode=SA     apn_address=ims    j=16
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    ue_mode=SA     apn_address=ims    n=16
# 
# [1]CB006667_5G_HA_8_NonDBF_CPRI_SA_TDD_FR1_DL_UL_IncreasedFdm_16UEs_longPucch_differentQCIWeight
#     [Tags]    CB008116    SA    DLUL    100M    8UE
#     [Setup]    Case Setup 6667
#     Run Keyword And Ignore Error    Load Case SCF and Commission    default_scf=${scf_path}/CB006667_case3.xml
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
#     Set test variable    ${ue_type}
#     log to console      "8UE_attach_Tput"
#     All spark UEs attach and start DLUL traffic    duration=3s   
#     Run Keyword And Ignore Error    Start Bip Logs Capture and download logs via webUI
#     sleep    5s
#     log to console      "8UE_check_Tput"
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=40
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=5
#     Run Keyword And Ignore Error    All UEs Check Tput    num=8
#     sleep    600s
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     #Should Contain    ${counter_scheUE_DL}    16
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     #Should Contain    ${counter_scheUE_UL}    16
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     #Should Contain    ${counter_allPRB_DL}    133
#     log to console      "8UE_stop_Tput"
#     All UEs Stop traffic    ue_mode=SA     apn_address=dxdata2    j=8
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    ue_mode=SA     apn_address=dxdata2   n=8
# 
# *** Keywords ***
# Case Setup 6667
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS24R2' in ${result}    set test variable    ${scf_path}    ${scf_path_24R2}
#     ...    ELSE IF    'SBTS24R3' in ${result}    set test variable    ${scf_path}    ${scf_path_24R3}
#     ...    ELSE IF    'SBTS24R1' in ${result}    set test variable    ${scf_path}    ${scf_path_24R1}
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_DL}    ${command_template_DL_22R2}
#     ...       ELSE     set test variable    ${command_template_DL}    ${command_template_DL_22R3}    
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_UL}    ${command_template_UL_22R2}
#     ...       ELSE     set test variable    ${command_template_UL}    ${command_template_UL_22R3}    
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pdsch_rnti_dl}    ${pdsch_rnti_dl_22R2}
#     ...       ELSE     set test variable    ${pdsch_rnti_dl}    ${pdsch_rnti_dl_22R3}    
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pusch_rnti_ul}    ${pusch_rnti_ul_22R2}
#     ...       ELSE     set test variable    ${pusch_rnti_ul}    ${pusch_rnti_ul_22R3}
#     Run keyword if    'SBTS22R2' in ${result}    set test variable    ${lua_path}    ${luashark_path_22R2}
#     ...       ELSE     set test variable    ${lua_path}    ${luashark_path_22R3}
#     robot_common_operations.Common Case Setup 
# 
# Start Bip Logs Capture and download logs via webUI
#     ${logs_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
#     Set Test Variable    ${logs_timestamp}
#     Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${logs_timestamp}
#     sleep    3s
#     ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${logs_timestamp}
#     [Return]    ${bip_log}
# 
# Capture BIP log and download on ABIO
#     [Arguments]     ${duration}=1s
#     Connect to Common Unit Master
#     Start Bip Log Capture on Loki
#     Sleep    ${duration}
#     ${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
#     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
# 
# Spark UE attach
#     [Arguments]    ${n}    ${attach_mode}    ${get_spark_license}=False
#     [Documentation]    Attach
#     ...          :param  n: The ue_index of Spark
#     ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
#     ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
#     log to console      "Prepare_UE${n}"
#     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
#     sleep      3s
#     log to console      "attach_UE${n}"
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     attach_mode=${attach_mode}    ue_index=${n}
#     power_ue.Verify attach     ue_type=${ue_type}    4G_check=True    5Grach_ed=${5Grach_ed}     ue_index=${n}
# 
# All UEs attach again
#     [Arguments]    ${attach_mode}=5G_NSA
#     FOR    ${i}    IN RANGE    16
#         spark.power_off    ue_alias=UE_${i}
#         spark.power_on     ue_alias=UE_${i}     
#     END
# 
# spark attach and start DLUL traffic
#     [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
#     ...             ${apn_address}    ${ue_mode}    ${attach_mode}
#     [Documentation]    Attach_start_DL_UL_tput
#     ...          :param  n: The ue_index of Spark
#     ...          :param  ue_mode: start traffic for NSA or SA
#     ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
#     ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
#     run keyword and ignore error    Spark UE attach    n=${n}    attach_mode=${attach_mode}
#     sleep      2s
#     power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
#     ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
#     power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
#     ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
# 
# All spark UEs attach and start DLUL traffic
#     [Arguments]     ${apn_address}=${apn1}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
#     FOR    ${i}    IN RANGE    8
#         spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
#         ...                                     data_transfer_ul=${data_transfer_ul}
#         ...                                     n=${i}
#         ...                                     ue_mode=${ue_mode}
#         ...                                     attach_mode=${attach_mode}
#         ...                                     apn_address=${apn_address}
#     END
# 
# All spark UEs attach and start DL traffic
#     [Arguments]     ${apn_address}=${apn1}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
#     FOR    ${i}    IN RANGE    16
#         Spark UE attach    n=${i}    attach_mode=${attach_mode}
#         sleep      8s
#         power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=1200
#         ...                        ue_index=${i}    ue_mode=${ue_mode}    apn_address=${apn_address}
#     END
# 
# All spark UEs attach and start UL traffic
#     [Arguments]     ${apn_address}=${apn1}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
#     FOR    ${i}    IN RANGE    16
#         Spark UE attach    n=${i}    attach_mode=${attach_mode}
#         sleep      8s
#         power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=1200
#         ...                        ue_index=${i}    ue_mode=${ue_mode}    apn_address=${apn_address}
#     END
# 
# Get dl pdml from 6667 bip
#     [Arguments]    ${pcap_file}=${bip_log_path}   ${output}=${TS_CASE_LOG_PATH}/6667_dl.pdml
# 	Set Test Variable    ${dl_command}    ${tshark_path} -r ${pcap_file} -X lua_script:${lua_path} -Y ${pdsch_filter} -T pdml > ${output}
#     Run    ${dl_command}
# 
# Get ul pdml from 6667 bip
#     [Arguments]    ${pcap_file}=${bip_log_path}    ${output}=${TS_CASE_LOG_PATH}/6667_ul.pdml
# 	Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -X lua_script:${lua_path} -Y ${pusch_filter} -T pdml > ${output}
#     Run    ${ul_command}
# 	
# Check FDM for 6667
#     [Arguments]     ${FDM_UE_num_dl}    ${FDM_UE_num_ul}
#     log to console      "bip_FDM_check_DL"
#     Get dl pdml from 6667 bip
#     run keyword and continue on failure    Get Item Num Per Slot    file_path=${TS_CASE_LOG_PATH}/6667_dl.pdml
#     ...                                                             dl_or_ul=dl    rnti_num=${FDM_UE_num_dl}    pid_rate=0    
#     log to console      "bip_FDM_check_UL"
#     Get ul pdml from 6667 bip
#     run keyword and continue on failure    Get Item Num Per Slot    file_path=${TS_CASE_LOG_PATH}/6667_ul.pdml
#     ...                                                             dl_or_ul=ul    rnti_num=${FDM_UE_num_ul}    pid_rate=0
# 
# Check FDM from bip log
#     [Arguments]     ${FDM_UE_num_dl}    ${FDM_UE_num_ul}
#     log to console      "bip_FDM_check_DL"
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}    
#     ...                                                      command_template=${command_template_DL}        
#     run keyword and continue on failure    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_dl}
#     ...                                                               field_name_slot=${pdsch_slot_dl}    
#     ...                                                               item_name=${pdsch_rnti_dl}  
#     ...                                                               target_item_num=${FDM_UE_num_dl}
#     log to console      "bip_FDM_check_UL"
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}    
#     ...                                                      command_template=${command_template_UL}        
#     run keyword and continue on failure    Check Item Num Per Slot    field_name_sfn=${pusch_sfn_ul}
#     ...                                                               field_name_slot=${pusch_slot_ul}    
#     ...                                                               item_name=${pusch_rnti_ul}  
#     ...                                                               target_item_num=${FDM_UE_num_ul}
