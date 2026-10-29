# Precondition
install taf lib
download robotws code
# Catch log with One Command
```
cp /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/.bash_aliases ~/.bash_aliases;source ~/.bashrc
log_type=btslog,ttitrace,sherpa
catchlog
test log is in /home/ute/test_logs/
```
# BIP
## catch BIP log on slot1 and slot2 continously and stop by manual cmd
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i 6137 manual_collect_log_bip.robot
## catch BIP log on Gnb And Airphone
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case4 manual_collect_log_bip.robot
## catch BIP log for 10s
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case1 manual_collect_log_bip.robot
## catch BIP log continously and stop by manual cmd
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case2 manual_collect_log_bip.robot

# Ttitrace
## catch Ttitrace in 10s
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case1 manual_collect_log_ttitrace.robot
## catch Ttitrace continously and stop by manual cmd
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case2 manual_collect_log_ttitrace.robot

# Sherpa
## catch Sherpa in 10s
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case1 manual_collect_log_sherpa.robot
## catch Sherpa continously and stop by manual cmd
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/
    mybot -i case1 manual_collect_log_sherpa.robot

# Get Config File
## Get config file on real ue testline
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/
    mybot -i gnb collect_config_file.robot
## Get config file on ute testline
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/
    mybot collect_config_file.robot

# Get Snapshot

# Get all types of log for one time.You need to modify robot file.
    cd /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/
    mybot auto_capture_logs.robot