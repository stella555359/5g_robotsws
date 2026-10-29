import json
import os
import socket
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_utilities import robot_kw, robot_logger


@robot_kw
def get_scout_hostname():
    # get the hostname
    hostname = socket.gethostname()
    # replace all dashes with underscores
    processed_hostname = hostname.replace('-', '_')
    robot_logger("Processed hostname: {}".format(processed_hostname), 'INFO', True)
    return processed_hostname


@robot_kw
def get_source_build():
    cm_artifacts = json.loads(os.getenv("CM_ARTIFACTS", "[]"))
    robot_logger("CM artifacts: {}".format(cm_artifacts), 'INFO', True)
    cm_tags = json.loads(os.getenv("CM_TAGS", "[]"))
    robot_logger("CM tags: {}".format(cm_tags), 'INFO', True)
    build = ""
    if any("UUF_CUSTOMER" in tag for tag in cm_tags):
        robot_logger("UUF_CUSTOMER TAG DETECTED", 'INFO', True)
        for artifact in cm_artifacts:
            try:
                if artifact['properties']['upgrade_path']['customer_deployments']:
                    for key in artifact['properties']['upgrade_path']['customer_deployments']:
                        if key['customer'].upper() == (get_cm_tag("UUF_CUSTOMER").split("=", 1)[1]).upper():
                            for sub_key in key['deployments']:
                                if sub_key['uuf_configuration_id'] == int(
                                        get_cm_tag("UUF_CONFIGURATION").split("=", 1)[1]):
                                    build = sub_key['source_sw_build'].upper()
            except KeyError:
                pass
    elif any('UPDATE_PATH' in tag for tag in cm_tags):
        robot_logger("UPDATE PATH TAG DETECTED", 'INFO', True)
        update_path_nr = [el.split('=')[1] for el in cm_tags if 'UPDATE_PATH' in el][0]
        robot_logger("SELECTED PATH {}".format(update_path_nr), 'INFO', True)
        for artifact in cm_artifacts:
            try:
                if artifact['properties']['upgrade_path']['product_defaults']:
                    build = (artifact['properties']['upgrade_path']['product_defaults'][update_path_nr]).upper()
            except KeyError:
                pass
    else:
        raise Exception("No required artifacts found in environment variables! "
                        "Probably not promoted trunk build OR suite used without proper tags")

    if not build:
        raise Exception("No selected build found!")
    else:
        return build


@robot_kw
def get_target_build():
    cm_artifacts = json.loads(os.getenv("CM_ARTIFACTS", "[]"))
    build = ""
    for artifact in cm_artifacts:
        if artifact['type'].upper() == "BUILD":
            build = artifact["name"].upper()
    if not build:
        raise Exception("No selected build found!")
    else:
        return build


@robot_kw
def get_cm_tag(pattern):
    cm_tags = json.loads(os.getenv("CM_TAGS", "[]"))
    tags = [tag for tag in cm_tags if tag.startswith(pattern)]
    if len(tags) > 1:
        robot_logger("No tag found", 'INFO', True)
    elif len(tags) == 1:
        return tags[0].upper()
    return None
