*** Settings ***
Documentation
...     [Author]        "Vaishnavi Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
variables       taf.ul.trs_e2e_fw.lib.oam.oam_interface
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup       Setup Oamops    bts_host=${mplane_ip}   alias=initial_mplane  timeout=1200
Suite Teardown    Teardown Oamops   alias=initial_mplane

***Test Cases***
[1][1.0] 5GC000310_Verify the gNB upgrade by M plane IP login
    precondition
     Get IPs
   Upgrade BTS software to latest software  SBTS00
	Ipconnectivity
*** Keywords ***
precondition
    Perform Commissioning       scf_file=${Coustomer_config_scf}     verify_bts_status=True     timeout=800    alias=initial_mplane
        sleep   300

Get IPs
        ${mplane_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}    alias=initial_mplane
        Set Suite Variable      ${mplane_ip}        ${mplane_ip}


Login Via V4 Ip
	[Arguments]	${ip}
	${mplane}=	Get parameter     param_path=${mplane_ip_moc_path}:localIpAddr      alias=initial_mplane
	Setup Oamops	bts_host=${ip}			timeout=900		alias=initial_mplane
	Traffic Capture Start	  capture_device=bts	alias=initial_mplane	timeout=120
	Traffic Capture Stop    alias=initial_mplane	  alias=initial_mplane


Upgrade BTS software to latest software
    [Arguments]    ${build}
     ${Build_name}=       Run     ls -lrt /tmp| awk /${build}/ | awk 'END{print}' | awk '{print $9}'
     ${build_string}=   Convert to String    ${Build_name}
     Perform Software Download And Update      package=/tmp/${build_string}        activate_sw=true      update_timeout=3600    alias=initial_mplane

Ipconnectivity
        Test Ipconnectivity     remote_address=${iprt_ipv4}    dscp=34     payload_size=16      source_address=${ipif_ipv4}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv4}    dscp=46     payload_size=20      source_address=${ipif_ipv4_cplane}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv4}    dscp=46     payload_size=30      source_address=${ipif_ipv4_uplane}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv4}    dscp=34     payload_size=40      source_address=${ipif_ipv4_nguplane}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv4}    dscp=46    payload_size=50      source_address=${ipif_ipv4_ngcplane}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv6}    dscp=46    payload_size=50      source_address=${ipif_ipv6_cplane}    timeout=30
	...      alias=default
        Test Ipconnectivity     remote_address=${iprt_ipv6}    dscp=46    payload_size=50      source_address=${ipif_ipv6_ngcplane}    timeout=30
	...      alias=default
