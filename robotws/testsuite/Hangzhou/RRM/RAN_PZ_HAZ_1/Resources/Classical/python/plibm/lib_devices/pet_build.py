# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""

import logging


class Build(object):

    def __init__(self, buildname, customer='A54') -> None:
        # buildname like: SBTS00_ENB_9999_230401_000014
        # buildname like: SBTS00_FSM3_9999_230310_000001
        self.buildname = buildname
        self.customer = customer

        self.is_trunk = '9999' in buildname
        if self.is_trunk:
            self.branch = 'SBTS00'
        else:
            self.branch = buildname.split('_')[0]
        branch_add = '_FSM3' if 'FSM3' in buildname else ''

        self.tag = '_'.join(self.buildname.split('_')[1:])
        self.filename = f'{self.branch}_{self.tag}_release_BTSSM_downloadable_{self.customer}.zip'

        self.hz_file = ('https://artifactory-hz1.ext.net.nokia.com/artifactory/'
                        'mn-cosi-sran-central-public-remote/build/'
                        f'{self.branch}{branch_add}/{self.branch}_{self.tag}/{self.filename}')
        self.pl_file = ('https://artifactory-espoo2.int.net.nokia.com/artifactory/'
                        'mn-cosi-sran-central-public-local/build/'
                        f'{self.branch}{branch_add}/{self.branch}_{self.tag}/{self.filename}')

    def get_http_file_size(self, url):
        import requests
        resp = requests.head(url)
        if resp.status_code == 200:
            headers = resp.headers
            return int(headers.get('Content-Length', 0))
        else:
            raise Exception(f'Failed to get url file size: {url} {resp.status_code}')

    def find_download_url(self):
        return self.hz_file
        if self.get_http_file_size(self.hz_file) > 0:
            logging.info('File was found in HZ Site')
            return self.hz_file
        elif self.get_http_file_size(self.pl_file) > 0:
            logging.info('File was found in Poland Site')
            return self.pl_file
        else:
            raise Exception('Could not find file in HZ site or Porland site')


if __name__ == '__main__':
    b = Build('SBTS00_ENB_9999_230907_000003')
    # b = Build('SBTS23R4_FSM3_0000_000022_000000')
    print(b.find_download_url())
