python create_suitemapping_file_from_local_path_guanxiaobin.py "$1"
python "pickup.py"  -r "$1/" \
        -p "suitemapping.csv"  -d  /home/ute/pick_logs --robot_opt "-L TRACE -v REMOVE_LOGS:off" --case_type stability

