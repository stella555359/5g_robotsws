*** Settings ***
Documentation
...         This file implements Sherpa keywords with in particular:
...         - Support to configure Sherpa traces on gNB
...         - Support to collect traces via TCP dump on WTS
...
...         Generic sherpa capturing can be implemented in features managing this variable that is set in Setup.robot:
...
...         ${enable_sherpa}
...
...         Check value of the variable ${enable_sherpa} to run your keyword
...
...         usage example:
...
...         Run Keyword If                  ${enable_sherpa}==${True}               Sherpa.Activate Sherpa
...
...         The variable value must be set to True using the robot -v option with variable *hire_a_sherpa*, example:
...
...         robot -v hire_a_sherpa:True  myrobotscript.robot
...
...         This can be done also in Jenkins jobs (ex: features 1248 or 679)
...
...         Author: Davide Bacchiega
...
...         contact: davide.bacchiega@nokia.com
...
...         Creation Date: 18-Nov-2019
...
...         Modified Date: 1-Jul-2021
...
...         Last Modified by: Davide Bacchiega

Library           OperatingSystem
Library           DateTime
Library           String
Library           Process
Library           Collections
Library           taf.transport.ssh                   WITH NAME    csn
Library           taf.analyzer.sherpa                 WITH NAME    SherpaCsvReader
Library           taf.converters.sherpa               WITH NAME    sherpa_converter
Library           taf.collectors.tcpdump              WITH NAME    tcpdump
Library           taf.collectors.l2stream3            WITH NAME    l2stream3
Library           taf.collectors.core                 WITH NAME    core
Library           ../python/Sherpa_new_connect.py     WITH NAME    sherpa_new
Resource          Connect.robot
Resource          Setup.robot
Resource          Tools.robot
Resource          Scf.robot

*** Variables ***
${process_handle}
${mydocker}
${alias_gnb}
&{executor}         host=192.168.255.1              user=Nemuadmin          password=nemuuser       port=443
&{curl_options}
&{curl_options2}
&{curl_options3}
&{curl_options4}
&{curl_options5}
&{curl_options6}
${Destination_port}                 4556
${gNB_Mplane_IP}                    10.0.1.111
${Udp_Receiver_wts_IP}              10.0.1.150

*** Keywords ***

#################################################################################################
#                   sherpa traces activation and capture keywords
#################################################################################################

Configure gNb for sherpa traces
    [Documentation]             Configure the gNb TRSW icom gateway for Sherpa traces (activating internal traces)
    ${alias_gnb}                SSH Connect                    ${AIRSCALE_GNB.sys[0].M}
    set suite variable          ${alias_gnb}
    Dated Log                   Configuring GNB for sherpa. Board Type is: ${AIRSCALE_GNB.sys[0].M.boardType}        True
    ${output}                   run keyword if                 '${AIRSCALE_GNB.sys[0].M.boardType}'=='ASIB'
    ...                         Configure gNb sherpa Asib      ${Destination_port}        ${gNB_Mplane_IP}
    ...                         ${Udp_Receiver_wts_IP}
    ...        ELSE             Configure gNb sherpa Asik      ${Destination_port}        ${gNB_Mplane_IP}
    ...                         ${Udp_Receiver_wts_IP}
    Dated Log                   GNB Internal trace activation output is:${output}
    run keyword if              '${AIRSCALE_GNB.sys[0].M.boardType}'=='ASIK'
    ...                         Should Contain                 ${output}                  [ENABLED]

Configure gNb sherpa Asik
    [Documentation]     Mainly for INTERNAL USAGE.
    [Arguments]         ${Destination_port}    ${gNB_Mplane_IP}    ${Udp_Receiver_wts_IP}
    SSH Cmd
    ...    /opt/trs/bin/trs-vppctl icom set_stream_conf src_ip ${gNB_Mplane_IP} dst_ip ${Udp_Receiver_wts_IP} dscp 32 dst_port ${Destination_port}
    ...    alias=${alias_gnb}
    SSH Cmd    /opt/trs/bin/trs-vppctl icom classical_mode enable
    ...        alias=${alias_gnb}
    ${output}    SSH Cmd    /opt/trs/bin/trs-vppctl icom classical_mode status
    ...          alias=${alias_gnb}
    [return]    ${output}

Configure gNb sherpa Asib
    [Documentation]     Mainly for INTERNAL USAGE.
    [Arguments]         ${Destination_port}    ${gNB_Mplane_IP}    ${Udp_Receiver_wts_IP}
    ${output}    SSH Cmd    /opt/trs/bin/vtc 5gicomgw stream_config_add ${gNB_Mplane_IP} ${Udp_Receiver_wts_IP} ${Destination_port} 32
    ...          alias=${alias_gnb}
    [return]     ${output}

Activate Sherpa
    [Documentation]     Activate Internal traces and Sherpa traces on gnb using COAM gui, logs the sherpa version
    ...                 A trace capture is then started. To stop it, use Deactivate Sherpa and Stop Collect
    ...                 It can work on Degraded cells, but guess it is not the ideal case.
    ...                 Better to use it ONLY if TL has CELL SETUP ok.
    ...                 This KW uses taf libraries, only usable on UTE TLs
    [Arguments]             ${l2ps}=${TRUE}    ${l2lo}=${TRUE}    ${l2hi}=${TRUE}
    ...                     ${cell_path}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    log    ${l2ps}    ${l2lo}    ${l2hi}    ${cell_path}
    ${collector_source_ip}          Get Source IP for Collector
    Configure gNb for sherpa traces
    Log Sherpa Version
    Setup Sherpa Traces
    Activate Sherpa and Collect     ${collector_source_ip}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                             10.0.1.1

Log Sherpa Version
    [Documentation]                 Mainly for INTERNAL USAGE.
    ${rc}    ${output} =            Run and Return RC and Output            cd /opt/Nokia/Sherpa_5G_18/;./Sherpa.run --version
    ${result} =                     Get Lines Containing String             ${output}
    ...                             Sherpa5G_
    Dated Log New Line              Installed sherpa release: ${result}

Get Source IP for Collector
    [Documentation]                 Mainly for INTERNAL USAGE.
    scf.SCF StartSession            scf_file=${SCF_SETUP_PATH}
    ${dist_name}                    Set Variable                        MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${result}                       Scf.SCF Get Single Value            ${dist_name}
    ...                             localIpAddr
    Dated Log New Line              LOCAL IP is: ${result}[0]
    [Return]                        ${result}[0]

Setup Sherpa Traces
    [Documentation]     Mainly for INTERNAL USAGE. Set up the lists to activate Sherpa traces on gnb using COAM gui,
    [Arguments]    ${L2PS}=${TRUE}    ${L2LO}=${TRUE}    ${L2Hi}=${TRUE}
    ${nr_phy_cell_ids}    Get PhyCellIds
    @{curl_list}      Create List
    Set To Dictionary    ${curl_options}     nr_phy_cell_ids=${nr_phy_cell_ids}    trace_type=Sherpa
    Set To Dictionary    ${curl_options2}    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Lo       trace_type=Sherpa
    Set To Dictionary    ${curl_options3}    nr_phy_cell_ids=${nr_phy_cell_ids}    trace_type=Component
    Set To Dictionary    ${curl_options4}    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Lo       trace_type=Component
    Set To Dictionary    ${curl_options5}    up_sw=L2HiPdcp                  trace_type=Sherpa
    Set To Dictionary    ${curl_options6}    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2HiRlc    trace_type=Sherpa
    Run Keyword If    '${L2PS}'=='${TRUE}'
    ...              Append To List    ${curl_list}    ${curl_options}    ${curl_options3}
    Run Keyword If    '${L2LO}'=='${TRUE}'
    ...              Append To List    ${curl_list}    ${curl_options2}    ${curl_options4}
    Run Keyword If    '${L2Hi}'=='${TRUE}'
    ...              Append To List    ${curl_list}    ${curl_options5}    ${curl_options6}
    Set Suite Variable    ${curl_list}
    [Return]    @{curl_list}

Activate Sherpa and Collect
    [Documentation]     Mainly for INTERNAL USAGE. please use the KW named Activate Sherpa.
    ...                 This KW uses taf libraries, only usable on UTE TLs
    [Arguments]    ${source_ip_addr}    ${gnb_ip}    ${dest_ip}=10.0.1.1
    ${executor.host}                Set Variable                ${gnb_ip}
    tcpdump.create tcpdump collector
    ...    name=tcpdump
    ...    options=-i eth3 udp and src ${source_ip_addr} and dst ${dest_ip} and dst port 5678
    ...    sudo_password=ute
#    l2stream3.create coam l2stream collector
#    ...    name=l2stream3
#    ...    webservice=${executor}
#    ...    vlan=1
#    ...    source_ip_addr=${source_ip_addr}
#    ...    destination_ip_addr=${dest_ip}
#    ...    collector=tcpdump
#    ...    l2_stream_configuration=${curl_list}
    l2stream3.Set Suite Alias       l2stream3
    core.setup_collectors           names=l2stream3
    core.start_collectors           names=l2stream3

Deactivate Sherpa and Stop Collect
    [Documentation]     Before using activate Sherpa traces on gnb using COAM gui or the dedicated KW
    ...                 Condition: use ONLY after Activate Sherpa usage
    core.stop_collectors            names=l2stream3
    ${trace_dir}                    Set Variable                ${LOG_PATH}
    Set Suite Variable              ${trace_dir}
    core.collect_collectors         names=l2stream3             target_dir=${trace_dir}
    core.teardown_collectors        names=l2stream3

#################################################################################################
#                   Checking content in cvs sherpa generated files
#################################################################################################

Verify Message presence in csv Files
    [Documentation]     Verify the presence of a given message in cvs files issued from sherpa
    ...                 return True if found, False if not
    [Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${directory}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory             ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Values In File    ${ColumnName}    ${valuetocheck}
        Exit For Loop If    "${found}"=="True"
    END
    Should be equal    "${found}"    "True"
    [Return]    ${found}

Verify Regex in csv File Column
    [Documentation]     Verify the presence of a given regex in a cvs file issued from sherpa
    ...                 return True if found in every row for a given column, False if not
    [Arguments]    ${CsvName}    ${ColumnName}    ${regex_tocheck}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directory     ${Sherpa_logs_local_path}/Sherpa_logs
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Regex Value In File Column    ${ColumnName}    ${regex_tocheck}
        Exit For Loop If    "${found}"=="True"
    END
    Should be equal    "${found}"    "True"
    [Return]    ${found}

Verify Regex in csv File Column with Prerequisite
    [Documentation]     Verify the presence of a given regex with another regex prerequisite in a cvs file issued from sherpa
    ...                 return True if both regex are found in row containing the prerequisite for a given column, False if not
    [Arguments]    ${CsvName}    ${ColumnName}    ${regex_prereq}    ${regex_tocheck}           ${directory}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory                ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Regex Value In File Column If Another
        ...             ${ColumnName}    ${regex_prereq}    ${regex_tocheck}
        Exit For Loop If    "${found}"=="True"
    END
    Should be equal    "${found}"    "True"
    [Return]    ${found}

Verify Value List In csv File Column
    [Documentation]     Verify the presence of a given list of values in a column and for each row in cvs files generated by sherpa.
    ...                 A check is performed with a precondition that is the presence of a value in a predefined column of the same row
    ...                 returns True if checked, False if not
    [Arguments]    ${CsvName}    ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directory     ${sherpa_output_path}/tcpdump
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Value List In File Column With Prerequisite
        ...                                     ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}
        Exit For Loop If    "${found}"=="True"
    END
    Should be equal    "${found}"    "True"
    [Return]    ${found}

Loop on files
    [Documentation]     INTERNAL USAGE ONLY
    ...                 Look for csv required file to check in csv dir; when found perform the check on it
    ...                 ${KW_name_torun}      the KW used to perform the check
    ...                 @{param_list_forcsv}  the parameters for KW_name_torun
    [Arguments]             ${my_dir}    ${CsvName}    ${KW_name_torun}    @{param_list_forcsv}
    ${found} =    Set Variable    False
    @{my_sub_dir} =    OperatingSystem.List Directory           ${sherpa_output_path}/${my_dir}
    FOR  ${file}  IN  @{my_sub_dir}
         BuiltIn.Log    File is:\n ${file}      console=yes
         ${found}    Run Keyword if    "${file}"=="${CsvName}"    ${KW_name_torun}     ${sherpa_output_path}/${my_dir}/${file}
         ...        @{param_list_forcsv}    ELSE    Set Variable    False
         Exit For Loop If    "${found}"=="True"
    END
    [Return]    ${found}

Check Values In File
    [Documentation]     INTERNAL USAGE ONLY
    ...                 Verify the presence of a given set of values in a cvs file generated by sherpa
    ...                 returns True if all of them are found, False if not
    [Arguments]         ${file}    ${Column_name}    ${valuetocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    BuiltIn.Log    Params are:\n${Column_name} ${valuetocheck}    console=yes
    ${result}     SherpaCsvReader.check all values for column    ${Column_name}    ${valuetocheck}
    [Return]    ${result}

Check Regex Value In File Column
    [Documentation]     INTERNAL USAGE ONLY
    ...                 Verify a regex expression on all the values in a column from a cvs file generated by sherpa
    ...                 returns True if all of them are found, False if not
    [Arguments]         ${file}    ${Column_name}    ${regex_tocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Regex in csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}     SherpaCsvReader.check csv column match all    ${Column_name}    ${regex_tocheck}
    BuiltIn.Log    \ncolumn values:\n @{result}[1]      console=yes
    [Return]    @{result}[0]

Check Regex Value In File Column If Another
    [Documentation]     INTERNAL USAGE ONLY
    ...                 Verify a regex expression if another is already present on all the values from a given column
    ...                 from a cvs file generated from sherpa traces
    ...                 returns True if both are verified in lines containing the ${regex_prereq} value, False if not
    [Arguments]         ${file}    ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Regex in csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}     SherpaCsvReader.check values column matching regex match another    ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    BuiltIn.Log    \ncolumn values:\n @{result}[1]      console=yes
    [Return]    @{result}[0]

Check Value List In File Column With Prerequisite
    [Documentation]     INTERNAL USAGE ONLY
    ...                 Verify that a list of values is present in all the rows matching the required value for a given column
    ...                 in a cvs file generated by sherpa
    ...                 returns True if all of them are found, False if not
    [Arguments]         ${file}    ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Value List In csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}         SherpaCsvReader.check value list column when value
    ...               ${prereq_column}    ${prereq_column_val}    ${Column_name}    ${value_list}
    BuiltIn.Log       \nlist values:\n @{result}[1]      console=yes
    [Return]          @{result}[0]

#################################################################################################
#                   Generic KWs to run sherpa on pcap files and others
#################################################################################################

Upload and decode sherpa pcap files
    [Documentation]     Supported only on UTE Test Lines, where decoding is performed locally.
    ...                 Sherpa command line version is run on the pcap files found in subdirectories
    ...                 generating csv files
    ...                 USAGE CONDITIONS:
    ...                     ${Sherpa_logs_local_path} parameter value must avoid  '[' ']' or spaces
    [Arguments]         ${Sherpa_logs_local_path}    ${duration}=120
    Set Global Variable    ${Sherpa_logs_local_path}
    @{my_files}            OperatingSystem.List Files In Directory    ${Sherpa_logs_local_path}/l2stream3/tcpdump    *.pcap
    Loop on Sherpa Captured Files               ${my_files}           ${Sherpa_logs_local_path}/l2stream3/tcpdump    ${duration}
    Copy File              /tmp/sherpa5G.log                          ${Sherpa_logs_local_path}

Loop on Sherpa Captured Files
    [Documentation]     Run Sherpa on a given set of pcap files. For each one a subdirectory with name based on epoch
    ...                 is created to contain the resulting csv files.
    ...                 Run Sherpa KW is called to generate the csv files.
    [Arguments]             ${my_files}    ${Sherpa_logs_local_path}    ${duration}=120
    FOR    ${file}    IN     @{my_files}
        ${surrent_epoch}     Tools.Get Date Epoch
        run    cd '${Sherpa_logs_local_path}';mkdir ${surrent_epoch};mv ${file} ${surrent_epoch}
        ${file_path}         set Variable           ${Sherpa_logs_local_path}/${surrent_epoch}/${file}
        ${output}            run                    if [ -f ${file_path} ] ; then echo "yes" ; else echo "no" ; fi
        Dated Log            Checking if file exists: result is --- ${output}
        ${pcap_size}         run                    stat -c "%s" ${file_path}
        Dated Log            Running sherpa on pcap file of size: ${pcap_size}
        Sherpa.Run Sherpa    ${Sherpa_logs_local_path}/${surrent_epoch}     ${Sherpa_logs_local_path}/${surrent_epoch}/${file}
        ...                  duration=${duration}    macro_period=1000
    END

Run Sherpa
    [Documentation]     Run Sherpa on a given pcap file with options
    ...                 Mainly for INTERNAL USAGE
    ...                 output_path:    output dir path where csv files are generated
    ...                 duration:       duration in seconds (optional, to limit pcap treatment)
    ...                 macro_period:   typical default value is 1000
    [Arguments]            ${output_path}           ${pcap_file}        ${duration}=None
    ...                    ${macro_period}=None
    Dated Log              Pcap file path is:${pcap_file}
    &{optional_params}     Create Dictionary
    Run Keyword if         '${duration}'!='None'
    ...                    Set To Dictionary    ${optional_params}    sherpa_command_duration=${duration}
    Run Keyword if         '${macro_period}'!='None'
    ...                    Set To Dictionary    ${optional_params}    sherpa_command_macro_period=${macro_period}
    ${length}              Get Length           ${optional_params}
    BuiltIn.Log            \nSherpa output:\n ${output_path}             console=yes
    set suite variable     ${sherpa_output_path}                        ${output_path}
    Run Keyword if         ${length}>0
    ...                    sherpa_converter.Create Sherpa Converter      sherpaconverter      file_path_pattern=${pcap_file}
    ...                    output_path=${output_path}          &{optional_params}
    ...                    ELSE
    ...                    sherpa_converter.Create Sherpa Converter      sherpaconverter      file_path_pattern=${pcap_file}
    ...                    output_path=${output_path}
    sherpa_converter.setup           sherpaconverter
    sherpa_converter.convert         sherpaconverter
    sherpa_converter.teardown        sherpaconverter

Get PhyCellIds
    [Documentation]     INTERNAL USAGE ONLY
    @{phycell}    Create List
    @{cellsNr}    OAM Get Cells Nr    oam=${GNB_DU.oam}
    FOR    ${c}    IN    @{cellsNr}
         Append to List    ${phycell}    ${c['physicalCellId']}
    END
    [Return]    @{phycell}
