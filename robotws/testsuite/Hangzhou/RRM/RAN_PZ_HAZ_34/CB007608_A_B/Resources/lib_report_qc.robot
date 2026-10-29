*** Settings ***

#Library         OperatingSystem
#Library         BuiltIn
#Library         SSHLibrary
Library         Process
Library         TaReportingLibrary.py


*** Variables ***


*** Keywords ***




######################
# TEST CASE KEYWORDS #
######################




Set Test Variables
    Set Suite variable      ${TEST_DATA_FILES}    ${CURDIR}/test_data_files
    Set Suite Variable      ${raise_alarm}        ${TEST_DATA_FILES}/alarm.xml
    Set Suite variable      ${SCF_BACKUP}         ${RESULTS}/${ENB_IP}_scf_backup.xml
    Set Test variable       ${ENB_IP}             ${ENB_MPLANE_IP}
    Set Suite variable      ${ENB_ID}
    Set Suite variable      ${NA_HOST}
    Set Suite variable      ${NA_USER}
    Set Suite variable      ${NA_PASS}
    #Set Suite variable      ${na_oracle_sql_ip_addr}
    Set Suite variable      ${ENB_MPLANE_IP}
    Set Suite variable      ${ENB_ROOT_USER}
    Set Suite variable      ${ENB_ROOT_PASS}
    Set Suite variable      ${SRAN}
    Set Suite variable      ${ADMIN}
    Set Suite variable      ${ENB_PC_USER}
    Set Suite variable      ${ENB_PC_PASS}
    Set Suite variable      ${ENB_PC_IP}
    Set Suite variable      ${NETACT_ID}
    set suite variable      ${SW_UPDATE_LOAD}


######################
# Get SW Version KEYWORDS #
######################


Get Active SW Version By SSH
     [Documentation]  This keyword will check active SW version on given ENB_ID and return it;
                   #SSHLibrary.Open Connection  host=10.68.141.148      #if remote ute plesae use enb ip
                   #Run Keyword And Ignore Error  SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
                   Run Keyword And Ignore Error    ssh.Connect to
                   ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
                   ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
                   ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}

                   #@{files}=	    SSHLibrary.List Files In Directory	         /ffs/run   TargetBD*.xml
                    #@{files}=	    OperatingSystem.List Files In Directory	         /ffs/run   TargetBD*.xml

                   ${cmd}=    set variable    ls -ltr /ffs/run/TargetBD*.xml |awk '{print $NF}'|cut -f4 -d'/'

                    ssh.Send Command    command=${cmd}
                     ${files}=    ssh.Read Output
                     ${files}=    strip_string    ${files}

                   #SSHLibrary.Close Connection


                   ssh.Disconnect
                   #${one}=      Get From List  ${files}  0
                   ${active_SW}=  Should Match Regexp   ${files}      TargetBD_(.*).xml
                   [Return]   ${active_SW[1]}

##################
# Report Related KEYWORDS #
##################




Report
    [Arguments]  ${qc_test_name}   ${qc_test_instance_name}   ${test_set}   ${qc_test_lab_path_trunk_airscale}
#                 ...    ${qc_test_lab_path_trunk_airscale}=Test_Sets\\5G20B_MP\\Regression\\SRAN_ENG2_PZ_HZ\\SRAN_ENG2_PZ_HZ_2
#################################################################################################################

##################################################################################################################

     ${build}=  Get Active SW Version By SSH
     ${RP_TEST_LINE_IN_CFG}=  set variable  GVE\_BJS\_TL1991

     Run keyword if  '${TEST_STATUS}'=='PASS'  TaReportingLibrary.report to rp  ${TEST_STATUS}  ${qc_test_name}  ${RP_TEST_LINE_IN_CFG}
	 ...               ${build}  ${test_set}  qc_test_lab_path=${qc_test_lab_path_trunk_airscale}  qc_test_instance_name=${qc_test_instance_name}
