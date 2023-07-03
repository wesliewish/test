#!/bin/bash

# Download Azur Lane
download_azurlane () {
    if [ ! -f "AzurLane.apk" ]; then
    # 下载游戏apk的地址,我找不到一个固定的链接,理论上每次更新客户端都要手动改地址
    url="https://objects.githubusercontent.com/github-production-release-asset-2e65be/617714826/82f310e5-d1e8-4d91-9b7f-8d8627b67fb9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230703%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230703T064359Z&X-Amz-Expires=300&X-Amz-Signature=bc73e939145ff9cccf081ded961a33160a8b98ba755546a6ffcbf806f4d2075e&X-Amz-SignedHeaders=host&actor_id=96678238&key_id=0&repo_id=617714826&response-content-disposition=attachment%3B%20filename%3DAzurLane.patched.apk&response-content-type=application%2Fvnd.android.package-archive"
    # 使用wget命令下载apk文件
    curl -o blhx.apk  $url
    fi
}

if [ ! -f "AzurLane.apk" ]; then
    echo "Get Azur Lane apk"
    download_azurlane
    mv *.apk "AzurLane.apk"
fi


echo "Decompile Azur Lane apk"
java -jar apktool.jar  -f d AzurLane.apk

echo "Copy libs"
cp -r libs/. AzurLane/lib/

echo "Patching Azur Lane"
oncreate=$(grep -n -m 1 'onCreate' AzurLane/smali_classes3/com/unity3d/player/UnityPlayerActivity.smali | sed  's/[0-9]*\:\(.*\)/\1/')
sed -ir "s#\($oncreate\)#.method private static native init(Landroid/content/Context;)V\n.end method\n\n\1#" AzurLane/smali_classes3/com/unity3d/player/UnityPlayerActivity.smali
sed -ir "s#\($oncreate\)#\1\n    const-string v0, \"Dev_Liu\"\n\n\    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V\n\n    invoke-static {p0}, Lcom/unity3d/player/UnityPlayerActivity;->init(Landroid/content/Context;)V\n#" AzurLane/smali_classes3/com/unity3d/player/UnityPlayerActivity.smali

echo "Build Patched Azur Lane apk"
java -jar apktool.jar  -f b AzurLane -o AzurLane.patched.apk

echo "Set Github Release version"

echo "PERSEUS_VERSION=$(echo BILIBILI)" >> $GITHUB_ENV

mkdir -p build
mv *.patched.apk ./build/
find . -name "*.apk" -print
