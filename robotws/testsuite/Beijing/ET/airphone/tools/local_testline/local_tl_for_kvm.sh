#unzip files on destination testline:
echo creat agent env...
bash -cel "cd /home/ute/;rm -rf ute_files;mkdir ute_files"
bash -cel "sshpass -p Nemuuser#365 scp ute@10.68.224.145:/home/ute/ute_files/* /home/ute/ute_files"
#bash -cel "rm -rf /home/ute/test_repo/;rm -rf /opt/ute/agent*/;rm -rf /opt/ute/ute_reservation/"
bash -cel "rm -rf /opt/ute/agent*/"
#bash -cel "cd /home/ute/ute_files;unzip test_repo.zip -d /home/ute/;unzip agent.zip -d /opt/ute/;echo 'A'|ccd;echo 'A'|unzip -d /opt/ute/ python.zip;"
bash -cel "cd /home/ute/ute_files;unzip agent.zip -d /opt/ute/"

#download code from gitlab:
#bash -cel "rm -rf /home/ute/MN/UTE/robotws; mkdir -p /home/ute/MN/UTE/; cd /home/ute/MN/UTE/; git clone ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/UTE/robotws"
#download bejin et code
echo clone et code...
#bash -cel "rm -rf /home/ute/MN/UTE/robotws/testsuite/Beijing/et; cd /home/ute/MN/UTE/robotws/testsuite/Beijing; git clone ssh://gerrit.ext.net.nokia.com:29418/MN/DCM/5G/et_l2_l3 ./et/"
echo creat ln from robotws to test_repository
rm -rf /home/ute/test_repository
ln -s /home/ute/MN/UTE/robotws/ /home/ute/test_repository

# update testline info
#rm -rf /home/ute/testline_configuration/* && export testline_name=$(hostname|sed 's/-/_/g'); git archive -o /home/ute/testline_configuration.zip --remote=ssh://gerrit-mn-essl1.int.net.nokia.com:29418/MN/UTE/testline_configuration HEAD $testline_name;unzip /home/ute/testline_configuration.zip -d /home/ute/testline_configuration/

#install tsharkcd 
echo install tshark...
sudo bash -ce 'while fuser /var/lib/dpkg/lock; do echo "dpkg is used"; sleep 1; done; sudo apt-get update; sudo apt-get install --yes ute-client; ute install 2221.05.00~py3~mini; sudo dpkg-query -s ute ute-4g 2>&1|grep Version|grep 2221.05.00~py3~mini'

#copy alias file to set pybot cmd
echo copy .bash_aliases
cp /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline/.bash_aliases ~/.bash_aliases

echo install taf.internal.node
pip3 install taf.internal.node
/home/ute/test_repo/bin/pip3 install taf.internal.node

echo "execute 'source ~/.bashrc' to update environment variable"

