from robot.libraries.XML import XML


def get_att_with_rf(tl_description_path, serial_num, pipes):
    rfs = {"serial_num": serial_num, "pipes": pipes, "att": {}}
    pa_list = []
    for pipe in pipes:
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Port'. \
            format(serial_num, pipe)
        os_att_port_id = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                           expression=expression)
        if not os_att_port_id:
            continue
        os_att_port_id = os_att_port_id[0]
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Number'. \
            format(serial_num, pipe)
        os_att_number_id = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                             expression=expression)[0]

        expression = '//Unit[@Type="ATT"][@Number="{}"]/Attenuator/@IP'. \
            format(os_att_number_id)
        ip = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                               expression=expression)[0]

        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Enable'. \
            format(serial_num, pipe)
        os_att_enable = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                          expression=expression)[0]
        expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Disable'. \
            format(serial_num, pipe)

        os_att_disable = XML(use_lxml=True).evaluate_xpath(source=tl_description_path,
                                                           expression=expression)[0]
        # print "----------------------"
        # print os_att_port_id, os_att_number_id, os_att_enable, os_att_disable
        # print "----------------------"
        if os_att_number_id not in rfs["att"].keys():
            rfs["att"][os_att_number_id] = {}
            # rfs["att"]["ip"] = ip
            rfs["att"][os_att_number_id]["ports"] = []
            rfs["att"][os_att_number_id]["port_id_list"] = []
            pa_list.append(ip)
        if os_att_port_id in rfs["att"][os_att_number_id]["port_id_list"]:
            continue
        rfs["att"][os_att_number_id]["port_id_list"].append(os_att_port_id)
        rfs["att"][os_att_number_id]["ports"].append({"port": os_att_port_id, "enable": os_att_enable,
                                                      "disable": os_att_disable})
    return rfs, pa_list


def get_bar_cell_by_pa_config(tl_description_path, test_cell, all_cell_list):
    bar_cell_list = []
    test_serial_num = test_cell["RF"][0]["serialNumber"]
    test_pipe = test_cell["RF"][0]["antl"][0]
    expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Port'. \
        format(test_serial_num, test_pipe)
    enable_att_port = XML(use_lxml=True).evaluate_xpath(source=tl_description_path, expression=expression)
    for cell_info in all_cell_list:
        if cell_info["phyCellId"] == test_cell["phyCellId"] or cell_info['btsId'] != test_cell['btsId']:
            continue
        serial_num = cell_info["RF"][0]["serialNumber"]
        pipes = cell_info["RF"][0]["antl"]
        for pipe in pipes:
            expression = '//Unit[@Type="FR"][@SerialNumber="{}"]/Attenuator[@PipeNumber="{}"]/@Port'. \
                format(serial_num, pipe)
            get_att_port = XML(use_lxml=True).evaluate_xpath(source=tl_description_path, expression=expression)
            if len(get_att_port) < 1:
                continue
            if get_att_port[0] in enable_att_port:
                bar_cell_list.append(cell_info)
    return bar_cell_list
