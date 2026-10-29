*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Library           ../resources/python/CPRT_Capture.py
Resource         ../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/BBpooling_MuMIMO.robot
Library          ../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String
Library          ta_messaging


*** Variables ***
${PDU_session_resource_setup_without_ICS}   PDU SESSION ID-.* setup.*reestablishment complete
${LTE_Bearer_creation_success}      Bearer-.* .*EBI=.* \nQCI=.*.* created
${ENDC_Sgnb_modification}     Successfully reconfigured dual connectivi

*** Keywords ***
Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    8min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     180s    5s	Check MIB_SIB status of GNB cell   ${i}
    END
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    8min    20sec     Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    15min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready ASOH - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog
    CPRT Monitoring Start ASOH
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    set suite variable    ${LOG_PATH}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None     ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterName}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

UE Tirgger Intra-Freq Intra-GNB HO back and forth
    [Arguments]    ${ue}
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=518598    event_type=A3
    ${intra_freq_intra_DU_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_1}    pass_regexp=Intra-eNB handover
    ${measid_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=518598    event_type=A3
    ${intra_freq_intra_DU_2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_2} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_2}    pass_regexp=Intra-eNB handover

Validate DL UL Traffic For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${rate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}

Validate DL UL Throughput For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${dlrate}   ${ulrate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${dlrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${ulrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}


UE Register should be Successful Vonr
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register should be Success
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Trigger DL Traffic for SA Vonr
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for SA Vonr
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Trigger DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic SA
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'         ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}


UE Register with ICS should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration with ICS in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.amf_param   id=1   send_ics_registration=on
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> UE Registeration with ICS Success
    Print Matching Lines from Output File    ${output}    ${UE_register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    Verify Initial Context Response   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
    Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register with ICS+PDU should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration with ICS+PDU in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    sleep   5s
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    sleep   5s
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
    Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Verify Initial Context Response
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial Context Response  message in  UE Registration
    ...                in the output file for the SA variant
    Should Contain    ${output}    ${Initial_context_setup_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_context_setup_pattern}


Verify PDU Session resource setup response
    [Arguments]    ${output}    ${ue_id}     ${pdu_session_id}
    [Documentation]    This keyword checks the PDU Session resoruce setup response without ICS
    ...                in the output file for the SA variant
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     UE-${ue_id}.*\\n.*PDU SESSION ID-${pdu_session_id} setup/reestablishment complete

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Multiple NSA UE Register
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         LTE Attach should be Successful    ${ue_id}
         UE Attach should be Successful     ${ue_id}
    END

Multiple NSA UE start and validate DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate DL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE start and validate UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate UL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE Detach
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR   ${ue_id}   IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         UE Detach should be Successful    ${ue_id}
    END

Add new LTE Bearer
    [Arguments]    ${ue_id}   ${bearer_id}    ${precedence}
    wtsrunner.bearer_add    ue=${ue_id}   id=${bearer_id}  filter=0  precedence=${precedence}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_Bearer_creation_success}    ${10}
    Print Matching Lines from Output File    ${output}    ${LTE_Bearer_creation_success}
    Log to console    New LTE Bearer addition is Success

ENDC Modify for Bearer Addition
    [Arguments]    ${ue_id}   ${bearer_id}    ${cause}=RN_CauseRadioNetwork_unspecified
    wtsrunner.enb_ue_dc_modify   ue=${ue_id}   bearer_to_add=${bearer_id}   by=enb   cause=${cause}
    ${output}    Read WTS Output Until Pattern Matches    ${ENDC_Sgnb_modification}    ${10}
    Print Matching Lines from Output File    ${output}    ${ENDC_Sgnb_modification}
    Log to console    ENDC Modify for Bearer Addition Success

Wait for UE to go to INACTIVE state
    [Arguments]       ${inactivity_timer}
    Log to Console          Wait ${inactivity_timer}s for UE to move inactive state
    sleep   ${inactivity_timer}s
    sleep   30s       #add extra delta

Trigger RRC Re-establishment
    [Arguments]    ${ue_id}   ${cell_id}
    wtsrunner.ue_rrc_reestablish    id=${ue_id}     cell=${cell_id}
    sleep    2s

Validate SA_DU_DRB_NBR_DL Counter
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55139C03509
    Set Suite variable   ${PM_dir1}
    ${M55139C03509}    Check PM counter value   ${PM_dir1}    PM_counter=M55139C03509
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir1}
    ...  pi_id=M55139C03509   moc=NRCELL-1

Collect and Store PM Counter Files
    Log to Console     Collecting PM Files
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    [Return]    ${PM_dir1}

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}


IntragNB Intercell HO SA A5 UE measurements
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=2 event=A5 srsrp_nr=19 phycell_id=50 nrsrp_nr=100 phycell_id=51
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}


Trigger High DL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}    ${bearer_id}
    [Documentation]    This keyword starts the DL Traffic for the SA variant for higher data rate
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//165
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%165
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
        Run Keyword if    ${loop}==0    Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=${dl_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${ul_rate}      ${bearer_id}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//165
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%165
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Multiple NSA UE start DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
    END

Multiple NSA UE start UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${ul_rate}
    END

Validate DL UL Throughput For NSA UE
    [Arguments]    ${UE_ID}   ${bearer_id}    ${dlrate}   ${ulrate}
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=${dlrate}   id=${bearer_id}
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=${ulrate}   id=${bearer_id}

Send A1 Measurement for Scell Addition
    [Arguments]    ${ue_id}   ${meas_id}    ${srsrp_nr}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr   id=${ue_id}    meas_id=${meas_id}   event=A1  srsrp_nr=${srsrp_nr}   phycell_id=${phycell_id}

Trigger High DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
            Run Keyword if    ${loop}==0       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=${dl_rate_reminder}   ack_mode=off  cl_trf_stats=on
            Run Keyword if    ${loop}>0        wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=175   ack_mode=off  cl_trf_stats=on
            ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger High UL Traffic SA
    [Arguments]    ${ue_id}      ${ul_data}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the \UL Traffic for the SA variant
    ${TRF_ID}=   Set Variable   1
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul   trf_id=${TRF_ID}   protocol=udp    mbps=${ul_data}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Verify DRXcycle not present in F1AP_UEContextSetupRequest
    [Arguments]   ${drx_path}   ${crnti}
    [Documentation]      This KW Verifies the DRXCycle IE Not present in F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_path}[cprt]/NODECPRT_GNB.pcap   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_path}[cprt]/NODECPRT_GNB.pcap
                     ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ue_id}) && (f1ap.procedureCode == 5)
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                                                path=f1ap.longDRXCycleLength
    Run Keyword and continue on Failure     should be true  ${path_count} == 0
    #analyzer.check_field            pdmlFile=${pdmlFile}
    #...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    #...                             fieldName=f1ap.longDRXCycleLength
    #...                             kind=showname
    #...                             value=longDRXCycleLength: ms10 (0)

Get gnb CU UEID from CRNTI
    [Arguments]      ${logpath}       ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       (3gpp.rnti == ${crnti}) && (itf_l2_ps_user_bearersetupreq)
    ${cu_ue_id}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearersetupreq
    ...                                                path=.*ueIdCu$
    ...                                                endPacket=${1}
    [Return]   ${cu_ue_id}

Verify DRXcycle in F1AP_UEContextSetupRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ue_id}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)

Verify DRXrelease in F1AP_UEContextModificationRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXrelease IE in F1AP_UEContextModificationRequest
    Log to console       Checking DRXRelease IE in F1AP_UEContextModificationRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   ((f1ap.procedureCode == 7) && (f1ap.GNB_CU_UE_F1AP_ID == ${gnb_cu_ue_id}) && (f1ap.DRXConfigurationIndicator == 0))
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.DRXConfigurationIndicator
    ...                             kind=showname
    ...                             value=DRXConfigurationIndicator: release (0)

Verify DRXcycle in F1AP_UEContextModificationRequest
    [Arguments]   ${drx_cprt_pcap}   ${crnti}   ${longDRXCycleLength}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextModificationRequest
    log to console       Checking DRXCycle IE In F1AP_UEContextModificationRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   ((f1ap.procedureCode == 7) && (f1ap.GNB_CU_UE_F1AP_ID == ${gnb_cu_ue_id}))
       analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=${longDRXCycleLength}
