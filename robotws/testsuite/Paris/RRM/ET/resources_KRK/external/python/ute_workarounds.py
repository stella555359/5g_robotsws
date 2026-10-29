import os
import subprocess

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]
rbi = BuiltIn()


def install_multidynamic_if_neeeded():
    # Author : Nikolay Shkulepov
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Private Keyword: Install Multidynamic if neeeded
    # It helps to check whether MULTI is installed and install it if not
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        import multi
    except ImportError:
        try:
            if os.getenv("VIRTUAL_ENV"):
                pip_path = os.path.join(os.getenv("VIRTUAL_ENV"), "bin", "pip")
            else:
                pip_path = "pip"
            cmdStr = "sudo mkdir /opt/tti_dissectors ; sudo chmod 777 /opt/tti_dissectors ; cd /opt/tti_dissectors"
            rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                    cmdStr, "TRACE")
            swVersion = rbi.run_keyword("Get gNB SW version")
            rbi.log("install_multidynamic_if_neeeded(): swVersion = %s" %
                    swVersion, "TRACE")
            os.chdir("/opt/tti_dissectors")
            if swVersion.startswith("SBTS"):
                cmdStr1 = "wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/"
                cmdStr2 = "%s_tti-dissectors.zip" % swVersion
                zipFileName = "%s_tti-dissectors.zip" % swVersion
            else:
                swVersion = rbi.run_keyword("Get gNB SW version").split("_")[1]
                cmdStr1 = "wget https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/"
                cmdStr2 = "System_Release/%s/tti-dissectors-%s.zip" % (
                    swVersion, swVersion)
                zipFileName = "tti-dissectors-%s.zip" % swVersion
            try:
                os.system(cmdStr)
                cmdStr = cmdStr1 + cmdStr2
                rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                        cmdStr, "TRACE")
                subprocess.run(cmdStr, timeout=30)
            except Exception as e:
                rbi.log(e)
                rbi.log("tti dissectors are already installed")
            cmdStr1 = "unzip -n %s ; " % zipFileName
            cmdStr2 = "chmod 777 * ; " + pip_path + \
                " install --no-index -f . multidynamic.zip"
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                    cmdStr, "TRACE")
            os.system(cmdStr)
        except Exception as e:
            rbi.log("install_multidynamic_if_neeeded(): Exception = <%s>" % str(e))
