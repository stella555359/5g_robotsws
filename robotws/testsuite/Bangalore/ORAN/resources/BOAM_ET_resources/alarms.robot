*** Settings ***
Library    BuiltIn
Library    Collections

Resource    ORAN.robot
Resource    admin.robot
Resource    admin_infomodel.robot
Resource    pretest_posttest.robot

*** Variables ***

&{2909}     fault_id=2909
...         alarm_id=
...         alarm_severity=Major
...         alarm_resource=
...         fault_name="Unexpected C/U-plane message content fault"
...         notifier=

&{1936}     fault_id=1936
...         alarm_id=
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name="Unit (module) temperature is high"
...         notifier=

&{1986}     fault_id=1986
...         alarm_id=
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name="SFP on RF Module faulty or unsupported"
...         notifier=

&{2908}     fault_id=2908
...         alarm_id=
...         alarm_severity=Major
...         alarm_resource=
...         fault_name="Interface Fault"
...         notifier=

&{1900_autonomous}     fault_id=1900
...         alarm_id=
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name="Radio autonomous reset as recovery action"
...         notifier=

&{1932}     fault_id=1932
...         alarm_id=
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name="No module fan detected"
...         notifier=

&{2907}     fault_id=2907
...         alarm_id=
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name="C/U-plane logical Connection faulty"
...         notifier=

&{2910}     fault_id=2910
...         alarm_id=
...         alarm_severity=Major
...         alarm_resource=
...         fault_name="Power Amplifier faulty"
...         notifier=

&{1806_allowed}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name="Radio autonomous reset as recovery action"
...         notifier=

&{1900_allowed}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="RF Module configuring failed"
...         notifier=

&{9}     fault_id=9
...         alarm_id=7241
...         alarm_severity=Major
...         alarm_resource=
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{4592}     fault_id=4592
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name="BTS Reset Cause"
...         notifier=

&{1806}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name=Radio autonomous reset as recovery action
...         notifier=

&{4176}     fault_id=4176
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Failure in log file gathering
...         notifier=

&{1900}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=RF Module configuring failed
...         notifier=

&{10}       fault_id=10
...         alarm_id=7116           
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=No connection to unit
...         notifier=

&{27}       fault_id=27
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Error in file server during file upload or download operation
...         notifier=

&{4662}     fault_id=4662
...         alarm_id=7115
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name=Number of supported O-RU objects exceeded
...         notifier=

&{1982}     fault_id=1982
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=RF Module External Alarm and Control lines configuration failed
...         notifier=

&{4298}     fault_id=4298
...         alarm_id=7108
...         alarm_severity=Major
...         alarm_resource=
...         fault_name=ToP reference missing
...         notifier=

&{16}       fault_id=16
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Unit synchronization failed
...         notifier=

&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         alarm_resource=
...         fault_name="No X2 link available"
...         notifier=

&{4069}     fault_id=4069
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=ALD Port power failure
...         notifier=

&{1807}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Invalid frequency channel for the BTS HW
...         notifier=

&{4044}     fault_id=4044
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Incoherency in cell configuration
...         notifier=

&{4008}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Power level not supported
...         notifier=

&{1402}     fault_id=1402
...         alarm_id=7103
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=eac_2
...         notifier=

&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Mismatch of RU reported capabilities with static HW Validation information
...         notifier=

&{6202}     fault_id=6202
...         alarm_id=7107
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Transport layer connection failure in S1 interface
...         notifier=
