*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords in commissioning.robot

Library     OperatingSystem
Library     taf.config.scf          WITH NAME    scf
Resource    ../commissioning.robot
Resource    ../testline.robot
Resource    ../snapshot.robot

Suite Setup  store original scf file
Suite Teardown  run keyword if  '${SUITE_STATUS}' != 'PASS'  perform final commissioning 


*** Test Cases ***

Test Generate Delta Commission
   [TAGS]      COMM
   scf.load scf  ${orig_scf_file}
   ${x2ResetRspTmr}=  scf.get value from scf  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${x2ResetRspTmr}=  evaluate  ${x2ResetRspTmr}+1
   ${x2ResetRspTmr}=  convert to string  ${x2ResetRspTmr}
   ${parameter1}=  create dictionary  value=${x2ResetRspTmr}  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${param_list}=  Create list  ${parameter1}
   ${delta_scf}  Generate Delta Commissioning File  ${orig_scf_file}  ${param_list}
   set suite variable  ${delta_scf}

Test Execute delta commissioning
   [TAGS]      COMM
   Execute delta commissioning  ${delta_scf}  resultDir=/tmp

Test Commission Managed Object List
   [TAGS]      COMM
   ${nrPlmnDn}=    Create Dictionary
   ...     parameterName=nrPlmnDN
   ...     value=
   ...     operation=delete
   ${NRPLMNR_1_params}=   Create List   ${nrPlmnDn}

   ${NRPLMNR_1}=    Create Dictionary
   ...     distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1
   ...     operation=update
   ...     parameters=${NRPLMNR_1_params}

   ${managed_objects}=    Create List    ${NRPLMNR_1}
   Commission Managed Object List    ${managed_objects}

Test Execute full commissioning
   [TAGS]      COMM
   Execute full commissioning  ${orig_scf_file}
   Wait For Minimum Required State For Cell Setup  cell_id=all  ru_id=all   timeout=15min

Test Collect snapshot from gNB
   [TAGS]      SNAPSHOT
    ${target_dir}               testline.Get Testcase Log Directory
    ${snapshot_path}            Collect snapshot from gNB   ${target_dir}
    File Should Exist           ${snapshot_path}
    File Should not be empty    ${snapshot_path}

Test Check If Commissioning Is Needed negative case
   [TAGS]      COMM
   # get actual values from scf file, set same values into param_list
   # expected result: variable ${COMISSIONING_REQUIRED} should be 'False'
   scf.load scf  ${orig_scf_file}
   ${x2ResetRspTmr}=  scf.get value from scf  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${actUlMuMimo}=    scf.get value from scf  dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${actDlMuMimo}=    scf.get value from scf  dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${parameter1}=  create dictionary  value=${x2ResetRspTmr}  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${parameter2}=  create dictionary  value=${actUlMuMimo}   dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${parameter3}=  create dictionary  value=${actDlMuMimo}   dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${param_list}=  Create list  ${parameter1}  ${parameter2}  ${parameter3}
   Check If Commissioning Is Needed  ${param_list}  ${orig_scf_file}
   should be true  ${P_COMISSIONING_REQUIRED} == False

Test Check If Commissioning Is Needed positive case
   [TAGS]      COMM
   # get actual values from scf file, set different values into param_list
   # expected result: variable ${COMISSIONING_REQUIRED} should be 'True'
   scf.load scf  ${orig_scf_file}
   ${x2ResetRspTmr}=  scf.get value from scf  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${x2ResetRspTmr}=  evaluate  ${x2ResetRspTmr}+1
   ${x2ResetRspTmr}=  convert to string  ${x2ResetRspTmr}
   ${parameter1}=  create dictionary  value=${x2ResetRspTmr}  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${parameter2}=  create dictionary  value=Foo   dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${parameter3}=  create dictionary  value=Bar   dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${param_list}=  Create list  ${parameter1}  ${parameter2}  ${parameter3}
   Check If Commissioning Is Needed  ${param_list}  ${orig_scf_file}
   should be true  ${P_COMISSIONING_REQUIRED} == True

*** Keywords ***

store original scf file
   ${scf_file}=  gnb.Get SCF from gNB
   set suite variable  ${orig_scf_file}  ${scf_file} 
perform final commissioning 
  Log to console  \nSuite status: ${SUITE_STATUS}
  Log to console  \nperform commissioning
  Execute full commissioning  ${orig_scf_file}
  
