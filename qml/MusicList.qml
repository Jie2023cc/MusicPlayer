import QtQuick
import Qt.labs.folderlistmodel
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: itemroot
    anchors.fill: parent
    anchors.margins: 2
    property int playindex
    signal playMusic(string url, int index)
    function addItem(data) {
        folderListModel.folder = data
    }
    function getcount(){
        return folderListModel.count
    }
    function hello(index,url){
        if(index+1 < folderListModel.count){
            playMusic(url+folderListModel.get(index+1,["fileName"]),index+1)
        }else{
            playMusic(url+folderListModel.get(0,["fileName"]),0)
        }
    }
    function hellos(index,url){
        if(index-1 < 0){
            playMusic(url+folderListModel.get(0,["fileName"]),0)
        }else{
            playMusic(url+folderListModel.get(index-1,["fileName"]),index-1)
        }
    }
    FolderListModel{
        id: folderListModel
        folder: ""
        nameFilters: ["*.mp3","*.wav","*.aac"]
        showDirs: false
        sortField: FolderListModel.Name
    }
    ListView{
        id:musicList
        anchors.fill: parent
        anchors.margins: 8
        model: folderListModel
        spacing: 6
        delegate: Rectangle{
            width: musicList.width
            height: listName.implicitHeight+20
            radius: 15
            scale: mouseArea.containsMouse ? 1.3 : 1
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            color: index === itemroot.playindex ? "#51536c" : "#353646"
            MouseArea{
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    playMusic(folderListModel.folder +"/"+ fileName,index)
                }
            }
            RowLayout{
                id: listName
                anchors.fill: parent
                anchors.margins: 10
                Text {
                    color: "white"
                    Layout.fillHeight: true
                    text: index + 1
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    color: "white"
                    Layout.fillHeight: true
                    text: fileName.toString().replace(/.(mp3|aac|wav)$/i,"")
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
