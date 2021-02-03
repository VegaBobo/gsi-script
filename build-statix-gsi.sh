#!/bin/bash

mkdir statix
cd statix

repo init -u https://github.com/StatiXOS/android_manifest.git -b 11
mkdir -p .repo/local_manifests
rm .repo/local_manifests/manifest.xml device/phh/treble/statix.mk
cp ../files/manifest.xml .repo/local_manifests/manifest.xml

repo sync --force-sync --no-clone-bundle --current-branch --no-tags -j$(nproc --all)

git clone https://github.com/VegaBobo/treble_experimentations
cp ../files/patches-v300l.zip patches.zip
unzip -o patches.zip
bash treble_experimentations/apply-patches.sh .

cd device/phh/treble
git clean -fdx
cd ../../..
cp ../files/statix.mk device/phh/treble
cd device/phh/treble
bash generate.sh statix

cd packages/services/Telecomm
git revert -m 1 10d34b4e320d3da4e8607724b12ea7e132fe8f5f --no-edit # "Merge tag 'LA.QSSI..."
git fetch https://github.com/LineageOS/android_packages_services_Telecomm
git cherry-pick c1da8a2e63dd3251c328f281227057635bc515da --no-edit # Bluetooth: Support to know if there is High Def call
git cherry-pick 3d64b4ffbacfaee909034ac887c2529e1324281a --no-edit # add support to check if Cs Call InProgress
cd ../Telephony
git revert -m 1 f638fefc91e0682666bff97adaf9d7263e504cd4 --no-edit # telephony: compile fixes ig
git revert -m 1 9fe94a64d41ce4e9ca998f8849918c6ee2d09075 --no-edit # Telephony: Break qti-telephony-framework dependency
git revert -m 1 b601d999911f76f8e0cc21bea0c6d9be0c10398a --no-edit # Merge tag 'LA.QSSI..."
cd ../../../system/core
git am ../../../files/0001-Restore-sbin.patch # AndyCGYan sbin patch (restores sbin folder)
cd ../..

buildVariant() {
    lunch $1
    make installclean
    make -j$(nproc --all) systemimage
    make vndk-test-sepolicy
}

. build/envsetup.sh

buildVariant treble_arm64_bvS-userdebug
buildVariant treble_a64_bvS-userdebug
