import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
Item {
    anchors.fill: parent
    anchors.margins: 8
    signal playButton()
    signal lastmusic()
    signal nextmusic()
    function mediaPlaying(){
        playimage.source = "./image/stop.png"
    }
    function mediaStop(){
        playimage.source = "./image/play.png"
    }
    RowLayout{
        anchors.fill: parent
        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Rectangle{
            Layout.fillHeight: true
            Layout.preferredWidth: height
            radius: height
            scale: last.containsMouse ? 1.2 : 1
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: "./image/last.png"
                mipmap: true
            }
            MouseArea{
                id: last
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.ClosedHandCursor
                onClicked: {
                    lastmusic()
                }
            }
        }
        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Rectangle{
            id: play
            Layout.fillHeight: true
            Layout.preferredWidth: height
            radius: height
            color: "#353646"
            scale: mouseArea.containsMouse ? 1.2 : 1
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            MouseArea{
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    playButton()
                }
                hoverEnabled: true
                cursorShape: Qt.ClosedHandCursor
            }
            Image {
                id: playimage
                anchors.fill: parent
                anchors.margins: 5
                fillMode: Image.Stretch
                source: "./image/play.png"
                mipmap: true
            }
        }
        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Rectangle{
            Layout.fillHeight: true
            Layout.preferredWidth: height
            radius: height
            scale: next.containsMouse ? 1.2 : 1
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: "./image/next.png"
                mipmap: true
            }
            MouseArea{
                id: next
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.ClosedHandCursor
                onClicked: {
                    nextmusic()
                }
            }
        }
    }
}
