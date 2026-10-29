*** Settings ***
#Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
#Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
#Test Setup       Run keyword and ignore error    robot_common_operations.Common Case Setup
#Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    Resources/CB010774_common_keywords.robot
Variables   ./Resources/CB010774_scf_parameters.py

Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: MMW3
...    feature : CB006457

Force Tags    CRT_TRUNK

*** Variables ***
${scf_relative_dir}    commissionings/HGZ

${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${target_file_name}    l1l2bip_log
${subcell_id}    2
${nettpye}    SA+NSA
${power_reset}    fasle
*** Test Cases ***
[1]CB010774-Classical-FDD-B_01_B1_IWK_5GC002063_DSS_Phase_3_Different_bandwidth
    [Documentation]    1)case will check the paging slot with/without CB010774
	...                2)case will run in tl909 which have spark in use
	 Test case prepare
     SCF Commission to cell on air    scf_name=SCF_${stream}.xml
	 Attach 2UE for Spark
	 Triger Paging in Spark and get L1-L2 BIP
	 Get Paging slot with CB010774
	 Check the paging slot and sfn with CB010774
	 Check MSG1 after paging
	[Teardown]    Test case teardown for Spark
[1]CB010774-Classical-FDD-A_03_B3_maxNumPagingRecords_verification
     Test case prepare
     SCF Commission to cell on air    scf_name=SCF_${stream}.xml
     loop to modify and check the maxNumPagingRecords
     Attach 2UE for Spark
	 Triger Paging in Spark and get L1-L2 BIP
	 Get Paging slot with CB010774
	 Check the paging slot and sfn with CB010774
	 Check MSG1 after paging
	[Teardown]    Test case teardown for Spark

*** Keywords ***
Test case teardown for Spark
   Run keyword and ignore error   robot_common_operations.Common Case Teardown
   Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
   run keyword if test failed    COAM Save snapshot via rest api
   Run keyword and ignore error   Stop L1-L2 BIP
   Run keyword and ignore error   power_ue.UE Detach    ue_type=huawei_sigspark    ue_index=${0}
   Run keyword and ignore error   power_ue.UE Detach    ue_type=huawei_sigspark    ue_index=${1}

Get Paging slot with CB010774
     log to console    \n###Get Paging slot with CB010774###
     Get paging SFN and Slot from BIP log
	 set test variable    ${paging_sfn_with}    ${paging_sfn}
	 set test variable    ${paging_slot_with}    ${paging_slot}
     log to console    the paging sfn/slot with CB010774 is ${paging_sfn_with}/${paging_slot_with}
Check the paging slot and sfn with CB010774
     should be true    ${paging_slot_with}[0]==7
	 should be true    ${paging_sfn_with}[0]%2==0

Check MSG1 after paging
     [Arguments]    ${pcap_file_path}=${EXECDIR}/l1l2bip_log/*.pcap
    ${all_packets}=    cap.Load Pcap File    pcap_file=${pcap_file_path}   alias=test
	${filter_expression}=    Catenate    uldata_prachreceiveind
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test
    ${PreambleIndex}=    cap.Get Field Value By Xpath    xpath=.//UlData_detectedPrachPreambles_t.prachPreambleIndex    pcap_parser=test
    should be true     ${PreambleIndex}[0]!=None
	log to console    PreambleIndex is ${PreambleIndex}
Attach 2UE for Spark
    Attach UE for Spark and Verify Attach Result    ue_index=${0}
    Attach UE for Spark and Verify Attach Result    ue_index=${1}
	sleep    40s

Attach UE for Spark and Verify Attach Result
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}   ${log_type}=Aasyslog   ${hwcheck_index}=${1}
    ...   ${ue_index}={0}   ${timeout}=15m   ${5Gstatus}=PASS
    log to console       Require ue ${ue_index}
    Run keyword and ignore error     spark.Require UE   ue_alias=UE_${ue_index}
    ...    get_spark_license=${True}    power_reset=true    index=${ue_index}      ue_num_input=${2}      detach_request=true
    log to console       Attach ue ${ue_index}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
	...                                                                          timeout=${timeout}
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
   ...                                                                          hwcheck_index=${hwcheck_index}
   ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu

    Run keyword and ignore error    spark.Send At Command On Ue    command=AT+CFUN=0    ue_alias=UE_${ue_index}
    Run keyword and ignore error    spark.Send At Command On Ue    command=AT+CFUN=1    ue_alias=UE_${ue_index}
	${status}    run keyword and return status    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${5Gra_l2lo_counter}    before_time=${5Gra_l2lo_timed}    hwcheck_index=${hwcheck_index}    log_type=${log_type}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2lo
    Run keyword if    '${status}'=='False'    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${5Gra_l2hidu_counter}    before_time=${5Gra_l2hidu_timed}    hwcheck_index=${hwcheck_index}    log_type=${log_type}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2hidu
	spark.Get Pdu Ip By AT    ue_alias=UE_${ue_index}
    [Teardown]    Teardown the Aasyslog save progress   gnb_index=${gnb_index}    du_index=${du_index}

Triger Paging in Spark and get L1-L2 BIP
	Start L1-L2 BIP
	log to console     please call
	spark.Send At Command On Ue    command=ATD+8613100012823;    ue_alias=UE_1
    #spark.Send At Command On Ue    command=ATA    ue_alias=UE_0
	log to console     Stop BIP
	Stop L1-L2 BIP

Online modify "maxNumPagingRecords"
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${100}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
Get actual value of "maxNumPagingRecords"
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	FOR    ${i}     IN RANGE   5
	    ${result}=    get_single_value_from_scf_file   dist_name=${MR_NR_CELL_NAME_${i+1}}    parameter=maxNumPagingRecords    connection=GNB_OAM
		...   timeout=20
		should be true    ${result}==${Expected_maxNumPagingRecords_value_${x}}[${i}]
	END
loop to modify and check the maxNumPagingRecords
   FOR    ${x}     IN RANGE   2
      set test variable    ${x}
	   Online modify "maxNumPagingRecords"   parameters_to_update=${PARAMETERS_TO_Modify_${x}}
       Get actual value of "maxNumPagingRecords"
   END