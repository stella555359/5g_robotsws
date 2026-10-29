#################################################################################
# File           : IphyUpdate.py
# Version        : 1.0
# Modified       : Manasa 08.03.2022
# Description    : Script to update swversion and swFilekey for RMODS in provided iphy.xml and copy to WTS
# Supported HW  :   AiC
# Version        :
#   1.0          :
# Requires files : -
# Requires options: -
# Copyright (C) Nokia 2021. All Rights Reserved.
# Author: GV Vivek
# Log of changes : $Log:
# ================================================================================
# Functions           Descriptions
# -------------------------------------------------------------------------------
#
#
#################################################################################


import sys
from robot.libraries.BuiltIn import BuiltIn
import logging as logger
import lxml.etree as Et
import subprocess
import re
import os
from itertools import chain
import AIC_LogCapture as AC

ResourceBuildKey = ['buildversion',
                    'bldVersion',
                    'soap-config/software/file/version']
SwFileKey = ['soap-config/software/file/name']
GSCN = 'CPRI-Config/CPRI-RP1-RE_List/RE/hardware/vcellList/vcell/GSCN'
targetbd_file = "TargetBD_vDU.xml"


builtin = BuiltIn()


def get_robot_output_dir():
    """
    Returns the value of Robot Framework variable ${OUTPUT_DIR}
    """
    return builtin.get_variable_value('${OUTPUT_DIR}')


def update_iphy_xml(custom_iphy, xvdu_ip, xvdu_username, xvdu_password, xvdu_namespace, gscn_value="None"):
    """
    updates iphy xml with build version of RMOD and gscn if provided.
    :param custom_iphy: path to custom iphy.xml
    :param gscn_value: gscn value which should be inserted to custom iphy.xml
                       Otherwise default present in iphy.xml would be retained.
    """
    tree = Et.parse(custom_iphy)
    root = tree.getroot()
#    updated_iphy_filename = os.path.dirname(custom_iphy)+"/updated_"+os.path.basename(custom_iphy)
    robot_output_dir = get_robot_output_dir()
#    print("***************DEBUG ===> ",robot_output_dir)
    updated_iphy_filename = robot_output_dir+"/updated_"+os.path.basename(custom_iphy)
    targetbd = robot_output_dir + "/" + targetbd_file

    for tag in chain(root.iter('cardName'), root.iter('productname')):
        print("tag", tag.text)
        AC.get_vDU_TargetBD_file(targetbd, xvdu_ip, xvdu_username, xvdu_password, xvdu_namespace)
        tree_targetbd = Et.parse(targetbd)
        root_targetbd = tree_targetbd.getroot()
        targetbd_values = get_values_from_targetbd(root_targetbd, str(tag.text))

        for tag1 in ResourceBuildKey:
            if re.search('software', tag1, re.IGNORECASE):
                p_tag = tag.getparent().getparent()
                for c_tag in p_tag.xpath(tag1):
                    build_version = c_tag
                    build_version.text = targetbd_values['resourceSWVersion']
            else:
                build_version = tag.getparent().find(tag1)
                build_version.text = targetbd_values['resourceSWVersion']

        for tag1 in SwFileKey:
            p_tag = tag.getparent().getparent()
            for c_tag in p_tag.xpath(tag1):
                build_key = c_tag
                build_key.text = targetbd_values['swFileKey']

        if gscn_value != "None":
            gscn_tag = root.find(GSCN)
            gscn_tag.text = gscn_value

        tree.write(updated_iphy_filename)

    send_custom_iphy_to_simulator(updated_iphy_filename)


def execute_command(command):
    """ Executes given command in local console
    :param str command: command that will be executed
    :return: output of command
    :rtype: str
    """
    pipes = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, stderr = pipes.communicate()
    if pipes.returncode != 0:
        exception = subprocess.CalledProcessError(pipes.returncode, command, output=output)
        error_msg = 'ERROR occurred\nstderr: {}:\nRC: {}'.format(stderr.strip(), pipes.returncode)
        logger.error(error_msg)
        raise exception
    return output.decode('utf-8')


def get_values_from_targetbd(root, radio_name):
    """
    Returns dictionary with resourceSWVersion and swFileKey
    :param root: parsed TargetBD.xml file
    :param radio_name: name of simulated radio taken from TargetBD.xml file
    :return: ditionary
    """
    target_bd_values = {}
    pattern = "LTX_" + radio_name + ".*"
    print("****pattern", pattern)
    for child in root:
        print("######### Debug ########", type(child.attrib["resourceBuildKey"]))
        print("********DEBUG *******", child.attrib["resourceBuildKey"])
        if re.match(pattern, child.attrib["resourceBuildKey"]):
            target_bd_values['resourceSWVersion'] = child.attrib['resourceSWVersion']
            for grandchild in child:
                if grandchild.tag == 'swFileKey':
                    target_bd_values['swFileKey'] = grandchild.text
            return target_bd_values


def send_custom_iphy_to_simulator(iphy_filename):
    """
    Sends custom iphy.xml to the IPHY module.
    :param custom_iphy: path to the custom iphy.xml
    """
    destination = 'toor4nsn@192.168.200.1:/ffs/run/simmode'
    sshpass_prefix = 'sshpass -p oZPS0POrRieRtu'
    scp_options = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
    source = iphy_filename

    execute_command('{} scp {} {} {}'.format(sshpass_prefix, scp_options, source, destination))
    cmd = "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 \'rm -rf /ffs/run/simmode/iphy.xml\'"
    os.system(cmd)
    cmd = "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 \'ln -s /ffs/run/simmode/" + \
          os.path.basename(iphy_filename)+" /ffs/run/simmode/iphy.xml\'"
    os.system(cmd)
    cmd = "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 \'ls -lrt /ffs/run/simmode/\'"
    os.system(cmd)


###################################################################
# if __name__ == "__main__":
#    update_iphy_xml("/home/ute/iphy_test1.xml",'1')
