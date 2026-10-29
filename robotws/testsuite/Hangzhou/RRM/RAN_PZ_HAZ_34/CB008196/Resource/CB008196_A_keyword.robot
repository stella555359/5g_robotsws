*** Settings ***
Documentation
...  author: Zhang Jin 2
...  contact: jin.2.zhang@nokia-sbell.com


Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Library     taf.sbts.oam.coam.admin                WITH NAME    coam
Library     String
Library     OperatingSystem
Library     DateTime
Library     XML
Library     Collections
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     taf.rfrl.common_resources.python.check_cap.CapPacket    WITH NAME   cap
Library         taf.collectors.core         WITH NAME       core
Library         taf.collectors.tcpdump      WITH NAME       tcpdump
Library    taf.transport.ssh    WITH NAME    csn
Library     ./csvanalyzer.py



*** Variables ***

${ue_type}        huawei
${GN_OAM_ADDR}     10.68.141.144
${START_PAGE}       https://gansulbwas.gansu.srnhz.nsn-rdnet.net/
${START_PAGE_USER}    omc
${START_PAGE_PASSWORD}   Nokia126_
${MO_NAME}          MRBTS-1997
${MRBTS_ID}         1997
${NRBTS}            NRBTS-10291
${target_dir}       /home/ute/Projects/tcpdump_log
${delta_combined}     ${CURDIR}/delta_8196_combined.json
${delta_delete}       ${CURDIR}/delta_8196_delete.json
${delta_combined_23R2}     ${CURDIR}/delta_8196_combined_23R2.json



*** Keyword ***
Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to False
    [Arguments]    ${bip_file}    ${csv_file}
    Convert tcpdump file to CSV for 8396
    ...  filter=(nsetapx.CuVendorExtensionRecordDataType == 3&&nsetapx.measResultSsbIndexes >= 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file}
    ${check_status}    Run Keyword And Return Status   Get and Check tcpdumpfile
    ...    item=nsetapx.CuVendorExtensionRecordDataType
    ...    value=3
    ...    CSV_FILE=${csv_file}
    should be equal as strings    ${check_status}     False


Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True
    [Arguments]    ${bip_file}      ${csv_file1}    ${csv_file2}   ${csv_file3}
    Convert tcpdump file to CSV for 8396
    ...  filter=(nr-rrc.reportType==0&&nr-rrc.includeBeamMeasurements==1&&nr-rrc.reportAmount==7&&nr-rrc.reportInterval==6&&nr-rrc.rsType==0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    ${file_size}=    CB008196_A_keyword.Get File Size    file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 8396
    ...  filter=(nsetapx.CuVendorExtensionRecordDataType == 3&&nsetapx.measResultSsbIndexes >= 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nsetapx.CuVendorExtensionRecordDataType
    ...    value=3
    ...    CSV_FILE=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nsetapx.measResultSsbIndexes
    ...    value=6
    ...    CSV_FILE=${csv_file2}

    Convert tcpdump file to CSV for 8396
    ...  filter=(nr-rrc.criticalExtensions == 0&&nr-rrc.resultsSSB_Indexes >= 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.criticalExtensions    #cell trace
    ...    value=0
    ...    CSV_FILE=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.resultsSSB_Indexes
    ...    value=6
    ...    CSV_FILE=${csv_file3}

Get File Size
    [Arguments]   ${file_path}
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE_CON
    ${file_info}   csn.Execute   command=cat ${file_path} |wc -l   connection=UTE_CON
    Set Suite Variable      ${file_size}    ${file_info.replace('\n','').strip()}
    [Return]   ${file_size}
    [teardown]     Run keyword and ignore error     csn.disconnect    connection=UTE_CON


Convert wireshark To CSV By NSETAPX
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}    Set Variable
    ${title}    Set Variable    -o ntrstr.port:49148 -o ntrstr.defragment:TRUE
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info ${title}
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}



Convert tcpdump file to CSV for 8396
    [Arguments]    ${filter}     ${bip_files}   ${csv_file}
    #${csv_file}    Replace String    ${bip_files}    .pcap    .csv
    #Set Suite Variable    ${CSV_FILE}    ${csv_file}

    @{csv_title_list1}    Create List     nsetapx.CuVendorExtensionRecordDataType   nr-rrc.reportType
    ...     nr-rrc.includeBeamMeasurements    nr-rrc.reportAmount    nr-rrc.reportInterval    nr-rrc.rsType
    ...     nr-rrc.criticalExtensions      nr-rrc.resultsSSB_Indexes    nsetapx.measResultSsbIndexes
    Convert wireshark To CSV By NSETAPX    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list1}


Get and Check tcpdumpfile
   [Arguments]    ${item}    ${value}   ${CSV_FILE}
   Verify Special Item Value Exist New
   ...      file_path=${CSV_FILE}
   ...      item=${item}
   ...      item_value=${value}


Verify Special Item Value Exist New
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${item}    ${item_value}
    ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
    ${status}  Run Keyword And Return Status  List Should Contain Value    ${special_item_value_list}    ${item_value}
    run keyword if  not ${status}  Should Contain Any  ${special_item_value_list}[0]    ${item_value}  5
    






Start to collect wireshark log for ASIK
    [Arguments]    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    ${name}=SCTP    ${options}=-i fp0  #1997
    #...    ${name}=SCTP    ${options}=-i br0   #1969
    ${gNB_ASIK_collector_config}=   create dictionary   host=${host}
    ...                                                 user=${username}
    ...                                                 password=${password}
    tcpdump.create_tcpdump_collector                name=${name}
    ...                                             options=${options}
    ...                                             executor=${gNB_ASIK_collector_config}
    core.setup_collectors       names=${name}
    core.start_collectors       names=${name}
    core.Set Suite Alias     ${name}
    log                         \nStarting tcpdump



UEs detach
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${1}


The first UE make the first SA call
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}


The second UE perform the second SA Call
    power_ue.Prepare UE    ue_index=${1}    ue_type=${ue_type}
    power_ue.UE Attach    ue_index=${1}    ue_type=${ue_type}


Common 8196_A Setup
    Run Keyword And Continue On Failure  create directory  ${target_dir}
    Run keyword And Ignore Error  Remove Directory  ${target_dir}  recursive=True
    Run keyword and ignore error    scf.Activate or Deactivate feature    delta_file=${delta_delete}
    sleep   100s

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    scf.Activate or Deactivate feature    delta_file=${delta_combined}
    ...    ELSE       scf.Activate or Deactivate feature    delta_file=${delta_combined_23R2}

    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    power_ue.Prepare UE    ue_index=${1}    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${1}
    sleep   100s
    Adjust Attenuation Port Value    port=${RU2}    value=${0}
    Adjust Attenuation Port Value    port=${RU1}    value=${0}

gNB Set Attribute Value
	[Documentation]     Set gNB Param Value using webUI
    [Arguments]         ${dist_name}    ${p_name}    ${new_value}
    coam.connect_to     bts_host=${GN_OAM_ADDR}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${p_name}    operation=update
    ...                                       value=${new_value}    skip_parameter_relation_errors=False
    [Teardown]          coam.teardown


gNB Get SCF Content
    [Documentation]     Get SCF content
    coam.connect_to     bts_host=${GN_OAM_ADDR}
    ${content}=         coam.get_current_scf_content
    [Return]            ${content}
    [Teardown]          coam.teardown


gNB Get Attribute value in SCF
    [Documentation]     Get element value in SCF content
    [Arguments]         ${dist_name}    ${p_name}
    ${content}=         CB008196_A_keyword.gNB Get SCF Content
    ${xml_root}=        XML.Parse XML    ${content}


    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${dist_name}"]/p[@name="${p_name}"]
    [Return]            ${result.text}




Check the PCMD and cell trace Related parameters via WEBUI For CB008196

    ${d_name}=                         set variable                      MRBTS-1997/NRBTS-10291
    ${p_name}                          set variable                      actCellTraceReport
    ${p_name2}                          set variable                      actPCMDReport

    ${CurrentValue}                CB008196_A_keyword.gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    ${CurrentValue2}               CB008196_A_keyword.gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name2}

    Should Be Equal As Strings  ${CurrentValue}    true
    Should Be Equal As Strings  ${CurrentValue2}   true

    log to console         actCellTraceReport value is ${CurrentValue}
    log to console         actPCMDReport value is ${CurrentValue2}


Check the PCMD and cell trace Related parameters via WEBUI For CB008196_2

    ${d_name}=                         set variable                      MRBTS-1997/NRBTS-10291
    ${p_name}                          set variable                      actCellTraceReport
    ${p_name2}                          set variable                      actPCMDReport

    ${CurrentValue}                 CB008196_A_keyword.gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    ${CurrentValue2}                CB008196_A_keyword.gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name2}

    Should Be Equal As Strings  ${CurrentValue}    false
    Should Be Equal As Strings  ${CurrentValue2}   false

    log to console         actCellTraceReport value is ${CurrentValue}
    log to console         actPCMDReport value is ${CurrentValue2}
