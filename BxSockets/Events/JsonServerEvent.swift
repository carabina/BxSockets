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
import BxCoding

public protocol JsonServerEvent: ServerEvent {
    
    associatedtype Message: FileDecodable
    
    func isRecognized(with message: Message) -> Bool
    func handle(message: Message) throws
}

extension JsonServerEvent {
    
    func isRecognized(with message: Message) -> Bool {
        return true
    }
    
    public func isRecognized(with event: MessagingEvent) throws -> Bool {
        switch event {
        case .data(let data):
            return isRecognized(with: try JsonDecoder.decode(data))
        case .text(let text):
            return isRecognized(with: try JsonDecoder.decode(.init(reading: text)))
        }
    }
    
    public func handle(message: MessagingEvent) throws {
        switch message {
        case .data(let data):
            try handle(message: try JsonDecoder.decode(data))
        case .text(let text):
            try handle(message: try JsonDecoder.decode(.init(reading: text)))
        }
    }
}
