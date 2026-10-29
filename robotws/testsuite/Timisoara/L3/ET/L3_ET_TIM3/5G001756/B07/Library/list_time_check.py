# this job will loop every record_time to check whether is exist between every pair of request and response

def check_efficent_record_between_frame_gap(request_time_list, response_time_list, record_time_list):
    request_list = [int(i) for i in request_time_list]
    response_list = [int(i) for i in response_time_list]
    record_list = [int(i) for i in record_time_list]
    request_list.sort()
    response_list.sort()
    record_list.sort()
    record_list_loop = record_list.copy()
    request_available_return = []
    record_not_found_request = request_list.copy()
    response_available_return = []
    record_available_return = []
    for index, value in enumerate(response_list):
        for record_index in record_list_loop:
            if record_index > response_list[index] or record_index <= request_list[index]:
                continue
            else:
                # print(f"found record record num{record_index} between {request_list[index]}&{response_list[index]}")
                record_list_loop.remove(record_index)
                request_available_return.append(request_list[index])
                record_not_found_request.remove(request_list[index])
                response_available_return.append(response_list[index])
                record_available_return.append(record_index)
    return request_available_return, response_available_return, record_available_return, record_not_found_request


# request_time_list = [33, 55, 216]
# response_time_list = [80, 236]
# record_time_list = [22, 72, 191, 225]
#
# check_efficent_record_between_frame_gap(request_time_list, response_time_list,record_time_list)

def find_nearby_frame(request_frame_list, response_frame_list):
    request_list = [int(i) for i in request_frame_list]
    response_list = [int(i) for i in response_frame_list]
    response_return = []
    for i in request_list:
        for j in response_list:
            if j-i > 0:
                response_return.append(j)
                break
    return response_return

#
# request_time_list = ['26200', '36673', '44336', '46400']
# response_time_list = ['4982', '5024', '5048', '5228', '5573', '5851', '26242', '27208',
#                       '27237', '27447', '36770', '37742', '37767', '37884', '44381', '45337', '45354',
#                       '45602', '46499', '47400', '47422', '47615', '49936', '50041']
#
# find_nearby_response(request_time_list,response_time_list)
