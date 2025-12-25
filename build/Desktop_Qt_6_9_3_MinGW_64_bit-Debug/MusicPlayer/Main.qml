import QtQuick
import QtCore
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import QtMultimedia
import "qml"
import MusicPlayer
import Qt.labs.platform

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("音乐播放器")
    color: "#3f414b"
    property string playUrl: ""
    property string playJpg: ""
    property int playIndex: 0
    property int lyricsTime: 0
    property int lyricsIndex: 0
    property string downloadurl: ""
    onLyricsTimeChanged: {
        musicLrc.getindex(root.lyricsTime,root.lyricsIndex)
    }
    Settings {
        id: setting
        property alias playurl: root.playUrl
        property alias playjpg: root.playJpg
        property alias playindex: root.playIndex
        property alias lyricstime: root.lyricsTime
        property alias lyricsindex: root.lyricsIndex
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
    }
    MediaPlayer{
        id: mediaplayer
        audioOutput: AudioOutput{}
        onMediaStatusChanged: {
            slider.enabled = true
            var directoryPath = mediaplayer.source.toString().substring(0, mediaplayer.source.toString().lastIndexOf("/") + 1);
            if(mediaStatus === MediaPlayer.EndOfMedia){
                if(functionList.getorder() === 0){
                    musicList.hello(root.playIndex,directoryPath)
                }else if(functionList.getorder() === 1){
                    musicList.hello(Math.floor(Math.random() * (musicList.getcount())),directoryPath)
                }else{
                    musicList.hello(root.playIndex-1,directoryPath)
                }
            }
        }
        onSourceChanged: {
            root.lyricsTime = 0
            root.lyricsIndex = 0
            slider.enabled = true
            musicLrc.emitUrl(mediaplayer.source,root.lyricsIndex)
        }
        onPositionChanged:{
            root.lyricsTime = Math.floor(mediaplayer.position/1000)
        }
    }
    Rectangle{
        anchors.right: parent.right
        width: parent.width/3
        height: parent.height
        color: "#3f414b"
        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#3f414b"
                RowLayout{
                    anchors.fill: parent
                    spacing: 0
                    Rectangle{
                        z:1
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width/5
                        color: "#3f414b"
                        FunctionList{
                            id: functionList
                        }
                    }
                    Rectangle{
                        z:0
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width*4/5
                        color: "#3f414b"
                        MusicList{
                            id: musicList
                            playindex:root.playIndex
                        }
                    }
                }
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height/10
                color: "#3f414b"
                MediaButton{
                    id: mediaButton
                }
            }
        }
    }
    Rectangle{
        anchors.bottom: parent.bottom
        width: parent.width*2/3
        height: parent.height
        clip: true
        color: "#3f414b"
        Rectangle{
            z: 1
            x: parent.width/2
            y: -parent.width/2
            width: parent.width
            height: width
            radius: 100
            color: "#433236"
            Rectangle{
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 20
                height: parent.height/2-50
                width: height
                radius: height
                color: "#433236"
                Canvas {
                    id: canvas
                    width: parent.width; height: parent.height
                    anchors.centerIn: parent
                    visible: false
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.beginPath()
                        ctx.arc(width/2, height/2, width/2, 0, Math.PI * 2)
                        ctx.closePath()
                        ctx.clip()
                        ctx.drawImage(jpg, 0, 0, width, height)
                    }
                    Image {
                        id: jpg
                        source: root.playJpg || ""
                        visible: false
                        onStatusChanged: if (status == Image.Ready) canvas.requestPaint()
                    }
                    Component.onCompleted: canvas.requestPaint()
                }
                MultiEffect{
                    source: canvas
                    anchors.fill: canvas
                    shadowEnabled: true
                    shadowColor: "#544b68"
                    shadowScale: 1
                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        from: 0; to: 360
                        duration: 15000
                        running: true
                    }
                    SequentialAnimation on shadowColor {
                        ColorAnimation { to: "#7d5d83"; duration: 5000;}
                        ColorAnimation { to: "#544b68"; duration: 5000; }
                        loops: Animation.Infinite
                    }
                    SequentialAnimation on shadowScale {
                        NumberAnimation{to: 1.1;duration: 2000;}
                        NumberAnimation{to: 1;duration: 2000;}
                        loops: Animation.Infinite
                    }
                }
            }
        }
        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width/2
                color: "#3f414b"
                SearchMusic{
                    id: searchmusic
                    onDownload: function(downloadurl){
                        root.downloadurl = downloadurl
                        var result = functionList.getfileurl();
                        searchmusic.gotodown(root.downloadurl,result)
                    }
                    onDown: function(urljpg){
                        jpg.source = "file:///"+urljpg
                        root.playJpg = "file:///"+urljpg
                    }
                }
            }
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "#3f414b"
                Rectangle{
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 2
                    width: parent.width/2
                    height: 40
                    color: "#3f414b"
                    RowLayout{
                        anchors.fill: parent
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            color: "#3f414b"
                            Text {
                                color: "white"
                                anchors.centerIn: parent
                                text: Math.floor(mediaplayer.position/1000/60)+":"+Math.floor(mediaplayer.position/1000%60)
                            }
                        }
                        Slider {
                            id:slider
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            from: 0
                            to: mediaplayer.duration > 0 ? mediaplayer.duration : 1
                            value: mediaplayer.position
                            onMoved:  mediaplayer.position = value
                            handle: Rectangle {
                                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 12
                                radius: 2
                                color: slider.pressed ? "#51536c" : "#3f414b"
                                border.color: "#bdbebf"
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                            onValueChanged: {
                                if (value >= to - 1) {
                                    slider.enabled = false;
                                }
                            }
                        }
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            color: "#3f414b"
                            Text {
                                id: musicduration
                                color: "white"
                                anchors.centerIn: parent
                                text: Math.floor(mediaplayer.duration/1000/60)+":"+Math.floor(mediaplayer.duration/1000%60)
                            }
                        }
                    }
                }
                Rectangle{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height-40
                    color: "#3f414b"
                    MusicLrc{
                        id: musicLrc
                        onUpdateindex:function(newindex){
                            root.lyricsIndex = newindex
                        }
                    }
                }
            }
        }
    }
    Connections {
        target: functionList
        function onSetlist(data) {
            musicList.addItem(data)
        }
        function onSetrate(rate){
            mediaplayer.playbackRate = rate
        }
    }
    Connections{
        target: musicList
        function onPlayMusic(url,index){
            mediaplayer.source = url
            root.playUrl = url
            root.playIndex = index
            mediaplayer.play()
            mediaButton.mediaPlaying()
            jpg.source = url.replace(/.(mp3|aac|wav)$/i, ".jpg")
            root.playJpg = url.replace(/.(mp3|aac|wav)$/i, ".jpg")
        }
    }
    Connections{
        target: mediaButton
        function onPlayButton(){
            if(mediaplayer.playing){
                mediaplayer.pause()
                mediaButton.mediaStop()
            }else{
                mediaplayer.source = setting.playurl
                mediaplayer.play()
                mediaButton.mediaPlaying()
            }
        }
        function onLastmusic(){
            var directoryPath = mediaplayer.source.toString().substring(0, mediaplayer.source.toString().lastIndexOf("/") + 1);
            musicList.hellos(root.playIndex,directoryPath)
        }
        function onNextmusic(){
            var directoryPath = mediaplayer.source.toString().substring(0, mediaplayer.source.toString().lastIndexOf("/") + 1);
            musicList.hello(root.playIndex,directoryPath)
        }
    }
    Component.onCompleted: {
        mediaplayer.source = setting.playurl
    }


    SystemTrayIcon {
       visible: true // 设置为 true 以显示
       icon.source: "qrc:/ui.png" // 使用你的图标，支持PNG等格式
       onActivated: function(reason) {
           if (reason === SystemTrayIcon.DoubleClick) { // 将 DoubleClick 改为 Trigger
               root.show();
               root.raise();
               root.requestActivate();
           }
       }
       menu: Menu {
           MenuItem {
               text: qsTr("退出")
               onTriggered: Qt.quit()
           }
       }
    }
}
