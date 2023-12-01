# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def index
    @bets = Bet.active.limit(10)
  end

  def faq; end

  def terms; end

  def contact; end
end
