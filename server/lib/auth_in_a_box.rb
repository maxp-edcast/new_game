#           NAME: authinabox
#        VERSION: 1.01 (Dec 27, 2008)
#         AUTHOR: Peter Cooper [ http://www.rubyinside.com/ github:peterc twitter:peterc ]
#    DESCRIPTION: An "all in one" Sinatra library containing a User model and authentication
#                 system for both session-based logins OR HTTP Basic auth (for APIs, etc).
#                 This is an "all in one" system so you will probably need to heavily tailor
#                 it to your own ideas, but it will work "out of the box" as-is.
#  COMPATIBILITY: - Tested on 0.3.2 AND the latest rtomayko Hoboken build! (recommended for the latter though)
#                 - NEEDS DataMapper!
#                 - Less work needed if you use initializer library -- http://gist.github.com/40238
#                   (remember to turn sessions on!!)
#        LICENSE: Use for what you want, just don't claim full credit unless you make significant changes
#
#   INSTRUCTIONS: To come in full later..
#                 Basically, require in lib/authinabox from your Sinatra app
#                 Tie up login, logout, and signup methods as shown in example at bottom of this file
#                 Use current_user, login_required, etc, from your app (as shown in example)
#                 If you do NOT want .json, .xml, etc, requests going to HTTP Basic auth, head down to line 200.



# ====== DEFAULT OPTIONS FOR PLUGIN ====== 
module Sinatra
  module Plugins
    module AuthInABox
      OPTIONS = { 
        :login_url => '/login',
        :logout_url => '/logout',
        :signup_url => '/signup',
        :after_signup_url => '/',
        :after_logout_url => '/',
        :template_language => :erb
      }
    end
  end
end


# ====== USER MODEL ======          
            
class User
  include DataMapper::Resource

  attr_accessor :password, :password_confirmation

  property :id, Serial, :writer => :protected, :key => true
  property :email, String, required: true, :length => (5..40), :unique => true, :format => :email_address
  property :username, String, required: true, :length => (2..32), :unique => true
  property :hashed_password, String, :writer => :protected
  property :salt, String, required: true, :writer => :protected
  property :created_at, DateTime
  property :account_type, String, required: true, :default => 'standard', :writer => :protected
  property :active, Boolean, :default => true, :writer => :protected
  
  validates_present :password_confirmation
  validates_is_confirmed :password

  # Authenticate a user based upon a (username or e-mail) and password
  # Return the user record if successful, otherwise nil
  def self.authenticate(username_or_email, pass)
    current_user = first(:username => username_or_email) || first(:email => username_or_email)
    return nil if current_user.nil? || User.encrypt(pass, current_user.salt) != current_user.hashed_password
    current_user
  end  

  # Set the user's password, producing a salt if necessary
  def password=(pass)
    @password = pass
    self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  protected
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end
end            




# ====== LOGIC ====== 

module Sinatra
  module Plugins
    module AuthInABox
      # ====== CONTROLLERS AND VIEWS ======
      
      # Present login screen (these are really last resorts, you should code your own and call them from your app!)
      def render_login
        if Plugins::AuthInABox::OPTIONS[:template_language] == :haml          
          haml clean(<<-EOS)
                        %form{ :method => "post" }
                          %label
                            username or e-mail:
                          %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %label
                            password:
                          %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %input{ :type => "submit", :value => "login" }
                        EOS
        else
          erb clean(<<-EOS)
          <form method='post'>
            <label>
              username or e-mail:
            </label>
            <input id='user_username' name='username' size='30' type='text' />
            <label>
              password:
            </label>
            <input id='user_password' name='password' size='30' type='password' />
            <input type='submit' value='login' />
          </form>
          EOS
        end
      end
      
      # Log in
      def login
          if user = User.authenticate(params[:username], params[:password])
            session[:user] = user.id
            redirect_to_stored
          else
            redirect Plugins::AuthInABox::OPTIONS[:login_url]
          end
      end
      
      # Log out and delete session info
      def logout
        session[:user] = nil
        redirect Plugins::AuthInABox::OPTIONS[:after_logout_url]
      end
      
      # Present signup page
      def render_signup
        if Plugins::AuthInABox::OPTIONS[:template_language] == :haml
          haml clean(<<-EOS)
                        %form{ :action => "#{Plugins::AuthInABox::OPTIONS[:signup_url]}", :method => "post" }
                          %label
                            username:
                          %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %label
                            email:
                          %input{ :id => "user_email", :name => "email", :size => 30, :type => "text" }
                          %label
                            password:
                          %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %label
                            confirm:
                          %input{ :id => "user_password_confirmation", :name => "password_confirmation", :size => 30, :type => "password" }
                          %input{ :type => "submit", :value => "sign up" }
                        EOS
        else
          erb clean(<<-EOS)
            <form action='#{Plugins::AuthInABox::OPTIONS[:signup_url]}' method='post'>
              <label>
                username:
              </label>
              <input id='user_username' name='username' size='30' type='text' />
              <label>
                email:
              </label>
              <input id='user_email' name='email' size='30' type='text' />
              <label>
            
                password:
              </label>
              <input id='user_password' name='password' size='30' type='password' />
              <label>
                confirm:
              </label>
              <input id='user_password_confirmation' name='password_confirmation' size='30' type='password' />
              <input type='submit' value='sign up' />
            </form>
          EOS
        end
      end
      
      def signup
        @user = User.new(:email => params[:email], :username => params[:username], :password => params[:password], :password_confirmation => params[:password_confirmation])
        if @user.save
          session[:user] = @user.id
          redirect Plugins::AuthInABox::OPTIONS[:after_signup_url]
        else
          puts @user.errors.full_messages
          redirect Plugins::AuthInABox::OPTIONS[:signup_url]
        end
      end
      
      
      # ====== HELPERS ======
      class Sinatra::Base
        def login_required
          if session[:user]
            return true
          elsif request.env['REQUEST_PATH'] =~ /(\.json|\.xml)$/ && request.env['HTTP_USER_AGENT'] !~ /Mozilla/
              @auth ||= Rack::Auth::Basic::Request.new(request.env)
              if @auth.provided? && @auth.basic? && @auth.credentials && User.authenticate(@auth.credentials.first, @auth.credentials.last)
                session[:user] = User.first(:username => @auth.credentials.first).id
                return true
              else
                status 401
                halt("401 Unauthorized") rescue throw(:halt, "401 Unauthorized")
              end
          else
            session[:return_to] = request.fullpath
            redirect Plugins::AuthInABox::OPTIONS[:login_url]
            pass rescue throw :pass
          end
        end
        
        def admin_required
          return true if login_required && current_user.account_type == 'admin'
          redirect '/'
        end
          
        def current_user
          User.get(session[:user])
        end
          
        def redirect_to_stored
          if return_to = session[:return_to]
            session[:return_to] = nil
            redirect return_to
          else
            redirect '/'
          end
        end
        
        # Cleans indentation for heredocs
        def clean(str); str.gsub(/^\s{#{str[/\s+/].length}}/, ''); end
      end

    end
  end
end

# Little hack to make inclusion work with both Sinatra 0.3.2 and latest experimental builds
(Sinatra::Base rescue Sinatra::EventContext).send(:include, Sinatra::Plugins::AuthInABox) 

# Get database up to date
DataMapper.auto_upgrade!


# CLIENT SIDE EXAMPLE CODE
#
# require 'lib/authinabox'
#
# get '/login' do
#   render_login    # or render your own equivalent!
# end
# 
# post '/login' do
#   login
# end
# 
# get '/signup' do
#   render_signup   # or render your own equivalent!
# end
# 
# post '/signup' do
#   signup
# end
# 
# get '/logout' do
#   logout
# end
#
# Example of using login_required..
#
# get '/api.json' do
#   login_required
#   content_type "text/json"
#   "{ 'a': 'b' }"
# end