*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...	    [Procedure]	"The test case is planned to validate RNIC serial numbers"
...	    [Date]		"02-01-25"
...     [Author]        "Eswar"
...	    [QC_Path]	"QC_Path in Test Plan"
...	    [QC_ID]		"CB012699"
...	    [Funtion_Hash_Tags]	"RANNIC"
...   	[Feature_ID]         	"CB012699"
...   	[Validated_TestLine] 	"CRAN-7"




Resource        ${CURDIR}/../resources/common_keywords.robot



*** Variables ***

${base_ORAN_SCF}    /home/ute/fw_user_path/config/12699/scf_files/vDU_ORAN_SCF.xml
${WRONG_ORAN_SCF}   /home/ute/fw_user_path/config/12699/scf_files/wrong_oran_scf.xml
${incorrect_vDU}    /home/ute/fw_user_path/config/12699/delta_files/incorrect_vDU.xml
${correct_vDU}      /home/ute/fw_user_path/config/12699/delta_files/correct_vDU.xml


*** Test Cases ***
[1]CB012699_vDU_RNICMOD_Serial_Number_Verification
    Login vDU
    Perform Commissioning      scf_file=${base_ORAN_SCF}      timeout=300      dut=vdu_7576    alias=default
    Perform Commissioning      scf_file=${WRONG_ORAN_SCF}      timeout=300      dut=vdu_7576    alias=default
    Sleep    120
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm     faultid=4282   severity=critical   should_exist=${True}
	... 	occurrences=1    dut=vdu_7576   alias=default
    Sleep   240
    Perform Commissioning      scf_file=${base_ORAN_SCF}      timeout=300      dut=vdu_7576    alias=default
    Verify Alarm        faultid=4282   severity=critical   should_exist=${False}   occurrences=1    dut=vdu_7576   alias=default
    Logout vDU


*** KeyWords ***

Login vDU
    Setup Oamops    dut=vdu_7576    alias=default

Logout vDU
    Teardown Oamops    dut=vdu_7576    alias=default