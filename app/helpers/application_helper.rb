# frozen_string_literal: true

module ApplicationHelper
  def secret_admin_name
    ENV['ADMIN_NAME'] || 'konnor'
  end

  def secret_admin_password
    ENV['ADMIN_PASSWORD'] || 'supersecret'
  end
end
