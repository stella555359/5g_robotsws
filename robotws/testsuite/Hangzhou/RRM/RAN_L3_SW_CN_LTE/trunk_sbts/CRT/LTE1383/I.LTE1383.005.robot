*** Settings ***
Documentation     I.LTE1383.005:
...               Neighbour relation consolidation during eNB start-up phase
...
...               1. DESCRIPTION
...
...               The purpose of this case is to verify for eNB start-up scenario correct consolidation of neighbour relationships in local eNB in ca
...               se configuration was prepared off-line and a full commissioning is executed. In this case there might be colliding neighbor relatio
...               ns present, which are then automatically removed. Moreover nrStatus flag shall be set correctly for all LNREL objects.
...
...               2. TEST ENVIRONMENT AND SETTINGS
...
...               The test environment consists of real eNB systems (incl. site manager), connected NetAct and real Ue's resp. TM500 test Ue. As core
...               LTE emulator as well as real core can be used. For the RF connection between eNB systems and the Ue's a cabled environment with a
...               remote controlled 8 channel attenuator is used. The LAN network connecting the eNB and the core consists of a LAN switch. It is pos
...               sible to interrupt temporary the IP connection between two ip-addresses (e.g. S1 link or X2 link) with suitable scripts on the LAN
...               switch. For enabled features related licenses are available (if applicable).
...
...               2.1 Testing Tools
...               real UE, TM500
...               LTE core emulator or real core
...               WireShark S1 / X2 tracer
...               BTSLog / EMIL trace tools
...               BTS Site Manager resp. NetAct
...
...               2.2 Test Automation
...               Automated test
...
...               3. DEFINITIONS FROM THE TEST SET
...               n/a
...
...               4. TESTING INSTRUCTIONS
...
...               4.1 Preconditions
...               One eNB system (B) with three LTE cells on air, S1 link to core up and running.
...               Several "fictive" eNB's (A, C, D) are used in description.
...               Special eNB database settings:
...               Static conditions for all instances:
...               - LTE782 feature flag set to false
...               - LTE492 feature flag set to false
...               - ANR dedicated profiles for intra-frequency carrier and for all other carriers used in the test line do exist
...               - Activate also for UE based ANR flag in all ANR dedicated profiles is set to false
...               - Neighbor relation limit intra frequency is set to 16 in all ANR dedicated profiles
...               - Neighbor relation limit inter frequency is set to 2 in ANR dedicated profile for frequency used in cell 1 eNB B
...               - neighbor eNB A has two cells configured with pci1 and pci2
...               - local eNB B has three cells configured with pci3, pci4 and pci5
...               - neighbor eNB C has only one cell configured with pci6
...               - in neighbor eNB D pci7, pci8 and pci9 are used with a different frequency as in all other cells
...               - in local eNB B LNADJ, LNADJL and LNREL objects are not defined
...
...               4.2 Test execution and instances
...
...               An prepared SCF file for local eNB B, which contains several neighbour eNB, neighbour cell and neighbour relation objects,
...               with partly collisions is activated via site manager command line tool.
...               During start-up phase eNB detects collisions and removes these automatically.
...               eNB reaches finally on air status.
...
...               4.3 Postconditions
...
...               LTE cells on air and operational,
...               X2 / S1 links available and in service,
...               no unusual alarm events received by site manager.
...
...               4.4 References
...               [1] SFS MM (Mobility Management)
...               [2] SFS RRM (Radio Resource Management)
...               [3] SFS BM (Bearer Management)
...               [4] SFS UESM (Ue State Management)
...               [5] SFS DPM (Data Path Management)
...               [6] SFS ComSig (Common Signaling Management)
...               [7] SFS SysInfo (System Information Management)
...               [8] SFS RNL O&M (Radio Network Layer Operation & Maintenance)
...
...               5. HISTORY
...               14.12.2012 0.1 Dirk Culemann First Draft
...               29.04.2013 1.0 Dirk Culemann Approved
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DevHZ5_SG4    owner-Chendong.He
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{Delete Neighbour Relation}
...  @{Plmn}
...  @{blacklist}
...  @{default_NR}
...  LNCEL-1/LNCEL_FDD-0:earfcnDL=1500
...  LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...  LNCEL-3/LNCEL_FDD-0:earfcnDL=1650
...  MRBTS-1/LNBTS-1:anrOmExtEnable=false
...  MRBTS-1/LNBTS-1:actUeBasedAnrIntraFreqLte=false
...  MRBTS-1/LNBTS-1:maxNumAnrMoiAllowed=200
...  MRBTS-1/LNBTS-1:maxNumOfLnadjLimit=256
...  MRBTS-1/LNBTS-1:anrOmExtEnable=false
...  MRBTS-1/LNBTS-1:actUeBasedAnrIntraFreqLte=false
...  MRBTS-1/LNBTS-1:maxNumAnrMoiAllowed=200
@{Delete Neighbour Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNADJW.*
...  delete:LNRELW.*
...  delete:LNADJG.*
...  delete:LNRELG.*
@{Plmn}
...  MRBTS-1/LNBTS-1:mcc=244
...  MRBTS-1/LNBTS-1:mnc=9
...  MRBTS-1/LNBTS-1:mncLength=2
...  MRBTS-1/LNBTS-1/LNCEL-1:tac=124
...  MRBTS-1/LNBTS-1/LNCEL-2:tac=124
...  MRBTS-1/LNBTS-1/LNCEL-3:tac=124
@{blacklist}
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=557
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=557
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=557
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=559
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=559
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=559
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=560
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=560
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=560
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=500
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=500
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=500
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=501
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=501
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=501
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mcc=666|enbId=502
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mnc=58|enbId=502
...  MRBTS-1/LNBTS-1/ANR-0:glbNbEnbIdX2LinkBlacklist:mncLength=2|enbId=502
@{LNADJG-0}
...  MRBTS-1/LNBTS-1/LNADJG-0:dtm=false
...  MRBTS-1/LNBTS-1/LNADJG-0:arfcnValueGeran=10
...  MRBTS-1/LNBTS-1/LNADJG-0:bandIndicatorGeran=dcs1800
...  MRBTS-1/LNBTS-1/LNADJG-0:basestationColourCode=1
...  MRBTS-1/LNBTS-1/LNADJG-0:networkColourCode=1
...  MRBTS-1/LNBTS-1/LNADJG-0:networkControlOrder=NC0
...  MRBTS-1/LNBTS-1/LNADJG-0:systemInfoType=none
...  MRBTS-1/LNBTS-1/LNADJG-0:gTargetCi=0
...  MRBTS-1/LNBTS-1/LNADJG-0:gTargetLac=1
...  MRBTS-1/LNBTS-1/LNADJG-0:mcc=262
...  MRBTS-1/LNBTS-1/LNADJG-0:mnc=2
...  MRBTS-1/LNBTS-1/LNADJG-0:mncLength=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:ci=10
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:lac=1
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:nrControl=automatic
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=forbidden
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:plmnId:mcc=262
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:plmnId:mnc=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-1:plmnId:mncLength=2
@{LNADJG-1}
...  MRBTS-1/LNBTS-1/LNADJG-1:dtm=false
...  MRBTS-1/LNBTS-1/LNADJG-1:arfcnValueGeran=20
...  MRBTS-1/LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...  MRBTS-1/LNBTS-1/LNADJG-1:basestationColourCode=2
...  MRBTS-1/LNBTS-1/LNADJG-1:networkColourCode=3
...  MRBTS-1/LNBTS-1/LNADJG-1:networkControlOrder=NC0
...  MRBTS-1/LNBTS-1/LNADJG-1:systemInfoType=none
...  MRBTS-1/LNBTS-1/LNADJG-1:gTargetCi=10
...  MRBTS-1/LNBTS-1/LNADJG-1:gTargetLac=1
...  MRBTS-1/LNBTS-1/LNADJG-1:mcc=262
...  MRBTS-1/LNBTS-1/LNADJG-1:mnc=2
...  MRBTS-1/LNBTS-1/LNADJG-1:mncLength=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:ci=20
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:lac=1
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:nrControl=automatic
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=forbidden
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:plmnId:mcc=262
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:plmnId:mnc=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-2:plmnId:mncLength=2
@{LNADJG-2}
...  MRBTS-1/LNBTS-1/LNADJG-2:dtm=false
...  MRBTS-1/LNBTS-1/LNADJG-2:arfcnValueGeran=30
...  MRBTS-1/LNBTS-1/LNADJG-2:bandIndicatorGeran=dcs1800
...  MRBTS-1/LNBTS-1/LNADJG-2:basestationColourCode=2
...  MRBTS-1/LNBTS-1/LNADJG-2:networkColourCode=2
...  MRBTS-1/LNBTS-1/LNADJG-2:networkControlOrder=NC0
...  MRBTS-1/LNBTS-1/LNADJG-2:systemInfoType=none
...  MRBTS-1/LNBTS-1/LNADJG-2:gTargetCi=20
...  MRBTS-1/LNBTS-1/LNADJG-2:gTargetLac=1
...  MRBTS-1/LNBTS-1/LNADJG-2:mcc=262
...  MRBTS-1/LNBTS-1/LNADJG-2:mnc=2
...  MRBTS-1/LNBTS-1/LNADJG-2:mncLength=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:ci=30
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:eNACCAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:lac=1
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:nrControl=automatic
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:redirWithSysInfoAllowed=forbidden
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:srvccAllowed=allowed
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:plmnId:mcc=262
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:plmnId:mnc=2
...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-3:plmnId:mncLength=2
@{LNADJW_ALL}
...  LNADJW-0:uTargetScFdd=110
...  LNADJW-0:uTargetRncId=1
...  LNADJW-0:uTargetCid=1
...  LNADJW-0:uTargetFreq=10592
...  LNADJW-0:uTargetLac=1
...  LNADJW-0:uTargetRac=1
...  LNADJW-0:srvccHoInd=PSandCS
...  LNADJW-0:primaryPlmnId:mcc=666
...  LNADJW-0:primaryPlmnId:mnc=58
...  LNADJW-0:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-0:nrControl=automatic
...  LNCEL-1/LNRELW-0:psHoAllowed=allowed
...  LNCEL-1/LNRELW-0:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
...  LNCEL-1/LNRELW-0:srvccAllowed=allowed
...  LNCEL-1/LNRELW-0:uTargetCid=1
...  LNCEL-1/LNRELW-0:uTargetRncId=1
...  LNCEL-1/LNRELW-0:utranLbAllowed=false
...  LNCEL-1/LNRELW-0:plmnId:mcc=666
...  LNCEL-1/LNRELW-0:plmnId:mnc=58
...  LNCEL-1/LNRELW-0:plmnId:mncLength=2
...  LNCEL-2/LNRELW-0:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-0:nrControl=automatic
...  LNCEL-2/LNRELW-0:psHoAllowed=allowed
...  LNCEL-2/LNRELW-0:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-0:removeAllowed=true
...  LNCEL-2/LNRELW-0:srvccAllowed=allowed
...  LNCEL-2/LNRELW-0:uTargetCid=1
...  LNCEL-2/LNRELW-0:uTargetRncId=1
...  LNCEL-2/LNRELW-0:utranLbAllowed=false
...  LNCEL-2/LNRELW-0:plmnId:mcc=666
...  LNCEL-2/LNRELW-0:plmnId:mnc=58
...  LNCEL-2/LNRELW-0:plmnId:mncLength=2
...  LNADJW-1:uTargetScFdd=220
...  LNADJW-1:uTargetRncId=1
...  LNADJW-1:uTargetCid=2
...  LNADJW-1:uTargetFreq=10592
...  LNADJW-1:uTargetLac=1
...  LNADJW-1:uTargetRac=1
...  LNADJW-1:srvccHoInd=PSandCS
...  LNADJW-1:primaryPlmnId:mcc=666
...  LNADJW-1:primaryPlmnId:mnc=58
...  LNADJW-1:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-1:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-1:nrControl=automatic
...  LNCEL-1/LNRELW-1:psHoAllowed=allowed
...  LNCEL-1/LNRELW-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-1:removeAllowed=true
...  LNCEL-1/LNRELW-1:srvccAllowed=allowed
...  LNCEL-1/LNRELW-1:uTargetCid=2
...  LNCEL-1/LNRELW-1:uTargetRncId=1
...  LNCEL-1/LNRELW-1:utranLbAllowed=false
...  LNCEL-1/LNRELW-1:plmnId:mcc=666
...  LNCEL-1/LNRELW-1:plmnId:mnc=58
...  LNCEL-1/LNRELW-1:plmnId:mncLength=2
...  LNCEL-2/LNRELW-1:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-1:nrControl=automatic
...  LNCEL-2/LNRELW-1:psHoAllowed=allowed
...  LNCEL-2/LNRELW-1:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-1:removeAllowed=true
...  LNCEL-2/LNRELW-1:srvccAllowed=allowed
...  LNCEL-2/LNRELW-1:uTargetCid=2
...  LNCEL-2/LNRELW-1:uTargetRncId=1
...  LNCEL-2/LNRELW-1:utranLbAllowed=false
...  LNCEL-2/LNRELW-1:plmnId:mcc=666
...  LNCEL-2/LNRELW-1:plmnId:mnc=58
...  LNCEL-2/LNRELW-1:plmnId:mncLength=2
...  LNADJW-2:uTargetScFdd=230
...  LNADJW-2:uTargetRncId=1
...  LNADJW-2:uTargetCid=3
...  LNADJW-2:uTargetFreq=9842
...  LNADJW-2:uTargetLac=2
...  LNADJW-2:uTargetRac=2
...  LNADJW-2:srvccHoInd=PSandCS
...  LNADJW-2:primaryPlmnId:mcc=666
...  LNADJW-2:primaryPlmnId:mnc=58
...  LNADJW-2:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-2:nrControl=automatic
...  LNCEL-1/LNRELW-2:psHoAllowed=allowed
...  LNCEL-1/LNRELW-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-2:removeAllowed=true
...  LNCEL-1/LNRELW-2:srvccAllowed=allowed
...  LNCEL-1/LNRELW-2:uTargetCid=3
...  LNCEL-1/LNRELW-2:uTargetRncId=1
...  LNCEL-1/LNRELW-2:utranLbAllowed=false
...  LNCEL-1/LNRELW-2:plmnId:mcc=666
...  LNCEL-1/LNRELW-2:plmnId:mnc=58
...  LNCEL-1/LNRELW-2:plmnId:mncLength=2
...  LNCEL-2/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-2:nrControl=automatic
...  LNCEL-2/LNRELW-2:psHoAllowed=allowed
...  LNCEL-2/LNRELW-2:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-2:removeAllowed=true
...  LNCEL-2/LNRELW-2:srvccAllowed=allowed
...  LNCEL-2/LNRELW-2:uTargetCid=3
...  LNCEL-2/LNRELW-2:uTargetRncId=1
...  LNCEL-2/LNRELW-2:utranLbAllowed=false
...  LNCEL-2/LNRELW-2:plmnId:mcc=666
...  LNCEL-2/LNRELW-2:plmnId:mnc=58
...  LNCEL-2/LNRELW-2:plmnId:mncLength=2
...  LNADJW-3:uTargetScFdd=340
...  LNADJW-3:uTargetRncId=3
...  LNADJW-3:uTargetCid=4
...  LNADJW-3:uTargetFreq=1192
...  LNADJW-3:uTargetLac=3
...  LNADJW-3:uTargetRac=3
...  LNADJW-3:srvccHoInd=PSandCS
...  LNADJW-3:primaryPlmnId:mcc=666
...  LNADJW-3:primaryPlmnId:mnc=58
...  LNADJW-3:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-3:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-3:nrControl=automatic
...  LNCEL-1/LNRELW-3:psHoAllowed=allowed
...  LNCEL-1/LNRELW-3:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-3:removeAllowed=true
...  LNCEL-1/LNRELW-3:srvccAllowed=allowed
...  LNCEL-1/LNRELW-3:uTargetCid=4
...  LNCEL-1/LNRELW-3:uTargetRncId=3
...  LNCEL-1/LNRELW-3:utranLbAllowed=false
...  LNCEL-1/LNRELW-3:plmnId:mcc=666
...  LNCEL-1/LNRELW-3:plmnId:mnc=58
...  LNCEL-1/LNRELW-3:plmnId:mncLength=2
...  LNCEL-2/LNRELW-3:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-3:nrControl=automatic
...  LNCEL-2/LNRELW-3:psHoAllowed=allowed
...  LNCEL-2/LNRELW-3:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-3:removeAllowed=true
...  LNCEL-2/LNRELW-3:srvccAllowed=allowed
...  LNCEL-2/LNRELW-3:uTargetCid=4
...  LNCEL-2/LNRELW-3:uTargetRncId=3
...  LNCEL-2/LNRELW-3:utranLbAllowed=false
...  LNCEL-2/LNRELW-3:plmnId:mcc=666
...  LNCEL-2/LNRELW-3:plmnId:mnc=58
...  LNCEL-2/LNRELW-3:plmnId:mncLength=2
...  LNADJW-21:srvccHoInd=PSandCS
...  LNADJW-21:uTargetCid=31
...  LNADJW-21:uTargetFreq=9842
...  LNADJW-21:uTargetLac=2
...  LNADJW-21:uTargetRac=2
...  LNADJW-21:uTargetRncId=1
...  LNADJW-21:uTargetScFdd=231
...  LNADJW-21:primaryPlmnId:mcc=666
...  LNADJW-21:primaryPlmnId:mnc=58
...  LNADJW-21:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-4:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-4:nrControl=automatic
...  LNCEL-1/LNRELW-4:psHoAllowed=allowed
...  LNCEL-1/LNRELW-4:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-4:removeAllowed=true
...  LNCEL-1/LNRELW-4:srvccAllowed=allowed
...  LNCEL-1/LNRELW-4:uTargetCid=31
...  LNCEL-1/LNRELW-4:uTargetRncId=1
...  LNCEL-1/LNRELW-4:utranLbAllowed=false
...  LNCEL-1/LNRELW-4:plmnId:mcc=666
...  LNCEL-1/LNRELW-4:plmnId:mnc=58
...  LNCEL-1/LNRELW-4:plmnId:mncLength=2
...  LNADJW-22:srvccHoInd=PSandCS
...  LNADJW-22:uTargetCid=32
...  LNADJW-22:uTargetFreq=9842
...  LNADJW-22:uTargetLac=2
...  LNADJW-22:uTargetRac=2
...  LNADJW-22:uTargetRncId=1
...  LNADJW-22:uTargetScFdd=232
...  LNADJW-22:primaryPlmnId:mcc=666
...  LNADJW-22:primaryPlmnId:mnc=58
...  LNADJW-22:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-5:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-5:nrControl=automatic
...  LNCEL-1/LNRELW-5:psHoAllowed=allowed
...  LNCEL-1/LNRELW-5:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-5:removeAllowed=true
...  LNCEL-1/LNRELW-5:srvccAllowed=allowed
...  LNCEL-1/LNRELW-5:uTargetCid=32
...  LNCEL-1/LNRELW-5:uTargetRncId=1
...  LNCEL-1/LNRELW-5:utranLbAllowed=false
...  LNCEL-1/LNRELW-5:plmnId:mcc=666
...  LNCEL-1/LNRELW-5:plmnId:mnc=58
...  LNCEL-1/LNRELW-5:plmnId:mncLength=2
...  LNADJW-23:srvccHoInd=PSandCS
...  LNADJW-23:uTargetCid=33
...  LNADJW-23:uTargetFreq=9842
...  LNADJW-23:uTargetLac=2
...  LNADJW-23:uTargetRac=2
...  LNADJW-23:uTargetRncId=1
...  LNADJW-23:uTargetScFdd=233
...  LNADJW-23:primaryPlmnId:mcc=666
...  LNADJW-23:primaryPlmnId:mnc=58
...  LNADJW-23:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-6:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-6:nrControl=automatic
...  LNCEL-1/LNRELW-6:psHoAllowed=allowed
...  LNCEL-1/LNRELW-6:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-6:removeAllowed=true
...  LNCEL-1/LNRELW-6:srvccAllowed=allowed
...  LNCEL-1/LNRELW-6:uTargetCid=33
...  LNCEL-1/LNRELW-6:uTargetRncId=1
...  LNCEL-1/LNRELW-6:utranLbAllowed=false
...  LNCEL-1/LNRELW-6:plmnId:mcc=666
...  LNCEL-1/LNRELW-6:plmnId:mnc=58
...  LNCEL-1/LNRELW-6:plmnId:mncLength=2
...  LNADJW-24:srvccHoInd=PSandCS
...  LNADJW-24:uTargetCid=34
...  LNADJW-24:uTargetFreq=9842
...  LNADJW-24:uTargetLac=2
...  LNADJW-24:uTargetRac=2
...  LNADJW-24:uTargetRncId=1
...  LNADJW-24:uTargetScFdd=234
...  LNADJW-24:primaryPlmnId:mcc=666
...  LNADJW-24:primaryPlmnId:mnc=58
...  LNADJW-24:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-7:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-7:nrControl=automatic
...  LNCEL-1/LNRELW-7:psHoAllowed=allowed
...  LNCEL-1/LNRELW-7:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-7:removeAllowed=true
...  LNCEL-1/LNRELW-7:srvccAllowed=allowed
...  LNCEL-1/LNRELW-7:uTargetCid=34
...  LNCEL-1/LNRELW-7:uTargetRncId=1
...  LNCEL-1/LNRELW-7:utranLbAllowed=false
...  LNCEL-1/LNRELW-7:plmnId:mcc=666
...  LNCEL-1/LNRELW-7:plmnId:mnc=58
...  LNCEL-1/LNRELW-7:plmnId:mncLength=2
...  LNADJW-25:srvccHoInd=PSandCS
...  LNADJW-25:uTargetCid=35
...  LNADJW-25:uTargetFreq=9842
...  LNADJW-25:uTargetLac=2
...  LNADJW-25:uTargetRac=2
...  LNADJW-25:uTargetRncId=1
...  LNADJW-25:uTargetScFdd=235
...  LNADJW-25:primaryPlmnId:mcc=666
...  LNADJW-25:primaryPlmnId:mnc=58
...  LNADJW-25:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-8:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-8:nrControl=automatic
...  LNCEL-1/LNRELW-8:psHoAllowed=allowed
...  LNCEL-1/LNRELW-8:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-8:removeAllowed=true
...  LNCEL-1/LNRELW-8:srvccAllowed=allowed
...  LNCEL-1/LNRELW-8:uTargetCid=35
...  LNCEL-1/LNRELW-8:uTargetRncId=1
...  LNCEL-1/LNRELW-8:utranLbAllowed=false
...  LNCEL-1/LNRELW-8:plmnId:mcc=666
...  LNCEL-1/LNRELW-8:plmnId:mnc=58
...  LNCEL-1/LNRELW-8:plmnId:mncLength=2
...  LNADJW-26:srvccHoInd=PSandCS
...  LNADJW-26:uTargetCid=36
...  LNADJW-26:uTargetFreq=9842
...  LNADJW-26:uTargetLac=2
...  LNADJW-26:uTargetRac=2
...  LNADJW-26:uTargetRncId=1
...  LNADJW-26:uTargetScFdd=236
...  LNADJW-26:primaryPlmnId:mcc=666
...  LNADJW-26:primaryPlmnId:mnc=58
...  LNADJW-26:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-9:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-9:nrControl=automatic
...  LNCEL-1/LNRELW-9:psHoAllowed=allowed
...  LNCEL-1/LNRELW-9:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-9:removeAllowed=true
...  LNCEL-1/LNRELW-9:srvccAllowed=allowed
...  LNCEL-1/LNRELW-9:uTargetCid=36
...  LNCEL-1/LNRELW-9:uTargetRncId=1
...  LNCEL-1/LNRELW-9:utranLbAllowed=false
...  LNCEL-1/LNRELW-9:plmnId:mcc=666
...  LNCEL-1/LNRELW-9:plmnId:mnc=58
...  LNCEL-1/LNRELW-9:plmnId:mncLength=2
...  LNADJW-27:srvccHoInd=PSandCS
...  LNADJW-27:uTargetCid=37
...  LNADJW-27:uTargetFreq=9842
...  LNADJW-27:uTargetLac=2
...  LNADJW-27:uTargetRac=2
...  LNADJW-27:uTargetRncId=1
...  LNADJW-27:uTargetScFdd=237
...  LNADJW-27:primaryPlmnId:mcc=666
...  LNADJW-27:primaryPlmnId:mnc=58
...  LNADJW-27:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-10:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-10:nrControl=automatic
...  LNCEL-1/LNRELW-10:psHoAllowed=allowed
...  LNCEL-1/LNRELW-10:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-10:removeAllowed=true
...  LNCEL-1/LNRELW-10:srvccAllowed=allowed
...  LNCEL-1/LNRELW-10:uTargetCid=37
...  LNCEL-1/LNRELW-10:uTargetRncId=1
...  LNCEL-1/LNRELW-10:utranLbAllowed=false
...  LNCEL-1/LNRELW-10:plmnId:mcc=666
...  LNCEL-1/LNRELW-10:plmnId:mnc=58
...  LNCEL-1/LNRELW-10:plmnId:mncLength=2
...  LNADJW-28:srvccHoInd=PSandCS
...  LNADJW-28:uTargetCid=38
...  LNADJW-28:uTargetFreq=9842
...  LNADJW-28:uTargetLac=2
...  LNADJW-28:uTargetRac=2
...  LNADJW-28:uTargetRncId=1
...  LNADJW-28:uTargetScFdd=238
...  LNADJW-28:primaryPlmnId:mcc=666
...  LNADJW-28:primaryPlmnId:mnc=58
...  LNADJW-28:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-11:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-11:nrControl=automatic
...  LNCEL-1/LNRELW-11:psHoAllowed=allowed
...  LNCEL-1/LNRELW-11:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-11:removeAllowed=true
...  LNCEL-1/LNRELW-11:srvccAllowed=allowed
...  LNCEL-1/LNRELW-11:uTargetCid=38
...  LNCEL-1/LNRELW-11:uTargetRncId=1
...  LNCEL-1/LNRELW-11:utranLbAllowed=false
...  LNCEL-1/LNRELW-11:plmnId:mcc=666
...  LNCEL-1/LNRELW-11:plmnId:mnc=58
...  LNCEL-1/LNRELW-11:plmnId:mncLength=2
...  LNADJW-29:srvccHoInd=PSandCS
...  LNADJW-29:uTargetCid=39
...  LNADJW-29:uTargetFreq=9842
...  LNADJW-29:uTargetLac=2
...  LNADJW-29:uTargetRac=2
...  LNADJW-29:uTargetRncId=1
...  LNADJW-29:uTargetScFdd=239
...  LNADJW-29:primaryPlmnId:mcc=666
...  LNADJW-29:primaryPlmnId:mnc=58
...  LNADJW-29:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-12:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-12:nrControl=automatic
...  LNCEL-1/LNRELW-12:psHoAllowed=allowed
...  LNCEL-1/LNRELW-12:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-12:removeAllowed=true
...  LNCEL-1/LNRELW-12:srvccAllowed=allowed
...  LNCEL-1/LNRELW-12:uTargetCid=39
...  LNCEL-1/LNRELW-12:uTargetRncId=1
...  LNCEL-1/LNRELW-12:utranLbAllowed=false
...  LNCEL-1/LNRELW-12:plmnId:mcc=666
...  LNCEL-1/LNRELW-12:plmnId:mnc=58
...  LNCEL-1/LNRELW-12:plmnId:mncLength=2
...  LNADJW-30:srvccHoInd=PSandCS
...  LNADJW-30:uTargetCid=40
...  LNADJW-30:uTargetFreq=9842
...  LNADJW-30:uTargetLac=2
...  LNADJW-30:uTargetRac=2
...  LNADJW-30:uTargetRncId=1
...  LNADJW-30:uTargetScFdd=240
...  LNADJW-30:primaryPlmnId:mcc=666
...  LNADJW-30:primaryPlmnId:mnc=58
...  LNADJW-30:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-13:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-13:nrControl=automatic
...  LNCEL-1/LNRELW-13:psHoAllowed=allowed
...  LNCEL-1/LNRELW-13:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-13:removeAllowed=true
...  LNCEL-1/LNRELW-13:srvccAllowed=allowed
...  LNCEL-1/LNRELW-13:uTargetCid=40
...  LNCEL-1/LNRELW-13:uTargetRncId=1
...  LNCEL-1/LNRELW-13:utranLbAllowed=false
...  LNCEL-1/LNRELW-13:plmnId:mcc=666
...  LNCEL-1/LNRELW-13:plmnId:mnc=58
...  LNCEL-1/LNRELW-13:plmnId:mncLength=2
...  LNADJW-31:srvccHoInd=PSandCS
...  LNADJW-31:uTargetCid=41
...  LNADJW-31:uTargetFreq=9842
...  LNADJW-31:uTargetLac=2
...  LNADJW-31:uTargetRac=2
...  LNADJW-31:uTargetRncId=1
...  LNADJW-31:uTargetScFdd=241
...  LNADJW-31:primaryPlmnId:mcc=666
...  LNADJW-31:primaryPlmnId:mnc=58
...  LNADJW-31:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-14:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-14:nrControl=automatic
...  LNCEL-1/LNRELW-14:psHoAllowed=allowed
...  LNCEL-1/LNRELW-14:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-14:removeAllowed=true
...  LNCEL-1/LNRELW-14:srvccAllowed=allowed
...  LNCEL-1/LNRELW-14:uTargetCid=41
...  LNCEL-1/LNRELW-14:uTargetRncId=1
...  LNCEL-1/LNRELW-14:utranLbAllowed=false
...  LNCEL-1/LNRELW-14:plmnId:mcc=666
...  LNCEL-1/LNRELW-14:plmnId:mnc=58
...  LNCEL-1/LNRELW-14:plmnId:mncLength=2
...  LNADJW-32:srvccHoInd=PSandCS
...  LNADJW-32:uTargetCid=42
...  LNADJW-32:uTargetFreq=9842
...  LNADJW-32:uTargetLac=2
...  LNADJW-32:uTargetRac=2
...  LNADJW-32:uTargetRncId=1
...  LNADJW-32:uTargetScFdd=242
...  LNADJW-32:primaryPlmnId:mcc=666
...  LNADJW-32:primaryPlmnId:mnc=58
...  LNADJW-32:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-15:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-15:nrControl=automatic
...  LNCEL-1/LNRELW-15:psHoAllowed=allowed
...  LNCEL-1/LNRELW-15:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-15:removeAllowed=true
...  LNCEL-1/LNRELW-15:srvccAllowed=allowed
...  LNCEL-1/LNRELW-15:uTargetCid=42
...  LNCEL-1/LNRELW-15:uTargetRncId=1
...  LNCEL-1/LNRELW-15:utranLbAllowed=false
...  LNCEL-1/LNRELW-15:plmnId:mcc=666
...  LNCEL-1/LNRELW-15:plmnId:mnc=58
...  LNCEL-1/LNRELW-15:plmnId:mncLength=2
...  LNADJW-33:srvccHoInd=PSandCS
...  LNADJW-33:uTargetCid=43
...  LNADJW-33:uTargetFreq=9842
...  LNADJW-33:uTargetLac=2
...  LNADJW-33:uTargetRac=2
...  LNADJW-33:uTargetRncId=1
...  LNADJW-33:uTargetScFdd=243
...  LNADJW-33:primaryPlmnId:mcc=666
...  LNADJW-33:primaryPlmnId:mnc=58
...  LNADJW-33:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-16:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-16:nrControl=automatic
...  LNCEL-1/LNRELW-16:psHoAllowed=allowed
...  LNCEL-1/LNRELW-16:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-16:removeAllowed=true
...  LNCEL-1/LNRELW-16:srvccAllowed=allowed
...  LNCEL-1/LNRELW-16:uTargetCid=43
...  LNCEL-1/LNRELW-16:uTargetRncId=1
...  LNCEL-1/LNRELW-16:utranLbAllowed=false
...  LNCEL-1/LNRELW-16:plmnId:mcc=666
...  LNCEL-1/LNRELW-16:plmnId:mnc=58
...  LNCEL-1/LNRELW-16:plmnId:mncLength=2
...  LNADJW-34:srvccHoInd=PSandCS
...  LNADJW-34:uTargetCid=44
...  LNADJW-34:uTargetFreq=9842
...  LNADJW-34:uTargetLac=2
...  LNADJW-34:uTargetRac=2
...  LNADJW-34:uTargetRncId=1
...  LNADJW-34:uTargetScFdd=244
...  LNADJW-34:primaryPlmnId:mcc=666
...  LNADJW-34:primaryPlmnId:mnc=58
...  LNADJW-34:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-17:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-17:nrControl=automatic
...  LNCEL-1/LNRELW-17:psHoAllowed=allowed
...  LNCEL-1/LNRELW-17:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-17:removeAllowed=true
...  LNCEL-1/LNRELW-17:srvccAllowed=allowed
...  LNCEL-1/LNRELW-17:uTargetCid=44
...  LNCEL-1/LNRELW-17:uTargetRncId=1
...  LNCEL-1/LNRELW-17:utranLbAllowed=false
...  LNCEL-1/LNRELW-17:plmnId:mcc=666
...  LNCEL-1/LNRELW-17:plmnId:mnc=58
...  LNCEL-1/LNRELW-17:plmnId:mncLength=2
...  LNADJW-35:srvccHoInd=PSandCS
...  LNADJW-35:uTargetCid=45
...  LNADJW-35:uTargetFreq=9842
...  LNADJW-35:uTargetLac=2
...  LNADJW-35:uTargetRac=2
...  LNADJW-35:uTargetRncId=1
...  LNADJW-35:uTargetScFdd=245
...  LNADJW-35:primaryPlmnId:mcc=666
...  LNADJW-35:primaryPlmnId:mnc=58
...  LNADJW-35:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-18:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-18:nrControl=automatic
...  LNCEL-1/LNRELW-18:psHoAllowed=allowed
...  LNCEL-1/LNRELW-18:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-18:removeAllowed=true
...  LNCEL-1/LNRELW-18:srvccAllowed=allowed
...  LNCEL-1/LNRELW-18:uTargetCid=45
...  LNCEL-1/LNRELW-18:uTargetRncId=1
...  LNCEL-1/LNRELW-18:utranLbAllowed=false
...  LNCEL-1/LNRELW-18:plmnId:mcc=666
...  LNCEL-1/LNRELW-18:plmnId:mnc=58
...  LNCEL-1/LNRELW-18:plmnId:mncLength=2
...  LNADJW-36:srvccHoInd=PSandCS
...  LNADJW-36:uTargetCid=46
...  LNADJW-36:uTargetFreq=9842
...  LNADJW-36:uTargetLac=2
...  LNADJW-36:uTargetRac=2
...  LNADJW-36:uTargetRncId=1
...  LNADJW-36:uTargetScFdd=246
...  LNADJW-36:primaryPlmnId:mcc=666
...  LNADJW-36:primaryPlmnId:mnc=58
...  LNADJW-36:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-19:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-19:nrControl=automatic
...  LNCEL-1/LNRELW-19:psHoAllowed=allowed
...  LNCEL-1/LNRELW-19:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-19:removeAllowed=true
...  LNCEL-1/LNRELW-19:srvccAllowed=allowed
...  LNCEL-1/LNRELW-19:uTargetCid=46
...  LNCEL-1/LNRELW-19:uTargetRncId=1
...  LNCEL-1/LNRELW-19:utranLbAllowed=false
...  LNCEL-1/LNRELW-19:plmnId:mcc=666
...  LNCEL-1/LNRELW-19:plmnId:mnc=58
...  LNCEL-1/LNRELW-19:plmnId:mncLength=2
...  LNADJW-37:srvccHoInd=PSandCS
...  LNADJW-37:uTargetCid=47
...  LNADJW-37:uTargetFreq=9842
...  LNADJW-37:uTargetLac=2
...  LNADJW-37:uTargetRac=2
...  LNADJW-37:uTargetRncId=1
...  LNADJW-37:uTargetScFdd=247
...  LNADJW-37:primaryPlmnId:mcc=666
...  LNADJW-37:primaryPlmnId:mnc=58
...  LNADJW-37:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-20:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-20:nrControl=automatic
...  LNCEL-1/LNRELW-20:psHoAllowed=allowed
...  LNCEL-1/LNRELW-20:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-20:removeAllowed=true
...  LNCEL-1/LNRELW-20:srvccAllowed=allowed
...  LNCEL-1/LNRELW-20:uTargetCid=47
...  LNCEL-1/LNRELW-20:uTargetRncId=1
...  LNCEL-1/LNRELW-20:utranLbAllowed=false
...  LNCEL-1/LNRELW-20:plmnId:mcc=666
...  LNCEL-1/LNRELW-20:plmnId:mnc=58
...  LNCEL-1/LNRELW-20:plmnId:mncLength=2
...  LNADJW-38:srvccHoInd=PSandCS
...  LNADJW-38:uTargetCid=48
...  LNADJW-38:uTargetFreq=9842
...  LNADJW-38:uTargetLac=2
...  LNADJW-38:uTargetRac=2
...  LNADJW-38:uTargetRncId=1
...  LNADJW-38:uTargetScFdd=248
...  LNADJW-38:primaryPlmnId:mcc=666
...  LNADJW-38:primaryPlmnId:mnc=58
...  LNADJW-38:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-21:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-21:nrControl=automatic
...  LNCEL-1/LNRELW-21:psHoAllowed=allowed
...  LNCEL-1/LNRELW-21:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-21:removeAllowed=true
...  LNCEL-1/LNRELW-21:srvccAllowed=allowed
...  LNCEL-1/LNRELW-21:uTargetCid=48
...  LNCEL-1/LNRELW-21:uTargetRncId=1
...  LNCEL-1/LNRELW-21:utranLbAllowed=false
...  LNCEL-1/LNRELW-21:plmnId:mcc=666
...  LNCEL-1/LNRELW-21:plmnId:mnc=58
...  LNCEL-1/LNRELW-21:plmnId:mncLength=2
...  LNADJW-39:srvccHoInd=PSandCS
...  LNADJW-39:uTargetCid=49
...  LNADJW-39:uTargetFreq=9842
...  LNADJW-39:uTargetLac=2
...  LNADJW-39:uTargetRac=2
...  LNADJW-39:uTargetRncId=1
...  LNADJW-39:uTargetScFdd=249
...  LNADJW-39:primaryPlmnId:mcc=666
...  LNADJW-39:primaryPlmnId:mnc=58
...  LNADJW-39:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-22:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-22:nrControl=automatic
...  LNCEL-1/LNRELW-22:psHoAllowed=allowed
...  LNCEL-1/LNRELW-22:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-22:removeAllowed=true
...  LNCEL-1/LNRELW-22:srvccAllowed=allowed
...  LNCEL-1/LNRELW-22:uTargetCid=49
...  LNCEL-1/LNRELW-22:uTargetRncId=1
...  LNCEL-1/LNRELW-22:utranLbAllowed=false
...  LNCEL-1/LNRELW-22:plmnId:mcc=666
...  LNCEL-1/LNRELW-22:plmnId:mnc=58
...  LNCEL-1/LNRELW-22:plmnId:mncLength=2
...  LNADJW-40:srvccHoInd=PSandCS
...  LNADJW-40:uTargetCid=50
...  LNADJW-40:uTargetFreq=9842
...  LNADJW-40:uTargetLac=2
...  LNADJW-40:uTargetRac=2
...  LNADJW-40:uTargetRncId=1
...  LNADJW-40:uTargetScFdd=250
...  LNADJW-40:primaryPlmnId:mcc=666
...  LNADJW-40:primaryPlmnId:mnc=58
...  LNADJW-40:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-23:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-23:nrControl=automatic
...  LNCEL-1/LNRELW-23:psHoAllowed=allowed
...  LNCEL-1/LNRELW-23:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-23:removeAllowed=true
...  LNCEL-1/LNRELW-23:srvccAllowed=allowed
...  LNCEL-1/LNRELW-23:uTargetCid=50
...  LNCEL-1/LNRELW-23:uTargetRncId=1
...  LNCEL-1/LNRELW-23:utranLbAllowed=false
...  LNCEL-1/LNRELW-23:plmnId:mcc=666
...  LNCEL-1/LNRELW-23:plmnId:mnc=58
...  LNCEL-1/LNRELW-23:plmnId:mncLength=2
...  LNADJW-41:srvccHoInd=PSandCS
...  LNADJW-41:uTargetCid=51
...  LNADJW-41:uTargetFreq=9842
...  LNADJW-41:uTargetLac=2
...  LNADJW-41:uTargetRac=2
...  LNADJW-41:uTargetRncId=1
...  LNADJW-41:uTargetScFdd=251
...  LNADJW-41:primaryPlmnId:mcc=666
...  LNADJW-41:primaryPlmnId:mnc=58
...  LNADJW-41:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-24:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-24:nrControl=automatic
...  LNCEL-1/LNRELW-24:psHoAllowed=allowed
...  LNCEL-1/LNRELW-24:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-24:removeAllowed=true
...  LNCEL-1/LNRELW-24:srvccAllowed=allowed
...  LNCEL-1/LNRELW-24:uTargetCid=51
...  LNCEL-1/LNRELW-24:uTargetRncId=1
...  LNCEL-1/LNRELW-24:utranLbAllowed=false
...  LNCEL-1/LNRELW-24:plmnId:mcc=666
...  LNCEL-1/LNRELW-24:plmnId:mnc=58
...  LNCEL-1/LNRELW-24:plmnId:mncLength=2
...  LNADJW-42:srvccHoInd=PSandCS
...  LNADJW-42:uTargetCid=52
...  LNADJW-42:uTargetFreq=9842
...  LNADJW-42:uTargetLac=2
...  LNADJW-42:uTargetRac=2
...  LNADJW-42:uTargetRncId=1
...  LNADJW-42:uTargetScFdd=252
...  LNADJW-42:primaryPlmnId:mcc=666
...  LNADJW-42:primaryPlmnId:mnc=58
...  LNADJW-42:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-25:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-25:nrControl=automatic
...  LNCEL-1/LNRELW-25:psHoAllowed=allowed
...  LNCEL-1/LNRELW-25:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-25:removeAllowed=true
...  LNCEL-1/LNRELW-25:srvccAllowed=allowed
...  LNCEL-1/LNRELW-25:uTargetCid=52
...  LNCEL-1/LNRELW-25:uTargetRncId=1
...  LNCEL-1/LNRELW-25:utranLbAllowed=false
...  LNCEL-1/LNRELW-25:plmnId:mcc=666
...  LNCEL-1/LNRELW-25:plmnId:mnc=58
...  LNCEL-1/LNRELW-25:plmnId:mncLength=2
...  LNADJW-43:srvccHoInd=PSandCS
...  LNADJW-43:uTargetCid=53
...  LNADJW-43:uTargetFreq=9842
...  LNADJW-43:uTargetLac=2
...  LNADJW-43:uTargetRac=2
...  LNADJW-43:uTargetRncId=1
...  LNADJW-43:uTargetScFdd=253
...  LNADJW-43:primaryPlmnId:mcc=666
...  LNADJW-43:primaryPlmnId:mnc=58
...  LNADJW-43:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-26:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-26:nrControl=automatic
...  LNCEL-1/LNRELW-26:psHoAllowed=allowed
...  LNCEL-1/LNRELW-26:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-26:removeAllowed=true
...  LNCEL-1/LNRELW-26:srvccAllowed=allowed
...  LNCEL-1/LNRELW-26:uTargetCid=53
...  LNCEL-1/LNRELW-26:uTargetRncId=1
...  LNCEL-1/LNRELW-26:utranLbAllowed=false
...  LNCEL-1/LNRELW-26:plmnId:mcc=666
...  LNCEL-1/LNRELW-26:plmnId:mnc=58
...  LNCEL-1/LNRELW-26:plmnId:mncLength=2
...  LNADJW-44:srvccHoInd=PSandCS
...  LNADJW-44:uTargetCid=54
...  LNADJW-44:uTargetFreq=9842
...  LNADJW-44:uTargetLac=2
...  LNADJW-44:uTargetRac=2
...  LNADJW-44:uTargetRncId=1
...  LNADJW-44:uTargetScFdd=254
...  LNADJW-44:primaryPlmnId:mcc=666
...  LNADJW-44:primaryPlmnId:mnc=58
...  LNADJW-44:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-27:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-27:nrControl=automatic
...  LNCEL-1/LNRELW-27:psHoAllowed=allowed
...  LNCEL-1/LNRELW-27:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-27:removeAllowed=true
...  LNCEL-1/LNRELW-27:srvccAllowed=allowed
...  LNCEL-1/LNRELW-27:uTargetCid=54
...  LNCEL-1/LNRELW-27:uTargetRncId=1
...  LNCEL-1/LNRELW-27:utranLbAllowed=false
...  LNCEL-1/LNRELW-27:plmnId:mcc=666
...  LNCEL-1/LNRELW-27:plmnId:mnc=58
...  LNCEL-1/LNRELW-27:plmnId:mncLength=2
...  LNADJW-45:srvccHoInd=PSandCS
...  LNADJW-45:uTargetCid=55
...  LNADJW-45:uTargetFreq=9842
...  LNADJW-45:uTargetLac=2
...  LNADJW-45:uTargetRac=2
...  LNADJW-45:uTargetRncId=1
...  LNADJW-45:uTargetScFdd=255
...  LNADJW-45:primaryPlmnId:mcc=666
...  LNADJW-45:primaryPlmnId:mnc=58
...  LNADJW-45:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-28:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-28:nrControl=automatic
...  LNCEL-1/LNRELW-28:psHoAllowed=allowed
...  LNCEL-1/LNRELW-28:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-28:removeAllowed=true
...  LNCEL-1/LNRELW-28:srvccAllowed=allowed
...  LNCEL-1/LNRELW-28:uTargetCid=55
...  LNCEL-1/LNRELW-28:uTargetRncId=1
...  LNCEL-1/LNRELW-28:utranLbAllowed=false
...  LNCEL-1/LNRELW-28:plmnId:mcc=666
...  LNCEL-1/LNRELW-28:plmnId:mnc=58
...  LNCEL-1/LNRELW-28:plmnId:mncLength=2
...  LNADJW-46:srvccHoInd=PSandCS
...  LNADJW-46:uTargetCid=56
...  LNADJW-46:uTargetFreq=9842
...  LNADJW-46:uTargetLac=2
...  LNADJW-46:uTargetRac=2
...  LNADJW-46:uTargetRncId=1
...  LNADJW-46:uTargetScFdd=256
...  LNADJW-46:primaryPlmnId:mcc=666
...  LNADJW-46:primaryPlmnId:mnc=58
...  LNADJW-46:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-29:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-29:nrControl=automatic
...  LNCEL-1/LNRELW-29:psHoAllowed=allowed
...  LNCEL-1/LNRELW-29:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-29:removeAllowed=true
...  LNCEL-1/LNRELW-29:srvccAllowed=allowed
...  LNCEL-1/LNRELW-29:uTargetCid=56
...  LNCEL-1/LNRELW-29:uTargetRncId=1
...  LNCEL-1/LNRELW-29:utranLbAllowed=false
...  LNCEL-1/LNRELW-29:plmnId:mcc=666
...  LNCEL-1/LNRELW-29:plmnId:mnc=58
...  LNCEL-1/LNRELW-29:plmnId:mncLength=2
...  LNADJW-47:srvccHoInd=PSandCS
...  LNADJW-47:uTargetCid=57
...  LNADJW-47:uTargetFreq=9842
...  LNADJW-47:uTargetLac=2
...  LNADJW-47:uTargetRac=2
...  LNADJW-47:uTargetRncId=1
...  LNADJW-47:uTargetScFdd=257
...  LNADJW-47:primaryPlmnId:mcc=666
...  LNADJW-47:primaryPlmnId:mnc=58
...  LNADJW-47:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-30:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-30:nrControl=automatic
...  LNCEL-1/LNRELW-30:psHoAllowed=allowed
...  LNCEL-1/LNRELW-30:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-30:removeAllowed=true
...  LNCEL-1/LNRELW-30:srvccAllowed=allowed
...  LNCEL-1/LNRELW-30:uTargetCid=57
...  LNCEL-1/LNRELW-30:uTargetRncId=1
...  LNCEL-1/LNRELW-30:utranLbAllowed=false
...  LNCEL-1/LNRELW-30:plmnId:mcc=666
...  LNCEL-1/LNRELW-30:plmnId:mnc=58
...  LNCEL-1/LNRELW-30:plmnId:mncLength=2
...  LNADJW-48:srvccHoInd=PSandCS
...  LNADJW-48:uTargetCid=58
...  LNADJW-48:uTargetFreq=9842
...  LNADJW-48:uTargetLac=2
...  LNADJW-48:uTargetRac=2
...  LNADJW-48:uTargetRncId=1
...  LNADJW-48:uTargetScFdd=258
...  LNADJW-48:primaryPlmnId:mcc=666
...  LNADJW-48:primaryPlmnId:mnc=58
...  LNADJW-48:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-31:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-31:nrControl=automatic
...  LNCEL-1/LNRELW-31:psHoAllowed=allowed
...  LNCEL-1/LNRELW-31:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-31:removeAllowed=true
...  LNCEL-1/LNRELW-31:srvccAllowed=allowed
...  LNCEL-1/LNRELW-31:uTargetCid=58
...  LNCEL-1/LNRELW-31:uTargetRncId=1
...  LNCEL-1/LNRELW-31:utranLbAllowed=false
...  LNCEL-1/LNRELW-31:plmnId:mcc=666
...  LNCEL-1/LNRELW-31:plmnId:mnc=58
...  LNCEL-1/LNRELW-31:plmnId:mncLength=2
...  LNADJW-49:srvccHoInd=PSandCS
...  LNADJW-49:uTargetCid=59
...  LNADJW-49:uTargetFreq=9842
...  LNADJW-49:uTargetLac=2
...  LNADJW-49:uTargetRac=2
...  LNADJW-49:uTargetRncId=1
...  LNADJW-49:uTargetScFdd=259
...  LNADJW-49:primaryPlmnId:mcc=666
...  LNADJW-49:primaryPlmnId:mnc=58
...  LNADJW-49:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-32:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-32:nrControl=automatic
...  LNCEL-1/LNRELW-32:psHoAllowed=forbidden
...  LNCEL-1/LNRELW-32:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-32:removeAllowed=true
...  LNCEL-1/LNRELW-32:srvccAllowed=forbidden
...  LNCEL-1/LNRELW-32:uTargetCid=59
...  LNCEL-1/LNRELW-32:uTargetRncId=1
...  LNCEL-1/LNRELW-32:utranLbAllowed=false
...  LNCEL-1/LNRELW-32:plmnId:mcc=666
...  LNCEL-1/LNRELW-32:plmnId:mnc=58
...  LNCEL-1/LNRELW-32:plmnId:mncLength=2
...  LNADJW-50:srvccHoInd=PSandCS
...  LNADJW-50:uTargetCid=60
...  LNADJW-50:uTargetFreq=9842
...  LNADJW-50:uTargetLac=2
...  LNADJW-50:uTargetRac=2
...  LNADJW-50:uTargetRncId=1
...  LNADJW-50:uTargetScFdd=260
...  LNADJW-50:primaryPlmnId:mcc=666
...  LNADJW-50:primaryPlmnId:mnc=58
...  LNADJW-50:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-33:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-33:nrControl=automatic
...  LNCEL-1/LNRELW-33:psHoAllowed=forbidden
...  LNCEL-1/LNRELW-33:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-33:removeAllowed=true
...  LNCEL-1/LNRELW-33:srvccAllowed=forbidden
...  LNCEL-1/LNRELW-33:uTargetCid=60
...  LNCEL-1/LNRELW-33:uTargetRncId=1
...  LNCEL-1/LNRELW-33:utranLbAllowed=false
...  LNCEL-1/LNRELW-33:plmnId:mcc=666
...  LNCEL-1/LNRELW-33:plmnId:mnc=58
...  LNCEL-1/LNRELW-33:plmnId:mncLength=2
...  LNCEL-2/LNRELW-33:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-33:nrControl=automatic
...  LNCEL-2/LNRELW-33:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-33:redirWithSysInfoAllowed=forbidden
...  LNCEL-2/LNRELW-33:removeAllowed=true
...  LNCEL-2/LNRELW-33:srvccAllowed=forbidden
...  LNCEL-2/LNRELW-33:uTargetCid=60
...  LNCEL-2/LNRELW-33:uTargetRncId=1
...  LNCEL-2/LNRELW-33:utranLbAllowed=false
...  LNCEL-2/LNRELW-33:plmnId:mcc=666
...  LNCEL-2/LNRELW-33:plmnId:mnc=58
...  LNCEL-2/LNRELW-33:plmnId:mncLength=2
...  LNADJW-51:srvccHoInd=PSandCS
...  LNADJW-51:uTargetCid=61
...  LNADJW-51:uTargetFreq=9842
...  LNADJW-51:uTargetLac=2
...  LNADJW-51:uTargetRac=2
...  LNADJW-51:uTargetRncId=1
...  LNADJW-51:uTargetScFdd=261
...  LNADJW-51:primaryPlmnId:mcc=666
...  LNADJW-51:primaryPlmnId:mnc=58
...  LNADJW-51:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-34:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-34:nrControl=automatic
...  LNCEL-1/LNRELW-34:psHoAllowed=forbidden
...  LNCEL-1/LNRELW-34:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-34:removeAllowed=false
...  LNCEL-1/LNRELW-34:srvccAllowed=forbidden
...  LNCEL-1/LNRELW-34:uTargetCid=61
...  LNCEL-1/LNRELW-34:uTargetRncId=1
...  LNCEL-1/LNRELW-34:utranLbAllowed=false
...  LNCEL-1/LNRELW-34:plmnId:mcc=666
...  LNCEL-1/LNRELW-34:plmnId:mnc=58
...  LNCEL-1/LNRELW-34:plmnId:mncLength=2
...  LNCEL-2/LNRELW-34:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-34:nrControl=automatic
...  LNCEL-2/LNRELW-34:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-34:redirWithSysInfoAllowed=forbidden
...  LNCEL-2/LNRELW-34:removeAllowed=false
...  LNCEL-2/LNRELW-34:srvccAllowed=forbidden
...  LNCEL-2/LNRELW-34:uTargetCid=61
...  LNCEL-2/LNRELW-34:uTargetRncId=1
...  LNCEL-2/LNRELW-34:utranLbAllowed=false
...  LNCEL-2/LNRELW-34:plmnId:mcc=666
...  LNCEL-2/LNRELW-34:plmnId:mnc=58
...  LNCEL-2/LNRELW-34:plmnId:mncLength=2
...  LNADJW-52:srvccHoInd=PSandCS
...  LNADJW-52:uTargetCid=62
...  LNADJW-52:uTargetFreq=9842
...  LNADJW-52:uTargetLac=2
...  LNADJW-52:uTargetRac=2
...  LNADJW-52:uTargetRncId=1
...  LNADJW-52:uTargetScFdd=262
...  LNADJW-52:primaryPlmnId:mcc=666
...  LNADJW-52:primaryPlmnId:mnc=58
...  LNADJW-52:primaryPlmnId:mncLength=2
...  LNADJW-53:srvccHoInd=PSandCS
...  LNADJW-53:uTargetCid=63
...  LNADJW-53:uTargetFreq=9842
...  LNADJW-53:uTargetLac=2
...  LNADJW-53:uTargetRac=2
...  LNADJW-53:uTargetRncId=1
...  LNADJW-53:uTargetScFdd=263
...  LNADJW-53:primaryPlmnId:mcc=666
...  LNADJW-53:primaryPlmnId:mnc=58
...  LNADJW-53:primaryPlmnId:mncLength=2
...  LNADJW-54:srvccHoInd=PSandCS
...  LNADJW-54:uTargetCid=64
...  LNADJW-54:uTargetFreq=9842
...  LNADJW-54:uTargetLac=2
...  LNADJW-54:uTargetRac=2
...  LNADJW-54:uTargetRncId=1
...  LNADJW-54:uTargetScFdd=264
...  LNADJW-54:primaryPlmnId:mcc=666
...  LNADJW-54:primaryPlmnId:mnc=58
...  LNADJW-54:primaryPlmnId:mncLength=2
...  LNADJW-55:srvccHoInd=PSandCS
...  LNADJW-55:uTargetCid=65
...  LNADJW-55:uTargetFreq=9842
...  LNADJW-55:uTargetLac=2
...  LNADJW-55:uTargetRac=2
...  LNADJW-55:uTargetRncId=1
...  LNADJW-55:uTargetScFdd=265
...  LNADJW-55:primaryPlmnId:mcc=666
...  LNADJW-55:primaryPlmnId:mnc=58
...  LNADJW-55:primaryPlmnId:mncLength=2
...  LNADJW-56:srvccHoInd=PSandCS
...  LNADJW-56:uTargetCid=66
...  LNADJW-56:uTargetFreq=9842
...  LNADJW-56:uTargetLac=2
...  LNADJW-56:uTargetRac=2
...  LNADJW-56:uTargetRncId=1
...  LNADJW-56:uTargetScFdd=266
...  LNADJW-56:primaryPlmnId:mcc=666
...  LNADJW-56:primaryPlmnId:mnc=58
...  LNADJW-56:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-100:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-100:nrControl=automatic
...  LNCEL-1/LNRELW-100:psHoAllowed=allowed
...  LNCEL-1/LNRELW-100:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-100:removeAllowed=false
...  LNCEL-1/LNRELW-100:srvccAllowed=allowed
...  LNCEL-1/LNRELW-100:uTargetCid=70
...  LNCEL-1/LNRELW-100:uTargetRncId=1
...  LNCEL-1/LNRELW-100:utranLbAllowed=false
...  LNCEL-1/LNRELW-100:plmnId:mcc=666
...  LNCEL-1/LNRELW-100:plmnId:mnc=58
...  LNCEL-1/LNRELW-100:plmnId:mncLength=2
...  LNADJW-200:srvccHoInd=PSandCS
...  LNADJW-200:uTargetCid=100
...  LNADJW-200:uTargetFreq=9862
...  LNADJW-200:uTargetLac=2
...  LNADJW-200:uTargetRac=2
...  LNADJW-200:uTargetRncId=100
...  LNADJW-200:uTargetScFdd=280
...  LNADJW-200:primaryPlmnId:mcc=666
...  LNADJW-200:primaryPlmnId:mnc=58
...  LNADJW-200:primaryPlmnId:mncLength=2
...  LNCEL-2/LNRELW-200:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-200:nrControl=automatic
...  LNCEL-2/LNRELW-200:psHoAllowed=allowed
...  LNCEL-2/LNRELW-200:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-200:removeAllowed=true
...  LNCEL-2/LNRELW-200:srvccAllowed=allowed
...  LNCEL-2/LNRELW-200:uTargetCid=100
...  LNCEL-2/LNRELW-200:uTargetRncId=100
...  LNCEL-2/LNRELW-200:utranLbAllowed=false
...  LNCEL-2/LNRELW-200:plmnId:mcc=666
...  LNCEL-2/LNRELW-200:plmnId:mnc=58
...  LNCEL-2/LNRELW-200:plmnId:mncLength=2
...  LNADJW-201:srvccHoInd=PSandCS
...  LNADJW-201:uTargetCid=100
...  LNADJW-201:uTargetFreq=9862
...  LNADJW-201:uTargetLac=2
...  LNADJW-201:uTargetRac=2
...  LNADJW-201:uTargetRncId=101
...  LNADJW-201:uTargetScFdd=280
...  LNADJW-201:primaryPlmnId:mcc=666
...  LNADJW-201:primaryPlmnId:mnc=58
...  LNADJW-201:primaryPlmnId:mncLength=2
...  LNCEL-2/LNRELW-201:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-201:nrControl=automatic
...  LNCEL-2/LNRELW-201:psHoAllowed=allowed
...  LNCEL-2/LNRELW-201:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-201:removeAllowed=true
...  LNCEL-2/LNRELW-201:srvccAllowed=allowed
...  LNCEL-2/LNRELW-201:uTargetCid=100
...  LNCEL-2/LNRELW-201:uTargetRncId=101
...  LNCEL-2/LNRELW-201:utranLbAllowed=false
...  LNCEL-2/LNRELW-201:plmnId:mcc=666
...  LNCEL-2/LNRELW-201:plmnId:mnc=58
...  LNCEL-2/LNRELW-201:plmnId:mncLength=2
@{LNADJ_ALL}
...  MRBTS-1/LNBTS-1/LNADJ-57:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-57:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-57:adjEnbId=557
...  MRBTS-1/LNBTS-1/LNADJ-57:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-57:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-57:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-57:cPlaneIpAddr=11.11.11.57
...  LNADJ-57/LNADJL-1:ecgiLcrId=4
...  LNADJ-57/LNADJL-1:fDlEarfcn=1500
...  LNADJ-57/LNADJL-1:phyCellId=305
...  LNADJ-57/LNADJL-1:tac=5580
...  LNADJ-57/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-57/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-57/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNADJ-57/LNADJL-2:ecgiLcrId=5
...  LNADJ-57/LNADJL-2:fDlEarfcn=1500
...  LNADJ-57/LNADJL-2:phyCellId=315
...  LNADJ-57/LNADJL-2:tac=5581
...  LNADJ-57/LNADJL-2:bcPlmnIdList:mcc=666
...  LNADJ-57/LNADJL-2:bcPlmnIdList:mnc=58
...  LNADJ-57/LNADJL-2:bcPlmnIdList:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-59:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-59:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-59:adjEnbId=559
...  MRBTS-1/LNBTS-1/LNADJ-59:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-59:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-59:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-59:cPlaneIpAddr=11.11.11.59
...  LNADJ-59/LNADJL-1:ecgiLcrId=1
...  LNADJ-59/LNADJL-1:fDlEarfcn=1500
...  LNADJ-59/LNADJL-1:phyCellId=3
...  LNADJ-59/LNADJL-1:tac=5580
...  LNADJ-59/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-59/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-59/LNADJL-1:bcPlmnIdList:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-60:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-60:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-60:adjEnbId=560
...  MRBTS-1/LNBTS-1/LNADJ-60:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-60:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-60:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-60:cPlaneIpAddr=11.11.11.60
...  LNADJ-60/LNADJL-1:ecgiLcrId=1
...  LNADJ-60/LNADJL-1:fDlEarfcn=180
...  LNADJ-60/LNADJL-1:phyCellId=308
...  LNADJ-60/LNADJL-1:tac=5580
...  LNADJ-60/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-60/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-60/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNADJ-60/LNADJL-2:ecgiLcrId=2
...  LNADJ-60/LNADJL-2:fDlEarfcn=180
...  LNADJ-60/LNADJL-2:phyCellId=318
...  LNADJ-60/LNADJL-2:tac=5580
...  LNADJ-60/LNADJL-2:bcPlmnIdList:mcc=666
...  LNADJ-60/LNADJL-2:bcPlmnIdList:mnc=58
...  LNADJ-60/LNADJL-2:bcPlmnIdList:mncLength=2
...  LNADJ-60/LNADJL-3:ecgiLcrId=3
...  LNADJ-60/LNADJL-3:fDlEarfcn=180
...  LNADJ-60/LNADJL-3:phyCellId=328
...  LNADJ-60/LNADJL-3:tac=5580
...  LNADJ-60/LNADJL-3:bcPlmnIdList:mcc=666
...  LNADJ-60/LNADJL-3:bcPlmnIdList:mnc=58
...  LNADJ-60/LNADJL-3:bcPlmnIdList:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-0:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-0:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-0:adjEnbId=500
...  MRBTS-1/LNBTS-1/LNADJ-0:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-0:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-0:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-0:cPlaneIpAddr=11.11.11.11
...  LNADJ-0/LNADJL-1:ecgiLcrId=1
...  LNADJ-0/LNADJL-1:fDlEarfcn=1500
...  LNADJ-0/LNADJL-1:phyCellId=10
...  LNADJ-0/LNADJL-1:tac=5580
...  LNADJ-0/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-2:ecgiLcrId=2
...  LNADJ-0/LNADJL-2:fDlEarfcn=1500
...  LNADJ-0/LNADJL-2:phyCellId=11
...  LNADJ-0/LNADJL-2:tac=5580
...  LNADJ-0/LNADJL-2:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-2:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-2:bcPlmnIdList:mncLength=2
...  ${EMPTY}
...  LNADJ-0/LNADJL-3:ecgiLcrId=3
...  LNADJ-0/LNADJL-3:fDlEarfcn=1500
...  LNADJ-0/LNADJL-3:phyCellId=12
...  LNADJ-0/LNADJL-3:tac=5580
...  LNADJ-0/LNADJL-3:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-3:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-3:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-4:ecgiLcrId=4
...  LNADJ-0/LNADJL-4:fDlEarfcn=1500
...  LNADJ-0/LNADJL-4:phyCellId=13
...  LNADJ-0/LNADJL-4:tac=5580
...  LNADJ-0/LNADJL-4:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-4:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-4:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-5:ecgiLcrId=5
...  LNADJ-0/LNADJL-5:fDlEarfcn=1500
...  LNADJ-0/LNADJL-5:phyCellId=14
...  LNADJ-0/LNADJL-5:tac=5580
...  LNADJ-0/LNADJL-5:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-5:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-5:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-6:ecgiLcrId=6
...  LNADJ-0/LNADJL-6:fDlEarfcn=1500
...  LNADJ-0/LNADJL-6:phyCellId=15
...  LNADJ-0/LNADJL-6:tac=5580
...  LNADJ-0/LNADJL-6:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-6:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-6:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-7:ecgiLcrId=7
...  LNADJ-0/LNADJL-7:fDlEarfcn=1500
...  LNADJ-0/LNADJL-7:phyCellId=16
...  LNADJ-0/LNADJL-7:tac=5580
...  LNADJ-0/LNADJL-7:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-7:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-7:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-8:ecgiLcrId=8
...  LNADJ-0/LNADJL-8:fDlEarfcn=1500
...  LNADJ-0/LNADJL-8:phyCellId=17
...  LNADJ-0/LNADJL-8:tac=5580
...  LNADJ-0/LNADJL-8:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-8:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-8:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-9:ecgiLcrId=9
...  LNADJ-0/LNADJL-9:fDlEarfcn=1500
...  LNADJ-0/LNADJL-9:phyCellId=18
...  LNADJ-0/LNADJL-9:tac=5580
...  LNADJ-0/LNADJL-9:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-9:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-9:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-10:ecgiLcrId=10
...  LNADJ-0/LNADJL-10:fDlEarfcn=1500
...  LNADJ-0/LNADJL-10:phyCellId=19
...  LNADJ-0/LNADJL-10:tac=5580
...  LNADJ-0/LNADJL-10:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-10:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-10:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-11:ecgiLcrId=11
...  LNADJ-0/LNADJL-11:fDlEarfcn=1500
...  LNADJ-0/LNADJL-11:phyCellId=20
...  LNADJ-0/LNADJL-11:tac=5580
...  LNADJ-0/LNADJL-11:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-11:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-11:bcPlmnIdList:mncLength=2
...  ${EMPTY}
...  LNADJ-0/LNADJL-12:ecgiLcrId=12
...  LNADJ-0/LNADJL-12:fDlEarfcn=1500
...  LNADJ-0/LNADJL-12:phyCellId=21
...  LNADJ-0/LNADJL-12:tac=5580
...  LNADJ-0/LNADJL-12:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-12:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-12:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-13:ecgiLcrId=13
...  LNADJ-0/LNADJL-13:fDlEarfcn=1500
...  LNADJ-0/LNADJL-13:phyCellId=22
...  LNADJ-0/LNADJL-13:tac=5580
...  LNADJ-0/LNADJL-13:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-13:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-13:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-14:ecgiLcrId=14
...  LNADJ-0/LNADJL-14:fDlEarfcn=1500
...  LNADJ-0/LNADJL-14:phyCellId=1
...  LNADJ-0/LNADJL-14:tac=5580
...  LNADJ-0/LNADJL-14:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-14:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-14:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-15:ecgiLcrId=15
...  LNADJ-0/LNADJL-15:fDlEarfcn=1500
...  LNADJ-0/LNADJL-15:phyCellId=2
...  LNADJ-0/LNADJL-15:tac=5580
...  LNADJ-0/LNADJL-15:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-15:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-15:bcPlmnIdList:mncLength=2
...  LNADJ-0/LNADJL-16:ecgiLcrId=16
...  LNADJ-0/LNADJL-16:fDlEarfcn=1650
...  LNADJ-0/LNADJL-16:phyCellId=3
...  LNADJ-0/LNADJL-16:tac=5580
...  LNADJ-0/LNADJL-16:bcPlmnIdList:mcc=666
...  LNADJ-0/LNADJL-16:bcPlmnIdList:mnc=58
...  LNADJ-0/LNADJL-16:bcPlmnIdList:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-1:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-1:adjEnbId=501
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddr=11.11.11.12
...  LNADJ-1/LNADJL-1:ecgiLcrId=1
...  LNADJ-1/LNADJL-1:fDlEarfcn=1500
...  LNADJ-1/LNADJL-1:phyCellId=305
...  LNADJ-1/LNADJL-1:tac=5580
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-2:ecgiLcrId=2
...  LNADJ-1/LNADJL-2:fDlEarfcn=1500
...  LNADJ-1/LNADJL-2:phyCellId=315
...  LNADJ-1/LNADJL-2:tac=5580
...  LNADJ-1/LNADJL-2:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-2:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-2:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-3:ecgiLcrId=3
...  LNADJ-1/LNADJL-3:fDlEarfcn=1500
...  LNADJ-1/LNADJL-3:phyCellId=1
...  LNADJ-1/LNADJL-3:tac=5580
...  LNADJ-1/LNADJL-3:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-3:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-3:bcPlmnIdList:mncLength=2
...  ${EMPTY}
...  LNADJ-1/LNADJL-4:ecgiLcrId=4
...  LNADJ-1/LNADJL-4:fDlEarfcn=1650
...  LNADJ-1/LNADJL-4:phyCellId=3
...  LNADJ-1/LNADJL-4:tac=5580
...  LNADJ-1/LNADJL-4:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-4:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-4:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-5:ecgiLcrId=5
...  LNADJ-1/LNADJL-5:fDlEarfcn=1500
...  LNADJ-1/LNADJL-5:phyCellId=3
...  LNADJ-1/LNADJL-5:tac=5580
...  LNADJ-1/LNADJL-5:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-5:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-5:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-6:ecgiLcrId=6
...  LNADJ-1/LNADJL-6:fDlEarfcn=180
...  LNADJ-1/LNADJL-6:phyCellId=308
...  LNADJ-1/LNADJL-6:tac=5580
...  LNADJ-1/LNADJL-6:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-6:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-6:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-7:ecgiLcrId=7
...  LNADJ-1/LNADJL-7:fDlEarfcn=180
...  LNADJ-1/LNADJL-7:phyCellId=318
...  LNADJ-1/LNADJL-7:tac=5580
...  LNADJ-1/LNADJL-7:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-7:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-7:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-8:ecgiLcrId=8
...  LNADJ-1/LNADJL-8:fDlEarfcn=180
...  LNADJ-1/LNADJL-8:phyCellId=328
...  LNADJ-1/LNADJL-8:tac=5580
...  LNADJ-1/LNADJL-8:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-8:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-8:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-9:ecgiLcrId=9
...  LNADJ-1/LNADJL-9:fDlEarfcn=1500
...  LNADJ-1/LNADJL-9:phyCellId=10
...  LNADJ-1/LNADJL-9:tac=5580
...  LNADJ-1/LNADJL-9:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-9:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-9:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-10:ecgiLcrId=10
...  LNADJ-1/LNADJL-10:fDlEarfcn=1500
...  LNADJ-1/LNADJL-10:phyCellId=11
...  LNADJ-1/LNADJL-10:tac=5580
...  LNADJ-1/LNADJL-10:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-10:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-10:bcPlmnIdList:mncLength=2
...  ${EMPTY}
...  LNADJ-1/LNADJL-11:ecgiLcrId=11
...  LNADJ-1/LNADJL-11:fDlEarfcn=1500
...  LNADJ-1/LNADJL-11:phyCellId=12
...  LNADJ-1/LNADJL-11:tac=5580
...  LNADJ-1/LNADJL-11:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-11:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-11:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-12:ecgiLcrId=12
...  LNADJ-1/LNADJL-12:fDlEarfcn=1500
...  LNADJ-1/LNADJL-12:phyCellId=13
...  LNADJ-1/LNADJL-12:tac=5580
...  LNADJ-1/LNADJL-12:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-12:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-12:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-13:ecgiLcrId=13
...  LNADJ-1/LNADJL-13:fDlEarfcn=1500
...  LNADJ-1/LNADJL-13:phyCellId=14
...  LNADJ-1/LNADJL-13:tac=5580
...  LNADJ-1/LNADJL-13:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-13:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-13:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-14:ecgiLcrId=14
...  LNADJ-1/LNADJL-14:fDlEarfcn=1500
...  LNADJ-1/LNADJL-14:phyCellId=15
...  LNADJ-1/LNADJL-14:tac=5580
...  LNADJ-1/LNADJL-14:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-14:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-14:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-15:ecgiLcrId=15
...  LNADJ-1/LNADJL-15:fDlEarfcn=1500
...  LNADJ-1/LNADJL-15:phyCellId=16
...  LNADJ-1/LNADJL-15:tac=5580
...  LNADJ-1/LNADJL-15:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-15:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-15:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-16:ecgiLcrId=16
...  LNADJ-1/LNADJL-16:fDlEarfcn=1500
...  LNADJ-1/LNADJL-16:phyCellId=17
...  LNADJ-1/LNADJL-16:tac=5580
...  LNADJ-1/LNADJL-16:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-16:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-16:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-17:ecgiLcrId=17
...  LNADJ-1/LNADJL-17:fDlEarfcn=1500
...  LNADJ-1/LNADJL-17:phyCellId=18
...  LNADJ-1/LNADJL-17:tac=5580
...  LNADJ-1/LNADJL-17:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-17:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-17:bcPlmnIdList:mncLength=2
...  ${EMPTY}
...  LNADJ-1/LNADJL-18:ecgiLcrId=18
...  LNADJ-1/LNADJL-18:fDlEarfcn=1500
...  LNADJ-1/LNADJL-18:phyCellId=19
...  LNADJ-1/LNADJL-18:tac=5580
...  LNADJ-1/LNADJL-18:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-18:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-18:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-19:ecgiLcrId=19
...  LNADJ-1/LNADJL-19:fDlEarfcn=1500
...  LNADJ-1/LNADJL-19:phyCellId=20
...  LNADJ-1/LNADJL-19:tac=5580
...  LNADJ-1/LNADJL-19:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-19:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-19:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-20:ecgiLcrId=20
...  LNADJ-1/LNADJL-20:fDlEarfcn=1500
...  LNADJ-1/LNADJL-20:phyCellId=21
...  LNADJ-1/LNADJL-20:tac=5580
...  LNADJ-1/LNADJL-20:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-20:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-20:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-21:ecgiLcrId=21
...  LNADJ-1/LNADJL-21:fDlEarfcn=1500
...  LNADJ-1/LNADJL-21:phyCellId=22
...  LNADJ-1/LNADJL-21:tac=5580
...  LNADJ-1/LNADJL-21:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-21:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-21:bcPlmnIdList:mncLength=2
...  LNADJ-1/LNADJL-22:ecgiLcrId=22
...  LNADJ-1/LNADJL-22:fDlEarfcn=1500
...  LNADJ-1/LNADJL-22:phyCellId=23
...  LNADJ-1/LNADJL-22:tac=5580
...  LNADJ-1/LNADJL-22:bcPlmnIdList:mcc=666
...  LNADJ-1/LNADJL-22:bcPlmnIdList:mnc=58
...  LNADJ-1/LNADJL-22:bcPlmnIdList:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-2:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-2:cPlaneIpAddrCtrl=enbControlled
...  MRBTS-1/LNBTS-1/LNADJ-2:adjEnbId=502
...  MRBTS-1/LNBTS-1/LNADJ-2:plmnId:mcc=666
...  MRBTS-1/LNBTS-1/LNADJ-2:plmnId:mnc=58
...  MRBTS-1/LNBTS-1/LNADJ-2:plmnId:mncLength=2
...  MRBTS-1/LNBTS-1/LNADJ-2:cPlaneIpAddr=11.11.11.13
...  LNADJ-2/LNADJL-1:ecgiLcrId=1
...  LNADJ-2/LNADJL-1:fDlEarfcn=1500
...  LNADJ-2/LNADJL-1:phyCellId=1
...  LNADJ-2/LNADJL-1:tac=5580
...  LNADJ-2/LNADJL-1:bcPlmnIdList:mcc=666
...  LNADJ-2/LNADJL-1:bcPlmnIdList:mnc=58
...  LNADJ-2/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNADJ-2/LNADJL-2:ecgiLcrId=2
...  LNADJ-2/LNADJL-2:fDlEarfcn=1500
...  LNADJ-2/LNADJL-2:phyCellId=2
...  LNADJ-2/LNADJL-2:tac=5580
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mcc=666
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mnc=58
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mncLength=2
...  LNADJ-2/LNADJL-3:ecgiLcrId=3
...  LNADJ-2/LNADJL-3:fDlEarfcn=1650
...  LNADJ-2/LNADJL-3:phyCellId=3
...  LNADJ-2/LNADJL-3:tac=5580
...  LNADJ-2/LNADJL-3:bcPlmnIdList:mcc=666
...  LNADJ-2/LNADJL-3:bcPlmnIdList:mnc=58
...  LNADJ-2/LNADJL-3:bcPlmnIdList:mncLength=2
@{LNCEL1_LNREL_ALL}
...  LNCEL-1/LNREL-1:amleAllowed=false
...  LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-1:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-1:ecgiLcrId=4
...  LNCEL-1/LNREL-1:handoverAllowed=allowed
...  LNCEL-1/LNREL-1:nrControl=automatic
...  LNCEL-1/LNREL-1:removeAllowed=true
...  LNCEL-1/LNREL-1:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-1:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-2:amleAllowed=false
...  LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-2:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-2:ecgiLcrId=5
...  LNCEL-1/LNREL-2:handoverAllowed=allowed
...  LNCEL-1/LNREL-2:nrControl=automatic
...  LNCEL-1/LNREL-2:removeAllowed=true
...  LNCEL-1/LNREL-2:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-2:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-3:amleAllowed=false
...  LNCEL-1/LNREL-3:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...  LNCEL-1/LNREL-3:ecgiLcrId=2
...  LNCEL-1/LNREL-3:handoverAllowed=allowed
...  LNCEL-1/LNREL-3:nrControl=automatic
...  LNCEL-1/LNREL-3:removeAllowed=true
...  LNCEL-1/LNREL-3:ecgiPlmnId:mcc=244
...  LNCEL-1/LNREL-3:ecgiPlmnId:mnc=9
...  LNCEL-1/LNREL-3:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-4:amleAllowed=false
...  LNCEL-1/LNREL-4:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-4:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-4:ecgiLcrId=6
...  LNCEL-1/LNREL-4:handoverAllowed=allowed
...  LNCEL-1/LNREL-4:nrControl=automatic
...  LNCEL-1/LNREL-4:removeAllowed=true
...  LNCEL-1/LNREL-4:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-4:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-4:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-5:amleAllowed=false
...  LNCEL-1/LNREL-5:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-5:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-5:ecgiLcrId=7
...  LNCEL-1/LNREL-5:handoverAllowed=allowed
...  LNCEL-1/LNREL-5:nrControl=automatic
...  LNCEL-1/LNREL-5:removeAllowed=true
...  LNCEL-1/LNREL-5:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-5:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-5:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-6:amleAllowed=false
...  LNCEL-1/LNREL-6:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-6:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-6:ecgiLcrId=8
...  LNCEL-1/LNREL-6:handoverAllowed=allowed
...  LNCEL-1/LNREL-6:nrControl=automatic
...  LNCEL-1/LNREL-6:removeAllowed=true
...  LNCEL-1/LNREL-6:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-6:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-6:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-7:amleAllowed=false
...  LNCEL-1/LNREL-7:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-7:ecgiAdjEnbId=1
...  LNCEL-1/LNREL-7:ecgiLcrId=3
...  LNCEL-1/LNREL-7:handoverAllowed=allowed
...  LNCEL-1/LNREL-7:nrControl=automatic
...  LNCEL-1/LNREL-7:removeAllowed=false
...  LNCEL-1/LNREL-7:ecgiPlmnId:mcc=244
...  LNCEL-1/LNREL-7:ecgiPlmnId:mnc=9
...  LNCEL-1/LNREL-7:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-8:amleAllowed=false
...  LNCEL-1/LNREL-8:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-8:ecgiAdjEnbId=559
...  LNCEL-1/LNREL-8:ecgiLcrId=1
...  LNCEL-1/LNREL-8:handoverAllowed=allowed
...  LNCEL-1/LNREL-8:nrControl=automatic
...  LNCEL-1/LNREL-8:removeAllowed=false
...  LNCEL-1/LNREL-8:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-8:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-8:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-9:amleAllowed=false
...  LNCEL-1/LNREL-9:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-9:ecgiAdjEnbId=560
...  LNCEL-1/LNREL-9:ecgiLcrId=1
...  LNCEL-1/LNREL-9:handoverAllowed=allowed
...  LNCEL-1/LNREL-9:nrControl=automatic
...  LNCEL-1/LNREL-9:removeAllowed=false
...  LNCEL-1/LNREL-9:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-9:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-9:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-10:amleAllowed=false
...  LNCEL-1/LNREL-10:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-10:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-10:ecgiLcrId=9
...  LNCEL-1/LNREL-10:handoverAllowed=allowed
...  LNCEL-1/LNREL-10:nrControl=automatic
...  LNCEL-1/LNREL-10:removeAllowed=false
...  LNCEL-1/LNREL-10:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-10:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-10:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-11:amleAllowed=false
...  LNCEL-1/LNREL-11:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-11:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-11:ecgiLcrId=10
...  LNCEL-1/LNREL-11:handoverAllowed=allowed
...  LNCEL-1/LNREL-11:nrControl=automatic
...  LNCEL-1/LNREL-11:removeAllowed=false
...  LNCEL-1/LNREL-11:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-11:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-11:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-12:amleAllowed=false
...  LNCEL-1/LNREL-12:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-12:ecgiAdjEnbId=557
...  LNCEL-1/LNREL-12:ecgiLcrId=11
...  LNCEL-1/LNREL-12:handoverAllowed=allowed
...  LNCEL-1/LNREL-12:nrControl=automatic
...  LNCEL-1/LNREL-12:removeAllowed=false
...  LNCEL-1/LNREL-12:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-12:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-12:ecgiPlmnId:mncLength=2
...  ${EMPTY}
...  LNCEL-1/LNREL-13:amleAllowed=false
...  LNCEL-1/LNREL-13:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-13:ecgiAdjEnbId=500
...  LNCEL-1/LNREL-13:ecgiLcrId=14
...  LNCEL-1/LNREL-13:handoverAllowed=allowed
...  LNCEL-1/LNREL-13:nrControl=automatic
...  LNCEL-1/LNREL-13:removeAllowed=true
...  LNCEL-1/LNREL-13:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-13:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-13:ecgiPlmnId:mncLength=2
...  LNCEL-1/LNREL-14:amleAllowed=false
...  LNCEL-1/LNREL-14:cellIndOffNeigh=0dB
...  LNCEL-1/LNREL-14:ecgiAdjEnbId=502
...  LNCEL-1/LNREL-14:ecgiLcrId=1
...  LNCEL-1/LNREL-14:handoverAllowed=allowed
...  LNCEL-1/LNREL-14:nrControl=automatic
...  LNCEL-1/LNREL-14:removeAllowed=false
...  LNCEL-1/LNREL-14:ecgiPlmnId:mcc=666
...  LNCEL-1/LNREL-14:ecgiPlmnId:mnc=58
...  LNCEL-1/LNREL-14:ecgiPlmnId:mncLength=2
@{LNCEL2_LNREL_ALL}
...  LNCEL-2/LNREL-1:amleAllowed=false
...  LNCEL-2/LNREL-1:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-1:ecgiAdjEnbId=557
...  LNCEL-2/LNREL-1:ecgiLcrId=4
...  LNCEL-2/LNREL-1:handoverAllowed=allowed
...  LNCEL-2/LNREL-1:nrControl=automatic
...  LNCEL-2/LNREL-1:removeAllowed=true
...  LNCEL-2/LNREL-1:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-1:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-2:amleAllowed=false
...  LNCEL-2/LNREL-2:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-2:ecgiAdjEnbId=557
...  LNCEL-2/LNREL-2:ecgiLcrId=5
...  LNCEL-2/LNREL-2:handoverAllowed=allowed
...  LNCEL-2/LNREL-2:nrControl=automatic
...  LNCEL-2/LNREL-2:removeAllowed=true
...  LNCEL-2/LNREL-2:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-2:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-3:amleAllowed=false
...  LNCEL-2/LNREL-3:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...  LNCEL-2/LNREL-3:ecgiLcrId=1
...  LNCEL-2/LNREL-3:handoverAllowed=allowed
...  LNCEL-2/LNREL-3:nrControl=automatic
...  LNCEL-2/LNREL-3:removeAllowed=true
...  LNCEL-2/LNREL-3:ecgiPlmnId:mcc=244
...  LNCEL-2/LNREL-3:ecgiPlmnId:mnc=9
...  LNCEL-2/LNREL-3:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-4:amleAllowed=false
...  LNCEL-2/LNREL-4:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-4:ecgiAdjEnbId=1
...  LNCEL-2/LNREL-4:ecgiLcrId=3
...  LNCEL-2/LNREL-4:handoverAllowed=allowed
...  LNCEL-2/LNREL-4:nrControl=automatic
...  LNCEL-2/LNREL-4:removeAllowed=true
...  LNCEL-2/LNREL-4:ecgiPlmnId:mcc=244
...  LNCEL-2/LNREL-4:ecgiPlmnId:mnc=9
...  LNCEL-2/LNREL-4:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-5:amleAllowed=false
...  LNCEL-2/LNREL-5:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-5:ecgiAdjEnbId=559
...  LNCEL-2/LNREL-5:ecgiLcrId=1
...  LNCEL-2/LNREL-5:handoverAllowed=allowed
...  LNCEL-2/LNREL-5:nrControl=automatic
...  LNCEL-2/LNREL-5:removeAllowed=true
...  LNCEL-2/LNREL-5:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-5:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-5:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-6:amleAllowed=false
...  LNCEL-2/LNREL-6:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-6:ecgiAdjEnbId=560
...  LNCEL-2/LNREL-6:ecgiLcrId=1
...  LNCEL-2/LNREL-6:handoverAllowed=allowed
...  LNCEL-2/LNREL-6:nrControl=automatic
...  LNCEL-2/LNREL-6:removeAllowed=true
...  LNCEL-2/LNREL-6:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-6:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-6:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-7:amleAllowed=false
...  LNCEL-2/LNREL-7:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-7:ecgiAdjEnbId=560
...  LNCEL-2/LNREL-7:ecgiLcrId=2
...  LNCEL-2/LNREL-7:handoverAllowed=allowed
...  LNCEL-2/LNREL-7:nrControl=automatic
...  LNCEL-2/LNREL-7:removeAllowed=true
...  LNCEL-2/LNREL-7:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-7:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-7:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-8:amleAllowed=false
...  LNCEL-2/LNREL-8:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-8:ecgiAdjEnbId=560
...  LNCEL-2/LNREL-8:ecgiLcrId=3
...  LNCEL-2/LNREL-8:handoverAllowed=allowed
...  LNCEL-2/LNREL-8:nrControl=automatic
...  LNCEL-2/LNREL-8:removeAllowed=true
...  LNCEL-2/LNREL-8:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-8:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-8:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-9:amleAllowed=false
...  LNCEL-2/LNREL-9:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-9:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-9:ecgiLcrId=1
...  LNCEL-2/LNREL-9:handoverAllowed=allowed
...  LNCEL-2/LNREL-9:nrControl=automatic
...  LNCEL-2/LNREL-9:removeAllowed=true
...  LNCEL-2/LNREL-9:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-9:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-9:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-10:amleAllowed=false
...  LNCEL-2/LNREL-10:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-10:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-10:ecgiLcrId=2
...  LNCEL-2/LNREL-10:handoverAllowed=allowed
...  LNCEL-2/LNREL-10:nrControl=automatic
...  LNCEL-2/LNREL-10:removeAllowed=true
...  LNCEL-2/LNREL-10:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-10:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-10:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-11:amleAllowed=false
...  LNCEL-2/LNREL-11:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-11:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-11:ecgiLcrId=3
...  LNCEL-2/LNREL-11:handoverAllowed=allowed
...  LNCEL-2/LNREL-11:nrControl=automatic
...  LNCEL-2/LNREL-11:removeAllowed=true
...  LNCEL-2/LNREL-11:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-11:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-11:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-12:amleAllowed=false
...  LNCEL-2/LNREL-12:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-12:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-12:ecgiLcrId=4
...  LNCEL-2/LNREL-12:handoverAllowed=allowed
...  LNCEL-2/LNREL-12:nrControl=automatic
...  LNCEL-2/LNREL-12:removeAllowed=true
...  LNCEL-2/LNREL-12:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-12:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-12:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-13:amleAllowed=false
...  LNCEL-2/LNREL-13:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-13:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-13:ecgiLcrId=5
...  LNCEL-2/LNREL-13:handoverAllowed=allowed
...  LNCEL-2/LNREL-13:nrControl=automatic
...  LNCEL-2/LNREL-13:removeAllowed=true
...  LNCEL-2/LNREL-13:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-13:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-13:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-14:amleAllowed=false
...  LNCEL-2/LNREL-14:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-14:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-14:ecgiLcrId=6
...  LNCEL-2/LNREL-14:handoverAllowed=allowed
...  LNCEL-2/LNREL-14:nrControl=automatic
...  LNCEL-2/LNREL-14:removeAllowed=true
...  LNCEL-2/LNREL-14:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-14:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-14:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-15:amleAllowed=false
...  LNCEL-2/LNREL-15:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-15:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-15:ecgiLcrId=7
...  LNCEL-2/LNREL-15:handoverAllowed=allowed
...  LNCEL-2/LNREL-15:nrControl=automatic
...  LNCEL-2/LNREL-15:removeAllowed=true
...  LNCEL-2/LNREL-15:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-15:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-15:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-16:amleAllowed=false
...  LNCEL-2/LNREL-16:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-16:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-16:ecgiLcrId=8
...  LNCEL-2/LNREL-16:handoverAllowed=allowed
...  LNCEL-2/LNREL-16:nrControl=automatic
...  LNCEL-2/LNREL-16:removeAllowed=false
...  LNCEL-2/LNREL-16:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-16:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-16:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-17:amleAllowed=false
...  LNCEL-2/LNREL-17:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-17:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-17:ecgiLcrId=9
...  LNCEL-2/LNREL-17:handoverAllowed=allowed
...  LNCEL-2/LNREL-17:nrControl=automatic
...  LNCEL-2/LNREL-17:removeAllowed=false
...  LNCEL-2/LNREL-17:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-17:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-17:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-18:amleAllowed=false
...  LNCEL-2/LNREL-18:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-18:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-18:ecgiLcrId=10
...  LNCEL-2/LNREL-18:handoverAllowed=allowed
...  LNCEL-2/LNREL-18:nrControl=automatic
...  LNCEL-2/LNREL-18:removeAllowed=false
...  LNCEL-2/LNREL-18:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-18:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-18:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-19:amleAllowed=false
...  LNCEL-2/LNREL-19:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-19:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-19:ecgiLcrId=11
...  LNCEL-2/LNREL-19:handoverAllowed=allowed
...  LNCEL-2/LNREL-19:nrControl=automatic
...  LNCEL-2/LNREL-19:removeAllowed=false
...  LNCEL-2/LNREL-19:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-19:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-19:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-20:amleAllowed=false
...  LNCEL-2/LNREL-20:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-20:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-20:ecgiLcrId=12
...  LNCEL-2/LNREL-20:handoverAllowed=allowed
...  LNCEL-2/LNREL-20:nrControl=automatic
...  LNCEL-2/LNREL-20:removeAllowed=false
...  LNCEL-2/LNREL-20:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-20:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-20:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-21:amleAllowed=false
...  LNCEL-2/LNREL-21:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-21:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-21:ecgiLcrId=13
...  LNCEL-2/LNREL-21:handoverAllowed=allowed
...  LNCEL-2/LNREL-21:nrControl=automatic
...  LNCEL-2/LNREL-21:removeAllowed=false
...  LNCEL-2/LNREL-21:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-21:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-21:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-101:amleAllowed=false
...  LNCEL-2/LNREL-101:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-101:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-101:ecgiLcrId=1
...  LNCEL-2/LNREL-101:handoverAllowed=allowed
...  LNCEL-2/LNREL-101:nrControl=automatic
...  LNCEL-2/LNREL-101:removeAllowed=true
...  LNCEL-2/LNREL-101:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-101:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-101:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-102:amleAllowed=false
...  LNCEL-2/LNREL-102:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-102:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-102:ecgiLcrId=2
...  LNCEL-2/LNREL-102:handoverAllowed=allowed
...  LNCEL-2/LNREL-102:nrControl=automatic
...  LNCEL-2/LNREL-102:removeAllowed=true
...  LNCEL-2/LNREL-102:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-102:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-102:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-103:amleAllowed=false
...  LNCEL-2/LNREL-103:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-103:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-103:ecgiLcrId=3
...  LNCEL-2/LNREL-103:handoverAllowed=allowed
...  LNCEL-2/LNREL-103:nrControl=automatic
...  LNCEL-2/LNREL-103:removeAllowed=true
...  LNCEL-2/LNREL-103:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-103:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-103:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-104:amleAllowed=false
...  LNCEL-2/LNREL-104:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-104:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-104:ecgiLcrId=4
...  LNCEL-2/LNREL-104:handoverAllowed=allowed
...  LNCEL-2/LNREL-104:nrControl=automatic
...  LNCEL-2/LNREL-104:removeAllowed=false
...  LNCEL-2/LNREL-104:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-104:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-104:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-105:amleAllowed=false
...  LNCEL-2/LNREL-105:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-105:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-105:ecgiLcrId=5
...  LNCEL-2/LNREL-105:handoverAllowed=allowed
...  LNCEL-2/LNREL-105:nrControl=automatic
...  LNCEL-2/LNREL-105:removeAllowed=false
...  LNCEL-2/LNREL-105:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-105:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-105:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-106:amleAllowed=false
...  LNCEL-2/LNREL-106:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-106:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-106:ecgiLcrId=6
...  LNCEL-2/LNREL-106:handoverAllowed=allowed
...  LNCEL-2/LNREL-106:nrControl=automatic
...  LNCEL-2/LNREL-106:removeAllowed=false
...  LNCEL-2/LNREL-106:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-106:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-106:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-107:amleAllowed=false
...  LNCEL-2/LNREL-107:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-107:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-107:ecgiLcrId=7
...  LNCEL-2/LNREL-107:handoverAllowed=allowed
...  LNCEL-2/LNREL-107:nrControl=automatic
...  LNCEL-2/LNREL-107:removeAllowed=true
...  LNCEL-2/LNREL-107:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-107:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-107:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-108:amleAllowed=false
...  LNCEL-2/LNREL-108:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-108:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-108:ecgiLcrId=8
...  LNCEL-2/LNREL-108:handoverAllowed=allowed
...  LNCEL-2/LNREL-108:nrControl=automatic
...  LNCEL-2/LNREL-108:removeAllowed=true
...  LNCEL-2/LNREL-108:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-108:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-108:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-109:amleAllowed=false
...  LNCEL-2/LNREL-109:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-109:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-109:ecgiLcrId=9
...  LNCEL-2/LNREL-109:handoverAllowed=allowed
...  LNCEL-2/LNREL-109:nrControl=automatic
...  LNCEL-2/LNREL-109:removeAllowed=false
...  LNCEL-2/LNREL-109:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-109:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-109:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-110:amleAllowed=false
...  LNCEL-2/LNREL-110:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-110:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-110:ecgiLcrId=10
...  LNCEL-2/LNREL-110:handoverAllowed=allowed
...  LNCEL-2/LNREL-110:nrControl=automatic
...  LNCEL-2/LNREL-110:removeAllowed=false
...  LNCEL-2/LNREL-110:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-110:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-110:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-111:amleAllowed=false
...  LNCEL-2/LNREL-111:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-111:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-111:ecgiLcrId=11
...  LNCEL-2/LNREL-111:handoverAllowed=allowed
...  LNCEL-2/LNREL-111:nrControl=automatic
...  LNCEL-2/LNREL-111:removeAllowed=false
...  LNCEL-2/LNREL-111:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-111:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-111:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-112:amleAllowed=false
...  LNCEL-2/LNREL-112:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-112:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-112:ecgiLcrId=12
...  LNCEL-2/LNREL-112:handoverAllowed=allowed
...  LNCEL-2/LNREL-112:nrControl=automatic
...  LNCEL-2/LNREL-112:removeAllowed=true
...  LNCEL-2/LNREL-112:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-112:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-112:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-113:amleAllowed=false
...  LNCEL-2/LNREL-113:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-113:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-113:ecgiLcrId=13
...  LNCEL-2/LNREL-113:handoverAllowed=allowed
...  LNCEL-2/LNREL-113:nrControl=automatic
...  LNCEL-2/LNREL-113:removeAllowed=false
...  LNCEL-2/LNREL-113:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-113:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-113:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-114:amleAllowed=false
...  LNCEL-2/LNREL-114:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-114:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-114:ecgiLcrId=14
...  LNCEL-2/LNREL-114:handoverAllowed=allowed
...  LNCEL-2/LNREL-114:nrControl=automatic
...  LNCEL-2/LNREL-114:removeAllowed=false
...  LNCEL-2/LNREL-114:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-114:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-114:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-115:amleAllowed=false
...  LNCEL-2/LNREL-115:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-115:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-115:ecgiLcrId=15
...  LNCEL-2/LNREL-115:handoverAllowed=allowed
...  LNCEL-2/LNREL-115:nrControl=automatic
...  LNCEL-2/LNREL-115:removeAllowed=false
...  LNCEL-2/LNREL-115:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-115:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-115:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-116:amleAllowed=false
...  LNCEL-2/LNREL-116:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-116:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-116:ecgiLcrId=16
...  LNCEL-2/LNREL-116:handoverAllowed=allowed
...  LNCEL-2/LNREL-116:nrControl=automatic
...  LNCEL-2/LNREL-116:removeAllowed=false
...  LNCEL-2/LNREL-116:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-116:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-116:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-117:amleAllowed=false
...  LNCEL-2/LNREL-117:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-117:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-117:ecgiLcrId=17
...  LNCEL-2/LNREL-117:handoverAllowed=allowed
...  LNCEL-2/LNREL-117:nrControl=automatic
...  LNCEL-2/LNREL-117:removeAllowed=false
...  LNCEL-2/LNREL-117:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-117:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-117:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-118:amleAllowed=false
...  LNCEL-2/LNREL-118:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-118:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-118:ecgiLcrId=18
...  LNCEL-2/LNREL-118:handoverAllowed=allowed
...  LNCEL-2/LNREL-118:nrControl=automatic
...  LNCEL-2/LNREL-118:removeAllowed=false
...  LNCEL-2/LNREL-118:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-118:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-118:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-119:amleAllowed=false
...  LNCEL-2/LNREL-119:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-119:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-119:ecgiLcrId=19
...  LNCEL-2/LNREL-119:handoverAllowed=allowed
...  LNCEL-2/LNREL-119:nrControl=automatic
...  LNCEL-2/LNREL-119:removeAllowed=false
...  LNCEL-2/LNREL-119:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-119:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-119:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-120:amleAllowed=false
...  LNCEL-2/LNREL-120:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-120:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-120:ecgiLcrId=20
...  LNCEL-2/LNREL-120:handoverAllowed=allowed
...  LNCEL-2/LNREL-120:nrControl=automatic
...  LNCEL-2/LNREL-120:removeAllowed=false
...  LNCEL-2/LNREL-120:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-120:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-120:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-121:amleAllowed=false
...  LNCEL-2/LNREL-121:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-121:ecgiAdjEnbId=501
...  LNCEL-2/LNREL-121:ecgiLcrId=21
...  LNCEL-2/LNREL-121:handoverAllowed=allowed
...  LNCEL-2/LNREL-121:nrControl=automatic
...  LNCEL-2/LNREL-121:removeAllowed=false
...  LNCEL-2/LNREL-121:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-121:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-121:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-22:amleAllowed=false
...  LNCEL-2/LNREL-22:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-22:ecgiAdjEnbId=500
...  LNCEL-2/LNREL-22:ecgiLcrId=15
...  LNCEL-2/LNREL-22:handoverAllowed=allowed
...  LNCEL-2/LNREL-22:nrControl=automatic
...  LNCEL-2/LNREL-22:removeAllowed=true
...  LNCEL-2/LNREL-22:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-22:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-22:ecgiPlmnId:mncLength=2
...  LNCEL-2/LNREL-23:amleAllowed=false
...  LNCEL-2/LNREL-23:cellIndOffNeigh=0dB
...  LNCEL-2/LNREL-23:ecgiAdjEnbId=502
...  LNCEL-2/LNREL-23:ecgiLcrId=2
...  LNCEL-2/LNREL-23:handoverAllowed=allowed
...  LNCEL-2/LNREL-23:nrControl=automatic
...  LNCEL-2/LNREL-23:removeAllowed=false
...  LNCEL-2/LNREL-23:ecgiPlmnId:mcc=666
...  LNCEL-2/LNREL-23:ecgiPlmnId:mnc=58
...  LNCEL-2/LNREL-23:ecgiPlmnId:mncLength=2
@{LNCEL3_LNREL_ALL}
...  LNCEL-3/LNREL-1:amleAllowed=false
...  LNCEL-3/LNREL-1:cellIndOffNeigh=0dB
...  LNCEL-3/LNREL-1:ecgiAdjEnbId=500
...  LNCEL-3/LNREL-1:ecgiLcrId=16
...  LNCEL-3/LNREL-1:handoverAllowed=allowed
...  LNCEL-3/LNREL-1:nrControl=automatic
...  LNCEL-3/LNREL-1:removeAllowed=true
...  LNCEL-3/LNREL-1:ecgiPlmnId:mcc=666
...  LNCEL-3/LNREL-1:ecgiPlmnId:mnc=58
...  LNCEL-3/LNREL-1:ecgiPlmnId:mncLength=2
...  LNCEL-3/LNREL-2:amleAllowed=false
...  LNCEL-3/LNREL-2:cellIndOffNeigh=0dB
...  LNCEL-3/LNREL-2:ecgiAdjEnbId=502
...  LNCEL-3/LNREL-2:ecgiLcrId=3
...  LNCEL-3/LNREL-2:handoverAllowed=allowed
...  LNCEL-3/LNREL-2:nrControl=automatic
...  LNCEL-3/LNREL-2:removeAllowed=false
...  LNCEL-3/LNREL-2:ecgiPlmnId:mcc=666
...  LNCEL-3/LNREL-2:ecgiPlmnId:mnc=58
...  LNCEL-3/LNREL-2:ecgiPlmnId:mncLength=2
@{default_NR}
...  @{LNADJG-0}
...  @{LNADJG-1}
...  @{LNADJG-2}
...  @{LNADJW_ALL}
...  @{LNADJ_ALL}
...  @{LNCEL1_LNREL_ALL}
...  @{LNCEL2_LNREL_ALL}
...  @{LNCEL3_LNREL_ALL}

*** Test Cases ***
C-Pln_LTE1383 NR during eNB start-up phase 1
    [Documentation]    Neighbour relation consolidation + HO relation counter during eNB start-up
    [Tags]
    Wait NR Creation finish
    Check Neighbour status
    Check RTPM Counter    file_name=reference_PM1_test

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace uec=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create mme alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Wait NR Creation finish
    sleep    30s

Check Neighbour status
    ${object_list}    Create List    LNADJW-0:sourceOfData=OM
    Object Should Exist    ${object_list}
    ${scf}=    Download Scf
    ${object_list}    Create List    LNADJW-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJW-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJW-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-0:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-0:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-1:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-2:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-4:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-5:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-6:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-7:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-8:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-9:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-10:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-11:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-12:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-13:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-14:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-15:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-16:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-17:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-18:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-19:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-20:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-21:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-22:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-23:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-24:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-25:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-26:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-27:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-28:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-29:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-30:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-31:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-32:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-33:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-34:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-100:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-0:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-1:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-2:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-33:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-34:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    comment    Check failure
    ${object_list}    Create List    LNCEL-2/LNRELW-200:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-201:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-57:cPlaneIpAddrCtrl=enbControlled    LNADJ-57:adjEnbId=557
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-59:cPlaneIpAddrCtrl=enbControlled    LNADJ-59:adjEnbId=559
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-60:cPlaneIpAddrCtrl=enbControlled    LNADJ-60:adjEnbId=560
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-0:cPlaneIpAddrCtrl=enbControlled    LNADJ-0:adjEnbId=500
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-1:cPlaneIpAddrCtrl=enbControlled    LNADJ-1:adjEnbId=501
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-2:cPlaneIpAddrCtrl=enbControlled    LNADJ-2:adjEnbId=502
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-57/LNADJL-1:ecgiLcrId=4  LNADJ-57/LNADJL-1:fDlEarfcn=1500  LNADJ-57/LNADJL-1:phyCellId=305
    ...  LNADJ-57/LNADJL-1:tac=5580  LNADJ-57/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-57/LNADJL-2:ecgiLcrId=5  LNADJ-57/LNADJL-2:fDlEarfcn=1500  LNADJ-57/LNADJL-2:phyCellId=315
    ...  LNADJ-57/LNADJL-2:tac=5581  LNADJ-57/LNADJL-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-59/LNADJL-1:ecgiLcrId=1  LNADJ-59/LNADJL-1:fDlEarfcn=1500  LNADJ-59/LNADJL-1:phyCellId=3
    ...  LNADJ-59/LNADJL-1:tac=5580  LNADJ-59/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-60/LNADJL-1:ecgiLcrId=1  LNADJ-60/LNADJL-1:fDlEarfcn=180  LNADJ-60/LNADJL-1:phyCellId=308
    ...  LNADJ-60/LNADJL-1:tac=5580  LNADJ-60/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-60/LNADJL-2:ecgiLcrId=2  LNADJ-60/LNADJL-2:fDlEarfcn=180  LNADJ-60/LNADJL-2:phyCellId=318
    ...  LNADJ-60/LNADJL-2:tac=5580  LNADJ-60/LNADJL-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-60/LNADJL-3:ecgiLcrId=3  LNADJ-60/LNADJL-3:fDlEarfcn=180  LNADJ-60/LNADJL-3:phyCellId=328
    ...  LNADJ-60/LNADJL-3:tac=5580  LNADJ-60/LNADJL-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-1:ecgiLcrId=1  LNADJ-0/LNADJL-1:fDlEarfcn=1500  LNADJ-0/LNADJL-1:phyCellId=10
    ...  LNADJ-0/LNADJL-1:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-2:ecgiLcrId=2  LNADJ-0/LNADJL-2:fDlEarfcn=1500  LNADJ-0/LNADJL-2:phyCellId=11
    ...  LNADJ-0/LNADJL-2:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-3:ecgiLcrId=3  LNADJ-0/LNADJL-3:fDlEarfcn=1500  LNADJ-0/LNADJL-3:phyCellId=12
    ...  LNADJ-0/LNADJL-3:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-4:ecgiLcrId=4  LNADJ-0/LNADJL-4:fDlEarfcn=1500  LNADJ-0/LNADJL-4:phyCellId=13
    ...  LNADJ-0/LNADJL-4:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-5:ecgiLcrId=5  LNADJ-0/LNADJL-5:fDlEarfcn=1500  LNADJ-0/LNADJL-5:phyCellId=14
    ...  LNADJ-0/LNADJL-5:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-6:ecgiLcrId=6  LNADJ-0/LNADJL-6:fDlEarfcn=1500  LNADJ-0/LNADJL-6:phyCellId=15
    ...  LNADJ-0/LNADJL-6:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-7:ecgiLcrId=7  LNADJ-0/LNADJL-7:fDlEarfcn=1500  LNADJ-0/LNADJL-7:phyCellId=16
    ...  LNADJ-0/LNADJL-7:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-8:ecgiLcrId=8  LNADJ-0/LNADJL-8:fDlEarfcn=1500  LNADJ-0/LNADJL-8:phyCellId=17
    ...  LNADJ-0/LNADJL-8:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-9:ecgiLcrId=9  LNADJ-0/LNADJL-9:fDlEarfcn=1500  LNADJ-0/LNADJL-9:phyCellId=18
    ...  LNADJ-0/LNADJL-9:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-10:ecgiLcrId=10  LNADJ-0/LNADJL-10:fDlEarfcn=1500  LNADJ-0/LNADJL-10:phyCellId=19
    ...  LNADJ-0/LNADJL-10:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-11:ecgiLcrId=11  LNADJ-0/LNADJL-11:fDlEarfcn=1500  LNADJ-0/LNADJL-11:phyCellId=20
    ...  LNADJ-0/LNADJL-11:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-12:ecgiLcrId=12  LNADJ-0/LNADJL-12:fDlEarfcn=1500  LNADJ-0/LNADJL-12:phyCellId=21
    ...  LNADJ-0/LNADJL-12:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-13:ecgiLcrId=13  LNADJ-0/LNADJL-13:fDlEarfcn=1500  LNADJ-0/LNADJL-13:phyCellId=22
    ...  LNADJ-0/LNADJL-13:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-14:ecgiLcrId=14  LNADJ-0/LNADJL-14:fDlEarfcn=1500  LNADJ-0/LNADJL-14:phyCellId=1
    ...  LNADJ-0/LNADJL-14:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-15:ecgiLcrId=15  LNADJ-0/LNADJL-15:fDlEarfcn=1500  LNADJ-0/LNADJL-15:phyCellId=2
    ...  LNADJ-0/LNADJL-15:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-16:ecgiLcrId=16  LNADJ-0/LNADJL-16:fDlEarfcn=1650  LNADJ-0/LNADJL-16:phyCellId=3
    ...  LNADJ-0/LNADJL-16:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-1:ecgiLcrId=1  LNADJ-1/LNADJL-1:fDlEarfcn=1500  LNADJ-1/LNADJL-1:phyCellId=305
    ...  LNADJ-1/LNADJL-1:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-2:ecgiLcrId=2  LNADJ-1/LNADJL-2:fDlEarfcn=1500  LNADJ-1/LNADJL-2:phyCellId=315
    ...  LNADJ-1/LNADJL-2:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-3:ecgiLcrId=3  LNADJ-1/LNADJL-3:fDlEarfcn=1500  LNADJ-1/LNADJL-3:phyCellId=1
    ...  LNADJ-1/LNADJL-3:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-4:ecgiLcrId=4  LNADJ-1/LNADJL-4:fDlEarfcn=1650  LNADJ-1/LNADJL-4:phyCellId=3
    ...  LNADJ-1/LNADJL-4:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-5:ecgiLcrId=5  LNADJ-1/LNADJL-5:fDlEarfcn=1500  LNADJ-1/LNADJL-5:phyCellId=3
    ...  LNADJ-1/LNADJL-5:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-6:ecgiLcrId=6  LNADJ-1/LNADJL-6:fDlEarfcn=180  LNADJ-1/LNADJL-6:phyCellId=308
    ...  LNADJ-1/LNADJL-6:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-7:ecgiLcrId=7  LNADJ-1/LNADJL-7:fDlEarfcn=180  LNADJ-1/LNADJL-7:phyCellId=318
    ...  LNADJ-1/LNADJL-7:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-8:ecgiLcrId=8  LNADJ-1/LNADJL-8:fDlEarfcn=180  LNADJ-1/LNADJL-8:phyCellId=328
    ...  LNADJ-1/LNADJL-8:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-9:ecgiLcrId=9  LNADJ-1/LNADJL-9:fDlEarfcn=1500  LNADJ-1/LNADJL-9:phyCellId=10
    ...  LNADJ-1/LNADJL-9:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-10:ecgiLcrId=10  LNADJ-1/LNADJL-10:fDlEarfcn=1500  LNADJ-1/LNADJL-10:phyCellId=11
    ...  LNADJ-1/LNADJL-10:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-11:ecgiLcrId=11  LNADJ-1/LNADJL-11:fDlEarfcn=1500  LNADJ-1/LNADJL-11:phyCellId=12
    ...  LNADJ-1/LNADJL-11:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-12:ecgiLcrId=12  LNADJ-1/LNADJL-12:fDlEarfcn=1500  LNADJ-1/LNADJL-12:phyCellId=13
    ...  LNADJ-1/LNADJL-12:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-13:ecgiLcrId=13  LNADJ-1/LNADJL-13:fDlEarfcn=1500  LNADJ-1/LNADJL-13:phyCellId=14
    ...  LNADJ-1/LNADJL-13:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-14:ecgiLcrId=14  LNADJ-1/LNADJL-14:fDlEarfcn=1500  LNADJ-1/LNADJL-14:phyCellId=15
    ...  LNADJ-1/LNADJL-14:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-15:ecgiLcrId=15  LNADJ-1/LNADJL-15:tac=5580  LNADJ-1/LNADJL-15:fDlEarfcn=1500
    ...  LNADJ-1/LNADJL-15:phyCellId=16
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-16:ecgiLcrId=16  LNADJ-1/LNADJL-16:fDlEarfcn=1500  LNADJ-1/LNADJL-16:phyCellId=17
    ...  LNADJ-1/LNADJL-16:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-17:ecgiLcrId=17  LNADJ-1/LNADJL-17:fDlEarfcn=1500  LNADJ-1/LNADJL-17:phyCellId=18
    ...  LNADJ-1/LNADJL-17:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-18:ecgiLcrId=18  LNADJ-1/LNADJL-18:fDlEarfcn=1500  LNADJ-1/LNADJL-18:phyCellId=19
    ...  LNADJ-1/LNADJL-18:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-19:ecgiLcrId=19  LNADJ-1/LNADJL-19:fDlEarfcn=1500  LNADJ-1/LNADJL-19:phyCellId=20
    ...  LNADJ-1/LNADJL-19:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-20:ecgiLcrId=20  LNADJ-1/LNADJL-20:fDlEarfcn=1500  LNADJ-1/LNADJL-20:phyCellId=21
    ...  LNADJ-1/LNADJL-20:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-21:ecgiLcrId=21  LNADJ-1/LNADJL-21:fDlEarfcn=1500  LNADJ-1/LNADJL-21:phyCellId=22
    ...  LNADJ-1/LNADJL-21:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-22:ecgiLcrId=22  LNADJ-1/LNADJL-22:fDlEarfcn=1500  LNADJ-1/LNADJL-22:phyCellId=23
    ...  LNADJ-1/LNADJL-22:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-1:ecgiLcrId=1  LNADJ-2/LNADJL-1:fDlEarfcn=1500  LNADJ-2/LNADJL-1:phyCellId=1
    ...  LNADJ-2/LNADJL-1:tac=5580  LNADJ-2/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-2:ecgiLcrId=2  LNADJ-2/LNADJL-2:fDlEarfcn=1500  LNADJ-2/LNADJL-2:phyCellId=2
    ...  LNADJ-2/LNADJL-2:tac=5580  LNADJ-2/LNADJL-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-3:ecgiLcrId=3  LNADJ-2/LNADJL-3:fDlEarfcn=1650  LNADJ-2/LNADJL-3:phyCellId=3
    ...  LNADJ-2/LNADJL-3:tac=5580  LNADJ-2/LNADJL-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-1:ecgiAdjEnbId=557  LNCEL-1/LNREL-1:ecgiLcrId=4
    ...  LNCEL-1/LNREL-1:removeAllowed=true  LNCEL-1/LNREL-1:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-2:ecgiAdjEnbId=557  LNCEL-1/LNREL-2:ecgiLcrId=5
    ...  LNCEL-1/LNREL-2:removeAllowed=true  LNCEL-1/LNREL-2:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-3:ecgiAdjEnbId=1  LNCEL-1/LNREL-3:ecgiLcrId=2
    ...  LNCEL-1/LNREL-3:removeAllowed=true  LNCEL-1/LNREL-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-7:ecgiAdjEnbId=1  LNCEL-1/LNREL-7:ecgiLcrId=3
    ...  LNCEL-1/LNREL-7:removeAllowed=false  LNCEL-1/LNREL-7:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-8:ecgiAdjEnbId=559  LNCEL-1/LNREL-8:ecgiLcrId=1
    ...  LNCEL-1/LNREL-8:removeAllowed=false  LNCEL-1/LNREL-8:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-9:ecgiAdjEnbId=560  LNCEL-1/LNREL-9:ecgiLcrId=1
    ...  LNCEL-1/LNREL-9:removeAllowed=false  LNCEL-1/LNREL-9:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-10:ecgiAdjEnbId=557  LNCEL-1/LNREL-10:ecgiLcrId=9
    ...  LNCEL-1/LNREL-10:removeAllowed=false  LNCEL-1/LNREL-10:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-11:ecgiAdjEnbId=557  LNCEL-1/LNREL-11:ecgiLcrId=10
    ...  LNCEL-1/LNREL-11:removeAllowed=false  LNCEL-1/LNREL-11:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-12:ecgiAdjEnbId=557  LNCEL-1/LNREL-12:ecgiLcrId=11
    ...  LNCEL-1/LNREL-12:removeAllowed=false  LNCEL-1/LNREL-12:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-13:ecgiAdjEnbId=500  LNCEL-1/LNREL-13:ecgiLcrId=14
    ...  LNCEL-1/LNREL-13:removeAllowed=true  LNCEL-1/LNREL-13:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-14:ecgiAdjEnbId=502  LNCEL-1/LNREL-14:ecgiLcrId=1
    ...  LNCEL-1/LNREL-14:removeAllowed=false  LNCEL-1/LNREL-14:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-1:ecgiAdjEnbId=557  LNCEL-2/LNREL-1:ecgiLcrId=4
    ...  LNCEL-2/LNREL-1:removeAllowed=true  LNCEL-2/LNREL-1:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-2:ecgiAdjEnbId=557  LNCEL-2/LNREL-2:ecgiLcrId=5
    ...  LNCEL-2/LNREL-2:removeAllowed=true  LNCEL-2/LNREL-2:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-3:ecgiAdjEnbId=1  LNCEL-2/LNREL-3:ecgiLcrId=1
    ...  LNCEL-2/LNREL-3:removeAllowed=true  LNCEL-2/LNREL-3:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-4:ecgiAdjEnbId=1  LNCEL-2/LNREL-4:ecgiLcrId=3
    ...  LNCEL-2/LNREL-4:removeAllowed=true  LNCEL-2/LNREL-4:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-5:ecgiAdjEnbId=559  LNCEL-2/LNREL-5:ecgiLcrId=1
    ...  LNCEL-2/LNREL-5:removeAllowed=true  LNCEL-2/LNREL-5:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-6:ecgiAdjEnbId=560  LNCEL-2/LNREL-6:ecgiLcrId=1
    ...  LNCEL-2/LNREL-6:removeAllowed=true  LNCEL-2/LNREL-6:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-7:ecgiAdjEnbId=560  LNCEL-2/LNREL-7:ecgiLcrId=2
    ...  LNCEL-2/LNREL-7:removeAllowed=true  LNCEL-2/LNREL-7:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-8:ecgiAdjEnbId=560  LNCEL-2/LNREL-8:ecgiLcrId=3
    ...  LNCEL-2/LNREL-8:removeAllowed=true  LNCEL-2/LNREL-8:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-9:ecgiAdjEnbId=500  LNCEL-2/LNREL-9:ecgiLcrId=1
    ...  LNCEL-2/LNREL-9:removeAllowed=true  LNCEL-2/LNREL-9:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-10:ecgiAdjEnbId=500  LNCEL-2/LNREL-10:ecgiLcrId=2
    ...  LNCEL-2/LNREL-10:removeAllowed=true  LNCEL-2/LNREL-10:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-11:ecgiAdjEnbId=500  LNCEL-2/LNREL-11:ecgiLcrId=3
    ...  LNCEL-2/LNREL-11:removeAllowed=true  LNCEL-2/LNREL-11:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-12:ecgiAdjEnbId=500  LNCEL-2/LNREL-12:ecgiLcrId=4
    ...  LNCEL-2/LNREL-12:removeAllowed=true  LNCEL-2/LNREL-12:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-13:ecgiAdjEnbId=500  LNCEL-2/LNREL-13:ecgiLcrId=5
    ...  LNCEL-2/LNREL-13:removeAllowed=true  LNCEL-2/LNREL-13:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-14:ecgiAdjEnbId=500  LNCEL-2/LNREL-14:ecgiLcrId=6
    ...  LNCEL-2/LNREL-14:removeAllowed=true  LNCEL-2/LNREL-14:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-15:ecgiAdjEnbId=500  LNCEL-2/LNREL-15:ecgiLcrId=7
    ...  LNCEL-2/LNREL-15:removeAllowed=true  LNCEL-2/LNREL-15:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-16:ecgiAdjEnbId=500  LNCEL-2/LNREL-16:ecgiLcrId=8
    ...  LNCEL-2/LNREL-16:removeAllowed=false  LNCEL-2/LNREL-16:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-17:ecgiAdjEnbId=500  LNCEL-2/LNREL-17:ecgiLcrId=9
    ...  LNCEL-2/LNREL-17:removeAllowed=false  LNCEL-2/LNREL-17:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-18:ecgiAdjEnbId=500  LNCEL-2/LNREL-18:ecgiLcrId=10
    ...  LNCEL-2/LNREL-18:removeAllowed=false  LNCEL-2/LNREL-18:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-19:ecgiAdjEnbId=500  LNCEL-2/LNREL-19:ecgiLcrId=11
    ...  LNCEL-2/LNREL-19:removeAllowed=false  LNCEL-2/LNREL-19:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-20:ecgiAdjEnbId=500  LNCEL-2/LNREL-20:ecgiLcrId=12
    ...  LNCEL-2/LNREL-20:removeAllowed=false  LNCEL-2/LNREL-20:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-21:ecgiAdjEnbId=500  LNCEL-2/LNREL-21:ecgiLcrId=13
    ...  LNCEL-2/LNREL-21:removeAllowed=false  LNCEL-2/LNREL-21:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-101:ecgiAdjEnbId=501  LNCEL-2/LNREL-101:ecgiLcrId=1
    ...  LNCEL-2/LNREL-101:removeAllowed=true  LNCEL-2/LNREL-101:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-102:ecgiAdjEnbId=501  LNCEL-2/LNREL-102:ecgiLcrId=2
    ...  LNCEL-2/LNREL-102:removeAllowed=true  LNCEL-2/LNREL-102:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-103:ecgiAdjEnbId=501  LNCEL-2/LNREL-103:ecgiLcrId=3
    ...  LNCEL-2/LNREL-103:removeAllowed=true  LNCEL-2/LNREL-103:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-104:ecgiAdjEnbId=501  LNCEL-2/LNREL-104:ecgiLcrId=4
    ...  LNCEL-2/LNREL-104:removeAllowed=false  LNCEL-2/LNREL-104:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-105:ecgiAdjEnbId=501  LNCEL-2/LNREL-105:ecgiLcrId=5
    ...  LNCEL-2/LNREL-105:removeAllowed=false  LNCEL-2/LNREL-105:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-106:ecgiAdjEnbId=501  LNCEL-2/LNREL-106:ecgiLcrId=6
    ...  LNCEL-2/LNREL-106:removeAllowed=false  LNCEL-2/LNREL-106:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-107:ecgiAdjEnbId=501  LNCEL-2/LNREL-107:ecgiLcrId=7
    ...  LNCEL-2/LNREL-107:removeAllowed=true  LNCEL-2/LNREL-107:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-108:ecgiAdjEnbId=501  LNCEL-2/LNREL-108:ecgiLcrId=8
    ...  LNCEL-2/LNREL-108:removeAllowed=true  LNCEL-2/LNREL-108:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-109:ecgiAdjEnbId=501  LNCEL-2/LNREL-109:ecgiLcrId=9
    ...  LNCEL-2/LNREL-109:removeAllowed=false  LNCEL-2/LNREL-109:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-110:ecgiAdjEnbId=501  LNCEL-2/LNREL-110:ecgiLcrId=10
    ...  LNCEL-2/LNREL-110:removeAllowed=false  LNCEL-2/LNREL-110:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-111:ecgiAdjEnbId=501  LNCEL-2/LNREL-111:ecgiLcrId=11
    ...  LNCEL-2/LNREL-111:removeAllowed=false  LNCEL-2/LNREL-111:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-112:ecgiAdjEnbId=501  LNCEL-2/LNREL-112:ecgiLcrId=12
    ...  LNCEL-2/LNREL-112:removeAllowed=true  LNCEL-2/LNREL-112:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-113:ecgiAdjEnbId=501  LNCEL-2/LNREL-113:ecgiLcrId=13
    ...  LNCEL-2/LNREL-113:removeAllowed=false  LNCEL-2/LNREL-113:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-114:ecgiAdjEnbId=501  LNCEL-2/LNREL-114:ecgiLcrId=14
    ...  LNCEL-2/LNREL-114:removeAllowed=false  LNCEL-2/LNREL-114:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-115:ecgiAdjEnbId=501  LNCEL-2/LNREL-115:ecgiLcrId=15
    ...  LNCEL-2/LNREL-115:removeAllowed=false  LNCEL-2/LNREL-115:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-116:ecgiAdjEnbId=501  LNCEL-2/LNREL-116:ecgiLcrId=16
    ...  LNCEL-2/LNREL-116:removeAllowed=false  LNCEL-2/LNREL-116:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-117:ecgiAdjEnbId=501  LNCEL-2/LNREL-117:ecgiLcrId=17
    ...  LNCEL-2/LNREL-117:removeAllowed=false  LNCEL-2/LNREL-117:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-118:ecgiAdjEnbId=501  LNCEL-2/LNREL-118:ecgiLcrId=18
    ...  LNCEL-2/LNREL-118:removeAllowed=false  LNCEL-2/LNREL-118:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-119:ecgiAdjEnbId=501  LNCEL-2/LNREL-119:ecgiLcrId=19
    ...  LNCEL-2/LNREL-119:removeAllowed=false  LNCEL-2/LNREL-119:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-120:ecgiAdjEnbId=501  LNCEL-2/LNREL-120:ecgiLcrId=20
    ...  LNCEL-2/LNREL-120:removeAllowed=false  LNCEL-2/LNREL-120:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-121:ecgiAdjEnbId=501  LNCEL-2/LNREL-121:ecgiLcrId=21
    ...  LNCEL-2/LNREL-121:removeAllowed=false  LNCEL-2/LNREL-121:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-22:ecgiAdjEnbId=500  LNCEL-2/LNREL-22:ecgiLcrId=15
    ...  LNCEL-2/LNREL-22:removeAllowed=true  LNCEL-2/LNREL-22:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-23:ecgiAdjEnbId=502  LNCEL-2/LNREL-23:ecgiLcrId=2
    ...  LNCEL-2/LNREL-23:removeAllowed=false  LNCEL-2/LNREL-23:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-1:ecgiAdjEnbId=500  LNCEL-3/LNREL-1:ecgiLcrId=16
    ...  LNCEL-3/LNREL-1:removeAllowed=true  LNCEL-3/LNREL-1:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-2:ecgiAdjEnbId=502  LNCEL-3/LNREL-2:ecgiLcrId=3
    ...  LNCEL-3/LNREL-2:removeAllowed=false  LNCEL-3/LNREL-2:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=6    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=7    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=8    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}

Check RTPM Counter
    [Arguments]    ${file_name}
    Start Rtpm Counter
    sleep    60s    #wait a minute to collect RTPM
    Check Rtpm Counters    pm_reference_file=${CURDIR}/data/${file_name}.txt

Check Neighbour Status For Instance 2
    ${object_list}    Create List    LNADJW-0:sourceOfData=OM
    Object Should Exist    ${object_list}
    ${scf}=    Download Scf
    ${object_list}    Create List    LNADJW-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJW-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJW-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-0:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-1:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-2:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-4:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-5:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-6:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-7:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-8:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-9:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-10:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-11:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-12:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-13:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-14:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-15:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-16:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-17:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-18:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-19:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-20:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-21:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-22:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-23:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-24:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-25:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-26:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-27:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-28:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-29:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-30:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-31:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-32:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-1/LNRELW-33:nrStatus=available
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-34:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-35:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-99:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-1/LNRELW-100:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-0:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-1:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-2:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-33:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-34:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    comment    Check failure
    ${object_list}    Create List    LNCEL-2/LNRELW-200:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNCEL-2/LNRELW-201:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-57:cPlaneIpAddrCtrl=enbControlled    LNADJ-57:adjEnbId=557
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-59:cPlaneIpAddrCtrl=enbControlled    LNADJ-59:adjEnbId=559
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-60:cPlaneIpAddrCtrl=enbControlled    LNADJ-60:adjEnbId=560
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-0:cPlaneIpAddrCtrl=enbControlled    LNADJ-0:adjEnbId=500
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-1:cPlaneIpAddrCtrl=enbControlled    LNADJ-1:adjEnbId=501
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}    Create List    LNADJ-2:cPlaneIpAddrCtrl=enbControlled    LNADJ-2:adjEnbId=502
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-57/LNADJL-1:ecgiLcrId=4  LNADJ-57/LNADJL-1:fDlEarfcn=1500  LNADJ-57/LNADJL-1:phyCellId=305
    ...  LNADJ-57/LNADJL-1:tac=5580  LNADJ-57/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNADJ-57/LNADJL:ecgiLcrId=5
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_not_list}    Create List    LNADJ-59/LNADJL:ecgiLcrId=1
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-57/LNADJL-4:ecgiLcrId=7  LNADJ-57/LNADJL-4:fDlEarfcn=1500  LNADJ-57/LNADJL-4:phyCellId=335
    ...  LNADJ-57/LNADJL-4:tac=5580  LNADJ-57/LNADJL-4:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-57/LNADJL-6:ecgiLcrId=9  LNADJ-57/LNADJL-6:fDlEarfcn=1500  LNADJ-57/LNADJL-6:phyCellId=355
    ...  LNADJ-57/LNADJL-6:tac=5580  LNADJ-57/LNADJL-6:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    comment    herere
    ${object_not_list}    Create List    LNADJ-60/LNADJL:ecgiLcrId=1
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-60/LNADJL-2:ecgiLcrId=2  LNADJ-60/LNADJL-2:fDlEarfcn=180  LNADJ-60/LNADJL-2:phyCellId=318
    ...  LNADJ-60/LNADJL-2:tac=5580  LNADJ-60/LNADJL-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-60/LNADJL-3:ecgiLcrId=3  LNADJ-60/LNADJL-3:fDlEarfcn=180  LNADJ-60/LNADJL-3:phyCellId=328
    ...  LNADJ-60/LNADJL-3:tac=5580  LNADJ-60/LNADJL-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-1:ecgiLcrId=1  LNADJ-0/LNADJL-1:fDlEarfcn=1500  LNADJ-0/LNADJL-1:phyCellId=10
    ...  LNADJ-0/LNADJL-1:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-2:ecgiLcrId=2  LNADJ-0/LNADJL-2:fDlEarfcn=1500  LNADJ-0/LNADJL-2:phyCellId=11
    ...  LNADJ-0/LNADJL-2:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-3:ecgiLcrId=3  LNADJ-0/LNADJL-3:fDlEarfcn=1500  LNADJ-0/LNADJL-3:phyCellId=12
    ...  LNADJ-0/LNADJL-3:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-4:ecgiLcrId=4  LNADJ-0/LNADJL-4:fDlEarfcn=1500  LNADJ-0/LNADJL-4:phyCellId=13
    ...  LNADJ-0/LNADJL-4:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-5:ecgiLcrId=5  LNADJ-0/LNADJL-5:fDlEarfcn=1500  LNADJ-0/LNADJL-5:phyCellId=14
    ...  LNADJ-0/LNADJL-5:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-6:ecgiLcrId=6  LNADJ-0/LNADJL-6:fDlEarfcn=1500  LNADJ-0/LNADJL-6:phyCellId=15
    ...  LNADJ-0/LNADJL-6:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-7:ecgiLcrId=7  LNADJ-0/LNADJL-7:fDlEarfcn=1500  LNADJ-0/LNADJL-7:phyCellId=16
    ...  LNADJ-0/LNADJL-7:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-8:ecgiLcrId=8  LNADJ-0/LNADJL-8:fDlEarfcn=1500  LNADJ-0/LNADJL-8:phyCellId=17
    ...  LNADJ-0/LNADJL-8:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-9:ecgiLcrId=9  LNADJ-0/LNADJL-9:fDlEarfcn=1500  LNADJ-0/LNADJL-9:phyCellId=18
    ...  LNADJ-0/LNADJL-9:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-10:ecgiLcrId=10  LNADJ-0/LNADJL-10:fDlEarfcn=1500  LNADJ-0/LNADJL-10:phyCellId=19
    ...  LNADJ-0/LNADJL-10:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-11:ecgiLcrId=11  LNADJ-0/LNADJL-11:fDlEarfcn=1500  LNADJ-0/LNADJL-11:phyCellId=20
    ...  LNADJ-0/LNADJL-11:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-12:ecgiLcrId=12  LNADJ-0/LNADJL-12:fDlEarfcn=1500  LNADJ-0/LNADJL-12:phyCellId=21
    ...  LNADJ-0/LNADJL-12:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-13:ecgiLcrId=13  LNADJ-0/LNADJL-13:fDlEarfcn=1500  LNADJ-0/LNADJL-13:phyCellId=22
    ...  LNADJ-0/LNADJL-13:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-14:ecgiLcrId=14  LNADJ-0/LNADJL-14:fDlEarfcn=1500  LNADJ-0/LNADJL-14:phyCellId=1
    ...  LNADJ-0/LNADJL-14:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-15:ecgiLcrId=15  LNADJ-0/LNADJL-15:fDlEarfcn=1500  LNADJ-0/LNADJL-15:phyCellId=2
    ...  LNADJ-0/LNADJL-15:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-0/LNADJL-16:ecgiLcrId=16  LNADJ-0/LNADJL-16:fDlEarfcn=1650  LNADJ-0/LNADJL-16:phyCellId=3
    ...  LNADJ-0/LNADJL-16:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-1:ecgiLcrId=1  LNADJ-1/LNADJL-1:fDlEarfcn=1500  LNADJ-1/LNADJL-1:phyCellId=305
    ...  LNADJ-1/LNADJL-1:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-2:ecgiLcrId=2  LNADJ-1/LNADJL-2:fDlEarfcn=1500  LNADJ-1/LNADJL-2:phyCellId=315
    ...  LNADJ-1/LNADJL-2:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-3:ecgiLcrId=3  LNADJ-1/LNADJL-3:fDlEarfcn=1500  LNADJ-1/LNADJL-3:phyCellId=1
    ...  LNADJ-1/LNADJL-3:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-4:ecgiLcrId=4  LNADJ-1/LNADJL-4:fDlEarfcn=1650  LNADJ-1/LNADJL-4:phyCellId=3
    ...  LNADJ-1/LNADJL-4:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-5:ecgiLcrId=5  LNADJ-1/LNADJL-5:fDlEarfcn=1500  LNADJ-1/LNADJL-5:phyCellId=3
    ...  LNADJ-1/LNADJL-5:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-6:ecgiLcrId=6  LNADJ-1/LNADJL-6:fDlEarfcn=180  LNADJ-1/LNADJL-6:phyCellId=308
    ...  LNADJ-1/LNADJL-6:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-7:ecgiLcrId=7  LNADJ-1/LNADJL-7:fDlEarfcn=180  LNADJ-1/LNADJL-7:phyCellId=318
    ...  LNADJ-1/LNADJL-7:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-8:ecgiLcrId=8  LNADJ-1/LNADJL-8:fDlEarfcn=180  LNADJ-1/LNADJL-8:phyCellId=328
    ...  LNADJ-1/LNADJL-8:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-9:ecgiLcrId=9  LNADJ-1/LNADJL-9:fDlEarfcn=1500  LNADJ-1/LNADJL-9:phyCellId=10
    ...  LNADJ-1/LNADJL-9:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-10:ecgiLcrId=10  LNADJ-1/LNADJL-10:fDlEarfcn=1500  LNADJ-1/LNADJL-10:phyCellId=11
    ...  LNADJ-1/LNADJL-10:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-11:ecgiLcrId=11  LNADJ-1/LNADJL-11:fDlEarfcn=1500  LNADJ-1/LNADJL-11:phyCellId=12
    ...  LNADJ-1/LNADJL-11:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-12:ecgiLcrId=12  LNADJ-1/LNADJL-12:fDlEarfcn=1500  LNADJ-1/LNADJL-12:phyCellId=13
    ...  LNADJ-1/LNADJL-12:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-13:ecgiLcrId=13  LNADJ-1/LNADJL-13:fDlEarfcn=1500  LNADJ-1/LNADJL-13:phyCellId=14
    ...  LNADJ-1/LNADJL-13:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-14:ecgiLcrId=14  LNADJ-1/LNADJL-14:fDlEarfcn=1500  LNADJ-1/LNADJL-14:phyCellId=15
    ...  LNADJ-1/LNADJL-14:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-15:ecgiLcrId=15  LNADJ-1/LNADJL-15:tac=5580  LNADJ-1/LNADJL-15:fDlEarfcn=1500
    ...  LNADJ-1/LNADJL-15:phyCellId=16
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-16:ecgiLcrId=16  LNADJ-1/LNADJL-16:fDlEarfcn=1500  LNADJ-1/LNADJL-16:phyCellId=17
    ...  LNADJ-1/LNADJL-16:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-17:ecgiLcrId=17  LNADJ-1/LNADJL-17:fDlEarfcn=1500  LNADJ-1/LNADJL-17:phyCellId=18
    ...  LNADJ-1/LNADJL-17:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-18:ecgiLcrId=18  LNADJ-1/LNADJL-18:fDlEarfcn=1500  LNADJ-1/LNADJL-18:phyCellId=19
    ...  LNADJ-1/LNADJL-18:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-19:ecgiLcrId=19  LNADJ-1/LNADJL-19:fDlEarfcn=1500  LNADJ-1/LNADJL-19:phyCellId=20
    ...  LNADJ-1/LNADJL-19:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-20:ecgiLcrId=20  LNADJ-1/LNADJL-20:fDlEarfcn=1500  LNADJ-1/LNADJL-20:phyCellId=21
    ...  LNADJ-1/LNADJL-20:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-21:ecgiLcrId=21  LNADJ-1/LNADJL-21:fDlEarfcn=1500  LNADJ-1/LNADJL-21:phyCellId=22
    ...  LNADJ-1/LNADJL-21:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-22:ecgiLcrId=22  LNADJ-1/LNADJL-22:fDlEarfcn=1500  LNADJ-1/LNADJL-22:phyCellId=23
    ...  LNADJ-1/LNADJL-22:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-1/LNADJL-23:ecgiLcrId=23  LNADJ-1/LNADJL-23:fDlEarfcn=1500  LNADJ-1/LNADJL-23:phyCellId=24
    ...  LNADJ-1/LNADJL-23:tac=5580
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-1:ecgiLcrId=1  LNADJ-2/LNADJL-1:fDlEarfcn=1500  LNADJ-2/LNADJL-1:phyCellId=1
    ...  LNADJ-2/LNADJL-1:tac=5580  LNADJ-2/LNADJL-1:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-2:ecgiLcrId=2  LNADJ-2/LNADJL-2:fDlEarfcn=1500  LNADJ-2/LNADJL-2:phyCellId=2
    ...  LNADJ-2/LNADJL-2:tac=5580  LNADJ-2/LNADJL-2:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNADJ-2/LNADJL-3:ecgiLcrId=3  LNADJ-2/LNADJL-3:fDlEarfcn=1650  LNADJ-2/LNADJL-3:phyCellId=3
    ...  LNADJ-2/LNADJL-3:tac=5580  LNADJ-2/LNADJL-3:sourceOfData=OM
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-1/LNREL:ecgiAdjEnbId=557    LNCEL-1/LNREL:ecgiLcrId=4
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-1/LNREL:ecgiAdjEnbId=557    LNCEL-1/LNREL:ecgiLcrId=5
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-3:ecgiAdjEnbId=1  LNCEL-1/LNREL-3:ecgiLcrId=2
    ...  LNCEL-1/LNREL-3:removeAllowed=true  LNCEL-1/LNREL-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-1/LNREL:ecgiAdjEnbId=1    LNCEL-1/LNREL:ecgiLcrId=3
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-8:ecgiAdjEnbId=559  LNCEL-1/LNREL-8:ecgiLcrId=1
    ...  LNCEL-1/LNREL-8:removeAllowed=false  LNCEL-1/LNREL-8:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-9:ecgiAdjEnbId=560  LNCEL-1/LNREL-9:ecgiLcrId=1
    ...  LNCEL-1/LNREL-9:removeAllowed=false  LNCEL-1/LNREL-9:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-10:ecgiAdjEnbId=557  LNCEL-1/LNREL-10:ecgiLcrId=9
    ...  LNCEL-1/LNREL-10:removeAllowed=false  LNCEL-1/LNREL-10:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-11:ecgiAdjEnbId=557  LNCEL-1/LNREL-11:ecgiLcrId=10
    ...  LNCEL-1/LNREL-11:removeAllowed=false  LNCEL-1/LNREL-11:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-12:ecgiAdjEnbId=557  LNCEL-1/LNREL-12:ecgiLcrId=11
    ...  LNCEL-1/LNREL-12:removeAllowed=false  LNCEL-1/LNREL-12:nrStatus=unavailable
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-13:ecgiAdjEnbId=500  LNCEL-1/LNREL-13:ecgiLcrId=14
    ...  LNCEL-1/LNREL-13:removeAllowed=true  LNCEL-1/LNREL-13:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-1/LNREL-14:ecgiAdjEnbId=502  LNCEL-1/LNREL-14:ecgiLcrId=1
    ...  LNCEL-1/LNREL-14:removeAllowed=false  LNCEL-1/LNREL-14:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-1:ecgiAdjEnbId=557  LNCEL-2/LNREL-1:ecgiLcrId=4
    ...  LNCEL-2/LNREL-1:removeAllowed=true  LNCEL-2/LNREL-1:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-2/LNREL:ecgiAdjEnbId=557    LNCEL-2/LNREL:ecgiLcrId=5
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-3:ecgiAdjEnbId=1  LNCEL-2/LNREL-3:ecgiLcrId=1
    ...  LNCEL-2/LNREL-3:removeAllowed=true  LNCEL-2/LNREL-3:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-4:ecgiAdjEnbId=1  LNCEL-2/LNREL-4:ecgiLcrId=3
    ...  LNCEL-2/LNREL-4:removeAllowed=true  LNCEL-2/LNREL-4:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-2/LNREL:ecgiAdjEnbId=559    LNCEL-2/LNREL:ecgiLcrId=1
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_not_list}    Create List    LNCEL-2/LNREL:ecgiAdjEnbId=560    LNCEL-2/LNREL:ecgiLcrId=1
    Object Should Not Exist    ${object_not_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-7:ecgiAdjEnbId=560  LNCEL-2/LNREL-7:ecgiLcrId=2
    ...  LNCEL-2/LNREL-7:removeAllowed=true  LNCEL-2/LNREL-7:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-8:ecgiAdjEnbId=560  LNCEL-2/LNREL-8:ecgiLcrId=3
    ...  LNCEL-2/LNREL-8:removeAllowed=true  LNCEL-2/LNREL-8:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-9:ecgiAdjEnbId=500  LNCEL-2/LNREL-9:ecgiLcrId=1
    ...  LNCEL-2/LNREL-9:removeAllowed=true  LNCEL-2/LNREL-9:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-10:ecgiAdjEnbId=500  LNCEL-2/LNREL-10:ecgiLcrId=2
    ...  LNCEL-2/LNREL-10:removeAllowed=true  LNCEL-2/LNREL-10:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-11:ecgiAdjEnbId=500  LNCEL-2/LNREL-11:ecgiLcrId=3
    ...  LNCEL-2/LNREL-11:removeAllowed=true  LNCEL-2/LNREL-11:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-12:ecgiAdjEnbId=500  LNCEL-2/LNREL-12:ecgiLcrId=4
    ...  LNCEL-2/LNREL-12:removeAllowed=true  LNCEL-2/LNREL-12:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-13:ecgiAdjEnbId=500  LNCEL-2/LNREL-13:ecgiLcrId=5
    ...  LNCEL-2/LNREL-13:removeAllowed=true  LNCEL-2/LNREL-13:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-14:ecgiAdjEnbId=500  LNCEL-2/LNREL-14:ecgiLcrId=6
    ...  LNCEL-2/LNREL-14:removeAllowed=true  LNCEL-2/LNREL-14:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-15:ecgiAdjEnbId=500  LNCEL-2/LNREL-15:ecgiLcrId=7
    ...  LNCEL-2/LNREL-15:removeAllowed=true  LNCEL-2/LNREL-15:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-16:ecgiAdjEnbId=500  LNCEL-2/LNREL-16:ecgiLcrId=8
    ...  LNCEL-2/LNREL-16:removeAllowed=false  LNCEL-2/LNREL-16:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-17:ecgiAdjEnbId=500  LNCEL-2/LNREL-17:ecgiLcrId=9
    ...  LNCEL-2/LNREL-17:removeAllowed=false  LNCEL-2/LNREL-17:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-18:ecgiAdjEnbId=500  LNCEL-2/LNREL-18:ecgiLcrId=10
    ...  LNCEL-2/LNREL-18:removeAllowed=false  LNCEL-2/LNREL-18:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-19:ecgiAdjEnbId=500  LNCEL-2/LNREL-19:ecgiLcrId=11
    ...  LNCEL-2/LNREL-19:removeAllowed=false  LNCEL-2/LNREL-19:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-20:ecgiAdjEnbId=500  LNCEL-2/LNREL-20:ecgiLcrId=12
    ...  LNCEL-2/LNREL-20:removeAllowed=false  LNCEL-2/LNREL-20:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-21:ecgiAdjEnbId=500  LNCEL-2/LNREL-21:ecgiLcrId=13
    ...  LNCEL-2/LNREL-21:removeAllowed=false  LNCEL-2/LNREL-21:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-101:ecgiAdjEnbId=501  LNCEL-2/LNREL-101:ecgiLcrId=1
    ...  LNCEL-2/LNREL-101:removeAllowed=true  LNCEL-2/LNREL-101:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-102:ecgiAdjEnbId=501  LNCEL-2/LNREL-102:ecgiLcrId=2
    ...  LNCEL-2/LNREL-102:removeAllowed=true  LNCEL-2/LNREL-102:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-103:ecgiAdjEnbId=501  LNCEL-2/LNREL-103:ecgiLcrId=3
    ...  LNCEL-2/LNREL-103:removeAllowed=true  LNCEL-2/LNREL-103:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-104:ecgiAdjEnbId=501  LNCEL-2/LNREL-104:ecgiLcrId=4
    ...  LNCEL-2/LNREL-104:removeAllowed=false  LNCEL-2/LNREL-104:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-105:ecgiAdjEnbId=501  LNCEL-2/LNREL-105:ecgiLcrId=5
    ...  LNCEL-2/LNREL-105:removeAllowed=false  LNCEL-2/LNREL-105:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-106:ecgiAdjEnbId=501  LNCEL-2/LNREL-106:ecgiLcrId=6
    ...  LNCEL-2/LNREL-106:removeAllowed=false  LNCEL-2/LNREL-106:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-107:ecgiAdjEnbId=501  LNCEL-2/LNREL-107:ecgiLcrId=7
    ...  LNCEL-2/LNREL-107:removeAllowed=true  LNCEL-2/LNREL-107:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-108:ecgiAdjEnbId=501  LNCEL-2/LNREL-108:ecgiLcrId=8
    ...  LNCEL-2/LNREL-108:removeAllowed=true  LNCEL-2/LNREL-108:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-109:ecgiAdjEnbId=501  LNCEL-2/LNREL-109:ecgiLcrId=9
    ...  LNCEL-2/LNREL-109:removeAllowed=false  LNCEL-2/LNREL-109:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-110:ecgiAdjEnbId=501  LNCEL-2/LNREL-110:ecgiLcrId=10
    ...  LNCEL-2/LNREL-110:removeAllowed=false  LNCEL-2/LNREL-110:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-111:ecgiAdjEnbId=501  LNCEL-2/LNREL-111:ecgiLcrId=11
    ...  LNCEL-2/LNREL-111:removeAllowed=false  LNCEL-2/LNREL-111:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-112:ecgiAdjEnbId=501  LNCEL-2/LNREL-112:ecgiLcrId=12
    ...  LNCEL-2/LNREL-112:removeAllowed=true  LNCEL-2/LNREL-112:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-113:ecgiAdjEnbId=501  LNCEL-2/LNREL-113:ecgiLcrId=13
    ...  LNCEL-2/LNREL-113:removeAllowed=false  LNCEL-2/LNREL-113:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-114:ecgiAdjEnbId=501  LNCEL-2/LNREL-114:ecgiLcrId=14
    ...  LNCEL-2/LNREL-114:removeAllowed=false  LNCEL-2/LNREL-114:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-115:ecgiAdjEnbId=501  LNCEL-2/LNREL-115:ecgiLcrId=15
    ...  LNCEL-2/LNREL-115:removeAllowed=false  LNCEL-2/LNREL-115:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-116:ecgiAdjEnbId=501  LNCEL-2/LNREL-116:ecgiLcrId=16
    ...  LNCEL-2/LNREL-116:removeAllowed=false  LNCEL-2/LNREL-116:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-117:ecgiAdjEnbId=501  LNCEL-2/LNREL-117:ecgiLcrId=17
    ...  LNCEL-2/LNREL-117:removeAllowed=false  LNCEL-2/LNREL-117:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-118:ecgiAdjEnbId=501  LNCEL-2/LNREL-118:ecgiLcrId=18
    ...  LNCEL-2/LNREL-118:removeAllowed=false  LNCEL-2/LNREL-118:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-119:ecgiAdjEnbId=501  LNCEL-2/LNREL-119:ecgiLcrId=19
    ...  LNCEL-2/LNREL-119:removeAllowed=false  LNCEL-2/LNREL-119:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-120:ecgiAdjEnbId=501  LNCEL-2/LNREL-120:ecgiLcrId=20
    ...  LNCEL-2/LNREL-120:removeAllowed=false  LNCEL-2/LNREL-120:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-121:ecgiAdjEnbId=501  LNCEL-2/LNREL-121:ecgiLcrId=21
    ...  LNCEL-2/LNREL-121:removeAllowed=false  LNCEL-2/LNREL-121:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-22:ecgiAdjEnbId=500  LNCEL-2/LNREL-22:ecgiLcrId=15
    ...  LNCEL-2/LNREL-22:removeAllowed=true  LNCEL-2/LNREL-22:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-2/LNREL-23:ecgiAdjEnbId=502  LNCEL-2/LNREL-23:ecgiLcrId=2
    ...  LNCEL-2/LNREL-23:removeAllowed=false  LNCEL-2/LNREL-23:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-1:ecgiAdjEnbId=500  LNCEL-3/LNREL-1:ecgiLcrId=16
    ...  LNCEL-3/LNREL-1:removeAllowed=true  LNCEL-3/LNREL-1:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-2:ecgiAdjEnbId=502  LNCEL-3/LNREL-2:ecgiLcrId=3
    ...  LNCEL-3/LNREL-2:removeAllowed=false  LNCEL-3/LNREL-2:nrStatus=invalid
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-3:ecgiAdjEnbId=1  LNCEL-3/LNREL-3:ecgiLcrId=1
    ...  LNCEL-3/LNREL-3:removeAllowed=true  LNCEL-3/LNREL-3:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-4:ecgiAdjEnbId=501  LNCEL-3/LNREL-4:ecgiLcrId=22
    ...  LNCEL-3/LNREL-4:removeAllowed=true  LNCEL-3/LNREL-4:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_list}  Create List  LNCEL-3/LNREL-5:ecgiAdjEnbId=501  LNCEL-3/LNREL-5:ecgiLcrId=23
    ...  LNCEL-3/LNREL-5:removeAllowed=true  LNCEL-3/LNREL-5:nrStatus=available
    Object Should Exist    ${object_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=6    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=7    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}
    ${object_not_in_list}    Create List    LNCEL-1/LNREL:ecgiLcrId=8    LNCEL-1/LNREL:ecgiAdjEnbId=557
    Object Should Not Exist    ${object_not_in_list}    scf=${scf}

Change Neighbor Relation For Instance 2
    ${delta_parameters_LNADJ_LNADJL}  Create List  delete:LNADJ-57/LNADJL-2  delete:LNADJ-59/LNADJL-1  delete:LNADJ-60/LNADJL-1  delete:LNADJW-51
    ...  delete:LNCEL-1/LNREL-1
    ...  delete:LNCEL-1/LNREL-7  delete:LNCEL-2/LNREL-6  delete:LNCEL-1/LNRELG-2  delete:LNCEL-1/LNRELW-33  delete:LNADJG-1
    Append To List    ${delta_parameters_LNADJ_LNADJL}    LNBTS-1:maxNumAnrMoiAllowed=4000
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJG-3:dtm=false  LNADJG-3:bandIndicatorGeran=dcs1800  LNADJG-3:arfcnValueGeran=35
    ...  LNADJG-3:basestationColourCode=5  LNADJG-3:networkColourCode=5
    ...  LNADJG-3:networkControlOrder=NC0  LNADJG-3:systemInfoType=none  LNADJG-3:gTargetCi=30  LNADJG-3:gTargetLac=1  LNADJG-3:mcc=262
    ...  LNADJG-3:mnc=2
    ...    LNADJG-3:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJG-4:dtm=false  LNADJG-4:arfcnValueGeran=40  LNADJG-4:bandIndicatorGeran=dcs1800
    ...  LNADJG-4:basestationColourCode=1  LNADJG-4:networkColourCode=1
    ...  LNADJG-4:networkControlOrder=NC0  LNADJG-4:systemInfoType=none  LNADJG-4:gTargetCi=40  LNADJG-4:gTargetLac=1  LNADJG-4:mcc=262
    ...  LNADJG-4:mnc=2
    ...    LNADJG-4:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJ-1/LNADJL-23:ecgiLcrId=23  LNADJ-1/LNADJL-23:fDlEarfcn=1500
    ...  LNADJ-1/LNADJL-23:phyCellId=24  LNADJ-1/LNADJL-23:tac=5580  LNADJ-1/LNADJL-23:bcPlmnIdList:mcc=666
    ...    LNADJ-1/LNADJL-23:bcPlmnIdList:mnc=58    LNADJ-1/LNADJL-23:bcPlmnIdList:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJ-57/LNADJL-4:ecgiLcrId=7  LNADJ-57/LNADJL-4:fDlEarfcn=1500
    ...  LNADJ-57/LNADJL-4:phyCellId=335  LNADJ-57/LNADJL-4:tac=5580  LNADJ-57/LNADJL-4:bcPlmnIdList:mcc=666
    ...    LNADJ-57/LNADJL-4:bcPlmnIdList:mnc=58    LNADJ-57/LNADJL-4:bcPlmnIdList:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJ-57/LNADJL-6:ecgiLcrId=9  LNADJ-57/LNADJL-6:fDlEarfcn=1500
    ...  LNADJ-57/LNADJL-6:phyCellId=355  LNADJ-57/LNADJL-6:tac=5580  LNADJ-57/LNADJL-6:bcPlmnIdList:mcc=666
    ...    LNADJ-57/LNADJL-6:bcPlmnIdList:mnc=58    LNADJ-57/LNADJL-6:bcPlmnIdList:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJW-59:srvccHoInd=PSandCS  LNADJW-59:uTargetCid=69  LNADJW-59:uTargetFreq=9852
    ...  LNADJW-59:uTargetLac=2  LNADJW-59:uTargetRac=2
    ...  LNADJW-59:uTargetRncId=1  LNADJW-59:uTargetScFdd=269  LNADJW-59:primaryPlmnId:mcc=666  LNADJW-59:primaryPlmnId:mnc=58
    ...  LNADJW-59:primaryPlmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNADJW-60:srvccHoInd=PSandCS  LNADJW-60:uTargetCid=70  LNADJW-60:uTargetFreq=9842
    ...  LNADJW-60:uTargetLac=2  LNADJW-60:uTargetRac=2
    ...  LNADJW-60:uTargetRncId=1  LNADJW-60:uTargetScFdd=270  LNADJW-60:primaryPlmnId:mcc=666  LNADJW-60:primaryPlmnId:mnc=58
    ...  LNADJW-60:primaryPlmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNCEL-3/LNREL-3:amleAllowed=false
    ...  LNCEL-3/LNREL-3:cellIndOffNeigh=0dB  LNCEL-3/LNREL-3:ecgiAdjEnbId=1  LNCEL-3/LNREL-3:ecgiLcrId=1
    ...  LNCEL-3/LNREL-3:handoverAllowed=allowed
    ...  LNCEL-3/LNREL-3:nrControl=automatic  LNCEL-3/LNREL-3:removeAllowed=true
    ...  LNCEL-3/LNREL-3:ecgiPlmnId:mcc=244  LNCEL-3/LNREL-3:ecgiPlmnId:mnc=9
    ...  LNCEL-3/LNREL-3:ecgiPlmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNCEL-3/LNREL-4:amleAllowed=false
    ...  LNCEL-3/LNREL-4:cellIndOffNeigh=0dB  LNCEL-3/LNREL-4:ecgiAdjEnbId=501  LNCEL-3/LNREL-4:ecgiLcrId=22
    ...  LNCEL-3/LNREL-4:handoverAllowed=allowed
    ...  LNCEL-3/LNREL-4:nrControl=automatic  LNCEL-3/LNREL-4:removeAllowed=true
    ...  LNCEL-3/LNREL-4:ecgiPlmnId:mcc=666  LNCEL-3/LNREL-4:ecgiPlmnId:mnc=58
    ...  LNCEL-3/LNREL-4:ecgiPlmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNCEL-3/LNREL-5:amleAllowed=false
    ...  LNCEL-3/LNREL-5:cellIndOffNeigh=0dB  LNCEL-3/LNREL-5:ecgiAdjEnbId=501  LNCEL-3/LNREL-5:ecgiLcrId=23
    ...  LNCEL-3/LNREL-5:handoverAllowed=allowed
    ...  LNCEL-3/LNREL-5:nrControl=automatic  LNCEL-3/LNREL-5:removeAllowed=true
    ...  LNCEL-3/LNREL-5:ecgiPlmnId:mcc=666  LNCEL-3/LNREL-5:ecgiPlmnId:mnc=58
    ...  LNCEL-3/LNREL-5:ecgiPlmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:ci=0
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:eNACCAllowed=allowed  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:lac=1
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:nrControl=automatic
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:redirWithSysInfoAllowed=forbidden
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:srvccAllowed=allowed  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:plmnId:mcc=262
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:plmnId:mnc=2  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-0:plmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:ci=40
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:eNACCAllowed=allowed  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:lac=1
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:nrControl=automatic
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:redirWithSysInfoAllowed=forbidden
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:srvccAllowed=allowed  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:plmnId:mcc=262
    ...  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:plmnId:mnc=2  MRBTS-1/LNBTS-1/LNCEL-1/LNRELG-4:plmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNCEL-1/LNRELW-35:csfbPsHoAllowed=forbidden
    ...  LNCEL-1/LNRELW-35:nrControl=automatic  LNCEL-1/LNRELW-35:psHoAllowed=forbidden
    ...  LNCEL-1/LNRELW-35:redirWithSysInfoAllowed=allowed  LNCEL-1/LNRELW-35:removeAllowed=true
    ...  LNCEL-1/LNRELW-35:srvccAllowed=forbidden  LNCEL-1/LNRELW-35:uTargetCid=62
    ...  LNCEL-1/LNRELW-35:uTargetRncId=1  LNCEL-1/LNRELW-35:utranLbAllowed=false
    ...  LNCEL-1/LNRELW-35:plmnId:mcc=666  LNCEL-1/LNRELW-35:plmnId:mnc=58
    ...    LNCEL-1/LNRELW-35:plmnId:mncLength=2
    Append To List  ${delta_parameters_LNADJ_LNADJL}  LNCEL-1/LNRELW-99:csfbPsHoAllowed=forbidden
    ...  LNCEL-1/LNRELW-99:nrControl=automatic  LNCEL-1/LNRELW-99:psHoAllowed=allowed
    ...  LNCEL-1/LNRELW-99:redirWithSysInfoAllowed=allowed  LNCEL-1/LNRELW-99:removeAllowed=true
    ...  LNCEL-1/LNRELW-99:srvccAllowed=allowed  LNCEL-1/LNRELW-99:uTargetCid=69
    ...  LNCEL-1/LNRELW-99:uTargetRncId=1  LNCEL-1/LNRELW-99:utranLbAllowed=false
    ...  LNCEL-1/LNRELW-99:plmnId:mcc=666  LNCEL-1/LNRELW-99:plmnId:mnc=58
    ...    LNCEL-1/LNRELW-99:plmnId:mncLength=2
    Delta Commission Parameters    ${delta_parameters_LNADJ_LNADJL}
