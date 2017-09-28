/* global WebSocket, F2, F3, A2, _elm_lang$core$Native_Scheduler, _elm_lang$core$Maybe$Just,  _elm_lang$core$Maybe$Nothing  */
var _dividat$websocket$Native_WebSocket = (function () {
  function open (url, settings) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      try {
        var socket = new WebSocket(url)
        socket.binaryType = 'arraybuffer'
        socket.elm_web_socket = true
      } catch (err) {
        return callback(_elm_lang$core$Native_Scheduler.fail({
          ctor: err.name === 'SecurityError' ? 'BadSecurity' : 'BadArgs',
          _0: err.message
        }))
      }

      socket.addEventListener('open', function (event) {
        callback(_elm_lang$core$Native_Scheduler.succeed(socket))
      })

      socket.addEventListener('message', function (event) {
        var data = event.data
        if (data instanceof ArrayBuffer) {
          _elm_lang$core$Native_Scheduler.rawSpawn(A2(settings.onMessage, socket, {ctor: 'Binary', _0: data}))
        } else {
          _elm_lang$core$Native_Scheduler.rawSpawn(A2(settings.onMessage, socket, {ctor: 'Text', _0: data}))
        }
      })

      socket.addEventListener('close', function (event) {
        _elm_lang$core$Native_Scheduler.rawSpawn(settings.onClose({
          code: event.code,
          reason: event.reason,
          wasClean: event.wasClean
        }))
      })

      return function () {
        if (socket && socket.close) {
          socket.close()
        }
      }
    })
  }

  function send (socket, msg) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      var result =
      socket.readyState === WebSocket.OPEN
      ? _elm_lang$core$Maybe$Nothing
      : _elm_lang$core$Maybe$Just({ ctor: 'NotOpen' })

      try {
        socket.send(msg._0)
      } catch (err) {
        result = _elm_lang$core$Maybe$Just({ ctor: 'BadString' })
      }

      callback(_elm_lang$core$Native_Scheduler.succeed(result))
    })
  }

  function close (code, reason, socket) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      try {
        socket.close(code, reason)
      } catch (err) {
        return callback(_elm_lang$core$Native_Scheduler.fail(_elm_lang$core$Maybe$Just({
          ctor: err.name === 'SyntaxError' ? 'BadReason' : 'BadCode'
        })))
      }
      callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Maybe$Nothing))
    })
  }

  function bytesQueued (socket) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      callback(_elm_lang$core$Native_Scheduler.succeed(socket.bufferedAmount))
    })
  }

  return {
    open: F2(open),
    send: F2(send),
    close: F3(close),
    bytesQueued: bytesQueued
  }
}())
