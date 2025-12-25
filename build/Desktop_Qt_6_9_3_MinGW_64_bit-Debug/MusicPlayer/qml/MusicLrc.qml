import QtQuick
import MusicPlayer
import QtQuick.Layouts

Item {
    anchors.fill: parent
    anchors.margins: 5
    clip: true
    signal updateindex(int newindex)
    GetLyrics{
        id: getLyrics
    }
    function emitUrl(url,index){
        getLyrics.getUrl(url)
        musicListView.currentIndex = 0
        musicListView.positionViewAtIndex(0, ListView.Beginning);
    }
    function getindex(time,index){
        var newindex = getLyrics.returnIndex(time,index)
        if(newindex !== index){
            updateindex(newindex)
            musicListView.currentIndex = newindex
            musicListView.positionViewAtIndex(newindex, ListView.Center);
        }
    }
    ListView {
        y: -50
        id: musicListView
        anchors.fill: parent
        spacing: 0
        model: getLyrics.musicModel
        delegate: Rectangle {
            property int distance: Math.abs(index - musicListView.currentIndex)
            id: delegateItem
            width: musicListView.width
            height: columnLyrics.implicitHeight
            color: "#3f414b"
            Column{
                id: columnLyrics
                anchors.fill: parent
                Rectangle{
                    width: parent.width
                    height: twotext.visible?twotext.implicitHeight:0
                    radius: 10
                    color: "#3f414b"
                    scale: (1.0 - (distance * 0.1) > 0) ? (1.0 - (distance * 0.1)) : 0
                    Text {
                        id: twotext
                        color: "#c0b5b5"
                        anchors.centerIn: parent
                        font.pixelSize: 12
                        text: twoLyrics ? twoLyrics : "..."
                        visible: twoLyrics? true:false
                    }
                }
                Rectangle{
                    width: parent.width
                    height: onetext.implicitHeight
                    radius: 10
                    color: index === musicListView.currentIndex?"#51536c":"#3f414b"
                    scale: (1.0 - (distance * 0.1) > 0) ? (1.0 - (distance * 0.1)) : 0
                    Text {
                        id: onetext
                        color: index === musicListView.currentIndex?"#aac0e4":"#8fa2c1"
                        anchors.centerIn: parent
                        font.pixelSize: 18
                        text: oneLyrics ? oneLyrics : "..."
                        visible: onetext? true:false
                    }
                }
            }
        }
    }
}
