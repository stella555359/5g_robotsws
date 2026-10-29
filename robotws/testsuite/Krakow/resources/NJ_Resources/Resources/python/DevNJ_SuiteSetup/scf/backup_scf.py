from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.load import *


def get_all_ips_from_init():
    ips_dict = {}
    _tl = BuiltIn().get_variable_value("${tl}")
    if hasattr(_tl, "gnbs") and _tl.gnbs:
        for gnb in _tl.gnbs:
            gnb_index = _tl.gnbs.index(gnb)
            ips_dict["gnb{}".format(gnb_index)] = {}
            try:
                bts_oam_ip = gnb.cu.oam_ssh_connection_details.addr
                bts_oam_user = gnb.cu.oam_ssh_connection_details.username
                bts_oam_password = gnb.cu.oam_ssh_connection_details.password
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_ip"] = bts_oam_ip
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_user"] = bts_oam_user
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_password"] = bts_oam_password
                bts_kvm_ip = gnb.dus[0].airscale.common_units[0].lmp_connection.proxy.addr
                bts_kvm_user = gnb.dus[0].airscale.common_units[0].lmp_connection.proxy.username
                bts_kvm_password = gnb.dus[0].airscale.common_units[0].lmp_connection.proxy.password
                ips_dict["gnb{}".format(gnb_index)]["bts_kvm_ip"] = bts_kvm_ip
                ips_dict["gnb{}".format(gnb_index)]["bts_kvm_user"] = bts_kvm_user
                ips_dict["gnb{}".format(gnb_index)]["bts_kvm_password"] = bts_kvm_password
            except Exception as e:
                logger.error("Get ips of gnb{} failed with error {}".format(gnb_index, str(e)))

    if hasattr(_tl, "enbs") and _tl.enbs:
        for enb in _tl.enbs:
            enb_index = _tl.enbs.index(enb)
            ips_dict["enb{}".format(enb_index)] = {}
            try:
                bts_oam_ip = enb.oam_ip.v4 or enb.x2_link_addr.v4
                bts_oam_user = "toor4nsn"
                bts_oam_password = "oZPS0POrRieRtu"
                ips_dict["enb{}".format(enb_index)]["bts_oam_ip"] = bts_oam_ip
                ips_dict["enb{}".format(enb_index)]["bts_oam_user"] = bts_oam_user
                ips_dict["enb{}".format(enb_index)]["bts_oam_password"] = bts_oam_password
                bts_kvm_ip = enb.system_module.common_units[0].lmp_connection.proxy.addr
                bts_kvm_user = enb.system_module.common_units[0].lmp_connection.proxy.username
                bts_kvm_password = enb.system_module.common_units[0].lmp_connection.proxy.password
                ips_dict["enb{}".format(enb_index)]["bts_kvm_ip"] = bts_kvm_ip
                ips_dict["enb{}".format(enb_index)]["bts_kvm_user"] = bts_kvm_user
                ips_dict["enb{}".format(enb_index)]["bts_kvm_password"] = bts_kvm_password
            except Exception as e:
                logger.error("Get ips of enb{} failed with error {}".format(enb_index, str(e)))
    logger.info("IPs info in init.py: {}".format(ips_dict))
    return ips_dict


def download_install_asicli(loadname, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd, remote_ssh_port=22,
                            connection='install_cli'):
    asimgr = r"/opt/Nokia/Managers/BTS\ Site/ASiR\ Manager/tools"
    i = 0
    ssh_manager = ssh()
    loadmgr = LoadMgr(loadname)
    while i < 5:
        i += 1
        try:
            ssh_manager.connect_to(hostname=remote_ssh_ip, username=remote_ssh_user,
                                   password=remote_ssh_passwd,
                                   port=remote_ssh_port, alias=connection)

            ssh_manager.send_command(command="ls -l /opt/asir", connection=connection)
            output = ssh_manager.read_output(connection=connection)
            if "/opt/Nokia/Managers/BTS Site/ASiR Manager/tools/scripts" in output:
                break
            loadmgr.download_asicli()
            ssh_manager.upload_file(os.path.join(os.path.join(PKG_LOCAL_ROOTPATH, loadname),
                                                 "asi-cli.tgz"), "/tmp/asi-cli.tgz", connection=connection)
            ssh_manager.send_command(command="sudo mkdir -p {}".format(asimgr),
                                     connection=connection)
            ssh_manager.send_command(command="sudo tar zxf /tmp/asi-cli.tgz -C {}".format(asimgr),
                                     connection=connection)
            ssh_manager.send_command(
                command="sudo rm -rf {0}/CLI && sudo cp -rf {0}/scripts {0}/CLI".format(asimgr),
                connection=connection)
            ssh_manager.send_command(
                command="sudo rm -rf /opt/asir && sudo ln -s {}/scripts /opt/asir".format(asimgr),
                connection=connection)
            ssh_manager.send_command(command="sudo chown -R ute.ute {}".format(asimgr),
                                     connection=connection)
            ssh_manager.send_command(
                command="sudo chown -R ute.ute /opt/asir && sudo chown -R ute.ute /opt/asir/",
                connection=connection)
            ssh_manager.disconnect(connection=connection)
            break
        except Exception:
            logger.error(
                "Install CLI failed on host: {} with username: {} and password: {} and port: {}".format(
                    remote_ssh_ip,
                    remote_ssh_user,
                    remote_ssh_passwd,
                    remote_ssh_port))
            ssh_manager.disconnect(connection=connection)
            time.sleep(10)


def save_asir_scf(file_name, local_path, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd, remote_ssh_port=22,
                  connection='asir_commission'):
    ssh_manager = ssh()
    i = 0
    while i < 5:
        i += 1
        try:
            ssh_manager.connect_to(hostname=remote_ssh_ip, username=remote_ssh_user, password=remote_ssh_passwd,
                                   port=remote_ssh_port, alias=connection)
            ssh_manager.send_command(command="cd /opt/asir/ && bash -C collectfiles.sh -ne 192.168.255.129 "
                                             "-pw Nemuadmin:nemuuser -outdir {} -comm".format("/tmp"),
                                     connection=connection)
            output = ssh_manager.read_output(connection=connection)
            if "finished successfully" in output:
                ssh_manager.send_command(command="mv /tmp/192.168.255.129_scf.xml /tmp/{}".format(file_name),
                                         connection=connection)
                ssh_manager.download_file(remote_path="/tmp/{}".format(file_name),
                                          local_path=os.path.join(local_path, file_name), connection=connection)
                ssh_manager.disconnect(connection=connection)
                break
        except Exception as e:
            logger.error(
                "Save asir scf failed on host: {} with username: {} and password: {} and port: {}".format(
                    remote_ssh_ip,
                    remote_ssh_user,
                    remote_ssh_passwd,
                    remote_ssh_port))
            ssh_manager.disconnect(connection=connection)
            time.sleep(60)
