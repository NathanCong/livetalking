var pc = null;

function negotiate() {
  pc.addTransceiver('video', { direction: 'recvonly' });
  pc.addTransceiver('audio', { direction: 'recvonly' });
  return pc.createOffer().then((offer) => {
    return pc.setLocalDescription(offer);
  }).then(() => {
    // wait for ICE gathering to complete
    return new Promise((resolve) => {
      if (pc.iceGatheringState === 'complete') {
        resolve();
      } else {
        const checkState = () => {
          if (pc.iceGatheringState === 'complete') {
            pc.removeEventListener('icegatheringstatechange', checkState);
            resolve();
          }
        };
        pc.addEventListener('icegatheringstatechange', checkState);
      }
    });
  }).then(() => {
    var offer = pc.localDescription;
    return fetch('/offer', {
      body: JSON.stringify({
        sdp: offer.sdp,
        type: offer.type,
      }),
      headers: {
        'Content-Type': 'application/json'
      },
      method: 'POST'
    });
  }).then((response) => {
    return response.json();
  }).then((answer) => {
    document.getElementById('sessionid').value = answer.sessionid
    return pc.setRemoteDescription(answer);
  }).catch((e) => {
    alert(e);
  });
}

function start() {
  var config = { sdpSemantics: 'unified-plan' };
  config.iceServers = [
      // {
      //   urls: 'turn:124.221.52.222:3478?transport=udp',
      //   username: 'byron',
      //   credential: 'baibai@1248'
      // },
      {
        urls: 'turn:62.234.188.122:3478?transport=udp',
        username: 'NathanCong',
        credential: 'CYN@8011'
      },
      // {
      //   urls: 'turn:8.160.115.34:3478?transport=udp',
      //   username: 'NathanCong',
      //   credential: 'CYN@8011'
      // },
    ];
    config.iceTransportPolicy = 'all';

  if (document.getElementById('use-stun').checked) {
    config.iceServers = [{ urls: ['stun:stun.l.google.com:19302'] }];
  }

  pc = new RTCPeerConnection(config);

  // connect audio / video
  pc.addEventListener('track', (evt) => {
    if (evt.track.kind == 'video') {
      document.getElementById('video').srcObject = evt.streams[0];
    } else {
      document.getElementById('audio').srcObject = evt.streams[0];
    }
  });

  document.getElementById('start').style.display = 'none';
  negotiate();
  document.getElementById('stop').style.display = 'inline-block';
}

function stop() {
  document.getElementById('stop').style.display = 'none';

  // close peer connection
  setTimeout(() => {
    pc.close();
  }, 500);
}

window.onunload = function (event) {
  // 在这里执行你想要的操作
  setTimeout(() => {
    pc.close();
  }, 500);
};

window.onbeforeunload = function (e) {
  setTimeout(() => {
    pc.close();
  }, 500);
  e = e || window.event
  // 兼容IE8和Firefox 4之前的版本
  if (e) {
    e.returnValue = '关闭提示'
  }
  // Chrome, Safari, Firefox 4+, Opera 12+ , IE 9+
  return '关闭提示'
}
