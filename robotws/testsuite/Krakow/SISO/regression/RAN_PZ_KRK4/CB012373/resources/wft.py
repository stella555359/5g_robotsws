from taf.rfrl.procedures.resources.python.wft.remote_api import BuildEndpoint


def compare_subbuilds(source_asihub, target_asihub):
    """
    Check ASIHUB builds are not the same.

    :param source_asihub: dict with source asihub builds
    :param target_asihub: dict with target asihub builds
                          e.g. {'ASIHUB': 'ASIHUB25.01.R01', 'ASIHUB2.0': 'ASIHUB2.0_24.12.R21'}
    """
    if len(dict(set(source_asihub.items()) - set(target_asihub.items()))) < 2:
        raise WrongASIHUBBuild("The same ASIHUB SW Version for SOURCE SW ({}) and TARGET SW ({})"
                               .format(source_asihub, target_asihub))


def get_asihub_versions_from_wft(sw_version):
    """
    Get ASIHUB and ASIHUB2.0 SW version

    :param sw_version: SBTS SW version
    """
    if "ENB_999" in sw_version:
        sw_version = "SBTS00_" + sw_version.split("_", 1)[-1]
    sub_builds = BuildEndpoint(project="5G", component="BTS", version=sw_version).sub_builds()
    return extract_asihub_versions_from_sub_builds(sub_builds)


def extract_asihub_versions_from_sub_builds(sub_builds):
    """
    Extract ASIHUB and ASIHUB2.0 SW version from SBTS build subbuilds

    :param sub_builds: SBTS SW subbuilds
    """
    asihub = dict()
    components = ['ASIHUB', 'ASIHUB2.0']
    for component in sub_builds:
        if component['component'] in components:
            asihub[component['component']] = component['version']
    return asihub


class WrongASIHUBBuild(Exception):
    pass
