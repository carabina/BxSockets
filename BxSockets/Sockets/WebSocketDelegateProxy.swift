// Copyright 2018 Oliver Borchert
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Starscream
import RxCocoa
import RxSwift

extension WebSocket: HasDelegate {
    
    public typealias Delegate = WebSocketDelegate
}

open class WebSocketDelegateProxy: DelegateProxy<WebSocket, WebSocketDelegate>, DelegateProxyType, WebSocketDelegate {
    
    private weak var forwardDelegate: WebSocketDelegate?
    public weak private(set) var socket: WebSocket?
    
    internal let didConnectSubject = PublishRelay<Void>()
    internal let didDisconnectSubject = PublishRelay<Error?>()
    internal let didReceiveMessageSubject = PublishRelay<String>()
    internal let didReceiveDataSubject = PublishRelay<Data>()
    
    public init(socket: WebSocket) {
        self.socket = socket
        super.init(parentObject: socket, delegateProxy: WebSocketDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { WebSocketDelegateProxy(socket: $0) }
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        forwardDelegate?.websocketDidConnect(socket: socket)
        didConnectSubject.accept(())
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        forwardDelegate?.websocketDidDisconnect(socket: socket, error: error)
        didDisconnectSubject.accept(error)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        forwardDelegate?.websocketDidReceiveMessage(socket: socket, text: text)
        didReceiveMessageSubject.accept(text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        forwardDelegate?.websocketDidReceiveData(socket: socket, data: data)
        didReceiveDataSubject.accept(data)
    }
}
