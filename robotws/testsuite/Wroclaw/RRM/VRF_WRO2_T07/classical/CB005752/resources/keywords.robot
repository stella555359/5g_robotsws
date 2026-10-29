*** Settings ***
Documentation
...   author: Patryk Mielcarek
...   contact: patryk.mielcarek@nokia.com
...   This is the ROBOT KEYWORDS file for ASOE L3 Call testing


Library       taf.ue
Library       testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB005752/resources/test_specific_keywords.py
Variables     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB005752/resources/test_specific_keywords.py


*** Variables ***
${traffic_duration}    60s
${downlink_tput}       85Mbits/sec
${uplink_tput}         75Mbits/sec
${protocol}            tcp


*** Keywords ***
[1][1.0] CB005752_A__Commisioning
    Log to Console    Case passed with Prepare Testline in Suite Setup


[1][1.0] CB005752_A__ASOE Recommisioning
    ${original_scf_file}=   setup and check preconditions in scf
    ${removed_cell_scf_file}=   delete_cell_and_cell_dependencies   scf_path=${original_scf_file}
    AdminUtils.perform_commissioning   scf_file=${removed_cell_scf_file}
    AdminUtils.wait_for_all_cells_on_air_state

    [Teardown]   Run Keywords
    ...         AdminUtils.perform_commissioning   scf_file=${original_scf_file}    AND
    ...         AdminUtils.wait_for_all_cells_on_air_state


[1][1.0] CB005752_A__DL_UL_Tput
    Nullify attenuation on all ports
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_sctp_logs.pcap    smod_master=${true}    smod_slave=${true}
    ${cells_info}=      AdminUtils.get_all_cell_ids
    ${num_of_cells}=    Get Length   ${cells_info}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    FOR    ${INDEX}    IN RANGE    1    ${num_of_cells}+1
        Log to console   ${INDEX}
        Wait for all cells on air state
        Log to console   Testing tput with cell ${INDEX}
        lock_other_cells  non_locking_cell=${INDEX}
        BuiltIn.Sleep   100  reason=Waiting for locked cell
        Log to console   Attaching UE...
        Attach Ue    UE_1
        Start and check DL
        Start and check UL
        AdminUtils.unlock_all_cells
    END
    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    [Teardown]   Run Keywords
    ...          AdminUtils.unlock_all_cells                  AND
    ...          Detach UE    UE_1                            AND
    ...          TcpdumpSmod.teardown_tcpdump_on_smod


[1][1.0] CB005752_A__TPUT_Robustness
    Nullify attenuation on all ports
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_sctp_logs.pcap    smod_master=${true}    smod_slave=${true}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    AdminUtils.wait_for_all_cells_on_air_state
    Log to console   Locking other cells...
    lock_other_cells  non_locking_cell=2
    BuiltIn.Sleep   100  reason=Waiting for locked cell
    Log to console   Attaching UE...
    Attach Ue    UE_1
    Start and check DL   duration=1800s   dl_tput=${downlink_tput}   deviation=15%
    Start and check UL   duration=1800s   ul_tput=${uplink_tput}   deviation=15%
    AdminUtils.unlock_all_cells
    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    [Teardown]   Run Keywords
    ...          AdminUtils.unlock_all_cells                  AND
    ...          Detach UE    UE_1                            AND
    ...          TcpdumpSmod.teardown_tcpdump_on_smod


Start and check UL
    [Arguments]   ${duration}=${traffic_duration}   ${ul_tput}=${uplink_tput}   ${protocol}=tcp   ${deviation}=95%
    Log to console   UL starting...
    Start Data Transfer   dt_name=DT_UL           ue_alias=UE_1
    ...                   buffer=4M
    ...                   direction=ul            duration=${duration}
    ...                   throughput=${ul_tput}   protocol=${protocol}
    Check Data Transfer Is Alive  DT_UL
    Log to console  UL started..
    Await Data Transfer Finish  DT_UL
    Log to console  UL finished.
    Verify Average Throughput With Deviation   DT_UL   ${ul_tput}   ${deviation}


Start and check DL
    [Arguments]   ${duration}=${traffic_duration}   ${dl_tput}=${downlink_tput}   ${protocol}=tcp   ${deviation}=95%
    Log to console   DL starting...
    Start Data Transfer   dt_name=DT_DL           ue_alias=UE_1
    ...                   buffer=4M
    ...                   direction=dl            duration=${duration}
    ...                   throughput=${dl_tput}   protocol=${protocol}
    Check Data Transfer Is Alive  DT_DL
    Log to console  DL started..
    Await Data Transfer Finish  DT_DL
    Log to console  DL finished.
    Verify Average Throughput With Deviation   DT_DL   ${dl_tput}   ${deviation}
