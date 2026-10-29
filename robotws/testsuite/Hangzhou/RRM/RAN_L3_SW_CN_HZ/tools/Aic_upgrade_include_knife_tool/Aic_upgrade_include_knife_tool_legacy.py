import getopt
import pprint
import time
import sys
import yaml
import os
import re
from ute_fsmaccess import ute_fsmaccess


class Logger(object):
    def __init__(self, file_name="log.txt"):
        self.terminal = sys.stdout
        self.log = open(file_name, 'a')

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)
        self.log.flush()

    def flush(self):
        pass


sys.stdout = Logger()


class build_aic_knife(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.host_ssh_usr = "core"
        self.host_ssh_pwd = "system123"
        self.host_ssh = None
        self.login_flag = False

    def _login(self):
        if not self.login_flag:
            self.login_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, prompt="$",
                                              user=self.host_ssh_usr, password=self.host_ssh_pwd,
                                              fallback_prompt=">", host=self.host_ssh)
        if self.login_flag:
            if not self.fsm_obj:
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, prompt="$",
                                                  user=self.host_ssh_usr, password=self.host_ssh_pwd,
                                                  fallback_prompt=">", host=self.host_ssh)

    def _logout(self):
        self.fsm_obj.teardown_enb_fsm_access(alias=self.alias)

    def _check_and_patch_pv(self):
        self._login()
        # ret_pv_1 = self.fsm_obj.execute_command_on_enb(
        #     "oc get pv | grep -v Available | grep -v openshift-image-registry/registry-storage", alias=alias)
        ret_pv_2 = self._check_pv()
        if ret_pv_2 != "":
            print("Exist unavailable persistent volume:\n%s" % ret_pv_2)
            print("Try to patch them")
            pv_patch_cmd = (
                "oc patch pv $(oc get pv | grep Released | awk '{print $1}')"
                " --type json -p '[{ \"op\": \"remove\", \"path\": \"/spec/claimRef\" }]'")
            try:
                self.fsm_obj.execute_command_on_enb(pv_patch_cmd, alias=self.alias)
            except Exception as e:
                print(e)
                print("try to check pv again")
            time.sleep(3)
            ret_pv_3 = self._check_pv()
            if ret_pv_3 != "":
                print("\033[1;31;47mStill exist unavailable persistent volume:%s\033" % ret_pv_3)
                raise Exception(
                    print("\033[1;31;47mPlease resolve unavailable persistent volume before install image!\n"
                          " Or Retry upgrade tool again!\033"))
            else:
                print("pv patch successfully")

    def _check_pv(self):
        ret_pv = self.fsm_obj.execute_command_on_enb("oc get pv | grep Released", return_rc=True, alias=self.alias)
        return ret_pv[0]

    def _start_toolbox(self):
        try:
            self.fsm_obj.execute_command_on_enb("sudo -S podman start toolbox-core", alias=self.alias)
        except Exception as e:
            raise Exception("Start toolbox-core unsuccessful: %s" % e)

    def _check_package_link_connection(self, link_address):
        link_conn_status = False
        link_check_ret = self._execute_cmd("curl -Is %s" % link_address)
        if re.search(re.compile(r'404 Not Found', flags=re.I), link_check_ret):
            print("package address can't reach..")
        else:
            link_conn_status = True
        return link_conn_status

    def _download_package(self, tl_folder_name, build, knife_package):
        """About need 3~5 min if using toolbox-core in ute testline"""
        print("===start to download image package, will take some time to finish===")
        self._login()
        self._start_toolbox()
        self.master_directory = "/var/home/core"
        self.master_file_path = self.master_directory + "/" + tl_folder_name + "_" + build
        # host_master_file_path = "/host/var/home/core/7_7_UTE5GCLOUDT7SK030_vDUCNF00_0.300.8664"
        self.host_master_file_path = "/host" + self.master_file_path
        build_num_id = build.split("_")[-1]
        build_release = build.split("_")[0]
        if knife_package is None:
            if build.lower().count(".300.") or build.lower().count(".250."):
                # sw_package_path = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/" \
                #                   "mnp5g-central-public-local/System_Release/" \
                #                   "vDUCNF00/vDUCNF00_0.300.8664/vDUCNF00_0.300.8664.zip"
                # sw_package_path = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/" \
                #                   "mnp5g-central-public-local/System_Release/" \
                #                   "vCUCNF00/vCUCNF00_0.250.8107/vCUCNF00_0.250.8107.zip"
                sw_package_path_espoo = ("https://artifactory-espoo1.ext.net.nokia.com/artifactory/"
                                         "mnp5g-central-public-local/System_Release/" + build_release + "/" + build +
                                         "/" + build + ".zip")
                sw_package_path_hz = ("https://artifactory-hz1.int.net.nokia.com/artifactory/"
                                      "mnp5g-central-public-remote/System_Release/" + build_release + "/" + build +
                                      "/" + build + ".zip")
                sw_package_path = sw_package_path_espoo + " " + sw_package_path_hz
                # onboard_pack_path = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/" \
                #                     "mnp5g-central-public-local/System_Release/" \
                #                     "vDUCNF00/vDUCNF00_0.300.8664/artifacts/onBoardingApp.tgz"
                # onboard_pack_path = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/" \
                #                     "mnp5g-central-public-local/System_Release/" \
                #                     "vCUCNF00/vCUCNF00_0.250.8107/artifacts/onBoardingApp.tgz"
                onboard_package_path_espoo = ("https://artifactory-espoo1.ext.net.nokia.com/artifactory/"
                                              "mnp5g-central-public-local/System_Release/" + build_release + "/" +
                                              build + "/artifacts/onBoardingApp.tgz")
                onboard_package_path_hz = ("https://artifactory-hz1.int.net.nokia.com/artifactory/"
                                           "mnp5g-central-public-remote/System_Release/" + build_release + "/" +
                                           build + "/artifacts/onBoardingApp.tgz")
                onboard_package_path = onboard_package_path_espoo + " " + onboard_package_path_hz
                conversionapp_path_espoo = ("https://artifactory-espoo1.ext.net.nokia.com/artifactory/"
                                            "mnp5g-central-public-local/System_Release/" + build_release + "/" +
                                            build + "/artifacts/" + "conversionApp-" + build_num_id + ".tar.gz")
                conversionapp_path_hz = ("https://artifactory-hz1.int.net.nokia.com/artifactory/"
                                         "mnp5g-central-public-remote/System_Release/" + build_release + "/" + build +
                                         "/artifacts/" + "conversionApp-" + build_num_id + ".tar.gz")
                conversionapp_path = conversionapp_path_espoo + " " + conversionapp_path_hz
            else:
                raise Exception("The version is not support yet, please contact "
                                "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com")
        else:
            sw_package_path = knife_package + "/" + build + ".zip"
            onboard_package_path2 = knife_package + "/onBoardingApp.tgz"
            onboard_package_path = knife_package + "/artifacts" + "/onBoardingApp.tgz"
            conversionapp_path = knife_package + "/artifacts" + "/conversionApp-" + build_num_id + ".tar.gz"
            link1_conn_status = self._check_package_link_connection(onboard_package_path)
            link2_conn_status = self._check_package_link_connection(onboard_package_path2)
            if link1_conn_status is True:
                dlo_cmd2 = "sudo -S podman exec toolbox-core aria2c -m 0 -x 4 -s 4 -d %s %s" % (
                    self.host_master_file_path, onboard_package_path)
            elif link2_conn_status is True:
                dlo_cmd2 = "sudo -S podman exec toolbox-core aria2c -m 0 -x 4 -s 4 -d %s %s" % (
                    self.host_master_file_path, onboard_package_path2)
            else:
                raise Exception("onBoardingApp package address can't reach")

        dlp_cmd = "sudo -S podman exec toolbox-core aria2c -m 0 -x 4 -s 4 -d %s %s" % (self.host_master_file_path,
                                                                                       sw_package_path)
        dlo_cmd = "sudo -S podman exec toolbox-core aria2c -m 0 -x 4 -s 4 -d %s %s" % (self.host_master_file_path,
                                                                                       onboard_package_path)
        self.fsm_obj.execute_command_on_enb("sudo rm -rf %s" % self.master_file_path, alias=self.alias)
        time.sleep(2)
        ret_dlp = self.fsm_obj.execute_command_on_enb(dlp_cmd, alias=self.alias)
        time.sleep(2)
        print("===download_sw_package_log===\n: {}".format(ret_dlp))
        try:
            ret_dlo = self.fsm_obj.execute_command_on_enb(dlo_cmd, alias=self.alias)
        except Exception as e:
            print("download onBoardingApp.tgz with below path fail:\n %s" % onboard_package_path)
            print("try second path:\n %s" % onboard_package_path2)
            ret_dlo = self.fsm_obj.execute_command_on_enb(dlo_cmd2, alias=self.alias)
        print("===download_onBoardingApp_log===\n: {}".format(ret_dlo))
        time.sleep(2)
        # unzip package
        unzip_cmd1 = ("sudo -S podman exec toolbox-core unzip -o " + self.host_master_file_path + "/" + build
                      + ".zip" + " -d " + self.host_master_file_path)
        try:
            print("try extracting package")
            extracting_ret = self.fsm_obj.execute_command_on_enb(unzip_cmd1, alias=self.alias)
            print("===extracting_package_log===\n: {}".format(extracting_ret))

            print("try unzip package")
            unzip_ret = self.fsm_obj.execute_command_on_enb(unzip_cmd1, alias=self.alias)
            # check zip file size if need later.
            # check_package_size_cmd = "ls -l %s/%s | awk '{print $5}'" % (self.master_file_path, build + ".zip")
            # print(check_package_size_cmd)
            # package_size_org = self.fsm_obj.execute_command_on_enb(check_package_size_cmd, alias=self.alias)
            # package_size_ret = None
            # while package_size_org != package_size_ret:
            #     package_size_ret = self.fsm_obj.execute_command_on_enb(check_package_size_cmd, alias=self.alias)
            #     package_size_org = package_size_ret
            #     time.sleep(10)
            #     package_size_ret = self.fsm_obj.execute_command_on_enb(check_package_size_cmd, alias=self.alias)
            print("===unzip_package_log===\n: {}".format(unzip_ret))
            print("unzip package completed")
            time.sleep(2)
        except Exception as e:
            print(e)
            print("try unzip package again")
            try:
                self._logout()
                print(self.fsm_obj.enb_store)
                print(self.fsm_obj.enb_store.aliases)
                print("debug1")
                self.login_flag = False
            except Exception as e:
                print(e)
                self.fsm_obj.enb_store.remove(alias=self.alias)
                print(self.fsm_obj.enb_store)
                print(self.fsm_obj.enb_store.aliases)
                print("debug2")
                self.login_flag = False
            time.sleep(5)
            self._login()
            self.fsm_obj.execute_command_on_enb(unzip_cmd1, alias=self.alias)
        unzip_cmd2 = ("sudo -S podman exec toolbox-core tar -xvf " + self.host_master_file_path
                      + "/onBoardingApp.tgz -C " + self.host_master_file_path)
        try:
            self.fsm_obj.execute_command_on_enb(unzip_cmd2, alias=self.alias)
        except Exception as e:
            print(e)
            print("try unzip onBoardingApp.tgz again")
            self._login()
            self.fsm_obj.execute_command_on_enb(unzip_cmd2, alias=self.alias)
        time.sleep(2)
        cmd1 = ("sudo -S podman exec toolbox-core cp -a " + self.host_master_file_path + "/onBoardingApp/. " +
                self.host_master_file_path + "/Image/")
        self.fsm_obj.execute_command_on_enb(cmd1, alias=self.alias)
        if build.lower().count("du"):
            cmd2 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vdu-[0-9]*.tgz -C " + self.host_master_file_path + "/HelmChart'")
            cmd3 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vdu-prerequisite-*.tgz -C " + self.host_master_file_path +
                    "/HelmChart'")
            cmd4 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vdu-cluster-preparation-*.tgz -C " + self.host_master_file_path
                    + "/HelmChart'")
        if build.lower().count("cu"):
            cmd2 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vcu-[0-9]*.tgz -C " + self.host_master_file_path + "/HelmChart'")
            cmd3 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vcu-prerequisite-*.tgz -C " + self.host_master_file_path +
                    "/HelmChart'")
            cmd4 = ("sudo -S podman exec toolbox-core sh -c 'tar -xvf " + self.host_master_file_path +
                    "/HelmChart/aic-vcu-cluster-preparation-*.tgz -C " + self.host_master_file_path
                    + "/HelmChart'")
        self.fsm_obj.execute_command_on_enb(cmd2, alias=self.alias)
        self.fsm_obj.execute_command_on_enb(cmd3, alias=self.alias)
        self.fsm_obj.execute_command_on_enb(cmd4, alias=self.alias)
        cmd5 = ("sudo chown -R core:core %s/" % self.master_file_path)
        self.fsm_obj.execute_command_on_enb(cmd5, alias=self.alias)
        # delete archive file
        cmd6 = ("rm -f %s/%s.zip" % (self.master_file_path, build))
        self.fsm_obj.execute_command_on_enb(cmd6, alias=self.alias)
        cmd7 = ("rm -f %s/onBoardingApp.tgz" % self.master_file_path)
        self.fsm_obj.execute_command_on_enb(cmd7, alias=self.alias)
        return conversionapp_path

    def _undeploy_image(self, namespace, product_type):
        print("===start to undeploy image===")
        self._login()
        if product_type == "vcu":
            undeploy_type = ("helm uninstall %scnf -n %s --timeout 10m --wait" % (product_type, namespace))
        else:
            undeploy_type = ("helm uninstall %s -n %s --timeout 10m --wait" % (product_type, namespace))
        try:
            undeploy_ret1 = self.fsm_obj.execute_command_on_enb(undeploy_type, alias=self.alias)
            print(undeploy_ret1)
        except Exception as e:
            if str(e).count("Release not loaded"):
                print("%s uninstalled already" % product_type)
            else:
                raise Exception(e)
        undeploy_type_pre = ("helm uninstall %s-prerequisite -n %s --timeout 10m --wait" % (product_type, namespace))
        try:
            undeploy_ret2 = self.fsm_obj.execute_command_on_enb(undeploy_type_pre, alias=self.alias)
            print(undeploy_ret2)
        except Exception as e:
            if str(e).count("Release not loaded"):
                print("%s-prerequisite uninstalled already" % product_type)
            else:
                raise Exception(e)
        undeploy_type_cluster = ("helm uninstall %s-cluster-preparation -n %s --timeout 10m --wait" % (product_type,
                                                                                                       namespace))
        try:
            undeploy_ret3 = self.fsm_obj.execute_command_on_enb(undeploy_type_cluster, alias=self.alias)
            print(undeploy_ret3)
        except Exception as e:
            if str(e).count("Release not loaded"):
                print("%s-cluster-preparation uninstalled already" % product_type)
            else:
                raise Exception(e)

    def _load_image(self, tl_folder_name, build, namespace):
        print("===start to load image===")
        self._check_and_patch_pv()
        load_cmd = ("sh /home/core/%s_%s/Image/loadImages.sh -n %s" % (tl_folder_name, build, namespace))
        print("Load image will take a long time to finish, don't cancel this procedure...")
        load_ret = self.fsm_obj.execute_command_on_enb(load_cmd, alias=self.alias)
        print("Load image result:\n {}".format(load_ret))
        build_num_id = build.split("_")[-1]
        # comment below image checking due to some testline spend too long time to list the image.
        # self._check_image(namespace, build_num_id)

    def _check_image(self, namespace, build_num_id):
        print("===start to check image===")
        check_cmd = ("podman image list| grep %s| grep %s" % (namespace, build_num_id))
        check_ret = self.fsm_obj.execute_command_on_enb(check_cmd, alias=self.alias)
        print(check_ret)

    def _check_knife_pod_and_docker_file_dir(self, data):
        """find knife pod from outside json/yaml file"""
        pass

    def _check_knife_image_exist(self, pod_name, build, namespace):
        self._login()
        # pod_name = self._check_knife_pod_and_docker_file_dir(data)
        build_id_num = build.split("_")[-1]
        check_cmd = ("podman image list |grep '%s/%s.*%s-knife'|awk '{print $2}'" % (namespace, pod_name,
                                                                                     build_id_num))
        check_ret = self.fsm_obj.execute_command_on_enb(check_cmd, return_rc=True, alias=self.alias)
        knife_id = 0
        print(check_ret[0])
        if len(check_ret[0].split()) > 0:
            knife_id += len(check_ret[0].split())
        return knife_id

    def _build_knife_action(self, pod_name, docker_file_folder_name, pod_image_name, build, namespace):
        cmd8 = ("podman login image-registry.openshift-image-registry.svc:5000 -u nokiaadmin -p $(oc whoami -t)")
        try:
            cmd8_ret = self.fsm_obj.execute_command_on_enb(cmd8, alias=self.alias)
            print(cmd8_ret)
        except Exception as e:
            print("login fail will impact image deployment")
            print(e)
        knife_id = self._check_knife_image_exist(pod_name, build, namespace)
        docker_file_path = ("%s/%s/Dockerfile" % (self.master_file_path, docker_file_folder_name))
        docker_file_f_path = self.master_file_path + "/" + docker_file_folder_name
        # 0.300.8664 , 0.250.7996
        build_id_num = build.split("_")[-1]
        build_cmd = ("cd %s; podman build -f %s -t %s/%s:%s-knife%s ." % (docker_file_f_path, docker_file_path,
                                                                          pod_image_name, pod_name, build_id_num,
                                                                          knife_id))
        # print(build_cmd)
        build_ret = self.fsm_obj.execute_command_on_enb(build_cmd, alias=self.alias)
        print(build_ret)
        push_cmd = ("podman push %s/%s:%s-knife%s" % (pod_image_name, pod_name, build_id_num, knife_id))
        # print(push_cmd)
        time.sleep(2)
        push_ret = self.fsm_obj.execute_command_on_enb(push_cmd, alias=self.alias)
        print(push_ret)
        return knife_id

    def _build_docker_knife(self, knife_data, namespace, build):
        """search the pod image name like as: podman image list |grep cprt|awk '{print $1}'
           >>pod_image_name: image-registry.openshift-image-registry.svc:5000/7-7-ute5gcloudt7sk030/cprt
        """
        self._login()
        image_prefix = "image-registry.openshift-image-registry.svc:5000"
        pod_image_name = image_prefix + "/" + namespace
        build_id_num = build.split("_")[-1]
        for i in knife_data["nodes"][0]["files"]:
            k_file_path = i["file_path"]
            # get folder name from file_path: "HZ_aic_test/vdu/dockerfile-cprt-trace"
            k_file_folder_name = k_file_path.split("/")[-1]
            k_pod_name_list = i["metadata"]["pod_names"]
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, k_file_path, self.host_ssh_usr,
                                                                    self.host_ssh, self.master_file_path))
            if len(k_pod_name_list) == 1:
                # no need search, all image prefix is same
                # search_cmd = ("podman image list |grep %s|awk '{print $1}'" % k_pod_name_list[0])
                sed_cmd = ("sed -i '1i From %s/%s:%s\n\n' %s/%s/Dockerfile" % (pod_image_name, k_pod_name_list[0],
                                                                               build_id_num, self.master_file_path,
                                                                               k_file_folder_name))
                self.fsm_obj.execute_command_on_enb(sed_cmd, alias=self.alias)
                knife_id = self._build_knife_action(pod_name=k_pod_name_list[0],
                                                    docker_file_folder_name=k_file_folder_name,
                                                    pod_image_name=pod_image_name,
                                                    build=build, namespace=namespace)
                if build.lower().count("du"):
                    self._modify_values_yaml(values_yaml_folder="aic-vdu", pod_name=k_pod_name_list[0],
                                             knife_id=knife_id, build_id_num=build_id_num)
                if build.lower().count("cu"):
                    self._modify_values_yaml(values_yaml_folder="aic-vcu", pod_name=k_pod_name_list[0],
                                             knife_id=knife_id, build_id_num=build_id_num)
            if len(k_pod_name_list) > 1:
                for pod in k_pod_name_list:
                    sed_cmd = ("sed -i '1i From %s/%s:%s\n' %s/%s/Dockerfile" % (pod_image_name, pod,
                                                                                 build_id_num, self.master_file_path,
                                                                                 k_file_folder_name))
                    if k_pod_name_list.index(pod) == 0:
                        self.fsm_obj.execute_command_on_enb(sed_cmd, alias=self.alias)
                    else:
                        sed_cmd_del_1st_line = ("sed -i '1d' %s/%s/Dockerfile" % (self.master_file_path,
                                                                                  k_file_folder_name))
                        self.fsm_obj.execute_command_on_enb(sed_cmd_del_1st_line, alias=self.alias)
                        sed_cmd2 = ("sed -i '1i From %s/%s:%s\n' %s/%s/Dockerfile" % (pod_image_name, pod,
                                                                                      build_id_num,
                                                                                      self.master_file_path,
                                                                                      k_file_folder_name))
                        self.fsm_obj.execute_command_on_enb(sed_cmd2, alias=self.alias)
                    knife_id = self._build_knife_action(pod_name=pod, docker_file_folder_name=k_file_folder_name,
                                                        pod_image_name=pod_image_name, build=build,
                                                        namespace=namespace)
                    if build.lower().count("du"):
                        self._modify_values_yaml(values_yaml_folder="aic-vdu", pod_name=pod, knife_id=knife_id,
                                                 build_id_num=build_id_num)
                    if build.lower().count("cu"):
                        self._modify_values_yaml(values_yaml_folder="aic-vcu", pod_name=pod, knife_id=knife_id,
                                                 build_id_num=build_id_num)
            if len(k_pod_name_list) == 0:
                raise Exception("No pod_names found in %s" % i)

    def _build_cprt_default_knife(self, namespace, cprt_default_knife_path, build):
        self._login()
        image_prefix = "image-registry.openshift-image-registry.svc:5000"
        pod_image_name = image_prefix + "/" + namespace
        build_id_num = build.split("_")[-1]
        self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, cprt_default_knife_path,
                                                                self.host_ssh_usr, self.host_ssh,
                                                                self.master_file_path))
        sed_cmd = ("sed -i '1i From %s/%s:%s\n\n' %s/%s/Dockerfile" % (pod_image_name, "cprt", build_id_num,
                                                                       self.master_file_path, "dockerfile-cprt"))
        self.fsm_obj.execute_command_on_enb(sed_cmd, alias=self.alias)
        knife_id = self._build_knife_action(pod_name="cprt", docker_file_folder_name="dockerfile-cprt",
                                            pod_image_name=pod_image_name, build=build, namespace=namespace)
        self._modify_values_yaml(values_yaml_folder="aic-vdu", pod_name="cprt", knife_id=knife_id,
                                 build_id_num=build_id_num)

    def _modify_values_yaml(self, values_yaml_folder, pod_name, knife_id, build_id_num):
        values_yaml_path = self.master_file_path + "/HelmChart/" + values_yaml_folder + "/values.yaml"
        # need change values.yaml with knife tag, can't use yaml due to format will be changed
        # download from master server
        self._execute_cmd("sshpass -p %s scp %s@%s:%s ./" % (self.host_ssh_pwd, self.host_ssh_usr, self.host_ssh,
                                                             values_yaml_path))
        time.sleep(2)
        with open("values.yaml", "r", encoding="utf-8") as r_file:
            # data = yaml.safe_load(r_file.read())
            data = r_file.read()
        r_file.close()
        #     cprt:
        #       repository: cprt
        #       tag: "0.300.8586-dev"
        if re.search(re.compile(
                r'.*((%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: ")(.*))"\n' % (pod_name, pod_name, pod_name),
                flags=re.M | re.I), data):
            sub1 = re.search(
                re.compile(r'.*(%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name, pod_name),
                           flags=re.M | re.I), data).group(1)
            sub2 = re.search(re.compile(
                r'.*((%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: ")(.*))"\n' % (pod_name, pod_name, pod_name),
                flags=re.M | re.I), data).group(2)
            sub4 = re.search(re.compile(
                r'.*((%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: ")(.*))"\n' % (pod_name, pod_name, pod_name),
                flags=re.M | re.I), data).group(4)
        print(sub1)
        # if re.search(re.compile(r'.*(%s:\n\s{6}repository: %s\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name),
        # flags=re.M), data):
        #     sub1 = re.search(re.compile(r'.*(%s:\n\s{6}repository: %s\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name),
        #                                 flags=re.M), data).group(1)
        #     sub2 = re.search(re.compile(r'.*(%s:\n\s{6}repository: %s\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name),
        #                                 flags=re.M), data).group(2)
        # new_data = re.sub(sub1, repl=(sub1 + "-knife%s" % knife_id), string=data)
        # print(re.search(re.compile(r'.*%s:\n\s{6}repository: %s\n\s{6}tag: "(.*)"\n' % (pod_name, pod_name),
        #                            flags=re.M), new_data).group(1))
        if re.match(re.compile(r'.*-knife.*', flags=re.M | re.I), sub4):
            new_data = re.sub(sub1, repl=(sub2 + "%s-knife%s" % (build_id_num, knife_id)), string=data)
        else:
            new_data = re.sub(sub1, repl=(sub1 + "-knife%s" % knife_id), string=data)
        print(re.search(
            re.compile(r'.*(%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name, pod_name),
                       flags=re.M | re.I), new_data).group(1))
        print(re.search(
            re.compile(r'.*(%s:\n\s{6}repository: ("%s"|%s)\n\s{6}tag: "(.*))"\n' % (pod_name, pod_name, pod_name),
                       flags=re.M | re.I), new_data).group(2))
        # override values.yaml
        with open("values.yaml", "w", encoding="utf-8") as w_file:
            w_file.write(new_data)
        w_file.close()
        time.sleep(1)
        # push new values.yaml to master server
        self._execute_cmd("sshpass -p %s scp %s %s@%s:%s" % (self.host_ssh_pwd, "values.yaml", self.host_ssh_usr,
                                                             self.host_ssh, values_yaml_path))

    def _put_deployment_to_master_vdu(self, yaml_file, yaml_file_common, deployment_file_path_new):
        yaml_file_new, yaml_file_common_new = self._migrate_deployment_file_vdu(yaml_file, yaml_file_common,
                                                                                deployment_file_path_new)
        # testline specific yaml file
        self.vdu_cluster_path_in_master = (
                self.master_file_path + "/HelmChart/aic-vdu-cluster-preparation/vdu-cluster-preparation.yaml")
        self.vdu_pre_path_in_master = self.master_file_path + "/HelmChart/aic-vdu-prerequisite/vdu-prerequisite.yaml"
        self.vdu_path_in_master = self.master_file_path + "/HelmChart/aic-vdu/vdu-cnf.yaml"

        # common yaml file
        self.vdu_cluster_common_path_in_master = (
                self.master_file_path + "/HelmChart/aic-vdu-cluster-preparation/vdu-cluster-preparation-common.yaml")
        self.vdu_pre_common_path_in_master = self.master_file_path + \
            "/HelmChart/aic-vdu-prerequisite/vdu-prerequisite-common.yaml"
        self.vdu_path_common_in_master = self.master_file_path + "/HelmChart/aic-vdu/vdu-cnf-common.yaml"

        # vdu-cluster-preparation-new and vdu-cluster-preparation-common-new
        if os.path.isfile(yaml_file_new) and yaml_file_new.lower().count("vdu-cluster-preparation-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vdu_cluster_path_in_master))
        if os.path.isfile(yaml_file_common_new) and yaml_file_common_new.lower().count(
                "vdu-cluster-preparation-common-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vdu_cluster_common_path_in_master))
        # vdu-prerequisite-new and vdu-prerequisite-common-new
        # need distinguish vdu-prerequisite-new.yaml/vdu-prerequisite-1-new.yaml/vdu-cnf-2-prerequisite.yaml ..
        if os.path.isfile(yaml_file_new) and re.search(re.compile(r"vdu-prerequisite(.*)-new", flags=re.I),
                                                       yaml_file_new.lower()):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vdu_pre_path_in_master))
        if os.path.isfile(yaml_file_common_new) and yaml_file_common_new.lower().count(
                "vdu-prerequisite-common-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vdu_pre_common_path_in_master))
        # vdu-cnf-new and vdu-cnf-common-new
        # need distinguish vdu-cnf-new.yaml/vdu-cnf-1-new.yaml/vdu-cnf-2-new.yaml ..
        if os.path.isfile(yaml_file_new) and re.search(re.compile(r"vdu-cnf(.*)-new", flags=re.I),
                                                       yaml_file_new.lower()):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vdu_path_in_master))
        if os.path.isfile(yaml_file_common_new) and re.search(re.compile(r"vdu-cnf-common(.*)-new", flags=re.I),
                                                              yaml_file_common_new.lower()):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vdu_path_common_in_master))

    def _put_deployment_to_master_vcu(self, yaml_file, yaml_file_common, deployment_file_path_new):
        yaml_file_new, yaml_file_common_new = self._migrate_deployment_file_vcu(yaml_file, yaml_file_common,
                                                                                deployment_file_path_new)
        # testline specific yaml file
        self.vcu_cluster_path_in_master = (
                self.master_file_path + "/HelmChart/aic-vcu-cluster-preparation/vcu-cluster-preparation.yaml")
        self.vcu_pre_path_in_master = self.master_file_path + "/HelmChart/aic-vcu-prerequisite/vcu-prerequisite.yaml"
        self.vcu_path_in_master = self.master_file_path + "/HelmChart/aic-vcu/vcu-cnf.yaml"

        # common yaml file
        self.vcu_cluster_common_path_in_master = (
                self.master_file_path + "/HelmChart/aic-vcu-cluster-preparation/vcu-cluster-preparation-common.yaml")
        self.vcu_pre_common_path_in_master = self.master_file_path + \
            "/HelmChart/aic-vcu-prerequisite/vcu-prerequisite-common.yaml"
        self.vcu_path_common_in_master = self.master_file_path + "/HelmChart/aic-vcu/vcu-cnf-common.yaml"

        # vcu-cluster-preparation-new and vcu-cluster-preparation-common-new
        if os.path.isfile(yaml_file_new) and yaml_file_new.lower().count("vcu-cluster-preparation-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vcu_cluster_path_in_master))
        if os.path.isfile(yaml_file_common_new) and yaml_file_common_new.lower().count(
                "vcu-cluster-preparation-common-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vcu_cluster_common_path_in_master))
        # vcu-prerequisite-new and vcu-prerequisite-common-new
        if os.path.isfile(yaml_file_new) and yaml_file_new.lower().count("vcu-prerequisite-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vcu_pre_path_in_master))
        if os.path.isfile(yaml_file_common_new) and yaml_file_common_new.lower().count(
                "vcu-prerequisite-common-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vcu_pre_common_path_in_master))
        # vcu-cnf-new and vcu-cnf-common-new
        if os.path.isfile(yaml_file_new) and yaml_file_new.lower().count("vcu-cnf-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_new, self.host_ssh_usr,
                                                                    self.host_ssh, self.vcu_path_in_master))
        if os.path.isfile(yaml_file_common_new) and yaml_file_common_new.lower().count("vcu-cnf-common-new"):
            self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, yaml_file_common_new,
                                                                    self.host_ssh_usr, self.host_ssh,
                                                                    self.vcu_path_common_in_master))

    def _migrate_deployment_file_vdu(self, yaml_file, yaml_file_common, deployment_file_path_new):
        # f_cluster and f_pre path is same as f_cnf, so use f_cnf as baseline path
        print("===start to migrate deployment vdu file===")
        yaml_file_new = deployment_file_path_new + yaml_file.split('/')[-1].split('.yaml')[0] + "-new.yaml"
        yaml_file_common_new = deployment_file_path_new + yaml_file_common.split('/')[-1].split('.yaml')[
            0] + "-new.yaml"
        if not (os.path.isfile(yaml_file) or os.path.isfile(yaml_file_common)):
            raise Exception("\033[1;31;47mNo specific and common deployment file found\033[0m")
        else:
            if os.path.isfile(yaml_file):
                print(yaml_file_new)
                self._execute_cmd("cp %s %s" % (yaml_file, yaml_file_new))
                time.sleep(1)
                self._conversion_yaml_file_vdu(deployment_file_path_new, yaml_file_new)
            else:
                print("\033[1;35;47m<Info:> This topo not use %s \033[0m\n" % yaml_file.split("/")[-1])
            if os.path.isfile(yaml_file_common):
                print(yaml_file_common_new)
                self._execute_cmd("cp %s %s" % (yaml_file_common, yaml_file_common_new))
                time.sleep(1)
                self._conversion_yaml_file_vdu(deployment_file_path_new, yaml_file_common_new)
            else:
                print("\033[1;35;47m<Info:> This topo not use %s \033[0m\n" % yaml_file_common.split("/")[-1])
        return yaml_file_new, yaml_file_common_new

    def _conversion_yaml_file_vdu(self, conversionapp_path_tl, yaml_file):
        # f_cluster_new
        if yaml_file.lower().count("vdu-cluster-preparation"):
            conversion_cmd1 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vdu-cluster-preparation.tpl"
                               " -o %s" % (yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd1))
        # f_pre_new
        if yaml_file.lower().count("vdu-prerequisite"):
            conversion_cmd2 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vdu-prerequisite.tpl"
                               " -o %s" % (yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd2))
        # f_cnf_new
        if yaml_file.lower().count("vdu-cnf"):
            conversion_cmd3 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vdu.tpl -o %s" % (
                yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd3))
            # here check vdu-cnf-new.yaml/vdu-cnf-1-new.yaml/vdu-cnf-2-new.yaml.. due to org file renamed
            if re.search(re.compile(r"vdu-cnf(.*)-new", flags=re.I), yaml_file.lower()):
                time.sleep(1)
                self._add_imagePullSecret_in_vdu_cnf(yaml_file)
        time.sleep(1)

    def _add_imagePullSecret_in_vdu_cnf(self, f_cnf_new):
        #  [IFC20230204][Notification][vDU][CNI93660]: move CR (Custom resource) from aic-vdu-prerequisite to aic-vdu
        imagePullSecret_name = self._fetch_imagePullSecret_name_aic()
        with open(f_cnf_new, "r") as f_cnf_file:
            cnf_data = yaml.safe_load(f_cnf_file)
        if "image" in cnf_data["global"]:
            cnf_data["global"]["image"]["imagePullSecret"] = imagePullSecret_name
        else:
            cnf_data["global"]["image"] = {}
            cnf_data["global"]["image"]["imagePullSecret"] = imagePullSecret_name
        print(cnf_data["global"]["image"])
        with open(f_cnf_new, "w") as f_cnf_file_new:
            yaml.dump(cnf_data, f_cnf_file_new)
        time.sleep(2)

    def _fetch_imagePullSecret_name_aic(self):
        self._login()
        fetch_imagePullSecret_cmd = "kubectl get secrets -n %s|grep -i default-docker|awk {'print $1'}" % self.vdu_ns
        imagePullSecret_name = self.fsm_obj.execute_command_on_enb(fetch_imagePullSecret_cmd, alias=self.alias)
        time.sleep(1)
        return imagePullSecret_name

    def _change_internale1_to_internalE1_vcu(self, vcu_yaml_file_path):
        # due to deployment file in testline is e1 but not E1.
        with open(vcu_yaml_file_path, "r") as f_cnf_file:
            cnf_data = yaml.safe_load(f_cnf_file)
        if "global" in cnf_data:
            if "internale1Network" in cnf_data["global"]:
                if "internale1" in cnf_data["global"]["internale1Network"]:
                    cnf_data["global"]["internalE1Network"] = {}
                    cnf_data["global"]["internalE1Network"]["internalE1"] = cnf_data["global"]["internale1Network"][
                        "internale1"]
                    del cnf_data["global"]["internale1Network"]
            if "internalE1Network" in cnf_data["global"]:
                if "internale1" in cnf_data["global"]["internalE1Network"]:
                    cnf_data["global"]["internalE1Network"] = {}
                    cnf_data["global"]["internalE1Network"]["internalE1"] = cnf_data["global"]["internale1Network"][
                        "internale1"]
                    del cnf_data["global"]["internalE1Network"]["internale1"]

        with open(vcu_yaml_file_path, "w") as f_cnf_file_new:
            yaml.dump(cnf_data, f_cnf_file_new)

    def _migrate_deployment_file_vcu(self, yaml_file, yaml_file_common, deployment_file_path_new):
        # f_cluster and f_pre path is same as f_cnf, so use f_cnf as baseline path
        print("===start to migrate deployment vcu file===")
        yaml_file_new = deployment_file_path_new + yaml_file.split('/')[-1].split('.yaml')[0] + "-new.yaml"
        yaml_file_common_new = deployment_file_path_new + yaml_file_common.split('/')[-1].split('.yaml')[
            0] + "-new.yaml"
        if not (os.path.isfile(yaml_file) or os.path.isfile(yaml_file_common)):
            raise Exception("\033[1;31;47mNo specific and common deployment file found\033[0m")
        else:
            if os.path.isfile(yaml_file):
                print(yaml_file_new)
                self._execute_cmd("cp %s %s" % (yaml_file, yaml_file_new))
                time.sleep(1)
                self._change_internale1_to_internalE1_vcu(yaml_file_new)
                self._conversion_yaml_file_vcu(deployment_file_path_new, yaml_file_new)
            else:
                print("\033[1;35;47m<Info:> This topo not use %s \033[0m\n" % yaml_file.split("/")[-1])
            if os.path.isfile(yaml_file_common):
                print(yaml_file_common_new)
                self._execute_cmd("cp %s %s" % (yaml_file_common, yaml_file_common_new))
                time.sleep(1)
                self._change_internale1_to_internalE1_vcu(yaml_file_common_new)
                self._conversion_yaml_file_vcu(deployment_file_path_new, yaml_file_common_new)
            else:
                print("\033[1;35;47m<Info:> This topo not use %s \033[0m\n" % yaml_file_common.split("/")[-1])
        return yaml_file_new, yaml_file_common_new

    def _conversion_yaml_file_vcu(self, conversionapp_path_tl, yaml_file):
        # f_cluster_new
        if yaml_file.lower().count("vcu-cluster-preparation"):
            conversion_cmd1 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vcu-cluster-preparation.tpl"
                               " -o %s" % (yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd1))
        # f_pre_new
        if yaml_file.lower().count("vcu-prerequisite"):
            conversion_cmd2 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vcu-prerequisite.tpl"
                               " -o %s" % (yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd2))
        # f_cnf_new
        if yaml_file.lower().count("vcu-cnf"):
            conversion_cmd3 = ("./cnf_userinput_conversion -p %s -t values-override.aic-vcu.tpl -o %s" % (
                yaml_file, yaml_file))
            self._execute_cmd("cd %s&&%s" % (conversionapp_path_tl + "conversionApp", conversion_cmd3))
        time.sleep(1)

    def _download_conversionapp(self, yaml_file, conversionapp_path):
        if yaml_file.lower().count("vcu"):
            deployment_file_path_new = '/'.join(re.split(r"/vcu-.*.yaml", yaml_file))
        elif yaml_file.lower().count("vdu"):
            deployment_file_path_new = '/'.join(re.split(r"/vdu-.*.yaml", yaml_file))
        else:
            raise Exception("yaml_file:%s is neither belong to vcu nor to vdu" % yaml_file)
        self._execute_cmd("rm -rf %s" % (deployment_file_path_new + "conversionApp*"))
        self._execute_cmd("wget %s -P %s" % (conversionapp_path, deployment_file_path_new))
        time.sleep(5)
        self._execute_cmd("tar xzf %s -C %s" % (deployment_file_path_new + "conversionApp*.tar.gz",
                                                deployment_file_path_new))
        time.sleep(2)
        self._execute_cmd("tar xzf %s -C %s" % (deployment_file_path_new + "conversionApp/cnf_userinput*tar*",
                                                deployment_file_path_new + "conversionApp"))
        time.sleep(2)
        return deployment_file_path_new

    def _install_aic(self, namespace, f_cluster, f_pre, f_cnf, build, conversionapp_path, f_cluster_common,
                     f_pre_common, f_cnf_common, yml_file_path_list_variant):
        self._login()
        deployment_file_path_new = self._download_conversionapp(f_cnf, conversionapp_path)
        if build.lower().count("du"):
            # self._put_deployment_to_master_vdu(f_cluster, f_pre, f_cnf, conversionapp_path)
            self._install_vdu_cluster(namespace, f_cluster, f_cluster_common, deployment_file_path_new)
            self._install_vdu_pre(namespace, f_pre, f_pre_common, deployment_file_path_new)
            self._install_vdu_cnf(namespace, f_cnf, f_cnf_common, deployment_file_path_new, yml_file_path_list_variant)
        if build.lower().count("cu"):
            # self._put_deployment_to_master_vcu(f_cluster, f_pre, f_cnf, conversionapp_path)
            self._install_vcu_cluster(namespace, f_cluster, f_cluster_common, deployment_file_path_new)
            self._install_vcu_pre(namespace, f_pre, f_pre_common, deployment_file_path_new)
            self._install_vcu_cnf(namespace, f_cnf, f_cnf_common, deployment_file_path_new, yml_file_path_list_variant)

    def _install_vdu_cluster(self, namespace, f_cluster, f_cluster_common, deployment_file_path_new):
        self._put_deployment_to_master_vdu(f_cluster, f_cluster_common, deployment_file_path_new)
        if os.path.isfile(f_cluster) and os.path.isfile(f_cluster_common):
            install_cmd1 = ("cd %s/HelmChart/aic-vdu-cluster-preparation/ && helm install vdu-cluster-preparation . "
                            "-f values-override.yaml -f vdu-cluster-preparation-common.yaml "
                            "-f vdu-cluster-preparation.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_cluster_common):
            install_cmd1 = ("cd %s/HelmChart/aic-vdu-cluster-preparation/ && helm install vdu-cluster-preparation . "
                            "-f values-override.yaml -f vdu-cluster-preparation-common.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_cluster):
            install_cmd1 = ("cd %s/HelmChart/aic-vdu-cluster-preparation/ && helm install vdu-cluster-preparation . "
                            "-f values-override.yaml -f vdu-cluster-preparation.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        install_ret1 = self.fsm_obj.execute_command_on_enb(install_cmd1, alias=self.alias)
        print(install_ret1)

    def _install_vdu_pre(self, namespace, f_pre, f_pre_common, deployment_file_path_new):
        self._put_deployment_to_master_vdu(f_pre, f_pre_common, deployment_file_path_new)
        if os.path.isfile(f_pre) and os.path.isfile(f_pre_common):
            install_cmd2 = ("cd %s/HelmChart/aic-vdu-prerequisite/ && helm install vdu-prerequisite . "
                            "-f values-override.yaml -f vdu-prerequisite-common.yaml -f vdu-prerequisite.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_pre_common):
            install_cmd2 = ("cd %s/HelmChart/aic-vdu-prerequisite/ && helm install vdu-prerequisite . "
                            "-f values-override.yaml -f vdu-prerequisite-common.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_pre):
            install_cmd2 = ("cd %s/HelmChart/aic-vdu-prerequisite/ && helm install vdu-prerequisite . "
                            "-f values-override.yaml -f vdu-prerequisite.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        install_ret2 = self.fsm_obj.execute_command_on_enb(install_cmd2, alias=self.alias)
        print(install_ret2)

    def _install_vdu_cnf(self, namespace, f_cnf, f_cnf_common, deployment_file_path_new, yml_file_path_list_variant):
        self._put_deployment_to_master_vdu(f_cnf, f_cnf_common, deployment_file_path_new)
        # put variant yaml to master vdu and will involve variant yaml to deploy
        var_file_cmd_for_deploy_arg = ""
        if yml_file_path_list_variant is not None:
            for var_file_path in yml_file_path_list_variant:
                var_file = var_file_path.split("/")[-1]
                vdu_variant_path_in_master = self.master_file_path + "/HelmChart/aic-vdu/%s" % var_file
                self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, var_file_path,
                                                                        self.host_ssh_usr, self.host_ssh,
                                                                        vdu_variant_path_in_master))
                var_file_cmd_for_deploy_arg += "-f %s " % var_file
        if os.path.isfile(f_cnf) and os.path.isfile(f_cnf_common):
            install_cmd3 = ("cd %s/HelmChart/aic-vdu/ && helm install vdu . "
                            "-f values-override.yaml -f vdu-cnf-common.yaml -f vdu-cnf.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        elif os.path.isfile(f_cnf_common):
            install_cmd3 = ("cd %s/HelmChart/aic-vdu/ && helm install vdu . "
                            "-f values-override.yaml -f vdu-cnf-common.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        elif os.path.isfile(f_cnf):
            install_cmd3 = ("cd %s/HelmChart/aic-vdu/ && helm install vdu . "
                            "-f values-override.yaml -f vdu-cnf.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        install_ret3 = self.fsm_obj.execute_command_on_enb(install_cmd3, alias=self.alias)
        print(install_ret3)

    def _install_vcu_cluster(self, namespace, f_cluster, f_cluster_common, deployment_file_path_new):
        self._put_deployment_to_master_vcu(f_cluster, f_cluster_common, deployment_file_path_new)
        if os.path.isfile(f_cluster) and os.path.isfile(f_cluster_common):
            install_cmd1 = ("cd %s/HelmChart/aic-vcu-cluster-preparation/ && helm install vcu-cluster-preparation . "
                            "-f values-override.yaml -f vcu-cluster-preparation-common.yaml "
                            "-f vcu-cluster-preparation.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_cluster_common):
            install_cmd1 = ("cd %s/HelmChart/aic-vcu-cluster-preparation/ && helm install vcu-cluster-preparation . "
                            "-f values-override.yaml -f vcu-cluster-preparation-common.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_cluster):
            install_cmd1 = ("cd %s/HelmChart/aic-vcu-cluster-preparation/ && helm install vcu-cluster-preparation . "
                            "-f values-override.yaml -f vcu-cluster-preparation.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        install_ret1 = self.fsm_obj.execute_command_on_enb(install_cmd1, alias=self.alias)
        print(install_ret1)

    def _install_vcu_pre(self, namespace, f_pre, f_pre_common, deployment_file_path_new):
        self._put_deployment_to_master_vcu(f_pre, f_pre_common, deployment_file_path_new)
        if os.path.isfile(f_pre) and os.path.isfile(f_pre_common):
            install_cmd2 = ("cd %s/HelmChart/aic-vcu-prerequisite/ && helm install vcu-prerequisite . "
                            "-f values-override.yaml -f vcu-prerequisite-common.yaml -f vcu-prerequisite.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_pre_common):
            install_cmd2 = ("cd %s/HelmChart/aic-vcu-prerequisite/ && helm install vcu-prerequisite . "
                            "-f values-override.yaml -f vcu-prerequisite-common.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        elif os.path.isfile(f_pre):
            install_cmd2 = ("cd %s/HelmChart/aic-vcu-prerequisite/ && helm install vcu-prerequisite . "
                            "-f values-override.yaml -f vcu-prerequisite.yaml -n %s "
                            "--timeout 25m" % (self.master_file_path, namespace))
        install_ret2 = self.fsm_obj.execute_command_on_enb(install_cmd2, alias=self.alias)
        print(install_ret2)

    def _install_vcu_cnf(self, namespace, f_cnf, f_cnf_common, deployment_file_path_new, yml_file_path_list_variant):
        self._put_deployment_to_master_vcu(f_cnf, f_cnf_common, deployment_file_path_new)
        # put variant yaml to master vcu and will involve variant yaml to deploy
        var_file_cmd_for_deploy_arg = ""
        if yml_file_path_list_variant is not None:
            for var_file_path in yml_file_path_list_variant:
                var_file = var_file_path.split("/")[-1]
                vcu_variant_path_in_master = self.master_file_path + "/HelmChart/aic-vcu/%s" % var_file
                self._execute_cmd("sshpass -p %s scp -r %s %s@%s:%s" % (self.host_ssh_pwd, var_file_path,
                                                                        self.host_ssh_usr, self.host_ssh,
                                                                        vcu_variant_path_in_master))
                var_file_cmd_for_deploy_arg += "-f %s " % var_file
        if os.path.isfile(f_cnf) and os.path.isfile(f_cnf_common):
            install_cmd3 = ("cd %s/HelmChart/aic-vcu/ && helm install vcucnf . "
                            "-f values-override.yaml -f vcu-cnf-common.yaml -f vcu-cnf.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        elif os.path.isfile(f_cnf_common):
            install_cmd3 = ("cd %s/HelmChart/aic-vcu/ && helm install vcucnf . "
                            "-f values-override.yaml -f vcu-cnf-common.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        elif os.path.isfile(f_cnf):
            install_cmd3 = ("cd %s/HelmChart/aic-vcu/ && helm install vcucnf . "
                            "-f values-override.yaml -f vcu-cnf.yaml %s -n %s "
                            "--timeout 25m" % (self.master_file_path, var_file_cmd_for_deploy_arg, namespace))
        install_ret3 = self.fsm_obj.execute_command_on_enb(install_cmd3, alias=self.alias)
        print(install_ret3)

    def _check_install_status(self):
        self._login()
        install_check_cmd = ("helm list -n 7-7-ute5gcloudt7sk030 && kubectl get pod -n 7-7-ute5gcloudt7sk030")
        check_ret = self.fsm_obj.execute_command_on_enb(install_check_cmd, alias=self.alias)
        print(check_ret)

    def _get_yaml_config(self, yaml_file_path):
        with open(yaml_file_path, "r") as y_file:
            y_data = yaml.safe_load(y_file.read())
        y_file.close()
        pprint.pprint(y_data)
        return y_data

    def _get_aic_knife_yaml(self, yaml_file_path):
        knife_data = self._get_yaml_config(yaml_file_path)
        return knife_data

    def _get_aic_version(self):
        pass

    def _execute_cmd(self, cmd):
        out = os.popen(cmd).readlines()
        return "".join(out).strip()

    def _check_deployment_file_exist(self, yaml_file_path):
        if not os.path.exists(yaml_file_path):
            print("\033[1;35;47m<Info:> This topo not use %s \033[0m\n" % yaml_file_path.split("/")[-1])
            # raise Exception("%s deployment file not found !" % yaml_file_path)
        return yaml_file_path

    def _fecth_aic_info_from_init(self, init_file, type):
        """type: 'vcu/vdu/vdu1/vdu2'"""
        with open(init_file, "r") as f:
            # remove comment lines..
            file_content = f.readlines()
            lines = [line for line in file_content if not line.strip().startswith('#')]
            yaml_content = ''.join(lines)
            # replace tab key to spaces..
            file_content_with_spaces = yaml_content.replace("\t", "    ")
            yf = yaml.safe_load(file_content_with_spaces)
        f.close()
        init_list = yf.split("\n")
        vdu_info = {}
        for i in init_list:
            if re.match(re.compile(r'.*%s_k8s_ssh_connection_details.*=.*SshServiceDetails.*' % type, flags=re.I), i):
                # print(i.strip().split("(")[-1].strip().split(")")[0])
                new_str = i.strip().split("(")[-1].strip().split(")")[0]
                # print(new_str.split(","))
                for j in new_str.split(","):
                    if j.strip().split("=")[1].strip().count('"') == 0 and j.strip().split("=")[1].strip().count(
                            "'") == 0:
                        vdu_info[j.strip().split("=")[0].strip()] = j.strip().split("=")[1].strip().split('\"')[0]
                    else:
                        vdu_info[j.strip().split("=")[0].strip()] = j.strip().split("=")[1].strip().split('\"')[1]
            if re.match(re.compile(r'.*%s_k8s.*namespace="(.*?)".*' % type, flags=re.I), i):
                # print(re.match(re.compile(r'.*%s_k8s.*namespace="(.*?)".*' % vdu_id, flags=re.I), i).group(1))
                vdu_info["ns"] = re.match(re.compile(r'.*%s_k8s.*namespace="(.*?)".*' % type, flags=re.I), i).group(1)
        if "addr" in vdu_info.keys():
            return vdu_info["addr"], vdu_info["username"], vdu_info["password"], vdu_info["ns"]
        if "ip_addr" in vdu_info.keys():
            return vdu_info["ip_addr"], vdu_info["username"], vdu_info["password"], vdu_info["ns"]

    def _get_variant_yaml_file(self, config_yaml_path, target_dir, host_name, variant, topology_configs_dir, tl_type,
                               topo_build_release, productVariant):
        with open(config_yaml_path, "r") as y_file:
            y_data = yaml.safe_load(y_file.read())
        y_file.close()
        need_file_path_list = []
        yml_file_path_list_common = []
        yml_file_path_list_variant_cu = []
        yml_file_path_list_variant_du = []
        for var in y_data["variants"]:
            if var["name"] == variant:
                print(var)
                need_file_path_list.append(var["nodes"][0]["files"])
        if len(need_file_path_list) != 1:
            raise Exception("variants not unique %s" % need_file_path_list)
        else:
            for yml_file in need_file_path_list[0]:
                if yml_file["file_type"] == "common_helm_values":
                    yml_file_path_list_common.append(yml_file["file_path"])
                if yml_file["file_type"] == "helm_values" and yml_file["hw_type"].lower() == "cu":
                    yml_file_path_list_variant_cu.append(yml_file["file_path"])
                if yml_file["file_type"] == "helm_values" and yml_file["hw_type"].lower() == "du":
                    yml_file_path_list_variant_du.append(yml_file["file_path"])
        self._execute_cmd("mkdir -p %s/%s/common_helm_values" % (target_dir, host_name))
        for yml_comm in yml_file_path_list_common:
            self._execute_cmd("cp %s/%s/%s/%s %s/%s/common_helm_values" % (topology_configs_dir, tl_type,
                                                                           topo_build_release, yml_comm,
                                                                           target_dir, host_name))
        if productVariant.lower() == "cu":
            yml_file_full_path_list_variant_cu = []
            for yml_var in yml_file_path_list_variant_cu:
                self._execute_cmd("cp %s/%s/%s/%s %s/%s/common_helm_values" % (topology_configs_dir, tl_type,
                                                                               topo_build_release, yml_var,
                                                                               target_dir, host_name))
                yml_var_file = yml_var.split("/")[-1]
                yml_file_full_path_list_variant_cu.append("%s/%s/common_helm_values/%s" % (target_dir, host_name,
                                                                                           yml_var_file))
            return yml_file_full_path_list_variant_cu
        elif productVariant.lower() == "du":
            yml_file_full_path_list_variant_du = []
            for yml_var in yml_file_path_list_variant_du:
                self._execute_cmd("cp %s/%s/%s/%s %s/%s/common_helm_values" % (topology_configs_dir, tl_type,
                                                                               topo_build_release, yml_var,
                                                                               target_dir, host_name))
                yml_var_file = yml_var.split("/")[-1]
                yml_file_full_path_list_variant_du.append("%s/%s/common_helm_values/%s" % (target_dir, host_name,
                                                                                           yml_var_file))
            return yml_file_full_path_list_variant_du

    def _get_configuration(self, productVariant, variant, du_num=1, du_identity="du", cellTechnology="TDD"):
        target_dir = "/home/ute/aic_dep"
        tl_config_dir = "/home/ute/testline_configuration"
        topology_configs_dir = "/home/ute/topology-configs"
        # topo_build_release is defined by vDUCNF00/vDUCNF23R3/vDUCNF23R4 ..
        topo_build_release = build.split("_")[0].replace("vCU", "vDU")

        host_name = self._execute_cmd("hostname")
        host_name = re.sub("-1$", "", host_name)
        host_name = re.sub("-2$", "", host_name)
        host_name = host_name.replace("-", "_")

        if os.path.isdir("%s/%s" % (target_dir, host_name)):
            # read init file from target_dir folder
            # tl_folder_name = host_name
            # remove target_dir and copy from /home/ute/testline_configuration
            self._execute_cmd("rm -rf %s" % target_dir)

        if os.path.isdir("%s/%s" % (tl_config_dir, host_name)):
            # read init file from tl_config_dir folder and copy to target_dir folder
            self._execute_cmd("mkdir -p %s" % target_dir)
            self._execute_cmd("cp -r %s/%s %s/%s" % (tl_config_dir, host_name, target_dir, host_name))
            tl_folder_name = host_name
        else:
            raise Exception(
                "\033[1;31;47mTestline_configuration %s not found, please use command "
                "'git clone https://wrgitlab.ext.net.nokia.com/RAN/configuration-management/testline_configuration' "
                "to your UTE location: '/home/ute'\033[0m" % host_name)

        if os.path.isdir("%s/%s" % (topology_configs_dir, tl_type)) is False:
            # git clone from https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs
            try:
                self._execute_cmd("rm -rf %s" % topology_configs_dir)
                self._execute_cmd("mkdir %s" % topology_configs_dir)
                self._execute_cmd(
                    "cd %s;git init;"
                    "git remote add -f origin git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git;"
                    "git config core.sparseCheckout true;"
                    "echo '%s/%s/' > .git/info/sparse-checkout;"
                    "git pull --depth=1 origin master" % (topology_configs_dir, tl_type, topo_build_release))
                time.sleep(2)
                if os.path.isdir(topology_configs_dir + "/" + tl_type) is not True:
                    raise Exception(
                        "\033[1;31;47mtopology-configs %s not found, and clone failed, please use command by manual"
                        "'git clone https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs' "
                        "to your UTE location: '/home/ute'\033[0m" % tl_type)
            except Exception as e:
                print(
                    "\033[1;31;47mtopology-configs %s not found, and clone failed, please use command by manual"
                    "'git clone https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs' "
                    "to your UTE location: '/home/ute'\033[0m" % tl_type)
                raise Exception(e)

        # read common yaml file from topology_configs_dir folder and copy to target_dir folder
        # if it's variant depolyment, then copy variant file to target_dir folder
        yml_file_path_list_variant = None
        if variant is not None:
            config_yaml_path = "%s/%s/%s/config.yaml" % (topology_configs_dir, tl_type, topo_build_release)
            if os.path.isfile(config_yaml_path):
                yml_file_path_list_variant = self._get_variant_yaml_file(config_yaml_path, target_dir, host_name,
                                                                         variant, topology_configs_dir,
                                                                         tl_type, topo_build_release, productVariant)
            else:
                raise Exception("Not find config.yaml for variant definition")
        else:
            if os.path.isdir("%s/%s/%s/common_helm_values" % (topology_configs_dir, tl_type, topo_build_release)):
                self._execute_cmd("cp -r %s/%s/%s/common_helm_values %s/%s" % (topology_configs_dir, tl_type,
                                                                               topo_build_release, target_dir,
                                                                               host_name))
            else:
                print("\033[1;34;47m<Warning:>\033[0m This topo not use common_helm_values,"
                      " will use only testline specific deployment values yaml\n")

        init_file_path = target_dir + "/" + tl_folder_name + "/__init__.py"
        org_file_path = target_dir + "/" + tl_folder_name
        org_topo_file_path = target_dir + "/" + tl_folder_name + "/common_helm_values"
        if productVariant.lower() == "du" and (du_identity.lower() == "du" or du_identity.lower() == "du1"):
            # vdu_ssh_ip=tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr
            # vdu_ssh_user=tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username
            # vdu_ssh_pwd=tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password
            # vdu_ns = tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace
            if du_num == 1:
                vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns = self._fecth_aic_info_from_init(init_file_path, "vdu")
                f_cluster = self._check_deployment_file_exist(org_file_path + "/vdu-cluster-preparation.yaml")
                f_pre = self._check_deployment_file_exist(org_file_path + "/vdu-prerequisite.yaml")
                f_cnf = self._check_deployment_file_exist(org_file_path + "/vdu-cnf.yaml")
                f_cluster_common = self._check_deployment_file_exist(org_topo_file_path +
                                                                     "/vdu-cluster-preparation-common.yaml")
                f_pre_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-prerequisite-common.yaml")
                f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s-1.yaml"
                                                                 % cellTechnology)
                if not os.path.isfile(f_cnf_common):
                    f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s.yaml"
                                                                     % cellTechnology)
            if du_num == 2:
                vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns = self._fecth_aic_info_from_init(init_file_path, "vdu1")
                if os.path.isfile(org_file_path + "/vdu-cluster-preparation.yaml"):
                    f_cluster = self._check_deployment_file_exist(org_file_path + "/vdu-cluster-preparation.yaml")
                else:
                    f_cluster = self._check_deployment_file_exist(org_file_path + "/vdu-cluster-preparation-1.yaml")
                f_pre = self._check_deployment_file_exist(org_file_path + "/vdu-prerequisite-1.yaml")
                f_cnf = self._check_deployment_file_exist(org_file_path + "/vdu-cnf-1.yaml")
                f_cluster_common = self._check_deployment_file_exist(org_topo_file_path +
                                                                     "/vdu-cluster-preparation-common.yaml")
                f_pre_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-prerequisite-common.yaml")
                f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s-1.yaml"
                                                                 % cellTechnology)
                if not os.path.isfile(f_cnf_common):
                    f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s.yaml"
                                                                     % cellTechnology)
            return vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns, f_cluster, f_pre, f_cnf, tl_folder_name, \
                f_cluster_common, f_pre_common, f_cnf_common, yml_file_path_list_variant
        if productVariant.lower() == "du" and du_identity.lower() == "du2":
            # vdu_ssh_ip=tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr
            # vdu_ssh_user=tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username
            # vdu_ssh_pwd=tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password
            # vdu_ns = tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.namespace
            vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns = self._fecth_aic_info_from_init(init_file_path, "vdu2")
            if os.path.isfile(org_file_path + "/vdu-cluster-preparation.yaml"):
                f_cluster = self._check_deployment_file_exist(org_file_path + "/vdu-cluster-preparation.yaml")
            else:
                f_cluster = self._check_deployment_file_exist(org_file_path + "/vdu-cluster-preparation-2.yaml")
            f_pre = self._check_deployment_file_exist(org_file_path + "/vdu-prerequisite-2.yaml")
            f_cnf = self._check_deployment_file_exist(org_file_path + "/vdu-cnf-2.yaml")
            f_cluster_common = self._check_deployment_file_exist(org_topo_file_path +
                                                                 "/vdu-cluster-preparation-common.yaml")
            f_pre_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-prerequisite-common.yaml")
            f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s-2.yaml"
                                                             % cellTechnology)
            if not os.path.isfile(f_cnf_common):
                f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vdu-cnf-common-%s.yaml"
                                                                 % cellTechnology)
            return vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns, f_cluster, f_pre, f_cnf, tl_folder_name, \
                f_cluster_common, f_pre_common, f_cnf_common, yml_file_path_list_variant
        if productVariant.lower() == "cu":
            # vcu_ssh_ip = tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr
            # vcu_ssh_user = tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username
            # vcu_ssh_pwd = tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password
            # vcu_ns = tl.gnbs[0].cloud_deployment.cloud_hosting.namespace
            vcu_ssh_ip, vcu_ssh_user, vcu_ssh_pwd, vcu_ns = self._fecth_aic_info_from_init(init_file_path, "vcu")
            f_cluster = self._check_deployment_file_exist(org_file_path + "/vcu-cluster-preparation.yaml")
            f_pre = self._check_deployment_file_exist(org_file_path + "/vcu-prerequisite.yaml")
            f_cnf = self._check_deployment_file_exist(org_file_path + "/vcu-cnf.yaml")
            f_cluster_common = self._check_deployment_file_exist(org_topo_file_path +
                                                                 "/vcu-cluster-preparation-common.yaml")
            f_pre_common = self._check_deployment_file_exist(org_topo_file_path + "/vcu-prerequisite-common.yaml")
            f_cnf_common = self._check_deployment_file_exist(org_topo_file_path + "/vcu-cnf-common.yaml")
            return vcu_ssh_ip, vcu_ssh_user, vcu_ssh_pwd, vcu_ns, f_cluster, f_pre, f_cnf, tl_folder_name, \
                f_cluster_common, f_pre_common, f_cnf_common, yml_file_path_list_variant

    def _check_vdu_docker_file_format(self, knife_data, du_num, yaml_file_path):
        for i in knife_data["nodes"][0]["files"]:
            if i["hw_id"] != knife_data["nodes"][0]["files"][0]["hw_id"]:
                raise Exception("All hw_id must be same in docker file: %s" % yaml_file_path)
        if du_num == 1:
            if knife_data["nodes"][0]["files"][0]["hw_id"] == 1:
                du_identity = "du"
            else:
                raise Exception("hw_id can only set to 1 for 1vDU in docker file %s" % yaml_file_path)
        elif du_num == 2:
            if knife_data["nodes"][0]["files"][0]["hw_id"] == 1:
                du_identity = "du"
            elif knife_data["nodes"][0]["files"][0]["hw_id"] == 2:
                du_identity = "du2"
            else:
                raise Exception("hw_id can only set to 1 or 2 for 2vDU in docker file %s" % yaml_file_path)
        else:
            raise Exception("Current tl_type is not support, please contact "
                            "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com ")
        return du_identity

    def _set_default_cprt_knife(self):
        self._execute_cmd("rm -rf dockerfile-cprt")
        self._execute_cmd("mkdir dockerfile-cprt")
        self._execute_cmd("touch dockerfile-cprt/Dockerfile")
        self._execute_cmd("echo 'RUN rm -rf /opt/nokia/SS_RCPCCSMCU/swconfig.txt' >> dockerfile-cprt/Dockerfile")
        self._execute_cmd("echo 'ADD swconfig.txt /opt/nokia/SS_RCPCCSMCU/swconfig.txt' >> dockerfile-cprt/Dockerfile")
        self._execute_cmd("echo 'RUN chmod 777 /opt/nokia/SS_RCPCCSMCU/swconfig.txt' >> dockerfile-cprt/Dockerfile")
        self._execute_cmd(
            "echo 'RUN chown root:root /opt/nokia/SS_RCPCCSMCU/swconfig.txt' >> dockerfile-cprt/Dockerfile")
        self._execute_cmd("touch dockerfile-cprt/swconfig.txt")
        self._execute_cmd("echo '0x590072=1\n0x59000c=0\n0x59000d=0\n0x5900B9=1' > dockerfile-cprt/swconfig.txt")
        cprt_default_knife_path = self._execute_cmd("pwd") + "/dockerfile-cprt"
        return cprt_default_knife_path

    def _set_default_cprt_knife_accord_yaml_file_if_exist(self, yaml_file_path, du_id, du_num):
        """Don't set default cprt knife(swconfig) if yaml config file exist cprt pod, then need owner to add this
           default cprt knife(swconfig) part.
        """
        knife_data = None
        if yaml_file_path is not None:
            knife_data = self._get_aic_knife_yaml(yaml_file_path)
            du_identity = self._check_vdu_docker_file_format(knife_data, du_num, yaml_file_path)
            all_pod_list = []
            for i in knife_data["nodes"][0]["files"]:
                all_pod_list += i["metadata"]["pod_names"]
            if "cprt" not in all_pod_list:
                # if cprt not in pod_names list wiil set default mandatory cprt knife
                cprt_default_knife_path = self._set_default_cprt_knife()
                # raise Exception("cprt pod not involved, please add it in dockerfile")
            else:
                cprt_default_knife_path = None
        else:
            cprt_default_knife_path = self._set_default_cprt_knife()
            if du_num == 1 or du_id == 1:
                du_identity = "du"
            else:
                du_identity = "du" + str(du_id)
        return knife_data, du_identity, cprt_default_knife_path

    def _remove_file_folder(self, file_foler):
        self._login()
        self.fsm_obj.execute_command_on_enb("sudo rm -rf %s" % file_foler, alias=self.alias)

    def _flash_rannic(self, build):
        print("===change vdu version in local vdu_config.ini===")
        kuafu_file_local_dir = ("/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/tools"
                                "/Aic_upgrade_include_knife_tool/kuafu_file")
        build_num_id = build.split("_")[-1]
        self._execute_cmd("cd %s;sed -i -E 's/^build_version=0.300.[0-9]+/build_version=%s/g' "
                          "vdu_config.ini" % (kuafu_file_local_dir, build_num_id))
        self._execute_cmd("cd %s; cat vdu_config.ini|grep '^build_version=0.300.'" % kuafu_file_local_dir)
        print("===start to get kuafu tool===")
        self._login()
        self.fsm_obj.execute_command_on_enb("cd ~; rm -rf kuafu-v*", alias=self.alias)
        self.fsm_obj.execute_command_on_enb(
            "cd ~;curl https://gitlabe2.ext.net.nokia.com/kuafu/kuafu/-/archive/v6.26.0/kuafu-v6.26.0.tar.gz "
            "--output ./kuafu-v6.26.0.tar.gz", alias=self.alias)
        self.fsm_obj.execute_command_on_enb("tar -xzvf kuafu-v6.26.0.tar.gz", alias=self.alias)
        time.sleep(1)
        self.fsm_obj.execute_command_on_enb("cd ~; rm kuafu-v6.26.0.tar.gz", alias=self.alias)
        self.fsm_obj.put_enb_file("%s/vdu_config.ini" % kuafu_file_local_dir,
                                  "/var/home/core/kuafu-v6.26.0/artifacts/", alias=self.alias)

        # copy rannic sw image file to kuafu l1sw directory
        kuafu_l1sw_dir = ("/var/home/core/kuafu-v6.26.0/l1sw/vdu/aic-vdu-%s" % build_num_id)
        self.fsm_obj.execute_command_on_enb("mkdir -p %s" % kuafu_l1sw_dir, alias=self.alias)
        ran_nic_sw = "ran-nic-sw-%s.tar" % build_num_id
        self.fsm_obj.execute_command_on_enb("cp %s/Image/%s %s" % (self.master_file_path, ran_nic_sw,
                                                                   kuafu_l1sw_dir), alias=self.alias)
        time.sleep(1)
        self.fsm_obj.execute_command_on_enb("cd %s; tar -xvf %s" % (kuafu_l1sw_dir, ran_nic_sw), alias=self.alias)
        time.sleep(1)
        self.fsm_obj.execute_command_on_enb(
            '''cd %s; cd "$(cat repositories | jq -r '.["ran-nic-sw"]["%s"]')"; ls; cp layer.tar ../''' % (
                kuafu_l1sw_dir, build_num_id), alias=self.alias)
        time.sleep(2)
        self.fsm_obj.execute_command_on_enb(
            "cd %s;"
            "find %s -type f ! -name '*.tar' -exec rm {} + " % (kuafu_l1sw_dir, kuafu_l1sw_dir), alias=self.alias)
        self.fsm_obj.execute_command_on_enb(
            '''cd %s; ls -l | grep '^d' | awk '{print $9}' |xargs rm -rf ''' % kuafu_l1sw_dir, alias=self.alias)
        time.sleep(1)
        self.fsm_obj.execute_command_on_enb("cd %s; tar -xvf layer.tar" % kuafu_l1sw_dir, alias=self.alias)
        time.sleep(1)
        self.fsm_obj.execute_command_on_enb("cd %s; find . -maxdepth 1 -type f -exec rm {} +" % kuafu_l1sw_dir,
                                            alias=self.alias)

        # download remote_utilities
        sdk_version = self.fsm_obj.execute_command_on_enb(
            "cd %s/vdu-thor;"
            "cat l1sw.depends.manifest |"
            "grep -oP 'u-boot-octeontx-nokia vdu-thor SDK\\K\\d+.\\d+.\\d+'" % kuafu_l1sw_dir, alias=self.alias)
        sdk_tool_link = ("https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/"
                         "marvellsdk/%s/%s.tar.gz" % (sdk_version, sdk_version))
        remote_utilities_dir = ("/var/home/core/kuafu-v6.26.0/l1sw/vdu/remote_utilities")
        self.fsm_obj.execute_command_on_enb("mkdir -p %s" % remote_utilities_dir, alias=self.alias)
        self.fsm_obj.execute_command_on_enb("curl %s --output %s/%s.tar.gz" % (sdk_tool_link, remote_utilities_dir,
                                                                               sdk_version), alias=self.alias)
        self.fsm_obj.execute_command_on_enb("cd %s; tar -xvf %s.tar.gz" % (remote_utilities_dir, sdk_version),
                                            alias=self.alias)
        self.fsm_obj.execute_command_on_enb("cd %s; rm %s.tar.gz" % (remote_utilities_dir, sdk_version),
                                            alias=self.alias)
        time.sleep(2)

        # flash rannic fw
        print("===start to flash rannic fw===")
        rannic_fw_update_ret = self.fsm_obj.execute_command_on_enb("cd ~/kuafu-v6.26.0/scenarios/vdu_l3call;"
                                                                   "./17-manage-rannic-firmware.sh update",
                                                                   alias=self.alias)
        print(rannic_fw_update_ret)
        if rannic_fw_update_ret.count("Check RAN NIC board version successfully") == 2  \
                and rannic_fw_update_ret.count("Error") == 0 and rannic_fw_update_ret.count("error") == 0 \
                and rannic_fw_update_ret.count("Fail") == 0 and rannic_fw_update_ret.count("fail") == 0:
            print("\033[1;31;32mFlash RANNIC FW successfully!\033[0m")
        else:
            raise Exception("\033[1;31;47mFlash RANNIC FW Failed !%s\033[0m")

    def _change_hw_id_in_knife_yaml_file(self, du_id, yaml_file_path):
        self._execute_cmd("sed -i -E 's/hw_id: [0-9]/hw_id: {}/g' {}".format(du_id, yaml_file_path))

    def _build_vdu_knife(self, build, du_num, yaml_file_path, du_id, knife_package, cellTechnology, variant):
        try:
            if int(du_num) != 1 and yaml_file_path is not None:
                self._change_hw_id_in_knife_yaml_file(du_id, yaml_file_path)
            knife_data, du_identity, cprt_default_knife_path = self._set_default_cprt_knife_accord_yaml_file_if_exist(
                yaml_file_path, du_id, du_num)
            vdu_ssh_ip, vdu_ssh_user, vdu_ssh_pwd, vdu_ns, \
                f_cluster, f_pre, f_cnf, tl_folder_name, f_cluster_common, f_pre_common, f_cnf_common, \
                yml_file_path_list_variant = \
                self._get_configuration(productVariant="du", variant=variant, du_num=du_num, du_identity=du_identity,
                                        cellTechnology=cellTechnology)
            self.host_ssh = vdu_ssh_ip
            self.host_ssh_usr = vdu_ssh_user
            self.host_ssh_pwd = vdu_ssh_pwd
            self.vdu_ns = vdu_ns
            self._check_and_patch_pv()
            conversionapp_path = self._download_package(tl_folder_name, build, knife_package)
            self._undeploy_image(vdu_ns, product_type="vdu")
            # self._flash_rannic(build)    #no need due to it will flash by vDU deployment
            self._load_image(tl_folder_name, build, vdu_ns)
            if yaml_file_path is not None:
                if cprt_default_knife_path is not None:
                    self._build_cprt_default_knife(vdu_ns, cprt_default_knife_path, build)
                self._build_docker_knife(knife_data, vdu_ns, build)
            else:
                # just to vdu update, need build cprt default knife
                self._build_cprt_default_knife(vdu_ns, cprt_default_knife_path, build)
            self._install_aic(vdu_ns, f_cluster, f_pre, f_cnf, build, conversionapp_path, f_cluster_common,
                              f_pre_common, f_cnf_common, yml_file_path_list_variant)
            self._remove_file_folder(self.master_file_path)
            print("\033[1;31;32mDeployment successfully!\033[0m")
        except Exception as e:
            self._remove_file_folder(self.master_file_path)
            raise Exception(e)

    def _build_vcu_knife(self, build, yaml_file_path, knife_package, variant):
        try:
            if yaml_file_path is not None:
                knife_data = self._get_aic_knife_yaml(yaml_file_path)
            vcu_ssh_ip, vcu_ssh_user, vcu_ssh_pwd, vcu_ns, \
                f_cluster, f_pre, f_cnf, tl_folder_name, f_cluster_common, f_pre_common, f_cnf_common, \
                yml_file_path_list_variant = \
                self._get_configuration(productVariant="cu", variant=variant)
            self.host_ssh = vcu_ssh_ip
            self.host_ssh_usr = vcu_ssh_user
            self.host_ssh_pwd = vcu_ssh_pwd
            self._check_and_patch_pv()
            conversionapp_path = self._download_package(tl_folder_name, build, knife_package)
            self._undeploy_image(vcu_ns, product_type="vcu")
            self._load_image(tl_folder_name, build, vcu_ns)
            if yaml_file_path is not None:
                # build cu knife if knife file input
                self._build_docker_knife(knife_data, vcu_ns, build)
            self._install_aic(vcu_ns, f_cluster, f_pre, f_cnf, build, conversionapp_path, f_cluster_common,
                              f_pre_common, f_cnf_common, yml_file_path_list_variant)
            self._remove_file_folder(self.master_file_path)
            print("\033[1;31;32mDeployment successfully!\033[0m")
        except Exception as e:
            self._remove_file_folder(self.master_file_path)
            raise Exception(e)


class build_aic_knife_vDU(object):
    def __init__(self):
        alias = "du"
        self.instance_vdu = build_aic_knife(alias)

    def build_vdu_knife(self, build, du_num, yaml_file_path, du_id, knife_package, cellTechnology, variant):
        self.instance_vdu._build_vdu_knife(build, du_num, yaml_file_path, du_id, knife_package, cellTechnology,
                                           variant)


class build_aic_knife_vDU2(object):
    def __init__(self):
        alias = "du2"
        self.instance_vdu2 = build_aic_knife(alias)

    def build_vdu_knife(self, build, du_num, yaml_file_path, du_id, knife_package, cellTechnology, variant):
        self.instance_vdu2._build_vdu_knife(build, du_num, yaml_file_path, du_id, knife_package, cellTechnology,
                                            variant)


class build_aic_knife_vCU(object):
    def __init__(self):
        alias = "cu"
        self.instance_vcu = build_aic_knife(alias)

    def build_vcu_knife(self, build, yaml_file_path, knife_package, variant):
        self.instance_vcu._build_vcu_knife(build, yaml_file_path, knife_package, variant)


def check_argument():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hb:l:t:v:f:k:", ["help", "du_id"])
        # print(opts)
        # print(args)
        if len(opts) == 0 or len(opts) < 2:
            print("Argument: \033[1;31;94m[Mandatory]\033[0m\n")
            print(
                " " * 10 + "\033[1;31;94m-b\033[0m  'vCUCNF00_0.250.xxxx' for(Trunk_cu_build)' or"
                           " 'vDUCNF00_0.300.xxxx for (Trunk_du_build)'\n")
            print(" " * 10 + "\033[1;31;94m-l\033[0m  'TL_TYPE like as: "
                             "CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH;\n"
                  + " " * 32 + "CLOUD_5GC_dRNIC_2vDU_P_AP_LO_SWFH;\n"
                  + " " * 32 + "CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC;\n"
                  + " " * 32 + "CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC'\n")
            print(" " * 10 + "\033[1;31;94m-t\033[0m  'cellTechnology like as: TDD; FDD\n")
            print(" " * 10 + "\033[1;31;94m[Optional]\033[0m[will only upgrade single cu or single du version "
                             "if missing docker knife file]\n")
            print(" " * 10 + "\033[1;31;94m-v\033[0m  'variant name like as: "
                             "SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA'\n")
            print(" " * 10 + "\033[1;31;94m-f\033[0m  'docker file absolute path like as: "
                             "/home/ute/Downloads/aic_knife_cu.yaml'\n")
            print(" " * 10 + "\033[1;31;94m-k\033[0m  'sw-knife package path like as: "
                             "https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/"
                             "knife-results/892925/'\n")
            print(" " * 10 + "\033[1;31;94mdu_id\033[0m  'du_id=1 for du1 or du_id=2 for du2 upgrade'\n")
            sys.exit(0)
        else:
            opt_list = []
            du_id = None
            docker_config_f_path = None
            knife_package = None
            variant = None
            for opt, arg in opts:
                opt_list.append(opt)
                if opt == "-b":
                    build = arg
                elif opt == "-f":
                    docker_config_f_path = arg
                elif opt == "-l":
                    tl_type = arg
                elif opt == "-k":
                    knife_package = arg
                elif opt == "-t":
                    cellTechnology = arg
                elif opt == "-v":
                    variant = arg
            if "-b" not in opt_list:
                raise Exception("\033[1;31;47m-b build is mandatory\033[0m")
            if "-l" not in opt_list:
                raise Exception("\033[1;31;47m-l tl_type is mandatory\033[0m")
            if "-t" not in opt_list:
                raise Exception("\033[1;31;47m-t cellTechnology is mandatory\033[0m")
            if "-f" not in opt_list:
                print("\033[1;31;94m===Will only upgrade sw version due to no assign docker knife===\033[0m")
                time.sleep(5)
            du_id_list = []
            for i in args:
                if i.lower().count("du_id="):
                    du_id_list.append(i)
            if len(du_id_list) > 1:
                raise Exception("\033[1;31;47m Only can assign one du_id each time\033[0m")
            if len(du_id_list) == 1:
                du_id = du_id_list[0].split("=")[-1]
            if len(du_id_list) == 0 and tl_type.lower().count("2vdu") and build.lower().count("vdu"):
                raise Exception(
                    "\033[1;31;47m Please assign additional argument: du_id=x [x=1 for du1, x=2 for du2]\033[0m")
        return build, docker_config_f_path, tl_type, du_id, knife_package, cellTechnology, variant
    except Exception as e:
        raise Exception('Please input \033[1;31;47m-h\033[0m or \033[1;31;47m--help\033[0m for help Info')


if __name__ == '__main__':
    build, docker_config_f_path, tl_type, du_id, knife_package, cellTechnology, variant = check_argument()
    if tl_type.lower().count("1vdu"):
        du_num = 1
        if build.count("vDUCNF"):
            # trunk + branch
            if build.count(".300."):
                vdu_obj = build_aic_knife_vDU()
                vdu_obj.build_vdu_knife(build, du_num=du_num, yaml_file_path=docker_config_f_path, du_id=du_id,
                                        knife_package=knife_package, cellTechnology=cellTechnology, variant=variant)
            else:
                raise Exception("\033[1;31;47mCurrent build version is not support now: %s\033[0m" % build)
        elif build.count("vCUCNF"):
            # trunk + branch
            if build.count(".250."):
                vcu_obj = build_aic_knife_vCU()
                vcu_obj.build_vcu_knife(build, yaml_file_path=docker_config_f_path, knife_package=knife_package,
                                        variant=variant)
            else:
                raise Exception("\033[1;31;47mCurrent build version is not support now: %s\033[0m" % build)
        else:
            raise Exception("\033[1;31;47mbuild version is incorrect: %s\033[0m" % build)
    elif tl_type.lower().count("2vdu"):
        du_num = 2
        if build.count("vDUCNF"):
            # trunk + branch
            if build.count(".300."):
                vdu2_obj = build_aic_knife_vDU2()
                vdu2_obj.build_vdu_knife(build, du_num=du_num, yaml_file_path=docker_config_f_path, du_id=du_id,
                                         knife_package=knife_package, cellTechnology=cellTechnology, variant=variant)
            else:
                raise Exception("\033[1;31;47mCurrent build version is not support now: %s\033[0m" % build)
        elif build.count("vCUCNF"):
            # trunk + branch
            if build.count(".250."):
                vcu_obj = build_aic_knife_vCU()
                vcu_obj.build_vcu_knife(build, yaml_file_path=docker_config_f_path, knife_package=knife_package,
                                        variant=variant)
            else:
                raise Exception("\033[1;31;47mCurrent build version is not support now: %s\033[0m" % build)
        else:
            raise Exception("\033[1;31;47mbuild version is incorrect: %s\033[0m" % build)
    else:
        raise Exception("\033[1;31;47mtl_type:%s is not support now\033[0m" % tl_type)
