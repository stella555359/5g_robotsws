*** Settings ***

Documentation   **********SW Download & Update to BTS via WebEM/NMS***********
Library    Process
Library    String
Library    SSHLibrary
Library    Collections
Library    OperatingSystem    WITH NAME     os
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.nms.netact    WITH NAME    nms
Library    taf.selenium.sbts    WITH NAME    sbts
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sg04_local_keywords.py
Resource    ./testsuite/Bangalore/ORAN/T08/CNI-145675/Classical_webem/SW_upgradekeywords.robot
Suite Setup       Suite setup
Suite Teardown    Suite teardown

*** Variables ***

${ORU_SW}=    		FJ-RU-ET1---------0202.FGF
${NETACT_NAME}=    	srnclab1042
${NetAct_host}=    	10.43.48.16
${NetAct_uname}=    omc
${NetAct_pwd}=   	Medsql!_1893
${is_TrunkBuild}=   True
${target_build_name}=    SBTS25R2_ENB_0000_000609_000000				#target build info input by user
${source_SBTS_buildname}=    	SBTS25R2_ENB_0000_000606_000001       #source build info input by user
${source_SBTS_buildtype}=    SBTS00               				    #Input by user to identify trunk or branch
${bts_host}=    192.168.255.129
${alias}=       Admin1
${SW_DESTINATION}=	/home/ute/Downloads								#SW download path
${btsusername}=           Nemuadmin
${btspassword}=           nemuuser
${port}=			443
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=        &{authentication}
&{default_user}=    defaultNetconfAccountName=fjncuser0
...                 defaultNetconfAccountPwd=ncCl2fjRu+autH0
${source_SCF}=		${CURDIR}/Config/25R2_SCF
${25R2_SCF_name}=    25R2_SCF.xml
@{fault_list}=             7115    7220    61652    61649    4681    4655    4654    61524
${fdsw_version}=          FDSW25A

*** Test Cases ***
Software upgrade
	Intra-release
    BTS SW upgrade from 25R2 to 25R3
    #BTS SW upgrade from 25R1 to 26R1
    RollbackSW
    # ORU SW Update from WebEM


