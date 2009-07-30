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

      # The URI to which the HTTP Basic auth should happen.  This must be a
      # fully-formed uri of the form scheme://host:port/path/to/location/ , 
      # including the trailing slash in the case of a directory.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> String
      def remote_http_uri(value = nil)
        rw_config(:remote_http_uri, value)
      end
      alias_method :remote_http_uri=, :remote_http_uri

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
          !remote_http_uri.blank? && (!remote_http_login.blank? || !remote_http_password.blank?)
        end
        
        def validate_by_remote_http
          errors.add(:remote_http_login, I18n.t('error_messages.remote_http_login_blank', :default => "can not be blank")) if remote_http_login.blank?
          errors.add(:remote_http_password, I18n.t('error_messages.remote_http_password_blank', :default => "can not be blank")) if remote_http_password.blank?
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
          if result
            self.attempted_record = search_for_record(find_by_remote_http_login_method, remote_http_login)
            errors.add(:remote_http_login, I18n.t('error_messages.login_not_found', :default => 'does not exist')) if attempted_record.blank?
          else
            errors.add_to_base("401 - Authorization Failed")
          end
        end

        def remote_http_uri
          self.class.remote_http_uri
        end

        def find_by_remote_http_login_method
          self.class.find_by_remote_http_login_method
        end
    end
  end
end
