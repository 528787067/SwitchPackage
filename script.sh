#!/bin/sh

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
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
find 'downloads' -name 'hekate_ctcaer_*.zip' | xargs -I {} unzip -q -u -o -d 'packages' {}

curl -sL 'https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases' \
    | jq -r '.[0].assets[] | select(.name | test("atmosphere-[.\\d]+-(master|prerelease)-\\w+\\+hbl-[.\\d]+\\+hbmenu-[.\\d]+.zip")) | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
find 'downloads' -name 'atmosphere-*.zip' | xargs -I {} unzip -q -u -o -d 'packages' {}

curl -L 'https://sigmapatches.coomer.party/sigpatches.zip' -o 'downloads/sigpatches.zip'
unzip -q -u -o -d 'packages' 'downloads/sigpatches.zip'

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_sigpatches.zip' . && cd ..

cp -r -f ../configs/* 'packages'
mv -f packages/hekate_ctcaer_*.bin 'packages/payload.bin'

curl -sL 'https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases' \
    | jq -r '.[0].assets[] | select(.name == "fusee.bin") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
cp -f 'downloads/fusee.bin' 'packages/bootloader/payloads/fusee.bin'

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_sigpatches_configs.zip' . && cd ..

rm -f 'packages/switch/haze.nro'
rm -f 'packages/switch/reboot_to_payload.nro'
mkdir -p 'packages/switch/daybreak' && mv -f 'packages/switch/daybreak.nro' 'packages/switch/daybreak/daybreak.nro'

curl -sL 'https://api.github.com/repos/rashevskyv/dbi/releases/latest' \
    | jq -r '.assets[] | select(.name == "DBI.nro") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
curl -sL 'https://api.github.com/repos/rashevskyv/dbi/releases/latest' \
    | jq -r '.assets[] | select(.name == "dbi.config") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
mkdir -p 'packages/switch/DBI'
cp -f 'downloads/DBI.nro' 'packages/switch/DBI/DBI.nro'
cp -f 'downloads/dbi.config' 'packages/switch/DBI/dbi.config'
sed -i 's/ExitToHomeScreen=true/ExitToHomeScreen=false/' 'packages/switch/DBI/dbi.config'

curl -sL 'https://api.github.com/repos/joel16/NX-Shell/releases/latest' \
    | jq -r '.assets[] | select(.name == "NX-Shell.nro") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
mkdir -p 'packages/switch/NX-Shell' && cp -f 'downloads/NX-Shell.nro' 'packages/switch/NX-Shell/NX-Shell.nro'

curl -sL 'https://api.github.com/repos/zdm65477730/Switch-Firmware-Dumper/releases/latest' \
    | jq -r '.assets[] | select(.name == "Firmware-Dumper.zip") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
unzip -q -u -o -d 'packages' 'downloads/Firmware-Dumper.zip'

curl -sL 'https://api.github.com/repos/WerWolv/Hekate-Toolbox/releases/latest' \
    | jq -r '.assets[] | select(.name == "HekateToolbox.nro") | .name, .browser_download_url' \
    | xargs -n2 sh -c 'curl -L $1 -o downloads/$0'
mkdir -p 'packages/switch/HekateToolbox' && cp -f 'downloads/HekateToolbox.nro' 'packages/switch/HekateToolbox/HekateToolbox.nro'

cd 'packages' && zip -q -r '../releases/hekate_atmosphere_sigpatches_configs_tools.zip' . && cd ../..
