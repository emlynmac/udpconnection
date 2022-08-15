# UdpConnection

Am async wrapper around Network's NWConnection, for User Datagram Protocol

Usage:

```
let connection = UdpConnection.live(url: yourUrl, queue: yourDispatchQueue)

// Send with 
connection.send(data)

// Receive by awaiting the data on the receivedData stream:
for await data in connection.receivedData {
  // DO SOMETHING WITH THE DATA
}
  
// Track errors and state with the connectionState stream:
Task {
  for await state in connection.connectionState {
      switch state {
    case .ready:
      // Start sending / receiving
      
    default:
      // Handle other things
    }
  }
}
```
