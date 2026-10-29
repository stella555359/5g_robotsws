"""
Author: Ruiyu Han
Contacts: ruiyu.han@nokia-sbell.com
Description: deal with dcap

"""
from taf.sw.dcap.rd import rd as dcap_rd
import time
# from taf.sw.dcap.rd.exception import NotConnectedException, AuthenticationFailed


def flexible_connect_to_dcap(dcap_host, dcap_host_bak, dcap_port, username='utfuser', password='utfadmin!'):
    try:
        retry_connect_to_dcap(dcap_host=dcap_host, dcap_port=dcap_port, username=username, password=password)
        print("successful connect to dcap:%s" % dcap_host)
    except Exception:
        retry_connect_to_dcap(dcap_host=dcap_host_bak, dcap_port=dcap_port, username=username, password=password)
        print("successful connect to dcap:%s" % dcap_host_bak)


def retry_connect_to_dcap(dcap_host, dcap_port, username='utfuser', password='utfadmin!'):
    retry_count = 3
    dcap_obj = dcap_rd()
    while True:
        try:
            dcap_obj.connect_to(host=dcap_host, port=dcap_port, username=username, password=password, secure=True)
            break
        except Exception:
            print('retry connect to dcap count: %s' % retry_count)
            if retry_count == 0:
                raise Exception
            retry_count -= 1
            time.sleep(1)
