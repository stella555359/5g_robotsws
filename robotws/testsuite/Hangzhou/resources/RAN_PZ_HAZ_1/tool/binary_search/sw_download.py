import subprocess
import os


def sw_download(sw_version, target_dir, package_type="Normal", package_variant="A54", timeout=3600):
    # url = "http://files.ute.nsn-rdnet.net/builds/enb/base/{}/{}_release_BTSSM_downloadable{}.zip"
    artifactory_hz = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
    url_wft = "{base}/{release}/{build}/{build}_release_BTSSM_downloadable{pack_type}_{pack_variant}.zip"
    release = sw_version.split("_")[0]
    suffix = ""
    if package_type == "T1":
        suffix = "_testpackage_T1"
    if package_type == "T2":
        suffix = "_testpackage_T2"

    if package_type == "CMCC":
        suffix = "_CMCC"
        package_variant = "A50"
    elif package_type == "E":
        package_variant += "E"

    # if package_type == "Normal" and package_variant == "A54":
    #     package_url = url.format(sw_version, sw_version, suffix)
    # else:
    package_url = url_wft.format(base=artifactory_hz,
                                 release=release,
                                 build=sw_version,
                                 pack_type=suffix,
                                 pack_variant=package_variant)
    print(package_url)
    wget_cmd = ['timeout', str(timeout), 'wget', '-P', str(target_dir), str(package_url)]
    proc = subprocess.Popen(wget_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    if proc.returncode != 0:
        raise Exception('Software package has not been downloaded.\n STDOUT: {}\n STDERR: {}\n RETURN_CODE: {}'.
                        format(out, err, proc.returncode))

    return os.path.join(target_dir, package_url.split("/")[-1])
