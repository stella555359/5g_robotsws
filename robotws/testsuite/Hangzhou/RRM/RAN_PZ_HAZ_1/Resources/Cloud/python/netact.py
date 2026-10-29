# -*- coding: utf-8 -*-
"""
Author: Xu Yuyan
Contacts: yuyan.xu@nokia-sbell.com
Description: this script is used for netact auto KW, refer from RFRL:netactlcm_utils.py.

"""
import os
import yaml
import shutil
import time
import tarfile


def _uncompress_tar_file(filename, uncompresspath):
    if os.path.isfile(filename):
        with tarfile.open(filename, 'r') as f:
            f.extractall(uncompresspath)
    else:
        return False
    return True


def _download_yaml_conversion_tool(swversion, temppath):
    try:
        if os.path.exists(temppath):
            shutil.rmtree(temppath)
        os.makedirs(temppath)
        artifactoryurl = """https://artifactory-hz1.int.net.nokia.com/artifactory"""
        wgetpathurl = """{0}/mnp5g-central-public-remote/System_Release/{1}/{2}/artifacts/conversionApp-{3}.tar.gz"""
        wgetoutpath = temppath + """/conversionApp-{0}.tar.gz"""
        swversionlist = swversion.split('_')
        versionnmuber = swversionlist[1].strip()
        productrelease = swversionlist[0].strip()
        wgetpathurl = wgetpathurl.format(artifactoryurl, productrelease, swversion, versionnmuber)
        wgetoutpath = wgetoutpath.format(versionnmuber)
        command = """sudo wget --progress=dot:giga -T 600 -t 2 {wgetpathurl} -O {wgetoutpath}"""
        command = command.format(wgetpathurl=wgetpathurl, wgetoutpath=wgetoutpath)
        print("command:", command)
        os.system(command)
        print(wgetoutpath)
        return wgetoutpath
    except Exception:
        print("can not download conversion tool")
        return ""


def get_conversion_tool(swversion, toolpath):
    """
    Download and uncompress conversion tool

    _*Parameters:*_
    | Input Parameters | Man. | Description                              |
    | productname      | Yes  | product name vcd/vdu                     |
    | swversion        | Yes  | product package version, vcu/vdu version |
    | toolpath         | Yes  | store conversion tool path, carefully    |

    _*Return Value:*_
    | Return Value | Return Ture when success, otherwise Return False    |

    _*Example:*_
    | ${swversion}       | "vCUCNF00_0.250.13351"    |
    | ${toolpath}        | "/home/ute/yamltemp"      |
    | get_conversion_tool    | ${swversion} | ${temppath} |

    """
    unique_id = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    currenttoolpath = os.path.join(toolpath, unique_id)
    temppath = os.path.join(currenttoolpath, "conversiontool")
    conversiontoolname = _download_yaml_conversion_tool(swversion, temppath)
    if _uncompress_tar_file(conversiontoolname, temppath):
        gzfilepath = temppath + """/conversionApp"""
        print(gzfilepath)
        files = os.listdir(gzfilepath)
        for file in files:
            print(file)
            if file.endswith('gz'):
                gzfile = gzfilepath + """/""" + file
                print(gzfile)
                _uncompress_tar_file(gzfile, gzfilepath)
                return currenttoolpath
    else:
        return None


def conversion_yaml_file(toolpath, oldyamlfile, yamlstyle, productname):
    """
    Conversion old version yaml file to current version yaml file
    the keyword need to use with get_conversion_tool keyword together
    the current yaml file name oldyamlfile + "_new"
    Note:
    aic-vcu-cluster-preparation-17.402.1.tgz  "cluster"
    aic-vcu-prerequisite-18.556.3.tgz         "prerequisite"
    aic-vcu-0.250.12912.tgz                   " "

    _*Parameters:*_
    | Input Parameters | Man. | Description                                                          |
    | toolpath         | Yes  | conversion tool store path,same with temppath in get_conversion_tool |
    | oldyamlfile      | Yes  | input old version yaml file                                          |
    | yamlstyle        | Yes  | which chart parameter file, "cluster"/"prerequisite"/""              |
    | productname      | Yes  | product name vcd/vdu                     |
    _*Return Value:*_
    | Return Value | Return current yaml file name    |

    _*Example:*_
    | ${toolpath}        | "/home/ute/yamltemp"                                 |
    | ${oldyamlfile}     | "/home/ute/yamlfile/values-override.aic-vcu.yaml"    |
    | ${yamlstyle}       | " "                                                  |
    | ${productname}     | vcu                                                  |
    | conversion_ymal_file | ${toolpath}  | ${oldyamlfile} | ${yamlstyle} |  ${productname} /

    """
    temppath = os.path.join(toolpath, "conversiontool")
    checkstyle = yamlstyle.strip().lower()
    # applicationpath = temppath + """/conversionApp"""
    application = temppath + """/conversionApp/cnf_userinput_conversion"""
    newyamlfile = oldyamlfile.strip() + """_new"""
    if os.path.isfile(newyamlfile):
        os.remove(newyamlfile)
    cmd = """{application} -s {oldyamlfile} -t {template} -o {newyamlfile}"""
    tool_style = productname.strip().lower()
    if checkstyle == 'cluster':
        templatefile = temppath + "/conversionApp/values-override.aic-{0}-cluster-preparation.tpl".format(tool_style)
    elif checkstyle == 'prerequisite':
        templatefile = temppath + "/conversionApp/values-override.aic-{0}-prerequisite.tpl".format(tool_style)
    else:
        templatefile = temppath + "/conversionApp/values-override.aic-{0}.tpl".format(tool_style)
    cmd = cmd.format(application=application, oldyamlfile=oldyamlfile, template=templatefile, newyamlfile=newyamlfile)
    print(cmd)
    os.system(cmd)
    return newyamlfile


def delete_conversion_tool(toolpath):
    """
    :param toolpath:
    :return: No return
    """
    if os.path.exists(toolpath):
        shutil.rmtree(toolpath)
