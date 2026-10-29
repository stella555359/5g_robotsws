PKG_LOCAL_ROOTPATH = "/home/ute/pkgload"
LOAD_ROOT_PATH_5G = "/home/scpadm/SPACE/COMMON/Loads/ASIR"
URL_5G_Commission = 'http://10.66.11.27/repo/5g-commission'
ciApiBase = "http://10.66.11.27/dashboard/s/api"
yaft_svn_url = "https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk"
yaft_svn_user = "ca_ute_test"
yaft_svn_passwd = "utetest"
yaft_latest_path = "/home/ute/yaft_latest"
yaft_file = "/home/ute/yaft_latest/yaft.py"
image_dir = "/home/ute/pkgload/YAFT_IMAGE"

SYS = {
    # for database
    "db_host": "10.66.11.27",
    "db_port": 33306,
    "db_user": "",
    "db_passwd": "",
    "database": "",  # updated dynamic
    # for loadserver and svn server
    "load_servers": {
        "Nanjing": {
            "IP": "10.66.11.28",
            "USER": "scpadm",
            "PASSWD": "M%ACTfVV&U!k3qqL#1r4",
            "PATH": LOAD_ROOT_PATH_5G,
        },
        "NJCommon": {
            "IP": "10.66.12.164",
            "USER": "scpadm",
            "PASSWD": "M%ACTfVV&U!k3qqL#1r4",
            "PATH": "/home/scpadm/loads/ASIR",
        },
    },
    # 5g commission files
    "5g_commission": {
        "repo": "https://gitlabe2.ext.net.nokia.com/mftaas/5g-commission.git",
        "username": "ca_MF_ST",
        "password": "Welcome123",
        "repo_local": "/home/ute/5g-commission",
    },
    # ci server api
    "ci_api_base": "http://10.66.11.27/ci/s/api",
}
