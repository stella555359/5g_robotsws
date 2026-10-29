# UTE Coud Testline Cmd
## Reserve a testline on ute cloud,run cmd to zip useful files.
```
bash -cel "cd /opt/ute/;zip -r agent.zip agent*;zip -r ute_reservation.zip reser*;zip -r python.zip python python3;cd /home/ute/;zip -r test_repo.zip test_repo"
bash -cel "sshpass -p nokia123 scp /home/ute/test_repo.zip /opt/ute/agent.zip /opt/ute/ute_reservation.zip /opt/ute/python.zip nokia@10.57.215.253:/home/nokia/LogServer2/ute_files/"  
```
## For CLOUD_5G_I_BOO_AP_LOO,Reserve a testline on ute cloud,run cmd to zip useful files.
```
bash -cel "cd /opt/ute/;zip -r agent.zip agent*;zip -r ute_reservation.zip reser*;zip -r python.zip python python3;cd /home/ute/;zip -r test_repo.zip test_repo"
bash -cel "sshpass -p nokia123 scp /home/ute/test_repo.zip /opt/ute/agent.zip /opt/ute/ute_reservation.zip /opt/ute/python.zip nokia@10.57.215.253:/home/nokia/LogServer2/ute_files_ute-ca/"  
```
## if python in your testline is python2, change to python3 by modifying file name
/home/ute/.uterc/python_path.2.sh
/home/ute/.uterc/python_path.default.3.sh
change cmd:
mv /home/ute/.uterc/python_path.3.sh /home/ute/.uterc/python_path.default.3.sh;
mv /home/ute/.uterc/python_path.default.2.sh /home/ute/.uterc/python_path.2.sh;
source ~/.bashrc;

# Local Testline Cmd
```
rm -rf /tmp/local_testline/*; git archive -o /tmp/local_testline.zip --remote=ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/UTE/robotws HEAD testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/local_testline_for_KVM.sh;unzip /tmp/local_testline.zip -d /tmp/local_testline/;
cp /tmp/local_testline/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/local_testline_for_KVM.sh /home/ute/local_testline_for_KVM.sh;
sh /home/ute/local_testline_for_KVM.sh
source ~/.bashrc

note: if gerrit server failed, you could not download local_testline_for_KVM.sh,
you can download code from git server and upload it to control pc.Make sure the end-of-line is LF, not NRLF.
sh /home/ute/local_testline_for_KVM.sh
```
# install ute-ca cmd
https://docs.ute.nsn-rdnet.net/docs/
```
sudo apt update && sudo apt upgrade ute-ca
systemctl status ute-ca
sudo systemctl start ute-ca
```
# ute-ca cmd
test cmd
```
agentctl exec --label CLOUD_5G_I_BOO_AP_LOO --sm-build SBTS00_ENB_9999_230228_000008 --required-state commissioned --mode check
```
update package for CLOUD_5G_I_BOO_AP_LOO
```
agentctl exec --label CLOUD_5G_I_BOO_AP_LOO --sm-build SBTS00_ENB_9999_230228_000008 --required-state commissioned
```
# agent cmd
Update package with agent:(change CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD to your own testline type and SBTS00_ENB_9999_220314_000003 to the package you want)

    bash -cel "source /opt/ute/agent_env/bin/activate; agent-sim init -l 'CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD' -b 'SBTS00_ENB_9999_220314_000003' -o '/home/ute/output' -s 'configured' -R '/home/ute/testline_init_results/'"

Update package with agent and set __init__.py file:(change CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD to your own testline type, SBTS22R2_ENB_0000_000891_000000 to the package you want, /home/ute/testline_configuration/7_5_UTE5GCLASSICAL11607/ to the folder contains your PB info)  

    bash -cel "source /opt/ute/agent_env/bin/activate; agent-sim init -l 'CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD' -b SBTS22R2_ENB_0000_000891_000000 -o '/home/ute/output' -s 'configured' -R '/home/ute/testline_init_results/' --tl-config-path '/home/ute/testline_configuration/7_5_UTE5GCLASSICAL11607/'"

Update package with agent for vran2.0

    bash -cel "source /opt/ute/agent_env/bin/activate; agent_5g init -l 'CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD' -b 'vDUCNF_0.300.6641' -o '/home/ute/output' -s 'configured' -R '/home/ute/testline_init_results/'"

# Run case cmd
Run case:(change 7_5_UTE5GCLASSICAL11602 to your own testline name)

    bash -cel "source /home/ute/test_repo/bin/activate; robot -L trace -V /home/ute/testline_configuration/$(hostname|sed 's/-/_/g') -d /home/ute/test_logs/test_logs$(date +'%Y%m%d%I%M%p') -i case1 /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CB006137/CB006137_AA.robot"
agent download package is put in /home/ute/output/builds/  
catch syslog manually,tool is /opt/ute/python/bin/cli_syslog.py

    /home/ute/test_repo/bin/cli_syslog.py -d "/home/ute/test/" -l "Gnb_syslog" -i "192.168.255.126" -s 209715200 -p 51000 51001 51003 50011
pip install method cmd:  

    rm -rf /home/ute/test_repo && /usr/bin/virtualenv /home/ute/test_repo && /home/ute/test_repo/bin/pip install ute_installer  && /home/ute/test_repo/bin/pip install -r /home/ute/MN/UTE/robotws/requirements.cfg
delete useless files on local ute testline:

    bash -cel "rm -rf /home/ute/.ute-ca/cache/*;sudo rm -rf /var/cache/apt/archives/;cd /opt/wts/; ls /opt/wts/ -t1|tail -n '+3'|sudo xargs rm -r"

Run Case on jenkins:
```
rm -rf /home/ute/.ute-ca/cache/*; sudo rm -rf /var/cache/apt/archives/*; cd /opt/wts/; ls /opt/wts/ -t1|tail -n '+3'|sudo xargs rm -r
#$GNB_BUILD=SBTS00
#gnb_v=$(curl http://files.ute.nsn-rdnet.net/builds/enb/base/|grep $GNB_BUILD|sort -r|sed -n '1p'|grep -Eo 'SBTS[[:alnum:]]{2,4}_ENB_[[:digit:]]{4}_[[:digit:]]{6}_[[:digit:]]{6}'|awk 'NR==1')
#/opt/ute/agent_env/bin/agent-sim init -l 'CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD' -b '$gnb_v' -o '/home/ute/output' -s 'configured' -R '/home/ute/testline_init_results/'
/home/ute/test_repo/bin/robot -L trace -V /home/ute/testline_configuration/$(hostname|sed 's/-/_/g') -d /home/ute/test_logs/test_logs$(date +'%Y%m%d%I%M%p') /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/5GC002329/5GC002329_3.robot
/home/ute/test_repo/bin/ute_reporting_portal send -ie -ro /home/ute/test_logs/$(ls -1r /home/ute/test_logs/|sed -n '1p')/output.xml  -tl $(hostname|sed 's/-/_/g') -v --sw_version "$(sshenb find /ffs/run/TargetBD_*.xml|awk -F "TargetBD_" '{print $2}'|awk -F "." '{print $1}'|sed s'/SBTS22R4/SBTS00/')" -l "CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD"
/home/ute/test_repo/bin/robot -L trace -V /home/ute/testline_configuration/$(hostname|sed 's/-/_/g') -d /home/ute/test_logs/test_logs$(date +'%Y%m%d%I%M%p') /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/5GC002329/5GC002329_5_CNI72413.robot
/home/ute/test_repo/bin/ute_reporting_portal send -ie -ro /home/ute/test_logs/$(ls -1r /home/ute/test_logs/|sed -n '1p')/output.xml  -tl $(hostname|sed 's/-/_/g') -v --sw_version "$(sshenb find /ffs/run/TargetBD_*.xml|awk -F "TargetBD_" '{print $2}'|awk -F "." '{print $1}'|sed s'/SBTS22R4/SBTS00/')" -l "CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD"

```
# Wireshark Tool
download wireshark software(win10):
https://artifactory-hz1.int.net.nokia.com/artifactory/wireshark-lte-5g-win-local/wireshark/wireshark-stable/win10/
wireshark introduction page:
https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1285887594
download mcshark plugin:
https://clutch-hz.dynamic.nsn-net.net/webtools/collectDownloadInfo/download
local mcshark path:
C:\Program Files\Wireshark\plugins\3.6\epan
C:\Users\yuema\AppData\Roaming\Wireshark\plugins\3.6\epan

# dos2unix cmd
sed -i 's/\r$//g' /home/ute/local_testline_for_KVM.sh
sed -i 's/\r$//g' /home/ute/.bash_aliases

# clone code from git server
```
rm -rf /home/ute/MN/UTE/robotws/ && git clone https://wrgitlab.ext.net.nokia.com/RAN/robotws.git /home/ute/MN/UTE/robotws/
rm -rf /home/ute/testline_configuration/; mkdir -p /home/ute/testline_configuration/; cd /home/ute/; git clone ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/UTE/testline_configuration
gnb_v=$(sshenb find /ffs/run/TargetBD_*.xml 2>/dev/null|awk -F "TargetBD_" '{print $2}'|awk -F "." '{print $1}'|sed s'/SBTS22R4/SBTS00/')

```
