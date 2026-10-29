*** Settings ***
Documentation
...         == Purpose ==
...
...         This robot library implements the usage of Sherpa.
...
...         == Description ==
...         Implementation of the usage of Sherpa.
...         - Support to configure Sherpa traces on gNB
...         - Support to collect traces via TCP dump on WTS

...         *Concepts:*.
...         Generic sherpa capturing can be implemented in features managing this variable that is set in Setup.robot:
...
...         ${enable_sherpa}
...
...         Check value of the variable ${enable_sherpa} to run your keyword.
...
...         Decoding and checking is supported via taf libraries included in this file. Please refer to taf documentation for details.
...         Better to avoid using directly taf methods and KWs,
...         use th KWs implemented in this file as suggested in the examples.
...
...         *Examples:*
...         How to use ${enable_sherpa}:
...         | Run Keyword If \ \ \ \ \ \ \ \ \ \ \ \ ${enable_sherpa}==${True} \ \ \ \ \ \ \ \ \ \ Sherpa.Activate Sherpa
...
...         The variable value must be set to True using the robot -v option with variable *hire_a_sherpa*, example:
...
...         robot -v hire_a_sherpa:True  myrobotscript.robot
...
...         This must be done also in Jenkins jobs for this variable to be effective (ex: features 1248 or 679).
...
...         How to implement Sherpa usage for checks:
...         Please refer to file examples/SherpaUsage.robot
...         and use the KWs present in the section of this file named *Checking content in csv sherpa generated files*


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
Resource          Connect.robot
Resource          Setup.robot
Resource          Tools.robot
Resource          Scf.robot

*** Variables ***
${process_handle}
${mydocker}
${alias_gnb}
&{executor}         host=192.168.255.129      user=Nemuadmin     password=nemuuser       port=443
&{curl_options}
&{curl_options2}
&{curl_options3}
&{curl_options4}
&{curl_options5}
&{curl_options6}
${Destination_port}                 4556
${gNB_Mplane_IP}                    10.0.1.111
${Udp_Receiver_wts_IP}              10.0.1.150
${Destination_port_asim}            4556
${gNB_Mplane_IP_asim}               10.0.1.2
${Udp_Receiver_wts_IP_asim}         10.0.1.1

*** Keywords ***

#################################################################################################
#                   sherpa traces activation and capture keywords
#################################################################################################

Configure gNb for sherpa traces
    [Documentation]             Configure the gNb TRSW icom gateway for Sherpa traces (activating internal traces).
    ${alias_gnb}                SSH Connect                    ${GNB_DU.sys[0].M}
    set suite variable          ${alias_gnb}
    Dated Log                   Configuring GNB for sherpa. Board Type is: ${GNB_DU.sys[0].M.boardType}        True
    ${output}                   run keyword if                 '${GNB_DU.sys[0].M.boardType}'=='ASIB'
    ...                         Configure gNb sherpa Asib      ${Destination_port}        ${gNB_Mplane_IP}
    ...                         ${Udp_Receiver_wts_IP}
    ...        ELSE IF          '${GNB_DU.sys[0].M.boardType}'=='ASIM'                    Configure gNb sherpa Asim
    ...                         ${Destination_port_asim}       ${gNB_Mplane_IP_asim}      ${Udp_Receiver_wts_IP_asim}
    ...        ELSE             Configure gNb sherpa Asik      ${Destination_port}        ${gNB_Mplane_IP}
    ...                         ${Udp_Receiver_wts_IP}
    Dated Log                   GNB Internal trace activation output is:${output}
    run keyword if              '${GNB_DU.sys[0].M.boardType}'=='ASIK'
    ...                         Should Contain                 ${output}                  [ENABLED]

Configure gNb sherpa Asik
    [Documentation]     INTERNAL USAGE.
    [Arguments]         ${Destination_port}    ${gNB_Mplane_IP}    ${Udp_Receiver_wts_IP}
    SSH Cmd
    ...    /opt/trs/bin/trs-vppctl icom set_stream_conf src_ip ${gNB_Mplane_IP} dst_ip ${Udp_Receiver_wts_IP} dscp 15 dst_port ${Destination_port}
    ...    alias=${alias_gnb}
    SSH Cmd    /opt/trs/bin/trs-vppctl icom classical_mode enable
    ...        alias=${alias_gnb}
    ${output}    SSH Cmd    /opt/trs/bin/trs-vppctl icom classical_mode status
    ...          alias=${alias_gnb}
    [return]    ${output}

Configure gNb sherpa Asim
    [Documentation]     INTERNAL USAGE.
    [Arguments]         ${Destination_port}    ${gNB_Mplane_IP}    ${Udp_Receiver_wts_IP}
    ${output}    SSH Cmd    /opt/trs/bin/vtc 5gicomgw stream_config_add ${gNB_Mplane_IP} ${Udp_Receiver_wts_IP} ${Destination_port} 7
    ...          alias=${alias_gnb}
    [return]    ${output}

Configure gNb sherpa Asib
    [Documentation]     INTERNAL USAGE.
    [Arguments]         ${Destination_port}    ${gNB_Mplane_IP}    ${Udp_Receiver_wts_IP}
    ${output}    SSH Cmd    /opt/trs/bin/vtc 5gicomgw stream_config_add ${gNB_Mplane_IP} ${Udp_Receiver_wts_IP} ${Destination_port} 32
    ...          alias=${alias_gnb}
    [return]     ${output}

Activate Sherpa
    [Documentation]                 Activate Internal traces and Sherpa traces on gnb using COAM gui, logs the sherpa version.
    ...                             A trace capture is then started. To stop it, use Deactivate Sherpa and Stop Collect.
    ...                             It can work on Degraded cells, but guess it is not the ideal case.
    ...                             Better to use it ONLY if TL has CELL SETUP ok.
    ...                             This KW uses taf libraries, only usable on UTE TLs.
    Run Keyword If                  ${isAic}    Start To Collect Sherpa Trace On AIC
    Return From Keyword If          ${isAic}

    ${collector_source_ip}          Get Source IP for Collector
    Configure gNb for sherpa traces
    Log Sherpa Version
    Setup Sherpa Traces             L2Hi=${FALSE}            L2LO=${FALSE}
    Activate Sherpa and Collect     ${collector_source_ip}
    ...                             ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                             ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                             ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                             10.0.1.1

Log Sherpa Version
    [Documentation]                 INTERNAL USAGE.
    ${rc}    ${output} =            Run and Return RC and Output            cd /opt/Nokia/Sherpa_5G_18/;./Sherpa.run --version
    ${result} =                     Get Lines Containing String             ${output}
    ...                             Sherpa5G_
    Dated Log New Line              Installed sherpa release: ${result}

Get Source IP for Collector
    [Documentation]                 INTERNAL USAGE.
    scf.SCF StartSession            scf_file=${SCF_SETUP_PATH}
    ${dist_name}                    Set Variable                        MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-[0-9]{1,2}/IPADDRESSV4-1
    ${result}                       Scf.SCF Get Single Value By Pattern           ${dist_name}
    ...                             localIpAddr
    Dated Log New Line              LOCAL IP is: ${result}[0]
    [Return]                        ${result}[0]

Setup Sherpa Traces
    [Documentation]      INTERNAL USAGE. Set up the lists to activate Sherpa traces on gnb using COAM gui.
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
    [Documentation]     INTERNAL USAGE. please use the KW named Activate Sherpa.
    ...                 This KW uses taf libraries, only usable on UTE TLs.
    [Arguments]    ${source_ip_addr}
    ...            ${oam_ip}
    ...            ${oam_user}
    ...            ${oam_password}
    ...            ${dest_ip}=10.0.1.1

    ${executor.host}                Set Variable                ${oam_ip}
    ${executor.user}                Set Variable                ${oam_user}
    ${executor.password}            Set Variable                ${oam_password}
    tcpdump.create tcpdump collector
    ...    name=tcpdump
    ...    options=-i eth3 udp and src ${source_ip_addr} and dst ${dest_ip} and dst port 5678
    ...    sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...    name=l2stream3
    ...    webservice=${executor}
    #...    vlan=1
    ...    source_ip_addr=${source_ip_addr}
    ...    destination_ip_addr=${dest_ip}
    ...    dscp=15
    ...    collector=tcpdump
    ...    l2_stream_configuration=${curl_list}
    l2stream3.Set Suite Alias       l2stream3
    core.setup_collectors           names=l2stream3
    core.start_collectors           names=l2stream3

Deactivate Sherpa and Stop Collect
    [Documentation]     Before using activate Sherpa traces on gnb using COAM gui or the dedicated KW.
    ...                 Condition: use ONLY after Activate Sherpa usage KW.
    [Arguments]                     ${keep_pcap_file}=${False}
    ${trace_dir}                    Set Variable                ${LOG_PATH}
    Set Suite Variable              ${trace_dir}
    Run Keyword If      ${isAic}    Stop And Download Sherpa Trace On AIC
    Return From Keyword If          ${isAic}
    core.stop_collectors            names=l2stream3
    core.collect_collectors         names=l2stream3             target_dir=${trace_dir}
    core.teardown_collectors        names=l2stream3
    # If required, move the pcap file into a sub dir
    # By default, the generated .pcap files remain in the original directory and
    # will be erased at the next call of Sherpa
    Run Keyword If                  ${keep_pcap_file}==${True}
    ...                             Move Sherpa Pcap Files      ${trace_dir}

Move Sherpa Pcap Files
    [Documentation]     INTERNAL USAGE
    ...                 Rename all .pcap files existing in the trace directory by adding testcase name
    ...                 as extension for each of them
    ...                 ${trace_dir}    path to the directory where sherpa .pcap files are stored
    [Arguments]         ${trace_dir}
    # get the list of .pcap files generated by Sherpa
    ${src_pcap_dir}                Set Variable                ${trace_dir}/l2stream3/tcpdump
    @{pcap_files}                  List Files In Directory     ${src_pcap_dir}          *.pcap
    # get the short test name (i.e. remove spaces, simple quotes and [x][xx] from TEST_NAME)
    # Ex: '[1][1.0] abcd efgh' --> abcdefgh
    ${short_test_name}             Replace String Using Regexp     ${TEST_NAME}          ${SPACE}      ${EMPTY}
    ${short_test_name}             Replace String Using Regexp     ${short_test_name}    \\'           ${EMPTY}
    ${short_test_name}             Replace String Using Regexp     ${short_test_name}    \\[.*\\]      ${EMPTY}
    # Create the subdir where to move pcap files
    ${dest_pcap_dir}               Set Variable                    ${trace_dir}/${short_test_name}
    run                            mkdir ${dest_pcap_dir}
    # set the suite variable to be used later
    Set Suite Variable             ${Sherpa_subfolder_name}        ${short_test_name}
    # move pcap files to the sub-directory
    Dated Log                      Moving Sherpa pcap files from ${src_pcap_dir} to ${dest_pcap_dir}
    FOR    ${file}    IN     @{pcap_files}
        Dated Log                  Moving file ${file}
        run                        mv ${src_pcap_dir}/${file} ${dest_pcap_dir}
    END

#################################################################################################
#                   Checking content in csv sherpa generated files
#################################################################################################

Verify Message presence in csv Files
    [Documentation]     Verify the presence of a given message (or a list of msgs) in csv files issued from sherpa.
    ...                 - The directory parameter indicates where csv files are stored, \
    ...                   usually default value is given by the variable sherpa_output_path.
    ...                 - The *valuetocheck* presence is verified in column *ColumnName* for all the files named *CsvName* \
    ...                   found in *directory* subdirectories.
    ...                 - Return True if found, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${directory}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory             ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Values In File    ${ColumnName}    ${valuetocheck}
        Exit For Loop If    "${found}"=="True"
    END
    [Return]    ${found}

Verify value with operator in csv Files
    [Documentation]     Verify the values in csv files column issued from sherpa using an operator and a reference value.
    ...                 - The directory parameter indicates where csv files are stored, \
    ...                   usually default value is given by the variable sherpa_output_path
    ...                 - The *valuetocheck* is checked with *check_operator* in column *ColumnName* for all the values from the files named \
    ...                   *CsvName* found in *directory* subdirectories.
    ...                 - Return True if the condition is verified for all the values, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${check_operator}    ${directory}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory             ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}               ${CsvName}         Check Values on Operator In File
        ...           ${ColumnName}    ${check_operator}    ${valuetocheck}
        Exit For Loop If    "${found}"=="False"
    END
    [Return]           ${found}

Verify value with operator in csv Files with Prerequisite
    [Documentation]     Verify the values in csv files column issued from sherpa using an operator and a reference value.
    ...                 The verification is done with another regex prerequisite, applying a first filter.
    ...                 - The directory parameter indicates where csv files are stored, \
    ...                   usually default value is given by the variable sherpa_output_path
    ...                 - The *valuetocheck* is checked with *check_operator* in column *ColumnName* for all the values from the files named \
    ...                   *CsvName* found in *directory* subdirectories.
    ...                 - A regex_prereq regular expression applied to the column_prereq content. This generates a first temporary subset of \
    ...                   rows from the csv file, on which the Verification is done with value + operator.
    ...                 - Return True if the condition is verified for all the values, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${check_operator}    ${directory}    ${regex_prereq}    ${colum_prereq}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory             ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}               ${CsvName}         Check Values on Operator In File
        ...           ${ColumnName}    ${check_operator}    ${valuetocheck}    ${regex_prereq}    ${colum_prereq}
        Exit For Loop If    "${found}"=="False"
    END
    [Return]           ${found}

Verify Regex in csv File Column
    [Documentation]     Verify the presence of a given regex in a csv file issued from sherpa.
    ...                 Return True if found in every row for a given column, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${regex_tocheck}    ${with_subdirs}=False
    ${verif_res} =                  Set Variable                                            False
    ${capture_subpath} =        Set Variable If                                             ${with_subdirs}
    ...                         ${sherpa_output_path}/tcpdump                               ${sherpa_output_path}
    @{my_dir} =                 OperatingSystem.List Directories In Directory               ${capture_subpath}
    FOR    ${dir}    IN     @{my_dir}
        ${verif_res} =    Loop on files    ${dir}    ${CsvName}    Check Regex Value In File Column    ${ColumnName}    ${regex_tocheck}
        Exit For Loop If    "${verif_res}"=="True"
    END
    Set Global Variable     ${verif_res}
    [Return]                ${verif_res}

Verify Regex in csv File Column with Prerequisite
    [Documentation]     Verify the presence of a given regex with another regex prerequisite in a csv file issued from sherpa.
    ...                 Return True if both regex are found in row containing the prerequisite for a given column, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${regex_prereq}    ${regex_tocheck}           ${directory}
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directory                ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}    Check Regex Value In File Column If Another
        ...             ${ColumnName}    ${regex_prereq}    ${regex_tocheck}
        Exit For Loop If    "${found}"=="True"
    END
    [Return]    ${found}

Verify Value List In csv File Column
    [Documentation]     Verify the presence of a given list of values in a column and for each row in csv files generated by sherpa.
    ...                 A check is performed with a precondition that is the presence of a value in a predefined column of the same row.
    ...                 with_subdirs parameters can be used (set to True) to manage multiple captures subdirs in tcpdump directory
    ...                 Returns True if checked, False if not.
    [Arguments]    ${CsvName}    ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}    ${with_subdirs}=False
    ${found} =                  Set Variable                                                False
    ${capture_subpath} =        Set Variable If                                             ${with_subdirs}
    ...                         ${sherpa_output_path}/tcpdump                               ${sherpa_output_path}
    @{my_dir} =                 OperatingSystem.List Directories In Directory               ${capture_subpath}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}    ${CsvName}        Check Value List In File Column With Prerequisite
        ...                                      ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}
        Exit For Loop If               "${found}"=="True"
    END
    [Return]    ${found}

Verify Regex in csv File Column with Regex Prereq
    [Documentation]     Verify the presence of a given regex in rows
    ...                 filtered with another regex prerequisite in a csv file issued from sherpa.
    ...                 Return True if both regex are found in row containing the prerequisite for a given column, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${regex_prereq}    ${regex_tocheck}           ${directory}
    @{results} =    Create List
    @{found} =      Create List    False     @{results}
    @{my_dir} =     OperatingSystem.List Directories In Directory                ${directory}
    FOR    ${dir}    IN     @{my_dir}
        @{found} =    Loop on files    ${dir}    ${CsvName}    Check Regex Value In File Column With Prerequisite
        ...             ${ColumnName}    ${regex_prereq}    ${regex_tocheck}
        Exit For Loop If    "@{found}[0]"=="True"
    END
    [Return]    @{found}

Loop on files
    [Documentation]     INTERNAL USAGE
    ...                 Look for csv required file to check in csv dir; when found perform the check on it.
    ...                 ${KW_name_torun}      the KW used to perform the check
    ...                 @{param_list_forcsv}  the parameters for KW_name_torun
    [Arguments]             ${my_dir}    ${CsvName}    ${KW_name_torun}    @{param_list_forcsv}
    ${found} =    Set Variable    False
    @{my_sub_dir} =    OperatingSystem.List Directory           ${sherpa_output_path}/${my_dir}
    FOR  ${file}  IN  @{my_sub_dir}
         Dated Log    File is:\n ${file}
         ${found}    Run Keyword if    "${file}"=="${CsvName}"    ${KW_name_torun}     ${sherpa_output_path}/${my_dir}/${file}
         ...        @{param_list_forcsv}    ELSE    Set Variable    False
         Exit For Loop If    "${file}"=="${CsvName}"
    END
    [Return]    ${found}

Check Values In File
    [Documentation]     INTERNAL USAGE
    ...                 Verify the presence of a given set of values in a csv file generated by sherpa
    ...                 returns True if all of them are found, False if not.
    [Arguments]         ${file}    ${Column_name}    ${valuetocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    # Reactivate for debug
    # Dated Log    Params are:\n${Column_name} ${valuetocheck}
    ${result}     SherpaCsvReader.check all values for column    ${Column_name}    ${valuetocheck}
    [Return]    ${result}

Check Values on Operator In File
    [Documentation]     INTERNAL USAGE
    ...                 Verify the integer numeric string values in a csv file generated by sherpa using an operator and a reference value
    ...                 returns True if all of them satisfy the condition, False if not.
    [Arguments]         ${file}    ${column_name}    ${check_operator}    ${valuetocheck}
    ...                 ${regex_prereq}=None        ${colum_prereq}=None    ${column_filter}=\d*
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    # Reactivate for debug
    # Dated Log             Params are:\n${valuetocheck} ${check_operator} ${column_name} ${regex_prereq} ${colum_prereq}
    @{result_temp}          Run Keyword if                                  '${regex_prereq}'!='None'
    ...                     SherpaCsvReader.check csv column match all match another            ${column_name}
    ...                     ${regex_prereq}                                 ${colum_prereq}     ${column_filter}
    ...                     ELSE
    ...                     SherpaCsvReader.check csv column match all      ${column_name}      ${column_filter}
    ${result}               Set Variable                                    ${None}
    @{values_to_check}      Set Variable                                    ${result_temp}[1]
    Dated Log               values_to_check is: ${values_to_check}
    FOR    ${elem}    IN    @{values_to_check}
        ${result}           Run keyword If              '${elem}'!=''
        ...                 Check on Operator           ${valuetocheck}      ${check_operator}
        ...                 ${elem}
        Exit For Loop If    "${result}"=="${False}"
    END
    Dated Log            Result is: ${result}
    [Return]    ${result}

Check on Operator
    [Documentation]     INTERNAL USAGE
    [arguments]    ${valuetotest}      ${operator}    ${val}
    ${normalized_val}     Evaluate    str(${val})
    ${result}      Evaluate    ${valuetotest} ${operator} ${normalized_val}
    # Reactivate for debug
    # Dated Log      checking ${valuetotest} ${operator} ${normalized_val}; result is ${result}
    [return]    ${result}

Check Regex Value In File Column
    [Documentation]     INTERNAL USAGE
    ...                 Verify a regex expression on all the values in a column from a csv file generated by sherpa
    ...                 returns True if all of them are found, False if not.
    [Arguments]         ${file}    ${Column_name}    ${regex_tocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Regex in csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}     SherpaCsvReader.check csv column match all    ${Column_name}    ${regex_tocheck}
    Dated Log    \ncolumn values:\n @{result}[1]
    [Return]    @{result}[0]

Check Regex Value In File Column If Another
    [Documentation]     INTERNAL USAGE
    ...                 Verify a regex expression if another is already present on all the values from a given column
    ...                 from a csv file generated from sherpa traces
    ...                 returns True if both are verified in lines containing the ${regex_prereq} value, False if not.
    [Arguments]         ${file}    ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Regex in csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}     SherpaCsvReader.check values column matching regex match another    ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    Dated Log    \ncolumn values:\n @{result}[1]
    [Return]    @{result}[0]

Check Value List In File Column With Prerequisite
    [Documentation]     INTERNAL USAGE
    ...                 Verify that a list of values is present in all the rows matching the required value for a given column
    ...                 in a csv file generated by sherpa
    ...                 returns True if all of them are found, False if not.
    [Arguments]         ${file}    ${Column_name}    ${value_list}    ${prereq_column}    ${prereq_column_val}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Value List In csv File Column
    SherpaCsvReader.setup reader    ${file}
    @{result}         SherpaCsvReader.check value list column when value
    ...               ${prereq_column}    ${prereq_column_val}    ${Column_name}    ${value_list}
    Dated Log       \nlist values:\n @{result}[1]
    [Return]          @{result}[0]

Check Regex Value In File Column With Prerequisite
    [Documentation]     INTERNAL USAGE
    ...                 Verify a regex expression in a given column if a value is present on the same rows
    ...                 from another given column
    ...                 from a csv file generated from sherpa traces
    ...                 return a boolean and a list of rows
    ...                 the boolean value is True if the value condition is verified in lines containing
    ...                 the ${regex_prereq} value for the related column, False if not.
    [Arguments]         ${file}    ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Regex in csv File Column with Regex Prereq
    SherpaCsvReader.setup reader    ${file}
    @{result}         SherpaCsvReader.check rows matching regex match another
    ...               ${Column_name}    ${regex_prereq}    ${regex_tocheck}
    Dated Log       \nlist values:\n @{result}[1]
    [Return]          @{result}


#################################################################################################
#                   Generic KWs to run sherpa on pcap files and others
#################################################################################################

Upload and decode sherpa pcap files
    [Documentation]     Supported only on UTE Test Lines, where decoding is performed locally.
    ...                 Sherpa command line version is run on the pcap files found in subdirectories
    ...                 generating csv files.
    ...                 USAGE CONDITIONS:
    ...                     ${Sherpa_logs_local_path} parameter value must avoid '[' ']' or spaces.
    [Arguments]         ${Sherpa_logs_local_path}
    ...                 ${duration}=120
    ...                 ${keep_pcap_file}=${False}
    Set Global Variable    ${Sherpa_logs_local_path}
    # use sub-dir if keep_pcap_file is set to ${True}
    ${pcap_dir}         Set Variable If    ${keep_pcap_file}==${True}
    ...                 ${Sherpa_logs_local_path}/${Sherpa_subfolder_name}
    ...                 ${Sherpa_logs_local_path}/l2stream3/tcpdump
    # use pcap_dir instead of ${Sherpa_logs_local_path}/l2stream3/tcpdump
    @{my_files}            OperatingSystem.List Files In Directory    ${pcap_dir}    *.pcap
    Dated Log              DEBUG -- Found files: ${my_files}
    #RDH: Workaround for the following Debian12 issue:
    # The /tmp/Sherpa5G_stdout.log is no more reachable, except if we change its owner info from root:root to ute:ute
    Dated Log              WARNING: DEBIAN12 WORKAROUNG WILL BE APPLIED...
    ${cmd_return}          run                      sudo chown ute:ute /tmp
    run keyword if         '${cmd_return}'!=''
    ...                     Dated Log       ERROR: the "sudo chown ute:ute /tmp" cmd returns: ${cmd_return}
    ...         ELSE        Dated Log       Workaround successfully applied
    #RDH: End of WorkAround
    Loop on Sherpa Captured Files               ${my_files}           ${pcap_dir}    ${duration}
    # use pcap_dir instead of ${Sherpa_logs_local_path}
    Copy File              /tmp/sherpa5G.log                          ${pcap_dir}
    # remove unused sub-directory and original .pcap files (already saved by Sherpa)
    Run KeyWord If         ${keep_pcap_file}==${True}
    ...                    Run                  rm -r ${pcap_dir}/l2stream3 ${pcap_dir}/*/*.pcap

Loop on Sherpa Captured Files
    [Documentation]     Run Sherpa on a given set of pcap files. For each one a subdirectory with name based on epoch
    ...                 is created to contain the resulting csv files.
    ...                 Run Sherpa KW is called to generate the csv files.
    [Arguments]             ${my_files}
    ...                     ${Sherpa_logs_local_path}
    ...                     ${duration}=120
    FOR    ${file}    IN     @{my_files}
        ${surrent_epoch}     Tools.Get Date Epoch
        run    cd '${Sherpa_logs_local_path}';mkdir ${surrent_epoch};mv ${file} ${surrent_epoch}
        ${file_path}         set Variable           ${Sherpa_logs_local_path}/${surrent_epoch}/${file}
        ${output}            run                    if [ -f ${file_path} ] ; then echo "yes" ; else echo "no" ; fi
        Dated Log            Checking if file exists: result is --- ${output}
        ${pcap_size}         run                    stat -c "%s" ${file_path}
        Dated Log            Running sherpa on pcap file of size: ${pcap_size}
        Should be true       ${pcap_size}>128       msg=ERROR: ${file_path} FILE IS EMPTY
        Sherpa.Run Sherpa    ${Sherpa_logs_local_path}/${surrent_epoch}     ${Sherpa_logs_local_path}/${surrent_epoch}/${file}
        ...                  duration=${duration}    macro_period=1000
    END

Run Sherpa
    [Documentation]     INTERNAL USAGE
    ...                 Run Sherpa on a given pcap file with options
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
    Dated Log            \nSherpa output:\n ${output_path}
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
    [Documentation]      INTERNAL USAGE
    @{phycell}    Create List
    @{cellsNr}    OAM Get Cells Nr    oam=${GNB_DU.oam}
    FOR    ${c}    IN    @{cellsNr}
         Dated Log       cell${c['physicalCellId']} ==> ${c['status']['blockingState']}:${c['status']['administrativeState']}
         run keyword if    "${c['status']['blockingState']}"=="Unblocked"
         ...                Append to List    ${phycell}    ${c['physicalCellId']}
    END
    [Return]    @{phycell}



#################################################################################################
#                  AIC KW
#################################################################################################

Start To Collect Sherpa Trace On AIC
    [Documentation]
    ...    ATTENTION : the keyword "Scf.Add Sherpa Route in SCF for AIC" must be called to update the SCF with the route
    ...                before calling this keyword
    ...    Start to collect Sherpa traces for AIC
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the IP address where Sherpa traces are sent to, "10.0.1.1" by default |
    ...    |  up_port            |   the port where Sherpa traces are sent to, "5678" by default |
    ...    |  interface          |   the network interface where Sherpa traces are sent to, "eth3" by default |
    ...    |  option             |   options to be passed to tcpdump providing the path where Sherpa .pcap file is generated |
    ...    Example
    ...    |  @{cellList} =  Create List |  1            |
    ...    |  Start To Collect Sherpa Trace |  ${cellList}  |
    [Arguments]    ${nrcell_id_list}=${None}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=10.0.1.1
    ...            ${up_port}=5678
    ...            ${interface}=eth3
    ...            ${option}=port ${up_port}
    ...            ${L2PS}=${TRUE}     ${L2LO}=${TRUE}    ${L2Hi}=${TRUE}
    Start Sherpa Tcpdump on VM AIC     interface=${interface}           option=${option}        collectorAIC=l2stream3
    ${default_nrcell_id_list}          get slice from list              ${NRCELL_ID_LIST_DU}    end=1
    ${tmp_nrcell_id_list}              set variable if                  ${nrcell_id_list} is ${None}
    ...                                ${default_nrcell_id_list}        ${nrcell_id_list}

    ${cell_list}    create list
    FOR   ${cell_id}    IN     @{tmp_nrcell_id_list}
            ${cell_dn}         set variable    MRBTS-${MRBTS_ID_DU}/NRBTS-${NRBTS_ID_DU}/NRCELL-${cell_id}
            append to list     ${cell_list}    ${cell_dn}
    END
    ${dico_args}            _Setup Sherpa Dico  L2PS=${L2PS}    L2LO=${L2LO}    L2Hi=${L2Hi}    cell_dn_list=${cell_list}

    FOR  ${dico_arg}   IN   @{dico_args}
        ${sherpa_activ_trace_id}       _Start Sherpa Trace Via UPTrace AIC
        ...                                 dico_args=${dico_arg}               dscp=${dscp}
        ...                                 up_destIpAddr=${up_destIpAddr}      up_port=${up_port}
    END
    _Check components on VDU

_Setup Sherpa Dico
    [Documentation]         INTERNAL USAGE. Set up the lists to activate Sherpa traces on gnb using COAM gui.
    [Arguments]             ${cell_dn_list}   ${L2PS}=${TRUE}    ${L2LO}=${TRUE}    ${L2Hi}=${TRUE}
    @{curl_list}            Create List
    Set To Dictionary       ${curl_options}     nr_cell_dn_list=${cell_dn_list}     target_component="L2Ps"         trace_type="Sherpa"
    Set To Dictionary       ${curl_options2}    nr_cell_dn_list=${cell_dn_list}     target_component="L2Lo"         trace_type="Sherpa"
    Set To Dictionary       ${curl_options3}    nr_cell_dn_list=${cell_dn_list}     trace_type="Component"
    Set To Dictionary       ${curl_options4}    nr_cell_dn_list=${cell_dn_list}     target_component="L2Lo"         trace_type="Component"
    Set To Dictionary       ${curl_options5}    nr_cell_dn_list=${cell_dn_list}     target_component="L2HiPdcp"     trace_type="Sherpa"
    Set To Dictionary       ${curl_options6}    nr_cell_dn_list=${cell_dn_list}     target_component="L2HiRlc"      trace_type="Sherpa"

    Run Keyword If          '${L2PS}'=='${TRUE}'
    ...                         Append To List      ${curl_list}    ${curl_options}
    Run Keyword If          '${L2LO}'=='${TRUE}'
    ...                         Append To List      ${curl_list}    ${curl_options2}
    Run Keyword If          '${L2Hi}'=='${TRUE}' and not ${isAic}
    ...                         Append To List      ${curl_list}    ${curl_options5}    ${curl_options6}
    ...         ELSE IF     '${L2Hi}'=='${TRUE}' and ${isAic}
    ...                         Append To List      ${curl_list}    ${curl_options6}

    Set Suite Variable      ${curl_list}
    [Return]                @{curl_list}

_Start Sherpa Trace Via UPTrace AIC
    [Documentation]  INTERNAL USAGE
    ...    Start Sherpa trace using UPLANE trace on VDU
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |
    [Arguments]    ${dico_args}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=10.0.1.1
    ...            ${up_port}=5678

    _Update Sherpa UP Trace Configuration For vDU AIC   uplane_ip_addr=${up_destIpAddr}    uplane_port=${up_port}    dscp=${dscp}
    ${Sherpa_activ_trace_id}=    _Start Sherpa Uplane Trace For vDU AIC   dico_args=${dico_args}
    Set Suite Variable        ${Sherpa_activ_trace_id}
    Dated Log            Activated Sherpa trace Id is: ${Sherpa_activ_trace_id}
    [Return]     ${Sherpa_activ_trace_id}

_Update Sherpa UP Trace Configuration For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Update user plane configuration
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |
    [Arguments]   ${uplane_ip_addr}=10.0.1.1
    ...           ${uplane_port}=5678
    ...           ${dscp}=0
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    &{args}      Create Dictionary     uplane_ip_addr="${uplane_ip_addr}"
    ...                                uplane_port=${uplane_port_1}
    ...                                dscp=${dscp_1}
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=update_uplane_configuration
    ...                             cmd_args=${args}
    sleep    10s
    &{args}      Create Dictionary     operation_id="${res1}"

    #vbo#INVES#
    FOR    ${iteration}    IN RANGE    1    3
        ${res2}      OAM Run Command    oam=${GNB_DU.oam}
        ...                             cmd=get_trs_api_operation_status
        ...                             cmd_args=${args}
        Dated Log    ===> res2 of cmd=get_trs_api_operation_status= ${res2}
        Exit For Loop If    "${res2}" == "{\'status\': \'Successful\'}"
        Traced Sleep    duration=10s    msg=successful result for get_trs_api_operation_status
    END
    [Return]    ${res2}

_Start Sherpa Uplane Trace For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Start Uplane Sherpa stream inside GNB
    ...    |  target_component   |   the component who generates the traces, "L2Ps" by default |
    ...    |  nr_cell_dn_list    |   list of cells which are monitored, 1st cell in the configured cells list by default |
    ...    |  trace_type         |   "Component" by default |
    [Arguments]     ${dico_args}=dico_args
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=start_uplane_trace_stream
    ...                             cmd_args=${dico_args}
    Log To Console    ${res1}
    sleep    3s
    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_active_trace_streams
    Log To Console             Sherpa active_trace_streams: ${res2[0]['trace_id']}
    [Return]    ${res2[0]['trace_id']}

_Check components on VDU
    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_active_trace_streams
    Log To Console             _Check components on VDU
    Run Keyword if        "${res2[0]['status']}" == "Active" and "${res2[1]['status']}" == "Active" and "${res2[2]['status']}" == "Active"
    ...                 Dated Log             components on VDU are activated
    ...                 ELSE            FAIL

Start Sherpa Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Start tcpdump to capture Sherpa traces on the test line VM
    ...    |  interface     |   network interface where to capture the traces, "eth3" by default |
    ...    |  option        |   option to be used by tcpdump for capturing traces (output filename, ...) |
    ...    |  collectorAIC  |   string representing the name of the collector, "SherpatcpdumpAic" by default |
    [Arguments]     ${interface}=eth3
    ...             ${option}=port 5678
    ...             ${collectorAIC}=l2stream3
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${HOST_EPCSIM.sshConnection.addr}
    ...     user=${HOST_EPCSIM.sshConnection.username}
    ...     password=${HOST_EPCSIM.sshConnection.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collectorAIC}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    core.setup_collectors    names=${collectorAIC}
    core.start_collectors    names=${collectorAIC}
    core.set_suite_alias     ${collectorAIC}
    Set Suite Variable           ${collectorAIC}
    [Return]    ${collectorAIC}

Stop Sherpa Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Stop tcpdump on the test line VM
    ...    |  desired_storage_directory     |   path where to store Sherpa traces, test path by default |
    ...    |  desired_file_name             |   Sherpa trace filename, "Sherpatrace_streaming" by default |
    [Arguments]     ${desired_storage_directory}=${LOG_PATH}
    ...             ${desired_file_name}=Sherpatrace_streaming
    core.stop_collectors    names=${collectorAIC}
    core.collect_collectors    names=${collectorAIC}     target_dir=${LOG_PATH}
    core.teardown_collectors    names=${collectorAIC}
    Move Sherpa Trace File to Desired Directory AIC    desired_storage_directory=${desired_storage_directory}
    ...                                         desired_file_name=${desired_file_name}    collector=${collectorAIC}

Stop And Download Sherpa Trace On AIC
    [Documentation]
    ...    Stop tcpdump and Uplane streaming
    ...    |  desired_storage_directory     |   path where to store Sherpa traces, test path by default |
    ...    |  desired_file_name             |   Sherpa trace filename, "Sherpatrace_streaming" by default |
    [Arguments]          ${desired_storage_directory}=${LOG_PATH}
    ...                  ${desired_file_name}=Sherpatrace_streaming
    log to console             Stop L2PS Sherpa trace(uplane trace stream) in AIC
    ${res2}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=get_active_trace_streams
    # STOP
    &{args}      Create Dictionary     trace_id="${res2[0]['trace_id']}"
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=stop_uplane_trace_stream
    ...                             cmd_args=${args}
    Log To Console    stop trace is: "${res2[0]['trace_id']}"
    &{args}      Create Dictionary     trace_id="${res2[1]['trace_id']}"
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=stop_uplane_trace_stream
    ...                             cmd_args=${args}
    Log To Console    stop trace is: "${res2[1]['trace_id']}"
    &{args}      Create Dictionary     trace_id="${res2[2]['trace_id']}"
    ${res1}      OAM Run Command    oam=${GNB_DU.oam}
    ...                             cmd=stop_uplane_trace_stream
    ...                             cmd_args=${args}
    Log To Console    stop trace is: "${res2[2]['trace_id']}"
    Stop Sherpa Tcpdump on VM AIC      desired_storage_directory=${desired_storage_directory}
    ...                         desired_file_name=${desired_file_name}

Move Sherpa Trace File to Desired Directory AIC
    [Documentation]     [PRIVATE]
    [Arguments]     ${desired_storage_directory}      ${desired_file_name}        ${collector}


    ${LOG_PATH_Sherpa}              set variable        ${LOG_PATH}/l2stream3/tcpdump/
    Dated Log        Log_path_sherpa ${LOG_PATH_Sherpa}
    Dated Log        desired_storage_directory ${desired_storage_directory}
    Dated Log        log path ${LOG_PATH}
    Dated Log        desired_file_name: ${desired_file_name}

    run keyword if   '${desired_storage_directory}'=='${LOG_PATH}'
    ...                run    cd ${LOG_PATH};mkdir -p l2stream3/tcpdump/;

    ${desired_storage_directory}       set variable if   '${desired_storage_directory}'=='${LOG_PATH}'
    ...                 ${LOG_PATH_Sherpa}             ${desired_storage_directory}
    ${desired_file_name}       set variable if           '${desired_file_name}'=='Sherpatrace_streaming'
    ...                 tcpdump                        ${desired_file_name}

    Move file  ${LOG_PATH}/${collector}/l2stream3.pcap
    ...        ${desired_storage_directory}/${desired_file_name}.pcap
   #Remove Directory     ${LOG_PATH}/${collector}/  recursive=True
