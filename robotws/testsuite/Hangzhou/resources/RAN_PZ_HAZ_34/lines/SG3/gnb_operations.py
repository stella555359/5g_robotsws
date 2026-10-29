# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/3/8 14:51
import json

from Common_setup_and_teardown import OperateGnb

bts_op = OperateGnb()


def multi_bts_upgrade():
    bts_op.bts_upgrade_threading()


def multi_bts_rollback():
    bts_op.bts_rollback_threading()


def multi_bts_reset():
    bts_op.bts_reset_threading()


def download_packages_to_ute():
    bts_op.download_package_threading()


def upgrade_rollback_reset():
    bts_op.upgrade_rollback_reset()


def multi_bts_commission(index_list,
                         scf_list,
                         skip_parameter_relation_errors=True,
                         timeout=600,
                         bts_type='gnb',
                         is_pdl_checking_needed=True):
    bts_op.bts_commission_threading(index_list=index_list,
                                    scf_list=scf_list,
                                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                                    timeout=timeout,
                                    bts_type=bts_type,
                                    is_pdl_checking_needed=is_pdl_checking_needed)


def check_gnb_release_for_counter_path(release_info="SBTS24R2_ENB_9999",
                                       release_year_diff=24,
                                       release_num_diff=1):
    release_year = release_info.split("_")[0][4:].split("R")[0]
    release_num = release_info.split("_")[0][4:].split("R")[1]
    print(release_year, release_num)
    if ((int(release_year) >= release_year_diff and int(release_num) > release_num_diff)
            or (int(release_year) > release_year_diff and int(release_num) >= release_num_diff)):
        return True
    else:
        return False


def paras_convert_to_json_file(data, json_path):
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
