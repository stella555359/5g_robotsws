import os
# import yaml
import shutil
from test_lines import tl_dict

path_to_topolory_config = "C:/Users/starzyk/repo/topology-configs/"
common_label = 'CLOUD_NL_ASIA_ABIA_ASIK_ABIL_AHLOA_UTECA'
tl_in_scope = [
    # ['tl_hostname', 'tl_topology'],
    ["1_16_UTESRAN2091", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_4_UTECA"],
    ["1_16_UTESRAN2092", 'CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_1_UTECA'],
    ["1_16_UTESRAN2093", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_2_UTECA"],
    ["1_16_UTESRAN2096", "CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_3_UTECA"],
]


class CommonLabelator:

    def __init__(self, label: str, tl: list, path_to_repo: str, verbose: bool):
        self.common_label = label
        self.tl = tl
        self.path_to_repo = path_to_repo
        self.verbose = verbose

    def check_if_exist(self, file_name):
        return os.path.isdir(f"{self.path_to_repo}{file_name}")

    def check_releases(self, topology):
        return [release for release in os.listdir(f"{self.path_to_repo}{topology}")]

    def make_new_dir(self, direction):
        if not os.path.exists(f"{direction}"):
            if self.verbose:
                print(f"MKDIR: {direction}")
            os.mkdir(direction)

    def adjust_yaml(self, path, common_label, sub_label):
        hook = '''
ute_ca_hooks:
  pre_sw_uploaded:
    package: "ute-ca-hook-common-label"
    entrypoint: "ute-ca-hook-common-label"
'''
        try:
            with open(path, 'a') as common_yaml:
                common_yaml.write(hook)
            if self.verbose:
                print("ute_ca_hooks successfully added to config.yaml")
            with open(path, 'r') as yaml:
                common_yaml = yaml.read()
            if common_label in common_yaml:
                print("jest")
            common_yaml = common_yaml.replace(sub_label, common_label)
            with open(path, 'w') as yaml:
                yaml.write(common_yaml)
        except Exception as e:
            print(f"Error: {e}")

    def check_if_common_label_exist(self):
        if self.check_if_exist(self.common_label):
            if self.verbose:
                print(f"{label.common_label} is already exist in the topology config")
        else:
            self.make_new_dir(f"{self.path_to_repo}{self.common_label}")

    def copy_file(self, src, dest):
        if self.verbose:
            print("COPYING: " + src + " TO " + dest)
        shutil.copyfile(src, dest)

    def create_sub_topology(self):
        for test_line in self.tl:
            releases = self.check_releases(f"{test_line[1]}")
            print(releases)
            for release in releases:
                if not self.check_if_exist(f"{self.common_label}/{release}"):
                    self.make_new_dir(f"{self.path_to_repo}{self.common_label}/{release}")
                if not os.path.isfile(f"{self.path_to_repo}{self.common_label}/{release}/config.yaml"):
                    self.copy_file(
                        f"{self.path_to_repo}{test_line[1]}/{release}/config.yaml",
                        f"{self.path_to_repo}{self.common_label}/{release}/config.yaml"
                    )
                    self.adjust_yaml(
                        f"{self.path_to_repo}{self.common_label}/{release}/config.yaml", self.common_label, test_line[1]
                    )
                if not self.check_if_exist(f"{self.common_label}/{release}/{test_line[0]}"):
                    self.make_new_dir(f"{self.path_to_repo}{self.common_label}/{release}/{test_line[0]}")
                files = [file.name for file in os.scandir(f"{self.path_to_repo}{test_line[1]}/{release}")]
                for file in files:
                    if file != "config.yaml":
                        self.copy_file(
                            f"{self.path_to_repo}{test_line[1]}/{release}/{file}",
                            f"{self.path_to_repo}{self.common_label}/{release}/{test_line[0]}/{file}"
                        )


# label_topo = CommonLabelator(common_label, tl_in_scope,path_to_topolory_config, True)
# print(label_topo.check_releases("CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQQA_1AHLOB_1AVQL_UUF_1_UTECA"))
# print(label_topo.check_releases("CLOUD_SRAN_NL_2ASIM_1ABIO_1ABIQ_3ABIP_1AZHA_1AQQQA_1AHLOB_1AVQL_UUF_1_UTECA/SBTS00"))


if __name__ == '__main__':
    label = CommonLabelator(common_label, tl_in_scope, path_to_topolory_config, True)
    label.check_if_common_label_exist()
    label.create_sub_topology()
