# README LM

***LM TestCases***

/LM                - Main Folder with .robot files
    /LM_resources  - Folder with files needed for LM TCs
        /Licenses  - Folder with License XML files
        /Plans     - Folder with Provisioning plans

How to use:
robot --variable ENB_MPLANE_IP:192.168.255.1 --variable RESULTS:/home/ute/test_results/Test -L TRACE -b /home/ute/test_results/Test/debug.log -d /home/ute/test_results/Test/ /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/LM/<TC-name>