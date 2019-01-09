module AuthenticationHelper
  module ControllerMixin
    def authenticate_as_stub_user
      request.env['warden'] = double(
        authenticate!: true,
        authenticated?: true,
      )
    end
  end
end
