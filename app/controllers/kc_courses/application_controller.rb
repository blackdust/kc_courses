module KcCourses
  class ApplicationController < ActionController::Base
    layout "kc_courses/application"

    if defined? PlayAuth
      helper PlayAuth::SessionsHelper
    end
  end
end