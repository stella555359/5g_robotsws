*** Settings ***

Documentation
...   This robot resource file contains KWs for BIP trace collection on gNB.

Library     taf.collectors.core         WITH NAME   core
Library     taf.collectors.l1l2bip      WITH NAME   l1l2bip
Resource    testline.robot


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

    ${collector}=   Start BIP Traces With TAF Collector     gnb_id=${gnb_id}
    ...                                                     collector=${collector}
    ...                                                     timeout=${timeout}
    ...                                                     merge_pcap_files=${True}
    ...                                                     remove_zip_file=${True}

    RETURN    ${collector}


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

    ${outfile}=    Stop BIP Traces With TAF Collector     collector=${collector}
    ...                                                   target_dir=${target_dir}

    RETURN  ${outfile}


Start BIP Traces With TAF Collector
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

    l1l2bip.Create Interface Mirroring L1l2bip Collector
    ...  name=${collector}
    ...  webservice=${webservice}
    ...  timeout=${timeout}
    ...  merge_pcap_files=${merge_pcap_files}
    ...  remove_zip_file=${remove_zip_file}

    core.Setup Collectors    names=${collector}
    core.Start Collectors    names=${collector}
    core.Set Suite Alias  ${collector}

    RETURN   ${collector}


Stop BIP Traces With TAF Collector
    [Documentation]
    ...  | collector | name of collector
    ...  | target_dir | Directory to store the pcap file
    [Arguments]     ${collector}
    ...             ${target_dir}=${None}

    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    core.Stop Collectors       names=${collector}
    core.Collect Collectors    names=${collector}  target_dir=${target_dir}
    core.Teardown Collectors   names=${collector}
    ${pcap_files}=    List Files In Directory    ${target_dir}/${collector}   *.pcap

    ${pcap_full_paths}=    Create List
    FOR    ${file}   IN   @{pcap_files}
        ${full_path}   Join Path    ${target_dir}/${collector}   ${file}
        Append To List    ${pcap_full_paths}   ${full_path}
    END

    RETURN    ${pcap_full_paths}
