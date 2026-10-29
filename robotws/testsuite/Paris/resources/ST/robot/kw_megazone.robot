*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for Megazone features
...
...     AUTHOR (I&V-1):
...         Gerard Bonhaure         gerard.bonhaure@nokia.com
...         Philippe Vignerte       philippe.vignerte @nokia.com
...         Amadou Faye             amadou.faye@nokia.com
...         Philippe Gaborieau      philippe.gaborieau@nokia.com
...         Merwane CHEMSSI         merwane.chemssi@nokia.com
...         Ismael Hama Djibo       ismael.hama_djibo@nokia.com


*** Keywords ***

Create Sessions
    mzc.create_session                base_url=${GN_WEBUI}

Teardown Sessions
    mzc.teardown_session

Create Connections
    Create LOG Local Directory
    ${output}=                    Fetch From Right          ${GN_WEBUI}       /
    Set Suite Variable            ${GN_OAM}                 ${output}
    Run Keyword If                '${custom['GNB_Architecture']}'=='CLOUD'
    ...               Connect to OAM                ${GN_OAM}                 robot             rastre1
    ...         ELSE
    ...               Connect to OAM                ${GN_OAM}                 toor4nsn          oZPS0POrRieRtu
    Run Keyword If                '${custom['GNB_Architecture']}'=='CLOUD'                  Connect to BB1
    Run Keyword If                '${custom['GNB_Architecture']}'=='CLOUD'                  Connect to CPIF
    Run Keyword If                '${custom['GNB_Architecture']}'=='CLOUD'                  Connect to UPUE

Close Connections
    Run Keyword If          '${custom['GNB_Architecture']}'=='CLOUD'            ssh.disconnect          connection=BB1
    Run Keyword If          '${custom['GNB_Architecture']}'=='CLOUD'            ssh.disconnect          connection=CPIF
    ssh.disconnect          connection=OAM
    Run Keyword If          '${custom['GNB_Architecture']}'=='CLOUD'            ssh.disconnect          connection=UPUE

Get gNB SW version For Reporting Portal Tlsw Info
    ${soft}=      mzc.get_sw_version
    Create File   tlsw.txt              ${soft}

Perform gNB Site Reset
    mzc.reset_site

Wait For GNB_OAM_VM WEBUI Connectivity After Site Reset
    ${gNB_unavailability_status}=
    ...                     mzc.wait_for_site_unavailability    ${GN_WEBUI}    60
    ${gNB_unavailable}=
    ...                     should be true    ${gNB_unavailability_status}
    log to console          WebUI is unavailable !
    ${gNB_availability_status}=
    ...                     mzc.wait_for_site_availability    ${GN_WEBUI}      900
    ${gNB_available}=
    ...                     should be true    ${gNB_availability_status}
    log to console          WebUI connection is back !

Check FSM Status From WEBUI
    # for AirScaile
    Log to console          Checking FSM Status:
    ${fsm_availability_status}=
    ...                     mzc.get_fsm
    ...                     attribute=availabilityStatus
    ${fsm_procedural_status}=
    ...                     mzc.get_fsm
    ...                     attribute=proceduralStatus
    ${fsm_operational_state}=
    ...                     mzc.get_fsm
    ...                     attribute=operationalState
    should be equal    ${fsm_availability_status}                       online
    log to console     Availability status : ${fsm_availability_status}
    should be equal    ${fsm_procedural_status}                         configured
    log to console     Procedural status : ${fsm_procedural_status}
    should be equal    ${fsm_operational_state}                         enabled
    log to console     Operational state : ${fsm_operational_state}

Check FCT Status From WEBUI
    # for ASIK
    Log to console          Checking FCT Status:
    ${fct_availability_status}=
    ...                     mzc.get_system_module_fct
    ...                     attribute=availabilityStatus   fsm_id=1
    ${fct_procedural_status}=
    ...                     mzc.get_system_module_fct
    ...                     attribute=proceduralStatus    fsm_id=1
    ${fct_operational_state}=
    ...                     mzc.get_system_module_fct
    ...                     attribute=operationalState    fsm_id=1
    should be equal         ${fct_availability_status}    online
    should be equal         ${fct_procedural_status}      configured
    should be equal         ${fct_operational_state}      enabled

Check FCT Status From Asik AdetS
    # for ASIK local
    ssh.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s        connection=BB1
    sleep               5s
    ${output}=          ssh.read output         connection=BB1
    ${result_asik}      Should Match Regexp     ${output}           0x10.*FSM1_FCT.*ready.*    ASIK is not ready    ignore_case=False

Check FBB_ID=${fbbid} Status From WEBUI
    # Check ABIL1
    ${fbb_availability_status}=
    ...                     mzc.get_fbb
    ...                     attribute=availabilityStatus    fbb_id=${fbbid}
    ${fbb_procedural_status}=
    ...                     mzc.get_fbb
    ...                     attribute=proceduralStatus      fbb_id=${fbbid}
    ${fbb_operational_state}=
    ...                     mzc.get_fbb
    ...                     attribute=operationalState      fbb_id=${fbbid}
    should be equal         ${fbb_availability_status}      online
    should be equal         ${fbb_procedural_status}        configured
    should be equal         ${fbb_operational_state}        enabled

Check FBBs Status From Asik AdetS
    ssh.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s
    ...        connection=BB1
    sleep               5s
    ${output}=          ssh.read output         connection=BB1
    ${result_abil}      Should Match Regexp
    ...          ${output}       0x12.*FSM1_FSP1.*ready.*    ASIK is not ready      ignore_case=False

Check Loner Status from Asik
    #check l1sw is active
    ssh.send command        command=bsh 1:2 'systemctl status l1sw'             connection=BB1
    sleep                   3s
    ${l1sw}                 ssh.read output                                     connection=BB1
    Should Match Regexp     ${l1sw}             .*Active.*active.*running.*
    #check l1sw-nrt
    ssh.send command        command=bsh 1:2 'systemctl status l1sw-nrt'         connection=BB1
    sleep                   3s
    ${l1sw_nrt}             ssh.read output                                     connection=BB1
    Should Match Regexp     ${l1sw_nrt}         .*Active.*active.*running.*
    #check autodetection
    ssh.send command        command=bsh 1:2 'systemctl status autodetection'    connection=BB1
    sleep                   3s
    ${detection}            ssh.read output     connection=BB1
    Should Match Regexp     ${detection}        .*Active.*active.*running.*

Create LOG Local Directory
    Create Directory              ${LOCAL_LOG_DIR_PATH}
    Create Directory              ${custom['PATH_Storage']}/Logs

Collect startup logs
    log to console          Try to unarchive startup_DEFAULT
    ssh.send_command        unxz /tmp/startup_DEFAULT.log.xz                 connection=BB1
    log to console          Downloading startup logs
    ssh.Download File       /tmp/startup_DEFAULT.log
    ...                     ${LOCAL_LOG_DIR_PATH}/startup_DEFAULT.log
    ...                     connection=BB1

Check F1AP link Status from Asik CP-RT And CP-IF
    # Check F1 link state from ASIK in startup_DEFAULT.log and from CP-IF in startup_cp_if.log
    ${out}=             run
    ...                 grep -i F1mgmt ${LOCAL_LOG_DIR_PATH}/startup_DEFAULT.log
    ${output}=          get lines containing string         ${out}       F1MgmtService
    @{output}           split to lines                      ${output}
    log many            @{output}
    should contain      @{output}[0]        Received common::InternalEventT<common::F1apSetupTriggerMsg
    ...                 msg=CPRI Synchro should be failed
    should contain      @{output}[1]        Received common::TaskDone
    should contain      @{output}[2]        Task 1 end successfully!
    should contain      @{output}[3]        Received common::InternalEventT<common::f1ap::F1SetupResp> transactionId= 0
    should contain      @{output}[4]        Received common::TaskDone
    should contain      @{output}[5]        Task 2 end successfully!
    ...                 msg=F1SetupResp not received from CP-IF
    # Since 5G_18A_B5 gnb upgrade patern is no more visible from ASIK investigation in progress
    # should contain      @{output}[6]       SCTP link status : 1
    # ...                 msg=F1 Link failed. SCTP not up
    ${output}           ssh.execute
    ...                 sudo journalctl -ab | grep -i "f1 link status"
    ...                 connection=CPIF
    should contain      ${output}           update f1 link status of Distributed Unit[id: 0] Ok
    ...                 msg=F1 link status with DU failed

Check F1AP link Status from Asik CP-RT And CP-IF for master Load
    # Check F1 link state from ASIK in startup_DEFAULT.log and from CP-IF in startup_cp_if.log
    ${out}=             run
    ...                 grep -i F1mgmt ${LOCAL_LOG_DIR_PATH}/startup_DEFAULT.log
    ${output}=          get lines containing string       ${out}       F1MgmtService
    @{output}           split to lines      ${output}
    log many            @{output}
    should contain      @{output}[0]        Received common::InternalEventT<common::F1apSetupTriggerMsg
    ...                 msg=CPRI Synchro should be failed
    should contain      @{output}[1]        Received common::TaskDone
    should contain      @{output}[2]        Task 1 end successfully!
    should contain      @{output}[3]        Received common::InternalEventT<common::f1ap::F1SetupResp> transactionId= 0
    should contain      @{output}[4]        Received common::TaskDone
    should contain      @{output}[5]        Task 2 end successfully!
    ...                 msg=F1SetupResp not received from CP-IF
    # Since 5G_18A_B5 gnb upgrade patern is no more visible from ASIK investigation in progress
    # should contain      @{output}[6]       SCTP link status : 1
    # ...                 msg=F1 Link failed. SCTP not up
    ${output}           ssh.execute
    ...                 sudo journalctl -ab | grep -i "f1 link status"
    ...                 connection=CPIF
    should contain      ${output}            update f1 link status of GnbDuId: 0 Status: ok
    ...                 msg=F1 link status with DU failed

Check VM OAM status
    ${VM_0AM_availability_status}=      mzc.get_vm_availability_status      oamVM
    should be equal                     ${VM_0AM_availability_status}       online

Check VM CPNB status
    ${VM_CPNB_availability_status}=     mzc.get_vm_availability_status      cpnbVM
    should be equal                     ${VM_CPNB_availability_status}      online

Check VM CPCL status
    ${VM_CPCL_availability_status}=     mzc.get_vm_availability_status      cpclVM
    should be equal                     ${VM_CPCL_availability_status}      online

Check VM CPUE status
    ${VM_UECP_availability_status}=     mzc.get_vm_availability_status      cpueVM
    should be equal                     ${VM_UECP_availability_status}      online

Check VM UPUE status
    ${VM_UEUP_availability_status}=     mzc.get_vm_availability_status      upueVM
    should be equal                     ${VM_UEUP_availability_status}      online

Check VM CPIF status
    ${VM_CPIF_availability_status}=     mzc.get_vm_availability_status      cpifVM
    should be equal                     ${VM_CPIF_availability_status}      online

Check VM CPNRT status
    ${VM_CPNRT_availability_status}=     mzc.get_vm_availability_status      cpnrtVM
    should be equal                     ${VM_CPNRT_availability_status}      online

Check Ru id=${rfid} Status
    ${frm_availability_status}=  mzc.get_frm    frm_id=${rfid}      attribute=availabilityStatus
    ${frm_procedural_status}=    mzc.get_frm    frm_id=${rfid}      attribute=proceduralStatus
    ${frm_operational_state}=    mzc.get_frm    frm_id=${rfid}      attribute=operationalState
    should be equal              ${frm_availability_status}         online
    should be equal              ${frm_procedural_status}           configured
    should be equal              ${frm_operational_state}           enabled

Check GpsSync Status
    ${gps_availability_status}=  mzc.get_gps_status
    should be equal              ${gps_availability_status}    inUse

Check Cell id=${cell_id} Status
    ${is_cell1_online}=      mzc.is_cell_in_state       online        ${cell_id}
    ${check_cell}=           should be true    ${is_cell1_online}
    ${out}=                  mzc.get_cell_specific_info               ${cell_id}
    Log                      ${out}

Start tail
    [Arguments]          ${inputFile}        ${outputfile1}       ${connection}
    ssh.send command     sudo tail -f -n 0 ${inputFile} > /tmp/${outputfile1}                    connection=${connection}

Stop tail
    [Arguments]          ${outputfile1}        ${outputfile2}     ${connection}
    ssh.Download File    /tmp/${outputfile1}   ${outputfile2}     connection=${connection}

start_tcpdump_log_collection_on_cpif
    # Start Tcpdump Log Collection On Cpif
    [Documentation]         Start tcpdump log collection in CPIF VMs
    [Arguments]             ${test_line}=${myTL}    ${cpifHostName}=cpif-0.local
    &{cpif_ssh_config}=     create dictionary       addr=cpif-0.local    username=robot
    ...                     password=rastre1    proxy=oam
    &{oam_ssh_config}=      create dictionary       addr=${GN_OAM}       username=robot
    ...                     password=rastre1
    &{testline_config}=     create dictionary       cpif=&{cpif_ssh_config}    oam=&{oam_ssh_config}
    &{paths}=               create dictionary       /tmp/tcpdump_CPIF.pcap  ${OUTPUT_DIR}/Logs/tcpdump_CPIF.pcap
    &{collector_config}=    create dictionary       type=tshark    nic_name=internal    paths=&{paths}    executor=cpif
    tcpdump.create_tcpdump_collector                cpif_tcpdump    collector_configuration=&{collector_config}
    ...                                             setup_configuration=&{testline_config}
    cc.start_collectors     collectors_list=cpif_tcpdump

stop_and_collect_tcpdump_log_collection_on_cpif
    # Stop And Collect Tcpdump Log Collection On Cpif
    [Documentation]         Stops journal log collection and collects the Log File in default path
    cc.stop_collectors      collectors_list=cpif_tcpdump
    cc.collect_collectors   collectors_list=cpif_tcpdump     target_path=${LOG_PATH}

start_tcpdump_log_collection_on_cpif_FH
    # Start Tcpdump Log Collection On Cpif FH
    [Documentation]         Start tcpdump log collection in CPIF Vms
    [Arguments]             ${test_line}=${myTL}    ${cpifHostName}=cpif-0.local
    &{cpif_ssh_config}=     create dictionary       addr=cpif-0.local       username=robot
    ...                     password=rastre1    proxy=oam
    &{oam_ssh_config}=      create dictionary       addr=${GN_OAM}          username=robot
    ...                     password=rastre1
    &{testline_config}=     create dictionary       cpif=&{cpif_ssh_config}     oam=&{oam_ssh_config}
    &{paths}=               create dictionary       /tmp/tcpdump_CPIF_FH.pcap   ${OUTPUT_DIR}/Logs/tcpdump_CPIF_FH.pcap
    &{collector_config}=    create dictionary       type=tshark     nic_name=fronthaul
    ...                     paths=&{paths}      executor=cpif
    tcpdump.create_tcpdump_collector    cpif_FH_tcpdump    collector_configuration=&{collector_config}
    ...                                 setup_configuration=&{testline_config}
    cc.start_collectors     collectors_list=cpif_FH_tcpdump

stop_and_collect_tcpdump_log_collection_on_cpif_FH
    # Stop And Collect Tcpdump Log Collection On Cpif FH
    [Documentation]         Stops journal log collection and collects the Log File in default path
    cc.stop_collectors      collectors_list=cpif_FH_tcpdump
    cc.collect_collectors   collectors_list=cpif_FH_tcpdump     target_path=${LOG_PATH}

start_tcpdump_log_collection_on_cpif_BH
    # Start Tcpdump Log Collection On Cpif BH
    [Documentation]         Start tcpdump log collection in CPIF Vms
    [Arguments]             ${test_line}=${myTL}      ${cpifHostName}=cpif-0.local
    &{cpif_ssh_config}=     create dictionary       addr=cpif-0.local     username=robot
    ...                      password=rastre1     proxy=oam
    &{oam_ssh_config}=      create dictionary       addr=${GN_OAM}        username=robot
    ...                     password=rastre1
    &{testline_config}=     create dictionary       cpif=&{cpif_ssh_config}         oam=&{oam_ssh_config}
    &{paths}=               create dictionary       /tmp/tcpdump_CPIF_BH.pcap
    ...                     ${OUTPUT_DIR}/Logs/tcpdump_CPIF_BH.pcap
    &{collector_config}=    create dictionary       type=tshark     nic_name=backhaul
    ...                        paths=&{paths}      executor=cpif
    tcpdump.create_tcpdump_collector    cpif_BH_tcpdump                collector_configuration=&{collector_config}
    ...                                 setup_configuration=&{testline_config}
    cc.start_collectors     collectors_list=cpif_BH_tcpdump

stop_and_collect_tcpdump_log_collection_on_cpif_BH
    # Stop And Collect Tcpdump Log Collection On Cpif BH
    [Documentation]         Stops journal log collection and collects the Log File in default path
    cc.stop_collectors      collectors_list=cpif_BH_tcpdump
    cc.collect_collectors   collectors_list=cpif_BH_tcpdump         target_path=${LOG_PATH}

L3 SgnAddition Sequence Analysis
    ${dict}                 Create Dictionary   options=+N -o SgnAdditionSequence
    ${resSequence}=         eCLAT-AnalysisTraces    ${protocolAnalysis_5gNBAddition_v1}
    ...                     ${VM_journals_trace_collected}          ${dict}
    # Do not use the @{trace} but instead ${trace}. This is due to current 'eCLAT-AnalysisTraces' tool limitation/
    Log to console          ${resSequence}
    should be true          ${resSequence} == ${TraceAnalysisAssemement}

Collect journalctl on CPIF
    [Documentation]         To collect the journalctl file from the CU BB3 CPIF VM for further analysis.
    ...                     And to filter out any lines with "DEBUG" string
    ...                     Then to temporary download the generated file under /tmp of the testVM/UTE VM.
    ...                     Then to
    Connect to CPIF
    ssh.Execute             command=sudo journalctl -ab | grep -v -i "DEBUG" > /tmp/journalctlCPIF_Retrieved
    ...                     connection=CPIF
    ssh.Download File       /tmp/journalctlCPIF_Retrieved     ${custom['PATH_Storage']}/journalctlCPIF
    ...                     connection=CPIF

Collect journalctl on UPUE
    [Documentation]         To collect the journalctl file from the CU BB3 UPUE VM for further analysis.
    Connect to UPUE
    ssh.Execute       command=sudo journalctl -ab | grep -v -i "DEBUG" > /tmp/journalctlUPUE_Retrieved
    ...                     connection=UPUE
    ssh.Download File       /tmp/journalctlUPUE_Retrieved     ${custom['PATH_Storage']}/journalctlUPUE
    ...              connection=UPUE

Collect journalctl on CPUE
    [Documentation]         To collect  the fournalctl file from the CU BB3 CPUE VM for further analysis.
    Connect to CPUE
    ssh.Execute             command=sudo journalctl -ab | grep -v -i "DEBUG" > /tmp/journalctlCPUE_Retrieved
    ...                     connection=CPUE
    ssh.Download File       /tmp/journalctlCPUE_Retrieved     ${custom['PATH_Storage']}/journalctlCPUE
    ...              connection=CPUE

Collect journalctl on CPCL
    [Documentation]         To collect  the fournalctl file from the CU BB3 CPCL VM for further analysis.
    Connect to CPCL
    ssh.Execute             command=sudo journalctl -ab | grep -v -i "DEBUG" > /tmp/journalctlCPCL_Retrieved
    ...                         connection=CPCL
    ssh.Download File       /tmp/journalctlCPCL_Retrieved     ${custom['PATH_Storage']}/journalctlCPCL
    ...                       connection=CPCL


Collect LINUX_Startup
    [Documentation]         To collect the LINUX_Startup file from the CU BB3 UPUE VM for further analysis.
    Connect to UPUE
    ssh.Send Command                cd /tmp; sudo unzip /tmp/LINUX_startup.zip
    ...                             timeout=120         connection=UPUE
    Sleep                           5s
    ${isUnzipedFile1}               ssh.Read Output               connection=UPUE
    Log to console                  ---- isUnzipedFile1: ${isUnzipedFile1} -----
    ${foundInflatingLine}=          Get Lines Containing String                 ${isUnzipedFile1}
    ...                            inflating: LINUX_startup.log
    Log to console                  ---- foundInflatingLine: ${foundInflatingLine} -----
    Should Contain                  ${foundInflatingLine}       inflating: LINUX_startup.log
    ssh.Send Command                sudo chmod 777 /tmp/LINUX_startup.log
    ...                             timeout=120         connection=UPUE
    Sleep                           5s
    Log to console                  ---- Downloading file.... -----
    ssh.Download File               /tmp/LINUX_startup.log     ${custom['PATH_Storage']}/LINUX_startup_collected.log
    ...                             connection=UPUE


L3 Throughput Analysis
    ${res}=                 eCLAT-AnalysisTraces           ${evalULDL_Tput_v1}         ${UPUE_LINUX_startup_collected}
    Log to console          ${res}
    should be true          ${res} == ${TraceAnalysisAssemement}

Connect to BB1 local private way
    [Arguments]     ${hostname}=${BB1_IP_LOCAL}
    ...             ${fsp1a_username}=${BB1_LOGIN}
    ...             ${fsp1a_password}=${BB1_PASSWORD}
    ...             ${alias}=BB1
    ssh.Connect to    hostname=${BB1_IP_LOCAL}    username=${BB1_LOGIN}     password=${BB1_PASSWORD}    alias=${alias}

Connect to Loner
    # Create local connection to Loner fsp1-1-1c via ASIK proxy
    [Arguments]     ${hostname}=fsp-1-1c
    ...             ${loner_username}=${GNB_AIRSCALE_USERNAME}
    ...             ${loner_password}=${GNB_AIRSCALE_PASSWORD}
    ...             ${alias}=LONER    ${proxy}=BB1
    #...             ${alias}=LONER    ${proxy}=OAM
    Connect via root if passed username fails       hostname=${hostname}
    ...                 username=${loner_username}    password=${loner_password}
    ...                                             alias=${alias}          proxy=${proxy}

Connect to fsp1a
    [Arguments]     ${hostname}=fsp-1-1a
    ...             ${fsp1a_username}=${GNB_AIRSCALE_USERNAME}
    ...             ${fsp1a_password}=${GNB_AIRSCALE_PASSWORD}
    ...             ${alias}=fsp1a    ${proxy}=BB1
    Connect via root if passed username fails    hostname=${hostname}
    ...                username=${fsp1a_username}    password=${fsp1a_password}
    ...                                          alias=${alias}         proxy=${proxy}

Collect FSPA1 journalctl
    [Documentation]   Collects JournalCTL from FSP1a =  fsp-1-1c, download it on a define directory
    ...               And return the path of the download file
    [Arguments]       ${input_path}=/tmp/journalctlFSP1A       ${output_path}=${custom['PATH_Storage']}/journalctlFSP1A
    ssh.send_command        journalctl -ab > /tmp/journalctlFSP1A        connection=fsp1a
    sleep                   10s
    ssh.download_file       ${input_path}          ${output_path}        connection=fsp1a
    [return]                ${output_path}

Connect to fsp2a
    [Arguments]     ${hostname}=fsp-1-2a
    ...             ${fsp1a_username}=${GNB_AIRSCALE_USERNAME}
    ...             ${fsp1a_password}=${GNB_AIRSCALE_PASSWORD}
    ...             ${alias}=fsp2a    ${proxy}=BB1
    Connect via root if passed username fails    hostname=${hostname}   username=${fsp1a_username}
    ...                 password=${fsp1a_password}
    ...                                          alias=${alias}         proxy=${proxy}

Collect FSPA2 journalctl
    [Documentation]   Collects JournalCTL from FSP1a =  fsp-1-2c, download it on a define directory
    ...               And return the path of the download file
    [Arguments]       ${input_path}=/tmp/journalctlFSP2A       ${output_path}=${custom['PATH_Storage']}/journalctlFSP2A
    ssh.send_command        journalctl -ab > /tmp/journalctlFSP2A        connection=fsp2a
    sleep                   10s
    ssh.download_file       ${input_path}          ${output_path}        connection=fsp2a
    [return]                ${output_path}

L3 Tput DL
    ${L3_DL_Tput}=          eCLAT-AnalysisTraces get global value        traff_Dl_In
    log to console          ${L3_DL_Tput}
    #Set Test Variable
    ${L3_DL_Tput}=          convert to number       ${L3_DL_Tput}
    should be true          ${L3_DL_Tput} >= ${DOWNLINK_DATA_TRANSFER}

L3 Tput UL
    ${L3_UL_Tput}=          eCLAT-AnalysisTraces get global value        traff_Ul_In
    log to console          ${L3_UL_Tput}
    ${L3_UL_Tput}=          convert to number       ${L3_UL_Tput}
    should be true          ${L3_UL_Tput} >= ${UPLINK_DATA_TRANSFER}

Collect PM files on Cloud Megazone
    [Arguments]                 ${folder}
    Create Directory            ${custom['PATH_Storage']}/PM_Counters/${folder}
#    Empty Directory             ${custom['PATH_Storage']}/PM
    ${pm_files}=                ssh.execute         command=ls /mnt/services/mzoam/config/[0-9.]*/pm/reports
    ...                         connection=OAM
    @{pm_files_list}            split string      string=${pm_files}
    ${pm_path}=                 ssh.execute         command=cd /mnt/services/mzoam/config/[0-9.]*/pm/reports; pwd
    ...                         connection=OAM
#    :FOR    ${file}     IN      @{pm_files_list}
#    \       ssh.Download File       /mnt/services/mzoam/config/[0-9.]*/pm/reports/${file}
#    \       ...                     ${custom['PATH_Storage']}/PM_Counters/${folder}/${file}     connection=OAM
     :FOR    ${file}     IN      @{pm_files_list}
    \       ssh.Download File       ${pm_path}/${file}
    \       ...                     ${custom['PATH_Storage']}/PM_Counters/${folder}/${file}     connection=OAM


Collect PM files on Cloud Megazone v2
    [Arguments]                 ${folder}
    Create Directory            ${custom['PATH_Storage']}/PM_Counters/${folder}
#    Empty Directory             ${custom['PATH_Storage']}/PM
    ${pm_files}=                ssh.execute         command=ls /mnt/services/mzoam/config/[0-9.]*/pm/reports
    ...                         connection=OAM
    @{pm_files_list}            split string      string=${pm_files}
    ${pm_path}=                 ssh.execute         command=cd /mnt/services/mzoam/config/[0-9.]*/pm/reports; pwd
    ...                         connection=OAM
#    :FOR    ${file}     IN      @{pm_files_list}
#    \       ssh.Download File       /mnt/services/mzoam/config/[0-9.]*/pm/reports/${file}
#    \       ...                     ${custom['PATH_Storage']}/PM_Counters/${folder}/${file}     connection=OAM
     :FOR    ${file}     IN      @{pm_files_list}
    \       ssh.Download File       ${pm_path}/${file}
    \       ...                     ${custom['PATH_Storage']}/PM_Counters/${folder}/${file}     connection=OAM