*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords in commissioning.robot

Library     OperatingSystem
Library     taf.config.scf          WITH NAME    scf
Resource    ../commissioning.robot
Resource    ../testline.robot
Resource    ../snapshot.robot
Resource    ../gnb.robot
Resource    ../scf_checks.robot

Suite Setup      Store Original Scf File
Suite Teardown   Perform Final Commisioning If The Suite Passes


*** Test Cases ***

Test Generate Delta Commission
   [TAGS]      COMM
   scf.Load Scf       ${orig_scf_file}
   ${x2ResetRspTmr}   scf.Get Value From SCF   dist_name=NRBTS-1   p_name=x2ResetRspTmr
   ${x2ResetRspTmr}   Evaluate            ${x2ResetRspTmr} + 1
   ${x2ResetRspTmr}   Convert To String   ${x2ResetRspTmr}
   ${parameter1}      Create Dictionary   value=${x2ResetRspTmr}   dist_name=NRBTS-1   p_name=x2ResetRspTmr
   ${param_list}      Create List   ${parameter1}
   ${delta_scf}       commissioning.Generate Delta Commissioning File   ${orig_scf_file}   ${param_list}
   Set Suite Variable   ${delta_scf}

Test Execute delta commissioning
   [TAGS]      COMM
   commissioning.Execute Delta Commissioning   ${delta_scf}   resultDir=/tmp

Test Commission Managed Object List
   [TAGS]      COMM
   ${nrPlmnDn}   Create Dictionary
   ...   parameterName=nrPlmnDN
   ...   value=
   ...   operation=delete
   ${NRPLMNR_1_params}   Create List   ${nrPlmnDn}

   ${dist_names}   gnb.Get DistNames From Local SCF File   scf_path=${orig_scf_file}
   ...   regex=MRBTS-1/NRBTS-1/NRDRB_QCI-1

   IF   ${{ len(${dist_names})>0 }}
      ${NRPLMNR_1}   Create Dictionary
      ...   distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1
      ...   operation=update
      ...   parameters=${NRPLMNR_1_params}
   ELSE
      ${NRPLMNR_1}   Create Dictionary
      ...   distName=MRBTS-1/NRBTS-1/NRDRB_5QI-1
      ...   operation=update
      ...   parameters=${NRPLMNR_1_params}
   END

   ${managed_objects}   Create List   ${NRPLMNR_1}
   commissioning.Commission Managed Object List    ${managed_objects}

Test Execute full commissioning
   [TAGS]      COMM
   commissioning.Execute Full Commissioning   ${orig_scf_file}
   gnb.Wait For Minimum Required State For Cell Setup   cell_id=all   ru_id=all   timeout=15min

Test Check If Commissioning Is Needed negative case
   [TAGS]      COMM
   # get actual values from scf file, set same values into param_list
   # expected result: variable ${COMISSIONING_REQUIRED} should be 'False'
   scf.Load Scf  ${orig_scf_file}
   ${x2ResetRspTmr}   scf.Get Value From SCF  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${actUlMuMimo}     scf.Get Value From SCF  dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${actDlMuMimo}     scf.Get Value From SCF  dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${parameter1}   Create Dictionary   value=${x2ResetRspTmr}  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${parameter2}   Create Dictionary   value=${actUlMuMimo}   dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${parameter3}   Create Dictionary   value=${actDlMuMimo}   dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${param_list}   Create List         ${parameter1}   ${parameter2}   ${parameter3}
   scf_checks.Check If Commissioning Is Needed         ${param_list}   ${orig_scf_file}
   Should Be True  ${P_COMISSIONING_REQUIRED} == False

Test Check If Commissioning Is Needed positive case
   [TAGS]      COMM
   # get actual values from scf file, set different values into param_list
   # expected result: variable ${COMISSIONING_REQUIRED} should be 'True'
   scf.Load SCF  ${orig_scf_file}
   ${x2ResetRspTmr}   scf.Get Value From SCF  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${x2ResetRspTmr}   Evaluate           ${x2ResetRspTmr} + 1
   ${x2ResetRspTmr}   Convert To String  ${x2ResetRspTmr}
   ${parameter1}   Create Dictionary   value=${x2ResetRspTmr}  dist_name=NRBTS-1  p_name=x2ResetRspTmr
   ${parameter2}   Create Dictionary   value=Foo   dist_name=NRBTS-1/NRCELL-1  p_name=actUlMuMimo
   ${parameter3}   Create Dictionary   value=Bar   dist_name=NRBTS-1/NRCELL-1  p_name=actDlMuMimo
   ${param_list}   Create List         ${parameter1}   ${parameter2}   ${parameter3}
   scf_checks.Check If Commissioning Is Needed  ${param_list}  ${orig_scf_file}
   Should Be True   ${P_COMISSIONING_REQUIRED} == True

Test Collect snapshot from gNB
   [TAGS]      SNAPSHOT
    ${target_dir}               testline.Get Testcase Log Directory
    ${snapshot_path}            snapshot.Collect Snapshot From GNB   ${target_dir}
    OperatingSystem.File Should Exist          ${snapshot_path}
    OperatingSystem.File Should Not Be Empty   ${snapshot_path}

Test Collect IM snapshot from gNB
   [TAGS]      SNAPSHOT
    ${target_dir}               testline.Get Testcase Log Directory
    ${snapshot_path}            snapshot.Collect IM Snapshot From GNB   ${target_dir}
    OperatingSystem.File Should Not Be Empty   ${snapshot_path}

*** Keywords ***

Store Original Scf File
   ${scf_file}          gnb.Get SCF From GNB
   Set Suite Variable   ${orig_scf_file}  ${scf_file}

Perform Final Commissioning
  Log To Console  \nSuite status: ${SUITE_STATUS}
  Log To Console  \nperform commissioning
  commissioning.Execute Full Commissioning  ${orig_scf_file}

Perform Final Commisioning If The Suite Passes
    IF   '${SUITE_STATUS}'!='PASS'   Perform Final Commissioning
