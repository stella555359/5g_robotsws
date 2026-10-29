*** Settings ***
Documentation     [Procedure] "CB007271_DSCP_Modification"
...               [Date] "Date of creation 15-02-2022"
...               [Author] "Vaishnavi"

variables         ta_e2e_bts_trs_fw
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library           SSHLibrary


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops



*** Test Cases ***
[1]CB005750-5G-EAAD_A_4_DSCP Marking modification
   Perform Commissioning       scf_file=${Verification_eesubjectname_SAN}     verify_bts_status=True     timeout=800    alias=default
    Sleep   300
    Get current DSCP value
    Get IPs
    Traffic Capture Start		capture_device=bts		alias=initial_mplane
    BuiltIn.Sleep     120
	${mplane_initial_dscp} = 	Get Parameter		param_path=${mplane_dscp_moc_path}
	${filename}=		Traffic Capture Stop		 capture_device=bts        alias=initial_mplane
	Analyse Pcap 		pcap_filename=${filename}		 analysis=verify_initial_mplane_dscp	filter_file_name=${traffic_filer_file_name}
    Perform Recommissioning         type=param      param_path=${dscp_name}:mPlaneDscp    operation=update        value=43
...     skip_parameter_relation_errors=${True}      timeout=300
   Traffic Capture Start      capture_device=bts      alias=initial_mplane
   BuiltIn.Sleep     240
   Setup Oamops    bts_host=${cmpcrlDN}   alias=initial_mplane
   ${mplane_changed_dscp} =    Get Parameter       param_path=${mplane_dscp_moc_path}
   ${filename}=        Traffic Capture Stop         capture_device=l2_wireshark        alias=initial_mplane
   Analyse Pcap        pcap_filename=${filename}        analysis=verify_initial_mplane_dscp        filter_file_name=${traffic_filer_file_name}


*** Keywords ***
Get current DSCP value
    ${Mplane_DSCP}=     Get Parameter   param_path=${MplaneDSCP_path}

Get IPs
    ${mplane_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}
    Set Suite Variable      ${mplane_ip}        ${mplane_ip}


