Readme for XP lua archived on Git
==================================

https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=911374906

XpShark_4.6.0 => src

21/03/2022 : XpShark_4.6.0 replace by XpShark_4.9.2

cd robotws5g/testsuite/Paris/RRM/ET/resources/DSS/XpShark/9.1800.330

zip all src/* (XpShark_4.6.0 luashark) to generated_luashark-9.1800.330.zip
============
make implode

unzip generated_luashark-9.1800.330.zip to src dir
=============
make explode

==================================
to solve tab issue with Makefile

cat -e -t -v Makefile

make has a very stupid relationship with tabs. All actions of every rule are identified by tabs. And, no, four spaces don't make a tab. Only a tab makes a tab.
To check, I use the command cat -e -t -v makefile_name.
It shows the presence of tabs with ^I and line endings with $. Both are vital to ensure that dependencies end
properly and tabs mark the action for the rules so that they are easily identifiable to the make utility.

==================================
