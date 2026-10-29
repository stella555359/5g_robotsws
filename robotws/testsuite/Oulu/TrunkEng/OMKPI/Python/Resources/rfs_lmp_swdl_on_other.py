#!/usr/bin/env python
# *- coding: utf-8 -*
"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import os
import sys
import subprocess
import time
from traceback import format_exception
from taf.sbts.oam.coam.admin import admin
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse

api = admin()
connection_ok = False


def create_admin_connection(retry_max_time=5, retry_interval=30, retry=0):
    if retry == 0:
        print("Create log folder for admin logs to /tmp/admin_logs on Other VM.")
        if not os.path.exists("/tmp/admin_logs_other"):
            os.makedirs("/tmp/admin_logs_other", exist_ok=True)
        print("Creating admin connection...")
    else:
        print(f"{retry}. try to create admin connection...")
    try:
        api.setup_admin(bts_host="192.168.255.129", admin_api_log_dir="/tmp/admin_logs_other", name='lmp_other',
                        timeout=60)
        print(f"Admin connection created.")
        global connection_ok
        connection_ok = True
    except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
            AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
            AliasInUse) as admin_error:
        tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
        print(f"Error when creating admin connection. {admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
        if retry < retry_max_time:
            print("Retry creating admin connection in 30s...")
            time.sleep(retry_interval)
            create_admin_connection(retry_max_time, retry_interval, retry+1)
        else:
            print("Unable to create Admin connection to Other LMP.")
            raise Exception("Admin connection creation failed")


def rfs_swdl_other(sw_build_path="", ru_swdl=False, activate_sw=True, retry=0):
    try:
        create_admin_connection()
        if connection_ok:
            if ru_swdl:
                print("Starting RU LMP SWDL on Other...")
                response = api.update_software(
                    sw_build_path, should_activate=activate_sw, timeout=18000,
                    independent_sw_update_type="RuSwOnly", connection='lmp_other')
            else:
                print("Starting LMP SWDL on Other...")
                response = api.update_software(sw_build_path, should_activate=activate_sw, timeout=18000,
                                               connection='lmp_other')
            print(f"SWDL response: {response}")
            if "Software update has been completed" in response:
                print("Software update was successful.")
                return True
            else:
                print("ERROR: Software update was not successful.")
                return False
        else:
            print("ERROR: No admin connection -> we cannot update software")
            return False
    except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
            AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
            AliasInUse) as admin_error:
        tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
        print(f"Error noticed during Software update. {admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
        if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
            if retry == 0:
                print("Unable to update software, because of session invalidation. Restart admin connection and try "
                      "again.")
                print("Call method rfs_swdl_other again after admin connection reset.")
                api.reset_admin(connection="lmp_other")
                rfs_swdl_other(sw_build_path=sw_build_path, ru_swdl=ru_swdl, activate_sw=activate_sw, retry=1)
            elif retry == 1:
                raise Exception("ERROR: Unable to update software from admin, because of session invalidation. Admin "
                                "connection restart did not help.")
        raise Exception(f"ERROR: Unable to update software from admin, because of {admin_error.__class__.__name__}.")
    finally:
        teardown_admin_connection()


def teardown_admin_connection():
    print("Teardown admin connection")
    try:
        api.teardown_admin(connection='lmp_other')
    except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
            AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
            AliasInUse) as admin_error:
        tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
        print(f"Error noticed during admin teardown {admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")


def wget_commands(sw_url, swdl_path="/home/ute/logs/"):
    """
    Use wget command to get SW build from website.

    :param str sw_url: Url from where the build is downloaded.
    :param str swdl_path: Path where the build is saved. Default is /home/ute/logs/.
    """
    print(f"Get build from {sw_url} to {swdl_path} -folder")
    command = f"wget --content-on-error -P {swdl_path} {sw_url}"
    path_to_saved_build = "{}{}".format(swdl_path, sw_url[sw_url.rfind("/")+1:])
    if os.path.exists(path_to_saved_build) and os.path.isfile(path_to_saved_build):
        print("Software already fetched to remote VM. No need to download it again.")
        return path_to_saved_build
    subp = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        outs, errs = subp.communicate(timeout=7200)
        print("Software fetched!")
        if "ERROR 404: Not Found.".encode() in errs:
            print("ERROR: Build was not found from artifactory. Cannot download build. Downloading"
                  " url {} returns ERROR: 404 Not Found".format(sw_url))
            print(errs)
            raise Exception("Build Not Found FromArtifactory")
        print("Build was saved to {}".format(path_to_saved_build))
        return path_to_saved_build
    except subprocess.TimeoutExpired:
        print("TimeoutExpired when getting build from artifactory ({})".format(sw_url))
        subp.kill()
        outs, errs = subp.communicate()
        print(outs, errs)
        raise Exception("TimeOut When Downloading From Artifactory")
    finally:
        print("Kill the subprocess in finally, just in case")
        subp.kill()


def check_size_of_sw_build(sw_build_path):
    """
    Check that size of software build is at least 8GiB. If not, raise error.

    :param str sw_build_path: Path to sw build.
                              For example
                              /home/ute/logs/SBTS00_ENB_9999_230606_000009_release_BTSSM_downloadable_
                              testpackage_T1_A54.zip
    :return boolean: If size ok return True, otherwise return False.
    """
    build_size = os.path.getsize(sw_build_path)
    min_build_size = "8000000000"
    if "_FSM3_" in sw_build_path:
        min_build_size = "1500000000"
    if build_size < int(min_build_size):
        print("ERROR: Size of {} should be at least {} ({}GB), it is {}. Invalid software package. NOK.".format(
            sw_build_path, min_build_size, min_build_size[0], build_size))
        return False
    print("Size of {} is {}, OK.".format(sw_build_path, build_size))
    return True


if __name__ == "__main__":
    print(sys.argv)
    if ".zip" not in str(sys.argv[1]):
        print("Invalid argument. Give path to build zip as first argument")
        raise ValueError("Invalid argument")
    sw_path = sys.argv[1]
    if len(sys.argv) > 2:
        if 'true' in str(sys.argv[2]).lower():
            ru_swdl_only = True
        else:
            ru_swdl_only = False
        if 'false' in str(sys.argv[3]).lower():
            should_activate = False
        else:
            should_activate = True
        swdl_ok = rfs_swdl_other(sw_path, ru_swdl_only, should_activate)
        if not swdl_ok:
            raise Exception("RFS LMP SWDL on Other failed")
    else:
        sw_path_local = wget_commands(sw_path)
        if sw_path_local:
            b_size = check_size_of_sw_build(sw_path_local)
            if not b_size:
                print("ERROR: Software package is too small. Cannot continue.")
                raise Exception("Software package is too small")

        else:
            print("Software was not fetched to remote VM. Cannot continue.")
            raise Exception("Software was not fetched to remote VM")
