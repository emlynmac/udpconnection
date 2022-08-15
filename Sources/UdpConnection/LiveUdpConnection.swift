import Foundation
import Network

typealias ReceiveType = (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void

extension UdpConnection {
  public static func live(url: URL, queue: DispatchQueue) -> UdpConnection? {
    guard let host = url.host, let port = url.port else {
      assertionFailure("No host / port configured")
      return nil
    }
    let conn = NWConnection(host: NWEndpoint.Host(host),
                            port: NWEndpoint.Port.init(rawValue: UInt16(port))!,
                            using: .udp)

    var cancelled = false
    
    return UdpConnection(
      cancel: {
        conn.cancel()
        cancelled = true
        conn.stateUpdateHandler = nil
      },
      connectionState: {
        AsyncStream { continuation in
          conn.stateUpdateHandler = {
            continuation.yield($0)
            if cancelled {
              continuation.finish()
            }
          }
          conn.start(queue: queue)
        }
      }(),
      receivedData: {
        AsyncThrowingStream<Data, Error> { continuation in
          var receiveMessages: (() -> Void)?
          let receiveWrapper: ReceiveType = { data, context, complete, error in
            if let err = error {
              continuation.finish(throwing: err)
            } else if let data = data {
              continuation.yield(data)
            }
            receiveMessages?()
          }

          receiveMessages = { [conn] in
            if !cancelled {
              conn.receiveMessage(completion: receiveWrapper)
            } else {
              continuation.finish()
            }
          }
          receiveMessages?()
        }
      }(),
      remoteHost: {
        switch conn.endpoint {
        case .hostPort(let host, _):
          return "\(host)"
        default:
          return ""
        }
      }(),
      send: { conn.send(content: $0, completion: .idempotent) }
    )
  }
}
