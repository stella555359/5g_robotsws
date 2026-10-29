*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     DateTime
Library     ta_attenuator
Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     ute_ue
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ute_tshark   WITH NAME   tshark
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008239/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.anr_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT322/ue_config.yaml
${GNB_1_CELL_1_ALIAS}       GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}       GNB_1_CELL_2
${GNB_1_CELL_3_ALIAS}       GNB_1_CELL_3
${GNB_2_CELL_1_ALIAS}       GNB_2_CELL_1
${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${VM_IP}                    ${tl.test_pc[0].default_ssh_connection_details.addr}
${NRADJECELL}               ${EMPTY}

*** Keywords ***
Test Setup
    [Arguments]  ${require_ue}=${TRUE}  ${auto_removal}=false  ${idle_time_removal}=3  ${maxNumNrAnrMoiAllowed}=20000
    ...          ${maxNumAnrNrrelePerCell}=50
    Teardown All Admin Sessions
    Remove Special Characters From Anr Testname
    Set Test Variable  ${require_ue}
    Delete All Nrrele And Nradjecell Objects
    IF  ${require_ue}  Prepare Ue
    Set Initial Parameters   ${auto_removal}  ${idle_time_removal}  ${maxNumNrAnrMoiAllowed}  ${maxNumAnrNrrelePerCell}
    Collect SCF Before Test


Test Teardown
    IF   ${require_ue} == ${TRUE}   Run Keywords
    ...    Run Keyword And Continue On Failure    Detach Ue    UE_1   AND
    ...    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_1_CELL_3_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB    AND
    ...    Release Attenuator
    Run Keyword And Ignore Error    Stop Collecting Syslog
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog
    Run Keyword If Test Failed      Collect Snapshot
    Add Scout Scf Id To Test Data
    Delete All Nrrele And Nradjecell Objects
    Teardown All Admin Sessions
    Run Keyword And Ignore Error    interface.Common Step Trigger


Teardown All Admin Sessions
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_del
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_status
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nradjcell_status
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrele_status
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=anr_activation
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=object_creation
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark


Start Collecting Logs
    Start Collecting Syslog   alias=5g
    IF   ${require_ue} == ${TRUE}    Start Tcpdump On CU    filename=${test_name}_SCTP.pcap
    Log to Console    Logging started...


Stop Collecting Logs
    Stop Collecting Syslog      alias=5g
    IF   ${require_ue} == ${TRUE}    Run Keywords    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap    AND
    ...              Move File   ${LOG_PATH}/${test_name}_SCTP.pcap   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap    AND
    ...              Set Test Variable   ${pcap_path}   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    Log to Console    Logging stopped...


Stop Collecting Tcpdump
    IF   ${require_ue} == ${TRUE}    Run Keywords    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap    AND
    ...              Move File   ${LOG_PATH}/${test_name}_SCTP.pcap   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap    AND
    ...              Set Test Variable   ${pcap_path}   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    Log to Console    Logging stopped...


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${GNB_IP}     alias=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb
    taf_admin.Teardown Admin    connection=admin_gnb


Start Collecting Syslog
    [Arguments]    ${alias}=5g
    taf_syslog.Start Syslog  log_dir=${LOG_PATH}/${test_name}/syslog/  log_name=syslog_${alias}.log
    ...  ip=192.168.255.126  alias=${alias}
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias}.log
    Sleep  5s


Stop Collecting Syslog
    [Arguments]    ${alias}=5g
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${alias}
    RETURN      ${file_path}


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2    GNB_1_CELL_3   GNB_2_CELL_1
    Set global variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_3_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Sleep  2s


Release Attenuator
    Release Attenuator Cell    ${GNB_CELLS}


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Perform Attach
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Attach UE    UE_1
    Log To Console    UE_1 attached!
    Sleep   10s


Collect Snapshot
    Log To Console    \nCollecting BTS Snapshot!
    Make Snapshot In Case Of Error


Wait One Removal Cycle
    Start Collecting Syslog    alias=wait_one_cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    ${LOG_PATH}/${test_name}/syslog/syslog_wait_one_cycle.log   auto_removal=${TRUE}
        ${date}  Get Current Date
        IF    ${fire_counter} == 1    BREAK
        Sleep    5s
    END
    Stop Collecting Syslog    alias=wait_one_cycle


Set Anr Activation Flag
    [Arguments]  ${anr_activation_flag}=true
    Log To Console    \nSetting Up Anr Activation Flag
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=anr_activation
    taf_admin.Create_Delta    delta_id=anr_activation
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}  actSaUeBasedAnrEutra
    ...  ${anr_activation_flag}    delta_id=anr_activation
    ${delta}    taf_admin.Get_Delta    delta_id=anr_activation
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=anr_activation
    taf_admin.Teardown_Admin    alias=anr_activation


Set maxNumNrAnrMoiAllowed
    [Arguments]  ${maxNumNrAnrMoiAllowed}
    Log To Console    \nSetting maxNumNrAnrMoiAllowed to 1
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=maxNumNrAnrMoiAllowed
    taf_admin.Create_Delta    delta_id=maxNumNrAnrMoiAllowed
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}  maxNumNrAnrMoiAllowed
    ...  ${maxNumNrAnrMoiAllowed}    delta_id=maxNumNrAnrMoiAllowed
    ${delta}    taf_admin.Get_Delta    delta_id=maxNumNrAnrMoiAllowed
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=maxNumNrAnrMoiAllowed
    taf_admin.Teardown_Admin    alias=maxNumNrAnrMoiAllowed


Set maxNumAnrNrrelePerCell
    [Arguments]  ${maxNumAnrNrrelePerCell}
    Log To Console    \nSetting maxNumAnrNrrelePerCell to ${maxNumAnrNrrelePerCell}
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=maxNumAnrNrrelePerCell
    taf_admin.Create_Delta    delta_id=maxNumAnrNrrelePerCell
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPRE-1  maxNumAnrNrrelePerCell
    ...  ${maxNumAnrNrrelePerCell}    delta_id=maxNumAnrNrrelePerCell
    ${delta}    taf_admin.Get_Delta    delta_id=maxNumAnrNrrelePerCell
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=maxNumAnrNrrelePerCell
    taf_admin.Teardown_Admin    alias=maxNumAnrNrrelePerCell


Set Initial Parameters
    [Arguments]  ${auto_removal}  ${ide_time_removal}  ${maxNumNrAnrMoiAllowed}  ${maxNumAnrNrrelePerCell}
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=initial_params
    taf_admin.Create_Delta    delta_id=initial_params
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1  actAutoEutraNbRemoval
    ...  ${auto_removal}    delta_id=initial_params
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPRE-1  idleTimeForEutraNbRemoval
    ...  ${ide_time_removal}    delta_id=initial_params
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}  maxNumNrAnrMoiAllowed
    ...  ${maxNumNrAnrMoiAllowed}    delta_id=initial_params
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPRE-1  maxNumAnrNrrelePerCell
    ...  ${maxNumAnrNrrelePerCell}    delta_id=initial_params
    ${delta}    taf_admin.Get_Delta    delta_id=initial_params
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=initial_params
    taf_admin.Teardown_Admin    alias=initial_params


Create Nradjcell And Nrrele Objects
    [Arguments]    ${nradjecell_id}=NRADJECELL-1    ${physcell_id}=503    ${nrrele_id}=NRRELE-1
    ${nradjecell_params}=    Get Params For Nradjecell Object  ${nradjecell_id}    ${physcell_id}
    ${nrrele_params}=    Get Params For Nrrele Object  ${nrrele_id}
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjecell_id}
    ...                                         parameter=${nradjecell_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    Sleep   10s
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/${nrrele_id}
    ...                                         parameter=${nrrele_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Teardown_Admin    alias=object_creation


Delete All Nrrele And Nradjecell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    ${params}    Get Empty List
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-5000
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-255
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-4999
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-123
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-123
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Remove Special Characters From Anr Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}


Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Perform Attach
    Sleep   2s
    Trigger Intra-gNB HO From Cell 1 to Cell 2
    Sleep   2s


Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 3
    Perform Attach
    Sleep   2s
    Trigger Intra-gNB HO From Cell 1 to Cell 3
    Sleep   2s


Trigger Intra-gNB HO From Cell 1 to Cell 2
    Log To Console    Starting InterRAT HO...
    Set Attenuation    GNB_1_CELL_2    0db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Trigger Intra-gNB HO From Cell 1 to Cell 3
    Log To Console    Starting InterRAT HO...
    Set Attenuation    GNB_1_CELL_3    0db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Perform Inter RAT HO With actSaUeBasedAnrEutra Online Modification
    Perform Attach
    Sleep   10s
    Log To Console    Starting InterRAT HO...
    Set Attenuation    GNB_1_CELL_2    0db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        ${fire_counter}=    Count Fires For Pci Resolution    syslog_path=${current_syslog_path}
        Log To Console   ${fire_counter}
        IF    ${fire_counter} > 4    BREAK
        Sleep    1s
    END
    Set Anr Activation Flag   anr_activation_flag=true
    Log To Console    HO procedure done...


Verify Gap Release And Drx Setup
    Log To Console   \nChecking Gap Release And Drx Setup Msgs In Pcap File...
    Verify InterRAT HO DRX In Pcap   ${LOG_PATH}/${test_name}     ${test_name}     ${UE_1_DRX_1}    ${UE_1_DRX_2}    ${UE_1_DRX_3}


Check Nrrele And Nradjecell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrele_status
    ${scfc_file}    taf_admin.Get Scf    connection=nrrele_status
    ${distname_nradjecell}    Should Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-\[0-9]{1,4}
    ${distname_nrrele}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRRELE-\[0-9]{1,3}
    Log To Console    \n${distname_nradjecell} Object exists!
    Log To Console    ${distname_nrrele} Object exists!
    taf_admin.Teardown Admin    connection=nrrele_status


Check Second Nrrele And Nradjecell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrele_status
    ${scfc_file}    taf_admin.Get Scf    connection=nrrele_status
    ${distname_nradjecell}    Should Not Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-4999
    ${distname_nrrele}    Should Not Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRRELE-255
    Log To Console    \nNo new objects visible
    taf_admin.Teardown Admin    connection=nrrele_status


Check NRRELE Not Exists
    [Arguments]    ${nrrele_id}=NRRELE-256
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=nrrele_status
    ${nrrel_status}    taf_admin.Get Scf   connection=nrrele_status
    Should Not Contain    ${nrrel_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/${nrrele_id}
    taf_admin.Teardown_Admin    alias=nrrele_status


Check Nradjecell Not Exists
    [Arguments]    ${nradjecell_id}=NRADJECELL-5000
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=nradjcell_status
    ${nradjcell_status}    taf_admin.Get Scf    connection=nradjcell_status
    Should Not Contain    ${nradjcell_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/${nradjecell_id}
    taf_admin.Teardown_Admin    alias=nradjcell_status


Check Nrrele Object Exists
    [Arguments]    ${nrrele_id}=NRRELE-256
    ${nrrele_pattern}    Set Variable   distName="MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/${nrrele_id}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrele_status
    ${scfc_file}    taf_admin.Get Scf   connection=nrrele_status
    Should Contain    ${scfc_file}   ${nrrele_pattern}
    taf_admin.Teardown Admin    connection=nrrele_status


Check Nradjcell Object Exists
    [Arguments]    ${nradjecell_id}=NRADJECELL-5000
    ${nradjecell_pattern}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjecell_id}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjecell_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradjecell_status
    Should Contain    ${scfc_file}   ${nradjecell_pattern}
    taf_admin.Teardown Admin    connection=nradjecell_status


Nrrele And Nradjecell Should Exist For Two Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 3    BREAK
        IF    ${fire_counter} < 2    Check Nrrele Object Exists  nrrele_id=NRRELE-256    ELSE
        ...        Wait Until Keyword Succeeds    2x    5s    Check NRRELE Not Exists  nrrele_id=NRRELE-256
        Check Nradjcell Object Exists  nradjecell_id=NRADJECELL-5000
        Sleep    30s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Wait Until Keyword Succeeds    10x    10s    Check Nradjecell Not Exists  nradjecell_id=NRADJECELL-5000
    Sleep    5s


Both Nrrele And Nradjecell Should Exist For Two Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 4    BREAK
        IF    ${fire_counter} < 3    Check Both Nrrele Objects Exist    ELSE
        ...        Wait Until Keyword Succeeds    2x    5s    Check Both Nrrele Objects Not Exist
        Check Both Nradjecell Objects Exist
        Sleep    30s
    END
    Should Be Equal As Integers    ${fire_counter}    4
    Wait Until Keyword Succeeds    10x    10s    Check Both Nradjecell Objects Not Exist
    Sleep    5s


Check Both Nrrele Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrele_status
    ${scfc_file}    taf_admin.Get Scf    connection=nrrele_status
    Should Contain    ${scfc_file}   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRRELE-1
    Should Contain    ${scfc_file}   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRRELE-2
    taf_admin.Teardown Admin    connection=nrrele_status


Check Both Nradjecell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjecell_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradjecell_status
    Should Contain    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-1
    Should Contain    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-2
    taf_admin.Teardown Admin    connection=nradjecell_status


Check Both Nrrele Objects Not Exist
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=nrrele_status
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrele_status
    Should Not Contain    ${nrrel_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRRELE-1
    Should Not Contain    ${nrrel_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRRELE-2
    taf_admin.Teardown_Admin    alias=nrrele_status


Check Both Nradjecell Objects Not Exist
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=nradjcell_status
    ${nradjcell_status}    taf_admin.Get Scf    connection=nradjcell_status
    Should Not Contain    ${nradjcell_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-1
    Should Not Contain    ${nradjcell_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJECELL-2
    taf_admin.Teardown_Admin    alias=nradjcell_status


Check If Both Nrrele Removed In Syslog
    Log To Console    \nChecking If Both NRREL Objects Removed Properly...
    Confirm Both Nrrele Removed   syslog_path=${current_syslog_path}


Check If Both Nradjecell Removed In Syslog
    Log To Console    \nChecking If Both NRADJECELL Objects Removed Properly...
    Confirm Both Nradjecell Removed   syslog_path=${current_syslog_path}


Check If Nrrele Removed In Syslog
    Log To Console    \nChecking If NRREL Objects Removed Properly...
    Confirm Nrrele Removed   syslog_path=${current_syslog_path}


Check If Nradjecell Removed In Syslog
    Log To Console    \nChecking If NRADJNRCELL Objects Removed Properly...
    Confirm Nradjecell Removed    syslog_path=${current_syslog_path}


Update Idle Time For Eutra Removal
    ${params}=    get_params_for_idleTimeForEutraNbRemoval
    taf_admin.Setup_Admin      bts_host=${GNB_IP}    alias=idleTimeForEutraNbRemoval
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPRE-1
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=idleTimeForEutraNbRemoval
    taf_admin.Teardown_Admin    alias=idleTimeForEutraNbRemoval


Check If Fire Time Difference Correct
    [Arguments]    ${auto_removal}=${TRUE}
    Check Time Difference    syslog_path=${current_syslog_path}      auto_removal=${auto_removal}


Nrrele And Nradjecell Should Exist Before First Timer Fire
    FOR    ${i}    IN RANGE    70
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 1    BREAK
        Check Nrrele And Nradjecell Objects Exist
        Sleep    5s
    END
    Should Be Equal As Integers    ${fire_counter}    1


Create Fake Relation To Lte
    Create Nradjcell And Nrrele Objects  nradjecell_id=NRADJECELL-123  physcell_id=123  nrrele_id=NRRELE-123


Perform Full Detach
    Detach UE    UE_1
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}   90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}   90dB
    Sleep    5s


Check ANR Relation Counters
    FOR   ${i}   IN RANGE    3
        Log To Console     ${i}
        Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
        Perform Full Detach
    END


Check Syslog For No New Relation
    Confirm New Nrrele Not Created    ${LOG_PATH}/${test_name}/syslog/syslog_second_nrrel.log


Check Properly Incremenation Of ANR Relation Counters
    Check Counter Number    ${LOG_PATH}/${test_name}/syslog/syslog_5g.log


Check Relation Limit
    Confirm Relation Limit    ${LOG_PATH}/${test_name}/syslog/syslog_second_ho.log


Check Counters
    [Arguments]  @{counters}  ${cell_id}=1  ${expected_value}=1
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  expected_value=${expected_value}


Meas Gap Release and DRX Setup in UE to allow inter-RAT EUTRA CGI measurement reporting
    Log To Console    \nStarting Test
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Stop Collecting Logs
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrele And Nradjecell Objects Exist
    Verify Gap Release And Drx Setup


New inter-RAT Neighbour object addition to Network Plan File
    Log To Console    \nStarting Test
    @{counters_1}=       Create List                     M55124C07001  M55124C07002  M55147C01501
    @{counters_2}=       Create List                     M55124C07001  M55124C07002
    @{counters_3}=       Create List                     M55147C01501
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_1}  expected_value=0
    Set maxNumNrAnrMoiAllowed    1
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Stop Collecting Tcpdump
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrele And Nradjecell Objects Exist
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_2}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_3}
    Perform Full Detach
    Check ANR Relation Counters
    Perform Full Detach
    Stop Collecting Syslog      alias=5g
    Start Collecting Syslog    alias=second_nrrel
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 3
    Sleep    60s
    Check Second Nrrele And Nradjecell Objects Exist
    Stop Collecting Syslog    alias=second_nrrel
    Check Properly Incremenation Of ANR Relation Counters
    Check Syslog For No New Relation


CB008239_B_B2_TC12 Automatic EUTRA Neighbour Removal Procedure
    Log To Console    \nStarting Test
    Wait One Removal Cycle
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrele And Nradjecell Objects Exist
    Log To Console    \nBoth NRRELE and NRADJECELL Objects Should Exist For 2 and 3 Cycles...
    Nrrele And Nradjecell Should Exist For Two Cycles
    Stop Collecting Logs
    Check If Nrrele Removed In Syslog
    Check If Nradjecell Removed In Syslog
    Check If Fire Time Difference Correct
    Perform Full Detach
    Start Collecting Syslog   alias=second_ho
    Set maxNumAnrNrrelePerCell    0
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Stop Collecting Syslog    alias=second_ho
    Perform Full Detach
    Sleep     60s
    Check NRRELE Not Exists
    Check Nradjecell Not Exists
    Check Relation Limit
    Start Collecting Syslog   alias=third_ho
    Set maxNumAnrNrrelePerCell    1
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb Cell 2
    Stop Collecting Syslog    alias=third_ho
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrele And Nradjecell Objects Exist


Online modification idleTimeForEutraNbRemoval flag
    Log To Console    \nStarting Test
    Log To Console    \nCreate NRRELE-1 and NRADJECELL-1 Objects...
    Wait One Removal Cycle
    Start Collecting Syslog
    Create Nradjcell And Nrrele Objects
    Nrrele And Nradjecell Should Exist Before First Timer Fire
    Update Idle Time For Eutra Removal
    Log To Console    \nCreate NRRELE-2 and NRADJECELL-2 Objects...
    Create Nradjcell And Nrrele Objects   nradjecell_id=NRADJECELL-2   physcell_id=502   nrrele_id=NRRELE-2
    Log To Console    \nBoth NRRELE and NRADJECELL Objects Should Exist For 2 and 3 Cycles...
    Both Nrrele And Nradjecell Should Exist For Two Cycles
    Stop Collecting Logs
    Check If Both Nrrele Removed In Syslog
    Check If Both Nradjecell Removed In Syslog
    Check If Fire Time Difference Correct


Automatic EUTRA Neighbour Removal Procedure
    Log To Console    \nStarting Test
    Start Collecting Logs
    Create Fake Relation To Lte
    Set Anr Activation Flag   anr_activation_flag=false
    Perform Inter RAT HO With actSaUeBasedAnrEutra Online Modification
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrele And Nradjecell Objects Exist
    Stop Collecting Logs
    Confirm Handover Scenario    syslog_path=${current_syslog_path}
