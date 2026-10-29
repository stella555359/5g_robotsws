*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[Feature_ID] 		        "CB006557"


variables       ta_e2e_bts_trs_fw
Resource    	/home/ute/fw_user_path/testcases/resources/common_keywords.robot

*** Variables ***
${tc_variables}		testcase_variables.json

*** Keywords ***
Attach UE with operator specific qci and send ul traffic
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=175
    sleep  10


