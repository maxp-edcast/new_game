module AuthRoutes
  def self.extended(base)
    base.class_exec do

      get '/login' do
        render_login    # or render your own equivalent!
      end

      post '/login' do
        login
      end

      get '/signup' do
        render_signup   # or render your own equivalent!
      end

      post '/signup' do
        signup
      end

      get '/logout' do
        logout
      end

    end
  end
end