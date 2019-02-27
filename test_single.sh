#!/bin/bash

git clone https://github.com/inmanta/quickstart.git
cd quickstart

inmanta-cli project create -n test
inmanta-cli environment create -n quickstart-env -p test -r https://github.com/inmanta/quickstart.git -b master --save
inmanta-cli environment setting set -e quickstart-env -k autostart_agent_deploy_splay_time -o 1

inmanta -vvv export -f single_machine.cf -d
while inmanta-cli version list -e quickstart-env | grep deploying; do sleep 1; done

