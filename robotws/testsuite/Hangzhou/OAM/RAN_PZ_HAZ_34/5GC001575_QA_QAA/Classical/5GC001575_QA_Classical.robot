# *** Settings ***
# Documentation     Author: Wang Lixia
# ...               contact: lixia.wang@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : 5GC001575_QA. The parameters in this case list is filtering from NIDD NRBTS5G20B_2009_100/ 1.0.0
# Suite Setup       SetupSuite
# Suite Teardown    TeardownSuite
# Force Tags        RAN_5G  RAN_5G_TDD  CLOUD_5G_CLASSICAL_ASIML_ABIPB1_2xAWHQE_ENB  STATE_SW_UPLOADED  SBTS00  SBTS21B
# ...    PY36
# ...               SBTS22R1
# Resource          Resources/5GC001575_QA_Resources.robot
# Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
# #Variables         ${CFGFILE_ON_GIT}/5GC001575/Delta_SCF.py
# 
# *** Variables ***
# ${OAM_TYPE}                 COAM
# #${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
# #${DeltaPath}                ${CFGFILE_ON_GIT}/5GC001575/Delta_SCF.py
# #${initial_SCF}              ${CFGFILE_ON_GIT}TestLineSCF2Cell_Both.xml
# 
# *** Test Cases ***
# 
# 
# [1.0] 5GC001575_QA_04_CU_and_DU_level_NRCELL_Parameter_Modification_with_Object_Locking_for_Classical_gNB_in_Both_Mode
#     [Documentation]  This case is to verify US5GC001575-QA#B4:NRCELL parameters modification with object locking via explicit
#     ...   activation/deactivation in CU and cell deletion/addition in DU for Classical gNB
#     ...   NRCELL Parameter with ojbeck locking in both CU and DU list:
#     ...          Activate aperiodic CSI reporting,Frequency band Indicator NR,LTE-NR dynamic spectrum sharing mode
#     ...          New Radio System Information Profile distinguished name,Physical cell identifier
#     ...   1) Modify parameter on NRCELL-1 then do activation.
#     ...   2) NRCELL-1 is deactived and activated. Check the NRCELL-2 is still online.
#     ...   3) Check parameter modification is applied in NRCELL-1
#     ...   4) Change parameter back to origical value on NRCELL-1.
#     ...   5) Check NRCELL-1 and NRCELL-2 is online
# 
#     [Tags]    CRT_UTE
#     [Setup]    5GC001575QACommonSetup
#     COAM_WebEM.Login
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate aperiodic CSI reporting    new_value=true
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Frequency band Indicator NR    new_value=40
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=LTE-NR dynamic spectrum sharing mode   new_value=DSS_Phase_3
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=New Radio System Information Profile distinguished name
# #    ...   new_value=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-2
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Physical cell identifier    new_value=130
#     CM_WebEM.ValidateAndActiveParameters
#     COAM_Admin.Login
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     Lock Cell  cell_idx=1
#     TestCase04 restore parameter to original value
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     UNLOCK CELL  cell_idx=1
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     [Teardown]  TestCase04Teardown
# 
# [1][1.0] 5GC001575_QA_05_DU_level_NRCELL_Parameter_Modification_with_Object_Locking_for_Classical_gNB_in_Both_Mode
#     [Documentation]  This case is to test NRCELL parameters to verify US5GC001575-QA#B5: NRCELL or NRCELLGRP parameters modification
#     ...     with object locking with cell deletion/addition in DU for Classical gNB
#     ...   NRCELL Parameters with ojbeck locking DU are more than 100. Test case does not need to cover all,only test several parameters
#     ...   1) Modify parameter on NRCELL-1 then do activation.
#     ...   2) NRCELL-1 is deactived and activated. Check the NRCELL-2 is still online.
#     ...   3) Check parameter modification is applied in NRCELL-1
#     ...   4) Change parameter back to origical value on NRCELL-1.
#     ...   5) Check NRCELL-1 and NRCELL-2 is online
# 
#     [Tags]    CRT_TRUNK    CRT_20B     CRT_21A   CRT_21B    CRT_UTE    CRT_22R1
#     [Setup]    5GC001575QACommonSetup
# #    [Teardown]        KW.Teardown
#     COAM_WebEM.Login
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Uplink DMRS additional position    new_value=Automatic
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO pairing low SINR threshold    new_value=40
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO maximum number of paired UEs   new_value=8
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO pairing intra-cell interference threshold   new_value=0.1
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Zero correlation zone config    new_value=1
#     CM_WebEM.ValidateAndActiveParameters
#     COAM_Admin.Login
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     TestCase05 restore parameter to original value
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     wait until keyword succeeds   15min   10s     Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     [Teardown]  TestCase05Teardown
# 
# [1][1.0]5GC001575_QA_06_DU_level_NRCELLGRP_Parameter_Modification_with_Object_Locking_for_Classical_gNB_in_Both_Mode
#     [Documentation]  This case is to test NRCELLGRP parameters to verify US5GC001575-QA#B5: NRCELL or NRCELLGRP parameters modification
#     ...   with object locking with cell deletion/addition in DU for Classical gNB
#     ...   NRCELLGRP Parameter with ojbeck locking DU list:
#     ...          Activate load based CSI periodicity,Activate NACK/DTX flood detection,
#     ...          Load Based Csi Periodicity increase Threshold,Pucch F2 Max Code Rate
#     ...   0) Precondition: NRCELL-1 is allocated on NRCELLGRP-0. NRCELL-2 is allocated on NRCELLGRP-1
#     ...   1) Modify parameter on NRCELLGRP-0 then do activation.
#     ...   2) NRCELL-1 which allocated on NRCELLGRP-0 is deactived and activated. Check the NRCELL-2 is still online.
#     ...   3) Check parameter modification is applied in NRCELLGRP-0
#     ...   4) Change parameter back to origical value on NRCELLGRP-0
#     ...   5) Check NRCELL-1 and NRCELL-2 is online
# 
#     [Tags]    CRT_UTE
#     [Setup]    5GC001575QACommonSetup
#     COAM_WebEM.Login
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Activate load based CSI periodicity    new_value=true
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Activate NACK/DTX flood detection    new_value=false
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Load Based Csi Periodicity increase Threshold   new_value=75Percent
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Pucch F2 Max Code Rate   new_value=zeroDot25
#     CM_WebEM.ValidateAndActiveParameters
#     COAM_Admin.Login
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     TestCase06 restore parameter to original value
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     [Teardown]  TestCase06Teardown
# 
# [1][1.0]5GC001575_QA_07_DU_level_Online_Parameter_Modification_for_Classical_gNB_in_Both_Mode
#     [Documentation]  This case is to test online parameters to verify US5GC001575-QA#B6: Online parameters modification in DU for Classical gNB
#     ...   There are hundreds DU level parameters tagged as “On-line” modifiable in NIDD CM. Test case is test several parameters.
#     ...   1) Modify online parameters
#     ...   2) Check NRCELL-1 and NRCELL-2 is online
#     ...   3) Change parameter back to origical value
#     ...   4) Check NRCELL-1 and NRCELL-2 is online
# 
#     [Tags]    CRT_UTE
#     [Setup]    5GC001575QACommonSetup
#     COAM_WebEM.Login
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Cell Barred    new_value=barred
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate downlink data and DMRS FDM    new_value=true
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=BLER Target for DL Transmission    new_value=0.2
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Downlink data and DMRS FDM threshold 256QAM MCS   new_value=25
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Delta CQI maximum of DL OLLA   new_value=20
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate downlink PTRS    new_value=true
#     CM_WebEM.ValidateAndActiveParameters
#     COAM_Admin.Login
#     Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     TestCase07 restore parameter to original value
#     Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     [Teardown]  TestCase07Teardown
# 
# 5GC001575_QA_08_CU_level_NRCELL_Parameter_Modification_with_Object_Locking_for_Classical_gNB_in_Both_Mode
#     [Documentation]  This case is to test object locking parameters to verify US5GC001575-QA#B3: NRCELL parameters modification
#     ...   with object locking via explicit cell activation/deactivation in CU for Classical gNB
#     ...   CU-level NRCELL parameters whose Modification attribute is equal to ‘Requires object locking’:
#     ...   mcc,mnc,mncLength under NRCELL/NRRELLTE
#     ...   0) test setup:Add MO and correct parameters of NRCELL-1/NRRELLTE
#     ...   1) modify parameter, Check NRCELL-2 is online
#     ...   3) Change parameter back to origical value
#     ...   4) Check NRCELL-1 and NRCELL-2 is online
# 
#     [Tags]    
#     [Setup]    BtsLog.StartBTSlogCollection
#     gNB.ModifySCF    InputFile=${initial_SCF}
#     ...               OutputFile=${LOG_PATH}/1575_QA08_SCF.xml
#     ...               MOsToAdd=${MOs_TO_ADD_1575_QA_08}
#     ...               ParamterToModify=${PARAMS_TO_MODIFY_1575_QA_08}
#     ...               ListToAdd=${LIST_TO_ADD_1575_QA_08}
# #    GNB.Commissioning   scf_file=1575_QA08_SCF.xml   file_path=${LOG_PATH}
#     gNB.Commission    scf_file=${LOG_PATH}/1575_QA08_SCF.xml    timeout=${2400}
# 
#     COAM_WebEM.Login
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MCC of PLMN ID in Global eNB ID    new_value=263
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MNC of PLMN ID in Global eNB ID    new_value=4
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MNC length of PLMN ID in Global eNB ID    new_value=3
#     CM_WebEM.ValidateAndActiveParameters
#     COAM_Admin.Login
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     TestCase08 restore parameter to original value
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=2    cell_group_idx=1
#     wait until keyword succeeds   15min   10s   Cell Should Be Online    cell_idx=1    cell_group_idx=0
#     [Teardown]  TestCase08Teardown
# 
# 5GC001575_QA_01_Cell_Addition_for_Classical_gNB_in_SA_mode
#     [Documentation]  From cplane sw degsin, cell unlock=cell addition. This case is already in CRT of 5GC000742_B_FDD.robot
#     [Tags]
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
#     COAM_WebEM.Login
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WebEM.Logout
#     Wireshark.StopCapturinglogFromContainer
#     Sleep   5s
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.Disconnect  alias=${ALIAS_ASIK}
# 
# 
# [1]5GC001575_QA_02_Cell_Addition_for_Classical_gNB_in_Both_Mode
#     [Documentation]  From cplane sw degsin, cell unlock=cell addition. This case is already in CRT of 5GC000742_B_FDD.robot
#     [Tags]
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
#     COAM_WebEM.Login
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WebEM.Logout
#     Wireshark.StopCapturinglogFromContainer
#     Sleep   5s
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.Disconnect  alias=${ALIAS_ASIK}
# 
# 
# [1]5GC001575_QA_03_Cell_Deletion_for_Classical_gNB_in_Both_Mode
#     [Documentation]  From cplane sw degsin, cell unlock=cell addition. This case is already in CRT of 5GC000742_B_FDD.robot
#     [Tags]
#     [Setup]    Setup case
#     [Teardown]  Teardown case
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
#     COAM_WebEM.Login
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WEBEM.LockUnlcokCell
#     COAM_WebEM.Logout
#     Wireshark.StopCapturinglogFromContainer
#     Sleep   5s
#     wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#     Conn.Disconnect  alias=${ALIAS_ASIK}
# 
# 
# *** Keywords ***
# TestSetup
#      5GC001575QACommonSetup
# 
# 
# Testteardown
#      run keyword and ignore error     COAM_WebEM.Logout
#      run keyword and ignore error     COAM_Admin.Login
# 
# TestCase04Teardown
#      run keyword if test failed   TestCase04 restore parameter to original value
#      common teardown to collect log
# 
# TestCase05Teardown
#      run keyword if test failed   TestCase05 restore parameter to original value
#      common teardown to collect log
# 
# TestCase06Teardown
#      run keyword if test failed   TestCase06 restore parameter to original value
#      common teardown to collect log
# 
# TestCase07Teardown
#      run keyword if test failed   TestCase07 restore parameter to original value
#      common teardown to collect log
# 
# TestCase08Teardown
#      run keyword if test failed   TestCase08 restore parameter to original value
#      common teardown to collect log
# 
# 
# TestCase04 restore parameter to original value
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate aperiodic CSI reporting    new_value=false
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Frequency band Indicator NR    new_value=78
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=LTE-NR dynamic spectrum sharing mode   new_value=none
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=New Radio System Information Profile distinguished name
#     ...   new_value=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Physical cell identifier    new_value=50
#     CM_WebEM.ValidateAndActiveParameters
# 
# TestCase05 restore parameter to original value
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Uplink DMRS additional position    new_value=One additional DMRS
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO pairing low SINR threshold    new_value=empty
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO maximum number of paired UEs   new_value=8
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=UL MU-MIMO pairing intra-cell interference threshold   new_value=empty
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Zero correlation zone config    new_value=0
#     CM_WebEM.ValidateAndActiveParameters
# 
# TestCase06 restore parameter to original value
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Activate load based CSI periodicity    new_value=false
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Activate NACK/DTX flood detection    new_value=true
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Load Based Csi Periodicity increase Threshold   new_value=50Percent
#     CM_WebEM.ModifyParameter    dist_name=NRCELLGRP-0   filter_param=Pucch F2 Max Code Rate   new_value=zeroDot15
#     CM_WebEM.ValidateAndActiveParameters
# 
# TestCase07 restore parameter to original value
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Cell Barred    new_value=notBarred
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate downlink data and DMRS FDM    new_value=false
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=BLER Target for DL Transmission    new_value=0.1
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Downlink data and DMRS FDM threshold 256QAM MCS   new_value=20
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Delta CQI maximum of DL OLLA   new_value=15
# #    CM_WebEM.ModifyParameter    dist_name=NRCELL-1   filter_param=Activate downlink PTRS    new_value=false
#     CM_WebEM.ValidateAndActiveParameters
# 
# TestCase08 restore parameter to original value
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MCC of PLMN ID in Global eNB ID    new_value=262
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MNC of PLMN ID in Global eNB ID    new_value=3
#     CM_WebEM.ModifyParameter    dist_name=NRCELL-1/NRRELLTE-1   filter_param=MNC length of PLMN ID in Global eNB ID    new_value=2
#     CM_WebEM.ValidateAndActiveParameters
# 
# common teardown to collect log
#    BtsLog.StopBTSlogCollectionandGetlog
# #   run keyword if test failed    gNB.CollectSnapshot
#    run keyword and ignore error     COAM_WebEM.Logout
#    run keyword and ignore error     COAM_Admin.Logout
# 
# 5GC001575QACommonSetup
#    TestCase.Start
# #   ${status}    Run keyword and return status    COAM_WebEM.VerifyAllCellsAreOnline
# #   run keyword if   '${status}'=='False'   gNB.Commission    scf_file=${initial_SCF}    timeout=${2400}
#    wait until keyword succeeds    15min   30s    COAM_WebEM.VerifyAllCellsAreOnline
#    BtsLog.StartBTSlogCollection
# KW.Teardown
#     TestCase.Stop
# #Suite setup for 5GC001575
# #   gNB.Commission    scf_file=${initial_SCF}    timeout=${2400}
# #   wait until keyword succeeds    15min   30s    COAM_WebEM.VerifyAllCellsAreOnline
# 
# Setup case
#     #Start BTSlogs Collection
#     log to console     Case Start
# 
# SetupSuite
#     log to console   SetupSuite
#     run keyword and ignore error    Import Variables      ${CFGFILE_PATH}/5GC001575/Delta_SCF.py
#     Set suite variable    ${initial_SCF}    ${CFGFILE_PATH}TestLineSCF2Cell_Both_1857.xml
#     TestSuilt.Start
#     GNB.FormatBTSID  
# #    gNB.SetLoggingSeverity    LoggingSeverity=trace
# TeardownSuite
#     log to console   TeardownSuite
# 	TestSuilt.Stop
# Teardown case
#     log to console   TeardownCase