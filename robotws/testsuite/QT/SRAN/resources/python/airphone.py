import yaml


def check_if_tl_reports_to_wft(path, tl, stream_version):
    with open('{}/PipelineConfiguration/QT/{}.yaml'.format(path, stream_version)) as yaml_content:
        data = yaml.load(yaml_content, Loader=yaml.FullLoader)
        try:
            testline = data['qt']['testline'][tl]
        except KeyError as e:
            return False
        if testline['pipeline_skip']:
            if 'wft' in testline['pipeline_skip']:
                return tl
        return False


def get_config_filename(ap_gnb, configuration, path):
    with open('{}/config.yaml'.format(path)) as f:
        data = yaml.load(f, Loader=yaml.FullLoader)

    conf = configuration.split('_')
    duplex = conf[3]
    gNB_common_unit = conf[1]
    gNB_capacity_unit = conf[2]
    fh_mode = conf[4]
    rf_mode = conf[5]

    for item in data['configs']:
        if item['duplex'] == duplex and item['FH_mode'] == fh_mode and item['RF_mode'] == rf_mode \
                and item['gNB_common_unit'] == gNB_common_unit and gNB_capacity_unit in item['gNB_capacity_unit']:
            try:
                swconf = item['paths'][ap_gnb]
                return swconf
            except KeyError:
                return


def get_config_filename_new_repo(file_type, hw_type, configuration, path):
    with open('{}/config.yaml'.format(path)) as f:
        data = yaml.load(f, Loader=yaml.FullLoader)

    for key in data['variants']:
        if key['name'] == configuration:
            for nodes in key['nodes']:
                for f_type in nodes['files']:
                    if f_type['file_type'] == file_type and f_type['hw_type'] == hw_type:
                        try:
                            path = f_type['file_path']
                            return path
                        except KeyError:
                            return
