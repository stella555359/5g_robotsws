*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Author: Han Ruiyu
...              Contact: ruiyu.han@nokia-sbell.com
...              Squard: HZ SG7
Library    OperatingSystem
Library   Collections
Library   String
Library    taf.transport.ssh   WITH NAME   csn
Library   ../libraries/snapshot_files.py
Resource   ../../common/taf_env.robot
Resource   ../../common/taf_coam.robot
Variables     ../../libraries/global_vars.py
Resource   coam.robot
Library   OperatingSystem

*** Variables ***
${package_version}    0.830.558
${package_web_service}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${MO_NAME}  ${tl.gnbs[0].global_bts_id}
${TTI_bin}    L2TtiTrace_EventsSnapshot.bin
${TTILog_dir}    TTILog

*** Keywords ***
Download and TAR TTI Decorder Tool to TAF VM
    ${package_version}    Format COAM Release
    ${coam_version}    _Get_gnb_version
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   /home/ute/Downloads/ttitrace-${package_version}
    Run    rm -rf /home/ute/Downloads/ttitrace-*
    ${package_download_dir}=   Set Variable
    ...   ${package_web_service}/${package_version}
    ${package_download_path}=   Set Variable   ${package_download_dir}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P /home/ute/Downloads
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec_qemux86-64-static.txz
    OperatingSystem.File Should Exist   /home/ute/Downloads/${coam_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf /home/ute/Downloads/${coam_version}_tti-dec_qemux86-64-static.txz -C ${ttidecoder_path}
    [Return]   ${ttidecoder_path}


TTI Decoder Run Bin or Pcap to Json
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.json
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    Run   pyenv local 3.6.8
    ${output}    Run
    ...  cd ${OUTPUT_DIR};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} json
    Should Not Contain    ${output}    error
    sleep   5min
    Run   pyenv local 2.7.13
#    ${jsonfile}    Run    ls | grep json
#    ${jsonfile}    strip string    ${jsonfile}
    File Should Not Be Empty    ${OUTPUTDIR}/decoderOutput.json
    ${jsonfile_path}    set variable   ${OUTPUTDIR}/decoderOutput.json
    [Return]    ${jsonfile_path}

TTI Decoder Run Bin or Pcap to CSV
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.csv
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    Run   pyenv local 3.6.8
    ${output}    Run
    ...  cd ${OUTPUT_DIR};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} excelCsv
    Should Not Contain    ${output}    error
    sleep   5min
    Run   pyenv local 2.7.13
    ${csvfile}    Run    ls | grep csv
    @{csvfiles}  	Split String	${csvfile}	 \n
    ${csvfiles_path}    Create List
    FOR   ${csvfile}  IN   @{csvfiles}
        File Should Not Be Empty    ${csvfile}
        Append to list    ${csvfiles_path}     ${OUTPUTDIR}/${csvfile}
    END
    [Return]    @{csvfiles_path}

Check Json File Valid
    [Arguments]     ${jsonfile_path}
    decode_csv  ${jsonfile_path}
    ${filecontext}    Get File    ${jsonfile_path}
    Should Start With    ${filecontext}    {\n"events": [
    Should End With    ${filecontext}    ]\n}\n
    Should Contain Any    ${filecontext}    dssSlotTypeData    body    eventHeader    sfn    slot    rnti    physCellId

Check TTI Decoder Tool
     [Arguments]     ${input_file}
     ${ttidecoder_path}    Download and TAR TTI Decorder Tool to TAF VM
     ${target_json}    TTI Decoder Run Bin or Pcap to Json     inputfile_path=${input_file}     ttidecoder_path=${ttidecoder_path}
     Check Json File Valid    jsonfile_path=${target_json}
     ${target_csvs}    TTI Decoder Run Bin or Pcap to CSV     inputfile_path=${input_file}     ttidecoder_path=${ttidecoder_path}
#     Check CSV Files Valid    ${target_csvs}

Get_Coam_Snapshop
    COAM Login
    ${snapshot_filename}    Catch Snapshot COAM
    COAM Logout
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    [Return]   ${FILE_STRUCT}

check snapshot_TTI
    ${FILE_STRUCT}   Get_Coam_Snapshop
    ${TTI_folder}    ${key_TTI}  snapshot_files.get_file_from_snapshot_by_key
    ...    key_name=${TTI_bin}      snapshot_structure=${FILE_STRUCT}
    run    cd ${OUTPUT_DIR}/snapshot/;unzip -d ${TTILog_dir} ${TTI_folder}
    run    cd ${OUTPUT_DIR}/snapshot/${TTILog_dir}
    should contain    container=${TTI_bin}   item=L2TtiTrace
    [Return]    ${TTI_folder}    ${key_TTI}

