from taf.sbts.oam.coam.admin import admin
from optparse import OptionParser
import os
import sys


class SiteOperation:
    def __init__(self):
        self.api = None

    def connect_to_site(self, host, username, password):
        self.api = admin()
        self.host = host
        self.api.connect_to(
            bts_host=host,
            username=username,
            password=password,
            name=host)

    def commission(self, scf_path):
        if os.path.exists(scf_path):
            self.api.perform_commissioning(scf_file=scf_path,
                                           connection=self.host)
        else:
            raise Exception("Could not find the scf file {}".format(scf_path))

    def teardown(self):
        self.api.teardown(connection=self.host)


def get_user_paras():
    opt = OptionParser()
    opt.add_option("-a", "--action", type="string", action="store", dest="action",
                   help="action can be: commission")
    opt.add_option("-i", "--host", type="string", action="store", dest="host",
                   default="192.168.255.129",
                   help="bts s1 name, default is 192.168.255.129")
    opt.add_option("-u", "--username", type="string", action="store", dest="username",
                   default="Nemuadmin",
                   help="bts webem username, default is: Nemuadmin")
    opt.add_option("-p", "--password", type="string", action="store", dest="password",
                   default="nemuuser",
                   help="bts webem username, default is: nemuuser")
    opt.add_option("-m", "--params", type="string", action="store", dest="params",
                   help="other params, like scf path")
    (options, sys.argv[1:]) = opt.parse_args()
    return options


if __name__ == '__main__':
    opt = get_user_paras()
    site = SiteOperation()
    site.connect_to_site(opt.host, opt.username, opt.password)
    try:
        getattr(site, opt.action)(opt.params)
        print("Success, {}".format(opt.params))
    except Exception as e:
        print("Fail, Some Exception happend {}".format(e))
    finally:
        site.teardown()
