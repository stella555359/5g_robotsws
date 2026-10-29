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

*** Variables ***
${package_version}    0.830.558
${package_web_service}
...   https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${package_web_service_SBTS}
#...   https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build

${MO_NAME}  ${tl.gnbs[0].global_bts_id}
${TTI_bin}    L2TtiTrace_EventsSnapshot.bin
${TTILog_dir}    TTILog
${TTI_json}    L2.*json


*** Keywords ***
Download and TAR TTI Decorder Tool to TAF VM
    ${release}    Get gnb release
    Run keyword if   '${release}'=='TRUNK'    Set Suite Variable    ${release}    SBTS00
    ...   ELSE   Set Suite Variable    ${release}    ${release}
    ${coam_version}   _Get_gnb_version
    ${coam_version}   run keyword if   '${release}'=='SBTS00'   Replace String Using Regexp   ${coam_version}   SBTS\\d\\dR\\d   SBTS00
    ...   ELSE   Set Variable    ${coam_version}
    Set Suite Variable   ${coam_version}   ${coam_version}
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   ${OUTPUT_DIR}/ttitrace-${coam_version}
    Run    rm -rf ${OUTPUT_DIR}/ttitrace-*
#    ${status}    ${version_path_list}    run keyword and ignore error  	  	Get Regexp Matches    ${AF_PATH}   \\d+.\\d+.\\d+
#    ${version_path_list}     run keyword if   ${status.count('FAIL')}    Get Regexp Matches    ${ENB_BUILD}   \\d+.\\d+.\\d+
#    ...   ELSE    Set Variable    ${version_path_list}
    ${version_path_list}    Get Regexp Matches    ${coam_version}   \\d+.\\d+.\\d+
    run keyword if  ${release.count('SBTS')} > 0    Set Suite Variable   ${qemux86_download_path}
    ...   ${package_web_service_SBTS}/${release}/${coam_version}/${coam_version}_tti-dec_qemux86-64-static.txz
    ...   ELSE   Set Suite Variable  ${qemux86_download_path}
    ...   ${package_web_service}/${version_path_list[0]}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${qemux86_download_path} -P ${OUTPUT_DIR}
    Wait Until Keyword Succeeds   10m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec_qemux86-64-static.txz
    OperatingSystem.File Should Exist   ${OUTPUT_DIR}/${coam_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf ${OUTPUT_DIR}/${coam_version}_tti-dec_qemux86-64-static.txz -C ${ttidecoder_path}
    [Return]   ${ttidecoder_path}

TTI Decoder Run Bin or Pcap to Json
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.json
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    run keyword if  ${inputfile.count('.xz')} > 0    Run   unxz -k ${ttidecoder_path}/tti-dec-bin/${inputfile}
    ${inputfile}   fetch from left   ${inputfile}    .xz
#    Run   pyenv local 3.6.8
    ${output}    Run
    ...  cd ${OUTPUT_DIR};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} json
    Should Not Contain any   ${output}    error   fail   Error   Fail
    #    Should Not Contain any   ${output}    Fail   fail   FAIL
    #sleep   10min
#    Run   pyenv local 2.7.13
#    ${jsonfile}    Run    ls | grep json
#    ${jsonfile}    strip string    ${jsonfile}
#    Run Keyword If    '${release}'=='SBTS00'   File Should Not Be Empty    ${ttidecoder_path}/tti-dec-bin/decoderOutput.json
#    ...   ELSE   File Should Not Be Empty   ${OUTPUT_DIR}/decoderOutput.json
    ${jsonfile_path}   Run   ls ${ttidecoder_path}/tti-dec-bin |grep -E "${TTI_json}"
    Run Keyword If   '${release}'=='SBTS00'   File Should Not Be Empty   ${ttidecoder_path}/tti-dec-bin/${jsonfile_path}
    ...   ELSE IF   '${release}'>='SBTS26R1'   File Should Not Be Empty   ${ttidecoder_path}/tti-dec-bin/${jsonfile_path}
    ...   ELSE IF   '${release}'<='SBTS25R3'   File Should Not Be Empty   ${ttidecoder_path}/tti-dec-bin/decoderOutput.json
    ...   ELSE   File Should Not Be Empty   ${OUTPUT_DIR}/decoderOutput.json
#    ${jsonfile_path}  Set Variable If  '${release}'=='SBTS00'  ${ttidecoder_path}/tti-dec-bin/decoderOutput.json   ${OUTPUT_DIR}/decoderOutput.json
    ${jsonfile_path}   Run Keyword If   '${release}'=='SBTS00'   Set Variable   ${ttidecoder_path}/tti-dec-bin/${jsonfile_path}
    ...   ELSE IF   '${release}'>='SBTS26R1'   Set Variable   ${ttidecoder_path}/tti-dec-bin/${jsonfile_path}
    ...   ELSE IF   '${release}'<='SBTS25R3'   Set Variable   ${ttidecoder_path}/tti-dec-bin/decoderOutput.json
    ...   ELSE   Set Variable   ${OUTPUT_DIR}/decoderOutput.json
    [Return]    ${jsonfile_path}

TTI Decoder Run Bin or Pcap to CSV
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.csv
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    run keyword if  ${inputfile.count('.xz')} > 0    Run   unxz ${ttidecoder_path}/tti-dec-bin/${inputfile}
    ${inputfile}   fetch from left   ${inputfile}    .xz
#    Run   pyenv local 3.6.8
    wait until keyword succeeds    3x   10s    _install_pandas_package
#    wait until keyword succeeds    3x   15s    _install_tti_dec_deb_dependen_package
    #sleep   5min
    ${output}    Run
    ...  cd ${OUTPUT_DIR};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} excelCsv
    Should Not Contain any   ${output}    error   fail   Error   Fail
    # Should Not Contain any   ${output}    Fail   fail   FAIL
    #sleep   5min
    ${csvfile}    Run    cd ${OUTPUT_DIR};ls | grep csv
    @{csvfiles}  	Split String	${csvfile}	 \n
    ${csvfiles_path}    Create List
#    :FOR   ${csvfile}  IN   @{csvfiles}
#        File Should Not Be Empty    ${OUTPUTDIR}/${csvfile}
#        Append to list    ${csvfiles_path}     ${OUTPUTDIR}/${csvfile}
#    END
    File Should Not Be Empty    ${OUTPUTDIR}/ttiTrace_dl.csv
    Append to list    ${csvfiles_path}     ${OUTPUTDIR}/ttiTrace_dl.csv
    File Should Not Be Empty   ${OUTPUTDIR}/ttiTrace_ul.csv
    Append to list    ${csvfiles_path}  ${OUTPUTDIR}/ttiTrace_ul.csv
    [Return]    @{csvfiles_path}

_install_pandas_package
#    ${output}   RUN    pip3 list | grep pandas
#    run keyword if   ${output.count('pandas')} <= 0    _install_internal_pandas
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    ${gnb_release}   set variable   ${gnb_release}
    run keyword if   '${gnb_release}'=='SBTS23R4'    _install_internal_pandas_v131
    ...   ELSE IF   '${gnb_release}'=='SBTS24R1'    _install_internal_pandas_v131
    ...   ELSE   _install_internal_pandas

_install_internal_pandas
    ${output}    Run
    ...  cd ${OUTPUT_DIR};pip3 install pandas --proxy=http://10.144.1.10:8080
    Should Not Contain any   ${output}    error   fail   Error   Fail

_install_internal_pandas_v131
    ${output}    Run
    ...  cd ${OUTPUT_DIR};pip3 install pandas==1.3.1 --proxy=http://10.144.1.10:8080
    Should Not Contain any   ${output}    error   fail   Error   Fail

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

Get_Coam_Snapshop
    COAM Login
    ${snapshot_filename}    Catch Snapshot COAM
    COAM Logout
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    wait until keyword succeeds    5min   30s
    ...   snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    [Return]   ${FILE_STRUCT}

check snapshot_TTI
    ${FILE_STRUCT}   Get_Coam_Snapshop
    ${return_dic}    snapshot_files.get_files_from_snapshot_by_key
    ...    key_name=${TTI_bin}      snapshot_structure=${FILE_STRUCT}
    ${filessz_list}    create list
    ${filesz_dic}   create dictionary
    FOR    ${key}   IN    @{return_dic}
         ${keyname}    fetch from left    ${key}    .zip
         run    cd ${OUTPUT_DIR}/snapshot/;unzip -d ${TTILog_dir}_${keyname} ${key}
         ${filessz_list}   ${filesz_dic}    _get_file_size_for_each_folder
         ...   ${keyname}  ${return_dic['${key}']}    ${filessz_list}   ${filesz_dic}
    END
    sort list    ${filessz_list}
    ${key_TTI}    set variable    ${filesz_dic[${filessz_list}[-1]]}
    [Return]    ${key_TTI}


_get_file_size_for_each_folder
    [Arguments]   ${key}   ${file_list}    ${filessz_list}   ${filesz_dic}
    FOR  ${file}  IN   @{file_list}
        ${file_size}    OperatingSystem.Get File Size  ${OUTPUT_DIR}/snapshot/${TTILog_dir}_${key}/${file}
        append to list   ${filessz_list}    ${file_size}
        Set To Dictionary   ${filesz_dic}    ${file_size}     ${OUTPUT_DIR}/snapshot/${TTILog_dir}_${key}/${file}
    END
    [Return]   ${filessz_list}   ${filesz_dic}

_install_tti_dec_deb_dependen_package
    Log    \n Start to Download XXX_tti-dec.deb Package From WFT ....    INFO
    run keyword if  ${release.count('SBTS')} > 0    Set Suite Variable   ${deb_download_path}
    ...   ${package_web_service_SBTS}/${release}/${coam_version}/${coam_version}_tti-dec.deb
    ...   ELSE   Set Suite Variable  ${deb_download_path}
    ...   ${package_web_service}/${version_path_list[0]}/${coam_version}_tti-dec.deb
    Run   rm -f wget-log*
    Run   rm -rf ${deb_download_path}/*.deb
    Run   wget -b ${deb_download_path} -P ${OUTPUT_DIR}
    Wait Until Keyword Succeeds   3m   1m   Wait Until wget process done
    ...  ${coam_version}_tti-dec.deb
    OperatingSystem.File Should Exist   ${OUTPUT_DIR}/${coam_version}_tti-dec.deb
    Log To Console    Download xxx_tti-dec.deb Package Finished!!!
    Log    \n Start to install xxx_tti-dec.deb ....    INFO
    ${out_deb}   Run   ls ${OUTPUT_DIR}}|grep 'tti-dec.deb'
    Set Variable    ${out_deb}
    Run    env|grep -i proxy;unset http_proxy https_proxy
    Run    export http_proxy=http://10.144.1.10:8080;export https_proxy=http://10.144.1.10:8080;env|grep -i proxy
    Wait Until Keyword Succeeds   6m   2m   Run   sudo dpkg -i ${OUTPUT_DIR}/${out_deb} 2>&1|grep 'Success'
    [Return]   ${out_deb}
