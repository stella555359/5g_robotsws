*** Settings ***

Documentation    Check bts log for CipheringAndIntegrity
Library         OperatingSystem
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.collectors.core   WITH NAME   core
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/resources/cyphering.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/resources/specific_keywords.py
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.ue.tm500.rci    WITH NAME    rci
Library         taf.transport.ssh  WITH NAME  ssh
Library         DateTime
Library         Collections
#Library         taf.ue
Resource        testsuite/Wroclaw/RRM/resources/connections.robot

*** Keywords ***
#NOTE: Moved to WRO_5/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
#Start Btslog
#    btslog.create_btslog_collector
#    ...                         name=btslog
#    core.setup_collectors       names=btslog
#    core.start_collectors       names=btslog
#    btslog.set_suite_alias      btslog
#    log to console              [DEBUG] Will save logs to /tmp/btslog
#
#Stop BtsLog
#    core.stop_collectors        names=btslog
#    Builtin.Sleep               10 sec
#    core.collect_collectors     names=btslog
#    log to console              [DEBUG] collectors finished
#    core.teardown_collectors    names=btslog

Collect snapshot
    [Arguments]         ${alias}=cOAM
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=300sec

    log to console      Collect snapshot.
    coam.connect to     name=coam_snap
    ${software_info}    coam.get software info  connection=coam_snap
    coam.teardown       connection=coam_snap
    ${sw_version}       set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    set variable  ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    coam.connect to     name=${alias}
    coam.get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    coam.teardown       connection=${alias}

Perform commissioning with given parameters
    [Arguments]         ${nea0}=1
    ...                 ${nia0}=0
    ...                 ${nea1_128}=3
    ...                 ${nea2_128}=4
    ...                 ${nea3_128}=2
    ...                 ${nia1_128}=3
    ...                 ${nia2_128}=4
    ...                 ${nia3_128}=2
    ...                 ${nullFallback}=true
    ...                 ${inactivityTimerSA}=30
    Log to console      __Perform commissioning with given parameters.
    &{cipherPrefL}         Create dictionary  nea0=${nea0}
                                       ...    nea1_128=${nea1_128}
                                       ...    nea2_128=${nea2_128}
                                       ...    nea3_128=${nea3_128}
    &{integrityProtPrefL}  Create dictionary  nia0=${nia0}
                                       ...    nia1_128=${nia1_128}
                                       ...    nia2_128=${nia2_128}
                                       ...    nia3_128=${nia3_128}

    ${object_path}      Set variable    MRBTS-${bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    Initialise delta store
    Add list parameters to delta  ${object_path}      cipherPrefL                &{cipherPrefL}
    Add list parameters to delta  ${object_path}      integrityProtPrefL               &{integrityProtPrefL}
    Add param to delta       ${object_path}       nullFallback             value=${nullFallback}
    Add param to delta       ${object_path}       srbInactivityTimerSA             value=${inactivityTimerSA}
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}

Pcap collection
    [Arguments]         ${alias}=ASIB       ${filename}=pcap_logs.pcap
    Connect to SMOD     alias=${alias}
    ssh.send command    command=tcpdump sctp -i any -w /tmp/${filename}     connection=${alias}

Pcap collection NGAP
    [Arguments]         ${alias}=ASIB   ${filename}=pcap_logs.pcap
    Connect to SMOD     alias=${alias}
    ssh.send command    command=tcpdump sctp -i any -w /tmp/${filename}     connection=${alias}

Pcap log downlad
    [Arguments]          ${alias}=ASIB      ${filename}=pcap_logs.pcap
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/${filename}
    ssh.execute          command=killall tcpdump   connection=${alias}
    sleep  2s
    Create Directory     ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    sleep  2s
    ssh.download_file    /tmp/${filename}   ${dir}    connection=${alias}

Check pcap log
    [Arguments]       ${nea}   ${nia}
    ${shark}   get_nea      ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/pcap_logs.pcap    nr-rrc.cipheringAlgorithm
    ${dict}  convert to string  ${shark}
    should contain    ${dict}      ${nea}
    should contain    ${dict}      ${nia}

Check pcap for NGAP
    ${shark}   get_nea      ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/pcap_logs.pcap    ngap.cause
    ${dict}  convert to string  ${shark}
    should contain    ${dict}    encryption-and-or-integrity-protection-algorithms-not-supported

Check syslog
    [Arguments]          ${integrity}   ${Ciphering}
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/btslog
    Run    cd ${dir}
    Run    tar zxvf syslog_files.tgz
    ${output}  Run    grep -s "Checking integrity algorithm:" ${dir}/*
    should contain    ${output}    ${integrity} Priority 9
    ${output}  Run    grep -s "Checking ciphering algorithm:" ${dir}/*
    should contain    ${output}    ${Ciphering} Priority 9
    ${output}  Run    grep -s "cipheringAlgorithm" ${dir}/*
    should contain    ${output}    "${Ciphering}"

Activate debug logs
    [Arguments]      ${command}= printf "[control]\n \nLoggingSeverity=debug" > /ffs/run/cp_runtime.ini
    Connect to SMOD    alias=asib
    ssh.send_command   ${command}     connection=asib
    ssh.send_command   crasign /ffs/run/cp_runtime.ini      connection=asib

Waiting for RRC idle
     LOG TO CONSOLE    -Waiting for UE idle
     sleep   60
