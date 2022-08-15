import Foundation
import Network

///
/// Wrapper for UDP NWConnection in a async interface
///
public struct UdpConnection {
  public var cancel: () -> Void
  public var connectionState: AsyncStream<NWConnection.State>
  public var receivedData: AsyncThrowingStream<Data, Error>
  public var remoteHost: String
  public var send: (Data) -> Void
}
