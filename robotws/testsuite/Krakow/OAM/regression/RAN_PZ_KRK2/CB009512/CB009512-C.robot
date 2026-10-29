*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB009512
...   author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...   maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Resource   ./resources/keywords.robot

Suite Setup       CB009512 Suite Setup
Suite Teardown    Common suite teardown
Test Setup        CB009512 Test Setup
Test Teardown     CB009512 Postconditions

*** Test Cases ***
[1][1.0] CB009512-C_004_ASiR_ATL_log_Record_Delete_is_Logged
    commissioning.perform_bts_delta_commissioning    delta=${oamtls_off}
    Run Keyword And Ignore Error    Run EMSSIM Command    ne3s_deactivate    alias=asirAC
    AsirWebEM.Clean Browser
    Script to get alarms
    ${path_to_wireshark_file}    Activate EMSSIM
    Collect ATL logs and stop Tcpdump
    ${alt_log}    Pick from Pcap tar OAtS    ${path_to_wireshark_file}
    ${additiontext_delete}    Evaluate    "^SM-1019[,;]There are some ATL logs that are overwritten before uploaded.*$"
    Compare ATL logs    ${alt_log}    ${additiontext_delete}    ASiR_OverWrite_Atl_AutonomousSecurityEvent
    asir.verify_only_allowed_alarms_are_active    allowed_alarms=${ASIR_ALLOWED_ALARMS}

[1][1.0] CB009512-C_005_Optimized_AdditionalText_and_LogRecord_Order_Check
    Sleep    60s    Wait for ASiR WebEM to be available
    ${path_to_wireshark_file}    Activate EMSSIM
    ASiR Selenium Modify Parameter    ASI_9512_Test_Tesla   asiName
    Collect ATL logs and stop Tcpdump

    ${alt_log}    Pick from Pcap Gzip OAtS    ${path_to_wireshark_file}
    ${additionaltext_modify_name}    Evaluate    "^.*SM-1019[,;]Reconfiguration request.*ASI-\\d+.*asiName.*ASI.9512.Test.Tesla.*$"
    Compare ATL logs    ${alt_log}    ${additionaltext_modify_name}    Reconfiguration

    #Modify ASIId
    ${path_to_wireshark_file_1}    Activate EMSSIM
    Set Test Variable    ${new_ASI_id}    123
    ASiR Selenium Modify Parameter    ${new_ASI_id}    asiId
    Wait Until Keyword Succeeds    15x    60s    Check Sbts Cell Status    expected_status_dict=${expected_status_cells}
    Collect ATL logs and stop Tcpdump

    ${alt_log}    Pick from Pcap Gzip OAtS    ${path_to_wireshark_file_1}
    ${additiontext_modify_asiId}  Evaluate  "^.*ASI-${new_ASI_id}.*$"
    Compare ATL logs    ${alt_log}    ${additiontext_modify_asiId}    Reconfiguration

[1][4.0] CB009512-C_008_Logfile_Compliant_with_OAtS2.1_with_ASiR_WebEM_State_Operations
    commissioning.perform_bts_delta_commissioning    delta=${oamtls_off}
    Sleep    60s    Wait for ASiR WebEM to be available
    ${path_to_wireshark_file}    Activate EMSSIM

    #Reset Hub
    asir.reset_hub
    Sleep    2    Waiting for ASIR
    Wait Until Keyword Succeeds    10x    30s    asir.verify_hubmod_status    expected_statuses=${expected_status_unlock_hubmod}
    Wait Until Keyword Succeeds    5x    60s    Check Sbts Cell Status    expected_status_dict=${expected_status_cells}

    #Block pRRH
    asir.block_antenna
    Sleep    2    Waiting for ASIR
    asir.verify_antmod_status    expected_statuses=${expected_status_block_antmod}

    #Unblock pRRH
    asir.unblock_antenna
    Sleep    2    Waiting for ASIR
    asir.verify_antmod_status    expected_statuses=${expected_status_unblock_antmod}
    Wait Until Keyword Succeeds    5x    60s    Check Sbts Cell Status    expected_status_dict=${expected_status_cells}

    #Reset pRRH
    asir.reset_antenna
    Sleep    2    Waiting for ASIR
    asir.verify_antmod_status    expected_statuses=${expected_status_unblock_antmod}
    Wait Until Keyword Succeeds    5x    60s    Check Sbts Cell Status    expected_status_dict=${expected_status_cells}

    Collect ATL logs and stop Tcpdump
    ${alt_log}    Pick from Pcap Gzip OAtS    ${path_to_wireshark_file}

    #Some parameters are not given in the following dictionary because the keyword of Transfer to SCF Comparer has defined the matched rules.
    ${additionaltext_reset_antmod}    Evaluate  "^.*SM-1019[,;]Unit reset request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_reset_antmod_new}    ASiR WebEm State Operations    ${additionaltext_reset_antmod}    UnitReset


    ${additionaltext_reset_hubmod}    Evaluate  "^.*SM-1019[,;]Unit reset request for ASI-\\d+.ASI_R-\\d.HUBMOD_R-\\d$"
    ${compare_dict_reset_hubmod_new}    ASiR WebEm State Operations    ${additionaltext_reset_hubmod}    UnitReset

    ${additionaltext_block_antmod}    Evaluate  "^.*SM-1019[,;]Unit block request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_block_antmod_new}    ASiR WebEm State Operations    ${additionaltext_block_antmod}    UnitBlock

    ${additionaltext_unblock_antmod}    Evaluate  "^.*SM-1019[,;]Unit unblock request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_unblock_new_antmod}    ASiR WebEm State Operations    ${additionaltext_unblock_antmod}    UnitUnblock

    ${list_comparer}    Create List    ${compare_dict_reset_hubmod_new}    ${compare_dict_reset_antmod_new}
    ...                                ${compare_dict_block_antmod_new}    ${compare_dict_unblock_new_antmod}
    ${res}    Atl Log Compare    dict_zip_content=${alt_log}    list_comparer=${list_comparer}
    Should Be Equal As Strings    first=${res}[res]    second=True
    [Teardown]    Common Postconditions

[1][1.0] CB009512-C_010_ASI_ATLlog_Not_Lost_during_Site_Reset_or_SW_Upgrade
    Sleep    60s    Wait for ASiR WebEM to be available
    Run EMSSIM Command  ne3s_activate   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Emss Proxy Clear Events
    Emss Proxy Format Events  events_format=full  bts_id=${bts_id}

    #Modify userLabel for BTS
    AsirWebEM.Set Virtual Enable    virtual_enable=${virtual_enable}
    AsirWebEM.Login
    AsirWebEM.Enter Config Man
    ${select_para_dict_userlabel}  Create Dictionary  para_mo=ASI-${asi_id}/BTS-1  para_abbr=userLabel  value=test
    ${select_para_list_to_modify}  Create List  ${select_para_dict_userlabel}
    AsirWebEM.Modify Parameter  ${select_para_list_to_modify}
    Sleep    2    Waiting for ASIR
    &{dict_res_prevalidate}  AsirWebEM.Prevalidate
    Sleep    2    Waiting for ASIR
    Should Be Equal As Strings   first=${dict_res_prevalidate}[ret]  second=True
    AsirWebEM.Activate
    Run Keyword And Ignore Error  AsirWebEM.Logout
    AsirWebEM.Clean Browser

    Reset Sbts
    Wait Until Keyword Succeeds  15x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    ${path_to_wireshark_file}    Activate EMSSIM
    Collect ATL logs and stop Tcpdump

    ${alt_log}    Pick from Pcap tar OAtS    ${path_to_wireshark_file}
    ${additiontext_modify_userLabel}  Evaluate  "^.*SM-1019[,;]Reconfiguration request.*ASI-\\d+.BTS-1.*userLabel.*test.*$"
    Compare ATL logs    ${alt_log}    ${additiontext_modify_userLabel}    Reconfiguration
