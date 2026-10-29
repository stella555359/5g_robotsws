*** Settings ***
Documentation
...		[Author]     		        "Abhishake T"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "01:05:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "RP001201"
...     [Validated_TestLine]        "TL3792"
...		[Procedure]   		        "TRS_Consistency check using delta__Migration Scenario_RP001201"
...     [Precondition]              "ASIM hardware is required"
...     [Config]    	            "GSM IPv6 shoule be configured"
...     [Function_Hash_Tags]        "Abis, IPV6"



variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup  Run Keywords  Suite Setup Preconditions
...  AND  Setup Oamops
Suite Teardown   Run Keywords  Suite Teardown Postconditions
...  AND  Teardown Oamops



*** Test Cases ***
[1.0] TRS_Consistency check using delta__Migration Scenario_RP001201
        Perform Commissioning		scf_file=${basic_config}		verify_bts_status=True
		Sleep   360
		Disable and Enable PacketAbisIPv6 and check BTS status
		Disable and Enable actIpV4BasedPktAbTrs and check BTS status
		Disable FAF for both IPv4 and IPv6 and check BTS status

*** Keywords ***
Disable and Enable PacketAbisIPv6 and check BTS status
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${False}  verify_bts_status=True   timeout=300
		sleep  200
        Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update
		...       value=3792    timeout=600
        sleep  160
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${True}  verify_bts_status=True   timeout=300
        sleep  200
        Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update
		...       value=379    timeout=600
        sleep  160
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300
Disable and Enable actIpV4BasedPktAbTrs and check BTS status
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${False}  verify_bts_status=True   timeout=300
		sleep  200
        Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update
		...       value=3792    timeout=600
        sleep  160
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${True}  verify_bts_status=True   timeout=300
        sleep  200
        Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update
		...       value=379    timeout=600
        sleep  160
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300

Disable FAF for both IPv4 and IPv6 and check BTS status
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${False}  verify_bts_status=True   timeout=300
		sleep  200
        Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update
		...       value=3792    timeout=600
        sleep  160
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300
		Perform Recommissioning        type=param           param_path=FEATGADM-1:actIpV6BasedPktAbTrs     operation=update
		...     value=${False}  verify_bts_status=False    timeout=300
        Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=300