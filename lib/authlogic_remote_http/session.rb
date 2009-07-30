module AuthlogicRemoteHttp
  module Session
    # Add a simple openid_identifier attribute and some validations for the field.
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end
    
    module Config
      # The remote HTTP server hostname.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> String
      def remote_http_host(value = nil)
        rw_config(:remote_http_host, value)
      end
      alias_method :remote_http_host=, :remote_http_host
      
      # The remote URI path.  This requires a trailing slash for directory
      # locations.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> String
      def remote_http_path(value = nil)
        rw_config(:remote_http_path, value)
      end
      alias_method :remote_http_path=, :remote_http_path

      # The remote HTTP port.
      #
      # * <tt>Default:</tt> 80
      # * <tt>Accepts:</tt> Integer
      def remote_http_port(value = nil)
        rw_config(:remote_http_port, value, 80)
      end
      alias_method :remote_http_port=, :remote_http_port

      # Should we use SSL for the remote connection?  This uses VERIFY_NONE
      # because I don't really know of a good way to deal with wildcard
      # certs without monkeypatching Net::HTTP.
      #
      # * <tt>Default:</tt> false
      # * <tt>Accepts:</tt> Boolean
      def remote_http_use_ssl(value = nil)
        rw_config(:remote_http_use_ssl, value, false)
      end
      alias_method :remote_http_use_ssl=, :remote_http_use_ssl
      
      # Once remote HTTP authentication has succeeded we need to find the
      # user in the database. By default this just calls the 
      # find_by_remote_http_login method provided by ActiveRecord. If you
      # have a more advanced set up and need to find users differently
      # specify your own method and define your logic in there.
      #
      # For example, if you allow users to store multiple ldap logins with
      # their account, you might do something like:
      #
      #   class User < ActiveRecord::Base
      #     def self.find_by_remote_http_login(login)
      #       first(:conditions => [
      #         "#{RemoteHttpLogin.table_name}.login = ?", 
      #         login
      #       ], :join => :remote_http_logins)
      #     end
      #   end
      #
      # * <tt>Default:</tt> :find_by_remote_http_login
      # * <tt>Accepts:</tt> Symbol
      def find_by_remote_http_login_method(value = nil)
        rw_config(:find_by_remote_http_login_method, value, :find_by_remote_http_login)
      end
      alias_method :find_by_remote_http_login_method=, :find_by_remote_http_login_method
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :remote_http_login
          attr_accessor :remote_http_password
          validate :validate_by_remote_http, :if => :authenticating_with_remote_http?
        end
        def remote_http_use_encryption
          self.class.remote_http_use_encryption
        end
      end
      
      # Hooks into credentials to print out meaningful credentials for
      # remote HTTP authentication.
      def credentials
        if authenticating_with_remote_http?
          details = {}
          details[:remote_http_login] = send(login_field)
          details[:remote_http_password] = "<protected>"
          details
        else
          super
        end
      end
      
      # Hooks into credentials so that you can pass an :remote_http_login
      # and :remote_http_password key.
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        if !hash.nil?
          self.remote_http_login = hash[:remote_http_login] if hash.key?(:remote_http_login)
          self.remote_http_password = hash[:remote_http_password] if hash.key?(:remote_http_password)
        end
      end
      
      private
        def authenticating_with_remote_http?
          !remote_http_host.blank? && (!remote_http_login.blank? || !remote_http_password.blank?)
        end
        
        def validate_by_remote_http
          errors.add(:remote_http_login, I18n.t('error_messages.remote_http_login_blank', :default => "can not be blank")) if remote_http_login.blank?
          errors.add(:remote_http_password, I18n.t('error_messages.remote_http_password_blank', :default => "can not be blank")) if remote_http_password.blank?
          return if errors.count > 0

          require 'net/http'
          require 'net/https'
          http = Net::HTTP::new(remote_http_host, remote_http_port)
          if remote_http_use_ssl
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          req = Net::HTTP::Get.new(remote_http_path)
          req.basic_auth(remote_http_login, remote_http_password)
          result = http.request(req).header.code.to_i == 200
          if result
            self.attempted_record = search_for_record(find_by_remote_http_login_method, remote_http_login)
            errors.add(:remote_http_login, I18n.t('error_messages.login_not_found', :default => 'does not exist')) if attempted_record.blank?
          else
            errors.add_to_base("401 - Authorization Failed")
          end
        end
        
        def remote_http_host
          self.class.remote_http_host
        end
        
        def remote_http_path
          self.class.remote_http_path
        end

        def remote_http_port
          self.class.remote_http_port
        end
        
        def remote_http_use_ssl
          self.class.remote_http_use_ssl
        end

        def find_by_remote_http_login_method
          self.class.find_by_remote_http_login_method
        end
    end
  end
end
