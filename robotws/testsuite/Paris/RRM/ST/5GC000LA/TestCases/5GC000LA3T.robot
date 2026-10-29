*** Settings ***
Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue    WITH NAME    ue

Variables    ../../../../resources/ST/python/custom.py

Library    ../../resources/Ue_address.py    WITH NAME    ue_addr
Library    ../../resources/swconfig_handler.py    WITH NAME    swconf
Library    ../../resources/sg_radio_perf/python/LA_getQCT_TTI_3.py

Resource    ../../resources/sg_radio_perf/robot/traffic_iperf3_qualcomm_LA.robot
Resource    ../../resources/sg_radio_perf/robot/var_test_suite_taf_classical_qualcomm_generic_LA_3.robot

Force Tags    5G_RAN

Suite Setup    Precondition
Suite Teardown    Teardown Sequence


*** Test Cases ***
5GC000LA_B_1_LA_DLUL
    [Documentation]    The purpose of this test case is to perform :
    ...    LA DL
    ...
    ...    Preconditions:
    ...    -
    ...
    ...    Test Steps Execution:
    ...    - Open ASIK ssh connection

    [Tags]    B_1

    log to console    =====================
    log to console    Start Link Adaptation
    log to console    =====================

    # VM Test
    ${LA_TIME_STAMP}    getTimeStamp
    ${VM_PATH_TST}    Set Variable  ${VM_PATH_TST}${LA_TIME_STAMP}/
    Create Directory    ${VM_PATH_TST}


    # Backup Currunt state of gNB (SCF, swconfig)
    # -------------------------------------------
    #log to console    Backup current SCF
    #Backup Current SCF
    #log to console    LA_SCF_PATH=${LA_SCF_PATH}
    #log to console    LA_SCF_BACKUP_FILE=${LA_SCF_BACKUP_FILE}
    #Get Current SCF    ${LA_SCF_PATH}  ${LA_SCF_BACKUP_FILE}
    #Run Keyword If    '${LA_SCF_LOAD}' == 'Y'  Get Current SCF    ${LA_SCF_PATH}   ${LA_SCF_BACKUP_FILE}


    # Backup Current swconfig
    #Get Current swconfig    ${LA_SWC_PATH}  ${LA_SWC_BACKUP_FILE}
    #Run Keyword If    '${LA_SWC_LOAD}' == 'Y'  Get Current swconfig    ${LA_SWC_PATH}   ${LA_SWC_BACKUP_FILE}


    #Download SCF    ${LA_SCF_PATH}  ${LA_SCF_FILE}
    #Run Keyword If    '${LA_SCF_LOAD}' == 'Y'  Download SCF    ${LA_SCF_PATH}   ${LA_SCF_FILE}


    #Run Keyword If    '${LA_SWC_LOAD}' == 'Y'  Download swconfig   ${LA_SWC_PATH}   ${LA_SWC_FILE}

    #${flag_reset_SWC}    Download swconfig   ${LA_SWC_PATH}   ${LA_SWC_FILE}
    #Run Keyword If    '${flag_reset_SWC}' == '1'    Reset Site gNB

    #Run Keyword If    '${LA_RESET_gNB}' == 'Y'  Reset Site gNB

    #${flag_Cell_OnAir}    Wait until Keyword Succeeds   10m   1m    Check Cell On Air
    #Run Keyword If   '${flag_Cell_OnAir}' != 'OnAir'   Fatal Error

    ue.Attach Ue    UE_1
    Sleep    3s

    ${UE_ip}    ue_addr.Get UE IP address  ${IPERF_VM_UL_IPADDRESS}
    ...    ${IPERF_VM_UL_LOGIN}
    ...    ${IPERF_VM_UL_PASSWD}

    Stop Traffic LA    {DL}    ueid=0
    Stop Traffic LA    {UL}    ueid=0

    # Run Keyword if   'DL' in '${LA_TRAFICTYPE}'   Start DL Traffic LA
    Run Keyword if   '${LA_TRAFICTYPE}' == 'DL'  Start DL Traffic LA
    ...    distantip=${UE_ip}
    ...    tput=1650M
    ...    duration=60000
    ...    ueid=0

    #Run Keyword if   'UL' in '${LA_TRAFICTYPE}'   Start UL Traffic LA
    Run Keyword if   '${LA_TRAFICTYPE}' == 'UL'   Start UL Traffic LA
    ...    distantip=${UE_ip}
    ...    tput=150M
    ...    duration=60000
    ...    ueid=0

    Run Keyword if   '${LA_TRAFICTYPE}' == 'DLUL'   Start DLUL Traffic LA
    ...    distantip=${UE_ip}
    ...    tputDL=1600M
    ...    tputUL=200M
    ...    duration=60000
    ...    ueid=0

    Sleep    5s

    log to console    Perform Link Adaptation Downlink

    getTracesTTI_QCT    testName=${LA_TESTNAME}
    ...    trafficType=${LA_TRAFICTYPE}
    ...    profile=${LA_PROFILE}
    ...    typeAtten=${LA_TYPEATTEN}
    ...    iatten=${LA_IATTEN}
    ...    fatten=${LA_FATTEN}
    ...    step=${LA_STEP}
    ...    nbLoop=${LA_NBLOOP}
    ...    allerRetour=${LA_ALLERRETOUR}
    ...    stabilisationTime=${LA_TIMESTABILASATION}
    ...    captureDuration=${LA_CAPTUREDURATION}
    ...    traceType=${LA_TRACETYPE}
    ...    hdf2txt=${LA_HDF2TXT}
    ...    timeStamp=${LA_TIME_STAMP}
    ...    vmPathTst=${VM_PATH_TST}

    Sleep    30s

    Run Keyword if   'DL' in '${LA_TRAFICTYPE}'   Stop Traffic LA   {DL}  ueid=0
    Run Keyword if   'UL' in '${LA_TRAFICTYPE}'   Stop Traffic LA   {UL}  ueid=0

    sleep    5s
    ue.Detach Ue    UE_1


    # Get from gNB SCF and swconfig used for Test
    # -------------------------------------------
    # Get SCF used for Test
    #${SCF_file_Test}    set variable  ${LA_SCF_FILE}_${LA_TESTNAME}${LA_TIME_STAMP}
    #log to console    VM_PATH_TST=${VM_PATH_TST}
    #log to console    SCF_file_Test=${SCF_file_Test}
    #Get Current SCF    ${VM_PATH_TST}  ${SCF_file_Test}
    #Run Keyword If    '${LA_SCF_LOAD}' == 'Y'  Get Current SCF    ${VM_PATH_TST}  ${SCF_file_Test}

    #log to console    Get swconfig.txt used for test
    # Get swconfig used for Test
    #${SWC_file_Test}    set variable  ${LA_SWC_FILE}_${LA_TESTNAME}${LA_TIME_STAMP}
    #log to console    VM_PATH_TST=${VM_PATH_TST}
    #log to console    SWC_file_Test=${SWC_file_Test}
    #Get Current swconfig    ${VM_PATH_TST}  ${SWC_file_Test}
    #Run Keyword If    '${LA_SWC_LOAD}' == 'Y'  Get Current swconfig    ${VM_PATH_TST}  ${SWC_file_Test}


    # Restore initial state of gNB (SCF, swconfig)
    # -------------------------------------------
    #log to console    \nRestore initial state of gNB (SCF, swconfig)
    #log to console    -------------------------------------------\n

    # Restore SCF initial
    #log to console    Restore initial SCF
    #####Download SCF    ${LA_SCF_PATH}  ${LA_SCF_BACKUP_FILE}
    #Run Keyword If    '${LA_SCF_LOAD}' == 'Y'  Download SCF    ${LA_SCF_PATH}  ${LA_SCF_BACKUP_FILE}

    #${flag_reset_SWC}    Download swconfig   ${LA_SWC_PATH}   ${LA_SWC_BACKUP_FILE}
    #Run Keyword If    '${LA_SWC_LOAD}' == 'Y'  Download swconfig   ${LA_SWC_PATH}   ${LA_SWC_BACKUP_FILE}
    #${flag_reset_SWC}    Download swconfig   ${LA_SWC_PATH}   ${LA_SWC_BACKUP_FILE}

    #Run Keyword If    '${flag_reset_SWC}' == '1'    Reset Site gNB
    #Run Keyword If    '${LA_RESET_gNB}' == 'Y'    Reset Site gNB

    log to console    End Link Adaptation


*** Keywords ***
Precondition
    Log to console    --- CURDIR is: ${CURDIR} ---
    #Create Directory    ${LOCAL_SCF_DIR_PATH}
    #coam.connect to    bts_host=${GN_WEBUI[0]}    bts_port=${GN_WEBUI_PORT[0]}    name=coam_admin
    #coam.get_current_scf_file    ${LOCAL_SCF_DIR_PATH}    ${ORIG_SCF_FILE_NAME}    connection=coam_admin
    ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    ue.Detach Ue   UE_1


Teardown Sequence
    #coam.teardown    connection=coam_admin
    Terminate All Processes    kill=True


Get Current SCF
    [Documentation]    Get current SCF
    [Arguments]    ${SCF_path_name}  ${SCF_file_name}

    Log to Console    Get Current SCF
    Log to Console    GN_WEBUI=${GN_WEBUI[0]}
    Log to Console    GN_WEBUI_PORT=${GN_WEBUI_PORT[0]}
    coam.connect to    bts_host=${GN_WEBUI[0]}    bts_port=${GN_WEBUI_PORT[0]}    name=coam_admin
    coam.get_current_scf_file   ${SCF_path_name}    ${SCF_file_name}    connection=coam_admin
    coam.teardown    connection=coam_admin


Get Current swconfig
    [Documentation]    Get current swconfig
    [Arguments]    ${SWC_path_name}  ${SWC_file_name}

    ${asik_cnx}    ssh.connect_to    ${ASIK_ADDR[0]}    ${ASIK_USERNAME[0]}    ${ASIK_PASSWORD[0]}    alias=asik_als
    ${SWC_full_name}    set variable  ${SWC_path_name}${SWC_file_name}
    swconf.backup_swconfig    ${asik_cnx}    /ffs/run/swconfig.txt    ${SWC_full_name}
    ssh.disconnect    connection=${asik_cnx}


Download SCF
    [Documentation]    Download SCF
    [Arguments]    ${SCF_path_name}  ${SCF_file_name}
    Log to Console    Download SCF

    ${SCF_full_name}    set variable  ${SCF_path_name}${SCF_file_name}
    Log to Console    SCF_full_name=${SCF_full_name}

    coam.connect to    bts_host=${GN_WEBUI[0]}    bts_port=${GN_WEBUI_PORT[0]}    name=coam_admin
    ${out}    coam.perform_commissioning   scf_file=${SCF_full_name}    skip_parameter_relation_errors=True
    ...    connection=coam_admin    timeout=300s

    #Log to console    Wait 5mn to be sure the OAM is restarted
    #sleep    300s

    # Check gNB status and return if it ok
    #Check gNB State


Download swconfig
    [Documentation]    Download swconfig
    [Arguments]    ${SWC_path_name}    ${SWC_file_name}

    ${asik_cnx}    ssh.connect_to    ${ASIK_ADDR[0]}    ${ASIK_USERNAME[0]}    ${ASIK_PASSWORD[0]}    alias=asik_als
    ${SWC_full_name}    set variable  ${SWC_path_name}${SWC_file_name}
    ${flag_reset}    swconf.set_swconfig    ${asik_cnx}    ${SWC_full_name}    /ffs/run/swconfig.txt
    ssh.disconnect    connection=${asik_cnx}
    [return]    ${flag_reset}


Reset Site gNB
    [Documentation]    Reset site  gNB

    Log to console    Reset Site gNB
    Run Keyword And Ignore error    oam.teardown_session    session=oam_session
    oam.create_session    base_url=${GN_WEBUI[0]}
    ...    alias=oam_session
    oam.reset_site    session=oam_session
    oam.teardown_session    session=oam_session
    Log to console    Wait 5mn to be sure the OAM is restarted
    sleep    300s


Check Cell On Air
    [Documentation]    Description: Check if GNB is in cell on air status
    Log to console    Check GNB cell on air

    coam.connect to    bts_host=${GN_WEBUI[0]}    bts_port=${GN_WEBUI_PORT[0]}    name=coam_admin
    ${bts_status}    coam.get_bts_statuses    connection=coam_admin

    ${gnb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Log to console    - gNB status : ${gnb_cell_status}
    Log to console    - operational State : ${bts_status['operationalState']}

    Should be equal as strings    ${gnb_cell_status}    OnAir    msg=GNB is not on air, Current status is ${gnb_cell_status}
    ...    ignore_case=${True}

    coam.teardown    connection=coam_admin
    [return]    ${gnb_cell_status}
