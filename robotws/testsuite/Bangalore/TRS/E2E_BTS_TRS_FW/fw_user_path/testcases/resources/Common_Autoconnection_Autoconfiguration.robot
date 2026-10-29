*** Settings ***
Documentation
...            [Author]     "Nandini R"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Library        OperatingSystem
Resource       ${CURDIR}/common_emssim.robot

*** Variables ***
${emssim_conf_file}					/etc/emssim.conf
${emssim_bk_conf_file}				/etc/emssim.conf_bk
${source_file}						/tmp/192.168.255.129_scf.xml
${target_file}						${EXECDIR}/Backup_Commissioning.xml
${primay_target_file}				${EXECDIR}/Intial_Backup_Commissioning.xml
${filename}							CDNL_BTSA_1_3221225472.xml
${gz_file}							CDNL_BTSA_1_3221225472.xml.gz
${ipsec_conf}						${CURDIR}/ipsec_autoconfiguration_vlan_ipv4.conf
${ipsec_Secrets}					${CURDIR}/ipsec_autoconfiguration.secrets
${ipsec_Secrets_v6}					${CURDIR}/ipsec_ipv6_autoconfig.secrets
${cmplan_id}						<cmData id="3221225472" scope="all" type="plan">

${ipsec_cert_new}					${CURDIR}/Autoconn_cert.pem
${ipsec_cacert_new}					${CURDIR}/Autoconn_cacert.pem
${ipsec_privkey_new}				${CURDIR}/Autoconn_PrivateKey.pem
${emssim_server_cert}				${CURDIR}/autoconnection_emssim.pem
${cmp_subject}						CN=AUTOCONN_TLS_TA

${ipsec_Conf_new}					${CURDIR}/Autoconn_ipsec.conf
${ipsec_Conf_new_ipv4_virtual}		${CURDIR}/Autoconn_ipsec_virtual_ipv4.conf
${Primary_cmp}						10.53.187.250
${CMP_Port}							8081
@{connid}							50

${default_ssl}						${CURDIR}/default-ssl.conf

*** Keywords ***
Initial Backup File
    Download BTS_TRS File from eNB
    Copy File   ${source_file}  ${primay_target_file}

Take backup commissioning file
    Download BTS_TRS File from eNB
    Copy File   ${source_file}  ${target_file}

Download BTS_TRS File from eNB
	[Arguments]			${alias}=default
	Generate Scf	target_file=/tmp/192.168.255.129_scf.xml	alias=${alias}

Initial Emssim configuration for Virtual Ipv6
	[Arguments]			${mplane_ipv6_IP}
	Run		sudo cp ${emssim_conf_file} ${emssim_bk_conf_file}
	Run		sudo sed -ie '0,/data_server\ \=\ 10\.0\.1\.1/s/data_server\ \=\ 10\.0\.1\.1/data_server\ \=\ fc00\:\:1/' ${emssim_conf_file}
	Run		sudo sed -i 's/data_server = 10.0.1.1/data_server = fc00::1/g' ${emssim_conf_file}
	Run		sudo sed -i 's/10.0.1.2/${mplane_ipv6_IP}/g' /opt/emssim/proxy/FBOX_Frames.pl
	Run		sudo sed -i 's/10.0.1.2/${mplane_ipv6_IP}/g' /etc/FBOX_Frames.yaml
	Sleep	30
	Reload EMSS
	Sleep	60
	Run		sudo ifconfig eth3 inet6 add fc00::1/114
	Run		sudo ip -6 route add ${mplane_ipv6_IP} via fc00::2 dev eth3

enB build is verified
    Setup Remote Access	remote_device=bts
    ${enb_build}=   Get Sw Version
	${enb_build}=	Get From List	${enb_build}	0
	${trunk_build}=		Run		echo '${enb_build}' | sed 's/FL18A/SBTS00/'
	${trunk_build}=		Run		echo '${trunk_build}' | sed 's/FL18SP/SBTS00/'
	Set Suite Variable		${trunk_build}
    Log To Console      ${enb_build}
	Log To Console      ${trunk_build}
    Teardown Remote Access
    @{active_release}=      Split String From Right     ${enb_build}            _       max_split=2
    Run Keyword If      '${active_release[0]}' == 'SBTS22R3_ENB_0000'      Set Suite Variable      ${sw_ver1}       SBTS22R3_ENB
    Run Keyword If      '${active_release[0]}' == 'SBTS22R4_ENB_9999'      Set Suite Variable      ${sw_ver1}       SBTS00_ENB
    Run Keyword If      '${active_release[0]}' == 'SBTS22R2_ENB_0000'      Set Suite Variable      ${sw_ver1}       SBTS22R2_ENB
    Run Keyword If      '${sw_ver1}' == 'SBTS22R3_ENB'             Set Suite Variable      ${sw_ver}       SBTS22R3
    Run Keyword If      '${sw_ver1}' == 'SBTS22R2_ENB'             Set Suite Variable      ${sw_ver}       SBTS22R2
    Run Keyword If      '${sw_ver1}' == 'SBTS00_ENB'              Set Suite Variable      ${sw_ver}       SBTS00
    Log To Console       ${sw_ver}

Check if software on eNB is '${build_number}'
	Setup Remote Access	remote_device=bts
    	${enb_build} =		Get Sw Version
	${current_build} =	Get From List	${enb_build}	0
	Set Suite Variable	${current_build}	${current_build}
	${build2}=	Replace String	${current_build}	SBTS22R4_ENB_9999	SBTS00_ENB_9999
	${build2}=	Replace String	${build2}	SBTS22R4_ENB_9999	SBTS00_ENB_9999
	Should be Equal	${build_number}	${build2}
	Teardown Remote Access

Initial Emssim configuration for VirtualIP
	[Arguments]			${mplane_IP}
	Run		sudo sed -i 's/10.0.1.2/${mplane_IP}/g' /opt/emssim/proxy/FBOX_Frames.pl
	Run		sudo sed -i 's/10.0.1.2/${mplane_IP}/g' /etc/FBOX_Frames.yaml
	Sleep	30
	Reload EMSS
	Sleep	60
	Run		sudo ip r a ${mplane_IP} via ${Virtual_mplaneIP} dev eth3

Reload EMSS
	Telnet.Open Connection		host=0		port=8061
	Sleep	5
	${out}=		Telnet.Write Bare	reload
	${result}=		Telnet.Read
	Run Keyword And Ignore Error	Should contain		${result}	FBOX_Frames.pl has been reloaded
	Telnet.Close Connection
	Run		sudo /opt/emssim/util/start_fbox.sh restart

Build download for Autoconfiguration
    Run     sed -i 's/<cmData.*>/${cmplan_id}/g' ${target_file}
    Run     sudo cp ${target_file} /home/flexi1/UPLOADS/${filename}
    Run     sudo gzip /home/flexi1/UPLOADS/${filename}
    OperatingSystem.File Should Exist       /home/flexi1/UPLOADS/${filename}.gz
    enB build is verified
	Run     sudo df -kh
	Run Keyword If  '${sw_ver1}'=='SBTS00_ENB'      Download the Trunk build build		ELSE    Download the build
	Sleep	10
    Run     sudo mv /tmp/${build_number}_release_BTSSM_downloadable.zip /home/flexi1/DOWNLOADS/
    Set Suite Variable      ${build_filename}       ${build_number}_release_BTSSM_downloadable.zip

Download the build
	Download Build      ${sw_ver1}      latest      1
	Run     sudo ls -lrth /tmp/SBTS*.zip*

Download the Trunk build build
	Download Build      ${sw_ver1}      latest      1
	Run     sudo ls -lrth /tmp/SBTS*.zip*

Download Build
	[Arguments]    	${release}  ${direction}  ${position}
	${build_number} = 	Run		perl ${CURDIR}/get_build.pl ${release} ${direction} ${position} 2>/tmp/stderr.txt
	Set Suite Variable		${build_file}	/tmp/${build_number}_release_BTSSM_downloadable.zip
	Set Suite Variable		${build_number}		${build_number}
	Run		wget -P /tmp/ http://files.ute.nsn-rdnet.net/builds/enb/base/${build_number}/${build_number}_release_BTSSM_downloadable.zip
#	Run		wget http://files.ute.nsn-rdnet.net/builds/enb/base/${build_number}/${build_number}_release_BTSSM_downloadable.zip

Strongswan configuration for Autoconfiguration VirtualIpv4
    Run     sudo cp ${IPSEC_P12_file} /home/ute/fw_user_path/testcases/resources/
	Run		sudo chmod 777 /etc/ipsec.d/private
	Run		sudo cp ${ipsec_Conf_new_ipv4_virtual} /etc/ipsec.conf
	Run		sudo cp ${ipsec_cacert_new} /etc/ipsec.d/cacerts
	Run		sudo cp ${ipsec_cert_new} /etc/ipsec.d/certs
	Run		sudo cp ${ipsec_privkey_new} /etc/ipsec.d/private
	Run		sudo sed -i "s/accMME_4K3_004-key.pem/Autoconn_PrivateKey.pem/g" /etc/ipsec.secrets
	Run		sudo ipsec restart

TLS certificate configuration
	Run		sudo cp /opt/emssim/proxy/ssl/cacert.pem /opt/emssim/proxy/ssl/cacert_current.pem
	Run		sudo cp /opt/emssim/proxy/ssl/servercert.pem /opt/emssim/proxy/ssl/servercert_current.pem
	Run		sudo cp /opt/emssim/proxy/ssl/serverprivkey.pem /opt/emssim/proxy/ssl/serverprivkey_current.pem

	Run		sudo cp ${ipsec_cacert_new} /opt/emssim/proxy/ssl/cacert.pem
	Run		sudo cp ${emssim_server_cert} /opt/emssim/proxy/ssl/servercert.pem
	Run		sudo cp ${ipsec_privkey_new} /opt/emssim/proxy/ssl/serverprivkey.pem

	Run		sudo cp ${ipsec_cacert_new} /etc/apache2/ssl.crt/cacert.pem
	Run		sudo cp ${emssim_server_cert} /etc/apache2/ssl.crt/servercert.pem
	Run		sudo cp ${ipsec_privkey_new} /etc/apache2/ssl.key/serverprivkey.pem
	Run     sudo chown ute:ute /etc/apache2/ssl.key/serverprivkey.pem

Verify pnpreport for autoconfiguration with IPSEC
	${Ipsecpnpreport}=		Get Pnp Report		output_file_name=pnp_report		timeout=30		alias=default		dut=bts
	${autoconn}=    OperatingSystem.Get File    ${Ipsecpnpreport}     encoding_errors=ignore
	Should Match Regexp		'${autoconn}'		Ike Succeeded
	Should Match Regexp		'${autoconn}'		NMS identification successful
	Should Match Regexp		'${autoconn}'		SW activation success
	Should Match Regexp		'${autoconn}'		Configuration plan activation success
	Should Match Regexp		'${autoconn}'		Autoconfiguration completed

Verify pnpreport for autoconfiguration
	${Ipsecpnpreport}=		Get Pnp Report		output_file_name=pnp_report		timeout=30		alias=default		dut=bts
	${autoconn}=    OperatingSystem.Get File    ${Ipsecpnpreport}     encoding_errors=ignore
	Should Match Regexp		'${autoconn}'		NMS identification successful
	Should Match Regexp		'${autoconn}'		SW activation success
	Should Match Regexp		'${autoconn}'		Configuration plan activation success
	Should Match Regexp		'${autoconn}'		Autoconfiguration completed

Start the fbox logging
#	Run		rm -rf /var/log/emssim/*
	Run     sudo cat /etc/FBOX_Frames.yaml
	Run Emssim Command      slog /home/flexi1/autoconnection_vlan.log
	Run Emssim Command      log on 1
