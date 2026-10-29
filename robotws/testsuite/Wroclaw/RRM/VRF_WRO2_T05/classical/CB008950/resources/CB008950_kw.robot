*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Library         ta5g_pm_counters
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950.py    WITH NAME    CB008950
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.hw.rf_attenuator    WITH NAME    att
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
#Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell

*** Keywords ***
Check scell tput on each UE
    [Documentation]    This keyword checks if DL tput is actually started on scell for every UE.
    ...                If not it is not possible to reach tput higher than 80000 MBits/sec
    ...                by each UE on single 10 MHz primary cell having DL tput started simultaneously.
    ...                Expected tput must be near 80000 MBits/sec. Expected UE3 tput is lower equal to 40000
    ...                due to broken port on mediatek.
    [Arguments]    ${avg_tput_DL_UE_1}  ${avg_tput_DL_UE_2}  ${avg_tput_DL_UE_3}  ${min_expected_tput}  ${deviation}=${0.9}
    Should Be True  ${avg_tput_DL_UE_1} > ${min_expected_tput}*${deviation}  Avg tput of UE_1 must be near ${min_expected_tput}
    Should Be True  ${avg_tput_DL_UE_2} > ${min_expected_tput}*${deviation}  Avg tput of UE_2 must be near ${min_expected_tput}
    Should Be True  ${avg_tput_DL_UE_3} > ${min_expected_tput}*${0.4}  Avg tput of UE_3 must be near 40000

Set attenuation 8950_310
    [Documentation]    Set Attenuation for 8950_310 test case on 186 attenuator
    ...               Turn on Cell 100 (AHLOB_1)
    ...               Turn on Cell 101 (AHLOB_2)
    #...               Turn on Cell 102 (AHLOB_3)
    ...               Turn on Cell 108 (AVHA_1)
    ...               Turn on Cell 109 (AVHA_2)
    ...               Turn on Cell 110 (AVHA_3)
    ...               Turn on Cell 114 (AHFII_1)

    Set attenuation on ports and check  lines=${lines_gNB_310_AHLOB_1_FDD_n71}   value=0    alias=att_1
    Set attenuation on ports and check  lines=${lines_gNB_310_AHLOB_2_FDD_n71}   value=0    alias=att_1
    #Set Attenuation on ports and check  lines=${lines_gNB_310_AHLOB_3_FDD_n71}   value=0    alias=att_1
    Set attenuation on ports and check  lines=${lines_gNB_310_AVHA_1_TDD_n41}    value=0    alias=att_1
    Set attenuation on ports and check  lines=${lines_gNB_310_AVHA_2_TDD_n41}    value=0    alias=att_1
    Set attenuation on ports and check  lines=${lines_gNB_310_AVHA_3_TDD_n41}    value=0    alias=att_1
    Set attenuation on ports and check  lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}   value=0    alias=att_2

Set attenuation CB008950-DB5_310
    [Documentation]    Set attenuation for CB008950-DB5 test case on 186 attenuator
    ...                Turn on CA SCell 101 (AHLOB_2)
    ...                Turn on CA SCell 108 (AVHA_1)
    ...                Turn on PCell 114 (AHFII_1)
    ...                Turn on CA SCell 105 (AHFII_2)
    ...                Turn on CA SCell 106 (AHFII_3)
    Set attenuation on ports and check    lines=${lines_gNB_310_AHLOB_2_FDD_n71}    value=0    alias=att_1
    Set attenuation on ports and check    lines=${lines_gNB_310_AVHA_2_TDD_n41}     value=0    alias=att_1
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_2_FDD_n25_n66}    value=30    alias=att_2


Set attenuation CB008950-DB201_310
    [Documentation]    Set attenuation for CB008950-DB201 test case on 186 attenuator
    ...                Turn on Cell 101 (AHLOB_1)
    ...                Turn on Cell 106, 116 (AHFII_3)
    ...                Turn on Cell 108 (AVHA_1)
    ...                Turn on Cell 209 (AVHA_2)
    ...                Turn on Cell 214 (AHFII_1)
    Set attenuation on ports and check        lines=${lines_gNB_310_AHLOB_2_FDD_n71}    value=0    alias=att_1
    Set attenuation on ports and check        lines=${lines_gNB_310_AHFII_3_FDD_n25_n66}    value=0    alias=att_2
    Set attenuation on ports and check        lines=${lines_gNB_310_AVHA_1_TDD_n41}     value=0    alias=att_1
    #Set attenuation on ports and check        lines=${lines_gNB_310_AVHA_2_TDD_n41}     value=15    alias=att_1
    Set attenuation on ports and check        lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}    value=0    alias=att_2

Set attenuation 8950
    ${att_1_ports_1}=  Create List  1  2  3  4  5  6  7  8  #AHLOA#1, AHFIB#1
    ${att_1_ports_2}=  Create List  9  10  11  12  21  22  23  24
    ${att_2_ports_1}=  Create List  9  10  11  12  #AEHC#2 PCI 108
    ${att_value}=  Set Variable  10
    ${att_value_aehc}=  Set Variable  20
    Set attenuation and check  lines=@{att_1_ports_1}    value=${att_value}
    Set attenuation and check  lines=@{att_1_ports_2}    value=${att_value_aehc}
    Set attenuation_2 and check  lines=@{att_2_ports_1}    value=${att_value_aehc}

Set attenuation CB008950-DB5
    [Arguments]  ${att_2_value_ahfib3}=90
    ${att_1_ports_off}=  Create List  1  2  3  4  21  22  23  24
    ${att_1_ports_ahfib1_ahloa2_ahfib2}=  Create List  5  6  7  8  13  14  15  16  17  18  19  20
    ${att_1_ports_aehc1}=  Create List  9  10  11  12
    ${att_2_ports_off}=  Create List  1  2  3  4  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24
    ${att_2_ports_ahfib3}=  Create List  5  6  7  8
    ${att_value_off}=  Set Variable  90
    ${att_1_value_ahfib1_ahloa2_ahfib2}=  Set Variable  10
    ${att_1_value_aehc1}=  Set Variable  20
    Set attenuation and check  lines=@{att_1_ports_off}    value=${att_value_off}
    Set attenuation and check  lines=@{att_1_ports_ahfib1_ahloa2_ahfib2}    value=${att_1_value_ahfib1_ahloa2_ahfib2}
    Set attenuation and check  lines=@{att_1_ports_aehc1}    value=${att_1_value_aehc1}
    Set attenuation_2 and check  lines=@{att_2_ports_off}    value=${att_value_off}
    Set attenuation_2 and check  lines=@{att_2_ports_ahfib3}    value=${att_2_value_ahfib3}

Set attenuation CB008950-DB201
    ${att_1_ports_off}=  Create List  1  2  3  4  17  18  19  20  21  22  23  24
    ${att_1_ports_ahfib1}=  Create List  5  6  7  8
    ${att_1_ports_ahloa2}=  Create List  13  14  15  16
    ${att_1_ports_aehc1}=  Create List  9  10  11  12
    ${att_2_ports_off}=  Create List  1  2  3  4  9  10  11  12  13  14  15  16  17  18  19  20
    ${att_2_ports_ahfib3_ahfib4}=  Create List  5  6  7  8  21  22  23  24
    ${att_value_off}=  Set Variable  90
    ${att_1_value_ahloa2}=  Set Variable  10
    ${att_1_value_aehc1}=  Set Variable  20
    ${att_value_on}=  Set Variable  0
    Set attenuation and check  lines=@{att_1_ports_off}    value=${att_value_off}
    Set attenuation and check  lines=@{att_1_ports_ahfib1}    value=${att_value_on}
    Set attenuation and check  lines=@{att_1_ports_ahloa2}    value=${att_1_value_ahloa2}
    Set attenuation and check  lines=@{att_1_ports_aehc1}    value=${att_1_value_aehc1}
    Set attenuation_2 and check  lines=@{att_2_ports_off}    value=${att_value_off}
    Set attenuation_2 and check  lines=@{att_2_ports_ahfib3_ahfib4}    value=${att_value_on}

Set attenuation CB008950-DB101
    Log to Console    Attenuation set
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0


Setup T186 attenuator
    ${att_alias}=  Set variable  t_186_attenuator
    ${port_numbers}=  Create List  1  2  3  4  5  6  7  8  9  10  11  12
    # Reset attenuator   ip_addr=10.42.61.34
    att.Setup attenuator    ip_addr=10.42.61.34    port=3001
    ...    attenuation_port_numbers=@{port_numbers}    max_attenuation=63    vendor=JFW
    ...    model=50PA-628   alias=${att_alias}
    Set attenuation on ports and check  lines=@{port_numbers}  value=${63}  alias=${att_alias}

Set T186 attenuator for cell 561
    [Arguments]  ${att_value}
    ${att_alias}=  Set variable  t_186_attenuator
    ${port_numbers}=  Create List  9  10  11  12
    # Reset attenuator   ip_addr=10.42.61.34
    Set attenuation on ports and check  lines=@{port_numbers}  value=${att_value}  alias=${att_alias}

Check specific cells are on air once
    [Arguments]    ${cells}    ${cell_type}=nr    ${timeout}=2000
    FOR    ${cell_id}    IN    @{cells}
        gnbcell.wait_for_cell_to_be_onair    cell_id=${cell_id}    cell_type=${cell_type}    timeout=${timeout}
    END

Check specific cells are on air
    [Arguments]    ${cells}    ${cell_type}=nr    ${timeout}=200   ${connection}=default    ${retry_interval}=90s    ${on_air_check}=True
    ${last_error}=    Set Variable    Unknown error
    ${alarm_23_seen}=    Set Variable    ${False}
    ${update_performed}=    Set Variable    ${False}
    FOR    ${attempt}    IN RANGE    1    7
        ${status}    ${message}=    Run keyword and ignore error
        ...    Check specific cells are on air once    ${cells}    ${cell_type}    ${timeout}
        IF    '${status}' == 'PASS'
            Return From Keyword
        END
        ${last_error}=    Set Variable    ${message}
        ${alarm_list_actual}=    Check unwanted alarms    connection=${connection}
        ${is_23_active}=    Run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
        ${alarm_23_seen}=    Set Variable If    ${is_23_active}    ${True}    ${alarm_23_seen}
        IF    ${is_23_active}
            Log to console    Alarm 23 visible after failed on-air check (attempt ${attempt}/3)
            IF    not ${update_performed}
                Perform_update  connection=${connection}  on_air_check=${on_air_check}  dir=/home/ute/Downloads
                ${update_performed}=    Set Variable    ${True}
            ELSE
                Log to console    Alarm 23 detected again, Perform_update already executed - skipping.
            END
        END
        IF    ${attempt} < 3
            Sleep    ${retry_interval}
        END
    END
    Fail    Check specific cells are on air failed after 3 attempts. Alarm 23 seen: ${alarm_23_seen}. Last error: ${last_error}


Perform rmod update if necessary
    [Arguments]    ${connection}=default    ${on_air_check}=True
    ${alarm_list_actual}=    Check unwanted alarms    connection=${connection}
    ${is_23_active}=    Run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    IF    ${is_23_active}
        Perform_update  connection=${connection}  on_air_check=${on_air_check}  dir=/home/ute/Downloads
    END


Load scf for 8950
    [Arguments]         ${resource_path}    ${folder_name}    ${scf_nr_name}
    ${host_name}=       Get TL hostname 8950
    ${stream_name}=     Get stream name 8950
    log to console      Start commissioning NR
    ${result}  coam.perform_commissioning
    ...   scf_file=${resource_path}/${host_name}/${folder_name}/${stream_name}/${scf_nr_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM
    log to console      Commissioning NR result=${result}

Get TL hostname 8950
    ${result} = 	Run   uname -a|awk '{print $2}'
    ${tl_name}=  Replace String  ${result}  -  _
    ${tl_name_final}=  Get Substring  ${tl_name}  0  -2
    [Return]  ${tl_name_final}

Get stream name 8950
    ${stream} = 	coam.Get sw release name    connection=cOAM    timeout=60
    ${stream} =  Set Variable If  '${stream}'=='SBTS26R2'  TRUNK    ${stream}
    [Return]  ${stream}

Set Suite variables CB008950
    Set Suite Variable  ${bts_mplane}  10.44.137.32

Set test variables CB008950-DB5
    Set test variable  ${test_name}  CB008950-DB5
    Set test variable  ${filter_list}  "ZMQ/SCTP name"="SrbSendReq";"ZMQ/SCTP name"="UlSduReceiveInd","Mapping"="cpSbAddress";"Mapping"="cpUeAddress"
    Set test variable  ${dcap_logs}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}

Set test variables CB008950-AB3
    Set test variable  ${test_name}  CB008950-AB3
    Set test variable  ${dcap_logs}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}
    ${cells_dict}      Create Dictionary
    Set test variable  ${cells_dict}

Set test variables CB008950-AB4
    Set test variable  ${test_name}  CB008950-AB4
    Set test variable  ${dcap_logs}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}
    ${cells_dict}      Create Dictionary
    Set test variable  ${cells_dict}

Set test variables CB008950-CB1
    Set test variable  ${test_name}  CB008950-CB1
    Set test variable  ${dcap_logs}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}
    ${cells_dict}      Create Dictionary
    Set test variable  ${cells_dict}
    Set test variable  ${filter_list}  "ZMQ/SCTP name"="SrbSendReq";"ZMQ/SCTP name"="UlSduReceiveInd","Mapping"="cpSbAddress";"Mapping"="cpUeAddress"

Set test variables CB008950-DB201
    Set test variable  ${test_name}  CB008950-DB201

    ${filter_list_exceed_1}  Set Variable  "ZMQ/SCTP name"="SrbSendReq";"ZMQ/SCTP name"="X2AP: SgNBAdditionRequestAcknowledge";
    ${filter_list_exceed_2}  Set Variable  "ZMQ/SCTP name"="F1AP: UEContextModificationFailure";"ZMQ/SCTP name"="X2AP: SgNBModificationRequired",
    ${filter_list_exceed_3}  Set Variable  "Mapping"="cpSbAddress";"Mapping"="x2apPort";"Mapping"="f1apPort"
    ${combined_filter_list_exceed}  Catenate  SEPARATOR=  ${filter_list_exceed_1}  ${filter_list_exceed_2}  ${filter_list_exceed_3}
    Set test variable  ${filter_list_exceeded_limit}  ${combined_filter_list_exceed}

    ${filter_list_no_exceed_1}  Set Variable  "ZMQ/SCTP name"="X2AP: SgNBModificationRequired";
    ${filter_list_no_exceed_2}  Set Variable  "ZMQ/SCTP name"="X2AP: SgNBAdditionRequestAcknowledge","Mapping"="x2apPort"
    ${combined_filter_list_no_exceed}  Catenate  SEPARATOR=  ${filter_list_no_exceed_1}  ${filter_list_no_exceed_2}
    Set test variable  ${filter_list_not_exceeded_limit}  ${combined_filter_list_no_exceed}

    Set test variable  ${exceeded_limit_suffix}  exceeded
    Set test variable  ${not_exceeded_limit_suffix}  not_exceeded
    Set test variable  ${dcap_logs_exceeded_limit}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${exceeded_limit_suffix}
    Set test variable  ${dcap_log_not_exceeded_limits}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${not_exceeded_limit_suffix}

Set test variables CB008950-DB101
    Set test variable  ${test_name}  CB008950-DB101
    ${t410_1}  Set variable  "User data"="DuCaConfig, SetupSCellId: 208310276";"ZMQ/SCTP name"="SrbSendReq";
    ${t410_2}  Set variable  "ZMQ/SCTP name"="NGAP: UEContextReleaseComplete";"ZMQ/SCTP name"="XnAP: IgNBCAResourceStatusUpdate",
    ${t410_3}  Set variable  "Mapping"="cpSbAddress";"Mapping"="ngapPort";"Mapping"="xnapPort";"Mapping"="f1apPort"
    ${combined_filter_list_exceed_t410}  Catenate  SEPARATOR=  ${t410_1}  ${t410_2}  ${t410_3}
    Set test variable  ${filter_list_exceeded_t410}  ${combined_filter_list_exceed_t410}

    ${t186_1}  Set variable  "ZMQ/SCTP name"="SrbSendReq";"ZMQ/SCTP name"="UlSduReceiveInd","Mapping"="cpSbAddress";"Mapping"="cpUeAddress"
    Set test variable  ${filter_list_exceeded_t186}  ${t186_1}

    Set test variable  ${filter_list_not_exceeded_t410}  "ZMQ/SCTP name"="XnAP: IgNBCAResourceStatusUpdate","Mapping"="xnapPort"
    Set test variable  ${filter_list_not_exceeded_t186}  "ZMQ/SCTP name"="F1AP: UEContextModificationResponse","Mapping"="f1apPort"

    Set test variable  ${exceeded_limit_suffix_t410}  exceeded_t410
    Set test variable  ${exceeded_limit_suffix_t186}  exceeded_t186
    Set test variable  ${not_exceeded_limit_suffix_t410}  not_exceeded_t410
    Set test variable  ${not_exceeded_limit_suffix_t186}  not_exceeded_t186
    Set test variable  ${dcap_logs_exceeded_limit_t410}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${exceeded_limit_suffix_t410}
    Set test variable  ${dcap_logs_exceeded_limit_t186}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${exceeded_limit_suffix_t186}
    Set test variable  ${dcap_log_not_exceeded_limits_t410}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${not_exceeded_limit_suffix_t410}
    Set test variable  ${dcap_log_not_exceeded_limits_t186}  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_${not_exceeded_limit_suffix_t186}

Lock LTE cells
    CB008950.delta_commisioning    json_delta=CB008950-DB5_lock_lte_cells
    Wait until keyword succeeds    20 min    1 min    CB008950.Verify all cells state with admin  lte_locked=${True}

Unlock LTE cells
    CB008950.delta_commisioning    json_delta=CB008950-DB5_unlock_lte_cells
    Wait until keyword succeeds    20 min    1 min    CB008950.Verify all cells state with admin

Load delta for CB008950-D-B201
    CB008950.delta_commisioning    json_delta=CB008950-DB201
    Wait until keyword succeeds    20 min    1 min    CB008950.Verify all cells state with admin  lte_locked=${True}  is_db_201=${True}

Add flags to sw config CB008950-DB101 t410
    [Documentation]    0x89006C = 2 #rdMaxActiveIncomingCaRelFlexSCellSelect for CU
    ...                0x89006D = 2 #rdMaxActiveOutgoingCaRelFlexSCellSelect for CU
    ${sw}=  coam.get_software_info  connection=cOAM
#    ${sw_config_path}=  CB008950.get_swconfig_path  ${sw['Active SW version']}
    ${flags_to_add}  Set variable  0x89006C=2${\n}0x89006D=2
    add_flag_to_swconfig  swconfig_backup  ${flags_to_add}  reset=${False}  sw_config_path=/ffs/run/swconfig.txt

Add flags to sw config CB008950-DB101 t186
    [Documentation]    0x89006C = 2 #rdMaxActiveIncomingCaRelFlexSCellSelect for CU
    ...                0x89006D = 2 #rdMaxActiveOutgoingCaRelFlexSCellSelect for CU
    ADMIN CLI remote connection  10.44.149.65
    ${sw}=  coam.get_software_info  connection=remote_admin
#    ${sw_config_path}=  CB008950.get_swconfig_path  ${sw['Active SW version']}
    ${flags_to_add}  Set variable  0x89006C=2${\n}0x89006D=2
    add_flag_to_swconfig  swconfig_backup_t186  ${flags_to_add}  reset=${False}  sw_config_path=/ffs/run/swconfig.txt
    ...  hostname=10.44.137.49  connection=remote_admin
    ADMIN CLI disconnection  connection=remote_admin

Restore original sw config CB008950
    [Arguments]  ${reset}=${False}
    ${sw}=  coam.get_software_info  connection=cOAM
    ${sw_config_path}=  CB008950.get_swconfig_path  ${sw['Active SW version']}
    restore_original_swconfig  swconfig_backup  reset=${reset}  sw_config_path=${sw_config_path}
    # Wait until keyword succeeds    20 min    1 min    CB008950.Verify all cells state with admin
    # wait until keyword succeeds  10min      1min    Check if X2 link Up

Restore original sw config CB008950 t186
    ADMIN CLI remote connection  10.44.149.65
    ${sw}=  coam.get_software_info  connection=remote_admin
    ${sw_config_path}=  CB008950.get_swconfig_path  ${sw['Active SW version']}
    restore_original_swconfig  swconfig_backup_t186  reset=${True}  sw_config_path=/ffs/run/swconfig.txt  hostname=10.44.137.49
    ...  connection=remote_admin
    Wait until keyword succeeds  20 min    20 sec   Check SMOD and BBMOD  remote_admin
    Check cells_status  connection=remote_admin
    ADMIN CLI disconnection  connection=remote_admin

Verify CA configured
    [Arguments]  ${log_path}
    ${result}=  CB008950.verify_ca_sa_setup_CB008950_DB5  ${log_path}
    Log to console  Check CA configured with scell 101 (UE3), scell 108 (UE2), scell 105 (UE1)
    Should be True  ${result}  CA configurations with scell 101 (UE3), scell 108 (UE2), scell 105 (UE1) not found in DCAP logs ${log_path}

Get event a6 reportconfigid
    [Documentation]    Get reportConfigId value od a6 event from rrcReconfiguration measObjectToAddModList.
    ...                reportConfigId value is used further to check if measurement reports contain valid a6 events after change of radio conditions.
    [Arguments]  ${log_path}
    ${result}=  CB008950.get_event_a6_reportconfigid  ${log_path}
    Should not be equal  ${result}  ${False}  msg=Event a6 reportconfigid not found in DCAP logs ${log_path}
    Log to console  reportconfigid of a6 event is equal to ${result}
    [Return]  ${result}

Check a6 events in measurement reports
    [Documentation]    4 measurement reports with a6 event should be send.
    ...                To be sure measurement report contain a6 event, measId is compared against reportConfigId and both should be equal.
    ...                Each measurement report should have physCellId equal to 106 configured.
    [Arguments]  ${log_path}  ${report_config_id}
    Log to console  Check if valid measurement reports with a6 events exist
    ${a6_event_counter}=  CB008950.check_event_a6_phycellid  ${log_path}  ${report_config_id}
    [Return]  ${a6_event_counter}

Read counters value For CB008950-DB5
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55118C00051  M55118C00052  M55167C00008  M55167C00009  M55118C00049
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   2  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value For CB008950-D-B201
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55118C00051  M55118C00052  M55167C00008  M55167C00009  M55167C00005
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   6  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value For CB008950-D-B101
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55138C03501  M55138C03502
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value For CB008950-D-B101 t_186
    ${counters_values}=   Create List
    Collect counters ext gnb   n_last=15  hostname=10.44.137.49
    @{counters}   Create list  M55118C00046
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify CB008950-DB5 counters old
    [Arguments]  ${a6_event_counter}
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value For CB008950-DB5
    Log to console  ${counters}
    ${AVG_SIM_USED_OUT_REL_CU_114}             get_counter_value_from_single_cell   ${counters}  114    M55118C00051
    ${AVG_SIM_USED_INC_REL_CU_101}             get_counter_value_from_single_cell   ${counters}  101    M55118C00052
    ${AVG_SIM_USED_INC_REL_CU_108}             get_counter_value_from_single_cell   ${counters}  108    M55118C00052
    ${AVG_SIM_USED_OUT_REL_DU_114}             get_counter_value_from_single_cell   ${counters}  114    M55167C00008
    ${AVG_SIM_USED_INC_REL_DU_101}             get_counter_value_from_single_cell   ${counters}  101    M55167C00009
    ${AVG_SIM_USED_INC_REL_DU_108}             get_counter_value_from_single_cell   ${counters}  108    M55167C00009
    ${SA_CU_SCELL_SEL_F_MAX_OUT_REL_114}       get_counter_value_from_single_cell   ${counters}  114    M55118C00049

    Should Be True      ${AVG_SIM_USED_OUT_REL_CU_114}>0  Lack of counters for AVG_SIM_USED_OUT_REL_CU for cell 114
    Should Be True      ${AVG_SIM_USED_INC_REL_CU_101}>0  Lack of counters for AVG_SIM_USED_INC_REL_CU for cell 101
    Should Be True      ${AVG_SIM_USED_INC_REL_CU_108}>0  Lack of counters for AVG_SIM_USED_INC_REL_CU for cell 108
    Should Be True      ${AVG_SIM_USED_OUT_REL_DU_114}>0  Lack of counters for AVG_SIM_USED_OUT_REL_DU for cell 114
    Should Be True      ${AVG_SIM_USED_INC_REL_DU_101}>0  Lack of counters for AVG_SIM_USED_INC_REL_DU for cell 101
    Should Be True      ${AVG_SIM_USED_INC_REL_DU_108}>0  Lack of counters for AVG_SIM_USED_INC_REL_DU for cell 108
    Should Be True      ${SA_CU_SCELL_SEL_F_MAX_OUT_REL_114}>=${a6_event_counter}
    ...  SA_CU_SCELL_SEL_F_MAX_OUT_REL on cell 114 should be equal to number of measurement reports in DCAP logs: ${a6_event_counter}

Verify CB008950-D-B201 counters_old
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value For CB008950-D-B201
    Log to console  ${counters}
    ${AVG_SIM_USED_OUT_REL_CU_101}         get_counter_value_from_single_cell   ${counters}  101    M55118C00051
    ${AVG_SIM_USED_OUT_REL_CU_116}         get_counter_value_from_single_cell   ${counters}  116    M55118C00051
    ${AVG_SIM_USED_INC_REL_CU_108}         get_counter_value_from_single_cell   ${counters}  108    M55118C00052
    ${AVG_SIM_USED_OUT_REL_DU_101}         get_counter_value_from_single_cell   ${counters}  101    M55167C00008
    ${AVG_SIM_USED_OUT_REL_DU_116}         get_counter_value_from_single_cell   ${counters}  116    M55167C00008
    ${AVG_SIM_USED_INC_REL_DU_108}         get_counter_value_from_single_cell   ${counters}  108    M55167C00009
    ${NSA_DU_SCELL_STP_F_MAX_INC_REL_108}  get_counter_value_from_single_cell   ${counters}  108    M55167C00005

    Should Be True      ${AVG_SIM_USED_OUT_REL_CU_101}>0  Lack of counters for AVG_SIM_USED_OUT_REL_CU for cell 101
    Should Be True      ${AVG_SIM_USED_OUT_REL_CU_116}>0  Lack of counters for AVG_SIM_USED_OUT_REL_CU for cell 116
    Should Be True      ${AVG_SIM_USED_INC_REL_CU_108}>0  Lack of counters for AVG_SIM_USED_INC_REL_CU for cell 108
    Should Be True      ${AVG_SIM_USED_OUT_REL_DU_101}>0  Lack of counters for AVG_SIM_USED_OUT_REL_DU for cell 101
    Should Be True      ${AVG_SIM_USED_OUT_REL_DU_116}>0  Lack of counters for AVG_SIM_USED_OUT_REL_DU for cell 116
    Should Be True      ${AVG_SIM_USED_INC_REL_DU_108}>0  Lack of counters for AVG_SIM_USED_INC_REL_DU for cell 108
    Should Be True      ${NSA_DU_SCELL_STP_F_MAX_INC_REL_108}>0
    ...  Lack of counters for NSA_DU_SCELL_STP_F_MAX_INC_REL for cell 108


Verify CB008950-DB5 counters
    [Arguments]  ${a6_event_counter}
    ${a6}=    Convert To String    ${a6_event_counter}
    Wait For Next Full Pm Interval Classical
    ${output}=    Set Variable  ${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${output}
    Verify Any Counters In All Files
    ...    M55118C00051    >0      AVG_SIM_USED_OUT_REL_CU_114
    ...    M55167C00008    >0      AVG_SIM_USED_OUT_REL_DU_114
#    ...    M55118C00049    ${a6}   SA_CU_SCELL_SEL_F_MAX_OUT_REL_114
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-114
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00052    >0    AVG_SIM_USED_INC_REL_CU_100
    ...    M55167C00009    >0    AVG_SIM_USED_INC_REL_DU_100
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-100
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00052    >0    AVG_SIM_USED_INC_REL_CU_108
    ...    M55167C00009    >0    AVG_SIM_USED_INC_REL_DU_108
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-108
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00052    >0    AVG_SIM_USED_INC_REL_CU_105
    ...    M55167C00009    >0    AVG_SIM_USED_INC_REL_DU_105
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-105
    ...    files_path=${output}
    ...    report_pm_counter=True


Verify CB008950-D-B201 counters
    Wait For Next Full Pm Interval Classical
    ${output}=    Set Variable  ${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${output}
    Verify Any Counters In All Files
    ...    M55118C00051    >0    AVG_SIM_USED_OUT_REL_CU_101
    ...    M55167C00008    >0    AVG_SIM_USED_OUT_REL_DU_101
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-101
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00051    >0    AVG_SIM_USED_OUT_REL_CU_116
    ...    M55167C00008    >0    AVG_SIM_USED_OUT_REL_DU_116
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-116
    ...    files_path=${output}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55118C00052    >0    AVG_SIM_USED_INC_REL_CU_108
    ...    M55167C00009    >0    AVG_SIM_USED_INC_REL_DU_108
    ...    M55167C00005    >0    NSA_DU_SCELL_STP_F_MAX_INC_REL_108
    ...    local_moid=PLMN-PLMN/MRBTS-55404/NRBTS-55404/NRCELL-108
    ...    files_path=${pm_counter_file}
    ...    report_pm_counter=True


Verify CB008950-D-B101 counters
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    ${counters}                 Read counters value For CB008950-D-B101
    ${counters_t186}            Read counters value For CB008950-D-B101 t_186
    Log to console  ${counters}
    Log to console  ${counters_t186}
    ${IGNB_CA_SCELL_ADMI_REQ_SA_311}         get_counter_value_from_single_cell   ${counters}  311    M55138C03501
    ${IGNB_CA_SCELL_ADMI_SUCC_SA_311}        get_counter_value_from_single_cell   ${counters}  311    M55138C03502
    ${SA_CU_SCELL_SEL_F_MAX_INC_REL_561}     get_counter_value_from_single_cell   ${counters_t186}  561    M55118C00046

    Should Be True      ${IGNB_CA_SCELL_ADMI_REQ_SA_311}>0  Lack of counters for IGNB_CA_SCELL_ADMI_REQ_SA for cell 311
    Should Be True      ${IGNB_CA_SCELL_ADMI_SUCC_SA_311}>0  Lack of counters for IGNB_CA_SCELL_ADMI_SUCC_SA for cell 311
    Should Be True      ${SA_CU_SCELL_SEL_F_MAX_INC_REL_561}>0  Lack of counters for SA_CU_SCELL_SEL_F_MAX_INC_REL for cell 561

Verify if NSA CA limited
    [Arguments]  ${dcap_logs_path}
    ${result_ca}=  verify_ca_sa_setup_CB008950_DB201  ${dcap_logs_path}
    Should Be True  ${result_ca}  All 2 SA UEs should have CA configured with scell 108
    ${nsa_setup}=  verify_nsa_setup_CB008950_DB201  ${dcap_logs_path}
    Should Be True  ${nsa_setup}  NSA spcell should be equal to 101
    ${is_nsa_ca_not_setup}=  verify_nsa_ca_setup_CB008950_DB201  ${dcap_logs_path}
    Should Be True  ${is_nsa_ca_not_setup}  4 messages F1AP: UEContextModificationFailure should be found
    ${result_ca_nsa}=  verify_ca_nsa_setup_CB008950_DB201  ${dcap_logs_path}
    Should not be equal  ${result_ca_nsa}  ${True}  msg=phycellid equal to 108 should be NOT found and configured in X2AP: SgNBModificationRequired

Verify if NSA CA not limited
    [Arguments]  ${dcap_logs_path}
    ${nsa_setup}=  verify_nsa_setup_CB008950_DB201  ${dcap_logs_path}
    Should Be True  ${nsa_setup}  NSA spcell should be equal to 101
    ${result_ca_nsa}=  verify_ca_nsa_setup_CB008950_DB201  ${dcap_logs_path}
    Should Be True  ${result_ca_nsa}  phycellid equal to 108 should be found and configured in X2AP: SgNBModificationRequired

Verify CA configured for pcells 1 21
    [Arguments]  ${log_path}
    ${result}=  CB008950.verify_ca_sa_setup_CB008950_DB101  ${log_path}
    Log to console  Check CA configured with scell 311 for UE1 and UE4
    Should be True  ${result}  CA configurations with scell 311 for UE1 and UE4 not found in DCAP logs ${log_path}

Verify t410 dcap logs if ext scell addition limited
    [Arguments]  ${dcap_logs_path}
    [Documentation]    MaxIncomingLinksStatus should be equal to equal-to-100percent when both
    ...                UE1 and UE4 has CA with scell 311 added and UE3 do not have inter ca with scell 311 added.
    ...                When UE1 is detached and only UE 4 has ca added with scell 311 (after UE1 detach)
    ...                then MaxIncomingLinksStatus should be equal to from-50percent-below-80percent.
    Verify CA configured for pcells 1 21  ${dcap_logs_path}
    ${msg_id_scell_info}=  CB008950.get_message_id_info_of_scell_addition_message_for_UE4  ${dcap_logs_path}
    ${msg_id_ue1_detach_info}=  CB008950.get_message_id_info_of_UE1_detach  ${dcap_logs_path}
    CB008950.check_MaxIncomingLinksStatus_ue1_ue4_ca_setup  ${dcap_logs_path}  equal-to-100percent
    ...    ${msg_id_scell_info}  ${msg_id_ue1_detach_info}
    CB008950.check_MaxIncomingLinksStatus_from_start_till_end_in_filtered_file  ${dcap_logs_path}
    ...    from-50percent-below-80percent  ${msg_id_ue1_detach_info}

Verify t186 dcap logs if ext scell addition limited
    [Arguments]  ${dcap_logs_path}
    [Documentation]    Scell addition is configured with a1 events. UE3 will try to add inter ca with scell 311
    ...                4 times. That is why 4 measurement reports for a1 event are expected to be found in logs.
    ${result}=  CB008950.get_event_a1_reportconfigid  ${dcap_logs_path}
    Should not be equal  ${result}  ${False}  msg=Event a1 reportconfigid not found in DCAP logs ${log_path}
    Log to console  reportconfigid of a1 event is equal to ${result}
    Log to console  Check if valid measurement reports with a1 events exist
    ${a1_event_counter}=  CB008950.check_event_a1_phycellid  ${dcap_logs_path}  ${result}
    @{listed}=  Create List    1    2    3    4    5   6   7    8
    Should Contain  ${listed}    ${a1_event_counter}   UE3 will try to add inter ca with scell 311. Please check logs: ${log_path}


Verify t410 dcap logs if ext scell addition not limited
    [Arguments]  ${dcap_logs_path}
    [Documentation]    When UE3 has added ca with scell 311 and UE4 has added inter ca with scell311 then
    ...                again MaxIncomingLinksStatus should be equal to equal-to-100percent.
    Log to console  Check MaxIncomingLinksStatus
    CB008950.check_MaxIncomingLinksStatus  ${dcap_logs_path}  equal-to-100percent

Verify t186 dcap logs if ext scell addition not limited
    [Arguments]  ${dcap_logs_path}
    ${is_inter_ca}=  CB008950.verify_interca_sa_setup_UE3_CB008950_DB101  ${dcap_logs_path}
    Should Be True      ${is_inter_ca}
    ...  Lack of F1AP: UEContextModificationResponse with pcell 561 and scell 311. Please check logs.

Setup bands DB201
    set mtk bands    UE_3    010000000000010000000000000000000    #n25n41
    set mtk bands    UE_2    000000000000010000000002000000000    #n66n41
    set mtk bands    UE_1    000000000000010000000040000000000    #b2n41n71


Setup bands DB5
    set mtk bands    UE_3    000000000000000000000042000000000    #n66n71
    set mtk bands    UE_2    000000000000010000000002000000000    #n66n41
    set mtk bands    UE_1    010000000000000000000002000000000    #n66n25


Setup bands C and A
    set mtk bands    UE_3    010000000000010000000042000000000    #n25n41n66n71
    set mtk bands    UE_2    010000000000010000000042000000000    #n25n41n66n71
    set mtk bands    UE_1    010000000000010000000042000000000    #n25n41n66n71

Setup deployment mode DB201
    set mtk deployment mode    UE_3    SA
    set mtk deployment mode    UE_2    SA
    set mtk deployment mode    UE_1    NSA

Setup deployment mode DB5 and A
    set mtk deployment mode    UE_3    SA
    set mtk deployment mode    UE_2    SA
    set mtk deployment mode    UE_1    SA

Setup deployment mode C
    set mtk deployment mode    UE_3    NSA
    set mtk deployment mode    UE_2    NSA
    set mtk deployment mode    UE_1    NSA
