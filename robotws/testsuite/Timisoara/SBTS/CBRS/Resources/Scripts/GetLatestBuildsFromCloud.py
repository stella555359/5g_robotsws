#!/usr/bin/env python
# -*- coding: utf-8 -*-

from ute_cloud_manager_api.api import CloudManagerApi
import sys

token = sys.argv[1]
branchVer = sys.argv[2]
records = sys.argv[3]

cm = CloudManagerApi(token)
available_builds_list = cm.list_enb_builds(branch=branchVer, limit=records)

print('[output_start]')
print(available_builds_list)
print('[output_end]')
