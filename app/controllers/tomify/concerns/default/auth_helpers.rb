module Tomify
  module Concerns
    module Default
      module AuthHelpers
        def not_found
          raise ActionController::RoutingError.new("Not Found")
        end

        def current_user
          @current_user ||= User.find_by(id: session[:current_user_id])
        end

        def require_user!
          not_found unless current_user
        end

        def require_admin!
          redirect_to root_path unless current_user.admin
        end

        def check_token
          return unless params[:token] && user = User.joins(:tokens).find_by(tokens: { uuid: params[:token] })
          session[:current_user_id] = user.id
        end
      end
    end
  end
end
