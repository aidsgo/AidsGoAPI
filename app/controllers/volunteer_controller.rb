class VolunteerController < ApplicationController
  def show_all
    render json: Volunteer.all
  end
end