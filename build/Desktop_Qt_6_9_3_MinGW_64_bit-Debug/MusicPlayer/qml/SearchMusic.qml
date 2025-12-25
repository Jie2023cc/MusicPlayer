import QtQuick
import QtQuick.Layouts
import MusicPlayer
import QtQuick.Effects
import QtMultimedia

Item {
    anchors.fill: parent
    signal download(string downloadurl)
    signal down(string jpgurl)
    Search{
        id:searchcpp
        onPlayurl: function(url){
            download(url)
        }
    }
    function gotodown(downurl,downfile){
        var playurl = searchcpp.downmusic(listView.currentIndex,downurl,downfile)
        down(playurl)
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height/5
            color: "#3f414b"
            RowLayout{
                anchors.fill: parent
                anchors.margins: 8
                spacing: 5
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    radius: 50
                    border.color: "black"
                    border.width: 2
                    TextInput{
                        id: search
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        width: parent.width - 40
                        clip: true
                        selectByMouse: true
                        selectedTextColor: "black"
                        selectionColor: "#c2c2c2"
                        onAccepted: {
                            searchcpp.getkeyword(search.text)
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: search.forceActiveFocus()
                    }
                }
                Rectangle{
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    radius: height
                    color: "#3f414b"
                    scale: mouseArea.containsMouse ? 1.2 : 1
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.Stretch
                        source: "./image/search.png"
                        mipmap: true
                    }
                    MouseArea{
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchcpp.getkeyword(search.text)
                        }
                    }
                }
            }
        }
        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height*4/5
            color: "#3f414b"
            ColumnLayout{
                anchors.fill: parent
                spacing: 2
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: musiclists.implicitHeight
                    color: "#3f414b"
                    RowLayout{
                        anchors.fill: parent
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "#3f414b"
                            Text {
                                id: musiclists
                                color: "white"
                                anchors.centerIn: parent
                                text: "歌曲"
                            }
                        }
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "#3f414b"
                            Text {
                                color: "white"
                                text: "作者"
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#3f414b"
                    clip: true
                    ListView{
                        id: listView
                        anchors.fill: parent
                        anchors.margins: 2
                        model: searchcpp.model
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle{
                            width: listView.width
                            height: listView.height/4
                            radius: 50
                            color: "#3f414b"
                            RowLayout{
                                anchors.fill: parent
                                spacing: 0
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "#51536c"
                                    radius: 50
                                    layer.enabled: true
                                    layer.effect:MultiEffect{
                                        shadowEnabled: true
                                        shadowColor: "#baf8b9"
                                        shadowBlur: 0.4
                                    }
                                    Text {
                                        color: "white"
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        text: "《" + title + "》"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                        fontSizeMode: Text.Fit
                                    }
                                    scale: mouses.containsMouse ? 0.9 : 1
                                    Behavior on scale {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                    MouseArea{
                                        id: mouses
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            listView.currentIndex = index
                                            searchcpp.geturl(index)

                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "#353646"
                                    radius: 50
                                    layer.enabled: true
                                    layer.effect:MultiEffect{
                                        shadowEnabled: true
                                        shadowColor: "#b9eef8"
                                        shadowBlur: 0.4
                                    }
                                    Text {
                                        color: "white"
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        text: artist
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                        fontSizeMode: Text.Fit
                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    radius: height
                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.Stretch
                                        source: artwork
                                        mipmap: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
