module AuthlogicRemoteHttp
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        extend Config
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Config
      # Whether or not to validate the remote_http_login field. If set to false ALL ldap validation will need to be
      # handled by you.
      #
      # * <tt>Default:</tt> true
      # * <tt>Accepts:</tt> Boolean
      def validate_remote_http_login(value = nil)
        rw_config(:validate_remote_http_login, value, true)
      end
      alias_method :validate_remote_http_login=, :validate_remote_http_login
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :remote_http_password
          
          if validate_remote_http_login
            validates_uniqueness_of :remote_http_login, :scope => validations_scope, :if => :using_remote_http?
            validates_presence_of :remote_http_password, :if => :validate_remote_http?
            validate :validate_remote_http, :if => :validate_remote_http?
          end
        end
      end
      
      private
        def using_remote_http?
          !remote_http_login.blank?
        end

        def validate_remote_http
          return if errors.count > 0
        
          require 'uri'
          require 'net/http'
          require 'net/https'
          myuri = URI.parse(remote_http_uri)
          http = Net::HTTP::new(myuri.host, myuri.port)
          if myuri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          req = Net::HTTP::Get.new(myuri.path)
          req.basic_auth(remote_http_login, remote_http_password)
          result = http.request(req).header.code.to_i == 200
          errors.add_to_base('401 - Authorization Failed') unless result
        end
        
        def validate_remote_http?
          remote_http_login_changed? && !remote_http_login.blank?
        end
    end
  end
end
