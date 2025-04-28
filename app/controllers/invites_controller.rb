class InvitesController < ApplicationController
  def create
    @invite = Invite.new(invite_params)
    @invite.house = House.find(params[:house_id])
    @invite.inviter = current_user
    authorize @invite

    existing_invite = Invite.find_by(house: @house, invitee_email: @invite.invitee_email, status: "pending")

    if existing_invite
      redirect_to houses_path, alert: "That user has already been invited."
    elsif @invite.save
      # TODO
    else
      # TODO
    end
  end

  def update
    @invite = Invite.find(params[:id])

    unless @invite.pending? &&
           !@invite.expired? &&
           @invite.invitee.present? &&
           @invite.invitee.email == @invite.invitee_email
      redirect_to root_path, alert: "This invite cannot be updated."
      return
    end

    case params[:status]
    when 'accepted'
      @invite.accepted!
      @invite.house.users << @invite.invitee unless @invite.house.users.include?(@invite.invitee)
    when 'declined'
      @invite.declined!
    else
      @invite.errors.add(:status, "An invite can only be accepted or declined")
    end

    if @invite.errors.any?
      render :edit, status: :unprocessable_entity
    else
      redirect_to house_path(@invite.house), notice: "Invite updated."
    end
  end

  def accept
    # TODO
  end

  private

  def invite_params
    params.require(:invite).permit(:invitee_email, :status)
  end
end
