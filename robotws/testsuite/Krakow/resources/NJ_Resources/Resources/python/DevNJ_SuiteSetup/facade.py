from .upgrade import *
from .load import *
from .testline import *
from .configure import *
from robot.libraries.BuiltIn import BuiltIn


class SysUpgradeType(object):
    standard = AsirUpgrade
    cdd = CddUpgrade
    das_dss = DasUpgrade
    dualcore_master = DualCoreMasterUpgrade
    dualcore_slave = DualCoreSlaveUpgrade
    rfs_all = RfsAllUpgrade
    rfs_all_master = RfsAllMasterUpgrade
    rfs_all_slave = RfsAllSlaveUpgrade


def loadpkg_download(loadname):
    loadservercfg = SYS["load_servers"]["Nanjing"]

    i = 0
    while i < 5:
        i += 1
        try:
            load_mgr = LoadMgr(loadname, loadservercfg["IP"], loadservercfg["USER"], loadservercfg["PASSWD"],
                               loadservercfg["PATH"])
            logger.info('=' * 10 + 'Start: Download Build' + '=' * 10, also_console=True)
            load_mgr.downloadpkg()
            load_mgr.prepare_yaft()
            logger.info('=' * 10 + 'End: Download Build' + '=' * 10, also_console=True)
            break
        except Exception as e:
            logger.error('=' * 10 + 'Download load build failed, try again after sleep 20s' + '=' * 10)
            time.sleep(20)
    else:
        raise Exception('=' * 10 + 'Download load build failed finally!!!' + '=' * 10)

    loadpkg = get_gnb_pkg(load_mgr, loadname)
    return loadpkg


def loadpkg_delete(loadname):
    path = PKG_LOCAL_ROOTPATH
    logger.info('=' * 10 + 'Start: Delete Build and YAFT_IMAGE Directory' + '=' * 10, also_console=True)
    run("rm -rf {}".format(os.path.join(path, loadname)))
    run("rm -rf {}".format(os.path.join(path, 'YAFT_IMAGE')))
    run("rm -rf {}admin_api_*".format(os.path.abspath(__file__).split('testsuite')[0]))
    run("rm -rf {}log".format(os.path.abspath(__file__).split('testsuite')[0]))
    logger.info(os.path.abspath(__file__).split('testsuite'), also_console=True)
    logger.info('=' * 10 + 'End: Delete Build and YAFT_IMAGE Directory' + '=' * 10, also_console=True)


def get_gnb_pkg(loadmgr, loadname):
    loaddir = loadmgr.get_loaddir(loadname)
    loadpkg = ""
    files = os.listdir(loaddir)
    for file in files:
        name, ext = os.path.splitext(file)
        if loadname in name and ext == ".zip" and "_BTSSM_" in name:
            loadpkg = os.path.join(loaddir, file)
            break

    if not os.path.exists(loadpkg):
        logger.debug("{} pkg does not exist, abort".format(loadpkg))
        return

    logger.debug("pkg name: {}".format(loadpkg))
    return loadpkg


def get_active_load_upgrade_method(tl_info):
    current_sw_version = get_sbts_sw_version()
    return upgrade_method_selection(tl_info, current_sw_version)


def upgrade_method_selection(tl_info, loadname):
    load_branch = get_release(loadname)
    sys_branches = SysCfgBranches(ciApiBase).get_branchs_info(tl_info.product_id)
    if not sys_branches:
        raise Exception("Failed to query branch info from dashboard, "
                        "please contact @Zhao Haiyang to add this product")

    active_branch_id = None
    for branch in sys_branches:
        if branch.get("pattern") == load_branch:
            active_branch_id = branch.get("id")
            logger.info("Found branch {}".format(branch))
            break

    # if not active_branch_id:
    #     for branch in sys_branches:
    #         if branch.get("pattern") == "SBTS00":
    #             active_branch_id = branch.get("id")
    #             logger.info("Found branch {}".format(branch))
    #             break
    active_upgrade_method_id = tl_info.branch_upgrade_method_id(active_branch_id)
    if not active_upgrade_method_id:
        active_upgrade_method_id = tl_info.upgrade_method_id

    sys_upg_methods = SysCfgUpgradeMethods(ciApiBase)
    methods = sys_upg_methods.upgrade_method
    if methods is None:
        raise Exception("Failed to query sys upgrade methods, exit.")

    active_upgrade_method_name = None
    for method in methods:
        if method.get("id") == active_upgrade_method_id:
            active_upgrade_method_name = method.get("name")
            break

    if not active_upgrade_method_name:
        active_upgrade_method_name = sys_upg_methods.default_upgrade_method.get("name")

    logger.info("Choose upgrade method for {}: {}".format(load_branch, active_upgrade_method_name))
    return active_upgrade_method_name


# def upgrade_method_selection(tl_info, loadname):
#     load_branch = get_release(loadname)
#     sys_branches = SysCfgBranches(ciApiBase).get_branchs_info(tl_info.product_id)
#     if not sys_branches:
#         raise Exception("Failed to query branch info from dashboard, "
#                         "please contact @Zhao Haiyang to add this product")
#
#     branch_id = None
#     for branch in sys_branches:
#         if branch.get("pattern") == load_branch:
#             branch_id = branch.get("id")
#             logger.info("Found branch {}".format(branch))
#             break
#
#     tl_upg_method_id = tl_info.upgrade_method_id
#     upg_method_id = tl_info.branch_upgrade_method_id(branch_id)
#     if upg_method_id is None:
#         upg_method_id = tl_upg_method_id
#
#     sys_upg_methods = SysCfgUpgradeMethods(ciApiBase)
#     methods = sys_upg_methods.upgrade_method
#     if methods is None:
#         raise Exception("Failed to query sys upgrade methods, exit.")
#
#     upg_method_name = None
#     for method in methods:
#         if method.get("id") == upg_method_id:
#             upg_method_name = method.get("name")
#         elif method.get("id") == tl_upg_method_id:
#             tl_upg_method_name = method.get("name")
#
#     if upg_method_name is None:
#         if upg_method_id == 0:
#             default_upgrade_method = sys_upg_methods.default_upgrade_method
#             upg_method_name = default_upgrade_method.get("name")
#         else:
#             raise Exception("faild to select upgrade method, exit")
#
#     logger.info("Choose upgrade method for {}: {}".format(load_branch, upg_method_name))
#     return upg_method_name


def get_master_tl_info():
    master_testline = run("hostname").replace("-", "_")

    try:
        master_tl_info = TestlineInfo(master_testline, ciApiBase)
    except Exception as e:
        if "Get testline {} failed".format(master_testline) in str(e):
            raise Exception("Failed to query testline {} in dashboard, suppose this testline dont need upgrade, "
                            "so exit!!".format(master_testline))

    return master_testline, master_tl_info


def get_slave_tl_info(master_tl_info):
    assert master_tl_info.product_type, "Please fulfill your product type in dashboard"
    _tl = BuiltIn().get_variable_value("${tl}")
    if "nr" in master_tl_info.product_type.lower():
        if hasattr(_tl, "enbs") and _tl.enbs:
            try:
                bts_kvm_ip = _tl.enbs[0].system_module.common_units[0].lmp_connection.proxy.addr
                bts_kvm_user = _tl.enbs[0].system_module.common_units[0].lmp_connection.proxy.username
                bts_kvm_password = _tl.enbs[0].system_module.common_units[0].lmp_connection.proxy.password
            except Exception as e:
                raise Exception("Get slave kvm info failed with error:{}".format(str(e)))
        else:
            raise Exception("Master bts is {}, {}, and haven't found pair bts in __init__.py, "
                            "suppose this testline dont need upgrade".
                            format(master_tl_info.product_name, master_tl_info.product_type))

    elif "lte" in master_tl_info.product_type.lower():
        if hasattr(_tl, "gnbs") and _tl.gnbs:
            try:
                bts_kvm_ip = _tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.proxy.addr
                bts_kvm_user = _tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.proxy.username
                bts_kvm_password = _tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.proxy.password
            except Exception as e:
                raise Exception("Get slave kvm info failed with error:{}".format(str(e)))
        else:
            raise Exception("Master bts is {}, {}, and haven't found pair bts in __init__.py, "
                            "suppose this testline dont need upgrade".
                            format(master_tl_info.product_name, master_tl_info.product_type))
    else:
        raise Exception("Master bts is {}, {}, and don't support this type in __init__.py, "
                        "suppose this testline dont need upgrade".
                        format(master_tl_info.product_name, master_tl_info.product_type))

    slave_testline = get_testline_name(hostname=bts_kvm_ip, username=bts_kvm_user, password=bts_kvm_password,
                                       port=22)

    try:
        slave_tl_info = TestlineInfo(slave_testline, ciApiBase)
    except Exception as e:
        raise Exception("Failed to query testline {} in dashboard, suppose this testline dont need upgrade, "
                        "so exit!!".format(slave_testline))
    return slave_tl_info, bts_kvm_ip, bts_kvm_user, bts_kvm_password


def get_all_ips_from_init():
    ips_dict = {}
    _tl = BuiltIn().get_variable_value("${tl}")
    if hasattr(_tl, "gnbs") and _tl.gnbs:
        for gnb in _tl.gnbs:
            gnb_index = _tl.gnbs.index(gnb)
            ips_dict["gnb{}".format(gnb_index)] = {}
            try:
                bts_oam_ip = gnb.cu.oam_http_connection_details.addr
                bts_oam_user = gnb.cu.oam_http_connection_details.username
                bts_oam_password = gnb.cu.oam_http_connection_details.password
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_ip"] = bts_oam_ip
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_user"] = bts_oam_user
                ips_dict["gnb{}".format(gnb_index)]["bts_oam_password"] = bts_oam_password
            except Exception as e:
                logger.error("Get ips of gnb{} failed with error {}".format(gnb_index, str(e)))

    if hasattr(_tl, "enbs") and _tl.enbs:
        for enb in _tl.enbs:
            enb_index = _tl.enbs.index(enb)
            ips_dict["enb{}".format(enb_index)] = {}
            try:
                try:
                    bts_oam_ip = enb.oam_ip.v4
                except Exception as e:
                    bts_oam_ip = enb.x2_link_addr.v4
                bts_oam_user = "Nemuadmin"
                bts_oam_password = "nemuuser"
                ips_dict["enb{}".format(enb_index)]["bts_oam_ip"] = bts_oam_ip
                ips_dict["enb{}".format(enb_index)]["bts_oam_user"] = bts_oam_user
                ips_dict["enb{}".format(enb_index)]["bts_oam_password"] = bts_oam_password
            except Exception as e:
                logger.error("Get ips of enb{} failed with error {}".format(enb_index, str(e)))
    logger.info("IPs info in init.py: {}".format(ips_dict))
    return ips_dict
