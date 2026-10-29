*** Settings ***
Resource             ../resources.txt

*** Variables ***

${yaml_file}         ${CURDIR}/oam.yaml

*** Keywords ***
Stop_log_collection
    [Documentation]                 stop log collection on all VM's
    [Arguments]                     ${names}
    core.stop_collectors            names=${names}

Collect_logs
    [Documentation]                 collect the log files to default path & close the all the connections at the end.
    [Arguments]                     ${names}    ${target_dir}=${EMPTY}
    ${log_file}=                    core.collect_collectors   names=${names}    target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]                        ${log_file}

Create_collectors_via_YAML
    [Arguments]                     ${yaml_file}=${yaml_file}     ${names}=gnb_oam_tcpdump
    [Documentation]                 create tcpdump log collection via YAML on specified VM.
    ...                             names: name of the collector. Ex: gnb_pm_counters
    ${configurations}=              core.Load Configurations     ${yaml_file}
    core.Create Collectors          names=${names}               configurations=${configurations['collectors']}
    core.Set Suite Alias            ${names}

Collect_tcpdump_cpcl
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpcl_tcpdump
    core.setup_collectors           names=gnb_cpcl_tcpdump
    core.start_collectors           names=gnb_cpcl_tcpdump

Collect_tcpdump_cpnb
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpnb_tcpdump
    core.setup_collectors           names=gnb_cpnb_tcpdump
    core.start_collectors           names=gnb_cpnb_tcpdump

Collect_tcpdump_cpif
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpif_tcpdump
    core.setup_collectors           names=gnb_cpif_tcpdump
    core.start_collectors           names=gnb_cpif_tcpdump

Collect_oam_snapshot
    Create_collectors_via_YAML      ${yaml_file}     names=oam_gnb_snapshot
    core.setup_collectors           names=oam_gnb_snapshot
    Collect_logs                    names=oam_gnb_snapshot

Collect_pm_files
    Create_collectors_via_YAML      ${yaml_file}     names=pm_files
    core.setup_collectors           names=pm_files
    Collect_logs                    names=pm_files

Collect_tcpdump_cprt
    [Documentation]                 ASIK slave cprt
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cprt_tcpdump
    core.setup_collectors           names=gnb_cprt_tcpdump
    core.start_collectors           names=gnb_cprt_tcpdump

Collect_tcpdump_cpnrt
    [Documentation]                 ASIK slave cpnrt
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpnrt_tcpdump
    core.setup_collectors           names=gnb_cpnrt_tcpdump
    core.start_collectors           names=gnb_cpnrt_tcpdump

Collect_journal_cpcl
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpcl_journal
    core.setup_collectors           names=gnb_cpcl_journal
    core.start_collectors           names=gnb_cpcl_journal

Collect_journal_cpnb
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpnb_journal
    core.setup_collectors           names=gnb_cpnb_journal
    core.start_collectors           names=gnb_cpnb_journal

Collect_journal_cpif
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpif_journal
    core.setup_collectors           names=gnb_cpif_journal
    core.start_collectors           names=gnb_cpif_journal

Collect_journal_cprt
    [Documentation]                 ASIK slave cprt
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cprt_journal
    core.setup_collectors           names=gnb_cprt_journal
    core.start_collectors           names=gnb_cprt_journal

Collect_journal_cpnrt
    [Documentation]                 ASIK slave cpnrt
    Create_collectors_via_YAML      ${yaml_file}     names=gnb_cpnrt_journal
    core.setup_collectors           names=gnb_cpnrt_journal
    core.start_collectors           names=gnb_cpnrt_journal

Collect_tcpdump_list
     Create_collectors_via_YAML      ${yaml_file}     names=gnb_list
     core.setup_collectors           names=gnb_list
     core.start_collectors           names=gnb_list

Collect logs To Directory
    [Documentation]
    [Arguments]   ${names}    ${target_dir}=${EMPTY}
    core.collect_collectors   names=${names}   target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]

Collect pm files To Path
    [Arguments]   ${pm_files_path}=${EMPTY}
    Create_collectors_via_YAML      ${yaml_file}     names=pm_files
    core.setup_collectors           names=pm_files
    Collect logs To Directory                    names=pm_files   target_dir=${pm_files_path}