#!/bin/bash

GITHUB_PROXY="$1"
if [[ -n "$GITHUB_PROXY" && "$GITHUB_PROXY" != */ ]]; then
    GITHUB_PROXY+="/"
fi
export GITHUB_PROXY

set -e
set -v on

rm -rf works
mkdir -p works
cd works
mkdir -p downloads
mkdir -p packages
mkdir -p releases

curl -sL 'https://api.github.com/repos/CTCaer/hekate/releases/latest' \
    | jq -r '.assets[] | select(.name | test("hekate_ctcaer_[.\\d]+_Nyx_[.\\d]+(_v\\d+)?.zip")) | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
find 'downloads' -name 'hekate_ctcaer_*.zip' | xargs -I {} unzip -q -u -o -d 'packages' {}

curl -sL 'https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases' \
    | jq -r '.[0].assets[] | select(.name | test("atmosphere-[.\\d]+-(master|prerelease)-\\w+\\+hbl-[.\\d]+\\+hbmenu-[.\\d]+.zip")) | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
find 'downloads' -name 'atmosphere-*.zip' | xargs -I {} unzip -q -u -o -d 'packages' {}

curl -sL 'https://api.github.com/repos/impeeza/sys-patch/releases' \
    | jq -r '.[0].assets[] | select(.name | test("sys-patch(-.*)?.zip")) | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
find 'downloads' -name 'sys-patch*.zip' | xargs -I {} unzip -q -u -o -d 'packages' {}

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_syspatch.zip' . && cd ..

cp -r -f ../configs/* 'packages'
mv -f packages/hekate_ctcaer_*.bin 'packages/payload.bin'

curl -sL 'https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases' \
    | jq -r '.[0].assets[] | select(.name == "fusee.bin") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
cp -f 'downloads/fusee.bin' 'packages/bootloader/payloads/fusee.bin'

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_syspatch_configs.zip' . && cd ..

rm -f 'packages/switch/haze.nro'
rm -f 'packages/switch/reboot_to_payload.nro'
rm -r -f 'packages/switch/.overlays'
mkdir -p 'packages/switch/daybreak' && mv -f 'packages/switch/daybreak.nro' 'packages/switch/daybreak/daybreak.nro'

curl -sL 'https://api.github.com/repos/suchmememanyskill/TegraExplorer/releases/latest' \
    | jq -r '.assets[] | select(.name == "TegraExplorer.bin") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
cp -f 'downloads/TegraExplorer.bin' 'packages/bootloader/payloads/TegraExplorer.bin'

curl -sL 'https://api.github.com/repos/impeeza/Lockpick_RCMDecScots/releases/latest' \
    | jq -r '.assets[] | select(.name == "Lockpick_RCM.zip") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
unzip -q -u -o -d 'packages/bootloader/payloads' 'downloads/Lockpick_RCM.zip'

curl -sL 'https://api.github.com/repos/rashevskyv/DBIPatcher/releases/latest' \
    | jq -r '.assets[] | select(.name | test("DBI.\\d+.en.nro")) | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
mkdir -p 'packages/switch/DBI' && find 'downloads' -name 'DBI.*.nro' | xargs -I {} cp -f {} 'packages/switch/DBI/DBI.nro'

curl -sL 'https://api.github.com/repos/rashevskyv/dbi/releases' \
    | jq ".[] | select(.tag_name | test(\"$(curl -sL 'https://api.github.com/repos/rashevskyv/DBIPatcher/releases/latest' | jq -r '.tag_name')(ru)?\"))"    \
    | jq -r '.assets[] | select(.name == "dbi.config") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
cp -f 'downloads/dbi.config' 'packages/switch/DBI/dbi.config'
sed -i 's/ExitToHomeScreen=true/ExitToHomeScreen=false/' 'packages/switch/DBI/dbi.config'

curl -sL 'https://api.github.com/repos/zdm65477730/NX-Shell/releases/latest' \
    | jq -r '.assets[] | select(.name == "NX-Shell.nro") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
mkdir -p 'packages/switch/NX-Shell' && cp -f 'downloads/NX-Shell.nro' 'packages/switch/NX-Shell/NX-Shell.nro'

curl -sL 'https://api.github.com/repos/WerWolv/Hekate-Toolbox/releases/latest' \
    | jq -r '.assets[] | select(.name == "HekateToolbox.nro") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $GITHUB_PROXY$1 -o downloads/$0'
mkdir -p 'packages/switch/HekateToolbox' && cp -f 'downloads/HekateToolbox.nro' 'packages/switch/HekateToolbox/HekateToolbox.nro'

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_syspatch_configs_tools.zip' . && cd ../..
