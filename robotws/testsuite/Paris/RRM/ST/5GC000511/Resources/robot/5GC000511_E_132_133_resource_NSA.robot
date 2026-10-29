*** Settings ***
Documentation    791 TC AC2FDD AC4FDD AC5TDD AC6TDD Resource file
...              AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...              creation : 20/01/2021
...              update to NSA mode  07/02/2022  Nadine Crasnier  nadine.crasnier@nokia.com
...               21.07.22:  Add test of EDA MNRCA_31823 CAS-263859-Y3Q9 :
...                          _ Add X2 traces and add keyword Perform PreCommissioning For 511-E And EDA in Suite Setup
...                          --> nadine.crasnier@nokia.com
...                          _ Add additional checks for nzp-CSI-RS-ResourceId field in X2AP SgNBAdditionRequestAck
...                          Item1 row1 should be 20 --> samraj.easterraj@nokia.com


Library           taf.analyzer.pcap   WITH NAME   wireshark
Library           taf.analyzer.pmcounter
Library           ../../../resources/pm_analyze.py

Resource          ../../../resources/pm_collection.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
#Resource          ../../../resources_sg_radioPerf/robot/Keywords_UE.robot
Resource     ../../../resources/sg_radio_perf/robot/Logs.robot
Resource          keywords_511_common.robot


*** Keywords ***

511_E_132_133_Suite_Setup
    [Arguments]        ${gnb_index}=0
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=all   gnb=${gnb_index}
    keywords_511_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf
    keywords_511_common.Perform PreCommissioning For 511-E And EDA
    ${MeasPeriod_num}=       Replace String      ${MeasPeriod}       min     ${EMPTY}
    Set Suite Variable              ${MeasPeriod_num}
    # added X2 traces for test of EDA CAS-263859-Y3Q9
	# Stop and Start X2 traces on gNB side
	Logs.Stop gNB X2 traces
	Logs.Start gNB X2 traces    br_id=0
	# Make call and ...
    keywords_511_common.Make Call and ULDL Traffic and Collect Pm files in TestsuiteDir
    ...     gNB=${gNB_id}
    ...     ue_index=${UE_ID}
    ...     ue_capabilities=${capabilities_ms}
    # added for X2 traces for test of EDA CAS-263859-Y3Q9
    # Stop and collect X2 traces on gNB side
	Logs.Stop and collect gNB X2 traces
	...   target_path=${OUTPUTDIR}
    ...   target_filename=tcpdump_X2Traces.pcap
    ...   collect_add_time=30s


511_E_132_133_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000511_E_132
    [Documentation]    The purpose of this test case is to check call establishment after on-line
    ...                modification of parameter sub6_preambleTransMax
    ...
    ...                Test Steps Executions:
    ...                - Perform delta commissioning of the SCF
    ...                - Establish a call with full UL and DL traffic
    ...                - Wait the next PM period
    ...                - Wait the end of the PM period
    ...                - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...                - Check the value of counters M55315C01009 and M55315C03009 with expected value calculated during
    ...                  the measurement period ; for case NSA .
    ...                  DL : Check that value of counter DL_PDCP_VOL_RCV_S1U_QOS_GRP_09 is equal to :
    ...                  100 000 / 8 * 120 = 1 500 000 +/- 5%
    ...                  UL : Check that value of counter UL_PDCP_VOL_SNT_S1U_QOS_GRP_09 is equal to :
    ...                  20 000 / 8 * 120 = 300 000 +/- 5%
    ...                - If the difference is greater than the tolerance , the test fails

    ...                 For EDA CAS-263859-Y3Q9 :
    ...                 In SCF delta commissioning for test 511_E_132 :
    ...                 add change firstRE value from default value (0) to 1 in the SCF
    ...                 In Suite_Setup, add X2 traces
    ...                 In test result: Check in X2 traces that the changing is well done
    ...                 Item1:frequencyDomainAllocation - row1: 20 present in SgNBAdditionRequestAcknowledge


    #Retrieve the PM reports and check the counter value
    ${pi_M55315C01009}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55315C01009       file_name=${PM_FILENAME}
    ${pi_M55315C03009}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55315C03009       file_name=${PM_FILENAME}
    log                 \n DL M55315C01009 = ${pi_M55315C01009}      console=${DEBUG_MODE_CONSOLE}
    log                 UL M55335C03009 = ${pi_M55315C03009}      console=${DEBUG_MODE_CONSOLE}
    should be true      ${pi_M55315C01009} > ${target_D}
    should be true      ${pi_M55315C03009} > ${target_U}

    # added for test of EDA CAS-263859-Y3Q9
    # List all UE_X2AP_ID for which there is a SgNBAdditionRequest
    ${filter_source}     Set Variable    (sctp.data_payload_proto_id == 27) && (x2ap.procedureCode == 27)
    ${list1_UEs}         Look ues in pcap traces     ${OUTPUTDIR}      tcpdump_X2Traces.pcap        X2AP
    ...                         ${filter_source}    -1

    # Check in the S1X2 traces, in the message SgNBAdditionRequestAcknowledge that for nzp-CSI-RS-ResourceId:2 field
    # in Item 1, row1 should be 20 ,
    ${empty_list}        create list     @{EMPTY}
    ${filter_x2}         Set Variable    (x2ap.procedureCode == 27) && (x2ap.UE_X2AP_ID == ${list1_UEs[0]})
    ${check_add_req}            Create List     SgNBAdditionRequest
    ${check_add_req_ack}        Create List     frequencyDomainAllocation: row1
    ...                                         nzp-CSI-RS-ResourceId: 2
    ...                                         row1: 20

    ${x2_checks}                Create List     ${check_add_req}             ${check_add_req_ack}
    ${x2_not_checks}            Create List     ${empty_list}                ${empty_list}
    Check pcap traces      ${OUTPUTDIR}          tcpdump_X2Traces.pcap    X2AP
    ...                        ${filter_x2}      ${x2_checks}    ${x2_not_checks}

    ${x2trace}         Load Pcap file    pcap_file=${OUTPUTDIR}/tcpdump_X2Traces.pcap
    ${value}=           Get Field Value     field_name=nr-rrc.row1
    ${row_value}=    Get From List    ${value}   0
    ${row_val}=    Get From List    ${row_value}   0
    Run Keyword If  ('${row_val}' == '20')    Log To Console     PASS
    ...         ELSE                          FAIL   Item 1-NZP-CSI-RS-Resource-row1: ${row_val} - Should be 20 -- Failed
    Log To Console       Item1:frequencyDomainAllocation - row1: 20 present in SgNBAdditionRequestAcknowledge -- Verified
    Log       Item1:frequencyDomainAllocation - row1: 20 present in SgNBAdditionRequestAcknowledge -- Verified
