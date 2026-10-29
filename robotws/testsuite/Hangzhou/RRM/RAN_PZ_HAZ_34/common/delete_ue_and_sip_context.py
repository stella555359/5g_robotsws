# coding= utf-8

'''
the ptyhon file is used for delete ue and sip context
'''

import requests

urls = ['https://newhorizons.srnhz.nsn-rdnet.net:8080/myimsi/delete_ue_context',
        'https://newhorizons.srnhz.nsn-rdnet.net:8080/myimsi/delete_sip_context']
header = {"Content-Type": "application/x-www-form-urlencoded"}


def delete_ue_context(imsi_num):
    url = urls[0]
    imsi = {"imsi": imsi_num}
    response = requests.post(url=url, data=imsi, headers=header, verify=False, timeout=90)
    print(response.status_code)
    if response.status_code == 200:
        print('imsi: "{}" ue context is deleted successfully'.format(imsi_num))
    else:
        print('imsi: "{}" ue context is deleted failed'.format(imsi_num))


def delete_sip_context(imsi_num):
    url = urls[1]
    imsi = {"imsi": imsi_num}
    response = requests.post(url=url, data=imsi, headers=header, verify=False)
    print(response.status_code)
    if response.status_code == 200:
        print('imsi: "{}" sip context is deleted successfully'.format(imsi_num))
    else:
        print('imsi: "{}" sip context is deleted failed'.format(imsi_num))
