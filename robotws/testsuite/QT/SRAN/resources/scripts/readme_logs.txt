===== READ ME =====

This readme.txt provides information about the content of logs inside the path.

== Main_folder ==

(TL_name)_(Build)_SYSLOG_(Date).tgz                                     =       Syslog from test execution
(TL_name)_Snapshot_(Build)_(Date_and_time).zip                          =       Snapshot after L3Call  
(TL_name)_Snapshot_(Build)T1_(Date_and_time).zip                        =       Snapshot after software update to T1
consoleText                                                             =       Console log of test execution from Jenkins
data_after_test.txt                                                     =       Stop & Fix flag
log.html                                                                =       Easy-to-read Roboframework result in HTML format.
messaging.container.errors.log                                          =       Jenkins container error messaging log
messaging.dispatcher.log                                                =       Jenkins dispatcher messaging log
messaging.flows.log                                                     =       Jenkins flows messaging log
messaging.flows.logic.log                                               =       Jenkins logic flows messaging log
messaging.log                                                           =       Jenkins messaging log
moler.debug.log                                                         =       NAA Plugin Moler log
moler.log                                                               =       NAA Plugin Moler log
moler.threads.log                                                       =       NAA Plugin Moler threads log
qt_test_results.json                                                    =       Json object file of QT results for automatic Release Notes
(Configuration)-(TL_name)_recovery.tar.gz                               =       Logs from TL recovery 
readme_logs.txt                                                         =       This file you are reading
report.html                                                             =       Easy-to-read Roboframework report in HTML format.
scf_from_webui_4050.xml                                                 =       SCF after 
ta_ue_uepc_local.log                                                    =


== Main_folder/Additional_Execution_Logs ==

_taf_venv_freeze.txt                   =       Listed library on VM
_before_TEST_admin_infomodel_*.ims2    =       IMS file collected before test by UTE Admin infomodel
_before_TEST_taf_*.ims2                =       IMS file collected before test by TAF library
al.aliases.log                          =       Abstraction layer ute_ue debug log for aliases
al.config.log                           =       Abstraction layer ute_ue debug log for config
al.devicepool.log                       =       Abstraction layer ute_ue debug log for devicepool
al.scopes.log                           =       Abstraction layer ute_ue debug log for scope
alarms_before_TEST.txt                  =       Listed alarms that are present on BTS before test is started
atlas_report_end.json                   =       Atlas report from the end of the test
atlas_report_start.json                 =       Atlas report from the start of the test
consoleText_Dispatcher_*                =       Console log from Jenkins Dispatcher
consoleText_env_health_check_*          =       Console log from Env Health checker
coop_report_start.json                  =       COOP report from the start of the test
coop_report.json                        =       COOP report from the finish of the test
debug.log                               =       Debag log from RobotFramework
gnb_startup_failure.log                 =       Check error message from syslog
output.xml                              =       Output from robotframework in xml format that contain all information about the execution
RawAlarmHistory.txt                     =       RawAlarmHistory from BTS
swconfig.txt                            =       swconfig from BTS
ute_ue.debug.log                        =       ute_ue debug log from NAA Plugin
ute_ue.log                              =       ute_ue log from NAA Plugin

== Main_folder/Additional_Execution_Logs/ADMIN_INFOMODEL_API ==

admin_api_all_test_infomodel_stderr.txt =       Test Admin infomodel stderr log
admin_api_all_test_infomodel_stdout.txt =       Test Admin infomodel stdout log
admin_api_all_test_infomodel.log        =       Test Admin infomodel log
admin_api_default_infomodel_stderr.txt  =       Default Admin infomodel stderr log
admin_api_default_infomodel_stdout.txt  =       Default Admin infomodel stdout log
admin_api_default_infomodel.log         =       Default Admin infomodel log 


== Main_folder/Full_Commissioning ==
(TL_name)_(Build)_after_commissioning_admin_infomodel_(Date_and_time).ims2      =       IMS collected by UTE Admin infomodel after commissionig
(TL_name)_(Build)_after_commissioning_taf_(Date_and_time).ims2	1.1 MB          =       IMS collected by TAF library after commissionig
alarms_after_commissioning.txt                                                  =       Alarms that are present on BTS after commissionig


== Main_folder/Full_Run ==
(TL_name)_(Build)_admin_infomodel.ims2          =       IMS collected by UTE Admin infomodel from the beginning


== Main_folder/L3_Call ==
(TL_name)_(Build)_after_l3call_admin_infomodel_(Date_and_time).ims2     =       IMS collected by UTE Admin infomodel after l3call
(TL_name)_(Build)_after_l3call_taf_(Date_and_time).ims2                 =       IMS collected by TAF library after l3call
alarms_after_l3call.txt                                                 =       Alarms that are present on BTS after l3call

== Main_folder/L3_Call/5G_call ==
ta_ue_uepc_local.log                        =       NAA Plugin Ue PC log
ue.(TL_name).taken.(TL_name).logs           =       NAA Plugin Ue debug log


== Main_folder/SW_Download_With_Activation ==
(TL_name)_(Build)_after_installation_gNB_package_admin_infomodel_(Date_and_time).ims2       =       IMS collected by UTE Admin infomodel after installation gNB package
(TL_name)_(Build)_after_installation_gNB_package_taf_(Date_and_time).ims2                   =       IMS collected by TAF library after installation gNB package
alarms_after_installation_gNB_package.txt                                                   =       Alarms that are present on BTS after installation gNB package


== Main_folder/Upgradability_T1 ==
(TL_name)_(Build)_after_T1_admin_infomodel_(Date_and_time).ims2       =       IMS collected by UTE Admin infomodel after installation T1 package
(TL_name)_(Build)_after_T1_taf_(Date_and_time).ims2                   =       IMS collected by TAF library after installation T1 package
alarms_after_T1.txt                                                   =       Alarms that are present on BTS after installation T1 package
