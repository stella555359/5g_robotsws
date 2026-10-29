*** Settings ***
Documentation
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: SG_04
...   Feature 5GC001596 in 5G19B program

Resource     ./5GC001596_F_Variables.robot
Resource     ./../../5GC001596_D/Resources/merge_case_to_one_kw.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py
