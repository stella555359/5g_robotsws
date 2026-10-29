*** Settings ***
Force Tags    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Sanjeev Pandey
                 ...              :contact      : sanjeev.pandey@nokia.com
                 ...              :Description  : The scope of this document is to define the trace data of subscriber and
                 ...       equipment trace, cell traffic trace and PCMD data for 5G technology. PCMD reporting is a kind of
                 ...       real-time performance monitoring.



Resource          ./resources/CB013789_keywords2.robot
Library		     taf.sbts.oam.coam.admin
Library          ta5g_cell_operations
Library          ta_pcmd
Resource        ../../../resources/robot/configuration_id.robot
Library        taf.analyzer.pdml


Suite Setup      CB013789 Suite setup
Suite Teardown    CB013789 Suite Teardown

*** Variables ***
${delta_configuration}       ${CURDIR}/config/scf/Delta_Configuration_LessRecords.json
${delta_configuration1}       ${CURDIR}/config/scf/Delta_Configuration_Del.json
${delta_configuration2}       ${CURDIR}/config/scf/Delta_Configuration_Max.json
${delta_configuration3}     ${CURDIR}/config/scf/Delta_Configuration_scf.json

*** Test Cases ***
USCB013789-A_B_C_TC26_Exploratory_Monitoring_PCMD_selected_content_between_gNB-CU-CP_And_gNB-CU-UP_And_gNB_DU_for_SBA


    [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    Run cfg file

    Delta file commissioning for SBA_1
    Check SIB messagges for all cells
    Start DCAP service on the testline
    sleep    30s
    Start Tshark on br-utf_lab_net_2
    sleep    30s
    Start Subscriber trace for UE73 from AMF
    Start PDU Session AND Traffic ON UE-73
    sleep  10s
    Detach1 UEs
    Stop Subscriber trace for UE73 from AMF
    verify vendor_extention_records for DU_OneRecords
    verify vendor_extention_records for CU_UP_OneRecords
    verify vendor_extention_records for CU_CP_OneRecords
    sleep    30s
    Stop Tshark on br-utf_lab_net_2
    Stop DCAP service on the testline
    ta5g_cell_operations.block_all_cells
    sleep    10s
    ta5g_cell_operations.unblock_all_cells
    Delta file commissioning for SBA_Del
    Sleep    30s
    Delta file commissioning for SBA_addation
    sleep    60s
    Start DCAP service on the testline
    sleep    30s
    Start Tshark on br-utf_lab_net
     sleep    30s
     Start Subscriber trace for UE74 from AMF
    Start PDU Session AND Traffic ON UE-74
    sleep  10s
    Detach2 UEs
    Stop Subscriber trace for UE74 from AMF
    verify vendor_extention_records for DU_Records
    verify vendor_extention_records for CU_UP_Records
    verify vendor_extention_records for CU_CP_Records
    sleep    30s
    Stop Tshark on br-utf_lab_net
#    sleep    60s
    ta5g_cell_operations.block_all_cells
    sleep    10s
    ta5g_cell_operations.unblock_all_cells
    Sleep    30s
    Start Tshark on br-utf_lab_net_1
    sleep    30s
    Start Subscriber trace for UE93 from AMF
#    Start Subscriber trace for UE92 from AMF
    Start PDU Session AND Traffic ON UE-93
    sleep    10s
#    Start PDU Session AND Traffic ON UE-92
    Start Subscriber trace for UE94 from AMF
    Start PDU Session AND Traffic ON UE-94
    sleep    10s
    Fetch C-RNTI of all UEs
    Detach all UEs
    Stop Subscriber trace for UE72 from AMF
    Stop Subscriber trace for UE92 from AMF
    sleep     30s
    verify vendor_extention_records for CU_CP_Records_multi-UE
    verify vendor_extention_records for DU_Records_multi-UE
    verify vendor_extention_records for CU_UP_Records_multi-UE
    sleep    10s
    Stop Tshark on br-utf_lab_net_1
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
     ...    AND   Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***


Start Tshark on br-utf_lab_net
      start_tshark   log_filename=CB013789_ABC.pcap    eth_interface=br-utf_lab_net   capture_filter=less 12000   alias=ABC

Start Tshark on br-utf_lab_net_2
      start_tshark   log_filename=CB013789_ABC_2.pcap    eth_interface=br-utf_lab_net   capture_filter=less 12000   alias=Single_ABC

verify no resource for gbr bearer
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.radioNetwork == 25 && s1ap.e_RAB_ID == 6
     ...    number_of_messages=1    alias=resource_check_Deact

Stop Tshark on br-utf_lab_net
     stop_tshark     alias=ABC


verify vendor_extention_records for DU_OneRecords

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.ver_Id == 4
     ...    number_of_messages=1    alias=Single_ABC

verify vendor_extention_records for CU_UP_OneRecords

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 1
     ...    number_of_messages=1    alias=Single_ABC


verify vendor_extention_records for CU_CP_OneRecords
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 12
     ...    number_of_messages=1    alias=Single_ABC



verify vendor_extention_records for DU_Records
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 1
     ...    number_of_messages=1    alias=ABC


     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 3
     ...    number_of_messages=1    alias=ABC



     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 4
     ...    number_of_messages=1    alias=ABC



     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 25
     ...    number_of_messages=1    alias=ABC




 verify vendor_extention_records for CU_UP_Records
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 1
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 3
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 4
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 5
     ...    number_of_messages=0    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 7
     ...    number_of_messages=0    alias=ABC


 verify vendor_extention_records for CU_CP_Records
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 13
     ...    number_of_messages=0    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 14
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18
     ...    number_of_messages=1    alias=ABC
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuVendorExtensionRecordDataType == 10
     ...    number_of_messages=0    alias=ABC

Start Tshark on br-utf_lab_net_1
      start_tshark   log_filename=CB013789_ABC_1.pcap    eth_interface=br-utf_lab_net   capture_filter=less 15000   alias=ABC_multi_ue

Stop Tshark on br-utf_lab_net_1
     stop_tshark     alias=ABC_multi_ue

Stop Tshark on br-utf_lab_net_2
     stop_tshark     alias=Single_ABC

verify vendor_extention_records for CU_CP_Records_multi-UE

    Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1    alias=ABC_multi_ue

    Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 0 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1    alias=ABC_multi_ue


     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 14 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1    alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 14 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1    alias=ABC_multi_ue


     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1    alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.CuVendorExtensionRecordDataType == 18 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1    alias=ABC_multi_ue

    Verify_tshark_for_given_number_of_messages   packet_filter=nsetapx.CuVendorExtensionRecordDataType == 13
     ...    number_of_messages=0    alias=ABC_multi_ue
    Verify_tshark_for_given_number_of_messages   packet_filter=nsetapx.CuVendorExtensionRecordDataType == 10
     ...    number_of_messages=0    alias=ABC_multi_ue



verify vendor_extention_records for CU_UP_Records_multi-UE

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 1
     ...    number_of_messages=2     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 3
     ...    number_of_messages=2    alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 4
     ...    number_of_messages=2    alias=ABC_multi_ue


     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 5
     ...    number_of_messages=0    alias=ABC_multi_ue
     Verify_tshark_for_given_number_of_messages    packet_filter=nsetapx.CuUpVendorExtensionRecordDataType == 7
     ...    number_of_messages=0    alias=ABC_multi_ue


verify vendor_extention_records for DU_Records_multi-UE
     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 1 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 1 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 3 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 3 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 4 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 4 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1     alias=ABC_multi_ue

     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 25 && nsetapx.crnti == ${crnti_93}
     ...    number_of_messages=1     alias=ABC_multi_ue
     Verify_tshark_for_at_least_given_number_of_messages  packet_filter=nsetapx.DuVendorExtensionRecordDataType == 25 && nsetapx.crnti == ${crnti_94}
     ...    number_of_messages=1     alias=ABC_multi_ue






