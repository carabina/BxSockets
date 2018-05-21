Pod::Spec.new do |s|

    s.name             = 'BxSockets'
    s.version = '0.1.1'
    s.swift_version    = '4.1'
    s.summary          = 'Beautiful WebSocket communication with Swift.'

    s.description      = 'BxSockets makes use of Starscream to provide a beautifully reactive way of using WebSockets.'

    s.homepage          = 'https://bxsockets.borchero.com'
    s.documentation_url = 'https://bxsockets.borchero.com/docs'
    s.license           = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author            = { 'Oliver Borchert' => 'borchero@icloud.com' }
    s.source            = { :git => 'https://github.com/borchero/BxSockets.git',
                            :tag => s.version.to_s }

    s.platform = :ios
    s.ios.deployment_target = '11.0'

    s.source_files = 'BxSockets/**/*'

    s.dependency 'RxSwift', '~> 4.0'
    s.dependency 'RxCocoa', '~> 4.0'
    s.dependency 'BxUtility', '~> 1.2.1'
    s.dependency 'BxCoding', '~> 1.0.0'
    s.dependency 'Starscream', '~> 3.0'

    s.framework = 'Foundation'

end
