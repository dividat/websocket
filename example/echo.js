const WebSocket = require('ws')

const wss = new WebSocket.Server({ port: 9000 })

wss.on('connection', function connection (ws) {
  setInterval(() => {
    ws.send(new ArrayBuffer(10))
    ws.send('Hello')
  }, 500)

  ws.on('message', function incoming (message) {
    console.log(message)
    ws.send(message)
  })
})
