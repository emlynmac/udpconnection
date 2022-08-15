import XCTest
@testable import UdpConnection

final class UdpConnectionTests: XCTestCase {
   
  func testRoundTrip() async throws {
    //  ncat -e /bin/cat -k -u -l 54321 on test target
    var urlBits = URLComponents()
    urlBits.host = "yourTestServerRunningNCAT"
    urlBits.port = 54321
    
    let atlantisEcho = urlBits.url!
    let conn = UdpConnection.live(
      url: atlantisEcho,
      queue: .main
    )
    
    let pingExpectation = expectation(description: "Ping is echoed")
    let helloData = "Hello!".data(using: .ascii)!
    
    let stateWatcher = Task {
      for await state in conn!.connectionState {
        switch state {
        case .ready:
          conn?.send(helloData)
        default:
          print(state)
        }
      }
    }
    
    Task {
      for try await data in conn!.receivedData {
        XCTAssertEqual(data, helloData)
        pingExpectation.fulfill()
        stateWatcher.cancel()
      }
    }
    
    wait(for: [pingExpectation], timeout: 10)
  }
}
