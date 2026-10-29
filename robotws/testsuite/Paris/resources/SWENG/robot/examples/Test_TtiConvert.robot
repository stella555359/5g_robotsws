*** Settings ***

Resource                ../TtiConvertInterface.robot
Resource                ../Tools.robot
Library                 OperatingSystem

Documentation           Refer to the TtiConvertInterface.robot file and the TtiAnalysis.py file for more information

*** Variables ***

${path_to_pcap}                /home/ute/Downloads/TTITraces/TTI_traffic.pcap
${path_to_pcap2}               /home/ute/Downloads/TTITraces/TTI_traffic2.pcap
${path_to_pcap3}               /home/ute/Downloads/TTITraces/TTI_trace.pcap
#@{example_events_list}        dlFdSchedData    ulFdSchedData
@{example_events_list}         dlPdcchDciData

*** Test Cases ***

Test TTI Conversion
    [Tags]    DEBUG
    Dated Log New Line          Downloading pcap file using KW "Download Package Using Git" on "NPS_VRF_8_and_9" Git project
    ${git_path}                 set variable    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ${token_name}               set variable    NpsVrfToken
    ${token_access}             set variable    glpat-4yNB_jaBXxz_BsyeAsgL
    ${git_folder}               set variable    SWENG/Test_files
    ${git_file_name}            set variable    TTI_traffic2.pcap
    ${target_dir}               set variable    /tmp
    Download Package Using Git                  git_path=${git_path}
    ...                                         git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    ...                                         target_dir=${target_dir}
    ...                                         token_name=${token_name}
    ...                                         token_access=${token_access}

    Copy File                                      ${target_dir}/${git_file_name}     destination=${path_to_pcap}
    Copy File                                      ${path_to_pcap}                    destination=${path_to_pcap2}
    TtiConvertInterface.Convert TTI capture        ${path_to_pcap2}                   ${example_events_list}
    # ...            tti_decoder_path=/ebs/dbacchie/TTI/bin
    TtiConvertInterface.Convert TTI capture        ${path_to_pcap}
    TtiConvertInterface.Convert TTI capture        ${path_to_pcap3}
