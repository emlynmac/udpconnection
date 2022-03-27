import Combine
import Foundation
import Network

///
/// Wrapper for UDP NWConnection in a Combine interface
///
public struct UdpConnection {
  public var cancel: () -> Void
  public var statePublisher: AnyPublisher<NWConnection.State, NWError>
  public var receiveDataPublisher: AnyPublisher<Data, NWError>
  public var remoteHost: String
  public var send: (Data) -> Void
}
