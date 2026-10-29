import requests
import json


class binary_search(object):
    def __init__(self):
        self.access_key = 'mMzwgJnDzFZeB6ubKYNIC3pUy7mNzrZ6O7cIRvs2'
        self.base_url = 'https://wft.int.net.nokia.com:8091/api/v1'
        self.s = requests.session()

    def get_build_info(self, version):
        """
        Get build detail information by version
        :param version: string .
        :return:
        """
        url = "{base_url}/SBTS/CI_ENB/builds/{version}?access_key={access_key}&excluded[]=ancestry&excluded[]=" \
              "custom_config_spec".format(base_url=self.base_url, version=version, access_key=self.access_key)

        res = self.s.get(url, verify=False)
        return res.json()

    def retrieve_collection_by_id(self, branch, start, end, sort, page=1, items=20):
        """
        Get build collection by build id
        :param branch: string .
        :param start: The start point of build id.
        :param end: The end point of build id .
        :param page: The default page number of collection .
        :param items: The default items number per page of collection .
        :return:list
        """
        url = "{base_url}/build.json".format(base_url=self.base_url)
        data = {
            "page": page,
            "items": items,
            "sorting_field": "created_at",
            "sorting_direction": sort,
            "group_by": "",
            "group_by_processor": "",
            "columns": {
                "0": {
                    "id": "id"
                },
                "1": {
                    "id": "branch.title"
                },
                "2": {
                    "id": "version"
                },
                "3": {
                    "id": "state"
                }
            },
            "projects": [
                "ALL"
            ],
            "view_filters_attributes": {
                "0": {
                    "column": "branch.title",
                    "operation": "eq",
                    "value": [
                        branch
                    ],
                    "parameter": ""
                },
                "1": {
                    "column": "deliverer.title",
                    "operation": "eq",
                    "value": [
                        "CI_ENB"
                    ],
                    "parameter": ""
                },
                "2": {
                    "column": "state",
                    "operation": "eq",
                    "value": [
                        "RELEASED"
                    ],
                    "parameter": ""
                },
                "3": {
                    "column": "state",
                    "operation": "eq",
                    "value": [
                        "RELEASED_WITH_RESTRICTIONS"
                    ],
                    "parameter": ""
                },
                "4": {
                    "column": "id",
                    "operation": "gt",
                    "value": start,
                    "parameter": ""
                },
                "5": {
                    "column": "id",
                    "operation": "lt",
                    "value": end,
                    "parameter": ""
                }
            },
            "access_key": self.access_key
        }
        headers = {'content-type': "application/json"}
        res = self.s.post(url, data=json.dumps(data), headers=headers, verify=False)
        return res.json()

    def get_build_id(self, version):
        build_info = self.get_build_info(version)
        build_id = build_info['id']
        return build_id

    def retrieve_all_collection_by_id(self, branch, start_id, end_id, sort="DESC"):
        result = self.retrieve_collection_by_id(branch, start_id, end_id, sort)
        total = result['total']
        result = self.retrieve_collection_by_id(branch, start_id, end_id, sort, items=total)
        return result['items']

    def get_middle_build(self, items):
        mid = int(len(items) / 2)
        return items[mid]

    def get_half_items(self, items, flag):
        length = len(items)
        mid = int(length / 2)
        if flag:
            return items[0:mid]
        elif length == 2:
            return items[-1:]
        elif length > 2:
            return items[mid + 1:]

    def get_target_failed_build(self, failed_items):
        temp_id = 0
        first_failed_version = []
        for item in failed_items:
            if temp_id == 0:
                min_id = item['id']
                first_failed_version = item['version']
            elif item['id'] < min_id:
                min_id = item['id']
                first_failed_version = item['version']
        return first_failed_version

    def get_target_passed_build(self, failed_items):
        temp_id = 0
        get_last_passed_build = []
        for item in failed_items:
            if temp_id == 0:
                max_id = item['id']
                get_last_passed_build = item['version']
            elif item['id'] > max_id:
                max_id = item['id']
                get_last_passed_build = item['version']
        return get_last_passed_build


if __name__ == "__main__":
    pass
