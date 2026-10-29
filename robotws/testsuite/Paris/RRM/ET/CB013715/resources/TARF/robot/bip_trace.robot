*** Settings ***

Documentation
...   This robot resource file contains KWs for BIP trace collection on gNB.

Library     taf.collectors.l1l2bip      WITH NAME   l1l2bip
Resource    testline-Keywords.robot


*** Keywords ***
Start BIP Traces
    [Documentation]
    ...
    ...    Starts the BIP Traces and returns the collector name
    ...
    ...    | gnb_id    | Id/Number of gNB |
    ...    | collector | Name of collector *Impact on log filename* |
    ...    | timeout   | Timeout for the single keywords to collect the traces |
    ...
    ...    *Returns* Name of collector used for the traces
    ...
    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=gnb-${gnb_id}-bip-tcpdump
    ...            ${timeout}=300

    ${collector}=   Start BIP Traces with taf collector     gnb_id=${gnb_id}
    ...                                                     collector=${collector}
    ...                                                     timeout=${timeout}
    ...                                                     merge_pcap_files=${True}
    ...                                                     remove_zip_file=${True}

    [Return]    ${collector}


Stop BIP Traces
    [Documentation]
    ...
    ...    Stops the BIP Traces and returns the path to the pcap file
    ...
    ...    | gnb_id |  Id/Number of gNB |
    ...    | collector |  Name of collector used at start command |
    ...    | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to BIP trace file
    ...

    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=gnb-${gnb_id}-bip-tcpdump
    ...            ${target_dir}=${None}

    ${outfile}=    Stop BIP Traces with taf collector     collector=${collector}
    ...                                                   target_dir=${target_dir}

    [RETURN]  ${outfile}


Start BIP Traces with taf collector
    [Documentation]
    ...    Start gNB BIP traces using taf.collectors.l1l2bip
    ...
    ...    | gnb_id               | Id/Number of gNB |
    ...    | collector            | name of collector |
    ...    | merge_pcap_files     | whether the pcap files should be merged or not default: True files will be merged. |
    ...    | remove_zip_file=None | flag for deleting zip file after extracting all pcap files. |

    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=bip_traces
    ...            ${timeout}=300
    ...            ${merge_pcap_files}=${True}
    ...            ${remove_zip_file}=${True}

    ${webservice}=   Get Webservice For Collector   ${tl}   ${gnb_id}

    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${collector}
    ...  webservice=${webservice}
    ...  timeout=${timeout}
    ...  merge_pcap_files=${merge_pcap_files}
    ...  remove_zip_file=${remove_zip_file}

    core.setup_collectors    names=${collector}
    core.start_collectors    names=${collector}
    core.set_suite_alias  ${collector}

    [Return]   ${collector}


Stop BIP Traces with taf collector
    [Documentation]
    ...  | collector | name of collector
    ...  | target_dir | Directory to store the pcap file
    [Arguments]     ${collector}
    ...             ${target_dir}=${None}

    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}

    core.stop_collectors       names=${collector}
    core.collect_collectors    names=${collector}  target_dir=${target_dir}
    core.teardown_collectors   names=${collector}

    ${pcap_files}=    List Files In Directory    ${target_dir}/${collector}   *.pcap

    ${pcap_full_paths}=    Create List
    FOR    ${file}   IN   @{pcap_files}
        ${full_path}   Join Path    ${target_dir}/${collector}   ${file}
        Append To List    ${pcap_full_paths}   ${full_path}
    END

    [Return]    ${pcap_full_paths}
