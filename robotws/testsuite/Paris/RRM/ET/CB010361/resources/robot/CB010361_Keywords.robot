*** Settings ***
Documentation     [SUITE PURPOSE]  Common keyword of CB010361 feature
...               PCMD additional radio resource usage and quality of service metrics
...               Prerequisite : gNB configured in T+F - UL and DL MU MIMO - UL and DL CA
...               Scope : 10361-A
...
...               Version History    Date           Authors                                   Notes
...               0.1               01-10-2024      martial.hummel@nokia.com                Creation
...               0.1               01-10-2024      marie-laurence.le_borgne@nokia.com      Creation

# Libraries
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ta5g_testline_management
Library           ute_wtssim                    WITH NAME    wts
Library           taf.wts.runner                WITH NAME    wtsemu
Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Library           ../../../../../resources/SWENG/python/PandasCsv.py
Library           ../../../resources/python/luashark_tools.py
Library           ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter


Library           ta_pcmd
Library           ta_pcmd.tshark_plugin_configurator
Library           ta5g_tshark


# Resources
Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../../resources/SWENG/robot/WtsXmlConfig.robot


Variables         ../../../../../resources/SWENG/python/Colors.py



*** Variables ***
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
${BSR_git_folder}       BSR
${BSR_git_file_name}    BSR_AEQE_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001.zip

@{ntrstrFilter}=        ntrstr.syncpattern == 0xd0b0061e && nsetapx.DuVendorExtensionRecordDataType == 4

${nbr_timeOfUeSchedMimo}                 0
${nbr_sumOfMacPduTxTime}                 0
${nbr_sumOfInitTxTime}                   0
${nbr_numOfInitTxSamples}                0
${nbr_sumOfMacPduRxTime}                 0
${nbr_sumOfInitRxTime}                   0
${nbr_numOfInitRxSamples}                0
${nbr_sumOfOverAirDelay}                0
${status_nbr_timeOfUeSchedMimo}       ${False}
${status_nbr_sumOfMacPduTxTime}       ${False}
${status_nbr_sumOfInitTxTime}         ${False}
${status_nbr_numOfInitTxSamples}      ${False}
${status_nbr_sumOfMacPduRxTime}       ${False}
${status_nbr_sumOfInitRxTime}         ${False}
${status_nbr_numOfInitRxSamples}      ${False}
${status_nbr_sumOfOverAirDelay}       ${False}

*** Keywords ***

#####################################################################
########################  Configuration KWs  ########################
#####################################################################
Suite Setup for CB010361
    [Documentation]     Setup TL with initial KDDI SCF

    Run Keyword         dated log       =====>CB010361 Update Configuration files >> SCF - Basic setup - iphy
    sleep    30s
    #TO BE INSERTED FOR DEBUG PURPOSE (to avoid full commissioning and BSR)
    #Setup.Suite Setup From Scratch      ${FD_ALL}      keepAllUeDataInCfgFile=${True}
    #...                  automaticTeardown=${False}

    #IF ABOVE 2 LINES are INSERTED COMMENT THE FOLLOWING CUSTOM CONFIG AND BSR
    Run Keyword         Suite Setup From Scratch        ${FD_ALL}      keepAllUeDataInCfgFile=${True}
    ...                 scfcPathname=${CURDIR}/../../config/custom/scf_CB010361_ULDLCA_ULDLMIMO.xml
    ...                 basicPathname=${CURDIR}/../../config/custom/basic_setup_5cells_CB010361_TDD_FDD.cfg
    ...                 iphyPathname=${CURDIR}/../../config/custom/iphy_5cells_CB010361_ULMIMO.xml
    sleep    120s
     Run Keyword         dated log       =====>CB010361 Update BSR for UL MIMO
     Run Keyword         CB010361 Load BSR file
     sleep    120s


########################## BSR UPDATE#######################
CB010361 Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position

    Dated Log New Line     ===> Download BSR file ${BSR_git_file_name}
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${BSR_git_folder}
    ...                                 git_file_name=${BSR_git_file_name}
    ...                                 target_dir=${LOG_PATH}


##############################UPDATE SCF WITH PCMD JSON
CB010361 Set SCF PCMD Params
    [Documentation]        Dedicated KW to use a delta commissioning file
    [Arguments]                   ${deltaScf}         ${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING STARTED * * * *
    coam.connect_to               name=${gnb_alias}
    Dated Log New Line            delta_file=${deltaScf}
    coam_parameter.perform_scf_delta_commission    delta_file=${deltaScf}    connection=${gnb_alias}
    OAM wait available
    coam.teardown                 connection=${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING FINISHED * * * *
    Dated Log New Line            * * * * TL RESTART TRIGGERED * * * *
    Restart TL


##################################################################################
######################################PCMD configuration for capture
##################################################################################
Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD


Configure PCMD in Wireshark
    Add Preferences To Wireshark Config
    Start Server Interface


Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49148" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Dated Log    File '~/.config/wireshark/preferences' contains the required flags for PCMD


Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49148
    [Return]    ${preferences_exist}


Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24


Start Netcat for tracing
    Log to console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}


Stop Netact for tracing
    Log to console    Netcat stopped
    Terminate Process  ${NC_PROC}


Start pcmd report Pcap
    Start tshark
    ...    log_filename=eth3_pcmd_report.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${logsDir}/tshark
    ...    alias=pcmd_report_pcap


Stop pcmd report Pcap
    [Arguments]    ${alias}=pcmd_report_pcap
    Stop tshark    alias=${alias}

##############################PCMD Verification

Verify PCMD Trace Records Pcell timeOfUeSchedMimo
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_timeOfUeSchedMimo_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_timeOfUeSchedMimo.pdml
    ...     element_xpath=.//field[@name="nsetapx.timeOfUeSchedMimo"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_timeOfUeSchedMimo_NSETAPX @{List_timeOfUeSchedMimo_NSETAPX}
    ${result}      Set Variable      ${nbr_timeOfUeSchedMimo}

    FOR     ${List_timeOfUeSchedMimo_NSETAPX}     IN     @{List_timeOfUeSchedMimo_NSETAPX}
            #Dated Log New Line      ===> timeOfUeSchedMimo ${List_timeOfUeSchedMimo_NSETAPX}
            Run Keyword If      ${List_timeOfUeSchedMimo_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_timeOfUeSchedMimo ${result}
    END

    ${nbr_timeOfUeSchedMimo}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_timeOfUeSchedMimo=${nbr_timeOfUeSchedMimo}
    ${status_nbr_timeOfUeSchedMimo}=        Run Keyword If    ${nbr_timeOfUeSchedMimo} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_timeOfUeSchedMimo=${status_nbr_timeOfUeSchedMimo}
    [Return]            ${status_nbr_timeOfUeSchedMimo}


Verify PCMD Trace Records Pcell sumOfMacPduTxTime
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_sumOfMacPduTxTime_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_sumOfMacPduTxTime.pdml
    ...     element_xpath=.//field[@name="nsetapx.sumOfMacPduTxTime"]
    ...     attribute_xpath=.
    ...     attribute=value
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_sumOfMacPduTxTime_NSETAPX @{List_sumOfMacPduTxTime_NSETAPX}
    ${result}      Set Variable      ${nbr_sumOfMacPduTxTime}

    FOR     ${List_sumOfMacPduTxTime_NSETAPX}     IN     @{List_sumOfMacPduTxTime_NSETAPX}
            #Dated Log New Line      ===> sumOfMacPduTxTime hex ${List_sumOfMacPduTxTime_NSETAPX}
            ${List_sumOfMacPduTxTime_NSETAPX}=     Convert To Integer     item=${List_sumOfMacPduTxTime_NSETAPX}    base=16
            #Dated Log New Line      ===> sumOfMacPduTxTime dec ${List_sumOfMacPduTxTime_NSETAPX}
            Run Keyword If      ${List_sumOfMacPduTxTime_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_sumOfMacPduTxTime ${nbr_sumOfMacPduTxTime}
    END

    ${nbr_sumOfMacPduTxTime}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_sumOfMacPduTxTime=${nbr_sumOfMacPduTxTime}
    ${status_nbr_sumOfMacPduTxTime}=        Run Keyword If    ${nbr_sumOfMacPduTxTime} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_sumOfMacPduTxTime=${status_nbr_sumOfMacPduTxTime}
    [Return]            ${status_nbr_sumOfMacPduTxTime}


Verify PCMD Trace Records Pcell sumOfInitTxTime
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_sumOfInitTxTime_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_sumOfInitTxTime.pdml
    ...     element_xpath=.//field[@name="nsetapx.sumOfInitTxTime"]
    ...     attribute_xpath=.
    ...     attribute=value
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_sumOfInitTxTime_NSETAPX @{List_sumOfInitTxTime_NSETAPX}
    ${result}      Set Variable      ${nbr_sumOfInitTxTime}

    FOR     ${List_sumOfInitTxTime_NSETAPX}     IN     @{List_sumOfInitTxTime_NSETAPX}
            #Dated Log New Line      ===> sumOfInitTxTime hex ${List_sumOfInitTxTime_NSETAPX}
            ${List_sumOfInitTxTime_NSETAPX}=     Convert To Integer     item=${List_sumOfInitTxTime_NSETAPX}    base=16
            #Dated Log New Line      ===> sumOfInitTxTime dec ${List_sumOfInitTxTime_NSETAPX}
            Run Keyword If      ${List_sumOfInitTxTime_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_sumOfInitTxTime ${nbr_sumOfInitTxTime}
    END
    ${nbr_sumOfInitTxTime}     Set Variable       ${result}

    Dated Log New Line      ===> nbr_sumOfInitTxTime=${nbr_sumOfInitTxTime}
    ${status_nbr_sumOfInitTxTime}=        Run Keyword If    ${nbr_sumOfInitTxTime} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_sumOfInitTxTime=${status_nbr_sumOfInitTxTime}
    [Return]            ${status_nbr_sumOfInitTxTime}


Verify PCMD Trace Records Pcell numOfInitTxSamples
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_numOfInitTxSamples_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_numOfInitTxSamples.pdml
    ...     element_xpath=.//field[@name="nsetapx.numOfInitTxSamples"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_numOfInitTxSamples_NSETAPX @{List_numOfInitTxSamples_NSETAPX}
    ${result}      Set Variable      ${nbr_numOfInitTxSamples}

    FOR     ${List_numOfInitTxSamples_NSETAPX}     IN     @{List_numOfInitTxSamples_NSETAPX}
            #Dated Log New Line      ===> numOfInitTxSamples ${List_numOfInitTxSamples_NSETAPX}
            Run Keyword If      ${List_numOfInitTxSamples_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_numOfInitTxSamples ${nbr_numOfInitTxSamples}
    END

    ${nbr_numOfInitTxSamples}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_numOfInitTxSamples=${nbr_numOfInitTxSamples}
    ${status_nbr_numOfInitTxSamples}=        Run Keyword If    ${nbr_numOfInitTxSamples} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_numOfInitTxSamples=${status_nbr_numOfInitTxSamples}
    [Return]            ${status_nbr_numOfInitTxSamples}


Verify PCMD Trace Records Pcell sumOfMacPduRxTime
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_sumOfMacPduRxTime_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_sumOfMacPduRxTime.pdml
    ...     element_xpath=.//field[@name="nsetapx.sumOfMacPduRxTime"]
    ...     attribute_xpath=.
    ...     attribute=value
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_sumOfMacPduRxTime_NSETAPX @{List_sumOfMacPduRxTime_NSETAPX}
    ${result}      Set Variable      ${nbr_sumOfMacPduRxTime}

    FOR     ${List_sumOfMacPduRxTime_NSETAPX}     IN     @{List_sumOfMacPduRxTime_NSETAPX}
            #Dated Log New Line      ===> sumOfMacPduRxTime hex ${List_sumOfMacPduRxTime_NSETAPX}
            ${List_sumOfMacPduRxTime_NSETAPX}=     Convert To Integer     item=${List_sumOfMacPduRxTime_NSETAPX}    base=16
            #Dated Log New Line      ===> sumOfMacPduRxTime dec ${List_sumOfMacPduRxTime_NSETAPX}
            Run Keyword If      ${List_sumOfMacPduRxTime_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_sumOfMacPduRxTime ${nbr_sumOfMacPduRxTime}
    END

    ${nbr_sumOfMacPduRxTime}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_sumOfMacPduRxTime=${nbr_sumOfMacPduRxTime}
    ${status_nbr_sumOfMacPduRxTime}=        Run Keyword If    ${nbr_sumOfMacPduRxTime} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_sumOfMacPduRxTime=${status_nbr_sumOfMacPduRxTime}
    [Return]            ${status_nbr_sumOfMacPduRxTime}


Verify PCMD Trace Records Pcell sumOfInitRxTime
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_sumOfInitRxTime_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_sumOfInitRxTime.pdml
    ...     element_xpath=.//field[@name="nsetapx.sumOfInitRxTime"]
    ...     attribute_xpath=.
    ...     attribute=value
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_sumOfInitRxTime_NSETAPX @{List_sumOfInitRxTime_NSETAPX}
    ${result}      Set Variable      ${nbr_sumOfInitRxTime}

    FOR     ${List_sumOfInitRxTime_NSETAPX}     IN     @{List_sumOfInitRxTime_NSETAPX}
            #Dated Log New Line      ===> sumOfInitRxTime hex ${List_sumOfInitRxTime_NSETAPX}
            ${List_sumOfInitRxTime_NSETAPX}=     Convert To Integer     item=${List_sumOfInitRxTime_NSETAPX}    base=16
            #Dated Log New Line      ===> sumOfInitRxTime dec ${List_sumOfInitRxTime_NSETAPX}
            Run Keyword If      ${List_sumOfInitRxTime_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_sumOfInitRxTime ${nbr_sumOfInitRxTime}
    END
    ${nbr_sumOfInitRxTime}     Set Variable       ${result}

    Dated Log New Line      ===> nbr_sumOfInitRxTime=${nbr_sumOfInitRxTime}
    ${status_nbr_sumOfInitRxTime}=        Run Keyword If    ${nbr_sumOfInitRxTime} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_sumOfInitRxTime=${status_nbr_sumOfInitRxTime}
    [Return]            ${status_nbr_sumOfInitRxTime}


Verify PCMD Trace Records Pcell numOfInitRxSamples
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_numOfInitRxSamples_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_numOfInitRxSamples.pdml
    ...     element_xpath=.//field[@name="nsetapx.numOfInitRxSamples"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_numOfInitRxSamples_NSETAPX @{List_numOfInitRxSamples_NSETAPX}
    ${result}      Set Variable      ${nbr_numOfInitRxSamples}

    FOR     ${List_numOfInitRxSamples_NSETAPX}     IN     @{List_numOfInitRxSamples_NSETAPX}
            #Dated Log New Line      ===> numOfInitRxSamples ${List_numOfInitRxSamples_NSETAPX}
            Run Keyword If      ${List_numOfInitRxSamples_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_numOfInitRxSamples ${nbr_numOfInitRxSamples}
    END

    ${nbr_numOfInitRxSamples}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_numOfInitRxSamples=${nbr_numOfInitRxSamples}
    ${status_nbr_numOfInitRxSamples}=        Run Keyword If    ${nbr_numOfInitRxSamples} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_numOfInitRxSamples=${status_nbr_numOfInitRxSamples}
    [Return]            ${status_nbr_numOfInitRxSamples}


Verify PCMD Trace Records Pcell sumOfOverAirDelay
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=pcmd_report_pcap    ${continue_on_failure}=${True}

    @{List_sumOfOverAirDelay_NSETAPX}=       Get Attribute Values From Tshark Messages
    ...     alias=${alias}
    ...     filter=${packet_filter}
    ...     output_pdml_filepath=${logsDir}/tshark/pdml_sumOfOverAirDelay.pdml
    ...     element_xpath=.//field[@name="nsetapx.sumOfOverAirDelay"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${logsDir}/tshark/eth3_pcmd_report.pcap
    Dated Log New Line      ===> List_sumOfOverAirDelay_NSETAPX @{List_sumOfOverAirDelay_NSETAPX}
    ${result}      Set Variable      ${nbr_sumOfOverAirDelay}

    FOR     ${List_sumOfOverAirDelay_NSETAPX}     IN     @{List_sumOfOverAirDelay_NSETAPX}
            #Dated Log New Line      ===> sumOfOverAirDelay ${List_sumOfOverAirDelay_NSETAPX}
            Run Keyword If      ${List_sumOfOverAirDelay_NSETAPX} > 0
            ...                 Increment Result          result=${result}
            #Dated Log New Line      ===> nbr_sumOfOverAirDelay ${nbr_sumOfOverAirDelay}
    END

    ${nbr_sumOfOverAirDelay}      Set Variable      ${result}

    Dated Log New Line      ===> nbr_sumOfOverAirDelay=${nbr_sumOfOverAirDelay}
    ${status_nbr_sumOfOverAirDelay}=        Run Keyword If    ${nbr_sumOfOverAirDelay} > 0
    ...     Set Variable    ${True}    ELSE    Set Variable    ${False}
    Dated Log New Line      ===> status_nbr_sumOfOverAirDelay=${status_nbr_sumOfOverAirDelay}
    [Return]            ${status_nbr_sumOfOverAirDelay}


Increment Result
    [Arguments]    ${result}
    ${result}=    Evaluate    ${result}+1
    Set Global Variable            ${result}
    #Dated log      result:${result}


#################################################################
############################ Complementary traces
################################################################

Get TTI Logs

    # TTI capture configuration
    ${TTIdir}                             Get TTI Trace Path    dir_suffix=TTI

    # Start TTI capture
    Dated Log New Line                    Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep                5         msg=DL TTI traffic capture 5 seconds

    # Stop TTI capture
    Dated Log New Line                    Stop TTI traces capture
    ${TTIpcap}                            Stop TTI Traces in Streaming mode
    ...                                   tti_trace_path=${TTIdir}
    ...                                   tti_trace_filename=TTI_TC10361

    Dated Log New Line                    Convert TTItrace to json and csv
    ${TTIjson}                            Convert TTItrace from pcap to others
    ...                                   input_file_path=${TTIpcap}
    ${TTIcsv}                             ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec
    ...                                   jsonPathName=${TTIjson}     num_of_events=10000


Get Snaphot Sos Report

    Dated log                       Get Snapshot
  # Get Sos Report
    Get Snapshot
##################################################################################
######################################Setup/Teardown KWs
##################################################################################

CB010361 Test Setup
    [Documentation]             Perform needed actions at the begining of a test case
    Init Trace color


CB010361 Test Teardown
    [Documentation]             Perform needed actions at the end of a test case
    Restore Files               listFileDesc=${FD_ALL}

    # "Test Teardown" KW from Setup.robot
    Test Teardown


Init Trace color
    ${trcColor}                 Evaluate    "${CYAN}"
    ${defColor}                 Evaluate    "${NORMAL}"
    ${OkColor}                  Evaluate    "${GREEN}"
    Set Suite Variable          ${trcColor}
    Set Suite Variable          ${defColor}
    Set Suite Variable          ${OkColor}
