#!/bin/bash -e

sudo apt update
sudo apt upgrade
sudo apt install make
sudo apt install build-essential
sudo apt install perl

#编译修改下面四个属性开始
OPENSSL_VERSION=1.1.1t
#NDK23及以后下载和解压需要修改，注意下面注释掉的内容和说明
NDK_VERSION=android-ndk-r22b
ANDROID_TARGET_API=21
#需要编译的架构  如果执行报数组错误  请使用 sudo dpkg-reconfigure dash  出现画面选择 否
ANDROID_ABI_ARRAY=(armeabi-v7a arm64-v8a x86_64)  #所有架构(armeabi armeabi-v7a arm64-v8a x86 x86_64 mips mips64)
#编译修改下面四个属性结束


WORK_PATH=$(cd "$(dirname "$0")";pwd)
ANDROID_NDK_PATH=${WORK_PATH}/${NDK_VERSION}
OPENSSL_SOURCES_PATH=${WORK_PATH}/openssl-${OPENSSL_VERSION}

if [ ! -e openssl-${OPENSSL_VERSION}.tar.gz ]
 then
    echo "openssl 压缩包不存在"
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
fi


if [ ! -d openssl-${OPENSSL_VERSION} ]
 then
    echo "openssl 目录不存在"
    tar -zxvf openssl-${OPENSSL_VERSION}.tar.gz
fi

if [ ! -e ${NDK_VERSION}-linux-x86_64.zip ]
 then
    echo "ndk 压缩包不存在"
    wget https://dl.google.com/android/repository/${NDK_VERSION}-linux-x86_64.zip
    #ndk23+后缀不区分x86_64
    #wget https://dl.google.com/android/repository/${NDK_VERSION}-linux.zip
fi

if [ ! -d ${NDK_VERSION} ]
 then
    echo "ndk 目录不存在"
    unzip ${NDK_VERSION}-linux-x86_64.zip
    #ndk23+后缀不区分x86_64
    #unzip ${NDK_VERSION}-linux.zip
fi

 build_library() {
    mkdir -p ${OUTPUT_PATH}
    make && make install
    rm -rf ${OPENSSL_TMP_FOLDER}
    rm -rf ${OUTPUT_PATH}/bin
    rm -rf ${OUTPUT_PATH}/share
    rm -rf ${OUTPUT_PATH}/ssl
    rm -rf ${OUTPUT_PATH}/lib/engines*
    rm -rf ${OUTPUT_PATH}/lib/pkgconfig
    rm -rf ${OUTPUT_PATH}/lib/ossl-modules
    echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

for ABI in ${ANDROID_ABI_ARRAY[@]}
do
ANDROID_TARGET_ABI=${ABI}
#编译好的库输出路径
OUTPUT_PATH=${WORK_PATH}/openssl_${OPENSSL_VERSION}_build_lib
OPENSSL_TMP_FOLDER=${WORK_PATH}/tmp/openssl_${ANDROID_TARGET_ABI}

mkdir -p ${OPENSSL_TMP_FOLDER}
cp -r ${OPENSSL_SOURCES_PATH}/* ${OPENSSL_TMP_FOLDER}
echo "开始编译 ${ABI}"

if [ "$ANDROID_TARGET_ABI" = "armeabi" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "armeabi-v7a" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "arm64-v8a" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-arm64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "mips" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "mips64" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-mips64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "x86" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

elif [ "$ANDROID_TARGET_ABI" = "x86_64" ]
then
    export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
    #PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
    PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    cd ${OPENSSL_TMP_FOLDER}
    ./Configure android-x86_64 -D__ANDROID_API__=${ANDROID_TARGET_API} -static no-shared no-tests -fPIC --prefix=${OUTPUT_PATH}/${ANDROID_TARGET_ABI}   #NDK22及以上需要添加-fPIC
    build_library

else
    echo "Unsupported target ABI: $ANDROID_TARGET_ABI"
    exit 1
fi

done

