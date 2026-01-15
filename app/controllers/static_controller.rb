class StaticController < ApplicationController
  # All static pages are public - no authorization needed
  skip_authorization_check

  def privacy_policy
  end

  def terms_conditions
  end

  def about
  end

  def contact
  end
end
