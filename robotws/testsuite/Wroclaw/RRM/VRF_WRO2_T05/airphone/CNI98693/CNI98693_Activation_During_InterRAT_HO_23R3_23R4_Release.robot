*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Joachim Otto
...              :contact: joachim.otto@nokia.com

Resource     CNI98693_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_interRat.json
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CNI98693_inter_rat.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_interRat.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CNI98693_Activation_During_InterRAT_HO_23R3_23R4_Release
    [Documentation]    This user scenario describes the gNB (23R3 and further release) behaviour where split of fetching
	...     NR container and EUTRA container into two separate RRC messages is introduced during interRAT HO.
	...	If CNI-98693 (NRTBS.actSplitNrEutraUeCapa = True in commissioning file ) is enabled then in first
	...	phase of ICS during UE Capabilities fetching for NR container gNB shall skip adding EUTRA
	...	container into RRC UE Capability Enquiry message. After ICS procedure gNB shall add EUTRA container
	...	in a second RRC UE Capability Enquiry message. 5G_RAN_OP_2887

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Attach Ue And Establish Pdu Session And Send A2 Measurement		ue_id=1   pdu_id=1   gw_id=1   meas_id=1
    Send B2 Measurement
    Verify Tcpdump Log               packet_filter=${UE_CAPABILITY_ENQUIRY}	   number_of_messages=2
    Verify Tcpdump Log               packet_filter=${RAT_TYPE_EUTRA}
    Verify Tcpdump Log               packet_filter=${RAT_TYPE_NR}
    Verify Successfull InterRAT HO

    [Teardown]    Run Keywords      Deregister UE Without Confirmation    ue_id=1
    ...           AND               Add Scout External Execution ID To Reporting Portal
    ...           AND               Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

