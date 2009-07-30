require "authlogic_remote_http/version"
require "authlogic_remote_http/acts_as_authentic"
require "authlogic_remote_http/session"

ActiveRecord::Base.send(:include, AuthlogicRemoteHttp::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicRemoteHttp::Session)
