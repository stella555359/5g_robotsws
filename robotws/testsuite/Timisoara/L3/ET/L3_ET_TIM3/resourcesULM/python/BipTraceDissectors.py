import os
from robot.libraries.BuiltIn import BuiltIn
rbi = BuiltIn()


class BipTraceDissectors:

    def get_software_release(self):
        swVersion = rbi.run_keyword("Get gNB SW version")
        if "SBTS" in swVersion:
            return (swVersion)
        else:
            return (swVersion.split("_")[1])

    def download_and_unzip_dissectors(self, swVersion, lua_base_path='/opt/lua_dissector'):

        if not os.path.exists(lua_base_path):
            cmdStr = "sudo mkdir {0} ; sudo chmod 777 {0} ; cd {0}".format(lua_base_path)
            os.system(cmdStr)

        sw_version_path = "{}/{}".format(lua_base_path, swVersion)
        if not os.path.exists(sw_version_path):
            cmdStr = "sudo mkdir {0} ; sudo chmod 777 {0} ; cd {0}".format(sw_version_path)
            os.system(cmdStr)
            os.chdir(sw_version_path)
            if "SBTS" in sw_version_path:
                wget_command = "wget https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/%s/%s_luashark.zip" %\
                               (swVersion.split("_")[0], swVersion)
            else:
                wget_command = "wget " \
                               "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/"
                wget_command += "System_Release/%s/luashark-%s.zip" % (swVersion, swVersion)
            os.system(wget_command)
            os.system("unzip * ; chmod 777 *")
        else:
            print("Dissectors already loaded!")
        luashark_path = sw_version_path + "/generated_luashark/luashark.lua"
        return luashark_path

    def get_lua_dissectors_if_needed(self, swVersion=None, lua_base_path='/opt/lua_dissector'):
        # https://artifactory-espoo1.ext.net.nokia.com/artifactory/
        #         mnp5g-central-public-local/System_Release/0.800.2402/luashark-0.800.2402.zip

        try:
            if not swVersion:
                swVersion = self.get_software_release()
            lua_path = self.download_and_unzip_dissectors(swVersion, lua_base_path)
            return lua_path
        except Exception as e:
            rbi.log("get_lua_dissectors_if_needed(): Exception = <%s>" % str(e))
