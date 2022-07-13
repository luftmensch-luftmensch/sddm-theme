/* ========================
 * Author - DN-debug
 * Original Author - eayus
 * Description - Modified clairvoyance with auto background 
 * changer on every boot. Added clock functionality and
 * blur effects
 ========================== */

import QtQuick 2.0
import QtQuick.Controls 2.2
import SddmComponents 2.0
import QtGraphicalEffects 1.12

Item {
  id: page
    width: 2048
    height: 2048
    Text {
        font.family: monospace;
    }
    
    focus: true
    Keys.onEscapePressed :{
        Qt.quit();
    }
    
    
  // Background Fill: Just in case video/background image fails to load.
  Rectangle {
    anchors.fill: parent
    color: "black"
  }

    property int slideIndex: 0

    property variant images: [
        "./backgrounds/1.jpg",
        "./backgrounds/2.jpeg",
        "./backgrounds/3.jpg",
        "./backgrounds/4.jpg",
        "./backgrounds/5.jpg",
    ]
    
    onSlideIndexChanged: if(slideIndex >= images.length )timer.stop()
    
    
    Timer{
        id: timer
        running: true
        repeat: true
        interval: 1500
        onTriggered: slideIndex++
    }

    Image{
        id: pic
        anchors.fill: parent
        width: screen.width
        height: screen.height
            
        fillMode: Image.PreserveAspectCrop

        source: {
            
            for (var i = 0 ; i <= images.length; --i )
            {
                i = Math.floor(Math.random()*7);
                
                console.log(i)
                switch(i){
                    case 0: return images[i++];
                    case 1: return images[i++];
                    case 2: return images[i++];
                    case 3: return images[i++];
                    case 4: return images[i++];
		    // This is needed in order to avoid selecting an index not valid
		    // Shift the case to the latest number when adding new backgrounds
                    case 5: return images[4]; // avoid the undefined idex
                }
            }
        }
    }
    
        ShaderEffectSource {
                id: blurMask

                sourceItem: page
                width: form.width
                height: parent.height
                anchors.centerIn: form
                sourceRect: Qt.rect(x,y,width,height)
                visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
            }

        GaussianBlur {
            id: blur

            height: parent.height
            width: config.FullBlur == "true" ? parent.width : form.width
            source: config.FullBlur == "true" ? pic : blurMask
            radius: config.BlurRadius
            samples: config.BlurRadius * 2 + 1
            cached: true
            anchors.centerIn: config.FullBlur == "true" ? parent : form
            visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
        }

   
   
  //Time and Date
    Clock {
      id: clock
      y: parent.height * config.relativePositionY - clock.height / 2
      x: parent.width * config.relativePositionX - clock.width / 2
      color: "white"
      timeFont.pointSize: 35
      dateFont.pointSize: 12
      timeFont.family: "monospace"
      dateFont.family: "monospace"
    }


  Login {
    id: loginFrame
    visible: false
    opacity: 0
  }

  PowerFrame {
    id: powerFrame
  }

  ListView {
    id: sessionSelect
    width: currentItem.width
    height: count * currentItem.height
    model: sessionModel
    currentIndex: sessionModel.lastIndex
    visible: false
    opacity: 0
    flickableDirection: Flickable.AutoFlickIfNeeded
    anchors {
      bottom: powerFrame.top
      right: page.right
      rightMargin: 35
    }
    delegate: Item {
      width: 100
      height: 50
      Text {
        width: parent.width
        height: parent.height
        text: name
        color: "white"
        opacity: (delegateArea.containsMouse || sessionSelect.currentIndex == index) ? 1 : 0.3
        font {
          pointSize: (config.enableHDPI == "true") ? 6 : 12
          family: "monospace"
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on opacity {
          NumberAnimation { duration: 250; easing.type: Easing.InOutQuad}
        }
      }

      MouseArea {
        id: delegateArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          sessionSelect.currentIndex = index
          sessionSelect.state = ""
        }
      }
    }

    states: State {
      name: "show"
      PropertyChanges {
        target: sessionSelect
        visible: true
        opacity: 1
      }
    }

    transitions: [
    Transition {
      from: ""
      to: "show"
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
      }
    },
    Transition {
      from: "show"
      to: ""
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
      }
    }
    ]

  }

  ChooseUser {
    id: listView
    visible: true
    opacity: 1
  }

  states: State {
    name: "login"
    PropertyChanges {
      target: listView
      visible: false
      opacity: 0
    }

    PropertyChanges {
      target: loginFrame
      visible: true
      opacity: 1
    }
  }

  transitions: [
  Transition {
    from: ""
    to: "login"
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
    }
  },
  Transition {
    from: "login"
    to: ""
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
    }
  }]

}
