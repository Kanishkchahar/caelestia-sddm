import QtQuick

Item {
    id: root

    property alias color: quote.color
    property alias maxWidth: quote.width

    anchors.fill: parent

    Item {
        Component.onCompleted: {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", Qt.resolvedUrl("../config/quotes.json"));
            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    try {
                        if (xhr.responseText) {
                            const data = JSON.parse(xhr.responseText);
                            if (data && data.length > 0) {
                                const index = Math.floor(Math.random() * data.length);
                                quote.text = data[index].text;
                                author.text = "~ " + data[index].author;
                                return;
                            }
                        }
                    } catch (e) {
                        console.log("Quotes fallback used:", e);
                    }
                    quote.text = "What we think, we become.";
                    author.text = "~ Buddha";
                }
            };
            xhr.send();
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Text {
            id: quote

            width: 100
            text: ""
            color: "white"
            font.pointSize: 20
            font.family: "Rubik"
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: author

            width: quote.width
            text: ""
            color: config.primary
            font.pointSize: 15
            font.family: "CaskaydiaCove NF"
            font.bold: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
