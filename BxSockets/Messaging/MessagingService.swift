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
import RxSwift
import BxUtility

public protocol MessagingService {
    
    var serverUrl: UrlConvertible { get }
    var protocols: [MessagingProtocol] { get }
    
    var registeredEvents: [ServerEvent] { get }
}

extension MessagingService {
    
    public var protocols: [MessagingProtocol] {
        return []
    }
    
    public var registeredEvents: [ServerEvent] {
        return []
    }
    
    public func connection(forQoS qos: QualityOfService = .userInitiated) -> MessagingConnection {
        let socket = WebSocket(url: serverUrl.url!, writeQueueQOS: qos, protocols: protocols.map { $0.name })
        return .init(with: socket, registeredEvents: registeredEvents)
    }
}
