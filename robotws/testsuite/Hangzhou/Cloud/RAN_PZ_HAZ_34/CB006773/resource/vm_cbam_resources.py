# ----------------------------------------------------------------------
#
# File: vm_cbam_resources.py
#
# Set of keywords related to CBAM management.
#
# ----------------------------------------------------------------------

import os
import sys
import re
import json
import requests
import datetime
import glob
import fileinput
from shutil import copyfile

from requests.packages.urllib3.exceptions import InsecureRequestWarning
# from requests.auth import HTTPBasicAuth
# from requests.auth import HTTPDigestAuth

from robot.api import logger

from jsonpointer import resolve_pointer


# ----------------------------------------------------------------------
# CLASS vm_cbam_resources
# ----------------------------------------------------------------------

class vm_cbam_resources(object):

    # ------------------------------------------------------------------
    # Robot Framework keywords.
    # ------------------------------------------------------------------

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0'

    # ------------------------------------------------------------------
    # Constructor / initializer.
    # ------------------------------------------------------------------

    def __init__(self):
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # ==================================================================
    # METHODs related to checking results.
    # ==================================================================

    # ------------------------------------------------------------------
    # METHOD get_vnf_id
    # ------------------------------------------------------------------

    def get_vnf_id(self, vnf_list, vnf_name):
        vnfs = {}

        for vnf in vnf_list:
            vnfs[vnf['vnfInstanceName']] = {}
            vnfs[vnf['vnfInstanceName']]['id'] = vnf['id']
            vnfs[vnf['vnfInstanceName']]['state'] = vnf['instantiationState']

        return(vnfs[vnf_name]['id'])

    # ------------------------------------------------------------------
    # METHOD get_vnfd_id_from_vnf
    # ------------------------------------------------------------------

    def get_vnfd_id_from_vnf(self, vnf_list, vnf_name):
        vnfs = {}

        for vnf in vnf_list:
            vnfs[vnf['vnfInstanceName']] = {}
            vnfs[vnf['vnfInstanceName']]['vnfdId'] = vnf['vnfdId']
            vnfs[vnf['vnfInstanceName']]['state'] = vnf['instantiationState']

        return(vnfs[vnf_name]['vnfdId'])

    # ------------------------------------------------------------------
    # METHOD get_vnf_state
    # ------------------------------------------------------------------

    def get_vnf_state(self, vnf_list, vnf_name):
        vnfs = {}
        for vnf in vnf_list:
            vnfs[vnf['vnfInstanceName']] = {}
            vnfs[vnf['vnfInstanceName']]['id'] = vnf['id']
            vnfs[vnf['vnfInstanceName']]['state'] = vnf['instantiationState']
        return(vnfs[vnf_name]['state'])

    # ------------------------------------------------------------------
    # METHOD get_operation_vnf_state                              # TBC!
    # ------------------------------------------------------------------

    def get_operation_vnf_state(self, vnf_info):
        return(vnf_info['instantiationState'])

    def get_operation_id(self, vnf_info):
        return(vnf_info['id'])

    # ------------------------------------------------------------------
    # METHOD get_vnf_package                                      # TBC!
    # ------------------------------------------------------------------

    def get_vnf_package(self, vnf_list, vnf_type):
        vnf_package = ""
        for vnf in vnf_list:
            if vnf_type in vnf['vnfdId']:
                vnf_package = vnf['vnfdId']
                break
        return vnf_package

    def determine_sw_version(self, tmpdir):
        sw_version = "NONE"

        for name in glob.glob(tmpdir + '/Addons-*'):
            print("- name = {}".format(name))
            if os.path.isfile(name):
                sw_version = re.search("^.*Addons-(.*).txz$", name).group(1)
                print("- sw_version = {}".format(sw_version))
                break

        return sw_version

    # ------------------------------------------------------------------
    # METHOD resolve
    # ------------------------------------------------------------------

    def resolve(self, url_with_domain):
        ip = None
        with requests.get(url_with_domain, stream=True) as r:
            ip = r.raw._connection.sock.getpeername()[0]

        domain = url_with_domain.split('//')[-1].split('/')[0]

        url_with_ip = url_with_domain.replace(domain, ip)

        return url_with_ip

    def get_vnfd_id(self, vnfd_list, vnf_type, release, vim_type="NCIR"):

        vnfd_id = None
        release = release.upper()
        vnf_format = "NCIR" if vim_type == "NCIR" else "VCP"

        vnfd_id_list = []
        vnfd_version_list = []

        for vnfd in vnfd_list:
            # print("- vnfd = %s" % vnfd)
            if 'vnfSoftwareVersion' in vnfd:

                # E.g. "vnfSoftwareVersion": "5G20B",
                pattern = '^.*{}.*$'.format(release)
                if re.match(pattern, vnfd['vnfSoftwareVersion'], re.IGNORECASE):
                    if 'vnfProductName' in vnfd:

                        # E.g. when VNF flavor:    "vnfProductName": "5G Flavors on NCIR19",
                        # E.g. when VNF extnet:    "vnfProductName": "5GBTS External Networks for 5G19B on NCIR19",
                        # E.g. when VNG gnb_cu:    "vnfProductName": "5GBTS VNF on NCIR19",
                        # E.g. when VNG gnb_cu_ha: "vnfProductName": "5GBTS VNF WITH REDUNDANT ...",
                        if (vnf_type == 'extnet'):
                            vnf_type = 'Network'

                        if (vnf_type == 'gnb_cu'):
                            vnf_type = 'VNF'

                        if (vnf_type == 'gnb_cu_ha'):
                            vnf_type = 'VNF WITH REDUNDANT 2OAM'

                        # Define the product name pattern.
                        pattern = '^5G.*{}.* on {}$'.format(vnf_type, vnf_format)

                        if re.match(pattern, vnfd['vnfProductName'], re.IGNORECASE):
                            # print("- vnfd['vnfProductName'] = %s" % vnfd['vnfProductName'])
                            # vnfd_id = vnfd['vnfdId']
                            vnfd_id_list.append(vnfd['vnfdId'])
                            vnfd_version_list.append(vnfd['vnfdVersion'])

        # Select the VNFD with the latest version.
        print("- vnfd_id_list = " + str(vnfd_id_list))
        print("- vnfd_version_list = " + str(vnfd_version_list))
        if len(vnfd_id_list) == 1:
            vnfd_id = vnfd_id_list[0]
        elif len(vnfd_id_list) > 1:
            max_version = "0"
            for i, version in enumerate(vnfd_version_list):
                if self.compare_versions(max_version, version) < 0:
                    max_version = version
                    vnfd_id = vnfd_id_list[i]
        return vnfd_id

    # ------------------------------------------------------------------
    # METHOD compare_versions
    # ------------------------------------------------------------------
    #
    # compare_versions("1.1.10", "1.1.10") => 0
    # compare_versions("1.1",    "1.1.1")  => -1
    # compare_versions("1.1.1",  "1.1")    => 1
    #

    def compare_versions(self, version1, version2):
        def normalize(v):
            return [int(x) for x in re.sub(r'(\.0+)*$', '', v).split(".")]
        return cmp(normalize(version1), normalize(version2))

    # ------------------------------------------------------------------
    # METHOD customize_vnf_config_files_of_type_instantiate
    # ------------------------------------------------------------------

    def customize_vnf_config_files_of_type_instantiate(
            self,
            srcdir,
            dstdir,
            version
            ):

        logger.info("METHOD vm_cbam_resources::customize_vnf_config_files_of_type_instantiate()", also_console=True)
        logger.info("- INPUT: srcdir  = {}".format(srcdir), also_console=True)
        logger.info("- INPUT: dstdir  = {}".format(dstdir), also_console=True)

        if not os.path.exists(dstdir):
            os.makedirs(dstdir)

        ch_inst = {
            "['softwareImages'][0]['vimSoftwareImageId']": "'{}'".format(version),

        }

        for instantiatefile in os.listdir(srcdir):
            logger.info("- instantiatefile = {}".format(instantiatefile), also_console=True)

            if '.json' not in instantiatefile:
                continue

            if "instantiate" in instantiatefile:
                logger.info("Treat {} file...".format(instantiatefile), also_console=True)

                fin = srcdir + '/' + instantiatefile
                fout = dstdir + '/' + instantiatefile
                self.update_json_file(fin, fout, ch_inst)

                # Update image reference.
            if "vnf" in instantiatefile:
                fh = open(fout, 'r')
                filedata = fh.read()
                fh.close()
                # Modify data.
                newdata = ""
                # vimSoftwareImageId = '"vimSoftwareImageId": "{}_CU_{}",'.format(release.upper(), load)
                vimSoftwareImageId = '"vimSoftwareImageId": "{}",'.format(version)

                for line in filedata.split('\n'):
                    nline = re.sub('\"vimSoftwareImageId\": .*', vimSoftwareImageId, line)
                    newdata += nline + "\n"
                # Overwrite file contents.
                fh = open(fout, 'w')
                fh.write(newdata)
                fh.close()
        return True

    def update_json_file(self, inputfile, outputfile, changes):

        logger.info("METHOD vm_cbam_resources::update_json_file()", also_console=True)
        logger.info("- INPUT: inputfile = {}".format(inputfile), also_console=True)
        logger.info("- INPUT: outputfile = {}".format(outputfile), also_console=True)
        logger.info("- INPUT: type(changes) = {}".format(type(changes)), also_console=True)

        fin = open(inputfile, "r")
        fout = open(outputfile, "w")

        # Load the input json data.
        data = json.load(fin)

        # Modify the json data.
        for change in changes:

            logger.info("- change = {}".format(change), also_console=True)

            if (change.split("'")[1] == 'extensions'):
                par = change.split("'")[3]
                rest = change.partition("]")[2].partition("]")[2]
                extensions = data["extensions"]

                for i, extension in enumerate(extensions):
                    if (extension["name"] == par):
                        xchange = "data['extensions'][{}]['value']{} = {}".format(i, rest, changes[change])
                        logger.info("  => {}\n".format(xchange), also_console=True)
                        exec(xchange)
            else:
                xchange = "data{param}={value}".format(param=change, value=changes[change])
                logger.info("   => {}".format(xchange), also_console=True)
                exec(xchange)

        # Write the modified json data in an outputfile.
        json.dump(data, fout, indent=4)

        fin.close()
        fout.close()

    def sub(self, inputfile, outputfile, text_to_search, text_to_replace):
        fin = open(inputfile, "rt")
        fout = open(outputfile, "wt")

        for line in fin:
            fout.write(line.replace(text_to_search, text_to_replace))

        fin.close()
        fout.close()

        return True

# End of CLASS vm_cbam_resources.


# ----------------------------end-of-file-------------------------------
