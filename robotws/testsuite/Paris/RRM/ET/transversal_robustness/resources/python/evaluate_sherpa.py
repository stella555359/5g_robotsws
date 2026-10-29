import json
import os
import sys
import itertools

context = {}


def initialize_context():
    context['error_list'] = []
    context['warning_list'] = {}
    context['frame_number'] = 1
    context['message_type'] = {}
    context['number_of_trace_loss'] = 0
    context['trace_seq_num'] = {}
    context['number_of_ae_blocs'] = 0
    context['event_id_distribution'] = {}
    context['event0'] = {'nb_of_sfn_0': 0}
    context['event9'] = {'nb_of_srBit_1': 0, 'nb_of_srBit': 0, 'nb_of_uciBits_0': 0, 'nb_of_uciBits': 0}


def append_error(error):
    error_string = f"frame {context['frame_number']}: " + error.strip().replace('"', "'")
    if len(context['error_list']) < 10:
        context['error_list'].append(error_string)
    else:
        context['error_list'][9] = 'Other errors occurred but list is full'


def check_error(locals, expression):
    if eval(expression, None, locals):
        append_error(expression)


def append_warning(warning):
    warning_string = warning.strip().replace('"', "'")
    if warning_string not in context['warning_list']:
        context['warning_list'][warning_string] = 0
    context['warning_list'][warning_string] += 1


def check_warning(reason_why_it_is_not_an_error, locals, expression):
    if eval(expression, None, locals):
        if expression not in context['warning_list']:
            context['warning_list'][expression] = 0
        context['warning_list'][expression] += 1


def final_checks_for_all_event_mode():
    check_error(None, "context['event_id_distribution']['0'] != context['number_of_ae_blocs']")
    check_error(None, "context['event_id_distribution']['9'] == 0")
    check_error(None, "context['event_id_distribution']['19'] == 0")
    check_error(None, "context['event0']['nb_of_sfn_0'] > 0.1 * context['number_of_ae_blocs']")
    check_error(None, "context['event9']['nb_of_srBit_1'] > 0.9 * context['event9']['nb_of_srBit']")
    check_warning('Action #540', None,
                  "context['event9']['nb_of_uciBits_0'] > 0.9 * context['event9']['nb_of_uciBits']")


def final_checks():
    check_error(None, f"context['frame_number'] < 2")
    trace_loss_limit = 2
    check_error(locals(), f"{100 * context['number_of_trace_loss'] / context['frame_number']} > trace_loss_limit")
    if context['number_of_ae_blocs'] != 0:
        final_checks_for_all_event_mode()


def decode_pcap_to_json(pcap_file_name):
    print(f'decoding {pcap_file_name}')
    os.system('tar xzf /opt/Nokia/Sherpa_5G_18/data/interfaces_lua.7z -C /tmp')
    json_file_name = pcap_file_name.split('.')[0] + '.json'
    os.system(f'tshark -X lua_script:/tmp/interfaces_lua/luashark.lua -r {pcap_file_name} -T json | ' +
              f'tail -n +9 > {json_file_name}')
    os.system('rm -rf /tmp/interfaces_lua')
    return json_file_name


def transform_in_list(input_list):
    if not isinstance(input_list, list):
        return [input_list]
    else:
        return input_list


def analyze_event0(event):
    # print(f'analyze_event0: {json.dumps(event, indent=1)}')
    if event['DU_L2PS_AE_EVENT_t.sfn'] == '0':
        context['event0']['nb_of_sfn_0'] += 1


def analyze_event09_r0_1(event):
    # print('analyze_event09_r0_1')
    reports = transform_in_list(event['du_l2ps_ae_event09_r0_1_t'])
    # print(f'reports: {json.dumps(reports, indent=1)}')
    for report in reports:
        context['event9']['nb_of_uciBits'] += 1
        if int(report['DU_L2PS_AE_EVENT09_R0_1_t.uciBits'], 16) == 0:
            context['event9']['nb_of_uciBits_0'] += 1
        context['event9']['nb_of_srBit'] += 1
        if report['DU_L2PS_AE_EVENT09_R0_1_t.srBit'] == '1':
            context['event9']['nb_of_srBit_1'] += 1


def analyze_event9(event):
    # print(f'analyze_event9: {json.dumps(event, indent=1)}')
    if 'du_l2ps_ae_event09_r0_1_t' in event:
        analyze_event09_r0_1(event)


def analyze_event61_65(extended_event):
    # print(f'analyze_event61_65: {json.dumps(extended_event, indent=1)}')
    check_error(locals(), "int(extended_event['DU_L2PS_AE_EVENT61_65_R_t.bandwidth']) >= 17")


def analyze_event61_70(extended_event):
    # print(f'analyze_event61_70: {json.dumps(extended_event, indent=1)}')
    check_error(locals(), "int(extended_event['DU_L2PS_AE_EVENT61_70_R_t.bwUL']) >= 17")


def analyze_event61(event):
    # print('analyze_event61')
    if event['DU_L2PS_AE_EVENT_t.ExtendedEventId'] == '65':
        analyze_event61_65(event['du_l2ps_ae_event61_65_r_t'])
    elif event['DU_L2PS_AE_EVENT_t.ExtendedEventId'] == '70':
        analyze_event61_70(event['du_l2ps_ae_event61_70_r_t'])


def analyze_du_l2ps_ae_t(decoded_structure):
    # print('analyze_du_l2ps_ae_t')
    check_error(locals(), "int(decoded_structure['DU_L2PS_AE_t.nodeId'], 16) == 0")
    blocs = transform_in_list(decoded_structure['du_l2ps_ae_bloc_t'])
    check_error(locals(), "len(blocs) == 0")
    for bloc in blocs:
        context['number_of_ae_blocs'] += 1
        events = transform_in_list(bloc['du_l2ps_ae_event_t'])
        for event in events:
            event_id = event['DU_L2PS_AE_EVENT_t.EventId']
            if event_id not in context['event_id_distribution']:
                context['event_id_distribution'][event_id] = 0
            context['event_id_distribution'][event_id] += 1
            if event_id == '0':
                analyze_event0(event)
            elif event_id == '9':
                analyze_event9(event)
            elif event_id == '61':
                analyze_event61(event)


def analyze_stream_ind(stream_ind):
    node_id = stream_ind['L2Log_StreamIndSherpa_t.nodeId']
    trace_type = stream_ind['L2Log_StreamIndSherpa_t.traceType']
    trace_name = stream_ind['L2Log_StreamIndSherpa_t.traceName']
    instance_id = 0
    if 'L2Log_StreamIndSherpa_t.instanceId' in stream_ind:
        instance_id = stream_ind['L2Log_StreamIndSherpa_t.instanceId']
    if 'L2Log_StreamIndSherpa_t.l2psInstanceId' in stream_ind:
        instance_id = stream_ind['L2Log_StreamIndSherpa_t.l2psInstanceId']
    full_id = (node_id, trace_type, trace_name, instance_id)
    trace_seq_num = int(stream_ind['L2Log_StreamIndSherpa_t.traceSeqNum'])
    if full_id in context['trace_seq_num']:
        number_of_trace_loss = trace_seq_num - (context['trace_seq_num'][full_id] + 1)
        if number_of_trace_loss > 0:
            print(f'stream_ind: {json.dumps(stream_ind, indent=1)}')
            print(f'number_of_trace_loss: {number_of_trace_loss}')
        context['number_of_trace_loss'] += number_of_trace_loss
    if trace_seq_num == 65535:
        trace_seq_num = -1
    context['trace_seq_num'][full_id] = trace_seq_num


def analyze_packet(packet):
    lua_data = packet['_source']['layers']['l2_stream_sherpa']['_ws.lua.text']
    if len(lua_data) >= 2:
        if 'l2log_streamindsherpa_t' in lua_data[1]:
            analyze_stream_ind(lua_data[1]['l2log_streamindsherpa_t'])
    if len(lua_data) >= 3:
        for key in lua_data[2]:
            decoded_structure = lua_data[2][key]
            if key not in context["message_type"]:
                context["message_type"][key] = 0
            context["message_type"][key] += 1
            if key == 'du_l2ps_ae_t':
                analyze_du_l2ps_ae_t(decoded_structure)
    if len(lua_data) > 3:
        print(json.dumps(lua_data, indent=1))
        raise BaseException("len(lua_data) > 3")


def custom_hook(pairs):
    def _key(pair):
        (k, v) = pair
        return k

    def g_pairs():
        for (k, group) in itertools.groupby(pairs, _key):
            ll = [v for (_, v) in group]
            (v, *extra) = ll
            yield k, ll if extra else v

    return dict(g_pairs())


def analyze_raw_line(line):
    forbidden_patterns = [
        'Error',
        '.sci": "255"', '.sci": "0"',
        '.SCI_DL": "255"', '.SCI_DL": "0"',
        '.sciUL": "255"', '.sciUL": "0"',
    ]
    for forbidden_pattern in forbidden_patterns:
        if forbidden_pattern in line:
            append_error(line)


def analyze_json(json_file_name):
    print(f'analyzing {json_file_name}')
    json_file = open(json_file_name, 'r')
    buffer = ''
    line = json_file.readline()
    while line:
        analyze_raw_line(line)
        if line.startswith('  {'):
            buffer = ''
        if line.startswith('  }'):
            buffer += '  }'
            json_data = json.loads(buffer, object_pairs_hook=custom_hook)
            analyze_packet(json_data)
            context['frame_number'] += 1
        buffer += line
        line = json_file.readline()
    json_file.close()


def evaluate_sherpa(pcap_file_name):
    initialize_context()
    json_file_name = decode_pcap_to_json(pcap_file_name)
    analyze_json(json_file_name)
    final_checks()
    print(f"message_type: {json.dumps(context['message_type'], indent=1)}")
    print(f"event_id_distribution: {json.dumps(context['event_id_distribution'], indent=1)}")
    print(f"warning_list: {json.dumps(context['warning_list'], indent=1)}")
    print(f"error_list: {json.dumps(context['error_list'], indent=1)}")
    return context['error_list'], json.dumps(context['message_type'], indent=1)


if __name__ == '__main__':
    evaluate_sherpa(sys.argv[1])
