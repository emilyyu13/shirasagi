module Cms::Addon
  module Thumb
    extend ActiveSupport::Concern
    extend SS::Addon
    include SS::Relation::File

    included do
      attr_accessor :in_thumb

      belongs_to_file :thumb, accepts: SS::File::IMAGE_FILE_EXTENSIONS
      permit_params :in_thumb
      validate :validate_thumb

      before_save :clone_thumb, if: ->{ try(:new_clone?) }
      after_generate_file :generate_thumb_public_file if respond_to?(:after_generate_file)
      after_remove_file :remove_thumb_public_file if respond_to?(:after_remove_file)

      if respond_to?(:liquidize)
        liquidize do
          export :thumb
        end
      end
    end

    private

    def validate_thumb
      return if thumb.blank? || thumb.image?
      errors.add :thumb_id, :thums_is_not_an_image
    end

    def generate_thumb_public_file
      return if thumb.blank?
      thumb.generate_public_file
    end

    def remove_thumb_public_file
      return if thumb.blank?
      thumb.remove_public_file
    end
  end
end
