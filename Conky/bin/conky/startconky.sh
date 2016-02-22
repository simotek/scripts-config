#!/bin/bash
sleep 15
conky -c ~/src/config/scripts-config/Conky/Conky/cpu &
sleep 1
conky -c ~/src/config/scripts-config/Conky/Conky/mem &
sleep 5
conky -c ~/src/config/scripts-config/Conky/Conky/rings &
sleep 30
#conky -c ~/src/config/scripts-config/Conky/Conky/weather &
sleep 1
#conky -c ~/src/config/scripts-config/Conky/Conky/mail
