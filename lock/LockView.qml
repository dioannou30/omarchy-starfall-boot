import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property color skyColor: "#0D1020"
  readonly property color textColor: "#DAE2FA"
  readonly property color dotColor: "#6FE9F5"
  readonly property color placeholderColor: "#7D89B3"
  readonly property color errorColor: "#FF7A93"
  readonly property bool animate: root.visible && root.loadBackground

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 64
  readonly property int fieldPadding: 30
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.0)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.2)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.3)
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onFailedAttemptsChanged: {
    if (failedAttempts > 0) shake.restart()
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    id: sky
    anchors.fill: parent
    color: root.skyColor
    clip: true

    Repeater {
      model: 70

      Image {
        id: starImage
        required property int index
        readonly property real rx: Math.random()
        readonly property real ry: Math.random()
        readonly property int size: Math.random() < 0.4 ? 6 : 3
        readonly property int period: 1500 + Math.round(Math.random() * 3000)

        source: Qt.resolvedUrl("assets/star.png")
        width: size
        height: size
        smooth: false
        x: rx * sky.width
        y: ry * sky.height
        opacity: 0.6

        SequentialAnimation on opacity {
          running: root.animate
          loops: Animation.Infinite
          PauseAnimation { duration: Math.round(Math.random() * starImage.period) }
          NumberAnimation { to: 1.0; duration: starImage.period; easing.type: Easing.InOutSine }
          NumberAnimation { to: 0.1; duration: starImage.period; easing.type: Easing.InOutSine }
        }
      }
    }

    Image {
      id: shootingStar
      source: Qt.resolvedUrl("assets/streak.png")
      rotation: 20
      opacity: 0

      ParallelAnimation {
        id: shootingRun
        NumberAnimation { target: shootingStar; property: "x"; from: shootingStar.startX; to: shootingStar.startX + 700; duration: 1000; easing.type: Easing.InQuad }
        NumberAnimation { target: shootingStar; property: "y"; from: shootingStar.startY; to: shootingStar.startY + 255; duration: 1000; easing.type: Easing.InQuad }
        SequentialAnimation {
          NumberAnimation { target: shootingStar; property: "opacity"; from: 0; to: 1; duration: 300 }
          NumberAnimation { target: shootingStar; property: "opacity"; to: 0; duration: 700 }
        }
      }

      property real startX: 0
      property real startY: 0
    }

    Timer {
      running: root.animate
      repeat: true
      interval: 6000
      onTriggered: {
        shootingStar.startX = Math.random() * sky.width * 0.7 - 150
        shootingStar.startY = Math.random() * sky.height * 0.4
        shootingRun.restart()
        interval = 5000 + Math.round(Math.random() * 4000)
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    Image {
      id: logo
      source: Qt.resolvedUrl("assets/logo.png")
      width: Math.min(800, sky.width * 0.6)
      height: width * 188 / 800
      fillMode: Image.PreserveAspectFit
      mipmap: true
      anchors.centerIn: parent
    }

    Image {
      id: lockIcon
      source: Qt.resolvedUrl("assets/lock.png")
      height: inputField.height * 0.8
      width: height * 84 / 96
      mipmap: true
      anchors.right: inputField.left
      anchors.rightMargin: 20
      anchors.verticalCenter: inputField.verticalCenter
    }

    BorderImage {
      id: inputField
      source: Qt.resolvedUrl("assets/entry.png")
      border { left: 20; right: 20; top: 14; bottom: 14 }
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.top: logo.bottom
      anchors.topMargin: 40
      anchors.horizontalCenter: parent.horizontalCenter
      transform: Translate { id: shakeShift }

      SequentialAnimation {
        id: shake
        NumberAnimation { target: shakeShift; property: "x"; to: -12; duration: 50 }
        NumberAnimation { target: shakeShift; property: "x"; to: 12; duration: 70 }
        NumberAnimation { target: shakeShift; property: "x"; to: -8; duration: 70 }
        NumberAnimation { target: shakeShift; property: "x"; to: 6; duration: 60 }
        NumberAnimation { target: shakeShift; property: "x"; to: 0; duration: 50 }
      }

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.leftMargin: root.fieldPadding + root.fingerprintReserve
        anchors.rightMargin: root.fieldPadding + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignLeft
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "●"
        passwordMaskDelay: 0
        color: root.dotColor
        selectionColor: "#2A3A6A"
        selectedTextColor: root.textColor
        font.family: Style.font.family
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 2
          color: root.dotColor
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        anchors.fill: passwordInput
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? root.textColor : (root.failureMessage.length > 0 ? root.errorColor : root.placeholderColor)
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: root.fieldPadding
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: root.placeholderColor
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
}
