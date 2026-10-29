#######################################################################################################################
#   VERSION          DATE                AUTHOR                     	               COMMENTS
#   1.0              15-May-2021         nupur.rupram_kohadkar@nokia.com                Initial
#######################################################################################################################
import os
import sys
from exceptions import *
from sys import argv
from ute_admin import ute_admin
import time
import subprocess
import argparse


#######################################################################################################################

class build_download_and_update:

    def setup_admin(self):
        try:
            admin = ute_admin()
            admin.setup_admin(bts_host="192.168.255.129", bts_port="443", username="Nemuadmin", password="nemuuser",
                              use_ssl=True)
            return admin
        except Exception as e:
            print("\n[ERROR] Unable to Setup Admin due to {0}\n".format(e))
            sys.exit(0)

    def check_bts_for_OnAir(self):
        admin = p1.setup_admin()
        try:
            for i in range(96):
                status = admin.get_mrbts_state(timeout=10, alias='default')
                if str(status).lower() == "onair":
                    print("\n[INFO] BTS is OnAir\n")
                    admin.teardown_admin()
                    return True
                else:
                    time.sleep(5)
        except Exception as e:
            print("\n[ERROR] Execution Failed due " + str(e) + "\n")
            admin.teardown_admin()
        print("\n[INFO] BTS is in {0} state\n".format(status))
        admin.teardown_admin()
        return False

    def build_download(self, build_version):
        try:
            if '5G' in build_version:
                print("\n*************** 5G Build ***************\n")
                build = build_version.split('_')[1]
                if os.path.isfile('AirScale-' + build + '.zip'):
                    cmd = 'rm ' + 'AirScale-' + build + '.zip'
                    os.system(cmd)
                link = 'aria2c -x 16 -s 16 https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central' \
                       '-public-local/System_Release/' + build + '/AirScale-' + build + '.zip '
                os.system(link)

            elif 'SBTS' in build_version:
                print("\n*************** SBTS Build ***************\n")
                build = build_version.split('_')[0]
                if os.path.isfile(build_version + '_release_BTSSM_downloadable_A54.zip'):
                    cmd = 'rm ' + build_version + '_release_BTSSM_downloadable_A54.zip'
                    os.system(cmd)
                link = 'aria2c -x 16 -s 16 http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/' + build + '/' + \
                       build_version + '_release_BTSSM_downloadable_A54.zip'
                os.system(link)

            else:
                print('\n[ERROR] Invalid Build\n')
                sys.exit(0)
        except Exception as e:
            print(e)
            sys.exit(0)

    def build_update(self, build_version):
        pwd = subprocess.check_output('pwd')
        pwd = pwd.strip('\n')

        if 'SBTS' in build_version:
            cmd = pwd + '/' + build_version + '_release_BTSSM_downloadable_A54.zip'
        elif '5G' in build_version:
            cmd = pwd + '/' + 'AirScale-' + build_version.split('_')[1] + '.zip'

        if os.path.isfile(cmd):
            admin = p1.setup_admin()
            try:
                bts = admin.get_bts_info(timeout=10, alias='default')
                bts_id = str(bts['mrbtsID'])

                try:
                    print("\n[INFO] Updating Software")
                    admin.update_software(cmd, should_activate=True, timeout=600, alias="default")
                    print("\n[INFO] Software Updated Sucessfully\n")
                    admin.teardown_admin()
                    time.sleep(360)
                    cmd1 = "rm " + cmd
                    os.system(cmd1)

                except Exception as e:
                    print("\n[INFO] Software Update failed due to " + str(e) + '\n')

                    print("\n[INFO] Collecting SCF")
                    admin.collect_scf(pwd + '/' + 'Full_Configuration' + bts_id + '.xml',
                                      export_type='configurationAndRuntimeObjects', timeout=120, alias='default')
                    print("\n[INFO] SCF collected\n")
                    print("\n[INFO] Performing Configuration Reset")
                    admin.reset_configuration(remove_site_id=False, remove_security_credentials=False, timeout=1200,
                                              alias='default')
                    print("\n[INFO] Configuration Reset Sucessfull.\n")
                    time.sleep(120)
                    admin.teardown_admin()

                    try:
                        admin = p1.setup_admin()
                        print("\n[INFO] Updating Software after Config Reset")
                        admin.update_software(cmd, should_activate=True, timeout=1800, alias="default")
                        print("\n[INFO] Software Updated Sucessfully.\n")
                        admin.teardown_admin()
                        time.sleep(360)
                        cmd1 = "rm " + cmd
                        os.system(cmd1)
                        '''
                        time.sleep(300)
                        admin = p1.setup_admin()
                        active_sw = build_version.split('_')[0]
                        print('\nChecking SCF file for ' + str(active_sw) + ' in ' + pwd +'/' + str(active_sw) + '\n')
                        if os.path.isfile(pwd +'/' + str(active_sw) + '/scf1.xml'):
                            print("\nScf file is present for "+str(active_sw)+"\n")
                            print("\nPerform Commissioning...")
                            admin.perform_commissioning(bts_id, pwd +'/' + str(active_sw) + '/scf1.xml',
                            skip_parameter_relation_errors=True, should_activate=True, timeout=1200, alias='default')
                            print(".\nCommissioning Successfull.\n")
                            admin.teardown_admin()
                            os.system(cmd1)
                            time.sleep(240)
                        else:
                            print("\nSCF file not present for " + str(active_sw) + "in " + pwd +'/' + str(active_sw) +
                            "\n" )
                            sys.exit(0)
                        '''
                    except Exception as e:
                        print("\n[ERROR] Execution Failed due to " + str(e) + "\n")
                        sys.exit(0)

            except Exception as e:
                print("[ERROR] Unable to get BTS id :" + str(e))
                admin.teardown_admin()
                sys.exit(0)

        else:
            print("\n[ERROR] Build not exist in " + pwd + "\n")
            sys.exit(0)

    def commissioning(self, scfc_file_path):

        if os.path.isfile(scfc_file_path):
            admin = p1.setup_admin()
            try:
                bts = admin.get_bts_info(timeout=10, alias='default')
                bts_id = str(bts['mrbtsID'])

                print("\n[INFO] Perform Commissioning")
                admin.perform_commissioning(bts_id, scfc_file_path, skip_parameter_relation_errors=True,
                                            should_activate=True, timeout=1500, alias='default')
                print("\n[INFO] Commissioning Succesfull.\n")
                admin.teardown_admin()
                time.sleep(180)

            except Exception as e:
                print("\n[ERROR] Commissioning failed due to " + str(e))
                admin.teardown_admin()
                sys.exit(0)

        else:
            print("\n{ERROR] File not exist in " + str(scfc_file_path) + "\n")
            sys.exit(0)

    def get_sw_version(self):
        try:
            admin = p1.setup_admin()
            swversionstring = admin.get_software_info(timeout=60)
            active_sw = swversionstring['Active SW version']
            admin.teardown_admin()
            return active_sw
        except Exception as e:
            print("\n[ERROR] Unable to get Software Vesrion" + "\n")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Software Build Download and Update BTS")
    parser.add_argument("-b", "--build_version",
                        help="Enter commissioning file path  e.g. SBTS20C_ENB_0000_002175_000000 [Mandatory]",
                        required=True)
    # parser.add_argument("-sf", "--scfc_file_path", help="Enter commissioning file path [Mandatory]", required=True)
    argument = parser.parse_args()
    build_version = argument.build_version
    scfc_file_path = argument.scfc_file_path

    p1 = build_download_and_update()
    p1.build_download(build_version)
    p1.build_update(build_version)
    # p1.commissioning(scfc_file_path)
    # value = p1.check_bts_for_OnAir()
    # if value == True :
    #    print("\nStarting Scan\n")
    # else:
    #    print("\n[ERROR] Unable to execute Scan. ENB/GNB not reaching Onair\n")
