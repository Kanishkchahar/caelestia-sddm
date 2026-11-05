import QtQuick

Item {
    id: root

    property alias color: icon.color
    property alias text: icon.text
    property alias pointSize: icon.font.pointSize

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Text {
        id: icon

        anchors.centerIn: parent
        font.family: "Material Symbols Rounded"
        font.pointSize: 20
    }
}
