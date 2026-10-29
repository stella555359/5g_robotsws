*** Settings ***
Documentation    :copyright: Nokia
...              :author: Bogusz Biedrzycki, Rafal Kawa
...              :contact: bogusz.biedrzycki@nokia.com, rafal.kawa@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     resources/libraries_instances.robot
Resource     resources/5GC002198_Keywords_and_Variables.robot

Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_ue_mobility

Suite Setup       Run Keywords       Start Default Logging         output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...               AND                Start Multiple Vm Ethernet Interfaces With Different Ips
...                                  if_name_with_ip_list=[eth3:gNB2_X2, 10.0.1.3/24], [eth3:gNB3_X2, 10.0.1.4/24], [eth3:gNB_S1U, 10.0.1.112/24]
...               AND                Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND                Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy.xml
...               AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_2198_A_B5_1.json
...               AND                Trigger Site Reset
...               AND                Check Radios Availability
...               AND                Reach Onair    lua_cfg=${CURDIR}/config/egate_5GC002198_A_B5_1.lua
...               AND                Setup X2 Link    initiator_device=1     complementary_device=3
...               AND                Stop Default Logging     output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords       Stop Default Processes And Gather Logs And Compress Logs
...               AND                Stop Multiple Vm Ethernet Interfaces With Different Ips
...                                  if_name_with_ip_list=[eth3:gNB2_X2, 10.0.1.3/24], [eth3:gNB3_X2, 10.0.1.4/24], [eth3:gNB_S1U, 10.0.1.112/24]
...               AND                Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...               AND                Trigger Site Reset

Test Setup                           Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Run Keywords       Detach Ue    ue_id=${UE_ID}
...               AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_2198_remove_NRREL.json
...               AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_2198_remove_NRADJNRCELL.json
...               AND                Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...               AND                Wait Until Keyword Succeeds  4x   15s  setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
${EXPECTED_NRADJNRCELL_OBJECTID}=    12288
${SUCCESSFUL_HO_REGEXP}=    Proxy \\(eNB 3 cell 1\\) reported successful RA

*** Test Cases ***
5GC002198_A_B5_1_A_Additional_A3_A5_Report_Before_NR_CGI_Report_Reception_New_Unknown_PCI_Is_Stronger_No_SRB3
    [Documentation]    This test case describes the EN-DC gNB behaviour when new A5 measurement report is received while
    ...                gNB is waiting for Measurement Report with NR-CGI during PCI resolution of new unknown Inter Frequency.
    ...                In this test we delay sending NR-CGI and in new A5 measurement report the unkown PCI is stronger by at
    ...                least 2dB from PCI than PCI currently resolved. Previous PCI resolution is interrupted and
    ...                Hand Over towards new cell is executed.
    ...                In Suite Teardown, Stop Default Processes And Gather Logs And Compress Logs is not the last keyword
    ...                because default delta causes reset site which would interrupt collecting logs

    Wait For Next NR RRC Counters Period    cell_id=${SERVING_CELL_ID}    nrpmrnl_id=${NRPMRNL_ID}
    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=${UE_ID}
    Attach Ue To Enb                 ue_id=${UE_ID}
    Start Gnb Addition Procedure     ue=${UE_ID}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Ue Rrc Reconf Param              ue_id=${UE_ID}    if_contains=report_cgi    action=donot_send_NRCGI
    Send Custom Ue Measurement Nr    id=${UE_ID}    meas_id=1    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=${UE_ID}    meas_id=4    event=A5    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=UE${UE_ID}: Hit on RRC Reconfiguration Rule presence=report_cgi delay=0 action=donot_send_NRCGI
    Send Custom Ue Measurement Nr    id=${UE_ID}    meas_id=5    event=A5    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              phycell_id=52    nrsrp_nr=70    pass_regexp=UE${UE_ID}: Successfully reconfigured dual connectivity
    ...                              pass_regexp=Proxy \\(eNB 3 cell 1\\) reported successful RA
    Validate NR CGI Report Counters  cell_id=${SERVING_CELL_ID}    nrpmrnl_id=${NRPMRNL_ID}
    Verify Existing NRREL
    Wait For Object To Exist         object_name=NRADJNRCELL_A-${EXPECTED_NRADJNRCELL_OBJECTID}    moc=NRADJNRCELL_A
    ...                              timeout=${NRREL_OBJECT_CREATION_TIME}
