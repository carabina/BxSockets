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
import RxSwift
import Starscream
import RxCocoa

extension Reactive where Base: WebSocket {
    
    public var delegate: WebSocketDelegateProxy {
        return WebSocketDelegateProxy(socket: base)
    }
    
    public var connected: ControlEvent<Void> {
        return ControlEvent(events: delegate.didConnectSubject)
    }
    
    public var disconnected: ControlEvent<Error?> {
        return ControlEvent(events: delegate.didDisconnectSubject)
    }
    
    public var messageReceived: ControlEvent<String> {
        return ControlEvent(events: delegate.didReceiveMessageSubject)
    }
    
    public var dataReceived: ControlEvent<Data> {
        return ControlEvent(events: delegate.didReceiveDataSubject)
    }
}
