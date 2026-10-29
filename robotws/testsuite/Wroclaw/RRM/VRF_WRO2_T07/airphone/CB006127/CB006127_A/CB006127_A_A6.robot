*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           SBTS00    SBTS23R1    CRT    SBTS23R2    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Michal Fluder, Sebastian Maslak
...              :contact: michal.fluder@nokia.com, sebastian.maslak@nokia.com

Resource    CB006127_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_scfc.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_6127_A6_setup_configuration.json
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_suite_setup_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_fdd_sansa_no_SA_cell_setup.lua

Suite Teardown    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_test_end.xml
...               AND             Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_scfc.xml

*** Variables ***
${UE_ID} =    1
${NRCGI_16386} =    00:00:04:00:20
${SPCELL_CONFIG_CELL_2} =    nr-rrc.spCellConfigCommon_element && nr-rrc.physCellId == ${CELL_2}
${RRC_MESS_TRANSFER}=      x2ap.procedureCode == 35
${SGNB_ADDITION_REQ_WITH_CGI_REPORTING_ENDC} =  ${X2AP_SGNB_ADDITION_REQUEST} && nr-rrc.nr_CGI_Reporting_ENDC == 0
${RRC_RECONFIG_IN_SGNB_MODIFICATION_WITH_CELL_2_TO_REPORT_CGI}=  ${X2AP_SGNB_MODIFICATION_REQUIRED} && nr-rrc.cellForWhichToReportCGI == ${CELL_2}
${NRRRC_RECONF_WITH_SYNC_FOR_CELL_2} =  ${RECONFIGURATION_WITH_SYNC} && ${SPCELL_CONFIG_CELL_2}
${NRRRC_RECONFIGURATION_COMPLETE} =   ${RRC_RECONFIGURATION_COMPLETE}
${NRRRC_MEAS_REPORT} =  ${RRC_MESS_TRANSFER} && nr-rrc.physCellId == ${CELL_1} && ${NRRRC_MCC} && ${NRRRC_MNC}
...                                          && nr-rrc.physCellId == ${CELL_2} && ${RRC_CELL_IDENTITY} == ${NRCGI_16386}

${SA_SETUP_FAILED_FAULT} =    7103
${SA_SETUP_FAILED_ALARM} =    7114

*** Test Cases ***
CB006127_A_A6_NSA_SIB1_inSANSA_cell_which_is_partially_setup
    [Documentation]    This test case verifies the gNB behaviour when UE or gNB have SRB3 capability
    ...                and UE report A5 measurement from second cell of the same gNB which is not exist in NRREL.

    Check If SA Setup Has Failed
    Attach UE To Enb And Gnb    ue_id=${UE_ID}
    Verify UE Supports NRCGI Report
    Send Custom Ue Measurement Nr    id=1     meas_id=2    index=0    nrs_result=125:125:0    event=A5    phycell_id=51
    ...                       nrsrq_nr=125     srsrq_nr=17    pass_regexp=Proxy \\(eNB 2 cell 2\\)
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    &{SECOND_CELL_NRREL}=    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{SECOND_CELL_NRREL}    mcc=311    mnc=489    mncLength=3    gNbId=1    gNbIdLength=22    lcrId=2
    Verify Ngap Messages    packet_filter=${RRC_RECONFIG_IN_SGNB_MODIFICATION_WITH_CELL_2_TO_REPORT_CGI}
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_MODIFICATION_CONFIRM}    number_of_messages=5
    Verify Ngap Messages    packet_filter=${NRRRC_RECONF_WITH_SYNC_FOR_CELL_2}
    Verify Ngap Messages    packet_filter=${NRRRC_RECONFIGURATION_COMPLETE}    number_of_messages=6
    Verify Ngap Messages    packet_filter=${NRRRC_MEAS_REPORT}
    Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Check If SA Setup Has Failed
#    Wait For Fault To Be Up    fault_id=${SA_SETUP_FAILED_FAULT}  timeout=300
    Wait For Alarm To Be Up    alarm_id=${SA_SETUP_FAILED_ALARM}  timeout=300
