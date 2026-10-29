*** Settings ***
Documentation
...		[Author]     	"Monika"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Variables		config

*** Keywords ***



Perform Plain IPv6 configuration
	[Arguments]				${Comm_file}
	Perform Commissioning		scf_file=${Comm_file}		verify_bts_status=False
	Run        sudo ifconfig eth3 inet6 add fc00::1/116


Send Traffic
	[Arguments]				${lua_file}
    Call Start  5g=${lua_file}:data   profile=egress_traffic
    Call Start  5g=${lua_file}:data   profile=ingress_traffic

Stop Traffic
	[Arguments]				${lua_file}
	Call Stop   5g=${lua_file}:data   profile=egress_traffic
    Call Stop   5g=${lua_file}:data   profile=ingress_traffic


Set Bandwidth and Counter class
	${bandwidth}=       Evaluate    random.choice(@{random_bandwidth})    random
    Set Suite Variable      ${bandwidth}       ${bandwidth}
	${BW_utilization}=      Evaluate    (100*${bandwidth})/5000
	Run Keyword If  ${BW_utilization}>=0 and ${BW_utilization}<26						Set reference counter values			100		0		0		0		0		900..1900
	...			ELSE IF 						${BW_utilization}>=26 and ${BW_utilization}<51						Set reference counter values			0		100		0		0		0		1900..2900
	...			ELSE IF 						${BW_utilization}>=51 and ${BW_utilization}<76						Set reference counter values			0		0		100		0		0		2900..3900
	...			ELSE IF 						${BW_utilization}>=76 and ${BW_utilization}<88						Set reference counter values			0		0		0		100		0		3900..4900
	...			ELSE IF 						${BW_utilization}>=88												Set reference counter values			0		0		0		0		100		4900..5500


Set reference counter values
	[Arguments]			${Class1}		${Class2}		${Class3}		${Class4}		${Class5}		${Value}
	Set Suite Variable      ${Class1}                   ${Class1}
    Set Suite Variable      ${Class2}                   ${Class2}
    Set Suite Variable      ${Class3}                   ${Class3}
    Set Suite Variable      ${Class4}                   ${Class4}
    Set Suite Variable      ${Class5}                   ${Class5}
    Set Suite Variable      ${Value_out}        		${Value}
	Set Suite Variable      ${Value_in}        			${Value}
