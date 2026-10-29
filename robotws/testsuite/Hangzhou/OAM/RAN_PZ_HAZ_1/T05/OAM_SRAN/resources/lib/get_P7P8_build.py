# coding=utf-8
import requests
import json
import logging
from requests.packages.urllib3.exceptions import InsecureRequestWarning


def login_rep():
    sign_url = 'https://rep-portal.ext.net.nokia.com/jwt/obtain/'
    data = {'username': "amli", 'password': "Lfly20236"}
    headers = {'content-type': 'application/json',
               'referer': 'https://rep-portal.wroclaw.nsn-rdnet.net/login/',
               'origin': 'https://rep-portal.wroclaw.nsn-rdnet.net',
               'cookie':
                   '_pk_id.1.6f59=be397cc9ffef0eda.1621923234.; _pk_ses.1.6f59=1;_pk_ses.1.6f59=1;',
               'user-agent':
                   'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
                   ' Chrome/88.0.4324.104 Safari/537.36'}
    session = requests.session()
    try:
        rep_page = session.post(sign_url, headers=headers, data=json.dumps(data))
        print("%s\n%s\n%s\n" % (rep_page.text, rep_page.reason, rep_page.status_code))
        assert rep_page.status_code == 200, "Status page after login " + sign_url + " not 200"
    except RuntimeError:
        print('Connection error during Reportal authentitaction!')
        raise Exception('Connection error during Reportal authentitaction!')
    return session


requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
rep_session = login_rep()
build_p7_p8_url = 'https://rep-portal.ext.net.nokia.com/api/delivery-entry?days_done=60&days_next=60'
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')


def get_p7p8_build_info(targ_resl, url=build_p7_p8_url):
    results_str = rep_session.get(url)
    print("results_str:%s" % results_str)
    res = json.loads(results_str.text)
    print("res:%s" % res)
    release_list = res['results']
    build_num = ' '
    try:
        for item in release_list:
            print("item_rel:{}".format(item['release']))
            if item['release'] == targ_resl:
                if item['done']:
                    done_list = item['done']
                    for each in done_list:
                        if '1.0PD' in each['name']:
                            build_num = each['builds'][0]
                        elif '0.0PD' in each['name']:
                            build_num = each['builds'][0]
    except RuntimeError:
        build_num = []
        logging.error("get P7_P8 build exception", build_num)
    else:
        logging.info("build_num:%s", build_num)
        print("build_num: {}".format(build_num))
        return build_num


get_p7p8_build_info('23R4')
