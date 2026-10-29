*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC002538/Resources/2538_keyword.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/common_keyword_RRM_SG2.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${scf_path}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${_scf_file_path}    ${scf_path}/commom_9055.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
@{beamset_horizontal}    -51.7    -51.7    51.7    51.7    8.9    8.9    32    32    6.8    6.8    -39.2    -39.2    -6.9    -6.9    -25.5    -25.5
@{beamset_vertical}    86    86    110.6    110.6    106.7    106.7    87.6    87.6    92.6    92.6    96    96    99.4    99.4    103.5    103.5
${pa_value}    25
@{pa_port}    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18
...    19    20    21    22    23    24    25    27    28    29    30    31    32
@{ue_list}    0    1    2    3    4    5    6    7    8    9    10    11    12    13

*** Test Cases ***
CB009055_case
    [Tags]    CB009055    CIT_TRUNK
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_file_path}
    Run Keyword And Continue On Failure    Check for unexpected alarms
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
	MCS Set angle    horizontal_set=@{beamset_horizontal}    vertical_set=@{beamset_vertical}  
	Set Test Variable    ${num}    ${8}
	Multi UE Attach And Send Traffic    num=${num}    send_dl=600M/sec
	Multi UE Attach And Send Traffic For Other Cell    
	...    start_ue=${8}    end_ue=${10}    send_dl=500M/sec
	Multi UE Attach And Send Traffic For Other Cell    
	...    start_ue=${16}    end_ue=${20}    send_dl=500M/sec
	Capture BIP Log and Download By Web
	&{tti_log_path}    Capture TTI log
	Check 9055 TTI Result    file_path=${tti_log_path}[DL]
    [Teardown]    Case Teardown


*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    robot_common_operations.Common Case Setup


Case Teardown
    Comment    Run Keyword And Ignore Error    Recover swconfig file
    Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown


UE Attach For MTU
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${false}    power_reset=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=False
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=1500M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Check DL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

UE Check UL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

MTU Stop traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl    ${ue_mode}=SA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

MTU Stop Ul traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul    ${ue_mode}=SA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

Multi UE Attach And Send Traffic
    [Arguments]    ${send_dl}=1500M/sec    ${send_ul}=200M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For MTU    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send DL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_dl}    send_duration=${send_duration}
		Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_ul}    send_duration=${send_duration}
    END

Multi UE Attach And Send Traffic For Other Cell
    [Arguments]    ${send_dl}=1500M/sec    ${send_ul}=200M/sec    ${send_duration}=3600    ${end_ue}=16
	...    ${start_ue}=8
    FOR    ${ue_no}    IN RANGE    ${start_ue}    ${num}
        UE Attach For MTU    ue_index=${ue_no}
        Run Keyword And Continue On Failure    UE Send DL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_dl}    send_duration=${send_duration}
		Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_ul}    send_duration=${send_duration}
    END

Multi UE Check Tput
    [Arguments]    ${num}=1    ${check_dl}=1400    ${check_ul}=200
    FOR    ${ue_no}    IN RANGE    ${num}
        ${dl_tput}    UE Check DL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${dl_tput}>${check_dl}
		${ul_tput}    UE Check UL Traffic    ue_index=${ue_no}
		Run Keyword And Continue On Failure    Should Be True    ${ul_tput}>${check_ul}
    END

Multi UE Attach And Send UL Traffic
    [Arguments]    ${send_traffic}=260M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For MTU    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_traffic}    send_duration=${send_duration}
        sleep    120s
    END

Multi UE Check UL Tput
    [Arguments]    ${num}=1    ${check_tput}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        ${tput}    UE Check UL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${tput}>${check_tput}
    END

Multi UE Stop traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        MTU Stop traffic    ue_index=${ue_no}
    END

Multi UE Stop UL traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        MTU Stop Ul traffic    ue_index=${ue_no}
        UE Detach For MTU    ue_index=${ue_no}
    END

UE Detach For MTU
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=False

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'


Check 9055 TTI Result
    [Arguments]    ${file_path}    ${physCellId}=physCellId    ${line_header}=dlAllocatedPooledResourcesData
	...    ${subcell0}=activeDlSubcellsList_[0]    ${subcell1}=activeDlSubcellsList_[1]    ${subcell2}=activeDlSubcellsList_[2]
	...    ${subcell3}=activeDlSubcellsList_[3]    ${numprb}=numAllocCellPrbDl    ${maxue}=maxNumPdschUes
	${pci}    get_tti_value    file_path=${file_path}    row_header=${physCellId}    line_header=${line_header}
	${subcell_0}    get_tti_value    file_path=${file_path}    row_header=${subcell0}    line_header=${line_header}
	${subcell_1}    get_tti_value    file_path=${file_path}    row_header=${subcell1}    line_header=${line_header}
	${subcell_2}    get_tti_value    file_path=${file_path}    row_header=${subcell2}    line_header=${line_header}
	${subcell_3}    get_tti_value    file_path=${file_path}    row_header=${subcell3}    line_header=${line_header}
	${numofprb}    get_tti_value    file_path=${file_path}    row_header=${numprb}    line_header=${line_header}
	${numofmaxue}    get_tti_value    file_path=${file_path}    row_header=${maxue}    line_header=${line_header}
	${len}    Get Length    ${pci}
	${total_ue}    Set Variable    ${0}
	FOR    ${index}    IN RANGE    ${len}
	    ${if_cell0_exsit}    Run Keyword And Return Status    Should Be True    ${subcell_0}[${index}]!=${NULL}
		${if_cell1_exsit}    Run Keyword And Return Status    Should Be True    ${subcell_1}[${index}]!=${NULL}
		${if_cell2_exsit}    Run Keyword And Return Status    Should Be True    ${subcell_2}[${index}]!=${NULL}
		${if_cell3_exsit}    Run Keyword And Return Status    Should Be True    ${subcell_3}[${index}]!=${NULL}
		${cell0_value}    Run Keyword And Return Status    Should Be True    ${subcell_0}[${index}]!=${NULL}
		Run Keyword If    ${pci}[${index}]==${236}    Should Be True    
		...    ${if_cell0_exsit}==${if_cell1_exsit}==${if_cell2_exsit}==${if_cell3_exsit}==True
		Run Keyword If    ${pci}[${index}]==${237}    Should Be True    ${if_cell0_exsit}
		Run Keyword If    ${pci}[${index}]==${237}    Should Not Be True    ${if_cell0_exsit}==${if_cell1_exsit}
		Run Keyword If    ${pci}[${index}]==${238}    Should Be True    
		...    ${if_cell0_exsit}==${if_cell1_exsit}==${if_cell2_exsit}==True
		Run Keyword If    ${pci}[${index}]==${238}    Should Not Be True    
		...    ${if_cell0_exsit}==${if_cell1_exsit}==${if_cell2_exsit}==${if_cell3_exsit}==True
		Run Keyword If    ${pci}[${index}]==${236}    Should Be True    ${numofprb}[${index}]==${1092}
		Run Keyword If    ${pci}[${index}]==${237}    Should Be True    ${numofprb}[${index}]==${273}
		Run Keyword If    ${pci}[${index}]==${238}    Should Be True    ${numofprb}[${index}]==${819}
		${total_ue}    Evaluate    ${total_ue}+${numofmaxue}[${index}]
	END
	${ev_ue}    Evaluate    ${len}/3*24
	Should Be True    ${total_ue}==${ev_ue}
