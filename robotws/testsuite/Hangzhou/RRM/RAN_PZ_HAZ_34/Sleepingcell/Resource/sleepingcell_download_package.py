import hashlib
import os
import requests
import time

__all__ = ['download_package', 'download_package_and_check_sha256']


arti_hz_sbts_base = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local"
lterel_base = "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
wft_base = "https://wft.int.net.nokia.com:8091/api/v1/SBTS/CI_ENB/builds"


def get_arti_full_url(sw_version):
    release = sw_version.split("_")[0]
    if 'ENB_9999' in sw_version:
        release_path = 'SBTS00_packages'
        package = sw_version.replace(release, 'SBTS00')
    else:
        release_path = release + '_packages'
        package = sw_version
    package_name = package + '_release_BTSSM_downloadable_A54.zip'
    full_url = arti_hz_sbts_base + '/' + release_path + '/' + package + '/' + package_name
    return full_url, package_name


def get_lterel_full_url(sw_version):
    release = sw_version.split("_")[0]
    if 'ENB_9999' in sw_version:
        release_path = 'SBTS00'
        package = sw_version.replace(release, 'SBTS00')
    else:
        release_path = release
        package = sw_version
    package_name = package + '_release_BTSSM_downloadable_A54.zip'
    full_url = lterel_base + '/' + release_path + '/' + package_name
    return full_url, package_name


def download(link, file_path, timeout=600):
    r = requests.get(link, stream=True, timeout=timeout)
    if r.status_code == 200:
        print("request package successful!: {}".format(link))
    else:
        print("request package failed!: {}".format(link))
        return False
    with open(file_path, 'wb') as f:
        for chunk in r.iter_content(1024):
            if chunk:
                f.write(chunk)
    os.path.exists(file_path)
    return True


def build_checksum(sw_version):
    release = sw_version.split("_")[0]
    if 'ENB_9999' in sw_version:
        package = sw_version.replace(release, 'SBTS00')
    else:
        package = sw_version
    url = wft_base + '/{}/storages/results.json?access_key=wuGTESBtvNFDlFK4gTXgiHJ6TLBqOwux5W8T4Fhh'.format(package)
    try:
        checksum_data = requests.get(url, verify=False)
    except Exception as ex:
        print(ex)
        raise FileNotFoundError('{} not accessible'.format(url))
    else:
        if checksum_data.status_code == 200:
            all_checksum = checksum_data.json()[1]['storage']['storage-items']
            for item in all_checksum:
                if '{}_release_BTSSM_downloadable_A54.zip'.format(package) == item['title']:
                    return item['hashes']['sha256']
            raise FileNotFoundError('{url} not accessible'.format(url=url))


def verifyCheckSum(file_path, checksum):
    with open(file_path, "rb") as f:
        sha256_hash = hashlib.sha256()
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
        print(sha256_hash.hexdigest(), checksum)
        if sha256_hash.hexdigest() == checksum:
            return True
        else:
            return False


def download_package(sw_version, save_path):
    full_url, package_name = get_arti_full_url(sw_version=sw_version)
    file_path = save_path + '/' + package_name
    flag = download(link=full_url, file_path=file_path)
    if not flag:
        full_url, package_name = get_lterel_full_url(sw_version=sw_version)
        file_path = save_path + '/' + package_name
        flag = download(link=full_url, file_path=file_path)
    assert flag
    return file_path


def download_package_and_check_sha256(sw_version, save_path):
    file_path = download_package(sw_version=sw_version, save_path=save_path)
    checksum = build_checksum(sw_version=sw_version)
    check_flag = verifyCheckSum(file_path=file_path, checksum=checksum)
    if not check_flag:
        os.remove(file_path)
        file_path = download_package(sw_version=sw_version, save_path=save_path)
        check_flag = verifyCheckSum(file_path=file_path, checksum=checksum)
    assert check_flag, 'package also incomplete after download twice'
    return file_path


# if __name__ == '__main__':
#     sw_version = 'SBTS22R3_ENB_0000_000242_000000'
#     save_path = 'C:\\ztt\\07_package\\'
#     file_path = download_package(sw_version=sw_version, save_path=save_path)
#     print(file_path)
