*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup       Run keyword and ignore error    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

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
${subcell_id}    0
${nettpye}    SA+NSA
${power_reset}    fasle
*** Test Cases ***
[1]CB010774-Classical-FDD-A_03_B3_maxNumPagingRecords_verification
     Test case prepare
     SCF Commission to cell on air    scf_name=SCF_${stream}.xml
     loop to modify and check the maxNumPagingRecords
     Attach 2UE for Samsung
	 Triger Paging in Samsung and get L1-L2 BIP
	 Get Paging slot with CB010774
	 Check the paging slot and sfn with CB010774
	 Check MSG1 after paging
	[Teardown]    Test case teardown for Samsung

*** Keywords ***
Test case teardown for Samsung
   robot_common_operations.Common Case Teardown
   CI_interface.Common Case Teardown
   Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
   run keyword if test failed    COAM Save snapshot via rest api
   Run keyword and ignore error   Stop L1-L2 BIP
   Run keyword and ignore error   Detach UE    ue_index=${0}
   Run keyword and ignore error   Detach UE    ue_index=${1}

Get Paging slot with CB010774
     log to console    \n###Get Paging slot with CB010774###
     Get paging SFN and Slot from BIP log
	 set test variable    ${paging_sfn_with}    ${paging_sfn}
	 set test variable    ${paging_slot_with}    ${paging_slot}
     log to console    the paging sfn/slot with CB010774 is ${paging_sfn_with}/${paging_slot_with}
Check the paging slot and sfn with CB010774
     should be true    ${paging_slot_with}[0]==4
	 should be true    ${paging_sfn_with}[0]%2==0

Check MSG1 after paging
     [Arguments]    ${pcap_file_path}=${EXECDIR}/l1l2bip_log/*.pcap
    ${all_packets}=    cap.Load Pcap File    pcap_file=${pcap_file_path}   alias=test
	${filter_expression}=    Catenate    uldata_prachreceiveind
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test
    ${PreambleIndex}=    cap.Get Field Value By Xpath    xpath=.//UlData_detectedPrachPreambles_t.prachPreambleIndex    pcap_parser=test
    should be true     ${PreambleIndex}[0]!=None
	log to console    PreambleIndex is ${PreambleIndex}

Attach 2UE for Samsung
	UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
	Andriod UE adb disable mobile data services    ue_index=${0}
	Andriod UE adb disable mobile data services    ue_index=${1}
	sleep    40s

Triger Paging in Samsung and get L1-L2 BIP
	Start L1-L2 BIP
	log to console     please call
    Make a VoNR call    ue_index=${0}    phone_number=+8613032996558
	Answer VoNR call    ue_index=${1}
	log to console     Stop BIP
	Stop L1-L2 BIP

Online modify "maxNumPagingRecords"
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${100}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Get actual value of "maxNumPagingRecords"
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	FOR    ${i}     IN RANGE   3
	    ${result}=    get_single_value_from_scf_file   dist_name=${MR_NR_CELL_NAME_${i+1}}    parameter=maxNumPagingRecords    connection=GNB_OAM
		...   timeout=20
		should be true    ${result}==${Expected_maxNumPagingRecords_value_TL2077_${x}}[${i}]
	END
loop to modify and check the maxNumPagingRecords
   FOR    ${x}     IN RANGE   2
      set test variable    ${x}
	   Online modify "maxNumPagingRecords"   parameters_to_update=${PARAMETERS_TO_Modify_TL2077_${x}}
       Get actual value of "maxNumPagingRecords"
   END