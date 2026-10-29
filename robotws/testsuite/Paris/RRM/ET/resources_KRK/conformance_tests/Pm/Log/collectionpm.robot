*** Settings ***
Documentation
...               Pm Counters Collection Management

Resource             ../pmresoures.txt

*** Variables ***
${yaml_file}         ${CURDIR}/forpm.yaml
# Richard : depending Cloud or Classical, we have to use a specific yaml file
${yaml_file_cloud}         ${CURDIR}/forpm_cloud.yaml

*** Keywords ***
Collect log files
    [Documentation]                 collect the log files and close the all the connections at the end.
    [Arguments]                     ${names}    ${target_dir}=${EMPTY}
    ${log_file}=                    core.collect_collectors   names=${names}    target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]                        ${log_file}


Collectors with YAML
    [Documentation]                 create collection via YAML on specified VM with name
    [Arguments]                     ${yaml_file}=${yaml_file}     ${names}=gnb_oam_tcpdump
    ${configurations}=              core.Load Configurations     ${yaml_file}
    core.Create Collectors          names=${names}               configurations=${configurations['collectors']}
    core.Set Suite Alias            ${names}


Collect collectors with path
    [Documentation]                 create collection with patch
    [Arguments]   ${names}    ${target_dir}=${EMPTY}
    core.collect_collectors   names=${names}   target_dir=${target_dir}
    core.teardown_collectors        names=${names}
    [Return]


Collect pm with path
    [Documentation]                 Collect pm with collectors
    [Arguments]   ${pm_files_path}=${EMPTY}
    # Richard : depending Cloud or Classical, we have to use a specific yaml file
    # Collectors with YAML      ${yaml_file}     names=pm_files
    ${yaml}    set variable if    '${TLConfig.isGnbCloud}'=='${False}'    ${yaml_file}    ${yaml_file_cloud}
    Collectors with YAML      ${yaml}          names=pm_files

    core.setup_collectors           names=pm_files
    Collect collectors with path                    names=pm_files   target_dir=${pm_files_path}

