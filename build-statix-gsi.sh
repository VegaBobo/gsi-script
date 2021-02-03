#!/bin/bash

mkdir cherish
cd cherish

repo init -u https://github.com/CherishOS/android_manifest.git -b eleven 
mkdir -p .repo/local_manifests
cp ../files/manifest.xml -r .repo/local_manifests/manifest.xml

repo sync -j6 -q

git clone https://github.com/phhusson/treble_experimentations.git
cp ../files/patches-v300l.zip patches.zip
unzip -o patches.zip
bash treble_experimentations/apply-patches.sh .

cd device/phh/treble
git clean -fdx
bash generate.sh cherish
cd ../../..
cp ../files/cherish.mk device/phh/treble

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
    make vndk-test-sepolicy
    make -j6 systemimage
}

. build/envsetup.sh

buildVariant treble_arm64_bvS-userdebug

