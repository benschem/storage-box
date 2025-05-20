class ApplicationJob < ActiveJob::Base
  # Watches your queries for when you should add eager loading (N+1 queries) [https://github.com/flyerhzm/bullet]
  include Bullet::ActiveJob if Rails.env.development?

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 5

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Log when a job starts and finishes
  before_perform do |job|
    Rails.logger.info("Starting job #{job.class.name} with arguments: #{job.arguments}")
  end

  after_perform do |job|
    Rails.logger.info("Job #{job.class.name} completed successfully")
  end

  # Handle job failures
  rescue_from StandardError do |exception|
    Rails.logger.error("Job failed: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n")) if Rails.env.development?

    # Re-raise in non-prod so bugs are not silently ignored
    raise exception unless Rails.env.production?

    # TODO: AdminMailer.job_failed(exception).deliver_later
  end
end
