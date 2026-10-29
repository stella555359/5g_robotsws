#unzip files on destination testline:
bash -cel "sshpass -p nokia123 scp nokia@10.57.215.253:/home/nokia/LogServer2/ute_files/* /home/ute/"
bash -cel "rm -rf /home/ute/test_repo/;rm -rf /opt/ute/agent*/;rm -rf /opt/ute/ute_reservation/"
bash -cel "cd /home/ute/;unzip test_repo.zip -d /home/ute/;unzip agent.zip -d /opt/ute/;echo 'A'|unzip ute_reservation.zip -d /opt/ute/;echo 'A'|unzip -d /opt/ute/ python.zip;"

#download code from gitlab:
bash -cel "rm -rf /home/ute/MN/UTE/robotws; mkdir -p /home/ute/MN/UTE/; cd /home/ute/MN/UTE/; git clone ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/UTE/robotws"
ln -s /home/ute/MN/UTE/robotws/ /home/ute/test_repository

rm -rf /home/ute/testline_configuration/* && export testline_name=$(hostname|sed 's/-/_/g'); git archive -o /home/ute/testline_configuration.zip --remote=ssh://gerrit-mn-essl1.int.net.nokia.com:29418/MN/UTE/testline_configuration HEAD $testline_name;unzip /home/ute/testline_configuration.zip -d /home/ute/testline_configuration/

#install tshark
sudo bash -ce 'while fuser /var/lib/dpkg/lock; do echo "dpkg is used"; sleep 1; done; apt-get update; apt-get install --yes ute-client; ute install 2307.01.00~py3~mini; dpkg-query -s ute 2>&1 | grep Version | grep 2307.01.00~py3~mini'

#copy alias file to set pybot cmd
cp /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/.bash_aliases ~/.bash_aliases;

pip install taf.internal.node
/home/ute/test_repo/bin/pip install taf.internal.node
echo "execute 'source ~/.bashrc' to update environment variable"

