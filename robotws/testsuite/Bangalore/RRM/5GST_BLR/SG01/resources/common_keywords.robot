*** Settings ***

Documentation
...   author: Mateusz Pajor
...   contact: mateusz.pajor@nokia.com
...   description: Krakow Verification Engineering team common keywords for 5GC006064 feature

Library    Collections
Library    OperatingSystem
Library    DateTime
Library    Telnet
Library    ute_fsmaccess
Library    ta5g_tshark
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_egate
Library    ta5g_pm_counters
Library    ta5g_ue_measurements
Library    ta5g_ue_mobility
Library    ta5g_cell_operations             WITH NAME    syslog
Library    taf.sbts.oam.coam.admin   WITH NAME    admin
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.collectors.snapshot  WITH NAME    snapshot
Library    taf.collectors.core      WITH NAME    core
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.config.scf           WITH NAME    scf
Library    taf.collectors.tcpdump   WITH NAME    tcpdump_core
Library    taf.transport.ssh        WITH NAME    ssh
Library    CB006064_keywords.py
Library    testsuite.RRM.Krakow.resources.Python.TtiTraces.TtiTraces  WITH NAME  ttitraces
Library    testsuite.RRM.Krakow.resources.Python.file_management
Library    resources/sites/NPS/SWENG/python/IphyUpdate.py
Library    ../../resources/Python/wts_configuration.py
Library    ../../resources/SwConfigModifier.py

Resource   ../../../../../resources/sites/Ulm/Common/ttitrace.robot
Resource   ../../../../../resources/sites/Ulm/Common/tcpdump.robot
Resource   ../../../../../resources/sites/Ulm/Common/pmcounters.robot
Resource   ../../../../../resources/sites/Ulm/Common/gnb.robot
Resource   ../../../../../resources/sites/Ulm/Common/wts_ue.robot
Resource   ../../../../../resources/sites/Ulm/Common/testline.robot
Resource   ../../../../AIRPHONE/Resources/robot/gnb.robot
Resource   ../../resources/Robot/pm_counters.robot
Resource   ../../resources/Robot/common_gnb.robot
Resource   ../../resources/wts_resources.robot
Resource   ../../resources/Robot/bip_logs.robot

Variables  variables.py

*** Keywords ***
Keywords list
    [Documentation]     Keywords list
    6064 Suite Setup
    6064-C Test Setup
    6064 Test Teardown
    Start Collect Logs
    Stop Collect Logs
    Verify Pucch F3 Modulation in BIP Log
    Perform commissioning with 6064 basic SCF
    Perform recomissioning with 6064 delta
    Ensure 6064 basic commissioning is performed
    Ensure 6064 delta is performed
    Get Default SCF For UTE TL
    Set 6064 Variables
    Change reqMinNumPuschPrb Parameter
    Set rdActivatePerCsi Flag
    Upload BIP Mirroring Scripts to gNB
    Change Mirroring Files Permissions
    Start Bip Collecting
    Stop Bip Collecting
    Copy Bip Logs To VM
    Validate BIP Messages In 6064
    Get Latest Counter Value
    Reset Testline And Collecting Logs
    Attach UE and establish pdu session 6064
    Wait Traffic Duration

6064 Suite Setup
    [Documentation]      Setting up configuration for testsuite
    ...                  Creation Date: 11.03.2021
    ...                  Modified Date: 07.04.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Set 6064 Variables
    Add IPs On VM
    Copy File    source=${EPCSIM_CFG_PATH}    destination=${WTS_DIR_PATH}
    Create Directory    ${OUTPUT_DIR}/${SUITE_LOGS_DIR}
    Get Default SCF For UTE TL
    Set rdActivatePerCsi Flag

6064-C Test Setup
    [Arguments]    ${scf_file}=${DELTA_CB006064_C_CONF1_TC3}
    [Documentation]      Setting up configuration for test case
    ...                  Creation Date: 15.01.2021
    ...                  Modified Date: 10.03.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Log    \nStart setup    console=True
    Ensure 6064 delta is performed  ${scf_file}
    Setup Biplog On ASIB
    Start Collect Logs
    Setup WTS instance    wts_config_file_path=${EPCSIM_CFG_4CELLS_PATH}    alias=${ALIAS_WTS_6064}

6064 Test Teardown
    [Documentation]      Bring TL back to original configuration
    ...                  Stop collecting logs
    ...                  Creation Date: 15.01.2021
    ...                  Modified Date: 16.06.2021
    ...                  Last Modified by: damian.piasecki@nokia.com

    Log to console    \nStart Teardown
    Stop Collect Logs
    Stop WTS instance    alias=${ALIAS_WTS_6064}
    Wait Until Keyword Succeeds    3x    4min    Collect Coam Snapshot
    Ensure 6064 basic commissioning is performed
    testline.Disconnect all available ssh connections

Start Collect Logs
    [Arguments]    ${prefix}=${TEST NAME}
    ...            ${timeout}=30 minute
    [Timeout]      ${timeout}
    [Documentation]      Common KW to collecting following logs
    ...                  BIP traces, TTI traces, syslog
    ...                  Creation Date: 15.01.2021
    ...                  Modified Date: 10.03.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    ttitraces.Start ttitraces    script=${TTI_SCRIPT_PATH}
    syslog.Start syslog
    ...    log_dir=${OUTPUT DIR}/${TEST NAME}
    ...    log_name=syslog.log

Stop Collect Logs
    [Arguments]    ${prefix}=${TEST NAME}
    [Documentation]      Stop collecting the following logs
    ...                  BIP traces, TTI traces, syslog
    ...                  Get SCF, swconfig files
    ...                  Creation Date: 15.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    syslog.Stop syslog
    ttitraces.Stop Ttitraces And Collect Logs
    gnb.Store Current swconfig from gNB    gnb_id=${0}    target_dir=${OUTPUT_DIR}/${TEST NAME}
    wts_ue.Store Current swconfig from Airphone    ue_id=${0}    target_dir=${OUTPUT_DIR}/${TEST NAME}
    admin.Connect To
    admin.Get Current Scf File    local_dir_path=${OUTPUT_DIR}/${TEST NAME}   file_name=gNB_commissioning.xml
    admin.Teardown

Verify Pucch F3 Modulation in BIP Log
    [Arguments]    ${bip_filepath}=${OUTPUT_DIR}/${SUITE_LOGS_DIR}/tcpdump.pcap    ${modulation}=BPSK
    [Documentation]    Verify if PUCCH F3 is sent with expected modulation
    ...                  Creation Date: 13.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: szymon.lange@nokia.com
    Log    \nStarting Pucch F3 modulation check. Expecting ${modulation}    console=True
    Create Pdml With Tshark Messages    input_file_path=${bip_filepath}
    ...                                 output_file_path=${OUTPUT_DIR}/${SUITE_LOGS_DIR}/tcpdump.pdml
    ...                                 tshark_filter=uldata_pucchreceivereq
    Log    Converted pcap to pdml    console=True
    ${PASSED}=    Verify Pucch F3 Modulation
    ...    filepath=${OUTPUT_DIR}/${SUITE_LOGS_DIR}/tcpdump.pdml
    ...    modulation=${modulation}
    Should Be True    ${PASSED}   msg=Incorrect PUCCH F3 modulation!
    Log    \nPucch F3 modulation check DONE    console=True

Perform commissioning with 6064 basic SCF
    [Arguments]    ${scf_file}=${FULL_PATH_TO_DEFAULT_SCF}
    [Documentation]      Adding basic comissioning
    ...                  Creation Date: 16.04.2021
    ...                  Modified Date: 18.05.2021
    ...                  Last Modified by: damian.piasecki@nokia.com

    Log    Preforming full commissioning
    admin.Setup Admin
    admin.Perform commissioning
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    [Teardown]    admin.Teardown Admin

Perform recomissioning with 6064 delta
    [Arguments]    ${delta_file}=${DELTA_CB006064_CONFIG_1_FILE}
    [Documentation]      Adding delta plan into basic comissioning
    ...                  Creation Date: 02.03.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    admin.Setup Admin
    admin.Perform delta recommissioning
    ...    delta_file=${CURDIR}/comissioning/${delta_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    [Teardown]    admin.Teardown Admin

Ensure 6064 basic commissioning is performed
    [Arguments]    ${scf_file}=${FULL_PATH_TO_DEFAULT_SCF}
    [Documentation]      Make sure that basic 6064 commissioning is loaded
    ...                  Creation Date: 16.04.2021
    ...                  Modified Date: 18.05.2021
    ...                  Last Modified by: damian.piasecki@nokia.com

    Wait Until Keyword Succeeds    3x  6 min  Perform commissioning with 6064 basic SCF  ${scf_file}
    Wait Until Keyword Succeeds    10min     30sec     gnb.Ensure gNB state is Up
    Wait Until Keyword Succeeds    8min     30sec     gnb.Ensure radio module is online

Ensure 6064 delta is performed
    [Arguments]    ${delta_file}=${DELTA_CB006064_CONFIG_1_FILE}
    [Documentation]      Make sure that basic 6064 delta is loaded
    ...                  Creation Date: 03.03.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Wait Until Keyword Succeeds    3x  6 min  Perform recomissioning with 6064 delta  ${delta_file}
    Wait Until Keyword Succeeds    10min     30sec     gnb.Ensure gNB state is Up
    Wait Until Keyword Succeeds    8min     30sec     gnb.Ensure radio module is online

Set 6064 Variables
    [Documentation]      Suite KW for setting up suite variables
    ...                  Creation Date: 11.03.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    admin.Connect To
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
    ${out_nrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${NRBTS_ID}    ${out_nrbts_id['nrBtsId']}
    [Teardown]    admin.Teardown

Change reqMinNumPuschPrb Parameter
    [Arguments]     ${value}=253
    [Documentation]      Configure reqMinNumPuschPrb parameter
    ...                  Creation Date: 18.03.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    admin.Connect To
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=reqMinNumPuschPrb
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=True
    [Teardown]    admin.Teardown admin

Set rdActivatePerCsi Flag
    [Documentation]      Set rdActivatePerCsi flag in swconfig file
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    ${flag}=    Create List    0x5800F3=1
    gnb.Update SW Config file on System Module    ${flag}

Upload BIP Mirroring Scripts to gNB
    [Arguments]    ${GNB_MIRRORING_FILE}=${GNB_MIRRORING_SCRIPT}
    [Documentation]      Upload via scp BIP mirroring script dedicated for ABIO
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Run    scp ${FULL_MIRRORING_SCRIPT} ${NOKIA_LOGIN}@192.168.255.129:${GNB_MIRRORING_FILE}
    Run    scp ${FULL_MIRRORING_CONFIG} ${NOKIA_LOGIN}@192.168.255.129:${GNB_MIRRORING_CONFIG}

Change Mirroring Files Permissions
    [Documentation]      Change permissions for BIP script
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Run On Gnb    chmod 777 ${GNB_MIRRORING_SCRIPT};chmod 777 ${GNB_MIRRORING_CONFIG}

Start Bip Collecting
    [Documentation]      Collecting BIP logs from ABIO board
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    ssh.Connect to    ${GNB_IP}    ${NOKIA_LOGIN}    ${NOKIA_PASS}    alias=bip
    ssh.send command    command=sh ${GNB_MIRRORING_SCRIPT}    connection=bip
    #[Teardown]    ssh.disconnect    connection=bip

Stop Bip Collecting
    [Documentation]      Stop BIP logs from ABIO board
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Run On Gnb    pkill -f ${MIRRORING_SCRIPT};pkill -f ${MIRRORING_DESTINATION}

Copy Bip Logs To VM
    [Arguments]    ${bip_download_path}=${OUTPUT_DIR}/${SUITE_LOGS_DIR}    ${file_suffix}=tcpdump
    ...            ${pcap}=${BIP_PCAP_FILE}
    [Documentation]      Copy BIP logs from ABIO board
    ...                  Creation Date: 20.05.2021
    ...                  Modified Date: 23.06.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    ${bip_file_path}    Convert To String    ${OUTPUT_DIR}/${SUITE_LOGS_DIR}/${file_suffix}.pcap
    Run    scp ${NOKIA_LOGIN}@192.168.255.129:${pcap} ${bip_file_path}
    [Return]    ${bip_file_path}

Validate BIP Messages In 6064
    [Arguments]    ${initial_bip_file_path}    ${messages}=${BIP_MESSAGES_TC4B}
    [Documentation]      Validation 6064 bip log
    ...                  Creation Date: 22.06.2021
    ...                  Modified Date: 23.06.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Log to console    Start validation of BIP log for CB006064
    Create Pdml With Tshark Messages    input_file_path=${initial_bip_file_path}
    ...                                 output_file_path=${OUTPUT_DIR}/${SUITE_LOGS_DIR}/tcpdump.pdml
    ...                                 tshark_filter=${messages[0]}
    Validate Bip    pdml_file_path=${OUTPUT_DIR}/${SUITE_LOGS_DIR}/tcpdump.pdml    messages=${messages}

Get Latest Counter Value
    [Arguments]    ${counter_id}
    ...            ${local_moid}=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    [Documentation]      Connect to gNB and collect counters from list
    ...                  Creation Date: 25.06.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com
    ${latest_counter_file}=    Get Latest Unpacked Full Pm Counters File
    ${value}    Get Latest PM Counter Value
    ...    counter_id=${counter_id}
    ...    local_moid=${local_moid}
    ...    filepath=${latest_counter_file}
    [Return]    ${value}

Reset Testline And Collecting Logs
    [Arguments]    ${alias_wts}
    [Documentation]      Reset WTS,AP and gNB, stop collect logs
    ...                  Creation Date:
    ...                  Modified Date: 26.04.2021
    ...                  Last Modified by: mateusz.pajor@nokia.com

    Stop Collect Logs
    Stop WTS instance    alias=${alias_wts}
    Reset Airphone Testline
    Start Collect Logs
    Setup WTS instance    alias=${alias_wts}

Attach UE and establish pdu session 6064
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute egate command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Attach UE
    ...    ue_id=${ue_id}    pass_regexp=${REGEX_UE_ATTACH_PASS}
    Establish pdu session
    ...    ue_id=${ue_id}
    ...    pass_regexp=${REGEX_PDU_SESSION_PASS}
    ...    pdu_id=${pdu_id}
    ...    gw_id=${ue_id}

Wait Traffic Duration
    [Arguments]    ${traffic_duration}=30s
    [Documentation]      Wait for the traffic time to expire
    ...                  Creation Date: 26.07.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    Sleep    ${traffic_duration}
