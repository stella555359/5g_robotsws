#!/bin/sh

jdk_table_path="/home/ute/.config/JetBrains/PyCharmCE2023.1/options/jdk.table.xml"
project_default_path="/home/ute/.config/JetBrains/PyCharmCE2023.1/options/project.default.xml"
filetypes="/home/ute/.config/JetBrains/PyCharmCE2023.1/options/filetypes.xml"

name_original="2.7.11 (/opt/ute/python/bin/python2.7)"
ver_original="2.7.17"
homepath_original="/opt/ute/python/bin/python2.7"

name_to_replace="3.9 (test_repo)"
ver_to_replace="3.9"
homepath_to_replace="\$USER_HOME$/test_repo/bin/python3.9"

sed -i "0,\@$name_original@{s@$name_original@$name_to_replace@g}" $jdk_table_path && sed -i "0,\@$homepath_original@{s@$homepath_original@$homepath_to_replace@g}" $jdk_table_path && sed -i "0,\@$ver_original@{s@$ver_original@$ver_to_replace@g}" $jdk_table_path

sed -i "s@$name_original@$name_to_replace@g" $project_default_path && sed -i "s@$homepath_original@$homepath_to_replace@g" $project_default_path

sed -i '6i\      <mapping ext="robot" approved="true" type="Robot Feature" />' $filetypes

nohup /opt/pycharm/bin/pycharm.sh /home/ute/robotws/ > /dev/null 2>/dev/null &

