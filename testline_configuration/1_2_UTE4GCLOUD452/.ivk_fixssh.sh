#!/usr/bin/expect
set timeout 2
spawn ssh-copy-id toor4nsn@192.168.255.129
expect {
    "Password" {
        send "oZPS0POrRieRtu\r"
        exp_continue
            }
    "Now try logging into the machine" {
            send "\r"
            }
    }
       interact
