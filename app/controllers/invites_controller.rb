# frozen_string_literal: true

# Send, accept or decline an invite
class InvitesController < ApplicationController
  before_action :build_invite, only: [:create]
  before_action :set_invite, only: [:update]

  def create
    existing_invite = Invite.find_by(house: @invite.house, recipient_email: @invite.recipient_email, status: 'pending')

    if existing_invite
      flash.now[:alert] = 'That user has already been invited.'
      render :new
    elsif @invite.save
      redirect_to houses_path, notice: 'Invitation sent!'
    else
      flash.now[:alert] = 'Something went wrong! Invitation not sent.'
      render :new
    end
  end

  def update
    accept_or_decline_invite

    if @invite.errors.any?
      render :edit, status: :unprocessable_entity
    else
      notice = set_notice
      redirect_to house_path(@invite.house), notice: notice
    end
  end

  private

  def build_invite
    @invite = Invite.new(invite_params)
    @invite.house = House.find(params[:house_id])
    @invite.sender = current_user
    authorize @invite
  end

  def set_invite
    @invite = Invite.find(params[:id])
    authorize @invite

    return if valid_invite?

    redirect_to root_path, alert: 'This invite cannot be updated.'
  end

  def accept_or_decline_invite
    case params[:status]
    when 'accepted'
      current_user.accept_invite(@invite)
    when 'declined'
      current_user.decline_invite(@invite)
    else
      @invite.errors.add(:status, 'An invite can only be accepted or declined')
    end
  end

  def set_notice
    if @invite.accepted?
      "Accepted invitation to join #{@invite.house.name.capitalize}"
    elsif @invite.declined?
      "Declined invitation to join #{@invite.house.name.capitalize}"
    end
  end

  def invite_params
    params.require(:invite).permit(:recipient_email, :status)
  end

  def valid_invite?
    @invite.pending? &&
      !@invite.expired? &&
      @invite.recipient.present? &&
      @invite.recipient.email == @invite.recipient_email
  end
end
