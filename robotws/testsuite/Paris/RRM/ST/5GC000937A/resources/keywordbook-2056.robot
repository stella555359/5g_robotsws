*** Settings ***

*** Variables ***

*** Keywords ***
Get eNB data
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi eNB
    ...     check if real or simulated eNB
    ...     suite variable  ${realEnb} returns true or false
    [Arguments]          ${enb_id}=0
    ${status}    run keyword and return status    variable should exist     ${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ${realEnb}   Set Variable If   '${status}' == 'True'     true     false
    set suite variable    ${realEnb}

extract lnbts distname from SCF
    [Documentation]    [PRIVATE]
    ...      Extract lnbts distName for eNB SCF
    ...     :Autor: Gerard Bonhaure
    ...     :param ${enb_id}: eNB instance id
    [Arguments]	   ${enb_id}=0
    get lnbts distname from SCF    scf_file=${resultBaseDir}/SCFC_start_enb_${enb_id}.xml   enb_id=${enb_id}

get lnbts distname from SCF
    [Documentation]    [PRIVATE]     extract lnbts distname from SCF
    ...     :Autor: Gerard Bonhaure
    ...     :param ${scf_file}: SCF file with path
    ...     :param ${enb_id}: eNB instance id
    [Arguments]       ${scf_file}   ${enb_id}=0
    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF_ext01}    distName_LNBTS
    ${bts_dist}      get element attribute    ${parsed_SCF}    distName    xpath=${xpath}
    ${splitted_mrbts_distName}   ${splitted_lnbts_distName}=     Split String From Right  ${bts_dist}   /   1

    set suite variable    ${enb_${enb_id}_bts_distName}        ${bts_dist}
    set suite variable    ${enb_${enb_id}_mrbts_distName}      ${splitted_mrbts_distName}
    set suite variable    ${enb_${enb_id}_lnbts_distName}      ${splitted_lnbts_distName}

    Log to console    \nenb_${enb_id} bts_distName: "${enb_${enb_id}_bts_distName}"
    Log to console    \nenb_${enb_id} mrbts_distName: "${enb_${enb_id}_mrbts_distName}"
    Log to console    \nenb_${enb_id} lnbts_distName: "${enb_${enb_id}_lnbts_distName}"

Start wireshark LTE ext02
    [Documentation]    for real LTE eNB
    [Arguments]   ${enb_id}=0    ${vlan_id}=0
    &{lte_oam_ssh}    Create Dictionary
    ...  host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...  user=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.username}
    ...  password=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.password}

    tcpdump.create_tcpdump_collector
    ...     name=lte_x2_dump_enb_${enb_id}
    ...     options=-i br1.${vlan_id}
    ...     executor=${lte_oam_ssh}

    tcpdump.Set Suite Alias     lte_x2_dump_enb_${enb_id}

    tcpdump.setup_collectors
    ...    names=lte_x2_dump_enb_${enb_id}
    tcpdump.start_collectors
    ...    names=lte_x2_dump_enb_${enb_id}

Stop wireshark LTE ext02
    [Arguments]    ${file_name}
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=lte_x2_dump
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=lte_x2_dump
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=lte_x2_dump
    Run Keyword And Continue On Failure  Move File    ${resultDir}/lte_x2_dump/lte_x2_dump.pcap    ${resultDir}/${file_name}

Stop wireshark LTE ext03
    [Arguments]    ${enb_id}=0    ${file_name}=none
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=lte_x2_dump_enb_${enb_id}
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=lte_x2_dump_enb_${enb_id}
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=lte_x2_dump_enb_${enb_id}
    Run Keyword And Continue On Failure  Move File
    ...    ${resultDir}/lte_x2_dump_enb_${enb_id}/lte_x2_dump_enb_${enb_id}.pcap    ${resultDir}/${file_name}


Collect snapshot enb
    [Documentation]    [PRIVATE]   collect snapshot on enb
    ...     :Autor: Gerard Bonhaure
    ...     :param ${enb_id}: eNB instance id
    [Arguments]    ${enb_id}=0

    builtIn.Log To Console    \nsnapshot enb started on enb_${enb_id}
    admin.connect_to
    ...    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=enb

    ${path_SCF}     admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot_enb_${enb_id}/snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=240
    ...    connection=enb

    admin.teardown    connection=enb
    BuiltIn.Log To Console    \nsnapshot enb finished for enb enb_${enb_id}
