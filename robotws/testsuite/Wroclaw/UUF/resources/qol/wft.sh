#!/bin/bash
if ! [[ $1 ]]; then (google-chrome https://wft.int.net.nokia.com &>/dev/null &)
fi
if [[ $1 == '22r1' ]]; then (google-chrome https://wft.int.net.nokia.com/ALL/branches/8000 &>/dev/null &)
fi
if [[ $1 == '22r2' ]]; then (google-chrome https://wft.int.net.nokia.com/SBTS/branches/8330?deliverer=CI_ENB &>/dev/null &)
fi
if [[ $1 == '22r3' ]]; then (google-chrome https://wft.int.net.nokia.com/SBTS/branches/8810?deliverer=CI_ENB_ENB &>/dev/null &)
fi
if [[ $1 == '22r4' ]]; then (google-chrome https://wft.int.net.nokia.com/branches/9112?deliverer=CI_ENB &>/dev/null &)
fi
if [[ $1 == '00' ]]; then (google-chrome https://wft.int.net.nokia.com/SBTS/branches/4581?deliverer=CI_ENB &>/dev/null &)
fi
