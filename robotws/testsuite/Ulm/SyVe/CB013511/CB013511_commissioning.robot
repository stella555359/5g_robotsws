*** Settings ***
Documentation   Generic gNB Commissioning: CB013511
...             This is a Robot Test Suite for feature: CB013511
...             Feature:  CB013511_A_CA_capability_dedicated_mobility_parameters_NSA
...             Author:  Antje Jooss
...             Team: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...             Email: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute GNB Delta Commission JSON For CB013511 GNB-0
    [Arguments]    ${nrbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB013511, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    scf_info.Set MNL Version String For Branch    basic_scf_name=${basic_scf_name_gnb_${SOURCE_NODE_ID}}
    Log To Console  Start commissioning for gnb-${SOURCE_NODE_ID}
    scf.Load SCF  ${basic_scf_name_gnb_${SOURCE_NODE_ID}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actCAMeasInMeasProf=SA+NSA
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMeasBasedSCellAdditionNsa=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMeasProfileCa=SA+NSA
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actMeasurementProfile=SA+NSA
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=76
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"4"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=76
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=76
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:measPrMaNSAList
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4:measPrMaNSAList:{"measPrPriority":"2"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-11:sCellAdditionMethod=covBasedA1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-4/NRREL-11:sCellOperationalMode=dlOnly
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasPCellSwitchSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasPCellSwitchSsbRsrp:{"a1HysteresisPCellSwitchSsbRsrp":"2"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasSCellAddSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"2"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=76
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=76
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=68
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms320
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms320
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=2
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=63
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=34
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeasSCellRelSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"4"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=55
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=512ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=50
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6\$:a5MeasSsbRsrp:a5HysteresisSsbRsrp=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:measPrMaNSAList
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6:measPrMaNSAList:{"measPrPriority":"3"}
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1\$:a3MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3a5Priority=10
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1\$:a5MeasEnabled=rsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=8
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"4"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=67
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=72
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms1024
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRREL-10:sCellPrio=1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRREL-11:sCellPrio=4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-10:sCellAdditionMethod=covBasedA1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-8/NRREL-10:sCellOperationalMode=dlOnly
    ...  delete:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRDU-1:actParallelTxForUlCa=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRDU-1\$:remoteDuIpAddr=fd5f:4268:2387:a881:40:43ff:fe80:84
    ...  add:[com.nokia.srbts.nrbts:NRCACLASS, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-1, MNL${version}, create]
    ...  add:[com.nokia.srbts.nrbts:NRCACLASS, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-2, MNL${version}, create]
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_IAF, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=77
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=77
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=256ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrp:{"a1HysteresishoSsbRsrp":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=71
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrq
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrq:{"a1HysteresishoSsbRsrq":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=10
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasReleaseSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasReleaseSsbRsrp:{"a2HysteresisReleaseSsbRsrp":"4"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=38
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrp:{"a2HysteresishoSsbRsrp":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=58
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrq
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrq:{"a2HysteresishoSsbRsrq":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=12
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"4"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrq
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrq:{"a3HysteresisSsbRsrq":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a5MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"0"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=66
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=71
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms640
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_IEF, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=4
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrq
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrq:{"a3HysteresisSsbRsrq":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms640
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"10"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=64
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=69
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrq
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrq:{"a5HysteresisSsbRsrq":"8"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=8
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms640
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_MA_NSA, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrIafDN=NRMEASPR_IAF-1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrIefDefaultDN=NRMEASPR_IEF-1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1:nrMeasPrSCellDefaultDN=NRMEASPR_SCELL-1
    ...  add:[com.nokia.srbts.nrbts:NRMEASPR_SCELL, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:{"a1HysteresisPCellSwitchSsbRsrp":"12"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=640ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a2MeasSCellRelSsbRsrp
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"12"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=62
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=640ms
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1:thresholdPCellSwitchTargetRsrp=80

    FOR  ${nrcell}    IN    1  4  6  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a2MeasSCellRelEnabled=rsrp
    END

    FOR  ${nrcell}    IN    1  3  4  5  6  7  8  9
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a5MeasEnabled=rsrp
    END

    FOR  ${nrcell}    IN    1  2  8  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=4
    END

    FOR  ${nrcell}    IN    1  2  8  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=76
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=76
    END

    FOR  ${nrcell}    IN    1  10
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:{"a2HysteresisSCellRelSsbRsrp":"4"}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=55
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=256ms
    END

    FOR  ${nrcell}    IN    1  2  3  4  5  6  7  8  9  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a5MeasSsbRsrp:a5Threshold1SsbRsrp=65
    END

    FOR  ${nrcell}    IN    1  2  3  4  5  6  7  8  9
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a5MeasSsbRsrp:a5Threshold2SsbRsrp=70
    END

    FOR  ${nrrel}    IN    4  10
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRREL-${nrrel}:sCellOperationalMode=dlOnly
    END

    FOR  ${nrcell}    IN    1  2  3  4  5  6  7  8  9  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
    END

    FOR  ${nrcell}    IN    10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
        ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}\$:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms320
    END

    FOR  ${nrrel}    IN    4  10  11
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-6/NRREL-${nrrel}:sCellOperationalMode=dlOnly
    END

    ${PrMaNSADN}    Set Variable    MRBTS-403641/NRBTS-403641/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    FOR  ${nrcell}    IN    4  6
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a1MeasSCellAddEnabled=rsrp
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
        ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell}:measPrMaNSAList:nrMeasPrMaNSADN=${PrMaNSADN}
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    @{GNB_PARAMS_IN_SCF_Part2}   Create List
    ...  add:[com.nokia.srbts.nrbts:NRMTRACECU, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1, MNL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:{"cellMaxActiveMDTUEsTraced":"50"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:immedMDTObtainLocation=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:immedMDTPosMethod=none
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:immedMDTSelectOnlyGNSSUEs=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:{"mdtMeasType":"periodic"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=r2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms2048
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:rrmEventTriggeredMeas=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:{"mcc":"540"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=403641

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF_Part2}
    scf.Save SCF  ${target_scf_name_gnb}

    ${tracePCMDSetting}=    Create List  SgNB Addition  SgNB Release  SgNB initiated SgNB Mod  MeNB initiated SgNB Mod  SgNB Change  HO Source
                                    ...  HO Target  RRC Setup  UE Setup  UE Release  UE Information  UE Measurement  PDU Session Resource Info
                                    ...  Bearer  CA Configuration  DU Connectivity  CU-UP Connectivity  MeNB Connectivity  XnAP HO Source
                                    ...  XnAP HO Target  NGAP HO Source  NGAP HO Target  Intra-gNB HO Source  Intra-gNB HO Target
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ...  list_name=tracePCMDSetting
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ...  list_name=tracePCMDSetting    elements=${tracePCMDSetting}

    ${caBandList_NRCACLASS-1}=    Create List  66  77
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-1
    ...  list_name=caBandList
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-1
    ...  list_name=caBandList    elements=${caBandList_NRCACLASS-1}

   ${pCellBandList_NRCACLASS-1}=    Create List  66
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-1
    ...  list_name=pCellBandList
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-1
    ...  list_name=pCellBandList    elements=${pCellBandList_NRCACLASS-1}

    ${caBandList_NRCACLASS-2}=    Create List  71  78
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-2
    ...  list_name=caBandList
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-2
    ...  list_name=caBandList    elements=${caBandList_NRCACLASS-2}

   ${pCellBandList_NRCACLASS-2}=    Create List  71
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-2
    ...  list_name=pCellBandList
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRCACLASS-2
    ...  list_name=pCellBandList    elements=${pCellBandList_NRCACLASS-2}

   ${nrCaClassDNList_NRMEASPR_MA_NSA-1}=    Create List  NRCACLASS-1
    scf.Add List To SCF
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    ...  list_name=nrCaClassDNList
    scf.Add Elements To List
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    ...  list_name=nrCaClassDNList    elements=${nrCaClassDNList_NRMEASPR_MA_NSA-1}


    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Full Commissioning With SCF File
    ...  node_type=gnb  node_id=${gnb_id}  scf_file_path=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}


######################################################################################################################################################


Execute ENB Delta Commission JSON For CB013511 ENB-0
    [Arguments]    ${nrbts_id}  ${enb_id}  ${target_scf_name_enb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of enb-0 for CB013511, create new updated SCF with delta changes.
    ...    Only one file is required for updating enb with delta changes.

    Log To Console  Start commissioning for enb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_enb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List

    FOR  ${lncel}    IN    1  2  3  4  5  6  7  8  9  101
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/LNBTS-${nrbts_id}/LNCEL-${lncel}\$:tac=8105
    END

    FOR  ${endcmeasconf}    IN    0  1  2  3  4  5  6  7
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:MRBTS-${nrbts_id}/LNBTS-${nrbts_id}/NRDCDPR-0/ENDCDMEASCONF-${endcmeasconf}\$:b1ThresholdNrRsrp=46
    END

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_enb}

    ${actMeasBasedSCellAdditionSa_elements}  Create List
    ...    A4-based


    scf.Save SCF  ${target_scf_name_enb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_enb}
    ...  actual_scf_path=${basic_scf_name_enb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Full Commissioning With SCF File
    ...  node_type=enb  node_id=${enb_id}  scf_file_path=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}