#!/usr/bin/env bash
#set -eEuo pipefail
#note:these cmd are got from CIT case log on REP server. enviroment variables are from env_variables.txt, bash cmds are from log.txt, you can also get newest cmd from newest CIT log. 
#history: update 2023/8/30
#======= set enviroment variable =======================
#copy all environment variables to your testline one time.
export CM_TOPOLOGY='{"agent": {"name": "ute-ca"}, "name": "CLOUD_5G_I_BOO_AP_LOO"}'
export CM_AGENT_RUN='{"executed": 1}'
export CM_AGENT_OUTPUT_PATH='/home/ute'
export CM_TEST_REPOSITORY_NAME='MN/UTE/robotws'
export CM_TAGS='["CLOUD_5G_I_BOO_AP_LOO", "QCaaS_EXECUTION", "PY36", "OPTION_RELATED_ARTIFACTS_5G"]'
export CM_REQUIRE_STATE=configured
export CM_TEST_REPOSITORY_TYPE=git
export CM_TOPOLOGY_NAME=CLOUD_5G_I_BOO_AP_LOO
export CM_TEST_REPOSITORY_VERSION=HEAD
export CM_ARTIFACTS='[{"id": "8f3c84f0-1e16-4ab9-b413-ddf2e34c93ab", "name": "SBTS00_ENB_9999_231006_000009", "type": "build", "status": "enabled", "properties": {"ute_version": "2332.03.00", "state": "RELEASED", "supported_hardware": ["4G_Airscale", "4G_FSMr3", "Airscale", "FSMr3"], "promotion": ["REGRESSION"], "nsetap_version": "2.25.2", "created_at": "2023-09-24 05:56:04+00:00", "updated_at": "2023-09-24 10:03:56+00:00", "path": "/mnt/enb/base/SBTS00_ENB_9999_230924_000003", "related_artifacts": {"5G": [{"version": "SBTS00_ENB_9999_230924_000003", "name": "build", "default": true}, {"version": "2332.03.00", "name": "ute-5g"}, {"version": "5G_4.0.26751", "name": "airphone", "default": true}], "4G": [{"version": "2332.03.00", "name": "ute-4g"}, {"version": "WTS_6020904.2_4.0.26603", "name": "wts", "default": true}]}, "all_packages_created": true, "test_information_location": {"locations": [{"project": "RAN_ET", "domain": "MN_RAN", "filters": {"test_subarea__regex": ".*(SBTS|5G_Classical|4G_SmallCell|5G_SmallCell|Classical_WCDMA|Classical_GSM).*", "test_lab_path__startswith": "Root\\Test_Sets\\Trunk\\"}}, {"project": "RAN_ST", "domain": "MN_RAN", "filters": {"test_subarea__regex": ".*(SBTS|5G_Classical|4G_SmallCell|5G_SmallCell|Classical_WCDMA|Classical_GSM).*", "test_lab_path__startswith": "Root\\Test_Sets\\Trunk\\"}}, {"project": "RAN_AP", "domain": "MN_RAN", "filters": {"test_subarea__regex": ".*(SBTS|5G_Classical).*", "test_lab_path__startswith": "Root\\Test_Sets\\Trunk\\"}}]}, "ps_version": "2023_09_0030", "promotions": [{"status": "active", "created_at": "2023-09-24 10:12:32.600556+00:00", "promotion": "REGRESSION", "updated_at": "2023-09-24 10:12:32.600567+00:00"}], "upgrade_path": {"version": "1.0", "product_defaults": {"n3": "SBTS23R2_ENB_0000_000745_000031", "n2": "SBTS23R3_ENB_0000_000724_000000", "n0": "SBTS00_ENB_9990_230911_000006", "n1": "SBTS00_ENB_9990_230801_000010"}, "customer_deployments": [{"customer": "TEF O2 Germany", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000662_000012", "uuf_configuration_id": 1}]}, {"customer": "SKT", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000662_070012", "uuf_configuration_id": 1}]}, {"customer": "TMO US", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "Korean Telecom", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000662_070012", "uuf_configuration_id": 1}]}, {"customer": "Free France", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000590_000016", "uuf_configuration_id": 1}]}, {"customer": "Chungwa Telecom", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000724_000000", "uuf_configuration_id": 1}]}, {"customer": "Verizon", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_001340_000000", "uuf_configuration_id": 1}]}, {"customer": "CMCC", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "VDF Italy", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000724_000000", "uuf_configuration_id": 1}]}, {"customer": "STC Saudi", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "TEF Spain", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000013", "uuf_configuration_id": 1}]}, {"customer": "Reliance India", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "AT&T", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000021", "uuf_configuration_id": 1}]}, {"customer": "KDDI Japan", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "Bell Canada", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000928_000007", "uuf_configuration_id": 1}]}, {"customer": "BT UK (EE and MBNL)", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_001112_000004", "uuf_configuration_id": 1}]}, {"customer": "LGU+", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000724_000000", "uuf_configuration_id": 1}]}, {"customer": "Optus", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000724_000000", "uuf_configuration_id": 1}]}, {"customer": "Orange France", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000724_000000", "uuf_configuration_id": 1}]}, {"customer": "Bharti", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000496_000006", "uuf_configuration_id": 1}]}, {"customer": "SFR", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "Taiwan Mobile", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}, {"customer": "Elisa", "deployments": [{"source_sw_build": "SBTS23R3_ENB_0000_000590_000016", "uuf_configuration_id": 1}]}, {"customer": "SBM", "deployments": [{"source_sw_build": "SBTS23R2_ENB_0000_000745_000031", "uuf_configuration_id": 1}]}]}, "nsetap_x_version": "1.10.4", "branch": "SBTS00", "cplan_version": "SBTS00_CPLANE_0001_006248_230923_010114", "lom_version": "LOM_0.223.2"}, "add_date": "2023-09-24T05:57:58.655126Z", "update_date": "2023-09-24T10:28:43.662144Z"}, {"id": "eb61fa95-48e5-4b8a-b804-7ab41f5748c7", "name": "MN/UTE/robotws-HEAD", "type": "testrepository", "status": "enabled", "properties": {"url": "ssh://gerrit-wrsl1.int.net.nokia.com:29418", "type": "git", "revision": "HEAD", "repository": "MN/UTE/robotws"}, "add_date": "2022-03-25T07:38:06.891217Z", "update_date": "2022-03-25T07:38:06.891252Z"}, {"id": "74e440a0-5db7-4529-b175-5d7cda85d8d3", "name": "utevm_debian10_64bit_202307261850.qcow2.tar.gz", "type": "sysimage", "status": "enabled", "properties": {}, "add_date": "2023-07-27T11:05:44.496817Z", "update_date": "2023-07-27T11:05:44.496833Z"}, {"id": "79cc251d-304a-417a-8218-f29cb26ca7dc", "name": "2338.01.00", "type": "ute-4g", "status": "enabled", "properties": {}, "add_date": "2023-09-20T06:57:28.004754Z", "update_date": "2023-09-20T06:57:28.004769Z"}]'
export CM_RESOURCES='[{"properties": {"machines": [{"properties": {"type": "VirtualMachine", "address": "10.71.187.221", "server": {"properties": {"type": "TestServer", "address": "10.71.187.161", "site": "Hangzhou", "name": "7_5_UTE5GCLASSICAL05604-kvm", "hypervisor": "KVM"}, "id": "4e4feef6-2e40-4b2d-913d-f7f803dcae16"}, "name": "7_5_UTE5GCLASSICAL05604-1"}, "id": "bd147829-86b0-4791-924b-4a5e529a1bd5"}], "type": "Testline", "tags": [], "name": "7_5_UTE5GCLASSICAL05604"}, "id": "73d7f794-f880-4587-8a4f-3b861d49ec23"}]'
#======= start PrepareKVMAgent =======================
#======= start ReinstallVirtualMachineKVM ============
#======= start PrepareUTEVMAgent =====================
bash -cel 'pyenv virtualenv-delete -f agent_utevm_env; pyenv virtualenv 3.9.14 agent_utevm_env; pyenv activate agent_utevm_env; pip install ute_installer; pip install agent_utevm; pip list'
#======= start PreparePyenvAgent =====================
bash -cel 'pyenv virtualenv-delete -f agent_pyenv_env; pyenv virtualenv 3.9.14 agent_pyenv_env; pyenv activate agent_pyenv_env; pip install agent_utepackage; pip list'
#======= start InstallUTEBuild =======================(install wireshark in this step,change python to python3)
bash -cel 'pyenv virtualenv-delete -f agent_utepackage_env; pyenv virtualenv 3.9.14 agent_utepackage_env; pyenv activate agent_utepackage_env; pip install agent_utepackage; pip list; agent_utepackage install'
#======= start PrepareAgentDl ========================
bash -ce 'rm -rf /opt/ute/agent_env; virtualenv /opt/ute/agent_env; source /opt/ute/agent_env/bin/activate; echo yes | pip install ute_installer -U; echo yes | pip install agent_dl -U; pip list --format=columns'
#======= start RunAgentDl ============================(test cmd)
bash -ce 'source /opt/ute/agent_env/bin/activate; agent_dl'
#======= start PrepareCommissioningAgent =============
bash -cel 'pyenv virtualenv-delete -f agent_commissioning_env; pyenv virtualenv 3.6.10 agent_commissioning_env; pyenv activate agent_commissioning_env; pip install agent_commissioning; pip list'
#======= start PrepareCloudAgent =====================(install ute-ca in this step:sudo apt install ute-ca)
bash -cel 'pyenv activate agent_commissioning_env; agent_commissioning install'
#======= start RunTestlineInit =======================(update gnb,airphone,wts,ttitrace,mcshark in this step,choose only one method)
## method 1(it reads above environment variables):
bash -cel 'pyenv activate agent_commissioning_env; agent_commissioning init'
## method 2(it doesn't read above environment variables):
###sudo systemctl start ute-ca.service
###sudo systemctl status ute-ca.service
###bash -cel "source /opt/ute/agent_env/bin/activate; ute-ca init -l 'CLOUD_5G_I_BOO_AP_LOO' -b 'SBTS00_ENB_9999_230806_000008' -o '/home/ute/output' -s 'configured' -R '/home/ute/testline_init_results/'"
## method 3(it doesn't read above environment variables):
###agentctl exec --label CLOUD_5G_I_BOO_AP_LOO --sm-build SBTS00_ENB_9999_230806_000008  --required-state commissioned

#======= start PrepareScoutAgent =====================
#======= start ScoutInit =============================
#======= start PrepareTestRepositoryAgent ============
bash -cel 'pyenv virtualenv-delete -f agent_test_repository_env;pyenv virtualenv 3.9.14 agent_test_repository_env; pyenv activate agent_test_repository_env; pip install ute_installer; pip install agent_test_repository; pip list'
#======= finish PrepareTestRepositoryAgent ===========
#======= start CheckoutRepository ====================
bash -cel 'pyenv activate agent_test_repository_env; agent_test_repository fetch'
#======= start PrepareTAFAgent =======================
bash -cel 'pyenv virtualenv-delete -f agent_taf_env; pyenv virtualenv 3.9.14 agent_taf_env; pyenv activate agent_taf_env; pip install agent_taf; pip list'
#======= start TAFInstall ============================
bash -cel 'pyenv activate agent_taf_env; agent_taf install'
#======= start PrepareUTEVMAgent =====================
#======= start GatherLogsInit ========================
#======= finish GatherLogsInit =======================
#======= start RunUserCustomScript ===================
#======= finish RunUserCustomScript ==================
#======= start PrepareUTEVMAgent =====================
#======= start RestoreVirtualMachineAccess ===========
#======= start PrepareUTEVMAgentOnKVM ================
#======= start RebootVirtualMachineKVM ===============
#======= start PrepareCommissioningAgent =============
#======= start PrepareCloudAgent =====================
#======= start RunTestlineCheck ======================
#======= start GatherLogsCheck =======================
	