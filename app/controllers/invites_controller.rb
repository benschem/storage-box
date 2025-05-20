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
      flash.now[:alert] = "Invitation sent!"
    else
      flash.now[:alert] = "Something went wrong! Invitation not sent."
    end
  end

  def update
    @invite = Invite.find(params[:id])
    authorize @invite

    unless valid_invite?
      redirect_to root_path, alert: "This invite cannot be updated."
      return
    end

    case params[:status]
    when 'accepted'
      @invite.accept_and_join_house!
    when 'declined'
      @invite.decline_invite!
    else
      @invite.errors.add(:status, "An invite can only be accepted or declined")
    end

    if @invite.errors.any?
      render :edit, status: :unprocessable_entity
    else
      notice = "Invite updated."
      if @invite.accepted?
        notice = "Accepted invitation to join #{@invite.house.name.capitalize}"
      elsif @invite.declined?
        notice = "Declined invitation to join #{@invite.house.name.capitalize}"
      end
      redirect_to house_path(@invite.house), notice: notice
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:invitee_email, :status)
  end

  def valid_invite?
    @invite.pending? &&
    !@invite.expired? &&
    @invite.invitee.present? &&
    @invite.invitee.email == @invite.invitee_email
  end
end
