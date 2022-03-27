import Combine
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
    let subject = PassthroughSubject<Data, NWError>()
    var cancelled = false
    
    return UdpConnection(
      cancel: {
        conn.cancel()
        cancelled = true
        conn.stateUpdateHandler = nil
      },
      statePublisher: {
        let subject = PassthroughSubject<NWConnection.State, NWError>()
        conn.stateUpdateHandler = subject.send
        
        return subject
          .handleEvents(
            receiveSubscription: { _ in conn.start(queue: queue) }
          )
          .eraseToAnyPublisher()
      }(),
      receiveDataPublisher: {
        var receiveMessages: (() -> Void)?
        let receiveWrapper: ReceiveType = { data, context, complete, error in
          if let err = error {
            subject.send(completion: .failure(err))
          } else if let data = data {
            subject.send(data)
          }
          receiveMessages?()
        }
        
        receiveMessages = { [conn] in
          if !cancelled {
            conn.receiveMessage(completion: receiveWrapper)
          }
        }
        
        return subject
          .handleEvents(receiveSubscription: { subscription in
            receiveMessages?()
          })
          .eraseToAnyPublisher()
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
