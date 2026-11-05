pragma ComponentBehavior: Bound
import "."
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property bool firstInput
    required property string currentSession
    required property string currentUser
    required property int rectHeight

    property string os: (config.os || "Arch").split(" ")[0]
    property string host: config.host || "localhost"
    property string session: (root.currentSession || "Hyprland").split(" ")[0]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 10

        // Title Bar
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Rectangle {
                width: 32
                height: 32
                radius: 10
                color: config.secondary

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    color: "#111111"
                    text: ">"
                    font.family: "CaskaydiaCove NF"
                    font.pointSize: 14
                    font.bold: true
                }
            }

            Text {
                renderType: Text.NativeRendering
                color: config.text
                text: "caelestiafetch.sh"
                font.family: "CaskaydiaCove NF"
                font.pointSize: 13
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Logo & Specs
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 18

            Logo {
                skipIntroAnimation: root.firstInput
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 125
                Layout.preferredHeight: 125
            }

            RowLayout {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                Text {
                    renderType: Text.NativeRendering
                    text: "WM     :\nUSER   :\nOS     :\nHOST   :"
                    color: config.text
                    font.pixelSize: 17
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 28
                    lineHeightMode: Text.FixedHeight
                }

                Text {
                    renderType: Text.NativeRendering
                    text: root.session + "\n" + root.currentUser + "\n" + root.os + "\n" + root.host
                    color: config.text
                    font.pixelSize: 17
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 28
                    lineHeightMode: Text.FixedHeight
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Color Dots
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Repeater {
                model: [
                    config.background,
                    config.primary,
                    config.text,
                    config.textDark,
                    config.secondary,
                    config.onSuccess,
                    config.inverseOnSurface
                ]

                Rectangle {
                    required property color modelData
                    width: 26
                    height: 26
                    color: modelData
                    radius: 9
                }
            }
        }

        Item {
            height: 10
        }
    }
}
