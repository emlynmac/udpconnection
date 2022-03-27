# UdpConnection

A Combine-style wrapper around Network's NWConnection with a UDP protocol

Usage:

```
let connection = UdpConnection.live(url: yourUrl, queue: yourDispatchQueue)

// Send with 
connection.send(data)

// Receive by subscribing to the receiveDataPublisher
let receiver = connection.receiveDataPublisher
  .sink(
    receiveCompletion: { completion in
      
    },
    receiveValue: { data in
     
    }
  )
  
// Track errors and state with
let state = connection.statePublisher.sink(
  receiveCompletion: { completion in
    // Handle the completion, possible error
  },
  receiveValue: { state in
    switch state {
    case .ready:
      // Handle ready
      
    default:
      // Handle other things
    }
  })
  
```
