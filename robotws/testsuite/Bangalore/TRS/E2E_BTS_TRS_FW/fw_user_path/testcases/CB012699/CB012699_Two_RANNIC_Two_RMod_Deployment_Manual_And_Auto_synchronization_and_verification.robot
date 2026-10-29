*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...	    [Procedure]	"The test case is planned to validate Sync"
...	    [Date]		"02-01-25"
...     [Author]        "Eswar"
...	    [QC_Path]	"QC_Path in Test Plan"
...	    [QC_ID]		"CB012699"
...	    [Funtion_Hash_Tags]	"RANNIC"
...   	[Feature_ID]         	"CB012699"
...   	[Validated_TestLine] 	"CRAN-7"


Resource        ${CURDIR}/resources/CB007576_commonkeywords.robot

Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_7576      alias=default   AND     Collect Snapshot
...     dut=vdu_7576  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_7576     alias=default

*** Variables ***
${base_ORAN_SCF}    /home/ute/fw_user_path/config/12699/scf_files/vDU_ORAN_SCF.xml
${WRONG_ORAN_SCF}   /home/ute/Downloads/Configuration_scf_MRBTS-1_DU-11133_BLR_Thor_2cell_TDD_SA1_20250909-0635.xml
${incorrect_vDU}    /home/ute/fw_user_path/config/7576/delta_files/incorrect_vDU.xml
${correct_vDU}      /home/ute/fw_user_path/config/7576/delta_files/correct_vDU.xml


*** Test Cases ***
[1]CB012699_Two_RANNIC_Two_RMod_Deployment_Manual_And_Auto_synchronization_and_verification
    Load SCF    ${base_ORAN_SCF}
    Enabling Rannic ssh
    Reboot Airphone
    Sleep    60
    Login to RANNIC and trigger sync
    Login to RADIO and trigger sync



*** KeyWords ***
Load SCF
    [Arguments]     ${base_scf}
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Commissioning    dut=vdu_7576    scf_file=${base_scf}    timeout=300    alias=default
    Sleep   300
    Teardown Oamops     dut=vdu_7576     alias=default

Reboot Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=sshiphy     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=reboot     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Enabling Rannic ssh
    Setup Oamops    dut=vdu_7576    alias=default   timeout=300
     Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}       new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=default


Login to RANNIC and trigger sync
    Setup Remote Access     remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command      command=${login_to_rannic_via_ssh_SWN}     alias=default
    Sleep   10
    Execute Interactive Remote Command      command=${RANNIC_PASSWORD}      alias=default
    Teardown Remote Access      alias=default
    Trigger Serviceuser Sync   sync_type=L1    timeout=30   dut=vdu_7576     alias=default


Login to RADIO and trigger sync
    Setup Remote Access     remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command      command=${login_to_radio_via_ssh_SWN}     alias=default
    Sleep   10
    Execute Interactive Remote Command      command=${RADIO_PASSWORD}      alias=default
    Teardown Remote Access      alias=default
    Trigger Serviceuser Sync   sync_type=RU    timeout=30   dut=vdu_7576     alias=default