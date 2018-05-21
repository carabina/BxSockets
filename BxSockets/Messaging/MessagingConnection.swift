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

public class MessagingConnection {
    
    private let socket: WebSocket
    private let registeredEvents: [ServerEvent]
    
    internal init(with socket: WebSocket, registeredEvents: [ServerEvent]) {
        self.socket = socket
        self.registeredEvents = registeredEvents
    }
    
    public func observe() -> Disposable {
        return Completable.create { complete in
            let disp1 = self.events.subscribe()
            self.socket.connect()
            let disp2 = self.socket.rx.disconnected
                .bind { _ in complete(.completed) }
            return Disposables.create {
                disp1.dispose()
                disp2.dispose()
                self.socket.disconnect()
            }
        }.subscribe()
    }
    
    public func send(_ event: ClientEvent) -> Completable {
        return Completable.create { complete in
            guard self.socket.isConnected else {
                complete(.error(BxSocketsFrameworks.Error.noConnection))
                return Disposables.create()
            }
            let disp = self.socket.rx.disconnected
                .bind { complete(.error($0 ?? BxSocketsFrameworks.Error.gracefulTermination)) }
            do {
                switch try event.generate() {
                case .data(let data):
                    self.socket.write(data: data) {
                        complete(.completed)
                    }
                case .text(let text):
                    self.socket.write(string: text) {
                        complete(.completed)
                    }
                }
            } catch {
                complete(.error(error))
            }
            return disp
        }
    }
    
    public lazy var events: Observable<ServerEvent> = {
        return Observable.create { observer in
            let events = Observable<MessagingEvent>.merge(self.socket.rx.dataReceived.map { .data($0) },
                                                          self.socket.rx.messageReceived.map { .text($0) })
            return events.subscribe(onNext: { event in
                let serverEvent = self.registeredEvents.first { (try? $0.isRecognized(with: event)) ?? false }
                try? serverEvent?.handle(message: event)
                observer.onNext(serverEvent ?? AnyServerEvent())
            })
        }.share()
    }()
    
    public lazy var connected: Observable<Bool> = {
        return Observable.create { observer in
            observer.onNext(self.socket.isConnected)
            let disp1 = self.socket.rx.connected
                .bind { observer.onNext(true) }
            let disp2 = self.socket.rx.disconnected
                .bind { _ in observer.onNext(false) }
            return Disposables.create(disp1, disp2)
        }.distinctUntilChanged().share(replay: 1)
    }()
    
    public func connect() -> Completable {
        return Completable.create { complete in
            if self.socket.isConnected {
                complete(.completed)
                return Disposables.create()
            }
            let disp1 = self.socket.rx.connected
                .bind { complete(.completed) }
            let disp2 = self.socket.rx.disconnected
                .bind { complete(.error($0 ?? BxSocketsFrameworks.Error.gracefulTermination)) }
            self.socket.connect()
            return Disposables.create(disp1, disp2)
        }
    }
    
    public func disconnect() -> Completable {
        return Completable.create { complete in
            if !self.socket.isConnected {
                complete(.completed)
                return Disposables.create()
            }
            let disp = self.socket.rx.disconnected
                .bind { _ in complete(.completed) }
            self.socket.disconnect()
            return disp
        }
    }
    
    deinit {
        if socket.isConnected {
            socket.disconnect()
        }
    }
}
