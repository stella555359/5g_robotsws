# @Time    : 2025/10/30 09:37
# @Author  : chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : 3G_RRM_Resources.robot
# @Software: PyCharm
*** Settings ***
Documentation    Manage all python and robot in 3G RRM Regression testing

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    robot/3G_RRM_Pionner.robot
Resource    robot/3G_specific_variables.robot
Resource    robot/3G_traffic.robot