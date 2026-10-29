*** Settings ***
Documentation    ...    :copyright: Nokia

Library    String
Library    Collections
Library    OperatingSystem
Library    ute_wtssim
Library    ./utility_functions.py    WITH NAME    utility
Library    taf.ccs.aashell    WITH NAME    cli
Library    ta5g_ue_mobility
Library    ta5g_throughput
Library    ta5g_cell_operations
Library    ta5g_enb
Library    ta5g_ue_measurements
Library    ta5g_testline_management
Library    ta5g_bearers
Library    ta5g_pm_counters   WITH NAME    counters
Library    taf.ul.vdu.helm    WITH NAME    helm
Library    taf.gnb.oam.coam.cu    WITH NAME    vcu
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.airphone.CB012584.resources.hook.Hook    WITH NAME    hook
Resource   testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Resource   ./variables.robot

*** Keywords ***
Change Multiple R&D Flags
    [Documentation]    Setup multiple R&D flags with the provided details.
    [Arguments]    ${name}    ${port}    ${namespace}    ${pod}    ${flags}    ${hops}=${HOPS_OCP_VDU}
    cli.Create Aashell Cli     name=${name}    port=${port}    namespace=${namespace}
    ...                        pod=${pod}      hops=${hops}
    cli.Setup                  alias=default
    cli.Change Rad Params      name=default    params=${flags}    is_permanent=True
    Log To Console    Change of R&D flags successfully performed.
    [Teardown]    cli.Teardown                 alias=default

Setup R&D Flags
    [Documentation]    This keyword sets necessary R&D flags.
    [Arguments]    ${name}    ${port}    ${flags}    ${pod}    ${hops}=${HOPS_OCP_VDU}
    Log To Console    Changing flags to values: ${flags}
    Change Multiple R&D Flags    ${name}    ${port}    ${NAMESPACE}    ${pod}    ${flags}    ${hops}

Create List With R&D Flags
    [Arguments]    @{flags}
    ${flags_list}=    Create List    @{flags}
    Set Suite Variable    ${flags_list}

Register ${ue_id} UEs To Cell ${cell_id}
    [Documentation]    Register certain ammount of UEs to the 5G core network.
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}

Deregister ${ue_id_start} To ${ue_id_end} UEs
    [Documentation]    Deregister certain ammount of UEs from the 5G core network.
    Deregister Ue    ue_id=${ue_id_start}-${ue_id_end}

Get number of RRC Rejects in pcap file
    [Arguments]    ${pcap}    ${alias}=${DEFAULT_UU_TSHARK_ALIAS}
    ${pcap_file_path}=    Catenate    SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${pcap}
    ${num_of_rejects}=    Get packets count for Tshark    packet_filter=${RRC_REJECT}    source_ip=0.0.0.0/0
    ...    alias=${alias}    pcap_file_path=${pcap_file_path}
    [Return]    ${num_of_rejects}

Check If RRCReject Is Not Visible
    [Arguments]    ${pcap_file_path}=default    ${alias}=${DEFAULT_TCPDUMP_ALIAS}
    Log To Console    Checking if RRCReject are not present
    IF    "${pcap_file_path}" != "default"
        ${pcap_file_path}=    Catenate    SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${pcap_file_path}
    END
    Verify Tcpdump Log    packet_filter=${RRC_REJECT}    number_of_messages=0    pcap_file_path=${pcap_file_path}    alias=${alias}

Verify Count of RRC Rejects
    [Arguments]    ${count}    ${packet_filter}=${RRC_REJECT}    ${log_filename}=${None}    ${alias}=${DEFAULT_UU_TSHARK_ALIAS}
    ...    ${timeout}=16
    IF    ${{$log_filename is not None}}
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    ELSE
        ${pcap_file_path}=    Set Variable    ${log_filename}
    END
    Verify Uu Messages    packet_filter=${packet_filter}    number_of_messages=${count}    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}    alias=${alias}

Verify successful SgNBAddition
    [Arguments]    ${count}=1    ${log_filename}=default    ${alias}=${DEFAULT_TCPDUMP_ALIAS}
    IF    "${log_filename}" != "default"
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    ELSE
        ${pcap_file_path}=    Set Variable    ${log_filename}
    END
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
    ...    number_of_messages=${count}    pcap_file_path=${pcap_file_path}    alias=${alias}

Verify SgNBAdditionRequestReject count
    [Arguments]    ${count}    ${log_filename}=default    ${alias}=${DEFAULT_TCPDUMP_ALIAS}
    IF    "${log_filename}" != "default"
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    ELSE
        ${pcap_file_path}=    Set Variable    ${log_filename}
    END
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_ADDITION_REJECT}
    ...    number_of_messages=${count}    pcap_file_path=${pcap_file_path}    alias=${alias}

Verify NG Handover Failure
    [Arguments]    ${count}=1    ${log_filename}=${None}    ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}
    IF    ${{$log_filename is not None}}
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    ELSE
        ${pcap_file_path}=    Set Variable    ${log_filename}
    END
    Verify Ngap Messages    packet_filter=${NGAP_HANDOVER_FAILURE_OVERLOAD}    number_of_messages=${count}
    ...    pcap_file_path=${pcap_file_path}    alias=${alias}

Verify successful NG handover
    [Arguments]    ${count}=1    ${log_filename}=${None}    ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}
    IF    ${{$log_filename is not None}}
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    ELSE
        ${pcap_file_path}=    Set Variable    ${log_filename}
    END
    Verify Ngap Messages    packet_filter=${NGAP_HANDOVER_NOTIFY}    number_of_messages=${count}
    ...    pcap_file_path=${pcap_file_path}    alias=${alias}

Verify current cell for UE
    [Arguments]    ${ue_id}=1    ${cell}=1    ${enb}=2
    Execute egate command    cmd=ue_disp id=${ue_id} type=cell    pass_regexp=enb.*?${enb}\[\\s\\S]+cell.*?${cell}

Perform NG handover and verify if it is successful
    [Arguments]    ${ue_id}=1    ${phycell_id}=50    ${log_filename}=ngap.pcap    ${alias}=pcap_ngap
    Start Tshark    log_filename=${log_filename}    eth_interface=eth7    capture_filter=sctp    alias=${alias}
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Perform UE handover    ue_id=${ue_id}    tgt_phycell_id=${phycell_id}
    Verify successful NG handover    log_filename=${log_filename}    alias=${alias}
    Stop Tshark    alias=${alias}

Perform EN-DC for UE with bearer addition and verify result
    [Arguments]    ${result}=success    ${ue_id}=808    ${target_gnb}=2    ${target_cells}=1    ${log_filename}=x2ap.pcap
    ...    ${alias}=pcap_x2ap
    IF    '${result}' == 'success'
        ${filter}=    Set Variable    ${X2AP_SGNB_MODIFICATION_CONFIRM}
    ELSE
        ${filter}=    Set Variable    ${X2AP_MODIFICATION_REJECT_OVL}
    END
    Start Tshark    log_filename=${log_filename}    eth_interface=eth3    alias=${alias}    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}    bearer=2
    ...    dc_type=split_scg
    Verify successful SgNBAddition    log_filename=${log_filename}    alias=${alias}
    Add bearer    ue_id=${ue_id}    bearer_id=3    pass_regexp=UE${ue_id}:.*?Bearer.3.*?created
    ...    filter=0    precedence=0
    Sleep    1
    Execute egate command    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=MISC_CauseMisc_unspecified
    Verify Ngap Messages    packet_filter=${filter}    alias=${alias}
    Detach UE    ue_id=${ue_id}
    Stop Tshark    alias=${alias}

Perform EN-DC for UE with intra-LTE HO and verify result
    [Arguments]    ${result}=success    ${ue_id}=808    ${endc_gnb}=2    ${endc_cells}=1    ${destination_lte_cell}=2
    ...    ${log_filename}=x2ap.pcap    ${alias}=pcap_x2ap
    IF    '${result}' == 'success'
        ${filter}=    Set Variable    ${X2AP_SGNB_MODIFICATION_CONFIRM}
    ELSE
        ${filter}=    Set Variable    ${X2AP_MODIFICATION_REJECT_OVL}
    END
    Start Tshark    log_filename=${log_filename}    eth_interface=eth3    alias=${alias}    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${endc_gnb}    target_cells=${endc_cells}    bearer=2    dc_type=split_scg
    Verify successful SgNBAddition    log_filename=${log_filename}    alias=${alias}
    Sleep    2
    IntraENB handover    ue_id=${ue_id}    dst_cell=${destination_lte_cell}
    Verify Ngap Messages    packet_filter=${filter}    alias=${alias}
    Detach UE    ue_id=${ue_id}
    Stop Tshark    alias=${alias}

Perform EN-DC for UE and verify result
    [Arguments]    ${result}=success    ${ue_id}=808    ${endc_gnb}=2    ${endc_cells}=1
    ...    ${log_filename}=x2ap.pcap    ${alias}=pcap_x2ap
    Start Tshark    log_filename=${log_filename}    eth_interface=eth3    capture_filter=sctp    alias=${alias}
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${endc_gnb}    target_cells=${endc_cells}    bearer=2    dc_type=split_scg
    IF    '${result}' == 'success'
        Verify successful SgNBAddition    log_filename=${log_filename}    alias=${alias}
    ELSE
        Verify SgNBAdditionRequestReject count    count=1    log_filename=${log_filename}    alias=${alias}
    END
    Detach UE    ue_id=${ue_id}
    Stop Tshark    alias=${alias}

Establish PDU session and verify it is rejected
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${log_filename}=ngap.pcap    ${alias}=pcap_ngap
    ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${log_filename}
    Start Tshark    log_filename=${log_filename}    eth_interface=eth7    capture_filter=sctp    alias=${alias}
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Establish PDU session without confirmation    ue_id=${ue_id}    pdu_id=${pdu_id}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${NGAP_PDU_SESSION_RESOURCE_REJECT_OVL}
    ...    pass_criteria= ==1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=16
    ...    continue_on_failure=${True}
    Stop Tshark    alias=${alias}

Check If ${number} Registrations Of Ues Occured
    Verify Tcpdump Log    packet_filter=${INITIAL_CONTEXT_SETUP}    number_of_messages=${number}

Register ${number} Ues And Check If ${ues_reg} Are Registered And ${ues_rej} Are Rejected
    ${capture_file}=        Set Variable  ${TEST_NAME}_UE${number}_register
    ta5g_tshark.Start Tshark            eth_interface=eth7  log_filename=${capture_file}.pcap
    ...                     alias=NGAP          capture_filter=${DEFAULT_S1_MME_SCTP}
    Run Keyword And Continue On Failure    Register ${number} UEs
    Check If ${ues_reg} Registrations Of Ues Occured
    Check If ${ues_rej} Registration Of UEs Are Rejected

Get Current Plan Of Vdu
    ${current_scf_plan_file}=    Get Vdu Current Plan File
    ...    vdu_path=${CURDIR}/../../configs/xml
    Set Suite Variable    ${current_scf_plan_file}

Check Availability Of Rmods
    ${vdu_rmods_online}=    Get Vdu Rmods Status
    Should Be True    ${vdu_rmods_online}

Perform Commissioning And Check Availability Of Rmods
    [Arguments]    ${scf_vcu}    ${scf_vdu}    ${vdu_number}
    ta5g_commissioning.Perform Commissioning Vcu Aic      path_to_plan_file=${scf_vcu}
    ta5g_commissioning.Send Full Commissioning Vdu Aic    input_filepath=${scf_vdu}    vdu=${vdu_number}
    Check Availability Of Rmods

Check Counters
    [Arguments]    ${counters}    ${amount}    ${local_moid}
    ${pm_counter_file}=    counters.Get Latest Unpacked Full PM Counters File Aic
    FOR    ${counter_name}    IN    &{counters}.keys()
        ${counter_id}=    Get From Dictionary    &{counters}    ${counter_name}
        counters.Verify Any Counters In File
        ...    ${counter_id}    ${amount}    ${counter_name}
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}
    END

Commission Overload Parameters On vDU
    [Arguments]    &{ovl_params}
    FOR    ${key}  ${value}    IN    &{ovl_params}
        Log To Console    \nCommissioning ${key} with value ${value}
        ta5g_commissioning.Perform Parameter Commissioning Vdu Aic
        ...        parameter=${key}    value=${value}    dist_name=MRBTS-1/NRBTS-1
    END

Commission Overload Parameters On vCU
    [Arguments]    &{ovl_params}
    FOR    ${key}  ${value}    IN    &{ovl_params}
        Log To Console    \nCommissioning ${key} with value ${value}
        ta5g_commissioning.Perform Parameter Commissioning Aic
        ...        parameter=${key}    value=${value}    dist_name=MRBTS-1/NRBTS-1
    END


Trigger Dual Connectivity For NSA UE ${ue_number} To Cell ${cell_number}
    [Documentation]    Cell number 1 and 3 are deployed on vDU1 and cell 2 and 4 are deployed on vDU2.
    Attach Ue To Enb    ue_id=${ue_number}
    Start Gnb Addition Procedure    ue=${ue_number}    target_gnb=2    target_cells=${cell_number}
    ...    bearer=2    dc_type=split_scg    pass_regexp=UE${ue_number}: Sending SgNB Addition Request
    Sleep    1

Verify If Counter X2_SGNB_ADD_PREP_FAIL_OVLCP Is Incremented For UE Assigned To Cell ${cell_number}
    counters.Wait For Next Full Pm Interval Aic
    ${PM_COUNTER_FILE}=    counters.Get Latest Unpacked Full Pm Counters File Aic
    counters.Verify Last Counters In File
    ...    M55112C05501  +1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_number}
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

Enable partial overload on CPRT pod
    Create List With R&D Flags    0x5901FA    1    0x5901FB    17    0x5901FC    1
    ...        0x590226    0    0x590227    200    0x590221    3000
    Setup R&D Flags    name=default    port=15057    flags=${flags_list}    pod=${CPRT_POD}

Enable full overload on CPRT pod
    Create List With R&D Flags    0x5901FA    1    0x5901FB    1    0x5901FC    1
    ...        0x590226    0    0x590227    200    0x590221    3000
    Setup R&D Flags    name=default    port=15057    flags=${flags_list}    pod=${CPRT_POD}
    Sleep    5

Enable full overload on CPUE pod
    Create List With R&D Flags    0x89008E    0    0x89006F    0
    Setup R&D Flags    name=default    port=15007    flags=${flags_list}    pod=${CPUE_POD}    hops=&{HOPS_OCP_VCU}
    Sleep    1

Change CPRT Flags To Default Values
    Log To Console    \nChanging C-Plane flags to default values: ${CPRT_DEFAULT_FLAGS}
    ${CPRT_POD}=    utility.Get Pod Name    pod_name=cprt
    Change Multiple R&D Flags    name=default    port=15057   namespace=${NAMESPACE}
    ...                          pod=${CPRT_POD}    flags=@{CPRT_DEFAULT_FLAGS}

Change CPUE Flags To Default Values
    Log To Console    \nChanging C-Plane flags to default values: ${CPUE_DEFAULT_FLAGS}
    ${CPRT_POD}=    utility.Get Pod Name    pod_name=cprt
    Change Multiple R&D Flags    name=default    port=15007   namespace=${NAMESPACE}
    ...                          pod=${CPUE_POD}    flags=@{CPUE_DEFAULT_FLAGS}    hops=&{HOPS_OCP_VCU}

Change Uplane Flags To Default Values
    Log To Console    \nChanging U-Plane flags to default values: @{UPLANE_DEFAULT_FLAGS}
    Apply R&D Flags For U-Plane    flags=@{UPLANE_DEFAULT_FLAGS}
    utility.Wait For F1 Link To Be Available
    utility.Wait For All Cells To Be Online

Set Up PDU Session For Mutiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${delay}=1
    Log To Console    Setting up PDU session for UEs ${first_ue_id}-${last_ue_id}
    ${last_ue_id_int}=    Convert To Integer    ${last_ue_id}
    ${last_ue_id_plus_one}=    Evaluate    ${last_ue_id_int} + 1
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id_plus_one}
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${i} pdu=1 nwslice=1 gw=1
        Sleep    ${delay}
    END

Register Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${delay}=1.5
    Execute Egate Command    cmd=set_pdu_param ue=${first_ue_id}-${last_ue_id} pdu=1 trf_type=internal
    ${last_ue_id_int}=    Convert To Integer    ${last_ue_id}
    ${last_ue_id_plus_one}=    Evaluate    ${last_ue_id_int} + 1
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id_plus_one}
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}    pass_regexp=UE${i}: Registering
        Sleep    ${delay}
    END

Register Multiple UEs with PDU session
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${attach_delay}=3    ${pdu_delay}=1
    Execute Egate Command    cmd=set_pdu_param ue=${first_ue_id}-${last_ue_id} pdu=1 trf_type=internal
    ${last_ue_id_int}=    Convert To Integer    ${last_ue_id}
    ${last_ue_id_plus_one}=    Evaluate    ${last_ue_id_int} + 1
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id_plus_one}
        Attach Ue    ue_id=${i}    pass_regexp=UE${i}: Registering
        Sleep    ${attach_delay}
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${i} pdu=1 nwslice=1 gw=1
        Sleep    ${pdu_delay}
    END

Register UEs In Loop Signaling
    [Arguments]    ${ue_range}    ${tries}=7
    FOR    ${index}    IN RANGE    ${tries}
        Execute Egate Command    cmd=ue_register id=${ue_range}
        Sleep    0.5
        Execute Egate Command    cmd=ue_deregister id=${ue_range} by=ue ue_deregister_type=switch_off
    END

Start Traffic For Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dir}    ${traffic}=5    ${unit}=Mbps    ${stabi_time}=5
    Execute Egate Command
    ...    cmd=trf_data_start ue=${first_ue_id}-${last_ue_id} pdu=1 trf_id=1 ${unit}=${traffic} dir=${dir}
    Sleep    ${stabi_time}    reason=Wait for throughput stabilization

Stop Traffic For Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dir}    ${stop_time}=6
    Execute Egate Command
    ...    cmd=trf_data_stop ue=${first_ue_id}-${last_ue_id} pdu=1 trf_id=1 dir=${dir}
    Sleep    ${stop_time}    reason=Wait for overload timer to expire and throughput reduction in egate

Get Pod Name And Set As Variable
    [Arguments]    ${pod_name}
    ${pod_full_name}=    utility.Get Pod Name    pod_name=${pod_name}
    Set Suite Variable    ${pod_full_name}

Set Vdu Yamls Path Variable
    ${HOSTNAME_WITH_DASH}= 	      Evaluate    socket.gethostname()	socket
    ${HOSTNAME}=                  Replace String    string=${HOSTNAME_WITH_DASH}    search_for=-    replace_with=_
    ${VDU_ACTIVE_SW}=             utility.Get Vdu Active Sw Build
    ${VDU_YAMLS_BASE_PATH}=       Set Variable    /home/core/${HOSTNAME}/${VDU_ACTIVE_SW}/0/HelmChart/cnf/aic-vdu
    Set Suite Variable    ${VDU_YAMLS_BASE_PATH}

Set Vdu Yamls Variable
    ${VDU_YAMLS}=    Catenate    SEPARATOR=        ${VDU_YAMLS_BASE_PATH}/values-override.yaml,
    ...    ${VDU_YAMLS_BASE_PATH}/vdu-cnf-common-TDD.yaml,${VDU_YAMLS_BASE_PATH}/tl.yaml
    Set Suite Variable    ${VDU_YAMLS}

Set Knife Hook Command Variable
    ${knife_hook_cmd}=    Catenate    SEPARATOR=    ute-ca-hook-aic-docker-knife configmap --config /home/ute
    ...                               /testline_init_results/execution/configs/hooks/hook_config_for_node_1.json
    Set Suite Variable    ${knife_hook_cmd}

Apply Onair
    [Arguments]    ${lua_cfg}
    Reach Onair Aic                lua_cfg=${lua_cfg}    check_edaemon_port=True
    utility.Wait For All Cells To Be Online

Apply R&D Flags For U-Plane
    [Arguments]    ${flags}
    Set Knife Hook Command Variable
    Set Vdu Yamls Path Variable
    Set Vdu Yamls Variable
    hook.Copy Dockerfiles And Config Yaml    topology=${TOPOLOGY}    dockerfile_src=${CURDIR}/../config/dockerfiles-l2rt
    ...                                      config_yaml_src=${CURDIR}/../config/config.yaml
    hook.Append Flags To Swconfig    flags=${flags}    topology=${TOPOLOGY}    component=l2rt
    hook.Install Hook In Venv    new_venv_name=ute_ca_venv
    hook.Run Hook    command=${knife_hook_cmd}
    utility.Wait For F1 Link To Be Available

Check Overloaded GNBDU Status Indication Element For At Least Given Number Of Messages
    [Arguments]    ${num_of_msg}
    ta5g_tshark.Verify Tshark    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    pass_criteria= >=${num_of_msg}
    ...    pcap_file_path=default
    ...    timeout=20
    ...    continue_on_failure=${True}

Check RRC Reject For At Least Given Number Of Messages
    [Arguments]    ${num_of_msg}
    Verify Uu Messages    packet_filter=${RRC_REJECT}
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    number_of_messages=${num_of_msg}
    ...    relation_symbol= >=
    ...    timeout=20
    ...    continue_on_failure=${True}

Suite Setup Uplane Scheduling Overload
    ta5g_setups_and_teardowns.Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}
    @{SCHEDULING_UPLANE_OVL_FLAGS}=    Create List    0x58093B=50    0x58093C=50    0x58093D=9    0x58093E=1    0x58093F=100
    ...    0x580940=50    0x580941=50    0x580942=9    0x580943=1    0x580944=100
    Set Suite Variable    @{SCHEDULING_UPLANE_OVL_FLAGS}
    Commission Overload Parameters On vDU    &{OVL_PARAMS_VDU_ON_SCHED}
    Commission Overload Parameters On vCU    &{OVL_PARAMS_VCU_ON}
    Apply R&D Flags For U-Plane    flags=@{SCHEDULING_UPLANE_OVL_FLAGS}
    ta5g_egate.Reach Onair Aic    lua_cfg=${CURDIR}/../config/CB012584.lua    check_edaemon_port=True

Suite Setup Uplane Signaling Overload
    ta5g_setups_and_teardowns.Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}
    @{SIGNALING_UPLANE_OVL_FLAGS}=    Create List    0x580933=1    0x580934=0
    Set Suite Variable    @{SIGNALING_UPLANE_OVL_FLAGS}
    Commission Overload Parameters On vDU    &{OVL_PARAMS_VDU_ON_SCHED}
    Commission Overload Parameters On vCU    &{OVL_PARAMS_VCU_ON}
    Apply R&D Flags For U-Plane    flags=@{SIGNALING_UPLANE_OVL_FLAGS}
    ta5g_egate.Reach Onair Aic    lua_cfg=${CURDIR}/../config/CB012584.lua    check_edaemon_port=True

Suite Teardown Uplane Scheduling Overload
    Commission Overload Parameters On vDU    &{OVL_PARAMS_VDU_OFF_SCHED}
    Commission Overload Parameters On vCU    &{OVL_PARAMS_VCU_OFF}
    hook.Clear Flags In Swconfig    flags=@{SCHEDULING_UPLANE_OVL_FLAGS}    topology=${TOPOLOGY}    component=l2rt
    ${connection}=    helm.Helm Master Connect    ip=${VDU_IP_ADDR}    port=${VDU_IP_PORT}
    ...    user=${VDU_IP_USERNAME}    password=${VDU_IP_PASSWORD}
    ${stdout}  ${stderr}  ${status}=    helm.Helm Delete    release_name=vdu
    ...    namespace=${NAMESPACE}    conn=${connection}
    Run Keyword If    ${status} == 0    Log To Console    Deletion Of vDU CNF successful.     ELSE    Run Keywords
    ...    Log To Console    There was some error during deletion of vDU CNF    AND    Fail
    ${stdout}  ${stderr}  ${status}=    helm.Helm Install    release_name=vdu    chart_path=${VDU_YAMLS_BASE_PATH}
    ...    namespace=${NAMESPACE}    conn=${connection}
    ...    value_files=${VDU_YAMLS}    install_timeout=15m0s
    Run Keyword If    ${status} == 0    Log To Console    Redeployment Of vDU CNF successful.     ELSE    Run Keywords
    ...    Log To Console    There was some error during installation of vDU CNF.    AND    Fail
    utility.Wait For F1 Link To Be Available
    ta5g_setups_and_teardowns.Stop Default Logging Aic

Register high priority access UE and verify RRC reject is not visible
    [Arguments]    ${pcap}=Uu_2.pcap    ${alias}=pcap2
    Start Tshark    log_filename=${pcap}    eth_interface=eth4    alias=${alias}    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    UE NR RRC Setup Param    ue_id=152    establishment_cause=highPriorityAccess
    Attach UE    152
    Check If RRCReject Is Not Visible    pcap_file_path=${pcap}    alias=${alias}
    Deregister UE    152
    Stop Tshark    alias=${alias}

Register emergency UE and verify RRC reject is not visible
    [Arguments]    ${ue_id}=153    ${pcap}=Uu_1.pcap    ${alias}=pcap1
    Start Tshark    log_filename=${pcap}    eth_interface=eth4    capture_filter=sctp    alias=${alias}    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    UE NR RRC Setup Param    ue_id=${ue_id}    establishment_cause=emergency
    Attach UE    ue_id=${ue_id}    optional_parameters=registration_type=EmergencyRegistration
    Check If RRCReject Is Not Visible    pcap_file_path=${pcap}    alias=${alias}
    Deregister UE    ue_id=${ue_id}
    Stop Tshark    alias=${alias}

Setup RRC inactive UE
    [Arguments]    ${wait_for_inactivity}=yes    ${only_one_ue}=no    ${wait_time}=1
    IF    '${only_one_ue}' == 'no'
        ${ue_ids}=    Set Variable    all
    ELSE
        ${ue_ids}=    Set Variable    151
    END
    ${amf_command}=    Catenate    amf_ue_ics_param id=1 ue=${ue_ids} core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=256
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=280
    Set internal traffic type for UE    ue=151    pdu=1
    Execute Egate Command    cmd=${amf_command}
    Attach UE    151
    Establish PDU Session    ue_id=151
    IF    '${wait_for_inactivity}' == 'yes'
        Wait for egate console output    UE151: Is INACTIVE    timeout=70
    ELSE
        Sleep    ${wait_time}    reason=Configurable wait time depending on test circumstances
    END

Resume RRC inactive UE
    [Arguments]    ${traffic}=1    ${delay}=1
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=151 gnb=2 cell=1 msg=resume_request_1 cause=mt_Access
    Start data traffic    ues=151    direction=dl    pdu=1    throughput=${traffic}Mbps
    Sleep    ${delay}

Register UE and start data traffic
    [Arguments]    ${ue_id}=1    ${direction}=dl    ${pdu_id}=1    ${throughput}=1Mbps
    Set internal traffic type for UE    ue=${ue_id}    pdu=${pdu_id}
    Sleep    3
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    1
    Start data traffic    ues=${ue_id}    direction=${direction}    pdu=${pdu_id}    throughput=${throughput}

Perform UE handover
    [Arguments]    ${ue_id}=1    ${tgt_phycell_id}=50    ${type}=NG    ${pass_regex}=${None}
    IF    '${type}' == 'NG'
        ${pass_regexp}=    Set variable    Inter-gNB Handover is triggered , target-pci : ${tgt_phycell_id}
    ELSE
        ${pass_regexp}=    Set variable    ${pass_regex}
    END
    Send UE measurement NR    ue_id=${ue_id}    meas_id=1    event=A3    phycell_id=${tgt_phycell_id}    nrsrp_nr=100
    ...    srsrp_nr=19    pass_regexp=${pass_regexp}

Perform online overload activation
    Perform delta recommissioning vDU    ${CURDIR}/../config/activate_ovl_online_vdu.json
    Perform delta recommissioning vCU    ${CURDIR}/../config/enable_OVL_online_vcu.json

Perform online overload deactivation
    Perform delta recommissioning vDU    ${CURDIR}/../config/deactivate_ovl_online_vdu.json
    Perform delta recommissioning vCU    ${CURDIR}/../config/disable_OVL_online_vcu.json

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:sim_gnb1    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:sim_gnb2    ip_with_mask=10.0.1.4/24

Copy Wireshark preferences
    Copy File    ${CURDIR}/wireshark_preferences    /home/ute/.config/wireshark/preferences

Start TCE trace
    [Arguments]    ${log_filename}=trace_TCE.pcap    ${alias}=tce_trace_pcap
    Start tshark
    ...    log_filename=${log_filename}
    ...    eth_interface=eth5
    ...    capture_filter=tcp
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    alias=${alias}

Verify TCE Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=tce_trace_pcap   ${continue_on_failure}=${True}
    IF    ${{$pcap_file_path is not None}}
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${pcap_file_path}
    END
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Suite Setup CPlane Overload
    Enable Cloud
    Start Vm Ethernet Interfaces
    Copy Wireshark preferences
    ta5g_egate.Reach Onair Aic                lua_cfg=${CURDIR}/../config/CB012584.lua    check_edaemon_port=True
    Get Pod Name And Set As Variable    pod_name=cprt
    Setup X2 Link    initiator_device=1    complementary_device=2
    Perform delta recommissioning vDU    ${CURDIR}/../config/initial_delta_new_vdu.json
    Perform delta recommissioning vCU    ${CURDIR}/../config/initial_delta_new_vcu.json

Suite Teardown CPlane Overload
    Log to console    Suite teardown

Suite Setup Uplane Overload
    @{UPLANE_OVL_FLAGS}=    Create List    0x580933=1    0x580934=0    0x58093B=50    0x58093C=50    0x58093D=5
    ...    0x58093E=1    0x58093F=100    0x580940=50    0x580941=50    0x580942=5    0x580943=1    0x580944=100
    Set Suite Variable    @{UPLANE_OVL_FLAGS}
    Apply R&D Flags For U-Plane    flags=@{UPLANE_OVL_FLAGS}
    Start Vm Ethernet Interfaces
    Reach Onair Aic    lua_cfg=${CURDIR}/../config/CB012584.lua    timeout=180    check_edaemon_port=True
    Perform delta recommissioning vDU    ${CURDIR}/../config/initial_delta_new_vdu.json
    Perform delta recommissioning vCU    ${CURDIR}/../config/initial_delta_new_vcu.json

Suite Teardown Uplane Overload
    Perform delta recommissioning vDU    ${CURDIR}/../config/disable_sig_ovl.json
