import XCTest
@testable import UdpConnection

final class UdpConnectionTests: XCTestCase {
   
  func testRoundTrip() throws {
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
    
    _ = conn?.receiveDataPublisher
      .sink(receiveCompletion: { completion in
        
      }, receiveValue: { data in
        XCTAssertEqual(data, helloData)
        pingExpectation.fulfill()
      })
    
    _ = conn?.statePublisher.sink(
      receiveCompletion: { completion in
        switch completion {
        case .failure(let nwErr):
          XCTFail(nwErr.debugDescription)
        default:
          break
        }
      },
      receiveValue: { state in
        switch state {
        case .ready:
          conn?.send(helloData)
          
        default:
          print(state)
        }
      })
    
    
    wait(for: [pingExpectation], timeout: 10)
  }
}
