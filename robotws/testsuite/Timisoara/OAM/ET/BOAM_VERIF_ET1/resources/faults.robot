*** Settings ***
Documentation
...    Author: Bianca Staicu(bianca.staicu@nokia.com)
...    Maintainer: Bianca Staicu(bianca.staicu@nokia.com)
...    Description: faults and alarms definitions

*** Variables ***

#&{FAULT_10}       fault_id=10
#...               alarm_id=7115
#...               alarm_severity=Minor
#...               alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
#...               fault_name="No connection to unit"

&{FAULT_1898}     fault_id=1898
...               alarm_id=7108
...               alarm_severity=Major
...               alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="PPS reference missing"

&{FAULT_4011}    fault_id=4011
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
...              fault_name="GPS Receiver alarm: control interface not available"

&{FAULT_4073}     fault_id=4073
...               alarm_id=7115
...               alarm_severity=Minor
...               alarm_resource=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="Fan vendor not detected"

&{FAULT_4405}    fault_id=4405
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="No usable time reference available"

&{FAULT_4439}    fault_id=4439
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_resource=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
...              fault_name="GPS receiver alarm: Signal Inaccurate"

&{FAULT_6202}     fault_id=6202
...               alarm_id=7107
...               alarm_severity=Critical
...               alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1/LNMME_R-0
...               fault_name="Transport layer connection failure in S1 interface"

&{FAULT_6203}     fault_id=6203
...               alarm_id=7107
...               alarm_severity=Major
...               alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1/LNADJ_R-53
...               fault_name="Transport layer connection failure in X2 interface"

@{FAULT_ALLOWED_LIST}=  &{FAULT_1898}  &{FAULT_4011}  &{FAULT_4073}
    ...   &{FAULT_4405}  &{FAULT_4439}  &{FAULT_6202}  &{FAULT_6203}
# removed &{FAULT_10}
#10  26  1400  1816  4073  4079  4080  4334  6202  6450  6290  61006  61613  61631  61058  61524  61652  61649

#&{FAULT_10_COR}       fault_id=10
#...               alarm_id=7115
#...               alarm_severity=Minor
#...               notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
#...               fault_name="No connection to unit"

&{FAULT_1898_COR}     fault_id=1898
...               alarm_id=7108
...               alarm_severity=Major
...               notifier=/MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="PPS reference missing"

&{FAULT_4011_COR}     fault_id=4011
...               alarm_id=7115
...               alarm_severity=Minor
...               notifier=/MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
...               fault_name="GPS Receiver alarm: control interface not available"

&{FAULT_4073_COR}     fault_id=4073
...               alarm_id=7115
...               alarm_severity=Minor
...               notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="Fan vendor not detected"

&{FAULT_4078_COR}     fault_id=4078
...               alarm_id=7115
...               alarm_severity=Minor
...               notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="Cooling fan broken"

&{FAULT_4405_COR}    fault_id=4405
...              alarm_id=7115
...              alarm_severity=Minor
...              notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="No usable time reference available"

&{FAULT_4439_COR}    fault_id=4439
...              alarm_id=7115
...              alarm_severity=Minor
...              notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
...              fault_name="GPS receiver alarm: Signal Inaccurate"

&{FAULT_4592_COR}    fault_id=4592
...              alarm_id=7115
...              alarm_severity=Warning
...              notifier=/MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="BTS Reset Cause"

&{FAULT_6202_COR}     fault_id=6202
...               alarm_id=7107
...               alarm_severity=Critical
...               notifier=/MRBTS-1/LNBTS_R-1/LNMME_R-0
...               fault_name="Transport layer connection failure in S1 interface"

&{FAULT_6203_COR}     fault_id=6203
...               alarm_id=7107
...               alarm_severity=Major
...               notifier=/MRBTS-1/LNBTS_R-1/LNADJ_R-53
...               fault_name="Transport layer connection failure in X2 interface"

&{FAULT_6450_COR}     fault_id=6450
...               alarm_id=7115
...               alarm_severity=Minor
...               notifier=MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
...               fault_name="Diagnostic Files collected"

# new added faults 27.09.2017
&{FAULT_61524_COR}   fault_id=61524
...              alarm_id=7220
...              alarm_severity=Minor
...              notifier=BTS-1/EQM-1/CABINET-1/SMOD-1/TRU-1/TRU_ALARM_NOTIF-2
...              fault_name="-"

&{FAULT_61524_Major}   fault_id=61524
...              alarm_id=7220
...              alarm_severity=Major
...              notifier=*/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="-"

&{FAULT_61607_COR}   fault_id=61607
...              alarm_id=61607
...              alarm_severity=Major
...              notifier=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1
...              fault_name="-"

&{FAULT_61652_COR}   fault_id=61652
...              alarm_id=7220
...              alarm_severity=Minor
...              notifier=BTS-1/EQM-1/CABINET-1/SMOD-1/TRU-1/TRU_ALARM_NOTIF-3
...              fault_name="-"

&{FAULT_61652_Major}   fault_id=61652
...              alarm_id=7220
...              alarm_severity=Major
...              notifier=*/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="-"

&{FAULT_61649_COR}   fault_id=61649
...              alarm_id=7220
...              alarm_severity=Minor
...              notifier=./EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="LMP access via port"

&{FAULT_61649_Major}   fault_id=61649
...              alarm_id=7220
...              alarm_severity=Major
...              notifier=./EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="LMP access via port"

&{FAULT_61058_COR_1}   fault_id=61058
...              alarm_id=7665
...              alarm_severity=Major
...              notifier=./EQM-1/CABINET-1/SMOD-1/TRU-1/TRU_ALARM_NOTIF-1
...              fault_name="BASE STATION TRANSMISSION ALARM"e

&{FAULT_4298_COR}   fault_id=4298
...              alarm_id=7108
...              alarm_severity=Major
...              notifier=*/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="ToP reference missing"

#Added 16.04.2020
&{FAULT_4145_COR}   fault_id=4145
...              alarm_id=7115
...              alarm_severity=Minor
...              notifier=*/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="Validation of signed file failed"

#Added 08.02.2021
&{FAULT_4654_COR}   fault_id=4654
...              alarm_id=7220
...              alarm_severity=Minor
...              notifier=*/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
...              fault_name="Ethernet port security is disabled"

&{FAULT_4655_COR}   fault_id=4655
...              alarm_id=7220
...              alarm_severity=Minor
...              notifier=/MRBTS-1/MNL-1/MNLENT-1/SECADM-1
...              fault_name="Service account root access is enabled"

@{FAULT_ALLOWED_LIST_COR}=  &{FAULT_1898_COR}  &{FAULT_4011_COR}  &{FAULT_4073_COR}  &{FAULT_4078_COR}
...     &{FAULT_4405_COR}  &{FAULT_4439_COR}  &{FAULT_6202_COR}  &{FAULT_6203_COR}  &{FAULT_6450_COR}
...     &{FAULT_61524_COR}  &{FAULT_61524_Major}  &{FAULT_61649_COR}  &{FAULT_61649_Major}  &{FAULT_61652_COR}
...     &{FAULT_61652_Major}  &{FAULT_61058_COR_1}  &{FAULT_4298_COR}   &{FAULT_4592_COR}  &{FAULT_4145_COR}
...     &{FAULT_61607_COR}  &{FAULT_4654_COR}  &{FAULT_4655_COR}
#removed &{FAULT_10_COR}
