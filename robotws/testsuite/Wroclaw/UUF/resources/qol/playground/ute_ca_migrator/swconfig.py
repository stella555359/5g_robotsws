import os
import shutil
from test_lines import tl_dict

topology_conf = "C:/Users/starzyk/repo/topology-configs/"

test_lines = [
    "1_16_CLOUD3697",
    "1_16_CLOUD3726",
    "1_16_UTESRAN3845",
    "1_16_UTESRAN3885",
    "1_16_UTESRAN3850",
    "1_16_UTESRAN3222",
    "1_16_UTESRAN3208",
    "1_16_UTESRAN3209",
    "1_16_UTESRAN2201",
    "1_16_UTESRAN2203",
    "1_16_UTESRAN2205",
    "1_16_UTESRAN2039",
    "1_16_UTESRAN3600",
    "1_16_UTESRAN3606",
    "1_16_UTESRAN3881",
    "1_16_UTESRAN3833",
    "1_16_UTESRAN2029",
    "1_16_UTESRAN2038",
    "1_16_UTESRAN3215",
    "1_16_UTESRAN3216",
    "1_16_UTESRAN3223",
    "1_16_UTESRAN3225",
    "1_16_UTESRAN3227",
    "1_16_UTESRAN2051",
    "1_16_UTESRAN2147",
    "1_16_UTESRAN3617",
    "1_16_UTESRAN3230",
    "1_16_UTESRAN3234",
    "1_16_UTESRAN3236",
    "1_16_UTESRAN3238",
    "1_16_UTESRAN3787",
    "1_16_UTESRAN3789",
    "1_16_UTESRAN3791",
    "1_16_UTESRAN2065",
    "1_16_UTESRAN2066",
    "1_16_UTESRAN2067",
    "1_16_UTESRAN2194",
    "1_16_UTESRAN2196",
    "1_16_UTESRAN3641",
    "1_16_UTESRAN3212",
    "1_16_UTESRAN3213",
    "1_16_UTESRAN3214",
    "1_16_UTESRAN2057",
    "1_16_UTESRAN2097",
    "1_16_UTESRAN2107",
    "1_16_UTESRAN3754",
    "1_16_UTESRAN3742",
    "1_16_UTESRAN3689",
    "1_16_UTESRAN3202",
    "1_16_UTESRAN3607",
    "1_16_UTESRAN3206",
    "1_16_UTESRAN2016",
    "1_16_UTESRAN2094",
    "1_16_UTESRAN2073",
    "1_16_UTESRAN2104",
    "1_16_UTESRAN2119",
    "1_16_UTESRAN1279",
    "1_16_UTESRAN2018",
    "1_16_UTESRAN2046",
    "1_16_UTESRAN2083",
    "1_16_UTESRAN2089",
    "1_16_UTESRAN2091",
    "1_16_UTESRAN2092",
    "1_16_UTESRAN2093",
    "1_16_UTESRAN2095",
    "1_16_UTESRAN2096",
    "1_16_UTESRAN2198",
    "1_16_UTESRAN3760",
    "1_16_UTESRAN3763",
    "1_16_UTESRAN3735",
    "1_16_UTESRAN3801",
    "1_16_UTESRAN3875",
    "1_16_CLOUD3848",
    "1_16_UTESRAN2040",
    "1_16_UTESRAN3643",
    "1_16_UTESRAN3644",
    "1_16_CLOUDGTA3817",
    "1_16_UTESRAN3684",
    "10_16_CLOUD3716",
    "1_16_UTESRAN3840",
    "1_16_CLOUD3770",
    "1_16_CLOUD3728",
    "1_16_UTESRAN3634",
    "1_16_CLOUD3844",
    "1_16_CLOUD3847",
    "1_16_UTESRAN3874",
    "1_16_CLOUD2181",
    "1_16_UTESRAN2041",
    "1_16_UTESRAN3755",
    "1_16_UTESRAN2031",
    "1_16_UTESRAN3200",
    "1_16_CLOUD1235",
    "10_16_CLOUD3846",
    "1_16_CLOUD3683",
    "1_16_CLOUD3893",
    "1_16_UTESRAN2085",
    "1_16_UTESRAN3765",
    "1_16_UTESRAN3000",
    "1_16_UTESRAN2034",
    "1_16_UTESRAN2045",
    "2_11_UTE4G276",
    "2_11_UTE4G274",
    "bucket_1_1",
    "bucket_1_2",
    "bucket_1_3",
    "bucket_2_3",
    "bucket_2_4",
    "bucket_2_5",
    "bucket_3_1",
    "bucket_3_2",
    "bucket_3_3",
    "bucket_3_4",
    # "bucket_4_1"
]


def check_if_exist(topology, repo_path):
    return os.path.exists(f"{repo_path}{topology}")


class Topology:

    def __init__(self, tl_hostname: int, path_to_repo: int, verbose=True):
        self.verbose = verbose
        self.tl_hostname = tl_hostname
        self.topology_details = tl_dict[self.tl_hostname]
        self.label = tl_dict[self.tl_hostname]["topology"]
        self.path_to_repo = path_to_repo
        self.path_to_topology = path_to_repo + self.label
        self.config = tl_dict[self.tl_hostname]["config"]
        self.releases = self.get_releases()
        self.path_to_swconfig = self.get_path_to_swconfig()

    def get_releases(self):
        return [release for release in os.listdir(self.path_to_topology)
                if os.path.isdir(os.path.join(self.path_to_topology, release))]

    def get_path_to_swconfig(self):
        if self.config == "common":
            return {host: [f"{self.path_to_topology}/{release}/{host}" for release in self.releases]
                    for host in self.topology_details["bts"]}
        else:
            return {self.tl_hostname: [f"{self.path_to_topology}/{release}" for release in self.releases]}

    def copy_swconfig(self):
        _counter = 0
        for tl, paths in self.get_path_to_swconfig().items():
            tl_config = tl_dict[tl]["config"]
            for _path in paths:
                swconfig = "swconfig_ald.txt" if tl_dict[tl]["ald"] else "swconfig.txt"
                if self.verbose:
                    print(f"copy {swconfig} -> {_path}/swconfig.txt")
                # shutil.copyfile(swconfig, f"{_path}/swconfig.txt")
                _counter += 1
                if tl_config in ["fullrack", "4+3", "kraken"]:
                    swconfig_sec = "swconfig_secondary_ald.txt" if tl_dict[tl]["ald"] else "swconfig_secondary.txt"
                    if self.verbose:
                        print(f"copy {swconfig_sec} -> {_path}/swconfig_secondary.txt")
                    # shutil.copyfile(swconfig_sec, f"{_path}/swconfig_secondary.txt")
                    _counter += 1
        return _counter


# Topology("1_16_UTESRAN3223", topology_conf).copy_swconfig()
# print(check_if_exist(tl_dict["bucket_4_1"]['topology'], topology_conf))
# if __name__ == "__main__":
#     counter = 0
#     for line in test_lines:
#         counter += Topology(line, topology_conf).copy_swconfig()
#     print(f"{counter} files have been copied")

# scope =""
# for tl in test_lines:
#     scope += f"file[topology-configs]:{tl_dict[tl]['topology']}//*||"
# print(scope)
