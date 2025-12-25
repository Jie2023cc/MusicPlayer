import QtQuick
import QtQuick.Layouts
import QtCore
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    id: itemRoot
    anchors.fill: parent
    property var myText: []
    property int index: 0
    property int order: 0
    signal setlist(string data)
    signal setrate(int rate)
    function getorder(){
        return itemRoot.order
    }
    Settings {
        id: settings
        property alias index: itemRoot.index
        property string savedText: "[]"
    }
    Component.onCompleted: {
        myText = JSON.parse(settings.savedText)
        listView.currentIndex = settings.index
        if(myText[0]){
            setlist(myText[settings.index].toString())
        }
    }
    function getfileurl(){
        return myText[settings.index]
    }
    Column{
        anchors.fill: parent
        spacing: 0
        Rectangle{
            width: parent.width
            height: parent.height*2/3
            color: "#3f414b"
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4
                Rectangle{
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    color: "#3f414b"
                    Layout.preferredHeight: listView.contentHeight > parent.height*2/3 ? parent.height*2/3:listView.contentHeight
                    ListView {
                        id: listView
                        anchors.fill: parent
                        model: myText.length
                        spacing: 0
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle {
                            width: listView.width
                            height: width
                            radius: 10
                            color: "#3f414b"
                            scale: mousearea.containsMouse ? 1.2 : 1
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                            }
                            Image {
                                id: file
                                anchors.fill: parent
                                anchors.margins: 5
                                fillMode: Image.Stretch
                                source: listView.currentIndex === index ? "./image/openfile.png" : "./image/file.png"
                                mipmap: true
                            }
                            MouseArea{
                                id: mousearea
                                anchors.fill: parent
                                onClicked: {
                                    listView.currentIndex = index
                                    itemRoot.index = listView.currentIndex
                                    setlist(myText[index].toString())
                                }
                                hoverEnabled: true
                                cursorShape: Qt.ClosedHandCursor
                                onDoubleClicked: {
                                    Qt.openUrlExternally(myText[index].toString())
                                }
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: width
                    color: "#3f414b"
                    radius: 10
                    scale: createfile.containsMouse ? 1.2 : 1
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.Stretch
                        source: "./image/new.png"
                    }
                    MouseArea{
                        id: createfile
                        anchors.fill: parent
                        onClicked: {
                            folderDialog.open()
                            myText = myText.slice()
                        }
                        hoverEnabled: true
                        cursorShape: Qt.ClosedHandCursor
                    }
                    FolderDialog {
                        id: folderDialog
                        onAccepted: {
                            var last= folderDialog.selectedFolder.toString().split("/")
                            myText.push(folderDialog.selectedFolder)
                            myText = myText.slice()
                            settings.savedText = JSON.stringify(myText)
                            if(myText.length-1 != 0){
                                listView.currentIndex = myText.length-1
                                setlist(myText[myText.length-1].toString())
                                itemRoot.index = listView.currentIndex
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: width
                    color: "#3f414b"
                    radius: 10
                    scale: delefile.containsMouse ? 1.2 : 1
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        fillMode: Image.Stretch
                        source: "./image/dele.png"
                    }
                    MouseArea{
                        id:delefile
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: {
                            myText.splice(listView.currentIndex, 1)
                            itemRoot.index -=1
                            var index = listView.currentIndex - 1
                            myText = myText.slice()
                            listView.currentIndex = index
                            settings.savedText = JSON.stringify(myText)
                            if(myText[index]){
                                setlist(myText[index].toString())
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#3f414b"
                }
            }
        }
        Rectangle{
            width: parent.width
            height: parent.height/3
            color: "#3f414b"
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 10
                Rectangle{
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: width
                    radius: width
                    color: "#3f414b"
                    scale: switchsc.containsMouse ? 1.2 : 1
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Image {
                        id: switchplay
                        anchors.fill: parent
                        anchors.margins: 8
                        fillMode: Image.Stretch
                        mipmap: true
                        source: "./image/order.png"
                    }
                    MouseArea{
                        id: switchsc
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: {
                            if(itemRoot.order === 0){
                                itemRoot.order = 1
                                switchplay.source = "./image/random.png"
                            }else if(itemRoot.order === 1){
                                itemRoot.order = 2
                                switchplay.source = "./image/circle.png"
                            }else{
                                itemRoot.order = 0
                                switchplay.source = "./image/order.png"
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: width
                    radius: width
                    color: "#3f414b"
                    scale: setRate.containsMouse ? 1.3 : 1
                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Text {
                        id: rate
                        color: "white"
                        anchors.centerIn: parent
                        text: qsTr(1)
                        onTextChanged: {
                            setrate(rate.text)
                        }
                    }
                    Text {
                        color: "white"
                        anchors.left: rate.right
                        anchors.baseline: rate.baseline
                        text: qsTr("x")
                    }
                    MouseArea{
                        id:setRate
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: {
                            if(slider.width === 0){
                                slider.width = parent.width*2
                            }else{
                                slider.width = 0
                            }
                        }
                    }
                    Slider{
                        id:slider
                        anchors.left: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 0
                        from: 1
                        to: 3
                        stepSize:1
                        value: rate.text
                        onMoved:  rate.text = value
                        handle: Item {}
                        background: Rectangle {
                            x: slider.leftPadding
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            width: slider.availableWidth
                            height: 6
                            radius: 3
                            color: "#535a3f"
                            Rectangle {
                                width: slider.visualPosition * parent.width
                                height: parent.height
                                color: "#53b430"
                                radius: 3
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.NoButton
                            }
                        }
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }
            }
        }
    }
}
